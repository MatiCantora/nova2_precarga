var origen = ''
var consultardisponibleeducacion = 0
var aux_analisis_old = ''
//function CargarAnalisis(nro_analisis)
//{

//  //if (!nro_analisis)
//  //  nro_analisis = GetCookie('nro_analisis')

//    //$('cbAnalisis').options.length = 0
//    //campos_defs.habilitar("cbAnalisis", true)
//    //campos_defs.clear_list("cbAnalisis")

//    //var nro_banco = campos_defs.get_value('banco') //$('banco').value
//    //var nro_mutual = campos_defs.get_value('mutual') //$('mutual').value
//    //form1.nro_mutual.value=nro_mutual
//  //var nro_sistema = $('nro_sistema').value
//  //var nro_lote = $('nro_lote').value
//  //var criterio = ""
//  //criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_grupo type='igual'>" + nro_grupo + "</nro_grupo><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
//  //if (((nro_sistema == "0") && (nro_lote == "0")) && (nro_grupo != 0))
//  //  criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_grupo type='igual'>" + nro_grupo + "</nro_grupo><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
//  //else
//  //  criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_sistema type='igual'>" + nro_sistema + "</nro_sistema><nro_lote type='igual'>" + nro_lote + "</nro_lote><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"

// // var i = 0
// //   if (nvFW.tienePermiso("permisos_web2", 3))   // (permisos_web2 & 32) > 0
// //    criterio += "<permiso_tabla type='sql'>dbo.rm_tiene_permiso('permisos_tablas_comercios',permiso_tabla) = 1</permiso_tabla>"

// //var es_debito=(nro_tipo_cobro==4)?1:0
// //criterio += "<permiso_analisis type='sql'>dbo.rm_tiene_permiso('permisos_analisis',permiso_analisis) = 1</permiso_analisis><aplica_precarga type='igual'>1</aplica_precarga><cbu type='igual'>"+es_debito+"</cbu>"

//  //var rs = new tRS();
//  //  rs.onComplete = function (rs) {
//  //      campos_defs.items['cbAnalisis'].rs = rs
//  //      campos_defs.items['cbAnalisis']['onchange'] = cbAnalisis_onchange
//  //      if(!nro_analisis){
//  //      campos_defs.set_first('cbAnalisis')
//  //      }else{
//  //        campos_defs.set_value('cbAnalisis',nro_analisis)
//  //      }
//  //      campos_defs.habilitar("cbAnalisis", false)
//  //      if(!motor.tiene_ofertas()){
//  //        if (rs.recordcount == 1) campos_defs.habilitar("cbAnalisis", false)
//  //        else campos_defs.habilitar("cbAnalisis", true)
//  //      }else{
//  //        if (rs.recordcount > 1) campos_defs.habilitar("cbAnalisis", true) //agregado para los analisis que si tieen mas de un analisis
//  //      }

//  //    }

//  //rs.open({ filtroXML: nvFW.pageContents["analisis_cargar"], filtroWhere: criterio })


//}

