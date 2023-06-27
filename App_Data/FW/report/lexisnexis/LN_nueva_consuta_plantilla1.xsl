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

        <title>Consulta lexisnexis</title>
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
            //tcampo_head.js
            function window_onresize() {
              $('divDetalles').setStyle({  width: $('tbCabecera').getWidth() })
              $('divDetalles').setStyle({ height: $$('body')[0].getHeight() - $('tbCabecera').getHeight() - $('div_pag').getHeight() });
              campos_head.resize('tbCabecera','tbDetalles');
            }
 
     
						]]>
        </xsl:comment>
      </script>

      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow-y: hidden; overflow-x:auto">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold; color: grey;">No se encontraron consultas</p>
              <!--<p style="margin: 0; font-size: 1.1em; color: grey;">Intente con otro/s valor/es de filtro</p>-->
            </div>
          </xsl:when>
          <xsl:otherwise>

            <table class="tb1" id="tbCabecera">
              <tr class="tbLabel">
                <td style='width: 3%; text-align: right' nowrap='true'>
                  <script> campos_head.agregar('Nro.', true,'nro_consulta')</script>
                </td>
                <td style='width: 5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Vigencia', true,'vigente')</script>
                </td> 
                <td style='width: 5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('ID Resultado', true,'ResultID')</script>
                </td>
                <td style='width: 3%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Tipo Doc.', true,'documento')</script>
                </td>
                <td style='width: 10%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Nro. Documento', true,'nro_docu')</script>
                </td>
                <td style='width: 10%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Nombre', true,'apenom')</script> 
                </td>
                <td style='width: 10%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Fe. Nacimiento', true,'fe_naci')</script>
                </td>
                <td style='width: 5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Sexo', true,'sexo')</script>
                </td> 
                <td style='width: 5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Pais', true,'pais')</script>
                </td>
                <td style='width: 5%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('División', true,'division')</script>
                </td>
                <td style='width: 10%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Usuario', true,'user')</script> 
                </td>
                <td style='width: 10%; text-align: center' nowrap='true'>
                  <script>campos_head.agregar('Fe. Consulta', true,'fe_consulta')</script>
                </td> 
                <td style="align:center; text-align:center; width:5%" nowrap='true'>
                  <img src='/fw/image/filetype/xlsx.png' title='Exportar a excel' onclick='parent.buscar_consulta(1) ' style="cursor:pointer" ></img>
                </td>
                <td style="align:center; text-align:center; width:5%" nowrap='true'>
                  -
                </td>


              </tr>
            </table>

            <div id='divDetalles' style='width:100%; height: 91%; overflow-y: auto; overflow-x:hidden'>
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

          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>



  <xsl:template match="z:row"  mode="row1">

    <xsl:variable name="apenom" select="concat(string(@nombres),' ',string(@apellido))"/>
    <tr name="dataRow">
      <!-- DATOS -->
      <td style="width: 5%; text-align: right">
        <xsl:value-of select="@nro_consulta"/>
      </td>
      <td style="width: 5%; text-align: left">
        <xsl:if test="@vigente = 'True' ">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: black; width: 5%; text-align: center; background-color: #DFF2BF'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@vigente = 'False' ">
          <xsl:attribute name="style">
            <xsl:value-of select="'color: black; width: 5%; text-align: center; background-color: #FFBABA'"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose><xsl:when test="@vigente= 'True'">Si</xsl:when><xsl:otherwise>No</xsl:otherwise></xsl:choose>
      </td>



      <td style="width: 10%; text-align: center">
        
        <xsl:choose>
          <xsl:when test="@ResultID != ''">
             <xsl:value-of select="@ResultID"/>
          </xsl:when>
          <xsl:otherwise>No encontrado</xsl:otherwise>
        </xsl:choose>
      </td>

      <td style="width: 5%;text-align: center">
        <xsl:value-of select="@documento"/>
      </td>
      <td style="width: 10%;text-align:  center">
        <xsl:value-of select="@nro_docu"/>
      </td>
      <td style="width: 10%; text-align: left">
        <xsl:value-of select="$apenom"/> 
      </td>
      <td style="width: 10%;text-align: center">
        <xsl:value-of select="foo:FechaToSTR(string(@fe_naci))"/>
      </td> 
      <td style="width: 5%;text-align: center">
        <xsl:value-of select="@sexo"/>
      </td>
      <td style="width: 5%;text-align: left">
        <xsl:value-of select="@pais"/>
      </td>
      <td style="width: 5%;text-align: left">
        <xsl:value-of select="@division"/>
      </td>
      <td style="width: 10%;text-align: left">
        <xsl:value-of select="@user"/>
      </td>
      <td style="width: 10%;text-align: center">
        <xsl:value-of select="foo:FechaToSTR(string(@fe_consulta))"/>
      </td>
      <td style="align:center; text-align:center; width:5%">
        <img src="../../voii/image/icons/abm.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">

            parent.descargar_consulta('<xsl:value-of select="@nro_consulta"/>','<xsl:value-of select="@ResultID"/>')
          </xsl:attribute>
        </img>
      </td>
      <td style="align:center; text-align:center; width:5%">
        <img src="../../voii/image/icons/editar.png" style="cursor:pointer" >
          <xsl:attribute name="onclick">parent.confirmar_consulta('<xsl:value-of select="@nro_consulta"/>') </xsl:attribute>
        </img>
      </td>

    </tr> 

  </xsl:template>

</xsl:stylesheet>
