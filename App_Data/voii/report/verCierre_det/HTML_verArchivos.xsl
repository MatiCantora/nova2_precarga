<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />

    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Seleccionar Entidades</title>
              <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
              <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
              <script type="text/javascript" src="/FW/script/swfobject.js"></script>
              <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
              <script type="text/javascript" src="/FW/script/nvFW.js"></script>
              <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
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

				    function editar(id_cierre_def) {
				        window.parent.editarCierre(id_cierre_def)
				    }


				    function window_onresize() {
				        try {

				            var dif = Prototype.Browser.IE ? 14 : 7
				            var body_height = $$('body')[0].getHeight()
				            var tbCabe_height = $('tbCabe').getHeight()
				            //var div_pag_height = $('div_pag').getHeight()

				            $('divDetalle').setStyle({
				                height: body_height - tbCabe_height - dif + 'px'
				            })

				            $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
				        } catch (e) {}
				    }

				    function tdScroll_hide_show(show) {
				        var i = 1
				        while (i <= campos_head.recordcount) {
				            if (show && $('tdScroll' + i) != undefined)
				                $('tdScroll' + i).show()

				            if (!show && $('tdScroll' + i) != undefined)
				                $('tdScroll' + i).hide()

				            i++
				        }
				    }

				    function window_onload() {
				        window_onresize()
				    }

				    function MostrarArchivos(pos) {
				        var tb = eval('document.all.tb' + pos)
				        var imgG = eval('document.all.img_' + pos)
				        if (tb.style.display == 'none') {
				            imgG.src = '../../meridiano/image/icons/menos.gif'
				            tb.style.display = 'inline'
				        } else {
				            imgG.src = '../../meridiano/image/icons/mas.gif'
				            tb.style.display = 'none'
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
                <div id="divDetalle" style="width:100%;height:410px;overflow:auto">
                    <table class="tb1 highlightEven highlightTROver" id="tbDetalle">
						<xsl:apply-templates select="xml/rs:data/z:row" >
							<xsl:sort select="carpeta"/>
						</xsl:apply-templates>	
						
                    </table>
                </div>
              			
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="carpeta" select="@carpeta"/>
		<xsl:variable name="pos" select="position()"/>
		<xsl:variable name="carpeta_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@carpeta"/>		
		<xsl:if test="$carpeta != $carpeta_ant or $pos = 1">
			<table class="tb1" >
			<tr>
				<td style="width:15px;height:15px" align="center">
					<a>
						<xsl:attribute name="style">cursor:hand</xsl:attribute>
						<xsl:attribute name='onclick'>return MostrarArchivos(<xsl:value-of select='$pos'/>)</xsl:attribute>
						<img border='0' src='../../meridiano/image/icons/mas.gif'><xsl:attribute name="id">img_<xsl:value-of  select="$pos" /></xsl:attribute></img>
					</a>
				</td>
				<td>
					<xsl:value-of select="$carpeta"/>
				</td>
			</tr>				
			</table>
			<table class="tb1">
				<xsl:attribute name="id">tb<xsl:value-of select="$pos"/></xsl:attribute>
				<xsl:attribute name="style">display:none</xsl:attribute>
				<xsl:apply-templates select="/xml/rs:data/z:row[@carpeta = $carpeta]" mode="detalle" />
			</table>
		</xsl:if>
	</xsl:template>
	<xsl:template match="z:row" mode="detalle">
		<tr>
			<td>&#160;&#160;&#160;&#160;&#160;</td>
			<td style='text-align: left; width: 40%'>
				<xsl:value-of select="@transferencia"/>
			</td>
			<td style="text-align:left; width:65%">
				<img style="width:16px;height:16px">
					<xsl:attribute name="src">
						<xsl:choose>
							<xsl:when test="@extension='pdf'">../../meridiano/image/icons/pdf.gif</xsl:when>
							<xsl:when test="@extension='xls'">../../meridiano/image/icons/excel.gif</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</img>
				<xsl:text>  </xsl:text>
				<a  target='_blank'>
					<xsl:attribute name='href'>/fw/scripts/pvGet_file_path.aspx?path=<xsl:value-of select ='@ruta_archivo' /></xsl:attribute>
					
					<xsl:value-of select="@nombre_archivo" />
				</a>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>