


//function sac_get_cuit_eval(cuit, existe, onComplete, propiedades) {

//  if ((cuit.toString().length > 0) && (existe == 0))
//   {
//     if ((window.top.permisos_web3 & 2097152) > 0)
//        {
//           var nro_banco = !propiedades.nro_banco ? 0 : propiedades.nro_banco
//           var nro_entidad = !propiedades.nro_entidad ? 0 : propiedades.nro_entidad
//           var CDA = !propiedades.CDA ? 0 : propiedades.CDA
//           var url = ""
//           var oXML1 = new tXML();
//           if (oXML1.load('/meridiano/GetXML.asp?accion=sac_get_token&criterio=<criterio><nro_banco>' + nro_banco + '</nro_banco><nro_entidad>' + nro_entidad + '</nro_entidad><CDA>' + CDA + '</CDA></criterio>')) 
//            {
//               var NODs = oXML1.selectNodes('resultado/url')
//               if (NODs.length == 1)
//                   url = XMLText(NODs[0])
//            }

//           window.open(url + "&documento=" + cuit, '', "width=800,height=340,directories=no,status=no,scrollbars=no,resize=no,menubar=no,location=0,toolbar=no,top=280,left=450")

//           window.top.Dialog.confirm('¿Continuar?', {
//               width: 250,
//               height: 100,
//               className: "alphacube",
//               okLabel: "Aceptar",
//               cancelLabel: "Cancelar",
//               cancel: function(win) {
//                                      onComplete('', propiedades)
//                                      win.close();
//                                      return
//                                     }
//                 , ok: function(win) {
//                                      onComplete(cuit, propiedades)
//                                      win.close();
//                                     }
//           });
//      }
//    else
//      {
//       if (!Prototype.Browser.IE) 
//         {
//              pregunta = 'Esta opción solo está disponible en Internet Explorer</br>¿Desea generar el informe sin actualizar la situación del individuo?'
//              window.top.Dialog.confirm(pregunta, {
//                  width: 300,
//                  height: 100,
//                  className: "alphacube",
//                  okLabel: "Aceptar",
//                  cancelLabel: "Cancelar",
//                  cancel: function(win) {
//                                          onComplete('', propiedades)
//                                          win.close();
//                                          return
//                                        },
//                  ok: function(win) {
//                                      onComplete(cuit, propiedades)
//                                      win.close();
//                                   }
//              });
//          }
//        else
//         {  
//            window.open("http://sac.nosis.com.ar/SAC_ServHTA_General/ConsultaExterna.asp?DOC=" + cuit + "&CodCliente=111&Prefijo=BCRA",'',"width=800,height=260,directories=no,status=no,scrollbars=no,resize=no,menubar=no,location=0,toolbar=no,top=280,left=450")
           
//            window.top.Dialog.confirm('¿Continuar?',{
//                                                    width: 250,
//                                                    height: 100,
//                                                    className: "alphacube",
//                                                    okLabel: "Aceptar",
//                                                    cancelLabel: "Cancelar",
//                                                    cancel: function(win)
//                                                                {
//                                                                 onComplete('', propiedades)
//                                                                 win.close();
//                                                                }
//                                                    ,ok: function(win)
//                                                                {
//                                                                 onComplete(cuit, propiedades)
//                                                                 win.close();
//                                                                }
//                                                   });
//        } //!IE 
//     } // CrossBrowser    
//   } //es CUIT      
//  else
//  { onComplete(cuit, propiedades) }
      
