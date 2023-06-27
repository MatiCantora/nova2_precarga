 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 
    'euge.aspx?nombre=guillermo
    Dim tipdoc As String = 8  'nvFW.nvUtiles.obtenerValor("tipdoc", "")
    Dim nrodoc As String = 20041716879 'nvFW.nvUtiles.obtenerValor("nrodoc", "")


    Dim eventKey As Boolean = nvFW.nvUtiles.obtenerValor("eventKey", False)

    Me.contents("fprestamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select top = '20' vista='VOII_prestamos'   cn='BD_IBS_ANEXA'><campos>cuecod, cancuocap, fecori, impneto, importpact, estoperdesc, Fecha_de_pago, mondesc, nroreferencia, openro, prodnom</campos><orden/><filtro> <nrodoc type='igual'> " + nrodoc + " </nrodoc>  <tipdoc type='igual'> " + tipdoc + " </tipdoc></filtro></select ></criterio>")

    Me.addPermisoGrupo("permisos_solicitudes")

    ' Diccionario para pedirle a la Page del VOII que cargue los permisos; SOLO CARGAR EN DEFAULT.ASPX
    Dim dicInit As New Dictionary(Of String, Boolean)
    dicInit.Add("permisos", True)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>NOVA VOII</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link rel="icon" type="image/png" href="/fw/image/icons/nv_voii.png"/>

     
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <% = Me.getHeadInit(dicInit) %>

   
     <script type="text/javascript">




         function buscar() {

             var filtro = "";

             filtro += campos_defs.filtroWhere('estopercodes');
             
             filtro += campos_defs.filtroWhere("moncodes");

             if (campos_defs.get_value('openro') != "") {
                 filtro += "<openro type='igual'>" + campos_defs.get_value('openro') + "</openro>";
             } 

             nvFW.exportarReporte({
                 filtroXML: nvFW.pageContents.fprestamos,
                 filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                 path_xsl: "/report/operaciones/prestamos.xsl",
                 salida_tipo: 'adjunto',
                 ContentType: 'text/html',
                 formTarget: 'frame',
                 nvFW_mantener_origen: true,
                 bloq_contenedor: $$('body')[0],
                 bloq_msg: 'Buscando...',
                 cls_contenedor: 'frame'

             });

         }

         function exportar_reporte() {

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.fprestamos,
                path_xsl: "/report/operaciones/prestamos.xsl",
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frame',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando...',
                cls_contenedor: 'frame'

            });

         }


         var verFiltros = true
         function mostrar_filtros() {
             window_onresize()
             if (verFiltros) {
                 $('img_filtros_mostrar').src = '/FW/image/icons/mas.gif';
                 $('tbFiltros').hide();
                 verFiltros = false;
             } else {
                 $('img_filtros_mostrar').src = '/FW/image/icons/menos.gif';
                 $('tbFiltros').show();
                 verFiltros = true;
             }

         }

         var vButtonItems = {}

         vButtonItems[0] = {}
         vButtonItems[0]["nombre"] = "Buscar";
         vButtonItems[0]["etiqueta"] = "Buscar";
         vButtonItems[0]["imagen"] = "buscar";
         vButtonItems[0]["onclick"] = "return buscar()";

         var vListButton = new tListButton(vButtonItems, 'vListButton');
         vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');


         function window_onresize() {

             if (!verFiltros) {
                 //h de iframe = h de body - h menu - h de tdfiltros
                 $("frame").setStyle({ height: $$("body")[0].getHeight() - $("vMenuPrincipal").getHeight() - $("tbFiltros").getHeight() + "px" })

             }
             else {
                 $("frame").setStyle({ height: $$("body")[0].getHeight() - $("vMenuPrincipal").getHeight() + "px" })

                 //h de iframe = h de body - h menu
             }
         }


         function window_onload() {
             vListButton.MostrarListButton();
             window_onresize()
             exportar_reporte()

         }
     </script>
     
</head> 
    
    
<body  style='width: 100%; height: 100%; overflow: hidden;' onload="window_onload()"  >

    <input type="hidden" id="nro_com_grupo" value="5" />
    <input type="hidden" id="nro_entidad" value="" />
    <div id="divMenuPrincipal"></div>
    <script>
        vMenuPrincipal = new tMenu('divMenuPrincipal', 'vMenuPrincipal');
        Menus["vMenuPrincipal"] = vMenuPrincipal;
        Menus["vMenuPrincipal"].alineacion = 'centro';
        Menus["vMenuPrincipal"].estilo = 'A';

        Menus["vMenuPrincipal"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>");

        vMenuPrincipal.MostrarMenu();
        $('menuItem_divMenuPrincipal_0').innerHTML = "<img onclick='return mostrar_filtros()' name='img_filtros_mostrar' id='img_filtros_mostrar' style='cursor: pointer; vertical-align: middle' src='/FW/image/icons/mas.gif' />&nbsp;Filtros"
    </script>
    <table id="tbFiltros" class="tb1" style="display: none">
       <tr>
         <td>
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="text-align: center">Nro.</td>
                    <td style="text-align: center">Moneda</td>
                    <td style="text-align: center" >Estado</td>
                </tr>
                <tr>
                    <td>
                        <script>
                            campos_defs.add("openro", {
                                enDB: false,
                                nro_campo_tipo: 100
                            })
                        </script>
                   </td>
                    <td>
                        <script>
                            campos_defs.add("moncodes")
                        </script>
                    </td>
                    <td>
                        <script>
                            campos_defs.add("estopercodes")
                        </script>
                    </td>
               </tr> 
            </table>
         </td>
         <td>
            <table class="tb1">
               <tr>
                   <td>&nbsp;</td>
               </tr>
               <tr>
                    <td style="vertical-align: middle">
                        <div id="divBuscar" style="width: 100%"></div>
                    </td>
               </tr>     
            </table>
         </td>
       </tr>
    </table>

     <iframe style="width: 100%; height: 100%; border: none" id="frame" name="frame"></iframe>
</body>
</html>
