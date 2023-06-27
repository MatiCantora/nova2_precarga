<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%   
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err = New nvFW.tError

    If (modo = "ajax_call") Then
        If (accion = "guardar") Then
            Dim strXml As String = nvFW.nvUtiles.obtenerValor("xml", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_nv_circuito_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

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

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            err.response()
        End If
    End If



    Me.contents("filtroCircuitos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cire_circuito'>" +
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
        var tabla_circuitos;
        window.alert = function (msg) {
            window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        }
        function window_onresize() {
            try {


                body_h = $$('BODY')[0].clientHeight;
                var divCircuito_h = $('divCircuito').getHeight();

                $('div_tabla_circuitos').style.height = (body_h - divCircuito_h - 5) + 'px';
                tabla_circuitos.resize();
            } catch (err) {

            }
        }

        function window_onload() {

            //Bloqueamos los campos si es una modificacion
            tabla_circuitos = new tTable()

            //Nombre de la tabla y id de la variable
            tabla_circuitos.nombreTabla = "tabla_circuitos";

            //Agregamos consulta XML
            /*tabla_circuitos.editable = false;
            tabla_circuitos.eliminable = false;
            tabla_circuitos.mostrarAgregar = false;*/
            tabla_circuitos.filtroXML = nvFW.pageContents.filtroCircuitos;
            tabla_circuitos.cabeceras = ["Nro Circuito", "Circuito", "Circuito ASPX", "Ver"];
            tabla_circuitos.async = true;
            tabla_circuitos.campos = [
                {
                    nombreCampo: "nro_circuito", nro_campo_tipo: 100, enDB: false, width: "20%", editable: false,
                    get_html: function (celda) { return celda.valor ? celda.valor : '-' }, unico: true, ordenable: true, align: 'center'
                },
                {
                    nombreCampo: "circuito", nro_campo_tipo: 104, enDB: false, width: "30%"
                }
                ,
                {
                    nombreCampo: "circuito_aspx", nro_campo_tipo: 104, enDB: false, width: "40%",nulleable:true
                }, {
                    nombreCampo: "Ver", nro_campo_tipo: 104, enDB: false,
                    width: "10%", align: "center", admiteNulo: true, editable: false,
                    get_html: function (celda, nombreTabla, campos) {
                        if (campos[2].valor) {
                            return "<img  onclick='mostrarASPX( \"" + campos[2].valor + " \", \"" + campos[1].valor + " \" , \"" + campos[0].valor + " \")' src='/FW/image/icons/ver.png'>"
                        } else {
                            return "";
                        }
                    }
                }
            ]

            tabla_circuitos.table_load_html();

            tabla_circuitos.addOnComplete(function () {
                tabla_circuitos.resize();
            });
            //---------------------
            window_onresize();
        }

        function mostrarASPX(archivoAspx, nombreCircuito, nro_circuito) {

            win_com = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: '/fw/circuito/circuitos_abms/' + archivoAspx,
                title: (nombreCircuito + ' ABM'),
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 800,
                height: 300
            });
            win_com.options.userData = {};
            win_com.options.userData.nro_circuito = nro_circuito;
            //win_com.options.userData.aspx = ;
            win_com.showCenter(true)
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
                                   //tabla_tipos_abm.refresh();
                                   win.close()
                               },
                               okLabel: 'Confirmar',
                               cancelLabel: 'Cancelar'
                           });
        }

        function guardar() {

            if (!tabla_circuitos.validar()) {
                alert("Compruebe que se hayan ingresado correctamente todos los campos.");
                return
            }

            var xml = "<?xml version='1.0' encoding='iso-8859-1'?><circuitos>" + tabla_circuitos.generarXML("circuito")+"</circuitos>";
            
            nvFW.error_ajax_request('cire_circuito_abm.aspx',
                {
                    parameters: {
                        xml: xml,
                        modo: "ajax_call",
                        accion: "guardar"
                    },
                    onSuccess: function (err) {
                        tabla_circuitos.refresh();
                    },
                    onFailure: function (err) {

                    }

                });
        }
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="">
    <div id="divCircuito"></div>
    <script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vCircuitos = new tMenu('divCircuito', 'vCircuitos');
        vCircuitos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vCircuitos.loadImage("abm", '/FW/image/icons/abm.png')
        Menus["vCircuitos"] = vCircuitos
        Menus["vCircuitos"].alineacion = 'centro';
        Menus["vCircuitos"].estilo = 'A';



        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;text-align:center; vertical-align:middle'>" +
                                        "<Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Circuitos ABM</Desc></MenuItem>")

        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'>" +
                                            "<Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'>" +
                                            "<Codigo>confirmar_cambios()</Codigo></Ejecutar></Acciones></MenuItem>")


        vCircuitos.MostrarMenu()
    </script>
    <div id="div_tabla_circuitos">
        <div id="tabla_circuitos" style="width: 100%;  background-color: white;"></div>
    </div>


</body>
</html>
