
/* Devuelve si una cadena "dd/mm/yyyy" o
"d/m/yyyy" es una fecha válida */
function esFecha (strValue)
{
    if (!/^(((?:0?[1-9])|(?:[12]\d)|(?:3[01]))\/((?:0?[1-9])|(?:1[0-2]))\/((?:19|20|21|22)\d\d))$/.test(strValue))
        return false;
    else {
        return true;
    }
}

function tnvTargetWin() {

    this.base = window.top
    this.winMinWidth = 200
    this.height = 500
    this.width = 1000

    this.winMinOrder = ordenar_ventanas_minimizadas
    this.owopen = openWindow 
    this.owshow = openWindow_onShow 
    this.owmaximizar = openWindow_onMaximize 
    this.owminimizar = openWindow_onMinimize 
    this.indice_anterior = indice_anterior

    return this
}

function ordenar_ventanas_minimizadas()
{
     //debugger
    if (!this.base.$$) return false;

    //var contAncho = this.base.$$('BODY')[0].getWidth() - this.winMinWidth
    var contAncho = this.winMinWidth;

    try
    {
        contAncho = this.base.$$('BODY')[0].getWidth() - this.winMinWidth;
    } catch (e)
    {
        console.log(e);
    }

    var dif_top = 40
    var min_left = 1 

    var zindex = getMaxzIndex(this.base)
    var _windows =this.base.Windows.windows
    for (var i=0; i < _windows.length ; i++)
        { 
         // if(_windows[i].propiedades)
          // {
              //if(_windows[i].propiedades.minimized)
               //{ 
                  var indice_ant = this.indice_anterior(_windows[i].element.id)
                  if(i != indice_ant)
                     { 
                       if(contAncho < (_windows[indice_ant].propiedades.min_left + this.winMinWidth))
                         {
                          dif_top = 40 + dif_top
                          min_left = 1
                          _windows[i].propiedades.top_barra = dif_top
                         }
                        else
                         {
                          dif_top = _windows[indice_ant].propiedades.top_barra                                                     
                          min_left = _windows[indice_ant].propiedades.min_left + this.winMinWidth
                         } 
                     }
                       
                  min_top = this.base.$$('BODY')[0].getHeight() - dif_top 
                  
                  _windows[i].propiedades.top_barra = dif_top        
                  _windows[i].propiedades.min_top = min_top
                  _windows[i].propiedades.min_left = min_left
                  
                //  _windows[i].setLocation(min_top,min_left)
                  if (_windows[i].propiedades) { //Ordena aunque las ventanas esten abiertas
                      if (_windows[i].propiedades.minimized) { //Ordena aunque las ventanas esten abiertas
                          _windows[i].setLocation(min_top, min_left)
                       //   _windows[i].setZIndex(zindex+10)
                      }
                  }
             // } 
         // }    
        }

}

function indice_anterior(id)
{
   var indice_anterior = -1
   var _windows = this.base.Windows.windows
   for (var i=0; i < _windows.length ; i++)
   { 

       if(_windows[i].element.id == id)
         {
          indice_anterior = indice_anterior == -1 ? i : indice_anterior
          return indice_anterior
          }
       else  
          if (_windows[i].propiedades && _windows[i].propiedades.minimized === true)
              indice_anterior = i
   }   
   return indice_anterior
}

