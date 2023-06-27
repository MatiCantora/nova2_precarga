<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>

<%

    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim nro_credito As String = nvUtiles.obtenerValor("nro_credito", "")
    Dim nro_vendedor As String = nvUtiles.obtenerValor("nro_vendedor", "")

    Dim _to As String = nvUtiles.obtenerValor("_to", "")
    Dim _cc As String = nvUtiles.obtenerValor("_cc", "")
    Dim _cco As String = nvUtiles.obtenerValor("_cco", "")

    Dim salida As String = nvUtiles.obtenerValor("salida", "")
    Dim htmlAdd As String = nvUtiles.obtenerValor("htmlAdd", "")

    Dim observacion As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("observacion", ""))
    Dim body As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("body", ""))
    Dim subject As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("subject", ""))
    Dim tipo_rechazo_call As String = HttpUtility.UrlDecode(nvUtiles.obtenerValor("tipo_rechazo_call", ""))
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "0")


    Dim path_destino As String = ""
    Dim err As New nvFW.tError()

    If salida <> "estado" Then
        err.salida_tipo = salida
    End If

    Dim rs As ADODB.Recordset
    Try
        If (body = "") And (nro_credito <> "") Then

            rs = nvDBUtiles.DBOpenRecordset("select * from vercreditos where nro_credito = " & nro_credito.ToString)
            If rs.EOF = False Then

                body += "Estimado:" & "<br>" & "<br>"
                body += "Se adjunta documentación para completar en referencia a la operación " & nro_credito.ToString & ".<br><br>"
                body += "<b>Información del Solicitante:</b>" & "<br>"
                body += "Nombre: " & rs.Fields("nombres").Value.ToString & ".<br>"
                body += "Apellido: " & rs.Fields("apellido").Value.ToString & ".<br>"
                body += rs.Fields("documento").Value & ": " & rs.Fields("nro_docu").Value.ToString & ".<br>"
                body += "CUIL: " & rs.Fields("cuit").Value.ToString & ".<br>"
                body += "Fecha Nacimiento: " & Format(rs.Fields("fe_naci").Value, "dd/MM/yyyy") & ".<br>" & "<br>"

                body += "<b>Información del Préstamo:</b>" & "<br>"
                body += "Préstamo Nº: <b>" & nro_credito.ToString & "</b>.<br>"
                body += "Fecha del Préstamo: " & Format(rs.Fields("fe_credito").Value, "dd/MM/yyyy") & ".<br>"
                body += "Plan: " & rs.Fields("plan_banco").Value.ToString & ".<br>"
                body += "Importe Solicitado: $" & rs.Fields("importe_bruto").Value.ToString & ".<br>"
                body += "Importe Neto: $" & rs.Fields("importe_neto").Value.ToString & ".<br>"
                body += "Importe cuota: $" & rs.Fields("importe_cuota").Value.ToString & ".<br>"
                body += "Cuotas: " & rs.Fields("cuotas").Value.ToString & ".<br><br><br>"

                body += htmlAdd

                If observacion = "" And modo = "" Then
                    body += "<p><b>Observación:</b></p>"
                    body += "<div contenteditable='true' class='observacion' id='observacion'>Ingrese las observaciones que crea necesaria...</div>"
                Else
                    body += observacion
                End If

                body += "<p class='nocontestar'>Este mensaje fue originado automáticamente. Por favor, no responder al mismo.</p>"

                subject = "Solicitud de Préstamo Nº " & nro_credito.ToString & " a nombre de " & rs.Fields("nombres").Value.ToString & " " & rs.Fields("apellido").Value.ToString

            End If
            nvDBUtiles.DBCloseRecordset(rs)
        End If

        If modo.ToLower = "enviar" Then

            Dim _from As String = ""
            Dim _from_title As String = ""

            rs = nvDBUtiles.DBOpenRecordset("select * from transf_conf")
            While rs.EOF = False

                If nvApp.server_name.IndexOf(rs.Fields("user").Value.split("@")(1)) >= 0 Then
                    _from = rs.Fields("from").Value
                    _from_title = rs.Fields("from_title").Value
                End If

                rs.MoveNext()
            End While

            If _from = "" Then
                err.numError = 99
                err.mensaje = "Imposible localizar una cuenta de notificación. Consulte al administrador del sistema"
                err.debug_src = "_editor_mail.aspx::enviar correo"
                err.response()
            End If

            err = nvNotify.sendMail(_from_title:=_from_title _
                       , _from:=_from _
                       , _to:=_to _
                       , _cc:=_cc _
                       , _bcc:=_cco _
                       , _subject:=subject _
                       , _body:=body)

        End If


    Catch ex As Exception
        err.parse_error_script(ex)
        err.numError = 99
    End Try

    If modo.ToLower = "enviar" Or err.numError = 0 Then
        If tipo_rechazo_call <> "" Then
            Dim logTrack As String = nvLog.getNewLogTrack()
            nvLog.addEvent("nosis_rechazo", logTrack & ";" & cuit & ";" & tipo_rechazo_call)
        End If
    End If

    If modo.ToLower = "enviar" Or err.numError <> 0 Then
        err.mostrar_error()
    End If

    Dim mail_operador As String = ""
    Dim mail_vendedor As String = ""
    Dim mail_operador_logueado As String = ""
    Dim sql As String = ""

    If (nro_credito <> "") Then
        sql = "select nro_credito"
        sql += ", v.nro_vendedor"
        sql += ", v.nro_entidad "
        sql += ", o.login"
        sql += ", o.operador"
        sql += ", case when isnull(lower(o.login),'') <> '' then lower(po.email) else '' end as mail_operador"
        sql += ", case when isnull(lower(pv.email),'') <> '' then lower(pv.email) else '' end as mail_vendedor"
        sql += " from verCreditos c"
        sql += " left outer join verVendedores v on v.nro_vendedor  = c.nro_vendedor"
        sql += " left outer join verPersonas pv on pv.nro_entidad = v.nro_entidad"
        sql += " left outer join operadores o on o.operador = c.operador"
        sql += " left outer join verPersonas po on po.nro_entidad = o.nro_entidad"
        sql += " where nro_credito=" & nro_credito

        rs = nvDBUtiles.DBOpenRecordset(sql)
        If (rs.EOF = False) Then
            mail_operador = rs.Fields("mail_operador").Value
            mail_vendedor = rs.Fields("mail_vendedor").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    End If

    If (nro_vendedor <> "") Then
        sql = "select lower(pr.email) as mail_vendedor from Vendedor vd "
        sql += "Left Join Personas pr on vd.nro_docu = pr.nro_docu And vd.tipo_docu = pr.tipo_docu And vd.sexo = pr.sexo "
        sql += "where vd.nro_vendedor =" & nro_vendedor

        rs = nvDBUtiles.DBOpenRecordset(sql)

        If (rs.EOF = False) Then
            mail_vendedor = rs.Fields("mail_vendedor").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    End If

    If (nro_credito <> "") Then
        sql = "Select "
        sql += "case When isnull(lower(o.login),'') <> '' then lower(po.email) else '' end as mail_operador"
        sql += " from operadores o "
        sql += " left outer join verPersonas po on po.nro_entidad = o.nro_entidad"
        sql += " where operador =" & nvFW.nvApp.getInstance.operador.operador

        rs = nvDBUtiles.DBOpenRecordset(sql)
        If (rs.EOF = False) Then
            mail_operador_logueado = rs.Fields("mail_operador").Value
        End If
        nvDBUtiles.DBCloseRecordset(rs)
    End If

    Dim cadena_mail As String = ""
    If mail_operador <> "" Then
        cadena_mail = mail_operador
    End If

    If mail_vendedor <> "" Then
        If cadena_mail = "" Then
            cadena_mail = mail_vendedor
        Else
            cadena_mail = cadena_mail & "','" & mail_vendedor
        End If
    End If

    If mail_operador_logueado <> mail_operador And mail_operador_logueado <> "" Then
        If cadena_mail = "" Then
            cadena_mail = mail_operador_logueado
        Else
            cadena_mail = cadena_mail & "','" & mail_operador_logueado
        End If
    End If

    cadena_mail = "'" & cadena_mail & "'"

 %>
