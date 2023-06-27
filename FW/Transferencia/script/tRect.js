/*if (!console) {
    var console = {
        log: function(data) {
//            alert(data)
        }
    }
}*/

/**********************************/
/**********************************/
function tnvControls()
{
    this.items = {} //Collecion de tRect y derivados de todo el documento
    //this.canvas = {}
    this.multiSelect = 'all' //define el modo de multiseleccion //'parent' - 'none' - 'all'
    /*
     this.icons = {}
     this.icons['arr_down'] = new Image()
     this.icons['arr_down'].src = '/FW/image/tnvRect/arr_down.png'
     this.icons['arr_up'] = new Image()
     this.icons['arr_up'].src = '/FW/image/tnvRect/arr_up.png'
     this.icons['arr_left'] = new Image()
     this.icons['arr_left'].src = '/FW/image/tnvRect/arr_left.png'
     this.icons['arr_right'] = new Image()
     this.icons['arr_right'].src = '/FW/image/tnvRect/arr_right.png'
     */
    this.generateID = tnvControls_generateID //Genera in id �nico para el nuevo objeto
    this.getRectById = tnvControls_getRectById //devuelve el objeto de la collecion de items por ID
    this.getRectByElement = tnvControls_getRectByElement //this.getRectByName = function(){name} //devuelve el objeto de la collecion de items por nombre

    this.dispose = tnvControls_dispose;

    //Vidrio
    this._div_glass = null
    this._glass_visible = function(valor)
    {
        var body = $$("BODY")[0]
        if (this._div_glass == null)
        {
            var strHTML = "<div id='div_glass' style='top:0px; left:0px; position: absolute; float: left; width: 100%; height: 100%; background-color: blue; z-index: 1000' />"
            body.insert({top: strHTML})
            this._div_glass = $('div_glass')
        }
        if (valor)
        {
            this._div_glass.show()
            this._div_glass.clonePosition(body)
            this._div_glass.setOpacity(0.2)
        }
        else
        {
            this._div_glass.hide()
        }

    }

    //DRAG AND DROP
    this._dad_begin = tnvRect_dad_begin
    this._dad_stop = tnvRect_dad_stop
    this._dad_move = tnvRect_dad_move
    this._dad_key = tnvRect_dad_key
    this._scut_key = tnvRect_scut_key

    this._drag_element = null
    this._drag_x = null
    this._drag_y = null
    this._drag_parent_x = null
    this._drag_parent_y = null
    this._dad_original_x = null
    this._dad_original_y = null

    //SIZE
    this._sz_begin = tnvRect_sz_begin
    this._sz_key = tnvRect_sz_key
    this._sz_stop = tnvRect_sz_stop
    this._sz_move = tnvRect_sz_move

    this._sz_element = null
    this._sz_original_w = null
    this._sz_original_h = null
    this._sz_x = null
    this._sz_y = null
    this._sz_original_cursor = null

    this._select_x = null
    this._select_y = null
    this._select_begin = tnvControls_mousedown
    this._select_move = tnvControls_mousemove

    //eventos
    this.onDragStart = function() {
    }
    this.onDragStop = function() {
    }
    this.onSizeStart = function() {
    }
    this.onSizeStop = function() {
    }

    //Arrow
    this._arrow_element = null
    //Anular menus contextuales
    $(document).oncontextmenu = function(e) {
        return false;
    }

   //activar teclas
   if (Prototype.Browser.IE || Prototype.Browser.WebKit) 
     Event.observe($(document), 'keyup', this._scut_key)
   else 
     Event.observe($(document), 'keypress', this._scut_key)

    Event.observe($(document), 'mousedown', this._select_begin)
    Event.observe($(document), 'mousemove', this._select_move)

}

function tnvControls_mouseup(e) {

    if (nvCtrls._select_x > 0 && nvCtrls._select_y > 0 && $('div_glass_selector')) {
        $('div_glass_selector').hide();

        var left = nvCtrls._select_x
        var top = nvCtrls._select_y

        var fin_x = left + $('div_glass_selector').getWidth()
        var fin_y = top + $('div_glass_selector').getHeight()
        var ini_x = left
        var ini_y = top

        for (var id in nvCtrls.items) {

            if (nvCtrls.items[id].type != "canvas") {

                var offset = nvCtrls.items[id].div.cumulativeOffset();
                var elem_punto_x = nvCtrls.items[id].left < offset.left ? nvCtrls.items[id].left : offset.left
                var elem_punto_y = nvCtrls.items[id].top < offset.top ? nvCtrls.items[id].top : offset.top

                if ((ini_x < elem_punto_x && elem_punto_x < fin_x) && (ini_y < elem_punto_y && elem_punto_y < fin_y)) {
                    nvCtrls.items[id].select(true)//!nvCtrls.items[id].selected)
                    //   console.log("origen " + ini_x + "," + ini_y_g + " destino " + fin_x + "," + fin_y + " - elemento: " + elem_punto_x + "," + elem_punto_y)
                }
            }

        }

        $('div_glass_selector').remove();
        nvCtrls._select_x = 0
        nvCtrls._select_y = 0
    }
}


function tnvControls_mousemove(e) {

    if (nvCtrls._select_x > 0 && nvCtrls._select_y > 0 && $('div_glass_selector')) {
        if (Event.isLeftClick(e)) {

            var offset = $('div_glass_selector').cumulativeOffset();

            var w = Event.pointerX(e) - offset.left
            var h = Event.pointerY(e) - offset.top

            w = w < 0 ? 0 : w;
            h = h < 0 ? 0 : h;

           // console.log(w + " ," + h)

            if ($('div_glass_selector'))
                $('div_glass_selector').setStyle({ 'width': w + 'px', 'height': h + 'px' });

            //console.log("origen: " + nvCtrls._select_x + "," + nvCtrls._select_y + " - destino: "+ nvCtrls._select_fin_x + "," + nvCtrls._select_fin_y)
        }
        else
            if ($('div_glass_selector'))
                $('div_glass_selector').remove();
    }

}

function tnvControls_mousedown(e) {

    //console.log("mousedown control")
    var el = Event.element(e)
    Event.observe($(document), 'mousedown', nvCtrls._select_begin)
    Event.observe($(document), 'mousemove', nvCtrls._select_move)

    var base = null
    try { base = el.up().up() } catch (e) { }
    if (base)
        if (nvCtrls.items[base.id]) {

        // deseleccionamos todo
        if (!e.ctrlKey) {
           for (var id in nvCtrls.items) {
               if (nvCtrls.items[id].type != "canvas") {
                   nvCtrls.items[id].select(false)
                }
           }
        }

        var offset = el.viewportOffset(); 
        var left = e.clientX - offset.left
        var top = e.clientY - offset.top 

        if ($('div_glass_selector')) 
             $('div_glass_selector').remove();

        var strHTML = "<div id='div_glass_selector' style='top:" + top + "px; left:" + left + "px; position: absolute; width: 0.1px; height: 0px; border: 1px dotted black; z-index: 100000' onmouseup='return tnvControls_mouseup(event)' />"
        el.insert({ top: strHTML })
        $('div_glass_selector').setOpacity(0.4)

        nvCtrls._select_x = left
        nvCtrls._select_y = top

        //console.log(nvCtrls._select_x + "," + nvCtrls._select_y )
        //var strHTML = "<div id='div_glass_selector1' style='top:" + nvCtrls._select_y + "px; left:" + nvCtrls._select_x + "px; position: absolute; width: 0.1px; height: 0px; border: 1px solid black; z-index: 100000' onmouseup='return tnvControls_mouseup(event)' />"
        //el.insert({ top: strHTML })

     }

}

var nvCtrls = new tnvControls()

function tnvControls_dispose(id)
{
    if (typeof(id) == 'object')
        id = id.id

    try
    {
        this.items[id].dispose()
    }
    catch (e) {
        console.log(e)
    }

    var items2 = {}
    for (var id2 in this.items)
        if (id2 != id)
            items2[id2] = this.items[id2]

    this.items = items2
}
function tnvControls_getRectById(id)
{
    return this.items[id] == undefined ? null : this.items[id]
}

function tnvControls_getRectByElement(el)
{
    var rec = this.getRectById(el.id)
    if (rec == null && el.up('DIV') != null)
        rec = this.getRectByElement(el.up('DIV'))

    return rec
}

function tnvControls_generateID()
{
    var id
    do
    {
        id = 'ID_'
        for (var i = 0; i < 10; i++)
            id += Math.floor(Math.random() * 10)
    }
    while (this.getRectById(id) != null)

    return id
}