function tnvAnalisis() {

    this.nro_analisis = 0
    this.nro_banco = 0
    this.cuota_maxima = 0
    this.haber_neto = 0
    this.saldo_a_cancelar = 0
    this.haber_neto = 0

    this.filas = 0


    this.maxMontos = 0;
    this.Etiquetas = {}
    this.Cancelaciones = {}

    this.maxCancelaciones = 0;
    this.array_campos_defs = {}


    this.canvas = null
    this.onAfterCalc = null
    this.onAfterCharge = null




    this.cargar = function (nro_analisis, nro_banco) {

        this.nro_analisis = nro_analisis
        this.nro_banco = nro_banco

        this.maxMontos = 0;
        this.Etiquetas = {}
        var Etiqueta = {}

        var colum_width = 0

        var objAnalisis = this

        //  var xmlCriterio = "<criterio><select vista='verEtiqueta_analisis'><campos>Orden,Nro_Etiqueta,etiqueta,Visible,Calculado,Color,Nro_Analisis,analisis,ultimo,HD,Comentario,css_style,tipo_dato,css_style_input,Calculo,editable,dbo.rm_an_calculobanco(nro_analisis, nro_etiqueta, orden, " + nro_banco + ") as CalculoBanco</campos><filtro><nro_analisis type='igual'>" + nro_analisis + "</nro_analisis></filtro><orden>orden</orden></select></criterio>"
        var rs = new tRS();
        rs.asyc = true
        rs.onComplete = function (rs) {
            while (!rs.eof()) {
                if ((rs.getdata('ultimo') == 'True') && (ismobile == false))
                    objAnalisis.filas++
                objAnalisis.maxMontos++
                objAnalisis.Etiquetas[objAnalisis.maxMontos] = {}
                objAnalisis.Etiqueta = objAnalisis.Etiquetas[objAnalisis.maxMontos]
                objAnalisis.Etiqueta['ID'] = objAnalisis.maxMontos
                objAnalisis.Etiqueta['orden'] = rs.getdata('Orden')
                objAnalisis.Etiqueta['nro_etiqueta'] = rs.getdata('Nro_Etiqueta')
                objAnalisis.Etiqueta['etiqueta'] = rs.getdata('etiqueta')
                objAnalisis.Etiqueta['visible'] = eval(rs.getdata('Visible').toLowerCase())
                objAnalisis.Etiqueta['calculado'] = eval(rs.getdata('Calculado').toLowerCase())
                objAnalisis.Etiqueta['color'] = rs.getdata('Color')
                objAnalisis.Etiqueta['calculoBanco'] = rs.getdata('CalculoBanco')
                objAnalisis.Etiqueta['nro_analisis'] = rs.getdata('Nro_Analisis')
                objAnalisis.Etiqueta['analisis'] = rs.getdata('analisis')
                objAnalisis.Etiqueta['ultimo'] = eval(rs.getdata('ultimo').toLowerCase())
                objAnalisis.Etiqueta['HD'] = rs.getdata('HD')
                objAnalisis.Etiqueta['comentario'] = rs.getdata('Comentario')
                objAnalisis.Etiqueta['css_style'] = rs.getdata('css_style')
                objAnalisis.Etiqueta['tipo_dato'] = rs.getdata('tipo_dato')
                objAnalisis.Etiqueta['editable'] = eval(rs.getdata('editable').toLowerCase())
                objAnalisis.Etiqueta['css_style_input'] = rs.getdata('css_style_input')
                if (objAnalisis.Etiqueta['calculoBanco'] == null)
                    objAnalisis.Etiqueta['calculo'] = rs.getdata('Calculo')
                else
                    objAnalisis.Etiqueta['calculo'] = objAnalisis.Etiqueta['calculoBanco']
                switch (objAnalisis.Etiqueta['tipo_dato']) {
                    case 'M':
                        objAnalisis.Etiqueta['valor'] = '0.00'
                        break
                    case 'I':
                        objAnalisis.Etiqueta['valor'] = '0'
                        break
                    case 'D':
                        objAnalisis.Etiqueta['valor'] = '1/1/2020';
                        break
                    case 'S':
                        objAnalisis.Etiqueta['valor'] = ''
                        break
                    case 'B':
                        objAnalisis.Etiqueta['valor'] = false
                        break
                }
                rs.movenext()
            }

            if (objAnalisis.onAfterCharge != null) objAnalisis.onAfterCharge()

        }
        rs.open({ filtroXML: nvFW.pageContents["etiqueta_analisis"], params: "<criterio><params nro_banco='" + this.nro_banco + "' nro_analisis='" + this.nro_analisis + "' /></criterio>" })
        //rs.open(xmlCriterio)

    }

    this.mostrar = function () {
        var strHTML = ""
        var strHTML_No_Visible = ""
        var cont = 0;
        var maxcont = 0;
        var calculoBanco;
        //var nro_banco = campos_defs.get_value('banco')// $('banco').value
        //if (!nro_analisis)
        //nro_analisis = campos_defs.get_value('cbAnalisis') //$('cbAnalisis').value
        //$('nro_analisis').value = $('cbAnalisis').value  
        //Borrar analisis previo


        this.filas++
        colum_width = 100 / this.filas

        var i = 0
        strHTML = "<table class='tb1' width='100%'><tr><td style='width:" + colum_width + "%; vertical-align:top'>"
        for (i in this.Etiquetas) {
            Etiqueta = this.Etiquetas[i]
            if (Etiqueta['visible']) {
                strHTML = strHTML + this.add_etiqueta(Etiqueta)
                if ((Etiqueta['ultimo']) && (ismobile == false))
                    strHTML = strHTML + "</td><td style='width:" + colum_width + "%; vertical-align:top'>"
            }
            else
                strHTML_No_Visible = strHTML_No_Visible + this.add_etiqueta(Etiqueta)

            //nro_analisis = Etiqueta['nro_analisis']
        }
        strHTML = strHTML + "</td></tr></table>"

        //if (nro_analisis_actual != nro_analisis) 
        // {
        this.canvas.innerHTML = ""
        this.canvasNoVisible.innerHTML = ""
        /*divHaberes.insertAdjacentHTML("BeforeEnd",strHTML)
        divHaberesNoVisibles.insertAdjacentHTML("BeforeEnd",strHTML_No_Visible)  */
        this.canvas.insert({ bottom: strHTML })
        this.canvasNoVisible.insert({ bottom: strHTML_No_Visible })




        //}
        //debugger
        //for (var i in array_campos_defs)
        //{
        //var campo_def = array_campos_defs[i]['campo_def']
        //var nombre = array_campos_defs[i]['parametro']
        //var contenedor = array_campos_defs[i]['target']
        //if (array_campos_defs[i]['tipo_dato'] == 'datetime')
        //    campos_defs.add(nombre, { target: contenedor, enDB: false, nro_campo_tipo: 103, despliega: 'abajo' })
        //else        
        //    campos_defs.add(campo_def, { enDB: true, target: contenedor })      
        //}

        this.nro_analisis_actual = nro_analisis

        //BCRA_situacion = 0


        this.actualizar(true)
        this.focus_first()
        //if (!ismobile)
        //    this.focus_first()

    }


    this.canvas_mostrar = function () {
        if (analisis.canvas.style.display === 'none')
            this.canvas.show();
        else this.canvas.hide();
    }


    this.actualizar = function (carga_inicial) {
        var Etiqueta;
        var index
        tiene_seguro = 0
        //17 es total de cancelaciones

        var Etiquetas = this.Etiquetas

        //for (index in Etiquetas) {
        //    //if (Etiquetas[index]["nro_etiqueta"] == 93)
        //    //    var sit_bcra_eti = $('nuevo_monto' + index)
        //    if (Etiquetas[index]["nro_etiqueta"] == 17)
        //        var TotalCancelaciones = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
        //    if (Etiquetas[index]["nro_etiqueta"] == 1007)
        //        var TotalCancelVenc = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
        //    if (Etiquetas[index]["nro_etiqueta"] == 1008)
        //        var TotalCancelNoVenc = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
        //    if (Etiquetas[index]["nro_etiqueta"] == 1009)
        //        var TotalCancelCupo = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
        //    if (Etiquetas[index]["nro_etiqueta"] == 1010)
        //        var TotalCancelCuotas = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
        //    if (Etiquetas[index]["nro_etiqueta"] == 489)
        //        tiene_seguro = $('nuevo_monto' + index).value == 'SI' ? 1 : 0
        //}

        ////Cargar situacion BCRA
        //if (sit_bcra_eti != undefined)
        // {
        //   if(parseInt(sit_bcra_eti.value) > 0 && $('sit_bcra').value == 0)
        //      $('sit_bcra').value = sit_bcra_eti.value
        //   else
        //     if($('sit_bcra').value > 0 && $('sit_bcra').value <= 6)
        //        sit_bcra_eti.value = formatoDecimal(parseFloat($('sit_bcra').value),2)
        // }

        //if (TotalCancelaciones != undefined)
        //    TotalCancelaciones.value = 0
        //if (TotalCancelVenc != undefined)
        //    TotalCancelVenc.value = 0
        //if (TotalCancelNoVenc != undefined)
        //    TotalCancelNoVenc.value = 0
        //if (TotalCancelCupo != undefined)
        //    TotalCancelCupo.value = 0
        //if (TotalCancelCuotas != undefined)
        //    TotalCancelCuotas.value = 0

        //('saldo_a_cancelar').innerHTML = 0

        //var Cancelaciones = this.Cancelaciones
        //saldo_a_cancelar = 0
        //for (h in Cancelaciones) {
        //    if (TotalCancelaciones != undefined)
        //        TotalCancelaciones.value = formatoDecimal(parseFloat(TotalCancelaciones.value) + parseFloat(Cancelaciones[h]['cancela_cuota']), 2)
        //    if ((Cancelaciones[h]['deuda_vencida'] == true) && (TotalCancelVenc != undefined))
        //        TotalCancelVenc.value = formatoDecimal(parseFloat(TotalCancelVenc.value) + parseFloat(Cancelaciones[h]['cancela_cuota']), 2)
        //    if ((Cancelaciones[h]['deuda_vencida'] == false) && (TotalCancelNoVenc != undefined))
        //        TotalCancelNoVenc.value = formatoDecimal(parseFloat(TotalCancelNoVenc.value) + parseFloat(Cancelaciones[h]['cancela_cuota']), 2)
        //    if (TotalCancelCupo != undefined)
        //        TotalCancelCupo.value = formatoDecimal(parseFloat(TotalCancelCupo.value) + parseFloat(Cancelaciones[h]['cancela_cupo']), 2)
        //    if (TotalCancelCuotas != undefined)
        //        TotalCancelCuotas.value = formatoDecimal(parseFloat(TotalCancelCuotas.value) + parseFloat(Cancelaciones[h]['cancela_cuota']), 2)
        //    saldo_a_cancelar = parseFloat(saldo_a_cancelar) + parseFloat(Cancelaciones[h]['importe_pago'])

        //}

        /*
        for (i in Etiquetas)
          switch (Etiquetas[i]["nro_etiqueta"])
            {
            case '17':
              form1.total_cancelaciones.value = parseFloat(eval("form1.nuevo_monto" + h + ".value")).toFixed(2)
              break  
            }
         */
        this.calcular_valores(carga_inicial)

        this.saldo_a_cancelar = this.min_etiqueta('saldo_a_cancelar')
        this.importe_en_mano = this.min_etiqueta('importe_en_mano')

        this.haber_neto = analisis.suma_etiqueta(14) //14 = hacer neto
        this.cuota_maxima = analisis.min_etiqueta(16) // 16  = cuota maxima
        this.neto_maximo = analisis.min_etiqueta(1001) // 1001  = neto maximo
        this.solicitado_max = analisis.min_etiqueta(1003) // 1003  = solicitado maximo
        this.documentado_max = analisis.min_etiqueta(1004) // 1004  = documentado maximo
        this.cuotas_max = analisis.min_etiqueta(1006) // 1006  = cuotas maximo
        this.importe_cuota = analisis.min_etiqueta(1026) // 1026  = cuotas maximo

        let hd_haber_neto = this.suma_etiqueta('haber_neto');
        this.haber_neto = this.haber_neto > 0 || !hd_haber_neto ? this.haber_neto : hd_haber_neto //14 = haber neto
        let hd_cuota_maxima = this.min_etiqueta('cuota_maxima');
        this.cuota_maxima = this.cuota_maxima > 0 || !hd_cuota_maxima ? this.cuota_maxima : hd_cuota_maxima // 16  = cuota maxima
        let hd_neto_maximo = this.min_etiqueta('neto_maximo');
        this.neto_maximo = this.neto_maximo > 0 || !hd_neto_maximo ? this.neto_maximo : hd_neto_maximo // 1001  = neto maximo
        let hd_solicitado_max = this.min_etiqueta('solicitado_max');
        this.solicitado_max = this.solicitado_max > 0 || !hd_solicitado_max ? this.solicitado_max : hd_solicitado_max // 1003  = solicitado maximo
        let hd_documento_max = this.min_etiqueta('documentado_max');
        this.documentado_max = this.documentado_max > 0 || !hd_documento_max ? this.documentado_max : hd_documento_max // 1004  = documentado maximo
        let hd_cuotas_max = this.min_etiqueta('cuotas_max');
        this.cuotas_max = this.cuotas_max > 0 || !hd_cuotas_max ? this.cuotas_max : hd_cuotas_max // 1006  = cuotas maximo
        let hd_importe_cuota = this.min_etiqueta('importe_cuota');
        this.importe_cuota = this.importe_cuota > 0 || !hd_importe_cuota ? this.importe_cuota : hd_importe_cuota // 1026  = cuotas maximo


        if (this.onAfterCalc != null) this.onAfterCalc()

        /*if(!motor.tiene_ofertas() || carga_inicial){
        importe_max_cuota = cuota_maxima    
        }*/

        //if (carga_inicial || motor.datos.es_poder_judicial == '1' || !motor.tiene_ofertas()) {
        //    importe_max_cuota = parseFloat(cuota_maxima)
        //}
        //importe_max_cuota = cuota_maxima    
        //var cuota_maxima_analisis = (carga_inicial || motor.datos.es_poder_judicial == '1' || !motor.tiene_ofertas()) ? parseFloat(cuota_maxima) : parseFloat(importe_max_cuota) //parseFloat(carga_inicial?cuota_maxima :importe_max_cuota) //este importe cuota , es un valor global q puede traer valor desde las cancelaciones
        /*if(!carga_inicial){
         cuota_maxima_analisis = parseFloat(cuota_maxima)+parseFloat(importe_max_cuota) //este importe es un valor de la cuota maxima disponible en funcion del calculo del analisis, por eso se puede sumar a las cancelaciones, si es q se van a liberar cuotas
        }*/


        //var str_cuota_maxima = (parseFloat(cuota_maxima_analisis) > 0) ? "<font color='green'><b>$ " + cuota_maxima_analisis.toFixed(2) + "</b></font>" : "<font color='red'><b>$ " + cuota_maxima_analisis.toFixed(2) + "</b></font>"
        //$('importe_max_cuota').insert({ bottom: str_cuota_maxima })

        //$('strCuotaMaxima').innerHTML = ""
        //$('strCuotaMaxima').insert({ bottom: '$ ' + parseFloat(importe_max_cuota).toFixed(2) })
        //if (origen == 'precarga')
        //    $('ifrplanes').src='enBlanco.htm'
    }

    this.add_etiqueta = function (Etiqueta, valor) {

        var readOnly = "";
        var Indice = "";
        var comentario = ""
        var i = 0
        if (Etiqueta['editable'] == false) {
            readOnly = "readonly"
        }
        if (Etiqueta['calculado']) {
            //readOnly = "readonly"
            Indice = "(c)"
        }
        if (Etiqueta['comentario'] != '') {
            comentario = " - " + Etiqueta['comentario']
        }
        if (!Etiqueta['visible'])
            visible = "style='DISPLAY: none'"
        else {
            if (strBC == 'BACKGROUND-COLOR: #F8FFFE')
                strBC = 'BACKGROUND-COLOR: #E9F0F4'
            else
                strBC = 'BACKGROUND-COLOR: #F8FFFE'
        }
        valor = Etiqueta['valor']
        //if (!valor) {
        //    switch (Etiqueta['tipo_dato']) {
        //        case 'M':
        //            valor = Etiqueta['valor']
        //            break
        //        case 'I':
        //            valor = Etiqueta['valor'].toFixed(0)
        //            break
        //        case 'D':
        //            valor = FechaToSTR(Etiqueta['valor'])
        //            break
        //        case 'S':
        //            valor = '' + Etiqueta['valor']
        //            break
        //        case 'B':
        //            valor = Etiqueta['valor']
        //            break
        //    }
        //}
        strHTML = "<table class='tb1' cellspacing='0' cellpadding='0'><tr><td style='" + Etiqueta['css_style'] + "; width:100%; vertical-align: middle !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;'>&nbsp;"
        //strHTML = "<table class='tb1' ><tr><td style='" + Etiqueta['css_style'] + "; vertical-align: middle'>"
        //if ((Etiqueta["nro_etiqueta"] == 8) && (origen == 'precarga'))
        //    valor = importe_cs_analisis
        //if ((Etiqueta["nro_etiqueta"] == 389) && (origen == 'precarga'))
        //    valor = cupo_disponible
        //if (Etiqueta["nro_etiqueta"] == 93)
        //  {
        //   if (origen != 'precarga')
        //     strHTML = strHTML + "<img title='Consulta BCRA' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return BCRA_consultar()'/>&nbsp;&nbsp;&nbsp;"

        //   //strHTML = strHTML + "<input type='hidden' id='sit_bcra' name='sit_bcra' value='0'/>"
        //  } 
        if ((Etiqueta["nro_etiqueta"] == 17) && !(origen == 'precarga'))
            //strHTML = strHTML + '<input type="button" name="btnMostrarCancelaciones" ID="btnMostrarCancelaciones"  value="+" LANGUAGE=javascript onclick="return cancelaciones_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='ABM Cancelaciones' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return cancelaciones_ABM()'/>&nbsp;&nbsp;&nbsp;"
        if (Etiqueta["nro_etiqueta"] == 1000)
            //strHTML = strHTML + '<input type="button" name="btnMostrarHaberes" ID="btnMostrarHaberes"  value="+" LANGUAGE=javascript onclick="return haberes_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='Mostrar Haberes' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return haberes_ABM()'/>&nbsp;&nbsp;&nbsp;"
        if (Etiqueta["nro_etiqueta"] == 1024)
            //strHTML = strHTML + '<input type="button" name="btnMostrarHaberes" ID="btnMostrarHaberes"  value="+" LANGUAGE=javascript onclick="return haberes_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='Seleccionar Seguro' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return seguro_seleccion()'/>&nbsp;&nbsp;&nbsp;"
        strHTML = strHTML + Etiqueta['etiqueta'] + " " + Indice + comentario + "</td>" + "<td><input id='nuevo_monto" + Etiqueta['ID'] + "' name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;border-style: double'"
        //strHTML = strHTML + Etiqueta['etiqueta'] + " " +  Indice + "</td>" + "<td style='width: 20%'><input name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style'] + "; width: 100%; TEXT-ALIGN: right'"

        switch (Etiqueta['tipo_dato']) {
            case 'M':
                strHTML = strHTML + " value='" + valor + "' onchange='validarNumero(event,\"0.00\"); analisis.actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "  //valDigitoOtro(event,\".+-*/\") //valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")
                break
            case 'I':
                strHTML = strHTML + " value='" + valor + "' onchange='analisis.actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "
                break
            case 'D':
                strHTML = strHTML + " value='" + valor + "' onchange='valFecha(event); analisis.actualizar(false)' onkeypress='return valDigito2(event,\"/\"," + Etiqueta['ID'] + ")' " //valDigitoVBS(event) 
                //i = i + 1
                //array_campos_defs[i] = {}
                //array_campos_defs[i]['parametro'] = Etiqueta['ID']
                //array_campos_defs[i]['tipo_dato'] = 'datetime'
                //array_campos_defs[i]['campo_def'] = ''
                //array_campos_defs[i]['target'] = 'nuevo_monto' + Etiqueta['ID']  
                //strHTML = strHTML + " value='" + valor + "' "
                break
            case 'S':
                strHTML = strHTML + " value='" + valor + "' onchange='analisis.actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
                break
            case 'B':
                strHTML = strHTML + " type='checkbox' " + (valor ? 'checked' : '') + " onclick='analisis.actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
                break
        }

        if (Etiqueta["nro_etiqueta"] == 93) {
            strHTML = strHTML + " onblur='onblur_BCRA_situacion()' "
        }

        if (Etiqueta['editable'] == false) {
            strHTML = strHTML + " type=hidden /><span id='span_monto_" + Etiqueta['ID'] + "'  style = '" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial; display: inline-block;border-collapse: collapse; border-radius: inherit;background: #dcdcdc;height:21px;padding-top:4px; padding-right:7px;' > " + valor + "</span > "
            strHTML = strHTML + "<input id='nuevo_monto_value" + Etiqueta['ID'] + "' name = 'nuevo_monto_value" + Etiqueta['ID'] + "' type = 'hidden' value = '" + Etiqueta['nro_etiqueta'] + "' /></td ></tr ></table > "
        } else {
            strHTML = strHTML + readOnly + " /><input id='nuevo_monto_value" + Etiqueta['ID'] + "' name='nuevo_monto_value" + Etiqueta['ID'] + "' type='hidden' value='" + Etiqueta['nro_etiqueta'] + "'/></td></tr></table>"
        }
        //strHTML = strHTML + readOnly + " /><input id='nuevo_monto_value" + Etiqueta['ID'] + "' name='nuevo_monto_value" + Etiqueta['ID'] + "' type='hidden' value='" + Etiqueta['nro_etiqueta'] + "'/></td></tr></table>"
        return strHTML
    }

    this.calcular_valores = function (carga_inicial) {

        var calculo;
        var pos1;
        var pos2;
        var nro_etiqueta;
        var Etiquetas = this.Etiquetas
        for (var i in Etiquetas) {
            switch (Etiquetas[i]['nro_etiqueta']) {
                case 17: //'Total Cancelaciones Liberadas'
                    Etiquetas[i]['valor'] = this.total_cancelaciones
                    continue
                    break;
                case 93:  //'Situacion BCRA'
                    continue
                    break;
                case 1024:  //'Compañia de seguro'
                    continue
                    break;

            }

            if (Etiquetas[i]['calculado']) {
                if ((Etiquetas[i]['editable'] == true && carga_inicial == true) || (Etiquetas[i]['editable'] == false)) {
                    calculo = Etiquetas[i]['calculo']

                    for (var j = 1; j <= i; j++) {
                        nro_etiqueta = Etiquetas[j]['nro_etiqueta']
                        while (calculo.indexOf('%' + nro_etiqueta + "%") != -1)
                            calculo = calculo.replace('%' + nro_etiqueta + "%", '(' + this.suma_etiqueta(Number(nro_etiqueta), i) + ')')
                    }
                    for (var j = 1; j <= i; j++) {
                        nro_etiqueta = Etiquetas[j]['nro_etiqueta']
                        while (calculo.indexOf('$' + nro_etiqueta + "$") != -1)
                            calculo = calculo.replace('$' + nro_etiqueta + "$", '(' + this.min_etiqueta(Number(nro_etiqueta), i) + ')')
                    }

                    Etiquetas[i]['valor'] = eval(calculo)
                    switch (Etiquetas[i]['tipo_dato']) {
                        //si calculo es vacio , pone NaN
                        case 'M': //Moneda
                            if (typeof (Etiquetas[i]['valor']) != 'string') Etiquetas[i]['valor'] = Etiquetas[i]['valor'].toFixed(2)
                            break
                        case 'I': //Entero
                            if (typeof (Etiquetas[i]['valor']) != 'string') Etiquetas[i]['valor'] = Etiquetas[i]['valor'].toFixed(0)
                            break
                        case 'D': //Fecha
                            if (typeof (Etiquetas[i]['valor']) != 'string') Etiquetas[i]['valor'] = FechaToSTR(Etiquetas[i]['valor'])
                            break
                        case 'S': //String
                            Etiquetas[i]['valor'] = '' + Etiquetas[i]['valor']
                            break
                        case 'B': //Boleano
                            if (typeof (Etiquetas[i]['valor']) != 'string') Etiquetas[i]['valor'] = '' + Etiquetas[i]['valor']
                            break
                    }
                    try {
                        $('nuevo_monto' + i).value = Etiquetas[i]['valor']
                        if ($('span_monto_' + i)) $('span_monto_' + i).innerText = $('nuevo_monto' + i).value
                    }
                    catch (e1) {

                    }


                    //try {
                    //    switch (Etiquetas[i]['tipo_dato']) {
                    //        //si calculo es vacio , pone NaN
                    //        case 'M': //Moneda
                    //            $('nuevo_monto' + i).value = Etiquetas[i]['valor']
                    //            break
                    //        case 'I': //Entero
                    //            $('nuevo_monto' + i).value = Etiquetas[i]['valor']
                    //            break
                    //        case 'D': //Fecha
                    //            $('nuevo_monto' + i).value = FechaToSTR(Etiquetas[i]['valor'])
                    //            break
                    //        case 'S': //String
                    //            $('nuevo_monto' + i).value = '' + Etiquetas[i]['valor']
                    //            break
                    //        case 'B': //Boleano
                    //            $('nuevo_monto' + i).checked = Etiquetas[i]['valor']
                    //            break
                    //    }
                    //}
                    //catch (e) { }
                    //try {
                    //    $('nuevo_monto' + i).value = Etiquetas[i]['valor']
                    //}


                    //if ($('span_monto_' + i)) $('span_monto_' + i).innerText = $('nuevo_monto' + i).value
                }

            }
            else { //Si no es calculado
                try {
                    switch (Etiquetas[i]['tipo_dato']) {
                        //si calculo es vacio , pone NaN
                        case 'M': //Moneda
                            Etiquetas[i]['valor'] = $('nuevo_monto' + i).value //$('nuevo_monto' + i).value
                            break
                        case 'I': //Entero
                            Etiquetas[i]['valor'] = $('nuevo_monto' + i).value
                            break
                        case 'D': //Fecha
                            Etiquetas[i]['valor'] = $('nuevo_monto' + i).value
                            break
                        case 'S': //String
                            Etiquetas[i]['valor'] = $('nuevo_monto' + i).value
                            break
                        case 'B': //Boleano
                            Etiquetas[i]['valor'] = '' + $('nuevo_monto' + i).checked
                            break

                    }
                }
                catch (e) { }
            }
        }
        //console.log("set_campos")
        //motor.set_campos()

    }

    this.add_etiqueta_new = function (Etiqueta, valor) {
        var readOnly = "";
        var Indice = "";
        var comentario = ""
        var i = 0

        if (Etiqueta['editable'] == false) {
            readOnly = "readonly"
        }
        if (Etiqueta['calculado']) {
            //readOnly = "readonly"
            Indice = "(c)"
        }
        if (Etiqueta['comentario'] != '') {
            comentario = " - " + Etiqueta['comentario']
        }
        if (!Etiqueta['visible'])
            visible = "style='DISPLAY: none'"
        else {
            if (strBC == 'BACKGROUND-COLOR: #F8FFFE')
                strBC = 'BACKGROUND-COLOR: #E9F0F4'
            else
                strBC = 'BACKGROUND-COLOR: #F8FFFE'
        }
        if (!valor) {
            switch (Etiqueta['tipo_dato']) {
                case 'M':
                    valor = '0.00'
                    break
                case 'I':
                    valor = '0'
                    break
                case 'D':
                    valor = ''
                    break
                case 'S':
                    valor = ''
                    break
                case 'B':
                    valor = ''
                    break
            }
        }
        strHTML = "<table class='tb1' cellspacing='0' cellpadding='0'><tr><td style='" + Etiqueta['css_style'] + "; width:100%; vertical-align: middle !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;white-space: nowrap;'>&nbsp;"
        //strHTML = "<table class='tb1' ><tr><td style='" + Etiqueta['css_style'] + "; vertical-align: middle'>"
        if ((Etiqueta["nro_etiqueta"] == 8) && (origen == 'precarga'))
            valor = importe_cs_analisis
        if ((Etiqueta["nro_etiqueta"] == 389) && (origen == 'precarga'))
            valor = cupo_disponible
        //si es activo provincial de bs as

        /*if ((Etiqueta["nro_etiqueta"] == 446) && (origen == 'precarga') && campos_defs.get_value("grupos")==10 && $F("consultarRobot")=="1")
        { 
          valor = DISPONIBLE_ba_educacion($("nro_docu").value,campos_defs.get_value("mutual"))   
        }*/

        if (Etiqueta["nro_etiqueta"] == 93) {
            if (origen == 'precarga')
                valor = sit_bcra
            else
                strHTML = strHTML + "<img title='Consulta BCRA' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return BCRA_consultar()'/>&nbsp;&nbsp;&nbsp;"

            strHTML = strHTML + "<input type='hidden' id='sit_bcra' name='sit_bcra' value='0'/>"
        }
        if ((Etiqueta["nro_etiqueta"] == 17) && !(origen == 'precarga'))
            //strHTML = strHTML + '<input type="button" name="btnMostrarCancelaciones" ID="btnMostrarCancelaciones"  value="+" LANGUAGE=javascript onclick="return cancelaciones_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='ABM Cancelaciones' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return cancelaciones_ABM()'/>&nbsp;&nbsp;&nbsp;"
        if (Etiqueta["nro_etiqueta"] == 1000)
            //strHTML = strHTML + '<input type="button" name="btnMostrarHaberes" ID="btnMostrarHaberes"  value="+" LANGUAGE=javascript onclick="return haberes_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='Mostrar Haberes' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return haberes_ABM()'/>&nbsp;&nbsp;&nbsp;"
        if (Etiqueta["nro_etiqueta"] == 1024)
            //strHTML = strHTML + '<input type="button" name="btnMostrarHaberes" ID="btnMostrarHaberes"  value="+" LANGUAGE=javascript onclick="return haberes_ABM()">&nbsp;&nbsp;&nbsp;'
            strHTML = strHTML + "<img title='Seleccionar Seguro' style='cursor:hand; cursor:pointer; vertical-align: middle' src='../../meridiano/image/icons/agregar.png' onclick='return seguro_seleccion()'/>&nbsp;&nbsp;&nbsp;"


        strHTML = strHTML + Etiqueta['etiqueta'] + " " + Indice + comentario + "</td>" + "<td><input id='nuevo_monto" + Etiqueta['ID'] + "' name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;border-style: doble'"
        //strHTML = strHTML + Etiqueta['etiqueta'] + " " +  Indice + "</td>" + "<td style='width: 20%'><input name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style'] + "; width: 100%; TEXT-ALIGN: right'"

        switch (Etiqueta['tipo_dato']) {
            case 'M':
                strHTML = strHTML + " value='" + valor + "' onchange='validarNumero(event,\"0.00\"); analisis.actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "  //valDigitoOtro(event,\".+-*/\") //valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")
                break
            case 'I':
                strHTML = strHTML + " value='" + valor + "' onchange='analisis.actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "
                break
            case 'D':
                strHTML = strHTML + " value='" + valor + "' onchange='valFecha(event); analisis.actualizar(false)' onkeypress='return valDigito2(event,\"/\"," + Etiqueta['ID'] + ")' " //valDigitoVBS(event) 
                //i = i + 1
                //campos_defs.add(Etiqueta['ID'], { nro_campo_tipo: 4, target: 'nuevo_monto' + Etiqueta['ID'], enDB: false })
                //array_campos_defs[i] = {}
                //array_campos_defs[i]['parametro'] = Etiqueta['ID']
                //array_campos_defs[i]['tipo_dato'] = 'datetime'
                //array_campos_defs[i]['campo_def'] = ''
                //array_campos_defs[i]['target'] = 'nuevo_monto' + Etiqueta['ID']  
                //strHTML = strHTML + " value='" + valor + "' "
                break
            case 'S':
                strHTML = strHTML + " value='" + valor + "' onchange='analisis.actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
                break
            case 'B':
                strHTML = strHTML + " type='checkbox'  onclick='analisis.actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
                break
        }

        if (Etiqueta["nro_etiqueta"] == 93) {
            strHTML = strHTML + " onblur='onblur_BCRA_situacion()' "
        }

        if (Etiqueta['editable'] == false) {
            strHTML = strHTML + " type=hidden /><span id='span_monto_" + Etiqueta['ID'] + "'  style = '" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial; display: inline-block;border-collapse: collapse; border-radius: inherit;background: #dcdcdc;height:21px;padding-top:4px; padding-right:7px;' > " + valor + "</span > "
            strHTML = strHTML + "<input id='nuevo_monto_value" + Etiqueta['ID'] + "' name = 'nuevo_monto_value" + Etiqueta['ID'] + "' type = 'hidden' value = '" + Etiqueta['nro_etiqueta'] + "' /></td ></tr ></table > "
        } else {
            strHTML = strHTML + readOnly + " /><input id='nuevo_monto_value" + Etiqueta['ID'] + "' name='nuevo_monto_value" + Etiqueta['ID'] + "' type='hidden' value='" + Etiqueta['nro_etiqueta'] + "'/></td></tr></table>"
        }
        return strHTML
    }


    this.set_etiqueta = function (id, value) {
        var Etiquetas = this.Etiquetas

        for (let i in Etiquetas) {
            if ((typeof id == 'number' && Etiquetas[i]['nro_etiqueta'] == id) || (typeof id == 'string' && Etiquetas[i]['HD'] == id)) {
                Etiquetas[i]['valor'] = value;
            }
        }
    }


    this.suma_etiqueta = function (id, indice) {
        var maxMontos = this.maxMontos
        var Etiquetas = this.Etiquetas
        if (!indice)
            indice = maxMontos + 1
        var suma = 0
        for (var i = 1; i <= maxMontos; i++) {
            if ((typeof id == 'number' && Etiquetas[i]['nro_etiqueta'] == id) || (typeof id == 'string' && Etiquetas[i]['HD'] == id)) {
                switch (Etiquetas[i]['tipo_dato'].toUpperCase()) {
                    case 'S':
                        suma = Etiquetas[i]['valor']
                        break
                    case 'D':
                        suma = Etiquetas[i]['valor']
                        break
                    case 'B':
                        suma = Etiquetas[i]['valor']
                        break

                    default:
                        suma = suma + parseFloat(Etiquetas[i]['valor'])
                }
            }
        }
        return suma
    }

    this.min_etiqueta = function (id, indice) {
        var Etiquetas = this.Etiquetas
        if (!indice) {
            var indice = 0
            for (var i in Etiquetas) {
                indice = parseInt(i) + 1
            }
        }
        var min = undefined
        for (var i = 1; i < indice; i++) {
            if ((typeof id == 'number' && Etiquetas[i]['nro_etiqueta'] == id) || (typeof id == 'string' && Etiquetas[i]['HD'] == id)) {
                switch (Etiquetas[i]['tipo_dato'].toUpperCase()) {
                    case 'S':
                        min = Etiquetas[i]['valor']
                        break
                    case 'D':
                        min = Etiquetas[i]['valor']
                        break
                    case 'B':
                        min = Etiquetas[i]['valor']
                        break
                    default:
                        if ((min > Etiquetas[i]['valor']) || (min == undefined))
                            min = Etiquetas[i]['valor']
                }
            }
        }

        return min
    }

    this.focus_first = function () {
        var Etiquetas = this.Etiquetas
        //try{
        for (var i in Etiquetas) {
            if (Etiquetas[i]['visible']) {
                $('nuevo_monto' + i).focus()
                $('nuevo_monto' + i).select()
                return true
            }
        }
        //}
        //catch(e)
        //{}
    }


}

