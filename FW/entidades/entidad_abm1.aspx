<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    'Dim nro_rol As String = nvFW.nvUtiles.obtenerValor("nro_rol", "0")
    Dim StrSQL As String = ""
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "C")         '//Modos --->    'C': Consulta - MC:Modif.Cabecera - AC:Alta Cabecera
    'If (modo = "") Then modo = "C"


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
            'Cmd.CommandText = "nv_rol_abm"
            Cmd.CommandText = "nv_entidad_abm"

            Dim pstrXML = Cmd.CreateParameter("strXML", 201, 1, strXML.Length, strXML)
            Cmd.Parameters.Append(pstrXML)

            Dim rs As ADODB.Recordset = Cmd.Execute()
            If Not rs.EOF Then
                nro_entidad = rs.Fields("nro_entidad").Value
                'nro_rol = rs.Fields("nro_rol").Value
                Err.numError = rs.Fields("numError").Value
                Err.titulo = rs.Fields("titulo").Value
                Err.mensaje = rs.Fields("mensaje").Value
                Err.comentario = rs.Fields("comentario").Value
                Err.params.Add("nro_entidad", nro_entidad)
                'Err.params.Add("nro_rol", nro_rol)
            End If
        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar el rol"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "entidad_abm.aspx"
        End Try

        Err.response()
    End If

    Me.contents("permisos_entidades") = nvApp.operador.permisos("permisos_entidades")
    'Me.contents("permisos") = nvApp.operador.permisos("permisos_roles")
    Me.contents("nro_entidad") = nro_entidad
    'Me.contents("nro_rol") = nro_rol

    'Me.contents("filtroXMLEntidad") = "<criterio><select vista='verEntidades'><campos>nro_entidad,rol_desc,razon_social,abreviacion,calle,postal,localidad,telefono,email,cuit,car_tel,nro_docu,tipo_docu,sexo,apellido,nombres,alias,persona_fisica</campos><orden></orden><filtro><nro_entidad type='igual'>" &
    '                                        nro_entidad & "</nro_entidad>" & "</filtro></select></criterio>"
    '"<nro_rol type='igual'>'" + nro_rol + "'</nro_rol>" +

    Me.contents("filtroXMLEntidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>nro_entidad,'' as rol_desc,razon_social,abreviacion,calle,postal,localidad,telefono,email,cuitcuil,cuit,car_tel,nro_docu,tipo_docu,sexo,apellido,nombres,alias,persona_fisica</campos><orden></orden><filtro></filtro></select></criterio>")
    'Me.contents("filtroverEntidadRolesParam") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadRolesParam'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    'Me.contents("filtroverParamRoles") = nvXMLSQL.encXMLSQL("<criterio><select vista='verParamRoles'><campos>nro_rol,rol_desc,parametro,nro_campo_tipo,obligatorio,valor_defecto,campo_def,etiqueta,param_orden,id_rol_param</campos><orden>param_orden</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroEntidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    'Me.contents("filtroverEntidad_roles") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_roles'><campos>rol_desc</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroVerEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>cuit</campos><orden>cuit</orden><filtro></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_entidades")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Entidad ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var vButtonItems            = []
        vButtonItems[0]             = []
        vButtonItems[0]["nombre"]   = "LocalidadSel";
        vButtonItems[0]["etiqueta"] = "...";
        vButtonItems[0]["imagen"]   = "";
        vButtonItems[0]["onclick"]  = "return selLocalidad()";

        var vListButton             = new tListButton(vButtonItems, 'vListButton');
        var win
        var nro_rol                 = nvFW.pageContents.nro_rol;
        var rol_desc
        var nro_entidad             = nvFW.pageContents.nro_entidad;
        //var permisos_entidades      = nvFW.pageContents.permisos_entidades;
        var roles                   = []
        var permiso                 = ''
        var nro_dist_tipo           = ''

        // Variables de elementos a cachear
        var $body
        var $nro_entidad
        var $razon_social
        var $abreviacion
        var $alias
        var $calle
        var $localidad
        var $car_tel
        var $telefono
        var $email
        var $cuit
        var $cuitcuil
        var $apellido
        var $nombres
        var $nro_docu
        var $frame_comentarios
        var $divMenuABMEntidades
        var $divDatosPersonales
        var $divComentarioParametros
        var $tbComentarioParametros
        var $datos_pjuridica
        var $datos_pfisica
        var $sexo
        var $persona_fisica
        var $modo
        var $postal
        var $sexo


        function window_onload()
        {
            vListButton.MostrarListButton()
            //permisos()

            cachearElementos()

            $nro_entidad.value = nro_entidad;
            
            if ($nro_entidad.value != '') {
                CargarDatos($nro_entidad.value)
                $modo.value = 'M'
            }
            else {
                entidad_nueva()
                $modo.value = 'A'
            }

            window_onresize()
        }


        function cachearElementos()
        {
            $body                    = $$('BODY')[0]
            $nro_entidad             = $('nro_entidad')
            $razon_social            = $('razon_social')
            $abreviacion             = $('abreviacion')
            $alias                   = $('alias')
            $calle                   = $('calle')
            $localidad               = $('localidad')
            $car_tel                 = $('car_tel')
            $telefono                = $('telefono')
            $email                   = $('email')
            $cuit                    = $('cuit')
            $cuitcuil                = $('cuitcuil')
            $apellido                = $('apellido')
            $nombres                 = $('nombres')
            $nro_docu                = $('nro_docu')
            $frame_comentarios       = $('frame_comentarios')
            $divMenuABMEntidades     = $('divMenuABMEntidades')
            $divDatosPersonales      = $('divDatosPersonales')
            $divComentarioParametros = $('divComentarioParametros')
            $tbComentarioParametros  = $('tbComentarioParametros')
            $datos_pjuridica         = $('datos_pjuridica')
            $datos_pfisica           = $('datos_pfisica')
            $persona_fisica          = $('persona_fisica')
            $modo                    = $('modo')
            $postal                  = $('postal')
            $sexo                    = $('sexo')
        }


        //function permisos() {
        //    //if ($('nro_rol').value != "") {
        //    //    switch ($('nro_rol').value) {
        //    //        //Cliente      
        //    //        case '1':
        //    //            permiso = nvFW.pageContents.permisos_roles;
        //    //            nro_dist_tipo = 1;
        //    //            break;
        //    //    }
        //    //}
        //}


        function window_onresize()
        {
            try {
                let body_h                            = $body.getHeight();
                let divMenuABMEntidades_h             = $divMenuABMEntidades.getHeight();
                let divDatosPersonales_h              = $divDatosPersonales.getHeight();
                let divComentarioParametros_h         = body_h - divMenuABMEntidades_h - divDatosPersonales_h

                $divComentarioParametros.style.height = divComentarioParametros_h + 'px'
                $tbComentarioParametros.style.height  = divComentarioParametros_h + 'px'

                //var tabla_estado_h = $('tabla_estado').getHeight();
                //$('div_datos_roles').setStyle({ height: (div_comentario_parametros_h - tabla_estado_h) });

                //$('td_estado_parametros').setStyle({ height: div_comentario_parametros_h });
                /*var dif = Prototype.Browser.IE ? 5 : 2
                var height_body = (height_div_filtro_datos < 450) ? 450 : height_div_filtro_datos;
                var height_div_comentario_parametros = $divComentarioParametros.getHeight();
                height_div_comentario_parametros = 200
                var tabla_estado = $('tabla_estado').getHeight();
                var height_div_datos_roles = height_div_comentario_parametros - tabla_estado;

                var tamanio = height_body - height_div_datos_roles
                $('div_datos_roles').setStyle({ height: height_div_datos_roles });
                $('td_estado_parametros').setStyle({ height: height_div_comentario_parametros });
                $divComentarioParametros.setStyle({ height: height_div_comentario_parametros });

                var height_div_filtro_datos = $divMenuABMEntidades.getHeight() + $divDatosPersonales.getHeight() + height_div_comentario_parametros;
                
                parent.win.setSize($$('body')[0].getWidth(), height_body);*/
            }
            catch (e) {}
        }


        function entidad_nueva()
        {
            $nro_entidad.value     = ''
            $razon_social.value    = ''
            $abreviacion.value     = ''
            $alias.value           = ''
            $calle.value           = ''
            $localidad.value       = ''
            $car_tel.value         = ''
            $telefono.value        = ''
            $email.value           = ''
            $cuit.value            = ''
            $cuitcuil.value        = 'CUIL'
            $apellido.value        = ''
            $nombres.value         = ''
            $nro_docu.value        = ''
            //$('nro_dist').value = 0
            campos_defs.clear('tipo_docu')
            //campos_defs.clear('fe_alta')
            //campos_defs.clear('nro_rol_estado')
            //campos_defs.clear('fe_estado')
            decidir_tabla('0')
            //buscar_param_roles()
            $frame_comentarios.src = "/FW/enBlanco.htm"
        }

        function decidir_tabla(opcion) {
            switch (opcion) {
                case "0": //Si es persona jurídica
                    $datos_pjuridica.show()
                    $datos_pfisica.hide()
                    break
                case "1": //Si es persona física
                    $datos_pjuridica.hide()
                    $datos_pfisica.show()
                    break
                default:
                    $datos_pjuridica.hide()
                    $datos_pfisica.hide()
            }
        }

        function CargarDatos(nro_entidad)
        {
            var rs        = new tRS();
            rs.async      = true
            rs.onComplete = function (rs) {
                if (!rs.eof()) {
                    $nro_entidad.value  = rs.getdata('nro_entidad')
                    $razon_social.value = !rs.getdata('razon_social') ? "" : rs.getdata('razon_social')
                    $abreviacion.value  = !rs.getdata('abreviacion') ? "" : rs.getdata('abreviacion') 
                    $calle.value        = !rs.getdata('calle') ? "" : rs.getdata('calle')
                    $postal.value       = !rs.getdata('postal') ? "" : rs.getdata('postal')
                    $telefono.value     = !rs.getdata('telefono') ? "" : rs.getdata('telefono')
                    $email.value        = !rs.getdata('email') ? "" : rs.getdata('email')
                    $cuit.value         = !rs.getdata('cuit') ? "" : rs.getdata('cuit')
                    $cuitcuil.value     = !rs.getdata('cuitcuil') ? "" : rs.getdata('cuitcuil')
                    $localidad.value    = rs.getdata('localidad') ? rs.getdata('localidad') : "";
                    $car_tel.value      = rs.getdata('car_tel') ? rs.getdata('car_tel') : "";
                    $alias.value        = (rs.getdata('alias') != null) ? rs.getdata('alias') : ''
                    
                    //$('rol_desc').value = rs.getdata('rol_desc') ? rs.getdata('rol_desc') : "Sin Rol";

                    if (rs.getdata("persona_fisica") == "True") {
                        //$persona_fisica.selectedIndex = 1
                        $persona_fisica.value = "1"
                        $nro_docu.value       = (rs.getdata('nro_docu') != null) ? rs.getdata('nro_docu') : ''
                        $apellido.value       = rs.getdata('apellido')
                        $nombres.value        = rs.getdata('nombres')
                        var tipo_docu_p       = (rs.getdata("tipo_docu") != null) ? rs.getdata("tipo_docu") : ''
                        $sexo.value           = (rs.getdata('sexo') != null) ? rs.getdata('sexo') : ''

                        campos_defs.set_value("tipo_docu", tipo_docu_p)
                        decidir_tabla('1')
                    }
                    else {
                        $persona_fisica.value = "0"
                        decidir_tabla('0')
                    }
                }
                
                VerComentarios()

                //No tiene permiso para editar datos de la Entidad
                //permisos_entidades = 99;
                
                //if ((permisos_entidades & 1) <= 0) {
                if (!nvFW.tienePermiso("permisos_entidades", 1)) {
                    $cuit.disabled           = true
                    $cuitcuil.disabled       = true
                    $persona_fisica.disabled = true
                    $apellido.disabled       = true
                    $nombres.disabled        = true
                    $sexo.disabled           = true
                    campos_defs.habilitar('tipo_docu', false)
                    $nro_docu.disabled       = true
                    $abreviacion.disabled    = true
                    $alias.disabled          = true
                    $calle.disabled          = true
                    $localidad.disabled      = true
                    $('divLocalidadSel').hide()
                    $car_tel.disabled        = true
                    $telefono.disabled       = true
                    $email.disabled          = true
                }
            }
            
            //var consultaXML =   
            //var parametros = "<criterio><params nro_entidad= '" + nro_entidad + "' /></criterio>";
           
            rs.open(nvFW.pageContents.filtroXMLEntidad, "", "<criterio><select><orden></orden><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro></select></criterio>", "", "")
        }


        function VerComentarios()
        {
            ObtenerVentana('frame_comentarios').location.href = '/fw/comentario/verCom_registro.aspx?nro_entidad=' + $nro_entidad.value +
                                                                '&nro_com_id_tipo=1&collapsed_fck=1&do_zoom=0' +
                                                                '&id_tipo=' + $nro_entidad.value + '&nro_com_grupo=1'
        }

        //function buscar_entidad_roles_param(nro_entidad, nro_rol) {
            
        //    if ((nro_entidad != '') && (nro_rol != '')) {
        //        var filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"

        //        roles = new Array()
        //        var k = 0
        //        var rs = new tRS();
        //        var vacio
        //        rs.async = true
                
        //        rs.onComplete = function (rs) {
                    
        //            if (!rs.eof()) {
        //                $('fe_alta').value = (rs.getdata('fe_alta') != null) ? isNULL_NaN(FechaToSTR(parseFecha(isNULL(rs.getdata('fe_alta'), ''))), '') : '';
        //                campos_defs.set_value("nro_rol_estado", rs.getdata("nro_rol_estado"))
        //                $('fe_estado').value = (rs.getdata('fe_estado') != null) ? isNULL_NaN(FechaToSTR(parseFecha(isNULL(rs.getdata('fe_estado'), ''))), '') : '';
                        
        //                $('id_ent_rol').value = (rs.getdata('id_ent_rol') != null) ? rs.getdata('id_ent_rol') : ''
        //            }
        //            while (!rs.eof()) {
        //                vacio = new Array()
                        
        //                vacio['nro_rol'] = rs.getdata('nro_rol')
        //                vacio['rol_desc'] = rs.getdata('rol_desc')
        //                vacio['parametro'] = rs.getdata('parametro')
        //                vacio['nro_campo_tipo'] = rs.getdata('nro_campo_tipo')
        //                vacio['obligatorio'] = rs.getdata('obligatorio')
        //                vacio['valor_defecto'] = rs.getdata('valor_defecto')
        //                vacio['campo_def'] = rs.getdata('campo_def')
        //                vacio['etiqueta'] = rs.getdata('etiqueta')
        //                vacio['param_orden'] = rs.getdata('param_orden')
        //                vacio['id_rol_param'] = rs.getdata('id_rol_param')
        //                vacio['valor'] = (rs.getdata('valor') != null) ? rs.getdata('valor') : '';

        //                roles[k] = vacio
        //                k++
        //                rs.movenext()
        //            }
        //            if ((roles.length > 1) || ((roles.length == 1) && ((roles[0]['parametro'] != null) || (roles[0]['campo_def'] != null)))) {
        //                roles_dibujar('edicion')
        //            }

        //            //No tiene permiso para editar el estado de una Entidad
        //            if ((permiso & 1) <= 0) {
        //                campos_defs.habilitar('fe_alta', false)
        //                campos_defs.habilitar('nro_rol_estado', false)
        //                campos_defs.habilitar('fe_estado', false)
        //            }

        //        }
                
                
        //        rs.open(nvFW.pageContents.filtroverEntidadRolesParam,"","<criterio><select><orden>param_orden</orden><filtro><nro_rol type='igual'>" + nro_rol + "</nro_rol>" + filtro + "</filtro></select></criterio>","","")
        //    }
        //}

        //function roles_dibujar(accion) {

        //    if (roles.length > 0) {
        //        $('div_datos_roles').innerHTML = ''
        //        var strHTML = '<table id="div_datos_roles" class="tb1" style="width:100%; vertical-align: top;">'

        //        roles.each(function (arreglo, i) {
        //            obligatorio = (arreglo['obligatorio'] == "True") ? '*' : '';
        //            strHTML += '<tr>'
        //            strHTML += '<td class="Tit1" style="width:35%;text-align:right"><b>' + arreglo['etiqueta'] + obligatorio + '</b></td>'
        //            strHTML += '<td style="text-align:left" id="td_' + arreglo["parametro"] + '"></td>'
        //            strHTML += '</tr>'
        //        });
        //        strHTML += '</table>'
        //        $('div_datos_roles').insert({ top: strHTML })

        //        roles.each(function (arreglo, i) {

        //            if (arreglo['campo_def'] != null) {
        //                campos_defs.add(arreglo["campo_def"], { target: 'td_' + arreglo["parametro"] })
        //                if (accion == 'alta')
        //                    campos_defs.set_value(arreglo["campo_def"], arreglo["valor_defecto"])
        //                else {
        //                    campos_defs.set_value(arreglo["campo_def"], arreglo["valor"])
        //                    //No tiene permiso para editar los parámetros de una Entidad
        //                    if ((permiso & 2) <= 0) {
        //                        campos_defs.habilitar(arreglo["campo_def"], false)
        //                    }
        //                }
        //            } else if (arreglo['parametro'] != null) {
        //                campos_defs.add(arreglo["parametro"], { enDB: false, target: 'td_' + arreglo["parametro"], nro_campo_tipo: arreglo["nro_campo_tipo"] })
        //                if (accion == 'alta')
        //                    campos_defs.set_value(arreglo["parametro"], arreglo["valor_defecto"])
        //                else {
        //                    campos_defs.set_value(arreglo["parametro"], arreglo["valor"])
        //                    //No tiene permiso para editar los parámetros de una Entidad
        //                    if ((permiso & 2) <= 0) {
        //                        campos_defs.habilitar(arreglo["parametro"], false)
        //                    }
        //                }
        //            }
        //        });
        //    }
        //    campos_defs.habilitar('fe_alta')
        //    campos_defs.habilitar('fe_estado')
        //}

        //function buscar_param_roles() {
            
        //    nro_rol = $('nro_rol').value
        //    if (nro_rol != '') {
        //        rol_desc = ''

        //        roles = new Array()
        //        var k = 0
        //        var rs = new tRS();
        //        var vacio
        //        rs.open(nvFW.pageContents.filtroverParamRoles, "", "<criterio><select><campos></campos><orden>param_orden</orden><filtro><nro_rol type='igual'>" + nro_rol + "</nro_rol></filtro></select></criterio>", "", "")

        //        if (!rs.eof()) {
        //            rol_desc = rs.getdata('rol_desc')
        //        }
        //        while (!rs.eof()) {
        //            vacio = new Array()
        //            vacio['nro_rol'] = rs.getdata('nro_rol')
        //            vacio['rol_desc'] = rs.getdata('rol_desc')
        //            vacio['parametro'] = rs.getdata('parametro')
        //            vacio['nro_campo_tipo'] = rs.getdata('nro_campo_tipo')
        //            vacio['obligatorio'] = rs.getdata('obligatorio')
        //            vacio['valor_defecto'] = rs.getdata('valor_defecto')
        //            vacio['campo_def'] = rs.getdata('campo_def')
        //            vacio['etiqueta'] = rs.getdata('etiqueta')
        //            vacio['param_orden'] = rs.getdata('param_orden')
        //            vacio['id_rol_param'] = rs.getdata('id_rol_param')
        //            vacio['valor'] = ''

        //            roles[k] = vacio
        //            k++
        //            rs.movenext()
        //        }
        //        if ((roles.length > 1) || ((roles.length == 1) && ((roles[0]['parametro'] != null) || (roles[0]['campo_def'] != null)))) {
        //            roles_dibujar('alta')
        //        }
        //    }
        //}

        function Cerrar_Ventanas() {
            window.top.Windows.getFocusedWindow().close()
        }

        function ver(alertError) {
            alertError.close()
            winActualizar.close()
        }

        function window_onunload() {
            var a                     = []
            a["razon_social"]         = $razon_social.value
            a["modo"]                 = $modo.value
            window.parent.returnValue = a
        }


        var res = []

        // Seleccionar la Localidad
        function selLocalidad()
        {
            win = nvFW.createWindow({
                url:            '/fw/funciones/localidad_consultar.aspx',
                title:          '<b>Seleccionar Localidad</b>',
                minimizable:    false,
                maximizable:    false,
                draggable:      false,
                width:          600,
                height:         350,
                destroyOnClose: true,
                onClose:        selLocalidad_return
            });

            win.options.userData = {}
            win.showCenter(true)
        }

        function selLocalidad_return()
        {
            if (win.options.userData.res) {
                try {
                    var res          = win.options.userData.res
                    $postal.value    = res.postal
                    $localidad.value = res.desc
                    $car_tel.value   = res.car_tel
                }
                catch (e) {}
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

        
        var win_entidad_seleccion
        
        function validarCUIT()
        {
            var str    = ''
            var accion = ''
            var filtro = ''
            var cuit   = trim($cuit.value)
            var msj    = ''

            //if (($cuit.value.length > 0) && ($cuit.value.length != 11)) {
            if (!validarFormatoCUIT(cuit)) {
                if (cuit != "")
                    alert('El cuit ingresado puede ser inválido.')
            }
            else {
                var rs      = new tRS();
                nro_entidad = $nro_entidad.value
                accion      = (($nro_entidad.value != '') && ($nro_entidad.value != '0')) ? 'edicion' : 'alta'

                rs.open(nvFW.pageContents.filtroEntidades, "", "<criterio><select><campos></campos><orden></orden><filtro><cuit type='like'>" + cuit + "</cuit></filtro></select></criterio>", "", "")
                
                if (rs.recordcount >= 1) {
                    while (!rs.eof()) {
                        if (nro_entidad != rs.getdata('nro_entidad')) {
                            if (msj == '') {
                                msj = 'Existen las siguientes entidades con el CUIT ingresado:</br>'
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            }
                            else {
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            }
                        }
                        rs.movenext()
                    }

                    if ((accion == 'edicion') && (msj != '')) {
                        alert(msj);
                        return
                    }

                    if (accion == 'alta') {
                        //win_entidad_seleccion = new Window({ className: 'alphacube',
                        win_entidad_seleccion = nvFW.createWindow({
                            url:            'entidad_seleccion.aspx?cuit=' + cuit + '&nro_entidad=' + nro_entidad + '&id_ventana=' + window.top.win.content.id,
                            title:          '<b>Selector de Entidades</b>',
                            minimizable:    true,
                            maximizable:    false,
                            draggable:      false,
                            width:          400,
                            height:         200,
                            resizable:      false,
                            destroyOnClose: true,
                            onClose:        recuperar_entidad
                        });

                        //win_entidad_seleccion.setURL('rol_seleccion.asp?cuit='+trim($cuit.value) + '&nro_entidad='+nro_entidad + '&id_ventana=' + window.top.win.content.id) 
                        win_entidad_seleccion.showCenter(true)
                    }
                }
            }
        }

        function recuperar_entidad(nro_entidad) {
            
            if (nro_entidad != '') {
                CargarDatos(nro_entidad)

                //if ($('nro_rol').value != '') {
                //    filtro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"
                //    var rs1 = new tRS();
                //    rs1.open(nvFW.pageContents.filtroverEntidad_roles,"","<criterio><select><campos></campos><orden></orden><filtro><nro_rol type='igual'>" + $('nro_rol').value + "</nro_rol>" + filtro + "</filtro></select></criterio>","","")
                    
                //    if (!rs1.eof()) {
                //        buscar_entidad_roles_param(nro_entidad, $('nro_rol').value)
                //        //str += 'La Entidad ya está asociada al rol "' + rs1.getdata('rol_desc') + '".</br>'; 
                //    } else {
                //        $('fe_alta').value = ''
                //        $('nro_rol_estado').value = ''
                //        $('fe_estado').value = ''
                //        $('id_ent_rol').value = ''

                //        roles.each(function (arreglo, i) {
                //            if (arreglo['campo_def'] != null) {
                //                campos_defs.set_value(arreglo["campo_def"], '')
                //            } else if (arreglo['parametro'] != null) {
                //                campos_defs.set_value(arreglo["parametro"], '')
                //            }
                //        });
                //    }

                //}
            }
        }

        function boton_generar_cuit()
        {
            var sexo     = $sexo.value
            var nro_docu = $nro_docu.value
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
            var sexo = $sexo.value
            var nro_docu = $nro_docu.value

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
                if (trim($cuit.value) == '') {
                    $cuit.value = v1 + str_nro_docu + digitoVerificador(v1 + str_nro_docu)
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


        function entidad_guardar()
        {
            var strError = "";
            var cuit     = trim($cuit.value)
            var cuitcuil = trim($cuitcuil.value)

            // Validar los datos
            if (cuit == "")
                strError += 'No ha cargado el "CUIT"</br>';
            else {
                var rs     = new tRS();
                var filtro = ''
                
                if ($nro_entidad.value != '')
                    filtro = "<nro_entidad type='distinto'>" + $nro_entidad.value + "</nro_entidad>"

                //rs.open("<criterio><select vista='verEntidades'><campos>cuit</campos><filtro><cuit type='igual'>" + cuit + "</cuit>" + filtro + "</filtro></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtroVerEntidades,
                    filtroWhere: "<criterio><select><filtro><cuit type='igual'>" + cuit + "</cuit>" + filtro + "</filtro></select></criterio>"
                })
                
                if (!rs.eof())
                    strError += 'Ya existe una Entidad con el CUIT ingresado</br>';
            }

            var persona_fisica = $persona_fisica.value == "1"

            if (persona_fisica) {
                if ($apellido.value == "")
                    strError += 'No ha cargado el "Apellido"</br>';
                if ($nombres.value == "")
                    strError += 'No ha cargado el "Nombre"</br>';
                if ($nro_docu.value == "")
                    strError += 'No ha cargado el "Nro.Documento"</br>';
                if ($('tipo_docu').value == "")
                    strError += 'No ha cargado el "Tipo Documento"</br>';
            }
            else {
                if ($razon_social.value == "")
                    strError += 'No ha cargado la "Razón Social"</br>';
            }

           // if ($('localidad').value == "")
             //   strError += 'No ha cargado la "Localidad"</br>';

            //roles.each(function (arreglo, i) {
            //    if (arreglo['obligatorio'] == "True") {
            //        if (arreglo['campo_def'] != null) {
            //            if ($(arreglo['campo_def']).value == "")
            //                strError += 'Debe seleccionar ' + arreglo["etiqueta"] + '</br>';
            //        } else if (arreglo['parametro'] != null) {
            //            if ($(arreglo['parametro']).value == "")
            //                strError += 'Debe ingresar ' + arreglo["etiqueta"] + '</br>';
            //        }
            //    }
            //});

            if (strError != "") {
                alert(strError);
                return
            }

            if (persona_fisica)
                $razon_social.value = $apellido.value + " " + $nombres.value

            var razon_social = '<![CDATA[' + $razon_social.value + ']]>'
            var abreviacion  = '<![CDATA[' + $abreviacion.value + ']]>'
            var apellido     = '<![CDATA[' + $apellido.value + ']]>'
            var nombres      = '<![CDATA[' + $nombres.value + ']]>'
            var alias        = '<![CDATA[' + $alias.value + ']]>'
            var calle        = '<![CDATA[' + $calle.value + ']]>'
            var email        = '<![CDATA[' + $email.value + ']]>'


            var xmldato = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            xmldato += "<pago_entidad modo = '" + $modo.value + "' nro_entidad = '" + $nro_entidad.value + "' "
            xmldato += "postal='" + $postal.value + "' telefono='" + $telefono.value + "' "
            xmldato += "cuit='" + cuit + "' "
            xmldato += "cuitcuil='" + cuitcuil + "' "

            if (persona_fisica)
                xmldato += "nro_docu='" + $nro_docu.value + "' tipo_docu='" + $('tipo_docu').value + "' sexo='" + $sexo.value + "' persona_fisica='" + $persona_fisica.value + "' "
            else
                xmldato += "nro_docu='0' tipo_docu='0' sexo='' persona_fisica='0' "

            xmldato += ">"

            if (persona_fisica) {
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


            //xmldato += "<entidad_roles id_ent_rol = '" + $('id_ent_rol').value + "' nro_entidad = '" + $('nro_entidad').value + "' nro_rol = '" + $('nro_rol').value + "' fe_alta = '" + $('fe_alta').value + "' nro_rol_estado = '" + $('nro_rol_estado').value + "' fe_estado = '" + $('fe_estado').value + "'>"
            //xmldato += "</entidad_roles>"
            //xmldato += "<roles>"
            //roles.each(function (arreglo_o, index_o) {
            //    if (arreglo_o['campo_def'] != null) {
            //        xmldato += "<rol_param_values id_ent_rol = '" + $('id_ent_rol').value + "' id_rol_param = '" + arreglo_o['id_rol_param'] + "' valor = '" + $(arreglo_o['campo_def']).value + "'/>"
            //    } else if (arreglo_o['parametro'] != null) {
            //        xmldato += "<rol_param_values id_ent_rol = '" + $('id_ent_rol').value + "' id_rol_param = '" + arreglo_o['id_rol_param'] + "' valor = '" + $(arreglo_o['parametro']).value + "'/>"
            //    }
            //});
            //xmldato += "</roles>"

            xmldato += "</pago_entidad>"
            
            nvFW.error_ajax_request('entidad_abm.aspx', {
                parameters: {
                    modo:   'M',
                    strXML: escape(xmldato)
                },
                onSuccess: function (err, transport) {
                    var nro_entidad    = err.params['nro_entidad']
                    //var nro_rol = err.params['nro_rol']
                    var ventana_actual = window.top.Windows.getFocusedWindow()
                    var params         = []

                    params['nro_entidad'] = nro_entidad
                    //params['nro_rol'] = nro_rol

                    ventana_actual.options.userData = {
                        modificacion: true,
                        recargar:     true
                    }
                    ventana_actual.returnValue      = params
                    ventana_actual.close()
                },
                error_alert: true,
                bloq_msg: "Guardando..."
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <form action="entidad_abm.aspx" method="post" name="form1" target="frmEnviar">
        <input type="hidden" name="modo" value="<% = modo %>" id="modo" />
        <input type="hidden" name="nro_entidad" id="nro_entidad" value="<% = nro_entidad %>" />
        <%--<input type="hidden" name="nro_rol" id="nro_rol" value="<%= nro_rol %>" />--%>
        <%--<input type="hidden" name="id_ent_rol" id="id_ent_rol" value="" />--%>
        <input type="hidden" name="strXML" value="" />

        <div id="divFiltroDatos" style="width: 100%; height: 97%; overflow: hidden;">
            <input type="hidden" name="postal" id="postal" value="" />
            <div id="divMenuABMEntidades"></div>

            <script type="text/javascript" language="javascript">
                //var DocumentMNG = new tDMOffLine;
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
                vMenuABMEntidades.MostrarMenu()
            </script>

            <div id="divDatosPersonales" style="width: 100%; height: auto;">
                <table class="tb1">
                    <tr>
                        <td style="width: 25%">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td style="width: 30%"><b>TIPO</b></td>
                                    <td style="width: 70%"><b>CUIT / CUIL *</b></td>
                                </tr>
                                <tr>
                                    <td>
                                        <select id="cuitcuil" style="width: 100%;">
                                            <option value="CUIL" selected="selected">CUIL</option>
                                            <option value="CUIT">CUIT</option>
                                        </select>
                                    </td>
                                    <td>
                                        <input style="width: 100%; text-align: right" maxlength="11" type="text" name="cuit" id="cuit" value="" onkeypress="return valDigito(event)" onchange="validarCUIT()" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 10%">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td style="width: 100%"><b>Tipo entidad</b></td>
                                </tr>
                                <tr>
                                    <td>
                                        <select name="persona_fisica" id="persona_fisica" onchange="decidir_tabla(this.value)" style="width: 100%;">
                                            <option value="0" selected="selected">Persona Jurídica</option>
                                            <option value="1">Persona Física</option>
                                        </select>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 65%">
                            <table class="tb1" id="datos_pfisica" style='display: none; width: 100%'>
                                <tr class="tbLabel">
                                    <td style="width: 30%"><b>Apellido *</b></td>
                                    <td style="width: 30%"><b>Nombres *</b></td>
                                    <td style="width: 10%"><b>Sexo *</b></td>
                                    <td style="width: 14%"><b>Tipo *</b></td>
                                    <td style="width: 16%"><b>Nro. Doc. *</b></td>
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
                                            <option value="M">MASCULINO</option>
                                            <option value="F">FEMENINO</option>
                                        </select>
                                    </td>
                                    <td>
                                        <% = nvFW.nvCampo_def.get_html_input("tipo_docu") %>
                                    </td>
                                    <td>
                                        <input type="text" name="nro_docu" id="nro_docu" maxlength="8" value="" style="width: 100%; text-align: right;" onchange="generarCUIT()" onkeypress="return valDigito(event)" />
                                    </td>
                                </tr>
                            </table>
                            <table class="tb1" id="datos_pjuridica" style="width: 100% !Important">
                                <tr class="tbLabel">
                                    <td style="width: 100%"><b>Razón Social *</b></td>
                                </tr>
                                <tr>
                                    <td style="width: 100%">
                                        <input type="text" name="razon_social" id="razon_social" value="" style="width: 100%" maxlength="200" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 15%"><b>Abreviación</b></td>
                        <td style="width: 15%"><b>Alias</b></td>
                        <td style="width: 15%"><b>Dirección</b></td>
                        <td style="width: 40%" colspan="2"><b>Localidad</b></td>
                        <td style="width: 15%"><b>Teléfono</b></td>
                    </tr>
                    <tr>
                        <td style="width: 15%">
                            <input type="text" name="abreviacion" id="abreviacion" value="" style="width: 100%" maxlength="50" />
                        </td>
                        <td style="width: 15%">
                            <input type="text" name="alias" id="alias" value="" style="width: 100%" maxlength="200" />
                        </td>
                        <td style="width: 15%">
                            <input type="text" name="calle" id="calle" value="" style="width: 100%" maxlength="50" />
                        </td>
                        <td style="width: 30%">
                            <input name="localidad" id="localidad" style="width: 100%" ondblclick="selLocalidad()" readonly="readonly" />
                        </td>
                        <td style="width: 10%">
                            <div id="divLocalidadSel" style="width: 100%"></div>
                        </td>
                        <td style="width: 15%">
                            <input type="text" name="car_tel" id="car_tel" value="" readonly="readonly" style="width: 28%" /><input type="text" name="telefono" id="telefono" value="" style="width: 70%" />
                        </td>
                    </tr>
                </table>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 100%"><b>E-mail</b></td>
                        <%--<td style="width: 25%">
                            <b>Rol</b>
                        </td>--%>
                    </tr>
                    <tr>
                        <td style="width: 100%">
                            <input type="text" name="email" id="email" style="width: 100%" value="" maxlength="255" />
                        </td>
                        <%--<td style="width: 25%">
                            <input type="text" disabled id="rol_desc" style="width:95%"/>
                        </td>--%>
                    </tr>
                </table>
            </div>

            <div id="divComentarioParametros" style="width: 100%; height: auto;">
                <table class="tb1" id="tbComentarioParametros" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 100%; vertical-align: top;" id="td_frame_comentarios">
                            <iframe name="frame_comentarios" id="frame_comentarios" style="width: 100%; height: 100%; overflow: hidden; border: none;"></iframe>
                        </td>
                       <%-- <td id="td_estado_parametros" style="width: 30%; vertical-align: top;">
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
                        </td>--%>
                    </tr>
                </table>
            </div>
            <%--<iframe name="frmEnviar" style="display: none" src="/FW/enBlanco.htm"></iframe>--%>
        </div>
    </form>
</body>
</html>
