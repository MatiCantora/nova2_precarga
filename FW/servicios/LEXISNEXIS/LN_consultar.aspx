 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Dim op = nvFW.nvApp.getInstance.operador
    If Not op.tienePermiso("permisos_herramientas", 9) Then
        Response.Redirect("/FW/error/httpError_401.aspx")
    End If

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")

    'Err.mensaje
    'Err.debug_desc
    'Err.debug_src
    'Err.titulo
    'Err.numError = 0

    If accion.ToUpper() = "GUARDAR" Then
        If Not op.tienePermiso("permisos_lexisnexis", 1) Then
            Response.Redirect("/FW/error/httpError_401.aspx")
        End If

        Dim err As New tError()
        Try

            Dim nro_consulta As String = nvFW.nvUtiles.obtenerValor("nro_consulta", "")

            nvFW.nvDBUtiles.DBExecute("update LN_consultas set vigente = 0 where nro_consulta =  " & nro_consulta & "  And vigente = 1 ")


        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try

        err.response()

    End If


    Dim eventKey As Boolean = nvFW.nvUtiles.obtenerValor("eventKey", False)

    Me.contents("filtro_resultado_enc") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos> [file],ReasonListed, AlertState,ResultID,ResultDesc,nro_consulta,tipo_docu,documento,nro_docu,apellido,nombres,sexo,pais,division,PredefinedSearchName,[user],fe_consulta,fe_vigente,vigente,fe_naci,Comments,AdditionalInfo, BestName, BestNameScore</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_resultado_busqueda") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos>distinct nro_consulta,tipo_docu,documento,nro_docu,apellido,nombres,sexo,pais,division,PredefinedSearchName,[user],fe_consulta,fe_vigente,vigente,fe_naci,ResultID,ResultDesc</campos><orden>fe_consulta</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_resultado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos> [file],ReasonListed,AlertState,ResultID,ResultDesc,nro_consulta,tipo_docu,documento,nro_docu,apellido,nombres,sexo,pais,division,PredefinedSearchName,[user],fe_consulta,fe_vigente,vigente,fe_naci,Comments,AdditionalInfo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_resultado_descarga") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos>ReasonListed, Comments,AdditionalInfo,[file],Name,BestName,Published,BestNameScore,AlertState,ResultID,ResultDesc,Comments,AdditionalInfo,nro_consulta,tipo_docu,documento,nro_docu,apellido,nombres,sexo,pais,division,PredefinedSearchName,[user],fe_consulta,fe_vigente,vigente,fe_naci</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("otraVentana") = eventKey


    Me.addPermisoGrupo("permisos_lexisnexis")

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
        vButtonItems[0]["onclick"] = "return buscador()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("buscar", '/FW/image/icons/buscar.png');
        vListButton.loadImage("excel", '/FW/image/icons/excel.png');
        vListButton.loadImage("imprimir", '/FW/image/icons/imprimir.png');



        var ventana = nvFW.getMyWindow();
        var solVentana;
        var solVentanas = new Map;

        var porcentajeHeight;
        var porcentajeWidth;

        var otraVentana;

         function getFiltroResult() {
             return nvFW.pageContents.filtro_resultado_enc
         }
          

         function buscador() {

             if (campos_defs.get_value('tipo_busqueda') == '1') {
                 buscar_resultado()
                 return
             }  
             if (campos_defs.get_value('tipo_busqueda') == '0')  
                 buscar_consulta(0)   
             else
                 alert("El tipo de busqueda es obligatorio.") 
                 
         }


         function buscar_resultado() { 
              
            var filtro = "";

            if (campos_defs.get_value('ReasonListed') != "")
                filtro += "<ReasonListed type='like'>%" + campos_defs.get_value('ReasonListed') + "%</ReasonListed>";

            if (campos_defs.get_value('AdditionalInfo') != "") {
                filtro += "<AdditionalInfo type='like'>%" + campos_defs.get_value('AdditionalInfo') + "%</AdditionalInfo>";
            }
            if (campos_defs.get_value('Comments') != "") {
                var filtroAux = "<Comments type='like'>%" +  + campos_defs.get_value('Comments') +"%</Comments>";
                filtro += filtroAux.replace(/, /g, "', '");
            }
            if (campos_defs.get_value('Published_desde') != "")
                 filtro += "<Published type='mas'>convert(datetime, '" + campos_defs.get_value('Published_desde') + "', 103)</Published>";

            if (campos_defs.get_value('Published_hasta') != "")
                 filtro += "<Published type='menor'>convert(datetime, '" + campos_defs.get_value('Published_hasta') + "', 103)</Published>";
               
            if (campos_defs.get_value('nro_consulta') != "")
                filtro += "<nro_consulta type='igual'>" + campos_defs.get_value('nro_consulta') + "</nro_consulta>";

            if (campos_defs.get_value('tipo_docu') != "") 
                filtro += "<tipo_docu type='igual'>" + campos_defs.get_value('tipo_docu') + "</tipo_docu>";
            
            if (campos_defs.get_value('nro_doc') != "") 
                filtro += "<nro_docu type='in'>'" + campos_defs.get_value('nro_doc') + "'</nro_docu>";
               
            if (campos_defs.get_value('ape') != "") 
                filtro += "<apellido type='like'>%" + campos_defs.get_value('ape') + "%</apellido>";
            
            if (campos_defs.get_value('nom') != "") 
                filtro += "<nombres type='like'>%" + campos_defs.get_value('nom') + "%</nombres>";
                
            if (campos_defs.get_value('vigente') != "") 
                filtro +=  "<vigente type='igual'>'" + campos_defs.get_value('vigente') + "'</vigente>";
                
            if (campos_defs.get_value('sexo') != "") 
                filtro +=  "<sexo type='igual'>" + campos_defs.get_value('sexo') + "</sexo>";

            if (campos_defs.get_value('user') != "") 
                filtro +=  "<user  type='sql'>[user] like  '%" + campos_defs.get_value('user') + "%'</user>";
             
            if (campos_defs.get_value('fe_desde') != "")
                filtro += "<fe_consulta type='mas'>convert(datetime, '" + campos_defs.get_value('fe_desde') + "', 103)</fe_consulta>";

             if (campos_defs.get_value('fe_hasta') != "")
                filtro += "<fe_consulta type='menor'>convert(datetime, '" + campos_defs.get_value('fe_hasta') + "', 103)</fe_consulta>";

            var cantFilas = Math.floor(($("frameDatos").getHeight() - 22) / 21); 
            
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_resultado_busqueda,
                filtroWhere: "<criterio><select  PageSize = '" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "/report/lexisnexis/LN_consultar_plantilla_resultados.xsl",
                salida_tipo: 'adjunto',
                ContentType: 'text/html',
                formTarget: 'frameDatos',
                nvFW_mantener_origen: true,
                bloq_contenedor: $$('body')[0],
                bloq_msg: 'Buscando...',
                cls_contenedor: 'frameDatos'

            }); 
        }

         function buscar_consulta(bandera) {
               
             var filtro = "";

             if (campos_defs.get_value('nro_consulta') != "")
                 filtro += "<nro_consulta type='igual'>" + campos_defs.get_value('nro_consulta') + "</nro_consulta>";

             if (campos_defs.get_value('tipo_docu') != "") {
                 filtro += "<tipo_docu type='igual'>" + campos_defs.get_value('tipo_docu') + "</tipo_docu>";
             }
             if (campos_defs.get_value('nro_doc') != "") {
                 var filtroAux = "<nro_docu type='in'>'" + campos_defs.get_value('nro_doc') + "'</nro_docu>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('ape') != "") {
                 var filtroAux = "<apellido type='like'>%" + campos_defs.get_value('ape') + "%</apellido>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('nom') != "") {
                 var filtroAux = "<nombres type='like'>%" + campos_defs.get_value('nom') + "%</nombres>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('vigente') != "") {
                 var filtroAux = "<vigente type='igual'>'" + campos_defs.get_value('vigente') + "'</vigente>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('sexo') != "") {
                 var filtroAux = "<sexo type='igual'>" + campos_defs.get_value('sexo') + "</sexo>";
                 filtro += filtroAux.replace(/, /g, "', '");
             } 
             if (campos_defs.get_value('user') != "") {
                 var filtroAux = "<user  type='sql'>[user] like  '%" + campos_defs.get_value('user') + "%'</user>";
                 filtro += filtroAux.replace(/, /g, "', '");
              }
             //consulta periodo
             if (campos_defs.get_value('fe_desde') != "")
                 filtro += "<fe_consulta type='mas'>convert(datetime, '" + campos_defs.get_value('fe_desde') + "', 103)</fe_consulta>";
             if (campos_defs.get_value('fe_hasta') != "")
                 filtro += "<fe_consulta type='menor'>convert(datetime, '" + campos_defs.get_value('fe_hasta') + "', 103)</fe_consulta>";

             var cantFilas = Math.floor(($("frameDatos").getHeight() - 22) / 21);
             if (bandera == 0) {

                 nvFW.exportarReporte({
                     filtroXML: nvFW.pageContents.filtro_resultado_busqueda,
                     filtroWhere: "<criterio><select  PageSize = '" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>",
                     path_xsl: "/report/lexisnexis/LN_consultar_plantilla.xsl",
                     salida_tipo: 'adjunto',
                     ContentType: 'text/html',
                     formTarget: 'frameDatos',
                     nvFW_mantener_origen: true,
                     bloq_contenedor: $$('body')[0],
                     bloq_msg: 'Buscando...',
                     cls_contenedor: 'frameDatos'

                 });

             }
             else {
                 var nombre = ""
                 var strHTML = "<br/><table class='tb1'><tr><td nowrap>Exportar el listado con el siguiente nombre: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><input type='text' id='filename' value='" + nombre + "' style='width:100%;text-align:right' /></td></tr></table>"
                 nvFW.confirm(strHTML,
                     {
                         title: "Exportar",
                         onShow: function (win) {
                             $("filename").focus()
                         },
                         onOk: function (win) {
                             nombre = $("filename").value

                             win.close()
                              
                             nvFW.exportarReporte({
                                 filtroXML: nvFW.pageContents.filtro_resultado_busqueda,
                                 filtroWhere: "<criterio><select ><filtro>" + filtro + "</filtro></select></criterio>",
                                 path_xsl: "/report/lexisnexis/LN_consultar_plantilla.xsl",
                                 salida_tipo: 'adjunto',
                                 ContentType: "application/vnd.ms-excel",
                                 filename: nombre + ".xls"
                             });
                         }
                     })


             }
              
         }
          
         function descargar_consulta(nroconsulta, resultID) {

             var filtro_descarga = "<nro_consulta type='igual'>" + nroconsulta + "</nro_consulta>"; 
 
             var path_reporte = "/report/lexisnexis/nconsulta/LN_resultado.rpt"

              nvFW.mostrarReporte({
                  filtroXML: nvFW.pageContents.filtro_resultado_descarga,
                     filtroWhere: "<criterio><select><filtro>" + filtro_descarga + "</filtro></select></criterio>",
                     path_reporte: path_reporte,
               //      path_xsl: "/report/lexisnexis/LN_consultar_plantilla.xsl",
                 //    salida_tipo: "crystal",
                  formTarget: "_blank",
                  ContentType : "application/pdf",
                  file_name: "Informe de consulta Lexis Nexis N°" + nroconsulta

                 })
         } 
          
        function key_Buscar() {
            if (window.event.keyCode == 13)
                buscador();
         }

         var ancho = 0
         var alto = 0

          
         function onchange_busqueda() { 
             if (campos_defs.get_value('tipo_busqueda') == 1) {
                campos_defs.habilitar('ReasonListed', true)
                campos_defs.habilitar('AdditionalInfo', true)
                campos_defs.habilitar('Comments', true)
                campos_defs.habilitar('Published_desde', true)
                campos_defs.habilitar('Published_hasta', true)
            } else {
                campos_defs.habilitar('ReasonListed', false)
                campos_defs.habilitar('AdditionalInfo', false)
                campos_defs.habilitar('Comments', false)
                campos_defs.habilitar('Published_desde', false)
                campos_defs.habilitar('Published_hasta', false)
             }
         }
        function window_onload() {
             vListButton.MostrarListButton();  
             otraVentana = nvFW.pageContents.otraVentana;
            window_onresize();
            campos_defs.set_value('tipo_busqueda', 0) 
            var d = new Date();
            campos_defs.set_value('fe_desde', d.toLocaleDateString()) 

            campos_defs.habilitar('ReasonListed', false) 
            campos_defs.habilitar('AdditionalInfo', false) 
            campos_defs.habilitar('Comments', false) 
            campos_defs.habilitar('Published_desde', false) 
            campos_defs.habilitar('Published_hasta', false) 
         } 

         function window_onresize() {
             var dif = Prototype.Browser.IE ? 5 : 2;
             $('frameDatos').setStyle({ height: $$('body')[0].getHeight() - $('divCabecera').getHeight() - dif - 7 + 'px' });
             ancho = $('frameDatos').getWidth()
             alto = $('frameDatos').getHeight()
         }


         function nueva_consuta(nombres, apellidos, tipodoc, documento, sexo, pais, fechanac, division, vigencia, esreconsulta, nroconsulta, lista_tipobusqueda, ResultID) {
             var titulo = "" 
             if (esreconsulta == 'True')
                 titulo = "<b>Consulta nro. " + nroconsulta + "</b>"
             else
                 titulo = "<b>Nueva Consulta</b>" 


             var win = nvFW.createWindow({
                 url: "/FW/servicios/LEXISNEXIS/LN_nueva_consulta.aspx?nombres=" + nombres + "&apellidos=" + apellidos + "&tipodoc=" + tipodoc + "&documento=" + documento + "&sexo=" + sexo + "&pais=" + pais + "&fechanac=" + fechanac + "&division=" + division + "&vigencia=" + vigencia + "&esreconsulta=" + esreconsulta + "&lista_tipobusqueda=" + lista_tipobusqueda + "&nro_consulta=" + nroconsulta + "&ResultID=" + ResultID ,
                 title: titulo,

                 resizable: true,
                 maximizable: false,
                 minimizable: false,

                 height: "310px",

                 width: "500px",

                 onShow: function (win) {

                 },

                 onClose: function (win) {
                 }

             })

             win.showCenter(true)


            
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
                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 900%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Consultas LexisNexis</Desc></MenuItem>")

                         
                    vMenuModulos.loadImage("estado", '/FW/image/icons/persona_mas.png')
                    vMenuModulos.loadImage("excel", '/fw/image/filetype/xlsx.png')

                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Consultas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>buscar_consulta(1)</Codigo></Ejecutar></Acciones></MenuItem>")

                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>estado</icono><Desc>Nueva Consulta</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nueva_consuta('','','','','','','','','','False','','','')</Codigo></Ejecutar></Acciones></MenuItem>")
                   
                    vMenuModulos.MostrarMenu()
                    

                </script>
            </tr>
             <tr>
                <td style="width: 90%">
                    <table class="tb1" style="width: 100%"> 

                        <tr class="tbLabel">
                            <td style="text-align: center; width: 5%">Nro. Consulta</td>
                            <td style="text-align: center; width: 5%">Tipo Doc.</td>
                            <td style="text-align: center; width: 10%">Nro. Documento</td> 
                            <td style="text-align: center; width: 5%">Sexo</td>
                            <td style="text-align: center; width: 10%">Apellido</td>
                            <td style="text-align: center; width: 10%">Nombre</td>

                            <td style="text-align: center; width: 5%">División</td>
                            <td style="text-align: center; width: 5%">Vigencia</td>
                            
                            <td style="text-align: center; width: 10%">Periodo: Desde</td>
                            <td style="text-align: center; width: 10%">Periodo: Hasta</td>
                            <td style="text-align: center; width:5%">Usuario</td>
                        </tr>

                       <tr>
                            <td id="tdnroconsul">
                                 <script type="text/javascript">
                                    campos_defs.add('nro_consulta', { enDB: false, nro_campo_tipo: 100 });
                                </script>
                            </td>
                            <td id="tdTipo_doc">
                              <script type="text/javascript">
                                   campos_defs.add('tipo_docu', { nro_campo_tipo: 2}); 
                                </script>
                            </td>
                             <td id="tdnro_doc">
                                  <script type="text/javascript">
                                    campos_defs.add('nro_doc', { enDB: false, nro_campo_tipo: 100 });
                                </script>
                            </td>
                            
                            <td id="tdsexo">  
                                 <script type="text/javascript">
                                    campos_defs.add('sexo', {
                                        enDB: false,
                                        nro_campo_tipo: 1,
                                        //   filtroWhere: "<sexo type='igual'>%campo_value%</sexo>",
                                        StringValueIncludeQuote: true
                                    });
                                    var rs = new tRS();
                                    rs.format = "getterror";
                                    rs.format_tError = "json";
                                    rs.addField("id", "string")
                                    rs.addField("campo", "string")
                                    rs.addRecord({ id: "M", campo: "Masculino" });
                                    rs.addRecord({ id: "F", campo: "Femenino" });
                                    campos_defs.items['sexo'].rs = rs;
                                </script>
                            </td> 
                            <td id="tdape">
                                 <script type="text/javascript">
                                    campos_defs.add('ape', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                            <td id="tdnom">
                                  <script type="text/javascript">
                                    campos_defs.add('nom', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                       
                    
                            <td id="dasivision">
                                   <script type="text/javascript">
                                    campos_defs.add("division",{ nro_campo_tipo: 2 });
                                </script>
                            </td>   
                            <td id="tdvigente">  
                                   <script type="text/javascript">
                                    campos_defs.add('vigente', {
                                        enDB: false,
                                        nro_campo_tipo: 1
                                    });
                                    var rs = new tRS();
                                    rs.format = "getterror";
                                    rs.format_tError = "json";
                                    rs.addField("id", "string")
                                    rs.addField("campo", "string")
                                    rs.addRecord({ id: "1", campo: "vigente" });
                                    rs.addRecord({ id: "0", campo: "no vigente" });
                                    campos_defs.items['vigente'].rs = rs;
                                </script>
                            </td> 

                            <td>
                                 <script type="text/javascript">
                                    campos_defs.add('fe_desde', { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td> 
                            <td>
                                   <script type="text/javascript">
                                    campos_defs.add('fe_hasta', { enDB: false, nro_campo_tipo: 103 });
                                </script>
                            </td>    
                            <td>
                              <script type="text/javascript">
                                    campos_defs.add('user', { enDB: false, nro_campo_tipo: 104 });
                              </script>
                            </td>    
                        </tr>
                        </table>
                  
                    <table class="tb1" style="width: 100%"> 
                        <tr class="tbLabel">
                            <td style="text-align: center;width:15%">Motivo</td>
                            <td style="text-align: center;width:15%">Información Adicional</td>
                            <td style="text-align: center;width:15%">Comentario</td>
                            <td style="text-align: center;width:15%">Publicación (desde)</td> 
                            <td style="text-align: center;width:15%">Publicación (hasta)</td> 
                        </tr> 
    
                        <tr>
                             <td> 
                                <script type="text/javascript">
                                    campos_defs.add('ReasonListed', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td> 
                            <td>  
                              <script type="text/javascript">
                                  campos_defs.add('AdditionalInfo', { enDB: false, nro_campo_tipo: 104 }); 
                              </script>
                            </td> 
                            <td>  
                              <script type="text/javascript">
                                    campos_defs.add('Comments', { enDB: false, nro_campo_tipo: 104 }); 
                                </script>
                            </td>               
                            <td>  
                              <script type="text/javascript">
                                    campos_defs.add('Published_desde', { enDB: false, nro_campo_tipo: 103 }); 
                                </script>
                            </td> 
                          
                            <td>  
                              <script type="text/javascript">
                                    campos_defs.add('Published_hasta', { enDB: false, nro_campo_tipo: 103 }); 
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
                            
                            <tr>
                                    
                                <td>  
                                  <script type="text/javascript">
                                        campos_defs.add('tipo_busqueda', {
                                            enDB: false,
                                            nro_campo_tipo: 1,
                                            mostrar_codigo: false,
                                            onchange: onchange_busqueda
                                        });
                                        var rs = new tRS();
                                        rs.format = "getterror";
                                        rs.format_tError = "json";
                                        rs.addField("id", "string")
                                        rs.addField("campo", "string")
                                        rs.addRecord({ id: "1", campo: "Por resultado" });
                                        rs.addRecord({ id: "0", campo: "Por consulta" });
                                        campos_defs.items['tipo_busqueda'].rs = rs;
                                  </script>
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
