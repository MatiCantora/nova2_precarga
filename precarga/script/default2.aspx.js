
var cupo_disponible = 0

/* Variables persona */
//var fe_naci = ''
//var sexo = ''
//var tipo_docu = 0
//var nro_docu = 0
//var cuit = ''
//var razon_social = ''
//var domicilio = ''
//var localidad = ''
//var CP = 0
//var provincia = ''
//var cod_prov_persona = 0
//var nro_archivo_nosis = 0
//var nro_docu_db = 0

//var TotalCancelaciones1 = 0
var LiberaCuota = 0
var cancelaciones = 0
var importe_max_cuota = 0

var nro_analisis = undefined
var nro_analisis_actual = -1

//var crPostergaciones = Array() //guarda los creditos que se relacionan entre si por postergaciones 

var vendedor = ''
var WinTipo = ''
var origen = 'precarga'
var tiene_seguro = 0

var win_descargas
function Descargar_formularios() {
    win_descargas = createWindow2({
        url: 'formulario_descarga.aspx?codesrvsw=true',
        title: '<b>Descargar Solicitudes</b>',
        maxHeight: 350,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true
    });
    win_descargas.options.userData = { res: '' }
    win_descargas.showCenter(true)

    if (isMobile())
        mostrarMenuIzquierdo()
}


function UbicacionObtener() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(Ubicacion, UbicacionErrores);
    } else {
        nvFW.alert('No disponible')
    }
}

var geoloc_lat = 0
var geoloc_long = 0
var geoloc_domicilio = ''
var geoloc_localidad = ''
var geoloc_provincia = ''
var geoloc_pais = ''
var ismobile = false

function Ubicacion(position) {
    geoloc_lat = position.coords.latitude
    geoloc_long = position.coords.longitude
    UbicacionDescripcion()
}

var win_ubicacion
var btn_aceptar_u = false

function UbicacionErrores(error) {
    var desc_error = ""
    switch (error.code) {
        case error.PERMISSION_DENIED:
            desc_error = "Permiso denegado para acceder a la ubicación."
            break;
        case error.POSITION_UNAVAILABLE:
            desc_error = "La información de la ubicación no se encuentra disponible."
            break;
        case error.TIMEOUT:
            desc_error = "Tiempo de respuesta agotado para obtener la ubicación."
            break;
        case error.UNKNOWN_ERROR:
            desc_error = "Error Desconocido."
            break;
    }
    if (desc_error != "") {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        win_ubicacion = createWindow2({
            title: '<b>Ubicación Geográfica</b>',
            parentWidthPercent: 0.8,
            //parentWidthElement: $("contenedor"),
            maxWidth: 450,
            //centerHFromElement: $("contenedor"),
            minimizable: false,
            maximizable: false,
            draggable: false,
            resizable: true,
            closable: false,
            recenterAuto: true,
            setHeightToContent: true,
            onClose: function () {
                if (btn_aceptar_u) {
                    //ObtenerSucursalOperador()
                    document.getElementById('nro_docu1').focus()
                }
                else
                    UbicacionObtener()
            }
        });
        var html = '<html><head></head><body style="width:100%;height:100%;overflow:hidden">'
        html += '<table class="tb1">'
        html += '<tbody><tr><td colspan="2"><b>La aplicación no pudo obtener la ubicación geográfica.</b><br><br>Acepte el mensaje de seguridad del browser o configure manualmente el acceso a la ubicación.</td></tr>'
        html += '<tr><td style="text-align:center;width:40%"><br><input type="button" style="width:99%" value="Reintentar" onclick="win_ubicacion_cerrar(false)" style="cursor: pointer !important" /></td><td style="text-align:center;width:60%"><br><input type="button" style="width:99%" value="Continuar sin ubicación" onclick="win_ubicacion_cerrar(true)" style="cursor: pointer !important" /></td></tr>'
        html += '</tbody></table></body></html>'

        win_ubicacion.setHTMLContent(html)
        win_ubicacion.showCenter(true)
    }
}

function win_ubicacion_cerrar(aceptar) {
    btn_aceptar_u = aceptar
    win_ubicacion.close()
}

