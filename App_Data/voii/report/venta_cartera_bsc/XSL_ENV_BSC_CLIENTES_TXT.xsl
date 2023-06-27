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
		<xsl:value-of select="foo:rellenar_der(string(@apellido),15,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@nombres),30,' ')" />
		<xsl:value-of select="foo:rellenar_izq(string(@sucursal),3,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@estado_civil),1,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@sexo),1,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@fecha_nacimiento),6,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_docu),2,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')" />
		<xsl:value-of select="foo:rellenar_der(string(@apellido_nombres_conyugue),30,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@fecha_nacimiento_conyugue),6,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@calle),30,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@numero),5,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@piso_dpto),10,' ')" />
		<xsl:value-of select="foo:rellenar_der(string(@localidad),20,' ')" />
		<xsl:value-of select="foo:rellenar_izq(string(@codigo_postal),5,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@cod_provincia),2,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@telefono),15,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@CUIT),13,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@nacionalidad),3,'0')" />
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_cuenta),1,'0')" />
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>