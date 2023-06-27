Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvWindowsLogon
        Private Declare Auto Function LogonUser Lib "advapi32.dll" (ByVal lpszUsername As [String],
            ByVal lpszDomain As [String], ByVal lpszPassword As [String],
            ByVal dwLogonType As Integer, ByVal dwLogonProvider As Integer,
            ByRef phToken As IntPtr) As Boolean


        'Private Declare Function logonUser Lib "advapi32.dll" _
        '    Alias "LogonUserA" (ByVal lpszUsername As String, _
        '    ByVal lpszDomain As String, ByVal lpszPassword As String, _
        '    ByVal dwLogonType As Long, ByVal dwLogonProvider As Long, _
        '    ByVal phToken As Long) As Long

        'Private Declare Function CloseHandle Lib "kernel32" (ByVal hObject As Long) As Long
        Public Declare Auto Function CloseHandle Lib "kernel32.dll" (ByVal handle As IntPtr) As Boolean

        Private Const LOGON32_LOGON_INTERACTIVE = 2
        Private Const LOGON32_PROVIDER_DEFAULT = 0

        Public Shared Function Logon(ByVal strAdminUser As String, ByVal _
         strAdminPassword As String, ByVal strAdminDomain As String) As Boolean
            Dim lngTokenHandle, lngLogonType, lngLogonProvider As Long
            Dim blnResult As Boolean

            lngLogonType = LOGON32_LOGON_INTERACTIVE
            lngLogonProvider = LOGON32_PROVIDER_DEFAULT


            blnResult = LogonUser(strAdminUser, strAdminDomain, strAdminPassword,
                                                 lngLogonType, lngLogonProvider,
                                                 lngTokenHandle)

            CloseHandle(lngTokenHandle)
            Return blnResult

        End Function
    End Class

End Namespace