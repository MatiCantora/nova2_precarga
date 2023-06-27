<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%

    Dim clientData As String = nvFW.nvUtiles.obtenerValor("clientData", "")
    If (clientData <> "") Then 'Guardar
        Dim err As New tError()

        Dim req As New nvHTTPRequest()
        req.url = "https://novatest.improntasolutions.com/voii/ibs/cliente/scl_cliente_particular.aspx"
        req.Method = "POST"
        req.time_out = 5000
        req.ContentType = "application/json"
        'req.param_add("Cookie", "ASP.NET_SessionId=nfhzjs4fkz5yk0c3x5gzh3kh", typeParam.param_headers)
        'req.param_add("Cookie", "ASP.NET_SessionId=b2dps5wa1ellcuqjjtwd3crf", typeParam.param_headers)
        'ASP.NET_SessionId=b2dps5wa1ellcuqjjtwd3crf

        req.Body = clientData

        'Certificado de prueba
        Dim objCer = New System.Security.Cryptography.X509Certificates.X509Certificate2
        Dim listCert As New List(Of System.Security.Cryptography.X509Certificates.X509Certificate2)

        Try
            'codigo
            Dim fs As New System.IO.FileStream("D:\lcravero.pfx", System.IO.FileMode.Open)
            Dim binary_file(fs.Length - 1) As Byte
            fs.Read(binary_file, 0, fs.Length)
            fs.Close()

            'Definir que es la clave privada es presistente, sino la guarda temporalmente y luego la borra
            Dim KeyStorageFlags As System.Security.Cryptography.X509Certificates.X509KeyStorageFlags = System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable Or System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.PersistKeySet
            objCer.Import(rawData:=binary_file, password:="Jueves29.", keyStorageFlags:=KeyStorageFlags) '2 + 4 + 16

            listCert.Add(objCer)

        Catch ex As Exception
        End Try

        req.ClientCertificate = listCert
        'Certificado

        Try

            Stop

            Dim resp As System.Xml.XmlDocument = req.getResponseXML()
            Dim msjs As System.Xml.XmlNode = resp.SelectSingleNode("error_mensajes")
            If msjs IsNot Nothing Then
                'msjs.SelectSingleNode("error_mensaje")
                err.mensaje = nvXMLUtiles.getNodeText(msjs, "error_mensaje", "")
                err.numError = 100
            End If




        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = 106
            err.titulo = "Error en el guardado"
            err.mensaje = "Error al enviar los datos."
        End Try

        err.response()
    End If


    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)
    If tipdoc > 0 And nrodoc > 0 Then

        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc

    End If
    'Me.addPermisoGrupo("permisos_vinculos")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <title>Cliente ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    

    <style type="text/css">
        td.selected {
            background-color: #A0A0A0 !important; 
            color: black !important;
            border-right-color: #0066CC;
        }
        #container {
            width: 100%;
            height: 80%;
            overflow: hidden;
        }
        #container > div {
            height: 100%;
        }
        iframe {
            width: 100%;
            height:100%;
            border: none;
            overflow: auto;
        }
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        vMenuTabs = new tMenu('divMenuTabs', 'vMenuTabs');

        var winCliente = nvFW.getMyWindow();
        var tabs       = [];
        var frame      = {
            'datos':              { 'cargado': false, 'elemento': null, 'content': null },
            'domicilios':         { 'cargado': false, 'elemento': null, 'content': null },
            'telefonos':          { 'cargado': false, 'elemento': null, 'content': null },
            'actividadEconomica': { 'cargado': false, 'elemento': null, 'content': null }
        }

        var _action = "A"
        var _paiscod = 54
        var _bcocod = 312
        var _succod = 1

        function window_onload()
        {
            if (winCliente) {
                if (winCliente.options.userData == undefined)
                    winCliente.options.userData = {}

                winCliente.options.userData.hay_modificacion = false
            }
            
            if (nvFW.pageContents && nvFW.pageContents.tipdoc && nvFW.pageContents.nrodoc) {
                campos_defs.set_value("tipdoc", nvFW.pageContents.tipdoc)
                campos_defs.set_value("nrodoc", nvFW.pageContents.nrodoc)
                campos_defs.habilitar("tipdoc", false)
                campos_defs.habilitar("nrodoc", false)
                _action = "M"

                loadTabs()

                // Cargar "asíncronamente" los demás iFrames
                loadOtherFrames();
            }
            //--- Seteo de frames ---//
            // Datos
            frame.datos.elemento              = $('frame_datos');
            frame.datos.content               = $('content_datos');
            // Domicilios
            frame.domicilios.elemento         = $('frame_domicilios');
            frame.domicilios.content          = $('content_domicilios');
            // Teléfonos
            frame.telefonos.elemento          = $('frame_telefonos');
            frame.telefonos.content           = $('content_telefonos');
            // Actividad Económica
            frame.actividadEconomica.elemento = $('frame_actividadEconomica');
            frame.actividadEconomica.content  = $('content_actividadEconomica');

            mostrarDatos();
            window_onresize();
   
        }

        function loadTabs() {
            
            vMenuTabs.MostrarMenu();

            // Almacena en un array todas las TABS desde el menú para manipularlas
            var tdTabs = $$('#vMenuTabs td');

            if (tdTabs.length > 1) {
                var lastPosition = tdTabs.length - 1;

                tdTabs.each(function (td, pos) {
                    if (pos !== lastPosition)
                        tabs.push(td);
                });
            }
        }
        


        function window_onresize()
        {
            try
            {
                var bodyH              = $$('body')[0].getHeight();
                var divMenuABMClienteH = $('divMenuABMCliente').getHeight();
                var tbClienteH         = $('tbCliente').getHeight();
                var divMenuTabsH       = $('divMenuTabs').getHeight();

                $('container').setStyle({ height: (bodyH - divMenuABMClienteH - tbClienteH - divMenuTabsH - 3) + 'px' });
            }
            catch (e) {}
        }

        
        function hideFrames()
        {
            for (var item in frame) {
                frame[item].content.hide();
            }
        }


        function mostrarDatos()
        {
            selectThisTab(0);   // Seleccionar la primer TAB

            if (!frame.datos.cargado)
            {
                var srcStr = '/voii/clientes/cliente_abm_datos.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc
                frame.datos.elemento.src = srcStr
                frame.datos.cargado      = true;
            }

            hideFrames();
            frame.datos.content.show();
        }


        function mostrarDomicilios()
        {
            selectThisTab(1);   // Seleccionar la segunda TAB

            if (!frame.domicilios.cargado)
            {
                var srcStr = '/voii/clientes/cliente_abm_domicilios.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc
                frame.domicilios.elemento.src = srcStr
                frame.domicilios.cargado      = true;
            }

            hideFrames();
            frame.domicilios.content.show();
        }


        function mostrarTelefonos()
        {
            selectThisTab(2);   // Seleccionar la tercer TAB

            if (!frame.telefonos.cargado)
            {
                frame.telefonos.elemento.src = '/voii/clientes/cliente_abm_telefonos.aspx';
                frame.telefonos.cargado      = true;
            }

            hideFrames();
            frame.telefonos.content.show();
        }


        function mostrarActividadEconomica()
        {
            selectThisTab(3);   // Seleccionar la cuarta TAB

            if (!frame.actividadEconomica.cargado)
            {
                var srcStr = '/voii/clientes/cliente_abm_actividadEconomica.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc

                frame.actividadEconomica.elemento.src = srcStr;
                frame.actividadEconomica.cargado      = true;
            }

            hideFrames();
            frame.actividadEconomica.content.show();
        }


        function selectThisTab(tabPosition)
        {
            cleanTabSelected();
            selectTab(tabPosition);
        }


        function cleanTabSelected()
        {
            var tabSelected = $$('#vMenuTabs td.selected');

            if (tabSelected.length === 1)
                tabSelected[0].removeClassName('selected');
        }


        function selectTab(tabPosition)
        {
            if (tabPosition === null || tabPosition === undefined || !tabs.length) return;

            tabs[tabPosition].addClassName('selected');
        }


        // Función para cargar "asincronamente" el resto de los iframes (agregar los que falten...)
        function loadOtherFrames()
        {
            // Domicilios
            setTimeout(function () {
                var srcStr = '/voii/clientes/cliente_abm_domicilios.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc
                frame.domicilios.elemento.src = srcStr
                frame.domicilios.cargado      = true;
            }, 0);

            // Teléfonos
            setTimeout(function () {
                var srcStr = '/voii/clientes/cliente_abm_telefonos.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc
                frame.telefonos.elemento.src = srcStr;
                frame.telefonos.cargado      = true;
            }, 30);

            // Actividad económica
            setTimeout(function () {
                var srcStr = '/voii/clientes/cliente_abm_actividadEconomica.aspx'
                if (_action == "M")
                    srcStr += '?tipdoc=' + nvFW.pageContents.tipdoc + '&nrodoc=' + nvFW.pageContents.nrodoc + '&bcocod=' + _bcocod + '&paiscod=' + _paiscod
                frame.actividadEconomica.elemento.src = srcStr;
                frame.actividadEconomica.cargado      = true;
            }, 60);
        }

        function cliente_guardar() {
            var winDatos = ObtenerVentana("frame_datos")
            var datos = {}

            if (typeof (winDatos.getJsonData) === "function") {
                datos = winDatos.getJsonData()
            }

            //Validaciones
            var msj = ""
            if (datos.clinom == "")
                msj += "Ingrese el nombre.<br>"
            if (datos.cliape == "")
                msj += "Ingrese el apellido.<br>"
            if (datos.clifecnac == null)
                msj += "Ingrese la fecha de nacimiento.<br>"
            if (datos.profesion == null)
                msj += "Ingrese la profesion.<br>"
            if (datos.perconcod == null)
                msj += "Ingrese el perfil de consumo.<br>"
            if (datos.clicondgi == null)
                msj += "Ingrese la condición frente al IVA.<br>"
            if (datos.impgancod == null)
                msj += "Ingrese impuesto a las ganancias.<br>"
            if (datos.perfoper == null)
                msj += "Ingrese el perfil operativo.<br>"

            if (msj != "") {
                alert(msj)
                return false;
            }
            //Fin validaciones
            

            datos["action"] = _action;//"A";
            datos["paiscod"] = _paiscod;// 54;
            datos["bcocod"] = _bcocod;//312;
            datos["succod"] = _succod;//1;
            datos["tipdoc"] = campos_defs.get_value("tipdoc");//8;
            datos["nrodoc"] = campos_defs.get_value("nrodoc");//20259040329;
            datos["confirmar_cambios"] = true
            datos["ef"] = ""

            nvFW.error_ajax_request('/voii/ibs/cliente/scl_cliente_particular.aspx', {
                postBody: JSON.stringify(datos),
                contentType: "application/json",
                method: 'post',
                bloq_msg: "Guardando",
                onFailure: function (err, transport) { console.log(transport.responseText) },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        if (winCliente)
                            winCliente.options.userData.hay_modificacion = true   

                        if (_action == "A")
                            location.href += '?tipdoc=' + datos["tipdoc"] + '&nrodoc=' + datos["nrodoc"]
                    }

                },
                error_alert: true
            });

            
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <form action="cliente_abm.aspx" method="post" name="form1" target="frmEnviar" autocomplete="off" style="margin: 0; height: 100%">
        
        <div id="divMenuABMCliente"></div>
        <script type="text/javascript">
            var vMenuABMCliente = new tMenu('divMenuABMCliente', 'vMenuABMCliente');
            
            Menus["vMenuABMCliente"] = vMenuABMCliente;
            Menus["vMenuABMCliente"].alineacion = 'centro';
            Menus["vMenuABMCliente"].estilo     = 'A';
            
            Menus["vMenuABMCliente"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Clientes - Datos Básicos</Desc></MenuItem>");
            Menus["vMenuABMCliente"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>cliente_guardar()</Codigo></Ejecutar></Acciones></MenuItem>");
                
            Menus["vMenuABMCliente"].loadImage('guardar', '/FW/image/icons/guardar.png');
                
            vMenuABMCliente.MostrarMenu();
        </script>

        <table class="tb1" id="tbCliente">
            <tr>
                <td class="Tit1" >Cliente:</td>
                <%--<td style="width: 95%;" id="td_inputnro_entidad">
                    <input style="width: 100%; text-align: right" type="text" name="inputnro_entidad" id="inputnro_entidad" />
                </td>--%>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('tipdoc');
                    </script>
                </td>
                <td width="70%">
                    <script>
                        campos_defs.add('nrodoc', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
        </table>
                
        <div id="divMenuTabs" style="margin: 0; padding: 0;"></div>
        <script>
            vMenuTabs = new tMenu('divMenuTabs', 'vMenuTabs');
            Menus["vMenuTabs"] = vMenuTabs;
            Menus["vMenuTabs"].alineacion = 'centro';
            Menus["vMenuTabs"].estilo = 'A';

            Menus["vMenuTabs"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos del cliente</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarDatos()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuTabs"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Domicilios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarDomicilios()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuTabs"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Teléfonos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTelefonos()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuTabs"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Actividad económica</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarActividadEconomica(event)</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuTabs"].CargarMenuItemXML("<MenuItem id='4' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");

        </script>
        
        <div id="container">
            <div id="content_datos" style="display: none;">
                <iframe id="frame_datos" name="frame_datos"></iframe>
            </div>

            <div id="content_domicilios" style="display: none;">
                <iframe id="frame_domicilios" name="frame_domicilios"></iframe>
            </div>

            <div id="content_telefonos" style="display: none;">
                <iframe id="frame_telefonos" name="frame_telefonos"></iframe>
            </div>

            <div id="content_actividadEconomica" style="display: none;">
                <iframe id="frame_actividadEconomica" name="frame_actividadEconomica"></iframe>
            </div>
        </div>
    </form>
</body>
</html>