function UbicacionDescripcion() {
    var request = new XMLHttpRequest();

    var method = 'GET';
    var url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=' + geoloc_lat + ',' + geoloc_long + '&sensor=true';
    var async = true;

    request.open(method, url, async);
    request.onreadystatechange = function () {
        if (request.readyState == 4 && request.status == 200) {
            var data = JSON.parse(request.responseText);
            try {
                geoloc_domicilio = data.results[0].formatted_address
                geoloc_localidad = data.results[0].address_components[2]['long_name']
                geoloc_provincia = data.results[0].address_components[4]['long_name']
                geoloc_pais = data.results[0].address_components[5]['long_name']
            }
            catch (e) {
            }
            //ObtenerSucursalOperador()
            document.getElementById('nro_docu1').focus()
        }
    };
    request.send();
};






var BodyWidth = 0
var widthWin = 0
var heightWin = 0
var leftWin = 0
var topWin = 0

var cod_prov_op
var sucursal_postal_real


function Mostrar_grupos() {
    $('divMostrarTrabajos').innerHTML = ''
    var strHTML = ""
    strHTML += "<table class='tb1' cellspacing='1' cellpadding='1'>"
    strHTML += "<tr><td class='Tit1' colspan='2' style='text-align:center'><b>Seleccione el mercado para continuar.<b></td></tr>"
    strHTML += "<tr><td style='width:100%'>"
    strHTML += "<table class='tb1' style='max-width:450px; margin:auto'><tr><td id='tdgrupos'></td><td id='divGAceptar'></td></tr></table>"
    strHTML += "</td>"
    strHTML += "</tr></table>"
    $('divMostrarTrabajos').insert({ bottom: strHTML })
    $('divMostrarTrabajos').show()
    var vButtonItems = {}
    vButtonItems[0] = {}
    vButtonItems[0]["nombre"] = "GAceptar";
    vButtonItems[0]["etiqueta"] = "Aceptar";
    vButtonItems[0]["imagen"] = "aceptar";
    vButtonItems[0]["onclick"] = "consulta.grupo_seleccionar()";
    var vListButtons = new tListButton(vButtonItems, 'vListButtons');
    vListButtons.loadImage("aceptar", "image/search_16.png");
    vListButtons.MostrarListButton()
    campos_defs.add("grupos", { nro_campo_tipo: 1, target: "tdgrupos", enDB: false, cacheControl: 'Session', filtroXML: nvFW.pageContents["grupos_cda"] })

    //JMO
    campos_defs.items["grupos"].onchange = function () { campos_defs.items["grupos"].input_text.focus() }
    $(campos_defs.items["grupos"].input_text).observe('keypress', function (e) {
        var tecla = !e.keyCode ? e.which : e.keyCode
        if (tecla = 13)
            consulta.grupo_seleccionar()
    })

    campos_defs.items["grupos"].input_text.ondblclick()
}


var CDA = 0
var nro_banco = 31

var win_sel_cuit
var win_sel_dbcuit



var nro_tipo_cobro = 0
var win_cobro
var btn_cobro_aceptar = false
var tiene_cupo = false
var grupo = ''
var tipo_cobro = ''
var tipo_rechazo_call = ''
var observaciones_call = ''


function win_tipo_rechazo(aceptar) {
    dictamen = 'RECHAZADO'
    tipo_rechazo_call = $('cbtr').value
    observaciones_call = $('txt_observaciones').value
    btn_tr_aceptar = aceptar
    win_tr.close()
}

function Generar_codigo() {
    if (nro_vendedor == 0 || nro_vendedor == '') {
        alert("debe seleccionar vendedor")
        return
    }
    var rstr = new tRS()
    rstr.open({ filtroXML: nvFW.pageContents["codigoyacare"], params: "<criterio><params nro_docu='" + consulta.cliente.nro_docu + "' sexo='" + consulta.cliente.sexo + "' tipo_docu='" + consulta.cliente.tipo_docu + "' cuit='" + consulta.cliente.cuit + "' nro_vendedor='" + consulta.nro_vendedor + "'  /></criterio>" })

    if (!rstr.eof()) {
        var codigo = rstr.getdata('codigo')
        var param = {}
        param['codigo'] = codigo
        param['strNombreCompleto'] = nombre.trim()
        var win_enviotyc = window.top.createWindow2({
            url: 'precarga_envio_codigo.aspx',
            title: '<b>Enviar codigo yacaré</b>',
            centerHFromElement: window.top.$("contenedor"),
            parentWidthElement: window.top.$("contenedor"),
            parentWidthPercent: 0.9,
            parentHeightElement: window.top.$("contenedor"),
            parentHeightPercent: 0.9,
            maxHeight: 180,
            minimizable: false,
            maximizable: false,
            draggable: true,
            resizable: true,
            onClose: function () { }
        });
        win_enviotyc.options.userData = { param: param }
        win_enviotyc.showCenter(true)
    }

}

