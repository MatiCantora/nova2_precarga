<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_ventana As String = nvFW.nvUtiles.obtenerValor("id_ventana", "")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Seleccionar Pagos Tipos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <script type="text/javascript">
        var win
        var vPago_registro = {}
        var nro_pago_registro
        var importe_pago
        var diferencia
        var total
        var id
        var nro_mutual
        var indice

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Seleccionar";
        vButtonItems[0]["etiqueta"] = "Seleccionar";
        vButtonItems[0]["imagen"] = "seleccionar";
        vButtonItems[0]["onclick"] = "return Seleccionar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("seleccionar", "/FW/image/icons/seleccionar.png")

        var pago_detalle = {}


        function Seleccionar() {
            
            if ($('nro_pago_tipo').value != '') {
                if ($('nro_pago_estado').value == '') {
                    alert('Seleccione un estado para el pago')
                    return
                }
                else {
                    if ($('nro_pago_tipo').value == 1 || $('nro_pago_tipo').value == 6) {
                        pago_detalle = ObtenerVentana('ifrmMostrar_Tipo').getParametros_pago()
                        if (Object.keys(pago_detalle.parametros).length == 0 && $('nro_pago_tipo').value == 1) {
                            return
                        }
                    }
                    else {
                        pago_detalle = {}
                        pago_detalle['nro_pago_detalle'] = ''
                        pago_detalle['nro_pago_tipo'] = $('nro_pago_tipo').value
                        pago_detalle['pago_tipo'] = campos_defs.desc('nro_pago_tipo')
                        pago_detalle['importe_pago'] = 0
                        pago_detalle['pg_desc'] = ''
                        pago_detalle['parametros'] = {}
                    }

                    pago_detalle['pago_estados'] = campos_defs.get_desc('nro_pago_estado').split(" (")[0]
                    pago_detalle['nro_pago_estado'] = campos_defs.get_value('nro_pago_estado')

                    var a = pago_detalle['nro_pago_estado']

                    if (a) {
                        var win = nvFW.getMyWindow()
                        win.options.userData = { res: pago_detalle }
                        win.close()
                    }
                    else
                        return
                }
            }
            else {
                alert('Seleccione un Pago para agregar.')
                return
            }
        }


        var nro_entidad
        var pago_detalle
        var tipo
        var parametros
        var filtro_tipo = ''


        function Inicio() {
            vListButton.MostrarListButton()
            win = nvFW.getMyWindow()

            pago_detalle = win.options.userData.Param_Tipo
            nro_entidad = pago_detalle["nro_entidad"]
            $('nro_entidad').value = pago_detalle["nro_entidad"]
            tipo = pago_detalle["tipo"]
            parametros = pago_detalle["parametros"]

            if (tipo == 'P')
                filtro_tipo = "<pago_habilitado type='igual'>1</pago_habilitado>"

            if (tipo == 'C')
                filtro_tipo = "<cobro_habilitado type='igual'>1</cobro_habilitado>"

            if (id)
                campos_defs.set_value('nro_pago_tipo', id)

            campos_defs.items['nro_pago_tipo']['onchange'] = Mostrar
            campos_defs.habilitar("nro_pago_estado", false)
        }


        function Mostrar() {
            var valor = $('nro_pago_tipo').value
            var nro_entidad = $('nro_entidad').value

            if (!valor) {
                campos_defs.habilitar("nro_pago_estado", false)
                campos_defs.clear("nro_pago_estado")
            }
            else {
                switch (valor) {
                    // Cheque Bejerman
                    case '6':
                        ObtenerVentana('ifrmMostrar_Tipo').location.href = "Pago_bejerman_chq.aspx?nro_entidad=" + nro_entidad + "&parametros=" + parametros //@@@@
                        break

                    // Depósito 3ros
                    case '1':
                        $('divSeleccionar').disabled = false
                        ObtenerVentana('ifrmMostrar_Tipo').location.href = "Pago_deposito.aspx?nro_entidad=" + nro_entidad + "&pago_tipo=" + campos_defs.get_desc("nro_pago_tipo") + "" //@@@@
                        break

                    default:
                        $('divSeleccionar').disabled = false
                        ObtenerVentana('ifrmMostrar_Tipo').location.href = '/FW/enBlanco.htm'
                }

                campos_defs.habilitar("nro_pago_estado", true)
            }
        }
    </script>
</head>
<body onload="return Inicio()">
    <input type="hidden" name="pago_concepto" id="pago_concepto" />
    <input type="hidden" name="importe_pago" id="importe_pago" />
    <input type="hidden" name="nro_entidad" id="nro_entidad" />
    <input type="hidden" name="id_ventana" id="id_ventana" value="<% = id_ventana %>" />

    <table class="tb1">
        <tr>
            <td style="width: 50%; text-align: center;">
                <% = nvFW.nvCampo_def.get_html_input("nro_pago_tipo") %>
            </td>
            <td style="width: 25%; text-align: center;">
                <% = nvFW.nvCampo_def.get_html_input("nro_pago_estado") %>
            </td>
            <td style="text-align: center;">
                <div style="width: 100%" id="divSeleccionar"></div>
            </td>
        </tr>
    </table>

    <iframe src='/FW/enblanco.htm' style="width: 100%; height: 250px; border: none;" id="ifrmMostrar_Tipo" name="ifrmMostrar_Tipo"></iframe>
</body>
</html>
