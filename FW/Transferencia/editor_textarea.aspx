<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%
    Me.contents("FiltroXML_desde") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='transf_conf'><campos>id_transf_conf as id, transf_conf as [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("FiltroXML_verOperadores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")

 %>
<html>
<head>
<title>Editor</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tScript.js"></script>     
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>   
        <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>
        <% = Me.getHeadInit()%>
        
       <script type="text/javascript">
            var win = nvFW.getMyWindow()

            function guardar()
            {
                win.options.userData.texto = CKEDITOR.instances.cuerpo.getData().replace("<p>", "").replace("</p>", ""); //CKEDITOR.instances.cuerpo.document.getBody().getText();
                win.close()
            }

            function window_onload() {
                
                // Nueva implementacion con CKEditor
                CKEDITOR.config.toolbar = 'Transferencia'
                CKEDITOR.config.resize_enabled = false;
                CKEDITOR.config.removePlugins = 'elementspath';     // elimina barra inferior         

                CKEDITOR.replace('cuerpo', {
                    on: {
                        instanceReady: function (event) {
                            window_onresize()
                            CKEDITOR.instances.cuerpo.insertHtml(win.options.userData.texto);
                        }
                    }
                });

                window_onresize()
            }

            function window_onresize()
            {
                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_height = $$('BODY')[0].getHeight()
                    var divPie_height = $('divPie').getHeight()

                    var alto = (body_height - divPie_height - dif)

                    $('divCuerpo').setStyle({ height: alto })

                    CKEDITOR.instances.cuerpo.resize('100%', alto)
                }
                catch (e) {console.log(e.message)}
            }

            function cancelar()
            {
                win.close()
            }

        </script>
    </head>
    <body onload="return window_onload();" onresize="return window_onresize()" style="background-color:white; width: 100%;height: 100%;overflow: hidden;">
       <div id="divCuerpo" style="width:100%">
        <table class="tb1 table" id="tbCuerpo" style="width: 100%">
            <tr>
                <td>
                    <textarea id="cuerpo" name="cuerpo"></textarea>
                </td>
            </tr>
       </table>
       </div>
       <div id="divPie">
         <table class="tb1" style="width:100%">
                  <tr>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                        <td style="text-align:center;width:35%"><input type="button" style="width:100%" value="Aceptar" onclick="guardar()" /></td>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                        <td style="text-align:center;width:35%"><input type="button" style="width:100%" value="Cancelar" onclick="cancelar()" /></td>
                        <td style="text-align:center;width:10%">&nbsp;</td>
                    </tr>
          </table>
    </div>
    </body>
</html>