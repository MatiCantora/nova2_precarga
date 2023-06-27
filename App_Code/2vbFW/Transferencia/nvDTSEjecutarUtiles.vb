Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW.nvTransferencia
    Public Class nvDTSEjecutarUtiles

        '/*********************************************************************************/
        '//  Ejecuta un dtsx
        '//  Importante metodo define como se realizará la ejecución
        '//  Metodo = 'TSQL' = Se ejecuta atraves del sp rm_DTSRun
        '//           El dtsx debe encontrarse en el servidor donde se ejecuta SQL Server   
        '//           Se ejecuta con el usuario de la cuenta de servicio de SQL    
        '//  Metodo = 'ASP' = Se ejecuta atraves del código ASP
        '//           El dtsx debe encontrarse en el servidor donde se ejecuta IIS   
        '//           Se ejecuta con el usuario de servicio de IIS
        '/********************************************************************************/
        Public Shared Function DTSRun(dtsx_path As String, xml_param As String, dtsx_exec As String, Optional ByVal timeOut As Integer = -1) As ADODB.Recordset

            If dtsx_exec = "" Then
                dtsx_exec = ".NET"
            End If

            'transparente para lo anterior
            'dtsx_exec = Replace(dtsx_exec, "ASP", "SSIS")

            dtsx_exec = ".NET"

            Dim rs As ADODB.Recordset

            Select Case dtsx_exec.ToUpper()

                Case "SSIS2017"
                    rs = DTSRun_ASP_shell(dtsx_path, xml_param, timeOut, 140)

                Case "SSIS2008"
                    rs = DTSRun_ASP_shell(dtsx_path, xml_param, timeOut, 100)

                Case "SSIS2005"
                    rs = DTSRun_ASP_shell(dtsx_path, xml_param, timeOut, 90)
                Case ".NET"
                    rs = DTSRun_ASPNet(dtsx_path, xml_param)
                Case Else
                    rs = DTSRun_TSQL(dtsx_path, xml_param, timeOut)
            End Select

            Return rs

        End Function

        Public Shared Function DTSRun_ASP_shell(dtsx_path As String, xml_param As String, TimeOut As Integer, version As Integer) As ADODB.Recordset
            If (TimeOut <= 0) Then TimeOut = 3000

            Dim strCmd As String
            Dim strParam As String = ""
            Dim variable As String
            Dim valor As String

            Dim oXML As New System.Xml.XmlDocument
            If Trim(xml_param) <> "" Then
                Try
                    oXML.LoadXml(xml_param)
                    Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/parametros/*")
                    For Each Nod As System.Xml.XmlNode In nodes
                        variable = Nod.Attributes("variable").Value
                        valor = Nod.InnerText
                        strParam = strParam & " /Set ""\Package.variables[" & variable & "].Value"";" & valor
                    Next

                Catch ex As Exception

                End Try
            End If

            strCmd = "dtexec.exe /F """ & dtsx_path & """" & strParam

            'Objeto shell  
            Dim objShell = CreateObject("wscript.shell")
            objShell.CurrentDirectory = "C:\Program Files (x86)\Microsoft SQL Server\" & version & "\DTS\Binn\"
            'Exec comand
            Dim sexec = objShell.Exec(strCmd)
            Dim strRes As String = ""

            '  //Recuperar info de aoutput
            While Not sexec.stdout.AtEndOfStream
                strRes += sexec.stdout.Read(2000)
            End While

            objShell = Nothing
            sexec = Nothing

            Dim line = ""
            Dim pos

            Dim reg As System.Text.RegularExpressions.Regex = New System.Text.RegularExpressions.Regex("'", RegexOptions.IgnoreCase)
            Dim strSQL As String = ""

            Dim lineas = strRes.Split(vbCrLf)
            strRes = ""
            For Each linea In lineas
                If Trim(linea) <> "" Then
                    strSQL = "insert into ERROR_DTSX([output]) values ('" & reg.Replace(linea, "''") & "')"
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If
            Next

            'Recuperar id_run
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX")
            Dim id_run As Integer = rs.Fields("id_run").Value
            'Actualizar id_run y cmd
            strSQL = "update ERROR_DTSX set id_run = " & id_run & ", cmd = '" & reg.Replace(strCmd, "''") & "'  where id_run = 0"
            nvFW.nvDBUtiles.DBExecute(strSQL)
            rs = nvFW.nvDBUtiles.DBOpenRecordset("Select * from ERROR_DTSX where id_run = " & id_run)

            Return rs
        End Function

        Public Shared Function DTSRun_ASP(dtsx_path As String, xml_param As String) As ADODB.Recordset
            Dim strCmd As String
            Dim strParam As String = ""
            Dim variable As String
            Dim valor As String

            Dim oDTSExec = CreateObject("DTSXUtil.RMDTS.DTSExec")

            Dim oXML As New System.Xml.XmlDocument
            If Trim(xml_param) <> "" Then
                Try
                    oXML.LoadXml(xml_param)
                    Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/parametros/*")
                    For Each Nod As System.Xml.XmlNode In nodes
                        variable = Nod.Attributes("variable").Value
                        valor = Nod.InnerText
                        oDTSExec.param_add(variable, valor)
                        strParam = strParam & " /Set \\Package.variables[" & variable & "].Value;" & valor
                    Next

                Catch ex As Exception

                End Try

            End If

            oDTSExec.path = dtsx_path

            'Identificar las connexiones por nombre y asignar las cadenas


            Dim r = oDTSExec.execute()
            Dim strRes = oDTSExec.Log

            Dim reg As System.Text.RegularExpressions.Regex = New System.Text.RegularExpressions.Regex("'", RegexOptions.IgnoreCase)
            Dim strSQL As String = ""

            Dim lineas = strRes.Split(vbCrLf)
            strRes = ""
            For Each linea In lineas
                If Trim(linea) <> "" Then
                    strSQL = "insert into ERROR_DTSX([output]) values ('" & reg.Replace(linea, "''") & "')"
                    nvFW.nvDBUtiles.DBExecute(strSQL)
                End If
            Next

            'Recuperar id_run
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX")
            Dim id_run As Integer = rs.Fields("id_run").Value
            'Actualizar id_run y cmd
            strSQL = "update ERROR_DTSX set id_run = " & id_run & ", cmd = '" & reg.Replace(strCmd, "''") & "'  where id_run = 0"
            nvFW.nvDBUtiles.DBExecute(strSQL)
            rs = nvFW.nvDBUtiles.DBOpenRecordset("Select * from ERROR_DTSX where id_run = " & id_run)

            Return rs
            '      var strCmd
            '      var strParam
            '      var variable
            '      var tipo_dato
            '      var valor

            '      //Abrir xml      
            '      xml_param = '<?xml version="1.0" encoding="iso-8859-1"?>' + xml_param
            '      var objXML = Server.CreateObject('Microsoft.XMLDOM')
            '      objXML.loadXML(xml_param)

            '    var oDTSExec = Server.CreateObject("DTSXUtil.RMDTS.DTSExec")

            '      var NODs = objXML.selectNodes('/parametros/*')
            '      strParam = ''
            '      for (var i = 0; i < NODs.length; i++) 
            '        {
            '        variable = getAttribute(NODs[i], 'variable', '')
            '    tipo_dato = getAttribute(NODs[i], 'tipo_dato', '')
            '    valor = NODs[i].text
            '        //Los datos varchar no pueden ser vacios se reemplazan por " "
            '        //oDTSExec.params.add(variable, valor)
            '        oDTSExec.param_add(variable, valor)

            '    If (valor == '')
            '          valor = '" "'
            '        else
            '          valor = '"' + valor + '"'

            '        strParam = strParam + ' /Set \\Package.variables[' + variable + '].Value;' + valor
            '        } 

            '      strCmd = 'dtexec.exe /F "' + dtsx_path + '"' + strParam

            '        oDTSExec.path = dtsx_path
            '      //Objeto DTSXExec

            '      //var r = oDTSExec.executeCMD(strCmd)
            '      var r = oDTSExec.execute()

            '      var strRes = oDTSExec.Log

            '      var line = ''
            '      var pos

            '      var reg = New RegExp("'", "ig")
            '      var strSQL = ''

            '        var lineas = strRes.split("\n")

            '      For (var i in lineas) {
            '          linea = lineas[i]
            '          If (linea!= '')
            '              strSQL = "insert into ERROR_DTSX([output]) values ('" + linea.replace(reg, "''") + "')"
            '          DBExecute(strSQL)
            '      }
            '      //Recuperar id_run
            '      rs = DBOpenRecordset('select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX')
            '      var id_run = rs.Fields('id_run').Value
            '      //Actualizar id_run y cmd
            '      strSQL = "update ERROR_DTSX set id_run = " + id_run + ", cmd = '" + strCmd.replace(reg, "''") + "'  where id_run = 0"
            '                DBExecute(strSQL)

            '                rs = DBOpenRecordset('Select * from ERROR_DTSX where id_run = ' + id_run)

            '                Return rs
        End Function

        Public Shared Function DTSRun_TSQL(dtsx_path As String, xml_param As String, Optional ByVal TimeOut As Integer = -1) As ADODB.Recordset
            Dim rsExec As New ADODB.Recordset
            If TimeOut <= 0 Then TimeOut = 3000
            'EJECUTAR EL DTS
            Dim cmd As New ADODB.Command
            cmd.ActiveConnection = nvFW.nvDBUtiles.ADMDBConectar
            cmd.CommandType = ADODB.CommandTypeEnum.adCmdStoredProc ' 4 // comandType = SP
            cmd.CommandTimeout = TimeOut 'segundos
            cmd.CommandText = "rm_DTSRun"
            'AGREGAR PARAMETROS
            Dim param01 As ADODB.Parameter = cmd.CreateParameter("dtsx_path", 201, 1, 4000, dtsx_path)
            cmd.Parameters.Append(param01)
            Dim xml_param_dtsx As ADODB.Parameter = cmd.CreateParameter("xml_param_dtsx", 201, 1, 8000, xml_param)
            cmd.Parameters.Append(xml_param_dtsx)

            rsExec.Source = cmd
            rsExec.Open()

            Return rsExec
        End Function


        Public Shared Function DTSRun_ASPNet(dtsx_path As String, xml_param As String) As ADODB.Recordset

            Dim pkg As Microsoft.SqlServer.Dts.Runtime.Package
            Dim app As New Microsoft.SqlServer.Dts.Runtime.Application

            'Abrir el paquete
            pkg = app.LoadPackage(dtsx_path, Nothing)

            'Recuperar conexiones y asignar las cadenas de conexión
            Dim Connections = pkg.Connections
            Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance()
            For Each cn In nvApp.app_cns
                Try
                    Connections(cn.Value.cn_nombre).ConnectionString = cn.Value.cn_string
                Catch ex As Exception
                End Try
            Next


            'Recuperar variables y asignales el valor
            Dim strParam As String = ""
            Dim vars = pkg.Variables
            If Trim(xml_param) <> "" Then
                Dim oXML As New System.Xml.XmlDocument
                Dim variable As String
                Dim valor As String
                Try
                    oXML.LoadXml(xml_param)
                    Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("/parametros/*")
                    For Each Nod As System.Xml.XmlNode In nodes
                        variable = Nod.Attributes("variable").Value
                        valor = Nod.InnerText
                        'strParam = strParam & " /Set ""\Package.variables[" & variable & "].Value"";" & valor
                        Try
                            vars(variable).Value = valor
                        Catch ex As Exception

                        End Try
                    Next
                Catch ex As Exception
                End Try
            End If

            ' Dim strCmd As String = "dtexec.exe /F """ & dtsx_path & """" & strParam

            'Ejecutar el proceso
            Dim pkgResults As Microsoft.SqlServer.Dts.Runtime.DTSExecResult = pkg.Execute(Connections, vars, Nothing, Nothing, Nothing)
            Dim reg As System.Text.RegularExpressions.Regex = New System.Text.RegularExpressions.Regex("'", RegexOptions.IgnoreCase)
            Dim strSQL As String = ""
            strSQL += "declare @id_run int = 0" & vbCrLf
            strSQL += "Insert into ERROR_DTSX_CAB(momento) values (getdate())" & vbCrLf
            strSQL += "set @id_run = @@IDENTITY" & vbCrLf
            strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'Utilidad de ejecución de paquetes de .NET')" & vbCrLf
            strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'Iniciado: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf

            If pkg.Errors.Count > 0 Then
                For Each Er In pkg.Errors
                    strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'" & "Error: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf
                    strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'" & reg.Replace(" - " & Er.Description, "''") & "')" & vbCrLf
                    strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'Fin de error')" & vbCrLf
                Next
            End If
            strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'DTExec: la ejecución del paquete devolvió " & [Enum].GetName(GetType(Microsoft.SqlServer.Dts.Runtime.DTSExecResult), pkgResults).ToString & " (" & pkgResults.ToString & "). ')" & vbCrLf
            strSQL += "Insert into ERROR_DTSX(id_run,[output]) values (@id_run,'Finalizado: " & Now().ToString("HH:mm:ss.fff") & "')" & vbCrLf
            strSQL += "Select * from ERROR_DTSX where id_run = @id_run"
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL)

            'Recuperar id_run
            'Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX")
            'Dim id_run As Integer = rs.Fields("id_run").Value
            'Actualizar id_run y cmd
            ' strSQL = "update ERROR_DTSX set id_run = " & id_run & " , cmd = '" & reg.Replace(strCmd, "''") & "'  where id_run = 0"
            ' nvFW.nvDBUtiles.DBExecute(strSQL)
            'rs = nvFW.nvDBUtiles.DBOpenRecordset("Select * from ERROR_DTSX where id_run = " & id_run)

            Return rs
            'String pkgLocation = @"c:\test.dtsx"; 

            'Package pkg; 
            'Application app; 
            'DTSExecResult pkgResults; 
            'Variables vars; 

            'app = New Application(); 
            'pkg = app.LoadPackage(pkgLocation, null); 

            'vars = pkg.Variables; 
            'vars["A_Variable"].Value = "Some value";    

            'pkgResults = pkg.Execute(null, vars, null, null, null); 

            'If (pkgResults == DTSExecResult.Success) Then
            '           Console.WriteLine("Package ran successfully"); 
            'Else
            '           Console.WriteLine("Package failed"); 
        End Function



    End Class

End Namespace


'  Function DTSRun_ASP(dtsx_path, xml_param)
'    {

'      var strCmd
'      var strParam
'      var variable
'      var tipo_dato
'      var valor

'      //Abrir xml      
'      xml_param = '<?xml version="1.0" encoding="iso-8859-1"?>' + xml_param
'      var objXML = Server.CreateObject('Microsoft.XMLDOM')
'      objXML.loadXML(xml_param)

'    var oDTSExec = Server.CreateObject("DTSXUtil.RMDTS.DTSExec")

'      var NODs = objXML.selectNodes('/parametros/*')
'      strParam = ''
'      for (var i = 0; i < NODs.length; i++) 
'        {
'        variable = getAttribute(NODs[i], 'variable', '')
'    tipo_dato = getAttribute(NODs[i], 'tipo_dato', '')
'    valor = NODs[i].text
'        //Los datos varchar no pueden ser vacios se reemplazan por " "
'        //oDTSExec.params.add(variable, valor)
'        oDTSExec.param_add(variable, valor)

'    If (valor == '')
'          valor = '" "'
'        else
'          valor = '"' + valor + '"'

'        strParam = strParam + ' /Set \\Package.variables[' + variable + '].Value;' + valor
'        } 

'      strCmd = 'dtexec.exe /F "' + dtsx_path + '"' + strParam

'        oDTSExec.path = dtsx_path
'      //Objeto DTSXExec

'      //var r = oDTSExec.executeCMD(strCmd)
'      var r = oDTSExec.execute()

'      var strRes = oDTSExec.Log

'      var line = ''
'      var pos

'      var reg = New RegExp("'", "ig")
'      var strSQL = ''

'        var lineas = strRes.split("\n")

'      For (var i in lineas) {
'          linea = lineas[i]
'          If (linea!= '')
'              strSQL = "insert into ERROR_DTSX([output]) values ('" + linea.replace(reg, "''") + "')"
'          DBExecute(strSQL)
'      }
'      //Recuperar id_run
'      rs = DBOpenRecordset('select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX')
'      var id_run = rs.Fields('id_run').Value
'      //Actualizar id_run y cmd
'      strSQL = "update ERROR_DTSX set id_run = " + id_run + ", cmd = '" + strCmd.replace(reg, "''") + "'  where id_run = 0"
'                DBExecute(strSQL)

'                rs = DBOpenRecordset('Select * from ERROR_DTSX where id_run = ' + id_run)

'                Return rs
'  } 


'Function DTSRun_ASP_shell(dtsx_path, xml_param, TimeOut, version)
'  {
'  If (!TimeOut) Then
'        TimeOut = 3000

'        var strCmd
'  var strParam
'  var variable
'  var tipo_dato
'  var valor

'  xml_param = '<?xml version="1.0" encoding="iso-8859-1"?>' + xml_param

'        var objXML = Server.CreateObject('Microsoft.XMLDOM')

'        objXML.loadXML(xml_param)

'        var NODs = objXML.selectNodes('/parametros/*')
'  strParam = ''  
'  for(var i = 0; i < NODs.length; i++)
'    {
'    variable = getAttribute(NODs[i], 'variable', '')
'        tipo_dato = getAttribute(NODs[i], 'tipo_dato', '')
'        valor = NODs[i].text
'    If (tipo_dato.toUpperCase() == 'VARCHAR')
'      valor = '"' + valor + '"'
'    strParam = strParam + ' /Set \\Package.variables[' + variable + '].Value;' + valor
'    }

'  strCmd = 'dtexec.exe /F "' + dtsx_path + '"' + strParam

'  //Objeto shell  
'  var objShell = Server.CreateObject("wscript.shell")
'  objShell.CurrentDirectory = "C:\\Program Files (x86)\\Microsoft SQL Server\\" + version + "\\DTS\\Binn\\"
'  //objShell.Run(strCmd, 1, true)

'  //Exec comand
'  var sexec = objShell.Exec(strCmd)
'  var strRes = ''
'  // Multiples procesos
'  //Esperar hasta que termine
'  /*
'   var i = 0
'  While (sexec.Status < 1)
'                i++
'  */
'  //strRes += sexec.stdout.Read(20000) 

