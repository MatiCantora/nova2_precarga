
function tScript()
  { 
  this.script = ''
  this.string = ''
  this.set_string = set_string;
  this.lenguaje = '';
  this.cod_cn = '';
  this.lenguajeReadOnly = false;
  this.parametros = [];
  this.param_add = [];
  this.type = {};
  this.get_campos = tget_campos;
  this.get_xsl = tget_xsl;
  this.get_rpt = tget_rpt;
  this.cargar_parametros = tcargar_parametros;
  this.cargar_param_add = tcargar_param_add;
  this.script_to_string = tscript_to_string;
  this.string_to_script = tstring_to_script;
  this.error = ''
  this.target_parse = ttarget_parse;
  
  this.param_add[0] = {};
  this.param_add[0].parametro = 'hoy()'
  this.param_add[0].etiqueta = 'hoy()'

  this.type[0] = {};
  this.type[0]['tipo'] = 'select'
  this.type[0]['desc'] = 'in'
  this.type[0]['filtroWhere'] = "<? type='in'></?>"
  this.type[1] = {};
  this.type[1]['tipo'] = 'select'
  this.type[1]['desc'] = 'inSQL'
  this.type[1]['filtroWhere'] = "<? type='inSQL'></?>"
  this.type[2] = {};
  this.type[2]['tipo'] = 'select'
  this.type[2]['desc'] = 'charindex'
  this.type[2]['filtroWhere'] = "<? type='charindex'></?>"
  this.type[3] = {};
  this.type[3]['tipo'] = 'select'
  this.type[3]['desc'] = 'igual'
  this.type[3]['filtroWhere'] = "<? type='igual'></?>"
  this.type[4] = {};
  this.type[4]['tipo'] = 'select'
  this.type[4]['desc'] = 'mas (>=)'
  this.type[4]['filtroWhere'] = "<? type='mas'></?>"
  this.type[5] = {};
  this.type[5]['tipo'] = 'select'
  this.type[5]['desc'] = 'menos (<=)'
  this.type[5]['filtroWhere'] = "<? type='menos'></?>"
  this.type[6] = {};
  this.type[6]['tipo'] = 'select'
  this.type[6]['desc'] = 'mayor'
  this.type[6]['filtroWhere'] = "<? type='mayor'></?>"
  this.type[7] = {};
  this.type[7]['tipo'] = 'select'
  this.type[7]['desc'] = 'menor'
  this.type[7]['filtroWhere'] = "<? type='menor'></?>"
  this.type[8] = {};
  this.type[8]['tipo'] = 'select'
  this.type[8]['desc'] = 'like'
  this.type[8]['filtroWhere'] = "<? type='like'></?>"
  this.type[9] = {};
  this.type[9]['tipo'] = 'select'
  this.type[9]['desc'] = 'isnull'
  this.type[9]['filtroWhere'] = "<? type='isnull'/>"
  this.type[10] = {};
  this.type[10]['tipo'] = 'select'
  this.type[10]['desc'] = 'distinto'
  this.type[10]['filtroWhere'] = "<? type='distinto'></?>"
  this.type[11] = {};
  this.type[11]['tipo'] = 'select'
  this.type[11]['desc'] = 'sql'
  this.type[11]['filtroWhere'] = "<SQL type='sql'></SQL>"
  this.type[12] = {};
  this.type[12]['tipo'] = 'select'
  this.type[12]['desc'] = 'AND'
  this.type[12]['filtroWhere'] = "<AND></AND>"
  this.type[13] = {};
  this.type[13]['tipo'] = 'select'
  this.type[13]['desc'] = 'OR'
  this.type[13]['filtroWhere'] = "<OR></OR>"
  this.type[14] = {};
  this.type[14]['tipo'] = 'select'
  this.type[14]['desc'] = 'NOT'
  this.type[14]['filtroWhere'] = "<NOT></NOT>"
  this.type[15] = {};
  this.type[15]['tipo'] = 'procedure'
  this.type[15]['desc'] = 'int'
  this.type[15]['filtroWhere'] = "<? DataType='int'></?>"
  this.type[16] = {};
  this.type[16]['tipo'] = 'procedure'
  this.type[16]['desc'] = 'money'
  this.type[16]['filtroWhere'] = "<? DataType='money'></?>"
  this.type[17] = {};
  this.type[17]['tipo'] = 'procedure'
  this.type[17]['desc'] = 'datetime'
  this.type[17]['filtroWhere'] = "<? DataType='datetime'></?>"
  this.type[18] = {};
  this.type[18]['tipo'] = 'procedure'
  this.type[18]['desc'] = 'varchar'
  this.type[18]['filtroWhere'] = "<? DataType='varchar'></?>"
  }
  