var win_tr
var btn_tr_aceptar = false

function tipo_rechazo() {
    win_tr = createWindow2({
        className: 'alphacube',
        title: '<b>Tipo de rechazo</b>',
        parentWidthPercent: 0.8,
        //parentWidthElement: $("contenedor"),
        maxWidth: 450,
        maxHeight: 200,
        //centerHFromElement: $("contenedor"),
        minimizable: false,
        maximizable: false,
        draggable: false,
        resizable: true,
        closable: false,
        recenterAuto: true,
        setHeightToContent: true,
        //destroyOnClose: true,
        onClose: function () {
            if (btn_tr_aceptar) {
                strHTML_CDA_noti = ''
                strHTML_CDA_noti += '<table>'
                strHTML_CDA_noti += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#800000 !important"><b>' + tipo_rechazo_call + '</b></td></tr>'
                strHTML_CDA_noti += '<table style="font-family: Verdana,Arial,Sans-serif;font-size: 12px"><tr><td><b>CUIT/CUIL:</b></td><td style="text-align:left">' + consulta.cliente.cuit + '</td></tr>'
                strHTML_CDA_noti += '<tr><td><b>Nombre:</b></td><td>' + nombre + '</td></tr><tr><td><b>Observaciones:</b></td><td>' + observaciones_call + '</td></tr></table>'
                NotiEnviar()
            }
        }
    });
    var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
    html += "<table class='tb1' style='width:100%'>"
    html += "<tbody><tr><td colspan=2 class='Tit1'><br><b>Seleccione el tipo de rechazo.</b><br><br></td></tr>"
    html += "<tr><td style='width:30%'>Tipo:</td><td style='width:70%'><select id='cbtr' style='width:100%'>"
    var str_sel = ""
    var rstr = new tRS()
    rstr.open({ filtroXML: nvFW.pageContents["tipos_rechazos"] })
    while (!rstr.eof()) {
        html += "<option id='" + rstr.getdata('nro_com_tipo') + "' value='" + rstr.getdata('com_tipo') + "' " + str_sel + ">" + rstr.getdata('com_tipo') + "</option>"
        rstr.movenext()
    }
    html += "</select></td></tr>"
    html += "<tr><td>Observaciones:</td><td><textarea id='txt_observaciones' style='width:100%' rows='3'></textarea></td></tr>"
    html += "<tr><td style='text-align:center' colspan='2'><br><input type='button' value='Notificar' onclick='win_tipo_rechazo(true)'/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' value='Cancelar' onclick='win_tipo_rechazo(false)'/><br><br></td></tr>"
    html += "</tbody></table></body></html>"
    win_tr.setHTMLContent(html)
    win_tr.showCenter(true)
}


var hpx = 0

function NotiEnviar() {
    let dictamen = consulta.resultado['dictamen'].toUpperCase()

    var subject = 'Notificación Precarga ' + dictamen + ' - ' + consulta.cliente.cuit + ':' + consulta.cliente.nombre.trim()
    var body = '<b>Razón Social:</b> ' + consulta.cliente.nombre + '<br>'
    body += '<b>CUIT/CUIL:</b> ' + consulta.cliente.cuit + '<br><br>'
    body += 'Informe Comercial:<br>'
    body += '<b>Situación:</b> ' + consulta.resultado.bcra_sit + ' - <b>CDA:</b> ' + dictamen
    var parametros = {}
    parametros['subject'] = subject
    parametros['body'] = consulta.resultado.strHTML_CDA_noti
    parametros['tipo_rechazo_call'] = tipo_rechazo_call
    parametros['cuit'] = consulta.cliente.cuit
    let win_noti = createWindow2({
        url: 'sendMail.aspx?nro_vendedor=' + consulta.nro_vendedor,
        title: '<b>Notificación</b>',
        //centerHFromElement: $("contenedor"),
        //parentWidthElement: $("contenedor"),
        //parentWidthPercent: 0.9,
        //parentHeightElement: $("contenedor"),
        //parentHeightPercent: 0.9,
        maxHeight: 500,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true
    });
    win_noti.options.userData = { parametros: parametros }
    win_noti.showCenter(true)
}

//var sit_bcra = 99
var nro_banco_cobro = 0
var banco_cobro = ''


