var origen = ''
var consultardisponibleeducacion=0
function CargarAnalisis(nro_analisis)
{
  
  //if (!nro_analisis)  
  //  nro_analisis = GetCookie('nro_analisis')

    //$('cbAnalisis').options.length = 0
    campos_defs.habilitar("cbAnalisis", true)
    campos_defs.clear_list("cbAnalisis")

    var nro_banco = campos_defs.get_value('banco') //$('banco').value
    var nro_mutual = campos_defs.get_value('mutual') //$('mutual').value
    form1.nro_mutual.value=nro_mutual
  //var nro_sistema = $('nro_sistema').value
  //var nro_lote = $('nro_lote').value
  var criterio = ""
  criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_grupo type='igual'>" + nro_grupo + "</nro_grupo><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
  //if (((nro_sistema == "0") && (nro_lote == "0")) && (nro_grupo != 0))
  //  criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_grupo type='igual'>" + nro_grupo + "</nro_grupo><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
  //else  
  //  criterio = "<nro_banco type='igual'>" + nro_banco + "</nro_banco><nro_sistema type='igual'>" + nro_sistema + "</nro_sistema><nro_lote type='igual'>" + nro_lote + "</nro_lote><nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"
 
  var i = 0   
  if ((permisos_web2 & 32) > 0)  
    criterio += "<permiso_tabla type='sql'>dbo.rm_tiene_permiso('permisos_tablas_comercios',permiso_tabla) = 1</permiso_tabla>"
 
 var es_debito=(nro_tipo_cobro==4)?1:0
  criterio += "<permiso_analisis type='sql'>dbo.rm_tiene_permiso('permisos_analisis',permiso_analisis) = 1</permiso_analisis><aplica_precarga type='igual'>1</aplica_precarga><cbu type='igual'>"+es_debito+"</cbu>"

  var rs = new tRS();
    rs.onComplete = function (rs) {           
        campos_defs.items['cbAnalisis'].rs = rs        
        campos_defs.items['cbAnalisis']['onchange'] = cbAnalisis_onchange
        if(!nro_analisis){
        campos_defs.set_first('cbAnalisis')  
        }else{
          campos_defs.set_value('cbAnalisis',nro_analisis)  
        }
        campos_defs.habilitar("cbAnalisis", false)
        if(!motor.tiene_ofertas()){
          if (rs.recordcount == 1) campos_defs.habilitar("cbAnalisis", false)
          else campos_defs.habilitar("cbAnalisis", true)  
        }else{
          if (rs.recordcount > 1) campos_defs.habilitar("cbAnalisis", true) //agregado para los analisis que si tieen mas de un analisis
        }
        
      } 

  rs.open({ filtroXML: nvFW.pageContents["analisis_cargar"], filtroWhere: criterio }) 
   
      
}

var maxMontos = 0;
var Etiquetas = {}

var maxCancelaciones = 0;
var array_campos_defs = {}

function analisis_mostrar(nro_analisis)
  {
  var strHTML = ""
  var strHTML_No_Visible = ""
  var cont = 0;
  var maxcont = 0;
  var calculoBanco;
    var nro_banco = campos_defs.get_value('banco')// $('banco').value
  if (!nro_analisis)
      nro_analisis = campos_defs.get_value('cbAnalisis') //$('cbAnalisis').value
  //$('nro_analisis').value = $('cbAnalisis').value  
  //Borrar analisis previo
  maxMontos = 0;
  Etiquetas = {}
  var Etiqueta = {}
  var filas = 0
  var colum_width = 0  
  
//  var xmlCriterio = "<criterio><select vista='verEtiqueta_analisis'><campos>Orden,Nro_Etiqueta,etiqueta,Visible,Calculado,Color,Nro_Analisis,analisis,ultimo,HD,Comentario,css_style,tipo_dato,css_style_input,Calculo,editable,dbo.rm_an_calculobanco(nro_analisis, nro_etiqueta, orden, " + nro_banco + ") as CalculoBanco</campos><filtro><nro_analisis type='igual'>" + nro_analisis + "</nro_analisis></filtro><orden>orden</orden></select></criterio>"
  var rs = new tRS();
  rs.asyc = true
  rs.onComplete = function (rs)
    {
      while (!rs.eof()) 
        {
        if ((rs.getdata('ultimo') == 'True') && (ismobile == false))
            filas++
        maxMontos++
        Etiquetas[maxMontos] = {}
        Etiqueta = Etiquetas[maxMontos]
        Etiqueta['ID'] = maxMontos
        Etiqueta['orden'] = rs.getdata('Orden')
        Etiqueta['nro_etiqueta'] = rs.getdata('Nro_Etiqueta')
        Etiqueta['etiqueta'] = rs.getdata('etiqueta')
        Etiqueta['visible'] =  eval(rs.getdata('Visible').toLowerCase())
        Etiqueta['calculado'] =  eval(rs.getdata('Calculado').toLowerCase())
        Etiqueta['color'] = rs.getdata('Color')
        Etiqueta['calculoBanco'] = rs.getdata('CalculoBanco')
        Etiqueta['nro_analisis'] = rs.getdata('Nro_Analisis')
        Etiqueta['analisis'] = rs.getdata('analisis')
        Etiqueta['ultimo'] = eval(rs.getdata('ultimo').toLowerCase())
        Etiqueta['HD'] = rs.getdata('HD')
        Etiqueta['comentario'] = rs.getdata('Comentario')
        Etiqueta['css_style'] = rs.getdata('css_style')
        Etiqueta['tipo_dato'] = rs.getdata('tipo_dato')
        Etiqueta['editable'] = eval(rs.getdata('editable').toLowerCase())
        Etiqueta['css_style_input'] = rs.getdata('css_style_input')        
        if (Etiqueta['calculoBanco'] == null)
            Etiqueta['calculo'] = rs.getdata('Calculo')
        else
            Etiqueta['calculo'] = Etiqueta['calculoBanco']    
        rs.movenext()
        }    
    }
    rs.open({ filtroXML: nvFW.pageContents["etiqueta_analisis"], params: "<criterio><params nro_banco='" + nro_banco + "' nro_analisis='" + nro_analisis + "' /></criterio>" })  
  //rs.open(xmlCriterio)    

  filas++        
  colum_width = 100 / filas

    var i = 0  
    strHTML = "<table class='tb1' width='100%'><tr><td style='width:" + colum_width + "%; vertical-align:top'>"
    for(i in Etiquetas)
      {
      Etiqueta = Etiquetas[i]
      if(Etiqueta['visible']) {
          strHTML = strHTML + analisis_add_etiqueta_new(Etiqueta)
        if ((Etiqueta['ultimo']) && (ismobile == false))
          strHTML = strHTML + "</td><td style='width:" + colum_width + "%; vertical-align:top'>"
        }  
      else
          strHTML_No_Visible = strHTML_No_Visible + analisis_add_etiqueta_new(Etiqueta)
        
      nro_analisis = Etiqueta['nro_analisis']
      }
      strHTML = strHTML + "</td></tr></table>"



    //if (nro_analisis_actual != nro_analisis) 
    // {
     $('divHaberes').innerHTML = ""
     $('divHaberesNoVisibles').innerHTML = ""
     /*divHaberes.insertAdjacentHTML("BeforeEnd",strHTML)
     divHaberesNoVisibles.insertAdjacentHTML("BeforeEnd",strHTML_No_Visible)  */
     $('divHaberes').insert({bottom:strHTML})
     $('divHaberesNoVisibles').insert({bottom:strHTML_No_Visible})
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

    nro_analisis_actual = nro_analisis
    
    BCRA_situacion = 0 
    analisis_actualizar(true)  
    if (!ismobile)
    analisis_posicionar_foco()
  
  }

