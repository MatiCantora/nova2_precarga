﻿
//CARGA DE CSS
let cssId = 'cssCancelaciones';
if (!document.getElementById(cssId)) {
    let head = document.getElementsByTagName('head')[0];
    let link = document.createElement('link');
    link.id = cssId;
    link.rel = 'stylesheet';
    link.type = 'text/css';
    link.href = '/precarga/css/cancelaciones.css';
    link.media = 'all';
    head.appendChild(link);
}


//Objeto con valores de cancelaciones
let objCancelaciones = {};
objCancelaciones.Creditos = [];
objCancelaciones.creditosBase = {};
objCancelaciones.creditosBase.cancelaciones = {};
objCancelaciones.creditosBase.mora = {};
objCancelaciones.totalCancelaciones = 0;
objCancelaciones.totalMora = 0;
objCancelaciones.LiberaCuota = 0;


objCancelaciones.limpiar = function () {

    consulta.cancelacion = {}
    consulta.cancelacion.cancelaciones = {};
    consulta.cancelacion.importe_cancelar = 0;
    consulta.cancelacion.totalCancelaciones = 0;
    consulta.cancelacion.LiberaCuota = 0;

    objCancelaciones.Creditos = [];
    objCancelaciones.creditosBase = {};
    objCancelaciones.creditosBase.cancelaciones = {};
    objCancelaciones.creditosBase.mora = {};
    objCancelaciones.totalCancelaciones = 0;
    objCancelaciones.totalMora = 0;
    objCancelaciones.LiberaCuota = 0;

    $('divCTotales').innerHTML = ''
}


//Cargar cancelaciones
objCancelaciones.actualizar = function (nro_docu, tipo_docu, sexo, tipo) {

    //nro_docu = 10699373;
    this.limpiar();

    //$('divSocio').show();
    nvFW.bloqueo_activar($('divCTotales'), 'blq_precarga_cs', 'Obteniendo información de saldos...')

    let objThis = this
    var rsC = new tRS();
    rsC.async = true
    rsC.onError = function (rsCS) {
        rserror_handler("Error al consultar cancelaciones. Intente nuevamente.", 'blq_precarga_cs', 'divCTotales')
    }

    rsC.onComplete = function (rsC) {

        let i = 0;
        $('divCTotales').innerHTML = objCancelaciones.dibujar_totales(rsC.recordcount);

        while (!rsC.eof()) {

            let Credito = {};

            Credito['orden_aparicion'] = i
            Credito['nro_credito'] = rsC.getdata('nro_credito')
            Credito['banco'] = rsC.getdata('banco')
            Credito['nro_banco'] = rsC.getdata('nro_banco')
            Credito['mutual'] = rsC.getdata('mutual')
            Credito['nro_mutual'] = rsC.getdata('nro_mutual')
            Credito['importe_cuota'] = (rsC.getdata('nro_calc_tipo') == 4) ? parseFloat(rsC.getdata('importe_cuota_seg')).toFixed(2) : parseFloat(rsC.getdata('importe_cuota')).toFixed(2)

            Credito['saldo'] = parseFloat(rsC.getdata('saldo_importe')).toFixed(2)
            Credito['saldo_importe'] = parseFloat(rsC.getdata('saldo_importe')).toFixed(2)
            Credito['saldo_nro_entidad'] = rsC.getdata('saldo_entidad')
            Credito['cancela_vence'] = FechaToSTR(new Date(parseFecha(rsC.getdata('saldo_vencimiento'))))
            Credito['cancela_cuota_paga'] = rsC.getdata('cuotas_pagadas')
            Credito['nro_credito_seguro'] = rsC.getdata('nro_credito_seguro')
            Credito['nro_calc_tipo'] = rsC.getdata('nro_calc_tipo')
            if (rsC.getdata('nro_calc_tipo') == '3')
                Credito['tipo'] = 'mora';
            else Credito['tipo'] = 'cancelacion';
            Credito['cancela'] = false
            //----------
            Credito['nro_pago_concepto'] = rsC.getdata('nro_credito_origen')
            Credito['tipo_cobro'] = rsC.getdata('tipo_cobro')
            Credito['nro_tipo_cobro'] = rsC.getdata('nro_tipo_cobro')
            Credito['porcentaje'] = parseInt(rsC.getdata('porcentaje'))

            Credito['nro_sistema'] = parseInt(rsC.getdata('nro_sistema'))
            Credito['nro_lote'] = parseInt(rsC.getdata('nro_lote'))
            Credito['tipo_lote'] = rsC.getdata('tipo_lote')
            Credito['clave_sueldo'] = parseInt(rsC.getdata('clave_sueldo'))
            Credito['nro_credito_origen'] = rsC.getdata('nro_credito_origen')
            Credito['level'] = 0
            Credito['relacionados'] = []
            Credito['liberaCuota'] = false

            objThis.Creditos.push(Credito)

            if (Credito.tipo == 'mora')
                objThis.creditosBase.mora[Credito['nro_credito']] = Credito
            else objThis.creditosBase.cancelaciones[Credito['nro_credito']] = Credito

            i++;
            rsC.movenext()
        }

        //--------------------

        if (rsC.recordcount > 0) {
            objThis.relacionar();
            objThis.Creditos.sort((a, b) => b.porcentaje - a.porcentaje);
            objThis.dibujar();

            if (!$('rdCheckAllMora').disabled) {
                $('rdCheckAllMora').checked = true;
                $('rdCheckAllMora').onclick();
            }
            //if (tipo != 1)
            //    checkAllCancelaciones(tipo);
        }
        $('divFlujoViejo').hide();
        nvFW.bloqueo_desactivar($('divCTotales'), 'blq_precarga_cs')
    }

    let filtro_calc_tipos = consulta.resultado.tiene_mora == '1' ? '1,3,4' : '1,4';
    rsC.open({ filtroXML: nvFW.pageContents["saldos"], params: "<criterio><params nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' nro_calc_tipos='" + filtro_calc_tipos + "' /></criterio>" })
    //SeleccionarPlanesMostrar()
}


