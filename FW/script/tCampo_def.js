/*******************************************/
// Librerías que se carga a demanda
/*******************************************/
function IMask(inputelement, option) {
    nvFW.chargeJSifNotExist("", '/FW/script/IMask/imask.js')
    return IMask(inputelement, option)
}

//Objeto global de control
function tCampos_defs() {
    this.items = {}; //Colección de campo_def creados
    this.filtroWhere = get_filtroWhere; //Recupera el filtroWhere teniendo en cuentas las definiciones de los controles
    this.add = campo_def_add; //Agregar nuevo campo_def
    this.remove = campo_def_remove; //Quitar el campo def de la estructura
    this.clear = campo_def_clear //Limpiar campo def
    this.get_value = campo_def_get_value //Recuperar valor de código seleccionado
    this.value = campo_def_get_value //idem anterior
    this.value = campo_def_get_value //Idem Anterior - no usar
    this.get_desc = campo_def_get_desc //Recuperar descripcion del elemento seleccionado;
    this.desc = campo_def_get_desc //Idem Anterior - no usar
    this.set_value = campo_def_set_value  //Setea el valor del control desde el código
    this.set_valueRS = campo_def_set_valueRS  //Setea el valor del control desde el código (recibe un objeto)
    this.set_first = campo_def_set_first  //Setea el valor del control al primer valor del resultado
    this.habilitar = campo_def_habilitar //Habilita y deshabilita el control cargar
    this.get_campo_id = campo_def_get_campo_id //Devuelve el nombre de campo de la DB que contiene el ID
    this.campo_id = campo_def_get_campo_id //Idem anterior - No usar
    this.get_campo_desc = campo_def_get_campo_desc //Devuelve el nombre de campo de la DB que contiene el ID
    this.campo_desc = campo_def_get_campo_desc //Idem anterior - No usar
    this.get_html = campo_def_get_html; //Genera e inserta el codigo HTML que dibuja el control
    this.onchange = campo_def_onchange;  //Ejecuta la funcion onchange en caso que existe  
    this.focus = campo_def_focus; //Pone el foco sobre el campo 
    this.getRS = campo_def_getRS; //recupera el rs que dio origen al combo
    this.preview = campo_def_preview;
    this.clear_list = campo_def_clear_list; //limpia el combo del campo def


    this.onclick = campo_def_onclick
    this.click_out = campo_def_click_out //Click fuera del control - Ocultar 
    this.cb_onkeypress = campo_def_cb_onkeypress
    this.onkeypress_autocomplete = campo_def_onkeypress_autocomplete
    this.cb_onclick = campo_def_cb_onclick
    this.cbmultiok_onclick = campo_def_cbmultiok_onclick
    this.codigo_onchange = campo_def_codigo_onchange

    this.clickout_autocomplete = campo_def_clickout_autocomplete //Limpia el campo en caso de no haber seleccion y no coincidir por completo con ninguna opcion
    this.onblur = campo_def_onblur

    this.divCampo_def_vidrio = null //Vidrio para capturar el click out
    this.divCampo_def = null //Campo def visible
    this.campo_def_get_path = null //Path de ajax_request para obtener el campo_def

    nvFW.chargeCSS("/fw/css/tCampo_def.css", ".campo_def_div_contenedor")
}

function campo_def_preview(campo_def) {
    var valor = this.value(campo_def)
    if (valor > 0) {

        var win = window.top.nvFW.createWindow({
            className: "alphacube",
            title: "Thumbail",
            width: 320, height: 320,
            minimizable: false,
            maximizable: false,
            maxWidth: 900,
            maxHeight: 600,
            resizable: false,
            draggable: false
        })
        var url = '/FW/file_preview.asp?f_id=' + valor + '&thumb_height=300&thumb_width=300&id_ventana=' + win.getId()
        win.setURL(url)
        win.showCenter(true);
    }
}
/*Elimina un campo def*/
function campo_def_remove(campo_def) {
    var new_items = {}
    for (var i in this.items)
        if (i != campo_def)
            new_items[i] = this.items[i]
        else {
            //Elimina todos los elementos HTML asociados al campos_def
            for (el in this.items[i])
                try {
                    if (this.items[i][el] instanceof HTMLElement) {
                        var eHtml = this.items[i][el]
                        var parent = eHtml.parentElement
                        parent.removeChild(eHtml)
                        this.items[i][el] = undefined
                        eHtml = undefined
                    }
                }
                catch (e) { }
        }
    this.items = new_items
}


