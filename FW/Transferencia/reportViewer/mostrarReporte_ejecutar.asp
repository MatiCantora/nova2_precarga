<!--#include virtual="fw/scripts/nv_utiles.asp"-->
<script runat="server" language="vbscript">
 'Cerar la variable gvGroupPath de tipo Array de variant necesaria para la exportación
 dim gvGroupPath 
 gvGroupPath = Array()
</script>
<%

function rpt_change_connection(pvRpt, cn_properties)
  {
  //Recorrer todas las tablas del reporte
  for(var t = 1; t <= pvRpt.Database.Tables.count; t++)   
    {
    //Limpiar la propiedades
    var cn_string = pvRpt.Database.Tables(t).connectBufferString
    pvRpt.Database.Tables(t).connectionProperties.DeleteAll()
    //Cargar las propiedades de la cadena de conexión
    for (var p in cn_properties)
      pvRpt.Database.Tables(t).connectionProperties.add(p, cn_properties[p])
      //oRpt.Database.Tables(t).SetLogOnInfo(Session.Contents('connection_server'), Session.Contents('connection_database'), Session.Contents('connection_uid'), Session.Contents('connection_pwd')) 
    }

  var oSubReport
  var oSections = pvRpt.Sections
  //Recorrer todas las secciones del reporte
  for(var s = 1;s <= pvRpt.Sections.count; s++)
    {
    //Recorrer todos los objetos de la seccion
    for(var o = 1; o <= pvRpt.Sections(s).ReportObjects.count; o++)
      {
      //Si el objeto es un subreporte
      if (pvRpt.Sections(s).ReportObjects(o).Kind == 5) //crSubreportObject
        {
        //recuperar el objeto reporte
        oSubReport = pvRpt.Sections(s).ReportObjects(o).OpenSubreport()
        //para todas las tablas dentro del subreporte
        /*
        for(var t = 1; t <= oSubReport.Database.Tables.count; t++)   
          {
          //Limpiar la propiedades
          oSubReport.Database.Tables(t).connectionProperties.DeleteAll()
          //Cargar las propiedades de la cadena de conexión
          for (var p in cn_properties)
            oSubReport.Database.Tables(t).connectionProperties.add(p, cn_properties[p])
          //oSubReport.Database.Tables(t).SetLogOnInfo(Session.Contents('connection_server'), Session.Contents('connection_database'), Session.Contents('connection_uid'), Session.Contents('connection_pwd')) 
          }
        */  
        rpt_change_connection(oSubReport, cn_properties)  
        }
      }
    }
  }
  

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

function mostrarReporte_ejecutar()
  {
//Ajustar valores NULL
//Si vienen en null inicializarlos a ''
 
 BinaryData = undefined
 TextData = undefined

if (report_name == null)  
  report_name = ''

if (path_reporte == null)  
  path_reporte = ''

if (VistaGuardada == null)
  VistaGuardada = ''
  

    /****************************************************************/
    // Controla y ajusta el valor de ContentType para que sea válido
    /* Solamente los que tienen (*) son entradas válidas, sino lo manda como PDF
    Valores de FormatType de  CR11
    00 = crEFTNoFormat
    01 = crEFTCrystalReport
    02 = crEFTDataInterChange
    03 = crEFTRecordStyle
    05 = crEFTCommaSeparatedValues
    06 = crEFTTabSeparatedValues
    07 = crEFTCharSeparatedValues
    08 = crEFTText
    09 = crEFTTabSeparatedText
    14 = crEFTWordForWindows (*) DOC
    23 = crEFTODBC
    24 = crEFTHTML32Standard
    25 = crEFTExplorer32Extend
    31 = crEFTPortableDocFormat (*) PDF
    32 = crEFTHTML40 (*) HTML
    34 = crEFTReportDefinition
    35 = crEFTExactRitchText
    36 = crEFTExcel97 (*) XLS
    37 = crEFTXML
    38 = crEFTExcelDataOnly
    39 = crEFTEditableRitchText
    /*
    /****************************************************************/

/*
codigos ALE
29 = Excel
*/
var FormatType // Se utiliza como parametro para la exportación de CR
var ext // Extención del archivo temporal

if (ContentType == null)
  ContentType = ''

var content_disposition = 'attachment'  
switch (ContentType.toLowerCase()) 
  {
  case 'application/vnd.ms-excel' :
    FormatType = 36 //29
    ext = '.xls'
    break
  case 'application/msword' :
    FormatType = 14
    ext = '.doc'
    break  
  case 'text/html' :
    FormatType = 32
    ext = '.html'
    content_disposition = 'inline'  
    break    
  case 'application/pdf' :
    FormatType = 31
    ext = '.pdf'
    content_disposition = 'inline'  
    break
  default :
    ContentType = 'application/pdf' 
    FormatType = 31
    ext = '.pdf'
    content_disposition = 'inline'  
  }   
  
    
if (target == null)
  target = ''

if (salida_tipo == null || salida_tipo == '')
  salida_tipo= 'adjunto'  
 
/*compatililidad con las llamadas del ALE*/
if (salida_tipo == 'excel')   
  {
  ContentType = 'application/vnd.ms-excel'
  salida_tipo = 'adjunto'
  }


/*****************************************************/
// Variable de error
/*****************************************************/

objError = new tError();
objError.salida_tipo = salida_tipo
objError.debug_src = 'mostrarReporte.asp'


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
    objError.cargar_msj_error(11002)
    return objError.mostrar_error()
  }