//  }


 function sac_get_cuit(nro_docu, onComplete, propiedades) {

  var razon_social = ''
  var sexo = ''
  var fecha_naci = ''
  
  var nro_vendedor = !propiedades.nro_vendedor ? 0 : propiedades.nro_vendedor
  var CDA = !propiedades.CDA ? 0 : propiedades.CDA
  var nro_entidad = !propiedades.nro_entidad ? 0 : propiedades.nro_entidad
  var cuit = !propiedades.cuit ? "" : propiedades.cuit
  var razonsocial = !propiedades.razonsocial ? "" : propiedades.razonsocial
  var sexo = !propiedades.sexo ? "" : propiedades.sexo
  var evaluar = propiedades.evaluar != false 
  
  var oXML = new tXML();
  oXML.async = true

  var existe
     oXML.load('/fw/servicios/nosis/GetXML.aspx', 'accion=SAC_identidad&criterio=<criterio><nro_docu>' + nro_docu + '</nro_docu><razonsocial><![CDATA[' + razonsocial + ']]></razonsocial><sexo>' + sexo + '</sexo><CDA>' + CDA + '</CDA><nro_entidad>' + nro_entidad + '</nro_entidad></criterio>', function () 
    {

    var NODs = oXML.selectNodes('Resultado/Personas/Persona')

    if (NODs.length == 1) {

      cuit = XMLText(selectSingleNode('Doc', NODs[0]))
      existe = selectSingleNode('@existe', NODs[0]).nodeValue

      propiedades.razon_social = XMLText(selectSingleNode('RazonSoc', NODs[0]))
      propiedades.sexo = XMLText(selectSingleNode('Sexo', NODs[0]))
      propiedades.fecha_naci = XMLText(selectSingleNode('FechaNacimiento', NODs[0]))

      //if (evaluar)
      //  sac_get_cuit_eval(cuit, existe, onComplete, propiedades) 
      //else
        onComplete(cuit, propiedades)
      }

    if (NODs.length > 1 && cuit != '')
      {

          var NODs = oXML.selectNodes('Resultado/Personas/Persona')
          for (var i = 0; i < NODs.length; i++)
           {
             Doc = XMLText(selectSingleNode('Doc', NODs[i]))
             if(cuit == Doc)
              {
                cuit = Doc
                existe = selectSingleNode('@existe', NODs[i]).nodeValue

                propiedades.razon_social = XMLText(selectSingleNode('RazonSoc', NODs[i]))
                propiedades.sexo = XMLText(selectSingleNode('Sexo', NODs[i]))
                propiedades.fecha_naci = XMLText(selectSingleNode('FechaNacimiento', NODs[i]))

                //if (evaluar)
                //  sac_get_cuit_eval(cuit, existe, onComplete, propiedades)
                //else
                  onComplete(cuit, propiedades)

                break; 
              }
           }
      }

     if (NODs.length > 1 && cuit == '')
      {
      var win = window.top.nvFW.createWindow({title: '<b>Seleccionar Persona</b>',
                                   minimizable: false,
                                   maximizable: false,
                                   draggable: false,
                                   width: 600,
                                   height: 400,
                                   resizable: false,
                                   onClose: function(win) 
                                              { 
                                              var e
                                              try 
                                               {
                                                cuit = win.options.userData.res['cuit']
                                                propiedades.razon_social = win.options.userData.res['razon_social']
                                                propiedades.sexo = win.options.userData.res['sexo']
                                                propiedades.fecha_naci = win.options.userData.res['fecha_naci'] 
                                                existe = win.options.userData.res['existe']
                                                }
                                              catch(e){}
                                              
                                              //if (evaluar)
                                              //    sac_get_cuit_eval(cuit, existe, onComplete, propiedades)
                                              //else
                                                  onComplete(cuit, propiedades)
                                              }
                                  });
                                  
      win.options.userData = { NODs: oXML }
      win.setURL('/fw/NOSIS_sel_cuit.aspx') 
      win.showCenter(true)
      }
   });
     
  }


