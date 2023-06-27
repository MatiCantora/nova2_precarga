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
		<xsl:value-of select="string(@operacion)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsNroOpeT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsFanT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsTipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TiDCodTriT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsNroTriT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PaiCodNacT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@ActCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@IVACodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsResT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@SecCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsBanT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsNomT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsApeT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsNomLarT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsSexT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsFecNacT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsEstCivT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsPaiNacT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@NedCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@SlaCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TiDDocT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PsrNroDocT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TivCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsCanCarT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsTipVivT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@TsoCodT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EmpFec))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EmprFecUltAsam))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EmpFecIni))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EmpreOrga)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EmprFecInicAct))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EmprNroInscrip)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EmprObjSoc)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EmprEstPod)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsDomLegT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsCapSusT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EmprFecUltAum))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsDurT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsFecAfipT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsFecDDJJT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsPerDDJJT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsIngDDJJT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsCatMonT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsFecPagMonT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsPerPagMonT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@PrsActDesT)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplEmp)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplCuit)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplRam)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplCar)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplPro)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplIng)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplVar)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplCuoDes)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplAnt)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="string(@EplMonCod)"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:value-of select="foo:formatoYYYYMMDD(string(@EplFecIng))"/>
		<xsl:text><![CDATA[|]]></xsl:text>
		<xsl:text>&#xD;&#xA;</xsl:text>
	</xsl:template>
</xsl:stylesheet>