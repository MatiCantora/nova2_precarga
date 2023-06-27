<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		var nro_ref_doc_tipo = -1
		var nro_ref_doc = -1
		
		var ref_ant = 0
		function get_ref_nueva(nro_ref)
		{
        if (ref_ant == nro_ref)
		      return false
		    else
		      {
		    ref_ant = nro_ref
		      return true
		    }
		}
    
		function grupo_tipo_cambio(nro_tipo_doc)
		{ 
		  if (nro_ref_doc_tipo != nro_tipo_doc)
		  {
		    nro_ref_doc_tipo = nro_tipo_doc
		    return true
		  }
		  else
		    return false
		}

    var primera_vez = true;
		function get_primera_vez()
    {
		  if(primera_vez)
      {
		    primera_vez = false;
		    return true;
		  }
		  return false;
		 }
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Referencia</title>
        <link href="/wiki/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" language="javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>

        <script type="text/javascript" language="javascript">
          <xsl:comment>
            
						var nro_ref = '<xsl:value-of select="xml/rs:data/z:row/@nro_ref"></xsl:value-of >'

						<![CDATA[
						
						function window_onresize()
            {
              if(nro_ref != '')
              {
                body_heigth = $$('body')[0].getHeight();
                //titulo_heigth = $('tb_titulo').getHeight() + $$('.ref_titulo.first')[0].getHeight();
                //var a = $('tb_body')
                //a.setStyle({'height': body_heigth - titulo_heigth})
						  }
            }
            
            function window_onload()
						{ 
              window_onresize()
						}
						  
						function imprimir()
						{
						  window.print()
 						}
						  
		
						]]>
					  </xsl:comment>
				  </script>
				<style>
					@media print
					  {
					  .noprint
					    {
						display: none
						}
					  }

				</style>
			</head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto">
				<xsl:apply-templates select="xml/rs:data/z:row" mode="tipo" />
			</body>
		  </html>
	  </xsl:template>

	  <xsl:template match="z:row" mode="tipo">
          <xsl:variable name="ref_nueva" select="foo:get_ref_nueva(number(@nro_ref))"></xsl:variable>
          <xsl:variable name="nro_ref_doc_tipo" select="@nro_ref_doc_tipo"/>
          <xsl:variable name="primer_vez" select="foo:get_primera_vez()"></xsl:variable>
         
          <xsl:if test="$ref_nueva">
              <div style="page-break-after: always;"></div>
              <table id="tb_titulo"  style="width: 100%; border: 0px;"  cellspacing="0" >
                  <tr class="ref_titulo">
                      <xsl:if test="$primer_vez">
                          <td nowrap="true">
                              <a class="noprint" style="font-family:Verdana; font-size:13px; font-weight:bold; color: #404040" >
                                  <xsl:attribute name="href">javascript:imprimir()</xsl:attribute>
                                  <img alt='Imprimir'  border='0' align='absmiddle' hspace='2' src="/fw/image/icons/imprimir.png"></img >
                                  Imprimir
                              </a>
                          </td>
                      </xsl:if>
                      <td  style="width: 100%">
                          <xsl:value-of select="@referencia"/>. <span class="ref_titulo_sub">
                              Ref <xsl:value-of select="@nro_ref"/>
                          </span>
                      </td>
                  </tr>
              </table>
          </xsl:if>
          <table class="tbDoc_cab" >
              <tr nowrap="true">
                  <td style="text-align:left vertical-align:middle" rowspan="2">
                      <h9>
                          <span class="ref_doc_titulo">
                              <xsl:value-of select="@ref_doc_titulo"/>
                          </span>
                      </h9>
                  </td>
              </tr>
          </table>
          <table style="width:100%">
              <tr nowrap="true">
                  <xsl:attribute name="id">trDocu<xsl:value-of select="@nro_ref_doc"/></xsl:attribute>
                  <td style='width:17px'></td>
                  <td style='vertical-align:top; margin:auto'>
                      <div>
                          <xsl:attribute name='id' >divDOC<xsl:value-of select='@id_ref_doc'/></xsl:attribute>
                      </div>
                      <script type="text/javascript" language="javascript">
                        <xsl:comment>
                          var id_ref_doc = '<xsl:value-of select='@id_ref_doc'/>'
                          var divID = 'divDOC' + id_ref_doc;
                          nvFW.insertFileInto(id_ref_doc, divID)
                        </xsl:comment>
                      </script>
                  </td>
              </tr>
          </table>
     </xsl:template>
</xsl:stylesheet>