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
              
				
	
	
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<html onload="return window_onload()" >
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Instrucciones de pago</title>
				
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
				<script type="text/javascript" src="/FW/script/nvFW.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
				<script type="text/javascript">
					var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

					campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
					campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
					campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
					campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
					campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
					campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW;

					function window_onload(){
					window_onresize()

					}

					function window_onresize() {
					campos_head.resize('tbCabecera','tbDetalles');
						var alto_body = $$('BODY')[0].getHeight()
					var tableMain = $('tableMain').getHeight()
					var div_pag = $('div_pag').getHeight()
					var alto_div = alto_body - tableMain - div_pag
					$('rowContainer').style.height = alto_div + 'px'
					}

				</script>

			</head>

			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">

				<!-- TABLA DE CABECERAS - El true/false del campos_head.agregar indica si queremos que tenga ordenamiento o no -->
				<table id="tbCabecera" name="main"  class="tb1" style="width: 100%">
					<tr>
						<td class="Tit1"  style="Font-weight:bolder ,width:9% !important">
							<script>campos_head.agregar('Cab', true,'nro_cf_cab')</script>
						</td>
						<td class="Tit1"  style="Font-weight:bolder ,width9% !important">
							<script>campos_head.agregar('Nro CF', true,'nro_cf_ci')</script>
						</td>
						<td class="Tit1"  style="Font-weight:bolder ,width:9% !important">
							<script>campos_head.agregar('Benef.', true,'Benef')</script>
						</td>
						<td class="Tit1"  style="Font-weight:bolder ,width:9% !important">
							<script>campos_head.agregar('Importe', true,'importe')</script>
						</td>
						<td class="Tit1"  style="Font-weight:bolder ,width:9% !important">
							<script>campos_head.agregar('Credin', true,'id_credin')</script>
						</td>
						<td class="Tit1"  style="Font-weight:bolder ,width:9% !important">
							<script>campos_head.agregar('Estado', true,'estado_coelsa')</script>
						</td>
						
						
					</tr>
				</table>

				<div style="overflow: auto; height:90%">
					<!-- Esta parte hace que complete las filas con la xsl:template  match="z:row" que está acá, más abajo -->
					<div id="divRow" style="overflow:hidden;width:100%; overflow:hidden">
						<table id="tbDetalles" class="tb1 highlightTROver highlightOdd   layout_fixed" style="width: 100%; " >
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
						</div>


				<!-- DIV DE PAGINACION -->

				<div id="div_pag" class="divPages" style="bottom: 0px; height: 16px;">
					<script type="text/javascript">
						if (campos_head.PageCount > 1)
						document.write(campos_head.paginas_getHTML())
					</script>
				</div>

			</body>
		</html>
	</xsl:template>
	<xsl:template  match="z:row">

		<tr>
<xsl:choose>
				<xsl:when test='@estado_coelsa="ACREDITADO"'>
					<xsl:attribute name="style">background-color: #3DA5D9; color:white</xsl:attribute>
				</xsl:when>
				<xsl:when test='@estado_coelsa="ERROR ACREDITACION"'>
					<xsl:attribute name="style">background-color:#EA7317 ; color:white !important</xsl:attribute>
				</xsl:when>
				<xsl:when test='@estado_coelsa="EN CURSO"'>
					<xsl:attribute name="style">background-color: #2364AA; color:white</xsl:attribute>
				</xsl:when>
				
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>

				<xsl:value-of  select="@nro_cf_cab" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>

				<xsl:value-of  select="@nro_cf_ci" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width: 10%</xsl:attribute>-->
				<xsl:value-of  select="@Benef" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>

				<xsl:value-of  select="@importe" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>

				<xsl:value-of  select="@id_credin" />
			</td>
			<td>
				<xsl:value-of  select="@estado_coelsa" />
			</td>
	
			

		</tr>
	</xsl:template>
</xsl:stylesheet>


