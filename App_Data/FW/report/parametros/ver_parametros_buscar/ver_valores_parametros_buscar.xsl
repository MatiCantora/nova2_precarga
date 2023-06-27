<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <msxsl:script language="javascript" implements-prefix="foo"></msxsl:script>

    <xsl:template match="/">
        <html onload="return window_onload()" >
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Parametros valores</title>
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
                    try{
			                var dif = 50
			                var body_height = $$('body')[0].getHeight()
			                var tbCabe_height = $('tbCabe').getHeight()
		                var div_pag_height = $('div_pag').getHeight()
			      
                    $('divRow').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})
			     
			            }
			            catch(e){Console.log('error resize')}
        
                        try
                        {
                        campos_head.resize("tbCabe","tbRow")                  
                        }
                        catch(e){}
                      }


                    function window_onload()
                    {
                       window_onresize()
                    }
                    ]]>
                    </xsl:comment>
                </script>
            </head>


            <body onload="window_onload()" style="width:100%;height:100%;overflow:hidden">
                <table class="tb1" id="tbCabe" >
                        <tr>
                            <td style="text-align: center; width: 35%" class="Tit1">Id Parametro</td>
                            <td style="text-align: center; width: 35%" class="Tit1">Descripción</td>
                            <td style="text-align: center; width: 9%" class="Tit1">Selec. </td>
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
            <td style="text-align: center; width: 35%">
                <xsl:value-of  select="@id_param" />
            </td>
            <td style="text-align: center; width: 35%">
                <xsl:value-of  select="@param" />
            </td>
            <td style="text-align: center" width="5%">
                <img src="/FW/image/icons/seleccionar.png" style="cursor:pointer">
                        <xsl:attribute name="onclick">parent.mostrar('<xsl:value-of select="@id_param"/>')</xsl:attribute>
                </img>
            </td>
        </tr>
    </xsl:template>
    
</xsl:stylesheet>