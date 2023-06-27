<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <head>

        <title>INSTRUCCIÓN DE PAGO</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW

        </script>

      </head>
      <script>
        <xsl:comment>
          <![CDATA[
						function window_onload() {
            
              window.parent.cant_resultados = campos_head.recordcount;
              window_onresize();
						}
            
            function window_onresize() {
              campos_head.resize('tbCabecera','tbDetalles');
            }
                       
           
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

        <table class="tb1" id="tbCabecera">
          <tr class="tbLabel">
            <td style='width: 4%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Nro.', true,'nro_proceso')</script>
            </td>
            <td style='width: 6%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Fecha', true,'fecha_proceso')</script>
            </td>
            <td style='width: 10.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Concepto', true,'pago_concepto')</script>
            </td>
            <td style='width: 9%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Origen', true,'Razon_social_origen')</script>
            </td>
            <td style='width: 9%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Destino', true,'Razon_social_destino')</script>
            </td>
            <td style='width: 8%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Estado', true,'pago_estados')</script>
            </td>
            <td style='width: 7.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Tipo', true,'pago_tipo')</script>
            </td>
            <td style='width: 7.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Banco Origen', true,'banco_orig')</script>
            </td>
            <td style='width: 12%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Cuenta Origen', true,'nro_cuenta_orig')</script>
            </td>
            <td style='width: 7.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Banco Destino', true,'banco_dest')</script>
            </td>
            <td style='width: 12%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Cuenta Destino', true,'nro_cuenta_dest')</script>
            </td>
            <td style='width: 7%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Importe', true,'importe_pago_det')</script>
            </td>
          </tr>
        </table>

        <div id='divDetalles' style='width: 100%; height: 91%; overflow: auto;'>
          <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
            <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
          </table>
        </div>

        <!-- DIV DE PAGINACION -->
        <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; height: 16px">
          <script type="text/javascript">
            if (campos_head.PageCount > 1)
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <tr name="dataRow">
      <!-- DATOS -->
      <td style="text-align: right">
        <a style="color: black" href="javascript:parent.nuevaInstruccionPago({@nro_proceso})">
          <xsl:value-of select="@nro_proceso" />
        </a>
      </td>
      <td style="text-align: right">
        <xsl:value-of select="@fecha_proceso" />
      </td>
      <td>
        <xsl:value-of select="@pago_concepto" />
      </td>
      <td title="{@Razon_social_origen}">
        &#160;
        <xsl:choose>
          <xsl:when test="string-length(@Abreviacion_origen) &gt; 0">
            <xsl:value-of select="@Abreviacion_origen" />
          </xsl:when>
          <xsl:when test="string-length(@Razon_social_origen) &gt; 23">
            <xsl:value-of select="substring(@Razon_social_origen, 1, 23)" />...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@Razon_social_origen" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td title="{@Razon_social_destino}">
        &#160;
        <xsl:choose>
          <xsl:when test="string-length(@Abreviacion_destino) &gt; 0">
            <xsl:value-of select="@Abreviacion_destino" />
          </xsl:when>
          <xsl:when test="string-length(@Razon_social_destino) &gt; 23">
            <xsl:value-of select="substring(@Razon_social_destino, 1, 23)" />...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@Razon_social_destino" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="@nro_pago_estado = '0'">
            <xsl:attribute name="style">color: grey;</xsl:attribute>
          </xsl:when>
          <xsl:when test="@nro_pago_estado = '1'">
            <xsl:attribute name="style">color: blue;</xsl:attribute>
          </xsl:when>
          <xsl:when test="@nro_pago_estado = '2'">
            <xsl:attribute name="style">color: green;</xsl:attribute>
          </xsl:when>
          <xsl:when test="@nro_pago_estado = '3'">
            <xsl:attribute name="style">color: red;</xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="style">color: inherit;</xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        &#160;<xsl:value-of select="@pago_estados" />&#160;<!--(<xsl:value-of select="@fecha_proceso" />)-->
      </td>
      <td>
        &#160;<xsl:value-of select="@pago_tipo" />
      </td>
      <td title="{@banco_orig}">
        &#160;
        <xsl:choose>
          <xsl:when test="string-length(@banco_orig) &gt; 23">
            <xsl:value-of select="substring(@banco_orig, 1, 23)" />...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@banco_orig" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style="width: 160px; text-align: right;">
        <xsl:value-of select="@nro_cuenta_orig" />&#160;
      </td>
      <td title="{@banco_dest}">
        &#160;
        <xsl:choose>
          <xsl:when test="string-length(@banco_dest) &gt; 23">
            <xsl:value-of select="substring(@banco_dest, 1, 23)" />...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@banco_dest" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style="text-align: right;">
        <xsl:value-of select="@nro_cuenta_dest" />&#160;
      </td>
      <td>
        <span style="float:left;">
          <xsl:value-of select="@ISO_cod" />
        </span>
        <span style="float:right;">
          <xsl:value-of select="format-number(@importe_pago_det, '#.00')" />
        </span>
        <!--<xsl:value-of select="concat(@ISO_cod, ' ', format-number(@importe_pago_det, '#.00'))" />-->
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>