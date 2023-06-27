//***************************************************************
// Objeto tRS
//****************************************************************
function tRS(cn)
{
    this.filtroWhere = ""
    this.filtroXML = ""
    this.params = ""
    this.vistaGuardada = ""

  this.fields = new Array();
  this.recordcount = 0; 
  this.XMLSQL = "" //'<criterio><select vista="estado"><campos>*</campos></select></criterio>'
  this.cn = cn
  //if (!this.cn) this.cn = ""
  if (!cn) 
    {
    if (!nvFW)
      this.cn = '/FW/GetXML.aspx?accion=GETXML&criterio='
    else
      this.cn = nvFW.path.getXML + '?accion=GETXML&criterio='
    }
  else
      this.cn = cn
  this.async = false 
  
  this.format = 'getxml'
  this.format_tError = "xml"
  this.cacheControl = 'none' //Identifica si se puede cahear el resultado 'none', 'nvFW' (cachea en el objeto nvFW ), 'App' (cachea en el objeto Application de ASP), 'Session' 
  this.cacheExpire = 0 //Tiempo de vida de cache
  this.cacheExpireAbsolute = null //Fecha de expiración del cache

  this.lastError = new tError();
  this.position = -1
  this.objXML = ''
  this.objXMLSQL = ''
  
  //Eventos
  this.onComplete = null
  this.onError = null
  //Metodos
  this.open = rs_open;
  this.eof = rs_eof;
  this.bof = rs_bof;
  this.movenext =  rs_movenext;
  this.moveprevious = rs_moveprevious;
  this.getdata = rs_getdata;
  this.getfield = rs_getfield;
  //this.async_complete = rs_async_complete;
  this.cargar_fields = rs_cargar_fields;
  this.cargar_recordcount = rs_cargar_recordcount;
  
  this.cache_push = rs_cache_push; //Guarda los datos en la cache
  this.cache_pop = rs_cache_pop; //Recupera los datos de la cache
  
  //*******
  this.setvista = rs_setvista;

  this.addField = rs_addField; //Agrega un nuevo campo al RS
  this.addRecord = rs_addRecord;  //Agrega un nuevo registro al RS. El formato del registro deberá ser compatible con la definición de los fields
}

function rs_setvista(strVista)
{
var NOD = this.objXMLSQL.selectSingleNode('criterio/select/@vista')
NOD.nodeValue = strVista
//this.objXMLSQL.selectSingleNode('criterio/select/@vista').nodeValue = strVista
}

function rs_cache_push()
  {
  
  if (this.cacheControl != 'nvFW')
    return
  //Utiliza el nvFW del top o el del documento  
  var _nvFW = window.top.nvFW
  if (!_nvFW)
    _nvFW = nvFW
  if (!_nvFW)
    return
    
  //_nvFW.cache.add('tRS', {XMLSQL:this.XMLSQL, cn:this.cn, format: this.format, format_tError: this.format_tError}, {fields: this.fields, position: this.position, recordcount: this.recordcount, data: this.data, objXML: this.objXML})
    _nvFW.cache.add('tRS', { XMLSQL: this.XMLSQL, filtroWhere: this.filtroWhere, vistaGuardada: this.vistaGuardada, params: this.params, cn:this.cn, format: this.format, format_tError: this.format_tError}, {fields: this.fields, position: this.position, recordcount: this.recordcount, data: this.data, objXML: this.objXML})
    
  }
  
function rs_cache_pop()  
  {
  if (this.cacheControl != 'nvFW')
    return false
  //Utiliza el nvFW del top o el del documento
  var _nvFW = window.top.nvFW
  if (!_nvFW)
    _nvFW = nvFW
  if (!_nvFW)
    return false

  //var cache = _nvFW.cache.get('tRS', {XMLSQL:this.XMLSQL, cn:this.cn, format: this.format, format_tError: this.format_tError})
    var cache = _nvFW.cache.get('tRS', { XMLSQL: this.XMLSQL, filtroWhere: this.filtroWhere, vistaGuardada: this.vistaGuardada, params: this.params, cn:this.cn, format: this.format, format_tError: this.format_tError})
  
  if (cache == null)
    return false
    
  this.fields = cache['valores']['fields']
  this.position = cache['valores']['position']
  this.recordcount = cache['valores']['recordcount']
  this.data = cache['valores']['data']
  this.objXML = cache['valores']['objXML']
  return true
  }

