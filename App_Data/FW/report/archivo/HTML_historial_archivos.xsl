<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    

    <xsl:template match="/">
        <html>
                    <head>
                      <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                      <title>Grupos de Archivos</title>
                      <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

                      <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
                      <script type="text/javascript" language="javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                      <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
                      <script type="text/javascript" language='javascript' src="/FW/script/tcampo_head.js"></script>

                      <script language="javascript" type="text/javascript">
                        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                        var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                        campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                        campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                        campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                        campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                        campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                        campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                        if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW
                      </script>
                        <script type="text/javascript"  language="javascript" >
                            <xsl:comment>
                                <![CDATA[ 
					                function  window_onload()
                          {
                            window_onresize()
                          }
                                       
					                function window_onresize()
					                {
					                    try
					                    {
					                     //var dif = Prototype.Browser.IE ? 5 : 2
					                     var body_height = $$('body')[0].getHeight()
					                     var tbCabe_height = $('tbCabe').getHeight()
					                     //var div_pag_height = $('div_pag').getHeight()
                                         
					                     $('divDetalle').setStyle({height: body_height - tbCabe_height + 'px'})
                					     
                               $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
					                    }
					                     catch(e){}
					                }         
            					    
					                function tdScroll_hide_show(show)
                          {
                            var i = 1
                            while(i <=  campos_head.recordcount)
                              {
                                if(show &&  $('tdScroll'+ i) != undefined)
                                  $('tdScroll'+ i).show() 
                                          
                                if(!show &&  $('tdScroll'+ i) != undefined)
                                  $('tdScroll'+ i).hide() 
                                          
                                i++
                              }
                          } 
                                    
      
                                ]]>
                            </xsl:comment>
                        </script>
                        <style type="text/css">
                            .tr_cel TD {
                            background-color: #F0FFFF !Important
                            }
                        </style>
                    </head>
                    <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
                        <table width="100%" class="tb1" id="tbCabe">
                               <tr class="tbLabel">
                                  <td>
                                     <script>campos_head.agregar('Documento', true, 'Descripcion')</script>
                                  </td>
                                  <td style='width:20%'>
                                     <script>campos_head.agregar('Fecha', true, 'momento')</script>
                                  </td>
                                  <td style='width:25%'>
                                     <script>campos_head.agregar('Operador', true, 'nombre_operador')</script>
                                  </td>
                                  <td style='width:15%'>
                                    <script>campos_head.agregar('Estado', true, 'estado')</script>
                                  </td>
                                  <td style="width:1%">&#160;</td>
                               </tr>
                        </table>
                        <div id="divDetalle" style="width:100%;overflow:auto">
                            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
                                <xsl:apply-templates select="xml/rs:data/z:row" />
                            </table>
                        </div>
                        <!--<div id="div_pag" class="divPages" >
                            <script type="text/javascript">
                                 document.write(campos_head.paginas_getHTML())
                            </script>
                        </div>-->
               </body>
        </html>
    </xsl:template>
    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
         <xsl:choose>
           <xsl:when test='@estado = "Legajo Fisico"'>
           <td onClick="parent.alert('El archivo no esta digitalizado. Solo existe en forma fisica.')">  
                <xsl:value-of select="@Descripcion"/>
           </td>
           </xsl:when>
           <xsl:otherwise>
            <td>
              <xsl:choose>
                <xsl:when test="@f_nro_ubi != '' ">
              <a target="_blank">
                <xsl:attribute name='title'><xsl:value-of select="@Descripcion"/></xsl:attribute>
                <xsl:attribute name='href'>/fw/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="@path"/></xsl:attribute>
                <xsl:value-of select="@Descripcion"/>
              </a>
                </xsl:when>
                <xsl:otherwise>
                <xsl:attribute name='title'><xsl:value-of select="@Descripcion"/></xsl:attribute>
                <xsl:value-of select="@Descripcion"/>
                </xsl:otherwise>
              </xsl:choose>
            </td>
           </xsl:otherwise>
         </xsl:choose>
            <td style='width:20%;'>
              <xsl:attribute name='title'>
                <xsl:value-of select="foo:FechaToSTR(string(@momento))"/> - <xsl:value-of select="foo:HoraToSTR(string(@momento))"/>
              </xsl:attribute>
              <xsl:value-of select="foo:FechaToSTR(string(@momento))"/>
            </td>
            <td style='width:25%;'>
              <xsl:attribute name='title'><xsl:value-of select="@nombre_operador"/></xsl:attribute>
              <xsl:value-of select="@nombre_operador"/>
            </td>
          <td style='width:15%; color:green'>
            <xsl:choose>
              <xsl:when test="@estado = 'Activo'">
                <xsl:attribute name='style'>width:15%; color:green;font-weight:bold</xsl:attribute>
              </xsl:when>
              <xsl:when test="@estado = 'Anulado'">
                <xsl:attribute name='style'>width:15%; color:red</xsl:attribute>
              </xsl:when>
              <xsl:when test="@estado = 'Legajo Fisico'">
                <xsl:attribute name='style'>width:15%; color:grey</xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:value-of select="@estado"/>
          </td>
          <td style='width:1% !Important'><xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;</td>
        </tr>
      
    </xsl:template>
</xsl:stylesheet>