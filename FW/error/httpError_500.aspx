<%@ Page Language="vb"  %>
<%
    Context.Items("titulo") = "El recurso solicitado no está disponible"
    Try
        Context.Items("subtitulo") = "Error http " & Request.QueryString(0)
    Catch ex As Exception
    End Try
    Server.Transfer("error_generico.aspx")
%>