<%@ Page Language="vb" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW"  EnableSessionState="ReadOnly" %>
<%@ Import namespace="nvFW" %>
<%

    Response.Expires = 0
    Dim accion As String = nvUtiles.obtenerValor("accion")
    Dim criterio As String = nvUtiles.obtenerValor("criterio")

    Dim strXML As String = ""
    Dim st As New ADODB.Stream


    Select Case accion.ToLower()

        Case "sesion"
            Dim Stopwatch As System.Diagnostics.Stopwatch = System.Diagnostics.Stopwatch.StartNew()
            Dim fe_last_action = New Date(1900, 1, 1)
            Dim new_fe_last_action = New Date(1900, 1, 1)
            If Not nvSession.Contents("fe_last_action") Is Nothing Then
                fe_last_action = Date.Parse(nvSession.Contents("fe_last_action"))
            End If
            Try
                'Date.Parse(criterio)
                'zz es el desplazamiento respecto de UTC
                Dim cultureinfo As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
                new_fe_last_action = DateTime.Parse(criterio, cultureinfo)

                'DateTime.ParseExact(criterio, "dd/MM/yyyy HH:mm:ss.ffff", System.Globalization.CultureInfo.InvariantCulture)

            Catch ex As Exception
            End Try

            If new_fe_last_action > fe_last_action Then
                fe_last_action = new_fe_last_action
            End If

            nvSession.Contents("fe_last_action") = fe_last_action.ToString()

            strXML = "<xml xmlns:s='uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882' xmlns:dt='uuid:C2F41010-65B3-11d1-A29F-00AA00C14882' xmlns:rs='urn:schemas-microsoft-com:rowset' xmlns:z='#RowsetSchema'><rs:data><z:row "
            If nvApp.operador.login = "" Then
                strXML += " sesion_check='false' "
            Else
                strXML += " sesion_check='true' "
                strXML += " app_cod_sistema = '" & nvApp.cod_sistema + "' "
                strXML += " app_sistema = '" & nvApp.sistema & "' "
                strXML += " app_path_rel = '" & nvApp.path_rel & "' "
                strXML += " UID = '" & nvApp.operador.login & "' "
                strXML += " BrowserSesionTimeut = '" & nvServer.getConfigValue("config/global/@BrowserSesionTimeut", "300000") & "' "
                Dim i As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
                strXML += " fe_last_action = '" + fe_last_action.ToString("ddd MMM d HH:mm:ss UTCzz00 yyyy", i) + "' "
                strXML += " /></rs:data></xml>"
            End If
            nvXMLUtiles.responseXML(Response, strXML)
            Stopwatch.Stop()
            Dim ts As TimeSpan = Stopwatch.Elapsed
            nvLog.addEvent("rd_XMLSession", ";;" & ts.TotalMilliseconds & ";" & accion & ";" & criterio)
            Response.End()

            'Case "page_close"
            '    'Stop
            '    nvPage.ContentsRemoveAll(criterio)

        Case Else
            Dim e As New nvFW.tError
            e.numError = 1001
            e.titulo = "Error en la consulta"
            e.comentario = "La acción es deconocida"
            e.debug_src = "getSessionXML"
            e.debug_desc = "accion='" & accion & "'; criterio='" & criterio & "'"
            e.response()
    End Select



%>