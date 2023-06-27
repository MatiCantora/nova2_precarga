<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				                      xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				                      xmlns:rs='urn:schemas-microsoft-com:rowset'
				                      xmlns:z='#RowsetSchema'
				                      xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				                      xmlns:fn="http://www.w3.org/2005/xpath-functions"
	                            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

  <xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes" />

  <msxsl:script language="javascript" implements-prefix="foo"></msxsl:script>

  <xsl:template match="/">
    <html>
      <head>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <style type="text/css">
          a { text-decoration: none; }
          a.selected { font-weight: bold; font-style: italic; }
        </style>
        <script type="text/javascript">
        <![CDATA[
          function Mostrar_Registro_grupo(nro_com_grupo, com_grupo)
          {
              try
              {
                  var link_old = document.querySelector('.selected');
                  var link_new = document.getElementById('link_' + nro_com_grupo);
                  
                  if (link_old)
                      link_old.classList.remove('selected');
                  
                  link_new.classList.add('selected');
              }
              catch (e) {}
              
              parent.Mostrar_Registro_grupo(nro_com_grupo, com_grupo);
          }


          function seleccionarGrupo(nro_com_grupo)
          {
              var link = document.getElementById('link_' + nro_com_grupo);
              link.classList.add('selected');
          }
        ]]>
        </script>
      </head>
      <body style="width: 100%; height: 100%; overflow: auto;">
        
        <table class="tb1 highlightOdd highlightTROver">
          <tbody>
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </tbody>
        </table>
        
        <script>seleccionarGrupo(<xsl:value-of select="xml/parametros/@nro_com_grupo_selected" />)</script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
      <tr>
        <td style="text-align: left; width: 100%; padding: 1px 3px;">
          <a>
            <xsl:attribute name="id">link_<xsl:value-of select="@nro_com_grupo"/></xsl:attribute>
            <xsl:attribute name="href">javascript:Mostrar_Registro_grupo(<xsl:value-of select="@nro_com_grupo"/>,'<xsl:value-of select="@com_grupo"/>')</xsl:attribute>
            <xsl:value-of select="@com_grupo"/>
          </a>
        </td>
      </tr>
  </xsl:template>
</xsl:stylesheet>