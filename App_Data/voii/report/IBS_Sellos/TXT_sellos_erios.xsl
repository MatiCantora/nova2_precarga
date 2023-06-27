<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:decimal-format name="european" decimal-separator=',' grouping-separator='.' />

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
				
					var dif = valor - nro_entero
					if (dif > 0)
						return String(Math.floor((valor * 100)))
          else
          return String(nro_entero)
				}

		]]>
	  </msxsl:script>
	<xsl:output method="text" />

	<xsl:template match="/">
    <xsl:text>30546741636;6502;</xsl:text>
    <xsl:value-of select="/xml/rs:data/z:row/@anio"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="/xml/rs:data/z:row/@periodo"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="count(/xml/rs:data/z:row)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="format-number(sum(/xml/rs:data/z:row/@baseimponible),'0,00','european')"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="format-number(sum(/xml/rs:data/z:row/@imp_retenido),'0,00','european')"/>
    <xsl:text>&#xD;&#xA;</xsl:text>
    <xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>

	<xsl:template match="z:row">    
		<xsl:text>1912;</xsl:text>
		<xsl:value-of select="@openro"/>
		<xsl:text>;30546741636</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="@fecmov"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="format-number(@baseimponible,'0,00','european')"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="format-number(@alicuota,'0,00','european')"/>
    <xsl:text>;</xsl:text>
    <!--<xsl:value-of select="@importe_retencion"/>-->
    <xsl:value-of select="format-number(@imp_retenido,'0,00','european')"/>
    <xsl:text>;</xsl:text>
    <xsl:text>titular</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="@CUIT_CUIL"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>