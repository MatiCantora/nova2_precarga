<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim Err As New tError()

    ' Debe tener el permiso para ver o editar
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    If Not op.tienePermiso("permisos_seguridad", 1) Then
        Err.numError = -1
        Err.titulo = "No se pudo completar la operación. "
        Err.mensaje = "No tiene permisos para ver el sistema."
        Err.response()
    End If

    'Me.contents("permisos_seguridad") = op.permisos("permisos_seguridad")

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim vista As String = nvFW.nvUtiles.obtenerValor("vista", "O") '// O: operadores , P: perfiles

    If accion = "perfil_abm" Then
        Dim tipo_operador As Int32 = nvFW.nvUtiles.obtenerValor("tipo_operador", "")
        Dim tipo_operador_desc As String = nvFW.nvUtiles.obtenerValor("tipo_operador_desc", "")
        Dim tipo_operador_hereda As Integer = IIf(nvFW.nvUtiles.obtenerValor("tipo_operador_hereda", "") = "", 0, nvFW.nvUtiles.obtenerValor("tipo_operador_hereda", ""))

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_perfil_ABM", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@tipo_operador", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , tipo_operador)
        cmd.addParameter("@tipo_operador_desc", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, tipo_operador_desc.Length, tipo_operador_desc)
        cmd.addParameter("@tipo_operador_hereda", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , tipo_operador_hereda)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()

            Err.numError = rs.Fields("numError").Value
            Err.mensaje = rs.Fields("mensaje").Value
            Err.titulo = rs.Fields("titulo").Value
            Err.debug_desc = rs.Fields("debug_desc").Value
            Err.debug_src = rs.Fields("debug_src").Value

            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.numError = -1
            Err.titulo = "Abm perfil"
            Err.mensaje = "Error inesperado"
            Err.debug_desc = ex.Message
            Err.debug_src = "FW_perfil_ABM"
        End Try

        Err.response()
    End If

    Me.contents("filtroImprimirOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroImprimirOperador_accesos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='FW_Permisos_verOperadores_accesos'><campos>*</campos><filtro><Permitir type='distinto'>'No utilizado'</Permitir><path type='distinto'>'No Asignado'</path></filtro><orden></orden></select></criterio>")
    Me.contents("filtroverOperadores_operador_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroImprimirPerfil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='FW_Permisos_verPerfiles_accesos'><campos>*</campos><filtro><Permitir type='distinto'>'No utilizado'</Permitir><path type='distinto'>'No Asignado'</path></filtro><orden></orden></select></criterio>")
    Me.contents("filtroTipoOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>distinct tipo_operador as id, tipo_operador_desc as [campo]</campos><orden>[campo]</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroPermisoGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo]</campos><orden>[campo]</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroNroPermiso") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id, Permitir as [campo]</campos><orden>[campo]</orden><filtro><Permitir type='distinto'>'No utilizado'</Permitir></filtro></select></criterio>")

    ' Permisos
    Me.addPermisoGrupo("permisos_seguridad")
