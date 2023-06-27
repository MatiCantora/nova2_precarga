Imports Microsoft.VisualBasic
Imports System.Threading
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Public Class nvResponsePending
        Private Shared _responsePendingItems As New Dictionary(Of String, nvResponsePendingElement)


        Public Shared Function add(data As String, Optional expirable As Boolean = False, Optional secondsToExpire As Integer = 60) As nvResponsePendingElement
            Dim id As String
            Do
                id = Guid.NewGuid().ToString
            Loop While _responsePendingItems.ContainsKey(id)

            Dim item As New nvResponsePendingElement(id, expirable, secondsToExpire)
            item.data = data
            _responsePendingItems.Add(id, item)
            Return item
        End Function

        Public Shared Function [get](id As String) As nvResponsePendingElement
            If _responsePendingItems.ContainsKey(id) Then
                Return _responsePendingItems(id)
            Else
                Return Nothing
            End If
        End Function

        Public Shared Sub remove(id As String)

            If _responsePendingItems.ContainsKey(id) Then
                _responsePendingItems.Remove(id)
            End If

        End Sub

        Public Class nvResponsePendingElement
            Private _id As String
            Public ReadOnly expirable As Boolean
            Public ReadOnly secondsToExpire As Integer
            Public _state As enumPendingSatate = enumPendingSatate.pendiente
            Public Event onStateChange()

            ' info operador
            Public cod_sistema As String
            Public operador As String

            Public data As String
            Public element As New Dictionary(Of String, Object)

            Public Property state As enumPendingSatate
                Get
                    Return _state
                End Get
                Set(value As enumPendingSatate)
                    _state = value
                    RaiseEvent onStateChange()
                End Set
            End Property

            Public Sub New(id As String, Optional expirable As Boolean = False, Optional secondsToExpire As Integer = 60)
                _id = id
                Me.expirable = expirable
                Me.secondsToExpire = secondsToExpire

                If expirable = True Then
                    Dim thread As New Thread(
                      Sub()
                          Threading.Thread.Sleep(secondsToExpire * 1000)
                          If _state <> enumPendingSatate.terminado Then
                              _state = enumPendingSatate.timeout
                          End If
                      End Sub
                    )
                    thread.Start()
                End If

            End Sub
            Public ReadOnly Property id As String
                Get
                    Return _id
                End Get
            End Property


        End Class

        Public Enum enumPendingSatate
            pendiente = 0
            enviado = 1
            timeout = 2
            terminado = 3
        End Enum
    End Class

    Public Class nvTCPClients
        Public Shared connections As New Dictionary(Of String, nvTCPClient)
        Public Shared nvTCPListen As New nvTCPListen

        Public Shared Sub init()
            If Not nvTCPListen.isListening Then
                AddHandler nvTCPListen.onClientConnect, Sub(sender As nvTCPListen, client As System.Net.Sockets.Socket)
                                                            'dejarlo pasar o no

                                                            'clientConnectPendinng.Add(client)
                                                            Dim TCPClient As New nvTCPClient
                                                            TCPClient.socket = client
                                                            connections.Remove(TCPClient.socket.RemoteEndPoint.ToString)
                                                            connections.Add(TCPClient.socket.RemoteEndPoint.ToString, TCPClient)

                                                            Dim _treadControl As New System.Threading.Thread(New System.Threading.ParameterizedThreadStart(Sub(_client As System.Net.Sockets.Socket)

                                                                                                                                                               Threading.Thread.Sleep(60000)
                                                                                                                                                               'controlar que se haya vinculado


                                                                                                                                                               Dim clientSocket As String
                                                                                                                                                               Try
                                                                                                                                                                   clientSocket = _client.RemoteEndPoint.ToString()
                                                                                                                                                               Catch ex As Exception
                                                                                                                                                                   ' _client fue cerrado/desechado
                                                                                                                                                                   Exit Sub
                                                                                                                                                               End Try

                                                                                                                                                               If connections.ContainsKey(clientSocket) Then
                                                                                                                                                                   If Not connections(clientSocket).vinculado Then

                                                                                                                                                                       Try
                                                                                                                                                                           _client.Close()
                                                                                                                                                                       Catch ex2 As Exception
                                                                                                                                                                       End Try
                                                                                                                                                                       connections.Remove(clientSocket)
                                                                                                                                                                       Exit Sub
                                                                                                                                                                   End If
                                                                                                                                                               End If



                                                                                                                                                               'Dim noSalir As Boolean = True
                                                                                                                                                               'Dim data() As Byte = nvConvertUtiles.StringToBytes("ping")

                                                                                                                                                               '' agregar 0 al final
                                                                                                                                                               'Array.Resize(data, data.Length + 1)
                                                                                                                                                               'data(data.Length - 1) = 0
                                                                                                                                                               'Do
                                                                                                                                                               '    Try
                                                                                                                                                               '        _client.Send(data)
                                                                                                                                                               '    Catch ex As Exception
                                                                                                                                                               '        Try
                                                                                                                                                               '            _client.Close()
                                                                                                                                                               '        Catch ex2 As Exception
                                                                                                                                                               '        End Try
                                                                                                                                                               '        connections.Remove(clientSocket)
                                                                                                                                                               '        Exit Sub
                                                                                                                                                               '    End Try

                                                                                                                                                               '    Threading.Thread.Sleep(10000)
                                                                                                                                                               'Loop While noSalir



                                                                                                                                                           End Sub))

                                                            _treadControl.Start(client)
                                                        End Sub

                AddHandler nvTCPListen.onDataReceived, Sub(sender As System.Net.Sockets.Socket, data() As Byte)

                                                           'nvTCPListen.datareceivedcount += 1
                                                           Dim message As String = ""
                                                           Dim xmlmenssage As New System.Xml.XmlDocument
                                                           Try
                                                               message = nvConvertUtiles.BytesToString(data)
                                                               xmlmenssage.LoadXml(message)

                                                               'Validar firma para saber quien es el operador conectado
                                                               Dim nodes As System.Xml.XmlNodeList = xmlmenssage.SelectNodes("/acciones/accion")
                                                               For Each node As System.Xml.XmlNode In nodes
                                                                   If (node.Attributes("type").Value = "sendCodImplementacion") Then
                                                                       Dim cod_implement As String = node.Attributes("cod_implement").Value

                                                                       Dim TCPClient As nvTCPClient = connections(sender.ToString)
                                                                       If Not TCPClient Is Nothing Then
                                                                           Dim app_cod_sistema As String = "nv_admin"
                                                                           Dim nro_operador As Integer = 14
                                                                           Dim cod_sistema_operador As String = app_cod_sistema & "||" & nro_operador
                                                                           If Not TCPClient.cod_sistema_operadores.Contains(cod_sistema_operador) Then
                                                                               TCPClient.cod_sistema_operadores.Add(cod_sistema_operador)
                                                                           End If
                                                                       End If

                                                                   End If
                                                               Next


                                                           Catch ex As Exception

                                                           End Try

                                                       End Sub
                nvTCPListen.listenON(1099)
            End If


        End Sub


        Public Shared Function add(socket As System.Net.Sockets.Socket, codimplement As String) As nvTCPClient
            Dim item As New nvTCPClient
            item.socket = socket
            item.codimplement = codimplement
            connections.Add(socket.ToString, item)
            Return item
        End Function


        ' Comprobar que un operador este conectado y vinculado por al menos un socket al servidor sistema
        Public Shared Function getOperadorSistemaTCPClient(cod_sistema_operador As String) As nvTCPClient

            For Each cn As nvTCPClient In connections.Values
                If cn.cod_sistema_operadores.Contains(cod_sistema_operador) Then
                    If cn.vinculado And isClientConnectionAlive(cn) Then
                        Return cn
                    End If
                End If
            Next
            Return Nothing

        End Function


        ' Comprobar que un operador este conectado y vinculado por al menos un socket al servidor sistema
        Public Shared Function operadorSistemaIsOnline(cod_sistema_operador As String) As Boolean

            For Each cn As nvTCPClient In connections.Values
                If cn.cod_sistema_operadores.Contains(cod_sistema_operador) Then
                    If cn.vinculado And isClientConnectionAlive(cn) Then
                        Return True
                    End If
                End If
            Next
            Return False

        End Function


        ' Comprobar que un socket cliente este vinculado y su conexion viva
        Public Shared Function socketIsOnline(socket As String) As Boolean

            If connections.ContainsKey(socket) Then
                Dim cn As nvTCPClient = connections(socket)
                If cn.vinculado And isClientConnectionAlive(cn) Then
                    Return True
                Else
                    Return False
                End If
            End If

            Return False

        End Function



        Public Shared Function isClientConnectionAlive(TCPClient As nvTCPClient) As Boolean
            Try
                ' En cliente android, el primer ping despues de la conexión no arroja una excepción
                nvTCPListen.SendMessage(TCPClient.socket.RemoteEndPoint.ToString, "ping")
                System.Threading.Thread.Sleep(2000)
                nvTCPListen.SendMessage(TCPClient.socket.RemoteEndPoint.ToString, "ping")
                Return True
            Catch Ex As Exception
                Return False
            End Try

        End Function

        Public Shared Sub sendMessage(socket As String, errData As tError)

            If connections.ContainsKey(socket) Then

                ' El cliente se puede haber cerrado de manera no explicita (terminado por android, error de conexion etc)
                ' Un error sera arrojado eventualmente, si es que se ha desconectado

                Try
                    nvTCPClients.nvTCPListen.SendMessage(socket, "ping")
                    System.Threading.Thread.Sleep(2000)
                    nvTCPClients.nvTCPListen.SendMessage(socket, errData.get_error_xml)
                Catch e As Exception
                    ' No hay que borrar, porque el cliente guarda la info para la reconexion
                    'connections.remove(socket)

                    Throw e
                End Try


            Else
                Throw New Exception("El socket del cliente no ha sido encontrado")

            End If

        End Sub



        Public Class nvTCPClient
            Public socket As System.Net.Sockets.Socket
            Public codimplement As String
            Public cod_sistema_operadores As New List(Of String)

            Public vinculado As Boolean = False
            Public vinculoSignature As String
        End Class
    End Class

End Namespace