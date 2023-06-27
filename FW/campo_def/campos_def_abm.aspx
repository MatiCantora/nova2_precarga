<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW.nvDBUtiles" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If (strXML <> "") Then
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("fw_campos_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Dim rs As ADODB.Recordset = cmd.Execute()
        Dim er As New nvFW.tError(rs)

        er.response()
    End If

    Me.contents("campo_def") = nvFW.nvUtiles.obtenerValor("campo_def", "")
    Me.contents("campo_def_abm") = nvXMLSQL.encXMLSQL("<criterio><select vista='campos_def'><campos>*</campos><orden>campo_def</orden><filtro></filtro></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Campos def</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">
        var default_accion = ""

        function window_onload() {
            var ventana = nvFW.getMyWindow()

            if (ventana.options.userData == undefined)
                ventana.options.userData = {}

            ventana.options.userData.hay_modificacion = false

            // agregar evento onChange cuando cargue la pagina
            campos_defs.items["depende_de"]["onchange"] = function () {
                campos_defs.clear("depende_de_campo")
                var depende_de = campos_defs.value("depende_de")

                if (depende_de == nvFW.pageContents.campo_def && depende_de != "") {
                    nvFW.alert('No puede elegir el mismo campo_def (' + depende_de + ') como dependiente ya que se utiliza en ID.')
                    campos_defs.clear("depende_de")
                }

                campos_defs.habilitar("depende_de_campo", campos_defs.value("depende_de") != "")

                if (campos_defs.value("depende_de") == "") {
                    campos_defs.set_value("depende_de_campo", "")
                }
            }

            var campo_def = nvFW.pageContents.campo_def
            default_accion = campo_def == "" ? "A" : "M"

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
                nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload")

                campos_defs.set_value("campo_def", rs.getdata("campo_def"))
                campos_defs.set_value('descripcion', rs.getdata("descripcion"))
                campos_defs.set_value('nro_campo_tipo', rs.getdata("nro_campo_tipo"))

                // campo 'depende_de'
                campos_defs.set_value("depende_de", rs.getdata("depende_de", ""))

                if (rs.getdata("depende_de") != null && rs.getdata("depende_de_campo") != null)
                    campos_defs.set_value("depende_de_campo", rs.getdata("depende_de_campo"))

                $("permite_codigo").checked = rs.getdata("permite_codigo") == "True"

                if (rs.getdata("json") == "True")
                    document.querySelector('[value=json]').checked = true
                else
                    document.querySelector('[value=XML]').checked = true

                // campo 'cacheControl'
                campos_defs.set_value("cacheControl", rs.getdata("cacheControl") != undefined ? rs.getdata("cacheControl") : "")

                $("filtroXML").value = rs.getdata("filtroXML") != undefined ? rs.getdata("filtroXML") : ""
                $("filtroWhere").value = rs.getdata("filtroWhere") != undefined ? rs.getdata("filtroWhere") : ""
                $("options").value = rs.getdata("options") != undefined ? rs.getdata("options") : ""
            }

            // Si "campo_def" esta vacio, no hacer la query
            if (nvFW.pageContents.campo_def != "") {
                nvFW.bloqueo_activar($$("BODY")[0], "rsOnload")
                var filtroWhere = "<criterio><select><filtro><campo_def type='igual'>'" + campo_def + "'</campo_def></filtro></select></criterio>"
                rs.open({ filtroXML: nvFW.pageContents.campo_def_abm, filtroWhere: filtroWhere })
            }
            else {
                campos_defs.set_value("depende_de", "")
                document.querySelector('[value=XML]').checked = true
                $('filtroXML').value = '"<criterio><select vista=\'\'><campos></campos><orden></orden><filtro></filtro></select></criterio>"';
            }
        }


        /*---------------------------------------------------------
        | MODIFICACION
        |----------------------------------------------------------
        | Funcion para modificar los campos de un campo_def
        | existente
        |
        |--------------------------------------------------------*/
        function campo_def_guardar(valor) {
            // Validaciones
            if (campos_defs.value("campo_def") == "") {
                alert("No ha ingresado el valor para <b>ID (campo_def)</b>")
                return
            }

            if (campos_defs.value("descripcion") == "") {
                alert("No ha ingresado el valor para <b>Descripción</b>")
                return
            }

            if (campos_defs.value("nro_campo_tipo") == "") {
                alert("No ha ingresado el valor para <b>Tipo</b>")
                return
            }

            if ($('options').value != '' && !validarJSON()) {
                alert("El formato ingresado para <b>Opciones</b> no es valido")
                return
            }

            // Si es nuevo validar que el codigo no exista ...
            var strXML = "<?xml version='1.0' encoding='iso-8859-1' ?>"
            if (typeof valor != 'undefined') {
                strXML += "<campos_defs><campo_def accion='A' campo_def='" + valor + "' descripcion='" + campos_defs.value("descripcion") + "' nro_campo_tipo='" + campos_defs.value("nro_campo_tipo") + "' "
            } else {
                strXML += "<campos_defs><campo_def accion='" + default_accion + "' campo_def='" + campos_defs.value("campo_def") + "' descripcion='" + campos_defs.value("descripcion") + "' nro_campo_tipo='" + campos_defs.value("nro_campo_tipo") + "' "
            }

            // campos 'depende_de' y 'depende_de_campo'
            if ($("depende_de").value != "") {
                strXML += "depende_de='" + $("depende_de").value + "' "

                if ($("depende_de_campo").value != "")
                    strXML += "depende_de_campo='" + $("depende_de_campo").value + "' "
            }

            if ($("permite_codigo").checked)
                strXML += " permite_codigo='true' "
            else
                strXML += " permite_codigo='false' "

            if (document.querySelector('[value=json]').checked)
                strXML += "json='true' "
            else
                strXML += "json='false' "

            // campo 'cacheControl'
            if ($('cacheControl').value != "")
                strXML += "cacheControl='" + $('cacheControl').value + "' "
            else
                strXML += "cacheControl='none' "

            strXML += ">"
            strXML += "<filtroXML><![CDATA[" + $("filtroXML").value + "]]></filtroXML><filtroWhere><![CDATA[" + $("filtroWhere").value + "]]></filtroWhere>"
            strXML += "<options><![CDATA[" + $("options").value + "]]></options></campo_def ></campos_defs> "

            var er = nvFW.error_ajax_request("campos_def_abm.aspx", {
                parameters: { strXML: strXML }
                , onSuccess: function () {
                    var win = nvFW.getMyWindow()
                    win.options.userData.hay_modificacion = true
                    win.close()
                }
                , error_alert: true
            })
        }


        function campo_def_guardar_como() {
            campo_def_guardar($('campo_def_gc').value)
        }

        var win;
        function btn_guardar_como() {

            win = nvFW.createWindow({
                title: '<b>Guardar como</b>',
                width: 500,
                height: 470,
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: true,
                closable: true,
                recenterAuto: true,
                setHeightToContent: true,
            });

            

            var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
            html += '<table class="tb1">'
            html += '<tbody><td class="Tit1" style="width:10px; height:10px">ID:</td>'
            html += '<td  colspan="2"><input style="width:100%; type="text" id="campo_def_gc" value=' + campos_defs.value("campo_def") + '></input></td><table>'
            html += '<table><tr><td style="text-align:center;width:10%"><button style="width:100%"; onclick="campo_def_guardar_como()"><img style="vertical-align: bottom;" src="/FW/image/icons/guardar.png" /> Guardar</button></td>'
            html += '<td style="text-align:center;width:10%"><button style="width:100%"; onclick="win.close()"><img style="vertical-align: bottom;" src="/FW/image/icons/cancelar.png" /> Cerrar</button></td></tr>'
            html += '</tbody></table></body></html>'



            win.setHTMLContent(html)
            win.showCenter(true)
        }



        /*---------------------------------------------------------
        | ALTA
        |----------------------------------------------------------
        | Función para preparar los campos y luego agregar un
        | nuevo campo_def
        |
        |--------------------------------------------------------*/
        function campo_def_nuevo() {
            // definir el 'default_action' como 'A' (alta)
            default_accion = "A"

            // limpiar campo_def para que no lo tome el eliminar por accidente
            campo_def = ""

            // limpiar todos los campos

            // id
            campos_defs.set_value("campo_def", "")

            // descripcion
            campos_defs.set_value("descripcion", "")

            // nro_campo_tipo
            campos_defs.set_value("nro_campo_tipo", "")

            // depende_de
            campos_defs.set_value("depende_de", "")

            // permite_codigo
            $("permite_codigo").checked = false

            // XML por defecto
            document.querySelector('[value=XML]').checked = true

            // cacheControl
            $("cacheControl").value = ""

            // filtroXML
            $('filtroXML').value = '"<criterio><select vista=\'\'><campos></campos><orden></orden><filtro></filtro></select></criterio>"';

            // filtroWhere
            $("filtroWhere").value = ""

            //options
            $("options").value = ""
        }


        /*---------------------------------------------------------
        | BAJA / ELIMINACION
        |----------------------------------------------------------
        | Función para eliminar un campo_def, pidiendo confirmación
        | antes de realizar la acción
        |
        |--------------------------------------------------------*/
        function campo_def_eliminar() {
            if (campo_def == "") {
                nvFW.alert("El ID (campo_def) no está definido para ser eliminado", { title: "Error al eliminar", okLabel: "Aceptar" })
                return
            }

            // dialogo de confirmacion
            nvFW.confirm("¿Está seguro de querer eliminar el registro de <b>" + nvFW.pageContents.campo_def + "</b>?",
                {
                    title: "Eliminar campo def",
                    onOk: function () {
                        // comprobar que el ID está definido
                        if (campos_defs.value("campo_def") == "") {
                            nvFW.alert("Debe estar definido el ID para su eliminación")
                            return
                        }

                        // armar el XML de eliminación (accion = "E")
                        var strXML = "<campos_defs><campo_def accion='E' campo_def='" + campos_defs.value("campo_def") + "'></campo_def></campos_defs>"

                        // ejecutar la accion
                        var er = nvFW.error_ajax_request("campos_def_abm.aspx",
                            {
                                parameters: { strXML: strXML },
                                onSuccess: function () {
                                    var win = nvFW.getMyWindow()
                                    win.options.userData.hay_modificacion = true
                                    win.close()
                                },
                                error_alert: true
                            }
                        )
                    },
                    onCancel: function () {
                        // volver a la ventana de edicion
                        return
                    }
                }
            )
        }

        function validarJSON() {
            try {
                JSON.parse($('options').value)
            } catch (e) {
                return false;
            }
            return true;
        }


        function btnParametros() {

            var strParametros = $('options').value

            var win = nvFW.createWindow(
                {
                    url: "/fw/campo_def/campos_def_parametros.aspx",
                    title: "Parametros",
                    width: "400",
                    height: "260",
                    onClose: function () {
                        $('options').value = typeof win.options.userData.strParametros != 'undefined' ? win.options.userData.strParametros : '';
                    }
                }
            )
            win.options.userData = { strParametros: strParametros }
            win.showCenter()
        }


    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()">
    <div id="DIV_Menu" style="width: 100%"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('DIV_Menu', 'vMenu');
        vMenu.alineacion = 'centro'
        vMenu.estilo = 'A'

        vMenu.loadImage("guardar", '/FW/image/icons/guardar.png')
        vMenu.loadImage("guardarComo", '/FW/image/icons/guardar_como.png')
        vMenu.loadImage('eliminar', '/FW/image/icons/eliminar.png')
        vMenu.loadImage('nuevo', '/FW/image/icons/nueva.png')

        vMenu.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardarComo</icono><Desc>Guardar Como </Desc><Acciones><Ejecutar Tipo='script'><Codigo>btn_guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Campo defs</Desc></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>campo_def_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu();
    </script>
    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 40px">ID:</td>
            <td colspan="2">
                <% = nvFW.nvCampo_def.get_html_input("campo_def", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1">Descripción:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("descripcion", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1">Tipo:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("nro_campo_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def_tipo'><campos> distinct nro_campo_tipo as id, campo_tipo as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>") %>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Dependiente:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("depende_de", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='campos_def'><campos>campo_def as id, campo_def as campo</campos></select></criterio>") %>
            </td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("depende_de_campo", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1">Permite código:</td>
            <td>
                <input name="permite_codigo" id="permite_codigo" type="checkbox" />
            </td>
        </tr>
        <tr>
            <td class="Tit1">Transporte:</td>
            <td>
                <input name="transporte" type="radio" value="json" />
                JSON
                <input name="transporte" type="radio" value="XML" />
                XML
            </td>
            <td class="Tit1">Cache control:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("cacheControl", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr class="tbLabel">
            <td colspan="2">FiltroXML</td>
        </tr>
        <tr>
            <td colspan="2">
                <textarea name="filtroXML" id="filtroXML" style="width: 100%" rows="5"></textarea></td>
        </tr>
        <tr class="tbLabel">
            <td colspan="2">FiltroWhere</td>
        </tr>
        <tr>
            <td colspan="2">
                <textarea name="filtroWhere" id="filtroWhere" style="width: 100%" rows="5"></textarea></td>
        </tr>
        <tr class="tbLabel">
            <%--<td><span>Opciones</span><span style="float:right"><button type="button" style="background-color: #a2a2a2; border: solid white 0.25px; color: white" onclick="btnParametros()">Parametros</button></span></td>--%>
            <td style="width: 100%">Opciones</td>
            <td onclick="btnParametros()" style="cursor: pointer" nowrap>Cargar parametros</td>
        </tr>
        <tr>
            <td colspan="2">
                <textarea ondblclick="btnParametros()" name="options" id="options" style="width: 100%" rows="4"></textarea></td>
        </tr>
    </table>

</body>
</html>
