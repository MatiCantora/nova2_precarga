Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvSICA
        Public Interface InvSicaObjetoGrupo
            Sub loadFromImplementation(objME As tSicaObjeto,
                                       nvApp As tnvApp,
                                       cod_objeto_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                       path As String,
                                       objeto As String,
                                       Optional cod_sub_tipo As Integer = 0,
                                       Optional chargeBinary As Boolean = False,
                                       Optional bytes() As Byte = Nothing)
            Sub saveToImplementation(objME As tSicaObjeto, nvApp As tnvApp)
            Function checkIntegrity(objME As tSicaObjeto, rescab As tResCab, nvApp As tnvApp) As nvenumResStatus
            Function hasImplementation() As Boolean
        End Interface



        Public Class nvSicaObjetoGrupo
            Private Shared _es_Grupo_cod_obj_tipos As Dictionary(Of tSicaObjeto.nvEnumObjeto_tipo, Boolean)


            Public Shared Function getObject(cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo) As Object
                Dim objeto As Object = Nothing

                Select Case cod_obj_tipo
                    Case tSicaObjeto.nvEnumObjeto_tipo.transferencia
                        objeto = New tnvSicaTipoTransferencia

                    Case tSicaObjeto.nvEnumObjeto_tipo.permiso_grupo
                        objeto = New tnvSicaPermisoGrupo

                    Case tSicaObjeto.nvEnumObjeto_tipo.pizarra
                        objeto = New tnvSicaPizarra

                    Case tSicaObjeto.nvEnumObjeto_tipo.parametro
                        objeto = New tnvSicaParametro

                End Select

                Return objeto
            End Function


            Public Shared Function esGrupo(cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo) As Boolean
                If _es_Grupo_cod_obj_tipos Is Nothing Then loadGrupo_cod_obj_tipos(_es_Grupo_cod_obj_tipos)

                Return _es_Grupo_cod_obj_tipos(cod_obj_tipo)
            End Function


            Private Shared Sub loadGrupo_cod_obj_tipos(ByRef diccionarioGrupos As Dictionary(Of tSicaObjeto.nvEnumObjeto_tipo, Boolean))
                _es_Grupo_cod_obj_tipos = New Dictionary(Of tSicaObjeto.nvEnumObjeto_tipo, Boolean)
                Dim strSQL As String = "SELECT cod_obj_tipo, esGrupo FROM nv_objeto_tipos ORDER BY cod_obj_tipo"
                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                While Not rs.EOF
                    _es_Grupo_cod_obj_tipos.Add(rs.Fields("cod_obj_tipo").Value, rs.Fields("esGrupo").Value)
                    rs.MoveNext()
                End While

                nvDBUtiles.DBCloseRecordset(rs)
            End Sub

        End Class
    End Namespace
End Namespace
