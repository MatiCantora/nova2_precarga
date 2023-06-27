var consulta = {}
//consulta.nro_vendedor = nvFW.operador.nro_vendedor
//consulta.nro_estructura = nvFW.operador.nro_estructura
//consulta.estructura = nvFW.operador.estructura
//consulta.cod_prov = nvFW.operador.cod_prov
//consulta.cp = nvFW.operador.cp

consulta.cliente = {}
consulta.cliente.fe_naci = ''
consulta.cliente.sexo = ''
consulta.cliente.tipo_docu = 0
consulta.cliente.nro_docu = 0
consulta.cliente.cuit = ''
consulta.cliente.razon_social = ''
consulta.cliente.domicilio = ''
consulta.cliente.localidad = ''
consulta.cliente.CP = 0
consulta.cliente.provincia = ''
consulta.cliente.cod_prov_persona = 0
consulta.cliente.nro_archivo_nosis = 0
consulta.cliente.nro_docu_db = 0

consulta.cliente.trabajo = {}
consulta.cliente.trabajo.nro_sistema = 0
consulta.cliente.trabajo.sistema = ''
consulta.cliente.trabajo.nro_lote = 0
consulta.cliente.trabajo.lote = ''
consulta.cliente.trabajo.clave_sueldo = ''
consulta.cliente.trabajo.nro_grupo = 0

consulta.cliente.trabajos = {}

consulta.resultado = {}
consulta.oferta = {}
consulta.plan = {};


consulta.cargar_operador = function () {
    consulta.nro_vendedor = nvFW.operador.nro_vendedor
    consulta.nro_estructura = nvFW.operador.nro_estructura
    consulta.estructura = nvFW.operador.estructura
    consulta.cod_prov = nvFW.operador.cod_prov
    consulta.cp = nvFW.operador.cp
    consulta.vendedor = nvFW.operador.vendedor
}


consulta.limpiar = function () {

    nvFW.cache.clear();

    consulta.cliente.nro_docu = 0
    consulta.cliente.cuit = ""
    consulta.cliente.nombre = ""
    consulta.cliente.razon_social = ""
    consulta.cliente.fe_naci = ""
    consulta.cliente.edad = ""
    consulta.cliente.sexo = ""
    consulta.cliente.nro_docu_db = ""
    consulta.cliente.sexo = ""
    consulta.cliente.tipo_docu = 0

    //Trabajo
    consulta.cliente.trabajo.tipo = ''
    consulta.cliente.trabajo.sistema = ''
    consulta.cliente.trabajo.nro_sistema = 0
    consulta.cliente.trabajo.lote = ''
    consulta.cliente.trabajo.nro_lote = 0
    consulta.cliente.trabajo.clave_sueldo = ''
    consulta.cliente.trabajo.disponible = -1
    consulta.cliente.trabajo.fecha_actualizacion = ''
    consulta.cliente.trabajo.nro_grupo = 0
    consulta.cliente.trabajo.grupo = ''

    //CDA
    consulta.resultado.strHTML_CDA = ""
    consulta.resultado.strHTML_CDA_noti = ""

    //trabajos
    consulta.trabajos = {}
    consulta.oferta = {}

    consulta.reslutado = null

    consulta.socio = {}
    consulta.socio.cr_mes = 0
    consulta.socio.tiene_cs = 0
    consulta.socio.tiene_cr = 0

    $('strApeyNomb').innerHTML = ''
    $('strFNac').innerHTML = ''
    //$('strInfoCuit').innerHTML = ""
    //$('tdResultado').innerHTML = ""


    $("btn1").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].show() //Pendiente
    $("btn2").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].setStyle({ width: "33%" }) //Precarga. devuelvo tamaño original

    $('strCUIT').innerHTML = ''

    $('divMostrarTrabajos').innerHTML = ''
    $('strSitBCRA').innerHTML = ''
    $('strDictamen').innerHTML = ''
    $('divOfertaResp').innerHTML = '';
    $('strFuentes').innerHTML = ''
    //$('strInfoCuit').innerHTML = ''
    //$('divNotiR').hide()
    //$('tbResultado').hide()
    $('nro_docu1').value = ''

    $('strEnMano').innerHTML = ''

    //Botones de foot
    $('tbButtons').hide()

    $('retirado_desde').value = ''
    $('retirado_hasta').value = ''
    $('importe_cuota_desde').value = ''
    $('importe_cuota_hasta').value = ''
    $('cuota_desde').value = ''
    $('cuota_hasta').value = ''
    //$('importe_cuota').value="0"

    $('divHaberes').innerHTML = ''
    $('divHaberesNoVisibles').innerHTML = ''
    $('saldo_a_cancelar').innerHTML = ''
    $('haber_neto').innerHTML = ''
    $('importe_max_cuota').innerHTML = ''
    $('divHaberes').innerHTML = ""
    $('divHaberesNoVisibles').innerHTML = ""
    $('tbCuotaSocial').innerHTML = ""


    $('divVendedor').show()
    $('divDatosPersonales').hide()
    $('divSelTrabajo').show()
    $('divGrupo').hide()
    $('divSocio').hide()
    $('divFiltros').hide()
    $('divFiltrosLeft').hide()
    $('divFiltrosRight').hide()
    $('divFiltros2Left').hide()
    $('divFiltros2Right').hide()
    $('divFiltros3Left').hide()
    $('divFiltros3Right').hide()
    $('divProducto').hide()
    //$('divMostrarTrabajos').hide()
    $('divAnalisis').hide()

    $('divVolverOferta').hide();
    //planes
    $('divPlanes').hide();
    $('divFiltros').hide();
    $('divOfertaLimpiar').show();
    $('divOfertaResp').show();

    campos_defs.clear("cbAnalisis") //$('cbAnalisis').options.length = 0
    analisis.nro_analisis = 0;

    $('selplan').checked = false
    $('chkmax_disp').checked = false
    document.getElementById('nro_docu1').focus()

    noti_prov = false

    btnStatus(false)

    planes_limpiar();
    wizzard();

}


//consulta.mostrar = function () {
//    if (this.cliente.nro_docu > 0) {
//        $('strApeyNomb').innerHTML = this.cliente.razon_social
//        $('strFNac').innerHTML = this.cliente.fe_naci + ' (' + this.cliente.edad + ')'
//        //$('strInfoCuit').innerHTML = this.cliente.razon_social
//        $('tdResultado').innerHTML = "Resultado: " + this.cliente.cuit
//        $('strCUIT').innerHTML = ''
//        $('strCUIT').insert({ bottom: this.cliente.cuit })
//    }
//}


