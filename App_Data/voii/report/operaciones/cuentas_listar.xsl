<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

  <xsl:template match="/">
    <html>
      <head>

        <title>SOLICITUDES</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'

          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>

          campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

          if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW

        </script>

      </head>
      <script>
        <xsl:comment>
          <![CDATA[
						function window_onload() {
              window_onresize();
						}
            
            function window_onresize() {
              
              var div_pag = $('div_pag');
              //obtieme tamaño de paginacion
              for (var i = 0; i < $('div_pag').childNodes.length; i++) {
              var childnode = div_pag.childNodes[i];
                if (childnode.nodeName.toUpperCase() == 'TABLE') {
                  div_pag.setStyle({ height: childnode.getHeight() + 'px' });
                }
              }
            
              $('divDetalles').setStyle({ width: $('tbCabecera').getWidth() })
              
              $('divDetalles').setStyle({ height: $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('div_pag').getHeight() + 'px' });
              campos_head.resize('tbCabecera','tbDetalles');
            }  
            
            
            
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow-x: auto; overflow-y: hidden">
        <!--CABECERA--> 
        <table class="tb1" id="tbCabecera">
          <tr class="tbLabel">
            <td style='width: 20%; text-align: center'>
              <script>campos_head.agregar('Tipo', true,'sistema')</script>
            </td>
            <td style='width: 10%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Moneda', true,'moneda')</script>
            </td>
            <td style='width: 15%; text-align: center'>
              <script>campos_head.agregar('Nro.', true,'cuecod')</script>
            </td>
            <td style='width: 5%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Estado', true,'cueestdesc')</script>
            </td>
            <td style='width: 30%; text-align: center'>
              <script>campos_head.agregar('Nombre Cuenta', true,'nombrecta')</script>
            </td>
            <td style='width: 10%; text-align: center' nowrap='true'>
              <script>campos_head.agregar('Último Movi.', true,'fecultmov')</script>
            </td>
          </tr>
        </table>
        <!--DATOS-->
        <div id='divDetalles' style='width: 100%; height: 91%; overflow-y: auto; overflow-x: hidden'>
          <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalles">
            <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
          </table>
        </div>

        <!-- DIV DE PAGINACION -->
        <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; height: 16px">
          <script type="text/javascript">
            if (campos_head.PageCount > 1)
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row" mode="row1">
    <xsl:variable name="pos" select="position()"/>
    <tr name="dataRow">
      <!-- DATOS -->
      
      <td style="width:20%; text-align:left">
          <xsl:value-of  select="@sistema" />        
      </td>
      <td style="width:10%; text-align:left">
          <xsl:value-of  select="@moneda" />        
      </td>
      <td style="width:15%; text-align: right" id="tdcuecod{$pos}" name="cuecod">
        <xsl:value-of  select="@cuecod" />
      </td>
      <td style="width:5%; text-align: left">
        <xsl:value-of  select="@cueestdesc" />
      </td>
      <td style="width:30%; text-align:left">
        <xsl:attribute name="title">
          <xsl:value-of  select="@nombrecta" />
        </xsl:attribute>
        <xsl:value-of  select="@nombrecta" />        
      </td>
      <td style="width:10%; text-align:center">
        <xsl:value-of  select="foo:FechaToSTR(string(@fecultmov))"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>