function openWindow_onShow(win) 
{

    var win_top = win.element.offsetTop
    var win_left = win.element.offsetLeft
    var min_left = 1
    var dif_top = 40

    //var contAncho = this.base.$$('BODY')[0].getWidth() - this.winMinWidth
    //var win_alto_full = this.height + 30

    var _windows = this.base.Windows.windows
    for (var i = 0; i < _windows.length; i++) {
        if (_windows[i].element.id == win.element.id) {

            _windows[i].propiedades = {}
            _windows[i].propiedades.height = win.height
            _windows[i].propiedades.width = win.width
            _windows[i].propiedades.parentWidthElement = win.options.parentWidthElement
            _windows[i].propiedades.parentHeightElement = win.options.parentHeightElement
            _windows[i].propiedades.parentWidthPercent = win.options.parentWidthPercent
            _windows[i].propiedades.parentHeightPercent = win.options.parentHeightPercent

            /*indice_ant = this.indice_anterior(win.element.id)

            if (indice_ant != i) {
                top_primero = _windows[indice_ant].propiedades.top_primero
                left_primero = _windows[indice_ant].propiedades.left_primero

                if ((_windows[indice_ant].propiedades.top + 20 + win_alto_full) >= this.base.$$('BODY')[0].getHeight()) {
                    win_top = top_primero
                    win_left = left_primero
                    top_primero = win_top
                    left_primero = win_left
                }
                else {
                    win_top = _windows[indice_ant].propiedades.top + 20
                    win_left = _windows[indice_ant].propiedades.left + 20
                }

                if (contAncho < (_windows[indice_ant].propiedades.min_left + this.winMinWidth)) {
                    min_left = 1
                    dif_top = 40 + _windows[indice_ant].propiedades.top_barra
                    _windows[i].propiedades.top_barra = dif_top
                }
                else {
                    dif_top = _windows[indice_ant].propiedades.top_barra
                    min_left = _windows[indice_ant].propiedades.min_left + this.winMinWidth
                }
            }
            else {
                top_primero = win_top
                left_primero = win_left
            }*/

            top_primero = win_top
            left_primero = win_left
            min_top =this.base.$$('BODY')[0].getHeight() - dif_top

            _windows[i].propiedades.top_barra = dif_top
            _windows[i].propiedades.min_top = min_top
            _windows[i].propiedades.min_left = min_left
            _windows[i].propiedades.left = win_left
            _windows[i].propiedades.top = win_top
            _windows[i].propiedades.minimized = false

            _windows[i].propiedades.top_primero = top_primero
            _windows[i].propiedades.left_primero = left_primero


            //$$('BODY')[0].style.zIndex = window.top.$$('BODY')[0].style.zIndex + 1
        }
    }

    //win.centerTop = win_top
    //win.centerLeft = win_left
    this.winMinOrder()
    win.setLocation(win_top, win_left)
}

function openWindow_onMaximize(win) {

    var _windows = this.base.Windows.windows
    for (var i = 0; i < _windows.length; i++) {
        if (_windows[i].element.id == win.element.id) {

            var height = _windows[i].propiedades.height
            var width = _windows[i].propiedades.width
            var left = _windows[i].propiedades.left
            var top = _windows[i].propiedades.top
            var parentWidthElement = _windows[i].propiedades.parentWidthElement
            var parentWidthPercent = _windows[i].propiedades.parentWidthPercent
            var parentHeightElement = _windows[i].propiedades.parentHeightElement
            var parentHeightPercent = _windows[i].propiedades.parentHeightPercent

            var min_top = _windows[i].propiedades.min_top
            var min_left = _windows[i].propiedades.min_left
            _windows[i].propiedades.minimized = win.minimized

            if (Prototype.Browser.IE)
                this.base.$(win.element.id + '_iefix').hide()
        }
    }

    if (win.storedLocation) {
        win.options.parentWidthElement = parentWidthElement
        win.options.parentHeightElement = parentHeightElement
        win.options.parentWidthPercent = 1
        win.options.parentHeightPercent = 1
        win.setSize(width, height)
        win.setLocation(0, 0)
        this.winMinOrder()
        win.setZIndex((getMaxzIndex(this.base) + 10))
    }
    else {
        win.options.parentWidthElement = parentWidthElement
        win.options.parentHeightElement = parentHeightElement
        win.options.parentWidthPercent = parentWidthPercent
        win.options.parentHeightPercent = parentHeightPercent
        win.setSize(width, height)
        win.setLocation(top, left)
    }             
}

