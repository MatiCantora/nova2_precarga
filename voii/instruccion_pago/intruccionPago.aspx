<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_instruccion_pago", 1)) Then Response.Redirect("/FW/error/httpError_401.aspx")
    Me.addPermisoGrupo("permisos_instruccion_pago")

    Me.contents("estado_instruccion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_estado_comp_fondos' cn='BD_IBS_ANEXA'><campos>*</campos><filtro></filtro><orden>fecha_estado DESC, clinrodoc </orden></select></criterio>")
    Me.contents("estado_instruccion_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_instrucciones_movim' cn='BD_IBS_ANEXA'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("estado_instruccion_detalle_saliente") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_comp_fondos_estado_credin' cn='BD_IBS_ANEXA'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("movimientos_internos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_mov_comprob_comp_fondos' cn='BD_IBS_ANEXA'><campos>nro_comp_fondo_concepto as nro_comp_mov_estado, nro_cuenta,titular,nombre_cta, fecha_mov,num_comprob, movimiento, tipo,cbu, importe,seccion_1,seccion_2,renglon1,renglon2,renglon3</campos><filtro></filtro></select></criterio>")


    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim cli_nro_doc As String = nvFW.nvUtiles.obtenerValor("cli_nro_doc", "")
    Dim nro_ref As Integer = nvFW.nvUtiles.obtenerValor("nro_ref", 0)
    Dim err As New tError()


    If (modo = "TX") Then


        Try
            'Garga la transferencia
            Dim tx As New nvFW.nvTransferencia.tTransfererncia
            tx.cargar(10001454)
            tx.param("clinrodoc")("valor") = cli_nro_doc
            tx.param("nro_cf_cab")("valor") = nro_ref


            err = tx.ejecutar()

            If Err.numError <> 0 Then
                Err.numError = -1
                Err.titulo = "No se pudo ejecutar la tarea"
                Err.mensaje = "Error al ejecutar el proceso"
            End If

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.numError = 106
            Err.titulo = "Error en la transferencia"
            Err.mensaje = "Error al ejecutar la transferencia"
        End Try


        Err.response()

    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Instrucciones de pago</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">  

        var Menus
        var vMenuDig
        var vMenuDig2
        var vMenuDig3
        var nro_ref

        function window_onload() {
            //########## BOTONES ###########
            var vButtonItems = {}

            vButtonItems[0] = {}
            vButtonItems[0]["nombre"] = "BtnBuscar";
            vButtonItems[0]["etiqueta"] = "Buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["imagen"] = "buscar";
            vButtonItems[0]["onclick"] = "return buscar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

            vListButton.MostrarListButton()

            /////////////////////////// MENU 1 //////////////////////
            vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
            Menus["vMenuDig"] = {}
            Menus["vMenuDig"] = vMenuDig
            Menus["vMenuDig"].alineacion = 'centro';
            Menus["vMenuDig"].estilo = 'A';

            //vMenuDig.loadImage("nueva", "/fw/image/icons/nueva.png");

            Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>INSTRUCCIONES DE PAGO</Desc></MenuItem>")
            vMenuDig.MostrarMenu()

            /////////////////////////// MENU 2 //////////////////////
            vMenuDig2 = new tMenu('divMenuDig2', 'vMenuDig2');
            Menus["vMenuDig2"] = {}
            Menus["vMenuDig2"] = vMenuDig2
            Menus["vMenuDig2"].alineacion = 'centro';
            Menus["vMenuDig2"].estilo = 'A';
            Menus["vMenuDig2"].loadImage("excel", '/fw/image/icons/excel.png')

            Menus["vMenuDig2"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>MOVIMIENTOS INTERNOS</Desc></MenuItem>")
            Menus["vMenuDig2"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exp_mov_entr()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuDig2.MostrarMenu()

            /////////////////////////// MENU 3 //////////////////////
            vMenuDig3 = new tMenu('divMenuDig3', 'vMenuDig3');
            Menus["vMenuDig3"] = {}
            Menus["vMenuDig3"] = vMenuDig3
            Menus["vMenuDig3"].alineacion = 'centro';
            Menus["vMenuDig3"].estilo = 'A';
            Menus["vMenuDig3"].loadImage("excel", '/fw/image/icons/excel.png')

            Menus["vMenuDig3"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>CREDINES GENERADOS</Desc></MenuItem>")
            Menus["vMenuDig3"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exp_mov_sal()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuDig3.MostrarMenu()

            //////////////////////////////

            let date = new Date();
            var fechaActual = String(date.getDate()).padStart(2, '0') + '/' + String(date.getMonth() + 1).padStart(2, '0') + '/' + date.getFullYear()
            campos_defs.set_value('def_fe_desde', fechaActual)
            


            onresize()
            buscar()
            
        }

        var filtroWhere =""
        function buscar() {
            if (!nvFW.tienePermiso('permisos_instruccion_pago', 2)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            filtroWhere = ""
            if (campos_defs.get_value('circuito_instruccion_pago') != "") {
                filtroWhere += "<circuito type='in'>" + campos_defs.get_value('circuito_instruccion_pago') + "</circuito>"
            }
            if (campos_defs.get_value('def_nro_referencia') != "") {
                filtroWhere += "<nroreferencia type='like'>%" + campos_defs.get_value('def_nro_referencia') + "%</nroreferencia>"
            }
            if (campos_defs.get_value('def_cbu') != "") {
                filtroWhere += "<clicbu type='like'>%"+ campos_defs.get_value('def_cbu') + "%</clicbu>"
            }
            if (campos_defs.get_value('estado_instruccion_pago') != "") {
                filtroWhere += "<estado type='in'>" + campos_defs.get_value('estado_instruccion_pago') + "</estado>"
            }
            if (campos_defs.get_value('def_fe_desde') != "") {
                filtroWhere += "<fecha_estado type='mas'>CONVERT(datetime,'" + campos_defs.get_value('def_fe_desde')  + "',103)</fecha_estado>"
            }
            if (campos_defs.get_value('def_fe_hasta') != "") {
                filtroWhere += "<fecha_estado type='menor'>CONVERT(datetime,'" + campos_defs.get_value('def_fe_hasta') + "',103)</fecha_estado>"
            }
            if (campos_defs.get_value('def_desc') != "") {
                filtroWhere += "<campo type='like'>%" + campos_defs.get_value('def_desc') + "%</campo>"
            }
            if (campos_defs.get_value('nrodoc_instrucc') != "") {
                filtroWhere += "<clinrodoc type='igual'>" + campos_defs.get_value('nrodoc_instrucc') + "</clinrodoc>"
            }
            if (campos_defs.get_value('tipo_docu') != "") {
                filtroWhere += "<clitipdoc type='igual'>" + campos_defs.get_value('tipo_docu') + "</clitipdoc>"
            }
            var cantFilas = Math.floor((($("iframe1").getHeight())) / 21)-1

            console.log(filtroWhere)
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.estado_instruccion,
                path_xsl: "report/instruccion_pago/HTML_instrucciones_pago.xsl",
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtroWhere + "</filtro></select></criterio>",
                formTarget: "iframe1",
                ContentType: "text/html",
                bloq_contenedor: $('iframe1'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe1',
                bloq_msg: "cargando"
            });

            $('iframe2').src = ""
            $('iframe3').src = ""
        }

        var id_select
        function verDetalle(e, id) {
            id_select = id
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.estado_instruccion_detalle,
                path_xsl: "report/instruccion_pago/HTML_instrucciones_pago_detalle.xsl",
                filtroWhere: "<nroreferencia type='igual'>'" + id + "'</nroreferencia>",
                formTarget: "iframe2",
                ContentType: "text/html",
                bloq_contenedor: $('iframe1'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe2',
                bloq_msg: "cargando"
            });
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.estado_instruccion_detalle_saliente,
                path_xsl: "report/instruccion_pago/HTML_instrucciones_pago_detalle_saliente.xsl",
                filtroWhere: "<Referencia type='igual'>'" + id + "'</Referencia>",
                formTarget: "iframe3",
                ContentType: "text/html",
                bloq_contenedor: $('iframe'),
                nvFW_mantener_origen: true,
                cls_contenedor: 'iframe3',
                bloq_msg: "cargando"
            });

            //SELECT * FROM dbo.VOII_comp_fondos_estado_credin   <------ taba para mostrar (mostrar el maximo estado)
            
        }

        function pressEnter() {
            if (window.event.keyCode == 13) {
                buscar()
            }
        }

        function onresize() {
            var alto_body = $('cuerpo').getHeight()-22
            var alto_buscador = $('contenedor').getHeight()
            var alto_menus = $('divMenuDig').getHeight() * 2

            $('iframe1').style.height = (alto_body - alto_buscador - alto_menus) * 0.7 + 'px'
            $('iframe2').style.height = (alto_body - alto_buscador - alto_menus) * 0.3 + 'px'

        }

        function exp_mov_entr() {
            
            var filtroXML = nvFW.pageContents.estado_instruccion_detalle
                nvFW.exportarReporte({
                    filtroXML: filtroXML
                    , filtroWhere: "<nroreferencia type='igual'>'" + id_select + "'</nroreferencia>"
                    , path_xsl: "report\\excel_base.xsl"
                    , salida_tipo: "adjunto"
                    , ContentType: "application/vnd.ms-excel"
                    , formTarget: "iframe1"
                    , filename: `Movimientos Internos - NroRef ${id_select}.xls`
                })
            
        }

        function exp_mov_sal(){
            var filtroXML = nvFW.pageContents.estado_instruccion_detalle_saliente
                nvFW.exportarReporte({
                    filtroXML: filtroXML
                    , filtroWhere: "<Referencia type='igual'>'" + id_select + "'</Referencia>"
                    , path_xsl: "report\\excel_base.xsl"
                    , salida_tipo: "adjunto"
                    , ContentType: "application/vnd.ms-excel"
                    , formTarget: "iframe1"
                    , filename: `Credines generados - NroRef ${id_select}.xls`
                })
            
        }
        
        function generarPDF(nroreferencia, clinrodoc, clitipdoc, nro_comp_fondo_concepto) {
            var filtroXMLPDF = "<orden type='igual'>1</orden><SQL type='sql'>UPPER(nroreferencia) = UPPER('" + nroreferencia + "')</SQL><clitipdoc type='igual'>" + clitipdoc + "</clitipdoc><clinrodoc type='igual'>" + clinrodoc + "</clinrodoc><cuit_cuil type='igual'>'" + clinrodoc + "'</cuit_cuil><nro_comp_fondo_concepto type='igual'>" + nro_comp_fondo_concepto + "</nro_comp_fondo_concepto>"
            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.movimientos_internos,
                filtroWhere: filtroXMLPDF,
                path_reporte: "report\\comprobante\\transferencia\\ibs_comprobante_acreditacion_generico.rpt",
                salida_tipo: "adjunto",
                formTarget: "_blank",
                filename: "detalle_movimiento.pdf"
            })
        }

        function ejecTransferencia(nro_ref, cli_nro_doc) {
            if (!nvFW.tienePermiso('permisos_instruccion_pago', 3)) {
                alert('No posee permisos para hacer esta operacion, consulte al administrador del sistema')
                return
            }
            Dialog.confirm(`¿Desea dar de baja la instruccion?`, {
                width: 300, className: "alphacube",
                onOk: function (win) {

                    nvFW.error_ajax_request('intruccionPago.aspx', {
                        parameters: { modo: 'TX', cli_nro_doc: cli_nro_doc, nro_ref:nro_ref },
                        onSuccess: function (err, transport) {

                            if (err.numError == 0) {
                                win.close()
                            }
                            else {
                                alert(err)
                                console.log(err)
                                return
                            }
                        }
                    });
                },
                okLabel: 'Aceptar',
                cancelLabel: 'Cancelar',
                onCancel: function (win) { win.close() }
            })
        }




    </script>
