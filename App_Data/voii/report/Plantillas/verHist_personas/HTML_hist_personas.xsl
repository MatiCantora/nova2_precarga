<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				        xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				        xmlns:rs='urn:schemas-microsoft-com:rowset'
				        xmlns:z='#RowsetSchema'
				        xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	              xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:vbuser="urn:vb-scripts">
 

  <xsl:include href="..\..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:include href="..\..\..\..\fw\report\xsl_includes\js_formato.xsl"/>

  <xsl:output method="html" encoding="ISO-8859-1" omit-xml-declaration="yes"/>  
  
  <xsl:template match="/">
    <html>
      <head>
        <title>HTML Operador historial</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <xsl:value-of disable-output-escaping="yes" select="vbuser:head_init()"/>

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
          <![CDATA[
					  function window_onload() {
              window_onresize()
            }

						function window_onresize() {
              
              campos_head.resize('tbCabe','tbDetalle');
					    try {
            	  var dif            = Prototype.Browser.IE ? 5 : 2,
                    body_height    = $$('body')[0].getHeight(),
                    tbCabe_height  = $('tbCabe').getHeight(),
                    div_pag_height = $('div_pag').getHeight()

					      $('divHistorialOperador').setStyle({ height: body_height - tbCabe_height - div_pag_height - dif + 'px' })
                $('tbDetalle').getHeight() - $('divHistorialOperador').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                                
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
            
            
            function selBusqueda(nro_entidad, nrodoc, tipdoc, origen, tipocli) {
                
                var $frame = ObtenerVentana('frame_buscar');
                
                if (origen == '') {
                    if($frame.cargarDatosCliente)
                        $frame.cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, -1);
                } else {
                    if($frame.cargarDatosCliente)
                        $frame.cargarDatosCliente(nro_entidad, tipocli, nrodoc, tipdoc, 1);     
                }    
                parent.cerrarVentana()
            }
					
					]]>
        </script>
        <style type="text/css"> .tr_cel TD { background-color: #F0FFFF !Important; } </style>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; bakcground-color: white;">
        <table class="tb1" id="tbCabe">
          <tr class="tbLabel">
            <td style='text-align: center; width: 6%' nowrap='true'>-</td>
            <td style='text-align: center; width: 74%'>
              <script>campos_head.agregar('Razón Social', 'true', 'Razon_social')</script>
            </td>
            <td style='text-align: center; width: 20%'>
              <script>campos_head.agregar('Fecha', 'true', 'fecha_busqueda')</script>
            </td>
            <!--<td style='width: 1%'></td>-->
          </tr>
        </table>

        <div id="divHistorialOperador" style="width: 100%; overflow: auto;">
          <table class="tb1 highlightOdd highlightTROver" id="tbDetalle">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>

        <div id="div_pag" class="divPages">
          <script type="text/javascript">
            if (campos_head.recordcount > campos_head.PageSize)
              <!--$("div_pag").innerHTML = campos_head.paginas_getHTML()-->
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <tr id="tr_ver{$pos}">
      <td style='text-align: center; width:6%' nowrap='true'>
        <img onclick="selBusqueda('{@nro_entidad}', '{@nro_docu}', '{@tipo_docu}', '{@origen}', '{@tipocli}')" title="Seleccionar" src="/FW/image/icons/agregar_cargo.png" style="cursor: pointer;" />
      </td>
      <td style='text-align: left; width: 74%;'>
        <a href="#" style="cursor: pointer;" onclick="selBusqueda('{@nro_entidad}', '{@nro_docu}', '{@tipo_docu}', '{@origen}', '{@tipocli}')" title="{@Razon_social}">
          <xsl:choose>
              <xsl:when test="string-length(@Razon_social) &#62; 50">
                <xsl:value-of select="substring(@Razon_social, 1, 50)" />...
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@Razon_social" />
              </xsl:otherwise>
          </xsl:choose>
        </a>
      </td>
      <td style='text-align: center; width: 20%;'>
        <xsl:value-of select="foo:FechaToSTR(string(./@fecha_busqueda))" />&#160;
        <xsl:value-of select="foo:HoraToSTR(string(./@fecha_busqueda))" />
      </td>
      <!--<td style='width: 1%;' id="tdScroll{$pos}"></td>-->
    </tr>
  </xsl:template>
</xsl:stylesheet>