function openWindow_onMinimize(win)
{
    var win_left = 1
    var _windows = this.base.Windows.windows
    for (var i = 0; i < _windows.length; i++) {
        if (_windows[i].element.id == win.element.id) {
            var height = _windows[i].propiedades.height
            var width = _windows[i].propiedades.width
            var left = _windows[i].propiedades.left
            var top = _windows[i].propiedades.top
            var parentWidthElement = _windows[i].propiedades.parentWidthElement
            var parentWidthPercent = _windows[i].propiedades.parentWidthPercent
            var parentHeightElement = _windows[i].propiedades.parentHeightElement
            var parentHeightPercent = _windows[i].propiedades.parentHeightPercent

            var min_top = _windows[i].propiedades.min_top
            var min_left = _windows[i].propiedades.min_left
            _windows[i].propiedades.minimized = win.minimized

            if (Prototype.Browser.IE)
                this.base.$(win.element.id + '_iefix').hide()
        }
    }

    if (win.minimized) {
        win.options.parentWidthElement = null
        win.setSize((this.winMinWidth - 20), 0)
        win.setLocation(min_top, min_left)
      //  win.element.style.zIndex = 0
    }
    else {
        win.options.parentWidthElement = parentWidthElement
        win.setZIndex((getMaxzIndex(this.base) + 10))
        if (win.storedLocation) {
            win.options.parentWidthPercent = 1
            win.options.parentHeightPercent = 1
            win.setSize(this.base.$$('BODY')[0].getWidth(), this.base.$$('BODY')[0].getHeight())
            win.setLocation(0, 0)
        }
        else {
            win.options.parentWidthPercent = parentWidthPercent
            win.options.parentHeightPercent = parentHeightPercent
            win.setSize(width, height)
            win.setLocation(top, left)
        }             
    }

    this.winMinOrder()
}

 function getMaxzIndex(ventana)
  {
  if (!ventana)
    ventana = window
  var NODS = ventana.document.getElementsByTagName("DIV")
  var mZindex = 1
  for (var i=0; i<NODS.length; i++)
    if (mZindex < parseInt(NODS[i].style.zIndex))
      mZindex = parseInt(NODS[i].style.zIndex)
      
  var NODS = ventana.document.getElementsByTagName("IFRAME")
  for (var i=0; i<NODS.length; i++)
    if (mZindex < parseInt(NODS[i].style.zIndex))
      mZindex = parseInt(NODS[i].style.zIndex)    
      
  return mZindex    
  };

function openWindow(parametros) {

    var height = height == undefined ? this.height : parametros.height
    var width = width == undefined ? this.width : parametros.width

    this.base = !this.base ? windows.top : this.base  //window.top.$$('BODY')[0] : parametros.target

    var contenedor_h = this.base.$$('BODY')[0].getHeight() //window.top.$$('BODY')[0].getHeight()
    var contenedor_w = this.base.$$('BODY')[0].getWidth() //window.top.$$('BODY')[0].getWidth()

    if (contenedor_h < height)
        height = contenedor_h - 10

    if (contenedor_w < width)
        width = contenedor_w - 10

    var nro_permiso = !parametros.nro_permiso ? 1 : parseInt(parametros.nro_permiso)
    var permiso = parametros.permiso == undefined ? 0 : parametros.permiso

    var tienePermiso = false
 //   if (parametros.permiso_grupo != undefined) {
	//	try{
 //           permiso = eval(parametros.permiso_grupo)
	//	} catch(e){
	//	}
	//}

    if (!nvFW.permiso_grupos[permiso]) {
        nvFW.permiso_grupos[permiso] = eval(permiso);
    }

    tienePermiso = nvFW.tienePermiso(permiso, nro_permiso)
    if (tienePermiso == false) {
        alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        return
    }

    if ((typeof (parametros.eventKey) !== 'undefined') && (parametros.eventKey.ctrlKey == true || parametros.eventKey.shiftKey == true)) {
        window.open(parametros.path)
        return
    }

    var parentWidthPercent = !parametros.parentWidthPercent ? 0.9 : parametros.parentWidthPercent
    var parentHeightPercent = !parametros.parentHeightPercent ? 0.9 : parametros.parentHeightPercent

    var maximizable = !parametros.maximizable ? true : parametros.maximizable
    var minimizable = !parametros.minimizable ? true : parametros.minimizable
    var draggable = !parametros.draggable ? true : parametros.draggable
    var resizable = true //!parametros.resizable ? true : parametros.resizable
    var modal = !parametros.modal ? false : parametros.modal
    var descripcion = !parametros.descripcion ? '' : parametros.descripcion
    var zIndex = !parametros.zIndex ? getMaxzIndex() : parametros.zIndex

    var file_dialog = {}
    var filters = {}
    var links = {}

    filters[0] = {}
    filters[0].titulo = "Todos los archivos"
    filters[0].filter = '*.*'
    filters[0].max_size = 1024 * 1024
    filters[0].inicio = true

    links[0] = {}
    links[0].icon = 'disco32.png'
    links[0].f_id = 0
    links[0].titulo = "Todas las unidades"
    links[0].inicio = true

    file_dialog.links = links
    file_dialog.filters = filters
    file_dialog.view = 'detalle'

    var _this = this
    //calcula el tamaño maximo de la ventana principal
    var maxHeight = this.base.$$('BODY')[0].getHeight() - 40
    var tienePermisoOld = (permiso & Math.pow(2, nro_permiso - 1)) > 0
    if (tienePermisoOld || tienePermiso) {
        win = this.base.nvFW.createWindow({
            title: '<b>' + descripcion + '</b>',
            minimizable: minimizable,
            maximizable: maximizable,
            draggable: draggable,
            width: width,
            height: height,
            //maxHeight: maxHeight,
            setWidthMaxWindow: true,
            resizable: resizable,
            centerVFromElement: this.base.$$('BODY')[0],
            centerHFromElement: this.base.$$('BODY')[0],
            parentWidthElement: this.base.$$('BODY')[0],
            parentWidthPercent: parentWidthPercent,
            parentHeightElement: this.base.$$('BODY')[0],
            parentHeightPercent: parentHeightPercent,
            resizable: resizable,
            file_dialog: file_dialog
          //  , zIndex: zIndex
            , onShow: typeof (parametros.onShow) != 'function' ? function (w) { _this.owshow(w) } : function (w) { parametros.onShow(); _this.owshow(w) }
            , onMaximize: typeof (parametros.onMaximize) != 'function' ? function (w) { _this.owmaximizar(w) } : function (w) { parametros.onMaximize(); _this.owmaximizar(w) }
            , onMinimize: typeof (parametros.onMinimize) != 'function' ? function (w) { _this.owminimizar(w) } : function (w) { parametros.onMinimize(); _this.owminimizar(w) }
            , onClose: typeof (parametros.onClose) != 'function' ? function (w) { w.destroy(); _this.winMinOrder() } : function (w) { parametros.onClose(); w.destroy(); _this.winMinOrder() }
          //  , onResize: function (w) { debugger }
        });

        if (parametros.path.split('?')[1] != undefined && parametros.path.split('?')[1] != '')
            win.setURL(parametros.path + "&id_ventana=" + win.getId())
        else
            win.setURL(parametros.path + "?id_ventana=" + win.getId())

        if(parametros.options)
            win.options.userData = parametros.options 
            
        win.showCenter(modal)

    }
    else {
        alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        return
    }
}

