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
          var cant = '<xsl:value-of select="xml/params/@recordcount"/>'
          <![CDATA[
          function Mostrar_contacto_grupo()
          {
              try
              {    
                  var contacto_grupo = ''
                  var filtroTipos = "<nro_contacto_grupo type='in'>"
                  var strTipos = ''
                  var cant_checked = 0
                  var checked = ''
                  parent.checkContacto_grupos = []
                  for (var i = 0; i < cant; i++) {
                    if (document.getElementById('check_' + i).checked) {
                      cant_checked += 1
                      strTipos += ',' + arrayContactoGrupo[i].nro_contacto_grupo
                      contacto_grupo = arrayContactoGrupo[i].contacto_grupo
                      parent.checkContacto_grupos.push(arrayContactoGrupo[i].nro_contacto_grupo)
                    }
                  }
                  
                  if (cant_checked == 1) {
                    var acentos = {'á':'a','é':'e','í':'i','ó':'o','ú':'u','Á':'A','É':'E','Í':'I','Ó':'O','Ú':'U'};
                    contacto_grupo = contacto_grupo.split('').map( letra => acentos[letra] || letra).join('').toString();	
                  
                    if (typeof parent.Contactos[contacto_grupo.toLowerCase()] == 'undefined') // ver acento telefono
                      parent.Contactos[contacto_grupo.toLowerCase()] = []
                  
                      parent.frameCargar(contacto_grupo.toLowerCase())
                    } else if (cant_checked > 1) {
                      strTipos = strTipos.substring(1, strTipos.length);
                      filtroTipos += strTipos + "</nro_contacto_grupo>"
                      
                      parent.frameCargar('generico', filtroTipos)
                  } else parent.frameCargar('generico', '')
              }
              catch (e) {debugger}
              
              //parent.Mostrar_Registro_grupo(nro_contacto_grupo, com_grupo);
          }


          function seleccionarContacto_grupo() {
          
            parent.frameCargar('generico', '');
          }
          
          
        ]]>
        </script>
      </head>
      <body style="width: 100%; height: 100%; overflow: auto;">

        <table class="tb1 highlightOdd highlightTROver" id="tbData">
          <tbody>
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </tbody>
        </table>

        <script>
          seleccionarContacto_grupo()
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position() - 1"/>

    <tr>
      <td style="text-align: left; width: 100%; padding: 1px 3px;">
        <script>
          if (typeof arrayContactoGrupo == 'undefined')
            arrayContactoGrupo = new Array()
          arrayContactoGrupo[<xsl:value-of select="$pos"/>] = {}
          arrayContactoGrupo[<xsl:value-of select="$pos"/>].nro_contacto_grupo = '<xsl:value-of select="@nro_contacto_grupo"/>'
          arrayContactoGrupo[<xsl:value-of select="$pos"/>].contacto_grupo = '<xsl:value-of select="@contacto_grupo"/>'

        </script>
        <input id="check_{$pos}" type="checkbox" onchange="Mostrar_contacto_grupo()"></input>
        <a style="color:blue">
          <xsl:attribute name="id">
            link_<xsl:value-of select="@nro_contacto_grupo"/>
          </xsl:attribute>
          <!--<xsl:attribute name="href">javascript:Mostrar_contacto_grupo(<xsl:value-of select="@nro_contacto_grupo"/>,'<xsl:value-of select="@contacto_grupo"/>')</xsl:attribute>-->
          <xsl:value-of select="@contacto_grupo"/>
        </a>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>