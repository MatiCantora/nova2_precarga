<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  <xsl:include href="..\..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
		
		var filters
		var filter_regs = new Array()
		function filter_generar(str)
		  {
		  var streg
          var reg
		  filters = str.split('|')
		  for (var i in filters)
		    {
		    streg = filters[i]
            reg = new RegExp("\\.", 'ig')
            streg = streg.replace(reg, "\\.")
            reg = new RegExp("\\*", 'ig')
            streg = streg.replace(reg, ".*")
            reg = new RegExp("\\?", 'ig')
            streg = streg.replace(reg, ".?")
            reg = new RegExp(streg, 'ig')
            filter_regs[i] = reg
		    }
		  
		  return ''
		  }
		  
		function filter_eval(filename)
		  {
		  for (var i in filter_regs)
		    {
		    var resultado = filename.match(filter_regs[i])
            if (resultado != null)
              return true
		    }
		  return false
		  }
		function get_filename(f_nombre, f_ext, f_nro_tipo)
		  {
		  if (f_ext != '')
		    return f_nombre + '.' + f_ext
		  else
		    return f_nombre 
		  }
		  function is_image(ext) {
            switch(ext.toUpperCase()){
                case 'BMP':
                case 'GIF':
                case 'JPG':
                case 'JPGE':
                case 'JPE':
                case 'PNG':
                case 'ICO':
                case 'TGA':
                case 'PCX':
                    return 1;
                    break;
                }
		    return 0;
		}
		]]>
  </msxsl:script>

  <xsl:template match="/">
    <xsl:value-of select="foo:filter_generar(string(xml/parametros/filter))"/>
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Archivos</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
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
          if (mantener_origen == '0')
          campos_head.nvFW = window.top.nvFW

        </script>
        <script type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW
          var file_actual = window.parent.file.f_id

          var f_id_sel = {}
          var files = {}
          var filter = '<xsl:value-of select="xml/parametros/filter"/>'
          var f_depende_de = '<xsl:value-of select="xml/parametros/file/@f_depende_de"/>'


          function file_onclick(f_id, event) {
              window.parent.file_onclick(files[f_id]) 
              var isSelected = f_id_sel[f_id]
              if (!event.ctrlKey) {
                    for(var f in f_id_sel ){
                      if(f_id_sel[f]){
                        $('trFile_' + f).removeClassName('trSel')
                        f_id_sel[f] = false
                      }
                    }
                    $('trFile_' + f_id).addClassName('trSel')
                    f_id_sel[f_id] = true
                    
                } else {
                
                    if (isSelected){
                        $('trFile_' + f_id).removeClassName('trSel')
                        f_id_sel[f_id] = false
                    } else {
                        $('trFile_' + f_id).addClassName('trSel')
                        f_id_sel[f_id] = true
                    }
                
                }
          }

          function file_ondblclick(f_id)
          {
          window.parent.file_ondblclick(files[f_id])
          }

          function file_up_ondblclick()
          {
          window.parent.file_up_ondblclick(file_actual)
          }




          function _selection()
          {
          if (window.getSelection)
          {
          if (window.getSelection().empty)
          {
          window.getSelection().empty();
          } // Chrome
          else
          if (window.getSelection().removeAllRanges)
          {
          window.getSelection().removeAllRanges();
          } // Firefox
          }
          else
          if (document.selection) {
          document.selection.empty();
          } // IE?
          }


          function window_onload() {
          window_onresize();
          }


          function window_onresize()
          {
          if (Prototype.Browser.IE)
          {
          var body_height = $$('body')[0].getHeight()
          var height = body_height - 18
          $('file_cont').setStyle({height: height + 'px'});
          }
          }


          function getDocHeight() {
          var D = document;
          return Math.max(
          Math.max(D.body.scrollHeight, D.documentElement.scrollHeight),
          Math.max(D.body.offsetHeight, D.documentElement.offsetHeight),
          Math.max(D.body.clientHeight, D.documentElement.clientHeight)
          );
          }
        </script>


        <style type="text/css">
                    .tbFiles
                    {
                    WIDTH: 100%;
                    /*BACKGROUND-COLOR: #BDD2EC;*/
                    font: 11px Trebuchet, Tahoma, Arial, Helvetica;
                    }

                    .trOver td
                    {
                    background-color: #F0FFFF  !Important;
                    }

                    .trSel td
                    {
                    color: white;
                    background-color: #0A246A !Important;
                    }
                    .divPages .tbPages td {
                    padding: 0px 2px;
                    }
                    .divPages .tbPages{
                    position: relative;
                    bottom: 2px;
                    }

        </style>

        <style type="text/css">



          .trSel td
          {
          background-color: #BBD0EC !Important;
          }
          .divPages .tbPages td {
          padding: 0px 2px;
          }
          .divPages .tbPages{
          position: relative;
          bottom: 2px;
          }

        </style>
      </head>
      <body onload="window_onload();" style="width: 100%; overflow: hidden; height: 100%;" onmousemove="_selection()">
        <div id="file_cont" style="width: 100%; overflow: auto; position: absolute; top: 0px; bottom: 17px;">
          <table class="tb1 highlightEven highlightTROver">

            <tr class="tbLabel0">
              <td nowrap='true' colspan='2'  >
                <script>
                  campos_head.agregar('Nombre', true, 'f_nombre')
                </script>
              </td>
              <td nowrap='true' style='width: 100px'>
                <script>
                  campos_head.agregar('Tamaño', true, 'f_size')
                </script>
              </td>
              <td nowrap='true' style='text-align: left' colspan='2'>
                <script>
                  campos_head.agregar('Tipo', true, 'f_ext')
                </script>
              </td>
              <td style='width: 120px; text-align: right' nowrap='true'>
                <script>
                  campos_head.agregar('Fecha de mod.', true, 'f_falta')
                </script>
              </td>
              <td  style='width: 40px; text-align: center' colspan='3' nowrap='true'>-</td>

              <td style='width: 40px; text-align: right' nowrap='true'>Versión</td>

            </tr>

            <xsl:if test='xml/parametros/file/@f_depende_de != 0'>
              <tr>
                <td style="text-align: left; width: 25px; cursor: hand; cursor: pointer; padding: 1px;">
                  <xsl:attribute name="ondblclick">file_up_ondblclick()</xsl:attribute>
                  <img src='../image/file_dialog/carpeta.png' border='0' align='absmiddle' hspace='1'/>
                </td>
                <td  style='text-align: left; vertical-align: text-bottom; cursor: hand; cursor: pointer; width: 100%' nowrap='true' >
                  <xsl:attribute name="ondblclick">file_up_ondblclick()</xsl:attribute>
                  ..
                </td>
                <td  style='text-align: right' nowrap='true'>
                </td>
                <td style="width: 5px"></td>
                <td  style='text-align: left' nowrap='true'>
                </td>
                <td  style='text-align: right' nowrap='true'>
                </td>
              </tr>

            </xsl:if>

            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; background: #BDD2EC; height: 16px;">
          <script type="text/javascript">
            if (campos_head.PageCount > 1)  document.write(campos_head.paginas_getHTML())
          </script>
        </div>
        <iframe name="hiddenIframe" id="hiddenIframe" src="/fw/enBlanco.htm" style="display: none" frameborder="0"></iframe>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:param name="filename" select="foo:get_filename(string(@f_nombre), string(@f_ext), string(@f_nro_tipo))" />
    <xsl:param name="filtro" select="foo:filter_eval($filename)"/>
    <xsl:param name="is_image" select="foo:is_image(string(@f_ext))"/>
    <xsl:if test="$filtro or @f_nro_tipo != 1 " >
      <tr>
        <xsl:attribute name='id'>trFile_<xsl:value-of select="@f_id"/></xsl:attribute>
        <script type="text/javascript">
          f_id = <xsl:value-of select="@f_id"/>
          files[f_id] = {}
          files[f_id].f_id = f_id
          files[f_id].f_nombre = '<xsl:value-of select="@f_nombre"/>'
          files[f_id].f_ext = '<xsl:value-of select="@f_ext"/>'
          files[f_id].f_nro_tipo = <xsl:value-of select="@f_nro_tipo"/>
          files[f_id].ref_files_path = '<xsl:value-of select="foo:replace(string(@ref_files_path), '\', '\\')"/>'
          files[f_id].f_depende_de = window.parent.file.f_id

        </script>
        <td style="text-align: left; width: 25px; cursor: hand; cursor: pointer; padding: 1px;"  >
          <xsl:attribute name="onclick">
            file_onclick(<xsl:value-of select="@f_id"/>, event)
          </xsl:attribute>
          <xsl:attribute name="ondblclick">
            file_ondblclick(<xsl:value-of select="@f_id"/>)
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@f_nro_tipo = 0">
              <img src='../image/file_dialog/carpeta.png' border='0' align='absmiddle' hspace='1'/>
            </xsl:when>
            <xsl:when test="@f_nro_tipo = -1">
              <img src='../image/file_dialog/disco.png' border='0' align='absmiddle' hspace='1'/>
            </xsl:when>
            <xsl:otherwise>
              <img border='0' align='absmiddle' hspace='1'>
                <xsl:attribute name='src'>
                  ../image/file_dialog/file_<xsl:value-of select="@f_ext"/>.png
                </xsl:attribute>
              </img>
            </xsl:otherwise>
          </xsl:choose>
        </td>
        <td  style='text-align: left; vertical-align: center; cursor: hand; cursor: pointer; width: 100%; padding-left: 2px;' nowrap='true' >
          <xsl:attribute name="onclick">
            file_onclick(<xsl:value-of select="@f_id"/>, event)
          </xsl:attribute>
          <xsl:attribute name="ondblclick">
            file_ondblclick(<xsl:value-of select="@f_id"/>)
          </xsl:attribute>
          <xsl:value-of select="$filename"/>
          <!--<xsl:value-of select="@f_nombre"/><xsl:if test="@f_nro_tipo = 1">.<xsl:value-of select="@f_ext"/></xsl:if>-->
        </td>
        <td  style='text-align: right' nowrap='true'>
          <xsl:if test='@f_nro_tipo = 1'>
            <xsl:value-of select="@f_size"/> Kb
          </xsl:if>
        </td>
        <td style="width: 5px"></td>
        <td  style='text-align: left' nowrap='true'>
          <xsl:choose>
            <xsl:when test='@f_nro_tipo = -1'>Disco</xsl:when>
            <xsl:when test='@f_nro_tipo = 0'>Carpeta</xsl:when>
            <xsl:otherwise>Archivo</xsl:otherwise>
          </xsl:choose>
        </td>
        <td  style='text-align: right' nowrap='true'>
          <xsl:value-of select="foo:FechaToSTR(string(@f_falta))"/>-<xsl:value-of select="foo:HoraToSTR(string(@f_falta))"/>
        </td>
        <td style="text-align: center; width: 20px; cursor: hand; cursor: pointer">
          <xsl:if test="@f_nro_tipo = 1">
            <a target="hiddenIframe">
              <xsl:attribute name="id">
                link_<xsl:value-of select="@f_id"/>
              </xsl:attribute>
              <!--<xsl:attribute name="href">../../meridiano/file_thumb.asp?f_id=<xsl:value-of select="@f_id"/>&#38;thumb_width=0&#38;thumb_height=0</xsl:attribute>-->
              <xsl:attribute name="href">
                /fw/files/file_get.aspx?content_disposition=attachment&amp;f_id=<xsl:value-of select="@f_id"/>
              </xsl:attribute>
              <img title="Descagar Archivo" border='0' align='absmiddle' hspace='1'>
                <xsl:attribute name='src'>../image/file_dialog/descargar.png</xsl:attribute>
              </img>
            </a>
          </xsl:if>
        </td>
        <td style="text-align: center; width: 20px; cursor: hand; cursor: pointer">
          <xsl:if test="@f_nro_tipo = 1">
            <xsl:if test="$is_image">
              <img title="Previsualizar" border='0' align='absmiddle' hspace='1'>
                <xsl:attribute name='src'>../image/file_dialog/buscar.png</xsl:attribute>
                <xsl:attribute name='onclick'>
                  parent.btnPreview_onclick(<xsl:value-of select="@f_id"/>)
                </xsl:attribute>
              </img>
            </xsl:if>
          </xsl:if>
        </td>
        <td style="text-align: center; width: 20px; cursor: hand; cursor: pointer">
          <!--xsl:if test="@f_nro_tipo = 1"-->
          <img title="Propidades" border='0' align='absmiddle' hspace='1'>
            <xsl:attribute name='src'>../image/file_dialog/propiedades.png</xsl:attribute>
            <xsl:attribute name='onclick'>
              parent.btnPropiedades_onclick(<xsl:value-of select="@f_id"/>)
            </xsl:attribute>
          </img>
          <!--/xsl:if-->
        </td>



        <td style="text-align: center; width: 25px; cursor: hand; cursor: pointer;"  >
          <xsl:if test="@f_nro_tipo = 1">
            <img title="versiones" border='0' align='absmiddle' hspace='1'>
              <xsl:attribute name='src'>/FW/image/file_dialog/versiones.png</xsl:attribute>
              <xsl:attribute name='onclick'>
                parent.btnVersiones_onclick('<xsl:value-of select="@f_nombre"/>', '<xsl:value-of select="@f_ext"/>', <xsl:value-of select="@f_depende_de"/>)
              </xsl:attribute>
            </img>
          </xsl:if>
        </td>


      </tr>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>