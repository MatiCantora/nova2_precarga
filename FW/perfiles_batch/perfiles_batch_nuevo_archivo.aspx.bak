<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutuales" %>

<%@ Import Namespace="Microsoft.Office.Interop" %>

<%
    Dim id_batch = nvFW.nvUtiles.obtenerValor("id_batch", 0)
    Dim check = nvFW.nvUtiles.obtenerValor("check", "")
    Dim hojaExcel = nvFW.nvUtiles.obtenerValor("hojaExcel", "Hoja1")
    Dim accion = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim proceso = nvFW.nvUtiles.obtenerValor("proceso", "")
    Dim id_transferencia = nvFW.nvUtiles.obtenerValor("id_transferencia", "")
    
    If accion = "guardar" Then
        Dim er As New tError
        Try      
             
            Dim listHojas As String = ""
            Dim MyFile As HttpPostedFile = Request.Files(0)
            Dim nombreExcel As String = MyFile.FileName
            Dim path As String = System.IO.Path.GetTempFileName() + ".xls"
            Dim rs_excel As ADODB.Recordset = New ADODB.Recordset()
            Dim excel As New nvFW.tExcel
            
            MyFile.SaveAs(path)
              
            Dim bytes = My.Computer.FileSystem.ReadAllBytes(path)
            
            Dim primerafila As Boolean = False
            If check = "on" Then
                primerafila = True
            End If
            
            'Manejo del excel
            Try
                excel.filename = path
                er = excel.listaHojasExcel()
                If er.numError <> 0 Then
                    System.IO.File.Delete(path)
                    er.response()
                End If
                
                listHojas = er.params("listHojas")
                rs_excel = excel.ExcelLeerDatos3(primerafila)
                If rs_excel Is Nothing Then
                    er.mensaje = "Error al leer el archivo"
                    er.numError = -1
                    er.response()
                End If
            Catch ex As Exception
                nvDBUtiles.DBCloseRecordset(rs_excel)
                er.parse_error_script(ex)
                er.titulo = "Error al guardar perfil."
                er.mensaje = ex.Message
                er.response()
            End Try
            
            System.IO.File.Delete(path)
           
            Dim parametros = "<?xml version='1.0' encoding='ISO-8859-1'?><parametros>"
            For i As Integer = 0 To rs_excel.Fields.Count - 1
                parametros += "<parametro id='" + rs_excel.Fields(i).Name + "' valor=''></parametro>"
            Next
            parametros += "</parametros>"
            
            'cerrar conexion 
            nvDBUtiles.DBCloseRecordset(rs_excel)
            
            Dim strXML As String = "<bpm_batch id_bpm='" + id_batch + "' excel_name='" + nombreExcel + "' primera_fila='" + primerafila.ToString + "' lista_hojas_excel='" + listHojas + "' hoja_selecc='" + hojaExcel + "'></bpm_batch>"
              
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("perfiles_batch_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "MA")
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            cmd.addParameter("@datos_excel", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, , bytes)
            cmd.addParameter("@parametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , parametros)

            Dim rs As ADODB.Recordset = cmd.Execute()
            er = New nvFW.tError(rs)
            er.params("id") = rs.Fields("id").Value
            nvDBUtiles.DBCloseRecordset(rs)

        Catch e As Exception
            er.parse_error_script(e)
            er.titulo = "Error al guardar perfil."
            er.mensaje = e.Message
            
        End Try
        
        er.response()
    End If

    Me.contents("filtroBatch") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPerfiles_batch'><campos>*</campos><orden></orden></select></criterio>")
   
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
        var id_batch = '<%= id_batch %>'
       
        function window_onload() {
            var rs = new tRS()
            rs.open(nvFW.pageContents.filtroBatch, '', "<id_bpm_batch type='igual'>" + id_batch + "</id_bpm_batch>")       
            
            if(!rs.eof()){
                $('proceso').value = rs.getdata('bpm_batch')
                $('transferencia').value = rs.getdata('id_transferencia') + " - " + rs.getdata('nombre_transf')
                $('id_transferencia').value = rs.getdata('id_transferencia')
                                  
                if(rs.getdata('primera_fila_excel') == 'True')
                    $('check').checked = 'checked'  
            }       
        }

        function guardar(){
            if (validar_extension()) return

             $('accion').value = 'guardar'
             nvFW.bloqueo_activar($$('body')[0], "bloqueo")
             formDocs.submit()
         }

         function validar_extension()  {
             var archivo = $('archivo').value
             var Extensiones = [".xls", ".xlsx", ".csv", ".ods", ".xlsb"]
             var strerror = ""

             if (!archivo) {
                 alert("No ha seleccionado ningún archivo.")
                 return true
             }
             else{
                 extension = (archivo.substring(archivo.lastIndexOf("."))).toLowerCase();
                 var permitida = false;
                 for (var i = 0; i < Extensiones.length; i++) {
                     if (Extensiones[i] == extension){
                         permitida = true;
                         break;
                     }
                 }

                 if (!permitida)  {
                     alert("El archivo no tiene un formato excel válido.")
                     return true
                 }
             }
         }

         function hiddenIframe_load() {
             try{       
                 nvFW.bloqueo_desactivar($$('body')[0], "bloqueo")

                 var strXML = $('iframeCargar').contentDocument.documentElement
                 if(strXML != null){
                     var numError = strXML.children[0].attributes.numError.value
                     var mensaje = strXML.children[0].children[1].innerHTML
                     if (numError != 0){        
                         nvFW.alert(mensaje)
                         return
                     }
                     else{
                         parent.cargarBatch(id_batch)
                         mywin.close()
                     }
                 }
             }
             catch (e) { }
         }
                                 
    </script>
</head>
<body onload="return window_onload()" style="overflow: hidden">
    <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
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
    <form id="formDocs" name="formDocs" method="post" enctype="multipart/form-data" target="iframeCargar">
    <input type="hidden" name="id_batch" id="id_batch" value="<%= id_batch %>"/>
    <input type="hidden" name="accion" id="accion" />
    <input type="hidden" name="id_transferencia" id="id_transferencia" />
    <table id="datos" class="tb1" style="width: 100%">
        <tr>
            <td style="width: 50px" class="Tit1">Descipción:</td>
            <td><input  style="width:100%"  id="proceso" name="proceso" type="text" readonly="readonly" disabled ="disabled"/></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 50px">Transferencia:</td>
            <td><input  style="width:100%"  id="transferencia" name="transferencia" type="text" readonly="readonly" disabled ="disabled" /></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 50px">Archivo:</td>
            <td ><input  style="width:100%" id="archivo" name="archivo" type="file"/></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width:340px"><b>Tomar la primera fila como nombre de las columnas</b></td>
            <td><input type="checkbox" id="check" name="check" checked="checked"/></td>
        </tr>
    </table>
    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none"></iframe>
</form>
</body>      
</html>
