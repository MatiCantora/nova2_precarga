Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW

    Public Class nvConvertUtiles


        ''' <summary>
        ''' Devuelve una string base64 con la imgen del QR
        ''' </summary>
        ''' <param name="cadena">Cadena a mostrar al leer el QR</param>
        ''' <returns>Imagen QR</returns>
        ''' <remarks></remarks>
        Public Shared Function stringToQR(cadena As String) As String

            Try

                Dim qrEncoder As New Gma.QrCodeNet.Encoding.QrEncoder(Gma.QrCodeNet.Encoding.ErrorCorrectionLevel.H)
                Dim qrCode = qrEncoder.Encode(cadena)
                Dim renderer = New Gma.QrCodeNet.Encoding.Windows.Render.GraphicsRenderer(New Gma.QrCodeNet.Encoding.Windows.Render.FixedModuleSize(5, Gma.QrCodeNet.Encoding.Windows.Render.QuietZoneModules.Two), System.Drawing.Brushes.Black, System.Drawing.Brushes.White)
                Dim bytes As Byte()
                Using stream As New IO.MemoryStream()
                    renderer.WriteToStream(qrCode.Matrix, System.Drawing.Imaging.ImageFormat.Png, stream)
                    bytes = stream.ToArray
                End Using

                Dim imgQR As String = Convert.ToBase64String(bytes)

                Return imgQR
            Catch ex As Exception
                Throw ex
            End Try
        End Function


        Public Shared currentEncoding As Encoding = System.Text.Encoding.GetEncoding("ISO-8859-1")
        'Private Shared _JScript_engine As Microsoft.JScript.Vsa.VsaEngine
        Private Shared _unique_id_increment As Integer = 0


        Public Shared Function StringToBytes(cadena As String) As Byte()
            Return currentEncoding.GetBytes(cadena)
        End Function

        Public Shared Function BytesToString(bytes As Byte()) As String
            If bytes Is Nothing Then Return ""
            Return currentEncoding.GetString(bytes)
        End Function


        ''' <summary>
        ''' Devuelve un objeto fecha desde una cadena
        ''' </summary>
        ''' <param name="objFecha">Fecha en formato cadena de caracteres</param>
        ''' <param name="modo">
        '''    modo '1' = "dd/MM/yyyy"
        '''    modo '2' = "MM/dd/yyyy"
        '''    modo '3' = "yyyy-MM-dd"
        ''' </param>
        ''' <returns>Valor fecha</returns>
        ''' <remarks></remarks>
        Public Shared Function FechaToSTR(objFecha As Date, Optional modo As Integer = 1) As String
            Select Case modo
                Case 1
                    Return objFecha.ToString("dd/MM/yyyy")
                Case 2
                    Return objFecha.ToString("MM/dd/yyyy")
                Case 3
                    Return objFecha.ToString("yyyy-MM-dd")
            End Select

            Return ""
        End Function


        ''' <summary>
        ''' Devuelve un objeto fecha desde una cadena
        ''' </summary>
        ''' <param name="strFecha">Fecha en formato cadena de caracteres</param>
        ''' <param name="modo">
        '''    modo 'XSL' = 'mm-dd-yyyyThh:mm:ss'
        '''    modo 'UTC' = ''
        '''    modo 'SCRIPT' = 'dd/mm/yyyy'
        ''' </param>
        ''' <returns>Valor fecha</returns>
        ''' <remarks></remarks>
        Public Shared Function parseFecha(ByVal strFecha As String, Optional ByVal modo As String = "XLS") As DateTime
            Dim a As String
            Select Case modo.ToUpper
                Case "XSL"
                    a = strFecha.Replace("-", "/").Replace("T", " ") & "."
                    a = a.Substring(0, a.IndexOf("."))

                Case "UTC"
                    Return DateTime.Parse(strFecha)

                Case "SCRIPT"
                    'Dim cadFecha As String = strFecha
                    'Dim dia = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    'cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    'Dim mes = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    'cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    'Dim anio = cadFecha
                    'a = mes & "/" & dia & "/" & anio
                    Dim cultureinfo2 As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
                    Return DateTime.Parse(strFecha, cultureinfo2)
                Case "ES-AR"
                    'Dim cadFecha As String = strFecha
                    'Dim dia = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    'cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    'Dim mes = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    'cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    'Dim anio = cadFecha
                    'a = mes & "/" & dia & "/" & anio
                    Dim cultureinfo2 As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("es-AR")
                    Return DateTime.Parse(strFecha, cultureinfo2)
                Case Else
                    Dim cadFecha As String = strFecha
                    Dim dia = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    Dim mes = cadFecha.Substring(0, cadFecha.IndexOf("/"))
                    cadFecha = cadFecha.Substring(cadFecha.IndexOf("/") + 1)
                    Dim anio = cadFecha
                    a = mes & "/" & dia & "/" & anio
            End Select
            Dim cultureinfo As System.Globalization.CultureInfo = New System.Globalization.CultureInfo("en-US")
            Dim fe As DateTime = DateTime.Parse(a, cultureinfo)
            Return fe
        End Function

        ''' <summary>
        ''' Convierte el valor de la variable cadena a un objeto de .Net
        ''' </summary>
        ''' <param name="cadena"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function StringToObject(ByVal cadena As String, type As String, Optional errorReturnNothing As Boolean = False, Optional culture As String = "en-US") As Object

            If cadena Is Nothing Or IsDBNull(cadena) Then
                Return Nothing
            End If
            Try
                Select Case type.ToLower
                    Case "i8", "int"
                        Dim val As Integer = cadena
                        Return val
                    Case "i2"
                        Dim val As Int16 = cadena
                        Return val
                    Case "ui1"
                        Dim val As Byte = cadena
                        Return val
                    Case "bin.hex"
                        Dim bytes() As Byte
                        bytes = nvConvertUtiles.BinhexToBytes(cadena) ' Convert.FromBase64String(cadena)
                        Return bytes
                    Case "float"
                        Dim val As Double = cadena
                        Return val
                    Case "r4"
                        Dim val As Single = cadena
                        Return val
                    Case "number", "money"
                        Dim val As Decimal = Decimal.Parse(cadena, New System.Globalization.CultureInfo("en-US"))
                        Return val
                    Case "decimal"
                        Dim val As Decimal = cadena
                        Return val
                    Case "boolean", "bit"
                        Dim val As Boolean = cadena.ToLower = "true" Or cadena = "1"
                        Return val
                    Case "datetime"
                        Dim pv As New System.Globalization.CultureInfo(culture)

                        If culture = "es-AR" Then
                            Dim x As New System.Globalization.DateTimeFormatInfo()

                            x.FullDateTimePattern = "dd/MM/yyyy HH:mm:ss.fff"
                            x.ShortDatePattern = "dd/MM/yyyy"
                            x.AbbreviatedMonthNames = New String() {"ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic", ""}

                            pv.DateTimeFormat = x
                        End If

                        Dim res As DateTime = System.Convert.ToDateTime(cadena, pv)
                        Return res
                    Case "string", "uuid", "varchar", "file"
                        Return cadena
                    Case Else
                        Return cadena
                End Select
            Catch ex As Exception
                If errorReturnNothing Then
                    Return Nothing
                Else
                    Throw ex
                End If
            End Try

        End Function

        ''' <summary>
        ''' Convierte el valor de la variable cadena a un objeto de .Net
        ''' </summary>
        ''' <param name="cadena"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function StringToAdoParamObject(ByVal cadena As String, type As String) As Object
            If cadena Is Nothing Then
                Return Nothing
            End If
            Select Case type.ToLower()

                Case "datetime"
                    Dim pv As New System.Globalization.CultureInfo("en-US")
                    Dim res As DateTime = System.Convert.ToDateTime(cadena, pv)
                    cadena = res.ToString("yyyy-dd-MM HH:mm:ss.fff") 'Cuidado, por alguna razon SQL Server interpreta el yyyy-dd-MM???
                    Return cadena

                Case Else
                    Return StringToObject(cadena, type)
            End Select

        End Function

        ''' <summary>
        ''' Convierte el valor de la variable cadena a un objeto de .Net
        ''' </summary>
        ''' <param name="cadena"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function StringToObject(ByVal cadena As String, type As ADODB.DataTypeEnum) As Object
            Dim strType As String = ADOTypeToXMLType(type)
            Return StringToObject(cadena, strType)
        End Function

        ''' <summary>
        ''' Convierte el valor de la variable objeto en una cadena de tipo script de javascript
        ''' </summary>
        ''' <param name="objeto"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function objectToScript(ByVal objeto As Object, Optional ByVal format As nvJS_format = nvJS_format.js_classic, Optional ByVal date_format As String = "", Optional ByVal string_quote As String = "") As String

            If objeto Is Nothing Then Return "null"

            If IsDBNull(objeto) Then Return "null"

            Dim squote As String = ""
            Dim dateFormat As String = ""

            Select Case format
                Case nvJS_format.js_classic
                    squote = "'"
                    dateFormat = "MM/dd/yyyy HH:mm:ss" '5/2/2020 6:40:31 PM
                Case nvJS_format.js_json
                    squote = """"
                    dateFormat = "yyyy-MM-ddTHH:mm:ss.fffZ"
            End Select

            If date_format <> "" Then dateFormat = date_format
            If string_quote <> "" Then squote = string_quote

            Dim res As String = ""
            Dim strType As String

            If (objeto.GetType().IsEnum) Then
                strType = [Enum].GetUnderlyingType(objeto.GetType()).ToString()
            Else
                strType = objeto.GetType().ToString()
            End If

            Select Case strType.ToString.ToLower
                Case "system.int16", "system.int32", "system.int64", "system.single", "system.double", "system.decimal", "system.byte"
                    res = CDbl(objeto).ToString(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"))

                Case "system.string"
                    '//Corregir caracter de escape "\"
                    objeto = objeto.ToString().Replace("\", "\\")
                    '//Corregir comillas simples o dobles
                    objeto = objeto.ToString().Replace(squote, "\" & squote)
                    ' //Corregir saltos de lineas
                    objeto = objeto.ToString().Replace(vbCrLf, "\n")
                    objeto = objeto.ToString().Replace(vbCr, "\r")
                    objeto = objeto.ToString().Replace(vbLf, "\n")

                    res = squote & objeto.ToString() & squote
                Case "system.boolean"
                    res = IIf(objeto, "true", "false")

                Case "system.datetime"
                    Dim d As DateTime = objeto
                    Select Case format
                        Case nvJS_format.js_classic
                            res = "new Date(Date.parse(""" + d.ToString(New System.Globalization.CultureInfo("en-US")) + """))"
                        Case nvJS_format.js_json
                            res = squote & d.ToString(dateFormat) & squote
                    End Select
                    'res = squote & d.ToString(dateFormat) & squote
                    'res = "new Date(Date.parse(""" + d.ToString(New System.Globalization.CultureInfo("en-US")) + """))"
                Case "nvfw.trsparam", "system.collections.generic.dictionary`2[system.string,system.object]"
                    Dim obj As trsParam

                    If strType.ToString.ToLower = "system.collections.generic.dictionary`2[system.string,system.object]" Then
                        obj = New trsParam(DirectCast(objeto, Dictionary(Of String, Object)))
                    Else
                        obj = objeto
                    End If

                    res = obj.toJSON()
                Case "system.byte[]"
                    res = squote & System.Convert.ToBase64String(objeto) & squote
                    'Case "system.xml.XmlDocument"
                    '    res = "(new tXML()).loadXML(" & nvConvertUtiles.objectToScriptString(objeto.outerXML) & ")"
                Case Else
                    res = squote & "Error. Tipo desconocido" & squote
            End Select

            Return res

        End Function

        ''' <summary>
        ''' Convierte el valor de la variable String en un valor sin comas ni saltos de linea para utilizar en los nvLogs
        ''' </summary>
        ''' <param name="str"></param>
        ''' <returns></returns>
        ''' <remarks></remarks>
        Public Shared Function StringTonvLogParam(str As String) As String
            If str <> "" Then
                str = str.Replace(",", "{;}")
                str = str.Replace(vbCrLf, " ")
                str = str.Replace(vbCr, " ")
                str = str.Replace(vbLf, " ")
            End If
            Return str
        End Function
        Public Shared Function objectToSQLScript(ByVal valor As String, DataTypeString As String, Optional [default] As Object = Nothing) As String
            Dim DataType As DataTypes
            Dim res As Object = [default]
            Try
                DataType = [Enum].Parse(DataType.GetType(), DataTypeString)
                res = StringToDataType(valor, DataType, [default])
            Catch ex As Exception
            End Try

            Return objectToSQLScript(res)
        End Function

        Public Shared Function objectToSQLScript(ByVal valor As String, DataType As DataTypes, Optional [default] As Object = Nothing) As String
            Dim res As Object = StringToDataType(valor, DataType, [default])
            Return objectToSQLScript(res)
        End Function

        Public Shared Function objectToSQLScript(ByVal objeto As Object) As String

            If objeto Is Nothing Then Return "null"

            If IsDBNull(objeto) Then Return "null"

            Dim res As String = ""
            Dim strType As String

            If (objeto.GetType().IsEnum) Then
                strType = [Enum].GetUnderlyingType(objeto.GetType()).ToString()
            Else
                strType = objeto.GetType().ToString()
            End If

            Select Case strType.ToString.ToLower
                Case "system.int16", "system.int32", "system.int64", "system.single", "system.double", "system.decimal", "system.byte"
                    res = CDbl(objeto).ToString(System.Globalization.CultureInfo.CreateSpecificCulture("en-US"))

                Case "system.string"
                    '//Corregir caracter de escape "\"
                    objeto = objeto.ToString().Replace("'", "''")
                    res = "'" & objeto.ToString() & "'"
                Case "system.boolean"
                    res = IIf(objeto, "1", "0")

                Case "system.datetime"
                    Dim d As DateTime = objeto
                    res = "convert(datetime, '" & d.ToString("MM/dd/yyyy  HH:mm:ss.fff") & "', 101)" ' new Date(Date.parse('" + d.ToString(New System.Globalization.CultureInfo("en-US")) + "'))"
                Case Else
                    res = "'Error. Tipo desconocido'"
            End Select

            Return res

        End Function

        Public Shared Function objectToDTSparam(ByVal objeto As Object) As String

            If objeto Is Nothing Then Return ""

            If IsDBNull(objeto) Then Return ""

            Dim res As String = ""
            Dim strType As String

            If (objeto.GetType().IsEnum) Then
                strType = [Enum].GetUnderlyingType(objeto.GetType()).ToString()
            Else
                strType = objeto.GetType().ToString()
            End If

            Select Case strType.ToString.ToLower
                Case "system.int16", "system.int32", "system.int64", "system.single", "system.double", "system.decimal", "system.byte"
                    res = """" & CDbl(objeto).ToString(System.Globalization.CultureInfo.CurrentCulture) & """" 'System.Globalization.CultureInfo.CreateSpecificCulture("en-US")

                Case "system.string"
                    Dim reg As New System.Text.RegularExpressions.Regex("""")
                    res = """" & reg.Replace(objeto.ToString(), """""") & """"

                Case "system.boolean"
                    res = """" & IIf(objeto, "1", "0") & """"

                Case "system.datetime"
                    Dim d As DateTime = objeto
                    res = """" & d.ToString(System.Globalization.CultureInfo.CurrentCulture) & """"
                Case Else
                    res = "Error. Tipo desconocido"
            End Select

            Return res

        End Function
        Public Shared Function objectToScriptString(ByVal objeto As Object, Optional culture As String = "en-US") As String

            If objeto Is Nothing Then Return ""

            If IsDBNull(objeto) Then Return ""

            Dim res As String = ""
            Dim strType As String

            If (objeto.GetType().IsEnum) Then
                strType = [Enum].GetUnderlyingType(objeto.GetType()).ToString()
            Else
                strType = objeto.GetType().ToString()
            End If

            Select Case strType.ToString.ToLower
                Case "system.int16", "system.int32", "system.int64", "system.single", "system.double", "system.decimal", "system.byte"
                    res = "'" & CDbl(objeto).ToString(System.Globalization.CultureInfo.CreateSpecificCulture("en-US")) & "'"

                Case "system.string"
                    '//Corregir caracter de escape "\"
                    objeto = objeto.ToString().Replace("\", "\\")
                    '//Corregir comillas simples
                    objeto = objeto.ToString().Replace("'", "\'")
                    ' //Corregir saltos de lineas
                    objeto = objeto.ToString().Replace(vbCrLf, "\n")
                    objeto = objeto.ToString().Replace(vbCr, "\r")
                    objeto = objeto.ToString().Replace(vbLf, "\n")

                    res = "'" & objeto.ToString() & "'"
                Case "system.boolean"
                    res = "'" & IIf(objeto, "true", "false") & "'"

                Case "system.datetime"
                    Dim d As DateTime = objeto
                    Select Case culture
                        Case "en-US"
                            res = "'" & d.ToString("MM/dd/yyyy") & "'" '"new Date(Date.parse('" + d.ToString(New System.Globalization.CultureInfo("en-US")) + "'))"
                        Case "es-AR"
                            res = "'" & d.ToString("dd/MM/yyyy") & "'" '"new Date(Date.parse('" + d.ToString(New System.Globalization.CultureInfo("en-US")) + "'))"
                    End Select

                Case Else
                    res = "'Error. Tipo desconocido'"
            End Select

            Return res

        End Function

        Public Shared Function ParamTypeToSQLType(tipo As String) As String
            Dim res As String = ""

            Select Case Trim(tipo).ToLower
                Case "int"
                    res = "bigint"
                Case "varchar", "file"
                    res = "varchar(max)"
                Case "datetime"
                    res = "datetime"
                Case "file"
                    res = "varchar"
                Case "money"
                    res = "money"
                Case "bit"
                    res = "bit"
                Case Else
                    res = "varchar(max)"
            End Select

            Return res

        End Function

        Public Shared Function ParamTypeToPLSQLType(tipo As String) As String
            Dim res As String = ""

            Select Case Trim(tipo).ToLower
                Case "int"
                    res = "NUMBER"
                Case "varchar", "file"
                    res = "varchar(8000)"
                Case "datetime"
                    res = "timestamp"
                Case "money"
                    res = "NUMBER(15,2)"
                Case "bit"
                    res = "NUMBER"
                Case Else
                    res = "varchar(8000)"
            End Select

            Return res

        End Function

        Public Shared Function XMLTypeToAdoType(ByVal type As String) As ADODB.DataTypeEnum
            'Cuando se pasa una fecha como parametro, el hijo de puta corta los decimales
            'Para evitar eso pasamos las fechas como cadenas
            'Cuando se quiere saber el tipo solamente se debe utilizar "XMLTypeToAdoType"
            'Cuando se quiere saber el tipo para utilizar como parámetro se dele utilizar "XMLTypeToAdoTParamType"

            'Tipo de dato SQL: tipo Dato XML : Tipo Dato ADO
            'bigint:     i8() : adBigInt(bigint)
            'smallint:   i2() : adSmallInt(smallint)
            'tinyint:    ui1() : adUnsignedTinyInt(tinyint)
            'int:        Int() : adInteger(Int)
            'timestamp:  bin.hex() : adBinary(timestamp)
            'float:      float() : adDouble(float)
            'real:       r4() : adSingle(real)
            'numeric:    number() : adNumeric(numeric)
            'decimal : number :: adNumeric (decimal)
            'smallmoney: number() : adCurrency(smallmoney)
            'money:      number() : adCurrency(money)
            'bit : boolean :: adBoolean (bit)
            'date : string :: adVarWChar (date)
            'datetimeoffset : string :: adVarWChar (datetimeoffset)
            'datetime2 : string :: adVarWChar (datetime2)
            'smalldatetime: DateTime() : adDBTimeStamp(smalldatetime)
            'datetime:   DateTime() : adDBTimeStamp(DateTime)
            'time : string :: adVarWChar (time)
            'binary:     bin.hex() : adBinary(binary)
            'varbinary:  bin.hex() : adVarBinary(varbinary)
            'image:      bin.hex() : adLongVarBinary(Image)
            'varchar : string :: adVarChar (varchar)
            'char : string :: adChar (char)
            'nvarchar : string :: adVarWChar (nvarchar)
            Select Case type
                Case "i8"
                    Return ADODB.DataTypeEnum.adBigInt
                Case "i2"
                    Return ADODB.DataTypeEnum.adSmallInt
                Case "ui1"
                    Return ADODB.DataTypeEnum.adTinyInt
                Case "int"
                    Return ADODB.DataTypeEnum.adInteger
                Case "bin.hex"
                    Return ADODB.DataTypeEnum.adVarBinary
                Case "float"
                    Return ADODB.DataTypeEnum.adDouble
                Case "r4"
                    Return ADODB.DataTypeEnum.adSingle
                Case "number"
                    Return ADODB.DataTypeEnum.adNumeric
                Case "decimal"
                    Return ADODB.DataTypeEnum.adDecimal
                Case "boolean"
                    Return ADODB.DataTypeEnum.adBoolean
                Case "dateTime"
                    Return ADODB.DataTypeEnum.adDBTimeStamp
                    'Return ADODB.DataTypeEnum.adVarChar
                Case "string", "uuid"
                    Return ADODB.DataTypeEnum.adVarChar
                Case Else
                    Return ADODB.DataTypeEnum.adIUnknown
            End Select

        End Function
        Public Shared Function XMLTypeToAdoParamType(ByVal type As String) As ADODB.DataTypeEnum
            'Cuando se pasa una fecha como parametro, el hijo de puta corta los decimales
            'Para evitar eso pasamos las fechas como cadenas
            'Cuando se quiere saber el tipo solamente se debe utilizar "XMLTypeToAdoType"
            'Cuando se quiere saber el tipo para utilizar como parámetro se dele utilizar "XMLTypeToAdoTParamType"

            'Tipo de dato SQL: tipo Dato XML : Tipo Dato ADO
            'bigint:     i8() : adBigInt(bigint)
            'smallint:   i2() : adSmallInt(smallint)
            'tinyint:    ui1() : adUnsignedTinyInt(tinyint)
            'int:        Int() : adInteger(Int)
            'timestamp:  bin.hex() : adBinary(timestamp)
            'float:      float() : adDouble(float)
            'real:       r4() : adSingle(real)
            'numeric:    number() : adNumeric(numeric)
            'decimal : number :: adNumeric (decimal)
            'smallmoney: number() : adCurrency(smallmoney)
            'money:      number() : adCurrency(money)
            'bit : boolean :: adBoolean (bit)
            'date : string :: adVarWChar (date)
            'datetimeoffset : string :: adVarWChar (datetimeoffset)
            'datetime2 : string :: adVarWChar (datetime2)
            'smalldatetime: DateTime() : adDBTimeStamp(smalldatetime)
            'datetime:   DateTime() : adDBTimeStamp(DateTime)
            'time : string :: adVarWChar (time)
            'binary:     bin.hex() : adBinary(binary)
            'varbinary:  bin.hex() : adVarBinary(varbinary)
            'image:      bin.hex() : adLongVarBinary(Image)
            'varchar : string :: adVarChar (varchar)
            'char : string :: adChar (char)
            'nvarchar : string :: adVarWChar (nvarchar)
            Select Case type
                Case "i8"
                    Return ADODB.DataTypeEnum.adBigInt
                Case "i2"
                    Return ADODB.DataTypeEnum.adSmallInt
                Case "ui1"
                    Return ADODB.DataTypeEnum.adTinyInt
                Case "int"
                    Return ADODB.DataTypeEnum.adInteger
                Case "bin.hex"
                    Return ADODB.DataTypeEnum.adVarBinary
                Case "float"
                    Return ADODB.DataTypeEnum.adDouble
                Case "r4"
                    Return ADODB.DataTypeEnum.adSingle
                Case "number"
                    Return ADODB.DataTypeEnum.adNumeric
                Case "decimal"
                    Return ADODB.DataTypeEnum.adDecimal
                Case "boolean"
                    Return ADODB.DataTypeEnum.adBoolean
                Case "dateTime"
                    'Return ADODB.DataTypeEnum.adDBTimeStamp
                    Return ADODB.DataTypeEnum.adVarChar
                Case "string", "uuid"
                    Return ADODB.DataTypeEnum.adVarChar
                Case Else
                    Return ADODB.DataTypeEnum.adIUnknown
            End Select

        End Function

        'Public Shared Function ADOTypeToScript(ByVal type As ADODB.DataTypeEnum) As String
        '    Return "'" & ADOTypeToXMLType(type) & "'"
        'End Function
        Public Shared Function ADOTypeToXMLType(ByVal type As ADODB.DataTypeEnum) As String
            'Tipo de dato SQL: tipo Dato XML : Tipo Dato ADO
            'bigint:     i8() : adBigInt(bigint)
            'smallint:   i2() : adSmallInt(smallint)
            'tinyint:    ui1() : adUnsignedTinyInt(tinyint)
            'int:        Int() : adInteger(Int)
            'timestamp:  bin.hex() : adBinary(timestamp)
            'float:      float() : adDouble(float)
            'real:       r4() : adSingle(real)
            'numeric:    number() : adNumeric(numeric)
            'decimal : number :: adNumeric (decimal)
            'smallmoney: number() : adCurrency(smallmoney)
            'money:      number() : adCurrency(money)
            'bit : boolean :: adBoolean (bit)
            'date : string :: adVarWChar (date)
            'datetimeoffset : string :: adVarWChar (datetimeoffset)
            'datetime2 : string :: adVarWChar (datetime2)
            'smalldatetime: DateTime() : adDBTimeStamp(smalldatetime)
            'datetime:   DateTime() : adDBTimeStamp(DateTime)
            'time : string :: adVarWChar (time)
            'binary:     bin.hex() : adBinary(binary)
            'varbinary:  bin.hex() : adVarBinary(varbinary)
            'image:      bin.hex() : adLongVarBinary(Image)
            'varchar : string :: adVarChar (varchar)
            'char : string :: adChar (char)
            'nvarchar : string :: adVarWChar (nvarchar)

            Select Case type
                Case ADODB.DataTypeEnum.adBigInt, ADODB.DataTypeEnum.adUnsignedBigInt
                    Return "i8"
                Case ADODB.DataTypeEnum.adSmallInt, ADODB.DataTypeEnum.adUnsignedSmallInt
                    Return "i2"
                Case ADODB.DataTypeEnum.adTinyInt, ADODB.DataTypeEnum.adUnsignedTinyInt
                    Return "ui1"
                Case ADODB.DataTypeEnum.adInteger
                    Return "int"
                Case ADODB.DataTypeEnum.adBinary, ADODB.DataTypeEnum.adVarBinary, ADODB.DataTypeEnum.adLongVarBinary
                    Return "bin.hex"
                Case ADODB.DataTypeEnum.adDouble
                    Return "float"
                Case ADODB.DataTypeEnum.adSingle
                    Return "r4"
                Case ADODB.DataTypeEnum.adNumeric, ADODB.DataTypeEnum.adCurrency
                    Return "number"
                Case ADODB.DataTypeEnum.adDecimal
                    Return "decimal"
                Case ADODB.DataTypeEnum.adBoolean
                    Return "boolean"
                Case ADODB.DataTypeEnum.adDBTimeStamp
                    Return "dateTime"

                Case ADODB.DataTypeEnum.adChar, ADODB.DataTypeEnum.adLongVarChar, ADODB.DataTypeEnum.adLongVarWChar, ADODB.DataTypeEnum.adVarChar, ADODB.DataTypeEnum.adVarWChar, ADODB.DataTypeEnum.adWChar
                    Return "string"
                Case Else
                    Return "desconocido"
            End Select

        End Function

        Public Shared Function DateDiffMilliseconds(ByVal ini As Date, ByVal fin As Date) As Double
            Dim ts As TimeSpan = fin.Subtract(ini)
            Return ts.TotalMilliseconds
        End Function

        Public Shared Function RamdomString(length As Integer, Optional ByVal especialchars As String = "") As String
            Randomize()
            Dim str As String = ""
            Dim chars As String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" & especialchars
            Dim pos As Integer
            While str.Length < length
                pos = Rnd() * (chars.Length - 1)
                str += chars.Substring(pos, 1)
            End While
            Return str
        End Function

        Public Shared Function RamdomInteger(length As Integer) As String
            Randomize()
            Dim str As String = ""
            Dim chars As String = "0123456789"
            Dim pos As Integer
            While str.Length < length
                pos = Rnd() * (chars.Length - 1)
                str += chars.Substring(pos, 1)
            End While
            Return str
        End Function


        ''' <summary>
        ''' Obtiene un ID unico basado en la fecha actual (YYYYMMDD hhmmss) más un valor random configurable
        ''' </summary>
        ''' <param name="length_rnd">El valor mínimo devulto es de 18 dígitos. Este parámetro configura el largo adicional variable sobre los 12 digitos base. El valor por defecto de length_rnd es 6, por lo tanto el largo total es de 18 caracteres.</param>
        ''' <returns></returns>
        Public Shared Function getUniqueId(Optional ByVal length_rnd As Integer = 6) As String
            Dim fecha As DateTime = Now()
            Dim extra As Byte() = {BitConverter.GetBytes(fecha.Year)(0), fecha.Month, fecha.Day, fecha.Hour, fecha.Minute, fecha.Second, BitConverter.GetBytes(_unique_id_increment)(0), BitConverter.GetBytes(_unique_id_increment)(1)}
            Dim strExtra As String = System.Convert.ToBase64String(extra)
            Dim newId As String = nvConvertUtiles.RamdomString(length_rnd) & strExtra
            _unique_id_increment += 1
            If _unique_id_increment > 32000 Then _unique_id_increment = 0

            Return newId
        End Function


        Public Shared Function BinhexToBytes2(strBinhex As String) As Byte()
            If strBinhex Is Nothing Then Return Nothing
            If strBinhex = "" Then
                Dim res(0) As Byte
                Return res
            End If
            Dim strXML As String = "<data>" & strBinhex & "</data>"
            Dim r As System.Xml.XmlTextReader = New System.Xml.XmlTextReader(New System.IO.StringReader(strXML))
            r.MoveToContent()
            Dim buffLenght As Integer = 1024
            Dim buf(buffLenght - 1) As Byte
            Dim bytesRead As Integer
            Dim ms2 As New System.IO.MemoryStream
            Do
                bytesRead = r.ReadBinHex(buf, 0, buf.Length)
                ms2.Write(buf, 0, bytesRead)
            Loop While (r.Name = "data")
            r.Close()
            Dim bytes(ms2.Length - 1) As Byte
            ms2.Position = 0
            ms2.Read(bytes, 0, ms2.Length)
            ms2.Close()
            Return bytes
        End Function

        Public Shared Function BinhexToBytes(strBinhex As String) As Byte()
            Dim res() As Byte
            Dim strReg As String = "[^1234567890ABCDEF]*"
            Dim reg As New Text.RegularExpressions.Regex(strReg, System.Text.RegularExpressions.RegexOptions.IgnoreCase)
            strBinhex = reg.Replace(strBinhex, "")
            Dim hex As String
            ReDim res(strBinhex.Length / 2 - 1)
            Dim position As Integer = 0
            Dim _byte As Byte
            While strBinhex.Length > 0
                hex = strBinhex.Substring(0, 2)
                strBinhex = strBinhex.Substring(2)
                _byte = Byte.Parse(hex, System.Globalization.NumberStyles.HexNumber, System.Globalization.CultureInfo.InvariantCulture)
                res(position) = _byte
                position += 1
            End While
            Return res
        End Function

        Public Shared Function BytesToBinhex2(bytes As Byte()) As String
            If bytes Is Nothing Then Return Nothing
            If bytes.Length = 0 Then Return ""
            Dim ms As New System.IO.MemoryStream
            Dim XmlWriterSettings As New System.Xml.XmlWriterSettings()
            XmlWriterSettings.Encoding = currentEncoding
            Dim writer As System.Xml.XmlWriter = System.Xml.XmlWriter.Create(ms, XmlWriterSettings)
            writer.WriteStartDocument()
            writer.WriteStartElement("data")
            writer.WriteBinHex(bytes, 0, bytes.Length)
            writer.WriteEndElement()
            writer.WriteEndDocument()
            writer.Close()
            ms.Position = 0
            Dim xmlBytes(ms.Length) As Byte
            ms.Read(xmlBytes, 0, ms.Length)
            Dim strXML As String = currentEncoding.GetString(xmlBytes)
            Dim oXML As New System.Xml.XmlDocument
            oXML.LoadXml(strXML)
            Return oXML.DocumentElement.ChildNodes(0).InnerText
        End Function

        Public Shared Function BytesToBinhex(bytes As Byte()) As String
            If bytes Is Nothing Then Return Nothing
            If bytes.Length = 0 Then Return ""

            Dim res As String = BitConverter.ToString(bytes)
            res = res.Replace("-", "")
            Return res
        End Function

        Public Shared Function JSScriptToObject(script As String, Optional def As Object = Nothing) As Object
            Dim res As Object = def
            Try
                'Dim j As New JScriptEval
                'Return j.Evaluate(script)
                'If _JScript_engine Is Nothing Then
                ' _JScript_engine = Microsoft.JScript.Vsa.VsaEngine.CreateEngine()
                'End If

                'res = Microsoft.JScript.Eval.JScriptEvaluate(script, _JScript_engine)

                Return nvEvaluator.jsEvaluator.Eval(script)

            Catch ex As Exception
                Return def
            End Try


        End Function

        Public Shared Function ObjectToDataType(valor As Object, type As DataTypes, Optional [default] As Object = Nothing) As Object
            If valor Is Nothing Then Return [default]

            If type = nvConvertUtiles.DataTypes.unknown Then Return valor

            Dim res As Object = [default]

            Select Case type
                Case DataTypes.boolean
                    res = If(valor.ToLower = "true", True, If(valor.ToLower = "false", False, [default]))

                Case DataTypes.date
                    Try
                        If isNUllorEmpty(valor) Then
                            res = Nothing
                        Else
                            res = Date.Parse(valor)
                        End If
                    Catch ex As Exception
                        res = [default]
                    End Try

                Case DataTypes.datetime
                    Try
                        If isNUllorEmpty(valor) Then
                            res = Nothing
                        Else
                            res = DateTime.Parse(valor)
                        End If
                    Catch ex As Exception
                        res = [default]
                    End Try

                Case DataTypes.decimal Or DataTypes.money
                    Try
                        res = System.Convert.ToDouble(valor, System.Globalization.CultureInfo.InvariantCulture) 'CDbl(valor)
                    Catch ex As Exception
                        res = [default]
                    End Try

                Case DataTypes.int
                    Try
                        res = CLng(valor)
                    Catch ex As Exception
                        res = [default]
                    End Try

                Case DataTypes.varchar, DataTypes.file
                    res = valor

            End Select

            Return res
        End Function
        Public Shared Function StringToDataType(valor As String, type As DataTypes, Optional [default] As Object = Nothing) As Object
            Return ObjectToDataType(valor, type, [default])
        End Function

        Public Shared Function JSONToDictionary(strJSON As String, Optional IgnoreCaseName As Boolean = True) As Dictionary(Of String, Object)
            ' Dezerializar el JSON a un object
            Dim serializer As New System.Web.Script.Serialization.JavaScriptSerializer
            Dim dic As Dictionary(Of String, Object) = serializer.Deserialize(Of Dictionary(Of String, Object))(strJSON)

            Dim reg As New System.Text.RegularExpressions.Regex("\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d{3}Z") '"2009-02-15T00:00:00.000Z"
            For index = 0 To dic.Keys.Count - 1
                Dim key As String = dic.Keys(index)
                If Not dic(key) Is Nothing AndAlso dic(key).GetType().ToString().ToLower() = "system.string" AndAlso reg.IsMatch(dic(key)) Then
                    Dim fecha As DateTime = DateTime.Parse(dic(key), Nothing, System.Globalization.DateTimeStyles.RoundtripKind)
                    dic(key) = fecha
                End If
            Next

            If Not IgnoreCaseName Then
                Return dic
            Else
                Return New Dictionary(Of String, Object)(dic, StringComparer.CurrentCultureIgnoreCase)
            End If

        End Function

        Public Shared Function trsParamToSQLScript(paramsArray() As trsParam) As String
            Dim SQLParams As String = ""

            For i = LBound(paramsArray) To UBound(paramsArray)
                Dim params As trsParam = paramsArray(i)
                SQLParams &= "--Parámetros bloque """ & params.name & """" & vbCrLf
                For Each param In params.Keys
                    SQLParams &= "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(params(param)) & vbCrLf
                Next
            Next

            Return SQLParams

        End Function

        Public Shared Function trsParamToSQLScript(params As trsParam) As String
            Return trsParamToSQLScript({params})
        End Function


        ''' <summary>
        ''' Valida que el tipo de datos del objeto se corresponda con el DataType de ADO
        ''' </summary>
        ''' <param name="obj"></param>
        ''' <param name="Datatype"></param>
        ''' <returns></returns>
        Public Shared Function ValidateObjectAdoType(obj As Object, Datatype As ADODB.DataTypeEnum) As Boolean
            If obj Is Nothing Then Return True

            If IsDBNull(obj) Then Return True

            Dim res As String = ""
            Dim strType As String

            If (obj.GetType().IsEnum) Then
                strType = [Enum].GetUnderlyingType(obj.GetType()).ToString().ToLower
            Else
                strType = obj.GetType().ToString().ToLower
            End If

            Dim enteros() As ADODB.DataTypeEnum = {ADODB.DataTypeEnum.adBigInt, ADODB.DataTypeEnum.adInteger, ADODB.DataTypeEnum.adSmallInt, ADODB.DataTypeEnum.adTinyInt, ADODB.DataTypeEnum.adUnsignedBigInt, ADODB.DataTypeEnum.adUnsignedInt, ADODB.DataTypeEnum.adUnsignedSmallInt, ADODB.DataTypeEnum.adUnsignedTinyInt}
            If enteros.Contains(Datatype) And Not {"system.int16", "system.int32", "system.int64", "system.byte"}.Contains(strType) Then
                Return False
            End If

            Dim decimales() As ADODB.DataTypeEnum = {ADODB.DataTypeEnum.adCurrency, ADODB.DataTypeEnum.adDecimal, ADODB.DataTypeEnum.adDouble, ADODB.DataTypeEnum.adNumeric, ADODB.DataTypeEnum.adSingle}
            If decimales.Contains(Datatype) And Not {"system.int16", "system.int32", "system.int64", "system.byte", "system.single", "system.double", "system.decimal"}.Contains(strType) Then
                Return False
            End If

            Dim cadenas() As ADODB.DataTypeEnum = {ADODB.DataTypeEnum.adChar, ADODB.DataTypeEnum.adLongVarChar, ADODB.DataTypeEnum.adLongVarWChar, ADODB.DataTypeEnum.adVarChar, ADODB.DataTypeEnum.adVarWChar, ADODB.DataTypeEnum.adWChar}
            If cadenas.Contains(Datatype) And Not {"system.string"}.Contains(strType) Then
                Return False
            End If

            Dim fechas() As ADODB.DataTypeEnum = {ADODB.DataTypeEnum.adDate, ADODB.DataTypeEnum.adDBDate, ADODB.DataTypeEnum.adDBTime, ADODB.DataTypeEnum.adDBTimeStamp}
            If fechas.Contains(Datatype) And Not {"system.datetime"}.Contains(strType) Then
                Return False
            End If

            Dim boleanos() As ADODB.DataTypeEnum = {ADODB.DataTypeEnum.adBoolean}
            If boleanos.Contains(Datatype) And Not {"system.boolean"}.Contains(strType) Then
                Return False
            End If

            Return True

        End Function

        Public Enum DataTypes
            [unknown] = -1
            [boolean] = 1
            [varchar] = 2
            [int] = 3
            [money] = 4
            [decimal] = 4
            [date] = 5
            [datetime] = 6
            [file] = 7
        End Enum

        Public Enum nvJS_format
            [js_classic] = 1
            [js_json] = 2
        End Enum

    End Class


    'Public Class jscript

    '    Private Shared _evaluator As Object
    '    Private Shared _evaluatorType As Type

    '    Private Shared ReadOnly _jscriptSource As String = _
    '    "package Evaluator " & vbCrLf & _
    '    "         {" & vbCrLf & _
    '    "     class Evaluator " & vbCrLf & _
    '    "            {" & vbCrLf & _
    '    "               public function Eval(expr : String) : Object " & vbCrLf & _
    '    "               { " & vbCrLf & _
    '    "                  return eval(expr); " & vbCrLf & _
    '    "               }" & vbCrLf & _
    '    "            }" & vbCrLf & _
    '    "         }"

    '    Shared Sub New()
    '        If _evaluator Is Nothing Then
    '            Dim compiler As ICodeCompiler
    '            compiler = (New JScriptCodeProvider()).CreateCompiler()
    '            Dim parameters As New CompilerParameters
    '            parameters.GenerateInMemory = True
    '            Dim results As CompilerResults = compiler.CompileAssemblyFromSource(parameters, _jscriptSource)
    '            Dim assembly As Reflection.Assembly = results.CompiledAssembly
    '            _evaluatorType = assembly.GetType("Evaluator.Evaluator")
    '            _evaluator = Activator.CreateInstance(_evaluatorType)
    '        End If
    '        'Return _evaluator
    '    End Sub

    '    Public Shared Function Eval(statement As String) As Object
    '        'Return _evaluatorType.InvokeMember(
    '        '         "Eval",
    '        '         System.Reflection.BindingFlags.InvokeMethod,
    '        '         Nothing,
    '        '         _evaluator,
    '        '         New Object() {statement}
    '        '      )
    '        Return _evaluator.Eval(statement)
    '    End Function

    '    Public Shared Function EvalToString(statement As String) As String
    '        Dim o = Eval(statement)
    '        Return o.ToString()
    '    End Function

    '    Public Shared Function EvalToInteger(statement As String) As Integer
    '        Dim s = EvalToString(statement)
    '        Return Integer.Parse(s)
    '    End Function

    '    Public Shared Function EvalToDouble(statement As String) As Double
    '        Dim s = EvalToString(statement)
    '        Return Double.Parse(s)
    '    End Function


    'End Class


End Namespace