function analisis_actualizar(carga_inicial) 
  {     
  var Etiqueta;
  var index
  tiene_seguro = 0   	
  //17 es total de cancelaciones
  
  for (index in Etiquetas)
    {
    if (Etiquetas[index]["nro_etiqueta"] == 93)
      var sit_bcra_eti = $('nuevo_monto' + index) 
    if (Etiquetas[index]["nro_etiqueta"] == 17)
      var TotalCancelaciones = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
    if (Etiquetas[index]["nro_etiqueta"] == 1007)
       var TotalCancelVenc = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
    if (Etiquetas[index]["nro_etiqueta"] == 1008)
      var TotalCancelNoVenc = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
    if (Etiquetas[index]["nro_etiqueta"] == 1009)
       var TotalCancelCupo = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
    if (Etiquetas[index]["nro_etiqueta"] == 1010)
        var TotalCancelCuotas = $('nuevo_monto' + index) // eval("form1.nuevo_monto" + parseInt(idCancelaciones))
    if (Etiquetas[index]["nro_etiqueta"] == 489)
        tiene_seguro = $('nuevo_monto' + index).value == 'SI' ? 1 : 0
    }

  //Cargar situacion BCRA
  if (sit_bcra_eti != undefined)
   {
     if(parseInt(sit_bcra_eti.value) > 0 && $('sit_bcra').value == 0)
        $('sit_bcra').value = sit_bcra_eti.value
     else
       if($('sit_bcra').value > 0 && $('sit_bcra').value <= 6)
          sit_bcra_eti.value = formatoDecimal(parseFloat($('sit_bcra').value),2)
   }    

  if (TotalCancelaciones != undefined)
      TotalCancelaciones.value = 0
  if (TotalCancelVenc != undefined)
      TotalCancelVenc.value = 0   
  if (TotalCancelNoVenc != undefined)
      TotalCancelNoVenc.value = 0
  if (TotalCancelCupo != undefined)
      TotalCancelCupo.value = 0       
  if (TotalCancelCuotas != undefined)
      TotalCancelCuotas.value = 0                     
 
  $('saldo_a_cancelar').innerHTML = 0
  var saldo_a_cancelar = 0
  for (h in Cancelaciones)
    {
    if (TotalCancelaciones != undefined)
      TotalCancelaciones.value = formatoDecimal(parseFloat(TotalCancelaciones.value) + parseFloat(Cancelaciones[h]['cancela_cuota']),2)
    if ((Cancelaciones[h]['deuda_vencida'] == true) && (TotalCancelVenc != undefined))
      TotalCancelVenc.value = formatoDecimal(parseFloat(TotalCancelVenc.value) + parseFloat(Cancelaciones[h]['cancela_cuota']),2)
    if ((Cancelaciones[h]['deuda_vencida'] == false) && (TotalCancelNoVenc != undefined))
      TotalCancelNoVenc.value = formatoDecimal(parseFloat(TotalCancelNoVenc.value) + parseFloat(Cancelaciones[h]['cancela_cuota']),2)            
    if (TotalCancelCupo != undefined)  
      TotalCancelCupo.value = formatoDecimal(parseFloat(TotalCancelCupo.value) + parseFloat(Cancelaciones[h]['cancela_cupo']),2)
    if (TotalCancelCuotas != undefined)  
      TotalCancelCuotas.value = formatoDecimal(parseFloat(TotalCancelCuotas.value) + parseFloat(Cancelaciones[h]['cancela_cuota']),2)      
    saldo_a_cancelar = parseFloat(saldo_a_cancelar) + parseFloat(Cancelaciones[h]['importe_pago'])
    $('saldo_a_cancelar').innerHTML = ''
    $('saldo_a_cancelar').insert ({bottom: formatoDecimal(saldo_a_cancelar ,2)})
    }
    
  /*
  for (i in Etiquetas)
    switch (Etiquetas[i]["nro_etiqueta"])
      {
      case '17':
        form1.total_cancelaciones.value = parseFloat(eval("form1.nuevo_monto" + h + ".value")).toFixed(2)
        break  
      }
   */   
  analisis_calcular_valores(carga_inicial)
  total_cancelaciones = formatoDecimal($('saldo_a_cancelar').innerHTML, 2)
  haber_neto = formatoDecimal(analisis_suma_etiqueta(14), 2) //14 = hacer neto
  //if (tiene_cupo)
  //    cuota_maxima = importe_max_cuota
  //else  

  cuota_maxima = formatoDecimal(analisis_min_etiqueta(16), 2) // 16  = cuota maxima
  neto_maximo = analisis_min_etiqueta(1001) // 1001  = neto maximo
  solicitado_max = analisis_min_etiqueta(1003) // 1003  = solicitado maximo
  documentado_max = analisis_min_etiqueta(1004) // 1004  = documentado maximo
  cuotas_max = analisis_min_etiqueta(1006) // 1006  = cuotas maximo
  importe_cuota = analisis_min_etiqueta(1026) // 1026  = cuotas maximo
  $('saldo_a_cancelar').innerHTML = ""
  $('saldo_a_cancelar').insert({bottom: "$ " + total_cancelaciones})
  $('haber_neto').innerHTML = ""
  $('haber_neto').insert({bottom: "$ " + haber_neto})
  $('importe_max_cuota').innerHTML = ""
  /*if(!motor.tiene_ofertas() || carga_inicial){
  importe_max_cuota = cuota_maxima    
  }*/

  if(carga_inicial || motor.datos.es_poder_judicial=='1' || !motor.tiene_ofertas()){
    importe_max_cuota=parseFloat(cuota_maxima)
  }
  //importe_max_cuota = cuota_maxima    
  var cuota_maxima_analisis=(carga_inicial || motor.datos.es_poder_judicial=='1' || !motor.tiene_ofertas())? parseFloat(cuota_maxima):parseFloat(importe_max_cuota) //parseFloat(carga_inicial?cuota_maxima :importe_max_cuota) //este importe cuota , es un valor global q puede traer valor desde las cancelaciones
  /*if(!carga_inicial){
   cuota_maxima_analisis = parseFloat(cuota_maxima)+parseFloat(importe_max_cuota) //este importe es un valor de la cuota maxima disponible en funcion del calculo del analisis, por eso se puede sumar a las cancelaciones, si es q se van a liberar cuotas
  }*/
  

  var str_cuota_maxima = (parseFloat(cuota_maxima_analisis) > 0) ? "<font color='green'><b>$ " + cuota_maxima_analisis.toFixed(2) + "</b></font>" : "<font color='red'><b>$ " + cuota_maxima_analisis.toFixed(2) + "</b></font>"
  $('importe_max_cuota').insert({bottom: str_cuota_maxima })
  
  //$('strCuotaMaxima').innerHTML = ""
  //$('strCuotaMaxima').insert({ bottom: '$ ' + parseFloat(importe_max_cuota).toFixed(2) })
  //if (origen == 'precarga')
  //    $('ifrplanes').src='enBlanco.htm'
  }


  var strBC = 'BACKGROUND-COLOR: #F8FFFE'

  function analisis_add_etiqueta(Etiqueta, valor) {
   var readOnly = "";
   var Indice = "";
   var comentario = ""
   var i = 0 
   if(Etiqueta['editable'] == false)
     {
     readOnly = "readonly"
     }
   if(Etiqueta['calculado'])
     {
     //readOnly = "readonly"
     Indice = "(c)"
     }
   if(Etiqueta['comentario']!= '')
     {
     comentario = " - " + Etiqueta['comentario']
     }         
   if(!Etiqueta['visible'])
     visible = "style='DISPLAY: none'"
   else
    {
    if (strBC == 'BACKGROUND-COLOR: #F8FFFE')
        strBC = 'BACKGROUND-COLOR: #E9F0F4'
    else
        strBC = 'BACKGROUND-COLOR: #F8FFFE'
    }
   if (!valor)  
     {
     switch (Etiqueta['tipo_dato'] )
       {
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
     strHTML = "<table class='tb1' cellspacing='0' cellpadding='0'><tr><td style='" + Etiqueta['css_style'] + "; width:100%; vertical-align: middle !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;'>&nbsp;" 
   //strHTML = "<table class='tb1' ><tr><td style='" + Etiqueta['css_style'] + "; vertical-align: middle'>"
   if ((Etiqueta["nro_etiqueta"] == 8) && (origen == 'precarga')) 
       valor = importe_cs_analisis
   if ((Etiqueta["nro_etiqueta"] == 389) && (origen == 'precarga'))
      valor = cupo_disponible
   if (Etiqueta["nro_etiqueta"] == 93)
     {
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
   strHTML = strHTML + Etiqueta['etiqueta'] + " " +  Indice + comentario + "</td>" + "<td><input id='nuevo_monto" + Etiqueta['ID'] + "' name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial;border-style: double'"
   //strHTML = strHTML + Etiqueta['etiqueta'] + " " +  Indice + "</td>" + "<td style='width: 20%'><input name='nuevo_monto" + Etiqueta['ID'] + "' style='" + Etiqueta['css_style'] + "; width: 100%; TEXT-ALIGN: right'"
   
   switch (Etiqueta['tipo_dato'] )
       {
       case 'M':
          strHTML = strHTML + " value='" + valor + "' onchange='validarNumero(event,\"0.00\"); analisis_actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "  //valDigitoOtro(event,\".+-*/\") //valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")
          break
       case 'I':
          strHTML = strHTML + " value='" + valor + "' onchange='analisis_actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' " 
          break
       case 'D':
          strHTML = strHTML + " value='" + valor + "' onchange='valFecha(event); analisis_actualizar(false)' onkeypress='return valDigito2(event,\"/\"," + Etiqueta['ID'] + ")' " //valDigitoVBS(event) 
          //i = i + 1
          //array_campos_defs[i] = {}
          //array_campos_defs[i]['parametro'] = Etiqueta['ID']
          //array_campos_defs[i]['tipo_dato'] = 'datetime'
          //array_campos_defs[i]['campo_def'] = ''
          //array_campos_defs[i]['target'] = 'nuevo_monto' + Etiqueta['ID']  
          //strHTML = strHTML + " value='" + valor + "' "
          break         
       case 'S':
          strHTML = strHTML + " value='" + valor + "' onchange='analisis_actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "  
          break
       case 'B':
          strHTML = strHTML + " type='checkbox'  onclick='analisis_actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "  
          break   
       }
   
   if(Etiqueta["nro_etiqueta"] == 93){
    strHTML = strHTML +  " onblur='onblur_BCRA_situacion()' "
   }

   strHTML = strHTML + readOnly + " /><input id='nuevo_monto_value" + Etiqueta['ID'] + "' name='nuevo_monto_value" + Etiqueta['ID'] + "' type='hidden' value='" + Etiqueta['nro_etiqueta'] + "'/></td></tr></table>"
   return strHTML
}

function analisis_calcular_valores(carga_inicial)
  {
  var calculo;
  var pos1;  
  var pos2;
  var nro_etiqueta;
  for(var i in Etiquetas)
    {
    if(Etiquetas[i]['calculado'] 
      //&& parseInt(Etiquetas[i]['nro_etiqueta']) != 17  //!!!verr
      && parseInt(Etiquetas[i]['nro_etiqueta']) != 93 
      && parseInt(Etiquetas[i]['nro_etiqueta']) != 1024)
      {      
      if ((Etiquetas[i]['editable'] == true && carga_inicial == true) || (Etiquetas[i]['editable'] == false))
          { 
          calculo = Etiquetas[i]['calculo']
          
          for(var j=1; j<=i;j++)
            {
            nro_etiqueta = Etiquetas[j]['nro_etiqueta']
            while (calculo.indexOf('%' + nro_etiqueta + "%") != -1)
              calculo = calculo.replace('%' + nro_etiqueta + "%", '(' + analisis_suma_etiqueta(nro_etiqueta, i) + ')')
            }
          for(var j=1; j<=i;j++)
            {
            nro_etiqueta = Etiquetas[j]['nro_etiqueta']
            while (calculo.indexOf('$' + nro_etiqueta + "$") != -1)
              calculo = calculo.replace('$' + nro_etiqueta + "$", '(' + analisis_min_etiqueta(nro_etiqueta, i) + ')')
          }
          
          switch (Etiquetas[i]['tipo_dato']) 
            {
              //si calculo es vacio , pone NaN
            case 'M':  
              $('nuevo_monto' + i).value = parseFloat(eval(calculo)).toFixed(2)
              break
           case 'I':                  
              $('nuevo_monto' + i).value = parseInt(eval(calculo))
              break  
            case 'D':
              $('nuevo_monto' + i).value = FechaToSTR(eval(calculo))
              break
            case 'S':
              $('nuevo_monto' + i).value = eval(calculo)
              break          
            case 'B':
              $('nuevo_monto' + i).value = eval(calculo)
              break            
              
            }
			   
          if ($('span_monto_' + i))   $('span_monto_' + i).innerText = $('nuevo_monto' + i).value
            }
      
      }
    }
    //console.log("set_campos")
    motor.set_campos()        
  }

function analisis_suma_etiqueta(nro_etiqueta, indice)
  {  
  if (!indice)
    indice = maxMontos+1
  var suma = 0
  for(var i=1;i<=maxMontos;i++)
    {
    if(Etiquetas[i]['nro_etiqueta'] == nro_etiqueta)
      {            
      switch (Etiquetas[i]['tipo_dato'].toUpperCase())
        {
        case 'S':
          suma = "'" + $('nuevo_monto' + i).value + "'"
          break
        case 'D':
          suma = "'" + $('nuevo_monto' + i).value + "'"
          break  
        case 'B':
          suma = $('nuevo_monto' + i).checked 
          break
            
        default:
          suma = suma + parseFloat($('nuevo_monto' + i).value)
        }
      }  
    }
  return suma  
  }

function analisis_min_etiqueta(nro_etiqueta, indice)
 {  
  if (!indice)
    {
    var indice = 0
    for (var i in Etiquetas) {
        indice = parseInt(i) + 1
        }
    }
  var min = undefined
  for(var i=1;i<indice;i++)
    {
    if(Etiquetas[i]['nro_etiqueta'] == nro_etiqueta)
      {
      switch (Etiquetas[i]['tipo_dato'].toUpperCase())
        {
        case 'S':
          min = "'" + $('nuevo_monto' + i).value + "'"    
          break
        case 'D':
          min = "'" + $('nuevo_monto' + i).value + "'"    
          break          
        case 'B':
          min =  $('nuevo_monto' + i).checked  
          break  
        default:  
          if ((min > parseFloat($('nuevo_monto' + i).value)) || (min == undefined))
            min = parseFloat($('nuevo_monto' + i).value)
        }
      }  
    }
  return min  
  }  

  var gets = {}
  function get(element, params)
    {
    try
      {
      var p
      var e = gets[element]
      var b = true
      for (p in gets[element]["params"])
        if (gets[element]["params"][p] != params[p])
          b = false
      if (b)  
        return gets[element]["value"]
      }
    catch(e){}  
    var rs = new tRS()
    var f = "dbo." + element 
    var strp = "("
    for (p in params)
        {
        if (p != "__proto__")
            if (typeof(params[p]) == "string")
                params[p] = params[p].replace(/'/g,"&apos;")
        strp +=  "," + params[p]
        }      
    strp += ")"
    strp = strp.replace("(,", "(")
    
    f = f + strp
    
    //var str = "<criterio><select vista='analisis'><campos>" + f + " as value</campos><filtro><nro_analisis type='igual'>" + $('cbAnalisis').value + "</nro_analisis></filtro></select></criterio>"
    //rs.open(str)
      rs.open({ filtroXML: nvFW.pageContents["analisis_valor"], params: "<criterio><params fun='" + f + "' nro_analisis='" + campos_defs.get_value('cbAnalisis')  + "' /></criterio>" })
    gets[element] = {}
    gets[element]["params"] = params
    gets[element]["value"] = rs.getdata("value")
    return gets[element]["value"]
    }

function tab(ev,i){ 
    i = i+1
    var keyCode = document.layers ? ev.which : document.all ? event.keyCode : document.getElementById ? ev.keyCode : 0;
    //if (keyCode !=13) return true;
    if(keyCode ==13){
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

function valDigito2(e, strCaracteres,i)
 { 
 i = i+1
 var key 
 if(window.event) // IE
   key = e.keyCode;
 else 
   key = e.which;
     
  if (key == 9 || key == 8 || key == 27 || key == 0)
      return true
  if (key == 13){
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
      catch (e) {    return true      
      }

     }

  if(!strCaracteres) strCaracteres = ''
  
  var strkey = String.fromCharCode(key)
  var encontrado = strCaracteres.indexOf(strkey) != -1
  
  if (((strkey < "0") || (strkey > "9")) && !encontrado)
    return false
    
  }

 function analisis_posicionar_foco(){ 
   
   //try{
   for(var i in Etiquetas){
   if (Etiquetas[i]['visible']){   
        $('nuevo_monto' + i).focus()
        $('nuevo_monto' + i).select()
        return
        }        
   }
   //}
   //catch(e)
   //{}
  }
var aux_analisis_old
function cbAnalisis_onchange() 
{   
    if (aux_analisis_old == campos_defs.get_value("cbAnalisis") && campos_defs.get_value("mutual")=="")
        return
    else
  analisis_mostrar()
    aux_analisis_old = campos_defs.get_value("cbAnalisis")
    
    if ((nro_tipo_cobro == 1) && (tiene_cupo) && campos_defs.get_value("cbAnalisis") != '') {
        $('selplan').checked = true
        selplan_on_click()
        $('chkmax_disp').checked = true
        btnBuscarPLanes_onclick()
        nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
    }
}

var info_recibo_nro_lote = 0
var info_recibo_nro_sistema = 0
var analisis_clave_sueldo = 0



function analisis_add_etiqueta_new(Etiqueta, valor) {
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
            strHTML = strHTML + " value='" + valor + "' onchange='validarNumero(event,\"0.00\"); analisis_actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "  //valDigitoOtro(event,\".+-*/\") //valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")
            break
        case 'I':
            strHTML = strHTML + " value='" + valor + "' onchange='analisis_actualizar(false)' onkeypress='return valDigito2(event,\".+-*/\"," + Etiqueta['ID'] + ")' "
            break
        case 'D':
           
            strHTML = strHTML + " value='" + valor + "' onchange='valFecha(event); analisis_actualizar(false)' onkeypress='return valDigito2(event,\"/\"," + Etiqueta['ID'] + ")' " //valDigitoVBS(event) 
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
            strHTML = strHTML + " value='" + valor + "' onchange='analisis_actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
            break
        case 'B':
            strHTML = strHTML + " type='checkbox'  onclick='analisis_actualizar(false)' onkeypress='return tab(event," + Etiqueta['ID'] + ")' "
            break
    }

    if (Etiqueta["nro_etiqueta"] == 93) {
        strHTML = strHTML + " onblur='onblur_BCRA_situacion()' "
    }
    
    if (Etiqueta['editable']  == false) {
        strHTML = strHTML + " type=hidden /><span id='span_monto_" + Etiqueta['ID'] + "'  style = '" + Etiqueta['css_style_input'] + " !Important FONT-SIZE: 12px;FONT-FAMILY: Arial; display: inline-block;border-collapse: collapse; border-radius: inherit;background: #dcdcdc;height:21px;padding-top:4px; padding-right:7px;' > " + valor + "</span > "
        strHTML = strHTML + "<input id='nuevo_monto_value" + Etiqueta['ID'] + "' name = 'nuevo_monto_value" + Etiqueta['ID'] + "' type = 'hidden' value = '" + Etiqueta['nro_etiqueta'] + "' /></td ></tr ></table > "
    } else {
        strHTML = strHTML + readOnly + " /><input id='nuevo_monto_value" + Etiqueta['ID'] + "' name='nuevo_monto_value" + Etiqueta['ID'] + "' type='hidden' value='" + Etiqueta['nro_etiqueta'] + "'/></td></tr></table>"
    }
    return strHTML
}





function rserror_handler(msg) {
            nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            nvFW.alert(msg, { onClose: function () { Precarga_Limpiar() } })
}



/*defino el objeto motor para su uso en el ambito*/
var motor={ofertas:{},datos:{},
tiene_mensaje:function(){  
  var ret=false;
  if(this.datos){
    if(this.datos.mensaje_usuario){
      ret=true
    }
  }
  return ret;
},//tiene_mensaje
tiene_ofertas:function(){ //funcion que devuelve si tengo ofertas disponibles  

  var ret=false;
  var ret=((this.ofertas)?1:0)
  if(ret){
    ret=(this.ofertas.length>0)
  }
  return ret;
},//tiene_ofertas
  get:function(etiqueta){
   var retorno=''
    switch (etiqueta) {
    case 'sueldo_bruto':
      retorno=(this.datos.sueldo_bruto)?this.datos.sueldo_bruto:"0"
      break;
    case 'sueldo_neto':
      retorno=(this.datos.sueldo_neto)?this.datos.sueldo_neto:"0"
      break;
    case 'disponible':    
    var importe_disponible=0;
      //importe_disponible=parseFloat((this.datos.trabajo)?this.datos.trabajo.disponible:"0")
      importe_disponible=parseFloat((this.datos.cupo_disponible)?this.datos.cupo_disponible:"0")
      
      
      retorno=importe_disponible
      break;
    case 'desc_ley':
      retorno=(this.datos.desc_ley)?this.datos.desc_ley:"0"
      break;
    case 'cuota_maxima':
    if(!this.tiene_ofertas()) return "";
      var nro_banco=$F("banco")
      var nro_mutual=$F("mutual")
      var nro_analisis=$F('cbAnalisis')      
      var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis) 
      if(aOferta.length>0)
      {var cuota_maxima=aOferta[0].cuota_maxima
       var importe_cuota_social= +this.get('importe_cs')
        if(importe_cuota_social>0){
          cuota_maxima=cuota_maxima-importe_cuota_social
        }
       retorno=cuota_maxima
      }
    break;
    case 'neto_maximo':
    if(!this.tiene_ofertas()) return "";
      var nro_banco=$F("banco")
      var nro_mutual=$F("mutual")
      var nro_analisis=$F('cbAnalisis')      
      var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis) 
      if(aOferta.length>0)
      {
       retorno=aOferta[0].neto_maximo
      }
      
      
    break;
    case 'max_cuotas':
      if(!this.tiene_ofertas()) return "";
      var nro_banco=$F("banco")
      var nro_mutual=$F("mutual")
      var nro_analisis=$F('cbAnalisis')      
      var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis) 
      if(aOferta.length>0)
      {
       retorno=aOferta[0].max_cuotas
      }
      
      
    break;
    case 'bcra_calificacion_cendeu':
    retorno=this.datos.bcra_calificacion_cendeu
    break;
    case 'estado':
    if(!this.tiene_ofertas()) return "";
    var nro_banco=$F("banco")
    var nro_mutual=$F("mutual")
    var nro_analisis=$F('cbAnalisis')      
    var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis) 
    if(aOferta.length>0)
    {
     retorno=aOferta[0].estado
    } 
    break;
    case 'importe_cs':     
    var importe_cs=0   
    var nro_grupo=this.datos.nro_grupo    
    var nro_mutual=$F("mutual")
    var socio_nuevo=(this.datos.socio_nuevo)?this.datos.socio_nuevo:"0"
    if(socio_nuevo=="1"){
        var rsN = new tRS()
        rsN.async = false
        rsN.open({
            filtroXML: nvFW.pageContents["precarga_cuota_social"],
            params: "<criterio><params nro_grupo='" + nro_grupo + "' nro_mutual='" + nro_mutual + "' /></criterio>"
        })
        if(!rsN.eof()) {
        importe_cs=rsN.getdata('importe_cuota');                        
        }
    }//if socio_nuevo
    retorno=importe_cs
    break;
    default:
  }//switch   
  return retorno;
 },//funcion get
  set_campos:function(){ //actualiza campos de la vista en funcion del banco/mutual/analisis seleccionado
    if(!this.tiene_ofertas()) return;

    var nro_banco=$F("banco")
    var nro_mutual=$F("mutual")
    var nro_analisis=$F('cbAnalisis')      
    var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis) 
    if(aOferta.length>0)
    {
     var neto_maximo=aOferta[0]['neto_maximo']
     campos_defs.habilitar('retirado_hasta', true)
     campos_defs.set_value('retirado_hasta',neto_maximo)
     //campos_defs.items['retirado_hasta']['onchange'] = 
     
     //campos_defs.habilitar('retirado_hasta', false)
     Element.writeAttribute("retirado_hasta","onkeyup","return evaluar_retirado_hasta(event,"+neto_maximo+")");
     var max_cuotas=aOferta[0]['max_cuotas']
     campos_defs.habilitar('cuota_hasta', true)
     campos_defs.set_value('cuota_hasta',max_cuotas)
     //si no hay cancelaciones seleccionadas, lo desactivo
     if($$("[id*='chkCred']:checked").length==0){
     campos_defs.habilitar('cuota_hasta', false) 
     }else{
      campos_defs.set_value('cuota_hasta','')
     }
     
    } 
      
      
  },//set_campos
  reset:function(){
   this.ofertas={}; 
   this.datos={};
  }
}//motor