function tnvRect(options)
{
    if (!options) {
        options = {}
    }
    this.id = nvCtrls.generateID() //Asigna un nuevo ID
    this.isNew = !options.isNew ? false : true
    this.type = !options.type ? 'rectangle' : options.type;
    this.subtype = ''
    this.className = 'divRect' //Clase CSS base
    this.style = !options.style ? '' : options.style
    this.div = null
    this.width = !options.width ? undefined : options.width
    this.height = !options.height ? undefined : options.height
    this.top = !options.top ? undefined : options.top
    this.left = !options.left ? undefined : options.left
    this.container = !options.container ? undefined : $(options.container)
    this.items = {} //Coleccion de items hijos
    this.parent = !options.parent ? null : options.parent //Objeto padre
    this.minWidth = !options.minWidth ? 110 : options.minWidth;
    this.minHeight = !options.minHeight ? 25 : options.minHeight;
//    this.selectorWrapperClass = 'selectedWrapper selected_item' + (!options.selectorWrapperClass ? '' : ' ' + options.selectorWrapperClass);
    this.selectorWrapperClass = 'selectedWrapper selected_item' + (!options.selectorWrapperClass ? (!options.bpmClass ? '' : ' ' + options.bpmClass) : ' ' + options.selectorWrapperClass);

    if (this.parent != null)
    {
        this.container = this.parent.div
        this.parent.items[this.id] = this
    }

    //Propiedades de seleccion
    this.multiSelect = !options.multiSelect ? 'all' : options.multiSelect //'parent' - 'none' - 'all'
    this.allowSelect = options.allowSelect == undefined ? true : options.allowSelect //Permite seleccion
    this.className_select = !options.className_select ? 'divRect_select' : options.className_select
    this.selected = false
    this.zIndex = options.zIndex === undefined ? zIndexes.activity : options.zIndex;

    //Propiedades de movimiento
    this.draggable = options.draggable === undefined ? true : options.draggable
    this.dad_opacity = 1 //Opacidad del elemento arrastrado
    this.dad_drop_eval = "false" //Evaluacion para soltar el rect

    //Propiedades de tama�o
    this.sizable = options.sizable === undefined ? true : options.sizable
    this._sz_divSE = null

    //opciones
    this.eliminar = options.eliminar === undefined ? true : options.eliminar
    this._eliminar_divNE = null

    this.clonar = options.clonar === undefined ? true : options.clonar
    this._clonar_divNE = null

    //Propiedades de flechas
    this.allowBeginArrows = options.allowBeginArrows == undefined ? true : options.allowBeginArrows

    //Metodos
    this.dispose = tnvRect_dispose;
    this.draw = tnvRect_draw;
    this.select = tnvRect_select;
    this.move = tnvRect_move;
    this.resize = tnvRect_resize;
    this.getPosMiddle = tnvRect_getPosMiddle;
    this.relations_draw = tnvRect_relations_draw;
    this.relation_add = tnvRect_relation_add;
    this.checkPointIn = tnvRect_checkPointIn;
    this.checkRectIn = tnvRect_checkRectIn;
    this.setWrapper = tnvRect_setWrapper;
    this.removeWrapper = tnvRect_removeWrapper;
    this.extend = tnvRect_extend;
    this.fixTitleWidth = tnvRect_fixTitleWidth;

    this.getTop = tnvRect_getTop;
    this.getLeft = tnvRect_getLeft;
    this.getHeight = tnvRect_getHeight;
    this.getWidth = tnvRect_getWidth;
    this.getInnerHeight = tnvRect_getInnerHeight;
    this.getInnerWidth = tnvRect_getInnerWidth;

    this.fitToChildren = function() {
    };
    this.afterArrowAdd = function(arrow) {
    };

    //Metodos internos
    this._mousedown = tnvRect_mousedown;
    this._sz_init = tnvRect_sz_init;
    this._eliminar_init = tnvRect_eliminar_init
    this._clonar_init = tnvRect_clonar_init
    //this._scut_key = tnvRect_scut_key;
    this._click = tnvRect_click;

    //Flechas
    this._arrow_init = tnvRect_arrow_init;
    this._arrow_points_hide = tnvRect_arrow_points_hide;
    this._arrow_begin = tnvRect_arrow_begin;

    //Relaciones con tRect
    this.relations = new Array()

    //Eventos
    this.onclick = null
    this.ondblclick = null
    this.onmove = options.onmove == undefined ? null : options.onmove;
    this.onrezize = null
    this.onselectchange = null
    this.onarrowclick = null
    this.onarrowdblclick = null

    this.onclonarclick = null
    this.oneliminarclick = null

    this.onDragStart = options.onDragStart == undefined ? function() {
    } : options.onDragStart;
    this.onDragStop = options.onDragStop == undefined ? function() {
    } : options.onDragStop;
    this.onSizeStart = options.onSizeStart == undefined ? function() {
    } : options.onSizeStart;
    this.onSizeStop = options.onSizeStop == undefined ? function() {
    } : options.onSizeStop;
    this.onDispose = options.onDispose == undefined ? function() {
    } : options.onDispose;

    this.onArrowStop = options.onArrowStop == undefined ? function() {
    } : options.onArrowStop;

    return this
}
function tnvRect_extend(newObj)
{
    Object.extend(newObj, this);
    nvCtrls.items[newObj.id] = newObj;
    if (this.parent != null) {
        this.parent.items[newObj.id] = newObj;
    }
    return newObj;
}
function tnvRect_dispose()
{
//    var parent = this.div.up();
//    parent.removeChild(this.div);
    if (this.div) {
        this.div.remove();
    }

    this.removeWrapper();

    for (var i = this.relations.length - 1; i >= 0; i--)
        this.relations[i].dispose()

    this.onDispose()
}
function tnvRect_draw()
{
    //Crear div
    if (this.div == null)
    {
        var strHTML = "<div id='" + this.id + "' class='" + this.className + "' style='width: " + this.width + "px;height:" + this.height + "px;top:" + this.top + "px;left:" + this.left + "px;" + this.style + ";z-index: " + this.zIndex + ";' ></div>"
        this.container.insert({bottom: strHTML})
        this.div = $(this.id)
        this.div.observe('dblclick', function(e)
        {
            var el = Event.element(e)
            var rec = nvCtrls.getRectByElement(el)
            if (rec.ondblclick != null)
            {
                rec.ondblclick(e)
                Event.stop(e)
            }
        })
    }

    if (this.allowSelect) {
        this.div.observe('mousedown', this._mousedown);
        if(!this.isNew)
         this.div.observe('click', this._click);
    }

    //if (Prototype.Browser.IE || Prototype.Browser.WebKit) 
    //  this.div.observe('keydown', this._scut_key);
    //else 
    //  this.div.observe('keypress', this._scut_key);

    this.top = this.div.offsetTop
    this.left = this.div.offsetLeft
    this.width = this.div.getWidth()
    this.height = this.div.getHeight()

    if (this.parent) {
        this.parent.fitToChildren();
    }
}

//function tnvRect_click(e)
//  {
//  if (Event.isLeftClick(e))
//    {
//    var el = Event.element(e)
//    var rec = nvCtrls.getRectByElement(el)
//    console.log("Click en " + rec.id)
//    rec.select(!rec.selected, e)
//    }
//    Event.stop(e)
//  }

function tnvRect_mousedown(e)
{
    if (Event.isLeftClick(e))
    {
        var el = Event.element(e)
        var rec = nvCtrls.getRectByElement(el)
        //var sel = e.ctrlKey ? undefined : true
        //if (rec.allowSelect)
        //  {
        //  rec.select(sel, e)
        //  }
        //rec.select(sel, e)
        if (rec.draggable)
          nvCtrls._dad_begin(e)
    }
    Event.stop(e)
}
function tnvRect_setWrapper() {
    if (!this.wrapper) {
        this.pad = 20;
        this.wrapper = new Element('div').addClassName(this.selectorWrapperClass);
        this.wrapper.setStyle({padding: this.pad + 'px', 'zIndex': zIndexes.selector});
        this.wrapper.setOpacity(0.2);
        
        this.parent.div.insert({top: this.wrapper});
    }

    var ie_fix = -1;
   /* if (Prototype.Browser.IE) {
        ie_fix = -2;
    }*/
    this.wrapper.clonePosition(this.div, {offsetTop: -1 * this.pad + ie_fix, offsetLeft: -1 * this.pad + ie_fix});
}
function tnvRect_removeWrapper() {
    if (this.wrapper) {
        this.wrapper.remove();
        this.wrapper = null;
    }
}

function tnvRect_click(e)
    {
   // debugger
    var el = Event.element(e)
    var rec = nvCtrls.getRectByElement(el)
    var actual_sel = rec.selected
    var sel = !actual_sel
    if (rec.allowSelect)
      {
      //Si no viene el parametro intercambiar entre selecionado y no seleccionado
      //if (sel === undefined)
      //    sel = !this.selected
       //Si va a seleccionar, analizar la multiseleccion

      //var cantidad_sel = 0
      //for (var id in nvCtrls.items)
      //  if (nvCtrls.items[id].selected)
      //       cantidad_sel++

      //var multiple_seleccion = false
      //if (cantidad_sel > 1)
      //    multiple_seleccion = true

      //console.log("sa " + rec.selected, "sm " + multiple_seleccion)

      if (nvCtrls._drag_multi_sel === true)
            return

      var parent = !rec.parent ? nvCtrls : rec.parent      
      if (parent.multiSelect == 'parent' & !e.ctrlKey)
          for (var id in parent.items)
              if (parent.items[id] != rec)
                   parent.items[id].select(false)

       if (parent.multiSelect == 'all' & !e.ctrlKey)
          for (var id in nvCtrls.items)
              if (nvCtrls.items[id] != rec) 
                  nvCtrls.items[id].select(false)
       
       rec.select(!rec.selected)
      

       }
    if (e != undefined)
      Event.stop(e)
    //this.div.focus()
   }

function tnvRect_select(sel)
   {
  // console.log("Seleccionar " + !this.selected) 
    var actual_sel = this.selected
    if (this.allowSelect)
    {
        if (sel)
        {
            this.div.addClassName(this.className_select)
            this.div.setStyle({'zIndex': zIndexes.selected});

            this.setWrapper();
             
            //Activar desplazamiento
            if (this.draggable)
                this.div.observe('mousedown', nvCtrls._dad_begin)

           if (this.eliminar)
             this._eliminar_init()
 
           if (this.clonar)          
             this._clonar_init()

            //Activar resize
            if (this.sizable)
                this._sz_init()

            //Activar flechas
            if (this.allowBeginArrows)
                this._arrow_init()

            //Activar presion de teclas
            //if (Prototype.Browser.IE || Prototype.Browser.WebKit) 
            //    Event.observe($(document), 'keydown', this._scut_key)
            //else 
            //    Event.observe($(document), 'keypress', this._scut_key)
            
        }
        else
        {
            this.div.removeClassName(this.className_select)
            this.div.setStyle({'zIndex': this.zIndex});

            this.removeWrapper();
            //Desactivar desplazamiento
            if (this.draggable)
                this.div.stopObserving('mousedown', nvCtrls._dad_begin)
         
            //Desactivar clonar
            if (this._clonar_divNE != null)
                this._clonar_divNE.hide()
            
            //Desactivar eliminar
            if (this._eliminar_divNE != null)
                this._eliminar_divNE.hide()

            //Desactivar redimencionar
            if (this.sizable && this._sz_divSE != null)
                this._sz_divSE.hide()

            //Desactivar flechas
            if (this.allowBeginArrows)
                this._arrow_points_hide()

            //desctivar presion de teclas
            //if (Prototype.Browser.IE || Prototype.Browser.WebKit) 
            //    Event.observe($(document), 'keydown', this._scut_key)
            //else 
            //    Event.observe($(document), 'keypress', this._scut_key)
            
            
        }
        this.selected = sel
    }

    if (this.onselectchange != null && actual_sel != this.selected)
        this.onselectchange(this)

    //this.div.focus();
}

