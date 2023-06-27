Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvFile

        Private Shared _upload_max_size As Integer = 0

        Public Shared _fileTypes As Dictionary(Of String, tnvFileType)

        Public Shared ReadOnly Property fileTypes(extencion As String) As tnvFileType
            Get
                If nvFW.nvFile.fileTypes.Keys.Contains(extencion.ToLower) Then
                    Return _fileTypes(extencion.ToLower)
                Else
                    Return _fileTypes("_default")
                End If
            End Get
        End Property
        Public Shared ReadOnly Property fileTypes As Dictionary(Of String, tnvFileType)
            Get
                If _fileTypes Is Nothing Then
                    _fileTypes = New Dictionary(Of String, tnvFileType)
                    _fileTypes.Add("_default", tnvFileType.getNew("_default", "", False, "attachment", False))
                    _fileTypes.Add("html", tnvFileType.getNew("html", "text/html", False, "inline", True))
                    _fileTypes.Add("htm", tnvFileType.getNew("htm", "text/html", False, "inline", True))
                    _fileTypes.Add("xml", tnvFileType.getNew("xml", "text/xml", False, "inline", True))
                    _fileTypes.Add("txt", tnvFileType.getNew("txt", "text/plain", False, "attachment", True))
                    _fileTypes.Add("sql", tnvFileType.getNew("sql", "text/plain", False, "attachment", True))
                    _fileTypes.Add("pdf", tnvFileType.getNew("pdf", "application/pdf", False, "inline", True))
                    _fileTypes.Add("xls", tnvFileType.getNew("xls", "application/vnd.ms-excel", False, "attachment", False))
                    _fileTypes.Add("doc", tnvFileType.getNew("doc", "application/msword", False, "attachment", False))
                    _fileTypes.Add("zip", tnvFileType.getNew("zip", "application/zip", False, "attachment", False))
                    _fileTypes.Add("gzip", tnvFileType.getNew("gzip", "application/gzip", False, "attachment", False))
                    _fileTypes.Add("rar", tnvFileType.getNew("rar", "application/x-rar-compressed", False, "attachment", False))
                    _fileTypes.Add("mp3", tnvFileType.getNew("mp3", "audio/mpeg", False, "attachment", False))
                    _fileTypes.Add("tmp", tnvFileType.getNew("tmp", "", False, "inline", True))
                    'Imagenes
                    _fileTypes.Add("gif", tnvFileType.getNew("gif", "image/gif", True, "inline", True))
                    _fileTypes.Add("jpg", tnvFileType.getNew("jpg", "image/jpeg", True, "inline", True))
                    _fileTypes.Add("jpeg", tnvFileType.getNew("jpeg", "image/jpeg", True, "inline", True))
                    _fileTypes.Add("png", tnvFileType.getNew("png", "image/png", True, "inline", True))
                    _fileTypes.Add("tif", tnvFileType.getNew("tif", "image/tiff", True, "inline", True))
                    _fileTypes.Add("tiff", tnvFileType.getNew("tiff", "image/tiff", True, "inline", True))
                    _fileTypes.Add("bmp", tnvFileType.getNew("bmp", "image/bmp", True, "inline", True))
                    'Video
                    _fileTypes.Add("mpg", tnvFileType.getNew("mpg", "video/mpeg", False, "inline", True))
                    _fileTypes.Add("mpeg", tnvFileType.getNew("mpeg", "video/mpeg", False, "inline", True))
                    _fileTypes.Add("mp4", tnvFileType.getNew("mp4", "video/mp4", False, "inline", True))
                    _fileTypes.Add("wmv", tnvFileType.getNew("wmv", "video/x-ms-wmv", False, "inline", True))
                    _fileTypes.Add("flv", tnvFileType.getNew("flv", "video/x-flv", False, "inline", True))
                    _fileTypes.Add("avi", tnvFileType.getNew("avi", "video/avi", False, "inline", True))
                End If
                Return _fileTypes
            End Get
        End Property

        Public Shared Function getFileTypes_rsParam() As trsParam
            Dim res As New trsParam
            Dim resElement As trsParam
            For Each imageType As tnvFileType In nvFW.nvFile.fileTypes.Values
                resElement = New trsParam
                resElement.Add("extencion", imageType.extencion)
                resElement.Add("contentType", imageType.contentType)
                resElement.Add("hasThumb", imageType.hasThumb)
                resElement.Add("defaul_content_disposition", imageType.defaul_content_disposition)
                resElement.Add("browser_display", imageType.browser_display)
                res.Add(imageType.extencion, resElement)
            Next

            Return res
        End Function

        Public Shared ReadOnly Property upload_max_size As Integer
            Get
                'Dim max2 As Integer = nvServer. 
                If _upload_max_size = 0 Then
                    _upload_max_size = nvServer.getConfigValue("/config/global/nvFile/@upload_max_size", "0")
                    'Controlar system.web/httpRuntime/@MaxRequestLength
                    Dim section As Web.Configuration.HttpRuntimeSection = ConfigurationManager.GetSection("system.web/httpRuntime")
                    If Not section Is Nothing Then
                        If section.MaxRequestLength < _upload_max_size Then
                            _upload_max_size = section.MaxRequestLength
                        End If
                    End If

                    'Controlar configuration/system.webServer/security/requestFiltering/requestLimits/@maxAllowedContentLength

                    'Dim config As Object = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration(HttpContext.Current.Request.ApplicationPath)
                    'Dim section_system_webServer = config.GetSection("system.webServer")
                    'Dim Xml As String = section_system_webServer.SectionInformation.GetRawXml()
                    Dim oXML As New System.Xml.XmlDocument
                    oXML.Load(nvServer.appl_physical_path & "\web.config")
                    Dim maxAllowedContentLength As Integer = nvXMLUtiles.getAttribute_path(oXML, "configuration/system.webServer/security/requestFiltering/requestLimits/@maxAllowedContentLength", _upload_max_size)
                    If maxAllowedContentLength < _upload_max_size Then
                        _upload_max_size = maxAllowedContentLength
                    End If

                End If
                Return _upload_max_size
            End Get
        End Property

        Public Shared Function getFile(Optional f_id As Integer = 0, Optional ref_files_path As String = "") As tnvFile
            Dim f As New tnvFile
            Dim strSQL As String
            strSQL = "SELECT	f.f_id, " & vbCrLf
            strSQL += "f.f_nombre, " & vbCrLf
            strSQL += "f.f_ext, " & vbCrLf
            strSQL += "f.f_path, " & vbCrLf
            strSQL += "f.f_falta, " & vbCrLf
            strSQL += "f.f_nro_tipo, " & vbCrLf
            strSQL += "ISNULL(f.f_depende_de, 0) AS f_depende_de, " & vbCrLf
            strSQL += "f.f_size, " & vbCrLf
            strSQL += "dbo.ref_files_path(f.f_id) AS ref_files_path, " & vbCrLf
            strSQL += "dbo.ref_files_dir(f.f_id) AS ref_files_dir, " & vbCrLf
            strSQL += "ISNULL(dbo.ref_files_path(f.f_depende_de), '') AS parent_ref_files_path," & vbCrLf
            strSQL += "f.f_nro_ubi," & vbCrLf
            strSQL += "o.login" & vbCrLf
            strSQL += "FROM	dbo.ref_files AS f " & vbCrLf
            strSQL += "INNER JOIN dbo.ref_file_tipos AS t ON f.f_nro_tipo = t.f_nro_tipo" & vbCrLf
            strSQL += "LEFT OUTER JOIN dbo.ref_files AS p ON p.f_id = f.f_depende_de" & vbCrLf
            strSQL += "LEFT OUTER JOIN dbo.verOperadores AS o ON o.operador = f.nro_operador" & vbCrLf

            If ref_files_path <> "" Then strSQL += " where  f.borrado = 0 and dbo.ref_files_path(f.f_id) =  '" & ref_files_path & "'"
            If f_id > 0 Then strSQL += " where f.f_id =  " & f_id

            If ref_files_path = "" And f_id = 0 Then
                Return Nothing
            End If

            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset(strSQL)
            If rs.EOF Then
                Return Nothing
            End If

            f.f_id = rs.Fields("f_id").Value
            f.f_nombre = rs.Fields("f_nombre").Value
            f.f_ext = rs.Fields("f_ext").Value
            f.f_path = rs.Fields("f_path").Value
            f.f_falta = rs.Fields("f_falta").Value
            f.f_nro_tipo = rs.Fields("f_nro_tipo").Value
            f.f_depende_de = nvUtiles.isNUll(rs.Fields("f_depende_de").Value, -1)
            f.f_size = rs.Fields("f_size").Value
            f.f_nro_ubi = rs.Fields("f_nro_ubi").Value
            f.ref_files_path = rs.Fields("ref_files_path").Value
            f.ref_files_dir = rs.Fields("ref_files_dir").Value
            f.parent_ref_files_path = rs.Fields("parent_ref_files_path").Value
            f.login = rs.Fields("login").Value

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            Return f
        End Function

        Public Class tnvFile
            Public f_id As Integer
            Public f_nombre As String
            Public f_ext As String
            Public f_nro_ubi As Integer
            Public f_path As String
            Public f_falta As Date
            Public f_nro_tipo As Integer
            Public f_depende_de As Integer
            Public f_size As Integer
            Public ref_files_path As String
            Public ref_files_dir As String
            Public parent_ref_files_path As String
            Public login As String

            Private _BinaryData() As Byte = Nothing
            Public ReadOnly Property filename As String
                Get
                    Return f_nombre & IIf(f_ext <> "", "." & f_ext, "")
                End Get
            End Property

            Public ReadOnly Property BinaryData As Byte()
                Get
                    If _BinaryData Is Nothing Then
                        If f_nro_ubi = 1 Then
                            'archivo fisico
                            Try
                                Dim filepath As String = ""
                                Dim nvApp As tnvApp = nvFW.nvApp.getInstance
                                Dim paths() As String = nvApp.app_dirs("nvFiles").path.Split(";")
                                For Each path In paths
                                    If System.IO.File.Exists(path & "\file" & f_id & "." & f_ext) Then
                                        filepath = path & "\file" & f_id & "." & f_ext
                                        Exit For
                                    End If
                                Next
                                _BinaryData = System.IO.File.ReadAllBytes(filepath)
                            Catch ex As Exception
                                Return Nothing
                            End Try

                            'Dim fs As New System.IO.FileStream(f_path, IO.FileMode.Open)
                            'Dim bytes(fs.Length - 1) As Byte
                            'fs.Read(bytes, 0, fs.Length)
                            'BinaryData = bytes
                            'fs.Close()
                        Else
                            'archivo guardado en DB           
                            Dim rs2 As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("Select * from ref_file_bin where f_id =  " & f_id)
                            _BinaryData = rs2.Fields("BinaryData").Value
                            nvFW.nvDBUtiles.DBCloseRecordset(rs2)
                        End If
                    End If
                    Return _BinaryData
                End Get
            End Property

            Public Function getThumbBinary(strech As Boolean, width As Integer, Optional height As Integer = 0, Optional quality As Integer = 60) As Byte()
                Dim dbSourse As Boolean = False
                Dim file_return As String = "/fw/image/file_dialog/file_default.png"
                Dim BinaryData() As Byte = Nothing

                If f_nro_tipo = -1 Then
                    file_return = "/fw/image/file_dialog/disco32.png"
                End If

                If f_nro_tipo = 0 Then
                    file_return = "/fw/image/file_dialog/carpeta32.png"
                End If

                If f_nro_tipo = 1 Then
                    'Se puede generar el thumb
                    If nvFW.nvFile.fileTypes(f_ext).hasThumb Then
                        Dim nvApp As tnvApp = nvFW.nvApp.getInstance
                        Dim hasThumbConn As Boolean = False
                        For Each cnv In nvApp.app_cns
                            If cnv.Key.ToLower = "nv_framework@thumb" And cnv.Value.cn_string <> "" Then
                                hasThumbConn = True
                            End If
                        Next

                        If hasThumbConn Then
                            ' Conectar a la bd de Thumb de la aplicacion actual
                            Dim strSQL As String = "SELECT * FROM file_thumb WHERE f_id = " & f_id & " AND width = " & width & " AND height = " & height
                            Dim res As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL:=strSQL, cod_cn:="nv_framework@thumb")
                            If Not res.EOF Then
                                BinaryData = res.Fields("archivo").Value
                                dbSourse = True
                            End If
                            nvFW.nvDBUtiles.DBCloseRecordset(res)
                        End If

                        If BinaryData Is Nothing Then
                            BinaryData = nvFW.nvImage.getThumbBinary(Me.BinaryData, strech, width, height, quality)
                        End If

                        If Not BinaryData Is Nothing And hasThumbConn And Not dbSourse Then

                            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand(commandText:="pa_file_thumb", commandType:=ADODB.CommandTypeEnum.adCmdStoredProc, cod_cn:="nv_framework@thumb")
                            cmd.Parameters("@f_id").Value = f_id
                            cmd.Parameters("@width").Value = width
                            cmd.Parameters("@height").Value = height
                            cmd.Parameters("@archivo").Type = 205
                            cmd.Parameters("@archivo").Size = BinaryData.Count
                            cmd.Parameters("@archivo").AppendChunk(BinaryData)

                            Dim result As ADODB.Recordset = cmd.Execute()

                            'err.numError = result.Fields("numError").Value
                            'err.mensaje = result.Fields("mensaje").Value
                            'err.titulo = result.Fields("titulo").Value
                            'err.debug_desc = result.Fields("debug_desc").Value
                            'err.debug_src = result.Fields("debug_src").Value

                            nvFW.nvDBUtiles.DBCloseRecordset(result)

                        End If

                        If BinaryData Is Nothing Then
                            If System.IO.File.Exists(HttpContext.Current.Server.MapPath("/fw/image/file_dialog/file_" + f_ext + ".png")) Then
                                file_return = "/fw/image/file_dialog/file_" + f_ext + ".png"
                            End If
                        End If
                    End If

                End If
                If BinaryData Is Nothing And file_return <> "" Then
                    Dim absPath As String = HttpContext.Current.Server.MapPath(file_return)
                    BinaryData = System.IO.File.ReadAllBytes(absPath)
                End If

                Return BinaryData
            End Function
        End Class

        Public Class tnvFileType
            Public extencion As String
            Public contentType As String
            Public hasThumb As Boolean = False 'determina si esta estención permite hacer thumbs
            Public defaul_content_disposition As String = "inline" 'inline|attachment
            Public browser_display As Boolean 'determina si esta extensión es visualizable en los browsers

            Public Sub New(extencion As String, contentType As String, Optional hasThumb As Boolean = False, Optional defaul_content_disposition As String = "inline", Optional browser_display As Boolean = False)
                Me.extencion = extencion
                Me.contentType = contentType
                Me.hasThumb = hasThumb
                Me.defaul_content_disposition = defaul_content_disposition
                Me.browser_display = browser_display
            End Sub
            Public Shared Function getNew(extencion As String, contentType As String, Optional hasThumb As Boolean = False, Optional defaul_content_disposition As String = "inline", Optional browser_display As Boolean = False) As tnvFileType
                Dim nuevo As New tnvFileType(extencion, contentType, hasThumb, defaul_content_disposition, browser_display)
                Return nuevo
            End Function

        End Class

    End Class
End Namespace
