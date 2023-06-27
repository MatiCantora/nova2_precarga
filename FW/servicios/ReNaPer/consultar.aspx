<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim permiso_grupo As String = "permisos_herramientas"
    Dim nro_permiso As Integer = 2  ' Consulta ReNaPer

    If Not nvFW.nvApp.getInstance().operador.tienePermiso(permiso_grupo, nro_permiso) Then
        Response.Redirect("/FW/error/httpError_401.aspx?subtitulo=No tiene permiso para �sta herramienta", True)
    End If

    Dim servicio As String = nvUtiles.obtenerValor("servicio", "").ToString().ToLower()

    If servicio <> "" Then
        Dim err As New tError()

        Select Case servicio

            Case "validar_paquete_3"
                Dim number As String = nvUtiles.obtenerValor("number", "")
                Dim gender As String = nvUtiles.obtenerValor("gender", "")
                Dim order As String = nvUtiles.obtenerValor("order", "")
                Dim error_message As String = String.Empty

                If number = String.Empty OrElse number.Length > 8 Then
                    error_message &= "N�mero de DNI inv�lido." & vbCrLf
                End If

                If gender = String.Empty OrElse gender.Length <> 1 Then
                    error_message &= "G�nero inv�lido." & vbCrLf
                End If

                If order = String.Empty Then
                    error_message &= "N�mero de tr�mite inv�lido." & vbCrLf
                End If


                If error_message <> String.Empty Then
                    err.numError = 1
                    err.titulo = "Error en par�metros"
                    err.mensaje = "Uno o m�s par�metros son inv�lidos. Revise los siguientes mensajes:" & vbCrLf & error_message
                Else
                    err = nvFW.servicios.Renaper.ValidarIdentidad(number, gender, order)

                    If err.numError = 0 AndAlso err.params("valid").ToString.ToLower <> "vigente" Then
                        err.numError = 1
                        err.titulo = "DNI inv�lido"
                        err.mensaje = "El servicio de RENAPER ha detectado que el DNI presentado es inv�lido."
                    End If
                End If

                err.response()

        End Select
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar ReNaPer</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var en_proceso_de_validacion = false;   // Flag para evitar que se env�en Requests en simult�neo (Ej: si dan muchas veces enter lanzando la validaci�n)
        
        var buttonItems = {};
        buttonItems[0]  = [];
        buttonItems[0].nombre   = "Verificar";
        buttonItems[0].etiqueta = "Verificar Identidad";
        buttonItems[0].imagen   = "engine";
        buttonItems[0].onclick  = "return validarIdentidad();";

        var listButtons = new tListButton(buttonItems, 'listButtons');
        listButtons.loadImage('engine', '/FW/image/icons/procesar.png');



        function windowOnload()
        {
            nvFW.enterToTab = false;
            listButtons.MostrarListButton();

            // Asignar los placehoder para ayuda extra
            $('number').placeholder = 'Ej: 19546999';
            $('order').placeholder = 'Ej: 00849163375';

            windowOnresize();
        }



        function windowOnresize()
        {
        }



        function validarIdentidad()
        {
            // Comprobar si no hay un proceso de validaci�n sin terminar
            if (en_proceso_de_validacion) return false;


            var messages = '';
            
            if (!$('number').value || $('number').value.length > 8) {
                messages += 'El n�mero de <b>DNI</b> es inv�lido.<br/>';
            }

            if (!$('gender').value) {
                messages += 'No se ha seleccionado el <b>g�nero</b> de la persona.<br/>';
            }

            if (!$('order').value || $('order').value.length != 11) {
                messages += 'El n�mero de <b>tr�mite</b> es inv�lido.<br/>';
            }
            
            if (messages) {
                alert('Uno o m�s par�metros est�n vac�os o son inv�lidos. Revise los siguientes mensajes:<br/><br/>' + messages, {
                    title:  '<b>Error en parametros</b>',
                    height: 135
                });

                return false;
            }

            // Activar la bandera
            en_proceso_de_validacion = true;

            $('msgValido').hide();
            $('resultado_ok').hide();
            $('resultado_error').hide();
            $('msgInvalido').hide();
            $('tbResultado').innerHTML = '';


            nvFW.error_ajax_request('consultar.aspx', {
                parameters: {
                    'servicio': 'validar_paquete_3',
                    'number':   $('number').value,
                    'gender':   $('gender').value,
                    'order':    $('order').value
                },
                onSuccess: function (err) {
                    if (err.params.valid.toLowerCase() != 'vigente') {
                        $('resultado_error').show();
                        $('msgInvalido').show();
                    }
                    else {
                        $('msgValido').show();
                        $('resultado_ok').show();
                        $('tbResultado').innerHTML = err.params.html_response;
                    }

                    en_proceso_de_validacion = false;
                },
                onFailure: function (err) {
                    $('resultado_error').show();
                    $('msgInvalido').show();

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
<body onload="windowOnload()" onresize='windowOnresize()' style="overflow: auto;">
    
    <div id="divMenu"></div>
    <script type="text/javascript">
        var vMenu              = new tMenu('divMenu', 'vMenu');
        Menus.vMenu            = vMenu;
        Menus.vMenu.alineacion = 'centro';
        Menus.vMenu.estilo     = 'A';
        Menus.vMenu.CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Registro Nacional de Personas</Desc></MenuItem>");
        vMenu.MostrarMenu()
    </script>

    <table class="tb1">
        <tr class="tbLabel">
            <td colspan="2">PAQUETE III: N� DNI + G�nero + N� tr�mite</td>
        </tr>
        <tr>
            <!-- TABLE inputs -->
            <td style="width: 40%; vertical-align: top;">
                <table class="tb1">
                    <tr>
                        <td class="Tit1" style="text-align: right;">Nro. DNI</td>
                        <td>
                            <% = nvCampo_def.get_html_input("number", enDB:=False, nro_campo_tipo:=100) %>
                            <script type="text/javascript">
                                campos_defs.items['number'].input_hidden.onkeypress = isEnterKey;
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1" style="text-align: right;">G�nero</td>
                        <td>
                            <select name="gender" id="gender" style="width: 100%;">
                                <option value="">-- Seleccionar --</option>
                                <option value="F">Femenino</option>
                                <option value="M">Masculino</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="Tit1" style="text-align: right;">Nro. tr�mite</td>
                        <td>
                            <% = nvCampo_def.get_html_input("order", enDB:=False, nro_campo_tipo:=100) %>
                            <script type="text/javascript">
                                campos_defs.items['order'].input_hidden.onkeypress = isEnterKey;
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