<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 

    Dim nro_rpt_tipo As String = nvUtiles.obtenerValor("nro_rpt_tipo", "")
    Dim nro_credito As String = nvUtiles.obtenerValor("nro_credito", "")
    Dim nro_docu As String = nvUtiles.obtenerValor("nro_docu", "")
    Dim tipo_docu As String = nvUtiles.obtenerValor("tipo_docu", "")
    Dim sexo As String = nvUtiles.obtenerValor("sexo", "")
    Dim hash As String = nvUtiles.obtenerValor("nv_hash", "")
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim rpt_defs As String = nvUtiles.obtenerValor("rpt_defs", "")
    Dim mail As String = nvUtiles.obtenerValor("mail", "")
    Dim salida As String = nvUtiles.obtenerValor("salida", "HTML")

    if(nro_credito = "")
        Response.Write("Falta Ingresar el número de Credito")
        Response.End()
    end If

    Dim mail_operador = ""
    Dim mail_vendedor = ""
    Dim rz_vendedor = ""
    Dim rz_operador = ""

    Dim host_dominio = ""
    Dim reg = "(\\.)+[a-z0-9\\.\\-]+[^\\/]"
    Dim dominio As String = nvApp.server_path
    For Each match As Match In Regex.Matches(nvApp.server_path, reg)
        dominio = match.Value
    Next
    If (dominio.Length > 0) Then
        dominio = dominio.Substring(1, dominio.ToString.Length - 1)
    End If


    Dim sql As String = "select nro_credito"
    sql += ", v.nro_vendedor"
    sql += ", v.nro_entidad "
    sql += ", o.login"
    sql += ", case when isnull(lower(o.login),'') <> '' then lower(o.login) + '@" + dominio + "' else '' end as mail_operador"
    sql += ", case when isnull(lower(pv.email),'') <> '' then lower(pv.email) else '' end as mail_vendedor"
    sql += ", case when isnull(lower(pv.email),'') <> '' then pv.nombres + ' ' + pv.apellido else '' end as rz_vendedor"
    sql += ", case when not(po.nro_entidad is null) then po.nombres + ' ' + po.apellido  else '' end as rz_operador"
    sql += " from verCreditos c"
    sql += " left outer join verVendedores v on v.nro_vendedor  = c.nro_vendedor"
    sql += " left outer join verPersonas pv on pv.nro_entidad = v.nro_entidad"
    sql += " left outer join operadores o on o.operador = c.operador"
    sql += " left outer join verPersonas po on po.nro_entidad = o.nro_entidad"
    sql += " where nro_credito=" & nro_credito

    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(sql)
    If (rs.EOF = False) Then
        mail_operador = rs.Fields("mail_operador").Value
        mail_vendedor = rs.Fields("mail_vendedor").Value
        rz_vendedor = rs.Fields("rz_vendedor").Value
        rz_operador = rs.Fields("rz_operador").Value
    End If
    nvDBUtiles.DBCloseRecordset(rs)

    Dim filtroXML_rm_rpt_buscar As String = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_rpt_buscar' vista='wrp_infoCredito'><parametros></parametros></procedure></criterio>")

    Me.addPermisoGrupo("permisos_rpt")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Impresión de Reportes</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>
    
    <% = Me.getHeadInit()%>
    <script type="text/javascript" >

        var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); }

        var win = nvFW.getMyWindow()

        function window_onload() {

            window_onresize()
            
            var nro_rpt_tipo = $('nro_rpt_tipo').value
            var nro_credito  = $('nro_credito').value
            var nro_docu = $('nro_docu').value
            var tipo_docu = $('tipo_docu').value
            var sexo = $('sexo').value
            var nro_print_tipo= 2  //2-pre impresos  3-Digitales
            var filtroWhere = ''
            
           //imprimir_pdf(nro_credito)
            if (nvFW.tienePermiso("permisos_rpt", 2)) {
            //*Reportes en estado prueba/vigentes y NO vigentes (Los NO vigentes se muestran siempre y cuando la fecha del estado no sea inferior a  la fecha actual)*/
                filtroWhere = "<criterio><procedure><parametros><nro_credito DataType='int'>" + nro_credito + "</nro_credito><rpt_todos DataType='int'>1</rpt_todos><nro_print_tipo DataType='int'>" + nro_print_tipo + "</nro_print_tipo></parametros></procedure></criterio>"
            } else {
            //*Reportes en estado vigentes y NO vigentes (Los NO vigentes se muestran siempre y cuando la fecha del estado no sea inferior a  la fecha actual)*//
                filtroWhere = "<criterio><procedure><parametros><nro_credito DataType='int'>" + nro_credito + "</nro_credito><rpt_todos DataType='int'>0</rpt_todos><nro_print_tipo DataType='int'>" + nro_print_tipo + "</nro_print_tipo></parametros></procedure></criterio>"
            }

                nvFW.exportarReporte({ filtroXML: '<%=filtroXML_rm_rpt_buscar %>',
                filtroWhere: filtroWhere,
                path_xsl: 'report\\verRPT_impresion\\HTML_rpt_impresion_movil.xsl',
                parametros: '<parametros><nro_credito>' + nro_credito + '</nro_credito><rz_operador><%=rz_operador %></rz_operador><rz_vendedor><%=rz_vendedor %></rz_vendedor><mailO><%= mail_operador %></mailO><mailV><%= mail_vendedor %></mailV></parametros>',
                formTarget: 'frame_listado',
                async: true,
                nvFW_mantener_origen: true,
                bloq_contenedor: 'frame_listado',
                cls_contenedor: 'frame_listado'
                })

        }

        function window_onresize() {
            try {                
            }
            catch (e) { }
        }

        function imprimir_pdf(rpt_defs,salida,mail,observacion) {

            if (!observacion)
                observacion = ""

            if (salida == 'MAIL') {

                if (mail == '') {

                    Dialog.confirm("Ingrese el correo del destinatario: <input type='text' id='dgMail' style='width:70%'/>",
                                        {
                                            width: 400,
                                            className: "alphacube",
                                            okLabel: "Si",
                                            cancelLabel: "No",
                                            onShow: function () { $('dgMail').focus() },
                                            onOk: function (w) {
                                                if ($('dgMail').value == '') {
                                                    alert("Ingrese la dirección de correo correspondiente")
                                                    return
                                                }

                                                var reg = new RegExp("^[_a-z0-9-]+(.[_a-z0-9-]+)*@[a-z0-9-]+(.[a-z0-9-]+)*(.[a-z]{2,4})$")
                                                var resultado = $('dgMail').value.match(reg)
                                                if (resultado == null) {
                                                    alert("El correo ingresado es invalido")
                                                    return
                                                }

                                                nvFW.error_ajax_request("RPT_exportar_destino.aspx", {
                                                    parameters: { modo: "M", nro_credito: $('nro_credito').value, rpt_defs: rpt_defs, salida: salida, mail: $('dgMail').value },
                                                    bloq_msg: 'Enviando correo a ' + $('dgMail').value + '...',
                                                    onSuccess: function (err, transport) {
                                                        if (err.numError == 0)
                                                            alert("Se envio el correo de la solicitud Nº " + $('nro_credito').value)
                                                        else
                                                            alert("Error al enviar correo." + err.mensaje)
                                                    }
                                                });


                                                w.close();
                                                return
                                            },

                                            onCancel: function (w) {
                                                w.close();
                                            }
                                        });

                }
                else {

                    if (observacion.toLowerCase() == 'enviar_sin_confirmar')
                    {
                        nvFW.error_ajax_request("rpt_impresion.aspx", {
                            parameters: { modo: "M", nro_credito: $('nro_credito').value, rpt_defs: rpt_defs, salida: salida, mail: mail },
                            bloq_msg: 'Enviando correo a ' + mail + '...',
                            onSuccess: function (err, transport) {
                                if (err.numError == 0)
                                    alert("Se envio el correo de la solicitud Nº" + $('nro_credito').value)
                                else
                                    alert("Error al enviar correo." + err.mensaje)
                            }
                        });

                    }
                    else
                      Dialog.confirm("¿Desea enviar a <b>" + mail + "</b> la solicitud de préstamo Nº <b>" + $('nro_credito').value + "</b>?",
                                       {
                                           width: 300,
                                           className: "alphacube",
                                           okLabel: "Si",
                                           cancelLabel: "No",
                                           onOk: function (w) {

                                               nvFW.error_ajax_request("RPT_exportar_destino.aspx", {
                                                   parameters: { modo: "M", nro_credito: $('nro_credito').value, rpt_defs: rpt_defs, salida: salida, mail: mail },
                                                   bloq_msg: 'Enviando correo a ' + mail + '...',
                                                   onSuccess: function (err, transport) {
                                                       if (err.numError == 0)
                                                           alert("Se envio el correo de la solicitud Nº" + $('nro_credito').value)
                                                       else
                                                           alert("Error al enviar correo." + err.mensaje)
                                                   }
                                               });

                                               w.close();
                                               return
                                           },

                                           onCancel: function (w) {
                                               w.close();
                                           }
                                       });

                }
            }
            else {

                //$('rpt_defs').value = rpt_defs
                //$('salida').value = "HTML"
                //$('form').submit()

                nvFW.error_ajax_request("RPT_exportar_destino.aspx", {
                    parameters: { modo: "M", nro_credito: $('nro_credito').value, rpt_defs: rpt_defs, salida: "html", content_disposition: "inline" },
                    bloq_msg: 'Generando informe',
                    onSuccess: function (err, transport) {
                        if (err.numError == 0) {
                            var win = window.open(err.params.url, "")
                            // win.close()
                        }
                        else
                            alert("Error al generar informe." + err.mensaje)
                    }
                });
            }

        }

        var filtroWhere = ""
        var strName = ""
        function btnExportar_onclick() {

            if (filtroWhere != "" && strName != "") {
                window.top.nvFW.exportarReporte({ filtroXML: '<%=filtroXML_rm_rpt_buscar %>',
                    filtroWhere: filtroWhere,
                    path_xsl: 'report\\verRPT_impresion\\XLS_REPORTE_IMPRESION.xsl',
                    formTarget: '_blank',
                    filename: strName,
                    salida_tipo: "adjunto",
                    name: 'solicitudes',
                    ContentType: "application/vnd.ms-excel"
                })

            }
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="height: 100%; overflow: hidden">
   <div id="divMenu" style="width:100%; margin: 0px; padding: 0px"></div>
   <script type="text/javascript">
    var DocumentMNG = new tDMOffLine;
    var vMenu = new tMenu('divMenu', 'vMenu');
    Menus["vMenu"] = vMenu
    Menus["vMenu"].alineacion = 'centro';
    Menus["vMenu"].estilo = 'A';
    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnExportar_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
    vMenu.loadImage("excel", '/fw/image/icons/excel.png')
    vMenu.MostrarMenu()
   </script>
   <form action="RPT_exportar_destino.aspx" method="post" name="form" id="form" target="_blank" style='display:none'>
        <input type="hidden" name="rpt_defs" id="rpt_defs" value=""/>
        <input type="hidden" name="salida" id="salida" value="HTML"/>  
        <input type="hidden" name="nro_credito" value="<%= nro_credito %>"/>  
   </form>
    
   <input type="hidden" name="nro_rpt_tipo" id="nro_rpt_tipo" value="<%=nro_rpt_tipo%>" />
   <input type="hidden" name="nro_credito" id="nro_credito" value="<%=nro_credito%>" />  
   <input type="hidden" name="nro_docu" id="nro_docu"  value="<%= nro_docu%>"/>  
   <input type="hidden" name="tipo_docu" id="tipo_docu" value="<%= tipo_docu%>"/>  
   <input type="hidden" name="sexo" id="sexo"  value="<%= sexo%>"/> 

   <iframe name="frame_listado" id="frame_listado" src="enBlanco.htm" style="width: 100%; height: 100%; overflow: hidden; border: none"></iframe>

</body>
</html>