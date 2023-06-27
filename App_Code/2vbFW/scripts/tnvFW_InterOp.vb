Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Public Class tnvFW_InterOp

    Public nvCampo_def As New tnvCampo_def
    Public nvXMLSQL As New tnvXMLSQL

    Public ReadOnly Property nvApp As tnvApp
        Get
            Return nvFW.nvApp.getInstance()
        End Get
    End Property

    Public Shared Function new_class(ByVal clase As String) As Object
        Select Case clase
            Case "trsParam"
                Dim o As trsParam = New trsParam
                Return o
            Case Else
                Return Nothing
        End Select
    End Function

    Public Class tnvCampo_def
        Public Function get_html_input(ByVal campo_def As String, Optional ByVal filtroXML As String = "" _
                                                                      , Optional ByVal filtroWhere As String = "" _
                                                                      , Optional ByVal vistaGuardada As String = "" _
                                                                      , Optional ByVal depende_de As String = "" _
                                                                      , Optional ByVal depende_de_campo As String = "" _
                                                                      , Optional ByVal nro_campo_tipo As enumnvCampo_def_tipos = 1 _
                                                                      , Optional ByVal permite_codigo As Boolean = False _
                                                                      , Optional ByVal json As Boolean = True _
                                                                      , Optional ByVal cacheControl As String = "" _
                                                                      , Optional ByVal enDB As Boolean = True _
                                                                      , Optional ByRef parametros As Dictionary(Of String, Object) = Nothing) As String
            Return nvFW.nvCampo_def.get_html_input(campo_def, filtroXML, filtroWhere, vistaGuardada, depende_de, depende_de_campo, nro_campo_tipo, permite_codigo, json, cacheControl, enDB, parametros)
        End Function
    End Class

    Public Class tnvXMLSQL
        Public Function encXMLSQL(ByVal strXML As String) As String
            Return nvFW.nvXMLSQL.encXMLSQL(strXML)
        End Function
    End Class



End Class