/********************************************************************/
//Abre el filtro para controlarlo y para recuperar el valor de vista
/********************************************************************/
var objfiltroXML = Server.CreateObject("Microsoft.XMLDOM")
if (!objfiltroXML.loadXML(filtroXML))
  {
  objError.cargar_msj_error(11001)
  objError.error_xml(objfiltroXML)
  objError.debug_desc +=  "\n" + filtroXML
  return objError.mostrar_error()  
  }

if (objfiltroXML.selectSingleNode("criterio/select/@vista") != null)
  vista = objfiltroXML.selectSingleNode("criterio/select/@vista").nodeValue
  
if (objfiltroXML.selectSingleNode("criterio/procedure/@vista") != null)
  vista = objfiltroXML.selectSingleNode("criterio/procedure/@vista").nodeValue


/*******************************************************************/
//Recuperar path de la plantilla
//Si xsl_name tiene valor utilizarlo, sino path_xsl
//Controlar que el archivo existe sino devuelve error
//Abrir el XSL si no se puede devuelve error
//Probar en la carpeta de la aplicacion y despues en meridiano
/*******************************************************************/

var path_rel = new Array()
path_rel[0] = Session.Contents("app_path_rel")
path_rel[1] = 'FW'
path_rel[2] = 'meridiano'

