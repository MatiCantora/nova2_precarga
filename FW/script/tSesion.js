

function logAdd(msg)
{
    //var strAhora = (new Date()).toISOString()
    //window.debug(strAhora + " : " + msg + "</br>")
//$("divDebbug").insertAdjacentHTML("BeforeEnd", strAhora + " : " + msg + "</br>")
}
function tSesion(control_intervalo, winTop, iniciar)
   {
   if (iniciar == undefined)
     iniciar = false

   this.name = 'tSesion'
   this.win = winTop
   this.UID = "" //this.win.UID
   this.app_path_rel = ''
   this.app_sistema = ''
   this.fe_last_action = new Date()
   if (!control_intervalo)
     control_intervalo = 180000 //default
   this.control_intervalo = control_intervalo //Valor de espera en ms antes del bloqueo
   this.control_ventana = null
   this.vidrio_intervalo = 10000
   this.vidrio_div = null
   this.fe_ultimo_check = new Date()
   this.min_interval_check = 30000
   this.interval_vidrio_activar = null
   this.interval_bloquear = null
   this.vidrio_opacity = 0.01

   
   
   //this.interval_id = null
   this.set_control_intervalo= function(valor, tipo_valor)
                                  {                          
                                  //Tipo valor: 'ms', 's', 'm', 'h'
                                  if (!tipo_valor)
                                    tipo_valor = 'ms'
                                  switch(tipo_valor.toLocaleLowerCase())
                                    {
                                    case 's':
                                      valor = valor * 1000
                                      break
                                    case 'm' :
                                      valor = valor * 1000 * 60
                                      break
                                    case 'h' :
                                      valor = valor * 1000 * 60 * 60
                                      break
                                    }
                                  //el intervalo no puede ser menor que 30 segundos  
                                  if (valor < 30000)  
                                    valor = 30000
                                  this.control_intervalo = valor  
                                  }
   this.check = tSesion_check; 

   //this.login_control = tSesion_login_control;
   this.close = tSesion_close;
   this.bloquear = tSesion_bloquear;
   this.desbloquear = tSesion_desbloquear;
   this.cerrar = tSesion_cerrar_sesion;
   this.control_session = tSesion_control_session;
   this.vidrio_activar = tSesion_vidrio_activar
   this.usuario_accion = tSesion_usuario_accion;
   this.iniciar = tSesion_iniciar;
   
   
   
   this.onkeypress = function(e)
                         {
                          // var key = e.wich ? e.wich : e.keyCode
                          // window.status = 'presiono la tecla' + key
                          this.usuario_accion(e)
                         }
   
   
   if (iniciar)
     this.iniciar()
   
   return this
   }

 
 function tSesion_iniciar()
   {
   //Primer chek, carga los valores de la aplicación activa
   this.check()
   //nvFW.brLog.add("tsession", {c1:'vidrio interval', c2:'interval:' + this.vidrio_intervalo + 'ms'})
   var oSesion = this
   this.interval_vidrio_activar = this.win.setTimeout(function()
                                                         {
                                                         oSesion.vidrio_activar()
                                                         }, this.vidrio_intervalo)
   this.interval_bloquear = null
   }
 
 function tSesion_control_session()
   {
   //nvFW.brLog.add("tsession", {c1:'control session'})
   var ahora = new Date()
   if ((ahora - this.fe_ultimo_check) > this.min_interval_check)//PARA QUE NO CHEQUEE TODO EL TIEMPO
     {
     this.fe_ultimo_check = ahora
     
     if (!this.count_control) this.count_control = 0 
       
     //if(this.check_suspend)
     //  return

     if (this.count_control > 2) 
       {
       //nvFW.brLog.add("tsession", {c1:'count_control_exit'})
       return
       }
       
     this.count_control++
         
     objSession = this
     //var check_preg = new Date()
     this.check(function(res)
                            {
                             objSession.count_control--
                             //var check_resp = new Date()
                             //check_dif = check_resp - check_preg
                             //if (!res && check_dif < 2000)
                             if (!res)
                               {
                               //nvFW.brLog.add("tsession", {c1:'bloqueo por check error'})
                               objSession.bloquear(false)
                               }
                            }  
               )
     
     }  
   }
 
 function tSesion_vidrio_activar() 
   {
   logAdd("Vidrio - Activar. Intervalo " +  this.vidrio_intervalo)
   if (this.interval_bloquear == null)
     {
     var oSesion = this
     this.interval_vidrio_activar = null
     var body = this.win.$$("BODY")[0]
     if (this.vidrio_div == null)
       {
       var strHTML = "<div id='divVidrio' style='position: absolute; float:left; z-index: 100000; border: solid red 1px; background-color: blue'></div>"
       body.insert({top: strHTML})
       this.vidrio_div = this.win.$('divVidrio')
       $(this.vidrio_div).setOpacity(this.vidrio_opacity)
       //$(this.vidrio_div).setOpacity(0.2)
       //$(this.vidrio_div).setOpacity(0.03)
       Event.observe($(this.vidrio_div), 'mousemove', function(){oSesion.usuario_accion()})
       Event.observe($(this.vidrio_div), 'touchstart', function(){oSesion.usuario_accion()})
       Event.observe($(this.vidrio_div), 'dragover', function(){oSesion.usuario_accion()})
                                                      
       }
    
     this.interval_check = this.win.setInterval(function() {oSesion.control_session()}, this.min_interval_check)
     logAdd("Iniciar control intervalo " + this.control_intervalo + "ms")
     this.interval_bloquear = this.win.setTimeout(function() {nvFW.brLog.add("tsession", {c1:"bloqueo por intervalo"});oSesion.bloquear()}, this.control_intervalo)
     try
       {
       this.vidrio_div.clonePosition(body)
       }
     catch(ex1)
       {
       debugger
       }
     
     
     
     //this.vidrio_div.style.zIndex = 100000
     
     if(this.control_ventana != null)
     this.vidrio_div.style.zIndex = this.control_ventana.options.zIndex - 1
     //nvFW.brLog.add("tsession", {c1:'vidrio activar', c2:'zIndex:' + this.vidrio_div.style.zIndex})
     this.vidrio_div.show()
     }
//   else
//     {
//     debugger
//      
//     }
       
   }
 function tSesion_usuario_accion(e)
  {
  logAdd("Usuario acción. Evento ")
  //var x = Event.pointerX(e) 
  //var y = Event.pointerY(e)
      //window.status = x + ', ' + y
  //nvFW.brLog.add("tsession", {c1:'usuario accion'})
  this.fe_last_action = new Date()
  var oSesion = this
  if (oSesion.interval_bloquear != null) //&& oSesion.ultimo_x != x && oSesion.ultimo_y != y
    {
    //oSesion.ultimo_x = x 
    //oSesion.ultimo_y = y 
    this.win.clearInterval(oSesion.interval_bloquear)
    oSesion.interval_bloquear = null   
    this.win.clearInterval(oSesion.interval_check)
    oSesion.interval_check = null   
    //nvFW.brLog.add("tsession", {c1:'vidrio desactivar'})
    oSesion.vidrio_div.hide()
    //nvFW.brLog.add("tsession", {c1:'vidrio interval', c2:'interval:' + oSesion.vidrio_intervalo + 'ms'})
    oSesion.interval_vidrio_activar = this.win.setTimeout(function(){oSesion.vidrio_activar()}, oSesion.vidrio_intervalo)
    
    }
//  else 
//    {
//    debugger 
//    }
 
  oSesion.control_session()
  }
  
 function tSesion_check(funComplete)
   {
   //nvFW.brLog.add("tsession", {c1:'check'})
   var res 
   var oXML = new tXML()
   oXML.method = "POST"
   oXML.async = true
  
   var objSession = this
   
   oXML.onComplete = function()
     {
     logAdd("****  Check complete")
     try
       {
       res = eval(this.selectSingleNode('/xml/rs:data/z:row/@sesion_check').nodeValue)
       }
     catch(e)
       {
       if (typeof(funComplete) == 'function') funComplete(false)
       } 
       
     if (res)
       {
       objSession.app_path_rel = this.selectSingleNode('/xml/rs:data/z:row/@app_path_rel').nodeValue
       objSession.app_sistema = this.selectSingleNode('/xml/rs:data/z:row/@app_sistema').nodeValue
       objSession.app_cod_sistema = this.selectSingleNode('/xml/rs:data/z:row/@app_cod_sistema').nodeValue
       //objSession.control_intervalo = this.selectSingleNode('/xml/rs:data/z:row/@BrowserSesionTimeut').nodeValue
       objSession.UID = this.selectSingleNode('/xml/rs:data/z:row/@UID').nodeValue
       var fe_last_action = new Date(Date.parse(this.selectSingleNode('/xml/rs:data/z:row/@fe_last_action').nodeValue))
       logAdd("****  Check complete. Usuario '" + objSession.UID + "' " + FechaToSTR(fe_last_action) + " " + HoraToSTR(fe_last_action))
       //nvFW.brLog.add("tsession", {c1:'check result', c2:'fe_last_action:' + HoraToSTR(fe_last_action) + '.' +  fe_last_action.getMilliseconds()} )
      
       // window.status = oXML.selectSingleNode('/xml/rs:data/z:row/@fe_last_action').nodeValue + ' - Pregunta:' + this.pregunta + ' - Respuesta: ' + this.respuesta + ' DIF:' + dif
      
       if ((fe_last_action - objSession.fe_last_action) > 10000)
         {
         objSession.usuario_accion()
         }
       if (typeof(funComplete) == 'function') funComplete(true)  
       }
     else
        if (typeof(funComplete) == 'function') funComplete(false)   
     }
    //oXML.getXML('sesion', objSession.fe_last_action.toString())
    oXML.load("/fw/getSessionXML.aspx", "accion=sesion&criterio=" + FechaToSTR(objSession.fe_last_action, 2) + " " + HoraToSTR(objSession.fe_last_action))

   }  
 

