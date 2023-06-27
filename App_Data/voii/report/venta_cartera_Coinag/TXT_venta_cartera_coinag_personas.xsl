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
    <xsl:value-of select="count(/xml/rs:data/z:row[@nro_docu > 0])"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:formatoYYYYMMDD(string(/xml/rs:data/z:row/@fecha_novedades))"/>
    <xsl:text>;</xsl:text>
    <xsl:text>&#xD;&#xA;</xsl:text>
		<xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>
	
	<xsl:template match="z:row">
		<xsl:value-of select="string(@detalle)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@accion)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@tipo_persona)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@apellido)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nombres)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@CUIT)"/>
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@tipo_docu)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_docu)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@fecha_nacimiento)"/>
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@estado_civil)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@sexo)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nacionalidad)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@pais)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@lugar_nacimiento)"/>
    <xsl:text>;</xsl:text>
		<xsl:value-of select="string(@calle)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@numero)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@dompiso)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@domdepto)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@codigo_postal)"/>
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@cpa)"/>
    <xsl:text>;</xsl:text>
		<xsl:value-of select="string(@cartel)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@numtel)"/>
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@cartel_cel)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@numtel_cel)"/>
    <xsl:text>;</xsl:text>
		<xsl:value-of select="string(@mail)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@actividad)"/>
		<xsl:text>;</xsl:text>
		<xsl:value-of select="string(@actividad_rubro)"/>
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@actividad_subrubro)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="foo:entero(string(@ingresos))" />,<xsl:value-of select="foo:decimal(string(@ingresos))" />
		<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@apellido_conyugue)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nombres_conyugue)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_docu_conyugue)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@tipo_docu_conyugue)"/>
    <xsl:text>;</xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
    </xsl:template>
  
</xsl:stylesheet>