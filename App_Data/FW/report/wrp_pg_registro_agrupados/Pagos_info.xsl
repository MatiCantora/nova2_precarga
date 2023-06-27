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

					function ordenar(campo)
					{
					window.parent.window_onload(campo)
					}

				</script>	
					
			</head>
			<body>
				<form name="frm1" id="frm1">
				<table class="tb1" >
					<tr class="tbLabel">
						<td style='text-align: center; width: 88px'>
							<a href='javascript:ordenar("envio");'>Envio</a>
						</td>
						<td style='text-align: center; width: 351px'>
							<a href='javascript:ordenar("razon_social");'>Razón Social</a>
						</td>
						<td style='text-align: center; width: 62px'>
							<a href='javascript:ordenar("nro_credito");'>Crédito</a>
						</td>
						<td style='text-align: center; width: 81px'>
							<a href='javascript:ordenar("importe_pago");'>Importe Pago</a>
						</td>
						<td style='text-align: center; width: 165px'>
							<a href='javascript:ordenar("pago_concepto");'>Concepto</a>
						</td>
						<td style='text-align: center; width: 12px'>
							<a href='javascript:ordenar("detalle");'>D</a>
						</td>
						<td style='text-align: center; width: 12px'>
							<a href='javascript:ordenar("contar");'>P</a>
						</td>
						<td style='text-align: center; width: 43px' nowrap='true'> - </td>
					</tr>									
				</table>
					<div style="width:100%; height:383px ;overflow-y:scroll;">
						<table class="tb1" >
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>	
				</form>	
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="conta_pendientes" select="@contar"/>
		<xsl:choose>
			<xsl:when test="$conta_pendientes > 0">
				<tr style='color:blue'>
					<td style='text-align: center; width: 88px'>
						<xsl:value-of  select="@envio" />
					</td>
					<td style='text-align: left; width: 351px'>
						<xsl:value-of  select="@razon_social" />
					</td>
					<td style='text-align: center; width: 62px'>
						<a target="_blank">
							<xsl:attribute name="href">
								../MostrarCredito.asp?nro_credito=<xsl:value-of select="@nro_credito"/>
							</xsl:attribute>
							<xsl:value-of  select="format-number(@nro_credito,'0000000')" />
						</a>
					</td>
					<td style='text-align: right; width: 81px'>
						<xsl:value-of  select="format-number(@importe_pago,'$  #0.00')" />
					</td>
					<td style='text-align: left; width: 165px'>
						<xsl:value-of  select="@pago_concepto" />
					</td>
					<td style='text-align: right; width: 12px'>
						<xsl:value-of  select="@detalle" />
					</td>
					<td style='text-align: right; width: 12px'>
						<xsl:value-of  select="@contar" />
					</td>
					<td style='text-align: center; width: 26px' nowrap='true'>
						<input type='button' value='...'>
							<xsl:attribute name='name'>
								btn<xsl:value-of select="@nro_pago_registro"/>
							</xsl:attribute>
							<xsl:attribute name='onclick'>
								return seleccionar(<xsl:value-of select="@nro_pago_registro"/>)
							</xsl:attribute>
						</input>
						<input type='hidden'>
							<xsl:attribute name='name'>
								<xsl:value-of select="position()"/>
							</xsl:attribute>
							<xsl:attribute name='value'>
								<xsl:value-of select="@nro_credito"/>
							</xsl:attribute>
						</input>
					</td>
				</tr>
			</xsl:when>
			<xsl:otherwise>
		<tr>
		  <td style='text-align: center; width: 88px'>
			  <xsl:value-of  select="@envio" />
		  </td>
		  <td style='text-align: left; width: 351px'>
			  <xsl:value-of  select="@razon_social" />
		  </td>
		  <td style='text-align: center; width: 62px'>
			  <a target="_blank">
				  <xsl:attribute name="href">
					  ../MostrarCredito.asp?nro_credito=<xsl:value-of select="@nro_credito"/>
				  </xsl:attribute>
				  <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
			  </a>
		  </td>
		  <td style='text-align: right; width: 81px'>
			  <xsl:value-of  select="format-number(@importe_pago,'$  #0.00')" />
		  </td>
		  <td style='text-align: left; width: 165px'>
			  <xsl:value-of  select="@pago_concepto" />
		  </td>
		  <td style='text-align: right; width: 12px'>
			  <xsl:value-of  select="@detalle" />
		  </td>
		  <td style='text-align: right; width: 12px'>
			  <xsl:value-of  select="@contar" />
		  </td>
		  <td style='text-align: center; width: 26px' nowrap='true'>
			  <input type='button' value='...'>
				  <xsl:attribute name='name'>
					  btn<xsl:value-of select="@nro_pago_registro"/>
				  </xsl:attribute>
				  <xsl:attribute name='onclick'>
					  return seleccionar(<xsl:value-of select="@nro_pago_registro"/>)
				  </xsl:attribute>
			  </input>
			  <input type='hidden'>
				  <xsl:attribute name='name'>
					  <xsl:value-of select="position()"/>
				  </xsl:attribute>
				  <xsl:attribute name='value'>
					  <xsl:value-of select="@nro_credito"/>
				  </xsl:attribute>
			  </input>			  
		  </td>
	  </tr>
			</xsl:otherwise>
		</xsl:choose>
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
		<td style="text-align: left">
			<xsl:value-of  select="." />
		</td>
	</xsl:template>
</xsl:stylesheet>