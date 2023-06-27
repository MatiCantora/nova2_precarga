<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim id_transferencia = nvUtiles.obtenerValor("id_transferencia", "")
    Dim tipo_salida = nvUtiles.obtenerValor("tipo_salida", "")
    Dim save_db = nvUtiles.obtenerValor("save_db", 0)
    Dim nro_cfg_pdf_export = nvUtiles.obtenerValor("nro_cfg_pdf_export", 1)

    Dim err = New nvFW.tError()
    err.salida_tipo = "HTML"

    Dim rs = nvDBUtiles.DBOpenRecordset("SELECT TOP 1 * FROM transf_cfg_pdf_export WHERE cfg_pdf_export_type = 1")
    If (rs.EOF) Then
        err.numError = 1012
        err.mensaje = "transf_cfg_pdf_export inexistente"
        err.titulo = "transf_cfg_pdf_export inexistente"
        err.mostrar_error()
    End If

    Dim zoom = rs.Fields("cfg_zoom").Value
    Dim marginTop = rs.Fields("cfg_margin_top").Value
    Dim marginRight = rs.Fields("cfg_margin_right").Value
    Dim marginBottom = rs.Fields("cfg_margin_bottom").Value
    Dim marginLeft = rs.Fields("cfg_margin_left").Value
    Dim pageSize = rs.Fields("cfg_page_size").Value
    Dim footerFontSize = rs.Fields("cfg_footer_font_size").Value
    Dim footerText = rs.Fields("cfg_footer_text").Value
    Dim orientation = rs.Fields("cfg_orientation").Value


    Me.contents("filtroXML_transf_cfg_pdf_export_abm") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.transf_cfg_pdf_export_abm' CommantTimeOut='1500'><parametros></parametros></procedure></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title></title>
        <meta http-equiv="X-UA-Compatible" content="IE=8"/>
        <!--meta charset='utf-8'-->
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/window_themes/default.css" rel="stylesheet" type="text/css"/> 
        <link href="/FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_def.js"></script>

        <style type="text/css">
            body {
                width: 96%;
                padding: 2%;
            }
            table {
                width: 100%;
                background: none !important;
            }
            table tr td{
                padding: 0px;
                border: 0;
                border-collapse: collapse;
                height: 21px;
            }
            table tr td.label{
                text-align: right;
                font-size: 12px;
                white-space: nowrap;
                width: 1px;
            }
            table tr td label.radio{
                position: relative;
                top: -2px;
                left: -4px;
            }
            table tr td input, table tr td select{
                width: 120px;
                padding: 1px;
                margin-right: 2px;
                text-align: right;
            }
            table tr td input[type="radio"]{
                width: 16px;
                margin: 3px 1px 0 0;
            }
            table.tb1.export {
                border-collapse: collapse;
            }
        </style>
        <script type="text/javascript">
            var id_transferencia = '<%= id_transferencia %>';
            var tipo_salida = '<%= tipo_salida %>';
            var nro_cfg_pdf_export = '<%= nro_cfg_pdf_export %>';

            function makeCopy() {
            
                var head = $(document.createElement('head'));
                try{head.update(parent.$$('head')[0].innerHTML);}catch(e){}
                head.select('script').each(function(script) {
                    script.remove();
                });
                head.select('link').each(function(link) {
                    if (!link.hasClassName('link_estable')) {
                        link.remove();
                    }
                });

                if (tipo_salida == 'pdf') {
                    var meta = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">';
                    head.insert({top: meta});
                }

                var body = $(document.createElement('body'));
                if(tipo_salida == 'html') {
                    body.setStyle({
                        overflow: 'auto',
                        margin: '0'
                    });
                }
                body.update(parent.$$('.divCanvas')[0].outerHTML);
                body.select('.pool').each(function(pool) {
                    var line = $(document.createElement('div'));
                    line.setStyle({
                        borderBottom: '1px solid #000000',
                        position: 'absolute',
                        bottom: '7px',
                        width: '100%'
                    });
                    pool.insert({bottom: line});
                });
                body.select('.selected_item').each(function(wrapper) {
                    wrapper.remove();
                });
                body.select('.divCtrl td.actions').each(function(element) {
                    element.update('');
                });
                body.select('.divCtrl.pool .resizer').each(function(r) {
                    r.remove();
                });
                body.select('.divCtrl.pool .icon').each(function(i) {
                    i.remove();
                });
                var html = $(document.createElement('html'));
                html.setAttribute('xmlns', "http://www.w3.org/1999/xhtml");
                html.setStyle({
                    overflow: 'visible'
                });
                html.insert({
                    bottom: head
                });
                html.insert({
                    bottom: body
                });

                var code = false;
                new Ajax.Request('/FW/Transferencia/Transferencia_tmpcopy_set.aspx', {
                    asynchronous: false,
                    parameters: {
                        html_code: html.outerHTML
                    },
                    onSuccess: function(response) {
                        code = response.responseText;
                    }
                });
                return code;
            }

            document.observe("dom:loaded", function() {
                $$('button')[0].observe('click', function() {
                    <% if (save_db = 0) then %>
                    var code = makeCopy();
                    var zoom;
                    if($$('#ajustar_pagina:checked').length > 0) {
                        zoom = 10;
                    } else {
                        zoom = ($('zoom').getValue() / 100);
                    }
                    var url = 'Transferencia_export.aspx?file_type=' + tipo_salida;
                    url += '&id_transferencia=' + id_transferencia;
                    url += '&tipo_salida=' + tipo_salida;
                    url += '&code=' + code;
                    url += '&zoom=' + zoom;
                    url += '&marginTop=' + $('marginTop').getValue();
                    url += '&marginBottom=' + $('marginBottom').getValue();
                    url += '&marginRight=' + $('marginRight').getValue();
                    url += '&marginLeft=' + $('marginLeft').getValue();
                    url += '&pageSize=' + $('pageSize').getValue();
                    url += '&footerFontSize=' + $('footerFontSize').getValue();
                    url += '&footerText=' + $('footerText').getValue();
                    url += '&orientation=' + $('orientation').getValue();
                    
                    if (tipo_salida == 'pdf') {
                        //window.top.location = url;
                        window.open(url, '_blank');
                    } else {
                        window.open(url, '_blank');
                    }
                    <% else %>
                    var rs = new tRS();
                    var filtroWhere = "<criterio><procedure>\n\
                        <parametros>\n\
                            <nro_cfg_pdf_export DataType='int'>" + nro_cfg_pdf_export + "</nro_cfg_pdf_export>\n\
                            <cfg_zoom DataType='varchar(50)'>" + $('zoom').getValue() + "</cfg_zoom>\n\
                            <cfg_page_size DataType='varchar(50)'>" + $('pageSize').getValue() + "</cfg_page_size>\n\
                            <cfg_footer_font_size DataType='varchar(50)'>" + $('footerFontSize').getValue() + "</cfg_footer_font_size>\n\
                            <cfg_margin_top DataType='varchar(50)'>" + $('marginTop').getValue() + "</cfg_margin_top>\n\
                            <cfg_margin_right DataType='varchar(50)'>" + $('marginRight').getValue() + "</cfg_margin_right>\n\
                            <cfg_margin_bottom DataType='varchar(50)'>" + $('marginBottom').getValue() + "</cfg_margin_bottom>\n\
                            <cfg_margin_left DataType='varchar(50)'>" + $('marginLeft').getValue() + "</cfg_margin_left>\n\
                            <cfg_footer_text DataType='varchar(50)'>" + $('footerText').getValue() + "</cfg_footer_text>\n\
                        </parametros></procedure></criterio>";
                    rs.open(nvFW.pageContents.filtroXML_transf_cfg_pdf_export_abm, "", filtroWhere, "")
                    <% end if %>
                    window.top.win.close();
                    return false;
                    });
                if($$('#ajustar_pagina:checked').length == 0){
                    $('td_zoom').show();
                } else {
                    $('td_zoom').hide();
                }
                $$('input[type="radio"][name="ajustar"]').each(function(ajustar){
                    ajustar.observe('change', function(){
                        if($$('#ajustar_pagina:checked').length == 0){
                            $('td_zoom').show();
                        } else {
                            $('td_zoom').hide();
                        }
                    });
                });
                if (tipo_salida == 'html') {
                    $$('button')[0].simulate('click');
                }
            });
        </script>
    </head>
    <body>
        <table class="tb1 export">
            <tr>
                <td class="label">Ajustar a:</td>
                <td>
                    <table>
                        <tr>
                            <td>
                                <input id="ajustar_pagina" type="radio" name="ajustar" <% if(zoom <> 0) then 
                                                                                             Response.Write("checked='checked'") 
                                                                                           end if %>/>
                                       <label for="ajustar_pagina" class="radio">Página</label>
                            </td>
                            <td>
                                <input id="ajustar_zoom" type="radio" name="ajustar" <% if(zoom <> 0) then
                                                                                          Response.Write("checked='checked'") 
                                                                                        end if%>/>
                                       <label for="ajustar_zoom" class="radio">Zoom</label>
                            </td>
                            <td width="16px">
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr id='td_zoom' style='display: none;'>
                <td class="label">Zoom:</td>
                <td><input id="zoom" type="text" value="<% Response.Write(zoom)%>"/>%</td>
            </tr>
            <tr>
                <td class="label">Margen Arriba:</td>
                <td><input id="marginTop" type="text" value="<% Response.Write(marginTop)%>"/>mm</td>
            </tr>
            <tr>
                <td class="label">Margen Abajo:</td>
                <td><input id="marginBottom" type="text" value="<% Response.Write(marginBottom)%>"/>mm</td>
            </tr>
            <tr>
                <td class="label">Margen Derecha:</td>
                <td><input id="marginRight" type="text" value="<% Response.Write(marginRight)%>"/>mm</td>
            </tr>
            <tr>
                <td class="label">Margen Izquierda:</td>
                <td><input id="marginLeft" type="text" value="<% Response.Write(marginLeft)%>"/>mm</td>
            </tr>
            <tr>
                <td class="label">Tamaño de página:</td>
                <td>
                    <select id="pageSize">
                        <option value="Letter" <% if (pageSize = "Letter") then 
                                                     Response.Write("selected='selected'") 
                                                  end if  %>>Letter</option>
                        <option value="A5" <% if (pageSize = "A5") then 
                                                     Response.Write("selected='selected'") 
                                              end if  %>>A5</option>
                        <option value="A4" <% if (pageSize = "A4") then 
                                                Response.Write("selected='selected'") 
                                              end if %>>A4</option>
                        <option value="A3" <% if (pageSize = "A3") then 
                                                 Response.Write("selected='selected'") 
                                              end if %>>A3</option>
                        <option value="A2" <% if (pageSize = "A2") then 
                                                Response.Write("selected='selected'") 
                                               end if %>>A2</option>
                        <option value="A1" <% if (pageSize = "A1") then 
                                                Response.Write("selected='selected'") 
                                              end if %>>A1</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="label">Orientación de página:</td>
                <td>
                    <select id="orientation">
                        <option value="Portrait" <% if(orientation = "Portrait") then 
                                                        Response.Write("selected='selected'") 
                                                     end if %>>Vertical</option>
                        <option value="Landscape" <% if(orientation = "Landscape") then 
                                                       Response.Write("selected='selected'") 
                                                     end if %>>Horizontal</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="label">Tamaño de Fuente del Footer:</td>
                <td><input id="footerFontSize" type="text" value="<% Response.Write(footerFontSize)%>"/></td>
            </tr>
            <tr>
                <td class="label">Texto del pie de página:</td>
                <td><input id="footerText" type="text" value="<% Response.Write(footerText)%>"/></td>
            </tr>
            <tr><td colspan="2">&nbsp;</td>
                </tr>
            <tr>
                <td class="label"></td>
                <td>
                    <% If (save_db = 0) Then%>
                    <button>Exportar</button>
                    <%  Else%>
                    <button>Guardar</button>
                    <% End If%>
                </td>
            </tr>
        </table>
    </body>
</html>