//######################################
//#######---Dibujar apartado-----#######
//######################################


//Dibujar totalizadores
objCancelaciones.dibujar_totales = function (cant) {
    let strHTML = '';
    //Div contenedor
    //strHTML += '<div id="divCTotales" class="box-product" style="text-align: center;">';
    //Div cancelaciones
    if (cant == 0)
        strHTML += '<div id="divCMensaje" style="text-align: center;"><b>El socio no posee cancelaciones.</b></div>';
    else {
        strHTML += '<div id="tbCredVigente" style="overflow-y: auto; max-height: 270px; display: none"></div>';
        //Div agrupador
        strHTML += '<div style="display: flex; justify-content: space-evenly;">';
        strHTML += '<div id="divcTotlaMora">Total mora: <span id="cTotlaMora">$0</span></div>';
        strHTML += '<div id="divcCuotaLiberada">Cuota liberada: <span id="cCuotaLiberada">$0</span></div>';
        strHTML += '</div>';
        //Div saldo a cancelar
        strHTML += '<div id="divcSaldoCancelar">Saldo a cancelar: <span id="cSaldoCancelar">$0</span></div>'
        //Div mostrar cancelaciones
        strHTML += '<div style="font-size: 1em" onclick="objCancelaciones.mostrarDivCancelaciones()"><a id="linkRefinanciar" href="javascript:;">Refinanciar</a></div>'
    }

    //strHTML += '</div>';

    return strHTML;
}


