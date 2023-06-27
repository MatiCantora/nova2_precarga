<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo"
                xmlns:vbuser="urn:vb-scripts">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl" />

    <xsl:template match="/">
        <html>
            <head>
                <title>Listado de Pagos agrupados por Instruccion de Pago</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

                <style type="text/css">
                    .impar { background-color: #F4F4F4 !important; }
                </style>

                <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>

                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID       = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl  = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount   = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount     = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize      = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage  = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    campos_head.orden         = '<xsl:value-of select="xml/params/@orden"/>'

                    if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW
                </script>
        
                <script type="text/javascript">
                    <![CDATA[
                    var $body


                    function window_onresize()
                    {
                        try {
                            $("contenedor").setStyle({ height: $body.getHeight() + 'px' })
                        }
                        catch(e) {}
                    }


                    function window_onload()
                    {
                        $body = $$("BODY")[0]
                        
                        window_onresize()
                        sumarTotales()
                        window.parent.cant_resultados = campos_head.recordcount
                    }


                    function showHideDetalles(elemento, registro)
                    {
                        var arr_detalles = $$('.detalle' + registro)

                        if (arr_detalles[0].style.display == 'none') {
                            // mostrar todos los detalles
                            arr_detalles.each(Element.show)
                            
                            // cambiar icono por 'menos'
                            elemento.src = '/FW/image/tTree/menos.jpg'
                            // cambiar el title
                            elemento.title = 'Ocultar detalle'
                            // agregar un estilo a la fila seleccionada
                            elemento.up('tr').setStyle({ 'font-weight': 'bold', 'background-color': '#DFD6E0' })
                        }
                        else {
                            // ocultar todos los detalles
                            arr_detalles.each(Element.hide)
                            
                            // cambiar icono por 'menos'
                            elemento.src = '/FW/image/tTree/mas.jpg'
                            // cambiar el title
                            elemento.title = 'Mostrar detalle'
                            // quitar estilo de fila seleccionada
                            elemento.up('tr').setStyle({ 'font-weight': 'normal', 'background-color': 'white' })
                        }
                    }


                    function sumarTotales()
                    {
                        $$('.sumar').each(function(fila) {
                            var suma = 0.0
	                        $$('.importe' + fila.id).each(function(item) {
		                        suma += (+item.innerHTML)
	                        })
	                        $('importe' + fila.id).innerHTML = suma.toFixed(2)
                        })
                    }
                    ]]>
                </script>
            </head>
            <body style="width: 100%; height: 100%; overflow: hidden; background: white;" onresize="window_onresize()" onload="window_onload()">

                <xsl:choose>
                    <xsl:when test="count(xml/rs:data/z:row) = 0">
                        <center>
                            <h3 style="color: #333333; margin: 2em 0 5px;">No se encontraron instrucciones de pago</h3>
                            <p style="color: #AAAAAA; margin: 0 0 1em;">Si ingresó algún filtro, intente con otra combinación</p>
                        </center>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="contenedor" style="width: 100%; overflow: auto;">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <!-- nro_proceso, fecha, nro_pago_concepto, pago_concepto, operador, nombre_operador, *TOTAL* -->
                                    <td style="width: 50px;  text-align: center;">-</td>
                                    <td style="width: 90px; text-align: center;" nowrap="true"><script>campos_head.agregar('Nro.', 'true', 'nro_proceso')</script></td>
                                    <td style="width: 150px; text-align: center;" nowrap="true"><script>campos_head.agregar('Fecha', 'true', 'fecha')</script></td>
                                    <td style="width: 200px; text-align: center;" nowrap="true"><script>campos_head.agregar('Concepto', 'true', 'pago_concepto')</script></td>
                                    <td style="width: 100px; text-align: center;" nowrap="true"><script>campos_head.agregar('Operador', 'true', 'Login')</script></td>
                                    <td style="text-align: center; min-width: 300px;">Observaciones</td>
                                    <td style="text-align: center; width: 100px;">Moneda</td>
                                    <td style="width: 150px; text-align: center;">Importe</td>
                                    <td style="width: 100px; text-align: center;">-</td>
                                </tr>
                            </table>
                            
                            <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
        
            </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row"  mode="row1">

        <xsl:variable name="pos" select="position()" />
        <xsl:variable name="proceso_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@nro_proceso" />
        <xsl:variable name="proceso" select="@nro_proceso" />
        
        <xsl:choose>
            <!-- Posicion igual a 1 o procesos diferentes -->
            <xsl:when test="$proceso_ant != $proceso or $pos = 1">
                <!--Dibujo una linea separadora solo si no es la fila 1-->
                <xsl:if test="$pos != 1">
                    <hr style="margin: 0;" />
                </xsl:if>
                
                <table class="tb1 highlightTROver sumar" id="{$proceso}">
                    <tr>
                        <td style="width: 50px; text-align: center;">
                            <xsl:if test="number(@cantidad_estados) = 1">
                                <!-- BackGround-Color: sólo si estado es igual para todos -->
                                <xsl:choose>
                                    <xsl:when test="number(@nro_pago_estado) = 0">
                                        <xsl:attribute name="style">width: 50px; text-align: center; background-color: grey;</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="number(@nro_pago_estado) = 1">
                                        <xsl:attribute name="style">width: 50px; text-align: center; background-color: blue;</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="number(@nro_pago_estado) = 2">
                                        <xsl:attribute name="style">width: 50px; text-align: center; background-color: green;</xsl:attribute>
                                    </xsl:when>
                                    <xsl:when test="number(@nro_pago_estado) = 3">
                                        <xsl:attribute name="style">width: 50px; text-align: center; background-color: red;</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="style">width: 50px; text-align: center; background-color: inherit;</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                            <img alt="Ver detalle" src="/FW/image/tTree/mas.jpg" style="cursor: pointer;" title="Mostrar detalle Instrucción de Pago" onclick="showHideDetalles(this, {$proceso})" />
                        </td>
                        <td style="width: 90px; text-align: right;"><xsl:value-of select="$proceso" />&#160;</td>
                        <td style="width: 150px;  text-align: right;"><xsl:value-of select="@fecha" />&#160;</td>
                        <td style="width: 200px;">&#160;<xsl:value-of select="@pago_concepto" /></td>
                        <td style="width: 100px;">&#160;<xsl:value-of select="@Login" /></td>
                        <td style="min-width: 300px;" title="{@observaciones}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@observaciones) &gt; 50">
                                    <xsl:value-of select="substring(@observaciones, 1, 50)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@observaciones" />
                                </xsl:otherwise>
                            </xsl:choose>
                          <input type="hidden" name="observacion_{$proceso}" id="observacion_{$proceso}" value="{@observaciones}" />
                        </td>
                        <td style="width: 100px; text-align: left;"><xsl:value-of select="@ISO_cod" />&#160;</td>
                        <td style="width: 150px; text-align: right;"><span id="importe{$proceso}"></span>&#160;</td>
                        <td style="width: 100px; text-align: center;">
                            <img alt="exportar_pdf" src="/FW/image/icons/nueva.png" style="cursor: pointer;" title="Archivos asociados al proceso Nº {$proceso}" onclick="parent.listadoArchivos({$proceso})" />&#160;
                            <img alt="exportar_pdf" src="/FW/image/filetype/pdf.png" style="cursor: pointer;" title="Exportar PDF de proceso Nº {$proceso}" onclick="parent.exportarPDFProceso({$proceso})" />&#160;
                            <img alt="Editar" src="/FW/image/icons/editar.png" style="cursor: pointer;" title="Editar proceso {$proceso}" onclick="parent.nuevaInstruccionPago({$proceso})" />&#160;
                            <img alt="Estado" src="/FW/image/icons/seleccionar.gif" style="cursor: pointer;" title="Cambiar estado al proceso {$proceso}" onclick="parent.cambiarEstado({$proceso}, '{@fecha}', '{@nro_pago_concepto}', '{@pago_concepto}', '{@nombre_operador}')" />
                        </td>
                    </tr>
                </table>
                
                <!-- Tabla con cabeceras del detalle -->
                <table class="tb1 detalle{$proceso}" cellspacing="0" cellpadding="0" style="display: none;">
                    <tr style="height: 19px;">
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td> <!-- solo para "espacear" la sub-tabla -->
                        <td class="Tit4" style="width: 180px; text-align: center;">Origen</td>
                        <td class="Tit4" style="width: 180px; text-align: center;">Destino</td>
                        <td class="Tit4" style="width: 130px; text-align: center;">Estado</td>
                        <td class="Tit4" style="width: 80px; text-align: center;">Tipo</td>
                        <td class="Tit4" style="width: 180px; text-align: center;">Banco Origen</td>
                        <td class="Tit4" style="width: 160px; text-align: center;">Cuenta Origen</td>
                        <td class="Tit4" style="width: 180px; text-align: center;">Banco Destino</td>
                        <td class="Tit4" style="width: 160px; text-align: center;">Cuenta Destino</td>
                        <td class="Tit4" style="text-align: center; min-width: 90px;">Importe</td>
                    </tr>
                </table>

                <!-- Tabla con detalle -->
                <table class="tb1 highlightTROver detalle{$proceso}" cellspacing="0" cellpadding="0" style="display: none; font-size: 0.85em;">
                    <tr style="height: 19px;">
                        <xsl:if test="($pos mod 2) != 0">
                            <xsl:attribute name="class">impar</xsl:attribute>
                        </xsl:if>
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td>
                        <td style="width: 180px;" title="{@Razon_social_origen}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@Abreviacion_origen) &gt; 0">
                                    <xsl:value-of select="@Abreviacion_origen" />
                                </xsl:when>
                                <xsl:when test="string-length(@Razon_social_origen) &gt; 23">
                                    <xsl:value-of select="substring(@Razon_social_origen, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@Razon_social_origen" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 180px;" title="{@Razon_social_destino}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@Abreviacion_destino) &gt; 0">
                                    <xsl:value-of select="@Abreviacion_destino" />
                                </xsl:when>
                                <xsl:when test="string-length(@Razon_social_destino) &gt; 23">
                                    <xsl:value-of select="substring(@Razon_social_destino, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@Razon_social_destino" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 130px;">
                          <xsl:choose>
                            <xsl:when test="@nro_pago_estado = '0'">
                              <xsl:attribute name="style">width: 130px; color: grey;</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="@nro_pago_estado = '1'">
                              <xsl:attribute name="style">width: 130px; color: blue;</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="@nro_pago_estado = '2'">
                              <xsl:attribute name="style">width: 130px; color: green;</xsl:attribute>
                            </xsl:when>
                            <xsl:when test="@nro_pago_estado = '3'">
                              <xsl:attribute name="style">width: 130px; color: red;</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:attribute name="style">width: 130px; color: inherit;</xsl:attribute>
                            </xsl:otherwise>
                          </xsl:choose>
                          &#160;<xsl:value-of select="@pago_estados" />&#160;(<xsl:value-of select="@fecha_proceso" />)
                        </td>
                        <td style="width: 80px;">&#160;<xsl:value-of select="@pago_tipo" /></td>
                        <td style="width: 180px;" title="{@banco_orig}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@banco_orig) &gt; 23">
                                    <xsl:value-of select="substring(@banco_orig, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@banco_orig" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 160px; text-align: right;"><xsl:value-of select="@nro_cuenta_orig" />&#160;</td>
                        <td style="width: 180px;" title="{@banco_dest}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@banco_dest) &gt; 23">
                                    <xsl:value-of select="substring(@banco_dest, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@banco_dest" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 160px; text-align: right;"><xsl:value-of select="@nro_cuenta_dest" />&#160;</td>
                        <td style="text-align: right; min-width: 90px;">$ <span class="importe{$proceso}"><xsl:value-of select="format-number(@importe_pago_det, '#.00')" /></span>&#160;</td>
                    </tr>
                </table>
            </xsl:when>
            
            <!-- Registros iguales: solo dibujar detalles -->
            <xsl:otherwise>
                <!-- Tabla con detalle -->
                <table class="tb1 highlightTROver detalle{$proceso}" cellspacing="0" cellpadding="0" style="display: none; font-size: 0.85em;">
                    <tr style="height: 19px;">
                        <xsl:if test="($pos mod 2) != 0">
                            <xsl:attribute name="class">impar</xsl:attribute>
                        </xsl:if>
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td>
                        <td style="width: 180px;" title="{@Razon_social_origen}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@Abreviacion_origen) &gt; 0">
                                    <xsl:value-of select="@Abreviacion_origen" />
                                </xsl:when>
                                <xsl:when test="string-length(@Razon_social_origen) &gt; 23">
                                    <xsl:value-of select="substring(@Razon_social_origen, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@Razon_social_origen" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 180px;" title="{@Razon_social_destino}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@Abreviacion_destino) &gt; 0">
                                    <xsl:value-of select="@Abreviacion_destino" />
                                </xsl:when>
                                <xsl:when test="string-length(@Razon_social_destino) &gt; 23">
                                    <xsl:value-of select="substring(@Razon_social_destino, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@Razon_social_destino" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 130px;">
                            <xsl:choose>
                              <xsl:when test="@nro_pago_estado = '0'">
                                <xsl:attribute name="style">width: 130px; color: grey;</xsl:attribute>
                              </xsl:when>
                              <xsl:when test="@nro_pago_estado = '1'">
                                <xsl:attribute name="style">width: 130px; color: blue;</xsl:attribute>
                              </xsl:when>
                              <xsl:when test="@nro_pago_estado = '2'">
                                <xsl:attribute name="style">width: 130px; color: green;</xsl:attribute>
                              </xsl:when>
                              <xsl:when test="@nro_pago_estado = '3'">
                                <xsl:attribute name="style">width: 130px; color: red;</xsl:attribute>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:attribute name="style">width: 130px; color: inherit;</xsl:attribute>
                              </xsl:otherwise>
                            </xsl:choose>
                            &#160;<xsl:value-of select="@pago_estados" />&#160;(<xsl:value-of select="@fecha_proceso" />)
                        </td>
                        <td style="width: 80px;">
                            &#160;<xsl:value-of select="@pago_tipo" />
                        </td>
                        <td style="width: 180px;" title="{@banco_orig}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@banco_orig) &gt; 23">
                                    <xsl:value-of select="substring(@banco_orig, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@banco_orig" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 160px; text-align: right;">
                            <xsl:value-of select="@nro_cuenta_orig" />&#160;
                        </td>
                        <td style="width: 180px;" title="{@banco_dest}">
                            &#160;
                            <xsl:choose>
                                <xsl:when test="string-length(@banco_dest) &gt; 23">
                                    <xsl:value-of select="substring(@banco_dest, 1, 23)" />...
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@banco_dest" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td style="width: 160px; text-align: right;">
                            <xsl:value-of select="@nro_cuenta_dest" />&#160;
                        </td>
                        <td style="text-align: right; min-width: 90px;">
                            $ <span class="importe{$proceso}">
                                <xsl:value-of select="format-number(@importe_pago_det, '#.00')" />
                            </span>&#160;
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>