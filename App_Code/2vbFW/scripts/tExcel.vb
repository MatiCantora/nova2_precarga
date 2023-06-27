Imports Microsoft.VisualBasic
Imports nvFW
Imports Microsoft.Office.Interop
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW

    Public Class tExcel

        Public Sub New()
            MyBase.New()
        End Sub

        Public filename As String = ""
        Public DBConnection_string As String = ""
        Public adoRecordset As New ADODB.Recordset


        Public Function DBConnect(ByVal cn_string As String) As ADODB.Connection
            Dim cn As New ADODB.Connection
            cn.Open(cn_string)
            Return cn
        End Function

        Public Function ExcelLeerCabecera(ByVal Optional primerFilaNomColumna As Boolean = True, ByVal Optional hoja As String = "Hoja1") As tError

            Dim err As New nvFW.tError
            err.params("strXML") = ""

            
            Me.DBConnection_string = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & Me.filename & ""
            If primerFilaNomColumna = True Then
                Me.DBConnection_string += ";Extended Properties='EXCEL 12.0 Xml;HDR=YES'"
            Else
                Me.DBConnection_string += ";Extended Properties='EXCEL 12.0 Xml;HDR=NO'"
            End If

            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            arParam("logTrack") = ""

            Dim obCommand As ADODB.Command = New ADODB.Command()
            Dim rs As New ADODB.Recordset
            Try

                obCommand.ActiveConnection = DBConnect(DBConnection_string)
                obCommand.CommandType = ADODB.CommandTypeEnum.adCmdText
                obCommand.CommandText = "select top 1 * from [" & hoja & "$] " 'where 1=2"
                obCommand.Prepared = True

                rs = obCommand.Execute()

                Dim XML As System.Xml.XmlDocument
                XML = New System.Xml.XmlDocument
                XML = nvXMLSQL.RecordsetToXML(rs, arParam)

                err.params("strXML") = XML.OuterXml

            Catch ex As Exception
                err.numError = -99
                err.mensaje = ex.Message.ToString
            End Try

            nvDBUtiles.DBCloseRecordset(rs)

            Return err

        End Function

        Public Function listaHojasExcel() As tError
            Dim err As New tError
            Dim exAPP As Excel.Application
            Dim exLibro As Excel.Workbook
            Dim exHoja As Excel.Worksheet
            Dim listHojas As String = ""
            Try
                exAPP = New Excel.Application
                exAPP.Visible = False
                exAPP.DisplayAlerts = False

                exLibro = exAPP.Workbooks.Open(Me.filename)
                exHoja = exLibro.Worksheets(1)

                Dim cantHojas = exLibro.Sheets.Count
                For i = 1 To cantHojas - 1
                    listHojas += exLibro.Sheets.Item(i).name + ","
                Next
                listHojas += exLibro.Sheets.Item(cantHojas).name
                err.numError = 0
                err.params("listHojas") = listHojas
                exLibro.Close()
                exAPP.Quit()
            Catch e As Exception
                err.parse_error_script(e)
                err.numError = 200
                err.titulo = "Error al leer archivo excel. "
                err.mensaje = "Error: " & e.Message & e.ToString
                exLibro.Close()
                exAPP.Quit()
            End Try

            Return err
        End Function


        Public Function ExcelLeerArchivo(ByVal Optional primerFilaNomColumna As Boolean = True, ByVal Optional hoja As String = "Hoja1") As tError

            Dim err As New nvFW.tError
            err.params("strXML") = ""

            Me.DBConnection_string = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & Me.filename & ""
            If primerFilaNomColumna = True Then
                Me.DBConnection_string += ";Extended Properties='EXCEL 8.0;HDR=YES'"
            Else
                Me.DBConnection_string += ";Extended Properties='EXCEL 8.0;HDR=NO'"
            End If

            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            arParam("logTrack") = ""

            Dim obCommand As ADODB.Command = New ADODB.Command()
            Dim rs As New ADODB.Recordset
            Try

                obCommand.ActiveConnection = DBConnect(DBConnection_string)
                obCommand.CommandType = ADODB.CommandTypeEnum.adCmdText
                obCommand.CommandText = "select * from [" & hoja & "$]"
                obCommand.Prepared = True

                rs = obCommand.Execute()

                Dim XML As System.Xml.XmlDocument
                XML = New System.Xml.XmlDocument
                XML = nvXMLSQL.RecordsetToXML(rs, arParam)

                err.params("strXML") = XML.OuterXml

            Catch ex As Exception
                err.numError = -99
                err.mensaje = ex.Message.ToString
            End Try

            nvDBUtiles.DBCloseRecordset(rs)

            Return err

        End Function


        Public Function ExcelLeerDatos3(Optional ByVal primerFilaNomColumna As Boolean = True, Optional ByVal hoja As String = "Hoja1") As ADODB.Recordset
            Dim adoRecordset As New ADODB.Recordset
            Dim exAPP As Excel.Application = New Excel.Application
            Dim er As New tError

            exAPP.Visible = False
            exAPP.DisplayAlerts = False
            Dim exLibro As Excel.Workbook
            Dim path_1 = System.IO.Path.GetTempFileName() + ".xls"

            Try
                exLibro = exAPP.Workbooks.Open(Me.filename)
               
                'Guardar el archivo con formato xls
               ' exLibro.SaveAs(path_1, FileFormat:=56)

                Dim ohoja As Excel.Worksheet
                ohoja = exLibro.Worksheets(1)

                For i = 0 To exLibro.Worksheets.Count - 1
                    If exLibro.Sheets.Item(i + 1).name = hoja Then
                        ohoja = exLibro.Sheets.Item(i + 1)
                    End If
                Next

                Dim xlXML As Object = CreateObject("MSXML2.DOMDocument")

               'Dim lastCol = ohoja.Range("a1").End(Excel.XlDirection.xlToRight).Column
               'Dim lastRow = ohoja.Range("a1").End(Excel.XlDirection.xlDown).Row

			    Dim cel1 = ohoja.Range("A1").End(Excel.XlDirection.xlToRight).Address
               Dim cel2 = ohoja.Range("A1").End(Excel.XlDirection.xlDown).Address


                Try
                   ' Dim strXML = ohoja.Range("a1", ohoja.Cells(lastRow, lastCol)).Value(Excel.XlRangeValueDataType.xlRangeValueMSPersistXML)
                    Dim strXML = ohoja.Range(cel1, cel2).Value(Excel.XlRangeValueDataType.xlRangeValueMSPersistXML)

                    xlXML.LoadXML(strXML)
                Catch ex As Runtime.InteropServices.COMException
                   er.parse_error_script(ex)
                End Try

                'cargar el recorset con el xml
                adoRecordset.Open(xlXML)

                exLibro.Close()
                exAPP.Quit()
                System.IO.File.Delete(path_1)

            Catch ex As Exception
                exLibro.Close()
                exAPP.Quit()
                System.IO.File.Delete(path_1)
                er.parse_error_script(ex)
                er.mostrar_error()
            End Try

            Return adoRecordset

        End Function



        Public Function ExcelLeerDatos2(Optional ByVal primerFilaNomColumna As Boolean = True, Optional ByVal hoja As String = "Hoja1") As tError
            'Dim adoRecordset As New ADODB.Recordset
            Dim exAPP As Excel.Application = New Excel.Application
            Dim er As New tError
            er.numError = 0

            exAPP.Visible = False
            exAPP.DisplayAlerts = False
            Dim exLibro As Excel.Workbook

            Try
                exLibro = exAPP.Workbooks.Open(Me.filename)

                Dim ohoja As Excel.Worksheet
                ohoja = exLibro.Worksheets(1)

                For i = 0 To exLibro.Worksheets.Count - 1
                    If exLibro.Sheets.Item(i + 1).name = hoja Then
                        ohoja = exLibro.Sheets.Item(i + 1)
                    End If
                Next


                Dim xlXML As Object = CreateObject("MSXML2.DOMDocument")

               Dim lastCol = ohoja.Range("a1").End(Excel.XlDirection.xlToRight).Column
               Dim lastRow = ohoja.Range("a1").End(Excel.XlDirection.xlDown).Row



                Try
                    Dim strXML = ohoja.Range("a1", ohoja.Cells(lastRow, lastCol)).Value(Excel.XlRangeValueDataType.xlRangeValueMSPersistXML)
                    xlXML.LoadXML(strXML)
					'cargar el recorset con el xml
					Me.adoRecordset.Open(xlXML)
                Catch ex As Runtime.InteropServices.COMException
                   'Stop
                   er.parse_error_script(ex)
                   er.numError = 1001
                   er.mensaje = "Error al cargar XML desde el excel. " + ex.Message
                    Return er
                End Try

                exLibro.Close()
                exAPP.Quit()

            Catch ex As Exception
                exLibro.Close()
                exAPP.Quit()
                er.parse_error_script(ex)
                 er.numError = 200
                 er.mensaje = "Error al convertir XML to recordset. " + ex.Message
            End Try

            Return er

        End Function

    End Class
End Namespace
