<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var extension
        var firma_avanzadas


        function window_onload() {
            extension = win.options.userData.input["extension"]
            firma_avanzadas = win.options.userData.input["firma_avanzadas"]

            setFirmaParams()
            mostrarSegunExtension()
            window_onresize()
        }

        function mostrarSegunExtension() {

            switch (extension) {
                case "pdf":
                    break;
                default:
                    $("divOpcionesPDF").style.display = "none"
                    break
            }
        }

        function setFirmaParams() {

            var setLTV
            var hashAlgorithm
            var certificationLevel
            var cryptoStandard
            var signatureEstimatedSize
            
            if (firma_avanzadas) {

                hashAlgorithm = firma_avanzadas["hashAlgorithm"]
                certificationLevel = firma_avanzadas["certificationLevel"]
                cryptoStandard = firma_avanzadas["cryptoStandard"]
                setLTV = firma_avanzadas["setLTV"]
                signatureEstimatedSize = firma_avanzadas["signatureEstimatedSize"]

                $("set_ltv").checked = setLTV
                $("algoritmoHash").value = hashAlgorithm
                $("nivelCertificacion").value = certificationLevel
                $("estandard").value = cryptoStandard
                $('signatureEstimatedSize').value = signatureEstimatedSize

            } else {

                // valores por defecto
                $("set_ltv").checked = true
                $("algoritmoHash").value = 1
                $("nivelCertificacion").value = 0
                $("estandard").value = 1
                $("signatureEstimatedSize").value = 0
            }
        }


        function window_onresize() {
            try {
            }
            catch (e) { }
        }

        function onclick_aceptar() {
            var output = {}
            output["setLTV"] = $("set_ltv").checked
            output["hashAlgorithm"] = $("algoritmoHash").value
            output["certificationLevel"] = $("nivelCertificacion").value
            output["cryptoStandard"] = $("estandard").value
            output["signatureEstimatedSize"] = $("signatureEstimatedSize").value
            win.options.userData.retorno["success"] = true
            win.options.userData.retorno["firma_avanzadas"] = output
            win.close()
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id="divMenu">
    </div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Configuracion</Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Aceptar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onclick_aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
        vMenu.MostrarMenu()
    </script>
    <div id="divAjustesAvanzados">
        <table style="width: 100%">
            <tr class='tbLabel'>
                <td style="width: 25%">
                    LTV habilitado
                </td>
                <td style="width: 25%">
                    Algoritmo de Hash
                </td>
            </tr>
            <tr>
                <td>
                    <center>
                        <input type="checkbox" id="set_ltv" /></center>
                </td>
                <td>
                    <select name="algoritmoHash" id="algoritmoHash" style="width: 100%">
                        <option value="0">SHA1</option>
                        <option value="1">SHA256</option>
                        <option value="2">SHA384</option>
                        <option value="3">SHA512</option>
                        <option value="4">RIPEMD160</option>
                    </select>
                </td>
            </tr>
        </table>
        <div id="divOpcionesPDF">
            <table style="width: 100%">

                <tr class="tbLabel">
                    <td style="width: 33%">
                        Nivel de Certificacion PDF
                    </td>
                    <td style="width: 33%">
                        Estandard PDF
                    </td>
                    <td style="width: 33%;display:none">
                        Tamaño estimado de la firma (bytes)
                    </td>
                </tr>

                <tr>
                    <td>
                        <select name="nivelCertificacion" id="nivelCertificacion" style="width: 100%">
                            <option value="0" selected="selected">No Certificado</option>
                            <option value="1">Certificado con prohibición de cambios</option>
                            <option value="2">Certificado con permiso para relleno de formularios</option>
                            <option value="3">Certificado con permiso para relleno de formularios y comentarios</option>
                        </select>
                    </td>
                    <td>
                        <select name="estandard" id="estandard" style="width: 100%">
                            <option value="0">CMS</option>
                            <option value="1">CADES</option>
                            
                        </select>
                    </td>
                    <td style="display:none">
                        <input type='text' id='signatureEstimatedSize'/>
                    </td>
                </tr>

            </table>
        </div>
    </div>
</body>
</html>
