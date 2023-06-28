var sit_bcra = 99
//var estructura_genera_codigo = nvFW.pageContents['estructura_genera_codigo'] //Array(11, 12)


function window_onload() {

   

    cambioDeWidth = 1;
    consulta.cargar_operador();

    $("strVendedor").innerText = consulta.vendedor

    //$("user_name").innerHTML = nvFW.operador.login
    //$("user_sucursal").innerHTML = nvFW.operador.sucursal
    //No guarda el scrolling en el historial
    sinonimos_dictamen_cargar();

    history.scrollRestoration = 'manual'
    ismobile = (isMobile()) ? true : false

    //Anulo el cartel default de nova cuando abandono la aplicacion
    nvFW.alertUnload = false
    vListButtons.MostrarListButton()

    if (nvFW.pageContents["nro_credito"] != "") MostrarCredito(nvFW.pageContents['nro_credito'])

    

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

    consulta.limpiar()

    //Esta funcion determina los tamaños de los componentes, menu sup, inf, body, etc
    tamanio = nvtWinDefault()

    //muestra menu dependiendo si debe ser menu movil o no
    //vMenuLeft.MostrarMenu(tamanio.ocultarMenu)

    //para operadores de mendoza o que no tengan estructura            
    //mostrar_boton_generarcodigo(nro_estructura==11)


    //funciones de scrolling para mostrar o ocultar el menu.
    detectSwipe($$("BODY")[0], "mostrar", 50);
    //detectSwipe($("divComponentes"), mostrarMenuIzquierdoSwipe, 50, "izq");
    detectSwipe($("menu_left_vidrio"), "colapsar");
    detectSwipe($("menu_left_mobile"), "colapsar");
    detectSwipe($("menu_right_vidrio"), "colapsar");
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
        debugger
        cargarValoresEstadisticas();
    //}

    // Mostrar el primer paso al cargar la página
    wizzard();
    
    //$('divMenu').style.cssText += 'float: left; position: absolute;';
    window_onresize();
    vendedor_check()

}


let objDictamen = {}
function sinonimos_dictamen_cargar() {
    let rs = new tRS();
    rs.async = true;

    rs.onComplete = function (rs) {
        while (!rs.eof()) {
            objDictamen[rs.getdata('dato1_desde')] = rs.getdata('pizarra_valor');

            rs.movenext();
        }
    }

    rs.onError = function (rs) {

    }

    rs.open(nvFW.pageContents.filtro_piz_dictamen);
}

//############################################
//#########----TRABAJOS Y COBROS----##########
//############################################

//Se utilizan en consulta.js




//se carga en consulta.cobro_seleccionar
var cobro_array = {}
function sel_cobro(aceptar) {

    if (aceptar) {
        var i = $$('input:checked[type="radio"][name="rdcobro"]').pluck('value')[0]
        consulta.nro_tipo_cobro = cobro_array[i]['nro_tipo_cobro']
        consulta.tipo_cobro = cobro_array[i]['tipo_cobro']
        consulta.nro_banco_cobro = ((cobro_array[i]['nro_banco'] == undefined) ? 0 : cobro_array[i]['nro_banco'])
        consulta.banco_cobro = ((cobro_array[i]['abreviacion'] == undefined) ? 0 : cobro_array[i]['abreviacion'])
        consulta.evaluar();
        goToNextStep();
    } else consulta.limpiar();

}


function selcobro(nro_tipo_cobro_sel) {
    var radioGrp = document['all']['rdcobro']
    if (radioGrp.length == undefined)
        $("rdcobro").checked = true
    else {
        for (i = 0; i < radioGrp.length; i++) {
            if (radioGrp[i].value == nro_tipo_cobro_sel)
                radioGrp[i].checked = true
            else
                radioGrp[i].checked = false
        }
    }
}


//############################################
//##########----FUNCIONES UTILES----##########
//############################################


function rserror_handler(msg, bloq_id, element_id) {
    if (!bloq_id)
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    else nvFW.bloqueo_desactivar($(element_id), bloq_id)
    nvFW.alert(msg, { onClose: function () { consulta.limpiar() } })
}


function btnBuscar_trabajo_onkeydown(e) {
    var key = Prototype.Browser.IE ? e.keyCode : e.which
    if ((key == 13) || (key == 9)) {
        consulta.cliente_buscar()
        return false
    }
}


function rddoc_onclick() {
    document.getElementById('nro_docu1').focus()
}


function VerCDA(limpiaronclose = false) {

    var winVerCda = nvFW.createWindow({
        width: 400,
        height: 350,
        title: '',
        zIndex: 101,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true,
        onClose: function () {
            if (limpiaronclose) {
                consulta.limpiar()
            }
        }
    })
    winVerCda.setHTMLContent(consulta.resultado.strHTML_CDA)
    winVerCda.showCenter(true)
}

//############################################
//########----SELECCIONAR VENDEDOR----########
//############################################


//function vendedor_check() {
//    //$('strVendedor').innerText = nvFW.operador.razon_social
//    if (consulta.nro_vendedor == 0)
//        precarga.sel_vendedor()
//}


