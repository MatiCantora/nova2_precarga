<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl" />
    
	<xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
		{
			var strNumero = numero.toString()

			while (strNumero.length < largo)
			    strNumero = '0' + strNumero

			return strNumero
		}
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
		<head>
			<title>Ver Pagos Comisiones</title>
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

            <script type="text/javascript" src="/FW/script/nvFW.js"></script>
            <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
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
                var $body
                var tbCabe
                var $divDetalle
                var $tbDetalle
                var $tdScroll
                
                
                function seleccionar_pago(nro_tipo_pago)
                {
                    window.parent.editarPago(nro_tipo_pago)
                }


                function window_onload()
                {
                    // cache de elementos
                    $body       = $$('body')[0]
                    $tbCabe     = $('tbCabe')
                    $divDetalle = $('divDetalle')
                    $tbDetalle  = $('tbDetalle')
                    $tdScroll   = $('tdScroll')
                    
                    window_onresize()
                }


                function window_onresize()
                {
                    try {
                        var body_h   = $body.getHeight()
                        var tbCabe_h = $tbCabe.getHeight()
                        var altura   = body_h - tbCabe_h

                        $divDetalle.style.height = altura + 'px'

                        tdScroll_hide_show($tbDetalle.getHeight() > altura)
                    }
                    catch(e) {
                        console.log('Ocurrió un error al aplicar el resize. Detalle: ' + e.message)
                    }
                }


                function tdScroll_hide_show(show)
                {
                    show ? $tdScroll.show() : $tdScroll.hide()
                }
                ]]>
            </script>
            <style type="text/css">
                .tr_cel TD { background-color: #F0FFFF !Important; }
            </style>
		</head>
        <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
			<form name="frmPagos" id="frmPagos" style="width: 100%; height: 100%; overflow: hidden; margin: 0;">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td style='text-align: center; width: 150px;'>
                            <script type="text/javascript">campos_head.agregar('Liquidación', 'true', 'id_liquidacion')</script>
						</td>
						<td style='text-align: center'>
                            <script type="text/javascript">campos_head.agregar('Razón Social', 'true', 'razon_social')</script>
						</td>
                        <td style='text-align: center; width: 150px;'>
                            <script type="text/javascript">campos_head.agregar('Fecha', 'true', 'fecha')</script>
                        </td>
						<td style='text-align: center; width: 150px;'>
                            <script type="text/javascript">campos_head.agregar('Importe Pago', 'true', 'importe_pago')</script>
                        </td>
						<td style='text-align: center; width: 250px;'>
                            <script type="text/javascript">campos_head.agregar('Entidad', 'true', 'entidad_pago')</script>
                        </td>
						<td style='text-align: center; width: 150px;'>
                            <script type="text/javascript">campos_head.agregar('Concepto', 'true', 'pago_concepto')</script>
						</td>
						<td style='text-align: center; width: 50px' title='Cantidad de detalles'>D</td>
						<td style='text-align: center; width: 50px' title='Cantidad de pagos pendientes'>P</td>
						<td style='text-align: center; width: 50px'>-</td>
                        <td id='tdScroll' style="width: 14px !important; display: none;">&#160;</td>
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
		<xsl:variable name="conta_pendientes" select="@pagos_pendientes" />
		<xsl:variable name="conta_suspendidos" select="@pagos_suspendidos" />
		<xsl:variable name="pos" select="position()" />

        <tr id="tr_ver{$pos}">
		    <xsl:choose>
			    <xsl:when test="$conta_pendientes > 0">
                    <xsl:attribute name='style'>color: blue;</xsl:attribute>
			    </xsl:when>
				<xsl:when test="$conta_suspendidos > 0">
                    <xsl:attribute name='style'>color: orange;</xsl:attribute>
				</xsl:when>
			    <xsl:otherwise></xsl:otherwise>
		    </xsl:choose>
			<input type="hidden" id="nro_pago_registro_{$pos}" value="{@nro_pago_registro}" name="nro_pago_registro_{$pos}" />
			<td style='text-align: center; width: 150px'>
			    <xsl:value-of select="@id_liquidacion" />				
			</td>
			<td style='text-align: left'>
				&#160;<xsl:value-of select="@razon_social" />
			</td>
            <td style='text-align: right; width: 150px;'>
                <xsl:attribute name="title">
                    <xsl:value-of select="foo:FechaToSTR(string(@fecha), 1)" />&#160;&#13;<xsl:value-of select="foo:HoraToSTR(string(@fecha))" />
                </xsl:attribute>
                <xsl:value-of select="foo:FechaToSTR(string(@fecha), 1)" />&#160;
            </td>
			<td style='text-align: right; width: 150px'>
				<xsl:value-of  select="format-number(@importe_pago, '$ #0.00')" />&#160;
			</td>
			<td style='text-align: left; width: 250px'>
                &#160;<xsl:value-of  select="@entidad_pago" />
			</td>
			<td style='text-align: left; width: 150px'>
                &#160;<xsl:value-of  select="@pago_concepto" />
			</td>
			<td style='text-align: center; width: 50px'>
				<xsl:value-of  select="@detalle" />
			</td>
			<td style='text-align: center; width: 50px'>
				<xsl:value-of  select="$conta_pendientes" />
			</td>
			<td style='text-align: center; width: 50px'>
                <img border='0' src='/FW/image/icons/editar.png' alt='Editar' onclick='return seleccionar_pago({@nro_pago_registro})' title='Editar Pago' />
				<input type='hidden' name='{$pos}' value='{@nro_credito}' />
			</td>
        </tr>			
	</xsl:template>	
</xsl:stylesheet>