function evaluar_retirado_hasta(event,neto_maximo){
      var valido=/^[0-9]$/i.test(event.key)
      if(valido){
        var valor= +$F("retirado_hasta")
        console.log(valor)
        var max= +neto_maximo
        if(valor>max){
          console.log("no valido")
          valido=false;
        campos_defs.set_value('retirado_hasta',max)
        }
      }
      return valido;
}

/*function input_max(campo,max){
  
var valor= +$F(campo)
if(valor>max){
  campos_defs.set_value('retirado_hasta',max)
}
}*/

var ofertas=new Array()




function rsdataToArray(xmlText){
var txt = document.createElement('textarea');
txt.innerHTML = xmlText;
var rsdatatext=txt.value
txt=null;
var columnas=new Array();
var filas=new Array();
 var objXML = new tXML();
 objXML.async = false
 if (objXML.loadXML(rsdatatext)){
  var campos=objXML.selectNodes('/xml/s:Schema/s:ElementType/s:AttributeType')
   for(var i = 0; i < campos.length; i++)
   {
   var columna=campos[i].getAttribute('name')
   columnas.push(columna)
   }
   var rsdatarows = objXML.selectNodes('/xml/rs:data/z:row')
   for(var i = 0; i < rsdatarows.length; i++)
   {
    var fila={}
     for(var j=0;j<columnas.length;j++){
      var valor=rsdatarows[i].getAttribute(columnas[j])
      var cab=objXML.selectSingleNode("/xml/s:Schema/s:ElementType/s:AttributeType[@name='"+columnas[j]+"']")
      var type=cab.childNodes[0].getAttribute("dt:type") 
      switch (type) {
      case "i8":    
      valor= +valor
      break;
      case "int":    
      valor= +valor
      break;
      case "number":  
      valor=parseFloat(valor)  
      break;  
      default:  
    }       
      fila[columnas[j]]=valor
     }
   filas.push(fila)
   }
 }
 return filas;

}



