<%@  language="jscript" %>

<!--#include virtual="meridiano/scripts/pvXMLtoSQL.asp"-->
<!--#include virtual="meridiano/scripts/pvUtilesASP.asp"-->
<%

Response.Expires = 0
Response.Buffer = false
/***************************************************/
// Recuperar parametros
/***************************************************/

//Parametros de datos
var id_ref_doc = obtenerValor("id_ref_doc") //id del documento
var vista = obtenerValor("vista") //id del documento


//Parametros de destino
var ContentType = obtenerValor("ContectType")         //Identifica ese valor en el flujo de salida
var target = obtenerValor("target")                   //Itenfifica donde será envíado el flujo de salida
var salida_tipo = obtenerValor("salida_tipo")         //Identifica si en la llamada será devuelto el resultado o un informe de resultado

//Ajustar valores NULL
//Si vienen en null inicializarlos a ''

if (target == null)
  target = ''
    
if (salida_tipo == null ||salida_tipo == '')
  salida_tipo= 'adjunto'    
  
if (ContentType == null)
  ContentType = ''
/*
var ext 
switch (ContentType.toLowerCase()) 
  {
  case 'application/vnd.ms-excel' :
    ext = '.xls'
    break
  case 'application/msword' :
     ext = '.doc'
    break  
  case 'text/html' :
    ext = '.html'
    break    
  case 'application/pdf' :
    ext = '.pdf'
    break
  case 'text/xml' :
    ext = '.xml'
    break  
  default :
    ContentType = 'text/html' 
    ext = '.html'
  } 
*/
  

/*****************************************************/
// Variable de error
/*****************************************************/
var objError = new tError();
objError.salida_tipo = salida_tipo
objError.debug_src = 'getFile.asp'

var fso = Server.CreateObject("Scripting.FileSystemObject")

/*********************************************************************/
//Recuperar datos
//var strSQL = XMLtoSQL(filtroXML, filtroWhere)
//Procesa el filtroXML y vevuelve un recordset con los datos resultado.
//Si no devuelve el recordset da error
//Luego controla el resultado, si existe el campo forxml_data, carga el 
//XML con esos datos, sino carga el resultado del recordset
/*********************************************************************/

try 
  {

      var rs = DBOpenRecordset('select * from ' + vista + ' where id_ref_doc = ' + id_ref_doc)  
  /*
  var mStream = Server.CreateObject("ADODB.Stream")
  mStream.Mode = 3 //adModeReadWrite
  mStream.Type = 1
  mStream.Open()
  mStream.write(rs.Fields("ref_doc_datos").value)
  */
  var ext = rs.fields('doc_type').value
  var BinaryData = rs.fields('ref_doc_datos').value
  
  DBCloseRecordset(rs)
  
  switch (ext.toLowerCase()) 
  {
  case '.xls' :
    ContentType = 'application/vnd.ms-excel'
    break
  case '.doc' :
     ContentType = 'application/msword'
    break  
  case '.html' :
    ContentType = 'text/html'
    Response.CharSet = "ISO-8859-1"
    break    
  case '.pdf' :
    ContentType = 'application/pdf'
    break
  case '.xml' :
    ContentType = 'text/xml'
    Response.CharSet = "ISO-8859-1"
    break  
  default :
    ContentType = 'text/html' 
    Response.CharSet = "ISO-8859-1"
    ext = '.html'
  } 
  
  
  }
catch(e)
  {
  objError.cargar_msj_error(11002)
  objError.error_script(e)
  objError.mostrar_error()
  }  

  
/********************************************************************/
// Genera el path del archivo temporal
/********************************************************************/

var archivo_tmp = "exp_" + Session.SessionID + ext
var path_temp = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "reportViewer\\tmp\\" + archivo_tmp
var TextData

/***********************************************************/
// Analizar salida en función de salida_tipo y target
/***********************************************************/

%>
<!--#include virtual="meridiano/reportViewer/pvExportar_destino.asp"-->
