<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
       
    Dim nro_ref As Integer = nvFW.nvUtiles.obtenerValor("nro_ref", 0)
    Dim tipo_salida As String = nvFW.nvUtiles.obtenerValor("tipo_salida", "")
    Dim save_db As Integer = nvFW.nvUtiles.obtenerValor("save_db", 0)
    Dim nro_cfg_pdf_export As Integer = nvFW.nvUtiles.obtenerValor("nro_cfg_pdf_export", 1)
    
    'Me.contents("filtroExportar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.cfg_pdf_export_abm'><parametros><nro_cfg_pdf_export DataType='int'>%nro_cfg_pdf_export%</nro_cfg_pdf_export><cfg_zoom DataType='varchar'>%cfg_zoom%</cfg_zoom><cfg_page_size DataType='varchar'>%cfg_page_size%</cfg_page_size><cfg_footer_font_size DataType='varchar'>%cfg_footer_font_size%</cfg_footer_font_size><cfg_margin_top DataType='varchar'>%cfg_margin_top%</cfg_margin_top><cfg_margin_right DataType='varchar'>%cfg_margin_right%</cfg_margin_right><cfg_margin_bottom DataType='varchar'>%cfg_margin_bottom%</cfg_margin_bottom><cfg_margin_left DataType='varchar'>%cfg_margin_left%</cfg_margin_left><cfg_footer_text DataType='varchar'>%cfg_footer_text%</cfg_footer_text></parametros></procedure></criterio>")
    Me.contents("filtroExportar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='cfg_pdf_export_abm'></procedure></criterio>")
    
    Dim zoom As String = "1.5"
    Dim marginTop As String = "10"
    Dim marginRight As String = "6"
    Dim marginBottom As String = "10"
    Dim marginLeft As String = "10"
    Dim pageSize As String = "A4"
    Dim footerFontSize As String = "9"
    Dim footerText As String = "P�gina [page] de [topage]"
    
    Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("SELECT TOP 1 * FROM cfg_pdf_export WHERE cfg_pdf_export_type = 1")
    If (Not rs.EOF) Then
        zoom = rs.Fields("cfg_zoom").Value
        marginTop = rs.Fields("cfg_margin_top").Value
        marginRight = rs.Fields("cfg_margin_right").Value
        marginBottom = rs.Fields("cfg_margin_bottom").Value
        marginLeft = rs.Fields("cfg_margin_left").Value
        pageSize = rs.Fields("cfg_page_size").Value
        footerFontSize = rs.Fields("cfg_footer_font_size").Value
        footerText = rs.Fields("cfg_footer_text").Value
    End If
    nvDBUtiles.DBCloseRecordset(rs)


%>

<script runat='server'>
    Sub setTamPagina(ByVal pageSize As String, ByVal opcion As String)
        If pageSize = opcion Then
            Response.Write("selected='selected'")
        Else
            Response.Write("")
        End If
    End Sub
        
    Sub setDisplayBoton(ByVal save_db As Integer, ByVal opcion As String)
        If (opcion = "E") Then  'Exportar
            If (save_db = 0) Then
                Response.Write("style='display:inline'")
            Else
                Response.Write("style='display:none'")
            End If
        Else 'Guardar
            If (save_db = 0) Then
                Response.Write("style='display:none'")
            Else
                Response.Write("style='display:inline'")
            End If
        End If
    End Sub
            
