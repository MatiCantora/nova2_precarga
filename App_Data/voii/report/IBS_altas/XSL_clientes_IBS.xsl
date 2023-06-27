<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
<xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
			
			
			function completarNoObligatorio(valor)
			{
				if(valor=='')
				{
				return 0
				}else
				{
				return valor;
				}
			}
		
		]]>
	</msxsl:script>
	<xsl:output method="text" />
	<xsl:template match="/xml/rs:data">
		<xsl:apply-templates select="z:row" />
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:value-of select="foo:completarNoObligatorio(string(@Tipmov))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Tipdoc))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nrodoc))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Tipdoc2))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nrodoc2))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@apellido)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@nombres)"/>		
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nacionalidad))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Provincia))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Lugnac))"/>		
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@estado_civil))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Pep)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@calle)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nro_calle))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Block))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Piso))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Dpto))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Barrio))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Manzana))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Lote))"/>
		<xsl:value-of select="string(@separador)"/>		
		<xsl:value-of select="string(@localidad)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:rellenar_izq(string(@Cod_Postal),4,'0')"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Cpa)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Diremail)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Tel_carac))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:rellenar_der(string(@Tel_nro),12,' ')"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@fecnacim)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@tipopersona))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Sexo)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@nrolegajo)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Condiciva)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Actcod))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nrosuc))"/>
		<xsl:value-of select="string(@separador)"/>				
		<xsl:value-of select="foo:completarNoObligatorio(string(@Nrocta))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@nrosecretar))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@Nrorepartic)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="foo:completarNoObligatorio(string(@Provincia))"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@alta_cuenta)"/>
		<xsl:value-of select="string(@separador)"/>
		<xsl:value-of select="string(@perfil_operativo)"/>	
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>