<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "pwd_cambiar" Then
    
        Dim pwd_curr As String = nvFW.nvUtiles.obtenerValor("pwd_curr", "")
        Dim pwd_new As String = nvFW.nvUtiles.obtenerValor("pwd_new", "")
        Dim err As tError = nvLogin.execute(nvApp, "pwd_cambiar", nvApp.operador.login, pwd_new, pwd_curr, "0", "", "")
    
        'rrRes = nvLogin.execute(nvApp, accion, UID, PWD, PWD_OLD, PwdCC, nv_hash, criterio)
        'nvADSUtiles.UserChangePassword(nvApp.ads_access, nvApp.ads_dominio, nvApp.ads_dc, nvApp.ads_group, UID, PWD_OLD, PWD)
        err.response()
    End If
    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Operador - Cambiar Contrase�a</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript">

        var vButtonItems = []

        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "btnAceptar_pwd_set";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return btnAceptar_pwd_set_onclick(true)";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "btnCancelar_pwd_set";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return btnCancelar_pwd_onclick()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/fw/image/security/buscar.png')


        function window_onload() {
            vListButton.MostrarListButton()
        }


        function window_onresize() {
        }


        function btnCancelar_pwd_onclick() {
            nvFW.getMyWindow().close()
        }


        function btnAceptar_pwd_set_onclick() {
            var pwd_curr = $('pwd_curr').value

            if (pwd_curr == "") {
                alert("Debe ingresar la contrase�a actual", {
                    title: '<b>Contrase�a vac�a</b>',
                    width: 350,
                    onOk: function (w) {
                        $('pwd_curr').focus()
                        w.close()
                    }
                })
                return
            }

            var pwd_new = $('pwd_new').value
            var pwd_new_conf = $('pwd_new_conf').value

            if (pwd_new == "" || pwd_new_conf == "") {
                alert('Al menos una de las contrase�as est� vac�a.<br />Por favor verifique.', {
                    title: '<b>Contrase�a vac�as</b>',
                    width: 350,
                    onOk: function (w) {
                        $('pass_set').focus()
                        w.close()
                    }
                })
                return
            }

            if (pwd_new_conf != pwd_new) {
                alert('Las contrase�as no coinciden.<br />Por favor verifique.', {
                    title: '<b>Contrase�as diferentes</b>',
                    width: 350,
                    onOk: function (w) {
                        setea ? $('pass_set').focus() : $('pass').focus()
                        w.close()
                    }
                })
                return
            }

            nvFW.error_ajax_request('operador_pwd_cambiar.aspx', {
                parameters: {
                    modo: "pwd_cambiar",
                    pwd_curr: $('pwd_curr').value,
                    pwd_new: $('pwd_new').value,
                    pwd_new_conf: $('pwd_new_conf').value
                },
                onSuccess: function (err, transport) {
                    $('pwd_curr').value = ''
                    $('pwd_new').value = ''
                    $('pwd_new_conf').value = ''

                    alert("La contrase�a fue seteada correctamente.", {
                        title: "",
                        width: 350,
                        onOk: function (w) {
                            w.close()
                            nvFW.getMyWindow().close()
                        }
                    })
                },
                onFailure: function (err) {
                    alert(err.mensaje, {
                        title: err.titulo,
                        width: 350
                    })
                },
                bloq_msg: 'Seteando nueva contrase�a...',
                error_alert: false
            });
        }


        function pwd_onkeypress(e, setea) {
            var key = Prototype.Browser.IE ? event.keyCode : e.which
            var pwd_new = $('pwd_new')
            var pwd_new_conf = $('pwd_new_conf')

            if (key == 13) {
                if (pwd_new.value == '')
                    pwd_new.focus()
                else
                    if (pwd_new_conf.value == '')
                        pwd_new_conf.focus()
                    else
                        btnAceptar_pwd_set_onclick(setea)
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height: 100%;
    width: 100%; vertical-align: top; overflow: hidden;">
    
    <div id="divSetear_pwd" style="width: 100%;height:100%">
        <table class="tb1" style="font-size: 13px;">
            <tr><td colspan="2" class="tdTitulosetearpwd"></td></tr>
            <tr><td colspan="2">&nbsp;</td></tr>

            <tr>
                <td style="width: 30%; white-space: nowrap; padding-top: 5px; text-align: right;">Contrase�a actual:&nbsp;</td>
                <td>
                    <input type="password" id="pwd_curr" name="pwd_curr" autocapitalize="off" tabindex="1" style="width: 100%; margin-top: 5px;" onkeypress="pwd_onkeypress(event,true)" />
                </td>
            </tr>

            <tr>
                <td style="width: 30%; white-space: nowrap; padding-top: 5px; text-align: right;">Contrase�a nueva:&nbsp;</td>
                <td>
                    <input type="password" id="pwd_new" name="pwd_new" autocapitalize="off" tabindex="1" style="width: 100%; margin-top: 5px;" onkeypress="pwd_onkeypress(event,true)" />
                </td>
            </tr>
            <tr>
                <td style="width: 30%; white-space: nowrap; padding-top: 5px; text-align: right;">Confirmar contrase�a nueva:&nbsp;</td>
                <td>
                    <input type="password" id="pwd_new_conf" name="pwd_new_conf" autocapitalize="off" tabindex="2" style="width: 100%; margin-top: 5px;" onkeypress="pwd_onkeypress(event,true)" />
                </td>
            </tr>
            <tr><td colspan="2">&nbsp;</td></tr>
            <tr>
                <td style="width: 100%; text-align: center; vertical-align: middle;" colspan="2">
                    <table class="tb1">
                        <tr style="text-align: center;">
                            <td style="width: 50%; text-align: center;">
                                <div id="divbtnAceptar_pwd_set" style="width: 100%;"></div>
                            </td>
                            <td style="text-align: center;">
                                <div id="divbtnCancelar_pwd_set" style="width: 100%;"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr><td colspan="2">&nbsp;</td></tr>
        </table>
    </div>

</body>
</html>
