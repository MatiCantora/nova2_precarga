<%

/********************************************************************/
// Genera el path del archivo temporal
/********************************************************************/
var archivo_tmp
var path_temp

/***********************************************************/
// Analizar salida en función de salida_tipo y target
/***********************************************************/
var BinaryData
var TextData
var rptError

function RSXMLtoExcelRs(rs,export_exeption,name)
  {
  
  var lfilas = export_exeption == "RSXMLtoExcel" ? 65535 : 1048575 //Cantidad de filas por hoja / mirar version de excel
  var ext_modelo = export_exeption == "RSXMLtoExcel" ? ".xls" : ".xlsx"

  var c
  var registros
  var oColumna
  var columna
  var n_hoja
  var fila
  var NOD
  var registro
  var hoja_nueva = true
  try
    {
    
    rptError.numError = '8'
    rptError.mensaje = 'new ActiveXObject("Excel.Application")'
    var exAPP = new ActiveXObject("Excel.Application");
   
    var exLibro // Excel.Workbook
    var exHoja // Excel.Worksheet
  
    var path_modelo = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\modelo_excel" + ext_modelo
    
    rptError.numError = '9'
    rptError.mensaje = 'exAPP.Workbooks.Open(path_modelo)'
    var exLibro = exAPP.Workbooks.Add //(path_modelo)
    
    exAPP.Visible = false
    exAPP.DisplayAlerts = false
    
    rptError.numError = '10'
    rptError.mensaje = 'exLibro.Worksheets(1)'
    exHoja = exLibro.Worksheets(1)
    exHoja.name = name == undefined ? 'Hoja' : name
    
    for(var c=0; c < rs.fields.count; c++)
      {
      exHoja.Cells(1, c + 1) = rs.fields.item(c).name
      if (rs.fields.item(c).type == 7 || rs.fields.item(c).type == 133 || rs.fields.item(c).type == 134 || rs.fields.item(c).type == 135)
        {
        exAPP.Columns(c + 1).Select()
        exAPP.Selection.NumberFormat = "dd/mm/yyyy;@"
        }
      }
    
    var n_hoja = 1
    var AbsoluteFila = 0
    while(!rs.eof)
      {
    
      fila = (AbsoluteFila % (lfilas)) == 0 ? 2 : fila= fila + 1
    
      for(var c=0; c < rs.fields.count; c++)
        {
        if (rs.fields.item(c).value != null) //revisar
          {
          //NOD = null
          try
            {
            switch (rs.fields.item(c).type)
              {
              case 7://"dateTime":
                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                break
              case 133://"dateTime":
                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                break
              case 134://"dateTime":
                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                break
              case 135://"dateTime":
                try {exHoja.Cells(fila, c + 1) = rs.fields.item(c).value} catch (e){exHoja.Cells(fila, c + 1) = "'" + FechaToSTR((new Date("" + rs.fields.item(c).value)))}
                break      
              case 200: // "string":
                exHoja.Cells(fila, c + 1) = "'" + rs.fields.item(c).value
                break
              case 201: // "string":
                exHoja.Cells(fila, c + 1) = "'" + rs.fields.item(c).value
                break
              case 202: // "string":
                exHoja.Cells(fila, c + 1) = "'" + rs.fields.item(c).value
                break    
              default:
                exHoja.Cells(fila, c + 1) = rs.fields.item(c).value
              }
            }
          catch(e)    
            {
            exHoja.Cells(fila, c + 1) = 'ERROR'
            }
          }  
        else
          {
          exHoja.Cells(fila, c + 1) = "NULL"
          }
        }//for columnas
      
      //aumento en uno para el proximo registro
      AbsoluteFila++
        
      if ((AbsoluteFila % (lfilas)) == 0 && (AbsoluteFila < rs.recordcount))  
        { 
        n_hoja++ 
        fila = 1
        exHoja = exLibro.Worksheets.Add(null, exHoja)
        //Cargar celdas con los nombres de campos
        for(var c=0; c < rs.fields.count; c++)
          {
          exHoja.Cells(1, c + 1) = rs.fields.item(c).name
          if (rs.fields.item(c).type == 7 || rs.fields.item(c).type == 133 || rs.fields.item(c).type == 134 || rs.fields.item(c).type == 135)
            {
            exAPP.Columns(c + 1).Select()
            exAPP.Selection.NumberFormat = "dd/mm/yyyy;@"
            }
          }
        }
        rs.movenext()
      }
    
      for (c = 1; c <= exLibro.Worksheets.count; c++)
      {
          exHoja = exLibro.Worksheets(c)
          exHoja.name = exHoja.name == name ? name : (exHoja.name + c)
          exHoja.Select()
          exAPP.Rows("1:1").Select()
          exAPP.Selection.Font.Bold = true
      
          exAPP.Selection.HorizontalAlignment = -4108 //xlCenter
          exAPP.Selection.VerticalAlignment = -4107 //xlBottom
          exAPP.Selection.WrapText = false
          exAPP.Selection.Orientation = 0
          exAPP.Selection.AddIndent = false
          exAPP.Selection.IndentLevel = 0
          exAPP.Selection.ShrinkToFit = false
          exAPP.Selection.ReadingOrder = -5002 //xlContext
          exAPP.Selection.MergeCells = false
      
          exAPP.Rows.Select()
          exAPP.Selection.RowHeight = 12.75
          exHoja.Cells.Select()
          exAPP.Cells.EntireColumn.AutoFit()
        }
     
    c = exLibro.Worksheets.count
    while(n_hoja < c)
     {
      exLibro.Worksheets(c).Delete()
      c--
     }

    exAPP.Worksheets(1).Select()
 
    rptError.numError = '11'
    rptError.mensaje = 'Server.CreateObject("Scripting.FileSystemObject")'
    var fso = Server.CreateObject("Scripting.FileSystemObject")
    
    var path_tmp_i = 0
    var path_tmp  = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\tmp\\tmp_exportar_excel" + path_tmp_i + ext_modelo
    while (fso.FileExists(path_tmp))
      {
       path_tmp_i++
       path_tmp  = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\transferencia\\reportViewer\\tmp\\tmp_exportar_excel" + path_tmp_i + ext_modelo
      }
      
    rptError.numError = '12'
    rptError.mensaje = 'exLibro.SaveAs(path_tmp)'
    
   var save_as = 51
   if(ext_modelo == '.xls')
      save_as = 56

    exLibro.SaveAs(path_tmp,save_as) 
    
    for (c = 1; c <= exAPP.WorkBooks.count; c++)
      exAPP.WorkBooks(c).close(true)
    //exLibro.close(true)
    exAPP.quit()
    delete exAPP

    return path_tmp  //Devuelve el path del archivo
    }
  catch(e)  
    {
     if (exAPP != undefined)
      {
      for (c = 1; c <= exAPP.WorkBooks.count; c++)
         exAPP.WorkBooks(c).close(false)
      exAPP.quit()
      delete exAPP
      }
      
     //Eliminar el archivo si fue creado
     if (path_tmp != undefined)
      {
      var fso = Server.CreateObject("Scripting.FileSystemObject")
      if (fso.FileExists(path_tmp))
        fso.DeleteFile(path_tmp,true);
      }
    
     rptError.cargar_msj_error(11006)
     rptError.error_script(e)
     return rptError.mostrar_error()
    }
  
  }


