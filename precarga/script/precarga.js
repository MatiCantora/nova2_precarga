var precarga = {}


precarga.window_onload = function window_onload() {

    let vMenuLeft = new tMenu('divMenuLeft', 'vMenuLeft', { clasicMenu: false, canvasMobile: "divMenuLeftMobile" });
    Menus["vMenuLeft"] = vMenuLeft
    Menus["vMenuLeft"].alineacion = 'izquierda';
    Menus["vMenuLeft"].estilo = 'M';

    cargarMenuLeft(vMenuLeft)

    tamanio = nvtWinDefault()

    //muestra menu dependiendo si debe ser menu movil o no
    vMenuLeft.MostrarMenu(true)
    
    drawcontrol.menu_izquierdo_show(!precarga.isMobile())
  


    //cambioDeWidth = 1;
    consulta.cargar_operador();
    $("strVendedor").innerText = consulta.vendedor

    
    sinonimos_dictamen_cargar();

    history.scrollRestoration = 'manual'
    ismobile = (isMobile()) ? true : false

    //Anulo el cartel default de nova cuando abandono la aplicacion
    nvFW.alertUnload = false
    vListButtons.MostrarListButton()

    //if (nvFW.pageContents["nro_credito"] != "") MostrarCredito(nvFW.pageContents['nro_credito'])

    consulta.limpiar()

    //ObtenerSucursalOperador()
    document.getElementById('nro_docu1').focus()

    //&& (permisos_precarga & 4)<= 0
    //if (!nvFW.tienePermiso('permisos_precarga', 2)) {
    //$('divNoti').hide()
    //$('divNotiR').hide()
    //$('tbResultado').hide()
    //}
    //&& (permisos_precarga & 64) == 0
    //if (!nvFW.tienePermiso('permisos_precarga', 6))
    //    $('spanFiltroCuenta').style.visibility = 'hidden';

    // && (permisos_precarga & 128) == 0
    //if (!nvFW.tienePermiso('permisos_precarga', 7))
    //    $('spanFiltroBCRA').style.visibility = 'hidden';

    

    //Esta funcion determina los tamaños de los componentes, menu sup, inf, body, etc
    //tamanio = nvtWinDefault()

    //muestra menu dependiendo si debe ser menu movil o no
    //vMenuLeft.MostrarMenu(tamanio.ocultarMenu)

    //para operadores de mendoza o que no tengan estructura            
    //mostrar_boton_generarcodigo(nro_estructura==11)


    //funciones de scrolling para mostrar o ocultar el menu.
    //detectSwipe($$("BODY")[0], "mostrar", 50);
    //detectSwipe($("divComponentes"), mostrarMenuIzquierdoSwipe, 50, "izq");
    //detectSwipe($("menu_left_vidrio"), "colapsar");
    //detectSwipe($("menu_left_mobile"), "colapsar");
    //detectSwipe($("menu_right_vidrio"), "colapsar");
    //detectSwipe($(vMenuRight.canvasMobile), "colapsar");
    //ocultar el vidrio porque el menu no se muestra desde el inicio
    //$("menu_left_vidrio").style.right = "-540px";
    //Para mostrar el body cuando termine el onload
    $$("body")[0].style.visibility = "visible"

    //campos_defs.items['banco']['onchange'] = banco_onchange
    //campos_defs.items['mutual']['onchange'] = mutual_onchange

    // ================ ESTADISTICAS ================ //
    //if (nvFW.tienePermiso('permisos_precarga', 16)) {
    //    estadisticas = [];
    //    cargarValoresEstadisticas();
    //}

    // Mostrar el primer paso al cargar la página
    wizzard();

    //$('divMenu').style.cssText += 'float: left; position: absolute;';
    //window_onresize();
    precarga.vendedor_check()

}


precarga.window_resize = function () {


}

precarga.isMobile = function () {
    return (
        (navigator.userAgent.match(/Android/i)) ||
        (navigator.userAgent.match(/webOS/i)) ||
        (navigator.userAgent.match(/iPhone/i)) ||
        (navigator.userAgent.match(/iPod/i)) ||
        (navigator.userAgent.match(/iPad/i)) ||
        (navigator.userAgent.match(/BlackBerry/i))
    );
}

precarga.window_pos = function () {
    
    var res = {}
    
    if (this.isMobile()) {
        var margin_height = 40
        var margin_width = 16
        var co_top_menu = Position.cumulativeOffset($("top_menu"))
        res.top = co_top_menu.top + $("top_menu").offsetHeight
        //var co_vMenuLeft = Position.cumulativeOffset($('vMenuLeft.menuMobile'))
        res.left = 0
        res.width = $$("BODY")[0].clientWidth - margin_width
        res.height = $$("BODY")[0].clientHeight - res.top - margin_height
    }
    else {
        var margin_height = 40
        var co_top_menu = Position.cumulativeOffset($("top_menu"))
        res.top = co_top_menu.top + $("top_menu").offsetHeight
        var co_vMenuLeft = Position.cumulativeOffset($('vMenuLeft.menuMobile'))
        res.left = co_vMenuLeft.left + $("vMenuLeft.menuMobile").offsetWidth
        res.width = $$("BODY")[0].clientWidth - (res.left * 2)
        res.height = $$("BODY")[0].clientHeight - res.top - margin_height
    }


    return res
}



