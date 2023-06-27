<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
	  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl" />
	  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_campo_def.xsl" />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    

    <xsl:template match="/">
        <html>
                    <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                    <title></title>
                    <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
                    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
                    <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
				            <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
				            <script type="text/javascript" src="/precarga/script/tCampo_head.js" language="JavaScript"></script>

                    <script type="text/javascript" language="javascript">
                      campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
					            var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
					            campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
					            campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
					            campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					            campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
					            campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
					            campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					            campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'
					            if (mantener_origen == '0')
					              campos_head.nvFW = window.parent.nvFW
                    </script>
                        <script type="text/javascript" language="javascript" >
                            <xsl:comment>
                                <![CDATA[ 
                                function selVendedor(nro_vendedor, vendedor, cod_prov,provincia,postal_real,nro_estructura)
                                {
                                    parent.selVendedor(nro_vendedor, vendedor, cod_prov,provincia,postal_real,nro_estructura)
                                }                        
                                
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
                                    
					                          $('div_lst_vendedor').setStyle({height: body_height - tbCabe_height - dif -34 + 'px'})            					     
                              
                                    $('tbDetalle').getHeight() - $('div_lst_vendedor').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
					                          }
					                       catch(e){}
					                     }    
                        
                              ]]>
                            </xsl:comment>
                        </script>
                    </head>
                    <body onload="window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:auto;position:relative">
                        
                                    <table width="100%" class="tb1" id="tbCabe">
                                        <tr class="tbLabel">
                                            <td style='text-align: center; width:6%' nowrap='true'>-</td>
                                            <td style='text-align: center; width:60%' nowrap='true'>
                                                <script type="text/javascript">
                                                    campos_head.agregar('Vendedor', true, 'vendedor')
                                                </script>
                                            </td>
											                      <td style='text-align: center; width:34%'>
                                                <script type="text/javascript">
                                                    campos_head.agregar('Estructura', true, 'estructura')
                                                </script>
                                            </td>											
                                        </tr>
                                    </table>
                        <div style="width:100%;height:100%;overflow:auto;position:relative" id="div_lst_vendedor" >
                        <table class="tb1 highlightEven highlightTROver" width="100%" id="tbDetalle">
                          <xsl:apply-templates select="xml/rs:data/z:row" />
                        </table>
                      </div>
                            <div id="tbPages">
                            <script type="text/javascript">
                              document.write(campos_head.paginas_precarga_getHTML())
                            </script>                            
                            </div>                      
                    </body>
            
        </html>
    </xsl:template>
    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
          <xsl:attribute name="onclick">selVendedor('<xsl:value-of select='@nro_vendedor'/>','<xsl:value-of select='@vendedor'/>','<xsl:value-of select='@cod_prov'/>','<xsl:value-of select='@provincia'/>','<xsl:value-of select='@postal_real'/>','<xsl:value-of select='@nro_estructura'/>')</xsl:attribute>
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            <td style='text-align: center; width:6%' nowrap='true'>
                <img title="Seleccionar Vendedor" src="../../precarga/image/ok.png" class="" style="cursor:pointer"></img>
            </td>
            <td style='text-align: left; width:60%'>
				        <b><xsl:value-of select="@vendedor"/></b>
            </td>
            <td style='text-align: left; width:34%'>
                <xsl:value-of select="@estructura"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>