   /*******************************************/
   // Cargar librerías obligatorias para el nvFW
   /*******************************************/
   nvFW_chargeJSifNotExist("tnvCache", '/FW/script/tnvCache.js')
   

   /*******************************************/
   // Instanaciar nvFW
   /*******************************************/
   var nvFW = tnvFrameWork()
   if (!window.top.nvFW) window.top.nvFW = nvFW

   
   
   
   /*******************************************/
   // Cargar librerías obligatorias
   /*******************************************/
   nvFW.chargeJSifNotExist("", '/FW/script/prototype.js')
   nvFW.chargeJSifNotExist("", '/FW/script/nvUtiles.js')
   nvFW.chargeJSifNotExist("", '/FW/script/tXML.js')
   //nvFW_chargeJSifNotExist("", '/FW/script/tnvBrowserLog.js')

   
  function tnvBrowserLog()
     { 
     nvFW_chargeJSifNotExist("", '/FW/script/tnvBrowserLog.js')
     return new tnvBrowserLog()
     }   
   //nvFW.nvPageID = GetCookie("nvPageID")

    var HabilitarSession = true
    try
        {
        HabilitarSession = _nvFW_Page_tSession
        }
    catch(ex){}
    if (HabilitarSession)
        nvFW.chargeJSifNotExist("tSesion", '/FW/script/tSesion.js', true) 

   Event.observe(document, 'click', nvFW_window_click)
   Event.observe(document, 'keydown', nvFW_window_keydown)
   Event.observe(document, 'contextmenu', nvFW_window_contextMenu)
   
   //Desabilitar el drop hacia la aplicación
   document.ondragover =  function(e)
                          {
                          if (e.dataTransfer.dropEffect != "copy")
                            e.dataTransfer.dropEffect = "none"
                          return false 
                          } 
   document.ondrop = function (e) { e.preventDefault(); return false; };
//   Event.observe(window, 'load', function () 
//                                    {
//                                    var HabilitarSession = true
//                                    try
//                                      {
//                                      HabilitarSession = _nvFW_Page_tSession
//                                      }
//                                    catch(ex){}
//                                    if (HabilitarSession)
//                                       nvFW.chargeJSifNotExist("tSesion", '/FW/script/tSesion.js', true) 
//                                    })
// Event.observe(window, 'unload', function() 
//                                 {
//                                 var nvPageID = nvFW.nvPageID
//                                 if (!nvPageID)
//                                    nvPageID = window.nvPageID
//                                 
//                                 if (nvPageID != undefined)    
//                                    {
//                                    var oXML = new tXML();
//                                    oXML.async = true
//                                    oXML.load("/FW/getSessionXML.aspx?accion=page_close&criterio=" + nvPageID)
//                                    }
//                                 }) 
 function tnvFrameWork()
	    {
	    this.nvPageID = null;
	    this.formExportar = null;
	    this.formMostrar = null;
	    this.formTransf = null;
	    this.formDTSX = null;
	    this.cache = new tnvCache();
	    this.reporte_parametro = new Array();
	    this.exportarReporte = nvFW_exportarReporte;
	    this.mostrarReporte = nvFW_mostrarReporte;
	    this.reporte_ejecutar = nvFW_reporte_ejecutar;
	    this.transferenciaEjecutar = nvFW_transferenciaEjecutar;
	    this.ejecutarDTSX = nvFW_ejecutarDTSX;
	    this.getFile = nvFW_getFile;
	    this.insertFileInto = nvFW_insertFileInto;
	    this.insertFile = nvFW_insertFile;
	    this.getXML = nvFW_getXML;
      this.createFORM = nvFW_createFORM;
      this.createWindow = nvFW_createWindow;
      this.bloqueo_activar = nvFW_bloqueo_activar;
      this.bloqueo_desactivar = nvFW_bloqueo_desactivar;
      this.error_ajax_request = nvFW_error_ajax_request;
      this.chargeJSifNotExist = nvFW_chargeJSifNotExist;
      this.chargeCSS = nvFW_chargeCSS;
      this.globalEval = nvFW_globalEval;
      this.selection_clear = nvFW_selection_clear;
      this.getWidthOfText =  nvFW_getWidthOfText;  
      this.tienePermiso = nvFW_tienePermiso;
      this.file_dialog_show = nvFW_file_dialog_show;
      this.enableDropFile = nvFW_enableDropFile;
      
      //Funciones del Dialog
      this.browser_alert = alert;
      this.browser_confirm = confirm;
      this.alert = nvFW_alert;
      this.confirm = nvFW_confirm;

      //Si hay un nvFW en el top tira el log a ese
      this.brLog = window.top.nvFW != undefined ? window.top.nvFW.brLog : new tnvBrowserLog()
      
      this.getMyWindowId =  function ()
                              {
                              var reg = new RegExp("_content$")
                              var id = ''
                              
                              if (reg.test(window.name))
                                id = window.name.replace(reg, '')
                                
                              return id  
                              }
  
      this.getMyWindow = function (src)
                          {
                          if (src == undefined)
                            src = parent
                          return src.Windows.getWindow(getMyWindowId())
                          }
  
      
      //Dialogs
      this.file_dialog = nvFW_file_dialog;
      
      this.abrir_sistema = nvFW_abrir_sistema; //Abre el sistema en otra ventana transfiriendo el login
      this.get_hash = nvFW_get_hash;
    
      /*******************************************/
      //Cotrol de eventos de usuario
      /*******************************************/
      //Mouse
      this.window_contextMenu = true //Habilita o desabilita los menus contextuales del browser
      this.window_click_left = null;
      this.window_click_middle = null;
      this.window_click_right = null;

      
      //Teclado
      //Desabilitar teclas
      this.enterToTab = true
      this.window_key_disable = {}
      this.window_key_disable['116'] = true        //F5
      this.window_key_disable['CTRL+116'] = true   //CTRL+F5
      this.window_key_disable['CTRL+82'] = true    //CTRL+R
      this.window_key_disable['CTRL+SHIFT+76'] = true    //CTRL+SHIFT+L
      this.window_key_disable['CTRL+SHIFT+82'] = true    //CTRL+SHIFT+R
      
      
      //Asignar funciones a una combinación de teclas
      //Controla que acciones de key_action estan disponibles
      this.window_key_action = {}
	    this.window_key_action['CTRL+SHIFT+76'] = function (e) //CTRL+SHIFT+L ---> Limpiar caches
                                                    {
                                                    var _nvFW = window.top.nvFW
                                                    if (!_nvFW)
                                                      _nvFW = nvFW
                                                    _nvFW.cache.clear() 
                                                    } 
	    this.window_key_action['CTRL+SHIFT+82'] = function (e) //CTRL+SHIFT+R ---> Limpiar caches de tRS
                                                    {
                                                    var _nvFW = window.top.nvFW
                                                    if (!_nvFW)
                                                       _nvFW = nvFW
                                                    _nvFW.cache.clear('tRS') 
                                                    } 
      
      
      this.path = {}
      this.path.exportarReporte = '/FW/reportViewer/exportarReporte.aspx'
      this.path.mostrarReporte = '/FW/reportViewer/mostrarReporte.aspx'
      this.path.getFile = '/FW/reportViewer/getFile.aspx'
      this.path.getXML = '/FW/getXML.aspx'
      this.path.transferenciaEjutar = '/FW/transferencia/transf_ejecutar.aspx'
      this.path.ejecutarDTSX = '/FW/ejecutarDTSX.aspx'
      this.path.nv_login = '/FW/nvlogin.aspx'
      this.path.getBinary = '/FW/reportViewer/getBinary.aspx'
      
      return this
      }
 

