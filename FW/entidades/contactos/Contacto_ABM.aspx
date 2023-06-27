<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim numError = 0
    Dim modo = nvUtiles.obtenerValor("modo", "")
    Dim nro_docu = nvUtiles.obtenerValor("nro_docu", "")
    Dim tipo_docu = nvUtiles.obtenerValor("tipo_docu", "")
    Dim sexo = nvUtiles.obtenerValor("sexo", "")
    Dim isModal = nvUtiles.obtenerValor("isModal", "")
    'Dim nombreFiltroContactoDomicilio = nvFW.nvUtiles.obtenerValor("nombreFiltroContactoDomicilio", "")
    'Dim nombreFiltroContactoTelefono = nvFW.nvUtiles.obtenerValor("nombreFiltroContactoTelefono", "")
    'Dim nombreFiltroContactoEmail = nvFW.nvUtiles.obtenerValor("nombreFiltroContactoEmail", "")
    Dim nombreFiltroContactoGenerico = nvFW.nvUtiles.obtenerValor("nombreFiltroContactoGenerico", "")
    Dim nro_id_tipo As Integer = nvFW.nvUtiles.obtenerValor("nro_id_tipo", 1)

    Dim id_tipo = nvUtiles.obtenerValor("id_tipo", "") 'cambiar por id_tipo

    If id_tipo = "" Then
        id_tipo = nvUtiles.obtenerValor("nro_entidad", "")
    End If

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador

    If ((modo <> "") And (modo <> "C")) Then

        Dim Err As New nvFW.tError()

        Try

            Dim contactos_xml As String = nvFW.nvUtiles.obtenerValor("contactos_xml", "")
            'If (op.tienePermiso("permisos_contactos", 1)) Then

            Dim cmd1 As New nvFW.nvDBUtiles.tnvDBCommand("rm_contacto_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)

            Dim BinaryData() As Byte
            BinaryData = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(contactos_xml)

            cmd1.Parameters.Append(cmd1.CreateParameter("@strXML0", 205, 1, BinaryData.Length, BinaryData))
            cmd1.Parameters.Append(cmd1.CreateParameter("@id_tipo", 3, 1, 1, id_tipo))
            cmd1.Parameters.Append(cmd1.CreateParameter("@nro_id_tipo", 3, 1, 1, nro_id_tipo))

            Dim rs1 As ADODB.Recordset = cmd1.Execute()

            Err.numError = rs1.Fields("numError").Value
            Err.titulo = rs1.Fields("titulo").Value
            Err.mensaje = rs1.Fields("mensaje").Value

            nvFW.nvDBUtiles.DBCloseRecordset(rs1)
            'End If

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar Contacto"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "Contacto_ABM.aspx"
        End Try

        Err.response()
    End If




    'filtros encriptados
    Me.contents("filtroContactoGenerico") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verContacto_generico'><campos>" + IIf(modo = "", "''", modo) + " as modo, dbo.rm_tiene_permiso('permisos_tipos_contacto', (SELECT nro_permiso FROM operador_permiso_detalle WHERE permitir = desc_contacto_tipo + ' (editar)')) as permiso_editar, *</campos><filtro></filtro><orden>predeterminado desc</orden></select></criterio>")
    Me.contents("filtro_contacto_grupos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='contacto_grupos'><campos>nro_contacto_grupo, contacto_grupo</campos><filtro></filtro><orden>contacto_grupo</orden></select></criterio>")

    Me.contents("nro_operador") = nro_operador
    Me.contents("nro_id_tipo") = nro_id_tipo
    Me.contents("id_tipo") = id_tipo
    'Me.contents("nombreFiltroContactoDomicilio") = nombreFiltroContactoDomicilio
    'Me.contents("nombreFiltroContactoTelefono") = nombreFiltroContactoTelefono
    'Me.contents("nombreFiltroContactoEmail") = nombreFiltroContactoEmail
    Me.contents("nombreFiltroContactoGenerico") = nombreFiltroContactoGenerico

    Me.addPermisoGrupo("permisos_contactos")

%>
<html>
<head>
    <title>ABM Contactos</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 400, height: 150, okLabel: "cerrar" }); }
        var nro_id_tipo = nvFW.pageContents.nro_id_tipo

        //var vButtonItems = new Array();

        //vButtonItems[0] = {};
        //vButtonItems[0]["nombre"] = "Nuevo";
        //vButtonItems[0]["etiqueta"] = "Nuevo";
        //vButtonItems[0]["imagen"] = "nueva";
        //vButtonItems[0]["onclick"] = "return ABMContacto_tipo()";

        //var vListButton = new tListButton(vButtonItems, 'vListButton');
        //vListButton.loadImage("nueva", '/FW/image/comentario/nueva.png')

        var Contactos = {};
        var strHTML = ""
        var id_tipo = nvFW.pageContents.id_tipo;
        var calle_o = ""
        var numero_o = ""
        var piso_o = ""
        var depto_o = ""
        var resto_o = ""
        var postal_o = ""
        var telefono_o = ""
        var isModal
        var modo = '<%= modo %>'
        var nro_docu = '<%= nro_docu %>'
        var tipo_docu = '<%= tipo_docu %>'
        var sexo = '<%= sexo %>'
        var fecha = new Date();
        var nro_operador = nvFW.pageContents.nro_operador;

        var indiceEmailPredeterminado;
        var indiceTelefonoPredeterminado;
        var indiceDomicilioPredeterminado;

        var contactosExternos = [];


        function window_onload() {
            //vListButton.MostrarListButton()
            
            if (typeof parent.contactosExternos != 'undefined')
                contactosExternos = parent.contactosExternos;

            if (id_tipo == "") {

                if (parent.nro_entidad)  // ** esta en un iframe
                {
                    id_tipo = parent.nro_entidad
                    $('id_tipo').value = id_tipo

                    $('divAceptar').style.display = 'none'
                    $('divAceptar').hide();
                    $('tb_button').hide();

                } else {
                    $('menuItem_divMenuContactos_3').hide();
                }

                $('divAceptar').style.display = 'none'
                $('divAceptar').hide();
                $('tb_button').hide();

            } else {
                $('divAceptar').hide();
                $('tb_button').hide();
            }

            get_contacto_grupos()

            window_onresize()
        }


        function frameCargar(contacto_tipo, filtroTipos) {

            switch (contacto_tipo) {
                case "domicilio":
                    contactos_cargar("<nro_contacto_grupo type='igual'>1</nro_contacto_grupo>");
                    break;
                case "telefono":
                    contactos_cargar("<nro_contacto_grupo type='igual'>2</nro_contacto_grupo>");
                    break;
                case "email":
                    contactos_cargar("<nro_contacto_grupo type='igual'>3</nro_contacto_grupo>");
                    break
                default:
                    contactos_cargar(filtroTipos);
                    break;
            }
        }

        /*****************************************************/
        /*************** CONTACTO DE DOMICILIO ***************/
        /*****************************************************/


        function Domicilio_Eliminar(indice, id_domicilio) {

            if (nvFW.tienePermiso('permisos_contactos', 2)) {
                nvFW.confirm("¿Desea borrar el Domicilio seleccionado?", {
                    width: 300,
                    //className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    cancel: function (winConfirm) { winConfirm.close(); return },
                    ok: function (winConfirm) {

                        if (Contactos["domicilio"][indice]["predeterminado"] == 'True') {
                            alert('No puede eliminar el domicilio, se encuentra como Predeterminado')
                        }
                        else {

                            var xmldato = ""
                            xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                            xmldato += "<contactos>"
                            xmldato += "<domicilios>"

                            xmldato += "<domicilio id_domicilio='" + (id_domicilio * -1) + "'>"
                            xmldato += "<calle></calle>"
                            xmldato += "</domicilio>"

                            xmldato += "</domicilios>"

                            xmldato += "<telefonos>"
                            xmldato += "</telefonos>"

                            xmldato += "<horarios>"
                            xmldato += "</horarios>"

                            xmldato += "<emails>"
                            xmldato += "</emails>"

                            xmldato += "</contactos>"

                            nvFW.error_ajax_request('contacto_ABM.aspx', {
                                parameters: {
                                    modo: 'E',
                                    contactos_xml: xmldato,
                                    id_tipo: id_tipo,
                                    nro_id_tipo: nro_id_tipo
                                },
                                onSuccess: function (err, transport) {

                                    Domicilio_Actualizar_return();

                                },
                                onFailure: function (err) {

                                    if (typeof err == 'object') {
                                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                                    }
                                },
                                error_alert: false,
                                bloq_msg: "Guardando..."
                            });
                        }
                        winConfirm.close()
                    }
                });
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }

        function Domicilio_Actualizar(indice, id_domicilio) {

            if (nvFW.tienePermiso('permisos_contactos', 1)) {
                win = parent.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/entidades/contactos/Contacto_Generico_ABM.aspx?indice=' + indice + "&id_contact=" + id_domicilio + "&id_tipo=" + id_tipo + '&nro_id_tipo=' + nro_id_tipo + '&nro_contacto_grupo=1',
                    title: '<b>ABM Contactos</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    width: 660,
                    height: 325,
                    onClose: function (win) {
                        if (win.options.userData.modificacion) {

                            Domicilio_Actualizar_return(indice);
                        }
                    },
                    destroyOnClose: true
                });

                win.options.userData = { Contactos: Contactos }
                win.showCenter(true)
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }

        function Domicilio_Actualizar_return(indice) {

            contactos_cargar(filto_tiposCheck)

        }


        /*****************************************************/
        /*************** CONTACTO DE TELÉFONOS ***************/
        /*****************************************************/


        function Telefono_Eliminar(indice, id_telefono) {

            if (nvFW.tienePermiso('permisos_contactos', 2)) {
                nvFW.confirm("¿Desea borrar el Telefono seleccionado?", {
                    width: 300,
                    //className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    cancel: function (winConfirm) { winConfirm.close(); return },
                    ok: function (winConfirm) {

                        if (Contactos["telefono"][indice]["predeterminado"] == 'True') {
                            alert('No puede eliminar el telefono, se encuentra como Predeterminado')
                        }
                        else {

                            var xmldato = ""
                            xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                            xmldato += "<contactos>"
                            xmldato += "<domicilios>"
                            xmldato += "</domicilios>"

                            xmldato += "<telefonos>"

                            xmldato += "<telefono id_telefono ='" + (id_telefono * -1) + "'/>"

                            xmldato += "</telefonos>"

                            xmldato += "<horarios>"
                            xmldato += "</horarios>"

                            xmldato += "<emails>"
                            xmldato += "</emails>"

                            xmldato += "</contactos>"

                            nvFW.error_ajax_request('contacto_ABM.aspx', {
                                parameters: {
                                    modo: 'E',
                                    contactos_xml: xmldato,
                                    id_tipo: id_tipo,
                                    nro_id_tipo: nro_id_tipo
                                },
                                onSuccess: function (err, transport) {

                                    Telefono_Actualizar_return();

                                },
                                onFailure: function (err) {

                                    if (typeof err == 'object') {
                                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                                    }
                                },
                                error_alert: false,
                                bloq_msg: "Guardando..."
                            });
                        }

                        winConfirm.close()
                    }
                });
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }

        function Telefono_Actualizar(indice, id_telefono) {

            if (nvFW.tienePermiso('permisos_contactos', 1)) {
                winTelefono = parent.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/entidades/contactos/Contacto_Generico_ABM.aspx?indice=' + indice + "&id_contact=" + id_telefono + "&id_tipo=" + id_tipo + "&nro_id_tipo=" + nro_id_tipo + '&nro_contacto_grupo=2',
                    title: '<b>ABM Contactos</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    width: 490,
                    height: 325,
                    onClose: function (winTelefono) { if (winTelefono.options.userData.modificacion) Telefono_Actualizar_return(indice); },
                    destroyOnClose: true
                });
                //winTelefono.options.userData = { Contactos: Contactos }
                winTelefono.showCenter(true)
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }

        function Telefono_Actualizar_return(indice) {

                contactos_cargar(filto_tiposCheck)

        }


        /***************************************************/
        /*************** CONTACTO DE EMAIL *****************/
        /***************************************************/


        /***    Elimina un Contacto de Email seleccionado ***/
        function Email_Eliminar(indice, id_email) {
            if (nvFW.tienePermiso('permisos_contactos', 2)) {
                nvFW.confirm("¿Desea borrar el Email seleccionado?", {
                    width: 300,
                    //className: "alphacube",
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    cancel: function (winConfirm) { winConfirm.close(); return },
                    ok: function (winConfirm) {

                        if (Contactos["email"][indice]["predeterminado"] == 'True') {
                            alert('No puede eliminar el email, se encuentra como Predeterminado')

                        }
                        else {

                            var xmldato = ""
                            xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                            xmldato += "<contactos>"
                            xmldato += "<domicilios>"
                            xmldato += "</domicilios>"

                            xmldato += "<telefonos>"
                            xmldato += "</telefonos>"

                            xmldato += "<horarios>"
                            xmldato += "</horarios>"

                            xmldato += "<emails>"
                            xmldato += "\n<email id_email='" + (id_email * -1) + "' estado='BORRADO'></email>"
                            xmldato += "</emails>"

                            xmldato += "</contactos>"

                            nvFW.error_ajax_request('contacto_ABM.aspx', {
                                parameters: {
                                    modo: 'E',
                                    contactos_xml: xmldato,
                                    id_tipo: id_tipo,
                                    nro_id_tipo: nro_id_tipo
                                },
                                onSuccess: function (err, transport) {

                                    Email_Actualizar_return();

                                },
                                onFailure: function (err) {

                                    if (typeof err == 'object') {
                                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                                    }
                                },
                                error_alert: false,
                                bloq_msg: "Guardando..."
                            });
                        }

                        winConfirm.close()
                    }
                });
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }


        /***    Permita editar un Contacto de Email seleccionado  ***/
        function Email_Actualizar(indice, id_email) {
            if (nvFW.tienePermiso('permisos_contactos', 1)) {
                winEmail = parent.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/entidades/contactos/Contacto_Generico_ABM.aspx?indice=' + indice + "&id_contact=" + id_email + "&id_tipo=" + id_tipo + "&nro_id_tipo=" + nro_id_tipo + '&nro_contacto_grupo=3',
                    title: '<b>ABM Contactos</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    width: 500,
                    height: 280,
                    onClose: function (winEmail) { if (winEmail.options.userData.modificacion) Email_Actualizar_return(indice); },
                    destroyOnClose: true
                });
                winEmail.options.userData = { Contactos: Contactos }
                winEmail.showCenter(true)
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }


        /***    Actualiza la tabla de Contactos de Email en la pantalla ABM Personas, luego de haber editado un contacto determinado***/
        function Email_Actualizar_return(indice) {

                contactos_cargar(filto_tiposCheck)

        }


        /***    Verifica si existen contactos de email vigentes, pero ninguno esta marcado como Predeterminado    ***/
        function Email_marcar_predeterminado() {
            var email_vigente = 0
            var email_predeterminado = 0

            Contactos["email"].each(function (arreglo, i) {
                vigente = (arreglo["vigente"] == null) ? "True" : arreglo["vigente"];
                if (vigente == "True")
                    email_vigente++
                if (arreglo["predeterminado"] == "True")
                    email_predeterminado++
            });

            if (email_vigente > 0 && email_predeterminado == 0)
                return true
            else {
                return false
            }
        }


        function window_onresize() {

            var body_h = $$('body')[0].getHeight();
            var menu_h = $('tbTitulo').getHeight()
            $('tbContactos').setStyle({ height: body_h - menu_h + 'px' })
            $('tdIframes').setStyle({ height: body_h - menu_h - 2 + 'px' })
            var tdIframes_h = $('tdIframes').getHeight()
            $('frmcontacto').setStyle({ height: tdIframes_h - 5 + 'px' })
            $('frameContacto').setStyle({ height: tdIframes_h - 5 + 'px' })
            $('menu_right').setStyle({ height: body_h - menu_h - 2 + 'px' })


        }


        function get_contacto_grupos() {
            var path_xsl = "report\\verContactos\\HTML_verContacto_grupos.xsl"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_contacto_grupos
                , filtroWhere: ""
                , path_xsl: path_xsl
                , salida_tipo: "adjunto"
                , formTarget: "iframe_grupo"
                , async: false
                , bloq_contenedor: $("iframe_grupo")
                , bloq_contenedor_msg: ' '
                , bloq_msg: 'Cargando...'
                //,funComplete: function (response, parseError) {
                //    Mostrar_Registro_grupo(nro_com_grupo)
                //}
            })
        }


        /***************************************************/
        /*************** CONTACTO GENERICO *****************/
        /***************************************************/

        var filto_tiposCheck = ''
        var checkContacto_grupos = new Array()
        function contactos_cargar(filtroTipos) {
            
            if (id_tipo != "") {
                var filtro = "<id_tipo type='igual'>" + id_tipo + "</id_tipo>"
                filtro += "<nro_id_tipo type='igual'>" + nro_id_tipo + "</nro_id_tipo>"
                filtro += filtroTipos
                filto_tiposCheck = filtroTipos

                var cantFilas = Math.floor((($("frameContacto").getHeight() - 18) / 22) - 1)

                Contactos = {};

                parametros = "<parametros><contactos_ABM cantContactosExternos='" + contactosExternos.length + "'/></parametros>";

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroContactoGenerico,
                    filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                    path_xsl: "/report/verContactos/HTML_verContactos_generico.xsl",
                    salida_tipo: 'adjunto',
                    ContentType: 'text/html',
                    formTarget: 'frameContacto',
                    nvFW_mantener_origen: true,
                    parametros: parametros,
                    bloq_contenedor: $$('body')[0],
                    bloq_msg: 'Buscando...',
                    cls_contenedor: 'frameContacto',

                });


            } else {

                var filtroXML = parent.nvFW.pageContents[nvFW.pageContents.nombreFiltroContactoGenerico]
                var filtro = filtroTipos
                filto_tiposCheck = filtroTipos

                if (typeof filtroXML != "undefined" && filtroXML != "") {

                    var cantFilas = Math.floor(($("frameContacto").getHeight() - 18) / 22) - 1

                    nvFW.exportarReporte({
                        filtroXML: filtroXML,
                        filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: "/report/verContactos/HTML_verContactos_generico.xsl",
                        salida_tipo: 'adjunto',
                        ContentType: 'text/html',
                        formTarget: 'frameContacto',
                        nvFW_mantener_origen: true,
                        bloq_contenedor: $$('body')[0],
                        bloq_msg: 'Buscando...',
                        cls_contenedor: 'frameContacto',

                    });

                }

            }
        }


        function Contacto_Actualizar(indice, id_contact, nro_contacto_grupo) {

            if (typeof nro_contacto_grupo != 'undefined') {
                nro_contacto_grupo = '&nro_contacto_grupo=' + nro_contacto_grupo
            } else {
                nro_contacto_grupo = checkContacto_grupos.length == 1 ? '&nro_contacto_grupo=' + checkContacto_grupos[0] : ''
            }

            if (nvFW.tienePermiso('permisos_contactos', 1)) {
                win = parent.nvFW.createWindow({
                    className: 'alphacube',
                    url: '/fw/entidades/contactos/Contacto_Generico_ABM.aspx?id_tipo=' + id_tipo + '&nro_id_tipo=' + nro_id_tipo + '&indice=' + indice + nro_contacto_grupo,
                    title: '<b>ABM Contactos</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    resizable: false,
                    width: 660,
                    height: 325,
                    onClose: function (win) {
                        if (win.options.userData.modificacion) {

                            Contacto_Actualizar_return(indice);
                        }
                    },
                    destroyOnClose: true
                });

                win.options.userData = { Contactos: Contactos }
                win.showCenter(true)
            }
            else {
                alert('No posee los permisos para realizar esta acción. Consulte a Sistemas.')
                return
            }
        }


        function Contacto_Actualizar_return(indice) {
            //domicilio_dibujar($('vertodos').checked)
            contactos_cargar(filto_tiposCheck);

        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <form id="frmcontacto" action="Contacto_ABM.aspx" method="post" name="form1" style="margin: 0px" target="frmEnviar">
        <input type="hidden" name="id_tipo" id="id_tipo" value="" />
        <input type="hidden" name="nro_docu" id="nro_docu" value="<%=nro_docu %>" />
        <input type="hidden" name="tipo_docu" id="tipo_docu" value="<%=tipo_docu %>" />
        <input type="hidden" name="sexo" id="sexo" value="<%=sexo %>" />
        <input type="hidden" name="strXML" id="strXML" value="" />
        <input type="hidden" name="modo" id="modo" value="<%=modo %>" />
        <input type="hidden" name="numError" id="numError" value="<%=numError %>" />
        <input type="hidden" name="isModal" id="isModal" value="<%=isModal %>" />
        <table id="tbTitulo" style="width: 100%; font-weight: bold">
            <tr class="tbLabel">
                <td style="background: #e3e0e3 !important; padding: 0;">
                    <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
                    <script type="text/javascript">
                        var vMenu = new tMenu('divMenu', 'vMenu');

                        Menus["vMenu"] = vMenu
                        Menus["vMenu"].alineacion = 'centro';
                        Menus["vMenu"].estilo = 'A';

                        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Contactos</Desc></MenuItem>")
                        vMenu.MostrarMenu()
                    </script>
                </td>
            </tr>
        </table>
        <table id="tb_button" style="display: inline" width="100%">
            <tr>
                <td style="text-align: center">
                    <div style="width: 60%" id="divAceptar" />
                </td>
            </tr>
        </table>
        <table class="tb1" id="tbContactos">
            <tr>
                <td id="tdIframes" style="width: 85%; vertical-align: top">
                    <iframe name="frmEnviar" id="frmEnviar" src="/fw/enBlanco.htm" style="width: 100%; height: 100%; display: none;"></iframe>
                    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameContacto" name="frameContacto"></iframe>
                </td>
                <td id="menu_right" style="vertical-align: top">
                    <table class="tb1" style="height: 70%">
                        <tr class="tbLabel0">
                            <td style="text-align: center">Tipos Contacto</td>
                        </tr>
                        <tr>
                            <td style="width: 100% !Important; vertical-align: top; height: 100%">
                                <div id="divGrupo" style="width: 100% !Important; overflow: auto; height: 100%">
                                    <iframe name="iframe_grupo" id="iframe_grupo" style="width: 100%; height: 100%; overflow: hidden" frameborder="0"></iframe>
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