var displayProductosMotor=function(){
  var datos=motor['datos']   
    datos['rechaza_motor']= motor['datos']['rechaza_motor'];    
      drawOferta(datos)
      var ofertas=motor['ofertas']
      if(ofertas.length>0){
       var nro_banco=ofertas[0]['nro_banco']
       campos_defs.set_value('banco',nro_banco) 
       var nro_mutual=ofertas[0]['nro_mutual']

       //obtengo los array de las mutuales que tienen el banco en cuestion
       //motor['ofertas'].filter(oferta=>oferta.nro_banco==nro_banco)
       
       campos_defs.set_value('mutual',nro_mutual) 
       nro_analisis=ofertas[0]['nro_analisis']
       //campos_defs.habilitar('cbAnalisis', true)
       //campos_defs.set_value('cbAnalisis',nro_analisis)
       //campos_defs.habilitar('cbAnalisis', false)
       //motor.set_campos()
       /*var neto_maximo=ofertas[0]['neto_maximo']
       campos_defs.set_value('retirado_hasta',neto_maximo)
       campos_defs.habilitar('retirado_hasta', false)
       var max_cuotas=ofertas[0]['max_cuotas']
       campos_defs.set_value('cuota_hasta',max_cuotas)
       campos_defs.habilitar('cuota_hasta', false)*/
     }
    nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')    
    //si no fue rechazado o si el rechazo no viene del motor, sino que por otro camino, cargo la pantalla
    if(motor['datos']['rechaza_motor']==0){
     Control_socio()
    }else{
       //Precarga_Limpiar()
       var limpiaronclose=true
        VerCDA(limpiaronclose)
    }
}//displayProductosMotor




