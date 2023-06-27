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
					var win_comentario

           
            function window_onload() {}

          function window_onresize() {
             
              
                  campos_head.resize("tbCabe", "tbDetalle")
              
          }
					
          
					
					]]>


				</script>

			</head>
			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel layout_fixed">
						<td style='width:6%; text-align:center; white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('cod_bcra', true, 'cod_bcra')
							</script>
						</td>
						<td style='width:20%; text-align:center; white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('Razon Social', true, 'razon_social')
							</script>
						</td>
						<td style='width:18%; text-align:center; white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('Tipo Cuenta', true, 'TIPO_CUENTA')
							</script>
						</td>
						<td style='width:21%; text-align:center white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('CBU:', true, 'cbu')
							</script>
						</td>
						<td style='width:15%; text-align:center; white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('Tipo Doc', true, 'TIPO_DOC')
							</script>
						</td>
						<td style='width:15%; text-align:center; white-space:nowrap'>
							<script type="text/javascript">
								campos_head.agregar('Cuit/Cuil', true, 'cuitcuil')
							</script>
						</td>
						<td style='width:5%; text-align:center; white-space:nowrap' >-</td>
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
		<tr>
			<td  style="text-align: left; width: 6%; white-space:nowrap" >
				<xsl:value-of select="@cod_bcra"/>
			</td>
			<td  style="text-align: left; width: 20%; white-space:nowrap">
				<xsl:value-of select="@razon_social"/>
			</td>
			<td style="text-align: left; width: 18%; white-space:nowrap">
				<xsl:value-of select="@TIPO_CUENTA" />
			</td>
			<td  style="text-align: left; width: 21%; white-space:nowrap">
				<xsl:value-of select="@cbu"/>
			</td>
			<td  style="text-align: left; width: 15%; white-space:nowrap">
				<xsl:value-of select="@TIPO_DOC"/>
			</td>
			<td  style="text-align: left; width: 15%; white-space:nowrap">
				<xsl:value-of select="@cuitcuil"/>
			</td>
			<td  style="text-align: center; width: 5%; white-space:nowrap">
				<img src="/fw/image/icons/editar.png" style="cursor:pointer" >
					<xsl:attribute name="onclick">
						parent.psps_editar('<xsl:value-of select="@id_cliente"/>','<xsl:value-of select="@TIPO_CUENTA"/>','<xsl:value-of select="@psp_tipo_docu"/>', '<xsl:value-of select="@cuitcuil"/>', '<xsl:value-of select="@razon_social"/>','<xsl:value-of select="@cbu"/>', '<xsl:value-of select="@cod_bcra"/>')
					</xsl:attribute>
				</img>
			</td>
		</tr>


	</xsl:template>
</xsl:stylesheet>
