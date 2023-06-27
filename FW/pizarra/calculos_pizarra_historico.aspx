<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" EnableSessionState="ReadOnly" %>
<% 
    Dim nro_calc_pizarra As Integer = nvFW.nvUtiles.obtenerValor("nro_calc_pizarra", "0", nvConvertUtiles.DataTypes.int)
    Me.contents("filtro_historicos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPizarras_historico'><campos>fecha, fe_to_show, operador, [login], full_name as fullName</campos><filtro><nro_calc_pizarra type='igual'>" & nro_calc_pizarra & "</nro_calc_pizarra></filtro><orden>fecha</orden></select></criterio>")
%>
<html>
<head>
    <title>Pizarra Histórico</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var ventana = nvFW.getMyWindow();
        var dif = Prototype.Browser.IE ? 5 : 0;


        function WindowOnLoad()
        {
            CargarYDibujarHistoricos();
            AjustarAlturaContenido();
        }


        function AjustarAlturaContenido()
        {
            try
            {
                var alturaDiv = $$('body')[0].getHeight() - $('tbCabecera').getHeight();
                $('divHistoricos').setStyle({ height: alturaDiv + 'px' });
            }
            catch (e) {}
        }


        function CargarYDibujarHistoricos()
        {
            var rs = new tRS();
            rs.async = true;

            rs.onComplete = function (res)
            {
                if (!res.recordcount)
                {
                    $('divHistoricos').innerHTML = '<p style="margin: 0; padding-top: 90px; text-align: center;">No existen registros históricos para la pizarra actual</p>';
                }
                else
                {
                    var html = '';

                    while (!res.eof())
                    {
                        html += '<tr>';
                        html += '<td style="width: 30px; text-align: center;"><img alt="select icon" src="/FW/image/icons/seleccionar.png" onclick="return SeleccionarFechaHistorico(\'' + res.getdata('fecha', '1900-01-01 00:00:00') + '\', \'' + res.getdata('login', 'N/D') + '\');" style="cursor: pointer;" title="Seleccionar" /></td>';
                        html += '<td style="width: 200px; text-align: right;">' + res.getdata('fe_to_show', 'Lunes 01/01/1900 00:00:00') + '&nbsp;</td>';
                        html += '<td style="width: 70px; text-align: right;">' + res.getdata('operador', '-1') + '&nbsp;</td>';
                        html += '<td style="width: 100px;">&nbsp;' + res.getdata('login', 'N/D') + '</td>';
                        html += '<td>&nbsp;' + res.getdata('fullName', 'N/D') + '</td>';
                        html += '</tr>';

                        res.movenext();
                    }

                    $('tbHistoricos').innerHTML = html;
                }

                nvFW.bloqueo_desactivar(null, 'vidrio_inicial');
            }

            rs.open(nvFW.pageContents.filtro_historicos);
        }


        function SeleccionarFechaHistorico(strFecha, strLogin)
        {
            if (strFecha)
            {
                ventana.options.userData.cargarHistorico = true;
                ventana.options.userData.fecha           = strFecha;
                ventana.options.userData.login           = strLogin;
            }
            else {
                ventana.options.userData.cargarHistorico = false;
                ventana.options.userData.fecha           = '';
                ventana.options.userData.login           = '';
            }

            ventana.close();
        }
    </script>
</head>
<body onload="WindowOnLoad()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">

    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'vidrio_inicial', 'Cargando histórico pizarra...');</script>

    <table class="tb1" id="tbCabecera">
        <tr class="tbLabel">
            <td style="width: 30px; text-align: center;">&nbsp;</td>
            <td style="width: 200px; text-align: center;">Fecha</td>
            <td style="width: 70px; text-align: center;">Operador</td>
            <td style="width: 100px; text-align: center;">Login</td>
            <td style="text-align: center;">Nombre</td>
        </tr>
    </table>

    <div id="divHistoricos" style="overflow: auto;">
        <table class="tb1 highlightOdd highlightTROver" id="tbHistoricos"></table>
    </div>
</body>
</html>