<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" EnableSessionState="ReadOnly" %>
<%
    Dim permiso_grupo As String = "permisos_herramientas"
    Dim nro_permiso As Integer = 1  ' Consulta COELSA

    If Not nvFW.nvApp.getInstance().operador.tienePermiso(permiso_grupo, nro_permiso) Then
        Response.Redirect("/FW/error/httpError_401.aspx?subtitulo=No tiene permiso para ésta herramienta", True)
    End If

    Dim accion As String = nvUtiles.obtenerValor("accion", "")


    If accion <> String.Empty Then
        Dim err As New tError
        Dim valorA As String = nvUtiles.obtenerValor("valorA", "")  ' CUIT
        Dim valorB As String = nvUtiles.obtenerValor("valorB", "")  ' CBU o ALIAS

        Select Case accion.ToLower()
            Case "cuitcbu"
                err = nvFW.servicios.nvCoelsa.ControlCuitCbu(valorA, valorB)

            Case "aliascuit"
                err = nvFW.servicios.nvCoelsa.ControlAliasCuit(valorB, valorA)

        End Select

        err.response()
    End If
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html lang="es-ar" xml:lang="es-ar" xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>WS COELSA</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        input[type=radio]:focus { outline: none; box-shadow: none; }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        // Control seleccionado
        var control_seleccionado = 'cuitcbu';
        // Boton de consulta
        var vButton_items = [];
        vButton_items[0]  = {};
        vButton_items[0].nombre   = "Consultar";
        vButton_items[0].etiqueta = "Consultar";
        vButton_items[0].imagen   = "";
        vButton_items[0].onclick  = "return consultarServicioCoelsa()";
        var vList_button = new tListButton(vButton_items, 'vList_button');



        function windowOnload()
        {
            vList_button.MostrarListButton();
            
            var this_win = nvFW.getMyWindow();
            this_win.options.minWidth  = 580;
            this_win.options.minHeight = 200;
        }



        function windowOnresize()
        {
        }



        function radioOnclick(valor)
        {
            if (valor)
            {
                control_seleccionado = valor;

                switch (valor)
                {
                    case 'cuitcbu':
                        $('trAlias').hide();
                        $('trCbu').show();
                        break;

                    case 'aliascuit':
                        $('trCbu').hide();
                        $('trAlias').show();
                        break;
                }
            }
        }



        function checkInputs()
        {
            var mensajes = '';

            // El CUIT se valida siempre porque participa de ambos servicios
            if (campos_defs.get_value('cuit').toString().length !== 11)
            {
                mensajes += '* El <b>CUIT</b> debe contener exactamente 11 caracteres numéricos, sin guiones.<br/>';
            }

            if (control_seleccionado == 'cuitcbu')
            {
                // Aquí comprueba sólo CBU
                if (campos_defs.get_value('cbu').toString().length !== 22)
                {
                    mensajes += '* El <b>CBU</b> debe contener exactamente 22 caracteres numéricos.<br/>';
                }
            }
            else
            {
                // Aquí comprueba sólo Alias
                var alias = campos_defs.get_value('alias').toString().length;

                if (alias < 6 || alias > 20)
                {
                    mensajes += '* El <b>Alias</b> debe contener entre 6 y 20 caracteres alfanuméricos (mínimo y máximo respectivamente). Actualmente contiene ' + alias + ' caracteres.<br/>';
                }
            }

            return mensajes ? 'Por favor, revise los siguientes mensajes:<br/><br/>' + mensajes : '';
        }



        function consultarServicioCoelsa()
        {
            var mensajes_check = checkInputs();

            if (mensajes_check)
            {
                alert(mensajes_check, { title: '<b>Datos inválidos</b>', width: 500, height: 150 });
                return false;
            }

            $('tbResultados').select('tbody')[0].innerHTML = '';

            error_ajax_request('consultar.aspx',
                {
                    parameters: 
                    {
                        'accion': control_seleccionado,
                        'valorA': campos_defs.get_value('cuit'),   // siempre es el CUIT
                        'valorB': control_seleccionado == 'cuitcbu' ? campos_defs.get_value('cbu') : campos_defs.get_value('alias')  // puede ser el CBU o el ALIAS
                    },
                    onSuccess: function (err)
                    {
                        $('tbResultados').select('tbody')[0].innerHTML = err.params.html_response;
                    },
                    onFailure: function (err)
                    {
                        if (err.numError !== 0)
                        {
                            alert(err.mensaje, { title: '<b>' + err.titulo + '</b>', width: 400, height: 110 });
                        }
                        
                        if (err.params.html_response)
                        {
                            $('tbResultados').select('tbody')[0].innerHTML = err.params.html_response;
                        }
                    },
                    bloq_msg: 'Comprobando...',
                    error_alert: false
                });
        }
    </script>
</head>
<body onload="windowOnload()" onresize='windowOnresize()' style="width: 100%; height: 100%; margin: 0; overflow: hidden;">

    <table class="tb1">
        <tr>
            <td class="Tit1" style="text-align: center;">Tipo de Control</td>
            <td class="Tit1" colspan="2" style="text-align: center;">Parametros</td>
        </tr>
        <tr>
            <td rowspan="3" style="width: 150px;" class="Tit4">
                <label for="control1" style="display: block;"><input type="radio" id="control1" name="control" value="cuitcbu" checked="checked" onclick="radioOnclick(this.value)" style="cursor: pointer;" title="Control CUIT-CBU" /> CUIT-CBU</label>
                <label for="control2" style="display: block;"><input type="radio" id="control2" name="control" value="aliascuit" onclick="radioOnclick(this.value)" style="cursor: pointer;" title="Control Alias-CUIT" /> Alias-CUIT</label>
            </td>
        </tr>

        <tr id="trCuit">
            <td class="Tit4">CUIT</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("cuit", enDB:=False, nro_campo_tipo:=100) %>
            </td>
        </tr>

        <tr id="trCbu">
            <td class="Tit4">CBU</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("cbu", enDB:=False, nro_campo_tipo:=100) %>
            </td>
        </tr>

        <tr id="trAlias" style="display: none;">
            <td class="Tit4">Alias</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("alias", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>

        <tr>
            <td colspan="3">
                <table class="tb1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td style="width: 30%;">
                            <div id="divConsultar"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <table class="tb1 highlightEven highlightTROver" id="tbResultados">
        <tbody></tbody>
    </table>

</body>
</html>
