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
		  
		function file_icon(f_nro_tipo, f_ext)
		  {
		  if (f_nro_tipo == -1)
		    return "../../meridiano/image/docs/servidor16.png"
		    
		  if (f_nro_tipo == 0)
		    return "../../meridiano/image/docs/carpeta.png"  
		    
		  return "../../meridiano/image/icons/file_" + f_ext + ".png"    
		  }
		  function is_image(ext) {
            switch(ext){
                case 'bmp':
                case 'gif':
                case 'jpg':
                case 'jpge':
                case 'jpe':
                case 'png':
                case 'ico':
                case 'tga':
                case 'pcx':
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
				<link href="../css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/fw/script/prototype.js" language='javascript'></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/rsXML.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tXML.js" language="JavaScript"></script>
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


                  function file_onclick(f_id) {
                  /*window.parent.file_onclick(files[f_id])
                  if (f_id_sel != null)
                  $('spnFile_' + f_id_sel).removeClassName('spnSel')
                  f_id_sel = f_id
                  $('spnFile_' + f_id).addClassName('spnSel')*/
                      
                      window.parent.file_onclick(files[f_id])
                      var isSelected = f_id_sel[f_id]
                      if (!event.ctrlKey) {
                            for(var f in f_id_sel ){
                              if(f_id_sel[f]){
                                $('spnFile_' + f).removeClassName('spnSel')
                                f_id_sel[f] = false
                              }
                            }
                            $('spnFile_' + f_id).addClassName('spnSel')
                            f_id_sel[f_id] = true
                    
                        } else {
                
                            if (isSelected){
                                $('spnFile_' + f_id).removeClassName('spnSel')
                                f_id_sel[f_id] = false
                            } else {
                                $('spnFile_' + f_id).addClassName('spnSel')
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

                  function mo(e)
                  {
                  var el = Event.element(e)
                  while(el.tagName != 'SPAN')
                  el = el.up()
                  el.addClassName('spnOver')
                  }

                  function mu(e)
                  {
                  var el = Event.element(e)
                  while(el.tagName != 'SPAN')
                  el = el.up()
                  el.removeClassName('spnOver')
                  }

                  function _selection()
                  {
                  //debugger
                  //selection.empty()
                  if (window.getSelection)
                  {
                  if (window.getSelection().empty)
                  {  window.getSelection().empty(); } // Chrome
                  else
                  if (window.getSelection().removeAllRanges)
                  {  window.getSelection().removeAllRanges();    } // Firefox
                  }
                  else
                  if (document.selection) {    document.selection.empty(); } // IE?
                  }
                  function window_onload(){
                  if (Prototype.Browser.IE) {
                  var height = getDocHeight() - 70;
                  $('file_cont').setStyle({'height': height + 'px'});
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

                    .spnFile
                    {
                    cursor: hand;
                    cursor: pointer;
                    /*width: 230px;*/
                    /*height: 210px;*/
                    width: <xsl:value-of select="xml/parametros/file/@thumbSize"/>px;
                    height: <xsl:value-of select="xml/parametros/file/@thumbSize"/>px;
                    vertical-align:top;
                    margin: 5px;
                    display: inline-block;
                    display: -moz-inline-stack;
                    border: solid silver 2px;
                    *display:inline;
                    }

                    .spnOver
                    {
                    border: solid gray 2px !Important
                    }

                    .spnSel
                    {
                    border: solid  #0A246A 2px !Important
                    }

                    .spnSel .tbMiniatura tr .tdTitulo
                    {
                    color: white !Important;
                    background-color: #0A246A !Important;
                    }

                    .tbMiniatura tr td
                    {
                    font-size: 11px;
                    }

                    .tbMiniatura tr .tdTitulo
                    {
                    background-color: #F0FFFF !Important;
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
            <body style="width: 100%; overflow:hidden;" onload="window_onload()" onmousemove="_selection()" onselectstart="_selection()" onselectionend="_selection">
                <div id="file_cont" style="width: 100%; overflow: auto; position: absolute; top: 0px; bottom: 17px;">
                    <xsl:if test='xml/parametros/file/@f_depende_de != 0'>
                        <span class="spnFile" onmouseover='return mo(event)' onmouseout='return mu(event)' >
                            <xsl:attribute name="ondblclick">file_up_ondblclick()</xsl:attribute>
                            <table class="tbMiniatura" border="0" cellspacing="0" cellpadding="0" style="width: 100%; height: 100%">
                                <tr>
                                    <td style="text-align: center; vertical-align: middle;">
                                        <img src='../image/file_dialog/carpeta32.png' border='0' align='absmiddle' hspace='1'/>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="height: 20px; text-align: center;">
                                        ..
                                    </td>
                                </tr>
                            </table>
                        </span>
                    </xsl:if>
                    <xsl:apply-templates select="xml/rs:data/z:row" />
                </div>
                <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; background: #BDD2EC; height: 16px;">
                    <script type="text/javascript">
                        document.write(campos_head.paginas_getHTML())
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
        <xsl:if test="$filtro or @f_nro_tipo != 1 " >
            <span class="spnFile" onmouseover='return mo(event)' onmouseout='return mu(event)' >
                <xsl:attribute name='title'><xsl:value-of select="$filename"/></xsl:attribute>
                <xsl:attribute name="onclick">file_onclick(<xsl:value-of select="@f_id"/>)</xsl:attribute>
                <xsl:attribute name="ondblclick">file_ondblclick(<xsl:value-of select="@f_id"/>)</xsl:attribute>
                <xsl:attribute name='id'>spnFile_<xsl:value-of select="@f_id"/></xsl:attribute>
                <table class="tbMiniatura" border="0" cellspacing="0" cellpadding="0" style="width: 100%; height: 100%">
                    <tr>
                        <td style="text-align: center; vertical-align: middle">
                            <div style="max-width: 100%;">
                                <img border='0' align='absmiddle' hspace='1'>
                                  <xsl:choose>
                                    <xsl:when test='@f_nro_tipo = -1'>
                                      <xsl:attribute name='src'>/fw/image/file_dialog/disco32.png</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test='@f_nro_tipo = 0'>
                                      <xsl:attribute name='src'>/fw/image/file_dialog/carpeta32.png</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:attribute name='src'>/fw/files/file_thumb.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;thumb_width=<xsl:value-of select="/xml/parametros/file/@thumbSize - 4"/>&amp;thumb_height=<xsl:value-of select="/xml/parametros/file/@thumbSize - 24"/></xsl:attribute>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                    
                                </img>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class="tdTitulo" style="height: 20px; text-align: center">
                            <table style="width:100%;">
                                <tr>
                                    <xsl:if test="@f_nro_tipo = 1">
                                        <td style="width:18px;text-align:left;">
                                            <a target="hiddenIframe">
                                                <xsl:attribute name="id">link_<xsl:value-of select="@f_id"/></xsl:attribute>
                                                <xsl:attribute name="href">/fw/files/file_get.aspx?content_disposition=attachment&amp;f_id=<xsl:value-of select="@f_id"/></xsl:attribute>
                                                <img title="Descagar Archivo" border='0' align='absmiddle' hspace='1'>
                                                    <xsl:attribute name='src'>../image/file_dialog/descargar.png</xsl:attribute>
                                                </img>
                                            </a>
                                        </td>
                                    </xsl:if>
                                    <td class="tdTitulo" style="text-align:center;">
                                        <div>
                                            <xsl:if test="@f_nro_tipo = 1">
                                                <xsl:attribute name="style">
                                                    overflow: hidden; width:<xsl:value-of select="/xml/parametros/file/@thumbSize - 66"/>px; height: 15px;
                                                </xsl:attribute>
                                            </xsl:if>
                                            <xsl:value-of select="$filename"/>
                                        </div>
                                    </td>
                                        <td style="width:36px;text-align:right;white-space:nowrap">
                                            <xsl:if test="@f_nro_tipo = 1">
                                                <xsl:if test="$is_image">
                                                    <img title="Previsualizar" border='0' align='absmiddle' hspace='1'>
                                                        <xsl:attribute name='src'>../image/file_dialog/buscar.png</xsl:attribute>
                                                        <xsl:attribute name='onclick'>parent.btnPreview_onclick(<xsl:value-of select="@f_id"/>)</xsl:attribute>
                                                    </img>
                                                </xsl:if>
                                            </xsl:if>
                                            <img title="Propidades" border='0' align='absmiddle' hspace='1'>
                                                <xsl:attribute name='src'>../image/file_dialog/propiedades.png</xsl:attribute>
                                                <xsl:attribute name='onclick'>parent.btnPropiedades_onclick(<xsl:value-of select="@f_id"/>)</xsl:attribute>
                                            </img>
                                        </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </span>
        </xsl:if> 
	</xsl:template>
</xsl:stylesheet>