<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 3)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim nro_tope_def As String = nvFW.nvUtiles.obtenerValor("nro_tope_def", "")
        Dim mov_tipo As String = nvFW.nvUtiles.obtenerValor("mov_tipo", "")
        Dim StrSQL As String = ""
        Dim Err = New nvFW.tError()

        Try
            Select Case modo.ToUpper
                Case "AM"
                    StrSQL = "INSERT INTO nv_psp_topes_def_mov_tipo (nro_tope_def, mov_tipo) VALUES (" & nro_tope_def & ",'" & mov_tipo & "')"
                Case "BM"
                    StrSQL = "DELETE FROM nv_psp_topes_def_mov_tipo WHERE nro_tope_def = " & nro_tope_def & " and mov_tipo='" & mov_tipo & "'"

            End Select

            nvFW.nvDBUtiles.DBExecute(StrSQL, cod_cn:="UNIDATO")
            Err.numError = 0

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al procesar el comando"
            Err.mensaje = "No se pudo realizar la acción solicitada"
        End Try

        Err.response()
    End If

    Me.contents("filtro_tipos_movs") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_mov_tipos' cn='UNIDATO'><campos>mov_tipo as [id], mov_tipo_desc as [campo]</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_tipos_movs_defs") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_def_mov_tipo' cn='UNIDATO'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Def Topes</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win = nvFW.getMyWindow();

        function window_onload() {
            pMenu = new tMenu('divMenuPrincipal', 'pMenu');
            Menus["pMenu"] = pMenu
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            pMenu.loadImage("guardar", "../image/icons/guardar.png");
            pMenu.MostrarMenu();
        }

        function guardar() {
            let rs = new tRS();
            let filtroWhere = "<criterio><select><filtro><nro_tope_def type='igual'>" + win.options.userData.nro_tope_def + "</nro_tope_def><mov_tipo type='igual'>'" + campos_defs.get_value('tipos_movs') + "'</mov_tipo></filtro></select></criterio>";
            rs.open({ filtroXML: nvFW.pageContents.filtro_tipos_movs_defs, filtroWhere: filtroWhere });

            if (rs.eof()) {
                nvFW.error_ajax_request('abm_def_tipos_movs.aspx', {
                    parameters:
                    {
                        modo: 'AM',
                        mov_tipo: campos_defs.get_value('tipos_movs'),
                        nro_tope_def: win.options.userData.nro_tope_def
                    },
                    onSuccess: function (err, transport) {
                        win.options.userData.hay_modificacion = true;
                        win.close();
                    }
                });
            }
            else {
                nvFW.alert("Ese movimiento ya está asociado con la definición.");
                return;
            }
        }

    </script>

</head>

<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table class="tb1">
        <tr>
            <td>Asociar Movimiento:</td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipos_movs', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipos_movs
                    });
                </script>
            </td>
        </tr>
    </table>

</body>
</html>
