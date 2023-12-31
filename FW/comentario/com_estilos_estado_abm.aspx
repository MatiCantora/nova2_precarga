<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_com_tipo As String = nvFW.nvUtiles.obtenerValor("nro_com_tipo", "")
    Dim nro_com_estado As String = nvFW.nvUtiles.obtenerValor("nro_com_estado", "")
    Dim style = nvFW.nvUtiles.obtenerValor("style", "")

    If modo <> "" Then
        Dim err As New tError()

        If ((nro_com_tipo = "") Or (nro_com_estado = "")) Then
            err.numError = 100
            err.mensaje = "Debe haber un tipo y estado de comentario seleccionado para proceder."

        Else
            Dim StrSQL As String = ""

            Try
                Select Case modo.ToUpper
                    Case "A"
                        If (style = "") Then
                            err.numError = 101
                            err.mensaje = "Debe haber un estilo para asociar."
                        Else
                            StrSQL = "Insert into com_tipos_com_estados(nro_com_tipo, nro_com_estado, style) values ('" & nro_com_tipo & "','" & nro_com_estado & "', '" & style & "')"
                        End If

                    Case "M"
                        If (style = "") Then
                            err.numError = 101
                            err.mensaje = "Debe haber un estilo para asociar."
                        Else
                            StrSQL = "UPDATE com_tipos_com_estados SET style='" & style & "' WHERE nro_com_tipo = " & nro_com_tipo & "and nro_com_estado = " & nro_com_estado
                        End If
                    Case "B"
                        StrSQL = "DELETE FROM com_tipos_com_estados WHERE nro_com_tipo = '" & nro_com_tipo & "' and nro_com_estado = '" & nro_com_estado & "'"
                End Select

                nvFW.nvDBUtiles.DBExecute(StrSQL)
                Err.numError = 0

            Catch ex As Exception
                err.numError = 1000
                err.titulo = "Error al procesar el comando."
                err.mensaje = "No se pudo realizar la acci�n solicitada."

            End Try

        End If

        err.response()

    End If

    Me.contents("comTiposEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos_com_estados'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("comTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>com_tipo</campos><filtro></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Modulo Comentarios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onresize() {

        }

        function window_onload() {
            campos_defs.set_value('nro_com_tipo', parseInt(win.options.userData.nro_com_tipo));
            campos_defs.habilitar('nro_com_tipo', false);

            if (win.options.userData.nro_com_tipo != '') {
                let rs = new tRS();
                let filtroXML = nvFW.pageContents.comTipos;
                let filtroWhere = "<criterio><select><filtro><nro_com_tipo type='igual'>'" + parseInt(win.options.userData.nro_com_tipo) + "'</nro_com_tipo></filtro></select></criterio>";
                rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere })
                if (!rs.eof()) {
                    campos_defs.set_value('com_tipo', rs.getdata('com_tipo'));
                    campos_defs.habilitar('com_tipo', false);
                }

                else {
                    nvFW.alert("Ocurri� un error, no puede procederse.");
                    win.close();
                    return;
                }
                
                campos_defs.set_value('com_estados', parseInt(win.options.userData.nro_com_estado));

                changeSelEstadoCom();
            }
            
            vMenuAgregar.MostrarMenu();

        }

        function guardar() {
            let modo;
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            let nro_com_estado = campos_defs.get_value('com_estados');
            let style = campos_defs.get_value('style');

            let rs = new tRS();
            let filtroXML = nvFW.pageContents.comTiposEstados;
            let filtroWhere = "<criterio><select><filtro><nro_com_tipo type='igual'>'" + nro_com_tipo + "'</nro_com_tipo><nro_com_estado type='igual'>'" + nro_com_estado + "'</nro_com_estado></filtro></select></criterio>";
            rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere });
            if (rs.eof())
                modo = 'A';
            else
                modo = 'M';

            if ((nro_com_tipo == '') || (nro_com_estado == '') || (style == '')) {
                nvFW.alert("El estado de comentario debe estar seleccionado, y el estilo definido no puede estar vacio. Intente nuevamente.");
                return;
            }

            nvFW.error_ajax_request("com_estilos_estado_abm.aspx", {
                parameters: {
                    modo: modo,
                    nro_com_tipo: nro_com_tipo,
                    nro_com_estado: nro_com_estado,
                    style: style
                },
                onError: function () {
                    nvFW.alert("Ocurri� un error. Contacte al administrador.");
                }
            })

        }

        function changeSelEstadoCom() {
            let nro_com_tipo = campos_defs.get_value('nro_com_tipo');
            let nro_com_estado = campos_defs.get_value('com_estados');

            let rs = new tRS();
            let filtroXML = nvFW.pageContents.comTiposEstados;
            let filtroWhere = "<criterio><select><filtro><nro_com_tipo type='igual'>'" + nro_com_tipo + "'</nro_com_tipo><nro_com_estado type='igual'>'" + nro_com_estado + "'</nro_com_estado></filtro></select></criterio>"

            rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere });
            if (!rs.eof())
                campos_defs.set_value('style', rs.getdata('style'));
            else
                campos_defs.set_value('style', '');
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%; overflow:hidden">
    <div id="divMenuAgregar">
            <script type="text/javascript">
                let vMenuAgregar = new tMenu('divMenuAgregar', 'vMenuAgregar');
                Menus["vMenuAgregar"] = vMenuAgregar;
                Menus["vMenuAgregar"].loadImage("guardar", '/fw/image/icons/guardar.png');
                Menus["vMenuAgregar"].alineacion = 'centro';
                Menus["vMenuAgregar"].estilo = 'A';
                Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='0' style='text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuAgregar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 95%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

            </script>
    </div>

    <table class="tb1" id="tabla">

        <tr>
            <td class="Tit1">Tipo comentario</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('com_tipo', {
                        nro_campo_tipo: 104,
                        enDB: false
                    });
                </script>
            <td>
        </tr>

        <tr hidden>
            <td class="Tit1">Nro comentario</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_com_tipo', {
                        nro_campo_tipo: 100,
                        enDB: false});
                </script>
            <td>
        </tr>

        <tr>
            <td class="Tit1"> Estado comentario </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('com_estados', { enDB: true, onchange: changeSelEstadoCom });
                </script>
            <td>
        </tr>

        <tr>
            <td class="Tit1">Estilo definido </td>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('style', {
                        nro_campo_tipo: 104,
                        enDB: false
                    })
                </script>
            </td>
        </tr>

    </table>


</body>
</html>
