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
		    Page.contents("filtro_verCreditos_control_digital_detV1") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos_control_digital_detV1'><campos>nro_archivo,nro_credito,Descripcion,momento,nombre_operador,img_origen,archivo_descripcion,nro_def_archivo,def_archivo,isnull(cant_hojas,0) as cant_hojas,isnull(pag_clasificadas,0) as pag_clasificadas,nro_credito</campos><orden>momento</orden><filtro></filtro></select></criterio>")
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
					
					
					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW
				</script>
                <script type="text/javascript">
                	 var fecha_desde = '<xsl:value-of select="xml/parametros/fecha_desde"/>'
					var fecha_hasta = '<xsl:value-of select="xml/parametros/fecha_hasta"/>'
					var id_control_digital='<xsl:value-of select="xml/parametros/id_control_digital"/>'
					var id_control_contenido='<xsl:value-of select="xml/parametros/id_control_contenido"/>'
					var nro_envio_gral='<xsl:value-of select="xml/parametros/nro_envio_gral"/>'
					var nro_mutual='<xsl:value-of select="xml/parametros/nro_mutual"/>'
					var nro_banco='<xsl:value-of select="xml/parametros/nro_banco"/>'
					<![CDATA[

					function  window_onload()
                          {
                            window_onresize()
                          }
                          
						function window_onresize()
					      {
					       try
					          {
            			      var dif = Prototype.Browser.IE ? 5 : 2
					          var body_height = $$('body')[0].getHeight()
					          var tbCabe_height = $('tbCabe').getHeight()
					          var div_pag_height = $('div_pag').getHeight()
                                     
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})            					     
                              
                              $('tbDetalle').getHeight() - $('div_lst_creditos').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
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
											
					function mostrar_creditos(e,nro_credito,link)
						{
                            var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
                            var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'
                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'
                            
                            if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                            $(link).href = path;
                            else {if (e.altKey){ //con la tecla "Alt", abre una ventana emergente
									window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)                                   
									}
									else{ 
										if (e.shiftKey)
										{ //con la tecla "Shift", abre una nueva ventana _blank
										$(link).target = '_blank'
										$(link).href = path;                                 
										}
										else
										{ 
										parent.mostrar_creditos(nro_credito)
										}                            
									}
								}
					     }
						 
				function abrir_archivos(nro_credito)
						 {
						 parent.abrir_archivos(nro_credito)
						 }



				function nodo_onclick(nro_credito)
				{ 
							var tb = $('divPG_reg' + nro_credito)
							var img = $('img' + nro_credito)

							if (tb && img)
							{
							    if (tb.style.display == 'none')
								{
								img.src = '../image/icons/menos.gif'
								tb.style.display = ''
								//mostrar_archivos(nro_credito) 
								}
									else 
								{
								img.src = '../image/icons/mas.gif'
								tb.style.display = 'none'
								}
							}
                }
						
						function Mostrar_Archivos(id_row,nro_operador,nro_img_origen,nro_sucursal)
						{
                    
								var tb = $('trDetalle' + id_row)
								var img = $('img_detalle_' + id_row) 
								var ifr = $('if_' + id_row) 
								var nombre = 'if_' + id_row
								var filtroXML = ''
								if (nro_operador != '')
									filtroXML += "<operador type='igual'>" + nro_operador + "</operador>"
								
									if (nro_sucursal != '')
									filtroXML += "<nro_sucursal type='igual'>" + nro_sucursal + "</nro_sucursal>"

								if (nro_img_origen != '')
									filtroXML += "<nro_img_origen type='igual'>" + nro_img_origen + "</nro_img_origen>"
								if (fecha_desde != '')
									filtroXML += "<momento type='mas'>convert(datetime,'" + fecha_desde + "',103)</momento>"
								if (fecha_hasta != '')
									filtroXML += "<momento type='menor'>convert(datetime,'" + fecha_hasta + "',103)+1</momento>"						

								if(id_control_digital !='')	
								filtroXML += "<id_control_digital type='igual'>" + id_control_digital + "</id_control_digital>"						

								if(id_control_contenido !='')	
								filtroXML += "<id_control_contenido type='igual'>" + id_control_contenido + "</id_control_contenido>"						

								if(nro_envio_gral !='')	
								filtroXML += "<nro_envio_gral type='in'>" + nro_envio_gral + "</nro_envio_gral>"						
															

								if(nro_mutual !='')	
								filtroXML += "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"						

								if(nro_banco !='')	
								filtroXML += "<nro_banco type='igual'>" + nro_banco + "</nro_banco>"						

									filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_detV1
								if (tb.style.display == 'none')
								{
								tb.show()
								img.src = '../image/icons/menos.jpg'
								nvFW.exportarReporte({
			                          filtroXML: filtroXML,
			                          path_xsl: 'report\\verCreditos_control_digital\\HTML_creditos_control_digital_detV1.xsl',
			                          formTarget: nombre,
                                filtroWhere: "<criterio><select><filtro>"  + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + filtroXML  + "</filtro></select></criterio>"
			                          nvFW_mantener_origen: true,
			                          bloq_contenedor: ifr,
			                          cls_contenedor: nombre
			                      })										
								}
								else
								{					
								tb.hide()
								img.src = '../image/icons/mas.jpg'
								}
						}



						function MostrarDetalle(nro_credito)
						{	
                    
							var tb = $('trDetalle' + nro_credito)
							var img = $('img_detalle_' + nro_credito) 
							
					
					
								if (tb.style.display == 'none')
								{
								tb.show()
								img.src = '../image/icons/menos.jpg'																
								}
								else
								{					
								tb.hide()
								img.src = '../image/icons/mas.jpg'
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
							<td style='width:5%'>-</td>
							<td style='width:30%'>
                               <script type="text/javascript">
									campos_head.agregar('Operador', 'true', 'nombre_operador')
                                </script>
                               
							</td>
							<td style='width:35%'>
                                <script type="text/javascript">
                                	campos_head.agregar('Sucursal', 'false', 'sucursal')							
								</script>								
							</td>
							<td style='width:15%'>
                                <script type="text/javascript">
									campos_head.agregar('Origen', 'false', 'img_origen')		
                                </script>
                                
							</td>
							<td style='width:10%'>
								Totales
							</td>
							<td style="width:15px">&#160;</td>
						</tr>						
					</table>
					<div style="width:100%; height:370px ;overflow-y:auto;" id="div_lst_creditos">						
						<table class="tb1 highlightEven highlightTROver" id="tbDetalle">
						<xsl:apply-templates  select="xml/rs:data/z:row" />
						</table>
					</div>
                    <div id="div_pag" class="divPages" style="width:1500px">
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
        <xsl:variable name="nro_sucursal" select="@nro_sucursal"/>		
        <xsl:variable name="nro_operador" select="@operador"/>		
        <xsl:variable name="operador_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@nombre_operador"/>		
        <xsl:variable name="nro_img_origen" select="@nro_img_origen"/>		
        <xsl:variable name="nro_operador_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@operador"/>
		
		<xsl:if  test="$nro_operador_ant != $nro_operador">
			<xsl:variable name="cantidad_archivos" select="sum(//xml/rs:data/z:row[@operador = $nro_operador_ant]/@nro_archivos)"/>
					<tr>
			 			<td></td>
			 			<td colspan="3" style='width:75%;text-align:right;font-weight: bold;'>Total operador <xsl:value-of select="$operador_ant"/> </td>
			 			<td style='width:15%;font-weight: bold'><xsl:value-of select="$cantidad_archivos" /> archivos</td>
			 			<td style='width:15px !Important'>
					  	<xsl:attribute name='id'>tdScroll<xsl:value-of select="@id_row"/></xsl:attribute>&#160;&#160;
				  		</td>
			 		</tr>
		</xsl:if>
			 		<tr>
			          <xsl:attribute name="id">tr_ver<xsl:value-of select="@id_row"/></xsl:attribute>

			          <td style='width:5%; text-align:center; vertical-align:middle'>			
						<a href='#'>
							<xsl:attribute name='onclick'>
									  return Mostrar_Archivos(<xsl:value-of select='@id_row'/>,<xsl:value-of select='@operador'/>,<xsl:value-of select='@nro_img_origen'/>,<xsl:value-of select='@nro_sucursal'/>)
							</xsl:attribute>
							<img border='0' src='../image/icons/mas.jpg'>
								<xsl:attribute name="id">img_detalle_<xsl:value-of  select="@id_row" /></xsl:attribute>
							</img>
						</a>
				  	  </td>
					  <td style='width:30%'>			  
						(<xsl:value-of select="@nombre_operador"/>) - <xsl:value-of select="@strNombreOperador"/>
					  </td>
					  <td style='width:35%'>
						 <xsl:value-of select="@sucursal"/>  (<xsl:value-of select="@localidad"/> - <xsl:value-of select="@provincia"/>)
					  </td>
					  <td style='text-align: center; width:15%'>
						   <xsl:value-of select="@img_origen"/> 
					  </td>
					  <td style='width:10%'>
					  	<xsl:value-of  select="@nro_archivos"/> 	archivos
					  </td>			  	  
					  <td style='width:15px !Important'>
						  <xsl:attribute name='id'>tdScroll<xsl:value-of select="@id_row"/></xsl:attribute>&#160;&#160;
					  </td>
			  		</tr>
				  <tr style="display:none">
				  	<xsl:attribute name="id">trDetalle<xsl:value-of select="@id_row"/></xsl:attribute>
					  	<td colspan="5" style="width:95%">
					  		<iframe style="height:100%;width:100%;border:none; overflow:auto">
							<xsl:attribute name="name">if_<xsl:value-of  select="@id_row" /></xsl:attribute>
							<xsl:attribute name="id">if_<xsl:value-of  select="@id_row" /></xsl:attribute>
							</iframe>



					  </td>
				  	  <td></td>
				  </tr>
				  	<xsl:if  test="position()=last()">
			<xsl:variable name="cantidad_archivos" select="sum(//xml/rs:data/z:row[@operador = $nro_operador]/@nro_archivos)"/>
					<tr>
			 			<td></td>
			 			<td colspan="3" style='width:75%;text-align:right;font-weight: bold;'>Total operador <xsl:value-of select="@nombre_operador"/> </td>
			 			<td style='width:15%;font-weight: bold'><xsl:value-of select="$cantidad_archivos" /> archivos</td>
			 			<td style='width:15px !Important'>
					  	<xsl:attribute name='id'>tdScroll<xsl:value-of select="@id_row"/></xsl:attribute>&#160;&#160;
				  		</td>
			 		</tr>
		</xsl:if>
			 		
	  
	</xsl:template>	
</xsl:stylesheet>