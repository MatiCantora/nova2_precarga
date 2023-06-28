var drawcontrol = {}

drawcontrol.menu_izquierdo_isVisible = true

drawcontrol.menu_izquierdo_swipe = function () {
    if (!precarga.isMobile()) return
    this.menu_izquierdo_show(!this.menu_izquierdo_isVisible)
}

drawcontrol.menu_izquierdo_show = function (show) {
    this.menu_izquierdo_isVisible = show
    //if (document.activeElement.name != undefined) {
    //    ; $(document.activeElement.name).blur()
    //} //quitar el focus para ocultar el teclado mobile y el menu se muestre completo

    //  $('nro_docu').focus()
    // $(vMenuLeft.canvasMobile).style.height = ($$("body")[0].getHeight() + 60 - $("top_menu").getHeight()) + "px";
    //$(vMenuLeft.canvasMobile).style.zIndex = "1"

    //$("divMenu").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";
    //$("menu_left_vidrio").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";
    if (show) {
        $("divMenu").show();
    }
    else {
        $("divMenu").hide();
    }

    //if ($('divMenu').style.display !== '') {
    //    $(vMenuLeft.canvasMobile).show();
    //    $("divMenu").show();
    //}
    //else {
    //    /*if (menuDerechoVisible) {
    //    mostrarMenuDerecho();
    //    }*/
    //    $(vMenuLeft.canvasMobile).hide();

    //    $("divMenu").hide();
    //}
    //window_onresize_menu();
    //$(vMenuLeft.canvasMobile).style.height = '100%';
}


var cambioDeWidth = 1;


//se usa en precarga.js
var bloquearSlideVertical = 0;
function blockVerticalSlide(sum) {

    bloquearSlideVertical = bloquearSlideVertical + sum

    //if (bloquearSlideVertical < 1) {
    //    $("div_body").style.position = "absolute"
    //    $("div_body").style.overflowY = "auto"
    //}
    //else {
    //    $("div_body").style.position = "fixed"
    //    $("div_body").style.overflowY = "hidden"
    //}
}


/*En otro caso la funcion nombre_del_menu.scroll_event(this) debe ser invocada como un evento oncroll desde el elemento que se scrollea*/
var calcularScrollEvent = "top";
function scroll_event(e) {

    if (bloquearSlideVertical < 1) {
    }
    else {
        window.scrollTo(0, 0);
        return
    }


    if (tamanio.ocultarMenu) {
        if ($$("BODY")[0].parentElement.scrollTop > 1) {
            if (calcularScrollEvent == "top") {
                calcularScrollEvent = "not_top"

                /*  if (!vMenuRight.functionMobile) {
                $(vMenuRight.canvas).style.top = "44px"
                $(vMenuRight.canvas).style.transition = "all 0.3s";
                $(vMenuRight.canvas).style.borderBottom = "3px solid #E3E0E3;"
                }*/
                $(vMenuLeft.canvasMobile).style.top = "44px"
                $("top_menu").setStyle({ height: "40px", opacity: 0.9 })

                $("logo").setStyle({ width: "125px", height: "40px", top: "0px" })
                //$("imgbloqueo_sesion").setStyle({ height: "24px", width: "24px" })
                //$("imgbutton_sesion").setStyle({ height: "24px", width: "24px" })
                $("img_Menu").setStyle({ height: "24px", width: "24px" })
            }
        } else {
            if (calcularScrollEvent == "not_top") {
                calcularScrollEvent = "top"

                $(vMenuLeft.canvasMobile).style.top = "50px"
                /*
                if (!vMenuRight.functionMobile) {
                $(vMenuRight.canvas).style.top = "50px"
                $(vMenuRight.canvas).style.transition = "all 0.3s";
                $(vMenuRight.canvas).style.borderBottom = "3px solid #E3E0E3;"
                }
                */
                $("top_menu").setStyle({ height: "50px", opacity: 1 })

                $("logo").setStyle({ width: "150px", height: "50px", top: "0px" })
                //$("imgbloqueo_sesion").setStyle({ height: "32px", width: "32px" })
                //$("imgbutton_sesion").setStyle({ height: "32px", width: "32px" })
                $("img_Menu").setStyle({ height: "32px", width: "32px" })
            }
        }
    }

}


//############################################
//########------FUNCIONES RESIZE------########
//############################################


