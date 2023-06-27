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
            var count     = strNumero.length

            while (count < largo)
            {
			    strNumero = '0' + strNumero
                count++
            }

			return strNumero
		}

		var nro_cheque_mas = 0

		function get_nro_cheque(nro_cheque_desde, nro_pago_detalle)
        {
		    if (parseInt(nro_pago_detalle) == 1)
		        nro_cheque_mas++

		    return (parseInt(nro_cheque_desde) + nro_cheque_mas) - 1
		}
	    ]]>
    </msxsl:script>

    <xsl:template match="/">
		<html>
			<head>
				<title>Impresión de Cheques</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
                <style type="text/css">
                    .tr_cel TD { background-color: #F0FFFF !Important;}
                    .tr_cel_click TD { background-color: #BDD3EF !Important; color : #0000A0 !Important; }
                </style>
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
                
                <script type="text/javascript" language="javascript" >
                    <![CDATA[
				    function seleccionar_todos(chkbox)
                    {
					    var x             = 0
                        var checkElements = $('frm1').select("input[type=checkbox]:not(#check_all)")
					    var elementos     = []
                        var ele
                        var row

                        for (var i = 0, cant = checkElements.length; i < cant; i++)
                        {
                            x++
                            row = $('tr_ver' + x)
                            ele = checkElements[i]

                            if (!chkbox.checked)
                            {
                                ele.checked = false
                                row.removeClassName("tr_cel_click")
                            }
                            else
                            {
                                ele.checked = true
                                elementos[x] = []
                                elementos[x]["nro_pago_detalle"] = ele.value
                                elementos[x]["nro_cheque"]       = $(ele.value).value
                                row.addClassName("tr_cel_click")
                            }
                        }

                        window.parent.Parametros_pagos = elementos
                    }


                    function onclick_sel(indice)
                    {
                        var x   = 0
                        var row = $('tr_ver' + indice)

                        $('check_' + indice).checked ? row.addClassName('tr_cel_click') : row.removeClassName('tr_cel_click')

                        var checkElements = $('frm1').select("input[type=checkbox]:not(#check_all)")
                        var elementos     = []
                        var ele

                        for (var i = 0, cant = checkElements.length; i < cant; i++)
                        {
                            ele = checkElements[i]
                            
                            if (ele.checked)
                            {
                                x++
                                elementos[x] = []
					            elementos[x]["nro_pago_detalle"] = ele.value
					            elementos[x]["nro_cheque"]       = $(ele.value).value
                            }
                        }

                        window.parent.Parametros_pagos = elementos
                    }


                    var win_credito


                    function credito_mostrar(e, nro_credito) {
                        if (e.ctrlKey == false)
                        {
                            var title = 'Nro. Credito: ' + nro_credito;
                            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                            
                            win_credito = w.createWindow({
                                url: '/meridiano/credito_mostrar.aspx?nro_credito=' + nro_credito,
                                title: '<b>' + title + '</b>',
                                minimizable: true,
                                maximizable: true,
                                draggable: true,
                                resizable: false,
                                width: 1000,
                                height: 500,
                                destroyOnClose: true
                            });

                            win_credito.showCenter()
                        }
                        else
                            $('link_mostrar_credito').href = '/meridiano/credito_mostrar.aspx?nro_credito=' + nro_credito;
                    }


                    function window_onload()
                    {
                        try
                        {
                            // Ajustar altura de DIV #tbDatos
                            var body_h   = $$("body")[0].getHeight()
                            var tbCabe_h = $("tbCabe").getHeight()

                            $("tbDatos").setStyle({ height: body_h - tbCabe_h + "px" })
                        }
                        catch(e) {}
                    }
                    ]]>
				</script>
			</head>
			<body onload="window_onload()" style="width: 100%; height: 100%; overflow: auto; background-color: white;">
			    <form name="frm1" id="frm1" style="margin: 0;">
				    <table class="tb1" id="tbCabe">
					    <tr class="tbLabel">
						    <td style='text-align: center; width: 26px;'>
							    <input type="checkbox" name="check_all" style="border: none; cursor: pointer;" id="check_all" onclick="seleccionar_todos(this)" title="Seleccionar todo" />
						    </td>
						    <td style='text-align: center; width: 80px'>Nro. Credito</td>
						    <td style='text-align: center;'>Razón Social</td>
						    <td style='text-align: center; width: 120px'>Concepto</td>
						    <td style='text-align: center; width: 120px'>Tipo de Pago</td>
						    <td style='text-align: center; width: 100px'>Importe</td>
                            <td style='text-align: center; width: 100px'>Nro. Cheque</td>
                            <td style='text-align: center; width: 16px'>&#160;</td>
					    </tr>
				    </table>
					<div id="tbDatos" style="width: 100%; overflow-y: auto;">
						<table class="tb1 highlightOdd highlightTROver">
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
				</form>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()" />
		<xsl:variable name="estado" select="@nro_pago_estado" />
		<!--<xsl:variable name="contador" select="1" />-->
        <xsl:variable name="nro_pago_detalle" select="@nro_pago_detalle" />

        <tr id="tr_ver{$pos}">
		    <td style='text-align: center; width: 26px'>
			    <input type='checkbox' style='border: none;' value='{$nro_pago_detalle}' name='{$pos}' id='check_{$pos}' onclick='onclick_sel({$pos})' />
		    </td>
		    <td style='text-align: center; width: 80px;'>
			    <xsl:if test='@nro_credito'>
                    <a id="link_mostrar_credito" href="#" title='Mostrar Datos Crédito' style='cursor: pointer;' onclick='credito_mostrar(event, {@nro_credito})'>
                        <xsl:value-of select="format-number(@nro_credito, '0000000')" />
                    </a>
			    </xsl:if>
		    </td>
		    <td style='text-align: left;'>
			    <xsl:value-of  select="@razon_social" />
		    </td>
		    <td style='text-align: left; width: 120px'>
			    <xsl:value-of  select="@pago_concepto" />
		    </td>
		    <td style='text-align: left; width: 120px'>
			    <xsl:value-of  select="@pago_tipo" />
		    </td>
		    <td style='text-align: right; width: 100px'>
                <xsl:choose>
                    <xsl:when test='string(@importe_param) != ""'>
			            <xsl:value-of select="format-number(@importe_param, '$  #0.00')" />
                    </xsl:when>
                    <xsl:otherwise>0.00</xsl:otherwise>
                </xsl:choose>
		    </td>		  
		    <td style='text-align: center; width: 100px'>
                <xsl:choose>
				    <xsl:when test="$estado = 1">
					    <xsl:variable name="retorno" select="foo:get_nro_cheque(string(@cheque_desde), string(@nro_pago_estado))" />
					    <font color="blue">
					        <xsl:value-of select="$retorno"/>
					    </font>
					    <input type='hidden' value='{$retorno}' name='{$nro_pago_detalle}' id='{$nro_pago_detalle}' />
				    </xsl:when>
				    <xsl:when test="$estado = 3">
					    <span title="{@observacion}">
						    <font color="red">
						        <xsl:value-of select="@pago_estados" />
						    </font>
						</span>
					    <input type="hidden" value="0" name="{$nro_pago_detalle}" id="{$nro_pago_detalle}" />
				    </xsl:when>
				    <xsl:otherwise>
					    <span title="{@nro_cheque}">
						    <xsl:value-of select="@pago_estados" />
					    </span>
					    <input type="hidden" value="0" name="{$nro_pago_detalle}" id="{$nro_pago_detalle}" />
				    </xsl:otherwise>
				</xsl:choose>  
		    </td>
            <td style='width: 16px'>&#160;</td>
	    </tr>	  
	</xsl:template>
</xsl:stylesheet>