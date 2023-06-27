<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  
    <xsl:include href="..\..\report\xsl_includes\js_formato.xsl" />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <msxsl:script language="javascript"  implements-prefix="foo">
        <![CDATA[
           function str_split(cad, buscar, remplazar)
                   {           
		               var reg = new RegExp(buscar, "ig")
		               cad = cad.replace(reg, remplazar)
    		  
		               return cad
                   }        
            ]]>
    </msxsl:script>

    <xsl:template match="/">
        <html onload="return window_onload()" >
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Sistemas</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
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
                   
                    function window_onresize(){
                        try
			                {
			                    var dif = 50
			                    var body_height = $$('body')[0].getHeight()
			                    var tbCabe_height = $('tbCabe').getHeight()
		                    var div_pag_height = $('div_pag').getHeight()
			      
                        $('divRow').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})
			     
			                }
			            catch(e){Console.log('error   ')}
        
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
            <body onload="window_onload()" style="width:100%;height:100%;overflow:hidden">
                <table class="tb1" id="tbCabe" >
                    <tr class="tbLabel">
                        <td style="text-align: center; width: 40%" > Parámetro </td>
                        <td style="text-align: center; width: 45%" > Valor </td>
                        <td style="text-align: center; width: 15%" colspan="2"> - </td>
                    </tr>
                </table>
                <div style="width:100%;overflow:auto" id="divRow">
                    <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
                </div>
                <div id="div_pag" class="divPages">
                    
                </div>
                <script type="text/javascript">
                    campos_head.resize("tbCabe", "tbRow")
                </script>
            </body>
        </html>
    </xsl:template>

    <xsl:template  match="z:row">
        <xsl:variable name="hardcode" select="@hardcode" />
        <tr >
            <td style="text-align: ;width: 40%"><xsl:value-of  select="@param" /> [ <xsl:value-of  select="@id_param" /> ]</td>
            <td style="text-align: ;width: 45%">
              <xsl:choose>
                <xsl:when test="@encriptar != 'True'">
                  <xsl:attribute name='title'>
                    <xsl:value-of select="@valor" />
                  </xsl:attribute>
                  <xsl:value-of select="foo:str_split(string(@valor), ',','&#x3C;/br&#x3E;')" disable-output-escaping="yes" />
                  <!--<xsl:if test="@wrapper_file != null">
                    <xsl:value-of select="foo:str_split(string(@valor), string(@wrapper_file_separador),'&#x3C;/br&#x3E;')" disable-output-escaping="yes"/>
                  </xsl:if>-->
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
              </xsl:choose>
            </td>
            <td style="text-align: center;width: 15%">
                <input type="button" value="Editar" title="Editar" style="cursor:pointer">
                    <xsl:attribute name="onclick">
                        parent.showValor('<xsl:value-of select="@id_param"/>',<xsl:value-of select="foo:stringToScriptString(string(@valor))"/>,'<xsl:value-of select="@encriptar"/>','<xsl:value-of select="@permiso_grupo"/>','<xsl:value-of select="@nro_permiso"/>', '<xsl:value-of select="@par_nodo" />')
                    </xsl:attribute>
                </input>
                <input type="button" value="Histórico" title="Histórico" style="cursor:pointer">
                    <xsl:attribute name="onclick">
                        parent.showHistorico('<xsl:value-of select="@id_param"/>')
                    </xsl:attribute>
                </input>
            </td>    
                <!--<xsl:choose>
                <xsl:when test="@hardcode = 'True'">
                  <input type="button" value="Ver Valor" style="cursor:pointer">
                    <xsl:attribute name="onclick">
                      parent.verValor('<xsl:value-of select="@id_param"/>','<xsl:value-of select="@valor"/>')
                    </xsl:attribute>
                  </input>
                </xsl:when>
                <xsl:when test="@hardcode = 'False'">
                  <xsl:value-of  select="@valor" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring(@valor,1,10)"/>...
                </xsl:otherwise>
              </xsl:choose>-->
            
            <!--<td align="center" width="6%">
                <img src="/FW/image/icons/editar.png" style="cursor:pointer align:center">
                    <xsl:attribute name="onclick">
                      parent.mostrar('<xsl:value-of select="@id_param"/>')
                    </xsl:attribute>
                </img>
            </td>-->
        </tr>
    </xsl:template>
    
</xsl:stylesheet>