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
                            $body         = $$('body')[0]
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
                <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
                    <div id="result_vacio" style="width: 100%; text-align: center; font: 13px Tahoma, Arial, sans-serif; height: 100px; position: absolute; top: 50%; left: 50%; margin-top: -50px; margin-left: -50%;">
                        <h3>Se ha completado la búsqueda</h3>
                        <p style="color: #AAA;">No se encontraron vínculos</p>
                    </div>
                </body>
            </xsl:when>

            <xsl:otherwise>
		        <head>
                    <title>Listado de Vínculos</title>
                    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW.js"></script>
                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_BasicControls.js"></script>
                    <script type="text/javascript" language="javascript" src="/fw/script/nvFW_windows.js"></script>
                    <script type="text/javascript" language='javascript' src="/fw/script/tcampo_def.js"></script>
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
                        var $frame_buscar
                        
                        
                        function window_onload()
                        {
                            // cachear los elementos en variables
                            $body         = $$('body')[0]
                            $tb_titulos   = $('tb_titulos')
                            $div_detalles = $('div_detalles')
                            $tb_detalles  = $('tb_detalles')
                            $tdScroll     = $('tdScroll')
                            $frame_buscar = ObtenerVentana('frame_buscar')

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
                        
                    
                        function cargarDatosCliente(cuit)
                        {
                            $frame_buscar.cargarDatosCliente(cuit)
                        }
                        
                    
                        function verVinculo(event, relacion, vinc_tipdoc, vinc_nrodoc)
                        {
                            nvFW.selection_clear()
                            parent.verVinculo(event, relacion, vinc_tipdoc, vinc_nrodoc)
                        }
                    ]]>
                    </xsl:comment>
                    </script>
                    <style type="text/css">
                      .vinculo { cursor: pointer; color: blue; }
                      .vinculo:hover { text-decoration: underline; }
                    </style>
			    </head>
                <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFF;">
                    <table class="tb1" id="tb_titulos">
                        <tr class="tbLabel">
                            
                            <td style="width: 40px; text-align: center;"><script>campos_head.agregar('Ver', false, 'vinc_nrodoc')</script></td>
                            <td style="width: 20%; text-align: center;"><script>campos_head.agregar('Relación', true, 'vincliclinom')</script></td>
                            <td style="width: 20%; text-align: center;"><script>campos_head.agregar('Tipo de relación', true, 'tipvinclidesc')</script></td>
                            <td style="width: 130px; text-align: center;"><script>campos_head.agregar('CUIT / CUIL', true, 'vinc_CUIT_CUIL')</script></td>
                            <td style="text-align: center;"><script>campos_head.agregar('Nombre', true, 'vinc_razon_social')</script></td>
                            <td style="width: 100px; text-align: center;"><script>campos_head.agregar('Desde', true, 'clivinfecalta')</script></td>
                            <td style="width: 100px; text-align: center;"><script>campos_head.agregar('Hasta', true, 'clivinfecven')</script></td>
                            
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
	    <xsl:variable name="openro" select="@openro" />
        <xsl:variable name="vinc_tipdoc" select="@vinc_tipdoc" />
        <xsl:variable name="vinc_nrodoc" select="@vinc_nrodoc" />
        <xsl:variable name="documento" select="concat(@vinc_tipdoc_desc, ': ', @vinc_nrodoc)" />
      <xsl:variable name="nombre" select="@vinc_razon_social" />

        <tr id="tr_ver{$pos}">
            <td style="width: 40px; text-align: center;">
              <img src="../../FW/image/icons/ver.png" style="cursor:pointer" title="{$documento}">
                <xsl:attribute name="onclick">
                  verVinculo(event, '<xsl:value-of select="@vinc_razon_social"/>', '<xsl:value-of select="@vinc_tipdoc"/>', '<xsl:value-of select="@vinc_nrodoc"/>')
                </xsl:attribute>
              </img>
            </td>
            <td style="width: 20%; text-align: left;">
              <xsl:value-of select="@vincliclinom" />
            </td>
            <td style="width: 20%; text-align: left;">
              <xsl:value-of select="@tipvinclidesc" />
            </td>
            <td style="width: 130px; text-align: left;">
              <xsl:value-of select="@vinc_CUIT_CUIL" />
            </td>
            <td style="text-align: left;">
                <xsl:value-of select="@vinc_razon_social" />
            </td>
              
            
            <td style="width: 100px; text-align: center;">
              <xsl:value-of select="foo:FechaToSTR(string(@clivinfecalta))" />
            </td>
            <td style="width: 100px; text-align: center;">
              <xsl:value-of select="foo:FechaToSTR(string(@clivinfecven))" />
            </td>
            
        </tr>
    </xsl:template>
</xsl:stylesheet>