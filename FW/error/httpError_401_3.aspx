<%@ Page Language="vb"  %>
<%
    Context.Items("titulo") = "Ha cancelado el inicio de sesión"
    Try
        Context.Items("subtitulo") = Request.QueryString(0)
    Catch ex As Exception
    End Try
    Server.Transfer("error_generico.aspx")

%>