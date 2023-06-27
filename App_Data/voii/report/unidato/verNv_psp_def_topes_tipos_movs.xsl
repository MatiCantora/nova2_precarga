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
		  
						function window_onload() {				
							window_onresize();
						}

						function window_onresize() {              
							try
							  {
							  
								let altura = $$('body')[0].getHeight() - $('tbCabe').getHeight();
								$('divDetalle').style.height = altura + 'px';
								$('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? $('tdScroll').hidden = false : $('tdScroll').hidden = true;
							  }
				  
							  catch (e) {}
						}
					
					]]>

				</script>

			</head>
			<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; overflow: auto">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td style='width:90%; text-align:center'>
							<script type="text/javascript">
								campos_head.agregar('Tipos de movimientos asociados', true, 'mov_tipo')
							</script>
						</td>
						<td style='width:9%; text-align:center; white-space:nowrap'>
							Eliminar
						</td>
						<td id='tdScroll' hidden='true' style='width:1%'></td>
					</tr>
				</table>

				<div id="divDetalle" style="width:100%;overflow:auto">
					<table id="tbDetalle" class='tb1 highlightOdd highlightTROver layout_fixed'>
						<xsl:apply-templates select="xml/rs:data/z:row" />
						<tr>
							<td colspan="2" style="text-align: center;">
								<img src="/fw/image/icons/agregar.png" style="cursor:pointer" >
									<xsl:attribute name="onclick">
										parent.asociar_nuevo_movimiento()
									</xsl:attribute>
								</img>
							</td>
						</tr>
					</table>
				</div>

				<!--<div id="div_pag" class="divPages">
					<script type="text/javascript">
						if (campos_head.PageCount > 1)
							document.write(campos_head.paginas_getHTML())
					</script>
				</div>-->
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
		<tr>
			<td style="width: 90%; white-space:nowrap'">
				<xsl:value-of select="@mov_tipo_desc"/>
			</td>
			<td style="width: 9%; text-align: center;white-space:nowrap">
				<img src="/fw/image/icons/eliminar.png" style="cursor:pointer" >
					<xsl:attribute name="onclick">
						parent.eliminar_tipo_mov('<xsl:value-of select="@mov_tipo"/>')
					</xsl:attribute>
				</img>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>
