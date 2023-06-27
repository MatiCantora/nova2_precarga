<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador

    Me.addPermisoGrupo("permisos_administrador_reportes")
    Me.contents("filtroTipRel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod, tiporel</campos><orden></orden></select></criterio>")
    'Me.contents("filtro_sistemas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..trsg_sistema' cn='BD_IBS_ANEXA'><campos>sistcod as id, descripcion as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")

    If (Not op.tienePermiso("permisos_administrador_reportes", 1)) Then Response.Redirect("../FW/error/httpError_401.aspx")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administrador de vistas y reportes</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        //CAMPOS DEF DE IBS
        //OBJETO CAMPOS DEF UTILIZADO PARA HABILITAR EL CAMPO SI SUS PRIMARY KEYS SE ENCUENTRAN EN LA VISTA SELECCIONADA
        // { nombreCampo_def: { primaryKey: [(claves que componen su filtroWhere)] } }
        var ar_config = {
            tipdoc: { primaryKey: ["paiscod", "tipdoc"] },
            tipdocs: { primaryKey: ["paiscod", "tipdoc"] },
            nrodoc: { primaryKey: ["nrodoc", "paiscod", "tipdoc", "bcocod"] },
            cilestcivcod: { primaryKey: ["paiscod", "cliestcivcod"] },
            cilestcivcodes: { primaryKey: ["paiscod", "cliestcivcod"] },
            clasicod: { primaryKey: ["paiscod", "clasicod"] },
            clasicodes: { primaryKey: ["paiscod", "clasicod"] },
            cliclivincod: { primaryKey: ["paiscod", "bcocod", "cliclivincod", "tipvinclicod"] },
            cliclivincodes: { primaryKey: ["paiscod", "bcocod", "cliclivincod", "tipvinclicod"] },
            clicondgi: { primaryKey: ["paiscod", "clicondgi"] },
            clicondgis: { primaryKey: ["paiscod", "clicondgi"] },
            codsubsist: { primaryKey: ["sistcod", "codsubsist"] },
            codsubsists: { primaryKey: ["sistcod", "codsubsist"] },
            compacod: { primaryKey: ["compacod"] },
            compacodes: { primaryKey: ["compacod"] },
            datoscod: { primaryKey: ["datoscod", "funcod"] },
            datoscodes: { primaryKey: ["datoscod", "funcod"] },
            estopercod: { primaryKey: ["estopercod"] },
            estopercodes: { primaryKey: ["estopercod"] },
            funcod: { primaryKey: ["funcod", "bcocod", "paiscod"] },
            funcodes: { primaryKey: ["funcod", "bcocod", "paiscod"] },
            impgancod: { primaryKey: ["impgancod", "paiscod"] },
            impgancodes: { primaryKey: ["impgancod", "paiscod"] },
            marprocod: { primaryKey: ["marprocod"] },
            marprocodes: { primaryKey: ["marprocod"] },
            moncod: { primaryKey: ["moncod"] },
            moncodes: { primaryKey: ["moncod"] },
            perconcod: { primaryKey: ["paiscod", "bcocod", "perconcod"] },
            perconcodes: { primaryKey: ["paiscod", "bcocod", "perconcod"] },
            plancod: { primaryKey: ["paiscod", "bcocod", "plancod", "codafinidad"] },
            plancodes: { primaryKey: ["paiscod", "bcocod", "plancod", "codafinidad"] },
            profesion: { primaryKey: ["paiscod", "profesion"] },
            profesiones: { primaryKey: ["paiscod", "profesion"] },
            sectorfin: { primaryKey: ["sectorfin"] },
            sectorfins: { primaryKey: ["sectorfin"] },
            sistcod: { primaryKey: ["sistcod"] },
            sistcodes: { primaryKey: ["sistcod"] },
            succod: { primaryKey: ["succod", "paiscod", "bcocod"] },
            succodes: { primaryKey: ["succod", "paiscod", "bcocod"] },
            tipcartcod: { primaryKey: ["tipcartcod", "paiscod"] },
            tipcartcodes: { primaryKey: ["tipcartcod", "paiscod"] },
            tipempsoc: { primaryKey: ["tipempsoc", "paiscod"] },
            tipempsocs: { primaryKey: ["tipempsoc", "paiscod"] },
            tipoempcod: { primaryKey: ["tipoempcod"] },
            tipoempcodes: { primaryKey: ["tipoempcod"] },
            tiporels: { primaryKey: ["tiporel", "paiscod", "bcocod"] },
            tipotercod: { primaryKey: ["tipotercod"] },
            tipotercodes: { primaryKey: ["tipotercod"] },
            tercod: { primaryKey: ["tercod", "paiscod", "bcocod", "succod"] },
            tipvinclicod: { primaryKey: ["tipvinclicod"] },
            tipvinclicodes: { primaryKey: ["tipvinclicod"] },
            usrident: { primaryKey: ["usrident", "tipdoc"] },
            catusrcod: { primaryKey: ["catusrcod"] },
            catusrcodes: { primaryKey: ["catusrcod"] },
            sistcod_oper: { primaryKey: ["tipopercod", "paiscod", "bcocod", "sistcod", "codsubsist", "moncod"] },
            tipopercod: { primaryKey: ["tipopercod", "paiscod", "bcocod", "sistcod", "codsubsist", "moncod"] },
            cuecod: { primaryKey: ["cuecod", "succod", "moncod", "paiscod", "bcocod", "codsubsist", "sistcod"] },
            cuecods: { primaryKey: ["cuecod", "succod", "moncod", "paiscod", "bcocod", "codsubsist", "sistcod"] },
            //feccrea_desde: { primaryKey: ["feccrea"] },
            //feccrea_hasta: { primaryKey: ["feccrea"] },
            //fechafin_desde: { primaryKey: ["fechafin"] },
            //fechafin_hasta: { primaryKey: ["fechafin"] },
            fecreal_desde: { primaryKey: ["fecreal"] },
            fecreal_hasta: { primaryKey: ["fecreal"] },
            clifecalt_desde: { primaryKey: ["clifecalt"] },
            clifecalt_hasta: { primaryKey: ["clifecalt"] },
            ofinrodoc: { primaryKey: ["ofinrodoc", "ofitipdoc", "ofibcocod", "ofipaiscod", "ofisuccod"] },
            fecalta_desde: { primaryKey: ["fecalta", "cuecod"] },
            fecalta_hasta: { primaryKey: ["fecalta", "cuecod"] },
            clisexo: { primaryKey: ["clisexo"] },
            codprovs: { primaryKey: ["codprov", "paiscod"] },
            loccod: { primaryKey: ["codprov", "paiscod", "loccod"] },
            fecultmov_desde: { primaryKey: ["cuecod", "fecultmov"] },
            fecultmov_hasta: { primaryKey: ["cuecod", "fecultmov"] },
            fecmov_desde: { primaryKey: ["movcod", "fecmov"] },
            fecmov_hasta: { primaryKey: ["movcod", "fecmov"] },
            ctacondgis: { primaryKey: ["ctacondgi", "paiscod"] },
            cliclivincodes_cta: { primaryKey: ["cliclivincod", "cuecod"] },
            prodcod: { primaryKey: ["paiscod", "bcocod", "prodcod", "sistcod", "codsubsist", "moncod"] },
            prodcodes: { primaryKey: ["paiscod", "bcocod", "prodcod", "sistcod", "codsubsist", "moncod"] },
            linea: { primaryKey: ["paiscod", "bcocod", "linea", "sistcod", "codsubsist", "moncod", "succod"] },
            fecori_desde: { primaryKey: ["fecori"] },
            fecori_hasta: { primaryKey: ["fecori"] },
            movcod: { primaryKey: ["movcod", "sistcod", "bcocod", "paiscod"] },
            trancodes: { primaryKey: ["trancod"] },
            grupocon: { primaryKey: ["grupocon", "paiscod", "bcocod"] },
            gruposcon: { primaryKey: ["grupocon", "paiscod", "bcocod"] },
            paiscod: { primaryKey: ["paiscod"] },
            importpact_desde: { primaryKey: ["importpact"] },
            importpact_hasta: { primaryKey: ["importpact"] },
            openro: { primaryKey: ["openro"] },
            nroreferencia: { primaryKey: ["nroreferencia"] }
        };

    </script>

    <script type="text/javascript">        

        var tablaFiltroId = '';
        var arrayCampos_def = [];

        function window_onload() {

            mostrarTablaFiltro(1);
            arrayCampos_def = Object.keys(campos_defs.items);            
            campos_defs.items['sistcod_oper'].filtroXML = campos_defs.items['sistcodes'].filtroXML
            filtros_habilitar();
            resize_filtros();

        }

        function window_onresize() {

            var tbFiltro_h = $(tablaFiltroId).getHeight();
            $('divFiltros').setStyle({ height: tbFiltro_h + 150 })

            $('divScroll').setStyle({ height: parent.iframe_h - $('vMenuFGral').getHeight() });

            var cdef_width = $('cdef_linea').getWidth() / 2;
            $('cdef_importpact_desde').setStyle({ width: cdef_width });
            $('cdef_importpact_hasta').setStyle({ width: cdef_width });

        }

        function getStrXML() {

            var strXMLFiltro = '';
            strXMLFiltro += campos_defs.filtroWhere()
            return strXMLFiltro;

        }

        function limpiar_filtros() {

            campos_defs.clear();

        }

        function mostrarTablaFiltro(code) {

            switch (code) {
                case 1:
                    $('tbFiltroEntidades').show();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroEntidades';
                    break;
                case 2:
                    $('tbFiltroEntidades').hide();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroCuentas').show();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroCuentas';
                    break;
                case 3:
                    $('tbFiltroMovimientos').show();
                    $('tbFiltroEntidades').hide();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroMovimientos';
                    break;
                case 4:
                    $('tbFiltroEntidades').hide();
                    $('tbFiltroOperaciones').show();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroOperaciones';
                    break;
                case 5:
                    $('tbFiltroEntidades').hide();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroOperadores').show();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroOperadores';
                    break;
                case 6:
                    $('tbFiltroEntidades').hide();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').show();
                    tablaFiltroId = 'tbFiltroOtros';
                    break;
                default:
                    $('tbFiltroEntidades').show();
                    $('tbFiltroOperaciones').hide();
                    $('tbFiltroMovimientos').hide();
                    $('tbFiltroOperadores').hide();
                    $('tbFiltroCuentas').hide();
                    $('tbFiltroOtros').hide();
                    tablaFiltroId = 'tbFiltroEntidades';
                    break;
            }

            window_onresize();

        }


        function filtros_habilitar() {

            for (var i = 0; i < arrayCampos_def.length; i++) { //RECORRO CAMPOS_DEF DEL ASPX
                var nombre_campo = arrayCampos_def[i];
                var habilitar_campo = true;
                for (var j = 0; j < ar_config[nombre_campo].primaryKey.length; j++) {
                    if (!parent.habilitar(ar_config[nombre_campo].primaryKey[j])) { //VERIFICO EXISTENCIA DE CAMPOS NECESARIOS EN LA VISTA SELECCIONADA
                        habilitar_campo = false;
                        break;
                    }
                }
                campos_defs.habilitar(nombre_campo, habilitar_campo)
            }
        }


        function cargar_filtros(objXML) {

            var strReg = '(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\\d{4}'
            var reg = new RegExp(strReg)
            var NOD = objXML.selectNodes('criterio/select/filtro')[0]

            for (var j = 0; j < NOD.childNodes.length; j++) {

                var nodeName = NOD.childNodes[j].nodeName;
                var valor;

                switch (nodeName) { //TIPO NODO
                    case 'AND': //NODOS AND
                        var values = { 0: {} }
                        var nodoAND = NOD.childNodes[j];
                        if (selectSingleNode('@campodef_src', nodoAND) != null) {
                            var campo_def = selectSingleNode('@campodef_src', nodoAND).value;
                            if (ar_config[campo_def].primaryKey.length > 1) {
                                for (var k = 0; k < nodoAND.childNodes.length; k++) { //NODOS DEL CAMPO_DEF
                                    var id = nodoAND.childNodes[k].nodeName;
                                    var valor = XMLText(nodoAND.childNodes[k]);
                                    values[0][id] = valor; //ARMO OBJETO CON VALORES A SETEAR
                                }
                                campos_defs.set_valueRS(campo_def, values);
                            }
                            else campos_defs.set_value(campo_def, XMLText(nodoAND.childNodes[0]));
                        }
                        break;
                    case 'OR': //NODOS OR
                        var NODOR = NOD.childNodes[j];
                        var campo_def = selectSingleNode('@campodef_src', NODOR).value;
                        var values = {};
                        for (var i = 0; i < NODOR.childNodes.length; i++) { //RECORRO NODOS AND DEL NODO OR
                            var nodoAND = NODOR.childNodes[i]
                            values[i] = {};
                            for (var k = 0; k < nodoAND.childNodes.length; k++) { //NODOS DEL CAMPO_DEF
                                var id = nodoAND.childNodes[k].nodeName;
                                var valor = XMLText(nodoAND.childNodes[k]);
                                values[i][id] = valor; //ARMO OBJETO CON VALORES A SETEAR
                            }
                        }
                        campos_defs.set_valueRS(campo_def, values);
                        break;
                    default: //OTROS
                        var NODCAMPO = NOD.childNodes[j]
                        if (selectSingleNode('@campodef_src', NODCAMPO) != null) { //NODO CAMPO_DEF
                            campo_def = selectSingleNode('@campodef_src', NODCAMPO).value;
                            if (campos_defs.items[campo_def].nro_campo_tipo != 103) //SI NO ES FECHA
                                campos_defs.set_value(campo_def, XMLText(NODCAMPO));
                            else {
                                campos_defs.set_value(campo_def, reg.exec(XMLText(NODCAMPO))[0]); //SI ES FECHA
                            }
                        }
                        break;
                }

            }
        }

        function resize_filtros() {
            $('clifecalt_desde').setStyle({ width: 170 });
            $('clifecalt_hasta').setStyle({ width: 170 });
            $('fecalta_desde').setStyle({ width: 170 });
            $('fecalta_hasta').setStyle({ width: 170 });
            $('fecultmov_desde').setStyle({ width: 170 });
            $('fecultmov_hasta').setStyle({ width: 170 });
            $('fecmov_desde').setStyle({ width: 170 }); //244
            $('fecmov_hasta').setStyle({ width: 170 });
            $('fecori_desde').setStyle({ width: 170 });
            $('fecori_hasta').setStyle({ width: 170 });
            $('fecreal_desde').setStyle({ width: 170 });
            $('fecreal_hasta').setStyle({ width: 170 });
            //$('feccrea_desde').setStyle({ width: 170 });
            //$('feccrea_hasta').setStyle({ width: 170 });
            //$('fechafin_desde').setStyle({ width: 170 });
            //$('fechafin_hasta').setStyle({ width: 170 });
        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div style="width: 100%; height: 100%; overflow: hidden" id="divMenuFGral">
        <script language="javascript" type="text/javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuFGral = new tMenu('divMenuFGral', 'vMenuFGral');
            Menus["vMenuFGral"] = vMenuFGral
            Menus["vMenuFGral"].alineacion = 'centro';
            Menus["vMenuFGral"].estilo = 'A';

            vMenuFGral.loadImage('mas', '/FW/image/tTree/mas.jpg')

            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Filtros</Desc></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Clientes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(1)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='2' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Cuentas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(2)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='3' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Movimientos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(3)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='4' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Operaciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(4)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='5' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Operador</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(5)</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuFGral"].CargarMenuItemXML("<MenuItem id='6' style='width: 100%; text-align: center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Otros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarTablaFiltro(6)</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuFGral.MostrarMenu()
        </script>
        <div id="divScroll" style="width: 100%; height: 100%; overflow: auto;">
            <div id="divFiltros" style="width: 100%; height: 100%; overflow: hidden;">
                <table class="tb1" id="tbFiltroEntidades" style="display: none">
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Cliente:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('nrodoc', {
                                    nro_campo_tipo: 3,
                                    campo_codigo: 'nrodoc',
                                    campo_desc: 'razon_social'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Estado Cliente:</td>
                        <td style="width: 100%">
                            <script>
                                var rs = new tRS()
                                rs.xml_format = "rs_xml_json"
                                rs.open(nvFW.pageContents.filtroTipRel)
                                rs.addRecord({ id: -1, campo: "Prospecto", paiscod: 54, bcocod: 312, tiporel: -1 })
                                campos_defs.add('tiporels', {
                                    filtroXML: "", //"<criterio><select vista='Banksys..trcl_tiprelac' cn='BD_IBS_ANEXA'><campos>distinct tiporel as id, tipreldesc as [campo], paiscod, bcocod</campos><orden></orden></select></criterio>",
                                    filtroWhere: "<paiscod>%rs!paiscod%</paiscod><bcocod>%rs!bcocod%</bcocod><tiporel>%rs!tiporel%</tiporel>",
                                    nro_campo_tipo: 2, enDB: false, json: true
                                });

                                campos_defs.items['tiporels'].rs = rs
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Alta:</td>
                        <td>
                            <script>
                                campos_defs.add('clifecalt_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<clifecalt type="mas">convert(datetime, "%campo_value%", 103)</clifecalt>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('clifecalt_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<clifecalt type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</clifecalt>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Doc.:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('tipdocs');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Clasificación Cliente:</td>
                        <td>
                            <script>
                                campos_defs.add("clasicodes");
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Oficial de Cuenta:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add("ofinrodoc", {
                                    campo_codigo: 'ofinrodoc',
                                    campo_desc: 'ofirazon_social'
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Condición Persona:</td>
                        <td>
                            <script>
                                campos_defs.add("perconcodes");
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Condición DGI:</td>
                        <td>
                            <script>
                                campos_defs.add("clicondgis");
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Sector Financiero:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add("sectorfins");
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Emp.:</td>
                        <td>
                            <script>
                                campos_defs.add("tipoempcodes");
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Soc.:</td>
                        <td>
                            <script>
                                campos_defs.add("tipempsocs");
                            </script>
                        </td>
                        <td class="tit1">Tipo Cartera:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add("tipcartcodes");
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1">Imp. Ganancias:</td>
                        <td>
                            <script>
                                campos_defs.add("impgancodes");
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Profesión:</td>
                        <td>
                            <script>
                                campos_defs.add('profesiones');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Estado Civil:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('cilestcivcodes');
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td style="width: 140px" class="Tit1">Sexo:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('clisexo', {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroWhere: "<clisexo type='in'>%campo_value%</clisexo>",
                                    mostrar_codigo: false
                                })
                                var rs = new tRS();
                                rs.xml_format = "rsxml_json";
                                rs.addField("id", "string")
                                rs.addField("campo", "string")
                                rs.addRecord({ id: "'M'", campo: "MASC" });
                                rs.addRecord({ id: "'F'", campo: "FEM" });
                                //rs.addRecord({ id: "'X'", campo: "XXX" });
                                campos_defs.items['clisexo'].rs = rs;
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="tbFiltroOperaciones" style="display: none">
                    <tr>
                        <td colspan="8">
                            <table class="tb1" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td class="tit1" style="width: 140px !important" nowrap>Tipo Operación:</td>
                                    <td style="width: 205px; padding-right: 3px; padding-left: 3px;">
                                        <script>
                                            campos_defs.add('sistcod_oper', {
                                                enDB: false,
                                                nro_campo_tipo: 2//,
                                                //filtroXML: nvFW.pageContents.filtro_sistemas
                                            });
                                        </script>
                                    </td>
                                    <td style="width: 348px; padding-right: 3px;">
                                        <script>
                                            campos_defs.add('tipopercod', {
                                                nro_campo_tipo: 2,
                                                depende_de: 'sistcod_oper',
                                                depende_de_campo: 'sistcod'
                                            });
                                        </script>
                                    </td>
                                    <td class="tit1" style="width: 140px" nowrap>Estado Operación:</td>
                                    <td style="padding-right: 3px; padding-left: 3px;">
                                        <script>
                                            campos_defs.add('estopercodes');
                                        </script>
                                    </td>  
                                    <td class="tit1" style="width: 140px" nowrap>Importe Pactado:</td>
                                    <td id="cdef_importpact_desde" style="padding-left: 3px;">
                                        <script>
                                            campos_defs.add('importpact_desde', {
                                                enDB: false,
                                                nro_campo_tipo: 101,
                                                filtroWhere: '<importpact type="mas">%campo_value%</importpact>'
                                            });
                                        </script>
                                    </td>
                                    <td id="cdef_importpact_hasta" style="padding-left: 3px;">
                                        <script>
                                            campos_defs.add('importpact_hasta', {
                                                enDB: false,
                                                nro_campo_tipo: 101,
                                                filtroWhere: '<importpact type="menos">%campo_value%</importpact>'
                                            });
                                        </script>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Originación:</td>
                        <td>
                            <script>
                                campos_defs.add('fecori_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecori type="mas">convert(datetime, "%campo_value%", 103)</fecori>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecori_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecori type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</fecori>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Nro. Operación:</td>
                        <td colspan="2" style="width: 50%">
                            <script>
                                campos_defs.add('openro', {
                                    enDB: false,
                                    nro_campo_tipo: 101,
                                    filtroWhere: '<openro type="in">%campo_value%</openro>'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Linea:</td>
                        <td id="cdef_linea" style="width: 100%">
                            <script>
                                campos_defs.add('linea', {
                                    campo_codigo: 'linea',
                                    campo_desc: 'deslin'
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Compañía Seguros:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('compacodes');
                            </script>
                        </td>
                         <td class="tit1" style="width: 140px" nowrap>Producto:</td>
                        <td colspan="2" style="width: 50%">
                            <script>
                                campos_defs.add('prodcod', {
                                    campo_codigo: 'prodcod',
                                    campo_desc: 'prodnom'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Nro. Referencia:</td>
                        <td style="width: 100%">
                            <script>
                                campos_defs.add('nroreferencia', {
                                    enDB: false,
                                    nro_campo_tipo: 104,
                                    filtroWhere: '<nroreferencia type="in">%campo_value%</nroreferencia>'
                                });
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="tbFiltroMovimientos" style="display: none">
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Real:</td>
                        <td>
                            <script>
                                campos_defs.add('fecreal_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecreal type="mas">convert(datetime, "%campo_value%", 103)</fecreal>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecreal_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecreal type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</fecreal>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Transacción:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('movcod', {
                                    campo_codigo: 'trancod',
                                    canpo_desc: 'descdet'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Estado Proceso:</td>
                        <td style="width: 100%" colspan="2">
                            <script>
                                campos_defs.add('marprocodes');
                            </script>
                        </td>
                        <%-- <td class="tit1" style="width: 140px" nowrap>Fec. Tran. Inicio:</td>
                        <td>
                            <script>
                                campos_defs.add('feccrea_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<feccrea type="mas">convert(datetime, "%campo_value%", 103)</feccrea>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('feccrea_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<feccrea type="mas">convert(datetime, "%campo_value%", 103)</feccrea>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>--%>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Movimiento:</td>
                        <td>
                            <script>
                                campos_defs.add('fecmov_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecmov type="mas">convert(datetime, "%campo_value%", 103)</fecmov>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecmov_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecmov type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</fecmov>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Transacciones:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('trancodes', {
                                    nro_campo_tipo: 101,
                                    enDB: false,
                                    filtroWhere: '<trancod type="in">%campo_value%</trancod>'
                                });
                            </script>
                        </td>
                        <td class="tit1" nowrap>Funciones:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('funcodes');
                            </script>
                        </td>
                        <%-- <td class="tit1" nowrap>Fec. Tran. Fin:</td>
                        <td>
                            <script>
                                campos_defs.add('fechafin_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fechafin type="menos">convert(datetime, "%campo_value%", 103)</fechafin>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fechafin_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fechafin type="menos">convert(datetime, "%campo_value%", 103)</fechafin>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>--%>
                    </tr>
                    <tr>
                        <td class="tit1" nowrap>Grupo Conceptos:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('gruposcon');
                            </script>
                        </td>
                        <td class="tit1" nowrap>Datos:</td>
                        <td>
                            <script>
                                campos_defs.add('datoscodes');
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="tbFiltroOperadores" style="display: none">
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Operador:</td>
                        <td>
                            <script>
                                campos_defs.add('usrident', {
                                    nro_campo_tipo: 3,
                                    campo_codigo: 'usrident',
                                    campo_desc: 'usrdesc'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Categoria:</td>
                        <td>
                            <script>
                                campos_defs.add('catusrcodes');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Terminal:</td>
                        <td>
                            <script>
                                campos_defs.add('tipotercodes');
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Terminal:</td>
                        <td>
                            <script>
                                campos_defs.add('tercod');
                            </script>
                        </td>

                    </tr>
                </table>
                <table class="tb1" id="tbFiltroCuentas" style="display: none">
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Cuenta:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('cuecod', {
                                    campo_codigo: "cuecod",
                                    campo_desc: "nombrecta"
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>N°. Cuentas:</td>
                        <td style="width: 100%">
                            <script>
                                campos_defs.add('cuecods', {
                                    nro_campo_tipo: 101,
                                    enDB: false,
                                    filtroWhere: '<cuecod type="in">%campo_value%</cuecod>'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Alta:</td>
                        <td>
                            <script>
                                campos_defs.add('fecalta_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecalta type="mas">convert(datetime, "%campo_value%", 103)</fecalta>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecalta_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecalta type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</fecalta>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Moneda:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('moncodes');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Cta. Condición DGI:</td>
                        <td style="width: 100%">
                            <script>
                                campos_defs.add('ctacondgis');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Fecha Ultimo Mov.:</td>
                        <td>
                            <script>
                                campos_defs.add('fecultmov_desde', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecultmov type="mas">convert(datetime, "%campo_value%", 103)</fecultmov>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('fecultmov_hasta', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    filtroWhere: '<fecultmov type="menor">dateadd(dd,1,convert(datetime, "%campo_value%", 103))</fecultmov>',
                                    despliega: 'abajo'
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Sucursal:</td>
                        <td style="width: 50%">
                            <script>
                                campos_defs.add('succodes');
                            </script>
                        </td>
                        <td class="tit1" nowrap>Sistema:</td>
                        <td style="width: 100%">
                            <script>
                                campos_defs.add('sistcodes');
                            </script>
                        </td>
                        <td class="tit1" nowrap>Subsistema:</td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('codsubsists', { depende_de: 'sistcodes' });
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="tbFiltroOtros" style="display: none">
                    <tr>
                        <td class="tit1">País:</td>
                        <td>
                            <script>
                                campos_defs.add('paiscod', {
                                    campo_codigo: 'paiscod',
                                    campo_desc: 'paisdesc'
                                });
                            </script>
                        </td>
                        <td class="tit1">Provincia:</td>
                        <td>
                            <script>
                                campos_defs.add("codprovs");
                            </script>
                        </td>
                        <td class="tit1">Localidad:</td>
                        <td>
                            <script>
                                campos_defs.add("loccod", {
                                    campo_codigo: "loccod",
                                    campo_desc: "campo"
                                });
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td class="tit1" style="width: 140px" nowrap>Grupo Vínculo:</td>
                        <td style="width: 33%">
                            <script>
                                campos_defs.add('tipvinclicodes');
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Vínculo:</td>
                        <td style="width: 33%">
                            <script>
                                campos_defs.add('cliclivincodes', {
                                    depende_de: 'tipvinclicodes',
                                    depende_de_campo: 'tipvinclicod'
                                });
                            </script>
                        </td>
                        <td class="tit1" style="width: 140px" nowrap>Tipo Vinculo Cta.:</td>
                        <td style="width: 33%">
                            <script>
                                campos_defs.add('cliclivincodes_cta');
                            </script>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</body>
</html>
