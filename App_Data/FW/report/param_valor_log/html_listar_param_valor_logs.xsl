<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\report\xsl_includes\js_formato.xsl" />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <head>

        <title>Histórico</title>
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
              var tbCabecera_h = $('tbCabecera').getHeight();
              var div_pag_h = $('div_pag').getHeight();
              var body_h = $$('body')[0].getHeight();
              
              $('divDetalles').setStyle({ height: body_h - tbCabecera_h })
              
              campos_head.resize('tbCabecera','tbDetalles');
            }
                       
           
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <p style="margin: 0; font-weight: bold; color: grey;">No se encontró información</p>
            </div>
          </xsl:when>
          <xsl:otherwise>

            <table class="tb1" id="tbCabecera">
              <tr class="tbLabel">
                <td style='width:25%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Acción', true,'accion')</script>
                </td>
                <td style='width:25%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Valor', true,'valor')</script>
                </td>
                <td style='width:25%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Momento', true,'momento')</script>
                </td>
                <td style='width:25%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Operador', true,'login')</script>
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

          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <xsl:variable name="apenom" select="concat(string(@nombre),' ',string(@apellido))"/>
    <tr name="dataRow">
      <!-- DATOS -->
      
      <xsl:choose>
        <xsl:when test="@accion = 'I'">
          <td style="width:25%; text-align:left;background-color: #DFF2BF ;color:#270">
            Insertado
          </td>
        </xsl:when>
        <xsl:when test="@accion = 'D'">
          <td style="width:25%; text-align:left;background-color: #FFBABA;color:#D8000C">
            Eliminado
          </td>
        </xsl:when>
        <xsl:when test="@accion = 'U'">
          <td style="width:25%; text-align:left;background-color: #ffff9e ;color:#a3a21b">
            Modificado
          </td>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
     
      <td style="width:25%; text-align:left">
        <xsl:attribute name="title">
          <xsl:value-of select="@valor"/>
        </xsl:attribute>
        <xsl:value-of select="@valor"/>
      </td>
      <td style="width:25%; text-align:right">
        <xsl:attribute name="title">
          <xsl:value-of  select="concat(foo:FechaToSTR(string(@momento)),' ',foo:HoraToSTR(string(@momento)))" />
        </xsl:attribute>
        &#160;<xsl:value-of select="foo:FechaToSTR(string(@momento))"/>
      </td>
      <td style="width:25%; text-align:left">
        <xsl:value-of select="@login"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>