<html>
<head>
<title>Transferencia MSG</title>
        <meta http-equiv="x-ua-compatible" content="IE=10">
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/transferencia/css/tags.css" rel="stylesheet" type="text/css" />

        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tScript.js"></script>     
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>   
        <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>

        <script type="text/javascript" src="/FW/transferencia/script/tags.js"></script>
      <% = Me.getHeadInit()%>
        <style type="text/css">
            html {
                overflow: auto;
                width: 100%;
                height: 100%;
            }
            table.table {
                width: 100%;
            }
            table.table td {
                text-align: center;
            }
            table.table textarea,
            table.table input[type="text"] {
                width: 100%;
            }
            #editor {
                height: 170px;
            }
            table.table td.title {
                width: 50px;
            }
            table.table td.narrow {
                width: 30px;
            }
            table.table td.actions {
                width: 40px;
            }
            table.table td.Tit1{
                text-align: right;
                vertical-align: central;
                /*font-weight: bold;*/
            }
            #asunto {
                width: 100%;
            }
            .tagger {
                width: 100%;
                float: right;
            }
            #archivosAdjuntos {
                width: auto;
                float: none;
                min-height: 60px;
            }
            #archivosDisponibles {
                text-align: left;
                min-height: 20px;
                background: #FFFFFF;
            }
            .hidden {
                display: none;
            }
            label {
                float: left;
                line-height: 17px;
            }
            .cont {
                clear: both;
                padding: 1px;
            }
            .campDef {
                display: none;
            }
            span.free {
                display: inline-block;
                background: #DDDDDD;
                border: 1px solid #666666;
                padding: 1px 3px;
                cursor: pointer;
                margin: 1px 2px;
                color: #000000;
            }
            img.search,
            img.avanzado {
                cursor: pointer;
                cursor: hand;
            }
            .nocontestar {
                width: 100%;
                font-style:italic;
            }
       #body {
            padding-bottom : 50px;
			overflow: auto;
			padding: 30px 30px 30px 30px;
