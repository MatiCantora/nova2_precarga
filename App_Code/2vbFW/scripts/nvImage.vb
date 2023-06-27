Imports System.Drawing
Imports Microsoft.VisualBasic
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles


Namespace nvFW
    Public Class nvImage

        Public Shared Function getThumb(img As Image, strech As Boolean, width As Integer, Optional height As Integer = 0) As Image
            Dim thumb As Image = resize(img, width, height, strech)
            Return thumb
        End Function

        Public Shared Function getThumb(img_bytes As Byte(), strech As Boolean, width As Integer, Optional height As Integer = 0) As Image
            Dim ms As New System.IO.MemoryStream
            ms.Write(img_bytes, 0, img_bytes.Length)
            ms.Position = 0
            Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
            Dim thumb As Image = resize(img, width, height, strech)
            img.Dispose()
            ms.Close()
            Return thumb
        End Function
        Public Shared Function getThumb(filename As String, strech As Boolean, width As Integer, Optional height As Integer = 0) As Image
            Dim img As System.Drawing.Image = System.Drawing.Image.FromFile(filename)
            Dim thumb As Image = resize(img, width, height, strech)
            img.Dispose()
            Return thumb
        End Function
        Public Shared Function getThumbBinary(img As Image, strech As Boolean, width As Integer, Optional height As Integer = 0, Optional quality As Integer = 60) As Byte()
            Dim thumb As Image = resize(img, width, height, strech)
            Dim thumbBytes As Byte() = ConvertToJpgBytes(thumb, quality)
            Return thumbBytes
        End Function
        Public Shared Function getThumbBinary(img_bytes As Byte(), strech As Boolean, width As Integer, Optional height As Integer = 0, Optional quality As Integer = 60) As Byte()
            Dim ms As New System.IO.MemoryStream
            ms.Write(img_bytes, 0, img_bytes.Length)
            ms.Position = 0
            Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(ms)
            Dim thumbBytes() As Byte = getThumbBinary(img, strech, width, height, quality)
            img.Dispose()
            ms.Close()
            Return thumbBytes
        End Function
        Public Shared Function getThumbBinary(filename As String, strech As Boolean, width As Integer, Optional height As Integer = 0, Optional quality As Integer = 60) As Byte()
            Dim img As System.Drawing.Image = System.Drawing.Image.FromFile(filename)
            Dim thumbBytes() As Byte = getThumbBinary(img, strech, width, height, quality)
            img.Dispose()
            Return thumbBytes
        End Function

        Public Shared Function resize(ByVal src_img As System.IO.MemoryStream, ByRef width As Integer, ByRef height As Integer, Optional strech As Boolean = True, Optional noResizeIfSmall As Boolean = False) As System.IO.MemoryStream
            Dim img As System.Drawing.Image = System.Drawing.Image.FromStream(src_img)
            Dim img_out As System.Drawing.Image = resize(img, width, height, strech, noResizeIfSmall)
            Dim img_return As System.IO.MemoryStream = New System.IO.MemoryStream
            img_out.Save(img_return, Imaging.ImageFormat.Jpeg)
            Return img_return
        End Function
        Public Shared Function resize(ByVal src_img As Image, ByRef width As Integer, ByRef height As Integer, Optional strech As Boolean = True, Optional noResizeIfSmall As Boolean = False) As Image
            Dim bm_source As New Bitmap(src_img)
            Dim aspectratio As Single = bm_source.Width / bm_source.Height
            If Not strech Then

                If width / aspectratio < height OrElse height = 0 Then
                    height = width / aspectratio
                Else
                    width = height * aspectratio
                End If
            End If
            Dim bm_dest As New Bitmap(width, height)
            Dim gr_dest As Graphics = Graphics.FromImage(bm_dest)
            gr_dest.DrawImage(bm_source, 0, 0, bm_dest.Width + 1, bm_dest.Height + 1)
            bm_source.Dispose()
            gr_dest.Dispose()
            Return bm_dest
        End Function

        Public Shared Function GetEncoder(ByVal format As System.Drawing.Imaging.ImageFormat) As System.Drawing.Imaging.ImageCodecInfo

            Dim codecs() As System.Drawing.Imaging.ImageCodecInfo = System.Drawing.Imaging.ImageCodecInfo.GetImageDecoders()
            For Each codec As System.Drawing.Imaging.ImageCodecInfo In codecs
                If codec.FormatID = format.Guid Then
                    Return codec
                End If
            Next
            Return Nothing
        End Function


        Public Shared Function ConvertToJpgBytes(ByVal image As System.Drawing.Image, ByVal compressionLevel As Long) As Byte()
            If compressionLevel < 0 Then compressionLevel = 0
            If compressionLevel > 100 Then compressionLevel = 100

            Dim jgpEncoder As System.Drawing.Imaging.ImageCodecInfo = GetEncoder(System.Drawing.Imaging.ImageFormat.Jpeg)
            Dim myEncoder As System.Drawing.Imaging.Encoder = System.Drawing.Imaging.Encoder.Quality
            Dim myEncoderParameters As System.Drawing.Imaging.EncoderParameters = New System.Drawing.Imaging.EncoderParameters(1)
            Dim myEncoderParameter As System.Drawing.Imaging.EncoderParameter = New System.Drawing.Imaging.EncoderParameter(myEncoder, compressionLevel)
            myEncoderParameters.Param(0) = myEncoderParameter

            Using ms As System.IO.MemoryStream = New System.IO.MemoryStream()
                image.Save(ms, jgpEncoder, myEncoderParameters)
                Return ms.ToArray()
            End Using
        End Function

        Public Shared Function RotateImageBitMap(ByVal bmpSrc As Bitmap, ByVal theta As Single) As Bitmap
            Dim mRotate As Drawing2D.Matrix = New Drawing2D.Matrix()
            mRotate.Translate(bmpSrc.Width / -2, bmpSrc.Height / -2, Drawing2D.MatrixOrder.Append)
            mRotate.RotateAt(theta, New Point(0, 0), Drawing2D.MatrixOrder.Append)

            Using gp As Drawing2D.GraphicsPath = New Drawing2D.GraphicsPath()
                gp.AddPolygon(New Point() {New Point(0, 0), New Point(bmpSrc.Width, 0), New Point(0, bmpSrc.Height)})
                gp.Transform(mRotate)
                Dim pts As PointF() = gp.PathPoints
                Dim bbox As Rectangle = RectangleboundingBox(bmpSrc, mRotate)
                Dim bmpDest As Bitmap = New Bitmap(bbox.Width, bbox.Height)

                Using gDest As Graphics = Graphics.FromImage(bmpDest)
                    Dim mDest As Drawing2D.Matrix = New Drawing2D.Matrix()
                    mDest.Translate(bmpDest.Width / 2, bmpDest.Height / 2, Drawing2D.MatrixOrder.Append)
                    gDest.Transform = mDest
                    gDest.DrawImage(bmpSrc, pts)
                    Return bmpDest
                End Using
            End Using
        End Function

        Public Shared Function RotateImage(img As Image, ByRef Angle As Double) As IO.MemoryStream

            Dim image_output As IO.MemoryStream = Nothing

            Dim retBMP As New Bitmap(img)
            'retBMP.SetResolution(img.HorizontalResolution, img.VerticalResolution)

            image_output = New IO.MemoryStream()

            retBMP = RotateImageBitMap(retBMP, Angle)

            retBMP.Save(image_output, Imaging.ImageFormat.Jpeg)

            retBMP.Dispose()

            Return image_output
        End Function

        Private Shared Function RectangleboundingBox(ByVal img As Bitmap, ByVal matrix As Drawing2D.Matrix) As Rectangle
            Dim gu As GraphicsUnit = New GraphicsUnit()
            Dim rImg As Rectangle = Rectangle.Round(img.GetBounds(gu))
            Dim topLeft As Point = New Point(rImg.Left, rImg.Top)
            Dim topRight As Point = New Point(rImg.Right, rImg.Top)
            Dim bottomRight As Point = New Point(rImg.Right, rImg.Bottom)
            Dim bottomLeft As Point = New Point(rImg.Left, rImg.Bottom)
            Dim points As Point() = New Point() {topLeft, topRight, bottomRight, bottomLeft}
            Dim gp As Drawing2D.GraphicsPath = New Drawing2D.GraphicsPath(points, New Byte() {CByte(Drawing2D.PathPointType.Start), CByte(Drawing2D.PathPointType.Line), CByte(Drawing2D.PathPointType.Line), CByte(Drawing2D.PathPointType.Line)})
            gp.Transform(matrix)
            Return Rectangle.Round(gp.GetBounds())
        End Function

        Public Shared Sub removeMetadata(ByRef image As IO.MemoryStream)

            Dim image_bitmap As Drawing.Bitmap = Drawing.Image.FromStream(image)
            Dim image_clon As Drawing.Bitmap = New Drawing.Bitmap(image_bitmap.Width, image_bitmap.Height)
            Dim graphic As Drawing.Graphics = Drawing.Graphics.FromImage(image_clon)
            graphic.DrawImage(image_bitmap, New Drawing.Rectangle(0, 0, image_bitmap.Width, image_bitmap.Height), New Drawing.Rectangle(0, 0, image_bitmap.Width, image_bitmap.Height), Drawing.GraphicsUnit.Pixel)

            image = New IO.MemoryStream()
            image_clon.Save(image, Drawing.Imaging.ImageFormat.Jpeg)
            image_bitmap.Dispose()
            image_clon.Dispose()
        End Sub

    End Class

End Namespace