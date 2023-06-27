<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin"  %>

<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Security" %>
<%@ Import Namespace="System.Security.Principal" %>
<%@ Import Namespace="System.Runtime.InteropServices" %>
<%


    Stop
    Dim action As String = obtenerValor("action", "")
    Select Case action
        Case "listenON"
            Dim nvTCPListen As nvTCPListen
            If Application.Contents("nvTCPListen") Is Nothing Then
                nvTCPListen = New nvTCPListen
                Application.Contents("nvTCPListen") = nvTCPListen
            Else
                nvTCPListen = Application.Contents("nvTCPListen")
            End If

            nvTCPListen.listenON(600)
            Dim t As New Threading.Thread(New Threading.ParameterizedThreadStart(Sub(TCPListen As nvTCPListen)
                                                                                     'AddHandler TCPListen.onDataReceived, Sub(sender As System.Net.Sockets.Socket, data() As Byte)
                                                                                     '                                         Dim strXML As String = nvConvertUtiles.BytesToString(data)
                                                                                     '                                         'nvTCPListen.listImplementation.Add(strXML, sender)
                                                                                     '                                         'nvTCPListen.datareceivedcount += 1
                                                                                     '                                     End Sub

                                                                                     AddHandler TCPListen.onMessageReceived, Sub(sender As System.Net.Sockets.Socket, message As String)
                                                                                                                                 System.Diagnostics.Debug.Print(message & vbCrLf)
                                                                                                                             End Sub

                                                                                 End Sub))
            t.Start(nvTCPListen)
            Dim err As tError = nvTCPListen.lastError
            If err.numError = 0 Then

                AddHandler nvServer.onApllicationEnd, Sub()
                                                          Try
                                                              nvTCPListen.listenOFF()
                                                          Catch ex As Exception

                                                          End Try
                                                      End Sub
            End If
            err.response()

        Case "listenOFF"
            Dim nvTCPListen As nvTCPListen
            Dim err As New tError
            If Not Application.Contents("nvTCPListen") Is Nothing Then
                Try
                    nvTCPListen = Application.Contents("nvTCPListen")
                    nvTCPListen.listenOFF()
                    Application.Contents.Remove("nvTCPListen")
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            End If
            err.response()

        Case "list"
            Dim nvTCPListen As nvTCPListen
            Dim err As New tError
            If Not Application.Contents("nvTCPListen") Is Nothing Then
                Try
                    nvTCPListen = Application.Contents("nvTCPListen")
                    err.params("isListening") = nvTCPListen.isListening
                    Dim i As Integer = 1
                    For Each c In nvTCPListen.clients.Values
                        err.params("cn" & i) = c.socket.RemoteEndPoint.ToString
                        i += 1
                    Next
                    err.params("datarecievedcount") = nvTCPListen.datareceivedcount
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            End If
            err.response()

        Case "enviar"
            Dim ip As String = obtenerValor("ip")
            Dim mensaje As String = obtenerValor("mensaje")
            Dim nvTCPListen As nvTCPListen
            Dim err As New tError
            If Not Application.Contents("nvTCPListen") Is Nothing Then
                Try
                    nvTCPListen = Application.Contents("nvTCPListen")
                    Dim data() As Byte = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(mensaje)
                    If Not nvTCPListen.SendData(ip, data) Then
                        err.numError = 10
                        err.mensaje = "No se pudo enviar el dato"
                    End If
                Catch ex As Exception
                    err.parse_error_script(ex)
                End Try
            End If
            err.response()
    End Select

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />

    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

   function nvTCPListener_listenON()
     {
     $("action").value = "listenON"
     $("form1").submit()
     }

   function nvTCPListener_listenOFF()
     {
     $("action").value = "listenOFF"
     $("form1").submit()
     }
     
   function nvTCPListener_list()
     {
     $("action").value = "list"
     $("form1").submit()
     }

   function nvTCPListener_Enviar()
     {
     $("action").value = "enviar"
     $("form1").submit()
     }

    </script>

    <script runat="server">


    </script>

    <%


    %>
</head>
<body onload="window_onload()" style="height: 100%; overflow: hidden">
    <form name="form1" id="form1" action="prueba_nvTCPListener.aspx" method="post" target="_blank">
        <input type="hidden" name="action" id="action" />
        <table class="tb1">
            <tr>
                <td>
                    <input type="button" value="Listen ON" onclick="nvTCPListener_listenON()" />

                </td>
                <td>
                    <input type="button" value="Listen OFF" onclick="nvTCPListener_listenOFF()" />

                </td>
                <td>
                    <input type="button" value="Listar" onclick="nvTCPListener_list()" />
                </td>

                <td>
                    <input type="button" value="Enviar" onclick="nvTCPListener_Enviar()" />IP: <input type="text" name="ip" style="width:200px" /> - Mensaje: <input type="text" name="mensaje" style="width:200px" />
                </td>
            </tr>
        </table>
   </form>

   <iframe name="iFrame01" style="width:100%; height: 300px"></iframe>


</body>
</html>