var path_archivo
report_name = report_name.replace("/", "\\")
path_reporte = path_reporte.replace("/", "\\")
for(var rel in path_rel ) 
  {
  var fso = Server.CreateObject("Scripting.FileSystemObject")
  if(report_name.length > 0)
      path_archivo = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + path_rel[rel] + "\\report\\" + vista + '\\' + report_name
  else
    if (!fso.FileExists(path_reporte))
        path_archivo = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + path_rel[rel] + "\\" + path_reporte  
  

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
path_reporte = path_archivo

if (!fso.FileExists(path_reporte))
  {
  objError.cargar_msj_error(11005)
  objError.debug_desc = path_reporte
  return objError.mostrar_error()
  }   


/*********************************************************************/
//Recuperar datos
//var strSQL = XMLtoSQL(filtroXML, filtroWhere)
//Procesa el filtroXML y vevuelve un recordset con los datos resultado.
//Si no devuelve el recordset da error
/*********************************************************************/
try 
  {
  var time_start = new Date()  
  var rs = XMLtoRecordset(filtroXML, filtroWhere)
  var time_end = new Date()
  try{nvLog_addEvent("dbg_mostrarReporte", nvLog_getTrack() + ";" + strDate(time_start) + ";" + strDate(time_end) + ";" + rs.Source)} catch(e_nvLog){}
   
  if (objError.numError != 0)
    return objError.mostrar_error()
  objError.debug_src = 'mostrarReporte.asp'
  if (rs.eof == null)
    {
    //Falta info del error
    objError.cargar_msj_error(11002)
    return objError.mostrar_error() 
    }
  }
catch(e)
  {
  objError.cargar_msj_error(11002)
  objError.error_script(e)
  return objError.mostrar_error()
  }  

/********************************************************************/
// Abrir y cargar el reporte
// Crear lo objetos necesarios para mostrar el reporte
/********************************************************************/
//Application
//Revisar creación condicional
try
{
 var oApp = Server.CreateObject("CrystalRuntime.Application.11")
}
catch(e)
{
  objError.cargar_msj_error(12004)
  objError.error_script(e)
  return objError.mostrar_error()
}

/*
if (typeof(Session("oApp")) != 'object')
  {
  var oApp = Server.CreateObject("CrystalRuntime.Application.11")
  Session("oApp") = oApp
  }
else
  oApp = Session("oApp")
*/ 
try
  {
  //var oRpt = Server.CreateObject("CrystalRuntime.Report.11")
  var oRpt = oApp.OpenReport(path_reporte) //var oRpt = oApp.OpenReport(path_reporte, 1) //genera ~*.tmp

  }
catch(e)
  {
  objError.cargar_msj_error(12004)
  objError.error_script(e)
  return objError.mostrar_error()
  }  

oRpt.MorePrintEngineErrorMessages = false
oRpt.EnableParameterPrompting = false
//oRpt.DiscardSavedData
  
//Set oADOConnection = objFC.cn
//dim oADORecordset = Server.CreateObject("ADODB.Recordset")
//Set oADORecordset = oADOConnection.Execute(strSQL)
//Set oRptTable = session("oRpt").Database.Tables.Item(1)
//'Once we have a reference we can then set the tables datasource to be the recorset object.
//oRptTable.SetDataSource oADORecordset, 3

/******************************************/
//  Cambiar conexiones
/******************************************/

/*
Session.Contents('connection_server') = "orion"
Session.Contents('connection_database') = "nuecuad"
Session.Contents('connection_uid') = "cuad"
Session.Contents('connection_pwd') = "cuad_orion"

Session.Contents('connection_server') = null
Session.Contents('connection_database') = null
Session.Contents('connection_uid') = null
Session.Contents('connection_pwd') = null
*/

/*
Session.Contents('connection_server') = "sis"
Session.Contents('connection_database') = "lausana"
Session.Contents('connection_uid') = "userdtsx"
Session.Contents('connection_pwd') = "userdtsx"
*/

/*********************************************************************************************/
//Cambiar la conexión de los reportes y subreportes por la cadena de conexión de la aplicación
//Como los boludos de Crystal no permiten cambiar la cadena de conexión y administran una distinta para cada tabla
//Y ademas no tienen en el objeto una colección de subreportes hay que hacer todo a pata
/*********************************************************************************************/
//1) Separar la cadena de conexión en sus propiedades

var properties = Session.Contents('connection_string').split(";")
var cn_properties = new Array()
for (var a = 0; a < properties.length; a++)
  if (properties[a].split("=")[1] != undefined)
    cn_properties[properties[a].split("=")[0]] = properties[a].split("=")[1]

//rpt_change_connection(oRpt, cn_properties)  

var oADORecordset = Server.CreateObject("ADODB.Recordset")
oADORecordset = rs

//var oRptTable = Server.CreateObject("CrystalRuntime.DatabaseTable.11")

var oRptTable = oRpt.Database.Tables.Item(1)
oRptTable.SetDataSource(oADORecordset, 3)

try
  {
  oRpt.ReadRecords()
  }
catch(e)  
  {
  objError.cargar_msj_error(12005)
  objError.error_script(e)
  return objError.mostrar_error()
  }


/****************************************************************************/
// Si salida_tipo
// Igual a "crystal" entonces el resultado es direccionado al visor de Crystal Report
// Igual a "estado" devuelve un XML con el resultado de la acción
// Igual a "adjunto" devuelve en el flujo el resultado (defeceto)
/*****************************************************************************/

//Si es crystal y ademas es IE
if (salida_tipo.toLowerCase() == "crystal" )
  {
  //Cargar las variables de sesion
  Session("oApp") = oApp
  Session("oRpt") = oRpt
  Session("oPageEngine") = oRpt.PageEngine
  %>
  <!-- #include file="SmartViewerActiveX.asp" -->
  <%
  }
else  
  {
  var CrystalExportOptions
  var mStream
  var path_destino
  
  try
    {
    
    var archivo_tmp = "rpt_" + Session.SessionID + ext
    var path_temp = Request.ServerVariables("APPL_PHYSICAL_PATH").Item + "fw\\reportViewer\\tmp\\" + archivo_tmp  

    /********************************************/
    // Parametros de exportación CR
    /********************************************/
    var CrystalExportOptions = oRpt.ExportOptions  
    oRpt.DisplayProgressDialog = false     
    CrystalExportOptions.FormatType = FormatType //CREFTPORTABLEDOCFORMAT
    //CrystalExportOptions.PDFExportAllPages = true
    //CrystalExportOptions.DiskFileName = path_temp
    CrystalExportOptions.DestinationType = 1 //CREDTDISKFILE
    
    /****************************/
    // Exportar
    /****************************/
    var goPageGenerator = oRpt.PageEngine.CreatePageGenerator(gvGroupPath)
    BinaryData = goPageGenerator.Export(8209)

    oPageEngine = null
    oRpt = null
    oApp = null
    oRptTable = null
    goPageGenerator = null
    CrystalExportOptions = null
    
    DBCloseRecordset(rs)
    try{oADORecordset = null}catch(eoADORecordset){}
    
    /*
    var mStream = Server.CreateObject("ADODB.Stream")
    mStream.Mode = 3 //adModeReadWrite
    mStream.Type = 1
    mStream.Open()
    mStream.Write(BinaryData)
    mStream.SaveToFile(path_temp)
    mStream.Close()
    */
    /*
    var CrystalExportOptions = oRpt.ExportOptions
    CrystalExportOptions.DestinationType = 1 //DiskFile
    CrystalExportOptions.DiskFileName = path_temp
    CrystalExportOptions.FormatType = FormatType 

    //Exportar / Crear el archivo
    debugger
    oRpt.Export(false)
    */
    }
  catch(e)
    {
    objError.cargar_msj_error(12006)
    objError.error_script(e)
    return objError.mostrar_error()
    }  

  /***********************************************************/
  // Analizar salida en función de salida_tipo y target
  /***********************************************************/
  /***********************************************************/
  // Analizar salida en función de salida_tipo y target
  /***********************************************************/
  return exportarDestino()
  } 
}//fin mostrarReporte_ejecutar
%>
