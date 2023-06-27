//############################################
//##########-------NO SE USAN-------##########
//############################################

function Evaluar_socio() {
    if ((tiene_cs > 0) || (tiene_cr > 0))
        $('divSocio').show()
    var Evaluar_persona = function () {
        var rs = new tRS();
        rs.async = true
        rs.onError = function (rs) {
            rserror_handler("Error al consultar los datos. Intente nuevamente (Persona).")
        }
        rs.onComplete = function (rs) {
            if (rs.recordcount == 0) {
                $('divSocio').hide()
                persona_existe = false
                SeleccionarPlanesMostrar()
            }
            if (rs.recordcount == 1) {  // Si la búsqueda de la persona por cuit da un resultado -> Carga creditos y CS
                //consulta.cliente.nro_docu = rs.getdata('nro_docu')
                //consulta.cliente.tipo_docu = rs.getdata('tipo_docu')
                //consulta.cliente.sexo = rs.getdata('sexo')
                //$('sexo').value =consulta.cliente.sexo
                // $('tipo_docu').value = consulta.cliente.tipo_docu
                //cod_prov_persona = rs.getdata('cod_prov')
                //fe_naci_socio = rs.getdata('fe_naci')
                //edad_socio = rs.getdata('edad')
                Evaluar_cs(consulta.cliente.nro_docu, consulta.cliente.tipo_docu, consulta.cliente.sexo, consulta.cliente.cuit, consulta.cliente.trabajo.nro_grupo)
            }
            if (rs.recordcount > 1) {   // Si la búsqueda da más de un resultado
                datos_persona['nro_docu'] = ''
                datos_persona['cuit'] = consulta.cliente.cuit
                win_sel_persona = createWindow2({
                    title: '<b>Seleccionar Persona</b>',
                    //centerHFromElement: $("contenedor"),
                    //parentWidthElement: $("contenedor"),
                    //parentWidthPercent: 0.9,
                    //parentHeightElement: $("contenedor"),
                    //parentHeightPercent: 0.9,
                    maxHeight: 500,
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: true,
                    onClose: function (win) {
                        if (win.options.userData.res != undefined) {
                            var filtros = {}
                            //consulta.cliente.nro_docu = win.options.userData.res['nro_docu']
                            //consulta.cliente.tipo_docu = win.options.userData.res['tipo_docu']
                            //consulta.cliente.sexo = win.options.userData.res['sexo']
                            cod_prov_persona = win.options.userData.res['cod_prov']
                            //var nombre = win.options.userData.res['nombre']
                            //fe_naci_socio = win.options.userData.res['fe_naci']
                            rs = null
                            Evaluar_cs(consulta.cliente.nro_docu, consulta.cliente.tipo_docu, consulta.cliente.sexo, consulta.cliente.cuit, consulta.cliente.trabajo.nro_grupo)
                        }
                        else {
                            $('divSocio').hide()
                            persona_existe = false
                            SeleccionarPlanesMostrar()
                        }
                    }
                });
                win_sel_persona.options.userData = { datos_persona: datos_persona }
                win_sel_persona.setURL('precarga_sel_persona.aspx?codesrvsw=true')
                win_sel_persona.showCenter(true)

            }
            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        }
        rs.open({ filtroXML: nvFW.pageContents["persona"], params: "<criterio><params cuit='" + consulta.cliente.cuit + "' /></criterio>" })
    }

    var Evaluar_cs = function (nro_docu, tipo_docu, sexo, cuit, nro_grupo) {
        nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información de cuota social...')
        if (tiene_cs > 0) {
            var strHTMLS = "<table class='tb1' cellspacing='1' cellpadding='1' style='vertical-align:top'>"
            var rsCS = new tRS();
            rsCS.async = true
            rsCS.onError = function (rsCS) {
                rserror_handler("Error al consultar los datos. Intente nuevamente (creditos_cs).")
            }
            rsCS.onComplete = function (rsCS) {
                if (rsCS.recordcount > 0)
                    strHTMLS += "<tr><td class='Tit1' style='width:70%'>Mutual</td><td class='Tit1' style='width:30%;text-align:right'>Cuota</td></tr>"
                else
                    strHTMLS += "<tr><td class='Tit1' style='width:100%' colspan=2>Sin información</td></tr>"
                while (!rsCS.eof()) {
                    i++
                    Creditos[i] = {}
                    Creditos[i]['nro_credito'] = 0
                    Creditos[i]['nro_banco'] = 200
                    Creditos[i]['nro_mutual'] = rsCS.getdata('nro_mutual')
                    Creditos[i]['mutual'] = rsCS.getdata('mutual')
                    Creditos[i]['importe_cuota'] = parseFloat(rsCS.getdata('importe_cuota')).toFixed(2)
                    Creditos[i]['saldo'] = 0
                    Creditos[i]['saldo_nro_entidad'] = 0
                    Creditos[i]['cancela_vence'] = ''
                    Creditos[i]['cancela_cuota_paga'] = 0
                    Creditos[i]['nro_credito_seguro'] = 0
                    Creditos[i]['nro_calc_tipo'] = 0
                    Creditos[i]['cancela'] = false
                    rsCS.movenext()
                }
                for (var j in Creditos) {
                    strHTMLS += "<tr><td>" + Creditos[j]['mutual'] + "</td><td style='text-align:right'>$ " + parseFloat(Creditos[j]['importe_cuota']).toFixed(2) + "</td></tr>"
                }
                strHTMLS += "</table>"
                $('tbCuotaSocial').insert({ bottom: strHTMLS })
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                Evaluar_cr()
            }
            rsCS.open({ filtroXML: nvFW.pageContents["creditos_cs"], params: "<criterio><params nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' cuit='" + cuit + "'   nro_grupo='" + nro_grupo + "' /></criterio>" })
        }
        else {
            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            Evaluar_cr()
        }

    }//evaluar_cs

    //evaluar_cr -> se cambio por cancelaciones.js

    $('tbCredVigente').innerHTML = ''
    $('tbCredVigente3').innerHTML = ''
    $('tbCuotaSocial').innerHTML = ''
    var i = 0
    Creditos = {}
    if (cr_mes > 0) {
        win_control_cred = createWindow2({
            title: '<b>Control de créditos</b>',
            parentWidthPercent: 0.8,
            //parentWidthElement: $("contenedor"),
            maxWidth: 450,
            maxHeight: 120,
            //centerHFromElement: $("contenedor"),
            minimizable: false,
            maximizable: false,
            draggable: false,
            resizable: true,
            closable: false,
            recenterAuto: true,
            setHeightToContent: true,
            onClose: function () {
                if (opcion_ctrl == 2) {
                    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información del socio...')
                    Evaluar_persona()
                }
                else
                    consulta.limpiar()
            }
        });
        var html = "<html><head></head><body style='width:100%;height:100%;overflow:hidden'>"
        html += "<table class='tb1'>"
        html += "<tr><td colspan=3 class='Tit1'><br>Ya existen créditos ingresados en el mes para el número de documento: <b>" + $('nro_docu1').value + "</b>. Desea ver los créditos o continuar con la carga?</b><br><br></td></tr><table>"
        html += "<table class='tb1'><tr><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Ver Créditos' onclick='win_control_cred_cerrar(1)'/></td><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Continuar' onclick='win_control_cred_cerrar(2)'/></td><td style='text-align:center;width:33%'><br><input type='button' style='width:100%; cursor:pointer' value='Limpiar' onclick='win_control_cred_cerrar(3)'/></td></tr>"
        html += "</table></body></html>"
        win_control_cred.setHTMLContent(html)
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        win_control_cred.showCenter(true)
    }
    else
        Evaluar_persona()
}

