<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
		{
			var strNumero = numero.toString()

			while (strNumero.length < largo)
			    strNumero = '0' + strNumero.toString()

            return strNumero
		}
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<title>Pagos</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
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

				<script language="javascript" type="text/javascript">
				    <![CDATA[
					function seleccionar_pago(nro_tipo_pago)
					{
					    window.parent.editarPago(nro_tipo_pago)
					}


					function onclick_sel(indice)
                    {
                        var x = 0

                        if ($('check_' + indice).checked)
                            $('tr_ver' + indice).addClassName('tr_cel_click')
                        else
                            $('tr_ver' + indice).removeClassName('tr_cel_click')

                        var elementos = ''

                        for (var i = 0, ele; ele = $('frm1').elements[i]; i++)
                        {
                            if (ele.type == 'checkbox' && ele.id != 'check_all')
				            {
				                if (ele.checked)
				                {
				                    if (elementos == '')
				                        elementos = ele.value
				                    else
				                        elementos += ',' + ele.value
				                }
				            }
                        }

                        window.parent.$('pagos_detalles').value = elementos
                    }


					function ChequearTodos(chkbox)
					{
					    var elementos = ''
					    var x = 0

                        for (var i = 0, ele; ele = $('frm1').elements[i]; i++)
					    {
					        if (ele.type == 'checkbox' && ele.id != 'check_all')
					        {  
					            x++

					            if (chkbox.checked)
					            {	
					                if (!ele.disabled)
					                {
					                    ele.checked = 'checked'
					                    $('tr_ver' + x).addClassName('tr_cel_click')

                                        if (elementos == '')
					                        elementos = ele.value
					                    else
					                        elementos += ',' + ele.value
					                }
						        }
						        else
						        {
						            ele.checked = ''
						            $('tr_ver' + x).removeClassName('tr_cel_click')
						        }
						    }
					    }

                        window.parent.$('pagos_detalles').value = elementos
					}
                    
                    
                    function window_onload()
                    {
                        // Aplicar el resize del iFrame
                        try
                        {
                            var hBody   = $$("body")[0].getHeight()
                            var hTbCabe = $("tbCabe").getHeight()
                            
                            $("divDatos").setStyle({ height: hBody - hTbCabe + "px" })
                        }
                        catch(e) {}
                    }
					]]>
				</script>

                <style type="text/css">
                    .tr_cel TD { background-color: #F0FFFF !Important; }
                    .tr_cel_click TD { background-color: #BDD3EF !Important; color : #0000A0 !Important; }
                </style>
			</head>
			<body onload="window_onload()">
				<form name="frm1" id="frm1" style="width: 100%; height: 100%; margin: 0;">
					<table class="tb1" id="tbCabe">
						<tr class="tbLabel">
							<td style='text-align: center; width: 10px'>
								<input type="checkbox" style="border: none; cursor: pointer;" name="check_all" id="check_all" onclick="ChequearTodos(this)" />
							</td>
							<td style='text-align: center; width: 80px'>Nro. Credito</td>
							<td style='text-align: center; width: 240px'>Razón Social</td>
							<td style='text-align: center; width: 120px'>Concepto</td>
							<td style='text-align: center; width: 120px'>Tipo de Pago</td>
							<td style='text-align: center; width: 100px'>Importe</td>
							<td style='text-align: center; width: 100px'>Estado</td>
						</tr>
					</table>
					<div style="width: 100%; height: 370px; overflow-y: scroll;" id="divDatos">
						<table class="tb1">
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
				</form>	
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()" />
	    <tr id="tr_ver{$pos}">
		    <td style='text-align: center; width: 10px;'>
			    <input type="checkbox" value="{@nro_pago_detalle}" name="{$pos}" id="check_{$pos}" onclick="onclick_sel({$pos})" style="border: none; cursor: pointer;">
				    <!--<xsl:attribute name='value'><xsl:value-of select="@nro_pago_detalle"/></xsl:attribute>-->
				    <!--<xsl:attribute name='name'><xsl:value-of select="position()"/></xsl:attribute>-->
                    <!--<xsl:attribute name='id'>check_<xsl:value-of select="position()"/></xsl:attribute>-->
                    <!--<xsl:attribute name='onclick'>onclick_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>-->
                    <!--<xsl:attribute name='style'>border:0</xsl:attribute>-->
				    <xsl:if test="@nro_pago_tipo = 1 and @nro_pago_concepto = 5 and @permiso_pago = 0">
					    <xsl:attribute name='disabled'>true</xsl:attribute>
				    </xsl:if>
			    </input>
		    </td>
		    <td style='text-align: center; width: 80px;'>
                <xsl:value-of select="format-number(@nro_credito, '0000000')" />
		    </td>		  
		    <td style='text-align: left; width: 240px;'>
			    <xsl:value-of select="@razon_social" />
		    </td>
		    <td style='text-align: left; width: 120px'>
			    <xsl:value-of select="@pago_concepto" />
		    </td>
		    <td style='text-align: left; width: 120px'>
			    <xsl:value-of select="@pago_tipo" />
		    </td>
		    <td style='text-align: right; width: 100px'>
			    <xsl:value-of select="format-number(@importe_param, '$  #0.00')" />
		    </td>
		    <td style='text-align: left; width: 85px;'>
			    <xsl:value-of select="@pago_estados" />
		    </td>
	    </tr>
	</xsl:template>
</xsl:stylesheet>