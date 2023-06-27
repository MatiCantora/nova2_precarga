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

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Detalle operaciones</title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
				<link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
				<script type="text/javascript" src="/FW/script/swfobject.js"></script>
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
		
			var $body            = null;
			var $divCabeceras    = null;
			var $div_pag1        = null;
			var $tabla_contenido = null;
		  
            function onload() {
				$body            = $$('body')[0];
				$divCabeceras    = $('tbCabecera');
				$div_pag1        = $('divPages');
				$tabla_contenido = $('tabla_contenido');
				
				onresize();
            }

            function onresize() {
				try
				  {
					  let altura = $body.getHeight() - $divCabeceras.getHeight() - $div_pag1.getHeight();
					  $tabla_contenido.style.height = altura + 'px';
				  }
				  catch (e) {}

            } 
			
			function editar(nro_tope_def, tope_def, nro_tope_tipo, nro_tope, vigente, tipo_periodo, id_tipo_alarma, origen, movs_propios) {
				let win_plantilla = nvFW.createWindow({
					className: 'alphacube',
					url: '/voii/unidato/abm_def_topes.aspx',
					title: 'Editar Definición de Tope',
					minimizable: false,
					maximizable: false,
					draggable: true,
					resizable: false,
					width: 700,
					height: 350,
					destroyOnClose: true,
					onClose: function (win_plantilla) {
						if (win_plantilla.options.userData.hay_modificacion) {
							parent.buscar();
						}
					}
				});
			
				win_plantilla.options.userData = {nro_tope_def: nro_tope_def, tope_def: tope_def, nro_tope_tipo: nro_tope_tipo, nro_tope: nro_tope, vigente: vigente, tipo_periodo: tipo_periodo, id_tipo_alarma: id_tipo_alarma, modo: 'M', origen: origen, movs_propios:movs_propios, hay_modificacion: false }
				win_plantilla.showCenter();
			}
           
          ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden">

				<table class="tb1 layout_fixed" id="tbCabecera">
					<tr class='tbLabel'>
						<td style='width:5%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Nro. Tope
							</xsl:attribute>
							<script>campos_head.agregar('Nro. Tope', true,'nro_tope')</script>
						</td>
						<td style='width:40%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Definición de Tope
							</xsl:attribute>
							<script>campos_head.agregar('Definición de Tope', true,'tope_def')</script>
						</td>
						<td style='width:5%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Nro. Alarma Unidato
							</xsl:attribute>
							<script>campos_head.agregar('Nro Alarma Unidato', true,'id_tipo_alarma')</script>
						</td>
						<td style='width:10%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Tipo de Tope
							</xsl:attribute>
							<script>campos_head.agregar('Tipo de tope', true,'tope_tipo')</script>
						</td>
						<td style='width:9%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Origen
							</xsl:attribute>
							<script>campos_head.agregar('Origen', true,'origen')</script>
						</td>
						<td style='width:5%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								¿Toma movimientos propios?
							</xsl:attribute>
							<script>campos_head.agregar('Toma movs. propios', true,'movs_propios')</script>
						</td>
						<td style='width:5%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								¿Vigente?
							</xsl:attribute>
							<script>campos_head.agregar('Vigente', true,'vigente')</script>
						</td>
						<td style='width:8%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Tipo de Período
							</xsl:attribute>
							<script>campos_head.agregar('Tipo período', true,'tipo_periodo')</script>
						</td>
						<td style='width:9%; white-space:nowrap; text-align:center'>
							<xsl:attribute name="title">
								Fecha de Alta
							</xsl:attribute>
							<script>campos_head.agregar('Fecha de alta', true,'fe_alta')</script>
						</td>
						<td style='width:3%; white-space:nowrap; text-align:center'></td>
						<td style='width:3%; white-space:nowrap; text-align:center'></td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='tabla_contenido' style='width: 100%;'>
					<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tblog" name="tblog">
						<xsl:apply-templates select="xml/rs:data/z:row" />						
					</table>
				</div>

				<!-- DIV DE PAGINACION -->
				<div id="divPages" class="divPages" style="position: absolute; bottom: 5px; height: 16px">
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
				<xsl:when test="@vigente != 'True'">
					<xsl:attribute name="style">color:red;</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<td style='width: 5%; white-space:nowrap; text-align:right'>
				<xsl:value-of  select="@nro_tope" />
			</td>
			<td style='width: 40%; white-space:nowrap;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_def" />
				</xsl:attribute>
				<xsl:value-of  select="@tope_def" />
			</td>
			<td style='width: 5%; white-space:nowrap;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@id_tipo_alarma" />
				</xsl:attribute>
				<xsl:value-of  select="@id_tipo_alarma" />
			</td>
			<td style='width: 10%; white-space:nowrap;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_tipo" />
				</xsl:attribute>
				<xsl:value-of  select="@tope_tipo" />
			</td>
			<td style='width:9%; white-space:nowrap;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@origen" />
				</xsl:attribute>
				<xsl:value-of  select="@origen" />
			</td>
			<td style='width: 5%; white-space:nowrap'>
				<xsl:choose>
					<xsl:when test="@movs_propios = 'True'">
						Si
					</xsl:when>
					<xsl:otherwise>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='width: 5%; white-space:nowrap'>
				<xsl:choose>
					<xsl:when test="@vigente = 'True'">
						Si
					</xsl:when>
					<xsl:otherwise>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='width: 8%; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tipo_periodo" />
				</xsl:attribute>
				<xsl:value-of  select="@tipo_periodo" />
			</td>
			<td style='width: 9%; white-space:nowrap; text-align:right'>
				<xsl:value-of select="foo:FechaToSTR(string(@fe_alta))"/>
			</td>
			<td style='width: 3%; white-space:nowrap; text-align:center'>
				<xsl:attribute name="title">
					Editar
				</xsl:attribute>
				<img src="/FW/image/icons/editar.png" style="cursor: pointer;">
					<!--<xsl:attribute name="onclick">editar(<xsl:value-of  select="@nro_tope_def" />, '<xsl:value-of  select="@tope_def" />', '<xsl:value-of  select="@nro_tope_tipo" />', '<xsl:value-of  select="@nro_tope" />', '<xsl:value-of  select="@vigente" />', '<xsl:value-of  select="@tipo_periodo" />', '<xsl:value-of  select="@id_tipo_alarma" />', '<xsl:value-of  select="@origen" />', '<xsl:value-of  select="@tipos_movs" />')</xsl:attribute>-->
					<xsl:attribute name="onclick">editar(<xsl:value-of  select="@nro_tope_def" />, '<xsl:value-of  select="@tope_def" />', '<xsl:value-of  select="@nro_tope_tipo" />', '<xsl:value-of  select="@nro_tope" />', '<xsl:value-of  select="@vigente" />', '<xsl:value-of  select="@tipo_periodo" />', '<xsl:value-of  select="@id_tipo_alarma" />', '<xsl:value-of  select="@origen" />', '<xsl:value-of  select="@movs_propios" />')</xsl:attribute>
				</img>
			</td>
			<td style='width: 3%; white-space:nowrap; text-align:center'>
				<xsl:attribute name="title">
					Eliminar
				</xsl:attribute>
				<img src="/FW/image/icons/eliminar.png" style="cursor: pointer;">
					<xsl:attribute name="onclick">
						parent.eliminar(<xsl:value-of  select="@nro_tope_def" />)
					</xsl:attribute>
				</img>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


