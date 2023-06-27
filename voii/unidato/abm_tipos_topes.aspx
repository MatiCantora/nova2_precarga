<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_alarmas_pld", 4)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If modo <> "" Then
        Dim e As New tError()

        Try
            Dim tope_tipo As Integer = nvFW.nvUtiles.obtenerValor("tope_tipo")
            Dim tope As Decimal = nvFW.nvUtiles.obtenerValor("tope")
            Dim StrSQL As String = ""

            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT tope FROM nv_psp_topes_tipos_periodo WHERE nro_tope_tipo=" & tope_tipo & " and fe_hasta is null", cod_cn:="UNIDATO", autoclose_connection:=True, CommandTimeout:=0)

            If Not rs.EOF Then
                StrSQL = "update nv_psp_topes_tipos_periodo set fe_hasta=getdate() where nro_tope_tipo=" & tope_tipo & " and fe_hasta is null"
                nvFW.nvDBUtiles.DBExecute(StrSQL, cod_cn:="UNIDATO")
            End If

            StrSQL = "insert into nv_psp_topes_tipos_periodo (nro_tope_tipo, tope, fe_desde) values (" & tope_tipo & "," & tope & ", getdate())"
            nvFW.nvDBUtiles.DBExecute(StrSQL, cod_cn:="UNIDATO")

            StrSQL = "update nv_psp_topes_tipos set tope=" & tope & " where nro_tope_tipo=" & tope_tipo
            nvFW.nvDBUtiles.DBExecute(StrSQL, cod_cn:="UNIDATO")

            e.numError = 0

        Catch ex As Exception
            e.numError = -99
            e.parse_error_script(ex)
            e.titulo = "Error al procesar el comando"
            e.mensaje = "No se pudo realizar la acción solicitada"
        End Try

        e.response()

    End If

    Me.contents("filtro_tipos_tope_abm") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_tipos' cn='UNIDATO'><campos>nro_tope_tipo as [id], tope_tipo as [campo]</campos><filtro><NOT><nro_tope_tipo type='igual'>3</nro_tope_tipo></NOT></filtro></select></criterio>")
    Me.contents("filtro_tipos_tope") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_psp_topes_tipos' cn='UNIDATO'><campos>*</campos><filtro><NOT><nro_tope_tipo type='igual'>3</nro_tope_tipo></NOT></filtro></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Tipos de Topes</title>
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
            Menus["pMenu"] = pMenu;
            Menus["pMenu"].alineacion = 'centro';
            Menus["pMenu"].estilo = 'A';

            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Crear nuevo</Desc></MenuItem>")
            Menus["pMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            pMenu.loadImage("guardar", "../image/icons/guardar.png");
            pMenu.MostrarMenu();

        }

        function guardar() {
            if ((campos_defs.get_value('tope_tipo') == "") || (campos_defs.get_value('tope') == "")) {
                nvFW.alert("Todos los campos son obligatorios.");
                return;
            }

            else {
                let rs = new tRS();
                let filtroWhere = "<criterio><select><filtro><nro_tope_tipo type='igual'>'" + campos_defs.get_value('tope_tipo') + "'</nro_tope_tipo></filtro></select></criterio>";
                rs.open({ filtroXML: nvFW.pageContents.filtro_tipos_tope, filtroWhere: filtroWhere })

                if (rs.getdata('tope') != campos_defs.get_value('tope')) {
                    nvFW.error_ajax_request('abm_tipos_topes.aspx', {
                        parameters: {
                            modo: 'A',
                            tope_tipo: campos_defs.get_value('tope_tipo'),
                            tope: campos_defs.get_value('tope')
                        },
                        onSuccess: function (err, transport) {
                            parent.mostrar_listado();
                            win.close();
                        }
                    });
                }

                else {
                    nvFW.alert("El tope ingresado es igual al ya vigente para ese tipo de tope.");
                    return;
                }
            }
        }

    </script>

</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuPrincipal"></div>

    <table class="tb1">
        <tr>
            <td>Tipo de Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope_tipo', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_tipos_tope_abm,
                        mostrar_codigo: false,
                    });
                </script>
            </td>
        </tr>
        <tr>
            <td>Tope</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tope', {
                        nro_campo_tipo: 102,
                        enDB: false
                    });
                </script>
            </td>
        </tr>
    </table>

</body>
</html>
