<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <head>

        <title>SOLICITUDES</title>
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
            
            function window_onresize() {
              campos_head.resize('tbCabecera','tbDetalles');
            }
                       
           
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold; color: grey;">No se encontraron solicitudes</p>
              <!--<p style="margin: 0; font-size: 1.1em; color: grey;">Intente con otro/s valor/es de filtro</p>-->
            </div>
          </xsl:when>
          <xsl:otherwise>

            <table class="tb1" id="tbCabecera">
              <tr class="tbLabel">
                <td style='width: 9%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Nro.', true,'nro_sol')</script>
                </td>
                <td style='width: 15%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Tipo Solicitud', true,'nro_sol_tipo')</script>
                </td>
                <td style='width: 16%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Fe. Alta', true,'fe_alta')</script>
                </td>
                <td style='width: 13.5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Monto', true,'monto')</script>
                </td>
                <td style='width: 9%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Plazo', true,'plazo')</script>
                </td>
                <td style='width: 16.5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Estado', true,'sol_estado_desc')</script>
                </td>
                <td style='width: 16%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Fe. Estado', true,'fe_estado')</script>
                </td>
                <td style='width: 5%; text-align: center'>-</td>
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

          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <xsl:variable name="apenom" select="concat(string(@nombre),' ',string(@apellido))"/>
    <tr name="dataRow">
      <!-- DATOS -->
      <td style="width:9%; text-align: right" name="nro_solicitudes">
        <xsl:value-of  select="@nro_sol" />
      </td>
      <td style="width:15%">
        <xsl:value-of  select="@nro_sol_tipo" />
      </td>
      <td style="width:16%; text-align:right">
        <xsl:attribute name="title">
          <xsl:value-of  select="concat(foo:FechaToSTR(string(@fe_alta)),' ',foo:HoraToSTR(string(@fe_alta)))" />
        </xsl:attribute>
        &#160;<xsl:value-of select="foo:FechaToSTR(string(@fe_alta))"/>
      </td>
      <td style="width:13.5%; text-align:right">
        <xsl:value-of select="concat('$',format-number(@monto,'#.00'))"/>
      </td>
      <td style="width:9%; text-align:right">
        <xsl:value-of select="@plazo"/>
      </td>
      <td style="width:16.5%" name="descripcion_estados">
        <xsl:attribute name="style">
          <xsl:value-of select="@sol_estado_estilo"/>
        </xsl:attribute>
        <xsl:value-of select="@sol_estado_desc"/>
      </td>
      <td style="width:16%; text-align:right">
        <xsl:attribute name="title">
          <xsl:value-of select="concat(foo:FechaToSTR(string(@fe_estado)),' ',foo:HoraToSTR(string(@fe_estado)))" />
        </xsl:attribute>
        <xsl:value-of select="foo:FechaToSTR(string(@fe_estado))"/>
      </td>
      <td style="align:center; text-align:center; width:5%">
        <img src="../../voii/image/icons/editar.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">
            parent.ver_solicitud('<xsl:value-of select="@nro_sol"/>','<xsl:value-of select="@nro_sol_tipo"/>','<xsl:value-of  select="$apenom" />',event)
          </xsl:attribute>
        </img>
      </td>
      <!--<td style='text-align: center; width:5%'>
        <center>
          <img src="../../fw/image/icons/eliminar.png" style="cursor:pointer">
            <xsl:attribute name="onclick">
              parent.botonEliminar('<xsl:value-of select=""/>')
            </xsl:attribute>
          </img>
        </center>
      </td>-->
    </tr>
  </xsl:template>
</xsl:stylesheet>