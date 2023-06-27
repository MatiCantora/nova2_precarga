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
			
				
			function decimaltasa(numero)
			{
			numero = parseFloat(numero)
			var nro_entero = Math.floor(numero)
			numero = numero - nro_entero
			var nro_dec = Math.round(numero * 10000)
		    if(nro_dec < 10)
			   nro_dec = "0" + nro_dec
			return nro_dec.toString()
			}	


    ]]>
  </msxsl:script>
	<xsl:output method="text" />

  <xsl:template match="/">
    <xsl:text>CUIT</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>Identificador de Crédito</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>Fecha de Alta</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Cuotas</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Capital</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Interes</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Valor Cuota</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Tasa</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>
  
	<xsl:template match="z:row">
	<xsl:value-of select="string(@CUIT)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@nro_prestamo)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="foo:formatoYYYYMMDD(string(@fe_alta))"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@cant_cuota)" />
	<xsl:text>;</xsl:text>
	<xsl:value-of select="foo:entero(sum(@capital_original))" />,<xsl:value-of select="foo:decimal(sum(@capital_original))" />
    <xsl:text>;</xsl:text>
	<xsl:value-of select="foo:entero(sum(@interes_original))" />,<xsl:value-of select="foo:decimal(sum(@interes_original))" />
    <xsl:text>;</xsl:text>
	<xsl:value-of select="foo:entero(sum(@valor_cuota))" />,<xsl:value-of select="foo:decimal(sum(@valor_cuota))" />
    <xsl:text>;</xsl:text>
	<xsl:value-of select="foo:entero(sum(@tasa))" />,<xsl:value-of select="foo:decimaltasa(sum(@tasa))" />
	<!--<xsl:value-of select="format-number(sum(@tasa), '###,######')" />-->
    <xsl:text>;</xsl:text>
	<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>