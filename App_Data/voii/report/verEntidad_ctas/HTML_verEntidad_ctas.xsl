<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:include href="..\..\..\voii\report\xsl_includes\js_formato.xsl"/>
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title></title>
				<!--#include virtual="../../FW/scripts/pvAccesoPagina.asp"-->
				<!--#include virtual="../../FW/scripts/pvUtiles.asp"-->
				<link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>
				<link href="../../FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
				<link href="../../FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />
				<link href="../../FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />
				<link href="../../FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

				<script type="text/javascript" src="../../FW/script/prototype.js"></script>
				<script type="text/javascript" src="../../FW/script/window.js"></script>
				<script type="text/javascript" src="../../FW/script/effects.js"></script>

				<script type="text/javascript" src="../../FW/script/acciones.js"></script>
				<script type="text/javascript" src="../../FW/script/imagenes_icons.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/mnuSvr.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/DMOffLine.js"></script>
				<script type="text/javascript" src="../../FW/script/rsXML.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/tXML.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/nvFW.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/tCampo_head.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/tCampo_def.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/utiles.js" language="JavaScript"></script>
				<script type="text/javascript" src="../../FW/script/tSesion.js"></script>
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
			<script type='text/javascript' language="javascript" >
			<![CDATA[
       			          
				function window_onload()
				{
				window_onresize()
				}
				
				function seleccionar(indice)
					{
					$('tr_ver'+indice).addClassName('tr_cel')
					}
                                 
				function no_seleccionar(indice)
					{
					$('tr_ver'+indice).removeClassName('tr_cel')
					}
					
				function window_onresize()
                    {
                    try
                    {

                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_height = $$('body')[0].getHeight()
                    var tbCabe_height = $('tbCabe').getHeight()

                    $('divDetalle').setStyle({height: body_height - tbCabe_height - dif + 'px'})

                    $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                    }
                    catch(e){}
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
					
				function RCuenta_onclick(id_cuenta)
					{
					window.parent.Seleccionar_Cuenta(id_cuenta)
					}
					
			]]>
        </script>
		</head>
		<body style="width:100%;height:100%;overflow:auto" onresize="window_onresize()" onload="return window_onload()">
		<table class="tb1" id="tbCabe">
			<tr class="tbLabel">
				<td style='text-align: center; width:30px'></td>
				<td style='text-align: center; width:340px'>Banco - Sucursal</td>					
				<td style='text-align: center; width:60px'>Tipo Cta</td>                  
				<td style='text-align: center; width:200px'>Nro. Cuenta</td>
				<td style='text-align: center' nowrap='true'>Hab.</td>				
				<td style="width:20px">&#160;</td>
			</tr>
		</table>
		<div id="divDetalle" style="width:100%;height:160px;overflow:auto">
				<table class="tb1" id="tbDetalle">
					<xsl:apply-templates select="xml/rs:data/z:row" />
				</table>
		</div>
		</body>
		</html>
	</xsl:template>
  
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
	<tr>
		<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
		<xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
		<xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <td style='text-align: center; width:28px'>
				<input type='hidden'>
					<xsl:attribute name='value'><xsl:value-of select="$pos"/></xsl:attribute>
					<xsl:attribute name="id">cuenta_<xsl:value-of select="@id_cuenta"/></xsl:attribute>
				</input>
				<input type='hidden'>
					<xsl:attribute name='value'><xsl:value-of select="@id_cuenta_old"/></xsl:attribute>
					<xsl:attribute name="id">cuenta_old_<xsl:value-of select="$pos"/></xsl:attribute>
				</input>
				<input type='hidden'>
					<xsl:attribute name='value'><xsl:value-of select="@nro_banco"/></xsl:attribute>
					<xsl:attribute name="id">nro_banco_<xsl:value-of select="$pos"/></xsl:attribute>
				</input>
				<input type='hidden'>
					<xsl:attribute name='value'><xsl:value-of select="@id_banco_sucursal"/></xsl:attribute>
					<xsl:attribute name="id">id_banco_sucursal_<xsl:value-of select="$pos"/></xsl:attribute>
				</input>
				<input type='radio' name='RCuenta' style='border:none'>
						<xsl:attribute name='onclick'>RCuenta_onclick('<xsl:value-of select="@id_cuenta"/>')</xsl:attribute>
						<xsl:attribute name='value'><xsl:value-of select="$pos"/></xsl:attribute>
						<xsl:attribute name="id">RCuenta<xsl:value-of select="@id_cuenta"/></xsl:attribute>
						<xsl:if test="@id_cuenta = @id_cuenta_sel"><xsl:attribute name="checked"/></xsl:if>							
				</input>
            </td>
            <td style='text-align: left; width:338px'><xsl:value-of select="@banco"/> - <xsl:value-of select="@banco_sucursal"/></td>            			
			<td style='text-align: right; width:58px'><xsl:value-of select="@tipo_cuenta_desc"/></td>
			<td style='text-align: right; width:198px'><xsl:value-of select="@nro_cuenta" /></td>
			<td style='text-align: right;' nowrap='true'>							
				<xsl:choose>
					<xsl:when test='string(@habilitada) ="True"'>Si</xsl:when>
					<xsl:otherwise>No</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='width:20px !Important'>
				<xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>
				&#160;&#160;
			</td>
			</tr>
	</xsl:template>
</xsl:stylesheet>