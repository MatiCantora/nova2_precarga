<?xml version="1.0" encoding="iso-8859-1"?>
<!--#include virtual="meridiano/scripts/pvAccesoPagina.asp"-->
<!--#include virtual="meridiano/scripts/pvUtiles.asp"-->
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
				<link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
				<script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
				<script type="text/javascript" language="javascript" src="/fw/script/nvFW_BasicControls.js"></script>
				<script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>
				<script type="text/javascript" language="jscript" >
					function seleccionar(nro_entidad,razon_social)
					{
					parent.AgregarEntidad(nro_entidad,razon_social)
					}
					
					function window_onresize()
					{
					try
					   {
					    body_height = $$('body')[0].getHeight()
					    titulo_height = $('tb_titulo').getHeight()
					    $('tb_body').setStyle({'height': body_height - titulo_height})
					   }
					catch(e){}
					}
				</script>	
					
			</head>
			<body onload="window_onresize()" onresize="window_onresize()"  style="width:100%; height: 100%; overflow: hidden">
				<table class="tb1" id="tb_titulo">
					<tr class="tbLabel">
						<td style="width:5%">-</td>
						<td style="width:15%">Nro. Entidad</td>
						<td style="width:30%">Documento</td>
						<td>Razón Social</td>
					</tr>
				</table>
				<div id="tb_body" style="width:100%;overflow:auto">
					<table class='tb1'>
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>	
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
	  <tr>
		  <td  style="width:5%">
				<a>
				   <xsl:attribute name="href">
				    javascript:seleccionar(<xsl:value-of select="@nro_entidad"/>,'<xsl:value-of select="@razon_social"/>')
				   </xsl:attribute>
				   <img src='/fw/image/icons/seleccionar.png' border='0' align='absmiddle' hspace='2'></img>
			   </a>
		  </td>
		  <td style='width:15%; text-align:right'>
			  <xsl:value-of  select="@nro_entidad" />
		  </td>
		  <td style='width:30%; text-align:right'>
			  <xsl:value-of  select="@documento" /> - <xsl:value-of  select="@nro_docu" />
		  </td>
		  <td style='text-align:left'>
			  <xsl:value-of  select="@razon_social" />
		  </td>
	  </tr>	  
	</xsl:template>
</xsl:stylesheet>