//function abrir_ventana_emergente(path, descripcion, permiso_grupo, nro_permiso, height, width, modulo, maximizable, draggable, resizable, modal) {

//    height = height == undefined ? this.height : height
//    width = width == undefined ? this.width : width

//   this.base = !this.base ? windows.top : this.base  //window.top.$$('BODY')[0] : parametros.target

//    contenedor_h = this.base.$$('BODY')[0].getHeight() //window.top.$$('BODY')[0].getHeight()
//    contenedor_w = this.base.$$('BODY')[0].getWidth() //window.top.$$('BODY')[0].getWidth()

//    if(contenedor_h < height)
//      height = contenedor_h - 10

//    if(contenedor_w < width)
//      width = contenedor_w - 10   

//    nro_permiso = nro_permiso == undefined ? 1 : parseInt(nro_permiso)
//    var permiso = permiso_grupo == undefined ? 1 : 0

////	var permiso = 0
//	var tienePermiso = false
//	if(permiso_grupo != undefined) {
//		try{
//			permiso =  eval(permiso_grupo)
//		} catch(e){
//		}
//		tienePermiso = nvFW.tienePermiso(permiso_grupo, nro_permiso)
//	}

//    maximizable = maximizable == undefined ? true : maximizable
//    draggable = draggable == undefined ? true : draggable
//    resizable = resizable == undefined ? true : resizable
//    modal = modal == undefined ? false : modal

//    var file_dialog = {}
//    var filters = {}
//    var links = {}

//    filters[0] = {}
//    filters[0].titulo = "Todos los archivos"
//    filters[0].filter = '*.*'
//    filters[0].max_size = 1024 * 1024
//    filters[0].inicio = true

//    links[0] = {}
//    links[0].icon = 'disco32.png'
//    links[0].f_id = 0
//    links[0].titulo = "Todas las unidades"
//    links[0].inicio = true

