<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>

<%

    Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
    Me.contents("nro_entidad") = nro_entidad

    Me.contents("filtroEntidad_funciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidad_funciones'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroCargarCertificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Esquema_firma'><campos>id_esquema,nro_entidad,strXML,nombreEsquema</campos><orden></orden><filtro></filtro></select></criterio>")

    Dim strXML = nvUtiles.obtenerValor("strXML", "")
    Dim modo = nvUtiles.obtenerValor("modo", "")

    Dim Err = New tError()

    If modo.ToUpper() = "M" Then

        Try

            Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
            objXML.LoadXml(strXML)
            Dim NODS = objXML.SelectNodes("/esquemas/esquema")

            For i As Integer = 0 To NODS.Count - 1
                Dim nod = NODS(i)
                Dim id_esquema = nod.Attributes("id_esquema").Value

                Dim rs = nvFW.nvDBUtiles.DBExecute("Delete from Esquema_firma where nro_entidad='" + nro_entidad + "' AND id_esquema='" + id_esquema + "'")
            Next

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error guardar el esquema de firma."
            Err.mensaje = "Error guardar el esquema de firma."
            Err.debug_src = "pki_esquema_firma.aspx"

        End Try
        Err.salida_tipo = "adjunto"
        Err.response()

    End If

%>
<html>
<head>
    <title>PKI Cert ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()
        var nro_entidad = nvFW.pageContents.nro_entidad;

        function window_onload() {
            mostrar_tabla_esquema()
        }

        function window_onresize() {
            try {

            }
            catch (e) { }
        }

        function mostrar_tabla_esquema() {
            
            div_esquema = new tTable();

            //Nombre de la tabla y id de la variable
            div_esquema.nombreTabla = "div_esquema";
            //Agregamos consulta XML
            div_esquema.filtroXML = nvFW.pageContents.filtroCargarCertificados
            div_esquema.filtroWhere = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>";


            div_esquema.cabeceras = ["Nombre Esquema", "Id Esquema"];

            div_esquema.async = true;
            div_esquema.editable = false;
            div_esquema.agregar_espacios_en_blanco_dir = function () {
                esquema_nuevo(nro_entidad)
            }
            div_esquema.modificar_fila = function (fila) {
                modificar_esquema(fila)
            }

            div_esquema.camposHide = [{ nombreCampo: "strXML"}]

            div_esquema.campos = [
             {
                 nombreCampo: "nombreEsquema", get_html: function (campo, nombre, fila)
                 {
                     debugger
                     var strEsquema = div_esquema.getFila(campo.fila)["strXML"]
                     var valorCelda = "<a onclick='modificar_esquema(" + campo.fila + ")'>" + "<b>" + fila[0].valor + ": </b>" + prefijo_a_infijo(strEsquema) + "</a>"
                     div_esquema.data[campo.fila]["strXML"] = ""
                     return valorCelda
                 }
             },
             {
                 nombreCampo: "id_esquema", nro_campo_tipo: 104, ordenable: false, width: "10%", style: { 'textAlign': 'center' }
             }

            ];

            div_esquema.table_load_html();
        }

        function modificar_esquema(fila) {
            id_esquema = div_esquema.getFila(fila)["id_esquema"];
            var nombreEsquema = div_esquema.getFila(fila)["nombreEsquema"];
            

            nvFW.bloqueo_activar($("div_esquema"), 'cargando-esquemas');
            var win2 =
                window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: 'pki_esquema_firma.aspx?subesquema=false' + "&nro_entidad=" + nro_entidad + "&id_esquema=" + id_esquema + "&nombreEsquema=" + nombreEsquema + "&modificando=true",
                    title: '<b>Modificar Esquema</b>',
                    width: 1000,
                    height: 500,
                    destroyOnClose: true,
                    onClose: function () {
                        nvFW.bloqueo_desactivar($("div_esquema"), 'cargando-esquemas');
                        div_esquema.refresh();
                    }
                });

            win2.options.data = {};
            win2.showCenter();
        }

        function esquema_nuevo(nro_entidad) {

            var win2 =
                window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: 'pki_esquema_firma.aspx?subesquema=false' + "&nro_entidad=" + nro_entidad,
                    title: '<b>Nuevo Esquema</b>',
                    width: 1000,
                    height: 500,
                    destroyOnClose: true,
                    onClose: function () { div_esquema.refresh(); }
                });

            win2.options.data = {};
            win2.showCenter();
        }


        function guardar() {
            var str = "<esquemas>"
            str += div_esquema.generarXML("esquema")
            str += "</esquemas>"

            nvFW.error_ajax_request('pki_esquemas_de_firmas.aspx', {
                parameters: {
                    modo: "M",
                    nro_entidad: nro_entidad,
                    strXML: str
                },
                onSuccess: function (err, transport) { }
            });

        }

        var funciones_lista = [];
        function prefijo_a_infijo(strXML2) {
        /*    if (!strXML2)
                return;*/

            var oXML = new tXML();
            oXML.loadXML(strXML2);

            var resultado = "";
           
            resultado += "(";

            if (funciones_lista.length === 0) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroEntidad_funciones);
                
                while (!rs.eof()) {
                    funciones_lista[rs.getdata("nro_funcion")] = rs.getdata("funcion");
                    rs.movenext();
                }
            }
            
            if (oXML.xml.firstChild)
                for (var i = 0; selectNodes("funcion", oXML.xml.firstChild).length > i; i++) {
                    var nodo = selectNodes("funcion", oXML.xml.firstChild)[i];
                    var minimo = selectNodes("minimo",nodo)[0].firstChild.data
                    var tipo = selectNodes("tipo", nodo)[0].firstChild.data

                    if (tipo == "funcion") {
                        resultado += funciones_lista[selectNodes("contenido", nodo)[0].firstChild.data] + "(" + minimo + ")";
                    }
                    else if (tipo == "grupo") {
                        resultado += prefijo_a_infijo(XMLtoString(nodo.firstChild.firstChild))
                    }
                    else {
                        resultado += "Esquema ID: " + selectNodes("contenido", nodo)[0].firstChild.data
                    }

                    if (selectNodes("funcion", oXML.xml.firstChild).length - 1 > i)
                        resultado += " " + oXML.xml.firstChild.nodeName + " "
                }

            resultado += ")";
            
            return resultado;
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <div id="divMenuABM_pki_esquema"></div>
    <script type="text/javascript">

        var vMenuABM_pki_esquemas = new tMenu('divMenuABM_pki_esquema', 'vMenuABM_pki_esquemas');
        Menus["vMenuABM_pki_esquemas"] = vMenuABM_pki_esquemas
        Menus["vMenuABM_pki_esquemas"].alineacion = 'centro';
        Menus["vMenuABM_pki_esquemas"].estilo = 'A';
        Menus["vMenuABM_pki_esquemas"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Esquemas</Desc></MenuItem>")
        Menus["vMenuABM_pki_esquemas"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

        Menus["vMenuABM_pki_esquemas"].loadImage("guardar", "/FW/image/icons/guardar.png")
        vMenuABM_pki_esquemas.MostrarMenu()

    </script>

    <div id="div_esquema"></div>

</body>
</html>