function sac_get_html(nro_docu, onComplete, propiedades, onError) {
    
      var nro_vendedor = !propiedades.nro_vendedor ? 0 : propiedades.nro_vendedor
      var nro_banco = !propiedades.nro_banco ? 0 : propiedades.nro_banco
      var CDA = !propiedades.CDA ? 0 : propiedades.CDA
      var nro_entidad = !propiedades.nro_entidad ? 0 : propiedades.nro_entidad
      var cuit = !propiedades.cuit ? "" : propiedades.cuit
      var reintentos = !propiedades.reintentos ? 0 : propiedades.reintentos
      var goToOnError = typeof(onError) != 'function' ? false : true


      sac_get_cuit(nro_docu
                , function (cuit, propiedades) {

                    var nro_vendedor = !propiedades.nro_vendedor ? 0 : propiedades.nro_vendedor
                    var nro_banco = !propiedades.nro_banco ? 0 : propiedades.nro_banco
                    var CDA = !propiedades.CDA ? 0 : propiedades.CDA
                    var nro_entidad = !propiedades.nro_entidad ? 0 : propiedades.nro_entidad
                    var reintentos = !propiedades.reintentos ? 0 : propiedades.reintentos

                    var strHTML = ''
                    if (cuit != '') {
                        var oXML = new tXML();
                        oXML.async = false
                        if (oXML.load('/fw/servicios/nosis/GetXML.aspx?accion=SAC_informe&criterio=<criterio><cuit>' + cuit + '</cuit><razonsocial><![CDATA[' + razonsocial + ']]></razonsocial><sexo>' + sexo + '</sexo><cda>' + propiedades.CDA + '</cda><nro_entidad>' + propiedades.nro_entidad + '</nro_entidad><nro_banco>' + propiedades.nro_banco + '</nro_banco><nro_entidad>' + propiedades.nro_entidad + '</nro_entidad><reintentos>' + propiedades.reintentos + '</reintentos></criterio>')) {

                            try {
                                var NODs = oXML.selectNodes('Respuesta/ParteHTML')
                                
                                var estado_resultado = XMLText(selectSingleNode('Respuesta/Consulta/Resultado/EstadoOk', oXML.xml))
                                var novedad = XMLText(selectSingleNode('Respuesta/Consulta/Resultado/Novedad', oXML.xml))

                                propiedades.estado_resultado = estado_resultado
                                propiedades.novedad = novedad

                                if (estado_resultado.toUpperCase() == 'NO')
                                    if (propiedades.reintentos == 0)
                                    {
                                        if (!goToOnError)
                                            alert(propiedades.novedad)
                                        else
                                            onError({ numError: -99, mensaje: propiedades.novedad })
                                    }
                                    else {
                                        Dialog.confirm(propiedades.novedad, { className: "alphacube",
                                            width: 350,
                                            height: 100,
                                            okLabel: "Generar",
                                            cancelLabel: "Cancelar",
                                            onOk: function (w) {
                                                if (Event.element(event).value.toLowerCase() == "reintentar")
                                                    propiedades.reintentos = propiedades.reintentos + 1
                                                else
                                                    propiedades.reintentos = 0

                                                w.close()
                                                onComplete('', propiedades)
                                            },
                                            onCancel: function (w) { w.close() },
                                            onShow: function (w) { $$('BODY')[0].querySelectorAll(".alphacube_buttons")[0].insert({ top: '<input type="button" class="ok_button" value="Reintentar" onclick="Dialog.okCallback()"/>' }) }
                                        });

                                        onComplete('return', propiedades)
                                        return
                                    }

                                if (NODs.length == 1)
                                    strHTML = XMLText(NODs[0])
                            }
                            catch (e) {

                                var noti = 'No se pudo generar el archivo. Consulte al administrador del sistema.'
                                if (!goToOnError)
                                    alert(noti)
                                else
                                    onError({ numError: -99, mensaje: noti })

                                return
                            }
                        }
                    }


                    if (selectSingleNode('Respuesta/@cdaSinInformeBCRA', oXML.xml))
                        if (selectSingleNode('Respuesta/@cdaSinInformeBCRA', oXML.xml).value.toLowerCase() == 'true') {
                            if (propiedades.novedad != "")
                                propiedades.novedad += "<br>"
                            propiedades.novedad += "Informe Nosis sin último informe BCRA actualizado"
                        }

                    onComplete(strHTML, propiedades)

                }
              , { cuit: cuit, nro_vendedor: nro_vendedor, CDA: CDA, nro_banco: nro_banco, nro_entidad: nro_entidad, reintentos: reintentos })

  }


//function sac_get_xml(nro_docu)
//  {
//  //var cuit = sac_get_cuit(nro_docu)
//  sac_get_cuit(nro_docu,function(cuit){
//                                      var strXML = ''
//                                      if (cuit != '')
//                                        {
//                                            var oXML = new tXML();
//                                        oXML.async = false
//                                        if (oXML.load('../../meridiano/GetXML.asp?accion=SAC_informe&criterio=' + cuit))
//                                          {
//                                          strXML = XMLtoString(oXML.xml)
//                                          }
//                                        }
//                                      //return strHTML
//                                       onComplete(strXML)
//                                      })
  
//  }


  //function SAC_deshabilitar(id_consulta) {
  //    var strXML = ''
  //    if (nro_docu != '') {
  //        var oXML = new tXML();
  //        oXML.async = false
  //        oXML.load('../../meridiano/GetXML.asp?accion=sac_deshabilitar&criterio=' + escape(id_consulta))
  //    }
  //}

