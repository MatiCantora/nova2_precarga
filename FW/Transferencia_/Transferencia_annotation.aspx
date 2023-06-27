<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
    <head>
        <title>Transferencia Detalle NOTED</title>
         <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>


        <script type="text/javascript">
            var Annotation;
            var win;
            function window_onload() {

                win = nvFW.getMyWindow();
                Annotation = win.options.Annotation;

                $('cuerpo').value = Annotation.text;

                window_onresize();
            }
            function btn_Aceptar_onclick() {

                Annotation.text = CKEDITOR.instances.cuerpo.getData()
                Annotation.HTMLTitle();
                win.close();
            }

            function btn_cancelar_onclick() {
                win.close();
            }
        

            function window_onresize() {
                try {

                    var alto_comentario = $$('BODY')[0].getHeight()
                    
                    contenedores = $('body_annotation').querySelectorAll(".contenedor")
                     for (var i = 0; i < contenedores.length; i++)
                         if (contenedores[i].style.display != 'none') 
                             alto_comentario = alto_comentario - contenedores[i].getHeight()

                     $('comentario').setStyle({ height: alto_comentario })
                     CKEDITOR.instances.cuerpo.resize('100%', alto_comentario)

               
                }
                catch (e1) { }

            }
        </script>
    </head>
    <body onload="return window_onload()" id="body_annotation" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden">
            <table class="tb1" style="width: 100%">
                <tr  class="tbLabel contenedor">
                    <td style="height: 10px;">Anotación</td>
                </tr>
             </table>
             <div id="comentario" style="vertical-align:top;display:inline-block;width: 100%; height: 100%; top: 0; margin: 0px; padding: 0px;">
              <textarea id="cuerpo" name="cuerpo"></textarea>
              <script type="text/javascript">
                              CKEDITOR.replace('cuerpo', {
                                  toolbar: 'Comentarios', height: '100%', width: '100%', resize_enabled: false, removePlugins: "elementspath", on: {
                                      instanceReady: function (event) {
                                          window_onresize()
                                      }
                                  }
                              });
             </script>
           </div>
           <table class="tb1" style="width: 100%">
                <tr class="contenedor">
                    <td style="width:10%">&nbsp;</td>
                    <td style="width:30%"><input type="button" style="width:100%" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                    <td style="width:20%">&nbsp;</td>
                    <td style="width:30%"><input type="button" style="width:100%" name="btn_Cancelar" value="Cancelar" onclick="btn_cancelar_onclick()" /></td>
                    <td>&nbsp;</td>
                </tr>
            </table>
    </body>
</html>