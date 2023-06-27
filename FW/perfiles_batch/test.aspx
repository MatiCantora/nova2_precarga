<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutuales" %>

<%@ Import Namespace="Microsoft.Office.Interop" %>

<%
    Dim proceso = nvFW.nvUtiles.obtenerValor("proceso", "")
         
    If proceso <> "" Then
        Dim er As New tError
        Dim path As String
        Dim path_1
        Dim exAPP As Excel.Application = New Excel.Application
        Dim exLibro As Excel.Workbook
        
        Try
            
            Dim MyFile As HttpPostedFile = Request.Files(0)
            Dim nombreExcel As String = MyFile.FileName
           ' Dim ext = nombreExcel.Split(".")
            
			path = System.IO.Path.GetTempFileName() + nombreExcel
            MyFile.SaveAs(path)
            
            Dim bytes = My.Computer.FileSystem.ReadAllBytes(path)
            
            path_1 = System.IO.Path.GetTempFileName() + nombreExcel
            
            My.Computer.FileSystem.WriteAllBytes(path_1, bytes, False)
            
            My.Computer.FileSystem.WriteAllBytes(path_1, bytes, False)
            
            nvFW.nvDBUtiles.DBExecute("insert into zzzzLog (id, log) values (1,' path: " & path & "')")
            nvFW.nvDBUtiles.DBExecute("insert into zzzzLog (id, log) values (2,'path 2: " & path_1 & "')")
            
			
					
            exAPP.Visible = False
            exAPP.DisplayAlerts = False
                
            'exLibro = exAPP.Workbooks.Open(path_1)
            
			exLibro = exAPP.Workbooks.Open(path_1)
            exLibro.Saved = True
            exLibro.SaveCopyAs(path)
            exLibro.SaveAs(path_1, Excel.XlFileFormat.xlOpenXMLWorkbook)
			
			
			
			
			'Dim comp = exLibro.Excel8CompatibilityMode()
			
            
		'	nvFW.nvDBUtiles.DBExecute("insert into zzzzLog (id, log) values (0,' path: "  &  comp.ToString() & "')")   
            
			
			exLibro.SaveAs(path_1)
               
            Dim ohoja As Excel.Worksheet
            ohoja = exLibro.Worksheets(1)
                
            
            
            Dim xlXML As Object = CreateObject("MSXML2.DOMDocument")

            Dim cel1 = ohoja.Range("A1").End(Excel.XlDirection.xlToRight).Address
            Dim cel2 = ohoja.Range("A1").End(Excel.XlDirection.xlDown).Address

            Dim datos = "datos " & cel1 & " : " & cel2 & ". "
                
            er.mensaje = datos
               
            Dim strXML = ohoja.Range(cel1, cel2).Value(Excel.XlRangeValueDataType.xlRangeValueMSPersistXML)
            xlXML.LoadXML(strXML)
            
            Dim xmlDoc = CreateObject("Microsoft.XMLDOM")
           
            xmlDoc.loadXML(strXML)
          
            'cargar el recorset con el xml
            Dim adoRecordset As New ADODB.Recordset
            ' adoRecordset.Open(xlXML)
            ' adoRecordset = nvDBUtiles.DBExecute("select 0 as re")
            
			 nvFW.nvDBUtiles.DBExecute("insert into zzzzLog  (id, log) values (13, 'p')")
			
			adoRecordset.Open(xmlDoc)
			
             nvFW.nvDBUtiles.DBExecute("insert into zzzzLog  (id, log) values (14, 'f')")
			 
            Dim str = "."
            str = adoRecordset.Fields(0).Value
			'str += adoRecordset.Fields(1).Value
			  
			nvFW.nvDBUtiles.DBExecute("insert into zzzzLog (id, log) values (22,'str: " & str & "')")
			
            er.mensaje += str
            er.numError = 4
            nvDBUtiles.DBCloseRecordset(adoRecordset)
            exLibro.Close()
            exAPP.Quit()
      
            
            System.IO.File.Delete(path)
            System.IO.File.Delete(path_1)
          
          
        Catch e As Exception
            nvFW.nvDBUtiles.DBExecute("insert into zzzzLog  (id, log) values (4, 'error general " & e.ToString & "')")
            exLibro.Close()
            exAPP.Quit()
            
            System.IO.File.Delete(path)
            System.IO.File.Delete(path_1)
            er.parse_error_script(e)
            er.titulo = "Error al guardar perfil."
            er.mensaje += e.Message + e.ToString
            er.numError = 55
           
             
        End Try
        
        er.response()
    End If

   
 %>
<html>
<head>
    <title>BPM Batch</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>   
   <% =Me.getHeadInit() %>
    <script type="text/javascript">

        var mywin = nvFW.getMyWindow()
        function window_onload()
        {

        }

        function guardar()
        {
            var file = $('archivo').value

            formDocs.submit()

        }

        function validar_extension()
        {
            var archivo = $('archivo').value
            var Extensiones = [".xls", ".xlsx", ".csv", ".ods", ".xlsb"]
            var strerror = ""

            if (!archivo)
            {
                alert("No ha seleccionado ningún archivo.")
                return true
            }
            else
            {
                extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();
                var permitida = false;
                for (var i = 0; i < Extensiones.length; i++)
                {
                    if (Extensiones[i] == extension)
                    {
                        permitida = true;
                        break;
                    }
                }

                if (!permitida)
                {
                    alert("El archivo no tiene un formato excel válido.")
                    return true
                }
            }

        }

        function hiddenIframe_load()
        {
            try
            {

                var strXML = $('iframeCargar').contentDocument.documentElement
                if (strXML != null)
                {
                    var numError = strXML.children[0].attributes.numError.value
                    var mensaje = strXML.children[0].children[1].innerHTML
                    if (numError != 0)
                    {
                        nvFW.alert(mensaje)
                        return
                    }
                    else
                    {
                        parent.buscar()
                        mywin.close()
                    }
                }
            }
            catch (e) { }
        }
                              
    </script>
</head>
<body onload="return window_onload()" style="overflow: hidden" >
    <div id="divMenu" style="margin: 0px; padding: 0px;">
    </div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu.loadImage('guardar', '/FW/image/icons/guardar.png')
        vMenu.MostrarMenu()
    </script>
    <form id="formDocs" name="formDocs" method="post" enctype="multipart/form-data"  target="iframeCargar">
    <input type="hidden" name="id_transferencia" id="id_transferencia" />
    <table id="datos" class="tb1" style="width: 100%">
        <tr>
            <td>Proceso</td><td><input type="text" id="proceso" name ="proceso"/></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 50px">Archivo:</td>
            <td ><input  style="width:100%" id="archivo" name="archivo" type="file" onchange="validar_extension()"/></td>
        </tr>
    </table>
     <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none"></iframe>
</form>
</body>      
</html>
