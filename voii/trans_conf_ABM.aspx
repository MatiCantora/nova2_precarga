<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_transferencia", 27)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_transferencia")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim err = New tError()
        If (Not op.tienePermiso("permisos_transferencia", 27)) Then
            err.numError = 403
            err.mensaje = "No posee permisos para realizar esta operación."
            err.debug_desc = "No posee permisos para realizar esta operación."
            err.debug_src = "trans_conf_ABM"
            err.response()
        End If

        Try
            Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("trans_conf_ABM", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            err.numError = rs.Fields("numError").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.debug_desc = rs.Fields("debug_desc").Value
            err.debug_src = rs.Fields("debug_src").Value
            err.params("id_transf_conf") = rs.Fields("id_transf_conf").Value

            nvDBUtiles.DBCloseRecordset(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
        End Try

        err.response()

    End If


    Me.contents("transf_conf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Ver_transf_conf' ><campos> [id_transf_conf],[transf_conf],[transf_conf_tipo],[transf_conf_default],[server],[port],[user],[password],[esSSL],[from],[from_title]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("param_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_def'><campos>distinct id_param as id, id_param as [campo]</campos><orden>[campo]</orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Transferencias conf ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">  

        var win = nvFW.getMyWindow()
        var modo = win.options.userData.modo
        var modificado = win.options.userData.modificado


        function window_onload() {
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            if (modo != "A") {
                campos_defs.set_value('id', win.options.userData.id_transf_conf)
                campos_defs.set_value('transf_conf', win.options.userData.trans_conf)
                campos_defs.set_value('server', win.options.userData.server)
                campos_defs.set_value('port', win.options.userData.port)
                campos_defs.set_value('user', win.options.userData.user)
                campos_defs.set_value('password', win.options.userData.password)
                campos_defs.set_value('esSSL', win.options.userData.esSSL)
                campos_defs.set_value('from', win.options.userData.from)
                campos_defs.set_value('from_title', win.options.userData.from_title)
                campos_defs.set_value('transf_conf_tipo', win.options.userData.transf_conf_tipo_id)
                
            }
        }

        function guardar(modo2) {
            
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            
            var id_transf_conf = campos_defs.get_value('id')
            var transf_conf = campos_defs.get_value('transf_conf')
            var transf_conf_tipo = campos_defs.get_desc('transf_conf_tipo')
            var server = campos_defs.get_value('server')
            var port = campos_defs.get_value('port')
            var user = campos_defs.get_value('user')
            var password = campos_defs.get_value('password')
            var esSSL = campos_defs.get_value('esSSL')
            var from = campos_defs.get_value('from')
            var from_title = campos_defs.get_value('from_title')
            var strXML = '<?xml version="1.0" encoding="ISO-8859-1"?><recurso modo="' + modo2 + '" id_transf_conf="' + id_transf_conf + '" transf_conf_tipo="' + transf_conf_tipo + '" transf_conf="' + transf_conf + '" server="' + server + '" port="' + port + '" user="' + user + '" password="' + password + '" from="' + from + '" from_title="' + from_title + '" esSSL="' + esSSL + '"></recurso>'
            console.log(strXML)
            if (transf_conf == "" || transf_conf_tipo == "") {
                alert("Completar los valores obligatorios (*)")
            } else {
                modificado = true
                nvFW.error_ajax_request("trans_conf_ABM.aspx", {
                    
                    parameters: {
                        modo: "ABM",
                        strXML: strXML
                    },
                    onSuccess: function (err, transport) {

                        if (err.numError == 0)
                            
                            if (modo2.toUpperCase() == 'A') {
                                campos_defs.set_value("id", err.params.id_transf_conf)
                                modo = 'M'
                            }
                            if (modo2.toUpperCase() == 'B')
                                nuevo()

                        //win.close()
                    },
                    onFailure: function (err) {
                        nvFW.alert("Ocurrió un error. Contacte al administrador.")
                    },
                    error_alert: false
                })
            }
        }

      
        function eliminar() {
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            if (campos_defs.get_value('id') != '') {
                Dialog.confirm("¿Desea Eliminar este elemento?", {

                    width: 450,
                    okLabel: 'Confirmar',
                    cancelLabel: 'Cancelar',
                    className: "alphacube",
                    onOk: function (win) {
                        modificado=true
                        guardar('B')
                        win.close(modificado)
                    },
                    onCancel: function (win) {
                        win.close(modificado)
                    }
                })
            } else {
                alert('Seleccione un elemento')
            }
        }
        

        function nuevo() {
            if (!nvFW.tienePermiso('permisos_transferencia', 27)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            modo = "A"
            campos_defs.set_value('id', "")
            campos_defs.set_value('transf_conf', "")
            campos_defs.set_value('server', "")
            campos_defs.set_value('port', "")
            campos_defs.set_value('user', "")
            campos_defs.set_value('password', "")
            campos_defs.set_value('esSSL', "")
            campos_defs.set_value('from', "")
            campos_defs.set_value('from_title', "")
            campos_defs.set_value('transf_conf_tipo', "")
        }

        function parametros() {
            
                var winAgregar
                winAgregar = nvFW.parent.createWindow({
                    className: 'alphacube',
                    url: '../fw/parametros/parametros_nodos_modulo.aspx',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 1000,
                    height: 700,
                    resizable: true
                })

            winAgregar.showCenter(true)
            
        }

      

    </script>
</head>
<body id="cuerpo" onload="window_onload()"  style="width: 100%;height: 100%; overflow: hidden">
    <div id="divMenuDig"></div>
    <script type="text/javascript">
        var vMenuAgregar = new tMenu('divMenuDig', 'vMenuAgregar');
        Menus["vMenuAgregar"] = vMenuAgregar
        Menus["vMenuAgregar"].loadImage("guardar", '/fw/image/icons/guardar.png')
        Menus["vMenuAgregar"].loadImage("nuevo", '/fw/image/icons/nueva.png')
        Menus["vMenuAgregar"].loadImage("eliminar", '/fw/image/icons/eliminar.png')
        Menus["vMenuAgregar"].loadImage("parametros", '/fw/image/icons/parametros.png')
        Menus["vMenuAgregar"].alineacion = 'centro';
        Menus["vMenuAgregar"].estilo = 'A';
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar(modo)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 60%;text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>parametros</icono><Desc>Parametros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametros()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuAgregar.MostrarMenu()
    </script>

    <table class="tb1 " style="width: 100%">
         <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                ID
            </td>
            <td>
                 <script type="text/javascript">
                     campos_defs.add('id', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.habilitar('id', false)
                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Descripción*
            </td>
            <td>
                 <script type="text/javascript">
                     campos_defs.add('transf_conf', { nro_campo_tipo: 104, enDB: false })
                 </script>
            </td>
        </tr>       

        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Tipo*
            </td>
            <td>
                 <script type="text/javascript">
                     campos_defs.add('transf_conf_tipo', { autocomplete: true })
                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Server
            </td>
            <td>
                 <script type="text/javascript">
                     campos_defs.add('server', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true })
                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Puerto
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('port', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('port', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true })

                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                esSSL
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('esSSL', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('esSSL', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true })

                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Usuario
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('user', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('user', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true, despliega: 'arriba' })

                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                Contraseña
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('password', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('password', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true, despliega: 'arriba' })

                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                From
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('from', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('from', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true, despliega: 'arriba' })

                 </script>
            </td>
        </tr>
        <tr>
            <td class="Tit2" style="font-weight:bolder !important">
                From Title
            </td>
            <td>
                 <script type="text/javascript">
                     //campos_defs.add('from_title', { nro_campo_tipo: 104, enDB: false })
                     campos_defs.add('from_title', { nro_campo_tipo: 1, enDB: false, filtroXML: nvFW.pageContents.param_def, filtroWhere: "<id_param type='igual'>'%campo_value%'</id_param>", autocomplete: true, despliega: 'arriba' })

                 </script>
            </td>
        </tr>
    </table>
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 100%; max-height: 817px; overflow: auto" frameborder='0'></iframe>
</body>
</html>
