
function ordenar_ventanas_minimizadas()
{
     //debugger
     var win_ancho = 325
     var contAncho = window.top.$$('BODY')[0].getWidth() - win_ancho
     var dif_top = 40
     var min_left = 1 
     
     var _windows = window.top.Windows.windows
     for (var i=0; i < _windows.length ; i++)
        { 
          if(_windows[i]['propiedades'])
           {
              if(_windows[i]['propiedades'].minimized)
               { 
                  var indice_ant = indice_anterior(_windows[i]['element'].id)
                  if(i != indice_ant)
                     { 
                       if(contAncho < (_windows[indice_ant]['propiedades'].min_left + win_ancho))
                         {
                          dif_top = 40 + dif_top
                          min_left = 1
                          _windows[i]['propiedades'].top_barra = dif_top
                         }
                        else
                         {
                          dif_top = _windows[indice_ant]['propiedades'].top_barra                                                     
                          min_left = _windows[indice_ant]['propiedades'].min_left + win_ancho
                         } 
                      }
                       
                  min_top = window.top.$$('BODY')[0].getHeight() - dif_top 
                  
                  _windows[i]['propiedades'].top_barra = dif_top        
                  _windows[i]['propiedades'].min_top = min_top
                  _windows[i]['propiedades'].min_left = min_left
                  
                  _windows[i].setLocation(min_top,min_left)
              } 
          }    
        }

}

function indice_anterior(id)
{
   var indice_anterior = -1
   var _windows = window.top.Windows.windows
   for (var i=0; i < _windows.length ; i++)
     { 
       if(_windows[i]['element'].id == id)
         {
          indice_anterior = indice_anterior == -1 ? i : indice_anterior
          return indice_anterior
          }
       else  
         if(_windows[i]['propiedades'])
              indice_anterior = i
     }   
   return indice_anterior
}

//function abrir_ventana_emergente(path, descripcion, permiso, nro_permiso, height, width, modulo, maximizable, draggable, resizable, modal) {

//    height = height == undefined ? 500 : height
//    width = width == undefined ? 1000 : width
//    
//    contenedor_h = window.top.$$('BODY')[0].getHeight()
//    contenedor_w = window.top.$$('BODY')[0].getWidth()
//    
//    if(contenedor_h < height)
//      height = contenedor_h - 10
//    
//    if(contenedor_w < width)
//      width = contenedor_w - 10
//    
//    permiso = permiso == undefined ? 1 : eval(permiso)
//    nro_permiso = nro_permiso == undefined ? 1 : parseInt(nro_permiso)

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

