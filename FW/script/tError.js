      function tError()
        {
        this.numError = 0
        this.titulo = ''
        this.mensaje = ''
        this.debug_src = ''
        this.debug_desc = ''
        this.error_alert = true
        //this.ok_delay = 500
        this.params = {}
        this.bloq_contenedor_on = true
        this.bloq_contenedor = $$('BODY')[0]
       
        //Info resultado
        //this.salida_tipo = 'HTML'
  
        this.error_xml = tError_error_xml; 
        this.error_script = tError_error_script;
        this.error_from_xml = tError_error_from_xml;
        this.get_error_xml = tError_get_error_xml;
        this.mostrar_error = tError_mostrar_error;
        this.request = tError_Ajax_request;
        this.Ajax_request = tError_Ajax_request;
        this.alert = tError_alert;
        }
        
function tError_Ajax_request(url, options) {
    if (!options)
        options = {}
    var encoding = options.encoding == undefined ? 'ISO-8859-1' : options.encoding
    var method = options.method == undefined ? 'post' : options.method
    var contentType = options.contentType == undefined ? 'application/x-www-form-urlencoded' : options.contentType

    //var asynchronous = options.asynchronous == undefined ? true : asynchronous == true
    var async = options.async == undefined ? true : options.async == true

    if (options.asynchronous != undefined) async = options.asynchronous == true
    var parameters = options.parameters == undefined ? {} : options.parameters
    var postBody = options.postBody == undefined ? null : options.postBody

    this.Ajax_onSuccess = typeof (options.onSuccess) == 'function' ? options.onSuccess : null
    this.Ajax_onFailure = typeof (options.onFailure) == 'function' ? options.onFailure : null
    this.Ajax_onUploadProgress = typeof (options.onUploadProgress) == 'function' ? options.onUploadProgress : null
    this.bloq_contenedor_on = options.bloq_contenedor_on == undefined ? true : options.bloq_contenedor_on == true
    this.bloq_contenedor = !options.bloq_contenedor ? $$('BODY')[0] : $(options.bloq_contenedor) //bloquear contenedor
    this.bloq_msg = !options.bloq_msg ? "" : options.bloq_msg
    this.bloq_id = !options.bloq_id ? 'Ajax_bloqueo' : options.bloq_id
    this.error_alert = options.error_alert == undefined ? true : options.error_alert == true

    if (this.bloq_contenedor_on)
        nvFW.bloqueo_activar(this.bloq_contenedor, this.bloq_id, this.bloq_msg)
    var bloq_on = this.bloq_contenedor_on;
    var objThis = this

    this.xml = new tXML()
    this.xml.method = method
    this.xml.async = async
    this.xml.onUploadProgress = this.Ajax_onUploadProgress;
    this.xml.onComplete = function () {
        //                                           if(bloq_on)
        //                                             window.setTimeout("nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')", objThis.ok_delay)
        if (objThis.bloq_contenedor_on) nvFW.bloqueo_desactivar(objThis.bloq_contenedor, objThis.bloq_id)
        try {
            var err = objThis
            oXML = new tXML();
            err.error_from_xml(objThis.xml)

            //var delay = 0
            //if (!oXML.loadXML(transport.responseText)) {
            //    err.numError = 10
            //    err.titulo = 'Error XML'
            //    err.mensaje = 'El resultado no se puede procesar.'
            //    err.debug_src = ''
            //    err.debug_desc = ''
            //}
            //else {
            //    err.error_from_xml(oXML)
            //    //                                               if (err.numError == 0)
            //    //                                                 delay = err.ok_delay
            //}
        }
        catch (e) {
            err.error_script(e)
        }
        var transport = this
        if (err.numError == 0) {
            //nvSesion:: Si es el mismo servidor actualiza la hora de ultimo acceso al sistema. 
            if ((new URL(document.URL)).origin == (new URL(transport.transport.responseURL)).origin && window.top.nvSesion != undefined) window.top.nvSesion.fe_ultimo_check = new Date()

            if (err.Ajax_onSuccess != null)
                err.Ajax_onSuccess(err, transport)
        }
        else {
            if (err.Ajax_onFailure != null)
                err.Ajax_onFailure(err, transport)
            if (err.error_alert)
                err.alert()
        }
    };
    this.xml.onFailure = function () {
        //                                           if(bloq_on)
        //                                             window.setTimeout("nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')", objThis.ok_delay)
        if (objThis.bloq_contenedor_on)  nvFW.bloqueo_desactivar(objThis.bloq_contenedor, objThis.bloq_id)
        var err = objThis
        err.numError = 10
        err.titulo = 'Error en la página de origen'
        err.mensaje = 'El resultado no se puede procesar.'
        err.debug_src = ''
        err.debug_desc = ''

        if (err.Ajax_onFailure != null)
            err.Ajax_onFailure(err, this.xhr)
        if (err.error_alert)
            err.alert()
    };

    var data = postBody == null ? parameters : postBody;
    this.xml.load(url, data ,null ) 

    //this.Ajax = new Ajax.Request(url, {
    //    encoding: encoding,
    //    contentType: contentType,
    //    method: method,
    //    asynchronous: async,
    //    parameters: parameters,
    //    postBody: postBody,
    //    //onCreate: avi_guardar_start,
    //    onFailure: function (transport) {
    //        //                                           if(bloq_on)
    //        //                                             window.setTimeout("nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')", objThis.ok_delay)
    //        nvFW.bloqueo_desactivar(objThis.bloq_contenedor, objThis.bloq_id)
    //        var err = objThis
    //        err.numError = 10
    //        err.titulo = 'Error en la página de origen'
    //        err.mensaje = 'El resultado no se puede procesar.'
    //        err.debug_src = ''
    //        err.debug_desc = ''

    //        if (err.Ajax_onFailure != null)
    //            err.Ajax_onFailure(err, transport)
    //        if (err.error_alert)
    //            err.alert()
    //    },
    //    onSuccess: function (transport) {
    //        //                                           if(bloq_on)
    //        //                                             window.setTimeout("nvFW.bloqueo_desactivar($(document.body), 'Ajax_bloqueo')", objThis.ok_delay)
    //        nvFW.bloqueo_desactivar(objThis.bloq_contenedor, objThis.bloq_id)
    //        try {
    //            var err = objThis
    //            oXML = new tXML();
    //            var delay = 0
    //            if (!oXML.loadXML(this.xhr.responseText)) {
    //                err.numError = 10
    //                err.titulo = 'Error XML'
    //                err.mensaje = 'El resultado no se puede procesar.'
    //                err.debug_src = ''
    //                err.debug_desc = ''
    //            }
    //            else {
    //                err.error_from_xml(oXML)
    //                //                                               if (err.numError == 0)
    //                //                                                 delay = err.ok_delay
    //            }
    //        }
    //        catch (e) {
    //            err.error_script(e)
    //        }

    //        if (err.numError == 0) {
    //            //nvSesion:: Si es el mismo servidor actualiza la hora de ultimo acceso al sistema. 
    //            if ((new URL(document.URL)).origin == (new URL(transport.transport.responseURL)).origin && window.top.nvSesion != undefined) window.top.nvSesion.fe_ultimo_check = new Date()

    //            if (err.Ajax_onSuccess != null)
    //                err.Ajax_onSuccess(err, this.xhr)
    //        }
    //        else {
    //            if (err.Ajax_onFailure != null)
    //                err.Ajax_onFailure(err, this.xhr)
    //            if (err.error_alert)
    //                err.alert()
    //        }
    //    }
    //});


}
      
    function tError_alert()
      {
      nvFW.alert(this.numError + ' - ' + this.mensaje, {
                                                title: this.titulo, 
                                                okLabel: "cerrar"
                                                })
      
      }
    function tError_error_from_xml(oXML)  
      {

      if (oXML != undefined) //oXML puede ser un tXML o un document. Si es "document" convertirlo a tXML()
        if (oXML.selectSingleNode == undefined)
          {
          var oXML2 = new tXML()
          oXML2.xml = oXML
          oXML = oXML2
          }

      this.numError = 0
      this.titulo = ""
      this.mensaje = ""
      this.debug_src = ""
      this.debug_desc = ""
      this.params = {}
      

      if (oXML == undefined) 
          {
          this.numError = 1000
          this.titulo = "Error XML"
          this.mensaje == 'Recurso no encontrado'
          }
      
      if (oXML.xml.parseError != undefined)
        {
        this.numError = oXML.xml.parseError.errorCode
        this.titulo = "Error XML"
        this.mensaje  = oXML.xml.parseError.reason
        }
      else
        {

        this.numError = parseInt(oXML.selectSingleNode('error_mensajes/error_mensaje/@numError').value)
          this.titulo = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/titulo'))
          this.mensaje = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/mensaje'))
          this.debug_src = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/debug_src'))
          this.debug_desc = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/debug_desc'))
          this.params = {}
          var NOD = oXML.selectSingleNode('error_mensajes/error_mensaje/params')
          for (var i = 0; i < NOD.childNodes.length; i++)
              if (NOD.childNodes[i].firstChild != undefined && NOD.childNodes[i].firstChild.nodeType == 1) //Si es un 'Element' compiar todo el XML
                  this.params[NOD.childNodes[i].nodeName] = XMLtoString(NOD.childNodes[i])
              else
                  this.params[NOD.childNodes[i].nodeName] = XMLText(NOD.childNodes[i])
              //this.params[NOD.childNodes[i].nodeName] = XMLText(NOD.childNodes[i])
              

        }  
      }
        
    function tError_error_xml(objXML)
        {
        var pe = objXML.parseError
        this.numError = pe.errorCode
        this.titulo = 'Error XML'
        this.mensaje = pe.reason
        this.debug_src = pe.srcText
        this.debug_desc = pe.errorCode + ' - url: "' + pe.url + '" - reason: "' + pe.reason + '" - srcText: "' + pe.srcText + '" - line: ' + pe.line + ' linepos: ' + pe.linepos + ' filepos: ' + pe.filepos
        }
  
  
    function tError_error_script(err)
        {
        this.numError = err.number
        this.titulo = 'Error Script'
        this.mensaje = err.description
        this.debug_src = err.number + ' - description: "' + err.description + '" - message: "' + err.message + '" - name: "' + err.name + '"'
        }  
        
    function tError_get_error_xml()
        {
        var error_xml = "<?xml version='1.0' encoding='iso-8859-1'?><error_mensajes><error_mensaje numError='" + this.numError + "'><titulo>" + this.titulo + "</titulo><mensaje><![CDATA[" + this.mensaje + "]]></mensaje><debug_src><![CDATA[" + this.debug_src + "]]></debug_src><debug_desc><![CDATA[" + this.debug_desc + "]]></debug_desc><params>" 
        for (var i in this.params)
          error_xml += "<" + i + "><![CDATA[" + this.params[i] + "]]></" + i + ">"
        error_xml += "</params></error_mensaje></error_mensajes>"
        return error_xml
        } 
        
    function tError_mostrar_error(src)
        {
        var strHTML = '<html xmlns="http://www.w3.org/1999/xhtml"><head><meta name="GENERATOR" content="Microsoft Visual Studio 6.0" /><link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet" /><title>Mostrar Error</title>'
        strHTML += '</head>'
        strHTML += '<body><table class="tb1"><tr class="tbLabel0"><td>'
        strHTML += this.numError + ' : ' + this.titulo
        strHTML += '</td></tr><tr><td>' + this.mensaje +  '</td></tr></table><table class="tb1"><tr class="tbLabel0"><td>Error</td></tr><tr><td>'
        strHTML += this.debug_src + '</td></tr><tr><td><textarea style="width: 100%" rows="10" size="5">' + this.debug_desc + '</textarea></td></tr></table></body></html>'
        }
     

