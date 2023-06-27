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

			function valor_control_old(valor)
			{
			 var suma=String(entero(valor)) + String(decimal(valor))
			 return suma
			}
			
			function valor_control(valor) 
			{
				valor = parseFloat(valor)
				var nro_entero = Math.floor(valor)
				
				dif = valor - nro_entero
				if (dif > 0)
					return String(Math.floor((valor * 100)))
				esle
				return String(nro_entero)
			}


    ]]>
  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
		<xsl:text>Identificador de Crédito</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Número de Cuota</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Fecha de Vencimiento</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Fecha de Cobro</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Capital</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Interes</xsl:text>
		<xsl:text>;</xsl:text>
		<xsl:text>Valor Cuota</xsl:text>
		<xsl:text>;</xsl:text>
        <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template> 
    
  <xsl:template match="z:row">
    <xsl:value-of select="string(@nro_prestamo)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_cuota)" />
	<xsl:text>;</xsl:text>
	<xsl:value-of select="foo:formatoYYYYMMDD(string(@fe_vencimiento))"/>
	<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@fecha_cobro)" />
	<xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@capital))" />,<xsl:value-of select="foo:decimal(sum(@capital))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@interes))" />,<xsl:value-of select="foo:decimal(sum(@interes))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@importe_cuota))" />,<xsl:value-of select="foo:decimal(sum(@importe_cuota))" />
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
  </xsl:template>
</xsl:stylesheet>