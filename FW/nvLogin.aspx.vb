
Partial Class vbLogin
    Inherits System.Web.UI.Page
    Public URL As String
    Public app_cod_sistema As String
    Public app_int As Integer
    'Public bloquear As Boolean
    Public accion As String
    Public UID As String
    Public PWD As String
    Public PWD_OLD As String
    Public PwdLastSet As String
    Public PwdCC As String
    Public port_eval As Boolean
    Public criterio As String
    Public nv_hash As String
    Public nvApp As tnvApp
    Public showAppsInLogin As Boolean = nvServer.getConfigValue("config/global/@showAppsInLogin", "true").ToLower = True
    Public showRemenberUID As Boolean = nvServer.getConfigValue("config/global/@showRemenberUID", "true").ToLower = True

    Public contents As New trsParam
    Private Sub vbLogin2_Load(sender As Object, e As EventArgs) Handles Me.Load

        '/****************************************************/
        '//Controlar que ingrese por el protocolo seguro https
        '//En caso contrario mandarlo al inicio
        '/****************************************************/
        If Application.Contents("nv_onlyHTTPS") = True And Not HttpContext.Current.Request.IsSecureConnection Then
            Response.Redirect(nvApp.server_host_https & "/FW/nvLogin.aspx?" & HttpContext.Current.Request.QueryString.ToString())
        End If

        nvApp = nvFW.nvApp.getInstance()

        '//URL desde donde se llama el login
        URL = nvUtiles.obtenerValor("URL", "")
        app_cod_sistema = nvUtiles.obtenerValor("app_cod_sistema", "")
        app_int = nvUtiles.obtenerValor("app_int", 0)
        'bloquear = nvUtiles.obtenerValor("bloquear", "false").ToLower() = "true"
        accion = nvUtiles.obtenerValor("accion", "")
        UID = nvUtiles.obtenerValor("UID", "")
        PWD = nvUtiles.obtenerValor("PWD", "")  'Obtiene contraseña del cliente
        PWD_OLD = nvUtiles.obtenerValor("PWD_OLD", "")
        PwdLastSet = nvUtiles.obtenerValor("PwdLastSet", "0") '// si el usuario decide cambiar la clave
        PwdCC = nvUtiles.obtenerValor("PwdCC", "0") ' si el usuario decide cambiar la clave

        '//var port_force = obtenerValor('port_force', '0')
        port_eval = False 'nvUtiles.obtenerValor("port_eval", "true").ToLower() = "false"
        '//nv_hash es un valor que reemplaza
        nv_hash = nvUtiles.obtenerValor("nv_hash", "")
        criterio = nvUtiles.obtenerValor("criterio", "")

        ''Compropbar si los parametros vienen por la sesión
        'Dim nvLoginParam = nvSession.Contents("nvLoginParam")
        'If Not nvLoginParam Is Nothing Then
        '    If nvLoginParam.URL Is Nothing Then URL = nvLoginParam.URL
        '    If nvLoginParam.app_cod_sistema Is Nothing Then app_cod_sistema = nvLoginParam.app_cod_sistema
        '    If nvLoginParam.app_int Is Nothing Then app_int = nvLoginParam.app_int
        '    If nvLoginParam.bloquear Is Nothing Then bloquear = nvLoginParam.bloquear
        '    If nvLoginParam.accion Is Nothing Then accion = nvLoginParam.accion
        '    If nvLoginParam.UID Is Nothing Then UID = nvLoginParam.UID
        '    If nvLoginParam.PWD Is Nothing Then PWD = nvLoginParam.PWD
        '    If nvLoginParam.PWD_OLD Is Nothing Then PWD_OLD = nvLoginParam.PWD_OLD
        '    If nvLoginParam.PwdLastSet Is Nothing Then PwdLastSet = nvLoginParam.PwdLastSet
        '    If nvLoginParam.PwdCC Is Nothing Then PwdCC = nvLoginParam.PwdCC
        '    If nvLoginParam.port_eval Is Nothing Then port_eval = nvLoginParam.port_eval
        '    If nvLoginParam.criterio Is Nothing Then criterio = nvLoginParam.criterio
        '    If nvLoginParam.nv_hash Is Nothing Then nv_hash = nvLoginParam.nv_hash
        'End If
        '*************************************************************************
        'Realizar la evaluación de carga del puerto en fucnion de la configuración
        'y realizar la redirección en caso de ser necesario
        ''*************************************************************************
        'Dim port_default As Integer
        'If (accion = "" And app_int = 0 And port_eval) Then
        '    port_default = nvServer.port_https 'nvSession.Contents("cfg_server_port_https")
        '    If bloquear = False Then
        '        port_default = nvApp.server_port 'nvSession.Contents("cfg_server_port") 'getPortsForcePerformance(Session.Contents("cfg_server_port_https"))
        '    End If
        '    If nvServer.port_https <> port_default Then
        '        Response.Redirect(nvApp.server_protocol & "://" & nvApp.server_name & ":" & port_default & "/FW/nvLogin.aspx?" & HttpContext.Current.Request.QueryString.ToString())
        '    End If
        'End If



        ''/***************************************************************/
        ''//  Control de aplicación, si se quiere entrar a otra aplicación
        ''//  dentro del mismo servidor direcionarlo hasta otro puerto
        ''/***************************************************************/
        'If nvApp.appState = enumnvAppState.loaded And nvApp.cod_sistema <> app_cod_sistema And app_cod_sistema <> "" Then
        '    app_int += 1
        '    Dim strSQL As String = "select * from nv_servidor_ports join nv_servidor_alias on nv_servidor_ports.cod_servidor = nv_servidor_alias.cod_servidor where servidor_alias = '" & nvApp.server_name & "' and port_http > " & nvServer.port_http & " order by port_http"
        '    Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.ADMDBExecute(strSQL)
        '    Dim port As New nvServer.tParPorts
        '    If Not rs.EOF Then
        '        port.http = rs.Fields("port_http").Value
        '        port.https = rs.Fields("port_https").Value
        '    Else
        '        nvFW.nvDBUtiles.DBCloseRecordset(rs)
        '        strSQL = "select * from nv_servidor_ports join nv_servidor_alias on nv_servidor_ports.cod_servidor = nv_servidor_alias.cod_servidor where servidor_alias = '" & nvApp.server_name & "' and port_http < " & nvServer.port_http & " order by port_http"
        '        rs = nvFW.nvDBUtiles.ADMDBExecute(strSQL)
        '        If Not rs.EOF Then
        '            port.http = rs.Fields("port_http").Value
        '            port.https = rs.Fields("port_https").Value
        '        End If
        '    End If
        '    nvFW.nvDBUtiles.DBCloseRecordset(rs)
        '    If port.http = 0 Then
        '        Dim er As New tError
        '        er.numError = 1
        '        er.titulo = "Error al intentar abrir la aplicación"
        '        er.mensaje = "Ya tiene abiertas demasiadas aplicacione en esta sesión. No existen puertos disponible."
        '        er.salida_tipo = "adjunto"
        '        er.response()
        '    Else
        '        Response.Redirect(nvApp.server_protocol & "://" & nvApp.server_name & ":" & IIf(HttpContext.Current.Request.IsSecureConnection, port.https, port.https) & "/FW/nvlogin.aspx?URL=" & URL & "&app_int=" & app_int & "&app_cod_sistema=" & app_cod_sistema & "&nv_hash=" & nv_hash)
        '    End If
        'End If

        If accion = "" And UID <> "" And PWD <> "" Then accion = "login"

        If accion.ToLower = "getinfobase" Then
            Dim er As New tError()
            er.params("app_cod_sistema") = nvApp.cod_sistema
            er.params("app_path_rel") = nvApp.path_rel
            er.params("SessionType") = nvSession.SessionType.ToString()
            er.params("showAppsInLogin") = showAppsInLogin.ToString.ToLower
            er.params("autLevel") = nvApp.operador.AutLevel

            If Application.Contents("_nvLogin_json_apps") Is Nothing Then
                Dim strSQL As String = "Select distinct cod_sistema, sistema from verSistemas_servidores where servidor_alias = '" + nvApp.server_name + "'"
                Dim tRSS As New trsParam
                Dim rsSistemas As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                While Not rsSistemas.EOF
                    tRSS(rsSistemas.Fields("cod_sistema").Value) = rsSistemas.Fields("sistema").Value
                    rsSistemas.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsSistemas)
                Application.Contents("_nvLogin_json_apps") = tRSS.toJSON()
            End If
            er.params("sistemas") = Application.Contents("_nvLogin_json_apps")
            er.response()
        End If

        If accion <> "" Then
            ''/***************************************************************/
            ''//Control de aplicación, si se quiere entrar a otra aplicación
            ''//dentro del mismo servidor direcionarlo hasta otro puerto
            ''/***************************************************************/
            'Dim cantidad_app As Integer
            'Dim NUEVO_SERVER_NAME As String = ""
            'Dim rs As ADODB.Recordset

            'If (nvApp.cod_sistema <> "" And nvApp.cod_sistema <> app_cod_sistema And app_cod_sistema <> "") Then
            '    app_int += 1
            '    rs = nvDBUtiles.ADMDBOpenRecordset("select count(*) as cantidad_app from verSistema_ports where cod_sistema = '" & app_cod_sistema & "' and servidor_alias = '" & nvApp.server_name & "'")
            '    cantidad_app = rs.Fields("cantidad_app").Value


            '    If cantidad_app > app_int Then
            '        rs = nvDBUtiles.ADMDBExecute("select * from verSistema_ports where cod_sistema = '" & app_cod_sistema & "' and servidor_alias = '" & nvApp.server_name & "' and port_https <> " & nvServer.port_https & " order by port_https")
            '        Do While Not rs.EOF
            '            If NUEVO_SERVER_NAME = "" Then
            '                NUEVO_SERVER_NAME = nvApp.server_host_https 'nvSession.Contents("cfg_server_protocol") & "://" + nvSession.Contents("cfg_server_name") & ":" & rs.Fields("port_https").Value
            '            End If
            '            If rs.Fields("port_https").Value > nvServer.port_https Then
            '                NUEVO_SERVER_NAME = nvApp.server_host_https 'nvSession.Contents("cfg_server_protocol") & "://" & nvSession.Contents("cfg_server_name") & ":" & rs.Fields("port_https").Value
            '                Exit Do
            '            End If
            '            rs.MoveNext()
            '        Loop
            '        Response.Redirect(NUEVO_SERVER_NAME & "/FW/nvLogin.aspx?" & HttpContext.Current.Request.QueryString.ToString())
            '    Else
            '        Dim err As tError = New tError()
            '        err.numError = 1
            '        err.titulo = "Error al cargar la aplicación"
            '        err.mensaje = "No se han encontrado puertos disponibles para esta sesión de browser. Cierre algunas de las aplicaciones dentro de la sesión del browser o habra una nueva sesión."
            '        err.response()
            '    End If
            'End If

            If nvApp.appState = enumnvAppState.not_loaded Then
                'Si hay una accion entonces tiene que estar definida una aplicacion
                'En caso de no estar se busca segun alguno de los siguientes criterios
                ' 1)Esto puede ser que ya este en una aplicacion Session.Contents("app_cod_sistema") != undefined
                ' 2)Que venga como parámetro a que aplicación quiere ingresar  app_cod_sistema != ''
                ' 3)Que tenga una url de acceso realacionada "pat_rel"
                ' 4)Que vaya a la aplicación por defecto para el usuario

                nvApp.cod_sistema = ""
                nvApp.ads_access = ""
                nvApp.ads_login = True
                nvApp.delegate_login = ""
                nvApp.operador.AutLevel = -1

                ''//1)Esto puede ser que ya este en una aplicacion Session.Contents("app_cod_sistema") != undefined    
                'If Not nvSession.Contents("app_cod_sistema") Is Nothing Then
                '    nvFW.nvApp.set_app_from_cod(nvApp, nvSession.Contents("app_cod_sistema"))
                'End If

                '//2)Que venga como parámetro a que aplicación quiere ingresar  app_cod_sistema != ''
                If nvApp.cod_sistema = "" And app_cod_sistema <> "" Then
                    nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema)
                End If

                '//3)Que tenga una url de acceso url != ''  
                If nvApp.cod_sistema = "" And URL <> "" Then
                    Dim strreg As String = "../../([^/]*)/"
                    Dim reg As Regex = New Regex(strreg)
                    Dim m As Match
                    m = reg.Match(URL)
                    If m.Length > 0 Then
                        nvFW.nvApp.set_app_from_cod(nvApp, , m.Value)
                    End If
                End If

                '//4) Buscar la aplicacion por defecto del usuario
                If nvApp.cod_sistema = "" And UID <> "" Then
                    nvFW.nvApp.set_app_default(nvApp, UID)
                End If
            End If
            Dim errRes As tError = New tError()


            errRes = nvLogin.execute(nvApp, accion, UID, PWD, PWD_OLD, PwdCC, nv_hash, criterio)
            errRes.response()
            'Else
            '    Me.contents("appTodas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSistemas_servidores' cn='admin'><campos>distinct cod_sistema, sistema</campos><filtro><servidor_alias>'" & nvApp.server_name & "'</servidor_alias></filtro></select></criterio>")
            '    Me.contents("appSession") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSistemas_servidores' cn='admin'><campos>distinct cod_sistema, sistema</campos><filtro><servidor_alias>'" & nvApp.server_name & "'</servidor_alias><cod_sistema>'" & nvApp.cod_sistema & "'</cod_sistema></filtro></select></criterio>")
        End If
    End Sub
End Class