//Dibujar cancelaciones y mora
objCancelaciones.dibujar = function () {

    let columnasCancelaciones = {
        titulo: [
            { class: '', type: 'checkbox', desc: '', style: '', funcion: 'objCancelaciones.checkAllCrd()', id: 'checkAllCreditos', name: '', disabled: false },
            { class: '', type: 'titulo', desc: 'Crédito', style: '' },
            { class: '', type: 'titulo', desc: 'Banco', style: '' },
            { class: '', type: 'titulo', desc: 'Mutual', style: '' },
            { class: '', type: 'radio', desc: 'Mora', style: '', funcion: 'objCancelaciones.rdCheckAll(\'mora\')', id: 'rdCheckAllMora', name: 'rdCheckAll', disabled: true, spanStyle: 'float: right;' },
            { class: '', type: 'radio', desc: 'Saldo', style: '', funcion: 'objCancelaciones.rdCheckAll(\'cancelacion\')', id: 'rdCheckAllCancelaciones', name: 'rdCheckAll', disabled: true, spanStyle: 'float: right;' }
        ],
        detalle: [
            { class: '', type: 'checkbox', det: '', style: 'text-align: center;', funcion: 'objCancelaciones.mostrarCancelacion(%nro_credito%)', id: 'checkCr', name: '', disabled: false },
            { class: '', type: 'detalle', det: 'nro_credito', style: 'text-align: right;' },
            { class: '', type: 'detalle', det: 'banco', style: '' },
            { class: '', type: 'detalle', det: 'mutual', style: '' },
            { class: '', type: 'detalle', desc: '<span style="float: left">$</span> 0.00', det: '', style: 'text-align: right;', funcion: '', id: 'SaldoMora', name: '' },
            { class: '', type: 'detalle', desc: '<span style="float: left">$</span> 0.00', det: '', style: 'text-align: right;', funcion: '', id: 'SaldoCancelacion', name: '' }
        ],
        detalleHidden: [
            { class: '', type: 'detalle', det: '', style: '', funcion: '', id: '', name: '', disabled: false },
            { class: '', type: 'detalle', det: 'tipo_cobro', style: '', funcion: '', id: '', name: '', disabled: false },
            { class: '', type: 'detalle', det: '', style: '', funcion: '', id: 'Cuota', name: '', disabled: false, colSpan: '2' },
            { class: '', type: 'radio', desc: '', det: '', style: 'text-align: right;', funcion: '', id: 'rdCheckMora', name: 'rdCheckCancelacion', disabled: true },
            { class: '', type: 'radio', desc: '', det: '', style: 'text-align: right;', funcion: '', id: 'rdCheckCancelacion', name: 'rdCheckCancelacion', disabled: true }
        ]
    };

    let divCancelaciones = document.getElementById('tbCredVigente');

    //Crear tabla
    let tablaCancelaciones = document.createElement("table");
    tablaCancelaciones.id = 'tbCred';
    tablaCancelaciones.className = 'tb1 tableFixHead';
    divCancelaciones.appendChild(tablaCancelaciones);

    //Crear cabecera
    let theadCancelaciones = document.createElement("thead");
    tablaCancelaciones.appendChild(theadCancelaciones);

    let trHeadCancelaciones = document.createElement("tr");
    //trHeadCancelaciones.className = 'tbLabel';
    theadCancelaciones.appendChild(trHeadCancelaciones);

    this.dibujarTR(columnasCancelaciones.titulo, 'th', trHeadCancelaciones);

    //Crear detalle
    let tbodyCancelaciones = document.createElement("tbody");
    tablaCancelaciones.appendChild(tbodyCancelaciones);

    for (let j = 0; j < this.Creditos.length; j++) {

        let creditoActual = this.Creditos[j];
        this.Creditos[j].orden_aparicion = j;

        if (!$('trCredito' + creditoActual.nro_credito)) {
            let trBodyCancelaciones = document.createElement("tr");
            trBodyCancelaciones.id = 'trCredito' + creditoActual.nro_credito;
            tbodyCancelaciones.appendChild(trBodyCancelaciones);

            //Dibujar columnas
            this.dibujarTR(columnasCancelaciones.detalle, 'td', trBodyCancelaciones, creditoActual);

            let trHiddenCancelaciones = document.createElement("tr");
            trHiddenCancelaciones.id = 'trCreditoHidden' + creditoActual.nro_credito;
            trHiddenCancelaciones.style.display = 'none';
            tbodyCancelaciones.appendChild(trHiddenCancelaciones);

            this.dibujarTR(columnasCancelaciones.detalleHidden, 'td', trHiddenCancelaciones, creditoActual);
        }

        //Cargar datos dependiendo el tipo
        switch (creditoActual['tipo']) {
            case 'cancelacion':
                $('rdCheckAllCancelaciones').disabled = false;
                $('rdCheckCancelacion' + creditoActual.nro_credito).disabled = false;
                $('rdCheckCancelacion' + creditoActual.nro_credito).onclick = function () { objCancelaciones.btnCancela_onClick(creditoActual.nro_credito, creditoActual.orden_aparicion, true) };
                $('tdSaldoCancelacion' + creditoActual.nro_credito).innerHTML = '<span style="float: left">$</span> ' + creditoActual['saldo_importe'];
                this.valLiberaCuota(creditoActual)
                break;
            case 'mora':
                $('rdCheckAllMora').disabled = false;
                $('rdCheckMora' + creditoActual.nro_credito).disabled = false;
                $('rdCheckMora' + creditoActual.nro_credito).onclick = function () { objCancelaciones.btnCancela_onClick(creditoActual.nro_credito, creditoActual.orden_aparicion, true) };
                $('tdSaldoMora' + creditoActual.nro_credito).innerHTML = '<span style="float: left">$</span> ' + creditoActual['saldo_importe'];
                break
        }
    }
}


