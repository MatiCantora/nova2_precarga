<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%
    Dim eventKey As Boolean = nvFW.nvUtiles.obtenerValor("eventKey", False)
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador

    If cuit <> "" Then
        Me.contents("filtroSolicitud") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>" & nro_operador & " as nro_operador_consulta, *</campos><orden></orden><filtro><cuil type='igual'>" + cuit + "</cuil></filtro></select></criterio>")
    Else
        Me.contents("filtroSolicitud") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>" & nro_operador & " as nro_operador_consulta, *</campos><orden></orden><filtro></filtro></select></criterio>")
    End If

    Me.contents("filtroSol_params") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSol_filtro_params'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroOperador_bloq") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSol_bloqueo_usuario'><campos>operador as id, descripcion as  [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroParam") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSol_params'><campos>param as id, etiqueta as [campo]</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("otraVentana") = eventKey
    Me.contents("cuit") = cuit

    Me.contents("filtroSolicitudRPT") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud_PF_OnLine'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("today") = DateTime.Today.ToString("dd/MM/yyyy")

    Me.addPermisoGrupo("permisos_solicitudes")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Solicitud</title>

    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit() %>

    <script type="text/javascript">    

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_solicitud(0)";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');
        vListButton.loadImage("excel", '/FW/image/icons/excel.png');
        vListButton.loadImage("imprimir", '/FW/image/icons/imprimir.png');

        var solicitudes = [];
        var estado = '';
        var nro_circuito = '';
        var tipo_solicitud = '';
        var comparar_tipo = true;
        var ventana = nvFW.getMyWindow();
        var solVentana;
        var solVentanas = new Map;

        var porcentajeHeight;
        var porcentajeWidth;

        var otraVentana;

        var cuit = nvFW.pageContents.cuit;

        var pathSolicitud = 'report\\Plantillas\\ModSolicitud\\html_listar_solicitudes_cliente.xsl';


        function window_onload() {
            
            vListButton.MostrarListButton();

            var today = nvFW.pageContents.today;
            campos_defs.set_value('fe_estado_desde', today);

            solicitudes = [];
            estado = '';
            solVentana = 0;
            tipo_solicitud = '';
            nro_circuito = '';
            comparar_tipo = true;

            campos_defs.habilitar('sol_param', false)
            campos_defs.habilitar('valor', false)

            otraVentana = nvFW.pageContents.otraVentana;

            window_onresize();

            if (cuit == '')
                pathSolicitud = 'report\\Plantillas\\ModSolicitud\\html_listar_solicitudes.xsl';
            else {
                campos_defs.set_value('fe_estado_desde', '');
                buscar_solicitud(0);
            }

        }


        function window_onresize() {

            var dif = Prototype.Browser.IE ? 5 : 2;

            $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divCabecera').getHeight() - dif - 7 + 'px' });

            if (solVentanas.size > 0) {

                ventanas_solicitud_resizes()

            }

        }

        function ventanas_solicitud_resizes() {

            solVentanas.forEach(function (value, key, mapa) {

                var height = value.element.getHeight();
                var width = value.element.getWidth();
                var mayor = 0; //Mover arriba si no quiero seguir alineando al centro

                if (!value.isMaximized()) {
                    if ($$("body")[0].getWidth() < value.element.getWidth()) {
                        width = $$("body")[0].getWidth() * porcentajeWidth;
                        mayor = 1;
                    }
                    if ($$("body")[0].getHeight() < value.element.getHeight()) {
                        height = $$("body")[0].getHeight() * porcentajeHeight;
                        mayor = 1;
                    }
                    if (mayor = 1) {
                        value.setSize(width, height);

                        var leftLocation;

                        if (parent.document.getElementById('tb_cab').getWidth() > 749) {
                            //leftLocation = ((parent.document.getElementById('tb_cab').getWidth() - $$("body")[0].getWidth()) / 2) + 1;
                            leftLocation = ((parent.document.getElementById('tb_cab').getWidth() - value.element.childNodes[4].getWidth()) / 2);
                        } else {
                            leftLocation = 4;
                        }
                        var topLocation = parent.document.getElementById('tb_cab').getHeight() + value.element.childNodes[4].getHeight() + 2;
                        value.setLocation(topLocation, leftLocation);

                    }
                } else {
                    height = (parent.document.getElementById('tb_cab').getHeight() + parent.document.getElementById('tb_body').getHeight()) * 0.96;
                    width = parent.document.getElementById('tb_cab').getWidth() * 0.99;
                    value.setSize(width, height);
                    value.setLocation(0, 0);
                }
            });
        }

        function buscar_solicitud(accion) {

            if (solicitudes.length > 0) {
                solicitudes = [];
                estado = '';
                tipo_solicitud = '';
                nro_circuito = '';
                comparar_tipo = true;
            }

            var filtro = campos_defs.filtroWhere()                       

            if (campos_defs.get_value('fe_alta_desde') != "") {
                filtro += "<fe_alta type='mas'>convert(datetime, '" + campos_defs.get_value('fe_alta_desde') + "', 103)</fe_alta>";
            }
            if (campos_defs.get_value('fe_alta_hasta') != "") {
                filtro += "<fe_alta type='menor'>dateadd(dd,1,convert(datetime, '" + campos_defs.get_value('fe_alta_hasta') + "', 103))</fe_alta>";
            }
            if (campos_defs.get_value('fe_estado_desde') != "") {
                filtro += "<fe_estado type='mas'>convert(datetime, '" + campos_defs.get_value('fe_estado_desde') + "', 103)</fe_estado>";
            }
            if (campos_defs.get_value('fe_estado_hasta') != "") {
                filtro += "<fe_estado type='menor'>dateadd(dd,1,convert(datetime, '" + campos_defs.get_value('fe_estado_hasta') + "', 103))</fe_estado>";
            }
            
            var cantFilas
            if ($('cantfilas').value != '') {
                cantFilas = $('cantfilas').value;
            } else {
                cantFilas = Math.floor(($("frameDatos").getHeight() - 18) / 24); //con checkbox
            }


            if (accion == 0) {                

                if (campos_defs.get_value('sol_param') != '') {

                    nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtroSol_params,
                        filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: "report\\Plantillas\\ModSolicitud\\html_listar_solicitudes_params.xsl",
                        salida_tipo: 'adjunto',
                        ContentType: 'text/html',
                        formTarget: 'frameDatos',
                        nvFW_mantener_origen: true,
                        bloq_contenedor: $$('body')[0],
                        bloq_msg: 'Buscando solicitudes...',
                        cls_contenedor: 'frameDatos'

                    });

                } else {
                    nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtroSolicitud,
                        filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                        path_xsl: pathSolicitud,
                        salida_tipo: 'adjunto',
                        ContentType: 'text/html',
                        formTarget: 'frameDatos',
                        nvFW_mantener_origen: true,
                        bloq_contenedor: $$('body')[0],
                        bloq_msg: 'Buscando solicitudes...',
                        cls_contenedor: 'frameDatos'

                    });
                }
            } else {
                
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroSolicitud
                    , filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>"
                    , path_xsl: "report\\EXCEL_base.xsl"
                    , salida_tipo: "adjunto"
                    , ContentType: "application/vnd.ms-excel"
                    , filename: "Solicitudes.xls"
                });
            }

        }
        var win
        function ver_solicitud(nro_sol, nro_sol_tipo, apenom, e) {
            
            if (!nvFW.tienePermiso('permisos_solicitudes', 1)) {
                alert('No posee permisos para ver la solicitud');
                return
            }

            var url_destino = "/voii/solicitudes/solicitud_abm.aspx?nro_sol = " + nro_sol + "&nro_sol_tipo=" + nro_sol_tipo;

            if (e.ctrlKey == true) {
                var win = window.open(url_destino)
            } else if (e.shiftKey) {
                // Nueva ventana de browser
                var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                newWin.moveTo(0, 0)
                newWin.resizeTo(screen.availWidth, screen.availHeight)
            } else {
                var width;
                var height;

                if (screen.height < 800) {
                    porcentajeHeight = 0.94;
                    porcentajeWidth = 0.988;
                    height = $$("body")[0].getHeight() * porcentajeHeight;
                    width = $$("body")[0].getWidth() * porcentajeWidth;
                    //porcentajeHeight = 0.947;
                }
                else {
                    //porcentajeHeight = 0.963;
                    //porcentajeWidth = 0.988;
                    porcentajeHeight = 0.92;
                    porcentajeWidth = 0.94;
                    height = $$("body")[0].getHeight() * porcentajeHeight;
                    width = $$("body")[0].getWidth() * porcentajeWidth;
                }

                //var win = nvFW.createWindow({                   
                 win = parent.nvFW.createWindow({
                     url: "/voii/solicitudes/solicitud_abm.aspx?nro_sol=" + nro_sol + "&nro_sol_tipo=" + nro_sol_tipo, width: "1200",
                    title: "<b>Solicitud N� " + nro_sol + " " + apenom + "</b>",
                    resizable: true,
                    height: height,
                    width: width,
                    onShow: function (win) {
                        solVentana += 1;
                        var topLocation = parent.document.getElementById('tb_cab').getHeight() + (win.element.childNodes[4].getHeight() + 2) * solVentana;
                        var leftLocation = ((parent.document.getElementById('tb_cab').getWidth() - win.element.childNodes[4].getWidth()) / 2);

                        win.setLocation(topLocation, leftLocation);

                        solVentanas.set(win.getId(), win);

                    },
                    onClose: function (win) {
                        solVentana -= 1;

                        solVentanas.delete(win.getId());

                        if (win.options.userData.hay_modificacion) {
                            buscar_solicitud(0);
                            //campos_head.pagina_cambiar(campos_head.AbsolutePage)
                        }
                    }

                })

                var id = win.getId();
                focus(id);

                win.showCenter()

            }

        }

        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscar_solicitud(0);
        }

        function cambiar_estado() {

            if (!check_sol_comparar()) {
                nvFW.alert("Selecci�n de solicitud con estado diferente");
                solicitudes = [];
                estado = '';
                tipo_solicitud = '';
                nro_circuito = '';
                comparar_tipo = true;
                return
            } else {
                if (!comparar_tipo) {
                    nvFW.alert("Selecci�n de solicitud con tipo diferente");
                    solicitudes = [];
                    estado = '';
                    tipo_solicitud = '';
                    nro_circuito = '';
                    comparar_tipo = true;
                    return
                }
            }

            if (solicitudes.length == 0) {
                nvFW.alert("No ha seleccionado ninguna solicitud");
                return;
            }

            var win = top.nvFW.createWindow({
                url: "/voii/solicitudes/cambio_estado_masivo.aspx?nro_sol_array=" + solicitudes.toString() + "&sol_estado=" + estado + "&nro_circuito=" + nro_circuito, width: "822", height: "450", top: "50",
                title: "<b>Solicitud</b>",
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {

                        buscar_solicitud(0);
                        //campos_head.pagina_cambiar(campos_head.AbsolutePage)
                    }
                    solicitudes = [];
                    estado = '';
                    tipo_solicitud = '';
                    nro_circuito = '';
                    comparar_tipo = true;
                }

            })

            win.showCenter(false)

            //}

        }


        function check_sol_comparar() {
            var compare = true;
            var frame = document.getElementById('frameDatos');
            var checkboxes = frame.contentWindow.document.getElementsByName('check_children');
            solicitudes = [];
            estado = '';
            tipo_solicitud = '';
            nro_circuito = '';
            comparar_tipo = true;

            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].checked) {
                    solicitudes.push(checkboxes[i].attributes.nro_sol.nodeValue)
                    if (estado == '') {
                        estado = checkboxes[i].attributes.sol_estado.nodeValue;
                        tipo_solicitud = checkboxes[i].attributes.nro_sol_tipo.nodeValue;
                        nro_circuito = checkboxes[i].attributes.nro_circuito.nodeValue;
                    } else {
                        if (estado != checkboxes[i].attributes.sol_estado.nodeValue)
                            compare = false;
                        if (tipo_solicitud != checkboxes[i].attributes.nro_sol_tipo.nodeValue)
                            comparar_tipo = false;
                    }

                }
                //solicitudes.push(checkboxes[i].attributes.value.nodeValue)
            }

            return compare;

        }

        function desbloquearSolicitud(nro_sol) {
            var pXML = "<sol modo='Q' nro_sol='" + nro_sol + "'><bloqueo>false</bloqueo></sol>"

            nvFW.error_ajax_request('solicitud_abm.aspx', {
                parameters: { paramXML: pXML, nro_sol: nro_sol },
                //bloq_msg: "Desbloqueando",
                onSuccess: function (err, transport) {

                    if (err.numError == 0) {
                        buscar_solicitud(0);
                    }

                },
                error_alert: true
            });
        }

        function mostrarParametros() {

            if (campos_defs.get_value('nro_sol_tipos') != '') {
                campos_defs.habilitar('sol_param', true)
                campos_defs.habilitar('valor', true)
            } else {
                campos_defs.habilitar('sol_param', false)
                campos_defs.habilitar('valor', false)
            }

            window_onresize()
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;' onkeypress="return key_Buscar()">
    <div id="divCabecera" style="width: 100%">
        <table id="tbFiltros" class="tb1" style="width: 100%">
            <tr>
                <td colspan="2">
                    <div id="divMenu"></div>
                </td>
                <script type="text/javascript">


                    if (nvFW.pageContents.cuit != "") {
                        $('divMenu').hide();
                    } else {

                        var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

                        Menus["vMenuModulos"] = vMenuModulos
                        Menus["vMenuModulos"].alineacion = 'centro';

                        Menus["vMenuModulos"].estilo = 'A';
                        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Solicitudes</Desc></MenuItem>")

                        vMenuModulos.loadImage("excel", '/FW/image/icons/excel.png');
                        vMenuModulos.loadImage("estado", '/FW/image/icons/cambio_estado.png');

                        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>estado</icono><Desc>Cambiar Estado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>cambiar_estado(event)</Codigo></Ejecutar></Acciones></MenuItem>")
                        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>buscar_solicitud(1)</Codigo></Ejecutar></Acciones></MenuItem>")

                        vMenuModulos.MostrarMenu()
                    }

                </script>
            </tr>
            <%--HTML en ventana solicitud--%>
            <% if cuit = "" Then %>
            <tr>
                <td style="width: 90%">
                    <table class="tb1">
                        <tr class="tbLabel">
                            <td style="text-align: center; width: 5%" colspan="2" nowrap>Nro. Solicitud</td>
                            <td style="text-align: center; width: 12%" colspan="2" nowrap>Tipo Solicitud</td>
                            <td style="text-align: center; width: 12%">Estado</td>
                            <td style="text-align: center; width: 12%">Parametro</td>
                            <td style="text-align: center; width: 12%">Valor</td>
                            <td id="tdDesc" style="text-align: center;">Descripci�n</td>
                            <td id="tdOperador" style="text-align: center; width: 10%" nowrap>Operador Estado</td>
                            <td id="tdOperador_bloq" style="text-align: center; width: 10%" nowrap>Operador Bloqueo</td>
                        </tr>
                        <tr>
                            <td id="nro_sol_CD" colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('nro_sol', {
                                        enDB: false,
                                        nro_campo_tipo: 100,
                                        filtroWhere: "<nro_sol type='igual'>'%campo_value%'</nro_sol>"
                                    });
                                </script>
                            </td>
                            <td id="nro_sol_tipos_CD" colspan="2">
                                <script type="text/javascript">
                                    campos_defs.add('nro_sol_tipos', { onchange: mostrarParametros });
                                </script>
                            </td>
                            <td id="sol_estados_CD">
                                <script type="text/javascript">
                                    campos_defs.add('sol_estados');
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add("sol_param");
                                </script>
                            </td>
                            <td>
                                <script type="text/javascript">
                                    campos_defs.add('valor', {
                                        enDB: false,
                                        nro_campo_tipo: 104,
                                        filtroWhere: "<valor type='like'>%%campo_value%%</valor>"
                                    });
                                </script>
                            </td>
                            <td id="desc_CD">
                                <script type="text/javascript">
                                    campos_defs.add('sol_desc', {
                                        enDB: false,
                                        nro_campo_tipo: 104,
                                        filtroWhere: "<sol_desc type='like'>%%campo_value%%</sol_desc>"
                                    });
                                </script>
                            </td>
                            <td id="operador_CD">
                                <script type="text/javascript">
                                    campos_defs.add("nro_operador");
                                </script>
                            </td>
                            <td id="operador_bloqueo_CD">
                                <script type="text/javascript">
                                    campos_defs.add("bloq_operador", {
                                        enDB: false,
                                        filtroXML: nvFW.pageContents.filtroOperador_bloq,
                                        nro_campo_tipo: 2,
                                        filtroWhere: "<bloq_operador type='in'>'%campo_value%'</bloq_operador>"
                                    });
                                </script>
                            </td>
                        </tr>                       
                        </table>

                        <table class="tb1">
                        <tr class="tbLabel">
                            <td style="text-align: center; width: 20%" colspan="2" nowrap>Fecha Alta</td>
                            <td style="text-align: center; width: 20%" colspan="2" nowrap>Fecha Estado</td>
                            <td id="tdDni" style="text-align: center; width: 17%">DNI</td>
                            <td id="tdCuil" style="text-align: center; width: 17%">CUIL</td>
                            <td id="tdNombre" style="text-align: center;" colspan="2">Nombre y Apellido</td>
                        </tr>
                        <tr>
                            <td id="fe_alta_desde_CD">
                                <script>
                                    campos_defs.add("fe_alta_desde", { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td>
                            <td id="fe_alta_hasta_CD">
                                <script>
                                    campos_defs.add("fe_alta_hasta", { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td>
                            <td id="fe_estado_desde_CD">
                                <script>
                                    campos_defs.add("fe_estado_desde", { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td>
                            <td id="fe_estado_hasta_CD">
                                <script>
                                    campos_defs.add("fe_estado_hasta", { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td>
                            <td id="documento_CD">
                                <script>
                                    campos_defs.add('documento', {
                                        enDB: false,
                                        nro_campo_tipo: 100,
                                        filtroWhere: "<cuil type='igual'>'%campo_value%'</cuil>"
                                    });
                                </script>
                            </td>
                            <td id="cuil_CD">
                                <script>
                                    campos_defs.add("cuil", {
                                        enDB: false,
                                        nro_campo_tipo: 100,
                                        filtroWhere: "<cuil type='igual'>'%campo_value%'</cuil>"
                                    });
                                </script>
                            </td>
                            <td id="nombre_CD">
                                <script>
                                    campos_defs.add("nombre", {
                                        enDB: false,
                                        nro_campo_tipo: 104,                                        
                                        filtroWhere: "<SQL type='sql'>concat(nombre,' ',apellido) like '%%campo_value%%'</SQL>"
                                    });
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
                <td>
                    <table class="tb1">
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="2" style="vertical-align: middle">
                                <div id="divBuscar" style="width: 100%"></div>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">&nbsp;</td>
                        </tr>
                        <tr>
                            <td class="Tit1" style="height: 18px" nowrap>Cant. filas:</td>
                            <td>
                                <input type="number" name="cantfilas" id="cantfilas" style="width: 50px; height: 16px"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <%--HTML en ventana cliente--%>
            <% Else %>
           <tr>
                <td style="width: 90%">
                    <table class="tb1" style="width: 100%">
                        <tr class="tbLabel">
                            <td style="text-align: center; width: 7%" nowrap>Nro. Solicitud</td>
                            <td style="text-align: center; width: 20%" nowrap>Tipo Solicitud</td>
                            <td style="text-align: center; width: 15%">Estado</td>
                            <td id="tdDesc" style="text-align: center; width: 17%">Descripci�n</td>
                            <td style="text-align: center; width: 20.5%" colspan="2" nowrap>Fecha Alta</td>
                            <td style="text-align: center; width: 20.5%" colspan="2" nowrap>Fecha Estado</td>
                            <tr>
                                <td id="nro_sol_CD">
                                    <script>
                                        campos_defs.add('nro_sol', { enDB: false, nro_campo_tipo: 100 });
                                    </script>
                                </td>
                                <td id="nro_sol_tipos_CD">
                                    <script>
                                        campos_defs.add('nro_sol_tipos');
                                    </script>
                                </td>
                                <td id="sol_estados_CD">
                                    <script>
                                        campos_defs.add('sol_estados');
                                    </script>
                                </td>
                                <td id="desc_CD" style="width: 17%">
                                    <script>
                                        campos_defs.add('sol_desc', { enDB: false, nro_campo_tipo: 104 });
                                    </script>
                                </td>
                                <td id="fe_alta_desde_CD" style="width: 10.25%">
                                    <script>
                                        campos_defs.add("fe_alta_desde", { enDB: false, nro_campo_tipo: 103 });
                                    </script>
                                </td>
                                <td id="fe_alta_hasta_CD" style="width: 10.25%">
                                    <script>
                                        campos_defs.add("fe_alta_hasta", { enDB: false, nro_campo_tipo: 103 });
                                    </script>
                                </td>
                                <td id="fe_estado_desde_CD" style="width: 10.25%">
                                    <script>
                                        campos_defs.add("fe_estado_desde", { enDB: false, nro_campo_tipo: 103 });
                                    </script>
                                </td>
                                <td id="fe_estado_hasta_CD" style="width: 10.25%">
                                    <script>
                                        campos_defs.add("fe_estado_hasta", { enDB: false, nro_campo_tipo: 103 });
                                    </script>
                                </td>
                            </tr>
                    </table>
                </td>
                <td>
                    <table class="tb1">
                        <tr>
                        <tr>
                            <td colspan="2" style="vertical-align: middle">
                                <div id="divBuscar" style="width: 100%"></div>
                            </td>
                        </tr>
                        <tr></tr>
                        <tr>
                            <td class="Tit1" style="height: 18px" nowrap>Cant. filas:</td>
                            <td>
                                <input type="number" name="cantfilas" id="cantfilas" style="width: 50px; height: 16px"></td>
                        </tr>
                    </table>
                </td>
            </tr>
            <% End If %>
        </table>
    </div>
    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
</body>
</html>