//    if ((permiso & nro_permiso) > 0) {
//        win = window.top.nvFW.createWindow({
//            className: 'alphacube',
//            title: '<b>' + descripcion + '</b>',
//            minimizable: true,
//            maximizable: maximizable,
//            draggable: draggable,
//            width: width,
//            height: height,
//            resizable: resizable,
//            file_dialog: file_dialog
//           ,onShow: function(win){
//                                     //debugger
//                                             
//                                     var win_top = win.element.offsetTop
//                                     var win_left = win.element.offsetLeft
//                                     var min_left = 1 
//                                     var dif_top = 40
//                                     
//                                     var win_ancho = 325
//                                     var contAncho = window.top.$$('BODY')[0].getWidth() - win_ancho
//                                     
//                                     var win_alto_full = height + 30
//                                     
//                                     var _windows = window.top.Windows.windows
//                                     for (var i=0; i < _windows.length ; i++)
//                                        { 
//                                          if(_windows[i]['element'].id == win.element.id)
//                                            {
//                                               _windows[i]['propiedades'] = new Array()
//                                               _windows[i]['propiedades'].height = win.height  
//                                               _windows[i]['propiedades'].width = win.width 
//                                               
//                                               indice_ant = indice_anterior(win.element.id) 
//                                               
//                                               if(indice_ant != i)
//                                                 { 
//                                                   top_primero = _windows[indice_ant]['propiedades'].top_primero 
//                                                   left_primero = _windows[indice_ant]['propiedades'].left_primero 
//                                                 
//                                                   if((_windows[indice_ant]['propiedades'].top + 20 + win_alto_full) >=  window.top.$$('BODY')[0].getHeight())
//                                                    {
//                                                     win_top = top_primero
//                                                     win_left = left_primero
//                                                     top_primero = win_top 
//                                                     left_primero = win_left 
//                                                    }
//                                                   else
//                                                    { 
//                                                     win_top  = _windows[indice_ant]['propiedades'].top + 20
//                                                     win_left = _windows[indice_ant]['propiedades'].left + 20
//                                                    }
//                                                   
//                                                   if(contAncho < (_windows[indice_ant]['propiedades'].min_left + win_ancho))
//                                                    {
//                                                      min_left = 1
//                                                      dif_top = 40 + _windows[indice_ant]['propiedades'].top_barra
//                                                      _windows[i]['propiedades'].top_barra = dif_top
//                                                     }
//                                                    else
//                                                     {
//                                                      dif_top = _windows[indice_ant]['propiedades'].top_barra                                                     
//                                                      min_left = _windows[indice_ant]['propiedades'].min_left + win_ancho
//                                                     } 
//                                                  }
//                                                 else
//                                                  {
//                                                   top_primero = win_top
//                                                   left_primero = win_left  
//                                                  }
//                                                    
//                                              min_top = window.top.$$('BODY')[0].getHeight() - dif_top 
//                                              
//                                              _windows[i]['propiedades'].top_barra = dif_top        
//                                              _windows[i]['propiedades'].min_top = min_top
//                                              _windows[i]['propiedades'].min_left = min_left
//                                              _windows[i]['propiedades'].left = win_left
//                                              _windows[i]['propiedades'].top = win_top  
//                                              _windows[i]['propiedades'].minimized = false   
//                                              
//                                              _windows[i]['propiedades'].top_primero = top_primero        
//                                              _windows[i]['propiedades'].left_primero  = left_primero
//                                              
//                                             //$$('BODY')[0].style.zIndex = window.top.$$('BODY')[0].style.zIndex + 1
//                                            } 
//                                        }
//                                 
//                                     //win.centerTop = win_top
//                                     //win.centerLeft = win_left
//                                 
//                                     win.setLocation(win_top,win_left)     
//                                  }
//            ,onMinimize : function(win){ 
//                                           //debugger
//                                           
//                                           var win_left = 1
//                                           var _windows = window.top.Windows.windows
//                                           for (var i=0; i < _windows.length ; i++)
//                                             { 
//                                               if(_windows[i]['element'].id == win.element.id)
//                                                { 
//                                                  var height = _windows[i]['propiedades'].height
//                                                  var width = _windows[i]['propiedades'].width 
//                                                  var left = _windows[i]['propiedades'].left 
//                                                  var top = _windows[i]['propiedades'].top 
//                                                
//                                                  var min_top = _windows[i]['propiedades'].min_top 
//                                                  var min_left = _windows[i]['propiedades'].min_left 
//                                                  _windows[i]['propiedades'].minimized = win.minimized
//                                                  
//                                                  if(Prototype.Browser.IE)
//                                                    window.top.$(win.element.id + '_iefix').hide()
//                                                }
//                                                
//                                             }
//                                          
//                                           if(win.minimized)
//                                            {
//                                             win.setSize(300,0) 
//                                             win.setLocation(min_top,min_left) 
//                                             win.element.style.zIndex = 0
//                                            }
//                                           else
//                                            {
//                                             win.setSize(width,height)
//                                             win.setLocation(top,left)
//                                            }
//                                         }
//             ,onClose: function(win) { 
//                                         win.destroy()
//                                         ordenar_ventanas_minimizadas()
//                                     } 
//                                                
//        });
//        
//        if (path.split('?')[1] != undefined && path.split('?')[1] != '')
//            win.setURL(path + "&id_ventana=" + win.getId())
//        else
//            win.setURL(path + "?id_ventana=" + win.getId())
//       
//       win.showCenter(modal)
//    
//    }
//    else {
//        alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
//        return
//    }
//}

