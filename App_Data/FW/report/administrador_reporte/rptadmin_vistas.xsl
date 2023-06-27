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

        <title>Vistas</title>
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
          campos_head.recordcount = '<xsl:value-of select="xml/params/@recordcount"/>'
          campos_head.PageCount = '<xsl:value-of select="xml/params/@PageCount"/>'
          campos_head.PageSize = '<xsl:value-of select="xml/params/@PageSize"/>'
          campos_head.AbsolutePage = '<xsl:value-of select="xml/params/@AbsolutePage"/>'

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
            
              //var tbCabecera_h = $('tbCabecera').getHeight();
              //var div_pag_h = $('div_pag').getHeight();
              //var body_h = $$('body')[0].getHeight();
              
              //$('divDetalles').setStyle({ height: body_h - tbCabecera_h - div_pag_h })
            
              campos_head.resize('tbCabecera','tbDetalles');
            }
            
            
           
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
        <table class="tb1" id="tbCabecera">
          <tr class="tbLabel">
            <td style='width: 20%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Nombre Vista', true,'nombre_vista')</script>
            </td>
            <td style='width: 25%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Descripción', true,'descripcion')</script>
            </td>
            <td style='width: 20%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Grupo Permiso', true,'permiso_grupo')</script>
            </td>
            <td style='width: 5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Nro. Permiso', true,'nro_permiso')</script>
            </td>
            <td style='width: 20%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Conexión', true,'cn')</script>
            </td>
            <td style='width: 5%; text-align: center'></td>
            <td style='width: 5%; text-align: center'></td>
          </tr>
        </table>

        <div id='divDetalles' style='width: 100%; overflow: auto;'>
          <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
            <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
          </table>
        </div>

        <!--DIV DE PAGINACION-->
        <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; height: 16px;">
          <script type="text/javascript">
            if (campos_head.PageCount > 1)
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <tr>
      <!-- DATOS -->
      <td style="width:20%; text-align: left">
        <xsl:value-of  select="@nombre_vista" />
      </td>
      <td style="width:25%">
        <xsl:value-of  select="@descripcion" />
      </td>
      <td style="width:20%; text-align: left">
        <xsl:value-of select="@permiso_grupo"/>
      </td>
      <td style="width:5%; text-align:right">
        <xsl:value-of  select="@nro_permiso" />
      </td>
      <td style="width:20%">
        <xsl:value-of  select="@cn" />
      </td>     
      <td style="align:center; text-align:center; width:5%">
        <img src="../../FW/image/icons/editar.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">
            parent.editar_vista('<xsl:value-of select="@nro_vista"/>','<xsl:value-of select="@nombre_vista"/>','<xsl:value-of select="@descripcion"/>','<xsl:value-of select="@permiso_grupo"/>','<xsl:value-of select="@nro_permiso"/>','<xsl:value-of select="@cn"/>','<xsl:value-of select="@vista_columnas"/>')
          </xsl:attribute>
        </img>
      </td>
      <td style='text-align: center; width:5%'>
        <center>
          <img src="../../FW/image/icons/eliminar.png" style="cursor:pointer">
            <xsl:attribute name="onclick">
              parent.eliminar_vista('<xsl:value-of select="@nro_vista"/>', '<xsl:value-of select="@nombre_vista"/>')
            </xsl:attribute>
          </img>
        </center>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>