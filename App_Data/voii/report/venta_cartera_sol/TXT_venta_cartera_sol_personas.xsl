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
    <xsl:text>CUIT</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>Apellido</xsl:text>
    <xsl:text>;</xsl:text>
    <xsl:text>Nombre</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Sexo</xsl:text>
	<xsl:text>;</xsl:text>
    <xsl:text>Tipo De Documento</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Número De Documento</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Calle</xsl:text>
    <xsl:text>;</xsl:text>
	<xsl:text>Número</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Piso</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Departamento</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Localidad</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Provincia</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Código Postal Extendido</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Prefijo Particular</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Teléfono Particular</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Prefijo Laboral</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Teléfono Laboral</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Prefijo Celular</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Teléfono Celular</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Nacionalidad</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Fecha de Nacimiento</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Fecha de Ingreso</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Ingresos</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Estado Civil</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>EMail</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>Legajo</xsl:text>
	<xsl:text>;</xsl:text>
	<xsl:text>&#xD;&#xA;</xsl:text>
	<xsl:apply-templates select="xml/rs:data/z:row" />
  </xsl:template>
	
	<xsl:template match="z:row">
	<xsl:value-of select="string(@CUIT)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@apellido)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nombres)"/>
	<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@sexo)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@tipo_docu)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="string(@nro_docu)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@calle)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@numero)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@piso)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@depto)"/>
	<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@localidad)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@provincia)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@cpa)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@cartel)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@numtel)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@cartel_lab)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@numtel_lab)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@cartel_cel)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@numtel_cel)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@nacionalidad)"/>
	<xsl:text>;</xsl:text>
    <xsl:value-of select="string(@fecha_nacimiento)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@fecha_ingreso)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="foo:entero(string(@ingresos))" />,<xsl:value-of select="foo:decimal(string(@ingresos))" />
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@estado_civil)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@mail)"/>
	<xsl:text>;</xsl:text>
	<xsl:value-of select="string(@legajo)"/>
	<xsl:text>;</xsl:text>
	<xsl:text>&#xD;&#xA;</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>

