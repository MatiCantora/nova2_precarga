function tnvBrowserLog()
 {
  this.agente_intervalo = 10000
  this._agente = null
  this.logs = new Array()
  this.logWindow = null
  this.clear = function ()
                 {
                 this.logs.clear()
                 }
  this.add = function (id_log_evento, campos)
                {
                var fe = new Date()
                var el = {}
                el.id_log_evento = id_log_evento
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
                                strXML += '<brLog fe_evento="' + el.fe_evento.toString() + '" id_log_evento="' + el.id_log_evento + '" ' + strCampos + ' />'
                                el.enviado = true
                                }
                            }
                          strXML += "</brLogs>" 
                          if (c > 0)
                            nvFW.getXML('brLog', strXML)
                          }

  this.showWindow = function() 
                              {
                                 if (this.logWindow == null) 
                                   {
                                      var permiso_grupo = 'permisos_log'
                                      var nro_permiso = 1
                                      
                                      if ((eval(permiso_grupo) & nro_permiso) > 0)
                                          tnvBrowserLogWindow(this)
                                      else 
                                       {
                                          window.top.win = window.top.nvFW.createWindow({ className: 'alphacube',
                                              title: '<b>Verificar Permisos</b>',
                                              url: '/fw/VerificarPermisos.asp',
                                              minimizable: false,
                                              maximizable: false,
                                              draggable: true,
                                              width: 250,
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
          url: '/fw/BrLog_window.asp',
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

      obj.logWindow.showCenter()
}