function tnvRect_scut_key(e)
{
//    try
//    {
       // console.warn("tnvRect_scut_key")
        var undorequiere = false
        var key = !e.which ? e.keyCode : e.which
        if (key == Event.KEY_DELETE && !e.ctrlKey && !e.shiftKey)
          {
          for (var id in nvCtrls.items)
              if (nvCtrls.items[id].selected)
                  {

                  if (nvCtrls.items[id].oneliminarclick) {
                      nvCtrls.items[id].oneliminarclick() //ver
                      nvCtrls.items[id].select(false, e); //ver
                  }

                   nvCtrls.dispose(id)
                   undorequiere = true 
                  }
          }
        
        var options = {}         
        var d = e.ctrlKey ? 1 : 5
        
        if (!e.shiftKey)
          {
          //MOVER
          var arrowkey = true
          options.offsetLeft = 0;
          options.offsetTop = 0;
           
          switch (key)
              {
              case Event.KEY_DOWN:
                  options.offsetTop = d
                  break;
              case Event.KEY_LEFT:
                  options.offsetLeft = -d
                  break;
              case Event.KEY_RIGHT:
                  options.offsetLeft = d
                  break;
              case Event.KEY_UP:
                  options.offsetTop = -d
                  break;
              default:
                   arrowkey = false
              }  
          if (arrowkey)
            {
            for (var id in nvCtrls.items) 
                {
                if (nvCtrls.items[id].selected && nvCtrls.items[id].draggable) 
                   {
                   nvCtrls.items[id].move(options);
                   undorequiere = true
                   } 
                }
            }
          }
        else
          {
            //Tama�o
            options.incHeight = 0;
            options.incWidth = 0;
            var arrowkey = true
            switch (key)
            {
                case Event.KEY_DOWN:
                    options.incHeight = d
                    break;
                case Event.KEY_LEFT:
                    options.incWidth = -d
                    break;
                case Event.KEY_RIGHT:
                    options.incWidth = d
                    break;
                case Event.KEY_UP:
                    options.incHeight = -d
                    break;
                default:
                     arrowkey = false
            }
          if (arrowkey)
              {
              for (var id in nvCtrls.items) {
                if (nvCtrls.items[id].selected && nvCtrls.items[id].sizable) 
                   {
                   nvCtrls.items[id].resize(options);
                   nvCtrls.items[id].onSizeStop();
                   undorequiere = true 
                   }
              }
            }
          }
    if (undorequiere) {
        nvCtrls.onDragStop();
    }
}



function tnvRect_clonar_init()
{
    if (this._clonar_divNE == null)
    {
        var strHTML = "<div id='iconclonar_" + this.id + "' style='width: 16px; height: 16px; background: url(\"../image/tnvRect/copiar.png\"); overflow: hidden; border: 0px; position: absolute; z-index: " + this.zindex + "; cursor:hand !Important; cursor:pointer !Important; right: 16px; top: -18px;' class='selected_item'></div>"
        this.div.insert({top: strHTML})
        this._clonar_divNE = $('iconclonar_' + this.id)
        this._clonar_divNE.observe('click',  this.onclonarclick)
    }

    this._clonar_divNE.show()
   
}


function tnvRect_eliminar_init()
{
    if (this._eliminar_divNE == null)
    {
        var strHTML = "<div id='iconeliminar_" + this.id + "' style='width: 16px; height: 16px; background: url(\"../image/tnvRect/delete.png\"); overflow: hidden; border: 0px; position: absolute; z-index: " + this.zindex + "; cursor:hand !Important; cursor:pointer !Important; right: 0px; top: -18px;' class='selected_item'></div>"
        this.div.insert({top: strHTML})
        this._eliminar_divNE = $('iconeliminar_' + this.id)

        this._eliminar_divNE.observe('click', this.oneliminarclick )
    }
    this._eliminar_divNE.show()
  
}

function tnvRect_sz_init()
{
    if (this._sz_divSE == null)
    {
        var strHTML = "<div id='iconsize_" + this.id + "' style='width: 16px; height: 16px; background: url(\"../image/tnvRect/resizer.png\"); overflow: hidden; border: 0px; position: absolute; z-index: " + this.zindex + "; cursor:se-resize !Important; right: -16px; bottom: -16px;' class='selected_item'></div>"
        this.div.insert({top: strHTML})
        this._sz_divSE = $('iconsize_' + this.id)
    }
    this._sz_divSE.show()

    this._sz_divSE.observe('mousedown', nvCtrls._sz_begin)
}

function tnvRect_move(x, y, offsetLeft, offsetTop)
{
var params = {}
if (typeof(x) == 'object') 
  {
  params.x = x.x
  params.y = x.y
  params.offsetLeft = x.offsetLeft
  params.offsetTop = x.offsetTop
  }
else
  {
  params.x = x
  params.y = y
  params.offsetLeft = !offsetLeft ? 0 : offsetLeft
  params.offsetTop = !offsetTop ? 0 : offsetTop
  } 

if (!params.x)
   params.x = this.getLeft()

if (!params.y)
  params.y = this.getTop()

//console.log("Antes (" + this.getLeft() + "," + this.getTop() + ")")

//console.log("(" + params.x + "," + params.y + ")  (" + params.offsetLeft + "," + params.offsetTop + ")  (" + (params.x + params.offsetLeft) + "," + (params.y + params.offsetTop) + ")" )

var position = {}
position.x = params.x + params.offsetLeft
position.y = params.y + params.offsetTop



//console.log("(" + this.getLeft() + "," + this.getTop() + ")")

//if (position.x < 0)
//    position.x = 0
//if (position.y  < 0)
//    position.y  = 0
  
//    if (typeof(x) == 'object') {
//        var options = x
//        x = !options.x ? this.div.offsetLeft : options.x
//        y = !options.y ? this.div.offsetTop : options.y
//        var inc = 0;
////        if (Prototype.Browser.IE) {
////            inc = 0;
////        }
//        x += (!options.offsetX ? 0 : options.offsetX) + inc
//        y += (!options.offsetY ? 0 : options.offsetY) + inc
//    }
//    if (x < 0)
//        x = 0
//    if (y < 0)
//        y = 0

    var parent
    if (this.parent == null)
        parent = $$('BODY')[0]
    else
        parent = this.parent.div
    this.div.clonePosition(parent, {setWidth: false, setHeight: false, offsetLeft: position.x, offsetTop: position.y});
  
    //console.log("Despues (" + this.getLeft() + "," + this.getTop() + ")")
   
    var ie_fix = -1;
    //if (Prototype.Browser.IE) {
    //    ie_fix = -2;
    //}
    if (this.wrapper) {
        this.wrapper.clonePosition(this.div, {'offsetTop': -1 * this.pad + ie_fix, 'offsetLeft': -1 * this.pad + ie_fix});
    }

    this.relations_draw()

    this.parent.fitToChildren();

    //disparar evento onmove
    if (this.onmove != null) {
        this.onmove(position.x, position.y);
    }
}

function tnvRect_relations_draw()
{
    for (var i = 0; i < this.relations.length; i++)
    {
        var arr = this.relations[i]
        var ppos;
        var point;
        if (arr.src == this)
        {
            point = arr.points.first()
            ppos = this.getPosMiddle(arr.direction)
            point.x = ppos.x
            point.y = ppos.y
            arr.draw({src: point})
        }

        if (arr.dest == this)
        {
            point = arr.points.last()
            ppos = this.getPosMiddle(arr.reception)
            point.x = ppos.x
            point.y = ppos.y
            arr.draw({dest: point})
        }
    }
}
function tnvRect_dad_begin(e)
{

    //if (nvCtrls)
    //console.log("tnvRect_dad_begin")
    var el = Event.element(e)
    var rec = nvCtrls.getRectByElement(el)

    if (Event.isLeftClick(e) && rec.draggable && rec.selected) {
        nvCtrls._drag_init_pointer_x = Event.pointerX(e)
        nvCtrls._drag_init_pointer_y = Event.pointerY(e)
        nvCtrls._drag_init_exist_move = false
        nvCtrls._drag_multi_sel = false
        nvCtrls._drag_element = rec
        nvCtrls._drag_element.div.setOpacity(nvCtrls._drag_element.dad_opacity)
        //nvCtrls._glass_visible(true)
        var cumulativeOffset = nvCtrls._drag_element.div.cumulativeOffset()
        nvCtrls._dad_original_x = cumulativeOffset.left
        nvCtrls._dad_original_y = cumulativeOffset.top
        nvCtrls._drag_x = Event.pointerX(e) - cumulativeOffset.left
        nvCtrls._drag_y = Event.pointerY(e) - cumulativeOffset.top


        cumulativeOffset = nvCtrls._drag_element.div.up().cumulativeOffset()
        nvCtrls._drag_parent_x = cumulativeOffset.left
        nvCtrls._drag_parent_y = cumulativeOffset.top

        Event.observe($(document), 'mouseup', nvCtrls._dad_stop)
        Event.observe($(document), 'mousemove', nvCtrls._dad_move)
        //if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
        //    Event.observe($(document), 'keydown', nvCtrls._dad_key)
        //} else {
        //    Event.observe($(document), 'keypress', nvCtrls._dad_key)
        //}
        rec.onDragStart();
    }
    else {
          nvCtrls._drag_multi_sel = false
          nvCtrls._dad_stop
    }

    Event.stop(e)
   
    return

}
function tnvRect_dad_move(e)
{

    if (Event.isLeftClick(e))
    {
        var min_desp_init = 4
        var min_desp = 2

        var x = Event.pointerX(e) - nvCtrls._drag_init_pointer_x
        var y = Event.pointerY(e) - nvCtrls._drag_init_pointer_y
 
        if( Math.abs(x) <= min_desp_init && Math.abs(y) <= min_desp_init && nvCtrls._drag_init_exist_move == false)
           return


        if( Math.abs(x) <= min_desp && Math.abs(y) <= min_desp)
          return

        nvCtrls._drag_init_pointer_x = Event.pointerX(e)
        nvCtrls._drag_init_pointer_y = Event.pointerY(e)

      // console.log("(" + Event.pointerX(e) + ',' + Event.pointerY(e) + ")  (" + nvCtrls._drag_init_pointer_x + ',' + nvCtrls._drag_init_pointer_y + ") (" + x + ',' + y + ')' )

       //x -= nvCtrls._drag_parent_x
       //y -= nvCtrls._drag_parent_y

       // nvCtrls._drag_element.move(x, y)
       var seleccionados = 0 
       for (var id in nvCtrls.items) 
            {           
              if (nvCtrls.items[id].selected && nvCtrls.items[id].draggable)
                { 
                nvCtrls.items[id].move({offsetLeft: x, offsetTop: y});
                nvCtrls._drag_init_exist_move = true
                seleccionados++
                if (seleccionados >= 1)
                   nvCtrls._drag_multi_sel = true
                }
       }
    }
    else
        nvCtrls._dad_stop()
}