consulta.cliente_buscar = function () {
    var strAlert = ''
    var tipo = $$('input:checked[type="radio"][name="rddoc"]').pluck('value')[0]
    var control = (tipo == 'dni') ? 8 : 11
    if ($('nro_docu1').value == '')
        strAlert = 'Ingrese un número de documento para realizar la busqueda.<br>'
    if ($('nro_docu1').value.length > control)
        strAlert = 'La cantidad de digitos ingresados es incorrecta.<br>'
    if ((tipo == 'cuit') && ($('nro_docu1').value.length != 11))
        strAlert += 'El CUIT/CUIL debe tener 11 dígitos.<br>'
    if (consulta.nro_vendedor == 0)
        strAlert += 'Seleccione un vendedor para realizar la búsqueda.<br>'
    if (strAlert != '') {
        nvFW.alert(strAlert, { width: "300" })
        document.getElementById('nro_docu1').focus()
        return
    }

    consulta.cliente.nro_docu = $('nro_docu1').value

    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Evaluando identidad...')

    var rs = new tRS();
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente(DBCuit).")
    }

    rs.onComplete = function (rs) {

        if (rs.recordcount == 1) {
            consulta.cliente.cuit = rs.getdata('cuit')
            //consulta.cliente.nombre = rs.getdata('nombre')
            consulta.cliente.razon_social = rs.getdata('nombre')
            consulta.cliente.fe_naci = rs.getdata('fe_naci_str')
            consulta.cliente.edad = rs.getdata('edad')
            consulta.cliente.sexo = rs.getdata('sexo')
            consulta.cliente.nro_docu = rs.getdata('nro_docu')
            consulta.cliente.nro_docu_db = rs.getdata('nro_docu')
            consulta.cliente.sexo = rs.getdata('sexo') ? rs.getdata('sexo') : ''
            consulta.cliente.tipo_docu = 3
            //consulta.mostrar()
            Persona_Trabajos_cargar(consulta.cliente.nro_docu);
            goToNextStep();
        }
        if (rs.recordcount == 0) {
            rserror_handler('No se encontro la persona buscada.')
        }
        if (rs.recordcount > 1) {
            win_sel_dbcuit = createWindow2({
                title: '<b>Seleccionar Persona</b>',
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: function (win) {
                    var e
                    try {

                        res = win_sel_dbcuit.options.userData.res

                        nro_docu_db = res['nro_docu']
                        //consulta.cliente.nro_docu = res['nro_docu']
                        //$('nro_docu').value = res['nro_docu']
                        consulta.cliente.cuit = res['cuit']
                        consulta.cliente.razon_social = res['nombre']
                        consulta.cliente.fe_naci = res['fe_naci_str']
                        consulta.cliente.edad = res['edad']
                        consulta.cliente.sexo = res['sexo']
                        consulta.cliente.tipo_docu = 3
                        consulta.mostrar()
                        Persona_Trabajos_cargar(consulta.cliente.nro_docu)
                        goToNextStep();
                    }
                    catch (e) {
                        rserror_handler('Error al seleccionar la persona.')
                        return
                    }
                }
            });
            win_sel_dbcuit.options.userData = { nro_docu: consulta.cliente.nro_docu }
            win_sel_dbcuit.setURL('NOSIS_sel_DBCuit.aspx')
            win_sel_dbcuit.showCenter(true)
            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        }
    }

    if (tipo == 'dni')
        rs.open({ filtroXML: nvFW.pageContents["DBCuit"], params: "<criterio><params nro_docu='" + this.cliente.nro_docu + "' /></criterio>" })
    else
        rs.open({ filtroXML: nvFW.pageContents["DBCuit2"], params: "<criterio><params cuit='" + this.cliente.nro_docu + "' /></criterio>" })


}


consulta.grupo_seleccionar = function () {
    if ($('grupos').value == '')
        nvFW.alert('Debe seleccionar un grupo para continuar')
    else {
        this.cliente.trabajo.nro_grupo = $('grupos').value
        this.cliente.trabajo.grupo = campos_defs.get_desc("grupos").substring(0, campos_defs.get_desc("grupos").indexOf('('))
        this.cobro_seleccionar()
    }
}


consulta.cobro_seleccionar = function () {

    let indice = document.querySelector('input[name="rdTrabajo"]:checked').value;
    consulta.cliente.trabajo = consulta.cliente.trabajos[indice]
    nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Obteniendo información comercial...')
    //$('divSelTrabajo').hide()
    //$('divDatosPersonales').show()
    var rs = new tRS();
    rs.async = true
    rs.onComplete = function (rs) {
        if (rs.recordcount == 0) {
            rserror_handler("No existen productos para el trabajo/grupo.")
            return;
        }

        $('divTiposCobro').innerHTML = ''
        let strHTML = '<div class="box-product">';
        strHTML += '<div style="text-align: center;"><b>Canal de cobro</b></div>';
        let i = 0;
        while (!rs.eof()) {
            let strchecked = (i == 0) ? 'checked' : ''
            i++;
            cobro_array[i] = {}
            cobro_array[i]['nro_tipo_cobro'] = rs.getdata('nro_tipo_cobro');
            cobro_array[i]['tipo_cobro'] = rs.getdata('tipo_cobro');
            cobro_array[i]['nro_banco'] = rs.getdata('nro_banco');
            cobro_array[i]['abreviacion'] = rs.getdata('abreviacion');

            strHTML += "<div onclick='selcobro(" + i + ")' style='cursor:pointer; display: flex;' >"
            strHTML += "<div><input type='radio' name='rdcobro' id='rdcobro' value='" + i + "' " + strchecked + "/></div>"
            strHTML += "<div>&nbsp;" + ((rs.getdata('nro_banco') == undefined) ? rs.getdata('tipo_cobro') : rs.getdata('tipo_cobro') + " - " + rs.getdata('abreviacion')) + "</div>"
            strHTML += '</div>';

            rs.movenext();

        }
        strHTML += '</div>';

        $('divTiposCobro').insert({ bottom: strHTML });
        goToNextStep();
        $('divSelTrabajo').hide();
        //$('divTiposCobro').setStyle({
        //    height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnCobro").getHeight() + 'px'
        //});

        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga');

    }
    rs.open({ filtroXML: nvFW.pageContents["nosis_cda_def"], params: "<criterio><params nro_grupo='" + this.cliente.trabajo.nro_grupo + "'/></criterio>" })

}


consulta.evaluar = function () {

    let paramsConsulta = '';

    var errEvaluar = nvFW.error_ajax_request("motor/evaluar.aspx", {
        method: "post",
        async: true,
        parameters: {
            criterio: "<criterio><nro_vendedor>" + consulta.nro_vendedor + "</nro_vendedor><nro_grupo>" + consulta.cliente.trabajo.nro_grupo + "</nro_grupo><nro_tipo_cobro>" + consulta.nro_tipo_cobro + "</nro_tipo_cobro><nro_banco>" + consulta.nro_banco_cobro + "</nro_banco><cuit>" + consulta.cliente.cuit + "</cuit><clave_sueldo>" + consulta.cliente.trabajo.clave_sueldo + "</clave_sueldo></criterio>"
        },

        onSuccess: function (a, b, c) {

            //Activar el spinner con los mensajes
            consulta.waitingcupo.cancelar();

            if (paramsConsulta != '')
                this.params = paramsConsulta;

            //Si viene un mnsaje de error
            if (this.params["mensaje_error"] != "") {
                alert(this.params["mensaje_error"])
                consulta.limpiar()
                return
            }

            //Cargar resultado
            consulta.resultado = this.params
            var oXML_targets = new tXML()
            oXML_targets.loadXML(this.params["targets"])

            var strXML_ofertas = XMLtoString(oXML_targets.selectSingleNode('targets/target[@transf_det = "XML Respuesta"]/xml'))
            var oXML_ofertas = new tXML()
            oXML_ofertas.loadXML(strXML_ofertas)

            var xNodes = oXML_ofertas.selectNodes('xml/rs:data/z:row')
            if (xNodes != null) {
                consulta.resultado['ofertas'] = []
                for (var i = 0; i < xNodes.length; i++) {
                    consulta.resultado['ofertas'][i] = {}
                    for (j = 0; j < xNodes[i].attributes.length - 1; j++)
                        consulta.resultado['ofertas'][i][xNodes[i].attributes[j].nodeName] = xNodes[i].attributes[j].nodeValue
                }
            }

            //Cargar cuota social del usuario
            //cargar_cs(consulta.cliente.nro_docu, consulta.cliente.tipo_docu, consulta.cliente.sexo, consulta.cliente.cuit, consulta.resultado.nro_grupo);

            //Ocultar boton pendiente
            //if (consulta.resultado.acepta_pendiente != 1) {
            //    $("btn1").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].hide() //oculto el boton pendiente
            //    $("btn2").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].setStyle({ width: "50%" }) //oculto el boton pendiente
            //}

            //bcra_get_sit_html();
            //consulta.dibujar_dictamen();

            //consulta.resultado_mostrar(0)

            //sit_bcra = consulta.resultado['bcra_sit']

            consulta.cargar_oferta();
            return

        },//onSucces,
        onFailure: function () {
            consulta.waitingcupo.cancelar();
            Dialog.confirm("Algo ha salido mal y no pudimos realizar la calificación<br/> ¿Probamos otra vez?",
                {
                    width: 300,
                    className: "alphacube",
                    okLabel: "Si",
                    cancelLabel: "No",
                    onOk: function (w) {
                        w.close();
                        nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga');
                        consulta.evaluar();
                        return
                    },
                    onCancel: function (w) {
                        consulta.limpiar();
                        w.close();
                    }
                })
        },
        onUploadProgress: function () {
            consulta.waitingcupo.iniciar()
        },
        bloq_contenedor_on: null,
        bloq_contenedor: null,
        bloq_id: 'blq_precarga',
        error_alert: false

    });
}


