<%


    Dim i As Integer
    Dim bytes() As Byte
    For i = 0 To Request.Files.Count - 1
        ReDim bytes(Request.Files(i).ContentLength - 1)
        Request.Files(i).InputStream.Read(bytes, 0, Request.Files(i).ContentLength)

        Dim fs As New System.IO.FileStream("d:\" & Request.Files(i).FileName, IO.FileMode.Create)
        fs.Write(bytes, 0, bytes.Length)
        fs.Close()
        Request.Files(i).InputStream.Close()
    Next
     %>
<HTML>
<HEAD>
<META NAME="GENERATOR" Content="Microsoft Visual Studio 6.0">
<LINK href="/fw/css/base.css" type='text/css' rel='stylesheet'/>
<TITLE></TITLE>
</HEAD>
<BODY>
    Tabla class tb1 - Tabla simple sin ajustes
<table class="tb1">
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
</table>
<br />
Tabla class tb1 highlightEven - Resalta las filas pares
<table class="tb1 highlightEven">
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
</table>

<br />
Tabla class tb1 highlightOdd - Resalta las filas impares
<table class="tb1 highlightOdd">
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
</table>

<br />
Tabla class tb1 highlightEven <b>highlightTROver</b> - Ilumina la fila seleccionada
<table class="tb1 highlightEven highlightTROver">
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
</table>

<br />
Tabla class tb1 highlightEven highlightTDOver <b>layout_fixed</b>  - Ilumina la celda seleccionada y corta los textos que execen el ancho de la celda
<table class="tb1 highlightEven highlightTDOver layout_fixed">
    <tr><td>Hola adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>Hola adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td></tr>
    <tr><td>Hola adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>Hola adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td><td>adshfkjdhfkshdfkljhdsklfjhdsklfhlkdsfhlksdfhlkdsfhlksdfhlkdsfhlkdshflkdshflkdshf</td></tr>
    
</table>
    <br />
Tabla class tb1 highlightEven - Ilumina la celda seleccionada
<table class="tb1 highlightEven highlightTDOver">
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
    <tr><td>Hola</td><td>Hola</td></tr>
</table>

<br />
Clases de filas
<table class="tb1 highlightEven ">
    <tr class="tbLabel"><td>tbLabel</td><td>-</td></tr>
    <tr class="tbLabel0"><td>tbLabel0</td><td>-</td></tr>
    <tr class="tbLabelNormal"><td>tbLabelNormal</td><td>-</td></tr>
</table>



<br />
Clases de celdas
<table class="tb1 highlightEven ">
    <tr class="tbLabel"><td class="Tit1">Clase</td><td>-</td></tr>
    <tr><td class="Tit1">Tit1</td><td>Hola</td></tr>
    <tr><td class="Tit2">Tit2</td><td>Hola</td></tr>
    <tr><td class="Tit3">Tit3</td><td>Hola</td></tr>
    <tr><td class="Tit4">Tit4</td><td>Hola</td></tr>
</table>

    <table class="tb1" style="border:solid red 1px" >
        <tr class="tbLabel"><td colspan="2">Titulo</td></tr>
        <tr><td class="Tit1" >Titulo</td><td>Hola</td></tr>
        </table>

    <form name="miForm" action="PruebaCSS_tabla.aspx" method="post"  enctype="multipart/form-data">
        <input type="file" id="archivo1" name="archivo1" />
        <input type="submit" value="Enviar" />
    </form>

</BODY>
</HTML>
