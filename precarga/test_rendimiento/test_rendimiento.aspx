<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga"%>
<%    

    'Dim nvApp As New tnvApp

    'nvFW.nvApp.set_app_from_cod(nvApp, "nv_mutualprecarga")
    'nvApp.cod_servidor = nvServer.cod_servidor
    'nvApp.operador.login = System.Environment.UserName
    'nvApp.operador.ads_usuario = System.Environment.UserDomainName & "\" & System.Environment.UserName
    'nvApp.operador.AutLevel = nvFW.nvSecurity.enumnvAutLevel.logeado 'autorizado
    'nvApp.loadCNAndDir()
    ''{modo: 'Z', nro_docu: '25910364', cuit: undefined, sce_id: '0', clave_sueldo: '625005200014259103641'}
    'Dim err As New nvFW.tError
    'Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp As Object)

    '                                                                              nvFW.nvApp._nvApp_ThreadStatic = psp("nvApp")

    Dim err_thread As New nvFW.tError
    Dim strXML As String = ""

    Try
        Dim nro_docu As String = "25910364" 'nvFW.nvUtiles.obtenerValor("nro_docu", "25910364")
        Dim sce_id As String = "0" 'nvFW.nvUtiles.obtenerValor("sce_id", "0")
        Dim clave_sueldo As String = "625005200014259103641" 'nvFW.nvUtiles.obtenerValor("clave_sueldo", "625005200014259103641")
        Dim hash As String = ""
        err_thread = nvLogin.execute(nvApp, "get_hash", nvApp.operador.login, "", "", "", "", "")
        hash = err_thread.params("hash")
        Dim aspx_callback As String = "FW/servicios/ROBOTS/GetXML.aspx"
        Dim URLREQUEST As String = "https://" & nvApp.server_name & "/" & aspx_callback
        Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("Select  isnull(dbo.piz1D('CUAD callback robot','" & nvApp.cod_servidor & "'),'') as host_callback")
        If Not (rs.EOF) Then
            If (rs.Fields("host_callback").Value <> "") Then
                URLREQUEST = "https://" & rs.Fields("host_callback").Value & "/" & aspx_callback
            End If
        End If

        Dim criterio As String = "<criterio><nro_docu>" & nro_docu & "</nro_docu><sce_id>" & sce_id & "</sce_id><clave_sueldo>" & clave_sueldo & "</clave_sueldo></criterio>"
        Dim oHTTP As New nvHTTPRequest
        oHTTP.multi_part = True
        oHTTP.url = URLREQUEST
        oHTTP.param_add("a", "consultar_premotor")
        oHTTP.param_add("app_cod_sistema", "nv_mutualprecarga")
        oHTTP.param_add("app_path_rel", "precarga")
        oHTTP.param_add("criterio", criterio)
        oHTTP.param_add("hash", hash)
        oHTTP.param_add("nv_hash", hash)
        oHTTP.param_add("end", "")
        oHTTP.time_out = 150000

        Dim response As Net.HttpWebResponse = oHTTP.getResponse()

        If (response Is Nothing) Then
            err_thread.numError = -1
            err_thread.mensaje = "Servicio apagado. URL: " & URLREQUEST
            strXML = err_thread.get_error_xml()
        Else
            Dim reader As System.IO.StreamReader = New System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("iso-8859-1"))
            Dim oXML As New System.Xml.XmlDocument
            strXML = reader.ReadToEnd()
        End If

        ''cargo el terror tmp por si viene cualquier cosa
        Dim ErrTmp As New tError
        ErrTmp.loadXML(strXML)
        If (ErrTmp.numError <> 0) Then
            err_thread.numError = -5
            err_thread.mensaje = "No se pudo procesar la informacion. Intente luego"
            err_thread.params("strXML") = strXML
        Else
            err_thread = ErrTmp
        End If
        ErrTmp = Nothing
    Catch ex As Exception
        err_thread.parse_error_script(ex)
        err_thread.titulo = "Error al consultar cupo"
        err_thread.comentario = ""

    End Try
    'psp("finish") = True
    'psp("err") = err_thread
    'End Sub)
    err_thread.response()

    'Dim ps As New Dictionary(Of String, Object)
    'ps.Add("err", err)
    'ps.Add("finish", False)
    'ps.Add("nvApp", nvApp)
    'ps.Add("strXML", "")
    'async_thread.Start(ps)

    'Dim timeout As Integer = 120 'segundos
    'Dim ini As Date = Microsoft.VisualBasic.DateAndTime.Now

    'While Not ps("finish") And Microsoft.VisualBasic.DateAndTime.Now < Microsoft.VisualBasic.DateAndTime.DateAdd(DateInterval.Second, timeout, ini)
    '    System.Threading.Thread.CurrentThread.Sleep(500)
    'End While

    'err = ps("err")

    'err.response()

 %>