'  //Recuperar info de aoutput
'  While (!sexec.stdout.AtEndOfStream)
'                    strRes += sexec.stdout.Read(2000)

'                    objShell = null
'                    sexec = null

'                    var line = ''
'  var pos 

'  var reg = New RegExp("'", "ig")
'  var strSQL = ''

'                    var lineas = strRes.split("\n")
'  strRes = ''
'  for (var i in lineas)
'    {
'    linea = lineas[i]
'    If (linea!= '') 
'      strSQL = "insert into ERROR_DTSX([output]) values ('" + linea.replace(reg, "''") + "')"
'    DBExecute(strSQL)
'    }
'  //Recuperar id_run
'  rs = DBOpenRecordset('select isnull(max(id_run)+1, 0) as id_run from ERROR_DTSX')  
'  var id_run = rs.Fields('id_run').Value
'  //Actualizar id_run y cmd
'  strSQL = "update ERROR_DTSX set id_run = " + id_run + ", cmd = '" + strCmd.replace(reg, "''") + "'  where id_run = 0"
'                        DBExecute(strSQL)

'                        rs = DBOpenRecordset('Select * from ERROR_DTSX where id_run = ' + id_run)

'                        Return rs
'  }

'Function DTSRun_TSQL(dtsx_path, xml_param, TimeOut)
'  {
'  var rsExec = Server.CreateObject("ADODB.Recordset")
'  If (!TimeOut) Then
'        TimeOut = 3000
'  //EJECUTAR EL DTS
'  cmd = Server.CreateObject("ADODB.Command")
'        cmd.ActiveConnection = conectar()
'        cmd.CommandType = 4 // comandType = SP
'        cmd.CommandTimeout = TimeOut // segundos
'        cmd.CommandText = 'rm_DTSRun'
'  // AGREGAR PARAMETROS
'  dtsx_path = cmd.CreateParameter('dtsx_path', 201, 1, 4000, dtsx_path)
'  cmd.Parameters.Append(dtsx_path)
'  var xml_param_dtsx = cmd.CreateParameter('xml_param_dtsx', 201, 1, 8000, xml_param)
'  cmd.Parameters.Append(xml_param_dtsx)

'  rsExec.Source = cmd
'        rsExec.Open()

'        Return rsExec
'  }  

