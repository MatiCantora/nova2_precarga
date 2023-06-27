function tnvBrowserLog()
 {
  this.agente_intervalo = 10000
  this._agente = null
  this.logs = new Array()
  this.logWindow = null
  this.eventos = {}
  this.cfg_actualizar = function ()
  {
      try
      {
          
          // parche: cuando se inicia nvfw intenta cargar los eventos de log pero txml aun no esta declarado
          nvFW_chargeJSifNotExist("", '/FW/script/tXML.js')
          var oXML = new tXML()

          oXML.async = true
          var parametros = "accion=brlogcfg&criterio="
          oXML.load('/fw/brLog/getLogXML.aspx', parametros, function () {
              try {
                  nvFW.brLog.eventos = {}
                  
                  var eventos = nvFW.brLog.eventos
                  var id_nv_log_evento
                  var NODs = this.selectNodes("brlogcfg/eventos/evento")
                  for (var i = 0; i < NODs.length; i++) {
                      id_nv_log_evento = NODs[i].getAttribute("id_nv_log_evento")
                      eventos[id_nv_log_evento] = {}
                      eventos[id_nv_log_evento].id_nv_log_evento = id_nv_log_evento
                      eventos[id_nv_log_evento].brEnviar = NODs[i].getAttribute("brEnviar") == 1
                      eventos[id_nv_log_evento].brMostrar = true
                      eventos[id_nv_log_evento].cuenta = 0
                  }
              }
              catch (e) { }
          })
      }
      catch (e) { }

  }

  this.cfg_actualizar()

  this.clear = function ()
                 {
                 this.logs.clear()
                 }
  this.add = function (id_nv_log_evento, campos)
                {
                var fe = new Date()
                var el = {}
                el.id_nv_log_evento = id_nv_log_evento
                el.fe_evento = fe
                if (typeof(campos) == 'object')
                  for (var i in campos)
                    el[i] = campos[i]
                else
                  el["campo01"] = campos

                this.logs.push(el)
                if (this.logWindow != null)
                  this.logWindow.content.contentWindow.brLog_show(el)
                
                }
  
  this.agente_iniciar = function (agente_intervalo)
                          {
                          if (agente_intervalo != undefined)
                            this.agente_intervalo = agente_intervalo
                          if (this._agente == null)  
                            this._agente = window.top.setInterval("window.top.nvFW.brLog.agente_ejecutar()",  this.agente_intervalo)
                          }
  
  this.agente_terminar = function ()
                          {
                          if (this._agente != null)
                            {
                            window.clearInterval(this._agente)
                            this._agente = null
                            }
                          }
                          
  this.agente_ejecutar = function ()
                          {
                          var c = 0
                          var strXML = "<brLogs>"
                          for (var i in this.logs)
                            {
                            log = this.logs[i]
                            if (log.enviado != true)
                              if (typeof(this.logs[i]) != "function")
                                {
                                c++
                                el = this.logs[i]
                                strCampos = ''
                                for (var i in el)
                                  if (i != 'fe_evento' && i != 'id_log_evento')
                                    {
                                    strCampos += i + "='" + el[i] + "' "
                                    }
                                strXML += '<brLog fe_evento="' + el.fe_evento.toString() + '" id_nv_log_evento="' + el.id_nv_log_evento + '"><![CDATA[' + strCampos + ']]></brLog>'
                                el.enviado = true
                                }
                            }
                          strXML += "</brLogs>" 
                          if (c > 0)
                           {
                              //nvFW.getXML('brLog', strXML)
                              var parametros = "accion=brLog&criterio=" + strXML
                              var res = oXML.load('/fw/brLog/getLogXML.aspx', parametros, null)
                              if (res)
                                  return oXML
                              else
                                  return null
                           }
                            
                          }

  this.showWindow = function() 
                              {
                                 if (this.logWindow == null) 
                                   {
                                      var permiso_grupo = 'permisos_log'
                                      var nro_permiso = 1
                                      
                                      if ((nvFW.pageContents[permiso_grupo] & nro_permiso) > 0)
                                          tnvBrowserLogWindow(this)
                                      else 
                                       {
                                          window.top.win = window.top.nvFW.createWindow(
                                              { className: 'alphacube',
                                              title: '<b>Verificar Permisos</b>',
                                              url: '/fw/brLog/VerificarPermisos.aspx',
                                              minimizable: false,
                                              maximizable: false,
                                              draggable: true,
                                              width: 350,
                                              height: 120,
                                              resizable: false,
                                              onClose: function(win) 
                                               {
                                                  if (window.top.win.options.userData.tacceso == 1)
                                                      tnvBrowserLogWindow(this)
                                               }
                                          })

                                          window.top.win.options.userData = { permiso_grupo: permiso_grupo, nro_permiso: nro_permiso, tacceso: 0 }
                                          window.top.win.showCenter(true)
                                       }
                                   }
                              }
}

function tnvBrowserLogWindow(obj) 
{
      obj.logWindow = window.top.nvFW.createWindow({ className: 'alphacube',
          title: '<b>Browser Log</b>',
          url: '/fw/brLog/BrLog_window.aspx',
          minimizable: true,
          maximizable: true,
          draggable: true,
          width: 850,
          height: 220,
          resizable: true,
          onClose: function(win) {
              window.top.nvFW.brLog.logWindow = null
          }
      })

      obj.logWindow.showCenter(false)
}