</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Referencia PreExport PDF</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>

    <%= Me.getHeadInit()%>

    <style type="text/css">
        td > label { margin-left: -30px; color: #8F8F8F; }
    </style>
        
    <script type="text/javascript" language="javascript">
        var nro_ref = '<%= nro_ref %>',
            tipo_salida = '<%= tipo_salida %>',
            nro_cfg_pdf_export = '<%= nro_cfg_pdf_export %>',
            save_db = '<%= save_db %>'
        var myWin = nvFW.getMyWindow()

        var vButtonItems = {};
        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Exportar";
        vButtonItems[0]["etiqueta"] = "Exportar";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return exportar()";

        vButtonItems[1] = {};
        vButtonItems[1]["nombre"] = "Guardar";
        vButtonItems[1]["etiqueta"] = "Guardar";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return exportar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_heigth = $$('body')[0].getHeight(),
                    tb_exportar_heigth = $('tb_exportar').getHeight()
                //$('iframe_exportar').setStyle({ 'height': body_heigth - tb_exportar_heigth - dif })
            }
            catch(e) {}
        }

        function window_onload() {
            vListButton.MostrarListButton()
            window_onresize()
        }

        function exportar() {          
            if (save_db == 0) {
                var url = 'ref_export.aspx?';
                url += 'nro_ref=' + nro_ref;
                url += '&tipo_salida=' + tipo_salida;
                url += '&zoom=' + $('zoom').getValue();
                url += '&marginTop=' + $('marginTop').getValue();
                url += '&marginBottom=' + $('marginBottom').getValue();
                url += '&marginRight=' + $('marginRight').getValue();
                url += '&marginLeft=' + $('marginLeft').getValue();
                url += '&pageSize=' + $('pageSize').getValue();
                url += '&footerFontSize=' + $('footerFontSize').getValue();
                url += '&footerText=' + $('footerText').getValue();

                window.open(url, '_blank');
            } else {
                var rs = new tRS();
                var filtroXML = nvFW.pageContents.filtroExportar
                //var params = "<criterio><params nro_cfg_pdf_export='" + nro_cfg_pdf_export + "' cfg_zoom='" + $('zoom').getValue() + "' cfg_page_size='" + $('pageSize').getValue() + "' cfg_footer_font_size='" + $('footerFontSize').getValue() + "' cfg_margin_top='" + $('marginTop').getValue() + "' cfg_margin_right='" + $('marginRight').getValue() + "' cfg_margin_bottom='" + $('marginBottom').getValue() + "' cfg_margin_left='" + $('marginLeft').getValue() + "' cfg_footer_text='" + $('footerText').getValue() + "'/></criterio>"
                //rs.open(filtroXML, '', '', '', params)

                var strXML = "<config nro_cfg_pdf_export='" + nro_cfg_pdf_export + "' cfg_zoom='" + $('zoom').getValue() + "' cfg_page_size='" + $('pageSize').getValue() + "' cfg_footer_font_size='" + $('footerFontSize').getValue() + "' cfg_margin_top='" + $('marginTop').getValue() + "' cfg_margin_right='" + $('marginRight').getValue() + "' cfg_margin_bottom='" + $('marginBottom').getValue() + "' cfg_margin_left='" + $('marginLeft').getValue() + "' cfg_footer_text='" + $('footerText').getValue() + "'/>"
                filtroWhere = "<criterio><procedure>"
                filtroWhere += "<parametros>"
                filtroWhere += "<strXML><![CDATA[" + strXML + "]]></strXML>"
                filtroWhere += "</parametros>"
                filtroWhere += "</procedure></criterio>"
                rs.open(filtroXML, '', filtroWhere, '', '')
            }
            myWin.close();
        }

        </script>
    </head>
    <body onload="return window_onload()" onresize="window_onresize()" style="width:100%;height: 100%; overflow: auto; background: #FFFFFF;">
        <table class="tb1" id="tb_exportar" style="width: 100%; border-radius:0;">
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Zoom:</td>
                <td style="width:50%;"><input id="zoom" type="number" value="<%= zoom%>"/></td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Margen Arriba:</td>
                <td style="width:50%;">
                    <input id="marginTop" type="number" value="<%= marginTop%>"/>
                    <label for="marginTop">mm</label>
                </td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Margen Abajo:</td>
                <td style="width:50%;">
                    <input id="marginBottom" type="number" value="<%=marginBottom%>"/>
                    <label for="marginBottom">mm</label>
                </td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Margen Derecha:</td>
                <td style="width:50%;">
                    <input id="marginRight" type="number" value="<%= marginRight%>"/>
                    <label for="marginRight">mm</label>
                </td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Margen Izquierda:</td>
                <td style="width:50%;">
                    <input id="marginLeft" type="number" value="<%= marginLeft%>"/>
                    <label for="marginLeft">mm</label>
                </td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Tama�o de p�gina:</td>
                <td style="width:50%;">
                    <select id="pageSize">
                        <option <% setTamPagina(pageSize,"Letter") %>>Letter</option>
                        <option <% setTamPagina(pageSize,"A4") %> >A4</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Tama�o de Fuente del Footer:</td>
                <td style="width:50%;"><input id="footerFontSize" type="number" value="<%= footerFontSize%>"/></td>
            </tr>
            <tr>
                <td class="tit1" style="width:50%; text-align:right;">Texto del pie de p�gina</td>
                <td style="width:50%;"><input id="footerText" type="text" value="<%= footerText%>"/></td>
            </tr>
            <tr>
                <td style="width:30%; padding-top: 1em;" colspan="2">
                    <table width="100%">
                        <tr style="text-align:center;">
                            <td width="100%">
                                <div id="divExportar" <% setDisplayBoton(save_db,"E") %>></div>
                                <div id="divGuardar" <% setDisplayBoton(save_db,"G") %>></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </body>
</html>