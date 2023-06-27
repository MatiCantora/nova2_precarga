<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err = New nvFW.tError

    If (modo <> "") Then
        If (accion = "guardar") Then

            Try
                Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("pg_concepto_estado_noti_ABM", ADODB.CommandTypeEnum.adCmdStoredProc)

                Dim pStrXML As ADODB.Parameter
                pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
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

                nvFW.nvDBUtiles.DBCloseRecordset(rs)

            Catch ex As Exception
                err.numError = "100"
                err.mensaje = "Error de ejecución."
                err.titulo = "Error"
                err.debug_desc = ""
                err.debug_src = ""
            End Try

            err.response()

        End If
    End If


    Me.contents("filtroNoti") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_concepto_estado_noti'><campos>nro_pago_concepto, nro_pago_estado, pago_concepto, pago_estados, operador, mail, login</campos><orden>nro_pago_concepto</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroConceptos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPago_conceptos_instruccionPago'><campos>DISTINCT nro_pago_concepto AS id, pago_concepto AS [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroEstados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='pago_estados'><campos>distinct nro_pago_estado as id, pago_estados as  [campo] </campos><orden>[id]</orden></select></criterio>")
    Me.contents("filtroOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>distinct operador as id, strNombreCompleto as  [campo] </campos><orden>[campo]</orden></select></criterio>")

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
        var tabla_destinatario_abm;
        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }

        var win
        function window_onload() {

            win = nvFW.getMyWindow();
            //Bloqueamos los campos si es una modificacion
            tabla_destinatario_abm = new tTable()

            //Nombre de la tabla y id de la variable
            tabla_destinatario_abm.nombreTabla = "tabla_destinatario_abm";

            //Agregamos consulta XML
            tabla_destinatario_abm.filtroXML = nvFW.pageContents.filtroNoti;
            tabla_destinatario_abm.cabeceras = ["Concepto", "Estado", "Operador", "Mail"];
            tabla_destinatario_abm.async = true;
            tabla_destinatario_abm.campos = [
                {
                    nombreCampo: "pago_concepto", id: 'nro_pago_concepto', width: "20%",//,  editable: false,
                    campoDefOpciones: { filtroXML: nvFW.pageContents.filtroConceptos, nro_campo_tipo: 1 }
                },
                {
                    nombreCampo: "pago_estados", id: 'nro_pago_estado', width: "15%", //nro_pago_estado
                    campoDefOpciones: { filtroXML: nvFW.pageContents.filtroEstados, nro_campo_tipo: 1 }
                },
                {
                    nombreCampo: "login", id: 'operador', width: "20%"//, unico: true
                    , nulleable: true,
                    campoDefOpciones: { filtroXML: nvFW.pageContents.filtroOperador, nro_campo_tipo: 3, campo_desc: 'strNombreCompleto', campo_codigo: 'operador' }
                },
                {
                    nombreCampo: "mail", nro_campo_tipo: 104, enDB: false//,
                    //campoDefOpciones: { filtroXML: nvFW.pageContents.filtroPermisos, nro_campo_tipo: 3 }
                }
            ]

            tabla_destinatario_abm.table_load_html();
            tabla_destinatario_abm.addOnComplete(function (tabla) {
                tabla.resize();
            });
            //---------------------
            window_onresize();
        }

        function window_onresize() {
            try {
                var body_h = $$('BODY')[0].clientHeight;
                var divTipos_h = $('divTipos').getHeight();
                //console.log(win.getSize().height);
                $('div_tipos_abm').style.height = (win.getSize().height - divTipos_h - 5) + 'px';
                $('tabla_destinatario_abm').style.height = (win.getSize().height - divTipos_h - 5) + 'px';

                tabla_destinatario_abm.resize();
            } catch (err) {

            }
        }


        function guardar() {

            if (!tabla_destinatario_abm.validar()) {
                alert("Compruebe que se hayan ingresado correctamente todos los campos.");
                return
            }
            
            var strXML = "<?xml version='1.0' encoding='iso-8859-1'?><tipos>" + tabla_destinatario_abm.generarXML("tipo") + "</tipos>";
            objXML = new tXML();
            if (objXML.loadXML(strXML)) {
                var NOD = objXML.selectNodes('tipos/tipo')
                for (var i = 0; i < NOD.length; i++) {
                    //EN CASO DE ELIMINAR REMPLAZA ATRIBUTOS STRING POR ENTEROS
                    if (selectSingleNode('@accion', NOD[i]).value == 'eliminar') {
                        selectSingleNode('@pago_conceptoAnterior', NOD[i]).value = 0
                        selectSingleNode('@pago_estadosAnterior', NOD[i]).value = 0
                        selectSingleNode('@loginAnterior', NOD[i]).value = 0
                    }
                }
            }
            
            strXML = objXML.toString()

            nvFW.error_ajax_request('noti_destinatario_abm.aspx',
                {
                    parameters: {
                        strXML: strXML,
                        modo: "ajax_call",
                        accion: "guardar"
                    },
                    onSuccess: function (err) {

                        nvFW.getMyWindow().close();
                    },
                    onFailure: function (err) {
                        tabla_destinatario_abm.refresh();
                    }

                });
        }
    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" style="">
    <div id="divTipos"></div>
    <script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vTipos = new tMenu('divTipos', 'vTipos');
        vTipos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vTipos.loadImage("abm", '/FW/image/icons/abm.png')
        Menus["vTipos"] = vTipos
        Menus["vTipos"].alineacion = 'centro';
        Menus["vTipos"].estilo = 'A';



        Menus["vTipos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vTipos"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
            "<Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'>" +
            "<Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")

        vTipos.MostrarMenu()
    </script>

    <div id="div_tipos_abm">
        <div id="tabla_destinatario_abm" style="width: 100%; height: 100%; background-color: white;"></div>

    </div>

</body>
</html>
