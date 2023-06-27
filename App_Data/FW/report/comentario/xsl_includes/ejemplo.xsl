<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[	
		
			
			function calc_importe_cuota(rec_importe, max_importe)
			  {
			  rec_importe = Math.floor(parseFloat(rec_importe))
			  max_importe = Math.floor(parseFloat(max_importe * 100))
			  if (rec_importe > max_importe)
			    return max_importe
			  else 	
			    return rec_importe
			  }
			  
			function calc_cuotas(rec_importe, max_importe)
			  {
			  rec_importe = Math.floor(parseFloat(rec_importe))
			  max_importe = Math.floor(parseFloat(max_importe * 100))
			  var cuotas = Math.floor(rec_importe / max_importe)
			  if (cuotas <= 1) cuotas = 1
			  return cuotas
			  }  
			  
			function calc_resto(rec_importe, max_importe)
			  {
			  rec_importe = Math.floor(parseFloat(rec_importe))
			  max_importe = Math.floor(parseFloat(max_importe * 100))
			  if (rec_importe > max_importe)
			    {
				return Math.floor(rec_importe % max_importe)
				}
			  else
			    return 0
			  }  
			  
			
		]]>
	</msxsl:script>
	<xsl:output method="text" />
	<xsl:template match="/">
		<xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>
	<xsl:template match="xml/rs:data/z:row">		
		<xsl:text>072</xsl:text><!--Asociacion-->
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_lote)), '2', '0')"/><!--Jurisdicción-->
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_docu)), '8', '0')"/>
		<xsl:text>1</xsl:text><!--Tipo concepto-->
		<xsl:text>3</xsl:text><!--Tipo docu-->
		<xsl:value-of select="foo:rellenar_izq(foo:calc_importe_cuota(string(@rec_importe), string(@max_importe)), '9', '0')"/><!--Importe-->
		<xsl:value-of select="@fecha_vencimiento"/><!--Primer vencimiento-->
		<xsl:text>000</xsl:text><!--cod_concepto-->
		<xsl:text>00000</xsl:text><!--cod_proveedor-->
		<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_comprobante)), '11', '0')"/><xsl:text>A</xsl:text><!--nro_comprobante-->
		<xsl:text>001</xsl:text><!--nro_cuota-->
		<xsl:value-of select="foo:rellenar_izq(foo:calc_cuotas(string(@rec_importe), string(@max_importe)), '3', '0')"/><!--cuotas-->
		<xsl:value-of select="foo:rellenar_der(string(@descripcion), '20', ' ')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:if test="foo:calc_resto(string(@rec_importe), string(@max_importe)) > 0">
			<xsl:text>072</xsl:text><!--Asociacion-->
			<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_lote)), '2', '0')"/><!--Jurisdicción-->
			<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_docu)), '8', '0')"/>
			<xsl:text>1</xsl:text><!--Tipo concepto-->
			<xsl:text>3</xsl:text><!--Tipo docu-->
			<xsl:value-of select="foo:rellenar_izq(foo:calc_resto(string(@rec_importe), string(@max_importe)), '9', '0')"/><!--Importe-->
			<xsl:value-of select="@fecha_vencimiento"/><!--Primer vencimiento-->
			<xsl:text>000</xsl:text><!--cod_concepto-->
			<xsl:text>00000</xsl:text><!--cod_proveedor-->
			<xsl:value-of select="foo:rellenar_izq(foo:entero(string(@nro_comprobante)), '11', '0')"/><xsl:text>B</xsl:text><!--nro_comprobante-->
			<xsl:text>001</xsl:text><!--nro_cuota-->
			<xsl:text>001</xsl:text><!--cuotas-->
			<xsl:value-of select="foo:rellenar_der(string(@descripcion), '20', ' ')"/>
			<xsl:text>&#xD;&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>