//    file_dialog.links = links
//    file_dialog.filters = filters
//    file_dialog.view = 'detalle'

//	//calcula el tamaño maximo de la ventana principal
//    var maxHeight = this.base.$$('BODY')[0].getHeight() - 40

//    var tienePermisoOld = (permiso & Math.pow(2, nro_permiso - 1)) > 0
//    if (tienePermisoOld || tienePermiso) {
//        win = this.base.nvFW.createWindow({
//            title: '<b>' + descripcion + '</b>',
//            minimizable: true,
//            maximizable: maximizable,
//            draggable: draggable,
//            width: width,
//            height: height,
//			//maxHeight: maxHeight,
//            setWidthMaxWindow: true,
//            resizable: resizable,
//            centerHFromElement:this.base.$$('BODY')[0],
//            parentWidthElement:this.base.$$('BODY')[0],
//            parentWidthPercent: 0.9,
//            parentHeightElement:this.base.$$('BODY')[0],
//            parentHeightPercent: 0.9,
//            file_dialog: file_dialog
//           ,onShow: function(win){
//                                     //debugger

//                                     var win_top = win.element.offsetTop
//                                     var win_left = win.element.offsetLeft
//                                     var min_left = 1 
//                                     var dif_top = 40

//                                     var contAncho =this.base.$$('BODY')[0].getWidth() - this.winMinWidth

//                                     var win_alto_full = height + 30

//                                     var _windows =this.base.Windows.windows
//                                     for (var i=0; i < _windows.length ; i++)
//                                        { 
//                                          if(_windows[i].element.id == win.element.id)
//                                            {
//                                              _windows[i].propiedades = new Array()
//                                              _windows[i].propiedades.height = win.height  
//                                              _windows[i].propiedades.width = win.width 
//                                              _windows[i].propiedades.parentWidthElement = win.options.parentWidthElement
//                                              _windows[i].propiedades.parentWidthPercent = win.options.parentWidthPercent
//                                              _windows[i].propiedades.parentHeightElement = win.options.parentHeightElement
//                                              _windows[i].propiedades.parentHeightPercent = win.options.parentHeightPercent

//                                               indice_ant = indice_anterior(win.element.id) 

//                                               if(indice_ant != i)
//                                                 { 
//                                                   top_primero = _windows[indice_ant].propiedades.top_primero 
//                                                   left_primero = _windows[indice_ant].propiedades.left_primero 

//                                                   if ((_windows[indice_ant].propiedades.top + 20 + win_alto_full) >=this.base.$$('BODY')[0].getHeight())
//                                                    {
//                                                     win_top = top_primero
//                                                     win_left = left_primero
//                                                     top_primero = win_top 
//                                                     left_primero = win_left 
//                                                    }
//                                                   else
//                                                    { 
//                                                     win_top  = _windows[indice_ant].propiedades.top + 20
//                                                     win_left = _windows[indice_ant].propiedades.left + 20
//                                                    }

//                                                   if(contAncho < (_windows[indice_ant].propiedades.min_left + this.winMinWidth))
//                                                    {
//                                                      min_left = 1
//                                                      dif_top = 40 + _windows[indice_ant].propiedades.top_barra
//                                                      _windows[i].propiedades.top_barra = dif_top
//                                                     }
//                                                    else
//                                                     {
//                                                      dif_top = _windows[indice_ant].propiedades.top_barra                                                     
//                                                      min_left = _windows[indice_ant].propiedades.min_left + this.winMinWidth
//                                                     } 
//                                                  }
//                                                 else
//                                                  {
//                                                   top_primero = win_top
//                                                   left_primero = win_left  
//                                                  }

//                                              min_top =this.base.$$('BODY')[0].getHeight() - dif_top 

//                                              _windows[i].propiedades.top_barra = dif_top        
//                                              _windows[i].propiedades.min_top = min_top
//                                              _windows[i].propiedades.min_left = min_left
//                                              _windows[i].propiedades.left = win_left
//                                              _windows[i].propiedades.top = win_top  
//                                              _windows[i].propiedades.minimized = false   

//                                              _windows[i].propiedades.top_primero = top_primero        
//                                              _windows[i].propiedades.left_primero  = left_primero

