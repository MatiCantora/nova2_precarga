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
		<xsl:value-of select="string(@CCAPRET)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCANOMT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAAPET)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACUIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAFECNACT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAREGDEST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCATITCODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAINGT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACALT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCANUMT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPIST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCADTOT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACODPOST)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCALOCCODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPROCODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPAICODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCATIPTELT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCADDIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCADDNT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPRECELT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACART)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCANUMTELT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAFECORIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAMONORIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPLAORIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCATNAT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCASALCAPT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACANCUOPAGT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPROCUOT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@VENCIMIENTO_PROXIMA_CUOTA)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACAPCUOT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAINTCUOT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAOTRCUOT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAPATT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAMART)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAMODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>		
		<xsl:value-of select="string(@CCACODT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAVALAUTORIT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCAVALACTINFT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCaNomConT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCaApeConT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@CCACuiConT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@Anio)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@Ex)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>