     
       function tUpload(target, max_size, filter, allow_image_preview)
        {         
        target = target == undefined ? 'document.write' : target
        if (target == '')
          target = 'document.write'
        if (!max_size)
          max_size = 0
        if (!filter)  
          filter = ""
          
        this.allow_image_preview = allow_image_preview == true  
        
        this.max_size = max_size
        this.filter = filter
        this.filters = filter.split("|")
        this.file_id = 0
        if (target == undefined)
          target = ''
        this.id = parseInt(Math.random() * 10000)
        this.name = 'upload_' + this.id
        this.target = target
        this.upload_ok = false
        this.file = null
        this.form = null
        this.iframe = null
        
        //Metodos
        this.get_html = tUpload_get_html
        this.validateFilename = tUpload_validateFilename
        this.getValue = tUload_getValue
        
        this.cambiar = tUpload_cambiar
        
        //Eventos
        this.onchange = null
        this.onbeforesend = null
        this.onaftersend = null
        this.onfailure = null
        
        this.image_preview = tUpload_image_preview;
        
        var objUp = this
        this.handler = function(e, a)
                        {
                        //Ajustar tamaño del boton en función del input file
                        //Mover el input a la posicion del td
                        //Mover la tapa a la posicion
                        
                        var td = $("td_button_" + objUp.name)
                        var input = objUp.file
                        var tapa = $("div_tp_" + objUp.name)
                        //td.setStyle({width: (input.getWidth() - tapa.getWidth()) + 'px'}) 
                        //input.clonePosition(td, {setTop: true, setWidth: false, setHeight: false, offsetLeft: -1 * tapa.getWidth()})
                        var cum = td.cumulativeOffset()
                        input.setStyle({top: cum.top + 'px', left: (cum.left - tapa.getWidth()) + 'px'})
                        tapa.clonePosition(input, {setTop: true, setWidth: false})
                        input.setOpacity(0)
                        tapa.setOpacity(0)
                        //window.status = td.cumulativeOffset().left + ',' + td.cumulativeOffset().top 
                        }
        
        this.get_html()
        
        }
        
      function tUpload_image_preview(ancho, alto, strech, calidad)
         {
         
         var file_id = this.getValue()
         if (!ancho)
           ancho = 300
         if (!alto)
           alto = 300
         strech = strech == true ? 1 : 0
         if (!calidad)
           calidad = 75
         var params = "file_id=" + file_id + '&thumb_width=' + ancho + "&thumb_height=" + alto + "&thumb_strech=" + strech + '&thumb_quality=' + calidad
         var win = window.top.nvFW.createWindow({className: "alphacube", 
                               title: "Thumbail", 
                               width:ancho+30, height:alto+40, 
                               url: "/fw/files/file_thumb.aspx?" + params })
         win.showCenter();
         }  
      
      function tUload_getValue()
        {
        if (this.upload_ok)
          return this.file_id
        return null  
        }
      
      function tUpload_get_html()
        { 
        
        var strHTML = ''
        strHTML += "<form style='border: 0px; padding: 0px; margin: 0px; width: 100%' name='frm_" + this.name + "' id='frm_" + this.name + "' action='/fw/files/file_upload.aspx' "
        strHTML += "method='post' enctype='multipart/form-data' onsubmit='return validateForm()' target='ifrm_upload_" + this.id + "'>"
        strHTML += "<table class='tb1' border='0' cellpadding='0' cellspacing='0' style='width: 100%'><tr><td style='white-space:nowrap; padding-left:5px; padding-right:5px' >"
        //Input disabled visible
        strHTML +=  this.filter 
        if (this.max_size > 0)
           strHTML += " - Max.: " + (this.max_size/(1024*1024)).toFixed(2) + " mb"
        strHTML += "</td><td id='td_button_" + this.name + "' style='width:100%; text-align: center; background-color: silver; border:solid 2px silver;'>Examinar...</td></tr></table>"
        //Input de tipo file
        strHTML += "<input style='border: 0px; position:absolute; float: left; z-index:2' type='file' size='1' name='" + this.name + "' id='" + this.name + "' onchange='return tUpload_file_onchange(event)'/>"
        //Tapa izquierda para el input
        strHTML += "<div style='border: 0px; position:absolute; float: left; z-index:3; width: 24px; height: 20px; background-color: red' name='div_tp_" + this.name + "' id='div_tp_" + this.name + "' ></div>"
        
        strHTML += "<input type='hidden' name='file_id' value=''/>"
        strHTML += "<input type='hidden' name='max_size' value=''/>"
        strHTML += "<input type='hidden' name='filter' value=''/>"
        strHTML += "<input type='hidden' name='path' value=''/>"
        strHTML += "<input type='hidden' name='accion' value='upload'/>"
        strHTML += "<iframe style='display: none; width: 400px; heigth: 300px' name='ifrm_upload_" + this.id + "' id='ifrm_upload_" + this.id + "' style='width: 100%' src='about:blank' onload='tUpload_iframe_load(event, \"" + this.name + "\")'></iframe>"
        strHTML += "</form>"
        
        //Escribir el HTML
        if (this.target == 'document.write')
          {
          document.write(strHTML)
          }
        else
          {
          var target = $(this.target)
          target.insert({top: strHTML})
          }  
          
        //Ajustar el  handler al load y al resize
        Event.observe(window, 'load', this.handler)
        Event.observe(window, 'resize', this.handler)  
          
        //Recuperar objetos insertados
        this.file = $(this.name)
        this.form = $('frm_upload_' + this.id)
        this.iframe = $('ifrm_upload_' + this.id)
        
        //Asignar a los objetos el tUpload
        this.file.tUpload = this
        this.form.tUpload = this
        this.iframe.tUpload = this
        
        //Si fue a un target ajustar el tamaño y posocion
        if (this.target != 'document.write')
          this.handler()
        
        }
         
      function tUpload_validateFilename(filename) {
          
        var bandera = false
        var streg
        var reg
        for (var i=0; i<this.filters.length;i++)
          if (this.filters[i] != "")
            {
            // Reemplazar "*" por ".*" , luego "?" por ".?" y el "." por "\."     
            streg = this.filters[i]
            reg = new RegExp("\\.", 'ig')
            streg = streg.replace(reg, "\\.")
            reg = new RegExp("\\*", 'ig')
            streg = streg.replace(reg, ".*")
            reg = new RegExp("\\?", 'ig')
            streg = streg.replace(reg, ".?")
            
            reg = new RegExp(streg, 'ig')
            var resultado = filename.match(reg)
            if (resultado != null)
              {
              bandera = true
              break
              }
            }
        if (!bandera)
          alert("El nombre del archivo no coincide con el filtro (" + this.filter + ")." )
        return bandera
        }
      
      function tUpload_iframe_load(e, name)
        { 
        var el = Event.element(e)
        if (!el.tUpload) return
        if (el.tUpload.file.value != '')
          {
          if (el.tUpload.onaftersend != null)
            el.tUpload.onaftersend(el.tUpload)
          try
            {
            var strXML = el.contentWindow.error_xml.innerText //el.contentWindow.error_mensajes //el.contentWindow.document.getElementById("error_xml").value
            var oXML = new tXML()
            oXML.loadXML(strXML)
            var err = new tError()
            err.error_from_xml(oXML)
            if (err.numError == 0)
              {
              el.tUpload.upload_ok = true
              var old_width = el.tUpload.div_upload.down().getWidth()
              var td = $('upload_td_desc_' + el.tUpload.name)
              var strHTML = ""
              
              if (el.tUpload.allow_image_preview)
                 strHTML += '&nbsp;<img alt="Previsualizar" onclick="tUpload_preview_onclick(\'' + el.tUpload.name + '\')" src="../../fw/image/campo_def/preview2.png" border=0 align=absmiddle hspace=1 style="cursor: hand; cursor: pointer"/>&nbsp;|'
              
              strHTML += '&nbsp;' + (parseInt(err.params['size']) / 1024).toFixed(0) + ' KBytes&nbsp;|&nbsp;<a href="javascript:tUpload_cambiar(\'' + el.tUpload.name + '\')">Cambiar</a> &nbsp;&nbsp;'
              
              td.innerHTML = strHTML
              var input = $('upload_input_' + el.tUpload.name)
              var new_width = input.getWidth() - (el.tUpload.div_upload.down().getWidth() - old_width)
              input.setStyle({width: new_width + 'px'})

              if (el.tUpload.onchange != null)
                el.tUpload.onchange(el.tUpload)
              }
            else
              {
              if (el.tUpload.onfailure != null)
                el.tUpload.onfailure(el.tUpload, err)
              tUpload_cambiar(el.tUpload.name)
              err.alert()
              }
            }
          catch(e)  
            {
            err = new tError()
            err.numError = 221
            err.titulo = 'Error tUpload'
            err.mensaje = 'No se ha podido subir el archivo.'
            if (el.tUpload.onfailure != null)
              el.tUpload.onfailure(el.tUpload, err)
            tUpload_cambiar(el.tUpload.name)
            err.alert('No se ha podido subir el archivo.')
            }
            el.tUpload.file.value = ""
          }
        }







        function tUpload_file_onchange(e) {
            var el = Event.element(e)
            if (el.value != "") {
                if (nvFW.pageContents.filtroFile) {
                    nvFW.bloqueo_activar($$('BODY')[0], 'vidrio_body')
                    var filepath = el.value//campos_defs.items[campo_def].upload.file.value
                    var fname = filepath.split("\\").pop()
                    var arr = fname.split(".")
                    var ext = arr[arr.length - 1]
                    arr.pop()
                    var filename = arr.join(".")

                    var rs = new tRS()
                    rs.async = true
                    rs.onComplete = function () {
                        nvFW.bloqueo_desactivar($$('BODY')[0], 'vidrio_body')
                        var existeArchivo = !rs.eof()
                        if (existeArchivo) {
                            var msg = "El archivo ya existe, desea sobreescribirlo?";
                            Dialog.confirm('<b>' + msg + '</br>'
                                    , { width: 280, className: "alphacube",
                                        onShow: function () {
                                        },
                                        onOk: function (win) {
                                            file_onchange(el)
                                            win.close();
                                        },
                                        onCancel: function (win) { el.value = "";  win.close() },
                                        okLabel: 'Confirmar',
                                        cancelLabel: 'Cancelar'
                                    });


                        } else {
                            file_onchange(el)
                        }
                    }
                    var parametros = "<criterio><params "
                    parametros += "f_depende_de='" + file.f_id + "' "
                    parametros += "f_nombre='" + filename + "' "
                    parametros += "f_ext='" + ext + "' "
                    parametros += "/>"
                    parametros += "</criterio>"
                    rs.open(nvFW.pageContents.filtroFile, '', '', '', parametros)
                } else {
                    file_onchange(el)
                }
            }
        }


        function file_onchange(el) {

            var upload = el.tUpload
            if (!upload.validateFilename(el.value))
                return
            if (!upload.div_upload) {
                var strHTML = "<div id='div_up_" + upload.name + "' style='display: none; border: 0px; margin: 0px; padding: 0px;' ></div>"
                //var strHTML = "<table id='div_up_" + upload.name + "' border='0' cellpadding='0' cellspacing='0'  style='background-color: Blue; border: 0px; padding: px; margin: 0px; width:100%'><tr><td style='border: 0px; width:100%; margin: 0px; padding: 0px;'><input type='text' readonly='true' style='width:100%; border: 0px; margin: 0px; padding: 0px;' /></td><td nowrap='true'>Cargando(<span id='span_size_" + upload.name + "'></span>)|<a href='javascript:upload_cancelar()'>Cancelar</a></td></tr></table>"
                upload.form.up().insert({ top: strHTML })
            }
            upload.div_upload = $('div_up_' + upload.name)
            upload.div_upload.innerHTML = "<table class='tb1' border='0' cellpadding='0' cellspacing='0' style='border:0px; padding: 0px; margin: 0px; width:100%'><tr><td style='border: 0px; width:100%; margin: 0px; padding: 0px;'><input type='text' id='upload_input_" + upload.name + "' disabled='true' readonly='true' style='width:100%; border: 0px; margin: 0px; padding: 0px;' /></td><td id='upload_td_desc_" + upload.name + "' nowrap='true'>&nbsp;&nbsp;<img src='/FW/image/file_dialog/spinner24x24_azul.gif' />&nbsp;|&nbsp;<a href='javascript:tUpload_cancelar(\"" + upload.name + "\")'>Subiendo</a>&nbsp;&nbsp;</td></tr></table>"

            upload.span_size = $('span_size_' + upload.name)
            upload.div_upload.clonePosition(upload.form)

            upload.form.hide()
            upload.div_upload.show()

            var input = $('upload_input_' + upload.name)
            input.setStyle({ width: input.getWidth() + 'px' })
            input.value = el.value

            nvFW.error_ajax_request('/fw/files/file_upload.aspx',
                                  {
                                      bloq_contenedor_on: false,
                                      asynchronous: false,
                                      method: '',
                                      parameters: { accion: 'getid', filename: el.value },
                                      onSuccess: function (err, transport) {
                                          upload.file_id = err.params['file_id']
                                          upload.form.file_id.value = err.params['file_id']
                                          upload.form.max_size.value = upload.max_size
                                          upload.form.filter.value = upload.filter
                                          if (upload.onbeforesend != null)
                                              upload.onbeforesend(upload)
                                          upload.form.submit()
                                      },
                                      onFailure: function (err, trasport) {
                                          alert('No se pudo recuperar el ID del archivo.')
                                      }
                                  })


        }
        


        
     function tUpload_cambiar(name) {
         
       if (!name)
         name = this.name
       var frm = $("frm_" + name)
       var input = $(name)
       var upload = frm.tUpload
       if (!upload.form.visible())
         {  
         upload.div_upload.hide()
         upload.form.show()
         if (upload.upload_ok)
           {
           upload.upload_ok = false
           var oXML = new tXML()
           oXML.async = true
           oXML.load("/fw/files/file_upload.aspx?accion=delete&file_id=" + upload.file_id)
           upload.file_id = 0
           if (upload.onchange != null)
             upload.onchange(upload)
           }  
         }
       upload.file_id = 0  
       upload.upload_ok = false      
       }
       
     function tUpload_cancelar(name)         
       {
      alert('No se puede cancelar el envio del archivo.\nEspera que termine el envío y luego cambie el archivo')
       }
       
     function tUpload_preview_onclick(name)  
       {
       var frm = $("frm_" + name)
       var upload = frm.tUpload
       upload.image_preview(undefined, undefined, false)
       }