<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">

    <xsl:include href="..\..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>

    <msxsl:script language="vb" implements-prefix="user">
        <msxsl:assembly name="System.Web"/>
        <msxsl:using namespace="System.Web" />
        <![CDATA[
            Dim nvFW_interOp As Object = HttpContext.current.application.contents("_nvFW_interOp")

            Public function getfiltrosXML() As String
                Page.contents("filtroverOperadores_operador_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador, Login, documento, nro_docu, apellido, nombres, fe_alta, estado</campos><filtro></filtro><orden></orden></select></criterio>")

		        return ""
            End Function

		    Dim a As String = getfiltrosXML()
		]]>
    </msxsl:script>
    <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
    ]]>    
    </msxsl:script>

	<xsl:template match="/">
	<html>
		<head>
		    <!--<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>-->
			<title>HTML verPerfiles asociados operadores</title>
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

            <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
            <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
            <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
            <script language="javascript" type="text/javascript">
                var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                campos_head.recordcount = '<xsl:value-of select="xml/params/@recordcount"/>'
                campos_head.PageCount = '<xsl:value-of select="xml/params/@PageCount"/>'
                campos_head.PageSize = '<xsl:value-of select="xml/params/@PageSize"/>'
                campos_head.AbsolutePage = '<xsl:value-of select="xml/params/@AbsolutePage"/>'
                
                if (mantener_origen == '0')
                    campos_head.nvFW = parent.nvFW          
            </script>
            <script language="javascript" type="text/javascript">
            <xsl:comment>
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
			            var tbCabe_height     = $('tbCabe').getHeight()
		                var div_pag_height    = $('div_pag').getHeight()
                        var divMenuABM_height = $('divMenuABM').getHeight()

			            $('divRow').setStyle({ height: body_height - divMenuABM_height - tbCabe_height - div_pag_height - dif + 'px' })
			        }
			        catch(e) {}
              
                    try {
                        campos_head.resize("tbCabe", "tbRow")
                    }
                    catch(e) {}
                }

			    function nodo_onclick(tipo_operador)
				{ 
				    var div = $('trOperadores' + tipo_operador)
					var img = $('img' + tipo_operador)

                    if (div.style.display == 'none') {
					    img.src = '/fw/image/security/menos.gif'
						div.show()
                        exportar_plantilla(tipo_operador)
					}
					else {
					    img.src = '/fw/image/security/mas.gif'
						div.hide()
					}

					window_onresize()
		        }

	            function exportar_plantilla(tipo_operador)
			    {
                    var filtroWhere = "<criterio><select><campos></campos><filtro><tipo_operador type='igual'>"+ tipo_operador +"</tipo_operador>"+ parent.cadena_filtro + "</filtro><orden></orden></select></criterio>"
                    var path_xsl = "\\report\\security\\FW_Operadores_Perfiles\\HTML_verOperadores_asociados.xsl"

                    nvFW.exportarReporte({
                          filtroXML: parent.nvFW.pageContents.filtroverOperadores_operador_tipo
                        , filtroWhere: filtroWhere
                        , path_xsl: path_xsl
                        , formTarget: 'iframeOperadores' + tipo_operador
                        , nvFW_mantener_origen: true
                        , id_exp_origen: 0
                        , bloq_contenedor: 'iframeOperadores' + tipo_operador
                        , cls_contenedor: 'iframeOperadores' + tipo_operador
                        , cls_contenedor_msg: ' '
                        , bloq_msg: 'Cargando...'
                    })
		        }
            ]]>
            </xsl:comment>
            </script>
		</head>
        <body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
		    <div id="divMenuABM"></div>
            <script type="text/javascript" language="javascript">
            <xsl:comment>
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
            </xsl:comment>
            </script>

            <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe">
                <tr class="tbLabel">
                    <td style="width:3%;text-align:center">&#160;-&#160;</td>
                    <td nowrap='nowrap' style='text-align:left'>
                        <script type='text/javascript'>campos_head.agregar('(Nro. Perfil) ', true, 'tipo_operador'); campos_head.agregar('Perfil', true, 'tipo_operador_desc')</script>
                    </td>
                    <td style='width:10% !Important'>&#160;&#160;</td>
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

            <script type="text/javascript">campos_head.resize("tbCabe", "tbRow")</script>
	    </body>
	</html>
    </xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <xsl:variable name="tipo_operador" select="@tipo_operador"></xsl:variable>
        <xsl:variable name="operador" select="@operador"></xsl:variable>
        <xsl:variable name="anteriores" select="count(/xml/rs:data/z:row[@tipo_operador = $tipo_operador and $operador > @operador ])"/>

        <xsl:if test="$anteriores = 0">
            <tr>
                <td style='text-align: center; width: 5%;'>
			  	    <img src='/fw/image/security/mas.gif' border='0' align='absmiddle' hspace='1' id='img{$tipo_operador}' onclick='nodo_onclick("{$tipo_operador}")' />
			    </td>
                <td style="text-align:left" title="({@tipo_operador}) {@tipo_operador_desc}">
                    <!--<img onclick="parent.abm_perfil('{@tipo_operador}', '{@tipo_operador_desc}')" src="/FW/image/icons/editar.png" style="cursor: pointer;" title="Editar Perfil" />-->
                    &#160;(<xsl:value-of select="@tipo_operador" />) <xsl:value-of select="@tipo_operador_desc" />
                </td>
                <td style='width:10%;text-align:center'>
                    <img onclick='parent.permiso_mostrar("arbol", "{@tipo_operador}")' src='/FW/image/security/permiso.png' style='cursor: pointer; border: none;' title='Ver Editar de Permisos' />
                    &#160;
                    <img onclick='parent.imprimir_perfil({@tipo_operador})' src='/FW/image/security/imprimir.png' style='cursor: pointer; border: none;' title='Imprimer Perfil' />
                </td>
            </tr>
            <tr id='trOperadores{$tipo_operador}' style='display: none;'>
                <td style="width: 3%;">&#160;</td>
                <td colspan="2">
                    <iframe id="iframeOperadores{$tipo_operador}" name="iframeOperadores{$tipo_operador}" style="width: 100%; overflow-y: auto; height: 180px; border: none;"></iframe>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>