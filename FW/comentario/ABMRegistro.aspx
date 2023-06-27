<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador

    Dim nro_entidad As String = nvUtiles.obtenerValor("nro_entidad", "")
    Dim id_tipo As String = nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_com_id_tipo As String = nvUtiles.obtenerValor("nro_com_id_tipo", "")
    Dim nro_registro_origen As String = nvUtiles.obtenerValor("nro_registro_origen", "")
    Dim nro_com_tipo_origen As String = nvUtiles.obtenerValor("nro_com_tipo_origen", "")
    Dim nro_com_estado_origen As String = nvUtiles.obtenerValor("nro_com_estado_origen", "")
    Dim nro_com_estado As String = nvUtiles.obtenerValor("nro_com_estado", "")
    Dim nro_com_grupo As String = nvUtiles.obtenerValor("nro_com_grupo", "")
    Dim collapsed_fck As String = nvUtiles.obtenerValor("collapsed_fck", "")
    Dim nro_circuito As String = nvUtiles.obtenerValor("nro_circuito", "")

    Dim bloq_menu As Integer = nvUtiles.obtenerValor("bloq_menu", 0)

    Dim vista As String = "ver_cire_com_detalle"
    Dim modo = nvUtiles.obtenerValor("modo", "")       ' VA:'Modo Vista Vacia'  A:'Modo Alta'
    If (modo = "") Then
        modo = "VA"
    End If

    If (modo.ToUpper = "VA") Then

        Dim rs = nvDBUtiles.DBExecute("select top 1 * from sys.all_views where name = 'ver_cire_com_detalle_id_tipo'")
        If Not (rs.EOF) Then
            vista = "ver_cire_com_detalle_id_tipo"
        End If
    End If

    If (modo.ToUpper <> "VA") Then
        Dim Err As New nvFW.tError()

        Select Case modo.ToUpper
            'Alta de comentario
            Case "A"
                Try
				
                   
				   Dim strSQL = ""
                    Dim strXML = HttpUtility.UrlDecode(nvUtiles.obtenerValor("strXML", ""))

                    Dim Cmd As New ADODB.Command
                    Cmd.ActiveConnection = nvDBUtiles.DBConectar()
                    Cmd.CommandType = 4
                    Cmd.CommandTimeout = 1500
                    Cmd.CommandText = "nv_comentario_alta"

                    Dim pstrXML = Cmd.CreateParameter("strXML", 201, 1, strXML.Length, strXML)
                    Cmd.Parameters.Append(pstrXML)
                    Dim rs = Cmd.Execute()
                    nro_entidad = rs.Fields("nro_entidad").Value
                    id_tipo = rs.Fields("id_tipo").Value
                    Dim nro_registro As String = rs.Fields("nro_registro").Value
                    Err.params.Add("nro_entidad", nro_entidad)
                    Err.params.Add("id_tipo", id_tipo)
                    rs.Close()
                    Err.numError = 0
                    Err.mensaje = ""

                    ' Disparar evento de comentario
                    nvServer.Events.RaiseEvent("ABMRegistro_event", nro_registro, strXML)

                Catch ex As Exception
                    Err.parse_error_script(ex)
                    Err.titulo = "Error al guardar la transferencia"
                    Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
                    Err.debug_src = "ABMRegistro.aspx"
                End Try
            'Bloquear comentario
            Case "BLOQ"
                Try

                    If (Not op.tienePermiso("permisos_comentarios", 6)) Then
                        Err.numError = -2
                        Err.titulo = ""
                        Err.mensaje = "No posee permisos para realizar esta acción."
                        Err.debug_src = "ABMRegistro.aspx"
                        Err.response()
                    End If

                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("bloqueo_capture", ADODB.CommandTypeEnum.adCmdStoredProc)

                    cmd.addParameter("@nro_registro", ADODB.DataTypeEnum.adInteger, , , nro_registro_origen)

                    Dim rs_bloq As ADODB.Recordset = cmd.Execute()

                    If rs_bloq.Fields("numError").Value <> 0 Then
                        Err.titulo = rs_bloq.Fields("titulo").Value
                        Err.mensaje = rs_bloq.Fields("mensaje").Value
                        Err.debug_src = rs_bloq.Fields("debug_src").Value
                        Err.debug_desc = rs_bloq.Fields("debug_desc").Value
                    End If

                    Err.params.Add("bloq_success", rs_bloq.Fields("bloq_success").Value)

                    nvFW.nvDBUtiles.DBCloseRecordset(rs_bloq)

                Catch ex As Exception
                    Err.parse_error_script(ex)
                    Err.numError = -1
                    Err.titulo = "Error"
                    Err.mensaje = "Error al intentar bloquear el comentario."
                    Err.debug_src = "ABMRegistro.aspx"
                End Try
            'Desbloquear comentario
            Case "DEBLOQ"
                Try

                    If (Not op.tienePermiso("permisos_comentarios", 6)) Then
                        Err.numError = -2
                        Err.titulo = ""
                        Err.mensaje = "No posee permisos para realizar esta acción."
                        Err.debug_src = "ABMRegistro.aspx"
                        Err.response()
                    End If

                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("bloqueo_decapture", ADODB.CommandTypeEnum.adCmdStoredProc)

                    cmd.addParameter("@nro_registro", ADODB.DataTypeEnum.adInteger, , , nro_registro_origen)

                    Dim rs_debloq As ADODB.Recordset = cmd.Execute()

                    If rs_debloq.Fields("numError").Value <> 0 Then
                        Err.titulo = rs_debloq.Fields("titulo").Value
                        Err.mensaje = rs_debloq.Fields("mensaje").Value
                        Err.debug_src = rs_debloq.Fields("debug_src").Value
                        Err.debug_desc = rs_debloq.Fields("debug_desc").Value
                    End If

                    nvFW.nvDBUtiles.DBCloseRecordset(rs_debloq)

                Catch ex As Exception
                    Err.parse_error_script(ex)
                    Err.numError = -1
                    Err.titulo = "Error"
                    Err.mensaje = "Error al intentar desbloquear el comentario."
                    Err.debug_src = "ABMRegistro.aspx"
                End Try
        End Select

        Err.response()

    End If


    'vistas********
    Dim filtro As String = "<nro_com_id_tipo type='igual'>" & nro_com_id_tipo & "</nro_com_id_tipo>"

    If (nro_com_tipo_origen = "0" Or nro_com_tipo_origen = "") Then
        filtro += "<nro_com_tipo_origen type='isnull' />"
    Else
        filtro += "<nro_com_tipo_origen type='igual'>" & nro_com_tipo_origen & "</nro_com_tipo_origen>"
    End If

    If (nro_com_estado_origen = "0" Or nro_com_estado_origen = "") Then
        filtro += "<nro_com_estado_origen type='isnull' />"
    Else
        filtro += "<nro_com_estado_origen type='igual'>" & nro_com_estado_origen & "</nro_com_estado_origen>"
    End If

    If nro_circuito <> "" AndAlso nro_circuito <> "0" Then
        filtro &= "<nro_circuito type='igual'>" & nro_circuito & "</nro_circuito>"
    Else
        filtro &= "<nro_circuito type='igual'>1</nro_circuito>"
    End If
    filtro &= "<vigente type='igual'>1</vigente>"

    Me.contents("ver_cire_com_detalle") = nvXMLSQL.encXMLSQL("<criterio><select vista='" & vista & "'><campos>nro_com_tipo as [id], desc_com_estado as [campo]</campos><orden>[campo]</orden><filtro>" & filtro & "</filtro></select></criterio>")
    Me.contents("verRegistro_padres") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_verRegistro_padres'><parametros></parametros></procedure></criterio>")
    Me.contents("verTipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>nro_com_tipo, nombre_asp</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("verBloqueo") = nvXMLSQL.encXMLSQL("<criterio><select vista='bloqueo_operador'><campos>CASE WHEN fe_hasta > GETDATE() THEN bloqueo_operador.operador ELSE '' END AS bloq_operador, CASE WHEN fe_hasta > GETDATE() THEN 1 ELSE 0 END AS bloqueado, bloq_mantener, CASE WHEN YEAR(fe_hasta) > 2100 THEN 'Indefinido' ELSE CONVERT(VARCHAR,fe_hasta,103) + ' ' + CONVERT(VARCHAR,fe_hasta,8) END AS fe_hasta</campos><orden></orden><filtro><nro_registro type='igual'>%nro_registro%</nro_registro></filtro></select></criterio>")

    Me.contents("bloq_menu") = bloq_menu
    Me.contents("operador") = op.operador

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Alta Comentarios</title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/ckeditor/ckeditor.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">
        var alert = function (msg) {
            Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }

        var win
        var fecha_hoy

        var nro_entidad = '<%= nro_entidad%>'
        var id_tipo = '<%=id_tipo %>'
        var nro_com_id_tipo = '<%= nro_com_id_tipo%>'
        var nro_registro_origen = '<%= nro_registro_origen%>'
        var nro_com_tipo_origen = '<%=nro_com_tipo_origen %>'
        var nro_com_estado_origen = '<%=nro_com_estado_origen %>'
        var nro_com_estado = '<%=nro_com_estado %>'
        var collapsed_fck = '<%=collapsed_fck %>'
        var nro_com_grupo = '<%= nro_com_grupo%>'
        var bloq_interval = ''

        var bloq_menu = nvFW.pageContents.bloq_menu
        var operador = nvFW.pageContents.operador
        var bloq_mantener = false
        var bloq_operador = ''

        var vButtonItems = new Array();

        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar Comentario";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return Guardar_comentario()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        //vListButton.imagenes = Imagenes //Imagenes se declara en pvUtiles
        vListButton.loadImage("guardar", '/fw/image/comentario/guardar.png')

        function window_onload() {
            iniciarGlobales()

            vListButton.MostrarListButton()
            fecha_hoy = FechaToSTR(new Date(), 1)
            $('fecha_comentario').insert({ bottom: fecha_hoy })
            
            if (bloq_menu) {
                cargar_menu_bloqueo()
            }

            cargarTiposDeComentarios()
            cargarHistorialComentarios()

            setTimeout("window_onresize();CKEDITOR.instances.comentario.focus()", 500)

        }

        function iniciarGlobales() {

            // obtenemos los parámetros del dialog
            win = typeof nvFW.getMyWindow() != 'undefined' ? nvFW.getMyWindow() : parent.nvFW.getMyWindow(); //si esta contenido en un iframe

        }

        function cargarTiposDeComentarios() {

            campos_defs.add('nro_com_tipo', {
                nro_campo_tipo: 1,
                target: 'td_nro_com_tipo',
                enDB: false,
                filtroXML: nvFW.pageContents.ver_cire_com_detalle,
                filtroWhere: "<nro_com_tipo type='igual'>%campo_value%</nro_com_tipo>",
                onchange: cargarPaginaComentario
            });

            var rs = new tRS()
            rs.open(nvFW.pageContents.ver_cire_com_detalle, "", "", "", "")
            if (!rs.eof())
                campos_defs.set_value('nro_com_tipo', rs.getdata("id"))
        }

        // carga el historial de comentarios del cual deriva el nuevo comentario
        function cargarHistorialComentarios() {

            if (nro_registro_origen == "" || nro_registro_origen == "0")
                return

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.verRegistro_padres,
                filtroWhere: "<criterio><procedure><parametros><select><filtro><nro_registro type='in'>" + nro_registro_origen + "</nro_registro></filtro><orden></orden><grupo></grupo><campos></campos></select></parametros></procedure></criterio>",
                path_xsl: "//report//comentario//verCom_registro//verRegistro_historial_comentarios.xsl",
                formTarget: 'iframe_historial_com',
                nvFW_mantener_origen: false,
                //id_exp_origen: 0,
                bloq_contenedor: $('iframe_historial_com'),
                cls_contenedor: 'iframe_historial_com'
            })
        }

        //carga en "iframe_comentario" la página de alta de comentario que corresponda
        function cargarPaginaComentario() {
            // verificamos que se haya seleccionado un item del 'select'
            if (!campos_defs.value('nro_com_tipo'))
                return;
          
            var rs = new tRS()
            rs.open(nvFW.pageContents.verTipos, "", "<criterio><select><campos></campos><orden></orden><filtro>" + campos_defs.filtroWhere('nro_com_tipo') + "</filtro></select></criterio>", "", "")
            if (!rs.eof()) {
                var asp = rs.getdata("nombre_asp");
                if (asp == undefined || asp == 'cargar_comentario_activo.asp' || asp == 'cargar_comentario_activo.aspx') {
                    $('iframe_comentario').hide();
                    $('default_comment').show();
                    $('tbTitComen').show()
                    $('tbPie').show()
                } else {
                    var pagina_asp = asp.toString();
                    //cargamos la página asociada al comentario en el iframe "iframe_comentario"
                    $('iframe_comentario').src = pagina_asp;
                    $('iframe_comentario').show();
                    $('default_comment').hide();
                    $('tbTitComen').hide()
                    $('tbPie').hide()
                }
            }

            window_onresize()
        }

        function Guardar_comentario() {
            
            var comentario = CKEDITOR.instances.comentario.getData();

            if ((comentario == "") || (comentario == "(Ingrese aquí su comentario)")) {
                alert("Debe especificar un comentario válido")
                return
            }

            if ($('nro_com_tipo').value == "") {
                alert("Debe seleccionar un tipo de comentario")
                return
            }

            var xmldato = ""
            xmldato = "<comentario "
            xmldato += "nro_entidad='" + nro_entidad + "' "
            xmldato += "id_tipo='" + id_tipo + "' "
            xmldato += "nro_com_id_tipo='" + nro_com_id_tipo + "' "
            xmldato += "nro_com_tipo='" + campos_defs.get_value('nro_com_tipo') + "' "
            xmldato += "fecha='" + fecha_hoy + "' "
            xmldato += "nro_registro_depende='" + nro_registro_origen + "' "
            xmldato += ">"
            xmldato += "<descripcion><![CDATA[" + comentario + "]]></descripcion>"
            xmldato += "</comentario>"

            nvFW.error_ajax_request('/FW/comentario/ABMRegistro.aspx', {
                parameters: {
                    modo: 'A',
                    strXML: escape(xmldato)
                },
                onSuccess: function (err, transport) {
                    $('nro_entidad').value = err.params['nro_entidad']
                    $('id_tipo').value = err.params['id_tipo']
                    window.top.Windows.getFocusedWindow().returnValue = err.params['nro_entidad']
                    //Cerrar_Ventanas() //window.setTimeout('Cerrar_Ventanas()', 2000)
                    win.close()
                },
                onFailure: function (err, transport) {
                    //debugger
                }
            })
        }

        function Cerrar_Ventanas() {
            window.top.Windows.getFocusedWindow().close()
        }


        function window_onresize() {
            try {
               // console.log("ok")
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var tbTipo_height = $('tbTipo').getHeight()
                var tbTitComen_height = $('tbTitComen').getHeight()
                var tbPie_height = $('tbPie').getHeight()

                var menuBloqueo_h = 0
                if (bloq_menu)
                    menuBloqueo_h = $('divMenuPrincipal').getHeight()

                var alto_cabe = (body_height * 0.20) + 'px'
                $('tbCabe').setStyle({ height: alto_cabe })

                var tbCabe_height = $('tbCabe').getHeight()

                alto = (body_height - tbCabe_height - tbTipo_height - menuBloqueo_h - dif)

                var resta = body_height - tbCabe_height - tbTipo_height + 'px'

                if ($('iframe_comentario').style.display != 'none') {

                    $('iframe_comentario').setStyle({ 'height': resta })                    
                }

                else {
                    alto = (alto - tbTitComen_height - tbPie_height)
                    var editor = CKEDITOR.instances.comentario
                    if (editor)
                        editor.resize('100%', alto);
                }

            }
            catch (e) {
                //console.log(e.message)
            }
        }


        function bloquear_comentario(bloq) {
            if (bloq) {
                //bloquear comentario
                //bloqueo pantalla si no es setInterval
                var bloq_contenedor_on = bloq_interval == '';

                nvFW.error_ajax_request('ABMRegistro.aspx', {
                    parameters: {
                        modo: 'BLOQ',
                        nro_registro_origen: nro_registro_origen
                    },
                    onSuccess: function (err, transport) {
                        if (err.params["bloq_success"] == 0) {
                            alert("El comentario se encuentra bloqueado por otro operador.")
                        } else {
                            $('menuItem_divMenuPrincipal_0').hide();
                            $('menuItem_divMenuPrincipal_1').show();
                            $('menuItem_divMenuPrincipal_2').show();
                            //si no hay intervalo para refrezcar bloqueo, seteo
                            if (bloq_interval == '')
                                bloq_interval = setInterval('bloquear_comentario(true)', 90000); //minuto y medio
                        }
                    },
                    onFailure: function (err, transport) {
                        //en caso de mantener bloqueo (si falla por caida de sesion)
                        if (!blqo_mantener) {
                            $('menuItem_divMenuPrincipal_1').hide();
                            $('menuItem_divMenuPrincipal_2').hide();
                            $('menuItem_divMenuPrincipal_0').show();

                            //si hay setInterval, libero
                            if (bloq_interval != '') {
                                clearInterval(bloq_interval)
                                bloq_interval = ''
                            }
                        }
                    },
                    bloq_contenedor_on: bloq_contenedor_on
                });
            } else {
                //desbloquear comentario
                if (operador != bloq_operador) {
                    alert("Este comentario esta bloqueado por otro operador.")
                    return
                }
                //libero setInterval que mantiene el bloqueo
                clearInterval(bloq_interval)
                bloq_interval = ''
                blqo_mantener = false

                nvFW.error_ajax_request('ABMRegistro.aspx', {
                    parameters: {
                        modo: 'DEBLOQ',
                        nro_registro_origen: nro_registro_origen
                    },
                    onSuccess: function (err, transport) {
                        $('menuItem_divMenuPrincipal_1').hide();
                        $('menuItem_divMenuPrincipal_2').hide();
                        $('menuItem_divMenuPrincipal_0').show();
                        $('menuItem_divMenuPrincipal_3').innerHTML = "";
                    },
                    onFailure: function (err, transport) {
                        $('menuItem_divMenuPrincipal_0').hide();
                        $('menuItem_divMenuPrincipal_1').show();
                        $('menuItem_divMenuPrincipal_2').show();
                    }
                });
            }

        }


        function window_onunload() {
            if (bloq_menu && operador == bloq_operador && !bloq_mantener) {
                bloquear_comentario(false);
            }

        }


        var vMenuPrincipal
        function cargar_menu_bloqueo() {

            var rs = new tRS();
            var rs_params = "<criterio><params nro_registro='" + nro_registro_origen + "' /></criterio>";

            rs.async = true

            rs.onComplete = function () {

                var bloqueado = 0;
                win.options.userData.bloqueado = 0;
                win.options.userData.bloq_operador = '';

                if (!rs.eof()) {
                    bloqueado = rs.getdata('bloqueado');
                    bloq_mantener = rs.getdata('bloq_mantener') == "True";
                    win.options.userData.bloqueado = bloqueado;
                    win.options.userData.bloq_operador = rs.getdata('bloq_operador');
                    bloq_operador = rs.getdata('bloq_operador');
                }

                vMenuPrincipal = new tMenu('divMenuPrincipal', 'vMenuPrincipal');
                Menus["vMenuPrincipal"] = vMenuPrincipal;
                Menus["vMenuPrincipal"].alineacion = 'centro';
                Menus["vMenuPrincipal"].estilo = 'A';

                var desc_menu = '';
                var icono = '';
                var id = '3';
                //si esta bloqueado por otro operador
                if (bloqueado == 1 && operador != bloq_operador) {
                    desc_menu = 'Comentario bloqueado';
                    icono = 'capturado';
                    id = '0';
                    //si esta bloqueado por mi o no esta bloqueado
                } else {
                    win.options.userData.bloq_operador = operador;
                    bloq_operador = operador;
                    Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>liberado</icono><Desc>Bloquear</Desc><Acciones><Ejecutar Tipo='script'><Codigo>bloquear_comentario(true)</Codigo></Ejecutar></Acciones></MenuItem>");
                    Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>capturado</icono><Desc>Desbloquear</Desc><Acciones><Ejecutar Tipo='script'><Codigo>bloquear_comentario(false)</Codigo></Ejecutar></Acciones></MenuItem>");
                    Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Mantener Bloqueo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mantener_bloqueo()</Codigo></Ejecutar></Acciones></MenuItem>");
                }

                Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='" + id + "' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>" + icono + "</icono><Desc>" + desc_menu + "</Desc></MenuItem>");

                Menus["vMenuPrincipal"].loadImage('capturado', '/FW/image/icons/cerrar.png');
                Menus["vMenuPrincipal"].loadImage('liberado', '/FW/image/icons/abierto.png');
                vMenuPrincipal.MostrarMenu();

                //si no esta bloqueado por otro operador
                if (id != '0') {
                    if (bloqueado == 0) {
                        $('menuItem_divMenuPrincipal_1').hide();
                        $('menuItem_divMenuPrincipal_2').hide();
                    }
                    else {
                        $('menuItem_divMenuPrincipal_0').hide();
                        //si esta bloqueado por mi, mantengo el bloqueo hasta cerrar la ventana o desbloquearlo
                        bloq_interval = setInterval('bloquear_comentario(true)', 90000); //minuto y medio
                        if (bloq_mantener) {
                            $('menuItem_divMenuPrincipal_3').innerHTML = "Bloqueado hasta: " + rs.getdata("fe_hasta");
                            $('menuItem_divMenuPrincipal_3').setStyle({ textAlign: "right" })
                        }
                    }
                }
            }

            rs.open(nvFW.pageContents.verBloqueo, "", "", "", rs_params);
        }


        function mantener_bloqueo() {

            var win = nvFW.createWindow({
                url: '/FW/comentario/bloqueo_registro.aspx?nro_registro=' + nro_registro_origen,
                title: '<b>Definir bloqueo</b>',
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                width: 300,
                height: 250,
                destroyOnClose: true,
                onClose: function () {
                    if (win.options.userData.hay_modificacion) {
                        $('menuItem_divMenuPrincipal_3').innerHTML = "Bloqueado hasta: " + win.options.userData.fecha_bloqueo;
                        $('menuItem_divMenuPrincipal_3').setStyle({ textAlign: "right" });
                        bloq_mantener = true;
                    }
                }
            });

            win.options.userData = {}
            win.showCenter(true);
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" onunload="window_onunload()" style="width: 100%; height: 100%; overflow: hidden">
    <input type="hidden" name="nro_entidad" id="nro_entidad" />
    <input type="hidden" name="id_tipo" id="id_tipo" />
    <div id="divMenuPrincipal" style="display: none"></div>
    <table class="tb1" id="tbCabe">
        <tr class="tbLabel">
            <td><b>Historial</b></td>
        </tr>
        <tr>
            <td>
                <div id="divHistorial_comentarios_depende_de" style="width: 100%; height: 100%; display: inline">
                    <iframe name="iframe_historial_com" style="width: 100%; height: 100%" src="enBlanco.htm" frameborder="0"></iframe>
                </div>
            </td>
        </tr>
    </table>
    <table class="tb1" id="tbTipo">
        <tr class="tbLabel">
            <td colspan='4'><b>Nuevo registro de comentario</b></td>
        </tr>
        <tr class="tbLabel">
            <td style="width: 30%">Fecha</td>
            <td style="width: 30%">Operador</td>
            <td>Tipo de comentario</td>
        </tr>
        <tr>
            <td style="text-align: center"><span id="fecha_comentario"></span></td>
            <td><% = nvApp.operador.nombre_operador.toUpper%></td>
            <td id="td_nro_com_tipo"></td>
        </tr>
    </table>
    <div style="width: 100%" id="default_comment">
        <table id="tbTitComen" class="tb1" style="width: 100%">
            <tr class="tbLabel">
                <td style="width: 100%"><b>Comentario:</b></td>
            </tr>
        </table>
        <div style="width: 100%;" id="ckeditor_contenedor">
            <textarea id="comentario"></textarea>
            <script type="text/javascript">
                CKEDITOR.config.toolbar = [
                    ['FitWindow', 'Source'],
                    ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteWord', '-'],
                    ['Undo', 'Redo', '-', 'SelectAll'],
                    ['OrderedList', 'UnorderedList', '-', 'Outdent', 'Indent'],
                    ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyFull']
                ];
                CKEDITOR.config.resize_enabled = false;
                CKEDITOR.config.removePlugins = 'elementspath';
                CKEDITOR.replace("comentario", {
                    on: {
                        resize: function (evt) {
                            //   window_onresize()
                        }
                    }
                });

            </script>
        </div>
        <table id="tbPie" class="tb1" style="width: 100%">
            <tr>
                <td colspan="3">&nbsp;</td>
            </tr>
            <tr>
                <td style="width: 30%">&nbsp;</td>
                <td>
                    <div id="divGuardar"></div>
                </td>
                <td style="width: 30%">&nbsp;</td>
            </tr>
            <tr>
                <td colspan="3">&nbsp;</td>
            </tr>
        </table>
    </div>
    <iframe name="iframe_comentario" id="iframe_comentario"  frameborder="0" src="/fw/enBlanco.htm" style="display: none; width: 100%; height: 100%;"></iframe>
</body>
</html>
