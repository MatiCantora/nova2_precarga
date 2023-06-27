Imports System
Imports System.CodeDom
Imports System.Collections.Generic
Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvPages

Namespace nvFW
    Namespace nvPages
        Public Class nvPageMutualPrecarga
            Inherits nvPageBase

            'Public Shadows operador As nvOperadorAdmin

            Private _classname As String = "nvPageMutualPrecarga"
            Private _app_cod_sistema As String = "nv_mutualprecarga"
            Private _app_sistema As String = "Nova Mutual Precarga"
            Private _app_path_rel As String = "precarga"




            Protected Overrides Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
                MyBase.Page_Load(sender, e)
            End Sub

            Public Sub New()
                MyBase.setAPP(_app_cod_sistema, _app_sistema, _app_path_rel)
            End Sub

            Public ReadOnly Property operador As tnvOperadorPrecarga
                Get
                    Return MyBase.operador
                End Get
            End Property


            Public Overrides Function app_config() As tError
                Dim res As tError = MyBase.app_config()
                If res.numError = 0 Then
                    Dim rs As ADODB.Recordset
                    Try

                        Dim operador As New tnvOperadorPrecarga
                        operador.login = nvApp.operador.login
                        operador.nombre_operador = nvApp.operador.nombre_operador
                        operador.nro_entidad = nvApp.operador.nro_entidad
                        operador.operador = nvApp.operador.operador
                        operador.ads_usuario = nvApp.operador.ads_usuario
                        operador.AutLevel = nvApp.operador.AutLevel

                        rs = nvDBUtiles.DBOpenRecordset("select * from veroperadores where operador = " & nvApp.operador.operador)
                        operador.nro_sucursal = nvUtiles.isNUll(rs.Fields("nro_sucursal").Value, 0)
                        operador.sucursal = nvUtiles.isNUll(rs.Fields("sucursal").Value, "Sin sucursal")

                        operador.nro_docu = rs.Fields("nro_docu").Value
                        operador.razon_social = rs.Fields("strNombreCompleto").Value
                        operador.sucursal_postal_real = rs.Fields("sucursal_postal_real").Value
                        operador.localidad = rs.Fields("localidad").Value
                        operador.cod_prov = rs.Fields("sucursal_cod_prov").Value
                        operador.provincia = rs.Fields("sucursal_provincia").Value

                        operador.setVendedorFromNroDocu(operador.nro_docu)

                        'Try
                        '    rs = nvDBUtiles.DBOpenRecordset("select *, dbo.rm_vendedor_dependencia(nro_vendedor) as dependientes from vervendedores where nro_docu = " & operador.nro_docu)
                        '    If Not rs.EOF Then
                        '        operador.nro_vendedor = rs.Fields("nro_vendedor").Value
                        '        operador.vendedor = rs.Fields("strNombreCompleto").Value
                        '        operador.nro_estructura = rs.Fields("nro_estructura").Value
                        '        operador.estructura = rs.Fields("estructura").Value
                        '        operador.dependientes = rs.Fields("dependientes").Value
                        '    End If

                        'Catch ex4 As Exception

                        'Finally
                        '    nvDBUtiles.DBCloseRecordset(rs)
                        'End Try

                        nvApp.operador = operador
                    Catch ex As Exception
                        nvApp.appState = enumnvAppState.not_loaded
                        res.parse_error_script(ex)
                        res.titulo = ""
                        res.debug_src = "nvPageAdmin::app_config()"
                    Finally
                        nvDBUtiles.DBCloseRecordset(rs)
                    End Try
                End If
                Return res
            End Function
            Public Overrides Function getHeadInit() As String
                Dim includes As New Dictionary(Of String, Boolean)
                Return getHeadInit(includes)
            End Function

            Public Overrides Function getHeadInit(ByRef includes As Dictionary(Of String, Boolean)) As String
                Dim retHTML As String = MyBase.getHeadInit(includes)
                Dim retScript As String = ""
                If includes Is Nothing Then
                    includes = New Dictionary(Of String, Boolean)
                End If

                If Not includes.Keys.Contains("general") Then includes.Add("general", True)


                If includes("general") Then
                    retScript += "var nro_operador = '" & operador.operador & "'" & vbCrLf
                    retScript += "var login = '" & operador.login & "'" & vbCrLf
                    'retScript += "var sucursal_defecto = '" & operador.sucursal & "'" & vbCrLf
                    retScript += "nvFW.operador = {}" & vbCrLf
                    retScript += "nvFW.operador.nro_operador = " & operador.operador & vbCrLf
                    retScript += "nvFW.operador.login = '" & operador.login & "'" & vbCrLf
                    retScript += "nvFW.operador.razon_social = '" & operador.razon_social & "'" & vbCrLf
                    retScript += "nvFW.operador.nro_sucursal = '" & operador.nro_sucursal & "'" & vbCrLf
                    retScript += "nvFW.operador.sucursal = '" & operador.sucursal & "'" & vbCrLf
                    retScript += "nvFW.operador.cod_prov = " & operador.cod_prov & vbCrLf
                    retScript += "nvFW.operador.provincia = '" & operador.provincia & "'" & vbCrLf
                    retScript += "nvFW.operador.cp = " & operador.sucursal_postal_real & vbCrLf
                    retScript += "nvFW.operador.localidad = '" & operador.localidad & "'" & vbCrLf
                    retScript += "nvFW.operador.nro_vendedor = " & operador.nro_vendedor & vbCrLf
                    retScript += "nvFW.operador.vendedor = '" & operador.vendedor & "'" & vbCrLf
                    retScript += "nvFW.operador.nro_estructura = " & operador.nro_estructura & vbCrLf
                    retScript += "nvFW.operador.estructura = '" & operador.estructura & "'" & vbCrLf

                End If

                If retScript <> "" Then
                    retScript = "<script  type='text/javascript' language='javascript' id='nvPageAdmin_HeadInit' name='nvPageAdmin_HeadInit'>" & vbCrLf & retScript & "</script>" & vbCrLf
                End If

                Return retHTML & vbCrLf & retScript
            End Function

            <Serializable()>
            Public Class tnvOperadorPrecarga
                Inherits nvSecurity.tnvOperador

                Public nro_docu As Integer
                Public razon_social As String = ""
                Public nro_sucursal As Integer
                Public sucursal As String
                Public nro_vendedor As Integer = 0
                Public nro_estructura As Integer = 0
                Public estructura As String = ""
                Public sucursal_postal_real As Integer = 0
                Public localidad As String = ""
                Public cod_prov As Integer = 0
                Public provincia As String = ""
                Public dependientes As String = ""
                Public vendedor As String = ""

                'Public vendedor As New trsParam

                'Public Overrides Function tienePermiso(ByVal permiso_grupo As String, ByVal nro_permiso As Integer) As Boolean
                '    Dim _nro_permiso As Integer = 1
                '    While nro_permiso <> 1 AndAlso Math.Pow(nro_permiso, 1 / (_nro_permiso - 1)) <> 2 AndAlso _nro_permiso < 32
                '        _nro_permiso += 1
                '    End While

                '    Return MyBase.tienePermiso(permiso_grupo, _nro_permiso)

                'End Function

                Public Sub New()
                    MyBase.New()

                End Sub

                Public Sub setVendedorFromNroDocu(nro_docu As Integer)
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select *, dbo.rm_vendedor_dependencia(nro_vendedor) as dependientes from vervendedores where nro_docu = " & nro_docu)
                    setVendedorRs(rs)
                End Sub

                Public Sub setVendedor(nro_vendedor As Integer)
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select *, dbo.rm_vendedor_dependencia(nro_vendedor) as dependientes from vervendedores where nro_vendedor = " & nro_vendedor)
                    setVendedorRs(rs)
                End Sub
                Public Sub setVendedorRs(rs As ADODB.Recordset)
                    '    Dim rs As New ADODB.Recordset
                    Try
                        If Not rs.EOF Then
                            nro_vendedor = rs.Fields("nro_vendedor").Value
                            vendedor = rs.Fields("strNombreCompleto").Value
                            nro_estructura = rs.Fields("nro_estructura").Value
                            estructura = rs.Fields("estructura").Value
                            dependientes = rs.Fields("dependientes").Value
                        End If

                    Catch ex4 As Exception

                    Finally
                        nvDBUtiles.DBCloseRecordset(rs)
                    End Try
                End Sub

            End Class


            '        Dim opParams As New trsParam
            'opParams("vendedor_provincia") = ""
            'opParams("cod_prov_op") = ""
            'opParams("sucursal_postal_real") = ""
            'opParams("nro_docu") = 0
            'opParams("strVendedor") = ""
            'opParams("nro_estructura") = ""
            'opParams("nro_vendedor") = ""

            'Try
            '        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from veroperadores where operador = " & Me.operador.operador)
            '    opParams("vendedor_provincia") = rs.Fields("sucursal_provincia").Value
            '    opParams("cod_prov_op") = rs.Fields("sucursal_cod_prov").Value
            '    opParams("sucursal_postal_real") = rs.Fields("sucursal_postal_real").Value
            '    opParams("nro_docu") = rs.Fields("nro_docu").Value '4292472
            '    nvDBUtiles.DBCloseRecordset(rs)
            'Catch ex As Exception

            '        End Try
            '        If opParams("nro_docu") <> 0 Then
            '        Try
            '        Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("select * from vervendedores where nro_docu = " & opParams("nro_docu"))
            '        opParams("strVendedor") = rs.Fields("strNombreCompleto").Value
            '        opParams("nro_vendedor") = rs.Fields("nro_vendedor").Value
            '        opParams("nro_estructura") = rs.Fields("nro_estructura").Value
            '        nvDBUtiles.DBCloseRecordset(rs)
            '    Catch ex As Exception

            '        End Try
            '        End If

        End Class

    End Namespace
End Namespace