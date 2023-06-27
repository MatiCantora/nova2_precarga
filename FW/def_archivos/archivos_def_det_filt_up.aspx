<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim idParam As String = nvFW.nvUtiles.obtenerValor("idParam", "")

    Me.contents("idParam") = idParam
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
        var winClose = nvFW.getMyWindow()
        var gCont = 0


        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Agregar";
        vButtonItems[0]["etiqueta"] = "Agregar";
        vButtonItems[0]["imagen"] = "agregar";
        vButtonItems[0]["onclick"] = "return newValue()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("agregar", "/fw/image/icons/agregar.png")

        function window_onresize() {

            var heiVal = document.body.getBoundingClientRect().height - $('divMenuABM').getBoundingClientRect().height - $('campo_def').getBoundingClientRect().height

            $('divParametros').setStyle({ height: heiVal - 30 + 'px' })

        }

        function window_onload() {
            var cont = 0

            htmlDialog += "<table id='valores' class='tb1 highlightOdd highlightTROver layout_fixe' style='height:50px !Important'><tr><td class='Tit1' style='width:5%; text-align:center'>-</td><td class='Tit1' style='text-align:center' colspan = 2>Filtros Upload: </td></tr>"
            var valor = idParam
            valor.split('|').each(function (ar, i) {
                htmlDialog += "<tr id='tr" + cont + "'><td style='width:5%;text-align:center'><img title='Eliminar filtro' onclick='deleteValue(" + cont + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0'/></td><td style='width:5%; text-align:center'>" + cont + "</td ><td style='width:90%'>" + ar + "</td ></tr>"
                cont += 1
            })
            gCont = cont
            htmlDialog += "</table>"

            $('tabla').innerHTML = htmlDialog
            vListButton.MostrarListButton()
            window_onresize()
        }

        function deleteValue(valor) {
            Dialog.confirm('<b>¿Esta seguro de que desea eliminar este filtro?</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "SI",
                cancelLabel: "NO",
                onOk: function (win) {
                    $('tr' + valor).remove()
                    gCont -= 1
                    win.close()
                }
            })
        }

        function newValue() {
            
            if ($('newFilt').value != '') {
                var top = $('valores').querySelectorAll('tr').length
                var c = 1
                var b = 0

                while (c < top) {
                    var ar = $('valores').querySelectorAll('tr')[c]
                    if (ar.querySelectorAll('td')[1].innerText == $('newFilt').value) {
                        b = 1
                        alert('<b>El valor ya existe</b>')
                        return
                    }
                    c += 1
                }

                if (b == 0) {
                    var onCli = "onclick='deleteValue(" + gCont + ")'"
                    var newVal = "<tr id='tr" + gCont + "'><td style='width:5%;text-align:center'><img title='Eliminar Movimiento' " + onCli +" src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0'/></td><td style='width:10%; text-align:center' id='" + $('newFilt').value + "'>" + gCont + "</td ><td style='width:85%;'>" + $('newFilt').value + "</td></tr>"
                    var fila = $('valores').insertRow(top)
                    //console.log(newVal)
                    fila.innerHTML = newVal //"<tr id='tr" + $('tipopercod').value + "'><td style='width:5%;text-align:center'><img title='Eliminar Movimiento' onclick='deleteValue(" + $('tipopercod').value + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0'/></td><td style='width:10%; text-align:center' id='" + $('tipopercod').value + "'>" + $('tipopercod').value + "</td ><td style='width:85%;'>" + campos_defs.get_desc("tipopercod") + "</td></tr>"
                    $('divParametros').scrollTop = $('divParametros').style.height.split('px')[0]
                }
                //var top1 = $('valores').querySelectorAll('tr').length

                $('valores').querySelectorAll('tr')[top].id = "tr" + gCont
                gCont += 1

                $('newFilt').value = ''
                //$('defTr').setStyle({ 'display': 'none' })
                window_onresize()
            }
        }

        function onSave() {

            var valor = ""
            var top = $('valores').querySelectorAll('tr').length

            var c = 1

            while (c < top) {
                var ar = $('valores').querySelectorAll('tr')[c]
                    valor += ar.querySelectorAll('td')[2].innerText + '|'
            
                c += 1
            }
            valor = valor.substring(0, valor.length - 1)
            parent.saveFilters(valor)
            winClose.close()
        }

        function showDef() {
            $('defTr').setStyle({ 'display': 'table' })
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
    <table class="tb1">
        <tr class="tbLabel">
<%--            <td style="width:5%; text-align:center">-</td>--%>
<%--            <td  style="text-align:center">Valor</td>--%>
        </tr>
    </table>
<div id="divParametros"  style="width:100%; height:100%; overflow:auto;">
   <div id="tabla" style="width:100%;overflow:auto;"></div>
</div>
   <div id="campo_def" style="background-color:white; text-align:center">
<%--       <table class="tb1">
           <tr class="tbLabel" >
                <td>Tipo</td>
           </tr>
           <tr >
                <td>--%>
                    <input style="width:70%;margin-right:1%; margin-bottom:5px" type="text" id="newFilt" /> <div style="width:22%; margin-right:2%; display:inline-block; height:17px" id="divAgregar"></div>
<%--                </td>
           </tr>
       </table>--%>
<%--<div style="display:none" id='divPie' style='padding-top:5px;padding-bottom:5px;width:100%;overflow:hidden;text-align:center;'><img alt='' title='agregar' style="cursor:pointer" onclick='campos_defs.onclick("","tipopercod")' src='/fw/image/param_def/agregar.png' /></div>--%>

</div>
</body>
</html>