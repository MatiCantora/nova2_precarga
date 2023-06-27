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
    <xsl:text>1</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>30546741636</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(/xml/rs:data/z:row/@nro_operacion)"/>
    <xsl:text>;</xsl:text>
    <xsl:text>Banco VOII SA</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(count(/xml/rs:data/z:row/@nro_prestamo))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital_original))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@capital_original))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@interes_original))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@interes_original))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@saldo_capital))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@saldo_capital))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_liquidacion))"/>
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>
  
	<xsl:template match="z:row">
		<xsl:value-of select="string(@detalle)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@accion)"/>
		<xsl:text>;</xsl:text>
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
    <xsl:value-of select="foo:entero(sum(@importe_neto))" />,<xsl:value-of select="foo:decimal(sum(@importe_neto))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@tna))" />,<xsl:value-of select="foo:decimal(sum(@tna))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@tea))" />,<xsl:value-of select="foo:decimal(sum(@tea))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@saldo_capital))" />,<xsl:value-of select="foo:decimal(sum(@saldo_capital))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@saldo_interes))" />,<xsl:value-of select="foo:decimal(sum(@saldo_interes))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@moneda)" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@destino)" />
    <xsl:text>;</xsl:text>
    <xsl:if test="string(@ultimo_pago) != '' and string(@ultimo_pago) != 'null'">
      <xsl:value-of select="foo:formatoYYYYMMDD(string(@ultimo_pago))"/>
    </xsl:if>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@cuotas_a_vender)" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@entidad_descuento)" />
    <xsl:text>;</xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>