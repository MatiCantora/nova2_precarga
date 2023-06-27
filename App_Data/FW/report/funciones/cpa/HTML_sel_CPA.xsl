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
		
		
			
		function armar_descripcion(nombrecalle,barrio,referencia,tipocalle){
		
			var descripcion = ''
			if(nombrecalle != 'TAB')
				descripcion = descripcion + nombrecalle
			if(nombrecalle != 'TAB' && barrio != 'TAB' && barrio != '')
				descripcion = descripcion + ' - '
			if(barrio != 'TAB' && barrio != '')
				descripcion = descripcion + 'Barrio: ' + barrio.toString()
			if(referencia != 'TAB')
				descripcion = descripcion + referencia
			
			var size = descripcion.length	
			
			if(tipocalle != ''){
				descripcion = descripcion + ' (' + tipocalle + ')'
			}
			else if (size > 20){
					descripcion = descripcion.substring(0,20) + '...'
				}
			
			return descripcion.toString()
			
		}	
			

		/*function armar_titulo(nombrecalle,barrio,referencia,tipocalle) {
			
			var titulo = ''
			titulo = armar_descripcion(nombrecalle,barrio,referencia)
			titulo = titulo + '(' + tipocalle + ')'
		
			return titulo.toString()
		}*/
		
		
		]]>
	</msxsl:script>
	
    <xsl:template match="/">
        <html>
                    <head>
                       		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				                  <title>CPA</title>
                          <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
                          <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
                          <script type="text/javascript" src="/FW/script/nvFW.js"></script>
                          <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
                          <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                          <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
                          <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
                          <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
                          <script type="text/javascript" src="/FW/script/utiles.js"></script>
                       
                          <script language="javascript" type="text/javascript">
                            campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                            var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                            campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                            campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                            campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                            campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                            campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                            campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                            var fecha_hasta = '<xsl:value-of select="xml/parametros/fecha_hasta"/>'
                            if (mantener_origen == '0')
                            campos_head.nvFW = window.parent.nvFW
                        </script>
                        <script  language="javascript" >
                            <xsl:comment>
                                <![CDATA[ 

                        
                        function seleccionar_CPA(CPA,codprov,provincia,localidad)
                        {
                            parent.selCPA(CPA,codprov,provincia,localidad)
                        }
                                      
						 
						
                    ]]>
                            </xsl:comment>
                        </script>
                 
                    </head>
                    <body style="width:100%;height:100%;overflow:auto">
                        <table width="100%" class="tb1" id="tbCabecera">
                            <tr class="tbLabel">
                                <td>
                                    <table width="100%">
                                        <tr class="tbLabel">
                                            <td style='text-align: center; width:3%' nowrap='true'>-</td>
                                            <td style='text-align: center; width:12%' nowrap='true'>
                                                <script>
                                                    campos_head.agregar('Provincia', true, 'provincia')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:12%'>
                                                <script>
                                                    campos_head.agregar('Partido', true, 'partido')
                                                </script>
                                            </td>
                                            <td style='text-align: center; width:17%'>
                                                <script>
                                                    campos_head.agregar('Localidad', true, 'localidad')
                                                </script>
                                            </td>
											                      <td style='text-align: center; width:17%'>
												                      <script>
													                      campos_head.agregar('Descripción', true, 'nombrecalle')
												                      </script>
											                      </td>
											                      <td style='text-align: center; width:17%'>
												                      <script>
													                      campos_head.agregar('N. Alternativo', true, 'nombrealt')
												                      </script>
											                      </td>
											                      <td style='text-align: center; width:7%'>
												                      <script>
													                      campos_head.agregar('Desde', true, 'desde')
												                      </script>
											                      </td>
											                      <td style='text-align: center; width:7%'>
												                      <script>
													                      campos_head.agregar('Hasta', true, 'hasta')
												                      </script>
											                      </td>
											                      <td style='text-align: center; width:8%'>CPA</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <div style="width:100%; overflow:auto">
                            <table class="tb1 highlightEven highlightTROver layout_fixed" width="100%">
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
            <td style='text-align: center; width:3%' nowrap='true'>
                <img title="Seleccionar Localidad" src="/fw/image/icons/agregar_cargo.png" style="cursor:pointer">
                <xsl:attribute name="onclick">seleccionar_CPA('<xsl:value-of select='@CPA'/>','<xsl:value-of select='@codprov'/>','<xsl:value-of select="@provincia"/>','<xsl:value-of select="@localidad"/>')</xsl:attribute>
                </img>
       </td>
      <td style='text-align: left; width:12%'>
				<xsl:attribute name='title'>
					<xsl:value-of select="@provincia" />
				</xsl:attribute>
      </td>
			<td style='text-align: left; width:12%'>
				<xsl:attribute name='title'><xsl:value-of select="@partido" /></xsl:attribute>
				<xsl:value-of select="@partido"/>
			</td>
      <td style='text-align: left; width:17%'>
                <xsl:attribute name='title'><xsl:value-of select="@localidad" /> - Partido: <xsl:value-of select="@partido"/></xsl:attribute>
                <xsl:value-of select="@localidad"/>
      </td>
			<td style='text-align: left; width:17%'>
				<xsl:attribute name='title'><xsl:value-of select="foo:armar_descripcion(string(@nombrecalle),string(@barrio),string(@referencia),string(@tipocalle))" />
				</xsl:attribute>
				<xsl:value-of select="foo:armar_descripcion(string(@nombrecalle),string(@barrio),string(@referencia),'')"/>
			</td>
			<td style='text-align: left; width:17%'>
				<xsl:attribute name='title'>
					<xsl:value-of select="@nombrealt"/>
				</xsl:attribute>
						<xsl:value-of select="@nombrealt"/>
			</td>
			<td style='text-align: left; width:7%'>
				<xsl:value-of select="@desde"/>
			</td>
			<td style='text-align: left; width:7%'>
				<xsl:value-of select="@hasta"/>
			</td>
			<td style='text-align: left; width:8%'>
				<xsl:value-of select="@CPA"/>
			</td>
						
        </tr>
    </xsl:template>
</xsl:stylesheet>