var getPlan_Selected=function(){
var nro_plan_sel=-1
  var iframe = $('ifrplanes');
  if(iframe.contentDocument.forms.frmplanes){
    if(iframe.contentDocument.forms.frmplanes.rdplan){
     var radioGrp = iframe.contentDocument.forms.frmplanes.rdplan
    if (radioGrp.length == undefined)
      if (iframe.contentDocument.forms.frmplanes.rdplan.checked)
          nro_plan_sel = iframe.contentDocument.forms.frmplanes.rdplan.value
      for (i = 0; i < radioGrp.length; i++) {
          if (radioGrp[i].checked == true)
              nro_plan_sel = radioGrp[i].value
      }  
    }
  
  }

  return nro_plan_sel;
  
}



var drawOferta=function(datos){  
    //cupo_disponible = (datos['trabajo']['disponible'] == -1 || datos['es_poder_judicial']==1) ? 0 : parseFloat(datos['trabajo']['disponible']).toFixed(2)
    cupo_disponible = (datos['trabajo']['disponible'] == -1 || datos['es_poder_judicial']==1) ? 0 : parseFloat(motor.get('disponible')).toFixed(2)
    tiene_cupo = (datos['trabajo']['disponible'] == -1) ? false : true
    var nosis_cda = (datos['nosis_cda'] == undefined) ? 'No existen productos para la combinación seleccionada.' : datos['nosis_cda'] + ' - ' + datos['nosis_cda_desc']
    var nosis_cda_log = (datos['nosis_cda'] == undefined) ? '' : datos['nosis_cda']
    var str_edad = (datos['control_edad'] == 1) ? '<td style="color:#008000"><b>Cumple</b></td>' : '<td style="color:#800000"><b>No Cumple</b></td>'
    var str_ent_exc = (datos['ent_excluidas'] == 0) ? '<td style="color:#008000;text-align:right"><b>' + datos['ent_excluidas'] + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + datos['ent_excluidas'] + ' *</b></td>'
    var str_ch_rech = (datos['ch_rechazados'] == 0) ? '<td style="color:#008000;text-align:right"><b>' + datos['ch_rechazados'] + '</b></td>' : '<td style="color:#800000;text-align:right"><b>' + datos['ch_rechazados'] + '</b></td>'
    //dictamen = (rsN.getdata("nosis_cda") != null) ? 'APROBADO' : 'RECHAZADO'
    dictamen=datos['dictamen'].toUpperCase()
    strHTML_CDA = ''
    strHTML_CDA_noti = ''
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
    
  
    strHTML_CDA += '<tr><td style="' + dct_style + '"><b>' + dictamen + '</b></td></tr>'
    var strHTMLMensaje=""
    if(datos['mensaje_usuario']!=""){
      strHTMLMensaje="<b>OBSERVACIONES</b><br/>"+datos['mensaje_usuario'].replace("|","<br/>")
    }else{
      strHTMLMensaje="<b></b>"
    }    
    strHTML_CDA += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px">' +strHTMLMensaje  + '</td></tr></table>'

    strHTML_CDA_noti += '<tr><td style="' + dct_style + '"><b>' + dictamen + '</b></td></tr>'
    strHTML_CDA_noti += '<tr><td style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 14px"><b>' + datos['mensaje_usuario'] + '</b></td></tr></table>'
    strHTML_CDA_noti += '<table style="font-family: Verdana,Arial,Sans-serif;font-size: 12px"><tr><td><b>CUIT/CUIL:</b></td><td style="text-align:left">' + cuit + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Nombre:</b></td><td>' + nombre + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Cobro:</b></td><td>' + datos['tipo_cobro'] + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Grupo:</b></td><td>' + datos['grupo'] + '</td></tr>'
    strHTML_CDA_noti += '<tr><td><b>Edad:</b></td>' + str_edad + '</tr>'
    strHTML_CDA_noti += '<tr><td><b>Ent. Excluyentes:</b></td>' + str_ent_exc + '</tr>'
    strHTML_CDA_noti += '<tr><td><b>Cheques Rech.:</b></td>' + str_ch_rech + '</tr></table>'

    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">CUIT/CUIL</td><td class="Tit1">Nombre</td></tr>'
    strHTML_CDA += '<tr><td style="text-align:left">' + cuit + '</td><td>' + nombre + '</td></tr></table>'
    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1">Cobro</td><td class="Tit1">Grupo</td></tr>'
    strHTML_CDA += '<td>' + datos['tipo_cobro'] + '</td><td>' + datos['grupo'] + '</td></tr></table>'
    strHTML_CDA += '<table class="tb1"><tr><td class="Tit1" style="width:30%">Edad</td><td class="Tit1" style="width:30%">Ent. Excluyentes</td><td class="Tit1">Cheques Rech.</td></tr>'
    strHTML_CDA += str_edad + str_ent_exc + str_ch_rech + '</tr></table>'
    strHTML_CDA += '</tr></table>'
    $('strSitBCRA').innerHTML = ''
    sit_bcra =datos['bcra_sit']
    //sit_bcra =datos['bcra_sit_financiera'] //rsN.getdata('situacion')
    $('strSitBCRA').insert({ bottom: sit_bcra })
    $('strSitBCRA').removeClassName($('strSitBCRA').className)
    switch (sit_bcra) {
        case '1':
            $('strSitBCRA').addClassName('sit1')
            break;
        case '2':
            $('strSitBCRA').addClassName('sit2')
            break;
        case '3':
            $('strSitBCRA').addClassName('sit3')
            break;
        case '4':
            $('strSitBCRA').addClassName('sit4')
            break;
        case '5':
            $('strSitBCRA').addClassName('sit5')
            break;
        case '6':
            $('strSitBCRA').addClassName('sit6')
            break;
    }

    $('strDictamen').innerHTML = ''
    $('strDictamen').insert({ bottom: dictamen })
    $('strDictamen').removeClassName($('strDictamen').className)
    switch (dictamen) {
        case 'APROBADO':
            $('strDictamen').addClassName('cdaAC')
            break;
        case 'OBSERVADO':
            $('strDictamen').addClassName('cdaOB')
            break;
        case 'MANUAL':
        $('strDictamen').addClassName('cdaOB')
        break;
        case 'RECHAZADO':
            $('strDictamen').addClassName('cdaRC')
              break;
        case 'RECHAZAR':
            $('strDictamen').addClassName('cdaRC')
            break;
    }

      //codigo en  lo que respecta BCRA, siempre y cuando el rechazo no haya venido del motor 1538 porque si esto es asi, no muestra nada
      if(datos['rechaza_motor']!=1){
        strHTML_CDA +='<br><table style="width:100%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base {fecha_info}</td><td>Sit.</td><td></td></tr>'
        strHTML_CDA += '{tr_body_bcra}<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'    
        strHTML_CDA += '</table>' 
        strHTML_CDA_noti += '<br><table style="width:60%;font-family: Verdana,Arial,Sans-serif;font-size: 11px"><tr style="background-color: #f7f7f7;font-weight: normal;border-bottom: 1px solid #dbdbdb"><td>Entidad</td><td>Periodo</td><td>Base {fecha_info}</td><td>Sit.</td><td></td></tr>'
        strHTML_CDA_noti += '{tr_body_bcra}<tr><td colspan="5"><br>B) Recategorización obligatoria. C) Situación jurídica.</td></tr>'
        strHTML_CDA_noti += '</table>'
        var arHTML={}
        arHTML['strHTML_CDA']={}
        arHTML['strHTML_CDA_noti']={}
        arHTML['strHTML_CDA']['html']=strHTML_CDA
        arHTML['strHTML_CDA_noti']['html']=strHTML_CDA_noti
        //agrego el cuerpo de la consulta a la bd del bcra
        arHTML=BCRABodyHTML(cuit,nro_grupo,nro_tipo_cobro,nro_banco_cobro,arHTML)
        strHTML_CDA=arHTML['strHTML_CDA']['html']
        strHTML_CDA_noti=arHTML['strHTML_CDA_noti']['html']

          nro_banco = datos['nro_entidad_cda']
          CDA = datos['nosis_cda']
          campos_defs.habilitar('nro_tipo_cobro_precarga', true)
          campos_defs.set_value('nro_tipo_cobro_precarga', nro_tipo_cobro)
          campos_defs.habilitar('nro_tipo_cobro_precarga', false)
          $('divGrupo').show()
          $('strGrupo').innerHTML = ''
          if (clave_sueldo != '')
              $('strGrupo').insert({ bottom: grupo + ' (' + clave_sueldo + ')' })
          else
              $('strGrupo').insert({ bottom: grupo })
          $('strCobro').innerHTML = ''
          var strCobroDesc = (nro_tipo_cobro == 4) ? tipo_cobro + ' - ' + banco_cobro : tipo_cobro
          $('strCobro').insert({ bottom: strCobroDesc })
      }
    
}






