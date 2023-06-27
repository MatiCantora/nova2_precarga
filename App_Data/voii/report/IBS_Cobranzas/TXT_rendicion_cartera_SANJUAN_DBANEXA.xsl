<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	
	<xsl:output method="text" />
	<xsl:template match="xml/rs:data/z:row">
		<xsl:text>00000</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_aut),7,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@importe)), '8', '0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:decimal(string(@importe)), '2', '0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>