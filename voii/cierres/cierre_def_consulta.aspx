<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>


<%
    Dim modo = nvFW.nvUtiles.obtenerValor("modo")       ' VA:"Modo Vista Vacia"    V:"Modo Vista"    A:"Modo Alta"  M:"Modo Actualización"
    Dim id_cierre_def = nvFW.nvUtiles.obtenerValor("id_cierre_def")
    Dim nro_cierre_periodo = nvFW.nvUtiles.obtenerValor("nro_cierre_periodo")
    Dim id_win = nvFW.nvUtiles.obtenerValor("id_win")
    If (modo Is Nothing) Then modo = "VA"
    If (id_cierre_def Is Nothing) Then id_cierre_def = 0

    Dim nv_operador = nvFW.nvApp.getInstance.operador

    Me.contents("filtro_cierre_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cierre_tipo'><campos>id_cierre_tipo as id, cierre_tipo as [campo]</campos><orden>cierre_tipo</orden></select></criterio>")
    Me.contents("filtro_verCierre_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierre_def' distinct='true'><campos> id_cierre_def,cierre_def,id_cierre_tipo,cierre_tipo,id_transferencia</campos><orden>cierre_def</orden><filtro></filtro></select></criterio>")

    Dim StrSQL = ""
    Dim strIn = ""

    Dim cierre_def = ""
    Dim cierre_periodo = ""
    Dim cierre_estado = ""
    If (modo = "E") Then
        Dim cn = DBConectar()
        Dim err = New tError()
        Try
            StrSQL += " delete  from cierre_det_operador where id_cierre_det in(select id_cierre_det  from cierre_det where id_cierre_def=" + id_cierre_def + ") \n"
            StrSQL += " delete from cierre_det where id_cierre_def=" + id_cierre_def + " \n"
            StrSQL += " delete from cierre_def_operador where id_cierre_def=" + id_cierre_def + " \n"
            StrSQL += " delete from cierre_def_dep where id_cierre_def=" + id_cierre_def + " \n"
            StrSQL += " delete from cierre_def where id_cierre_def=" + id_cierre_def + " \n"
            Dim Rs = cn.Execute(StrSQL)
            cn.Close()



        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If

