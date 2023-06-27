<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\..\..\voii\report\xsl_includes\js_formato.xsl"/>
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
			debugger
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Seleccionar Entidades</title>
                <!--#include virtual="../../FW/scripts/pvAccesoPagina.asp"-->
                <!--#include virtual="../../FW/scripts/pvUtiles.asp"-->
                <link href="../../FW/css/base.css" type="text/css" rel="stylesheet"/>
                <link href="../../FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
                <link href="../../FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />
                <link href="../../FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />
                <link href="../../FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

                <script type="text/javascript" src="../../FW/script/prototype.js"></script>
                <script type="text/javascript" src="../../FW/script/window.js"></script>
                <script type="text/javascript" src="../../FW/script/effects.js"></script>

                <script type="text/javascript" src="../../FW/script/acciones.js"></script>
                <script type="text/javascript" src="../../FW/script/imagenes_icons.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/mnuSvr.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/DMOffLine.js"></script>
                <script type="text/javascript" src="../../FW/script/rsXML.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/tXML.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/nvFW.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/tCampo_head.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/tCampo_def.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/utiles.js" language="JavaScript"></script>
                <script type="text/javascript" src="../../FW/script/tSesion.js"></script>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW
                </script>
                <script type="text/javascript" language="javascript" >
				<![CDATA[
				    function seleccionar(indice)
	                 {
	                  $('tr_ver'+indice).addClassName('tr_cel')
	                 }
                                 
	                function no_seleccionar(indice)
	                 {
	                  $('tr_ver'+indice).removeClassName('tr_cel')
	                 }
				
                    function Entidad_mostrar(nro_entidad)
					{
						window.parent.Entidad_mostrar(nro_entidad)
					}

                    function window_onresize()
                    {
                    try
                    {

                    var dif = Prototype.Browser.IE ? 5 : 2
					var menu_height = $('divMenuEntidades').getHeight()
                    var body_height = $$('body')[0].getHeight()
                    var tbCabe_height = $('tbCabe').getHeight()
                    var div_pag_height = $('div_pag').getHeight()

                    $('divDetalle').setStyle({height: body_height - menu_height - div_pag_height - tbCabe_height - dif + 'px'})

                    $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
                    }
                    catch(e){}
                    }

                    function tdScroll_hide_show(show)
                    {
                    var i = 1
                    while(i <=  campos_head.recordcount)
                    {
                    if(show &&  $('tdScroll'+ i) != undefined)
                    $('tdScroll'+ i).show()

                    if(!show &&  $('tdScroll'+ i) != undefined)
                    $('tdScroll'+ i).hide()

                    i++
                    }
                    }

                    function  window_onload()
                    {
                    window_onresize()
                    }
					
					var win_abm_entidad
					
					function EntidadABM(nro_entidad)  // Llama la modal para editar las Entidades
					{
						/*if ((permisos_entidades & 2) == 0)          // Controlo si tiene permisos de Modificación Entidad             
						{
							alert ('No Tiene Permisos para realizar esta Acción, <br>Consulte con el Administrador del Sistema');
						}
						else    
						{*/
							win_abm_entidad = window.top.nvFW.createWindow({ className: 'alphacube',
								url: 'Entidad_ABM.asp?nro_entidad=' + nro_entidad,
								title: '<b>ABM Entidades</b>',
								minimizable: false,
								maximizable: false,
								draggable: false,
								width: 900,
								height: 350,
								resizable: false
							})
							win_abm_entidad.showCenter(true)        
						//}
					}	
					
					var win_entidad
    
					/*function Entidad_mostrar(nro_entidad) {
					var titulo = ''
					var rs = new tRS();
					rs.open("<criterio><select vista='pago_entidad'><campos>Razon_social,cuit</campos><orden></orden><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro></select></criterio>")
					if (!rs.eof()) {
						titulo = rs.getdata('Razon_social')
						if (rs.getdata('cuit') != '')
							titulo += ' - ' + rs.getdata('cuit')
					}
					var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
					win_entidad = w.createWindow({ className: 'alphacube',
								url: 'Entidad_mostrar.asp?nro_entidad=' + nro_entidad,
								title: '<b>' + titulo + '</b>',
								minimizable: true,
								maximizable: false,
								draggable: true,
								width: 1100,
								height: 550,
								resizable: false,
								destroyOnClose: true
							});
							win_entidad.options.userData = { retorno: '' }
							win_entidad.showCenter(false) 
					}*/
					
                    ]]>
                </script>
                <style type="text/css">
                    .tr_cel TD {
                    background-color: #F0FFFF !Important
                    }
                </style>					
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				<div id="divMenuEntidades"></div>
				<script type="text/javascript">
					<![CDATA[
					var DocumentMNG = new tDMOffLine;
					var vMenuEntidades = new tMenu('divMenuEntidades', 'vMenuEntidades');
					Menus["vMenuEntidades"] = vMenuEntidades
					Menus["vMenuEntidades"].alineacion = 'centro';
					Menus["vMenuEntidades"].estilo = 'A';
					Menus["vMenuEntidades"].imagenes = Imagenes //Imagenes se declara en pvUtiles
					Menus["vMenuEntidades"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 85%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
					Menus["vMenuEntidades"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva Entidad</Desc><Acciones><Ejecutar Tipo='script'><Codigo>EntidadABM(0)</Codigo></Ejecutar></Acciones></MenuItem>")
					vMenuEntidades.MostrarMenu()
					]]>
				</script>
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
                        <td style='text-align: center; width: 25px'>-</td>
                        <td style='text-align: center; width: 80px'>
                            <script type="text/javascript">
                                campos_head.agregar('Nro', true, 'nro_entidad')
                            </script>
                        </td>
                        <td style='text-align: center; width:350px'>
                            <script type="text/javascript">
                                campos_head.agregar('Razón Social', true, 'Razon_social')
                            </script>
                        </td>
                        <td style='text-align: center; width: 220px'>
                            <script type="text/javascript">
                                campos_head.agregar('Abreviación', true, 'Abreviacion')
                            </script>
                        </td>
						<td style='text-align: center; width: 100px'>
							Cuit
						</td>
                        <td style='text-align: center; width:300px'>Domicilio</td>
                        <td style='text-align: center' nowrap='true'>-</td>
                        <td style="width:20px">&#160;</td>
					</tr>
                </table>
                <div id="divDetalle" style="width:100%;height:80%;overflow:auto">
                    <table class="tb1" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
                </div>
                <div id="div_pag" class="divPages">
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
		  <td style="text-align:center; width:24px">			  
			  <img title="Ver Entidad" style="cursor:hand; cursor:pointer" src='../../FW/image/icons/buscar.png'>
				  <xsl:attribute name='onclick'>
					  return Entidad_mostrar('<xsl:value-of select="@nro_entidad"/>')
				  </xsl:attribute>
			  </img>
		  </td>
		  <td style="text-align:right; width:78px">
			  <xsl:value-of  select="@nro_entidad" />
		  </td>
          <td style="text-align:left; width:348px">
              <xsl:attribute name='title'><xsl:value-of select="@Razon_social"/></xsl:attribute>
              <xsl:choose>
                  <xsl:when test="string-length(@Razon_social) &#62; 55">
                      <xsl:value-of select="substring(@Razon_social,1,55)"/>...
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="@Razon_social"/>
                  </xsl:otherwise>
              </xsl:choose>
		  </td>		  
          <td style="text-align:left; width:218px">
              <xsl:attribute name='title'><xsl:value-of select="@Abreviacion"/></xsl:attribute>
              <xsl:choose>
                  <xsl:when test="string-length(@Abreviacion) &#62; 30">
                      <xsl:value-of select="substring(@Abreviacion,1,30)"/>...
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="@Abreviacion"/>
                  </xsl:otherwise>
              </xsl:choose>
		  </td>
		  <td style="text-align:left; width:98px">
			  <xsl:value-of select="string(@cuit)"/>
		  </td>
          <td style="text-align:left; width:298px">
              <xsl:attribute name='title'><xsl:value-of select="@strDomicilioCompleto"/></xsl:attribute>
              <xsl:choose>
                  <xsl:when test="string-length(@strDomicilioCompleto) &#62; 80">
                      <xsl:value-of select="substring(@strDomicilioCompleto,1,80)"/>...
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="@strDomicilioCompleto"/>
                  </xsl:otherwise>
              </xsl:choose>
		  </td>
          <td style='text-align: center' nowrap='true'>
              <img title="Editar Entidad" style="cursor:hand; cursor:pointer" src='../../FW/image/icons/editar.png'>
                  <xsl:attribute name='onclick'>
					  return EntidadABM('<xsl:value-of select="@nro_entidad"/>')
                  </xsl:attribute>
              </img>
		  </td>
          <td style='width:20px !Important'>
              <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>
              &#160;&#160;
          </td>
      </tr>	  
	</xsl:template>
</xsl:stylesheet>