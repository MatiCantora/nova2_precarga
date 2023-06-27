<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo">

    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

    <xsl:template match="/">
        <html>
        <head>
            <title>Buscar Pizarras</title>
            <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />

            <style type="text/css">
              .btn-seleccionar {
                display: inline-block;
                width: 16px;
                height: 16px;
                background-image: url('/FW/image/icons/seleccionado_no.png');
                background-repeat: no-repeat;
                cursor: pointer;
              }
              .btn-seleccionar:hover {
                background-image: url('/FW/image/icons/seleccionado_si.png');
              }
            </style>

            <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
            <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
            
            <script language="javascript" type="text/javascript">
                var mantener_origen       = '<xsl:value-of select="xml/mantener_origen"/>'
                campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
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
            <script type="text/javascript" language="javascript">
                <![CDATA[
                var $body
                var $tbCabecera
                var $divDetalles
                var $tbDetalles
                var $tdScroll


                function window_onresize()
                {
                    try
                    {
                        var altura = $body.getHeight() - $tbCabecera.getHeight()
                        $divDetalles.style.height = altura + 'px'
                        $tbDetalles.getHeight() > altura ? $tdScroll.show() : $tdScroll.hide()
                    }
                    catch(e) {}
                }
                
                
                function window_onload()
                {
                    $body        = $$('body')[0]
                    $tbCabecera  = $('tbCabecera')
                    $divDetalles = $('divDetalles')
                    $tbDetalles  = $('tbDetalles')
                    $tdScroll    = $('tdScroll')
                    
                    window_onresize()
                }
                
                
                function seleccionar(event, id_pizarra)
                {
                    window.parent.seleccionar(event, id_pizarra);
                }
                ]]>
            </script>
        </head>
        <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background: #FFFFFF">
            <table class="tb1" id="tbCabecera">
                <tr class="tbLabel">
                    <td style='width: 75px; text-align: center'>-</td>
                    <td style='width: 150px; text-align: center'><script>campos_head.agregar('Nro', 'true', 'nro_calc_pizarra')</script></td>
                    <td style='text-align: center'><script>campos_head.agregar('Pizarra', 'true', 'calc_pizarra')</script></td>
                    <td style='width: 150px; text-align: center'>Prefijo</td>
                    <td style='width: 150px; text-align: center'>Posfijo</td>
                    <td style='width: 200px; text-align: center'><script>campos_head.agregar('Tipo dato', 'true', 'dato_tipo')</script></td>
                    <td style='width: 15px; display: none' id='tdScroll'>&#160;</td>
                </tr>    
            </table>

            <div id='divDetalles' style='width: 100%; height: 400px; overflow: auto;'>
                <table class="tb1 highlightOdd highlightTROver" id="tbDetalles">
                    <xsl:apply-templates select="xml/rs:data/z:row" mode="row1" />
	            </table>
            </div>
        </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row"  mode="row1">
        <tr>
          <td style="text-align: center; width: 75px;">
            <span class="btn-seleccionar" title="Seleccionar pizarra {@nro_calc_pizarra}" onclick="seleccionar(event, '{@nro_calc_pizarra}');"></span>
	        </td>
          <td style='width: 150px; text-align: center'><xsl:value-of select="@nro_calc_pizarra" /></td>
          <td>&#160;<xsl:value-of select="@calc_pizarra"/></td>
          <td style='width: 150px; text-align: center'><xsl:value-of select="@prefijo" /></td>
          <td style='width: 150px; text-align: center'><xsl:value-of select="@posfijo" /></td>
          <td style='width: 200px; text-align: center'><xsl:value-of select="@dato_tipo" /></td>
        </tr>
    </xsl:template>

</xsl:stylesheet>