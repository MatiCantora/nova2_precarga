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

function tMobile(nombreMenuLeft, nombreMenuTop, contenedor) {

    /*Funciones*/
    this.generarMenu = generarMenu;
    this.mostrarMenuIzquierdo = mostrarMenuIzquierdo;
    this.resize = resize;
    this.showMenuLeft = showMenuLeft;
    this.hideMenuLeft = hideMenuLeft;
    this.addItemMenuLeft = addItemMenuLeft;
    this.generarBotonesMenuLeft = generarBotonesMenuLeft;
    this.scroll_event = scroll_event;
    this.nvtWinDefault = nvtWinDefault
    this.mostrarMenuIzquierdoSwipe = mostrarMenuIzquierdoSwipe

    /*Variables*/
    this.nombreMenuLeft = nombreMenuLeft;
    this.nombreMenuTop = nombreMenuTop;
    this.menuLeftItems = [];
    this.vButtonItemsMenuLeft =  new Array();
    this.vListButtonsMenuLeft;
    this.nombreUsuario = nombreUsuario
    this.urlLogo = "/precarga/image/nova-aux.svg"
    this.contenedor = contenedor

    function addItemMenuLeft(nombrediv, nombre, funcion, imagen) {

        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length] = {}
        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length-1]["nombre"] = nombrediv;
        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length-1]["etiqueta"] = nombre;
        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length - 1]["imagen"] = "etiqueta_imagen_" + nombrediv;
        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length - 1]["urlimagen"] = imagen;
        this.vButtonItemsMenuLeft[this.vButtonItemsMenuLeft.length-1]["onclick"] = funcion;

    }

    function generarBotonesMenuLeft() {
        var html = new Array()
        this.vListButtonsMenuLeft = new tListButton(this.vButtonItemsMenuLeft, 'vListButtonsMenuLeft');
        
        for (var i = 0; i < this.vButtonItemsMenuLeft.length; i++) {
            html[i] = ""
            html[i] += "<tr>"
            html[i] += "<td style='border: none' title='" + this.vButtonItemsMenuLeft[i]["etiqueta"] + "'>"
            html[i] += "<div style='margin: auto;width: 80%' id='div" + this.vButtonItemsMenuLeft[i]["nombre"] + "' />"
            html[i] += "</td>"
            html[i] += "</tr>"
            
            this.vListButtonsMenuLeft.loadImage(this.vButtonItemsMenuLeft[i]["imagen"], this.vButtonItemsMenuLeft[i]["urlimagen"]);
        }
        return html
    }

    function showMenuLeft() {
        $(this.nombreMenuLeft + "_menu_left").show();
        $(this.nombreMenuLeft + "_menu_left_vidrio").show();
    }

    function hideMenuLeft() {
        $(this.nombreMenuLeft + "_menu_left").hide();
        $(this.nombreMenuLeft + "_menu_left_vidrio").hide();
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

    var menuIzquierdoVisible = false;
    function mostrarMenuIzquierdo() {
        menuIzquierdoVisible = !menuIzquierdoVisible
        $(this.nombreMenuLeft + "_menu_left").style.height = ($$("body")[0].getHeight() - $(this.nombreMenuTop + "_menu_top").getHeight()) + "px";
        $(this.nombreMenuLeft + "_menu_left_vidrio").style.height = ($$("body")[0].getHeight() - $(this.nombreMenuTop + "_menu_top").getHeight()) + "px";

        if (!menuIzquierdoVisible) {
            $(this.nombreMenuLeft + "_menu_left").style.left = "-500px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.right = "-500px";

        }
        else {
            $(this.nombreMenuLeft + "_menu_left").style.left = "0px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.right = "0px";
        }
    }

    /*Esta funcion genera los menus top y left, para esto es necesario proveer los nombres de ambos menus en nombreMenuLeft y nombreMenuTop*/
    function generarMenu() {

        var htmlMenuLeft = "";
        if (this.nombreMenuLeft) {
            htmlMenuLeft = '<div id="' + this.nombreMenuLeft + "_menu_left" + '" style="background-color: white; position: fixed; left: -500px; bottom: 0px; transition: .3s all;border-right: 3px solid #E3E0E3;" ><table class="tb1" style="padding-top:7px" >'

            var botones = this.generarBotonesMenuLeft();

            htmlMenuLeft += botones[0] + "<tr style='height: 7px;'><td><hr style='width:90%;border-color: #E3E0E3;'></td></tr>"

            for (var i = 1; i < botones.length; i++) {
                htmlMenuLeft += botones[i]
            }

            htmlMenuLeft += '</table></div><div onclick="menu.mostrarMenuIzquierdo()" id="' + this.nombreMenuLeft + "_menu_left_vidrio" + '" style="background-color: white; position: fixed; right: -500px; bottom: 0px; filter: alpha(opacity=0); opacity: 0.0; width: 50px;"></div>'
            
            $(this.nombreMenuLeft).innerHTML = htmlMenuLeft;

            this.vListButtonsMenuLeft.MostrarListButton()


            $(this.nombreMenuLeft + "_menu_left").style.height = ($$("body")[0].getHeight() - $(this.nombreMenuTop).getHeight()) + "px";
            $(this.nombreMenuLeft + "_menu_left").style.width = ($$("body")[0].getWidth()) * 0.7 + "px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.height = ($$("body")[0].getHeight() - $(this.nombreMenuTop).getHeight()) + "px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.width = ($$("body")[0].getWidth()) * 0.3 + "px";
        }

        if (this.nombreMenuTop) {
            htmlMenuLeft = ""

            htmlMenuLeft += "<table id='" + this.nombreMenuTop + "_menu_top" + "' border='0' class='tb1 tablelarge' style='border-bottom: 3px solid #E3E0E3;'>"
            htmlMenuLeft += "<tr>"
            htmlMenuLeft += "<td style='width: 32px;' id='imgMenu'>"
            htmlMenuLeft += "<img style='height: 32px; width: 32px;' border='0' class ='img_button_sesion' alt='Menu' title='Menú' src='/precarga/image/menu.png' onclick='menu.mostrarMenuIzquierdo()' />"
            htmlMenuLeft += "</td>"
            htmlMenuLeft += "<td style='align: left; text-align: left'>"

            htmlMenuLeft += "<object data='"+this.urlLogo+"' id='" + this.nombreMenuTop + "_logo" + "' class='logo' type='image/svg+xml'>"
            htmlMenuLeft += "<img src='/fw/image/nvLogin/nvLogin_logo.png' alt='PNG image of standAlone.svg' />"
            htmlMenuLeft += "</object>"
            htmlMenuLeft += "</td>"
            htmlMenuLeft += "<td id='data_user' style='text-align: right; vertical-align: middle' nowrap>"
               
            if(this.nombreUsuario)
                htmlMenuLeft +=  "<span id='user_name' nowrap>" + this.nombreUsuario + "</span>"

           htmlMenuLeft += "<img border='0' style='height: 32px; width: 32px' id='imgbloqueo_sesion' class='img_button_sesion' alt='Bloquear sesión' title='Bloquear sesión' src='/precarga/image/bloquear_sesion.png' onclick='nvSesion.bloquear()' />"
           htmlMenuLeft += "<img border='0' style='height: 32px; width: 32px' id='imgbutton_sesion' class='img_button_sesion' alt='Cerrar sesión' title='Cerrar sesión' src='/precarga/image/sesion_cerrar.gif' onclick='nvSesion.cerrar()' />"

           htmlMenuLeft += "</td>"
           htmlMenuLeft += "</tr>"
           htmlMenuLeft += "</table>"

           $(this.nombreMenuTop).innerHTML = htmlMenuLeft
            
           this.contenedor.onscroll = this.scroll_event.bind(this)

           detectSwipe(this.contenedor, this.mostrarMenuIzquierdoSwipe.bind(this),50);
           detectSwipe($(this.nombreMenuLeft + "_menu_left"), this.mostrarMenuIzquierdoSwipe.bind(this));
           detectSwipe($(this.nombreMenuLeft + "_menu_left_vidrio"), this.mostrarMenuIzquierdoSwipe.bind(this));
        }
    }

    /*Si el elemento sobre el cual se efectua scrolling, contiene al menu top, entonces no es necesario cambiar nada.
    En otro caso la funcion nombre_del_menu.scroll_event(this) debe ser invocada como un evento oncroll desde el elemento que se scrollea*/
    var calcularScrollEvent;
    function scroll_event(e) {
        
        if (!isMobile())
            return
        
        var contenedor = this.contenedor
        
        if (contenedor.scrollTop > 1) {
            if (calcularScrollEvent != "top") {
                calcularScrollEvent = "top"
                $(this.nombreMenuTop + "_menu_top").className = "tb1 tablesmall"
                $(this.nombreMenuTop).className = "small"
                $(this.nombreMenuTop).style = "filter:alpha(opacity=90); opacity:0.9;"
                $(this.nombreMenuTop + "_logo").style = "width: 125px;height: 40px;top: 0px;"
                $("imgbloqueo_sesion").style = "height:24px;width:24px"
                $("imgbutton_sesion").style = "height:24px;width:24px"
                this.resize()
            }
        } else {
            if (calcularScrollEvent != "not_top") {
                calcularScrollEvent = "not_top"
                $(this.nombreMenuTop + "_menu_top").className = "tb1 tablelarge"
                $(this.nombreMenuTop).className = "large"
                $(this.nombreMenuTop).style = "filter:alpha(opacity=100); opacity:1;"
                $(this.nombreMenuTop + "_logo").style = "width: 150px;height: 50px;top: 0px;"
                $("imgbloqueo_sesion").style = "height:32px;width:32px"
                $("imgbutton_sesion").style = "height:32px;width:32px"
                this.resize()
            }
        }
    }

    function detectSwipe(elemento, funcion,inicial) {

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
            //e.preventDefault();
            var t = e.touches[0];
            deteccion_swipe.eX = t.screenX;
            deteccion_swipe.eY = t.screenY;
        }, false);
        
        ele.addEventListener('touchend', function (e) {
            if ((((deteccion_swipe.eX - min_x > deteccion_swipe.sX) || (deteccion_swipe.eX + min_x < deteccion_swipe.sX)) && ((deteccion_swipe.eY < deteccion_swipe.sY + max_y) && (deteccion_swipe.sY > deteccion_swipe.eY - max_y) && (deteccion_swipe.eX > 0)))) {
                if (deteccion_swipe.eX > deteccion_swipe.sX) direccion = "derecha";
                else direccion = "izquierda";
            }
            
            if (inicial && (deteccion_swipe.cX > inicial))
                direccion = ""

            if (direccion != "") {
                if (typeof funcion == 'function') funcion(elemento.id, direccion);
            }
            direccion = "";
            deteccion_swipe.sX = 0; deteccion_swipe.sY = 0; deteccion_swipe.eX = 0; deteccion_swipe.eY = 0;
        }, false);
    }

    function mostrarMenuIzquierdoSwipe(elemento, direccion) {
        if (elemento === this.contenedor.id && !menuIzquierdoVisible && direccion === "derecha")
            this.mostrarMenuIzquierdo()
        if ((elemento ===( this.nombreMenuLeft + "_menu_left") || elemento ===( this.nombreMenuLeft + "_menu_left_vidrio")) && direccion === "izquierda")
            this.mostrarMenuIzquierdo()
    }

    function resize() {
        if (isMobile()) {

            var tamanio = nvtWinDefault(this.nombreMenuLeft + "_menu_left", this.nombreMenuTop + "_menu_top")
            
            $(this.nombreMenuLeft + "_menu_left").style.height = tamanio.div_left.height //($$("body")[0].getHeight() - $(this.nombreMenuTop + "_menu_top").getHeight()) + "px";
            $(this.nombreMenuLeft + "_menu_left").style.width = tamanio.div_left.width //($$("body")[0].getWidth()) * 0.7 + "px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.height = tamanio.div_left_vidrio.height //($$("body")[0].getHeight() - $(this.nombreMenuTop + "_menu_top").getHeight()) + "px";
            $(this.nombreMenuLeft + "_menu_left_vidrio").style.width = tamanio.div_left_vidrio.width//($$("body")[0].getWidth()) * 0.3 + "px";
            
        }
    }

}