function set_string(string)  
  {
  this.string = string
  this.script = this.string_to_script(string)
  return this.script
  }
  
function set_script(script)  
  {
  this.script = script
  this.string = this.script_to_string(script)
  return this.string 
  }  
  
  
function tcargar_parametros(parametros)
  {
  this.parametros = [];
  for (var i = 0; i < parametros.size(); i++) {
      this.parametros[i] = {};
      this.parametros[i]['parametro'] = parametros[i]['parametro']
      this.parametros[i]['tipo_dato'] = parametros[i]['tipo_dato']
      this.parametros[i]['etiqueta'] = parametros[i]['etiqueta']
      //si es datetime agegarlo a param_add
      if (parametros[i]["tipo_dato"].toLowerCase() == 'datetime') {
          var j = this.param_add.length
          this.param_add[j] = {};
          this.param_add[j].parametro = "ajustarFecha(" + parametros[i]['parametro'] + ")"
          this.param_add[j].etiqueta = "ajustarFecha(" + parametros[i]['parametro'] + ")"
          j = this.param_add.length
          this.param_add[j] = {};
          this.param_add[j].parametro = "FechaToSTR(" + parametros[i]['parametro'] + ")"
          this.param_add[j].etiqueta = "FechaToSTR(" + parametros[i]['parametro'] + ")"
      }
  }
  }


function tcargar_param_add(parametros) {
    this.param_add = [];
    for (var i = 0; i < parametros.size(); i++) {
        this.param_add[i] = {};
        this.param_add[i]['parametro'] = parametros[i]['parametro']
        this.param_add[i]['etiqueta'] = parametros[i]['etiqueta']
    }
}
  
function tget_campos()
   { 
   txt = this.string
   var reg = new RegExp("\\s{1}vista\\s*=\\s*('|\")(.*?)('|\")")
   var regcn = new RegExp("\\s{1}cn\\s*=\\s*('|\")(.*?)('|\")")
   var resultado = txt.match(reg)

   var resultadocn = txt.match(regcn)
   var cn = "&cn=" + (resultadocn != null ? resultadocn[2] : '')

   if (resultado != null)
   {
     var vista = "&vista=" + resultado[2]
    // strXML = "<criterio><select vista='" + vista + "' cn='" + + "'><campos>*</campos><SQL type='sql'>1=2</SQL></select></criterio>"
       
     var rs = new tRS();
     rs.cn = '/fw/transferencia/editor_script.aspx?modo=getRs&criterio=&type=view' + vista + cn
     rs.xml_format = 'rs_xml'
     rs.open("")
     var campos = {}
     if(rs.fields.length > 0)
        {
         rs.fields.each(function (fields, i) {
             if (fields["name"] != undefined)
                 campos[i] = fields["name"]
         });
        }
   }

   txt = this.string
   var reg = new RegExp("\\s{1}CommandText\\s*=\\s*('|\")(.*?)('|\")")
   var resultado = txt.match(reg)
   if (resultado != null) {
       var vista = "&vista=" + resultado[2]
      // strXML = "<criterio><select vista='sys.parameters'><campos>replace(name,'@','') as name</campos><filtro><object_id type='igual'>object_id('" + vista + "')</object_id></filtro></select></criterio>"

       var rs = new tRS();
       rs.cn = '/fw/transferencia/editor_script.aspx?modo=getRs&criterio=&type=sp' + vista + cn
       rs.open("")
       var campos = {}
       var i = 0
       while (!rs.eof()) {
           campos[i] = rs.getdata("name")
           i++
           rs.movenext()
       }
   }
   return campos
   }

