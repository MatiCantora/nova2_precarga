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
			if(fecha_sin_formato=='')
				{return ''
				}
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
		<xsl:value-of select="foo:rellanar_izq(string(@PrsCodT),12,'0')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),7,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),15,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),11,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),60,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),8,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),10,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),20,' ')" />
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@fecha))" />
		<xsl:value-of select="foo:rellanar_izq(string(@PrsCodT),4,'0')" />
		<xsl:value-of select="foo:rellanar_izq(string(@PrsCodT),1,'0')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),15,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),50,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),7,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),40,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),30,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),30,' ')" />
		<xsl:value-of select="foo:rellanar_der(string(@PrsCodT),8,' ')" />
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>