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

        <title>PRESTAMOS</title>
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
              window_onresize();
						}
       //tcampo_head.js
            function window_onresize() {

              $('divDetalles').setStyle({  width: $('tbCabecera').getWidth() })
              $('divDetalles').setStyle({ height: $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('div_pag').getHeight() });
               
              campos_head.resize('tbCabecera','tbDetalles');
            }
 
 
					]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow-y: hidden; overflow-x:auto">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold; color: grey;">No se encontraron prestamos</p>
              <!--<p style="margin: 0; font-size: 1.1em; color: grey;">Intente con otro/s valor/es de filtro</p>-->
            </div>
          </xsl:when>
          <xsl:otherwise>

            <table class="tb1" id="tbCabecera">
              <tr class="tbLabel">

                <td style=" width: 7%; text-align: center;">
                   
                  <script>campos_head.agregar( 'Nro.', true,'openro')</script>
                </td>
                <td style='width: 5%; text-align: center'>
                  <script>campos_head.agregar('Cue. Cod.', true,'cuecod')</script>
                </td>
                <td style='width: 5%; text-align: center'>
                  <script>campos_head.agregar('Cuotas', true,'cancuocap')</script>
                </td> 
                <td style='width: 7%; text-align: center'>
                  <script>campos_head.agregar('Fecha Origen', true,'fecori')</script>
                </td>
                <td style='width: 10%; text-align: center'>
                  <script>campos_head.agregar('Imp. Neto', true,'impneto')</script>
                </td>
                <td style='width: 10%; text-align: center'>
                  <script>campos_head.agregar('Imp. Pactado', true,'importpact')</script>
                </td>
                <td style='width: 8%; text-align: center'>
                  <script>campos_head.agregar('Estado', true,'estoperdesc')</script>
                </td>
                <td style='width: 10%; text-align: center'>
                  <script>campos_head.agregar('Fecha de Pago', true,'Fecha_de_pago')</script>
                </td>
                <td style='width: 10%; text-align: center'>
                  <script>campos_head.agregar('Moneda', true,'mondesc')</script>
                </td>
                <td style='width: 10%; text-align: center'>
                  <script>campos_head.agregar('Nro. Ref.', true,'nroreferencia')</script>
                </td>
                <td style='width: 18%; text-align: center'>
                  <script>campos_head.agregar('Producto', true,'prodnom')</script>
                </td>


              </tr>
            </table>
            <div id='divDetalles' style='width:100%; height: 91%; overflow-y: auto; overflow-x:hidden'>
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

          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>



  <xsl:template match="z:row"  mode="row1">

    <tr name="dataRow">
      <!-- DATOS -->

      <td style="width: 7%;text-align: right">
        <xsl:value-of select="@openro"/>
      </td>
      <td style="width: 5%; text-align: right">
        <xsl:value-of select="@cuecod"/>
      </td>
      <td style="width: 5%; text-align: right">
        <xsl:value-of select="@cancuocap"/>
      </td>
      <td style="width: 7%;text-align: center">
        <xsl:value-of select="foo:FechaToSTR(string(@fecoiri))"/>
      </td>
      <td style="width: 10%; text-align: right">
        <xsl:value-of select="@impneto"/> 
      </td>
      <td style="width: 10%;text-align: right">
        <xsl:value-of select="@importpact"/> 
      </td>
      <td style="width: 8%;text-align: center">
        <xsl:value-of select="@estoperdesc"/>
      </td>
      <td style="width: 10%;text-align: center">
        <xsl:value-of select="foo:FechaToSTR(string(@Fecha_de_pago))"/>
      </td>
      <td style="width: 10%;text-align: center">
        <xsl:value-of select="@mondesc"/>
      </td>
      <td style="width: 10%;text-align: right">
        <xsl:value-of select="@nroreferencia"/>
      </td>
      <td style="width: 18%;text-align: left">
        <xsl:attribute name="title">
          <xsl:value-of  select="@prodnom" />
        </xsl:attribute>
        <xsl:value-of select="@prodnom"/>
      </td>

    </tr> 

  </xsl:template>

</xsl:stylesheet>
