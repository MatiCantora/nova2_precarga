<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />
    <xsl:include href="..\..\..\FW\report\xsl_includes\js_formato.xsl" />

    <msxsl:script language="javascript" implements-prefix="foo">
	    <![CDATA[]]>
    </msxsl:script>

    <xsl:template match="/">
	    <html>
        <xsl:choose>
            <xsl:when test="count(xml/rs:data/z:row) = 0">
                <head>
                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
                    <script type="text/javascript" language="javascript">
                    <xsl:comment>
                    <![CDATA[
                        var dif   = Prototype.Browser.IE ? 5 : 0
                        var alto  = 0
                        var ancho = 0
                        var $body
                        var $result_vacio


                        function window_onload()
                        {
                            // Cachear los elementos
                            $body = $$('body')[0]
                            $result_vacio = $('result_vacio')

                            window_onresize()
                        }


                        function window_onresize()
                        {
                            try {
                                alto  = $result_vacio.getHeight() + dif
                                ancho = $body.getWidth()

                                window.top.win.setSize(ancho, alto)
                            }
                            catch(e) {}
                        }
                    ]]>
                    </xsl:comment>
                    </script>
                </head>
                <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow: hidden">
                    <div id="result_vacio" style="width: 100%; text-align: center; font: 13px Tahoma, Arial, sans-serif; height: 100px; position: absolute; top: 50%; left: 50%; margin-top: -50px; margin-left: -50%;">
                        <h3>Se ha completado la búsqueda</h3>
                        <p style="color: #AAA;">No se encontraron préstamos para el CUIT solicitado</p>
                    </div>
                </body>
            </xsl:when>

            <xsl:when test="count(xml/rs:data/z:row) = 1">
                <head>
                    <xsl:variable name="id_prestamo">
                        <xsl:value-of select="xml/rs:data/z:row/@paiscod"/>-<xsl:value-of select="xml/rs:data/z:row/@bcocod"/>-<xsl:value-of select="xml/rs:data/z:row/@succod"/>-<xsl:value-of select="xml/rs:data/z:row/@sistcod"/>-<xsl:value-of select="xml/rs:data/z:row/@codsubsist"/>-<xsl:value-of select="xml/rs:data/z:row/@moncod"/>-<xsl:value-of select="xml/rs:data/z:row/@cuecod"/>-<xsl:value-of select="xml/rs:data/z:row/@openro"/>
                    </xsl:variable>
                    <xsl:variable name="cuit" select="xml/rs:data/z:row/@nrodoc" />

                    <meta http-equiv="Refresh">
                        <xsl:attribute name="content">
                            0; url=/voii/cargar_prestamo.aspx?cuit=<xsl:value-of select="$cuit"/>&#38;id_prestamo=<xsl:value-of select="$id_prestamo"/>
                        </xsl:attribute>
                    </meta>
                </head>
            </xsl:when>

            <xsl:otherwise>
		        <head>
                    <title>Buscar Nro Operación</title>
                    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_BasicControls.js"></script>
                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>
                    <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>

				    <script type="text/javascript" language="javascript">
                    <xsl:comment>
                        var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'

                        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                        campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
                        campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
                        campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
                        campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
                        campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
                        campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>

                        if (mantener_origen == '0')
                            campos_head.nvFW = window.parent.nvFW

                    <![CDATA[
                        var dif = Prototype.Browser.IE ? 5 : 0
                        var $body
                        var $tb_titulos
                        var $div_detalles
                        var $tb_detalles
                        var $tdScroll
                        var $frame_ppal
                        
                        
                        function window_onload()
                        {
                            // cachear los elementos en variables
                            $body         = $$('body')[0]
                            $tb_titulos   = $('tb_titulos')
                            $div_detalles = $('div_detalles')
                            $tb_detalles  = $('tb_detalles')
                            $tdScroll     = $('tdScroll')
                            $frame_ppal   = ObtenerVentana('frame_ref')

                            window_onresize()
                        }


                        function window_onresize()
                        {
			                try {
				                var body_h        = $body.getHeight()
				                var tb_titulos_h  = $tb_titulos.getHeight()
				                var tb_detalles_h = $tb_detalles.getHeight()
				                var contenedor_h  = body_h - tb_titulos_h - dif
                                
                                $div_detalles.style.height = contenedor_h + 'px'
                                
                                tdScroll_hide_show(tb_detalles_h > contenedor_h)
				            }
			                catch(e) {}
			            }


			            function tdScroll_hide_show(show)
                        {
                            show ? $tdScroll.show() : $tdScroll.hide()
                        }
                        
                    
                        function cargarPrestamo(cuit, id_prestamo)
                        {
                            debugger
                            $frame_ppal
                        }
                    ]]>
                    </xsl:comment>
                    </script>
			    </head>
                <body onload="window_onload()" style="width: 100%; height: 100%; overflow: hidden; background: #FFF;">
                    <table class="tb1" id="tb_titulos">
                        <tr class="tbLabel">
                            <td style="width: 25px; text-align: center;">-</td>
                            <td style="width: 90px; text-align: center;">Nro. Operación</td>
                            <td style="width: 100px; text-align: center;"><b>CUIT</b></td>
                            <td style="width: 250px; text-align: center;"><b>Apellido</b></td>
                            <td style="text-align: center;"><b>Nombre</b></td>
                            <td style="width: 100px; text-align: center;"><b>Sexo</b></td>
                            <td style="width: 100px; text-align: center;"><b>Fecha Nac.</b></td>
                            <td id="tdScroll" style="width: 14px !important; display: none; text-align: center;">&#160;</td>
	                    </tr>
                    </table>

                    <div id="div_detalles" style="width: 100%; overflow: auto;">
                        <table class="tb1 highlightOdd highlightTROver" id="tb_detalles">
                            <xsl:apply-templates select="xml/rs:data/z:row" />
                        </table>
                    </div>
                </body>
            </xsl:otherwise>
        </xsl:choose>
	    </html>
	</xsl:template>

    <xsl:template match="z:row">
	    <xsl:variable name="pos" select="position()" />
	    <xsl:variable name="cuit" select="@nrodoc" />
        <xsl:variable name="id_prestamo">
            <xsl:value-of select="@paiscod"/>-<xsl:value-of select="@bcocod"/>-<xsl:value-of select="@succod"/>-<xsl:value-of select="@sistcod"/>-<xsl:value-of select="@codsubsist"/>-<xsl:value-of select="@moncod"/>-<xsl:value-of select="@cuecod"/>-<xsl:value-of select="@openro"/>
        </xsl:variable>

        <tr id="tr_ver{$pos}">
            <td style="width: 25px; text-align: center;">
                <img alt="Seleccionar" src="/FW/image/icons/seleccionar.png" style="cursor: pointer;" title="Seleccionar operación {@openro} de {@cliape}, {@clinom}" onclick="return cargarPrestamo({$cuit, $id_prestamo})" />
            </td>
            <td style="width: 90px; text-align: right;">
                <xsl:value-of select="@openro"/>
            </td>
            <td style="width: 100px; text-align: right;">
                <xsl:value-of select="$cuit" />
            </td>
            <td style="width: 250px;">
                <xsl:value-of select="@cliape" />
            </td>
            <td>
                <xsl:value-of select="@clinom" />
            </td>
            <td style="width: 100px; text-align: center;">
                <xsl:choose>
                    <xsl:when test="string(@clisexo) = 'F'">FEMENINO</xsl:when>
                    <xsl:when test="string(@clisexo) = 'M'">MASCULINO</xsl:when>
                </xsl:choose>
            </td>
            <td style="width: 100px; text-align: right;">
                <xsl:value-of select="foo:FechaToSTR(string(@clifecnac), 1)" />
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>