/* function tSesion_login_control()
   {
   debugger
   if (!this.check())
     this.bloquear()
   }
*/
 
  function tSesion_return_zIndex()
  {
    var _windows = this.win.Windows.windows
    var zIndex = 1
    var returnzIndex = 5000
   
    for (var i=0; i < _windows.length ; i++)
     { 
       if(zIndex < _windows[i]['element'].style.zIndex)
          zIndex = _windows[i]['element'].style.zIndex
     }   
   
    if(zIndex > returnzIndex)  
     returnzIndex = zIndex + 1
     
    return returnzIndex 
  }
  
 function tSesion_bloquear(cerrar_sesion)
   {
   logAdd("Bloquear usuario")
   if (cerrar_sesion == undefined)
     cerrar_sesion = true
   if (this.interval_vidrio_activar != null)
     {
     this.win.clearTimeout(this.interval_vidrio_activar)
     this.interval_vidrio_activar = null
     }
   if (this.interval_check != null)
     {
     this.win.clearTimeout(this.interval_check)
     this.interval_check = null
     }   
   if (this.interval_bloquear != null)
     {
     this.win.clearTimeout(this.interval_bloquear)
     this.interval_bloquear = null
     }   
   
   if (this.control_ventana == null)
     {
     
     if(this.vidrio_div != null)
       this.vidrio_div.hide()
     //var zIndex = tSesion_return_zIndex()
     if (this.UID == "")
         return
     this.control_ventana = nvFW.createWindow({title: "Sesión bloqueada", 
                            width:300, 
                            height:350, 
                            closable: false,
                            minimizable: false,
                            maximizable: false,
                            resizable:false,
                            minWidth:300,
                            minHeight:350,
                           // zIndex: zIndex,
                            url: "/FW/nvLogin.aspx?bloquear=true&UID=" + this.UID + '&app_cod_sistema=' + this.app_cod_sistema
//                            onClose: function() 
//                                       {
//                                       
//                                       objSesion.desbloquear()  
//                                       }
//                          
                          });
     this.control_ventana.showCenter(true);  
     }

    //cerrar sesion
     if (cerrar_sesion)
     this.close(false)
//   else 
//     {
//     debugger 
//     }
   } 
 
 function tSesion_desbloquear()
   { 
   this.control_ventana.close()
   this.control_ventana = null
   var oSesion = this
   this.interval_vidrio_activar = this.win.setTimeout(function() {oSesion.vidrio_activar()}, this.vidrio_intervalo)
   //Activar la aplicacion
   /*
   var oXML = new tXML()
   var res = oXML.load('../../' + this.app_path_rel +  '/scripts/app_config.asp?app_config_return_error=true')
   if (res)
     {
     this.control_ventana.close()
     this.control_ventana = null
     this.interval_vidrio_activar = window.setTimeout('window.top.nvSesion.vidrio_activar()', this.vidrio_intervalo)
     //this.interval_id = window.setInterval('this.login_control()', this.control_intervalo)
     }
   else
     alert('Error al activar la aplicacion')  
   */
   }  
   
 function tSesion_close(redir)
   {
   
   if (redir == undefined)
     redir = true
   var URL = '/FW/nvLogin.aspx'
   var parametros = 'accion=cerrar'
   var oXML = new tXML()
   oXML.method = 'POST'
   oXML.async = true
   //oXML.onComplete = function ()
   //                      {
   //                      var numError = parseInt(this.selectSingleNode('error_mensajes/error_mensaje/@numError').value)
   //                      if (redir)
   //                        {
   //                        if (numError == 0)
   //                          nvSesion.win.location.href = '/' + nvSesion.app_path_rel
   //                        else
   //                          nvSesion.win.alert('Error al cerrar la sesión. Cierre los navegadores que estén abiertos con el sistema.') 
   //                        }
   //                      }
   oXML.load(URL, parametros)
   if (redir)
     {
     nvFW.alertUnload = false
     var url = '/fw/nvLogin.aspx?app_cod_sistema=' + nvSesion.app_cod_sistema
     nvSesion.win.location.href =  url
     }
   return true
   }
   
 function tSesion_cerrar_sesion()
   {
   //debugger
   var objThis = this
   this.win.Dialog.confirm("¿Confirma cerrar sesión?", {width:300, className: "alphacube", 
                                               okLabel: "Aceptar", 
                                               cancelLabel: "Cancelar",
                                               buttonClass: "myButtonClass", 
                                               id: "myDialogId", 
                        ok:function(win) 
                              {
                              objThis.close()
                              /* 
                              var URL = '../../nv_login.asp'
                              var parametros = 'accion=cerrar'
                              oXML = (new tXML).load(URL, parametros)
                              var numError = parseInt(selectSingleNode('error_mensajes/error_mensaje/@numError', oXML).value)
                              if (numError == 0)
                                window.location.href = '../../errores_personalizados/sesion_cerrada.html'
                              else
                                alert('Error al cerrar la sesión. Cierre los exploradores que estén abiertos con el sistema.') 
                              return true
                              */
                              } 
                              });
   
   }   



