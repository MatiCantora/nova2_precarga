<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
			debugger
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}
		
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Generado con tienda-html.xsl</title>
				<link href="../css/base.css" type="text/css" rel="stylesheet"/>
			</head>
			<body>
				<table class="tb1" >
					<tr class="tbLabel">
						<td style='text-align: center'>Fila</td>
						<xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
					</tr>
					<xsl:apply-templates select="xml/rs:data/z:row" />
					<tr class="tbLabel0">
						<td  style="text-align: center">
							<xsl:value-of select="count(xml/rs:data/z:row)"/>
						</td>
						<xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="totales"/>
					</tr>
					
				</table>
				<table class="tb1">
					<xsl:variable name="importe_neto" select="sum(xml/rs:data/z:row/@importe_neto)"/>
					<xsl:variable name="importe_bruto" select="sum(xml/rs:data/z:row/@importe_bruto)"/>
					<xsl:variable name="importe_documentado" select="sum(xml/rs:data/z:row/@importe_documentado)"/>
					<xsl:variable name="importe_cuota" select="sum(xml/rs:data/z:row/@importe_cuota)"/>
					<xsl:if test="$importe_neto > 0">
						<tr>
							<td class="Tit1">Suma importe neto:</td>
							<td style="text-align: right">
								<xsl:value-of select="format-number($importe_neto,'0.00')"/>
							</td> 
						</tr>
					</xsl:if>
					<xsl:if test="$importe_bruto > 0">
						<tr>
							<td class="Tit1">Suma importe bruto:</td>
							<td style="text-align: right">
								<xsl:value-of select="format-number($importe_bruto,'0.00')"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="$importe_documentado > 0">
						<tr>
							<td class="Tit1">Suma importe documentado:</td>
							<td style="text-align: right">
								<xsl:value-of select="format-number($importe_documentado,'0.00')"/>
							</td>
						</tr>
					</xsl:if>
					<xsl:if test="$importe_cuota > 0">
						<tr>
							<td class="Tit1">Suma importe cuota:</td>
							<td style="text-align: right">
								<xsl:value-of select="format-number($importe_cuota,'0.00')"/>
							</td>
						</tr>
					</xsl:if>
					<tr >
						<td class="Tit1">Cantidad de registros:</td>
						<td style="text-align: right"	>
							<xsl:value-of select="count(xml/rs:data/z:row)"/>
						</td>
					</tr>
				</table>	
				
				
			</body>
		</html>
	</xsl:template>
	<xsl:template match="s:AttributeType" mode="titulo">
		<td style="white-space: nowrap">
			<xsl:choose >
				<xsl:when test="@name = 'strNombreCompleto'">
					Apellido y nombre
				</xsl:when>
				<xsl:when test="@name = 'strDomicilioCompleto'">
					Domicilio
				</xsl:when>
				<xsl:when test="@name = 'nro_credito'">
					Nº crédito
				</xsl:when>
				<xsl:when test="@name = 'importe_neto'">
					$ Neto
				</xsl:when>
				<xsl:when test="@name = 'importe_documentado'">
					$ Documentado
				</xsl:when>
				<xsl:when test="@name = 'importe_bruto'">
					$ Bruto
				</xsl:when>
				<xsl:when test="@name = 'importe_cuota'">
					$ Cuota
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@name"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	<xsl:template match="s:AttributeType" mode="totales">
		
			<xsl:choose >
				<xsl:when test="@name = 'importe_neto'">
					<td style="text-align: right">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_neto),'#.00')"/></td>
					</xsl:when>
				<xsl:when test="@name = 'importe_bruto'">
					<td style="text-align: right"><xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_bruto),'#.00')"/>
				</td>
				</xsl:when>
				<xsl:when test="@name = 'importe_cuota'">
					<td style="text-align: right">
						<xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_cuota),'#.00')"/>
				</td>
					</xsl:when>
				<xsl:when test="@name = 'importe_documentado'">
					<td style="text-align: right"><xsl:value-of select="format-number(sum(//xml/rs:data/z:row/@importe_documentado),'#.00')"/>
				</td>
				</xsl:when>
				<xsl:otherwise>
					<td>-</td>
				</xsl:otherwise>
			</xsl:choose>
		
	</xsl:template>
	<xsl:template match="z:row">
	  <tr>
		  <td  style='text-align: center'>
			  <xsl:value-of select="format-number(position(), '00000')"/>
		  </td>
		  <xsl:apply-templates  select="@*"/>
	  </tr>	  
	</xsl:template>
	<xsl:template match="@nro_credito">
		<xsl:variable name="nro_credito" select='.'/>
		<td style='text-align: center'>
			<a target="_blank">
				<xsl:attribute name="href">../MostrarCredito.asp?nro_credito=<xsl:value-of select="."/></xsl:attribute>
				<xsl:value-of  select="format-number(.,'0000000')" />
			</a>	
		</td>
	</xsl:template>
	<xsl:template match="@nro_docu">
		<td>
			<xsl:variable name="tipo_docu" select="../@tipo_docu"/>
            <a  target="_blank">
				<xsl:attribute name="href">../MostrarDatosPersona.asp?tipo_docu=<xsl:value-of select="../@tipo_docu"/>&amp;nro_docu=<xsl:value-of select="../@nro_docu"/>&amp;sexo=<xsl:value-of select="../@sexo"/></xsl:attribute>	
			<xsl:choose>
				<xsl:when test="$tipo_docu = 3">
					DNI
				</xsl:when>
				<xsl:when test="$tipo_docu = 2">
					LC
				</xsl:when>	
				<xsl:when test="$tipo_docu = 1">
					LE
				</xsl:when>	
				<xsl:when test="$tipo_docu = 4">
					CI
				</xsl:when>
				<xsl:when test="$tipo_docu = 5">
					PASS
				</xsl:when>
				<xsl:otherwise>
					Desconocido
				</xsl:otherwise>
			</xsl:choose>
			- <xsl:value-of  select="." />
			</a>	
		</td>
	</xsl:template>
	<xsl:template match="@strNombreCompleto">
		<td style="white-space: nowrap">
			<a  target="_blank">
				<xsl:attribute name="href">
					../MostrarDatosPersona.asp?tipo_docu=<xsl:value-of select="../@tipo_docu"/>&amp;nro_docu=<xsl:value-of select="../@nro_docu"/>&amp;sexo=<xsl:value-of select="../@sexo"/>
				</xsl:attribute>
				<xsl:value-of  select="." />
			</a>
		</td>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:variable name="tipo_dato" select="." />
		<td style="text-align: right">
			<xsl:value-of  select="." />
		</td>
	</xsl:template>
</xsl:stylesheet>