function openWindow_onShow(win) 
{
    //debugger

    var win_top = win.element.offsetTop
    var win_left = win.element.offsetLeft
    var min_left = 1
    var dif_top = 40

    var win_ancho = 325
    var contAncho = window.top.$$('BODY')[0].getWidth() - win_ancho

    var win_alto_full = win.height + 30

    var _windows = window.top.Windows.windows
    for (var i = 0; i < _windows.length; i++) {
        if (_windows[i]['element'].id == win.element.id) {
            _windows[i]['propiedades'] = new Array()
            _windows[i]['propiedades'].height = win.height
            _windows[i]['propiedades'].width = win.width

            indice_ant = indice_anterior(win.element.id)

            if (indice_ant != i) {
                top_primero = _windows[indice_ant]['propiedades'].top_primero
                left_primero = _windows[indice_ant]['propiedades'].left_primero

                if ((_windows[indice_ant]['propiedades'].top + 20 + win_alto_full) >= window.top.$$('BODY')[0].getHeight()) {
                    win_top = top_primero
                    win_left = left_primero
                    top_primero = win_top
                    left_primero = win_left
                }
                else {
                    win_top = _windows[indice_ant]['propiedades'].top + 20
                    win_left = _windows[indice_ant]['propiedades'].left + 20
                }

                if (contAncho < (_windows[indice_ant]['propiedades'].min_left + win_ancho)) {
                    min_left = 1
                    dif_top = 40 + _windows[indice_ant]['propiedades'].top_barra
                    _windows[i]['propiedades'].top_barra = dif_top
                }
                else {
                    dif_top = _windows[indice_ant]['propiedades'].top_barra
                    min_left = _windows[indice_ant]['propiedades'].min_left + win_ancho
                }
            }
            else {
                top_primero = win_top
                left_primero = win_left
            }

            min_top = window.top.$$('BODY')[0].getHeight() - dif_top

            _windows[i]['propiedades'].top_barra = dif_top
            _windows[i]['propiedades'].min_top = min_top
            _windows[i]['propiedades'].min_left = min_left
            _windows[i]['propiedades'].left = win_left
            _windows[i]['propiedades'].top = win_top
            _windows[i]['propiedades'].minimized = false

            _windows[i]['propiedades'].top_primero = top_primero
            _windows[i]['propiedades'].left_primero = left_primero

            //$$('BODY')[0].style.zIndex = window.top.$$('BODY')[0].style.zIndex + 1
        }
    }

    //win.centerTop = win_top
    //win.centerLeft = win_left

    win.setLocation(win_top, win_left)

}

function openWindow_onMinimize(win)
{
    var win_left = 1
    var _windows = window.top.Windows.windows
    for (var i = 0; i < _windows.length; i++) {
        if (_windows[i]['element'].id == win.element.id) {
            var height = _windows[i]['propiedades'].height
            var width = _windows[i]['propiedades'].width
            var left = _windows[i]['propiedades'].left
            var top = _windows[i]['propiedades'].top

            var min_top = _windows[i]['propiedades'].min_top
            var min_left = _windows[i]['propiedades'].min_left
            _windows[i]['propiedades'].minimized = win.minimized

            if (Prototype.Browser.IE)
                window.top.$(win.element.id + '_iefix').hide()
        }

    }

    if (win.minimized) {
        win.setSize(300, 0)
        win.setLocation(min_top, min_left)
        win.element.style.zIndex = 1
    }
    else {
        win.setSize(width, height)
        win.setLocation(top, left)
    }

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

    var height = !parametros.height ? 500 : parametros.height
    var width = !parametros.width ? 1000 : parametros.width

    var contenedor_h = window.top.$$('BODY')[0].getHeight()
    var contenedor_w = window.top.$$('BODY')[0].getWidth()

    if (contenedor_h < height)
        height = contenedor_h - 10

    if (contenedor_w < width)
        width = contenedor_w - 10

    var permiso = !parametros.permiso ? 1 : nvFW.pageContents[parametros.permiso]
    var nro_permiso = !parametros.nro_permiso ? 1 : parseInt(parametros.nro_permiso)

    var maximizable = !parametros.maximizable ? true : parametros.maximizable
    var minimizable = !parametros.minimizable ? true : parametros.minimizable
    var draggable = !parametros.draggable ? true : parametros.draggable
    var resizable = !parametros.resizable ? true : parametros.resizable
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

    if ((permiso & nro_permiso) > 0) {
        win = window.top.nvFW.createWindow({
            className: 'alphacube',
            title: '<b>' + descripcion + '</b>',
            minimizable: minimizable,
            maximizable: maximizable,
            draggable: draggable,
            width: width,
            height: height,
            resizable: resizable,
            file_dialog: file_dialog
          , zIndex: zIndex
          , onShow: typeof (parametros.onShow) != 'function' ? function(w) { openWindow_onShow(w) } : function(w) { parametros.onShow(); openWindow_onShow(w) }
          , onMinimize: typeof (parametros.onMinimize) != 'function' ? function(w) { openWindow_onMinimize(w) } : function(w) { parametros.onMinimize(); openWindow_onMinimize(w) }
          , onClose: typeof (parametros.onClose) != 'function' ? function(w) { w.destroy(); ordenar_ventanas_minimizadas() } : function(w) { parametros.onClose(); w.destroy(); ordenar_ventanas_minimizadas() }

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
