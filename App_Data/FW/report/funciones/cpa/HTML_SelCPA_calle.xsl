<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\xsl_includes\js_formato.xsl"  />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		
		function mostrar_descripcion(descripcion)
			{
			var resultado = ''
			var size = descripcion.length
			if (size > 25){
				resultado = descripcion.substring(0,25) + '...'
			}
			else{
				resultado = descripcion
			}
			
			return resultado.toString()
			
			}
			

	function armar_descripcion(nombrecalle,barrio,nombrealt,tipocalle){
		
			var descripcion = ''
			if(nombrecalle != 'TAB')
				descripcion = descripcion + nombrecalle
			if(nombrecalle != 'TAB' && barrio != 'TAB' && barrio != '')
				descripcion = descripcion + ' - '
			if(barrio != 'TAB' && barrio != '')
				descripcion = descripcion + 'Barrio: ' + barrio.toString()
			if(nombrecalle == 'TAB' && barrio == 'TAB')
				descripcion = descripcion + nombrealt
			
			var size = descripcion.length	
			
			if(tipocalle != ''){
				descripcion = descripcion + ' (' + tipocalle + ')'
			}
			else if (size > 22){
					descripcion = descripcion.substring(0,22) + '...'
				}
			
			return descripcion.toString()
			
		}	

		
		]]>
	</msxsl:script>

    <xsl:template match="/">
        <html>
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

                        <title>Buscar Calle</title>
                        <!--#include virtual="../../meridiano/scripts/pvUtiles.asp"-->
                        <link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet"/>
                        <link href="../../meridiano/css/btnSvr.css" type="text/css" rel="stylesheet" />
                        <link href="../../meridiano/css/mnuSvr.css" type="text/css" rel="stylesheet" />
                        <link href="../../meridiano/css/window_themes/default.css" rel="stylesheet" type="text/css" />
                        <link href="../../meridiano/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

                        <script type="text/javascript" src="../../meridiano/script/prototype.js"></script>
                        <script type="text/javascript" src="../../meridiano/script/window.js"></script>
                        <script type="text/javascript" src="../../meridiano/script/effects.js"></script>

                        <script type="text/javascript" src="../../meridiano/script/acciones.js"></script>
                        <script type="text/javascript" src="../../meridiano/script/imagenes_icons.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/mnuSvr.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/DMOffLine.js"></script>
                        <script type="text/javascript" src="../../meridiano/script/rsXML.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/tXML.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/nvFW.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/tCampo_head.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/tCampo_def.js" language="JavaScript"></script>
                        <script type="text/javascript" src="../../meridiano/script/utiles.js" language="JavaScript"></script>

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

                        
                        function seleccionar_calle(nombrecalle,barrio,nombre_alt,localidad,cod_prov,cod_veraz_prov,codcalle)
                        {
                            parent.selCalle(nombrecalle,barrio,nombre_alt,localidad,cod_prov,cod_veraz_prov,codcalle)
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
                                            <td style='text-align: center; width:4%' nowrap='true'>-</td>
                                            <td style='text-align: center; width:22%' nowrap='true'>
                                                <script>
													campos_head.agregar('Descripcion', true, 'nombrecalle')
												</script>
                                            </td>
											<td style='text-align: center; width:20%' nowrap='true'>
												<script>
													campos_head.agregar('Nombre Alt', true, 'nombrealt')
												</script>
											</td>
											<td style='text-align: center; width:14%' nowrap='true'>
												<script>
													campos_head.agregar('Tipo', true, 'tipocalle')
												</script>
											</td>
                                            <td style='text-align: center; width:20%'>
                                                <script>
                                                    campos_head.agregar('Localidad', true, 'localidad')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:20%'>
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
            <td style='text-align: center; width:4%' nowrap='true'>
                <img title="Seleccionar Calle" src="../../meridiano/image/icons/agregar_cargo.png" style="cursor:pointer">
                <xsl:attribute name="onclick">seleccionar_calle('<xsl:value-of select='@nombrecalle'/>','<xsl:value-of select='@barrio'/>','<xsl:value-of select='@nombrealt'/>','<xsl:value-of select='@localidad'/>','<xsl:value-of select='@cod_prov'/>','<xsl:value-of select="@codprov"/>','<xsl:value-of select="@codcalle"/>')</xsl:attribute>
                </img>
            </td>
            <td style='text-align: left; width:22%'>
				<xsl:attribute name='title'>
					<xsl:value-of select="foo:armar_descripcion(string(@nombrecalle),string(@barrio),string(@nombrealt),string(@tipocalle))" />
				</xsl:attribute>
				<xsl:value-of select="foo:armar_descripcion(string(@nombrecalle),string(@barrio),string(@nombrealt),'')"/>
				<!--<xsl:choose>
					<xsl:when test="@nombrecalle != 'TAB'">
						<xsl:attribute name='title'><xsl:value-of select="@nombrecalle" /></xsl:attribute>
						<xsl:value-of select="foo:mostrar_descripcion(string(@nombrecalle))"/>
					</xsl:when>
					<xsl:when test="@nombrecalle = 'TAB' and @barrio != 'TAB' ">
						<xsl:attribute name='title'><xsl:value-of select="@barrio" /></xsl:attribute>
						Barrio: <xsl:value-of select="foo:mostrar_descripcion(string(@barrio))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name='title'><xsl:value-of select="@nombrealt" /></xsl:attribute>
						<xsl:value-of select="foo:mostrar_descripcion(string(@nombrealt))"/>
					</xsl:otherwise>
				</xsl:choose>-->
            </td>
			<td style='text-align: left; width:20%'>
				<xsl:attribute name='title'><xsl:value-of select="@nombrealt" /></xsl:attribute>
				<xsl:choose>
					<xsl:when test="string-length(@nombrealt) &#62; 19">
						<xsl:value-of select="substring(@nombrealt,1,19)"/>...
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@nombrealt"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='text-align: left; width:14%'>
				<xsl:value-of select="@tipocalle"/>
			</td>
            <td style='text-align: left; width:20%'>
				<xsl:attribute name='title'><xsl:value-of select="@localidad" /> - Partido: <xsl:value-of select="@partido"/></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@localidad) &#62; 20">
                        <xsl:value-of select="substring(@localidad,1,20)"/>...
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@localidad"/></xsl:otherwise>
                </xsl:choose>
            </td>
            <td style='text-align: left; width:20%'>
                <xsl:attribute name='title'><xsl:value-of select="@provincia" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length(@provincia) &#62; 20">
                        <xsl:value-of select="substring(@provincia,1,20)"/>...
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@provincia"/></xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>