function tget_xsl()
{
   txt = this.string
   var files = new Array();
   var reg = new RegExp("\\s{1}vista\\s*=\\s*('|\")(.*?)('|\")")
   var resultado = txt.match(reg)
   if (resultado != null)
     {
     var vista = resultado[2]
     
     var oXML = new tXML()
     criterio ='<criterio><select vista="' + vista + '"/></criterio>'
     oXML.async = false
     if (oXML.load('/fw/GetXML.aspx', "accion=get_plantillas&criterio=" + criterio))
      {
         var NOD = oXML.selectNodes('/xml/rs:data')
         if (NOD != null)
          {
           if (NOD.length > 0)
            {
               NOD = NOD[0]
               for(var i = 1; i <= NOD.childNodes.length; i++)
                 {
                 
                  files[i] = new Array();
                  files[i]['path'] = NOD.childNodes[i-1].getAttribute('path_xsl')
                  files[i]['name'] = NOD.childNodes[i-1].getAttribute('name')
                 }
            }
          }     
      }
//     var XML1 = new ActiveXObject("Microsoft.XMLDOM")
//     criterio ='<criterio><select vista="' + vista + '"/></criterio>'
//     XML1.async = false
//     if (XML1.load("GetXML.asp?accion=get_plantillas&criterio=" + criterio))
//       {
//       NOD = XML1.getElementsByTagName('xml/rs:data')[0]
//       for(var i=1; i<=NOD.childNodes.length; i++)
//         {
//         files[i] = new Array();
//         files[i]['path'] = getAttribute(NOD.childNodes[i-1], 'path')
//         files[i]['name'] = getAttribute(NOD.childNodes[i-1], 'name')
//         }
//       }
     }
   return files
   }   
   
function tget_rpt()
{
    
   txt = this.string
   var files = new Array();
   var reg = new RegExp("\\s{1}vista\\s*=\\s*('|\")(.*?)('|\")")
   var resultado = txt.match(reg)
   if (resultado != null)
     {
     var vista = resultado[2]

      var oXML = new tXML()
     criterio ='<criterio><select vista="' + vista + '"/></criterio>'
     oXML.async = false
     if (oXML.load('/fw/GetXML.aspx', "accion=get_reportes&criterio=" + criterio))
      {
         var NOD = selectNodes('xml/rs:data',oXML.xml)
         if (NOD != null)
          {
           if (NOD.length > 0)
            {
               NOD = NOD[0]
               for(var i = 1; i <= NOD.childNodes.length; i++)
                 {
                  files[i] = new Array();
                  files[i]['path'] = NOD.childNodes[i-1].getAttribute('path_reporte')
                  files[i]['name'] = NOD.childNodes[i-1].getAttribute('name')
                 }
            }
          }     
      }

//     var XML1 = new ActiveXObject("Microsoft.XMLDOM")
//     criterio ='<criterio><select vista="' + vista + '"/></criterio>'
//     XML1.async = false
//     if (XML1.load("GetXML.asp?accion=get_reportes&criterio=" + criterio))
//       {
//       NOD = XML1.getElementsByTagName('xml/rs:data')[0]
//       for(var i=1; i<=NOD.childNodes.length; i++)
//         {
//         files[i] = new Array();
//         files[i]['path'] = getAttribute(NOD.childNodes[i-1], 'path')
//         files[i]['name'] = getAttribute(NOD.childNodes[i-1], 'name')
//         }
//       }
     }
   return files
   }      
  
