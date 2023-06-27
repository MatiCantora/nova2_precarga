<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%   
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err = New nvFW.tError

    If (modo = "ajax_call") Then
        If (accion = "guardar") Then
            Dim strXml As String = nvFW.nvUtiles.obtenerValor("xml", "")
            Dim nro_circuito As String = nvFW.nvUtiles.obtenerValor("nro_circuito", "")
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_nv_cir_com_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXml.Length, strXml)
            cmd.addParameter("@nro_circuito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 0, Int32.Parse(nro_circuito))

            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then
                Dim numError As Integer = rs.Fields("numError").Value

                If numError <> 0 Then
                    err.numError = numError
                    err.mensaje = rs.Fields("mensaje").Value
                    err.titulo = rs.Fields("titulo").Value
                    err.debug_desc = rs.Fields("debug_desc").Value
                    err.debug_src = rs.Fields("debug_src").Value
                End If
            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)
            err.response()
        End If
    End If

    Me.contents("filtroCircuitos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verNv_circuito_comentarios'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroTipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>distinct nro_com_tipo as id, com_tipo as [campo] </campos><filtro></filtro><orden>[ID]</orden></select></criterio>")
    Me.contents("filtroEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_estados'><campos>distinct nro_com_estado as id, com_estado as [campo] </campos><filtro></filtro><orden>[ID]</orden></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Circuito Comentarios ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var tabla_comentarios_circuitos;
        

        function window_onresize()
        {
            try {
                var body_h = $$('BODY')[0].clientHeight;
                var divCircuito_h = $('divCircuito').getHeight();

                $('div_tabla_comentarios_circuitos').style.height = (body_h - divCircuito_h - 5) + 'px';
                tabla_comentarios_circuitos.resize();
            }
            catch(err) {}
        }


        function window_onload()
        {
            // Bloqueamos los campos si es una modificacion
            tabla_comentarios_circuitos = new tTable()

            // Nombre de la tabla y id de la variable
            tabla_comentarios_circuitos.nombreTabla = "tabla_comentarios_circuitos";

            // Agregamos consulta XML
            tabla_comentarios_circuitos.filtroXML = nvFW.pageContents.filtroCircuitos;
            tabla_comentarios_circuitos.cabeceras = ["Nro Cir Det", "Tipo Origen", "Estado Origen", "Tipo Destino", "Estado Destino", "Estado Destino Dependiente de", ];//, "Estado Origen", "Estado Destino"
            tabla_comentarios_circuitos.async = true;
            tabla_comentarios_circuitos.campos = [
                {
                    nombreCampo: "id_cire_com_detalle", 
                    nro_campo_tipo: 100, 
                    enDB: false, 
                    width: "10%", 
                    editable: false,
                    get_html: function (celda) { 
                        return celda.valor ? celda.valor : '-' 
                    },
                    unico: true, 
                    ordenable: true, 
                    align: 'center'
                },
                {
                    nombreCampo: "com_tipo_origen",
                    id: "nro_com_tipo_origen",
                    campoDefOpciones: { 
                        filtroXML: nvFW.pageContents.filtroTipos, 
                        nro_campo_tipo: 1 
                    },
                    width: "12%", 
                    align: "center",
                    nulleable: true
                },
                {
                    nombreCampo: "com_estado_origen",
                    id: "nro_com_estado_origen",
                    campoDefOpciones: { 
                        filtroXML: nvFW.pageContents.filtroEstados, 
                        nro_campo_tipo: 1
                    },
                    width: "12%",
                    align: "center", 
                    nulleable: true
                },
                {
                    nombreCampo: "com_tipo_destino",
                    id: "nro_com_tipo",
                    campoDefOpciones: { 
                        filtroXML: nvFW.pageContents.filtroTipos, 
                        nro_campo_tipo: 1
                    },
                    width: "15%",
                    align: "center"
                },
                {
                    nombreCampo: "com_estado_destino",
                    id: "nro_com_estado",
                    campoDefOpciones: { 
                        filtroXML: nvFW.pageContents.filtroEstados, 
                        nro_campo_tipo: 1
                    },
                    width: "15%",
                    align: "center"
                },
                {
                    nombreCampo: "com_estado_origen_nuevo",
                    id: "nro_com_estado_origen_nuevo",
                    campoDefOpciones: { 
                        filtroXML: nvFW.pageContents.filtroEstados, 
                        nro_campo_tipo: 1
                    },
                    width: "15%",
                    align: "center",
                    nulleable: true
                }
            ]

            tabla_comentarios_circuitos.camposHide = [{nombreCampo:"nro_circuito"}]
            tabla_comentarios_circuitos.table_load_html();

            window_onresize();
        }


        function confirmar_cambios()
        {
            var msg = "<b>¿Esta seguro que desea confirmar sus cambios?<b><br/>";
            nvFW.confirm(msg, {
                width: 280,
                onShow: function () {},
                onOk: function (win) {
                    guardar();
                    win.close();
                },
                onCancel: function (win) {
                    win.close()
                },
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar'
            });
        }


        function guardar()
        {
            if (!tabla_comentarios_circuitos.validar()) {
                alert("Compruebe que se hayan ingresado correctamente todos los campos.");
                return
            }

            win_cir_com = nvFW.getMyWindow();

            var xml = "<?xml version='1.0' encoding='ISO-8859-1'?><circuitos_msj>" + tabla_comentarios_circuitos.generarXML("circuito") + "</circuitos_msj>";

            nvFW.error_ajax_request('circuito_comentarios_abm.aspx', {
                parameters: {
                    xml: xml,
                    nro_circuito: win_cir_com.options.userData.nro_circuito,
                    modo: "ajax_call",
                    accion: "guardar"
                },
                onSuccess: function (err) {
                    tabla_comentarios_circuitos.refresh();
                },
                onFailure: function (err) {}
            });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()"  style="width: 100%; height: 100%; overflow: hidden;">
    <div id="divCircuito"></div>
    <script type="text/javascript">
        var vCircuitos = new tMenu('divCircuito', 'vCircuitos');

        vCircuitos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vCircuitos.loadImage("abm", '/FW/image/icons/abm.png')

        Menus["vCircuitos"] = vCircuitos
        Menus["vCircuitos"].alineacion = 'centro';
        Menus["vCircuitos"].estilo = 'A';

        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Circuito Comentario Detalles ABM</Desc></MenuItem>")
        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>confirmar_cambios()</Codigo></Ejecutar></Acciones></MenuItem>")

        vCircuitos.MostrarMenu()
    </script>

    <div id="div_tabla_comentarios_circuitos">
        <div id="tabla_comentarios_circuitos" style="width: 100%; background-color: white;"></div>
    </div>
</body>
</html>