/*			border-bottom: 5px solid #05B2D2;*/
			position: relative;
			color: #333;
			background-color: #FFFFFF;
		}

       .observacion {
			overflow: auto;
			margin-bottom : 30px;
			padding-bottom : 5px;
			border: 1px solid #666666;
			position: relative;
			color: #666666;
            vertical-align:top;
			background-color: #f9f9f9;
            max-height :100px;
            min-height : 100px;
		}       

        </style>
        <script type="text/javascript">
            var message;
          
            function __beforeAddMail(tag) {
                var expression = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!tag.name.match(expression) && !__validateVariable(tag.name)) {
                    alert('La dirección de mail no es válida');
                    return false;
                }
                return true;
            }
        
            function __validateVariable(variable) {
                return variable.match(/^{{[a-z0-9._]+(\[[a-z0-9._]\]+)?}}$/i);
            }
         

            function getClearText( strSrc ) {
                    return  strSrc.replace( /<[^<|>]+?>/gi,'' );
            }

            function loadParameters() {
                message.parametros_extra = {
                    para: {
                    /*    pool: '',
                        lane: '1',
                        mail: '1',
                        xmpp: '',
                        userText: [],*/
                        mailText: [<%=cadena_mail%>]
                     /*   xmppText: []*/
                    },
                    cc: {
                       /* pool: '',
                        lane: '',
                        mail: '',
                        xmpp: '',
                        userText: [],*/
                        mailText: []
                    },
                    cco: {
                     /*   pool: '',
                        lane: '',
                        mail: '',
                        xmpp: '',
                        userText: [],*/
                        mailText: []
                    },
                    desde: '',
                    asunto: subject,
                    cuerpo: '',
                    archivosAdjuntos: ''
                };


                for (var names in message.parametros_extra) {
                    if (typeof (message.parametros_extra[names]) == 'object' && names != 'archivosAdjuntos') {
                        for (var name in message.parametros_extra[names]) {
                            if (typeof(message.parametros_extra[names][name]) != 'function') {
                                setValue(names + '_' + name, message.parametros_extra[names][name]);
                            }
                        }
                    } else {
                        if (typeof(message.parametros_extra[names]) != 'function') {
                            setValue(names, message.parametros_extra[names]);
                        }
                    }
                }

                //if (!message.parametros_extra['cuerpo']) {
                //    message.parametros_extra['cuerpo'] = '<p></p>';
                //}

                //CKEDITOR.instances.cuerpo.insertHtml(message.parametros_extra['cuerpo']);

            }

            function Aceptar() {
                $$('table.table tr.input input[id]').each(function(input) {
                    var id = input.getAttribute('id');
                    if (id) {
                        if (id.indexOf('_') != -1) {
                            var names = id.split('_');
                            message.parametros_extra[names[0]][names[1]] = getValue(input);
                        } else {
                            message.parametros_extra[id] = getValue(input);
                        }
                    }
                });
                $$('table tr.input .tagger').each(function(input) {
                    var id = input.getAttribute('id');
                    if (id) {
                        if (id.indexOf('_') != -1) {
                            var names = id.split('_');
                            message.parametros_extra[names[0]][names[1]] = getValue(input);
                        } else {
                            message.parametros_extra[id] = getValue(input);
                        }
                    }
                });

                //if (campos_defs.value("desde") == "")
                // {
                //    alert("Seleccione desde donde se enviará la notificación.")
                //    return
                // }

                //var html = CKEDITOR.instances.cuerpo.getSnapshot();
                //var dom=document.createElement("DIV");
                //dom.innerHTML=html;
                //var plain_text=(dom.textContent || dom.innerText);

                //message.parametros_extra['desde'] = campos_defs.value("desde")
                
                //message.parametros_extra['cuerpo'] = CKEDITOR.instances.observacion.getData(); // FCKeditorAPI.GetInstance('cuerpo').GetData();

                var _to = ""
                message.parametros_extra.para.mailText.each(function (arr) {
                    _to += arr.name + ";"
                });
                var _cc = ""
                message.parametros_extra.cc.mailText.each(function (arr) {
                    _cc += arr.name + ";"
                });
                var _cco = ""
                message.parametros_extra.cco.mailText.each(function (arr) {
                    _cco += arr.name + ";"
                });
                var body = $('body').innerHTML
                var subject = $('asunto').value
                

                nvFW.error_ajax_request('sendMail.aspx', {
                    parameters: { modo: "enviar", _to: _to, _cc: _cc,_cco:_cco,subject:subject,body:body,observacion: '',tipo_rechazo_call: tipo_rechazo_call,cuit: cuit },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0)
                            alert("El correo se envio correctamente.")
                    }
                });
              
            }

            function setValue(element, value) {
                
                if (element.tagName == undefined) {
                    var elementName = element;
                    element = $(element);
                }
                if (!element) {
                    //console.log(elementName)
                }
                if (element && element.tagName != undefined) {
                    switch (element.tagName.toUpperCase()) {
                        case 'SELECT':
                            var option = element.select('option[value="' + value + '"]');
                            if (option.length > 0) {
                                option[0].selected = true;
                            }
                            break;
                        case 'INPUT':
                            if (campos_defs.items[element.getAttribute('id')] != undefined) {
                                campos_defs.set_value(element.getAttribute('id'), value);
                            }
                            else
                            {
                            if (element.getAttribute('type') == 'checkbox') {
                                if (value == '1') {
                                    element.checked = true;
                                } else {
                                    element.checked = false;
                                }
                            } else {
                                element.value = value;
                            }
                            }
                            break;
                        case 'DIV'://es un campodef
                            if (element.hasClassName('tagger')) {
                                
                                element.setValue(value);
                                
                                //contenedores = $('tbCabe').querySelectorAll("span.remove")
                                //for (var i = 0; i < contenedores.length; i++) {
                                //    contenedores[i].style.display = false
                                //}

                            } else {
                                campos_defs.set_value(element.getAttribute('id') + '_cd', value);
                            }
                            break;
                        case 'TEXTAREA':
                            try {
                                element.update(value);
                            } catch (e) {
                                //IExplorer
                            }
                            break;
                    }
                }
            }

            function getValue(element) {
                if (element.tagName == undefined) {
                    element = $(element);
                }
                var value = null;
                switch (element.tagName.toUpperCase()) {
                    case 'SELECT':
                        element.select('option').each(function(option) {
                            if (option.selected) {
                                value = option.value;
                                throw $break;
                            }
                        });
                        break;
                    case 'TEXTAREA':
                    case 'INPUT':
                        if ($(element.getAttribute('id') + '_cd')) {
                            value = campos_defs.get_value(element.getAttribute('id'));
                        }
                        else {
                            if (element.getAttribute('type') == 'checkbox') {
                                if (element.up().select('input:checked').length > 0) {
                                    value = 1;
                                } else {
                                    value = 0;
                                }
                            } else {
                                value = element.value;
                            }
                        }
                        break;
                    case 'DIV':
                        if (element.hasClassName('tagger')) {
                            value = element.getValue();
                        } else {
                            value = campos_defs.get_value(element.getAttribute('id') + '_cd');
                        }
                        break;
//                    case 'TEXTAREA':
//                        value = element.value
//                        break;
                }
                return value;
            }
          
            var win = nvFW.getMyWindow()
            var subject = ''
            var tipo_rechazo_call = ''
            var cuit = 0

            function window_onload() {
                
                //$('observacion').observe('click', function (e) {
                //    if( e.srcElement.innerHTML == "Ingrese las observaciones que crea necesaria...")
                //      e.srcElement.innerHTML= ""
                //    });
                parametros = win.options.userData.parametros
                body = parametros['body']
                subject = parametros['subject']
                tipo_rechazo_call = parametros['tipo_rechazo_call']
                cuit = parametros['cuit']

                $('asunto').value = subject
                $('body').insert({ bottom: body })

                $$('#para_mailText, #cc_mailText, #cco_mailText').each(function(element) {
                    $(element).taggify({beforeAdd: __beforeAddMail});
                });
                
                message = {}

                // Nueva implementacion con CKEditor
                CKEDITOR.config.toolbar = [
                                            ['FitWindow', 'Source'],
                                            ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteWord', '-'],
                                            ['Undo', 'Redo', '-', 'SelectAll'],
                                            ['OrderedList', 'UnorderedList', '-', 'Outdent', 'Indent'],
                                            ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyFull'],
                                            ['Link', 'Unlink'],
                                            ['Style', 'FontFormat', 'FontName', 'FontSize', 'TextColor', 'BGColor']
                                          ];
                CKEDITOR.config.resize_enabled = false;

                CKEDITOR.on('instanceCreated', function (event) {

                    var editor = event.editor;
                       element = editor.element;
                 
                    // Customize editors for headers and tag list.
                    // These editors do not need features like smileys, templates, iframes etc.
                    //if (element.is('h1', 'h2', 'h3') || element.getAttribute('id') == 'taglist') {
                    //    // Customize the editor configuration on "configLoaded" event,
                    //    // which is fired after the configuration file loading and
                    //    // execution. This makes it possible to change the
                    //    // configuration before the editor initialization takes place.
                    //    editor.on('configLoaded', function () {

                    //        // Remove redundant plugins to make the editor simpler.
                    //        editor.config.removePlugins = 'colorbutton,find,flash,font,' +
                    //                'forms,iframe,image,newpage,removeformat,' +
                    //                'smiley,specialchar,stylescombo,templates';

                    //        // Rearrange the toolbar layout.
                    //        editor.config.toolbarGroups = [
                    //            { name: 'editing', groups: ['basicstyles', 'links'] },
                    //            { name: 'undo' },
                    //            { name: 'clipboard', groups: ['selection', 'clipboard'] },
                    //            { name: 'about' }
                    //        ];
                    //    });   
                    //}
                });

                var taggerUnderEdit = false;
                var ejecutar_onchange = false

                loadParameters()
                window_onresize()
                return true;
            }

            function window_onresize()
            {
                try {
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_height = $$('BODY')[0].getHeight()
                    var divMenu_height = $('divMenu').getHeight()
                    var cabe_height = $('tbCabe').getHeight()
                    var divCampDef_height = $('divCampDef').getHeight()

                    var alto = (body_height - divMenu_height - cabe_height - divCampDef_height - dif) //+ 'px'

                    $('body').setStyle({ height: alto })
                }
                catch (e) {console.log(e.message)}
            }

            function window_onunload() {
                
            }

        
        </script>
    </head>
    <body onload="return window_onload();" onresize="return window_onresize()" onunload="return window_onunload();" style="background-color:white; width: 100%;height: 100%;overflow: hidden;">
       <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
       <script type="text/javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenu = new tMenu('divMenu', 'vMenu');
         Menus["vMenu"] = vMenu
         Menus["vMenu"].alineacion = 'centro';
         Menus["vMenu"].estilo = 'A';
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>enviar_mail</icono><Desc>Enviar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         vMenu.loadImage("enviar_mail", '/fw/image/icons/enviar_mail.png')
         vMenu.MostrarMenu()
        </script> 
         <div id="divCampDef" class="campDef">
            <%= nvCampo_def.get_html_input("nro_operador")%>
        </div>
        <table class="tb1 table" id="tbCabe" style="width: 100%">