function window_onresize_movil() {

    $("divEspacioBotonera").show();
    $("imgMenu").show();
    $("imgMenuDerecho").hide(); //va show 

    //$('menu_left_mobile').style.display === '' = false;

    /* if (!vMenuRight.functionMobile) {
    $("imgMenuDerecho").hide();
    }*/

    $("menu_left_vidrio").show();
    $("menu_right_vidrio").show();

    $("user_sucursal").hide();
    $("br1").hide();
    $("br2").hide();

    if ($("logo").data != 'image/nova-aux.svg') {
        $("logo").data = 'image/nova-aux.svg'
        if (calcularScrollEvent == "top") {
            $("logo").setStyle({ height: "50px", width: "150px" })
        }
        else {
            $("logo").setStyle({ height: "40px", width: "125px" })
        }
    }

    $(vMenuLeft.canvasMobile).style.position = "fixed";
    $(vMenuLeft.canvasMobile).style.width = tamanio.div_left.width + "%"
    $(vMenuLeft.canvasMobile).style.height = tamanio.div_left.height + "px"

    $(vMenuLeft.canvasMobile).style.marginTop = "0px";

    $("menu_left_vidrio").style.width = tamanio.div_left_vidrio.width + "%"
    $("menu_left_vidrio").style.height = tamanio.div_left_vidrio.height + "px"

    $("menu_right_vidrio").style.width = tamanio.div_left_vidrio.width + "%"
    $("menu_right_vidrio").style.height = tamanio.div_left_vidrio.height + "px"

    $$("BODY")[0].setStyle({ overflowy: "auto", width: "99.9%", float: "none" })

    $("top_menu").style.position = "fixed"

    vMenuLeft.resize(true)

    if (!vMenuLeft.clasicMenu) {
        $(vMenuLeft.canvasMobile).children[0].rows[0].show()
    }

    $$("BODY")[0].style.marginTop = "0px"

    $(vMenuLeft.canvasMobile).style.left = "-540px"
    $(vMenuLeft.canvasMobile).style.top = $("top_menu").getHeight() + "px"
    $(vMenuLeft.canvasMobile).style.transition = "all 0.3s";

    // $("tbButtons").style.width = $$("BODY")[0].getWidth()  + "px"
    $("tbButtons").style.position = "fixed"

    $("divVendedor").style.width = "100%"
    $("divVendedor").style.marginTop = "50px"
    $("divSelTrabajo").style.width = "100%"
    $("divDatosPersonales").style.width = "100%"
    $("divGrupo").style.width = "100%"
    $("divSocio").style.width = "100%"
    $("divProducto").style.width = "100%"
    $("divAnalisis").style.width = "100%"
    $("divFiltros").style.width = "100%"
    $("tbButtons").style.width = "98%"

    $("div_padding_left").style.width = "0px"
    //$$("body")[0].style.paddingLeft = "0px"

    $("divVendedor").style.marginLeft = "0px"
    $("divSelTrabajo").style.marginLeft = "0px"
    $("divDatosPersonales").style.marginLeft = "0px"
    $("divGrupo").style.marginLeft = "0px"
    $("divSocio").style.marginLeft = "0px"
    $("divProducto").style.marginLeft = "0px"
    $("divAnalisis").style.marginLeft = "0px"
    $("divFiltros").style.marginLeft = "0px"
    $("tbButtons").style.marginLeft = "0px"

    $("top_menu").style.left = "0px"
}


