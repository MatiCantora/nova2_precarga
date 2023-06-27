<%@ Page Language="vb"  %>
<%
    Dim titulo As String = nvUtiles.isNUllorEmpty(Context.Items("titulo"), "El recurso solicitado no está disponible")
    Dim subtitulo As String = nvUtiles.isNUllorEmpty(Context.Items("subtitulo"), "Error desconocido")
    Dim img_path_svg As String = nvUtiles.isNUllorEmpty(Context.Items("img_path_svg"), nvServer.getConfigValue("/config/global/customErrors/img/@path_svg", ""))
    Dim img_path As String = nvUtiles.isNUllorEmpty(Context.Items("img_path"), nvServer.getConfigValue("/config/global/customErrors/img/@path", ""))
    Dim img_width As String = nvUtiles.isNUllorEmpty(Context.Items("img_width"), nvServer.getConfigValue("/config/global/customErrors/img/@width", "300"))
    Dim img_height As String = nvUtiles.isNUllorEmpty(Context.Items("img_height"), nvServer.getConfigValue("/config/global/customErrors/img/@height", "128"))
    Dim email As String = nvUtiles.isNUllorEmpty(Context.Items("email"), nvServer.getConfigValue("/config/global/customErrors/contact/@email", ""))
    Dim telefono As String = nvUtiles.isNUllorEmpty(Context.Items("telefono"), nvServer.getConfigValue("/config/global/customErrors/contact/@phone", ""))

	Dim ContentTypeisJSON As Boolean = HttpContext.Current.Request.ContentType.ToLower.IndexOf("application/json") >= 0

    If ContentTypeisJSON = True Then
        Dim err As New tError
        err.numError = 100
        err.titulo = titulo
        err.mensaje = subtitulo
        err.response(tError.nvenum_error_format.json)
    End If

     %>

<!DOCTYPE html>

<html>
<head>
    <title></title>
	<meta charset="utf-8" />
</head>
<body>

    <table height="140px" style="font-family: &quot;Times New Roman&quot;; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;" width="100%">
        <tr>
            <td nowrap="nowrap" style="text-align: center; color: rgb(0, 0, 0); font-style: normal; font-variant: normal; font-weight: normal; font-stretch: normal; font-size: 15pt; line-height: 15pt; font-family: verdana;"><%=titulo %><div nowrap="nowrap" style="margin: 0px; padding: 0px; border: 0px; text-align: center; color: rgb(0, 0, 0); font-style: normal; font-variant: normal; font-weight: normal; font-stretch: normal; font-size: 8pt; line-height: 8pt; font-family: verdana;">
                <%=subtitulo %></div>
            </td>
        </tr>
    </table>
    <br style="color: rgb(0, 0, 0); font-family: &quot;Times New Roman&quot;; font-size: 12px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;" />
    <table height="150px" style="font-family: &quot;Times New Roman&quot;; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;" width="100%">
        <tr>
            <td style="text-align: center;">
                <% 
                    If img_path_svg <> "" Then
                        Response.Write("<object data='" & img_path_svg & "' width='" & img_width & "px' height='" & img_height & "px' type='image/svg+xml'><img src='" & img_path & "' width='" & img_width & "px' height='" & img_height & "px' /></object>")
                    Else
                        If img_path <> "" Then
                            Response.Write("<img src='" & img_path & "' width='" & img_width & "px' height='" & img_height & "px' />")
                        End If
                    End If

                    %>

                 </td>
        </tr>
    </table>
    <br style="color: rgb(0, 0, 0); font-family: &quot;Times New Roman&quot;; font-size: 12px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;" />
    <br style="color: rgb(0, 0, 0); font-family: &quot;Times New Roman&quot;; font-size: 12px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: normal; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial;" />
    <table style="letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-style: initial; text-decoration-color: initial; text-align: center; color: black; font-style: normal; font-variant: normal; font-weight: normal; font-stretch: normal; font-size: 12pt; line-height: 12pt; font-family: tahoma;" width="100%">
        <tr>
            <td style="text-align: center; color: black; font-style: normal; font-variant: normal; font-weight: normal; font-stretch: normal; font-size: 12pt; line-height: 12pt; font-family: tahoma;">&nbsp;Póngase en contacto con el administrador del sistema.</td>
        </tr>
       
            <%
                If email <> "" Then
                    Response.Write("<tr><td>&nbsp;Email:<span >&nbsp;</span><a href='mailto:" & email & "' style='font-family: tahoma; font-size: 12pt; font-weight: normal; color: blue; text-decoration: none; font-style: normal; font-variant: normal; font-stretch: normal; line-height: 12pt;'>" & email & "</a></td></tr>")
                End If
                If telefono <> "" Then
                    Response.Write("<tr><td>&nbsp;Teléfono:<span >&nbsp;</span><a href='tel:" & telefono & "' style='font-family: tahoma; font-size: 12pt; font-weight: normal; color: blue; text-decoration: none; font-style: normal; font-Variant: normal; font-stretch: normal; line-height: 12pt;'>" & telefono & "</a></td></tr>")
                End If

                 %>
           
            
       
    </table>

</body>
</html>
