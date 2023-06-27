<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Me.contents("filtro_banco") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>DISTINCT nro_bancoBCRA, banco</campos><orden>banco</orden><filtro><nro_permiso_consulta type='sql'>dbo.rm_tiene_permiso('permisos_pagos_consultar', nro_permiso_consulta) = 1</nro_permiso_consulta></filtro></select></criterio>")
    Me.contents("filtro_cuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>nro_bancoBCRA, cuenta</campos><orden>cuenta</orden><grupo>cuenta, nro_bancoBCRA</grupo><filtro><nro_permiso_consulta type='sql'>dbo.rm_tiene_permiso('permisos_pagos_consultar', nro_permiso_consulta) = 1</nro_permiso_consulta></filtro></select></criterio>")
    Me.contents("filtro_cuenta2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>COALESCE(chequera, '') AS chequera</campos><orden>chequera</orden><grupo>chequera</grupo></select></criterio>")
    Me.contents("filtro_imprimir_banco") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='WRP_PG_Registro'><campos>SUM(importe_param) AS importe</campos></select></criterio>")
    Me.contents("filtro_ctrl_importe_max") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>importe_maximo</campos></select></criterio>")
    Me.contents("filtro_ctrl_importe_max2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_registro,nro_pago_detalle</campos><filtro><nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_dividir_pagos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_registro, nro_pago_detalle</campos><filtro><nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado></filtro></select></criterio>")
    Me.contents("filtro_dividir_pagos_exp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_pagos_dividir' CommantTimeOut='1500' vista='wrp_pg_registro'><parametros><nro_pago_detalle DataType='int'>%param1%</nro_pago_detalle><nro_pago_registro DataType='int'>%param2%</nro_pago_registro><importe_maximo DataType='money'>%param3%</importe_maximo></parametros></procedure></criterio>")
    Me.contents("filtro_imprimir_cheques") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Bj_Cuentas'><campos>empresa</campos></select></criterio>")
    Me.contents("filtro_ultimoCheque") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPagos_cheques'><campos>MAX(nro_cheque) AS nro_cheque</campos></select></criterio>")
