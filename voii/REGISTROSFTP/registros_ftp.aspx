 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Dim op = nvFW.nvApp.getInstance.operador
    If Not op.tienePermiso("permisos_herramientas", 9) Then
        Response.Redirect("/FW/error/httpError_401.aspx")
    End If



    Me.contents("filtro_consulta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ftp_log'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")



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

        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar_consulta()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
         vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');

         

         function buscar_consulta() {


             var filtro = "";

             var filtroXML = nvFW.pageContents.filtro_consulta

             if (campos_defs.get_value('nro_proceso') != "")
                 filtro += "<nro_proceso type='igual'>" + campos_defs.get_value('nro_proceso') + "</nro_proceso>";


            if (campos_defs.get_value('fecha_desde') != "") {
                filtro += "<fecha type='mas'>convert(datetime, '" + campos_defs.get_value('fecha_desde') + "', 103)</fecha>"
             }

             if (campos_defs.get_value('fecha_hasta') != "") {
                 filtro += "<fecha type='menor'>convert(datetime, '" + campos_defs.get_value('fecha_hasta') + "', 103)</fecha>"
             }


             if (campos_defs.get_value('archivo') != "") {
                 filtro += "<archivo type='like'>%" + campos_defs.get_value('archivo') + "%</archivo>";
             }
             if (campos_defs.get_value('destino') != "") {
                 filtro += "<destino type='like'>%" + campos_defs.get_value('destino') + "%</destino>";
                 
             }

             if ($('consulta_estado').value == 'E') {
                 filtro += "<not><fe_enviado type='isNull'></fe_enviado></not>";
             }

             if ($('consulta_estado').value == 'N') {
                 filtro += "<fe_enviado type='isNull'></fe_enviado>";
             }

             var cantFilas = Math.floor(($("frameDatos").getHeight() - 18 * 2) / 19);

                 nvFW.exportarReporte({
                     filtroXML: filtroXML,
                     filtroWhere: "<criterio><select PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                     path_xsl: "/report/registrosftp/registros_ftp_plantilla.xsl",
                     salida_tipo: 'adjunto',
                     ContentType: 'text/html',
                     formTarget: 'frameDatos',
                     nvFW_mantener_origen: true,
                     bloq_contenedor: $$('body')[0],
                     bloq_msg: 'Buscando...',
                     cls_contenedor: 'frameDatos',
                     id_exp_origen: 0
                 });
                          
         }
             
     
        function window_onload() {
             vListButton.MostrarListButton();  
             window_onresize();
             
         }

         function window_onresize() {
             var dif = Prototype.Browser.IE ? 5 : 2;

             $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divCabecera').getHeight() - dif - 7 + 'px' });
              

             ancho = $('frameDatos').getWidth()
             alto = $('frameDatos').getHeight()

         }

         function btnExportar() {
             var filtro = "<criterio><select><filtro>" + campos_defs.filtroWhere() + "</filtro></select></criterio>";

             nvFW.exportarReporte({
                 filtroXML: nvFW.pageContents.filtro_consulta,
                 filtroWhere: filtro,
                 path_xsl: "report\\EXCEL_base.xsl",
                 salida_tipo: "adjunto",
                 ContentType: "application/vnd.ms-excel",
                 filename: "registros_ftp.xls"
             });
         }

     </script>
     
</head> 
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;' onkeypress="return key_Buscar()">
   
    
    <div id="divCabecera" style="width: 100%">
        <table id="tbFiltros" class="tb1" style="width: 100%">
            <tr>
                <td colspan="2">
                    <div id="divMenu" style="width: 100%"></div>
                </td> 
                <script type="text/javascript">

                    var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

                    Menus["vMenuModulos"] = vMenuModulos
                    Menus["vMenuModulos"].alineacion = 'center';

                    Menus["vMenuModulos"].estilo = 'A';
                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 900%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")

                    vMenuModulos.loadImage("excel", '/FW/image/icons/excel.png');

                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnExportar()</Codigo></Ejecutar></Acciones></MenuItem>")
                    vMenuModulos.MostrarMenu()

                </script>
            </tr>
             <tr>
                <td style="width: 90%">
                    <table class="tb1" style="width: 100%">
                            

                        <tr class="tbLabel">

                            <td style="text-align: center; width: 10%" >Nro. Proceso</td>
                            <td style="text-align: center; width: 30%"  >Archivo</td> 
                            <td style="text-align: center; width: 30%">Destino</td>
                            <td style="text-align: center; width: 10%"  >Estado</td>
                             <td style="text-align: center; width: 10%"  >Fecha Desde</td>
                            <td style="text-align: center; width: 10%"  >Fecha Hasta</td>
                        </tr>
                        <tr>
                            <td id="tdnroproceso">
                                <script>
                                    campos_defs.add('nro_proceso', { enDB: false, nro_campo_tipo: 100 });
                                </script>
                            </td>
                            

                             <td id="tdarchivo">
                                <script>
                                    campos_defs.add('archivo', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                            
                            <td id="tddestino">
                                <script>
                                    campos_defs.add('destino', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                            <td id="tdestado">
                                
                                    <select style='width:100%' id='consulta_estado'>
                                        <option value=''></option>
                                        <option value='E'>Enviado</option>
                                        <option value='N'> No Enviado</option>
                                    </select>
                                
                            </td>

                            <td id="tdfechaD">
                                <script>
                                    campos_defs.add('fecha_desde', { nro_campo_tipo: 103 });
                                </script>
                            </td>

                               <td id="tdfechaH">
                                <script>
                                    campos_defs.add('fecha_hasta', { nro_campo_tipo: 103 });
                                </script>
                            </td>
                        </tr>
                        
                    </table>  
                </td>
                <td>
                     <table class="tb1"> 
                            <tr>
                                <td colspan="2" style="vertical-align: middle">
                                    <div id="divBuscar" style="width: 100%"></div>
                                </td>
                            </tr>
                            
                    </table>
                </td> 
            </tr>
            <%--HTML en ventana cliente--%>
             
        </table>
    </div>
    <iframe style="width: 100%; border: none" id="frameDatos" name="frameDatos"></iframe>
</body>
</html>
