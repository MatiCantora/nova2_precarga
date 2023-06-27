<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
<xsl:output method="text" />
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

			
			function rellenar_der(numero, largo, relleno)
			{
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			  
			while(strNumero.length < largo)
			  strNumero = strNumero.toString() + relleno
			return strNumero
			}
		]]>	
	</msxsl:script>
	<xsl:template match="/">
        <xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>

	<xsl:template match="z:row">
		<xsl:value-of select="@tipo_docu" />
        <xsl:value-of select="foo:rellenar_izq(string(@nro_docu), 11, '0')" />
        <xsl:value-of select="foo:rellenar_izq('', 11, '0')" />
        <xsl:value-of select="foo:rellenar_der(string(@strNombreCompleto), 40, ' ')" />
        <xsl:value-of select="foo:rellenar_izq(string(@importe_cuota100), 10, '0')" />
        <xsl:value-of select="foo:rellenar_izq(string(@importe_pago100), 10, '0')" />
        <xsl:value-of select="foo:rellenar_izq(string(@clave_banco), 12, ' ')" />
        
        <xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>