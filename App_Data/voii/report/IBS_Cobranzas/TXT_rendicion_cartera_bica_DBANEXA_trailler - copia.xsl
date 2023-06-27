<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
			
			function parte_entera(valor)
			{
			var suma=parseInt(valor)
			return suma
			}

    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:apply-templates select="xml/rs:data/z:row" />
		<xsl:value-of select="foo:rellenar_izq('9',9,'9')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:parte_entera((sum(/xml/rs:data/z:row[@importe > 0]/@importe) div count(/xml/rs:data/z:row[@importe > 0]))*7),8,'0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="foo:rellenar_izq(string(@nro_aut),9,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_doc),2,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:formatoDDMMYY(string(@fe_cobro)),6,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@importe)), '9', '0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:decimal(string(@importe)), '2', '0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@nro_cuota),3,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@remanente)), '9', '0')"/>
		<xsl:value-of select="foo:rellenar_izq(foo:decimal(string(@remanente)), '2', '0')"/>
        <xsl:value-of select="foo:rellenar_izq(string(@cod_bica), '6', '0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>