//############################################
//##########--------DIBUJADO--------##########
//############################################

consulta.waitingcupo = {}
consulta.waitingcupo.idxmsgcupo = 0;
consulta.waitingcupo.mensajescupo = Array("Aguarde un instante...", "Consultado bases internas...", "Obteniendo información de bases internas...", "Consultado bases externas...", "Obteniendo información de bases internas...", "Generando informe comercial...", "Calculando Dictamen...", "Calculando oferta...")
consulta.waitingcupo.iniciar = function () {
    nvFW.bloqueo_msg('blq_precarga', this.mensajescupo[this.idxmsgcupo])
    if (this.mensajescupo.length - 1 == this.idxmsgcupo) {
        this.idxmsgcupo = 0;
    } else {
        this.idxmsgcupo++;
    }
    this.intervalID = window.setTimeout("consulta.waitingcupo.iniciar()", 5000)
}


consulta.waitingcupo.cancelar = function () {
    window.clearTimeout(this.intervalID)
}


consulta.consultar_cupo = function (nro_docu, cuit, sce_id, clave_sueldo, indice, callback) {
    //if (this.consultando) return;
    //if (typeof onbefore == "function") {
    //    onbefore();
    //}
    //this.consultando = true;
    if (!e) var e = window.event;
    e.cancelBubble = true;
    if (e.stopPropagation) e.stopPropagation();

    let that = this;
    nvFW.error_ajax_request('motor/consulta_cupo.aspx', {
        parameters: { modo: 'Z', nro_docu: nro_docu, cuit: cuit, sce_id: sce_id, clave_sueldo: clave_sueldo },
        //bloq_contenedor_on: false,
        onSuccess: function (err, transport) {
            that.consultando = false;
            var strXML = err.params['strXML']
            that.error = err;
            let ofertas = rsdataToArray(strXML) //obtengo las filas del xml data en forma de array

            if (typeof callback == "function") {
                callback(ofertas, indice);
            }
        }, onFailure: function (err) {
            that.consultando = false;
            if (typeof callback == "function") {
                callback()
            }
            console.log(err.mensaje);
            nvFW.alert("Disculpe, hubo un inconveniente. Intente otra vez");
        }//onFailure
    });
}



//Pasar cosas de trabajo a un nuevo JS?
//#####################################
//###########----TRABAJO----###########
//#####################################

function Persona_Trabajos_cargar(nro_docu) {

    consulta.cliente.trabajos = {}
    //nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Identificando trabajos...')
    var rs = new tRS();
    Trabajos = {}
    //var i = 0
    var cod_prov = cod_prov_op
    rs.async = true
    rs.onError = function (rs) {
        rserror_handler("Error al consultar los datos. Intente nuevamente (trabajo).")
    }
    rs.onComplete = function (rs) {

        var i = 0
        while (!rs.eof()) {
            if (rs.getdata('nro_grupo') != 0) {
                i++
                consulta.cliente.trabajos[i] = {}
                consulta.cliente.trabajos[i]['tipo'] = rs.getdata('tipo')
                consulta.cliente.trabajos[i]['sistema'] = rs.getdata('sistema')
                consulta.cliente.trabajos[i]['nro_sistema'] = rs.getdata('nro_sistema')
                consulta.cliente.trabajos[i]['lote'] = rs.getdata('lote')
                consulta.cliente.trabajos[i]['nro_lote'] = rs.getdata('nro_lote')
                consulta.cliente.trabajos[i]['clave_sueldo'] = rs.getdata('clave_sueldo')
                consulta.cliente.trabajos[i]['nro_docu'] = rs.getdata('nro_docu')
                consulta.cliente.trabajos[i]['nombre'] = rs.getdata('nombre')
                consulta.cliente.trabajos[i]['disponible'] = ((rs.getdata('id_origen') == 11210) || (rs.getdata('id_origen') == 651) || (rs.getdata('id_origen') == 11100)) ? -1 : rs.getdata('disponible')
                consulta.cliente.trabajos[i]['fecha_actualizacion'] = rs.getdata('fecha_actualizacion')
                consulta.cliente.trabajos[i]['nro_grupo'] = rs.getdata('nro_grupo')
                consulta.cliente.trabajos[i]['grupo'] = rs.getdata('grupo')
                consulta.cliente.trabajos[i]['id_origen'] = rs.getdata('id_origen')

                //-----------------------------------------------------------------
                consulta.cliente.trabajos[i]['scu_id'] = rs.getdata('Scu_id')
                consulta.cliente.trabajos[i]['sce_id'] = rs.getdata('Sce_Id')
                consulta.cliente.trabajos[i]['premotor'] = null
                consulta.cliente.trabajos[i]['tipo_lote'] = rs.getdata('tipo_lote')
            }
            rs.movenext()
        }
        if (i > 0) {
            i++
            consulta.cliente.trabajos[i] = {}
            consulta.cliente.trabajos[i]['tipo'] = ''
            consulta.cliente.trabajos[i]['sistema'] = ''
            consulta.cliente.trabajos[i]['nro_sistema'] = 99999
            consulta.cliente.trabajos[i]['lote'] = ''
            consulta.cliente.trabajos[i]['nro_lote'] = 0
            consulta.cliente.trabajos[i]['clave_sueldo'] = ''
            consulta.cliente.trabajos[i]['nro_docu'] = nro_docu
            consulta.cliente.trabajos[i]['nombre'] = 'Seleccionar otro mercado...'
            consulta.cliente.trabajos[i]['disponible'] = -1
            consulta.cliente.trabajos[i]['fecha_actualizacion'] = ''
            consulta.cliente.trabajos[i]['nro_grupo'] = 0
            consulta.cliente.trabajos[i]['grupo'] = ''
            consulta.cliente.trabajos[i]['id_origen'] = ''

            //-----------------------------------------------------------------
            consulta.cliente.trabajos[i]['scu_id'] = -1
            consulta.cliente.trabajos[i]['sce_id'] = -1
            consulta.cliente.trabajos[i]['premotor'] = null
            consulta.cliente.trabajos[i]['tipo_lote'] = ''
        }

        //(permisos_precarga & 4) > 0
        if (nvFW.tienePermiso("permisos_precarga", 2))
            //$('divNotiR').show()
            //$('tbResultado').show()
            if (i == 0) {
                $('divMostrarTrabajos').innerHTML = ''
                var strHTML = ""
                strHTML += "<table class='tb1' cellspacing='5' cellpadding='1'>"
                strHTML += "<tr><td class='Tit1' colspan='2' style='text-align:center'><b>Seleccione el mercado para continuar.<b></td></tr>"
                strHTML += "<tr><td style='width:100%'>"
                strHTML += "<table class='tb1' style='max-width:450px; margin:auto'><tr><td id='tdgrupos'></td><td id='divGAceptar'></td></tr></table>"
                strHTML += "</td>"
                strHTML += "</tr></table>"
                $('divMostrarTrabajos').insert({ bottom: strHTML })
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
                campos_defs.items["grupos"].input_text.ondblclick(event)
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                return
            }
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        consulta.trabajos_dibujar()

    }
    rs.open({ filtroXML: nvFW.pageContents["trabajo"], params: "<criterio><params nro_docu='" + consulta.cliente.nro_docu + "' /></criterio>" })


    //var onError = function () { nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga') }
    //var nro_docu = $('nro_docu1').value
    //Persona_buscar(nro_docu, tipo, onSusses, onError)
}


