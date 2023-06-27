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
		<xsl:value-of select="string(@CCCNegT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TPDcls)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCNroT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCSucT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCMonCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTitCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCoTit1T)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCoTit2T)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCapCedT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCIntCedT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCFecIniT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCDscT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCodDesT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCFecDesT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCMonOrgT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCMonDesT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCMonFinT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCPlaT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasOriT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCDivT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTipTasT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCSprT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasPisT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasTecT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasActT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCAprHipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCAcuHipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCEscHipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCInsHipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCNivAtrT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCNLCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCBUT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCProCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTipCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCCodDesC)"/>
		<xsl:text><![CDATA[|]]></xsl:text>		
		<xsl:value-of select="string(@CCCNroANST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTrnANST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCComANST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCDiaVenT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTNAT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasPunT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTasComT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCPorSegVT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCCTitCodExtT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>