objCancelaciones.dibujarTR = function (objColumnas, columnaTipo, trElement, creditoActual) {

    let nro_credito_actual = !!creditoActual ? creditoActual.nro_credito : '';

    objColumnas.forEach((element) => {
        let columnElement = document.createElement(columnaTipo);
        if (!!element.id)
            columnElement.id = 'td' + element.id + nro_credito_actual;

        let desc = !!element.desc ? element.desc : '';
        desc += !!element.det ? creditoActual[element.det] : '';
        columnElement.innerHTML = desc;

        if (element.type != 'detalle' && element.type != 'titulo') {
            let spanInput = document.createElement('span');
            spanInput.style.cssText = !!element.spanStyle ? element.spanStyle : '';

            let columnInput = document.createElement('input');
            columnInput.type = element.type
            if (!!element.funcion)
                columnInput.onclick = function () { eval(replace(element.funcion, '%nro_credito%', nro_credito_actual)); }; //Cambiar por expresion regular
            columnInput.id = element.id + nro_credito_actual;
            columnInput.name = element.name + nro_credito_actual;
            columnInput.disabled = element.disabled;
            spanInput.appendChild(columnInput);
            columnElement.appendChild(spanInput);
        }

        //let columnDesc = document.createTextNode(desc);
        //columnElement.appendChild(columnDesc);
        columnElement.className = element.class;
        if (!!element.colSpan)
            columnElement.colSpan = element.colSpan;
        columnElement.style.cssText = element.style;

        trElement.appendChild(columnElement);
    });
}


objCancelaciones.valLiberaCuota = function (cancelacion) {

    if (cancelacion.tipo == 'mora')
        return;

    let liberaCuota = cancelacion.nro_mutual == consulta.oferta.nro_mutual;

    switch (consulta.cliente.trabajo.scu_id + '|' + consulta.cliente.trabajo.sce_id) {
        case '2|7':
            liberaCuota = liberaCuota && consulta.cliente.trabajo.tipo_lote == cancelacion.tipo_lote
            break;
        case '2|8':
            liberaCuota = liberaCuota && consulta.cliente.trabajo.tipo_lote == cancelacion.tipo_lote;
            liberaCuota = liberaCuota && consulta.cliente.trabajo.nro_lote == cancelacion.nro_lote;
            break;
        case '8|10':
        case '8|12':
        case '8|14':
        case '8|15':
            liberaCuota = liberaCuota && consulta.cliente.trabajo.tipo_lote == cancelacion.tipo_lote;
            liberaCuota = liberaCuota && consulta.cliente.trabajo.nro_sistema == cancelacion.nro_sistema;
            break;
        case '8|11':
            liberaCuota = liberaCuota && consulta.cliente.trabajo.nro_sistema == cancelacion.nro_sistema;
            liberaCuota = liberaCuota && consulta.cliente.trabajo.nro_lote == cancelacion.nro_lote;
            liberaCuota = liberaCuota && consulta.cliente.trabajo.clave_sueldo == cancelacion.clave_sueldo;
            break;
    }

    $('tdCuota' + cancelacion.nro_credito).innerHTML = liberaCuota ? 'Cuota: $ ' + cancelacion.importe_cuota : 'No libera cuota';
    cancelacion.liberaCuota = liberaCuota;
}


