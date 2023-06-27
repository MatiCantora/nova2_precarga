<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%   
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err = New nvFW.tError

    If (modo = "ajax_call") Then
        If (accion = "guardar") Then
            Dim strXml As String = nvFW.nvUtiles.obtenerValor("xml", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_nv_grupo_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

            Dim pStrXML As ADODB.Parameter
            pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXml.Length, strXml)
            cmd.Parameters.Append(pStrXML)

            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim numError As Integer = rs.Fields.Item("numError").Value

            If numError <> 0 Then
                Err.numError = rs.Fields("numError").Value
                Err.mensaje = rs.Fields("mensaje").Value
                Err.titulo = rs.Fields("titulo").Value
                Err.debug_desc = rs.Fields("debug_desc").Value
                Err.debug_src = rs.Fields("debug_src").Value
                

            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            err.response()
        End If
    End If



    Me.contents("filtroGrupos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_grupos'>" +
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
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var tabla_grupos_abm;
        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }

        function window_onresize() {
            try{

            
            body_h = $$('BODY')[0].clientHeight;
            var divGrupos_h = $('divGrupos').getHeight();
            
            $('div_grupos_abm').style.height = (body_h - divGrupos_h - 5) + 'px';
            tabla_grupos_abm.resize();
            } catch(err){

            }
        }

        function window_onload() {
            
            //Bloqueamos los campos si es una modificacion
            tabla_grupos_abm = new tTable()

            //Nombre de la tabla y id de la variable
            tabla_grupos_abm.nombreTabla = "tabla_grupos_abm";

            //Agregamos consulta XML
            tabla_grupos_abm.filtroXML = nvFW.pageContents.filtroGrupos;
            tabla_grupos_abm.cabeceras = ["Nro Grupo", "Grupo"];
            tabla_grupos_abm.async = true;
            tabla_grupos_abm.campos = [
                {
                    nombreCampo: "nro_com_grupo", nro_campo_tipo: 100, enDB: false, width: "30%", editable: false,
                    get_html: function (celda) { return celda.valor ? celda.valor : '-' }, unico: true, ordenable:true
                },
                {
                    nombreCampo: "com_grupo", nro_campo_tipo: 104, enDB: false, width: "70%"
                }   
            ]

            tabla_grupos_abm.table_load_html();
            
            //---------------------
            window_onresize();
        }
        function confirmar_cambios() {
            var msg = "Esta seguro que desea confirmar sus cambios.";
            Dialog.confirm('<b>' + msg + '</br>'
                           , {
                               width: 280, className: "alphacube",
                               onShow: function () {

                               },
                               onOk: function (win) {
                                   guardar();
                                   win.close();

                               },
                               onCancel: function (win) {
                                   //tabla_grupos_abm.refresh();
                                   win.close()
                               },
                               okLabel: 'Confirmar',
                               cancelLabel: 'Cancelar'
                           });
        }

        function guardar() {
            /*-if (! tabla_grupos_abm.validar()) {
                alert("Compruebe que se hayan ingresado correctamente todos los campos.");
                return
            }*/

            var xml = "<?xml version='1.0' encoding='iso-8859-1'?><grupos>" + tabla_grupos_abm.generarXML("grupo") + "</grupos>";

            nvFW.error_ajax_request('com_grupos_abm.aspx',
                {
                parameters: {
                    xml: xml,
                    modo: "ajax_call",
                    accion: "guardar"
                },
                onSuccess: function (err) {
                    nvFW.getMyWindow().close();
                },
                onFailure: function (err) {
                    tabla_grupos_abm.refresh();
                }
            });
        }
        function ventanaComentariosTipoGrupo() {

            /*ObtenerVentana('frame_ref').location.href = '/fw/comentario/verCom_registro.aspx?nro_entidad=' + $('nro_entidad').value + '&nro_com_id_tipo=5&collapsed_fck=1&do_zoom=0&id_tipo=' + $('nro_entidad').value + '&nro_com_grupo=5';*/
            win_com = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/comentario/com_tipos_grupos_listar.aspx',
                title: ('Relacion Grupo/Tipo ABM'),
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 1024,
                height: 768
            });
            win_com.options.userData = {};

            win_com.showCenter(true)
        }
    </script>

</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="">
    <div id="divGrupos"></div>
    <script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vGrupos = new tMenu('divGrupos', 'vGrupos');
        vGrupos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vGrupos.loadImage("abm", '/FW/image/icons/abm.png')
        Menus["vGrupos"] = vGrupos
        Menus["vGrupos"].alineacion = 'centro';
        Menus["vGrupos"].estilo = 'A';



        Menus["vGrupos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Grupos</Desc></MenuItem>")
        Menus["vGrupos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
                                            "<Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Rel Tipos/Grupos</Desc><Acciones><Ejecutar Tipo='script'>" +
                                            "<Codigo>ventanaComentariosTipoGrupo()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vGrupos"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
                                            "<Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'>" +
                                            "<Codigo>confirmar_cambios()</Codigo></Ejecutar></Acciones></MenuItem>")
       

        vGrupos.MostrarMenu()
    </script>
    <div id="div_grupos_abm">
     <div id="tabla_grupos_abm" style="width: 100%; height:100%; background-color: white;"></div>
     </div>
</body>
</html>
