<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nro_entidad As Integer = nvFW.nvUtiles.obtenerValor("nro_entidad", 0)
    Dim entidad_consultar As String = nvFW.nvUtiles.obtenerValor("entidad_consultar", "")

    Me.contents("filtro_ent_vinculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_vinculos'><campos>nro_entidad, id_ent_vinc, vinc_baja, CASE WHEN persona_fisica_vinc = 1 THEN 1 WHEN persona_fisica_vinc = 0 THEN 2 END AS vinc_tipocli,nro_entidad_vinc , razon_social_vinc, tipo_docu_vinc, vinc_grupo, vinc_tipo, documento_vinc, nro_docu_vinc, vinc_desde, vinc_hasta, nro_vinc_tipo, origen, vinc_tiporel</campos><filtro><nro_entidad type='igual'>%nro_entidad%</nro_entidad></filtro><orden></orden></select></criterio>")

    Me.addPermisoGrupo("permisos_vinculos")

    Me.contents("nro_entidad") = nro_entidad
    Me.contents("entidad_consultar") = entidad_consultar
    'Me.contents("url_ver_vinculo") = url_ver_vinculo
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

        var nro_entidad = nvFW.pageContents.nro_entidad;

        var verTodos = false;

        var vinculosExternos = [];
        var entidad_consultar = nvFW.pageContents.entidad_consultar;


        function window_onload() {

            if (typeof parent.vinculosExternos != "undefined") {
                vinculosExternos = parent.vinculosExternos;
            }


            nvFW.enterToTab = false;

            //vListButton.MostrarListButton();

            window_onresize();

            buscarVinculos();

        }

        function window_onresize() {

            $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divCabecera').getHeight() })

        }

        var vinculosArray = new Array();
        function buscarVinculos() {

            var filtro = "";

            if (!verTodos)
                filtro += "<sql type='sql'>vinc_baja IS NULL</sql>";


            var cantFilas

            cantFilas = Math.floor(($("frameDatos").getHeight() - 18 * 2) / 22);

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_ent_vinculos,
                filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                params: "<criterio><params nro_entidad='" + nro_entidad + "' /></criterio>",
                path_xsl: "report\\verVinculos\\HTML_verVinculos.xsl",
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frameDatos',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando vinculos...',
                cls_contenedor: 'frameDatos'
                //funComplete: function () {



                //}

            });

        }


        function agregar_vinculo() {

            var url = '/FW/entidades/vinculos/ent_vinculos_abm.aspx?nro_entidad=' + nro_entidad

            if (entidad_consultar != '')
                url += '&entidad_consultar=' + entidad_consultar

            win_abm_entidad = parent.nvFW.createWindow({
                url: url,
                title: '<b>ABM Vínculos</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: false,
                width: 850,
                height: 300,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) { buscarVinculos() }
                },
                destroyOnClose: true
            })

            win_abm_entidad.showCenter(true)
        }


        function verVinculo(evento, vinc_nro_entidad, vinc_nombre, vinc_tipocli, vinc_tipdoc, vinc_nrodoc, vinc_nro_entidad_aux, vinc_tiporel) {

            var url_destino = ""
            var width
            var height
            var modal = true;
            var target = window.top.nvFW;
            var minimizable = false;
            var resizable = false;
            var maximizable = false;
            var draggable = false;


            if (nro_entidad != 0) {

                if (vinc_nro_entidad == '')
                    vinc_nro_entidad = vinc_nro_entidad_aux != '' ? vinc_nro_entidad_aux : 0

                if (typeof parent.verEntidad != "undefined") {
                    parent.verEntidad(evento, vinc_nro_entidad, vinc_tipdoc, vinc_nrodoc, vinc_tipocli, vinc_nombre, vinc_tiporel)
                    return
                } else {

                    if (vinc_nro_entidad == '')
                        vinc_nro_entidad = vinc_nro_entidad_aux

                    //Entidad de Nv
                    width = 1024;
                    height = 600;
                    url_destino += "/FW/entidades/entidad_abm.aspx?nro_entidad=" + vinc_nro_entidad;
                }
            }
            else {

                if (typeof parent.verEntidad != "undefined") {
                    parent.verEntidad(evento, vinc_nro_entidad, vinc_tipdoc, vinc_nrodoc, vinc_tipocli, vinc_nombre, vinc_tiporel)
                    return
                }


            }

            // Abrir datos según modificadores (Ctrl | Shift)
            if (evento.ctrlKey) {
                // Nueva pestaña
                var newWin = window.open(url_destino)
            }
            else if (evento.shiftKey) {
                // Nueva ventana de browser
                var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                newWin.moveTo(0, 0)
                newWin.resizeTo(screen.availWidth, screen.availHeight)
            }
            else {
                // Ventana flotante NO-modal. Comportamiento por defecto
                var win_vinculo = target.createWindow({
                    url: url_destino,
                    title: '<b>' + vinc_nombre + '</b>',
                    width: width,
                    height: height,
                    draggable: draggable,
                    resizable: resizable,
                    minimizable: minimizable,
                    maximizable: maximizable,
                    destroyOnClose: true
                })

                win_vinculo.showCenter(modal);
            }

        }

        function verHistoricoVinculos() {

            if (verTodos)
                verTodos = false;
            else verTodos = true;

            buscarVinculos();
        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;' <%--onkeypress="return key_Buscar()"--%>>
    <div id="divCabecera" style="width: 100%">
    </div>
    <iframe src="/fw/enBlanco.htm" style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
</body>
</html>
