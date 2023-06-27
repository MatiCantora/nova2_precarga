Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvPages
Imports nvFW.nvSecurity

Namespace nvFW
    Namespace nvPages
        Public Class nvPageWiki
            Inherits nvPageBase

            'Public Shadows operador As nvOperadorAdmin


            Private _classname As String = "nvPageWiki"
            Private _app_cod_sistema As String = "nv_wiki"
            Private _app_sistema As String = "Nova Wiki"
            Private _app_path_rel As String = "wiki"


            Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
                MyBase.Page_Load(sender, e)
            End Sub

            Public Sub New()
                MyBase.setAPP(_app_cod_sistema, _app_sistema, _app_path_rel)
            End Sub

            Public Overrides Function app_config() As tError
                Dim res As tError = MyBase.app_config()
                If res.numError = 0 Then

                End If
                Return res
            End Function

            <Serializable()>
            Public Class tnvOperadorWiki
                Inherits nvSecurity.tnvOperador

                'Public nro_sucursal As Integer
                'Public sucursal As String

                Public Sub New()
                    MyBase.New()
                End Sub

                Public Overrides Function save() As tError
                    Dim err As tError = MyBase.save()
                    If err.numError = 0 Then
                        'update de la sucursal
                        Dim strSQL As String = "Update operadores set nro_sucursal = " & Me.datos("nro_sucursal").value & " where operador = " & Me.operador
                        nvDBUtiles.DBExecute(strSQL)
                    End If
                    Return err
                End Function


                Public Overrides Function load(login As String) As Boolean
                    Dim res As String = MyBase.load(login)
                    If res Then
                        Dim strSQL As String = "Select nro_sucursal from operadores where [login] = '" & login & "'"
                        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                        Dim dato As New nvSecurity.tnvOperadorDato
                        If Me.datos.ContainsKey("nro_sucursal") = False Then
                            dato.name = "nro_sucursal"
                            dato.label = "Nro de sucursal"
                            dato.campo_def = "nro_sucursal"
                            dato.value = rs.Fields("nro_sucursal").Value
                            Me.datos.Add("nro_sucursal", dato)
                        End If
                        nvDBUtiles.DBCloseRecordset(rs)
                    End If
                    Return res
                End Function
                Public Overrides Function load(operador As Integer) As Boolean
                    Dim res As String = MyBase.load(operador)
                    If res Then
                        Dim strSQL As String = "Select nro_sucursal from operadores where operador = " & operador
                        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                        Dim dato As New nvSecurity.tnvOperadorDato
                        dato.name = "nro_sucursal"
                        dato.label = "Nro de sucursal"
                        dato.campo_def = "nro_sucursal"
                        dato.value = rs.Fields("nro_sucursal").Value
                        Me.datos.Add("nro_sucursal", dato)
                        nvDBUtiles.DBCloseRecordset(rs)
                    End If
                    Return res
                End Function

            End Class

        End Class

    End Namespace
End Namespace
