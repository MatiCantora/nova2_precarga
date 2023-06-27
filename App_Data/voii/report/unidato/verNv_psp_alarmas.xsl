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
		<![CDATA[
			Public function generarEncriptados() As String
				Page.contents("filtro_sub_comentario") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCom_registro_UnidatoPSP'><campos>nro_entidad,id_tipo,nro_com_id_tipo,nro_com_estado,nro_registro, nro_com_tipo,numero_alarma</campos><filtro></filtro><orden></orden></select></criterio>")

				return ""
			End Function

			Dim a As String = generarEncriptados()
			]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Detalle Alarma</title>
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
						<td style='width:3%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Unidato Alarma</xsl:attribute>
							<script>campos_head.agregar('Unidato Alarma', true,'UNIDATO_NUMERO_ALARMA')</script>
						</td>
						<td style='width:11%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Razón social</xsl:attribute>
							<script>campos_head.agregar('Razón Social', true,'RAZON_SOCIAL')</script>
						</td>
						<td style='width:4%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Fecha calc</xsl:attribute>
							<script>campos_head.agregar('Fecha calc', true,'MES_CALC')</script>
						</td>
						<td style='width:6%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Tipo de periodo</xsl:attribute>
							<script>campos_head.agregar('Tipo peri­odo', true,'tipo_periodo')</script>
						</td>
						<td style='width:10%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Fecha Alta - Vencimiento</xsl:attribute>
							<script>campos_head.agregar('Fecha Alta - Venc', true,'FECHA_VENCIMIENTO_ALARMA')</script>
						</td>
						<td style='width:22%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Tipo de Definición</xsl:attribute>
							<script>campos_head.agregar('Tipo de Definición', true,'tope_def')</script>
						</td>
						<td style='width:7%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Tipo de Persona</xsl:attribute>
							<script>campos_head.agregar('Tipo de Persona', true,'tp')</script>
						</td>
						<td style='width:6%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">CUIT de Titular</xsl:attribute>
							<script>campos_head.agregar('Cuit/Cuil', true,'CUITCUIL')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Estado</xsl:attribute>
							<script>campos_head.agregar('Estado', true,'estado_secuencia')</script>
						</td>
						<td style='width:5%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Cantidad de Operaciones</xsl:attribute>
							<script>campos_head.agregar('Cant Op', true,'cantidad_obtenida')</script>
						</td>
						<td style='width:8%; nowrap:true; text-align:center'>
							<xsl:attribute name="title">Importe</xsl:attribute>
							<script>campos_head.agregar('Importe', true,'importe_mo')</script>
						</td>
						<td style='width:3%'></td>
						<td style='width:3%'></td>
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
			<td style='width: 3%; nowrap:true; text-align:right;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@unidato_numero_alarma" />
				</xsl:attribute>
				<xsl:value-of  select="@unidato_numero_alarma" />
			</td>
			<td style='width: 11%; nowrap:true; text-decoration: underline; cursor:pointer;'>
				<xsl:choose>
					<xsl:when test="@aceptado = 'True'">
						<xsl:attribute name="style">width: 11%; nowrap:true;border-width: 1px;border-style: solid;border-color: darkgreen;</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:attribute name="title">
					<xsl:value-of  select="@razon_social" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_cliente(<xsl:value-of  select="@cuitcuil" />)
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@gran_cliente = 'True'">
						(GC)
					</xsl:when>
				</xsl:choose>
				<xsl:value-of  select="@razon_social" />
			</td>
			<td style='width: 4%; nowrap:true; text-align: right;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@mes_calc" />/<xsl:value-of  select="@anio_calc" />
				</xsl:attribute>
				<xsl:value-of  select="@mes_calc" />/<xsl:value-of  select="@anio_calc" />
			</td>
			<td style='width: 6%; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tipo_periodo" />
				</xsl:attribute>
				<xsl:value-of  select="@tipo_periodo" />
			</td>
			<td style='width: 10%; nowrap:true; text-align:center'>
				<xsl:attribute name="title">
					<xsl:value-of  select="foo:FechaToSTR(string(@FECHA_ALTA_ALARMA))" /> - <xsl:value-of  select="foo:FechaToSTR(string(@FECHA_VENCIMIENTO_ALARMA))" />
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@DIAS_VENCIMIENTO &lt;= 0">
						<xsl:attribute name="bgcolor">#fa3d3d</xsl:attribute>
					</xsl:when>
					<xsl:when test="@DIAS_VENCIMIENTO &lt;= 7">
						<xsl:attribute name="bgcolor">#F9700c</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of  select="foo:FechaToSTR(string(@FECHA_ALTA_ALARMA))" /> - <xsl:value-of  select="foo:FechaToSTR(string(@FECHA_VENCIMIENTO_ALARMA))" />
			</td>
			<td style='width: 22%; nowrap:true; text-decoration: underline; cursor:pointer;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_def" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_tope_def(<xsl:value-of  select="@nro_tope_def" />)
				</xsl:attribute>
				<xsl:value-of  select="@id_tope" /> - <xsl:value-of  select="@tope_def" />
			</td>
			<td style='width: 7%; nowrap:true'>
				<xsl:choose>
					<xsl:when test="@tp = 'PJ'">
						<xsl:attribute name="title">
							Persona Jurídica
						</xsl:attribute>
						Persona Jurídica
					</xsl:when>
					<xsl:when test="@tp = 'PH'">
						<xsl:attribute name="title">
							Persona Humana
						</xsl:attribute>
						Persona Humana
					</xsl:when>
				</xsl:choose>
			</td>
			<td style='width: 6%; text-align:right; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@cuitcuil" />
			</td>
			<td style='width: 5%; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@ESTADO_SECUENCIA" />
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="@ESTADO_SECUENCIA = 'En Análisis'">
						<xsl:attribute name="bgcolor">#F5F58F</xsl:attribute>
					</xsl:when>
					<xsl:when test="@ESTADO_SECUENCIA = 'Justificada'">
						<xsl:attribute name="bgcolor">#6BBA70</xsl:attribute>
					</xsl:when>
					<xsl:when test="@ESTADO_SECUENCIA = 'Falso Positivo'">
						<xsl:attribute name="bgcolor">#FF3300</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:value-of  select="@ESTADO_SECUENCIA" />
			</td>
			<td style='width: 5%; nowrap:true; text-align:right;'>
				<xsl:attribute name="title"><xsl:value-of  select="@cantidad_obtenida" /></xsl:attribute>
				<xsl:value-of  select="@cantidad_obtenida" />
			</td>
			<td style='width: 8%; text-align:right; nowrap:true'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@IMPORTE_MO" />
				</xsl:attribute>
				$<xsl:value-of select='format-number(@IMPORTE_MO,"###,###.00")' />
			</td>
			<td style="text-align:center; width:3%">
				<img>
					<xsl:attribute name="onclick">parent.cargarSubDetalle(event, '<xsl:value-of  select="@unidato_numero_alarma" />','<xsl:value-of  select="@nro_registro" />')</xsl:attribute>
					<xsl:attribute name="src">/FW/image/transferencia/buscar.png</xsl:attribute>
					<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Detalle de Alarma</xsl:attribute>
				</img>
			</td>
			<td style="text-align:center; width:3%">
				<img>
					<xsl:attribute name="onclick">parent.abrirComentario('<xsl:value-of  select="@unidato_numero_alarma" />','<xsl:value-of  select="@nro_registro" />')</xsl:attribute>
					<xsl:attribute name="src">/FW/image/icons/cambio_estado.png</xsl:attribute>
					<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Cambiar Estado</xsl:attribute>
				</img>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