function sac_html_guardar(onComplete, propiedades, onError) 
   {
    
      var nro_docu = !propiedades.nro_docu ? 0 : propiedades.nro_docu
      var nro_vendedor = !propiedades.nro_vendedor ? 0 : propiedades.nro_vendedor
      var nro_banco = !propiedades.nro_banco ? 0 : propiedades.nro_banco
      var CDA = !propiedades.CDA ? 0 : propiedades.CDA
      var nro_entidad = !propiedades.nro_entidad ? 0 : propiedades.nro_entidad
      var cuit = !propiedades.cuit ? "" : propiedades.cuit
      var reintentos = !propiedades.reintentos ? 0 : propiedades.reintentos
      var id_tipo = !propiedades.id_tipo ? 0 : propiedades.id_tipo
      var nro_archivo_id_tipo = !propiedades.nro_archivo_id_tipo ? 0 : propiedades.nro_archivo_id_tipo
      var nro_def_archivo = !propiedades.nro_def_archivo ? 0 : propiedades.nro_def_archivo
      var razonsocial = !propiedades.razonsocial ? "" : propiedades.razonsocial
      var sexo = !propiedades.sexo ? "" : propiedades.sexo
      var goToOnError = typeof(onError) != 'function' ? false : true

      sac_get_cuit(nro_docu, function (cuit) {

          var strHTML = ''
          var strXML = "<xml><resultado num_error='2'></resultado></xml>"
          if (cuit != '') {

              var oXML = new tXML();
              oXML.async = true
              var criterio = "<criterio><nro_def_archivo>" + nro_def_archivo + "</nro_def_archivo><razonsocial><![CDATA[" + razonsocial + "]]></razonsocial><sexo>" + sexo + "</sexo><cuit>" + cuit + "</cuit><cda>" + CDA + "</cda><nro_entidad>" + nro_entidad + "</nro_entidad><nro_archivo_id_tipo>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo><id_tipo>" + id_tipo + "</id_tipo><reintentos>" + reintentos + "</reintentos></criterio>"
              oXML.load('/fw/servicios/nosis/GetXML.aspx', 'accion=sac_html_guardar&criterio=' + criterio, function () {
                  try {

                      var estado_resultado = XMLText(selectSingleNode('Respuesta/Consulta/Resultado/EstadoOk', oXML.xml))
                      var novedad = XMLText(selectSingleNode('Respuesta/Consulta/Resultado/Novedad', oXML.xml))

                      propiedades.estado_resultado = estado_resultado
                      propiedades.novedad = novedad

                      if (estado_resultado.toUpperCase() == 'NO')
                          if (propiedades.reintentos == 0) {
                              if (!goToOnError)
                                  window.top.alert(propiedades.novedad )
                              else
                                  onError({ numError: -99, mensaje: propiedades.novedad  })
                          }
                          else {
                              Dialog.confirm(propiedades.novedad, {
                                  className: "alphacube",
                                  width: 350,
                                  height: 100,
                                  okLabel: "Generar",
                                  cancelLabel: "Cancelar",
                                  onOk: function (w) {

                                      if (Event.element(event).value.toLowerCase() == "reintentar")
                                          propiedades.reintentos = propiedades.reintentos + 1
                                      else
                                          propiedades.reintentos = 0

                                      w.close()
                                      onComplete('', propiedades)
                                  },
                                  onCancel: function (w) { w.close() },
                                  onShow: function (w) { $$('BODY')[0].querySelectorAll(".alphacube_buttons")[0].insert({ top: '<input type="button" class="ok_button" value="Reintentar" onclick="Dialog.okCallback()"/>' }) }
                              });

                              onComplete('return', propiedades)
                              return
                          }

                      var NODs = oXML.selectNodes('Respuesta/Consulta/Resultado/URL')
                      if (NODs.length == 1) {

                          if (selectSingleNode('Respuesta/@cdaSinInformeBCRA', oXML.xml))
                              if (selectSingleNode('Respuesta/@cdaSinInformeBCRA', oXML.xml).value.toLowerCase() == 'true') {
                                  if (propiedades.novedad != "")
                                      propiedades.novedad += "<br>"
                                  propiedades.novedad += "Informe Nosis sin último informe BCRA actualizado"
                              }

                          strHTML = XMLText(NODs[0])
                          onComplete(strHTML, propiedades)
                      }
                  }
                  catch (e) {
                      var noti = 'No se pudo generar el archivo. Consulte al administrador del sistema.'      
                      if (!goToOnError)
                          alert(noti)
                      else
                          onError({ numError:-99, mensaje: noti })
                  }
              });
          }
          else {
              var noti = 'No se pudo generar el archivo. Consulte al administrador del sistema.'              
              if (!goToOnError)
                  alert(noti)
              else
                  onError({ numError: -99, mensaje: noti })
          }
          

    }, { cuit: cuit, CDA: CDA, razonsocial: razonsocial, sexo: sexo, nro_entidad: nro_entidad, reintentos: reintentos })

  }


