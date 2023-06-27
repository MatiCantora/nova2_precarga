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
    </msxsl:script>

    <xsl:template match="/">
      <html>
        <head>
          <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        </head>
        <body style="width:100%;height:100%;overflow:auto">
          <xsl:apply-templates select="xml/rs:data/z:row" />
        </body>
      </html>
    </xsl:template>

  <xsl:template match="z:row">
        <table style="width:100%" class="tb1">
            <tr>
                <td style="text-align:left;width:100%;padding: 1px 3px;">
                  <a>
                     <xsl:attribute name="id">link_<xsl:value-of select="@nro_com_grupo"/></xsl:attribute>
                     <xsl:attribute name="href">javascript:parent.Mostrar_Registro_grupo(<xsl:value-of select="@nro_com_grupo"/>,'<xsl:value-of select="@com_grupo"/>')</xsl:attribute>
                     <xsl:value-of select="@com_grupo"/>
                  </a>
                </td>
            </tr>
        </table>
    </xsl:template>

</xsl:stylesheet>