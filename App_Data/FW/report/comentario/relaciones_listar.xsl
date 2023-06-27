<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
        <title>Créditos</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
        <!--<script type="text/javascript" src="/fw/script/nvFW_windows.js" language="JavaScript"></script>-->
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

          <xsl:comment>
          <![CDATA[
		  function window_onload(){
          window_onresize()
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

      </head>
      <body  style="width:100%;height:100%;overflow:hidden" onresize="window_onresize()" onload="window_onload()">
        <table class="tb1 " id="tbCabecera">
          <tr class="tbLabel">
			  <td  style='width:10%; text-align: center;'>
				  <script>campos_head.agregar('Nro Grupo', true,'nro_com_grupo')</script>
			  </td>
			  <td  style='width:30%; text-align: center;'>
				  <script>campos_head.agregar('Grupo', true,'com_grupo')</script>
			  </td>
			  <td  style='width:10%; text-align: center;'>
				  <script>campos_head.agregar('Nro Tipo', true,'nro_com_tipo')</script>
			  </td>
			  <td  style='width:30%; text-align: center;'>
				  <script>campos_head.agregar('Tipo', true,'com_tipo')</script>
			  </td>
			  <td  style='width:10%; text-align: center;'>
				  <script>campos_head.agregar('Prioridad', true,'com_prioridad')</script>
			  </td>
			  <td  style='width:10%; text-align: center;'></td>
          </tr>
        </table>
        <div style="width:100%; height:100%;overflow:hidden" id="divDetalles">
        <table  class="tb1  highlightOdd highlightTROver layout_fixed" style="width: 100%" id="tbDetalle" >
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

  <xsl:template match="z:row"  mode="row1">
    <tr>
		<td style='width:10%; text-align: right;'>
			<xsl:value-of  select="@nro_com_grupo" />
		</td>
		<td style='width:30%;'>
			<xsl:value-of  select="@com_grupo" />
		</td>
		<td style='width:10%; text-align: right;'>
			<xsl:value-of  select="@nro_com_tipo" />
		</td>
		<td style='width:30%;'>
			<xsl:value-of  select="@com_tipo" />
		</td>
		<td style='width:10%; text-align: right;'>
			<xsl:value-of  select="@com_prioridad" />
		</td>
		<td style='text-align: center; width:10%'>
			<center>
				<img src="/FW/image/icons/eliminar.png" style="cursor:pointer">
					<xsl:attribute name="onclick">
						parent.eliminarTipoGrupo('<xsl:value-of select="@nro_com_grupo"/>','<xsl:value-of select="@nro_com_tipo"/>','<xsl:value-of select="@com_prioridad"/>','<xsl:value-of  select="@com_grupo" />','<xsl:value-of select="@com_tipo"/>')
					</xsl:attribute>
				</img>
				<img src="/FW/image/icons/editar.png" style="cursor:pointer">
					<xsl:attribute name="onclick">
						parent.editarTipoGrupo('<xsl:value-of select="@nro_com_grupo"/>','<xsl:value-of select="@nro_com_tipo"/>','<xsl:value-of select="@com_prioridad"/>','<xsl:value-of  select="@com_grupo" />','<xsl:value-of select="@com_tipo"/>')
					</xsl:attribute>
				</img>
			</center>
		</td>
    </tr>
  </xsl:template>
</xsl:stylesheet>