<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<!--<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>-->
	<xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
              
				
	
	
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<html onload="return window_onload()" >
			<head>
				<!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>-->
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
					var alto_body = $('body1').getHeight()
					var tableMain = $('tbCabecera').getHeight()
					var div_pag = $('div_pag').getHeight()
					var alto_div = alto_body - tableMain - div_pag
					$('div_pag').style.height = alto_div + 'px'
					}

				</script>

			</head>

			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden" id="body1">

				<!-- TABLA DE CABECERAS - El true/false del campos_head.agregar indica si queremos que tenga ordenamiento o no -->
				<table id="tbCabecera" name="main"  class="tb1" style="width: 100%">
					<tr>
						<td class="Tit1"  style="width:3%">

						</td>
						<td class="Tit1"  style="width:7%">
							<script>campos_head.agregar('Cliente', true,'clinrodoc')</script>
						</td>
						<td class="Tit1"  style="width:8%">
							<script>campos_head.agregar('Circuito', true,'clinrodoc')</script>
						</td>
						<td class="Tit1"  style="width:15%">
							<script>campos_head.agregar('CBU', true, 'clicbu')</script>
						</td>
						<td class="Tit1"  style="width:15%">
							<script>campos_head.agregar('Nro. Referencia', true,'nroreferencia')</script>
						</td>

						<td class="Tit1"  style="width:10% ">
							<script>campos_head.agregar('Estado', true,'estado')</script>
						</td>
						<td class="Tit1"  style="width:7%">
							<script>campos_head.agregar('Fecha', true,'fecha_estado')</script>
						</td>
						<td class="Tit1"  style="width:33% ">
							<script>campos_head.agregar('Descripción', true,'campo')</script>
						</td>
						<td class="Tit1"  style="width:2% "></td>


					</tr>
				</table>

				<div style="overflow: auto">
					<!-- Esta parte hace que complete las filas con la xsl:template  match="z:row" que está acá, más abajo -->
					<div id="divRow" style="overflow:hidden;width:100%; overflow:hidden">
						<table id="tbDetalles" class="tb1   layout_fixed" style="width: 100%; " >
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
				<xsl:when test='@descripcion="Cargado"'>
					<xsl:attribute name="style">background-color: white; width:3%</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Pendiente"'>
					<xsl:attribute name="style">background-color: #DDA3B2; color:white; width:3%</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Cancelado"'>
					<xsl:attribute name="style">background-color: #E72458; color:white; width:3%</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Procesado IBS OK"'>
					<xsl:attribute name="style">background-color: #3DA5D9; color:white; width:3%</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Anulado"'>
					<xsl:attribute name="style">background-color:#EA7317 ; color:white !important</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Credin en Curso"'>
					<xsl:attribute name="style">background-color: #2364AA; color:white</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Credin Acreditado"'>
					<xsl:attribute name="style">background-color: #73BFB8; color:white</xsl:attribute>
				</xsl:when>
				<xsl:when test='@descripcion="Cargado"'>
					<xsl:attribute name="style">background-color: #FEC601; color:black</xsl:attribute>
				</xsl:when>

				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>

			<td>
								<xsl:attribute name="style">text-align: center</xsl:attribute>
				<input type="radio"  name="fav_language" value="JavaScript">
					<xsl:attribute name="id">
						<xsl:value-of  select="@nroreferencia" />
					</xsl:attribute>
					<xsl:choose>
						<xsl:when test='@descripcion = "Cargado"'>
							<xsl:attribute name="disabled">true</xsl:attribute>
						</xsl:when>
						<xsl:when test='@descripcion = "Pendiente"'>
							<xsl:attribute name="disabled">true</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:attribute name="onclick">
						parent.verDetalle(event,'<xsl:value-of select="@nroreferencia"/>')
					</xsl:attribute>
					<xsl:attribute name="style">cursor:pointer</xsl:attribute>
				</input>
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>
				<xsl:value-of  select="@clinrodoc" />
			</td>
			<td>
				<xsl:attribute name="title">
					<xsl:value-of select="@descr_circ" />
				</xsl:attribute>
				<xsl:attribute name="style">text-align: right</xsl:attribute>
				<xsl:value-of  select="@descr_circ" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>
				<xsl:value-of  select="@clicbu" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>
				<xsl:value-of  select="@nroreferencia" />
			</td>


			<td>
				<xsl:value-of  select="@descripcion" />
			</td>
			<td>
				<xsl:attribute name="style">text-align: right</xsl:attribute>
				<xsl:value-of  select="substring(@fecha_estado,9,2)" />/<xsl:value-of  select="substring(@fecha_estado,6,2)" />/<xsl:value-of  select="substring(@fecha_estado,1,4)" />

			</td>
			<!--<td>
				<xsl:attribute name="style">width:30%</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of  select="translate(@campo, 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ', 'AAAAAAACEEEEIIIIDNOOOOOOUUUUYBsaaaaaaaceeeeiiiionoooooouuuuyty')" />
				</xsl:attribute>
				<xsl:value-of  select="translate(@campo, 'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ', 'AAAAAAACEEEEIIIIDNOOOOOOUUUUYBsaaaaaaaceeeeiiiionoooooouuuuyty')" />

			</td>-->
			<!--<td>
				<xsl:attribute name="style">width:30%</xsl:attribute>
				<xsl:attribute name="title">
					<xsl:value-of disable-output-escaping="yes" select="string(@campo)" />
				</xsl:attribute>
				<xsl:value-of disable-output-escaping="yes"  select="string(@campo)" />
			</td>-->
			<td>
				<xsl:attribute name="title">
					<xsl:value-of select="@campo" />
				</xsl:attribute>
				<xsl:value-of  select="@campo"/>
			</td>
			<td>
				<xsl:attribute name="style">background-color:white;text-align: center</xsl:attribute>
				<xsl:choose>
				<xsl:when test='@descripcion="Cargado" or @descripcion="Pendiente"'>
					<img>
					<xsl:attribute name="style">cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Cancelar instrucciones</xsl:attribute>

					<xsl:attribute name="src">/fw/image/icons/baja.png</xsl:attribute>
					<xsl:attribute name="onclick">
						parent.ejecTransferencia('<xsl:value-of select="@id"/>','<xsl:value-of select="@clinrodoc"/>')
					</xsl:attribute>
				</img>
				</xsl:when>				
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
					
					
					
				
			</td>


		</tr>
	</xsl:template>
</xsl:stylesheet>


