Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Namespace nvSICA

        Public Class Herramientas

            Public Shared Function exportar(Optional sistemas As String = "", Optional modulos As String = "", Optional pasajes As String = "", Optional exportedFileName As String = "export") As tError

                Dim err As New tError
                err.params("compressedFile") = ""
                err.params("outputFilePathFull") = ""

                Try

                    Dim permisosExportar As New HashSet(Of Integer)

                    Dim xmlIn As String = ""

                    Dim sistemasList(-1) As String

                    If sistemas <> "" Then
                        sistemasList = sistemas.Split(",")
                    End If

                    Dim modulosList(-1) As String

                    If modulos <> "" Then
                        modulosList = modulos.Split(",")
                    End If

                    Dim pasajesLis(-1) As String

                    If pasajes <> "" Then
                        pasajesLis = pasajes.Split(",")
                    End If

                    xmlIn &= "<exportacion>"
                    xmlIn &= "<sistemas_versiones>"

                    Dim rs As ADODB.Recordset

                    For Each cod_sistema_version In sistemasList
                        rs = nvDBUtiles.DBOpenRecordset("SELECT cod_sistema, cod_modulo_version, cod_modulo FROM verNv_sistema_modulo_version WHERE cod_sistema_version=" & cod_sistema_version)

                        If Not rs.EOF Then
                            xmlIn &= "<sistema_version cod_sistema='" & rs.Fields("cod_sistema").Value & "' cod_sistema_version='" & cod_sistema_version & "'>"
                            xmlIn &= "<modulos_versiones>"

                            While Not rs.EOF
                                xmlIn &= "<modulo_version cod_modulo_version='" & rs.Fields("cod_modulo_version").Value & "' cod_modulo='" & rs.Fields("cod_modulo").Value & "' />"

                                rs.MoveNext()
                            End While

                            xmlIn &= "</modulos_versiones>"
                            xmlIn &= "</sistema_version>"
                        End If

                        nvDBUtiles.DBCloseRecordset(rs)
                    Next

                    xmlIn &= "</sistemas_versiones>"
                    xmlIn &= "<modulos_versiones>"

                    For Each cod_modulo_version In modulosList
                        rs = nvDBUtiles.DBOpenRecordset("SELECT cod_modulo FROM verNv_modulo_version WHERE cod_modulo_version=" & cod_modulo_version)

                        If Not rs.EOF Then
                            xmlIn &= "<modulo_version cod_modulo_version='" & cod_modulo_version & "' cod_modulo='" & rs.Fields("cod_modulo").Value & "' />"
                        End If

                        nvDBUtiles.DBCloseRecordset(rs)
                    Next

                    xmlIn &= "</modulos_versiones>"
                    xmlIn &= "<pasajes>"

                    ' Variables temporales para cod_pasaje_depende y pasaje_depende
                    Dim cod_pasaje_depende As Integer
                    Dim pasaje_depende As String

                    For Each cod_pasaje In pasajesLis
                        ' 1) Por cada "pasaje" buscar si tiene "dependientes"
                        rs = nvDBUtiles.DBOpenRecordset("SELECT cod_pasaje_depende, pasaje_depende FROM verNv_pasaje_dependencias WHERE cod_pasaje=" & cod_pasaje)

                        While Not rs.EOF
                            cod_pasaje_depende = CType(rs.Fields("cod_pasaje_depende").Value, Integer)
                            pasaje_depende = CType(rs.Fields("pasaje_depende").Value, String)

                            ' Agregar al XML de exportación el Pasaje del cual depende el original
                            xmlIn &= "<pasaje cod_pasaje='" & cod_pasaje_depende & "' pasaje='" & nvXMLUtiles.escapeXMLAttribute(pasaje_depende) & "' />"
                            rs.MoveNext()
                        End While

                        nvDBUtiles.DBCloseRecordset(rs) ' Cierro el RecordSet actual para iniciar otro

                        ' 2) Obtener la descripción del pasaje objetivo
                        rs = nvDBUtiles.DBOpenRecordset("SELECT pasaje FROM verNv_pasajes WHERE cod_pasaje=" & cod_pasaje)

                        If Not rs.EOF Then
                            xmlIn &= "<pasaje cod_pasaje='" & cod_pasaje & "' pasaje='" & nvXMLUtiles.escapeXMLAttribute(rs.Fields("pasaje").Value) & "' />"
                        End If

                        nvDBUtiles.DBCloseRecordset(rs)
                    Next

                    xmlIn &= "</pasajes>"
                    xmlIn &= "</exportacion>"

                    'xmlIn = "<exportacion>"
                    'xmlIn += "<sistemas_versiones>"
                    'xmlIn += "<sistema_version cod_sistema='nu_si' cod_sistema_version='396'>"
                    'xmlIn += "<modulo_version cod_modulo='nu_mod' cod_modulo_version='1034'>"
                    'xmlIn += "<pasajes>"
                    'xmlIn += "<pasaje cod_pasaje='668'/>"
                    'xmlIn += "</pasajes>"
                    'xmlIn += "</modulo_version>"
                    'xmlIn += "</sistema_version>"
                    'xmlIn += "</sistemas_versiones>"
                    'xmlIn += "</exportacion>"

                    Dim oXml As New System.Xml.XmlDocument
                    oXml.LoadXml(xmlIn)

                    Dim settings As New System.Xml.XmlWriterSettings()
                    settings.Indent = False
                    settings.NewLineOnAttributes = True
                    settings.Encoding = nvConvertUtiles.currentEncoding

                    Dim tmpFilePath As String = ""

                    Try
                        tmpFilePath = System.IO.Path.GetTempFileName()

                        Using writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(tmpFilePath, settings)
                            writer.WriteStartDocument()
                            writer.WriteStartElement("sica_export")
                            writer.WriteRaw(oXml.OuterXml)
                            writer.WriteStartElement("Data")


                            ' Sistemas
                            Dim sistemasNodes As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/sistemas_versiones/sistema_version")
                            Dim sistemasProcesados As New Dictionary(Of String, Boolean)
                            writer.WriteStartElement("sistemas")

                            For Each sistemaNod As System.Xml.XmlNode In sistemasNodes
                                Dim cod_sistema As String = sistemaNod.Attributes("cod_sistema").Value

                                If sistemasProcesados.ContainsKey(cod_sistema.ToLower) Then
                                    Continue For
                                Else
                                    sistemasProcesados(cod_sistema.ToLower) = True
                                End If

                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_sistema, sistema, path_rel, sistema_nro_permiso_grupo FROM verNv_sistemas WHERE cod_sistema='" & cod_sistema & "'")
                                writer.WriteStartElement("sistema")
                                writer.WriteAttributeString("cod_sistema", rs.Fields("cod_sistema").Value)
                                writer.WriteAttributeString("sistema", rs.Fields("sistema").Value)
                                writer.WriteAttributeString("path_rel", rs.Fields("path_rel").Value)

                                Dim nro_permiso_grupo As Integer = rs.Fields("sistema_nro_permiso_grupo").Value
                                permisosExportar.Add(nro_permiso_grupo)

                                nvDBUtiles.DBCloseRecordset(rs)

                                writer.WriteStartElement("sistema_dirs")
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_dir, dir_nombre, cod_directorio_tipo FROM nv_sistema_dir WHERE cod_sistema='" & cod_sistema & "'")

                                While Not rs.EOF
                                    writer.WriteStartElement("sistema_dir")
                                    writer.WriteAttributeString("cod_dir", rs.Fields("cod_dir").Value)
                                    writer.WriteAttributeString("dir_nombre", rs.Fields("dir_nombre").Value)
                                    writer.WriteAttributeString("cod_directorio_tipo", rs.Fields("cod_directorio_tipo").Value)
                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                nvDBUtiles.DBCloseRecordset(rs)

                                writer.WriteEndElement()
                                writer.WriteStartElement("sistema_cns")
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_cn, id_cn_tipo, cn_nombre, cn_default FROM nv_sistema_cn WHERE cod_sistema='" & cod_sistema & "'")

                                While Not rs.EOF
                                    writer.WriteStartElement("sistema_cn")
                                    writer.WriteAttributeString("cod_cn", rs.Fields("cod_cn").Value)
                                    writer.WriteAttributeString("id_cn_tipo", rs.Fields("id_cn_tipo").Value)
                                    writer.WriteAttributeString("cn_nombre", rs.Fields("cn_nombre").Value)
                                    writer.WriteAttributeString("cn_default", rs.Fields("cn_default").Value)
                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                nvDBUtiles.DBCloseRecordset(rs)
                                writer.WriteEndElement()
                                writer.WriteEndElement()
                            Next

                            writer.WriteEndElement()



                            ' Sistemas Versiones
                            Dim sistemasVersionesNodes As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/sistemas_versiones/sistema_version")
                            writer.WriteStartElement("sistemas_versiones")

                            For Each sistemaVersionNod As System.Xml.XmlNode In sistemasVersionesNodes
                                Dim cod_sistema_version As String = sistemaVersionNod.Attributes("cod_sistema_version").Value
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_sistema, sistema_version, sistema_subversion, sistema_microversion FROM verNv_sistema_version WHERE cod_sistema_version=" & cod_sistema_version)

                                writer.WriteStartElement("sistema_version")
                                writer.WriteAttributeString("cod_sistema_version", cod_sistema_version)
                                writer.WriteAttributeString("cod_sistema", rs.Fields("cod_sistema").Value)
                                writer.WriteAttributeString("version", rs.Fields("sistema_version").Value)
                                writer.WriteAttributeString("subversion", rs.Fields("sistema_subversion").Value)
                                writer.WriteAttributeString("microversion", rs.Fields("sistema_microversion").Value)
                                writer.WriteEndElement()

                                nvDBUtiles.DBCloseRecordset(rs)
                            Next

                            writer.WriteEndElement()



                            ' Modulos
                            Dim modulosVersionesNodes As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/sistemas_versiones/sistema_version/modulos_versiones/modulo_version")
                            Dim modulosNodes As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/modulos_versiones/modulo_version")
                            Dim nodes As New List(Of System.Xml.XmlNode)(modulosVersionesNodes.Cast(Of System.Xml.XmlNode)())
                            Dim nList = nodes.Concat(modulosNodes.Cast(Of System.Xml.XmlNode)()) ' Lista joineada
                            Dim modulosProcesados As New Dictionary(Of String, Boolean)

                            writer.WriteStartElement("modulos")

                            For Each moduloVersionNod In nList
                                Dim cod_modulo As String = moduloVersionNod.Attributes("cod_modulo").Value

                                If modulosProcesados.ContainsKey(cod_modulo.ToLower) Then
                                    Continue For
                                Else
                                    modulosProcesados(cod_modulo.ToLower) = True
                                End If

                                rs = nvDBUtiles.DBOpenRecordset("SELECT modulo, modulo_nro_permiso_grupo FROM verNv_modulos WHERE cod_modulo='" & cod_modulo & "'")
                                writer.WriteStartElement("modulo")
                                writer.WriteAttributeString("cod_modulo", cod_modulo)
                                writer.WriteAttributeString("modulo", rs.Fields("modulo").Value)

                                Dim nro_permiso_grupo As Integer = rs.Fields("modulo_nro_permiso_grupo").Value
                                permisosExportar.Add(nro_permiso_grupo)

                                nvDBUtiles.DBCloseRecordset(rs)

                                writer.WriteStartElement("modulo_dirs")
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_modulo_dir, dir_nombre, cod_directorio_tipo FROM nv_modulo_dir WHERE cod_modulo='" & cod_modulo & "'")

                                While Not rs.EOF
                                    writer.WriteStartElement("modulo_dir")
                                    writer.WriteAttributeString("cod_modulo_dir", rs.Fields("cod_modulo_dir").Value)
                                    writer.WriteAttributeString("dir_nombre", rs.Fields("dir_nombre").Value)
                                    writer.WriteAttributeString("cod_directorio_tipo", rs.Fields("cod_directorio_tipo").Value)
                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                nvDBUtiles.DBCloseRecordset(rs)

                                writer.WriteEndElement()
                                writer.WriteStartElement("modulo_cns")
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_cn, id_cn_tipo, cn_nombre FROM nv_modulo_cn WHERE cod_modulo='" & cod_modulo & "'")

                                While Not rs.EOF
                                    writer.WriteStartElement("modulo_cn")
                                    writer.WriteAttributeString("cod_cn", rs.Fields("cod_cn").Value)
                                    writer.WriteAttributeString("id_cn_tipo", rs.Fields("id_cn_tipo").Value)
                                    writer.WriteAttributeString("cn_nombre", rs.Fields("cn_nombre").Value)
                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                nvDBUtiles.DBCloseRecordset(rs)
                                writer.WriteEndElement()
                                writer.WriteEndElement()
                            Next

                            writer.WriteEndElement() 'end Modulos



                            ' Modulos Versiones
                            Dim modulosVersionProcesados As New Dictionary(Of String, Boolean)
                            writer.WriteStartElement("modulos_versiones")

                            For Each moduloVersionNod In nList
                                Dim cod_modulo_version As String = moduloVersionNod.Attributes("cod_modulo_version").Value

                                If modulosVersionProcesados.ContainsKey(cod_modulo_version) Then
                                    Continue For
                                Else
                                    modulosVersionProcesados(cod_modulo_version) = True
                                End If

                                rs = nvDBUtiles.DBOpenRecordset("SELECT modulo, cod_modulo, modulo_version, modulo_subversion, modulo_microversion FROM verNv_modulo_version WHERE cod_modulo_version=" & cod_modulo_version)
                                writer.WriteStartElement("modulo_version")
                                writer.WriteAttributeString("cod_modulo_version", cod_modulo_version)
                                writer.WriteAttributeString("modulo", rs.Fields("modulo").Value)
                                writer.WriteAttributeString("cod_modulo", rs.Fields("cod_modulo").Value)
                                writer.WriteAttributeString("version", rs.Fields("modulo_version").Value)
                                writer.WriteAttributeString("subversion", rs.Fields("modulo_subversion").Value)
                                writer.WriteAttributeString("microversion", rs.Fields("modulo_microversion").Value)
                                nvDBUtiles.DBCloseRecordset(rs)

                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_objeto, path, cod_sub_tipo, depende_de, fe_mod, objeto, cod_obj_tipo, fecha_creacion, fecha_modificacion, cod_tipo_reg, comentario, hash, size, extension, valor FROM verNv_modulo_version_objetos WHERE cod_modulo_version=" & cod_modulo_version & " AND cod_pasaje=0")

                                While Not rs.EOF
                                    writer.WriteStartElement("objeto")
                                    writer.WriteAttributeString("cod_objeto", rs.Fields("cod_objeto").Value)
                                    writer.WriteAttributeString("path", rs.Fields("path").Value)
                                    writer.WriteAttributeString("cod_sub_tipo", rs.Fields("cod_sub_tipo").Value)

                                    If Not IsDBNull(rs.Fields("depende_de").Value) Then
                                        writer.WriteAttributeString("depende_de", rs.Fields("depende_de").Value)
                                    End If

                                    writer.WriteAttributeString("fe_mod", DateToString(rs.Fields("fe_mod").Value))
                                    writer.WriteAttributeString("objeto", rs.Fields("objeto").Value)
                                    writer.WriteAttributeString("cod_obj_tipo", rs.Fields("cod_obj_tipo").Value)
                                    writer.WriteAttributeString("fecha_creacion", DateToString(rs.Fields("fecha_creacion").Value))
                                    writer.WriteAttributeString("fecha_modificacion", DateToString(rs.Fields("fecha_modificacion").Value))
                                    writer.WriteAttributeString("cod_tipo_reg", rs.Fields("cod_tipo_reg").Value)
                                    writer.WriteAttributeString("comentario", rs.Fields("comentario").Value)

                                    If Not IsDBNull(rs.Fields("hash").Value) Then
                                        writer.WriteAttributeString("hash", rs.Fields("hash").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("size").Value) Then
                                        writer.WriteAttributeString("size", rs.Fields("size").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("extension").Value) Then
                                        writer.WriteAttributeString("extension", rs.Fields("extension").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("valor").Value) Then
                                        Dim a As Byte() = rs.Fields("valor").Value
                                        writer.WriteStartElement("valor")
                                        writer.WriteBase64(a, 0, a.Count)
                                        writer.WriteEndElement()
                                    End If

                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                nvDBUtiles.DBCloseRecordset(rs)
                                writer.WriteEndElement()
                            Next

                            writer.WriteEndElement()



                            ' Pasajes
                            Dim pasajesNodes1 As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/sistemas_versiones/sistema_version/modulo_version/pasajes/pasaje")
                            Dim pasajesNodes2 As System.Xml.XmlNodeList = oXml.SelectNodes("exportacion/pasajes/pasaje")
                            Dim nodesPasajes As New List(Of System.Xml.XmlNode)(pasajesNodes1.Cast(Of System.Xml.XmlNode)())
                            Dim pasajesList = nodesPasajes.Concat(pasajesNodes2.Cast(Of System.Xml.XmlNode)()) ' Lista joineada
                            'Dim pasajesProcesados As New Dictionary(Of String, Boolean)

                            writer.WriteStartElement("pasajes")

                            For Each pasajeNod In pasajesList
                                Dim cod_pasaje As String = pasajeNod.Attributes("cod_pasaje").Value
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_modulo, modulo_version, modulo_subversion, modulo_microversion, pasaje, descripcion_pasaje, cod_pasaje_tipo, id_pasaje_estado FROM verNv_Pasajes WHERE cod_pasaje=" & cod_pasaje)

                                writer.WriteStartElement("pasaje")
                                writer.WriteAttributeString("cod_pasaje", cod_pasaje)
                                writer.WriteAttributeString("cod_modulo", rs.Fields("cod_modulo").Value)

                                writer.WriteAttributeString("modulo_version", rs.Fields("modulo_version").Value)
                                writer.WriteAttributeString("modulo_subversion", rs.Fields("modulo_subversion").Value)
                                writer.WriteAttributeString("modulo_microversion", rs.Fields("modulo_microversion").Value)

                                writer.WriteAttributeString("pasaje", rs.Fields("pasaje").Value)
                                writer.WriteAttributeString("descripcion_pasaje", rs.Fields("descripcion_pasaje").Value)
                                writer.WriteAttributeString("cod_pasaje_tipo", rs.Fields("cod_pasaje_tipo").Value)
                                writer.WriteAttributeString("id_pasaje_estado", rs.Fields("id_pasaje_estado").Value)

                                nvDBUtiles.DBCloseRecordset(rs)

                                writer.WriteStartElement("objetos")
                                rs = nvDBUtiles.DBOpenRecordset("SELECT cod_objeto, path, cod_sub_tipo, depende_de, es_baja, fe_mod, objeto, cod_obj_tipo, fecha_creacion, fecha_modificacion, cod_tipo_reg, comentario, hash, size, extension, valor FROM verNv_modulo_version_objetos WHERE cod_pasaje=" & cod_pasaje)

                                While Not rs.EOF
                                    writer.WriteStartElement("objeto")
                                    writer.WriteAttributeString("cod_objeto", rs.Fields("cod_objeto").Value)
                                    writer.WriteAttributeString("path", rs.Fields("path").Value)
                                    writer.WriteAttributeString("cod_sub_tipo", rs.Fields("cod_sub_tipo").Value)

                                    If Not IsDBNull(rs.Fields("depende_de").Value) Then
                                        writer.WriteAttributeString("depende_de", rs.Fields("depende_de").Value)
                                    End If

                                    writer.WriteAttributeString("es_baja", rs.Fields("es_baja").Value)
                                    writer.WriteAttributeString("fe_mod", DateToString(rs.Fields("fe_mod").Value))
                                    writer.WriteAttributeString("objeto", rs.Fields("objeto").Value)
                                    writer.WriteAttributeString("cod_obj_tipo", rs.Fields("cod_obj_tipo").Value)
                                    writer.WriteAttributeString("fecha_creacion", DateToString(rs.Fields("fecha_creacion").Value))
                                    writer.WriteAttributeString("fecha_modificacion", DateToString(rs.Fields("fecha_modificacion").Value))
                                    writer.WriteAttributeString("cod_tipo_reg", rs.Fields("cod_tipo_reg").Value)
                                    writer.WriteAttributeString("comentario", rs.Fields("comentario").Value)

                                    If Not IsDBNull(rs.Fields("hash").Value) Then
                                        writer.WriteAttributeString("hash", rs.Fields("hash").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("size").Value) Then
                                        writer.WriteAttributeString("size", rs.Fields("size").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("extension").Value) Then
                                        writer.WriteAttributeString("extension", rs.Fields("extension").Value)
                                    End If

                                    If Not IsDBNull(rs.Fields("valor").Value) Then
                                        Dim a As Byte() = rs.Fields("valor").Value
                                        writer.WriteStartElement("valor")
                                        writer.WriteBase64(a, 0, a.Count)
                                        writer.WriteEndElement()
                                    End If

                                    writer.WriteEndElement()
                                    rs.MoveNext()
                                End While

                                writer.WriteEndElement() ' objetos
                                nvDBUtiles.DBCloseRecordset(rs)
                                writer.WriteEndElement() ' pasaje
                            Next

                            writer.WriteEndElement() 'pasajes
                            ' end Data
                            writer.WriteEndElement()
                            ' end sica_export
                            writer.WriteEndElement()
                            writer.WriteEndDocument()
                        End Using
                    Catch ex As Exception
                        err.parse_error_xml(ex)
                        Return err
                    End Try

                    Dim compressedFile As String = Compress(tmpFilePath)
                    'Dim outputFile As String = exportedFileName & ".data"
                    'err.params("outputFile") = outputFile
                    'err.params("outputFilePathFull") = exportedFileName 'System.IO.Path.Combine(System.IO.Path.GetDirectoryName(err.params("compressedFile")), err.params("outputFile"))
                    err.params("compressedFile") = compressedFile
                    err.params("outputFilePathFull") = exportedFileName

                    Dim data_bin() As Byte = System.IO.File.ReadAllBytes(err.params("compressedFile"))
                    Dim data_file As New IO.FileStream(exportedFileName, IO.FileMode.Create)
                    data_file.Write(data_bin, 0, data_bin.Length)
                    data_file.Close()

                Catch ex As Exception
                    err.parse_error_xml(ex)
                End Try

                Return err

            End Function

            Private Shared Function Compress(filepath As String) As String
                Dim fname As String = filepath & ".gz"

                Using originalFileStream = New IO.FileStream(filepath, IO.FileMode.Open)
                    Using compressedFileStream As IO.FileStream = IO.File.Create(fname)
                        Using compressionStream As IO.Compression.GZipStream = New IO.Compression.GZipStream(compressedFileStream, IO.Compression.CompressionMode.Compress)
                            originalFileStream.CopyTo(compressionStream)
                        End Using
                    End Using
                End Using

                Return fname
            End Function


            Private Shared Function DateToString(val As Object) As String
                Dim ms As String = val.millisecond.ToString
                Dim anio As String = val.year.ToString & ""
                Dim mes As String = (val.month).ToString
                Dim dia As String = val.day.ToString & ""
                Dim horas As String = val.hour.ToString & ""
                Dim minutos As String = val.Minute.ToString & ""
                Dim segundos As String = val.Second.ToString & ""
                Dim strValue As String = anio & "-" & mes & "-" & dia & " " & horas & ":" & minutos & ":" & segundos & "." & ms

                Return strValue
            End Function


        End Class

    End Namespace
End Namespace

