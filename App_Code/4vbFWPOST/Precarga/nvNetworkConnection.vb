Imports Microsoft.VisualBasic
Imports System.ComponentModel
Imports System.Net
Imports System.Runtime.InteropServices
Namespace nvFW
    Namespace servicios
        Public Class nvNetworkConnection
            Implements System.IDisposable

            Private _networkName As String

            Public Sub New(ByVal networkName As String, ByVal credentials As NetworkCredential)
                _networkName = networkName
                Dim netResource = New NetResource() With {
            .Scope = ResourceScope.GlobalNetwork,
            .ResourceType = ResourceType.Disk,
            .DisplayType = ResourceDisplaytype.Share,
            .RemoteName = networkName
        }
                Dim result = WNetAddConnection2(netResource, credentials.Password, credentials.UserName, 0)

                If result <> 0 Then
                    Throw New Win32Exception(result, "Error connecting to remote share")
                End If
            End Sub

            Protected Overrides Sub Finalize()
                Dispose(False)
            End Sub

            Public Sub Dispose()
                Dispose(True)
                GC.SuppressFinalize(Me)
            End Sub

            Protected Overridable Sub Dispose(ByVal disposing As Boolean)
                WNetCancelConnection2(_networkName, 0, True)
            End Sub

            <DllImport("mpr.dll")>
            Private Shared Function WNetAddConnection2(ByVal netResource As NetResource, ByVal password As String, ByVal username As String, ByVal flags As Integer) As Integer
            End Function

            <DllImport("mpr.dll")>
            Private Shared Function WNetCancelConnection2(ByVal name As String, ByVal flags As Integer, ByVal force As Boolean) As Integer
            End Function

            Private Sub IDisposable_Dispose() Implements IDisposable.Dispose

            End Sub
        End Class
        <StructLayout(LayoutKind.Sequential)>
        Public Class NetResource
            Public Scope As ResourceScope
            Public ResourceType As ResourceType
            Public DisplayType As ResourceDisplaytype
            Public Usage As Integer
            Public LocalName As String
            Public RemoteName As String
            Public Comment As String
            Public Provider As String
        End Class

        Public Enum ResourceScope As Integer
            Connected = 1
            GlobalNetwork
            Remembered
            Recent
            Context
        End Enum

        Public Enum ResourceType As Integer
            Any = 0
            Disk = 1
            Print = 2
            Reserved = 8
        End Enum

        Public Enum ResourceDisplaytype As Integer
            Generic = &H0
            Domain = &H1
            Server = &H2
            Share = &H3
            File = &H4
            Group = &H5
            Network = &H6
            Root = &H7
            Shareadmin = &H8
            Directory = &H9
            Tree = &HA
            Ndscontainer = &HB
        End Enum

    End Namespace
End Namespace