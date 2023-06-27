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
				<script language="jscript" >
					function seleccionar(nro_tipo_pago)
					{
					window.parent.editarPago(nro_tipo_pago)
					}

				</script>	
					
			</head>
			<body>
				<form name="frm1" id="frm1">
				<table class="tb1" >
					<tr class="tbLabel">
						<xsl:apply-templates select="xml/s:Schema/s:ElementType/s:AttributeType" mode="titulo"/>
						<td>-</td>
					</tr>
					<xsl:apply-templates select="xml/rs:data/z:row" />
				
				</table>
				</form>	
			</body>
		</html>
	</xsl:template>
	<xsl:template match="s:AttributeType" mode="titulo">
		<td style="white-space: nowrap">
			<xsl:choose >
				<xsl:when test="@name = 'nro_pago_registro'">
					Nro. Pago Registro
				</xsl:when>				
				<xsl:when test="@name = 'strNombreCompleto'">
					Apellido y nombre
				</xsl:when>
				<xsl:when test="@name = 'razon_social'">
					Razón Social
				</xsl:when>
				<xsl:when test="@name = 'nro_credito'">
					Nº crédito
				</xsl:when>
				<xsl:when test="@name = 'importe_pago'">
					Importe pago
				</xsl:when>
				<xsl:when test="@name = 'pago_tipo'">
					Tipo de Pago
				</xsl:when>				
				<xsl:when test="@name = 'pago_concepto'">
					Concepto
				</xsl:when>			
				<xsl:otherwise>
					<xsl:value-of select="@name"/>
				</xsl:otherwise>
			
		</xsl:choose>
		</td>
	</xsl:template>
	<xsl:template match="z:row">
	  <tr>
		  <xsl:apply-templates  select="@*"/>
		  <td>
			  <input type='button' value='...'>
				  <xsl:attribute name='name'>
					  btn<xsl:value-of select="@nro_pago_registro"/>
				  </xsl:attribute>
				  <xsl:attribute name='onclick'>
					  return seleccionar(<xsl:value-of select="@nro_pago_registro"/>)
				  </xsl:attribute>
			  </input>
		  </td>
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
	<xsl:template match="@importe_pago">
		<xsl:variable name="tipo_dato" select="." />
		<td style="text-align: right">
			<xsl:value-of  select="format-number(.,'$  #0.00')" />
		</td>
	</xsl:template>
	<xsl:template match="@*">
		<xsl:variable name="tipo_dato" select="." />
		<td style="text-align: left">
			<xsl:value-of  select="." />
		</td>
	</xsl:template>
</xsl:stylesheet>