//######################################
//######---SELECCION MULTIPLE-----######
//######################################


//Tildar/destildar todos los creditos
objCancelaciones.checkAllCrd = function (forceCheck) {

    if (!$('checkAllCreditos'))
        return;

    let objCreditos = objCancelaciones.Creditos;
    let checked = typeof forceCheck != 'undefined' ? forceCheck : $('checkAllCreditos').checked;

    //Destildar radios globales
    if (!checked) {
        $('rdCheckAllMora').checked = false;
        $('rdCheckAllCancelaciones').checked = false;
    }

    nvFW.bloqueo_activar($('tbCredVigente'), 'blq_cs_check_all', 'Calculando analisis...')
    setTimeout(function () {
        Object.keys(objCreditos).forEach(function (key, index) {
            let nro_credito = objCreditos[key].nro_credito
            //Si existe y su valor es distinto al global
            if (!!$('checkCr' + nro_credito) && $('checkCr' + nro_credito).checked != checked) {
                $('checkCr' + nro_credito).checked = checked;
                objCancelaciones.mostrarCancelacion(nro_credito);
            }
        });
        nvFW.bloqueo_desactivar($('tbCredVigente'), 'blq_cs_check_all')
    }, 500)

}


//Tildar todas las moras o cancelaciones
objCancelaciones.rdCheckAll = function (tipo) {
    let objCreditos = objCancelaciones.Creditos;

    nvFW.bloqueo_activar($('tbCredVigente'), 'blq_cs_check_all', 'Calculando analisis...');
    setTimeout(function () {
        Object.keys(objCreditos).forEach(function (key, index) {
            let nro_credito = objCreditos[key].nro_credito;
            let rdId = tipo == 'mora' ? 'rdCheckMora' : 'rdCheckCancelacion';

            if (objCreditos[key].tipo == tipo) {

                //Tildar checkbox
                if (!$('checkCr' + nro_credito).checked) {
                    $('checkCr' + nro_credito).checked = true;
                    $('checkCr' + nro_credito).onclick();
                }

                //Tildar radio
                if (!$(rdId + nro_credito).checked) {
                    $(rdId + nro_credito).checked = true;
                    objCancelaciones.btnCancela_onClick(nro_credito, objCreditos[key].orden_aparicion, false);
                }
            } else {
                //Si el tipo no coincide, destildar si el radio del tipo es disabled y esta tildado
                if ($(rdId + nro_credito).disabled && $('checkCr' + nro_credito).checked) {
                    $('checkCr' + nro_credito).checked = false;
                    $('checkCr' + nro_credito).onclick();
                }
            }
        });
        nvFW.bloqueo_desactivar($('tbCredVigente'), 'blq_cs_check_all');
    }, 500)
}


//######################################
//######----SELECCION SIMPLE------######
//######################################


//Cambiar vista entre cancelaciones y mora
objCancelaciones.mostrarCancelacion = function (nro_credito) {
    $('trCreditoHidden' + nro_credito).style.display = $('checkCr' + nro_credito).checked ? '' : 'none';

    //Destildar y actualizar cancelacion y mora
    if (!$('checkCr' + nro_credito).checked) {
        $('rdCheckCancelacion' + nro_credito).checked = false;
        if (typeof $('rdCheckCancelacion' + nro_credito).onclick == 'function')
            $('rdCheckCancelacion' + nro_credito).onclick();
        $('rdCheckMora' + nro_credito).checked = false;
        if (typeof $('rdCheckMora' + nro_credito).onclick == 'function')
            $('rdCheckMora' + nro_credito).onclick();
    }
}


