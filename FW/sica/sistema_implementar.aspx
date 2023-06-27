<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")

    Dim cod_servidor As String = nvUtiles.obtenerValor("cod_servidor", "")
    Dim cod_sistema As String = nvUtiles.obtenerValor("cod_sistema", "")
    Dim port As String = nvUtiles.obtenerValor("port", "")

    Dim cod_sistema_version As String = nvUtiles.obtenerValor("cod_sistema_version", "")
    Dim desc_sistema_rol As String = ""


    If modo <> "" Then
        Select Case modo.ToUpper()

            Case "IMPLEMENTAR"
                Dim cod_modulo_versiones As String = nvUtiles.obtenerValor("cod_modulo_versiones")
                Dim cod_tipos As String = nvUtiles.obtenerValor("cod_tipos")
                Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
                Dim err As New tError

                ' chequear permisos 
                ' debe tener el permiso para implementar sistema
                If Not op.tienePermiso("permisos_sica", 7) AndAlso Not op.tienePermiso("permisos_servidor_" & cod_servidor & "_sistema_" & cod_sistema, 3) Then
                    err.numError = -1
                    err.mensaje = "No tiene permisos para implementar el sistema en este servidor"
                    err.response()
                    Return
                End If

                ' establecer la version de sistema 
                nvDBUtiles.DBExecute("UPDATE nv_servidor_sistemas SET cod_sistema_version=" & cod_sistema_version & " WHERE cod_servidor='" & cod_servidor & "' AND cod_sistema='" & cod_sistema & "'")

                ' cargar app
                Dim app As New nvFW.tnvApp
                app.loadFromDefinition(cod_servidor, cod_sistema, port)

                If (Application.Contents("nvRunningImplementations") Is Nothing) Then
                    Application.Contents("nvRunningImplementations") = New Dictionary(Of String, nvFW.tnvApp)
                End If

                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim nvRunningImplementations As Dictionary(Of String, nvFW.tnvApp) = Application.Contents("nvRunningImplementations")

                If nvRunningImplementations.ContainsKey(key) Then
                    Dim tApp As nvFW.tnvApp = nvRunningImplementations(key)

                    If Not tApp Is Nothing AndAlso tApp.sica_implementacion.thread.IsAlive Then
                        err.numError = -1
                        err.mensaje = "Existe una instalación o pasaje en curso"
                        err.response()
                    Else
                        nvRunningImplementations(key) = app
                    End If
                Else
                    nvRunningImplementations.Add(key, app)
                End If

                err = nvFW.nvSICA.Implementation.sistema_implementacion_iniciar(app, cod_modulo_versiones, cod_tipos)
                err.response()



            Case "CHECK_STATUS"
                Dim impl_res As String = nvUtiles.obtenerValor("impl_res", "0")
                Dim strXML As String = ""
                strXML = "<resultado><nvApp cod_sistema='" & cod_sistema & "' " &
                                           "cod_sistema_version='' " &
                                           "sistema='' " &
                                           "fe_inicio='' " &
                                           "fe_fin='' " &
                                           "pg_count='' " &
                                           "pg_pos='' " &
                                           "pi_count='' " &
                                           "pi_pos='' " &
                                           "elapseSeconds='' " &
                                           "total_count='0' " &
                                           "status='' " &
                                           "status_err_msg='' " &
                                           "progress_info=''>" &
                                    "</nvApp></resultado>"

                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim app As nvFW.tnvApp = Nothing

                Dim nvRunningImplementations As Dictionary(Of String, nvFW.tnvApp) = Application.Contents("nvRunningImplementations")

                If Not nvRunningImplementations Is Nothing Then
                    If nvRunningImplementations.ContainsKey(key) Then
                        app = Application.Contents("nvRunningImplementations")(key)
                    End If
                End If

                ' Si se pide el estado de la ultima implementacion, pero ha sido reemplazada
                ' por el estado del ultimo pasaje realizado, hay que devolver la respuesta vacia
                If Not app Is Nothing AndAlso Not app.sica_implementacion Is Nothing AndAlso app.sica_implementacion.cod_pasajes <> "" AndAlso impl_res = "1" Then
                    Response.ContentType = "text/xml"
                    Response.Write(strXML)
                    Response.End()
                End If

                If Not app Is Nothing AndAlso Not app.sica_implementacion Is Nothing Then
                    strXML = "<resultado><nvApp cod_sistema='" & app.cod_sistema & "' " &
                                               "cod_sistema_version='" & app.cod_sistema_version & "' " &
                                               "sistema='" & app.sistema & "' " &
                                               "fe_inicio='" & app.sica_implementacion.fe_inicio.ToString & "' " &
                                               "fe_fin='" & If(app.sica_implementacion.thread.IsAlive, "", app.sica_implementacion.fe_fin.ToString()) & "' " &
                                               "elapseSeconds='" & If(app.sica_implementacion.thread.IsAlive, "", DateDiff(DateInterval.Second, app.sica_implementacion.fe_inicio, app.sica_implementacion.fe_fin)) & "' " &
                                               "pg_count='" & app.sica_implementacion.pg_count & "' " &
                                               "pg_pos='" & app.sica_implementacion.pg_pos & "' " &
                                               "pi_count='" & app.sica_implementacion.pi_count & "' " &
                                               "pi_pos='" & app.sica_implementacion.pi_pos & "' " &
                                               "total_count='" & app.sica_implementacion.total_count & "' " &
                                               "status='" & app.sica_implementacion.status & "' " &
                                               "status_err_msg='" & nvXMLUtiles.escapeXMLAttribute(app.sica_implementacion.status_err_msg) & "' " &
                                               "progress_info='" & nvXMLUtiles.escapeXMLAttribute(app.sica_implementacion.progress_info) & "'>"

                    If Not app.sica_implementacion.thread.IsAlive Then
                        Dim strCodPasaje As String = ""
                        Dim extension As String

                        For i = 0 To app.sica_implementacion.elements.Count - 1
                            strCodPasaje = ""

                            If app.sica_implementacion.elements(i).cod_pasaje <> Nothing Then
                                strCodPasaje = "cod_pasaje='" & app.sica_implementacion.elements(i).cod_pasaje & "' "
                            End If

                            extension = System.IO.Path.GetExtension(app.sica_implementacion.elements(i).objeto)
                            strXML += "<resElement path='" & app.sica_implementacion.elements(i).path & "' " &
                                                  "objeto='" & app.sica_implementacion.elements(i).objeto & "' " &
                                                  "extension='" & extension & "' " &
                                                  "logInstallMsg='" & nvXMLUtiles.escapeXMLAttribute(app.sica_implementacion.elements(i).logInstallMsg) & "' " &
                                                  "cod_objeto='" & app.sica_implementacion.elements(i).cod_objeto & "' " &
                                                  "cod_obj_tipo='" & app.sica_implementacion.elements(i).cod_obj_tipo & "' " &
                                                  "cod_sub_tipo='" & app.sica_implementacion.elements(i).cod_sub_tipo & "' " &
                                                  "cod_modulo_version='" & app.sica_implementacion.elements(i).cod_modulo_version & "' " &
                                                  strCodPasaje & " />"
                        Next
                    End If

                    strXML += "</nvApp></resultado>"
                End If

                Response.ContentType = "text/xml"
                Response.Write(strXML)
                Response.End()



            Case "ABORTAR"
                Dim err As New tError
                Dim key As String = cod_servidor & "@" & cod_sistema & "@" & port
                Dim app As nvFW.tnvApp = Application.Contents("nvRunningImplementations")(key)
                err = nvFW.nvSICA.Implementation.sistema_implementacion_abortar(app)
                err.response()

        End Select
    End If


    Dim query As String = String.Format("SELECT cod_sistema_version, desc_sistema_rol FROM vernv_servidor_sistemas WHERE cod_servidor='{0}' AND cod_sistema='{1}'", cod_servidor, cod_sistema)
    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(query)

    If Not rs.EOF Then
        cod_sistema_version = isNUll(rs.Fields("cod_sistema_version").Value, "")
        desc_sistema_rol = rs.Fields("desc_sistema_rol").Value
    End If

    Me.contents("cod_servidor") = cod_servidor
    Me.contents("cod_sistema") = cod_sistema
    Me.contents("cod_sistema_version") = cod_sistema_version
    Me.contents("desc_sistema_rol") = desc_sistema_rol

    Me.contents("filtro_sistema_modulo_version") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_sistema_modulo_version'><campos>*</campos><filtro><cod_sistema_version type='igual'>%cod_sistema_version%</cod_sistema_version></filtro></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Implementar Sistema</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var winmod = nvFW.getMyWindow()

        var cod_servidor
        var cod_sistema
        var cod_sistema_version
        var port
        var log

        var interval
        var interval_time_ms = 1500;



        function window_onload()
        {
            cod_servidor         = nvFW.pageContents.cod_servidor;
            cod_sistema          = nvFW.pageContents.cod_sistema;
            cod_sistema_version  = nvFW.pageContents.cod_sistema_version;
            var desc_sistema_rol = nvFW.pageContents.desc_sistema_rol;

            loadMenu()
            
            $('divCodServidor').innerHTML = cod_servidor;
            $('divCodSistema').innerHTML  = cod_sistema + " (" + desc_sistema_rol + ")";

            if (cod_sistema_version)
            {
                campos_defs.set_value("cod_sistema_version", cod_sistema_version);
                loadModulos(cod_sistema_version);
            }

            campos_defs.items["port"]["onchange"] = function ()
            {
                port = campos_defs.get_value("port")

                if (port) {
                    checkStatus()
                }
            }

            campos_defs.items["cod_sistema_version"]["onchange"] = function ()
            {
                var cod_sistema_version = campos_defs.get_value("cod_sistema_version")
                loadModulos(cod_sistema_version)
            }

            if (!cod_sistema_version) {
                alert("No ha declarado una versión para este sistema")
            }

            window_onresize();
        }



        function loadModulos(cod_sistema_version)
        {
            var rs = new tRS()
            rs.async = true
            rs.onComplete = function ()
            {
                var strHML = ""

                while (!rs.eof())
                {
                    strHML += "<tr><td><input name='check_modulo_version' type='checkbox' checked='checked' value='" + rs.getdata("cod_modulo_version") + "'/>" + rs.getdata("modulo_nombre_version") + "</td></tr>"
                    rs.movenext()
                }

                if (strHML !== "") {
                    $('divModulos').innerHTML = "<table class='tb1 highlightEven highlightTROver'><tr class='tblabel'><td>Módulos</td></tr>" + strHML + "</table>"
                }
            }

            var parametros = "<criterio><params cod_sistema_version= '" + cod_sistema_version + "' /></criterio>"
            rs.open(nvFW.pageContents.filtro_sistema_modulo_version, '', '', '', parametros);
        }



        function checkStatus()
        {
            // simular accion de usuario cada vez que se actualiza la info de la instalacion
            // para evitar cierre de sesion por inactividad
            window.top.nvSesion.usuario_accion();

            var oXML = new tXML();
            oXML.async = true;
            oXML.onComplete = function (oXML)
            {
                var fe_inicio     = this.selectSingleNode("resultado/nvApp/@fe_inicio").nodeValue;
                var fe_fin        = this.selectSingleNode("resultado/nvApp/@fe_fin").nodeValue;
                
                // Re-armar la información para mostrarla como una consola de comandos
                var progress_info = this.selectSingleNode("resultado/nvApp/@progress_info").nodeValue
                var info_split    = progress_info.split('<br/>');
                progress_info = '';

                for (var i = 0; i < info_split.length; i++)
                {
                    if (info_split[i].trim() !== "...")
                        progress_info += '> ' + info_split[i] + '<br/>';
                }

                
                if (fe_inicio !== "" && fe_fin !== "")
                {
                    var status_err_msg = this.selectSingleNode("resultado/nvApp/@status_err_msg").nodeValue;
                    var elapseSeconds  = this.selectSingleNode("resultado/nvApp/@elapseSeconds").nodeValue;
                    var total_count    = this.selectSingleNode("resultado/nvApp/@total_count").nodeValue;

                    if (status_err_msg !== "") {
                        alert("El proceso finalizó debido a un error: " + status_err_msg, { title: '<b>Error</b>'} );
                    }

                    $("btnAbortar").hide();
                    $("btnImplementar").show();

                    window.clearInterval(interval);
                    campos_defs.habilitar("port", true);

                    $("divStatus").innerHTML = "> Tiempo de ejecucion " + elapseSeconds + " segundos (" + total_count + " objetos)";
                    $("divStatusMessages").innerHTML = progress_info;

                    showLogMsgs(this);
                    return;
                }

                if (fe_inicio !== "" && fe_fin === "")
                {
                    var pg_count = this.selectSingleNode("resultado/nvApp/@pg_count").nodeValue;
                    var pg_pos   = this.selectSingleNode("resultado/nvApp/@pg_pos").nodeValue;
                    var pi_count = this.selectSingleNode("resultado/nvApp/@pi_count").nodeValue;
                    var pi_pos   = this.selectSingleNode("resultado/nvApp/@pi_pos").nodeValue;

                    $("btnImplementar").hide();
                    $("btnAbortar").show();

                    $("divStatus").innerHTML = "> Ejecutando (Etapa " + pg_pos + " de " + pg_count + ")(objeto " + pi_pos + " de " + pi_count + ")";
                    $("divStatusMessages").innerHTML = progress_info;

                    // Cuando se cierra la ventana y se vuelve a abrir, y hay un proceso activo, reactivar el timer
                    if (!interval) {
                        interval = window.setInterval("checkStatus()", interval_time_ms);
                    }

                    showLogMsgs(this);
                    return;
                }

                if (fe_inicio === "")
                {
                    $("btnAbortar").hide();
                    $("btnImplementar").show();
                    $("divStatus").innerHTML = "";
                    $("divLogMsgs").src = "";
                }
            }

            oXML.load("sistema_implementar.aspx?modo=CHECK_STATUS&cod_servidor=" + cod_servidor + "&cod_sistema=" + cod_sistema + "&port=" + port + "&impl_res=1");
        }



        function showLogMsgs(oXML)
        {
            // mostrar mensajes log
            var elements = oXML.selectNodes("resultado/nvApp/resElement")
            var strHTML = ""

            var objeto
            var path0
            var cod_obj_tipo
            var logInstallMsg
            var tipo

            for (var i = 0; i < elements.length; i++)
            {
                objeto        = elements[i].getAttribute("objeto")
                path0         = elements[i].getAttribute("path")
                cod_obj_tipo  = elements[i].getAttribute("cod_obj_tipo")
                logInstallMsg = elements[i].getAttribute("logInstallMsg")

                switch (parseInt(cod_obj_tipo))
                {
                    // Objetos simples
                    case 1: tipo = "Tabla"; break;
                    case 2: tipo = "Vista"; break
                    case 3: tipo = "SP"; break;
                    case 4: tipo = "Directorio"; break;
                    case 5: tipo = "Archivo"; break;
                    case 6: tipo = "Funcion"; break;
                    case 8: tipo = "Datos"; break;
                    // Objetos complejos
                    case 7: tipo = "Transferencia"; break;
                    case 9: tipo = "Permiso Grupo"; break;
                    case 10: tipo = "Grupo"; break;
                    case 11: tipo = "Script DB"; break;
                    case 12: tipo = "Pizarra"; break;
                    case 13: tipo = "Parámetro"; break;
                }

                strHTML += "<tr><td>" + objeto + "</td><td>" + path0 + "</td><td>" + tipo + "</td><td>" + logInstallMsg + "</td></tr>"
            }

            if (strHTML !== "") {
                $('divLogMsgs').innerHTML = "<table class='tb1'><tr class='tbLabel'><td>Objeto</td><td>Path</td><td>Tipo</td><td>Mensaje</td></tr>" + strHTML + "</table>";
            }
        }



        var vMenu
        
        
        
        function loadMenu()
        {
            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align:center;vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Establecer Versión</Desc></MenuItem>");
            vMenu.MostrarMenu();
        }



        function cancelar()
        {
            winmod.close();
        }



        function abortar()
        {
            nvFW.error_ajax_request('sistema_implementar.aspx',
            {
                parameters:
                {
                    cod_servidor: cod_servidor,
                    cod_sistema:  cod_sistema,
                    port:         port,
                    modo:         "ABORTAR"
                },
                onSuccess: function (err)
                {
                    if (err.numError === 0)
                    {
                        $("btnAbortar").hide();
                        $("btnImplementar").show();

                        campos_defs.habilitar("port", true);
                        window.clearInterval(interval);
                        
                        $("divStatus").innerHTML += "<br/>> Proceso abortado.";
                    }
                    else
                    {
                        alert("No se pudo abortar el proceso");
                    }
                }
            });
        }



        function implementar()
        {
            // Modulos //////////////////////////
            var modulo_versiones = [];
            var checks = $$("input[name=check_modulo_version][type=checkbox]:checked"); // obtener todos los input chequeados, asi evitamos traer todos y recorrerlos
            
            if (!checks.length)
            {
                alert("Seleccione al menos un módulo para ser instalado", { title: '<b>Error</b>' });
                return;
            }
            
            for (var i = 0; i < checks.length; i++) {
                modulo_versiones.push(checks[i].value);
            }

            var cod_modulo_versiones = modulo_versiones.join(",");


            // Objetos //////////////////////////
            var checks_tipos_objeto = $$('input[type=checkbox][name=check_tipo_objeto]:checked');
            var tipo_objetos = [];
            
            if (!checks_tipos_objeto.length)
            {
                alert("Seleccione al menos un tipo de objeto a instalar", { title: '<b>Error</b>' });
                return;
            }

            for (var i = 0; i < checks_tipos_objeto.length; i++) {
                tipo_objetos.push(checks_tipos_objeto[i].value);
            }

            var cod_tipos = tipo_objetos.join(",")


            nvFW.error_ajax_request('sistema_implementar.aspx',
            {
                parameters:
                {
                    cod_servidor:         cod_servidor,
                    cod_sistema:          cod_sistema,
                    cod_sistema_version:  cod_sistema_version,
                    port:                 port,
                    cod_tipos:            cod_tipos,
                    cod_modulo_versiones: cod_modulo_versiones,
                    modo:                 "IMPLEMENTAR"
                },
                onSuccess: function (err)
                {
                    if (err.numError === 0)
                    {
                        $("btnImplementar").hide();
                        $("btnAbortar").show();

                        $('divLogMsgs').innerHTML = "";
                        $("divStatus").innerHTML = "> Ejecutando...";
                        $("divStatusMessages").innerHTML = "";
                        
                        campos_defs.habilitar("port", false);
                        interval = window.setInterval("checkStatus()", interval_time_ms);
                    }
                },
                onFailure: function (err)
                {
                    alert(err.mensaje, { title: '<b>' + err.title + '</b>' });
                },
                bloq_msg: 'Implementando...',
                error_alert: false
            });
        }



        function confirmImplementar()
        {
            cod_sistema_version = campos_defs.get_value('cod_sistema_version');
            port                = campos_defs.get_value('port');

            if (!cod_sistema_version)
            {
                alert("Seleccione la versión de sistema que desea implementar", { title: '<b>Error</b>' });
                return;
            }

            if (!port)
            {
                alert("Seleccione el puerto. Es necesario para conocer el path donde se instalaran los archivos del sistema a implementar", { title: '<b>Error</b>' });
                return;
            }

            var msg = '¿Está seguro que desea continuar e implementar el sistema <b>' + cod_sistema + '</b>? Tenga en cuenta que los archivos y objetos de base de datos, a excepcion de las tablas, ' +
                        'serán sobreescritos si ya existen en la base de datos destino.';

            nvFW.confirm(msg,
            {
                title: '<b>Confirmar implementación</b>',
                width: 570,
                height: 110,
                onOk: function (win)
                {
                    implementar();
                    win.close();
                },
                onCancel: function (win)
                {
                    win.close();
                },
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar'
            });
        }



        function window_onresize()
        {
            try
            {
                var body_h       = $$('body')[0].getHeight();
                var divMenu_h    = $('divMenu').getHeight();
                var tbFiltros_h  = $('tbFiltros').getHeight();
                var divConsole_h = $('divConsole').getHeight();
                var h            = body_h - (divMenu_h + tbFiltros_h + divConsole_h);

                $('divModulosObjetos').setStyle({ height: h + 'px' });
            }
            catch (e) {}
        }



        function checkAll(event, checks_complejos)
        {
            var checked_status = event.target.checked;
            var selector = checks_complejos ? '#tdComplejos ' : '#tdSimples ';
            selector += 'input[type=checkbox][name=check_tipo_objeto]';

            $$(selector).each(function (item)
            {
                item.checked = checked_status;
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenu" style="width: 100%"></div>
    
    <table class="tb1" id="tbFiltros">
        <tr>
            <td class='tit1'>Servidor</td>
            <td class='tit1'>Sistema</td>
            <td class='tit1'>Versión del Sistema</td>
            <td class='tit1'>Puerto</td>
            <td class="tit1"></td>
        </tr>
        <tr>
            <td>
                <div id='divCodServidor'></div>
            </td>
            <td>
                <div id='divCodSistema'></div>
            </td>
            <td>
                <% = nvCampo_def.get_html_input("cod_sistema_version", enDB:=False, filtroXML:="<criterio><select vista='verNv_sistema_version'><campos>cod_sistema_version as id, sistema_nombre_version as [campo]</campos><filtro><cod_sistema type='igual'>'" & cod_sistema & "'</cod_sistema></filtro><orden>id</orden></select></criterio>") %>
            </td>
            <td>
                <% = nvCampo_def.get_html_input("port", enDB:=False, filtroXML:="<criterio><select vista='nv_servidor_ports'><campos>distinct port_https as id, port_https as campo</campos><filtro><cod_servidor type='igual'>'" & cod_servidor & "'</cod_servidor></filtro></select></criterio>") %>
            </td>
            <td>
                <div>
                    <input style="width: 100%; cursor: pointer" type="button" value="Implementar" onclick="confirmImplementar()" id='btnImplementar' />
                    <input style="width: 100%; cursor: pointer; display: none" type="button" value="Abortar" onclick="abortar()" id="btnAbortar" />
                </div>
            </td>
        </tr>
    </table>

    <div id="divModulosObjetos">
        <table class='tb1'>
            <tr>
                <td style="width: 50%; vertical-align: top">
                    <div style="width: 100%; text-align: center" id='divModulos'></div>
                </td>
                <td style="width: 50%">
                    <div style="float: left; width: 100%; text-align: center">
                        <table id="options" class="tb1">
                            <tr class='tblabel'>
                                <td colspan="2">Objetos</td>
                            </tr>
                            <tr>
                                <td class="Tit1" style="text-align: center;">
                                    <input type="checkbox" name="check_all_complejos" id="check_all_complejos" onclick="checkAll(event, true)" style="float: left;" title="Seleccionar todo" /> Complejos
                                </td>
                                <td class="Tit1" style="text-align: center;">
                                    <input type="checkbox" name="check_all_simples" id="check_all_simples" onclick="checkAll(event, false)" style="float: left;" title="Seleccionar todo" /> Simples
                                </td>
                            </tr>
                            <tr>
                                <td id="tdComplejos" style="vertical-align: top;">
                                    <table class="tb1 highlightEven highlightTROver">
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="10" />Grupos
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="13" />Parámetros
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="9" />Permisos Grupo
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="12" />Pizarras
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="11" />Scripts DB
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="7" />Transferencias
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td id="tdSimples" style="vertical-align: top;">
                                    <table class="tb1 highlightEven highlightTROver">
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="5" />Archivos
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="4" />Directorios
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="1" />Tablas
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="2" />Vistas
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="6" />Funciones
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="3" />SP's
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <input type='checkbox' name="check_tipo_objeto" value="8" />Datos
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
    </div>

    <div id="divConsole" style="height: 250px; font-family: monospace; background-color: #3F3F3F; color: #FFFFFF;">
        <div id='divStatusDummy' style="padding: 10px;">>>> Consola para estado de implementación del Sistema <b><% = cod_sistema %></b> >>></div>
        <div id='divStatus' style="padding: 10px;">&nbsp;</div>
        <div id='divStatusMessages' style="padding: 10px;">&nbsp;</div>
        <div id='divLogMsgs' style="padding: 10px;">&nbsp;</div>
    </div>
</body>
</html>