<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutuales" %>

<%@ Import Namespace="Microsoft.Office.Interop" %>

<%
    Dim proceso = nvFW.nvUtiles.obtenerValor("proceso", "")
    Dim id_transferencia = nvFW.nvUtiles.obtenerValor("id_transferencia", 0)
    Dim check = nvFW.nvUtiles.obtenerValor("check1", "")
    Dim hojaExcel = nvFW.nvUtiles.obtenerValor("hojaExcel", "Hoja1")
    
    If proceso <> "" Then
        Dim er As New tError
        Try
             
            Dim listHojas As String = ""
            Dim MyFile As HttpPostedFile = Request.Files(0)
            
            Dim nombreExcel As String = MyFile.FileName
           
            Dim path As String = System.IO.Path.GetTempFileName() + ".xls"
            MyFile.SaveAs(path)
           
            Dim rs_excel As ADODB.Recordset = New ADODB.Recordset()
            Dim excel As New nvFW.tExcel
           
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
                'rs_excel = excel.ExcelLeerDatos3(primerafila)
                er = excel.ExcelLeerDatos2(primerafila)
                If er.numError <> 0 Then
                    System.IO.File.Delete(path)
                    er.response()
                End If
                rs_excel = excel.adoRecordset
               ' nvDBUtiles.DBCloseRecordset(excel.adoRecordset)
                Dim cant_Reg = rs_excel.RecordCount
            Catch ex As Exception
                nvDBUtiles.DBCloseRecordset(rs_excel)
                System.IO.File.Delete(path)
                er.parse_error_script(ex)
                er.titulo = "Error al guardar perfil."
                er.mensaje = ex.Message
                er.response()
            End Try
            
            System.IO.File.Delete(path)
          
            'stop 
            Dim parametros = "<?xml version='1.0' encoding='ISO-8859-1'?><parametros>"
            For i As Integer = 0 To rs_excel.Fields.Count - 1
                parametros += "<parametro id='" + rs_excel.Fields(i).Name + "' valor=''></parametro>"
            Next
            parametros += "</parametros>"
            
            'cerrar conexion 
            nvDBUtiles.DBCloseRecordset(rs_excel)
            
            Dim strXML As String = "<?xml version='1.0' encoding='ISO-8859-1'?><bpm_batch id_bpm='0' nombre='" + proceso + "' id_transferencia='" + id_transferencia + "' tipos='' excel_name='" + nombreExcel + "' primera_fila='" + primerafila.ToString + "' lista_hojas_excel='" + listHojas + "' hoja_selecc='" + hojaExcel + "'></bpm_batch>"
              
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("perfiles_batch_abm", ADODB.CommandTypeEnum.adCmdStoredProc, emunDBType.db_app)
            cmd.addParameter("@modo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , "A")
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
        function window_onload() {
                    
        }

        function guardar()
        {   
             var nombre = $('proceso').value
            var transf = campos_defs.get_value("id_transferencia")
            var file = $('archivo').value
            
              if( nombre == ''){
                  nvFW.alert("Complete el nombre del proceso")
                 return
             }
             if( transf == ''){
                 nvFW.alert("Seleccione la transferencia asociada")
                 return
             }
              if(validar_extension()) return

             $('id_transferencia').value = transf
             nvFW.bloqueo_activar($$('body')[0], "bloqueo")
             formDocs.submit()
             
         }

         function validar_extension(){         
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
                 for (var i = 0; i < Extensiones.length; i++){
                     if (Extensiones[i] == extension){
                         permitida = true;
                         break;
                     }
                 }

                 if (!permitida){
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
            <td style="width: 50px" class="Tit1">Descipción:</td>
            <td><input  style="width:100%"  id="proceso" name="proceso" type="text"/></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 50px">Transferencia:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("id_transferencia", nro_campo_tipo:=3)%></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 50px">Archivo:</td>
            <td ><input  style="width:100%" id="archivo" name="archivo" type="file" onchange="validar_extension()"/></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width:350px"><b>Tomar la primera fila como nombre de las columnas</b></td>
            <td><input type="checkbox" id="check1" name="check1" checked="checked"/></td>
        </tr>
    </table>
    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none"></iframe>
</form>
</body>      
</html>
