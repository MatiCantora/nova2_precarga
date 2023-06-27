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
				Page.contents("filtro_sub_detalle_operaciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_psp_alarmas_movimientos' cn='UNIDATO'><campos>tope_tipo,id_tope,tope_def,tipo_periodo,mes,anio,cantidad_obtenida,importe_obtenido,calc_tope,tit_razon_social,tit_cuitcuil,tit_cbu,tit_cvu,cont_razon_social,cont_cuitcuil,cont_tp,cont_gran_cliente,cont_tipo_cuenta,cont_cbu,cont_cvu,importe</campos><filtro></filtro><orden></orden></select></criterio>")
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
								  let altura = $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('tbResultado').getHeight() - $('divPages').getHeight();
								  $('tabla_contenido').style.height = altura + 'px';
								  
								  $('tblog').getHeight() - $('tabla_contenido').getHeight() >= 0 ? $('tdScroll').hidden = false : $('tdScroll').hidden = true
							  }
							  catch (e) {}
							  
					  }
					                  
				  ]]>
				</script>

			</head>
			<body onload="onload()" onresize="onresize()" style="width: 100%; overflow: auto">
				<table class="tb1" id="tbCabecera">
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Alarma Unidato
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@unidato_numero_alarma)" /> (Tipo Alarma: <xsl:value-of  select="(xml/rs:data/z:row/@ID_TIPO_ALARMA)" />)
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Alta Alarma:
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of select="foo:FechaToSTR(string(xml/rs:data/z:row/@FECHA_ALTA_ALARMA))"/>
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Días transcurridos:
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@DIAS_TRANSCURRIDOS)" />
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Tipo de tope:
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@tope_tipo)" />
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Definición de tope:
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@id_tope)" /> - <xsl:value-of  select="(xml/rs:data/z:row/@tope_def)" /> - (<xsl:value-of  select="(xml/rs:data/z:row/@origen)" />)
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Tipo de período:
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@tipo_periodo)" />
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Persona
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@razon_social)" /> - <xsl:value-of  select="(xml/rs:data/z:row/@cuitcuil)" /> (<xsl:value-of  select="(xml/rs:data/z:row/@tp)" />)
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								<xsl:choose>
									<xsl:when test="xml/rs:data/z:row/@nro_tope_tipo=3">
										Posicion tope
									</xsl:when>
									<xsl:otherwise>
										Valor tope
									</xsl:otherwise>
								</xsl:choose>
							</b>
						</td>

						<xsl:variable name="calc_tope" select="(xml/rs:data/z:row/@calc_tope)"/>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select='format-number($calc_tope,"###,###.00")' />
						</td>
					</tr>

					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Total Operado
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							$<xsl:value-of  select='format-number(xml/rs:data/z:row/@total,"###,###.00")' /> (<xsl:value-of  select='format-number(xml/rs:data/z:row/@calc_tope,"###,###.00")' />)

						</td>
					</tr>

					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Estado
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px;">
							<xsl:choose>
								<xsl:when test="(xml/rs:data/z:row/@ESTADO_SECUENCIA) = 'En Análisis'">
									<xsl:attribute name="style">background-color: #F5F58F !Important;</xsl:attribute>
								</xsl:when>
								<xsl:when test="(xml/rs:data/z:row/@ESTADO_SECUENCIA) = 'Justificada'">
									<xsl:attribute name="style">background-color: #6BBA70 !Important;</xsl:attribute>
								</xsl:when>
								<xsl:when test="(xml/rs:data/z:row/@ESTADO_SECUENCIA) = 'Falso Positivo'">
									<xsl:attribute name="style">background-color: #FF3300 !Important;</xsl:attribute>
								</xsl:when>
							</xsl:choose>
							<xsl:value-of  select="(xml/rs:data/z:row/@ESTADO_SECUENCIA)" />&#160;&#160;
							<img src="/FW/image/icons/cambio_estado.png" title="Cambiar estado" style="cursor:hand;cursor:pointer;">
								<xsl:attribute name="onclick">
									parent.abrirComentario()
								</xsl:attribute>
							</img>
						</td>
					</tr>
					<tr>
						<td class="Tit1" colspan="2" style="padding: 3px">
							<b>
								Observaciones
							</b>
						</td>
						<td class="Tit1" colspan="11" style="padding: 3px">
							<xsl:value-of  select="(xml/rs:data/z:row/@OBSERVACIONES)" />
						</td>
					</tr>
				</table>
				
				<div id='tabla_contenido' style='width: 100%;overflow:auto'>
					<table class="tb1 layout_fixed" style="position:sticky; top:0px">
						<tr class='tbLabel0'>
							<td style='width:130px; white-space:nowrap'>
								<xsl:attribute name="title">Tipo de movimiento</xsl:attribute>
								<script>campos_head.agregar('Tipo mov', true,'mov_tipo_desc')</script>
							</td>
							<td style='width:150px; white-space:nowrap'>
								<xsl:attribute name="title">Fecha de movimiento</xsl:attribute>
								<script>campos_head.agregar('Fecha', true,'mov_fecha')</script>
							</td>
							<td style='width:220px; white-space:nowrap'>
								<xsl:attribute name="title">Titular</xsl:attribute>
								<script>campos_head.agregar('Titular', true,'TIT_RAZON_SOCIAL')</script>
							</td>
							<td style='width:100px; white-space:nowrap'>
								<xsl:attribute name="title">Cuit titular</xsl:attribute>
								<script>campos_head.agregar('Cuit', false,'TIT_CUITCUIL')</script>
							</td>
							<td style='width:180px; white-space:nowrap'>
								<xsl:attribute name="title">CBU Titular</xsl:attribute>
								<script>campos_head.agregar('CBU', false,'TIT_CBU')</script>
							</td>
							<td style='width:180px; white-space:nowrap'>
								<xsl:attribute name="title">CVU Titular</xsl:attribute>
								<script>campos_head.agregar('CVU', false,'TIT_CVU')</script>
							</td>
							<td style='width:220px; white-space:nowrap'>
								<xsl:attribute name="title">Contraparte</xsl:attribute>
								<script>campos_head.agregar('Contraparte', true,'CONT_RAZON_SOCIAL')</script>
							</td>
							<td style='width:100px; white-space:nowrap'>
								<xsl:attribute name="title">CUIT Contraparte</xsl:attribute>
								<script>campos_head.agregar('CUIT', false,'CONT_CUITCUIL')</script>
							</td>
							<td style='width:180px; white-space:nowrap'>
								<xsl:attribute name="title">CBU Contraparte</xsl:attribute>
								<script>campos_head.agregar('CBU', false,'CONT_CBU')</script>
							</td>
							<td style='width:180px; white-space:nowrap'>
								<xsl:attribute name="title">CVU Contraparte</xsl:attribute>
								<script>campos_head.agregar('CVU', false,'CONT_CVU')</script>
							</td>
							<td style='width:100px; white-space:nowrap'>
								<xsl:attribute name="title">Importe</xsl:attribute>
								<script>campos_head.agregar('Importe', true,'IMPORTE')</script>
							</td>
						</tr>
					</table>

				<!--DATOS-->
					<table class="tb1 highlightOdd layout_fixed" id="tblog" name="tblog">
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>

				<!--SUMAS Y TOTALES-->
				<table class="tb1 layout_fixed" id="tbResultado">
					<tr>
						<td class="Tit1"  style='text-align: right; padding:3px'>
							<b>
								Cantidad:
							</b>
						</td>
						<td class="Tit1" style='width:20%; text-align: right;'>
							<b>
								<xsl:value-of select="xml/params/@recordcount"/>
							</b>
						</td>
					</tr>
					<tr>
						<td class="Tit1"  style='text-align: right; padding:5px'>
							<b>
								Importe total:
							</b>
						</td>
						<td class="Tit1" style='text-align: right;' >
							<xsl:attribute name="title">
								$<xsl:value-of  select='format-number(xml/rs:data/z:row/@total,"###,###.00")' /> (<xsl:value-of  select='format-number(xml/rs:data/z:row/@calc_tope,"###,###.00")' />)
							</xsl:attribute>
							<b>
								$<xsl:value-of  select='format-number(xml/rs:data/z:row/@total,"###,###.00")' /> (<xsl:value-of  select='format-number(xml/rs:data/z:row/@calc_tope,"###,###.00")' />)
							</b>
						</td>
					</tr>
				</table>

				<!-- DIV DE PAGINACION -->
				<div id="divPages" class="divPages" style="position: absolute; bottom: 0px; height: 0px;">
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
			<td style='width: 130px; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@mov_tipo_desc" />
				</xsl:attribute>
				<xsl:value-of  select="@mov_tipo_desc" />
			</td>
			<td style='width: 150px; white-space:nowrap'>
				<xsl:attribute name="title">
					<xsl:value-of select="foo:FechaToSTR(string(@mov_fecha))" /> - <xsl:value-of select="foo:HoraToSTR(string(@mov_fecha))" />
				</xsl:attribute>
				<xsl:value-of select="foo:FechaToSTR(string(@mov_fecha))" /> - <xsl:value-of select="foo:HoraToSTR(string(@mov_fecha))" />
			</td>
			<td style='width: 220px; white-space:nowrap; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_razon_social" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_razon_social" />
			</td>
			<td style='width: 100px; text-align:right; white-space:nowrap; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cuitcuil" />
			</td>
			<td style='width: 180px; text-align:right; white-space:nowrap; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cbu" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cbu" />
			</td>
			<td style='width: 180px; text-align:right; white-space:nowrap; background-color: #d8f8e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@tit_cvu" />
				</xsl:attribute>
				<xsl:value-of  select="@tit_cvu" />
			</td>
			<td style='width: 220px; white-space:nowrap; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_razon_social" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_razon_social" />
			</td>
			<td style='width: 100px; text-align:right; white-space:nowrap; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cuitcuil" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cuitcuil" />
			</td>
			<td style='width: 180px; text-align:right; white-space:nowrap; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cbu" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cbu" />
			</td>
			<td style='width: 180px; text-align:right; white-space:nowrap; background-color: #ffe4e1'>
				<xsl:attribute name="title">
					<xsl:value-of  select="@cont_cvu" />
				</xsl:attribute>
				<xsl:value-of  select="@cont_cvu" />
			</td>
			<td style='width: 100px; text-align:right; white-space:nowrap'>
				<xsl:attribute name="title">
					$<xsl:value-of select='format-number(@importe,"###,###.00")' />
				</xsl:attribute>
				$<xsl:value-of select='format-number(@importe,"###,###.00")' />
			</td>
		</tr>

	</xsl:template>
</xsl:stylesheet>


