<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim m As Integer = nvFW.nvUtiles.obtenerValor("m", -1)
    Dim ip As String = nvFW.nvUtiles.obtenerValor("ip", "")
    Dim type As Integer = nvFW.nvUtiles.obtenerValor("type", 0)
    Dim mask As String = nvFW.nvUtiles.obtenerValor("mask", "")

    Me.contents("filtroOperadorIp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_ip'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("campoDefIP") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ip_types'><campos> IP_typeID as id, ip_type as campo</campos></select></criterio>")
    Me.contents("m") = m
    Me.contents("ip") = ip
    Me.contents("type") = type
    Me.contents("mask") = mask
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Parametros listado</title>
    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">
        var htmlDialog = ""
        var m = nvFW.pageContents.m
        var type = nvFW.pageContents.type
        var ip = nvFW.pageContents.ip
        var mask = nvFW.pageContents.mask
        var winClose = nvFW.getMyWindow()
        var objetIns = []
        var backIp 
        var backMask

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Aceptar";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return newValue()";
        vButtonItems[1] = new Array();
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return winClose.close()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        //vListButton.loadImage("agregar", "/fw/image/icons/agregar.png")

        function newValue() {
            var valor = nvFW.pageContents.ip.replace(/\./g, "") 
            console.log(valor)

            if ($('IP').value == "") {
                alert('Complete el campo IP')
                return
            }

            if ($('type').value == "") {
                alert('Complete el campo Tipo')
                return
            }

            var ip = $('IP').value
            var mask = $('mask').value
            var type = $('type').value
            var typeDesc = campos_defs.get_desc('type').replace(/[0-9,()]/g, "")

            parent.newValue(m, ip, mask, type, typeDesc, valor)
            winClose.close()
        }

        function window_onresize() {

        }

        function window_onload() {
            vListButton.MostrarListButton()
            if (ip != '') {
                $('IP').value = ip
                $('mask').value = mask
                campos_defs.set_value('type', type)
            }
        }

        function validateIp(valor) {
                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('IP').value)) {
                    return
                } else {
                    alert("Ingrese una direccion IP valida", { onClose: function () { $('IP').focus()}})
                    $('IP').value = ''
                    
                    return 
                }
        }

        function validateMask(valor) {

                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('mask').value)) {
                    return
                } else {
                    alert("Ingrese una mascara IP valida", { onClose: function () { $('mask').focus()}})
                    $('mask').value = ''
                    
                    return 
                }


        }


    </script>

</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<table class="tb1" style="width:100%; margin: 0 auto">
    <tr class="tbLabel">
        <td>Direccion IP</td>
        <td>Mascara</td>
        <td>Tipo</td>
    </tr>
    <tr>
        <td><input style="width:100%" type="text" onchange="validateIp(0)" id="IP" placeholder="IP..." /></td>
        <td><input style="width:100%" type="text" onchange="validateMask(0)" id="mask" placeholder="Mascara..." /></td>
        <td>
            <script type="text/javascript">
                campos_defs.add('type', {
                    enDB: false,
                    nro_campo_tipo: 1,
                    filtroXML: nvFW.pageContents.campoDefIP
                })
            </script>
        </td>
    </tr>
</table>
<div style="margin: 10px auto; width:80%">
<div style="display:inline-block; width:49%" id="divAceptar"></div>
<div style="display:inline-block; width:49%" id="divCancelar"></div>
</div>
</body>
</html>