consulta.trabajos_dibujar = function () {
    $('divMostrarTrabajos').innerHTML = ''

    let strHTML = "";
    strHTML += '<div style="color: black; text-align: center;">';
    //Div datos personales
    strHTML += '<div><b>' + consulta.cliente.razon_social + '</b></div>';
    strHTML += '<div>DNI: ' + consulta.cliente.nro_docu + '</div>';
    strHTML += '</div>';

    let valtrabajo = [];
    let vBtntrabajoItems = {}
    let checked = 'checked';
    for (var x in consulta.cliente.trabajos) {
        const trab = this.cliente.trabajos[x];
        if (trab['nro_sistema'] == 99999) {
            //ver figma
            let nro_sistema = 99999;
        } else {
            //criterio de santa fe arbitrario
            const found = valtrabajo.find(element => element.tipo === trab.tipo && element.sistema === trab.sistema && element.lote === trab.lote);
            if (!found) {
                vBtntrabajoItems[x] = {}
                vBtntrabajoItems[x]["nombre"] = "BtnPremotor" + x;
                vBtntrabajoItems[x]["etiqueta"] = "Consultar";
                vBtntrabajoItems[x]["imagen"] = "";
                vBtntrabajoItems[x]["onclick"] = "return consulta.consultar_cupo(" + trab.nro_docu + "," + trab.cuit + "," + trab.sce_id + "," + trab.clave_sueldo + ", " + x + ", trabajo_dibujar_cupo)";
                vBtntrabajoItems[x]["estilo"] = "I";

                // onclick="return consulta.cobro_seleccionar(' + x + ')"
                strHTML += '<div class="box-product">';
                strHTML += '<div style="display: flex; flex-direction: row; justify-content: space-between; align-items: center;">';
                strHTML += '<div style="display: flex; gap: 1.4em;"><input name="rdTrabajo" id="rdTrabajo' + x + '" value="' + x + '" type="radio" ' + checked + ' />';
                strHTML += '<div style="display: flex; flex-direction: column; align-items: center;"><div><b>' + trab.tipo + '</b></div><div>' + trab.sistema + ' - ' + trab.lote + '</div></div>';
                strHTML += '</div>'
                strHTML += '<div id="divTrabajoCupo' + x + '" style="color: var(--celeste); font-weight: bolder; display: none"><div>Disponible</div><div style="text-align: right;" id="trabCupoDisponible' + x + '">$ 0</div></div>';
                strHTML += '<div id="divBtnPremotor' + x + '"></div>';
                strHTML += '</div>';
                strHTML += '</div>';

                valtrabajo.push(JSON.parse('{ "tipo": "' + trab.tipo + '", "sistema": "' + trab.sistema + '", "lote": "' + trab.lote + '"}'));

                checked = '';
            }
        }
        //    if (trab['nro_sistema'] == 99999)
        //        strHTML += "<tr style='text-align:center' onclick='return Mostrar_grupos()'><td style='text-align:center' title='Seleccionar trabajo'><img class='img_button_sel' src='image/seleccionar_32.png'/></td><td>" + trab['nombre'] + "</td><td>" + trab['sistema'] + "</td><td>" + trab['clave_sueldo'] + "</td></tr>"
        //    else
        //        strHTML += "<tr style='text-align:center' onclick='return consulta.cobro_seleccionar(" + x + ")'><td style='text-align:center' title='Seleccionar trabajo'><img class='img_button_sel' src='image/seleccionar_32.png'/></td><td>" + trab['nombre'] + "</td><td>" + trab['sistema'] + " - " + trab['lote'] + "</td><td>" + trab['clave_sueldo'] + "</td></tr>"

    }

    $('divMostrarTrabajos').insert({ bottom: strHTML });

    if (Object.keys(vBtntrabajoItems).length > 0) {
        var vListTrabajoBtns = new tListButton(vBtntrabajoItems, 'vListTrabajoBtns');
        vListTrabajoBtns.MostrarListButton();
    }
}


function trabajo_dibujar_cupo(ofertas, i) {
    $('divBtnPremotor' + i).hide();
    $('divTrabajoCupo' + i).show();

    $('trabCupoDisponible' + i).innerHTML = '$' + ofertas[0].cupo_disponible;
}


