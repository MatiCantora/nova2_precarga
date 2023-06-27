<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
				
				xmlns:vbuser="urn:vb-scripts">
	<xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
	<xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Créditos</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
		  <script type="text/javascript" src="/FW/script/swfobject.js"></script>
		  <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
		  <!--<script type="text/javascript" src="/FW/script/nvFW.js"></script>-->
		  <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
		  <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
		  <!--<script type="text/javascript" src="/FW/script/tCampo_head.js"></script>-->
		  <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
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

          function window_onresize()
          {
          var body = $$("BODY")[0]
          var altoDiv = body.clientHeight - 50
          $("divBody").setStyle({height: altoDiv + "px" })

          campos_head.resize("tbCabe", "tbDetalle")
          }

          function window_onload()
          {
          window_onresize()
          }

        </script>

      </head>
      <body  style="width:100%;height:100%;overflow:hidden" onresize="window_onresize()" onload="window_onload()">
        <table class="tb1 " id="tbCabe">
          <tr class="tbLabel">			  
            <td style="width:7%; text-align:center">
              <script>campos_head.agregar('Com. Tipo', 'true', 'com_id_tipo')</script>
            </td>
		    <td style="width:5%; text-align:center">
              <script>campos_head.agregar('ID Tipo', 'true', 'id_tipo')</script>
            </td>			  
		    <td style="width:10%; text-align:center">
              <script>campos_head.agregar('Tipo', 'true', 'com_tipo')</script>
            </td>
			  
            <td style="width:49%; text-align:center">
              <script>campos_head.agregar('Comentario', 'true', 'comentario')</script>
            </td>
            <td style="width:6%; text-align:center">
              <script>campos_head.agregar('Estado', 'true', 'com_estado')</script>
            </td>
			  <td style="width:10%; text-align:center">
				  <script>campos_head.agregar('Fecha', 'true', 'fecha')</script>
			  </td>
			  <td style="width:10%; text-align:center">
				  <script>campos_head.agregar('Operador', 'true', 'nombre_operador')</script>
			  </td>
			  <td style="width:3%; text-align:center">-</td>
          </tr>
        </table>
        <div style="width:100%; height:300px;overflow-y:auto" id="divBody">
        <table  class="tb1  highlightOdd highlightTROver layout_fixed" id="tbDetalle" >
          <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
        </table>
        </div>
        <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
        </script>
        
        <script type="text/javascript">
          campos_head.resize("tbCabe", "tbDetalle")
        </script>       
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row"  mode="row1">
    <tr>
		<td style="text-align:center; white-space: nowrap;">
        <xsl:value-of  select="@com_id_tipo" />
      </td>
		<td style="text-align:right; white-space: nowrap;">
        <xsl:value-of  select="@id_tipo" />
      </td>
      <td style="text-align:left; white-space: nowrap;">
        <xsl:value-of  select="@com_tipo"/>
      </td>
      <td style="text-align:left; white-space: nowrap;">
        <xsl:value-of  select="@comentario" disable-output-escaping="yes" />
      </td>
      <td style="text-align:center; white-space: nowrap;">
        <xsl:value-of  select="@com_estado"/> 
      </td>
      <td style="text-align:center; white-space: nowrap;">
        <xsl:value-of  select="concat(foo:FechaToSTR(string(@fecha)),' ',foo:HoraToSTR(string(@fecha)))"/>
      </td>
		<td style="text-align:left; white-space: nowrap;">
			<xsl:value-of  select="@nombre_operador" />
		</td>
		<td style="text-align:center;">
			<!--<xsl:attribute name="style">
				text-align:center;cursor:pointer;<xsl:value-of select="$estiloEstado"/>
			</xsl:attribute>-->
			<img>
				<xsl:attribute name="style">cursor:pointer</xsl:attribute>

				<xsl:attribute name="src">/fw/image/icons/alerta.png</xsl:attribute>
				<xsl:attribute name="onclick">
					<!--parent.abrirComentario('<xsl:value-of select="@nro_registro"/>')-->
					parent.ABMRegistro('<xsl:value-of select="@nro_entidad"  />', '<xsl:value-of select="@id_tipo"/>', '<xsl:value-of select="@nro_com_id_tipo" />', '<xsl:value-of select="@nro_registro" />', '<xsl:value-of select="@nro_com_tipo" />', '<xsl:value-of select="@nro_com_estado" />', 0, '<xsl:value-of select="@nro_com_grupo" />')
				</xsl:attribute>
			</img>
		</td>

	</tr>
  </xsl:template>
 

</xsl:stylesheet>