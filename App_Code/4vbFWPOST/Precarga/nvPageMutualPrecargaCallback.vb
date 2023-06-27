Namespace nvFW
    Namespace nvPages
        Public Class nvPageMutualPrecargaCallback
            Inherits nvPageBase

            Private _classname As String = "nvPageMutualPrecargaCallback"
            Private _app_cod_sistema As String = "nv_mutualprecarga"
            Private _app_sistema As String = "Nova Mutual Precarga"
            Private _app_path_rel As String = "precarga"


            Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

                Dim err As New terror

                Dim host_ip As String = If(Not (Request.Headers("X-Forwarded-For") Is Nothing), Request.Headers("X-Forwarded-For"), Request.ServerVariables("REMOTE_ADDR"))
                'If (host_ip.IndexOf("172.18.149") = -1) Then
                '    err.numError = 97
                '    err.titulo = "Error de Acceso"
                '    err.mensaje = "Host remoto invalido"
                '    err.debug_src = "nvPageMutualPrecargaCallback::Page_Load"
                '    err.debug_desc = "Host remoto invalido. host:" & host_ip
                '    Dim logTrack As String = nvLog.getNewLogTrack()
                '    nvLog.addEvent("lg_interface_request", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString)
                '    err.response()
                'End If


                Dim io As System.IO.Stream = HttpContext.Current.Request.InputStream

                If io.Length = 0 Then
                    err.numError = 98
                    err.titulo = "Error de Acceso"
                    err.mensaje = "No existe información"
                    err.debug_src = "nvPageMutualPrecargaCallback::Page_Load"
                    err.debug_desc = "InputStream vacio"
                    Dim logTrack As String = nvLog.getNewLogTrack()
                    nvLog.addEvent("lg_interface_request", logTrack & ";" & Request.Url.ToString & ";" & Request.QueryString.ToString)

                    err.response()
                End If

                'io.Position = 0
                'Dim bufferInput(io.Length - 1) As Byte
                'io.Read(bufferInput, 0, bufferInput.Length)

                'Dim request_terror As String = nvFW.nvConvertUtiles.currentEncoding.GetString(bufferInput)

                'nvUtiles.definirValor("request_terror", request_terror)

                nvApp = nvFW.nvApp.getInstance
                nvFW.nvApp.set_app_from_cod(nvApp, _app_cod_sistema)
                nvApp.cod_servidor = nvServer.cod_servidor
                nvApp.operador.login = System.Environment.UserName
                nvApp.operador.ads_usuario = System.Environment.UserDomainName & "\" & System.Environment.UserName
                nvApp.appState = enumnvAppState.loaded
                nvApp.operador.AutLevel = nvSecurity.enumnvAutLevel.autorizado
                nvApp.host_ip = host_ip
                nvApp.host_name = host_ip
                nvApp.loadCNAndDir()

            End Sub

            Public Sub New()

                MyBase.setAPP(_app_cod_sistema, _app_sistema, _app_path_rel)
            End Sub

        End Class

    End Namespace
End Namespace