var existe
var fecha_actualizacion = ''
var disponible = 0

//var nombre = ''
//var edad = 0

var prueba = ''
var NroConsulta = 0
var edad = ''
var fe_naci_str = ''

var HTMLCDA = ''



//var Creditos = {}
//var Consumos = {}
var win_persona

var persona_existe = true
var fe_naci_socio = ''
var edad_socio = 0
var win_sel_persona

var datos_persona = {}


//var win_control_cred
var opcion_ctrl = 0

function win_control_cred_cerrar(opcion) {
    if (opcion == 1)
        VerCreditos('S')
    else {
        opcion_ctrl = opcion
        win_control_cred.close()
    }

}


var plan_lineas = ''
var noti_prov = false
var nro_credito_random = 0

function chk_noti_prov_on_click() {
    if ($('chk_noti_prov').checked)
        campos_defs.habilitar('cod_provincia', true)   //$('cbprov').enable()
    else {
        campos_defs.set_value('cod_provincia', cod_prov_persona)  //$('cbprov').value = cod_prov_persona
        campos_defs.habilitar('cod_provincia', false) //$('cbprov').disable()
    }
}

var win_sel_cp
var btn_sel_cp_aceptar = false

var win_files
var nro_archivo_noti_prov = 0

function ABMArchivos_return() {
    var retorno = win_files.options.userData.res
    if (retorno == undefined) {
        nvFW.alert('Debe adjuntar un servicio para notificar el cambio de provincia.')
        consulta.limpiar()
    }
    var sucess = retorno['sucess']
    nro_archivo_noti_prov = retorno['nro_archivo']
    if (sucess == true) {
        nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Buscando información del producto...(01)')
        $('divProducto').show()
        $('divFiltros').show()
        if (nro_grupo != 0) {
            $('ifrplanes').hide()
            $('tbfiltros').hide()
            $('selplan').hide()
            $('selplan').setStyle({ display: 'inline' })
        }
        else {
            $('ifrplanes').show()
            $('tbfiltros').show()
            $('selplan').setStyle({ display: 'none' })
        }
        $('tbButtons').show()
        $('strEnMano').innerHTML = ''
        $('chkmax_disp').checked = true
        $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
        importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
        var socio = false
        for (var j in Creditos) {
            if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
                socio = true
                break
            }
        }
        if (!socio)
            importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
        //  $('banco').options.length = 0
        //  $('mutual').options.length = 0
        campos_defs.clear('banco')
        campos_defs.clear('mutual')
        CargarBancos(banco_onchange)
    }
    else {
        nvFW.alert('Debe adjuntar un servicio para notificar el cambio de provincia.')
        consulta.limpiar()
    }
}


function inaes_black_list(nro_banco) {
    if (nro_banco != 800) return false;
    var rs = new tRS()
    rs.async = false
    //var cuit=$("cuit").value
    rs.open({ filtroXML: nvFW.pageContents["inaes_black_list"], params: "<criterio><params CUIT='" + consulta.cliente.cuit + "' /></criterio>" })
    return (!rs.eof())

}


var importe_cuota_social = 0
var importe_cs_analisis = 0



function win_edad_cerrar(aceptar) {
    if (aceptar) {
        if ($('fe_naci').value == '') {
            nvFW.alert('Ingrese la fecha de nacimiento.')
            return
        }
    }
    btn_aceptar = aceptar
    win_edad.close()
}

var win_edad
var btn_aceptar = false

function getEdad(dateString) {
    var dia = dateString.substring(0, dateString.indexOf("/"))
    var mes = dateString.substring(dateString.indexOf("/") + 1, dateString.indexOf("/", dateString.indexOf("/") + 1))
    var anio = dateString.substring(dateString.indexOf("/", dateString.indexOf("/") + 1) + 1, dateString.length)
    dateString = mes + "/" + dia + "/" + anio
    var today = new Date();
    var birthDate = new Date(dateString);
    var age = today.getFullYear() - birthDate.getFullYear();
    var m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
}