if (window.top.nvSesion == undefined) {
    //var nvSesion = tSesion()
    window.top.nvSesion = new tSesion(180000, window.top)
    window.top.nvSesion.set_control_intervalo(5, 'm') //Controla el tiempo de sesion. Es decir el tiempo en que el usuario no tiene actividad antes de cerrar la session.
    window.top.nvSesion.vidrio_intervalo = 30000      //Controla el tiempo de apertura de vidrio
    window.top.nvSesion.min_interval_check = 60000    //Contorla el tiempo minimo del estado de session.
    window.top.nvSesion.iniciar()
    window.nvSesion = window.top.nvSesion
    var sesion = window.top.nvSesion
    logAdd("control_intervalo:" + sesion.control_intervalo + ", vidrio_intervalo:" + sesion.vidrio_intervalo + ", min_interval_check:" + sesion.min_interval_check)

}

if (window != window.top)  
  {
  Event.observe(window.document, 'keypress', function(e)
                                               {
                                                window.top.nvSesion.onkeypress(e)
                                               })

  }
else
  {
  
  Event.observe(window.document, 'keypress', function(e)
                                               {
                                                nvSesion.onkeypress(e)
                                               })


  
//  debugger 
//  var strwinSession = GetCookie("winSession", '')   
//  var winSession = strwinSession.split(",")
//  for (var i=0; i < winSession.length; i++)
//    if (winSession[i] == "")
//      winSession.splice(i, 1)
//      
//  if (window.name == '')
//    {
//    window.name = 'winSesion_'
//    for (var i = 0; i < 5; i++)
//      window.name += Math.floor(Math.random()*10) 
//    }
//  
//  existe = false
//  for (var i=0; i < winSession.length; i++)
//    {
//    name = winSession[i]
//    if (window.name == name)
//      {
//      existe = true
//      break
//      }
//    }

//  if (!existe)
//    {
//    strwinSession += strwinSession != '' ? "," : ''
//    strwinSession += name
//    SetCookie("winSession", strwinSession)  
//    }
  
  }