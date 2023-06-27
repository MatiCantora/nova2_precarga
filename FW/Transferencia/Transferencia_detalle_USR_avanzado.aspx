<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<html>
<head>
<title>Transferencia USR</title>
        <meta http-equiv="X-UA-Compatible" content="IE=8"/>
        <!--meta charset='utf-8'-->
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/transferencia/css/tags.css" rel="stylesheet" type="text/css" />

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" language="javaScript" src="/FW/script/tScript.js"></script>     
        
        <script type="text/javascript" src="/FW/transferencia/script/tags.js"></script>
        

        <style type="text/css">
        </style>
        <script type="text/javascript" language="javascript">
            var win;
            var usr;
            var oFCKeditor;
            var parameters;
            var parametros_det;
            var usarInputsPersonalizados;
            function window_onload() {
                win = nvFW.getMyWindow();
                usr = win.options.usr;
                window.top.parametros_det = win.options.parametros_det;
                parametros_det = win.options.parametros_det;
                usarInputsPersonalizados = usr.parametros_extra.usarInputsPersonalizados;
                
                oFCKeditor = new FCKeditor('inputs');
                oFCKeditor.ToolbarSet = 'Usr';
                oFCKeditor.BasePath = '/FW/script/fckeditor/';
                oFCKeditor.Height = '100%';
                oFCKeditor.Value = '';
                oFCKeditor.ReplaceTextarea();
                var intervall = setInterval(function(){
                    if(typeof(FCKeditorAPI) != 'undefined'){
                        try {
                            doWindow_onload();
                            clearInterval(intervall);
                        } catch (e) {}
                    }
                }, 200);
                
                vMenu = new tMenu('topMenu', 'vMenu');
                vMenu.alineacion = 'derecha';
                vMenu.estilo = 'B';

                ImagenesTransf = {}
                ImagenesTransf['nueva'] = new Image();
                ImagenesTransf['nueva'].src = '/FW/image/transferencia/nueva.png';
                ImagenesTransf['periodicidad'] = new Image();
                ImagenesTransf['periodicidad'].src = '/FW/image/transferencia/periodicidad.png';
                vMenu.imagenes = ImagenesTransf;

                var menuXmlIzq = '<?xml version="1.0" encoding="ISO-8859-1"?>';
                menuXmlIzq += '<resultado>';
                menuXmlIzq += '     <MenuItems>';
                menuXmlIzq += '         <MenuItem id="100">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>nueva</icono>';
                menuXmlIzq += '             <Desc> </Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>usarInputsPersonalizadosChange()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="101">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>periodicidad</icono>';
                menuXmlIzq += '             <Desc>Regenerar</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>regenerar()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '     </MenuItems>';
                menuXmlIzq += '</resultado>';
                vMenu.CargarXML(menuXmlIzq);
                vMenu.MostrarMenu();
                usarInputsPersonalizadosChange(false);
            }
            function doWindow_onload() {
                window_onresize();
                
                usr.parametros_extra.inputs = usr.parametros_extra.inputs == undefined ? '' : usr.parametros_extra.inputs;
                FCKeditorAPI.GetInstance('inputs').SetData(usr.parametros_extra.inputs);
            }
            function usarInputsPersonalizadosChange(change) {
                change = typeof(change) === 'undefined' ? true : change;
                if(change) {
                    usarInputsPersonalizados = !usarInputsPersonalizados;
                }
                if(usarInputsPersonalizados) {
                    $('fckContainer').show();
                    $$('.mnuCELL_OnOver_B, .mnuCELL_Normal_B')[0].select('span')[1].update('Deshabilitar');
                } else {
                    $('fckContainer').hide();
                    $$('.mnuCELL_OnOver_B, .mnuCELL_Normal_B')[0].select('span')[1].update('Habilitar');
                }
            }
            function window_onresize() {
                var h = $$('body')[0].getHeight() - 60;
                $('fckContainer').setStyle({
                    height: h + 'px'
                });
            }
            function window_onunload() {
                delete window.top.parametros_det;
            }
            function btn_Aceptar_onclick() {
                usr.parametros_extra.inputs = FCKeditorAPI.GetInstance('inputs').GetData();
                usr.parametros_extra.usarInputsPersonalizados = usarInputsPersonalizados;
                win.close();
            }
            function btn_Cancelar_onclick() {
                win.close();
            }
            function regenerar() {
                var str  = '<p>';
                str += '<table>';
                for(var i in parametros_det) {
                    var parametro_det = parametros_det[i];
                    str += '<tr>';
                    str += '<td>';
                    str += parametro_det.label;
                    str += '</td>';
                    str += '<td>';
                    str += '<TransfUsrParametro parametro="' + parametro_det.parameter.parametro + '"></TransfUsrParametro>';
                    str += '</td>';
                    str += '</tr>';
                }
                str += '</table>';
                str += '</p>';
                
                FCKeditorAPI.GetInstance('inputs').SetData(str);
            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
        <table class="tb2" width="100%">
            <tr>
                <td id="topMenu" colspan="2">
                </td>
            </tr>
            <tr>
                <td id="fckContainer" colspan="2" style="height: 230px;">
                    <textarea id="inputs" name="inputs"></textarea>
                </td>
            </tr>
            <tr>
                <td align="center"><input type="button" style="width:40%" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                <td align="center"><input type="button" style="width:40%" value="Cancelar" onclick="btn_Cancelar_onclick()" /></td>
            </tr>
        </table>
    </body>
</html>