//                                             //$$('BODY')[0].style.zIndex = window.top.$$('BODY')[0].style.zIndex + 1
//                                            } 
//                                        }

//                                     //win.centerTop = win_top
//                                     //win.centerLeft = win_left

//                                     win.setLocation(win_top,win_left)     
//                                  }
//           ,onMaximize: function (win) {

//               var _windows =this.base.Windows.windows
//               for (var i = 0; i < _windows.length; i++) {
//                   if (_windows[i].element.id == win.element.id) {

//                       var height = _windows[i].propiedades.height
//                       var width = _windows[i].propiedades.width
//                       var left = _windows[i].propiedades.left
//                       var top = _windows[i].propiedades.top
//                       var parentWidthElement = _windows[i].propiedades.parentWidthElement
//                       var parentWidthPercent = _windows[i].propiedades.parentWidthPercent
//                       var parentHeightElement = _windows[i].propiedades.parentHeightElement
//                       var parentHeightPercent = _windows[i].propiedades.parentHeightPercent

//                       var min_top = _windows[i].propiedades.min_top
//                       var min_left = _windows[i].propiedades.min_left
//                       _windows[i].propiedades.minimized = win.minimized

//                       if (Prototype.Browser.IE)
//                          this.base.$(win.element.id + '_iefix').hide()
//                   }
//               }

//               if (win.storedLocation) {
//                   win.options.parentWidthPercent = 1
//                   win.options.parentHeightPercent = 1
//                   win.setSize(width, height)
//                   win.setLocation(0, 0)
//               }
//               else {
//                   win.options.parentWidthPercent = parentWidthPercent
//                   win.options.parentHeightPercent = parentHeightPercent
//                   win.setSize(width, height)
//                   win.setLocation(top, left)
//               }             

//            }
//           ,onMinimize: function (win) { 
//                                           //debugger
//                                           var win_left = 1
//                                           var _windows =this.base.Windows.windows
//                                           for (var i=0; i < _windows.length ; i++)
//                                             { 
//                                               if(_windows[i].element.id == win.element.id)
//                                                { 
//                                                  var height = _windows[i].propiedades.height
//                                                  var width = _windows[i].propiedades.width 
//                                                  var left = _windows[i].propiedades.left 
//                                                  var top = _windows[i].propiedades.top 
//                                                  var parentWidthElement = _windows[i].propiedades.parentWidthElement
//                                                  var parentWidthPercent = _windows[i].propiedades.parentWidthPercent
//                                                  var parentHeightElement = _windows[i].propiedades.parentHeightElement
//                                                  var parentHeightPercent = _windows[i].propiedades.parentHeightPercent     

//                                                  var min_top = _windows[i].propiedades.min_top 
//                                                  var min_left = _windows[i].propiedades.min_left 
//                                                  _windows[i].propiedades.minimized = win.minimized

//                                                  if(Prototype.Browser.IE)
//                                                   this.base.$(win.element.id + '_iefix').hide()
//                                                }
//                                            }

//                                           if(win.minimized)
//                                            {
//                                             win.options.parentWidthElement = null
//                                             win.setSize((this.winMinWidth - 20),0) 
//                                             win.setLocation(min_top,min_left) 
//                                             win.element.style.zIndex = 0
//                                            }
//                                           else
//                                            {
//                                             win.options.parentWidthElement = parentWidthElement
//                                             win.setSize(width,height)
//                                             win.setLocation(top,left)
//                                            }
//                                         }
//           ,onClose: function(win) { 
//                                         win.destroy()
//                                         winMinOrder()
//                                     } 

//        });

//        if (path.split('?')[1] != undefined && path.split('?')[1] != '')
//            win.setURL(path + "&id_ventana=" + win.getId())
//        else
//            win.setURL(path + "?id_ventana=" + win.getId())

//       win.showCenter(modal)

//    }
//    else {
//        alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
//        return
//    }
//}

function abrir_ventana_emergente(path, descripcion, permiso_grupo, nro_permiso, height, width, modulo, maximizable, draggable, resizable, modal, target, eventKey) {
    
    var parametros = {}
    parametros.path = path
    parametros.descripcion = descripcion
    parametros.permiso = permiso_grupo
    parametros.nro_permiso = nro_permiso
    parametros.height = height
    parametros.width = width
    parametros.maximizable = maximizable
    parametros.draggable = draggable
    parametros.resizable = resizable
    parametros.modal = modal
    parametros.target = target
    parametros.eventKey = eventKey

    if (!nvTargetWin) {
        var nvTargetWin
        if (window.top.nvTargetWin)
            nvTargetWin = window.top.nvTargetWin
        else
            nvTargetWin = new tnvTargetWin()
    }

    nvTargetWin.owopen(parametros)

}