precarga.show_modal_window = function (parametros) {
    
    var window_pos = this.window_pos()

    var new_win_params = {
        url: parametros.url,
        title: parametros.title,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true,
        className: "alphacube",
        destroyOnClose: true,

        //ubicacion y tamaño
        //centerHFromElement: $("contenedor"),
        //parentWidthElement: $("contenedor"),
        //parentWidthPercent: 0.9,
        //parentHeightElement: $("contenedor"),
        //parentHeightPercent: 0.9,
        zIndex: 10,
        top: window_pos.top,
        left: window_pos.left,
        width: window_pos.width,
        height: window_pos.height, //610

        onResize: function (_win) {
            var window_pos = precarga.window_pos()
            _win.setSize(window_pos.width, window_pos.height)
            _win.setLocation(window_pos.top, window_pos.left)
        }
        , onClose: parametros.onClose == undefined ? null : parametros.onClose
        , userData: parametros.userData == undefined ? null : parametros.userData
    }

    //var win = new top.window.Window(parametros);
    //return win
    var win = nvFW.createWindow(new_win_params)

    // win.addEventListener("resize", function (a, b, c) {
    //debugger
    //var window_pos = this.window_pos()
    //win.callback_onresize()
    window.addEventListener("resize", function () {
        var window_pos = precarga.window_pos()
        win.setSize(window_pos.width, window_pos.height)
        win.setLocation(window_pos.top, window_pos.left)
    })

    win.show(true)
    return win
}

precarga.vendedor_check = function() {
    //$('strVendedor').innerText = nvFW.operador.razon_social
    if (consulta.nro_vendedor == 0)
        precarga.vendedor_seleccionar()
}


precarga.vendedor_seleccionar = function () {

    if (!nvFW.tienePermiso('permisos_precarga', 1)) {
        nvFW.alert('No posee permisos para seleccionar el vendedor')
        return
    }
    precarga.show_modal_window({
        url: 'selVendedor.aspx',
        title: '<b>Seleccionar Vendedor</b>',
        onClose: function(win_vendedor) {
            
            var retorno = win_vendedor.options.userData.res
            if (retorno) {
                $('strVendedor').innerText = retorno["vendedor"]
                //strVendedor = retorno["vendedor"]
                consulta.nro_vendedor = retorno['nro_vendedor']
                consulta.nro_estructura = (retorno['nro_estructura'] == null) ? 0 : retorno['nro_estructura']
                consulta.estructura = ""
                //mostrar_boton_generarcodigo(estructura_genera_codigo.indexOf(+nro_estructura)>=0)
                consulta.cod_prov = retorno['cod_prov']
                consulta.postal_real = retorno['postal_real']
                //mostrar_boton_generarcodigo(nro_estructura==11 || nro_estructura==0)
                //mostrar_boton_generarcodigo(nro_estructura==11)
                //consulta.limpiar()
            }
        }
    })
}


function isMobile() {
    return (
        (navigator.userAgent.match(/Android/i)) ||
        (navigator.userAgent.match(/webOS/i)) ||
        (navigator.userAgent.match(/iPhone/i)) ||
        (navigator.userAgent.match(/iPod/i)) ||
        (navigator.userAgent.match(/iPad/i)) ||
        (navigator.userAgent.match(/BlackBerry/i))
    );
}




