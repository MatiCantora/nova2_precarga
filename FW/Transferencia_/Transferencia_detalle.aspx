<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Dim indice = nvUtiles.obtenerValor("indice", "")
    Me.contents("filtrotransf_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='transf_tipos'><campos>distinct (rtrim(transf_tipo)) as transf_tipo</campos><orden>transf_tipo</orden><grupo></grupo><filtro></filtro></select></criterio>")

%>
<HTML>
    <HEAD>
        <title>Transferencia Detalle</title>
            <!--<meta http-equiv="X-UA-Compatible" content="IE=8"/>-->
            <!--meta charset='utf-8'-->
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
            <script type="text/javascript" src="/fw/script/nvFW.js"></script>
            <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
            <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
            <script type="text/javascript" src="/fw/script/tScript.js"></script>
            <%= Me.getHeadInit()   %>
            <script type="text/javascript">

                var id_transferencia = 0
                var indice = 0
                var Transferencia
                var detalle 
                var win = nvFW.getMyWindow()

                function window_onload()
                {
                    
                    Transferencia = win.options.Transferencia
                    detalle = win.options.detalle

                    indice = $('indice').value
                    $('id_transferencia_txt').value = indice
                    if (indice == -1)   // Alta de Detalle
                    {
                        $('id_transferencia_txt').value = Transferencia["detalle"].length
                        // CargarTransf_Tipo($('cb_transf_tipo'),'SP')
                        $('transferencia').value = ''
                    }
                    else                // Modificación Detalle
                    {
                        CargarTransf_Tipo($('cb_transf_tipo'), Transferencia["detalle"][indice]["transf_tipo"])
                        $('transferencia').value = Transferencia["detalle"][indice]["transferencia"] = Transferencia["detalle"][indice]["title"]
                        $('opcional').checked = Transferencia["detalle"][indice]["opcional"]
                        $('title_hide').checked = !Transferencia["detalle"][indice].parametros_extra.title_hide ? false : Transferencia["detalle"][indice].parametros_extra.title_hide

                        if (Transferencia["detalle"][indice]["transf_estado"] == 'N')
                            $('estado').options[1].selected = true
                        else
                            $('estado').options[0].selected = false
                    }

                    cb_Transf_Tipo_on_change()

                    window_onresize()

                }

                function CargarTransf_Tipo(cb, transf_tipo)
                {
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtrotransf_tipos,"","","","")
                    while (!rs.eof())
                    {
                        cb.options.length++
                        cb.options[cb.options.length - 1].value = rs.getdata('transf_tipo')
                        cb.options[cb.options.length - 1].text = rs.getdata('transf_tipo')
                        if (transf_tipo == rs.getdata('transf_tipo'))
                            cb.options[cb.options.length - 1].selected = true
                        rs.movenext()
                    }
                }

                var objScriptEditar = new tScript();
                function cb_Transf_Tipo_on_change()
                {
                    if (parent.window.tienePermisoDeEdicion(Transferencia["detalle"][indice])) {
                        var type = $('cb_transf_tipo').value;
                        type = type == 'IUS' ? 'USR' : type;

                        if (type == 'SP' || type == 'SSR' || type == 'SCR' || type == 'SSC')
                        {
                            $('tbPie').hide()
                            
                            objScriptEditar.cargar_parametros(Transferencia.parametros)
                            objScriptEditar.script_txt = Transferencia.detalle[indice].TSQL
                            objScriptEditar.lenguaje = type == 'SP' ? 'SQL' : Transferencia.detalle[indice].lenguaje
                            objScriptEditar.cod_cn = Transferencia.detalle[indice].cod_cn
                            objScriptEditar.protocolo = "SCRIPT"
                            objScriptEditar.parametros_extra = !Transferencia.detalle[indice].parametros_extra ? {} : Transferencia.detalle[indice].parametros_extra 

                            win.options.objScriptEditar = objScriptEditar
                            win.options.indice = $('indice').value
                            
                            $('ifrDetalle').src = "/fw/transferencia/editor_script.aspx"
                        }
                        else
                            $('ifrDetalle').src = '/FW/Transferencia/transferencia_detalle_' + type + '.aspx?indice=' + indice
                    } else {
                        win.height = 100;
                        win.updateWidth();
                    }
                }

                function return_Transferencia()
                {
                    return Transferencia
                }

                function return_detalle() {
                    return detalle
                }

                function return_indice() {
                    return $('indice').value
                }


                function btn_Aceptar_onclick() {
                    
                   /* if ($('transferencia').value == "")
                    {
                        alert("Ingrese el nombre de la tarea.")
                        return
                    }*/

                    if ($('transferencia').value  == "") {
                        $('transferencia').value = "Tarea " + $('cb_transf_tipo').value + "(" + $('indice').value + ")"
                    }

                    var indice = $('indice').value
                    Transferencia["detalle"][indice]["transferencia"] = $('transferencia').value
                    Transferencia["detalle"][indice]["opcional"] = $('opcional').checked
                    Transferencia["detalle"][indice]["transf_estado"] = $('estado').value
                    Transferencia["detalle"][indice].parametros_extra.title_hide = $('title_hide').checked

                    if (parent.window.tienePermisoDeEdicion(Transferencia["detalle"][indice]))
                     {

                        var strError = window.frames[0].validar();
                        if (strError != '') {

                            confirm('\n' + strError, {
                                width: 400,
                                height: "auto",
                                className: "alphacube",
                                okLabel: "Si",
                                cancelLabel: "No",
                                onOk: function (w) {
                                    win.options.Transferencia = window.frames[0].guardar()
                                    w.close()
                                    win.close()
                                },
                                onCancel: function (w) {
                                    w.close(); return
                                }
                            });

                            return null
                        }
                     else
                         win.options.Transferencia = window.frames[0].guardar()

                        //val = window.frames[0].Aceptar();
                        if (!win.options.Transferencia)
                          return null
                     }     
                    else 
                     {
                       Transferencia["detalle"][indice]["orden"] = indice
                       win.options.Transferencia = Transferencia
                     } 

                    win.close()
                }

                function btn_cancelar_onclick()
                {
                    for (var i = Transferencia["detalle"][indice]["parametros_det"].length - 1; i >= 0; i--)
                        if (Transferencia["detalle"][indice]["parametros_det"][i]["estado"] == 'N')
                            Transferencia["detalle"][indice]["parametros_det"].splice(i, 1)

                    win.close()
                }

                function window_onunload()
                {
                    win.options.Transferencia = Transferencia
                    win.close()
                }


                function window_onresize()
                {
                    try
                    {
                        var dif = Prototype.Browser.IE ? 5 : 2
                        var body_h = $$('body')[0].getHeight()
                        var divCabe_h = $('divCabe').getHeight()
                        var tbPie_h = $('tbPie').style.display == 'none' ? 0 : $('tbPie').getHeight()
                        var alto = body_h - divCabe_h - tbPie_h - dif
                        $('ifrDetalle').setStyle({ 'height': alto + 'px' })
                        //console.log($('divCabe').getHeight(), $('ifrDetalle').getHeight(), $('tbPie').getHeight())
                    }
                    catch (e) {}
                }

                var winEditor
                function editar_title() {

                    winEditor = nvFW.createWindow({
                        className: 'alphacube',
                        title: '<b>Editar Titulo</b>',
                        url: '/fw/transferencia/editor_textarea.aspx',
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        width: 700,
                        height: 350,
                        resizable: true,
                        destroyOnClose: true,
                        onClose: return_editar_title
                    })

                    winEditor.options.userData = {}
                    winEditor.options.userData.texto = $('transferencia').value
                    
                    winEditor.showCenter(true)
                }

                function return_editar_title() {
                    
                    $('transferencia').value = winEditor.options.userData.texto
                }
          
            </script>
    </HEAD>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="width:100%;height:100%;overflow:hidden">
            <div id="divCabe" style="width:100%">
                <input type="hidden" name="indice" id="indice" value="<%=indice %>" />
                <table class='tb1'>
                    <tr>
                        <td class="Tit2" style="width:10%;text-align:center;font-weight:bold ">Nº</td>
                        <td class="Tit2" style="width:10%;text-align:center;font-weight:bold">Tipo</td>
                        <%--<td style="width:5%;text-align:center;">Ocultar</td>--%>
                        <td class="Tit2" style="font-weight:bold">
                        <div style="width:100%;display:inline-block;text-align:center;vertical-align:top">Tarea</div>
                        </td>
                        <td class="Tit2" style="width:12%;font-weight:bold">
                            <div style="width:100%;display:inline-block;float:right;text-align:right;vertical-align:top">
                                 <input type="checkbox" name="title_hide" id="title_hide" style="border:0px;vertical-align:middle"/>Ocultar titulo</div>
                        </td>
                        <td class="Tit2" style="width:5%;text-align:center;font-weight:bold">Opcional</td>
                        <td class="Tit2" style="width:10%;text-align:center;font-weight:bold">Estado</td>
                    </tr>
                    <tr>
                        <td><input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" onkeypress='return valDigito()' disabled="disabled" /></td>
                        <td><select name="cb_transf_tipo" id="cb_transf_tipo" style="width:100%" onclick="cb_Transf_Tipo_on_change()" disabled="disabled"></select></td>
                      <%--  <td><input type="checkbox" name="title_hide" id="title_hide" style="width:100%;border:0px" /></td>--%>
                        <td colspan="2"><input type="text" name="transferencia"  id="transferencia" style="width:94%" />&nbsp;<input type='button' value="..." onclick="editar_title()" style='width:5%;position:relative; display:inline-block;cursor:pointer' /></td>                
                        <td><input type="checkbox" name="opcional" id="opcional" style="width:100%;border:0px" /></td>
                        <td>
                            <select name="estado" id="estado" style="width:100%">
                                <option value='A'>Activo</option>
                                <option value='N'>Nulo</option>
                            </select>
                        </td>
                    </tr>
                </table>  
            </div>
            <iframe id="ifrDetalle" style='width:100%;overflow:hidden' src='' frameborder="0" ></iframe>
            <table class='tb1' id="tbPie">
                <tr>
                    <td style="text-align:center;width:10%"">&nbsp;</td>
                    <td style="text-align:center;width:35%""><input type="button" style="width:100%;cursor:pointer" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                    <td style="text-align:center;width:10%"">&nbsp;</td>
                    <td style="text-align:center;width:35%""><input type="button" style="width:100%;cursor:pointer" name="btn_Cancelar" value="Cancelar" onclick="btn_cancelar_onclick()" /></td>
                    <td style="text-align:center;width:10%"">&nbsp;</td>
                </tr>
            </table>             
    </body>
</HTML>