%>
<html>
<head>
    <title>Seleccionar Chequera</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var inCredito
        var strError = ""
        var nro_pagos_registros
        var Parametros = []
        var cuenta
        var filtro_credito

        // Botones
        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Imprimir";
        vButtonItems[0]["etiqueta"] = "Imprimir";
        vButtonItems[0]["imagen"]   = "imprimir";
        vButtonItems[0]["onclick"]  = "return Imprimir()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("imprimir", "/FW/image/icons/imprimir.png")


        function CargarBanco() {
            var rs = new tRS()
            $('banco').options.length = 0
            //rs.open("<criterio><select vista='Bj_Cuentas'><campos>distinct nro_bancoBCRA, banco</campos><orden>banco</orden><filtro><nro_permiso_consulta type='sql'>dbo.rm_tiene_permiso('permisos_pagos_consultar', nro_permiso_consulta) = 1</nro_permiso_consulta></filtro></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents.filtro_banco })

            while (!rs.eof()) {
                $('banco').insert(new Element('option', { value: rs.getdata('nro_bancoBCRA'), width: '100%' }).update(rs.getdata('banco')))
                
                if (rs.getdata('banco') == 'Nuevo Banco Santa Fe S.A.') {
                      $('banco').selectedIndex = $('banco').options.length - 1
                }
                rs.movenext()
            }

            $('banco').setStyle({ width: "100%" })
            banco_onchange()
        }


        function CargarCuenta(nro_banco) {
            var rs = new tRS()
            $('cuenta').options.length = 0
            //rs.open("<criterio><select vista='Bj_Cuentas'><campos>nro_bancoBCRA, cuenta</campos><orden>cuenta</orden><grupo>cuenta, nro_bancoBCRA</grupo><filtro><nro_bancoBCRA type='like'>" + nro_banco + "</nro_bancoBCRA><nro_permiso_consulta type='sql'>dbo.rm_tiene_permiso('permisos_pagos_consultar', nro_permiso_consulta) = 1</nro_permiso_consulta></filtro></select></criterio>")
            rs.open({
                filtroXML: nvFW.pageContents.filtro_cuenta,
                filtroWhere: "<criterio><select><filtro><nro_bancoBCRA type='like'>" + nro_banco + "</nro_bancoBCRA></filtro></select></criterio>"
            })

            while (!rs.eof()) {         
                $('cuenta').insert(new Element('option', { value: rs.getdata('nro_bancoBCRA') }).update(rs.getdata('cuenta')))

                if (rs.getdata('cuenta') == 'CTA CTE 20219/02 STA FE')
                    $('cuenta').selectedIndex = $('cuenta').options.length - 1

                rs.movenext()
            }

            cuenta_onchange()
            $('cuenta').setStyle({ width: "100%" })
        }


        function banco_onchange() {
            $('cuenta').options.length   = 0
            $('chequera').options.length = 0

            if ($('banco').value > 0)
                CargarCuenta($('banco').value);
        }


        function cuenta_onchange() {
            var cuenta = $('cuenta')[$('cuenta').selectedIndex].text
            var rs = new tRS();
            
            $('chequera').options.length = 0
            //rs.open("<criterio><select vista='Bj_Cuentas'><campos>coalesce(chequera, '') as chequera</campos><orden>chequera</orden><grupo>chequera</grupo><filtro><cuenta type='like'>" + cuenta + "</cuenta></filtro></select></criterio>")
            rs.open({
                filtroXML: nvFW.pageContents.filtro_cuenta2,
                filtroWhere: "<criterio><select><filtro><cuenta type='like'>" + cuenta + "</cuenta></filtro></select></criterio>"
            })
            
            while (!rs.eof()) {           
                $('chequera').insert(new Element('option', { value: rs.getdata('chequera') }).update(rs.getdata('chequera')))
                rs.movenext()
            }

            $('chequera').setStyle({ width: '100%' })

            if ($('chequera').value)
                cuenta_ch = $('chequera').value  

            $('cheque_desde').value = 0  
        }


        function window_onload() {
            //nvFW.bloqueo_activar($$("body")[0], "bloq_inicio", "Cargando contenidos")
            // Mostrar botones creados
            vListButtons.MostrarListButton()
            CargarBanco()
            $('cheque_desde').focus();
          
            var win = nvFW.getMyWindow()
            var Parametros = win.options.userData.Parametros
            nro_pagos_registros = Parametros["nro_pagos_registros"]
            nvFW.bloqueo_desactivar(null, "bloq_inicio")
        }


        var win_imprimir


        function Imprimir() {
            if (filtro_credito == 'deposito') { // Impresión de Cheques desde Depósitos
                var nro_banco
                nro_banco = $('banco').value
                formImpXML.filtroXML.value   = nvFW.pageContents.filtro_imprimir_banco
                formImpXML.filtroWhere.value = "<criterio><select><filtro><nro_pago_detalle type='in'>" + filtro_envio + "</nro_pago_detalle></filtro></select></criterio>"

                switch (nro_banco) {
                    case '330':     // Banco: Sta Fe
                        formImpXML.report_name.value = "CHEQUE_STAFE_DEP.rpt"
                        break

                    case '59':      // Banco: Berza
                        formImpXML.report_name.value = "CHEQUE_BERZA_DEP.rpt"
                        break

                    case '255':     // Banco: Suquia
                        formImpXML.report_name.value = "CHEQUE_SUQUIA_DEP.rpt"
                        break
                }

                formImpXML.submit()
            }
            else {
                if ($('banco').options[$('banco').selectedIndex].text == "" || $('cuenta').options[$('cuenta').selectedIndex].text == "" || $('chequera').options[$('chequera').selectedIndex].text == "" || $('cheque_desde').value == "")
                    alert('Selección Incorrecta')
                else
                    Control_Importe_Maximo($('banco').value, $('chequera').options[$('chequera').selectedIndex].text)
            }


            function Control_Importe_Maximo(nro_banco, chequera) {
                var importe_maximo = 0
                var rs = new tRS()
                //rs.open("<criterio><select vista='Bj_Cuentas'><campos>importe_maximo</campos><filtro><nro_bancoBCRA type='igual'>" + nro_banco + "</nro_bancoBCRA><chequera type='like'>" + chequera + "</chequera></filtro></select></criterio>")               
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_ctrl_importe_max,
                    filtroWhere: "<criterio><select><filtro><nro_bancoBCRA type='igual'>" + nro_banco + "</nro_bancoBCRA><chequera type='like'>" + chequera + "</chequera></filtro></select></criterio>"
                })
                
                if (!rs.eof())
                    importe_maximo = rs.getdata('importe_maximo')
                
                var filtro = "<nro_pago_registro type='in'>" + nro_pagos_registros + "</nro_pago_registro>"
                var nro_pago_detalle
                var nro_pago_registro

                //rs.open("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_registro,nro_pago_detalle</campos><filtro>" + filtro + "<nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado><importe_pago_detalle type='mayor'>" + importe_maximo + "</importe_pago_detalle></filtro><orden></orden></select></criterio>")    
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_ctrl_importe_max2,
                    filtroWhere: "<criterio><select><filtro>" + filtro + "<importe_pago_detalle type='mayor'>" + importe_maximo + "</importe_pago_detalle></filtro></select></criterio>"
                })
                
                if (!rs.eof())
                    dividir_pagos(filtro, importe_maximo)
                else
                    imprimir_cheques()
            }


            function dividir_pagos(filtro, importe_maximo) {
                nvFW.confirm('Hay pagos que superan el importe máximo de la chequera. Desea dividir los pagos?.', {
                    width: 300,
                    onOk: function(win) {
                        dividir_pagos_rs(filtro, importe_maximo)            
                        win.close()
                    },
                    onCancel: function(win) {
                        imprimir_cheques()
                        win.close()
                        return
                    }
                })
            }


            function dividir_pagos_rs(filtro, importe_maximo) {
                if (filtro != '') {
                    var rs = new tRS();
                    //rs.open("<criterio><select vista='wrp_verpg_registro'><campos>nro_pago_registro,nro_pago_detalle</campos><filtro>" + filtro + "<nro_pago_tipo type='in'>6</nro_pago_tipo><nro_pago_estado type='igual'>1</nro_pago_estado><importe_pago_detalle type='mayor'>" + importe_maximo + "</importe_pago_detalle></filtro><orden></orden></select></criterio>")    
                    rs.open({
                        filtroXML: nvFW.pageContents.filtro_dividir_pagos,
                        filtroWhere: "<criterio><select><filtro>" + filtro + "<importe_pago_detalle type='mayor'>" + importe_maximo + "</importe_pago_detalle></filtro></select></criterio>"
                    })

                    while (!rs.eof()) {
                        nro_pago_registro = rs.getdata('nro_pago_registro')
                        nro_pago_detalle  = rs.getdata('nro_pago_detalle')
                        
                        nvFW.exportarReporte({
                            //filtroXML: "<criterio><procedure CommandText='dbo.rm_pagos_dividir' CommantTimeOut='1500' vista='wrp_pg_registro'><parametros><nro_pago_detalle DataType='int'>" + nro_pago_detalle + "</nro_pago_detalle><nro_pago_registro DataType='int'>" + nro_pago_registro + "</nro_pago_registro><importe_maximo DataType='money'>" + importe_maximo + "</importe_maximo></parametros></procedure></criterio>",
                            filtroXML: nvFW.pageContents.filtro_dividir_pagos_exp,
                            params: "<criterio><params param1='" + nro_pago_detalle + "' param2='" + nro_pago_registro + "' param3='" + importe_maximo + "' /></criterio>",
                            xsl_name: "HTML_base.xsl",
                            formTarget: 'iframe1',
                            nvFW_mantener_origen: true,
                            bloq_contenedor: 'iframe1',
                            cls_contenedor: 'iframe1'
                        })

                        rs.movenext()
                    }
                }

                imprimir_cheques()
            }


            function imprimir_cheques() {
                var rs = new tRS()
                //rs.open("<criterio><select vista='Bj_Cuentas'><campos>empresa</campos><filtro><chequera type='like'>" + $('chequera').options[$('chequera').selectedIndex].text + "</chequera></filtro></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtro_imprimir_cheques,
                    filtroWhere: "<criterio><select><filtro><chequera type='like'>" + $('chequera').options[$('chequera').selectedIndex].text + "</chequera></filtro></select></criterio>"
                })
                
                if (!rs.eof())
                    Parametros["empresa"] = rs.getdata('empresa')
                
                Parametros["nro_pagos_registros"] = nro_pagos_registros;
                Parametros["nro_banco"]           = $('banco').value
                Parametros["banco"]               = $('banco').options[$('banco').selectedIndex].text
                Parametros["cuenta"]              = $('cuenta').options[$('cuenta').selectedIndex].text
                Parametros["chequera"]            = $('chequera').options[$('chequera').selectedIndex].text
                Parametros["cheque_desde"]        = $('cheque_desde').value    
                win_imprimir = top.nvFW.createWindow({
                    title: '<b>Administración de Pagos - Cheques</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: false,
                    closable: true,
                    width: 850,
                    height: 500,
                    resizable: false,
                    detroyOnClose: true,
                    onClose: function (){
                        parent.win_chequera.close()
                    }
                });
                
                win_imprimir.options.userData = { Parametros: Parametros }
                win_imprimir.setURL('Pagos/Pagos_distribucion_imprimir.aspx')
                win_imprimir.showCenter(true)
            }
        }


        function ultimo_cheque(cuenta_ch) {
            var rs = new tRS()
            //rs.open("<criterio><select vista='verPagos_cheques'><campos>max(nro_cheque) as nro_cheque</campos><filtro><chequera type='like'>" + cuenta_ch + "</chequera></filtro><orden></orden></select></criterio>")
            rs.open({
                filtroXML: nvFW.pageContents.filtro_ultimoCheque,
                filtroWhere: "<criterio><select><filtro><chequera type='like'>" + cuenta_ch + "</chequera></filtro></select></criterio>"
            })

            if (!rs.eof())
                $('cheque_desde').value = parseFloat(rs.getdata('nro_cheque')) + 1    
            else
                $('cheque_desde').value = 1        
        }


        function valDigito(strCaracteres) {
            if (event.keyCode == 13) {
                event.keyCode = 0
                Imprimir()
            }

            if (!strCaracteres)
                strCaracteres = ''

            var key        = window.event.keyCode
            var strkey     = String.fromCharCode(key)
            var encontrado = strCaracteres.indexOf(strkey) != -1

            if ((strkey < "0" || strkey > "9") && !encontrado)
                window.event.keyCode = 0
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <script>
        nvFW.bloqueo_activar($$("body")[0], "bloq_inicio", "Cargando contenidos")
    </script>

    <form name="formImpXML" id="formImpXML" method="post" action="/FW/reportViewer/exportarReporte.aspx">
        <input type="hidden" name="filtroXML" value="" />
        <input type="hidden" name="filtroWhere" value="" />
        <input type="hidden" name="report_name" value="" />
    </form>

    <table class="tb1">
        <tr class="tbLabel">
            <td nowrap colspan="4" class="Tit1" style="text-align: center;">
                <b>Impresión de Cheques - Selección</b>
            </td>
        </tr>
        <tr class="tbLabel">
            <td style="width:30%">Banco</td>
            <td style="width:30%">Cuenta</td>
            <td style="width:20%">Chequera</td>
            <td style="width:20%">Nro. Cheque Desde:</td>
        </tr>
        <tr>
            <td>
                <select name="banco" id="banco" onchange='return banco_onchange()'></select>
            </td>
            <td>
                <select name="cuenta" id="cuenta" onchange='return cuenta_onchange()'></select>
            </td>
            <td>
                <select name="chequera" id="chequera"></select>
            </td>
            <td>
                <input type="text" name="cheque_desde" id="cheque_desde" value="1" maxlength="10" style="width: 100%" onkeypress='valDigito(",-")' />
            </td>                
        </tr>
    </table>
<%--    <table class="tb1">
        <tr class="tbLabel">
            <td style="width:30%">Banco</td>
            <td style="width:30%">Cuenta</td>
            <td style="width:20%">Chequera</td>
            <td style="width:20%">Nro. Cheque Desde:</td>
        </tr>
        <tr>
            <td>
                <select name="banco" id="banco" onchange='return banco_onchange()'></select>
            </td>
            <td>
                <select name="cuenta" id="cuenta" onchange='return cuenta_onchange()'></select>
            </td>
            <td>
                <select name="chequera" id="chequera"></select>
            </td>
            <td>
                <input type="text" name="cheque_desde" id="cheque_desde" value="1" maxlength="10" style="width: 100%" onkeypress='valDigito(",-")' />
            </td>                
        </tr>
    </table> --%> 
    <%--<br />--%>
    <table class="tb1" style="position: absolute; left: 0; bottom: 0;">
        <tr>
            <td style="width: 25%"></td>
            <td>
                <div id="divImprimir"></div>
            </td>
            <td style="width: 25%"></td>
        </tr>
    </table>

    <%--<iframe name="iframe1" id="iframe1" style="visibility: hidden; width: 0px; height: 0px; border: none;"></iframe>--%>
    <iframe name="iframe1" id="iframe1" style="display: none; border: none;"></iframe>

</body>
</html>
