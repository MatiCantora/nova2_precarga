<%@ Page Language="VB" AutoEventWireup="false" CodeFile="default.aspx.vb" Inherits="default_precarga" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1 " lang="es">
    <meta name="viewport" content="width=device-width, user-scalable=no" lang="es">
    <meta name="mobile-web-app-capable" content="yes" lang="es">
    <meta http-equiv="Content-Language" content="es" />
    <meta name="google" content="notranslate" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />

    <title>NOVA Precarga</title>

    <link href="/precarga/image/icons/nv_mutual.png" sizes="193x193" rel="shortcut icon" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga2.css" type="text/css" rel="stylesheet" />
    <link rel="manifest" href="/precarga/manifest.json">

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="script/drawcontrol.js"></script>
    <script type="text/javascript" src="script/precarga.js"></script>
    <script type="text/javascript" src="script/analisis.js?v=20220902"></script>
    <script type="text/javascript" src="script/cancelaciones.js"></script>
    <script type="text/javascript" src="script/planes.js"></script>
    <script type="text/javascript" src="/fw/script/utiles.js"></script>
    <script type="text/javascript" src="script/estadisticas.js"></script>
    <script type="text/javascript" src="script/bcra.js"></script>
    <script type="text/javascript" src="script/creditos.js"></script>
    <script type="text/javascript" src="script/wizzard.js"></script>
    <script type="text/javascript" src="script/default2.aspx.js"></script>
    <script type="text/javascript" src="script/default.aspx.js"></script>
    <script type="text/javascript" src="script/consulta.js"></script>

    <% = Me.getHeadInit()%>

