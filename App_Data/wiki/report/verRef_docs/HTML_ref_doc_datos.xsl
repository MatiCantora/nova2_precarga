<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">
  
    <xsl:include href="..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>

    <msxsl:script language="vb" implements-prefix="user">
        <msxsl:assembly name="System.Web"/>
        <msxsl:using namespace="System.Web"/>
        <![CDATA[
        Dim nvFW_interOp as object = HttpContext.current.application.contents("_nvFW_interOp")
      
        Public function getfiltrosXML() as String
        

            Page.contents("filtroRefDocDep") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_dep'><campos>*,  CAST(ref_doc_datos as varchar(max)) as docHTML </campos><orden>ref_dep_orden, nro_ref_doc_tipo, nro_ref_doc, doc_orden</orden><filtro><nro_ref_doc_tipo type='igual'>1</nro_ref_doc_tipo><nro_ref_estado type='igual'>1</nro_ref_estado><ref_doc_activo type='igual'>1</ref_doc_activo></filtro></select></criterio>")
            Page.contents("filtroRefSusOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_sus_operador'><campos>*</campos><orden></orden><filtro><operador type='igual'>dbo.rm_nro_operador()</operador><nro_ref_sus_estado type='igual'>1</nro_ref_sus_estado><nro_ref type='igual'>%nro_ref%</nro_ref></filtro><grupo></grupo></select></criterio>")
            Page.contents("filtroRefSusOperadorPend") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_sus_operador'><campos>*</campos><orden></orden><filtro><operador type='igual'>dbo.rm_nro_operador()</operador><nro_ref_sus_estado type='igual'>2</nro_ref_sus_estado><nro_ref type='igual'>%nro_ref%</nro_ref></filtro><grupo></grupo></select></criterio>")
            Page.contents("filtroRmRefOpSuscripcion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_ref_op_suscripcion'><parametros><nro_ref DataType='int'>%nro_ref%</nro_ref></parametros></procedure></criterio>")
            Page.contents("filtroRefDocVersiones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_versiones' top='5'><campos>*</campos><orden>ref_doc_version desc</orden><filtro><nro_ref_doc type='igual'>%nro_ref_doc%</nro_ref_doc></filtro><grupo></grupo></select></criterio>")
            Page.contents("filtroRefDocs") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>nro_ref_doc_tipo, nro_ref_doc, doc_orden</orden><filtro></filtro><grupo></grupo></select></criterio>")
            Page.contents("filtroRefImpresion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.ref_dependientes' CommantTimeOut='1500'><parametros></parametros></procedure></criterio>")
            Page.contents("filtroRefEliminar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_ref_eliminar' CommantTimeOut='1500'><parametros><nro_ref DataType='int'>%nro_ref%</nro_ref></parametros></procedure></criterio>")

            return ""

        End Function
		
		Dim a as String = getfiltrosXML()     
		]]>
    </msxsl:script>

    <msxsl:script language="javascript" implements-prefix="foo">
	    <![CDATA[
      
        var nro_ref_doc_tipo = -1,
            nro_ref_doc = -1
    
        function renderPage(nro_ref) {
            if (nro_ref != 0) {
                return true;
            }
            return false;
        }
		  
		function grupo_doc_cambio(nro_doc) { 
		    if (nro_ref_doc != nro_doc) {
			    nro_ref_doc = nro_doc
			    return true
			}
		    else
		        return false
		}  

		function parseFecha(strFecha) {
		    var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
			a = a.substr(0, a.indexOf('.'))
			var fe = new Date(Date.parse(a))

			return fe
		}
		
		function conv_fecha_to_str(cadena, modo) {
		    var objFecha = parseFecha(cadena),
                dia,
                mes,
                anio,
                hora,
                minuto,
                segundo

		    if (objFecha.getDate() < 10)
		        dia = '0' + objFecha.getDate().toString()
		    else
		        dia = objFecha.getDate().toString() 

		    if ((objFecha.getMonth() + 1) < 10)
		        mes = '0' + (objFecha.getMonth() + 1).toString()
		    else
		        mes = (objFecha.getMonth() + 1).toString() 	 
		    anio = objFecha.getFullYear()

		    if (objFecha.getHours() < 10)
		        hora = '0' + objFecha.getHours().toString()
		    else
		        hora = objFecha.getHours().toString() 
			 
		    if (objFecha.getMinutes() < 10)
		        minuto = '0' + objFecha.getMinutes().toString()
		    else
		        minuto = objFecha.getMinutes().toString() 	 
		
		    if (objFecha.getSeconds() < 10)
		        segundo = '0' + objFecha.getSeconds().toString()
		    else
		        segundo = objFecha.getSeconds().toString() 	 	 
		  
            switch (modo) {
			    case 'mm/dd/aa':
			        return mes + '/' + dia + '/' + anio
			        break; 
			    case 'dd/mm/aa':
			        return dia + '/' + mes + '/' + anio
			        break;    
			    case 'dd/mm/aa hh:mm:ss':
			        return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + minuto + ':' + segundo
			        break;       
			}
        }

		function ucase(a) {
		    return a.toUpperCase()
		}

        function grupo_tipo_cambio(nro_tipo_doc) { 
		    if (nro_ref_doc_tipo != nro_tipo_doc) {
		        nro_ref_doc_tipo = nro_tipo_doc
		        return true
		    }
		    else
		        return false
		}
		]]>
    </msxsl:script>

    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Referencia</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                <link href="/wiki/css/base.css" type="text/css" rel="stylesheet"/>

                <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
                <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
                <script type="text/javascript" language="javascript" src="/FW/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" language="javascript" src="/fw/script/utiles.js"></script>
                
                <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>

                <script type="text/javascript" language="javascript">
                    <xsl:comment>
                    var nro_ref = '<xsl:value-of select="xml/rs:data/z:row/@nro_ref"></xsl:value-of >',
                        ref_admin = '<xsl:value-of select="xml/rs:data/z:row/@ref_admin"></xsl:value-of >',
                        ref_editar = '<xsl:value-of select="xml/rs:data/z:row/@ref_editar"></xsl:value-of >',
                        ref_eliminar = '<xsl:value-of select="xml/rs:data/z:row/@ref_eliminar"></xsl:value-of >',
                        id_ref_auto = '<xsl:value-of select="xml/parametros/id_ref_auto"/>',
                        app_path_rel = '<xsl:value-of select="xml/parametros/app_path_rel"/>',
                        permisos_referencias = '<xsl:value-of select="xml/parametros/permisos_referencias"/>'
                        <![CDATA[
                    
               
                    // necesario setear el valor de permisos para usar la funcion nvFW.tienePermiso (No disponemos de Me.addPermisoGrupo)
                    if (!window.top.permiso_grupos) {
                        window.top.permiso_grupos = {}
                        window.top.permiso_grupos["permisos_referencias"] = permisos_referencias
                    }
                    
                    //window.top.permiso_grupos["permisos_referencias"] = permisos_referencias
                    
                    
                    var fw
                    if (window.top.nvFW != undefined) {
                        fw = window.top.nvFW
                    } else {
                        fw = nvFW
                    }
                    

                    function window_onresize() {
                        if (nro_ref != '') {
                            var dif = Prototype.Browser.IE ? 5 : 2,
                                body_heigth = $$('body')[0].getHeight()
                                tdMenuDatosRefIzq_heigth = $('tdMenuDatosRefIzq').getHeight(),
                                titulo_heigth = $('tb_titulo').getHeight() //+ $$('.ref_titulo.first')[0].getHeight(),
                                a = $('tb_body')
                                
                                a.setStyle({ height: body_heigth - tdMenuDatosRefIzq_heigth - titulo_heigth - dif + 'px' })
						}
					}

                    function window_onload() {
                        if (nro_ref != '') {
                            var filtroXML = nvFW.pageContents.filtroRefDocDep,
                                filtroWhere = "<criterio><select ><orden></orden><filtro><nro_ref_padre type='in'>" + nro_ref + "</nro_ref_padre></filtro></select></criterio>"

                            nvFW.exportarReporte({
                                filtroXML: filtroXML
                                ,filtroWhere : filtroWhere
                                ,path_xsl: "report\\verRef_docs\\HTML_ref_doc_dep.xsl"
                                ,metodo: 'httprequest'
                                ,funComplete: function(oXMLHttp, parseError) {
                                    $('ref_dependencia').insert({ top: oXMLHttp.responseText })
                                }
                                //,formTarget: 'ref_dependencia'
                                //,nvFW_mantener_origen: true
                                //,id_exp_origen: 0
                                ,bloq_contenedor: $('ref_dependencia')
                            })
                            toggleSus(); 
                            verSuscripcionPendiente(nro_ref); 
                            window_onresize()
                        }

                        // Ver de donde sale el "editRef" ??????
                        if (window.top.editRef || id_ref_auto != 0) {
                            editar_referencia(window.top.editRef);
                            window.top.editRef = false;
                        }
					}

                    /***  Verifica si el operador est� "Suscripto" a la referencia  ***/
                    function estaSuscripto(nro_ref) {
                        var rs = new tRS(),
                            filtroXML = nvFW.pageContents.filtroRefSusOperador,
                            params = "<criterio><params nro_ref='" + nro_ref + "'/></criterio>"
                        
                        rs.open(filtroXML, '', '', '', params)
                        return !rs.eof();
                    }
                        
                    /***  Muestra de icono de favorito del men� de diferente color, dependiendo si el operador esta suscripto o no a la referencia buscada  ***/
                    function toggleSus()
                    {
                      var $img20 = $('vMenu_img20')
                      var $img21 = $('vMenu_img21')

                      if (estaSuscripto(nro_ref)) {
                        $img20.up('td').setStyle({'display':'table-cell'});
                        $img21.up('td').setStyle({'display':'none'});
						          }
                      else {
                        $img20.up('td').setStyle({'display':'none'});
                        $img21.up('td').setStyle({'display':'table-cell'});
						          }

                      $img20.setStyle({'display': 'inline'});
                      $img21.setStyle({'display': 'inline'});
					          }

                    /***  Verifica si el operador tiene una "Suscripcion Pendiente" a la referencia   ***/
                    function tieneSuscripcionPendiente(nro_ref) {
                        var rs = new tRS(),
                            filtroXML = nvFW.pageContents.filtroRefSusOperadorPend,
                            params = "<criterio><params nro_ref='" + nro_ref + "'/></criterio>"
                        
                        rs.open(filtroXML, '', '', '', params)
                        return !rs.eof();
                    }

                    /***  Verifica si el operador posee una "Suscripcion Pendiente" a la referencia y si la acepta o no   ***/
                    function verSuscripcionPendiente() {
                        if (tieneSuscripcionPendiente(nro_ref)) {
                            fw.confirm("Ha sido subscripto a la referencia. �Desea confirmar la suscripcion?", {
                                width: 300,
                                okLabel: "Aceptar",
                                cancelLabel: "Cancelar",
                                ok: function(win) {
                                        updateRefOp(nro_ref);
                                        toggleSus();
                                        win.close()
                                },
                                cancel: function(win) {
                                        updateRefOp(-1 * nro_ref);
                                        win.close();
                                },
                                id: 'confirm'
                            });
                        }
                    }

                    function updateRefOp(nro_ref) {
                        var alert_1 = '',
                            alert_2 = 'No se pudo realizar la operaci�n';

                        if (nro_ref < 0) {
                            alert_1 = alert_2;
                            alert_2 = '';
                        }

                        var rs = new tRS(),
                            filtroXML = nvFW.pageContents.filtroRmRefOpSuscripcion,
                            params = "<criterio><params nro_ref='"+nro_ref+"'/></criterio>"

                        rs.open(filtroXML, '', '', '', params)

                        if (!rs.eof()) {
                            if (alert_1 != '') {
                                alert(alert_1);
                            }
                        }
                        else {
                            if (alert_2 != '') {
                                alert(alert_2);
                            }
                        }
                    }

                    function MO(e) {
					    obj = Event.element(e)
                          
                        while (obj.tagName != "TD") {
                            obj = obj.up()
                        }
                          
                        obj.removeClassName("MU")  
                        obj.addClassName("MO") 
					}

					function MU(e) {
					    obj = Event.element(e)
                          
                        while (obj.tagName != "TD") {
                            obj = obj.up()
                        }
                            
                        obj.removeClassName("MO")  
                        obj.addClassName("MU") 
					}

                    /***  Construye la lista de versiones de cada documento de una referencia   ***/
                    function get_version_list(nro_ref_doc, nro_ref_version) {
                        //Resuelto con tRS en un span
                        var sp_id = "sp_ver" + nro_ref_doc,
                            versiones = '',
                            title = '',
                            rs = new tRS(),
                            filtroXML = nvFW.pageContents.filtroRefDocVersiones,
                            params = "<criterio><params nro_ref_doc='"+nro_ref_doc+"'/></criterio>"
                          
                        rs.open(filtroXML, '', '', '', params)    

                        while (!rs.eof()) {
                            title = "Modificador:" + rs.getdata("ref_doc_fe_estado") + ' - ' + rs.getdata("nombre_operador")
                            versiones += '<a href="#" title="' + title + '" onclick="seleccionar_version(' + rs.getdata("ref_doc_version") + ',' + rs.getdata("nro_ref_doc") + ',' + rs.getdata("nro_ref") +')">' + rs.getdata("ref_doc_version") + '</a>-'
                            rs.movenext() 
                        }

                        versiones += '<a href="#" title="Ver todas las versiones del documento" onclick="versiones_doc_onclick(' + nro_ref + ',' + nro_ref_doc +')">+</a>'
                        $(sp_id).innerHTML = versiones
                    }

                    /***  Abre una ventana/pesta�a del navegador, con la informaci�n de la versi�n seleccionada del documento de una referencia ***/
                    function seleccionar_version(ref_doc_version, nro_ref_doc, nro_ref) { 
                        var filtroXML = nvFW.pageContents.filtroRefDocs,
                            filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro><ref_doc_version type='igual'>" + ref_doc_version + "</ref_doc_version><nro_ref_doc type='igual'>" + nro_ref_doc + "</nro_ref_doc><nro_ref type='igual'>" + nro_ref + "</nro_ref></filtro><grupo></grupo></select></criterio>"
                          
                        nvFW.exportarReporte({
                            filtroXML: filtroXML
                            , filtroWhere : filtroWhere
                            , path_xsl: "report\\verRef_docs\\HTML_ref_doc_datos.xsl"
                            , formTarget: '_blank'
                            , nvFW_mantener_origen: true
                            , id_exp_origen: 0
                            , parametros: '<parametros><id_ref_auto>' + id_ref_auto + '</id_ref_auto><app_path_rel>' + app_path_rel + '</app_path_rel><permisos_referencias>' + permisos_referencias + '</permisos_referencias></parametros>'
                        })
			        }	

                    function versiones_doc_onclick(nro_ref, nro_ref_doc) { 
                        version_buscar(nro_ref,nro_ref_doc)
					}

                    /***  Abre una ventana con la lista de versiones del documento de la referencia seleccionada  ***/
                    var win_version_buscar 	   
						            
                    function version_buscar(referencia, documento) { 
                        // cuando se buscan todas las versiones de la referencia la variable documento es undefined 
						documento = documento == undefined ? '' : documento
                        
						if ( (fw.tienePermiso('permisos_referencias', 3) && ref_editar=='1')
                             || fw.tienePermiso('permisos_referencias', 8)) {                          

                            win_version_buscar = fw.createWindow({ 
                                url: '/wiki/version_buscar.aspx?nro_ref=' + referencia + '&nro_ref_doc='+ documento, 
                                title: '<b>Versiones</b>',
                                minimizable: true,
                                maximizable: false,
                                draggable: true,
                                width: 700,
                                height: 400,
                                resizable: false,
                                onClose: function(){
                                    //  parent.frame_ref_recargar(referencia)   
                                }
                            });
                            //win_version_buscar.options.userData = {parametros: parametros}
                            win_version_buscar.showCenter(true)
			            }
                        else {
                            alert('No posee permisos para realizar esta acci�n. Consulte con el Administrador del Sistema.')	                                            
                        }
					}

                    /******************************************/
                    /***  Funciones llamadas desde el men�  ***/
                    /******************************************/
                        
                    /***  Abre la ventana del ABM Referencia para editar la referencia buscada  ***/
                        
                    var win_referencias_abm

                    function editar_referencia()
                    {
          
                        if ( (fw.tienePermiso('permisos_referencias', 3) && ref_editar=='1')
                             || parseInt(id_ref_auto)
                             || fw.tienePermiso('permisos_referencias', 8)) {
                            
                            var ref_no_guardada = '0';
                            
                            if (window.top.ref_no_guardada) {
                                ref_no_guardada = '1';
                                window.top.ref_no_guardada = false;
                            }


                            win_referencias_abm = fw.createWindow({
                                url: '/wiki/referencias_ABM.aspx?nro_ref2=' + nro_ref + '&id_ref_auto=' + id_ref_auto + '&ref_no_guardada=' + ref_no_guardada,
                                title: '<b>Editar Ref. ' + nro_ref + '</b>',
                                minimizable: true,
                                maximizable: true,
                                resizable: true,
                                draggable: true,
                                width: 1200,
                                height: 600,
                                destroyOnClose: true,
                                onClose: function(nro_ref){
                                    if (window.top != undefined) {
                                        window.top.abrir_ventana_emergente_OnClose(nro_ref)
                                    }
                                }
                            });

                            //win_referencias_abm.options.userData = {parametros: parametros}
                            win_referencias_abm.showCenter(true)
                        } 
                        else {
                            window.top.alert('No tiene permisos para realizar esta accion. Consulte con el Administrador del Sistema.')
                            return false
                        }
                    }
                        
                    /***  Al presionar el bot�n favorito del men�:
                    **   1 - si el operador esta suscripto a la referencia buscada, le pregunta si quiere dejar de recibir las actualizaciones de la referencia
                    **   2 - si el operador NO esta suscripto a la referencia buscada, le pregunta si quiere recibir las actualizaciones de la referencia
                    ***/
                    function suscripcion_referencia(nro_ref) {
                        var dejar_de = "";

                        if (nro_ref < 0) {
                            dejar_de = 'dejar de ';
                        }
                            
                        fw.confirm('�Desea '+ dejar_de +'recibir las actualizaciones de la referencia?', {
                            width: 300, 
                            onOk: function(win1) {
                                updateRefOp(nro_ref);
                                toggleSus();
                                win1.close();
                            }, 
                            onCancel: function(win1) {
                                win1.close();
                            }
                        });
                    }

                    /***  Abre una nueva ventana con la vista "Actual" o "Resumen" del resultado de la b�squeda, visualizado como PDF  ***/
                    function ref_impresion_pdf(nro_ref, tipo_salida) {
                        abrir_ventana_emergente('/wiki/ref_pre_export_pdf.aspx?nro_ref=' + nro_ref + '&tipo_salida=' + tipo_salida, 'Exportar referencia', 'permisos_referencias', 1, 236, 450)
                    }

                    /***  Abre una nueva ventana con la vista "Actual" del resultado de la b�squeda, para Imprimir  ***/
                    function ref_impresion(nro_ref) {
                        var filtroXML = nvFW.pageContents.filtroRefImpresion,
                            filtroWhere = "<criterio><procedure><parametros><nro_ref DataType='int'>" + nro_ref + "</nro_ref></parametros></procedure></criterio>"

                        nvFW.exportarReporte({
                            filtroXML: filtroXML
                            , filtroWhere: filtroWhere
                            , path_xsl: "report\\verRef_docs\\HTML_ref_doc_impresion_resumen.xsl"
                            , formTarget: '_blank'
                        })
                    }

                    /***  Abre una nueva ventana con la vista "Completa" del resultado de la b�squeda, para Imprimir  ***/
                    function ref_impresion_detalle(nro_ref) {
                        var filtroXML = nvFW.pageContents.filtroRefImpresion,
                            filtroWhere = "<criterio><procedure><parametros><nro_ref DataType='int'>" + nro_ref + "</nro_ref></parametros></procedure></criterio>"

                        nvFW.exportarReporte({
                            filtroXML: filtroXML
                            , filtroWhere: filtroWhere
                            , path_xsl: "report\\verRef_docs\\HTML_ref_doc_impresion_detalle.xsl"
                            , formTarget: '_blank'
                        }) 
                    }

                    function ref_mostrar(nro_ref) { 
                        //nvFW.alert(nro_ref.toString())
                        ObtenerVentana('divMenu_content').ref_mostrar(nro_ref)
			        }	  


                    /*** Abre la ventana "Permisos de Referencia" ***/
                    function permiso_referencia(nro_ref)
                    {
                        // Chequear que el operador puede administrar los permisos
                        if (fw.tienePermiso('permisos_referencias', 9) || (fw.tienePermiso('permisos_referencias', 5) && ref_admin=='1' )) {
                            abrir_ventana_emergente('/wiki/ref_permisos_abm.aspx?nro_ref=' + nro_ref , 'Permisos de Referencia', 'permisos_referencias', 1, 500, 950)
                        } else {
                            alert("No posee el permiso necesario para Administrar los permisos de la Referencia. Consulte con el Administrador del Sistema.")
                            return false
                        }
		                }


                    /***  Abre una ventana con la lista de versiones del documento de la referencia seleccionada  ***/
                    function versiones_onclick(nro_ref) {
					    version_buscar(nro_ref)
					}

                    function docu_onclick(nro_ref_doc) {
					    var tr = $('trDocu' + nro_ref_doc),
                            img = $('imgDocu' + nro_ref_doc)

						if (!tr.visible()) {
						    img.src = '/fw/image/tmenu/menos.gif'
						    tr.show()
						}
						else {
						    img.src = '/fw/image/tmenu/mas.gif'
							tr.hide()
						}
                    }

                    var arIndice = {}
					arIndice[0] = 0
				    arIndice[1] = 0
					arIndice[2] = 0
					arIndice[3] = 0
					arIndice[4] = 0
					arIndice[5] = 0
					arIndice[6] = 0
					arIndice[7] = 0
					arIndice[8] = 0	

					function html_limpiar(strHTML) {
					    var strreg = "</?[^>]*>",
                            reg = new RegExp(strreg, 'ig')
						
                        reg.IgnoreCase = true

					    strHTML = strHTML.replace(reg, '')
						return strHTML
					}

					function indice_inc(indice) {
					    if (indice == 9) 
                            indice = 0

						arIndice[indice] = arIndice[indice] + 1
                        for (var i = Number(indice) + 1; i <= 8; i++)
						    arIndice[i] = 0
					}

					function indice_get(indice) {
					    if (indice == 9)
                            indice = 0

                        indice_inc(indice)
						var res = ""

                        for (var i in arIndice)
						    if (arIndice[i] != 0)
							    res +=  arIndice[i] + "."

						return res	  
					}

					
          /*
					var arrTitulos = new Array();
          
          
                    function contenido_onclick() { 
					    if ($('tbContenido').style.display == '') {
						    $('tbContenido').hide()
						    arrTitulos.length = 0
						    return 
						}

						if (arrTitulos.length == 0) {
						    //colocar formato
						    var strreg = "(<h(\\d)>)(.*)(</h\\2>)",
						        reg1 = new RegExp(strreg, 'ig')
						    
                            reg1.IgnoreCase = true
									
						    strreg = "<h(\\d)>.*</h\\1>"
						    var reg = new RegExp(strreg, 'ig')
                            reg.IgnoreCase = true
                            var res = $$('body')[0].innerHTML.match(reg),
                                indice = '',
                                regA = /()/     // expresion regular vacia,
                                objBody = {}    // objeto vacio,
                                strHTML = ""

                            if (res == null) {
                                res = []
                            }

                            for (var i = 0, max = res.length; i < max; i++) {
							    arrTitulos[i] = {}
							    arrTitulos[i]['innerHTML'] = res[i].toString()
							    arrTitulos[i]['titulo'] = html_limpiar(arrTitulos[i]['innerHTML'].replace(reg1, "$3"))
							    indice = arrTitulos[i]['innerHTML'].replace(reg1, "$2")
							    strreg = "(" + arrTitulos[i]['innerHTML'] + ")"
							    regA = new RegExp(strreg)
							    objBody = $$('body')[0]
							    objBody.innerHTML = objBody.innerHTML.replace(regA, "<a name='link_tit" + i + "'/>$1")
							    arrTitulos[i]['contenido'] = arrTitulos[i]['innerHTML'].replace(reg1, "<div class='cont_h$2'><a href='#link_tit" + i + "'>" + indice_get(indice) + " " + arrTitulos[i]['titulo'] + "</a></div>")
							}

                            for (i = 0, max = arrTitulos.length; i < max; i++) {
							    strHTML += arrTitulos[i]['contenido']
							}

						    strHTML += ""
						    $('divContenido').innerHTML = ''
						    $('divContenido').insert({ top: strHTML })
						    $('tbContenido').show()
						}
					}
          */
          
          
          // Nueva version para "contenido_onclick()"
          
          var arrTitulos = []
          
          function contenido_onclick()
          {
            
            var $tbContenido = $('tbContenido')

					  if ($tbContenido.style.display == '') {
						  $tbContenido.hide()
						  arrTitulos.length = 0
						  return 
						}

						if (arrTitulos.length == 0) {
              var titulos = $$('.ref_doc_titulo')
              var indice  = ''
              var objBody = {}    // objeto vacio
              var strHTML = ""

              if (titulos == null) {
                titulos = []
              }

              for (var i = 0, max = titulos.length; i < max; i++) {
							  arrTitulos[i] = {}
							  arrTitulos[i]['innerHTML'] = titulos[i].innerHTML
							  arrTitulos[i]['titulo']    = titulos[i].innerText
							  //indice = arrTitulos[i]['innerHTML'].replace(reg1, "$2")
							  //strreg = "(" + arrTitulos[i]['innerHTML'] + ")"
							  //regA = new RegExp(strreg)
							  //objBody = $$('body')[0]
							  //objBody.innerHTML = objBody.innerHTML.replace(regA, "<a name='link_tit" + i + "'/>$1")
							  //arrTitulos[i]['contenido'] = arrTitulos[i]['innerHTML'].replace(reg1, "<div class='cont_h$2'><a href='#link_tit" + i + "'>" + indice_get(indice) + " " + arrTitulos[i]['titulo'] + "</a></div>")
                titulos[i].wrap('a', { 'name' : 'link_tit' + i })
                arrTitulos[i]['contenido'] = "<div class='cont_h9'><a href='#link_tit" + i + "'>" + (i + 1) + ". " + arrTitulos[i]['titulo'] + "</a></div>"
							}

              for (i = 0, max = arrTitulos.length; i < max; i++) {
							  strHTML += arrTitulos[i]['contenido']
							}

						  $('divContenido').innerHTML = strHTML
						  //$('divContenido').insert({ top: strHTML })
						  $tbContenido.show()
						}
				  }


					/***  Elimina la referencia seleccionada  ***/  
                    function referencia_eliminar(nro_ref) { 
                        var permisoOperadorRef = fw.tienePermiso('permisos_referencias', 2)  && ref_eliminar=='1'
                        if( permisoOperadorRef
                            || fw.tienePermiso('permisos_referencias', 7)){
                        
 
					        fw.confirm('�Desea eliminar esta referencia?', {
                                width: 300, 
                                onOk: function(win) {
                                    RefEliminar(nro_ref);
                                    win.close();
                                }, 
                                onCancel: function(win) {
                                    win.close();
                                }
                            });
                         }
                         
                         
                         else{
                            alert('No tiene permisos para realizar esta accion. Consulte con el administrador de sistema')
                         }
					}

					/*function RefEliminar(nro_ref) { 
                var rs = new tRS(),
                filtroXML = nvFW.pageContents.filtroRefEliminar,
                params = "<criterio><params nro_ref='" + nro_ref + "'/></criterio>"

                rs.open(filtroXML, '', '', '', params)

                if (!rs.eof()) {
                    if (rs.getdata('nro_ref') > 0) {
                        ObtenerVentana('divMenu_content').location.href = '/wiki/ref_tree.aspx'
                        ObtenerVentana('frame_ref').location.href = '/wiki/inicio.aspx'
                    }
                    else {
                        alert('No se pudo eliminar la referencia')
                    }
                }
					}*/
          
          
          function RefEliminar(nro_ref) { 
              
              var strXML = "<?xml version='1.0' encoding='iso-8859-1'?>"
              strXML += "<referencia nro_ref='-" + nro_ref + "'></referencia>"
              nvFW.error_ajax_request('/wiki/referencias_abm.aspx', {
                    bloq_msg: 'Guardando...',
                    parameters: {
                        modo: 'M',
                        strXML: strXML
                    },
                    onSuccess: function (err, transport) {
                        ObtenerVentana('divMenu_content').location.href = '/wiki/ref_tree.aspx'
                        ObtenerVentana('frame_ref').location.href = '/wiki/inicio.aspx'
                    }
                });
					}
          
          
          

					/*function grupo_onclick(nro_ref_doc_tipo)
					{
						var tr = $('trTipo' + nro_ref_doc_tipo)
						var img = $('imgTipo' + nro_ref_doc_tipo)
						    
                        if (!tr.visible())
						{
							img.src = '/fw/image/tMenu/menos.gif'
							tr.show()
                        }
						else 
						{
							img.src = '/fw/image/tMenu/mas.gif'
							tr.hide()
						}
					}*/
                    
     
                    
                    ]]>
                    </xsl:comment>
                </script>
                <style>
                    div.menu_ref {
                        width: 100%;
                        border: none;
                        border-bottom: 1px solid #FFFFFF;
                    }
                    div.menu_ref tr td {
                        background: #707070;
                        color: white;
                        border: none;
                    }
                    #vMenu_img20, #vMenu_img21 {
                        display: none;
                    }
                </style>
            </head>

            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">                
                <xsl:if test="foo:renderPage(string(xml/rs:data/z:row/@nro_ref))">
                    <div id="tdMenuDatosRefIzq" class="menu_ref" style="padding: 0;"></div>
                    <table id="tb_titulo" cellspacing="0" style="width: 100%; overflow:auto;" class="tb1">
                        <tr>
                            <td class="tit1" style="width: 100%; padding: 3px; text-align:center; font-size: 1.5em !important;">
                                <xsl:value-of select="xml/rs:data/z:row/@referencia"/>.
                                <span class="ref_titulo_sub">Ref. <xsl:value-of select="xml/rs:data/z:row/@nro_ref"/></span>
                            </td>
                        </tr>
                    </table>

                    <script type="text/javascript">
                        <xsl:comment>
                        var nro_ref = '<xsl:value-of select="xml/rs:data/z:row/@nro_ref"></xsl:value-of >';
                        <![CDATA[
                        var vMenu = new tMenu('tdMenuDatosRefIzq', 'vMenu');
                        vMenu.alineacion = 'izquierda';
                        vMenu.estilo = 'A ';
                        vMenu.loadImage("editar_lapiz", "/fw/image/icons/editar.png")
                        vMenu.loadImage("favorito_si", "/wiki/image/icons/favorito_si.png")
                        vMenu.loadImage("favorito_no", "/wiki/image/icons/favorito_no.png")
                        vMenu.loadImage("application_xml", "/wiki/image/icons/application_xml.png")
                        vMenu.loadImage("content", "/wiki/image/icons/content.png")
                        vMenu.loadImage("version", "/wiki/image/icons/version.png")
                        vMenu.loadImage("pixel_transparente", "/wiki/image/icons/pixel_transparente.png")
                        vMenu.loadImage("pdf", "/fw/image/filetype/pdf.png")
                        vMenu.loadImage("permiso", "/fw/image/icons/permiso.png")
                        vMenu.loadImage("eliminar", "/fw/image/icons/eliminar.png")

                        var xml_menu_filename = 'ref_mnu_int'
                        var DocumentMNG = new tDMOffLine;
                        DocumentMNG.APP_PATH = window.location.href;
                        var path_xml_menu_file = '/wiki/DocMNG/Data/' + xml_menu_filename + '.xml'
                        //var menuXmlIzq = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', 'ref_mnu_int');
                        var menuXmlIzq = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', path_xml_menu_file);
                        
                        vMenu.CargarXML(menuXmlIzq);
                        vMenu.MostrarMenu();
                        ]]>
                        </xsl:comment>
                    </script>
                    <div id="tb_body" style="width:100%; overflow: auto; height: 100%;">
                        <div id="divVersiones"></div>	
                        <table id="tbContenido" style="display:none">
                            <tr>
                                <td style="text-align: center; ">
                                    <b>Contenido</b>
                                </td>
                            </tr>
                            <tr>
                                <td id="divContenido" ></td>
                            </tr>
                        </table>
                        <xsl:apply-templates select="xml/rs:data/z:row" mode="tipo" />
                    </div>
                </xsl:if>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="z:row" mode="tipo">
        <xsl:variable name="nro_ref_doc_tipo" select="@nro_ref_doc_tipo"/>
        <xsl:if test="foo:grupo_tipo_cambio(string(@ref_nro_tipo_doc))">
            <table class="doc_tb" style="width: 100%; overflow:auto;">
                <tr>
                    <td>
                        <xsl:apply-templates select="/xml/rs:data/z:row[@nro_ref_doc_tipo >= $nro_ref_doc_tipo and @nro_ref_estado != 2]" mode="docs" />
                    </td>
                </tr>
            </table>
            <div name="ref_dependencia" id="ref_dependencia" style="width:100%"></div>
        </xsl:if>
    </xsl:template>  
  
    <xsl:template match="z:row" mode="docs">
        <xsl:variable name="nro_ref_doc" select="@nro_ref_doc"/>
        <xsl:if test="foo:grupo_doc_cambio(string(@nro_ref_doc))">
            <table class="tbDoc_cab" style="width: 100%;">
                <tr nowrap="true">
                    <td onmouseover="MO(event)" onmouseout="MU(event)" style='width:17px; vertical-align:middle' rowspan="2">
                        <img src='/fw/image/tMenu/menos.gif' border='0' align='absmiddle' hspace='0'>
                            <xsl:attribute name="id">imgDocu<xsl:value-of select="@nro_ref_doc"/></xsl:attribute>
                            <xsl:attribute name='onclick'>return docu_onclick(<xsl:value-of select="@nro_ref_doc"/>)</xsl:attribute>
                        </img>
                    </td>
                    <td style="text-align:left; vertical-align:middle" rowspan="2">
                        <span class="ref_doc_titulo">
                            <xsl:value-of select="@ref_doc_titulo"/>
                        </span>
                    </td>
                    <td style="text-align:right; vertical-align:bottom; font-size:13px;">
                        <span>
                            <xsl:attribute name="id">sp_ver<xsl:value-of select='@nro_ref_doc'/></xsl:attribute>
                        </span>
                        <script type="text/javascript" language="javascript">
                            <xsl:comment>
                                get_version_list(<xsl:value-of select="@nro_ref_doc"/>, 1)
                            </xsl:comment>
                        </script>
                        <a>
                            <img src='/fw/image/icons/operador.png' border='0' align='absmiddle' hspace='2' >
                                <xsl:attribute name='onclick'>
                                    versiones_doc_onclick(<xsl:value-of select="@nro_ref"/>, <xsl:value-of select="@nro_ref_doc"/>)
                                </xsl:attribute>
                            </img>
                        </a>
                        <b>
                            <xsl:value-of select="@doc_operador"/>
                        </b>
                        &#x00A0;
                        <span>
                            <xsl:value-of select="foo:conv_fecha_to_str(string(@ref_doc_fe_estado), 'dd/mm/aa hh:mm:ss')"/>
                        </span>
                    </td>
                </tr>
            </table>
            <table style="width:100%; ">
                <tr nowrap="true">
                    <xsl:attribute name="id">trDocu<xsl:value-of select="@nro_ref_doc"/></xsl:attribute>
                    <td style='width: 17px;'></td>
                    <td>
                        <div>
                            <xsl:attribute name='id'>divDOC<xsl:value-of select='@id_ref_doc'/></xsl:attribute>
                        </div>
                        <script type="text/javascript" language="javascript">
                            <xsl:comment>
                                var id_ref_doc = '<xsl:value-of select='@id_ref_doc'/>',
                                    divID = 'divDOC' + id_ref_doc;

                                nvFW.insertFileInto(id_ref_doc, divID)
                            </xsl:comment>
                        </script>
                    </td>
                </tr>
            </table>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>