var nvNosis = tNosis()
if (!window.top.nvNosis) 
  window.top.nvNosis = nvNosis
else
  nvNosis = window.top.nvNosis
  

function tNosis(param) {

    if (!param)
        param = {}

    if (!param.CDA) param.CDA = ''
    if (!param.nro_vendedor) param.nro_vendedor = 0
    if (!param.nro_banco) param.nro_banco = 0
    if (!param.id_tipo) param.id_tipo = false
    if (!param.nro_archivo_id_tipo) param.nro_archivo_id_tipo = false
    if (param.cuit == undefined) param.cuit = true
    if (!param.nro_docu) param.nro_docu = 0
    if (!param.razonsocial) param.razonsocial = ''
    if (!param.sexo) param.sexo = ''
    if (!param.nro_def_archivo) param.nro_def_archivo = 0

    this.CDA = param.CDA
    this.nro_vendedor = param.nro_vendedor
    this.nro_banco = param.nro_banco
    this.id_tipo = param.id_tipo
    this.nro_archivo_id_tipo = param.nro_archivo_id_tipo
    this.cuit = param.cuit
    this.nro_docu = param.nro_docu
    this.razonsocial = param.razonsocial
    this.sexo = param.sexo
    this.nro_def_archivo = param.nro_def_archivo
    this.callback = null
 
    return this

}

  //function sac_val_cda(nro_credito,onComplete) {


  //    var oXML = new tXML();
  //    oXML.async = false
  //    var propiedades = {}
  //    propiedades.encontrados = 0
  //    propiedades.xml = ''
  //    propiedades.numError = 0
  //    propiedades.mensaje = ''

  //    if (oXML.load('/meridiano/GetXML.asp?accion=sac_val_cda&criterio=<criterio><nro_credito>' + nro_credito + '</nro_credito></criterio>')) 
  //     {

  //        var NODs = oXML.selectNodes('xml/empresas/empresa')

  //        cuit = selectSingleNode('xml/empresas/@cuit',oXML.xml).value
  //        nro_vendedor = selectSingleNode('xml/empresas/@nro_vendedor',oXML.xml).value
  //        propiedades.numError = selectSingleNode('xml/error/@numError', oXML.xml).value
  //        propiedades.mensaje = XMLText(selectSingleNode('xml/error/mensaje', oXML.xml))
          
  //        if (NODs.length == 1) {

  //            nro_entidad = selectSingleNode('@nro_entidad', NODs[0]).nodeValue
  //            cda = selectSingleNode('@cda', NODs[0]).nodeValue

  //            if (propiedades.numError != 0)  
  //              propiedades.encontrados = 0
  //            else
  //              propiedades.encontrados = 1

  //            onComplete(cuit,nro_entidad,cda,nro_vendedor,propiedades)
  //        }

  //        if (NODs.length > 1) {
              
  //            var strnro_entidad = ''
  //            var strcda = ''
  //            for (var i = 0; i < NODs.length; i++) {
                      
  //                    nro_entidad = selectSingleNode('@nro_entidad', NODs[i]).nodeValue
  //                    if(strnro_entidad == '')
  //                       strnro_entidad = nro_entidad
  //                    else
  //                       if(strnro_entidad.indexOf(nro_entidad) == -1)
  //                          strnro_entidad = strnro_entidad + ',' + nro_entidad

  //                    cda = selectSingleNode('@cda', NODs[i]).nodeValue
  //                    if(strcda == '')
  //                       strcda = cda
  //                    else
  //                       if(strcda.indexOf(cda) == -1)
  //                           strcda = strcda + "','" + cda

  //                    propiedades.encontrados = i + 1
  //               }
                  
  //               strcda = "'"  + strcda + "'"
  //               propiedades.xml = oXML.xml

  //               onComplete(cuit,strnro_entidad,strcda,nro_vendedor,propiedades)
  //            }
  //        }

  //}