var aux_valor_banco_old = ''
function CargarBancos(banco_onchange) {
    debugger;
    var nro_banco_first = ""
    //si hubo ofertas, es porque vino desde el motor, sino busco los cambios segun consulta a la BD que va por el camino tradicional
    var hayofertasmotor = motor.tiene_ofertas()
    campos_defs.habilitar("banco", true)
    campos_defs.clear_list("banco")
    var rs = new tRS()
    var i = 0
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente (operatoria_bancos).")
    }
    rs.onComplete = function (rs) {
        campos_defs.items['banco'].rs = rs
        campos_defs.set_first('banco')
        if (nro_banco_first != "") {
            campos_defs.set_value("banco", nro_banco_first)
        }
        if (rs.recordcount == 1) campos_defs.habilitar("banco", false)
        else campos_defs.habilitar("banco", true)
    }


    if (!hayofertasmotor) {
        if (!sit_bcra) {
            sit_bcra = motor.datos['bcra_sit']
        }
        rs.open({ filtroXML: nvFW.pageContents["operatoria_bancos"], params: "<criterio><params sit_bcra='" + sit_bcra + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco_cobro='" + nro_banco_cobro + "' /></criterio>" })
    } else {
        //filtro los arreglos que no tengan estado
        var aBancos = motor['ofertas'].filter(that => that.estado != null)
        //ordeno por campo orden            (de menor a mayor)
        aBancos.sort(function (a, b) {
            if (a.orden > b.orden) {
                return 1;
            }
            if (a.orden < b.orden) {
                return -1;
            }
            // a must be equal to b
            return 0;
        }) //sort

        if (aBancos.length > 0) {
            nro_banco_first = aBancos[0].nro_banco.toString()
        }
        var bancos = (aBancos.map(item => item.nro_banco)).toString() //obtengo nro_bancos los bancos
        rs.open({ filtroXML: nvFW.pageContents["operatoria_bancos_manual"], params: "<criterio><params sit_bcra='" + sit_bcra + "'  nro_bancos='" + bancos + "' /></criterio>" })
    }//hayofertasmotor

}


function banco_onchange() {

    var nro_banco_filtro = campos_defs.get_value('banco')//$('banco').value

    if (nro_banco_filtro == aux_valor_banco_old) {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
        return
    }
    /*if(inaes_black_list(nro_banco_filtro)){
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
        alert("Persona bloqueada para alta en voii. Seleccione otro Banco")
        if(aux_valor_banco_old!=800 && aux_valor_banco_old!=""){
        campos_defs.set_value('banco',aux_valor_banco_old)       
        }
        return
    }*/

    campos_defs.habilitar("mutual", true)
    campos_defs.clear_list("mutual")
    campos_defs.habilitar("cbAnalisis", true)
    campos_defs.clear_list("cbAnalisis")

    if (nro_banco_filtro != '') {
        CargarMutuales(nro_banco_filtro, mutual_onchange)
    }
    else {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    }
    aux_valor_banco_old = nro_banco_filtro

}


function mutual_onchange() {
    var rs_cs = new tRS();
    importe_cuota_social = 0
    importe_cs_analisis = 0
    if (campos_defs.get_value('mutual') == aux_valor_mutual_old) {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');
        return
    }

    campos_defs.habilitar("cbAnalisis", true)
    campos_defs.clear_list("cbAnalisis")
    rs_cs.open({ filtroXML: nvFW.pageContents["mutual_cuota"], params: "<criterio><params nro_mutual='" + campos_defs.get_value('mutual') + "' nro_grupo='" + nro_grupo + "' /></criterio>" })
    if (!rs_cs.eof())
        importe_cuota_social = parseFloat(rs_cs.getdata('importe_cuota_social')).toFixed(2)
    $('strEnMano').innerHTML = ''
    importe_mano = 0
    $('strEnMano').insert({ bottom: '$ ' + parseFloat(importe_mano).toFixed(2) })
    importe_max_cuota = parseFloat(parseFloat(cupo_disponible) + parseFloat(LiberaCuota)).toFixed(2)
    var socio = false
    for (var j in Creditos) {
        if (Creditos[j]['nro_banco'] == 200 && Creditos[j]['nro_mutual'] == campos_defs.get_value('mutual')) {
            socio = true
            break
        }
    }
    if (!socio) {
        importe_cs_analisis = parseFloat(importe_cuota_social).toFixed(2)
        importe_max_cuota = parseFloat(parseFloat(importe_max_cuota) - parseFloat(importe_cuota_social)).toFixed(2)
    }
    var j = 0
    for (var x in Creditos) {
        if (Creditos[x]['cancela'] == true) {
            j++
            Cancelaciones[j]['cancela_cuota'] = Creditos[x]['importe_cuota']
            Cancelaciones[j]['cancela_cupo'] = 0
            Cancelaciones[j]['importe_pago'] = Creditos[x]['saldo']
        }
    }
    $('divHaberes').innerHTML = ""
    $('divHaberesNoVisibles').innerHTML = ""
    $('ifrplanes').src = 'enBlanco.htm'

    $('divAnalisis').show()

    if (motor.tiene_ofertas()) {
        var ofertaMotor = motor.ofertas.filter(oferta => oferta.nro_banco == campos_defs.get_value("banco") && oferta.nro_mutual == campos_defs.get_value("mutual"))
        if (ofertaMotor.length > 0) {
            nro_analisis = ofertaMotor[0].nro_analisis
        }
    }
    CargarAnalisis(nro_analisis)
    //if ((nro_tipo_cobro == 1) && (tiene_cupo) &&  campos_defs.get_value("mutual") != '') {
    //        $('selplan').checked = true
    //        selplan_on_click()
    //        $('chkmax_disp').checked = true
    //        btnBuscarPLanes_onclick()
    //    }
    aux_valor_mutual_old = campos_defs.get_value("mutual")
    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

    checkAllCancelaciones(1);

}//mutual_onchange


var aux_valor_mutual_old = ''
function CargarMutuales(nro_banco_filtro, mutual_onchange) {
    campos_defs.clear("mutual")
    //si hubo ofertas, es porque vino desde el motor, sino busco los cambios segun consulta a la BD que va por el camino tradicional
    if (typeof motor['ofertas'] != "undefined") {
        hayofertasmotor = (motor['ofertas'].length > 0)
    }
    var i = 0
    var sel = false
    var rs = new tRS();
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente (operatoria_mutuales).")
    }
    rs.onComplete = function (rs) {

        campos_defs.items['mutual'].rs = rs
        campos_defs.set_first('mutual')
        if (rs.recordcount == 1) campos_defs.habilitar("mutual", false)
        else campos_defs.habilitar("mutual", true)
    }
    if (!hayofertasmotor) {
        rs.open({ filtroXML: nvFW.pageContents["operatoria_mutuales"], params: "<criterio><params nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco_cobro='" + nro_banco_cobro + "' nro_banco='" + nro_banco_filtro + "' /></criterio>" })
    } else {
        var ofertasporbanco = motor['ofertas'].filter(oferta => oferta.nro_banco == nro_banco_filtro) //obtengo los array de ofertas que tengan el banco en cuestion
        var mutuales = (ofertasporbanco.map(item => item.nro_mutual)).toString() //obtengo las mutuales involucradas en las ofertas, segun banco seleccionado                    
        rs.open({ filtroXML: nvFW.pageContents["operatoria_mutuales_manual"], params: "<criterio><params nro_mutuales='" + mutuales + "' /></criterio>" })
    }

}//CargarMutuales


