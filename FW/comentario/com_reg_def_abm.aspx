<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err = New nvFW.tError

    If (modo = "ajax_call") Then
        If (accion = "guardar") Then
            
            Dim strXml As String = nvFW.nvUtiles.obtenerValor("xml", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_nv_comentario_def_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

            Dim pStrXML As ADODB.Parameter
            pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXml.Length, strXml)
            cmd.Parameters.Append(pStrXML)

            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim numError As Integer = rs.Fields.Item("numError").Value

            If numError <> 0 Then
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value
                err.titulo = rs.Fields("titulo").Value
                err.debug_desc = rs.Fields("debug_desc").Value
                err.debug_src = rs.Fields("debug_src").Value


            End If

            err.params("nro_com_id_tipo") = rs.Fields("nro_com_id_tipo").Value

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            err.response()
        End If
    End If


    Me.contents("filtroIdTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_id_tipo'>" +
                          "<campos>nro_com_id_tipo as id, com_id_tipo as  [campo] </campos>" +
                          "<filtro></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroGrupos") =
        nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_grupos'>" +
                  "<campos>*</campos>" +
                  "<filtro></filtro></select></criterio>")
    Me.contents("filtroGruposSeleccionados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_id_tipo_grupos'>" +
                                                                "<campos>*</campos>" +
                                                                "<filtro></filtro></select></criterio>")

    Me.contents("filtroTipos") =
        nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'>" +
                  "<campos>*</campos>" +
                  "<filtro></filtro></select></criterio>")
    Me.contents("filtroTiposSeleccionados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_id_tipo_tipos'>" +
                                                "<campos>*</campos>" +
                                                "<filtro></filtro></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Modulo Comentarios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var win_abmGrupoTipo;
        var id_tipo = '';
        var grupos = {};
        var tipos = {};
        //Permite saber si se creo una nueva def de comentario o se esta modificando
        var nuevo = false;
        var com_id_tipo;

        //Sirve para saber si ya se cargaron los tipos y grupos
        var cargados_tipos = false;
        var cargados_grupos = false;
        //Sirve para determinar si ya se seleccionaron segun el ultimo id cargado
        var ultimo_id_seleccionado_grupo = "";
        var ultimo_id_seleccionado_tipo = ""
        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }

        function window_onresize() {
            try {
                body_h = $$('BODY')[0].clientHeight;
                var divComentario_h = $('trDivComentario').getHeight();

                if (!nuevo)
                    var trComentario_h = $('trComentarioExistente').getHeight();
                else
                    var trComentario_h = $('trComentarioNuevo').getHeight();
                var divGrupos_h = $('divTipos').getHeight();
                tamanio = (body_h - divComentario_h - trComentario_h - divGrupos_h - 30);
                $('trGrupoTipo').style.height = (tamanio>65 ? tamanio : 65) + 'px';
                $('divFrameTipo').style.height = (tamanio > 65 ? tamanio : 65) + 'px';
                $('divFrameGrupo').style.height = (tamanio > 65 ? tamanio : 65) + 'px';
            } catch (err) {

            }
            
        }

        function window_onload() {
            
            campos_defs.items["id_tipo"]["onchange"] = function () {
                if (typeof String.prototype.trim !== 'function') {
                    String.prototype.trim = function () {
                        return this.replace(/^\s+|\s+$/g, '');
                    }
                }
                
                limpiar();
                $('com_id_tipo').value = campos_defs.get_desc('id_tipo').split('(')[0].trim();
                id_tipo = campos_defs.get_value('id_tipo');

                if (!cargados_grupos ){
                    cargarGrupos();
                } else {
                    seleccionarGrupos(); 
                }
                if (!cargados_tipos) {
                    cargarTipos();
                } else {
                    seleccionarTipos();
                }
            };
            //---------------------
            window_onresize();
        }

        function cargarGrupos() {

            var filtro = nvFW.pageContents.filtroGrupos;

            nvFW.bloqueo_activar($('iframeGrupos'), 'cargando_grupos');

            nvFW.exportarReporte({
                filtroXML: filtro,
                //filtroWhere: filtroWhere,
                path_xsl: '../FW/report/comentario/com_grupos.xsl',
                formTarget: 'iframeGrupos',
                nvFW_mantener_origen: true,
                async: true,
                cls_contenedor: 'iframeGrupos',
                funComplete: function (response, parseError) {
                    cargados_grupos = true;
                    seleccionarGrupos();

                }
            });

        }

        function seleccionarGrupos() {
            var iframeGrupos = frames.iframeGrupos.document;

            if (!id_tipo || ultimo_id_seleccionado_grupo == id_tipo) {
                nvFW.bloqueo_desactivar($('iframeGrupos'), 'cargando_grupos');
                return;
            }

            for (grupo in grupos) {
                iframeGrupos.getElementById('checked_grupo_' + grupo).checked = false;
            }
            grupos = {};

            ultimo_id_seleccionado_grupo = id_tipo;
            if(!$('divBloq_cargando_grupos')){
                nvFW.bloqueo_activar($('iframeGrupos'), 'cargando_grupos');
            }
            
            var filtroXML = nvFW.pageContents.filtroGruposSeleccionados;
            var filtroWhere = '<nro_com_id_tipo type="igual">' + id_tipo + '</nro_com_id_tipo>';

            var rs = new tRS()
            rs.async = true

            rs.onComplete = function (rs) {
                //Deschequeamos los activos anteriormente
                while (!rs.eof()) {
                    //console.log(rs.getdata("nro_com_grupo"))
                    
                    iframeGrupos.getElementById('checked_grupo_' + rs.getdata("nro_com_grupo")).checked=true;
                    addGrupo(iframeGrupos.getElementById('checked_grupo_' + rs.getdata("nro_com_grupo")), rs.getdata("nro_com_grupo"))
                    rs.movenext()
                }

                nvFW.bloqueo_desactivar($('iframeGrupos'), 'cargando_grupos');
            }

            rs.open(filtroXML, '', filtroWhere);
        }

        function cargarTipos() {

            var filtro = nvFW.pageContents.filtroTipos;

            nvFW.bloqueo_activar($('iframeTipos'), 'cargando_tipos');

            nvFW.exportarReporte({
                filtroXML: filtro,
                //filtroWhere: filtroWhere,
                path_xsl: '../FW/report/comentario/com_tipos.xsl',
                formTarget: 'iframeTipos',
                nvFW_mantener_origen: true,
                async: true,
                cls_contenedor: 'iframeTipos',
                funComplete: function (response, parseError) {
                    cargados_tipos = true;
                    seleccionarTipos();
                }
            });

        }

        function seleccionarTipos() {
            var iframeTipos = frames.iframeTipos.document;
            

            if (!id_tipo || ultimo_id_seleccionado_tipo == id_tipo) {
                nvFW.bloqueo_desactivar($('iframeTipos'), 'cargando_tipos');
                return;
            }
            for (tipo in tipos) {
                iframeTipos.getElementById('checked_tipo_' + tipo).checked = false;
            }
            tipos = {};

            ultimo_id_seleccionado_tipo = id_tipo;
            if(!$('divBloq_cargando_tipos')){
                nvFW.bloqueo_activar($('iframeTipos'), 'cargando_tipos');
            }
            
            var filtroXML = nvFW.pageContents.filtroTiposSeleccionados;
            var filtroWhere = '<nro_com_id_tipo type="igual">' + id_tipo + '</nro_com_id_tipo>';

            var rs = new tRS()
            rs.async = true

            rs.onComplete = function (rs) {
               
                
                while (!rs.eof()) {
                    //console.log(rs.getdata("nro_com_grupo"))
                    
                    iframeTipos.getElementById('checked_tipo_' + rs.getdata("nro_com_tipo")).checked=true;
                    addTipo(iframeTipos.getElementById('checked_tipo_' + rs.getdata("nro_com_tipo")), rs.getdata("nro_com_tipo"))
                    rs.movenext()
                }

                nvFW.bloqueo_desactivar($('iframeTipos'), 'cargando_tipos');
            }

            rs.open(filtroXML, '', filtroWhere);
        }

        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscar_click();
        }

        function guardar() {
            var accion;
            com_id_tipo = $('com_id_tipo').value;
            if (nuevo){
                accion = "nuevo"
                if ($('com_id_tipo').value == '') {
                    alert("Debe establecer un nombre a la definicion de comentario o seleccionar una para modificar.");
                    return
                }

            }
            else{
                accion = "modificar";
                if ($('id_tipo').value == '') {
                    alert("Debe seleccionar una definicion de comentario o crear una nueva.");
                    return
                }
            }
            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"
            
            xml += "<comentario accion='" + accion + "' nro_com_id_tipo='" + id_tipo + "' com_id_tipo='" + com_id_tipo + "'>"

            xml += "<grupos>"
            for (grupo in grupos) {
                xml += "<grupo  nro_com_grupo='" + grupo + "'  />"
            }
            xml += "</grupos>";
            xml += "<tipos>";
            for (tipo in tipos) {
                xml += "<tipo  nro_com_tipo='" + tipo + "'  />"
            }
            xml += "</tipos></comentario>";
            if (nuevo)
                campos_defs.clear('id_tipo');
            nvFW.error_ajax_request('com_reg_def_abm.aspx',
                {
                    parameters: {
                        xml: xml,
                        modo: "ajax_call",
                        accion: "guardar"
                    },
                    onSuccess: function (err) {
                        
                        if (nuevo) {
                            nvFW.getMyWindow().refresh();
                            /*nvFW.bloqueo_activar($(document.body), 'cargando_nuevo_tipo');
                            id_tipo= err.params["nro_com_id_tipo"]
                            nuevoComentario();
                            setTimeout(function () {
                                campos_defs.set_value('id_tipo', id_tipo);
                                nvFW.bloqueo_desactivar($(document.body), 'cargando_nuevo_tipo');
                            }, 1000);*/
                        }
                    }
                });
        }

        function abmGrupos() {
            win_abmGrupoTipo = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_grupos_abm.aspx',
                title: ('ABM Grupos'),
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 400,
                height: 300,
                modal: true,
                center: true,
                bloquear: true,
                onClose: function () {
                    ultimo_id_seleccionado_grupo = "";
                    cargarGrupos();
                }
            });
            win_abmGrupoTipo.options.userData = {};

            win_abmGrupoTipo.showCenter(true)
        }

        function abmTipos() {
            win_abmGrupoTipo = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_tipos_abm.aspx',
                title: ('ABM de Tipos'),
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1500,
                height: 700,
                onClose: function () {
                    ultimo_id_seleccionado_tipo = "";
                    cargarTipos();
                }
            });
            win_abmGrupoTipo.options.userData = {};

            win_abmGrupoTipo.showCenter(true)
        }

    
        function toggleComentario() {
            if (!nuevo)
                modificarComentario()
            else
                nuevoComentario();
        }

        function modificarComentario() {
            id_tipo = '';
            $('com_id_tipo').value = '';

            var img_mod = "<img id='vComentario_img1' src='/FW/image/icons/editar.png' align='absmiddle' hspace='1' >"
            $('vComentario').children[0].children[0].children[1].children[0].innerHTML = img_mod
            $('vComentario').children[0].children[0].children[1].children[1].innerHTML = "<span>Modificar</span>"

            if (!cargados_grupos) {
                cargarGrupos();
            } else {
                seleccionarGrupos();    
            }

            if(!cargados_tipos){
                    cargarTipos();
            }else{
                    seleccionarTipos();
            }

            $('trComentarioExistente').style.display = 'none';
            $('trComentarioNuevo').style.display = 'inline-table';

            limpiar();

            nuevo = true;
        }
        function limpiar() {
            var iframeGrupos = frames.iframeGrupos.document;
            var iframeTipos = frames.iframeTipos.document;
            for (grupo in grupos) {
                iframeGrupos.getElementById('checked_grupo_' + grupo).checked = false;
            }
            grupos = {};
            for (tipo in tipos) {
                iframeTipos.getElementById('checked_tipo_' + tipo).checked = false;
            }
            tipos = {};
            id_tipo = '';
            ultimo_id_seleccionado_grupo = '';
            ultimo_id_seleccionado_tipo = '';
        }

        function nuevoComentario() {
            var img_nuevo = "<img id='vComentario_img1' src='/FW/image/icons/nueva.png' align='absmiddle' hspace='1' >"
            $('vComentario').children[0].children[0].children[1].children[0].innerHTML = img_nuevo
            $('vComentario').children[0].children[0].children[1].children[1].innerHTML = "<span>Nuevo</span>"
            campos_defs.clear('id_tipo');
            $('trComentarioExistente').style.display = 'inline-table';
            $('trComentarioNuevo').style.display = 'none';
            nuevo = false;
        }

        function addGrupo(check, grupo) {
            
            if (check.checked)
                grupos[grupo] = true;
            else
                delete grupos[grupo];
            
        }

        function addTipo(check, tipo) {
            if (check.checked)
                tipos[tipo] = true;
            else
                delete tipos[tipo];
        }

        
        function confirmar_eliminarComentario() {
            var nro_com_id_tipo = $('id_tipo').value;
            if (nro_com_id_tipo == '') {
                alert("Debe seleccionar una definicion de comentario.");
                return
            }

            var msg = "¿Esta seguro que desea eliminar la definicion de comentario " +campos_defs.get_desc('id_tipo')+ "?";
            Dialog.confirm('<b>' + msg + '</br>'
                            , {
                                width: 280, className: "alphacube",
                                onShow: function () {

                                },
                                onOk: function (win) {
                                    eliminarComentario(nro_com_id_tipo);
                                    win.close();

                                },
                                onCancel: function (win) { win.close() },
                                okLabel: 'Confirmar',
                                cancelLabel: 'Cancelar'
                            });
        }
        function eliminarComentario(nro_com_id_tipo) {
            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"

            xml += "<comentario accion='eliminar' nro_com_id_tipo='" + nro_com_id_tipo + "' com_id_tipo='' />"

            nvFW.error_ajax_request('com_reg_def_abm.aspx',
                {
                    parameters: {
                        xml: xml,
                        modo: "ajax_call",
                        accion: "guardar"
                    },
                    onSuccess: function (err) {
                        nvFW.getMyWindow().refresh();
                    }
                });
        }

        function ventanaComentariosTipoGrupo() {

            
            win_com = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_tipos_grupos_listar.aspx',
                title: ('Relacion Grupo/Tipo ABM'),
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1024,
                height: 768,
                onClose: function () {
                    ultimo_id_seleccionado_tipo = "";
                    ultimo_id_seleccionado_grupo = "";
                    cargarGrupos();
                    cargarTipos();
                }
            });
            win_com.options.userData = {};

            win_com.showCenter(true)
        }
    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow:auto">

    <table class="tb1" id="tbComentarios">
        <tr>
            <td>
                <table class="tb1">
                    <tr id="trDivComentario">
                        <td colspan="4">
                            <div id="divComentario"></div>
                            <script type="text/javascript">
                                //var DocumentMNG = new tDMOffLine;
                                var vComentario = new tMenu('divComentario', 'vComentario');
                                vComentario.loadImage("nueva", '/FW/image/icons/nueva.png')
                                vComentario.loadImage("guardar", '/FW/image/icons/guardar.png')
                                Menus["vComentario"] = vComentario
                                Menus["vComentario"].alineacion = 'centro';
                                Menus["vComentario"].estilo = 'A';



                                Menus["vComentario"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 60%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Comentarios</Desc></MenuItem>")
                                Menus["vComentario"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 20%; text-align:center; vertical-align:middle'>" +
                                                                    "<Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'>" +
                                                                    "<Codigo>toggleComentario()</Codigo></Ejecutar></Acciones></MenuItem>")
                                Menus["vComentario"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 20%; text-align:center; vertical-align:middle'>" +
                                                                    "<Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'>" +
                                                                    "<Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

                                vComentario.MostrarMenu()
                            </script>
                        </td>
                    </tr>
                    <tr id="trComentarioExistente" style="width:80%;display:inline-table">
                        <td class="Tit1" style="width: 40%; text-align: right">ID Comentario: </td>
                        <td style="width: 40%">
                            <script type="text/javascript">
                                campos_defs.add('id_tipo', {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroIdTipo
                                });
                            </script>
                        </td>
                        <td>
                            <img src="/FW/image/icons/eliminar.png" title="Eliminar"  style="cursor:pointer" onclick="confirmar_eliminarComentario()"/>
                        </td>
                    </tr>
                    <tr id="trComentarioNuevo"  style="display:none;width:80%;">
                        <td class="Tit1" style="width: 40%; text-align: right;" >Descripcion Comentario</td>
                        <td style="width: 40%;">
                            <input type="text" id="com_id_tipo" style="width:100%" />
                        </td>

                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                   
                    <tr>
                        <td colspan="4">
                            <div id="divTipos"></div>
                            <script type="text/javascript">
                                var vTipos = new tMenu('divTipos', 'vTipos');
                                vTipos.loadImage("abm", '/FW/image/icons/abm.png')
                                Menus["vTipos"] = vTipos
                                Menus["vTipos"].alineacion = 'centro';
                                Menus["vTipos"].estilo = 'A';


                                Menus["vTipos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
                                                                    "<Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM</Desc><Acciones><Ejecutar Tipo='script'>" +
                                                                    "<Codigo>abmGrupos()</Codigo></Ejecutar></Acciones></MenuItem>")

                                Menus["vTipos"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 30%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Grupos</Desc></MenuItem>")
                                Menus["vTipos"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 20%; text-align:center; vertical-align:middle'>" +
                                                                    "<Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Rel Tipo/Grupo</Desc><Acciones><Ejecutar Tipo='script'>" +
                                                                    "<Codigo>ventanaComentariosTipoGrupo()</Codigo></Ejecutar></Acciones></MenuItem>")
                                Menus["vTipos"].CargarMenuItemXML("<MenuItem id='4' style='WIDTH: 30%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Tipos</Desc></MenuItem>")

                                Menus["vTipos"].CargarMenuItemXML("<MenuItem id='5' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
                                                                    "<Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>ABM</Desc><Acciones><Ejecutar Tipo='script'>" +
                                                                    "<Codigo>abmTipos()</Codigo></Ejecutar></Acciones></MenuItem>")


                                vTipos.MostrarMenu()
                            </script>
                        </td>
                    
                    </tr>
                    <tr id="trGrupoTipo" >
                        <td>
                            <div id="divFrameGrupo" style="height:100%">
                            <iframe id="iframeGrupos" name="iframeGrupos" style="width: 100%; height: 100%;min-height:40px; border: 0.1px solid; border-color:dimgray;border-radius:5px"></iframe>
                                </div>
                        </td>
                        <td style="width:5px"></td>
                        <td><div id="divFrameTipo" style="height:100%">
                            <iframe id="iframeTipos" name="iframeTipos" style="width: 100%; height: 100%;min-height:40px; border: 0.1px solid; border-color:dimgray;border-radius:5px"></iframe>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>

    </table>
</body>
</html>
