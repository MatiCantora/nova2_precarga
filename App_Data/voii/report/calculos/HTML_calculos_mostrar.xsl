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
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}
		
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Calculos</title>
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
				<script type="text/javascript" language="javascript" >
                				
				<![CDATA[ 

						function window_onload()
						{
							window_onresize()
						}
	
						function window_onresize()
						{
						try
						{

						var dif = Prototype.Browser.IE ? 5 : 2
						var body_height = $$('body')[0].getHeight()
						var tbCabe_height = $('tbCabe').getHeight()
						var div_pag_height = $('div_pag').getHeight()
                    
						$('divDetalle').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})

						$('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
						}
						catch(e){}
                    
						campos_head.resize('tbCabe','tbDetalle')
						}

						function tdScroll_hide_show(show)
						{
						var i = 1
						while(i <=  campos_head.recordcount)
						{
						if(show &&  $('tdScroll'+ i) != undefined)
						$('tdScroll'+ i).show()

						if(!show &&  $('tdScroll'+ i) != undefined)
						$('tdScroll'+ i).hide()

						i++
						}
						}
            
            function nodo_onclick(id_calc_cab)
						{
							var div = $('trContenedor' + id_calc_cab)
							var img = $('img' + id_calc_cab)
							if (div.style.display == 'none')
							{
									//div.setStyle({ 'height':'200px' })
									//div.show()
									img.src = '/fw/image/tTree/menos.jpg'
									div.show()
									verDetalleCalculo(id_calc_cab)
							}
							else
								{
									img.src = '/fw/image/tTree/mas.jpg'
									div.hide()
								}
              }
              
              function verDetalleCalculo(id_calc_cab)
							{
									var filtro = "<id_calc_cab type='igual'>" + id_calc_cab + "</id_calc_cab>"
                            
									var filtroXML = parent.nvFW.pageContents.filtro_ver_calc_det
									var filtroWhere = "<criterio><select ><campos></campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"
   
									nvFW.exportarReporte({ 
										filtroXML: filtroXML,
										filtroWhere: filtroWhere,
										path_xsl: 'report\\calculos\\HTML_calculos_detalle_mostrar.xsl',
										formTarget: 'iFrameDetalleCalculo' + id_calc_cab,
										bloq_contenedor: $('iFrameDetalleCalculo' + id_calc_cab),
										cls_contenedor: 'iFrameDetalleCalculo' + id_calc_cab,
										nvFW_mantener_origen: true,
										id_exp_origen: 0
									})
							}
              
              function calculo_editar(id_calc_det, id_calc_cab) {
								//if (id_calc_det != 0) {
										/////
										if (!parent.nvFW.tienePermiso("permisos_calculos", 1)) {
												alert("No posee permisos para realizar la operación.")
												return
										} 

										var win = nvFW.createWindow({
												className: 'alphacube',
												url: '/voii/calculos/calculos_detalle_ABM.aspx?id_calc_det=' + id_calc_det + '&id_calc_cab=' + id_calc_cab,
												title: '<b>Editar Detalle Cálculo</b>',
												resizable: true,
												height : 500,
												width : 1100,
												minimizable : true,
												maximizable : false,
												draggable : false,
												resizable : false,
												onClose: function (win) {
														if (win.options.userData.hayModificacion)
																verDetalleCalculo(win.options.userData.id_calc_cab)
												}
										})
										win.options.userData = { hayModificacion : false }
										win.showCenter(true)
								//}
						}
                    
						]]>
				</script>
				<style type="text/css">
						.tr_cel TD {
						background-color: #F0FFFF !Important
						}
				</style>			
			</head>
			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">				
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
            <td style='text-align: center; width:5%' nowrap='true'>-</td>
						<td style='text-align: center; width: 5%'>
							<script type="text/javascript">campos_head.agregar('ID', 'true', 'id_calc_cab')</script>
						</td>
						<td style='text-align: center; width: 40%'>
							<script type="text/javascript">campos_head.agregar('Cálculo', 'true', 'calc_cab')</script>
						</td>
						<td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('Fe. Desde', 'true', 'fe_desde_cab')</script>
						</td>
						<td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('Fe. Hasta', 'true', 'fe_hasta_cab')</script>
						</td>
						<td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('Tipo de Persona', 'true', 'nro_tipo_persona')</script>
						</td>
            <td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('ID Cálculo', 'true', 'id_calculo')</script>
						</td>
						<!--<td style='text-align: center; width: 20%'>
							<script type="text/javascript">campos_head.agregar('Código', 'true', 'parametro')</script>
						</td>-->
						<td style='text-align: center; width: 5%'>-</td>
						<td style='text-align: center; width: 5%'>-</td>
					</tr>									
				</table>
        <div id="divDetalle" style="width:100%;overflow:auto">
          <table class="tb1 highlightEven highlightTROver layout_fixed" id="tbDetalle">
						<xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" class="divPages">
            <script type="text/javascript">
                document.write(campos_head.paginas_getHTML())
            </script>
        </div>
		</body>
	</html>