/*
if (nvFW.nvInterOP) {
function abrirChat() {
nvFW.nvInterOP.openChatRoom();
}
 
nvFW.nvInterOP.sendMessage("login", "<action><params user='prueba_xmpp' password='1234562' token='' cod_app='cod_app' cod_implement='AABC10F' /></action>")
nvFW.nvInterOP.receiveMessageHandler = function (action, params) {
if (action == 'is_alive') {
nvFW.nvInterOP.sendMessage('is_alive', 'true')
return;
}
 
 
if (action == 'BackPressed') {
 
establecerFuncionBack()
 
nvFW.nvInterOP.sendMessage('BackPressed', 'true') // le respondo al esqueleto que ya me hice cargo del back
//nvFW.nvInterOP.sendMessage('BackPressed','false') //le respondo al esqueleto que manda la app al backgroun
return;
}
 
if (action == 'MessageReceived') {
alert('Notificacion Recibida')
console.log('Notificaci—n recibida.')
}
}
}
*/

//function Btn_cancelaciones_onclick(objeto) {
//    var nombre1 = (objeto) ? objeto.id : 'td_canc_int'
//    $(nombre1).setStyle({ width: "30%", color: "#404040", cursor: "auto", textDecoration: "none" })
//    var nombre = (nombre1 == 'td_canc_3') ? 'td_canc_int' : 'td_canc_3'
//    $(nombre).setStyle({ width: "30%", color: "#FFFFFF", cursor: "pointer", textDecoration: "underline" })
//    if (nombre1 == 'td_canc_3') {
//        $('tbCredVigente').hide()
//        $('tbCredVigente3').show()
//    }
//    else {
//        $('tbCredVigente').show()
//        $('tbCredVigente3').hide()
//    }
//}

/*--------------------------------------------------------------------
|   nvFW.nvInterOP
|---------------------------------------------------------------------
|
|   Interfaz entre WebApp de Android y JavaScript, con la cual podemos
|   ejecutar métodos en la aplicación nativa Android.
|
|-------------------------------------------------------------------*/
if (nvFW.nvInterOP) {
    nvFW.nvInterOP.checkIfHandlerExists('true')
    function abrirChat() {
        nvFW.nvInterOP.openChatRoom()
        if (isMobile())
            mostrarMenuIzquierdo()
    }

    //nvSession.UID

    // esto va en nvLogin.js: linea 278
    //try {
    //	 
    //	 if (nvFW.nvInterOP) {
    //		 nvFW.nvInterOP.sendMessage("login", "<action><params user='" +  $('UID').value + "' password='" + $('PWD').value + "' token='' cod_app='" + app_cod_sistema + "' cod_implement='AABC10F' /></action>")
    //	 }
    //} catch (e) {
    //}

    nvFW.nvInterOP.receiveMessageHandler = function (action, params) {
        if (action == 'is_alive') {
            nvFW.nvInterOP.sendMessage('is_alive', 'true')
            //         nvFW.nvInterOP.checkIfHandlerExists('true')
            return;
        }

        if (action == 'BackPressed') {
            establecerFuncionBack()
            nvFW.nvInterOP.sendMessage('BackPressed', 'true') // le respondo al esqueleto que ya me hice cargo del Back
            //nvFW.nvInterOP.sendMessage('BackPressed','false') //le respondo al esqueleto que manda la app al background
            return;
        }

        if (action == 'MessageReceived') {
            alert('Notificacion Recibida')
            // console.log('Notificaci—n recibida.')
        }

        if (action == 'get_hash') {
            nvFW.nvInterOP.sendMessage('get_hash', nvFW.get_hash())
        }

        if (action == 'xmppMessageReceived') {
            var xmlObj = new tXML()
            xmlObj.loadXML(params)
            var nod = xmlObj.selectNodes("action/params")[0]
            var messagesPreview = nod.getAttribute("messagesPreview")
            var newMessagesCount = nod.getAttribute("newMessagesCount")

            //alert("Operador de chat dice: <br><b>" + messagesPreview + "...</b>")
            // Mostrar mensajería en un dialog de Android
            nvFW.interOP.printDialogMessage('Operador de chat dice:', messagesPreview);
        }
    }
}

try {
    if (window.webkit.messageHandlers) {
        //
        window.webkit.messageHandlers.nvInterOp.receiveMessageHandler = function (action, params) {
            // 
            if (action == 'BackPressed') {
                //  
                establecerFuncionBack()
                window.webkit.messageHandlers.nvInterOp.postMessage('BackPressed') // le respondo al esqueleto que ya me hice cargo del Back
                return;
            }


        }

        // window.webkit.messageHandlers.nvInterOp.postMessage('close_app')
    }
}
catch (e) { }


function descargar_app() {
    if (isMobile())
        mostrarMenuIzquierdo()

    window.open('https://play.google.com/store/apps/details?id=com.improntasolutions.precarga&hl=es')
}