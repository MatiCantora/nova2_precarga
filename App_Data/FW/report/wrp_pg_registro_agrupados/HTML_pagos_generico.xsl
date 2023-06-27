<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

    <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl" />
    
    <msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[ ]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<title>Ver Pagos</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

                <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
                <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

                <script language="javascript" type="text/javascript">
                    var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>

                    if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW
                </script>

                <script type="text/javascript" language="javascript">
                    <![CDATA[
                    function seleccionar_pago(nro_tipo_pago)
                    {
                        window.parent.editarPago(nro_tipo_pago)
                    }


                    function  window_onload()
                    {
                        window_onresize()
                    }


                    function window_onresize()
                    {
                        try
                        {
                            var body_height   = $$('body')[0].getHeight()
                            var tbCabe_height = $('tbCabe').getHeight()

                            $('divDetalle').setStyle({ height: body_height - tbCabe_height + 'px' })

                            tdScroll_hide_show($('tbDetalle').getHeight() > $('divDetalle').getHeight())
                        }
                        catch(e) {}
                    }


                    function tdScroll_hide_show(show)
                    {
                        show ? $('tdScroll').show() : $('tdScroll').hide()
                    }
                    ]]>
                </script>
                <style type="text/css">
                    .tr_cel TD { background-color: #F0FFFF !Important; }
                    .centrado tr td { text-align: center; }
                </style>
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
				<form name="frmPagos" id="frmPagos" style="width: 100%; height: 100%; overflow: hidden;">
					<table class="tb1 centrado" id="tbCabe">
					    <tr class="tbLabel">
                            <td style="width: 80px;">ID</td>
						    <td style='width: 110px'>
                                <script type="text/javascript">campos_head.agregar('Envio', 'true', 'nro_envio_gral')</script>
						    </td>
						    <td>
                                <script type="text/javascript">campos_head.agregar('Razón Social', 'true', 'razon_social')</script>
						    </td>
                            <td style='width: 200px;'>
                                <script type="text/javascript">campos_head.agregar('Mutual', 'true', 'mutual')</script>
                            </td>
						    <td style='width: 100px'>
                                <script type="text/javascript">campos_head.agregar('Crédito', 'true', 'nro_credito')</script>
						    </td>
						    <td style='width: 110px'>Importe Pago</td>
						    <td style='width: 150px'>
                                <script type="text/javascript">campos_head.agregar('Concepto', 'true', 'pago_concepto')</script>
						    </td>
                            <td style='width: 80px'>Fecha</td>
						    <td style='width: 30px' title='Detalles'>D</td>
						    <td style='width: 30px' title='Pendientes'>P</td>
						    <td style='width: 30px'> - </td>
                            <td id='tdScroll' style="width: 14px; display: none;">&#160;</td>
					    </tr>
				    </table>
                    <div id="divDetalle" style="width: 100%; overflow: auto;">
                        <table class="tb1 highlightOdd highlightTROver" id="tbDetalle">
					        <xsl:apply-templates select="xml/rs:data/z:row" />
                        </table>
                    </div>
				</form>
			</body>
		</html>
	</xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
		<xsl:variable name="contador_pagos_pendientes" select="@contar" />

        <tr id="tr_ver{$pos}">
		    <xsl:choose>
			    <xsl:when test="$contador_pagos_pendientes > 0">
                    <xsl:attribute name='style'>color: blue;</xsl:attribute>
			    </xsl:when>
		    </xsl:choose>
			<input type="hidden" id="nro_pago_registro_{$pos}" value="{@nro_pago_registro}" name="nro_pago_registro_{$pos}" />
            <td style='text-align: center; width: 80px'>
                <xsl:value-of select='@nro_pago_registro' />
            </td>
			<td style='text-align: center; width: 110px'>
				<xsl:value-of select="concat(@nro_envio, '/', @nro_envio_gral)" />
			</td>
			<td style='text-align: left;'>
				<xsl:value-of select="@razon_social" />
			</td>
            <td style='text-align: left; width: 200px;'>
                <xsl:value-of select="@mutual" />
            </td>
			<td style='text-align: center; width: 100px'>				
                <xsl:choose>
                    <xsl:when test='@nro_credito'>
                        <a target="_blank" href="/meridiano/credito_mostrar.aspx?nro_credito={@nro_credito}" title="Haga click para consultar el crédito">
							<xsl:if test="$contador_pagos_pendientes = 0">
								<xsl:attribute name="style">color: black;</xsl:attribute>
							</xsl:if>
							<xsl:if test="$contador_pagos_pendientes > 0">
								<xsl:attribute name='style'>color: blue;</xsl:attribute>
							</xsl:if>
                            <xsl:value-of select="format-number(@nro_credito, '0000000')" />
                        </a>
                    </xsl:when>
                </xsl:choose>                
			</td>
			<td style='text-align: right; width: 110px'>
				<xsl:value-of  select="format-number(@importe_pago, '$  #0.00')" />
			</td>
			<td style='text-align: left; width: 150px'>
				<xsl:value-of  select="@pago_concepto" />
			</td>
            <td style='text-align: right; width: 80px'>
                <xsl:value-of  select="foo:FechaToSTR(string(@fecha), 1)" />
            </td>
			<td style='text-align: center; width: 30px'>
				<xsl:value-of  select="@detalle" />
			</td>
			<td style='text-align: center; width: 30px'>
				<xsl:value-of  select="@contar" />
			</td>
			<td style='text-align: center; width: 30px'>
                    <a href='#' onclick='return seleccionar_pago({@nro_pago_registro})' title='Editar Pago'>
                        <img border='0' alt='Editar Pago' src='/FW/image/icons/editar.png' />
                    </a>
				<input type='hidden' name='{$pos}' value='{@nro_credito}' />
			</td>
        </tr>
	</xsl:template>	
</xsl:stylesheet>