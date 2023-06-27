<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

    <xsl:include href="..\xsl_includes\js_formato.xsl"  />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title></title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                <style type="text/css">
                    tr {
                    white-space: nowrap !important;
                    }
                </style>
                <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
                <script type="text/javascript" src="/FW/script/prototype.js"></script>
                <script type="text/javascript" src="/FW/script/tXML.js"></script>

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
              
                <script type="text/javascript" language="javascript">
                    <xsl:comment>

                    </xsl:comment>
                </script>
                <script type="text/javascript">
                    <![CDATA[
          
            function window_onload(){
                calcular_totales()
                window_onresize()
            }

            function window_onresize() {
                try {
                    var body_h = $$('BODY')[0].getHeight();
                    var divHeader_h = $('divHeader').getHeight();
                    var h = body_h - divHeader_h - $('tbTotales').getHeight()
                    if (h > 0) {
                        $('divMain').setStyle({ height: h + 'px', overflow: 'auto' });
                    }
                }                  
                catch (e) {}
                campos_head.resize('header_tbl', 'main')
            }
            
            
            function calcular_totales() {
              var estados                 = $$('.estado');
              var cantidad_total          = estados.length;
              var cantidad_modificados    = 0;
              var cantidad_no_encontrados = 0;

              $('cantidadTotal').innerText = cantidad_total;
              
              estados.each(function(item)
              {
                switch (item.getAttribute('data-estado'))
                {
                  case '1': cantidad_no_encontrados++; break;
                  case '2': cantidad_modificados++; break;
                }
              });
              
              $('cantidadModificados').innerText   = cantidad_modificados;
              $('cantidadNoEncontrados').innerText = cantidad_no_encontrados;
            }
          ]]>
                </script>
            </head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%; height:100%;overflow:hidden">

                <div id="divHeader">
                    <table id="header_tbl" class="tb1">
                        <tr class="tbLabel">

                            <td id="field_checkbox" style="width:5%;">
                                <input type='checkbox' id='chbx_master' onclick='parent.check_all();' />
                            </td>

                            <td style="width:5%;">
                                Cod Módulo Versión
                            </td>

                            <td style="width:5%;">
                                Módulo Versión
                            </td>

                            <td style="width:5%;">
                              Cod Pasaje
                            </td>

                          <td style="width:30%;">
                              <script>campos_head.agregar('Path', 'true', 'path')</script>
                            </td>
                            <td style="width:15%;">
                              <script>campos_head.agregar('Obj. Tipo', 'true', 'cod_obj_tipo')</script>
                            </td>
                            <td style="width:15%;">
                              <script>campos_head.agregar('Objeto', 'true', 'objeto')</script>
                            </td>

                            <td style="width:10%;">
                              <script>campos_head.agregar('Estado', 'true', 'resStatusDesc')</script>
                            </td>

                            <td style="width:10%;">
                                Detalle
                            </td>

                        </tr>
                    </table>
                </div>

                <div id="divMain">
                    <table id="main" name="main" class="tb1 highlightEven highlightTROver scroll" >
                        <xsl:apply-templates select="xml/rs:data/z:row" mode="row1"  />
                    </table >
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

            </body>
        </html>
    </xsl:template>


    <xsl:template match="z:row" mode="row1">
        <tr name="datarow">

            <xsl:attribute name="cod_modulo_version">
                <xsl:value-of  select="@cod_modulo_version" />
            </xsl:attribute>
            <xsl:attribute name="cod_objeto">
                <xsl:value-of  select="@cod_objeto" />
            </xsl:attribute>

            <xsl:attribute name="objeto">
                <xsl:value-of  select="@objeto" />
            </xsl:attribute>

            <xsl:attribute name="path">
                <xsl:value-of  select="@path" />
            </xsl:attribute>

            <xsl:attribute name="cod_obj_tipo">
                <xsl:value-of  select="@cod_obj_tipo" />
            </xsl:attribute>

            <xsl:attribute name="resStatus">
                <xsl:value-of  select="@resStatus" />
            </xsl:attribute>
            
            <td name="chbx_td">
                <input style="border:0px" type="checkbox" name="chbx_group"  value=""></input>
            </td>

            <td>
                <div>
                    <xsl:attribute name="title">
                        <xsl:value-of  select="@cod_modulo_version" />
                    </xsl:attribute>

                    <xsl:value-of  select="@cod_modulo_version" />
                </div>
            </td>

            <td>
                <div>
                    <xsl:attribute name="title">
                        <xsl:value-of  select="@modulo_version" />
                    </xsl:attribute>
                    <xsl:value-of  select="@modulo_version" />
                </div>
            </td>

            <td>
              <div>
                <xsl:attribute name="title">
                  <xsl:value-of  select="@cod_pasaje" />
                </xsl:attribute>

                <xsl:value-of  select="@cod_pasaje" />
              </div>
            </td>

            <td>
                <div>
                    <xsl:attribute name="title">
                        <xsl:value-of  select="@path" />
                    </xsl:attribute>
                    <xsl:value-of  select="@path" />
                </div>
            </td>

            <td>
                <div>
                    <xsl:choose>
                        <xsl:when test="@cod_obj_tipo=1">
                            <xsl:text>Tabla</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=2">
                            <xsl:text>Vista</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=3">
                            <xsl:text>SP</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=4">
                            <xsl:text>Directorio</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=5">
                            <xsl:text>Archivo</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=6">
                            <xsl:text>Función</xsl:text>
                        </xsl:when>
                        <xsl:when test="@cod_obj_tipo=8">
                            <xsl:text>Datos</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text></xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>

            <td>
                <div>
                    <xsl:attribute name="title">
                        <xsl:value-of  select="@objeto" />
                    </xsl:attribute>
                    <xsl:value-of  select="@objeto" />
                </div>
            </td>


            <td>
              <xsl:variable name="resStatusDesc" select="@resStatusDesc" />
              <div title="{$resStatusDesc}" class="estado">
                <!--
            OK = 0
            objeto_no_econtrado = 1
            objeto_modificado   = 2
            archivo_sobrante    = 3
          -->
                <xsl:choose>
                  <xsl:when test="$resStatusDesc = 'objeto_no_econtrado'">
                    <xsl:attribute name="style">color: red;</xsl:attribute>
                    <xsl:attribute name="data-estado">1</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="$resStatusDesc = 'objeto_modificado'">
                    <xsl:attribute name="style">color: orange;</xsl:attribute>
                    <xsl:attribute name="data-estado">2</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="style">color: inherit;</xsl:attribute>
                    <xsl:attribute name="data-estado">0</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>

                <xsl:value-of select="$resStatusDesc" />
              </div>
            </td>


            <td>
              <div onclick="parent.verObjetoIntegridad({@cod_objeto}, '{@objeto}', {foo:stringToScriptString(string(@path))}, {@cod_obj_tipo}, '{@extension}', {@resStatus})" style="cursor: pointer;">
                <img alt="ver_detalle" src='/FW/image/icons/ver.png' style='border: none; cursor: pointer;' title='Ver detalle' />
              </div>
              
                <!--<div>
                    <xsl:attribute name="onclick">
                        parent.verObjetoIntegridad(
                        <xsl:value-of  select="@cod_objeto" />,
                        '<xsl:value-of  select="@objeto" />',
                        <xsl:value-of  select ="foo:stringToScriptString(string(@path))"/>,
                        <xsl:value-of  select="@cod_obj_tipo" />,
                        '<xsl:value-of  select="@extension" />',
                        <xsl:value-of  select="@resStatus" />)
                    </xsl:attribute>

                    <img border='0'  title='Ver detalle' src='/FW/image/icons/ver.png' style='cursor:pointer'/>
                </div>-->
            </td>

        </tr>
    </xsl:template>
</xsl:stylesheet>





