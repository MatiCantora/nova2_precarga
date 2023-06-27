 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<% 

    Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", "")
    Dim nrodoc As String = nvFW.nvUtiles.obtenerValor("nrodoc", "")
    Dim cuecod As String = nvFW.nvUtiles.obtenerValor("cuecod", "")


    Dim eventKey As Boolean = nvFW.nvUtiles.obtenerValor("eventKey", False)

    Me.contents("nrodoc") = nrodoc
    Me.contents("tipdoc") = tipdoc
    Me.contents("cuecod") = cuecod
    Me.contents("fPF") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_PF' cn='BD_IBS_ANEXA'><campos>*</campos><orden/><filtro><nrodoc type='igual'> " + nrodoc + " </nrodoc><tipdoc type='igual'> " + tipdoc + " </tipdoc><cuecod type='igual'> " + cuecod + " </cuecod></filtro></select></criterio>")
    Me.contents("filtroProducto") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banksys..tgl_Producto' cn='BD_IBS_ANEXA'><campos>prodnom as id, prodnom as campo</campos><orden/><filtro></filtro></select></criterio>")

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
             
             var filtroWhere = campos_defs.filtroWhere()

             nvFW.exportarReporte({
                 filtroXML: nvFW.pageContents.fPF,
                 filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                 path_xsl: "/report/operaciones/PF.xsl",
                 salida_tipo: 'adjunto',
                 ContentType: 'text/html',
                 formTarget: 'frame',
                 nvFW_mantener_origen: true,
                 bloq_contenedor: $$('body')[0],
                 bloq_msg: 'Buscando...',
                 cls_contenedor: 'frame'

             });

             window_onresize()
              
         } 
        

         var verFiltros = false
         function mostrar_filtros() {

             if (verFiltros == true) {
                 $('img_filtros_mostrar').src = '/FW/image/icons/mas.gif';
                 $('tbFiltros').hide();
                 verFiltros = false;
             } else {
                 $('img_filtros_mostrar').src = '/FW/image/icons/menos.gif';
                 $('tbFiltros').show();
                 verFiltros = true;
             }
             window_onresize()
         }


         
         


         function window_onresize() {
             
             if (verFiltros == true) {                 
                 $("frame").setStyle({ height: $$("body")[0].getHeight() - $("vMenuPrincipal").getHeight() - $("tbFiltros").getHeight() + "px" })
             }
             else {
                 $("frame").setStyle({ height: $$("body")[0].getHeight() - $("vMenuPrincipal").getHeight()  + "px" })
             }
         }


         function window_onload() { 
             //vListButton.MostrarListButton();
             buscar()
             window_onresize()             
         }

     </script>
     
</head> 

<body  style='width: 100%; height: 100%; overflow: hidden;' onload="window_onload()"  >

   <%-- <script type="text/javascript">

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

    </script>--%>

    <input type="hidden" id="nro_com_grupo" value="5" />
    <input type="hidden" id="nro_entidad" value="" />
    <div id="divMenuPrincipal"></div>
    <script type="text/javascript">
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
                    <td style="text-align: center">Nro. operación</td>
                    <td style="text-align: center">Producto</td>                    
                    <td style="text-align: center">Plazo</td>
                    <td style="text-align: center">Fecha CreaciÓn</td>
                    <td style="text-align: center">Fecha Vencimiento</td>
                </tr>
                <tr>
                    
                    <td>
                        <script type="text/javascript">
                            campos_defs.add("openro", {
                                enDB: false,
                                nro_campo_tipo: 100,
                                filtroWhere: "<openro type='igual'>%campo_value%</openro>",
                                onchange: buscar
                            })
                        </script>
                    </td>
                    <td>
                        <script type="text/javascript">
                            campos_defs.add("prodnom", {
                                enDB: false,
                                nro_campo_tipo: 3,
                                filtroXML: nvFW.pageContents.filtroProducto,
                                filtroWhere: "<prodnom type='igual'>%campo_value%</prodnom>",                                
                                campo_desc: 'prodnom',
                                campo_codigo: 'prodnom',
                                mostrar_codigo: false,
                                onchange: buscar

                            })
                        </script>
                    </td>
                    <td>
                        <script type="text/javascript">
                            campos_defs.add("plazoop", {
                                enDB: false,
                                nro_campo_tipo: 100,
                                filtroWhere: "<openro type='igual'>%campo_value%</openro>",
                                onchange: buscar
                            })
                        </script>
                    </td>
                    <td>
                        <script type="text/javascript">
                            campos_defs.add("fecori", {
                                enDB: false,
                                despliega: 'abajo',
                                nro_campo_tipo: 103,
                                filtroWhere: "<fecori type='igual'>%campo_value%</fecori>",
                                onchange: buscar
                            })
                        </script>
                    </td> 
                    <td>
                        <script type="text/javascript">
                            campos_defs.add("fecven", {
                                enDB: false,
                                nro_campo_tipo: 103,
                                filtroWhere: "<fecven type='igual'>%campo_value%</fecven>",
                                onchange: buscar
                            })
                        </script>
                    </td>
                </tr> 
             </table>
          </td>

         <%-- <td>
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
          </td>--%>
        </tr>
    </table>

     <iframe style="width: 100%; height: 100%; border: none" id="frame" name="frame"></iframe>
</body>
</html>