function NOSIS_evaluar_identidad(nro_docu, onSusses, onError) {
    var strXML = ""
    var strHTML = ""
    var oXML = new tXML();
    oXML.async = true
    oXML.load("/FW/servicios/NOSIS/GetXML.aspx", "accion=SAC_identidad&criterio=<criterio><nro_docu>" + nro_docu + '</nro_docu><CDA>' + CDA + '</CDA><nro_vendedor>' + consulta.nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>',
        function () {
            var NODs = oXML.selectNodes('Resultado/Personas/Persona')
            if (NODs.length == 0) {
                nvFW.alert('No se encontro información con el documento ingresado.')
                onError()
            }
            if (NODs.length == 1) {
                consulta.cliente.cuit = XMLText(selectSingleNode('Doc', NODs[0]))
                existe = selectSingleNode('@existe', NODs[0]).nodeValue
                onSusses(consulta.cliente.cuit)
            }
            if (NODs.length > 1) {
                win_sel_cuit = createWindow2({
                    title: '<b>Seleccionar Persona</b>',
                    //centerHFromElement: $("contenedor"),
                    //parentWidthElement: $("contenedor"),
                    //parentWidthPercent: 0.9,
                    //parentHeightElement: $("contenedor"),
                    //parentHeightPercent: 0.9,
                    maxHeight: 500,
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: true,
                    onClose: function (win) {
                        var e
                        try {
                            consulta.cliente.cuit = win.options.userData.res['cuit']
                            existe = win.options.userData.res['existe']
                            onSusses(consulta.cliente.cuit)
                        }
                        catch (e) {
                            rserror_handler("Error al conaultar el CUIT")
                            return
                        }
                    }
                });
                win_sel_cuit.options.userData = { NODs: oXML }
                win_sel_cuit.setURL('NOSIS_sel_cuit.aspx')
                win_sel_cuit.showCenter(true)
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            }
        }
    );
}