</head>
<body id="body" onload="return precarga.window_onload()" onresize="return precarga.window_resize()" style="visibility: hidden; overflow-y: hidden; overflow-x: auto;">

    <form id="form1" action=""></form>

    <div style="height: 100%; float: left" id="div_padding_left"></div>

    <div id="div_body" class="centered_div">
        <table id='top_menu' border='0' style="height: 8.5vh">
            <tr>
                <td style='width: 42px; padding-left: 2%;' id='imgMenu'>
                    <img id='img_Menu' style='height: 32px; width: 32px;' border='0' class='img_button_sesion' alt='Menu' title='Menú' src='image/menu.svg' onclick='drawcontrol.menu_izquierdo_swipe()' />
                </td>
                <td style='text-align: center; width: 60%'>
                    <object data='image/Logo red mutual azul-02 1.svg' class='logo' id="logo" type='image/svg+xml'>
                        <img src='/fw/image/nvLogin/nvLogin_logo.png' alt='PNG image of standAlone.svg' />
                    </object>
                </td>
                <td id='data_user' style='text-align: right; vertical-align: middle; display: none' nowrap>
                    <div id="menu_right" style="background-color: white; display: inline"></div>
                </td>
                <td style="width: 20%;" id="imgMenuDerecho" class="imgSession">
                    <img src="./image/sesion_cerrar.svg" alt="" onclick="nvSesion.cerrar()" />
                    <img src="./image/sesion_bloquear.svg" alt="" onclick="nvSesion.bloquear()" />
                </td>
            </tr>
        </table>

        <div id="menu_right_vidrio" onclick="mostrarMenuDerecho()" style="background-color: white; position: fixed; left: -540px; bottom: 0px; filter: alpha(opacity=0); opacity: 0.0; width: 50px;">
        </div>

        <div id="divMenu" style="z-index: 1; background-color: white; height: 100%; transition: .3s all; border-right: 3px solid #E3E0E3; overflow: hidden; width: 250px; position: absolute">
            <div id="divInfoVendedor" style="background-color: var(--azul); color: var(--blanco); vertical-align: middle; padding-top: 25px; padding-bottom: 25px; display: flex; align-items: center; gap: 10px; padding-left: 15px;">
                <img src="/precarga/image/star.svg" />
                <div style="display: flex; flex-direction: column">
                    <span id="strVendedor" class="Seller"></span>
                    <span id="strCategoria" class="Seller" style="font-weight: bold">Categoria Bronze</span>
                </div>

            </div>
            <div id="divMenuLeft" style="height: 100%; width: 100%"></div>
            <div id="divMenuLeftMobile" style="height: 100%; width: 100%; padding-left: 15px;"></div>

        </div>

        <div id="menu_left_vidrio" onclick="mostrarMenuIzquierdo()" style="position: fixed; right: -540px; bottom: 0px; filter: alpha(opacity=0); opacity: 0.0; width: 50px;"></div>


        <div id="div_contenedor" class="contenedor">
            <div id="divVendedor" class="ClaseGeneral TopContainer">
                <div id="divVendedorLeft">
                    <div>
                    </div>
                    <div id="divPMesa"></div>
                </div>

                <div id="divWizardWrapper" class="wizardWrapper">
                    <div id="divWizzard" class="wizard-progress">
                    </div>
                    <div id="wizzardLeyenda" style="font-size: 1.3em;">Ingresa un DNI para iniciar búsqueda.</div>
                </div>
                <!-- Buscar Persona -->
                <div id="divSelTrabajo" class="ClaseGeneral" <%--style="width: 100%; height: 100%;"--%>>
                    <%--<table id="tbBuscar">
                        <tbody>
                            <tr>
                                <td onclick="return rddoc_onclick()">--%>

                                    <div id="tbBuscar" class="box-content">
                                        <div style="margin-top: 7rem;">
                                            <input style="vertical-align: bottom; display: none;" type='radio' name='rddoc' id='rddoc' value='cuit' onclick="return rddoc_onclick()" />
                                            <input style="vertical-align: bottom; display: none;" type='radio' name='rddoc' id='rddoc' value='dni' onclick="return rddoc_onclick()" checked />
                                            <input style="text-align: right;" placeholder="Ingresar DNI" type="number" name="nro_docu1" id="nro_docu1" onclick="return detectSwipe($('menu_left_mobile'), 'colapsar')" onkeydown="return btnBuscar_trabajo_onkeydown(event)">
                                            <img onclick="return consulta.cliente_buscar()" src="/precarga/image/buscar.svg" />
                                        </div>
                                        <div id="divPLimpiar">
                                        </div>
                                        <%--<div style="position: absolute; bottom: 0; top: 90%">
                                            <div id="divPBuscar" class="nextButton" />
                                        </div>--%>
                                    </div>
                            <%--    </td>
                            </tr>

                        </tbody>
                    </table>--%>
                    <div id="divTrabajos" style="width: 100%; height: 100%;">
                        <div id="divMostrarTrabajos" class="box-content"></div>
                        <div id="divBtnTrabajo" class="btn-footer">
                            <div id="divTrabajoPrev" style="min-width: 13%"></div>
                            <div id="divTrabajoNext" style="min-width: 13%"></div>
                        </div>
                    </div>
                </div>
                <div id="divSelCobro">
                    <div id="divTiposCobro" class="box-content"></div>
                    <div id="divBtnCobro" class="btn-footer">
                        <div id="divCobroPrev" style="min-width: 13%"></div>
                        <div id="divCobroNext" style="min-width: 13%" class="nextButton"></div>
                    </div>
                </div>

                <div id="divOfertaContenedor">
                    <div id="divOfertaResp" class="box-content"></div>
                    <%--REFACTORIZAR PLANES--%>
                    <div id="divPlanes" class="box-content" style="display: none">
                        <div id="divFiltros">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td style="text-align: left !important" onclick='selplan_on_click()'>
                                        <input type="checkbox" style="border: none; display: none; vertical-align: middle;" id="selplan" onclick='selplan_on_click()' />&nbsp;Seleccionar Plan</td>
                                </tr>
                            </table>
                            <table class='tb1' id="tbfiltros" style="border-collapse: collapse; border: none; display: none">
                                <tr>
                                    <td>
                                        <div id="divFiltrosLeft">
                                            <table class='tb1'>
                                                <tr>
                                                    <td class='Tit1' style="width: 50%"></td>
                                                    <td class='Tit1' style="width: 25%">Desde</td>
                                                    <td class='Tit1' style="width: 25%">Hasta</td>
                                                </tr>
                                                <tr>
                                                    <td>Importe Retirado</td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('retirado_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('retirado_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divFiltrosRight">
                                            <table class='tb1'>
                                                <tr>
                                                    <td class='Tit1' style="width: 50%"></td>
                                                    <td class='Tit1' style="width: 25%">Desde</td>
                                                    <td class='Tit1' style="width: 25%">Hasta</td>
                                                </tr>
                                                <tr>
                                                    <td>Importe Cuota</td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('importe_cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('importe_cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divFiltros2Left">
                                            <table class='tb1'>
                                                <tr>
                                                    <td class='Tit1' style="width: 50%"></td>
                                                    <td class='Tit1' style="width: 25%">Desde</td>
                                                    <td class='Tit1' style="width: 25%">Hasta</td>
                                                </tr>
                                                <tr>
                                                    <td>Cuotas</td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('cuota_desde', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                    <td>
                                                        <script type="text/javascript">campos_defs.add('cuota_hasta', { enDB: false, nro_campo_tipo: 102 })</script>
                                                    </td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div id="divFiltros2Right">
                                        </div>
                                        <div id="divFiltros3Left">
                                            <table class='tb1'>
                                                <tr>
                                                    <td class="Tit1" style="width: 50%"></td>
                                                </tr>
                                                <tr>
                                                    <td style="width: 50%">
                                                        <input type="checkbox" style="border: none" id="chkmax_disp" name="chkmax_disp" />
                                                        Importe máx. disp.</td>
                                                </tr>
                                            </table>
                                        </div>
                                        <div style="width: 100%;" id="divFiltros3Right">
                                            <div style="display: flex; width: 100%; justify-content: center;">
                                                <div style="text-align: center; width: 25%;" id="divPlanBuscar"></div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                            <iframe style="width: 100%; height: 200px; border: none; display: none;" name="ifrplanes" id="ifrplanes" src="enBlanco.htm"></iframe>
                        </div>
                    </div>
                    <%--FIN PLANES--%>
                    <div id="divBtnOferta" class="btn-footer">
                        <div id="divOfertaLimpiar" style="min-width: 13%"></div>
                        <div id="divOfertaNext" style="min-width: 13%" class="nextButton"></div>
                    </div>
                </div>

                <div id="divCreditoAlta" style="display: none"></div>

                <div id="divFlujoViejo">
                    <div id="divDatosPersonales" style="display: none; float: left">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td style="text-align: left !important">Datos Personales</td>
                            </tr>
                        </table>
                        <div id="divDatosPersonalesLeft">
                            <table class="tb1">
                                <tr>
                                    <td class='Tit1' style="width: 60%">CUIT</td>
                                    <td class="Tit1" style="width: 40%">F.Nac.</td>
                                </tr>
                                <tr>
                                    <td><span id="strCUIT"></span></td>
                                    <td><span id="strFNac"></span></td>
                                </tr>
                            </table>
                        </div>
                        <div id="divDatosPersonalesRight">
                            <table class="tb1">
                                <tr>
                                    <td class='Tit1' style="width: 100%">Apellido y Nombres</td>
                                </tr>
                                <tr>
                                    <td><span id="strApeyNomb"></span></td>
                                </tr>
                            </table>
                        </div>
                        <div id="divInformeComercial">
                            <table class="tb1">
                                <tr>
                                    <td class='Tit1'>Informe Comercial</td>
                                </tr>
                            </table>
                            <table class="tb1">
                                <tr>
                                    <td style="width: 50%">Situación: &nbsp;&nbsp;
                    <b><span style="display: inline-block; width: 50px !important; border-radius: 4px" class="sit1" id="strSitBCRA"></span></b>
                                    </td>
                                    <td style="width: 30%"><span id="span_criterio">CDA</span> :&nbsp;&nbsp;<a href="#" style='cursor: pointer; text-decoration-style: wavy;' onclick="VerCDA()">
                                        <span style="display: inline-block; width: 100px; border-radius: 4px !important" class="cdaAC" id="strDictamen"></span></a>
                                        <span id="strFuentes"></span>
                                    </td>
                                    <td style="width: 20%">
                                        <div id="divNoti"></div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div id="divGrupo" style="display: none; float: left">
                        <div id="divGrupoLeft">
                            <table class='tb1'>
                                <tr>
                                    <td class='Tit1'>Trabajo</td>
                                </tr>
                                <tr>
                                    <td><span id="strGrupo"></span></td>
                                </tr>
                            </table>
                        </div>
                        <div id="divGrupoRight">
                            <table class='tb1'>
                                <tr>
                                    <td class='Tit1' style="width: 100%">Cobro</td>
                                </tr>
                                <tr>
                                    <td><span id="strCobro"></span></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div id="divSocio" style="display: none; float: left">
                        <div id="divSocioLeft">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td style="text-align: left !important">Socio</td>
                                </tr>
                            </table>
                            <table class='tb1'>
                                <tr>
                                    <td style="width: 100%; vertical-align: top" colspan="2">
                                        <div id="tbCuotaSocial" style="vertical-align: top; width: 100%"></div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="divSocioRight">
                            <table class="tb1" id="tbCreditos">
                                <tr class="tbLabel">
                                    <td style="text-align: left !important; display: flex; justify-content: space-around; align-items: center;">
                                        <p id="titulo_cancelacion" style="cursor: pointer; padding: 0 15px;">Pagos mora interna y cancelaciones</p>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div id="divProducto" style="display: none; float: left">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td style="text-align: left !important">Producto</td>
                            </tr>
                        </table>
                        <div id="divOferta">
                            <table class='tb1'>
                                <tr>
                                    <td class='Tit1' style="width: 10%">Oferta:</td>
                                    <td>
                                        <script type="text/javascript">
                                            campos_defs.add('cdef_oferta', {
                                                enDB: false,
                                                nro_campo_tipo: 1,
                                                sin_seleccion: false,
                                                mostrar_codigo: false
                                            });
                                        </script>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="divProductoLeft" style="display: none">
                            <table class='tb1'>
                                <tr>
                                    <td class='Tit1' style="width: 10%; display: none">Banco:</td>
                                    <td style="width: 36%; display: none">
                                        <script type="text/javascript">
                                            campos_defs.add('banco', {
                                                enDB: false,
                                                nro_campo_tipo: 1,
                                                sin_seleccion: false
                                            });
                                        </script>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div id="divProductoRight" style="display: none">
                            <table class='tb1'>
                                <tr>
                                    <td class='Tit1' style="width: 10%">Mutual:</td>
                                    <td style="width: 36%">
                                        <script type="text/javascript">campos_defs.add('mutual', { enDB: false, nro_campo_tipo: 1 })</script>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <div id="divAnalisis" style="display: none; float: left">
                        <table class='tb1'>
                            <tr>
                                <td class='Tit1' style="width: 10%; display: none">Analisis:</td>
                                <td style="width: 36%; display: none">
                                    <script type="text/javascript">campos_defs.add('cbAnalisis', { enDB: false, nro_campo_tipo: 1 })</script>
                            </tr>
                        </table>
                        <div id="divHaberesNoVisibles" style='display: none'></div>
                        <table style="width: 100%" id="haberes" cellspacing="0" cellpadding="0">
                            <tr style="text-align: center; font-size: 12px; font-weight: bolder; color: white; background-color: dimgray;"></tr>
                        </table>
                        <div id="divHaberes"></div>
                        <div id="divTotalesLeft">
                            <table class="tb1" style="width: 100%">
                                <tr>
                                    <td style='width: 27%; text-align: right;'
                                        class="Tit1"><b>&nbsp;Saldo a cancelar:&nbsp;</b></td>
                                    <td style='width: 25%; text-align: right'><b><span id="saldo_a_cancelar">$ 0.00</span></b></td>
                                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;Haber neto:&nbsp;</b></td>
                                    <td style='text-align: right'><b><span id="haber_neto">$ 0.00</span></b></td>
                                </tr>
                            </table>
                        </div>
                        <div id="divTotalesRight">
                            <table class="tb1" style="width: 100%">
                                <tr>
                                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;Cuota máxima:&nbsp;</b></td>
                                    <td style='width: 25%; text-align: right'><b><span id="importe_max_cuota">$ 0.00</span></b></td>
                                    <td style='width: 25%; text-align: right' class="Tit1"><b>&nbsp;En mano:&nbsp;</b></td>
                                    <td style='width: 25%; text-align: right'><b><span id="strEnMano">$ 0.00</span></b></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <table style="width: 98%; display: none; position: fixed; bottom: 0px; float: left; background-color: grey; border-radius: 140px;"
                        id="tbButtons">
                        <tr>
                            <td style="width: 33%">
                                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important;">
                                    <tr>
                                        <td class="btnBegin_O"></td>
                                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('P')" id="btn1" style="border-radius: 70px">
                                            <img src="image/save.ico" class="img_button" border="0" align="absmiddle" hspace="1" id="img1">&nbsp;Pendiente
                                        </td>
                                        <td class="btnEnd_O"></td>
                                    </tr>
                                </table>
                            </td>
                            <td style="width: 33%">
                                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important;">
                                    <tr>
                                        <td class="btnBegin_O"></td>
                                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="GuardarSolicitud('H')" id="btn2" style="border-radius: 70px">
                                            <img src="image/ok.ico" class="img_button" border="0" alt="" align="absmiddle" hspace="1" id="img2">&nbsp;Precarga
                                        </td>
                                        <td class="btnEnd_O"></td>
                                    </tr>
                                </table>
                            </td>
                            <td style="text-align: center">
                                <table class="btnTB_O" cellspacing="0" border="0" cellpadding="0" style="border-radius: 55px !important;">
                                    <tr>
                                        <td class="btnBegin_O"></td>
                                        <td class="btnNormal_O" onmouseover="btnMO(event)" onmouseout="btnMU(event)" onclick="this.disabled=true; Precarga_Limpiar()" id="btn3" style="border-radius: 70px">
                                            <img src="image/blank.ico" class="img_button" border="0" align="absmiddle" hspace="1" id="img3">&nbsp;Limpiar
                                        </td>
                                        <td class="btnEnd_O"></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                    <div id="divEspacioBotonera" style="height: 50px; float: left; width: 100%;"></div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
