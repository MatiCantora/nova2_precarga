<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>


  <xsl:template match="/">
    <html>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

        <title>Buscar Vendedor</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>

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
          campos_head.nvFW = window.parent.nvFW
        </script>
        <script type="text/javascript" language="javascript" >
          <xsl:comment>
            <![CDATA[ 

                         function seleccionarPerfil(tipo_operador,tipo_operador_desc)
						 {
							window.parent.perfil_seleccionar(tipo_operador,tipo_operador_desc)
						 }


                         function window_onresize(){
                        try
			                {
			                    var dif = 50
			                    var body_height = $$('body')[0].getHeight()
			                    var tbCabe_height = $('tbCabecera').getHeight()
		                    var div_pag_height = $('divPages').getHeight()
			      
                        $('divRow').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})
			     
			                }
			            catch(e){}
        
                        try
                        {
                        campos_head.resize("tbCabe","tbRow")                  
                        }
                        catch(e){}
                      }

                    function window_onload(){
                       window_onresize()
                    }
                     
                    ]]>
          </xsl:comment>
        </script>
      </head>
      <body onload="window_onload()" style="width:100%;height:100%;overflow:auto">
        <table width="100%" class="tb1" id="tbCabecera">
          <tr class="tbLabel">
            <td style='text-align: center; width:6%' nowrap='true'>-</td>
            <td style='text-align: center; width:10%' nowrap='true'>
            <script type="text/javascript">
                campos_head.agregar('Nro', true, 'tipo_operador')
            </script>
            </td>
            <td style='text-align: center;'>
            <script type="text/javascript">
                campos_head.agregar('Perfil', true, 'tipo_operador_desc')
            </script>
            </td>
        </tr>
        </table>
        <div id="divRow" style="width:100%; overflow:auto">
          <table id="tbRow" class="tb1 highlightOdd highlightTROver" width="100%">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
        <div id="tbPie" class="divPages">
          <script type="text/javascript">
            document.write(campos_head.paginas_getHTML())
          </script>
        </div>
      </body>

    </html>
  </xsl:template>
  <xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <tr>
      <td style='text-align: center; width:6%' nowrap='true'>
        <img title="Seleccionar Perfil" src="/fw/image/icons/confirmar.png" style="cursor:pointer">
          <xsl:attribute name="onclick">
            seleccionarPerfil('<xsl:value-of select='@tipo_operador'/>','<xsl:value-of select='@tipo_operador_desc'/>')
          </xsl:attribute>
        </img>
      </td>
      <td style='text-align: left; width:10%'>
        <xsl:value-of select="@tipo_operador"/>
      </td>
      <td style='text-align: left;'>
        <xsl:value-of select="@tipo_operador_desc"/>
      </td>

    </tr>
  </xsl:template>
</xsl:stylesheet>