function tscript_to_string(script,error)
{ 
 if (script!="")
  {
  
     // for (var i in this.parametros)
     for (var i = 0; i < this.parametros.size(); i++) 
      {
      parametro = this.parametros[i]['parametro']
      var str = "('|\")\\s*\\+\\s*(" + parametro + ")\\s*\\+\\s*(\\1)"
      var reg = new RegExp(str, 'ig')
      script = script.replace(reg, "{$2}")
      }
    
    //for (var i in this.param_add)
     for (var i = 0; i < this.param_add.size(); i++) 
      {
      parametro = this.param_add[i].parametro
      //Reemplazar lo caracteres especiales de la exp regular
      strExp = "([\\\\\(\\)\\+])" 
      reg = new RegExp(strExp, "ig")  
      parametro = parametro.replace(reg, "\\$1")
      var str = "('|\")\\s*\\+\\s*(" + parametro + ")\\s*\\+\\s*(\\1)"
      var reg = new RegExp(str, 'ig')
      script = script.replace(reg, "{%$2%}")
      }
        
     var str = "('|\")\\s*\\+\\s*(\\b.*\\b)\\s*\\+\\s*(\\1)"
     var reg = new RegExp(str, 'ig')
     var arr = script.match(reg) 
     if (arr) {
         
         var strError = ""
         for (var i = 0; i < arr.length; i++) {
             strError += "" + arr[i].replace(/\+/ig, "").replace(/\'/ig, "") + "<br>"
         }

         //if (strError != "") {
         //    alert("Estas variables no están definidas: " + strError)
         //}

         if (arr.length > 0) {
             script = script.replace(reg, "{$2}")
         }
     }

    try
     {
     var resultado = eval(script)  
     this.error = ''
     return resultado
     }
     catch(e)  
     {
     this.error = 'Error en la conversión'
     return ""
     }

   }  
 else
    return "" 
       
}


function tstring_to_script(string,format_noparam)
{

  if (format_noparam == undefined)
      format_noparam = true

  var string = replace(string, "\\", "\\\\") //Reemplazar barra simple por doble
  string = replace(string, "'", "\\'") //Reemplazar comillas simples
  string = replace(string, String.fromCharCode(13) + String.fromCharCode(10), "\\n") //Reemplazar retorno de carro y salto de linea
  string = replace(string, "\n", "\\n") //Reemplazar salto de linea

  var parametro
  var strExp = ''
  var reg = ''

  //    for (j in this.parametros)
  for (var j = 0; j < this.parametros.size(); j++) {
   parametro = this.parametros[j]["parametro"]
   strExp = "\\{(" + parametro + ")\\}" 
   reg = new RegExp(strExp, "ig")
   string = string.replace(reg, "' + " + parametro + " + '")
   }
  

  //for (var i in this.param_add)
  for (var i = 0; i < this.param_add.size(); i++) {
   parametro = this.param_add[i].parametro
   //Reemplazar lo caracteres especiales de la exp regular
   strExp = "([\\\\\(\\)\\+])" 
   reg = new RegExp(strExp, "ig")  
   parametro = parametro.replace(reg, "\\$1")
   //Contruir la expresion
   strExp = "\\{%(" + parametro + ")%\\}" 
   reg = new RegExp(strExp, "ig")  
   //reemplazar
   string = string.replace(reg, "' + " + this.param_add[i].parametro + " + '")
  }

  //convierte a formato script en el caso que no este el parametro definido. es decir: de {param_no_existe} a '+ param_no_existe +'
  if (format_noparam) {

        var str = "\\{([^\\}]*)\\}"
        var r = new RegExp(str, "ig")
        var res = string.match(r)
        if (res) {
            for (var i = 0; i < res.length; i++) {
                string = replace(string, res[i], "' + " + replace(replace(res[i], "{", ""), "}", "") + " + '")
            }
      }

  }

var resultado = "'" + string + "'"
return resultado
}

/**************************************************************************************/
//                            TARGET
/**************************************************************************************/
function ttarget_parse(target)
  {
  var i
  //Los targets vienen separados por ;
  //Utiliza el split si sencuentra el ; o simplemente asigna el valor al primer elemento
  var destinos = new Array();
  if (target.indexOf(';') == -1)
   {
   destinos[0] = target
   }
  else  
   destinos = target.split(';')
   
  //Elimina los espacio al principio
  for (var i = 0; i < destinos.length; i++)
    {
    var r = new RegExp("^\\s*") //Espacios en blanco al principio
    destinos[i] = destinos[i].replace(r, '')
    //Elimina los destinos en blanco
    if (destinos[i] == '')
      {
      destinos.splice(i, 1)
      i--
      }
    } 
    
  var arrTarget = new Array();
  for (var i=0; i < destinos.length; i++)
    {
    var target = destinos[i]
    var protocolo = target.substr(0, target.indexOf('://')).toUpperCase()
    switch (protocolo) 
      {
      case "FILE": //Copia el archivo resultado al destino
         var file = ttarget_get_file(target)
         arrTarget[i] = file
      break
      case "MAILTO" :
         var mailto = ttarget_get_mailto(target)
         arrTarget[i] = mailto
      break
      case "NAME": //Copia el archivo resultado al destino
         arrTarget[i] = {}
         arrTarget[i]['protocolo'] = protocolo
         arrTarget[i]['filename'] = target.substr(target.indexOf('://') + 3, target.length)
         arrTarget[i]['target'] = target
      break   
      default :
         arrTarget[i] = {}
         arrTarget[i]['protocolo'] = protocolo
         arrTarget[i]['target'] = target
      break
      } 
    }
  return arrTarget  
  }


function ttarget_get_file(strfile)
{
  var file = {}
  file['protocolo'] = 'file'
  file['target'] = strfile
  
    //{{<opcional comp_metodo='zip' comp_algoritmo='' comp_pwd'' xls_save_as=''/>}}

  var raiz = ''
  path_destino = strfile.substr(strfile.indexOf('://') + 3, strfile.length).split("||")[0]
  file['path'] = path_destino
  file['folder'] = fso_GetParentFolder(path_destino) 
  file['filename'] = fso_GetFileName(path_destino)
  file['extencion'] = fso_GetExtencion(path_destino)

  file['xls_save_as'] = ""
  file['comp_metodo'] = ""
  file['comp_algoritmo'] = ""
  file['comp_filename'] = ""
  file['comp_pwd'] = ""
  file['target_agregar'] = ""
  file['codificacion'] = ""    

  var strExp = '(\\|\\|<(.*?)>\\|\\|)'
  var reg = new RegExp(strExp, "ig")
  var res = []
  res = strfile.match(reg)
  res = res ? res : [] 
  if (res.length > 0)
  {
      strExp = '[|]'
      reg = new RegExp(strExp, "ig")
      res = res[0].replace(reg,"")
      var objxml = new tXML();
      if (objxml.loadXML(res))
      {
          file['xls_save_as'] = !selectSingleNode("opcional/@xls_save_as", objxml.xml) ? '' : selectSingleNode("opcional/@xls_save_as", objxml.xml).value
          file['comp_metodo'] = !selectSingleNode("opcional/@comp_metodo", objxml.xml) ? '' : selectSingleNode("opcional/@comp_metodo", objxml.xml).value
          file['comp_filename'] = !selectSingleNode("opcional/@comp_filename", objxml.xml) ? '' : selectSingleNode("opcional/@comp_filename", objxml.xml).value
          file['comp_algoritmo'] = !selectSingleNode("opcional/@comp_algoritmo", objxml.xml) ? '' : selectSingleNode("opcional/@comp_algoritmo", objxml.xml).value
          file['comp_pwd'] = !selectSingleNode("opcional/@comp_pwd", objxml.xml) ? '' : selectSingleNode("opcional/@comp_pwd", objxml.xml).value
          file['target_agregar'] = !selectSingleNode("opcional/@target_agregar", objxml.xml) ? '' : selectSingleNode("opcional/@target_agregar", objxml.xml).value
          file['codificacion'] = !selectSingleNode("opcional/@codificacion", objxml.xml) ? '' : selectSingleNode("opcional/@codificacion", objxml.xml).value    
      }
  }

  return file
}


function ttarget_get_mailto(strmailto)
   {
   var ma, mb, mc, md
   //Array resultado
   var mailto = new Array()
   //descompone la cadena entre la direccion y los parametros
   ma = strmailto.split('?') 
   //descompone la cadena entre protocolo y dirección
   mb = ma[0].split('://')
   mailto[mb[0]] = mb[1]
   mc = ma[1].split('&')
   for (var i=0; i < mc.length; i++)
     {
     md = mc[i].split('=')
     mailto[md[0].toLowerCase()] = replace(md[1],"~",";")
     }
   //si el "to" no existe utilizar el mailto
   
   if (!mailto["to"] || mailto["to"] == '')
     mailto["to"] =  mailto.MAILTO
   //else                                         -- OJO
     //mailto["to"] += ';' + mailto.MAILTO        -- OJO
   
   
   mailto["protocolo"] = 'mailto'
   mailto["target"] = strmailto
   return mailto
   /*
   mailto["mailto"]
   mailto["to"]
   mailto["cc"]
   mailto["bcc"]
   mailto["subject"]
   mailto["body"]
   mailto["attach"]
   */
   }     