%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Operadores</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        // Botones
        var vButtonItems = []
        
        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Boton_Buscar"
        vButtonItems[0]["etiqueta"] = "Buscar"
        vButtonItems[0]["imagen"]   = "buscar"
        vButtonItems[0]["onclick"]  = "return buscar()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"]   = "btnAceptar"
        vButtonItems[1]["etiqueta"] = "Aceptar"
        vButtonItems[1]["imagen"]   = ""
        vButtonItems[1]["onclick"]  = "return perfil_guardar()";

        vButtonItems[2] = []
        vButtonItems[2]["nombre"]   = "btnCancelar"
        vButtonItems[2]["etiqueta"] = "Cancelar"
        vButtonItems[2]["imagen"]   = ""
        vButtonItems[2]["onclick"]  = "return perfil_cancelar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/fw/image/security/buscar.png')

        var $login


        function window_onload() 
        {
            // Cache del elemento 'login' que es frecuentemente utilizado
            $login = $('login')

            // Mostrar botones creados
            vListButtons.MostrarListButton()
            operador_tipo_estado_on_change()
            window_onresize()

            $('operador').observe('keypress', function (e) { campo_onkeypress(e) })
            $login.observe('keypress',        function (e) { campo_onkeypress(e) })
            $('apellido').observe('keypress', function (e) { campo_onkeypress(e) })
            $('nombres').observe('keypress',  function (e) { campo_onkeypress(e) })
            $('path').observe('keypress',     function (e) { campo_onkeypress(e) })
            $('nro_docu').observe('keypress', function (e) { campo_onkeypress(e) })

            $login.focus()
        }


        function validar(filtro)
        {
            var strError = ''
            return strError
        }


        function obtenerFiltroLogin(campo, valor)
        {
            var str = ''

            if ($login.value.match(/\,/))
                str = "<" + campo + " type='in'>'" + replace(valor, ",", "','") + "'</" + campo + ">"
            else
                str = "<" + campo + " type='like'>%" + valor + "%" + "</" + campo + ">"

            return str
        }


        var cadena_filtro = ''

        function buscar(accion)
        {
            if (!accion)
                accion = 'pantalla'

            cadena_filtro = ''

            if ($login.value != '')
                cadena_filtro += obtenerFiltroLogin('login', $login.value)

            if ($('operador').value != '')
                cadena_filtro += "<operador type='in'>" + $('operador').value + "</operador>"

            if ($('nro_docu').value != '')
                cadena_filtro += "<nro_docu type='in'>" + $('nro_docu').value + "</nro_docu>"

            if ($('apellido').value != '')
                cadena_filtro += "<apellido type='like'>%" + $('apellido').value + "%</apellido>"

            if ($('nombres').value != '')
                cadena_filtro += "<nombres type='like'>%" + $('nombres').value + "%</nombres>"

            if ($('path').value != '')
                cadena_filtro += "<path type='like'>%" + $('path').value + "%</path>"

            if ($('tiene_permiso').value != '')
                cadena_filtro += "<tiene_permiso type='igual'>" + $('tiene_permiso').value + "</tiene_permiso>"

            cadena_filtro += campos_defs.filtroWhere()

            if (campos_defs.get_value('tipo_operador') != '') {
                cadena_filtro += "<tipo_operador_desc type='like'>%"+ campos_defs.get_value('tipo_operador')  +"%</tipo_operador_desc>"

            }

            var strError = validar(cadena_filtro)
            
            if (strError != '') {
                alert(strError)
                return
            }

            var filtroXML         = ""
            var path_reporte      = ""
            var filename          = ""
            var val_consulta_tipo = $('consulta_tipo').value
            var msg_bloqueo       = ''

            if (val_consulta_tipo == 'AOP' || val_consulta_tipo == 'APO') {
                if ($('operador_tipo_estado').value != 'TODOS')
                    cadena_filtro += "<estado type='in'>'" + $('operador_tipo_estado').value + "'</estado>"

                path_xsl    = "report\\security\\FW_Operadores_Perfiles\\HTML_verOperadores_asociados_Perfiles.xsl"
                filename    = 'Operadores Asociados a Perfiles.xls'
                msg_bloqueo = 'Cargando Operadores asociados a perfiles...'

                if (val_consulta_tipo == 'APO') {
                    cadena_filtro += "<NOT><tipo_operador type='isnull'/></NOT>"
                    path_xsl       = "report\\security\\FW_Operadores_Perfiles\\HTML_verPerfiles_asociados_operadores.xsl"
                    filename       = 'Perfiles Asociados a Operadores.xls'
                    msg_bloqueo    = 'Cargando Perfiles asociados a operadores...'
                }

                filtroXML = nvFW.pageContents.filtroverOperadores_operador_tipo
            }

            if (val_consulta_tipo == 'APP') {
                path_xsl     = "report\\security\\FW_Operadores_Perfiles\\HTML_FW_Permisos_verPerfiles_accesos_lineal.xsl"
                path_reporte = '\\report\\security\\FW_Operadores_Perfiles\\INF_fw_permisos_verPerfiles_accesos.rpt'
                filename     = 'Perfiles Asociados a Permisos.xls'
                filtroXML    = nvFW.pageContents.filtroImprimirPerfil
                msg_bloqueo  = 'Cargando Perfiles asociados a permisos...'
            }

            if (val_consulta_tipo == 'AOPM') {
                path_xsl     = "report\\security\\FW_Operadores_Perfiles\\HTML_FW_Permisos_verOperadores_accesos_lineal.xsl"
                path_reporte = 'report\\security\\FW_Operadores_Perfiles\\INF_fw_permisos_veroperadores_accesos.rpt'
                filename     = 'Operadores Asociados a Permisos.xls'
                filtroXML    = nvFW.pageContents.filtroImprimirOperador_accesos
                msg_bloqueo  = 'Cargando Operadores asociados a permisos...'
            }

            if (val_consulta_tipo == 'O') {
                path_xsl    = "report\\security\\FW_Operadores_Perfiles\\HTML_verOperadores_lineal.xsl"
                filtroXML   = nvFW.pageContents.filtroImprimirOperador
                filename    = "Informes Operadores"
                msg_bloqueo = 'Cargando Operadores...'
            }

            if (val_consulta_tipo == 'P') {
                path_xsl     = "report\\security\\FW_Operadores_Perfiles\\HTML_Perfil_lineal.xsl"
                filename     = 'Perfiles.xls'
                filtroXML    = nvFW.pageContents.filtroTipoOperador
                path_reporte = '\\report\\security\\FW_Operadores_Perfiles\\INF_fw_verPerfiles.rpt'
                msg_bloqueo  = 'Cargando Perfiles...'
            }

            var pagesize=""
            if (accion == 'exportar')
                PageSize = '0'
            else
                PageSize = setPageSize()

            var filtroWhere = "<criterio><select AbsolutePage='1' PageSize='" + PageSize + "' cacheControl='Session'><filtro>" + cadena_filtro + "</filtro><orden></orden></select></criterio>"

            switch (accion) {
                case 'exportar':
                    nvFW.exportarReporte({
                        filtroXML: filtroXML
                        , filtroWhere: filtroWhere
                        , path_xsl: '\\report\\excel_base.xsl'
                        , salida_tipo: "adjunto"
                        , ContentType: 'application/vnd.ms-excel'
                        , filename: filename + ".xls"
                    })
                    break

                case 'imprimir':
                    nvFW.mostrarReporte({
                        filtroXML: filtroXML
                        , filtroWhere: filtroWhere
                        , path_reporte: path_reporte
                        , salida_tipo: "adjunto"
                        , ContentType: 'application/pdf'
                        , filename: filename + ".pdf"
                        , formTarget: "_blank"
                    })
                    break

                default :
                    nvFW.exportarReporte({
                        filtroXML: filtroXML
                        , filtroWhere: filtroWhere
                        , path_xsl: path_xsl
                        , salida_tipo: "adjunto"                    
                        , formTarget: "iframeSolicitud"
                        , nvFW_mantener_origen: true
                        , bloq_contenedor: $('iframeSolicitud')
                        , cls_contenedor: "iframeSolicitud"
                        , cls_contenedor_msg: ' '
                        , bloq_msg: msg_bloqueo
                    })
            }
        }


        function setPageSize()
        {
            var pagesize = 100

            try {
                //pagesize = Math.round($('iframeSolicitud').getHeight() / $('consulta_tipo').getHeight() - 1, 0)
                pagesize = Math.round($('iframeSolicitud').getHeight() / $('consulta_tipo').getHeight() - 1)
                // restamos la cabecera y pie considero 4 el como las row de los mismos
                pagesize -= 2
            }
            catch(e) {}

            return pagesize
        }


        function imprimir_operador(operador)
        {
            var filtro = "<operador type='igual'>" + operador + "</operador>"

            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.filtroImprimirOperador_accesos
                , path_reporte: '\\report\\security\\FW_Operadores_Perfiles\\INF_fw_permisos_veroperadores_accesos.rpt'
                , filtroWhere: filtro
                , salida_tipo: "adjunto"
                , contentType: 'application/pdf'
                , filename: "infmodseg_permisos_operador.pdf"
                , formTarget: "_blank"
            })
        }


        function imprimir_perfil(nro_perfil)
        {
            var filtro = "<tipo_operador type='igual'>" + nro_perfil + "</tipo_operador>"

            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.filtroImprimirPerfil
                , path_reporte: '\\report\\security\\FW_Operadores_Perfiles\\INF_fw_permisos_verPerfiles_accesos.rpt'
                , filtroWhere: filtro
                , salida_tipo: "adjunto"
                , contentType: 'application/pdf'
                , filename: "infmodseg_permisos_perfil.pdf"
                , formTarget: "_blank"
            })
        }


		var dif = Prototype.Browser.IE ? 5 : 0

        function window_onresize()
        {
	        try {
		        var body_height = $$('BODY')[0].getHeight()
		        var cabe_height = $('cabecera').getHeight()

                $('iframeSolicitud').setStyle({ 'height': body_height - cabe_height - dif + 'px' })
            }
            catch(e) {}
        }


        function enter_onkeypress(e)
        { 
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                buscar()
        }


        function hoy()
        {
            return FechaToSTR(new Date())
        }


        var win = nvFW.getMyWindow()

        function permiso_mostrar(vista, perfil)
        {
            if (!nvFW.tienePermiso("permisos_seguridad", 3)) {
                alert('No posee los permisos necesarios para realizar esta acción')
                return
            }

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            
            win = w.createWindow({
                url: '/FW/security/permiso_abm.aspx?vista=' + vista + "&perfil="+ perfil,
                width: 900,
                height: 500,
                draggable: true,
                resizable: true,
                closable: true,
                minimizable: false,
                maximizable: false,
                title: "<b>Asignación Permisos</b>"
            })

            win.showCenter(true);
        }


        function abm_operadores(login)
        {
            if (!nvFW.tienePermiso("permisos_seguridad", 1)) {
                alert('No posee los permisos necesarios para realizar esta acción')
                return
            }

            win = top.nvFW.createWindow({
                url: '/fw/security/operador_abm.aspx',
                title: '<b>ABM Operadores</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 950,
                height: 560,
                resizable: true,
                destroyOnClose: true,
                onClose: abm_operadores_return
            });

            win.options.userData = {}
            win.options.userData.login = login
            win.showCenter(true);
        }


        function abm_operadores_return()
        {
            buscar()
        }

        var win_perfil

        function abm_perfil(tipo_operador, tipo_operador_desc)
        {
            var strHTML = ""

            win_perfil = nvFW.createWindow({
                width: 360,
                height: 190,
                draggable: false,
                resizable: false,
                closable: false,
                minimizable: false,
                maximizable: false,
                title: "<b>ABM Perfil " + tipo_operador_desc + "</b>",
                onShow: function (win) {
                    if (tipo_operador == 0) {
                        campos_defs.habilitar("tipo_operadores_h", true)
                        $('tipo_operador_abm').value = 0
                        $('tipo_operador_desc_abm').value = tipo_operador_desc
                    }
                    else {
                        $('tbtipo_operadores').hide()
                        $('tipo_operador_abm').value = tipo_operador
                        $('tipo_operador_desc_abm').value = tipo_operador_desc
                    }

                    $('tipo_operador_abm').disabled = true
                    $('tipo_operador_desc_abm').focus()
                }
            });

            win_perfil.getContent().innerHTML = $('divPerfil').innerHTML 
            win_perfil.showCenter(true);
        }


        function perfil_cancelar()
        {
            win_perfil.close()
        }


        function perfil_guardar()
        {
            if ($('tipo_operador_desc_abm').value == "") {
                alert("Ingrese la descripcion de perfil")
                return
            }

            nvFW.error_ajax_request('operador_consultar.aspx', {
                parameters: {
                    tipo_operador: $('tipo_operador_abm').value,
                    tipo_operador_desc: $('tipo_operador_desc_abm').value,
                    tipo_operador_hereda: $('tipo_operadores_h').value,
                    accion: "perfil_abm"
                },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        alert("El perfil se guardo correctamente.")
                        win_perfil.close()
                    }
                }
            });
        }


        function operador_tipo_estado_on_change()
        {
            if ($('consulta_tipo').value == 'O') {
                $('tbEstadoCab').hide()
                $('tbEstado').hide()

                $('tbFeAltaCabDesde').hide()
                $('tbFeAltaCabHasta').hide()
                $('tbFeAltaDesde').hide()
                $('tbFeAltaHasta').hide()

                $('tbFeBajaCabDesde').hide()
                $('tbFeBajaCabHasta').hide()
                $('tbFeBajaDesde').hide()
                $('tbFeBajaHasta').hide()

                $('td_tipo_operadorCab').hide()
                $('td_tipo_operador').hide()
                $('td_permiso_grupoCab').hide()
                $('td_permiso_grupo').hide()
                $('td_permiso_detalleCab').hide()
                $('td_permiso_detalle').hide()

                $('td_tiene_permisoCab').hide()
                $('td_tiene_permiso').hide()
                $('td_pathCab').hide()
                $('td_path').hide()

                $('td_operadorCab').show()
                $('td_operador').show()
                $('td_loginCab').show()
                $('td_login').show()
                $('td_apellidoCab').show()
                $('td_apellido').show()
                $('td_nro_docuCab').show()
                $('td_tipo_docuCab').show()
                $('td_nro_docu').show()
                $('td_tipo_docu').show()
                $('td_nombresCab').show()
                $('td_nombres').show()

                $('tr_cab').hide();
            }

            if ($('consulta_tipo').value == 'P') {
                $('tbFeAltaCabDesde').hide()
                $('tbFeAltaCabHasta').hide()
                $('tbFeAltaDesde').hide()
                $('tbFeAltaHasta').hide()

                $('tbFeBajaCabDesde').hide()
                $('tbFeBajaCabHasta').hide()
                $('tbFeBajaDesde').hide()
                $('tbFeBajaHasta').hide()

                $('tbEstadoCab').hide()
                $('tbEstado').hide()
                $('td_tipo_operadorCab').show()
                $('td_tipo_operador').show()
                $('td_permiso_grupoCab').hide()
                $('td_permiso_grupo').hide()
                $('td_permiso_detalleCab').hide()
                $('td_permiso_detalle').hide()

                $('td_tiene_permisoCab').hide()
                $('td_tiene_permiso').hide()
                $('td_pathCab').hide()
                $('td_path').hide()

                $('td_operadorCab').hide()
                $('td_operador').hide()
                $('td_loginCab').hide()
                $('td_login').hide()
                $('td_apellidoCab').hide()
                $('td_apellido').hide()
                $('td_nro_docuCab').hide()
                $('td_tipo_docuCab').hide()
                $('td_nro_docu').hide()
                $('td_tipo_docu').hide()
                $('td_nombresCab').hide()
                $('td_nombres').hide()

                $('tr_cab').show();
            }

            if ($('consulta_tipo').value == 'AOP' || $('consulta_tipo').value == 'APO') {
                $('tbFeAltaCabDesde').show()
                $('tbFeAltaCabHasta').show()
                $('tbFeAltaDesde').show()
                $('tbFeAltaHasta').show()

                $('tbFeBajaCabDesde').show()
                $('tbFeBajaCabHasta').show()
                $('tbFeBajaDesde').show()
                $('tbFeBajaHasta').show()

                $('tbEstadoCab').show()
                $('tbEstado').show()
                $('td_tipo_operadorCab').show()
                $('td_tipo_operador').show()
                $('td_permiso_grupoCab').hide()
                $('td_permiso_grupo').hide()
                $('td_permiso_detalleCab').hide()
                $('td_permiso_detalle').hide()

                $('td_tiene_permisoCab').hide()
                $('td_tiene_permiso').hide()
                $('td_pathCab').hide()
                $('td_path').hide()

                $('td_operadorCab').show()
                $('td_operador').show()
                $('td_loginCab').show()
                $('td_login').show()
                $('td_apellidoCab').show()
                $('td_apellido').show()
                $('td_nro_docuCab').show()
                $('td_tipo_docuCab').show()
                $('td_nro_docu').show()
                $('td_tipo_docu').show()
                $('td_nombresCab').show()
                $('td_nombres').show()

                $('tr_cab').show();
            }

            if ($('consulta_tipo').value == 'APP') {
                $('tbEstadoCab').hide()
                $('tbEstado').hide()

                $('tbFeAltaCabDesde').hide()
                $('tbFeAltaCabHasta').hide()
                $('tbFeAltaDesde').hide()
                $('tbFeAltaHasta').hide()

                $('tbFeBajaCabDesde').hide()
                $('tbFeBajaCabHasta').hide()
                $('tbFeBajaDesde').hide()
                $('tbFeBajaHasta').hide()

                $('td_tipo_operadorCab').show()
                $('td_tipo_operador').show()
                $('td_permiso_grupoCab').show()
                $('td_permiso_grupo').show()
                $('td_permiso_detalleCab').show()
                $('td_permiso_detalle').show()
                $('td_tiene_permisoCab').show()
                $('td_tiene_permiso').show()
                $('td_pathCab').show()
                $('td_path').show()

                //$('td_pathCab').show()
                //$('td_path').show()
                $('td_operadorCab').hide()
                $('td_operador').hide()
                $('td_loginCab').hide()
                $('td_login').hide()
                $('td_apellidoCab').hide()
                $('td_apellido').hide()
                $('td_nro_docuCab').hide()
                $('td_tipo_docuCab').hide()
                $('td_nro_docu').hide()
                $('td_tipo_docu').hide()
                $('td_nombresCab').hide()
                $('td_nombres').hide()

                $('tr_cab').show();
            }

            if ($('consulta_tipo').value == 'AOPM') {
                $('tbEstadoCab').hide()
                $('tbEstado').hide()

                $('tbFeAltaCabDesde').hide()
                $('tbFeAltaCabHasta').hide()
                $('tbFeAltaDesde').hide()
                $('tbFeAltaHasta').hide()

                $('tbFeBajaCabDesde').hide()
                $('tbFeBajaCabHasta').hide()
                $('tbFeBajaDesde').hide()
                $('tbFeBajaHasta').hide()

                $('td_tipo_operadorCab').hide()
                $('td_tipo_operador').hide()

                $('td_permiso_grupoCab').show()
                $('td_permiso_grupo').show()
                $('td_permiso_detalleCab').show()
                $('td_permiso_detalle').show()

                $('td_tiene_permisoCab').show()
                $('td_tiene_permiso').show()
                $('td_pathCab').show()
                $('td_path').show()

                $('td_operadorCab').show()
                $('td_operador').show()
                $('td_loginCab').show()
                $('td_login').show()
                $('td_apellidoCab').show()
                $('td_apellido').show()
                $('td_nombresCab').show()
                $('td_nombres').show()
                $('td_nro_docuCab').show()
                $('td_tipo_docuCab').show()
                $('td_nro_docu').show()
                $('td_tipo_docu').show()

                $('tr_cab').show();
            }

            campos_defs.clear()
            $('tiene_permiso').value = ""
            window_onresize()
            ObtenerVentana('iframeSolicitud').location.href = '/FW/enBlanco.htm'
        }


        function campo_onkeypress(e) 
        {
            var key = Prototype.Browser.IE ? event.keyCode : e.which

            if (key == 13)
                buscar()
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <div id="cabecera" style="width: 100%;">
        <div id="divMenuABM"></div>
        <script type="text/javascript">
            var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');

            Menus["vMenuABM"]            = vMenuABM;
            Menus["vMenuABM"].alineacion = 'centro';
            Menus["vMenuABM"].estilo     = 'A';

            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
               <% 
            if vista = "O" Then
                Response.Write(" Menus['vMenuABM'].CargarMenuItemXML('<MenuItem id=\'1\' style=\'text-align: center;\'><Lib TipoLib=\'offLine\'>DocMNG</Lib><icono>operador</icono><Desc>Nuevo Operador</Desc><Acciones><Ejecutar Tipo=\'script\'><Codigo>abm_operadores(0)</Codigo></Ejecutar></Acciones></MenuItem>')")
            Else
                Response.Write(" Menus['vMenuABM'].CargarMenuItemXML('<MenuItem id=\'2\' style=\'text-align: center;\'><Lib TipoLib=\'offLine\'>DocMNG</Lib><icono>perfil</icono><Desc>Nuevo Perfil</Desc><Acciones><Ejecutar Tipo=\'script\'><Codigo>abm_perfil(0,\'\')</Codigo></Ejecutar></Acciones></MenuItem>')")
            End If
                %>
               
            vMenuABM.loadImage("operador", '/fw/image/security/operador.png')
            vMenuABM.loadImage("perfil", '/fw/image/security/perfil.png')
            vMenuABM.loadImage("clave", '/fw/image/security/permiso.png')
            vMenuABM.loadImage("buscar", '/fw/image/security/buscar.png')

            vMenuABM.MostrarMenu()
        </script>

            <table class="tb1" cellspacing="0" cellpadding="0">
                <tr>
                    <td colspan="2">
                        <table class="tb1">
                            <tr>
                                <td class="Tit1" style="width: 20%; text-align: right;">Tipo de Visualización:&nbsp;</td>
                                <td>
                                <% 
                                    if vista = "O" Then
                                        Response.Write("<select style = 'width:100%' id='consulta_tipo' onchange='operador_tipo_estado_on_change()'>" &
                                                            "<option value='O' selected='selected'>Operadores</Option>" &
                                                            "<option value = 'AOP' > Operadores : Asociados a Perfiles</option> " &
                                                            "<option value = 'AOPM' > Operadores : Asociados a Permisos</option>" &
                                                        "</select>")
                                    Else
                                        Response.Write("<select style = 'width:100%' id='consulta_tipo' onchange='operador_tipo_estado_on_change()'>" &
                                                            "<option value='P'>Perfiles</option>" &
                                                            "<option value = 'APO' >Perfil: Asociados a Operadores</option>" &
                                                            "<option value = 'APP' >Perfil: Asociados a Permisos</option>" &
                                                        "</select>")
                                    End if
                                %>
                               
                                </td>
                                <td style="width:20%">
                                    <div id="divBoton_Buscar" style="width:100%"></div>
                                </td>
                            </tr>
                        </table>
                    </td>  
	            </tr>
                <tr>
                    <td style="width: 85%; vertical-align: top;">
	                    <table class="tb1" cellpadding="0" cellspacing="0">
                            <tr>
			                    <td style="width: 70%">
				                    <table class="tb1">
					                    <tr class="tbLabel">	
						                    <td style="width: 15%; text-align: center;" id="td_loginCab">Login</td>
                                            <td style="width: 10%; text-align: center;" id="td_operadorCab">Nro. Operador</td>
                                            <td style="width: 10%; text-align: center;" id="td_tipo_docuCab">Tipo</td>
                                            <td style="width: 10%; text-align: center;" id="td_nro_docuCab">Documento</td>
                                            <td style="width: 15%; text-align: center;" id="td_apellidoCab">Apellido</td>
                                            <td style="text-align: center;" id="td_nombresCab">Nombres</td>
					                    </tr>
					                    <tr>
                                            <td id="td_login">
							                    <script type="text/javascript">
								                    campos_defs.add('login', {
                                                        target: 'td_login',
                                                        enDB: false,
                                                        nro_campo_tipo: 104
                                                    })
							                    </script>                        
						                    </td>		
                                            <td id="td_operador">
							                    <script type="text/javascript">
								                    campos_defs.add('operador', {
                                                        target: 'td_operador',
                                                        enDB: false,
                                                        nro_campo_tipo: 101
                                                    })
							                    </script>                        
						                    </td>
                                            <td id="td_tipo_docu">
							                    <script type="text/javascript">
								                    campos_defs.add('tipo_docu', {
                                                        target: 'td_tipo_docu',
                                                        enDB: true,
                                                        nro_campo_tipo: 2
                                                    })
							                    </script>                        
						                    </td>	
                                            <td id="td_nro_docu">
							                    <script type="text/javascript">
								                    campos_defs.add('nro_docu', {
                                                        target: 'td_nro_docu',
                                                        enDB: false, 
                                                        nro_campo_tipo: 101
                                                    })
							                    </script>                        
						                    </td>	
                                            <td id="td_apellido">
							                    <script type="text/javascript">
								                    campos_defs.add('apellido', {
                                                        target: 'td_apellido',
                                                        enDB: false, 
                                                        nro_campo_tipo: 104 
                                                    })
							                    </script>                        
						                    </td>		
                                            <td id="td_nombres">
							                    <script type="text/javascript">
								                    campos_defs.add('nombres', { 
                                                        target: 'td_nombres', 
                                                        enDB: false, 
                                                        nro_campo_tipo: 104
                                                    })
							                    </script>                        
						                    </td>		
		                                </tr>
				                    </table>    
			                    </td>				
	   	                    </tr>
                            <tr id='tr_cab' style="display: none;">
			                    <td style="width:70%">
				                    <table class="tb1">
					                    <tr class="tbLabel">	
                                            <td style="width: 20%; white-space: nowrap" id="td_tipo_operadorCab">Perfil</td>
                                            <td style="width: 5%; white-space: nowrap" id="tbFeAltaCabDesde">Fe alta desde</td>
                                            <td style="width: 5%; white-space: nowrap" id="tbFeAltaCabHasta">Fe alta hasta</td>
                                            <td style="width: 5%; white-space: nowrap" id="tbFeBajaCabDesde">Fe baja desde</td>
                                            <td style="width: 5%; white-space: nowrap" id="tbFeBajaCabHasta">Fe baja hasta</td>
                                            <td style="width: 5%; white-space: nowrap" id="tbEstadoCab">Estado del perfil</td>
                                            <td style="width: 20%" id="td_pathCab">Path (Estructura de permiso)</td>
                                            <td style="width: 20%" id="td_permiso_grupoCab">Grupo</td>
                                            <td style="width: 20%" id="td_permiso_detalleCab">Permisos</td>
                                            <td style="width: 10%" id="td_tiene_permisoCab">Accesos</td>
					                    </tr>
					                    <tr>
                                            <td id="td_tipo_operador">
							                    <script type="text/javascript">
								                    campos_defs.add('tipo_operador', {
                                                        enDB: false,
                                                        target: 'td_tipo_operador',
                                                    nro_campo_tipo: 104//,
                                                    //filtroXML: nvFW.pageContents.filtroTipoOperador,
                                                    //filtroWhere: "<tipo_operador type='in'>%campo_value%</tipo_operador>"
                                                    })
                                                </script>
						                    </td>
                                            <td id="tbFeAltaDesde">
							                    <script type="text/javascript">
								                    campos_defs.add('fe_alta_desde', {
                                                        target: 'tbFeAltaDesde',
                                                        enDB: false,
                                                        nro_campo_tipo: 103, 
                                                        filtroWhere: "<fe_alta type='mas'>'%campo_value%'</fe_alta>"
                                                    })
							                    </script>                        
						                    </td>	
                                            <td id="tbFeAltaHasta">
							                    <script type="text/javascript">
								                    campos_defs.add('fe_alta_hasta', {
                                                        target: 'tbFeAltaHasta',
                                                        enDB: false,
                                                        nro_campo_tipo: 103,
                                                        filtroWhere: "<fe_alta type='menor'>dateadd(dd, 1, '%campo_value%')</fe_alta>"
                                                    })
							                    </script>                        
						                    </td>
                                            <td id="tbFeBajaDesde">
							                    <script type="text/javascript">
								                    campos_defs.add('fe_baja_desde', {
                                                        target: 'tbFeBajaDesde', 
                                                        enDB: false, 
                                                        nro_campo_tipo: 103,
                                                        filtroWhere: "<fe_baja type='mas'>'%campo_value%'</fe_baja>" 
                                                    })
							                    </script>                        
						                    </td>
                                            <td id="tbFeBajaHasta">
							                    <script type="text/javascript">
								                    campos_defs.add('fe_baja_hasta', {
                                                        target: 'tbFeBajaHasta', 
                                                        enDB: false, 
                                                        nro_campo_tipo: 103, 
                                                        filtroWhere: "<fe_baja type='menor'>dateadd(dd, 1, '%campo_value%')</fe_baja>" 
                                                    })
							                    </script>                        
						                    </td>
                                            <td id="td_path">
							                    <script type="text/javascript">
								                    campos_defs.add('path', { 
                                                        target: 'td_path', 
                                                        enDB: false, 
                                                        nro_campo_tipo: 104 
                                                    })
							                    </script>                        
						                    </td>	
                                            <td style="width: 5%; text-align: center" id="tbEstado">
                                                <select style="width: 100%" id="operador_tipo_estado">
                                                    <option value="TODOS" selected="selected"></option>
                                                    <option value="vencido">Vencido</option>
                                                    <option value="activo">Activo</option>
                                                </select>
                                            </td>
                                            <td id="td_permiso_grupo">
							                    <script type="text/javascript">
								                    campos_defs.add('nro_permiso_grupo', {
                                                        enDB: false,
                                                        target: 'td_permiso_grupo',
                                                        nro_campo_tipo: 2,
                                                        filtroXML: nvFW.pageContents.filtroPermisoGrupo,
                                                        filtroWhere: "<nro_permiso_grupo type='in'>%campo_value%</nro_permiso_grupo>"
                                                    })
                                                </script>
						                    </td>
                                            <td id="td_permiso_detalle">
							                    <script type="text/javascript">
								                    campos_defs.add('nro_permiso', {
                                                        enDB: false,
                                                        target: 'td_permiso_detalle',
                                                        nro_campo_tipo: 2,
                                                        filtroXML: nvFW.pageContents.filtroNroPermiso,
                                                        filtroWhere: "<nro_permiso type='in'>%campo_value%</nro_permiso>",
                                                        depende_de: "nro_permiso_grupo",
                                                        depende_de_campo: "nro_permiso_grupo"
                                                    })
                                                </script>
						                    </td>
                                            <td style="width: 10%; text-align: center;" id="td_tiene_permiso">
                                                <select style="width: 100%" id="tiene_permiso">
                                                    <option value="" selected="selected"></option>
                                                    <option value="1">Con Acceso</option>
                                                    <option value="0">Sin Acceso</option>
                                                </select>
                                            </td>
		                                </tr>
				                    </table>
			                    </td>
	   	                    </tr>
                        </table>
                    </td>
                </tr>
            </table>
    </div>

    <div id="divPerfil" style="width: 100%; display: none;">
        <table class="tb1" cellspacing="0" cellpadding="0">
            <tr>
                <td class="Tit1" style="text-align: center" colspan="2">Descripción</td>
            </tr>
            <tr>
                <td style="width: 10%;" id='td_tipo_operador_abm'>
                    <script type="text/javascript">
                        campos_defs.add('tipo_operador_abm', {
                            target: "td_tipo_operador_abm", 
                            enDB:           false,
                            nro_campo_tipo: 101
                        })
					</script>
                </td>
                <td id='td_tipo_operador_desc_abm'>
                    <script type="text/javascript">
                        campos_defs.add('tipo_operador_desc_abm', {
                            target: "td_tipo_operador_desc_abm", 
                            enDB:           false,
                            nro_campo_tipo: 104 
                        })
					</script>  
                </td>
            </tr>
            <tr>
                <td colspan="2">&nbsp;</td>
            </tr>
        </table>
        <table class="tb1" id="tbtipo_operadores">
            <tr>
                <td class="Tit1">Si desea puede seleccionar un perfil para heredar su estructura de permiso:</td>
            </tr>
            <tr>
                <td> 
                    <% = nvCampo_def.get_html_input("tipo_operadores_h", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='operador_tipo'><campos>DISTINCT tipo_operador AS id, tipo_operador_desc AS [campo]</campos><orden>[campo]</orden></select></criterio>") %></td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td colspan="5">&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 5%; text-align: center">&nbsp;</td>
                <td style="width: 42%; text-align: center">
                    <div id="divbtnAceptar" style="width: 100%"></div>
                </td>
                <td style="width: 5%; text-align: center">&nbsp;</td>
                <td style="text-align: center">
                    <div id="divbtnCancelar" style="width: 100%"></div>
                </td>
                <td style="width: 5%; text-align: center">&nbsp;</td>
            </tr>
        </table>
    </div>

    <iframe id="iframeSolicitud" name="iframeSolicitud" src="/FW/enBlanco.htm" style="width: 100%; height: 100%; border: none; overflow: hidden;"></iframe>

</body>
</html>