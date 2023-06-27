<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_entidad = nvFW.nvUtiles.obtenerValor("nro_entidad")
    Dim pago_tipo As String = nvFW.nvUtiles.obtenerValor("pago_tipo", "")
    Me.contents("filtro_entidad_bco_ctas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

    Me.contents("pago_tipo") = pago_tipo

%>
<html>
<head>
    <title>Pago Depósitos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win
        var indice      = -1
        var vParametros = {}
        var Cuentas
        var pago_tipo = 'Depósito'

        function window_onload()
        {
            if (nvFW.pageContents.pago_tipo != "")
                pago_tipo = nvFW.pageContents.pago_tipo
            CargarCuentas()
        }


        function CargarCuentas()
        {
            Cuentas = {}
            var i = 0
            var rs = new tRS();
            rs.open(nvFW.pageContents.filtro_entidad_bco_ctas, "", "<nro_entidad type='igual'>" + $('nro_entidad').value + "</nro_entidad>")
            while (!rs.eof()) {
                Cuentas[i] = {}
                Cuentas[i]["id_cuenta"]         = rs.getdata('id_cuenta')
                Cuentas[i]["id_cuenta_old"]     = rs.getdata('id_cuenta_old')
                Cuentas[i]["nro_banco"]         = rs.getdata('nro_banco')
                Cuentas[i]["banco"]             = rs.getdata('banco')
                Cuentas[i]["id_banco_sucursal"] = rs.getdata('id_banco_sucursal')
                Cuentas[i]["banco_sucursal"]    = rs.getdata('banco_sucursal')
                Cuentas[i]["tipo_cuenta"]       = rs.getdata('tipo_cuenta')
                Cuentas[i]["tipo_cuenta_desc"]  = rs.getdata('tipo_cuenta_desc')
                Cuentas[i]["nro_cuenta"]        = rs.getdata('nro_cuenta')
                Cuentas[i]["desc"]              = rs.getdata('descripcion')
                Cuentas[i]["descripcion"]       = 'Banco: ' + rs.getdata('banco') + ' - Cuenta: ' + rs.getdata('tipo_cuenta_desc') + ': ' + rs.getdata('nro_cuenta')
                
                i++
                rs.movenext()
            }

            $('divCuentas').innerHTML = ""
            var strHTML = "<table class='tb1'><tr class='tbLabel'><td nowrap><b>Banco - Sucursal</b></td><td nowrap><b>Tipo Cta</b></td><td nowrap><b>Nro. Cuenta</b></td></tr>"
            for (j in Cuentas) {
                var checkeador = ''
                if (j == 0)
                    checkeador = "checked"
                indice = 0
                strHTML += "<tr><td><input type='radio' " + checkeador + " style='border:none' name='RCuenta' id='RCuenta' value='" + j + "' onclick='return RCuenta_onclick(" + j + ")' >"
                strHTML += Cuentas[j]["banco"] + " - " + Cuentas[j]["banco_sucursal"] + "  " + Cuentas[j]["desc"] + "</td><td style='text-align: right'>" + Cuentas[j]["tipo_cuenta_desc"] + "&nbsp;</td><td style='text-align: right'>" + Cuentas[j]["nro_cuenta"] + "&nbsp;</td></tr>"
            }

            strHTML += "</table>"
            $('divCuentas').insert({ top: strHTML })
        }


        function RCuenta_onclick(j)
        {
            indice = j
        }


        function getParametros_pago()
        {
            var pago_detalle = {}
            
            if (indice == -1)
            {
                alert('No existen cuentas para seleccionar.')
                pago_detalle['nro_pago_detalle'] = ''
                pago_detalle['nro_pago_tipo']    = '1'
                pago_detalle['pago_tipo']        = pago_tipo
                pago_detalle['importe_pago']     = 0
                pago_detalle['pg_desc']          = ''
                pago_detalle['parametros']       = {}
                
            }
            else
            {
                pago_detalle['nro_pago_detalle'] = ''
                pago_detalle['nro_pago_tipo']    = 1
                pago_detalle['pago_tipo']        = pago_tipo
                pago_detalle['importe_pago']     = 0
                pago_detalle['pago_estados']     = "Pendiente"
                pago_detalle['nro_pago_estado']  = 1
                pago_detalle['pg_desc']          = Cuentas[indice]["descripcion"]
                pago_detalle['dep_id_cuenta']    = Cuentas[indice]["id_cuenta"]
                pago_detalle['parametros']       = {}
                pago_detalle['parametros']['nro_banco']          = Cuentas[indice]["nro_banco"]
                pago_detalle['parametros']['nro_banco_sucursal'] = Cuentas[indice]["id_banco_sucursal"]
                pago_detalle['parametros']['nro_comprobante']    = ''
                pago_detalle['parametros']['id_cuenta']          = Cuentas[indice]["id_cuenta"]
                pago_detalle['parametros']['nro_cuenta']         = Cuentas[indice]["nro_cuenta"]
                pago_detalle['parametros']['tipo_cuenta']        = Cuentas[indice]["tipo_cuenta"]
            }

            return pago_detalle
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto;">
    <form action="Pago_deposito.aspx" method="post" name="formAltaCuenta" target="frameEnviar" style="margin: 0;">
        <input type="hidden" id="nro_entidad" name="nro_entidad" value="<% = nro_entidad %>"/>
        <div id="divCuentas" style='width: 100%; height: 100%;'></div>
    </form>
</body>
</html>