%>
<html>
<head>
    <title>ABM Entidades</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var win
        var canc
        vPago_registro = {}
        var arrAcciones = {} //acciones aplicadas a este cierre_def

        //Botones
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return consultar_cierres()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')


        function window_onresize() {
            try {

                var win = nvFW.getMyWindow()
                var dif = Prototype.Browser.IE ? 5 : 5
                var height_datos = $('divDatos').getHeight();
                var height_body = height_datos
                var h = height_body + dif + 12
                if (h > 0) {
                    var hdetCierres = h - 35;

                    win.setSize($$('body')[0].getWidth(), h);

                    $('divDetCierres').setStyle({ 'height': hdetCierres + 'px' });

                }

            }
            catch (e) { }
        }

        function window_onload() {


            var win = getMyWindow()
            inicializar_componentes()
            //window_onresize()        

        }

        function inicializar_componentes() {
            campos_defs.add(
                'id_cierre_tipo',
                {
                    target: 'tdCierre_tipo',
                    nro_campo_tipo: 1,
                    enDB: false,
                    filtroXML: nvFW.pageContents.filtro_cierre_tipo
                })

            vListButtons.MostrarListButton()
        }


        function agregar_cierre() {


            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_cierre = w.createWindow({
                className: 'alphacube',
                title: '<b>Cierre</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                width: 1000,
                height: 350,
                resizable: false,
                onClose: function (win) {

                    if (win.options.userData != null) {
                        var params = new Array()
                        params = win.options.userData.params
                        if (params['status'] == 'OK') {
                            consultar_cierres()
                        }
                    }
                }

            })

            win_cierre.setURL("cierres/cierre_def_configuracion.aspx?modo=VA&id_win=" + win_cierre.getId() + "&=id_cierre_def=" + id_cierre_def)
            win_cierre.showCenter(true)

        }

        var arrCierres = Array()
        function consultar_cierres() {

            var cierre_desc = $F('cierre_desc')
            var id_cierre_tipo = $F('id_cierre_tipo')
            var i = 0
            var strWhere = ""
            if (cierre_desc != '') {
                strWhere += "<cierre_def type='like'>%" + cierre_desc + "%</cierre_def>"
            }

            if (id_cierre_tipo != '') {
                strWhere += "<id_cierre_tipo type='igual'>" + id_cierre_tipo + "</id_cierre_tipo>"
            }


            var rs = new tRS()
            var strHtml = '<table class="tb1" style="width:100%"><tr class="tbLabel"><th style="width:50%">Cierres</th><th style="width:20%">Tipo</th><th style="width:15%">Transferencia</th><th style="width:15%"></th></tr>'
            rs.open(nvFW.pageContents.filtro_verCierre_def, "", strWhere)
            while (!rs.eof()) {
                arrCierres[i] = Array()

                id_cierre_def = rs.getdata('id_cierre_def')
                arrCierres[i]['id_cierre_def'] = id_cierre_def
                cierre_def = rs.getdata('cierre_def')
                arrCierres[i]['cierre_def'] = cierre_def
                id_cierre_tipo = rs.getdata('id_cierre_tipo')
                cierre_tipo = rs.getdata('cierre_tipo')
                id_transferencia = rs.getdata('id_transferencia')
                strHtml += '<tr id="tr_ver' + id_cierre_def + '" )"><td>(' + id_cierre_def + ') ' + cierre_def + '</td><td> ' + cierre_tipo + '</td><td style="text-align:center"><a href="/FW/transferencia/transferencia_ABM.aspx?id_transferencia=' + id_transferencia + '" target="_blank" >' + id_transferencia + '</a></td><td  style="text-align:center"><img onclick="cierre_modificar(' + id_cierre_def + ')"  style="cursor:pointer" src="../../FW/image/icons/editar.png"></td></tr>'
                i++;
                rs.movenext()
            }
            strHtml += '</table>'

            $('divCierres').innerHTML = ""
            $('divCierres').insert({ top: strHtml })
        }

        function cierre_modificar(id_cierre_def) {

            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_cierre = w.createWindow({
                className: 'alphacube',
                title: '<b>Cierre (' + id_cierre_def + ')</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                width: 1000,
                height: 350,
                resizable: false,
                onClose: function (win) {

                    if (win.options.userData != null) {
                        var params = new Array()
                        params = win.options.userData.params
                        if (params['status'] == 'OK') {
                            consultar_cierres()
                        }
                    }
                }


            })

            win_cierre.setURL("cierres/cierre_def_configuracion.aspx?modo=VA&id_cierre_def=" + id_cierre_def + "&id_win=" + win_cierre.getId())
            win_cierre.showCenter(true)
        }


        function cierre_eliminar(id_cierre_def) {
            var cierre_desc = ''
            for (i = 0; i < arrCierres.length; i++) {
                if (arrCierres[i]['id_cierre_def'] == id_cierre_def) {
                    cierre_desc = arrCierres[i]['cierre_def']
                    break
                }
            }


            Dialog.confirm("¿Desea eliminar el cierre '(" + id_cierre_def + ") " + cierre_desc + "' ? Tenga en cuenta que las tareas y controles realizados sobre este cierre, no podran retomarse.",
                                                                       {
                                                                           width: 300,
                                                                           className: "alphacube",
                                                                           okLabel: "Si",
                                                                           cancelLabel: "No",
                                                                           onOk: function (win) {

                                                                               nvFW.error_ajax_request('cierres/cierre_def_consulta.aspx', {
                                                                                   parameters: { id_cierre_def: id_cierre_def, modo: 'E' },
                                                                                   onSuccess: function (err, transport) {

                                                                                       var params = new Array()

                                                                                       params['status'] = ''
                                                                                       if (err.numError != 0) {
                                                                                           alert("Hubo error al eliminar: " + err.descError)
                                                                                       }
                                                                                       win.close()
                                                                                   }
                                                                               });
                                                                               consultar_cierres()
                                                                           },
                                                                           onCancel: function (win) {
                                                                               win.close()

                                                                           }
                                                                       });


        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="" method="post" name="form1" target="frmEnviar">
        <input type="hidden" id="id_win" value="<%=id_win %>" />
        <input type="hidden" id="num_error" name="num_error" value="" />
        <input type="hidden" id="id_cierre_def" name="id_cierre_def" value="<%= id_cierre_def %>" />
        <input type="hidden" id="strXML" name="strXML" value="" />
        <input type="hidden" id="modo" name="modo" value="<%= modo %>" />
        <input type="hidden" id="operador" name="operador" value="<%=nv_operador%>" />
        <input type="hidden" id="nro_cierre_periodo" value="<%=nro_cierre_periodo %>" />
        <div id='divDatos'>
            <div id="divMenuCierre"></div>
            <script type="text/javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuCierre = new tMenu('divMenuCierre', 'vMenuCierre');
                Menus["vMenuCierre"] = vMenuCierre
                Menus["vMenuCierre"].alineacion = 'centro';
                Menus["vMenuCierre"].estilo = 'A';

                vMenuCierre.loadImage("guardar", '/FW/image/icons/guardar.png')

                Menus["vMenuCierre"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuCierre"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 20%'><Lib TipoLib='offLine'>DocMNG</Lib><Desc>ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_cierre()</Codigo></Ejecutar></Acciones><icono>guardar</icono></MenuItem>")
                vMenuCierre.MostrarMenu()
            </script>
            <table class="tb1" style="width: 100%">
                <tr class="tbLabel">
                    <td style="width: 40%">Descripción</td>
                    <td style="width: 30%">Tipo</td>
                    <td style="width: 30%"></td>
                </tr>
                <tr>
                    <td>
                        <input type="text" value="" id="cierre_desc" style="width: 100%" /></td>
                    <td id="tdCierre_tipo"></td>
                    <td style="text-align: center">
                        <div id="divBuscar"></div>
                    </td>
                </tr>
            </table>
            <div id="divCierres" style="width: 100%; height: 80%; border: none; display: block; overflow-y: auto"></div>
        </div>
    </form>
</body>
</html>