function createWindow2(parametros) {
    debugger
    //ubicacion
    var co = Position.cumulativeOffset($("top_menu")) 
    var top = co.top + $("top_menu").offsetHeight

    var new_win_params = {
        url: parametros.url,
        title: parametros.title,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true,
        className: "alphacube",

        //ubicacion 
        top: top

    }

    //var win = new top.window.Window(parametros);
    //return win
    var win = nvFW.createWindow(new_win_params)
    return win


    //Codigo anterior
    var tamanio = nvtWinDefault()
    
    //parametros.parentWidthPercent = 0.93
    parametros.maxHeight = !parametros.maxHeight ? 600 : parametros.maxHeight
    parametros.maxWidth = !parametros.maxWidth ? 900 : parametros.maxWidth
    parametros.destroyOnClose = false;
    //Definir el alto de una ventana en porcentaje de otro elemento
    //parametros.parentHeightPercent = 0.80
    //Opcupe toda la ventana, menos el top

    //1) Agregar un callback al resize de la window.top
    //2) El resize redimiensiona y reposisiona la ventana
    //3) En el oclose quitar el callback
    //parametros.top = $("top_menu").getHeight()
    parametros.parentWidthPercent = undefined
    parametros.parentHeightPercent = undefined
    parametros.parentWidthElement = undefined
    parametros.parentHeightElement = undefined
    parametros.className = "alphacube"


    if (tamanio.ocultarMenu) {
        parametros.maxHeight = undefined
        parametros.maxWidth = undefined
    }
    
    //var userAgent = window.navigator.userAgent;
    
    /*
    if (userAgent.match(/iPad/i) || userAgent.match(/iPhone/i)) {
        // iPad or iPhone
    }*/

    try{ 
        blockVerticalSlide(1) 

        if (parametros.onClose != null) {
            var old_close = parametros.onClose
            parametros.onClose = function (win) { old_close(); window.removeEventListener("resize", win.callback_onresize); blockVerticalSlide(-1); win.destroy(); }
        }
        else {
            parametros.onClose = function (win) { window.removeEventListener("resize", win.callback_onresize); blockVerticalSlide(-1); win.destroy(); }
        }
    }
    catch (e) {}
    var tamanio = nvtWinDefault()

    parametros.width = tamanio.div_top_body.width + "px"
    parametros.height = document.documentElement.clientHeight - tamanio.div_top_menu.height + "px"
    parametros.top =  tamanio.div_top_menu.height + "px"
    
    var win = nvFW.createWindow(parametros)

    var callback_onresize = function () {
       // win.eventResize = undefined
        var tamanio = nvtWinDefault()
        var top_height = tamanio.div_top_menu.height
        var height = document.documentElement.clientHeight - tamanio.div_top_menu.height - 34
        
        var width = tamanio.div_top_body.width - 14
        var left_width 
       
        if(!win.options.maxHeightCopy)
            win.options.maxHeightCopy = win.options.maxHeight
        
        if (tamanio.ocultarMenu) {
            win.options.maxHeight = undefined
            left_width = (document.documentElement.clientWidth - tamanio.div_top_body.width) / 2
        }
        else {
            win.options.maxHeight = win.options.maxHeightCopy
            left_width = (document.documentElement.clientWidth - tamanio.div_top_body.width) / 2 + (tamanio.div_top_body.width - ((win.options.maxWidth) ? win.options.maxWidth : width)) / 2 - 7
        }

        win.options.top = top_height
        win.options.left = left_width
        
        new Effect.ResizeWindow(win, top_height, left_width, width, height, { duration: 0 });
    }

    win.callback_onresize = callback_onresize
    
    window.addEventListener("resize", win.callback_onresize)
    
    win.callback_onresize()

    //win.element.style.overflow = "hidden"
    win.element.style.position = "fixed"
    
    return win
}


function nvtWinDefault() {
    var dif = Prototype.Browser.IE ? 5 : 2
    var body_width
    var body_heigth
    var tamanio = {}
    
    body_width = document.documentElement.clientWidth
    
    tamanio.width_defs = new Array()
    tamanio.width_defs[0] = { min: 0, max: 900, left_width: '50%', left_percent: 0.5, ocultarMenu: true, top_height: 50, top_width: body_width }
    tamanio.width_defs[1] = { min: 900, max: 1200, left_width: '40%', left_percent: 0.4, ocultarMenu: false, top_height: 100, top_width: body_width }
    tamanio.width_defs[2] = { min: 1200, max: 10000, left_width: '10%', left_percent: 0.1, ocultarMenu: false, top_height: 100, top_width: 1200 }
    
    var posicion = 0
     
    for (var i = 0; i < tamanio.width_defs.length; i++) {
        if (body_width >= tamanio.width_defs[i].min && body_width <= tamanio.width_defs[i].max) {
            posicion = i;
            break;
        }
    }

    body_heigth = document.documentElement.clientHeight

    var div_left = {
        'height': body_heigth - tamanio.width_defs[posicion].top_height,
        'left_percent': tamanio.width_defs[posicion].left_percent,
        'width': tamanio.width_defs[posicion].left_percent * 100
    }

    var div_left_vidrio = {
        'height': body_heigth - tamanio.width_defs[posicion].top_height ,
        'width': ((tamanio.width_defs[posicion].left_percent !== 0) ? (1 - tamanio.width_defs[posicion].left_percent) * 100 : tamanio.width_defs[posicion].left_width)
    }

    
    var div_top_menu = {
        'height': tamanio.width_defs[posicion].top_height,
        'width': tamanio.width_defs[posicion].top_width
    }
    
    var div_top_body = {
        'height': (document.body.clientHeight + 1),
        'width': tamanio.width_defs[posicion].top_width,
        'top_percent': tamanio.width_defs[posicion].top_percent
    }

    return { div_left: div_left, div_left_vidrio: div_left_vidrio, div_top_menu: div_top_menu, div_top_body: div_top_body, ocultarMenu: tamanio.width_defs[posicion].ocultarMenu }
}
