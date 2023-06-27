<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageIDS" %>
<%
    Dim uid_valcode As String = nvUtiles.obtenerValor("id_origen", "")
    Dim accion As String = nvUtiles.obtenerValor("accion", "")

    If accion <> "" AndAlso accion = "load_info" Then
        Dim err As New tError

        If uid_valcode = "" Then
            err.numError = 100
            err.titulo = "Error"
            err.mensaje = "Identificación de Identidad inválida o nula."
            err.response()
        End If

        Dim query As String = String.Format("SELECT tError_response, tError_validation, request FROM ids_identity_validations a LEFT JOIN ids_action_requests b ON a.uid_valcode = b.id_origen WHERE uid_valcode='{0}'", uid_valcode)
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(query)
        Dim tError_response As String = ""
        Dim tError_validation As String = ""
        Dim request_xml As String = ""

        If Not rs.EOF Then
            tError_response = nvUtiles.isNUll(rs.Fields("tError_response").Value, "")
            tError_validation = nvUtiles.isNUll(rs.Fields("tError_validation").Value, "")
            request_xml = nvUtiles.isNUll(rs.Fields("request").Value, "")

            If request_xml <> "" Then
                ' Chequear si el XML es válido, porque puede no tener un nodo raíz
                Dim xml As New System.Xml.XmlDocument

                Try
                    xml.LoadXml(request_xml)
                Catch ex As Exception
                    request_xml = "<request>" & request_xml & "</request>"
                    Try
                        xml.LoadXml(request_xml)
                    Catch ex2 As Exception
                        request_xml = ""
                    End Try
                End Try

                xml = Nothing
            End If

        End If

        nvDBUtiles.DBCloseRecordset(rs)

        err.params("tError_response") = tError_response
        err.params("tError_validation") = tError_validation
        err.params("request_xml") = request_xml
        err.response()
    End If


    Me.contents("uid_valcode") = uid_valcode
