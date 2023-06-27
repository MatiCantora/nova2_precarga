<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
            <title>Listado conceptos financieros</title>
            
            <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
        
            <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
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

                function window_onresize() {
                    var body = $$("BODY")[0],
                        altoDiv = body.clientHeight - 50
                    try {
                        $("divBody").setStyle({height: altoDiv + "px" })
                    }
                    catch(e) {}

                    campos_head.resize("tbCabe", "tbDetalle")
                }

                function window_onload() {
                    window_onresize()
                }

				
            </script>
        </head>

        <body style="width:100%;height:100%;overflow:hidden; background:#FFFFFF" onresize="window_onresize()" onload="window_onload()">
            <table class="tb1 " id="tbCabe">
	          	<tr class="tbLabel">
	            	<td style="width:100px">
	              		<script>campos_head.agregar('ID', 'true', 'cf_id')</script>
	            	</td>
		            <td>
		              	<script>campos_head.agregar('Conceptos', 'true', 'cf_concepto')</script>
		            </td>
		              	<td style="width:200px">Concepto abreviado
		            </td>
		            <td >
		              	<script>campos_head.agregar('Tipo', 'true', 'cf_tipo')</script>
		            </td>
		            <td style="width:50px" >Editar</td>  
	          </tr>
	        </table>
            <div style="width:100%; height:300px; overflow-y:auto" id="divBody">
                <table  class="tb1 highlightOdd highlightTROver layout_fixed" id="tbDetalle" >
                    <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
                </table>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="z:row"  mode="row1">
    <tr>
        <td>
            <xsl:value-of  select="@cf_id" />
        </td>
        <td >
            <xsl:value-of  select="@cf_concepto" />
        </td>
        <td >
       		<xsl:value-of  select="@cf_abrev" />
	    </td>
	    <td>
	        <xsl:value-of  select="@cf_tipo" /> 
	    </td>
	    <td style="align:center; text-align:center">
	    	<img src="/fw/image/icons/editar.png" style="cursor:pointer" >
				<xsl:attribute name="onclick">window.parent.concepto_editar('<xsl:value-of select="@cf_id"/>')</xsl:attribute>
	        </img>
	    </td>
    </tr>
</xsl:template>
</xsl:stylesheet>