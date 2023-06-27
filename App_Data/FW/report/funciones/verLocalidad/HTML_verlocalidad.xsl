<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl"  />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    

    <xsl:template match="/">
        <html>
                    <head>
                      <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                      <title>Listado localidad</title>
                      <link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>
                      <link href="../../FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
                      <link href="../../FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />

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
                      <!--definicion del template por defecto-->

                      <script language="javascript" type="text/javascript">
                            <xsl:comment>
                                <![CDATA[ 

                        
                        function seleccionar_localidad(postal,postal_real,provincia,localidad,car_tel,cod_prov,cod_veraz_prov)
                        {
                            desc = 'CP: '+postal_real+' - '+localidad
                            parent.selLocalidad(postal, desc, car_tel,provincia,localidad,cod_prov,cod_veraz_prov)
                        }
                        
                        function seleccionar(indice)
					             {
					                $('tr_ver'+indice).addClassName('tr_cel')
					             }
                         
					            function no_seleccionar(indice)
					             {
					                $('tr_ver'+indice).removeClassName('tr_cel')
					             }
                    ]]>
                            </xsl:comment>
                        </script>
                        <style type="text/css">
                            .tr_cel TD {
                            background-color: #F0FFFF !Important
                            }
                        </style>
                    </head>
                    <body style="width:100%;height:100%;overflow:auto">
                        <table width="100%" class="tb1" id="tbCabecera">
                            <tr class="tbLabel">
                                <td>
                                    <table width="100%">
                                        <tr class="tbLabel">
                                            <td style='text-align: center; width:5%' nowrap='true'>-</td>
                                            <td style='text-align: center; width:15%' nowrap='true'>
                                                <script>
                                                    campos_head.agregar('Código Postal', true, 'postal_real')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:30%'>
                                                <script>
                                                    campos_head.agregar('Localidad', true, 'localidad')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:30%'>
                                                <script>
                                                    campos_head.agregar('Provincia', true, 'provincia')
                                                </script>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <div style="width:100%; overflow:auto">
                            <table class="tb1" width="100%">
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
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
            <xsl:attribute name="onmousemove">seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <xsl:attribute name="onmouseout">no_seleccionar(<xsl:value-of select="$pos"/>)</xsl:attribute>
            <td style='text-align: center; width:5%' nowrap='true'>
                <img title="Seleccionar Localidad" src="/fw/image/icons/agregar.png" style="cursor:pointer">
                <xsl:attribute name="onclick">seleccionar_localidad('<xsl:value-of select='@postal'/>','<xsl:value-of select='@postal_real'/>','<xsl:value-of select="@provincia"/>','<xsl:value-of select="@localidad"/>','<xsl:value-of select="@car_tel"/>','<xsl:value-of select="@cod_prov"/>','<xsl:value-of select="@cod_veraz_prov"/>')</xsl:attribute>
                </img>
            </td>
            <td style='text-align: left; width:15%'>
                <xsl:value-of select="@postal_real"/>
            </td>
            <td style='text-align: left; width:30%'>
                <xsl:attribute name='title'><xsl:value-of select="@localidad" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@localidad) &#62; 25">
                        <xsl:value-of select="substring(@localidad,1,25)"/>...
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@localidad"/></xsl:otherwise>
                </xsl:choose>
            </td>
            <td style='text-align: left; width:30%'>
                <xsl:attribute name='title'><xsl:value-of select="@provincia" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@provincia) &#62; 25">
                        <xsl:value-of select="substring(@provincia,1,25)"/>...
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@provincia"/></xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>