function nvFW_getWidthOfText(txt, fontname, fontsize)
     {
     var body = $$("BODY")[0]
     if (!fontname) fontname = window.getComputedStyle(body, null).getPropertyValue('font-family')
     if (!fontsize) fontsize = window.getComputedStyle(body, null).getPropertyValue('font-size')
     var c=document.createElement('canvas');
     var ctx=c.getContext('2d');
     ctx.font = fontsize + " " +  fontname;
     var length = ctx.measureText(txt).width;
     return length;
     }


function nvFW_alert(msg, options)
  {
  msg = msg.toString()
  if (!window.Dialog)  nvFW.chargeJSifNotExist("", '/FW/script/nvFW_windows.js')
      
  if (options == undefined) options = {}
  //if (!options.width)
  //  {
  //  var maxWidth = $$("BODY")[0].getWidth() - 40
  //  if (maxWidth > 800) maxWidth = 800

  //  var calcWidth = getWidthOfText(msg) + 20
  //  if (calcWidth > maxWidth) calcWidth = maxWidth
  //  }
  if (!options.className)  options.className = "alphacube"
  //if (!options.width)  options.width = 400
  if (!options.height)  options.height = 100
  if (!options.okLabel)  options.okLabel = 'Cerrar'
  return Dialog.alert(msg, options)
  }

function nvFW_confirm(msg, options)
  {
  if (!window.Dialog)  nvFW.chargeJSifNotExist("", '/FW/script/nvFW_windows.js')

  if (options == undefined) options = {}
  //if (!options.width)
  //  {
  //  var maxWidth = $$("BODY")[0].getWidth() - 40
  //  if (maxWidth > 800) maxWidth = 800

  //  var calcWidth = getWidthOfText(msg) + 20
  //  if (calcWidth > maxWidth) calcWidth = maxWidth
  //  }
  if (!options.className)  options.className = "alphacube"
  //if (!options.width)  options.width = 400
  if (!options.height)  options.height = 100
  if (!options.okLabel)  options.okLabel = 'Si'
  if (!options.cancelLabel)  options.cancelLabel = 'No'
  return Dialog.confirm(msg, options)
  }

