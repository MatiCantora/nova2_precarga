<%@ Page Language="vb"  %>
<%
    Context.Items("titulo") = "Acceso denegado"
    Try
        Context.Items("subtitulo") = Request.QueryString(0)
    Catch ex As Exception
    End Try
    Server.Transfer("error_generico.aspx")

%>