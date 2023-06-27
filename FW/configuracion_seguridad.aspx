<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<% 

    Try

        Me.contents("nv_cod_servidor") = nvApp.cod_servidor 'nvServer.cod_servidor
        Me.contents("nv_cod_sistema") = nvApp.cod_sistema
        Me.contents("nv_cod_sistema_rol") = nvApp.id_sistema_rol
        Me.contents("nv_cod_sistema_version") = nvApp.cod_sistema_version
        Me.contents("nv_sistema_version_estado") = nvApp.sistema_version_estado

        Dim rsR As ADODB.Recordset
        rsR = nvFW.nvDBUtiles.DBOpenRecordset("SELECT desc_sistema_rol from nv_sistema_rol WHERE cod_sistema_rol='" + nvApp.id_sistema_rol.ToString() + "'")
        Me.contents("nv_desc_sistema_rol") = rsR.Fields("desc_sistema_rol").Value

        Dim rsE As ADODB.Recordset
        rsE = nvFW.nvDBUtiles.DBOpenRecordset("SELECT sistema_estado from nv_sistema_estado WHERE id_sistema_estado='" + nvApp.sistema_version_estado.ToString() + "'")
        Me.contents("nv_desc_sistema_estado") = rsE.Fields("sistema_estado").Value


        Me.contents("nv_ads_login") = IIf(nvApp.ads_login = "True", "Active Directory", "Delegar")
        Me.contents("nv_ads_dc") = nvApp.ads_dc
        Me.contents("nv_ads_dominio") = nvApp.ads_dominio
        Me.contents("nv_ads_access") = nvApp.ads_access

        'Configurations
        'Datos desde nvConfig.cfg
        Dim nv_onlyHTTPS = nvServer.getConfigValue("/config/global/@onlyHTTPS", "false") = "true"
        Me.contents("nv_onlyHTTPS") = nv_onlyHTTPS

        Me.contents("nv_showDebugErrors") = nvServer.getConfigValue("/config/global/@showDebugErrors", "false") = "true"
        Me.contents("nv_SessionType") = nvServer.getConfigValue("/config/global/@SessionType", "")
        Me.contents("nv_showAppsInLogin") = nvServer.getConfigValue("/config/global/@showAppsInLogin", "")
        Me.contents("nv_showRemenberUID") = nvServer.getConfigValue("/config/global/@showRemenberUID", "")
        Me.contents("nv_BrowserSessionTimeout") = nvServer.getConfigValue("/config/global/@BrowserSessionTimeout", "")

        Me.contents("nv_transformXSL_method") = nvServer.getConfigValue("/config/global/transformXSL/@method", "")
        Me.contents("nv_transformXSL_indent") = nvServer.getConfigValue("/config/global/transformXSL/@indent", "false") = "true"
        Me.contents("nv_transformXSL_enableDebug") = nvServer.getConfigValue("/config/global/transformXSL/@enableDebug", "false") = "true"

        Me.contents("nv_XMLtoSQL_returnSQLStatement") = nvServer.getConfigValue("/config/global/XMLtoSQL/@returnSQLStatement", "false") = "true"
        Me.contents("nv_XMLtoSQL_allowFiltroXMLNotEncrypted") = nvServer.getConfigValue("/config/global/XMLtoSQL/@allowFiltroXMLNotEncrypted", "false") = "true"

        Me.contents("nv_nvSecurity_permissionCache") = nvServer.getConfigValue("/config/global/nvSecurity/@permissionCache", "")

        Me.contents("nv_nvSecurity_jsofuscator_elements") = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@elements", "")
        Me.contents("nv_nvSecurity_jsofuscator_library") = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@library", "")
        Me.contents("nv_nvSecurity_jsofuscator_encoding") = nvServer.getConfigValue("/config/global/nvSecurity/jsofuscator/@encoding", "")

        'Datos desde web.config
        Me.contents("nv_compilation_debug") = HttpContext.Current.IsDebuggingEnabled
        'Me.contents("nv_customErrors_mode") = HttpContext.Current.GetSection("system.web/customErrors").Mode.ToString()
        'Me.contents("nv_contentType_mode") = HttpContext.Current.GetSection("system.webServer")

        Me.contents("nv_session_timeout") = HttpContext.Current.Session.Timeout




    Catch ex As Exception
        Dim err As tError = New tError()
        err.parse_error_script(ex)
        err.numError = 10
        err.titulo = "Error al iniciar la Aplicacion"
        err.mensaje = "No se pudo acceder a la configuración del sistema"
        err.mostrar_error()
    End Try

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Configuraciones de Seguridad</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
        td.Error{
        color: #D8000C;
        background-color: #FFBABA;
        }
    </style>
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript" >

        function window_onload() {
            configuracion_cargar()
            window_onresize()
        }


        function configuracion_cargar() {

            // #region Server
            $("nv_cod_servidor").innerText = nvFW.pageContents.nv_cod_servidor
            $("nv_cod_sistema").innerText = nvFW.pageContents.nv_cod_sistema
            $("nv_desc_sistema_rol").innerText = nvFW.pageContents.nv_desc_sistema_rol
            $("nv_cod_sistema_version").innerText = nvFW.pageContents.nv_cod_sistema_version
            $("nv_desc_sistema_estado").innerText = nvFW.pageContents.nv_desc_sistema_estado

            if (nvFW.pageContents.nv_cod_sistema_rol == 3 && nvFW.pageContents.nv_sistema_version_estado !== 3)
                addError("Un servidor con rol 'Producción' debe tener estado 'Producción'.");
            // #endregion

            // #region Domain
            $("nv_ads_login").innerText = nvFW.pageContents.nv_ads_login
            $("nv_ads_dc").innerText = nvFW.pageContents.nv_ads_dc
            $("nv_ads_dominio").innerText = nvFW.pageContents.nv_ads_dominio
            $("nv_ads_access").innerText = nvFW.pageContents.nv_ads_access
            // #endregion

            // #region Configs
            var rowErrors = [];
            setRow("nv_onlyHTTPS_row", nvFW.pageContents.nv_onlyHTTPS, "false", "true", rowErrors)
            setRow("nv_showDebugErrors_row", nvFW.pageContents.nv_showDebugErrors, "true", "false", rowErrors)
            setRow("nv_SessionType_row", nvFW.pageContents.nv_SessionType, "", "HTTP_session", rowErrors)
            setRow("nv_showAppsInLogin_row", nvFW.pageContents.nv_showAppsInLogin, "", "false", rowErrors)
            setRow("nv_showRemenberUID_row", nvFW.pageContents.nv_showRemenberUID, "", "false", rowErrors)
            setRow("nv_BrowserSessionTimeout_row", nvFW.pageContents.nv_BrowserSessionTimeout, "", "< 300000")

            setRow("nv_transformXSL_method_row", nvFW.pageContents.nv_transformXSL_method, "", "XMLDocument", rowErrors)
            setRow("nv_transformXSL_indent_row", nvFW.pageContents.nv_transformXSL_indent, "", "false", rowErrors)
            setRow("nv_transformXSL_enableDebug_row", nvFW.pageContents.nv_transformXSL_enableDebug, "true", "false", rowErrors)
            setRow("nv_XMLtoSQL_returnSQLStatement_row", nvFW.pageContents.nv_XMLtoSQL_returnSQLStatement, "true", "false", rowErrors)
            setRow("nv_XMLtoSQL_allowFiltroXMLNotEncrypted_row", nvFW.pageContents.nv_XMLtoSQL_allowFiltroXMLNotEncrypted, "true", "false", rowErrors)
            setRow("nv_nvSecurity_permissionCache_row", nvFW.pageContents.nv_nvSecurity_permissionCache, "none", "session", rowErrors)
            setRow("nv_nvSecurity_jsofuscator_elements_row", nvFW.pageContents.nv_nvSecurity_jsofuscator_elements, "", "all", rowErrors)
            setRow("nv_nvSecurity_jsofuscator_library_row", nvFW.pageContents.nv_nvSecurity_jsofuscator_library, "none", "nvJSOfuscator", rowErrors)
            setRow("nv_nvSecurity_jsofuscator_encoding_row", nvFW.pageContents.nv_nvSecurity_jsofuscator_encoding, "0", "10", rowErrors)

            setRow("nv_compilation_debug_row", nvFW.pageContents.nv_compilation_debug, "true", "false", rowErrors)
            //setRow("nv_customErrors_mode_row", nvFW.pageContents.nv_customErrors_mode, "Off", "RemoteOnly", rowErrors)
            setRow("nv_session_timeout_row", nvFW.pageContents.nv_session_timeout, "", "")

            //Validaciones especificas
            if (nvFW.pageContents.nv_cod_sistema_rol == 3) {
                if (nvFW.pageContents.nv_BrowserSessionTimeout > 300000) {
                    addError("<b onclick='goToRow(\"nv_BrowserSessionTimeout_row\")' style='cursor: pointer;'>BrowserSessionTimeout</b> no debe ser superior a 300000.");
                    rowErrors.push("nv_BrowserSessionTimeout_row");
                }

                //Validación de concordancia timeout
                var dif_timeout_MS = (nvFW.pageContents.nv_session_timeout * 60000) - nvFW.pageContents.nv_BrowserSessionTimeout;
                if (dif_timeout_MS != 10000) {
                    addError("<b onclick='goToRow(\"nv_session_timeout_row\")' style='cursor: pointer;'>Server Session Timeout</b> debe tener 1 minuto más que <b onclick='goToRow(\"nv_BrowserSessionTimeout_row\")' style='cursor: pointer;'>BrowserSessionTimeout</b> (" + (nvFW.pageContents.nv_BrowserSessionTimeout / 60000) + " min.).");
                    rowErrors.push("nv_session_timeout_row");
                }
            }
            

            
            // #endregion

            if (rowErrors.length) {
                addError("Se sugiere cambiar los valores resaltados a los recomendados para Alta Seguridad.");
                rowErrors.forEach(function (rowId) { $$("#" + rowId + " td.currentValue")[0].addClassName("Error");})
            }
                
                
        }

        /**
         * Setea los valores en la fila correspondiente
         * si el servidor es PRODUCTIVO se valida la seguridad del valor actual
         * @param rowId identificador del tr
         * @param currentValue Valor actual asignado
         * @param testValue Valor recomendado para test
         * @param securityValue Valor recomendado para Alta Seguridad
         * @param rowErrors Salida. Lista de rowId's con baja seguridad
         */
        function setRow(rowId, currentValue, testValue, securityValue, rowErrors) {
            
            $$("#" + rowId + " td.currentValue b")[0].innerText = currentValue;
            $$("#" + rowId + " td.testValue span")[0].innerText = testValue;
            $$("#" + rowId + " td.securityValue span")[0].innerText = securityValue;

            if (rowErrors && nvFW.pageContents.nv_cod_sistema_rol == 3 && currentValue.toString().toLowerCase() != securityValue.toLowerCase()) {
                rowErrors.push(rowId);
            }
        }

        function addError(description) {
            var pnode = document.createElement("p");
            pnode.setAttribute("style", "margin:0")
            
            var imgnode = document.createElement("img");
            imgnode.setAttribute("src", "/FW/image/icons/warning.png"); imgnode.setAttribute("align", "absmiddle"); imgnode.setAttribute("hspace", "1"); imgnode.setAttribute("width", "16");
            //var textnode = document.createTextNode(description);
            var descriptionDOM = document.createRange().createContextualFragment("&nbsp;" + description);
            pnode.appendChild(imgnode);
            pnode.appendChild(descriptionDOM);
            

            $("statusInfo").appendChild(pnode);
        }

        function goToRow(rowId) {
            var element = document.getElementById(rowId);
            element.parentElement.scroll(element.offsetLeft, element.offsetTop-60);

            var origcolor = element.style.backgroundColor
            element.style.backgroundColor = '#DFD6E0';
            var t = setTimeout(function () {
                element.style.backgroundColor = origcolor;
            }, (1300));
        }

        function window_onresize() {
            var tbConfigs = $("tbConfigs")
            var tbody_h = $$("BODY")[0].getHeight() - tbConfigs.tHead.getHeight() - $("menuConfig").getHeight() - $("srvInfo").getHeight() - $("statusInfo").getHeight()
            tbConfigs.tBodies[0].setStyle({ height: tbody_h + "px" })
            $("divtable").setStyle({
                height: (tbConfigs.tHead.getHeight() + tbody_h) + "px"
            })
        }

        function imprimir() {

            var table = $("tbConfigs")
            table.tBodies[0].setStyle({ "overflow-y": "visible", height: "" })
            $("divtable").setStyle({ height: "" })

            var mywindow = window.open('', 'PRINT', 'height=400,width=600');

            mywindow.document.write('<html><head><title>Seguridad</title>');
            mywindow.document.write('<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />');
            mywindow.document.write('<style type="text/css">td.Error{color: #D8000C;background-color: #FFBABA;}</style>');
            mywindow.document.write('</head><body style="background-color: white" onload="window.print();window.close();">');
            mywindow.document.write('<h1>Configuraciones de Seguridad</h1>');
            mywindow.document.write(document.getElementById("printable").innerHTML);
            mywindow.document.write('</body></html>');

            mywindow.document.close(); // necessary for IE >= 10
            mywindow.focus(); // necessary for IE >= 10*/

            //mywindow.print();
            //mywindow.close();
            table.tBodies[0].setStyle({ "overflow-y": "overlay" })

            window_onresize();
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height: 100%; width:100%; vertical-align: top; overflow: hidden; background-color: white;">
    <div id="menuConfig"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('menuConfig', 'vMenu');
        vMenu.alineacion = 'centro'
        vMenu.estilo = 'A'
        vMenu.loadImage('imprimir', '/FW/image/icons/imprimir.png')
        vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>Imprimir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>imprimir()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu.MostrarMenu();
    </script>
    <div id="printable">
        <div id="srvInfo" style="padding-bottom: 1em;">
            <table class='tb1' id='tbServSis'  style="width: 100%;">
                <tr>
                    <td class="tit2" style="text-align: center; width: 20%" nowrap>
                        <b>Servidor</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 20%" nowrap>
                        <b>Sistema</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 20%" nowrap>
                        <b>Rol</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 20%" nowrap>
                        <b>Versión</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 20%" nowrap>
                        <b>Estado</b>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_cod_servidor"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_cod_sistema"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_desc_sistema_rol"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_cod_sistema_version"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_desc_sistema_estado"></span>
                    </td>
                </tr>
            </table>
            <table class='tb1' id='tbDomain'  style="width: 100%;">
                <tr>
                    <td class="tit2" style="text-align: center; width: 25%" nowrap>
                        <b>Tipo de login</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 25%" nowrap>
                        <b>Ads Access</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 25%" nowrap>
                        <b>Dominio</b>
                    </td>
                    <td class="tit2" style="text-align: center; width: 25%" nowrap>
                        <b>Ads dc</b>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_ads_login"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_ads_access"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_ads_dominio"></span>
                    </td>
                    <td style="text-align: center; background-color: white">
                        <span id="nv_ads_dc"></span>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divtable">
            <table class="tb1 highlightEven scroll" id="tbConfigs" style="min-width:930px;overflow-x:auto">
                <thead>
                    <tr class="tbLabel" style="display:block;">
                        <td width="10%">Archivo</td>
                        <td width="20%">Propiedad</td>
                        <td width="30%">Descripción</td>
                        <td width="10%">Valores Admitidos</td>
                        <td width="10%">Valor Actual</td>
                        <td width="10%">Recomendado para Testing</td>
                        <td width="10%">Recomendado para Alta Seguridad</td>
                    </tr>
                </thead>
                <tbody style="display:block; overflow-y:overlay;height:400px;">
                    <tr id="nv_onlyHTTPS_row">
                        <td width="10%" rowspan="15" class="Tit1">nvConfig.cfg</td>
                        <td width="20%" class="Tit1" title="/config/global/@onlyHTTPS">OnlyHTTPS</td>
                        <td width="30%">
                            Exige que las conexiones al servidor solo sean encriptadas por SSL.
                        </td>
                        <td width="10%">
                            True<br />
                            False
                        </td>
                        <td  width="10%" class="currentValue">
                            <b></b>
                        </td>
                        <td  width="10%" class="testValue">
                            <span></span>
                        </td>
                        <td  width="10%" class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_showDebugErrors_row">
                        <td class="Tit1" title="/config/global/@showDebugErrors">ShowDebugErrors</td>
                        <td>
                            Visualiza la información de los errores en pantalla.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_SessionType_row">
                        <td class="Tit1" title="/config/global/@SessionType">SessionType</td>
                        <td>
                            Administrador de estado de sesión
                        </td>
                        <td>
                            nvInterOP_session<br />
                            HTTP_session
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td> 
                    </tr>
                    <tr id="nv_showAppsInLogin_row">
                        <td class="Tit1" title="/config/global/@showAppsInLogin">ShowAppsInLogin</td>
                        <td>
                            Permite controlar si la pantalla de login muestra las aplicaciones instaladas.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td> 
                    </tr>
                    <tr id="nv_showRemenberUID_row">
                        <td class="Tit1" title="/config/global/@showRemenberUID">ShowRemenberUID</td>
                        <td>
                            Permite controlar si la pantalla de login muestra la opción "Recordar usuario".
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td> 
                    </tr>
                    <tr id="nv_BrowserSessionTimeout_row">
                        <td class="Tit1" title="/config/global/@BrowserSessionTimeout">BrowserSessionTimeout</td>
                        <td>
                            Controla el tiempo de sesión dentro del browser. Debe ser concordante con el valor del tiempo de sesión del server.
                        </td>
                        <td>
                            [0 - N) (milisegundos)
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td> 
                    </tr>
                
                    <tr id="nv_transformXSL_method_row">
                        <td class="Tit1" title="/config/global/transformXSL/@method">TransformXSL Method</td>
                        <td>
                            Define con qué colección de objetos se realizara la transformación XSLT.
                        </td>
                        <td>
                            XMLDocument<br />
                            DOMDocument
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_transformXSL_indent_row">
                        <td class="Tit1" title="/config/global/transformXSL/@indent">TransformXSL Indent</td>
                        <td>
                            En caso de que se utilice el method=XMLDocument define si se identará automáticamente el resultado de la transformación XML.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_transformXSL_enableDebug_row">
                        <td class="Tit1" title="/config/global/transformXSL/@enableDebug">TransformXSL EnableDebug</td>
                        <td>
                            En caso de que se utilice el method=XMLDocument define si se habilita la depuración dentro de la plantilla XSL.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_XMLtoSQL_returnSQLStatement_row">
                        <td class="Tit1" title="/config/global/XMLtoSQL/@returnSQLStatement">XMLtoSQL ReturnSQLStatement</td>
                        <td>
                            Devuelve la consulta SQL cuando devuelve los datos.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_XMLtoSQL_allowFiltroXMLNotEncrypted_row">
                        <td class="Tit1" title="/config/global/XMLtoSQL/@allowFiltroXMLNotEncrypted">XMLtoSQL AllowFiltroXMLNotEncrypted</td>
                        <td>
                            Permite que se utilicen consultas XML sin encriptar directamente desde el Browser.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_nvSecurity_permissionCache_row">
                        <td class="Tit1" title="/config/global/nvSecurity/@permissionCache">nvSecurity PermissionCache</td>
                        <td>
                            Define cómo se evaluarán los permisos en tiempo de ejecución.
                        </td>
                        <td>
                            none<br />
                            session
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_nvSecurity_jsofuscator_elements_row">
                        <td class="Tit1" title="/config/global/nvSecurity/jsofuscator/@elements">nvSecurity Jsofuscator Elements</td>
                        <td>
                            Determina los tipos de documentos a ofuscar.
                        </td>
                        <td>
                            all<br />
                            file_js<br />
                            js_in_html
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_nvSecurity_jsofuscator_library_row">
                        <td class="Tit1" title="/config/global/nvSecurity/jsofuscator/@library">nvSecurity Jsofuscator Library</td>
                        <td>
                            Define la librería utilizada para la ofuscación.
                        </td>
                        <td>
                            nvJSOfuscator<br />
                            yui.compressor<br />
                            none
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_nvSecurity_jsofuscator_encoding_row">
                        <td class="Tit1" title="/config/global/nvSecurity/jsofuscator/@encoding">nvSecurity Jsofuscator Encoding</td>
                        <td>
                            Tipo de codificación utilizado. Sólo para la librería nvJSOfuscator.
                        </td>
                        <td>
                            0&#8194;&#8194;(none)<br />
                            10&#8194;(numeric)<br />
                            20&#8194;(mix)
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_compilation_debug_row">
                        <td rowspan="4" class="Tit1">web.config</td>
                        <td class="Tit1" title="/configuration/system.web/compilation/@debug">Compilation Debug</td>
                        <td>
                            Permite insertar símbolos de depuración en la página compilada.
                        </td>
                        <td>
                            True<br />
                            False
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_customErrors_mode_row">
                        <td class="Tit1" title="-">CustomErrors Mode</td>
                        <td>
                            Habilita la configuración de las acciones que se deben realizar si un error no controlado tiene lugar durante la ejecución de una solicitud.
                        </td>
                        <td>
                            On<br />
                            Off<br />
                            RemoteOnly
                        </td>
                        <td class="currentValue">
                            <span>Por Definir</span>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_buffers_row">
                        <td class="Tit1" title="-">Buffers</td>
                        <td>
                            Tamaños de buffers entrada/salida.
                        </td>
                        <td>
                        
                        </td>
                        <td class="currentValue">
                            <span>Por Definir</span>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_contentTypes_row">
                        <td class="Tit1" title="-">ContentTypes</td>
                        <td>
                            Tipos de archivos admitidos por el sistema.
                        </td>
                        <td>
                        
                        </td>
                        <td class="currentValue">
                            <span>Por Definir</span>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                    <tr id="nv_session_timeout_row">
                        <td class="Tit1">Server</td>
                        <td class="Tit1" title="">Server Session Timeout</td>
                        <td>
                            Tiene que tener un valor de 1 min. más que el de BrowserSessionTimeout.
                        </td>
                        <td>
                            [0 - N) (minutos)
                        </td>
                        <td class="currentValue">
                            <b></b>
                        </td>
                        <td class="testValue">
                            <span></span>
                        </td>
                        <td class="securityValue">
                            <span></span>
                        </td>
                    </tr>
                </tbody>
            </table>

        </div>
        <div id="statusInfo" style="padding:0.5em;">
            
        </div>
    </div>
</body>
</html>        