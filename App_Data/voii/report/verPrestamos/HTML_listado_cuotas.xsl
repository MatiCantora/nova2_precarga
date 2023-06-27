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
                        <p style="color: #AAA;">No cuotas asociadas al préstamo solicitado</p>
                    </div>
                </body>
            </xsl:when>

            <xsl:otherwise>
		        <head>
                    <title>Listado de Cuotas</title>
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
                        var $div_resumen
                        var $tdScroll
                        var $frame_buscar
                        var hr_h
                        
                        
                        function window_onload()
                        {
                            // cachear los elementos en variables
                            $body         = $$('body')[0]
                            $tb_titulos   = $('tb_titulos')
                            $div_detalles = $('div_detalles')
                            $tb_detalles  = $('tb_detalles')
                            $div_resumen  = $('div_resumen')
                            $tdScroll     = $('tdScroll')
                            $frame_buscar = ObtenerVentana('frame_buscar')
                            hr_h          = $('hr_separador').getHeight()

                            window_onresize()
                        }


                        function window_onresize()
                        {
			                try {
				                var body_h        = $body.getHeight()
				                var tb_titulos_h  = $tb_titulos.getHeight()
				                var tb_detalles_h = $tb_detalles.getHeight()
                                var div_resumen_h = $div_resumen.getHeight()
				                var contenedor_h  = body_h - tb_titulos_h - div_resumen_h - hr_h - dif

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
                        
                    
                        function verPrestamo(event, nro_operacion)
                        {
                            nvFW.selection_clear()
                            parent.verPrestamo(event, nro_operacion)
                        }
                    ]]>
                    </xsl:comment>
                    </script>
			    </head>
                <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFF;">
                    <table class="tb1" id="tb_titulos">
                        <tr class="tbLabel">
                            <td style="width: 100px; text-align: center;"><script>campos_head.agregar('Nro. Cuota', true, 'nrocuo')</script></td>
                            <td style="text-align: center;">Detalle</td>
                            <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Vencimiento', true, 'fecven')</script></td>
                            <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Importe', true, 'importe_cuota')</script></td>
                            <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Ultimo pago', true, 'fe_ultipago')</script></td>
                            <td style="width: 120px; text-align: center;">Pagado</td>
                            <td style="width: 120px; text-align: center;">Debe</td>
                            <td id="tdScroll" style="width: 14px !important; display: none; text-align: center;">&#160;</td>
	                    </tr>
                    </table>

                    <div id="div_detalles" style="width: 100%; overflow: auto;">
                        <table class="tb1 highlightOdd highlightTROver" id="tb_detalles">
                            <xsl:apply-templates select="xml/rs:data/z:row" />
                        </table>
                    </div>

                    <hr id="hr_separador" style="width: 100%; margin: 0; padding: 0;" />

                    <div id="div_resumen" style="width: 100%;">
                        
                         <!--Determinar la moneda--> 
                        <xsl:variable name="moneda" select="xml/rs:data/z:row/@monsimbolo" />
                        
                        <table class="tb1">
                            <tr>
							    <td class="Tit1" style='width: 35%;' nowrap='true'><b>Total abonado:</b></td>
								<td style='text-align: right; width: 15%' nowrap='true'>
                                    <xsl:variable name="suma_pagos" select="sum(xml/rs:data/z:row/@importe_pago)" />
                                    <input type="text" value="{$moneda} {format-number($suma_pagos, '#0.00')}" style="width: 100%; text-align: right;" disabled="disabled" />
                                    <!--<xsl:value-of select='$moneda' />&#160;<xsl:value-of select="format-number($suma_pagos, '#0.00')" />-->
								</td>
								<td class="Tit1" style='width:35%;' nowrap='true'><b>Saldo vencido:</b></td>
								<td style='text-align: right; width: 15%' nowrap='true'>
                                    
                                    <!--
                                    Estados de operación (estopercod)
                                    ====================================
                                    0   SIN USO
                                    1	Activo
                                    6	Baja
                                    5	Cancelada
                                    -->
                                    
                                    <xsl:variable name='estado' select='xml/rs:data/z:row/@estopercod' />

                                    <xsl:choose>
                                        <xsl:when test="$estado = '0'">
                                            <input type="text" value="{$moneda} 0.00" style="width: 100%; text-align: right;" disabled="disabled" />
                                        </xsl:when>
                                        <xsl:otherwise>
								            <xsl:if test="$estado = '1'">
									            <xsl:variable name="suma_vencido" select="format-number(sum(xml/rs:data/z:row[foo:fecha_vencida(string(@fecven))]/@importe_cuota) - sum(xml/rs:data/z:row[foo:fecha_vencida(string(@fecven))]/@importe_pago), '0.00')"/>
                                                <input type="text" value="{$moneda} {format-number($suma_vencido, '#0.00')}" style="width: 100%; text-align: right;" disabled="disabled">
                                                    <xsl:if test='$suma_vencido > 0'>
                                                        <xsl:attribute name='style'>width: 100%; text-align: right; color: red;</xsl:attribute>
                                                    </xsl:if>
                                                </input>
									        </xsl:if>
									        <xsl:if test="$estado = '5' or $estado = '6'">
									            <input type="text" value="{$moneda} 0.00" style="width: 100%; text-align: right;" disabled="disabled" />
									        </xsl:if>
                                        </xsl:otherwise>
                                    </xsl:choose>
									</td>
								</tr>
								<tr>
									<td class="Tit1" style='width: 35%;' nowrap='true'><b>Debe pago a cuenta:</b></td>
									<td style='text-align: right; width: 15%;' nowrap='true'>
									    <xsl:variable name="suma_deuda_a_cuenta" select="xml/rs:data/z:row/@importe_deuda"/>
                                        <input type="text" value="{$moneda} {format-number($suma_deuda_a_cuenta, '#0.00')}" style="width: 100%; text-align: right;" disabled="disabled">
										    <xsl:if test="number($suma_deuda_a_cuenta) > 0.00">
											    <xsl:attribute name="style">width: 100%; text-align: right; color: red;</xsl:attribute>
										    </xsl:if>
                                        </input>
									</td>
									<td class="Tit1" style='width:35%;' nowrap='true'><b>Saldo a cobrar:</b></td>
									<td style='text-align: right; width: 15%;' nowrap='true'>
										<xsl:variable name="suma_debe" select="sum(xml/rs:data/z:row/@importe_cuota) - sum(xml/rs:data/z:row/@importe_pago)" />
                                        <input type="text" value="{$moneda} {format-number($suma_debe, '#0.00')}" style="width: 100%; text-align: right;" disabled="disabled" />
									</td>
								</tr>
                        </table>
                    </div>
                </body>
            </xsl:otherwise>
        </xsl:choose>
	    </html>
	</xsl:template>

    <xsl:template match="z:row">
	    <xsl:variable name="pos" select="position()" />
        <xsl:variable name="moneda" select="@monsimbolo" />

        <tr id="tr_ver{$pos}">
            <td style="width: 100px; text-align: center;">
                <xsl:value-of select="@nrocuo" />
            </td>
            <td style="text-align: left;">
                <xsl:value-of select="@detalle" />
            </td>
            <td style="width: 120px; text-align: right;">
                <xsl:value-of select="@fecven" />
            </td>
            <td style="width: 120px; text-align: right;">
                <xsl:value-of select="$moneda" />&#160;<xsl:value-of select="format-number(@importe_cuota, '#0.00')" />
            </td>
            <td style="width: 120px; text-align: right;">
                <!--<xsl:choose>
                    <xsl:when test="string(@fe_ultipago) = ''">&#160;</xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@fe_ultipago" />
                    </xsl:otherwise>
                </xsl:choose>-->
                <xsl:value-of select="@fe_ultipago" />
            </td>
            <td style="width: 120px; text-align: right;">
                <xsl:value-of select="$moneda" />&#160;<xsl:value-of select="format-number(@importe_pago, '#0.00')" />
            </td>
            <td style="width: 120px; text-align: right;">
                <xsl:value-of select="$moneda" />&#160;<xsl:value-of select="format-number(@importe_deuda, '#0.00')" />
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>