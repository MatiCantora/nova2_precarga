

var info_recibo_nro_lote = 0
var info_recibo_nro_sistema = 0
var analisis_clave_sueldo = 0


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
    var tiene_oferta=this.tiene_ofertas()      
    var importe_disponible=0;
    var nro_banco=$F("banco")
    var nro_mutual=$F("mutual")
    var nro_analisis=$F('cbAnalisis')   
    //importe_disponible=parseFloat((this.datos.trabajo)?this.datos.trabajo.disponible:"0")
    importe_disponible=parseFloat((this.datos.cupo_disponible)?this.datos.cupo_disponible:"0")  
    if(tiene_oferta){
    var aOferta=motor.ofertas.filter(oferta=>oferta.nro_banco==nro_banco && oferta.nro_mutual==nro_mutual && oferta.nro_analisis==nro_analisis)   
      if(aOferta.length>0){
        importe_disponible=aOferta[0].disponible
      } 
    }
    
    /*if(this.tiene_ofertas() && aOferta.length>0){
      importe_disponible=aOferta[0].disponible
    }else{
      importe_disponible=parseFloat((this.datos.cupo_disponible)?this.datos.cupo_disponible:"0")  
    } */ 
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


var displayProductosPrecargaCDA=function(){  
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
                  consulta.resultado_genera_html()
                  nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                  Control_socio()
                }
                rsN.open({
                    filtroXML: nvFW.pageContents["precarga_cda"],
                    params: "<criterio><params nro_vendedor='" + consulta.nro_vendedor + "' nro_grupo='" + consulta.cliente.trabajo.nro_grupo + "' nro_tipo_cobro='" + consulta.nro_tipo_cobro + "' nro_banco='" + consulta.nro_banco_cobro + "' cuit='" + consulta.cliente.cuit + "' /></criterio>",
                    nvLog: "<nvLog><event id_log_evento='nosis_cda_def' params='" + consulta.nro_vendedor + ";" + strVendedor + ";" + consulta.cliente.trabajo.nro_grupo + ";" + consulta.cliente.trabajo.grupo + ";" + consulta.nro_tipo_cobro + ";" + consulta.tipo_cobro + ";" + consulta.cliente.cuit + "' moment='end' /></nvLog>"
                })
            

}//displayProductosPrecargaCDA




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