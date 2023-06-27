<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If (strXML <> "") Then
        Dim er As New tError

        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("fw_instancia_watcher_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()
            er = New nvFW.tError(rs)
        Catch ex As Exception
            er.parse_error_script(ex)
            er.numError = 105
            er.titulo = "Error en el SP"
            er.mensaje = "Error en el SP fw_instancia_watcher_abm"
        End Try
        er.response()

    End If

    Me.contents("id_nvwinstancia") = nvFW.nvUtiles.obtenerValor("id_nvwinstancia", "")
    Me.contents("watchers") = nvXMLSQL.encXMLSQL("<criterio><select vista='verNvw_Instancias_Watchers'><campos>*</campos><orden>nvwLabel</orden><filtro></filtro></select></criterio>")

    ' Obtener el nombre correcto de tabla para "tipos de campos def" segun la aplicación llamante - cambia con Admin y VOII
    Dim lista_sistemas As New List(Of String)(New String() {"nv_voii", "nv_admin"})
    Dim strVistaCampoDefTipo As String = IIf(lista_sistemas.IndexOf(nvApp.cod_sistema) > -1, "campos_def_tipo", "campo_def_tipo")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Instancia</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
     

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var default_accion = ""
        function window_onload()
        {
            var ventana = nvFW.getMyWindow()

            if (ventana.options.userData == undefined)
                ventana.options.userData = {}

            ventana.options.userData.hay_modificacion = false

            var id = nvFW.pageContents.id_nvwinstancia
            default_accion = id == "" ? "A" : "M"

            // Si "id_nvwinstancia" esta vacio, no hacer la query
            if (id != "") {

                var rs = new tRS()
                rs.asyc = true
                rs.onComplete = function (rs) {
                    nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload");

                    campos_defs.set_value("nvwInstancia", rs.getdata("nvwInstancia"))
                }

                nvFW.bloqueo_activar($$("BODY")[0], "rsOnload");
                var filtroWhere = "<criterio><select><filtro><id_nvwinstancia type='igual'>'" + id + "'</id_nvwinstancia></filtro></select></criterio>";
                rs.open({ filtroXML: nvFW.pageContents.watchers, filtroWhere: filtroWhere });
            }
                    

        }

        function instancia_guardar()
        {
            // Validaciones
            if (campos_defs.get_value("nvwInstancia") == "") {
                alert("No ha ingresado el valor para <b>Nombre</b>")
                return
            }

            // armar el XML de instancia alta (accion = "A") o edición (accion = "E")
            var strXML = '<nWatcher><nvwInstancias accion="' + default_accion
                + '" id_nvwinstancia="' + nvFW.pageContents.id_nvwinstancia
                + '" nvwInstancia="' + campos_defs.get_value("nvwInstancia")
                + '" el_machine="." el_log="Application" el_source="nvWatcher" el_cn="" /></nWatcher>'

            var er = nvFW.error_ajax_request("nWatcher_abm.aspx", {
                                                    parameters: {strXML: strXML}
                                                    ,onSuccess: function()
                                                    {
                                                        var win = nvFW.getMyWindow()
                                                        win.options.userData.hay_modificacion = true
                                                        win.close()
                                                        //Forzamos la carga del combo en el listado
                                                        //if (parent.campos_defs.items["nro_instancias_watcher"] && parent.campos_defs.items["nro_instancias_watcher"].input_select)
                                                        //    parent.campos_defs.items["nro_instancias_watcher"].input_select.length = 0
                                                        //if(parent.buscar_onclick)
                                                        //    parent.buscar_onclick()
                                                     } 
                                                    ,error_alert: true  
            })

            
        }


    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()">
    <table class="tb1">
        <tr>
            <td colspan="7">
                <div id="DIV_Menu" style="WIDTH: 100%"></div>
            </td>
        </tr>
        <script type="text/javascript">
            var vMenu = new tMenu('DIV_Menu','vMenu');
            vMenu.alineacion = 'centro'
            vMenu.estilo     = 'A'
   
            vMenu.loadImage("guardar", '/FW/image/icons/guardar.png')
            
            vMenu.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>instancia_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + (nvFW.pageContents.id_nvwinstancia == '' ? 'Nueva' : 'Editar') + " Instancia</Desc></MenuItem>")

            vMenu.MostrarMenu();
        </script>

        <tr>
            <td class="Tit1" style="width: 40px">Nombre:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("nvwInstancia", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>
    </table>
</body>
</html>