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
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_mov),1,'0')"/>
    <xsl:text>*~*</xsl:text>
		<xsl:value-of select="foo:rellenar_izq(string(@tipo_docu),2,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_docu),11,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@apellido),25,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@nombres),25,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@calle),25,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@numero),5,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@block),5,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@piso),5,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@depto),5,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@barrio),20,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@manzana),10,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@lote_casa),10,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@localidad),15,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@codigo_postal),4,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@car_tel),5,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@telefono),12,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@fecha_nacimiento),8,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@tipo_persona),1,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@sexo),1,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_legajo),12,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@condicion_iva),1,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_sucursal),2,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_cuenta),8,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_secretaria),3,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_reparticion),9,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nro_prov),2,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@cpa),8,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_der(string(@email),90,' ')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@estado_civil),30,'0')"/>
    <xsl:text>*~*</xsl:text>
    <xsl:value-of select="foo:rellenar_izq(string(@nacionalidad),30,'0')"/>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>