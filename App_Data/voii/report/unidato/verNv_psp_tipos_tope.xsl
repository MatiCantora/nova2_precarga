<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

	<xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
	<xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>

	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<msxsl:script language="vb" implements-prefix="user">

	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Detalle operaciones</title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
				<link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
				<script type="text/javascript" src="/FW/script/nvFW.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
				<script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
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

				<script type="text/javascript">
					<![CDATA[
		
					  function onload() {						
						  window.onresize();  
					  }

					  function onresize() {							
							try
							  {
								  let altura = $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('divPages').getHeight();
								  $('tabla_contenido').style.height = altura + 'px';
								  
								  $('tblog').getHeight() - $('tabla_contenido').getHeight() >= 0 ? $('tdScroll').hidden = false : $('tdScroll').hidden = true
							  }
							  catch (e) {}
					  }
					  			  
				  ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden">
				<table class="tb1 layout_fixed" id="tbCabecera">
					<tr class='tbLabel0'>
						<td style='width:30%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Unidato Alarma</xsl:attribute>
							<script>campos_head.agregar('Tipo Tope', true,'tope_tipo')</script>
						</td>
						<td style='width:30%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Tipo Alarma</xsl:attribute>
							<script>campos_head.agregar('Tope', true,'tope')</script>
						</td>
						<td style='width:20%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Mes</xsl:attribute>
							<script>campos_head.agregar('Fecha desde', true,'fe_desde')</script>
						</td>
						<td style='width:20%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Año</xsl:attribute>
							<script>campos_head.agregar('Fecha Hasta', true,'fe_hasta')</script>
						</td>
						<td id='tdScroll' hidden='true' style='width:1%'></td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='tabla_contenido' style='width: 100%;overflow:auto'>
					<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tblog" name="tblog">
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>

				<!-- DIV DE PAGINACION -->
				<div id="divPages" class="divPages" style="position: absolute; bottom: 0px; height: 15px;">
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
			<xsl:choose>
				<xsl:when test="foo:FechaToSTR(string(@fe_hasta)) != ''">
					<xsl:attribute name="style">color:darkred</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<td style='width: 30%; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_tipo" />
				</xsl:attribute>
				<xsl:value-of  select="@tope_tipo" />
			</td>
			<td style='width: 30%; nowrap:true; text-align:right;'>
				<xsl:attribute name="title">
					<xsl:choose>
						<xsl:when test ="not(format-number(@tope,'###,###.00') = 'NaN')">
							<xsl:value-of select='format-number(@tope,"###,###.00")' />
						</xsl:when >
						<xsl:otherwise>
							-
						</xsl:otherwise>
					</xsl:choose >
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test ="not(format-number(@tope,'###,###.00') = 'NaN')">
						<xsl:value-of select='format-number(@tope,"###,###.00")' />
					</xsl:when >
					<xsl:otherwise>
						-
					</xsl:otherwise>
				</xsl:choose >
			</td>
			<td style='width: 20%; nowrap:true; text-align:right;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_desde))" />
				</xsl:attribute>
				<xsl:value-of  select="foo:FechaToSTR(string(@fe_desde))" />
			</td>
			<td style='width: 20%; text-align:right; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_hasta))" />
				</xsl:attribute>
				<xsl:value-of  select="foo:FechaToSTR(string(@fe_hasta))" />
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


