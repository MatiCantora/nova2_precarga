function tUndo(options) {
    
    this.list = [];
    this.index = -1;
    this.id = options.id;

    this.add = tUndo_add;
    this.undo = tUndo_undo;
    this.redo = tUndo_redo;
    this.reset = tUndo_reset;
    this.inicializar = tUndo_inicializar;

    this.onRedo = null;
    this.onUndo = null;

    this.wUndo = null;
    this.onOpenWindow = tUndo_windowShow;

    this.setHtml = tUndo_setHtml;
    this.setHtml()

    var __construct = function(t_undo, options) {
        if (!options) {
            options = {};
        }
        t_undo.container = options.container === undefined ? $($(document)) : options.container;

        t_undo.onUndo = options.onUndo === undefined ? function() {
        } : options.onUndo;
        t_undo.onRedo = options.onRedo === undefined ? function() {
        } : options.onRedo;

        if (options.container !== undefined) {
            t_undo.container.setAttribute('tabindex', 9999999);
            Event.observe(t_undo.container, "click", function(event) {
                t_undo.container.focus();
            });
        }

        var ctrlDown = false;
        var ctrlKey = 17, zKey = 90, yKey = 89; 
        Event.observe(t_undo.container, "keydown", function(event) {
            if (event.keyCode == ctrlKey) {
                ctrlDown = true;
            }
        });
        Event.observe(t_undo.container, "keyup", function(event) {
            if (event.keyCode == ctrlKey) {
                ctrlDown = false;
            }
        });
        Event.observe(t_undo.container, "keydown", function(event) {
            if (ctrlDown) {
                if (event.keyCode == zKey) {
                    t_undo.undo();
                }
                if (event.keyCode == yKey) {
                    t_undo.redo();
                }
            }
        });
    }(this, options);
}

function tUndo_add(obj,desc,check_point) {

    if (!desc)
      desc = "Insertar deshacer"

    if (!check_point)
      check_point = false

    var list_obj = {};
    list_obj.obj = obj
    list_obj.desc = desc
    list_obj.check_point = check_point
    list_obj.fecha = new Date() //FechaToSTR(new Date()) + " " + TiempoToSTR(new Date())

    if (this.list[this.index] == undefined || this.list[this.index] != list_obj) {
        if (this.index < (this.list.length - 1)) {
            this.list = this.list.slice(0, this.index + 1);
        }
        
        this.list.push(list_obj);
        this.index = this.list.length - 1;
        this.temp = null;
        
        Undo_addUndoHtml(this)

        return true;
    }
    return false;
}
function tUndo_undo(indice) {
    
    var state = false;
    if (typeof(indice) !== "undefined") {
        state = this.list[indice];
        this.onUndo(state, indice);
        this.index = indice
    }
    else
      if (this.index > 0) {
        state = this.list[--this.index];
        this.onUndo(state, this.index);
      }

    //if (state)
    //    insertSelUndo(this)

    return state;
}
function tUndo_redo(indice) {
    
    var state = false;
    if (typeof (indice) !== "undefined"){
       state = this.list[indice];
       this.onRedo(state, indice);
        this.index = indice
     }
    else
      if(this.index <= (this.list.length - 1)) {
         state = this.list[++this.index];
          this.onRedo(state, this.index);
      }

    //if (state)
    //    insertSelRedo(this)

    return state;
}
function tUndo_reset() {
    this.list = [this.list[this.list.length - 1]];
    this.index = 0;
}

function TiempoToSTR(objFecha) {
    var horas = parseInt(objFecha.getHours(), 10)
    var minutos = parseInt(objFecha.getMinutes(), 10)
    var segundos = parseInt(objFecha.getSeconds(), 10)

    horas = horas < 10 ? '0' + horas : horas
    minutos = minutos < 10 ? '0' + minutos : minutos
    segundos = segundos < 10 ? '0' + segundos : segundos

    return horas + ':' + minutos + ':' + segundos
}

function tUndo_setHtml() {

    if (!$('div' + this.id)) {
        alert("Inserte div undo")
        return
    }

    $('div' + this.id).hide()

    var html = '<table class="tb1" id="tbCabe">'
    html += '<tr>'
    html += '<td style="width:5%" class="Tit1">-</td>'
    html += '<td class="Tit1">Descripción</td>'
  //  html += '<td style="width:15%;white-space:nowrap" class="Tit1">Check Point</td>'
    html += '</tr>'
    html += '</table>'
    html += '<table class="tb1" id="tbRow">'
    html += '<tr>'
    html += '<td style="width:100%"><div id="list_undo" style="overflow:auto"/></td>'
    html += '</tr>'
    html += '</table>'
    
    $("div" + this.id).innerHTML = html

}


