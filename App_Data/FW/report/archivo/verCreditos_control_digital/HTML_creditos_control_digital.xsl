<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">
  
    <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
  
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
  
  
    <msxsl:script language="vb" implements-prefix="vbuser">
        <![CDATA[
		Public function generarEncriptados() As String
		    Page.contents("filtro_verArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos'><campos>nro_archivo,nro_credito,Descripcion,momento,nombre_operador,img_origen</campos><orden></orden><filtro></filtro></select></criterio>")
		    return ""
        End Function

		Dim a As String = generarEncriptados()
		]]>
    </msxsl:script>      
  
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Créditos Control Digital</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/FW/script/swfobject.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					var nro_operador = '<xsl:value-of select="xml/parametros/nro_operador"/>'
					var nro_archivo_def_grupo = '<xsl:value-of select="xml/parametros/nro_archivo_def_grupo"/>'
          var nro_img_origen = '<xsl:value-of select="xml/parametros/nro_img_origen"/>'
          var tipo_def_todos = '<xsl:value-of select="xml/parametros/tipo_def_todos"/>'
          var fecha_desde = '<xsl:value-of select="xml/parametros/fecha_desde"/>'
					var fecha_hasta = '<xsl:value-of select="xml/parametros/fecha_hasta"/>'
          
					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW
				</script>
                <script type="text/javascript">
					<![CDATA[ 				
					function window_onload() {
					    window_onresize()
					}

					function window_onresize() {
					    try {
					        var dif = Prototype.Browser.IE ? 5 : 2
					        var body_height = $$('body')[0].getHeight()
					        var tbCabe_height = $('tbCabe').getHeight()
					        var div_pag_height = $('div_pag').getHeight()

					        $('div_lst_creditos').setStyle({
					            height: body_height - tbCabe_height - div_pag_height - dif + 'px'
					        })

					        $('tbDetalle').getHeight() - $('div_lst_creditos').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
					    } catch (e) {}
					}

					function tdScroll_hide_show(show) {
					    var i = 1
					    while (i <= campos_head.recordcount) {
					        if (show && $('tdScroll' + i) != undefined)
					            $('tdScroll' + i).show()

					        if (!show && $('tdScroll' + i) != undefined)
					            $('tdScroll' + i).hide()

					        i++
					    }
					}

					function MostrarDetalle(nro_credito) {
					    var filtro2 = ""

					    if (tipo_def_todos != "")
					        filtro2 = "<nro_archivo_def_tipo type='igual'>" + tipo_def_todos + "</nro_archivo_def_tipo>"

					    var tb = $('tr_' + nro_credito)
					    var img = $('img_detalle_' + nro_credito)
					    var ifr = $('if_' + nro_credito)
					    var nombre = 'if_' + nro_credito
					    var filtroXML = ''
					    if (nro_operador != '')
					        filtroXML += "<operador type='igual'>" + nro_operador + "</operador>"
					    if (nro_archivo_def_grupo != '')
					        filtroXML += "<sql type='sql'>dbo.rm_def_detalle_en_grupo(nro_def_detalle," + nro_archivo_def_grupo + ")=1</sql>"
					    if (nro_img_origen != '')
					        filtroXML += "<nro_img_origen type='igual'>" + nro_img_origen + "</nro_img_origen>"
					    if (fecha_desde != '')
					        filtroXML += "<momento type='mas'>convert(datetime,'" + fecha_desde + "',103)</momento>"
					    if (fecha_hasta != '')
					        filtroXML += "<momento type='menor'>convert(datetime,'" + fecha_hasta + "',103)+1</momento>"
					    if (tb.style.display == 'none') {
					        tb.show()
					        img.src = '../image/icons/menos.gif'
					        nvFW.exportarReporte({
					            filtroXML: nvFW.pageContents.filtro_verArchivos,
					            filtroWhere: "<criterio><select><filtro>" + "<nro_credito type='igual'>" + nro_credito + "</nro_credito>" + filtro2 + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + filtroXML + "</filtro></select></criterio>"
					            path_xsl: 'report\\verCreditos_control_digital\\HTML_creditos_control_digital_det.xsl',
					            formTarget: nombre,
					            nvFW_mantener_origen: true,
					            bloq_contenedor: ifr,
					            cls_contenedor: nombre
					        })
					    } else {
					        tb.hide()
					        img.src = '../image/icons/mas.gif'
					    }
					}

					function Radio_sel(numero) {
					    window.parent.Descuento_Sel(numero)
					}

					function verABM_Descuentos(numero, imputado) {
					    window.parent.btnABM_Descuentos_onclick(numero, imputado)
					}

					function mostrar_creditos(e, nro_credito, link) {
					    var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
					    var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'

					    $(link).style.color = '#848484'
					    $(link).style.textDecoration = 'underline'
					    $(link).style.cursor = 'pointer'

					    if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
					        $(link).href = path;
					    else {
					        if (e.altKey) { //con la tecla "Alt", abre una ventana emergente
					            window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)
					        } else {
					            if (e.shiftKey) { //con la tecla "Shift", abre una nueva ventana _blank
					                $(link).target = '_blank'
					                $(link).href = path;
					            } else {
					                parent.mostrar_creditos(nro_credito)
					            }
					        }
					    }
					}

					function abrir_archivos(e, link, nro_credito, titulo) {
					    titulo = titulo.toUpperCase()
					    var ventana = 0
					    if (e.ctrlKey == true) {
					        ventana = 1
					        $(link).href = '/meridiano/verArchivosTodos.aspx?nro_credito=' + nro_credito + '&ventana=1&titulo=' + titulo
					    }
					    if (e.shiftKey == true) {
					        ventana = 1
					        $(link).target = '_blank'
					        $(link).href = '/meridiano/verArchivosTodos.aspx?nro_credito=' + nro_credito + '&ventana=1&titulo=' + titulo
					    }


					    if (ventana == 0) {
					        win_archivos = window.top.nvFW.createWindow({
					            className: 'alphacube',
					            title: titulo,
					            minimizable: true,
					            maximizable: true,
					            draggable: false,
					            closable: true,
					            width: 800,
					            height: 450,
					            resizable: false
					        });
					        win_archivos.setURL('/meridiano/verArchivosTodos.aspx?nro_credito=' + nro_credito + '&titulo=' + titulo)
					        win_archivos.showCenter(true)
					    }
					}
					
					]]>
				</script>
                <style type="text/css">
                    .tr_cel TD {
                    background-color: #F0FFFF !Important
                    }
                </style>
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto">
				<form name="frm1" id="frm1">
					<table class="tb1" id="tbCabe" >
						<tr class="tbLabel">
							<td style='width:22px'>-</td>
							<td style='width:72px'>
                                <script type="text/javascript">
									campos_head.agregar('Nro', 'true', 'nro_credito')
                                </script>
							</td>
							<td style='width:102px'>
                                <script type="text/javascript">
									campos_head.agregar('Documento', 'false', 'nro_docu')
                                </script>
							</td>
							<td style='width:182px'>
								<script type="text/javascript">
									campos_head.agregar('Nombre', 'false', 'strNombreCompleto')
								</script>
							</td>
							<td style='width:192px'>
                                <script type="text/javascript">
									campos_head.agregar('Banco', 'false', 'banco')
								</script>
							</td>
							<td style='width:192px'>
                                <script type="text/javascript">
									campos_head.agregar('Mutual', 'false', 'mutual')
								</script>
							</td>
							<td style='width:82px'>
								<script type="text/javascript">
									campos_head.agregar('Estado', 'false', 'descripcion')
								</script>
							</td>
							<td style='width:122px'>
                                <script type="text/javascript">
									campos_head.agregar('Sucursal', 'false', 'sucursal')
								</script>
							</td>
							<td style='width: 82px'>Ctrol digital</td>
							<td style='width: 82px'>Ctrol contenido</td>
							<td nowrap='true'>-</td>
							<td style="width:15px">&#160;</td>
						</tr>
					</table>
					<div style="width:100%; height:370px ;overflow-y:auto;" id="div_lst_creditos">						
						<table class="tb1 highlightEven highlightTROver" id="tbDetalle">
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
                    <div id="div_pag" class="divPages">
                        <script type="text/javascript">
                            document.write(campos_head.paginas_getHTML())
                        </script>
                    </div>
					</form>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
	  <tr>
          <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
		  <xsl:choose>
			  <xsl:when test="@id_control_digital = 1">
				  <xsl:attribute name="style">color:blue !Important</xsl:attribute>  
			  </xsl:when>
			  <xsl:when test="@id_control_digital = 3">
				  <xsl:attribute name="style">color:red !Important</xsl:attribute>
			  </xsl:when>
		  </xsl:choose>		   
		  <td style='width:20px; text-align:center; vertical-align:middle'>
			<xsl:if test='@cantidad_archivos > 0'>
				<a href='#'>
					<xsl:attribute name='onclick'>
							  return MostrarDetalle(<xsl:value-of select='@nro_credito'/>)
					</xsl:attribute>
					<img border='0' src='../image/icons/mas.jpg'>
						<xsl:attribute name="id">img_detalle_<xsl:value-of  select="@nro_credito" /></xsl:attribute>
					</img>
				</a>
			</xsl:if>
			<xsl:if test='@cantidad_archivos = 0'>
				<img border='0' src='../image/icons/punto.jpg'>
					<xsl:attribute name="id">img_detalle_<xsl:value-of  select="@nro_credito" /></xsl:attribute>
				</img>
			</xsl:if>		  
		  </td>
		  <td style='text-align: center; width:70px'>
			  <a>
				  <xsl:attribute name="target">_blank</xsl:attribute>
				  <xsl:attribute name="href">../../meridiano/credito_mostrar.aspx?nro_credito=<xsl:value-of select="@nro_credito"/></xsl:attribute>
				  <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
			  </a>
		  </td>
		  <td style='width:100px'>			  
			  <a>
				  <xsl:attribute name="target">_blank</xsl:attribute>
				  <xsl:attribute name="href">../../meridiano/persona_mostrar.aspx?nro_docu=<xsl:value-of select="@nro_docu"/>&amp;tipo_docu=<xsl:value-of select="@tipo_docu"/>&amp;sexo=<xsl:value-of select="@sexo"/>&amp;modal=2</xsl:attribute>
				  <xsl:value-of select='string(@documento)'/> - <xsl:value-of select='string(@nro_docu)'/>
			  </a>
		  </td>
		  <td style='width:180px'>
			  <xsl:attribute name='title'><xsl:value-of select="@strNombreCompleto"/></xsl:attribute>
			  <xsl:choose>
				  <xsl:when test="string-length(@strNombreCompleto) &#62; 25">
					  <xsl:value-of select="substring(@strNombreCompleto,1,25)"/>...
				  </xsl:when>
				  <xsl:otherwise><xsl:value-of select="@strNombreCompleto"/></xsl:otherwise>
			  </xsl:choose>
		  </td>
		  <td style='width:190px'>
			  <xsl:attribute name='title'><xsl:value-of select="@banco"/></xsl:attribute>
			  <xsl:choose>
				  <xsl:when test="string-length(@banco) &#62; 28">
					  <xsl:value-of select="substring(@banco,1,28)"/>...
				  </xsl:when>
				  <xsl:otherwise>
					  <xsl:value-of select="@banco"/>
				  </xsl:otherwise>
			  </xsl:choose>
		  </td>
		  <td style='width:190px'>
			  <xsl:attribute name='title'><xsl:value-of select="@mutual"/></xsl:attribute>
			  <xsl:choose>
				  <xsl:when test="string-length(@mutual) &#62; 28">
					  <xsl:value-of select="substring(@mutual,1,28)"/>...
				  </xsl:when>
				  <xsl:otherwise>
					  <xsl:value-of select="@mutual"/>
				  </xsl:otherwise>
			  </xsl:choose>
		  </td>
		  <td style='width:80px'>
			  <xsl:value-of select="@descripcion" />
		  </td>
		  <td style='width:120px'>
			  <xsl:value-of select="string(@sucursal)" />
		  </td>
		  <td style='text-align: left; width:80px' >
			  <xsl:value-of select="string(@control_digital)" />
		  </td>
		  <td style='text-align: left; width:80px' >
			  <xsl:value-of select="string(@control_contenido)" />
		  </td>
		  <td style='text-align: center' title='Visualizador de archivos'>
			  <xsl:variable name='nombre'><xsl:value-of select="foo:cod_reemplazar(string(@strNombreCompleto))"/></xsl:variable>
			  <xsl:variable name='titulo'>Nro Credito: <xsl:value-of select="@nro_credito"/> - <xsl:value-of select='string(@documento)'/> - <xsl:value-of select='string(@nro_docu)'/> - <xsl:value-of select='string($nombre)'/></xsl:variable>
			  <a href="#">
				  <xsl:attribute name='id'>link_archivos_<xsl:value-of select="@nro_credito"/></xsl:attribute>
				  <xsl:attribute name='style'>cursor:hand</xsl:attribute>	
				  <xsl:attribute name='onclick'>abrir_archivos(event,'link_archivos_<xsl:value-of select="@nro_credito"/>','<xsl:value-of select="@nro_credito"/>','<xsl:value-of select="string($titulo)"/>')</xsl:attribute>
				  <IMG border="0" name="img_1" hspace="1" align="absMiddle" src="../../meridiano/image/icons/pagina_impresion.png" />
			  </a>
		  </td>
		  <td style='width:15px !Important'>
			  <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;
		  </td>
	  </tr>
		<tr style="display:none; height:60px">
			<xsl:attribute name="id">tr_<xsl:value-of  select="@nro_credito" /></xsl:attribute>
			<td></td>
			<td colspan="10">
				<table style="width:100%" cellpadding="0" cellspacing="0">
					<tr>
					<td>
						<iframe style="height:100%;width:100%;border:none; overflow:auto">
							<xsl:attribute name="name">if_<xsl:value-of  select="@nro_credito" /></xsl:attribute>
							<xsl:attribute name="id">if_<xsl:value-of  select="@nro_credito" /></xsl:attribute>
						</iframe>
					</td>
					</tr>
				</table>
			</td>	
		</tr>	
	</xsl:template>
</xsl:stylesheet>