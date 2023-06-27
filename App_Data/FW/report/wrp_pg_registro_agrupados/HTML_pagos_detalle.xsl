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
        <title>Ver Pagos Detalle</title>
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
          .centrado tr td { text-align: center; }
        </style>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
        <!--<form name="frmPagos" id="frmPagos" style="width: 100%; height: 100%; overflow: hidden;">-->
          <table class="tb1 centrado" id="tbCabe">
            <tr class="tbLabel">
              <td style="width: 5%;"></td>
              <td style='width: 10%' nowrap="true">
                <script type="text/javascript">campos_head.agregar('Origen', 'true', 'origen')</script>
              </td><td style='width: 10%' nowrap="true">
                <script type="text/javascript">campos_head.agregar('Tipo Pago Orig.', 'true', 'pago_tipo_orig')</script>
              </td>
              <td style='width: 10%' nowrap="true">
                <script type="text/javascript">campos_head.agregar('Tipo Pago Dest.', 'true', 'pago_tipo')</script>
              </td>
              <td style='width: 10%'>
                <script type="text/javascript">campos_head.agregar('Estado', 'true', 'pago_estado')</script>
              </td>
              <td nowrap="true">
                <script type="text/javascript">campos_head.agregar('Detalle Cobro', 'true', 'detalle_cobro')</script>
              </td>
              <td style='width: 10%;' nowrap="true">
                <script type="text/javascript">campos_head.agregar('Fecha Estado', 'true', 'fe_estado')</script>
              </td>
              <td style='width: 9%' nowrap='true'>
                <script type="text/javascript">campos_head.agregar('Operador', 'true', 'login')</script>
              </td>
              <td style='width: 15%' nowrap="true">
                <script type="text/javascript">campos_head.agregar('Importe Pago', 'true', 'importe_pago')</script>
              </td>
              <!--<td id='tdScroll' style="width: 14px; display: none;">&#160;</td>-->
            </tr>
          </table>
          <div id="divDetalle" style="width: 100%; overflow: auto;">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
              <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
          </div>
        <!--</form>-->
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="contador_pagos_pendientes" select="@contar" />

    <tr id="tr_ver{$pos}">
      <td style="width: 5%;"></td>
      <td style='text-align: left; width: 10%'>
        <xsl:attribute name='title'>
          <xsl:value-of select='@origen' />
        </xsl:attribute>
        <xsl:value-of select='@origen' />
      </td>
      <td style='text-align: left; width: 10%'>
        <xsl:value-of select='@pago_tipo_orig' />
      </td>
        <td style='text-align: left; width: 10%'>
        <xsl:value-of select='@pago_tipo' />
      </td>
      <td style='text-align: left; width: 10%'>
        <xsl:value-of select="@pago_estados" />
      </td>
      <td style='text-align: left;'>
        <xsl:attribute name='title'>
          <xsl:value-of select='@detalle_cobro' />
        </xsl:attribute>
        <xsl:value-of select="@detalle_cobro" />
      </td>
      <td style='text-align: right; width: 10%'>
        <xsl:attribute name="title">
          <xsl:value-of select="foo:FechaToSTR(string(@fe_estado), 1)" />&#160;&#13;<xsl:value-of select="foo:HoraToSTR(string(@fe_estado))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@fe_estado), 1)" />&#160;
      </td>
      <td style='text-align: left; width: 9%;'>
        <xsl:value-of select="@login" />
      </td>
      <td style='text-align: right; width: 15%'>
        <span style='float: left'>
          <xsl:value-of  select="@ISO_cod" />&#160;
        </span>
        <xsl:value-of select="format-number(@importe_pago, '#0.00')" />
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>