//Agregar campo def
function campo_def_add(campo_def, parametros) {

    if (!parametros)
        parametros = {}

    var descripcion = ''
    var filtroXML = ''
    var vistaGuardada = ''
    var nro_campo_tipo = null
    var filtroWhere = ''
    var depende_de = null
    var depende_de_campo = ''
    var depende_de_seleccion = ''
    var permite_codigo = false
    var json = true
    var cacheControl = 'none'
    var max_size = 0
    var filter = ''
    var despliega = 'abajo'
    var StringValueIncludeQuote = false
    var campo_codigo = ""
    var campo_desc = ""
    var file_dialog
    var mostrar_codigo = true
    var sin_seleccion = true
    var autocomplete = false
    var autocomplete_match = 'todo' //todo, solo_inicio
    var autocomplete_minlength = 0
    var native_autocomplete = false
    var placeholder = ''
    var mask = {}
    var onmask_complete = function () { return }
    var onmask_change = function () { return }

    //Identifica si se debe recuperar información de la base de datos
    var enDB = parametros.enDB == undefined ? true : parametros.enDB

    var options = typeof parametros.options != 'undefined' ? parametros.options : {}

    if (enDB) {
        var _nvFW = window.top.nvFW
        if (!_nvFW)
            _nvFW = nvFW

        var er
        var cache = _nvFW.cache.get('tCampo_def', { campo_def: campo_def })
        if (cache != null) //Recuperar datos de la cache
            er = cache['valores']['tError']
        else //Recuperar datos de la base de datos
        {
            er = new tError()
            er.Ajax_request(this.campo_def_get_path + "?campo_def=" + campo_def, { async: false })
            if (er.numError == 0) nvFW.cache.add("tCampo_def", { campo_def: campo_def }, { tError: er })
        }
        if (er.numError == 0) {
            filtroXML = er.params['filtroXML']
            filtroWhere = er.params['filtroWhere']
            depende_de = er.params['depende_de']
            depende_de_campo = er.params['depende_de_campo']
            nro_campo_tipo = er.params['nro_campo_tipo']
            permite_codigo = er.params['permite_codigo'] == 'true'
            json = er.params['json'] == 'true'
            cacheControl = er.params['cacheControl']
            campo_codigo = er.params['campo_codigo']
            campo_desc = er.params['campo_desc']
            options = er.params['options']
            if (options == "") options = {}
        }
    }

    try {
        options = JSON.parse(options)
        for (var element in options) {
            switch (typeof options[element]) {
                case 'string':
                    eval(element + ' = ' + '"' + options[element] + '"')
                    break;
                case 'boolean':
                    eval(element + ' = ' + options[element])
                    break;
                case 'number':
                    eval(element + ' = ' + options[element])
                    break;
                case 'object':
                    eval(element + ' = ' + JSON.stringify(options[element]))
                    break;
                default:
                    eval(element + ' = ' + '"' + options[element] + '"')
                    break;
            }
        }
    }
    catch (ex) {
    }

    //Actualizar datos con los parametros pasados
    descripcion = !parametros.descripcion ? descripcion : parametros.descripcion
    nro_campo_tipo = !parametros.nro_campo_tipo ? nro_campo_tipo : parametros.nro_campo_tipo
    depende_de = !parametros.depende_de ? depende_de : parametros.depende_de
    vistaGuardada = !parametros.vistaGuardada ? vistaGuardada : parametros.vistaGuardada
    filtroXML = !parametros.filtroXML ? filtroXML : parametros.filtroXML
    filtroWhere = !parametros.filtroWhere ? filtroWhere : parametros.filtroWhere
    depende_de_campo = !parametros.depende_de_campo ? depende_de_campo : parametros.depende_de_campo
    permite_codigo = typeof (parametros.permite_codigo) == 'undefined' ? permite_codigo : parametros.permite_codigo
    json = typeof (parametros.json) == 'undefined' ? json : parametros.json
    cacheControl = !parametros.cacheControl ? cacheControl : parametros.cacheControl
    StringValueIncludeQuote = !parametros.StringValueIncludeQuote ? StringValueIncludeQuote : parametros.StringValueIncludeQuote

    max_size = !parametros.max_size ? max_size : parametros.max_size
    filter = !parametros.filter ? filter : parametros.filter
    despliega = !parametros.despliega ? despliega : parametros.despliega
    campo_codigo = !parametros.campo_codigo ? campo_codigo : parametros.campo_codigo
    campo_desc = !parametros.campo_desc ? campo_desc : parametros.campo_desc
    file_dialog = parametros.file_dialog
    mostrar_codigo = typeof (parametros.mostrar_codigo) == 'undefined' ? (mostrar_codigo && nro_campo_tipo != 4) : parametros.mostrar_codigo == true
    sin_seleccion = typeof (parametros.sin_seleccion) == 'undefined' ? sin_seleccion : parametros.sin_seleccion == true
    autocomplete = typeof (parametros.autocomplete) == 'undefined' ? autocomplete : parametros.autocomplete == true
    //El tipo 4 es siempre autocomplete
    if (nro_campo_tipo == 4)
        autocomplete = true
    autocomplete_match = typeof (parametros.autocomplete_match) == 'undefined' ? autocomplete_match : parametros.autocomplete_match
    autocomplete_minlength = typeof (parametros.autocomplete_minlength) == 'undefined' ? autocomplete_minlength : parametros.autocomplete_minlength
    native_autocomplete = typeof (parametros.native_autocomplete) == 'undefined' ? native_autocomplete : parametros.native_autocomplete == true
    placeholder = typeof (parametros.placeholder) == 'undefined' ? placeholder : parametros.placeholder
    //Mascara para campo decimal con separador de miles
    if (nro_campo_tipo == 121)
        mask = {
            mask: Number,
            scale: 2, //Dígitos después del punto
            radix: ',', //Separador de decimales
            mapToRadix: ['.'],  //Separador de decimales sin mascara
            padFractionalZeros: true,  //Si es verdadero, coloca ceros al final de la escala
            thousandsSeparator: '.' //Separador de miles
        }
    mask = typeof (parametros.mask) == 'undefined' ? mask : parametros.mask
    onmask_complete = typeof (parametros.onmask_complete) == 'undefined' ? onmask_complete : parametros.onmask_complete
    onmask_change = typeof (parametros.onmask_change) == 'undefined' ? onmask_change : parametros.onmask_change

    var onblur = typeof (parametros.onblur) == 'undefined' ? null : parametros.onblur
    var onchange = !parametros.onchange ? null : parametros.onchange
    var onchargefinish = !parametros.onchargefinish ? null : parametros.onchargefinish
    var target = parametros.target == undefined ? 'document.write' : parametros.target

    this.items[campo_def] = {};
    this.items[campo_def]['campo_def'] = campo_def
    this.items[campo_def]['descripcion'] = descripcion
    this.items[campo_def]['vistaGuardada'] = vistaGuardada
    this.items[campo_def]['filtroXML'] = filtroXML
    this.items[campo_def]['filtroWhere'] = filtroWhere
    this.items[campo_def]['depende_de'] = depende_de
    this.items[campo_def]['depende_de_campo'] = depende_de_campo
    this.items[campo_def]['nro_campo_tipo'] = nro_campo_tipo
    this.items[campo_def]['onchange'] = onchange
    this.items[campo_def]['onchargefinish'] = onchargefinish
    this.items[campo_def]['permite_codigo'] = permite_codigo
    this.items[campo_def]['json'] = json
    this.items[campo_def]['cacheControl'] = cacheControl
    this.items[campo_def]['max_size'] = max_size
    this.items[campo_def]['filter'] = filter
    this.items[campo_def]['despliega'] = despliega
    this.items[campo_def]['campo_codigo'] = campo_codigo
    this.items[campo_def]['campo_desc'] = campo_desc
    this.items[campo_def]['StringValueIncludeQuote'] = StringValueIncludeQuote
    this.items[campo_def]['file_dialog'] = file_dialog
    this.items[campo_def]['disabled'] = false
    this.items[campo_def]['mostrar_codigo'] = mostrar_codigo
    this.items[campo_def]['sin_seleccion'] = sin_seleccion
    this.items[campo_def]['autocomplete'] = autocomplete
    this.items[campo_def]['autocomplete_match'] = autocomplete_match
    this.items[campo_def]['autocomplete_minlength'] = autocomplete_minlength
    this.items[campo_def]['native_autocomplete'] = native_autocomplete
    this.items[campo_def]["depende_de_seleccion"] = depende_de_seleccion //Atributo para verificar si cambio la seleccion del padre
    this.items[campo_def]["placeholder"] = placeholder
    this.items[campo_def]["mask"] = mask
    this.items[campo_def]["onmask_complete"] = onmask_complete
    this.items[campo_def]["onmask_change"] = onmask_change
    this.items[campo_def]["onblur"] = onblur


    for (var c in parametros)
        if (this.items[campo_def][c] == undefined && c.toLowerCase() != 'depende_de')
            this.items[campo_def][c] = parametros[c]

    //Insertar el HTML
    var strHTML = ""
    if (this.items[campo_def]['nro_campo_tipo'] > 0)
        strHTML = this.get_html(campo_def, target)
    //Si depende de otro campo
    depende_de = this.items[campo_def]['depende_de']
    if (depende_de != null && this.items[depende_de] != undefined) {
        if (!this.items[depende_de]["dependientes"])
            this.items[depende_de]["dependientes"] = new Array();

        this.items[depende_de]["dependientes"][this.items[depende_de]["dependientes"].length] = this.items[campo_def]
        //        var handler = function ()
        //                        {
        //                        debugger
        //                        var cb = $('cb' + campo_def)
        //                        if(cb != null)  
        //                          cb.options.length = 0 
        //                        $(campo_def).value = '' 
        //                        $(campo_def + '_desc').value = ''
        //                        }
        //                                                                  
        //        var e = $(depende_de)
        //        if (!!document.all)
        //          Event.observe(e, 'propertychange', handler); 
        //        else
        //          {
        //          Event.observe($(depende_de), 'change', handler); 
        //          Event.observe($(depende_de), 'DOMAttrModified', handler);
        //          //e.addEventListener('change', handler, false); //Firefox                                                  
        //          //e.addEventListener('DOMAttrModified', handler, false)
        //          }
    }

    this.items[campo_def]['input_hidden'] = $(campo_def)
    this.items[campo_def]['input_text'] = $(campo_def + "_desc")
    this.items[campo_def]['input_limpiar'] = $("btnLim_" + campo_def)

    if (this.items[campo_def]['autocomplete']) //Si es autocomplete precarga el rs si no tiene valor asignado
        setTimeout(function () { if (campos_defs.get_value(campo_def) == "") campos_defs.set_value(campo_def, "") }, 500)

    if (Object.keys(this.items[campo_def]['mask']).length !== 0) //Si tiene mascara
    {
        //ver cual es hidden, en >  100 $('campo_def') campo_def_desc = hidden, en < 100 $('campo_def_desc') campo_def = hidden
        this.items[campo_def]['objMask'] = IMask($(campo_def), this.items[campo_def]['mask'])
        this.items[campo_def]['objMask'].on('complete', function () //Funcion de mascara que se ejecuta cuando el campo esta completo
        {
            return campos_defs.items[campo_def]["onmask_complete"](campo_def, campos_defs.items[campo_def])
        })
        this.items[campo_def]['objMask'].on('accept', function () //Funcion de mascar que se ejecuta cuando hay cambios en el campo
        {
            return campos_defs.items[campo_def]["onmask_change"](campo_def, campos_defs.items[campo_def])
        })
    }


    return strHTML
}


function campo_def_onblur(campo_def) {
    if (typeof this.items[campo_def]['onblur'] == 'function')
        this.items[campo_def]['onblur'](campo_def, this.items[campo_def])
}

function campo_def_onmask_complete(campo_def) {
    if (typeof this.items[campo_def]['onmask_complete'] == 'function')
        this.items[campo_def]['onmask_complete'](campo_def, this.items[campo_def])
}

function campo_def_onmask_change(campo_def) {
    if (typeof this.items[campo_def]['onmask_change'] == 'function')
        this.items[campo_def]['onmask_change'](campo_def, this.items[campo_def])
}

function campo_def_getRS(campo_def) {
    var rs = this.items[campo_def].rs
    if ((this.items[campo_def]['nro_campo_tipo'] == 1 || this.items[campo_def]['nro_campo_tipo'] == 3) && rs != undefined)
        if (this.items[campo_def].sin_seleccion) {
            if (this.items[campo_def]['input_select'].selectedIndex > 0)
                rs.position = this.items[campo_def]['input_select'].selectedIndex - 1
        }
        else rs.position = this.items[campo_def]['input_select'].selectedIndex

    return rs
}

function campo_def_focus(campo_def) {
    try {
        if (this.items[campo_def]['input_text'].type == 'hidden')
            this.items[campo_def]['input_hidden'].focus()
        else
            this.items[campo_def]['input_text'].focus()
    }
    catch (e) { }
}
var _cambiar_codigo_control = true
function campo_def_codigo_onchange(e, campo_def) {
    if (_cambiar_codigo_control) {
        _cambiar_codigo_control = false
        src = Event.element(e)
        cod = src.value
        if (replace(cod, ' ', '') == '')
            this.clear(campo_def)
        else
            this.set_value(campo_def, cod)
        _cambiar_codigo_control = true
    }

}
function campo_def_onchange(e, campo_def) {
    if (!!this.items[campo_def]["dependientes"]) {
        for (var i = 0; i < this.items[campo_def]["dependientes"].length; i++) {
            this.clear(this.items[campo_def]["dependientes"][i].campo_def)
        }
    }
    if (typeof (this.items[campo_def]["onchange"]) == 'function')
        this.items[campo_def]["onchange"](e, campo_def)
}


function campo_def_clickout_autocomplete(campo_def) {
    //Si no se selecciona y hay un valor igual al escrito, setea el valor, si no borra (comportamiento con tipo 1)
    var noSelected = false
    var objCb = this.items[campo_def]['input_select'] = $('cb' + campo_def)
    var valor = this.get_value(campo_def)
    var desc = this.get_desc(campo_def)
    if (valor == '' && desc != '') {
        noSelected = true
        for (var i = 0; i < objCb.options.length; i++) {
            if (desc.toLowerCase() == objCb.options[i].text.toLowerCase()) //Si encuentra coincidencia en el combo, selecciona
            {
                Element.addClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")
                this.items[campo_def]["input_hidden"].value = objCb.options[i].value
                this.items[campo_def]["input_text"].value = objCb.options[i].text
                objCb.selectedIndex = i

                noSelected = false
                break
            }
        }
    }
    if (noSelected) //Si no encuentra coincidencia
    {
        if (this.items[campo_def]['nro_campo_tipo'] == 1)
            this.clear(campo_def)
        else {
            this.items[campo_def]["input_hidden"].value = desc
            this.items[campo_def]["input_text"].value = desc
            objCb.selectedIndex = -1
        }
    }
    else this.onchange(null, campo_def)
}

