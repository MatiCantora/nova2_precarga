<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim cod_image As String = nvUtiles.obtenerValor("cod_image", "")
    Dim accion As String = nvUtiles.obtenerValor("accion", "")

    If accion <> "" AndAlso accion = "load_info" Then
        Dim err As New tError

        If cod_image = "" Then
            err.numError = 100
            err.titulo = "Error"
            err.mensaje = "Codigo de imagen inválido"
            err.response()
        End If

        Dim query As String = String.Format("SELECT tError_response, tError_validation FROM ids_image_validations WHERE cod_image='{0}'", cod_image)
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(query)
        Dim tError_response As String = ""
        Dim tError_validation As String = ""

        If Not rs.EOF Then
            tError_response = nvUtiles.isNUll(rs.Fields("tError_response").Value, "")
            tError_validation = nvUtiles.isNUll(rs.Fields("tError_validation").Value, "")
        End If

        nvDBUtiles.DBCloseRecordset(rs)

        If tError_response = "" Then
            err.numError = 101
            err.titulo = "Error al solicitar datos"
            err.mensaje = "Los datos asociados a la solicitud actual son nulos."
            err.response()
        End If

        err.params("tError_response") = tError_response
        err.params("tError_validation") = tError_validation
        err.response()
    End If
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Información obtenida por Validación de Imagen</title>
        <link rel="stylesheet" type="text/css" href="/FW/css/base.css" />
        <style>
            body {
                width: 100%;
                overflow: hidden;
                background-color: white;
            }
            div#divValidation,
            div#divData {
                height: 50%;
                margin: 0;
                padding: 0;
                overflow: hidden;
            }
            h3 {
                margin: 0;
                padding: 10px;
                font-weight: bold;
                text-align: center;
                background-color: #333333;
                color: #ffffff;
            }
            div > textarea {
                margin: 0;
                padding: 5px;
            }
        </style>

        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

        <%-- CodeMirror --%>
        <script type="text/javascript" src="/FW/script/CodeMirror/lib/codemirror.js"></script>
        <link rel="stylesheet" type="text/css" href="/FW/script/CodeMirror/lib/codemirror.css" />
        <script type="text/javascript" src="/FW/script/CodeMirror/mode/xml/xml.js"></script>

        <script type="text/javascript">
            var editor_response   = null;
            var editor_validation = null;


            function loadData()
            {
                nvFW.error_ajax_request("get_info.aspx",
                {
                    parameters:
                    {
                        "cod_image": "<% = cod_image %>",
                        "accion":    "load_info"
                    },
                    onSuccess: function (err)
                    {
                        // Metemos unos saltos de linea entre cada etiqueta para leerlo bien
                        var re = new RegExp(/></ig);

                        $('txtResponse').value = err.params.tError_response;
                        editor_response.setValue(err.params.tError_response.replace(re, ">\n<"));

                        $('txtValidation').value = err.params.tError_validation;
                        editor_validation.setValue(err.params.tError_validation.replace(re, ">\n<"));
                    },
                    onFailure: function (err)
                    {
                        alert(err.mensaje, { title: '<b>' + err.titulo + '</b>', width: 400 });
                    },
                    error_alert:     false,
                    bloq_contenedor: $$('body')[0],
                    bloq_msg:        'Cargando datos...'
                });
            }


            function setCodeMirror()
            {
                const options = {
                    scrollbarStyle:   "native",
                    mode:             "xml",
                    readOnly:         true,
                    selectionPointer: true
                };

                editor_response   = CodeMirror.fromTextArea($("txtResponse"), options);
                editor_validation = CodeMirror.fromTextArea($("txtValidation"), options);
            }


            function windowOnresize()
            {
                try
                {
                    // Corregir altura para los 2 DIV's principales
                    var body_h = $$('body')[0].getHeight();
                    var half_h = body_h / 2;

                    $('divValidation').style.height = half_h + 'px';
                    $('divData').style.height = half_h + 'px';

                    // Corregir altura para los CodeMirror
                    var h3_h = $$('#divValidation h3')[0].getHeight();
                    var code_h = half_h - h3_h - 2; // 2px del border

                    $$('.CodeMirror').each(function (item)
                    {
                        item.setStyle({ 'height': code_h + 'px' });
                    });
                }
                catch (e) {}
            }


            function windowOnload()
            {
                setCodeMirror();
                loadData();
                windowOnresize();
            }
        </script>
    </head>
    <body onload="windowOnload()" onresize="windowOnresize()">
        <div id="divValidation">
            <h3>tError Response</h3>
            <textarea id="txtResponse" rows="11"></textarea>
        </div>
        <div id="divData">
            <h3>tError Validation</h3>
            <textarea id="txtValidation" rows="22"></textarea>
        </div>
    </body>
</html>