var analisis = new tnvAnalisis()


var strBC = 'BACKGROUND-COLOR: #F8FFFE'


var gets = {}
function get(element, params) {
    try {
        var p
        var e = gets[element]
        var b = true
        for (p in gets[element]["params"])
            if (gets[element]["params"][p] != params[p])
                b = false
        if (b)
            return gets[element]["value"]
    }
    catch (e) { }
    var rs = new tRS()
    var f = "dbo." + element
    var strp = "("
    for (p in params) {
        if (p != "__proto__")
            if (typeof (params[p]) == "string")
                params[p] = params[p].replace(/'/g, "&apos;")
        strp += "," + params[p]
    }
    strp += ")"
    strp = strp.replace("(,", "(")

    f = f + strp

    //var str = "<criterio><select vista='analisis'><campos>" + f + " as value</campos><filtro><nro_analisis type='igual'>" + $('cbAnalisis').value + "</nro_analisis></filtro></select></criterio>"
    //rs.open(str)
    rs.cacheControl = 'nvFW';
    rs.open({ filtroXML: nvFW.pageContents["analisis_valor"], params: "<criterio><params fun='" + f + "' nro_analisis='" + campos_defs.get_value('cbAnalisis') + "' /></criterio>" })
    gets[element] = {}
    gets[element]["params"] = params
    gets[element]["value"] = rs.getdata("value")
    return gets[element]["value"]
}









function tab(ev, i) {
    i = i + 1
    var keyCode = document.layers ? ev.which : document.all ? event.keyCode : document.getElementById ? ev.keyCode : 0;
    //if (keyCode !=13) return true;
    if (keyCode == 13) {
        //if($('nuevo_monto'  + i).getHeight() > 0)
        //{
        $('nuevo_monto' + i).focus()
        $('nuevo_monto' + i).select()
        //}
        //else {
        //  tab(ev,i)
        //  }
        return false;
    }

}

function valDigito2(e, strCaracteres, i) {
    i = i + 1
    var key
    if (window.event) // IE
        key = e.keyCode;
    else
        key = e.which;

    if (key == 9 || key == 8 || key == 27 || key == 0)
        return true
    if (key == 13) {
        try {
            if ($('nuevo_monto' + i).getHeight() > 0) {
                $('nuevo_monto' + i).focus()
                $('nuevo_monto' + i).select()
            }
            else {
                $('nuevo_monto' + i).blur()
                valDigito2(e, strCaracteres, i)

            }
            return true
        }
        catch (e) {
            return true
        }

    }

    if (!strCaracteres) strCaracteres = ''

    var strkey = String.fromCharCode(key)
    var encontrado = strCaracteres.indexOf(strkey) != -1

    if (((strkey < "0") || (strkey > "9")) && !encontrado)
        return false

}




