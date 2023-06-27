<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
<xsl:output method="text" encoding="iso-8859-1"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
	
	
      
		]]>	
	</msxsl:script>
<xsl:template match="/">
    <xsl:apply-templates select="/xml/rs:data/z:row" />
 </xsl:template>

<xsl:template match="z:row">    
    <xsl:value-of disable-output-escaping="yes" select="@apellido" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="@CUIT_CUIL" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="@nacion" />
    <xsl:text>&#xD;&#xA;</xsl:text>
</xsl:template>
</xsl:stylesheet>