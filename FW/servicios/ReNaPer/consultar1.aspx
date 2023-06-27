<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim servicio As String = nvUtiles.obtenerValor("servicio", "").ToString().ToLower()
    Dim err As New tError()

    If servicio <> "" Then

        Select Case servicio

            Case "validar_paquete_iii"
                Dim number As String = nvUtiles.obtenerValor("number", "")
                Dim gender As String = nvUtiles.obtenerValor("gender", "")
                Dim order As String = nvUtiles.obtenerValor("order", "")
                Dim eMsg As String = String.Empty

                If number = String.Empty Then
                    eMsg &= "Número de DNI inválido." & vbCrLf
                End If

                If gender = String.Empty Then
                    eMsg &= "Género inválido." & vbCrLf
                End If

                If order = String.Empty Then
                    eMsg &= "Número de trámite inválido." & vbCrLf
                End If


                If eMsg <> String.Empty Then
                    err.numError = 1
                    err.titulo = "Error en parámetros"
                    err.mensaje = "Uno o más parámetros son inválidos. Revise los siguientes mensajes:" & vbCrLf & eMsg
                Else
                    err = nvFW.servicios.Renaper.ValidarIdentidad(number, gender, order)

                    If err.numError = 0 AndAlso err.params("valid").ToLower() <> "vigente" Then
                        err.numError = 1
                        err.titulo = "DNI inválido"
                        err.mensaje = "El servicio de RENAPER ha detectado que el DNI presentado es inválido."
                    End If
                End If

                err.response()

        End Select
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>RENAPER</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <style type="text/css">
        * { font-family: Verdana, sans-serif !important; }
        body { background-color: white; font-size: 13px; }
        /*---------------- Contenedores ----------------*/
        .contenedor { width: 100%; margin: 0 auto 20px; border: 1px solid #CCCCCC; border-radius: 3px; box-shadow: 0px 0px 5px 0px #afafaf; }
        .contenedor h4 { margin: 0 0 5px 0; padding: 10px; background-color: #EFEFEF; border-bottom: 1px solid #CCCCCC; color: #3f3f3f; border-top-left-radius: 3px; border-top-right-radius: 3px; }
        .ok { background-color: #3aa00d54; }
        .ok h4 { color: #33730c; }
        .error { background-color: #ff000063; }
        .error h4 { color: #d42525; }
        .contenedor p { margin: 0 10px 5px; }
        div > table.tb1, div > form > table.tb1 { padding: 0 10px; margin-bottom: 10px; }
        input[type=file] { width: 500px; }
        input[type=button] { border-radius: 3px; border: 1px solid #000000; color: #000000; text-transform: uppercase; padding: 2px 15px; background-color: #F0F0F2; }
        input[type=button]:hover { border-color: #000000; background-color: #000000; color: #FFFFFF; }
        input[type=button]:disabled, input[type=button]:disabled:hover { border: 1px solid #b0b0b0; color: #b0b0b0; background-color: #F0F0F2; }
        .tag { margin: 0 3px 0 0; padding: 0 5px 1px; border-radius: 3px; color: #ffffff; font-size: 0.85em; text-transform: uppercase; }
        .face, .version { background-color: #5178f1; }
        .time { background-color: #3e3e3e; }
        .selfie-ok { background-color: #26a722; }
        .selfie-error { background-color: #d8433f; }
        .selfie-info { background-color: #3743d8; }
        .converted { color: #333333; background-color: #43d83f; }
        #paquete { width: 230px; }
    </style>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var en_proceso_de_validacion = false;
        
        var buttonItems = {};
        buttonItems[0]  = [];
        buttonItems[0].nombre   = "Verificar";
        buttonItems[0].etiqueta = "Verificar Identidad";
        buttonItems[0].imagen   = "engine";
        buttonItems[0].onclick  = "return validarIdentidad();";

        var listButtons = new tListButton(buttonItems, 'listButtons');
        listButtons.loadImage('engine', '/FW/image/icons/procesar.png');



        function WindowOnload()
        {
            nvFW.enterToTab = false;
            listButtons.MostrarListButton();
            WindowOnresize();
        }



        function WindowOnresize()
        {
        }



        function validarIdentidad()
        {
            // Comprobar si no hay un proceso de validación sin terminar
            if (en_proceso_de_validacion) return false;


            var messages = '';
            
            if (!$('_number').value) {
                messages += 'El número de <b>DNI</b> está vacío.<br/>';
            }

            if (!$('_gender').value) {
                messages += 'No se ha seleccionado el <b>género</b> de la persona.<br/>';
            }

            if (!$('_order').value) {
                messages += 'El número de <b>trámite</b> está vacío.<br/>';
            }
            
            if (messages) {
                alert('Uno o más parámetros están vacíos o son inválidos. Revise los siguientes mensajes:<br/><br/>' + messages, {
                    title:  '<b>Error en parametros</b>',
                    height: 135
                });

                return false;
            }

            // Activar la bandera
            en_proceso_de_validacion = true;


            nvFW.error_ajax_request('consultar.aspx', {
                parameters: {
                    'servicio': 'validar_paquete_iii',
                    'number':   $('_number').value,
                    'gender':   $('_gender').value,
                    'order':    $('_order').value
                },
                onSuccess: function (err) {
                    if (err.params.valid.toLowerCase() != 'vigente') {
                        $('msgValido').hide();
                        $('resultado_ok').hide();
                        $('resultado_error').show();
                        $('msgInvalido').show();
                        $('tbResultado').innerHTML = '';
                    }
                    else {
                        $('msgInvalido').hide();
                        $('msgValido').show();
                        $('resultado_error').hide();
                        $('resultado_ok').show();
                        $('tbResultado').innerHTML = err.params.html_response;
                    }

                    en_proceso_de_validacion = false;
                },
                onFailure: function (err) {
                    $('msgValido').hide();
                    $('resultado_ok').hide();
                    $('resultado_error').show();
                    $('msgInvalido').show();
                    $('tbResultado').innerHTML = '';

                    alert(err.mensaje, {
                        title: '<b>' + err.titulo + '</b>'
                    });

                    en_proceso_de_validacion = false;
                },
                error_alert: false,
                bloq_msg: 'Validando identidad...'
            });
        }



        function isEnterKey(evento)
        {
            if ((evento.keyCode || evento.which) === 13) {
                validarIdentidad();
            }
        }
    </script>
</head>
<body onload="WindowOnload()" onresize='WindowOnresize()' style="overflow: auto;">
    
    <div id="divMenu"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');

        Menus["vMenu"]            = vMenu;
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo     = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Registro Nacional de Personas</Desc></MenuItem>")
        
        vMenu.MostrarMenu()
    </script>

    <table class="tb1">
        <tr class="tbLabel">
            <td colspan="2">PAQUETE III: Nº DNI + Género + Nº trámite</td>
        </tr>
        <tr>
            <!-- TABLE inputs -->
            <td style="width: 40%; vertical-align: top;">
                <table class="tb1">
                    <tr>
                        <td class="Tit1">Nro. DNI</td>
                        <td>
                            <% = nvCampo_def.get_html_input("_number", enDB:=False, nro_campo_tipo:=100) %>
                            <script type="text/javascript">
                                campos_defs.items['_number'].input_hidden.onkeypress = isEnterKey;
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1">Género</td>
                        <td>
                            <select name="_gender" id="_gender" style="width: 100%;">
                                <option value="">-- Seleccionar --</option>
                                <option value="F">Femenino</option>
                                <option value="M">Masculino</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1">Nro. trámite</td>
                        <td>
                            <% = nvCampo_def.get_html_input("_order", enDB:=False, nro_campo_tipo:=100) %>
                            <script type="text/javascript">
                                campos_defs.items['_order'].input_hidden.onkeypress = isEnterKey;
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td style="text-align: right; padding-top: 5px;">
                            <div id="divVerificar"></div>
                        </td>
                    </tr>
                    <tr>
                        <td style="text-align: center; vertical-align: middle;">
                            <img alt="resultado" src="/FW/image/icons/tilde.png" id="resultado_ok" style="display: none;" />
                            <img alt="resultado" src="/FW/image/icons/eliminar.png" id="resultado_error" style="display: none;" />
                        </td>
                        <td>
                            <p style="display: none; color: #ce2727; text-align: center; font-weight: bold; font-size: 3em;" id="msgInvalido">INVALIDO</p>
                            <p style="display: none; color: #2f9f26; text-align: center; font-weight: bold; font-size: 3em;" id="msgValido">VALIDO</p>
                        </td>
                    </tr>
                </table>
            </td>
            
            <!-- TABLE outputs -->
            <td id="tbResultado"></td>
        </tr>
    </table>

</body>
</html>