<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim login As String = nvFW.nvUtiles.obtenerValor("login", "")
    'Dim operador As Integer = nvFW.nvUtiles.obtenerValor("operador", "")
    Dim operador As Integer = nvFW.nvUtiles.obtenerValor("operador", "0")

    Me.contents("filtroOperadorIp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperador_ip_tipo'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("campoDefIP") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ip_types'><campos> IP_typeID as id, ip_type as campo</campos></select></criterio>")
    Me.contents("typeFilt") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ip_types'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("operador") = operador
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
        var idParam = nvFW.pageContents.idParam
        var login = nvFW.pageContents.login
        var operador = nvFW.pageContents.operador
        var winClose = nvFW.getMyWindow()
        var objetIns = []
        var backIp 
        var backMask
        var valor 



        function window_onresize() {

            var heiVal = document.body.getBoundingClientRect().height - $('divMenuABM').getBoundingClientRect().height - $('campo_def').getBoundingClientRect().height

            $('divParametros').setStyle({ height: heiVal - 30 + 'px' })

        }

        function window_onload() {
            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.filtroOperadorIp,
                filtroWhere: '<criterio><select><filtro><operador>' + operador + '</operador></filtro></select></criterio>'
            })

            htmlDialog += "<table id='valores' class='tb1 highlightOdd highlightTROver layout_fixe' /*style='height:50px !Important'*/><tr style='height:15px !Important'><td class='Tit1' style='width:5%; text-align:center'>-</td><td class='Tit1' style='width:5%; text-align:center'>-</td><td class='Tit1' style='text-align:center' >Dirección IP </td><td class='Tit1' style='text-align:center' >Mascara </td><td class='Tit1' style='text-align:center' >Tipo </td></tr>"
            while (!rs.eof()) {
                var ip = ''
                ip = rs.getdata('IP').replace(/\./g, "")
                mask = rs.getdata('mask').replace(/\./g, "")

                htmlDialog += "<tr id='tr" + ip + "'>"
                htmlDialog += "<td style='width:5%;text-align:center' >"
                htmlDialog += "<img title='Eliminar Movimiento' onclick='deleteValue("+ ip +")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0' />"
                htmlDialog += "</td>"
                htmlDialog += "<td style='width:5%;text-align:center' >"
                htmlDialog += "<img title='Editar Movimiento' onclick='valueWin(1," + ip + "," + rs.getdata('ip_typeID') +","+ mask +")' src='/fw/image/icons/editar.png' style='cursor: pointer' border='0' />"
                htmlDialog += "</td>"
                htmlDialog += "<td id='ip" + ip + "' style='width:31%'>" + rs.getdata('IP') + "</td ><td id='mask" + mask + "' style='width:31%'>" + rs.getdata('mask') + "</td>"
                htmlDialog += "<td style='width:28%' title='" + rs.getdata('ip_typeID') + "'>" + rs.getdata('ip_type') + "</td>"
                htmlDialog += "</tr>"
                rs.movenext()
            }
            htmlDialog += "</table>"

            $('tabla').innerHTML = htmlDialog
            window_onresize()
        }

        function valueWin(m,ip,type,mask) {
            var w = nvFW
            var ipEdit = ''
            var maskEdit = ''
            if (m == 1) {
                ipEdit = $('ip' + ip).innerHTML
                maskEdit = $('mask' + mask).innerHTML

                win_archivos_def_detalle_abm = w.createWindow({
                    url: '/fw/security/operador_abm_ip _modal.aspx?ip=' + ipEdit + '&type=' + type + '&mask=' + maskEdit + '&m=' + m,
                    title: '<b>Nueva IP</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    bloquear: true,
                    width: 570,
                    height: 135,
                    onClose: function () {

                    }
                });
            } else {
                win_archivos_def_detalle_abm = w.createWindow({
                    url: '/fw/security/operador_abm_ip _modal.aspx?m=' + m,
                    title: '<b>Nueva IP</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    bloquear: true,
                    width: 570,
                    height: 135,
                    onClose: function () {

                    }
                });
            }


            win_archivos_def_detalle_abm.showCenter(true)
        }

        function deleteValue(valor) {
            Dialog.confirm('<b>¿Esta seguro de que desea eliminar este valor?</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "SI",
                cancelLabel: "NO",
                onOk: function (win) {
                    $('tr' + valor).remove()
                    win.close()
                }
            })
        }

        function editValue(value) {
            valor = value
            var c = 1
            var top = $('tabla').querySelectorAll('tr').length
            var ar = $('tabla').querySelectorAll('tr')
            while ( c < top) {
                if (ar[c].querySelectorAll('td')[1].querySelectorAll('img')[0].title == 'Aplicar cambios') {
                    alert('Para realizar cambios en otro campo, debe aplicar los cambios del anterior')
                    return
                }
                c += 1
            }

            backMask = $('tr' + valor).querySelectorAll('td')[2].innerHTML
            backIp = $('tr' + valor).querySelectorAll('td')[3].innerHTML
            $('tr' + valor).querySelectorAll('td')[2].innerHTML = '<input type="text" id="ip'+ valor +'" onchange="validateIp('+ valor +')" style="width:100%" value="' + $('tr' + valor).querySelectorAll('td')[2].innerHTML + '"/>'
            $('tr' + valor).querySelectorAll('td')[3].innerHTML = '<input type="text" id="mask'+ valor +'" onchange="validateMask(' + valor +')" style="width:100%" value="' + $('tr' + valor).querySelectorAll('td')[3].innerHTML + '"/>'
            //$('tr' + valor).querySelectorAll('td')[4].innerHTML = //'<input type="text" style="width:100%" value="' + $('tr' + valor).querySelectorAll('td')[4].innerHTML + '"/>'
            $('tr' + valor).querySelectorAll('td')[1].innerHTML = "<img title='Aplicar cambios' onclick='changeValue(" + valor + ")' src='/fw/image/icons/seleccionar.png' style='cursor: pointer' border='0'/>"
        }

        function changeValue(ip, mask, type) {
            $('tr' + valor).querySelectorAll('td')[2].innerHTML = ip
            $('tr' + valor).querySelectorAll('td')[3].innerHTML = mask
            //$('tr' + valor).querySelectorAll('td')[4].innerHTML = //'<input type="text" style="width:100%" value="' + $('tr' + valor).querySelectorAll('td')[4].innerHTML + '"/>'
            $('tr' + valor).querySelectorAll('td')[1].innerHTML = type
        }

        function newValue(m, ip, mask, type, typeDesc, valor) {
            var top = $('valores').querySelectorAll('tr').length
            var c = 1
            var b = 0

            while (c < top) {
                var ar = $('valores').querySelectorAll('tr')[c]
                if (ar.querySelectorAll('td')[2].innerText == ip) {
                    b = 1
                    alert('<b>El valor ya existe</b>')
                    return
                }
                c += 1
            }

            if (ip != '') {
                if (m == 0) {

                    if (b == 0) {

                        var newVal = "<tr id='tr" + ip.replace(/\./g, "") + "'>"
                        newVal += "<td style='width:5%;text-align:center' >"
                        newVal += "<img title='Eliminar Movimiento' onclick='deleteValue(" + ip.replace(/\./g, "") + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0' />"
                        newVal += "</td>"
                        newVal += "<td style='width:5%;text-align:center' >"
                        newVal += "<img title='Editar Movimiento' onclick='valueWin(1," + ip.replace(/\./g, "") + "," + type + "," + mask.replace(/\./g, "") + ")' src='/fw/image/icons/editar.png' style='cursor: pointer' border='0' />"
                        newVal += "</td>"
                        newVal += "<td id='ip" + ip.replace(/\./g, "") + "' style='width:31%'>" + ip + "</td ><td id='mask" + mask.replace(/\./g, "") + "' style='width:31%'>" + mask + "</td>"
                        newVal += "<td style='width:28%' title='" + type + "'>" + typeDesc + "</td>"
                        //newVal += "<td style='width:28%'>" + type + "</td>"
                        newVal += "</tr>"

                        var fila = $('valores').insertRow(1)
                        fila.innerHTML = newVal
                    }

                    $('valores').querySelectorAll('tr')[1].id = "tr" + ip.replace(/\./g, "")
                    window_onresize()
                } else {
                    $('tr' + valor).querySelectorAll('td')[2].innerHTML = ip
                    $('tr' + valor).querySelectorAll('td')[2].id = 'ip' + ip.replace(/\./g, "") 
                    $('tr' + valor).querySelectorAll('td')[3].innerHTML = mask
                    $('tr' + valor).querySelectorAll('td')[3].id = 'mask' + ip.replace(/\./g, "") 
                    $('tr' + valor).querySelectorAll('td')[4].innerHTML = type
                    $('tr' + valor).querySelectorAll('td')[1].innerHTML = "<img title='Editar Movimiento' onclick='valueWin(1," + ip.replace(/\./g, "") + "," + type + "," + mask.replace(/\./g, "") + ")' src='/fw/image/icons/editar.png' style='cursor: pointer' border='0' />"
                    $('tr' + valor).querySelectorAll('td')[0].innerHTML = "<img title='Eliminar Movimiento' onclick='deleteValue(" + ip.replace(/\./g, "") + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0' />"

                    $('tr' + valor).id = 'tr' + ip.replace(/\./g, "") 
                }

            } //else {
            //    if ($('IP').value != '') {

            //        if (b == 0) {
            //            var ip = ''
            //            ip = $('IP').value.replace(/\./g, "")
            //            var newVal = "<tr id='tr" + ip + "'>"
            //            newVal += "<td style='width:5%;text-align:center' >"
            //            newVal += "<img title='Eliminar Movimiento' onclick='deleteValue(" + ip + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0' />"
            //            newVal += "</td>"
            //            newVal += "<td style='width:5%;text-align:center' >"
            //            newVal += "<img title='Editar Movimiento' onclick='editValue(" + ip+ ")' src='/fw/image/icons/editar.png' style='cursor: pointer' border='0' />"
            //            newVal += "</td>"
            //            newVal += "<td style='width:31%'>" + $('IP').value + "</td ><td style='width:31%'>" + $('mask').value + "</td>"
            //            newVal += "<td style='width:28%'>" + $('type').value + "</td>"
            //            newVal += "</tr>"
            //            var fila = $('valores').insertRow(1)
            //            fila.innerHTML = newVal 
            //        }

            //        $('valores').querySelectorAll('tr')[1].id = "tr" + ip
            //        window_onresize()
            //    }
            //}

        }

        function validateIp(valor) {
            if (valor == 0) {
                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('IP').value)) {
                    return
                } else {
                    alert("Ingrese una direccion IP valida")
                    $('IP').value = ''
                    return 
                }
            } else {

                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('ip' + valor).value)) {
                    return
                } else {
                    alert("Ingrese una direccion IP valida")
                    $('ip' + valor).value = backIp
                    return
                }
            }


        }

        function validateMask(valor) {
            if (valor == 0) {
                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('mask').value)) {
                    return
                } else {
                    alert("Ingrese una mascara IP valida")
                    $('mask').value = ''
                    return 
                }
            } else {

                if (/^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test($('mask' + valor).value)) {
                    return
                } else {
                    alert("Ingrese una mascara IP valida")
                    $('mask' + valor).value = backMask
                    return
                }
            }

        }

        function onSave() {
            var c = 1
            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><ipdir>"
            var top = $('valores').querySelectorAll('tr').length
            while (c < top) {
                var ar = $('valores').querySelectorAll('tr')[c]
                var newIp = {
                    'IP': ar.querySelectorAll('td')[2].innerText,
                    'type': ar.querySelectorAll('td')[4].innerText,
                    'mask': ar.querySelectorAll('td')[3].innerText
                }

                xmldato += "<ips IP='" + ar.querySelectorAll('td')[2].innerText + "'"
                xmldato += " mask='" + ar.querySelectorAll('td')[3].innerText + "'"
                xmldato += " type='" + ar.querySelectorAll('td')[4].title + "'></ips>"

                objetIns.push(newIp)  
                c = c + 1
            }
            xmldato += "</ipdir>"
            console.log(xmldato)

            //paramsGlob.each(function (arreglo, i) {
            //    nvFW.error_ajax_request('operador_abm_ip.aspx', {
            //        parameters: { IP: arreglo['IP'], type: arreglo['type'], operador: arreglo['operador'], mask: arreglo['mask'] },
            //        onSuccess: function (err, transport) {

            //            if (err.numError != 0) {
            //                alert(err.mensaje)
            //                return
            //            }
            //            //winParam_def.close()
            //        },
            //        error_alert: true
            //    });
            //})
        }


    </script>

</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<div style="display: none;">nvFW.pageContents.id_param</div>
<div id="divMenuABM"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
     vMenuABM.loadImage("guardar", '/FW/image/icons/guardar.png')
     Menus["vMenuABM"] = vMenuABM
     Menus["vMenuABM"].alineacion = 'centro';
     Menus["vMenuABM"].estilo = 'A';
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>onSave()</Codigo></Ejecutar></Acciones></MenuItem>");

     vMenuABM.MostrarMenu();
    </script> 
<div id="divParametros"  style="width:100%; height:100%; overflow:auto;">
   <div id="tabla" style="width:100%;overflow:auto;"></div>
</div>
   <div id="campo_def" style="background-color:white; text-align:center">

<table class="tb1" style="width:95%; margin: 0 auto; display:none">
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
                    despliega: 'arriba',
                    filtroXML: nvFW.pageContents.campoDefIP
                })
            </script>
        </td>
    </tr>
</table>
</div>
<div id='divPie' style='padding-top:5px;padding-bottom:5px;width:100%;overflow:hidden;text-align:center;'><img alt='' title='agregar' style="cursor:pointer" onclick='valueWin(0)' src='/fw/image/param_def/agregar.png' /></div>
</body>
</html>