consulta.resultado_mostrar = function (oferta_index) { //displayProductosMotor
   
    //var datos = motor['datos']
    //datos['rechaza_motor'] = motor['datos']['rechaza_motor'];

    consulta.oferta = consulta.resultado.ofertas[oferta_index];
    this.resultado_genera_html(oferta_index)

    //var ofertas = motor['ofertas']
    if (consulta.resultado.ofertas.length > 0) {


        $('strGrupo').innerHTML = ''
        if (consulta.cliente.trabajo.clave_sueldo != '')
            $('strGrupo').insert({ bottom: consulta.cliente.trabajo.grupo + ' (' + consulta.cliente.trabajo.clave_sueldo + ')' })
        else
            $('strGrupo').insert({ bottom: consulta.cliente.trabajo.grupo })
        $('strCobro').innerHTML = ''
        var strCobroDesc = (consulta.nro_tipo_cobro == 4) ? consulta.tipo_cobro + ' - ' + consulta.banco_cobro : consulta.tipo_cobro
        $('strCobro').insert({ bottom: strCobroDesc })


        var oferta = consulta.resultado.ofertas[oferta_index]

        //Cargar banco
        campos_defs.clear_list("banco")
        campos_defs.clear('banco')
        var rsBanco = new tRS()
        rsBanco.addField("id")
        rsBanco.addField("campo")
        rsBanco.addRecord({ id: oferta.nro_banco, campo: oferta.banco });
        campos_defs.items['banco'].rs = rsBanco
        campos_defs.habilitar("banco", true)
        campos_defs.set_first('banco')
        campos_defs.habilitar("banco", false)

        //Cargar mutual
        campos_defs.clear('mutual')
        campos_defs.clear_list("mutual")
        var rsmutual = new tRS()
        rsmutual.addField("id")
        rsmutual.addField("campo")
        rsmutual.addRecord({ id: oferta.nro_mutual, campo: oferta.mutual })
        campos_defs.items['mutual'].rs = rsmutual
        campos_defs.habilitar("mutual", true)
        campos_defs.set_first('mutual')
        campos_defs.habilitar("mutual", false)

        //Cargar Analisis
        campos_defs.clear('cbAnalisis')
        campos_defs.clear_list("cbAnalisis")
        var rsAnalisis = new tRS()
        rsAnalisis.addField("id")
        rsAnalisis.addField("campo")
        rsAnalisis.addRecord({ id: oferta.nro_analisis, campo: oferta.Analisis })
        campos_defs.items['cbAnalisis'].rs = rsAnalisis
        campos_defs.habilitar("cbAnalisis", true)
        campos_defs.set_first('cbAnalisis')
        campos_defs.habilitar("cbAnalisis", false)

        if (form1.nro_docu == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='nro_docu' />")
        form1.nro_docu.value = consulta.cliente.nro_docu
        if (form1.cuit == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='cuit' />")
        form1.cuit.value = consulta.cliente.cuit
        if (form1.nro_sistema == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='nro_sistema' />")
        form1.nro_sistema.value = consulta.cliente.trabajo.nro_sistema
        if (form1.nro_lote == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='nro_lote' />")
        form1.nro_lote.value = consulta.cliente.trabajo.nro_lote
        if (form1.importe_cuota == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='importe_cuota' />")
        form1.importe_cuota.value = 0
        if (form1.clave_sueldo == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='clave_sueldo' />")
        form1.clave_sueldo.value = consulta.resultado.clave_sueldo
        //if (form1.importe_prevision_coseguro == undefined) form1.insertAdjacentHTML('AfterBegin', "<input type='hidden' name='importe_prevision_coseguro' />")
        //form1.importe_prevision_coseguro.value = 0

        $('divProducto').show()
        //$("divAnalisis").show()

        $("divGrupo").show()
        $("divGrupoLeft").show()
        $("divGrupoRight").show()



        $('divEspacioBotonera').show()
        $('tbButtons').show()

        $('selplan').checked = true
        selplan_on_click()

        //$("divFiltros").show()
        //$("tbfiltros").show()
        //$('divFiltrosLeft').show()
        //$('divFiltrosRight').show()
        //$('divFiltros2Left').show()
        //$('divFiltros2Right').show()
        //$('divFiltros3Left').show()
        //$('divFiltros3Right').show()


        //$('divSocio').show()

        analisis.canvas = $('divAnalisisCanvas')
        analisis.canvasNoVisible = $('divAnalisisNoVisibles')


        analisis.onAfterCharge = function () {
            for (i in this.Etiquetas) {
                if (this.Etiquetas[i]['HD'] != "" && consulta.resultado.ofertas[oferta_index][this.Etiquetas[i]['HD']] != undefined) {
                    this.Etiquetas[i]['calculado'] = false
                    this.Etiquetas[i]['calculo'] = ""
                    switch (this.Etiquetas[i]['tipo_dato']) {
                        case 'B':
                            this.Etiquetas[i]['valor'] = eval(consulta.resultado.ofertas[oferta_index][this.Etiquetas[i]['HD']].toLowerCase())
                            break;
                        default:
                            this.Etiquetas[i]['valor'] = consulta.resultado.ofertas[oferta_index][this.Etiquetas[i]['HD']]
                            break;
                    }
                }
            }
            this.mostrar()
        }

        analisis.onAfterCalc = function () {
            $('haber_neto').innerHTML = this.haber_neto == undefined ? '$ 0.00' : "$ " + parseFloat(this.haber_neto).toFixed(2)

            //gjmo -> corregir cuando resuelva el analisis
            //borrar lineas siguientes

            //if (campos_defs.get_value('cbAnalisis') != 657) {
            //    let importe_max_cuota = parseFloat(this.min_etiqueta(389));
            //    importe_max_cuota += parseFloat(this.min_etiqueta(17));//this.min_etiqueta('importe_a_liberar')
            //    importe_max_cuota -= parseFloat(eval(consulta.oferta.socio_nuevo.toLowerCase()) ? consulta.oferta.importe_cs : '0');//this.min_etiqueta('importe_a_liberar')
            //    analisis.set_etiqueta(16, parseFloat(importe_max_cuota));

            //    this.cuota_maxima = importe_max_cuota;
            //}
            //****************
            $('importe_max_cuota').innerHTML = "$ " + parseFloat(!!this.cuota_maxima ? this.cuota_maxima : '0').toFixed(2)
            if (!!$('divDisponible')) {
                $('valorDisponible').innerHTML = 'DISPONIBLE $ ' + parseFloat(!!this.cuota_maxima ? this.cuota_maxima : '0').toFixed(2);
            }


            $('saldo_a_cancelar').innerHTML = objCancelaciones.totalCancelaciones == undefined ? '$ 0.00' : "$ " + parseFloat(objCancelaciones.totalCancelaciones).toFixed(2)
            let importe_en_mano = !!consulta.plan.nro_plan ? consulta.plan.importe_neto - consulta.plan.gastoscomerc : 0;
            importe_en_mano = !!objCancelaciones.totalCancelaciones ? importe_en_mano - objCancelaciones.totalCancelaciones : importe_en_mano
            $('strEnMano').innerHTML = "$ " + parseFloat(importe_en_mano).toFixed(2)

            consulta.validarPlan();

        }

        analisis.cargar(oferta.nro_analisis, oferta.nro_banco)

        //consulta.resultado_mostrar_comentado();

    }
    //nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    //si no fue rechazado o si el rechazo no viene del motor, sino que por otro camino, cargo la pantalla
    return
    if (this.resultado['rechaza_motor'] == 0) {
        Control_socio()
    } else {
        consulta.limpiar()
        //Precarga_Limpiar()
        //var limpiaronclose = true
        //VerCDA(limpiaronclose)
    }
}//displayProductosMotor


consulta.validarPlan = function () {
    if (!!consulta.plan.nro_plan) {
        let objValid = validarPlan(consulta.cliente.trabajo.nro_grupo, consulta.plan.nro_plan);
        if (!objValid.valido) {
            //alert(objValid.mensaje);
            planes_limpiar();
            //Cargar nueva configuracion de planes
            //ver que pasa cuando hago check en todas las cancelaciones
            btnBuscarPLanes_onclick();
        }
    }
}


//consulta.dibujar_dictamen = function () {
//    let dictamen = consulta.resultado.dictamen.toUpperCase()

//    $('strDictamen').innerHTML = ''
//    $('strDictamen').insert({ bottom: objDictamen[dictamen] })
//    $('strDictamen').removeClassName($('strDictamen').className)
//    switch (dictamen) {
//        case 'APROBADO':
//            $('strDictamen').addClassName('cdaAC')
//            break;
//        case 'OBSERVADO':
//            $('strDictamen').addClassName('cdaOB')
//            break;
//        case 'MANUAL':
//            $('strDictamen').addClassName('cdaOB')
//            break;
//        case 'RECHAZADO':
//            $('strDictamen').addClassName('cdaRC')
//            break;
//        case 'RECHAZAR':
//            $('strDictamen').addClassName('cdaRC')
//            break;
//    }
//}


consulta.dibujar_dictamen = function () {
    let dictamen = consulta.resultado.dictamen.toUpperCase();

    let strHTML = '<div id="divDictamen" ';
    switch (dictamen) {
        case 'APROBADO':
            strHTML += 'class="box-cda cdaV">';
            break;
        case 'OBSERVADO':
            strHTML += 'class="box-cda cdaAS">';
            break;
        case 'MANUAL':
            strHTML += 'class="box-cda cdaAS">';
            break;
        case 'RECHAZADO':
            strHTML += 'class="box-cda cdaR">';
            break;
        case 'RECHAZAR':
            strHTML += 'class="box-cda cdaR">';
            break;
    }
    strHTML += '<div>' + objDictamen[dictamen].toUpperCase() + '</div>';

    let mensaje = '<b>' + objDictamen[dictamen].toUpperCase() + '</b>';
    mensaje += '</br>' + (objDictamen[dictamen].toUpperCase() == 'VIABLE' ? '¡Vas bien!' : consulta.resultado.mensaje_usuario.replace(/\|/g, '</br>'));
    strHTML += '<div onclick="alert(\'' + mensaje + '\')">Ver detalle ></div>';
    strHTML += '</div>';

    return strHTML;

}


consulta.resultado_genera_html = function (oferta_index) {
    this.resultado.strHTML_CDA = ""
    this.resultado.strHTML_CDA_noti = ""

    if (oferta_index == undefined) oferta_index = 0
    //cupo_disponible = (datos['trabajo']['disponible'] == -1 || datos['es_poder_judicial']==1) ? 0 : parseFloat(datos['trabajo']['disponible']).toFixed(2)
    //cupo_disponible = (consulta.resultado.trabajo.disponible == -1 || consulta.resultado['es_poder_judicial'] == 1) ? 0 : parseFloat(motor.get('disponible')).toFixed(2)
    //tiene_cupo = (consulta.resultado.trabajo['disponible'] == -1) ? false : true
    var nosis_cda = (consulta.resultado['nosis_cda'] == undefined) ? 'No existen productos para la combinación seleccionada.' : consulta.resultado['nosis_cda'] + ' - ' + consulta.resultado['nosis_cda_desc']
    var nosis_cda_log = (consulta.resultado['nosis_cda'] == undefined) ? '' : consulta.resultado['nosis_cda']
    var str_edad = (consulta.resultado['control_edad'] == 1) ? '<td style="color:#008000"><b>Cumple</b></td>' : '<td style="color:#800000"><b>No Cumple</b></td>'
    var str_ent_exc = (consulta.resultado['ent_excluidas'] == 0) ? '<td style="color:#008000;text-align:right"><b>' + consulta.resultado['ent_excluidas'] + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + consulta.resultado['ent_excluidas'] + ' *</b></td>'
    var str_ch_rech = (consulta.resultado['ch_rechazados'] == 0) ? '<td style="color:#008000;text-align:right"><b>' + consulta.resultado['ch_rechazados'] + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + consulta.resultado['ch_rechazados'] + '</b></td>'
    //dictamen = (rsN.getdata("nosis_cda") != null) ? 'APROBADO' : 'RECHAZADO'
    let dictamen = consulta.resultado['dictamen'].toUpperCase()
    var strHTML_CDA = ""
    var strHTML_CDA_noti = ""

    strHTML_CDA += '<table class="tb1">'
    strHTML_CDA_noti += '<table>'

    var dct_style = ''
    switch (dictamen) {
        case 'APROBADO':
            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#008000 !important'
            break;
        case 'OBSERVADO':
            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#ffd800 !important'
            break;
        case 'MANUAL':
            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#ffd800 !important'
            break;
        case 'RECHAZADO':
            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#800000 !important'
            break;
        case 'RECHAZAR':
            dct_style = 'width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px;color:#800000 !important'
            break;
    }


    strHTML_CDA += '<tr><td style="' + dct_style + '"><b>' + objDictamen[dictamen] + '</b></td></tr>'
    var strHTMLMensaje = ""
    if (consulta.resultado['mensaje_usuario'] != "") {
        strHTMLMensaje = "<b>OBSERVACIONES</b><br/>" + consulta.resultado['mensaje_usuario'].replace("|", "<br/>")
    } else {
        strHTMLMensaje = "<b></b>"
    }
    strHTML_CDA += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px">' + strHTMLMensaje + '</td></tr></table>'

    strHTML_CDA_noti += '<tr><td style="' + dct_style + '"><b>' + objDictamen[dictamen] + '</b></td></tr>'
    strHTML_CDA_noti += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px"><b>' + consulta.resultado['mensaje_usuario'] + '</b></td></tr></table>'
    strHTML_CDA_noti += '<table style="font-family: Verdana,Arial,Sans-serif;font-size: 12px"><tr><td><b>CUIT/CUIL:</b></td><td style="text-align:left">' + consulta.cliente.cuit + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Nombre:</b></td><td>' + consulta.cliente.razon_social.trim() + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Cobro:</b></td><td>' + consulta.resultado['tipo_cobro'] + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Grupo:</b></td><td>' + consulta.cliente.trabajo.grupo + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Edad:</b></td>' + str_edad + '</tr>'
    strHTML_CDA_noti += '<tr><td><b>Ent. Excluyentes:</b></td>' + str_ent_exc + '</tr>'
    strHTML_CDA_noti += '<tr><td><b>Cheques Rech.:</b></td>' + str_ch_rech + '</tr></table>'

    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">CUIT/CUIL</td><td class="Tit1">Nombre</td></tr>'
    strHTML_CDA += '<tr><td style="text-align:left">' + consulta.cliente.cuit + '</td><td>' + consulta.cliente.razon_social + '</td></tr></table>'
    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">Cobro</td><td class="Tit1">Grupo</td></tr>'
    strHTML_CDA += '<td>' + consulta.resultado['tipo_cobro'] + '</td><td>' + consulta.cliente.trabajo.grupo + '</td></tr></table>'
    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1" style="width:30%">Edad</td><td class="Tit1" style="width:30%">Ent. Excluyentes</td><td class="Tit1">Cheques Rech.</td></tr>'
    strHTML_CDA += str_edad + str_ent_exc + str_ch_rech + '</tr></table>'
    strHTML_CDA += '</tr></table>'

    //codigo en  lo que respecta BCRA, siempre y cuando el rechazo no haya venido del motor 1538 porque si esto es asi, no muestra nada
    let rechaza_motor = consulta.resultado.evalua_motor == 1 && (consulta.resultado.dictamen.toUpperCase() == "RECHAZADO" || consulta.resultado.dictamen.toUpperCase() == "RECHAZAR")
    if (rechaza_motor != 1) {
        strHTML_CDA += '<br><table style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base {fecha_info}</td><td>Sit.</td><td></td></tr>'
        strHTML_CDA += '{tr_body_bcra}<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'
        strHTML_CDA += '</table>'
        strHTML_CDA_noti += '<br><table style="width:60%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base {fecha_info}</td><td>Sit.</td><td></td></tr>'
        strHTML_CDA_noti += '{tr_body_bcra}<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'
        strHTML_CDA_noti += '</table>'
        var arHTML = {}
        arHTML['strHTML_CDA'] = {}
        arHTML['strHTML_CDA_noti'] = {}
        arHTML['strHTML_CDA']['html'] = strHTML_CDA
        arHTML['strHTML_CDA_noti']['html'] = strHTML_CDA_noti
        //agrego el cuerpo de la consulta a la bd del bcra
        arHTML = BCRABodyHTML(consulta.cliente.cuit, consulta.cliente.trabajo.nro_grupo, consulta.nro_tipo_cobro, consulta.nro_banco_cobro, arHTML)
        strHTML_CDA = arHTML['strHTML_CDA']['html']
        strHTML_CDA_noti = arHTML['strHTML_CDA_noti']['html']

        nro_banco = consulta.resultado['nro_entidad_cda']
        CDA = consulta.resultado['nosis_cda']
        //campos_defs.habilitar('nro_tipo_cobro_precarga', true)
        //campos_defs.set_value('nro_tipo_cobro_precarga', consulta.nro_tipo_cobro)
        //campos_defs.habilitar('nro_tipo_cobro_precarga', false)
        $('divGrupo').show()
        $('strGrupo').innerHTML = ''
        if (consulta.cliente.trabajo.clave_sueldo != '')
            $('strGrupo').insert({ bottom: consulta.cliente.trabajo.grupo + ' (' + consulta.cliente.trabajo.clave_sueldo + ')' })
        else
            $('strGrupo').insert({ bottom: consulta.cliente.trabajo.grupo })
        $('strCobro').innerHTML = ''
        var strCobroDesc = (consulta.nro_tipo_cobro == 4) ? consulta.tipo_cobro + ' - ' + consulta.banco_cobro : consulta.tipo_cobro
        $('strCobro').insert({ bottom: strCobroDesc })
    }

    this.resultado.strHTML_CDA = strHTML_CDA
    this.resultado.strHTML_CDA_noti = strHTML_CDA_noti
}


consulta.cargar_oferta = function () {

    $('divOfertaResp').innerHTML = '';

    let strHTML = '';
    strHTML += '<div id="divDatosSocio" style="color: black; text-align: center;">';
    //Div datos personales
    strHTML += '<div><b>' + consulta.cliente.razon_social + '</b></div>';
    strHTML += '<div>DNI: ' + consulta.cliente.nro_docu + '</div>';
    strHTML += '</div>';
    //Div dictamen
    strHTML += consulta.dibujar_dictamen();
    //Div Cancelaciones
    //Cargar total cancelaciones
    strHTML += '<div id="divCTotales" class="box-product" style="text-align: center;"></div>';
    //strHTML += objCancelaciones.dibujar_totales();
    
    strHTML += '<div class="box-product" id="divDisponible"><span id="valorDisponible" style="color: var(--celeste);">DISPONIBLE $ ' + parseFloat(!!analisis.cuota_maxima ? analisis.cuota_maxima : '0').toFixed(2) + '</span>';
    //Analisis
    strHTML += '<div id="divAnalisisCanvas" style="display: none"></div>'
    strHTML += '<div id="divAnalisisNoVisibles" style="display: none"></div>'
    strHTML += '<span><a onclick="return analisis.canvas_mostrar()" href="javascript:;">Ver</a></span>'
    strHTML += '</div>';
    //strHTML += dibujar_propuesta_maxima(this.cliente.trabajo.nro_grupo, 'divPropuestaMaxima');
    //Div Plan maximo
    strHTML += '<div class="box-product" id="divPropuestaMaxima"></div>'

    strHTML += '</div>'

    $('divOfertaResp').innerHTML = strHTML;

    //cargar campo_def oferta - se mantiene por compatibilidad - refactorizar en boxes propuestas
    consulta.cargar_campo_oferta();
    //Cargar cancelaciones
    objCancelaciones.actualizar(consulta.cliente.nro_docu, consulta.cliente.tipo_docu, consulta.cliente.sexo, 3);
    //Cargar planes
    btnBuscarPLanes_onclick();

    //mover a onresize
    //$('divOfertaResp').setStyle({
    //    height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnOferta").getHeight() + 'px'
    //});
    //$('divPlanes').setStyle({ height: $$('body')[0].getHeight() - $("top_menu").getHeight() - $("divVendedorLeft").getHeight() - $("divWizardWrapper").getHeight() - $("divBtnOferta").getHeight() + 'px' });

    //propuesta maxima es el plan mayor?

}


//por compatibilidad
consulta.cargar_campo_oferta = function () {
    //Cargar campo_def oferta
    campos_defs.clear_list("cdef_oferta")
    campos_defs.clear('cdef_oferta')
    campos_defs.items.cdef_oferta.onchange = function (e, campo_def) {
        //checkAllCancelaciones(1);
        objCancelaciones.checkAllCrd(false);
        planes_limpiar();
        if (campos_defs.get_value(campo_def) != '')
            consulta.resultado_mostrar(campos_defs.items.cdef_oferta.input_select.selectedIndex);
    }
    var rsOferta = new tRS()
    rsOferta.addField("id")
    rsOferta.addField("campo")
    rsOferta.addField("oferta")

    for (var i = 0; i < consulta.resultado['ofertas'].length; i++) {
        //Mock analisis -> borrar
        switch (consulta.resultado['ofertas'][i].nro_analisis) {
            case '611':
                consulta.resultado['ofertas'][i].nro_analisis = 657;
                break;
            case '612':
                consulta.resultado['ofertas'][i].nro_analisis = 661;
                break;
            case '592':
                consulta.resultado['ofertas'][i].nro_analisis = 662;
                break;
            case '593':
                consulta.resultado['ofertas'][i].nro_analisis = 664;
                break;
        }

        rsOferta.addRecord({ id: i, campo: consulta.resultado['ofertas'][i].banco + ' - ' + consulta.resultado['ofertas'][i].mutual + ' - ' + consulta.resultado['ofertas'][i].Analisis + ' (' + consulta.resultado['ofertas'][i].nro_analisis + ')' });
    }
    campos_defs.items['cdef_oferta'].rs = rsOferta
    campos_defs.set_first('cdef_oferta')

    $('divFlujoViejo').hide();
}


//############################################
//##########-------NO SE USAN-------##########
//############################################

consulta.evaluar2 = function () {

    ofertas = new Array()

    var oXML = new tXML();
    oXML.async = true
    oXML.method = 'POST'
    oXML.intervalID = null;
    oXML.onUploadProgress = function () {
        msg_waitingcupo()
        oXML.intervalID = setInterval(msg_waitingcupo, 5000);
    }
    oXML.onComplete = function () {

        clearInterval(oXML.intervalID);
        strXML = XMLtoString(oXML.xml)

        //Scu_Id:=2, Sce_Id:=7, Scm_Id:=2, Clave_Sueldo:="27272675142"
        // strXML='<?xml version="1.0" encoding="ISO-8859-1"?><error_mensajes><error_mensaje numError="0"><titulo/><mensaje/><debug_src/><debug_desc/><params><dictamen>Aprobado</dictamen><mensaje_usuario>asdasdsad</mensaje_usuario><bcra_sit_financiera>1</bcra_sit_financiera><bcra_calificacion_cendeu>OK</bcra_calificacion_cendeu><cant_sit_juridica>0</cant_sit_juridica><ch_rechazados>0</ch_rechazados><control_edad>1</control_edad><nro_grupo>1</nro_grupo><grupo>Santa Fe - Activos centralizados</grupo><nro_tipo_cobro>1</nro_tipo_cobro><tipo_cobro>Descuento de haberes</tipo_cobro><ent_excluidas>0</ent_excluidas><nosis_cda>2086068</nosis_cda><nosis_cda_desc>VOII - Orig cuenta y orden version 3</nosis_cda_desc><motivo/><nro_entidad_cda>800</nro_entidad_cda><clave_sueldo>27272675142</clave_sueldo><sueldo_bruto>104505.84</sueldo_bruto><desc_ley>0</desc_ley><sueldo_neto>62546.65</sueldo_neto><cupo_disponible>16334.99</cupo_disponible><id_transf_log>2035131</id_transf_log><nro_motor_decision>1538</nro_motor_decision><rechaza_motor>0</rechaza_motor><evalua_motor>1</evalua_motor><socio_nuevo>1</socio_nuevo><Scu_Id>2</Scu_Id><Sce_Id>7</Sce_Id><Scm_Id>2</Scm_Id><strXML>&lt;xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema"&gt;&lt;s:Schema id="RowsetSchema"&gt;&lt;s:ElementType name="row" content="eltOnly"&gt;&lt;s:AttributeType name="nro_banco" rs:number="1" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_mutual" rs:number="2" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="estado" rs:number="3" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="string" rs:dbtype="str" dt:maxLength="4294967295" rs:long="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="cuota_maxima" rs:number="4" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="neto_maximo" rs:number="5" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="max_cuotas" rs:number="6" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="id_origen" rs:number="7" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_analisis" rs:number="8" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:extends type="rs:rowbase" /&gt;&lt;/s:ElementType&gt;&lt;/s:Schema&gt;&lt;rs:data&gt;&lt;z:row nro_banco="800" nro_mutual="55" estado="A" cuota_maxima="16334.99" neto_maximo="600000" max_cuotas="36" id_origen="10601" nro_analisis="585" /&gt;&lt;z:row nro_banco="170" nro_mutual="55" estado="A" cuota_maxima="16334.99" neto_maximo="800000" max_cuotas="36" id_origen="10601" nro_analisis="584" /&gt;&lt;/rs:data&gt;&lt;params vista="#tmp_respuesta" timeout="0" PageSize="0" AbsolutePage="0" recordcount="2" PageCount="1" cacheControl="none" cache="False" /&gt;&lt;/xml&gt;</strXML></params></error_mensaje></error_mensajes>'
        //strXML='<?xml version="1.0" encoding="ISO-8859-1"?><error_mensajes><error_mensaje numError="0"><titulo /><mensaje /><debug_src /><debug_desc /><params><dictamen>Aprobado</dictamen><mensaje_usuario></mensaje_usuario><bcra_sit_financiera>1</bcra_sit_financiera><cant_sit_juridica>0</cant_sit_juridica><ch_rechazados>0</ch_rechazados><control_edad>1</control_edad><nro_grupo>1</nro_grupo><grupo>Santa Fe - Activos centralizados</grupo><nro_tipo_cobro>1</nro_tipo_cobro><tipo_cobro>Descuento de haberes</tipo_cobro><ent_excluidas>0</ent_excluidas><nosis_cda>2086068</nosis_cda><nosis_cda_desc>VOII - Orig cuenta y orden version 3</nosis_cda_desc><motivo /><nro_entidad_cda>800</nro_entidad_cda><clave_sueldo>27272675142</clave_sueldo><sueldo_bruto>110051.12</sueldo_bruto><desc_ley>0</desc_ley><sueldo_neto>67988.29</sueldo_neto><cupo_disponible>25042.82</cupo_disponible><id_transf_log>2070599</id_transf_log><nro_motor_decision>1538</nro_motor_decision><bcra_calificacion_cendeu>califica VOII</bcra_calificacion_cendeu><Scu_Id>2</Scu_Id><Sce_Id>7</Sce_Id><Scm_Id>3</Scm_Id><socio_nuevo>true</socio_nuevo><rechaza_motor>0</rechaza_motor><evalua_motor>1</evalua_motor><strXML>&lt;xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema"&gt;&lt;s:Schema id="RowsetSchema"&gt;&lt;s:ElementType name="row" content="eltOnly"&gt;&lt;s:AttributeType name="nro_banco" rs:number="1" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_mutual" rs:number="2" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="estado" rs:number="3" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="string" rs:dbtype="str" dt:maxLength="4294967295" rs:long="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="cuota_maxima" rs:number="4" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="neto_maximo" rs:number="5" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="max_cuotas" rs:number="6" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="id_origen" rs:number="7" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_analisis" rs:number="8" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:extends type="rs:rowbase" /&gt;&lt;/s:ElementType&gt;&lt;/s:Schema&gt;&lt;rs:data&gt;&lt;z:row nro_banco="800" nro_mutual="55" estado="A" cuota_maxima="25042.82" neto_maximo="600000" max_cuotas="36" id_origen="10601" nro_analisis="585" /&gt;&lt;z:row nro_banco="170" nro_mutual="55" estado="A" cuota_maxima="25042.82" neto_maximo="800000" max_cuotas="36" id_origen="10601" nro_analisis="584" /&gt;&lt;/rs:data&gt;&lt;params vista="#tmp_respuesta" timeout="0" PageSize="0" AbsolutePage="0" recordcount="2" PageCount="1" cacheControl="none" cache="False" /&gt;&lt;/xml&gt;</strXML></params></error_mensaje></error_mensajes>'
        /*NosisXML = strXML*/
        objXML = new tXML();
        objXML.async = false
        $("divHaberes").show();
        if (objXML.loadXML(strXML)) {
            var error_mensaje = objXML.selectSingleNode("error_mensajes/error_mensaje")
            var numError = error_mensaje.getAttribute("numError")
            if (numError == 0) {
                var datos = {}
                //datos['trabajo'] = this.cliente.trabajo
                //datos['nro_vendedor'] = this.nro_vendedor
                //datos['nro_banco_cobro'] = this.nro_banco_cobro
                //datos['nro_grupo'] = this.cliente.trabajo.nro_grupo
                var params = objXML.selectSingleNode("error_mensajes/error_mensaje/params")
                for (n = 0; n < params.childNodes.length; n++) {
                    datos[params.childNodes[n].nodeName] = (params.childNodes[n].innerHTML).replace(/&lt;/g, "<").replace(/&gt;/g, ">")
                    //console.log("parametro "+params.childNodes[n].nodeName+" valor "+params.childNodes[n].innerHTML)
                }
                if (datos['bcra_sit']) {
                    consulta.sit_bcra = datos["bcra_sit"]
                }

                datos.trabajo = consulta.cliente.trabajo
                consulta.resultado = datos

                //motor['datos'] = datos;

                if (datos['evalua_motor'] == 1) {
                    if ((nvFW.tienePermiso("permisos_precarga", 14) || consulta.resultado.es_poder_judicial == '1') > 0) { //permisos_precarga & 16384
                        $("divHaberes").show();
                    } else {
                        $("divHaberes").hide();
                    }
                    $("btn1").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].hide() //oculto el boton pendiente
                    $("btn2").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].setStyle({ width: "50%" }) //oculto el boton pendiente

                    $("span_criterio").update("Ver informes")
                    var xmlText = objXML.selectSingleNode("error_mensajes/error_mensaje/params/strXML").innerHTML
                    ofertas = rsdataToArray(xmlText) //obtengo las filas del xml data en forma de array
                    //ofertas=ofertas.filter(that=>that.estado!=null && that=>that.estado!="") //saco los elementos que no tienen estado
                    ofertas = ofertas.filter(that => (that.estado != undefined) && (that.estado != ""));
                    motor['ofertas'] = ofertas;
                    consulta.resultado_mostrar()
                } else {
                    $("span_criterio").update("CDA")
                    displayProductosPrecargaCDA(trabajo)
                }

            } else {
                var mensaje = objXML.selectSingleNode("error_mensajes/error_mensaje/mensaje").innerHTML
                //rserror_handler(mensaje)
                Dialog.confirm(mensaje + "<br/> ¿Probamos otra vez?",
                    {
                        width: 300,
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (w) {
                            w.close();
                            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga');
                            consulta.evaluar()
                            return
                        },
                        onCancel: function (w) {
                            w.close();
                        }
                    });//dialog



            }// else error
        }
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')

    }//oncomplete
    oXML.onFailure = function () {
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        clearInterval(oXML.intervalID);
        rserror_handler("Error al consultar los datos. Intente nuevamente.")
    }
    /*luego poner en accion=precarga_motor*/
    var clave_sueldo = consulta.cliente.trabajo.clave_sueldo
    oXML.load('/FW/servicios/ROBOTS/getXML.aspx', "accion=evaluar&criterio=<criterio><nro_vendedor>" + consulta.nro_vendedor + "</nro_vendedor><nro_grupo>" + consulta.cliente.trabajo.nro_grupo + "</nro_grupo><nro_tipo_cobro>" + consulta.nro_tipo_cobro + "</nro_tipo_cobro><nro_banco>" + consulta.nro_banco_cobro + "</nro_banco><cuit>" + consulta.cliente.cuit + "</cuit><clave_sueldo>" + consulta.cliente.trabajo.clave_sueldo + "</clave_sueldo></criterio>")

}