function window_onresize_desktop() {

    $("divEspacioBotonera").hide();

    $("div_padding_left").style.width = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
    //$$("body")[0].style.paddingLeft = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"


    $("top_menu").setStyle({ opacity: 1 })

    $(vMenuLeft.canvasMobile).style.transition = "";

    $("imgMenu").hide();
    //$("imgMenuDerecho").hide();

    $("menu_left_vidrio").hide();

    $("br1").show();
    $("br2").show();
    $("user_sucursal").show();

    if ($("logo").data != 'image/nova.svg') {
        $("logo").data = 'image/nova.svg'
        $("logo").setStyle({ height: "90px", width: "215px" })
    }

    $(vMenuLeft.canvasMobile).style.position = "fixed";
    $(vMenuLeft.canvasMobile).style.width = "200px"
    $(vMenuLeft.canvasMobile).style.height = "100%"
    $(vMenuLeft.canvasMobile).style.marginTop = "102px"
    $(vMenuLeft.canvasMobile).style.top = "0px"
    //$(vMenuLeft.canvasMobile).style.left = "initial"

    //vMenuRight.resize(false)
    vMenuLeft.resize(false)
    /*
    if (vMenuRight.clasicMenu) {
    $(vMenuRight.canvas).style.width = "100%"
    $(vMenuRight.canvas).style.float = "none"
    $(vMenuRight.canvas).style.marginTop = "0px"
    $(vMenuRight.canvas).style.top = "0px"
    $(vMenuRight.canvas).style.position = "initial"
    }*/

    //if (!vMenuLeft.clasicMenu) {
    //    $(vMenuLeft.canvasMobile).children[0].rows[0].hide()
    //}

    $("menu_right_vidrio").hide();

    // $$("BODY")[0].setStyle({ overflowy: "auto", width: tamanio.div_top_body.width /* + (window.innerWidth - tamanio.div_top_body.width) / 2*/ + "px" })

    $$("BODY")[0].style.marginTop = "0px";
    $("top_menu").style.position = "fixed"
    $("top_menu").style.left = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
    $(vMenuLeft.canvasMobile).style.left = (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"

    $(vMenuLeft.canvasMobile).style.float = "left"

    $$("BODY")[0].style.float = "left"

    $("top_menu").setStyle({ width: tamanio.div_top_menu.width + "px", height: tamanio.div_top_menu.height + "px" })

    $("tbButtons").style.width = ($$("BODY")[0].getWidth() - 16) + "px"
    //$("tbButtons").style.position = "relative"

    $("divVendedor").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divVendedor").style.marginTop = "102px"
    $("divSelTrabajo").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divDatosPersonales").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divGrupo").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divSocio").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divProducto").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divAnalisis").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("divFiltros").style.width = ($("top_menu").getWidth() - 200) + "px"
    $("tbButtons").style.width = ($("top_menu").getWidth() - 200) + "px"

    $("divVendedor").style.marginLeft = "200px"
    $("divSelTrabajo").style.marginLeft = "200px"
    $("divDatosPersonales").style.marginLeft = "200px"
    $("divGrupo").style.marginLeft = "200px"
    $("divSocio").style.marginLeft = "200px"
    $("divProducto").style.marginLeft = "200px"
    $("divAnalisis").style.marginLeft = "200px"
    $("divFiltros").style.marginLeft = "200px"
    $("tbButtons").style.marginLeft = 200 + (window.innerWidth - tamanio.div_top_body.width) / 2 + "px"
}


var tamanio
function window_onresize() {
    //try {

    //    //ejecutar onresize solo si hubo un cambio de width
    //    if (document.documentElement.clientWidth == cambioDeWidth) return
    //    cambioDeWidth = document.documentElement.clientWidth

    //    //setear tamaño de componentes
    //    tamanio = nvtWinDefault()

    //    //evitar mostrar mnostrar el vidrio simulando una accion
    //    window.top.nvSesion.usuario_accion()

    //    //$("contenedor").setStyle({ overflowy: "auto", height: tamanio.div_top_body.height + "px", width: tamanio.div_top_body.width + "px" })

    //    $("top_menu").style.width = tamanio.div_top_menu.width + "px"
    //    $("top_menu").style.height = tamanio.div_top_menu.height + "px"

    //    //if (!tamanio.ocultarMenu) {
    //    //    window_onresize_desktop()
    //    //}
    //    //else {
    //    //    window_onresize_movil()
    //    //}

    //    // $(vMenuRight.canvasMobile).style.borderLeft = "3px solid #E3E0E3"
    //    window_onresize_menu();

    //    //rezise steps
    //    $('divMostrarTrabajos').setStyle({ height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() + 'px' });
    //    //$('divCancelaciones').setStyle({ height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() + 'px' });
    //    $('divOfertaResp').setStyle({
    //        height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnOferta").getHeight() + 'px' });
    //    $('divTiposCobro').setStyle({
    //        height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnCobro").getHeight() + 'px'
    //    });

    //    $('divCreditoAlta').setStyle({ height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() + 'px' });
    //    if (!!$('divContentCrd'))
    //        $('divContentCrd').setStyle({
    //            height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnLimpiarCrd").getHeight() + 'px'
    //        });
    //}
    //catch (e) { }
}


