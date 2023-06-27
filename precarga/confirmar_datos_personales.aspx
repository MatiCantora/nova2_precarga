<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%
    Dim accion As String = nvUtiles.obtenerValor({"accion","a"}, "")
    Dim nro_entidad As String = ""
    Dim strXML As String = ""
    Dim dni As String = nvFW.nvUtiles.obtenerValor("dni", "")
    Dim nro_tabla As String
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
    Dim cod_prov As String = nvFW.nvUtiles.obtenerValor("cod_prov", "")
    Dim apellido As String = nvFW.nvUtiles.obtenerValor("apellido", "")
    Dim nombre As String = nvFW.nvUtiles.obtenerValor("nombre", "")
    Dim fecha_nac As String = nvFW.nvUtiles.obtenerValor("fecha_nac", "")
    Dim sexo As String = nvFW.nvUtiles.obtenerValor("sexo", "")
    Dim localidad As String = nvFW.nvUtiles.obtenerValor("localidad", "")
    Dim carac As String = nvFW.nvUtiles.obtenerValor("carac", "")
    Dim estado_credito As String = ""
    Dim estado As String = ""
    Dim contingenciaQNET As Boolean = IIf(nvFW.nvUtiles.getParametroValor("contingenciaQNET") = "1", True, False)
    'Dim localidad As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim telefono As String = nvFW.nvUtiles.obtenerValor("telefono", "")

    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", 0)
    Dim criterio As String = nvUtiles.obtenerValor("criterio", "")

    If (accion = "validacbu" And criterio <> "") Then
        Dim XML As System.Xml.XmlDocument
        XML = New System.Xml.XmlDocument
        XML.LoadXml(criterio)
        Dim id_cuenta_consulta As String = nvXMLUtiles.getNodeText(XML, "criterio/id_cuenta", "")
        Dim nro_credito_consulta As String = nvXMLUtiles.getNodeText(XML, "criterio/nro_credito", "")
        Dim nro_entidad_banking As String = ""
        Dim nro_cuenta_banking As String = ""

        Dim rs = nvDBUtiles.DBOpenRecordset("select case when c.nro_banco=31 then b.nro_entidad else 403 end as nro_entidad_banking,c.cuit  from vercreditos c join Banco b on c.nro_banco=b.nro_banco where c.nro_credito=" & nro_credito_consulta)
        If (Not rs.EOF) Then
            nro_entidad_banking = rs.Fields("nro_entidad_banking").Value
            cuit = rs.Fields("cuit").Value
        End If

        rs = nvDBUtiles.DBOpenRecordset("select * from verEntidad_bco_ctas where id_cuenta=" & id_cuenta_consulta)
        If (Not rs.EOF) Then
            nro_cuenta_banking = rs.Fields("nro_cuenta").Value
        End If
        If (nro_cuenta_banking <> "" And nro_entidad_banking <> "") Then
            Dim Err As New tError
            Try
                Dim valida As Boolean = 0
                rs = nvDBUtiles.DBOpenRecordset("select url_servicio,pwd_certificado,path_certificado  from verPiz_340_apibanking_accesos where testing=0 and nro_entidad=" & nro_entidad_banking)
                ''directorio_archivos\apivoii\amus_prod.pfx
                If (Not rs.EOF) Then
                    Dim path_certificado As String = nvServer.appl_physical_path & "App_Data\localfile\" & rs.Fields("path_certificado").Value
                    Dim apivoii As New nvFW.servicios.voii.ApiBanking(urlpdfx:=path_certificado, pwdpdfx:=rs.Fields("pwd_certificado").Value, host:=rs.Fields("url_servicio").Value, nro_entidad_consulta:=CInt(nro_entidad_banking))
                    apivoii.inicializar()
                    apivoii.timeout = 180000
                    valida = apivoii.validacuentaARS(nro_cuenta:=nro_cuenta_banking, cuit:=cuit, err:=Err)
                    Err.params("path_certificado") = path_certificado
                Else
                    Err.numError = -10
                    Err.mensaje = "servicio no disponible para esta entidad"
                End If
                If (valida) Then
                    Err.params("cuentavalida") = 1
                Else
                    Err.params("cuentavalida") = 0
                    If (Err.numError = -100 And contingenciaQNET) Then
                        Err.params("cuentavalida") = -1
                    End If
                End If
            Catch ex As Exception
                Err.parse_error_script(ex)
                Err.numError = -1
                Err.mensaje = ex.Message.ToString
            End Try
            strXML = Err.get_error_xml()
        End If ''consulta banking
        nvXMLUtiles.responseXML(Response, strXML)
        Response.End()
    End If


    If (accion = "updatecobro") Then
        Dim Err As New tError
        Dim cobro As String = nvFW.nvUtiles.obtenerValor("cobro", "")
        If (cobro <> "") Then
            Try
                Dim nro_pago_tipo As String = IIf(cobro = "1", "6", "1") '' si cobro es cheque, pago tipo es cheque, todo los demas casos, deposito
                Dim stmt = "update credito set cobro=" & cobro & " where nro_credito=" & CStr(nro_credito) & vbCrLf
                stmt &= "update pago_registro_detalle set nro_pago_tipo=" & nro_pago_tipo & " where nro_pago_registro in(select nro_pago_registro  from pago_registro where nro_credito=" & CStr(nro_credito) & " and nro_pago_concepto=5)" & vbCrLf
                nvDBUtiles.DBExecute(stmt)
            Catch ex As Exception
                Err.parse_error_script(ex)
            End Try
        Else
            Err.numError = -1
            Err.mensaje = "no se defini� el cobro"
        End If

        Err.response()
    End If





    Dim rsc = nvFW.nvDBUtiles.DBExecute("select * from vercreditos where nro_credito=" & CStr(nro_credito))
    Dim tipo_docu = rsc.Fields("tipo_docu").Value
    Dim nro_docu = rsc.Fields("nro_docu").Value
    sexo = rsc.Fields("sexo").Value
    estado = rsc.Fields("estado").Value
    Dim id_cuenta = rsc.Fields("id_cuenta").Value
    nro_entidad = rsc.Fields("nro_entidad").Value
    nro_tabla = rsc.Fields("nro_tabla").Value

    Dim id_calificacion = nvFW.nvUtiles.obtenerValor("id_solicitud", 0)


    strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    estado_credito = nvFW.nvUtiles.obtenerValor("estado", "Pendiente")

    Me.contents.Add("provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>"))
    'Me.contents.Add("banco", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='banco'><campos>banco</campos><filtro></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("solicitud", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_solicitud_parametros'><campos>*,convert(varchar,fe_estado,103) as str_fe_estado</campos><filtro></filtro><orden>fecha desc</orden></select></criterio>"))
    Me.contents.Add("creditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>*,convert(varchar,fe_naci,103) as fecha_nacimiento</campos><filtro></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("referencias", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Telefono'><campos>*</campos><filtro><nro_contacto_tipo type='in'>2,9,10</nro_contacto_tipo><vigente type='igual'>1</vigente></filtro><orden></orden></select></criterio>"))
    ''Me.contents.Add("cuentas", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>*</campos><orden></orden><filtro><r_tipo_cuenta type='igual'>2</r_tipo_cuenta></filtro></select></criterio>"))
    Me.contents.Add("cuentas", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>*</campos><orden></orden><filtro><not><cbu type='igual'>''</cbu></not><tipo_cuenta_desc type='distinto'>'CVU'</tipo_cuenta_desc></filtro></select></criterio>"))

    Me.contents("filtro_cobro_grupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerCobro_Grupos'><campos>cobro as id,detalle as [campo]</campos><orden>orden</orden><filtro><SQL type='sql'>nro_cobro_grupo in(select nro_cobro_grupo  from verTablas where nro_tabla=" & nro_tabla & ")</SQL></filtro></select></criterio>")




    Dim GOOGLE_MAPS_API_KEY_BROWSER As String = "AIzaSyAvpe0ahD3qvGRpQLgc2cvUYLro_jS4-Q8"



%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="X-UA-Compatible" content="IE=edge">
     <meta name="viewport" content="initial-scale=1 " lang="es" >
     <meta name="viewport" content="width=device-width, user-scalable=no" lang="es" >
    
    <title>confirmacion de datos personales</title>
    <meta name="google" content="notranslate" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />

   
    <meta name="mobile-web-app-capable" content="yes"lang="es"  >
    <meta http-equiv="Content-Language" content="es"/>
    <link href="/precarga/image/icons/nv_mutual.png"  sizes="193x193" rel="shortcut icon" />
    <title>NOVA Precarga</title>
   




<style type="text/css">
.pac-logo:after{
    display:none
}   

</style>

    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>
    
    <%-- Google Maps API --%>
    <script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=<% = GOOGLE_MAPS_API_KEY_BROWSER %>&libraries=places&region=AR"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript" class="table_window">
        var nro_banco_cr=''
        var dataloaded=0
        var refloaded=0
        var datos_iniciales = $H({apellido: '', nombres: '', fe_naci: '',sexo:'',id_estado_civil:'',calle:'',numero:'',piso:'',depto:'',ciudad:'',postal_real:'',cod_prov:'',numTel:'',ref1_carac:'',ref1_numtel:'',ref1_apenom:'',ref2_carac:'',ref2_numtel:'',ref2_apenom:'',laboral_carac:'',laboral_numtel:'',laboral_lugar_trabajo:'',apellido_materno:''});
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var ismobile
        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardar()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "cancelar";
        vButtonItems[1]["onclick"] = "return cancelar()";

        vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "Agregar";
        vButtonItems[2]["etiqueta"] = "Agregar";
        vButtonItems[2]["imagen"] = "agregar";
        vButtonItems[2]["onclick"] = "return agregar_cuenta()";
       

        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.loadImage("guardar", "/FW/image/icons/guardar.png");
        vListButtons.loadImage("cancelar", "/FW/image/icons/cancelar.png");
        vListButtons.loadImage("verificar", "/FW/image/icons/confirmar.png");
        vListButtons.loadImage("agregar", "/FW/image/icons/agregar.png");

        var win = nvFW.getMyWindow()



        // Maps
        var autocomplete;
        var autocomplete_city;
        var numeroTelValidado = ''        
        var cuit = '<%= cuit %>'
        var nro_credito = '<%= nro_credito%>'
        var token = 0
        var nro_solicitud = 0
        var estado_credito = '<%=estado_credito %>'
        
        function window_onload() { 
            paramsave["solicitud"]=0
            paramsave["mensaje_solicitud"]=""
            paramsave["cuenta"]=0
            paramsave["mensaje_cuenta"]=""

            ismobile = (parent.isMobile()) ? true : false
            vListButtons.MostrarListButton()
            campos_defs.add("cod_prov_arg", { nro_campo_tipo: 1, enDB: true, target: "tdprovincia" })
             nvFW.enterToTab = false;
            inicializarMaps();      
            //solo consulto las solicitudes pendientes, sino cargo los datos que vienen desde la persona
            if (nro_credito > 0) {
                var rs = new tRS()
                rs.open(nvFW.pageContents.solicitud, '', "<nro_credito type='igual'>" + nro_credito + "</nro_credito><nro_tipo_solicitud type='igual'>3</nro_tipo_solicitud><estado_solicitud type='igual'>'P'</estado_solicitud>")
               if(!rs.eof()){
                cargar_datos_desde_sol(rs)
               }else{
                var rs = new tRS()
                rs.open(nvFW.pageContents.creditos, '', "<nro_credito type='igual'>" + nro_credito + "</nro_credito>")
                cargar_datos_desde_cr(rs)
                cargar_referencias() //la referencias las cargo cuando no hay solicitud pendiente
               }

                campos_defs.habilitar("apellido", true)
                campos_defs.habilitar("persona", true)
                campos_defs.habilitar("sexo", true)
                campos_defs.habilitar("dni", false)
                campos_defs.habilitar("cuit", false)

            }
            
            if (estado_credito != 'Pendiente' && nro_credito > 0) {
                 habilitarCampos(false)
            }

          

            var input = $('fe_naci');
            input.placeholder = 'dd/mm/yyyy';
            
            cargar_cuentas_persona()
        }

      


        function cargar_datos_iniciales(){
            
            if(dataloaded==1 && refloaded==1){             
            datos_iniciales.set("apellido",$F("apellido"))
            datos_iniciales.set("nombres",$F("persona"))
            datos_iniciales.set("fe_naci",$F("fe_naci"))
            datos_iniciales.set("sexo",$F("sexo"))
            datos_iniciales.set("id_estado_civil",$F("id_estado_civil"))
            datos_iniciales.set("calle",$F("calle"))
            datos_iniciales.set("numero",$F("numero"))
            datos_iniciales.set("piso",$F("piso"))
            datos_iniciales.set("depto",$F("depto"))
            datos_iniciales.set("ciudad",$F("ciudad"))
            datos_iniciales.set("postal_real",$F("postal"))
            datos_iniciales.set("cod_prov",$F("cod_prov_arg"))
            datos_iniciales.set("numTel",$F("numTel"))
            datos_iniciales.set("ref1_carac",$F("ref1_carac"))
            datos_iniciales.set("ref1_numtel",$F("ref1_numTel"))
            datos_iniciales.set("ref1_apenom",$F("ref1_apenom"))
            datos_iniciales.set("ref2_carac",$F("ref2_carac"))
            datos_iniciales.set("ref2_numtel",$F("ref2_numTel"))
            datos_iniciales.set("ref2_apenom",$F("ref2_apenom"))
            datos_iniciales.set("laboral_carac",$F("laboral_carac"))
            datos_iniciales.set("laboral_numtel",$F("laboral_numTel"))
            datos_iniciales.set("laboral_lugar_trabajo",$F("laboral_lugar_trabajo"))
            datos_iniciales.set("apellido_materno",$F("apellido_materno"))
            }
           

        }

        var estados_cuenta="HPRXM" 
        var win_abm_cuentas
        function agregar_cuenta(){
            if(estados_cuenta.indexOf($F("estado"))>=0){
             win_abm_cuentas =  window.top.createWindow2({
                url: 'Cuenta_ABM.aspx?modo=V&nro_entidad='+$F("nro_entidad"),
                title: '<b>ingrese banco y cbu</b>',
                centerHFromElement: window.top.$("contenedor"),
                parentWidthElement: window.top.$("contenedor"),
                parentWidthPercent: 0.9,
                parentHeightElement: window.top.$("contenedor"),
                parentHeightPercent: 0.9,
                maxHeight: 150,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: datos_cuentas_return
            });
            
            win_abm_cuentas.options.userData = {}
            win_abm_cuentas.showCenter(true)   
        }else{
            alert("El estado en que se encuentra el credito, no se pueden agregar cuentas")
        }
             
            
        }//agregar


         function datos_cuentas_return(){            
            if(win_abm_cuentas.options.userData['add']==1){
                cargar_cuentas_persona()
            }
        }


        function cargar_datos_desde_sol (rs,verificarpendiente = 1){
            var estado_desc_str=''
            var estado_str=''
            var operador_estado_str=''
            var str_fe_estado_sol=''
            var estado_cr=''
            while (!rs.eof()) {    
            operador_estado_str=rs.getdata('nombre_operador_estado')                
            estado_str=rs.getdata('estado_solicitud')                
            estado_cr=rs.getdata('estado')                
            estado_desc_str=rs.getdata('estado_solicitud_desc') 
            str_fe_estado_sol=rs.getdata('str_fe_estado') 
            nro_banco_cr=rs.getdata("nro_banco")
              //si esta en estado pendiente y el usuario quiere verificar , realiza la pregunta. Sino, lo ignora y continua cargando             
             if (estado_str == "P" && verificarpendiente==1) {
                cargar_datos_desde_sol(rs,0)
                return
             }//solicitud pendiente

            nro_solicitud = rs.getdata('nro_solicitud')
                        
                    switch (rs.getdata("parametro")) {

                        case "apellido":
                            campos_defs.set_value("apellido", rs.getdata("valor"))
                            break;                        
                        case "calle":
                            campos_defs.set_value("calle", rs.getdata("valor"))                          
                            break;
                        case "car_tel":
                            $('carac').value = +rs.getdata("valor")                          
                            break;                      
                        case "cod_prov":
                            campos_defs.set_value("cod_prov_arg", rs.getdata("valor"))                           
                            break;
                        case "depto":
                            campos_defs.set_value("depto", rs.getdata("valor"))                          
                            break;                        
                        case "estado_civil":
                            campos_defs.set_value("id_estado_civil", rs.getdata("valor"))                           
                            break;
                        case "fe_naci":
                            campos_defs.set_value("fe_naci", rs.getdata("valor"))                            
                            break;
                        case "localidad":
                            campos_defs.set_value("ciudad", rs.getdata("valor"))                          
                            break;
                        case "nombres":
                            campos_defs.set_value("persona", rs.getdata("valor"))                            
                            break;
                        case "nro_docu":
                            campos_defs.set_value("dni", rs.getdata("valor"))                         
                            break;
                        case "numero":
                            campos_defs.set_value("numero", rs.getdata("valor"))                           
                            break;
                        case "piso":
                            campos_defs.set_value("piso", rs.getdata("valor"))                          
                            break;
                        case "postal_real":
                            campos_defs.set_value("postal", rs.getdata("valor"))                           
                            break;                        
                        case "sexo":
                            campos_defs.set_value("sexo", rs.getdata("valor"))
                            if(verificarpendiente==0)
                            campos_defs.habilitar("sexo", false)
                        break;
                        case "telefono":
                            $('numTel').value = rs.getdata("valor")                        
                            break;
                        case "cuil":
                        campos_defs.set_value("cuit",rs.getdata("valor"))
                        break;
                        case "email":
                        campos_defs.set_value("email",rs.getdata("valor"))
                        break;
                        case "token_celular":
                            token = rs.getdata("valor")
                            break;
                        case "ref1_carac":
                        $("ref1_carac").value=rs.getdata("valor")
                        break;
                        case "ref2_carac":
                        $("ref2_carac").value=rs.getdata("valor")
                        break;
                        case "laboral_carac":
                        $("laboral_carac").value=rs.getdata("valor")
                        break;
                        case "ref1_numtel":
                        $("ref1_numTel").value=rs.getdata("valor")
                        break;
                        case "ref2_numtel":
                        $("ref2_numTel").value=rs.getdata("valor")
                        break;
                        case "laboral_numtel":
                        $("laboral_numTel").value=rs.getdata("valor")
                        break;
                        case "ref1_apenom":
                        $("ref1_apenom").value=rs.getdata("valor")
                        break;
                        case "ref2_apenom":
                        $("ref2_apenom").value=rs.getdata("valor")
                        break;
                        case "laboral_lugar_trabajo":
                        $("laboral_lugar_trabajo").value=rs.getdata("valor")
                        break;
                        case "apellido_materno":
                        $("apellido_materno").value=rs.getdata("valor")
                        break;

                    }
                    rs.movenext()
                }


                if(estado_str!="" && operador_estado_str!="" && estado_str !=null && operador_estado_str !=null){
                    var titulo=win.getTitle()
                    win.setTitle(titulo.replace("</b>"," ("+estado_desc_str+" - "+operador_estado_str+" - "+str_fe_estado_sol+")</b>"))
                }
                dataloaded=1
                refloaded=1 //cuando se carga una solicitud pendiente, se cargan datos del credito y de referencia
                cargar_datos_iniciales()
                var strEstados="PDHXMR" 
                if(strEstados.indexOf(estado_cr)==-1){
                habilitarCampos(false)
                $("divGuardar").update("")
                }
                //si esta confirmada, no edita, sino que crea nueva solicitud
                if(estado_str == "C"){
                    nro_solicitud=0
                    modo="N"
                }
        }

        function cargar_datos_desde_cr(rs){
            
            if(!rs.eof()){
                campos_defs.set_value("apellido", rs.getdata("apellido"))                
                campos_defs.set_value("persona", rs.getdata("nombres"))                
                campos_defs.set_value("dni", rs.getdata("nro_docu"))
                campos_defs.set_value("sexo", rs.getdata("sexo"))
                campos_defs.set_value("cuit", rs.getdata("cuit"))
                $('numTel').value=rs.getdata("telefono")
                $('carac').value = +rs.getdata("car_tel")
                campos_defs.set_value("cod_prov_arg",  rs.getdata("cod_prov"))
                campos_defs.set_value("calle", rs.getdata("calle"))
                campos_defs.set_value("numero", rs.getdata("numero"))
                campos_defs.set_value("piso", rs.getdata("piso"))
                campos_defs.set_value("depto", rs.getdata("depto"))                
                campos_defs.set_value("postal", rs.getdata("CP"))
                campos_defs.set_value("id_estado_civil",rs.getdata("estado_civil"))
                campos_defs.set_value("email", rs.getdata("email"))
                campos_defs.set_value("apellido_materno", rs.getdata("apellido_materno"))
                nro_banco_cr=rs.getdata("nro_banco")
                $("ciudad").value=rs.getdata("localidad")
                campos_defs.set_value("fe_naci", rs.getdata("fecha_nacimiento"))
            }//if
            dataloaded=1

            cargar_datos_iniciales()
        }


        function habilitarCampos(habilita) {
            campos_defs.habilitar("cod_prov_arg", habilita)
            campos_defs.habilitar("id_estado_civil", habilita)
            campos_defs.habilitar("calle", habilita)
            campos_defs.habilitar("fe_naci", habilita)
            campos_defs.habilitar("numero", habilita)
            campos_defs.habilitar("ciudad", habilita)     
            campos_defs.habilitar("depto", habilita)            
            campos_defs.habilitar("piso", habilita)            
            campos_defs.habilitar("postal", habilita)
            campos_defs.habilitar("apellido_materno", habilita)
            document.getElementById('carac').disabled = !habilita 
            document.getElementById('numTel').disabled = !habilita
            
            
        }

        function inicializarMaps() {
            // Box general
            var configs = {
                types: ['address'],
                //types: ['(cities)'],
                //types: ['geocode'],
                componentRestrictions: { country: 'ar' }
            };
            
            var input = $('calle');
            input.placeholder = 'Ingrese una direcci�n. Ej: Bv. Oro�o 126, Rosario, Santa Fe';
            input.autocomplete = 'on';

            autocomplete = new google.maps.places.Autocomplete(input, configs);
            autocomplete.setFields(['address_components']);
            autocomplete.addListener('place_changed', setDataMapCallback); // Evento seleccionar

            /*var input_laboral = $('calleLaboral')
            input_laboral.placeholder = 'Ingrese una direcci�n. Ej: Bv. Oro�o 126, Rosario, Santa Fe';
            input_laboral.autocomplete = 'on';*/

           /* autocomplete_lab = new google.maps.places.Autocomplete(input_laboral, configs);
            autocomplete_lab.setFields(['address_components']);
            autocomplete_lab.addListener('place_changed', setDataMapCallbackLaboral); // Evento seleccionar*/



            // Box ciudad
            var config_city = {
                types: ['(cities)'],
                componentRestrictions: { country: 'ar' }
            };

            var input_city = $('ciudad');
            input_city.placeholder = 'Ej: Santa Fe';
            input_city.autocomplete = 'on';

            autocomplete_city = new google.maps.places.Autocomplete(input_city, config_city);
            autocomplete_city.setFields(['address_components']);
            autocomplete_city.addListener('place_changed', setDataCityCallback); // Evento seleccionar (input de ciudad)

            /*var input_city_lab = $('ciudadLaboral');
            input_city_lab.placeholder = 'Ej: Santa Fe';
            input_city_lab.autocomplete = 'on';

            autocomplete_city_lab = new google.maps.places.Autocomplete(input_city_lab, config_city);
            autocomplete_city_lab.setFields(['address_components']);
            autocomplete_city_lab.addListener('place_changed', setDataCityCallbackLaboral); */// Evento seleccionar (input de ciudad)

        }

        function setDataMapCallback() {
            
            var place = autocomplete.getPlace();

            if (place.address_components) {
                var item;
                campos_defs.set_value('postal','');
                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];
                        
                    switch (item.types[0]) {
                        case 'route':
                            if (item.long_name) campos_defs.set_value('calle', item.long_name);
                            break;

                        case 'street_number':
                            if (item.long_name) campos_defs.set_value('numero', item.long_name);
                            break;

                        case 'locality':
                            if (item.long_name) campos_defs.set_value('ciudad', item.long_name);
                            break;

                        case 'postal_code':
                            if (item.long_name) {
                                var expReg = /^\d+$/i;
                                var cod_post = item.long_name
                                if (!expReg.test(cod_post))
                                    cod_post = cod_post.substr(1, cod_post.length)

                                campos_defs.set_value('postal', cod_post);
                            }
                            break;
                            
                        case 'administrative_area_level_1':
                            if (item.long_name) buscarProvincia(item.long_name, "cod_prov_arg")//campos_defs.set_value('cod_prov_arg', item.long_name);
                            break;
                    }
                }
            }
        }

        function setDataCityCallback() {
            // Obtener los datos y setear solo la ciudad (locality)
            var place = autocomplete_city.getPlace();

            if (place.address_components) {
                var item;

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];

                    if (item.types[0] === 'locality') {
                        campos_defs.set_value('ciudad', item.long_name);
                        break;
                    }
                }
            }
        }

        function setDataMapCallbackLaboral() {
            var place = autocomplete_lab.getPlace();

            if (place.address_components) {
                var item;

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];
                        
                    switch (item.types[0]) {
                        case 'route':
                            if (item.long_name) campos_defs.set_value('calleLaboral', item.long_name);
                            break;

                        case 'street_number':
                            if (item.long_name) campos_defs.set_value('numeroLaboral', item.long_name);
                            break;

                        case 'locality':
                            if (item.long_name) campos_defs.set_value('ciudadLaboral', item.long_name);
                            break;

                        case 'postal_code':
                            if (item.long_name) {
                                var expReg = /^\d+$/i;
                                var cod_post = item.long_name
                                if (!expReg.test(cod_post))
                                    cod_post = cod_post.substr(1, cod_post.length)

                                campos_defs.set_value('postalLaboral', cod_post);
                            }
                            break;
                            
                        case 'administrative_area_level_1':
                            if (item.long_name) buscarProvincia(item.long_name, "prov_laboral")//campos_defs.set_value('cod_prov_arg', item.long_name);
                            break;
                    }
                }
            }
        }

        function setDataCityCallbackLaboral() {
            // Obtener los datos y setear solo la ciudad (locality)
            var place = autocomplete_city_lab.getPlace();

            if (place.address_components) {
                var item;

                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];

                    if (item.types[0] === 'locality') {
                        campos_defs.set_value('ciudadLaboral', item.long_name);
                        break;
                    }
                }
            }
        }

        function buscarProvincia(provincia, campo_def) {
            provincia = provincia.replace("�", "a")
            provincia = provincia.replace("�", "e")
            provincia = provincia.replace("�", "i")
            provincia = provincia.replace("�", "o")
            provincia = provincia.replace("�", "u")
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
            if (!rs.eof()) {
                campos_defs.set_value(campo_def, rs.getdata('cod_prov'))
            }
        }
            rs.open(nvFW.pageContents.provincia, "", "<provincia type='like'>" + provincia + "</provincia>")
                        
        }

        var modo = 'N'        
        function guardar(){
            var id_cuenta=0
            var cobro=0
            var id_cuenta=0
            var parametros={}            
            if (nro_solicitud > 0)
               modo = 'E'

            parametros['nro_credito']=nro_credito
            parametros['modo']=modo
            //apellido
            if (campos_defs.get_value('apellido') == '') {
                alert("Complete el apellido del socio")
                return
            }
            parametros['apellido']=campos_defs.get_value('apellido')
            //nombre
            if (campos_defs.get_value('persona') == '') {
                alert("Complete el nombre del socio")
                return
            }
            parametros['persona']=campos_defs.get_value('persona')

           //sexo
            if (campos_defs.get_value('sexo') == '') {
                alert("Seleccione el sexo del socio")
                return
            }
            parametros['sexo']=campos_defs.get_value('sexo')

            //DNI
            if (campos_defs.get_value('dni') == '') {
                alert("Complete el n�mero de documento del socio")
                return
            }
            parametros['dni']=campos_defs.get_value('dni')

            if(campos_defs.get_value("id_estado_civil")==''){
             alert("Complete el estado civil del socio")
                return   
            }
            parametros['id_estado_civil']=campos_defs.get_value('id_estado_civil')
           
             caracteristica = $('carac').value
             telefono = $('numTel').value
             //si alguno de los dos campos NO esta vacio, es porq se quiere ingresar telefono
             if(caracteristica!="" || telefono !=""){
                //que si es asi, valido
                if(!validarTelefono()){
                    alert("Verifique el celular. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el n�mero.")
                    document.getElementById("carac").focus()
                return
                }

             }
             parametros['caracteristica']=caracteristica
             parametros['telefono']=telefono

             //email
            if(campos_defs.get_value("email")==''){
             alert("Complete el email del socio")
                return   
            }

            if(!valFormatoEmail(campos_defs.get_value('email'))){
                alert("El email ingresado no es valido. Verifique por favor")                
                return
            }
            parametros['email']=campos_defs.get_value('email')

            //apellido materno
            if(campos_defs.get_value("apellido_materno")=='' && nro_banco_cr=='800'){ //valida solo para voii
             alert("Complete el apellido materno del socio")
                return   
            }
            parametros['apellido_materno']=campos_defs.get_value('apellido_materno')

            //calle
               if(campos_defs.get_value("calle")==''){
             alert("Complete la calle del socio")
                return   
            }
            parametros['calle']=campos_defs.get_value('calle')
            //numero calle
            if(campos_defs.get_value("numero")==''){
             alert("Complete el numero de la calle del socio por favor")
                return   
            }
            parametros['numero']=campos_defs.get_value('numero')
            //postal
            if(campos_defs.get_value("postal")==''){
             alert("Complete el codigo postal del socio por favor")
                return   
            }
            parametros['postal']=campos_defs.get_value('postal')
            //provincia
            if (campos_defs.get_value('cod_prov_arg') == '') {
                alert("Seleccione la provincia del socio por favor")                
                return
            }
             parametros['cod_prov']=campos_defs.get_value('cod_prov_arg')

            var ref1_carac=$F("ref1_carac")
            var ref1_numTel=$F("ref1_numTel")
            var ref1_apenom=$F("ref1_apenom")
            if(ref1_carac!="" || ref1_numTel!=""){
                if(!valida_telefono(ref1_carac,ref1_numTel)){
                     alert("Verifique el telefono de la referencia 1. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el n�mero.")
                    //$("ref1_carac").focus()
                     document.getElementById("ref1_carac").focus()
                    return
                }
            }
            parametros['ref1_carac']=ref1_carac
            parametros['ref1_numTel']=ref1_numTel
            parametros['ref1_apenom']=ref1_apenom

            var ref2_carac=$F("ref2_carac")
            var ref2_numTel=$F("ref2_numTel")
            var ref2_apenom=$F("ref2_apenom")
            if(ref2_carac!="" || ref2_numTel!=""){
                if(!valida_telefono(ref2_carac,ref2_numTel)){
                    alert("Verifique el telefono de la referencia 2. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el n�mero.")
                    document.getElementById("ref2_carac").focus()
                    return
                }
            }
            parametros['ref2_carac']=ref2_carac
            parametros['ref2_numTel']=ref2_numTel
            parametros['ref2_apenom']=ref2_apenom

            var laboral_carac=$F("laboral_carac")
            var laboral_numTel=$F("laboral_numTel")
            var laboral_lugar_trabajo=$F("laboral_lugar_trabajo")
            if(laboral_carac!="" || laboral_numTel!=""){
                if(!valida_telefono(laboral_carac,laboral_numTel)){
                    alert("Verifique el telefono laboral. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el n�mero.")
                    //$("laboral_carac").focus()
                    document.getElementById("laboral_carac").focus()
                    return
                }
            }

            parametros['laboral_carac']=laboral_carac
            parametros['laboral_numTel']=laboral_numTel
            parametros['laboral_lugar_trabajo']=laboral_lugar_trabajo

            var ciudad=campos_defs.get_value("ciudad")
            if(ciudad==""){
                alert("La localidad no debe ser vacia. Verifique")
                document.getElementById("ciudad").focus()
                return
            }
            parametros['ciudad']=ciudad


            $$("input[name='cuenta']").each(function(e){ if(e.checked){
                id_cuenta = $(e).readAttribute("id_cuenta")
                }
            })
            if(!id_cuenta>0){
             alert("No ha seleccionado una cuenta bancaria")
                return   
            }
            parametros['id_cuenta']=id_cuenta

            var cobro= +campos_defs.get_value('cobro')
            if(!cobro>0){
             alert("No ha seleccionado tipo de cobro")
                return   
            }

            if(cobro==27){ //cobro sin definicion
             alert("No se permite seleccionar cobro sin definicion")
                return   
            }
            parametros['cobro']=cobro
            parametros['cuentavalida']=0;


            
            
             nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga','validando cuenta...'); 
             var valida=false;
             var oXML = new tXML();
             oXML.async = true
             var validacion_cuenta_retorno=""
             oXML.onComplete = function ()
                           {
                            
                            strXML = XMLtoString(oXML.xml)
                            objXML = new tXML();
                            objXML.async = false
                            if (objXML.loadXML(strXML)){
                                 var oNode = objXML.selectSingleNode("error_mensajes/error_mensaje")
                                var numError= +oNode.getAttribute("numError")
                                var titulo=''
                                var mensaje=''
                                if(numError==0){
                                validacion_cuenta_retorno =XMLText(selectSingleNode('params/cuentavalida', oNode))
                                valida=(validacion_cuenta_retorno=='1')?1:0
                                }else{
                                titulo=XMLText(selectSingleNode('titulo', oNode))
                                mensaje=XMLText(selectSingleNode('mensaje', oNode))
                                console.log("numError "+ numError.toString()+" titulo :"+titulo+" - mensaje ="+mensaje)
                                    if(numError==-1){
                                        mensaje="En estos momentos no podemos realizar la consulta. Por favor intente en unos minutos"
                                    }
                                    if(numError==13){
                                        mensaje="no se pudo verificar la cuenta. Intente nuevamente y si el problema persiste, consulte con sistemas (tokenfwt)"
                                    }
                                }
                            }
                            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') 
                               
                            if (!valida){
                                alert(mensaje);                  
                                return
                            }
                            parametros['cuentavalida']=valida
                            parametros['validacion_cuenta_retorno']=validacion_cuenta_retorno
                            confirmar_guardado(parametros)
                          
                       }//oncomplete
            oXML.onFailure = function () {
            rserror_handler("Error al consultar. Intente nuevamente.")
            }
            oXML.load('/precarga/confirmar_datos_personales.aspx?accion=validacbu&criterio=<criterio><id_cuenta>' + id_cuenta + '</id_cuenta><nro_credito>' + nro_credito + '</nro_credito></criterio>')
           

        }//guardar


         /***   Valida el formato de Email  ***/
        function valFormatoEmail(email) {
            if (email != '') {
                var okemail = /^\w+([\.-]?\w+)*(\-)*@\w+([\.-]?\w+)*(\.\w{2,4})+$/.test(email);
                if (!okemail)
                    return false
                else
                    return true
            }
        }

        var paramsave={}
        function confirmar_guardado(parametros){            
            paramsave["solicitud"]=0
            paramsave["mensaje_solicitud"]=""
            paramsave["cuenta"]=0
            paramsave["mensaje_cuenta"]=""
            var id_cuenta= parametros['id_cuenta']
            var cobro= parametros['cobro']
            var modo= parametros['modo']
            var ciudad= parametros['ciudad']
            var caracteristica= parametros['caracteristica']
            var telefono= parametros['telefono']
            var ref1_carac=parametros['ref1_carac'] 
            var ref1_numTel=parametros['ref1_numTel']
            var ref1_apenom=parametros['ref1_apenom']
            var ref2_carac=parametros['ref2_carac'] 
            var ref2_numTel=parametros['ref2_numTel'] 
            var ref2_apenom=parametros['ref2_apenom'] 
            var laboral_carac=parametros['laboral_carac']   
            var laboral_numTel=parametros['laboral_numTel']
            var laboral_lugar_trabajo=parametros['laboral_lugar_trabajo']
             Dialog.confirm("confirma que los datos son correctos?",
                                       {
                                           width: 300,
                                           className: "alphacube",
                                           okLabel: "Si",
                                           cancelLabel: "No",
                                           onOk: function (w) {
                                               
                                                var xml = "<?xml version='1.0' encoding='iso-8859-1'?><solicitud  nombres='" + campos_defs.get_value("persona") + "' apellido='" + campos_defs.get_value("apellido") + "' tipo_docu='3' sexo='" + campos_defs.get_value("sexo") + "' fe_naci='" + campos_defs.get_value("fe_naci") + "'"
                                                xml += " nro_docu='" + campos_defs.get_value("dni") + "' estado_civil='" + campos_defs.get_value("id_estado_civil")+"' "
                                                xml += " calle='" + campos_defs.get_value("calle") + "' numero='" + campos_defs.get_value("numero") + "' piso='" + campos_defs.get_value("piso") + "' depto='" + campos_defs.get_value("depto") + "' localidad='" + campos_defs.get_value("ciudad") + "' postal_real='" + campos_defs.get_value("postal") + "'"
                                                xml += " cod_prov='" + campos_defs.get_value("cod_prov_arg") + "' provincia='" + campos_defs.get_desc("cod_prov_arg").split("(")[0] + "'"
                                                xml += " tipo_telefono='celular' car_tel='" + $('carac').value + "' telefono='" + telefono + "'  token_celular='"+token+"' nro_nacion='1' cuil='" + campos_defs.get_value("cuit") + "' email='" + campos_defs.get_value("email") + "' resto='' ref1_carac='"+ref1_carac+"' ref1_numtel='"+ref1_numTel+"' ref1_apenom='"+ref1_apenom+"' ref2_carac='"+ref2_carac+"' ref2_numtel='"+ref2_numTel+"' ref2_apenom='"+ref2_apenom+"' laboral_carac='"+laboral_carac+"' laboral_numtel='"+laboral_numTel+"' laboral_lugar_trabajo='"+laboral_lugar_trabajo+"' apellido_materno='"+ campos_defs.get_value("apellido_materno") +"' ></solicitud > "

                                                    nvFW.error_ajax_request('solicitud_cargar.aspx', {
                                                        parameters: { modo: modo, strXML: xml, nro_solicitud: nro_solicitud,nro_credito:nro_credito},
                                                            bloq_msg: 'Guardando solicitud...',
                                                        onSuccess: function (err, transport) {
                                                            
                                                                if (err.numError == 0) {                                                                    
                                                                    paramsave["solicitud"]=1                                                                    
                                                                    var callbackchangecbu=function(){
                                                                        changecobro(cobro,nro_credito)  
                                                                    }
                                                                    changecbu(id_cuenta,nro_credito,callbackchangecbu)      
                                                                    
                                                                    
                                                                }
                                                                else{
                                                                 nvFW.alert('Error al guardar la solicitud.')
                                                                 paramsave["solicitud"]=0                                                                    
                                                                 paramsave["mensaje_solicitud"]=err.mensaje   
                                                                }
                                                                    
                                                                    },
                                                                    error_alert:false
                                                                });     




                                               w.close();
                                               return
                                           },

                                           onCancel: function (w) {
                                               w.close();
                                           }
                                       });//dialog
        }


        function verificar_cambios(){
            
            var modificaciones=0
            if(datos_iniciales.get("apellido")!=$F("apellido")){
                modificaciones++
            }
            if(datos_iniciales.get("nombres")!=$F("persona")){
             modificaciones++   
            }
            if(datos_iniciales.get("fe_naci")!=$F("fe_naci"))
            {
                modificaciones++   
            }
            if(datos_iniciales.get("sexo")!=$F("sexo")){
             modificaciones++      
            }
            if(datos_iniciales.get("id_estado_civil")!=$F("id_estado_civil")){
             modificaciones++         
            }
            if(datos_iniciales.get("calle")!=$F("calle")){
             modificaciones++            
            }
            if(datos_iniciales.get("numero")!=$F("numero")){
             modificaciones++               
            }
            if(datos_iniciales.get("piso")!=$F("piso")){
             modificaciones++                  
            }
            if(datos_iniciales.get("depto")!=$F("depto")){
             modificaciones++                     
            }
            if(datos_iniciales.get("ciudad")!=$F("ciudad")){
             modificaciones++                        
            }
            if(datos_iniciales.get("postal_real")!=$F("postal")){
                modificaciones++
            }
            if(datos_iniciales.get("cod_prov")!=$F("cod_prov_arg")){
                modificaciones++
            }

            if(datos_iniciales.get("numTel")!=$F("numTel")){
                modificaciones++
            }

            if(datos_iniciales.get("ref1_carac")!=$F("ref1_carac")){
                modificaciones++
            }
            if(datos_iniciales.get("ref1_numtel")!=$F("ref1_numTel")){
                modificaciones++
            }
            if(datos_iniciales.get("ref1_apenom")!=$F("ref1_apenom")){
                modificaciones++
            }
            if(datos_iniciales.get("ref2_carac")!=$F("ref2_carac")){
                modificaciones++
            }
            if(datos_iniciales.get("ref2_numtel")!=$F("ref2_numTel")){
                modificaciones++
            }
            if(datos_iniciales.get("ref2_apenom")!=$F("ref2_apenom")){
                modificaciones++
            }
            if(datos_iniciales.get("laboral_carac")!=$F("laboral_carac")){
                modificaciones++
            }
            if(datos_iniciales.get("laboral_numtel")!=$F("laboral_numTel")){
                modificaciones++
            }
            if(datos_iniciales.get("laboral_lugar_trabajo")!=$F("laboral_lugar_trabajo")){
                modificaciones++
            }
            return modificaciones>0

        }
                
      

        var caracteristica = 0
        var telefono = 0
        function validarTelefono() {
            caracteristica = $('carac').value
            telefono = $('numTel').value            
            var ex=valida_telefono(caracteristica,telefono)
                if(!ex){
                    $('carac').focus()
                }
           return ex
        }

        function valida_telefono(caracteristica,telefono){
            
           if (caracteristica.charAt(0) == 0){               
               return false
           }
           if (telefono.charAt(0) == 1 && telefono.charAt(1) == 5) {
               return false
            }

            if ((caracteristica + telefono).length == 10) {
                numeroTelValidado = caracteristica + telefono
                return true
            } 
            return false

       }

       
        function window_onresize() {
            try {
               
                //var dif = Prototype.Browser.IE ? 5 : 2
                //body_height = $$('body')[0].getHeight()
                //$('containerDiv').setStyle({ height: body_height - dif - 2 + 'px' })
                //tamanio = nvtWinDefault()
                var tds=$$('#idDatos3  td')
                if (ismobile) {
                    $('idDatos1').style.width = '100%'
                    $('idDatos2').style.width = '100%'
                    $('idDatos3').style.width = '100%'
                    $('idDatos4').style.width = '100%'
                    $('idDatos5').style.width = '100%'
                    $('idDatos6').style.width = '100%'
                    $('idDatos7').style.width = '100%'  
                     $('idDatos8').style.width = '100%'                    
                     $('idDatos9').style.width = '100%'                    
                    $('idDomicilio1').style.width = '100%'
                    $('idDomicilio2').style.width = '100%'
                    $('idDomicilio3').style.width = '100%'
                    $('idDomicilio4').style.width = '100%'                    
                    $('idref1').style.width = '100%'
                    $('idref1_apenom').style.width='100%'
                    $('idref2').style.width = '100%'
                    $('idref2_apenom').style.width='100%'
                    $('idreflaboral').style.width = '100%'                    
                    $('idlaboral_lugar_trabajo').style.width='100%'

                    $('numTel').style.width  = '50%'
                    
                    
                    $$('#idDatos3  td[class=Tit1]')[0].update("Fec. Nac.")
                    $$('#idDatos6 td[class=Tit1]')[0].update("Est. Civ.")
                }
                else {
                    $('idDatos1').style.width = '50%'
                    $('idDatos2').style.width = '50%'
                    $('idDatos3').style.width = '50%'
                    $('idDatos4').style.width = '50%'
                    $('idDatos5').style.width = '50%'
                    $('idDatos6').style.width = '50%'                      
                    $('idDatos7').style.width = '50%' 
                    $('idDatos8').style.width = '50%' 
                    $('idDatos9').style.width = '50%' 
                    $('idDomicilio1').style.width = '50%'
                    $('idDomicilio2').style.width = '50%'
                    $('idDomicilio3').style.width = '50%'
                    $('idDomicilio4').style.width = '50%'
                    $('idref1').style.width = '50%'
                    $('idref1_apenom').style.width='50%'
                    $('idref2').style.width = '50%'
                    $('idref2_apenom').style.width='50%'
                    $('idreflaboral').style.width = '50%'   
                    $('idlaboral_lugar_trabajo').style.width='50%'
                    
                    $$('#idDatos3  td[class=Tit1]')[0].update("Fecha Nacimiento")

                    
                }
                
                var htotal=$(document.body).getHeight()
                $("containerDiv").setStyle({height:$(document.body).getHeight()})
                var h1 = +$("tbResultado").getHeight();
                var h2 = +$("tbDomicilio").getHeight();
                var h3 = +$("tbContactos").getHeight();
                var h4 = +$("tbCuentasCBU").getHeight();                
                var tcH = +$("tbtipo_cobro").getHeight();
                var divCH = +$("containerDivCobro").getHeight();
                var f1h = +$("tbfooter1").getHeight();
                var f2h = +$("tbfooter2").getHeight();  
                var divlistadoH=htotal-h1-h2-h3-h4-tcH-divCH-f1h-f2h-30;
                //console.log(divlistadoH)
               $("divlistado").setStyle({height:divlistadoH})

              
            }
            catch (e) { }
        }

        function onchange_tipoCel() {
            if ($('select').value == 'celular') {
                $('numTel').placeholder = '15'
                $('carac').placeholder = ''
            }
            else {
                $('numTel').placeholder = ''
                $('carac').placeholder = ''
            }
        }
            
        function onchange_tel(event){
            
            var id_ele=event.target.id
            if (id_ele=="carac" && id_ele=="numTel"){
                if($(id_ele).value=="")return

                if (!validarTelefono()) {
                alert("Verifique el celular. No debe colocar el 0 ni el 15.")
                }            
                token = 0
            }            
        }


        function cancelar(){            
            nvFW.getMyWindow().close()
        }


        var refloaded=0
        function cargar_referencias(){
            
            var rs = new tRS();
            rs.async = true
            rs.onComplete = function (rs) {
                while (!rs.eof()) {
                    
                    var car_tel=rs.getdata('car_tel')
                    var telefono = rs.getdata('telefono')
                    var observacion = rs.getdata('observacion')
                    var nro_contacto_tipo= rs.getdata('nro_contacto_tipo') 
                    switch (nro_contacto_tipo){
                        case "2": //contacto laboral
                        $("laboral_carac").value=car_tel
                        $("laboral_numTel").value=telefono
                        $("laboral_lugar_trabajo").value=observacion
                        break;
                        case "9": //referencia 1
                        $("ref1_carac").value=car_tel
                        $("ref1_numTel").value=telefono
                        $("ref1_apenom").value=observacion
                        break;
                        case "10": //referencia 2
                        $("ref2_carac").value=car_tel
                        $("ref2_numTel").value=telefono
                        $("ref2_apenom").value=observacion
                        break;
                    }
                    rs.movenext()
                }
                refloaded=1
                cargar_datos_iniciales()
            }
             rs.open(nvFW.pageContents.referencias,"","<nro_entidad type='igual'>" + $F('nro_entidad') + "</nro_entidad>" )


    }



   


        function cargar_cuentas_persona() {
            nvFW.bloqueo_activar($(document.body), 'Cargando cuentas');
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
                $("tblistado").update("")
                var html=""
                while(!rs.eof()){
                    html+="<tr><td><input type='radio' id='cuenta_"+rs.getdata("id_cuenta")+"'  name='cuenta' id_cuenta='"+rs.getdata("id_cuenta")+"' /> </td><td>"+rs.getdata("banco")+"</td><td>"+((rs.getdata("CBU"))?rs.getdata("CBU"):"")+"</td></tr>"
                    rs.movenext()
                }//while
                if(html!=""){
                     $("tblistado").update(html)
                     selcuenta($F("id_cuenta_selected"))
                }
             nvFW.bloqueo_desactivar($(document.body), 'Cargando cuentas');  
             window_onresize()  
            }
            rs.open(nvFW.pageContents.cuentas, '', "<nro_entidad type='igual'>" + $F("nro_entidad") + "</nro_entidad>")
            
            
        }

        function changecbu(id_cuenta,nro_credito,fxcallback){
            nvFW.error_ajax_request('Cuenta_seleccion.aspx', {parameters: { modo: 'C', id_cuenta: id_cuenta, nro_credito: nro_credito},
             bloq_msg: 'cargando cuenta...',
             onSuccess: function (err, transport) {                                  
                                        if (err.numError == 0) {                     
                                            console.log("credito actualizado con cuenta "+id_cuenta.toString())
                                            $("id_cuenta_selected").value=id_cuenta
                                            selcuenta($F("id_cuenta_selected"))
                                            paramsave["cuenta"]=1;
                                            fxcallback()
                                            win.options.userData["res"]=true;
                                            win.options.userData["data"]=paramsave
                                            win.options.userData["estado"]=$F("estado")
                                            win.close();

                                        }
                                        else
                                        {
                                        nvFW.alert(err.mensaje)
                                        paramsave["cuenta"]=0;
                                        paramsave["mensaje_cuenta"]=err.mensaje;
                                        }                         
                                    }
                                });
          }


          function changecobro(cobro,nro_credito)  {
            if(cobro=="" || nro_credito=="") return;
            nvFW.error_ajax_request('confirmar_datos_personales.aspx', {parameters: { accion: 'updatecobro', cobro: cobro, nro_credito: nro_credito},
             bloq_msg: 'actualizando cobro...',
             onSuccess: function (err, transport) {                                  
                                        if (err.numError != 0) {                     
                                           nvFW.alert(err.mensaje)  
                                        }else{
                                            console.log("actualizando cuenta")                                            
                                        }
                                                               
                                    }
                                });
          }

          function selcuenta(id_cuenta){
            
            $("id_cuenta_selected").value=id_cuenta
             $$("input[name='cuenta']").each(function(e){
                
                var idcuenta=$(e).readAttribute('id_cuenta');
                if(idcuenta==id_cuenta){
                    $(e).checked=true
                }
             })
        }


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; background-color: white; -webkit-text-size-adjust: none; overflow: auto;">
    <input type="hidden" id="nro_entidad" name="nro_entidad" value="<%=nro_entidad%>" />
    <input type="hidden" value="<%=id_cuenta%>" id="id_cuenta_selected" />
    <input type="hidden" value="<%=estado%>" id="estado" />
    <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDiv">
        <table class="tb1" id="tbResultado" style="width: 100%; white-space: nowrap;">
            <tr>
                <td class="Tit3" style="text-align: center;"><b>Datos personales</b></td>
            </tr>
            <tr>
                <td>
                    <table id="idDatos1" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="width: 120px" class="Tit1">Apellido</td>
                            <td id="tdapellido"><%= nvFW.nvCampo_def.get_html_input("apellido", nro_campo_tipo:=104, enDB:=False) %></td>
                        </tr>
                    </table>
                    <table id="idDatos2" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="width: 120px" class="Tit1">Nombre</td>
                            <td id="tdnombre"><%= nvFW.nvCampo_def.get_html_input("persona", nro_campo_tipo:=104, enDB:=False) %></td>
                        </tr>
                    </table>
                    <table id="idDatos3" class="tb1" style="width: 50%; float: left">
                        <tr>
                         <td style="white-space: nowrap" class="Tit1" >Fecha nacimiento</td>
                         <td id="tdfenaci" ><%= nvFW.nvCampo_def.get_html_input("fe_naci", nro_campo_tipo:=103, enDB:=False) %></td>                         
                        </tr>
                    </table>
                    <table id="idDatos4" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">DNI</td>
                            <td id="tddni" style="width: 32%" ><%= nvFW.nvCampo_def.get_html_input("dni", nro_campo_tipo:=100, enDB:=False) %></td>
                            <td style="white-space: nowrap" class="Tit1"> Cuit</td>
                            <td id="tdcuit" ><%= nvFW.nvCampo_def.get_html_input("cuit", nro_campo_tipo:=100, enDB:=False) %></td>
                        </tr>
                    </table>
                    <table id="idDatos5" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">Sexo</td>
                            <td id="tdsexo" ><%= nvFW.nvCampo_def.get_html_input("sexo", nro_campo_tipo:=1, enDB:=True) %></td>
                           
                        </tr>
                    </table>
                     <table id="idDatos6" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="white-space: nowrap" class="Tit1">Estado civil</td>
                            <td id="tdcivil"><%= nvFW.nvCampo_def.get_html_input("id_estado_civil", enDB:=True) %></td>
                        </tr>
                    </table>
                    <table id="idDatos7" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap"> Celular</td>
                          
                            <td id="tdnumtel" style="width: 100%; white-space: nowrap">
                                0<input type="text" id="carac" placeholder="cod. area" style="width: 30%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)"  maxlength="5" autocomplete="off" /> -
                               15<input type="text" id="numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="numero" /></td>
                             
                        </tr>
                    </table>
                    <table id="idDatos8" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="white-space: nowrap" class="Tit1"> Email</td>
                            <td id="tdcuit" style="width: 70%;"><%= nvFW.nvCampo_def.get_html_input("email", nro_campo_tipo:=104, enDB:=False) %></td>
                        </tr>
                    </table>

                    <table id="idDatos9" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td style="white-space: nowrap" class="Tit1"> Apellido materno</td>
                            <td id="tdcuit" style="width: 70%;"><%= nvFW.nvCampo_def.get_html_input("apellido_materno", nro_campo_tipo:=104, enDB:=False) %></td>
                        </tr>
                    </table>
                   
                    
                    </td>
            </tr>           
        </table>
        <table class="tb1" id="tbDomicilio" style="width: 100%; white-space: nowrap;">

            <tr>
                <td>
                    <table id="idDomicilio1" class="tb1" style="width: 50%; float: left">                      
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">Calle</td>
                            <td id="tdDomicilio" style=""><% = nvFW.nvCampo_def.get_html_input("calle", enDB:=False, nro_campo_tipo:=104) %></td> 
                        </tr>
                    </table>
                    <table id="idDomicilio2" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">Nro</td>
                            <td style="width: 67px;"><% = nvFW.nvCampo_def.get_html_input("numero", enDB:=False, nro_campo_tipo:=100) %></td>
                            <td class="Tit1" style="white-space: nowrap">Piso</td>
                            <td style="width: 46px;"><% = nvFW.nvCampo_def.get_html_input("piso", enDB:=False, nro_campo_tipo:=100) %></td>
                            <td class="Tit1" style="white-space: nowrap">Depto </td>
                            <td><%= nvFW.nvCampo_def.get_html_input("depto", enDB:=False, nro_campo_tipo:=104) %></td>
                        </tr>
                    </table>
                    <table id="idDomicilio3" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">Localidad</td>
                            <td id="tdLocalidad" style=""><%= nvFW.nvCampo_def.get_html_input("ciudad", enDB:=False, nro_campo_tipo:=104)%></td>
                            <td class="Tit1">C.P.</td>
                            <td style="width: 60px"><%= nvFW.nvCampo_def.get_html_input("postal", nro_campo_tipo:=100, enDB:=False) %></td>
                        </tr>
                    </table>                   
                    <table id="idDomicilio4" class="tb1" style="width: 50%; float: left">
                        <tr>
                            <td class="Tit1" style="white-space: nowrap">Provincia</td>
                            <td id="tdprovincia" style=""></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <table class="tb1" id="tbContactos" style="width: 100%; white-space: nowrap;">
            <tr>
                <td class="Tit3" style="text-align: center;"><b>Contactos Telef�nicos</b></td>
            </tr>            
            <tr>
                <td>
                    <table id="idref1" class="tb1" style="width: 50%; float: left">                      
                        <tr>
                            <td class="Tit1" style="white-space: nowrap;width: 10%">Referencia 1</td>
                            <td id="tdTelefonoref1" style="width: 40%"><input type="text" id="ref1_carac"  style="width: 30%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)"  maxlength="5" autocomplete="off" placeholder="cod. area" /> -
                               <input type="text" id="ref1_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telef�nico"  />
                           </td>                           
                        </tr>
                    </table>
                     <table id="idref1_apenom" class="tb1" style="width: 50%; float: left">                      
                        <tr>                           
                           <td id="tdApenomref1" style="width: 100%">
                               <input type="text" id="ref1_apenom" style="width: 100%; text-align: left" autocomplete="off" placeholder="apellido y  nombres"  />
                           </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <table id="idref2" class="tb1" style="width: 50%; float: left">                      
                        <tr>
                            <td class="Tit1" style="white-space: nowrap;width: 10%">Referencia 2</td>
                            <td id="tdTelefonoref2" style="width: 40%"> <input type="text" id="ref2_carac" placeholder="cod. area" style="width: 30%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)"  maxlength="5" autocomplete="off" /> -
                               <input type="text" id="ref2_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telef�nico"/>
                           </td>                         
                        </tr>
                    </table>
                     <table id="idref2_apenom" class="tb1" style="width: 50%; float: left">                      
                        <tr>                           
                           <td id="tdApenomref2" style="width: 100%">
                               <input type="text" id="ref2_apenom" style="width: 100%; text-align: left" autocomplete="off" placeholder="apellido y  nombres"  />
                           </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                     <table id="idreflaboral" class="tb1" style="width: 50%; float: left">                      
                        <tr>
                            <td class="Tit1" style="white-space: nowrap;width: 10%">Laboral</td>
                            <td id="tdTelefonoreflaboral" style="width: 40%"><input type="text" id="laboral_carac" placeholder="cod. area" style="width: 30%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)"  maxlength="5" autocomplete="off" /> -
                               <input type="text" id="laboral_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telef�nico" />
                           </td>                           
                        </tr>                        
                    </table>
                     <table id="idlaboral_lugar_trabajo" class="tb1" style="width: 50%; float: left">                      
                        <tr>                           
                           <td id="tdApenomref2" style="width: 100%">
                               <input type="text" id="laboral_lugar_trabajo" style="width: 100%; text-align: left" autocomplete="off" placeholder="Lugar de trabajo"  />
                           </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>

        <!--seleccion de cuenta bancaria -->
        <table class="tb1" id="tbCuentasCBU" style="width: 100%; white-space: nowrap;">
             <tr>
                    <td class="Tit3" style="text-align: center;"><b>Cuentas bancarias</b></td>
                    <td style="width: 120px" title="Agregar cuenta bancaria" >
                        <div style="width: 120px" id="divAgregar" />
                    </td>
             </tr>           
        </table>
        <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDivListado">           
            <table class="tb1 highlightEven highlightTROver" id="tbcab" style="width: 100%;">
                <head><tr><th style="width:7%"></th><th style="width:47%;text-align:left">banco</th><th style="width:auto;text-align:left">cbu</th></tr></head>
            </table>
            <div id="divlistado" style="width: 100%; overflow-y: auto">
            <table class="tb1 highlightEven highlightTROver" style="width: 100%;text-align: left" >             
                <tbody id="tblistado">                
                </tbody>
            </table>    
            </div>
        </div>
        <!--seleccion de tipo de cobro -->
        <table class="tb1" id="tbtipo_cobro" style="width: 100%; white-space: nowrap;">
             <tr>
                    <td class="Tit3" style="text-align: center;" ><b>Seleccione tipo de cobro</b></td>
                    
             </tr>           
        </table>
        <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDivCobro">                       
            <div style="width: 100%; overflow-y: auto">
            <table class="tb1 highlightEven highlightTROver" style="width: 100%;text-align: left" >             
                <tbody > 
                    <tr>
                    <td class="Tit1" style="white-space: nowrap;width: 15%">Cobro</td>               
                    <td>
                    <script type="text/javascript">
                         campos_defs.add('cobro', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.filtro_cobro_grupo })
                         campos_defs.set_value('cobro',2) //deposito por defecto
                    </script>
                    </td>
                    </tr>
                </tbody>
            </table>    
            </div>
        </div>

        <table class="tb1" id="tbfooter1" style="width: 100%; white-space: nowrap;">            
            <tr>
                <td style="font-size: smaller">*Campos obligatorios</td>
            </tr>
        </table>

        <table class="tb1" id="tbfooter2">
            <tr>
            <td style="text-align: center">
                <div style="width: 120px; margin: auto" id="divCancelar" />
            </td>
            <td style="text-align: center">                
                <div style="width: 120px; margin: auto" id="divGuardar" />
            </td>
            </tr>
        </table>
    </div>
</body>
</html>
