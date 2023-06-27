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
				<title>Jugadores</title>
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

					}

				</script>

			</head>

			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">

				<!-- TABLA DE CABECERAS - El true/false del campos_head.agregar indica si queremos que tenga ordenamiento o no -->
				<table id="tbCabecera" name="main"  class="tb1" style="width: 100%">
					<tr>
						<td class="Tit1"  style="width:15% !important">
							<script>campos_head.agregar('Identificador', true,'identificador')</script>
						</td>
						<td  class="Tit1" style="width:5% !important">
							<script>campos_head.agregar('Canal', true , 'type')</script>
						</td>
						<td  class="Tit1" style="width:25% !important">
							<script>campos_head.agregar('Contenido', true , 'body')</script>
						</td>
						<td class="Tit1" style="width:10% !important">
							<script>campos_head.agregar('Asunto', true,'subject')</script>
						</td>
						<td class="Tit1" style="width:5% !important">
							<script>campos_head.agregar('Fecha', true,'momento')</script>
						</td>
						<td class="Tit1" style="width:5% !important">
							<script>campos_head.agregar('Estado', true,'estado')</script>
						</td>
						<td class="Tit1" style="width:25% !important">
							<script>campos_head.agregar('Observaciones', false)</script>
						</td>
						<td class="Tit1" style="width:10% !important">
							<script>campos_head.agregar('Source', false)</script>
						</td>
					</tr>
				</table>

				<!-- Esta parte hace que complete las filas con la xsl:template  match="z:row" que está acá, más abajo -->
				<div id="divRow" style="overflow:hidden;width:100%">
					<table id="tbDetalles" class="tb1 highlightTROver highlightOdd layout_fixed" style="width: 100%; " >
						<!--table-layout: fixed !important-->
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
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
			<td>
				<!--<xsl:attribute name="style">width: 10%</xsl:attribute>-->
				<xsl:value-of  select="@identificador" />
			</td>
			<td>
				<xsl:value-of  select="@type" />
			</td>
			<td>
				<xsl:value-of  select="@body" />
			</td>
			
			
						<td>
							<xsl:value-of  select="@subject" />
						</td>
				
			
			<td>
				<xsl:value-of  select="substring (@momento, 1, 10)" />

			</td>
			<td>
				<xsl:choose>
					<xsl:when test="@estado = 'E'">
						<span>Enviado</span>
					</xsl:when>
					<xsl:when test="@estado = 'P'">
						<span>Pendiente</span>
					</xsl:when>
					<xsl:otherwise>
						<span>No registrado</span>
					</xsl:otherwise>
				</xsl:choose>
				
				<!--<xsl:attribute name="style">width: 25% </xsl:attribute>
				<xsl:value-of  select="@estado" />-->
			</td>
			<td>
				<xsl:value-of  select="@observacion" />
			</td>
			<td>
				<xsl:value-of  select="@source" />
			</td>

		</tr>
	</xsl:template>
</xsl:stylesheet>