function nvFW_abrir_sistema(sistema, ventana) 
  {
    if (ventana == undefined)
        ventana = "win_" + ((Math.random() * 1000).floor())
    var oXML = new tXML()
    oXML.async = false
    if (oXML.load(this.path.nv_login, "accion=get_hash")) {
        var hash = XMLText(oXML.selectSingleNode("/error_mensajes/error_mensaje/comentario"))
    }
    eval("ventana = window.open('/' + sistema + '/default.asp?nv_hash=' + hash, ventana)")
 }

 function nvFW_get_hash()
   {
    var oXML = new tXML()
    oXML.async = false
    if (oXML.load(this.path.nv_login, "accion=get_hash"))
      { 
      var er = new tError()
      er.error_from_xml(oXML)   
      return er.params["hash"]
      }
     return null
   }  
   
    //enctype="multipart/form-data"					  
    function nvFW_createFORM(tipo, formTarget, enctype)
	  {
	  if (!enctype)
	    enctype = ''
      if (!tipo)
        tipo = 'EXP'
      
      tipo = tipo.toUpperCase()
        
      var action = ''
      var id = ''
      switch (tipo)  
        {
        case 'EXP': 
          action = this.path.exportarReporte
          id = 'frmExportar'
          break
          
        case 'INF': 
          action = this.path.mostrarReporte
          id = 'frmMostrar'
          break
            
        case 'FILE': 
          action = this.path.getFile
          id = 'frmFile'
          break  
          
        case 'TRAN': 
          action = this.path.transferenciaEjutar
          id = 'frmTran'
          break    
        case 'DTSX': 
          action = this.path.ejecutarDTSX
          id = 'frmDTS'
          break    
        }
					  
      if (tipo == 'EXP' || tipo == 'INF' || tipo == 'FILE' || tipo == 'TRAN' || tipo == 'DTSX')
        {
        //var action = tipo == 'EXP' ? '../../../FW/reportViewer/exportarReporte.asp' : '../../../FW/reportViewer/mostrarReporte.asp'
        //var id =  tipo == 'EXP' ? 'frmExportar' : 'frmMostrar'
        id += (Math.random() * 1000).floor()
        
        var strEnctype = enctype != '' ?  " enctype='" + enctype + "' " : ''
        
        strHTML = "<form name='" + id + "' id='" + id + "' style='display: none' method='POST' action='" + action + "' target='" + formTarget + "' " + strEnctype + " >"
						
        strHTML += "<input type='hidden' name='VistaGuardada' value='' />"
        strHTML += "<input type='hidden' name='filtroXML' value='' />"
        strHTML += "<input type='hidden' name='filtroWhere' value='' />"
        strHTML += "<input type='hidden' name='params' value='' />"
        strHTML += "<input type='hidden' name='xml_data' value='' />" 
        strHTML += "<input type='hidden' name='xsl_name' value='' />"
        strHTML += "<input type='hidden' name='path_xsl' value='' />"
        strHTML += "<input type='hidden' name='report_name' value='' />"
        strHTML += "<input type='hidden' name='path_reporte' value='' />"
        strHTML += "<input type='hidden' name='parametros' value='' />"
        strHTML += "<input type='hidden' name='ContentType' value='' />"
        strHTML += "<input type='hidden' name='destinos' value='' />"
        strHTML += "<input type='hidden' name='salida_tipo' value='' />"
        strHTML += "<input type='hidden' name='mantener_origen' value='' />"
        strHTML += "<input type='hidden' name='id_exp_origen' value='' />"
        strHTML += "<input type='hidden' name='id_ref_doc' value='' />"
        strHTML += "<input type='hidden' name='id_transferencia' value='' />"
        strHTML += "<input type='hidden' name='xml_param' value='' />"
        strHTML += "<input type='hidden' name='pasada' value='' />"
        strHTML += "<input type='hidden' name='dtsx_path' value='' />"
        strHTML += "<input type='hidden' name='dtsx_parametros' value='' />"
        strHTML += "<input type='hidden' name='dtsx_exec' value='' />"
        strHTML += "<input type='hidden' name='timeout' value='' />"
        strHTML += "<input type='hidden' name='export_exeption' value='' />"
        strHTML += "<input type='hidden' name='filename' value='' />"
        strHTML += "<input type='hidden' name='winModalID' value='' />"
        strHTML += "<input type='hidden' name='ej_mostrar' value='' />" 
        strHTML += "<input type='hidden' name='content_disposition' value='' />" 
        
        
        strHTML += "</form>"
        }
      $$('BODY')[0].insert({top: strHTML})
      return $(id)
      }
    function nvFW_exportarReporte(parametros) 
		  {
		  this.reporte_ejecutar('EXP', parametros)
      }
    function nvFW_mostrarReporte(parametros) 
      {
      this.reporte_ejecutar('INF', parametros)
      }			    
      
    function nvFW_reporte_ejecutar(exp_tipo, parametros)
      {
      var nvFW_mantener_origen = !parametros.nvFW_mantener_origen ? false : parametros.nvFW_mantener_origen //Indica que se llevará registro de la llamada para reutilizarlo
      var id_exp_origen = !parametros.id_exp_origen ? 0 : parametros.id_exp_origen     //Identificar el nro con
      if (id_exp_origen > 0 && nvFW_mantener_origen)
        parametros = this.reporte_parametro[id_exp_origen]
      
      if (nvFW_mantener_origen == true)
        {
        if (id_exp_origen <= 0)
          id_exp_origen = this.reporte_parametro.size()+1
        this.reporte_parametro[id_exp_origen] = parametros
        }   
      
      var FORM = parametros.form //Formulario para submit
      var metodo = !parametros.metodo ? 'submit' : parametros.metodo //Metodo de ejecución submit o httprequest
      var async = !parametros.async ? false : parametros.async
      var winPrototype = !parametros.winPrototype ? null : parametros.winPrototype //opciones de ventana prorotype
      var funComplete = !parametros.funComplete ? null : parametros.funComplete //Función que se ejecuta al terminar
      var cls_contenedor = !parametros.cls_contenedor ? null : parametros.cls_contenedor //Limpiar contenedor
      var cls_contenedor_msg = !parametros.cls_contenedor_msg ? 'cargando...' : parametros.cls_contenedor_msg //Limpiar contenedor
      var bloq_contenedor = !parametros.bloq_contenedor ? null : $(parametros.bloq_contenedor) //bloquear contenedor
      var bloq_id = (Math.random() * 1000).floor()  //Privado
      
      
      var VistaGuardada = !parametros.VistaGuardada ? '' : parametros.VistaGuardada   //nombre de la vista guardada en WRP_config
      var filtroXML = !parametros.filtroXML ? '' : parametros.filtroXML               //Comando SQL en codificación XML
      var filtroWhere = !parametros.filtroWhere ? '' : parametros.filtroWhere         //Where anexo a los comandos anteriores
      var params = !parametros.params ? '' : parametros.params                        //Parametros modificadores de la consulta
      var xml_data = !parametros.xml_data ? '' : parametros.xml_data                  //Datos XML a plantillar  
			
	  //Parametros de exportar 
	  //Si xsl_name tiene valor se busca el archivo dentro de la carpeta de la vista.
      //Si no se busca la el archivo en la dirección indicada en path_xsl anexandole la carpeta de servidor
      var xsl_name = !parametros.xsl_name ? '' : parametros.xsl_name
      var path_xsl = !parametros.path_xsl ? '' : parametros.path_xsl
      var mantener_origen = !parametros.mantener_origen ? '' : parametros.mantener_origen //Indica que se llevará registro de la llamada para reutilizarlo
       
      var xml_parametros = !parametros.parametros ? '' : parametros.parametros

      //Parametros de mostrar 
      var report_name = !parametros.report_name ? '' : parametros.report_name
      var path_reporte = !parametros.path_reporte ? '' : parametros.path_reporte

			//Parametros de destino
      var ContentType = !parametros.ContentType ? !parametros.ContectType : parametros.ContentType         //Identifica ese valor en el flujo de salida
      if (ContentType == undefined)
        ContentType = ''
      var target = !parametros.target ? '' : parametros.target                   //Itenfifica donde será envíado el flujo de salida
      var destinos = !parametros.destinos ? '' : parametros.destinos             //Itenfifica donde será envíado el flujo de salida
      if (destinos == '')
        destinos = target
      var formTarget = !parametros.formTarget ? '' : parametros.formTarget
      var salida_tipo = !parametros.salida_tipo ? '' : parametros.salida_tipo    //Identifica si en la llamada será devuelto el resultado o un informe de resultado
      var timeout = !parametros.timeout ? '3000' : parametros.timeout
      var export_exeption = !parametros.export_exeption ? '' : parametros.export_exeption //Identifica el algoritomo de exportación "RSXMLtoExcel" | "TransformFromXSL"
      var filename = !parametros.filename ? '' : parametros.filename
      var content_disposition = !parametros.content_disposition ? 'attachment' : parametros.content_disposition

      
      //Limpiar contenedor
      if (cls_contenedor != null) 
        {
        var objC = $(cls_contenedor) 
        if (objC != null) 
          {
          if (objC.tagName == "IFRAME") //IFRAME
            objC.contentWindow.document.body.innerHTML = cls_contenedor_msg
          else
            objC.innerHTML = cls_contenedor_msg //Element
          }
        else 
          {
          var v = ObtenerVentana(cls_contenedor)
          if (v != null)
            v.document.body.innerHTML = cls_contenedor_msg //Window
          }  
        }
      
	  //Determinar metodo de ejecución
	  if (metodo.toLowerCase() == 'httprequest')
        {
        var strParam = "VistaGuardada=" + encodeURIComponent(VistaGuardada)
        strParam += "&filtroXML=" + encodeURIComponent(filtroXML)
        strParam += "&filtroWhere=" + encodeURIComponent(filtroWhere)
        strParam += "&params=" + encodeURIComponent(params)
        strParam += "&xml_data=" + encodeURIComponent(xml_data)
        strParam += "&ContentType=" + encodeURIComponent(ContentType)
        strParam += "&destinos=" + encodeURIComponent(destinos)
        strParam += "&salida_tipo=" + encodeURIComponent(salida_tipo)
        strParam += "&timeout=" + encodeURIComponent(timeout)
        strParam += "&filename=" + encodeURIComponent(filename)
        strParam += "&content_disposition=" + encodeURIComponent(content_disposition)
        if (xml_data != '')
          strParam += "&xml_data" + encodeURIComponent(xml_data)
        
        if (exp_tipo == "EXP") 
          {
          var URL = this.path.exportarReporte
          strParam += "&xsl_name=" + encodeURIComponent(xsl_name)
          strParam += "&path_xsl=" + encodeURIComponent(path_xsl)
          strParam += "&mantener_origen=" + encodeURIComponent(mantener_origen)
          strParam += "&id_exp_origen=" + encodeURIComponent(id_exp_origen)
          strParam += "&parametros=" + encodeURIComponent(xml_parametros)
          strParam += "&export_exeption=" + encodeURIComponent(export_exeption)
          }
        if (exp_tipo == "INF") 
          {
          var URL = this.path.mostrarReporte
          strParam += "&report_name=" + encodeURIComponent(report_name)
          strParam += "&path_reporte=" + encodeURIComponent(path_reporte)
          }
        var oXMLHttp = XMLHttpObject()
        
        var miOBJETO = this
        if (funComplete != null || bloq_contenedor != null)
          {
          oXMLHttp.onreadystatechange = function() {
            if (oXMLHttp.readyState == 4) {
                var parseError = XMLParseError(oXMLHttp.responseXML)
                if (bloq_contenedor != null)
                    miOBJETO.bloqueo_desactivar(bloq_contenedor, bloq_id)
                if (funComplete != null)    
                  funComplete(oXMLHttp, parseError)
            }
            };
          }  
        
        if (bloq_contenedor != null)
            this.bloqueo_activar(bloq_contenedor, bloq_id)
        oXMLHttp.open('POST', URL, async);
        oXMLHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        oXMLHttp.send(strParam)
        return false
        }
      else
        {
        if (exp_tipo == "EXP") 
          {
          FORM = nvFW_createFORM('EXP', formTarget)
          FORM.xsl_name.value = xsl_name
          FORM.path_xsl.value = path_xsl
          FORM.mantener_origen.value = mantener_origen
          FORM.id_exp_origen.value = id_exp_origen
          FORM.parametros.value = xml_parametros
          FORM.export_exeption.value = export_exeption
          FORM.xml_data.value = xml_data
          }
        if (exp_tipo == "INF")
          {
          FORM = nvFW_createFORM('INF', formTarget)
          FORM.report_name.value = report_name
          FORM.path_reporte.value = path_reporte
          }
        FORM.VistaGuardada.value = VistaGuardada
        FORM.filtroXML.value = filtroXML
        FORM.filtroWhere.value = filtroWhere
        FORM.xml_data.value = xml_data
        FORM.params.value = params
        FORM.content_disposition.value = content_disposition
        FORM.ContentType.value = ContentType
        FORM.destinos.value = destinos
        FORM.salida_tipo.value = salida_tipo
        FORM.filename.value = filename
        FORM.timeout.value = timeout
        
        var miOBJETO = this
        var es_winPrototype = formTarget == "winPrototype"
        if (es_winPrototype) 
          {
          //Valores por defecto
          if (winPrototype == null) winPrototype = {}
          if (winPrototype.bloquear == undefined) winPrototype.bloquear = true
          if (winPrototype.center == undefined) winPrototype.center = true
          if (winPrototype.modal == undefined) winPrototype.modal = true
          
          if (winPrototype.bloquear)
            {
            winPrototype.onShow = function(e)
                                        {
                                        miOBJETO.bloqueo_activar($(win.content.id), bloq_id)
                                        }
            }
          var win = this.createWindow(winPrototype);
          if (winPrototype.center)
            win.showCenter(winPrototype.modal)
          else
            win.show(winPrototype.modal)
          formTarget = win.content.name
          FORM.target = win.content.name
          bloq_contenedor = $(win.content.id)
          }

        
        if (funComplete != null || bloq_contenedor != null)
          {
          var a = $(formTarget)
          if (a == null)
            { 
            win = ObtenerVentana(formTarget)
            if (win != null)
              a = win.parent.$(formTarget)
            } 
//            if (a == null)
//              a = ObtenerVentana(formTarget)
            if (a != null && a.tagName.toUpperCase() == 'IFRAME')
                Event.observe(a, 'load', function load_func_iframe(e) {
                                              //limpiar evento onload
                                              var element = Event.element(e)
                                              Event.stopObserving(element, 'load')
                                              if (bloq_contenedor != null)
                                                miOBJETO.bloqueo_desactivar(bloq_contenedor, bloq_id)
                                              if (funComplete != null)      
                                                funComplete(e) 
                                              })

          }

          if (bloq_contenedor != null && !es_winPrototype)
            this.bloqueo_activar(bloq_contenedor, bloq_id)
        FORM.submit()
        }  
					  
      }
