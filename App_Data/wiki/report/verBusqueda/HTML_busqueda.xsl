<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

    <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

    <msxsl:script language="javascript" implements-prefix="foo">
	    <![CDATA[
	      function get_filename(f_nombre, f_ext, f_nro_tipo) {
		      if (f_ext != '')
		          return f_nombre + '.' + f_ext
		      else
		          return f_nombre 
        }
	    ]]>
    </msxsl:script>

    <xsl:template match="/">
	    <html>
        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <head>
              <script type="text/javascript" language="javascript">
                <xsl:comment>  
                  <![CDATA[
                    function window_onload() {
                        window_onresize()
                    }

                    function window_onresize() {
                        try {
                            var dif                 = Prototype.Browser.IE ? 5 : 2,
                                body_height         = $$('body')[0].getHeight(),
                                result_vacio_height = $('result_vacio').getHeight(),
                                alto                = result_vacio_height + dif,
                                ancho               = $$('body')[0].getWidth()

                            window.top.win.setSize(ancho, alto)
                        }
                        catch(e) {}
                    }
                  ]]>
                </xsl:comment>
              </script>
            </head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow: hidden">
              <div id="result_vacio" style="width: 100%; text-align: center; font-family: Arial, sans-serif; height: 100px; position: absolute; top: 50%; left: 50%; margin-top: -50px; margin-left: -50%;">
                <h3>Se ha completado la búsqueda</h3>
                <p style="color: #AAAAAA;">No hay resultados que mostrar</p>
              </div>
                <!--<span id="result_vacio" style="height:50px;">Se ha completado la búsqueda. No hay resultados que mostrar.</span>-->
            </body>
          </xsl:when>

          <xsl:otherwise>
			      <head>
              <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
              <title>Buscar Referencias</title>
              <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

              <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
              <script type="text/javascript" language="javascript" src="/fw/script/nvFW_BasicControls.js"></script>
              <script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>
              <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>

				      <script type="text/javascript" language="javascript">
                <xsl:comment>
                  var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
                  
                  campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                  campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
                  campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
                  campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
                  campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
                  campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
                  campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>

                  if (mantener_origen == '0')
                      campos_head.nvFW = window.parent.nvFW

                  <![CDATA[
                    /*function ref_seleccionar(nro_ref) {
                        parent.ref_seleccionar(nro_ref)
                    }*/

                    function window_onload() {
                        window_onresize()
                    }

                    function window_onresize() {
			                  try {
                            var dif              = Prototype.Browser.IE ? 5 : 2,
				                        body_height      = $$('body')[0].getHeight(),
				                        tb_titulo_height = $('tb_titulo').getHeight(),
				                        div_res_height   = $('div_res').getHeight(),
				                        alto             = tb_titulo_height + div_res_height + dif

				                    if (alto > body_height) {
                                    alto  = body_height
                                    valor = alto - tb_titulo_height - dif
                                    $('div_res').setStyle({ height: valor })
                            }
                            else {
                                $('div_res').setStyle({ height: body_height - tb_titulo_height - dif + 'px' })       
                            }

                            $('tb_res_detalle').getHeight() - $('div_res').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)

                            var ancho = $$('body')[0].getWidth()
                            window.top.winBuscar_res.setSize(ancho, alto)
				                }
			                  catch(e) {}
			              }

			              function tdScroll_hide_show(show) {
                        var i = 1

                        while (i <= campos_head.recordcount) {
                            if (show && $('tdScroll' + i) != undefined)
                                $('tdScroll' + i).show()

                            if (!show && $('tdScroll' + i) != undefined)
                                $('tdScroll' + i).hide()

                            i++
                        }
                    }

                    function ok_seleccionar(e) {
                        Event.element(e).src = "/wiki/image/icons/ok_seleccionado.png"
                    }

                    function ok_no_seleccionar(e) {
                        Event.element(e).src = "/wiki/image/icons/ok_no_seleccionado.png"
                    }
                  ]]>
                </xsl:comment>
              </script>
              <style type="text/css">
                .tbFiles { WIDTH: 100%; font: 11px Arial, sans-serif; }
              </style>
			    </head>
          <body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden; background: #FFF;">
            <table class="tb1" id="tb_titulo">
              <tr class="tbLabel">
		            <td style="width: 5%; text-align: center;">-</td>
	              <td style="width: 45%"><b>Nombre</b></td>
	              <td style="width: 44%" colspan="3"><b>Título</b></td>
	              <td style="width: 5%"><b>Tipo</b></td>
                <td style="width: 1% !Important">&#160;</td>
	            </tr>
            </table>
            <div id="div_res" style="width: 100%; overflow: auto">
              <table class="tb1 highlightTROver" id="tb_res_detalle">
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>
          </body>
        </xsl:otherwise>
      </xsl:choose>
	  </html>		
	</xsl:template>

    <xsl:template match="z:row">
      <xsl:param name="filename" select="foo:get_filename(string(@f_nombre), string(@f_ext), string(@f_nro_tipo))" />
	    <xsl:variable name="nro_ref" select="@id"></xsl:variable>
	    <xsl:variable name="pos" select="position()" />
	    <xsl:variable name="nro_ref_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@id" />
        <tr id="tr_ver{$pos}" style="cursor: hand; cursor: pointer;">
          <!--<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
          <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>-->
          <xsl:choose>
            <xsl:when test="@es_ref = 'True'"> 
              <xsl:choose>
                <xsl:when test="$nro_ref != $nro_ref_ant or $pos = 1">
                  <td style="width: 5%; text-align: center; vertical-align: middle;">
                    <img name="imagen_ok" src='/wiki/image/icons/ok_no_seleccionado.png' style="cursor:pointer" border='0' align='absmiddle' hspace='2' onclick='top.frame_ref_recargar("{@id}")' onmousemove="ok_seleccionar(event)" onmouseout="ok_no_seleccionar(event)" />
                    <!--<img name="imagen_ok" src='/wiki/image/icons/ok_no_seleccionado.png' style="cursor:pointer" border='0' align='absmiddle' hspace='2' onclick='ref_seleccionar("{@id}")' onmousemove="ok_seleccionar(event)" onmouseout="ok_no_seleccionar(event)" />-->
                      <!--<xsl:attribute name="onclick">ref_seleccionar('<xsl:value-of select="@id"/>')</xsl:attribute>
                    </img>-->
                  </td>
                  <td style="width: 45%; vertical-align: middle;">
                    <xsl:value-of select="@id"/> - <xsl:value-of select="@referencia"/>
                  </td>
                  <td style="width: 44%; vertical-align: middle" colspan="3">
                    <xsl:value-of select="@nro_ref_doc"/> - <xsl:value-of select="@ref_doc_titulo"/>
                  </td>
                  <td style="width: 5%; vertical-align: middle; text-align: center;">
                    <xsl:if test="@en_doc = 'True'">
                      <img src="/wiki/image/icons/documento.png" title="El resultado se encuentra en el documento" />
                    </xsl:if>
                    <xsl:if test="@en_doc = 'False'">
                      <img src="/fw/image/icons/info.png" title="El resultado se encuentra en la referencia" />
                    </xsl:if>
                  </td>
                  <td style='width: 1% !Important' id='tdScroll{$pos}'>
                    <!--<xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>-->
                    &#160;&#160;
                  </td>
                </xsl:when>
                <xsl:when test="$nro_ref = $nro_ref_ant">
                  <td style="width: 5%; text-align: center;"></td>
                  <td style="width: 45%; vertical-align: middle;">
                    <!--<xsl:value-of  select="@nro_ref_doc" /> - <xsl:value-of  select="@ref_doc_titulo" />-->
                  </td>
                  <td style="width: 44%; vertical-align: middle;" colspan="3">
					          <xsl:value-of select="@nro_ref_doc" /> - <xsl:value-of select="@ref_doc_titulo" />
                  </td>
                  <td style="width: 5%; vertical-align: middle; text-align: center;">
                    <xsl:if test="@en_doc = 'True'">
                      <img src="/wiki/image/icons/documento.png" title="El resultado se encuentra en el documento"/>
                    </xsl:if>
                    <xsl:if test="@en_doc = 'False'">
                      <img src="/fw/image/icons/info.png" title="El resultado se encuentra en la referencia"/>
                    </xsl:if>
                  </td>
                  <td style='width: 1% !Important' id='tdScroll{$pos}'>
                    <!--<xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;-->
                    &#160;
                  </td>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@es_ref = 'False'">
              <xsl:attribute name='id'>trFile_<xsl:value-of select="@id"/></xsl:attribute>
              <td style="width: 5%; text-align: center; vertical-align: middle;">
                <xsl:if test="@f_nro_tipo = 1">
                  <a id="link_{@id}" href="/FW/files/file_get.aspx?f_id={@id}" target="_blank">
                    <!--<xsl:attribute name="id">link_<xsl:value-of select="@id"/></xsl:attribute>-->
                    <!--<xsl:attribute name="href">/FW/file_dialog/file_get.aspx?f_id=<xsl:value-of select="@id"/></xsl:attribute>-->
                    <!--<xsl:attribute name="target">_blank</xsl:attribute>-->
                    <img name="imagen_ok" src='/wiki/image/icons/ok_no_seleccionado.png' style="cursor:pointer" border='0' align='absmiddle' hspace='2' onmousemove="ok_seleccionar(event)" onmouseout="ok_no_seleccionar(event)" />
                  </a>
                </xsl:if>
              </td>
              <td style='text-align: left; width: 45%;' title='{$filename}'>
                <!--<xsl:attribute name='title'><xsl:value-of select="$filename" /></xsl:attribute>-->
                <xsl:choose>
                  <xsl:when test="string-length($filename) &#62; 45">
                    <xsl:value-of select="substring($filename, 1, 45)"/>...
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$filename"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="width:38%; vertical-align:middle" title="{$filename}">
                <!--<xsl:attribute name='title'><xsl:value-of select="$filename" /></xsl:attribute>-->
                <xsl:choose>
                  <xsl:when test="string-length($filename) &#62; 40">
                    <xsl:value-of select="substring($filename, 1, 40)"/>...
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$filename"/>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td style="text-align: center; width: 3%; cursor: hand; cursor: pointer;">
                <xsl:if test="@f_nro_tipo = 1">
                  <img src="/wiki/image/icons/propiedades.png" onclick="parent.btnPropiedades_onclick({@id})" title="Propidades" style="border: none; vertical-align: middle; margin: 0 1px;" />
                    <!--<xsl:attribute name='src'>/wiki/image/icons/propiedades.png</xsl:attribute>
                    <xsl:attribute name='onclick'>parent.btnPropiedades_onclick(<xsl:value-of select="@id"/>)</xsl:attribute>
                  </img>-->
                </xsl:if>
              </td>
              <td style="text-align: center; width: 3%; cursor: hand; cursor: pointer;">
                <xsl:if test="@f_nro_tipo = 1">
                  <img src="/fw/image/icons/buscar.png" onclick="parent.btnPreview_onclick({@id})" title="Previsualizar" style="border: none; vertical-align: middle; margin: 0 1px;" />
                    <!--<xsl:attribute name='src'>/fw/image/icons/buscar.png</xsl:attribute>
                    <xsl:attribute name='onclick'>parent.btnPreview_onclick(<xsl:value-of select="@id"/>)</xsl:attribute>
                  </img>-->
                </xsl:if>
              </td>
              <td style="width: 5%; vertical-align: middle; text-align: center;">
                <xsl:if test="@f_nro_tipo = 1">
                  <img src="/wiki/image/icons/file_{@f_ext}.png" style="border: none; vertical-align: middle; margin: 0 1px;" title="El resultado se encuentra en el archivo" />
                    <!--<xsl:attribute name='src'>/wiki/image/icons/file_<xsl:value-of select="@f_ext"/>.png</xsl:attribute>
                  </img>-->
                </xsl:if>
              </td>
              <td style='width: 1% !Important;' id='tdScroll{$pos}'>
                <!--<xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>-->
                &#160;&#160;
              </td>
            </xsl:when>
          </xsl:choose>
        </tr>
    </xsl:template>
</xsl:stylesheet>