</xsl:template>
  
<xsl:template match="z:row">
		<xsl:variable name="conta_pendientes" select="@contar"/>
      <xsl:variable name="pos" select="position()"/>
		<tr>
      <xsl:attribute name="id">tr_ver<xsl:value-of select="@id_calc_cab"/></xsl:attribute> 
      <td class='Tit1' style="width:5% !Important;text-align:center">
          <xsl:attribute name="style">cursor:hand;cursor:pointer;text-align:center</xsl:attribute>
          <img src='/fw/image/tTree/mas.jpg' border='0' align='absmiddle' hspace='0'>
              <xsl:attribute name="id">img<xsl:value-of select="@id_calc_cab"/></xsl:attribute>
              <xsl:attribute name='onclick'>nodo_onclick('<xsl:value-of select="@id_calc_cab"/>')</xsl:attribute>
          </img>
      </td>
      
			<td style='text-align: right; width:5%'>
				<xsl:value-of  select="@id_calc_cab" />
			</td>
			<td style='text-align: left; width: 40%'>
				<xsl:attribute name='title'>
					<xsl:value-of  select="@calc_cab" />
				</xsl:attribute>
        <xsl:value-of  select="@calc_cab" />
			</td>
			<td style='text-align: center; width: 10%'>
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_desde))" />
			</td>
      <td style='text-align: center; width: 10%'>
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_hasta))" />
			</td>
			<td style='text-align: left; width: 10%'>
				<xsl:value-of  select="@tipo_persona" />
			</td>
      <td style='text-align: left; width: 10%'>
				<xsl:value-of  select="@calculo" />
			</td>
			<!--<td style='text-align: left; width: 20%'>
					<xsl:value-of  select="@parametro" />
			</td>-->
			<td style='text-align: center; width: 5%'>
        <img title="Editar" src="/voii/image/icons/editar.png" style="cursor:pointer">
					<xsl:attribute name="onclick">
            parent.calculo_abm('<xsl:value-of select="@id_calc_cab"/>', '<xsl:value-of select="@calc_cab"/>', '<xsl:value-of select="foo:FechaToSTR(string(@fe_desde))"/>', '<xsl:value-of select="foo:FechaToSTR(string(@fe_hasta))"/>', '<xsl:value-of select="@nro_tipo_persona"/>', '<xsl:value-of select="@id_calculo"/>')
          </xsl:attribute>
        </img>
			</td>
      <td style='text-align: center; width: 5%'>
        <img title="Nuevo Detalle" src="/voii/image/icons/modulo.png" style="cursor:pointer">
					<xsl:attribute name="onclick">
            calculo_editar(0, '<xsl:value-of select="@id_calc_cab"/>')
          </xsl:attribute>
        </img>
			</td>
		</tr>			
		<tr>
		<xsl:attribute name='id'>trContenedor<xsl:value-of select="@id_calc_cab"/></xsl:attribute>
        <xsl:attribute name='style'>display:none</xsl:attribute>
          <td style="width:12px !Important; text-align:center;vertical-align:middle">&#160;</td>
          <td colspan="8">
              <iframe style="width:100%;height:100%;border:none;">
                <xsl:attribute name='name'>iFrameDetalleCalculo<xsl:value-of select="@id_calc_cab"/></xsl:attribute>
                <xsl:attribute name='id'>iFrameDetalleCalculo<xsl:value-of select="@id_calc_cab"/></xsl:attribute>
              </iframe>
          </td>
    </tr>	  
	</xsl:template>	
  
</xsl:stylesheet>
