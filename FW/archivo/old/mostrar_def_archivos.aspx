﻿<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_tipo As String = nvFW.nvUtiles.obtenerValor("id_tipo", "0")
    Dim nro_archivo_id_tipo As String = nvFW.nvUtiles.obtenerValor("nro_archivo_id_tipo", "1")
    Dim nro_def_archivo As String = nvFW.nvUtiles.obtenerValor("nro_def_archivo", "0")

    Dim orden As String = nvFW.nvUtiles.obtenerValor("orden", "")
    Dim operador As Object
    Try
        operador = nvFW.nvApp.getInstance().operador
        Me.contents("permisos_web") = operador.permisos("permisos_web")
    Catch ex As Exception
    End Try

    Dim filtro_idtipo As String = ""
    Dim filtro_nro_def_archivo As String = ""

    If id_tipo <> "0" Then
        filtro_idtipo = "<id_tipo type='igual'>" & id_tipo & "</id_tipo>"
    End If

    If nro_def_archivo <> "0" Then
        '  filtro_nro_def_archivo += "<AND><id_tipo type='isnull'/><nro_def_archivo type='igual'>" & nro_def_archivo & "</nro_def_archivo></AND>"
        filtro_nro_def_archivo += "<nro_def_archivo type='igual'>" & nro_def_archivo & "</nro_def_archivo>"
    End If

    '    If filtro_idtipo <> "" And filtro_nro_def_archivo <> "" Then
    '    filtro_idtipo = "<OR>" & filtro_idtipo
    '   filtro_nro_def_archivo += "</OR>"
    '  End If

    Me.contents("verArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>*</campos><filtro>" + filtro_idtipo + filtro_nro_def_archivo + "</filtro><orden></orden></select></criterio>")

    '"<OR><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo><nro_archivo_id_tipo type='isnull'/></OR>" +
    '"<orden type='igual'>" +
    'orden.ToString() +
    '"</orden>" +
    '"</filtro><orden>momento</orden></select></criterio>")



%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Sistemas ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% =Me.getHeadInit()%>
    <style type="text/css">
        
    </style>
    <script type="text/javascript">
        var alert = function (msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow();
      
        // var id_tipo = win.options.userData.id_tipo;
       //var orden = win.options.userData.nro_com_id_tipo;
        //win.options.userData.seleccionado = 0;

        function window_onload() {
            cargarHistorial();
            window_onresize();
        }

        function cargarHistorial() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.verArchivos,
                parametros: "<parametros><id_tipo><% = id_tipo %></id_tipo><nro_archivo_id_tipo><% = nro_archivo_id_tipo %></nro_archivo_id_tipo><nro_def_archivo_actual><% = nro_def_archivo %></nro_def_archivo_actual></parametros>",
                path_xsl: "report\\archivo\\HTML_ver_archivos_def.xsl",
                formTarget: 'frame_historial',

                //nvFW_mantener_origen: true,
                bloq_contenedor: 'frame_historial',
                async: true,
                cls_contenedor: 'frame_historial',
                funComplete: function () {
                    
                }
            })
        }

        function tryGetValue(nombre, rs) {
            var valor = rs.getdata(nombre);

            return (valor ? valor : '');
        }

        function seleccionar(nro_archivo, path, desc)
        {
            var archivo = path.split('\\').pop();
            win.options.userData.seleccionado = nro_archivo;
            win.options.userData.archivo = archivo;
            win.options.userData.desc = desc;
            win.close();
        }
        function key_Enter() {

        }

        function window_onresize() {

             try
             {
              var dif = Prototype.Browser.IE ? 5 : 2
              var body_h = $$('body')[0].getHeight()
              $('frame_historial').setStyle({ 'height': body_h - dif })

             }
             catch(e){}

        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" onkeypress="return key_Enter()" style="width: 100%; height: 100%; vertical-align: top;">
   <iframe id="frame_historial" name="frame_historial" style="overflow:hidden;width: 100%;height:100%"></iframe>
</body>
</html>