//############################################
//############-------NOSIS-------#############
//############################################

function NOSIS_actualizar_fuentes(cuit) {
    NOSIS_generar_informe(cuit)
}


function NOSIS_generar_informe(cuit) {
    nvFW.bloqueo_msg('blq_precarga', "Obteniendo información de NOSIS...")
    var oXML = new tXML();
    oXML.async = true
    oXML.method = 'POST'
    oXML.onComplete = function () {
        strXML = XMLtoString(oXML.xml)
        NosisXML = strXML
        objXML = new tXML();
        objXML.async = false
        if (objXML.loadXML(strXML))
            var NODs = objXML.selectNodes('Respuesta/ParteHTML')
        if (NODs.length == 1)
            strHTMLNosis = XMLText(NODs[0])
        strHTMLNosis = replace(strHTMLNosis, "undefined", "'")
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    }
    oXML.onFailure = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }
    oXML.load('/FW/servicios/NOSIS/GetXML.aspx', 'accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><CDA>' + CDA + '</CDA><nro_vendedor>' + consulta.nro_vendedor + '</nro_vendedor><nro_banco>' + nro_banco + '</nro_banco></criterio>')

}


//function ObtenerSucursalOperador() {

//    //cod_prov_op = nvFW.operador.cod_prov
//    //sucursal_postal_real = nvFW.operador.sucursal_postal_real
//    //consulta.cliente.nro_docu = nvFW.operador.nro_docu
//    //$('strVendedor').innerText = nvFW.operador.razon_social
//    //strVendedor = nvFW.operador.razon_social
//    //nro_vendedor = nvFW.operador.nro_vendedor
//    //nro_estructura = nvFW.operador.nro_estructura

