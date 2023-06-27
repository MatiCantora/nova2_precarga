<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
			
		

    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="foo:rellenar_izq(string(@cuit),13,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@razon_social),80,' ')"/>
    <xsl:value-of select="foo:rellenar_izq(string(@fecmov),8,' ')"/>
		<xsl:value-of select="foo:rellenar_der(string(@nat_acto),40,' ')"/>
    <xsl:value-of select="foo:rellenar_der(string(@destino),15,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@baseimponible),15,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@alicuiva),5,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@importe_retenido),15,'0')"/>
    <xsl:value-of select="foo:rellenar_der(string(@observacion),100,' ')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>