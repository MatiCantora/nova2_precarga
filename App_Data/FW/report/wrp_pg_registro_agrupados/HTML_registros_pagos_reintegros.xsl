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
            var count     = strNumero.length

			while (count < largo) {
			    strNumero = "0" + strNumero
                count++
            }

			return strNumero
		}
		]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <title>Ver Pagos Reintegros</title>
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
                        try {
                            var body_height   = $$('body')[0].getHeight()
                            var tbCabe_height = $('tbCabe').getHeight()

                            $('divDetalle').setStyle({ height: body_height - tbCabe_height + 'px' })

                            //tdScroll_hide_show($('tbDetalle').getHeight() > $('divDetalle').getHeight())
                        }
                        catch(e) {}
                        
                        campos_head.resize('tbCabe', 'tbDetalle')
                    }


                    function tdScroll_hide_show(show)
                    {
                        show ? $('tdScroll').show() : $('tdScroll').hide()
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
              <td style='text-align: center; width: 120px'>
                <script type="text/javascript">campos_head.agregar('Fecha', 'true', 'fecha')</script>
              </td>
              <td style='text-align: center'>
                <script type="text/javascript">campos_head.agregar('Razón Social', 'true', 'razon_social')</script>
              </td>
              <td style='text-align: center; width: 190px'>
                <script type="text/javascript">campos_head.agregar('Mutual', 'true', 'mutual')</script>
              </td>
              <td style='text-align: center; width: 120px'>
                <script type="text/javascript">campos_head.agregar('Fe. Descuento', 'true', 'fe_descuento')</script>
              </td>
              <td style='text-align: center; width: 120px'>
                <script type="text/javascript">campos_head.agregar('Nro. Descuento', 'true', 'numero')</script>
              </td>
              <td style='text-align: center; width: 120px'>
                <script type="text/javascript">campos_head.agregar('Nro. Proceso', 'true', 'nro_proceso')</script>
              </td>
              <td style='text-align: center; width: 120px'>
                <script type="text/javascript">campos_head.agregar('Importe Pago', 'true', 'importe_pago')</script>
              </td>
              <td style='text-align: center; width: 80px'>Concepto</td>
              <td style='text-align: center; width: 50px;' title='Detalles de pago'>D</td>
              <td style='text-align: center; width: 50px;' title='Pendientes de pago'>P</td>
              <td style='text-align: center; width: 50px;'>-</td>
              <!--<td style="width: 15px !important" id="tdScroll">&#160;</td>-->
            </tr>
          </table>
          <div id="divDetalle" style="width: 100%; overflow: auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
          </div>
        </form>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="cantidad_pendientes" select="@pagos_pendientes" />
    <xsl:variable name="cantidad_suspendidos" select="@pagos_suspendidos" />
    <xsl:variable name="cantidad_en_espera" select="@pagos_en_espera" />
    <xsl:variable name="pos" select="position()" />

    <tr id="tr_ver{$pos}">
      <xsl:choose>
        <xsl:when test="$cantidad_pendientes > 0">
          <xsl:attribute name='style'>color: blue;</xsl:attribute>
        </xsl:when>
        <xsl:when test="$cantidad_suspendidos > 0">
          <xsl:attribute name='style'>color: orange;</xsl:attribute>
        </xsl:when>
        <xsl:when test="$cantidad_en_espera > 0">
          <xsl:attribute name='style'>color: grey;</xsl:attribute>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>

      <td style='text-align: right; width: 120px;'>
        <xsl:value-of select='foo:FechaToSTR(string(@fecha), 1)'/>&#160;
      </td>
      <td style='text-align: left'>
        &#160;<xsl:value-of select="@razon_social" />
      </td>
      <td style='text-align: left; width: 190px;' title='{@mutual}'>
        <xsl:choose>
          <xsl:when test="string-length(@mutual) &#62; 28">
            &#160;<xsl:value-of select="substring(@mutual, 1, 28)" />...
          </xsl:when>
          <xsl:otherwise>
            &#160;<xsl:value-of select="@mutual" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <xsl:variable name='fecha' select='foo:FechaToSTR(string(@fe_descuento), 1)' />
      <td style='text-align: right; width: 120px' title='{$fecha}'>
        <xsl:value-of select="$fecha" />&#160;
      </td>
      <td style='text-align: right; width: 120px'>
        <xsl:value-of select="@numero" />&#160;
      </td>
      <td style='text-align: right; width: 120px'>
        <xsl:value-of select="@nro_proceso" />&#160;
      </td>
      <td style='text-align: right; width: 120px'>
        <span style='float: left'>
          <xsl:value-of  select="@ISO_cod" />&#160;
        </span>
        <xsl:value-of select="format-number(@importe_pago, '#0.00')" />&#160;
      </td>
      <td style='text-align: left; width: 80px'>
        &#160;<xsl:value-of select="@pago_concepto" />
      </td>
      <td style='text-align: center; width: 50px'>
        <xsl:value-of select="@detalle" />
      </td>
      <td style='text-align: center; width: 50px'>
        <xsl:value-of select="$cantidad_pendientes" />
      </td>
      <td style='text-align: center; width: 50px;'>
        <img alt='Editar Pago' src='/FW/image/icons/editar.png' style='border: none; cursor: pointer;' onclick='return seleccionar_pago({@nro_pago_registro})' title='Editar Pago' />
        <input type="hidden" name="{$pos}" value="{@nro_credito}" />
      </td>
      <input type="hidden" id="nro_pago_registro_{$pos}" value="{@nro_pago_registro}" name="nro_pago_registro_{$pos}" />
    </tr>
  </xsl:template>
</xsl:stylesheet>