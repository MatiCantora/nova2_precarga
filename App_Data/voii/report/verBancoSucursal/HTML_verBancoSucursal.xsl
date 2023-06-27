<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:include href="..\..\..\voii\report\xsl_includes\js_formato.xsl"/>
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Seleccionar Sucursal</title>
				<link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>
				<script>
					<![CDATA[
					
						function Seleccion(id_banco_sucursal)
						{
						window.parent.Seleccion(id_banco_sucursal)
						}
					]]>
				</script>
			</head>
			<body>
				<table class="tb1" >
					<tr class="tbLabel">
						<td style='width:22px'>-</td>
						<td style='width:62px'>Código</td>
						<td style='width:62px'>Cód.CBU</td>
						<td nowrap='true'>Sucursal</td>
					</tr>
				</table>
				<div id="div_personas"  style="width:100%; height:113px; overflow-y:scroll;">
					<table class="tb1" >
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
	  <tr>
		  <td  style='text-align: center; width:20px'>
			  <input type='button' value='+' style='width:100%'>
				  <xsl:attribute name='onclick'>
					  Seleccion(<xsl:value-of select='@id_banco_sucursal'/>)
				  </xsl:attribute>
			  </input>
		  </td>
		  <td style='width:60px'>
			  <xsl:value-of select='@cod_sucursal'/>
		  </td>
		  <td style='width:60px'>
			  <xsl:value-of select='@cod_cbu'/>
		  </td>
		  <td nowrap='true'>
			  <xsl:value-of select='@Banco_sucursal'/>
		  </td>
	  </tr>	  
	</xsl:template>
</xsl:stylesheet>