function exportarReporte_ejecutar()
  {
//Ajustar valores NULL
//Si vienen en null inicializarlos a ''
 
 BinaryData = undefined
 TextData = undefined
 
if (id_exp_origen == '')  
  id_exp_origen = 0

if (xsl_name == null)  
  xsl_name = ''

if (path_xsl == null)  
  path_xsl = ''
  
if (filtroWhere == null)  
  filtroWhere = ''  

if (VistaGuardada == null)
  VistaGuardada = ''
  
if (target == null)
  target = ''
    
if (salida_tipo == null || salida_tipo == '')
  salida_tipo= 'adjunto'    

if (filename == null)
  filename = ''

var ext
if (ContentType == null)
  ContentType = ''

//Solamente si es 'true'
mantener_origen = mantener_origen.toString().toLowerCase() == 'true'

var content_disposition = 'attachment'
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
    content_disposition = 'inline'   
    break    
  case 'application/pdf' :
    ext = '.pdf'
    content_disposition = 'inline'   
    break
  case 'text/xml' :
    ext = '.xml'
    break  
  default :
    ContentType = 'text/html' 
    ext = '.html'
    content_disposition = 'inline'   
  } 
  

/*****************************************************/
// Variable de error
/*****************************************************/
rptError = new tError();
rptError.salida_tipo = salida_tipo
rptError.debug_src = 'ExportarReporte.asp'
    

//Recuperar parametros adicionales
var objParametros = ''
if (parametros != '')
  {
  objParametros = Server.CreateObject("Microsoft.XMLDOM")
  if (!objParametros.loadXML(parametros))
    {
    rptError.cargar_msj_error(11001)
    rptError.error_xml(objfiltroXML)
    rptError.debug_desc += "\n" + filtroXML
    return rptError.mostrar_error()  
    }  
  }  

/******************************************************************************/
//Mantener origen
//Guarda en la base de datos los parametros de entrada dandole un identificador
/******************************************************************************/

