<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageVOII" %>
<%

    Dim err As New tError()

    Dim nro_sol As String = nvFW.nvUtiles.obtenerValor("nro_sol", "")
    Dim nro_sol_tipo As String = nvFW.nvUtiles.obtenerValor("nro_sol_tipo", "")

    Dim id_transferencia As String = nvFW.nvUtiles.obtenerValor("transferencia", "")

    If (id_transferencia <> "") Then
        Try
            'Garga la transferencia
            Dim tx As New nvFW.nvTransferencia.tTransfererncia
            tx.cargar(id_transferencia)
            tx.param("nro_sol")("valor") = nro_sol

            err = tx.ejecutar()

            Dim errRes As New tError()
            errRes.params.Add("id_transf_log", err.params("id_transf_log"))

            'Evaluas la ejecución de la transferencia y los posibles errores
            If err.numError <> 0 Then
                errRes.numError = -1
                errRes.titulo = "No se pudo ejecutar la tarea"
                errRes.mensaje = "Error al ejecutar el proceso"
                errRes.response()
            End If

            Dim strXMLRes = tx.getError_xml()

            Dim oXML As New System.Xml.XmlDocument
            oXML.LoadXml(strXMLRes)

            Dim errorCount = nvFW.nvXMLUtiles.getAttribute_path(oXML, "error_mensajes/error_mensaje/params/tareas_logs/@error_count", "-1")
            If errorCount <> 0 Then
                errRes.numError = 0
                errRes.titulo = ""
                errRes.mensaje = ""
                errRes.params("user_message") = "El proceso se ejecuto con errores, consulte al administrador del sistema (" & err.params("id_transf_log") & ")."
                errRes.response()
            End If

            Dim targetList As String = ""
            Dim nodes As System.Xml.XmlNodeList = oXML.SelectNodes("error_mensajes/error_mensaje/params/return/elements/targets/target")
            For Each n As System.Xml.XmlElement In nodes
                Dim id_transf_log_det = nvXMLUtiles.getAttribute_path(n, "@id_transf_log_det", "")
                Dim p = nvXMLUtiles.selectSingleNode(oXML, "error_mensajes/error_mensaje/params/tareas_logs/error_mensaje/params[id_transf_log_det = '" + id_transf_log_det + "']")
                Dim tName = nvXMLUtiles.getNodeText(p, "transf_det", "")
                targetList += "{""name"":""" & tName & """,""url"":""" & n.InnerXml & """},"
            Next

            'JSON targets
            errRes.params.Add("targets", "[" & targetList.Trim(",") & "]")
            errRes.params.Add("user_message", nvFW.nvXMLUtiles.getNodeText(oXML, "error_mensajes/error_mensaje/params/return/elements/params/user_message", ""))
            errRes.response()

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 106
            err.titulo = "Error en la transferencia"
            err.mensaje = "Error al ejecutar la transferencia"
        End Try

        err.response()
    End If

    Me.contents("procesoXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_det'><campos>pizarra_valor as titulo, pizarra_valor_2 as comentario, dato2_desde as transferencia,  dato3_desde as ej_mostrar, orden</campos><orden>orden</orden><filtro><nro_calc_pizarra type='igual'>9</nro_calc_pizarra><dato1_desde type='igual'>'" + nro_sol_tipo + "'</dato1_desde></filtro></select></criterio>")


    Me.contents("nro_sol") = nro_sol
    Me.contents("nro_sol_tipo") = nro_sol_tipo

%>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Solicitud</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
     

        <%= Me.getHeadInit() %>

        <script type="text/javascript">
            var ventanaProceso
            function window_onload() {
                ventanaProceso = nvFW.getMyWindow()
                if (ventanaProceso.options.userData == undefined)
                    ventanaProceso.options.userData = {}
                ventanaProceso.options.userData.hay_modificacion = false

                var rs = new tRS();
                rs.open(nvFW.pageContents.procesoXML);
                while (!rs.eof()) {
                    var fila = '<tr><td title="' + rs.getdata("comentario") + '">' + rs.getdata("titulo") + '</td><td><div id="divEjecutar' + rs.getdata("transferencia") + '" style="width: 100%"></div></td></tr>'
                    $$('#procesosTbl')[0].insert(fila);

                    var vButtons = {};
                    vButtons[0] = {};
                    vButtons[0]["nombre"] = "Ejecutar" + rs.getdata("transferencia");
                    vButtons[0]["etiqueta"] = "Ejecutar";
                    vButtons[0]["imagen"] = "ejecutar";
                    vButtons[0]["onclick"] = "return ejecutarTransf('" + rs.getdata("transferencia") + "','" + rs.getdata("comentario") + "', '"+ rs.getdata("ej_mostrar") + "')";
                    var vListButtons = new tListButton(vButtons, 'vListButtons');
                    vListButtons.loadImage("ejecutar", '/FW/image/icons/procesar.png');
                    vListButtons.MostrarListButton()

                    rs.movenext()
                }

                var contentHeight = $$("#procesosTbl")[0].getHeight();
                if (contentHeight < 140)
                    contentHeight += 100
                ventanaProceso.setSize(ventanaProceso.getSize().width, contentHeight);
            }

            var win_transf
            function ejecutarTransf(nroTransferencia,com,mostrar) {

              if(mostrar == '1')
                {
                  win_transf = parent.nvFW.createWindow({
                                                        title: '<b>' + com + '</b>',
                                                        minimizable: false,
                                                        maximizable: true,
                                                        maximize:true,
                                                        draggable: true,
                                                        width: 1100,
                                                        height: 400,
                                                        resizable: true,
                                                        destroy: true,
                                                        onClose: function (w) {
                                                             ventanaProceso.options.userData.hay_modificacion = true  
                                                             ventanaProceso.close()
                                                             w.close()
                                                        }
                                                    });
                 win_transf.setURL('/fw/transferencia/transf_ejecutar.aspx?pasada=0&id_transferencia=' + nroTransferencia + '&xml_param=<parametros><nro_sol><%= nro_sol%></nro_sol></parametros>&ej_mostrar=true&app_path_rel=<%= nvApp.path_rel  %>')
                 win_transf.showCenter()
               
                }
          else
            {
                parent.nvFW.error_ajax_request('solicitud_proceso_ejecutar.aspx', {
                    parameters: { transferencia: nroTransferencia, nro_sol: nvFW.pageContents.nro_sol },
                    bloq_msg: "Ejecutando Proceso",
                    onSuccess: function (err, transport) {

                        ventanaProceso.options.userData.hay_modificacion = true                        
                        if (err.params.user_message) {
                            var mensaje = '<b>' + err.params.user_message + "</b>"

                            //iterar sobre los targets
                            var targetArr = JSON.parse(err.params.targets);
                            var archivosTr = ""
                            for (target of targetArr) {
                                var extencion = target.url.substring(target.url.lastIndexOf('.') + 1);
                                archivosTr += '<tr>' +
                                    '<td>' + target.name + '</td>' +
                                    '<td style="text-align: center;"><img src="/FW/image/docs/' + extencion + '.png" alt="' + extencion + '" border="0" align="bottom" height="16"></td>' +
                                    '<td><a href="' + window.location.origin + '/fw/files/file_get.aspx?path=' + target.url + '" title="Descargar" style="display: block;" download>' + target.url.substring(target.url.lastIndexOf('/') + 1) + '</a></td>' +
                                    '</tr>'
                            }
                            
                            if (archivosTr) {
                                mensaje += '<table class="tb1"><tr class="tbLabel"><td colspan="3" style="padding: 0 .3em 0 .3em;">Archivos generados</td></tr>' + archivosTr + '</table>'
                            }

                            var resumeParam = {
                                onOk: function () {
                                    ventanaProceso.close()
                                    this.close()
                                },
                                windowParameters: {
                                    width: "400px",
                                    height: 62 + (16 * targetArr.lenght) + "px"
                                }
                            }
                            parent.nvFW.alert(mensaje, resumeParam);
                        }
                        
                    },
                    onError: function () {
                        parent.nvFW.alert();
                    },
                    error_alert: false
                })
            }
        }
        </script>

    </head >

    <body  onload="window_onload()">
        <table class="tb1 highlightOdd highlightTROver">
            <tbody id="procesosTbl">

            </tbody>
        </table>

    </body>
</html>