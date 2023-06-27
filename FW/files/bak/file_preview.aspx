<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%
    Dim f_id As String = nvFW.nvUtiles.obtenerValor("f_id", "0")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")
    Dim width As String = nvFW.nvUtiles.obtenerValor("width", "300")
    Dim height As String = nvFW.nvUtiles.obtenerValor("height", "300")
    Dim file As nvFW.nvFile.tnvFile = nvFW.nvFile.getFile(f_id:=f_id, ref_files_path:=ref_files_path)
    If file Is Nothing Then
        Dim err As New tError
        err.numError = 12
        err.titulo = "Error al previsualizar el archivo"
        err.mensaje = "El archivo no existe o no tiene permisos para su visalización"
        err.salida_tipo = "HTML"
        err.mostrar_error()
    End If

    Dim f As New trsParam
    f.Add("f_id", file.f_id)
    f.Add("f_nombre", file.f_nombre)
    f.Add("f_ext", file.f_ext)
    f.Add("f_path", file.f_path)
    f.Add("f_falta", file.f_falta)
    f.Add("f_size", file.f_size)
    f.Add("f_depende_de", file.f_depende_de)
    f.Add("ThumbBinary", file.getThumbBinary(False, 200, 200))
    Me.contents("file") = f
    'Dim f_params As String
    Me.contents("f_id") = f_id
    Me.contents("width") = width
    Me.contents("height") = height
    Me.contents("imageTypes") = nvFW.nvFile.getFileTypes_rsParam()

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>File Preview</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js" language='javascript'></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js" language='javascript'></script>
    <% =Me.getHeadInit()%>
    <script type="text/javascript">
        var file = nvFW.pageContents.file
        var f_id = nvFW.pageContents.f_id
        var width = nvFW.pageContents.width
        var height = nvFW.pageContents.height
        var imageType
        function window_onload() 
          {
          imageType = nvFW.pageContents.imageTypes[file.f_ext.toLowerCase()]
          if (imageType == undefined)
          imageType = {hasThumb:false,browser_display:false}
          if (imageType.hasThumb)
            {
            $("tbHeadImg").show()
            $("divIMG").show()
            $("iframeFile").hide()
            tamano_seleccionar(200)
            tamano_onchange()
            }
          else
            {
            $("tbHeadImg").hide()
            $("divIMG").hide()
            $("iframeFile").show()
            $("iframeFile").src = "/fw/files/file_get.aspx?f_id=" + file.f_id
            }
          $("ifFirmas").src = "/fw/files/file_signatures.aspx?f_id=" + file.f_id
          window_onresize()
          }

        function tamano_seleccionar(valor) 
          {
          var cb = $('cbTananio')
          for (var i = 0; i < cb.length; i++) {
                if (valor == cb[i].value) {
                    cb[i].selected = true
                    return
                }
            }
          }

        function tamano_onchange() 
          {
            var cb = $('cbTananio')
            var valor = cb.options[cb.selectedIndex].value
            
            if (valor == '0') 
              {
              $("img_preview").src = "/fw/files/file_get.aspx?f_id=" + f_id 
              } 
            else 
              {
              $("img_preview").src = '/fw/files/file_thumb.aspx?f_id=' + f_id + '&thumb_height=' + valor + '&thumb_width=' + valor
              //$("img_preview").setStyle({background: "url(" + '/fw/file_dialog/file_thumb.aspx?f_id=' + f_id + '&thumb_height=' + valor + '&thumb_width=' + valor + ") no-repeat center center"})
              }
            
            $("aPreview").href = $("img_preview").src + "&content_disposition=attachment"
          } 


        function setSize(){
            $('tdTamanio').innerHTML = imgOri.getWidth() + 'x' + imgOri.getHeight()
        }

        function window_onresize()
          {
          var height 
          if (imageType.hasThumb)
            height = $$("BODY")[0].getHeight() - $("tbHeadImg").getHeight() - $("tbFirmas").getHeight()
          else
            height = $$("BODY")[0].getHeight() - $("tbFirmas").getHeight()
                       
          $("divIMG").setStyle({height: height + 'px'})
          $("iframeFile").setStyle({height: height + 'px'})
          }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="overflow:hidden">
    <table class='tb1' id="tbHeadImg" style="display:none">
        <tr class="tbLabel">
            <td>
                Tamaño
            </td>
            <td>
                -
            </td>
            <td>
                Herramientas
            </td>
        </tr>
        <tr>
            <td>
                <select id="cbTananio" style='width: 100%' onchange='tamano_onchange()'>
                    <option value="0">Original </option>
                    <option value="200">200 Pixeles </option>
                    <option value="300">300 Pixeles </option>
                    <option value="500">500 Pixeles </option>
                    <option value="700">700 Pixeles </option>
                </select>
            </td>
            <td id='tdTamanio'>
            </td>
            <td>
                &nbsp;&nbsp;<a id='aPreview' target="hiddenIframe" href="">Descargar preview</a>
            </td>
        </tr>
    </table>
    <div id="divIMG" style="width: 100%; height: 400px; overflow-y: auto">
        <table width="100%" height="100%" align="center" valign="center">
            <tr>
                <td align="center">
                    <img id="img_preview" src="" alt="" />
                </td>
            </tr>
        </table>
    </div>
    <iframe id="iframeFile" name="iframeFile" style="width:100%" frameborder="0" marginheight="0" marginwidth="0" ></iframe>
    <table class="tb1" id="tbFirmas">
        <tr><td><iframe name="ifFirmas" id="ifFirmas" style="width:100%; height: 150px" frameborder="0" marginheight="0" marginwidth="0"></iframe></td></tr>
    </table>
    <iframe id="hiddenIframe" name="hiddenIframe" style="display:none"></iframe>
<%--    <div>
    <iframe id="imgOri" name="imgOri" style="width: 100%; height: 100%;margin: 0px;" frameborder="0" marginheight="0" marginwidth="0" ></iframe>
    </div>

    <div>
    <iframe id="imgPreview" name="imgPreview" style="width: 100%; height: 100%;margin: 0px;" frameborder="0" marginheight="0" marginwidth="0" ></iframe>
    </div>--%>


    
</body>
</html>
