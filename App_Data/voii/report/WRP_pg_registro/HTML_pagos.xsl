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

		function parseFecha(strFecha)
		{
		    var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
			a = a.substr(0, a.indexOf('.'))
			var fe = new Date(Date.parse(a))

			return fe
		}
        
		// MODO 1 : dd/mm/yyyy
        // MODO 2 : mm/dd/yyyy
		function FechaToSTR(cadena, modo)
        {
		    var objFecha = parseFecha(cadena)
		    var dia
		    var mes
		    var anio

		    if (objFecha.getDate() < 10)
		        dia = '0' + objFecha.getDate().toString()
		    else
		        dia = objFecha.getDate().toString()

		    if ((objFecha.getMonth() + 1) < 10)
		        mes = '0' + (objFecha.getMonth() + 1).toString()
		    else
		        mes = (objFecha.getMonth() + 1).toString()

		    anio = objFecha.getFullYear()

            if (modo == 1) 
                return (dia + '/' + mes + '/' + anio).toString()
            else
                return (mes + '/' + dia + '/' + anio).toString()
        }
		]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <title>Pagos depósito</title>
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
                        if ($('check_' + indice).checked)
                            $('tr_ver' + indice).addClassName('tr_cel_click')
                        else
                        {
                            $('tr_ver' + indice).removeClassName('tr_cel_click')
                            $('interb_estado_' + $('check_' + indice).value).innerHTML = ''
                        }  

                        var elementos = ''

                        for(var i = 0, ele; ele = $('frm1').elements[i]; i++)
                        {
                            if (ele.type == 'checkbox' && ele.id != 'check_all')
				            {
				                if (ele.checked)
				                {
				                    if (elementos == '')
				                        elementos = ele.value
				                    else
				                        elementos = elementos + ',' + ele.value
				                }
				            }
                        }

                        window.parent.$('pagos_detalles').value = elementos
                        sumar_total_seleccionado()
                        window.parent.forma_pago_onchange()
                    }

					function ChequearTodos(chkbox, situacion)
					{
					    var elementos = ''
					    var x = 0

					    for(var i = 0, ele; ele = $('frm1').elements[i]; i++)
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
						            $('interb_estado_' + ele.value ).innerHTML = ''
						        }
						    }
					    }

                        window.parent.$('pagos_detalles').value = elementos
                        sumar_total_seleccionado()
                        window.parent.forma_pago_onchange()
					}

					function seleccionar_estado(estado)
					{
					    if (estado == 'V')
					        return

 					    var elementos  = ''
					    var x          = 0
					    var evaluacion = ''

					    switch (estado)
                        {
					        case "T":
					            evaluacion = 'true'
					            break;

					        case "I":
					            evaluacion = 'false'
					            break;

					        case "H":
					            evaluacion = "$('interb_estado_' + ele.value ).innerHTML.toUpperCase() == 'HABILITADO'"
					            break;

					        case "N":
					            evaluacion = "$('interb_estado_' + ele.value ).innerHTML.toUpperCase() != 'HABILITADO'"
					            break;

					        case "P":
					            evaluacion = "$('interb_estado_' + ele.value ).innerHTML.toUpperCase() == '24 HS. HABILITACIÓN'"
					            break;
					    }

					    for (var i = 0, ele; ele = $('frm1').elements[i]; i++)
					    { 
					        if (ele.type == 'checkbox' && ele.id != 'check_all')
					        {  
					            x++
					            if (!ele.disabled && eval(evaluacion))
					            {
					                ele.checked = 'checked'
					                $('tr_ver' + x).addClassName('tr_cel_click')
					              
                                    if (elementos == '')
					                    elementos = ele.value
					                else
					                    elementos += ',' + ele.value
					            }
						        else
						        {
						            ele.checked = ''
						            $('tr_ver' + x).removeClassName('tr_cel_click')
						            $('interb_estado_' + ele.value ).innerHTML = ''
						        }
						    }
					    }

                        window.parent.$('pagos_detalles').value = elementos
                        sumar_total_seleccionado()
                        window.parent.forma_pago_onchange()
					}

					function sumar_total_seleccionado()
					{
					    var sumar_importe = 0

				        for (var i = 0, ele; ele = $('frm1').elements[i]; i++)
					    { 
					        if (ele.type == 'checkbox' && ele.id != 'check_all')
					        {
				                var input_importe_param_ = $('importe_param_' + ele.id.split('check_')[1])
   				           
                                if (parseFloat(input_importe_param_.value) > 0 && ele.checked)
					                sumar_importe = parseFloat(sumar_importe) + parseFloat(input_importe_param_.value)
					        }
					    }

					    $('sel_total').innerHTML = ""
					    $('sel_total').insert({ top: "$ " + formatoDecimal(sumar_importe, 2) })
					  
                        if (sumar_importe > 150000)
                            $('sel_total').setStyle({ color: '#AE0000' })
                        else
                            $('sel_total').setStyle({ color: '#FFFFFF' })
					}

					function window_onresize() 
                    { 
                        try
                        {
                            //var dif    = Prototype.Browser.IE ? 5 : 2
                            var hbody  = $$('BODY')[0].getHeight()
                            var htbCab = $('tbCab').getHeight()
                            var htbPie = $('tbPie').getHeight()

                            $('divDet').setStyle({ 'height' : (hbody - htbCab - htbPie) + 'px' })
                            //$('tbDet').getHeight() - $('divDet').getHeight() >= 0
                            //    ? tdScroll_hide_show(false)
                            //    : tdScroll_hide_show(true)
                        }
                        catch(e) {}
                        
                        campos_head.resize('tbCab', 'tbDet')
                    }

				    ]]>
        </script>
        <style type="text/css">
          .tr_cel TD { background-color: #F0FFFF !Important; }
          .tr_cel_click TD { background-color: #DFD6E0 !Important; color : #0000A0 !Important; }
        </style>
      </head>
      <body onload="return window_onresize()" onresize="return window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
        <form name="frm1" id="frm1" style="width: 100%; height: 100%; overflow: hidden; margin: 0;">
          <table class="tb1" id="tbCab">
            <tr class="tbLabel">
              <td style='text-align: center; width: 5%'>
                <input type="checkbox" style="border: 0; cursor: pointer;" name="check_all" id="check_all" onclick="ChequearTodos(this)" />
              </td>
              <td style='text-align: center; width: 10%' nowrap='true'>
                <script type="text/javascript">campos_head.agregar('Nro. Credito', 'true', 'nro_credito')</script>
              </td>
              <td style='text-align: center; width: 20%' nowrap='true'>
                <script type="text/javascript">campos_head.agregar('Razón Social', 'true', 'razon_social')</script>
              </td>
              <td style='text-align: center; width: 15%'>Concepto</td>
              <td style='text-align: center; width: 15%' nowrap='true'>Tipo de Pago</td>
              <td style='text-align: center; width: 15%'>Estado</td>
              <td style='text-align: center; width: 10%' nowrap='true'>Estado IB</td>
              <td style='text-align: center; width: 10%'>Importe</td>
            </tr>
          </table>
          
          <div id='divDet' style="width:100%; overflow:auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDet">
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
          </div>
          <table class="tb1" id="tbPie">
            <tr class="tbLabel">
              <td style='text-align: right; width: 682px; font-weight: bold;' id='tdResumen'>Importe Total Seleccionado:</td>
              <td name="sel_total" id="sel_total" style="text-align: right; width: 102px; font-weight: bold;">$ 0.00</td>
              <td style="width: 14px;">&#160;</td>
            </tr>
          </table>
        </form>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()" />
    <tr id="tr_ver{$pos}">
      <td style='text-align: center; width: 5%;'>
        <input type="checkbox" value="{@nro_pago_detalle}" name="{$pos}" id="check_{$pos}" onclick="onclick_sel({$pos})" style="border: 0; cursor: pointer;">
          <xsl:if test="@nro_pago_tipo = 1 and @nro_pago_concepto = 5 and @permiso_pago = 0">
            <xsl:attribute name='disabled'>true</xsl:attribute>
          </xsl:if>
        </input>
      </td>
      <td style='text-align: center; width: 10%;'>
        <xsl:choose>
          <xsl:when test='string(@nro_credito) != ""'>
            <xsl:value-of select="format-number(@nro_credito, '0000000')" />
          </xsl:when>
          <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
      </td>
      <td style='text-align: left; width: 20%;' title='{@razon_social}'>
        <xsl:choose>
          <xsl:when test="string-length(@razon_social) &#62; 20">
            <xsl:value-of select="substring(@razon_social, 1, 20)" />...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@razon_social" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style='text-align: left; width: 15%;'>
        <xsl:value-of select="@pago_concepto" />
      </td>
      <td style='text-align: left; width: 15%;'>
        <xsl:value-of select="@pago_tipo" />
      </td>
      <td style='text-align: left; width: 15%;'>
        <xsl:value-of select="@pago_estados" />&#160;<xsl:if test="@fe_estado">
          (<xsl:value-of select="foo:FechaToSTR(string(@fe_estado), 1)" />)
        </xsl:if>
      </td>
      <td style='text-align: left; width: 10%;' name='interb_estado_{@nro_pago_detalle}' id='interb_estado_{@nro_pago_detalle}'></td>
      <td style='text-align: right; width: 10%;'>
        <xsl:variable name="importe">
          <xsl:choose>
            <xsl:when test="string(@importe_pago) != ''">
              <xsl:value-of select="@importe_pago"/>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="format-number($importe, '$  #0.00')" />
        <input type="hidden" value="{format-number($importe, '#0.00')}" name="importe_param_{$pos}" id="importe_param_{$pos}" />
      </td>
      <script type="text/javascript" languaje="javascript">
        <![CDATA[
                if (parent.$('pagos_detalles_todos').value == '')
                    parent.$('pagos_detalles_todos').value = ]]><xsl:value-of select="@nro_pago_detalle" /><![CDATA[
                else
                    parent.$('pagos_detalles_todos').value += ',' + ]]><xsl:value-of select="@nro_pago_detalle" />
      </script>
    </tr>
  </xsl:template>
</xsl:stylesheet>