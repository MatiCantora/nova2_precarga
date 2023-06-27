<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

    <xsl:include href="..\xsl_includes\js_formato.xsl" />
    <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

    <xsl:template match="/">
      <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
        <title>Control de Integridad</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <style type="text/css">
          .sin-resultados { max-width: 350px; margin: 0 auto; padding: 5em 0 0 0; text-align: center; color: 3f3f3f; }
          tr { white-space: nowrap !important; }
          .estado { text-align: center !important; font-size: 0.85em !important; color: #ffffff; }
          .estado.no-encontrado { background-color: #fe5454aa; }
          .estado.modificado { color: #3f3f3f; background-color: #fda402CC; }
          .estado.ok { background-color: #2eca5ecc; }
        </style>
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
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
          campos_head.orden         = '<xsl:value-of select="xml/params/@orden"/>'

          if (mantener_origen == '0')
            campos_head.nvFW = window.parent.nvFW
        </script>

        <script type="text/javascript">
          <![CDATA[
          var cantidad_total = 0;



          function window_onload()
          {
              calcular_totales()
            
              if (cantidad_total)
                  parent.toogleUpdateButtons(true);
            
              window_onresize()
          }



          function window_onresize()
          {
              try
              {
                  var body_h      = $$('BODY')[0].getHeight();
                  var divHeader_h = $('divHeader').getHeight();
                  var h           = body_h - divHeader_h - $('tbTotales').getHeight()
              
                  if (h > 0)
                      $('divMain').setStyle({ height: h + 'px', overflow: 'auto' });
              }
              catch (e) {}

              campos_head.resize('header_tbl', 'main')
          }



          function calcular_totales()
          {
              try
              {
                  var cantidad_modificados    = $$('.estado[data-estado=2]').length;
                  var cantidad_no_encontrados = $$('.estado[data-estado=1]').length;
                  cantidad_total              = cantidad_modificados + cantidad_no_encontrados;

                  $('cantidadTotal').innerText         = cantidad_total;
                  $('cantidadModificados').innerText   = cantidad_modificados;
                  $('cantidadNoEncontrados').innerText = cantidad_no_encontrados;
              }
              catch (e) {}
          }
          ]]>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <p class="sin-resultados">No se encontraron objetos que comprometan la integridad en base a los filtros proporcionados.</p>
          </xsl:when>
          
          <xsl:otherwise>
            <div id="divHeader">
              <table id="header_tbl" class="tb1">
                <tr class="tbLabel">
                  <td id="field_checkbox" style="width: 30px; text-align: center;">
                    <input type='checkbox' id='chbx_master' onclick='parent.check_all();' style='cursor: pointer;' />
                  </td>
                  <td style="width: 5%; text-align: center;">Cod. Mód. Ver.</td>
                  <td style="width: 5%; text-align: center;">Módulo Ver.</td>
                  <td style="width: 25%; text-align: center;">
                    <script>campos_head.agregar('Path', 'true', 'path')</script>
                  </td>
                  <td style="width: 7%; text-align: center;">
                    <script>campos_head.agregar('Tipo', 'true', 'cod_obj_tipo')</script>
                  </td>
                  <td style="width: 20%; text-align: center;">
                    <script>campos_head.agregar('Objeto', 'true', 'objeto')</script>
                  </td>
                  <td style="width: 5%; text-align: center;">
                    <script>campos_head.agregar('Cod. Pasaje', 'true', 'cod_pasaje')</script>
                  </td>
                  <td style="width: 10%; text-align: center;">
                    <script>campos_head.agregar('Tipo Dep.', 'true', 'cod_obj_tipo_dep')</script>
                  </td>
                  <td style="width: 10%; text-align: center;">Objeto Dep.</td>
                  <td style="width: 8%; text-align: center;">
                    <script>campos_head.agregar('Estado', 'true', 'resStatusDesc')</script>
                  </td>
                  <td style="width: 5%; text-align: center;">Detalle</td>
                </tr>
              </table>
            </div>

            <div id="divMain">
              <table id="main" name="main" class="tb1 highlightEven highlightTROver scroll">
                <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
              </table>
            </div>

            <table class="tb1" id="tbTotales">
              <tr class="tbLabel">
                <td>&#160;</td>
                <td style="width: 150px; text-align: right; font-weight: 700;">Total&#160;</td>
                <td style="width: 50px; text-align: center;" id="cantidadTotal"></td>
                <td style="width: 150px; text-align: right; font-weight: 700;">Modificados&#160;</td>
                <td style="width: 50px; text-align: center; background-color: orange !important; color: black;" id="cantidadModificados"></td>
                <td style="width: 150px; text-align: right; font-weight: 700;">No encontrados&#160;</td>
                <td style="width: 50px; text-align: center; background-color: red !important;" id="cantidadNoEncontrados"></td>
              </tr>
            </table>
          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>


  <xsl:template match="z:row" mode="row1">
    <tr name="datarow">

      <xsl:attribute name="cod_modulo_version">
        <xsl:value-of select="@cod_modulo_version" />
      </xsl:attribute>
      <xsl:attribute name="cod_objeto">
        <xsl:value-of select="@cod_objeto" />
      </xsl:attribute>
      <xsl:attribute name="objeto">
        <xsl:value-of select="@objeto" />
      </xsl:attribute>
      <xsl:attribute name="path">
        <xsl:value-of select="@path" />
      </xsl:attribute>
      <xsl:attribute name="cod_obj_tipo">
        <xsl:value-of select="@cod_obj_tipo" />
      </xsl:attribute>
      <xsl:attribute name="resStatus">
        <xsl:value-of select="@resStatus" />
      </xsl:attribute>
      <xsl:attribute name="cod_pasaje">
        <xsl:value-of select="@cod_pasaje" />
      </xsl:attribute>

      <td name="chbx_td" style="width: 30px; text-align: center;">
        <input style="border: none; cursor: pointer;" type="checkbox" name="chbx_group" value="">
          <xsl:if test="number(@cod_pasaje) > 0">
            <xsl:attribute name="disabled">disabled</xsl:attribute>
          </xsl:if>
        </input>
      </td>

      <td title="{@cod_modulo_version}" style="text-align: right;">
        <xsl:value-of select="@cod_modulo_version" />
      </td>

      <td title="{@modulo_version}" style="text-align: right;">
        <xsl:value-of select="@modulo_version" />
      </td>

      <td title="{@path}">
        <xsl:value-of select="@path" />
      </td>

      <td>
        <xsl:choose>
            <!-- Objetos simples -->
            <xsl:when test="@cod_obj_tipo = 1"><xsl:text>Tabla</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 2"><xsl:text>Vista</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 3"><xsl:text>SP</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 4"><xsl:text>Directorio</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 5"><xsl:text>Archivo</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 6"><xsl:text>Función</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 8"><xsl:text>Datos</xsl:text></xsl:when>
          
            <!-- Objetos complejos -->
            <xsl:when test="@cod_obj_tipo = 7"><xsl:text>Transferencia</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 9"><xsl:text>Permiso Grupo</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 10"><xsl:text>Grupo</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 12"><xsl:text>Pizarra</xsl:text></xsl:when>
            <xsl:when test="@cod_obj_tipo = 13"><xsl:text>Parámetro</xsl:text></xsl:when>
            
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
      </td>

      <td title="{@objeto}">
        <xsl:value-of select="@objeto" />
      </td>

      <td style="text-align: right;">
        <xsl:value-of select="@cod_pasaje" />
      </td>
      
      <td>
        <xsl:choose>
          <xsl:when test="@cod_obj_tipo_dep = 7">
            <xsl:attribute name="title">Transferencia</xsl:attribute>
            <xsl:text>Transferencia</xsl:text>
          </xsl:when>
          <xsl:when test="@cod_obj_tipo_dep = 9">
            <xsl:attribute name="title">Permiso Grupo</xsl:attribute>
            <xsl:text>Permiso Grupo</xsl:text>
          </xsl:when>
          <xsl:when test="@cod_obj_tipo_dep = 10">
            <xsl:attribute name="title">Grupo</xsl:attribute>
            <xsl:text>Grupo</xsl:text>
          </xsl:when>
          <xsl:when test="@cod_obj_tipo_dep = 12">
            <xsl:attribute name="title">Pizarra</xsl:attribute>
            <xsl:text>Pizarra</xsl:text>
          </xsl:when>
          <xsl:when test="@cod_obj_tipo_dep = 13">
            <xsl:attribute name="title">Parámetro</xsl:attribute>
            <xsl:text>Parámetro</xsl:text>
          </xsl:when>
          <xsl:otherwise>&#160;</xsl:otherwise>
        </xsl:choose>
      </td>
      
      <td title="{@objeto_dep}">
        <xsl:value-of select="@objeto_dep" />
      </td>
      
      <xsl:variable name="resStatusDesc" select="@resStatusDesc" />

      <td>
        <!--
          OK = 0
          objeto_no_econtrado = 1
          objeto_modificado   = 2
          archivo_sobrante    = 3
        -->
        <xsl:choose>
          <xsl:when test="$resStatusDesc = 'objeto_no_econtrado'">
            <xsl:attribute name="class">estado no-encontrado</xsl:attribute>
            <xsl:attribute name="title">Objeto no encontrado en implementación</xsl:attribute>
            <xsl:attribute name="data-estado">1</xsl:attribute>
            <xsl:text>NO ENCONTRADO</xsl:text>
          </xsl:when>
          <xsl:when test="$resStatusDesc = 'objeto_modificado'">
            <xsl:attribute name="class">estado modificado</xsl:attribute>
            <xsl:attribute name="title">Objeto modificado</xsl:attribute>
            <xsl:attribute name="data-estado">2</xsl:attribute>
            <xsl:text>MODIFICADO</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="class">estado ok</xsl:attribute>
            <xsl:attribute name="style">Objeto Ok</xsl:attribute>
            <xsl:attribute name="data-estado">0</xsl:attribute>
            <xsl:text>OK</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </td>

      <td style="text-align: center;">
        <img alt="ver_detalle" 
             src='/FW/image/icons/ver.png' 
             style='border: none; cursor: pointer;' 
             title='Ver detalle {@objeto}' 
             onclick="parent.verObjetoIntegridad({@cod_objeto}, '{@objeto}', {foo:stringToScriptString(string(@path))}, {@cod_obj_tipo}, '{@extension}', {@resStatus}, {foo:stringToScriptString(string(@comentario))})" />
      </td>

    </tr>
  </xsl:template>
</xsl:stylesheet>