/*
    function nvFW_transferenciaEjecutar(parametros)
      {
      var FORM = parametros.form
      
      var id_transferencia = !parametros.id_transferencia ? '' : parametros.id_transferencia   
      var xml_param = !parametros.xml_param ? '' : parametros.xml_param        
      var pasada = !parametros.pasada ? '' : parametros.pasada    
		
				  
      var formTarget = !parametros.formTarget ? '' : parametros.formTarget
					  
	  //si no existe colocar el que esta creado
      if (!FORM)
        FORM = this.formTransf
      //Sino crearlo
      if (!FORM)	
        {
        FORM = nvFW_createFORM('TRAN', formTarget, "multipart/form-data")
        this.formTransf = FORM;
        }
      
      FORM.id_transferencia.value = id_transferencia
      FORM.xml_param.value = xml_param
      FORM.pasada.value = pasada
      
      if (formTarget == 'winModal')
        {
        var win = window.top.nvFW.createWindow({className: 'alphacube', 
                               url: 'enBlanco.htm',
						     title: '<b>Ejecutar transferencia</b>', 
			           minimizable: false,
			   	       maximizable: true,
				       	 draggable: true,
				             width: 1000, 
				            height: 500,
				         resizable: true,
				         destroyOnClose: true
				      });
		//win.setContent("<iframe name='iframe_01' id='iframe_01' style='width: 100%; height: 100%' src='enBlanco.html' ></iframe>", true, true)
		win.setZIndex(10000)
        win.showCenter(true)
        FORM.target = win.getContent().name
        
        }
					  
      FORM.submit()
					  
      }  
		*/
		
	function nvFW_transferenciaEjecutar(parametros)
      { 
      
      var FORM = parametros.form //Formulario para submit
      var ej_mostrar = !parametros.ej_mostrar ? 'False' : parametros.ej_mostrar
      var metodo = !parametros.metodo ? 'submit' : parametros.metodo //Metodo de ejecución submit o httprequest
      var async = !parametros.async ? false : parametros.async
      var winPrototype = !parametros.winPrototype ? null : parametros.winPrototype //opciones de ventana prorotype
      var funComplete = !parametros.funComplete ? null : parametros.funComplete //Función que se ejecuta al terminar
      var cls_contenedor = !parametros.cls_contenedor ? null : parametros.cls_contenedor //Limpiar contenedor
      var cls_contenedor_msg = !parametros.cls_contenedor_msg ? 'cargando...' : parametros.cls_contenedor_msg //Limpiar contenedor
      var bloq_contenedor = !parametros.bloq_contenedor ? null : $(parametros.bloq_contenedor) //bloquear contenedor
      var bloq_id = (Math.random() * 1000).floor()  //Privado
      var cod_sistema = !parametros.cod_sistema ? window.top.nvSesion.app_sistema : cod_sistema
      var nv_hash = !parametros.nv_hash ? "" : nv_hash
      
      //Transferencia
      var id_transferencia = !parametros.id_transferencia ? '' : parametros.id_transferencia   
      var xml_param = !parametros.xml_param ? '' : parametros.xml_param        
      var pasada = !parametros.pasada ? '' : parametros.pasada   
      
	  //Parametros de destino
      //var target = !parametros.target ? '' : parametros.target                   //Itenfifica donde será envíado el flujo de salida
      //var destinos = !parametros.destinos ? '' : parametros.destinos             //Itenfifica donde será envíado el flujo de salida
      //if (destinos == '')
        //destinos = target
      var formTarget = !parametros.formTarget ? '' : parametros.formTarget
      var salida_tipo = !parametros.salida_tipo ? '' : parametros.salida_tipo    //Identifica si en la llamada será devuelto el resultado o un informe de resultado
      
      //Limpiar contenedor
      if (cls_contenedor != null) 
        {
        var objC = $(cls_contenedor) 
        if (objC != null) 
          {
          if (objC.tagName == "IFRAME") //IFRAME
            objC.contentWindow.document.body.innerHTML = cls_contenedor_msg
          else
            objC.innerHTML = cls_contenedor_msg //Element
          }
        else 
          {
          var v = ObtenerVentana(cls_contenedor)
          if (v != null)
            v.document.body.innerHTML = cls_contenedor_msg//Window
          }  
        }
      
	  //Determinar metodo de ejecución
	  
	  if (metodo.toLowerCase() == 'httprequest')
        {
        var strParam = "?id_transferencia=" + encodeURIComponent(id_transferencia)
        strParam += "&xml_param=" + encodeURIComponent(xml_param)
        strParam += "&pasada=" + encodeURIComponent(pasada)
        strParam += "&salida_tipo=" + encodeURIComponent(salida_tipo)
        strParam += "&metodo=" + encodeURIComponent(metodo)
        strParam += "&ej_mostrar=" + encodeURIComponent(ej_mostrar)
        strParam += "&winModalID=" 
        
        
        var oXMLHttp = XMLHttpObject()
        var miOBJETO = this
        if (funComplete != null || bloq_contenedor != null)
          {
          oXMLHttp.onreadystatechange = function() {
            if (this.readyState == 4) {
                var parseError = XMLParseError(this.responseXML)
                if (bloq_contenedor != null)
                    miOBJETO.bloqueo_desactivar(bloq_contenedor, bloq_id)
                if (funComplete != null)    
                  funComplete(this, parseError)
            }
            };
          }  
        var URL = this.path.transferenciaEjutar
        if (bloq_contenedor != null)
            this.bloqueo_activar(bloq_contenedor, bloq_id)
        oXMLHttp.open('GET', URL + strParam, async);
        oXMLHttp.send(null)
        return false
        }
      else
        {
        FORM = nvFW_createFORM('TRAN', formTarget, "multipart/form-data")
        FORM.id_transferencia.value = id_transferencia
        FORM.ej_mostrar.value = ej_mostrar
        FORM.xml_param.value = xml_param
        FORM.pasada.value = pasada
        FORM.salida_tipo.value = salida_tipo
        FORM.winModalID.value = ''
        
        var miOBJETO = this
        var es_winPrototype = formTarget == "winPrototype"
        if (es_winPrototype) 
          {
          //Valores por defecto
          if (winPrototype == null) winPrototype = {}
          if (winPrototype.bloquear == undefined) winPrototype.bloquear = true
          if (winPrototype.center == undefined) winPrototype.center = true
          if (winPrototype.modal == undefined) winPrototype.modal = true
          
          if (winPrototype.bloquear)
            {
            winPrototype.onShow = function(e)
                                        {
                                        miOBJETO.bloqueo_activar($(win.content.id), bloq_id)
                                        }
            }
          var win = this.createWindow(winPrototype);
          
          if (winPrototype.center)
            win.showCenter(winPrototype.modal)
          else
            win.show(winPrototype.modal)
            
          formTarget = !win.content.name ? win.content.id : win.content.name
          FORM.target = !win.content.name ? win.content.id : win.content.name
          FORM.winModalID.value = win.getId()
          bloq_contenedor = $(win.content.id)
          }

        
        if (funComplete != null || bloq_contenedor != null)
          {
            var a = $(formTarget)
            if (a != null && a.tagName.toUpperCase() == 'IFRAME')
                Event.observe(a, 'load', function load_func_iframe(e) {
                                              //limpiar evento onload
                                              var element = Event.element(e)
                                              Event.stopObserving(element, 'load')
                                              
                                              if (bloq_contenedor != null)
                                                miOBJETO.bloqueo_desactivar(bloq_contenedor, bloq_id)
                                              if (funComplete != null)      
                                                funComplete(e) 
                                              })

          }

          if (bloq_contenedor != null && !es_winPrototype)
            this.bloqueo_activar(bloq_contenedor, bloq_id)
        FORM.submit()
        }  
					  
      }			  
	function nvFW_ejecutarDTSX(parametros)
      {
      
      var FORM = parametros.form
      
      var dtsx_path = !parametros.dtsx_path ? '' : parametros.dtsx_path   
      var dtsx_parametros = !parametros.dtsx_parametros ? '' : parametros.dtsx_parametros        
      var dtsx_exec = !parametros.dtsx_exec ? '' : parametros.dtsx_exec    
      var timeout = !parametros.timeout ? '3000' : parametros.timeout   
      
      var async = !parametros.async ? false : parametros.async
      var funComplete = !parametros.funComplete ? null : parametros.funComplete 
		
				  
      var formTarget = !parametros.formTarget ? '' : parametros.formTarget
      
	  if (async)
        {
        var strParam = "dtsx_path=" + escape(dtsx_path)
        strParam += "&dtsx_parametros=" + escape(dtsx_parametros)
        strParam += "&dtsx_exec=" + escape(dtsx_exec)
        strParam += "&timeout=" + escape(timeout)
        var oXML = new tXML()
        oXML.async = true        
        oXML.load(nvFW.path.ejecutarDTSX, strParam, funComplete)
        }
      else
        {				  
	    //si no existe colocar el que esta creado
        if (!FORM)
          FORM = this.formDTSX
        //Sino crearlo
        if (!FORM)	
          {
          FORM = nvFW_createFORM('DTSX', formTarget)
          this.formDTSX = FORM;
          }
       
        FORM.dtsx_path.value = dtsx_path
        FORM.dtsx_parametros.value = dtsx_parametros
        FORM.dtsx_exec.value = dtsx_exec
        FORM.timeout.value = timeout
        FORM.submit()
        }
					  
      }  
					  
    
      
    function nvFW_getFile(parametros)
      {
      var accion = !parametros.accion ? 'submit' : parametros.accion
      var type = !parametros.type ? 'REF' : 'OTROS'
        
      accion = accion.toLowerCase()
      if (accion != 'submit' && accion != 'return')
        accion = 'submit'

      var id_ref_doc = !parametros.id_ref_doc ? '' : parametros.id_ref_doc
      var vista = !parametros.vista ? 'ref_docs' : parametros.vista 
      
      var select = !parametros.select ? '' : parametros.select  
      
      if (accion == 'submit')
        {
        var FORM = parametros.form
        var formTarget = !parametros.formTarget ? '' : parametros.formTarget
      
	    //si no existe colocar el que esta creado
        if (!FORM)
          FORM = this.formExportar
        //Sino crearlo
        if (!FORM)	
          {
          FORM = nvFW_createFORM('FILE', formTarget)
          this.formExportar = FORM;
          }
        
        FORM.id_ref_doc.value = id_ref_doc
					  
        FORM.submit()
        }
      else
        {
        var res = null
        if(type == 'REF')
          {
            new Ajax.Request(this.path.getFile, {asynchronous: false,
                                                 parameters: { id_ref_doc: id_ref_doc, vista: vista },
                                                 onSuccess: function(transport)
                                                                             {
                                                                               res = transport.responseText
                                                                             }          
                                                 })
          }                                       
        else
          {
            new Ajax.Request(this.path.getBinary, {asynchronous: false,
                                                   parameters: { select: select},
                                                   onSuccess: function(transport)
                                                                                {
                                                                                  res = transport.responseText
                                                                                }          
                                                 })  
          }                                         
        return res                                                                                                                                                                  
        }  
      }
      
    function nvFW_getXML(accion, criterio, async, funComplete)
      {
      if (funComplete == undefined) 
        funComplete = null
      if (async == undefined) 
        async = false
      if (criterio == undefined) 
        criterio = ''
      var oXML = new tXML()
      oXML.async = async
      var res 
      var parametros = "accion=" + accion + "&criterio=" + criterio
      res = oXML.load(this.path.getXML, parametros, funComplete)
      if (res)
        return oXML
      else
        return null
      }
	  
    function nvFW_insertFileInto(pid_ref_doc, container,vista) {
      var id_ref_doc = !pid_ref_doc ? this.id_ref_doc : pid_ref_doc
      var vista = !vista ? 'ref_docs' : vista
      new Ajax.Updater(container, this.path.getFile + '?id_ref_doc=' + id_ref_doc + '&vista=' + vista);
      }
      
    function nvFW_insertFile(pid_ref_doc, container, position,vista)
      {
      var id_ref_doc = !pid_ref_doc ? this.id_ref_doc : pid_ref_doc
      var vista = !vista ? 'ref_docs' : vista
      new Ajax.Request(this.path.getFile + '?vista=' + vista + '&id_ref_doc=' + id_ref_doc, { async: true,
                                                                         method: 'get',
                                                                         onSuccess: function(transport)
                                                                                        {
                                                                                        switch (position.toUpperCase())
                                                                                        {
                                                                                            case 'after':
                                                                                                $(container).insert({after:transport.responseText})
                                                                                            break    
                                                                                            case 'before':
                                                                                                $(container).insert({before:transport.responseText})
                                                                                            break    
                                                                                            case 'bottom':
                                                                                                $(container).insert({bottom:transport.responseText})
                                                                                            break    
                                                                                            default:                                                
                                                                                                $(container).insert({top:transport.responseText})                                                                                                                                                                                                                                                    
                                                                                        }                                                                                            
                                                                                        } 
                      }) 
     
      }   
      
    function nvFW_createWindow(parametros)
      {
      if (!parametros) parametros = {}
      parametros.className = "alphacube"
      var win = new Window(parametros);
      return win				      
      }

    function nvFW_bloqueo_resize(contenedor, id)
      {
      var objC = $(contenedor) //objeto contenedor
      var oDiv = $("divBloq_" + id)
      if (objC != null && oDiv != null)
        {
        $(oDiv).clonePosition(objC)
        }
      }
    function nvFW_bloqueo_activar(contenedor, id) 
      {
      var objC = $(contenedor) //objeto contenedor
      var doc = document // documento contenedor
      var oDiv = doc.createElement("DIV")
      oDiv.setAttribute("id", "divBloq_" + id)
      //oDiv.style.background = "#d6d3d3 url('/fw/image/icons/spinner24x24_azul.gif') no-repeat 50% 50%"
      $(oDiv).addClassName("overlay_bloqueo")
      //oDiv.style.background = "#FDFDFD url('../../FW/image/icons/spinner.gif') no-repeat 50% 50%"
      //oDiv.style.border = "solid #A9CDEE 2px"
      oDiv.style.position = "absolute"
      oDiv.style.styleFloat = "left"
      oDiv.style.zIndex = objC.style.zIndex + 100
      
      //oDiv.style.width = "100%"
      //oDiv.style.height = "100%"
      //oDiv.style.top = "0"
      //oDiv.style.left = "0"
      try 
        {
        $(oDiv).setOpacity(0.5)
        }
      catch (e) 
        {
        oDiv.style.opacity = 0.5
        }
      doc.body.appendChild(oDiv)
      $(oDiv).clonePosition(objC)


      $(oDiv)._eventResize =  function () {nvFW_bloqueo_resize(contenedor, id)} 

      Event.observe(window, "resize", $(oDiv)._eventResize)
      //window.onresize = function () {
      //                 debugger
      //                 nvFW_bloqueo_resize()
      //                 } 
                       
  }
      
      function nvFW_bloqueo_desactivar(contenedor, id) {
          var objC = contenedor //objeto contenedor
          var doc = document // documento contenedor
          var oDiv = document.getElementById("divBloq_" + id)
          if (oDiv == null) oDiv = $("divBloq_" + id) 

          if (oDiv != null) 
              {
              oDiv.id = ""
              oDiv.style.display = 'none'
              Event.stopObserving(window, "resize", $(oDiv)._eventResize)
              }
            //oDiv.parentNode.removeChild(oDiv)
          //$$("BODY")[0].stopObserving("resize", "nvFW_bloqueo_resize('" + contenedor + "', '" + id + "')")
          //window.onresize = null

          



      }

