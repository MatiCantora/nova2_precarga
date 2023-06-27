<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 
    Me.contents("tipoCtaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_cuentas_tipo'><campos>nro_dc_tipo_cta as id, desc_dc_tipo_cta as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("seleccionEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_ctas'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("bancos_bcra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("tipo_cta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_cuentas_tipo'><campos>*</campos><filtro></filtro></select></criterio>")
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar CREDIN y DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled {
            background-color: #EBEBE4;
        }
    </style>

    <script type="application/javascript">
        var filtroWhere
        var win = nvFW.getMyWindow()
        var flag = 0
        var flag1 = true

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Validar";
        vButtonItems[0]["etiqueta"] = "Seleccionar";
        vButtonItems[0]["imagen"] = "confirmar";
        vButtonItems[0]["onclick"] = "return validar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("confirmar", "/fw/image/icons/confirmar.png")

        function window_onresize() {

        }

        function window_onload() {
            vListButton.MostrarListButton()
            if (win.options.userData.flag == 1) {
                $('informacion').style.display = 'none'
            }
        }

        function validar() {                        
            var id
            var cbu = $('cbu').value.replace('#', '')

            if ($('tdCbu').style.display != 'none') {                
                if (cbu.length != 22) {
                    alert("Ingrese un CBU valido de veintidós digitos")
                    return
                }               
                id = $('cbu').value
            }

            if ($('tdAli').style.display != 'none') {                                
                //if ($('alias').value.length != 16) {
                //    alert("Ingrese un Alias valido de dieciseis digitos")
                //    return
                //}                
                id = $('alias').value
            }
            

            validarCBU(cbu)
            if (flag1 == true) {

                error_ajax_request("dc_acciones.aspx", {
                    parameters: {
                        accion: 'CCBUALIAS',
                        id: id
                    },
                    onSuccess: function (err, transport) {

                        var strHTML = '';
                        var obj = JSON.parse(err.params.json_response)
                        var nro_banco_bcra
                        var tipo_cta
                        var cbu

                        if ($('tdCbu').style.display != 'none') {
                            nro_banco_bcra = obj.cbu.substring(0, 3)
                            tipo_cta = obj.cuenta.tipo_cta
                            cbu = obj.cbu
                        }
                        if ($('tdAli').style.display != 'none') {
                            nro_banco_bcra = obj.cuenta.nro_bco
                            tipo_cta = obj.cuenta.tipo_cta
                            cbu = obj.alias
                        }

                        if (obj.titular.length == 1) {
                            enviarPersona(obj.titular[0].nombre, obj.titular[0].cuit, nro_banco_bcra, tipo_cta, cbu)
                            return
                        }

                        strHTML += '<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCuentas">';
                        strHTML += '<tr class="tbLabel">';
                        strHTML += '<td style="text-align: center; width: 5%">-</td>';
                        strHTML += '<td style="text-align: center;">Razon Social</td>';
                        strHTML += '<td style="text-align: center; width: 20%">CUIT</td>';
                        strHTML += '<td style="text-align: center; width: 15%">Persona</td>';
                        strHTML += '</tr>';

                        if (typeof obj.titular != 'undefined') {
                            for (var i = 0; i < obj.titular.length; i++) {

                                var objTit = obj.titular[i];

                                var tipopersona
                                if (objTit.tipo_persona == 'F') {
                                    tipopersona = 'Fisica'
                                } else {
                                    tipopersona = 'Juridica'
                                }

                                strHTML += '<tr>'
                                strHTML += '<td style="text-align: center; width:5%"><input type="radio" name="rd_checked" id="rd_checked_' + objTit.cuit + '" onchange="enviarPersona(\'' + objTit.nombre + '\', ' + objTit.cuit + ', \'' + nro_banco_bcra + '\', ' + tipo_cta + ', \'' + cbu + '\')"></input></td>';
                                strHTML += '<td  id="rd_rs_' + objTit.cuit + '">' + objTit.nombre + '</td>';
                                strHTML += '<td style="width:20%" id="rd_cuit_' + objTit.cuit + '">' + objTit.cuit + '</td>';
                                strHTML += '<td style="width:15%" id="rd_per_' + objTit.cuit + '">' + tipopersona + '</td>';
                                strHTML += '</tr>';
                            }
                        }

                        strHTML += '</table></div>';

                        $('info').setStyle({ display: 'flex' })
                        $('info').innerHTML = strHTML;

                        //console.log(obj.tit_razon_social)

                        if (obj.numError != 0) {
                            alert(obj.mensaje)
                            return
                        }
                    },
                    onFailure: function (err, transport) {
                        console.log(err)
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                        win.close()
                    },
                    bloq_msg: 'VALIDANDO...',
                    error_alert: false
                })
            } else {
                alert("Ingrese un CBU valido")               
            }
        }

        function enviarPersona(razon_social, cuit, nro_bco, tipo_cuenta, cbu) {            
            //ESTE RS BUSCA LA DESCRIPCION DEL BANCO
            var rs = new tRS()
            var bcra
            
            rs.open({
                filtroXML: nvFW.pageContents.bancos_bcra,
                filtroWhere: "<criterio><select><filtro><nro_bcra type='igual'>" + nro_bco + "</nro_bcra></filtro></select></criterio>"
            })
           
            if (!rs.eof()) {
                bcra = rs.getdata('bcra_desc')
            } else {
                bcra = nro_bco
            }

            //ESTE RS BUSCA LA DESCRIPCION DEL TIPO DE CUENTA
            var rs_1 = new tRS()

            rs_1.open({
                filtroXML: nvFW.pageContents.tipo_cta,
                filtroWhere: "<criterio><select><filtro><nro_dc_tipo_cta type='igual'>" + tipo_cuenta + "</nro_dc_tipo_cta></filtro></select></criterio>"
            })

            win.options.userData.cuitInput.value = cuit
            win.options.userData.cbuInput.value = cbu
            win.options.userData.banco.value = bcra
            win.options.userData.tipo_cta.value = rs_1.getdata('desc_dc_tipo_cta')
            win.options.userData.cbuInput.disabled = 'true'
            win.options.userData.razonSocialInput.value = razon_social

            if (win.options.userData.flag == 1) {
                win.options.userData.importe.focus()
                win.close()
            }

        }

        function definirDebito(cuit, cbu, razonSocial) {
            win.options.userData.cuitInput.value = cuit
            win.options.userData.cbuInput.value = cbu
            win.options.userData.cbuInput.disabled = 'true'
            win.options.userData.razonSocialInput.value = razonSocial
            win.close()
        }

        //VALIDA QUE SE INGRESE UN CBU VALIDO
        function validarCBU(cbu) {
            
            var ponderador = '97139713971397139713971397139713'
            var i
            var nDigito
            var nPond
            var bloque1 = '0' + cbu.substring(0, 7)
            var bloque2
            var nTotal = 0

            for (i = 0; i <= 7; i++) {
                nDigito = bloque1.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador
            //es CVU
            if (cbu.substring(0, 3) == '000') {
                flag1 = false
                return false;
            } else {
                flag1 = true
            }

            if (cbu.substring(7, 8) != i) {
                flag1 = false
                return false;
            } else {
                flag1 = true
            }

            nTotal = 0;

            bloque2 = '000' + cbu.substring(8, 21)

            for (i = 0; i <= 15; i++) {
                nDigito = bloque2.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador

            if (cbu.substring(21, 22) != i) {
                flag1 = false
                return false;
            } else {
                flag1 = true
            }

            return true;
        }

        //CAMBIOS DE INPUTS Y LABEL EN CASO DE ELEGIR INGRESO DE ALIAS EN LUGAR DE CBU.
        function switchInp() {
            if ($('tipo').value == 'cbu') {
                $('tit').innerHTML = 'CBU:'
                win.options.userData.eti_d.innerHTML = 'CBU:'
                win.options.userData.eti_c.innerHTML = 'CBU:'
                $('tdCbu').style.display = 'table-cell'
                $('tdAli').style.display = 'none'
            } else {
                $('tit').innerHTML = 'ALIAS:'
                win.options.userData.eti_d.innerHTML = 'ALIAS:'
                win.options.userData.eti_c.innerHTML = 'ALIAS:'
                $('tdAli').style.display = 'table-cell'                
                $('tdCbu').style.display = 'none'
            }
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <table class="tb1">
        <tr>
            <td style="width: 93%">
                <table class="tb1">
                    <tr>
                        <td style="width: 30%;">
                            <select style="width: 100%;" id="tipo" onchange="switchInp()">
                                <option value="cbu">CBU</option>
                                <option value="alias">ALIAS</option>
                            </select>
                        </td>
                        <td style="width: 10%;" class="Tit1" id="tit">CBU:</td>
                        <td style="width: 60%;" id="tdCbu">
                            <script>
                                campos_defs.add('cbu', {
                                    enDB: false,
                                    nro_campo_tipo: 100,
                                    mask: {
                                        mask: '0000000000000000000000',
                                        lazy: false,
                                        placeholderChar: '#'
                                    }
                                    /*onmask_complete: function (campo_def, objcampo_def) { if (validarCBU(campos_defs.get_value('cbu'))) { } else { } }*/
                                });
                            </script>
                            <%--<input style="width: 100%" onkeypress="return ( this.value.length < 22 )" type="number" id="cbu" />--%>
                        </td>
                        <td style="width: 60%; display: none" id="tdAli">
                            <input style="width: 100%" onkeypress="return ( this.value.length < 16 )" type="text" id="alias" />
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 7%">
                <div id="divValidar"></div>
            </td>
        </tr>
    </table>
    <div id="info" style="display: none"></div>
    <div id="informacion">
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 100px">Razón Social:</td>
                <td>
                    <input type="text" id="razonSocial" style="width: 100%" disabled /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 100px">Sucursal:</td>
                <td>
                    <input type="text" id="sucursal" style="width: 100%" disabled /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 100px">CUIT:</td>
                <td>
                    <input type="text" id="cuit" style="width: 100%" disabled /></td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td style="width: 100px" class="Tit1">Tipo Cuenta:</td>
                <td style="">
                    <script type="text/javascript">
                        campos_defs.add('tipoCta', {
                            enDB: false,
                            filtroXML: nvFW.pageContents.tipoCtaDef,
                            nro_campo_tipo: 1
                        })
                        campos_defs.habilitar('tipoCta', false)
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td style="width: 100px" class="Tit1">Persona:</td>
                <td>
                    <input type="text" id="persona" style="width: 100%" disabled /></td>
            </tr>
        </table>
    </div>
</body>
</html>
