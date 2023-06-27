<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
    ]]>
  </msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Listado entidades Jurídicas</title>
        <link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          if (mantener_origen == '0')
          campos_head.nvFW = parent.nvFW
        </script>

        <script language="javascript" type="text/javascript">
          <xsl:comment>
            <![CDATA[
          
          function window_onload()
		      {
		 	      window_onresize()
		      }
                              
          function window_onresize()
          {
              try
			        {
			          var dif = Prototype.Browser.IE ? 5 : 2
			          var body_height = $$('body')[0].getHeight()
			          var tbCabe_height = $('tbCabe').getHeight()
		            var div_pag_height = $('div_pag').getHeight()
			      
                $('divRow').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})
			     
			        }
			      catch(e){}
        
             try
              {
               campos_head.resize("tbCabe","tbRow")                  
              }
             catch(e){}
          }
      ]]>
          </xsl:comment>
        </script>
      </head>
      <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">

        <xsl:choose>
          <xsl:when test="count(xml/rs:data/z:row) = 0">
            <div style="width: 50%; margin: 20px auto; text-align: center;">
              <p style="margin: 0; padding: 15px 0 10px; font-size: 1.5em; font-weight: bold;">No se encontraron codigos</p>
              <p style="margin: 0; font-size: 1.1em; color: grey;">Intente con otro/s valor/es de filtro</p>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <table class="tb1" id="tbCabe">
              <tr class="tbLabel">
                <td style='width: 25%; text-align: center;'>
                  <script>campos_head.agregar('Elemento', true, 'elemento')</script>
                </td>
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Cod. Interno', true, 'cod_interno')</script>
                </td>
                <td style='width: 15%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Sistema Externo', true, 'sistema_externo')</script>
                </td>
                <td style='width: 10%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Cod. Externo', true, 'cod_externo')</script>
                </td>
                <td style='width: 25%; text-align: center;' nowrap='true'>
                  <script>campos_head.agregar('Descripción', true, 'desc_externo')</script>
                </td>
                <td style='width: 5%; text-align: center;'>-</td>
                <td style='width: 5%; text-align: center;'>-</td>
              </tr>
            </table>

            <div style="width: 100%; overflow: auto;" id="divRow">
              <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                <xsl:apply-templates select="xml/rs:data/z:row" />
              </table>
            </div>

            <div id="div_pag" class="divPages">
              <script type="text/javascript">
                if (campos_head.PageCount > 1)
                  document.write(campos_head.paginas_getHTML())
              </script>
            </div>
            <script type="text/javascript">campos_head.resize("tbCabe", "tbRow")</script>
          </xsl:otherwise>
        </xsl:choose>

      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <tr>
      <td style='width: 25%; text-align: left;'>
        <xsl:value-of select="@elemento" />
      </td>
      <td style="text-align: right">
        <xsl:value-of select="@cod_interno" />
      </td>
      <td>
        <xsl:value-of select="@sistema_externo" />
      </td>
      <td style="text-align: right">
        <xsl:value-of select="@cod_externo" />
      </td>
      <td>
        <xsl:value-of select="@desc_externo" />
      </td>
      <td style='width: 5%; cursor: pointer; text-align: center;'>
        <img src='/fw/image/icons/editar.png' border='0' align='absmiddle' hspace='2' onclick='parent.editar_registro("{@elemento}", "{@cod_interno}", "{@sistema_externo}")' title='Editar' />
      </td>
      <td style='width: 5%; cursor: pointer; text-align: center;'>
        <img src='/fw/image/icons/eliminar.png' border='0' align='absmiddle' hspace='2' onclick='parent.eliminar_registro("{@elemento}", "{@cod_interno}", "{@sistema_externo}")' title='Eliminar' />
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>