function window_onresize_menu() {
    $(vMenuLeft.canvasMobile).style.borderRight = "3px solid #E3E0E3"

    $('divMenu').setStyle({ height: $$('body')[0].getHeight() - $('top_menu').getHeight() + 'px' });
    $('menu_left_mobile').setStyle({ height: $$('body')[0].getHeight() - $('top_menu').getHeight() - $('divInfoVendedor').getHeight() + 'px' });
    $('menu_left_mobile').style.overflowY = "auto";
    $('divInfoVendedor').setStyle({ width: $('menu_left_mobile').getWidth() + 'px' });
}

//############################################
//########------FUNCIONES SWIPE------#########
//############################################


function detectSwipe(elemento, funcion, inicial) {

    deteccion_swipe = {};
    deteccion_swipe.sX = 0; deteccion_swipe.sY = 0; deteccion_swipe.eX = 0; deteccion_swipe.eY = 0; deteccion_swipe.cX = 0

    var min_x = 50;  //min x swipe para swipe horizontal 
    var max_y = 60;  //max y para swipe horizontal 

    var direccion = "";
    ele = elemento;

    ele.addEventListener('touchstart', function (e) {
        var t = e.touches[0];
        deteccion_swipe.sX = t.screenX;
        deteccion_swipe.sY = t.screenY;
        deteccion_swipe.cX = t.clientX;

    }, false);

    ele.addEventListener('touchmove', function (e) {

        //e.preventDefault()

        //window.scrollTo(window.scrollX, window.scrollY);
        var t = e.touches[0];
        deteccion_swipe.eX = t.screenX;
        deteccion_swipe.eY = t.screenY;

        //e.cancelBubble = true
    }, { passive: false });

    ele.addEventListener('touchend', function (e) {
        //e.preventDefault()
        if ((((deteccion_swipe.eX - min_x > deteccion_swipe.sX) || (deteccion_swipe.eX + min_x < deteccion_swipe.sX)) && ((deteccion_swipe.eY < deteccion_swipe.sY + max_y) && (deteccion_swipe.sY > deteccion_swipe.eY - max_y) && (deteccion_swipe.eX > 0)))) {
            if (deteccion_swipe.eX > deteccion_swipe.sX) direccion = "derecha";
            else direccion = "izquierda";
        }

        if (funcion === "colapsar") {

            if (menuDerechoVisible && direccion === "derecha") {
                //mostrarMenuDerecho()
            }
            else if ($('divMenu').style.display === '' && direccion === "izquierda") {
                mostrarMenuIzquierdo()
            }
        }
        else if (direccion == "izquierda" && funcion === "mostrar") {
            if (inicial && (($$("body")[0].getWidth() - inicial) < deteccion_swipe.cX)) {
                //mostrarMenuDerechoSwipe(elemento.id, direccion);
            }
        }
        else if (direccion == "derecha" && funcion === "mostrar") {
            if (inicial && (deteccion_swipe.cX < inicial))
                mostrarMenuIzquierdoSwipe(elemento.id, direccion);
        }
        direccion = "";
        deteccion_swipe.sX = 0; deteccion_swipe.sY = 0; deteccion_swipe.eX = 0; deteccion_swipe.eY = 0;
    }, false);
}


function mostrarMenuIzquierdoSwipe(elemento, direccion) {
    if (elemento === "body" && $('divMenu').style.display !== '' && direccion === "derecha")
        mostrarMenuIzquierdo()
    if ((elemento === (vMenuLeft.canvasMobile) || elemento === ("menu_left_vidrio")) && direccion === "izquierda")
        mostrarMenuIzquierdo()
}


function mostrarMenuDerechoSwipe(elemento, direccion) {
    if (elemento === "body" && !menuDerechoVisible && direccion === "izquierda")
        mostrarMenuDerecho()
    if ((elemento === (vMenuRight.canvasMobile) || elemento === ("menu_right_vidrio")) && direccion === "derecha")
        mostrarMenuDerecho()
}


