<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%
    
    Dim nro_entidad As String=""

    Dim dni As String = nvFW.nvUtiles.obtenerValor("dni", "")
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
    Dim cod_prov As String = nvFW.nvUtiles.obtenerValor("cod_prov", "")
    Dim apellido As String = nvFW.nvUtiles.obtenerValor("apellido", "")
    Dim nombre As String = nvFW.nvUtiles.obtenerValor("nombre", "")
    Dim fecha_nac As String = nvFW.nvUtiles.obtenerValor("fecha_nac", "")
    Dim sexo As String = nvFW.nvUtiles.obtenerValor("sexo", "")
    Dim localidad As String = nvFW.nvUtiles.obtenerValor("localidad", "")
    Dim carac As String = nvFW.nvUtiles.obtenerValor("carac", "")

    'Dim localidad As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim telefono As String = nvFW.nvUtiles.obtenerValor("telefono", "")

    Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", 0)

    Dim rsc=nvFW.nvDBUtiles.DBExecute("select * from vercreditos where nro_credito=" & CStr(nro_credito))
    nro_entidad=rsc.Fields("nro_entidad").Value

    Dim id_calificacion = nvFW.nvUtiles.obtenerValor("id_solicitud", 0)


    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim estado_credito = nvFW.nvUtiles.obtenerValor("estado", "Pendiente")
    ''alta de solicitud
    If modo = "N" Then

        Dim err = New tError
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_alta_solicitud_precarga", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@XMLsolicitud", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            cmd.addParameter("@accion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 4, "N")
            cmd.addParameter("@nro_solicitud", ADODB.DataTypeEnum.adDecimal, ADODB.ParameterDirectionEnum.adParamInput, , 0)
            cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adDecimal, ADODB.ParameterDirectionEnum.adParamInput, , nro_credito)
            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim numError As Integer = rs.Fields("numError").Value
            Dim mensaje As String = rs.Fields("mensaje").Value

            err.numError = numError
            err.params("nro_solicitud") = rs.Fields("nro_solicitud").Value

            err.titulo = ""
            err.mensaje = mensaje
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If
    ''edicion de solicitud
    If modo = "E" Then
        Dim err = New tError
        Try
            Dim nro_solicitud = nvFW.nvUtiles.obtenerValor("nro_solicitud", 0)
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_alta_solicitud_precarga", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@XMLsolicitud", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            cmd.addParameter("@accion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, modo.Length, modo)
            cmd.addParameter("@nro_solicitud", ADODB.DataTypeEnum.adDecimal, ADODB.ParameterDirectionEnum.adParamInput, , nro_solicitud)
            cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adDecimal, ADODB.ParameterDirectionEnum.adParamInput, , nro_credito)

            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim numError As Integer = rs.Fields("numError").Value
            Dim mensaje As String = rs.Fields("mensaje").Value

            err.numError = numError
            err.params("nro_solicitud") = rs.Fields("nro_solicitud").Value

            err.titulo = ""
            err.mensaje = mensaje
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If



    Me.contents.Add("provincia", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='provincia'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>"))
    'Me.contents.Add("banco", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='banco'><campos>banco</campos><filtro></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("solicitud", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_solicitud_parametros'><campos>*,convert(varchar,fe_estado,103) as str_fe_estado</campos><filtro></filtro><orden>fecha desc</orden></select></criterio>"))
    Me.contents.Add("creditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>*,convert(varchar,fe_naci,103) as fecha_nacimiento</campos><filtro></filtro><orden></orden></select></criterio>"))

     Me.contents.Add("referencias", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_Telefono'><campos>*</campos><filtro><nro_contacto_tipo type='in'>2,9,10</nro_contacto_tipo><vigente type='igual'>1</vigente></filtro><orden></orden></select></criterio>"))


    Dim GOOGLE_MAPS_API_KEY_BROWSER As String = "AIzaSyAvpe0ahD3qvGRpQLgc2cvUYLro_jS4-Q8"
                                                 


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="X-UA-Compatible" content="IE=edge">
     <meta name="viewport" content="initial-scale=1 " lang="es" >
     <meta name="viewport" content="width=device-width, user-scalable=no" lang="es" >
    
    <title>solicitud de datos personales</title>
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
        var dataloaded=0
        var refloaded=0
        var datos_iniciales = $H({apellido: '', nombres: '', fe_naci: '',sexo:'',id_estado_civil:'',calle:'',numero:'',piso:'',depto:'',ciudad:'',postal_real:'',cod_prov:'',numTel:'',ref1_carac:'',ref1_numtel:'',ref1_apenom:'',ref2_carac:'',ref2_numtel:'',ref2_apenom:'',laboral_carac:'',laboral_numtel:'',laboral_lugar_trabajo:'',apellido_materno:''});
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var ismobile
        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "guardar solicitud";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardar()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "cancelar";
        vButtonItems[1]["onclick"] = "return cancelar()";
       

        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        vListButtons.loadImage("guardar", "/FW/image/icons/guardar.png");
        vListButtons.loadImage("cancelar", "/FW/image/icons/cancelar.png");
        vListButtons.loadImage("verificar", "/FW/image/icons/confirmar.png");

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

            window_onresize()

            var input = $('fe_naci');
            input.placeholder = 'dd/mm/yyyy';
            
            
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
              //si esta en estado pendiente y el usuario quiere verificar , realiza la pregunta. Sino, lo ignora y continua cargando             
             if (estado_str == "P" && verificarpendiente==1) {
                 Dialog.confirm("Este crédito ya posee una solicitud pendiente de aprobación ¿Desea continuar y editar la misma?",
                                       {
                                           width: 300,
                                           className: "alphacube",
                                           okLabel: "Si",
                                           cancelLabel: "No",
                                           onOk: function (w) {
                                               cargar_datos_desde_sol(rs,0)
                                               w.close();
                                               return
                                           },

                                           onCancel: function (w) {                                               
                                               w.close();
                                               nvFW.getMyWindow().close()
                                           }
                                       });//dialog

                return
             }//solicitud pendiente

            nro_solicitud = rs.getdata('nro_solicitud')
                        
                    switch (rs.getdata("parametro")) {

                        case "apellido":
                            campos_defs.set_value("apellido", rs.getdata("valor"))
                            break;                        
                        case "calle":
                            campos_defs.set_value("calle", rs.getdata("valor"))
                          //  campos_defs.habilitar("calle", false)
                            break;
                        case "car_tel":
                            $('carac').value = +rs.getdata("valor")
                          //  $('carac').disable = 'disable'
                            break;                      
                        case "cod_prov":
                            campos_defs.set_value("cod_prov_arg", rs.getdata("valor"))
                           // campos_defs.habilitar("cod_prov_arg", false)
                            break;
                        case "depto":
                            campos_defs.set_value("depto", rs.getdata("valor"))
                          //  campos_defs.habilitar("departamento", false)
                            break;
                        
                        case "estado_civil":
                            campos_defs.set_value("id_estado_civil", rs.getdata("valor"))
                           // campos_defs.habilitar("id_estado_civil", false)
                            break;
                        case "fe_naci":
                            campos_defs.set_value("fe_naci", rs.getdata("valor"))
                            //campos_defs.habilitar("fe_naci", false)
                            break;
                        case "localidad":
                            campos_defs.set_value("ciudad", rs.getdata("valor"))
                          //  campos_defs.habilitar("ciudad", false)
                            break;
                        case "nombres":
                            campos_defs.set_value("persona", rs.getdata("valor"))
                            
                            break;
                        case "nro_docu":
                            campos_defs.set_value("dni", rs.getdata("valor"))
                         //   campos_defs.habilitar("dni", false)
                            break;
                        case "numero":
                            campos_defs.set_value("numero", rs.getdata("valor"))
                           // campos_defs.habilitar("numero", false)
                            break;
                        case "piso":
                            campos_defs.set_value("piso", rs.getdata("valor"))
                          //  campos_defs.habilitar("piso", false)
                            break;
                        case "postal_real":
                            campos_defs.set_value("postal", rs.getdata("valor"))
                           // campos_defs.habilitar("postal", false)
                            break;                        
                        case "sexo":
                            campos_defs.set_value("sexo", rs.getdata("valor"))
                            if(verificarpendiente==0)
                            campos_defs.habilitar("sexo", false)
                        break;
                        case "telefono":
                            $('numTel').value = rs.getdata("valor")
                        //    $('numTel').disable = 'disable'
                            break;
                        case "cuil":
                        campos_defs.set_value("cuit",rs.getdata("valor"))
                        break;
                        case "email":
                        campos_defs.set_value("email",rs.getdata("valor"))
                        break;
                        case "token_celular":
                            token = rs.getdata("valor")
                            if (token != 0) {
                                //$('celOk').style.display = 'inline'
                                //$('btnVerificar').style.display = "none"  
                            }
                            else {
                                //$('celOk').style.display = 'none'
                                //$('btnVerificar').style.display = "inline"
                            }
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
            input.placeholder = 'Ingrese una dirección. Ej: Bv. Oroño 126, Rosario, Santa Fe';
            input.autocomplete = 'on';

            autocomplete = new google.maps.places.Autocomplete(input, configs);
            autocomplete.setFields(['address_components']);
            autocomplete.addListener('place_changed', setDataMapCallback); // Evento seleccionar

            /*var input_laboral = $('calleLaboral')
            input_laboral.placeholder = 'Ingrese una dirección. Ej: Bv. Oroño 126, Rosario, Santa Fe';
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
            provincia = provincia.replace("á", "a")
            provincia = provincia.replace("é", "e")
            provincia = provincia.replace("í", "i")
            provincia = provincia.replace("ó", "o")
            provincia = provincia.replace("ú", "u")
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
        function guardar() {
            
            var ciudad=campos_defs.get_value("ciudad")

            if (nro_solicitud > 0)
               modo = 'E'

            if (campos_defs.get_value('apellido') == '') {
                alert("Complete el apellido del cliente")
                return
            }

            if (campos_defs.get_value('persona') == '') {
                alert("Complete el nombre del cliente")
                return
            }

           
            if (campos_defs.get_value('sexo') == '') {
                alert("Seleccione el sexo del cliente")
                return
            }

            if (campos_defs.get_value('dni') == '') {
                alert("Complete el número de documento del cliente")
                return
            }

            if (campos_defs.get_value('dni') == '') {
                alert("Complete el dni del cliente")
                return
            }
             caracteristica = $('carac').value
             telefono = $('numTel').value
             //si alguno de los dos campos NO esta vacio, es porq se quiere ingresar telefono
             if(caracteristica!="" || telefono !=""){
                //que si es asi, valido
                if(!validarTelefono()){
                    alert("Verifique el celular. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el número.")
                    document.getElementById("carac").focus()
                return
                }

             }
             

            var ref1_carac=$F("ref1_carac")
            var ref1_numTel=$F("ref1_numTel")
            var ref1_apenom=$F("ref1_apenom")
            if(ref1_carac!="" || ref1_numTel!=""){
                if(!valida_telefono(ref1_carac,ref1_numTel)){
                     alert("Verifique el telefono de la referencia 1. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el número.")
                    //$("ref1_carac").focus()
                     document.getElementById("ref1_carac").focus()
                    return
                }
            }
            var ref2_carac=$F("ref2_carac")
            var ref2_numTel=$F("ref2_numTel")
            var ref2_apenom=$F("ref2_apenom")
            if(ref2_carac!="" || ref2_numTel!=""){
                if(!valida_telefono(ref2_carac,ref2_numTel)){
                    alert("Verifique el telefono de la referencia 2. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el número.")
                    document.getElementById("ref2_carac").focus()
                    return
                }
            }

            var laboral_carac=$F("laboral_carac")
            var laboral_numTel=$F("laboral_numTel")
            var laboral_lugar_trabajo=$F("laboral_lugar_trabajo")
            if(laboral_carac!="" || laboral_numTel!=""){
                if(!valida_telefono(laboral_carac,laboral_numTel)){
                    alert("Verifique el telefono laboral. Recuerde no colocar el 0 ni el 15 y que no supere los 10 numeros entre la caracteristica y el número.")
                    //$("laboral_carac").focus()
                    document.getElementById("laboral_carac").focus()
                    return
                }
            }


            if(ciudad==""){
                alert("La localidad no debe ser vacia. Verifique")
                document.getElementById("ciudad").focus()
                return
            }


            var verifyOK=verificar_cambios()
             if(!verifyOK){
                alert("No hay cambios realizados. La solicitud no se guardará")
                return
             }

            var accion=(nro_solicitud>0) ? 'guardar la':'generar una'
            
                Dialog.confirm("¿Desea  "+accion+" solicitud pendiente de revision de datos personales?",
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
                                                        parameters: { modo: modo, strXML: xml, nro_solicitud: nro_solicitud,nro_credito:nro_credito },
                                                            bloq_msg: 'Guardando solicitud...',
                                                        onSuccess: function (err, transport) {
                                                            
                                                                if (err.numError == 0) {
                                                                            //if(modo == 'N')
                                                                              //  parent.guardarCredito_ok('P', err.params["nro_solicitud"])
                                                                    
                                                                    nvFW.getMyWindow().close()
                                                                }
                                                                else
                                                                    nvFW.alert('Error al guardar la solicitud.')
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


            
                         
        }//guardar


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

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; background-color: white; -webkit-text-size-adjust: none; overflow: auto;">
    <input type="hidden" id="nro_entidad" name="nro_entidad" value="<%=nro_entidad%>" />
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
                <td class="Tit3" style="text-align: center;"><b>Contactos Telefónicos</b></td>
            </tr>            
            <tr>
                <td>
                    <table id="idref1" class="tb1" style="width: 50%; float: left">                      
                        <tr>
                            <td class="Tit1" style="white-space: nowrap;width: 10%">Referencia 1</td>
                            <td id="tdTelefonoref1" style="width: 40%"><input type="text" id="ref1_carac"  style="width: 30%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)"  maxlength="5" autocomplete="off" placeholder="cod. area" /> -
                               <input type="text" id="ref1_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telefónico"  />
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
                               <input type="text" id="ref2_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telefónico"/>
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
                               <input type="text" id="laboral_numTel" style="width: 60%; text-align: right" onkeypress='return valDigito(event)' onchange="onchange_tel(event)" maxlength="8" autocomplete="off" placeholder="nro. telefónico" />
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

        <table class="tb1" id="tbSolicitud" style="width: 100%; white-space: nowrap;">            
            <tr>
                <td style="font-size: smaller">*Campos obligatorios</td>
            </tr>
        </table>
        <table class="tb1">
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
