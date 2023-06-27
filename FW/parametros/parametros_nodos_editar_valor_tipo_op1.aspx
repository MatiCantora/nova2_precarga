<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim idParam As String = nvFW.nvUtiles.obtenerValor("idParam", "")

    Me.contents("idParam") = idParam
    Me.contents("filtroParametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_nodos'><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>")
    Me.contents("filtroParametrosDescripcion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='CDef_tipopercod' cn='BD_IBS_ANEXA'><campos>*</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroSeleccionarParametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_def'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
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

        function window_onload() {
            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.filtroParametros,
                filtroWhere: '<criterio><select><filtro><id_param type="like">%' + idParam + '%</id_param></filtro></select></criterio>'
            })

            var rs_param = new tRS()
            rs_param.open({
                filtroXML: nvFW.pageContents.filtroSeleccionarParametro,
                filtroWhere: "<id_param type='igual'>'" + rs.getdata("id_param") + "'</id_param>"
            })

            htmlDialog += "<table id='valores' class='tb1 highlightOdd highlightTROver layout_fixe' style='height:50px !Important'><tr><td class='Tit1' style='width:5%; text-align:center'>-</td><td class='Tit1' colspan = 2>Tipo de operaciones: </td></tr>"
            var valor = rs.getdata("valor")
            valor.split(',').each(function (ar, i) {
                var rs_desc = new tRS()
                rs_desc.open({
                    filtroXML: nvFW.pageContents.filtroParametrosDescripcion,
                    filtroWhere: "<tipopercod type='igual'>" + ar + "</tipopercod>"
                })
                htmlDialog += "<tr id='tr" + ar + "'><td style='width:5%;text-align:center'><img title='Eliminar Movimiento' onclick='deleteValue(" + ar + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0'/></td><td style='width:10%; text-align:center'>" + ar + "</td ><td style='width:85%'>" + rs_desc.getdata("campo") + "</td ></tr>"
            })
            htmlDialog += "</table>"

            $('tabla').innerHTML = htmlDialog
        }

        function deleteValue(valor) {
            Dialog.confirm('<b>�Esta seguro de que desea eliminar este valor?</b>', {
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

        function newValue() {

            if ($('tipopercod').value != '') {
                var top = $('valores').querySelectorAll('tr').length
                console.log(top)
                var c = 1
                var b = 0

                while (c < top) {
                    var ar = $('valores').querySelectorAll('tr')[c]
                    if (ar.querySelectorAll('td')[1].innerText == $('tipopercod').value) {
                        b = 1
                        alert('<b>El valor ya existe</b>')
                        return
                    }
                    c += 1
                }

                if (b == 0) {
                    var fila = $('valores').insertRow(1)
                    fila.innerHTML = "<tr><td style='width:5%;text-align:center'><img title='Eliminar Movimiento' onclick='deletValue(" + $('tipopercod').value + ")' src='/fw/image/icons/eliminar.png' style='cursor: pointer' border='0'/></td><td style='width:95%; id='" + $('tipopercod').value + "'>" + $('tipopercod').value + "</td ></tr>"
                    campos_defs.clear("tipopercod")
                }
            }
        }

        function onSave() {
            var valor = ""
            var top = $('valores').querySelectorAll('tr').length
            console.log(top)
            var c = 1

            while (c < top) {
                var ar = $('valores').querySelectorAll('tr')[c]
                    valor += ar.querySelectorAll('td')[1].innerText + ','
            
                c += 1
            }
            parent.guardar(idParam, valor, false)
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
            <td  style="text-align:center">Valor</td>
        </tr>
    </table>

   <div id="tabla" style="width:100%;overflow:auto;"></div>
   <div id="campo_def" style="background-color:white; text-align:center">
       <table class="tb1" style="width:70%; margin:auto">
           <tr class="tbLabel" >
                <td>Tipo</td>
           </tr>
           <tr>
                <td>
                <script>
                    campos_defs.add('tipopercod', {
                        enDB: true
                    })
                </script>
                </td>
           </tr>
       </table>
   </div>
   <div id='divPie' style='padding-top:10px;width:100%;overflow:hidden;text-align:center;'><img alt='' title='agregar' style="cursor:pointer" onclick='newValue()' src='/fw/image/param_def/agregar.png' /></div>

   <iframe name="divParametros" id="divParametros"  style="width:100%; overflow:auto;" frameborder="0" src="enBlanco.htm"></iframe>
</body>
</html>