function nvFW_error_ajax_request(url, options)
  {
  var er = new tError()
  er.Ajax_request(url, options)
  return er
  }
//Captura el evento click de la pagina
function nvFW_window_click(e)
  {
  var func = null
  switch (e.button)
    {
    case 0:
      func = nvFW.window_click_left
      break;
    case 1:
      func = nvFW.window_click_middle
      break;
    //case 2: //Sejecuta por contextMenu
    //  func = nvFW.window_click_right
    //  break;
    }
      
  if (func != null)
    func(e)
  }

function nvFW_window_contextMenu(e)
  {
  if (nvFW.window_click_right != null )
    nvFW.window_click_right(e)

  if (!nvFW.window_contextMenu)
    e.preventDefault();
  }

  //Habilita el drop hacia el elemento
  function nvFW_enableDropFile(element, cssClassOver, onDrop)
     {
      element._cssClassOver = cssClassOver
      element._onDropSuccess = onDrop
      element.ondragover = function (e) 
                                   { 
                                   //$("divDebug").innerHTML += "dropContainer.ondragover(" + e.dataTransfer.dropEffect + ") <br>"
                                   $(this).addClassName(cssClassOver); 
                                   e.dataTransfer.dropEffect = "copy";  
                                   e.preventDefault()
                                   return false; 
                                   };
     element.ondragleave = function () { $(this).removeClassName(element._cssClassOver); return false; };
     element.ondragend = function () { $(this).removeClassName(element._cssClassOver); return false; };
     element.ondrop = function(evt) 
                               {
                               $(this).removeClassName(element._cssClassOver)
                               evt.preventDefault();
                               element._onDropSuccess(evt)
                               };  
     }


