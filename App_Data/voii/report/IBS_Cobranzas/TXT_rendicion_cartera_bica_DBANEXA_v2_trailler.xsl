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
		<xsl:text>Entidad;Autorizacion;FechaLiqu;CapitalLiqu;SaldoCap;MaxAtraso;PrimerVtoImpago</xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:apply-templates select="xml/rs:data/z:row" />
		<xsl:value-of select="foo:rellenar_izq('9',9,'9')"/>;<xsl:value-of select="foo:rellenar_izq(foo:valor_control((sum(/xml/rs:data/z:row[@saldocapital > 0]/@saldocapital) div count(/xml/rs:data/z:row[@saldocapital >= 0]))*7),8,'0')"/>;0;0;0;0;0</xsl:template>

	
	<xsl:template match="z:row">    
		<xsl:value-of select="foo:rellenar_izq(string(@cod_bica),9,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@nroreferencia),9,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:choose>
			<xsl:when test ="string(@fecliquidacion) = ''">
				<xsl:value-of select="foo:rellenar_izq(string(@fecliquidacion),8,'0')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="foo:rellenar_izq(foo:formatoDDMMYYYY(string(@fecliquidacion)),8,'0')"/>
			</xsl:otherwise> 
		</xsl:choose>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="format-number(@impliquidacion * 100, '00000000000')" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="format-number(@saldocapital * 100, '00000000000')" />
		<xsl:text>;</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@diasatraso),4,'0')"/>
		<xsl:text>;</xsl:text>
		<xsl:choose>
			<xsl:when test ="string(@privecimpago) = ''">
				<xsl:value-of select="foo:rellenar_izq(string(@privecimpago),8,'0')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="foo:rellenar_izq(foo:formatoDDMMYYYY(string(@privecimpago)),8,'0')"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>