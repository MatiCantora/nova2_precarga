<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", "")
    Dim nrodoc As String = nvFW.nvUtiles.obtenerValor("nrodoc", "")
    Dim strTabla As String = ""
    Dim err As New tError

    If tipdoc <> "" And nrodoc <> "" Then
        Me.contents("filtro_vinculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidad_vinculos' cn='BD_IBS_ANEXA'>" +
                                                                 "<campos>vinc_razon_social, vinc_CUIT_CUIL, vinc_tipdoc, vinc_tipdoc_desc, vinc_nrodoc, vincliclinom, rel_vincliclinom, tipvinclidesc, clivinfecalta, clivinfecven</campos>" +
                                                                 "<filtro><tipdoc type='igual'>" & tipdoc & "</tipdoc><nrodoc type='igual'>" & nrodoc & "</nrodoc></filtro><orden>vinc_razon_social ASC</orden></select></criterio>")

        Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_externo as id, desc_externo as [campo]</campos><filtro><elemento type='igual'>'documento'</elemento></filtro><orden>[campo]</orden></select></criterio>")
    Else
        Me.contents("filtro_vinculos") = ""
        err.numError = 100
        err.titulo = "Documento no definido"
        err.mensaje = "No se especificó el tipo y número de documento."
        err.response()
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Listado de Vínculos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var $body
        var $tbFiltro
        var $frameVinculos

        var vButtonItems = []

        vButtonItems[0] = []
        vButtonItems[0]["nombre"]   = "Filtrar";
        vButtonItems[0]["etiqueta"] = "Filtrar";
        vButtonItems[0]["imagen"]   = "filtro";
        vButtonItems[0]["onclick"]  = "return cargarVinculos()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"]   = "Limpiar";
        vButtonItems[1]["etiqueta"] = "Limpiar";
        vButtonItems[1]["imagen"]   = "limpiar";
        vButtonItems[1]["onclick"]  = "return limpiarFiltros()";
  
        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("filtro", "/voii/image/icons/filtro.png")
        vListButton.loadImage("limpiar", "/FW/image/icons/eliminar.png")


        function window_onload()
        {
            vListButton.MostrarListButton()

            $body           = $$('body')[0]
            $tbFiltro       = $('tbFiltro')
            $frameVinculos = $('frameVinculos')

            window_onresize()
            nvFW.bloqueo_desactivar(null, 'bloq_vinculos')
            cargarVinculos()
        }


        function window_onresize()
        {
            try {
                var body_h     = $body.getHeight()
                var tbFiltro_h = $tbFiltro.getHeight()
                
                $frameVinculos.style.height = body_h - tbFiltro_h + 'px'
            }
            catch(e) {}
        }


        function cargarVinculos()
        {
            if (nvFW.pageContents.filtro_vinculos == '') {
                alert('Ocurrio un error al intentar cargar los vínculos debido a que no hay un documento presente.')
                return
            }
            else {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtro_vinculos,
                    filtroWhere: getFiltros(),
                    formTarget: 'frameVinculos',
                    path_xsl: 'report/Plantillas/HTML_listado_vinculos.xsl',
                    cls_contenedor: 'frameVinculos',
                    cls_contenedor_msg: ' ',
                    bloq_contenedor: $('frameVinculos'),
                    bloq_msg: 'Cargando vínculos...',
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0
                })
            }
        }


        function limpiarFiltros()
        {
            campos_defs.clear('nombreEntidad')
            campos_defs.clear('nroDocu')
            campos_defs.clear('tipoDocu')

            cargarVinculos()
        }


        function getFiltros()
        {
            // Armar el filtro Where
            var filtro = ''

            var nro_docu = campos_defs.get_value('nroDocu')
            if (nro_docu != '') {
                filtro += "<vinc_nrodoc type='igual'>" + nro_docu + "</vinc_nrodoc>";
                var tipo_docu = campos_defs.get_value('tipoDocu')
                if (tipo_docu != '') {
                    filtro += "<vinc_tipdoc type='igual'>" + tipo_docu + "</vinc_tipdoc>";
                }
            }
            
            // Razón Social
            if (campos_defs.get_value('nombreEntidad') != '')
                filtro += '<vinc_razon_social type="like">%' + campos_defs.get_value('nombreEntidad').toUpperCase() + '%</vinc_razon_social>'

            return filtro
        }


        function verVinculo(evento, nombre, vinc_tipdoc, vinc_nrodoc)
        {
            var url_destino = '/voii/cargar_cliente.aspx?tipdoc=' + vinc_tipdoc + '&nrodoc=' + vinc_nrodoc + '&titulo=' + nombre

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
                var porcentajeHeight;
                if (screen.height < 800)
                    porcentajeHeight = 0.947;
                else porcentajeHeight = 0.963;

                var frame = top.ObtenerVentana('frame_ref')
                var win_vinculo = frame.nvFW.createWindow({
                    url: url_destino,
                    title: '<b>' + nombre + '</b>',
                    width: frame.innerWidth * 0.988, //1024,
                    height: frame.innerHeight * porcentajeHeight,//500,
                    destroyOnClose: true
                })

                win_vinculo.showCenter(true)
            }
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script>nvFW.bloqueo_activar($$('body')[0], 'bloq_vinculos', 'Cargando vínculos...')</script>
    
    <table class="tb1" cellspacing="0" cellpadding="0" id="tbFiltro">
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="text-align: center;" colspan="2" width="30%"><b>Documento</b></td>
                        <td style="text-align: center;">Apellido y Nombres / Razón Social</td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('tipoDocu', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.filtro_nomenclador_documento,
                                    nro_campo_tipo: 1
                                });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nroDocu', { enDB: false, nro_campo_tipo: 100 });
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nombreEntidad', { enDB: false, nro_campo_tipo: 104 });
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
            <td style="width: 300px;">
                <table class="tb1">
                    <tr>
                        <td style="width: 50%;">
                            <div id="divFiltrar">Filtrar</div>
                        </td>
                        <td style="width: 50%;">
                            <div id="divLimpiar">Limpiar</div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <iframe id="frameVinculos" name="frameVinculos" style="width: 100%; height: 150px; border: none; overflow: hidden;" src="enBlanco.htm"></iframe>

</body>
</html>