function nvFW_file_dialog(accion, options)
  {
//  if (!accion)
//    accion = 'seleccionar'
//  
//  var onClose = typeof(options.onClose) == 'function' ? options.onClose : null
//  var links = !links  ? {} : links
//  var vista = !vista  ? 'detalle' : vista
//  
//  this.nvFW_createWindow()
//  
//  
  
  }  
  
function nvFW_window_keydown(e)
  {

  var evt = !window.event ? e : window.event
  //var tecla = !window.event ? evt.which : evt.keyCode
  var tecla = !evt.keyCode ? evt.which : evt.keyCode
  var isShiftPressed = evt.shiftKey==1
  var isCtrlPressed = evt.ctrlKey==1
  var isAltPressed = evt.altKey==1
  var strConv = isAltPressed ? 'ALT+' : ''
  strConv += isCtrlPressed ? 'CTRL+' : ''
  strConv += isShiftPressed ? 'SHIFT+' : ''
  strConv += tecla.toString()

  //Función enterToTab
  if (strConv == '13'&& nvFW.enterToTab)
     {
     var focusElement = Event.element(e)
     var elements = $$("input[type=text], input[type=radio], input[type=date], input[type=number], input[type=password],input[type=checkbox], TEXTAREA, SELECT")
     if (elements.length > 0)
       {
       var nextElement =  elements[0]
       for1:
       for (var i=0;i<elements.length-1;i++)
         {
         if (elements[i] === focusElement)
           for (j=i+1;j<elements.length;j++) //Busca el próximo que esté visible y no desabilitado
             if (!elements[j].disabled && elements[j].offsetParent != null)
               {
               nextElement = elements[j]
               break for1;
               }
         }
       $(nextElement).focus()
       }
     
      
     //$("[tabindex='"+($(this).attr("tabindex")+1)+"']").focus();
     //var nextEl = el.form.elements[el.tabIndex+1];
     }
  //$$('BODY')[0].insertAdjacentHTML('beforeend',';' + strConv)
  //if (strConv == "CTRL+65")
  //   debugger
  
  /***************************/
  // window_key_function
  // Procesar la función asignada a la combinación de teclas
  /***************************/
  if (typeof(nvFW.window_key_action[strConv]) == 'function')
    nvFW.window_key_action[strConv](e)

  //Cancelar pulsación de tecla
  if (!!nvFW.window_key_disable[strConv])
    {
    evt.cancelBubble = true
    if (!document.all)
      {
      e.stopPropagation()
      e.preventDefault()
      } 
    else  
      evt.keyCode = 0  
    return false  
    }    
  
  return true
  
  ///**************************/  
  ////  Funciones de framework
  ///**************************/  
  //if (nvFW.window_key_action[strConv])
  //  switch (strConv)
  //    {
  //    case 'CTRL+SHIFT+76': //CTRL+SHIFT+L ---> Limpiar caches
  //      var _nvFW = window.top.nvFW
  //      if (!_nvFW)
  //        _nvFW = nvFW
  //      _nvFW.cache.clear()
  //      break
      
  //    case 'CTRL+SHIFT+82': //CTRL+SHIFT+R ---> Limpiar caches de tRS
  //      var _nvFW = window.top.nvFW
  //      if (!_nvFW)
  //        _nvFW = nvFW
  //      _nvFW.cache.clear('tRS')  
  //      break  
  //    }
  }  
  
