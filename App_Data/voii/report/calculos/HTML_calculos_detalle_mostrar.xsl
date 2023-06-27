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
						<td style='text-align: center; width: 5%'>
							<script type="text/javascript">campos_head.agregar('ID', 'true', 'id_calc_det')</script>
						</td>
						<td style='text-align: center; width: 40%'>
							<script type="text/javascript">campos_head.agregar('Detalle', 'true', 'calc_det')</script>
						</td>
						<!--<td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('Fe. Desde', 'true', 'fe_desde_det')</script>
						</td>
						<td style='text-align: center; width: 10%'>
							<script type="text/javascript">campos_head.agregar('Fe. Hasta', 'true', 'fe_hasta_det')</script>
						</td>-->
						<td style='text-align: center; width: 20%'>
							<script type="text/javascript">campos_head.agregar('Tipo', 'true', 'id_tipo')</script>
						</td>
						<td style='text-align: center; width: 30%'>
							<script type="text/javascript">campos_head.agregar('Código', 'true', 'calc_id_tipo')</script>
						</td>
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
			<td style='text-align: center; width:5%'>
				<xsl:value-of  select="@id_calc_det" />
			</td>
			<td style='text-align: left; width: 40%'>
				<xsl:attribute name='title'>
					<xsl:value-of  select="@calc_det" />
				</xsl:attribute>
        <xsl:value-of  select="@calc_det" />
			</td>
			<!--<td style='text-align: center;; width: 10%'>
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_desde_det))" />
			</td>
      <td style='text-align: center; width: 10%'>
					<xsl:value-of  select="foo:FechaToSTR(string(@fe_hasta_det))" />
			</td>-->
			<td style='text-align: right; width: 20%'>
				<xsl:value-of  select="@id_tipo" />
			</td>
			<td style='text-align: left; width: 30%'>
					<xsl:value-of  select="@calc_id_tipo" />
			</td>
			<td style='text-align: center; width: 5%'>
                <img title="Editar" src="/fw/image/icons/editar.png" style="cursor:pointer">
					<xsl:attribute name="onclick">parent.calculo_editar('<xsl:value-of select="@id_calc_det"/>', '<xsl:value-of select="@id_calc_cab"/>')</xsl:attribute>
                </img>
			</td>
		</tr>			
	</xsl:template>	
  
</xsl:stylesheet>
