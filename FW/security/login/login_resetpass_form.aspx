<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    Dim password_reset_code As String = obtenerValor("password_reset_code", "")
    Dim usuario As String = obtenerValor("usuario", "")
    Me.contents("password_reset_code") = password_reset_code
    Me.contents("usuario") = usuario
    Me.contents("redirect_url") = New Uri(nvApp.server_host_https).ToString
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Cambiar contraseña</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        function btnAceptar_pwd_onclick() {
            var pwd = $('pwd_new').value
            var pwdRepeat = $('pwd_new_conf').value
            if (!pwd || !pwdRepeat) {
                alert("Debe completar los campos")
                return
            }
            if (pwd != pwdRepeat) {
                alert("No coincide la contraseña ingresada. Debe ser igual en ambos campos")
                return
            }
            nvFW.error_ajax_request('login_resetpass.aspx', {
                bloq_contenedor_on: true,
                parameters: { accion: "reset_password", password_reset_code: nvFW.pageContents.password_reset_code, usuario: nvFW.pageContents.usuario, password: pwd, password_confirm: pwdRepeat },
                onSuccess: function (err) {
                    if (err.numError == 0) {
                        $('divContent').innerHTML = "<div style='font-size:large'>La contraseña ha sido reestablecida con exito!</div>"
                    } else {
                        alert("No ha sido posible resetear la contraseña")
                    }
                },
                onFailure: function (err) {
                }
            })
        }

        function window_onload() {
            nvFW.enterToTab = false

            // centrado vertical
            var bodyHeight = $$('BODY')[0].getHeight();
            var divContentHeight = $('divContent').getHeight();
            var diffHeight = bodyHeight - divContentHeight
            if (diffHeight > 0) {
                $('divContent').setStyle({ marginTop: (diffHeight * 0.3) + 'px', overflow: "auto" });
            }
        }

        function login_onkeypress(e) {
            key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                switch (Event.element(e).id) {
                case "pwd_new":
                    $("pwd_new_conf").focus()
                    break
                default:
                    btnAceptar_pwd_onclick()
            }
        }

    </script>
</head>
<body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <div id='divContent' style="width: 100%; text-align: center;" align="center">
        <table class='tb1' style="margin: 0 auto; width: 20%">
            <tr class="tbLabelNormal">
                <td style="align: center; text-align: center; -moz-border-radius: 0.75em; -webkit-border-radius: 0.75em;
                    border-radius: 0.75em;">
                    <object data="/fw/image/nvLogin/nova.svg" width="150" height="64px" type="image/svg+xml">
                        <img src="/fw/image/nvLogin/nvLogin_logo.png" alt="PNG image of standAlone.svg">
                    </object>
                </td>
            </tr>
            <tr class="tbLabel0">
                <td style="text-align: center">
                    Resetear Contraseña
                </td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <table style="width: 100%">
                        <tbody>
                            <tr class="tbLabelNormal">
                                <td class="Tit4" nowrap="">
                                    &nbsp;Nueva contraseña:&nbsp;&nbsp;
                                </td>
                                <td style="width: 100%">
                                    <input type="password" autocapitalize="off" id="pwd_new" style="width: 100%" onkeypress="login_onkeypress(event)" />
                                </td>
                            </tr>
                            <tr class="tbLabelNormal">
                                <td class="Tit4">
                                    &nbsp;Confirmar:&nbsp;&nbsp;
                                </td>
                                <td style="width: 100%">
                                    <input type="password" autocapitalize="off" id="pwd_new_conf" style="width: 100%"
                                        onkeypress="login_onkeypress(event)" />
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 100%; text-align: center; vertical-align: middle" colspan="2">
                                    <table style="width: 100%">
                                        <tbody>
                                            <tr>
                                                <td style="width: 50%; text-align: center">
                                                    <div id="divbtnAceptar_pwd" style="width: 100%">
                                                        <input type="button" id="btnAceptar_pwd" onclick="btnAceptar_pwd_onclick()" value="Aceptar"
                                                            style="width: 100%" /></div>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
