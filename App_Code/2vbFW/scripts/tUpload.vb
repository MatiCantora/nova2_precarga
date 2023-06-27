Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW

    Public Class tUploadConfig
        Public Shared upload_max_size As Integer = 80000
        Public Shared upload_filter As String = ""
    End Class

    Public Class tUpload

        Public file_id As Integer
        Public max_size As Integer = tUploadConfig.upload_max_size
        Public filter As String = tUploadConfig.upload_filter
        Public filters() As String = tUploadConfig.upload_filter.Split("|")

        Public size As Integer = 0
        Public filename As String = ""
        Public path_tmp As String = ""
        Public estado As nvenumTUploadStado = nvenumTUploadStado.subiendo


        Public Sub New(file_id As Integer)


            'Dim upload_files As Dictionary(Of Integer, tUpload) = nvSession.Contents("upload_files")
            'If upload_files Is Nothing Then
            '    upload_files = New Dictionary(Of Integer, tUpload)
            'End If

            'Me.file_id = upload_files.Count + 1

            Me.file_id = file_id
            Me.max_size = tUploadConfig.upload_max_size
            Me.filter = tUploadConfig.upload_filter
            Me.filters = filter.Split("|")
            Me.size = 0
            Me.filename = ""
            Me.path_tmp = ""
            Me.estado = nvenumTUploadStado.subiendo




            'upload_files(Me.file_id) = Me



            'Optional ByVal file_id As Integer = Nothing
            'If file_id <> Nothing And upload_files.ContainsKey(file_id) Then
            '    Dim file As tUpload = upload_files(file_id)
            '    Me.file_id = file.file_id
            '    Me.max_size = file.max_size
            '    Me.filter = file.filter
            '    Me.filters = file.filters
            '    Me.size = file.size
            '    Me.filename = file.filename
            '    Me.path_tmp = file.path_tmp
            '    Me.estado = file.estado
            'Else



        End Sub
        'Public Function setFilename(name As String) As Boolean()
        '    Me.filename = name
        '    nvSession.Contents("upload_files")(Me.file_id) = Me
        'End Function
        Public Function getBinaryData() As Byte()
            If System.IO.File.Exists(path_tmp) Then

                Dim buffer() As Byte = System.IO.File.ReadAllBytes(path_tmp)
                Return buffer
                'Dim fs As New System.IO.FileStream(path_tmp, IO.FileMode.Open)
                'Dim buffer(fs.Length - 1) As Byte
                'fs.Read(buffer, 0, fs.Length)
                'Return buffer
            Else
                Return Nothing
            End If
        End Function

        Public Sub borrar()
            If System.IO.File.Exists(path_tmp) Then
                System.IO.File.Delete(path_tmp)
            End If
            path_tmp = ""
            estado = nvenumTUploadStado.borrado
        End Sub

        Public Sub set_filename_tmp()
            path_tmp = System.IO.Path.GetTempFileName
        End Sub

        'Public Sub limpiar()
        '    Dim upload_files As Dictionary(Of Integer, tUpload) = nvSession.Contents("upload_files")
        '    Dim file_id As Integer
        '    Dim file As tUpload
        '    For Each file_id In upload_files.Keys
        '        file = New tUpload(file_id)
        '        file.borrar()
        '    Next

        'End Sub

        Public Sub mover(ByVal path_destino As String, Optional ByVal sobreescribir As Boolean = True, Optional ByVal mantener_origen As Boolean = False)

            '//Si el destino existe y no se sobreescribe dar error
            If System.IO.File.Exists(path_destino) And Not sobreescribir Then
                Throw New Exception("No se puede copiar el archivo. Ya existe el archivo destino")
            End If

            '//Si el archivo de origen no existe dar error
            If Not System.IO.File.Exists(path_tmp) Then
                Throw New Exception("No se puede copiar el archivo. No existe el origen")
            End If

            '//Copiar y borrar el archivo  
            System.IO.File.Copy(path_tmp, path_destino)

            If Not mantener_origen Then borrar()
        End Sub

        Public Sub response()

            Dim ext As String = System.IO.Path.GetExtension(filename)
            Dim ContentType As String = ""

            Select Case ext.ToLower

                Case ".xls"
                    ContentType = "application/vnd.ms-excel"

                Case ".doc"
                    ContentType = "application/msword"

                Case ".html"
                    ContentType = "text/html"

                Case ".pdf"
                    ContentType = "application/pdf"

                Case ".xml"
                    ContentType = "text/xml"

            End Select

            HttpContext.Current.Response.ContentType = ContentType
            HttpContext.Current.Response.AddHeader("filename", Me.filename)

            HttpContext.Current.Response.BinaryWrite(Me.getBinaryData)

        End Sub

        'Public Sub statusUpdate()
        '    Dim upload_files As Dictionary(Of Integer, tUpload) = nvSession.Contents("upload_files")
        '    upload_files(Me.file_id) = Me
        'End Sub

        Public Enum nvenumTUploadStado
            subiendo = 0
            borrado = 1
        End Enum

    End Class

End Namespace