function mostrarMenuIzquierdo() {
    //if (document.activeElement.name != undefined) {
    //    ; $(document.activeElement.name).blur()
    //} //quitar el focus para ocultar el teclado mobile y el menu se muestre completo

    //  $('nro_docu').focus()
    // $(vMenuLeft.canvasMobile).style.height = ($$("body")[0].getHeight() + 60 - $("top_menu").getHeight()) + "px";
    $(vMenuLeft.canvasMobile).style.zIndex = "1"

    //$("divMenu").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";
    //$("menu_left_vidrio").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";

    if ($('divMenu').style.display !== '') {
        $(vMenuLeft.canvasMobile).show();
        $("divMenu").show();
    }
    else {
        /*if (menuDerechoVisible) {
        mostrarMenuDerecho();
        }*/
        $(vMenuLeft.canvasMobile).hide();

        $("divMenu").hide();
    }
    window_onresize_menu();
    //$(vMenuLeft.canvasMobile).style.height = '100%';
}


var menuDerechoVisible = false;
function mostrarMenuDerecho() {
    menuDerechoVisible = !menuDerechoVisible
    $(vMenuRight.canvasMobile).style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";
    $("menu_right_vidrio").style.height = ($$("body")[0].getHeight() - $("top_menu").getHeight()) + "px";

    if (!menuDerechoVisible) {
        $(vMenuRight.canvasMobile).style.right = "-540px";
        $("menu_right_vidrio").style.left = "-540px";
    }
    else {
        if ($('divMenu').style.display === '') {
            mostrarMenuIzquierdo();
        }

        $(vMenuRight.canvasMobile).style.right = "0px";
        $("menu_right_vidrio").style.left = "0px";
    }
}


//############################################
//##########------FUNCION BACK------##########
//############################################


function establecerFuncionBack(event) {

    /* var isSafari = /constructor/i.test(window.HTMLElement) || (function (p) { return p.toString() === "[object SafariRemoteNotification]"; })(!window['safari'] || (typeof safari !== 'undefined' && safari.pushNotification));
     if (isSafari) {
         history.pushState({}, '', '');
         return;
     }*/

    if (window.top.Windows.modalWindows.length > 0) {
        window.top.Windows.focusedWindow.close()
        history.pushState(null, document.title, location.href);

        if (window.top.Windows.focusedWindow && window.top.Windows.focusedWindow.callback_onresize)
            window.top.Windows.focusedWindow.callback_onresize()
    }
    else {
        if ($('divMenu').style.display === '') {
            mostrarMenuIzquierdo()
            history.pushState(null, document.title, location.href);
        }
        else if (menuDerechoVisible) {
            mostrarMenuDerecho()
            history.pushState(null, document.title, location.href);
        }
        else {
            var vent = confirm("¿Desea salir?, Verifique haber guardado los cambios.")
            vent.okCallback = function () {
                if (nvFW.nvInterOP) {
                    nvFW.nvInterOP.sendMessage('close_app', '')
                }
                else {
                    window.removeEventListener('popstate', establecerFuncionBack);
                    history.back();
                }

                vent.cancelCallback = function () {
                    history.pushState(null, document.title, location.href);
                }
            }
        }
    }


    history.pushState(null, document.title, location.href);
    window.addEventListener('popstate', establecerFuncionBack);
}


//############################################
//########-------MENU Y BOTONES-------########
//############################################

var menuRight = false;

var vButtonItems = {}
//vButtonItems[0] = {}
//vButtonItems[0]["nombre"] = "PBuscar";
//vButtonItems[0]["etiqueta"] = " Buscar";
//vButtonItems[0]["imagen"] = "buscar";
//vButtonItems[0]["onclick"] = "return consulta.cliente_buscar()";
//vButtonItems[0]["estilo"] = "M";

vButtonItems[0] = {}
vButtonItems[0]["nombre"] = "PlanBuscar";
vButtonItems[0]["etiqueta"] = "Buscar";
vButtonItems[0]["imagen"] = "";
vButtonItems[0]["onclick"] = "return Validar_datos()";
vButtonItems[0]["estilo"] = "M";

vButtonItems[1] = {}
vButtonItems[1]["nombre"] = "PLimpiar";
vButtonItems[1]["etiqueta"] = "Limpiar";
vButtonItems[1]["imagen"] = "limpiar";
vButtonItems[1]["onclick"] = "return consulta.limpiar()";
vButtonItems[1]["estilo"] = "L";

vButtonItems[2] = {}
vButtonItems[2]["nombre"] = "PMesa";
vButtonItems[2]["etiqueta"] = "Mesa de ayuda";
vButtonItems[2]["imagen"] = "telefono";
vButtonItems[2]["estilo"] = "I";
vButtonItems[2]["onclick"] = "alert('No implementado')";

