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
			    if(fecha_sin_formato=='' || fecha_sin_formato == ' ')
				  return ''
			
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
		<xsl:value-of select="string(@CUCNegT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCNroT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCNroT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCAmoT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIntComT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCFecVenT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCTipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCFecPagT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCFecIngT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCSalCapT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCTasActT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCSalDeuT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCSegVidT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCSegIncT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCImpSegT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCAraCanT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIvaAraT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCInt0T)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCCarIniT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCDevIniT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCCarIniT1)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCDevIniT1)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCGasSinT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCImpSelT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCFonGarT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCGasLiqT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIVALiqT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIVASIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCGasIncT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIVAGSIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIVASIT1)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCComAdmT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCIVAComAT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCImpProT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCBonT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CUCBalT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>		
		<xsl:value-of select="string(@CUCCedT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>