if (mantener_origen)
  {
  if (id_exp_origen <= 0)
    {
    var strSQL = 'exec lausana..exp_origen_add'
    strSQL += "'" + replace(VistaGuardada, "'", "''") + "', '" +  replace(filtroXML, "'", "''") + "',"
    strSQL += "'" +  replace(filtroWhere, "'", "''") + "', '" +  replace(xsl_name, "'", "''") + "', '" +  replace(path_xsl, "'", "''") + "', '" +  replace(ContentType, "'", "''") + "', '" +  replace(target, "'", "''") + "', '" +  replace(salida_tipo, "'", "''") + "', '" + replace(parametros, "'", "''") + "'"
    var rsOrigen = DBOpenRecordset(strSQL)
    id_exp_origen = rsOrigen.fields('id_exp_origen').value
    }
  else
    {
    var strSQL = 'update exp_origen_log set VistaGuardada = '
    strSQL += "'" + replace(VistaGuardada, "'", "''") + "', filtroXML = '" +  replace(filtroXML, "'", "''") + "',"
    strSQL += " filtroWhere = '" +  replace(filtroWhere, "'", "''") + "', xsl_name = '" +  replace(xsl_name, "'", "''") + "', path_xsl = '" +  replace(path_xsl, "'", "''") + "', ContentType = '" +  replace(ContentType, "'", "''") + "', target = '" +  replace(target, "'", "''") + "', salida_tipo = '" +  replace(salida_tipo, "'", "''") + "', parametros = '" + replace(parametros, "'", "''") + "'"
    strSQL += " where id_exp_origen = " + id_exp_origen
    DBExecute(strSQL)
    }  
  }


/*********************************************************************/
// Si VistaGuardada tiene valor utilizarlo, sino paresear el filtroXML
/*********************************************************************/
if (VistaGuardada.length > 0)
  {
  var rs = DBExecute("select * from WRP_Config where vista = '" + VistaGuardada + "'")
  filtroXML = rs.Fields('strXML').Value
  }

//error filtroXML
if (filtroXML == null)
  {
    //Falta info del error
    rptError.cargar_msj_error(11002)
    return rptError.mostrar_error()
  }

/********************************************************************/
//Abre el filtro para controlarlo y para recuperar el valor de vista
/********************************************************************/
var objfiltroXML = Server.CreateObject("Microsoft.XMLDOM")
if (!objfiltroXML.loadXML(filtroXML))
  {
  rptError.cargar_msj_error(11001)
  rptError.error_xml(objfiltroXML)
  rptError.debug_desc += "\n" + filtroXML
  return rptError.mostrar_error()  
  }

if (objfiltroXML.selectSingleNode("criterio/select/@vista") != null)
  vista = objfiltroXML.selectSingleNode("criterio/select/@vista").nodeValue
  
if (objfiltroXML.selectSingleNode("criterio/procedure/@vista") != null)
  vista = objfiltroXML.selectSingleNode("criterio/procedure/@vista").nodeValue


var name     
if (objfiltroXML.selectSingleNode("criterio/select/@name") != null)
  name = objfiltroXML.selectSingleNode("criterio/select/@name").nodeValue

if (objfiltroXML.selectSingleNode("criterio/procedure/@name") != null)
  name = objfiltroXML.selectSingleNode("criterio/procedure/@name").nodeValue


/*******************************************************************/
//Recuperar path de la plantilla
//Si xsl_name tiene valor utilizarlo, sino path_xsl
//Controlar que el archivo existe sino devuelve error
//Abrir el XSL si no se puede devuelve error
//Probar en la carpeta de la aplicacion y despues en meridiano
/*******************************************************************/

var path_rel = new Array()
path_rel[0] = nvSession.getContents("app_path_rel")
path_rel[1] = "FW"
//path_rel[2] = 'meridiano'

var path_archivo
if ( export_exeption.indexOf("RSXMLtoExcel") == -1)
  {
  xsl_name = xsl_name.replace("/", "\\")
  path_xsl = path_xsl.replace("/", "\\")
  for(var rel in path_rel ) 
    {
    var fso = Server.CreateObject("Scripting.FileSystemObject")
    if(xsl_name.length > 0)
        path_archivo = Request.ServerVariables("APPL_PHYSICAL_PATH").Item  + "App_Data\\" + path_rel[rel] + "\\report\\" + vista + '\\' + xsl_name
    else
      if (!fso.FileExists(path_xsl))
          path_archivo = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "App_Data\\" + path_rel[rel] + "\\" + path_xsl  
  

    //controla si existe en copia
    if (!fso.FileExists(path_archivo))
      {
      var path_archivo2 = path_archivo.replace("\\report\\", "\\report_copia\\")
      if (fso.FileExists(path_archivo2))
        fso.MoveFile(path_archivo2, path_archivo)
      }
    if (fso.FileExists(path_archivo)) 
      break
    }

  path_xsl = path_archivo
  if (!fso.FileExists(path_xsl))
    {
    rptError.cargar_msj_error(11005)
    rptError.debug_desc = path_xsl
    return rptError.mostrar_error()
    }   

  var XSL = Server.CreateObject("Microsoft.XMLDOM")
  if (!XSL.load(path_xsl))
    {
    rptError.cargar_msj_error(11003)
    rptError.error_xml(XSL)
    rptError.debug_desc += "\n" + path_xsl
    return rptError.mostrar_error()  
    }
  }


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
  var arParam = new Array()
  
  var rs = XMLtoRecordset(filtroXML, filtroWhere, arParam)

  if (objError.numError != 0)
    rptError.mostrar_error()
  
  rptError.debug_src = 'ExportarReporte.asp'
  if (rs == null)
    {
    //Falta info del error
    rptError.cargar_msj_error(11002)
    return rptError.mostrar_error() 
    }

  if (rs.eof == null)
    {
    //Falta info del error
    rptError.cargar_msj_error(11002)
    return rptError.mostrar_error() 
    }
  }
