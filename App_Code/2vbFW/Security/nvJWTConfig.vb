Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Namespace nvFW.nvSecurity

    Public Class nvJWTConfig

        Public Shared PKI_cod_sistema As String = "nv_ids"
        Public Shared PKI_name As String = "Main"
        Public Shared JWT_exprie_minutes As String = 25
        Public Shared JWT_iss As String = "IDS"


        Public Shared _PKI As tnvPKI
        Public Shared _MyCert As System.Security.Cryptography.X509Certificates.X509Certificate2

        Public Shared ReadOnly Property PKI As tnvPKI
            Get
                If _PKI Is Nothing Then _loadPKI()

                Return _PKI
            End Get
        End Property

        Public Shared ReadOnly Property MyCert As System.Security.Cryptography.X509Certificates.X509Certificate2
            Get
                If _PKI Is Nothing Then _loadPKI()

                Return _MyCert
            End Get
        End Property


        'Private Shared Sub _loadPKI(nvApp As tnvApp)
        '    Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2
        '    'Dim oPKI As tnvPKI '= Application.Contents("_Main_PKI")
        '    Dim myCerts As Dictionary(Of String, Org.BouncyCastle.X509.X509Certificate)
        '    If _PKI Is Nothing Then
        '        _PKI = nvFW.nvPKIDBUtil.LoadPKIFromDB("Main", nvApp)
        '    End If
        '    myCerts = _PKI.myCerts()
        '    If myCerts.Count > 0 Then
        '        _MyCert = _PKI.certs_X509Certificate2(myCerts.First.Key)
        '        'Application.Contents("_Main_PKI_myCert") = cert
        '    End If
        'End Sub
        Private Shared Sub _loadPKI()
            Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2
            'Dim oPKI As tnvPKI '= Application.Contents("_Main_PKI")
            Dim myCerts As Dictionary(Of String, Org.BouncyCastle.X509.X509Certificate)
            If _PKI Is Nothing Then
                Dim nvApp As New tnvApp
                nvFW.nvApp.set_app_from_cod(nvApp, PKI_cod_sistema)
                nvApp.cod_servidor = nvServer.cod_servidor
                nvApp.loadCNAndDir()
                _PKI = nvFW.nvPKIDBUtil.LoadPKIFromDB(PKI_name, nvApp)
            End If
            myCerts = _PKI.myCerts()
            If myCerts.Count > 0 Then
                _MyCert = _PKI.certs_X509Certificate2(myCerts.First.Key)
                'Application.Contents("_Main_PKI_myCert") = cert
            End If

        End Sub

    End Class

End Namespace