<%--            <tr class="div input">
                <td class="Tit1">Desde</td>
                <td style="width: 100%;" colspan="6">
                   <script type ="text/javascript">                          
                       campos_defs.add('desde', {
                           nro_campo_tipo: 1,
                           enDB: false,
                           filtroXML: nvFW.pageContents.FiltroXML_desde,
                           filtroWhere: "<id_transf_conf type='igual'>%campo_value%</id_transf_conf>"
                       })
                    
                       </script>

                </td>
            </tr>--%>
            <tr class="input">
                <td class="Tit1">Para</td>
                <td>
                    <div class="cont hCont">
                        <div id="para_mailText" class="variable">
                            <%= cadena_mail %>
                        </div>
                    </div>
                </td>
            </tr>
            <tr class="input">
                <td class="Tit1">CC</td>
                <td>
                    <div class="cont hCont">
                        <div id="cc_mailText" class="variable"></div>
                    </div>
                </td>
            </tr>
            <tr class="input">
                <td class="Tit1">CCO</td>
                <td>
                    <div class="cont hCont">
                        <div id="cco_mailText" class="variable"></div>
                    </div>
                </td>
            </tr>
            <tr class="input cont">
                <td class="Tit1">Asunto</td>
                <td colspan="5">
                    <input type="text" id="asunto" disabled="disabled"  class="variable" />
                </td>
            </tr>
       </table>
        <div id="body" contenteditable="false">
        </div>
    </body>
</html>