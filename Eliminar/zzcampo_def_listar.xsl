<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:vbuser="urn:vb-scripts">
  <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Créditos</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
        <!--<script type="text/javascript" src="/fw/script/nvFW_windows.js" language="JavaScript"></script>-->
        <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
        <script language="javascript" type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW

          function window_onresize()
          {
          var body = $$("BODY")[0]
          var altoDiv = body.clientHeight - 50
          $("divBody").setStyle({height: altoDiv + "px" })

          campos_head.resize("tbCabe", "tbDetalle")
          }

          function window_onload()
          {
          window_onresize()
          }

          function campo_def_editar(campo_def)
          {
          var win = top.nvFW.createWindow({url: "../eliminar/campos_def_abm.aspx?campo_def=" + campo_def, width: "1100", height: "400", top:"50", })
          //centered = true;
          //centerTop = top;
          //centerLeft = left;
          //win.show()
          //win.show(true)
          win.showCenter(true)
          }

        </script>

      </head>
      <body  style="width:100%;height:100%;overflow:hidden" onresize="window_onresize()" onload="window_onload()">
        <table class="tb1 " id="tbCabe">
          <tr class="tbLabel">
            <td style="width:180px">
              <script>campos_head.agregar('campo def', 'true', 'campo_def')</script>
            </td>
            <td>
              <script>campos_head.agregar('Descripción', 'true', 'descripcion')</script>
            </td>
            <td style="width:300px" >
              <script>campos_head.agregar('Tipo', 'true', 'nro_campo_tipo')</script>
            </td>
            <td style="width:180px">Depende de</td>
            <td style="width:80px">P. codigo</td>
            <td style="width:80px" nowrap="true">
              <script>campos_head.agregar('Cache', 'true', 'cacheControl')</script> 
            </td>
            <td style="width:40px; cursor:pointer">
              <script>campos_head.agregar_exportar()</script> 
            </td>
          </tr>
        </table>
        <div style="width:100%; height:300px;overflow-y:auto" id="divBody">
        <table  class="tb1  highlightOdd highlightTROver layout_fixed" id="tbDetalle" >
          <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
        </table>
        </div>
        <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
        </script>
        
        <script type="text/javascript">
          campos_head.resize("tbCabe", "tbDetalle")
        </script>
        <!--<xsl:value-of select="/xml/params/@orden"/>
        <br/>
        <xsl:value-of select="/xml/params/@cache"/>-->
        
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <tr>
      <td>
        <xsl:value-of  select="@campo_def" />
      </td>
      <td >
        <xsl:value-of  select="@descripcion" />
      </td>
      <td>
        <xsl:value-of  select="@campo_tipo" /> 
      </td>
      <td>
        <xsl:value-of  select="@depende_de" />
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="@permite_codigo = 'False'">No</xsl:when>
          <xsl:otherwise>Si</xsl:otherwise>
        </xsl:choose>
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="@cacheControl = 'none'">No</xsl:when>
          <xsl:otherwise>
            <xsl:value-of  select="@cacheControl" />
          </xsl:otherwise>
        </xsl:choose>
      </td>
      <td style="align:center; text-align:center">
        <img src="/fw/image/icons/editar.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">campo_def_editar('<xsl:value-of select="@campo_def"/>')</xsl:attribute>
        </img>
      </td>
    </tr>
  </xsl:template>
 

</xsl:stylesheet>