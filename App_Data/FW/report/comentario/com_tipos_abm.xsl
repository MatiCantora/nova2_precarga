<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

	<xsl:include href="xsl_includes\js_formato.xsl"  />
	<xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

	<xsl:template match="/">
		<html>
			<head>

				<title> ABM de Tipos </title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

				<script type="text/javascript" src="/FW/script/nvFW.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

				<script language="javascript" type="text/javascript">
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
					campos_head.nvFW = window.parent.nvFW

				</script>

			</head>
			<script>
					<![CDATA[
			function window_onload() {
              window_onresize();
              
			}
            
            function window_onresize() {
				var body = $$("BODY")[0]
				var altoDiv = body.clientHeight - 50
				$("divDetalles").setStyle({height: altoDiv + "px" })

				campos_head.resize("tbCabecera", "tbDetalles")
            } 
			
           
						]]>
			</script>

			<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: auto%; overflow: hidden">
				<!--CABECERA-->
				<table class="tb1" id="tbCabecera">
					<tr class="tbLabel">
						<td style='width: 3%; text-align: center; nowrap: true'>
							<script>campos_head.agregar('Nro', false,'nro_com_tipo')</script>
						</td>
						<td style='width: 12%; text-align: center; nowrap: true'>
							<script>campos_head.agregar('Tipo', true,'com_tipo')</script>
						</td>
						<td style="width: 25%; text-align: center; nowrap: true">				
							<script>campos_head.agregar('Estilo', false,'style')</script>
						</td>
						<td style='width: 15%; text-align: center; nowrap: true' >
							<script>campos_head.agregar('Permiso grupo', true,'nro_permiso_grupo')</script>
						</td>
						<td style='width: 10%; text-align: center; nowrap: true' >
							<script>campos_head.agregar('Permiso', true,'nro_permiso')</script>
						</td>
						<td style='width: 25%; text-align: center; nowrap: true' >
							<script>campos_head.agregar('Nombre ASP', true,'nombre_asp')</script>
						</td>
						<td style='width: 5%; text-align: center; nowrap: true' >
							Editar
						</td>
						<td style='width: 5%; text-align: center; nowrap: true'>
							Eliminar
						</td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='divDetalles' style='width: 100%; height: 100%; overflow-y: auto; overflow-x: hidden'>
					<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
						<xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
					</table>
				</div>

				<!-- DIV DE PAGINACION -->
				<div id="divPages" class="divPages" style="position: absolute; bottom: 0px; height: 16px">
					<script type="text/javascript">
						if (campos_head.PageCount > 1)
						document.write(campos_head.paginas_getHTML())
					</script>
				</div>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row" mode="row1">
		<tr class="dataRow">
			<td style="width:3%; text-align:left">
				<xsl:value-of  select="@nro_com_tipo" />
			</td>
			<td style="width:12%; text-align: left">
				<xsl:value-of  select="@com_tipo" />
			</td>
			<td style="width:25%; text-align: left">
				<xsl:attribute name="style">
					<xsl:value-of select="@style" />
				</xsl:attribute>	
				<xsl:value-of  select="@style" />
			</td>
			<td style="width:15%; text-align: left">
				<xsl:value-of  select="@permiso_grupo" />
			</td>
			<td style="width:10%; text-align: left">
				<xsl:value-of  select="@permiso" />
			</td>
			<td style="width:25%; text-align: left">
				<xsl:value-of  select="@nombre_asp" />
			</td>
			<td style="width:5%; text-align: center">
				<img style="cursor: pointer" src="/FW/image/icons/editar.png">
					<xsl:attribute name="onclick">parent.editarTipoABM('modificar', '<xsl:value-of select="@nro_com_tipo" />', '<xsl:value-of select="@com_tipo" />', '<xsl:value-of select="@style" />', '<xsl:value-of select="@nro_permiso_grupo" />', '<xsl:value-of select="@nro_permiso" />', '<xsl:value-of select="@nombre_asp" />')</xsl:attribute>
				</img>
			</td>
			<td style="width:5%; text-align: center">
				<img style="cursor: pointer" src="/FW/image/icons/eliminar.png">
					<xsl:attribute name="onclick">parent.eliminarTipo('<xsl:value-of select="@nro_com_tipo" />')</xsl:attribute>
				</img>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>