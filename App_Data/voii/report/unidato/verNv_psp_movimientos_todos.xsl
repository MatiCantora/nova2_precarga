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
						<td style='width:8%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Cliente</xsl:attribute>
							<script>campos_head.agregar('Cliente', true,'razon_social')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Mes</xsl:attribute>
							<script>campos_head.agregar('Mes', true,'mes_desc')</script>
						</td>
						<td style='width:3%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Año</xsl:attribute>
							<script>campos_head.agregar('Año', true,'anio')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Tipo de movimiento</xsl:attribute>
							<script>campos_head.agregar('Tipo mov', true,'mov_tipo_desc')</script>
						</td>
						<td style='width:10%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Razón Social Titular</xsl:attribute>
							<script>campos_head.agregar('Titular', true,'TIT_RAZON_SOCIAL')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CUIT de Titular</xsl:attribute>
							<script>campos_head.agregar('Cuit', true,'TIT_CUITCUIL')</script>
						</td>
						<td style='width:9%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CBU de Titular</xsl:attribute>
							<script>campos_head.agregar('CBU', true,'TIT_CBU')</script>
						</td>
						<td style='width:9%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CVU de Titular</xsl:attribute>
							<script>campos_head.agregar('CVU', true,'TIT_CVU')</script>
						</td>
						<td style='width:10%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Razón Social de Contraparte</xsl:attribute>
							<script>campos_head.agregar('Contraparte', true,'CONT_RAZON_SOCIAL')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CUIT de Contraparte</xsl:attribute>
							<script>campos_head.agregar('CUIT', true,'CONT_CUITCUIL')</script>
						</td>
						<td style='width:9%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CBU de Contraparte</xsl:attribute>
							<script>campos_head.agregar('CBU', true,'CONT_CBU')</script>
						</td>
						<td style='width:9%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CVU de Contraparte</xsl:attribute>
							<script>campos_head.agregar('CVU', true,'CONT_CVU')</script>
						</td>
						<td style='width:7%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Importe</xsl:attribute>
							<script>campos_head.agregar('Importe', true,'IMPORTE')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Fecha de movimiento</xsl:attribute>
							<script>campos_head.agregar('Fecha mov', true,'MOV_FECHA')</script>
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
			<td style='width: 8%; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@razon_social" />
				</xsl:attribute>
				<xsl:value-of  select="@razon_social" />
			</td>
			<td style='width: 5%; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@mes_desc" />
				</xsl:attribute>
				<xsl:value-of  select="@mes_desc" />
			</td>
			<td style='width: 3%; text-align:right; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@anio" />
				</xsl:attribute>
				<xsl:value-of  select="@anio" />
			</td>
			<td style='width: 5%; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@mov_tipo_desc" />
				</xsl:attribute>
				<xsl:value-of  select="@mov_tipo_desc" />
			</td>
			<td style='width: 10%; nowrap:true; text-decoration: underline; cursor:pointer; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_razon_social" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_cliente(<xsl:value-of  select="@tit_cuitcuil" />)
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@tit_gran_cliente = 'True'">
						(GC)
					</xsl:when>
				</xsl:choose>
				<xsl:value-of  select="@tit_razon_social" />
			</td>
			<td style='width: 5%; text-align:right; nowrap:true; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cuitcuil" />
			</td>
			<td style='width: 9%; text-align:right; nowrap:true; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cbu" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cbu" />
			</td>
			<td style='width: 9%; text-align:right; nowrap:true; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cvu" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cvu" />
			</td>
			<td style='width: 10%; nowrap:true; text-decoration: underline; cursor:pointer; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_razon_social" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_cliente(<xsl:value-of  select="@cont_cuitcuil" />)
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@cont_gran_cliente = 'True'">
						(GC)
					</xsl:when>
				</xsl:choose>
				<xsl:value-of  select="@cont_razon_social" />
			</td>
			<td style='width: 5%; text-align:right; nowrap:true; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cuitcuil" />
			</td>
			<td style='width: 9%; text-align:right; nowrap:true; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cbu" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cbu" />
			</td>
			<td style='width: 9%; text-align:right; nowrap:true; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cvu" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cvu" />
			</td>
			<td style='width: 7%; text-align:right; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@importe" />
				</xsl:attribute>
				$<xsl:value-of select='format-number(@importe,"###,###.00")' />
			</td>
			<td style='width: 5%; text-align:right; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="foo:FechaToSTR(string(@mov_fecha))" />
				</xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@mov_fecha))"/>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


