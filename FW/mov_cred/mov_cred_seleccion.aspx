<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("filtroMov") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_mov_cartera' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroDet") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_mov_cartera_det' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_cab' cn='BD_IBS_ANEXA'><campos>id_mov as id,descripcion as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_tipos' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_estados") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_estados' cn='BD_IBS_ANEXA'><campos>estado_mov as id,estado_desc_mov as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_recursos_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_recursos_tipos' cn='BD_IBS_ANEXA'><campos>nro_mov_recurso_tipo as id,mov_recurso_tipo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("entidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("entidades_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>nrodoc as id,razon_social as campo</campos><orden></orden><filtro><razon_social type='like'>%BANCO%</razon_social></filtro></select></criterio>")
    Me.contents("admin_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>nrodoc as id,razon_social as campo</campos><orden></orden><filtro><razon_social type='like'>%MUTUAL%</razon_social></filtro></select></criterio>")
    Me.contents("dateToDay") = DateTime.Now.ToString("dd/MM/yyyy")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de Movimientos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit() %>


    <script type="text/javascript">

        var paiscod
        var bcocod
        var tipodoc 
        var nrodoc
        var tipocli

        var paiscodOr
        var bcocodOr
        var tipodocOr 
        var nrodocOr
        var tipocliOr

        var paiscodDes
        var bcocodDes
        var tipodocDes 
        var nrodocDes
        var tipocliDes


        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return listaMovCred()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")

        var nr
        var paiscod
        var bcocod
        var tipodoc
        var nrodoc
        var tipocli

        var win = nvFW.getMyWindow()

        function window_onload() {
            //vListButton.MostrarListButton()
            window_onresize()
        }

        function window_onresize() {

            var heiFrame = document.body.getBoundingClientRect().height - $('tablaCont').getBoundingClientRect().height - $('divMenuEstado').getBoundingClientRect().height

            //var heiVal = document.body.getBoundingClientRect().height - $('destino').getBoundingClientRect().height - $('destino').getBoundingClientRect().top
            //var topVal = $('tablaCont').getBoundingClientRect().height - $('ori_des').getBoundingClientRect().height/* - $('destino').getBoundingClientRect().top*/
            //var leftVal = $('destino').getBoundingClientRect().left

            //var topValOr = $('tablaCont').getBoundingClientRect().height - $('ori_des').getBoundingClientRect().height /*- $('origen').getBoundingClientRect().top*/
            //var leftValOr = $('origen').getBoundingClientRect().left

            //var widthVal = $('destino').getBoundingClientRect().width
            //var widthValOr = $('origen').getBoundingClientRect().width

            //$('listaEntDes').setStyle({ top: '-' + topVal + 'px', left: leftVal + 1 + 'px', width: widthVal - 2 + 'px', height: topVal + 'px', height: heiVal - 30 + 'px'  })
            //$('listaEntOr').setStyle({ top: '-' + topValOr + 'px', left: leftValOr - 1 + 'px', width: widthValOr - 2 + 'px', height: topValOr + 'px', height: heiVal - 30 + 'px' })
            $('listaMovCreditos').setStyle({ height: heiFrame - 5 + 'px' })
        }

        function verEntidades(n) {

            var strCriterio = nvFW.pageContents.entidades
            var rs = new tRS();
            
            if (n == 1) {
                nr = 1
                rs.open({
                    filtroXML: strCriterio,
                    filtroWhere: "<criterio><select><filtro><razon_social type='igual'>" + $('inOrigen').value +"</razon_social></filtro></select></criterio>"
                })
            } else {
                nr = 0
                rs.open({
                    filtroXML: strCriterio,
                    filtroWhere: "<criterio><select><filtro><razon_social type='igual'>" + $('inDest').value +"</razon_social></filtro></select></criterio>"
                })
            }

            var razSocial = rs.getdata('razon_social')
            var paiscod1 = rs.getdata('paiscod')
            var bcocod1 = rs.getdata('bcocod')
            var tipodoc1 = rs.getdata('tipdoc')
            var nrodoc1 = rs.getdata('nrodoc')
            var tipocli1 = rs.getdata('tipcli')

            set_value(razSocial, paiscod1, bcocod1, tipodoc1, nrodoc1, tipocli1)
        }

        function set_value(razSocial, paiscod1, bcocod1, tipodoc1, nrodoc1, tipocli1) {

            paiscod = paiscod1
            bcocod = bcocod1
            tipodoc = tipodoc1
            nrodoc = nrodoc1
            tipocli = tipocli1

            if (nr == 1) {
                paiscodOr = paiscod1
                bcocodOr = bcocod1
                tipodocOr = tipodoc1
                nrodocOr = nrodoc1
                tipocliOr = tipocli1

            } else {
                paiscodDes = paiscod1
                bcocodDes = bcocod1
                tipodocDes = tipodoc1
                nrodocDes = nrodoc1
                tipocliDes = tipocli1

            }

        }

        function listHid(n) {
            if (n == 1) {
                $('listaEntDes').setStyle({ display: 'none' })
            } else {
                $('listaEntOr').setStyle({ display: 'none' })
            }
        }

        var win_archivos_def_tipo_abm
        function nuevoMov() {

                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_archivos_def_tipo_abm = w.createWindow({
                    className: 'alphacube',
                    url: '/fw/mov_cred/mov_cred_ABM.aspx?accion=0&parentWin=' + win,
                    title: '<b>Administrador de movimientos</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    resizable: true,
                    width: 1000,
                    height: 300,
                    onClose: function () { listaMovCred() }
                });

                win_archivos_def_tipo_abm.showCenter()
        }

        function editar_movimiento(id_mov, acc) {
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_archivos_def_tipo_abm = w.createWindow({
                className: 'alphacube',
                url: '/fw/mov_cred/mov_cred_ABM.aspx?accion=1&id_mov=' + id_mov + '&parentWin=' + win,
                title: '<b>Administrador de movimientos</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                resizable: true,
                width: 1000,
                height: 300,
                onClose: function () { }
            });

            win_archivos_def_tipo_abm.showCenter()
        }

        var filtro = ""
        function filtrar() {
            filtro = ""

            if ($('desc').value != "") {
                filtro += "<descripcion type='like'>%" + $('desc').value + "%</descripcion>"
            }

            if ($('nro_mov').value != "") {
                filtro += "<id_mov type='in'>" + $('nro_mov').value + "</id_mov>"
            }

            var date1 = $('fecha_venta_1').value.substr(3, 2) + "/" + $('fecha_venta_1').value.substr(0, 2) + "/" + $('fecha_venta_1').value.substr(6, 4)
            if ($('fecha_venta_1').value != "") {
                filtro += "<fe_mov type='mas'>convert(datetime,'" + date1 + "',103)</fe_mov>"
            }

            var date2 = $('fecha_venta_2').value.substr(3, 2) + "/" + $('fecha_venta_2').value.substr(0, 2) + "/" + $('fecha_venta_2').value.substr(6, 4)
            if ($('fecha_venta_2').value != "") {
                filtro += "<fe_mov type='menor'>convert(datetime,'" + date2 + "',103)</fe_mov>"
            }

            var date_1 = $('fecha_estado_1').value.substr(3, 2) + "/" + $('fecha_estado_1').value.substr(0, 2) + "/" + $('fecha_estado_1').value.substr(6, 4)
            if ($('fecha_estado_1').value != "") {
                filtro += "<fe_estado_mov type='mas'>convert(datetime,'" + date_1 + "',103)</fe_estado_mov>"
            }

            var date_2 = $('fecha_estado_2').value.substr(3, 2) + "/" + $('fecha_estado_2').value.substr(0, 2) + "/" + $('fecha_estado_2').value.substr(6, 4)
            if ($('fecha_estado_2').value != "") {
                filtro += "<fe_estado_mov type='mas'>convert(datetime,'" + date_2 + "',103)</fe_estado_mov>"
            }

            if ($('monto_1').value != "") {
                filtro += "<monto_mov type='mas'>" + $('monto_1').value + "</monto_mov>"
            }

            if ($('monto_2').value != "") {
                filtro += "<monto_mov type='menor'>" + $('monto_2').value + "</monto_mov>"
            }

            if ($('tasa_1').value != "") {
                filtro += "<tasa_mov type='mas'>" + $('tasa_1').value + "</tasa_mov>"
            }

            if ($('tasa_2').value != "") {
                filtro += "<tasa_mov type='menor'>" + $('tasa_2').value + "</tasa_mov>"
            }

            if ($('mov_tipos').value != "") {
                filtro += "<nro_mov_tipo type='in'>" + $('mov_tipos').value + "</nro_mov_tipo>"
            }

            if ($('mov_recursos_tipos').value != "") {
                filtro += "<nro_mov_recurso_tipo type='in'>" + $('mov_recursos_tipos').value + "</nro_mov_recurso_tipo>"
            }

            if ($('inOrigen').value != "") {
                filtro += "<nrodoc_origen type='in'>" + $('inOrigen').value + "</nrodoc_origen>"
            }

            if ($('inDest').value != "") {
                filtro += "<nrodoc_destino type='in'>" + $('inDest').value + "</nrodoc_destino>"
            }

            if ($('mov_estados').value != "") {
                filtro += "<estado_mov type='in'>'" + $('mov_estados').value + "'</estado_mov>"
            }

        }

        function listaMovCred() {
            filtrar()

            if ($('tipo_vista').value == 'AO') {
                //var fWhere = ""

                //if ($('mov_tipos').value != "") {
                //    fWhere = "<nro_mov_tipo type='in'>" + $('mov_tipos').value + "</nro_mov_tipo>"
                //}

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroMov,
                    filtroWhere: "<criterio><select ><filtro>" + filtro +"</filtro></select></criterio>",
                    path_xsl: "report\\verMov_cred\\mov_tipo.xsl",
                    formTarget: 'listaMovCreditos',
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    bloq_contenedor: $('listaMovCreditos'),
                    cls_contenedor: 'listaMovCreditos'
                })

            } else {

                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroMov,
                    filtroWhere: "<criterio><select ><filtro>" + filtro + "</filtro></select></criterio>",
                    path_xsl: "report\\verMov_cred\\mov_cred.xsl",
                    formTarget: 'listaMovCreditos',
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    bloq_contenedor: $('listaMovCreditos'),
                    cls_contenedor: 'listaMovCreditos'
                })
            }

        }

        function eliminar_movimiento(id_mov1) {
            Dialog.confirm('<b>¿Esta seguro de que desea eliminar este Movimiento y sus Operaciones?</b>', {
                width: 425,
                className: "alphacube",
                okLabel: "SI",
                cancelLabel: "NO",
                onOk: function (win) {

                    id_mov = id_mov1
                    accion = 2

                    nvFW.error_ajax_request('mov_cred_ABM.aspx', {
                        parameters: { id_mov: id_mov1, accion: accion },
                        onSuccess: function (err, transport) {
                            if (err.numError != 0) {
                                alert(err.mensaje)
                                return
                            }
                            //parent.listaMovCred()
                            win.close()
                            nvFW.pageContents.parentWin.listaMovCred()
                        },
                    })

                }

            })


        }

        function mostrar_mov(frame, nro) {
            var fWhere = ""

            if ($('admin').value != '') {
                fWhere += "<nrodoc_admin type='in'>%" + $('admin').value + "%</nrodoc_admin>"
            }

            if ($('nro_oper').value != "") {
                fWhere += "<openro type='in'>" + $('nro_oper').value + "</openro>"
            }

            var filtroWhere = "<criterio><select><filtro><id_mov type='igual'>" + nro + "</id_mov>" + fWhere +"</filtro></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroDet,
                filtroWhere: filtroWhere,
                path_xsl: 'report\\verMov_cred\\mov_tipo_cred.xsl',
                formTarget: 'movi' + nro,
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                cls_contenedor: 'movi' + nro
            })
        }

        function exportarExcel() {
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroMov,
                filtroWhere: '<criterio><select><filtro>' + filtro + '</filtro></select></criterio>',
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "Movimientos.xls"

            })
        }

        function exportarExcelOp(nro) {
            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.filtroMov,
                filtroWhere: "<criterio><select><filtro><id_mov type='igual'>" + nro + "</id_mov></filtro></select></criterio>"
            })

            var fWhere = ""

            if ($('admin').value != '') {
                fWhere += "<nrodoc_admin type='in'>" + $('admin').value + "</nrodoc_admin>"
            }

            if ($('nro_oper').value != "") {
                fWhere += "<openro type='in'>" + $('nro_oper').value + "</openro>"
            }

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtroDet,
                filtroWhere: "<criterio><select><filtro><id_mov type='igual'>" + nro + "</id_mov>" + fWhere + "</filtro></select></criterio>",
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "Movimiento_operaciones.xls",
                parametros: "<parametros><columnHeaders><table><tr><td>" + nro + "</td><td colspan='5'>" + rs.getdata('descripcion') + "</td><td colspan='3'>" + rs.getdata('razon_social_origen') + "</td><td colspan='3'>" + rs.getdata('razon_social_destino') + "</td><td colspan='3'>" + rs.getdata('mov_tipo') + "</td><td  colspan='3'>" + rs.getdata('mov_recurso_tipo') + "</td><td colspan='2'>" + rs.getdata('estado_desc_mov') +"</td></tr></table></columnHeaders></parametros>"
            })
        }

        function changeView() {
            if ($('tipo_vista').value == 'AO') {
                campos_defs.habilitar('admin', true)
                $('nro_oper').disabled = false
            } else {
                campos_defs.habilitar('admin', false)
                campos_defs.clear('admin')

                $('nro_oper').disabled = true
                $('nro_oper').value = ''
            }
        }

        function transferencia_cartera(id_mov) {
            var win_transf = window.top.nvFW.createWindow({
                title: '<b> Alta Movimiento </b>',
                minimizable: false,
                maximizable: true,
                maximize: true,
                draggable: true,
                width: 1100,
                height: 600,
                resizable: true,
                onClose: function (w) {

                    //listaMovCred();
                    win_transf.destroy()
                }
            });
            win_transf.setURL('/fw/transferencia/transf_ejecutar.aspx?id_transferencia=103')
            win_transf.showCenter()
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
            <div id="divMenuEstado" style="margin: 0px; padding: 0px;"></div>
            <script>
                var vMenuEstado = new tMenu('divMenuEstado', 'vMenuEstado');
                vMenuEstado.loadImage("nueva", "/fw/image/icons/nueva.png")
                vMenuEstado.loadImage("excel", "/fw/image/icons/excel.png")
                vMenuEstado.loadImage("buscar", "/fw/image/icons/buscar.png")
                vMenuEstado.loadImage("procesar", "/fw/image/icons/procesar.png")
                Menus["vMenuEstado"] = vMenuEstado
                Menus["vMenuEstado"].alineacion = 'centro';
                Menus["vMenuEstado"].estilo = 'A';
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='width: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Administrador de movimientos</Desc></MenuItem>")
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='1' style='width: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>procesar</icono><Desc>Alta Mov.</Desc><Acciones><Ejecutar Tipo='script'><Codigo>transferencia_cartera(213)</Codigo></Ejecutar></Acciones></MenuItem>")
               // Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='2' style='width: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoMov()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='3' style='width: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarExcel()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='4' style='width: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>listaMovCred()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuEstado.MostrarMenu()
            </script>
<table id="tablaCont" style="width:100%" class="tb1">   
    <tr>
        <td style="width:80%">
            <table id="ori_des"  style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="width: 10%; text-align:center">Nro. Mov</td>
                    <td style="width: 10%; text-align:center">Nro. Oper</td>
                    <td style="width: 40%; text-align:center">Origen</td>
                    <td style="width: 40%; text-align:center">Destino</td>
                </tr>
                <tr>
                    <td>
<%--                        <script type="text/javascript">
                            campos_defs.add('nro_mov', { enDB: false, nro_campo_tipo: 101 })
                        </script>--%>
                        <input id="nro_mov" style="width:100%" type="text" >
                    </td>
                    <td>
<%--                        <script type="text/javascript">
                            campos_defs.add('nro_oper', { enDB: false, nro_campo_tipo: 101 })
                            campos_defs.habilitar('nro_oper', false)
                        </script>--%>
                        <input id="nro_oper" style="width:100%" type="text" disabled >
                    </td>
                    <td id="origen" style="text-align:center" >
<%--                        <img id="orPlus" src="/fw/image/icons/agregar.png" style="cursor: pointer" onclick="verEntidades(1)" /><input id="inOrigen" onclick="verEntidades(1)" style="width: 100%; display:none" type="text" />--%>
                        <script type="text/javascript">
                            campos_defs.add('inOrigen', {
                                enDB: true,
                                nro_campo_tipo: 2,
                                //filtroXML: nvFW.pageContents.entidades_def
                            })
                            campos_defs.items['inOrigen'].onchange = function (campo_def) {
                                verEntidades(1)
                            }
                        </script>
                    </td>
                    <td id="destino" style="text-align:center" >
<%--                        <img id="desPlus" src="/fw/image/icons/agregar.png" style="cursor: pointer" onclick="verEntidades()" /><input id="inDest" onclick="verEntidades(0)" style="width: 100%; display:none" type="text" />--%>
                        <script type="text/javascript">
                            campos_defs.add('inDest', {
                                enDB: true,
                                nro_campo_tipo: 2,
                                //filtroXML: nvFW.pageContents.entidades_def
                            })
                            campos_defs.items['inDest'].onchange = function (campo_def) {
                                verEntidades(0)
                            }
                        </script>
                    </td>
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center;width:20%" colspan="2">Fecha movimiento</td>
                    <td style="text-align:center;width:40%">Tipo movimiento</td>                    
                    <td style="text-align:center;width:40%">Tipo recurso</td>
                </tr>
                <tr>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_venta_1', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_venta_2', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>                
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_tipos', {
                                enDB: true,
                                nro_campo_tipo: 2,
                                //filtroXML: nvFW.pageContents.mov_tipos
                            })
                        </script>
                    </td>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_recursos_tipos', {
                                enDB: true,
                                nro_campo_tipo: 2,
                                //filtroXML: nvFW.pageContents.mov_recursos_tipos
                            })
                        </script>
                    </td> 
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr style="width:100%" class="tbLabel">
                    <td style="text-align:center;width:21% !important">Administradora</td>
                    <td colspan="4" style="text-align:center;width:20% " >Monto movimiento</td>
                    <td colspan="4" style="text-align:center;width:18% ">Tasa</td>
                    <td style="text-align:center;width:41% !important">Descripción</td>
                </tr>
                <tr style="width:100%">
                    <td style="width:20%" >
                        <script type="text/javascript">
                            campos_defs.add('admin', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.admin_def
                            })
                            campos_defs.habilitar('admin', false)
                        </script>
                    </td>
                    <td style="">$</td>
                    <td style="">
                        <script type="text/javascript">
                            campos_defs.add('monto_1', { enDB: false, nro_campo_tipo: 102 })
                            //$('monto_1').setStyle({ width: '98%' })
                        </script>
                    </td>
                    <td style="text-align:center"><span>hasta</span></td>
                    <td  style="">
                         <script type="text/javascript">
                             campos_defs.add('monto_2', { enDB: false, nro_campo_tipo: 102 })
                                //$('monto_2').setStyle({ width: '98%' })
                        </script>
                    </td>
                    <td style="">
                        <script type="text/javascript">
                            campos_defs.add('tasa_1', { enDB: false, nro_campo_tipo: 102 })
                            //$('tasa_1').setStyle({ width: '98%' })
                        </script>
                    </td>
                    <td style="text-align:center"><span>hasta</span></td>
                    <td style="">
                         <script type="text/javascript">
                             campos_defs.add('tasa_2', { enDB: false, nro_campo_tipo: 102 })
                                //$('tasa_2').setStyle({ width: '98%' })
                        </script>
                    </td>
                    <td style="">%</td>
                    <td style="width:40%" ><input style="width:100%" id="desc" type="text" /></td>
                </tr>
            </table>
        </td>
        <td style="width:20%">
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center">Vista</td>
                </tr>
                <tr style="display:inline-flex; width:100%">
                    <td style="width:100%; display:flex">
                        <select id='tipo_vista' style="width: 100%" onchange="changeView()">
                            <option value='AM'>Listado por movimiento</option>
                            <option value='AO'>Agrupado por operaciones</option>
                        </select>
                    </td>
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center" >Estado</td>
                </tr>
                <tr style="display:inline-flex; width:100%">
                    <td  style="width:100%; display:flex">
                        <script type="text/javascript">
                            campos_defs.add('mov_estados', {
                                //filtroXML: nvFW.pageContents.mov_estados,
                                enDB: true,
                                nro_campo_tipo: 2
                            })
                        </script>
                    </td>
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="width: 100%; text-align:center" colspan="2">Fecha estado</td>
                </tr>
                <tr>                
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_estado_1', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_estado_2', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<%--<div id="listaEntDes" onclick="listHid(1)" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none; z-index: 3;"></div>
<div id="listaEntOr" onclick="listHid()" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none; z-index: 3;"></div>--%>
<div style="z-index: 0">
    <iframe id="listaMovCreditos" name="listaMovCreditos" style="width: 100%; height: 100%; overflow:auto; border:none; background-color:white"></iframe>
</div>
</body>
</html>
