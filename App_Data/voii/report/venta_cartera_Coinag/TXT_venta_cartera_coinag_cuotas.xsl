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
    <xsl:value-of select="count(/xml/rs:data/z:row/@nro_prestamo)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@capital))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@interes))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@interes))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(/xml/rs:data/z:row/@capital_saldo))"/>,<xsl:value-of select="foo:decimal(sum(/xml/rs:data/z:row/@capital_saldo))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template> 
    
	<xsl:template match="z:row">
    <xsl:value-of select="string(@detalle)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@CUIT)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_prestamo)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(@fe_vencimiento))"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@cuota)" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@capital))" />,<xsl:value-of select="foo:decimal(sum(@capital))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@interes))" />,<xsl:value-of select="foo:decimal(sum(@interes))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@comisiones))" />,<xsl:value-of select="foo:decimal(sum(@comisiones))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@IVA))" />,<xsl:value-of select="foo:decimal(sum(@IVA))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@otros_servicios))" />,<xsl:value-of select="foo:decimal(sum(@otros_servicios))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@otros_tributos))" />,<xsl:value-of select="foo:decimal(sum(@otros_tributos))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@importe_cuota))" />,<xsl:value-of select="foo:decimal(sum(@importe_cuota))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@capital_saldo))" />,<xsl:value-of select="foo:decimal(sum(@capital_saldo))" />
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@interes_saldo))" />,<xsl:value-of select="foo:decimal(sum(@interes_saldo))" />
    <xsl:text>;</xsl:text>
    <xsl:if test="string(@fecha_pago) != '' and string(@fecha_pago) != 'null'">
      <xsl:value-of select="foo:formatoYYYYMMDD(string(@fecha_pago))"/>
    </xsl:if >
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(sum(@total_cobrado))" />,<xsl:value-of select="foo:decimal(sum(@total_cobrado))" />
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>