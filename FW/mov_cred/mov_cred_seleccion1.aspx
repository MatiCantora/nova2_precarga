<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("filtroMov") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_cab' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_cab' cn='BD_IBS_ANEXA'><campos>id_mov as id,descripcion as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_tipos' cn='BD_IBS_ANEXA'><campos>nro_mov_tipo as id,mov_tipo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_estados") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_estados' cn='BD_IBS_ANEXA'><campos>estado_mov as id,estado_desc_mov as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("mov_recursos_tipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='mov_recursos_tipos' cn='BD_IBS_ANEXA'><campos>nro_mov_recurso_tipo as id,mov_recurso_tipo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("entidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("entidades_def") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>nrodoc as id,razon_social as campo</campos><orden></orden><filtro><razon_social type='like'>%BANCO%</razon_social></filtro></select></criterio>")
    Me.contents("dateToDay") = DateTime.Now.ToString("dd/MM/yyyy")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Movimientos de Prestamos</title>
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
            vListButton.MostrarListButton()
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
                    title: '<b>Movimientos de Prestamos</b>',
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

        function editar_movimiento(id_mov) {
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_archivos_def_tipo_abm = w.createWindow({
                className: 'alphacube',
                url: '/fw/mov_cred/mov_cred_ABM.aspx?accion=1&id_mov=' + id_mov + '&parentWin=' + win,
                title: '<b>Movimientos de Prestamos</b>',
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

        function listaMovCred() {
            var filtro = ""

            if ($('desc').value != "") {
                filtro += "<descripcion type='like'>%" + $('desc').value + "%</descripcion>"
            }

            var date1 = $('fecha_venta_1').value.substr(3, 2) + "/" + $('fecha_venta_1').value.substr(0, 2) + "/" + $('fecha_venta_1').value.substr(6, 4)
            if ($('fecha_venta_1').value != "") {
                filtro += "<fe_mov type='mas'>convert(datetime,'" + date1 + "',103)</fe_mov>"
            }

            var date2 = $('fecha_venta_2').value.substr(3, 2) + "/" + $('fecha_venta_2').value.substr(0, 2) + "/" + $('fecha_venta_2').value.substr(6, 4)
            if ($('fecha_venta_2').value != "") {
                filtro += "<fe_mov type='menor'>convert(datetime,'" + date2 + "',103)</fe_mov>"
            }

            if ($('fecha_estado').value != "") {
                filtro += "<fe_estado_mov type='igual'>" + $('fecha_estado').value + "</fe_estado_mov>"
            }

            if ($('monto').value != "") {
                filtro += "<monto_mov type='igual'>" + $('monto').value + "</monto_mov>"
            }

            if ($('tasa').value != "") {
                filtro += "<tasa_mov type='igual'>" + $('tasa').value + "</tasa_mov>"
            }

            if ($('mov_tipos').value != "") {
                filtro += "<nro_mov_tipo type='igual'>" + $('mov_tipos').value + "</nro_mov_tipo>"
            }

            if ($('mov_recursos_tipos').value != "") {
                filtro += "<nro_mov_recurso_tipo type='igual'>" + $('mov_recursos_tipos').value + "</nro_mov_recurso_tipo>"
            }

            if ($('inOrigen').value != "") {
                filtro += "<nrodoc_origen type='in'>" + $('inOrigen').value + "</nrodoc_origen>"
            }

            if ($('inDest').value != "") {
                filtro += "<nrodoc_destino type='in'>" + $('inDest').value + "</nrodoc_destino>"
            }

            if ($('mov_estados').value != "") {
                filtro += "<estado_mov type='igual'>'" + $('mov_estados').value + "'</estado_mov>"
            }

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

        function eliminar_movimiento(id_mov1) {

            nvFW.error_ajax_request('mov_cred_ABM.aspx', {
                parameters: { id_mov: id_mov1, accion: 2 },
                onSuccess: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    listaMovCred()
                },
            })
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
            <div id="divMenuEstado" style="margin: 0px; padding: 0px;"></div>
            <script>
                var vMenuEstado = new tMenu('divMenuEstado', 'vMenuEstado');
                vMenuEstado.loadImage("nueva", "/fw/image/icons/nueva.png")
                Menus["vMenuEstado"] = vMenuEstado
                Menus["vMenuEstado"].alineacion = 'centro';
                Menus["vMenuEstado"].estilo = 'A';
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='width: 95%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Movimientos de prestamos</Desc></MenuItem>")
                Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='1' style='width: 5%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoMov()</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuEstado.MostrarMenu()
            </script>
<table id="tablaCont" style="width:100%" class="tb1">   
    <tr>
        <td style="width:75%">
            <table id="ori_des"  style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="width: 50%; text-align:center">Origen</td>
                    <td style="width: 50%; text-align:center">Destino</td>
                </tr>
                <tr>
                    <td id="origen" style="text-align:center" >
<%--                        <img id="orPlus" src="/fw/image/icons/agregar.png" style="cursor: pointer" onclick="verEntidades(1)" /><input id="inOrigen" onclick="verEntidades(1)" style="width: 100%; display:none" type="text" />--%>
                        <script type="text/javascript">
                            campos_defs.add('inOrigen', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.entidades_def
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
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.entidades_def
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
                    <td style="text-align:center;width:35%">Tipo venta</td>
                    <td style="text-align:center;width:35%">Tipo movimiento</td>                    
                    <td style="text-align:center" colspan="2">Fecha venta</td>
                </tr>
                <tr>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_recursos_tipos', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.mov_recursos_tipos
                            })
                        </script>
                    </td>                 
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('mov_tipos', {
                                enDB: false,
                                nro_campo_tipo: 1,
                                filtroXML: nvFW.pageContents.mov_tipos
                            })
                        </script>
                    </td>
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
                </tr>
                <tr class="tbLabel">
                    <td colspan=4 style="text-align:center">Descripción</td>
                </tr>
                <tr>
                    <td colspan=4 ><input id="desc" style="width: 100%" type="text" /></td>
                </tr>
            </table>
        </td>
        <td style="width:25%">
            <table style="width:100%" class="tb1">
                <tr>
                    <td colspan=3 ><div style="width:50%;margin:auto" id="divBuscar"></div></td>
                </tr>
                <tr></tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td style="text-align:center">Tasa</td>
                    <td style="text-align:center">Monto venta</td>
                </tr>
                <tr>
                    <td ><input id="tasa" style="width: 100%" type="text" /></td>
                    <td ><input id="monto" style="width: 100%" type="text" /></td>
                </tr>
            </table>
            <table style="width:100%" class="tb1">
                <tr class="tbLabel">
                    <td colspan=3 style="width: 65%; text-align:center">Estado</td>
                    <td colspan=3 style="width: 35%; text-align:center">Fecha estado</td>
                </tr>
                <tr>                
                    <td colspan=3 >
                        <script type="text/javascript">
                            campos_defs.add('mov_estados', {
                                filtroXML: nvFW.pageContents.mov_estados,
                                enDB: false,
                                nro_campo_tipo: 1   
                            })
                        </script>
                    </td>
                    <td >
                        <script type="text/javascript">
                            campos_defs.add('fecha_estado', { enDB: false, nro_campo_tipo: 103 })
                        </script>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<div id="listaEntDes" onclick="listHid(1)" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none; z-index: 3;"></div>
<div id="listaEntOr" onclick="listHid()" style="position: relative; max-height:500px; overflow:auto; top:initial; display:none; z-index: 3;"></div>
<div style="z-index: 0">
    <iframe id="listaMovCreditos" name="listaMovCreditos" style="width: 100%; height: 100%; overflow:auto;"></iframe>
</div>
</body>
</html>
