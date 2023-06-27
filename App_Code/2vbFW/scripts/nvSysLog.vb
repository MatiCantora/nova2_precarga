Imports System
Imports System.Net
Imports System.Net.Sockets
Imports System.Runtime.InteropServices
Imports System.Threading
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW.nvSysLog
    Public Class nvSysLogClient
        Public Shared Sub Send(ByVal host As String, ByVal port As Integer, ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
            Dim ElSocket As New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
            Try

                Dim ips() As IPAddress = Dns.GetHostEntry(host).AddressList
                Dim ip As IPAddress = Nothing
                For i = 0 To ips.Count - 1
                    If ips(i).AddressFamily = AddressFamily.InterNetwork Then
                        ip = ips(i)
                        Exit For
                    End If
                Next
                If Not ip Is Nothing Then

                    Dim DirecciónDestino As New IPEndPoint(ip, port)
                    Dim priority As Integer = facility * 8 + level
                    Dim msg As String = System.String.Format("<{0}>{1}",
                                                         priority,
                                                         text)
                    Dim DatosBytes As Byte() = nvConvertUtiles.StringToBytes(msg)
                    ElSocket.SendTo(DatosBytes, DatosBytes.Length, SocketFlags.None, DirecciónDestino)
                End If
            Catch ex As Exception
            Finally
                Try
                    ElSocket.Close()
                Catch ex As Exception
                End Try
            End Try
        End Sub
    End Class

    Public Enum enumSysLogLevel
        Emergency = 0
        Alert = 1
        Critical = 2
        [Error] = 3
        Warning = 4
        Notice = 5
        Information = 6
        Debug = 7
    End Enum

    Public Enum enumSysLogFacility
        Kernel = 0
        User = 1
        Mail = 2
        Daemon = 3
        Auth = 4
        Syslog = 5
        Lpr = 6
        News = 7
        UUCP = 8
        Cron = 9
        Local0 = 10
        Local1 = 11
        Local2 = 12
        Local3 = 13
        Local4 = 14
        Local5 = 15
        Local6 = 16
        Local7 = 17
    End Enum

    'Public Class nvSysLogMessage
    '    Private _facility As enumSysLogFacility
    '    Public Property Facility() As enumSysLogFacility
    '        Get
    '            Return _facility
    '        End Get
    '        Set(ByVal value As enumSysLogFacility)
    '            _facility = value
    '        End Set
    '    End Property

    '    Private _level As enumSysLogLevel
    '    Public Property Level() As enumSysLogLevel
    '        Get
    '            Return _level
    '        End Get
    '        Set(ByVal value As enumSysLogLevel)
    '            _level = value
    '        End Set
    '    End Property

    '    Private _text As String
    '    Public Property Text() As String
    '        Get
    '            Return _text
    '        End Get
    '        Set(ByVal value As String)
    '            _text = value
    '        End Set
    '    End Property

    '    Public Sub New()

    '    End Sub
    '    Public Sub New(ByVal facility As enumSysLogFacility, ByVal level As enumSysLogLevel, ByVal text As String)
    '        _facility = facility
    '        _level = level
    '        _text = text
    '    End Sub

    'End Class

    'Public Class UdpClientEx
    '    Inherits System.Net.Sockets.UdpClient
    '    Public Sub New()
    '        MyBase.New()
    '    End Sub

    '    Public Sub New(ByVal ipe As IPEndPoint)
    '        MyBase.New(ipe)
    '    End Sub

    '    Protected Overrides Sub Finalize()
    '        If (Me.Active) Then
    '            Me.Close()
    '        End If
    '        MyBase.Finalize()
    '    End Sub

    '    Public ReadOnly Property IsActive() As Boolean
    '        Get
    '            Return Me.Active
    '        End Get
    '    End Property
    'End Class

    '<Microsoft.VisualBasic.ComClass()> Public Class nvSysLogClient
    '    Private ipHostInfo As IPHostEntry
    '    Private ipAddress As IPAddress
    '    Private ipLocalEndPoint As IPEndPoint
    '    Private udpClient As UdpClientEx
    '    Private _sysLogServerIp As String = ""
    '    Private _port As Integer = 514
    '    Private _pvCodError As Integer

    '    Public Sub New()
    '        MyBase.New()
    '        ipHostInfo = Dns.GetHostEntry(Dns.GetHostName())
    '        ipAddress = ipHostInfo.AddressList(0)
    '        ipLocalEndPoint = New IPEndPoint(ipAddress, 0)
    '        udpClient = New UdpClientEx(ipLocalEndPoint)
    '        Me._pvCodError = 0
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(1)> Public Sub init()

    '    End Sub

    '    <System.Runtime.InteropServices.DispId(2)> Public ReadOnly Property IsActive() As Boolean
    '        Get
    '            Return udpClient.IsActive
    '        End Get
    '    End Property

    '    <System.Runtime.InteropServices.DispId(3)> Public Sub Close()
    '        If udpClient.IsActive Then
    '            udpClient.Close()
    '        End If
    '    End Sub

    '    <System.Runtime.InteropServices.DispId(4)> Public Property Port() As Integer
    '        Get
    '            Return _port
    '        End Get
    '        Set(ByVal value As Integer)
    '            _port = value
    '        End Set
    '    End Property

    '    <System.Runtime.InteropServices.DispId(5)> Public Property SysLogServerIp() As String
    '        Get
    '            Return _sysLogServerIp
    '        End Get
    '        Set(ByVal value As String)
    '            If Not IsActive Then
    '                _sysLogServerIp = value
    '                'udpClient.Connect(_hostIp, _port);
    '            End If
    '        End Set
    '    End Property

    '    Private Sub Send(ByVal message As nvSysLog.nvSysLogMessage)
    '        Me._pvCodError = 0
    '        If Not udpClient.IsActive Then
    '            udpClient.Connect(_sysLogServerIp, _port)
    '        End If
    '        If udpClient.IsActive Then
    '            Dim priority As Integer = message.Facility * 8 + message.Level
    '            Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '                                              priority, _
    '                                              DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '                                              ipLocalEndPoint.Address, _
    '                                              message.Text)
    '            Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '            udpClient.Send(bytes, bytes.Length)
    '        Else
    '            Throw New Exception("nvSysLogClient Socket no conectado.")
    '            Me._pvCodError = -1
    '        End If


    '    End Sub

    '    <System.Runtime.InteropServices.DispId(6)> _
    '    Public Sub Send(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        Try
    '            If Not udpClient.IsActive Then
    '                udpClient.Connect(_sysLogServerIp, _port)
    '            End If
    '            If udpClient.IsActive Then
    '                Dim priority As Integer = facility * 8 + level
    '                Dim msg As String = System.String.Format("<{0}>{1}", _
    '                                                         priority, _
    '                                                         text)
    '                'Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '                '                                  priority, _
    '                '                                  DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '                '                                  ipLocalEndPoint.Address, _
    '                '                                  text)
    '                Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '                udpClient.BeginSend(bytes, bytes.Length, Nothing, Nothing)
    '            Else
    '                Me._pvCodError = -1
    '            End If
    '        Catch ex As Exception
    '        End Try
    '    End Sub

    '    <System.Runtime.InteropServices.DispId(7)> Protected Overrides Sub Finalize()
    '        MyBase.Finalize()
    '        If udpClient.IsActive Then
    '            udpClient.Close()
    '        End If
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(8)> Public Property pvCodError() As Integer
    '        Get
    '            Return Me._pvCodError
    '        End Get
    '        Set(ByVal value As Integer)

    '        End Set
    '    End Property
    'End Class

    '<Microsoft.VisualBasic.ComClass()> Public Class nvSysLogClient2
    '    Private ipHostInfo As IPHostEntry
    '    Private ipAddress As IPAddress
    '    Private ipLocalEndPoint As IPEndPoint
    '    'Private udpClient As nvSysLog.UdpClientEx
    '    Private _sysLogServerIp As String = ""
    '    Private _port As Integer = 514
    '    Private _pvCodError As Integer

    '    Public Sub New()
    '        MyBase.New()
    '        ipHostInfo = Dns.GetHostEntry(Dns.GetHostName())
    '        ipAddress = ipHostInfo.AddressList(0)
    '        ipLocalEndPoint = New IPEndPoint(ipAddress, 0)
    '        'udpClient = New nvSysLog.UdpClientEx(ipLocalEndPoint)
    '        Me._pvCodError = 0
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(1)> Public Sub init()

    '    End Sub

    '    <System.Runtime.InteropServices.DispId(4)> _
    '    Public Property Port() As Integer
    '        Get
    '            Return _port
    '        End Get
    '        Set(ByVal value As Integer)
    '            _port = value
    '        End Set
    '    End Property

    '    <System.Runtime.InteropServices.DispId(5)> _
    '    Public Property SysLogServerIp() As String
    '        Get
    '            Return _sysLogServerIp
    '        End Get
    '        Set(ByVal value As String)
    '            _sysLogServerIp = value
    '            'udpClient.Connect(_hostIp, _port);
    '        End Set
    '    End Property

    '    Private Delegate Sub _Send_delegate(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '    Private Sub _Send(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        Dim udpClient As New System.Net.Sockets.UdpClient
    '        Try
    '            udpClient.Connect(Dns.GetHostEntry(_sysLogServerIp).AddressList(0), _port)
    '            Dim priority As Integer = facility * 8 + level
    '            Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '                                              priority, _
    '                                              DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '                                              ipLocalEndPoint.Address, _
    '                                              text)
    '            Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '            udpClient.Send(bytes, bytes.Length)
    '        Catch ex As Exception
    '            'Throw New Exception("nvSysLogClient Socket no conectado.")
    '            Me._pvCodError = -1
    '        End Try
    '        udpClient.Close()
    '        udpClient = Nothing
    '    End Sub


    '    <System.Runtime.InteropServices.DispId(6)> _
    '    Public Sub Send(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        _Send(facility, level, text)
    '    End Sub


    '    <System.Runtime.InteropServices.DispId(7)> _
    '    Protected Overrides Sub Finalize()
    '        MyBase.Finalize()
    '    End Sub

    '    <System.Runtime.InteropServices.DispId(8)> _
    '    Public Property pvCodError() As Integer
    '        Get
    '            Return Me._pvCodError
    '        End Get
    '        Set(ByVal value As Integer)

    '        End Set
    '    End Property

    '    '<System.Runtime.InteropServices.DispId(9)> _
    '    'Public Sub Send2(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '    '    Dim _t As Threading.Thread
    '    '    _t = New Threading.Thread(AddressOf Send)
    '    '    _t.Start(2)
    '    'End Sub
    'End Class



    '<Microsoft.VisualBasic.ComClass()> Public Class nvSysLogClient3
    '    Private ipHostInfo As IPHostEntry
    '    Private ipAddress As IPAddress
    '    Private ipLocalEndPoint As IPEndPoint
    '    Public Facility As Integer
    '    Public Level As Integer
    '    Public Text As String
    '    'Private udpClient As nvSysLog.UdpClientEx
    '    Private _sysLogServerIp As String = ""
    '    Private _port As Integer = 514

    '    Public Sub New()
    '        MyBase.New()
    '        ipHostInfo = Dns.GetHostEntry(Dns.GetHostName())
    '        ipAddress = ipHostInfo.AddressList(0)
    '        ipLocalEndPoint = New IPEndPoint(ipAddress, 0)
    '        'udpClient = New nvSysLog.UdpClientEx(ipLocalEndPoint)
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(1)> Public Sub init()

    '    End Sub

    '    <System.Runtime.InteropServices.DispId(4)> _
    '    Public Property Port() As Integer
    '        Get
    '            Return _port
    '        End Get
    '        Set(ByVal value As Integer)
    '            _port = value
    '        End Set
    '    End Property

    '    <System.Runtime.InteropServices.DispId(5)> _
    '    Public Property SysLogServerIp() As String
    '        Get
    '            Return _sysLogServerIp
    '        End Get
    '        Set(ByVal value As String)
    '            _sysLogServerIp = value
    '            'udpClient.Connect(_hostIp, _port);
    '        End Set
    '    End Property

    '    Private Sub _Send()
    '        Dim udpClient As New System.Net.Sockets.UdpClient
    '        Try
    '            udpClient.Connect(Dns.GetHostEntry(_sysLogServerIp).AddressList(0), _port)
    '            Dim priority As Integer = Me.Facility * 8 + Me.Level
    '            Dim msg As String = System.String.Format("<{0}>", _
    '                                              Me.Text)
    '            'Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '            '                                  priority, _
    '            '                                  DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '            '                                  ipLocalEndPoint.Address, _
    '            '                                  Me.Text)
    '            Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '            udpClient.Send(bytes, bytes.Length)
    '        Catch ex As Exception
    '            'Throw New Exception("nvSysLogClient Socket no conectado.")
    '        Finally
    '            udpClient.Close()
    '            udpClient = Nothing
    '        End Try

    '    End Sub


    '    <System.Runtime.InteropServices.DispId(6)> _
    '    Public Sub Send()
    '        Try
    '            Dim _th As Thread
    '            _th = New Thread(AddressOf _Send)
    '            _th.Start()
    '        Catch ex As Exception
    '            Thread.CurrentThread.Sleep(200)
    '            Send()
    '        End Try
    '    End Sub
    '    Public Sub Send2()
    '        _Send()
    '    End Sub


    '    <System.Runtime.InteropServices.DispId(7)> _
    '    Protected Overrides Sub Finalize()
    '        MyBase.Finalize()
    '    End Sub


    '    '<System.Runtime.InteropServices.DispId(9)> _
    '    'Public Sub Send2(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '    '    Dim _t As Threading.Thread
    '    '    _t = New Threading.Thread(AddressOf Send)
    '    '    _t.Start(2)
    '    'End Sub
    'End Class



    '<Microsoft.VisualBasic.ComClass()> Public Class nvSysLogClient4
    '    Private ipHostInfo As IPHostEntry
    '    Private ipAddress As IPAddress
    '    Private ipLocalEndPoint As IPEndPoint
    '    Private udpClient As nvSysLog.UdpClientEx
    '    Private _sysLogServerIp As String = ""
    '    Private _port As Integer = 514
    '    Private _pvCodError As Integer
    '    Private _agenteSend As Thread
    '    Private _cola As Collection

    '    Private Class colaItem
    '        Public facility As Integer
    '        Public level As Integer
    '        Public text As String
    '    End Class

    '    Public Sub New()
    '        MyBase.New()
    '        ipHostInfo = Dns.GetHostEntry(Dns.GetHostName())
    '        ipAddress = ipHostInfo.AddressList(0)
    '        ipLocalEndPoint = New IPEndPoint(ipAddress, 0)
    '        udpClient = New nvSysLog.UdpClientEx(ipLocalEndPoint)
    '        Me._pvCodError = 0
    '        _cola = New Collection
    '        _agenteSend = New Thread(AddressOf controlar_y_enviar)
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(1)> Public Sub init()

    '    End Sub

    '    <System.Runtime.InteropServices.DispId(2)> Public ReadOnly Property IsActive() As Boolean
    '        Get
    '            Return udpClient.IsActive
    '        End Get
    '    End Property

    '    <System.Runtime.InteropServices.DispId(3)> Public Sub Close()
    '        If udpClient.IsActive Then
    '            udpClient.Close()
    '        End If
    '    End Sub

    '    <System.Runtime.InteropServices.DispId(4)> Public Property Port() As Integer
    '        Get
    '            Return _port
    '        End Get
    '        Set(ByVal value As Integer)
    '            _port = value
    '        End Set
    '    End Property

    '    <System.Runtime.InteropServices.DispId(5)> Public Property SysLogServerIp() As String
    '        Get
    '            Return _sysLogServerIp
    '        End Get
    '        Set(ByVal value As String)
    '            If Not IsActive Then
    '                _sysLogServerIp = value
    '                'udpClient.Connect(_hostIp, _port);
    '            End If
    '        End Set
    '    End Property

    '    Private Sub _Send(ByVal message As nvSysLog.nvSysLogMessage)
    '        Me._pvCodError = 0
    '        If Not udpClient.IsActive Then
    '            udpClient.Connect(_sysLogServerIp, _port)
    '        End If
    '        If udpClient.IsActive Then
    '            Dim priority As Integer = message.Facility * 8 + message.Level
    '            Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '                                              priority, _
    '                                              DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '                                              ipLocalEndPoint.Address, _
    '                                              message.Text)
    '            Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '            udpClient.Send(bytes, bytes.Length)
    '        Else
    '            Throw New Exception("nvSysLogClient Socket no conectado.")
    '            Me._pvCodError = -1
    '        End If


    '    End Sub

    '    <System.Runtime.InteropServices.DispId(6)> _
    '    Private Sub _Send(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        Try
    '            If Not udpClient.IsActive Then
    '                udpClient.Connect(_sysLogServerIp, _port)
    '            End If
    '            If udpClient.IsActive Then
    '                Dim priority As Integer = facility * 8 + level
    '                Dim msg As String = System.String.Format("<{0}>{1}", _
    '                                                         priority, _
    '                                                         text)
    '                'Dim msg As String = System.String.Format("<{0}>{1} {2} {3}", _
    '                '                                  priority, _
    '                '                                  DateTime.Now.ToString("MMM dd HH:mm:ss"), _
    '                '                                  ipLocalEndPoint.Address, _
    '                '                                  text)
    '                Dim bytes() As Byte = System.Text.Encoding.ASCII.GetBytes(msg)
    '                udpClient.BeginSend(bytes, bytes.Length, Nothing, Nothing)
    '            Else
    '                Me._pvCodError = -1
    '            End If
    '        Catch ex As Exception
    '        End Try
    '    End Sub
    '    Public Sub Send(ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        Dim it As New colaItem
    '        SyncLock _cola
    '            it.facility = facility
    '            it.level = level
    '            it.text = text
    '            _cola.Add(it)
    '        End SyncLock
    '        If Not _agenteSend.IsAlive Then
    '            _agenteSend = New Thread(AddressOf controlar_y_enviar)
    '            _agenteSend.Start()
    '        End If
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(7)> Protected Overrides Sub Finalize()
    '        MyBase.Finalize()
    '        If udpClient.IsActive Then
    '            udpClient.Close()
    '        End If
    '    End Sub
    '    <System.Runtime.InteropServices.DispId(8)> Public Property pvCodError() As Integer
    '        Get
    '            Return Me._pvCodError
    '        End Get
    '        Set(ByVal value As Integer)

    '        End Set
    '    End Property

    '    Private Sub controlar_y_enviar()
    '        Dim i As Integer
    '        Dim it As New colaItem
    '        SyncLock _cola
    '            For i = 1 To _cola.Count
    '                it = _cola(i)
    '                _Send(it.facility, it.level, it.text)
    '            Next
    '            _cola.Clear()
    '        End SyncLock
    '    End Sub
    'End Class

    '<Microsoft.VisualBasic.ComClass()> _
    'Public Class nvSysLogClient5
    '    <System.Runtime.InteropServices.DispId(20)> _
    '    Public Sub Send(ByVal host As String, ByVal port As Integer, ByVal facility As Integer, ByVal level As Integer, ByVal text As String)
    '        Dim ElSocket As New Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp)
    '        Try
    '            Dim DirecciónDestino As New IPEndPoint(Dns.GetHostEntry(host).AddressList(0), port)
    '            Dim priority As Integer = facility * 8 + level
    '            Dim msg As String = System.String.Format("<{0}>{1}", _
    '                                                 priority, _
    '                                                 text)
    '            Dim DatosBytes As Byte() = System.Text.Encoding.Default.GetBytes(msg)
    '            ElSocket.SendTo(DatosBytes, DatosBytes.Length, SocketFlags.None, DirecciónDestino)
    '        Catch ex As Exception
    '        Finally
    '            Try
    '                ElSocket.Close()
    '            Catch ex As Exception
    '            End Try
    '        End Try
    '    End Sub

    'End Class

   
End Namespace