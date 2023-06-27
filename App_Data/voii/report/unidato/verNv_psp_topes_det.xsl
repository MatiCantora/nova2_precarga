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
					let altura = $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('divPages').getHeight();
					$('tabla_contenido').style.height = altura + 'px';
					$('tblog').getHeight() - $('tabla_contenido').getHeight() >= 0 ? $('tdScroll').hidden = false : $('tdScroll').hidden = true;
				  }
				  
				  catch (e) {}

            } 
			
			
			function editar_proporciones() {
					var win = nvFW.createWindow({ className: 'alphacube',
                        title: 'Modificar proporciones de tope',
                        minimizable: false,
                        maximizable: false,
                        draggable: false,
                        resizable: false,
                        recenterAuto: false,
                        width: 400,
                        height: 140,
                        onClose: function () {
							document.getElementById('col_nuevas_proporciones').hidden = true;
							for (let i=1; i <= campos_head.recordcount; i++)
								document.getElementById('nueva_proporcion'+i).hidden = true;
							parent.buscar();
                        }
                    });
				
					document.getElementById('col_nuevas_proporciones').hidden = false
					for (let i=1; i <= campos_head.recordcount; i++){
						document.getElementById('nueva_proporcion'+i).hidden = false
					}
                    win.setURL('/voii/unidato/cambio_topes_lote.aspx')
                    win.showCenter(true)
			}
			
			function topes_modificados(signo, porcentaje) {
					let strXMLtopes = "<?xml version='1.0' encoding='ISO-8859-1'?><root>"
					let proporcion_actual, proporcion_nueva, nro_topes_det;

					for (i=1; i <= campos_head.recordcount; i++){
						proporcion_actual = parseFloat($('proporcion_tope'+i).innerText);
						nro_topes_det = $('tope'+i).innerText;
						
						if (signo == '+')
							proporcion_nueva = proporcion_actual * porcentaje / 100 + proporcion_actual;
						else if (signo == '-')
							proporcion_nueva = proporcion_actual - proporcion_actual * porcentaje / 100;

						strXMLtopes += "<tope nro_topes_det='" + nro_topes_det + "' nueva_proporcion='" + proporcion_nueva.toFixed(4) + "'></tope>";
						$('nueva_proporcion'+i).innerText =  proporcion_nueva.toFixed(4);						
					}
					
					strXMLtopes += "</root>";
					return strXMLtopes;
			}         
					   
		   
          ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden">
				<table class="tb1 layout_fixed" id="tbCabecera">
					<tr class='tbLabel'>
						<td style='width:7%; white-space:nowrap; text-align:center' title='Tipo de persona'>
							<script>campos_head.agregar('Tipo persona', true,'tipo_persona')</script>
						</td>
						<td style='width:29%; white-space:nowrap; text-align:center' title='Definición de Tope'>
							<script>campos_head.agregar('Definición de Tope', true,'tope_def')</script>
						</td>
						<td style='width:7%; white-space:nowrap; text-align:center' title='Tipo de tope'>
							<script>campos_head.agregar('Tipo de tope', true,'tope_tipo')</script>
						</td>
						<td style='width:7%; white-space:nowrap; text-align:center' title='Tope'>
							<script>campos_head.agregar('Tope', true,'tope')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center' title='Tipo de período'>
							<script>campos_head.agregar('Tipo período', true,'tipo_periodo')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center' title='Gran Cliente'>
							<script>campos_head.agregar('Gran cliente', true,'gran_cliente')</script>
						</td>
						<td style='width:9%; white-space:nowrap; text-align:center' title='CUIT/CUIL'>
							<script>campos_head.agregar('CUIT/CUIL', true,'cuitcuil')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center' title='Fecha de Alta'>
							<script>campos_head.agregar('Fe. Alta', true,'fecha_alta')</script>
						</td>
						<td style='width:6%; white-space:nowrap; text-align:center' title='Fecha de Baja'>
							<script>campos_head.agregar('Fe. Baja', true,'fecha_baja')</script>
						</td>
						<td style='width:7%; white-space:nowrap; text-align:center' title='Proporción tope'>
							<script>campos_head.agregar('Proporción tope', true,'proporcion_tope')</script>
						</td>
						<td style='width:7%; white-space:nowrap; text-align:center;' id='col_nuevas_proporciones' hidden='true'>
							Nueva Proporción
						</td>
						<td style='width:2%; white-space:nowrap; text-align:center'></td>
						<td id='tdScroll' hidden='true' style='width:1%'></td>
						<td hidden='true'></td>
					</tr>
				</table>

				<!--DATOS-->
				<div id='tabla_contenido' style='width: 100%;overflow:auto'>
					<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tblog" name="tblog">
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>

				<!-- DIV DE PAGINACION -->
				<div id="divPages" class="divPages" style="position: absolute; bottom: 0px; height: auto">
					<table class="tb1 layout_fixed">
						<td colspan="9" style='background-color: #A1A1A3;'></td>
						<td colspan='3' style='text-align:center' title='Editar proporción tope por lote'>
							<button style='width:100%;' onclick="editar_proporciones()">Editar proporción tope por lote</button>
						</td>
						<td colspan="1" style='background-color: #A1A1A3;'></td>
					</table>
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
		<tr>
			<xsl:choose>
				<xsl:when test="@no_vigente = 1">
					<xsl:attribute name="style">color:darkred</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<td style='width: 7%; white-space:nowrap;'>
				<xsl:choose>
					<xsl:when test="@tipo_persona = 'PJ'">
						<xsl:attribute name="title">
							Persona Jurídica
						</xsl:attribute>
						Persona Jurídica
					</xsl:when>
					<xsl:when test="@tipo_persona = 'PH'">
						<xsl:attribute name="title">
							Persona Humana
						</xsl:attribute>
						Persona Humana
					</xsl:when>
				</xsl:choose>
			</td>
			<td style='width: 29%; white-space:nowrap;text-decoration: underline; cursor:pointer;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_def" />
				</xsl:attribute>
				<xsl:attribute name="onclick">
					parent.ver_tope_def(<xsl:value-of  select="@nro_tope_def" />)
				</xsl:attribute>
				<xsl:value-of  select="@nro_tope" /> - <xsl:value-of  select="@tope_def" />	
			</td>
			<td style='width: 7%; white-space:nowrap;'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope_tipo" />
				</xsl:attribute>
				<xsl:value-of  select="@tope_tipo" />
			</td>
			<td style='width: 7%; white-space:nowrap; text-align:right'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tope" />
				</xsl:attribute>
				<xsl:value-of  select="@tope" />
			</td>
			<td style='width: 6%; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tipo_periodo" />
				</xsl:attribute>
				<xsl:value-of  select="@tipo_periodo" />
			</td>
			<td style='width: 6%; white-space:nowrap'>
				<xsl:choose>
					<xsl:when test="@gran_cliente = 'True'">
						<xsl:attribute name="title">
							Si es gran cliente
						</xsl:attribute>
						Si
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="title">
							No es gran cliente
						</xsl:attribute>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='width: 9%; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@cuitcuil" />
			</td>
			<td style='width: 6%; white-space:nowrap; text-align:right'>
				<xsl:attribute name="title">
					<xsl:value-of select="foo:FechaToSTR(string(@fecha_alta))"/>
				</xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@fecha_alta))"/>
			</td>
			<td style='width: 6%; white-space:nowrap; text-align:right'>
				<xsl:attribute name="title">
					<xsl:value-of select="foo:FechaToSTR(string(@fecha_actual))"/>
				</xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@fecha_baja))"/>
			</td>
			<td style='width: 7%; white-space:nowrap; text-align:right'>
				<xsl:attribute name="id">proporcion_tope<xsl:value-of select="$pos"/>
				</xsl:attribute>
				<xsl:attribute name="title"><xsl:value-of  select="@proporcion_tope" /></xsl:attribute>
				<xsl:value-of select="string(format-number(@proporcion_tope,'0.0000'))" />
			</td>
			<td style='width: 7%; white-space:nowrap; text-align:right;' hidden='true'>
				<xsl:attribute name="id">nueva_proporcion<xsl:value-of select="$pos"/></xsl:attribute>
				<xsl:attribute name="bgcolor">#F5F58F</xsl:attribute>
			</td>
			<td style='width: 2%; white-space:nowrap; text-align:center'>
				<xsl:attribute name="title">Editar</xsl:attribute>
				<img src="../image/icons/editar.png" style="cursor: pointer;">
					<xsl:attribute name="onclick">parent.editar('M',<xsl:value-of  select="@nro_tope_def" />, '<xsl:value-of  select="@id_cliente" />','<xsl:value-of  select="@tipo_persona" />', '<xsl:value-of  select="@gran_cliente" />', '<xsl:value-of  select="@proporcion_tope" />', '<xsl:value-of select="foo:FechaToSTR(string(@fecha_alta))"/>', '<xsl:value-of  select="@nv_login" />', <xsl:value-of  select="@nro_topes_det" />, '<xsl:value-of select="foo:FechaToSTR(string(@fecha_baja))"/>', <xsl:value-of  select="@cuitcuil" />)</xsl:attribute>
				</img>
			</td>
			<td hidden="true">
				<xsl:attribute name="id">tope<xsl:value-of select="$pos"/>
				</xsl:attribute>
				<xsl:value-of  select="@nro_topes_det" />
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>