//function selVendedor_onclick() {

//    if (!nvFW.tienePermiso('permisos_precarga', 1)) {
//        nvFW.alert('No posee permisos para seleccionar el vendedor')
//        return
//    }
//    precarga.show_modal_window({
//        url: 'selVendedor.aspx',
//        title: '<b>Seleccionar Vendedor</b>',
//        onClose: function (win) { selVendedor_return(win_vendedor); }
//    });
//    //win_vendedor.options.userData = { res: '' }
//    //win_vendedor.showCenter(true)
//    // mostrarMenuIzquierdoSwipe()

//    //if (isMobile())
//        //mostrarMenuIzquierdo()

//}


//function selVendedor_return(win_vendedor) {
//    var retorno = win_vendedor.options.userData.res
//    if (retorno) {
//        $('strVendedor').innerText = retorno["vendedor"]
//        //strVendedor = retorno["vendedor"]
//        consulta.nro_vendedor = retorno['nro_vendedor']
//        consulta.nro_estructura = (retorno['nro_estructura'] == null) ? 0 : retorno['nro_estructura']
//        consulta.estructura = ""
//        //mostrar_boton_generarcodigo(estructura_genera_codigo.indexOf(+nro_estructura)>=0)
//        consulta.cod_prov = retorno['cod_prov']
//        consulta.postal_real = retorno['postal_real']
//        //mostrar_boton_generarcodigo(nro_estructura==11 || nro_estructura==0)
//        //mostrar_boton_generarcodigo(nro_estructura==11)
//        consulta.limpiar()


//    }
//}


//############################################
//############-----TUTORIALES-----############
//############################################


function verTutoriales() {
    // window.open('https://youtu.be/k7QU1fab5Mo','_blank')
    
    precarga.show_modal_window({
        url: 'tutoriales_precarga.aspx?codesrvsw=false',
        title: '<b>Tutoriales</b>',
    
    });

}


//############################################
//##############-----SOCIO-----###############
//############################################


function cargar_cs(nro_docu, tipo_docu, sexo, cuit, nro_grupo) {

    nvFW.bloqueo_activar($('divSocioLeft'), 'blq_precarga_cuota', 'Obteniendo información de cuota social...')
    let strHTMLS = "<table class='tb1' cellspacing='1' cellpadding='1' style='vertical-align:top'>"

    let rsCS = new tRS();
    rsCS.async = true

    rsCS.onError = function (rsCS) {
        rserror_handler("Error al consultar los datos. Intente nuevamente.", 'blq_precarga_cuota', 'divSocioLeft')
    }

    rsCS.onComplete = function (rsCS) {

        if (rsCS.recordcount > 0) {
            strHTMLS += "<tr><td class='Tit1' style='width:70%'>Mutual</td><td class='Tit1' style='width:30%;text-align:right'>Cuota</td></tr>"
            while (!rsCS.eof()) {
                strHTMLS += "<tr><td>" + rsCS.getdata('mutual') + "</td><td style='text-align:right'>$ " + parseFloat(rsCS.getdata('importe_cuota')).toFixed(2) + "</td></tr>"
                rsCS.movenext()
            }
        } else strHTMLS += "<tr><td class='Tit1' style='width:100%' colspan=2>Sin información</td></tr>"

        strHTMLS += "</table>"

        $('tbCuotaSocial').insert({ bottom: strHTMLS })
        nvFW.bloqueo_desactivar($('divSocioLeft'), 'blq_precarga_cuota')

    }
    rsCS.open({ filtroXML: nvFW.pageContents["creditos_cs"], params: "<criterio><params nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' cuit='" + cuit + "'   nro_grupo='" + nro_grupo + "' /></criterio>" })
}

function rsdataToArray(xmlText) {
    var txt = document.createElement('textarea');
    txt.innerHTML = xmlText;
    var rsdatatext = txt.value
    txt = null;
    var columnas = new Array();
    var filas = new Array();
    var objXML = new tXML();
    objXML.async = false
    if (objXML.loadXML(rsdatatext)) {
        var campos = objXML.selectNodes('/xml/s:Schema/s:ElementType/s:AttributeType')
        for (var i = 0; i < campos.length; i++) {
            var columna = campos[i].getAttribute('name')
            columnas.push(columna)
        }
        var rsdatarows = objXML.selectNodes('/xml/rs:data/z:row')
        for (var i = 0; i < rsdatarows.length; i++) {
            var fila = {}
            for (var j = 0; j < columnas.length; j++) {
                var valor = rsdatarows[i].getAttribute(columnas[j])
                var cab = objXML.selectSingleNode("/xml/s:Schema/s:ElementType/s:AttributeType[@name='" + columnas[j] + "']")
                var type = cab.childNodes[0].getAttribute("dt:type")
                switch (type) {
                    case "i8":
                        valor = +valor
                        break;
                    case "int":
                        valor = +valor
                        break;
                    case "number":
                        valor = parseFloat(valor)
                        break;
                    default:
                }
                fila[columnas[j]] = valor
            }
            filas.push(fila)
        }
    }
    return filas;

}