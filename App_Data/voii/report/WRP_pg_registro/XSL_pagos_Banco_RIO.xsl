<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <msxsl:script language="javascript" implements-prefix="foo">
	    <![CDATA[
		function parseFecha(strFecha)
		{
		    var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
			a = a.substr(0, a.indexOf('.'))
			var fe = new Date(Date.parse(a))

			return fe
		}

		function formatoYYYYMMDD(fecha_sin_formato)
        {
		    var fecha = parseFecha(fecha_sin_formato)
			var fecha_retorno = fecha.getFullYear().toString()

			if (fecha.getMonth() < 9)
			    fecha_retorno += '0' + (fecha.getMonth() + 1)
			else
				fecha_retorno += (fecha.getMonth() + 1).toString()

			if (fecha.getDate().toString().length == 1)
			    fecha_retorno += '0' + fecha.getDate()
			else
			    fecha_retorno += fecha.getDate().toString()

			return fecha_retorno
		}
		]]>	
	</msxsl:script>

	<xsl:output method="text" />

    <xsl:template match="xml/rs:data">
		<!-- DETALLE DE LOS REGISTROS QUE COMPONEN EL ARCHIVO -->
		<xsl:apply-templates select="z:row" />
	</xsl:template>

	<xsl:template match="z:row">
		<xsl:apply-templates select="@*" />
		
		<!-- RELLENO CON ESPACIOS -->
		<!-- <xsl:text>                                                                                                                                                                                                                                                                                                                                                                                  </xsl:text> -->
		<xsl:value-of select="substring('                                                                                                                                                                                                                                                                                                                                                                                  ', 1, 370)" />
		
		<!-- RETORNO DE CARRO -->
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>

	<xsl:template match="@nro_pago_detalle">
		<xsl:value-of select="." /><xsl:value-of select="substring('               ', 1, 15 - string-length(string(.)))" />
	</xsl:template>

    <xsl:template match="@razon_social">
		<xsl:value-of select="." /><xsl:value-of select="substring('                              ', 1, 30 - string-length(string(.)))" />
	</xsl:template>

    <xsl:template match="@cuit">
		<xsl:value-of select="format-number(., '00000000000')" />
	</xsl:template>

    <xsl:template match="@cbu">
		<xsl:value-of select="." /><xsl:value-of select="substring('                      ', 1, 22 - string-length(string(.)))" />
	</xsl:template>

    <xsl:template match="@nro_liquidacion">
		<xsl:value-of select="format-number(., '000000000000000')" />
	</xsl:template>

    <xsl:template match="@fe_pago">
		<xsl:value-of select="foo:formatoYYYYMMDD(string(.))" />
	</xsl:template>

    <xsl:template match="@importe_pago">
		<!-- <xsl:variable name="importe_pg" select=". * 100" /> -->
		<xsl:value-of select="format-number(. * 100, '000000000000000')" />
	</xsl:template>

    <xsl:template match="@sucursal_rio">
		<xsl:value-of select="format-number(., '0000')" />
	</xsl:template>

    <xsl:template match="@tipo_cuenta_rio">
		<xsl:value-of select="format-number(., '0')" />
	</xsl:template>

    <xsl:template match="@numero_cuenta_rio">
		<xsl:value-of select="format-number(., '00000000')" />
	</xsl:template>
</xsl:stylesheet>