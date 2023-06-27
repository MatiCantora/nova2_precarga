<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		function limpiar_cadena_domicilio(cade)
			  {
			  var cars = new Array()
			  cars[0] = {}
			  cars[0]['original'] = 'á'
			  cars[0]['reemplazo'] = 'a'
			  
			  cars[1] = {}
			  cars[1]['original'] = 'é'
			  cars[1]['reemplazo'] = 'e'
			  
			  cars[2] = {}
			  cars[2]['original'] = 'í'
			  cars[2]['reemplazo'] = 'i'
			  
			  cars[3] = {}
			  cars[3]['original'] = 'ó'
			  cars[3]['reemplazo'] = 'o'
			  
			  cars[4] = {}
			  cars[4]['original'] = 'ú'
			  cars[4]['reemplazo'] = 'u'
			  
			  cars[5] = {}
			  cars[5]['original'] = 'ñ'
			  cars[5]['reemplazo'] = 'n'
			  
			  cars[6] = {}
			  cars[6]['original'] = 'º'
			  cars[6]['reemplazo'] = ''
			  
			  cars[7] = {}
			  cars[7]['original'] = 'Á'
			  cars[7]['reemplazo'] = 'A'
			  
			  cars[8] = {}
			  cars[8]['original'] = 'É'
			  cars[8]['reemplazo'] = 'E'
			  
			  cars[9] = {}
			  cars[9]['original'] = 'Í'
			  cars[9]['reemplazo'] = 'I'
			  
			  cars[10] = {}
			  cars[10]['original'] = 'Ó'
			  cars[10]['reemplazo'] = 'O'
			  
			  cars[11] = {}
			  cars[11]['original'] = 'Ú'
			  cars[11]['reemplazo'] = 'U'
			  
			  cars[12] = {}
			  cars[12]['original'] = 'Ñ'
			  cars[12]['reemplazo'] = 'N'
			  
			  cars[13] = {}
			  cars[13]['original'] = 'ñ'
			  cars[13]['reemplazo'] = 'n'
			  
			  cars[14] = {}
			  cars[14]['original'] = 'à'
			  cars[14]['reemplazo'] = 'a'
			  
			  cars[15] = {}
			  cars[15]['original'] = 'À'
			  cars[15]['reemplazo'] = 'A'
			  
			  cars[16] = {}
			  cars[16]['original'] = 'È'
			  cars[16]['reemplazo'] = 'E'
			  
			  cars[17] = {}
			  cars[17]['original'] = 'è'
			  cars[17]['reemplazo'] = 'e'
			  
			  cars[18] = {}
			  cars[18]['original'] = 'ì'
			  cars[18]['reemplazo'] = 'i'
			  
			  cars[19] = {}
			  cars[19]['original'] = 'Ì'
			  cars[19]['reemplazo'] = 'I'
			  
			  cars[20] = {}
			  cars[20]['original'] = 'ò'
			  cars[20]['reemplazo'] = 'o'
			  
			  cars[21] = {}
			  cars[21]['original'] = 'Ò'
			  cars[21]['reemplazo'] = 'O'
			  
			  cars[22] = {}
			  cars[22]['original'] = 'ù'
			  cars[22]['reemplazo'] = 'u'
			  
			  cars[23] = {}
			  cars[23]['original'] = 'Ù'
			  cars[23]['reemplazo'] = 'U'
			  
			 
			  
			  var strreg = ""
			  var reg
			  for (var i = 0; i < 23; i++)
				{    
				reg = new RegExp(cars[i]['original'], 'g')
				cade = cade.replace(reg, cars[i]['reemplazo'])
				}
				
				//caracteres aceptados, de los cuales elimino los que no estan contemplados
				 /*ABCDEFGHIJKLMNÑOPQRSTUVWXYZÜË,'/0123456789Ä()*/
			  var re=/[^a-zA-Z0-9ÜËÄ()\s]/g
			  var result = cade.replace(re, "");
			  
			  var re = /([\ \t]+(?=[\ \t])|^\s+|\s+$)/g
			  var result = result.replace(re, "");			  
			  
			  return result
			  }
				  
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
		<xsl:value-of select="foo:limpiar_cadena_domicilio(string(@CCACALT))"/>
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
    <xsl:value-of select="string(@CCAVALCUOT)"/>
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