%>
<!DOCTYPE html>
<html>
<head>
    <title>Detalles de Validación de Imagen</title>
    <link href="/FW/css/base.css" rel="stylesheet" type="text/css" />
    <style>
        body {
            width: 100%;
            overflow: hidden;
        }
        div.container {
            display: inline-block;
            width: 50%;
            height: 100%;
            float: left;
            overflow: hidden;
        }
        div.container p {
            margin: 0;
            padding: 10px;
            height: 40px;
            text-align: center;
            font-size: 1.3em;
            background-color: #333333;
            color: #ffffff;
            font-weight: bold;
        }
        div.container textarea,
        div.container table,
        div.container div.CodeMirror {
            width: 100%;
            height: calc(100% - 40px);
        }
        div.container:first-child div.CodeMirror {
            border-right: 1px solid #cccccc;
        }
        div.container > div {
            background-color: #ffffff;
        }

        .tb1 tr.tbLabel td {
            text-align: center;
        }
        .icon {
            display: inline-block;
            width: 16px;
            height: 16px;
        }
        .icon.ok {
            background-image: url('/IDS/image/icons/ok.png');
        }
        .icon.error {
            background-image: url('/IDS/image/icons/cancelar.png');
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <%-- CodeMirror --%>
    <script type="text/javascript" src="/FW/script/CodeMirror/lib/codemirror.js"></script>
    <link rel="stylesheet" type="text/css" href="/FW/script/CodeMirror/lib/codemirror.css" />
    <script type="text/javascript" src="/FW/script/CodeMirror/mode/xml/xml.js"></script>

    <script type="text/javascript">
        var editor_response = null;
        var validations     = {
            req_email:               'Email',
            req_phone:               'Teléfono',
            req_verazID:             'Veraz',
            req_nosisID:             'NOSIS',
            req_dni_frente:          'DNI Frente',
            req_dni_dorso:           'DNI Dorso',
            req_selfie:              'Selfie',
            val_dni_selfie:          'DNI + Selfie',
            val_pre_selfie:          'Prevalidación Selfie',
            val_bio_vida:            'Biométrica Vida',
            val_renaper_basico:      'ReNaPer Básico',
            val_renaper_multifactor: 'ReNaPer Multifactor',
            req_cbu_mov:             'Movimiento CBU',
            bpm_process:             'Proceso BPM',
            req_facebook:            'Facebook',
            req_google:              'Google',
            req_twitter:             'Twitter',
            req_instagram:           'Instagram'
        }



        function drawRequestTable(data)
        {
            var html = '<tr class="tbLabel"><td style="width: 250px;">Dato</td><td>Valor</td></tr>';

            if (!data)
            {
                html += '<tr><td colspan="2" style="text-align: center;">Sin Datos</td></tr>'
                $('tbRequest').innerHTML = html;
                return;
            }

            var oXML = new tXML();
            if (!oXML.loadXML(data)) return;

            var NOD = oXML.selectSingleNode('request');

            for (var node of NOD.children)
            {
                html += '<tr>';
                html += '<td>' + node.nodeName + '</td>';
                html += '<td>';
                
                switch (node.nodeName)
                {
                    case 'ids_deviceID':
                        html += '<b>' + node.textContent + '</b>';
                        break;

                    case 'dni_frente_code':
                    case 'dni_dorso_code':
                    case 'selfie_code':
                    case 'gesture1_code':
                    case 'gesture2_code':
                    case 'gesture3_code':
                    case 'gesture4_code':
                        html += '<a href="javascript:parent.ObtenerVentana(\'frame_right\').showDetails(\'val_img\', \'' + node.textContent + '\')">' + node.textContent + '</a>';
                        break;

                    default:
                        html += node.textContent;
                        break;
                }

                html += '</td>';
                html += '</tr>';
            }

            $('tbRequest').innerHTML = html;
        }


        function drawValidationTable(data)
        {
            if (!data) return;

            var oXML = new tXML();
            if (!oXML.loadXML(data)) return;

            var html      = '<tr class="tbLabel"><td style="width: 140px;">Validación</td><td style="width: 75px;">Resultado</td><td>Mensaje</td><td style="width: 70px;">Tiempo</td></tr>';
            var params    = oXML.selectSingleNode('/error_mensajes/error_mensaje/params');
            var NOD       = null;
            var NOD_child = null;

            for (var i = 0; i < params.childElementCount; i++)
            {
                NOD       = params.children[i];
                NOD_child = NOD.children;
                html += '<tr>';

                // Validación
                html += '<td>' + (validations[NOD.nodeName] ? validations[NOD.nodeName] : NOD.nodeName) + '</td>';

                // Resultado
                if (NOD_child[0].textContent === 'true')
                    html += '<td style="text-align: center;"><span class="icon ok" title="Validación OK"></span></td>';
                else
                    html += '<td style="text-align: center;"><span class="icon error" title="Validación FALLIDA"></span></td>';

                // Mensaje
                html += '<td>' + NOD_child[1].textContent + '</td>';

                // Tiempo transcurrido por validación
                html += '<td style="text-align: right;">' + (NOD_child[2] ? NOD_child[2].textContent : '0') + ' ms</td>';
                html += '</tr>';
            }

            $('tbValidation').innerHTML = html;
        }


        function loadData()
        {
            nvFW.error_ajax_request('identity_details.aspx',
            {
                parameters:
                {
                    id_origen: '<% = uid_valcode %>',
                    accion:    'load_info'
                },
                onSuccess: function (err)
                {
                    // Metemos unos saltos de linea entre cada etiqueta para leerlo bien
                    var re = new RegExp(/></ig);

                    // Request
                    drawRequestTable(err.params.request_xml);

                    // Response
                    if (!err.params.tError_response) err.params.tError_response = '<request>Sin datos</request>'
                    $('txtResponse').value = err.params.tError_response;
                    editor_response.setValue(err.params.tError_response.replace(re, '>\n<'));
                    
                    // Response Validation
                    drawValidationTable(err.params.tError_validation);
                },
                onFailure: function (err)
                {
                    alert(err.mensaje, { title: '<b>' + err.titulo + '</b>', width: 400 });
                },
                error_alert:     false,
                bloq_contenedor: $$('body')[0],
                bloq_msg:        'Cargando información...'
            });
        }


        function setCodeMirror()
        {
            const options = {
                scrollbarStyle:   'native',
                mode:             'xml',
                readOnly:         true,
                selectionPointer: true
            };

            editor_response = CodeMirror.fromTextArea($('txtResponse'), options);
        }


        function setTitle()
        {
            nvFW.getMyWindow().setTitle('<b>Detalles validación de Identidad (' + nvFW.pageContents.uid_valcode + ')</b>');
        }


        function windowOnload()
        {
            setTitle();
            setCodeMirror();
            loadData();
        }
    </script>
</head>
<body onload="windowOnload()">

    <div class="container">
        <p>Datos de Consulta</p>
        <div style="overflow: auto;">
            <table class="tb1 highlightTROver highlightOdd" id="tbRequest"></table>
        </div>
    </div>

    <div class="container">
        <div style="height: 50%;">
            <p>tError Response</p>
            <textarea name="txtResponse" id="txtResponse"></textarea>
        </div>
        <div style="height: 50%;">
            <p>tError Validation</p>
            <div style="overflow: auto;">
                <table class="tb1 highlightTROver highlightOdd" id="tbValidation"></table>
            </div>
        </div>
    </div>

</body>
</html>