<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  
  <xsl:template match="/">
      <html>
          <head>
              <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
              <title></title>
              <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
              <script type="text/javascript" src="/FW/script/nvFW.js"></script>
              <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
              <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
              <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
              <script type="text/javascript">
					campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
					var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
					campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
					campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
					campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
					campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
					campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW
				</script>
              <script type='text/javascript' >
                 
                    if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW

                      function window_onresize() {
                         var dif = 10
					     var body_height = $$('body')[0].getHeight() 
					     var tbCabecera_height = $('tbCabecera').getHeight()
					     var div_pag_height = $('div_pag').getHeight()
                                   
					     $('div_detalle').setStyle({height: body_height  - tbCabecera_height - div_pag_height -dif  + 'px'}) 

                        campos_head.resize("tbCabecera", "tbDetalle")
                      }

                      function window_onload() {
                        window_onresize()
                      }
                      
                   
              </script>
          </head>
          <body onload="window_onload()"  onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
              <table  class="tb1" id="tbCabecera">
                <tr class="tbLabel">
                    <td style='text-align:center;width:5%' >Código</td>
                    <td style='text-align: center;width:45%'><script>campos_head.agregar('Configuración', true, 'nombre_conf')</script></td>
                    <td style='text-align: center;width:47%' >Comentario</td>
                    <td style='text-align: center;width:3%'></td>
                </tr>
              </table>
              <div id="div_detalle" style="width:100%;overflow:hidden">
                  <table class="tb1 highlightOdd highlightTROver" id="tbDetalle">
                      <xsl:apply-templates select="xml/rs:data/z:row" />
                  </table>
              </div>
              <div id="div_pag" style="width:100%; text-align:right">
                  <script type="text/javascript"> document.write(campos_head.paginas_getHTML()) </script>
              </div>
              <script type="text/javascript">campos_head.resize("tbCabecera", "tbDetalle")</script>
          </body>
      </html>
	</xsl:template>
  
	<xsl:template match="z:row">
		<tr>
			<td style='text-align: left; width:5%' ><xsl:value-of select="@id_cfg_especial" /></td>
            <td style=' width:45%'  ><xsl:value-of select="@nombre_conf"/></td>
			<td style=' width:47%' ><xsl:value-of select="@comentario_conf" /></td>
			<td style='text-align: center; width:3%' ><img src='/FW/image/icons/editar.png' style='cursor:pointer'><xsl:attribute name='onclick'>
                window.parent.editar_configuracion(<xsl:value-of select="@id_cfg_especial"/>,'<xsl:value-of select="@permiso_grupo"/>',<xsl:value-of select="@permiso_ver"/> )</xsl:attribute></img></td>
		</tr>
	</xsl:template>
</xsl:stylesheet>