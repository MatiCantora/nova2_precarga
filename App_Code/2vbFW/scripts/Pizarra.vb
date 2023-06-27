Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW
    Public Class Pizarra
        Public Shared Function value(ByVal pizarra As String, ByVal ParamArray list() As String) As String
            Try
                Dim strFunction As String = "select "
                Select Case list.Count
                    Case 1
                        strFunction += "dbo.piz1D"
                    Case 2
                        strFunction += "dbo.piz2D"
                    Case 3
                        strFunction += "dbo.piz3D"
                    Case 4
                        strFunction += "dbo.piz4D"
                    Case 5
                        strFunction += "dbo.piz5D"
                    Case 6
                        strFunction += "dbo.piz6D"
                    Case 7
                        strFunction += "dbo.piz7D"
                    Case 8
                        strFunction += "dbo.piz8D"
                    Case 9
                        strFunction += "dbo.piz9D"
                    Case 10
                        strFunction += "dbo.piz10D"
                End Select

                strFunction += "(" & nvConvertUtiles.objectToSQLScript(pizarra) & ", "

                For i = 0 To list.Count - 1
                    strFunction += nvConvertUtiles.objectToSQLScript(list(i)) & ", "
                Next

                If list.Count > 0 Then
                    strFunction = strFunction.Substring(0, strFunction.Length - 2)
                End If

                strFunction += ") as return_value"

                strFunction = "SET NOCOUNT ON" & vbCrLf & strFunction

                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strFunction)
                Dim res As String = rs.Fields("return_value").Value
                DBCloseRecordset(rs)

                Return res
            Catch ex As Exception
                Return ""
            End Try

        End Function

        Public Shared Function values(ByVal pizarra As String, ByVal ParamArray list() As String) As String()
            Dim res(2) As String
            res(0) = ""
            res(1) = ""
            res(2) = ""
            Try
                Dim strFunction As String = "select * from "
                Select Case list.Count
                    Case 1
                        strFunction += "dbo.piz1D_values"
                    Case 2
                        strFunction += "dbo.piz2D_values"
                    Case 3
                        strFunction += "dbo.piz3D_values"
                    Case 4
                        strFunction += "dbo.piz4D_values"
                    Case 5
                        strFunction += "dbo.piz5D_values"
                    Case 6
                        strFunction += "dbo.piz6D_values"
                    Case 7
                        strFunction += "dbo.piz7D_values"
                    Case 8
                        strFunction += "dbo.piz8D_values"
                    Case 9
                        strFunction += "dbo.piz9D_values"
                    Case 10
                        strFunction += "dbo.piz10D_values"
                End Select

                strFunction += "(" & nvConvertUtiles.objectToSQLScript(pizarra) & ", "

                For i = 0 To list.Count - 1
                    strFunction += nvConvertUtiles.objectToSQLScript(list(i)) & ", "
                Next

                If list.Count > 0 Then
                    strFunction = strFunction.Substring(0, strFunction.Length - 2)
                End If

                strFunction += ") "

                strFunction = "SET NOCOUNT ON" & vbCrLf & strFunction

                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strFunction)

                res(0) = rs.Fields("valor1").Value
                res(1) = rs.Fields("valor2").Value
                res(2) = rs.Fields("valor3").Value
                DBCloseRecordset(rs)

                Return res
            Catch ex As Exception
                Return res
            End Try

        End Function


        Public Shared Function values_matriz(ByVal pizarra As String, ByVal ParamArray list() As String) As List(Of Dictionary(Of String, String))

            Dim listPizValues = New List(Of Dictionary(Of String, String))()

            Try
                Dim strFunction As String = "select * from "
                Select Case list.Count
                    Case 1
                        strFunction += "dbo.piz1D_values"
                    Case 2
                        strFunction += "dbo.piz2D_values"
                    Case 3
                        strFunction += "dbo.piz3D_values"
                    Case 4
                        strFunction += "dbo.piz4D_values"
                    Case 5
                        strFunction += "dbo.piz5D_values"
                    Case 6
                        strFunction += "dbo.piz6D_values"
                    Case 7
                        strFunction += "dbo.piz7D_values"
                    Case 8
                        strFunction += "dbo.piz8D_values"
                    Case 9
                        strFunction += "dbo.piz9D_values"
                    Case 10
                        strFunction += "dbo.piz10D_values"
                End Select

                strFunction += "(" & nvConvertUtiles.objectToSQLScript(pizarra) & ", "

                For i = 0 To list.Count - 1
                    strFunction += nvConvertUtiles.objectToSQLScript(list(i)) & ", "
                Next

                If list.Count > 0 Then
                    strFunction = strFunction.Substring(0, strFunction.Length - 2)
                End If

                strFunction += ") "

                strFunction = "SET NOCOUNT ON" & vbCrLf & strFunction

                Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strFunction)

                While Not rs.EOF

                    Dim dicPizValues As New Dictionary(Of String, String)

                    dicPizValues.Add("valor1", rs.Fields("valor1").Value)
                    dicPizValues.Add("valor2", rs.Fields("valor2").Value)
                    dicPizValues.Add("valor3", rs.Fields("valor3").Value)

                    listPizValues.Add(dicPizValues)

                    rs.MoveNext()
                End While


                DBCloseRecordset(rs)

                Return listPizValues
            Catch ex As Exception
                Return listPizValues
            End Try

        End Function

    End Class

End Namespace