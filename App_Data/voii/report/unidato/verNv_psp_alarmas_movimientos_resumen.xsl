<?xml version="1.0" encoding="iso-8859-1"?>
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
		<![CDATA[
			Public function generarEncriptados() As String
				Page.contents("filtro_sub_detalle_operaciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_movimientos' cn='UNIDATO'><campos>*<campos><filtro></filtro><orden></orden></select></criterio>")

				return ""
			End Function

			Dim a As String = generarEncriptados()
			]]>
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
							let altura = $$('body')[0].getHeight() - $('tbCabecera').getHeight();
							$('tabla_contenido').style.height = altura + 'px';
                
							$('tblog').getHeight() > altura ? $('tdScroll').show() : $('tdScroll').hide();
					  }
					 
				  ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden">
				<table class="tb1 layout_fixed" id="tbCabecera">
					<tr class='tbLabel0'>
						<td style='width: 15%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('PSP', true,'psp')</script>
						</td>
						<td style='width: 22%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Definición de Tope', true,'tope_def')</script>
						</td>
						<td style='width: 9%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Mes', true,'mes_calc')</script>
						</td>
						<td style='width: 8%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Año', true,'anio_calc')</script>
						</td>
						<td style='width: 10%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Alarmas', true,'alarmas')</script>
						</td>
						<td style='width: 10%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Vigente', true,'vigente')</script>
						</td>
						<td style='width: 12%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Tipo período', true,'tipo_periodo')</script>
						</td>
						<td style='width: 12%; nowrap:true; text-align:center'>
							<script>campos_head.agregar('Fecha alta', true,'fe_alta')</script>
						</td>
						<td style="width: 2%; display: none" id="tdScroll"></td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='tabla_contenido' style='width: 100%; overflow:auto'>
					<table class="tb1 highlightOdd layout_fixed" id="tblog" name="tblog">
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
			<td style='width: 15%; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@psp" />
				</xsl:attribute>
				<xsl:value-of  select="@psp" />
			</td>
			<td style='width: 22%; nowrap:true; text-decoration: underline; cursor:pointer;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@id_tope" /> - <xsl:value-of  select="@tope_def" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_tope_def(<xsl:value-of  select="@nro_tope_def" />)
				</xsl:attribute>
				<xsl:value-of  select="@id_tope" /> - <xsl:value-of  select="@tope_def" />
			</td>
			<td style='width: 9%; nowrap:true;'>
				<xsl:if test="@mes_calc = 1">
					Enero
				</xsl:if>
				<xsl:if test="@mes_calc = 2">
					Febrero
				</xsl:if>
				<xsl:if test="@mes_calc = 3">
					Marzo
				</xsl:if>
				<xsl:if test="@mes_calc = 4">
					Abril
				</xsl:if>
				<xsl:if test="@mes_calc = 5">
					Mayo
				</xsl:if>
				<xsl:if test="@mes_calc = 6">
					Junio
				</xsl:if>
				<xsl:if test="@mes_calc = 7">
					Julio
				</xsl:if>
				<xsl:if test="@mes_calc = 8">
					Agosto
				</xsl:if>
				<xsl:if test="@mes_calc = 9">
					Septiembre
				</xsl:if>
				<xsl:if test="@mes_calc = 10">
					Octubre
				</xsl:if>
				<xsl:if test="@mes_calc = 11">
					Noviembre
				</xsl:if>
				<xsl:if test="@mes_calc = 12">
					Diciembre
				</xsl:if>
			</td>
			<td style='width: 8%; nowrap:true; text-align:right;'>
				<xsl:value-of select="@anio_calc" />
			</td>
			<td style='width: 10%; nowrap:true; text-align:right;'>
				<xsl:value-of select="@alarmas" />&#160;
				<img src="/FW/image/icons/reporte.png" style="cursor: pointer;">
					<xsl:attribute name="onclick">
						parent.ver_alarmas(<xsl:value-of  select="@id_tipo_alarma" />, <xsl:value-of  select="@anio_calc" />, <xsl:value-of  select="@mes_calc" />, '<xsl:value-of  select="@psp_id" />')
					</xsl:attribute>
				</img>
			</td>
			<td style='width: 10%; nowrap:true;'>
				<xsl:choose>
					<xsl:when test="@vigente">
						Si
					</xsl:when>
					<xsl:otherwise>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='width: 12%; nowrap:true;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tipo_periodo" />
				</xsl:attribute>
				<xsl:value-of select="@tipo_periodo" />
			</td>
			<td style='width: 12%; nowrap:true; text-align:right;'>
				<xsl:attribute name="title">
					<xsl:value-of select="foo:FechaToSTR(string(@fe_alta))" />
				</xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@fe_alta))" />
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>