function nvFW_chargeJSifNotExist(strObject, jsURL, async, onComplete, forceCarge)
   {
   if (forceCarge == undefined) 
     forceCarge = false
   if (strObject == "")
     strObject = "CualquierCosaQueNoSeaObjeto"

   if (!onComplete)
     onComplete = null
    
   if (async == undefined)
     async = false

   var objetoEncontrado
   var r
   try 
     {
     //Evaluar si existe el objeto
     r = eval(strObject)
     objetoEncontrado = true
     }
   catch (e) 
     {
     objetoEncontrado = false
     }
   if (!objetoEncontrado || forceCarge)
     {
     var strObjOriginal
     if (objetoEncontrado)
       strObjOriginal = r.toString()
     //Carga asincrona 
     if (async)
       {
       var head = document.getElementsByTagName('head')[0];
       var script = document.createElement('script');
       script.type = 'text/javascript';
       if (onComplete != null)
         {
         script.onreadystatechange = function () 
                                    {
                                    if (this.readyState == 'loaded') onComplete();
                                    }
         script.onload = onComplete;
         }
       script.src = jsURL;
       head.appendChild(script);
       }
     else
       {
       var code
       if (!window.top._xhr_cache)  window.top._xhr_cache = {}
       if (!window.top._xhr_cache[jsURL])
         {
         var xmlHttp 
         try
          {
          xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
          }
        catch (e)
           {
          xmlHttp=new XMLHttpRequest(); // Firefox, Opera 8.0+, Safari       
          }
         try
           {
           xmlHttp.open("GET", jsURL, false)
           xmlHttp.send()
           code = xmlHttp.responseText
           window.top._xhr_cache[jsURL] = code
           }
         catch(e)
           {
           alert("No se puede cargar el archivo '" + jsURL + "'")
           return
           }
         }
     else
       code = window.top._xhr_cache[jsURL]
       
         var miEval
         if (!!window.execScript) 
             {
             miEval = window.execScript;
             } 
         else 
           miEval = nvFW_globalEval
//            if (navigator.userAgent.indexOf('AppleWebKit/') > -1)
//              {
//              miEval = function () { $$("head").first().insert(Object.extend(new Element("script", { type: "text/javascript" }), { text: code })); }
//              }
//            else 
//              miEval = nvFW_globalEval
         try
           {
           miEval(code)
           if (objetoEncontrado)
             {
             var r2 = eval(strObject)
             if (strObjOriginal == r2.toString())
               alert("Error al cargar el objeto")
             }
           }
         catch(ex)
           {
           alert("No se puede cargar el archivo '" + jsURL + "'.\n" + ex.toString())
           }
        
       }
     
     }
     
   }

