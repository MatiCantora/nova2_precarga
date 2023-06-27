<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Ver Comentarios</title>
        <!--#include virtual="/fw/scripts/pvUtiles.asp"-->
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

        <link href="/fw/css/window_themes/default.css" rel="stylesheet" type="text/css" />
        <link href="/fw/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

        <script type="text/javascript" src="/fw/script/prototype.js"></script>
        <script type="text/javascript" src="/fw/script/window.js"></script>
        <script type="text/javascript" src="/fw/script/effects.js"></script>

        <script type="text/javascript" src="/fw/script/acciones.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/imagenes_icons.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/mnuSvr.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/DMOffLine.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/btnSvr.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/rsXML.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tXML.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/utiles.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tSesion.js" language="JavaScript"></script>
        <script language="javascript" type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          if (mantener_origen == '0')
          campos_head.nvFW = window.top.nvFW
        </script>

                <style type="text/css">
                    .tr_cel TD
                    {
                    background-color: white !Important
                    }
                    .tr_cel_click TD
                    {
                    background-color: #BDD3EF !Important,
                    color : #0000A0 !Important
                    }
                </style>
                <script>
					<xsl:comment>
                        var visible = 'siempre'
                        var nro_entidad = '<xsl:value-of select="xml/parametros/nro_entidad"/>'
                        var nro_com_id_tipo = '<xsl:value-of select="xml/parametros/nro_com_id_tipo"/>'
                        var id_tipo = '<xsl:value-of select="xml/parametros/id_tipo"/>'
                        var nro_com_grupo = '<xsl:value-of select="xml/parametros/nro_com_grupo"/>'

                        <![CDATA[										
						
						//Botones
                        var vButtonItems = {};
                        vButtonItems[0] = {};
                        vButtonItems[0]["nombre"] = "Nuevo";
                        vButtonItems[0]["etiqueta"] = "Nuevo";
                        vButtonItems[0]["imagen"] = "nueva";
                        vButtonItems[0]["onclick"] = "return ABMRegistro(nro_entidad, id_tipo,nro_com_id_tipo, 0, 0)";

                        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
                        vListButtons.imagenes = Imagenes    
						
						function Mostrar_Registro_grupo(nro_com_grupo_nuevo)
							{
							
							nro_com_grupo = nro_com_grupo_nuevo
							var e
							try
								{
							 	 var strFiltro = ''
    							
    							 	 
							 	 strFiltro = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>"
							     strFiltro += "<id_tipo type='igual'>" + id_tipo + "</id_tipo>"
				                 //strFiltro += "<nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo>"
				                 strFiltro += "<nro_com_grupo type='igual'>" + nro_com_grupo + "</nro_com_grupo>"
							     
                                  nvFW.exportarReporte({
                                                         filtroXML: "<criterio><select vista='verCom_registro'><campos>*</campos><orden>com_prioridad desc, fecha</orden><filtro>" + strFiltro + "</filtro></select></criterio>",
                                                         path_xsl: "report/verCom_registro/verRegistro_base_detalle.xsl",
                                                         formTarget: 'iframe_detalle',
                                                         bloq_contenedor: $('iframe_detalle'),
                                                         cls_contenedor: 'iframe_detalle',
                                                         cls_contenedor_msg: '&nbsp;'
                                                       }) 
								}
							catch(e){}	
							}
							
                         function onmove_sel(indice)
			               {
					        $('tr_ver'+indice).addClassName('tr_cel')
					       }
            					
					     function onout_sel(indice)
					       {
					         $('tr_ver'+indice).removeClassName('tr_cel')
					       }
					   
                      function ABMRegistro(nro_entidad,id_tipo,nro_com_id_tipo,nro_registro, nro_com_tipo)
			            {					
                          var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                          
                          window.top.win = w.createWindow({ className: 'alphacube',
                                                            url: 'ABMRegistro.asp?nro_entidad=' + nro_entidad + '&id_tipo=' + id_tipo + '&nro_com_id_tipo=' + nro_com_id_tipo + '&nro_registro=' + nro_registro + '&nro_com_tipo=' + nro_com_tipo,
                                                            title: '<b>Alta de Comentario</b>',
                                                            minimizable: false,
                                                            maximizable: false,
                                                            draggable: false,
                                                            width: 670,
                                                            height: 450,
                                                            resizable: true,
                                                            onClose: Mostrarcomentarios_return
                                                          });
                          window.top.win.showCenter(true)
			            }		
            
                      function Mostrarcomentarios_return()
                      {
                      if (window.top.win.returnValue != undefined) 
                           Mostrar_Registro_grupo(nro_com_grupo)
                      }
            					
		                function window_onload()
		                {						
		                  // mostramos los botones creados
                          vListButtons.MostrarListButton()
			             // window_onResize();
			            
                										  
			              if (nro_entidad == '' && parent.entidad != undefined)
			                  nro_entidad = parent.nro_entidad
			              
			              if(parent.$('nro_ref_get') != null)
			                  if (id_tipo == '' && parent.$('nro_ref_get').value > 0)
			                      id_tipo = parent.$('nro_ref_get').value
			                      
			            Mostrar_Registro_grupo(nro_com_grupo)
		                }
						
			            function window_onResize()
			            {
				            try{
				                 var dif = Prototype.Browser.IE ? 5 : 2
					             body_height = $$('body')[0].getHeight()
					             trTitulo_height = $('trTitulo').getHeight()
					             alto = body_height - trTitulo_height - dif - 5
					             $('iframe_detalle').setStyle({height : alto})
					            }
					            catch(e){}
			            }
						
			            function get_com_grupo()
						  {
						   var URL = "/fw/reportViewer/exportarReporte.asp"
						   filtroXML = "<criterio><select vista='verCom_id_tipo_grupos'><campos>nro_com_grupo, com_grupo</campos><orden>com_grupo desc</orden><filtro><nro_com_id_tipo type='igual'>" + nro_com_id_tipo + "</nro_com_id_tipo></filtro><grupo></grupo></select></criterio>"
						   path_xsl = "report/verCom_registro/verRegistro_grupo.xsl"
						   console.log(path_xsl)
						   new Ajax.Updater($('divGrupo'), URL, {method: 'get', 
						                                parameters: {filtroXML: filtroXML, path_xsl: path_xsl},
						                                onComplete: function(win)
						                                       {
						                                       Mostrar_Registro_grupo(onclick_nro_com_grupo)
						                                       formatear_grupo_link(nro_com_grupo) // le da formato al grupo seleccionado
						                                       }
						                                }); 
						  
						  }
						  
						function formatear_grupo_link(nro_com_grupo)
						{
						
						  $('link_'+ onclick_nro_com_grupo).style.fontStyle = ''
						  $('link_'+ onclick_nro_com_grupo).style.fontWeight = ''
						  
						  $('link_'+ nro_com_grupo).style.fontStyle = 'italic'
						  $('link_'+ nro_com_grupo).style.fontWeight = 'bold'
						  
						}
						
						function EncuestaMostrar(nro_entidad,id_encuesta,nro_registro)
						    {
						    var win_encuesta = window.top.nvFW.createWindow({
								   className: 'alphacube',
								   title: '<b>Encuesta</b>',
                                   minimizable: true,
                                   maximizable: true,
                                   draggable: true,
                                   width: 800,
                                   height: 400,
                                   resizable: false,
                                   onClose: EncuestaMostrar_return
                                  });
						    win_encuesta.options.userData = { res: false }
						    win_encuesta.setURL('../meridiano/Encuesta_det.asp?nro_entidad=' + nro_entidad + '&id_encuesta=' + id_encuesta + '&nro_registro=' + nro_registro) 
						    win_encuesta.showCenter(true)                             
						    }
						
	   ]]>
		</xsl:comment>
	</script>
