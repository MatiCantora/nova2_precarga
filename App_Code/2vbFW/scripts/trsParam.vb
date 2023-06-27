
Imports System.Xml
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles
Imports System
Imports System.Collections.Generic

Namespace nvFW

    ''' <summary>
    ''' Objeto diccionario (string, object) extendido. 
    ''' </summary>
    ''' <remarks>
    ''' Se utiliza para transportar colecciones de datos nominadas
    ''' Tiene la función de convertir a XML o JSON
    ''' </remarks>
    Public Class trsParam
        Implements IDictionary(Of String, Object)

        Public name As String = ""

        Dim _dic As Dictionary(Of String, Object)

        ''' <summary>
        ''' Crea el rsParam y lo carga desde un recordset desde el primer registro de este. Name y value del fields
        ''' </summary>
        ''' <remarks>
        ''' Trabaja sobre el registro activo, cada uno de los campos del registro se pasan al rsParam
        ''' </remarks>
        Public Sub New(rs As ADODB.Recordset)
            _dic = New Dictionary(Of String, Object)
            Try
                For i = 0 To rs.Fields.Count - 1
                    Me(rs.Fields(i).Name) = nvUtiles.isNUll(rs.Fields(i).Value, Nothing)
                Next
            Catch ex As Exception

            End Try
        End Sub

        ''' <summary>
        ''' Crea el rsParam desde un Dictonary(Of String, Object)
        ''' </summary>
        ''' <remarks>
        '''        
        '''  </remarks>
        Public Sub New(dic As Dictionary(Of String, Object))
            _dic = dic

        End Sub
        ''' <summary>
        ''' Crea el rsParam y desde dos arrays, una con los nombres y otra con los valores
        ''' </summary>
        ''' <remarks>
        ''' 
        ''' </remarks>

        Public Sub New(names() As String, values() As Object)
            _dic = New Dictionary(Of String, Object)
            Dim c As Integer = 0
            Dim name As String
            For Each value In values
                name = "param" & (c + 1)
                If c <= names.Length - 1 Then name = names(c)
                Me(name) = value
                c += 1
            Next
        End Sub

        Public Sub New()
            _dic = New Dictionary(Of String, Object)
        End Sub


        Public ReadOnly Property Count As Integer Implements ICollection(Of KeyValuePair(Of String, Object)).Count
            Get
                Return _dic.Count
            End Get
        End Property


        Public ReadOnly Property IsReadOnly As Boolean Implements ICollection(Of KeyValuePair(Of String, Object)).IsReadOnly
            Get
                Return False
            End Get
        End Property


        Default Public Property Item(key As String) As Object Implements IDictionary(Of String, Object).Item
            Get
                'Return Me.Item(key, "")
                'Dim def As String = ""
                Dim res As Object = ""
                SyncLock _dic
                    If _dic.Keys.Contains(key) Then
                        res = _dic.Item(key)
                    End If
                End SyncLock
                Return res
            End Get
            Set(value As Object)
                SyncLock _dic
                    _dic.Remove(key)
                    _dic.Item(key) = value
                End SyncLock
            End Set
        End Property


        Default Public ReadOnly Property Item(key As String, def As Object) As Object 'Implements IDictionary(Of String, Object).Item
            Get
                Dim res = def
                SyncLock _dic
                    If _dic.Keys.Contains(key) Then
                        res = _dic.Item(key)
                    End If
                End SyncLock
                Return res
            End Get
        End Property


        Public Shared Function getValueOrRiseError2(dic As Dictionary(Of String, Object), key As String) As Object

            Dim dictrsParam As New trsParam(dic)

            Dim res As Object = dictrsParam.Item(key, Nothing)
            If res Is Nothing Then
                'registrar error
                Throw New Exception("Error en la lectura de la key " & key)
            End If

            Return res

        End Function


        Public Function getValueOrRiseError(key As String) As Object
            Return getValueOrRiseError2(Me._dic, key)
        End Function


        Public ReadOnly Property Keys As ICollection(Of String) Implements IDictionary(Of String, Object).Keys
            Get
                Return _dic.Keys
            End Get
        End Property


        Public ReadOnly Property Values As ICollection(Of Object) Implements IDictionary(Of String, Object).Values
            Get
                Return _dic.Values
            End Get
        End Property

        Public Sub Add(item As KeyValuePair(Of String, Object)) Implements ICollection(Of KeyValuePair(Of String, Object)).Add
            _dic.Add(item.Key, item.Value)
        End Sub

        Public Sub Add(key As String, value As Object) Implements IDictionary(Of String, Object).Add
            _dic.Add(key, value)
        End Sub

        Public Sub Clear() Implements ICollection(Of KeyValuePair(Of String, Object)).Clear
            _dic.Clear()
        End Sub

        Public Sub CopyTo(array() As KeyValuePair(Of String, Object), arrayIndex As Integer) Implements ICollection(Of KeyValuePair(Of String, Object)).CopyTo
            Throw New NotImplementedException()
        End Sub

        Public Function Contains(item As KeyValuePair(Of String, Object)) As Boolean Implements ICollection(Of KeyValuePair(Of String, Object)).Contains
            Return _dic.Contains(item)
        End Function

        Public Function ContainsKey(key As String) As Boolean Implements IDictionary(Of String, Object).ContainsKey
            Return _dic.ContainsKey(key)
        End Function

        Public Function GetEnumerator() As IEnumerator(Of KeyValuePair(Of String, Object)) Implements IEnumerable(Of KeyValuePair(Of String, Object)).GetEnumerator
            Return _dic.GetEnumerator()
        End Function

        Public Function Remove(item As KeyValuePair(Of String, Object)) As Boolean Implements ICollection(Of KeyValuePair(Of String, Object)).Remove
            Return _dic.Remove(item.Key)
        End Function

        Public Function Remove(key As String) As Boolean Implements IDictionary(Of String, Object).Remove
            Return _dic.Remove(key)
        End Function

        Public Function TryGetValue(key As String, ByRef value As Object) As Boolean Implements IDictionary(Of String, Object).TryGetValue
            Return _dic.TryGetValue(key, value)
        End Function

        Private Function IEnumerable_GetEnumerator() As IEnumerator Implements IEnumerable.GetEnumerator
            Return DirectCast(_dic, System.Collections.IEnumerable).GetEnumerator()
        End Function


        ''' <summary>
        ''' Devuelve un String con el JSON de la colección
        ''' </summary>
        ''' <remarks>
        ''' 
        ''' </remarks>
        Public Function toJSON(Optional ByVal format As nvConvertUtiles.nvJS_format = nvConvertUtiles.nvJS_format.js_classic, Optional ByVal date_format As String = "") As String
            Dim sep As String = vbCrLf
            Dim res As String = "{" & sep

            For i = 0 To _dic.Count - 1
                Dim strType As String
                Dim key As String = _dic.Keys(i)
                Dim obj As Object = _dic(_dic.Keys(i))

                If obj Is Nothing Then
                    res &= """" & key & """: null" & sep
                Else
                    If (obj.GetType().IsEnum) Then
                        strType = [Enum].GetUnderlyingType(obj.GetType()).ToString()
                    Else
                        strType = obj.GetType().ToString()
                    End If

                    Select Case strType.ToString.ToLower
                        Case "nvfw.trsparam"
                            res &= """" & key & """:" & obj.toJSON(format, date_format) '& sep

                        Case "system.xml.xmldocument"
                            res &= """" & key & """:" & nvConvertUtiles.objectToScript(obj.outerXML, format, date_format) & sep

                        Case "nvfw.nvjson_string"
                            res &= """" & key & """:" & obj.value & sep

                        Case "nvfw.terror"
                            res &= """" & key & """:" & obj.get_error_json() '& sep

                        Case "system.collections.generic.dictionary`2[system.string,system.object]"
                            Dim objAux As Dictionary(Of String, Object) = obj
                            Dim trsDic As New trsParam(objAux)
                            res &= """" & key & """:" & trsDic.toJSON(format, date_format) '& sep

                        Case "system.collections.arraylist"

                            res &= """" & key & """: [" & sep

                            res &= Me.ArrayListToJSON(obj, format, date_format)

                            res &= "]" & sep
                        Case Else
                            res &= """" & key & """:" & nvConvertUtiles.objectToScript(obj, format, date_format) & sep

                    End Select

                End If

                If i <> _dic.Count - 1 Then
                    res &= ","
                End If
            Next

            res &= "}"

            Return res
        End Function
        ''' <summary>
        ''' Devuelve un String con el JSON de la lista
        ''' </summary>
        ''' <remarks>
        ''' 
        ''' </remarks>
        Public Function ArrayListToJSON(objList As System.Collections.ArrayList, Optional ByVal format As nvConvertUtiles.nvJS_format = nvConvertUtiles.nvJS_format.js_classic, Optional ByVal date_format As String = "") As String

            Dim sep As String = vbCrLf
            Dim res As String = ""
            Dim strType As String

            For i = 0 To objList.Count - 1
                'Dim strType As String = objList(i).GetType().ToString()

                If objList(i) Is Nothing Then
                    res &= "null" & sep
                Else
                    If (objList(i).GetType().IsEnum) Then
                        strType = [Enum].GetUnderlyingType(objList(i).GetType()).ToString()
                    Else
                        strType = objList(i).GetType().ToString()
                    End If

                    Select Case strType.ToString.ToLower
                        Case "nvfw.trsparam"
                            res &= objList(i).toJSON(format, date_format) '& sep

                        Case "system.xml.xmldocument"
                            res &= nvConvertUtiles.objectToScript(objList(i).outerXML, format, date_format) & sep

                        Case "nvfw.nvjson_string"
                            res &= objList(i) & sep

                        Case "nvfw.terror"
                            res &= objList(i).get_error_json() '& sep

                        Case "system.collections.generic.dictionary`2[system.string,system.object]"
                            Dim objAux As Dictionary(Of String, Object) = objList(i)
                            Dim trsDic As New trsParam(objAux)
                            res &= trsDic.toJSON(format, date_format) '& sep

                        Case "system.collections.arraylist"

                            res &= "[" & sep

                            res &= Me.ArrayListToJSON(objList(i), format, date_format)

                            res &= "]" & sep
                        Case Else
                            res &= nvConvertUtiles.objectToScript(objList(i), format, date_format) & sep

                    End Select

                End If

                If i <> objList.Count - 1 Then
                    res &= ","
                End If
            Next

            'res &= "}"

            Return res

        End Function

        ''' <summary>
        ''' Devuelve un String con el XML de la colección
        ''' </summary>
        ''' <remarks>
        ''' 
        ''' </remarks>
        Public Function toXML(Optional ByVal includeRoot As Boolean = True, Optional ByRef RootName As String = "params") As String
            'Dim strXML As String = ""
            Dim ms As New System.IO.MemoryStream
            Dim settings As New XmlWriterSettings()
            settings.Indent = False
            settings.NewLineOnAttributes = True
            settings.OmitXmlDeclaration = True
            settings.Encoding = nvConvertUtiles.currentEncoding

            Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, settings)
            writer.WriteStartDocument()
            writer.WriteStartElement(RootName)

            'If includeRoot Then strXML = "<" & RootName & ">"

            For i = 0 To _dic.Keys.Count - 1
                'Dim mXML As New System.Xml.XmlDocument
                Dim key As String = _dic.Keys(i)
                Dim obj As Object = _dic(key)
                Dim strValue As String = ""
                Dim strType As String
                'Dim value As String = nvUtiles.isNUllorEmpty(Me.params(key), "")
                writer.WriteStartElement(key)

                If Not obj Is Nothing Then
                    If (obj.GetType().IsEnum) Then
                        strType = [Enum].GetUnderlyingType(obj.GetType()).ToString()
                    Else
                        strType = obj.GetType().ToString()
                    End If
                End If


                If obj Is Nothing OrElse strType.ToString.ToLower = "system.dbnull" OrElse (strType.ToString.ToLower = "system.collections.arraylist" AndAlso obj.count = 0) Then

                Else


                    Select Case strType.ToString.ToLower
                        Case "system.int16", "system.int32", "system.int64", "system.single", "system.double", "system.decimal", "system.byte"
                            writer.WriteString(CDbl(obj).ToString(System.Globalization.CultureInfo.CreateSpecificCulture("en-US")))
                        Case "system.boolean"
                            writer.WriteString(IIf(obj, "true", "false"))
                        Case "system.datetime"
                            Dim d As DateTime = obj
                            writer.WriteString(d.ToString("MM/dd/yyyy HH:mm:ss.fff"))
                        Case "system.byte[]"
                            writer.WriteString(System.Convert.ToBase64String(obj))

                        Case "nvfw.trsparam"
                            writer.WriteRaw(obj.toXML(False))
                            'strValue = obj.toXML(False)
                            'Res &= key & ":" & obj.toJSON() & vbCrLf
                        Case "system.collections.generic.dictionary`2[system.string,system.object]"

                            Dim objAux As Dictionary(Of String, Object) = obj
                            Dim trsDic As New trsParam(objAux)
                            writer.WriteRaw(trsDic.toXML(False))

                        Case "system.xml.xmldocument"
                            'En el caso que no se quiera embeber la raiz del parametro xml tomamos solos sus hijos
                            If key = obj.childNodes(0).name Then
                                writer.WriteRaw(obj.childNodes(0).innerXML)
                            Else
                                writer.WriteRaw(obj.outerXML)
                            End If
                            'strValue = obj.outerXML
                        Case "nvfw.nvjson_string"
                            writer.WriteString(obj.value)
                        Case Else
                            writer.WriteString(obj)
                    End Select

                End If
                writer.WriteEndElement()
                'strXML &= "<" & key & ">" & strValue & "</" & key & ">"
            Next
            writer.WriteEndElement() 'error_mensajes
            writer.WriteEndDocument()
            writer.Close()
            ms.Position = 0
            Dim bytes(ms.Length - 1) As Byte
            ms.Read(bytes, 0, ms.Length)
            ms.Close()
            Dim strXML As String = nvConvertUtiles.currentEncoding.GetString(bytes)


            If Not includeRoot Then
                Dim oXML As New System.Xml.XmlDocument
                oXML.LoadXml(strXML)
                strXML = oXML.DocumentElement.InnerXml
            End If

            Return strXML

        End Function
        'Public Function toXML2(Optional ByVal includeRoot As Boolean = True, Optional ByRef RootName As String = "params") As String
        '    Dim strXML As String = ""
        '    If includeRoot Then strXML = "<" & RootName & ">"

        '    For i = 0 To _dic.Keys.Count - 1
        '        Dim mXML As New System.Xml.XmlDocument
        '        Dim key As String = _dic.Keys(i)
        '        Dim obj As Object = _dic(key)
        '        Dim strValue As String = ""
        '        Dim strType As String
        '        'Dim value As String = nvUtiles.isNUllorEmpty(Me.params(key), "")

        '        If obj Is Nothing Then
        '            Continue For
        '        Else
        '            If (obj.GetType().IsEnum) Then
        '                strType = [Enum].GetUnderlyingType(obj.GetType()).ToString()
        '            Else
        '                strType = obj.GetType().ToString()
        '            End If

        '            Select Case strType.ToString.ToLower
        '                Case "nvfw.trsparam"
        '                    strValue = obj.toXML(False)
        '                    'Res &= key & ":" & obj.toJSON() & vbCrLf
        '                Case "system.xml.xmldocument"
        '                    strValue = obj.outerXML
        '                Case "nvfw.nvjson_string"
        '                    strValue = obj.value
        '                Case Else
        '                    If obj.ToString().Length > 1 AndAlso obj.ToString()(1) = "<" Then 'Si es un posible XML
        '                        Try
        '                            If (obj.ToString().IndexOf("<?xml") = -1) Then
        '                                mXML.LoadXml("<?xml version='1.0' encoding='iso-8859-1'?>" & obj.ToString)
        '                            Else
        '                                mXML.LoadXml(obj.ToString)
        '                                'obj = obj.Substring(obj.IndexOf(">") + 1)
        '                            End If

        '                            strValue = mXML.OuterXml

        '                        Catch ex As Exception
        '                            strValue = obj.ToString()
        '                        End Try
        '                    Else ' Cualquier otro tipo de datos
        '                        strValue = obj
        '                    End If
        '            End Select

        '        End If

        '        strXML &= "<" & key & ">" & strValue & "</" & key & ">"
        '    Next
        '    If includeRoot Then strXML &= "</" & RootName & ">"
        '    Stop
        '    Return strXML

        'End Function
    End Class

End Namespace