catch(e)
  {
  rptError.cargar_msj_error(11002)
  rptError.error_script(e)
  return rptError.mostrar_error()
  }     

if(export_exeption.indexOf("RSXMLtoExcel") > -1)
  {
  try
    {
    path_temp = RSXMLtoExcelRs(rs,export_exeption,name)
    DBCloseRecordset(rs)
    }
  catch(e)
    {
    rptError.cargar_msj_error(11002)
    rptError.error_script(e)
    return rptError.mostrar_error()
    }
  }  
else
  {    
  try
    {
    var XML = Server.CreateObject("Microsoft.XMLDOM")
    // rs.Save(XML, adPersistXML)
    // XML.loadXML("<?xml version='1.0' encoding='ISO-8859-1'?><xml></xml>")
    //Si es un recordset comun o un campo con el XML
    if (rs.Fields(0).name != 'forxml_data' )
      {
      rs.Save(XML, 1)
      }
    else
      XML.loadXML(rs.Fields("forxml_data").value)

   /*******************************************/
    // Agregar name al XML
    /*******************************************/
    if(name)
     {
      var att = XML.createAttribute("name")
          att.nodeValue = name
      XML.childNodes(0).setAttributeNode(att)  
     }
       
    /*******************************************/
    // Agregar parametros al XML
    /*******************************************/
    var NOD = XML.createElement("params")
    var att
    for (var p in arParam)  
      {
      att = XML.createAttribute(p)
      att.nodeValue = arParam[p]
      NOD.setAttributeNode(att)
      }
    XML.childNodes(0).appendChild(NOD)  
    //Si no se cachea entonces cerrarlo
    //if (arParam['cacheControl'] != 'Session')
      DBCloseRecordset(rs)
    }
  catch(e)
    {
    rptError.cargar_msj_error(11002)
    rptError.error_script(e)
    return rptError.mostrar_error()
    }  

    /*********************************************************************/
    //Transformar XML
    //Transforma el XML con la plantilla XSL
    //Si no puede devuelve error
    /*********************************************************************/
    try
      {
      
      //Anexar información complementaria
      if (id_exp_origen > 0)
        {
        var nod_origen = XML.createElement("id_exp_origen")
        nod_origen.text = id_exp_origen
        XML.childNodes(0).appendChild(nod_origen)
        var nod_mantener_origen = XML.createElement("mantener_origen")
        nod_mantener_origen.text = mantener_origen
        XML.childNodes(0).appendChild(nod_mantener_origen)
        }

      if (typeof(objParametros) == 'object')
        {
        var nod_parametros = objParametros.selectSingleNode('/parametros')
        XML.childNodes(0).appendChild(nod_parametros)
        }
        
      TextData = XML.transformNode(XSL)
      
      //Primero cambia la definición de codigo de caracteres 
      TextData = TextData.replace('<META http-equiv="Content-Type" content="text/html; charset=UTF-16">', "")
      TextData = TextData.replace('<?xml version="1.0" encoding="UTF-16"?>', '<?xml version="1.0" encoding="iso-8859-1"?>')
      }
    catch(e)
      {
      rptError.cargar_msj_error(11003)
      rptError.error_script(e)
      return rptError.mostrar_error() 
      }
} 

/********************************************************************/
// Genera el path del archivo temporal
/********************************************************************/

//archivo_tmp = "exp_" + Session.SessionID + ext
//path_temp = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "\FW\\reportViewer\\tmp\\" + archivo_tmp

//archivo_tmp = "exp_" + Session.SessionID + ext
//path_temp = path_temp == '' ? Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "FW\\reportViewer\\tmp\\" + archivo_tmp : path_temp

/***********************************************************/
// Analizar salida en función de salida_tipo y target
/***********************************************************/
return exportarDestino()

}//fin exportarReporte_ejecutar
%>


