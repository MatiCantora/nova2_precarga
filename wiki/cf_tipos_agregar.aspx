<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim cf_tipo_id As Integer = nvFW.nvUtiles.obtenerValor("cf_tipo_id", 0)
    Dim parent_id As Integer = nvFW.nvUtiles.obtenerValor("parent_id", -1)
    Dim depende_de_orden As Integer = nvFW.nvUtiles.obtenerValor("depende_de_orden", -1)

    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If strXML <> "" Then
        Dim err As New tError
        Try
            Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("cf_tipos_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
            Cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            Dim rs = Cmd.Execute()

            err.parse_rs(rs)
            err.params("cf_tipo_id") = rs.Fields("cf_tipo_id").Value
            err.response()
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error en CF TIPOS ABM"
            err.mensaje = "No se pudo realizar la acción solicitada"
        End Try
    End If

    Me.contents("cf_tipo_id") = cf_tipo_id
    Me.contents("filtro_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCf_tipos'><campos>*</campos></select></criterio>")
 %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Agregar/editar Tipo CF</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <%= Me.getHeadInit() %>
    
    <script type="text/javascript">
        var cf_tipo_id = nvFW.pageContents.cf_tipo_id,
            parent_id = <%= parent_id %>,
            editar = cf_tipo_id > 0 ? true : false,
            depende_de = parent_id > -1 ? parent_id : -1,
            depende_de_orden = <%= depende_de_orden %>

        function window_onload() {
            if (editar)
                cargar_datos()

            if (parent_id != -1)
                cargar_dependiente()
        }

        function cargar_datos() {
            var rs = new tRS(),
                filtroXML = nvFW.pageContents.filtro_tipo,
                filtroWhere = "<criterio><select><filtro><cf_tipo_id type='igual'>" + cf_tipo_id + "</cf_tipo_id></filtro></select></criterio>"

            rs.onComplete = function (r) {
                if (r.lastError.numError == 0) {
                    while (!r.eof()) {
                        campos_defs.set_value("cf_tipo", r.getdata("cf_tipo"))
                        if (r.getdata("depende_de") != null) {
                            depende_de = r.getdata("depende_de")
                            $("depende_de").value = r.getdata("depende_de_nombre") + " (" + depende_de + ")"
                        }
                        else
                            $("depende_de").value = ""

                        r.movenext()
                    }
                }
            }

            rs.open({
                filtroXML: filtroXML,
                filtroWhere: filtroWhere
            })
        }

        parent.winTipo = {}

        function abrir_arbol_tipo() {
            var id_padre = $("depende_de").value != "" ? $("depende_de").value : -1,
                url = editar ? "/wiki/cf_tipos_listar.aspx?id_padre=" + id_padre + "&id_hijo=" + cf_tipo_id : "/wiki/cf_tipos_listar.aspx"

            parent.winTipo = parent.nvFW.createWindow({
                url: url,
                title: "<b>Tipos de Conceptos Financieros</b>",
                width: 500,
                height: 400,
                destroyOnClose: true,
                minimizable: true,
                maximizable: true,
                onClose: function () {
                    if (parent.tipo_desc != null && parent.tipo_id != null) {
                        $("depende_de").value = parent.tipo_desc + " (" + parent.tipo_id + ")"
                        depende_de = parent.tipo_id
                        nvFW.selection_clear() // Limpiar la seleccion, si es que ocurre
                    }
                }
            })

            parent.winTipo.showCenter(true)
        }

        // ALTA
        function guardar() {
            if (campos_defs.get_value("cf_tipo") == "") {
                parent.alert("Debe completar todos los campos antes de guardar", { title: "Error al guardar" })
                return
            }
            else {
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                xmldato += "<tipo cf_tipo_id='" + cf_tipo_id + "' cf_tipo='" + campos_defs.get_value("cf_tipo") + "' depende_de='" + depende_de + "' depende_de_orden='" + depende_de_orden + "'>"
                xmldato += "</tipo>"

                parent.nvFW.error_ajax_request("cf_tipos_agregar.aspx", {
                    parameters: { strXML: xmldato },
                    onSuccess: function (er) {
                        try {
                            if (parent.winNuevo != null) parent.winNuevo.close()
                            if (parent.winEditar != null) parent.winEditar.close()
                        }
                        catch(e) {}
                    },
                    error_alert: true,
                    bloq_contenedor_on: true
                })
            }
        }

        function cargar_dependiente() {
            var rs = new tRS(),
                filtroXML = nvFW.pageContents.filtro_tipo,
                filtroWhere = "<criterio><select><filtro><cf_tipo_id type='igual'>" + parent_id + "</cf_tipo_id></filtro></select></criterio>"

            rs.onComplete = function (r) {
                if (r.lastError.numError == 0) {
                    while (!r.eof()) {
                        depende_de = r.getdata("cf_tipo_id")
                        $("depende_de").value = r.getdata("cf_tipo") + " (" + depende_de + ")"

                        r.movenext()
                    }
                }
            }

            rs.open({ filtroXML: filtroXML, filtroWhere: filtroWhere })
        }
    </script>
</head>

<body onload="window_onload()" onresize="window_onresize()" style="background: white; width:100%; height:100%; overflow:hidden">
    <div id="divMenu" style="width:100%;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        vMenu.loadImage("guardar", "/FW/image/icons/guardar.png");

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>");
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 80%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

        vMenu.MostrarMenu();
    </script>
    <table class="tb1">
        <tr>
            <td class="Tit1">Tipo:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("cf_tipo", enDB:=False, nro_campo_tipo:=104) %></td>
        </tr>
        <tr>
            <td class="Tit1">Depende de:</td>
            <td>
                <input id="depende_de" type="text" value="<%= IIf(parent_id <> -1, parent_id, "") %>" readonly="readonly" ondblclick="return abrir_arbol_tipo()"/>
                <img style="vertical-align: middle;" src="/FW/image/icons/buscar.png" alt="" onclick="return abrir_arbol_tipo()"/>
            </td>
        </tr>
    </table>
</body>
</html>