function tnvRect_resize(w, h)
{
    if (typeof(w) == 'object')
    {
        var options = w
        w = !options.w ? this.getInnerWidth() : options.w
        h = !options.h ? this.getInnerHeight() : options.h
        w += !options.incWidth ? 0 : options.incWidth
        h += !options.incHeight ? 0 : options.incHeight
    }

    w = w < this.minWidth ? this.minWidth : w;
    h = h < this.minHeight ? this.minHeight : h;

    this.div.setStyle({'width': w + 'px', 'height': h + 'px'});

    var ie_fix = -1;
    //if (Prototype.Browser.IE) {
    //    ie_fix = -2;
    //}
    this.wrapper.clonePosition(this.div, {'offsetTop': -1 * this.pad + ie_fix, 'offsetLeft': -1 * this.pad + ie_fix});

    this._arrow_init()
    this.parent.fitToChildren();

    //acomodo el title para ie
    this.fixTitleWidth(w);
    this.relations_draw()
    //disparar evento onresize
    if (this.onresize != null)
        this.onresize(w, h)
}
function tnvRect_fixTitleWidth(w) {
    if(w == undefined && this.div.style != undefined) {
        w = this.div.getWidth() - 10;
    }
    var title = this.div.select('.title p');
    if(title.length > 0) {
        title = title[0];
        title.setStyle({'width': (w - 4) + 'px'});
    }
}

function tnvRect_dad_stop()
{   
    var rec = nvCtrls._drag_element;
    try { nvCtrls._drag_element.div.setOpacity(1) } catch (e) { console.error(e.message)}
    nvCtrls._drag_element = null
    nvCtrls._drag_x = null
    nvCtrls._drag_y = null
    nvCtrls._dad_original_x = null
    nvCtrls._dad_original_y = null

    try
    {
        Event.stopObserving($(document), 'mouseup', nvCtrls._dad_stop)
        Event.stopObserving($(document), 'mousemove', nvCtrls._dad_move)
        
        //if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
        //    Event.stopObserving($(document), 'keydown', nvCtrls._dad_key)
        //} else {
        //    Event.stopObserving($(document), 'keypress', nvCtrls._dad_key)
        //}
         


        //Event.stopObserving(nvCtrls._div_glass, 'mousemove')
        //nvCtrls._glass_visible(false)
    }
    catch (e) {
        console.log(e)
    }
    //console.log("tnvRect_dad_stop")
    if (nvCtrls._drag_init_exist_move)   
        rec.onDragStop();

    //nvCtrls._drag_init_exist_move = false
}

function tnvRect_dad_key(e)
{
    var key = !e.which ? e.keyCode : e.which
    if (Event.KEY_ESC == key)
    {
        var x = nvCtrls._dad_original_x
        var y = nvCtrls._dad_original_y
        x -= nvCtrls._drag_parent_x
        y -= nvCtrls._drag_parent_y
        nvCtrls._drag_element.move(x, y)
        nvCtrls._dad_stop()
    }

}

function tnvRect_sz_begin(e)
{
    if (Event.isLeftClick(e))
    {
        var el = Event.element(e)
        nvCtrls._sz_element = nvCtrls.getRectByElement(el)
        var rec = nvCtrls._sz_element;
        //var id = el.id.substr(9)
        //nvCtrls._sz_element = nvCtrls.getRectById(id)
        //nvCtrls._drag_element.div.setOpacity(nvCtrls._drag_element.dad_opacity)
        //nvCtrls._glass_visible(true)
        //var cumulativeOffset = nvCtrls._sz_element.div.cumulativeOffset()
        var cumulativeOffset = nvCtrls._sz_element.div.viewportOffset()
        nvCtrls._sz_x = cumulativeOffset.left
        nvCtrls._sz_y = cumulativeOffset.top
        nvCtrls._sz_original_w = nvCtrls._sz_element.div.getWidth()

        nvCtrls._sz_original_cursor = nvCtrls._sz_element.div.style.cursor
        nvCtrls._sz_element.div.setStyle({cursor: 'se-resize !Important'})
        $(document.body).setStyle({cursor: 'se-resize !Important'})
        Event.observe($(document), 'mouseup', nvCtrls._sz_stop)
        Event.observe($(document), 'mousemove', nvCtrls._sz_move)
        if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
            Event.observe($(document), 'keydown', nvCtrls._sz_key)
        } else {
            Event.observe($(document), 'keypress', nvCtrls._sz_key)
        }
        rec.onSizeStart();
    }
    else
        nvCtrls._sz_stop

    Event.stop(e)
    return
}

function tnvRect_sz_stop()
{
    var rec = nvCtrls._sz_element;
    nvCtrls._sz_element.div.setStyle({cursor: nvCtrls._sz_original_cursor})
    nvCtrls._sz_element = null
    nvCtrls._sz_original_w = null
    nvCtrls._sz_original_h = null
    nvCtrls._sz_x = null
    nvCtrls._sz_y = null

    document.body.setStyle({cursor: ''})
    try
    {
        Event.stopObserving($(document), 'mouseup', nvCtrls._sz_stop)
        Event.stopObserving($(document), 'mousemove', nvCtrls._sz_move)
        if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
            Event.stopObserving($(document), 'keydown', nvCtrls._sz_key)
        } else {
            Event.stopObserving($(document), 'keypress', nvCtrls._sz_key)
        }
        //Event.stopObserving(nvCtrls._div_glass, 'mousemove')
        //nvCtrls._glass_visible(false)
        rec.onSizeStop();
    }
    catch (e) {
        console.log(e)
    }
}

function tnvRect_sz_move(e)
{
    if (Event.isLeftClick(e))
    {
        var w = Event.pointerX(e) - nvCtrls._sz_x //+ 3
        var h = Event.pointerY(e) - nvCtrls._sz_y //+ 3
        nvCtrls._sz_element.resize(w, h);
    }
    else
        nvCtrls._sz_stop()
}

function tnvRect_sz_key(e)
{
    var key = !e.which ? e.keyCode : e.which
    if (Event.KEY_ESC == key)
    {
        var w = nvCtrls._sz_original_w
        var h = nvCtrls._sz_original_w
        nvCtrls._sz_element.resize(w, h)
        nvCtrls._sz_stop()
    }
}

function tnvCanvas(options)
{
    if (!options)
        options = {}
    //Heredar de tnvRect
    options.zIndex = zIndexes.canvas;
    new tnvRect(options).extend(this)

    this.type = 'canvas'
    this.className = 'divCanvas'
    if (this.parent != null)
        this.parent.items[this.id] = this
    //nvCtrls.canvas[this.id] = this
    //Metodos
    this.fitToChildren = tnvCanvas_fitToChildren;

    this.tDraw = this.draw;
    this.draw = function() {
        this.tDraw();
        //Anular seleccion de texto
        this.div.onselectstart = function() {
            return false;
        }
        // ie
        this.div.onmousedown = function() {
            return false;
        }

         //Mozilla
        //Event.observe(document, 'selectstart', function() {oCB2.innerHTML += 'ose '; return false;}) // ie
        //Event.observe(document, 'mousedown', function() {oCB2.innerHTML += 'omd '; return false;}) //Mozilla
    }
   
  
    this.draw();
    return this;
}
function tnvCanvas_fitToChildren() {
    var max_width = 0;
    var max_height = 0;
    var curr_width = 0;
    var curr_height = 0;
    for (var item in this.items) {
        item = this.items[item];
        try {
            curr_width = item.div.viewportOffset().left;
            curr_width -= this.div.viewportOffset().left;
            curr_width += item.div.getWidth();
        } catch(e) {
            //explorer da un error aca en algunos casos, no se porque. Por eso el try
//            debugger
        }
        if (max_width < curr_width) {
            max_width = curr_width;
        }
        if (item.transf_tipo != undefined && ['pool', 'lane'].indexOf(item.transf_tipo) == -1) {
            curr_height = item.div.viewportOffset().top - this.div.viewportOffset().top + item.div.getHeight();
            if (max_height < curr_height) {
                max_height = curr_height;
            }
        }
    }
    this.div.setStyle({
        width: max_width + 'px',
        height: max_height + 100 + 'px'
    });
}
function tnvCtrl(options) {
    if (!options)
        options = {}
    //Heredar de tnvRect
    this.inherit = new tnvRect(options)
    Object.extend(this, this.inherit)
    this.inherit.id = ''
    //Asignar valores a las propiedades heredadas
    this.type = 'control'
    this.className = !options.className ? 'divCtrl' : options.className
    this.param = !options.param ? null : options.param
    this.ondblclick = !options.ondblclick ? null : options.ondblclick

    if (this.parent != null)
        this.parent.items[this.id] = this
    nvCtrls.items[this.id] = this

    //Propiedades

    this.title = !options.title ? '' : options.title
    this.HTMLcontent = !options.HTMLcontent ? '' : options.HTMLcontent

    //Metodos
    this.hDraw = this.draw
    this.draw = function tnvCtrl_draw()
    {
        this.hDraw()
        this.div.innerHTML = ''
        this.div.insert({top: this.HTMLcontent})
    }

    //Crear div
    //var strStyle = '' //"top: " + this.top + "px; left: " + this.left + "px; width: " + this.width + "px; height: " + this.height + "px;"
    //<div id='divTit_" + this.divID + "' class='divCtrl_title'>" + this.title + "</div>" + this.comment + "
    //var strHTML = "<div id='" + this.divID + "' class='divCtrl' style='" + this.style + strStyle + "'></div>"

    this.draw()
    return this
}

function tnvRect_arrow_init()
{
    if (this.allowBeginArrows) {
        var l = 15;
        if (this._arrow_points == null)
        {
            this._arrow_points = {}
            this._arrow_points["top"] = null
            this._arrow_points["left"] = null
            this._arrow_points["bottom"] = null
            this._arrow_points["right"] = null
            var id
            for (var name in this._arrow_points)
            {
                id = 'apoint_' + name + "_" + this.id
                var strHTML = "<div id='" + id + "' style='border-radius: 8px;border: 1px solid #444444;width: " + (l - 2) + "px; height: " + (l - 2) + "px; background: rgb(100, 100, 100); overflow: hidden; position: absolute; cursor:pointer !Important; cursor: hand !Important' class='selected_item'></div>"
                this.div.insert({top: strHTML})
                $(id).setOpacity(0.66);
                this._arrow_points[name] = $(id)
                this._arrow_points[name].position = name
                this._arrow_points[name].observe('mousedown', tnvRect_arrow_begin)
            }
        }
        for (var name in this._arrow_points)
            this._arrow_points[name].show()

        var ie_fix = 0;
//    if (Prototype.Browser.Gecko) {
        //if (Prototype.Browser.IE) {
        //    ie_fix = 1;
        //}
        this._arrow_points["top"].setStyle({
            'top': '-' + (l + 4) + 'px',
            'left': '50%',
            'marginLeft': ((l + ie_fix) / -2) + 'px'
        });
        this._arrow_points["bottom"].setStyle({
            'bottom': '-' + (l + 4) + 'px',
            'left': '50%',
            'marginLeft': ((l + ie_fix) / -2) + 'px'
        });
        this._arrow_points["left"].setStyle({
            'left': '-' + (l + 4) + 'px',
            'top': '50%',
            'marginTop': ((l + ie_fix) / -2) + 'px'
        });
        this._arrow_points["right"].setStyle({
            'right': '-' + (l + 4) + 'px',
            'top': '50%',
            'marginTop': ((l + ie_fix) / -2) + 'px'
        });
    }
}

