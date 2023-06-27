<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)
    Dim bcocod As Integer = nvFW.nvUtiles.obtenerValor("bcocod", 0)
    Dim paiscod As Integer = nvFW.nvUtiles.obtenerValor("paiscod", 0)


    If tipdoc > 0 And nrodoc > 0 Then
        'Dim op = nvFW.nvApp.getInstance.operador
        'If (Not op.tienePermiso("permisos_entidades", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos para ver las entidades.")

        Dim camposAct_tcl As String = "tipdoc, nrodoc, paiscod, actcod, actnom, feciniactiv, actprim, tipcod, tipnom"
        Me.contents("actXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cliente_actividad' cn='BD_IBS_ANEXA'><campos>" + camposAct_tcl + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc><bcocod type='igual'>" + bcocod.ToString + "</bcocod><paiscod type='igual'>" + paiscod.ToString + "</paiscod></filtro><orden></orden></select></criterio>")

        Dim camposOp_tcl As String = "tipdoc, nrodoc, paiscod, actcod, tipcod, actlincod, tipactivcod, unidad, fechactiv, monto"
        Me.contents("opXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_Cliente_Activ_linea' cn='BD_IBS_ANEXA'><campos>" + camposOp_tcl + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc><bcocod type='igual'>" + bcocod.ToString + "</bcocod><paiscod type='igual'>" + paiscod.ToString + "</paiscod><tipcod type='igual'>%tipcod%</tipcod><actcod type='igual'>%actcod%</actcod></filtro><orden></orden></select></criterio>")

        'Me.contents("act_tipoXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_act_tipo' cn='BD_IBS_ANEXA'><campos>tipcod as id, tipnom as campo, tipcod</campos><orden>tipnom</orden><filtro></filtro></select></criterio>")
        'Me.contents("act_econXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tcl_act_economica' cn='BD_IBS_ANEXA'><campos>actcod as id, actnom as campo, tipcod</campos><orden>actnom</orden><filtro></filtro></select></criterio>")

        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc
        Me.contents("bcocod") = bcocod
        Me.contents("paiscod") = paiscod

    End If

    Me.contents("filtroActividades") = nvXMLSQL.encXMLSQL("<criterio><select vista='tcl_act_economica'><campos>paiscod,bcocod, tipcod, actcod, codactbcra, actnom</campos><filtro></filtro><orden></orden></select></criterio>")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <title>Cliente Actividad Económica</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            background-color: white;
        }
        #divActividades {
            height: 60%;
        }
        #divOperaciones {
            height: 40%;
        }
        #actividadesTitulo td,
        #operacionesTitulo td {
            border-radius: 0;
        }
        .tb1 td.Tit1 {
            text-align: center;
        }
        .td-icons {
             text-align: center !important;
        }
        .td-icons img {
            vertical-align: middle;
            cursor: pointer;
        }
        .pt-5 {
            padding-top: 5px;
        }
        .pb-5 {
            padding-bottom: 5px;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var myWindow            = nvFW.getMyWindow();
        var vButtonItems        = {}
        var vListButton = null;
        var vAltaButtonItems = {}
        var vAltaListButton = null;

        var codigoTipoActividad = 7;
        var codigoActividad     = 970;



        function getJsonData()
        {
            return { 'codigoTipoActividad': codigoTipoActividad, 'codigoActividad': codigoActividad };
        }
        

        function window_onload()
        {
            loadButtons();

            CargarDatosActividad();

            window_onresize();
        }

        function loadButtons() {
            var vButtonItems = {};

            //Actividades
            vButtonItems[0] = {};
            vButtonItems[0]["nombre"] = "Mostrar";
            vButtonItems[0]["etiqueta"] = "Mostrar";
            vButtonItems[0]["imagen"] = "mostrar";
            vButtonItems[0]["onclick"] = "return actividad.show()";

            vButtonItems[1] = {};
            vButtonItems[1]["nombre"] = "Nuevo";
            vButtonItems[1]["etiqueta"] = "Nueva Activ.";
            vButtonItems[1]["imagen"] = "nuevo";
            vButtonItems[1]["onclick"] = "return actividad.add()";

            vButtonItems[2] = {};
            vButtonItems[2]["nombre"] = "Borrar";
            vButtonItems[2]["etiqueta"] = "Borrar Activ.";
            vButtonItems[2]["imagen"] = "eliminar";
            vButtonItems[2]["onclick"] = "return actividad.delete()";

            vButtonItems[3] = {};
            vButtonItems[3]["nombre"] = "Guardar";
            vButtonItems[3]["etiqueta"] = "Guardar";
            vButtonItems[3]["imagen"] = "guardar";
            vButtonItems[3]["onclick"] = "return actividad.save()";

            //Operaciones
            vButtonItems[4] = {};
            vButtonItems[4]["nombre"] = "OpNuevo";
            vButtonItems[4]["etiqueta"] = "Nueva Oper.";
            vButtonItems[4]["imagen"] = "nuevo";
            vButtonItems[4]["onclick"] = "return operacion.add()";

            vButtonItems[5] = {};
            vButtonItems[5]["nombre"] = "OpBorrar";
            vButtonItems[5]["etiqueta"] = "Borrar Oper.";
            vButtonItems[5]["imagen"] = "eliminar";
            vButtonItems[5]["onclick"] = "return operacion.delete()";


            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("mostrar", '/FW/image/icons/ver.png')
            vListButton.loadImage("nuevo", '/FW/image/icons/agregar.png')
            vListButton.loadImage("eliminar", '/FW/image/icons/eliminar.png');
            vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')
            vListButton.MostrarListButton()

        }


        function window_onresize()
        {
            try
            {
                // Resize sección Actividades Económicas
                var divActividadesGridH = $('divActividadesGrid').getHeight();
                var actividadesTituloH  = $('actividadesTitulo').getHeight();
                //var actividadesAgregarH = $('actividadesAgregar').getHeight();
                $('actividadesDatos').setStyle({ height: divActividadesGridH - actividadesTituloH + 'px' });

                // Resize sección Operaciones
                var divOperacionesH     = $('divOperaciones').getHeight();
                var operacionesTituloH  = $('operacionesTitulo').getHeight();
                //var operacionesAgregarH = $('operacionesAgregar').getHeight();
                $('operacionesDatos').setStyle({ height: divOperacionesH - operacionesTituloH + 'px' });
            }
            catch (e)
            {
                console.error("nvFW:onresize:: " + e.message);
            }
        }

        var actList
        function CargarDatosActividad() {

            actList = []
            $('actListBody').innerHTML = "";

            if (nvFW.pageContents == undefined || nvFW.pageContents.tipdoc == undefined || nvFW.pageContents.nrodoc == undefined) return;

            var rs = new tRS();
            rs.async = true;

            rs.onComplete = function (res) {
                while (!res.eof()) {
                    var act = {
                        tipdoc: res.getdata("tipdoc"),
                        nrodoc: res.getdata("nrodoc"),
                        actcod: res.getdata("actcod"),
                        actnom: res.getdata("actnom") ? res.getdata("actnom") : "",
                        tipnom: res.getdata("tipnom"),
                        actprim: res.getdata("actprim"),
                        tipcod: res.getdata("tipcod")
                    }


                    var fila = '<tr onclick="seleccionarAct(' + actList.length + ')" style="cursor: pointer;"><td width="5px"><input type="radio" name="actRadio" id="radio' + actList.length + '" data-index="' + actList.length + '" style="cursor: pointer;" title="Seleccionar"></td>' +
                        '<td width="5px"><input type="checkbox" name="actprim" title="Primaria" ' + (act.actprim == 1 ? 'checked' : '') +'  onclick="return false;"></td>' +
                        '<td width="15%" nowrap>' + act.tipnom + '</td>' +
                        '<td style="text-align: right">' + act.actcod + '</td>' +
                        '<td>' + act.actnom + '</td></tr >';
                    $$('#actListBody')[0].insert(fila);

                    actList.push(act);

                    res.movenext()
                }

                //Fila para nueva actividad
                var fila_new = '<tr id="tr_act_new" style="display: none"><td width="5px"></td>' +
                    '<td width="5px"><input id="actprim_new" type="checkbox" name="actprim" title="Primaria" ></td>' +
                    '<td width="15%" id="tipo_new" nowrap></td>' +
                    '<td id="actcod_new" style="text-align: right"></td>' +
                    '<td id="actividad_new"></td></tr >';
                $$('#actListBody')[0].insert(fila_new);
                campos_defs.add('tipcod', { target: "tipo_new" })
                campos_defs.add('actcod', {
                    target: "actividad_new",
                    mostrar_codigo: false,
                    onchange: function () {
                        $("actcod_new").update(campos_defs.get_value('actcod'))
                    }
                })


                nvFW.bloqueo_desactivar($("divActividades"), 'bloq_actividades')
            }

            rs.onError = function (res) {
                nvFW.bloqueo_desactivar($("divActividades"), 'bloq_actividades')
                alert(res.lastError.numError + ' - ' + res.lastError.mensaje);
            }

            nvFW.bloqueo_activar($("divActividades"), 'bloq_actividades', 'Cargando actividades económicas de cliente...')
            rs.open(nvFW.pageContents.actXML);
        }

        function seleccionarAct(fila) {
            //limpiarCampos()
            $$("#radio" + fila)[0].checked = true;


        }


        //--- ACTIVIDAD ---
        var actividad = {

            // Ventana donde se despliegan las opciones para agregar una actividad
            winAdd: null,

            getSelected: function() {
                var rSelected = $$("#actListBody input[type=radio]:checked")[0]
                if (rSelected == undefined) {
                    return undefined;
                }

                var actSelected = actList[rSelected.dataset.index]

                return actSelected;
            },

            add: function () {
                $("actprim_new").checked = false
                campos_defs.set_value('actcod', '')
                campos_defs.set_value('tipcod', '')
                $("tr_act_new").show();
            },

            save: function () {
                var datos = {};

                var tipcod = campos_defs.get_value("tipcod")
                var actcod = campos_defs.get_value("actcod")

                if (tipcod == "") {
                    alert("Seleccione un tipo de actividad.")
                    return
                }
                if (actcod == "") {
                    actcod = 0
                    //alert("Seleccione una actividad económica.")
                    //return
                }

                datos["tipcod"] = parseInt(tipcod, 10);
                datos["actcod"] = parseInt(actcod, 10);
                datos["actprim"] = $("actprim_new").checked ? 1 : 0;

                datos["tipdoc"] = parseInt(parent.campos_defs.get_value("tipdoc"), 10);
                datos["nrodoc"] = parseInt(parent.campos_defs.get_value("nrodoc"), 10);
                datos["paiscod"] = nvFW.pageContents.paiscod;
                datos["bcocod"] = nvFW.pageContents.bcocod;

                datos["ef"] = ""
                datos["debug"] = true

                nvFW.error_ajax_request('/voii/ibs/cliente/actividad/scl_itcl_cliente_actividad.aspx', {
                    postBody: JSON.stringify(datos),
                    contentType: "application/json",
                    method: 'post',
                    bloq_msg: "Guardando",
                    bloq_contenedor: $("divActividades"),
                    onFailure: function (err, transport) {
                        console.log(transport.responseText)
                    },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0) {
                            CargarDatosActividad();
                        }

                    },
                    error_alert: true
                });
            },


            /*-----------------------------------
            |         Mostrar Actividad
            |          (función Helper)
            |----------------------------------*/
            show: function()
            {

                var actSelected = actividad.getSelected()
                if (actSelected == undefined) {
                    alert("Seleccione una actividad")
                    return;
                }

                var html = '<table class="tb1" cellspacing="0" cellpadding="0">' +
                    '<tr>' +
                    '<td style="width: 100px;">' +
                    '<table class="tb1">' +
                    '<tr><td style="font: 0.8em Tahoma, Arial, sans-serif; text-align: center;">Actividad</td></tr>' +
                    '<tr><td style="font: bold 1.2em Tahoma, Arial, sans-serif; text-align: center;">' + actSelected.actnom + '</td></tr>' +
                    '<tr><td style="font: 0.8em Tahoma, Arial, sans-serif; text-align: center;">Tipo</td></tr>' +
                    '<tr><td style="font: bold 1.2em Tahoma, Arial, sans-serif; text-align: center;">' + actSelected.tipnom + '</td></tr>' +
                    '</table>' +
                    '</td>' +
                    '</tr>' +
                    '</table>';

                var win = nvFW.createWindow({
                    title:          '<b>Actividad Económica</b>',
                    width:          850,
                    height:         75,
                    destroyOnClose: true
                });

                win.setHTMLContent(html);
                win.showCenter(true);
            },


            /*-----------------------------------
            |             Eliminar
            |----------------------------------*/
            delete: function ()
            {
                var actSelected = actividad.getSelected()
                if (actSelected == undefined) {
                    alert("Seleccione una actividad")
                    return;
                }

                // Confirmar deseo de eliminar
                confirm('¿Desea eliminar la actividad seleccionada?',
                    {
                        okLabel: 'Eliminar',
                        onOk: function (win)
                        {
                            win.close();

                            var datos = {};

                            datos["paiscod"] = nvFW.pageContents.paiscod;
                            datos["bcocod"] = nvFW.pageContents.bcocod;
                            datos["tipdoc"] = parseInt(actSelected.tipdoc, 10)
                            datos["nrodoc"] = parseInt(actSelected.nrodoc, 10)
                            datos["tipcod"] = parseInt(actSelected.tipcod, 10)
                            datos["actcod"] = parseInt(actSelected.actcod, 10)
                            datos["eliminar_relacionados"] = true
                            datos["ef"] = ""

                            nvFW.error_ajax_request('/voii/ibs/cliente/actividad/scl_dtcl_cliente_actividad.aspx', {
                                postBody: JSON.stringify(datos),
                                contentType: "application/json",
                                method: 'post',
                                bloq_msg: "Eliminando",
                                onFailure: function (err, transport) { console.log(transport.responseText) },
                                onSuccess: function (err, transport) {
                                    if (err.numError == 0) {
                                        CargarDatosActividad();
                                    }

                                },
                                error_alert: true
                            });
                        }
                    });
            },

        };


        //--- Operación ---
        var operacion = {

            load: function (tipcod, actcod) {

            },
            
            /*-----------------------------------
            |               Agregar
            |----------------------------------*/
            add: function ()
            {
                var title = '<b>Agregar Operación</b>';
                var body  = '<b>AQUÍ</b>: window con las opciones para agregar una <b>OPERACIÓN</b>!';
                var win   = nvFW.createWindow({
                    title:          title,
                    width:          500,
                    height:         300,
                    destroyOnClose: true,
                    onClose: function(w) {}
                });

                win.setHTMLContent(body);
                win.showCenter(true);
            },


            /*-----------------------------------
            |              Eliminar
            |----------------------------------*/
            delete: function (paiscod, bcocod, tipcod, actcod, codactbcra, idOperacion)
            {
                confirm('¿Desea eliminar la operación seleccionada?',
                    {
                        okLabel: 'Eliminar',
                        onOk: function (win)
                        {
                            win.close();

                            if (!paiscod || !bcocod || !tipcod || !actcod || !codactbcra || !idOperacion) {
                                alert('Uno o más parámetros son nulos o inválidos.');
                                return;
                            }

                            nvFW.error_ajax_request('cliente_abm_actividadEconomica.aspx',
                                {
                                    parameters: {
                                        modo:        'OPERATION',
                                        action:      'DELETE',
                                        paiscod:     paiscod,
                                        bcocod:      bcocod,
                                        tipcod:      tipcod,
                                        actcod:      actcod,
                                        codactbcra:  codactbcra,
                                        idOperacion: idOperacion
                                    },
                                    onSuccess: function (res) {
                                        console.log(res.params);
                                        alert('Operación eliminada con éxito.');
                                    },
                                    onFailure: function (res) {
                                        alert(res.numError + ' - ' + res.mensaje);
                                    },
                                    error_alert: false,
                                    bloq_msg: 'Eliminando operación...'
                                });
                        }
                    });
            }
        };
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()">
    
    <%--Listado de Actividades Ecnomicas de la empresa--%>
    <div id="divActividades">
        <div id="divActividadesGrid" style="width: 80%; float:left;">
            <div id="actividadesTitulo">
                <table class="tb1" cellpadding="0" cellspacing="0" id="tbTitulo">
                    <tr class="tbLabel">
                        <td>Actividades Económicas de la Empresa</td>
                    </tr>
                </table>
            </div>

            <div id="actividadesDatos">
                <table class="tb1 highlightTROver highlightEven">
                    <thead>
                        <tr>
                        <td class="Tit1">&nbsp;</td>
                        <td class="Tit1">Act. Prim.</td>
                        <td class="Tit1">Clasificación</td>
                        <td class="Tit1">Código</td>
                        <td class="Tit1">Actividad Económica</td>
                    </tr>
                    </thead>
                    <tbody id="actListBody">

                    </tbody>
                </table>
            </div>

        </div>
        <div style="width: 20%; float:left;">
            <div id="divActividadesAcciones"></div>
            <div id="divMostrar">
            </div>
            <div id="divNuevo">
            </div>
            <div id="divBorrar">
            </div>
            <div id="divGuardar">
            </div>
        </div>
    </div>
    


    <%--Listado del Volumen de operaciones--%>
    <div id="divOperaciones" style="width: 80%; float:left;">
        <div id="operacionesTitulo">
            <table class="tb1" cellpadding="0" cellspacing="0">
                <tr class="tbLabel">
                    <td>Volumen de Operaciones</td>
                </tr>
            </table>
        </div>

        <div id="operacionesDatos">
            <table class="tb1 highlightTROver highlightEven">
                <tr>
                    <td class="Tit1" style="width: 40px; height: 18px;">&nbsp;</td>
                    <td class="Tit1">Tipo de Operación</td>
                    <td class="Tit1">Unidad</td>
                    <td class="Tit1">Fecha</td>
                    <td class="Tit1">Monto</td>
                </tr>
                <tr>
                    <td class="td-icons">
                        <img alt="delete_operation" onclick="operacion.delete(54, 312, 7, 8, 108, 10025)" src="/FW/image/icons/eliminar.png" title="Eliminar operación" />
                    </td>
                    <td>Plazo Fijo</td>
                    <td>Pesos</td>
                    <td>01/10/2020</td>
                    <td>85.650.250</td>
                </tr>
            </table>
        </div>

    </div>
    <div style="width: 20%; float:left;">
        <div id="divOperacionesAcciones"></div>
        <div id="divOpNuevo">
        </div>
        <div id="divOpBorrar">
        </div>
        <%--<div id="divGuardar">
        </div>--%>
    </div>

    <div id="divAddOperation" style="display: none;">
        <table class="tb1" style="font-size: 13px;">
            <tr>
                <td></td>
            </tr>
        </table>
    </div>

</body>
</html>
