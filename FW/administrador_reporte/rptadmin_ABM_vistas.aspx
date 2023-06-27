<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_vista As String = nvFW.nvUtiles.obtenerValor("nro_vista", "")
    Dim nombre_vista As String = nvFW.nvUtiles.obtenerValor("nombre_vista", "")
    Dim descripcion As String = nvFW.nvUtiles.obtenerValor("descripcion", "")
    Dim cn As String = nvFW.nvUtiles.obtenerValor("cn", "")
    Dim vista_columnas As String = "0"
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador

    If (Not op.tienePermiso("permisos_administrador_reportes", 9)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    If modo <> "" Then

        Dim e As New tError

        Try

            Dim strSQL As String = ""

            If modo <> "B" Then

                'Consulto si existe la vista verRptadmin_columnas
                Dim strSQL_columnas = "IF OBJECT_ID('verRptadmin_columnas') IS NOT NULL SELECT '1' AS vista_columnas ELSE SELECT '0'  AS vista_columnas"
                Try
                    Dim rsVista_columnas As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL:=strSQL_columnas, cod_cn:=cn)
                    If Not rsVista_columnas.EOF Then
                        vista_columnas = rsVista_columnas.Fields("vista_columnas").Value
                    End If
                    nvFW.nvDBUtiles.DBCloseRecordset(rsVista_columnas)
                Catch ex As Exception

                End Try

                'Alta de vista
                strSQL = "DECLARE @nro_vista INT = 0 "
                If modo = "A" Then
                    strSQL &= "IF NOT EXISTS (SELECT * FROM rptadmin_vistas WHERE nombre_vista = '" & nombre_vista & "') BEGIN "
                    strSQL &= "INSERT INTO rptadmin_vistas (nombre_vista,descripcion,cn,vista_columnas) values ('" & nombre_vista & "','" & descripcion & "','" & cn & "', '" & vista_columnas & "')"
                    strSQL &= "SET @nro_vista = SCOPE_IDENTITY() "
                End If
                'Actualizacion de vista
                If modo = "M" Then
                    strSQL &= "IF NOT EXISTS (SELECT * FROM rptadmin_vistas WHERE nombre_vista = '" & nombre_vista & "' AND nro_vista <> " & nro_vista & ") BEGIN "
                    strSQL &= "UPDATE rptadmin_vistas SET nombre_vista = '" & nombre_vista & "' , descripcion = '" & descripcion & "' , cn = '" & cn & "', vista_columnas = '" & vista_columnas & "' WHERE nro_vista = " & nro_vista
                    strSQL &= "SET @nro_vista = " & nro_vista & " "
                End If
                strSQL &= " SELECT 0 AS 'numError', @nro_vista AS 'nro_vista' END "
                strSQL &= "ELSE SELECT 1 AS 'numError', @nro_vista AS 'nro_vista'"

            Else
                'Baja de vista
                strSQL = "DELETE FROM rptadmin_vistas WHERE nro_vista = " & nro_vista & " SELECT 0 AS 'numError'"
            End If

            Dim rsVista As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)

            e.numError = rsVista.Fields("numError").Value

            If e.numError = 0 Then
                e.mensaje = "Vista guardada con exito."
                e.titulo = ""

                If modo = "A" Then

                    nro_vista = rsVista.Fields("nro_vista").Value
                    'Alta de permisos
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rptadmin_crear_permisos", ADODB.CommandTypeEnum.adCmdStoredProc)
                    cmd.addParameter("@nro_vista", ADODB.DataTypeEnum.adInteger, , , nro_vista)
                    cmd.addParameter("@nombre_vista", ADODB.DataTypeEnum.adVarChar, , , nombre_vista)

                    Dim rsPermiso As ADODB.Recordset = cmd.Execute()
                    'Asignacion automatica de permiso
                    Dim cmd1 As New nvFW.nvDBUtiles.tnvDBCommand("rptadmin_auto_asignar_permiso", ADODB.CommandTypeEnum.adCmdStoredProc)
                    cmd1.addParameter("@nro_vista", ADODB.DataTypeEnum.adInteger, , , nro_vista)
                    cmd1.addParameter("@operador", ADODB.DataTypeEnum.adInteger, , , nro_operador)

                    Dim rsPermiso_autoasignar As ADODB.Recordset = cmd1.Execute()

                    nvFW.nvDBUtiles.DBCloseRecordset(rsPermiso)
                    nvFW.nvDBUtiles.DBCloseRecordset(rsPermiso_autoasignar)
                End If

            Else
                e.mensaje = "Ya existe vista con el nombre <b>" & nombre_vista & "</b>."
                e.titulo = "Error"
            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rsVista)

        Catch ex As Exception
            e.parse_error_script(ex)
            e.mensaje = "Error al intentar guardar cambios."
            e.titulo = "Error"
            e.numError = -1
        End Try

        e.response()

    End If
    'Conexiones para campo def
    Dim strConexiones As String = ""

    For Each key In nvApp.app_cns.Keys
        strConexiones &= key & ","
    Next


    Me.contents("CDef_permiso_grupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='rptadmin_vistas'><campos>distinct permiso_grupo as id, permiso_grupo as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("CDef_conexion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='rptadmin_vistas'><campos>distinct cn as id, cn as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_vistas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='rptadmin_vistas'><campos>nro_vista, nombre_vista, descripcion, permiso_grupo, nro_permiso, cn, vista_columnas</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("conexiones") = strConexiones
    Me.addPermisoGrupo("permisos_administrador_reportes")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de vistas y reportes</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript"> 

        var win;

        var vButtonItems = {};

        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_vistas()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Agregar";
        vButtonItems[1]["etiqueta"] = "Guardar";
        vButtonItems[1]["imagen"] = "guardar";
        vButtonItems[1]["onclick"] = "return btn_guardar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage('buscar', '/FW/image/icons/buscar.png')
        vListButton.loadImage('guardar', '/FW/image/icons/guardar.png')

        function window_onload() {

            nvFW.enterToTab = false;

            win = nvFW.getMyWindow()

            if (win.options.userData == undefined)
                win.options.userData = {}

            win.options.userData.hay_modificacion = false

            vListButton.MostrarListButton();
            campos_defs.habilitar('nro_vista_add', false)

            window_onresize();

            $('nombre_vista').onkeypress = enterOnKeyPress;
            $('descripcion').onkeypress = enterOnKeyPress;
            $('permiso_grupo').onkeypress = enterOnKeyPress;
            $('conexion').onkeypress = enterOnKeyPress;

        }

        function window_onresize() {

            //var dif = Prototype.Browser.IE ? 5 : 2

            var body_h = $$('body')[0].getHeight();
            var tbAgregarVista_h = $('tbAgregarVista').getHeight();
            var tbFiltros_h = $('tbFiltros').getHeight();
            var vMenuFGral_h = $('vMenuFGral').getHeight();
            $('divMenuFGral').setStyle({ height: vMenuFGral_h + 'px' })

            $('frmVistas').setStyle({ height: body_h - tbAgregarVista_h - tbFiltros_h - vMenuFGral_h + 'px' })

        }

        function isEnterKey(event) {
            return (event.keyCode || event.which) == 13
        }


        function enterOnKeyPress(event) {
            if (!isEnterKey(event)) {
                return
            }
            else {
                if (this.value.length == 0)
                    return false
                else
                    buscar_vistas()
            }
        }

        function buscar_vistas() {

            var filtro = campos_defs.filtroWhere();
            cantFilas = Math.floor(($("frmVistas").getHeight() - 18) / 24);

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_vistas,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: 'report/administrador_reporte/rptadmin_vistas.xsl',
                formTarget: 'frmVistas',
                salida_tipo: 'adjunto',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando vistas...',
                cls_contenedor: 'frmVistas',
                ContentType: 'text/html',
            });

        }

        function limpiar_campos() {
            campos_defs.set_value('nro_vista_add', '');
            campos_defs.clear('nombre_vista_add');
            campos_defs.clear('descripcion_add');
            campos_defs.clear('conexion_add');
        }

        function editar_vista(nro_vista, nombre_vista, descripcion, permiso_grupo, nro_permiso, cn, vista_columnas) {
            campos_defs.set_value('nro_vista_add', nro_vista);
            campos_defs.set_value('nombre_vista_add', nombre_vista);
            campos_defs.set_value('descripcion_add', descripcion);
            campos_defs.set_value('conexion_add', cn);
        }

        var alertGuardar = function (msg) { Dialog.alert(msg, { title: '<b>Error</b>', className: "alphacube", width: 300, height: 150, okLabel: "cerrar" }); }
        function btn_guardar() {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 9)) {
                alert('No posee permisos para realizar esta acción.');
                return;
            }

            var modo;
            var nro_vista = campos_defs.get_value('nro_vista_add');
            var nombre_vista = campos_defs.get_value('nombre_vista_add');
            var descripcion = campos_defs.get_value('descripcion_add');
            var cn = campos_defs.get_value('conexion_add');

            var strError = '';

            if (nombre_vista == '')
                strError += 'Nombre Vista.<br>';
            if (descripcion == '')
                strError += 'Descripción.<br>';
            if (cn == '')
                strError += 'Conexión.<br>';

            if (strError != '') {
                alertGuardar('Falta completar campo:<br>' + strError);
                return
            }

            if (campos_defs.get_value('nro_vista_add') == '')
                modo = 'A';
            else modo = 'M';

            nvFW.error_ajax_request('rptadmin_ABM_vistas.aspx',
                {
                    parameters:
                    {
                        modo: modo,
                        nro_vista: nro_vista,
                        nombre_vista: nombre_vista,
                        descripcion: descripcion,
                        cn: cn
                    },
                    onSuccess: function (err) {
                        limpiar_campos();
                        win.options.userData.hay_modificacion = true;
                        buscar_vistas();
                    },
                    bloq_msg: 'Guardando...'
                });


        }

        function eliminar_vista(nro_vista, nombre_vista) {

            if (!nvFW.tienePermiso('permisos_administrador_reportes', 9)) {
                alert('No posee permisos para realizar esta acción.');
                return;
            }

            var modo = 'B';

            Dialog.confirm("¿Desea eliminar la vista <b>" + nombre_vista + "</b>?", {
                width: 300,
                className: "alphacube",
                okLabel: "Si",
                cancelLabel: "No",
                onOk: function (win_eliminar) {

                    nvFW.error_ajax_request('rptadmin_ABM_vistas.aspx',
                        {
                            parameters:
                            {
                                modo: modo,
                                nro_vista: nro_vista
                            },
                            onSuccess: function (err) {
                                win.options.userData.hay_modificacion = true;
                                buscar_vistas();
                            },
                            bloq_msg: 'Eliminando...'
                        });

                    win_eliminar.close(); return
                },
                onCancel: function (win_eliminar) { win_eliminar.close(); return }
            });

        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <table id="tbFiltros" class="tb1">
        <tr class="tbLabel">
            <td style="text-align: center" nowrap>Nombre Vista</td>
            <td style="text-align: center" nowrap>Descripción</td>
            <td style="text-align: center" nowrap>Grupo Permiso</td>
            <td style="text-align: center" nowrap>Conexión</td>
        </tr>
        <tr>
            <td>
                <script>
                    campos_defs.add('nombre_vista', {
                        enDB: false,
                        nro_campo_tipo: 104,
                        filtroWhere: "<nombre_vista type='like'>%%campo_value%%</nombre_vista>"
                    });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('descripcion', {
                        enDB: false,
                        nro_campo_tipo: 104,
                        filtroWhere: "<descripcion type='like'>%%campo_value%%</descripcion>"
                    });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('permiso_grupo', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.CDef_permiso_grupo,
                        mostrar_codigo: false,
                        filtroWhere: "<permiso_grupo type='igual'>'%campo_value%'</permiso_grupo>"
                    });
                </script>
            </td>
            <td>
                <script>
                    campos_defs.add('conexion', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.CDef_conexion,
                        mostrar_codigo: false,
                        filtroWhere: "<cn type='igual'>'%campo_value%'</cn>"
                    });
                </script>
            </td>
            <td rowspan="2">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>
    <iframe name="frmVistas" id="frmVistas" src="/FW/enBlanco.htm" style="width: 100%; height: 100%; overflow: hidden; border: none;"></iframe>
    <div style="width: 100%; height: 100%; overflow: hidden" id="divMenuFGral"></div>
    <script language="javascript" type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuFGral = new tMenu('divMenuFGral', 'vMenuFGral');
        Menus["vMenuFGral"] = vMenuFGral
        Menus["vMenuFGral"].alineacion = 'centro';
        Menus["vMenuFGral"].estilo = 'A';

        vMenuFGral.loadImage('nuevo', '/FW/image/icons/nueva.png')

        Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem><MenuItem id='1' style='width: 100px; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Limpiar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>limpiar_campos()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuFGral.MostrarMenu()
    </script>
    <table id="tbAgregarVista" class="tb1">
        <tr>
            <td>
                <table class="tb1">
                    <tr>
                        <td class="Tit1" nowrap>Nro. Vista:</td>
                        <td style="width: 10%">
                            <script>
                                campos_defs.add('nro_vista_add', {
                                    enDB: false,
                                    nro_campo_tipo: 101
                                });
                            </script>
                        </td>
                        <td class="Tit1" nowrap>Nombre Vista:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('nombre_vista_add', {
                                    enDB: false,
                                    nro_campo_tipo: 104
                                });
                            </script>
                        </td>
                        <td class="Tit1">Descripción:</td>
                        <td>
                            <script>
                                campos_defs.add('descripcion_add', {
                                    enDB: false,
                                    nro_campo_tipo: 104
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1">Conexión:</td>
                        <td colspan="2">
                            <script>
                                var conexiones = nvFW.pageContents.conexiones.substring(0, nvFW.pageContents.conexiones.length - 1)
                                
                                conexiones = conexiones.split(",")

                                var rs = new tRS()

                                rs.format = "getterror";
                                rs.format_tError = "json";
                                rs.addField("id", "string")
                                rs.addField("campo", "string")
                                for (var i = 0; i < conexiones.length; i++) {
                                    rs.addRecord({ id: conexiones[i], campo: conexiones[i] })
                                }


                                campos_defs.add('conexion_add', {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    json: true,
                                    mostrar_codigo: false,
                                    despliega: 'arriba'
                                });

                                campos_defs.items['conexion_add'].rs = rs;
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
            <td>
                <div id="divAgregar"></div>
            </td>
        </tr>
    </table>
</body>
</html>