function tnvRect_arrow_points_hide()
{
  
  for (var name in this._arrow_points)
        this._arrow_points[name].hide()

}

function tnvRect_arrow_begin(e)
{
  
  var el = Event.element(e)
    var src = nvCtrls.getRectByElement(el)

    var direction
    switch (el.position)
    {
        case 'top':
            direction = 'up'
            break;
        case 'bottom':
            direction = 'down'
            break;
        default:
            direction = el.position
            break;
    }

    nvCtrls._arrow_element = new tnvArrow({src: src, parent: src.parent, direction: direction, points_draw: false});
    /*
     var pos = rec.getPosMiddle(el.position)
     nvCtrls._arrow_element = new tnvArrow({src: rec, parent: rec.parent, direction: direction, points_draw: false})
     */
    //Definir evaluaci�n de destino
    nvCtrls._arrow_element.dest_eval = 'nvCtrls.getRectByElement(element) != null && nvCtrls.getRectByElement(element).div.up() == nvCtrls._arrow_element.parent.div'
    //Definir acciones de destino
    nvCtrls._arrow_element.dest_over = tnvRect_arrow_dest_over
    nvCtrls._arrow_element.dest_over_out = tnvRect_arrow_dest_over_out
    //Agregar punto de inicio

    //nvCtrls._arrow_element.points.push(new tnvPoint({x: pos.x, y: pos.y, position: position, parent: rec.parent, direction: direction, className: this.className, parentArrow: this}))

    Event.observe($(document), 'mouseup', tnvRect_arrow_end)
    Event.observe($(document), 'mousemove', tnvRect_arrow_move)
    if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
        Event.observe($(document), 'keydown', tnvRect_arrow_key)
    } else {
        Event.observe($(document), 'keypress', tnvRect_arrow_key)
    }

    Event.stop(e)
}

function tnvRect_relation_add(options)
{   
    options.src = this;
    options.parent = this.parent;
    var arr = new tnvArrow(options);
    this.relations.push(arr);
    options.dest.relations.push(arr);
    arr.draw();
    this.afterArrowAdd(arr);
    return arr;
}
/**
 * checkea si un punto pertenece al tnvRect y devuelve las distancias n,s,e y o {x,y}
 * @param {type} point
 * @returns {tnvRect_checkPointIn.distances}
 */
function tnvRect_checkPointIn(point) {
    var offset = this.div.viewportOffset();
    var rect_lmts = {
        n: offset.top,
        s: offset.top + this.div.getHeight(),
        e: offset.left,
        o: offset.left + this.div.getWidth()
    };
    var distances = {
        n: rect_lmts.n - point.y,
        s: point.y - rect_lmts.s,
        e: rect_lmts.e - point.x,
        o: point.x - rect_lmts.o
    };
    distances.xIn = distances.e <= 0 && distances.o <= 0;
    distances.yIn = distances.n <= 0 && distances.s <= 0;
    distances.isIn = distances.xIn && distances.yIn;
    return distances;
}
/**
 * checkea si un tnvRect pertenece al tnvRect y devuelve las distancias n,s,e y o
 * @param {type} tRect
 * @returns {tnvRect_checkRectIn.distances}
 */
function tnvRect_checkRectIn(tRect) {
    var offset = tRect.div.viewportOffset();
    var rect_lmts = {
        n: offset.top,
        s: offset.top + tRect.div.getHeight(),
        e: offset.left,
        o: offset.left + tRect.div.getWidth()
    };
    var ne = this.checkPointIn({x: rect_lmts.e, y: rect_lmts.n});
    var so = this.checkPointIn({x: rect_lmts.o, y: rect_lmts.s});
    var distances = {
        n: ne.n,
        s: so.s,
        e: ne.e,
        o: so.o
    };
    distances.fullYIn = ne.yIn && so.yIn;
    distances.fullXIn = ne.xIn && so.xIn;
    distances.fullIn = distances.fullXIn && distances.fullYIn;
    distances.partialXIn = !distances.fullXIn && (ne.xIn || so.xIn);
    distances.partialYIn = !distances.fullYIn && (ne.yIn || so.yIn);
    distances.partialIn = !distances.fullIn && (ne.isIn || so.isIn);
    return distances;
}
function tnvRect_arrow_end(e)
{

 if (nvCtrls._arrow_element != null)
        if (nvCtrls._arrow_element._arrow_dest != null)
        {
            var dest = nvCtrls._arrow_element._arrow_dest
            
            //Menor distancia al puntero del mouse
//            var cumOffset = dest.div.up().cumulativeOffset()
            var cumOffset = dest.div.up().viewportOffset()
            var x = Event.pointerX(e) - cumOffset.left
            var y = Event.pointerY(e) - cumOffset.top

            //Menor distancia al inicio de la flecha
            //var x = nvCtrls._arrow_element.points[0].x // Event.pointerX(e) // - cumOffset.left
            //var y = nvCtrls._arrow_element.points[0].y //Event.pointerY(e) //- cumOffset.top

            var middles = {}
            middles['top'] = dest.getPosMiddle('top')
            middles['bottom'] = dest.getPosMiddle('bottom')
            middles['left'] = dest.getPosMiddle('left')
            middles['right'] = dest.getPosMiddle('right')

            var a
            var b
            var c
            var min = 100000
            var index
            for (var i in middles)
            {
                //strHTML = "<div style='left:" + middles[i].x + "px; top:" + middles[i].y + "px; width: 5px; height: 5px; background-color: green; overflow: hidden; border: 0px; position: absolute; float: left; z-index: 1000'/>"
                //arr.parent.div.insert({top:strHTML})
                a = y - middles[i].y
                b = x - middles[i].x
                middles[i]['dist'] = Math.sqrt((a * a) + (b * b))

                //oCB2.div.innerHTML += i + ':' + middles[i]['dist'].toFixed(2) + '<br/>'
                if (middles[i]['dist'] < min)
                {
                    min = middles[i]['dist']
                    index = i
                }
            }

            var reception
            switch (index)
            {
                case 'top':
                    reception = 'up'
                    break;

                case 'bottom':
                    reception = 'down'
                    break;
                default:
                    reception = index
            }
            var src = nvCtrls._arrow_element.src;
            var options = {};
            options.dest = dest;
            options.direction = nvCtrls._arrow_element.direction;
            options.reception = reception;
            var arr = src.relation_add(options)
//            nvCtrls._arrow_element.src.onArrowStop(arr);

//            nvCtrls._arrow_element.dispose();

            tnvRect_arrow_stop();
            src.onArrowStop(arr,e);
        }
}

function tnvRect_arrow_stop()
{
    try
    {
        nvCtrls._arrow_element.dest_over_out()
        nvCtrls._arrow_element.dispose()
        nvCtrls._arrow_element = null
    }
    catch (e) {
        console.log(e)
    }

    try
    {
        Event.stopObserving($(document), 'mouseup', tnvRect_arrow_end)
        Event.stopObserving($(document), 'mousemove', tnvRect_arrow_move)
        if (Prototype.Browser.IE || Prototype.Browser.WebKit) {
            Event.stopObserving($(document), 'keydown', tnvRect_arrow_key)
        } else {
            Event.stopObserving($(document), 'keypress', tnvRect_arrow_key)
        }
    }
    catch (e) {
        console.log(e)
    }
}

function tnvRect_arrow_key(e)
{
    var key = !e.which ? e.keyCode : e.which
    if (Event.KEY_ESC == key)
        tnvRect_arrow_stop()

}

function tnvRect_arrow_move(e)
{
  //  Event.stop(e)  
    if (Event.isLeftClick(e))
    {
        
var cumOffset = nvCtrls._arrow_element.parent.div.viewportOffset()
        var x = Event.pointerX(e) - cumOffset.left
        var y = Event.pointerY(e) - cumOffset.top
        if (x < 0)
            x = 0
        if (y < 0)
            y = 0
        nvCtrls._arrow_element.draw({dest_point: {x: x, y: y}})
        var element = Event.element(e)

   if (nvCtrls._arrow_element.dest_over != null && eval(nvCtrls._arrow_element.dest_eval))
            nvCtrls._arrow_element.dest_over(e, element)
        else
            nvCtrls._arrow_element.dest_over_out(e, element)

    }
    else
        tnvRect_arrow_stop()

    //debugger
    //Event.stop(e)
}

