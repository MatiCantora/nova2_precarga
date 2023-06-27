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
 
  criterio += "<permiso_analisis type='sql'>dbo.rm_tiene_permiso('permisos_analisis',permiso_analisis) = 1</permiso_analisis><aplica_precarga type='igual'>1</aplica_precarga>"

  var rs = new tRS();
    rs.onComplete = function (rs) {      
        campos_defs.items['cbAnalisis'].rs = rs
        campos_defs.items['cbAnalisis']['onchange'] = cbAnalisis_onchange
        campos_defs.set_first('cbAnalisis')

        if (rs.recordcount == 1) campos_defs.habilitar("cbAnalisis", false)
        else campos_defs.habilitar("cbAnalisis", true)
      } 

  rs.open({ filtroXML: nvFW.pageContents["analisis_cargar"], filtroWhere: criterio }) 
    
  //while (!rs.eof()) {          
  //    $('cbAnalisis').insert(new Element('option', { value: rs.getdata('nro_analisis') }).update(rs.getdata('nro_analisis') + ' - ' + rs.getdata('analisis')))
  //    if (rs.getdata('nro_analisis') == nro_analisis)
  //        $('cbAnalisis').selectedIndex = $('cbAnalisis').options.length - 1
  //    i++    
  //    rs.movenext()  
  //    } 
 //if($('cbAnalisis').selectedIndex >=0)
    //consultardisponibleeducacion=1;  
    //debugger
    //analisis_mostrar()
 //$('cbAnalisis').setStyle({ width: '100%' })     
      
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
  var str_cuota_maxima = (parseFloat(cuota_maxima) > 0) ? "<font color='green'><b>$ " + cuota_maxima + "</b></font>" : "<font color='red'><b>$ " + cuota_maxima + "</b></font>"
  $('importe_max_cuota').insert({bottom: str_cuota_maxima })
  importe_max_cuota = cuota_maxima
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
    if(Etiquetas[i]['calculado'] && parseInt(Etiquetas[i]['nro_etiqueta']) != 17 && parseInt(Etiquetas[i]['nro_etiqueta']) != 93 && parseInt(Etiquetas[i]['nro_etiqueta']) != 1024)
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

//var rsTrabajo_info = new tRS();

//function recuperar_info_recibo(campo)
//    {
//    var valor
//    //if (info_recibo_nro_lote != nro_lote || info_recibo_nro_sistema != nro_sistema || nro_sistema == '' || analisis_clave_sueldo != clave_sueldo)
//    //  {
//    //  info_recibo_nro_lote = nro_lote
//    //  info_recibo_nro_sistema = nro_sistema
//    //  analisis_clave_sueldo = clave_sueldo
//    //<nro_lote type="igual">' + nro_lote + '</nro_lote>  
//    rsTrabajo_info.open('<criterio><select vista="WRP_trabajo_info"><campos>top 1 *</campos><filtro><nro_docu type="igual">' + nro_docu + '</nro_docu><tipo_docu type="igual">' + tipo_docu + '</tipo_docu><sexo type="igual">\'' + sexo + '\'</sexo><clave_sueldo type="igual">\'' + clave_sueldo + '\'</clave_sueldo><nro_sistema type="igual">' + nro_sistema + '</nro_sistema><nro_lote type="igual">' + nro_lote + '</nro_lote></filtro></select></criterio>')
//    //}
//    valor = rsTrabajo_info.getdata(campo)
//    if (valor == null)
//      valor = 0 

//    return valor
//    }

//function onblur_BCRA_situacion() {debugger
//    if ($('sit_bcra').value > 0)
//        BCRA_situacion_calcular($('sit_bcra').value)
//}

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
      
      if ((Etiqueta["nro_etiqueta"] == 446) && (origen == 'precarga') && campos_defs.get_value("grupos")==10 && $F("consultarRobot")=="1")
      { 
        valor = DISPONIBLE_ba_educacion($("nro_docu").value,campos_defs.get_value("mutual"))   
      }

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




 function DISPONIBLE_ba_educacion(nro_docu, nro_mutual) {
            var monto_disponible=0
            var strXML = ""
            var strHTML = ""
            var oXML = new tXML();
            oXML.async = false
            oXML.load('/FW/servicios/ROBOTS/GetXML.aspx', 'accion=disponible_ba_educacion&criterio=<criterio><nro_docu>' + nro_docu + '</nro_docu><nro_mutual>' + nro_mutual + '</nro_mutual><nro_vendedor>' + $("nro_vendedor").value + '</nro_vendedor></criterio>',
                            function () {
                                var NODs = oXML.selectNodes('error_mensajes/error_mensaje')
                                if (NODs.length != 0) {
                                    numerror = selectSingleNode('@numError', NODs[0]).nodeValue 
                                    mensaje = XMLText(selectSingleNode('mensaje', NODs[0]))
                                    if(numerror==0){
                                    disponible = XMLText(selectSingleNode('params/disponible', NODs[0]))  
                                    }
                                }
                                
                                
                            });
return disponible
}




