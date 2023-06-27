Imports System.IO
Imports System.Reflection



Namespace nvFW
    Public Class nvPDF
        Private _numError As Integer = 0
        Private _descError As String = ""
        Private iTextKernel As Assembly
        Private iTextIO As Assembly
        Private rootpathapp As String = nvServer.appl_physical_path.Replace("/", "\")

        Private Sub load()
            iTextKernel = Assembly.LoadFrom(rootpathapp & "Bin\itext7\itext.kernel.dll")
            iTextIO = Assembly.LoadFrom(rootpathapp & "Bin\itext7\itext.io.dll")
        End Sub
        Public Sub New()
            load()
        End Sub

        Public Shared Function HtmlStringToPdf(ByVal htmlstr As String) As Byte()
            Dim Converter As SelectPdf.HtmlToPdf = New SelectPdf.HtmlToPdf
            Dim doc As SelectPdf.PdfDocument = Converter.ConvertHtmlString(htmlstr)
            Dim binaryData() As Byte = doc.Save()
            doc.Close()
            Return binaryData
        End Function


        ''listado de bites de archivos, FullCompressionMode: si comprime el pdf final o no
        Public Function Concat(ByVal listFiles As List(Of Byte()), Optional ByVal FullCompressionMode As Boolean = True) As Byte()
            _numError = -1
            _descError = "sin concatenar"

            Dim docbytes() As Byte = Nothing
            Try
                If (listFiles.Count > 0) Then

                    ''creo la instancia al constructor del objeto WriterProperties (para pasarle por parametros al constructor iText.Kernel.Pdf.PdfWriter) 
                    Dim instanciaWriterProperties As Type = iTextKernel.GetType("iText.Kernel.Pdf.WriterProperties")
                    Dim WriterProperties As Object = Activator.CreateInstance(instanciaWriterProperties)
                    WriterProperties.SetFullCompressionMode(FullCompressionMode)

                    ''creo la instancia al constructor del objeto PdfWriter (que necesita un parametro al invocarse de tipo MemoryStream) 
                    Dim instanciaPdfWriter As Type = iTextKernel.GetType("iText.Kernel.Pdf.PdfWriter")
                    Dim ms As New MemoryStream
                    Dim paramwriter(1) As Object
                    paramwriter(0) = ms
                    paramwriter(1) = WriterProperties
                    Dim writer As Object = Activator.CreateInstance(instanciaPdfWriter, paramwriter)
                    writer.SetSmartMode(True)

                    ''creo la instancia al constructor del objeto PdfDocument(que necesita un parametro al invocarse de tipo iText.Kernel.Pdf.PdfWriter) 
                    Dim instanciaPdfDocument As Type = iTextKernel.GetType("iText.Kernel.Pdf.PdfDocument")
                    Dim paramPdfDocument(0) As Object
                    paramPdfDocument(0) = writer
                    Dim pdfDoc As Object = Activator.CreateInstance(instanciaPdfDocument, paramPdfDocument)
                    'pdfDoc.InitializeOutlines()

                    ''creo la instancia al constructor del objeto PdfReader (que necesita un parametro al invocarse de tipo System.IO.Stream) 
                    Dim instanciaPdfReader As Type = iTextKernel.GetType("iText.Kernel.Pdf.PdfReader")
                    For Each file In listFiles

                        Dim FileStream As System.IO.Stream = New System.IO.MemoryStream(file)
                        Dim paramreader(0) As Object
                        paramreader(0) = FileStream
                        Dim paramsdoc2(0) As Object
                        Dim Pdfreader = Activator.CreateInstance(instanciaPdfReader, paramreader) '' PdfReader(FileStream)
                        Pdfreader.SetUnethicalReading(True) ''para autenticar usuario que ejecuta la accion de leer el archivo 
                        paramsdoc2(0) = Pdfreader
                        Dim addedDoc As Object = Activator.CreateInstance(instanciaPdfDocument, paramsdoc2)
                        addedDoc.CopyPagesTo(1, addedDoc.GetNumberOfPages(), pdfDoc)
                        addedDoc.Close()
                        FileStream.Close()
                        FileStream = Nothing
                    Next
                    pdfDoc.Close()
                    pdfDoc = Nothing
                    writer.Close()

                    docbytes = ms.ToArray()
                    ms.Close()
                    ms = Nothing
                    listFiles = Nothing
                    _numError = 0
                    _descError = ""
                End If

            Catch ex As Exception
                Me._numError = 1
                Me._descError = ex.Message & " - traza " & ex.StackTrace()
            End Try
            Return docbytes
        End Function
        Public Function Concat(ByVal listFiles As List(Of String), Optional ByVal FullCompressionMode As Boolean = True) As Byte()
            Dim docbytes() As Byte = Nothing
            Dim listFilesBytes As List(Of Byte()) = New List(Of Byte())
            For Each file In listFiles
                Dim bytefile As Byte() = System.IO.File.ReadAllBytes(file)
                listFilesBytes.Add(bytefile)
            Next
            docbytes = Concat(listFilesBytes, FullCompressionMode)
            listFilesBytes = Nothing
            Return docbytes
        End Function

        Public Property descError() As String
            Get
                Return Me._descError
            End Get
            Set(ByVal value As String)

            End Set
        End Property

        Public Property numError() As Integer
            Get
                Return Me._numError
            End Get
            Set(ByVal value As Integer)

            End Set
        End Property

        Public Function ImageToPDF(ByVal bytes() As Byte, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150, Optional ByVal FullCompressionMode As Boolean = True) As Byte()
            Dim ms As New IO.MemoryStream(bytes) 'This is correct...
            Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
            Return ImageToPDF(img, image_compresion, image_dpi, FullCompressionMode)
        End Function
        Public Function ImageToPDF(ByVal path_archivo As String, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150, Optional ByVal FullCompressionMode As Boolean = True) As Byte()
            Dim img = New System.Drawing.Bitmap(path_archivo)
            Return ImageToPDF(img, image_compresion, image_dpi, FullCompressionMode)
        End Function

        Public Function ImageToPDF(ByVal img As System.Drawing.Bitmap, Optional ByVal image_compresion As Integer = 85, Optional ByVal image_dpi As Integer = 150, Optional ByVal FullCompressionMode As Boolean = True) As Byte()
            ''creo la instancia de las PAges que voy a usar
            Dim iPageSize As Type = iTextKernel.GetType("iText.Kernel.Geom.PageSize")
            Dim PageSizeA4 As Object = iPageSize.GetField("A4").GetValue(Nothing) '' inv.Invoke(Nothing, New Object() {}) '' PageSize.A4  ''Activator.CreateInstance(iPageSizeA4)
            ''Dim iPageSizeLEGAL As Type = iTextKernel.GetType("iText.Kernel.Geom.PageSize.LEGAL")
            Dim PageSizeLEGAL As Object = iPageSize.GetField("LEGAL").GetValue(Nothing) 'iPageSize.GetField("LEGAL") ''PageSize.LEGAL ''Activator.CreateInstance(iPageSizeLEGAL)

            ''creo la instancia al constructor del objeto PdfDocument(que necesita un parametro al invocarse de tipo iText.Kernel.Pdf.PdfWriter) 
            Dim instanciaRectangle As Type = iTextKernel.GetType("iText.Kernel.Geom.Rectangle")
            Dim paramRectangle(1) As Object
            paramRectangle(0) = PageSizeA4.GetHeight()
            paramRectangle(1) = PageSizeA4.GetWidth()
            Dim Rectangle_A4_LANDSCAPE As Object = Activator.CreateInstance(instanciaRectangle, paramRectangle)

            paramRectangle(0) = PageSizeA4.GetWidth()
            paramRectangle(1) = PageSizeA4.GetHeight()
            Dim Rectangle_A4 As Object = Activator.CreateInstance(instanciaRectangle, paramRectangle)

            paramRectangle(0) = PageSizeLEGAL.GetWidth()
            paramRectangle(1) = PageSizeLEGAL.GetHeight()
            Dim Rectangle_LEGAL As Object = Activator.CreateInstance(instanciaRectangle, paramRectangle)

            paramRectangle(0) = PageSizeLEGAL.GetHeight()
            paramRectangle(1) = PageSizeLEGAL.GetWidth()
            Dim Rectangle_LEGAL_LANDSCAPE As Object = Activator.CreateInstance(instanciaRectangle, paramRectangle)


            Dim img_ratio As Single = img.Width / img.Height
            Dim pageSizes As New Dictionary(Of String, Object)
            pageSizes.Add("A4", Rectangle_A4)
            pageSizes.Add("A4_LANDSCAPE", Rectangle_A4_LANDSCAPE)
            pageSizes.Add("LEGAL", Rectangle_LEGAL)
            pageSizes.Add("LEGAL_LANDSCAPE", Rectangle_LEGAL_LANDSCAPE)

            Dim selected_pageSize = pageSizes.Item("A4")
            Dim min_dif As Single = 20

            For Each p As Object In pageSizes.Values
                If Math.Abs((p.GetWidth() / p.GetHeight()) - img_ratio) < min_dif Then
                    selected_pageSize = p
                    min_dif = Math.Abs((p.GetWidth() / p.GetHeight()) - img_ratio)
                End If
            Next

            If image_compresion = 0 Then image_compresion = 85
            Dim bmp As System.Drawing.Bitmap = New System.Drawing.Bitmap(img)
            If image_dpi = 0 Then image_dpi = 150

            ''creo la instancia al constructor del objeto WriterProperties (para pasarle por parametros al constructor iText.Kernel.Pdf.PdfWriter) 
            Dim instanciaWriterProperties As Type = iTextKernel.GetType("iText.Kernel.Pdf.WriterProperties")
            Dim WriterProperties As Object = Activator.CreateInstance(instanciaWriterProperties)
            WriterProperties.SetFullCompressionMode(FullCompressionMode)

            ''creo la instancia al constructor del objeto PdfWriter (que necesita un parametro al invocarse de tipo MemoryStream) 
            Dim instanciaPdfWriter As Type = iTextKernel.GetType("iText.Kernel.Pdf.PdfWriter")
            Dim ms As New MemoryStream
            Dim paramwriter(1) As Object
            paramwriter(0) = ms
            paramwriter(1) = WriterProperties
            Dim writer As Object = Activator.CreateInstance(instanciaPdfWriter, paramwriter)
            writer.SetSmartMode(True)

            ''creo la instancia al constructor del objeto PdfDocument(que necesita un parametro al invocarse de tipo iText.Kernel.Pdf.PdfWriter) 
            Dim instanciaPdfDocument As Type = iTextKernel.GetType("iText.Kernel.Pdf.PdfDocument")
            Dim paramPdfDocument(0) As Object
            paramPdfDocument(0) = writer
            Dim pdfDoc As Object = Activator.CreateInstance(instanciaPdfDocument, paramPdfDocument)
            pdfDoc.InitializeOutlines()

            Dim instanciaPageSize As Type = iTextKernel.GetType("iText.Kernel.Geom.PageSize")
            Dim paramPageSize(0) As Object
            paramPageSize(0) = selected_pageSize
            Dim page_size As Object = Activator.CreateInstance(instanciaPageSize, paramPageSize)

            ''Dim page_size As New iText.Kernel.Geom.PageSize(selected_pageSize)

            Dim newpage = pdfDoc.AddNewPage(page_size)
            Dim new_width As Integer
            Dim new_height As Integer
            Dim new_rect_page = newpage.GetPageSize()
            Dim page_aratio As Single = new_rect_page.GetWidth / new_rect_page.GetHeight
            Dim image_aratio As Single = bmp.Width / bmp.Height
            'Controla el aspect ratio para ver como se debe escalar
            'Si la imagen es mas grande que la hoja la achica, sino la deja del tamaño actual
            If page_aratio < image_aratio Then
                If new_rect_page.GetWidth < bmp.Width Then
                    new_width = (new_rect_page.GetWidth / 72) * image_dpi
                Else
                    new_width = bmp.Width
                End If
                new_height = new_width / image_aratio
            Else
                If new_rect_page.GetHeight < bmp.Height Then
                    new_height = (new_rect_page.GetHeight / 72) * image_dpi
                Else
                    new_height = bmp.Height
                End If
                new_width = new_height * image_aratio
            End If

            Dim bmp1 = nvImage.resize(bmp, new_width, new_height, strech:=True, noResizeIfSmall:=True)
            Dim bytes As Byte() = nvImage.ConvertToJpgBytes(bmp1, image_compresion)
            bmp.Dispose()
            bmp1.Dispose()


            ''creo la instancia al constructor del objeto ImageDataFactory(que necesita un parametro al invocarse de tipo bytes) 
            Dim iImageDataFactory As Type = iTextIO.GetType("iText.IO.Image.ImageDataFactory")
            Dim paramImageDataFactory(0) As Object
            paramImageDataFactory(0) = bytes
            Dim fxCreate As Object = iImageDataFactory.GetMethods()(1) ''obtengo el metodo create ''iImageDataFactory.GetMethod("Create")
            Dim imageData = fxCreate.Invoke(Nothing, paramImageDataFactory)
            ''Dim ImageDataFactory As Object = Activator.CreateInstance(iImageDataFactory, paramImageDataFactory)
            ''Dim imageData As Object = ImageDataFactory.Create(bytes)

            ''creo la instancia al constructor del objeto PdfCanvas (parametros contentStream As PdfStream, resources As PdfResources, document As PdfDocument) 
            Dim iPdfCanvas As Type = iTextKernel.GetType("iText.Kernel.Pdf.Canvas.PdfCanvas")

            Dim parampdfcanvas(2) As Object
            parampdfcanvas(0) = newpage.NewContentStreamAfter()
            parampdfcanvas(1) = newpage.GetResources()
            parampdfcanvas(2) = pdfDoc
            Dim cnv As Object = Activator.CreateInstance(iPdfCanvas, parampdfcanvas)




            Dim iPdfRectangle As Type = iTextKernel.GetType("iText.Kernel.Geom.Rectangle")
            Dim parampdfrect(3) As Object
            parampdfrect(0) = 0
            parampdfrect(1) = 0

            Dim Wpage As Single = new_rect_page.GetWidth()
            Dim HPage As Single = CInt(new_rect_page.GetWidth() / img_ratio)
            If (HPage > new_rect_page.GetHeight()) Then
                HPage = new_rect_page.GetHeight()
                Wpage = HPage * img_ratio
            End If
            If (Wpage > new_rect_page.GetWidth()) Then
                Wpage = new_rect_page.GetWidth()
                HPage = CInt(new_rect_page.GetWidth() / img_ratio)
            End If

            parampdfrect(2) = Wpage
            parampdfrect(3) = HPage
            Dim rectangle As Object = Activator.CreateInstance(iPdfRectangle, parampdfrect)

            cnv.AddImage(imageData, rectangle, False)
            ''Dim cnv As New PdfCanvas(newpage.NewContentStreamAfter(), newpage.GetResources(), pdfDoc)
            'cnv.AddImage(imageData, 0, 0, new_rect_page.GetHeight(), True, False)

            'cnv.AddImage(imageData, 0, 0, new_rect_page.GetHeight(), False, False)
            'cnv.AddImage(imageData, 0, 0, new_rect_page.GetWidth(), True)
            'cnv.AddImage(imageData, 0, 0)
            pdfDoc.Close()
            pdfDoc = Nothing
            writer.Close()
            Return ms.ToArray()
        End Function
    End Class






End Namespace