<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
			function rellenar_izq(numero, largo, relleno)
			{
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			while(strNumero.length < largo)
			  strNumero = relleno + strNumero.toString() 
			return strNumero
			}
			
			function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
			
			function rellenar_der(numero, largo, relleno)
			{
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			  
			while(strNumero.length < largo)
			  strNumero = strNumero.toString() + relleno
			return strNumero
			}
			
			function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
			
			function formatoYYYYMMDD(fecha_sin_formato){
				var fecha = parseFecha(fecha_sin_formato)
				var fecha_retorno= fecha.getFullYear().toString()
				
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
	<xsl:template match="/xml/rs:data">
		<xsl:apply-templates select="z:row" />
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()"/>		
		<xsl:value-of select="string(@PrsCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelTipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelDDIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelDDNT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelPreCelT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelCarT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelNroT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelIntT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TelMarT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>