function openWindow_blank(path, permiso, nro_permiso) 
{
    permiso = permiso == undefined ? 1 : eval(permiso)
    nro_permiso = nro_permiso == undefined ? 1 : parseInt(nro_permiso)

    if ((permiso & nro_permiso) > 0) {
        ObtenerVentana('').location.href = path
    }
    else
        alert('No posee los permisos necesarios para realizar esta acción')
}

function f_open_window_max(aURL, aWinName) 
{
    var wOpen;
    var sOptions;

    //debugger
    sOptions = 'status=yes,menubar=yes,scrollbars=yes,resizable=yes,toolbar=yes,location=yes'
    sOptions += ',width=' + (screen.availWidth - 5) + ',height=' + (screen.availHeight - 130) + ',top=0,left=0'

    try {
        wOpen = window.open('', aWinName, sOptions);
        wOpen.location = aURL;
        wOpen.focus();
    } catch (e) {
        //alert(e.message)  
    }
    return wOpen;
}

var win_no_modal
function abrir_ventana_no_modal(path, descripcion, permiso, nro_permiso, height, width, maximizable, draggable, resizable) {
    height = height == undefined ? 500 : height
    width = width == undefined ? 1000 : width
    permiso = permiso == undefined ? 1 : eval(permiso)
    nro_permiso = nro_permiso == undefined ? 1 : parseInt(nro_permiso)

    maximizable = maximizable == undefined ? true : maximizable
    draggable = draggable == undefined ? true : draggable
    resizable = resizable == undefined ? true : resizable
    
    if ((permiso & nro_permiso) == 0) {
        alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        return
    }

    win_no_modal = window.top.prototype_window({ className: 'alphacube',
    title: '<b>' + descripcion + '</b>',
    minimizable: true,
    maximizable: maximizable,
    draggable: draggable,
    resizable: resizable,
    //modal: true,
    width: width,
    height: height,
    destroyOnClose: true
    });

    if (path.split('?')[1] != undefined && path.split('?')[1] != '')
        win_no_modal.setURL(path + "&id_ventana=" + win_no_modal.getId())
    else
        win_no_modal.setURL(path + "?id_ventana=" + win_no_modal.getId())

    win_no_modal.showCenter()
}
  

function copy_pagos(o, indice) 
   {
   if (!indice)
     indice = null
   
   if (typeof(o) != "object" || o == null)
     return o; 
     
   //var r = o.constructor == Array ? [] : {};  
   if (indice == 'cancela_vence')
     return null
   
   var r = new Array();
   for (var i in o)
     {
     r[i] = copy_pagos(o[i], i);
     }
   return r;
   }
 

function setAttribute(NOD, attr, valor)
{
for (var i=0; i<NOD.attributes.length; i++) 
  if (NOD.attributes[i].nodeName == attr)
    {
    NOD.attributes[i].nodeValue = valor
    return
    }
  var new_att = NOD.ownerDocument.createAttribute(attr)
  new_att.nodeValue = valor
  NOD.attributes.setNamedItem(new_att)  
}  


function MO(e)
{
if (!e)
  var e=window.event;
var S=e.srcElement;
while (S.tagName!="TD")
  {S=S.parentElement;}
S.className="MO";
}
function MU(e)
{
if (!e)
 var e=window.event;
var S=e.srcElement;
while (S.tagName!="TD")
 {S=S.parentElement;}
S.className="MU";
}
function MENU_MO(e)
{
if (!e)
  var e=window.event;
var S=e.srcElement;
while (S.tagName!="TD")
  {S=S.parentElement;}
S.className="MENU_MO";
}
function MENU_MU(e)
{
if (!e)
 var e=window.event;
var S=e.srcElement;
while (S.tagName!="TD")
 {S=S.parentElement;}
S.className="MENU_MU";
}
  
  
function  link_mostrar(URL_relativa,  URL)
  {
  if (!URL)
    URL = URL_relativa
    //URL = URL_BASE + URL_relativa
  var a = window.open(URL)
  }
  
 

