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
		<xsl:apply-templates select="xml/rs:data/z:row" />
		</xsl:template>
		
	<xsl:template match="z:row">
		<xsl:value-of select="foo:rellenar_izq(string(@cuit_cedente),11,'0')"/>
		<xsl:value-of select="foo:rellenar_der(string(@nro_prestamo),30,' ')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@cuota),4,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@fe_vigente),8,'0')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@fe_vencimiento),8,'0')"/>
		<xsl:value-of select="format-number(@capital * 100, '000000000000000')"/>
		<xsl:value-of select="format-number(@interes * 100, '000000000000000')"/>
		<xsl:value-of select="format-number(@gastos * 100, '000000000000000')"/>
		<xsl:value-of select="format-number(@IVA_interes * 100, '000000000000000')"/>
		<xsl:value-of select="format-number(@total * 100, '000000000000000')"/>
		<xsl:value-of select="foo:rellenar_izq(string(@plazo_cal_interes),4,'0')"/>
		<xsl:value-of select="format-number(@tasa_cuota * 100, '0000000')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>