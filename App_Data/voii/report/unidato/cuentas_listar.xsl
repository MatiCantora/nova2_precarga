<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

	<xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
	<xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>

	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Consulta Comentarios</title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
				<link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
				<script type="text/javascript" src="/FW/script/swfobject.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
				<script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
				<xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>

				<script language="javascript" type="text/javascript">
					campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
					var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
					campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
					campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
					campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
					campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
					campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW
				</script>
				<script type="text/javascript" language="javascript">
					<![CDATA[
 
						var $body            = null;
						var $divCabeceras    = null;
						var $div_pag1        = null;
						var $tabla_contenido = null;
		  
						function onload() {
							$body            = $$('body')[0];
							$divCabeceras    = $('tbCabe');
							$div_pag1        = $('div_pag');
							$tabla_contenido = $('divDetalle');
				
							onresize();
						}

						function onresize() {
							try
							  {
								  let altura = $body.getHeight() - $divCabeceras.getHeight() - $div_pag1.getHeight();
								  $tabla_contenido.style.height = altura + 'px';
							  }
							  catch (e) {}
							
							campos_head.resize('tbCabe', 'tbDetalle')
						} 
					
					]]>

				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width:100%;height:100%;overflow:hidden">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td style='width:20%; text-align:center' nowrap='true'>
							<script type="text/javascript">
								campos_head.agregar('Tipo de Cuenta', true, 'TIPO_CUENTA')
							</script>
						</td>
						<td style='width:20%; text-align:center' nowrap='true'>
							<script type="text/javascript">
								campos_head.agregar('Nro Cuenta', true, 'numero_cuenta')
							</script>
						</td>
						<td style='width:30%; text-align:center' nowrap='true'>
							<script type="text/javascript">
								campos_head.agregar('CBU', true, 'cbu')
							</script>
						</td>
						<td style='width:20%; text-align:center' nowrap='true'>
							<script type="text/javascript">
								campos_head.agregar('Sucursal', true, 'sucursal')
							</script>
						</td>
						<td style='width:5%; text-align:center' nowrap='true'>-</td>
						<td style='width:5%; text-align:center' nowrap='true'>-</td>
					</tr>
				</table>

				<div id="divDetalle" style="width:100%;overflow:auto">
					<table id="tbDetalle" class='tb1 highlightOdd highlightTROver layout_fixed'>
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>

				<div id="div_pag" class="divPages">
					<script type="text/javascript">
						if (campos_head.PageCount > 1)
						document.write(campos_head.paginas_getHTML())
					</script>
				</div>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()"/>

		<tr style="max-height:18px !important">
			<td style="text-align: left; width: 20%">
				<xsl:value-of select="@TIPO_CUENTA" />
			</td>
			<td  style="text-align: left; width: 20%">
				<xsl:value-of select="@numero_cuenta"/>
			</td>
			<td  style="text-align: left; width: 30%">
				<xsl:value-of select="@cbu"/>
			</td>
			<td  style="text-align: left; width: 20%">
				<xsl:value-of select="@SUCURSAL"/>
			</td>
			<td  style="text-align: center; width: 5%">
				<xsl:choose>
					<xsl:when test ="@cbu != 'OTROS'">
						<img src="/fw/image/icons/editar.png" style="cursor:pointer" >
							<xsl:attribute name="onclick">
								parent.editar_cuenta('<xsl:value-of select="@id_cliente"/>', <xsl:value-of select="@id_tipo_cuenta"/>, '<xsl:value-of select="@numero_cuenta"/>','<xsl:value-of select="@cbu"/>',<xsl:value-of select="@id_sucursal"/>)
							</xsl:attribute>
						</img>
					</xsl:when >
				</xsl:choose>
			</td>
			<td  style="text-align: center; width: 5%">
				<xsl:choose>
					<xsl:when test ="@cbu != 'OTROS'">
						<img src="/fw/image/icons/eliminar.png" style="cursor:pointer" >
							<xsl:attribute name="onclick">
								parent.eliminar_cuenta('<xsl:value-of select="@id_cliente"/>','<xsl:value-of select="@cbu"/>')
							</xsl:attribute>
						</img>
					</xsl:when >
				</xsl:choose>
			</td>
		</tr>


	</xsl:template>
</xsl:stylesheet>
