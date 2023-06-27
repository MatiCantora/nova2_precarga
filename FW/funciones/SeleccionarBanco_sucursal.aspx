<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageFW" %>
<%
    Response.Expires = 0

    Dim id_ventana As String = obtenerValor("id_ventana", "")
    Dim nro_banco As String = obtenerValor("nro_banco", "")

    Me.contents("filtro_verBancoSucursal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verBancoSucursal'><campos>id_banco_sucursal, cod_sucursal, cod_cbu, Banco_sucursal</campos><filtro><nro_banco type='igual'>%nro_banco%</nro_banco></filtro><orden>cod_sucursal ASC</orden></select></criterio>")
    Me.contents("filtro_bancoSucursal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banco_sucursal'><campos>cod_sucursal, banco_sucursal</campos><filtro><id_banco_sucursal type='igual'>%id_banco_sucursal%</id_banco_sucursal></filtro><orden>cod_sucursal ASC</orden></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Seleccionar Sucursal</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    
    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var win = nvFW.getMyWindow()
        var vButtonItems = {};
        var nro_banco

        vButtonItems[0] = {};
        vButtonItems[0]["nombre"]   = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"]   = "buscar";
        vButtonItems[0]["onclick"]  = "return Buscar_Sucursal()";

        var vListButton = new tListButton(vButtonItems,'vListButton');
        vListButton.loadImage("buscar", "/FW/image/icons/buscar.png")


        function window_onload()
        {
            vListButton.MostrarListButton()
            
            nro_banco = win.options.userData.ParamBco['nro_banco']
            $('nro_banco').value = nro_banco
            
            try {
                var h_body   = $$("body")[0].getHeight()
                var h_tbCabe = $("tbCabe").getHeight()

                $("iframe1").setStyle({ height: h_body - h_tbCabe + "px" })
            }
            catch(e) {}

            Buscar_Sucursal()
        }


        function Buscar_Sucursal()
        {
            var filtro = ''

            if ($('cod_sucursal').value != '') {
                filtro += "<cod_sucursal type='like'>%" + $('cod_sucursal').value + "%</cod_sucursal>"
            }

            if ($('cod_cbu').value != '') {
                filtro += "<cod_cbu type='like'>%" + $('cod_cbu').value + "%</cod_cbu>"
            }

            if ($('banco_sucursal').value != '') {
                filtro += "<banco_sucursal type='like'>%" + $('banco_sucursal').value + "%</banco_sucursal>"
            }

            nvFW.exportarReporte({
                //filtroXML: "<criterio><select vista='verBancoSucursal'><campos>id_banco_sucursal, cod_sucursal, cod_cbu, Banco_sucursal</campos><filtro><nro_banco type='igual'>" + nro_banco + "</nro_banco>" + filtro + "</filtro><orden></orden></select></criterio>",
                filtroXML: nvFW.pageContents.filtro_verBancoSucursal,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                params: "<criterio><params nro_banco='" + nro_banco + "' /></criterio>",
                //xsl_name: 'HTML_verBancoSucursal.xsl',
                path_xsl: "report/funciones/HTML_verBancoSucursal.xsl",
                formTarget: 'iframe1',
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe1',
                cls_contenedor_msg: ' ',
                bloq_contenedor: 'iframe1',
                bloq_msg: 'Buscando...'
            })  
        }


        function Seleccion(id_banco_sucursal)
        {
            var cod_sucursal = 0
            var banco_sucursal = 0
            var rs = new tRS();

            //rs.open("<criterio><select vista='Banco_sucursal'><campos>cod_sucursal, banco_sucursal</campos><filtro><id_banco_sucursal type='igual'>" + id_banco_sucursal + "</id_banco_sucursal></filtro><orden></orden></select></criterio>") 
            rs.open({
                filtroXML: nvFW.pageContents.filtro_bancoSucursal,
                params: "<criterio><params id_banco_sucursal='" + id_banco_sucursal + "' /></criterio>"
            })
            
            if (!rs.eof()) {
                cod_sucursal   = rs.getdata('cod_sucursal')
                banco_sucursal = rs.getdata('banco_sucursal')
            }

            try {
                var Parametros_sel = {}
                Parametros_sel['id_banco_sucursal'] = id_banco_sucursal
                Parametros_sel['cod_sucursal']      = cod_sucursal
                Parametros_sel['banco_sucursal']    = banco_sucursal

                var id_ventana = $('id_ventana').value
                //var win = nvFW.getMyWindow()
                win.options.userData = { Parametros_sel: Parametros_sel }
                win.close()
            }
            catch(e) {
                window.top.alert('Error al seleccionar la sucursal.')
                return
            }
        }


        function sucursal_onkeypress(e)
        {
            (e.keyCode == 13 || e.which == 13) && Buscar_Sucursal()
            //var tecla = (document.all) ? event.keyCode : e.which;
            //if (tecla == 13)
            //    Buscar_Sucursal();
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto; background-color: white;">
    <input type="hidden" id="id_ventana" value="<% = id_ventana %>" />
    <input type="hidden" id="nro_banco" value="<% = nro_banco %>" />

    <table class="tb1" id="tbCabe">
        <tr>
            <td style="width: 75%">
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 20%">Código</td>
                        <td style="width: 20%">Cód. CBU</td>
                        <td style="width: 60%">Sucursal</td>
                    </tr>
                    <tr>
                        <td>
                            <input type="text" style="width:100%" value="" id="cod_sucursal" name="cod_sucursal" onkeypress="sucursal_onkeypress(event)"/>  
                        </td>
                        <td>
                            <input type="text" style="width:100%" value="" id="cod_cbu" name="cod_cbu" onkeypress="sucursal_onkeypress(event)"/>  
                        </td>
                        <td>
                            <input type="text" style="width:100%" value="" id="banco_sucursal" name="banco_sucursal" onkeypress="sucursal_onkeypress(event)"/>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="vertical-align:bottom">
                <div id="divBuscar"></div>
            </td>
        </tr>
    </table>

    <iframe name="iframe1" id="iframe1" height="135px" width="100%" frameborder="0" marginwidth="0" marginheight="0" src="/FW/enBlanco.htm"></iframe>
</body>
</html>

    