function nvFW_tienePermiso(permiso_grupo, nro_permiso)
  {
  var permiso = 0
  try
    {
    permiso = this.permiso_grupos[permiso_grupo]
    }
  catch(ex){}

  return (permiso & Math.pow(2,nro_permiso-1)) > 0
  }

function nvFW_file_dialog_show(file_dialog_options, window_options)
  {
  //abrir_ventana_emergente('/fw/file_dialog/file_dialog.aspx?f_seleccionar=0','Explorador de Archivos','permisos_web',8,500,1000)
  if (!file_dialog_options) file_dialog_options = {}
  if (!window_options) window_options = {}
    
  var filters = file_dialog_options.filters
  var links =  file_dialog_options.links
  var view = !file_dialog_options.view ? "detalle" : file_dialog_options.view
  var modal = !window_options.modal ? true : window_options.modal
  var f_seleccionar = file_dialog_options.seleccionar == true ? "true" : "false"

  if (!filters)
    {
    filters = {}
    filters[0] = {}
    filters[0].titulo = "Todos los archivos"
    filters[0].filter = '*.*'
    filters[0].max_size = 0 // 1024 * 1024 * 20
    filters[0].inicio = true

    filters[1] = {}
    filters[1].titulo = "Archivos de imagen"
    filters[1].filter = '*.jpg|*.png|*.gif'
    filters[1].max_size = 1024 * 1024 * 20
    filters[1].inicio = false

    filters[2] = {}
    filters[2].titulo = "Archivos PDF"
    filters[2].filter = '*.pdf'
    filters[2].max_size = 1024 * 1024 * 20
    filters[2].inicio = false
    }
    
  if (!links)
    {
    links = {}
    links[0] = {}
    links[0].icon = 'disco32.png'
    links[0].f_id = 0
    links[0].titulo = "Todas las unidades"
    links[0].inicio = true
    }

  //var file_dialog =  {}
  file_dialog_options.links = links
  file_dialog_options.filters = filters
  file_dialog_options.view = view

  window_options.width = !window_options.width ? 1000 : window_options.width
  window_options.height = !window_options.height ? 500 : window_options.height
  window_options.title = !window_options.title ? '<b>Explorador de archivos</b>' : window_options.title
  window_options.file_dialog = file_dialog_options
  window_options.minimizable = false

  win = window.top.nvFW.createWindow(window_options)
  win.setURL("/fw/files/file_dialog.aspx?f_seleccionar=" + f_seleccionar)
  win.showCenter(modal)
  return win
  }

function nvFW_globalEval(data)
  {
  if (data && data != "")
    {
    // We use execScript on Internet Explorer
    // We use an anonymous function so that context is window
    // rather than jQuery in Firefox
    (window.execScript || function(data) 
       {
       window[ "eval" ].call( window, data );
       })(data);
    }
  }

 function nvFW_chargeCSS(cssURL) 
   {
   var head = document.getElementsByTagName('head')[0];
   var link = document.createElement('link');
   link.setAttribute("rel", "stylesheet");
   link.setAttribute("type", "text/css");
   link.setAttribute("href", cssURL);
   head.appendChild(link);
   }

function nvFW_selection_clear()
  {
  var sel = window.getSelection ? window.getSelection() : document.selection;
  if (sel) 
    {
    if (sel.removeAllRanges) 
      {
      sel.removeAllRanges();
      } 
    else if (sel.empty) 
      {
      sel.empty();
      }
    }
  }

   /*******************************************/
   // Librerías que se carga a demanda
   /*******************************************/
   function tError()
     { 
     nvFW.chargeJSifNotExist("", '/FW/script/tError.js')
     return new tError()
     }
   
   function tRS()
     { 
     nvFW.chargeJSifNotExist("", '/FW/script/tRS.js')
     return new tRS()
     }

  function FCKeditor(name)
     { 
     nvFW.chargeJSifNotExist("", '/FW/script/fckeditor/FCKeditor.js')
     return new FCKeditor(name)
     }


 


  