function Undo_addUndoHtml(obj) {
    
    var div = 'list_undo' 

    var desc = TiempoToSTR(obj.list[obj.index].fecha) + " " + obj.list[obj.index].desc
    var check_point = obj.list[obj.index].check_point ? ' checked="checked" ' : ''

    var html = '<table class="tb1 highlightOdd highlightTROver layout_fixed">'
    html += '<tr>'
    html += '<td style="width:5%"><img src="/fw/image/transferencia/undo.png" onclick="' + obj.id + '.undo(' + obj.index +')" style="cursor:pointer"/></td>'
    html += '<td>' + desc + '</td>'
    //html += '<td style="width:15%;text-align:center"><input type="checkbox" id="check_point' + obj.index + '" ' + check_point + ' onclick="return Undo_checkpoint(event,'+ obj.id +')"/></td>'
    html += '</tr>'
    html += '</table>'
    
    $$('body')[0].querySelectorAll("#" + div)[0].insertAdjacentHTML("BeforeEnd", html)

    if (obj.wUndo) {
        $$('body')[0].querySelectorAll("#list_undo")[0].setStyle({ height: (obj.wUndo.getSize().height - 22) + 'px' })
    }

}

function Undo_checkpoint(e,obj) {

    var el = Event.element(e)

    var index = el.id.split("check_point")[1]
    obj.list[index].check_point = el.checked

}

function Undo_addRedoHtml(obj) {

    div = 'row_undo' + obj.id

    var html = '<table class="tb1">'
    html += '<tr>'
    html += '<td style="width:5%"><img src="/fw/image/transferencia/redo.png" onclick="' + this.id + '.redo()" style="cursor:pointer" /></td>'
    html += '<td><div id="sel_undo' + this.id + '" ></td>'
    html += '</tr>'
    html += '</table>'

    $(div).innerHTML = html

}


//function insertSelUndo(obj) {

//    cb_undo = 'sel_undo' + obj.id
//    cb_redo = 'sel_redo' + obj.id

//    if (!$(cb_undo) || !$(cb_redo))
//        return

//    var mover_hasta = $(cb_undo).value
//    var mover = [];
//    for (var i = 0; i < $(cb_undo).length; i++) {
//        if ($(cb_undo)[i].value >= $(cb_undo).value) {
//            mover.push($(cb_undo)[i].value)
//        }
//    }

//    var j
//    var primera_vez = false
//    for (j = mover.length - 1; j >= 0; j--) {

//        $(cb_undo).value = mover[j]

//        var index_existe = -1
//        for (var i = 0; i < $(cb_redo).length; i++) {
//            if ($(cb_redo)[i].value == $(cb_undo).value) {
//                index_existe = i;
//                continue
//            }
//        }

//        if (index_existe == -1) {
//            var option = document.createElement("option");
//            option.value = $(cb_undo).value
//            option.text = $(cb_undo).options[$(cb_undo).selectedIndex].text
//            if (!primera_vez) {
//                option.selected = true
//                primera_vez = true
//            }
//            $(cb_redo).add(option)
//            index_existe = $(cb_redo).length - 1
//        }

//        $(cb_redo)[index_existe].value = $(cb_undo).value
//        $(cb_redo)[index_existe].text = $(cb_undo).options[$(cb_undo).selectedIndex].text

//        $(cb_undo).remove($(cb_undo).selectedIndex)

//    }
//}

//function insertSelRedo(obj) {

//    cb_redo = 'sel_redo' + obj.id
//    cb_undo = 'sel_undo' + obj.id

//    if (!$(cb_undo) || !$(cb_redo))
//        return

//    var mover_hasta = $(cb_redo).value
//    var mover = [];
//    for (var i = 0; i < $(cb_redo).length; i++) {
//        if ($(cb_redo)[i].value <= $(cb_redo).value) {
//            mover.push($(cb_redo)[i].value)
//        }
//    }

//    for (var j = 0; j < mover.length; j++) {

//        $(cb_redo).value = mover[j]