//dado los parametros, consulta el central de deudores y lo devuelve en tr para su asignacion en los tags html
//en el array, pueden venir varias cadenas html a reemplazar
var BCRABodyHTML=function(cuit,nro_grupo,nro_tipo_cobro,nro_banco_cobro,arrHtml){
  
  var rsBCRA = new tRS()
  var color = 'green'
  var marca_exc = ''
  var style_exc = ''
  var obs = ''
  var fecha_info=''
    rsBCRA.open({
          filtroXML: nvFW.pageContents["BCRA_deudores"],
          params: "<criterio><params cuil='" + cuit + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco='" + nro_banco_cobro + "' /></criterio>"          
      })
    var strTR=""
    while (!rsBCRA.eof()) {
      fecha_info=rsBCRA.getdata('fecha_info')       
       var situacion = rsBCRA.getdata('situacion').trim()
          switch (situacion) {
              case '1':
                  color = 'green'
                  break;
              case '2':
                  color = '#FFD700'
                  break;
              case '3':
                  color = '#f0f'
                  break;
              case '4':
                  color = '#c33'
                  break;
              case '5':
                  color = 'maroon'
                  break;
              case '6':
                  color = '#000'
                  break;
          }
          hpx = hpx + 20
          marca_exc = ''
          obs = ''
          style_exc = 'text-align:left'
          if (rsBCRA.getdata('excluyente') != undefined) {
              marca_exc = '<b>*</b>'
              style_exc = 'text-align:left;font-weight: bold;color:#800000'
          }
          if (rsBCRA.getdata('recat_obligatoria') == 1)
              obs += '(B)'
          if (rsBCRA.getdata('sit_juridica') == 1)
              obs += '(C)'
          strTR += '<tr><td style="' + style_exc + '">' + rsBCRA.getdata('noment') + ' ' + marca_exc + '</td><td>' + rsBCRA.getdata('fecha_info') + '</td><td style="background-color: ' + color + ';color: #fff;text-align:right" title="' + rsBCRA.getdata('fecha_info') + '" ><b>' + rsBCRA.getdata('prestamos') + '</b></td><td style="background-color: ' + color + ';color: #fff;" title="' + rsBCRA.getdata('fecha_info') + '"><b>' + rsBCRA.getdata('situacion') + '</b></td><td>' + obs + '</td></tr>'          
          rsBCRA.movenext()
      }//while

      for(r in arrHtml){
        arrHtml[r]['html']=arrHtml[r]['html'].replace('{tr_body_bcra}',strTR)
        arrHtml[r]['html']=arrHtml[r]['html'].replace('{fecha_info}',fecha_info)
      }
      return arrHtml;    
}