function tnvPoint(options)
{

    if (options == undefined)
        options = {}
    this.id = !options.id ? '' : options.id
    if (this.id == '')
    {
        this.id = 'POINT_'
        for (var i = 0; i < 10; i++)
            this.id += Math.floor(Math.random() * 10)
    }

    this.parent = options.parent
    //this.rect = !options.rect ? null : options.rect
    //this.position = !options.position ? null : options.position
    this.direction = !options.direction ? null : options.direction
    this.reception = !options.reception ? null : options.reception
    this.parentArrow = !options.parentArrow ? null : options.parentArrow
    if (this.direction == null)
        switch (this.reception)
        {
            case 'up':
                this.direction = 'down'
                break
            case 'down':
                this.direction = 'up'
                break
            case 'left':
                this.direction = 'right'
                break
            case 'right':
                this.direction = 'left'
                break
        }

    this.zIndex = zIndexes.arrow_symbol;
    this.icon = options.icon == undefined ? Icons['no_condition'] : options.icon
    this.type = options.type == undefined ? 'none' : options.type
    this.size = options.size == undefined ? 9 : options.size
    this.className = options.className == undefined ? 'point' : 'point ' + options.className

    this.className += this.direction == null ? '' : ' ' + this.direction;
    this.className += this.reception == null ? '' : ' ' + this.reception;
//    this.className += this.icon == null ? '' : ' ' + this.icon;
    this.className += this.type == null ? '' : ' ' + this.type;

    this.x = options.x == undefined ? null : options.x
    this.y = options.y == undefined ? null : options.y
    this.div = null
    this.draw = tnvPoint_draw;
    this.quadrant = tnvPoint_quadrant;
    this.dispose = tnvPoint_dispose;

    if (this.parent.points_draw) {
        this.draw();
    }
}
function tnvPoint_draw(redraw)
{
    if (redraw) {
        this.dispose();
    }
    if (this.icon == 'none')
        return

    var strHTML
    var left
    var top
    var src_icon

    if (!this.div) {
        var amount = 7;
        this.correction_x = -4;
        this.correction_y = -4;
        this.background = "url('/FW/image/transferencia/";
        /*Si es de inicio medio o final*/
        switch (this.type) {
            case 'ini':
                amount = this.parentArrow.distance - 10;
                this.background += this.icon;
                switch (this.parentArrow.direction) {
                    case 'up':
                        this.correction_y -= amount;
                        break;
                    case 'down':
                        this.correction_y += amount;
                        break;
                    case 'left':
                        this.correction_x -= amount;
                        break;
                    case 'right':
                        this.correction_x += amount;
                        break;
                }
                break;
            case 'end':
                amount = 4;
                this.background += Icons['arrow_' + this.parentArrow.reception];
                switch (this.parentArrow.reception) {
                    case 'up':
                        this.correction_y -= (amount + 1);
                        break;
                    case 'down':
                        this.correction_y += amount;
                        break;
                    case 'left':
                        this.correction_x -= (amount + 1);
                        break;
                    case 'right':
                        this.correction_x += amount;
                        break;
                }
                break;
            default:
                this.background += this.icon;
                break;
        }
        this.background += "')";
        this.div = $(document.createElement('div')).setStyle({
            background: this.background,
            position: 'absolute',
            width: this.size + 'px',
            height: this.size + 'px',
            cursor: 'pointer',
            zIndex: this.zIndex
        });
        var parentArrow = this.parentArrow;
//        this.points[index].div.stopObserving('click')
        if (parentArrow.onclick) {
            this.div.observe('click', function(e) {
                parentArrow.onclick(parentArrow, e);
            });
        }
//        this.points[index].div.stopObserving('dblclick')
        if (parentArrow.ondblclick) {
            this.div.observe('dblclick', function(e) {
                parentArrow.ondblclick(parentArrow, e);
            });
        }
        this.parent.div.insert({top: this.div});
    }
    this.div.setStyle({
        top: this.y + this.correction_y + 'px',
        left: this.x + this.correction_x + 'px'
    });
}
function tnvPoint_dispose()
{
    if (this.div != null) {
        this.div.remove();
        this.div = null;
    }

}
function tnvPoint_quadrant(point)
{
    if (this.x > point.x && this.y > point.y)
        return 'NO'

    if (this.x <= point.x && this.y > point.y)
        return 'NE'

    if (this.x > point.x && this.y <= point.y)
        return 'SO'

    if (this.x <= point.x && this.y <= point.y)
        return 'SE'

}
function tnvArrow(options)
{
    this.src = !options.src ? null : options.src
//    if (typeof(this.src) == 'object' && this.src != null)
//        this.src.relations.push(this)
//
    this.dest = !options.dest ? null : options.dest
//    if (typeof(this.dest) == 'object' && this.dest != null)
//        this.dest.relations.push(this)

    this.direction = !options.direction ? 'down' : options.direction // Indica como debe arrancar la flecha
    this.reception = !options.reception ? 'down' : options.reception // Indica como debe terminar la flecha
    this.parent = options.parent //Elemento que la contiene

    this.lineStyle = options.lineStyle == undefined ? 'dashed' : options.lineStyle
    this.lineColor = options.lineColor == undefined ? '#000' : options.lineColor
    this.lineWidth = options.lineWidth == undefined ? 1 : options.lineWidth
    this.title = options.title ? options.title : '';
    this.title_position = options.title_position ? options.title_position : 'middle';
    this.distance = 20;

    this.className = options.className == undefined ? 'default' : options.className
    this.segmentClassName = options.segmentClassName == undefined ? undefined : options.segmentClassName
    this.styleBorder = function tnvArrow_styleBorder() {
        return this.lineStyle + ' ' + this.lineColor + ' ' + this.lineWidth + 'px'
    }
    this.zIndex = zIndexes.arrow_line;
    this.point_default_icon = options.point_default_icon == undefined ? 'none' : options.point_default_icon
    this.points_draw = options.points_draw == undefined ? true : options.points_draw
    this.points_draw_first = options.points_draw_first == undefined ? true : options.points_draw_first
    this.points_draw_middle = options.points_draw_middle == undefined ? false : options.points_draw_middle
    this.points_draw_last = options.points_draw_last == undefined ? true : options.points_draw_last
    this.points = new Array() //Puntos de quiebre que la componen
    this.segments = new Array() //Segmentos entre puntos

    //Define una evaluaci�n que de dar positivo dipara el evento dest_over
    this.dest_eval = options.dest_eval == undefined ? 'false' : options.dest_eval

    this.draw = tnvArrow_draw;
    this.dispose = tnvArrow_dispose;
    this.insert_point = tnvArrow_insert_point;
    this.remove_point = tnvArrow_remove_point;
    this.newFirstIcon = tnvArrow_newFirstIcon;
    this.newMiddleIcon = tnvArrow_newMiddleIcon;
    this.getIniPoint = tnvArrow_getIniPoint;
    this.getMiddlePoint = tnvArrow_getMiddlePoint;
    this.getEndPoint = tnvArrow_getEndPoint;
    this.updateTitle = tnvArrow_updateTitle;
    this.drawSegment = tnvArrow_drawSegment;

    this.dest_over = null //tnvArrow_dest_over; //Se ejecuta cuando la evaluacion dest_eval da verdadera 
    this.dest_over_out = null //tnvArrow_dest_over_out; ////Se ejecuta cuando la evaluacion dest_eval da falsa  

    //Eventos
    this.ondblclick = this.src.onarrowdblclick
    this.onclick = null
    this.afterDraw = options.afterDraw ? options.afterDraw : function() {

    }
    this.onDispose = function() {

    }

    return this;
}
function tnvArrow_updateTitle() {
    if (!this.titleDiv) {
        this.titleDiv = $(document.createElement('span'));
        this.titleDiv.setStyle({
            position: 'absolute',
            top: '50%',
            left: '50%',
            width: '100px',
            height: '16px',
            zIndex: zIndexes.title,
            fontSize: '11px',
            cursor: 'pointer'
        });
    }
    var index;
    var style = {};
    switch(this.title_position){
        case 'ini':
            index = 0;
            break;
        case 'middle':
            index = Math.floor(this.segments.length / 2);
            break;
        case 'fin':
            index = this.segments.length - 1;
            break;
    }
    if(this.title_position == 'middle'){
        style.textAlign = 'center';
        var verticlaDisplacement = -10;
        if(this.segments[index].getWidth() / this.segments[index].getHeight() >= 1){
            verticlaDisplacement = -16;
        }
        this.titleDiv.setStyle({
            marginTop: verticlaDisplacement + 'px',
            marginLeft: '-50px'
        });
    } else {
        var dir;
        if(this.title_position == 'ini'){
            dir = this.direction;
        } else {
            dir = this.reception;
        }
        switch(dir){
            case 'up':
                style.textAlign = 'center';
                this.titleDiv.setStyle({
                    marginTop: '-8px',
                    marginLeft: '-50px'
                });
                break;
            case 'down':
                style.textAlign = 'center';
                this.titleDiv.setStyle({
                    marginTop: '-8px',
                    marginLeft: '-50px'
                });
                break;
            case 'right':
                style.textAlign = 'left';
                this.titleDiv.setStyle({
                    marginTop: '-16px',
                    marginLeft: '0px'
                });
                break;
            case 'left':
                style.textAlign = 'right';
                this.titleDiv.setStyle({
                    marginTop: '-16px',
                    marginLeft: '-100px'
                });
                break;
        }
    }
    
    this.segments[index].setStyle(style);
    this.segments[index].update(this.titleDiv);
    this.titleDiv.update(this.title);
}
function tnvArrow_newFirstIcon(icon_background) {
    if(this.points_draw && this.points_draw_first){
        this.points[0].icon = icon_background;
        this.points[0].draw(true);
        if(this.points_draw_middle){
            this.points[1].icon = icon_background;
            this.points[1].draw(true);
        }
    }
}
function tnvArrow_newMiddleIcon(icon_background) {
    if(this.points_draw && this.points_draw_middle){
        for (var i = 2; i < this.points.length - 1; i++) {
            this.points[i].icon = icon_background;
            this.points[i].draw(true);
        }
    }
}
function tnvRect_getPosMiddle(position)
{
//       var div = this.div
//       var cumOP = div.cumulativeOffset()
//       var cumOParent = this.parent.div.cumulativeOffset()
//       src.x = cumOP.left + div.getWidth()/2 - cumOParent.left
//       src.y = cumOP.top + div.getHeight()/2 - cumOParent.top

    var offsetLeft = this.div.offsetLeft
    var offsetTop = this.div.offsetTop
    var w = this.div.getWidth()
    var h = this.div.getHeight()
    var res = {}
    switch (position)
    {
        case 'top':
            res.left = offsetLeft + w / 2
            res.top = offsetTop
            break;

        case 'bottom':
            res.left = offsetLeft + w / 2
            res.top = offsetTop + h
            break;

        case 'up':
            res.left = offsetLeft + w / 2
            res.top = offsetTop
            break;

        case 'down':
            res.left = offsetLeft + w / 2
            res.top = offsetTop + h
            break;

        case 'left':
            res.left = offsetLeft
            res.top = offsetTop + h / 2
            break;

        case 'right':
            res.left = offsetLeft + w
            res.top = offsetTop + h / 2
            break;
    }
    res.x = res.left
    res.y = res.top
    return res
}
function tnvRect_arrow_dest_over(e, element)
{
 
   if (this._arrow_dest != null)
        this.dest_over_out()

    element = nvCtrls.getRectByElement(element)
    element.div.addClassName('nvCtrl_dest')
    this._arrow_dest = element
}
function tnvRect_getInnerHeight() {
    var fix;
    //if (Prototype.Browser.IE) {
    //    fix = 4;
    //} else {
    //    fix = parseInt(this.div.getStyle('border-top-width').replace('px', '')) + parseInt(this.div.getStyle('border-bottom-width').replace('px', ''));
    //}
    fix = parseInt(this.div.getStyle('border-top-width').replace('px', '')) + parseInt(this.div.getStyle('border-bottom-width').replace('px', ''));
    return this.div.getHeight() - fix;
}
function tnvRect_getInnerWidth() {
    var fix;
    //if (Prototype.Browser.IE) {
    //    fix = 4;
    //} else {
    //    fix = parseInt(this.div.getStyle('border-right-width').replace('px', '')) + parseInt(this.div.getStyle('border-left-width').replace('px', ''));
    //}
    fix = parseInt(this.div.getStyle('border-right-width').replace('px', '')) + parseInt(this.div.getStyle('border-left-width').replace('px', ''));
    return this.div.getWidth() - fix;
}
function tnvRect_getTop() {
    return this.div.positionedOffset().top;
}
function tnvRect_getLeft() {
    return this.div.positionedOffset().left;
}
function tnvRect_getHeight() {
    return this.div.getHeight();
}
function tnvRect_getWidth() {
    return this.div.getWidth();
}
function tnvRect_arrow_dest_over_out(e, element)
{
    if (this._arrow_dest != null)
    {
        this._arrow_dest.div.removeClassName('nvCtrl_dest')
        this._arrow_dest = null
    }
}
function getDirectionVector(direction) {
    switch (direction) {
        case 'right':
            return {x: 1, y: 0};
        case 'left':
            return {x: -1, y: 0};
        case 'up':
            return {x: 0, y: 1};
        case 'down':
            return {x: 0, y: -1};
    }
}
//rota un vector 90 grados en sentido horario
function rotate90cw(vector) {
    var x = vector.x;
    vector.x = vector.y;
    vector.y = -1 * x;
    return vector;
}
//rota un vector 90 grados en sentido anti-horario
function rotate90ccw(vector) {
    var y = vector.y;
    vector.y = vector.x;
    vector.x = -1 * y;
    return vector;
}
function mirrorY(vector) {
    vector.y = -1 * vector.y;
}
function mirrorX(vector) {
    vector.x = -1 * vector.x;
}
//retorna el producto punto de dos vectores
function dotProduct(vector1, vector2) {
    return vector1.x * vector2.x + vector1.y * vector2.y;
}
function tnvArrow_draw(options) {
    this.div = this.parent.div
    if (!options) {
        options = {};
    }
//    var point_src = !options.point_src ? 0 : options.point_src;
    var src_point
    if (options.src_point) {
        src_point = options.src_point;
    } else {
        src_point = this.src.getPosMiddle(this.direction);
    }
    src_point.x = Math.floor(src_point.x);
    src_point.y = Math.floor(src_point.y);
//    src_point = this.src.getPosMiddle(this.direction);
    var dest_point;
    if (options.dest_point) {
        dest_point = options.dest_point;
    } else {
        dest_point = this.dest.getPosMiddle(this.reception);
    }
    dest_point.x = Math.floor(dest_point.x);
    dest_point.y = Math.floor(dest_point.y);
//    dest_point = this.dest.getPosMiddle(this.reception);
//    var point_dest = !options.point_dest ? this.points.length - 1 : options.point_dest;

    src_point.y *= -1;
    dest_point.y *= -1;
    var d = this.distance;

    // muevo el sistema al origen
    var src_mov = {};
    src_mov.x = src_point.x;
    src_mov.y = src_point.y;

    dest_point.x -= src_mov.x;
    dest_point.y -= src_mov.y;
    src_point.x = 0;
    src_point.y = 0;

    var direction = getDirectionVector(this.direction);
    var reception = getDirectionVector(this.reception);
    //roto el sistema para que la direcci�n sea siempre hacia la derecha
    var rotations = 0;
    while (direction.x != 1 || direction.y != 0) {
        rotate90cw(direction);
        rotate90cw(reception);
        rotate90cw(dest_point);
        rotations++;
    }
    //espejo para que siempre vaya para abajo
    var mirrored = false;
    if (dest_point.y < 0) {
        mirrorY(reception);
        mirrorY(dest_point);
        mirrored = true;
    }

    var points = [];
    var dot_product = dotProduct(direction, reception);
    var pos_x;

    points.push(src_point);
    points.push({x: d, y: 0});
    if (dot_product < 0) {
        pos_x = dest_point.x < 2 * d ? -1 : 1;
        if (pos_x > 0) {
            points.push({x: dest_point.x / 2, y: 0});
            points.push({x: dest_point.x / 2, y: dest_point.y});
        } else {
            points.push({x: d, y: dest_point.y / 2});
            points.push({x: dest_point.x - d, y: dest_point.y / 2});
        }
        points.push({x: dest_point.x - d, y: dest_point.y});
    } else if (dot_product > 0) {
        pos_x = dest_point.x < 0 ? -1 : 1;
        if (pos_x > 0) {
            points.push({x: dest_point.x + d, y: 0});
        } else {
            points.push({x: d, y: dest_point.y});
        }
        points.push({x: dest_point.x + d, y: dest_point.y});
    } else {
        if (mirrored) {
            mirrorY(reception);
            mirrorY(dest_point);
            mirrored = false;
        }
        if (reception.x == 0 && reception.y == -1) {
            mirrorY(reception);
            mirrorY(dest_point);
            mirrored = true;
        }
        var pos_y = dest_point.y < -d ? -1 : 1;
        var pos_x = dest_point.x < d ? -1 : 1;

        if (pos_y < 0) {
            if (pos_x < 0) {
                points.push({x: d, y: (dest_point.y + d) / 2});
                points.push({x: dest_point.x, y: (dest_point.y + d) / 2});
            } else {
                points.push({x: dest_point.x, y: 0});
            }
        } else {
            if (pos_x < 0) {
                points.push({x: d, y: dest_point.y + d});
            } else {
                points.push({x: d + (dest_point.x - d) / 2, y: 0});
                points.push({x: d + (dest_point.x - d) / 2, y: dest_point.y + d});
            }
        }
        points.push({x: dest_point.x, y: dest_point.y + d});
    }

    points.push(dest_point);
    var first_icon = this.points[0] ? this.points[0].icon : null;
    //borro los puntos existentes
    this.points.each(function(point) {
        if(point.dispose){
            point.dispose();
        }
    });
    //borro los segmentos
    this.segments.each(function(segment) {
        segment.remove();
    });
    this.segments = [];
    this.points = points;
    var index = -1;
    //saco el sistema del origen
    this.points[0].x += src_mov.x;
    this.points[0].y += src_mov.y;
    this.points[index + 1].y *= -1;
    if(this.points_draw && this.points_draw_first){
        this.points[0] = new tnvPoint({type: 'ini', x: this.points[0].x, y: this.points[0].y, parent: this, parentArrow: this, icon: first_icon})
    }
    var type = 'middle';
    while (++index < (this.points.length - 1)) {
        if (mirrored) {
            mirrorY(this.points[index + 1]);
        }
        for (var i = 0; i < rotations; i++) {
            rotate90ccw(this.points[index + 1]);
        }
        //saco el sistema del origen
        this.points[index + 1].x += src_mov.x;
        this.points[index + 1].y += src_mov.y;
        this.points[index + 1].y *= -1;
        if(this.points_draw && (this.points_draw_middle || (this.points_draw_last && (index + 1) == (this.points.length - 1)))){
            if (index + 1 == this.points.length - 1) {
                type = 'end';
            }
            this.points[index + 1] = new tnvPoint({type: type, x: this.points[index + 1].x, y: this.points[index + 1].y, parent: this, parentArrow: this, icon: first_icon})
        }
        first_icon = null;
        this.drawSegment(this.points[index], this.points[index + 1]);
    }
    this.updateTitle();
    this.afterDraw();
}
function tnvArrow_drawSegment(src, dest) {
    var div = $(document.createElement('div'));
    var thick = '1px';
    var correction = 0;
    var options = {
        zIndex: zIndexes.arrow_line,
        borderWidth: correction + 'px',
        cursor: 'pointer'
    };
    if (src.y == dest.y) {//horizontal
        options.top = src.y - correction + 'px';
        options.left = Math.min(src.x, dest.x) - correction + 'px';
        options.width = Math.abs(dest.x - src.x) + 1 + 'px';
        options.height = thick;
    } else if (src.x == dest.x) {//vertical
        options.top = Math.min(src.y, dest.y) - correction + 'px';
        options.left = src.x - correction + 'px';
        options.width = thick;
        options.height = Math.abs(dest.y - src.y) + 1 + 'px';
    } else {
        console.log(src.x + ',' + src.y);
        console.log(dest.x + ',' + dest.y);
        console.log('---------------');
    }
    div.addClassName('arrow segment');

    if(this.segmentClassName != undefined) {
        div.addClassName(this.segmentClassName);
    }
    this.parent.div.insert({bottom: div});
    div.setStyle(options);
    this.segments.push(div);
    var arrow = this;
    div.observe('dblclick', function(e) {
        if(arrow.ondblclick){
            arrow.ondblclick(arrow, e);
        }
    });
}/*
 function tnvArrow_draw2(options)
 {
 var point_src = !options.point_src ? 0 : options.point_src
 var src = !options.src ? this.points[point_src] : options.src
 var point_dest = !options.point_dest ? this.points.length - 1 : options.point_dest
 var dest = !options.dest ? this.points[point_dest] : options.dest
 
 while (this.points.length > 1)
 {
 var p = this.points.pop()
 p.dispose()
 }
 this.points.push(dest)
 
 var p1
 var p2
 var d = 20
 var quadrant
 var index = 0
 var points_add = new Array()
 while (index < (this.points.length - 1))
 {
 
 p1 = this.points[index]
 p2 = this.points[index + 1]
 quadrant = p1.quadrant(p2)
 if (p2.reception == null)
 p2.reception = quadrant == 'NO' || quadrant == 'NE' ? 'down' : 'up'
 //p2.reception = quadrant == 'NO'  || quadrant == 'SO' ? 'right' : 'left'
 //p2.reception = quadrant == 'NO'  || quadrant == 'SO' ? 'left' : 'right'
 
 //oCB2.div.innerHTML += index + ' - ' + p1.direction + ' - ' + p2.reception + ' - ' + quadrant + ' - '
 
 if (p1.direction == 'down' && p2.reception == 'left' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x - d, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'left' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'left' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x - d, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'right' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'right' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x + d, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'right' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x + d, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'up' && quadrant == 'NO')
 {
 points_add.push(new tnvPoint({x: p2.x, y: p2.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'down' && p2.reception == 'up' && quadrant == 'NE')
 {
 points_add.push(new tnvPoint({x: p2.x, y: p2.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'down' && p2.reception == 'up' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'up' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'down' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'down' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x, y: p1.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'down' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x, y: p2.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'down' && p2.reception == 'down' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x, y: p2.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'left' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x - d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'left' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x - d, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'left' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'right' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x + d, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'right' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'right' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x + d, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'up' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x, y: p2.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'up' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x, y: p2.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'up' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'up' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'down' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'down' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'up' && p2.reception == 'down' && quadrant == 'SO')
 {
 points_add.push(new tnvPoint({x: p2.x, y: p2.y + d, parent: p1.parent, direction: 'up', reception: 'right', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'right', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'up' && p2.reception == 'down' && quadrant == 'SE')
 {
 points_add.push(new tnvPoint({x: p2.x, y: p2.y + d, parent: p1.parent, direction: 'up', reception: 'left', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p1.y - d, parent: p1.parent, direction: 'down', reception: 'left', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'right' && p2.reception == 'left' && quadrant == 'NO')
 {
 points_add.push(new tnvPoint({x: p2.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: p1.x + d, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'right' && p2.reception == 'left' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'left' && quadrant == 'SO')
 {
 points_add.push(new tnvPoint({x: p2.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: p1.x + d, y: (p1.y + p2.y) / 2, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'right' && p2.reception == 'left' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'right' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p1.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'right' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p2.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'right' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p1.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'right' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p2.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'up' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p1.x + d, y: p2.y - d, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'up' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y - d, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'up' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p1.x + d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 
 if (p1.direction == 'right' && p2.reception == 'down' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p1.x + d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'down' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p1.x + d, y: p2.y + d, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'right' && p2.reception == 'down' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y + d, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'left' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: p2.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'left' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p1.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'left' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: p2.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'left' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p1.x - d, y: p2.y, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'right' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'right' && quadrant == 'NE')
 {
 points_add.push(new tnvPoint({x: p2.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: p1.x - d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'left' && p2.reception == 'right' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p2.y, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'right' && quadrant == 'SE')
 {
 points_add.push(new tnvPoint({x: p2.x + d, y: p2.y, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 points_add.push(new tnvPoint({x: p1.x - d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 }
 
 if (p1.direction == 'left' && p2.reception == 'up' && quadrant == 'NO')
 points_add.push(new tnvPoint({x: (p2.x + p1.x) / 2, y: p2.y - d, parent: p1.parent, direction: 'left', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'up' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p1.x - d, y: p2.y - d, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'up' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p1.x - d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'down' && quadrant == 'NE')
 points_add.push(new tnvPoint({x: p1.x - d, y: (p2.y + p1.y) / 2, parent: p1.parent, direction: 'right', reception: 'down', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'down' && quadrant == 'SO')
 points_add.push(new tnvPoint({x: (p1.x + p2.x) / 2, y: p2.y + d, parent: p1.parent, direction: 'left', reception: 'up', className: this.className, parentArrow: this}))
 
 if (p1.direction == 'left' && p2.reception == 'down' && quadrant == 'SE')
 points_add.push(new tnvPoint({x: p1.x - d, y: p2.y + d, parent: p1.parent, direction: 'right', reception: 'up', className: this.className, parentArrow: this}))
 
 while (points_add.length > 0)
 {
 this.insert_point(points_add.pop(), {position: index + 1})
 index++
 }
 index++
 }
 
 index = 0
 var top
 var left
 var width
 var height
 var seg
 while (this.segments.length > 0)
 {
 seg = this.segments.pop()
 //        seg.up().removeChild(seg)
 seg.remove();
 }
 index = 0
 while (index < this.points.length - 1)
 {
 p1 = this.points[index]
 p2 = this.points[index + 1]
 
 //          if (Math.abs(p1.y-p2.y) > 100 && Math.abs(p1.x-p2.x) > 100)
 //            debugger
 top = p1.y < p2.y ? p1.y : p2.y
 left = p1.x < p2.x ? p1.x : p2.x
 width = Math.abs(p1.x - p2.x)
 height = Math.abs(p1.y - p2.y)
 if (width <= 1)
 width = 2
 if (height <= 1)
 height = 2
 var ie_add = 0;
 if (Prototype.Browser.IE) {
 ie_add = this.lineWidth;
 }
 if (!this.segments[index])
 {
 strHTML = "<div id='seg_" + p1.id + "' style='top:" + (top - this.lineWidth / 2) + "px; left: " + (left - this.lineWidth / 2) + "px; width: " + (width + ie_add) + "px; height: " + (height) + "px; overflow: hidden; position: absolute; float: left; z-index:" + this.zIndex + "'/>"
 this.parent.div.insert({top: strHTML})
 seg = $("seg_" + p1.id)
 seg.addClassName(this.className);
 this.segments.push(seg)
 }
 else
 {
 seg = this.segments[index]
 this.segments[index].setStyle({top: top + 'px', left: left + 'px', width: width + 'px', height: height + 'px', border: '0px'})
 }
 var styleBorder = this.styleBorder()
 if (p1.x == p2.x)
 {
 seg.setStyle({borderLeft: styleBorder})
 index++
 continue
 }
 
 if (p1.y == p2.y)
 {
 seg.setStyle({borderTop: styleBorder})
 index++
 continue
 }
 
 if (p1.direction == 'left')
 seg.setStyle({borderLeft: styleBorder})
 
 if (p1.direction == 'right')
 seg.setStyle({borderRight: styleBorder})
 
 if (p1.direction == 'down')
 seg.setStyle({borderBottom: styleBorder})
 
 if (p1.direction == 'up')
 seg.setStyle({borderTop: styleBorder})
 
 if (p2.reception == 'left')
 seg.setStyle({borderLeft: styleBorder})
 
 if (p2.reception == 'right')
 seg.setStyle({borderRight: styleBorder})
 
 if (p2.reception == 'down')
 seg.setStyle({borderBottom: styleBorder})
 
 
 if (p2.reception == 'up')
 seg.setStyle({borderTop: styleBorder})
 
 index++
 }
 
 //dibujar puntos  
 if (this.points_draw)
 {
 this.points.each(function(point, index) {
 //oCB2.div.innerHTML += "Point index: " + index + " - (x, y)(" + point.x + ", " + point.y + ")<br/>" 
 point.draw()
 })
 }
 
 this.updateTitle();
 this.afterDraw();
 }*/
