<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
			
			function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
			
			function formatoYYYYMMDD(fecha_date){	// recibe una cadena de fecha
				var fecha = parseFecha(fecha_date)
				var fecha_retorno= fecha.getFullYear().toString()
				
				if (fecha.getMonth() < 9)
					fecha_retorno += '0' + (fecha.getMonth() + 1).toString()
				else
					fecha_retorno += (fecha.getMonth() + 1).toString()
					
				if (fecha.getDate().toString().length == 1)
					fecha_retorno += '0' + fecha.getDate().toString()
				else
					fecha_retorno += fecha.getDate().toString()
				
				return fecha_retorno
			}
			
			function formatoDDMMYY(fecha_date){		// recibe una cadena de fecha
				var fecha = parseFecha(fecha_date)
				
				var cadena_fecha_dia = fecha.getDate().toString()
				if (cadena_fecha_dia.length == 1)
					cadena_fecha_dia = '0' + cadena_fecha_dia
				
				var cadena_fecha_mes = (fecha.getMonth() + 1).toString()
				if (cadena_fecha_mes.length == 1)
					cadena_fecha_mes = '0' + cadena_fecha_mes
					
				var cadena_fecha_anio = fecha.getFullYear().toString()
				if (cadena_fecha_anio.length == 4)
					cadena_fecha_anio = cadena_fecha_anio.substring(2)
				
				return cadena_fecha_dia + cadena_fecha_mes + cadena_fecha_anio
			}
			
			function fechaHoy(){					// retorna la fecha de hoy con el formato "YYYYMMDD"
				var fecha = new Date()
				var fecha_retorno= fecha.getFullYear().toString()
				
				if (fecha.getMonth() < 9)
					fecha_retorno += '0' + (fecha.getMonth() + 1).toString()
				else
					fecha_retorno += (fecha.getMonth() + 1).toString()
					
				if (fecha.getDate().toString().length == 1)
					fecha_retorno += '0' + fecha.getDate().toString()
				else
					fecha_retorno += fecha.getDate().toString()
				
				return fecha_retorno
			}
		
			function formatoDDMMYYYY(fecha_date){	// retorna una fecha tipo 'Date()' a una cadena de formato "dd/mm/yyyy"
				var fecha_retorno
				
				if (fecha.getDate().toString().length == 1)
					fecha_retorno = '0' + fecha.getDate() + '/'
				else
					fecha_retorno = fecha.getDate().toString() + '/'
					
				if (fecha.getMonth() < 9)
					fecha_retorno += '0' + (fecha.getMonth() + 1) + '/'
				else
					fecha_retorno += (fecha.getMonth() + 1).toString() + '/'
					
				fecha_retorno += fecha_date.getFullYear().toString()
				
				return fecha_retorno
			}
			
			function formatoMMDDYYYY(fecha){	// retorna una fecha tipo 'Date()' a una cadena de formato "mm/dd/yyyy"
				var fecha_retorno
							
				if (fecha.getMonth() < 9)
					fecha_retorno = '0' + (fecha.getMonth() + 1) + '/'
				else
					fecha_retorno = (fecha.getMonth() + 1).toString() + '/'
			
				if (fecha.getDate().toString().length == 1)
					fecha_retorno += '0' + fecha.getDate() + '/'
				else
					fecha_retorno += fecha.getDate().toString() + '/'
			
				fecha_retorno += fecha.getFullYear().toString()
				
				return fecha_retorno
			}
		
			function sumarDiasAFecha(fecha_orig, cantidad_dias){
				var fecha_date = parseFecha(fecha_orig)

				fecha_date.setDate(fecha_date.getDate() + parseInt(cantidad_dias))
				
				return formatoMMDDYYYY(fecha_date)
			}
			
			function reemplazarCaracterEnCadena(cadena, caracter, carac_reemplazo){		// reemplaza en "cadena" las ocurrencias de "caracter" por "carac_reemplazo"
							
				while (cadena.indexOf(caracter) != -1)
					cadena = cadena.replace(caracter, carac_reemplazo)
					
				return cadena
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
			
			function parte_entera(valor)
			{
			/*var cadena=valor.toString()						
			return cadena.substr(0,cadena.indexOf('.'))*/
			
			/*var suma=Number(valor)*/
			var suma=parseInt(valor)
			return suma
			/*return suma.toFixed();*/
			
			}
		]]>
	</msxsl:script>
	<xsl:output method="text" />
	<xsl:template match="/">
		<xsl:apply-templates select="xml/rs:data/z:row" />
	</xsl:template>
	<xsl:template match="xml/rs:data/z:row">
		<xsl:if test="@imputado > 0.01">	
		<xsl:comment>nro_credito</xsl:comment>
		<xsl:choose>
					<xsl:when test="@nro_mutual = 499 and count(@nro_side_autori) > 1">
						<xsl:value-of select="format-number(@nro_side_autori, '000000000')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="format-number(@nro_credito, '000000000')" />
					</xsl:otherwise>
		</xsl:choose>
		<xsl:comment>tipo de documento según nomenclatura BICA</xsl:comment>
		<xsl:choose>
			<xsl:when test="@tipo_docu = 3">
				<xsl:text>01</xsl:text>
			</xsl:when>
			<xsl:when test="@tipo_docu = 1">
				<xsl:text>02</xsl:text>
			</xsl:when>
			<xsl:when test="@tipo_docu = 2">
				<xsl:text>03</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>01</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:comment>nro_docu</xsl:comment>
		<xsl:value-of select="format-number(@nro_docu, '00000000000')" />
		<xsl:comment>fecha de descuento en formato 'ddmmyy'</xsl:comment>
		<xsl:value-of select="foo:formatoDDMMYY(string(@fe_descuento))" />
		<xsl:comment>pago imputado</xsl:comment>
		<xsl:value-of select="format-number(@imputado * 100, '00000000000')" />
		<xsl:comment>nro de cuota</xsl:comment>
		<xsl:value-of select="format-number(@nro_cuota, '000')" />
		<xsl:comment>saldo de cuota</xsl:comment>
			<xsl:choose>
				<xsl:when test="@saldo_cuota &lt; 0">
					<xsl:value-of select="format-number(0, '00000000000')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="format-number(@saldo_cuota * 100, '00000000000')" />
				</xsl:otherwise>
			</xsl:choose>		
		<xsl:text>&#xD;&#xA;</xsl:text>
		</xsl:if>
		<xsl:if test="position()=last()">
			<xsl:value-of select="foo:rellenar_izq(string(@NroAut),9,'0')"/><xsl:value-of select="foo:rellenar_izq(foo:parte_entera((sum(/xml/rs:data/z:row[@importe_control > 0]/@importe_control) div count(/xml/rs:data/z:row[@importe_control > 0]))*7),8,'0')"/><xsl:text>&#xD;&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>