//Chequear cancelacion/mora
objCancelaciones.btnCancela_onClick = function (nro_credito, i, destildarGlobal) {

    let Creditos = this.Creditos;

    let rdId = Creditos[i]['tipo'] == 'mora' ? 'rdCheckMora' : 'rdCheckCancelacion';
    let checkElement = rdId + nro_credito

    if ($(checkElement).checked) {
        if (!consulta.cancelacion.cancelaciones[i]) {

            if (destildarGlobal) {
                $('rdCheckAllMora').checked = false;
                $('rdCheckAllCancelaciones').checked = false;
            }

            //Agregar postergaciones
            this.postergacionAdd(nro_credito, Creditos[i]['nro_calc_tipo']);

            //Actualizar datos
            this.totalCancelaciones = parseFloat(parseFloat(this.totalCancelaciones) + parseFloat(Creditos[i]['saldo'])).toFixed(2);
            this.LiberaCuota = Creditos[i].liberaCuota ? parseFloat(parseFloat(this.LiberaCuota) + parseFloat(Creditos[i]['importe_cuota'])).toFixed(2) : parseFloat(parseFloat(this.LiberaCuota));
            this.totalMora = Creditos[i]['tipo'] == 'mora' ? parseFloat(parseFloat(this.totalMora) + parseFloat(Creditos[i]['saldo'])).toFixed(2) : parseFloat(parseFloat(this.totalMora));
            Creditos[i]['cancela'] = true

            this.actualizarDatos();

            //Quitar radio opuesto si estaba seleccionado
            let checkElement2 = Creditos[i]['tipo'] == 'mora' ? 'rdCheckCancelacion' + nro_credito : 'rdCheckMora' + nro_credito;
            if (typeof $(checkElement2).onclick == 'function')
                $(checkElement2).onclick();

            consulta.cancelacion.cancelaciones[i] = Creditos[i];
        }
    }
    else {
        //Si estaba seleccionado
        if (!!consulta.cancelacion.cancelaciones[i]) {
            //Quitar postergaciones
            this.postergacionRemove(nro_credito, Creditos[i]['nro_calc_tipo']);

            //Actualizar datos
            this.totalCancelaciones = parseFloat(parseFloat(this.totalCancelaciones) - parseFloat(Creditos[i]['saldo'])).toFixed(2);
            this.LiberaCuota = Creditos[i].liberaCuota ? parseFloat(parseFloat(this.LiberaCuota) - parseFloat(Creditos[i]['importe_cuota'])).toFixed(2) : parseFloat(parseFloat(this.LiberaCuota));
            this.totalMora = Creditos[i]['tipo'] == 'mora' ? parseFloat(parseFloat(this.totalMora) - parseFloat(Creditos[i]['saldo'])).toFixed(2) : parseFloat(parseFloat(this.totalMora));
            Creditos[i]['cancela'] = false

            delete consulta.cancelacion.cancelaciones[i];

            this.actualizarDatos();
        }
    }

    //Si tiene seguro forzar la selección
    for (var j in Creditos) {
        if (j != i) {
            if ((Creditos[j]['nro_credito_seguro'] != 0) && (Creditos[i]['nro_credito_seguro'] == Creditos[j]['nro_credito_seguro'])) {
                if (($(checkElement).checked && !consulta.cancelacion.cancelaciones[j]) || (!$(checkElement).checked && !!consulta.cancelacion.cancelaciones[j])) {
                    $(rdId + Creditos[j].nro_credito).checked = $(checkElement).checked;
                    if (typeof $(rdId + Creditos[j].nro_credito).onclick == 'function')
                        $(rdId + Creditos[j].nro_credito).onclick();
                }
            }
        }
    }
}


