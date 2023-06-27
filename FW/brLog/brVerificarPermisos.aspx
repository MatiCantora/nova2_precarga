<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%


%>
<html>
<head>
    <title>Presentacion</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% =Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 350, height: 100, okLabel: "cerrar" }); }
        var win = nvFW.getMyWindow()
        var permiso_grupo = window.top.win.options.userData.permiso_grupo
        var nro_permiso = window.top.win.options.userData.nro_permiso

        function window_onload() {

            var vButtonItems = {};
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "btnAceptar";
            vButtonItems[0]["etiqueta"] = "Aceptar";
            vButtonItems[0]["imagen"] = "aceptar";
            vButtonItems[0]["onclick"] = "return btnAceptar_onclick()";


            vButtonItems[1] = {};
            vButtonItems[1]["nombre"] = "btnCancelar";
            vButtonItems[1]["etiqueta"] = "Cancelar";
            vButtonItems[1]["imagen"] = "cancelar";
            vButtonItems[1]["onclick"] = "return win.close()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("cancelar", '/FW/image/icons/cancelar.png');
            vListButton.loadImage("aceptar", '/FW/image/icons/clave.png');
            //vListButton.imagenes = Imagenes
            vListButton.MostrarListButton()

        }

        function btnAceptar_onclick() {

            var strError = ''

            if ($('UID').value == '')
                strError += 'Ingrese el usuario.</br>'
            if ($('PWD').value == '')
                strError += 'Ingrese la contraseña.</br>'

            if (strError != '') {
                alert(strError)
                return
            }

            nro_permiso = '1';
            permiso_grupo = 'permisos_log';

            criterio = "<criterio><UID>" + $('UID').value + "</UID><PWD>" + $('PWD').value + "</PWD><permiso_grupo>" + permiso_grupo +
                "</permiso_grupo><nro_permiso>" + nro_permiso + "</nro_permiso></criterio>"

            new Ajax.Request('/admin/ABMnvLog/brLog/getLogXML.aspx', {
                method: 'post',
                encoding: 'ISO-8859-1',
                parameters: { accion: 'brlogvalidar', criterio: criterio },
                onSuccess: login_return
            })
        }

        function login_return(transport) {
            
            oXML = new tXML()

            //oXML = transport.responseXML

            oXML.loadXML(transport.responseText);
            var numError = parseInt(oXML.selectSingleNode('xml/rs:data/z:row/@numError').nodeValue);
            //var numError = parseInt(objXML.selectSingleNode('xml/rs:data/z:row/@numError').value)
            var mensaje = oXML.selectSingleNode('xml/rs:data/z:row/mensaje').text// objXML.selectSingleNode('xml/rs:data/z:row/mensaje').text
            switch (numError) {
                case 0:
                    win.options.userData.tacceso = 1
                    win.close()
                    break
                default:
                    win.options.userData.tacceso = 0
                    alert(mensaje)
                    break

            }

        }

        function login_onkeypress(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                btnAceptar_onclick()
        }
    </script>
</head>
<body style="width: 100%; height: 100%; overflow: hidden; background-color: White; width: 100%" onload="window_onload()">
    <div id="divVerifPermiso" style="width: 100%">
        <table class='tb1'>
            <tr>
                <td>
                    <br />
                    <table>
                        <tr>
                            <td>
                                <b>Usuario:</b></td>
                            <td style="width: 100%">
                                <input type="text" tabindex="0" id="UID" value="" style="width: 100%" maxlength="20" onkeypress="login_onkeypress(event)" /></td>
                        </tr>
                        <tr>
                            <td><b>Contraseña:</b></td>
                            <td style="width: 100%">
                                <input type="password" tabindex="0" id="PWD" style="width: 100%" onkeypress="login_onkeypress(event)" />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 100%; vertical-align: middle; text-align: center" colspan="2"></br>
                    <table style='width: 100%'>
                        <tr>
                            <td style="width: 50%; text-align: center">
                                <div id="divbtnAceptar">
                                </div>
                            </td>
                            <td style="text-align: center">
                                <div id="divbtnCancelar">
                                </div>
                            </td>
                        </tr>

                    </table>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
