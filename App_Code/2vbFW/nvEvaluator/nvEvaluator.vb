Imports Microsoft.VisualBasic
Imports nvFW
Imports nvFW.nvUtiles
Imports nvFW.nvConvertUtiles
Imports System.CodeDom.Compiler

Imports nvFW.nvDBUtiles






Namespace nvEvaluator
    Public Class Code
        Public Shared _compiled As New Dictionary(Of String, Reflection.Assembly)
        Public Shared _assembly As New List(Of String)
        Public Shared _provider As New Dictionary(Of String, trsParam)
        Public Shared Function ejecutar(lenguaje As String, script As String, det As nvTransferencia.tTransfDet, NamespaceName As String, className As String, Optional return_code As String = "") As tError
            Dim CompilerVersion As String = ""
            Dim chkGenerateExecutable As Boolean = False
            Dim chkGenerateInMemory As Boolean = True
            Dim chkTreatWarningsAsErrors As Boolean = False
            Dim asm As Reflection.Assembly
            Dim langCompilerInfo As CompilerInfo
            Dim langCompilerConfig As CompilerParameters
            Dim OutputAssembly As String = System.IO.Path.GetTempFileName & ".dll" '= "Det_SSR_" & det.id_transf_det & ".dll"
            Dim provider As CodeDomProvider
            Dim cp As CompilerParameters

            Dim resError As New tError

            Dim code As String = getCodeObjectBase(lenguaje, script, det, NamespaceName, className, return_code)

            'Si ya fué compilado
            If Not _compiled.Keys.Contains(script & "::" & return_code) Then
                If Not _provider.ContainsKey(lenguaje) Then
                    '***********************************************
                    ' Instanciar compilador
                    '***********************************************
                    'Cargar opciones del proveedor
                    Dim provOptions As New Dictionary(Of String, String)
                    If CompilerVersion <> "" Then
                        provOptions.Add("CompilerVersion", CompilerVersion)
                    End If
                    'Recuperar el proveedor
                    If provOptions.Count > 0 Then
                        provider = CodeDomProvider.CreateProvider(lenguaje, provOptions)
                    Else
                        provider = CodeDomProvider.CreateProvider(lenguaje)
                    End If

                    '***********************************************
                    ' Cargar opciones de compilación
                    '***********************************************
                    cp = New CompilerParameters()
                    cp.GenerateExecutable = chkGenerateExecutable 'Si es tue, genera un .exe. Si es false, generará una .dll.
                    cp.OutputAssembly = OutputAssembly 'El nombre que se va a mostrar al .exe/.dll cuando es generado.
                    cp.GenerateInMemory = True ' chkGenerateInMemory 'True -> generción en memoria, False -> genera el ficho en el bin/Debug directory.
                    cp.TreatWarningsAsErrors = chkTreatWarningsAsErrors 'Establecer si queremos que todas las advertencias las tomemos como error. En este caso, false.
                    cp.WarningLevel = 3 'Evita que determinadas advertencias de compilación causen errores 
                    cp.IncludeDebugInformation = True
                    cp.TempFiles = New TempFileCollection(Environment.GetEnvironmentVariable("TEMP"), True)
                    cp.TempFiles.KeepFiles = True

                    ''Definir directorio para ensamblados dinámicos
                    'Dim dyn_assembly_path As String = AppDomain.CurrentDomain.BaseDirectory & "bin\dyn_asm"
                    'If Not System.IO.Directory.Exists(dyn_assembly_path) Then IO.Directory.CreateDirectory(dyn_assembly_path)
                    'cp.CompilerOptions = " /out:" & dyn_assembly_path & "/" & OutputAssembly & ".dll"



                    '***********************************************************
                    'Cargar los ensamblados necesarios para el nuevo componente
                    'Solo se agregan los ensamblados nativos de la solucion.
                    'Los de las carpetas "App_Code"
                    '**********************************************************
                    'Dim asm As Reflection.Assembly
                    If _assembly.Count = 0 Then
                        Dim location As String
                        For Each asm In AppDomain.CurrentDomain.GetAssemblies()
                            Try
                                location = asm.Location
                                If Not String.IsNullOrEmpty(location) And (location.IndexOf("App_SubCode_") > 0 Or location.IndexOf("ADODB") > 0 Or location.IndexOf("System.Web") > 0) Then
                                    cp.ReferencedAssemblies.Add(location)
                                    _assembly.Add(location)
                                    'System.Diagnostics.Debug.Print("Agregado: " & location)
                                End If
                            Catch ex As NotSupportedException
                                'System.Diagnostics.Debug.Print("NO Agregado: " & location)
                                'Stop
                            End Try
                        Next
                    Else
                        For Each location In _assembly
                            cp.ReferencedAssemblies.Add(location)
                        Next
                    End If
                    Dim p As New trsParam()
                    p("provider") = provider
                    p("cp") = cp
                    _provider.Add(lenguaje, p)
                Else 'El provider ya existe
                    Dim p As trsParam = _provider(lenguaje)
                    provider = p("provider")
                    cp = p("cp")
                    cp.OutputAssembly = OutputAssembly 'El nombre que se va a mostrar al .exe/.dll cuando es generado.
                    cp.TempFiles = New TempFileCollection(Environment.GetEnvironmentVariable("TEMP"), True)
                End If

                '***********************************************
                ' Compilar
                '***********************************************
                Dim cr As CompilerResults
                Try
                    cr = provider.CompileAssemblyFromSource(cp, code)
                Catch ex As Exception
                    resError.parse_error_script(ex)
                    resError.titulo = "Error al ejecutar la tarea SSR"
                    resError.mensaje = "Errores al compilar el ensamblado"
                    resError.debug_src = "nvSSRCodeEjecutar::MarshalByRefType::Ejecutar"
                    Return resError
                End Try

                If cr.Errors.Count > 0 Then
                    '***********************************************
                    ' Mostrar Errores
                    '***********************************************
                    Dim strRes As String = "Errores de compilación (" & cr.Errors.Count & ")" & vbCrLf
                    Dim ce As CompilerError
                    For Each ce In cr.Errors
                        strRes += "    " & ce.ToString() & " filename: '" & ce.FileName & "'" & "Linea: " & ce.Line & " columna: " & ce.Column & vbCrLf
                    Next
                    resError = New tError
                    resError.numError = 456
                    resError.titulo = "Error al ejecutar la tarea SSR"
                    resError.mensaje = "Errores en la compilación"
                    resError.debug_desc = strRes
                    resError.debug_src = "nvSSRCodeEjecutar::MarshalByRefType::Ejecutar"
                    Return resError
                Else
                    asm = cr.CompiledAssembly
                    _compiled.Add(script & "::" & return_code, asm)
                End If
            Else
                asm = _compiled(script & "::" & return_code) 'Tomar el ensamblado guardado
            End If


            ''Crear dDominio de aplicacion
            'Dim domain As AppDomain = AppDomain.CreateDomain("MyDomain")
            'Try

            '    Dim objClaseUnWrap As Object
            '    objClaseUnWrap = domain.CreateInstanceFrom(asm.Location, NamespaceName & "." & className)
            '    objClaseUnWrap = domain.CreateInstanceFromAndUnwrap(asm.Location, NamespaceName & "." & className)
            '    objClaseUnWrap.Det = det
            '    objClaseUnWrap.Transf = det.Transf
            '    objClaseUnWrap.ejecutar()
            '    resError = New tError
            'Catch ex As Exception
            '    resError = New tError
            '    resError.parse_error_script(ex)
            '    resError.titulo = "Error al ejecutar la tarea SSR"
            '    resError.mensaje = "Errores en la ejecución"
            '    resError.debug_src = "nvSSRCodeEjecutar::MarshalByRefType::Ejecutar"
            'End Try
            'AppDomain.Unload(domain)

            'Descargar Dominio de aplicacion
            Dim objClase As Object

            Try
                objClase = asm.CreateInstance(asm.ExportedTypes(asm.ExportedTypes.Count - 1).FullName, False, Reflection.BindingFlags.CreateInstance, Nothing, Nothing, Nothing, Nothing)
                objClase.Det = det
                objClase.Transf = det.Transf
                'IO.File.WriteAllBytes("d:\\code_base.vb", System.Text.Encoding.Unicode.GetBytes(code))
                Dim return_value As Object = objClase.ejecutar()
                resError = New tError
                resError.params("return_value") = IIf(IsDBNull(return_value), Nothing, return_value)
            Catch ex As Exception
                resError = New tError
                resError.parse_error_script(ex)
                resError.titulo = "Error al ejecutar la tarea SSR"
                resError.mensaje = "Errores en la ejecución"
                resError.debug_src = "nvSSRCodeEjecutar::MarshalByRefType::Ejecutar"
            End Try

            Return resError

        End Function

        Public Shared Function getCodeObjectBase(lenguaje As String, code As String, det As nvTransferencia.tTransfDet, NamespaceName As String, className As String, Optional return_code As String = "") As String
            Dim res As String = ""
            Select Case lenguaje.ToLower
                Case "vb", "visualbasic"

                    'Dim path As String = "D:\Dropbox\desarrollo\Prueba compilación dinámica\Prueba compilación dinámica\pruebaClase.vb"
                    'Dim t As New System.IO.StreamReader(path)
                    'res = t.ReadToEnd()
                    If return_code = "" Then
                        return_code = "Return Nothing"
                    Else
                        return_code = "Return " & return_code
                    End If
                    res = "Option Explicit On" & vbCrLf &
                           "Imports nvFW" & vbCrLf &
                           "Imports System" & vbCrLf &
                           "Imports Microsoft.VisualBasic" & vbCrLf &
                           "Imports nvFW.nvTransferencia" & vbCrLf &
                           "Imports nvEvaluator" & vbCrLf &
                           "" & vbCrLf &
                           "Namespace %namespace%" & vbCrLf &
                           "    Public Class %class%" & vbCrLf &
                           "        Inherits System.MarshalByRefObject" & vbCrLf &
                           "        Public Transf As nvFW.nvTransferencia.tTransfererncia" & vbCrLf &
                           "        Public Det As nvFW.nvTransferencia.tTransfDet" & vbCrLf &
                           "" & vbCrLf &
                           "        Public Function ejecutar() as Object" & vbCrLf &
                           "            Dim err As New tError" & vbCrLf &
                           "" & vbCrLf &
                           "            Dim code As String = """"" & vbCrLf &
                           "" & vbCrLf &
                           "            %return_code%" & vbCrLf &
                           "        End Function" & vbCrLf &
                           "    End Class" & vbCrLf &
                           "End Namespace" & vbCrLf

                    '****************************
                    'Definir property
                    '****************************
                    Dim strProperty As New System.Text.StringBuilder
                    strProperty.AppendLine("Public Det As nvFW.nvTransferencia.tTransfDet")
                    For Each param In det.Transf.param
                        strProperty.AppendLine("Public Property [" & param.Key & "] As " & paramTypeToNetType(param.Value("tipo_dato")) & "")
                        strProperty.AppendLine("  Get")
                        strProperty.AppendLine("    Return Transf.param(""" & param.Key & """)(""valor"")")
                        strProperty.AppendLine("  End Get")
                        strProperty.AppendLine("  Set(value As " & paramTypeToNetType(param.Value("tipo_dato")) & ")")
                        strProperty.AppendLine("    Transf.param(""" & param.Key & """)(""valor"") = value")
                        strProperty.AppendLine("  End Set")
                        strProperty.AppendLine("End Property")
                        strProperty.AppendLine(" ")
                    Next

                    res = res.Replace("Public Det As nvFW.nvTransferencia.tTransfDet", strProperty.ToString())
                    res = res.Replace("Dim code As String = """"", code)

                Case "js", "javascript", "jscript"

                    'Dim path As String = "D:\Dropbox\desarrollo\Prueba compilación dinámica\Prueba compilación dinámica\Class1.js"
                    'Dim t As New System.IO.StreamReader(path)
                    'res = t.ReadToEnd()
                    If return_code = "" Then
                        return_code = "return null;"
                    Else
                        return_code = "return " & return_code & ";"
                    End If
                    res = "import nvFW;" & vbCrLf &
                          "import System;" & vbCrLf &
                          "import nvFW.nvTransferencia;" & vbCrLf &
                          "import nvEvaluator;" & vbCrLf &
                          "" & vbCrLf &
                          "package %namespace%" & vbCrLf &
                          "  {" & vbCrLf &
                          "	 class %class%" & vbCrLf &
                          "      {" & vbCrLf &
                          "      var Transf : nvFW.nvTransferencia.tTransfererncia;" & vbCrLf &
                          "      var Det : nvFW.nvTransferencia.tTransfDet;" & vbCrLf &
                          "" & vbCrLf &
                          "      function ejecutar() " & vbCrLf &
                          "         {" & vbCrLf &
                          "	     var code : string" & vbCrLf &
                          "	     %return_code%" & vbCrLf &
                          "         }" & vbCrLf &
                          "      }" & vbCrLf &
                          "  }" & vbCrLf

                    '****************************
                    'Definir property
                    '****************************
                    Dim strProperty As New System.Text.StringBuilder
                    strProperty.AppendLine("var Det : nvFW.nvTransferencia.tTransfDet;")
                    For Each param In det.Transf.param
                        strProperty.AppendLine("function get " & param.Key & "() : " & paramTypeToNetType(param.Value("tipo_dato")) & "")
                        strProperty.AppendLine("  {")
                        strProperty.AppendLine("  return Transf.param(""" & param.Key & """)(""valor"");")
                        strProperty.AppendLine("  }")
                        strProperty.AppendLine("")
                        strProperty.AppendLine("function set " & param.Key & "(value : " & paramTypeToNetType(param.Value("tipo_dato")) & ")")
                        strProperty.AppendLine("  {")
                        strProperty.AppendLine("  Transf.param(""" & param.Key & """)(""valor"") = value")
                        strProperty.AppendLine("  }")
                    Next

                    res = res.Replace("var Det : nvFW.nvTransferencia.tTransfDet;", strProperty.ToString())
                    res = res.Replace("var code : string", code)

                Case "c#", "cs", "csharp"

                    'Dim path As String = "D:\Dropbox\desarrollo\Prueba compilación dinámica\Prueba compilación dinámica\Class1.js"
                    'Dim t As New System.IO.StreamReader(path)
                    'res = t.ReadToEnd()
                    If return_code = "" Then
                        return_code = "return null;"
                    Else
                        return_code = "return " & return_code & ";"
                    End If
                    res = "using nvFW;" & vbCrLf &
                          "using System;" & vbCrLf &
                          "using nvFW.nvTransferencia;" & vbCrLf &
                          "using nvEvaluator;" & vbCrLf &
                          "" & vbCrLf &
                          "namespace %namespace%" & vbCrLf &
                          "{" & vbCrLf &
                          "    public class %class%" & vbCrLf &
                          "    {" & vbCrLf &
                          "        public nvFW.nvTransferencia.tTransfererncia Transf;" & vbCrLf &
                          "        public nvFW.nvTransferencia.tTransfDet Det;" & vbCrLf &
                          "" & vbCrLf &
                          "        public object ejecutar()" & vbCrLf &
                          "        {" & vbCrLf &
                          "            string code = "";" & vbCrLf &
                          "            %return_code%" & vbCrLf &
                          "        }" & vbCrLf &
                          "    }" & vbCrLf &
                          "}" & vbCrLf

                    '****************************
                    'Definir property
                    '****************************
                    Dim strProperty As New System.Text.StringBuilder
                    strProperty.AppendLine("public nvFW.nvTransferencia.tTransfDet Det;")
                    For Each param In det.Transf.param
                        strProperty.AppendLine("public " & paramTypeToNetType(param.Value("tipo_dato")) & " " & param.Key & "")
                        strProperty.AppendLine("  {")
                        strProperty.AppendLine("  get { return (" & paramTypeToNetType(param.Value("tipo_dato")) & ")Transf.param[""" & param.Key & """][""valor""]; }")
                        strProperty.AppendLine("  set { Transf.param[""" & param.Key & """][""valor""] = value; }")
                        strProperty.AppendLine("  }")
                    Next

                    res = res.Replace("public nvFW.nvTransferencia.tTransfDet Det;", strProperty.ToString())
                    res = res.Replace("string code = "";", code)
            End Select

            res = res.Replace("%namespace%", NamespaceName)
            res = res.Replace("%class%", className)
            res = res.Replace("%return_code%", return_code)

            Return res
        End Function

        Public Shared Function paramTypeToNetType(paramType As String) As String
            Select Case paramType.ToLower
                Case "int"
                    Return "System.Int32"
                Case "varchar"
                    Return "System.String"
                Case "datetime"
                    Return "System.DateTime"
                Case "money"
                    Return "System.Decimal"
                Case "boolean", "bit"
                    Return "System.Boolean"
                Case Else
                    Return "System.String"
            End Select

            Return "System.String"
        End Function
    End Class





End Namespace

