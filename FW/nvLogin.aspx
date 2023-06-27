<%@ Page Language="VB" AutoEventWireup="false" CodeFile="nvLogin.aspx.vb" Inherits="vbLogin"     %>

<!doctype html>
<html>
<head>
    <title>NOVA Login</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="image/icons/nv_login.ico" rel="shortcut icon" />
    <%--<link href="/fw/css/base.css" rel="stylesheet" type="text/css" />--%>
    
    <!--<link href="/fw/css/base.css" rel="stylesheet" type="text/css" />-->
    <link href="/fw/css/nvLogin.css" rel="stylesheet" type="text/css" />
   
    <script type="text/javascript">
        var _nvFW_Page_tSession = false
        
    </script>
    <script type="text/javascript"  src="script/nvFW.js"></script>
    <script type="text/javascript"  src="script/nvFW_BasicControls.js"></script>
    <script type="text/javascript"  src="script/nvFW_windows.js"></script>
    <script type="text/javascript"  src="script/nvLogin.js"></script>
    <script type="text/javascript"  src="script/tCampo_def.js"></script>
    <script type="text/javascript" >

        var showAppsInLogin = <%=Me.showAppsInLogin.ToString.ToLower%>
        var showRemenberUID = <%=Me.showRemenberUID.ToString.ToLower%>

        //Contador de intentos    
        var intentos = 0

        var url_string = window.location.href
        var url = new URL(url_string);
        var c = url.searchParams.get("c");

        var URLParam = url.searchParams.get("url");
        if (URLParam === null) URLParam = url.searchParams.get("URL");
        if (URLParam === null) URLParam = '';

        var app_cod_sistema = url.searchParams.get("app_cod_sistema")
        var SessionType
        var bloquear = url.searchParams.get("bloquear") == 'true'
        var UID_bloquear = ""
        if (bloquear) UID_bloquear = url.searchParams.get("UID")
        nvFW.error_ajax_request('?accion=getInfoBase', {
            onSuccess: function (er) {
                //app_cod_sistema = er.params["app_cod_sistema"]
                //Si por algún motivo viene a esta pagina y estla logueado lo manda de nuevo a la apliación
                if (er.params["app_path_rel"] != "" && er.params["autLevel"] != "-1" && !bloquear) {
                    if (URLParam.indexOf(er.params["app_path_rel"] == -1))
                        URLParam = ""

                    window.location.href = location.origin + (URLParam != "" ? URLParam : "/" + er.params.app_path_rel);
                }

                if (er.params["app_path_rel"] != "" && er.params["autLevel"] != "-1" && !bloquear)
                    window.location.href = location.origin + "/" + er.params.app_path_rel;


                SessionType = er.params["SessionType"]

                if (eval(er.params["showAppsInLogin"]) && !bloquear) {
                    var apps
                    eval("apps = " + er.params["sistemas"])
                    var cb = $("cbCod_sistema")
                    var rs = new tRS()
                    rs.addField("id", "varchar")
                    rs.addField("campo", "string")
                    rs.addRecord({ id: "", campo: '-- automático --' })
                    for (el in apps)
                        rs.addRecord({ id: el, campo: apps[el] })
                    campos_defs.items['cbCod_sistema'].rs = rs

                    campos_defs.habilitar("cbCod_sistema", true)
                    campos_defs.set_first("cbCod_sistema")
                }
                //$("tb_Loginbody").setStyle({display:"inline"})

                login_foco()
                $("bloquear").value = bloquear
                if (bloquear) {
                    $("UID").value = UID_bloquear
                    $("UID").disabled = true
                    campos_defs.habilitar("cbCod_sistema", false)
                }
            },
            error_alert: false,
            bloq_contenedor_on: false
        })



        nvFW.enterToTab = false

        function window_onresize() {
            //var body = $$("BODY")[0]
            //$('tb_Loginbody').setStyle({left:((body.getWidth() - $('tb_Loginbody').getWidth()) / 2) + "px"})
            //$('tb_Loginbody').setStyle({top:((body.getHeight() - $('tb_Loginbody').getHeight()) / 2) + "px"})
        }

        function window_onload() {

            //Si es un bloqueo de pantalla, colocar el UID y bloquearlo para que no se pueda cambiar.




            if (!showAppsInLogin) $("trCBSistemas").hide()
            if (!showRemenberUID) $("spanRecordarUsuario").hide()
            $("div_body").show()





            window_onresize()
        }


        function setFocusDelay(el, ms) {
            if (!ms) ms = 100
            window.setTimeout(function () { el.focus(); }, ms)
            //window.setTimeout(function() {el.trigger("focus")},ms)

        }

        function login_foco() {
            //window.setTimeout("$('UID').focus();$('UID').click()", 2000) //  
            window.focus()
            setFocusDelay($('UID'))
            $('chkRecUID').checked = eval(GetCookie('recordar_usuario', 'false'))

            if ($('chkRecUID').checked) {
                $('UID').value = GetCookie('cookUID', '')
                if ($('UID').value == '')
                    setFocusDelay($('UID'))
                else
                    setFocusDelay($('PWD'))
            }

            if ($('bloquear').value == 'true') {
                $('UID').disabled = true
                setFocusDelay($('PWD'))
            }

        }
     
    </script>

