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
        <title>Definiciones de Archivos</title>
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
					                  var dif = Prototype.Browser.IE ? 5 : 2
					                  var body_height = $$('body')[0].getHeight()
					                  var tbCabe_height = $('tbCabe').getHeight()
					                  //var div_pag_height = $('div_pag').getHeight()
                                         
					                  $('divDetalle').setStyle({height: body_height - tbCabe_height - dif + 'px'})
                					     
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
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Pais Cod.', true, 'paiscod')</script>
            </td>
            <td style='text-align: center; width:8%'>
              <script>campos_head.agregar('Banco Cod.', true, 'bcocod')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Sis. Cod.', true, 'sistcod')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Sistema', true, 'sistema')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Subs. Cod.', true, 'codsubsist')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Mon. Cod.', true, 'moncod')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Suc. Cod.', true, 'succod')</script>
            </td>
            <td style='text-align: center; width:5%'>
              <script>campos_head.agregar('Cue. Cod.', true, 'cuecod')</script>
            </td>
            <td style='text-align: center; width:8%'>
              <script>campos_head.agregar('Nro. Oper.', true, 'openro')</script>
            </td>
            <td style='text-align: center; width:7%;'>
              <script>campos_head.agregar('Nro. Ref.', true, 'nroreferencia')</script>
            </td>
            <td style='text-align: center; width:7%'>
              <script>campos_head.agregar('Nro. Ext.', true, 'nroreferencia_externa')</script>
            </td>
            <td style='text-align: center; width:9%'>
              <script>campos_head.agregar('Ingreso', true, 'ingresos')</script>
            </td>
            <td style='text-align: center; width:9%'>
              <script>campos_head.agregar('RCI', true, 'rci')</script>
            </td>
            <td style='text-align: center; width:7%'>
              <script>campos_head.agregar('Organismo', true, 'organismo')</script>
            </td>
            <td style='text-align: center; width:10%;'>
              <script>campos_head.agregar('Administrador', true, 'nrodoc_admin')</script>
            </td>
            <td style="width:1% !important">&#160;</td>
          </tr>
        </table>
        <div id="divDetalle" style="width:100%;overflow:auto">
          <table class="tb1 highlightOdd highlightTROver layout_fixe" id="tbDetalle">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" class="divPages" >
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
      </body>
    </html>
    </xsl:template>
    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <xsl:variable name="nro_mov_tipo" select="@nro_mov_tipo"/>
      <tr>
        <!--<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            <xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>-->

        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@paiscod"/>
        </td>
        <td style='text-align: right;width:8%'>
          <xsl:value-of select="@bcocod"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@sistcod"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@sistema"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@codsubsist"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@moncod"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@succod"/>
        </td>
        <td style='text-align: right;width:5%'>
          <xsl:value-of select="@cuecod"/>
        </td>
        <td style='text-align:center; width:8%'>
          <xsl:value-of select="@openro"/>
        </td>
        <td style='text-align: right; width:7%'>
          <xsl:value-of select="@nroreferencia"/>
        </td>
        <td style='text-align: right; width:7%'>
          <xsl:value-of select="@nroreferencia_externa"/>
        </td>
        <td style='text-align: center;width:9%'>
          <xsl:choose>
            <xsl:when test='@ingresos != ""'>
              <xsl:value-of select="format-number(@ingresos, '#.00')"/>
            </xsl:when>
          </xsl:choose>
        </td>
        <td style='text-align: center; width:9%'>
          <xsl:choose>
            <xsl:when test='@ingresos != ""'>
              <xsl:value-of select="format-number(@rci, '#.00')"/>
            </xsl:when>
          </xsl:choose>          
        </td>
        <td style='text-align: center; width:7%'>
          <xsl:choose>
            <xsl:when test='@ingresos != ""'>
              <xsl:value-of select="@organismo"/>
            </xsl:when>
          </xsl:choose>
        </td>
        <td style='text-align: left; width:10%'>
          <xsl:value-of select="@nrodoc_admin"/>
        </td>
        <!--<td style='width:1% !Important'>
          <xsl:attribute name='id'>
            tdScroll<xsl:value-of select="$pos"/>
          </xsl:attribute>&#160;&#160;
        </td>-->
      </tr>
    </xsl:template>
</xsl:stylesheet>