function mostrarVentanaModal(sURL, vArguments, sFeatures)
  {
  sFeatures =  sFeatures + 'edge: sunken; center: Yes; help: No; resizable: No; status: No; dialogHide: yes; unadorned: yes;'
  var res = window.showModalDialog(sURL, vArguments, sFeatures)
  }

/* Cookies *********************************** */
/* Cookies *********************************** */
/* Cookies *********************************** */

function GetCookie (name, defecto) 
{  
  if(defecto == undefined)
    defecto = null
  var arg = name + "=";  
  var alen = arg.length;  
  var clen = document.cookie.length;  
  var i = 0;  
  while (i < clen) 
    {    
    var j = i + alen;    
    if (document.cookie.substring(i, j) == arg)      
      return getCookieVal (j);    
    i = document.cookie.indexOf(" ", i) + 1;    
    if (i == 0) break;   
    }  
  return defecto;
}

function SetCookie (name, value, expires, path, domain, secure) 
{  

  var hoy = new Date();
  var argv = SetCookie.arguments;  
  var argc = SetCookie.arguments.length; 
  if (argc > 2)
    { 
    var today = new Date();
    today.setTime(today.getTime());
    expires = expires * 1000 * 60 * 60 * 24;
    var expires = new Date( today.getTime() + (expires) );
    }
  else
    var expires = null 
  
  var path = (argc > 3) ? argv[3] : null;  
  var domain = (argc > 4) ? argv[4] : null;  
  var secure = (argc > 5) ? argv[5] : false;  
  document.cookie = name + "=" + escape (value) + 
  ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) + 
  ((path == null) ? "" : ("; path=" + path)) +  
  ((domain == null) ? "" : ("; domain=" + domain)) +    
  ((secure == true) ? "; secure" : "");
}

function DeleteCookie (name) 
{  
  var exp = new Date();  
  exp.setTime (exp.getTime() - 1);  
  var cval = GetCookie (name);  
  document.cookie = name + "=" + cval + "; expires=" + exp.toGMTString();
}


function getCookieVal(offset) 
{
  var endstr = document.cookie.indexOf (";", offset);
  if (endstr == -1)
  endstr = document.cookie.length;
  return unescape(document.cookie.substring(offset, endstr));
}

function cod_reemplazar(cade)
  {
  var cars = new Array()
  cars[0] = {}
  cars[0]['original'] = 'á'
  cars[0]['reemplazo'] = 'a'
  cars[1] = {}
  cars[1]['original'] = 'é'
  cars[1]['reemplazo'] = 'e'
  cars[2] = {}
  cars[2]['original'] = 'í'
  cars[2]['reemplazo'] = 'i'
  cars[3] = {}
  cars[3]['original'] = 'ó'
  cars[3]['reemplazo'] = 'o'
  cars[4] = {}
  cars[4]['original'] = 'ú'
  cars[4]['reemplazo'] = 'u'
  cars[5] = {}
  cars[5]['original'] = 'ñ'
  cars[5]['reemplazo'] = 'n'
  cars[6] = {}
  cars[6]['original'] = 'º'
  cars[6]['reemplazo'] = ''
  cars[7] = {}
  cars[7]['original'] = 'Á'
  cars[7]['reemplazo'] = 'A'
  cars[8] = {}
  cars[8]['original'] = 'É'
  cars[8]['reemplazo'] = 'E'
  cars[9] = {}
  cars[9]['original'] = 'Í'
  cars[9]['reemplazo'] = 'I'
  cars[10] = {}
  cars[10]['original'] = 'Ó'
  cars[10]['reemplazo'] = 'O'
  cars[11] = {}
  cars[11]['original'] = 'Ú'
  cars[11]['reemplazo'] = 'U'
  cars[12] = {}
  cars[12]['original'] = 'Ñ'
  cars[12]['reemplazo'] = 'N'
  
  var strreg = ""
  var reg
  for (var i = 0; i < 13; i++)
    {
    reg = new RegExp(cars[i]['original'], 'ig')
    cade = cade.replace(reg, cars[i]['reemplazo'])
    }
  
  return cade
}


function msg(mensaje) {
    if (mensaje) {
        console.log(mensaje);
    }
}
