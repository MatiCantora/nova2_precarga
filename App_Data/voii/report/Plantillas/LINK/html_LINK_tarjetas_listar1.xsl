<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:include href="..\..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <head>

        <title>Tarjetas</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
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
              window_onresize();
						}
            
            
            function window_onresize() {
              
              var div_pag = $('div_pag');
              for (var i = 0; i < $('div_pag').childNodes.length; i++) {
              var childnode = div_pag.childNodes[i];
                if (childnode.nodeName.toUpperCase() == 'TABLE') {
                  div_pag.setStyle({ height: childnode.getHeight() + 'px' });
                }
              }
            
              $('divDetalles').setStyle({ height: $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('div_pag').getHeight() + 'px' });
              campos_head.resize('tbCabecera','tbDetalles');
            }
                       
           
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

        <table class="tb1" id="tbCabecera">
          <tr class="tbLabel">
            <td style='width: 5%; text-align: center' nowrap='true'></td>
            <td style='width: 5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Cod. Tran.', true,'cod_tran')</script>
            </td>
            <td style='width: 12.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Tipo Cuenta', true,'tipo_cuenta_desc')</script>
            </td>
            <td style='width: 12.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Nro. Cuenta', true,'nro_cuenta')</script>
            </td>
            <td style='width: 15%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Persona', true,'persona_cuil')</script>
            </td>
            <td style='width: 12.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Nro. Tarjeta', true,'tarjeta_nro')</script>
            </td>
            <td style='width: 10%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Tipo Tarjeta', true,'tarjeta_tipo_desc')</script>
            </td>
            <td style='width: 10%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Tarjeta Estado', true,'tarjeta_estado_desc')</script>
            </td>
            <td style='width: 7.5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Fecha Venc.', true,'tarjeta_fe_ven')</script>
            </td>
            <td style='width: 10%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Fecha Emisión', true,'tarjeta_fe_emis_plastico_date')</script>
            </td>
            <!--<td style='width: 5%; text-align: center'></td>-->
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
      <td style="width: 5%; text-align: center">
        <img src="/FW/image/icons/ver.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">
            parent.ver_detalle(event,'<xsl:value-of  select="@tj_maestro_id" />')
          </xsl:attribute>
        </img>
      </td>
      <td style="width:5%; text-align: right">
        <xsl:value-of  select="@cod_tran" />
      </td>
      <td style="width:12.5%">
        <xsl:value-of  select="@tipo_cuenta_desc" />
      </td>
      <td style="width:12.5%; tex-align: right">
        <xsl:value-of  select="@nro_cuenta" />
      </td>
      <td style="width:15%;">
        <xsl:value-of select="concat(@persona_cuil, ' - ', @persona_ape_nom)"/>
      </td>
      <td style="width:12.5%; text-align:right">
        <xsl:value-of  select="@tarjeta_nro" />
      </td>
      <td style="width:10%">
        <xsl:value-of  select="@tarjeta_tipo_desc" />
      </td>
      <td style="width:10%;">
        <xsl:value-of select="@tarjeta_estado_desc"/>
      </td>
      <td style="width:7.5%; text-align:right">
        <xsl:value-of select="@tarjeta_fe_ven"/>
      </td>
      <td style="width:10%; text-align:right">
        <xsl:value-of select="foo:FechaToSTR(string(@tarjeta_fe_emis_plastico_date))"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>