<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				xmlns:vbuser="urn:vb-scripts">

  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <title>Listado Instancias Watcher</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        
        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
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
          var body_h = $$("BODY")[0].getHeight();
          var divHeader_h = $('divCabeceras').getHeight();
          var div_pag1_h = $('div_pag1').getHeight();
          var altoDiv = body_h - divHeader_h - div_pag1_h
          $("divBody").setStyle({height: altoDiv + "px" })

          campos_head.resize("header_tbl", "tbDetalle")
          }

          function window_onload()
          {
          window_onresize()
          }

          function instancia_editar(id_nvwinstancia)
          {
          parent.instancia_editar(id_nvwinstancia);

          }
        </script>
      </head>
      <body style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onresize="window_onresize()" onload="window_onload()">
          
          <xsl:choose>
              <xsl:when test="count(xml/rs:data/z:row) = 0">
                  <div style="margin: 0 auto; text-align: center;" id="divBody">
                      <h2 style="margin-top: 100px;">Sin resultados</h2>
                      <p style="color: #999;">No existe ninguna instancia con los filtros suministrados</p>
                  </div>
              </xsl:when>
              <xsl:otherwise>
                <div style="width:100%;" id="divCabeceras">
                  <table class="tb1" id="header_tbl" name="header_tbl">
                      <tr class="tbLabel">
                          <td style="width: 150px">
                              <script>campos_head.agregar('Instancia', true, 'nvwInstancia')</script>
                          </td>
                        <td style="width: 150px">
                              <script>campos_head.agregar('Watcher', true, 'nvwLabel')</script>
                          </td>
                          <td style="width: 170px">
                              <script>campos_head.agregar('Origen', true, 'dirOrigen')</script>
                          </td>
                          <td style="width: 170px">
                              <script>campos_head.agregar('Destino', true, 'dirDestino')</script>
                          </td>
                          <td >
                              <script>campos_head.agregar('Filtro', false, 'dirFiltro')</script>
                          </td>
                          <td style="width: 30px; cursor: pointer; text-align: center;">
                              <img alt="Exportar Excel" src="/fw/image/filetype/xlsx.png" onclick="parent.exportar()" title="Exportar a Excel"/>
                          </td>
                      </tr>
                  </table>
                </div>
                
                <div id="divBody">
                    <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
                    </table>
                </div>
                
                <div style="float:left" id="div_pag1" class="divPages">
                  <script type="text/javascript">
                    document.write(campos_head.paginas_getHTML())
                  </script>
                </div>

                <script type="text/javascript">
                  campos_head.resize("header_tbl", "tbDetalle")
                </script>
              </xsl:otherwise>
          </xsl:choose>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">
    <tr>
      <td>
        <xsl:value-of select="@nvwInstancia" />
      </td>
      <td >
        <xsl:value-of select="@nvwLabel" />
      </td>
      <td>
        <xsl:value-of select="@dirOrigen" /> 
      </td>
      <td>
        <xsl:value-of select="@dirDestino" />
      </td>
      <td>
        <xsl:value-of select="@dirFiltro" />
      </td>
      <td style="width: 30px; align: center; text-align: center;">
        <img src="/fw/image/icons/editar.png" style="cursor: pointer;" onclick="instancia_editar('{@id_nvwinstancia}')" />
      </td>
    </tr>
  </xsl:template>

</xsl:stylesheet>