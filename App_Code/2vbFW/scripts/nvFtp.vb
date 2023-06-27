Imports System.Net.FtpWebRequest
Imports System.Net
Imports System.IO
Imports System.Text.RegularExpressions
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Public Class nvFtp
    Private counter As Integer = 0
    Private _modopasivo As Boolean = False
    Public buffer As Integer = 2048 ''2kb default
    Public timeout As Integer = 8000 ''8 segundos
    Public logdb As Boolean = True
    Private _enablessl As Boolean = False
    Private protocolo As String = "ftp"
    Private urlbase As String = protocolo & "://{host}/{dir}"
    Dim _host, _user, _pass As String
    Private _networkcredential As System.Net.NetworkCredential

    ''eventos para el envio de ficheros
    Public Event onInitSendFiles(ByVal ficheros As List(Of Fileftp))
    Public Event onSendFiles(ByVal ficheros As List(Of Fileftp))
    Public Event onErrorSendFiles(ByVal ficheros As List(Of Fileftp), ByVal err As tError)
    Public Event onFinishSendFiles(ByVal ficheros As List(Of Fileftp))
    ''eventos para la creacion de directorio
    Public Event onInitCreateDir(ByVal directorio As String)
    Public Event onErrorCreateDir(ByVal directorio As String, ByVal err As tError)
    Public Event onCreateDir(ByVal directorio As String)

    ''eventos para eliminar archivos
    Public Event onInitDeleteFile(ByVal fichero As String)
    Public Event onErrorDeleteFile(ByVal fichero As String, ByVal err As tError)
    Public Event onDeleteFile(ByVal fichero As String)

    Public Sub New(ByVal host As String, ByVal user As String, ByVal pass As String, ByVal modopasivo As Boolean, enabledssl As Boolean, Optional protocolo As String = "ftp")
        Me._host = host
        Me._user = user
        Me._pass = pass
        Me.protocolo = protocolo
        Me.urlbase = protocolo & "://{host}/{dir}"
        Me.urlbase = Me.urlbase.Replace("{host}", host)
        Me._networkcredential = New NetworkCredential(user, pass)
        Me._enablessl = enabledssl
        Me._modopasivo = modopasivo
    End Sub

    Public ReadOnly Property networkcredential() As NetworkCredential
        Get
            Return _networkcredential
        End Get
    End Property
    Public ReadOnly Property host() As String
        Get
            Return _host
        End Get
    End Property

    Public Function eliminarFichero(ByVal fichero As String) As tError
        If (fichero.IndexOf("ftp://") < 0) Then
            fichero = "ftp://" & fichero
        End If
        Dim err = New tError
        Dim peticionFTP As FtpWebRequest

        ' Creamos una petición FTP con la dirección del fichero a eliminar
        peticionFTP = CType(WebRequest.Create(New Uri(fichero)), FtpWebRequest)
        peticionFTP.Timeout = Me.timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = Me._networkcredential  ''New NetworkCredential(user, pass)
        ' Seleccionamos el comando que vamos a utilizar: Eliminar un fichero
        peticionFTP.Method = WebRequestMethods.Ftp.DeleteFile
        peticionFTP.UsePassive = Me._modopasivo
        peticionFTP.EnableSsl = Me._enablessl
        RaiseEvent onInitDeleteFile(fichero)
        Try
            Dim respuestaFTP As FtpWebResponse
            respuestaFTP = CType(peticionFTP.GetResponse(), FtpWebResponse)
            respuestaFTP.Close()
            RaiseEvent onDeleteFile(fichero)
        Catch ex As Exception
            ' Si se produce algún fallo, se devolverá el mensaje del error
            err.parse_error_script(ex)
            RaiseEvent onErrorDeleteFile(fichero, err)
        End Try
        Return err
    End Function
    ''directory, debe ser sin barra invertida al final ej ftp://10.10.10.1:21/folder
    Public Function existeFolder(ByVal directory As String) As Boolean

        If (directory <> "") Then
            directory = directory.Replace("\", "/")
            ''elimino la ultima barra en caso de q la traiga
            If (directory.Substring(directory.Length - 1) = "/") Then
                directory = directory.Substring(0, directory.Length - 1)
            End If
        End If
        If (directory.IndexOf(Me.protocolo & "://") < 0) Then
            directory = Me.protocolo & "://" & Me.host & "/" & directory
        End If
        Dim sinprotocolo As String = directory.Replace(Me.protocolo & "://", "")
        directory = Me.protocolo & "://" & sinprotocolo.Replace("//", "/")


        Dim peticionFTP As FtpWebRequest
        ' Creamos una peticion FTP con la dirección del objeto que queremos saber si existe
        peticionFTP = CType(WebRequest.Create(New Uri(directory)), FtpWebRequest)
        peticionFTP.Timeout = Me.timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = _networkcredential  ''New NetworkCredential(user, pass)
        ' Para saber si el objeto existe, solicitamos el listado de directorios, si existe, es porq la carpeta existe
        peticionFTP.Method = WebRequestMethods.Ftp.ListDirectory
        peticionFTP.UsePassive = Me._modopasivo
        peticionFTP.EnableSsl = Me._enablessl

        Try
            ' Si el objeto existe, se devolverá True
            Dim respuestaFTP As FtpWebResponse
            respuestaFTP = CType(peticionFTP.GetResponse(), FtpWebResponse)
            Return True
        Catch ex As Exception
            ' Si el objeto no existe, se producirá un error y al entrar por el Catch
            ' se devolverá falso
            Return False
        End Try
    End Function

    Public Function existeFile(ByVal file As String) As Boolean

        If (file.IndexOf(Me.protocolo & "://") < 0) Then
            file = Me.protocolo & "://" & Me.host & "/" & file
        End If
        Dim peticionFTP As FtpWebRequest
        ' Creamos una peticion FTP con la dirección del objeto que queremos saber si existe
        peticionFTP = CType(WebRequest.Create(New Uri(file)), FtpWebRequest)
        peticionFTP.Timeout = Me.timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = _networkcredential  ''New NetworkCredential(user, pass)
        ' Para saber si el objeto existe, solicitamos la fecha de creación del mismo
        peticionFTP.Method = WebRequestMethods.Ftp.GetFileSize
        peticionFTP.UsePassive = Me._modopasivo
        peticionFTP.EnableSsl = Me._enablessl

        Try
            ' Si el objeto existe, se devolverá True
            Dim respuestaFTP As FtpWebResponse
            respuestaFTP = CType(peticionFTP.GetResponse(), FtpWebResponse)
            Return True
        Catch ex As Exception
            ' Si el objeto no existe, se producirá un error y al entrar por el Catch
            ' se devolverá falso
            Return False
        End Try
    End Function

    Public Function directorioActual() As String

        Dim directorio As String = ""
        Dim urlftp = Me.urlbase.Replace("{dir}", "")
        Dim respuestaFTP As FtpWebResponse
        Dim peticionFTP As FtpWebRequest
        ' Creamos una peticion FTP con la dirección del objeto que queremos saber si existe
        peticionFTP = CType(WebRequest.Create(New Uri(urlftp)), FtpWebRequest)
        peticionFTP.Timeout = Me.timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = _networkcredential  ''New NetworkCredential(user, pass)
        ' Para saber si el objeto existe, solicitamos la fecha de creación del mismo
        peticionFTP.Method = WebRequestMethods.Ftp.PrintWorkingDirectory
        peticionFTP.UsePassive = Me._modopasivo
        peticionFTP.EnableSsl = Me._enablessl
        Try
            ' Si el objeto existe, se devolverá True
            Dim response = peticionFTP.GetResponse()
            respuestaFTP = CType(response, FtpWebResponse)
            Dim partes = respuestaFTP.StatusDescription.Split("""")
            directorio = partes(1)
        Catch ex As Exception
        End Try
        Return directorio
    End Function

    Public Function testConexion(Optional ByRef err As tError = Nothing) As Boolean

        Dim exito As Boolean = False
        Dim urlftp = Me.urlbase.Replace("{dir}", "")
        Dim respuestaFTP As FtpWebResponse
        Dim peticionFTP As FtpWebRequest
        ' Creamos una peticion FTP con la dirección del objeto que queremos saber si existe
        peticionFTP = CType(WebRequest.Create(New Uri(urlftp)), FtpWebRequest)
        peticionFTP.Timeout = Me.timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = _networkcredential  ''New NetworkCredential(user, pass)
        ' Para saber si el objeto existe, solicitamos la fecha de creación del mismo
        peticionFTP.Method = WebRequestMethods.Ftp.PrintWorkingDirectory
        peticionFTP.UsePassive = Me._modopasivo
        peticionFTP.EnableSsl = Me._enablessl
        Try
            ' Si el objeto existe, se devolverá True
            Dim response = peticionFTP.GetResponse()
            respuestaFTP = CType(response, FtpWebResponse)
            err.mensaje = respuestaFTP.WelcomeMessage
            exito = True
        Catch ex As Exception
            If (err IsNot Nothing) Then
                err.parse_error_script(ex)
            End If
        End Try
        Return exito
    End Function
    ''urldir es un path absoluto ej ftp://host:21/carpeta/subcarpeta
    ''luego el algorimo borra la ultima carpeta y se posiciona ahi para buscar
    Public Function existeDirectorio(ByVal urldir As String, Optional ByRef err As tError = Nothing) As Boolean
        'Dim basePath As String = Me.urlbase.Replace("{dir}", "")
        Dim existe As Boolean = False
        Dim carpetaabuscar As String = ""
        Dim carpetapadre As String = ""
        'Dim urldirectoriosbase As String = urldir.Replace(basePath, "") ''quito la urlbase de la estructura (si es q la tiene)

        'Dim folders As String = urldirectoriosbase.Replace("\", "/").Replace("//", "/")
        'If (folders.Substring(0, 1) = "/") Then
        '    folders = folders.Substring(1, folders.Length - 1)
        'End If
        Dim folders As String = getfolderswithouthost(urldir)
        ''carpetas, puede haber 0,1,2 o mas  
        Dim partes = folders.Split("/")
        ''la url o tiene dos carpetas o solamente tiene una carpeta, es esa la q hay q  buscar
        If (partes.Length > 1) Then
            If (partes(partes.Length - 1) = "") Then
                carpetaabuscar = partes(partes.Length - 2)
                carpetapadre = ""
            Else
                carpetaabuscar = partes(partes.Length - 1)
                For i = 0 To partes.Length - 2
                    If (carpetapadre = "") Then
                        carpetapadre = partes(i)
                    Else
                        carpetapadre = carpetapadre & "/" & partes(i)
                    End If
                Next
            End If
        Else
            carpetaabuscar = folders
        End If

        Dim listado As New List(Of ElementFtp)
        err = Me.Listar(Me.urlbase.Replace("{dir}", carpetapadre), listado)
        If (err.numError <> 0) Then
            err.titulo = "Error al listar archivos " & err.titulo
            Return False
        End If

        ''verifico si el objeto esta en e listado de archivos obtenidos
        For Each l In listado
            If (l.Name.ToUpper() = carpetaabuscar.ToUpper() And l.Type = "DIR") Then
                existe = True
                Exit For
            End If
        Next
        Return existe
    End Function


    ''dado el nombre del directorio, lista los objetos que hay alli
    Public Function Listar(ByVal dir As String, ByRef Files As List(Of ElementFtp)) As tError
        ''parametro dir:acepta como parametro ftp://XX:XX:XX.XX , folder1/subfolder, o si es vacio, toma la urlbase
        Dim basepath As String = Me.urlbase.Replace("{dir}", "")
        Dim err As New tError
        ''si es vacio, es porque se esta consultando por los archivos desde raiz
        If (dir = "") Then
            dir = Me.urlbase.Replace("{dir}", "")
        Else
            ''verifico primero si el parametro dir tiene un nombre de archivo para eliminar
            Dim filename = Me.getfilename(dir)
            If (filename <> "") Then
                dir = dir.Replace(filename, "")
            End If
            ''elimino el host del string asi me quedan solamente los folder del ftp
            'Dim foldershost As String = dir.Replace(basepath, "").Replace("\", "/")
            '''suprimo la barra inicial si es que la tiene
            'If (foldershost.Substring(0, 1) = "/") Then
            '    dir = foldershost.Substring(1, dir.Length - 1)
            'End If
            dir = getfolderswithouthost(dir)
            dir = Me.urlbase.Replace("{dir}", dir)
        End If
        Try
            Dim peticionFTP As FtpWebRequest
            ' Creamos una peticion FTP con la dirección del objeto que queremos saber si existe
            peticionFTP = CType(WebRequest.Create(New Uri(dir)), FtpWebRequest)
            peticionFTP.Timeout = Me.timeout
            ' Fijamos el usuario y la contraseña de la petición
            peticionFTP.Credentials = _networkcredential  '' New NetworkCredential("BancoVoii", "V0iib4#c0")
            ' Para saber si el objeto existe, solicitamos la fecha de creación del mismo
            peticionFTP.Method = WebRequestMethods.Ftp.ListDirectoryDetails
            'peticionFTP.Method = WebRequestMethods.Ftp.ListDirectoryDetails
            peticionFTP.UsePassive = True ''para consultas TRUE
            peticionFTP.EnableSsl = Me._enablessl
            ''peticionFTP.UseBinary = False
            ' Si el objeto existe, se devolverá True
            Dim response = peticionFTP.GetResponse()
            Dim responseStream As Stream = response.GetResponseStream
            Using reader As New StreamReader(responseStream)
                While reader.Peek <> -1
                    Dim filedatastring As String = reader.ReadLine()
                    Dim ele As New ElementFtp
                    ele.Load(filedatastring)
                    Files.Add(ele)
                End While
            End Using
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Host " & dir
        End Try
        Return err
    End Function


    Public Function borrarArchivo(ByVal remoteFilePath As String) As tError

        Dim err As New tError()

        Dim basepath As String = Me.urlbase.Replace("{dir}", "")
        ''si es vacio, es porque se esta consultando por los archivos desde raiz
        If (remoteFilePath = "") Then
            err.numError = -1
            err.mensaje = "Uno de los parametros es vacio."
            Return err
        Else
            ''elimino el host del string asi me quedan solamente los folder del ftp
            'Dim foldershost As String = dir.Replace(basepath, "").Replace("\", "/")
            '''suprimo la barra inicial si es que la tiene
            'If (foldershost.Substring(0, 1) = "/") Then
            '    dir = foldershost.Substring(1, dir.Length - 1)
            'End If
            remoteFilePath = getfolderswithouthost(remoteFilePath)
            remoteFilePath = Me.urlbase.Replace("{dir}", remoteFilePath)
        End If

        Dim peticionFTP As FtpWebRequest
        peticionFTP = CType(WebRequest.Create(New Uri(remoteFilePath)), FtpWebRequest)
        peticionFTP.Method = WebRequestMethods.Ftp.DeleteFile
        peticionFTP.Credentials = _networkcredential

        Try
            Dim response As FtpWebResponse = CType(peticionFTP.GetResponse(), FtpWebResponse)

            If response.StatusCode <> 250 Then
                err.numError = -2
                err.mensaje = "Error al borrar archivo."
                err.debug_desc = response.StatusDescription
            End If
            response.Close()
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        Return err
    End Function


    Public Function descargarArchivo(ByVal remoteFilePath As String, ByVal localPath As String, Optional ByVal deleteFile As Boolean = False) As tError

        Dim err As New tError()

        If Not Me.existeFile(remoteFilePath) Then
            err.numError = -3
            err.mensaje = "El archivo solicitado no existe."
            Return err
        End If

        Dim basepath As String = Me.urlbase.Replace("{dir}", "")
        ''si es vacio, es porque se esta consultando por los archivos desde raiz
        If (remoteFilePath = "" OrElse localPath = "") Then
            err.numError = -1
            err.mensaje = "Uno de los parametros es vacio."
            Return err
        Else
            ''elimino el host del string asi me quedan solamente los folder del ftp
            'Dim foldershost As String = dir.Replace(basepath, "").Replace("\", "/")
            '''suprimo la barra inicial si es que la tiene
            'If (foldershost.Substring(0, 1) = "/") Then
            '    dir = foldershost.Substring(1, dir.Length - 1)
            'End If
            remoteFilePath = getfolderswithouthost(remoteFilePath)
            remoteFilePath = Me.urlbase.Replace("{dir}", remoteFilePath)
        End If

        Dim peticionFTP As FtpWebRequest
        peticionFTP = CType(WebRequest.Create(New Uri(remoteFilePath)), FtpWebRequest)
        peticionFTP.Method = WebRequestMethods.Ftp.DownloadFile
        peticionFTP.Credentials = _networkcredential

        Try
            Dim response As FtpWebResponse = CType(peticionFTP.GetResponse(), FtpWebResponse)
            Dim responseStream As Stream = response.GetResponseStream()
            'Dim reader As StreamReader = New StreamReader(responseStream)
            Dim file As New FileStream(localPath, FileMode.OpenOrCreate, FileAccess.Write)
            responseStream.CopyTo(file)
            'reader.Close()
            responseStream.Dispose()
            file.Dispose()
            response.Close()

            If deleteFile = True Then
                err = borrarArchivo(remoteFilePath)
            End If
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        Return err
    End Function

    Public Function crearDirectorio(ByVal dir As String) As tError

        Dim err = New tError
        Dim peticionFTP As FtpWebRequest
        RaiseEvent onInitCreateDir(dir)
        ' Creamos una peticion FTP con la dirección del directorio que queremos crear
        peticionFTP = CType(WebRequest.Create(New Uri(dir)), FtpWebRequest)
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = _networkcredential  ''New NetworkCredential(user, pass)

        ' Seleccionamos el comando que vamos a utilizar: Crear un directorio

        peticionFTP.Method = WebRequestMethods.Ftp.MakeDirectory
        peticionFTP.EnableSsl = Me._enablessl
        peticionFTP.Timeout = Me.timeout

        'peticionFTP.UsePassive = True
        'peticionFTP.UseBinary = True
        'peticionFTP.KeepAlive = False
        Try
            Dim respuesta As FtpWebResponse
            respuesta = CType(peticionFTP.GetResponse(), FtpWebResponse)
            respuesta.Close()
            RaiseEvent onCreateDir(dir)
        Catch ex As Exception
            ' Si se produce algún fallo, se devolverá el mensaje del error
            err.parse_error_script(ex)
            RaiseEvent onErrorCreateDir(dir, err)
        End Try
        Return err
    End Function

    Private Function getfolderswithouthost(ByVal dir As String) As String
        Dim basePath As String = Me.urlbase.Replace("{dir}", "")
        If (dir = "") Then
            Return dir
        End If
        Dim folders As String = dir.Replace(basePath, "").Replace("\", "/").Replace("//", "/")
        If (folders.Length > 1) Then
            If (folders.Substring(0, 1) = "/") Then
                folders = folders.Substring(1, folders.Length - 1)
            End If
        Else
            If (folders = "/") Then
                folders = ""
            End If
        End If

        Return folders
    End Function
    ''dada una ruta de red o path local, obtiene el nombre de la ultima carpeta de la cadena
    Public Function getfoldername(ByVal pathdir As String) As String
        If (pathdir.Contains("/")) Then
            pathdir = pathdir.Replace("/", "\")
        End If
        If (pathdir.Contains("\\\\")) Then
            pathdir = pathdir.Replace("\\", "\")
        End If
        Dim patternred As String = "^\\\\([A-Za-z0-9\-._]+\\)" ''patron de unidad de red ej: \\platon\ , \\127.0.1.1\
        Dim patternlocal As String = "^([A-Za-z]{1}:\\)" ''patron de unidad de disco ej.: D:\ , C:\
        Dim folderwithoutroot As String = ""
        If (Regex.IsMatch(pathdir, patternred)) Then
            folderwithoutroot = Regex.Replace(pathdir, patternred, "", System.Text.RegularExpressions.RegexOptions.None)
        End If
        If (Regex.IsMatch(pathdir, patternlocal)) Then
            folderwithoutroot = Regex.Replace(pathdir, patternlocal, "", System.Text.RegularExpressions.RegexOptions.None)
        End If
        If (folderwithoutroot <> "") Then
            Dim partes = folderwithoutroot.Split("\")
            If (partes.Length > 1) Then
                If (partes(partes.Length - 1) = "") Then
                    folderwithoutroot = partes(partes.Length - 2)
                Else
                    folderwithoutroot = partes(partes.Length - 1)
                End If
            End If
        End If
        Return folderwithoutroot
    End Function
    Public Function crearDirectorioSiNoExiste(ByVal dir As String) As tError

        Dim err As New tError
        Dim folders = getfolderswithouthost(dir)
        If (dir = "" Or folders = "") Then
            err.numError = 1
            err.mensaje = "No se puede crear un directorio vacio"
            Return err
        End If
        'Dim basePath As String = Me.urlbase.Replace("{dir}", "")
        'Dim folders As String = dir.Replace(basePath, "").Replace("\", "/").Replace("//", "/")
        'If (folders.Substring(0, 1) = "/") Then
        '    folders = folders.Substring(1, folders.Length - 1)
        'End If

        Dim existe As Boolean = Me.existeDirectorio(folders, err)
        ''existe la carpeta, no creo nada
        If (existe) Then
            Return err
        End If
        ''si no existe evaluo la existencia de las otras carpetas
        Dim carpetas = folders.Split("/")
        ''si llego a la raiz y no existe la carpeta, la creo
        If (carpetas.Length <= 1) Then
            err = crearDirectorio(Me.urlbase.Replace("{dir}", folders))
            Return err
        End If
        Dim parentfolder As String = ""
        For f As Integer = 0 To carpetas.Length - 2
            parentfolder &= "/" & carpetas(f)
        Next
        existe = Me.existeDirectorio(parentfolder, err)
        If Not (existe) Then
            err = crearDirectorioSiNoExiste(parentfolder)
            ''si pudo crear las carpetas padre, creo esta carpeta
            If (err.numError = 0) Then
                err = crearDirectorio(Me.urlbase.Replace("{dir}", folders))
            End If
        Else
            ''si existe el parentfolder, creo la carpeta
            err = crearDirectorio(Me.urlbase.Replace("{dir}", folders))
        End If
        Return err
    End Function

    ''files: listado de archivos a enviar
    ''directorioremoto: es la carpeta donde van a ir a parar los archivos en el servidor ftp
    ''deletefiles: una vez que se hayan enviado, se eliminand del directorio local
    Public Function subirFicheros(ByVal files As List(Of Fileftp), ByVal directorioRemoto As String, Optional ByVal deletefiles As Boolean = False, Optional ByVal nro_proceso As Integer = 0, Optional patronfile As Pattern = Nothing) As tError
        Dim err As New tError
        Dim basepath As String = Me.urlbase.Replace("{dir}", "")
        RaiseEvent onInitSendFiles(files)

        Try
            If (Me.logdb) Then                 
                If (nro_proceso > 0) Then
                    Dim rs = nvDBUtiles.DBOpenRecordset("select * from ftp_log_cab where nro_proceso=" & CStr(nro_proceso))
                    If Not (rs.RecordCount > 0) Then ''s si no existe el proceso, lo agrego, sino continuo con el resto de los archivos
                        nvDBUtiles.DBExecute("insert into ftp_log_cab (nro_proceso,estado,fe_inicio,fe_estado) values(" & CStr(nro_proceso) & ",'P',getdate(),getdate())")
                    End If
                End If

            End If

            Dim foldershost = getfolderswithouthost(directorioRemoto)
            ''obtengo el nombre de la carpeta que lo va a alojar para ver si existe el directorio, si no existe, lo creo
            Dim uriDir As String
            uriDir = Me.urlbase.Replace("{dir}", foldershost)
            ' Si no existe el directorio, lo creamos
            If (uriDir <> "" And foldershost <> "") Then
                'If Not existeDirectorio(uriDir, err) And err.numError = 0 Then
                '    err = crearDirectorio(uriDir)
                'End If
                err = crearDirectorioSiNoExiste(uriDir)
            End If
            '' si no hay carpeta a enviar, limpio la url del host, porque va a parar a la raiz
            If (foldershost = "") Then
                uriDir = Me.urlbase.Replace("/{dir}", "")
            End If
            ''devuelvo el error por si hubo problemas al crear directorio
            If (err.numError <> 0) Then
                Return err
            End If
            Dim enviados As Integer = 0
            For Each f In files
                If (Me.logdb) Then
                    Dim rs = nvDBUtiles.DBOpenRecordset("select * from ftp_log where nro_proceso=" & CStr(nro_proceso) & " and archivo='" & f.localfilepath & "'")
                    If (rs.RecordCount = 0) Then
                        nvDBUtiles.DBExecute("insert into ftp_log (fecha,archivo,host,nro_proceso,id) values(getdate(),'" & f.localfilepath & "','" & Me.host & "'," & CStr(nro_proceso) & ",'" & f.id & "')")
                    Else
                        nvDBUtiles.DBExecute("delete from  ftp_log_parametros where nro_proceso=" & CStr(nro_proceso) & " and archivo='" & f.localfilepath & "'")
                    End If

                    If (patronfile IsNot Nothing) Then
                        For Each kvp As KeyValuePair(Of Integer, String) In patronfile._groups
                            Dim keyname As String = kvp.Value
                            Dim valor As String = patronfile.getvalue(cad:=f.localfilepath, namegroup:=keyname)
                            nvDBUtiles.DBExecute("insert into ftp_log_parametros (archivo,nro_proceso,parametro,valor) values('" & f.localfilepath & "'," & CStr(nro_proceso) & ", '" & keyname & "','" & valor & "')")
                        Next
                    End If

                End If
                f.send(uriDir:=uriDir, _ftp:=Me)
                If (Me.logdb) Then
                    Dim enviado As Integer = IIf(f.enviado, 1, 0)
                    Dim errordesc As String = f.tError.titulo & " - " & " " & f.tError.mensaje & f.tError.debug_desc
                    Dim observaciones As String = IIf(f.enviado, "", errordesc)
                    ''nvDBUtiles.DBExecute("update ftp_log set fe_enviado=getdate(),obs='" & observaciones & "',destino='" & f.destino & "',miliseconds=" & CStr(f.milisecond) & " where archivo='" & f.localfilepath & "' and nro_proceso=" & CStr(nro_proceso))
                    Dim strSql = "update ftp_log set fe_enviado=getdate(),obs=?,destino='" & f.destino & "',miliseconds=" & CStr(f.milisecond) & " where archivo='" & f.localfilepath & "' and nro_proceso=" & CStr(nro_proceso)
                    Dim cmd As New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                    Dim observacion = cmd.CreateParameter("@observacion", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, observaciones)
                    cmd.Parameters.Append(observacion)
                    cmd.Execute()
                    cmd = Nothing
                End If
                '' si esta habilitado para eliminar, se elimina una vez enviado
                If (deletefiles And f.tError.numError = 0 And f.enviado = True) Then
                    Try
                        System.IO.File.Delete(f.localfilepath)
                    Catch ex As Exception
                    End Try
                End If
                If (f.enviado) Then
                    enviados += 1
                End If
                RaiseEvent onSendFiles(files)

            Next
            If (nro_proceso > 0 And Me.logdb) Then
                Dim strobs = CStr(enviados) & " archivos enviados de " & files.Count
                nvDBUtiles.DBExecute("update ftp_log_cab set fe_estado=getdate(), estado='T',obs='" & strobs & "' where nro_proceso=" & CStr(nro_proceso))
            End If
            RaiseEvent onFinishSendFiles(files)
        Catch ex As Exception
            If (nro_proceso > 0 And Me.logdb) Then
                Dim strSql = "update ftp_log_cab set fe_estado=getdate(), estado='X',obs=? where nro_proceso=" & CStr(nro_proceso)
                Dim cmd As New nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText)
                Dim observacion = cmd.CreateParameter("@observacion", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, ex.Message)
                cmd.Parameters.Append(observacion)
                cmd.Execute()
                cmd = Nothing
            End If
            ' Si se produce algún fallo, se devolverá el mensaje del error
            err.parse_error_script(ex)
            RaiseEvent onErrorSendFiles(files, err)
        End Try
        'If (Me.logdb) Then
        '    nvDBUtiles.DBDesconectar()
        'End If
        Return err
    End Function

    ''directoriolocal: path de la carpeta donde se encuentran los archivos a enviar
    ''directorio remoto: es el directorio en el servidor ftp donde van a ir a parar los archivos (si el mismo no existe, se crea siempre y cuando el usuario tenga los permisos necesario)
    ''mantenercarpetaorigen: si esto es true, en el directorioremoto los archivos se van a guardar en una carpeta con el mismo nombre que 'directoriolocal'
    ''deletefiles: si es true, al enviar cada archivo, se intenta eliminar del directorio local
    Public Function enviarCarpeta(ByVal directoriolocal As String, ByVal directorioremoto As String, Optional ByVal mantenercarpetaorigen As Boolean = False, Optional ByVal deletefiles As Boolean = False, Optional ByVal eventInitSend As Fileftp.onInitSendFileEventHandler = Nothing, Optional ByVal eventSendFile As Fileftp.onSendFileEventHandler = Nothing, Optional ByVal eventFinishFile As Fileftp.onFinishSendFileEventHandler = Nothing, Optional ByVal eventErrorSendFile As Fileftp.onErrorSendFileEventHandler = Nothing, Optional ByVal nro_proceso As Integer = 0, Optional ByVal patron As Pattern = Nothing) As tError

        Dim err As New tError
        Dim files = System.IO.Directory.GetFiles(directoriolocal)
        If (files.Length = 0) Then
            err.numError = 1
            err.mensaje = "No hay archivos en la carpeta " & directoriolocal
            Return err
        End If
        Dim cola As New List(Of Fileftp)
        For Each f In files
            Dim archivo As New Fileftp(f)
            archivo.id = getuid()
            If (eventInitSend IsNot Nothing) Then
                AddHandler archivo.onInitSendFile, eventInitSend
            End If
            If (eventSendFile IsNot Nothing) Then
                AddHandler archivo.onSendFile, eventSendFile
            End If

            If (eventFinishFile IsNot Nothing) Then
                AddHandler archivo.onFinishSendFile, eventFinishFile
            End If
            If (eventErrorSendFile IsNot Nothing) Then
                AddHandler archivo.onErrorSendFile, eventErrorSendFile
            End If
            cola.Add(archivo)
        Next

        If (mantenercarpetaorigen) Then
            'Dim folders = directoriolocal.Split("\")
            Dim folder As String = Me.getfoldername(directoriolocal)
            'If (folders.Length > 1) Then
            '    folder = folders(folders.Length - 1)
            'Else
            '    folder = directoriolocal
            'End If
            directorioremoto = directorioremoto & "/" & folder ''hago esto para que me tome el nombre de la carpeta, sino , toma la carpeta anterior
        End If
        If (cola.Count > 0) Then
            err = Me.subirFicheros(files:=cola, directorioRemoto:=directorioremoto, deletefiles:=deletefiles, patronfile:=patron, nro_proceso:=nro_proceso)
        Else
            err.numError = 1
            err.mensaje = "No hay archivos en la cola de la carpeta " & directoriolocal
        End If

        err.params("obs") = CStr(files.Count) & "archivos  encontrados . Directorio remoto " & directorioremoto
        Return err
    End Function

    ''dado una url, obtengo el nombre del archivo a partir del macheo de la exp regular
    Public Function getfilename(ByVal cadena As String) As String
        Dim ret As String = ""
        ''si no tiene barras invertidas, que no evalue
        If (cadena.IndexOf("/") = -1 And cadena.IndexOf("\") = -1) Then
            Return ret
        End If
        cadena = cadena.Replace("//", "\")
        cadena = cadena.Replace("\\", "\")
        Dim filename As String = System.IO.Path.GetFileNameWithoutExtension(cadena)
        Dim ext As String = System.IO.Path.GetExtension(cadena)
        If (filename <> "" And ext <> "") Then
            ret = filename & ext
        End If

        Return ret

    End Function

    Public ReadOnly Property modopasivo As Boolean
        Get
            Return Me._modopasivo
        End Get
    End Property
    Public ReadOnly Property enablessl As Boolean
        Get
            Return Me._enablessl
        End Get
    End Property

    Public ReadOnly Property credenciales As NetworkCredential
        Get
            Return Me._networkcredential
        End Get
    End Property
    Private Function getuid() As String
        counter += 1
        Dim uid As String = Format(DateAndTime.Now, "yyyyMMddHHmmss").ToString & counter.ToString
        Return uid
    End Function

End Class

Public Class ElementFtp
    Public DateModify As String = ""
    Public Type As String = "KNOW"
    Public Name As String = ""
    Public DataResponse As String = ""
    Public Bytes As Long = 0
    Public Sub Load(ByVal cadena As String)

        Me.DataResponse = cadena
        Dim regftpformatstring As String = "\s(ftp)\s(ftp)\s" ''machea ' ftp ftp '
        Dim mftpformastring As Match = Regex.Match(cadena, regftpformatstring, RegexOptions.IgnoreCase)
        If (mftpformastring.Success) Then
            ''para formatos
            '-rw-r--r-- 1 ftp ftp        1752894 Jun 15 09:03 test4.txt"
            'drwxr-xr-x 1 ftp ftp              0 Jun 08 10:02 venta 20210606"
            'drwxr-xr-x 1 ftp ftp              0 Sep 28 14:38 Comprobantes
            Dim mextension1 As Match = Regex.Match(cadena, "([.][A-Za-z]{1,4})", RegexOptions.IgnoreCase) ''solo busco si la cadena tiene extension
            cadena = cadena.Substring(mftpformastring.Index + 9)
            ''Dim regfechahora1 As String = "([A-Za-z]{3})\s(0[1-9]|[12][0-9]|3[01])\s((0[0-9]|1[012])[:](0[0-9]|[012345][0-9]))" ''busca mes dia hh:mm
            ''busca patron, mes dia hh:mm para partir desde ahi, hacia adelante y tomar lo q queda solo para determinar si es archivo o carpeta
            Dim regfechahora1 As String = "([A-Za-z]{3})\s(0[1-9]|[12][0-9]|3[01])\s((0[0-9]|1[0-9]|2[123])[:](0[0-9]|[012345][0-9]))"
            Dim mfechahora1 As Match = Regex.Match(cadena, regfechahora1, RegexOptions.IgnoreCase)
            If (mfechahora1.Success) Then
                Me.DateModify = mfechahora1.Value
                cadena = cadena.Replace(mfechahora1.Value, "|")
                Dim partes = cadena.Split("|")
                If (partes.Length = 2) Then
                    Me.Bytes = CInt(partes(0).Trim())
                    Me.Name = partes(1).Trim()
                    If (mextension1.Success) Then
                        Me.Type = "FILE"
                    Else
                        Me.Type = "DIR"
                    End If
                End If
            End If
        Else
            Dim regfechahora As String = "((0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])[- /.]\d{2})\s\s((0[0-9]|1[012])[:](0[0-9]|[012345][0-9])(AM|PM))" ''machea con mm-dd-yy hh:mm(AM|PM)
            Dim mfechahora As Match = Regex.Match(cadena, regfechahora, RegexOptions.IgnoreCase)
            Dim mdir As Match = Regex.Match(cadena, "(<DIR>)", RegexOptions.IgnoreCase)
            If (mdir.Success And mfechahora.Success) Then
                'por aca , tiene formato
                '"06-10-21  04:16PM       <DIR>          unionsolidaria"
                If (mfechahora.Success) Then
                    Me.DateModify = mfechahora.Value
                End If
                If (mdir.Success) Then
                    Me.Type = "DIR"
                End If
                Me.Name = cadena.Replace("<DIR>", "").Replace(mfechahora.Value, "").Trim()
            End If
            Dim mextension As Match = Regex.Match(cadena, "([.][A-Za-z]{1,4})", RegexOptions.IgnoreCase) ''solo busco si la cadena tiene extension
            Dim mbytes As Match = Regex.Match(cadena, " (\s\d+\s)", RegexOptions.IgnoreCase) ''solo busco un numero entero que tenga al menos un espacio antes y despues, con eso determino q es un numero de tamaño
            If (Not (mdir.Success) And mfechahora.Success And mextension.Success) Then
                If (mbytes.Success) Then
                    Me.Bytes = CInt(mbytes.Value.Trim())
                End If
                Me.DateModify = mfechahora.Value
                Me.Type = "FILE"
                'por aca , tiene formato
                '"06-16-21  11:58AM                 6129 test1.txt"
                Me.Name = cadena.Replace(mbytes.Value, "").Replace(mfechahora.Value, "").Trim()
            End If
        End If



    End Sub
    ''si es un path, devuelve vacio
    Public Function GetFileName(ByVal strpath As String) As String
        Dim ext = System.IO.Path.GetExtension(strpath)
        If (ext = "") Then
            Return ""
        End If
        Return System.IO.Path.GetFileName(strpath)
    End Function
End Class

Public Class Fileftp
    Private _err As New tError
    Private _id As String = ""
    Private _localfilepath As String = ""
    Private _enviado As Boolean = False
    Private _destino As String = "" ''carpeta en ftp
    Private _milisecond As Long = 0
    Private _bytessended As Long = 0
    Private _infoFichero As FileInfo
    Private _errormessage As String = ""
    Private _filename As String = "" ''si bien toma el nombre del archivo actual por defecto, el mismo se puede cambiar
    Private _ftp As nvFtp
    Private _buffer As Integer = 2048
    Private _Timeout As Integer = 8000 ''segundos
    ''eventos para el envio de ficheros
    Public Event onInitSendFile(ByVal file As Fileftp)
    Public Event onSendFile(ByVal file As Fileftp)
    Public Event onErrorSendFile(ByVal file As Fileftp)
    Public Event onFinishSendFile(ByVal file As Fileftp)

    Public Sub New(ByVal localfilepath As String)
        Me._filename = System.IO.Path.GetFileName(localfilepath)
        Me._localfilepath = localfilepath
        Me._infoFichero = New FileInfo(localfilepath)
    End Sub


    ''uridir, es el directorio donde va  a para (se supone que esta creado con anterioridad
    Public Function send(ByVal uriDir As String, ByVal _ftp As nvFtp, Optional ByVal nro_proceso As Integer = 0) As tError
        Me._ftp = _ftp
        Dim err As New tError
        Dim dateini = DateTime.Now()
        RaiseEvent onInitSendFile(Me)
        Dim destinoRemoto As String = uriDir & "/" & Me._filename
        Dim peticionFTP As FtpWebRequest

        ' Creamos una peticion FTP con la dirección del fichero que vamos a subir
        peticionFTP = CType(FtpWebRequest.Create(New Uri(destinoRemoto)), FtpWebRequest)
        peticionFTP.Timeout = Me._Timeout
        ' Fijamos el usuario y la contraseña de la petición
        peticionFTP.Credentials = Me._ftp.credenciales  ''New NetworkCredential(user, pass)
        peticionFTP.KeepAlive = True
        peticionFTP.UsePassive = Me._ftp.modopasivo
        peticionFTP.EnableSsl = Me._ftp.enablessl
        ' Seleccionamos el comando que vamos a utilizar: Subir un fichero
        peticionFTP.Method = WebRequestMethods.Ftp.UploadFile
        ' Especificamos el tipo de transferencia de datos
        peticionFTP.UseBinary = True
        ' Informamos al servidor sobre el tamaño del fichero que vamos a subir
        peticionFTP.ContentLength = Me._infoFichero.Length
        ' Fijamos un buffer 
        Dim longitudBuffer As Integer
        longitudBuffer = Me._buffer
        Dim lector As Byte() = New Byte(Me._buffer) {}
        Dim num As Integer
        ' Abrimos el fichero para subirlo
        Dim fs As FileStream
        fs = Me._infoFichero.OpenRead()
        Try
            Dim escritor As Stream
            escritor = peticionFTP.GetRequestStream()
            ' Leemos 2 KB del fichero en cada iteración
            num = fs.Read(lector, 0, longitudBuffer)
            Dim BytesEnviados As Integer = 0
            While (num <> 0)
                ' Escribimos el contenido del flujo de lectura en el
                ' flujo de escritura del comando FTP
                escritor.Write(lector, 0, num)
                BytesEnviados = BytesEnviados + longitudBuffer
                Me._bytessended = BytesEnviados
                RaiseEvent onSendFile(Me)
                num = fs.Read(lector, 0, longitudBuffer)
            End While
            escritor.Close()
            fs.Close()
            Dim dateend = DateTime.Now()
            Dim diff As TimeSpan = dateend - dateini
            Me._enviado = True
            Me._destino = destinoRemoto
            Me._milisecond = diff.TotalMilliseconds
            Me._bytessended = BytesEnviados
            RaiseEvent onFinishSendFile(Me)
        Catch ex As Exception
            ' Si se produce algún fallo, se devolverá el mensaje del error
            err.parse_error_script(ex)
            Me._err = err
            RaiseEvent onErrorSendFile(Me)
        End Try
        Me._err = err
        peticionFTP = Nothing
        Return err
    End Function



    Public ReadOnly Property localfilepath As String
        Get
            Return _localfilepath
        End Get
    End Property
    Public ReadOnly Property info As FileInfo
        Get
            Return _infoFichero
        End Get
    End Property
    Public ReadOnly Property length As Long
        Get
            Return Me._infoFichero.Length
        End Get
    End Property

    Public Property bytessended As Long
        Get
            Return _bytessended
        End Get
        Set(value As Long)
            Me._bytessended = value
        End Set
    End Property
    Public Property id As String
        Get
            Return _id
        End Get
        Set(id As String)
            Me._id = id
        End Set
    End Property

    Public Property milisecond As Long
        Get
            Return _milisecond
        End Get
        Set(value As Long)
            Me._milisecond = value
        End Set
    End Property

    Public Property enviado As Boolean
        Get
            Return _enviado
        End Get
        Set(value As Boolean)
            Me._enviado = value
        End Set
    End Property

    Public Property destino As String
        Get
            Return _destino
        End Get
        Set(value As String)
            Me._destino = value
        End Set
    End Property

    Public Property filename As String
        Get
            Return _filename
        End Get
        Set(value As String)
            Me._filename = value
        End Set
    End Property

    Public Property tError As tError
        Get
            Return _err
        End Get
        Set(value As tError)
        End Set
    End Property

    Public Property timeout As Integer
        Get
            Return _Timeout
        End Get
        Set(value As Integer)
            Me._Timeout = value
        End Set
    End Property


End Class

Public Class Pattern
    Public _groups As Dictionary(Of Integer, String) = New Dictionary(Of Integer, String)
    Private _expreg As String = ""
    Public Sub New(ByVal expReg As String)
        Me._expreg = expReg
    End Sub
    ''cad: cadena que puede machear con expreg, groupindex: indice del grupo que puede tener el valor que se busca en el macheo de la cadena en la expreg
    Public Function getvalue(ByVal cad As String, ByVal groupindex As Integer) As String
        Dim ret As String = ""
        Dim matchstring As Match = Regex.Match(cad, Me._expreg, RegexOptions.IgnoreCase)
        If (matchstring.Success) Then
            ret = matchstring.Groups.Item(groupindex).Value
        End If
        Return ret
    End Function
    ''cad: cadena que puede machear con expreg, namegroup: nombre del grupo en _groups que machea con la expresion regular
    Public Function getvalue(ByVal cad As String, ByVal namegroup As String) As String
        Dim ret As String = ""
        For Each kvp As KeyValuePair(Of Integer, String) In Me._groups
            Dim indexgroup As Integer = kvp.Key
            Dim keyname As String = kvp.Value
            If (namegroup = keyname) Then
                Dim matchstring As Match = Regex.Match(cad, Me._expreg, RegexOptions.IgnoreCase)
                If (matchstring.Success) Then
                    ret = matchstring.Groups.Item(indexgroup).Value
                End If
                Exit For
            End If
        Next
        Return ret
    End Function

    Public Sub addgroup(ByVal groupindex As Integer, ByVal namegroup As String)
        If (Me._groups.ContainsKey(groupindex)) Then
            Me._groups.Item(groupindex) = namegroup
        Else
            Me._groups.Add(groupindex, namegroup)
        End If
    End Sub
End Class
