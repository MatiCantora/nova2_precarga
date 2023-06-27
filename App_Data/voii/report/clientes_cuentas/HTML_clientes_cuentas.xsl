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
				<title></title>
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
				<table id="tbCabecera" name="main"  class="tb1" style="width: 100%">
					<tr >
						<td class="Tit1"  style="width:5% !important; text-align:center;">
							<script>campos_head.agregar('Tipo documento', true,'tipdoc')</script>
						</td>
						<td  class="Tit1" style="width:7% !important; text-align:center">
							<script>campos_head.agregar('Número de documento', true , 'nrodoc')</script>
						</td>
						<td  class="Tit1" style="width:12% !important; text-align:center">
							<script>campos_head.agregar('Razon Social', true , 'Razon_social')</script>
						</td>
						<td class="Tit1" style="width:10% !important; text-align:center">
							<script>campos_head.agregar('Sistema', true,'sistcod')</script>
						</td>
						<td class="Tit1" style="width:7% !important; text-align:center">
							<script>campos_head.agregar('Número de cuenta', true,'cuecod')</script>
						</td>
						<td class="Tit1" style="width:11% !important; text-align:center">
							<script>campos_head.agregar('CBU', true,'cbu')</script>
						</td>
						<td class="Tit1" style="width:7% !important; text-align:center">
							<script>campos_head.agregar('Moneda', true,'moneda_desc')</script>
						</td>
						<td  class="Tit1" style="width:5% !important; text-align:center">
							<script>campos_head.agregar('Vigente', true,'vigente')</script>
						</td>
						<td class="Tit1" style="width:7% !important; text-align:center">
							<script>campos_head.agregar('Fecha de vigencia', true,'fe_vigencia')</script>
						</td>
						<td  class="Tit1" style="width:7% !important; text-align:center">
							<script>campos_head.agregar('Operador', true,'Login')</script>
						</td>
						<td  class="Tit1" style="width:14% !important; text-align:center">
							<script>campos_head.agregar('Callback', false)</script>
						</td>

						<td  class="Tit1" style="width:5% !important; text-align:center">
							<script>campos_head.agregar('Es PSP', false)</script>
						</td>
						<td  class="Tit1" style="width:3% !important; text-align:center">
							<script>campos_head.agregar('-', false)</script>
						</td>
					</tr>
				</table>

				<!-- Esta parte hace que complete las filas con la xsl:template  match="z:row" que está acá, más abajo -->
				<div id="divRow" style="overflow:hidden;width:100%">
					<table id="tbDetalles" class="tb1 highlightTROver highlightOdd layout_fixed" style="width: 100%; " >
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
				<xsl:value-of  select="@tipdoc_desc" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:right</xsl:attribute>

				<xsl:value-of  select="@nrodoc" />
			</td>
			
			<td>
				<xsl:attribute name="title">
					<xsl:value-of  select="@Razon_social" />
				</xsl:attribute>
				<xsl:value-of  select="@Razon_social" />
			</td>
			
			<td>
				<xsl:attribute name="title">
					<xsl:value-of  select="@sistcod" /> - <xsl:value-of  select="@siscod_desc" />
				</xsl:attribute>
				<xsl:value-of  select="@siscod_desc" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:right</xsl:attribute>
				<xsl:value-of  select="@cuecod" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:right</xsl:attribute>
				<xsl:value-of  select="@cbu" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:left</xsl:attribute>
				<xsl:value-of  select="@desc_externo" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:center</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@vigente = 'True'">
						<span>Si</span>
					</xsl:when>
					<xsl:when test="@vigente = 'False'">
						<span>No</span>
					</xsl:when>
					<xsl:otherwise>
						<span>No hay informacion</span>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			
			<td>
				<xsl:value-of  select="substring(@fe_vigencia,9,2)" />/<xsl:value-of  select="substring(@fe_vigencia,6,2)" />/<xsl:value-of  select="substring(@fe_vigencia,1,4)" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:left</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of  select="@Login" />
				</xsl:attribute>
				<xsl:value-of  select="@Login" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:left</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of  select="@callback" />
				</xsl:attribute>
				<xsl:value-of  select="@callback" />
			</td>
			
			<td>
				<xsl:attribute name="style">text-align:left</xsl:attribute>

				<xsl:choose>
					<xsl:when test="@es_psp = 'True'">
						<span>Si</span>
					</xsl:when>
					<xsl:when test="@es_psp = 'False'">
						<span>No</span>
					</xsl:when>
					<xsl:otherwise>
						<span>No hay informacion</span>
					</xsl:otherwise>
				</xsl:choose>
			</td>

			<td>
				<xsl:attribute name="style">text-align:center</xsl:attribute>
				<img>
					<xsl:attribute name="style">cursor:pointer</xsl:attribute>
					<xsl:attribute name="src">/fw/image/icons/editar.png</xsl:attribute>
					<xsl:attribute name="onclick">
						parent.editar("edit",'<xsl:value-of select="@id_api_cc_cfg"/>')
					</xsl:attribute>
				</img>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


