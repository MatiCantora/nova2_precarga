<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

    <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl" />
    <xsl:output method="html" version="5" encoding="ISO-8859-1" omit-xml-declaration="yes" />

    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
        ]]>    
    </msxsl:script>

	<xsl:template match="/">
		<html>
		<head>
        <!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>-->
        <title>HTML verOperadores lineal</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

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
        <![CDATA[
            function window_onload()
		    {
		 	    window_onresize()
		    }

			var dif = Prototype.Browser.IE ? 5 : 2

            function window_onresize()
            {
                try {
			        var body_height       = $$('body')[0].getHeight()
			        var divMenuABM_height = $('divMenuABM').getHeight()
                    var tbCabe_height     = $('tbCabe').getHeight()
		            var div_pag_height    = $('div_pag').getHeight()

                    $('divRow').setStyle({ height: body_height - divMenuABM_height - tbCabe_height - div_pag_height - dif + 'px' })
                    
                    showTdScroll($('tbRow').getHeight() > $('divRow').getHeight())
			    }
			    catch(e) {}
            }
            
            function showTdScroll(show)
            {
                show ? $('tdScroll').show() : $('tdScroll').hide()
            }
        ]]>
        </script>
	</head>
    <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
        <div id="divMenuABM"></div>
        <script type="text/javascript" language="javascript">
        <![CDATA[
            var DocumentMNG = new tDMOffLine;
            var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
            
            Menus["vMenuABM"] = vMenuABM
            Menus["vMenuABM"].alineacion = 'centro';
            Menus["vMenuABM"].estilo = 'A';
            
            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>imprimir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parent.buscar('imprimir')</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parent.buscar('exportar')</Codigo></Ejecutar></Acciones></MenuItem>")
            
            vMenuABM.loadImage("imprimir",'/FW/image/security/imprimir.png')
            vMenuABM.loadImage("excel",'/FW/image/security/excel.png')
            
            vMenuABM.MostrarMenu()
        ]]>
        </script>     

        <table class="tb1" id="tbCabe">
            <tr class="tbLabel">
                <td style='width: 5%; text-align: center;'>-</td>
                <td style='width: 25%;'>
                    <script>campos_head.agregar('(Operador) - ', true, 'operador'); campos_head.agregar('Login', true, 'Login')</script>
                </td>
                <td style='width: 25%;'>
                    <script>campos_head.agregar('Apellido', true, 'apellido')</script>
                </td>
                <td>
                    <script>campos_head.agregar('Nombres', true, 'nombre')</script>
                </td>
                <td style='width: 20%;'>
                    <script>campos_head.agregar('Nro. Documento', true, 'nro_docu')</script>
                </td>
                <td id='tdScroll' style='display: none; width: 14px !important;'>&#160;</td>
            </tr>
        </table>

        <div style="width: 100%; overflow: auto;" id="divRow">
            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                <xsl:apply-templates select="xml/rs:data/z:row" />
            </table>
        </div>

        <div id="div_pag" class="divPages">
            <script type="text/javascript">document.write(campos_head.paginas_getHTML())</script>
        </div>
	</body>
</html>
</xsl:template>

<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="operador" select="@operador" />
    <tr>
        <td style='width: 5%; text-align: center;'>
            <img onclick='parent.abm_operadores("{@Login}")' src='/FW/image/icons/editar.png' style='cursor: pointer;' title='Editar Operador' />
        </td>
        <td style='width: 25%;'>(<xsl:value-of select="$operador" />) <xsl:value-of select="@Login" /></td>
        <td style='width: 25%;'>
            <xsl:value-of select="@apellido"/> 
        </td>
        <td>
            <xsl:value-of select="@nombres"/>
        </td>
        <td style="width: 20%;">
            <xsl:value-of select="@documento"/> - <xsl:value-of select="@nro_docu"/>
        </td>
    </tr>
</xsl:template>
</xsl:stylesheet>