//    //consulta.nro_vendedor=nro_vendedor
//    //if (nvFW.pageContents['nro_credito'] != 0)
//    //    MostrarCredito(nvFW.pageContents['nro_credito'])
//    //else if (nro_vendedor == '')
//    //    selVendedor_onclick()




//}

//function mostrar_boton_generarcodigo(bandera){

//    //oculto para cuando la estructura no es de mendoza
//    if(bandera){
//            if($("menuItem_menu_left_mobile_6")!=null){
//               $("menuItem_menu_left_mobile_6").show()
//           }
//    }else{
//        if($("menuItem_menu_left_mobile_6")!=null){
//               $("menuItem_menu_left_mobile_6").hide()
//        }
//    }
//}


consulta.cliente_control = function () {

    if (consulta.cliente.cuit == "") {
        rserror_handler("Sin cuit. Intente nuevamente")
        return
    }

    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información del cliente...')

    var rs = new tRS();
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente (Cliente).")
    }
    rs.onComplete = function (rs) {
        if (rs.recordcount > 0) {
            consulta.socio.cr_mes = rs.getdata('cr_mes')
            consulta.socio.tiene_cs = rs.getdata('tiene_cs')
            consulta.socio.tiene_cr = rs.getdata('tiene_cr')
            //consulta.cliente.nro_docu = rs.getdata('nro_docu')
        }
        //Evaluar_socio()
    }

    rs.open({ filtroXML: nvFW.pageContents["evaluar_persona"], params: "<criterio><params nro_vendedor='" + consulta.nro_vendedor + "' cuit='" + consulta.cliente.cuit + "' /></criterio>" })

}


