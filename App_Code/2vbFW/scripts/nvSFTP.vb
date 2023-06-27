'------------------------------------------------------------------------------
' Descripción:
'   Nueva clase para manejo básico de SFTP (NO confundir con FTPs)
'   Para éstos propósitos se utiliza una librería compilada del proyecto
'   SSH.NET con .NET Framework 4.0 como target
'
'   La librería compilada es "Renci.SshNet.dll" y está en "/Bin"
'
' Historial:
'   07/12/2018; mmeurzet; Creación de la clase para manejo de SFTP básico
'   07/12/2018; mmeurzet; Implementación y correcciones en método List
'   10/12/2018; mmeurzet; Creación método para string de permisos
'   10/12/2018; mmeurzet; Implementación de método Upload
'   10/12/2018; mmeurzet; Implementación de método Download
'   10/12/2018; mmeurzet; Implementación de método DownloadDirectory
'   10/12/2018; mmeurzet; Implementación de método DownloadDirectoryWrapper
'   10/12/2018; mmeurzet; Implementación de método Remove
'   10/12/2018; mmeurzet; Renombrado el nombre de la clase nvSFTP2 => nvSFTP
'
'------------------------------------------------------------------------------
Imports System.IO
Imports Renci.SshNet


Namespace nvFW

    Public Class nvSFTP

        '**********************************************************************
        '
        ' LIST
        '
        '**********************************************************************
        '
        ' Método que retorna el listado de carpetas y archivos a partir de
        ' una ubicación dada como parámetro (RemoteDirectory)
        '
        ' El resultado se devuelve con la estructura tError() dentro del 
        ' parámetro "xml" con la estructura de un archivo XML
        '
        '**********************************************************************

        Private Shared Function getXMLList(ByRef Sftp As SftpClient) As tError
            Dim err_list As New tError()
            Try
                Sftp.Connect()

                Dim files As IEnumerable(Of Sftp.SftpFile) = Sftp.ListDirectory("")
                Dim xml As New StringBuilder("<archivos>")

                For Each file As Sftp.SftpFile In files
                    xml.Append("<archivo>")
                    xml.Append("<FileType>" & IIf(file.IsDirectory, "D", "F") & "</FileType>")
                    xml.Append("<FullName>" & file.FullName & "</FullName>")
                    xml.Append("<Name>" & file.Name & "</Name>")
                    xml.Append("<Length>" & IIf(Not file.IsDirectory, Math.Ceiling(file.Length / 1024) & " Kb", "") & "</Length>")
                    xml.Append("<LastModified>" & file.LastWriteTimeUtc.ToString("dd/MM/yyyy HH:mm:ss") & "</LastModified>")
                    xml.Append("<Permissions>" & GetFilePermissions(file) & "</Permissions>")
                    xml.Append("</archivo>")
                Next

                xml.Append("</archivos>")
                err_list.params("xml") = xml.ToString()
                xml = Nothing

                Sftp.Disconnect()
            Catch ex As Exception
                err_list.parse_error_script(ex)
                err_list.numError = 110
                err_list.titulo = "Error List"
                err_list.mensaje = "No se pudo realizar el listado de archivos"
            End Try

            Return err_list

        End Function

        Public Shared Function List(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteDirectory As String, Optional ByVal pathKeyFile As String = "") As tError
            Dim err As New tError
            err.debug_src = "nvFW.nvSFTP::List"
            err.params("xml") = ""

            If pathKeyFile <> "" Then
                Dim privateKey = New PrivateKeyFile(pathKeyFile)

                Using Sftp As New SftpClient(HostUrl, Username, privateKey)
                    err = getXMLList(Sftp)
                End Using
            Else
                Using Sftp As New SftpClient(HostUrl, Username, Password)
                    err = getXMLList(Sftp)
                End Using
            End If

            Return err
        End Function


        '**********************************************************************
        ' Método auxiliar para formar un string con los permisos de un fichero
        '**********************************************************************
        Private Shared Function GetFilePermissions(ByRef file As Sftp.SftpFile) As String
            Dim permissions As String = ""
            ' Owner
            permissions &= IIf(file.OwnerCanRead, "r", "-")    ' Read
            permissions &= IIf(file.OwnerCanWrite, "w", "-")   ' Write
            permissions &= IIf(file.OwnerCanExecute, "x", "-") ' Execute
            permissions &= " "
            ' Group
            permissions &= IIf(file.GroupCanRead, "r", "-")    ' Read
            permissions &= IIf(file.GroupCanWrite, "w", "-")   ' Write
            permissions &= IIf(file.GroupCanExecute, "x", "-") ' Execute
            permissions &= " "
            ' Others
            permissions &= IIf(file.OthersCanRead, "r", "-")    ' Read
            permissions &= IIf(file.OthersCanWrite, "w", "-")   ' Write
            permissions &= IIf(file.OthersCanExecute, "x", "-") ' Execute

            Return permissions
        End Function


        '**********************************************************************
        '
        ' UPLOAD
        '
        '**********************************************************************
        '
        ' Método para la subida de un archivo especificado por el parámetro
        ' "LocalFilePath" hacia el directorio remoto especificado mediante el 
        ' parámetro "RemoteDirectory"
        '
        '**********************************************************************

        Private Shared Function sftpUpload(ByRef Sftp As SftpClient, ByVal RemoteDirectory As String, ByVal LocalFullPathFile As String) As tError
            Dim err_upload As New tError()

            Try
                Sftp.Connect()

                err_upload.params("file") = LocalFullPathFile

                Using f As FileStream = File.OpenRead(LocalFullPathFile)
                    Sftp.UploadFile(f, IO.Path.Combine(RemoteDirectory, Path.GetFileName(LocalFullPathFile)), True) ' el 3er parámetro es "CanOverwrite" => aquí decimos que lo sobre-escriba
                End Using

                Sftp.Disconnect()
            Catch ex As Exception
                err_upload.parse_error_script(ex)
                err_upload.numError = 111
                err_upload.titulo = "Error Upload"
                err_upload.mensaje = "No fué posible subir el archivo hacia " & RemoteDirectory & ". Exception: " & ex.Message
                err_upload.params("file") = LocalFullPathFile
            End Try

            Return err_upload
        End Function

        Public Shared Function Upload(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteDirectory As String, ByVal LocalFullPathFile As String, Optional ByVal pathKeyFile As String = "") As tError
            Dim err As New tError()
            err.debug_src = "nvFW.nvSFTP::Upload"

            If pathKeyFile <> "" Then
                Dim privateKey = New PrivateKeyFile(pathKeyFile)

                Using Sftp As New SftpClient(HostUrl, Username, privateKey)
                    err = sftpUpload(Sftp, RemoteDirectory, LocalFullPathFile)
                End Using
            Else
                Using Sftp As New SftpClient(HostUrl, Username, Password)
                    err = sftpUpload(Sftp, RemoteDirectory, LocalFullPathFile)
                End Using
            End If

            Return err
        End Function


        '**********************************************************************
        '
        ' DOWNLOAD
        '
        '**********************************************************************
        '
        ' Método para la descarga de un archivo ubicado en el Host localizado
        ' por el parámetro "RemoteFullPathDirectory" y alojarlo en el 
        ' directorio especificado por el parámetro "LocalPathToDownload"
        '
        '**********************************************************************

        Private Shared Function sftpDownload(ByRef Sftp As SftpClient, ByVal RemoteFullPathDirectory As String, ByVal LocalPathToDownload As String) As tError

            Dim err_download As New tError()

            Try
                Sftp.Connect()

                If Not Directory.Exists(LocalPathToDownload) Then
                    Directory.CreateDirectory(LocalPathToDownload)
                End If

                Using fileStream As FileStream = File.OpenWrite(Path.Combine(LocalPathToDownload, Path.GetFileName(RemoteFullPathDirectory)))
                    Sftp.DownloadFile(RemoteFullPathDirectory, fileStream)
                End Using

                Sftp.Disconnect()
            Catch ex As UnauthorizedAccessException
                err_download.numError = 112
                err_download.titulo = "Error Download"
                err_download.mensaje = "No se pudo descargar el fichero porque el acceso fué denegado"
            Catch ex As PathTooLongException
                err_download.numError = 113
                err_download.titulo = "Error Download"
                err_download.mensaje = "El path proporcioando es muy extenso"
            Catch ex As FileNotFoundException
                err_download.numError = 114
                err_download.titulo = "Error Download"
                err_download.mensaje = "No se encontró el fichero: " & Path.GetFileName(RemoteFullPathDirectory)
            Catch ex As Exception
                err_download.parse_error_script(ex)
                err_download.numError = 115
                err_download.titulo = "Error Download"
                err_download.mensaje = "Ocurrió un error al intentar descargar el fichero"
            End Try

            Return err_download

        End Function

        Public Shared Function Download(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteFullPathDirectory As String, ByVal LocalPathToDownload As String, Optional ByVal pathKeyFile As String = "") As tError
            Dim err As New tError
            err.debug_src = "nvFW.nvSFTP::Download"
            err.params("LocalFilePath") = Path.Combine(LocalPathToDownload, Path.GetFileName(RemoteFullPathDirectory))

            If pathKeyFile <> "" Then
                Dim privateKey = New PrivateKeyFile(pathKeyFile)

                Using Sftp As New SftpClient(HostUrl, Username, privateKey)
                    err = sftpDownload(Sftp, RemoteFullPathDirectory, LocalPathToDownload)
                End Using
            Else
                Using Sftp As New SftpClient(HostUrl, Username, Password)
                    err = sftpDownload(Sftp, RemoteFullPathDirectory, LocalPathToDownload)
                End Using
            End If

            Return err
        End Function


        '**********************************************************************
        '
        ' DOWNLOAD BINARIO
        '
        '**********************************************************************
        '
        ' Método para la descarga de un archivo ubicado en el Host localizado
        ' por el parámetro "RemoteFullPathDirectory" y alojarlo en el 
        ' directorio especificado por el parámetro "LocalPathToDownload"
        '
        '**********************************************************************
        Public Shared Function DownloadBinary(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteFullPathDirectory As String) As Byte()
            Dim file As Byte() = Nothing
            Dim streamBinario As IO.MemoryStream = Nothing

            Using Sftp As New SftpClient(HostUrl, Username, Password)
                Try
                    Sftp.Connect()
                    Using ms As New IO.MemoryStream()
                        Sftp.DownloadFile(RemoteFullPathDirectory, ms)

                        If ms.Length > 0 Then
                            file = ms.ToArray()
                        End If
                    End Using

                    Sftp.Disconnect()
                Catch ex As Exception
                End Try
            End Using

            Return file
        End Function


        '**********************************************************************
        '
        ' DOWNLOAD DIRECTORY
        '
        '**********************************************************************
        '
        ' Método para descargar todo el directorio especificado por el
        ' parámetro "RemotePathDirectory" hacia el directorio local
        ' especificado por el parámetro "LocalPathDestination"
        '
        '**********************************************************************
        Public Shared Function DownloadDirectory(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemotePathDirectory As String, ByVal LocalPathDestination As String, Optional ByVal Recursive As Boolean = False) As tError
            Dim err As New tError
            err.debug_src = "nvFW.nvSFTP::DownloadDirectory"

            Using Sftp As New SftpClient(HostUrl, Username, Password)
                Try
                    Sftp.Connect()

                    Dim files As IEnumerable(Of Sftp.SftpFile) = Sftp.ListDirectory(RemotePathDirectory)

                    For Each f As Sftp.SftpFile In files
                        ' Llamo al wrapper con el cliente, el archivo y el directorio local donde se va a descargar
                        DownloadDirectoryWrapper(Sftp, f, LocalPathDestination, Recursive)
                    Next

                    Sftp.Disconnect()
                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.numError = 116
                    err.titulo = "Error Download Directory"
                    err.mensaje = "Ocurrió un error al descargar el directorio: " & RemotePathDirectory
                End Try
            End Using

            Return err
        End Function


        '**********************************************************************
        ' Método wrapper para no instanciar un cliente en cada iteración de 
        ' descarga masiva
        '**********************************************************************
        Private Shared Sub DownloadDirectoryWrapper(ByRef cliente As SftpClient, ByRef f As Sftp.SftpFile, ByVal directory As String, ByVal recursive As Boolean)
            ' Si es archivo => descargar
            If Not f.IsDirectory AndAlso Not f.IsSymbolicLink Then
                ' Chequear que el directorio destino exista
                If Not IO.Directory.Exists(directory) Then
                    IO.Directory.CreateDirectory(directory)
                End If

                Using fileStream As FileStream = File.OpenWrite(Path.Combine(directory, f.Name))
                    cliente.DownloadFile(f.FullName, fileStream)
                End Using
            ElseIf f.Name <> "." AndAlso f.Name <> ".." Then
                ' Si es un directorio
                Dim dir = IO.Directory.CreateDirectory(Path.Combine(directory, f.Name))
                ' Si está indicado que descargue todo recursivamente, re-invocar al método
                If recursive Then
                    DownloadDirectoryWrapper(cliente, f, dir.FullName, recursive)
                End If
            End If
        End Sub


        '**********************************************************************
        '
        ' REMOVE
        '
        '**********************************************************************
        '
        ' Método para eliminar un fichero en el servidor host indicado por el
        ' parámetro "RemoteFullPathFile"
        '
        '**********************************************************************

        Private Shared Function sftpRemove(ByRef Sftp As SftpClient, ByVal RemoteFullPathFile As String) As tError
            Dim err_remove As New tError()

            Try
                Sftp.Connect()

                If Not Sftp.Exists(RemoteFullPathFile) Then
                    err_remove.numError = 117
                    err_remove.titulo = "Error Remove"
                    err_remove.mensaje = "No fué posible eliminar el fichero " & Path.GetFileName(RemoteFullPathFile) & " porque no existe"
                Else
                    Sftp.DeleteFile(RemoteFullPathFile)
                End If

                Sftp.Disconnect()
            Catch ex As Exception
                err_remove.parse_error_script(ex)
                err_remove.numError = 118
                err_remove.titulo = "Error Remove"
                err_remove.mensaje = "Ocurrió un error al intentar eliminar el fichero " & Path.GetFileName(RemoteFullPathFile)
            End Try

            Return err_remove
        End Function

        Public Shared Function Remove(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteFullPathFile As String, Optional ByVal pathKeyFile As String = "") As tError
            Dim err As New tError()
            err.debug_src = "nvFW.nvSFTP::Remove"

            If pathKeyFile <> "" Then
                Dim privateKey = New PrivateKeyFile(pathKeyFile)

                Using Sftp As New SftpClient(HostUrl, Username, privateKey)
                    err = sftpRemove(Sftp, RemoteFullPathFile)
                End Using
            Else
                Using Sftp As New SftpClient(HostUrl, Username, Password)
                    err = sftpRemove(Sftp, RemoteFullPathFile)
                End Using
            End If

            Return err
        End Function




        Public Shared Function CheckBatchFileExists(ByVal HostUrl As String, ByVal Username As String, ByVal Password As String, ByVal RemoteDirectoryDigitalizados As String, ByRef fileNames As List(Of String)) As List(Of String)
            Dim listaFicherosExistentes As New List(Of String)

            If fileNames.Count > 0 Then
                Using Sftp As New SftpClient(HostUrl, Username, Password)
                    Try
                        Sftp.Connect()

                        For Each fileName As String In fileNames
                            If Sftp.Exists(IO.Path.Combine(RemoteDirectoryDigitalizados, fileName)) Then
                                listaFicherosExistentes.Add(fileName)
                            End If
                        Next

                        Sftp.Disconnect()
                    Catch ex As Exception
                    End Try
                End Using
            End If

            Return listaFicherosExistentes
        End Function

    End Class

End Namespace