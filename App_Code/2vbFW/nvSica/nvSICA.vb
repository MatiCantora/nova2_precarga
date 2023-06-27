Imports System.Threading
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW
    Namespace nvSICA

        Public Class currentApp

            Public Shared Function control_integridad_iniciar(Optional ByVal cod_modulo_versiones As String = "", Optional ByVal cod_tipos As String = "", Optional ByVal filtroObjeto As String = "", Optional filtroFechaMod As DateTime = Nothing) As tError
                Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance()
                Return Implementation.control_integridad_iniciar(nvApp, cod_modulo_versiones, cod_tipos, filtroObjeto, filtroFechaMod)
            End Function



            Public Shared Function control_integridad_abortar() As tError
                Dim nvApp As nvFW.tnvApp = nvFW.nvApp.getInstance()
                Return Implementation.control_integridad_abortar(nvApp)
            End Function

        End Class



        Public Class path

            Public Shared Function PhysicalToLogical(ByRef nvApp As tnvApp, ByVal path As String) As String
                Dim res As String = path
                Dim cod_dir As String
                Dim paths() As String

                For Each cod_dir In nvApp.app_dirs.Keys
                    paths = nvApp.app_dirs(cod_dir).path.Split(";")

                    For Each npath As String In paths
                        If npath <> "" Then res = res.Replace(npath, "%" & cod_dir & "%\")
                    Next
                Next

                res = res.Replace(nvApp.ports.physical_path & nvApp.path_rel & "\", "%PATH_REL%\")
                res = res.Replace(nvApp.ports.physical_path, "%RAIZ%\")
                Return res
            End Function


            Public Shared Function LogicalToPhysical(ByRef nvApp As tnvApp, ByVal path As String) As String
                Dim res As String = path
                res = res.Replace("%RAIZ%\", nvApp.ports.physical_path)
                res = res.Replace("%PATH_REL%\", nvApp.ports.physical_path & nvApp.path_rel & "\")
                Dim cod_dir As String
                Dim paths() As String

                For Each cod_dir In nvApp.app_dirs.Keys
                    paths = nvApp.app_dirs(cod_dir).path.Split(";")

                    For Each npath As String In paths
                        If npath <> "" Then res = res.Replace("%" & cod_dir & "%\", nvApp.app_dirs(cod_dir).path)
                    Next
                Next

                Return res
            End Function


            Public Shared Function getParamRel(ByRef nvApp As tnvApp, ByVal path As String) As String
                If path.IndexOf("%RAIZ%\") = 0 Then Return "%RAIZ%\"
                If path.IndexOf("%PATH_REL%\") = 0 Then Return "%PATH_REL%\"

                For Each cod_dir As String In nvApp.app_dirs.Keys
                    If path.IndexOf("%" & cod_dir & "%\") = 0 Then Return "%" & cod_dir & "%\"
                Next

                Return ""
            End Function


            Public Shared Function getParamRelPath(ByRef nvApp As tnvApp, ByVal path As String) As String
                If path.IndexOf("%RAIZ%\") = 0 Then Return nvApp.ports.physical_path
                If path.IndexOf("%PATH_REL%\") = 0 Then Return nvApp.ports.physical_path & nvApp.path_rel & "\"

                For Each cod_dir As String In nvApp.app_dirs.Keys
                    If path.IndexOf("%" & cod_dir & "%\") = 0 Then Return nvApp.app_dirs(cod_dir).path
                Next

                Return ""
            End Function

        End Class



        <Serializable()>
        Public Class tResCab
            Public id_res_cab As Integer
            Public nvApp As tnvApp
            Public fe_inicio As Date
            Public fe_fin As Date
            Public elements As List(Of tResElement)
            Public pg_count As Integer
            Public pg_pos As Integer
            Public pi_count As Integer
            Public pi_pos As Integer
            Public total_count As Integer
            Public thread As Thread
            Public cod_modulo_versiones As String
            Public cod_tipos As String
            Public filtroObjeto As String
            Public filtroFechaMod As DateTime = Nothing
            Public check_modulo_vresion As Dictionary(Of Integer, String)
            Public check_cod_tipos As Dictionary(Of Integer, String)

            Public status As tResCabStatusCode = tResCabStatusCode.no_iniciado
            Public status_err_msg As String = ""
            Public progress_info As String = ""

            Public cod_pasajes As String = Nothing


            Public Sub New()
                elements = New List(Of tResElement)
            End Sub


            Public Enum tResCabStatusCode
                no_iniciado = 0
                iniciado = 1
                finalizado = 2
                abortado = 3
                finalizado_err = 4
            End Enum
        End Class


        <Serializable()>
        Public Class tResElement
            Public cod_objeto As Integer
            Public objeto As String
            Public path As String
            Public cod_obj_tipo As Integer
            Public cod_sub_tipo As Integer
            Public cod_modulo_version As Integer
            Public cod_pasaje As Integer
            Public resStatus As nvenumResStatus = nvenumResStatus.OK    ' Estado de integridad
            Public logInstallMsg As String                              ' Mensaje arrojado al instalar el objeto
            Public comentario As String
            Public depende_de As String
        End Class


        Public Enum nvenumResStatus
            OK = 0
            objeto_no_econtrado = 1
            objeto_modificado = 2
            archivo_sobrante = 3
        End Enum


        Public Class Definition

            Public Shared Sub objetos_eliminar(ByVal strXML As String)
                Dim cmd As New nvDBUtiles.tnvDBCommand("sica_modulo_version_objetos_eliminar", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_admin)
                cmd.Parameters("@binXML").Value = strXML
                cmd.Execute()
            End Sub


            Public Shared Sub objeto_eliminar(ByVal cod_modulo_version As Integer, ByVal cod_objeto As Integer, ByVal path As String, Optional ByVal cod_pasaje As Integer = 0, Optional ByRef cn As ADODB.Connection = Nothing)
                Dim cmd As New nvDBUtiles.tnvDBCommand("sica_modulo_version_objeto_eliminar", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_admin, cn:=cn)
                cmd.Parameters("@cod_modulo_version").Value = cod_modulo_version
                cmd.Parameters("@cod_objeto").Value = cod_objeto
                cmd.Parameters("@path").Value = path

                If cod_pasaje > 0 Then cmd.Parameters("@cod_pasaje").Value = cod_pasaje

                cmd.Execute()
            End Sub


            Public Shared Function checkBinary(ByVal cod_objeto As Integer, ByRef bytes As Byte()) As Boolean
                Dim Cmd As New nvDBUtiles.tnvDBCommand("sica_eval_binary", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_admin, "",
                                                                   ADODB.CursorTypeEnum.adOpenStatic, , 0, ADODB.CursorLocationEnum.adUseClient)
                Cmd.addParameter("@cod_objeto", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 0, cod_objeto)

                If bytes.Length <> 0 Then
                    Cmd.addParameter("@valor", ADODB.DataTypeEnum.adLongVarBinary, ADODB.ParameterDirectionEnum.adParamInput, bytes.Length, bytes)
                End If

                Dim rsEvalBinary As ADODB.Recordset = Cmd.Execute()
                Dim res As Boolean = rsEvalBinary.Fields("binaryOK").Value = 0
                nvDBUtiles.DBCloseRecordset(rsEvalBinary)

                Return res
            End Function



            ' Devuelve la definicion de los objetos que se encuentran implementados en el servidor sistema especificado, para las versiónes de módulos señalada
            Public Shared Function getServidorSistemaObjetosDef(ByVal cod_servidor As String, ByVal cod_sistema As String, ByVal cod_modulo_versiones As String, Optional ByVal filtro As String = "", Optional ByVal orden As String = "") As ADODB.Recordset
                Dim listModuloVersiones As List(Of String) = cod_modulo_versiones.Split(",").ToList()
                Dim xmlModuloVersiones As String = "<?xml version='1.0' encoding='iso-8859-1'?><modulo_versiones>"

                For Each modulo_version As String In listModuloVersiones
                    xmlModuloVersiones &= "<modulo_version>" & modulo_version & "</modulo_version>"
                Next

                xmlModuloVersiones &= "</modulo_versiones>"
                xmlModuloVersiones = xmlModuloVersiones.Replace("'", "''")

                Dim xmlPasajes As String = "<?xml version='1.0' encoding='iso-8859-1'?><pasajes>"
                Dim strSQL As String = "SELECT A.cod_pasaje" &
                                        " FROM nv_servidor_sistema_pasajes A" &
                                        " INNER JOIN nv_pasajes B ON B.cod_pasaje=A.cod_pasaje AND b.cod_modulo_version IN (" & cod_modulo_versiones & ")" &
                                        " WHERE cod_sistema='" & cod_sistema & "' AND cod_servidor='" & cod_servidor & "'" &
                                        " ORDER BY fecha_pasaje ASC"
                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                If Not rs.EOF Then
                    While Not rs.EOF
                        xmlPasajes &= "<pasaje>" & rs.Fields("cod_pasaje").Value.ToString() & "</pasaje>"
                        rs.MoveNext()
                    End While
                End If

                nvDBUtiles.DBCloseRecordset(rs)
                xmlPasajes &= "</pasajes>"
                xmlPasajes = xmlPasajes.Replace("'", "''")

                strSQL = "exec [sica_modulo_pasajes_sumarizar] '" & xmlModuloVersiones & "', '" & xmlPasajes & "', '*', '" & filtro.Replace("'", "''") & "', '" & orden & "' "
                Dim cmd As New nvDBUtiles.tnvDBCommand(strSQL, ADODB.CommandTypeEnum.adCmdText, nvDBUtiles.emunDBType.db_admin)
                Return cmd.Execute()
            End Function
        End Class



        Public Class Implementation

            Public Shared Function sistema_pasajes_iniciar(ByRef nvapp As tnvApp, Optional ByVal cod_pasajes As String = "") As tError
                Dim retError As New tError
                Dim objetos_simples As New List(Of Integer)({1, 2, 3, 4, 5, 6, 8})
                Dim objetos_complejos As New List(Of Integer)({7, 9, 12, 13})

                'Dim cod_tipos As String = "1,2,3,4,5,6,8" ' Todos los objetos simples
                Dim cod_tipos As String = String.Join(",", objetos_simples) & "," & String.Join(",", objetos_complejos) ' Todos los objetos

                Try
                    ' Controlar que no haya un proceso ejecutandose
                    If Not nvapp.sica_implementacion Is Nothing AndAlso nvapp.sica_implementacion.thread.IsAlive Then
                        retError.numError = 10
                        retError.titulo = "Error implementacion pasajes"
                        retError.mensaje = "Error al iniciar el proceso de implementación de pasajes. Hay un proceso ya iniciado."
                        retError.debug_src = "nvSica::sistema_implementacion_aplicar_pasajes"
                        Return retError
                    End If

                    nvapp.sica_implementacion = New tResCab
                    nvapp.sica_implementacion.elements = New List(Of tResElement)
                    nvapp.sica_implementacion.thread = New System.Threading.Thread(New ParameterizedThreadStart(AddressOf Implementation.sistema_pasajes_aplicar))
                    nvapp.sica_implementacion.nvApp = nvapp
                    nvapp.sica_implementacion.cod_pasajes = cod_pasajes
                    nvapp.sica_implementacion.cod_tipos = cod_tipos
                    nvapp.sica_implementacion.thread.Start(nvapp.sica_implementacion)
                Catch ex As Exception
                    retError.parse_error_script(ex)
                    retError.titulo = "Error implementacion pasajes"
                    retError.mensaje = "Error al iniciar el proceso de implementación de pasajes."
                    retError.debug_src = "nvSica::sistema_implementacion_aplicar_pasajes"
                    retError.debug_desc = ex.Message
                End Try

                Return retError
            End Function


            Public Shared Sub sistema_pasajes_aplicar(ByVal resCab As tResCab)
                resCab.fe_inicio = Now()
                resCab.progress_info = ""

                Dim nvApp As tnvApp = resCab.nvApp
                Dim cod_pasajes As String = resCab.cod_pasajes
                Dim cod_pasajes_list() As String = cod_pasajes.Split(",")

                Dim aplicar_pasaje As Boolean
                Dim pasaje_no_autorizado As Boolean
                Dim cod_pasaje_dep As String
                Dim rs As ADODB.Recordset
                Dim query As String

                Try
                    For Each cod_pasaje As String In cod_pasajes_list
                        ' Revisar si está AUTORIZADO
                        query = String.Format("SELECT 1 FROM nv_servidor_sistema_pasajes_autorizaciones WHERE cod_pasaje={0}", cod_pasaje)
                        rs = nvDBUtiles.ADMDBOpenRecordset(query)
                        pasaje_no_autorizado = rs.EOF
                        nvDBUtiles.DBCloseRecordset(rs)

                        ' Si pasaje NO está autorizado, salvar progreso y continuar con el siguiente
                        If pasaje_no_autorizado Then
                            resCab.progress_info &= "El pasaje " & cod_pasaje & " no se encuentra autorizado. Se omite su instalación</br>"
                            Continue For
                        End If

                        query = String.Format("SELECT 1 FROM nv_servidor_sistema_pasajes " &
                                              "WHERE cod_servidor='{0}' AND cod_sistema='{1}' AND cod_pasaje={2}", nvApp.cod_servidor, nvApp.cod_sistema, cod_pasaje)
                        rs = nvDBUtiles.ADMDBOpenRecordset(query)
                        aplicar_pasaje = rs.EOF
                        nvDBUtiles.DBCloseRecordset(rs)

                        ' Si el pasaje ya está instalado, salvar progreso y continuar con el siguiente
                        If Not aplicar_pasaje Then
                            resCab.progress_info &= "El pasaje " & cod_pasaje & " ya se encuentra instalado. Se omite instalación</br>"
                            Continue For
                        End If

                        ' Revisar si tiene pasajes dependientes y aplicarlos
                        query = String.Format("SELECT DISTINCT (cod_pasaje_depende) AS cod_pasaje_dep, level, pasaje_nom " &
                                                "FROM nvGetPasajeDependencias({0}) A " &
                                                    "WHERE cod_pasaje_Depende NOT IN( " &
                                                        "SELECT cod_pasaje FROM nv_servidor_sistema_pasajes " &
                                                        "WHERE cod_servidor='{1}' AND cod_sistema='{2}') " &
                                                "ORDER BY A.level DESC", cod_pasaje, nvApp.cod_servidor, nvApp.cod_sistema)
                        rs = nvDBUtiles.ADMDBOpenRecordset(query)

                        While Not rs.EOF
                            cod_pasaje_dep = rs.Fields("cod_pasaje_dep").Value
                            pasaje_aplicar(cod_pasaje_dep, resCab)
                            rs.MoveNext()
                        End While

                        nvDBUtiles.DBCloseRecordset(rs)

                        ' Aplicar el pasaje actual
                        pasaje_aplicar(cod_pasaje, resCab)
                    Next

                    resCab.progress_info &= "El proceso finalizó"
                    resCab.status = tResCab.tResCabStatusCode.finalizado
                Catch ex As Exception
                    Dim tEx As ThreadAbortException = TryCast(ex, ThreadAbortException)

                    If Not tEx Is Nothing Then
                        resCab.progress_info &= "El proceso fue abortado"
                    Else
                        resCab.progress_info &= "El proceso se interrumpió porque ocurrió un error..."
                    End If

                    resCab.status_err_msg = ex.Message
                End Try

                resCab.fe_fin = Now()
            End Sub


            Private Shared Sub pasaje_aplicar(ByVal cod_pasaje As Integer, ByRef resCab As tResCab)
                Dim nvApp As tnvApp = resCab.nvApp

                Try
                    '-- Script/s INICIO -----------------------------
                    pasaje_scripts_ejecutar(cod_pasaje, resCab, 0)

                    '-- Quitar objetos especificados ----------------
                    pasaje_quitar_objetos(nvApp, resCab, cod_pasaje)

                    resCab.progress_info &= "Creando objetos...</br>"
                    resCab.pi_pos = 0
                    resCab.total_count = 0
                    resCab.pg_pos = 1
                    resCab.pg_count = resCab.cod_tipos.Split(",").Count ' Cada etapa de instalacion por tipo de objeto

                    '-- Implementar ---------------------------------
                    implementar(nvApp, resCab, cod_pasaje)

                    '-- Script/s FIN --------------------------------
                    pasaje_scripts_ejecutar(cod_pasaje, resCab, 1)

                    resCab.progress_info &= "Fin de instalación de pasaje " & cod_pasaje & "</br>"
                    nvDBUtiles.ADMDBExecute("insert into nv_servidor_sistema_pasajes(cod_servidor, cod_sistema, cod_pasaje, fecha_pasaje, operador) values('" & nvApp.cod_servidor & "', '" & nvApp.cod_sistema & "', " & cod_pasaje.ToString & ", GETDATE(), " & nvApp.operador.operador.ToString & ")")
                Catch ex As Exception
                    Try
                        '-- Script/s ROLLBACK -----------------------
                        pasaje_scripts_ejecutar(cod_pasaje, resCab, 2)
                    Catch rollbackEx As Exception
                    End Try

                    Throw ex
                End Try
            End Sub


            Private Shared Sub pasaje_scripts_ejecutar(ByVal cod_pasaje As Integer, ByRef resCab As tResCab, ByVal cod_sub_tipo As Integer)
                Dim nvApp As tnvApp = resCab.nvApp
                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset("SELECT objeto, cod_objeto, path, cod_modulo_version FROM verNv_sistema_version_objetos WHERE cod_sistema_version=" & nvApp.cod_sistema_version & " AND cod_pasaje=" & cod_pasaje & " AND cod_obj_tipo=11 AND cod_sub_tipo=" & cod_sub_tipo)
                Dim objeto As String = ""

                Try
                    Dim cod_objeto As String
                    Dim path As String
                    Dim cod_modulo_version As Integer
                    Dim oSica As tSicaObjeto

                    While Not rs.EOF
                        cod_objeto = rs.Fields("cod_objeto").Value
                        path = rs.Fields("path").Value
                        cod_modulo_version = rs.Fields("cod_modulo_version").Value
                        objeto = rs.Fields("objeto").Value

                        Select Case cod_sub_tipo
                            Case 0
                                resCab.progress_info &= "Ejecutando script de inicio " & objeto & " - Pasaje " & cod_pasaje & " ...</br>"

                            Case 1
                                resCab.progress_info &= "Ejecutando script de finalización " & objeto & " - Pasaje " & cod_pasaje & " ...</br>"

                            Case 2
                                resCab.progress_info &= "Ejecutando script de rollback " & objeto & " - Pasaje " & cod_pasaje & " ...</br>"
                        End Select

                        oSica = New tSicaObjeto
                        oSica.loadFromDefinition(cod_objeto)
                        oSica.loadModuloVersion(cod_modulo_version, path, cod_pasaje)
                        oSica.saveToImplementation(nvApp)

                        rs.MoveNext()
                    End While
                Catch ex As Exception
                    resCab.progress_info &= "Error en script " & objeto & ": " & ex.Message & " <br/>"
                    Throw (ex)
                Finally
                    nvDBUtiles.DBCloseRecordset(rs)
                End Try
            End Sub


            Public Shared Function sistema_implementacion_iniciar(ByRef nvapp As tnvApp, Optional ByVal cod_modulo_versiones As String = "", Optional ByVal cod_tipos As String = "", Optional ByVal filtroObjeto As String = "", Optional ByVal filtroFechaMod As DateTime = Nothing) As tError
                Dim retError As New tError

                Try
                    ' Controlar que no haya un proceso ejecutandose
                    If Not nvapp.sica_implementacion Is Nothing AndAlso nvapp.sica_implementacion.thread.IsAlive Then
                        retError.numError = 10
                        retError.titulo = "Error al iniciar el proceso de implementación"
                        retError.mensaje = "Hay un proceso ya iniciado"
                        retError.debug_src = "nvSica::sistema_implementar_iniciar"
                        Return retError
                    End If

                    nvapp.sica_implementacion = New tResCab
                    nvapp.sica_implementacion.elements = New List(Of tResElement)
                    nvapp.sica_implementacion.thread = New System.Threading.Thread(New ParameterizedThreadStart(AddressOf Implementation.sistema_implementar))
                    nvapp.sica_implementacion.nvApp = nvapp
                    nvapp.sica_implementacion.cod_modulo_versiones = cod_modulo_versiones
                    nvapp.sica_implementacion.cod_tipos = cod_tipos
                    nvapp.sica_implementacion.filtroObjeto = filtroObjeto
                    nvapp.sica_implementacion.filtroFechaMod = filtroFechaMod
                    nvapp.sica_implementacion.thread.Start(nvapp.sica_implementacion)
                Catch ex As Exception
                    retError = New tError
                    retError.parse_error_script(ex)
                    retError.titulo = "Error al iniciar  el proceso de implementación"
                    retError.mensaje = ""
                    retError.debug_src = "nvSica::sistema_implementar_iniciar"
                End Try

                Return retError
            End Function


            Public Shared Function sistema_implementacion_abortar(ByRef nvapp As tnvApp) As tError
                Dim res As New tError

                Try
                    If nvapp.sica_implementacion.thread.IsAlive Then
                        nvapp.sica_implementacion.thread.Abort()
                        res.params.Add("iniciado", "true")
                    Else
                        res.params.Add("iniciado", "false")
                    End If
                Catch ex As Exception
                    res.params.Add("iniciado", "false")
                End Try

                Return res
            End Function


            Public Shared Sub sistema_implementar(ByVal resCab As tResCab)
                Dim nvApp As tnvApp = resCab.nvApp
                resCab.fe_inicio = Now()
                resCab.progress_info = "...<br/>"
                resCab.pi_pos = 0
                resCab.total_count = 0
                resCab.pg_pos = 1
                resCab.pg_count = resCab.cod_tipos.Split(",").Count 'cada etapa de instalacion por tipo de objeto

                Try
                    implementar(nvApp, resCab)
                    resCab.progress_info &= "El proceso finalizó"
                    resCab.status = tResCab.tResCabStatusCode.finalizado
                Catch ex As ThreadAbortException
                    resCab.progress_info &= "El proceso fue abortado"
                    resCab.status = tResCab.tResCabStatusCode.abortado
                Catch ex As Exception
                    resCab.progress_info &= "El proceso finalizó porque ocurrió un error"
                    resCab.status = tResCab.tResCabStatusCode.finalizado_err
                    resCab.status_err_msg = ex.Message
                Finally
                    resCab.fe_fin = Now()
                End Try
            End Sub


            Private Shared Sub implementar(ByRef nvApp As tnvApp, ByRef resCab As tResCab, Optional ByVal cod_pasaje As Integer = 0)
                Dim objetos = resCab.cod_tipos.Split(",").ToList()

                If objetos.Count > 0 Then
                    ' Implementar SOLO los objetos pedidos mediante "cod_tipos"
                    While objetos.Count > 0
                        Dim tipo As tSicaObjeto.nvEnumObjeto_tipo = [Enum].Parse(GetType(tSicaObjeto.nvEnumObjeto_tipo), objetos(0))
                        objetos_implementar(nvApp, tipo, resCab, cod_pasaje)
                        objetos.RemoveAt(0) ' Elimino el primer codigo hasta que no me quede ninguno
                    End While
                Else
                    '*****************************************
                    ' Implementar TODO!!!

                    '/// OBJETOS COMPLEJOS ////////////////////////////////////////////////////////////

                    '--- Parametro
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.parametro, resCab, cod_pasaje)

                    '--- Permiso Grupo
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.permiso_grupo, resCab, cod_pasaje)

                    '--- Pizarra
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.pizarra, resCab, cod_pasaje)

                    '--- Transferencia
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.transferencia, resCab, cod_pasaje)


                    '/// OBJETOS SIMPLES //////////////////////////////////////////////////////////////

                    '--- Directorio
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.directorio, resCab, cod_pasaje)

                    '--- Función (BBDD) [retornan escalares]
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.funcion, resCab, cod_pasaje, 0)

                    '--- IMPORTANTE -------------------------------------------------------------------
                    ' Dependencias:
                    '     si una tabla referenciada no existe, el SP se crea igual. Pero si la tabla 
                    '   existe y es inconsistente de acuerdo a la forma en la cual se la usa en el SP 
                    '   (por ejemplo haciendo un insert con una columna que no existe) el create del SP
                    '   falla.
                    '     En esta instancia, fallara el create del SP, y fallara posteriormente el 
                    '   create de la tabla, porque ya existe, y no es igual a la de la definicion.
                    '     El problema se resuelve, haciendo que las tablas sean consistentes con lo
                    '   referido a sus posibles usos (como en un SP).
                    '----------------------------------------------------------------------------------

                    '--- Procedimiento Almacenado (SP)
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.sp, resCab, cod_pasaje)

                    '--- Tablas
                    tablas_implementar(nvApp, resCab, cod_pasaje)

                    '--- Vistas
                    tablas_implementar(nvApp, resCab, cod_pasaje, True)

                    '--- Función (BBDD) [retornan tablas]
                    ' No es posible crearlas si hacen referencia a objetos inexistentes
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.funcion, resCab, cod_pasaje, 1)

                    '--- Datos
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, resCab, cod_pasaje)

                    '--- Archivos [SOBREESCRIBE]
                    ' Se realiza al final dado que el cambio de archivos puede reciclar el proceso (por ejemplo con *.vb)
                    objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.archivo, resCab, cod_pasaje)
                End If

                '************************************* inicio codigo ORIGINAL ****************************************

                ''/// OBJETOS COMPLEJOS ////////////////////////////////////////////////////////////

                ''--- Parametro
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.parametro, resCab, cod_pasaje)

                ''--- Permiso Grupo
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.permiso_grupo, resCab, cod_pasaje)

                ''--- Pizarra
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.pizarra, resCab, cod_pasaje)

                ''--- Transferencia
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.transferencia, resCab, cod_pasaje)



                ''/// OBJETOS SIMPLES //////////////////////////////////////////////////////////////

                ''--- Directorio
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.directorio, resCab, cod_pasaje)

                ''--- Función (BBDD) [retornan escalares]
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.funcion, resCab, cod_pasaje, 0)

                ''--- IMPORTANTE -------------------------------------------------------------------
                '' Dependencias:
                ''     si una tabla referenciada no existe, el SP se crea igual. Pero si la tabla 
                ''   existe y es inconsistente de acuerdo a la forma en la cual se la usa en el SP 
                ''   (por ejemplo haciendo un insert con una columna que no existe) el create del SP
                ''   falla.
                ''     En esta instancia, fallara el create del SP, y fallara posteriormente el 
                ''   create de la tabla, porque ya existe, y no es igual a la de la definicion.
                ''     El problema se resuelve, haciendo que las tablas sean consistentes con lo
                ''   referido a sus posibles usos (como en un SP).
                ''----------------------------------------------------------------------------------

                ''--- Procedimiento Almacenado (SP)
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.sp, resCab, cod_pasaje)

                ''--- Tablas
                'tablas_implementar(nvApp, resCab, cod_pasaje)

                ''--- Vistas
                'tablas_implementar(nvApp, resCab, cod_pasaje, True)

                ''--- Función (BBDD) [retornan tablas]
                '' No es posible crearlas si hacen referencia a objetos inexistentes
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.funcion, resCab, cod_pasaje, 1)

                ''--- Datos
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.datos, resCab, cod_pasaje)

                ''--- Archivos [SOBREESCRIBE]
                '' Se realiza al final dado que el cambio de archivos puede reciclar el proceso (por ejemplo con *.vb)
                'objetos_implementar(nvApp, tSicaObjeto.nvEnumObjeto_tipo.archivo, resCab, cod_pasaje)

                '************************************* fin codigo ORIGINAL ****************************************
            End Sub


            Private Shared Sub pasaje_quitar_objetos(ByRef nvApp As tnvApp, ByRef resCab As tResCab, ByVal cod_pasaje As Integer)
                Dim strSQL As String = "SELECT cod_obj_tipo, objeto, cod_objeto, cod_modulo_version, path, " &
                                              "cod_sub_tipo, depende_de, cod_pasaje, fe_mod " &
                                       "FROM verNv_sistema_version_objetos " &
                                       "WHERE cod_sistema_version=" & nvApp.cod_sistema_version & " AND cod_pasaje= " & cod_pasaje & " AND es_baja=1 " &
                                       "ORDER BY cod_modulo_version, cod_obj_tipo"

                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                Try
                    If Not rs.EOF Then
                        resCab.progress_info &= "Quitando objetos - Pasaje " & cod_pasaje & " ...</br>"
                        Dim sicaObj As tSicaObjeto

                        While Not rs.EOF
                            sicaObj = New tSicaObjeto
                            sicaObj.loadFromImplementation(nvApp, rs.Fields("cod_obj_tipo").Value, rs.Fields("path").Value, rs.Fields("objeto").Value)
                            sicaObj.removeFromImplementation()
                            rs.MoveNext()
                        End While
                    End If
                Catch ex As Exception
                    resCab.progress_info &= "Error quitando el objeto " & rs.Fields("objeto").Value & ": " & ex.Message & " <br/>"
                    Throw (ex)
                Finally
                    nvDBUtiles.DBCloseRecordset(rs)
                End Try
            End Sub


            Private Shared Sub objetos_implementar(ByRef nvApp As tnvApp, ByVal cod_obj_tipo As String, ByRef resCab As tResCab, Optional ByVal cod_pasaje As Integer = 0, Optional ByVal cod_sub_tipo As Integer = -1)
                Dim strSQL As String = "SELECT objeto, cod_objeto, cod_modulo_version, path, cod_sub_tipo, depende_de, cod_pasaje, fe_mod " &
                                        "FROM verNv_sistema_version_objetos " &
                                        "WHERE cod_sistema_version=" & nvApp.cod_sistema_version & " and es_baja=0 AND cod_obj_tipo= " & cod_obj_tipo

                'If resCab.cod_tipos <> "" Then
                '    strSQL &= " AND cod_obj_tipo IN (" & resCab.cod_tipos & ")"
                'End If

                If resCab.cod_modulo_versiones <> "" Then
                    strSQL &= " AND cod_modulo_version IN (" & resCab.cod_modulo_versiones & ")"
                End If

                strSQL &= " AND cod_pasaje=" & cod_pasaje
                strSQL &= " AND depende_de IS NULL"

                If cod_sub_tipo <> -1 Then
                    strSQL &= " AND cod_sub_tipo=" & cod_sub_tipo
                End If

                ' Si implementa "archivos", instalar los que tienen extension ".vb" al final
                If cod_obj_tipo = tSicaObjeto.nvEnumObjeto_tipo.archivo Then
                    strSQL &= " ORDER BY CASE WHEN objeto LIKE '%.vb' THEN 1 ELSE 0 END, objeto"
                End If

                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                Dim oSica As tSicaObjeto
                'Dim errList As New List(Of tError)
                Dim objeto As String
                Dim cod_objeto As Integer
                Dim cod_modulo_version As String
                Dim path0 As String

                resCab.pi_count = If(rs.EOF, 0, rs.RecordCount)
                resCab.pi_pos = 0

                While Not rs.EOF
                    'cod_modulo_version, cod_objeto, path 
                    cod_modulo_version = rs.Fields("cod_modulo_version").Value
                    cod_objeto = rs.Fields("cod_objeto").Value
                    path0 = rs.Fields("path").Value
                    objeto = rs.Fields("objeto").Value

                    oSica = New tSicaObjeto
                    oSica.loadFromDefinition(cod_objeto)
                    'oSica.loadModuloVersion(cod_modulo_version, path0, cod_pasaje)
                    oSica.loadModuloVersion(cod_modulo_version, path0, rs.Fields("cod_sub_tipo").Value, rs.Fields("depende_de").Value, rs.Fields("cod_pasaje").Value, rs.Fields("fe_mod").Value)

                    Try
                        oSica.saveToImplementation(nvApp)
                    Catch e As Exception
                        Dim resElement As New tResElement
                        resElement.cod_objeto = cod_objeto
                        resElement.cod_obj_tipo = cod_obj_tipo
                        resElement.path = oSica.modulo_version_path
                        resElement.cod_sub_tipo = oSica.modulo_version_cod_sub_tipo
                        resElement.objeto = objeto
                        resElement.cod_modulo_version = cod_modulo_version
                        resElement.logInstallMsg = e.Message
                        resElement.cod_pasaje = cod_pasaje
                        resElement.depende_de = Nothing
                        resCab.elements.Add(resElement)

                        Throw e
                    End Try

                    resCab.pi_pos = rs.AbsolutePosition
                    resCab.total_count += 1

                    rs.MoveNext()
                End While

                nvDBUtiles.DBCloseRecordset(rs)

                If resCab.pg_pos < resCab.pg_count Then resCab.pg_pos += 1
            End Sub


            Private Shared Sub tablas_implementar(ByRef nvApp As tnvApp,
                                                  ByRef resCab As tResCab,
                                                  Optional ByVal cod_pasaje As Integer = 0,
                                                  Optional ByVal esVista As Boolean = False,
                                                  Optional ByVal cod_sub_tipo As Integer = -1)

                Dim strSQL As String = "SELECT * FROM verNv_sistema_version_objetos " &
                                        "WHERE cod_sistema_version=" & nvApp.cod_sistema_version &
                                            " AND es_baja=0" &
                                            " AND cod_obj_tipo=" & If(esVista = True, tSicaObjeto.nvEnumObjeto_tipo.vista, tSicaObjeto.nvEnumObjeto_tipo.tabla)

                If resCab.cod_tipos <> "" Then
                    strSQL &= " AND cod_obj_tipo in (" & resCab.cod_tipos & ")"
                End If

                If resCab.cod_modulo_versiones <> "" Then
                    strSQL &= " AND cod_modulo_version in (" & resCab.cod_modulo_versiones & ")"
                End If

                strSQL &= " AND cod_pasaje=" & cod_pasaje

                If cod_sub_tipo <> -1 Then
                    strSQL &= " AND cod_sub_tipo = " & cod_sub_tipo
                End If

                Dim rs As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)

                ' Guardar las tablas en una lista
                Dim tablas As New List(Of Dictionary(Of String, Object))
                Dim tabla As Dictionary(Of String, Object)

                While Not rs.EOF
                    tabla = New Dictionary(Of String, Object)
                    tabla("cod_objeto") = rs.Fields("cod_objeto").Value
                    tabla("path") = rs.Fields("path").Value
                    tabla("objeto") = rs.Fields("objeto").Value
                    tabla("cod_modulo_version") = rs.Fields("cod_modulo_version").Value
                    tabla("cod_sub_tipo") = rs.Fields("cod_sub_tipo").Value
                    tabla("depende_de") = rs.Fields("depende_de").Value
                    tabla("cod_pasaje") = rs.Fields("cod_pasaje").Value
                    tabla("fe_mod") = rs.Fields("fe_mod").Value
                    tabla("creado") = False

                    tablas.Add(tabla)
                    rs.MoveNext()
                End While

                nvDBUtiles.DBCloseRecordset(rs)

                Dim tablasCount As Integer = tablas.Count
                Dim completed As Integer = 0

                resCab.pi_count = tablasCount
                resCab.pi_pos = 0

                Dim sicaObj As tSicaObjeto
                Dim cab As tResCab

                If Not esVista Then
                    ' Marcar como ya creadas aquellas tablas que ya existen en estado integro 
                    ' en la base de dato destino
                    For i As Integer = 0 To tablasCount - 1
                        tabla = tablas(i)
                        sicaObj = New tSicaObjeto
                        sicaObj.loadFromDefinition(tabla("cod_objeto"))
                        cab = New tResCab
                        sicaObj.checkIntegrity(cab, nvApp)

                        If cab.elements.Count = 1 Then
                            If cab.elements(0).resStatus = nvenumResStatus.objeto_modificado Then
                                Throw New Exception("La tabla " & tabla("objeto") & " ya existe y es distinta")
                            End If
                        ElseIf cab.elements.Count = 0 Then
                            tabla("creado") = True
                            completed += 1
                            resCab.pi_pos += 1
                            resCab.total_count += 1
                        End If
                    Next
                End If

                Dim completed_0 As Integer = completed
                Dim pending As Integer = tablasCount - completed
                Dim elements As New List(Of tResElement)(New tResElement(tablasCount - 1) {})
                Dim cod_objeto As Integer
                Dim path0 As String
                Dim objeto As String
                Dim cod_modulo_version As Integer
                Dim numNotInstalled As Integer
                Dim oSica As tSicaObjeto

                For i As Integer = 1 To pending
                    For j As Integer = 0 To tablasCount - 1
                        tabla = tablas(j)

                        If Not tabla("creado") Then
                            cod_objeto = tabla("cod_objeto")
                            path0 = tabla("path")
                            objeto = tabla("objeto")
                            cod_modulo_version = tabla("cod_modulo_version")
                            oSica = New tSicaObjeto
                            oSica.loadFromDefinition(cod_objeto)
                            oSica.loadModuloVersion(cod_modulo_version, path0, tabla("cod_sub_tipo"), tabla("depende_de"), tabla("cod_pasaje"), tabla("fe_mod"))

                            Try
                                oSica.saveToImplementation(nvApp)
                                completed += 1
                                tabla("creado") = True
                                elements(j) = Nothing
                                resCab.pi_pos += 1
                                resCab.total_count += 1
                            Catch e As Exception
                                If elements(j) Is Nothing Then
                                    Dim resElement As New tResElement
                                    resElement.cod_objeto = cod_objeto
                                    resElement.cod_obj_tipo = nvSICA.tSicaObjeto.nvEnumObjeto_tipo.tabla
                                    resElement.path = oSica.modulo_version_path
                                    resElement.cod_sub_tipo = oSica.modulo_version_cod_sub_tipo
                                    resElement.objeto = objeto
                                    resElement.cod_modulo_version = cod_modulo_version
                                    resElement.cod_pasaje = cod_pasaje
                                    elements(j) = resElement
                                End If

                                elements(j).logInstallMsg = e.Message
                            End Try
                        End If
                    Next

                    ' si se completo de crear todas las tablas, salir
                    If completed = tablasCount Then
                        Exit For
                    End If

                    ' si no se pudo crear ninguna tabla en el ciclo, salir
                    If completed = completed_0 Then
                        numNotInstalled = tablasCount - completed
                        resCab.pi_pos += numNotInstalled
                        resCab.total_count += numNotInstalled

                        Exit For
                    End If

                    ' se creo al menos una tabla, continuar con el ciclo
                    completed_0 = completed
                Next

                For i As Integer = 0 To elements.Count - 1
                    If Not elements(i) Is Nothing Then
                        resCab.elements.Add(elements(i))
                        Throw New Exception(elements(i).logInstallMsg)
                    End If
                Next

                If resCab.pg_pos < resCab.pg_count Then resCab.pg_pos += 1
            End Sub


            Public Shared Function control_integridad_iniciar(ByRef nvapp As tnvApp, Optional ByVal cod_modulo_versiones As String = "", Optional ByVal cod_tipos As String = "", Optional ByVal filtroObjeto As String = "", Optional ByVal filtroFechaMod As DateTime = Nothing) As tError
                Dim retError As New tError

                Try
                    'controlar que no haya un proceso ejecutandose
                    If Not nvapp.sica_control Is Nothing AndAlso nvapp.sica_control.thread.IsAlive Then
                        retError.numError = 10
                        retError.titulo = "Error al iniciar le proceso de control de integridad"
                        retError.mensaje = "Hay un proceso ya iniciado"
                        retError.debug_src = "nvSica::control_integridad"
                        Return retError
                    End If

                    nvapp.sica_control = New tResCab
                    nvapp.sica_control.elements = New List(Of tResElement)
                    nvapp.sica_control.thread = New System.Threading.Thread(New ParameterizedThreadStart(AddressOf Implementation.control_integridad))
                    nvapp.sica_control.nvApp = nvapp
                    nvapp.sica_control.cod_modulo_versiones = cod_modulo_versiones
                    nvapp.sica_control.cod_tipos = cod_tipos
                    nvapp.sica_control.filtroObjeto = filtroObjeto
                    nvapp.sica_control.filtroFechaMod = filtroFechaMod
                    nvapp.sica_control.thread.Start(nvapp.sica_control)
                Catch ex As Exception
                    retError = New tError
                    retError.parse_error_script(ex)
                    retError.titulo = "Error al iniciar le proceso de control de integridad"
                    retError.mensaje = ""
                    retError.debug_src = "nvSica::control_integridad"
                End Try

                Return retError
            End Function


            Public Shared Function control_integridad_abortar(nvapp As tnvApp) As tError
                Dim res As New tError

                Try
                    If nvapp.sica_control.thread.IsAlive Then
                        nvapp.sica_control.thread.Abort()
                        nvapp.sica_control.status = tResCab.tResCabStatusCode.abortado
                        nvapp.sica_control.fe_fin = Now()
                        res.params.Add("iniciado", "true")
                    Else
                        res.params.Add("iniciado", "false")
                    End If
                Catch ex As Exception
                    res.params.Add("iniciado", "false")
                End Try

                Return res
            End Function


            Public Shared Sub control_integridad(ByVal ResCab As tResCab)
                Dim cod_modulo_version As Integer
                Dim strSQL As String
                Dim rsModulos As ADODB.Recordset
                Dim rsElement As ADODB.Recordset
                ResCab.fe_inicio = Now()
                ResCab.progress_info = "Ejecutando"
                ResCab.pg_pos = 0
                ResCab.pi_pos = 0
                ResCab.total_count = 0

                Dim app As tnvApp = ResCab.nvApp

                Try
                    strSQL = "SELECT * FROM nv_sistema_modulo_version WHERE cod_sistema_version=" & ResCab.nvApp.cod_sistema_version & If(ResCab.cod_modulo_versiones = "", "", " AND cod_modulo_version IN (" & ResCab.cod_modulo_versiones & ")")
                    rsModulos = nvDBUtiles.ADMDBOpenRecordset(strSQL)
                    ResCab.pg_count = If(rsModulos.EOF, 0, rsModulos.RecordCount)

                    Dim filtro As String = ""

                    ' 1) Filtro por: Tipos de objeto seleccionados
                    If ResCab.cod_tipos <> "" Then
                        filtro = "cod_obj_tipo IN (" & ResCab.cod_tipos & ")"
                    End If

                    ' 2) Filtro por: Objetos
                    If ResCab.filtroObjeto <> "" Then
                        If filtro <> "" Then filtro &= " AND"
                        filtro &= " objeto " & ResCab.filtroObjeto  ' aca ResCab.filtroObjeto ya viene con "like" o "not like"
                    End If

                    ' 3) Filtro por: Fecha
                    Dim oValor As String = ResCab.filtroFechaMod.ToString("yyyy-MM-dd HH:mm:ss")

                    If oValor <> "" Then
                        If filtro <> "" Then filtro &= " AND"
                        filtro &= " fe_mod > CONVERT(datetime, '" & oValor & "', 121)"
                    End If


                    Dim orden As String = " path, objeto"
                    Dim sicaObj As tSicaObjeto

                    While Not rsModulos.EOF
                        ResCab.pg_pos = rsModulos.AbsolutePosition
                        cod_modulo_version = rsModulos.Fields("cod_modulo_version").Value
                        rsElement = Definition.getServidorSistemaObjetosDef(app.cod_servidor, app.cod_sistema, cod_modulo_version, filtro, orden)
                        ResCab.pi_count = If(rsElement.EOF, 0, rsElement.RecordCount)

                        While Not rsElement.EOF
                            ResCab.total_count += 1
                            ResCab.pi_pos = rsElement.AbsolutePosition
                            sicaObj = New tSicaObjeto
                            sicaObj.loadFromDefinition(rsElement.Fields("cod_objeto").Value)
                            sicaObj.loadModuloVersion(cod_modulo_version, rsElement.Fields("path").Value, rsElement.Fields("cod_sub_tipo").Value, rsElement.Fields("depende_de").Value, rsElement.Fields("cod_pasaje").Value, rsElement.Fields("fe_mod").Value)
                            sicaObj.checkIntegrity(ResCab, ResCab.nvApp)
                            rsElement.MoveNext()
                        End While

                        nvDBUtiles.DBCloseRecordset(rsElement)
                        rsModulos.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rsModulos)
                    ResCab.progress_info = "Finalizado"
                    ResCab.status = tResCab.tResCabStatusCode.finalizado
                Catch abortEx As ThreadAbortException
                    ResCab.progress_info = "Proceso abortado"
                    ResCab.status = tResCab.tResCabStatusCode.abortado
                Catch ex As Exception
                    ResCab.progress_info = "Error - Proceso interrumpido"
                    ResCab.status = tResCab.tResCabStatusCode.finalizado_err
                    ResCab.status_err_msg = ex.Message
                Finally
                    ResCab.fe_fin = Now()
                End Try
            End Sub



            Public Shared Function exist(ByRef nvapp As tnvApp, ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, Optional ByRef bytes As Byte() = Nothing) As Boolean
                Dim physical_path As String

                Select Case cod_obj_tipo
                    Case tSicaObjeto.nvEnumObjeto_tipo.directorio
                        physical_path = nvSICA.path.LogicalToPhysical(nvapp, path & objeto)
                        Return IO.Directory.Exists(physical_path)


                    Case tSicaObjeto.nvEnumObjeto_tipo.archivo
                        physical_path = nvSICA.path.LogicalToPhysical(nvapp, path & objeto)
                        Return IO.File.Exists(physical_path)


                    Case tSicaObjeto.nvEnumObjeto_tipo.funcion, tSicaObjeto.nvEnumObjeto_tipo.sp, tSicaObjeto.nvEnumObjeto_tipo.vista, tSicaObjeto.nvEnumObjeto_tipo.tabla
                        Dim strSQL As String = "select object_id from sys.objects where name = '" & objeto & "'"
                        Dim nvcn As tDBConection

                        If path = "" Then
                            nvcn = nvapp.app_cns("default").clone()
                        Else
                            nvcn = nvapp.app_cns(path).clone()
                        End If

                        nvcn.excaslogin = False
                        Dim rsObj As ADODB.Recordset = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)
                        Dim res As Boolean = Not rsObj.EOF
                        nvDBUtiles.DBCloseRecordset(rsObj)
                        Return res


                    Case tSicaObjeto.nvEnumObjeto_tipo.datos
                        ' Si la tabla no existe devolver que el objeto no existe
                        Dim nvcn As tDBConection
                        Dim tabla As String = path.Split("\")(1)
                        Dim cn As String = path.Split("\")(0)

                        If cn = "" Then
                            nvcn = nvapp.app_cns("default").clone()
                        Else
                            nvcn = nvapp.app_cns(cn).clone()
                        End If

                        nvcn.excaslogin = False
                        Dim strSQL As String = "select object_id from sys.objects where name = '" & tabla & "'"
                        Dim rsObj As ADODB.Recordset = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, _nvcn:=nvcn)
                        Dim res As Boolean = Not rsObj.EOF
                        nvDBUtiles.DBCloseRecordset(rsObj)

                        If res = False Then
                            Return False
                        End If

                        ' Si la tabla existe, y no existe ningun elemento, devolver que no existe, sino devolver que existe
                        Dim sicaOBJ As New tSicaObjeto
                        sicaOBJ.loadFromImplementation(nvapp, cod_obj_tipo, path, objeto, 0, True, bytes)

                        If sicaOBJ.bytes Is Nothing Then
                            Return False
                        End If

                        Dim oXMlDef As New System.Xml.XmlDocument
                        Dim oXMlImp As New System.Xml.XmlDocument
                        Dim strXML As String = nvConvertUtiles.BytesToString(bytes)
                        oXMlDef.LoadXml(strXML)
                        strXML = nvConvertUtiles.BytesToString(sicaOBJ.bytes)
                        oXMlImp.LoadXml(strXML)
                        Dim nodesDef As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXMlDef, "xml/rs:data/z:row")
                        Dim nodesImp As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXMlImp, "xml/rs:data/z:row")
                        Dim encontrado As Boolean = True

                        For i = 0 To nodesDef.Count - 1
                            For j = 0 To nodesDef(i).Attributes.Count - 1
                                If nodesDef(i).Attributes(j).Value <> nodesImp(i).Attributes(j).Value Then
                                    encontrado = False
                                    Exit For
                                End If
                            Next
                        Next

                        Return encontrado


                    Case Else
                        Return False

                End Select
            End Function


            Public Shared Function checkBinary(ByVal cod_objeto As Integer, ByRef nvApp As tnvApp, ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, ByVal cod_sub_tipo As Integer) As Boolean
                Dim sicaObj As New tSicaObjeto
                sicaObj.loadFromImplementation(nvApp, cod_obj_tipo, path, objeto, cod_sub_tipo, True)
                Return Definition.checkBinary(cod_objeto, sicaObj.bytes)
            End Function


            Public Shared Function checkBinary(ByVal cod_objeto As Integer, ByRef binary As Byte()) As Boolean
                Return Definition.checkBinary(cod_objeto, binary)
            End Function


            Public Shared Sub objetos_eliminar(ByRef nvapp As tnvApp, ByVal strXML As String)
            End Sub


            Public Shared Sub objeto_eliminar(ByRef nvapp As tnvApp, ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo, ByVal path As String, ByVal objeto As String, Optional ByVal cod_sub_tipo As Integer = 0)
                Select Case cod_obj_tipo
                    Case tSicaObjeto.nvEnumObjeto_tipo.archivo
                        Dim physicalPath As String = nvSICA.path.LogicalToPhysical(nvapp, path & objeto)
                        IO.File.Delete(physicalPath)

                    Case tSicaObjeto.nvEnumObjeto_tipo.directorio
                        Dim physicalPath As String = nvSICA.path.LogicalToPhysical(nvapp, path & objeto)
                        IO.Directory.Delete(physicalPath)

                    Case tSicaObjeto.nvEnumObjeto_tipo.funcion, tSicaObjeto.nvEnumObjeto_tipo.sp, tSicaObjeto.nvEnumObjeto_tipo.vista, tSicaObjeto.nvEnumObjeto_tipo.tabla
                        Dim nvcn As tDBConection = nvapp.app_cns(path)
                        nvcn.excaslogin = False
                        Dim strSQL As String = Nothing

                        Select Case cod_obj_tipo
                            Case tSicaObjeto.nvEnumObjeto_tipo.vista
                                strSQL = "DROP VIEW " & objeto

                            Case tSicaObjeto.nvEnumObjeto_tipo.sp
                                strSQL = "DROP PROCEDURE " & objeto

                            Case tSicaObjeto.nvEnumObjeto_tipo.funcion
                                strSQL = "DROP FUNCTION " & objeto

                            Case tSicaObjeto.nvEnumObjeto_tipo.tabla
                                strSQL = "DROP TABLE " & objeto
                        End Select

                        nvDBUtiles.DBExecute(strSQL, _nvcn:=nvcn)

                    Case tSicaObjeto.nvEnumObjeto_tipo.datos

                End Select
            End Sub



            Private Shared Sub _AddADOParameter(ByVal field As ADODB.Field, ByVal Cmd As ADODB.Command)
                If Not IsDBNull(field.Value) Then
                    ' Los campos tipo fecha se castean a string para resolver
                    ' el problema del truncado de los milisegundos
                    If field.Type = 135 Then 'datetime, smalldatetime (adDBTimeStamp)
                        Dim anio As String = String.Format("{0:D4}", field.Value.year)
                        Dim mes As String = String.Format("{0:D2}", field.Value.month)
                        Dim dia As String = String.Format("{0:D2}", field.Value.day)
                        Dim horas As String = String.Format("{0:D2}", field.Value.hour)
                        Dim minutos As String = String.Format("{0:D2}", field.Value.Minute)
                        Dim segundos As String = String.Format("{0:D2}", field.Value.Second)
                        Dim ms As String = String.Format("{0:D3}", field.Value.millisecond)
                        Dim strValue As String = anio & "" & mes & "" & dia & " " & horas & ":" & minutos & ":" & segundos & "." & ms
                        Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, 200, 1, strValue.Length, strValue))
                    Else
                        Dim fieldSize As Integer = field.ActualSize
                        Dim fieldValue As Object = field.Value

                        ' image nulo (adLongVarBinary = 205)
                        If field.Type = ADODB.DataTypeEnum.adLongVarBinary AndAlso field.ActualSize = 0 Then
                            fieldValue = ""
                            fieldSize = 4
                        End If

                        ' varchar y nvarchar nulos (adVarChar = 200, adVarWChar = 202)
                        If (field.Type = ADODB.DataTypeEnum.adVarChar OrElse field.Type = ADODB.DataTypeEnum.adVarWChar) AndAlso field.ActualSize = 0 Then
                            fieldSize = 4
                        End If

                        Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, field.Type, 1, fieldSize, fieldValue))
                    End If
                Else
                    Cmd.Parameters.Append(Cmd.CreateParameter("@" & field.Name, field.Type, 1, -1, Nothing))
                End If
            End Sub



            Public Shared Sub objeto_agregar(ByVal cod_objeto As Integer,
                                             ByVal cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo,
                                             ByRef nvApp As tnvApp,
                                             ByVal modulo_version_path As String,
                                             ByVal objeto As String,
                                             ByRef bytes As Byte())
                Dim physical_path As String

                Select Case cod_obj_tipo
                    Case tSicaObjeto.nvEnumObjeto_tipo.archivo
                        physical_path = path.LogicalToPhysical(nvApp, modulo_version_path & objeto)
                        nvReportUtiles.create_folder(IO.Path.GetDirectoryName(physical_path))
                        Dim fs As New IO.FileStream(physical_path, IO.FileMode.Create)
                        fs.Write(bytes, 0, bytes.Length)
                        fs.Close()


                    Case tSicaObjeto.nvEnumObjeto_tipo.directorio
                        physical_path = path.LogicalToPhysical(nvApp, modulo_version_path)

                        If Not IO.Directory.Exists(physical_path) Then nvReportUtiles.create_folder(physical_path)


                    Case tSicaObjeto.nvEnumObjeto_tipo.funcion, tSicaObjeto.nvEnumObjeto_tipo.sp, tSicaObjeto.nvEnumObjeto_tipo.vista, tSicaObjeto.nvEnumObjeto_tipo.script_db
                        Dim nvcn As tDBConection

                        If modulo_version_path = "" Then
                            nvcn = nvApp.app_cns("default").clone()
                        Else
                            nvcn = nvApp.app_cns(modulo_version_path).clone()
                        End If

                        nvcn.excaslogin = False
                        Dim strDef As String = nvConvertUtiles.BytesToString(bytes)

                        If cod_obj_tipo <> tSicaObjeto.nvEnumObjeto_tipo.script_db AndAlso exist(nvApp, cod_obj_tipo, modulo_version_path, objeto) Then
                            Dim reg As Regex = Nothing

                            Select Case cod_obj_tipo
                                Case tSicaObjeto.nvEnumObjeto_tipo.funcion
                                    reg = New Regex("\.*Create\s+function\s+", RegexOptions.IgnoreCase)


                                Case tSicaObjeto.nvEnumObjeto_tipo.sp
                                    reg = New Regex("\.*Create\s+(procedure|proc)\s+", RegexOptions.IgnoreCase)


                                Case tSicaObjeto.nvEnumObjeto_tipo.vista
                                    reg = New Regex("\.*Create\s+view\s+", RegexOptions.IgnoreCase)

                            End Select

                            If Not reg Is Nothing Then
                                Dim match As Match = reg.Match(strDef)

                                If match.Success Then
                                    Dim statement As String = Regex.Replace(match.Value, "CREATE", "ALTER", RegexOptions.IgnoreCase)
                                    strDef = strDef.Replace(match.Value, statement)
                                End If
                            End If
                        End If

                        Dim rx As New Regex("\bgo\b", RegexOptions.IgnoreCase)
                        Dim sentencias() As String = rx.Split(strDef)

                        ' Aquí debemos armar una única conexión, ya que en SyBase (IBS) se usan tablas temporales y 
                        ' si cerramos la conexion en cada iteración se pierde la sesión
                        Dim cn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)

                        For Each sentencia As String In sentencias
                            If (sentencia <> String.Empty) Then
                                nvDBUtiles.DBExecute(sentencia, _cn:=cn, autoclose_connection:=False)
                            End If
                        Next

                        nvDBUtiles.DBDesconectar(cn)


                    Case tSicaObjeto.nvEnumObjeto_tipo.tabla
                        Dim nvcn As tDBConection

                        If modulo_version_path = "" Then
                            nvcn = nvApp.app_cns("default").clone()
                        Else
                            nvcn = nvApp.app_cns(modulo_version_path).clone()
                        End If

                        nvcn.excaslogin = False

                        If exist(nvApp, cod_obj_tipo, modulo_version_path, objeto) Then
                            Throw New Exception("No se puede actualizar la tabla [<b>" & objeto & "</b>] porque ya existe.")
                        End If

                        Dim strDef As String = nvConvertUtiles.BytesToString(bytes)
                        ' Cargar el string XML en un documento XML y desde alli obtener el script de creación
                        Dim oXml As New System.Xml.XmlDocument
                        oXml.LoadXml(strDef)
                        Dim strCreationScript As String = nvXMLUtiles.selectSingleNode(oXml, "table/creation_script").InnerText

                        ' Válido sólo MS SQL Server
                        ' Cuando el create table arroja error por foreign key a tabla no existente,de todas maneras se crea la tabla
                        ' Evitamos que la tabla se cree si se arroja algun error
                        Dim sentencias() As String = strCreationScript.Split(New String() {vbCrLf & "GO" & vbCrLf}, StringSplitOptions.RemoveEmptyEntries)
                        Dim cn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                        cn.BeginTrans()

                        Try
                            For Each sentencia As String In sentencias
                                cn.Execute(sentencia)
                            Next

                            cn.CommitTrans()
                        Catch tEx As Exception
                            cn.RollbackTrans()
                            Throw tEx
                        End Try


                    Case tSicaObjeto.nvEnumObjeto_tipo.datos
                        ' Tomar la conexion del path, esta compuesto por conexion\tabla
                        Dim nvcn As tDBConection
                        Dim tabla As String = modulo_version_path.Split("\")(1) ' Recuperar la tabla del path
                        Dim cn As String = modulo_version_path.Split("\")(0)    ' Recuperar la conexion

                        If cn = "" Then
                            nvcn = nvApp.app_cns("default").clone()
                        Else
                            nvcn = nvApp.app_cns(cn).clone()
                        End If

                        nvcn.excaslogin = False

                        Dim _paramXML As String = nvConvertUtiles.BytesToString(bytes)
                        Dim oXml As New System.Xml.XmlDocument
                        oXml.LoadXml(_paramXML)
                        Dim nodes As System.Xml.XmlNodeList = nvXMLUtiles.selectNodes(oXml, "xml/s:Schema/s:ElementType/s:AttributeType")
                        Dim pk As New List(Of String)
                        Dim campo As String

                        For Each node In nodes
                            campo = nvXMLUtiles.getAttribute_path(node, "@name", "Error")

                            If nvXMLUtiles.getAttribute_path(node, "@pk", "false") = "true" Then pk.Add(campo)
                        Next

                        Dim objStream As New ADODB.Stream
                        With objStream
                            .Charset = "unicode"
                            .Mode = ADODB.ConnectModeEnum.adModeReadWrite
                            .Type = ADODB.StreamTypeEnum.adTypeText
                            .Open()
                            .WriteText(_paramXML)
                            .Position = 0
                        End With

                        Dim rs As New ADODB.Recordset
                        rs.Open(objStream)
                        objStream.Close()

                        Dim campos As New List(Of String)
                        Dim wildCards As New List(Of String)
                        Dim NoPk As New List(Of String)

                        For i As Integer = 0 To rs.Fields.Count - 1
                            If (rs.Fields(i).Type <> 128) OrElse ((rs.Fields(i).Attributes And &H200) = 0) Then  ' se debe excluir timestamp ( como binary tambien es tipo 128 hay q preguntar en attributes)
                                campos.Add(rs.Fields(i).Name)
                                wildCards.Add("?")

                                If Not pk.Contains(rs.Fields(i).Name) Then NoPk.Add(rs.Fields(i).Name)
                            End If
                        Next

                        Dim strWhere As String = "[" & String.Join("]=? and [", pk) & "]=? "
                        Dim strSetCampos As String = "[" & String.Join("]=? , [", NoPk) & "]=? "
                        Dim strCampos As String = "[" & String.Join("],[", campos) & "]"
                        Dim strWildCards As String = String.Join(",", wildCards)
                        Dim conn As ADODB.Connection = nvDBUtiles.DBConectar(db_type:=emunDBType.db_other, _nvcn:=nvcn)
                        conn.BeginTrans()

                        Try
                            ' Si la tabla tiene columnas "Identity" desactivar la inserción de valores de identidad
                            Dim strQuery As String = "IF (EXISTS(SELECT TOP 1 * FROM sys.identity_columns WHERE object_name(object_id)='" & tabla & "'))" & vbCrLf &
                                                       "SET identity_insert " & tabla & " ON" & vbCrLf
                            conn.Execute(strQuery)

                            ' Guardar las "Foreign Keys" de la tabla (si tiene alguna) para luego no chequear tales "constraints"
                            strQuery = "SELECT name FROM sys.foreign_keys WHERE object_name(parent_object_id)='" & tabla & "'"
                            Dim rsFks As ADODB.Recordset = conn.Execute(strQuery)
                            Dim fks As New List(Of String)

                            While Not rsFks.EOF
                                fks.Add(rsFks.Fields("name").Value)
                                rsFks.MoveNext()
                            End While

                            nvDBUtiles.DBCloseRecordset(rsFks, False)

                            For i As Integer = 0 To fks.Count - 1
                                strQuery = "ALTER TABLE " & tabla & vbCrLf & "NOCHECK CONSTRAINT " & fks(i)
                                conn.Execute(strQuery)
                            Next

                            Dim procedure As String
                            Dim Cmd As ADODB.Command
                            Dim rst As ADODB.Recordset
                            Dim rowcount As Integer
                            Dim _rs As ADODB.Recordset
                            Dim count As Integer

                            While Not rs.EOF
                                Try
                                    ' Controlar que el registro no existe o bien si existe que sea unico; caso contrario hacer rollback
                                    strQuery = "BEGIN SELECT COUNT(*) AS [count] FROM " & tabla & " WHERE "
                                    Dim _where As String = ""

                                    For Each _pk In pk
                                        _where &= " AND [" & _pk & "]="

                                        If rs.Fields(_pk).Type = ADODB.DataTypeEnum.adChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adLongVarChar OrElse
                                            rs.Fields(_pk).Type = ADODB.DataTypeEnum.adLongVarWChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adVarChar OrElse
                                            rs.Fields(_pk).Type = ADODB.DataTypeEnum.adVarWChar OrElse rs.Fields(_pk).Type = ADODB.DataTypeEnum.adWChar Then
                                            _where &= "'" & rs.Fields(_pk).Value & "'"
                                        ElseIf rs.Fields(_pk).Type = ADODB.DataTypeEnum.adBoolean Then
                                            _where &= If(rs.Fields(_pk).Value.ToString.ToLower = "true" OrElse rs.Fields(_pk).Value.ToString = "1", 1, 0)
                                        Else
                                            _where &= rs.Fields(_pk).Value
                                        End If
                                    Next

                                    _where = _where.Substring(5)
                                    strQuery &= _where & " END"

                                    _rs = conn.Execute(strQuery)

                                    If Not _rs.EOF Then
                                        count = _rs.Fields("count").Value

                                        Select Case count
                                            Case 0
                                                ' No hay registros => INSERTAR
                                                procedure = "BEGIN INSERT INTO " & tabla & " (" & strCampos & ") VALUES(" & strWildCards & ") END"
                                                Cmd = New ADODB.Command
                                                Cmd.ActiveConnection = conn
                                                Cmd.CommandType = ADODB.CommandTypeEnum.adCmdText
                                                Cmd.CommandTimeout = 1500
                                                Cmd.CommandText = procedure

                                                For Each campo In campos
                                                    _AddADOParameter(rs.Fields(campo), Cmd)
                                                Next

                                                Cmd.Execute()


                                            Case 1
                                                ' Si no hay campos para updatear (caso excepcional de una tabla con un solo campo) => Salir con Excepción
                                                'If strSetCampos = "[]=? " Then
                                                '   Throw New Exception("No hay campos para actualizar")
                                                If strSetCampos <> "[]=? " Then
                                                    ' Hay sólo un registro => ACTUALIZAR
                                                    procedure = "BEGIN UPDATE " & tabla & " SET " & strSetCampos & " WHERE " & strWhere & vbCrLf & " SELECT @@rowcount AS [rowcount] END" & vbCrLf
                                                    Cmd = New ADODB.Command
                                                    Cmd.ActiveConnection = conn
                                                    Cmd.CommandType = ADODB.CommandTypeEnum.adCmdText
                                                    Cmd.CommandTimeout = 1500
                                                    Cmd.CommandText = procedure

                                                    For Each campo In NoPk
                                                        _AddADOParameter(rs.Fields(campo), Cmd)
                                                    Next

                                                    For Each campo In pk
                                                        _AddADOParameter(rs.Fields(campo), Cmd)
                                                    Next

                                                    Try
                                                        rst = Cmd.Execute()
                                                        rowcount = rst.Fields(0).Value
                                                        nvDBUtiles.DBCloseRecordset(rst, False)

                                                        If rowcount = 0 Then
                                                            Throw New Exception("Error de inserción. No se pudo updatear el registro.")
                                                        End If
                                                    Catch UpdateException As Exception
                                                        Throw UpdateException
                                                    End Try
                                                End If


                                            Case Else
                                                ' Hay más de un registro => ERROR
                                                Throw New Exception("La/s claves primarias retornan más de un registro, invalidando la actualización de los datos.")

                                        End Select
                                    End If

                                    nvDBUtiles.DBCloseRecordset(_rs, False)
                                Catch updateDataException As Exception
                                    Throw updateDataException
                                End Try

                                rs.MoveNext()
                            End While

                            ' Volver a checkear las "Foreign Keys" que tiene la tabla (si las tiene)
                            For i As Integer = 0 To fks.Count - 1
                                strQuery = "ALTER TABLE " & tabla & vbCrLf & "CHECK CONSTRAINT " & fks(i)
                                conn.Execute(strQuery)
                            Next

                            ' Volver a habilitar el control de insersión de identidades de tabla
                            conn.Execute("IF (EXISTS(SELECT TOP 1 * FROM sys.identity_columns WHERE object_name(object_id)='" & tabla & "'))" & vbCrLf &
                                           "SET identity_insert " & tabla & " OFF" & vbCrLf)

                            conn.CommitTrans()
                        Catch ex As Exception
                            conn.RollbackTrans()
                            Throw ex
                        Finally
                            Try
                                conn.Close()
                                rs.Close()
                            Catch ex As Exception
                            End Try
                        End Try
                End Select
            End Sub


            Public Shared Function getRSXMLElements(nvApp As tnvApp, cod_obj_tipo As tSicaObjeto.nvEnumObjeto_tipo, Optional filtro As String = "") As String
                Dim res As String = ""

                Select Case cod_obj_tipo
                    Case tSicaObjeto.nvEnumObjeto_tipo.transferencia
                        res = tnvSicaTipoTransferencia.getRSXMLElements(nvApp, filtro)

                    Case tSicaObjeto.nvEnumObjeto_tipo.permiso_grupo
                        res = tnvSicaPermisoGrupo.getRSXMLElements(nvApp, filtro)

                    Case tSicaObjeto.nvEnumObjeto_tipo.pizarra
                        res = tnvSicaPizarra.getRSXMLElements(nvApp, filtro)

                    Case tSicaObjeto.nvEnumObjeto_tipo.parametro
                        res = tnvSicaParametro.getRSXMLElements(nvApp, filtro)

                End Select

                Return res
            End Function
        End Class



        Public Class utiles

            Public Shared Function cnstringToSqlConnectionStringBuilder(cn_string As String) As Data.SqlClient.SqlConnectionStringBuilder

                Dim data_source As String = get_cn_element({"data source", "server", "address", "addr", "network address"}, cn_string)
                Dim failover_partner As String = get_cn_element({"Failover Partner", "Failover_Partner"}, cn_string)
                Dim initial_catalog As String = get_cn_element({"Initial Catalog", "Database"}, cn_string)
                Dim integrated_security As String = get_cn_element({"Integrated Security", "Trusted_Connection"}, cn_string)
                Dim password As String = get_cn_element({"Password", "PWD"}, cn_string)
                Dim user_id As String = get_cn_element({"User ID", "UID"}, cn_string)
                Dim application_name As String = get_cn_element({"Application Name"}, cn_string)
                Dim connect_timeout As String = get_cn_element({"Connect Timeout", "Connection Timeout", "Timeout"}, cn_string)
                Dim current_language As String = get_cn_element({"Current Language", "Languaje"}, cn_string)
                Dim encrypt As String = get_cn_element({"Encrypt"}, cn_string)
                Dim network_library As String = get_cn_element({"Network Library", "Network", "Net"}, cn_string)
                Dim persist_security_info As String = get_cn_element({"Persist Security Info"}, cn_string)
                Dim trustservercertificate As String = get_cn_element({"TrustServerCertificate"}, cn_string)
                Dim applicationintent As String = get_cn_element({"ApplicationIntent"}, cn_string)
                Dim asynchronous_processing As String = get_cn_element({"Asynchronous Processing", "Async"}, cn_string)
                Dim attachdbfilename As String = get_cn_element({"AttachDBFilename"}, cn_string)

                Dim sql_cn_builder As New Data.SqlClient.SqlConnectionStringBuilder

                If data_source <> "" Then sql_cn_builder.Add("Data Source", data_source) ' Server -or- Address -or- Addr -or- Network Address
                If failover_partner <> "" Then sql_cn_builder.Add("Failover Partner", failover_partner) ' 
                If initial_catalog <> "" Then sql_cn_builder.Add("Initial Catalog", initial_catalog) ' or Database
                If integrated_security <> "" Then sql_cn_builder.Add("Integrated Security", integrated_security) ' or Trusted_Connection
                If password <> "" Then sql_cn_builder.Add("Password", password) 'or PWD
                If user_id <> "" Then sql_cn_builder.Add("User ID", user_id) 'or UID
                If application_name <> "" Then sql_cn_builder.Add("Application Name", application_name)
                If connect_timeout <> "" Then sql_cn_builder.Add("Connect Timeout", connect_timeout) '-or- Connection Timeout -or- Timeout
                If current_language <> "" Then sql_cn_builder.Add("Current Language", current_language) ' or  Languaje
                If encrypt <> "" Then sql_cn_builder.Add("Encrypt", encrypt) ' 
                If network_library <> "" Then sql_cn_builder.Add("Network Library", network_library) ' -or- Network -or- Net opciones:  dbnmpntw (Named Pipes), dbmsrpcn (Multiprotocol, Windows RPC), dbmsadsn (Apple Talk), dbmsgnet(VIA), dbmslpcn (Shared Memory), dbmsspxn(IPX / SPX) , dbmssocn(TCP / IP),  Dbmsvinn (Banyan Vines)
                If persist_security_info <> "" Then sql_cn_builder.Add("Persist Security Info", persist_security_info) ' or PersistSecurityInfo
                If trustservercertificate <> "" Then sql_cn_builder.Add("TrustServerCertificate", trustservercertificate)
                If applicationintent <> "" Then sql_cn_builder.Add("ApplicationIntent", trustservercertificate)
                If asynchronous_processing <> "" Then sql_cn_builder.Add("Asynchronous Processing", trustservercertificate)
                If attachdbfilename <> "" Then sql_cn_builder.Add("AttachDBFilename", trustservercertificate)

                Return sql_cn_builder
            End Function


            Public Shared Function get_cn_element(tags As String(), cadena As String, Optional [default] As String = "") As String
                Dim res As String = [default]
                Dim i As Integer
                Dim tag As String
                Dim strReg As String
                Dim reg As System.Text.RegularExpressions.Regex

                For i = LBound(tags) To UBound(tags)
                    tag = tags(i)
                    strReg = tag & "\s*=\s*([^;]*)"
                    reg = New Regex(strReg, RegexOptions.IgnoreCase)

                    If reg.IsMatch(cadena) Then
                        res = reg.Matches(cadena)(0).Groups(1).Value
                        Exit For
                    End If
                Next

                Return res
            End Function

        End Class

    End Namespace
End Namespace