function rs_cargar_fields(tErrorJson)
  {
  if (tErrorJson == undefined) //Si es un XML
    {
    if (this.objXML.selectSingleNode('rs_xml_json/fields') != null) //getxml_json
      {
      str = XMLText(this.objXML.selectSingleNode('rs_xml_json/fields'))
      this.fields = eval(str)
      str = XMLText(this.objXML.selectSingleNode('rs_xml_json/data'))
      this.data = eval(str)
      }
    else
      if (this.objXML.selectNodes("xml/s:Schema/s:ElementType/s:AttributeType").length > 0) //getxml
        {
        var NOD = this.objXML.selectNodes("xml/s:Schema/s:ElementType/s:AttributeType")
        for(var i=0; i<NOD.length; i++)
          {
          this.fields[i] = new Array();
          if (selectSingleNode("@rs:name", NOD[i]) == null)
            this.fields[i]["name"] = selectSingleNode( "@name", NOD[i]).nodeValue
          else
            this.fields[i]["name"] = selectSingleNode( "@rs:name", NOD[i]).nodeValue 
          this.fields[i]["datatype"] = selectSingleNode( "s:datatype/@dt:type", NOD[i]).nodeValue
          }
        }
      else
        if (this.objXML.selectSingleNode("error_mensajes/error_mensaje/params/fields") != null) //getterror XML
          {
          this.fields = JSON.parse(XMLText(this.objXML.selectSingleNode("error_mensajes/error_mensaje/params/fields")))
          this.data = JSON.parse(XMLText(this.objXML.selectSingleNode("error_mensajes/error_mensaje/params/rows")))
          }

    }
  else //Si viene el tErrorJSON
    {
    this.fields = tErrorJson.params.fields
    this.data = tErrorJson.params.rows
    }
  
  
  }
  

  
function rs_cargar_recordcount(tErrorJson)
  {
  if (tErrorJson == undefined) //Si es XML
    {
    if (this.objXML.selectSingleNode('rs_xml_json/data/@recordcount') != null)
       this.recordcount = this.objXML.selectSingleNode('rs_xml_json/data/@recordcount').nodeValue
    else
      if (this.objXML.selectNodes("xml/s:Schema/s:ElementType/s:AttributeType").length > 0)
        this.recordcount = this.objXML.selectNodes('xml/rs:data/z:row').length
      else
        if (this.objXML.selectSingleNode("error_mensajes/error_mensaje/params/recordcount") != null)
            this.recordcount = XMLText(this.objXML.selectSingleNode("error_mensajes/error_mensaje/params/recordcount"))

    }
  else //SI viene el tErrorJSON
    {
    this.recordcount = tErrorJson.params.recordcount
    }
  

  //if (this.xml_format.toLowerCase() != 'getxml')
  //  this.recordcount = this.objXML.selectSingleNode('rs_xml_json/data/@recordcount').nodeValue
  //else  
  //  this.recordcount = this.objXML.selectNodes('xml/rs:data/z:row').length
  if (this.recordcount > 0)
    this.position = 0
  else
    this.position = -1  
  }  
  
