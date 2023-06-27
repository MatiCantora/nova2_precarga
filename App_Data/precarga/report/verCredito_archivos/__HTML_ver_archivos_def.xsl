
<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:include href="..\..\..\meridiano\report\xsl_includes\js_formato.xsl"  />
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				
				<title>Generado con tienda-html.xsl</title>
				
				
				<!--#include virtual="../meridiano/scripts/pvUtiles.asp"-->
				<!--#include virtual="../meridiano/scripts/pvCampo_def.asp"-->
				<link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet"/>
				<link href="../../meridiano/css/btnSvr.css" type="text/css" rel="stylesheet" />
				<link href="../../meridiano/css/mnuSvr.css" type="text/css" rel="stylesheet" />
				<link href="../../meridiano/css/window_themes/default.css" rel="stylesheet" type="text/css" />
				<link href="../../meridiano/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

				<script type="text/javascript" src="../../meridiano/script/prototype.js"></script>
				<script type="text/javascript" src="../../meridiano/script/window.js"></script>
				<script type="text/javascript" src="../../meridiano/script/effects.js"></script>
				<script type="text/javascript" src="../../meridiano/script/btnSvr.js"></script>
				<script type="text/javascript" src="../../meridiano/script/acciones.js"></script>
				<script type="text/javascript" src="../../meridiano/script/imagenes_icons.js"></script>
				<script type="text/javascript" src="../../meridiano/script/mnuSvr.js" ></script>
				<script type="text/javascript" src="../../meridiano/script/DMOffLine.js"></script>
				<script type="text/javascript" src="../../meridiano/script/rsXML.js"></script>
				<script type="text/javascript" src="../../meridiano/script/tXML.js" ></script>
				<script type="text/javascript" src="../../meridiano/script/nvFW.js" ></script>
				<script type="text/javascript" src="../../meridiano/script/tCampo_head.js"></script>
				<script type="text/javascript" src="../../meridiano/script/tCampo_def.js" ></script>
				<script type="text/javascript" src="../../meridiano/script/utiles.js" ></script>
				<script type="text/javascript" src="../../meridiano/script/tSesion.js"></script>
				<script type="text/javascript" src="../../fw/script/NOSIS.js"></script>
                <script language="javascript" >
				<xsl:comment>
				<xsl:variable name="nro_credito" select="xml/rs:data/z:row/@nro_credito"/>
				var nro_credito = ''
				var pvnro_credito = ''
				<xsl:if test="$nro_credito">
				nro_credito = '<xsl:value-of select="$nro_credito"/>'
				pvnro_credito = '<xsl:value-of select="$nro_credito"/>'
				</xsl:if>
				<xsl:variable name="nro_docu" select="xml/rs:data/z:row/@nro_docu"/>
				var nro_docu = ''
				<xsl:if test="$nro_credito">
				nro_docu = '<xsl:value-of select="$nro_docu"/>'
				</xsl:if>
			    <xsl:variable name="nro_vendedor" select="xml/rs:data/z:row/@nro_vendedor"/>
				var nro_vendedor = ''
				<xsl:if test="$nro_vendedor">
					nro_vendedor = '<xsl:value-of select="$nro_vendedor"/>'
				</xsl:if>
				var nro_archivo
				<xsl:variable name="nro_archivo" select="xml/rs:data/z:row/@nro_archivo"/>
				<xsl:if test="$nro_archivo">
					nro_archivo = '<xsl:value-of select="$nro_archivo"/>'
				</xsl:if>
				var permiso_nosis = '<xsl:value-of select="xml/rs:data/z:row/@permiso_nosis"/>'
				<xsl:variable name="cuit" select="xml/rs:data/z:row/@cuit"/>
                var cuit = ''
                <xsl:if test="$cuit">
                cuit = '<xsl:value-of select="$cuit"/>'
                </xsl:if>
						<![CDATA[
						var estado;
	 					var estados = "ACDEFIJLQSTUW";
						
						 var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

						var archivos = new Array();
						
						/*var vButtonItems = new Array()

						vButtonItems[0] = new Array();
						vButtonItems[0]["nombre"] = "Aceptar";
						vButtonItems[0]["etiqueta"] = "Agregar Archivo";
						vButtonItems[0]["imagen"] = "catalogo";
						vButtonItems[0]["onclick"] = "return ABMDocumentos()";

						var vListButtons = new tListButton(vButtonItems, 'vListButtons')
						vListButtons.imagenes = Imagenes*/
						
						function seleccionar(nro_tipo_pago)
						{
						window.parent.editarPago(nro_tipo_pago)
						}

						function ChequearTodos(chkbox)
						{
						for(i=0; ele=document.all.frm1.elements[i]; i++)
						{
						if (ele.type=='checkbox')
						ele.checked = chkbox.checked
						}
						}						
						
						function ABMDocumentos(filein,readonly,nro_archivo,tipo,permisos_tiene)
						{	

						

						if (!_permiso_editar_archivos){

			              		if (!_solo_pagare && !_solo_edicto_quiebra && !_solo_acta_defuncion && !_solo_carta_documento){
			              		alert("No posee permisos para realizar esta acción")
			              		return;
			              		}
		              		//si a pesar de no tener permisos de edicion, no tiene permisos particulares para este archivo
	            			}


						/*if (!( estados.indexOf(estado) != -1 && (window.top.permisos_web3 & 134217728)!=0 && permisos_tiene == 'True'))
						{ }*/


            			if(permisos_tiene =='False')
	              		{		              			

	              				alert("No posee permisos para realizar esta acción")
		              			return;
	              		}

            			var sp = 0;
            			if ((_solo_pagare  || permisos_tiene=='True' || _solo_edicto_quiebra || _solo_acta_defuncion || _solo_carta_documento)  && !_permiso_editar_archivos) sp =1;
            
						var url = 'abmdocumentos.asp?sp='+sp;
												
						var Parametros = new Array();
						
							Parametros["nro_credito"] = nro_credito
						 	Parametros["filein"] = filein
							if (readonly=='False')
								Parametros["nro_archivo"] = nro_archivo
								
							window.top.documento = window.top.nvFW.createWindow({ className: 'alphacube',
							url: url ,
							title: 'ABM Documento',
							minimizable: false,
							maximizable: false,
							draggable: true,
							width: 700,
							height: 200,
							onShow: function() { window.top.documento.returnValue = Parametros },
							onClose: abmdocumentos_return
						});

						window.top.documento.showCenter(true)
						
						}
						
						
						function abmdocumentos_return(win){ 
							//if (typeof (win.returnValue) == 'string') {
							if(win.returnValue != ''){
								parent.btnMostrarArchivos_onclick()
							}
						}
						
						
						function verDocumentosWin(nro_credito,nro_def_detalle)
						{	
						var Parametros = new Array();
							Parametros["nro_credito"] = nro_credito
							Parametros["nro_def_detalle"] = nro_def_detalle
													 	
							window.top.documento = window.top.nvFW.createWindow({ className: 'alphacube',
							url: 'verDocumentosWin.asp',
							title: 'Documentos',
							minimizable: false,
							maximizable: false,
							draggable: true,
							width: 700,
							height: 200,
							onShow: function() { window.top.documento.returnValue = Parametros },
							onClose: verDocumentosWin_return
						});

						window.top.documento.showCenter(true)
						
						}
						
						
						function verDocumentosWin_return(win){ 
							//
						}
						
						var wineditar
						function editarDocumentosWin(nro_archivo,titulo,nro_registro)
						{	
            if (!_permiso_editar_archivos){
              alert("No posee permisos para modificar archivos en este crédito")
              return;
            }
							  if((window.top.permisos_web & 16)>0)
								{
									var Parametros = new Array();
									Parametros["nro_archivo"] = nro_archivo
									Parametros["nro_registro"] = nro_registro
									Parametros["titulo"] = titulo +" - " + nro_archivo
									
									wineditar = window.top.nvFW.createWindow({ className: 'alphacube',
									url: 'editarDocumentosWin.asp',
									title: 'Archivo',
									minimizable: false,
									maximizable: false,
									draggable: true,
									width: 400,
									height: 90,
									//onShow: function() { window.top.documento.returnValue = Parametros },
									onClose: editarDocumentosWin_return
								});
		                        wineditar.options.userData = { retorno: Parametros}
								wineditar.showCenter(true)

							    }else
								alert("No posee permisos para realizar esta operacion. Consulte con el administrador del sistema")					
												
						}
						
						
						function editarDocumentosWin_return(win){ 
							javascript:cargar_grupo(-1)
						}	
							
						function verParametros(nro_credito, nro_def_detalle){
					            
								var Parametros = new Array();
									Parametros["nro_credito"] = nro_credito
									Parametros["nro_def_detalle"] = nro_def_detalle
									
									wineditar = window.top.nvFW.createWindow({ className: 'alphacube',
									url: 'verparametros_archivos.asp',
									title: 'Parámetros',
									minimizable: false,
									maximizable: false,
									draggable: true,
									width: 400,
									height: 360
									
								});
		                        wineditar.options.userData = { retorno: Parametros}
								wineditar.showCenter(true)
								
						}
						
						
						function window_onload()
						{		
              parametros_editar_archivo()
							window_onResize();
						}
						
						function window_onResize()
						{														
							try
				              {
							  	
												  
            	               var dif = Prototype.Browser.IE ? 5 : 2
							   var body_height = $$('body')[0].getHeight()
				               var tbEncabezado1_height = $('tbEncabezado1').getHeight()
				               var tbEncabezado2_height = $('tbEncabezado2').getHeight()
				               var ajuste =  body_height > 500 ? 250 : 0
							   
				               $('div_archivos').setStyle({height: body_height - tbEncabezado1_height - tbEncabezado2_height - dif - ajuste + 'px'})
            	              // $('div_archivos').getHeight() - $('tbRegistros').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
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
						
						
					
					function Alta_Comentario(nro_docu, tipo_docu, sexo, nro_registro, nro_com_tipo, com_tipo, nro_com_estado, com_estado, fecha, nro_operador, operador, nro_credito)
					{
					  var filtro = ""
					  var Parametros = new Array();
					  Parametros["nro_docu"] = nro_docu
					  Parametros["tipo_docu"] = tipo_docu
					  Parametros["sexo"] = sexo
					  Parametros["nro_credito"] = nro_credito
					  Parametros["nro_registro"] = nro_registro
					  Parametros["com_tipo"] = com_tipo
					  Parametros["nro_registro"] = nro_registro
					  Parametros["nro_com_estado"] = nro_com_estado
					  Parametros["nro_com_tipo"] = nro_com_tipo
					  Parametros["com_estado"] = com_estado
					  Parametros["fecha"] = fecha
					  Parametros["operador"] = operador
					  Parametros["nro_operador"] = nro_operador
					  if (!nro_credito)
						Parametros["nro_credito"] = nro_credito
					  
					   window.top.win = window.top.nvFW.createWindow({
					   className: 'alphacube',
						url: 'ABMRegistro.asp',
						title: '<b>Registro de Comentario</b>',
						minimizable: true,
						maximizable: false,
						draggable: false,
						width: 600,
						height: 480,
						onShow: function() { window.top.win.options.userData = {}; window.top.win.options.userData.Parametros = Parametros },
						onClose: Alta_Comentario_return
					});
					window.top.win.showCenter(true)
					 
					
					}
          
		  
		  function Alta_Comentario_return(win){
		    
		    if (win.options.userData.res) {
				
				parent.btnMostrarRegistros_onclick()
			
			/*
				nvFW.exportarReporte({
				filtroXML: "<criterio><select vista='verDocumentos'><campos>*</campos><filtro><nro_credito type='in'>" + nro_credito + "</nro_credito></filtro></select></criterio>",
					xsl_name: 'HTML_ver_archivos.xsl', 
					formTarget: 'iframe1',
					nvFW_mantener_origen: true,
					bloq_contenedor: $('iframe1'),
					cls_contenedor: 'iframe1'
				})*/
				
			}
		  
		  }
		  
		  
		  function obtener_archivo(nro_credito,nro_def){
			 var strXML = "<criterio><select vista='archivos'><campos>*</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito><nro_def_detalle type='igual'>" + nro_def + "</nro_def_detalle></filtro></select></criterio>"
		     var rs = new tRS();
			 rs.open(strXML)
			 var path = ""
			 if (!rs.eof())
				path = rs.getdata("path")
			 return path
		  }
		  
		  function obtener_grupos(nro_credito){
			 var strXML = "<criterio><select vista='verArchivos_grupos'><campos>distinct nro_archivo_def_grupo, archivo_def_grupo</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito></filtro></select></criterio>"
		     
			 var rs = new tRS();
			 rs.open(strXML)
			 var htmlgrupos = ""
			 while (!rs.eof()){
				htmlgrupos += '<tr><td><a href="javascript:cargar_grupo('+rs.getdata("nro_archivo_def_grupo")+')">'+rs.getdata("archivo_def_grupo")+'</a></td><td><a href="javascript:imprimir_grupo('+rs.getdata("nro_archivo_def_grupo")+')"><img border="0" src="../../meridiano/image/icons/descargar.png" title="Descargar Grupo"></a></td></tr>';			
				rs.movenext()
			}
			htmlgrupos += '<tr><td><a href="javascript:cargar_grupo(-1)">TODOS</a></td><td><a href="javascript:imprimir_grupo(0)"><img border="0" src="../../meridiano/image/icons/descargar.png" title="Descargar Grupo"></a></td></tr>'
			 $('grupos').update(htmlgrupos)
			 return
		  }
		  function cargar_grupo(nro_grupo){
		       
			   var filtro = "<param_grupo type='sql'> dbo.rm_def_detalle_en_grupo(nro_def_detalle,"+nro_grupo+") = 1 </param_grupo>"
			   if (nro_grupo == -1)
			   filtro = ""
			   nvFW.exportarReporte({
                filtroXML: "<criterio><select vista='verCredito_archivos'><campos>*,dbo.rm_credito_count_defs (nro_credito,nro_def_detalle) as cantidad,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene</campos><filtro><nro_credito type='in'>" + nro_credito + "</nro_credito>"+filtro+"<NOT><archivo_descripcion type='isnull' /></NOT></filtro><orden>orden</orden></select></criterio>",
                xsl_name: 'HTML_ver_archivos_def.xsl',
                formTarget: 'iframe1',
                mantener_origen: true,
                bloq_contenedor: $('iframe1'),
                cls_contenedor: 'iframe1'
            })

		  }
		  
		  function imprimir_grupo(nro_grupo){
			var id_transferencia = 684//542
  
            var parametros = '<nro_credito>' + nro_credito + '</nro_credito><nro_archivo_def_grupo>' + nro_grupo + '</nro_archivo_def_grupo>'

            var strXML_parm = '<parametros>' + parametros + '</parametros>'

            parent.nvFW.transferenciaEjecutar({
                id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                formTarget: 'winPrototype',
                ej_mostrar: true,
                async: false,
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: false,
                    url: 'enBlanco.htm',
                    title: '<b>Generar archivo de grupo</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 800,
                    height: 300,
                    resizable: true,
                    destroyOnClose: true
                }
            })
		  
		  }
		  
		  function btnUIF_onclick(nro_credito)
          { 
          
          if (!_permiso_editar_archivos){
              alert("No posee permisos para modificar archivos en este crédito")
              return;
            }
            
		         var URL = '/meridiano/getXML.asp?accion=uif_html_guardar&criterio=<criterio><nro_credito>' + nro_credito + '</nro_credito></criterio>'
             var oXML = new tXML()
             oXML.async = true
             
             nvFW.bloqueo_activar($(document.body), 'Ajax_bloqueo')
             oXML.load('/meridiano/getXML.asp','accion=uif_html_guardar&criterio=<criterio><nro_credito>' + nro_credito + '</nro_credito></criterio>',function(){
                nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')
                var num_error = oXML.selectSingleNode('xml/resultado/@num_error').nodeValue
				
				        if(num_error != 0)
				         {
				          alert("Error al adjuntar el archivo.</br>Intentelo nuevamente.")
				          return
				         }
				 
                        var NURL = oXML.selectNodes('xml/resultado')
                        var URL = XMLText(selectSingleNode('URL',NURL[0]))
				 											
				        if(URL == "")
				          return
																		 
				        window.open(URL, '_blank')
				        parent.btnMostrarArchivos_onclick()  
                
             });
             
             
		     } 
		  
          function btnNOSIS_onclick(nro_credito, nro_docu)
          { 
		       if (!_permiso_editar_archivos){
              alert("No posee permisos para modificar archivos en este crédito")
              return;
            }
            
            var existe = false
            			
			      j = archivos.length - 1
			
			      for(i=1; i<j ; i++){
                    if (archivos[i]['archivo_descripcion'].indexOf('NOSIS') != -1)
                      existe = true
                  }
					
            if(existe)
             {
				      window.top.Dialog.confirm("Ya existe un archivo de NOSIS para este crédito. ¿Desea cargar otro?", {
				      width: 300,
				      className: "alphacube",
				      okLabel: "Aceptar",
				      cancelLabel: "Cancelar",
				      cancel: function(win) { win.close(); return },
				      ok: function(win) {
								
								      cargar_NOSIS()
								      win.close()
							      }
				      });
			      }
			      else
             {
				      cargar_NOSIS()
       			}
    }
		 
		 
		  function cargar_NOSIS(){
			
        /*  nro_banco = 0
          var strXML = "<criterio><select vista='vercreditos'><campos>cuit,nro_banco</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito></filtro></select></criterio>"
		      var rs = new tRS();
			    rs.open(strXML)
          {
            nro_banco = rs.getdata("nro_banco")
            cuit = rs.getdata("cuit")
          }
         
         debugger
         if ((window.top.permisos_nosis & 1) > 0) 
         {
            window.top.win_nosis = window.top.nvFW.createWindow({
                className: 'alphacube',
                title: '<b>Ver Informe NOSIS</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 500,
                height: 350,
                minWidth:500,
                maxheight: 350,
                resizable: false,
                onClose: parent.btnMostrarArchivos_onclick
                
            });
            window.top.win_nosis.setURL("NOSIS_sel_CDA_new.asp?nro_docu=" + nro_docu + "&cuit=" + cuit + "&nro_credito=" + nro_credito + "&nro_banco=" + nro_banco)
            window.top.win_nosis.showCenter(true)
        }
        else*/
          
          
          sac_val_cda(nro_credito, function(cuit,nro_entidad,cda,nro_vendedor,propiedades){  
          
                                   if(propiedades.encontrados == 1)
                                     sac_html_guardar(nro_credito,nro_docu, function(strXML){  
																       try
																	    {
																	    var oXML = new tXML();
																		    oXML.loadXML(strXML)
																		    var num_error = oXML.selectSingleNode('xml/resultado/@num_error').nodeValue
																		    if (num_error == 1){
																			    //window.close()
																		        window.top.alert('No se pudo generar el archivo. Consulte al administrador del sistema.')
																			    return
																		    }
																		    //var URL = oXML.selectSingleNode('xml/resultado/URL').text
																		
																		    var NURL = oXML.selectNodes('xml/resultado')
																		    var URL = XMLText(selectSingleNode('URL',NURL[0]))
																		    window.open(URL, '_blank')
																		    parent.btnMostrarArchivos_onclick()  
																	    }
																	    catch(e)
																	    {
																		    window.top.alert('No se pudo generar el archivo. Consulte al administrador del sistema.')
																	    }	
																     },{cuit : cuit , nro_entidad: nro_entidad ,CDA: cda, nro_vendedor: nro_vendedor, nro_banco: 0} )
                                   else
                                   {
                                   
                                       window.top.win_nosis = window.top.nvFW.createWindow({
                                        className: 'alphacube',
                                        title: '<b>Ver Informe NOSIS</b>',
                                        minimizable: false,
                                        maximizable: false,
                                        draggable: true,
                                        width: 500,
                                        height: 350,
                                        minWidth:500,
                                        maxheight: 350,
                                        resizable: false,
                                        onClose: parent.btnMostrarArchivos_onclick
                
                                    });
                                    window.top.win_nosis.setURL("NOSIS_sel_CDA.asp?nro_docu=" + nro_docu + "&nro_vendedor=" + nro_vendedor + "&cuit=" + cuit + "&nro_credito=" + nro_credito + "&nro_entidad=" + nro_entidad + "&cda=" + escape(cda))
                                    window.top.win_nosis.showCenter(true)
                                    
                                   }
                                   
                  });
		 
		 }
		 
		 var win_BCRA
         var param_BCRA = {}
		 function btnBCRA_onclick()
          {
          
          if (!_permiso_editar_archivos){
              alert("No posee permisos para modificar archivos en este crédito")
              return;
            }
            
		  if((window.top.permisos_web2 & 268435456)>0)
		  {
			   var nro_credito=($('nro_credito')== undefined)?pvnro_credito:$F('nro_credito')
				 if ( nro_credito!="") 
				 {
				    param_BCRA['cuit'] = ''
                    param_BCRA['sit_bcra'] = ''
                    param_BCRA['modo'] = ''

                    var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                    win_BCRA = w.createWindow({ 
                        className: 'alphacube',
                        url: "bcra_captcha.asp?modo=A&nro_credito=" + nro_credito + "&cuit=" + cuit,
                        title: '<b>Consulta BCRA</b>',
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        width: 720,
                        height: 450,
                        resizable: false,
                        onClose: BCRA_consultar_return
                    });

                    win_BCRA.options.userData = { param_BCRA: param_BCRA }
                    win_BCRA.showCenter(true)     
				 
				 }
				 
	        }else
			alert("No posee permisos para realizar esta operacion. Consulte con el administrador del sistema")
		 }
		
		 function BCRA_consultar_return()
		  {
		   if(win_BCRA.options.userData.param_BCRA['modo'] == "ACTUALIZAR")
		     parent.btnMostrarArchivos_onclick()  
		  }
		 
		 function cargar_titulo(nro_credito){
		     var strXML = "<criterio><select vista='verCreditos'><campos>*</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito></filtro></select></criterio>"
		     var rs = new tRS();
			 rs.open(strXML)
			 var path = ""
			 
			 if (!rs.eof())
				return 'Nro Crédito : ' + nro_credito + ' - ' + rs.getdata('documento') + ': '+rs.getdata('nro_docu')+' - ' + rs.getdata('strNombreCompleto')
		    
				return 'Nro Crédito : '+nro_credito
		 }
     
     var _permiso_editar_archivos; 
     var _solo_pagare = false;
     var _solo_edicto_quiebra=false;
     var _solo_acta_defuncion=false;
     var _solo_carta_documento=false;	 
     function parametros_editar_archivo(){
        
        _permiso_editar_archivos = true;
        var cred_par = new Array();
        
        var rs = new tRS();
        var nro_tipo_cobro;
        var nro_tabla_tipo;
        rs.open("<criterio><select vista='verCredito_parametros_editar_archivo'><campos>parametro,parametro_valor,estado,nro_tipo_cobro,nro_tabla_tipo</campos><orden></orden><grupo></grupo><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito></filtro></select></criterio>")
        while (!rs.eof()) {
             cred_par[rs.getdata('parametro')] = rs.getdata('parametro_valor')
             estado = rs.getdata('estado')
             nro_tipo_cobro=rs.getdata('nro_tipo_cobro')
             nro_tabla_tipo=rs.getdata('nro_tabla_tipo')
             rs.movenext()
        }
        
        
        if(estados.indexOf(estado) != -1)
		{ 
			if(nro_tabla_tipo == 1 && nro_tipo_cobro == 4)
			{
					if((window.top.permisos_web4 & 33554432)==0)
					{					
					_permiso_editar_archivos = false; 
					}
			}
			else
			{
				if((window.top.permisos_web3 & 134217728)==0)
				{
					if((window.top.permisos_web4 & 64)==0 || cred_par["id_carpeta_control"] != 5)
					_permiso_editar_archivos = false; 
				}
			
			}
		
		}

        if((window.top.permisos_web3 & 16384)==0 && cred_par["id_control_digital"] == 2)
				{ _permiso_editar_archivos = false; }
        if((window.top.permisos_web3 & 268435456)==0 && cred_par["id_carpeta_control"] == 2)
				{ _permiso_editar_archivos = false; }
        if((window.top.permisos_web3 & 536870912)==0 && cred_par["id_control_contenido"] == 2)
				{ _permiso_editar_archivos = false; } 
        
        if((window.top.permisos_web4 & 2)==0 && cred_par["id_control_contenido"] == 4)
				{ _permiso_editar_archivos = false; } 
        if((window.top.permisos_web4 & 4)==0 && cred_par["id_control_digital"] == 5)
				{ _permiso_editar_archivos = false; }         
        if((window.top.permisos_web4 & 1)!=0 && cred_par["id_control_contenido"] == 4)
				{ _solo_pagare = true; } 
        if((window.top.permisos_web4 & 8)!=0 && cred_par["id_control_digital"] == 5)
				{ _solo_pagare = true; }      

				
				//Permiso para solo documentos de quiebras
            	if((window.top.permisos_archivos & 2)!=0)
            	{ _solo_edicto_quiebra=true }

            	//Permiso para solo documentos de defuncion
            	if((window.top.permisos_archivos & 4)!=0)
            	{ _solo_acta_defuncion=true }

            	//Permiso para solo cargar carta documento 
            	if((window.top.permisos_archivos & 8)!=0)
            	{ _solo_carta_documento=true }
        
           
     }
						]]>
						</xsl:comment>
					</script>

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
					campos_head.nvFW = parent.nvFW
				</script>
				<script type="text/javascript"  language="javascript" >
					<xsl:comment>
						<![CDATA[ 

                        function seleccionTR(indice)
		                   {
		                      $('tr_ver'+indice).addClassName('tr_cel')
		                   }
                 
		                  function no_seleccionTR(indice)
		                   {
		                      $('tr_ver'+indice).removeClassName('tr_cel')
		                   }
					        
					    function window_onresize()
					    {
					        try
					        {
    					    
					         var dif = Prototype.Browser.IE ? 5 : 2
					         var body_height = $$('body')[0].getHeight()
					         var tbCabe_height = $('tbCabe').getHeight()
					         var div_pag_height = $('div_pag').getHeight()
                             
					         $('divDetalle').setStyle({height: body_height - div_pag_height - tbCabe_height - dif + 'px'})
    					     
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
                        parametros_editar_archivo()
                         window_onresize()
                        }
                       
					   function abrir_visualizador(e){
					   
							 var path = '/meridiano/verArchivosTodos.asp?nro_credito='+pvnro_credito;
							 var link = 'link_mostrar_archivos';
							 
							 if (e.ctrlKey == true) {
								    $(link).href =  path + '&ventana=1';
							 }else if(e.shiftKey == true){
									$(link).target = '_blank'
								    $(link).href = path + '&ventana=1';                                 
                  			 }else{
								 abrir_ventana_emergente(path, cargar_titulo(pvnro_credito), undefined, undefined, 580, 1100, true, true, true, true, false)
							 }
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
				<body onload="return window_onload()" onResize="return window_onResize()" style="width:100%;height:100%; overflow:hidden">
					<xsl:variable name="nro_credito" select="xml/rs:data/z:row/@nro_credito" />
					<form name="frm1" id="frm1">						
						<table id="tbCuerpo" class="tb1" >
							<tr class="tbLabel" >
								<td colspan="3">
									<table class="tb1" id="tbEncabezado1" cellspacing="0" cellpadding="0">
										<tr>
											<td style="text-align:center">	
												<b>Archivos</b><xsl:if test="$nro_credito != ''"><b> - Nro Credito: <xsl:value-of select="$nro_credito"/></b></xsl:if>
												
											</td>
										</tr>	
									</table>
								</td>
							</tr>
							<tr>
								<td colspan='2' style='width:85%'>

									<table width="100%" class="tb1" id="tbCabe">
										<tr class="tbLabel">
											<td colspan="3">
												<table width="100%">
													<tr class="tbLabel">
														<td style='text-align: center; width:45%'>
															<script>
																campos_head.agregar('Documentos', true, 'archivo_descripcion')
															</script>

														</td>
														<td style='text-align: center; width:10%'>
															<script>
																campos_head.agregar('Requisito', true, 'requerido')
															</script>
														</td>

														<td style='text-align: center;  width:5%'>
													
														</td>
														<td style='text-align: center; width:5%'>

														</td>
														<td style='text-align: center; width:5%'>

														</td>
														<td style='text-align: center; width:10%'>
															<script>
																campos_head.agregar('Fecha', true, 'fe_credito')
															</script>
														</td>
														<td style='text-align: center; width:10%'>
															<script>
															campos_head.agregar('Operador', true, 'operador')
															</script>
														</td>
														<td style='text-align: center; width:10%'>
													    
														</td>
														<td style='text-align: center; width:10%'>
													    
														</td>
														
													</tr>
												</table>
											</td>
										</tr>
									</table>
									<div id="divDetalle" style="width:100%;overflow:auto">
										<table class="tb1" id="tbDetalle">
											<xsl:apply-templates select="xml/rs:data/z:row" />
										</table>
									</div>
									<div id="div_pag" class="divPages">
										<script type="text/javascript">
											document.write(campos_head.paginas_getHTML())
										</script>
									</div>
								
								</td>
								<td style="vertical-align:top">
									<table class="tb1">
										<tr>
											<td>


												<DIV style="WIDTH: 100%" id="divGuardar">
													<TABLE class="btnTB_O" border="0" cellSpacing="0" cellPadding="0">
														<TBODY>
															<TR>
																<TD class="btnBegin_O"></TD>

																<TD class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)"  onclick="return abrir_visualizador(event)">
																	<a id="link_mostrar_archivos" href="#" style="color:black; text-decoration:none;" >
																		<IMG border="0" name="img_1" hspace="1" align="absMiddle" src="../../meridiano/image/icons/pagina_impresion.png" />Visualizador
																	</a>
															</TD>

															<TD class="btnEnd_O"></TD>
															</TR>
														</TBODY>
													</TABLE>
												</DIV>
											</td>
										</tr>
										<!--<tr class="tbLabel0">
											<td>Estados</td>
										</tr>
										<tr>
											<td nowrap="true">
												<a>
													Activos[<span style="color: blue">
														<xsl:value-of select="count(xml/rs:data/z:row[@nro_com_estado = 1])"/>
													</span>]
												</a>
											</td>
										</tr>
										<tr>
											<td nowrap="true">
												<a>

													Anulados[<span style="color: blue">
														<xsl:value-of select="count(xml/rs:data/z:row[@nro_com_estado = 3])"/>
													</span>]
												</a>
											</td>
										</tr>
										<tr>
											<td nowrap="true">
												<a>

													Pendientes[<span style="color: blue">
														<xsl:value-of select="count(xml/rs:data/z:row[@nro_com_estado = 2])"/>
													</span>]
												</a>
											</td>
										</tr>
										<tr>
											<td nowrap="true">
												<a>

													Terminados[<span style="color: blue">
														<xsl:value-of select="count(xml/rs:data/z:row[@nro_com_estado = 5])"/>
													</span>]
												</a>
											</td>
										</tr>-->
									</table>
								<table class="tb1">
									<tr class="tbLabel0">
										<td>Documentos</td>
									</tr>										
									<tr>	
										<td>
											<input type="button" name="btn_NvoDoc" value="Nuevo" style="width:100%" onclick="ABMDocumentos(null,null,null,13,null)"></input>
										</td>
									</tr>
                  <xsl:if test="xml/rs:data/z:row/@permiso_nosis = 'True'">
                    <tr>
                      <td>
                        <input type="button" name="btn_NOSIS" value="NOSIS" style="width:100%" onclick="btnNOSIS_onclick(pvnro_credito, nro_docu)"></input>
                      </td>
                    </tr>
                  </xsl:if>
    			  <tr>
		              <td>
				        <input type="button" name="btn_DocBCRA" value="BCRA" style="width:100%" onclick="btnBCRA_onclick()"></input>
					 </td>
                  </tr>
                  <xsl:if test="xml/rs:data/z:row/@permiso_uif = 'True'">
                      <tr >
                          <td>
                              <input type="button" name="btn_UIF" value="UIF" style="width:100%;" onclick="btnUIF_onclick(pvnro_credito)"></input>
                          </td>
                      </tr>
                  </xsl:if>
									
									<tr class="tbLabel0">
										<td>Grupos</td>
									</tr>
									</table>
									<div  style="overflow: auto; height: 136px;">
									<table class="tb1" id ="grupos">
									</table>
									</div>
									<script languaje="javascript">obtener_grupos(nro_credito)</script>


								</td>
							</tr>
							
							
						</table>

				</form>
				<form name="formVarios" action="../reportViewer/exportarReporte.asp" method="POST">
					<input type="hidden" name="filtroXML" value=""></input>
					<input type="hidden" name="xsl_name" value=""></input>
				</form>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()"/>
		<tr>
			<xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>			 
          <xsl:attribute name="onmousemove">seleccionTR(<xsl:value-of select="$pos"/>)</xsl:attribute>
          <xsl:attribute name="onmouseout">no_seleccionTR(<xsl:value-of select="$pos"/>)</xsl:attribute>
			<xsl:attribute name="style">
				<xsl:value-of select="@style_vencimiento"/>
			</xsl:attribute>
			<xsl:attribute name="title">
				<xsl:choose>
					<xsl:when test="@style_vencimiento = 'color:red !Important'">Documentación venciada o falta presentar</xsl:when>
					<xsl:when test="@style_vencimiento = 'color:#AAA60F !Important'">Dos día para el vencimiento de la documentación</xsl:when>
					<xsl:when test="@style_vencimiento = 'color:#ED8714 !Important'">Un día para el vencimiento de la documentación</xsl:when>
					<xsl:when test="@style_vencimiento = 'color:green !Important'">Documentación no presentada, pero es opcional</xsl:when>
					<xsl:when test="@style_vencimiento = 'color:blue !Important'">Documentación presentada</xsl:when>
					<xsl:when test="@style_vencimiento = 'color:black !Important'">Documentación no vigente</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<td style='text-align: left; width:40%;'>
						
				
				<xsl:attribute name="style">
					text-align: left;<xsl:value-of select="@style_vencimiento"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test='string(@requerido) = "True" and string(@nro_archivo) != "NULL"'>
						<xsl:attribute name="style">
							color:Red
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">
							color:Green
						</xsl:attribute>
					</xsl:otherwise>

				</xsl:choose>
				<xsl:if test='string(@nro_archivo) != ""'>
					<xsl:attribute name="style">
						cursor:pointer;color:blue; font-weight:bold; text-decoration: underline;
					</xsl:attribute>
					
					<xsl:attribute name="onclick">
					  window.open('../../meridiano/get_file.asp?nro_archivo=<xsl:value-of select="@nro_archivo"/>')
					 </xsl:attribute>
					
				</xsl:if>
				
					<xsl:choose>							
						<xsl:when test="string-length(@archivo_descripcion) &#62; 100">
							<xsl:value-of select="substring(@archivo_descripcion,1,100)"/>...
							<xsl:if test='string(@nro_archivo) != ""'>
							- <xsl:value-of select="@nro_archivo"/>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@archivo_descripcion"/>
							<xsl:if test='string(@nro_archivo) != ""'>
							- <xsl:value-of select="@nro_archivo"/>
							</xsl:if>
						</xsl:otherwise>			
					</xsl:choose>

				

			</td>
			<td style='text-align: left; width:10%'>
				<xsl:attribute name="style">
					text-align: left; width:10%;<xsl:value-of select="@style_vencimiento"/>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="string(@requerido) = 'True'">
						Obligatorio
					</xsl:when>
					<xsl:otherwise>
						Opcional
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td style='text-align: center;width:5%'>
				<xsl:if test='@nro_def_archivo = @nro_def_archivo_actual'>
					<a>
					<xsl:attribute name="onclick">
						ABMDocumentos(<xsl:value-of select="@orden"/>,'<xsl:value-of select="@readonly"/>','<xsl:value-of select="@nro_archivo"/>','<xsl:value-of select="@nro_archivo_def_tipo"/>','<xsl:value-of select="@permiso_tiene"/>')
					</xsl:attribute>
					<img title="Adjuntar Archivo" src="../../meridiano/image/icons/agregar.png" style="cursor:pointer;cursor:hand" border="0"/>
				</a>
				</xsl:if>
			</td>

			<td style='text-align: center; width:5%' nowrap='true'>
				<a>
					<xsl:attribute name="onclick">
						abrir_ventana_emergente('verArchivosTodos.asp?nro_credito='+pvnro_credito+'&amp;nroarchivo=<xsl:value-of select="@nro_archivo"/>', cargar_titulo(pvnro_credito), undefined, undefined, 580, 1100, true, true, true, true, false)
				    </xsl:attribute>
					<img src="../../meridiano/image/icons/ver_adjunto.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Vista Preliminar</xsl:attribute>
					</img>
				</a>


			</td>
			<td style='text-align: center; width:5%' nowrap='true'>
				
				<xsl:if test='string(@cantidad) > 0'>
					<xsl:attribute name="onclick">
						verDocumentosWin(<xsl:value-of select="@nro_credito"/>,<xsl:value-of select="@nro_def_detalle"/>)
					</xsl:attribute>
					<img src="../../meridiano/image/icons/reporte.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Historial Documentos</xsl:attribute>
					</img>
				</xsl:if>
			</td>
			
				<td style='text-align: center; width:10%' nowrap='true'>
				<xsl:value-of select="foo:FechaToSTR(string(@momento))"/>
		
			</td>
			<td style='width:10% !Important'>
				<xsl:value-of select="@operador"/>
			</td>

			<td style='text-align: center; width:5%' nowrap='true'>

				<xsl:if test='@nro_archivo != ""'>
					<xsl:attribute name="onclick">
						editarDocumentosWin(<xsl:value-of select="@nro_archivo"/>,"<xsl:value-of select="@archivo_descripcion"/>","<xsl:value-of select="@nro_registro"/>")
					</xsl:attribute>
					<img src="/meridiano/image/icons/editar.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Editar Archivo</xsl:attribute>
					</img>
				</xsl:if>
			</td>
			
			<td style='text-align: center; width:5%' nowrap='true'>

				<xsl:if test='@nro_archivo != ""'>
					<xsl:attribute name="onclick">
						verParametros(<xsl:value-of select="@nro_credito"/>,<xsl:value-of select="@nro_def_detalle"/>)
					</xsl:attribute>
					<img src="/meridiano/image/icons/propiedades.png" style="cursor:pointer" border="0" >
						<xsl:attribute name="title">Ver Parámetros</xsl:attribute>
					</img>
				</xsl:if>
			</td>
			
			
			
		</tr>
	</xsl:template>
</xsl:stylesheet>