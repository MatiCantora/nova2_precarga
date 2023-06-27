 <%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim fnombres As String = nvFW.nvUtiles.obtenerValor("nombres", "")
    Dim fapellidos As String = nvFW.nvUtiles.obtenerValor("apellidos", "")
    Dim ftipodoc As String = nvFW.nvUtiles.obtenerValor("tipodoc", "")
    Dim fdocumento As String = nvFW.nvUtiles.obtenerValor("documento", "")
    Dim fsexo As String = nvFW.nvUtiles.obtenerValor("sexo", "")
    Dim fpais As String = nvFW.nvUtiles.obtenerValor("pais", "")
    Dim ffechanac As String = nvFW.nvUtiles.obtenerValor("fechanac", Nothing)
    Dim fdivision As String = nvFW.nvUtiles.obtenerValor("division", "")
    Dim fvigencia As String = nvFW.nvUtiles.obtenerValor("vigencia", "")
    Dim fesreconsulta As String = nvFW.nvUtiles.obtenerValor("esreconsulta", "")
    Dim flista_tipobusqueda As String = nvFW.nvUtiles.obtenerValor("lista_tipobusqueda", "")
    Dim fnro_consulta As String = nvFW.nvUtiles.obtenerValor("nro_consulta", "")
    Dim fResultID As String = nvFW.nvUtiles.obtenerValor("ResultID", "")

    Dim op = nvFW.nvApp.getInstance.operador
    If Not op.tienePermiso("permisos_lexisnexis", 2) Then
        Response.Redirect("/FW/error/httpError_401.aspx")
    End If

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")


    If accion.ToUpper() = "CONSULTAR" Then
        If Not op.tienePermiso("permisos_lexisnexis", 3) Then
            Response.Redirect("/FW/error/httpError_401.aspx")
        End If

        Dim err As New tError()
        Try

            Dim nombres As String = nvFW.nvUtiles.obtenerValor("nombres", "")
            Dim apellido As String = nvFW.nvUtiles.obtenerValor("apellido", "")
            Dim tipo_docu As String = nvFW.nvUtiles.obtenerValor("tipo_docu", "")
            Dim nro_docu As String = nvFW.nvUtiles.obtenerValor("nro_docu", "")
            Dim sexo As String = nvFW.nvUtiles.obtenerValor("sexo", "")
            Dim pais As String = nvFW.nvUtiles.obtenerValor("pais", "")
            Dim fe_naci As Date = nvFW.nvUtiles.obtenerValor("fe_naci", Nothing)
            Dim division As String = nvFW.nvUtiles.obtenerValor("division", "")
            Dim lista_tipobusqueda As String = nvFW.nvUtiles.obtenerValor("lista_tipobusqueda", "")

            err = nvFW.servicios.LEXISNEXIS.search(nombres, apellido, tipo_docu, nro_docu, sexo, pais, fe_naci, True, division, "", lista_tipobusqueda)

        Catch ex As Exception
            err.numError = -1
            err.mensaje = ex.Message
            err.debug_desc = ex.Message
            err.titulo = "Error"
        End Try


        err.response()

    End If


    Me.addPermisoGrupo("permisos_lexisnexis")


    Me.contents("filtro_consulta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos>[file],Name,BestName,Published,BestNameScore,AlertState,ResultID,nro_consulta, documento, nro_docu,apellido,nombres,sexo,pais,division, PredefinedSearchName,[user] ,fe_consulta,fe_vigente,vigente,fe_naci</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_consultas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verLn_resultados'><campos>[file],Name,BestName,Published,BestNameScore,AlertState,ResultID, documento, nro_docu,apellido,nombres,sexo,pais,division,PredefinedSearchName, [user] ,fe_consulta,fe_vigente,vigente,fe_naci</campos><orden></orden><filtro></filtro></select></criterio>")


    Me.contents("fnombres") = fnombres
    Me.contents("fapellidos") = fapellidos
    Me.contents("ftipodoc") = ftipodoc
    Me.contents("fdocumento") = fdocumento
    Me.contents("fsexo") = fsexo
    Me.contents("fpais") = fpais
    Me.contents("ffechanac") = ffechanac
    Me.contents("fvigencia") = fvigencia
    Me.contents("fesreconsulta") = fesreconsulta
    Me.contents("fdivision") = fdivision
    Me.contents("flista_tipobusqueda") = flista_tipobusqueda
    Me.contents("fnro_consulta") = fnro_consulta
    Me.contents("fResultID") = fResultID



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

         var nom_consulta = ""
         if (nvFW.pageContents.fesreconsulta == 'False') {
             nom_consulta = " Consultar"
         }
         else {
             nom_consulta = " Reconsultar"

         }
         vButtonItems[0] = {}
         vButtonItems[0]["nombre"] = "Consultar";
         vButtonItems[0]["etiqueta"] = nom_consulta; 
         vButtonItems[0]["imagen"] = "Consultar";
         vButtonItems[0]["onclick"] = "return confirmar_consulta()";

         vButtonItems[1] = {}
         vButtonItems[1]["nombre"] = "Salir";
         vButtonItems[1]["etiqueta"] = " Salir";
         vButtonItems[1]["imagen"] = "Salir";
         vButtonItems[1]["onclick"] = "return win.close()";
         var win = nvFW.getMyWindow();



         var vListButton = new tListButton(vButtonItems, 'vListButton');
         vListButton.loadImage("Consultar", '/FW/image/icons/persona_mas.png');
         vListButton.loadImage("Salir", '/FW/image/transferencia/salir.png');
 



         function window_onload() {

             vListButton.MostrarListButton();

             setearcamposdef();
             window_onresize();

         }
         function window_onresize() {

           }


         function confirmar_consulta() {
             if (nvFW.tienePermiso('permisos_lexisnexis', 3)) {

                 var canterrores = 0
                 var nombres = campos_defs.get_value("apellido")
                 var apellido = campos_defs.get_value("apellido")
                 var tipo_docu = campos_defs.get_value("tipo_docu")
                 var nro_docu = campos_defs.get_value("nro_docu")
                 var sexo = campos_defs.get_value("sexo")
                 var fe_naci = campos_defs.get_value("fe_naci")
                 var pais = campos_defs.get_value("pais")
                 var division = campos_defs.get_value("division")
                 var lista_tipobusqueda = campos_defs.get_value("lista_tipobusqueda")

                 if (nombres == "")
                     canterrores += 1
                 if (apellido == "")
                     canterrores += 1
                 if (tipo_docu == "")
                     canterrores += 1
                 if (nro_docu == "")
                     canterrores += 1
                 if (sexo == "")
                     canterrores += 1
                 if (fe_naci == "")
                     canterrores += 1
                 if (pais == "")
                     canterrores += 1
                 if (division == "")
                     canterrores += 1
                 if (lista_tipobusqueda == "")
                     canterrores += 1

                 if (canterrores != 0) {
                     alert("Todos los campos son requeridos.")
                    return
                 }
                 
                 var strHTML = "<br/><table class='tb1'><tr><td nowrap>¿Está seguro de querer realizar la consulta?</td> </tr></table>"
                 nvFW.confirm(strHTML,
                     {
                         title: "Confirmar",
                         onShow: function (win) {

                         },
                         onOk: function (win) {
                              
                             consultar_lexisnexis()
                             
                             win.close()
                         }
                     })
             }
             else {
                 alert("No posee permisos suficientes para realizar la consulta.")
             }
         }




         function consultar(bandera) {
             var filtro = "";


             if (campos_defs.get_value('tipo_docu') != "") {
                 filtro += "<tipo_docu type='igual'>" + campos_defs.get_value('tipo_docu') + "</tipo_docu>";
             }
             if (campos_defs.get_value('nro_docu') != "") {
                 var filtroAux = "<nro_docu type='in'>'" + campos_defs.get_value('nro_docu') + "'</nro_docu>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('nombres') != "") {
                 var filtroAux = "<nombres type='in'>'" + campos_defs.get_value('nombres') + "'</nombres>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('apellido') != "") {
                 var filtroAux = "<apellido type='in'>'" + campos_defs.get_value('apellido') + "'</apellido>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }
             if (campos_defs.get_value('sexo') != "") {
                 var filtroAux = "<sexo type='igual'>" + campos_defs.get_value('sexo') + "</sexo>";
                 filtro += filtroAux.replace(/, /g, "', '");
             }

             //consulta periodo
             if (campos_defs.get_value('fe_naci') != "")
                 filtro += "<fe_naci type='igual'>convert(datetime, '" + campos_defs.get_value('fe_naci') + "', 103)</fe_naci>";

 
             if (bandera == 0) {

                 nvFW.exportarReporte({
                     filtroXML: nvFW.pageContents.filtro_consulta,
                     filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                     path_xsl: "/report/lexisnexis/LN_nueva_consuta_plantilla.xsl",
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
                                 filtroXML: nvFW.pageContents.filtro_consulta,
                                 filtroWhere: "<criterio><select ><filtro>" + filtro + "</filtro></select></criterio>",
                                 path_xsl: "/report/lexisnexis/LN_nueva_consulta_plantilla.xsl",
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

             var path_reporte =  "/report/lexisnexis/nconsulta/LN_resultado.rpt"


             nvFW.mostrarReporte({
                 filtroXML: nvFW.pageContents.filtro_consulta,
                 filtroWhere: "<criterio><select><filtro>" + filtro_descarga + "</filtro></select></criterio>",
                 path_reporte: path_reporte, 
                 ContentType: "application/pdf",
                 filename: "Consulta Lexis Nexis Nro Consulta " + nroconsulta + '.pdf',
                 formTarget: "_blank"
             })
         }


         function consultar_lexisnexis() { 


             nvFW.error_ajax_request('nueva_consulta.aspx', {
                 parameters: {
                     accion: 'CONSULTAR',
                     nombres: campos_defs.get_value("nombres"),
                     apellido: campos_defs.get_value("apellido"),
                     tipo_docu: campos_defs.get_value("tipo_docu"),
                     nro_docu: campos_defs.get_value("nro_docu"),
                     sexo: campos_defs.get_value("sexo"),
                     fe_naci: campos_defs.get_value("fe_naci"),
                     pais: campos_defs.get_value("pais"),
                     division: campos_defs.get_value("division"),
                     lista_tipobusqueda: campos_defs.get_value("lista_tipobusqueda")
                 },
                 onSuccess: function (err) {
                     if (err.numError == 0)
                         descargar_consulta(err.params.nro_consulta, err.params.ResultID)
 
                 },
                 onFailure: function (err, transport) {

                    },
                 bloq_msg: 'Consultando...'
             });
         }
         function setearcamposdef() {
             campos_defs.set_value('nombres', nvFW.pageContents.fnombres);
             campos_defs.set_value('apellido', nvFW.pageContents.fapellidos);
             campos_defs.set_value('tipo_docu', nvFW.pageContents.ftipodoc);
             campos_defs.set_value('nro_docu', nvFW.pageContents.fdocumento);
             campos_defs.set_value('sexo', nvFW.pageContents.fsexo);
             campos_defs.set_value('pais', nvFW.pageContents.fpais);
             campos_defs.set_value('fe_naci', nvFW.pageContents.ffechanac);
             campos_defs.set_value('division', nvFW.pageContents.fdivision);
             campos_defs.set_value('lista_tipobusqueda', nvFW.pageContents.flista_tipobusqueda); 
            
         }




     </script>
     
</head> 
<body onload="window_onload()" onresize="window_onresize()" style='width: 100%; height: 100%; overflow: hidden;'>

   
    
    <div id="divCabecera" style="width: 100%">
          <table id="tbFiltros" class="tb1" style="width: 100%">
            <tr>
                <td colspan="4">
                    <div id="divMenu" style="width: 100%"></div>
                </td> 
                <script type="text/javascript">

                    var vMenuModulos = new tMenu('divMenu', 'vMenuModulos');

                    Menus["vMenuModulos"] = vMenuModulos
                    Menus["vMenuModulos"].alineacion = 'center';

                    Menus["vMenuModulos"].estilo = 'A';
                    Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc> Detalle</Desc></MenuItem>")


                    if (nvFW.pageContents.fvigencia) {
                        vMenuModulos.loadImage("descargar", '/FW/image/docs/pdf.png');//edit
                        var descarga = " Imprimir"
                        var vig = "" 
                        if (nvFW.pageContents.fvigencia == "True") {
                            vMenuModulos.loadImage("estado", '/FW/image/icons/persona_mas.png');
                            vig = " Vigente"
                        }
                        else {
                            vMenuModulos.loadImage("estado", '/FW/image/icons/persona_quitar.png');
                            vig= " No vigente"
                        } 
                        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='1' ><Lib TipoLib='offLine'>DocMNG</Lib><icono>descargar</icono><Desc >" + descarga + "</Desc><Acciones><Ejecutar Tipo='script'><Codigo> descargar_consulta(" + nvFW.pageContents.fnro_consulta + "," + nvFW.pageContents.fResultID + ") </Codigo></Ejecutar></Acciones></MenuItem>")

                        Menus["vMenuModulos"].CargarMenuItemXML("<MenuItem id='2' ><Lib TipoLib='offLine'>DocMNG</Lib><icono>estado</icono><Desc >" + vig + "</Desc></MenuItem>")
                    }
                    vMenuModulos.MostrarMenu()


                </script> 
                 

               <tr><td></td></tr>                 
               <tr>
                <td class="Tit1" style="width:20%"><b>Nombres:</b></td>   
                <td id="tdn" style="width:30%">

                    <script type="text/javascript">
                        campos_defs.add('nombres', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
             </tr>
              <tr><td></td></tr>
            <tr>
                
                <td class="Tit1" style="width:20%"><b>Apellidos:</b></td>   
                <td id="tdnape" style="width:30%">
                    <script type="text/javascript">
                        campos_defs.add('apellido', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
              <tr><td></td></tr>
              
            <tr>
                
                    <td class="Tit1" style="width:10%"><b>Tipo Doc:</b></td>   
                    <td id="tdTipo_doc" style="width:10%">
                        <script  type="text/javascript">
                            campos_defs.add('tipo_docu', { nro_campo_tipo: 1 });
                        </script>
                    </td>
            </tr>
              <tr><td></td></tr>
            <tr>
              
                        <td class="Tit1" style="width:20%" ><b>Documento:</b></td>   
                        <td id="tddoc" style="width:30%">

                            <script type="text/javascript">
                                campos_defs.add('nro_docu', { enDB: false, nro_campo_tipo: 100 });
                            </script>
                        </td>
            </tr>
              <tr><td></td></tr>
            <tr>
                        <td class="Tit1" style="width:10%"><b>Sexo:</b></td>   
                        <td id="tdsex" style="width:10%">
                            <script type="text/javascript">
                                campos_defs.add('sexo', {
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroWhere: "<sexo type='igual'>%campo_value%</sexo>"
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
                   
            </tr>
               <tr><td></td></tr>
              
            <tr>
                 <td class="Tit1" style="width:10%"><b>País:</b></td>   
                <td id="tdpais" style="width:20%"> 
                    <script type="text/javascript">
                        campos_defs.add('pais', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
              <tr><td></td></tr> 
            <tr>
                <td class="Tit1" style="width:20%" nowrap><b>Fecha de Nacimiento:</b></td>   
                <td id="tdfenac" style="width:50%">
                    <script type="text/javascript">
                        campos_defs.add('fe_naci', { enDB: false, nro_campo_tipo: 103 });
                    </script>
                </td>
            </tr>
              <tr><td></td></tr>
            <tr>
                <td class="Tit1" style="width:20%"><b>División:</b></td>   
                <td id="tddiv" style="width:50%">
                    <script type="text/javascript">
                        campos_defs.add('division', { nro_campo_tipo: 1  });
                    </script>
                </td>
            </tr>
               <tr><td></td></tr>
            <tr>
                <td class="Tit1" style="width:20%"><b>Tipo de Busqueda:</b></td>   
                <td id="tdbusqpred" style="width:50%">
                    <script type="text/javascript">
                        campos_defs.add('lista_tipobusqueda', { nro_campo_tipo: 1 });
                    </script>
                </td>
            </tr>
              <tr><td></td></tr><tr><td></td></tr>
              </table> 
            <table class="tb1"> 
                <tr>
                 

                    <td   style=" width: 15%"></td>
                    <td colspan="1">
                        <div id="divConsultar" style="width: 30%"></div>
                    </td>
                    <td   style=" width: 10%"></td>
                    
                    <td colspan="1">
                        <div id="divSalir" style="width: 30%"></div>
                    </td>
                    <td   style=" width: 10%"></td>
                    



                </tr>                        
           </table>
         
    </div>
</body>
</html>