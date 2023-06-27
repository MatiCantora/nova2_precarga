<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />

  <xsl:output method="html" encoding="ISO-8859-1" omit-xml-declaration="yes" />

    <xsl:template match="/">
        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

            <title>Consultas</title>
            <!--#include virtual="../lavado/scripts/pvAccesoPagina.asp"-->
            <!--#include virtual="../../meridiano/scripts/pvUtiles.asp"-->
                      
            <!--<link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet"/>
            <link href="../../meridiano/css/btnSvr.css" type="text/css" rel="stylesheet" />
            <link href="../../meridiano/css/mnuSvr.css" type="text/css" rel="stylesheet" />
            <link href="../../meridiano/css/window_themes/default.css" rel="stylesheet" type="text/css" />
            <link href="../../meridiano/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />-->

            <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
            <link href="/FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
            <link href="/FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />
            <link href="/FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />
            <link href="/FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

            <script type="text/javascript" src="/FW/script/prototype.js"></script>
            <script type="text/javascript" src="/FW/script/window.js"></script>
            <script type="text/javascript" src="/FW/script/effects.js"></script>

            <script type="text/javascript" src="/FW/script/tXML.js" language="JavaScript"></script>
            <script type="text/javascript" src="/FW/script/nvFW.js" language="JavaScript"></script>
            <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
            <script type="text/javascript" src="/FW/script/tCampo_def.js" language="JavaScript"></script>
            <script type="text/javascript" src="/FW/script/utiles.js" language="JavaScript"></script>
            <script type="text/javascript" src="/FW/script/tSesion.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

            <script language="javascript" type="text/javascript">
              var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

              campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
              campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
              campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
              campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
              campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
              campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
              campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
              campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

              if (mantener_origen == '0')
              campos_head.nvFW = window.parent.nvFW

              /*
              var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                            
                campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                if (mantener_origen == '0')
                campos_head.nvFW = window.parent.nvFW
                */
            </script>
            <script type="text/javascript"  language="javascript" >
                <xsl:comment>
                    <![CDATA[ 
              
					    function window_onload() {
                window_onresize();
					    }
              
              //tcampo_head.js
              
              function window_onresize() {
              
                try
					      {
					        var dif = Prototype.Browser.IE ? 6 : 2
					        var body_height = $$('body')[0].getHeight()
					        var tbCabe_height = $('tbCabe').getHeight()
					        //var div_pag_height = $('div_pag').getHeight()
					        var div_pag_height = $('div_pag').getHeight()
                  
                                         
					        $('divDetalle').setStyle({height: body_height - (div_pag_height * 3.25) - tbCabe_height - dif + 'px'})
                					     
                  $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
					      }
					      catch(e){}
              
                //$('divDetalle').setStyle({  width: $('tbCabe').getWidth() })
                //$('divDetalle').setStyle({ height: $$('body')[0].getHeight() - $('tbCabe').getHeight() - $('div_pag').getHeight() });
                //campos_head.resize('tbCabe','tbDetalle');
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
                                    
              function seleccionar(indice)
		          {
		            $('tr_ver'+indice).addClassName('tr_cel')
		          }
                             
		          function no_seleccionar(indice)
		          {
		            $('tr_ver'+indice).removeClassName('tr_cel')
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
        <body onload="return window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:hidden;">

          <xsl:choose>
            <xsl:when test="count(xml/rs:data/z:row) = 0">
              <div style="width: 50%; margin: 20px auto; text-align: center;">
                <p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold; color: grey;">No se encontraron consultas</p>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <table width="100%" class="tb1" id="tbCabe">
                      <tr class="tbLabel">
                        <td style='text-align: center; width:7%'>
                            <script>campos_head.agregar('Nro. documento', true, 'nro_docu')</script>
                        </td>
                        <td style='text-align: center; width:20%'>
                            <script>campos_head.agregar('Raz. social', true, 'razon_social')</script>
                        </td>
                        <td style='text-align: center; width:22%'>
                            <script>campos_head.agregar('Banco', true, 'banco')</script>
                        </td>
                        <td style='text-align: center; width:22%'>
                            <script>campos_head.agregar('Mutual', true, 'mutual')</script>
                        </td>
                        <td style='text-align: center; width:6%'>
                            <script>campos_head.agregar('Estado', true, 'descripcion_estado')</script>
                        </td>
                        <td style='text-align: center; width:8%'>
                            <script>campos_head.agregar('Fecha', true, 'fecha')</script>
                        </td>
                        <td style='text-align: center; width:7%'>
                            <script>campos_head.agregar('Importe retirado', true, 'importe_retirado')</script>
                        </td>
                        <td style='text-align: center; width:7%'>
                            <script>campos_head.agregar('Importe solicitado', true, 'importe_solicitado')</script>
                        </td>
                        <td style="width:1%">&#160;</td>
                      </tr>
              </table>

              <!-- DIV DE PAGINACION -->
              <div id="divDetalle" style="width:100%;height: 100%;overflow:auto">
                <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
                  <xsl:apply-templates select="xml/rs:data/z:row" />
                </table>

              </div>
              
              <div id="div_pag" class="divPages"></div>
           
              <script type="text/javascript">

                if (campos_head.recordcount > campos_head.PageSize) {
                  $("div_pag").innerHTML = campos_head.paginas_getHTML()
                }
              </script>
              
            </xsl:otherwise>
          </xsl:choose>
      </body>
      </html>
    </xsl:template>
    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            <xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
          
            <td style='text-align: left; width:7%'>
              <xsl:value-of select="@nro_docu"/>
            </td>
            <td style='text-align: left; width:20%'>
              <xsl:value-of select="@razon_social"/>
            </td>
            <td style='text-align: left; width:22%'>
              <xsl:value-of select="@banco"/>
            </td>
            <td style='text-align: left; width:22%'>
              <xsl:value-of select="@mutual"/>
            </td>
            <td style='text-align: left; width:6%'>
              <xsl:value-of select="@descripcion_estado"/>
            </td>
            <td style='text-align: left; width:8%'>
              <xsl:value-of select="foo:FechaToSTR(string(@fecha))"/>
            </td>
            <td style='text-align: right; width:7%'>
              <xsl:value-of select="format-number(@importe_retirado, '#0.00')"/>
            </td>
            <td style='text-align: right; width:7%'>
              <xsl:value-of select="format-number(@importe_solicitado, '#0.00')"/>
            </td>
            
            <td style='width:1% !Important'><xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;</td>
        </tr>
    </xsl:template>
</xsl:stylesheet>