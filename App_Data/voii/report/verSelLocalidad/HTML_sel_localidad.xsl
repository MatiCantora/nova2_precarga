<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:include href="..\..\..\voii\report\xsl_includes\js_formato.xsl"/>
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    

    <xsl:template match="/">
        <html>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

                        <title>Buscar Localidad</title>
						<!--#include virtual="../../FW/scripts/pvAccesoPagina.asp"-->
						<!--#include virtual="../../FW/scripts/pvUtiles.asp"-->
						<link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>
						<link href="../../FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
						<link href="../../FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />
						<link href="../../FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />
						<link href="../../FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

						<script type="text/javascript" src="../../FW/script/prototype.js"></script>
						<script type="text/javascript" src="../../FW/script/window.js"></script>
						<script type="text/javascript" src="../../FW/script/effects.js"></script>

						<script type="text/javascript" src="../../FW/script/acciones.js"></script>
						<script type="text/javascript" src="../../FW/script/imagenes_icons.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/mnuSvr.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/DMOffLine.js"></script>
						<script type="text/javascript" src="../../FW/script/rsXML.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/tXML.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/nvFW.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/tCampo_head.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/tCampo_def.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/utiles.js" language="JavaScript"></script>
						<script type="text/javascript" src="../../FW/script/tSesion.js"></script>

                        <script type="text/javascript">
                            campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                            var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                            campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                            campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                            campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                            campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                            campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                            campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                            if (mantener_origen == '0')
                            campos_head.nvFW = parent.nvFW
                        </script>
                        <script  language="javascript" >
                            <xsl:comment>
                                <![CDATA[ 

                        
                        function seleccionar_localidad(postal,postal_real,localidad,car_tel)
                        {
                            desc = 'CP: '+postal_real+' - '+localidad
                            parent.selLocalidad(postal, desc, car_tel)
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
                                            <td style='text-align: center; width:10%' nowrap='true'>-</td>
                                            <td style='text-align: center; width:20%' nowrap='true'>
                                                <script>
                                                    campos_head.agregar('Código Postal', true, 'postal_real')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:70%'>
                                                <script>
                                                    campos_head.agregar('Localidad', true, 'localidad')
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
            <td style='text-align: center; width:10%' nowrap='true'>
                <img title="Seleccionar Localidad" src="../../fw/image/icons/agregar_cargo.png" style="cursor:pointer">
                <xsl:attribute name="onclick">seleccionar_localidad('<xsl:value-of select='@postal'/>','<xsl:value-of select='@postal_real'/>','<xsl:value-of select="@localidad"/>','<xsl:value-of select="@car_tel"/>')</xsl:attribute>
                </img>
            </td>
            <td style='text-align: left; width:20%'>
                <xsl:value-of select="@postal_real"/>
            </td>
            <td style='text-align: left; width:70%'>
                <xsl:value-of select="@localidad"/>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>