vButtonItems[3] = {}
vButtonItems[3]["nombre"] = "CobroNext";
vButtonItems[3]["etiqueta"] = "Siguiente";
vButtonItems[3]["imagen"] = "";
vButtonItems[3]["onclick"] = "return sel_cobro(true)";
vButtonItems[3]["estilo"] = "M";

vButtonItems[4] = {}
vButtonItems[4]["nombre"] = "CobroPrev";
vButtonItems[4]["etiqueta"] = "Volver";
vButtonItems[4]["imagen"] = "";
vButtonItems[4]["estilo"] = "I";
vButtonItems[4]["onclick"] = "return sel_cobro(false)";

vButtonItems[5] = {}
vButtonItems[5]["nombre"] = "OfertaNext";
vButtonItems[5]["etiqueta"] = "Confírmar";
vButtonItems[5]["imagen"] = "";
vButtonItems[5]["onclick"] = "return GuardarSolicitud('H')";
vButtonItems[5]["estilo"] = "M";

vButtonItems[6] = {}
vButtonItems[6]["nombre"] = "OfertaLimpiar";
vButtonItems[6]["etiqueta"] = "Limpiar";
vButtonItems[6]["imagen"] = "";
vButtonItems[6]["estilo"] = "I";
vButtonItems[6]["onclick"] = "return consulta.limpiar()";

vButtonItems[7] = {}
vButtonItems[7]["nombre"] = "TrabajoPrev";
vButtonItems[7]["etiqueta"] = "Volver";
vButtonItems[7]["imagen"] = "";
vButtonItems[7]["estilo"] = "I";
vButtonItems[7]["onclick"] = "return consulta.limpiar()";

vButtonItems[8] = {}
vButtonItems[8]["nombre"] = "TrabajoNext";
vButtonItems[8]["etiqueta"] = "Siguiente";
vButtonItems[8]["imagen"] = "";
vButtonItems[8]["estilo"] = "M";
vButtonItems[8]["onclick"] = "return consulta.cobro_seleccionar()";


var vListButtons = new tListButton(vButtonItems, 'vListButtons');
vListButtons.loadImage("buscar", "image/search_16.png");
vListButtons.loadImage("volver", "image/a_left_2.png");
vListButtons.loadImage("credito", "image/us_dollar_16.png");
vListButtons.loadImage("nuevo", "image/text_document_24.png");
vListButtons.loadImage("guardar", "image/guardar.png");
vListButtons.loadImage("telefono", "image/telefono.svg")
vListButtons.loadImage("limpiar", "/FW/image/icons/eliminar.svg");
//vListButtons.loadImage("ver", "image/preview_16.png");
vListButtons.loadImage("noti", "image/send-16.png");
vListButtons.loadImage("pdf", "../FW/image/filetype/pdf.png");
vListButtons.loadImage("abrir_chat", "../FW/image/icons/comentario3.png");
//vListButtons.loadImage("limpiar", "../FW/image/icons/eliminar.png");
vListButtons.loadImage("cuenta", "../FW/image/icons/cuenta.png");