function tnvArrow_getIniPoint() {
    return {
        x: this.points[0].x,
        y: this.points[0].y,
        direction: this.points[0].direction
    };
}
function tnvArrow_getMiddlePoint() {
    return;
    var line_index_1 = Math.floor(this.points.length / 2) - 1;
    var line_index_2 = line_index_1 + 1;
    var point = {};
    if (this.points[line_index_1].x == this.points[line_index_2].x) {//vertical
        point = {
            x: this.points[line_index_1].x,
            y: this.points[line_index_1].y + (this.points[line_index_2].y - this.points[line_index_1].y) / 2
        };
    } else if (this.points[line_index_1].y == this.points[line_index_2].y) {//horizontal
        point = {
            x: this.points[line_index_1].x + (this.points[line_index_2].x - this.points[line_index_1].x) / 2,
            y: this.points[line_index_1].y
        };
    } else {
        point = {
            x: this.points[line_index_1].x + (this.points[line_index_2].x - this.points[line_index_1].x) / 2,
            y: this.points[line_index_1].y + (this.points[line_index_2].y - this.points[line_index_1].y) / 2
        };
    }
    return point;
}
function tnvArrow_getEndPoint() {
    return {
        x: this.points[this.points.length - 1].x,
        y: this.points[this.points.length - 1].y,
        reception: this.points[this.points.length - 1].reception
    };
}
function tnvArrow_dispose()
{
    this.segments.each(function(seg)
    {
        try
        {
//            seg.up().removeChild(seg)
            seg.remove();
        }
        catch (e) {
            console.log(e)
        }
    });
    this.segments.clear()

    while (this.points.length > 0)
        this.remove_point(0)

    var rel;
    //Eliminar relaciones  
    if (this.src != null)
    {
        rel = new Array()
        for (var i = 0; i < this.src.relations.length; i++)
            if (this.src.relations[i] != this)
                rel.push(this.src.relations[i])
        this.src.relations = rel
    }

    if (this.dest != null)
    {
        var rel = new Array()
        for (var i = 0; i < this.dest.relations.length; i++)
            if (this.dest.relations[i] != this)
                rel.push(this.dest.relations[i])
        this.dest.relations = rel
    }
    if (this.titleDiv) {
        try { this.titleDiv.remove(); } catch (e) { console.log(e) }
    }
    this.onDispose()
}

