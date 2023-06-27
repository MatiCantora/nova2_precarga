<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%

 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />

    <title>NOVA VOII</title>
    
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet"/>
    <link rel="shortcut icon" href="/fw/image/icons/nv_voii.ico"/>
    
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>

    <% = Me.getHeadInit() %>
    <script type="text/javascript">
        function window_onload() {
            //var dif = Prototype.Browser.IE ? 5 : 2
            //var body_h = $$('table')[0].getHeight()
            //var menu_h = $$('div')[0].getHeight()
            ////var FiltroDatos_h = $('divCabe').getHeight() + $('voiiFrame').getHeight()
            //$$('body').setStyle({ 'height': body_h + menu_h + 'px' });

            parent.setFrameList($('frame_listado'))
        }

        function setValues() {
            parent.setFrameVals($('ibs_cliente_oficial').value, $('vinculos').value, $('alta_cli').value, $('alta_cli_to').value )
        }

        function abrir_entidad_win(event, nro_archivo_id_tipo, id_tipo) {
            parent.abrir_entidad_win(event, nro_archivo_id_tipo, id_tipo)
        }

        function def_archivo(nro_def_archivo, nro_def_detalle) {
            parent.def_archivo(nro_def_archivo, nro_def_detalle)
        }

        function cambioEstadoMasivo(a) {
            parent.cambioEstadoMasivo(a)
        }

        function getWin(win, aum, n_des, n_id) {
            parent.getWin(win, aum, n_des, n_id)
        }

        function mostrar_entidades(pos, nro) {
            parent.mostrar_entidades(pos, nro)
        }

        function mostrar_reclamos(pos, nro) {
            parent.mostrar_reclamos(pos, nro)
        }

        function filtro_fn() {
            parent.filtro_fn()
        }

        function getVars(nro_ent) {
            parent.getVars(nro_ent)
        }

        function mostrar_creditos(nro_credito) {
            parent.mostrar_creditos(nro_credito)
        }


    </script>
</head>
<body id="body" onload="window_onload()" style="overflow: hidden;">
    <div id="divMenuFrame"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuFrame = new tMenu('divMenuFrame', 'vMenuFrame');
        Menus["vMenuFrame"] = vMenuFrame
        Menus["vMenuFrame"].alineacion = 'centro';
        Menus["vMenuFrame"].estilo = 'A';

        Menus["vMenuFrame"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Filtros de busqueda avanzada</Desc></MenuItem>")

        vMenuFrame.MostrarMenu()
    </script>
            <table id="filters" style="width: 100%; margin: 0 auto;" class="tb1">
                    <tr class="tbLabel">
                        <td id="campos_def_1_tit" style="width:15%;text-align:center"><b>Oficial de cuenta</b></td>
                        <td style="width:15%;text-align:center"><b>Vinculos</b></td>
                        <td colspan="2" id="campos_def_2_tit" style="width:15%;text-align:center"><b>Alta Cliente</b></td>
                    </tr>
                    <tr>
                        <td id="campos_def_1">
                            <script type="text/javascript">
                                campos_defs.add('ibs_cliente_oficial', {
                                    enDB: true,
                                    nro_campo_tipo: 2,
                                    target: 'campos_def_1'
                                })
                                campos_defs.items['ibs_cliente_oficial'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                        <td style="float:initial;z-index:3"><input style="width:100%;float:initial;z-index:3" id="vinculos" type="text" onchange="setValues()"/></td>
                        <td id="campos_def_2">
                            <script type="text/javascript">
                                campos_defs.add('alta_cli', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    target: 'campos_def_2'
                                })
                                campos_defs.items['alta_cli'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                        <td id="campos_def_2_to">
                            <script type="text/javascript">
                                campos_defs.add('alta_cli_to', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    target: 'campos_def_2_to'
                                })
                                campos_defs.items['alta_cli_to'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                    </tr>
            </table>
<iframe name="frame_listado" id="frame_listado" src="/fw/enBlanco.htm" style="width: 100%; height:100%; max-height:625px; overflow:auto;z-index:0" frameborder='0'></iframe>
</body>
</html>
