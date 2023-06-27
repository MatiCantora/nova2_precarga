<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
        <title>NOSIS CDAs</title>
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

          function window_onresize() {
            var body = $$("BODY")[0],
                altoDiv = body.clientHeight - 50

            try {
              $("divBody").setStyle({ height: altoDiv + "px" })
            }
            catch(e) {}
          }

          function window_onload() {
            window_onresize()
          }
        </script>
      </head>

      <body style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF" onresize="window_onresize()" onload="window_onload()">

          <xsl:choose>
              <xsl:when test="not(xml/rs:data/z:row/@nosis_cda)">
                  <center>
                      <h3 style="color: #333333; margin: 2em 0 5px;">No hay CDAs asociados a ésta empresa</h3>
                      <p style="color: #AAAAAA; margin: 0 0 1em;">Puede agregar CDAs haciendo clic en el botón de abajo</p>
                  </center>
              </xsl:when>
              <xsl:otherwise>
                  <table class="tb1 highlightOdd highlightTROver" id="tbNosisCdas">
                      <tr class="tbLabel">
                          <td style="width: 3%; text-align: center;">-</td>
                          <td style="width: 8%;"><script>campos_head.agregar('CDA', 'true', 'nosis_cda')</script></td>
                          <td style="width: 27%;"><script>campos_head.agregar('Descripción', 'true', 'nosis_cda_desc')</script></td>
                          <td style="width: 21%;">Permiso Grupo</td>
                          <td style="width: 21%;">Permiso</td>
                          <td style="width: 5%;">Vigente</td>
                          <td style="width: 8%; text-align: center;">Acciones</td>
                          <td style="width: 7%; text-align: center;">Orden</td>
                      </tr>
                      <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
                  </table>
              </xsl:otherwise>
          </xsl:choose>

        <div id="div_boton_agregar" style="margin-top: 0.5em;">
          <center>
            <img onclick="window.parent.agregar_cda()" src="/FW/image/icons/agregar.png" style="cursor:pointer" title="Agregar CDA" />
          </center>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <!--*** Capturar variable NOSIS_CDA usada frecuentemente ***-->
    <xsl:variable name="nosis_cda" select="@nosis_cda"/>
    <tr data-nosis_cda="{$nosis_cda}" data-nosis_cda_desc="{@nosis_cda_desc}" data-nro_permiso_grupo="{@nro_permiso_grupo}" data-nro_permiso="{@nro_permiso}" data-orden="{@orden}" data-vigente="{@vigente}">
      <td style="width: 3%; text-align: center;">
        <script type="text/javascript" language="javascript">window.parent.listaCdas.push(<xsl:value-of select="$nosis_cda"/>)</script>
        <input name="radio_cda" onclick="window.parent.cargar_cdas_bancos({$nosis_cda})" style="cursor: pointer" title="Ver bancos relacionados" type="radio" />
      </td>
      <td style="width: 8%;"><xsl:value-of select="$nosis_cda"/></td>
      <td style="width: 27%;"><xsl:value-of select="@nosis_cda_desc"/></td>
      <td style="width: 21%;">
        <xsl:choose>
          <xsl:when test="@nro_permiso_grupo_desc != ''"><xsl:value-of select="@nro_permiso_grupo_desc"/></xsl:when>
          <xsl:otherwise>INVALIDO</xsl:otherwise>
        </xsl:choose>
        (<xsl:value-of select="@nro_permiso_grupo"/>)
          <input id="permiso_grupo_{$nosis_cda}" name="permiso_grupo_{$nosis_cda}" type="hidden" value="{@nro_permiso_grupo}" />
      </td>
      <td style="width: 21%;">
        <xsl:choose>
          <xsl:when test="@nro_permiso_desc != ''"><xsl:value-of select="@nro_permiso_desc"/></xsl:when>
          <xsl:otherwise>INVALIDO</xsl:otherwise>
        </xsl:choose>
        (<xsl:value-of select="@nro_permiso"/>)
      </td>
      <td style="width: 5%; text-align: center;">
        <xsl:choose>
          <xsl:when test="@vigente = 'True'">SI</xsl:when>
          <xsl:otherwise>NO</xsl:otherwise>
        </xsl:choose>
      </td>
      <td style="width: 8%; text-align: center;">
        <img alt="Editar CDA {$nosis_cda}" onclick="window.parent.editar_cda(this, {$nosis_cda})" src="/FW/image/icons/editar.png" style="cursor: pointer" title="Editar CDA {$nosis_cda}" />
        &#160;
        <img alt="Eliminar CDA {$nosis_cda}" onclick="window.parent.eliminar_cda(this, {$nosis_cda})" src="/FW/image/icons/eliminar.png" style="cursor: pointer" title="Eliminar CDA {$nosis_cda}" />
      </td>
      <td style="width: 7%; text-align: center;">
        <img alt="Bajar" onclick="window.parent.bajar_fila(this)" src="/FW/image/icons/down_a.png" style="cursor:pointer" title="Bajar fila" />
        <img alt="Subir" onclick="window.parent.subir_fila(this)" src="/FW/image/icons/up_a.png" style="cursor:pointer" title="Subir fila" />
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>