function win_sel_cp_onclick(aceptar) {
    let cod_prov_persona = consulta.cliente.cod_prov_persona;
    if (persona_existe == true) {
        if ($('chk_noti_prov').checked)
            if (cod_prov_persona == campos_defs.get_value('cod_provincia')) {//$('cbprov').value) {
                nvFW.alert('La provincia seleccionada es la misma que la propuesta.<br>Para notificar el cambio debe seleccionar otra. Verifique.')
                return
            }
        noti_prov = $('chk_noti_prov').checked
    }
    if (campos_defs.get_value('cod_provincia') == '') {
        alert("Debe seleccionar la provincia de residencia")
        return
    }
    cod_prov_persona = campos_defs.get_value('cod_provincia') // $('cbprov').value
    btn_sel_cp_aceptar = aceptar
    win_sel_cp.close()
}


function Evaluar_persona() {
    var rs = new tRS();
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente (Persona).")
    }
    rs.onComplete = function (rs) {
        if (rs.recordcount == 0) {
            //$('divSocio').hide()
            persona_existe = false;
        }
        if (rs.recordcount == 1) {  // Si la búsqueda de la persona por cuit da un resultado -> Carga creditos y CS
            persona_existe = true;
        }
        if (rs.recordcount > 1) {   // Si la búsqueda da más de un resultado
            datos_persona['nro_docu'] = ''
            datos_persona['cuit'] = consulta.cliente.cuit
            win_sel_persona = createWindow2({
                title: '<b>Seleccionar Persona</b>',
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: function (win) {
                    if (win.options.userData.res != undefined) {
                        persona_existe = true;
                        consulta.cliente.nro_docu = win.options.userData.res['nro_docu']
                        consulta.cliente.tipo_docu = win.options.userData.res['tipo_docu']
                        consulta.cliente.sexo = win.options.userData.res['sexo']
                        consulta.cliente.cod_prov_persona = win.options.userData.res['cod_prov']
                        consulta.cliente.nombre = win.options.userData.res['nombre']
                        consulta.cliente.fe_naci = win.options.userData.res['fe_naci']
                        rs = null
                    }
                    else {
                        //$('divSocio').hide()
                        persona_existe = false;
                    }
                }
            });
            win_sel_persona.options.userData = { datos_persona: datos_persona }
            win_sel_persona.setURL('precarga_sel_persona.aspx?codesrvsw=true')
            win_sel_persona.showCenter(true)

        }
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    }
    rs.open({ filtroXML: nvFW.pageContents["persona"], params: "<criterio><params cuit='" + consulta.cliente.cuit + "' /></criterio>" })
}