</head>
<body id="cuerpo" onload="return window_onload()" style="width: 100%; height: 100%" onkeypress="pressEnter()" onresize="onresize()">
    <table id='contenedor' class="tb1">
        <tr class="tbLabel">
            <td style="text-align: center; font-weight: bolder!important; width:12%">Circuito</td>
            <td style="text-align: center; font-weight: bolder!important; width:12%">Nro. Referencia</td>
            <td style="text-align: center; font-weight: bolder!important; width:25%">CBU Cliente</td>
            <td style="text-align: center; font-weight: bolder!important; width:25%">Tipo Documento</td>
            <td style="text-align: center; font-weight: bolder!important; width:25%">Número de documento</td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('circuito_instruccion_pago')
                </script>
            </td> 
            <td>
                <script type="text/javascript">
                    campos_defs.add('def_nro_referencia', { nro_campo_tipo: 101, enDB: false })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('def_cbu', { nro_campo_tipo: 101, enDB: false })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('tipo_docu', { nro_campo_tipo: 2})
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nrodoc_instrucc', {enDB:false,nro_campo_tipo:100})
                </script>
            </td>
        </tr>
        <tr class="tbLabel">
            <td style="text-align: center; font-weight: bolder!important" colspan="2">Estado</td>
            <td style="text-align: center; font-weight: bolder!important">Fecha desde</td>
            <td style="text-align: center; font-weight: bolder!important">Fecha hasta</td>
            <td style="text-align: center; font-weight: bolder!important">Descripción</td>
        </tr>
        <tr>
            <td colspan="2">
                <script type="text/javascript">
                    campos_defs.add('estado_instruccion_pago')
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('def_fe_desde', { nro_campo_tipo: 103, enDB: false })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('def_fe_hasta', { nro_campo_tipo: 103, enDB: false })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('def_desc', { nro_campo_tipo: 104, enDB: false })
                </script>
            </td>
        </tr>
        <tr>
            <td colspan="100%">
                <div id="divBtnBuscar" style="border: 10px"></div>
            </td>
        </tr>
    </table>
    <div id="divMenuDig"></div>
    <iframe name="iframe1" id="iframe1" style="overflow: auto; width: 100%" frameborder='0'></iframe>
    <div style="display:flex">
    <div style="display:inline-block;width:65%; border-right: 3px solid gray ">
        <div id="divMenuDig2"></div>
        <iframe name="iframe2" id="iframe2" style="overflow: auto; width: 100%" frameborder='0'></iframe>
    </div>
    <div style="display:inline-block;width:35%;border-left: 3px solid gray">
        <div id="divMenuDig3"></div>
        <iframe name="iframe3" id="iframe3" style="overflow: auto; width: 100%" frameborder='0'></iframe>
    </div>
        </div>




    <%--    <iframe name="iframe1" id="iframe1" style="width: 100%;height:80%; max-height: 817px; overflow: auto" frameborder='0'></iframe>--%>
</body>
</html>