function rs_open(XMLSQL, cn, filtroWhere, vistaGuardada, params)
  {
  var arP = {}
  if (typeof(XMLSQL) == 'object')
    {
    for (el in XMLSQL)
      switch (el)
        {
         case 'filtroXML':
          break
        case 'filtroWhere':
          filtroWhere = XMLSQL.filtroWhere
          break
        case 'vistaGuardada':
          vistaGuardada = XMLSQL.vistaGuardada
          break
        case 'params':
          params = XMLSQL.params
          break
        case 'cn':
          cn = XMLSQL.cn
          break
        default:
           arP[el] = XMLSQL[el]
        }
    XMLSQL = XMLSQL.filtroXML
    }
  
  if (!filtroWhere)
    filtroWhere = ""

  if (!vistaGuardada)
    vistaGuardada = ""
  
  if (!params)
    params = ""

  if (cn != undefined && cn != "")
    this.cn = cn
  
  var pvURL = encodeURIComponent(XMLSQL)
  if (filtroWhere != "")
      pvURL += "&filtroWhere=" + encodeURIComponent(filtroWhere)

  if (vistaGuardada != "")
      pvURL += "&vistaGuardada=" + encodeURIComponent(vistaGuardada)

  if (params != "")
      pvURL += "&params=" + encodeURIComponent(params)
   
   for (el in arP)
      pvURL += "&" + el + "=" + encodeURIComponent(arP[el])

  this.XMLSQL = pvURL
  pvURL = this.cn + pvURL

  var params = {}
  
  //Pasar URL a parametros
  var str = "[?&]([^?&]*)=([^&]*)"
  var reg = new RegExp(str, "ig")
  var matches = [];
  //var cad = this.cn
  var match = reg.exec(pvURL);
  while (match != null) 
    {
    //this.cn = replace(pvURL, match[0], "")
    params[match[1]] = match[2]
    matches.push(match);
    match = reg.exec(pvURL);
    }

  this.cn = this.cn.substring(0, this.cn.indexOf("?"))

  if (this.xml_format != undefined)
      this.format = this.xml_format

  if (this.format.toLowerCase() == "rs_xml")  this.format = "getxml"
  if (this.format.toLowerCase() == "rsxml_json" || this.format.toLowerCase() == "rs_xml_json")  this.format = "getxml_json"
  params.accion = this.format
  params.ef = this.format_tError


  
  //if (!params.accion)
  //  //si 'rs_xml' -> criterio = 'GETXML'
  //  //si no ->criterio = 'rs_xml_json'
  //  if (this.xml_format.toLowerCase() == 'rs_xml') //this.cn = replace(this.cn, '=GETXML&', '=GETXML_JSON&')
  //    params.accion = "GETXML"
  //  else
  //    params.accion = this.xml_format
  
  //if (params.accion.toLowerCase() == 'getxml')
  //  params.accion = this.xml_format.toLowerCase() ==  'rs_xml_json' ?  'getxml_json' :'getxml'


  var strParams = ""
  for (var name in params)
    {
    if (strParams == "")
      strParams += "" + name + "=" + params[name]
    else
      strParams += "&"  + name + "=" + params[name]
    }
  
  
  //Carga el criterio
  //  this.objXMLSQL = new tXML()
  //  if (!this.objXMLSQL.loadXML(XMLSQL))
  //    {
  //    this.strError = 'Error en el XMLSQL.\n' + this.objXMLSQL.parseError['description']   
  //    this.position = -1
  //    return false
  //    }
  this.filtroXML = XMLSQL
  this.filtroWhere = filtroWhere
  this.params = params
  this.vistaGuardada = vistaGuardada

  var recupera_cache = this.cache_pop()
  if (recupera_cache)
    {
    //Si existe el onComplete ejecutarlo
    if (this.onComplete != null)
      this.onComplete(this)
    return true  
    }
  
  //if (this.async)
  //  {
    //Ejecucion asincrona
    this.objXML = new tXML()
    this.objXML.async = this.async
    //this.objXML.method = "POST"
    var oXMLHttp = XMLHttpObject()
   

    var objRS = this
    //this.objXML.onComplete = function()
    //var process_xml_return = function()
    //                            {
    //                            //"this" es el obteto tXML
    //                            //Evaluar si se recuperó un XML
    //                            if (objRS.objXML.parseError.numError == 0)
    //                              {
    //                              //Si viene un RSXML
    //                              if (objRS.objXML.selectSingleNode('rs_xml_json/fields') != null || objRS.objXML.selectSingleNode('xml/rs:data') != null)
    //                                {
    //                                objRS.cargar_fields()
    //                                objRS.cargar_recordcount()
    //                                objRS.cache_push()
    //                                objRS.lastError = new tError()
                                    
    //                                }
                                  
    //                              //Si viene un XML Error
    //                              if (objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/@numError') != null)
    //                                {
    //                                objRS.lastError = new tError()
    //                                objRS.lastError.numError = objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/@numError').nodeValue
    //                                objRS.lastError.mensaje = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/mensaje'))
    //                                objRS.lastError.debug_src = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/debug_src'))
    //                                objRS.lastError.debug_desc = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/debug_desc'))
    //                                }
    //                              }
    //                            else
    //                              {
    //                              objRS.lastError = new tError()
    //                              objRS.lastError.error_xml(objRS.objXML)
    //                              objRS.lastError.mensaje = "Error al procesar el rsultado. No es un XML válido.\n" + objRS.lastError.mensaje
    //                              }
                                 
    //                              if (objRS.lastError.numError == 0)
    //                                {
    //                                //Ejecutar el codigo
    //                                if (objRS.onComplete != null)
    //                                  objRS.onComplete(objRS)
    //                                }
    //                              else
    //                                {
    //                                if (objRS.onError != null)
    //                                  objRS.onError(objRS)  
    //                                }
                                
    //                            }
    var miOBJETO = this.objXML
    oXMLHttp.onreadystatechange = function()
                                          {
                                          if (oXMLHttp.readyState == 4)
                                            {
                                             if (oXMLHttp.status == 200) 
                                               { 
                                               if (oXMLHttp.responseXML != undefined)
                                                 {
                                                 miOBJETO.xml = oXMLHttp.responseXML
                                                 //Si viene un RSXML
                                                 if (objRS.objXML.selectSingleNode('rs_xml_json/fields') != null || objRS.objXML.selectSingleNode('xml/rs:data') != null)
                                                   {
                                                   objRS.cargar_fields()
                                                   objRS.cargar_recordcount()
                                                   objRS.cache_push()
                                                   objRS.lastError = new tError()
                                                   }
                                  
                                                 //Si viene un XML Error
                                                 if (objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/@numError') != null)
                                                   {
                                                   objRS.lastError = new tError()
                                                   objRS.lastError.error_from_xml(oXMLHttp.responseXML)
                                                   if (objRS.lastError.numError == 0)
                                                     {
                                                     objRS.cargar_fields()
                                                     objRS.cargar_recordcount()
                                                     objRS.cache_push()
                                                     //objRS.lastError = new tError()
                                                     }
                                                   //objRS.lastError.numError = objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/@numError').nodeValue
                                                   //objRS.lastError.mensaje = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/mensaje'))
                                                   //objRS.lastError.debug_src = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/debug_src'))
                                                   //objRS.lastError.debug_desc = XMLText(objRS.objXML.selectSingleNode('/error_mensajes/error_mensaje/debug_desc'))
                                                   }

                                                 //miOBJETO.parseError = XMLParseError(oXMLHttp.responseXML)
                                                 }
                                               else //Cuando viene un tError JSON
                                                 {
                                                 var resText = oXMLHttp.responseText
                                                 objRS.lastError = JSON.parse(resText)
                                                 if (objRS.lastError.numError == 0)
                                                     {
                                                     objRS.cargar_fields(objRS.lastError)
                                                     objRS.cargar_recordcount(objRS.lastError)
                                                     objRS.cache_push()
                                                     }
                                                 //objRS.lastError = new tError()
                                                 }
                                                 if (objRS.lastError.numError == 0) {
                                                     //debugger
                                                     //nvSesion:: Si es el mismo servidor actualiza la hora de ultimo acceso al sistema. 
                                                     if ((new URL(document.URL)).origin == (new URL(oXMLHttp.responseURL)).origin && window.top.nvSesion != undefined) window.top.nvSesion.fe_ultimo_check = new Date()


                                                     if (typeof (objRS.onComplete) == 'function')
                                                         objRS.onComplete(objRS)
                                                 }
                                               else
                                                 if (typeof(objRS.onError) == "function")
                                                   objRS.onError(objRS)
                                               }
                                             else //oXMLHttp.status <> 200
                                               {
                                               if (oXMLHttp.status == 0) //status == 0 cuando no hay conexión
                                                 {
                                                 objRS.lastError.numError = 1000
                                                 objRS.lastError.mensaje = "En estos momentos no se puede acceder al recurso solicitado.<br>Revise el estado de su conexión e intente nuevamente."
                                                 }
                                               else
                                                 {
                                                 objRS.lastError.numError = 101
                                                 objRS.lastError.mensaje = "Error desconocido. HTTP Status:" + oXMLHttp.status + " - " + oXMLHttp.statusText
                                                 }
                                               if (typeof(objRS.onError) == "function")
                                                 objRS.onError(objRS)

                                               }
 
                                            }  
                                          };
//       var escape2 = function (str)
//      {
//      var res = escape(str)
//      var reg = new RegExp("\\+", "ig" )
//      res = res.replace(reg, "%2B")
//      return res
//      }


    oXMLHttp.open('POST', this.cn, this.async)
    oXMLHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
    oXMLHttp.send(strParams)

    //this.objXML.load(this.cn, strParams)
    if (!this.async)
      return this.lastError.numError == 0
//    }
//  else  
//    {  
//    //Ejecucion sincrona
//    this.objXML = new tXML()
//    this.objXML.method = "POST"
//    this.objXML.async = false
//    if (this.objXML.load(this.cn, strParams))
//       {
//       this.cargar_fields()
//       this.cargar_recordcount()
//       this.cache_push()
//       //Si existe el onComplete ejecutarlo
//       if (this.onComplete != null)
//         this.onComplete(this)
//       }
//    else
//      {
//      this.lastError = new tError()
//      this.lastError.numError = 1004
//      this.lastError.mensaje = 'No se puede abrir el destino.\n' + this.objXML.parseError['description']
//      this.position = -1
//      //Si existe el onError ejecutarlo
//      if (this.onError != null)
//        this.onError(this)
//      return false
//      }
//    }  
  }

function rs_eof()
  {
  return ((this.position >= this.recordcount) || (this.recordcount == 0)) 
  }
function rs_bof()
  {
  return ((this.position < 0) || (this.recordcount == 0)) 
  }

function rs_movenext()
  {
  this.position = this.position + 1
  }
  
function rs_moveprevious()
  {
  this.position = this.position - 1
  }

function rs_getfield(strField)
  {
  for (var i=0;i<this.fields.length;i++)
    if (this.fields[i].name.toLowerCase() == strField.toLowerCase())
      return this.fields[i]
  return null
  }
function rs_getdata(strField, isNull)
  {
  if (isNull == undefined) isnull = null
  //this.objXML.getElementsByTagName('xml/rs:data/z:row[' + this.position + ']/@estado')[0].nodeValue
  var resultado
  try 
    {
    if (this.data != undefined)
      resultado = this.data[this.position][strField]
    else 
      {
      var position = Prototype.Browser.IE ? this.position : this.position +1
      var path = 'xml/rs:data/z:row[' + position + ']/@' + strField
      nod = selectSingleNode(path, this.objXML.xml)
      resultado = nod.nodeValue
      //resultado = this.objXML.selectSingleNode('xml/rs:data/z:row[' + position + ']/@' + strField).nodeValue
      }
    //resultado = this.objXML.getElementsByTagName('xml/rs:data/z:row[' + this.position + ']/@' + strField)[0].nodeValue
    return resultado
    }
  catch(e)  
    {
    return isNull
    }
  }


function rs_addField(name, datatype) 
  {
  var i = this.fields.length
  this.fields[i] = new Array();
  this.fields[i]["name"] = name
  this.fields[i]["datatype"] = datatype
  }

function rs_addRecord(record)
  {
  //this.format.toLowerCase() = "getxml_json"
  this.format = "getxml_json"
  if (!this.data) this.data = {}
  this.data[this.recordcount] = record
  this.recordcount = parseInt(this.recordcount) + 1
  if (this.recordcount == 1) this.position = 0
  }

