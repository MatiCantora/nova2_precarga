<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
			
		

    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
    <xsl:text>Sistema</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Cod_Cuenta</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Fecha_Mov</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Fecha_Proc</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Fecha</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Cod_Movimiento</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Descripcion</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Nro_Cbte</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Tipo_Funcion</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Funcion</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Importe</xsl:text>
    <xsl:text>&#x9;</xsl:text>
    <xsl:text>Men_Movimiento</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
  <xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="string(@Sistema)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Moneda)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="foo:FechaToSTR(string(@Fecha_Mov))"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="foo:FechaToSTR(string(@Fecha_Proc))"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="foo:FechaToSTR(string(@Fecha_Real))"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Cod_Movimiento)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Descripcion)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Nro_Cbte)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Tipo_Funcion)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Funcion)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Absoluto)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Importe)"/>
    <xsl:text>&#x9;</xsl:text>
    <xsl:value-of select="string(@Men_Movimiento)"/>
    <xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
</xsl:stylesheet>