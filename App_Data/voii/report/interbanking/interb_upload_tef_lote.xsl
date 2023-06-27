<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
    <xsl:text>&#xD;&#xA;</xsl:text>
 </xsl:template>

<xsl:template match="z:row">    
    <xsl:value-of select="@linea" />
</xsl:template>
</xsl:stylesheet>