var displayProductosPrecargaCDA=function(trabajo){  
                var rsN = new tRS()
                rsN.async = true
                rsN.onError = function (rsN) {
                    rserror_handler("Error al consultar los datos. Intente nuevamente.")
                }
                rsN.onComplete = function (rsN) {                  
                  var datos={}
                  datos['trabajo']=trabajo;
                  datos['nosis_cda']=rsN.getdata('nosis_cda');
                  datos['nosis_cda_desc']=rsN.getdata('nosis_cda_desc');
                  datos['control_edad']=rsN.getdata('control_edad');
                  datos['ent_excluidas']=rsN.getdata('ent_excluidas');
                  datos['ch_rechazados']=rsN.getdata('ch_rechazados');
                  datos['dictamen']=(rsN.getdata("nosis_cda") != null) ? 'APROBADO' : 'RECHAZADO'
                  datos['tipo_cobro']=rsN.getdata('tipo_cobro');
                  datos['grupo']=rsN.getdata('Grupo');
                  datos['bcra_sit_financiera']=rsN.getdata('situacion')  
                  datos['nro_entidad_cda']=rsN.getdata('nro_entidad')  
                  datos['rechaza_motor']=0;
                  datos['mensaje_usuario']="";
                  drawOferta(datos)
                  nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                  Control_socio()
                }
                rsN.open({
                    filtroXML: nvFW.pageContents["precarga_cda"],
                    params: "<criterio><params nro_vendedor='" + nro_vendedor + "' nro_grupo='" + nro_grupo + "' nro_tipo_cobro='" + nro_tipo_cobro + "' nro_banco='" + nro_banco_cobro + "' cuit='" + cuit + "' /></criterio>",
                    nvLog: "<nvLog><event id_log_evento='nosis_cda_def' params='" + nro_vendedor + ";" + strVendedor + ";" + nro_grupo + ";" + grupo + ";" + nro_tipo_cobro + ";" + tipo_cobro + ";" + cuit + "' moment='end' /></nvLog>"
                })
            

}//displayProductosPrecargaCDA

var idxmsgcupo=0;
 var mensajescupo=Array("Aguarde un instante...","Consultado bases internas...","Obteniendo información de bases internas...","Consultado bases externas...","Obteniendo información de bases internas...","Generando informe comercial...","Calculando Dictamen...","Calculando oferta...")
var msg_waitingcupo=function () {
  console.log(mensajescupo[idxmsgcupo]);
  nvFW.bloqueo_msg('blq_precarga', mensajescupo[idxmsgcupo]) 
  if(mensajescupo.length-1==idxmsgcupo){
    idxmsgcupo=0;
  }else{
    idxmsgcupo++;
  }
}

