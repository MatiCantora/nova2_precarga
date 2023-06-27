<%@ WebHandler Language="VB" Class="nvWebSocket.ws" %>
Imports System
Imports System.Web
Imports Microsoft.Web.WebSockets

Namespace nvWebSocket
    Public Class ws : Implements IHttpHandler

        Public ReadOnly Property IsReusable As Boolean Implements IHttpHandler.IsReusable
            Get
                Return False
            End Get
        End Property

        Public Sub ProcessRequest(ByVal context As HttpContext) Implements IHttpHandler.ProcessRequest
            If context.IsWebSocketRequest Then
                If context.Request.Cookies.Count > 0 Then context.AcceptWebSocketRequest(New nvFW.nvWebSocket.nvWSClient(context))
            End If
        End Sub
    End Class
End Namespace