</head>
<body onload="return window_onload()" style="width:100%;height:100%;overflow:hidden">
	<xsl:variable name="nro_com_grupo" select="xml/rs:data/z:row/@nro_com_grupo" />
	<xsl:variable name="nro_entidad" select="xml/rs:data/z:row/@nro_entidad" />
    <table style="width:100%;font-weight:bold">
        <tr id="trTitulo" class="tbLabel" >
            <td colspan="2">
                Registro de comentarios
            </td>
        </tr>
    </table>
	<table class="tb1" style="height:100% !Important">
		<tr>
			<td style="width:85%">
                    <iframe name="iframe_detalle" style="width:100%;height:100%;overflow:hidden" frameborder="0"></iframe>
			</td>
            <td id="menu_right" style="vertical-align:top">
				<table class="tb2">
				  <tr class="tbLabel0">
					   <td>Grupos</td>
				   </tr>
				   <tr>
				     <td style="width:100% !Important">
				       <div id="divGrupo" style="width:100% !Important"></div>
                       <script language="javascript" type="text/javascript">
                           get_com_grupo()
                       </script>
					 </td>
                    </tr>
				  <tr class="tbLabel0">
			 		<td>Comentario</td>
				  </tr>
                  <tr>
                    <td>&#160;</td>
                  </tr>
				  <tr>
					<td style="width:100% !Important">
                        <div id="divNuevo" style="width:100% !Important"></div>
					</td>
				</tr>
			   </table>								
		    </td>
		</tr>
   </table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>