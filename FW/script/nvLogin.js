 var win  

 function btnAceptar_pwd_onclick() 
     {
     var pwd_new = $('pwd_new').value
     var pwd_new_conf = $('pwd_new_conf').value
     var pwd_old = $('PWD').value
     var UID = $('UID').value
     //var PWD = $('PWD').value
     
     if (pwd_new_conf != pwd_new)
       {
       window.top.nvFW.alert('Las contraseñas no coinciden')
       return
       }
     
     if (pwd_new_conf == "" || pwd_new == "")
       {
       window.top.nvFW.alert('Debe ingresar una contraseña nueva')
       return
       }
     
     //actualizar_start() 
     pwd_cambiar_start()
     nvFW.error_ajax_request('nvLogin.aspx', {method: 'post', 
                                       encoding: 'ISO-8859-1', 
                                       parameters: {accion: 'pwd_cambiar', PWD: encodeURIComponent(pwd_new), PWD_OLD:encodeURIComponent(pwd_old), UID:UID},
                                       height: "200",
                                       //onCreate: login_start,
                                       onSuccess:  function login_pwd_cambiar_return2(er)
                                                              {        
                                                              pwd_cambiar_end()
                                                              Windows.getFocusedWindow().close()
                                                              login_end()
                                                              $('PWD').value = ""
                                                              window.top.nvFW.alert("Su contraseña ha sido cambiada correctamente.<br/>Ingrese con las nuevas credenciales.")
                                                              },
                                       onFailure: function(){pwd_cambiar_end()}
                                      }
                                      )
     //new Ajax.Request('nvLogin.aspx', {method: 'post', 
     //                                  encoding: 'ISO-8859-1', 
     //                                  parameters: {accion: 'pwd_cambiar', PWD: pwd_new, PWD_OLD:pwd_old, UID:UID},
     //                                  onCreate: login_start,
     //                                  onSuccess: login_pwd_cambiar_return
     //                                 })
     }
    
  var winActualizar 
  function actualizar_start()
  {
   winActualizar = window.top.Dialog.info('Actualizando', {className: "alphacube", width: 250, 
                               contentType: "text/plain",
                               height: 50, 
                               showProgress: true});
  }

  
   
   function btnCancelar_pwd_onclick()
    {
    login_end()
    Windows.getFocusedWindow().close()
    }
   
   function btnCancelar_onclick()
     {
      window.top.location.href = 'errores_personalizados/error_401_3.html'
      //window.setTimeout("window.open('','_parent',''); window.close()",1000)
     }
     
   var win_cambio_clave   
   function btnAceptar_onclick()
    {  
     var UID = $('UID').value
     var PWD = $('PWD').value
     
     if (UID == "" || PWD == "")
       {
       window.top.nvFW.alert('Debe ingresar un usuario y contraseña para poder continuar')
       return
       }
     
     intentos++
     
     //var cb = $('cbCod_sistema')
     //if (cb.selectedIndex > 0)
     //    app_cod_sistema =  cb.value 
     var cbCod_sistema = campos_defs.get_value("cbCod_sistema")
     if (cbCod_sistema != "") app_cod_sistema = cbCod_sistema
     //debugger
    login_start()
    
    var oXML = new tXML();
    oXML.method = "POST"
    oXML.async = true
    oXML.onFailure = function()
                        {
                        window.top.nvFW.alert("Error al intentar realizar la operación.<br>" + this.parseError.numError + '-' + this.parseError.description)
                        login_end()
                        }
       oXML.load('/FW/nvLogin.aspx', "UID=" + UID + "&PWD=" + encodeURIComponent(PWD) + "&URL=" + URLParam + "&PwdCC=0&app_cod_sistema=" + app_cod_sistema + "&port_eval=false", login_return)
     
   }    
   
   function login_start()
     {
    // $('divlog').insert({bottom: ' - start'})
     $("spinner").show()
     $('UID').disabled = true
     $('PWD').disabled = true
     $('btnAceptar').disabled = true
/*     $('btnCancelar').disabled = true*/
     $('chkRecUID').disabled = true
     try
       {
       $('cbCod_sistema').disabled = true
       }
     catch(ex){}
     
     }  
     
   function login_end()
     {
     $('UID').disabled = false
     $('PWD').disabled = false
     $('btnAceptar').disabled = false
     /*$('btnCancelar').disabled = false*/
     $('chkRecUID').disabled = false
     $("spinner").hide()
     }
   
   function pwd_cambiar_start()
     {
     $('pwd_new').disabled = true
     $('pwd_new_conf').disabled = true
     $('btnAceptar_pwd').disabled = true
     $('btnCancelar_pwd').disabled = true
     }  
     
   function pwd_cambiar_end()
     {
     $('pwd_new').disabled = false
     $('pwd_new_conf').disabled = false
     $('btnAceptar_pwd').disabled = false
     $('btnCancelar_pwd').disabled = false
     }  
   
   function login_return(transport) 
     {
     objXML = this //transport.responseXML
     var error = new tError();
     
     error.error_from_xml(objXML)
     //var numError = parseInt(objXML.selectSingleNode('error_mensajes/error_mensaje/@numError').value) //parseInt(selectSingleNode('error_mensajes/error_mensaje/@numError', objXML).value)
     //var descripcion = XMLText(objXML.selectSingleNode('error_mensajes/error_mensaje/mensaje'))
     switch (error.numError)
       {
       case 0: //OK
         //Recordar usuario
         SetCookie('recordar_usuario', $('chkRecUID').checked.toString(), 30)
         //SetCookie('cambiar_clave', $('chkCC').checked.toString(), 30)
         if ($('chkRecUID').checked)
            SetCookie('cookUID', $('UID').value, 30)

         //Analizar el entorno de sesion
         if (SessionType == "nvInterOP_session")
           {
           var IDS = error.params["nvSessionNET"] // XMLText(objXML.selectSingleNode('error_mensajes/error_mensaje/params/nvSessionNET'))
           var idXML = new tXML()
           idXML.async = false
           idXML.method = "POST"
           var retError = -1
           idXML.load('/FW/scripts/InterOP.asp', 'IDSessionNet=' + IDS)
           try
              {
              retError = parseInt(selectSingleNode('error_mensajes/error_mensaje/@numError', idXML.xml).value)
              }
           catch(ex3)
              {}
           if (retError != 0)
             {
             window.top.nvFW.alert("No se pudo conectar a la otra session. Cerrar el sistema")
             return
             }
           } 

           if (window.top.nvSesion != undefined && window.top.nvSesion.app_path_rel != "")
               URLParam = "/" + window.top.nvSesion.app_path_rel

//           if (URL == "" && $("path_rel").value != "") 
//             URL = $("path_rel").value

           
       /*   if (URL == "")
             URL = error.params["app_default"] // XMLText(objXML.selectSingleNode('error_mensajes/error_mensaje/params/app_default'))
              
           //cargar la aplicacion
           var oXML = new tXML();
           var retApp = -1
           var appURL = URL.indexOf("?") == -1 ? URL + "?app_config_return_error=true" : URL + "&app_config_return_error=true"
           oXML.async = true*/

		   var app_default = error.params["app_default"] // XMLText(objXML.selectSingleNode('error_mensajes/error_mensaje/params/app_default'))

           //cargar la aplicacion
           var oXML = new tXML();
           var retApp = -1
           var appURL = app_default + "?app_config_return_error=true"
           oXML.async = true
           
           oXML.onComplete = function()
                               {
                               
                               var errDesc = ''
                               try
                                 {
                                 retApp = parseInt(this.selectSingleNode('error_mensajes/error_mensaje/@numError').value)
                                 errDesc = XMLText(this.selectSingleNode('error_mensajes/error_mensaje/mensaje'))
                                 }
                               catch(es){}
                               if (retApp != 0)
                                 {
                                 window.top.nvFW.alert("No se pudo cargar la aplicación. " + errDesc)
                                 login_end()
                                 return
                                 }
                               if ($('bloquear').value == 'true')
                                 {
                                 window.top.nvSesion.desbloquear()
                                 }
                               else    
                                   window.location.href = URLParam == "" ? ("../.." + app_default) : URLParam 
                               }

           oXML.onError = function()
                             {
                             window.top.nvFW.alert("Error al intentar realizar la operación. " + this.parseError.numError + '-' + this.parseError.description)
                             login_end()
                             }

           oXML.load(appURL)
           
          
         break
       case 11://Cambiar contraseña
         //Recordar usuario
         SetCookie('recordar_usuario', $('chkRecUID').checked.toString(), 30)
         if ($('chkRecUID').checked)
            SetCookie('cookUID', $('UID').value, 30)
         login_cambiar_pwd()  
         break
       default:
         window.top.nvFW.alert(error.mensaje)
         login_end()
       }
     
     }
    
    function login_onkeypress(e)
      {
      key = Prototype.Browser.IE ? event.keyCode : e.which 
      if (key == 13)
        switch (Event.element(e).id)
          {
          case "UID":
             $("PWD").focus()
             break
          default:
            btnAceptar_onclick()    
          }
      }
    
    function pwd_new_onkeypress(e)
      {
      key = Prototype.Browser.IE ? event.keyCode : e.which 
      if (key == 13)
        if($('pwd_new').value == '')
           $('pwd_new').focus()
        else
          if($('pwd_new_conf').value == '')
             $('pwd_new_conf').focus()
          else
             btnAceptar_pwd_onclick()
      }
      
    function login_cambiar_pwd()
      { 
        var strHTML = ""
        var win = nvFW.createWindow({name:"sasara", width: 400, height: 150, zIndex: 100,
                              draggable: false,
                              resizable: false, 
                              closable: false, 
                              minimizable: false, 
                              maximizable:false, 
                              title: "<b>Cambiar Contraseña</b>",
                              onShow: function (win){$('pwd_new').focus()}
                            })
        win.getContent().innerHTML = $('divLogin_cambiar_pwd').innerHTML
        win.showCenter(true); 
      }
      