var evaluar_motor = function (nro_vendedor,nro_grupo,nro_tipo_cobro,nro_banco_cobro,cuit,trabajo){
  ofertas=new Array()

        var oXML = new tXML();
        oXML.async = true
        oXML.method = 'POST'
        oXML.intervalID=null;        
        oXML.onUploadProgress=function () {
          msg_waitingcupo()
          oXML.intervalID = setInterval(msg_waitingcupo,5000);
        }
        oXML.onComplete = function ()
                           {
                            
                         clearInterval(oXML.intervalID);                            
                         strXML = XMLtoString(oXML.xml)
                          //  debugger
                          //Scu_Id:=2, Sce_Id:=7, Scm_Id:=2, Clave_Sueldo:="27272675142"
                         // strXML='<?xml version="1.0" encoding="ISO-8859-1"?><error_mensajes><error_mensaje numError="0"><titulo/><mensaje/><debug_src/><debug_desc/><params><dictamen>Aprobado</dictamen><mensaje_usuario>asdasdsad</mensaje_usuario><bcra_sit_financiera>1</bcra_sit_financiera><bcra_calificacion_cendeu>OK</bcra_calificacion_cendeu><cant_sit_juridica>0</cant_sit_juridica><ch_rechazados>0</ch_rechazados><control_edad>1</control_edad><nro_grupo>1</nro_grupo><grupo>Santa Fe - Activos centralizados</grupo><nro_tipo_cobro>1</nro_tipo_cobro><tipo_cobro>Descuento de haberes</tipo_cobro><ent_excluidas>0</ent_excluidas><nosis_cda>2086068</nosis_cda><nosis_cda_desc>VOII - Orig cuenta y orden version 3</nosis_cda_desc><motivo/><nro_entidad_cda>800</nro_entidad_cda><clave_sueldo>27272675142</clave_sueldo><sueldo_bruto>104505.84</sueldo_bruto><desc_ley>0</desc_ley><sueldo_neto>62546.65</sueldo_neto><cupo_disponible>16334.99</cupo_disponible><id_transf_log>2035131</id_transf_log><nro_motor_decision>1538</nro_motor_decision><rechaza_motor>0</rechaza_motor><evalua_motor>1</evalua_motor><socio_nuevo>1</socio_nuevo><Scu_Id>2</Scu_Id><Sce_Id>7</Sce_Id><Scm_Id>2</Scm_Id><strXML>&lt;xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema"&gt;&lt;s:Schema id="RowsetSchema"&gt;&lt;s:ElementType name="row" content="eltOnly"&gt;&lt;s:AttributeType name="nro_banco" rs:number="1" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_mutual" rs:number="2" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="estado" rs:number="3" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="string" rs:dbtype="str" dt:maxLength="4294967295" rs:long="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="cuota_maxima" rs:number="4" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="neto_maximo" rs:number="5" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="max_cuotas" rs:number="6" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="id_origen" rs:number="7" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_analisis" rs:number="8" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:extends type="rs:rowbase" /&gt;&lt;/s:ElementType&gt;&lt;/s:Schema&gt;&lt;rs:data&gt;&lt;z:row nro_banco="800" nro_mutual="55" estado="A" cuota_maxima="16334.99" neto_maximo="600000" max_cuotas="36" id_origen="10601" nro_analisis="585" /&gt;&lt;z:row nro_banco="170" nro_mutual="55" estado="A" cuota_maxima="16334.99" neto_maximo="800000" max_cuotas="36" id_origen="10601" nro_analisis="584" /&gt;&lt;/rs:data&gt;&lt;params vista="#tmp_respuesta" timeout="0" PageSize="0" AbsolutePage="0" recordcount="2" PageCount="1" cacheControl="none" cache="False" /&gt;&lt;/xml&gt;</strXML></params></error_mensaje></error_mensajes>'
                          //strXML='<?xml version="1.0" encoding="ISO-8859-1"?><error_mensajes><error_mensaje numError="0"><titulo /><mensaje /><debug_src /><debug_desc /><params><dictamen>Aprobado</dictamen><mensaje_usuario></mensaje_usuario><bcra_sit_financiera>1</bcra_sit_financiera><cant_sit_juridica>0</cant_sit_juridica><ch_rechazados>0</ch_rechazados><control_edad>1</control_edad><nro_grupo>1</nro_grupo><grupo>Santa Fe - Activos centralizados</grupo><nro_tipo_cobro>1</nro_tipo_cobro><tipo_cobro>Descuento de haberes</tipo_cobro><ent_excluidas>0</ent_excluidas><nosis_cda>2086068</nosis_cda><nosis_cda_desc>VOII - Orig cuenta y orden version 3</nosis_cda_desc><motivo /><nro_entidad_cda>800</nro_entidad_cda><clave_sueldo>27272675142</clave_sueldo><sueldo_bruto>110051.12</sueldo_bruto><desc_ley>0</desc_ley><sueldo_neto>67988.29</sueldo_neto><cupo_disponible>25042.82</cupo_disponible><id_transf_log>2070599</id_transf_log><nro_motor_decision>1538</nro_motor_decision><bcra_calificacion_cendeu>califica VOII</bcra_calificacion_cendeu><Scu_Id>2</Scu_Id><Sce_Id>7</Sce_Id><Scm_Id>3</Scm_Id><socio_nuevo>true</socio_nuevo><rechaza_motor>0</rechaza_motor><evalua_motor>1</evalua_motor><strXML>&lt;xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema"&gt;&lt;s:Schema id="RowsetSchema"&gt;&lt;s:ElementType name="row" content="eltOnly"&gt;&lt;s:AttributeType name="nro_banco" rs:number="1" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_mutual" rs:number="2" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="estado" rs:number="3" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="string" rs:dbtype="str" dt:maxLength="4294967295" rs:long="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="cuota_maxima" rs:number="4" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="neto_maximo" rs:number="5" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="number" rs:dbtype="currency" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="max_cuotas" rs:number="6" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="id_origen" rs:number="7" rs:nullable="true" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="i8" dt:maxLength="8" rs:precision="19" rs:fixedlength="true" /&gt;&lt;/s:AttributeType&gt;&lt;s:AttributeType name="nro_analisis" rs:number="8" rs:writeunknown="true"&gt;&lt;s:datatype dt:type="int" dt:maxLength="4" rs:precision="10" rs:fixedlength="true" rs:maybenull="false" /&gt;&lt;/s:AttributeType&gt;&lt;s:extends type="rs:rowbase" /&gt;&lt;/s:ElementType&gt;&lt;/s:Schema&gt;&lt;rs:data&gt;&lt;z:row nro_banco="800" nro_mutual="55" estado="A" cuota_maxima="25042.82" neto_maximo="600000" max_cuotas="36" id_origen="10601" nro_analisis="585" /&gt;&lt;z:row nro_banco="170" nro_mutual="55" estado="A" cuota_maxima="25042.82" neto_maximo="800000" max_cuotas="36" id_origen="10601" nro_analisis="584" /&gt;&lt;/rs:data&gt;&lt;params vista="#tmp_respuesta" timeout="0" PageSize="0" AbsolutePage="0" recordcount="2" PageCount="1" cacheControl="none" cache="False" /&gt;&lt;/xml&gt;</strXML></params></error_mensaje></error_mensajes>'
                          /*NosisXML = strXML*/
                           objXML = new tXML();
                           objXML.async = false
                           $("divHaberes").show();
                           if (objXML.loadXML(strXML)){                               
                              var error_mensaje=objXML.selectSingleNode("error_mensajes/error_mensaje")
                              var numError=error_mensaje.getAttribute("numError")
                              if(numError==0){  
                                var datos={}
                               datos['trabajo']=trabajo
                               datos['nro_vendedor']=nro_vendedor                               
                               datos['nro_banco_cobro']=nro_banco_cobro
                               datos['nro_grupo']=nro_grupo                               
                               var params=objXML.selectSingleNode("error_mensajes/error_mensaje/params")
                               for(n=0;n<params.childNodes.length;n++){                                
                                 datos[params.childNodes[n].nodeName]=(params.childNodes[n].innerHTML).replace(/&lt;/g, "<").replace(/&gt;/g, ">")
                                 //console.log("parametro "+params.childNodes[n].nodeName+" valor "+params.childNodes[n].innerHTML)
                               }
                               if(datos['bcra_sit']){
                                sit_bcra=datos["bcra_sit"]
                               }

                               motor['datos']=datos;

                               if(datos['evalua_motor']==1){                                                                
                                if((permisos_precarga & 16384 ||  motor.datos.es_poder_judicial=='1')>0){
                                  $("divHaberes").show();
                                }else{
                                  $("divHaberes").hide();
                                }
                                $("btn1").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].hide() //oculto el boton pendiente
                                $("btn2").ancestors()[0].ancestors()[0].ancestors()[0].ancestors()[0].setStyle({width:"50%"}) //oculto el boton pendiente
                                
                                $("span_criterio").update("Ver informes")
                                var xmlText=objXML.selectSingleNode("error_mensajes/error_mensaje/params/strXML").innerHTML
                                 ofertas=rsdataToArray(xmlText) //obtengo las filas del xml data en forma de array
                                 //ofertas=ofertas.filter(that=>that.estado!=null && that=>that.estado!="") //saco los elementos que no tienen estado
                                 ofertas=ofertas.filter(that=>(that.estado!= undefined) && (that.estado!=""));
                                 motor['ofertas']=ofertas;                                 
                                 displayProductosMotor()
                               }else{
                                $("span_criterio").update("CDA")
                                displayProductosPrecargaCDA(trabajo)
                               }                               
                               
                              }else{
                              var mensaje=objXML.selectSingleNode("error_mensajes/error_mensaje/mensaje").innerHTML  
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
                                               evaluar_motor(nro_vendedor,nro_grupo,nro_tipo_cobro,nro_banco_cobro,cuit,trabajo)
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
        oXML.onFailure = function () {nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
        clearInterval(oXML.intervalID);
        rserror_handler("Error al consultar los datos. Intente nuevamente.")
        }                
        /*luego poner en accion=precarga_motor*/
        var clave_sueldo=trabajo['clave_sueldo']
        oXML.load('/FW/servicios/ROBOTS/getXML.aspx',"accion=precarga_motor&criterio=<criterio><nro_vendedor>" + nro_vendedor + "</nro_vendedor><nro_grupo>" + nro_grupo + "</nro_grupo><nro_tipo_cobro>" + nro_tipo_cobro + "</nro_tipo_cobro><nro_banco>" + nro_banco_cobro + "</nro_banco><cuit>" + cuit + "</cuit><clave_sueldo>" + clave_sueldo + "</clave_sueldo></criterio>")
 
}//handler evaluar_motor


var cbubanking = function (cbu){  
        var oXML = new tXML();
        oXML.async = true
        oXML.method = 'POST'
        oXML.onComplete = function ()
                           {
                            
                              strXML = XMLtoString(oXML.xml)
                              console.log(strXML)
                             objXML = new tXML();
                             objXML.async = false
                             
                             if (objXML.loadXML(strXML)){ 
                                var error_mensaje=objXML.selectSingleNode("error_mensajes/error_mensaje")
                                var numError=error_mensaje.getAttribute("numError")
                                if(numError==0){   
                                console.log("ok")                             
                                }    
                             }
                       }//oncomplete
        oXML.onFailure = function () {
        rserror_handler("Error al consultar los datos. Intente nuevamente.")
        }                
        
        oXML.load('/FW/servicios/ROBOTS/GetXML.aspx',"accion=consultar_cbu&criterio=<criterio><cuenta>" + cbu + "</cuenta></criterio>")
 
}//handler cbubanking