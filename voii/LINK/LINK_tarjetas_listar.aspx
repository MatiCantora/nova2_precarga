<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If (Not op.tienePermiso("permisos_stock_tarjetas", 1)) Then Response.Redirect("/FW/error/httpError_401.aspx")

    Me.contents("filtro_tarjetas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLINK_soat_tj_maestro'><campos>tj_maestro_id, cod_tran, cod_tran_desc, tipo_cuenta, tipo_cuenta_desc,nro_cuenta, persona_tip_doc, persona_nro_doc, persona_ape_nom, persona_cuil, tarjeta_nro, tarjeta_tipo, tarjeta_tipo_desc, tarjeta_fe_ven, tarjeta_estado, style, tarjeta_estado_desc, tarjeta_fe_emis_plastico_date</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("cdef_tarjeta_estado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='LINK_SOAT_tj_estados'><campos>tj_estado as id, tj_estado_desc as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("cdef_tarjeta_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='LINK_SOAT_tj_tipos'><campos>tj_tipo as id, tj_tipo_desc as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("cdef_cuneta_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='LINK_SOAT_ct_tipos'><campos>ct_tipo as id, ct_tipo_desc as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("cdef_cod_trans") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='LINK_SOAT_cod_trans'><campos>cod_tran as id, tran_desc as campo</campos><orden>campo</orden><filtro><habilitado type='igual'>1</habilitado></filtro></select></criterio>")

    Me.contents("filtro_tarjeta_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLINK_soat_tj_maestro'><campos>*, convert(varchar, tarjeta_fe_emis_plastico_date, 103) as fecha_emis_plastico_103</campos><orden></orden><filtro><tj_maestro_id type='igual'>%tj_maestro_id%</tj_maestro_id></filtro></select></criterio>")
    Me.contents("filtro_tarjetas_excel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLINK_soat_tj_maestro'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_tarjetas_persona") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLINK_soat_tj_maestro'><campos> persona_ape_nom, persona_cuil, tarjeta_nro, tarjeta_tipo_desc, style, tarjeta_estado_desc, tarjeta_fe_ven, tarjeta_fe_emis_plastico_date, tj_maestro_id </campos><orden></orden><filtro></filtro></select></criterio>")


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>LINK Tarjetas</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <style>
        .cabecera {
            background-color: white;
            display: flex;
            align-items: center;
        }

        .cabecera_content {
            flex-grow: 3;
        }

        .cabecera_bton {
            flex-grow: 1;
        }
    </style>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">


        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return btnBuscar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');


        function window_onload() {
            vListButton.MostrarListButton();
            window_onresize();
        }


        function window_onresize() {
            $('ifrRegistros').setStyle({ height: $$('body')[0].getHeight() - $('divSelectBuscar').getHeight() - $('divMenu').getHeight() - $('divCabecera').getHeight() + 'px' });
        }


        function btnExportar() {
            var filtro = "<criterio><select><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>";

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_tarjetas_excel,
                filtroWhere: filtro,
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "LINK_tarjetas.xls"
            });
        }


        function btnBuscar() {
         
            var cantFilas = Math.floor(($("ifrRegistros").getHeight() - 24 - 21) / 22) - 1;
            var filtro = "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>";


            if ($('consulta_tipo').value == 'L') {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_tarjetas,
                    filtroWhere: filtro,
                    path_xsl: 'report/plantillas/LINK/html_LINK_tarjetas_listar.xsl',
                    salida_tipo: 'adjunto',
                    ContentType: 'text/html',
                    formTarget: 'ifrRegistros',
                    nvFW_mantener_origen: true,
                    bloq_contenedor: $$('body')[0],
                    bloq_msg: 'Buscando...',
                    cls_contenedor: 'ifrRegistros'
                });
            }
            else if ($('consulta_tipo').value == 'P') {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_tarjetas_persona,
                    filtroWhere: filtro,
                    path_xsl: 'report/plantillas/LINK/html_LINK_tarjetas_persona_listar.xsl',
                    salida_tipo: 'adjunto',
                    ContentType: 'text/html',
                    formTarget: 'ifrRegistros',
                    nvFW_mantener_origen: true,
                    bloq_contenedor: $$('body')[0],
                    bloq_msg: 'Buscando...',
                    cls_contenedor: 'ifrRegistros'
                });
            }

            window_onresize()
        }

        function habilitarFiltros() {
            campos_defs.clear()
            window_onresize()
            ObtenerVentana('ifrRegistros').location.href = '/FW/enBlanco.htm'
        }


        function ver_detalle(e, tj_maestro_id) {

            var rs_tarjeta = new tRS();
            rs_tarjeta.async = true;

            nvFW.bloqueo_activar($$('body')[0], 'bloq_tarjeta', 'Cargando datos...');
            rs_tarjeta.onComplete = function () {
                nvFW.bloqueo_desactivar(null, 'bloq_tarjeta');

                if (!rs_tarjeta.eof()) {

                    var strHTML = '<div id="bodyDetalle" style="overflow: hidden"><div id=cabeceraDetalle style="overflow: hidden"><table class="tb1"><div><tr><td colspan="2" class="tit2" style="text-align:left;">Nro. Tarjeta</td><td colspan="2" class="tit1" style="text-align:right"> ' + rs_tarjeta.getdata('tarjeta_nro') + '</td></tr></div><tr><td class="tit2" style="text-align:left">CUIL</td><td class="tit4" style="text-align:right" >' + rs_tarjeta.getdata('persona_cuil') + '</td><td class="tit2" style="text-align:left">Apellido y Nombre</td><td class="tit4" style="text-align:left">' + rs_tarjeta.getdata('persona_ape_nom') + '</td></tr><div><tr><td class="tit2" style="text-align:left">Tipo Tarjeta</td><td class="tit4" style="text-align:left">' + rs_tarjeta.getdata('tarjeta_tipo_desc') + '</td><td class="tit2" style="text-align:left">Tarjeta Estado</td><td class="tit4" style="text-align:left;' + rs_tarjeta.getdata('style') + '">' + rs_tarjeta.getdata('tarjeta_estado_desc') + '</td></tr></div><div><tr><td class="tit2" style="text-align:left">Fecha Venc.</td><td class="tit4" style="text-align:right">' + rs_tarjeta.getdata('tarjeta_fe_ven') + '</td><td class="tit2" style="text-align:left">Fecha Emisi�n</td><td class="tit4" style="text-align:right">' + rs_tarjeta.getdata('fecha_emis_plastico_103') + '</td></tr></table ></div><div id="cabeceraTablaDetalle"><table id="tbCabecera" class="tb1"><tr><td class="tit2" style="text-align:center; width:32%">Propiedades</td><td class="tit2" style="text-align:center; width:72%">Valor</td></tr></table></div><div id="detalle" style="width: 100%; height: 100%; overflow-y: auto"><table class="tb1">';



                    for (var i = 0; i < rs_tarjeta.fields.length; i++) {

                        var columna = rs_tarjeta.fields[i].name;
                        var valor = rs_tarjeta.getdata(columna);

                        if (columna != 'tarjeta_nro' && columna != 'persona_cuil' && columna != 'persona_ape_nom' && columna != 'tarjeta_tipo_desc' && columna != 'tarjeta_estado_desc' && columna != 'tarjeta_fe_ven' && columna != 'fecha_emis_plastico_103') {
                            strHTML +=

                                '<tr><td class="tit1">' + columna + '</td><td class="tit4">' + valor + '</td></tr>';
                        }

                    }
                    strHTML += '</table></div>';

                    var win_tarjeta_height = 600
                    win_tarjeta = nvFW.createWindow({
                        className: 'alphacube',
                        title: '<b>Datos de la tarjeta</b>',
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        resizable: true,
                        recenterAuto: false,
                        width: 850,
                        height: win_tarjeta_height,
                        onDestroy: true,
                        onClose: function () { },
                        onMaximize: function () {
                            $('detalle').setStyle({ height: win_tarjeta.height - $('cabeceraDetalle').getHeight() - $('cabeceraTablaDetalle').getHeight() + 'px' })
                        }



                    });

                    win_tarjeta.setHTMLContent(strHTML)

                    //var id = win_tarjeta.getId()
                    win_tarjeta.showCenter()

                    $('detalle').setStyle({ height: win_tarjeta_height - $('cabeceraDetalle').getHeight() - $('cabeceraTablaDetalle').getHeight() + 'px' })

                } else {
                    alert('Error al cargar datos.');
                }
            }

            rs_tarjeta.onError = function () {
                nvFW.bloqueo_desactivar(null, 'bloq_tarjeta');
                alert('Error al cargar datos.');
            }

            var parametros = "<criterio><params tj_maestro_id='" + tj_maestro_id + "' /></criterio>";

            rs_tarjeta.open(nvFW.pageContents.filtro_tarjeta_detalle, '', '', '', parametros);

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <div id="divMenu"></div>
    <script>
        var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

        Menus["vMenuModulos"] = vMenuModulos
        Menus["vMenuModulos"].alineacion = 'centro';

        Menus["vMenuModulos"].estilo = 'A';
        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

        vMenuModulos.loadImage("excel", '/FW/image/icons/excel.png');
        vMenuModulos.loadImage("estado", '/FW/image/icons/cambio_estado.png');

        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnExportar()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuModulos.MostrarMenu();
    </script>
    <div id="divSelectBuscar">
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 20%; text-align: right;">Tipo de B�squeda:&nbsp;</td>
                <td>
                    <select style = 'width:100%' id='consulta_tipo' onchange="habilitarFiltros()">
                        <option value='L'>Lineal</Option>
                        <option value = 'P' selected='selected'> Agrupado por Persona</option>                                                             
                    </select>     
                </td>
                <td style="width:20%">
                    <div id="divBuscar" class="cabecera_bton"></div>
                </td>
            </tr>
        </table>
    </div>

    <div id="divCabecera" class="cabecera">
        <div class="cabecera_content">
            <table id="tbCabeceraPersona" class="tb1">
                <tr class="tbLabel">
                    <%--Persona y Cuenta--%>
                    <td style="text-align: center;width:25%">Tipo</td>
                    <td style="text-align: center;width:25%" nowrap>Nro. cuenta</td>
                    <td style="text-align: center;width:10%" nowrap>CUIL</td>
                    <td style="text-align: center;width:40%" nowrap>Apellido y Nombre</td>
                </tr>
                <tr>
                    <td>
                        <script>
                            campos_defs.add('tipo_cta', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                StringValueIncludeQuote: true,
                                filtroXML: nvFW.pageContents.cdef_cuneta_tipo,
                                filtroWhere: '<tipo_cuenta type="in">%campo_value%</tipo_cuenta>'
                            });
                        </script>
                    </td>
                     <td>
                        <script>
                            campos_defs.add('nro_cuenta', {
                                enDB: false,
                                nro_campo_tipo: 100,
                                filtroWhere: '<cuentas_nros type="like">%%campo_value%%</cuentas_nros>'
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('nro_docu', {
                                nro_campo_tipo: 101,
                                StringValueIncludeQuote: true,
                                filtroWhere: '<persona_cuil type="like">%campo_value%</persona_cuil>',
                                enDB: false,
                                mask: {
                                    mask: '00-00000000-0',
                                    lazy: false
                                },
                                onmask_complete: function (campo_def, objcampo_def) {
                                    var vec = new Array(10);
                                    var cuit = campos_defs.get_value(campo_def);
                                    esCuit = false;
                                    cuit_rearmado = "";
                                    errors = ''
                                    for (i = 0; i < cuit.length; i++) {
                                        caracter = cuit.charAt(i);
                                        if (caracter.charCodeAt(0) >= 48 && caracter.charCodeAt(0) <= 57) {
                                            cuit_rearmado += caracter;
                                        }
                                    }
                                    cuit = cuit_rearmado;
                                    if (cuit.length != 11) {  // si no estan todos los digitos
                                        esCuit = false;
                                        errors = 'Cuit < 11 ';
                                        alert("CUIT Menor a 11 Caracteres");
                                    } else {
                                        x = i = dv = 0;
                                        // Multiplico los d�gitos.
                                        vec[0] = cuit.charAt(0) * 5;
                                        vec[1] = cuit.charAt(1) * 4;
                                        vec[2] = cuit.charAt(2) * 3;
                                        vec[3] = cuit.charAt(3) * 2;
                                        vec[4] = cuit.charAt(4) * 7;
                                        vec[5] = cuit.charAt(5) * 6;
                                        vec[6] = cuit.charAt(6) * 5;
                                        vec[7] = cuit.charAt(7) * 4;
                                        vec[8] = cuit.charAt(8) * 3;
                                        vec[9] = cuit.charAt(9) * 2;

                                        // Suma cada uno de los resultado.
                                        for (i = 0; i <= 9; i++) {
                                            x += vec[i];
                                        }
                                        dv = (11 - (x % 11)) % 11;
                                        if (dv == cuit.charAt(10)) {
                                            esCuit = true;
                                        }
                                    }
                                    document.MM_returnValue1 = (errors == '');
                                }
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('nombre', {
                                nro_campo_tipo: 104,
                                enDB: false,
                                filtroWhere: '<persona_ape_nom type="like">%%campo_value%%</persona_ape_nom>'
                            });
                        </script>
                    </td>
                </tr>
            </table>
            <table id="tbCabeceraTarjeta" class="tb1">
                <tr class="tbLabel">
                    <%--Tarjeta--%>
                    <td style="text-align: center; width:20%" nowrap>Codigo Transacci�n</td>
                    <td style="text-align: center; width:20%">Tipo</td>
                    <td style="text-align: center; width:20%" nowrap>Nro. Tarjeta</td>
                    <td style="text-align: center; width:10%">Estado</td>
                    <td style="text-align: center; width:15%" colspan="2" nowrap>Fecha Emisi�n</td>
                    <td style="text-align: center; width:15%" colspan="2" nowrap>Fecha Vencimiento</td>
                </tr>
                <tr>
                    <td>
                        <script>
                            campos_defs.add('cod_tran', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.cdef_cod_trans,
                                filtroWhere: '<cod_tran type="in">%campo_value%</cod_tran>'
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('tarjeta_tipo', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.cdef_tarjeta_tipo,
                                StringValueIncludeQuote: true,
                                filtroWhere: '<tarjeta_tipo type="in">%campo_value%</tarjeta_tipo>'
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('nro_tarjeta', {
                                nro_campo_tipo: 104,
                                enDB: false,
                                filtroWhere: '<tarjeta_nro type="like">%campo_value%</tarjeta_nro>'
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('tarjeta_estado', {
                                enDB: false,
                                nro_campo_tipo: 2,
                                filtroXML: nvFW.pageContents.cdef_tarjeta_estado,
                                StringValueIncludeQuote: true,
                                filtroWhere: '<tarjeta_estado type="in">%campo_value%</tarjeta_estado>'
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('fecha_em_desde', {
                                enDB: false,
                                nro_campo_tipo: 103,
                                filtroWhere: "<tarjeta_fe_emis_plastico_date type='mas'>convert(datetime, '%campo_value%', 103)</tarjeta_fe_emis_plastico_date>"
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('fecha_em_hasta', {
                                enDB: false,
                                nro_campo_tipo: 103,
                                filtroWhere: "<tarjeta_fe_emis_plastico_date type='menor'>dateadd(dd,1,convert(datetime, '%campo_value%', 103))</tarjeta_fe_emis_plastico_date>"
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('fecha_venc_desde', {
                                enDB: false,
                                nro_campo_tipo: 103,
                                filtroWhere: "<tarjeta_fe_ven_date type='mas'>convert(datetime, '%campo_value%', 103)</tarjeta_fe_ven_date>"
                            });
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add('fecha_venc_hasta', {
                                enDB: false,
                                nro_campo_tipo: 103,
                                filtroWhere: "<tarjeta_fe_ven_date type='menor'>dateadd(dd,1,convert(datetime, '%campo_value%', 103))</tarjeta_fe_ven_date>"
                            });
                        </script>
                    </td>
                </tr>
            </table>
        </div>
    </div>
    <iframe id="ifrRegistros" name="ifrRegistros" style="width: 100%; border: none;"></iframe>
</body>
</html>