objCancelaciones.actualizarDatos = function () {
    //administrar importe en mano
    consulta.cancelacion.LiberaCuota = this.LiberaCuota;
    consulta.cancelacion.totalCancelaciones = this.totalCancelaciones;

    analisis.set_etiqueta(17, this.LiberaCuota);
    analisis.set_etiqueta('importe_a_liberar', this.LiberaCuota);
    analisis.set_etiqueta('saldo_a_cancelar', this.totalCancelaciones);

    analisis.actualizar();

    $('cTotlaMora').innerHTML = '$' + this.totalMora;
    $('cCuotaLiberada').innerHTML = '$' + this.LiberaCuota;
    $('cSaldoCancelar').innerHTML = '$' + this.totalCancelaciones;
}


//######################################
//#######----Postergaciones------#######
//######################################


//Cargar relaciones entre creditos
objCancelaciones.relacionar = function () {

    var sumaLevel = function (objCreditos, nro_credito) {
        //obtener raiz de postergaciones
        if (!objCreditos[nro_credito].raiz)
            objCreditos[nro_credito].raiz = nro_credito;

        //si existe credito origen y el credito no fue evaluado (level = 0)
        if (objCreditos[nro_credito].nro_credito_origen != 0 && objCreditos[nro_credito].level == 0 && !!objCreditos[objCreditos[nro_credito].nro_credito_origen]) {
            //llamado recursivo para obtener nivel y raiz
            resultado = sumaLevel(objCreditos, objCreditos[nro_credito].nro_credito_origen);
            objCreditos[nro_credito].level = resultado.level + 1;
            objCreditos[nro_credito].raiz = resultado.raiz;
            //guardar relaciones con postergaciones en la raiz
            objCreditos[resultado.raiz].relacionados.push(nro_credito);
        }
        return { level: objCreditos[nro_credito].level, raiz: objCreditos[nro_credito].raiz };
    }

    //Cargar niveles
    var cargarRelaciones = function (objCreditos) {
        Object.keys(objCreditos).forEach(function (key, index) {
            sumaLevel(objCreditos, key)
        });

        //Cargar relaciones de la raiz con sus nodos
        Object.keys(objCreditos).forEach(function (key, index) {
            if (objCreditos[key].raiz != key) {
                let raiz = objCreditos[key].raiz;
                objCreditos[key].relacionados = [objCreditos[key].raiz, ...objCreditos[raiz].relacionados];
                objCreditos[key].relacionados.splice(objCreditos[key].relacionados.indexOf(key), 1);
            }
        });
    }

    cargarRelaciones(objCancelaciones.creditosBase.cancelaciones);
    cargarRelaciones(objCancelaciones.creditosBase.mora);

}


//Chequear creditos relacionados
objCancelaciones.postergacionAdd = function (nro_credito, nro_calc_tipo) {
    this.administrarPostergacion(nro_credito, nro_calc_tipo, true);
}


//Deschequear creditos relacionados
objCancelaciones.postergacionRemove = function (nro_credito, nro_calc_tipo) {
    this.administrarPostergacion(nro_credito, nro_calc_tipo, false);
}


objCancelaciones.administrarPostergacion = function (nro_credito, nro_calc_tipo, checked) {

    let creditoPostergacion = nro_calc_tipo == 3 ? this.creditosBase.mora : this.creditosBase.cancelaciones
    let rel = creditoPostergacion[nro_credito].relacionados;
    let rdId = nro_calc_tipo == '3' ? 'rdCheckMora' : 'rdCheckCancelacion';

    for (var r = 0; r < rel.length; r++) {
        //si existen relaciones con check en distinto estado
        if ($(rdId + creditoPostergacion[rel[r]].nro_credito).checked != checked) {
            $(rdId + creditoPostergacion[rel[r]].nro_credito).checked = checked;
            if (typeof $(rdId + creditoPostergacion[rel[r]].nro_credito).onclick == 'function')
                $(rdId + creditoPostergacion[rel[r]].nro_credito).onclick();
        }
    }

}


objCancelaciones.mostrarDivCancelaciones = function () {
    if ($('tbCredVigente').style.display === '') {
        $('tbCredVigente').hide();
        $('linkRefinanciar').innerHTML = 'Refinanciar';
    } else {
        $('tbCredVigente').show();
        $('linkRefinanciar').innerHTML = 'Ocultar';
    }
}