function tnvArrow_insert_point(point, options)
{
    if (!options)
        options = {}

    //point.zIndex = this.zIndex + 5
    point.icon = this.point_default_icon

    var pos = !options.position ? this.points.length : options.position
    this.points.push(point)
    var length = this.points.length
    for (var i = length - 2; i >= pos; i--)
        this.points[i + 1] = this.points[i]
    this.points[pos] = point
}

function tnvArrow_remove_point(index)
{
    var point = this.points[index]
    var length = this.points.length
    for (var i = index; i <= length - 2; i++)
        this.points[i] = this.points[i + 1]
    this.points.pop()
    if (point.div != null) {
//        point.div.up().removeChild(point.div)
        point.div.remove();
    }
}

var zIndexes = {
    canvas: 0,
    pool: 1,
    arrow_line: 2,
    arrow_symbol: 4,
    element: 5,
    annotation: 3,
    title: 6,
    selector: 9999,
    selected: 10000
}
var Icons = {
    'arrow_up': 'point_arrow_up.png',
    'arrow_right': 'point_arrow_right.png',
    'arrow_down': 'point_arrow_down.png',
    'arrow_left': 'point_arrow_left.png',
    'default': 'point_default.png',
    //'output_false': 'point_output_false.png',
    'condition': 'point_condition.png',
    'no_condition': 'point_no_condition.png',
    'empty': 'point_no_condition.png'
//    'empty': ''
}

function isEmpty(obj) {

    // null and undefined are "empty"
    if (obj == null) return true;

    // Assume if it has a length property with a non-zero value
    // that that property is correct.
    if (obj.length > 0)    return false;
    if (obj.length === 0)  return true;

    // Otherwise, does it have any properties of its own?
    // Note that this doesn't handle
    // toString and toValue enumeration bugs in IE < 9
    for (var key in obj) {
        if (hasOwnProperty.call(obj, key)) return false;
    }

    return true;
}