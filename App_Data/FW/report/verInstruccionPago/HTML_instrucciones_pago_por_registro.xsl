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

    <xsl:template match="/">
        <html>
            <head>
                <title>Listado de Pagos agrupador por Registro</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

                <style type="text/css">
                    .impar { background-color: #F4F4F4 !important; }
                </style>

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
                </script>
        
                <script type="text/javascript">
                    <![CDATA[
                    function window_onresize()
                    {
                        try {
                            var body = $$("BODY")[0],
                            altoDiv  = body.clientHeight - 50

                            $("divBody").setStyle({ height: altoDiv + "px" })
                        }
                        catch(e) {}
                    }


                    function window_onload()
                    {
                        window_onresize()
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
                    ]]>
                </script>
            </head>
            <body style="width: 100%; height: 100%; overflow: hidden; background: white;" onresize="window_onresize()" onload="window_onload()">

                <xsl:choose>
                    <xsl:when test="count(xml/rs:data/z:row) = 0">
                        <center>
                            <h3 style="color: #333333; margin: 2em 0 5px;">No se encontraron regtistros de pago</h3>
                            <p style="color: #AAAAAA; margin: 0 0 1em;">Si ingresó algún filtro, intente con otra combinación</p>
                        </center>
                    </xsl:when>
                    <xsl:otherwise>
                        <table class="tb1" id="tbNosisCdas">
                            <tr class="tbLabel">
                                <!--nro_pago_registro,fecha,pago_concepto,importe_pago,Razon_social_origen,Razon_social_destino,nombre_operador-->
                                <td style="width: 50px; text-align: center;">-</td>
                                <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Nro. Registro', 'true', 'nro_pago_registro')</script></td>
                                <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Fecha', 'true', 'fecha')</script></td>
                                <td style="width: 150px; text-align: center;"><script>campos_head.agregar('Concepto', 'true', 'pago_concepto')</script></td>
                                <td style="width: 320px; text-align: center;"><script>campos_head.agregar('Origen', 'true', 'Razon_social_origen')</script></td>
                                <td style="width: 320px; text-align: center;"><script>campos_head.agregar('Destino', 'true', 'Razon_social_destino')</script></td>
                                <td style="text-align: center;"><script>campos_head.agregar('Operador', 'true', 'nombre_operador')</script></td>
                                <td style="width: 120px; text-align: center;"><script>campos_head.agregar('Importe', 'true', 'importe_pago')</script></td>
                                <!--<td style="width: 50px; text-align: center;">-</td>-->
                            </tr>
                        </table>
                            
                        <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />

                    </xsl:otherwise>
                </xsl:choose>
        
            </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row"  mode="row1">

        <xsl:variable name="pos" select="position()" />
        <xsl:variable name="registro_anterior" select="/xml/rs:data/z:row[position() = ($pos -1)]/@nro_pago_registro" />
        <xsl:variable name="registro" select="@nro_pago_registro" />
        
        <xsl:choose>
            <!-- Posicion igual a 1 o registros diferentes -->
            <xsl:when test="$registro_anterior != $registro or $pos = 1">
                <!--Dibujo una linea separadora solo si no es la fila 1-->
                <xsl:if test="$pos != 1">
                    <hr style="margin: 0;" />
                </xsl:if>
                
                <table class="tb1 highlightTROver" id="{$registro}">
                    <tr>
                        <td style="width: 50px; text-align: center;">
                            <img alt="Ver detalle" src="/FW/image/tTree/mas.jpg" style="cursor: pointer;" title="Mostrar detalle" onclick="showHideDetalles(this, {$registro})" />
                        </td>
                        <td style="width: 120px; text-align: right;"><xsl:value-of select="@nro_pago_registro" />&#160;</td>
                        <td style="width: 120px;  text-align: right;"><xsl:value-of select="@fecha" />&#160;</td>
                        <td style="width: 150px;">&#160;<xsl:value-of select="@pago_concepto" /></td>
                        <td style="width: 320px;">&#160;<xsl:value-of select="@Razon_social_origen" /></td>
                        <td style="width: 320px;">&#160;<xsl:value-of select="@Razon_social_destino" /></td>
                        <td>&#160;<xsl:value-of select="@nombre_operador" /></td>
                        <td style="width: 120px; text-align: right;">$ <xsl:value-of select="format-number(@importe_pago, '#.00')" />&#160;</td>
                        <!--<td style="width: 50px; text-align: center;">
                            <img alt="Editar" src="/FW/image/icons/editar.png" style="cursor: pointer;" title="Editar registro {$registro}" onclick="" />
                        </td>-->
                    </tr>
                </table>
                
                <!-- Tabla con cabeceras del detalle -->
                <table class="tb1 detalle{$registro}" cellspacing="0" cellpadding="0" style="display: none;">
                    <tr style="height: 19px;">
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td> <!-- solo para "espacear" la sub-tabla -->
                        <td class="Tit4" style="text-align: center;">Nro. Pago Detalle</td>
                        <td class="Tit4" style="width: 100px; text-align: center;">Estado</td>
                        <td class="Tit4" style="width: 100px; text-align: center;">Tipo</td>
                        <td class="Tit4" style="width: 250px; text-align: center;">Banco Origen</td>
                        <td class="Tit4" style="width: 200px; text-align: center;">Cuenta Origen</td>
                        <td class="Tit4" style="width: 250px; text-align: center;">Banco Destino</td>
                        <td class="Tit4" style="width: 200px; text-align: center;">Cuenta Destino</td>
                        <td class="Tit4" style="width: 100px; text-align: center;">Importe</td>
                    </tr>
                </table>

                <!-- Tabla con detalle -->
                <table class="tb1 highlightTROver detalle{$registro}" cellspacing="0" cellpadding="0" style="display: none;">
                    <tr style="height: 19px;">
                        <xsl:if test="($pos mod 2) != 0">
                            <xsl:attribute name="class">impar</xsl:attribute>
                        </xsl:if>
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td> <!-- solo para "espacear" la sub-tabla -->
                        <td style="text-align: right;"><xsl:value-of select="@nro_pago_detalle" />&#160;</td>
                        <td style="width: 100px;">&#160;<xsl:value-of select="@pago_estados" /></td>
                        <td style="width: 100px;">&#160;<xsl:value-of select="@pago_tipo" /></td>
                        <td style="width: 250px;">&#160;<xsl:value-of select="@banco_orig" /></td>
                        <td style="width: 200px; text-align: right;"><xsl:value-of select="@nro_cuenta_orig" />&#160;</td>
                        <td style="width: 250px;">&#160;<xsl:value-of select="@banco_dest" /></td>
                        <td style="width: 200px; text-align: right;"><xsl:value-of select="@nro_cuenta_dest" />&#160;</td>
                        <td style="width: 100px; text-align: right;">$ <xsl:value-of select="format-number(@importe_pago_det, '#.00')" />&#160;</td>
                    </tr>
                </table>
            </xsl:when>
            
            <!-- Registros iguales: solo dibujar detalles -->
            <xsl:otherwise>
                <!-- Tabla con detalle -->
                <table class="tb1 highlightTROver detalle{$registro}" cellspacing="0" cellpadding="0" style="display: none;">
                    <tr style="height: 19px;">
                        <xsl:if test="($pos mod 2) != 0">
                            <xsl:attribute name="class">impar</xsl:attribute>
                        </xsl:if>
                        <td class="" style="width: 50px; background-color: white !important;">&#160;</td>
                        <td style="text-align: right;"><xsl:value-of select="@nro_pago_detalle" />&#160;</td>
                        <td style="width: 100px;">&#160;<xsl:value-of select="@pago_estados" /></td>
                        <td style="width: 100px;">&#160;<xsl:value-of select="@pago_tipo" /></td>
                        <td style="width: 250px;">&#160;<xsl:value-of select="@banco_orig" /></td>
                        <td style="width: 200px; text-align: right;"><xsl:value-of select="@nro_cuenta_orig" />&#160;</td>
                        <td style="width: 250px;">&#160;<xsl:value-of select="@banco_dest" /></td>
                        <td style="width: 200px; text-align: right;"><xsl:value-of select="@nro_cuenta_dest" />&#160;</td>
                        <td style="width: 100px; text-align: right;">$ <xsl:value-of select="format-number(@importe_pago_det, '#.00')" />&#160;</td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

</xsl:stylesheet>