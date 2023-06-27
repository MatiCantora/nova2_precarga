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
					  
					$('tblog').getHeight() - $('tabla_contenido').getHeight() >= 0 ? $('tdScroll').hidden = false : $('tdScroll').hidden = true

				}
				
				catch (e) {}
            } 
           
          ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden">

				<table class="tb1 layout_fixed" id="tbCabecera">
					<tr class='tbLabel'>
						<td style='width:14%; white-space:nowrap; text-align:center;' title='PSP'>
							<script>campos_head.agregar('PSP', true,'id_cliente')</script>
						</td>
						<td style='width:10%; white-space:nowrap; text-align:center;' title='Tipo Documento'>
							<script>campos_head.agregar('Tipo documento', true,'tipo_docu')</script>
						</td>
						<td style='width:10%; white-space:nowrap; text-align:center;' title='Nro Documento'>
							<script>campos_head.agregar('Nro Documento Cliente', false,'nro_docu')</script>
						</td>
						<td style='width:10%; white-space:nowrap; text-align:center;' title='CUIT/CUIL Cliente'>
							<script>campos_head.agregar('CUIT/CUIL Cliente', false,'cuitcuil')</script>
						</td>
						<td style='width:28%; white-space:nowrap; text-align:center;' title='Razón Social Cliente'>
							<script>campos_head.agregar('Razón social Cliente', true,'razon_social')</script>
						</td>
						<td style='width:7%; white-space:nowrap; text-align:center;' title='Tipo Persona'>
							<script>campos_head.agregar('Tipo persona', true,'tipo_persona')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center;' title='¿Es Gran Cliente?'>
							<script>campos_head.agregar('Gran cliente', true,'gran_cliente')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center;' title='Aceptado'>
							<script>campos_head.agregar('Aceptado', true,'aceptado')</script>
						</td>
						<td style='width:3%; white-space:nowrap; text-align:center;' title='Editar'>Editar</td>
						<td style='width:3%; white-space:nowrap; text-align:center;' title='Eliminar'>Eliminar</td>
						<td style='width:3%; white-space:nowrap; text-align:center;' title='Consultar historial de modificaciones'>Histórico</td>
						<td id='tdScroll' hidden='true' style='width:1%'></td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='tabla_contenido' style='width: 100%;overflow:auto'>
					<table class="tb1 highlightOdd layout_fixed" id="tblog" name="tblog">
						<xsl:apply-templates select="xml/rs:data/z:row" />
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
	<xsl:template match="z:row">
		<tr>
			<td style='width: 14%; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cliente_razon_social" />
				</xsl:attribute>
				<xsl:value-of  select="@cliente_razon_social" />
			</td>
			<td style='width: 10%; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tipo_docu_desc" />
				</xsl:attribute>
				<xsl:value-of  select="@tipo_docu_desc" />
			</td>
			<td style='width: 10%; text-align:right; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@nro_docu" />
				</xsl:attribute>
				<xsl:value-of select="@nro_docu"/>
			</td>
			<td style='width: 10%; text-align:right; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cuitcuil" />
				</xsl:attribute>
				<xsl:value-of select="@cuitcuil"/>
			</td>
			<td style='width: 28%; white-space:nowrap'>
				<xsl:attribute name="title"><xsl:value-of  select="@razon_social" /></xsl:attribute>
				<xsl:value-of  select="@razon_social" />
			</td>
			<td style='width: 7%; white-space:nowrap'>
				 <xsl:if test="@tipo_persona='PJ'">
					 <xsl:attribute name="title">
						 Jurídica
					 </xsl:attribute>
				  Jurídica
				</xsl:if>
				<xsl:if test="@tipo_persona='PH'">
					<xsl:attribute name="title">
						Física
					</xsl:attribute>
				  Física
				</xsl:if>
			</td>
			<td style='width: 6%; white-space:nowrap'>
				<xsl:choose>
				  <xsl:when test="@gran_cliente='True'">
					  <xsl:attribute name="title">
						  Si
					  </xsl:attribute>
					Si
				  </xsl:when>
				  <xsl:otherwise>
					  <xsl:attribute name="title">
						  No
					  </xsl:attribute>
					No
				  </xsl:otherwise>
				</xsl:choose>
			</td>
			<td style="width:6%">
				<xsl:choose>
					<xsl:when test="@aceptado=1">
						<xsl:attribute name="title">
							Si
						</xsl:attribute>
						Si
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="title">
							No
						</xsl:attribute>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style="text-align:center; width:3%">
				<img>
					<xsl:attribute name="onclick">parent.editar_cliente('M', '<xsl:value-of  select="@id_cliente" />' , <xsl:value-of  select="@tipo_docu" />, '<xsl:value-of  select="@nro_docu" />')</xsl:attribute>
					<xsl:attribute name="src">/voii/image/icons/editar.png</xsl:attribute>
					<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Editar</xsl:attribute>
				</img>
			</td>
			<td style="text-align:center; width:3%">
				<img>
					<xsl:attribute name="onclick">parent.eliminar('<xsl:value-of  select="@id_cliente" />' , <xsl:value-of  select="@tipo_docu" />, '<xsl:value-of  select="@nro_docu" />')</xsl:attribute>
					<xsl:attribute name="src">/voii/image/icons/eliminar.png</xsl:attribute>
					<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Eliminar</xsl:attribute>
				</img>
			</td>
			<td style="text-align:center; width:3%">
				<img>
					<xsl:attribute name="onclick">
						parent.ventana_historico('<xsl:value-of  select="@id_cliente" />', <xsl:value-of  select="@cuitcuil" />)
					</xsl:attribute>
					<xsl:attribute name="src">/voii/image/icons/historico.png</xsl:attribute>
					<xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
					<xsl:attribute name="title">Histórico</xsl:attribute>
				</img>
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