function cargarMenuLeft(vMenuLeft) {
    
    
    //vMenuLeft.loadImage("star", "image/star.svg")
    vMenuLeft.loadImage("inicio", "image/inicio.png")
    vMenuLeft.loadImage("volver", "/FW/image/icons/izquierda.png")
    vMenuLeft.loadImage("money", "image/money.png")
    vMenuLeft.loadImage("ventas", "image/ventas.png")
    vMenuLeft.loadImage("cartera", "image/cartera.png")
    vMenuLeft.loadImage("campania", "image/campania.png")
    vMenuLeft.loadImage("categorias", "image/categorias.png")
    vMenuLeft.loadImage("tutoriales", "image/tutoriales.png")
    vMenuLeft.loadImage("notificaciones", "image/notificaciones.png")
    vMenuLeft.loadImage("bloquear", "image/bloquear.png")
    vMenuLeft.loadImage("cerrar", "image/cerrar.png")


    //let styleMenu1 = 'background-color: var(--azul); color: var(--blanco); vertical-align: middle; padding-top: 25px; padding-bottom: 25px;';
    //Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='1' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>volver</icono><Desc>Volver</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarMenuIzquierdo()</Codigo></Ejecutar></Acciones></MenuItem>")
    //vMenuLeft.CargarMenuItemXML("<MenuItem id='1' style='" + styleMenu1 + "'><Lib TipoLib='offLine'>DocMNG</Lib><icono>star</icono><Desc></Desc><Acciones><Ejecutar Tipo='script'><Codigo>Inicio()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='1' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>inicio</icono><Desc>Inicio</Desc><Acciones><Ejecutar Tipo='script'><Codigo>consulta.limpiar()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='2' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>money</icono><Desc>Mis créditos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>VerCreditos('V')</Codigo></Ejecutar></Acciones></MenuItem>")
    //vMenuLeft.CargarMenuItemXML("<MenuItem id='3' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Vendedor</Desc><Acciones><Ejecutar Tipo='script'><Codigo>selVendedor_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='4' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>ventas</icono><Desc>Mis ventas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>precarga.show_modal_window({ url: 'estadisticas/stats_default.aspx', title: '<b>Seleccionar Vendedor</b>' })</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='5' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cartera</icono><Desc>Cartera activa</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alert('No implementado')</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='6' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>campania</icono><Desc>Campaña de ventas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alert('No implementado')</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='7' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>categorias</icono><Desc>Categoría de vendedor</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alert('No implementado')</Codigo></Ejecutar></Acciones></MenuItem>")
    //vMenuLeft.CargarMenuItemXML("<MenuItem id'4' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Formularios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Descargar_formularios()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='8' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>tutoriales</icono><Desc>Tutoriales</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verTutoriales()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='9' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>notificaciones</icono><Desc>Notificaciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>alert('No implementado')</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='10' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>bloquear</icono><Desc>Bloquear Sesión</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nvSesion.bloquear()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenuLeft.CargarMenuItemXML("<MenuItem id='11' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cerrar</icono><Desc>Cerrar Sesión</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nvSesion.cerrar()</Codigo></Ejecutar></Acciones></MenuItem>")
    
    //$('divInfoVendedor').insert({ bottom: '<div></div>' })

    //if (isMobile()) {
    //    Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>app</icono><Desc>Aplicación</Desc><Acciones><Ejecutar Tipo='script'><Codigo>descargar_app()</Codigo></Ejecutar></Acciones></MenuItem>")
    //}

    //if(estructura_genera_codigo.indexOf(+nvFW.operador.nro_estructura)>=0 || nvFW.operador.nro_estructura==""){
    //Menus["vMenuLeft"].CargarMenuItemXML("<MenuItem id='6' style='cursor:pointer'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cuenta</icono><Desc>Generar codigo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Generar_codigo()</Codigo></Ejecutar></Acciones></MenuItem>")         
    //}
}

//############################################
//##########-------NO SE USAN-------##########
//############################################

var vMenuRight = new tMenu('menu_right', 'vMenuRight');
var DocumentMNG = new tDMOffLine;
function cargarMenuRight() {
    // cargar menu
    vMenuRight.alineacion = 'izquierda';
    vMenuRight.estilo = 'O'
    vMenuRight.loadImage("inicio", "/fw/image/icons/home.png")
    vMenuRight.loadImage("upload", "/fw/image/icons/play.png")
    vMenuRight.loadImage("ref", "/fw/image/icons/info.png")
    vMenuRight.loadImage("nueva", "/fw/image/icons/nueva.png")
    vMenuRight.loadImage("servicio_asignar", "/fw/image/icons/play.png")
    vMenuRight.loadImage("buscar", "/fw/image/icons/buscar.png")
    vMenuRight.loadImage("vincular", "/fw/image/security/vincular.png")
    vMenuRight.loadImage("herramientas", "/fw/image/icons/herramientas.png")
    vMenuRight.loadImage("operador", "/fw/image/icons/operador.png")
    vMenuRight.loadImage("permiso", "/fw/image/icons/permiso.png")
    vMenuRight.loadImage("imprimir", "/fw/image/icons/imprimir.png")

    vMenuRight.loadImage("parametros", "/fw/image/icons/imprimir.png")
    vMenuRight.loadImage("play", "/fw/image/icons/imprimir.png")

    //Importante: Nombre de la ventana que contendrá los documentos 

    DocumentMNG.APP_PATH = window.location.href;
    var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', 'ref_mnu_cabecera')
    vMenuRight.CargarXML(strXML);

    // vMenuRight.MostrarMenu(tamanio.ocultarMenu);//DESATIVADO POR AHORA TODO , PARA VERSION PROD
}