</head>
<body onload="window_onload()" onresize='window_onresize()'  >
    <form id="form_login" name="form_login" method="post" action=""  autocomplete="off">
    <input type="hidden" name="bloquear" id="bloquear" />
    <!-- <span id="max800_portrait" >@media screen and (max-device-width: 800px) and (orientation: portrait)</span>
    <span id="max800_landscape" >@media screen and (max-device-width: 800px) and (orientation: landscape)</span>-->
    <div id="div_body" align="center" style="100%; height:100%; display:none"  >
    <table class="tb1" id="tb_Loginbody" cellpadding="0" cellspacing="0" >

        <tr class="tbLabelNormal">
            <td>
               <!-- <iframe id="novaLobo" src="image/nvLogin/nova.svg" style="border: 0px; width:150px; height:64px" marginheight="0" marginwidth="0" noresize scrolling="No" frameborder="0"></iframe>-->
                 <object data="/precarga/image/Logo red mutual azul-02 1.svg" width="200" height="64" type="image/svg+xml">
                            <%--<img src="image/nvLogin/nvLogin_logo.png" alt="PNG image of standAlone.svg" />--%>
                 </object>
            </td>
        </tr>

        <tr>
            <td>
                
                <div id="divLogin_cambiar_pwd" style="width: 100%; display: none">
                    <table class="tb1" style="height: 100%; background-color: #FFFBFF !Important">
                        <tr>
                            <td colspan="2" style="text-align:center">El servidor a solicitado que cambie la contraseña.<br />
                                Ingrese una nueva contraseña para continuar</td>
                        </tr>
                        <tr>
                            <td style="width: 100%">
                                <table style="width: 100%">
                                    <tr class="tbLabelNormal">
                                        <td class="Tit4" nowrap>&nbsp;Nueva contraseña:&nbsp;&nbsp;</td>
                                        <td style="width: 100%">
                                            <input type="password" autocapitalize="off" id="pwd_new" style="width: 100%" onkeypress="pwd_new_onkeypress(event)" /></td>
                                    </tr>
                                    <tr class="tbLabelNormal">
                                        <td class="Tit4">&nbsp;Confirmar:&nbsp;&nbsp;</td>
                                        <td style="width: 100%">
                                            <input type="password" autocapitalize="off" id="pwd_new_conf" style="width: 100%" onkeypress="pwd_new_onkeypress(event)" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">&nbsp;</td>
                                    </tr>
                                    <tr>
                                        <td style="width: 100%; text-align: center; vertical-align: middle" colspan="2">
                                            <table style="width: 100%">
                                                <tr>
                                                    <td style="width: 50%; text-align: center">
                                                        <div id="divbtnAceptar_pwd" style="width: 100%">
                                                            <input type="button" id="btnAceptar_pwd" onclick="btnAceptar_pwd_onclick()" value="Aceptar" style="width: 100%" /></div>
                                                    </td>
                                                    <td style="text-align: center">
                                                        <div id="divbtnCancelar_pwd" style="width: 100%">
                                                            <input type="button" id="btnCancelar_pwd" onclick="btnCancelar_pwd_onclick()" value="Cancelar" style="width: 100%" /></div>
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


                <div id="divLogin">

                    <input type="text" placeholder="Usuario" autocapitalize="off" autocomplete="off" tabindex="1" id="UID" value="" maxlength="20"  onkeypress="login_onkeypress(event)" /> 
                    <input type="password" placeholder="Contraseña" autocapitalize="off" tabindex="2" id="PWD" onkeypress="login_onkeypress(event)" />
                    <table style="width: 100%">
                                   
                                    <tr id="trCBSistemas">
                                        <td class="Tit4">Sistema:</td>
                                        <td style="width: 100%" id="tdCBSistemas">
                                            <script type="text/javascript">
                                                campos_defs.add('cbCod_sistema', {nro_campo_tipo : 1, enDB: false, json: true, mostrar_codigo:false, sin_seleccion:false});
                                            </script>
                                        </td>
                                    </tr>
                                </table>
                    
                    <div class="wrap-toggle">
                                            
                    <input type="checkbox" id="chkRecUID" class="offscreen" value="0" onkeypress="login_onkeypress(event)" />
             
                    <span id="spanRecordarUsuario">
                           Recordar usuario
                    </span>
                    </div>     

                    <div id="divbtnAceptar">
                        <input type="button" id="btnAceptar" name="btnAceptar" value="Iniciar Sesión" onclick="btnAceptar_onclick()"/>
                    </div>

                    <img id="spinner" src="image/icons/spinner24x24_azul.gif" style="display: none; position: absolute" />
                </div>
            </td>
        </tr>
        </table>  

        </div>


        </form>
</body>
</html>