//        var index_existe = -1
//        for (var i = 0; i < $(cb_undo).length; i++) {
//            if ($(cb_undo)[i].value == $(cb_redo).value) {
//                index_existe = i;
//                continue
//            }
//        }

//        if (index_existe == -1) {
//            var option = document.createElement("option");
//            option.value = $(cb_redo).value
//            option.text = $(cb_redo).options[$(cb_redo).selectedIndex].text
//            option.selected = true
//            $(cb_undo).add(option, 0)
//            index_existe = $(cb_undo).length - 1
//        }
//        else {
//            $(cb_undo)[index_existe].text = $(cb_redo).options[$(cb_redo).selectedIndex].text
//            $(cb_undo)[index_existe].value = $(cb_redo).value
//        }

//        $(cb_redo).remove($(cb_redo).selectedIndex)

//    }
//}


//function onclickSelUndo(e, obj) {

//    cb_undo = $('sel_undo' + obj.id)

//    if (!cb_undo)
//        return

//    if (cb_undo.selectedIndex == -1)
//        return

//    var value = cb_undo.options[cb_undo.selectedIndex].value

//    obj.undo(value)
//}

//function onclickSelRedo(e, obj) {

//    cb_redo = $('sel_redo' + obj.id)

//    if (!cb_redo)
//        return

//    if (cb_redo.selectedIndex == -1)
//        return

//    var value = cb_redo.options[cb_redo.selectedIndex].value

//    obj.redo(value)
//}

function tUndo_windowShow() {

    
    if (this.wUndo)
        if (!this.wUndo.oldStyle)
            return

    var div = $("div" + this.id)

    this.wUndo = nvFW.createWindow({
        width: 350, height: 200,
        draggable: true,
        resizable: true,
        closable: true,
        minimizable: false,
        maximizable: false,
        title: "<b>Seguimiento de Cambios</b>",
        destroy: true,
        onResize: function (win) {
            var calc = (win.getSize().height - 30) + 'px'
            $$('body')[0].querySelectorAll("#list_undo")[0].setStyle({ height: calc })
        },
        onShow: function (win) {
        },
        onClose: function (win) {
            div.innerHTML = ""
            div.innerHTML = win.getContent().innerHTML
            win.destroy()
        }
    })

 
    this.wUndo.getContent().innerHTML = div.innerHTML 
    this.wUndo.show();
    this.wUndo.setLocation(48, $$('body')[0].getWidth() - 750);
    $(div).setStyle({ height: this.wUndo.height + 'px' })

}


function tUndo_inicializar() {

       //cb_redo = 'sel_redo' + this.id
       //cb_undo = 'sel_undo' + this.id

       //if ($(cb_undo))
       //    $(cb_undo).length = 0

       //if ($(cb_redo))
       //    $(cb_redo).length = 0

       this.list.length = 0
}


//function head_resize(idHead, idBody) {

//    var oHead = $(idHead)
//    var oBody = $(idBody)

//    if (oHead == undefined || oBody == undefined)
//        return

//    var colHead = oHead
//    while (colHead.nodeName.toUpperCase() != "TR" && $(colHead).childElements().length > 0)
//        colHead = $(colHead).childElements()[0]

//    var colBody = oBody
//    while (colBody.nodeName.toUpperCase() != "TR" && $(colBody).childElements().length > 0)
//        colBody = $(colBody).childElements()[0]

//    if ((colBody.nodeName.toUpperCase() != "TR") || (colHead.nodeName.toUpperCase() != "TR"))
//        return

//    var divBody = $(oBody.parentNode)


//    var colWidth
//    var tbBodyWidth = oBody.getWidth()
//    var scrollWidth = divBody.getWidth() - tbBodyWidth

//    for (var i = 0; i < colHead.childElements().length - 2; i++) {
//        $(colBody.childElements()[i]).setStyle({ width: $(colHead.childElements()[i]).getWidth() + "px" })
//    }

//    //Ajustar ultimo elemento
//    var hasVerticalScrollbar = divBody.scrollHeight > divBody.clientHeight
//    var i = colHead.childElements().length - 1
//    var widthScroll = 0
//    if (hasVerticalScrollbar)
//        widthScroll = 16
//    $(colBody.childElements()[i]).setStyle({ width: ($(colHead.childElements()[i]).getWidth() - widthScroll) + "px" })

//    return ""

//}   