function campo_def_tabkey(ev, campo_def) {
    if (ev.keyCode == 9 || ev.keyCode == 13 || ev.keyCode == 27)
        campos_defs.click_out(campo_def)
}


//Devuelve el codigo html del control
function campo_def_get_html(campo_def, target) {
    var str_native_autocomplete = ''
    if (!this.items[campo_def]["native_autocomplete"])
        str_native_autocomplete = "autocomplete='off'"
    var nro_campo_tipo = this.items[campo_def]['nro_campo_tipo']
    if (nro_campo_tipo >= 200 && nro_campo_tipo < 300) {
        strHTML = "<input type='hidden' name='" + campo_def + "' id='" + campo_def + "' style='display: none' value='0'>"

        var allow_image_preview = nro_campo_tipo == 201
        var upload = this.items[campo_def]['upload'] = new tUpload(target, this.items[campo_def]['max_size'], this.items[campo_def]['filter'], allow_image_preview)
        $$('BODY')[0].insert({ bottom: strHTML })
        upload.campo_def = campo_def
        upload.onchange = function (upload) {
            campos_defs.items[upload.campo_def]['input_hidden'].value = upload.getValue() == null ? 0 : upload.getValue()
            if (campos_defs.items[upload.campo_def]['onchange'] != null)
                campos_defs.items[upload.campo_def]['onchange'](null, upload.campo_def)
        }
        return ''
    }
    var strHTML = '<table class="tb1 cdef" id="campo_def_tb' + campo_def + '" cellspacing="0" cellpadding="0" style="width: 100%" border="0"><tr>'

    if (nro_campo_tipo < 100) {
        strHTML += "<td style='width: 100%; text-align:center;white-space:nowrap;'><input type='hidden' name='" + campo_def + "' id='" + campo_def + "'><input  class='' type='text' id='" + campo_def + "_desc' style='width: 100%;padding-right: 17px; ' "
        strHTML += "placeholder='" + this.items[campo_def]['placeholder'] + "'"
        if (!this.items[campo_def]["permite_codigo"] && !this.items[campo_def]["autocomplete"])
            strHTML += " readonly='true' ontouchstart='return campos_defs.onclick(event, \"" + campo_def + "\")'"
        else if (this.items[campo_def]["autocomplete"])
            strHTML += " " + str_native_autocomplete + " onkeypress='campos_defs.onkeypress_autocomplete(event, \"" + campo_def + "\", true)' onkeyup='campos_defs.onkeypress_autocomplete(event, \"" + campo_def + "\", true)' onkeydown='return campo_def_tabkey(event, \"" + campo_def + "\" )'"
        else
            strHTML += " " + str_native_autocomplete + " onchange='campos_defs.codigo_onchange(event, \"" + campo_def + "\" )'"
        strHTML += " onblur='campos_defs.onblur(\"" + campo_def + "\")' "
        if (nro_campo_tipo != 4) {
            strHTML += " ondblclick='return campos_defs.onclick(event, \"" + campo_def + "\")' >"
            strHTML += "<img src='" + campos_defs.url_img_down + "' class='" + campos_defs.class_img_down + "' border='0' align='absmiddle' hspace='1' id='img_down' ontouchstart='return campos_defs.onclick(event, \"" + campo_def + "\")' onclick='return campos_defs.onclick(event, \"" + campo_def + "\")'>"
        }
        else strHTML += ">"
        strHTML += "</td><td><img src='" + campos_defs.url_img_clear + "' title='Limpiar' class='img_clear' readonly='true' onclick='return campos_defs.clear(\"" + campo_def + "\")'></td>"
        if (this.items[campo_def]["preview"] == true)
            strHTML += "<td><img src='/FW/image/campo_def/preview.png' alt='Preview' style='cursor: hand; cursor: pointer' id='btnPreview_" + campo_def + "' onclick='return campos_defs.preview( \"" + campo_def + "\")'>"
        strHTML += "</td>"
    }
    else {
        strHTML += "<td style='width: 100%' nowrap><input type='hidden' id='" + campo_def + "_desc' onkeypress='return campos_defs.cb_onkeypress(event, \"" + campo_def + "\")'/>"
        strHTML += "<input  id='" + campo_def + "' " + str_native_autocomplete + " "
        strHTML += "placeholder='" + this.items[campo_def]['placeholder'] + "' "
        strHTML += "onblur='campos_defs.onblur(\"" + campo_def + "\")' "
        switch (nro_campo_tipo) {
            case 100:  //Valores enteros
                if (Object.keys(this.items[campo_def]['mask']).length === 0)
                    strHTML += 'type="number" onkeypress="return valDigito(event)"  onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                else strHTML += ' type="text" onkeypress="return valDigito(event)" inputmode="numeric" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                break;
            case 101: //Valores enteros separados por comas o guiones
                strHTML += ' type="text" inputmode="numeric" onkeypress="return valDigito(event, \'-,\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                break;
            case 102: //Valores decimales
                if (Object.keys(this.items[campo_def]['mask']).length === 0)
                    strHTML += ' type="number" onkeypress="return valDigito(event, \'-.\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                else strHTML += ' type="text" inputmode="numeric" onkeypress="return valDigito(event, \'-.\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                break;
            case 103: //Valores de tipo fecha
                strHTML += ' type="date" onkeypress="return valDigito(event, \'/\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                strHTML += "<td><img src='" + campos_defs.url_img_clear + "' title='Limpiar' class='img_clear' readonly='true' onclick='return campos_defs.clear(\"" + campo_def + "\")'></td>"
                break;
            case 104: //Texto libre
                strHTML += ' type="text" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: left"/>'
                break;
            case 105: //Valores de tipo fecha
                strHTML += ' type="datetime-local" onkeypress="return valDigito(event, \'/\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                strHTML += "<td><img src='" + campos_defs.url_img_clear + "' title='Limpiar' class='img_clear' readonly='true' onclick='return campos_defs.clear(\"" + campo_def + "\")'></td>"
                break;
            case 121: //Valores decimales con separador de miles
                strHTML += ' type="text" inputmode="numeric" onkeypress="return valDigito(event, \'.,\')" onchange="campos_defs.onchange(event, \'' + campo_def + '\')" style="width: 100%; text-align: right"/>'
                break;
        }

        strHTML += "</td>"

    }
    strHTML += "</tr></table>"
    switch (target) {
        case "document.write":
            document.write(strHTML)
            break;
        case "return_html":
            break;
        default:
            var contenedor = $(target)
            if (contenedor != null)
                contenedor.insert({ bottom: strHTML })
        //else
        //  nvFW.alert("Campo def. El contenedor no '" + campo_def + "' no existe.")
    }
    return strHTML
}

function campo_def_habilitar(campo_def, habilitar) {
    $(campo_def).disabled = !habilitar
    //this.items[campo_def]["input_hidden"]
    try {
        this.items[campo_def].disabled = !habilitar
        this.items[campo_def]["input_text"].disabled = !habilitar
        //this.items[campo_def]["input_button"].disabled = !habilitar
        this.items[campo_def]["input_limpiar"].disabled = !habilitar
    }
    catch (e) { }
}

function campo_def_get_value(campo_def) {
    //Si tiene mascara, devuelve el valor sin mascara
    var value = typeof this.items[campo_def]['objMask'] == 'undefined' ? this.items[campo_def]["input_hidden"].value : this.items[campo_def]['objMask'].unmaskedValue

    if ((this.items[campo_def]["nro_campo_tipo"] == 103 || this.items[campo_def]["nro_campo_tipo"] == 105) && value != "") {
        var fechaSTR = ''
        switch (this.items[campo_def]["nro_campo_tipo"]) {
            case 103:
                fe = parseFecha(this.items[campo_def]["input_hidden"].value, 'yyyy-mm-dd')
                fechaSTR = FechaToSTR(fe)
                break;
            case 105:
                fe = parseFecha(this.items[campo_def]["input_hidden"].value, 'yyyy-mm-ddThh:mm')
                fechaSTR = FechaToSTR(fe) + ' ' + HoraToSTR(fe, 'hh:mm')
                break;
        }
        
        return fechaSTR
    }
    else
        return value
}

function campo_def_get_desc(campo_def) {
    return this.items[campo_def]["input_text"].value
}

function campo_def_get_campo_id(campo_def) {
    var filtroXML = this.items[campo_def]["filtroXML"]
    if (filtroXML == '') {
        var rs = new tRS();
        rs.open("<criterio><select vista='campos_def'><campos>filtroXML</campos><filtro><campo_def type='igual'>'" + campo_def + "'</campo_def></filtro></select></criterio>")
        /*Identifica el campo que utiliza como ID para buscar por el mismo*/
        var filtroXML = rs.getdata('filtroXML')
        if (filtroXML != null)
            filtroXML = eval(filtroXML)
        this.items[campo_def]["filtroXML"] = filtroXML
    }
    var str = "(\\w*)\\s+as\\s+\\[?id]?" // busca ????? as id  O ????? as [id]
    var reg = new RegExp(str)
    var res = filtroXML.toLowerCase().match(reg)
    id = res[1]
    return id
}


function campo_def_get_campo_desc(campo_def) {
    var filtroXML = this.items[campo_def]["filtroXML"]
    if (filtroXML == '') {
        var rs = new tRS();
        rs.open("<criterio><select vista='campos_def'><campos>filtroXML</campos><filtro><campo_def type='igual'>'" + campo_def + "'</campo_def></filtro></select></criterio>")
        /*Identifica el campo que utiliza como ID para buscar por el mismo*/
        var filtroXML = rs.getdata('filtroXML')
        if (filtroXML != null)
            filtroXML = eval(filtroXML)
        this.items[campo_def]["filtroXML"] = filtroXML
    }
    //var str = "(>|id\\s)(.*)\\sas\\s\\[?campo\\[?" // busca ????? as campo  O ????? as [campo]
    str = "([^>]*)\\s+as\\s+\\[?campo]?"// busca ????? as campo  O ????? as [campo]
    var reg2 = new RegExp(str)
    var res2 = filtroXML.toLowerCase().match(reg2)
    var strCampos = res2[1]

    str = "(.*)id]?\\s*,"// busca ????? as campo  O ????? as [campo]
    var reg3 = new RegExp(str)
    campo = strCampos.replace(reg3, "")
    return campo
}
/*
var values = {0:{paiscod:1, bacocod:32, tiprel:2}}
var values2 =  {0:{paiscod:1, bacocod:32, tiprel:2},
                1:{paiscod:1, bacocod:32, tiprel:3},
                2:{paiscod:1, bacocod:32, tiprel:5}}

*/
function campo_def_set_valueRS(campo_def, values) {

    if (this.items[campo_def]['nro_campo_tipo'] == 3) //si es tipo 3 genero filtroWhere y obtengo rs
    {
        var id = this.items[campo_def]["campo_codigo"]
        //var campo = this.items[campo_def]["campo_desc"]

        var valor = ''

        var filtroXML = this.items[campo_def]["filtroXML"]
        var filtroWhere = ""

        for (index in values) {
            for (campo in values[index]) {
                if (campo == id)
                    valor = values[index][campo]
                filtroWhere += "<" + campo + ">" + values[index][campo] + "</" + campo + ">"
            }
        }

        var rs2 = new tRS();
        rs2.format = this.items[campo_def]['json'] ? 'getterror' : 'getxml_json'
        rs2.format_tError = rs2.format == "getterror" ? 'json' : rs2.format_tError
        rs2.open(filtroXML, undefined, filtroWhere)

        this.items[campo_def].rs = rs2 //Guardar rs del campo_def

        if (!rs2.eof()) {
            var desc = rs2.getdata("campo")
            $(campo_def).value = valor
            $(campo_def + '_desc').value = desc + ' (' + valor + ')'
            //Carga de input_select
            this.items[campo_def].nro_campo_tipo = 1
            this.onclick(null, campo_def, false)

            if (this.items[campo_def]['sin_seleccion']) //Si sin_seleccion = true, seleccionar el segundo valor
                this.items[campo_def]['input_select'].options.selectedIndex = 1

            this.items[campo_def].nro_campo_tipo = 3

        }
        else {
            $(campo_def).value = ''
            $(campo_def + '_desc').value = ''
        }
        this.onchange(null, campo_def)
        return
    }

    var inicio = (this.items[campo_def]['sin_seleccion']) ? 1 : 0;
    if (this.onclick(null, campo_def, false)) {
        var objCb = $('cb' + campo_def)
        var rs = this.items[campo_def].rs
        rs.position = 0
        var bandera = true
        while (!rs.eof()) {
            for (index in values) {
                bandera = true
                for (campo in values[index])
                    if (rs.getdata(campo) != values[index][campo]) {
                        bandera = false
                        break;
                    }
                if (bandera)
                    break;
            }
            objCb.options[rs.position + inicio].selected = bandera
            rs.movenext()
        }
        campos_defs.cbmultiok_onclick(null, campo_def)
    }
}

function campo_def_set_value(campo_def, valor) {

    if (this.items[campo_def]['nro_campo_tipo'] >= 200 && this.items[campo_def]['nro_campo_tipo'] < 300) {
        alert('No se puede actualizar un campo de este tipo')
        return
    }
    valor = valor.toString()
    if (this.items[campo_def]['nro_campo_tipo'] >= 100) {

        //validar formato de fecha
        if (valor != '' && (this.items[campo_def]['nro_campo_tipo'] == 103 || this.items[campo_def]['nro_campo_tipo'] == 105)) {
            var regFecha = /^([0-2]?[0-9]|(3)[0-1])(\/)(((0)?[0-9])|((1)[0-2]))(\/)\d{4}$/
            var arregloFechaHora = valor.split(' ')
            if (!arregloFechaHora[0].match(regFecha)) {
                alert('Formato de fecha no permitido (dd/mm/yyyy)');
                return;
            }
            
            var arregloFecha = arregloFechaHora[0].split('/');
            valor = arregloFecha[2] + '-' + arregloFecha[1].padStart(2, '0') + '-' + arregloFecha[0].padStart(2, '0');

            if (this.items[campo_def]['nro_campo_tipo'] == 105) {
                var regHora = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/
                valor += !!arregloFechaHora[1] && arregloFechaHora[1].match(regHora) ? 'T' + arregloFechaHora[1] : 'T00:00';
            }

        }
        var oldValue = this.items[campo_def]['input_text'].value
        this.items[campo_def]['input_text'].value = valor
        if (typeof this.items[campo_def]['objMask'] == 'undefined') //Si no tiene mascara definida
            this.items[campo_def]['input_hidden'].value = valor
        else
            this.items[campo_def]['objMask'].unmaskedValue = valor
        if (oldValue != valor)
            this.onchange(null, campo_def)
        return
    }

    if (this.items[campo_def]['nro_campo_tipo'] == 90) {
        if (this.items[campo_def]['input_hidden'].value == valor || valor == '' || valor <= 0)
            return
        if (valor > 0) {
            var erRes = nvFW.error_ajax_request("/fw/files/file_properties.aspx", { asynchronous: false, parameters: { modo: "get_properties", f_id: valor } })
            if (erRes.numError == 0) {
                this.items[campo_def]['input_text'].value = erRes.params['ref_files_path']
                this.items[campo_def]['input_hidden'].value = erRes.params['f_id']
            }
        }
        else {
            this.items[campo_def]['input_text'].value = ''
            this.items[campo_def]['input_hidden'].value = ''
        }
        this.onchange(null, campo_def)
        return
    }
    if (this.items[campo_def]['nro_campo_tipo'] == 3) {
        id = this.items[campo_def]["campo_codigo"]
        campo = this.items[campo_def]["campo_desc"]

        var filtroXML = this.items[campo_def]["filtroXML"]

        var filtroWhere = ''

        if (this.items[campo_def].StringValueIncludeQuote)
            filtroWhere = "<" + id + " type='igual'>'" + valor + "'</" + id + ">"
        else
            filtroWhere = "<" + id + " type='igual'>" + valor + "</" + id + ">"

        //var filtroWhere = "<" + id + " type='igual'>'" + valor + "'</" + id + ">"

        var rs2 = new tRS();
        rs2.open(filtroXML, undefined, filtroWhere)
        if (!rs2.eof()) {
            var desc = rs2.getdata("campo") != undefined ? rs2.getdata("campo") : rs2.getdata("CAMPO");

            if (this.items[campo_def].StringValueIncludeQuote)
                $(campo_def).value = "'" + valor + "'"
            else
                $(campo_def).value = valor

            $(campo_def + '_desc').value = desc + (this.items[campo_def].mostrar_codigo ? ' (' + valor + ')' : '');
            this.items[campo_def].rs = rs2;
        }
        else {
            $(campo_def).value = ''
            $(campo_def + '_desc').value = ''
        }
        this.onchange(null, campo_def)
        return
    }


    if (this.onclick(null, campo_def, false)) {
        //campos_defs.items[campo_def]["input_hidden"].value = valor
        var objCb = $('cb' + campo_def)
        //******************************************************************
        //Si se carga el combo y hay un elemento seleccionado, lo busca y lo selecciona.
        objCb.selectedIndex = -1
        var selected = false
        if (valor != '') {
            //var re = new RegExp(" ", "ig")
            //var values = valor.replace(re, "").split(",")

            /*
            *  NOTA: 
            *    se quitó la expresión regular para los espacios en blanco,
            *    ya que si el ID del campo_def es una cadena con espacios en
            *    blanco, ésta de ser válida y no se setea el campo_def.
            *
            *    Por otro lado, se asume que si vienen 2 o más ID de campos_defs,
            *    éstos vienen separados por ',' y sin espacios entre valores. En 
            *    caso de ocurrir un error asociado a ésto, indicar que los valores
            *    separados por coma no deben llevar espacios entre sí.
            */
            var values = valor.split(",");

            for (i = 0; i < objCb.options.length; i++)
                for (var j = 0; j < values.size(); j++)
                    if (objCb.options[i].value == values[j]) {
                        objCb.options[i].selected = true
                        selected = true
                        break
                    }
                    else
                        objCb.options[i].selected = false
        }
        if (this.items[campo_def].nro_campo_tipo != 4 || selected)
            campos_defs.cbmultiok_onclick(null, campo_def)
        else //En caso de ser tipo 4 y no coincidir con alguna opcion del combo, setear el input_text
        {
            //Ocultar   
            this.focus(campo_def)
            this.click_out(campo_def)

            var id = $(campo_def)
            var txt = $(campo_def + '_desc')

            id.value = valor
            txt.value = valor

            this.onchange(null, campo_def)
            txt.blur()
            return
        }
    }
}

function campo_def_set_first(campo_def, async) {
    if (async == undefined) async = false
    if (this.items[campo_def]['nro_campo_tipo'] >= 200 && this.items[campo_def]['nro_campo_tipo'] < 300) {
        alert('No se puede actualizar un campo de este tipo')
        return
    }
    if (this.items[campo_def]['nro_campo_tipo'] >= 100) {
        alert('No se puede actualizar un campo de este tipo')
        return
    }

    if (this.items[campo_def]['nro_campo_tipo'] == 90) {
        alert('No se puede actualizar un campo de este tipo')
        return
    }
    if (this.items[campo_def]['nro_campo_tipo'] == 3) {
        id = this.items[campo_def]["campo_codigo"]
        campo = this.items[campo_def]["campo_desc"]

        var filtroXML = this.items[campo_def]["filtroXML"]

        var filtroWhere = "<" + id + " type='igual'>'" + valor + "'</" + id + ">"

        var rs2 = new tRS();
        rs2.open(filtroXML, undefined, filtroWhere)
        if (!rs2.eof()) {
            var desc = rs2.getdata("campo")
            $(campo_def).value = valor
            $(campo_def + '_desc').value = desc + ' (' + valor + ')'
        }
        else {
            $(campo_def).value = ''
            $(campo_def + '_desc').value = ''
        }
        this.onchange(null, campo_def)
        return
    }
    var onchargefinish_old = this.items[campo_def].onchargefinish
    var handler = function (campo_def) {
        campos_defs.items[campo_def].onchargefinish = onchargefinish_old
        //campos_defs.items[campo_def]["input_hidden"].value = valor
        var objCb = $('cb' + campo_def)
        //******************************************************************
        //Si se carga el combo y hay un elemento seleccionado, lo busca y lo selecciona.
        objCb.selectedIndex = -1
        var indice0 = campos_defs.items[campo_def].sin_seleccion ? 1 : 0
        for (i = 0; i < objCb.options.length; i++)
            //if (i == 1)
            if (i == indice0)
                objCb.options[i].selected = true
            else
                objCb.options[i].selected = false
        campos_defs.cbmultiok_onclick(null, campo_def)
        if (onchargefinish_old != null)
            onchargefinish_old(campo_def)
    }


    var objCb = $('cb' + campo_def)
    if (objCb != null && objCb.options.length > 1) {
        handler(campo_def)
        return
    }
    if (async) {
        this.items[campo_def].onchargefinish = handler
        this.onclick(null, campo_def, false)
    }
    else
        if (this.onclick(null, campo_def, false))
            handler(campo_def)
}

function campo_def_clear(strcampos_def) {
    var campo_def
    if (!!strcampos_def) {
        var items = {}
        var selItems = strcampos_def.split(',')
        for (var h = 0; h < selItems.size(); h++) {
            campo_def = replace(selItems[h], ' ', '')
            items[campo_def] = this.items[campo_def]
        }
    }
    else
        var items = this.items
    var i
    for (campo_def in items) {
        if (items[campo_def]["input_hidden"].disabled) continue
        var oldValue = items[campo_def]["input_hidden"].value
        this.items[campo_def]['input_hidden'].value = ""
        if (typeof this.items[campo_def]['objMask'] != 'undefined') //Si tiene mascara definida
            this.items[campo_def]['objMask'].unmaskedValue = ""
        try {
            items[campo_def]["input_text"].value = ""
        }
        catch (e) { }
        var objCb = $('cb' + campo_def)

        if (objCb != null) {
            objCb.selectedIndex = -1
            for (var i = 0; i < objCb.options.length; i++)
                Element.removeClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")
        }

        if (items[campo_def]['nro_campo_tipo'] >= 200 && items[campo_def]['nro_campo_tipo'] < 300)
            items[campo_def]['upload'].cambiar()

        if (oldValue != "")
            this.onchange(null, campo_def)
        //if (items[campo_def]["onchange"] != null)
        //items[campo_def]["onchange"](null, campo_def)
    }
}

function campo_def_clear_list(campo_def) {
    //Limpiar el datos del campo_def
    this.clear(campo_def)
    //Limpiar el combo de selección
    if (!!this.items[campo_def]['input_select'])
        this.items[campo_def]['input_select'].options.length = 0
    //Eliminar el rs asociado
    this.items[campo_def].rs = undefined

}

function get_filtroWhere(campos_defs) {
    //campos_defs permite seleccionar que campos se incluyen en el filtro
    //los campos se pasan en el string separados por comas
    if (!campos_defs)
        campos_defs = ''

    campos_defs = campos_defs.toLowerCase()
    var i
    var strWhere = ''
    var campo_def
    var campo_value = ''
    var campo_disabled = ''
    var filtroWhere = ''
    for (campo_def in this.items) {
        campo_value = this.value(campo_def)
        campo_disabled = this.items[campo_def]["input_hidden"].disabled

        if (this.items[campo_def]['filtroWhere'] != "" && campo_value != "" && !campo_disabled) //Si tiene definición, tomó valor y está habilitado
        {
            if (campos_defs == '' || campos_defs.toLowerCase().indexOf(campo_def) != -1) //Si tiene filtro de campos y está dentro del mismo
            {
                var strReg = "%rs!([^%]*)%"  //ejemplo: %rs!cod_servidor%
                var reg = new RegExp(strReg, "ig")
                var c1 = 0
                var f2 = ""
                var inicio = 1
                if (this.items[campo_def]['sin_seleccion']) inicio = 1; else inicio = 0;

                filtroWhere = this.items[campo_def]['filtroWhere']

                if (filtroWhere.search(reg) == -1)  //Si no contiene la expresion regular
                {
                    filtroWhere = replace(filtroWhere, '%campo_def%', campo_def)
                    filtroWhere = replace(filtroWhere, '%campo_value%', campo_value)
                    f2 = filtroWhere
                }
                else //Si contiene expresion regular
                {
                    for (i = inicio; i < this.items[campo_def].input_select.options.length; i++) {
                        if (this.items[campo_def].input_select.options[i].selected) {
                            filtroWhere = this.items[campo_def]['filtroWhere']
                            filtroWhere = replace(filtroWhere, '%campo_def%', campo_def)
                            filtroWhere = replace(filtroWhere, '%campo_value%', campo_value)

                            do {
                                m = reg.exec(filtroWhere)
                                if (m) {
                                    var campo = m[1]
                                    filtroWhere = replace(filtroWhere, m[0], this.items[campo_def].rs.data[i - inicio][campo])
                                }
                            }
                            while (m)

                            c1++

                            f2 += "<AND>" + filtroWhere + "</AND>"

                        }
                    }
                }

                if (c1 > 1) //Tiene mas de una seleccion
                    f2 = "<OR campodef_src='" + campo_def + "'>" + f2 + "</OR>"
                else {
                    var objXML = new tXML();
                    if (objXML.loadXML(f2)) //Si falla la carga, el filtrowhere no tiene nodo raiz
                    {
                        var NOD = objXML.selectNodes('/')[0].childNodes[0] //Si tiene un nodo raiz, añadir campodef_src
                        NOD.setAttribute('campodef_src', campo_def)
                        f2 = XMLtoString(NOD)
                    }
                    else f2 = "<AND campodef_src='" + campo_def + "'>" + f2 + "</AND>" //Si no tiene un nodo raiz, agregar nodo "<AND>"
                }
                strWhere += f2
            }
        }
    }
    return strWhere
}


function campo_def_onkeypress_autocomplete(ev, campo_def, mostrar) {

    if (ev) ev.preventDefault()
    //Si es dependiente y no hay seleccion no permite escritura
    var depende_de = campos_defs.items[campo_def]['depende_de']
    if (depende_de != null && depende_de != "") {
        if ($(depende_de).value == "")
            return false
    }

    //Si es enter
    if (ev.keyCode == 13) {
        return
    }

    //Teclas no imprimibles
    if (ev.type == 'keyup' && (ev.keyCode != 8 && ev.keyCode != 38 && ev.keyCode != 40 && ev.keyCode != 229))
        return

    var imprimible = ev.keyCode == 229 || ev.type == 'keypress' ? true : false
    var result = get_regexp_autocomplete(ev, campo_def, mostrar, imprimible) //Genera la expresion regular para la busqueda
    var reg = result.reg
    mostrar = result.mostrar

    this.onclick(ev, campo_def, mostrar, reg)
}


function get_regexp_autocomplete(ev, campo_def, mostrar, imprimible) {
    //Armado de expresion regular en caso de ser autocomplete
    var valor = ''
    var reg = new RegExp('', "i")

    var positioncursor = ev.target.selectionStart
    if (imprimible) //Escribe en el campo_def en la posicion del cursor si es una tecla imprimible
    {
        var asc = !ev.keyCode ? ev.wich : ev.keyCode
        //var el = Event.element(ev)
        var key = ''
        //if (asc == 229) 
        //  key = el.value.substring(ev.target.selectionEnd, el.value.length - 1) 
        //else
        //  key = String.fromCharCode(asc)
        if (asc != 229)
            key = String.fromCharCode(asc)

        campos_defs.items[campo_def]["input_text"].value = campos_defs.items[campo_def]["input_text"].value.substring(0, positioncursor) + key + campos_defs.items[campo_def]["input_text"].value.substring(ev.target.selectionEnd, campos_defs.items[campo_def]["input_text"].value.length)
        ev.target.selectionStart = positioncursor + 1
        ev.target.selectionEnd = positioncursor + 1
    }
    //Si cant letras del input >= a minlength, mostrar el div y buscar el valor
    if (campos_defs.items[campo_def]['autocomplete_minlength'] <= campos_defs.items[campo_def]["input_text"].value.length) {
        valor = campos_defs.items[campo_def]["input_text"].value
        if (campos_defs.get_value(campo_def) != "") {
            //Si es seleccion con flechas no borrar el valor del campo
            if (ev.type != 'keyup' || (ev.type == 'keyup' && ev.keyCode != 40 && ev.keyCode != 38)) {
                campos_defs.items[campo_def]["input_hidden"].value = ""
                if (typeof $('cb' + campo_def) != 'undefined') $('cb' + campo_def).selectedIndex = -1
            }

            campos_defs.items[campo_def]["input_text"].value = valor
            campos_defs.focus(campo_def)
        }

        valor = valor.replace(/\\/g, '\\\\')
        valor = valor.replace(/\(/g, '\\(')
        valor = valor.replace(/\)/g, '\\)')
        valor = valor.replace(/\./g, '\\.')
        valor = valor.replace(/\*/g, '\\*')
        valor = valor.replace(/\$/g, '\\$')
        valor = valor.replace(/\+/g, '\\+')
        //Busqueda solo al inicio
        if (campos_defs.items[campo_def]["autocomplete_match"] == 'solo_inicio')
            valor = "\^" + valor
        reg = new RegExp(valor, "i") //Expresion regular de valor a buscar
    }
    else //En caso de ser menor a minlength no mostrar el combo de opciones
        if (ev.type != 'keyup' || (ev.type == 'keyup' && ev.keyCode != 40 && ev.keyCode != 38)) {
            mostrar = false
            try {
                campos_defs.divCampo_def_vidrio.hide()
                campos_defs.divCampo_def.hide()
            }
            catch (e) { }
        }
    return { reg: reg, mostrar: mostrar }
}


function campo_def_onclick(ev, campo_def, mostrar, reg) {

    if (ev) ev.preventDefault()
    //Mostrar tambien define si la consulta es asincrona
    //Si se muestra es asincrona
    this.focus(campo_def)
    if (ev != null && ev.ctrlKey == 1 && ev.shiftKey == 1) {
        this.clear(campo_def)
        return
    }

    if (mostrar == undefined)
        mostrar = true

    //Si el campo está desabilitado salir
    if (campos_defs.items[campo_def]["input_hidden"].disabled)
        return false

    var depende_de = campos_defs.items[campo_def]['depende_de']
    var depende_de_campo = campos_defs.items[campo_def]['depende_de_campo']

    var recargar_rs = false
    //Si tiene dependencia y no esta seleccionada salir
    if (depende_de != null && depende_de != "") {
        if ($(depende_de).value == "")
            return false
        //Si el valor en el campo dependiente es distinto al guardado en el hijo, setear bandera para recargar el combo
        if (this.items[campo_def]["depende_de_seleccion"] != $(depende_de).value) {
            recargar_rs = true
            this.items[campo_def]["depende_de_seleccion"] = $(depende_de).value
        }
    }


    //COMBO Busqueda
    if (this.items[campo_def]['nro_campo_tipo'] == 3) {
        if (!this.items[campo_def]["window"]) {
            if (!this.items[campo_def]["nvFW"]) {
                this.items[campo_def]["nvFW"] = window.top.nvFW
                if (!this.items[campo_def]["nvFW"])
                    this.items[campo_def]["nvFW"] = nvFW
            }

            this.items[campo_def]["window"] = this.items[campo_def]["nvFW"].createWindow({
                title: "Seleccionar",
                parameters: { campo_def: campos_defs.items[campo_def] },
                width: 400, height: 300,
                minimizable: false,
                minHeight: 270,
                maxHeight: 300,
                minWidth: 300,
                url: "/FW/campo_def/campo_def_tipo3.aspx?campo_def=" + campo_def,
                onClose: function (win) {
                    if (campos_defs.items[campo_def]["input_hidden"].value != win.campo_def_value && win.cancelado == false) {
                        campos_defs.items[campo_def]["input_hidden"].value = win.campo_def_value
                        campos_defs.items[campo_def]["input_text"].value = win.campo_desc
                        campos_defs.items[campo_def]["input_select"] = win.input_select
                        campos_defs.items[campo_def]["rs"] = win.rs
                        campos_defs.focus(campo_def)
                        campos_defs.onchange(ev, campo_def)
                    }
                }
            })
        }

        this.items[campo_def]["window"].showCenter(true);
        return true
    }

    if (this.items[campo_def]['nro_campo_tipo'] == 90) {
        if (!this.items[campo_def]["window"]) {
            var file_dialog
            if (this.items[campo_def].file_dialog != undefined)
                file_dialog = this.items[campo_def].file_dialog
            else {
                var file_dialog = {}
                file_dialog.view = 'detalle'
                file_dialog.seleccionar = true
            }
            file_dialog.seleccionar = true
            if (file_dialog.links == undefined) {
                var links = {}
                links[0] = {}
                links[0].icon = 'disco32.png'
                links[0].f_id = 0
                links[0].titulo = "Todas las unidades"
                links[0].inicio = true
                file_dialog.links = links
            }

            if (file_dialog.filters == undefined) {
                var filters = {}
                filters[0] = {}
                filters[0].titulo = "Todos los archivos"
                filters[0].filter = '*.*'
                filters[0].max_size = 1024 * 1024
                filters[0].inicio = true
                file_dialog.filters = filters
            }
            file_dialog.campo_def = campo_def
            this.items[campo_def]["window"] = window.top.nvFW.file_dialog_show(file_dialog, {
                file_dialog: file_dialog
                , onClose: function (win, a, c) {
                    var file = win.content.contentWindow.file_seleccionado
                    if (file == null) {
                        file = {}
                        file.f_id = ''
                    }
                    var campo_def = win.options.file_dialog.campo_def
                    if (campos_defs.items[campo_def]["input_hidden"].value != file.f_id && file.f_id != '') {
                        campos_defs.items[campo_def]["input_hidden"].value = file.f_id
                        campos_defs.items[campo_def]["input_text"].value = file.ref_files_path
                        campos_defs.onchange(ev, campo_def)
                    }
                }

            })

            //this.items[campo_def]["window"] = win = window.top.nvFW.createWindow({title: "Seleccionar archivo"
            //                   ,width:800
            //                   ,height:400 
            //                   ,file_dialog: file_dialog
            //                   ,onClose: function (win)
            //                                {
            //                                var file = win.content.contentWindow.file_seleccionado
            //                                if (file == null)
            //                                  {
            //                                  file = {}
            //                                  file.f_id = ''
            //                                  }
            //                                var campo_def = win.options.file_dialog.campo_def
            //                                if (campos_defs.items[campo_def]["input_hidden"].value != file.f_id && file.f_id != '')
            //                                  {
            //                                  campos_defs.items[campo_def]["input_hidden"].value = file.f_id
            //                                  campos_defs.items[campo_def]["input_text"].value = file.ref_files_path
            //                                  campos_defs.onchange(ev, campo_def)
            //                                  }  
            //                                }      

            //                   })
            //win.setURL("FW/files/file_dialog.aspx")                   
        }
        else {
            this.items[campo_def]["window"].showCenter(true)
        }
        //win = this.items[campo_def]["window"]  
        //this.items[campo_def]["window"].showCenter(true);   
        return true
    }


    //Buscar el divContenedor  
    var objDIV = $('div' + campo_def)
    var posicionar = function () {
        try {
            var objDIV = $('div' + campo_def)
            var obj = $('campo_def_tb' + campo_def)
            //Buscar la coordenadas de la tabla padre
            var offsetTop = 0
            //En caso de estar escribiendo en el campo, desplazar la posicion del combo
            if (!!ev && ev.type != 'click' && ev.type != 'dblclick' && ev.type != 'touchstart')
                offsetTop = obj.getHeight()
            if (tmp_campo_def.despliega == 'arriba')
                offsetTop = (objDIV.getHeight() - obj.getHeight()) * - 1 - offsetTop
            objDIV.clonePosition(obj, { setHeight: false, offsetTop: offsetTop })
        }
        catch (ex3) { }
    }
    if (!objDIV) {
        //COMBO SIMPLE
        if (campos_defs.items[campo_def]['nro_campo_tipo'] == 1 || campos_defs.items[campo_def]['nro_campo_tipo'] == 4)
            var strHTML = '<div id="div' + campo_def + '" class="campo_def_div_contenedor" style="position: absolute; z-index: 500; float: left; display: none; overflow-y: auto" ><table id="cbTB_' + campo_def + '" class=" tb1 highlightOdd highlightTROver" style="width:100%" ><tr><td>Cargando...</td></tr></table><select id="cb' + campo_def + '" size="2" style="display: none; width: 100%" onclick="return campos_defs.cb_onclick(event, \'' + campo_def + '\')"  onkeypress="return campos_defs.cb_onkeypress(event, \'' + campo_def + '\')" ></select></div>'


        //COMBO MULTIPLE  
        if (campos_defs.items[campo_def]['nro_campo_tipo'] == 2)
            var strHTML = '<div id="div' + campo_def + '" class="campo_def_div_contenedor" style="position: absolute; z-index: 500; float: left; display: none; overflow-y: auto" ><div style=" overflow-y: auto; height: 130px"><table id="cbTB_' + campo_def + '" class=" tb1 highlightOdd highlightTROver" style="width:100%"><tr><td>Cargando...</td></tr></table></div><select id="cb' + campo_def + '" size="2" style="display: none; width: 100%" onblur="return campos_defs.cbmultiok_onclick(event, \'' + campo_def + '\')" ondblclick="return campos_defs.cbmultiok_onclick(event, \'' + campo_def + '\')" onkeypress="return campos_defs.cb_onkeypress(event, \'' + campo_def + '\')" multiple></select><input type="button" id="btnok' + campo_def + '"style="width: 100%; cursor: pointer; margin: 0; padding: 2px 0;" value="Ok" onclick="return campos_defs.cbmultiok_onclick(event, \'' + campo_def + '\')" /></div>'

        $$('BODY')[0].insert({ top: strHTML })
        objDIV = $('div' + campo_def)
        this.items[campo_def].divSelect = objDIV

        window.addEventListener("resize", posicionar)

    }

    //Cargar el combo
    var filtroWhere = ""
    var objCb = this.items[campo_def]['input_select'] = $('cb' + campo_def)
    var filtroXML = campos_defs.items[campo_def]['filtroXML']
    var vistaGuardada = campos_defs.items[campo_def]['vistaGuardada']
    var StringValueIncludeQuote = campos_defs.items[campo_def]['StringValueIncludeQuote']
    var StringValueIncludeQuote_depende = false
    var mostrar_codigo = campos_defs.items[campo_def]['mostrar_codigo']
    var sin_seleccion = campos_defs.items[campo_def]['sin_seleccion']
    //Si tiene dependencia agregar el filtro
    if (depende_de != null && depende_de != "") {
        if (recargar_rs) {
            this.items[campo_def]['rs'] = undefined //Limpiar el rs si ya estaba generado
            if (depende_de_campo == null || depende_de_campo == '')
                depende_de_campo = depende_de
        }

        //filtroWhere = '<' + depende_de_campo + ' type="in">' + $(depende_de).value + '</' + depende_de_campo + '>'
        //var tipo_dato = "int"
        var depende_de_valor = $(depende_de).value;
        try {
            if (typeof campos_defs.items[depende_de] != 'undefined') {
                //StringValueIncludeQuote_depende = campos_defs.items[depende_de]['StringValueIncludeQuote']
                StringValueIncludeQuote_depende = campos_defs.items[depende_de].rs.getfield("id").datatype == 'string' && !campos_defs.items[depende_de].StringValueIncludeQuote ? true : false
                if (campos_defs.items[depende_de].nro_campo_tipo == 2 && StringValueIncludeQuote_depende)
                    depende_de_valor = depende_de_valor.replace(/, /g, '\',\'')
            }
            //else {
            //    tipo_dato = typeof $(depende_de).value;
            //    //StringValueIncludeQuote_depende = tipo_dato == 'string' ? true : false
            //}
        }
        catch (ex2) { }
        if (StringValueIncludeQuote_depende)
            filtroWhere = '<' + depende_de_campo + ' type="in">\'' + depende_de_valor + '\'</' + depende_de_campo + '>';
        else
            filtroWhere = '<' + depende_de_campo + ' type="in">' + depende_de_valor + '</' + depende_de_campo + '>';
    }


    //Si depende de otro campo y cambia la seleccion hay que recargar el combo, lo mismo si está vacio
    if (recargar_rs || objCb.options.length == 0) {
        //Mostrar define si la carga es asincrona
        format = this.items[campo_def]['json'] ? 'getterror' : 'getxml_json'
        cacheControl = this.items[campo_def]['cacheControl']
        var nunMostrar_codigo = mostrar_codigo ? 1 : 0
        var nunSin_seleccion = sin_seleccion ? 1 : 0

        this.items[campo_def].rs = cargar_cbCodigo(objCb, '', 'id', 'campo', filtroWhere, '', nunSin_seleccion, nunMostrar_codigo, filtroXML, mostrar, function () {

            var tbCombo = $('cbTB_' + campo_def)
            tbCombo.innerHTML = ""
            for (var i = 0; i < objCb.options.length; i++) {
                var allowSelection = objCb.options[i].allowSelection != false
                var strClass = allowSelection ? "campo_def_cb_item" : "campo_def_cb_item_disable"
                var text = objCb.options[i].text == "" ? "&nbsp;" : objCb.options[i].text
                if (campos_defs.items[campo_def]['nro_campo_tipo'] == 1 || campos_defs.items[campo_def]['nro_campo_tipo'] == 4) {
                    var str_onClick = allowSelection ? " onclick='return campo_def_cb_onclick(event, \"" + campo_def + "\", " + i + ")'" : ""
                    tbCombo.insertAdjacentHTML("beforeend", "<tr id='cbTB_TR_" + campo_def + "_" + i + "'><td id='cbTB_TD_" + campo_def + "_" + i + "' class='" + strClass + "'" + str_onClick + " nowrap>" + text + "</td></tr>")
                }
                if (campos_defs.items[campo_def]['nro_campo_tipo'] == 2) {
                    var str_onClick = allowSelection ? " onclick='return campo_def_cb_onclick2(event, \"" + campo_def + "\", " + i + ")' " : ""
                    tbCombo.insertAdjacentHTML("beforeend", "<tr><td  id='cbTB_TD_" + campo_def + "_" + i + "' class='" + strClass + "' " + str_onClick + "  ondblclick='return campo_def_cbmultiok_onclick(event,  \"" + campo_def + "\")' nowrap>" + text + "</td></tr>")
                }
            }

            if (campos_defs.items[campo_def].onchargefinish != null)
                campos_defs.items[campo_def].onchargefinish(campo_def)
        }, null, format, cacheControl, vistaGuardada, StringValueIncludeQuote, this.items[campo_def].rs)
    }

    //Refrescar el combo (aplica a autocomplete)
    var objCB_visibles = [] //objCb a recorrer en seleccion
    if (ev != null && this.items[campo_def]['autocomplete'] && this.items[campo_def].rs.recordcount != 0) {
        //En caso de seleccion por flechas y combo visible, no se refresca
        if ((ev.type == 'keyup' && (ev.keyCode == 38 || ev.keyCode == 40)) && $("div" + campo_def).style.display == "") {
            for (var i = 0; i < objCb.options.length; i++)
                if ($("cbTB_TR_" + campo_def + "_" + i).style.display == "")
                    objCB_visibles.push(i) //Guardar las opciones visibles del combo
        }
        else {
            var sin_seleccion = campos_defs.items[campo_def]['sin_seleccion']
            for (var i = 0; i < objCb.options.length; i++) {//Si coincide se muestra (si ya hay uno seleccionado se muestran todas las opciones del combo)
                reg = typeof reg == 'undefined' ? new RegExp('', "i") : reg
                if (reg.test(objCb.options[i].text) || (objCb.options[i].text == "" && sin_seleccion) || this.get_value(campo_def) != '') {
                    $("cbTB_TR_" + campo_def + "_" + i).show()
                    objCB_visibles.push(i) //Guardar las opciones visibles del combo
                }
                else
                    $("cbTB_TR_" + campo_def + "_" + i).hide()
            }
        }
    }


    if (mostrar) {
        if (this.divCampo_def_vidrio == null) {
            strHTML = "<div id='divCampo_def_vidrio' onclick='campos_defs.click_out(\"" + campo_def + "\")' style='position: absolute; float: left; z-index: 400; width: 100%; heigth: 100%; background-color: blue;'></div>"
            $$('BODY')[0].insert({ top: strHTML })
            this.divCampo_def_vidrio = $('divCampo_def_vidrio')
            var vidrio = this.divCampo_def_vidrio
            window.addEventListener("resize", function (e) { vidrio.clonePosition($$('BODY')[0]) })
            //$(window).observe("resize", )
        }

        this.divCampo_def_vidrio.setOpacity(0.01)
        this.divCampo_def_vidrio.clonePosition($$('BODY')[0])
        this.divCampo_def_vidrio.show()
        this.divCampo_def_vidrio.idcampo_def = campo_def

        //AJUSTAR TAMAÑO y MOSTRAR
        //Obtener tabla padre
        obj = $('campo_def_tb' + campo_def)
        var tmp_campo_def = this.items[campo_def]

        posicionar()

        //Desmarcar todo
        for (var i = 0; i < objCb.options.length; i++)
            Element.removeClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")

        if (ev == null || ev.type != 'keyup' || (ev.keyCode != 38 && ev.keyCode != 40)) //en caso de ser flecchas de direccion, mover seleccion
        {

            //Marcar los seleccionados
            if (campos_defs.items[campo_def]["input_hidden"].value != "") {
                var values = campos_defs.items[campo_def]["input_hidden"].value.split(", ")
                for (index in values)
                    for (var i = 0; i < objCb.options.length; i++)
                        if (objCb.options[i].value == values[index])
                            Element.addClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")
            }
        }
        else //Desplazamiento por flechas
        {
            //Si el combo de seleccion es visible desplazar a siguiente seleccion, si no, muestrar el combo en seleccion actual
            var desplazar_seleccion = 0
            if ($("div" + campo_def).style.display == "")
                desplazar_seleccion = 1
            if (ev.keyCode == 38) //Desplazamiento hacia arriba
                desplazar_seleccion = -1 * desplazar_seleccion
            var bandera = false
            for (var j = 0; j < objCB_visibles.length; j++) //Recorrer las opciones visibles
            {
                var i = objCB_visibles[j]

                if (objCb.options[i].selected) {
                    if (typeof objCb.options[objCB_visibles[j + desplazar_seleccion]] != 'undefined') {
                        //Selecciona y marca la opcion
                        var index = objCB_visibles[j + desplazar_seleccion]
                        Element.addClassName("cbTB_TD_" + campo_def + "_" + index, "campo_def_cbmulti_select")

                        this.items[campo_def]["input_hidden"].value = objCb.options[index].value
                        this.items[campo_def]["input_text"].value = objCb.options[index].text
                        objCb.selectedIndex = index

                    }
                    else
                        Element.addClassName("cbTB_TD_" + campo_def + "_" + objCB_visibles[j], "campo_def_cbmulti_select") //marca fija si es extremo
                    bandera = true
                    break
                }
            }
            if (!bandera) //En caso de no encontrar coincidencia exacta seleccionar la primer opcion (no vacia)
            {
                var i = objCB_visibles[0]
                if (sin_seleccion == true)
                    i = objCB_visibles[1]
                if (typeof i != 'undefined') {
                    Element.addClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")

                    this.items[campo_def]["input_hidden"].value = objCb.options[i].value
                    this.items[campo_def]["input_text"].value = objCb.options[i].text
                    objCb.selectedIndex = i

                }
            }
        }



        //Element.addClassName("cbTB_TD_" + campo_def + "_" + "0" , "campo_def_cbmulti_select")
        //el.addClassName("campo_def_cbmulti_select")

        objDIV.show()
        //Ajustar los scrolls horizontales
        objDIV.scrollLeft = 0
        try { objDIV.childNodes[0].scrollLeft = 0 }
        catch (ex4) { }
        this.divCampo_def = objDIV

        objCb.focus()
    }
    return true
}

function campo_def_click_out(campo_def) {
    try {
        this.divCampo_def_vidrio.hide()
        this.divCampo_def.hide()
        if (this.items[this.divCampo_def_vidrio.idcampo_def]['autocomplete'] == true && (typeof campo_def == 'undefined' || (typeof campo_def != 'undefined' && campo_def == this.divCampo_def_vidrio.idcampo_def)))
            this.clickout_autocomplete(this.divCampo_def_vidrio.idcampo_def)
    }
    catch (e) { }
}

function campo_def_cb_onclick2(e, campo_def, index) {
    var cb = $('cb' + campo_def)
    var el = Event.element(e)
    if (!e.ctrlKey && !Prototype.BrowserFeatures.touch_device) {
        for (var i = 0; i < cb.options.length; i++) {
            cb.options[i].selected = false
            Element.removeClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")
        }
        cb.options[index].selected = true
    }
    else
        cb.options[index].selected = !cb.options[index].selected

    if (cb.options[index].selected)
        el.addClassName("campo_def_cbmulti_select")
    else
        el.removeClassName("campo_def_cbmulti_select")
}

function campo_def_cb_onclick(e, campo_def, index) {
    var el = Event.element(e)
    campos_defs.focus(campo_def)
    if ($('div' + campo_def) == null) //control 
        alert('Error campo_def.')

    //Ocultar   
    campos_defs.click_out(campo_def)
    //$('div' + campo_def).hide() // style.display = 'none'

    var cb = $('cb' + campo_def)

    cb.selectedIndex = index

    for (var i = 0; i < cb.options.length; i++)
        Element.removeClassName("cbTB_TD_" + campo_def + "_" + i, "campo_def_cbmulti_select")
    el.addClassName("campo_def_cbmulti_select")

    var id = $(campo_def)
    var txt = $(campo_def + '_desc')
    id.value = ''
    txt.value = ''
    txt.blur()
    if (cb.selectedIndex > -1) {
        id.value = cb.options[cb.selectedIndex].value
        txt.value = cb.options[cb.selectedIndex].text
        //Si tiene definido onchange
        campos_defs.onchange(e, campo_def)
        //if (typeof(campos_defs.items[campo_def]['onchange']) == 'function')
        // campos_defs.items[campo_def]['onchange'](e, campo_def) 
    }
    //
}


function campo_def_cb_onkeypress(e, campo_def) {
    var evt = !window.event ? e : window.event
    var key = !evt.keyCode ? evt.which : evt.keyCode

    if (key == 13)
        campo_def_cb_onclick(e, campo_def)
    nvFW.selection_clear()
}


function campo_def_cbmultiok_onclick(e, campo_def) {
    //Ocultar   
    campos_defs.focus(campo_def)
    campos_defs.click_out(campo_def)
    //$('div' + campo_def).hide()  // style.display = 'none'
    var cb = $('cb' + campo_def)
    var id = $(campo_def)
    var txt = $(campo_def + '_desc')

    id.value = ''
    txt.value = ''
    var ids = ''
    var txts = ''
    var indice0 = campos_defs.items[campo_def].sin_seleccion ? 1 : 0
    for (var i = indice0; i < cb.options.length; i++)
        if (cb.options[i].selected) {
            ids += cb.options[i].value + ', '
            txts += cb.options[i].text + '; '
        }
    if (ids != '') {
        ids = ids.substr(0, ids.length - 2)
        txts = txts.substr(0, txts.length - 2)
    }

    id.value = ids
    txt.value = txts
    campos_defs.onchange(e, campo_def)
    txt.blur()
    //if (typeof(campos_defs.items[campo_def]['onchange']) == 'function')
    //campos_defs.items[campo_def]['onchange'](e, campo_def) 
}


function cargar_cbCodigo(cb, vista, id, campo, filtroWhere, orden, sin_seleccion, mostrar_codigo, filtroXML, async, fonComplete, fonError, format, cacheControl, vistaGuardada, StringValueIncludeQuote, current_rs) {
    if (StringValueIncludeQuote == undefined)
        StringValueIncludeQuote = false
    if (!cacheControl)
        cacheControl = 'none'
    var rs = new tRS();
    rs.format = format
    rs.format_tError = format == "getterror" ? 'json' : rs.format_tError
    rs.cacheControl = cacheControl
    if (async == undefined)
        async = false
    rs.async = async
    var onComplete = function (rs) {
        var idValue = ''
        var campoValue = ''
        if (rs.recordcount > 0) rs.position = 0
        var IDType = rs.getfield("id").datatype
        cb.options.length = 0
        if (!mostrar_codigo)
            mostrar_codigo = 0

        if (!sin_seleccion)
            sin_seleccion = 0

        if (sin_seleccion == 1) {
            cb.options.length++
            cb.options[cb.options.length - 1].value = ''
            cb.options[cb.options.length - 1].text = ''
            cb.options[cb.options.length - 1].allowSelection = true
        }
        while (!rs.eof()) {
            cb.options.length++
            cb.options[cb.options.length - 1].allowSelection = rs.getdata("allowSelection") != false
            if (IDType == 'string' && StringValueIncludeQuote) {
                idValue = rs.getdata(id) != undefined ? rs.getdata(id) : rs.getdata(id.toUpperCase())
                cb.options[cb.options.length - 1].value = "'" + idValue + "'"
            }
            else {
                idValue = rs.getdata(id) != undefined ? rs.getdata(id) : rs.getdata(id.toUpperCase())
                cb.options[cb.options.length - 1].value = idValue
                //cb.options[cb.options.length-1].value = rs.getdata(id)
            }
            campoValue = rs.getdata(campo) != undefined ? rs.getdata(campo) : rs.getdata(campo.toUpperCase())
            var desc = mostrar_codigo == 0 ? campoValue : campoValue + '  (' + idValue + ')'
            //var desc =  mostrar_codigo == 0 ? rs.getdata(campo) : rs.getdata(campo) + '  (' + rs.getdata(id) + ')'
            cb.options[cb.options.length - 1].text = desc
            rs.position++
        }
        cb.disabled = false
        if (cb.options.length >= 1)
            cb.selectedIndex = 0
        if (fonComplete != null)
            fonComplete()
    }
    rs.onError = function (rs) {
        cb.options.length = 0
        cb.options.length++
        cb.options[cb.options.length - 1].text = "Error"
        try {
            cb.options[cb.options.length - 1].text = rs.lastError.mensaje + '. ' + rs.lastError.debug_desc

        }
        catch (ex3) { }
        cb.disabled = false
        if (fonError != null)
            fonError()
    }
    rs.onComplete = onComplete
    cb.options.length = 0
    cb.options.length++
    cb.disabled = true

    if (current_rs != undefined) {
        onComplete(current_rs)
        return current_rs
    }

    if (!filtroXML && vista != "") {
        if (!filtroWhere)
            filtroWhere = ''

        if (!orden)
            orden = ''
        if (orden != '')
            orden = '<orden>' + orden + '</orden>'
        rs.open('<criterio><select vista="' + vista + '">' + orden + '<campos>' + id + ', ' + campo + '</campos><filtro>' + filtroWhere + '</filtro></select></criterio>')
    }
    else
        rs.open(filtroXML, "", filtroWhere, vistaGuardada)
    //Devolver el rs con el resultado
    return rs
}


/*****************************************/
//  Objeto global
/*****************************************/
var campos_defs = new tCampos_defs()
campos_defs.campo_def_get_path = "/fw/campo_def/campos_def_get.aspx" //Path por defecto para cargar campo_def
window.mobileAndTabletCheck = function () { //Funcion para detectar si es mobile
    let check = false;
    (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
    return check;
};
campos_defs.mobile = window.mobileAndTabletCheck()
if (campos_defs.mobile) { //Imagenes en caso mobile
    campos_defs.url_img_down = '/FW/image/campo_def/down_mobile.png'
    campos_defs.url_img_clear = '/FW/image/campo_def/cancelar_mobile.png'
    campos_defs.class_img_down = 'img_down_mobile'
} else {
    campos_defs.url_img_down = '/FW/image/campo_def/down.png'
    campos_defs.url_img_clear = '/FW/image/campo_def/cancelar.png'
    campos_defs.class_img_down = 'img_down'
}