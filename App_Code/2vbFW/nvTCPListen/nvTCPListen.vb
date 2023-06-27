Imports System.ComponentModel
Imports System.Reflection
Imports Microsoft.VisualBasic
Imports nvFW

Namespace nvFW


    Public Class nvTCPListen


        'Public Shared _listImplementation As New Dictionary(Of String, System.Net.Sockets.Socket)

        Public lastError As New nvFW.tError
        Public clients As New Dictionary(Of String, nvTCPClient)
        Public ReceiveBufferSize As Integer = 4096

        Public Event onListen(sender As nvTCPListen)
        Public Event onListenError(sender As nvTCPListen)
        Public Event onClientConnect(sender As nvTCPListen, client As System.Net.Sockets.Socket)
        Public Event onClientConnectError(sender As nvTCPListen, client As System.Net.Sockets.Socket, er As tError)
        Public Event onDataReceived(sender As System.Net.Sockets.Socket, data() As Byte)
        Public Event onMessageReceived(sender As System.Net.Sockets.Socket, message As String)
        Public Event onDataReceivedError(sender As System.Net.Sockets.Socket, er As tError)


        Private _listener As TcpListenerEx
        Private _port As Integer
        Private _interface As String
        Private _threadListen As Threading.Thread
        Private _treadListenerWhile As Boolean
        'Private _clientsThread As New List(Of Threading.Thread)
        Private _WaitToListen As Boolean
        Private Shared _datareceivedcount As Integer = 0
        'Private _threadConnectionsAlive As Threading.Thread

        Public ReadOnly Property datareceivedcount As Long
            Get
                Return _datareceivedcount
            End Get
        End Property


        Public Sub New()

        End Sub
        Public Function listenON(port As Integer) As tError
            Dim err As New tError()
            If Not _threadListen Is Nothing Then
                If Not _threadListen.IsAlive Then _threadListen = Nothing
            End If
            If _threadListen Is Nothing Then
                _threadListen = New Threading.Thread(Sub() _listen(port))
                _WaitToListen = True
                _threadListen.Start()
                While _WaitToListen
                    System.Threading.Thread.CurrentThread.Sleep(100)
                End While
                err = lastError
            End If
            Return err
        End Function

        Private Sub _listen(port As Integer)
            Dim ipAddress As System.Net.IPAddress
            Try
                _listener = New TcpListenerEx(ipAddress.Any, port)
                _listener.Start()
                '_threadConnectionsAlive = New Threading.Thread(AddressOf _threadConnectionsAliveControl)
                _WaitToListen = False
            Catch ex As Exception
                lastError = New tError()
                lastError.parse_error_script(ex)
                lastError.titulo = "Error de TCPListener"
                lastError.mensaje = "No se puede abrir el puerto de escucha"
                RaiseEvent onListenError(Me)
                _WaitToListen = False
                Exit Sub
            End Try

            Dim client As System.Net.Sockets.Socket
            _treadListenerWhile = True
            While (_treadListenerWhile)
                Try
                    client = Nothing
                    client = _listener.AcceptSocket()
                    Dim t As New Threading.Thread(New Threading.ParameterizedThreadStart(AddressOf _clientDataReceived))
                    t.Start(client)
                    clients.Add(client.RemoteEndPoint.ToString, New nvTCPClient(client, t))
                    '_clientsThread.Add(t)
                    RaiseEvent onClientConnect(Me, client)
                Catch ex As Exception
                    Dim err As tError = New tError
                    err.parse_error_script(ex)
                    err.titulo = "Error de TCPListener"
                    err.mensaje = "Error en la conexión del cliente"
                    RaiseEvent onClientConnectError(Me, client, err)
                End Try
            End While
            Try
                _listener.Stop()
            Catch ex As Exception
            End Try

        End Sub

        Public Function isListening() As Boolean
            If _threadListen Is Nothing Then
                Return False
            End If
            Return _threadListen.IsAlive And _listener.Active
        End Function
        'Private Sub _threadConnectionsAliveControl()
        '    While True
        '        For Each c In clients
        '            If c.
        '        Next
        '        System.Threading.Thread.CurrentThread.Sleep(500)
        '    End While
        'End Sub

        Public Sub listenOFF()
            _treadListenerWhile = False
            Try
                _listener.Stop()
            Catch ex As Exception
            End Try
            If Not _threadListen Is Nothing Then
                If _threadListen.IsAlive Then _threadListen.Abort()
                _threadListen = Nothing
            End If
            While clients.Count > 0
                clients.ElementAt(0).Value.threadListen.Abort()
                Try
                    clients.ElementAt(0).Value.socket.Close()
                Catch ex As Exception
                End Try
                clients.Remove(clients.ElementAt(0).Key)
            End While

            'If Not _threadListen Is Nothing Then
            '    Dim ahora As DateTime = Now
            '    Dim limite As DateTime = DateAdd(DateInterval.Second, 3, ahora)
            '    While _threadListen.IsAlive And Now < limite
            '        Threading.Thread.CurrentThread.Sleep(300)
            '    End While
            '    If _threadListen.IsAlive Then _threadListen.Abort()
            '    _threadListen = Nothing
            'End If

        End Sub


        Private Sub _clientDataReceived(client As System.Net.Sockets.Socket)
            Dim BytesReceived As Integer
            Dim buffer(ReceiveBufferSize - 1) As Byte
            Dim data(ReceiveBufferSize - 1) As Byte
            client.ReceiveBufferSize = ReceiveBufferSize
            While (_treadListenerWhile)
                Try
                    ReDim data(buffer.Length - 1)
                    BytesReceived = client.Receive(buffer)
                    _datareceivedcount += BytesReceived
                    buffer.CopyTo(data, 0)
                    Dim TCPclient As nvTCPClient = clients(client.RemoteEndPoint.ToString)
                    'Si viene vacío se debe descargar el buffermessage
                    If (BytesReceived = 0) Then
                        TCPclient.buffermessage = ""
                        Exit Sub
                    End If
                    RaiseEvent onDataReceived(client, data)
                    'Chequear que el evento existe
                    If Not onMessageReceivedEvent Is Nothing Then
                        Dim desde As Integer = 0
                        Dim hasta As Integer
                        For i = 0 To BytesReceived - 1
                            If data(i) = 0 And i = desde Then
                                If TCPclient.buffermessage <> "" Then
                                    RaiseEvent onMessageReceived(client, TCPclient.buffermessage)
                                    TCPclient.buffermessage = ""
                                End If
                                desde += 1
                                Continue For
                            End If
                            If data(i) = 0 Then
                                Dim data_frag(i - desde - 1) As Byte
                                Array.Copy(data, desde, data_frag, 0, i - desde)
                                TCPclient.buffermessage += nvConvertUtiles.BytesToString(data_frag)
                                RaiseEvent onMessageReceived(client, TCPclient.buffermessage)
                                TCPclient.buffermessage = ""
                                desde = i + 1
                            End If
                        Next
                        If desde < BytesReceived - 1 Then
                            Dim data_frag(BytesReceived - desde - 1) As Byte
                            Array.Copy(data, desde, data_frag, 0, BytesReceived - desde)
                            TCPclient.buffermessage += nvConvertUtiles.BytesToString(data_frag)
                        End If

                        'If data(UBound(data)) = 0 Then
                        '    ReDim Preserve data(UBound(data) - 1)
                        '    TCPclient.buffermessage += nvConvertUtiles.BytesToString(data)
                        '    RaiseEvent onMessageReceived(client, TCPclient.buffermessage)
                        '    TCPclient.buffermessage = ""
                        'Else
                        '    TCPclient.buffermessage += nvConvertUtiles.BytesToString(data)
                        'End If
                    End If

                Catch ex As Exception
                    Dim err As New tError
                    err.parse_error_script(ex)
                    err.titulo = "Error de TCPListener"
                    err.mensaje = "Error al riceibir datos"
                    RaiseEvent onDataReceivedError(client, err)
                End Try

            End While
        End Sub

        Public Function SendData(strRemoteEndPoint As String, data() As Byte) As Boolean
            Dim i As Integer = 1
            Dim client As nvTCPClient = clients(strRemoteEndPoint)
            If Not client Is Nothing Then
                Try
                    Dim bytesSend As Integer = client.socket.Send(data)
                    Return bytesSend = data.Length
                Catch ex As Exception
                    If Not client.socket.Connected Then
                        clients.Remove(strRemoteEndPoint)
                    End If
                End Try
            End If
            Return False

            'For Each c As nvTCPClient In clients.Values
            '    If c.RemoteEndPoint.ToString() = strRemoteEndPoint Then
            '        'Dim data() As Byte = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(mensaje)
            '        Try
            '            Try
            '                c.Send(data)
            '                Return True
            '            Catch ex As Exception
            '                If Not c.Connected Then
            '                    clients.Remove(c)
            '                End If
            '            End Try
            '        Catch ex As Exception
            '        End Try
            '        Exit For
            '    End If
            'Next
            'Return False
        End Function

        Public Function SendMessage(strRemoteEndPoint As String, message As String) As Boolean
            Dim data() As Byte = nvConvertUtiles.StringToBytes(message)
            ReDim Preserve data(UBound(data) + 1)
            data(UBound(data)) = 0
            Return SendData(strRemoteEndPoint, data)
        End Function

        'Public Shared Function GetEventSubscribers(ByVal target As Object, ByVal eventName As String) As List(Of [Delegate])

        '    Dim type As Type = target.GetType()
        '    Dim list As New List(Of [Delegate])

        '    eventName = eventName & "Event"

        '    Do
        '        For Each field As FieldInfo In type.GetFields((BindingFlags.NonPublic Or
        '  (BindingFlags.Static Or BindingFlags.Instance)))

        '            If field.Name = eventName Then

        '                Dim eventList As EventHandlerList = DirectCast(target.GetType().GetProperty("Events",
        '      (BindingFlags.FlattenHierarchy Or (BindingFlags.NonPublic Or BindingFlags.Instance))).GetValue(target, Nothing), EventHandlerList)

        '                Dim eventDelegate As [Delegate] = eventList.Item(field.GetValue(target))

        '                If eventDelegate IsNot Nothing Then
        '                    list.Add(eventDelegate)
        '                End If

        '            End If

        '        Next field
        '        type = type.BaseType
        '    Loop While type IsNot Nothing

        '    Return list

        'End Function

        Protected Overrides Sub Finalize()
            listenOFF()
            MyBase.Finalize()
        End Sub

        Public Class nvTCPClient
            Public socket As System.Net.Sockets.Socket
            Public threadListen As Threading.Thread
            Public buffermessage As String = ""
            Public Sub New(socket As System.Net.Sockets.Socket, threadListen As Threading.Thread)
                Me.socket = socket
                Me.threadListen = threadListen
            End Sub
        End Class

        Private Class TcpListenerEx
            Inherits System.Net.Sockets.TcpListener

            Public Sub New(localEP As Net.IPEndPoint)
                MyBase.New(localEP)
            End Sub

            Public Sub New(localaddr As Net.IPAddress, port As Integer)
                MyBase.New(localaddr, port)
            End Sub

            Public Overloads ReadOnly Property Active As Boolean
                Get
                    Return MyBase.Active
                End Get
            End Property
        End Class

    End Class
End Namespace