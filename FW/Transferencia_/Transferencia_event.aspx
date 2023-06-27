<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
    <head>
        <title>Transferencia Detalle Event</title>
         <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
            
        <style type="text/css">
        </style>
        <script type="text/javascript" language="javascript">
            var win;
            var tEvent;
            function window_onload() {
                win = nvFW.getMyWindow();
                tEvent = win.options.tEvent;

                $('title').value = tEvent.title;
            }
            function window_onresize() {

            }
            function window_onunload() {

            }
            function btn_Aceptar_onclick() {
                tEvent.title = $('title').value;
                tEvent.HTMLTitle();
                
              //  parent.window.Undo.add();
                win.close();
            }
            function btn_Cancelar_onclick() {
                win.close();
            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
        <div id="divCabe" style="width:100%">
            <table class="tb1" width="100%">
                <tr class="tbLabel">
                    <td style="width:10%">Nº</td>
                    <td style="width:10%">Tipo</td>
                    <td style="">Detalle Transferencia</td>
                </tr>
                <tr>
                    <td><input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" onkeypress='return valDigito()' disabled="disabled" /></td>
                    <td><select name="cb_transf_tipo" id="cb_transf_tipo" style="width:100%" onclick="cb_Transf_Tipo_on_change()" disabled="disabled"></select></td>
                    <td><input type="text" name="title" id="title" style="width:100%" /></td>
                </tr>
            </table>  
        </div>
        <table class="tb1" id="tbPie">
            <tr>
                 <td style="width:5%">&nbsp;</td>
                 <td style="width:40%;text-align:center"><input type="button" style="width:40%" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                 <td>&nbsp;</td>
                 <td style="width:40%;text-align:center"><input type="button" style="width:40%" name="btn_Cancelar" value="Cancelar" onclick="btn_Cancelar_onclick()" /></td>
                 <td style="width:5%">&nbsp;</td>
            </tr>
        </table>
    </body>
</html>