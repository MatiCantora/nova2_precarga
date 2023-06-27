<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%

    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    Dim nro_rol As String = nvFW.nvUtiles.obtenerValor("nro_rol", "")
    Dim StrSQL As String = ""

    Dim nro_funcion As String = nvFW.nvUtiles.obtenerValor("nro_funcion", "")
    Dim nro_funcion_entidad_destino As String = nvFW.nvUtiles.obtenerValor("nro_funcion_entidad_destino", "")
    'Dim nro_funcion_inversa As String = nvFW.nvUtiles.obtenerValor("nro_funcion_inversa", "")
    Dim strAElminar As String = nvFW.nvUtiles.obtenerValor("strAElminar", "")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If (modo = "") Then modo = "C"

    If modo.ToUpper() = "M" Then
        Dim Err As New nvFW.tError()

        Dim strXML As String = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""), System.Text.Encoding.Default)

        Err.numError = 1
        Err.mensaje = "Error al executar el procedimiento almacenado"
        Try
            '//Ejecutar el procedimiento
            Dim Cmd As New ADODB.Command ' = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "nv_rol_abm"

            Dim pstrXML = Cmd.CreateParameter("strXML", 201, 1, strXML.Length, strXML)
            Cmd.Parameters.Append(pstrXML)

            Dim rs As ADODB.Recordset = Cmd.Execute()
            If Not rs.EOF Then
                nro_entidad = rs.Fields("nro_entidad").Value
                nro_rol = rs.Fields("nro_rol").Value
                Err.numError = rs.Fields("numError").Value
                Err.titulo = rs.Fields("titulo").Value
                Err.mensaje = rs.Fields("mensaje").Value
                Err.comentario = rs.Fields("comentario").Value
                Err.params.Add("nro_entidad", nro_entidad)
                Err.params.Add("nro_rol", nro_rol)
            End If

            Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
            objXML.LoadXml(strAElminar)
            Dim NODS = objXML.SelectNodes("/info/params")

            For i As Integer = 0 To NODS.Count - 1
                Dim nod = NODS(i)

                Dim origen = nod.Attributes("origen").Value
                Dim destino = nod.Attributes("destino").Value
                Dim nro_funcion_eliminar = nod.Attributes("nro_funcion").Value
                Dim nro_funcion_eliminar_inversa = nod.Attributes("funcion_inversa").Value

                rs = nvFW.nvDBUtiles.DBExecute("Delete entidad_funciones_rel where origen='" + origen + "' and destino='" + destino + "' and nro_funcion='" + nro_funcion_eliminar + "'")
                rs = nvFW.nvDBUtiles.DBExecute("Delete entidad_funciones_rel where origen='" + destino + "' and destino='" + origen + "' and nro_funcion='" + nro_funcion_eliminar_inversa + "'")

            Next

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar el rol"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "rol_abm.aspx"
        End Try

        Err.response()

    ElseIf modo.ToUpper() = "EF" Then 'modo entidad funcion

        Dim Err As New nvFW.tError()

        Err.numError = 1
        Err.mensaje = "Error al guardar la relacion entidad funcion"
        Try
            Dim rs = nvFW.nvDBUtiles.DBExecute("Insert into entidad_funciones_rel(origen,destino,nro_funcion,activo) values('" + nro_entidad + "','" + nro_funcion_entidad_destino + "','" + nro_funcion + "','" + "1" + "')")
            'rs = nvFW.nvDBUtiles.DBExecute("Insert into entidad_funciones_rel(origen,destino,nro_funcion,activo) values('" + nro_funcion_entidad_destino + "','" + nro_entidad + "','" + nro_funcion_inversa + "','" + "1" + "')")

            Err.numError = 0

        Catch ex As Exception

            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar la relacion entidad funcion"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "rol_abm.aspx"
        End Try

        Err.response()

    End If

    Me.contents("permisos_entidades") = nvApp.operador.permisos("permisos_entidades")
    Me.contents("permisos") = nvApp.operador.permisos("permisos_roles")
    Me.contents("nro_entidad") = nro_entidad
    Me.contents("nro_rol") = nro_rol

    'Me.contents("filtroXMLEntidad") = "<criterio><select vista='verEntidades'><campos>nro_entidad,rol_desc,razon_social,abreviacion,calle,postal,localidad,telefono,email,cuit,car_tel,nro_docu,tipo_docu,sexo,apellido,nombres,alias,persona_fisica</campos><orden></orden><filtro><nro_entidad type='igual'>" &
    '                                        nro_entidad & "</nro_entidad>" & "</filtro></select></criterio>"
    '"<nro_rol type='igual'>'" + nro_rol + "'</nro_rol>" +

    Me.contents("filtroXMLEntidad") = "<criterio><select vista='verEntidades'><campos>nro_entidad,rol_desc,razon_social,abreviacion,calle,postal,localidad,telefono,email,cuitcuil,cuit,car_tel,nro_docu,tipo_docu,sexo,apellido,nombres,alias,persona_fisica</campos><orden></orden><filtro>" &
    "<nro_entidad type='igual'>" &
    "'%nro_entidad%'" &
    "</nro_entidad>" & "</filtro></select></criterio>"

    Me.contents("filtroCargarEntidadRelaciones") = "<criterio><select vista='verEntidadFuncionesRel'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>"

    Me.contents("filtroCampoDefEntidad") = "<criterio><select vista='verentidad'><campos>distinct nro_entidad as id, Razon_social as [campo] </campos><orden>[id]</orden></select></criterio>"
    Me.contents("filtroCampoDefWhere") = "<%campo_def%  type='igual'>'%campo_value%'</%campo_def%" + ">"

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Roles</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var vButtonItems = new Array();

        var backDoor = false;

        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "LocalidadSel";
        vButtonItems[0]["etiqueta"] = "...";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return selLocalidad()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');

        var win
        
        var nro_rol = nvFW.pageContents.nro_rol;
        var rol_desc
        var nro_entidad = nvFW.pageContents.nro_entidad;
        var permisos_entidades = nvFW.pageContents.permisos_entidades;
        var roles = new Array()
        var permiso = ''
        var nro_dist_tipo = ''
        
        
        //var distribucion
        function window_onload() {
            //var e
            vListButton.MostrarListButton()
            permisos()
            
            $('nro_entidad2').value = nro_entidad;
            if ($('nro_entidad2').value != '') {
                CargarDatos($('nro_entidad2').value)
                buscar_entidad_roles_param($('nro_entidad2').value, $('nro_rol').value)
                $('modo').value = 'M'
            }
            else {
                entidad_nueva()
                $('modo').value = 'A'
            }
            tabla_entidad_funcion_cargar()
            window_onresize()
        }


        function permisos() {
            if ($('nro_rol').value != "") {
                switch ($('nro_rol').value) {
                    //Cliente      
                    case '1':
                        permiso = nvFW.pageContents.permisos_roles;
                        nro_dist_tipo = 1;
                        break;
                }
            }
        }

        function window_onresize() {
            try {
                var body_h = $$('BODY')[0].getHeight();//$$('body')[0].getHeight();
                
                var dif = Prototype.Browser.IE ? 50 : 50
                var divMenuABMEntidades_h = $('divMenuABMEntidades').getHeight();
                var divDatosPersonales_h = $('divComentarioParametros').getHeight();
                var div_tabla_entidad_funciones_h = 0
                
                //if (!$('div_tabla_entidad_funciones').disabled)
                    div_tabla_entidad_funciones_h = $('div_tabla_entidad_funciones').getHeight();
                    
                var div_comentario_parametros_h = (body_h - div_tabla_entidad_funciones_h - divMenuABMEntidades_h - divDatosPersonales_h)
                
                //console.log(div_comentario_parametros_h);
                $('divComentarioParametros').setStyle({ height: div_comentario_parametros_h });
                $('tbComentarioParametros').setStyle({ height: div_comentario_parametros_h });


                var tabla_estado_h = $('tabla_estado').getHeight();
                $('div_datos_roles').setStyle({ height: (div_comentario_parametros_h - tabla_estado_h) });
            }
            catch (e) { }
        }

        function entidad_nueva() {
            $('nro_entidad2').value = ''
            $('razon_social').value = ''
            $('abreviacion').value = ''
            $('alias').value = ''
            $('calle').value = ''
            $('localidad').value = ''
            $('car_tel').value = ''
            $('telefono').value = ''
            $('email').value = ''
            $('cuit').value = ''
            $('cuitcuil').value = 'CUIL'
            $('apellido').value = ''
            $('nombres').value = ''
            $('nro_docu').value = ''
            //$('nro_dist').value = 0
            campos_defs.clear('tipo_docu')
            campos_defs.clear('fe_alta')
            campos_defs.clear('nro_rol_estado')
            campos_defs.clear('fe_estado')
            decidir_tabla('0')
            buscar_param_roles()
            $('frame_comentarios').src = "/FW/enBlanco.htm"
        }


        var esPersonaFisica = "0";;
        function decidir_tabla(opcion) {
            switch (opcion) {
                case "0": //Si es persona jurídica
                    esPersonaFisica = "0"
                    $('datos_pjuridica').show()
                    $('datos_pfisica').hide()
                    menu_pers_juridica();
                    $('div_tabla_entidad_funciones').disabled = false;

                    $("div_funcion_juridica").show();
                    $("div_funcion_fisica").hide();
                    break
                case "1": //Si es persona física
                    esPersonaFisica = "1"
                    $('datos_pjuridica').hide()
                    $('datos_pfisica').show()
                    menu_pers_fisica();
                    $('div_tabla_entidad_funciones').disabled = true;

                    $("div_funcion_juridica").hide();
                    $("div_funcion_fisica").show();
                    break
                default:
                    $('datos_pjuridica').hide()
                    $('datos_pfisica').hide()
            }
            window_onresize();
        }

        function CargarDatos(nro_entidad) {
            var rs = new tRS();
            rs.async = true
            rs.onComplete = function (rs) {
                if (!rs.eof()) {
                    
                    $('nro_entidad2').value = rs.getdata('nro_entidad')
                    $('razon_social').value = rs.getdata('razon_social')
                    $('abreviacion').value = (rs.getdata('abreviacion') != null) ? rs.getdata('abreviacion') : ''
                    $('calle').value = rs.getdata('calle')
                    $('postal').value = rs.getdata('postal')
                    $('telefono').value = rs.getdata('telefono')
                    $('email').value = rs.getdata('email')
                    $('cuit').value = rs.getdata('cuit')
                    $('cuitcuil').value = rs.getdata('cuitcuil')
                    $('localidad').value = rs.getdata('localidad') ? rs.getdata('localidad') : "";
                    $('car_tel').value = rs.getdata('car_tel') ? rs.getdata('car_tel') : "";
                    $('alias').value = (rs.getdata('alias') != null) ? rs.getdata('alias') : ''
                    
                    $('rol_desc').value = rs.getdata('rol_desc') ? rs.getdata('rol_desc') : "Sin Rol";

                    if (rs.getdata("persona_fisica") == "True") {
                        $('persona_fisica').selectedIndex = 1
                        $('nro_docu').value = (rs.getdata('nro_docu') != null) ? rs.getdata('nro_docu') : ''
                        $('apellido').value = rs.getdata('apellido')
                        $('nombres').value = rs.getdata('nombres')
                        var tipo_docu_p = (rs.getdata("tipo_docu") != null) ? rs.getdata("tipo_docu") : ''
                        campos_defs.set_value("tipo_docu", tipo_docu_p)
                        $('sexo').value = (rs.getdata('sexo') != null) ? rs.getdata('sexo') : ''
                        decidir_tabla('1')
                    }
                    else {
                        $('persona_fisica').selectedIndex = 0
                        decidir_tabla('0')
                    }

                }
                
                VerComentarios()
                

                //No tiene permiso para editar datos de la Entidad
                //permisos_entidades = 99;
                
                if ((permisos_entidades & 1) <= 0) {
                    $('cuit').disabled = "disabled"
                    $('cuitcuil').disabled = "disabled"
                    $('persona_fisica').disabled = "disabled"
                    $('apellido').disabled = "disabled"
                    $('nombres').disabled = "disabled"
                    $('sexo').disabled = "disabled"
                    campos_defs.habilitar('tipo_docu', false)
                    $('nro_docu').disabled = "disabled"
                    $('abreviacion').disabled = "disabled"
                    $('alias').disabled = "disabled"
                    $('calle').disabled = "disabled"
                    $('localidad').disabled = "disabled"
                    $('divLocalidadSel').style.display = 'none'
                    $('car_tel').disabled = "disabled"
                    $('telefono').disabled = "disabled"
                    $('email').disabled = "disabled"
                }

            }
            
            //var consultaXML =   
            var parametros = "<criterio><params nro_entidad= '" + nro_entidad + "' /></criterio>";
            rs.open(nvFW.pageContents.filtroXMLEntidad, "", "", "", parametros)
        }

        function VerComentarios() {
            ObtenerVentana('frame_comentarios').location.href = '/fw/comentario/verCom_registro.aspx?nro_entidad=' +
                                                                $('nro_entidad2').value +
                                                                '&nro_com_id_tipo=6&collapsed_fck=1&do_zoom=0&id_tipo=' +
                                                                $('nro_entidad2').value + '&nro_com_grupo=6'
        }

        function buscar_entidad_roles_param(nro_entidad, nro_rol) {
            
            if ((nro_entidad != '') && (nro_rol != '')) {
                var filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"

                roles = new Array()
                var k = 0
                var rs = new tRS();
                var vacio
                rs.async = true
                
                rs.onComplete = function (rs) {
                    
                    if (!rs.eof()) {
                        $('fe_alta').value = (rs.getdata('fe_alta') != null) ? isNULL_NaN(FechaToSTR(parseFecha(isNULL(rs.getdata('fe_alta'), ''))), '') : '';
                        campos_defs.set_value("nro_rol_estado", rs.getdata("nro_rol_estado"))
                        $('fe_estado').value = (rs.getdata('fe_estado') != null) ? isNULL_NaN(FechaToSTR(parseFecha(isNULL(rs.getdata('fe_estado'), ''))), '') : '';
                        
                        $('id_ent_rol').value = (rs.getdata('id_ent_rol') != null) ? rs.getdata('id_ent_rol') : ''
                    }
                    while (!rs.eof()) {
                        vacio = new Array()
                        
                        vacio['nro_rol'] = rs.getdata('nro_rol')
                        vacio['rol_desc'] = rs.getdata('rol_desc')
                        vacio['parametro'] = rs.getdata('parametro')
                        vacio['nro_campo_tipo'] = rs.getdata('nro_campo_tipo')
                        vacio['obligatorio'] = rs.getdata('obligatorio')
                        vacio['valor_defecto'] = rs.getdata('valor_defecto')
                        vacio['campo_def'] = rs.getdata('campo_def')
                        vacio['etiqueta'] = rs.getdata('etiqueta')
                        vacio['param_orden'] = rs.getdata('param_orden')
                        vacio['id_rol_param'] = rs.getdata('id_rol_param')
                        vacio['valor'] = (rs.getdata('valor') != null) ? rs.getdata('valor') : '';

                        roles[k] = vacio
                        k++
                        rs.movenext()
                    }
                    if ((roles.length > 1) || ((roles.length == 1) && ((roles[0]['parametro'] != null) || (roles[0]['campo_def'] != null)))) {
                        roles_dibujar('edicion')
                    }

                    //No tiene permiso para editar el estado de una Entidad
                    if ((permiso & 1) <= 0) {
                        campos_defs.habilitar('fe_alta', false)
                        campos_defs.habilitar('nro_rol_estado', false)
                        campos_defs.habilitar('fe_estado', false)
                    }

                }
                
                rs.open("<criterio><select vista='verEntidadRolesParam'><campos>*</campos><orden>param_orden</orden><filtro><nro_rol type='igual'>" + nro_rol + "</nro_rol>" + filtro + "</filtro></select></criterio>")
            }
        }

        function roles_dibujar(accion) {

            if (roles.length > 0) {
                $('div_datos_roles').innerHTML = ''
                var strHTML = '<table id="div_datos_roles" class="tb1" style="width:100%; vertical-align: top;">'

                roles.each(function (arreglo, i) {
                    obligatorio = (arreglo['obligatorio'] == "True") ? '*' : '';
                    strHTML += '<tr>'
                    strHTML += '<td class="Tit1" style="width:35%;text-align:right"><b>' + arreglo['etiqueta'] + obligatorio + '</b></td>'
                    strHTML += '<td style="text-align:left" id="td_' + arreglo["parametro"] + '"></td>'
                    strHTML += '</tr>'
                });
                strHTML += '</table>'
                $('div_datos_roles').insert({ top: strHTML })

                roles.each(function (arreglo, i) {

                    if (arreglo['campo_def'] != null) {
                        campos_defs.add(arreglo["campo_def"], { target: 'td_' + arreglo["parametro"] })
                        if (accion == 'alta')
                            campos_defs.set_value(arreglo["campo_def"], arreglo["valor_defecto"])
                        else {
                            campos_defs.set_value(arreglo["campo_def"], arreglo["valor"])
                            //No tiene permiso para editar los parámetros de una Entidad
                            if ((permiso & 2) <= 0) {
                                campos_defs.habilitar(arreglo["campo_def"], false)
                            }
                        }
                    } else if (arreglo['parametro'] != null) {
                        campos_defs.add(arreglo["parametro"], { enDB: false, target: 'td_' + arreglo["parametro"], nro_campo_tipo: arreglo["nro_campo_tipo"] })
                        if (accion == 'alta')
                            campos_defs.set_value(arreglo["parametro"], arreglo["valor_defecto"])
                        else {
                            campos_defs.set_value(arreglo["parametro"], arreglo["valor"])
                            //No tiene permiso para editar los parámetros de una Entidad
                            if ((permiso & 2) <= 0) {
                                campos_defs.habilitar(arreglo["parametro"], false)
                            }
                        }
                    }
                });
            }
            campos_defs.habilitar('fe_alta')
            campos_defs.habilitar('fe_estado')
        }

        function buscar_param_roles() {
            
            nro_rol = $('nro_rol').value
            if (nro_rol != '') {
                rol_desc = ''

                roles = new Array()
                var k = 0
                var rs = new tRS();
                var vacio
                rs.open("<criterio><select vista='verParamRoles'><campos>nro_rol,rol_desc,parametro,nro_campo_tipo,obligatorio,valor_defecto,campo_def,etiqueta,param_orden,id_rol_param</campos><orden>param_orden</orden><filtro><nro_rol type='igual'>" + nro_rol + "</nro_rol></filtro></select></criterio>")

                if (!rs.eof()) {
                    rol_desc = rs.getdata('rol_desc')
                }
                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['nro_rol'] = rs.getdata('nro_rol')
                    vacio['rol_desc'] = rs.getdata('rol_desc')
                    vacio['parametro'] = rs.getdata('parametro')
                    vacio['nro_campo_tipo'] = rs.getdata('nro_campo_tipo')
                    vacio['obligatorio'] = rs.getdata('obligatorio')
                    vacio['valor_defecto'] = rs.getdata('valor_defecto')
                    vacio['campo_def'] = rs.getdata('campo_def')
                    vacio['etiqueta'] = rs.getdata('etiqueta')
                    vacio['param_orden'] = rs.getdata('param_orden')
                    vacio['id_rol_param'] = rs.getdata('id_rol_param')
                    vacio['valor'] = ''

                    roles[k] = vacio
                    k++
                    rs.movenext()
                }
                if ((roles.length > 1) || ((roles.length == 1) && ((roles[0]['parametro'] != null) || (roles[0]['campo_def'] != null)))) {
                    roles_dibujar('alta')
                }
            }
        }

        function Cerrar_Ventanas() {
            window.top.Windows.getFocusedWindow().close()
        }

        function ver(alertError) {
            alertError.close()
            winActualizar.close()
        }

        function window_onunload() {
            var a = new Array();
            a["razon_social"] = $('razon_social').value
            a["modo"] = $('modo').value
            window.parent.returnValue = a
        }


        var res = new Array()
        function selLocalidad()     // ************ Seleccionar la Localidad
        {
            win = new Window({ className: 'alphacube',
                url: '/fw/funciones/localidad_consultar.aspx',
                title: '<b>Seleccionar Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                width: 400,
                height: 300,
                onClose: selLocalidad_return
            });
            win.options.userData = {}
            win.showCenter(true)
        }

        function selLocalidad_return() {
            
            if (win.options.userData.res) {
                try {
                    var res = win.options.userData.res
                    $('postal').value = res.postal
                    $('localidad').value = res.desc
                    $('car_tel').value = res.car_tel
                }
                catch (e) { }
            }
        }

        function isNULL(valor, sinulo) {
            return valor = valor == null ? sinulo : valor
        }

        function isNULL_NaN(valor, sinulo) {
            return valor = valor == 'NaN/NaN/NaN' ? sinulo : valor
        }

        function trim(myString) {
            return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
        }

        var win_rol_seleccion
        function validarCUIT() {
            
            
            var str = ''
            var accion = ''
            var filtro = ''
            var cuit = trim($('cuit').value)
            var msj = ''
            
            //if (($('cuit').value.length > 0) && ($('cuit').value.length != 11)) {
            if (!validarFormatoCUIT(cuit) && backDoor) {
                if (cuit!="")
                    alert('El cuit ingresado puede ser inválido.')
            } else {

                accion = (($('nro_entidad2').value != '') && ($('nro_entidad2').value != '0')) ? 'edicion' : 'alta'

                var rs = new tRS();
                rs.open("<criterio><select vista='Entidades'><campos>nro_entidad,Razon_social,cuit,cuitcuil</campos><orden></orden><filtro><cuit type='like'>" + cuit + "</cuit></filtro></select></criterio>")

                if (rs.recordcount >= 1) {
                    
                    while (!rs.eof()) {
                        if (nro_entidad != rs.getdata('nro_entidad')) {
                            if (msj == '') {
                                msj = 'Existen las siguientes entidades con el CUIT ingresado:</br>'
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            } else {
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            }
                        }
                        nro_entidad = rs.getdata('nro_entidad')
                        rs.movenext()
                    }
                    
                    if ((accion == 'edicion') && (msj != '')) {
                        alert(msj);
                        return
                    }

                    var win = nvFW.getMyWindow();
                    
                    if (accion == 'alta') {
                        win_rol_seleccion = new Window({ className: 'alphacube',
                            url: 'rol_seleccion.aspx?cuit=' + cuit + '&nro_entidad=' + nro_entidad + '&id_ventana=' +  window.top.win.content.id,
                            title: '<b>Selector de Entidades</b>',
                            minimizable: true,
                            maximizable: false,
                            draggable: false,
                            width: 400,
                            height: 200,
                            resizable: false,
                            onClose: recuperar_entidad
                        });

                        //win_rol_seleccion.setURL('rol_seleccion.asp?cuit='+trim($('cuit').value) + '&nro_entidad='+nro_entidad + '&id_ventana=' + window.top.win.content.id) 
                        win_rol_seleccion.showCenter(true)
                    }
                }
            }
        }

        function recuperar_entidad(nro) {
            
            if (nro_entidad != '') {
                CargarDatos(nro_entidad)
                
                tabla_entidad_funciones.refresh("<origen>" + nro_entidad + "</origen>");

                if ($('nro_rol').value != '') {
                    filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"
                    var rs1 = new tRS();
                    rs1.open("<criterio><select vista='verEntidad_roles'><campos>rol_desc</campos><orden></orden><filtro><nro_rol type='igual'>" + $('nro_rol').value + "</nro_rol>" + filtro + "</filtro></select></criterio>")
                    
                    if (!rs1.eof()) {
                        buscar_entidad_roles_param(nro_entidad, $('nro_rol').value)
                        //str += 'La Entidad ya está asociada al rol "' + rs1.getdata('rol_desc') + '".</br>'; 
                    } else {
                        $('fe_alta').value = ''
                        $('nro_rol_estado').value = ''
                        $('fe_estado').value = ''
                        $('id_ent_rol').value = ''

                        roles.each(function (arreglo, i) {
                            if (arreglo['campo_def'] != null) {
                                campos_defs.set_value(arreglo["campo_def"], '')
                            } else if (arreglo['parametro'] != null) {
                                campos_defs.set_value(arreglo["parametro"], '')
                            }
                        });
                    }

                }
            }
        }

        function boton_generar_cuit() {
            var sexo = $('sexo').value
            var nro_docu = $('nro_docu').value
            var strError = ""

            if ((sexo == "") || (nro_docu == ""))
                strError += 'Para generar el CUIT debe ingresar "Sexo" y "Nro. Documento"</br>';

            if (strError != "") {
                alert(strError)
                return
            } else {
                generarCUIT()
            }
        }

        //function generarCUIT(sexo, nro_docu) {
        function generarCUIT() {
            //sexo "M" = 20
            //sexo "F" = 27
            //30 para otros tipos de entidades
            var sexo = $('sexo').value
            var nro_docu = $('nro_docu').value

            if ((sexo != '') && (nro_docu != '')) {
                var v1
                var str_nro_docu = nro_docu.toString()
                if (sexo.toUpperCase() == "M")
                    v1 = "20"
                else {
                    if (sexo.toUpperCase() == "F")
                        v1 = "27"
                    else
                        v1 = "30"
                }
                while (str_nro_docu.length < 8)
                    str_nro_docu = "0" + str_nro_docu

                var digito = digitoVerificador(v1 + str_nro_docu)

                if (digito == 10) {
                    if (v1 == 20 || v1 == 27 || v1 == 24)
                        v1 = '23'
                    else
                        v1 = '33'
                }
                //el digito verificador debe ser 4 para v1=27. y 9 para v1=22 o 33
                /*No es necesario hacer la llamada recursiva, 
                se puede poner el digito en 9 si el prefijo original era 
                23 o 33 o poner el dijito en 4 si el prefijo era 27*/

                //return v1 + str_nro_docu + digitoVerificador(v1 + str_nro_docu)
                if (trim($('cuit').value) == '') {
                    $('cuit').value = v1 + str_nro_docu + digitoVerificador(v1 + str_nro_docu)
                    validarCUIT()
                }
            }
        }

        function digitoVerificador(S) {
            var v2 = 0;
            var v3 = 0;
            S = S.toString()
            v2 = (parseInt(S.substr(0, 1)) * 5 + parseInt(S.substr(1, 1)) * 4 + parseInt(S.substr(2, 1)) * 3 + parseInt(S.substr(3, 1)) * 2 + parseInt(S.substr(4, 1)) * 7 + parseInt(S.substr(5, 1)) * 6 + parseInt(S.substr(6, 1)) * 5 + parseInt(S.substr(7, 1)) * 4 + parseInt(S.substr(8, 1)) * 3 + parseInt(S.substr(9, 1)) * 2);
            v2 = v2 - (Math.floor(v2 / 11) * 11)
            v3 = 11 - v2;

            switch (v3) {
                case 11: v3 = 0; break;
            }
            return v3
        }

        function validarFormatoCUIT(strCUIT) {

            // determina si el dígito verificador es correcto
            // Retorna true si es correcto y false si es incorrecto
            var v3
            if (strCUIT.length = 11) {
                v3 = digitoVerificador(parseInt(strCUIT));
                var digito_ok = parseInt(strCUIT.substr(10, 1)) == v3
                var val_ok = (parseInt(strCUIT.substr(0, 2)) == 23 && (v3 == 4 || v3 == 9)) || (parseInt(strCUIT.substr(0, 2)) != 23)
                return digito_ok && val_ok;
            }
            else
                return false
        }

        function entidad_guardar() {
            
            var strError = "";
            var cuit = trim($('cuit').value)
            var cuitcuil = trim($('cuitcuil').value)
            //Validar los datos
            if (cuit == "")
                strError += 'No ha cargado el "CUIT"</br>';
            else {
                var filtro = ''
                if ($('nro_entidad2').value != '')
                    filtro = "<nro_entidad type='distinto'>" + $('nro_entidad2').value + "</nro_entidad>"
                var rs = new tRS();
                rs.open("<criterio><select vista='verEntidad_roles'><campos>cuit</campos><filtro><cuit type='igual'>" + cuit + "</cuit>" + filtro + "</filtro></select></criterio>")
                if (!rs.eof())
                    strError += 'Ya existe una Entidad con el CUIT ingresado</br>';
            }

            if ($('persona_fisica').value == "1") {
                if ($('apellido').value == "")
                    strError += 'No ha cargado el "Apellido"</br>';
                if ($('nombres').value == "")
                    strError += 'No ha cargado el "Nombre"</br>';
                if ($('nro_docu').value == "")
                    strError += 'No ha cargado el "Nro.Documento"</br>';
                if ($('tipo_docu').value == "")
                    strError += 'No ha cargado el "Tipo Documento"</br>';
            }
            else {
                if ($('razon_social').value == "")
                    strError += 'No ha cargado la "Razón Social"</br>';
            }

           // if ($('localidad').value == "")
             //   strError += 'No ha cargado la "Localidad"</br>';

            roles.each(function (arreglo, i) {
                if (arreglo['obligatorio'] == "True") {
                    if (arreglo['campo_def'] != null) {
                        if ($(arreglo['campo_def']).value == "")
                            strError += 'Debe seleccionar ' + arreglo["etiqueta"] + '</br>';
                    } else if (arreglo['parametro'] != null) {
                        if ($(arreglo['parametro']).value == "")
                            strError += 'Debe ingresar ' + arreglo["etiqueta"] + '</br>';
                    }
                }
            });

            if (strError != "") {
                alert(strError);
                return
            }

            if ($('persona_fisica').value == "1")
                $('razon_social').value = $('apellido').value + " " + $('nombres').value

            var razon_social = '<![CDATA[' + $('razon_social').value + ']]>'
            var abreviacion = '<![CDATA[' + $('abreviacion').value + ']]>'
            var apellido = '<![CDATA[' + $('apellido').value + ']]>'
            var nombres = '<![CDATA[' + $('nombres').value + ']]>'
            var alias = '<![CDATA[' + $('alias').value + ']]>'
            var calle = '<![CDATA[' + $('calle').value + ']]>'
            var email = '<![CDATA[' + $('email').value + ']]>'


            var xmldato = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            xmldato += "<pago_entidad modo = '" + $('modo').value + "' nro_entidad = '" + $('nro_entidad2').value + "' "
            xmldato += "postal='" + $('postal').value + "' telefono='" + $('telefono').value + "' "
            xmldato += "cuit='" + cuit + "' "
            xmldato += "cuitcuil='" + cuitcuil + "' "
            if ($('persona_fisica').value == "1")
                xmldato += "nro_docu='" + $('nro_docu').value + "' tipo_docu='" + $('tipo_docu').value + "' sexo='" + $('sexo').value + "' persona_fisica='" + $('persona_fisica').value + "' "
            else
                xmldato += "nro_docu='0' tipo_docu='0' sexo='' persona_fisica='0' "
            xmldato += ">"

            if ($('persona_fisica').value == "1") {
                xmldato += "<apellido>" + apellido + "</apellido>"
                xmldato += "<nombres>" + nombres + "</nombres>"
            }
            else {
                xmldato += "<apellido></apellido>"
                xmldato += "<nombres></nombres>"
            }
            xmldato += "<razon_social>" + razon_social + "</razon_social>"
            xmldato += "<abreviacion>" + abreviacion + "</abreviacion>"
            xmldato += "<alias>" + alias + "</alias>"
            xmldato += "<calle>" + calle + "</calle>"
            xmldato += "<email>" + email + "</email>"


            xmldato += "<entidad_roles id_ent_rol = '" + $('id_ent_rol').value + "' nro_entidad = '" + $('nro_entidad2').value + "' nro_rol = '" + $('nro_rol').value + "' fe_alta = '" + $('fe_alta').value + "' nro_rol_estado = '" + $('nro_rol_estado').value + "' fe_estado = '" + $('fe_estado').value + "'>"
            xmldato += "</entidad_roles>"
            xmldato += "<roles>"
            roles.each(function (arreglo_o, index_o) {
                if (arreglo_o['campo_def'] != null) {
                    xmldato += "<rol_param_values id_ent_rol = '" + $('id_ent_rol').value + "' id_rol_param = '" + arreglo_o['id_rol_param'] + "' valor = '" + $(arreglo_o['campo_def']).value + "'/>"
                } else if (arreglo_o['parametro'] != null) {
                    xmldato += "<rol_param_values id_ent_rol = '" + $('id_ent_rol').value + "' id_rol_param = '" + arreglo_o['id_rol_param'] + "' valor = '" + $(arreglo_o['parametro']).value + "'/>"
                }
            });
            xmldato += "</roles>"

            xmldato += "</pago_entidad>"

            var strAElminar = "<info>"
            strAElminar += tabla_entidad_funciones.generarXML("params")
            strAElminar += "</info>"
            
            nvFW.error_ajax_request('rol_abm.aspx', {
                parameters: {
                    modo: 'M',
                    strXML: escape(xmldato),
                    strAElminar: strAElminar
                },
                onSuccess: function (err, transport) {
                    var nro_entidad = err.params['nro_entidad']
                    var nro_rol = err.params['nro_rol']

                    var params = new Array()
                    params['nro_entidad'] = nro_entidad
                    params['nro_rol'] = nro_rol
                    window.top.Windows.getFocusedWindow().options.userData.modificacion = true;
                    window.top.Windows.getFocusedWindow().returnValue = params
                    window.top.Windows.getFocusedWindow().close()

                    if ((nro_entidad != undefined) && (nro_rol != undefined) && (nro_entidad != '') && (nro_rol == '1')) {
                        window.parent.frame_ref.location.href = '/<%= nvApp.path_rel %>/cliente_mostrar.aspx?nro_entidad=' + nro_entidad + '&nro_rol=' + nro_rol
                    }
                }
            });
        }

        function nuevo_certificado() {
            var Parametros = new Array();

            if (!nro_entidad) {
                alert("La entidad no esta cargada en la BD.")
                return;
            }
            var nombre_entidad = $('razon_social').value || $('apellido').value + " " + $('nombres').value


            win =
                window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/pki/pki_certificados_entidad.aspx?nombre_entidad=' + nombre_entidad + "&nro_entidad=" + nro_entidad,
                    title: '<b>Certificados ABM</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 1000,
                    height: 500,
                    minWidth: 900,
                    minHeight: 500,
                    destroyOnClose: true,
                    onShow: function (win) {
                        win_top = win.element.offsetTop
                        win_left = win.element.offsetLeft

                        Windows.windows.each(function (arreglo, i) {
                            if (arreglo['element'].id == win.element.id) {
                                if (i > 0) {
                                    win_top = arreglo['element'].offsetTop + (i * 20)
                                    win_left = arreglo['element'].offsetLeft + (i * 20)
                                }
                            }
                        });

                        win.centerTop = win_top
                        win.centerLeft = win_left

                        win.setLocation(win_top, win_left)
                    }
                });
            win.options.userData = { retorno: Parametros }
            win.options.data = {};
            win.showCenter();
        }
        
        var tabla_entidad_funciones;
        function tabla_entidad_funcion_cargar() {
            tabla_entidad_funciones = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_entidad_funciones.nombreTabla = "tabla_entidad_funciones";
            //Agregamos consulta XML
            tabla_entidad_funciones.filtroXML = nvFW.pageContents.filtroCargarEntidadRelaciones

          //  if ($('nro_entidad2').value)
                tabla_entidad_funciones.filtroWhere = "<origen>" + "99999999999999" + "</origen>";

            tabla_entidad_funciones.cabeceras = ["Destino", "Funcion"];

            tabla_entidad_funciones.async = true;

            tabla_entidad_funciones.editable = false;
            tabla_entidad_funciones.mostrarAgregar = false;

            tabla_entidad_funciones.camposHide = [{ nombreCampo: "origen" }, { nombreCampo: "destino" }, { nombreCampo: "nro_funcion" }, { nombreCampo: "funcion_inversa" }]

            tabla_entidad_funciones.campos = [
             {
                 nombreCampo: "Razon_social",
             },
             {
                 nombreCampo: "funcion",
             }
            ];
            
            tabla_entidad_funciones.table_load_html();
        }

        function agregar_entidad_funcion() {

            nvFW.error_ajax_request('rol_abm.aspx', {
                parameters: { modo:'M', strXML: escape(xmldato) },
                onSuccess: function (err, transport) {
                    var nro_entidad = err.params['nro_entidad']
                    var nro_rol = err.params['nro_rol']

                    var params = new Array()
                    params['nro_entidad'] = nro_entidad
                    params['nro_rol'] = nro_rol
                    window.top.Windows.getFocusedWindow().options.userData.modificacion = true;
                    window.top.Windows.getFocusedWindow().returnValue = params
                    window.top.Windows.getFocusedWindow().close()

                    if ((nro_entidad != undefined) && (nro_rol != undefined) && (nro_entidad != '') && (nro_rol == '1')) {
                        window.parent.frame_ref.location.href = '/<%= nvApp.path_rel %>/cliente_mostrar.aspx?nro_entidad=' + nro_entidad + '&nro_rol=' + nro_rol
                    }
                }
            });

        }

        function entidad_funcion_guardar() {

            var funcion;
            if (esPersonaFisica == "0")
                funcion = campos_defs.get_value('funcion_juridica')
            else
                funcion = campos_defs.get_value('funcion_fisica')

            if (!$('nro_entidad2').value && backDoor) {
                alert("No es posible agregar la funcion, primero seleccione una entidad existente");
                return;
            }
            else if (!funcion) {
                alert("No es posible agregar la funcion, primero seleccione una funcion existente");
                return;
            }
            else if (!campos_defs.get_value('nro_entidades')) {
                alert("No es posible agregar la funcion, primero seleccione una entidad de destino existente");
                return;
            }

            filtroWhere = "<nro_funcion type='igual'>" + funcion + "</nro_funcion>"

         //   rs = new tRS();
            //rs.open("<criterio><select vista='entidad_funciones'><campos>funcion_inversa</campos><filtro>" + filtroWhere + "</filtro></select></criterio>")
            
            nvFW.error_ajax_request('rol_abm.aspx', {
                parameters: {
                    modo: "EF",
                    nro_entidad:  $('nro_entidad2').value,
                    nro_funcion: funcion,
                    nro_funcion_entidad_destino: campos_defs.get_value('nro_entidades')
                    //nro_funcion_inversa: rs.getdata("funcion_inversa")
                },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        tabla_entidad_funciones.refresh("<origen>" + $('nro_entidad2').value + "</origen>");
                    }
                }
            });
        }

        function nuevo_esquema() {
            var Parametros = new Array();
            /*
            if (!nro_entidad) {
                alert("La entidad no esta cargada en la BD.")
                return;
            }*/
            var nombre_entidad = $('razon_social').value || $('apellido').value + " " + $('nombres').value
            
            //TODO 
            nro_entidad = "3766"

            win =
                window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/pki/pki_esquemas_de_firmas.aspx?nro_entidad=' + nro_entidad,
                    title: '<b>ABM Esquema Firma</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 1000,
                    height: 500,
                    minWidth: 900,
                    minHeight: 500,
                    destroyOnClose: true,
                    onShow: function (win) {
                        win_top = win.element.offsetTop
                        win_left = win.element.offsetLeft

                        Windows.windows.each(function (arreglo, i) {
                            if (arreglo['element'].id == win.element.id) {
                                if (i > 0) {
                                    win_top = arreglo['element'].offsetTop + (i * 20)
                                    win_left = arreglo['element'].offsetLeft + (i * 20)
                                }
                            }
                        });

                        win.centerTop = win_top
                        win.centerLeft = win_left

                        win.setLocation(win_top, win_left)
                    }
                });
            //win.options.userData = { retorno: Parametros }
            //win.options.data = {};
            win.showCenter();
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height:100%;  overflow: auto">
    <form action="rol_abm.aspx" method="post" name="form1" target="frmEnviar">
    <input name="modo" type="hidden" value="<%=modo %>" id="modo" />
    <input type="hidden" name="nro_entidad2" id="nro_entidad2" value="<%= nro_entidad %>" />
    <input type="hidden" name="nro_rol" id="nro_rol" value="<%= nro_rol %>" />
    <input type="hidden" name="id_ent_rol" id="id_ent_rol" value="" />
    <input name="strXML" type="hidden" value="" />
    <div id="divFiltroDatos" style="width: 100%; height:97%; overflow: hidden">
        <input type="hidden" name="postal" id="postal" value="" />
        <div id="divMenuABMEntidades">
        </div>

        <script type="text/javascript" >

            var Menus;
            function menu_pers_juridica() {
                vMenuABMEntidades = menu_cargar_generico();
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>ABM Esquema Firma</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_esquema()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenuABMEntidades.MostrarMenu()
            }

            function menu_pers_fisica() {
                vMenuABMEntidades = menu_cargar_generico();
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Nuevo Certificado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_certificado()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenuABMEntidades.MostrarMenu()
            }

            function menu_cargar_generico() {

                $('divMenuABMEntidades').innerHTML = ""

                var DocumentMNG = new tDMOffLine;
                var vMenuABMEntidades = new tMenu('divMenuABMEntidades', 'vMenuABMEntidades');

                Menus["vMenuABMEntidades"] = vMenuABMEntidades
                Menus["vMenuABMEntidades"].alineacion = 'centro';
                Menus["vMenuABMEntidades"].estilo = 'A';
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>entidad_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Generar CUIT</Desc><Acciones><Ejecutar Tipo='script'><Codigo>boton_generar_cuit()</Codigo></Ejecutar></Acciones></MenuItem>")

                if ((permiso & 4) > 0)
                    Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>entidad_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")

                Menus["vMenuABMEntidades"].loadImage('guardar', '/FW/image/icons/guardar.png')
                Menus["vMenuABMEntidades"].loadImage('hoja', '/FW/image/icons/nueva.png')

                return vMenuABMEntidades;
            }

            menu_pers_juridica()
        </script>

        <div id="divDatosPersonales" style="width: 100%; height: auto;">
            <table class="tb1">
                <tr>
                    <td style="width: 25%">
                        <table class="tb1">
                            <tr class="tbLabel">
                                 <td style="width: 30%">
                                    <b>TIPO</b>
                                </td>
                                <td style="width: 70%">
                                    <b>CUIT/CUIL*</b>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <select id="cuitcuil" style="width:100%">
                                        <option value="CUIL" selected="selected">CUIL</option>
                                        <option value="CUIT">CUIT</option>
                                    </select>
                                </td>
                                <td>
                                    <input style="width: 100%; text-align: right" maxlength="11" type="text" name="cuit"
                                        id="cuit" value="" onkeypress="return valDigito(event)" onchange="validarCUIT()" />
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="width: 10%">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td style="width: 100%">
                                    <b>Tipo entidad</b>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <select name="persona_fisica" id="persona_fisica" onchange="decidir_tabla(this.value)">
                                        <option value="0" selected="selected">Persona Juridica</option>
                                        <option value="1">Persona Fisica</option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td style="width: 65%">
                        <table class="tb1" id="datos_pfisica" style='display: none; width: 100%'>
                            <tr class="tbLabel">
                                <td style="width: 30%">
                                    <b>Apellido*</b>
                                </td>
                                <td style="width: 30%">
                                    <b>Nombres*</b>
                                </td>
                                <td style="width: 10%">
                                    <b>Sexo*</b>
                                </td>
                                <td style="width: 14%">
                                    <b>Tipo*</b>
                                </td>
                                <td style="width: 16%">
                                    <b>Nro.Documento*</b>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" name="apellido" id="apellido" value="" style="width: 100%" />
                                </td>
                                <td>
                                    <input type="text" name="nombres" id="nombres" value="" style="width: 100%" />
                                </td>
                                <td>
                                    <select name="sexo" id="sexo" style="width: 100%">
                                        <option value="M">MASC</option>
                                        <option value="F">FEM</option>
                                    </select>
                                </td>
                                <td>
                                    <%= nvFW.nvCampo_def.get_html_input("tipo_docu") %>
                                </td>
                                <td>
                                    <input type="text" name="nro_docu" id="nro_docu" value="" style="width: 100%" onchange="generarCUIT()"
                                        onkeypress="return valDigito(event)" />
                                </td>
                            </tr>
                        </table>
                        <table class="tb1" id="datos_pjuridica" style="width: 100% !Important">
                            <tr class="tbLabel">
                                <td style="width: 100%">
                                    <b>Razón Social*</b>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%">
                                    <input type="text" name="razon_social" id="razon_social" value="" style="width: 100%"
                                        maxlength="200" />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="width: 15%">
                        <b>Abreviación</b>
                    </td>
                    <td style="width: 15%">
                        <b>Alias</b>
                    </td>
                    <td style="width: 15%">
                        <b>Dirección</b>
                    </td>
                    <td style="width: 40%" colspan="2">
                        <b>Localidad</b>
                    </td>
                    <td style="width: 15%">
                        <b>Telefono</b>
                    </td>
                </tr>
                <tr>
                    <td style="width: 15%">
                        <input type="text" name="abreviacion" id="abreviacion" value="" style="width: 100%"
                            maxlength="50" />
                    </td>
                    <td style="width: 15%">
                        <input type="text" name="alias" id="alias" value="" style="width: 100%" maxlength="200" />
                    </td>
                    <td style="width: 15%">
                        <input type="text" name="calle" id="calle" value="" style="width: 100%" maxlength="50" />
                    </td>
                    <td style="width: 30%">
                        <input name="localidad" id="localidad" style="width: 100%" ondblclick="selLocalidad()"
                            readonly="readonly" />
                    </td>
                    <td style="width: 10%">
                        <div id="divLocalidadSel" style="width: 100%">
                        </div>
                    </td>
                    <td style="width: 15%">
                        <input type="text" name="car_tel" id="car_tel" value="" readonly="readonly" style="width: 28%" /><input
                            type="text" name="telefono" id="telefono" value="" style="width: 70%" />
                    </td>
                </tr>
            </table>
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="width: 75%">
                        <b>E-mail</b>
                    </td>
                    <td style="width: 25%">
                        <b>Rol</b>
                    </td>
                </tr>
                <tr>
                    <td style="width: 75%">
                        <input type="text" name="email" id="email" style="width: 100%" value="" maxlength="255" />
                    </td>
                    <td style="width: 25%">
                        <input type="text" disabled id="rol_desc" style="width:95%"/>
                    </td>
                </tr>
            </table>
            
        </div>

        <div id="div_tabla_entidad_funciones" style="width: 100%; height: 170px;">
            <div id="tabla_entidad_funciones" style="width: 100%; height: 100%;"></div>
        </div>

        <table style="width: 100%; height: 15px;" class="tb1" id="tabla_agregar_entidad_funciones">
            <tr>
                <td class="Tit1" >Agregar:</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add("nro_entidades", {
                            nro_campo_tipo: 3,
                            enDB: true
                        })
                    </script> 
                </td>
                <td>
                    <div id="div_funcion_fisica">
                        <script type="text/javascript">
                            campos_defs.add("funcion_fisica",
                                {
                                    filtroXML: "<criterio><select vista='Entidad_funciones'><campos>distinct nro_funcion as id, funcion as [campo] </campos><orden>[id]</orden><filtro><aplica_pf type='igual'>'1'</aplica_pf></filtro></select></criterio>",
                                    nro_campo_tipo: 1,
                                    enDB: false
                                })
                            $("div_funcion_fisica").hide()
                        </script> 
                    </div>
                    <div id="div_funcion_juridica">
                        <script type="text/javascript">
                            campos_defs.add("funcion_juridica",
                                {
                                    filtroXML: "<criterio><select vista='Entidad_funciones'><campos>distinct nro_funcion as id, funcion as [campo] </campos><orden>[id]</orden><filtro><aplica_pj type='igual'>'1'</aplica_pj></filtro></select></criterio>",
                                    nro_campo_tipo: 1,
                                    enDB: false
                                })
                        </script> 
                    </div>
                </td>
                <td><input type="button" value= "Agregar" onclick="entidad_funcion_guardar()"/></td>
            </tr>            
        </table>

        <div id="divComentarioParametros" style="width: 100%; ">
            <table class="tb1" id="tbComentarioParametros">
                <tr>
                    <td style="width: 70%; vertical-align: top;" id="td_frame_comentarios">
                        <iframe name="frame_comentarios" id="frame_comentarios" style="width: 100%; height: 100%;
                            overflow: hidden;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
                    </td>
                    <td id="td_estado_parametros" style="width: 30%; vertical-align: top;">
                        <table id="tabla_estado" class="tb1" style="width: 100%; vertical-align: top;">
                            <tr>
                                <td class="Tit1" style="width: 35%; text-align: right">
                                    <b>Fecha Alta</b>
                                </td>
                                <td style="text-align: left">

                                    <script type="text/javascript">
                                        campos_defs.add('fe_alta', { enDB: false, nro_campo_tipo: 103 })
                                    </script>

                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1" style="width: 30%; text-align: right">
                                    <b>Estado</b>
                                </td>
                                <td style="text-align: left">

                                    <script type="text/javascript">
                                        campos_defs.add('nro_rol_estado')
                                    </script>

                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1" style="width: 30%; text-align: right">
                                    <b>Fecha Estado</b>
                                </td>
                                <td style="text-align: left">

                                    <script type="text/javascript">
                                        campos_defs.add('fe_estado', { enDB: false, nro_campo_tipo: 103 })
                                    </script>

                                </td>
                            </tr>
                        </table>
                        <div id="div_datos_roles" style="width: 100%; height: 100%; overflow: auto">
                        </div>
                    </td>
                </tr>
            </table>
        </div>
        <%--<iframe name="frmEnviar" style="display: none" src="/FW/enBlanco.htm"></iframe>--%>
    </div>
    </form>
</body>
</html>
