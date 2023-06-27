<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%
    Me.contents("dato1") = "Hola mundo"
    Me.contents("dato2") = Date.Now
    Me.contents("dato3") = 15
    Me.contents("dato4") = CDbl(15)
    Me.contents("dato5") = CDbl(15.35)
    Me.contents("filtroPrueba") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("filtroXMLmiCampo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>estado as [id], descripcion as campo</campos><filtro></filtro></select></criterio>")
    
    '<export_params path_xsl='report\html_base.xsl'  />
    Dim expParam As New nvFW.tnvExportarParam
    With expParam
        .filtroXML = "<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>"
        .path_xsl = "report\html_base.xsl"
    End With
    Me.contents("exportar01") = expParam.encXML() ' nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select><></criterio>")
    
    
    Dim expParam2 As New nvFW.tnvExportarParam(VistaGuardada:="credito_analisis", report_name:="Analisis_Interno.rpt")
    Me.contents("mostrar13") = expParam2.encXML()
    
    'Dim expParam2 As New nvFW.tnvExportarParam(VistaGuardada:="credito_analisis", report_name:="Analisis_Interno.rpt")
    Me.contents("mostrar14") = (New nvFW.tnvExportarParam(VistaGuardada:="credito_analisis", report_name:="Analisis_Interno.rpt")).encXML()
    Me.contents("mostrar15") = nvFW.tnvExportarParam.getEncXML(VistaGuardada:="credito_analisis", report_name:="Analisis_Interno.rpt")

      
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>

    <link href="/admin/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

    <script type="text/javascript" language="javascript">
    
    </script>
    <script type="text/javascript" language="javascript">
      
      function exportar_ej01() {
         var filtroXML = "<criterio><select vista='estado' ><campos>*</campos></select><result><filter campo_id='estado' campo_desc='descripcion'/><filter campo_id='nro_permiso' campo_desc='nro_permiso'/></result></criterio>"
         nvFW.exportarReporte({
         filtroXML: filtroXML
        , path_xsl: "report/ejemplos/HTML_simple.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "iframe1"
        , bloq_contenedor: $('iframe1')
        , cls_contenedor: 'iframe1'
        })
        }   

        
      function exportar_ej14() {
         //Exportacion a HTML con paginación y guarda la info en el nvFW
         //Destino un IFRAME
         //var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 
         
         var filtroXML = "<criterio><select vista='estado' PageSize='20' AbsolutePage='1' ><campos>*</campos></select><result><filter campo_id='estado' campo_desc='descripcion'/><filter campo_id='nro_permiso' campo_desc='nro_permiso'/></result></criterio>"
         nvFW.exportarReporte({
         filtroXML: filtroXML
        , path_xsl: "report/ejemplos/HTML_paginacion.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "iframe1"
        , bloq_contenedor: $('iframe1')
        , cls_contenedor: 'iframe1'
        , nvFW_mantener_origen: true //Obligatorio para la paginación, sino no sabe donde guardar la incormación de llamada
            })
        }


      function exportar_ej15() {
         //Exportacion a HTML con paginación y guarda la info de la consulta en la DB
         //Destino un IFRAME
         //var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 
         
         var filtroXML = "<criterio><select vista='estado' PageSize='3' AbsolutePage='1' ><campos>*</campos></select></criterio>"
         nvFW.exportarReporte({
         filtroXML: filtroXML
        , path_xsl: "report/ejemplos/HTML_paginacion.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "iframe1"
        , bloq_contenedor: $('iframe1')
        , cls_contenedor: 'iframe1'
        , mantener_origen: true //Obligatorio para la paginación, sino no sabe donde guardar la incormación de llamada
            })
        }

     function exportar_ej16() {
         //Exportacion a HTML con paginación y guarda la info en el nvFW y con cache
         //Destino un IFRAME
         //var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 

         var filtroXML = "<criterio><select vista='estado' PageSize='3' AbsolutePage='1' cacheControl='session' expire_minutes='60'><campos>*</campos></select></criterio>"
         //var filtroXML = "<criterio><select cacheID='25' PageSize='3' AbsolutePage='2'></criterio>"
         var filtroXML = "<criterio><select vista='estado' PageSize='3' AbsolutePage='1' cacheControl='session' expire_minutes='60' cacheID='25'><campos>*</campos></select></criterio>"
         nvFW.exportarReporte({
         filtroXML: filtroXML
        , path_xsl: "report/ejemplos/HTML_paginacion.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "iframe1"
        , bloq_contenedor: $('iframe1')
        , cls_contenedor: 'iframe1'
        , nvFW_mantener_origen: true //Obligatorio para la paginación, sino no sabe donde guardar la incormación de llamada
            })
        }

        function exportar_ej17() {
            //Simple exportacion a html
            //Destino un IFRAME
            var filtroXML = "<criterio><procedure CommandText='dbo.zzEliminar_prueba' cn='default' CommandTimeout='3000'><parametros><num DataType='int'>15</num><cad>otra cosa</cad><fecha DataType='datetime'>3/25/2016</fecha></parametros></procedure></criterio>"
            nvFW.exportarReporte({
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
        , ContentType: "text/html" //default opcional
        , formTarget: "iframe1"
            })
        }


        function exportar_ej18() {
            //Exportacion a EXCEL por RSXMLtoExcel. Guarda a un archivo en la carpera definida como raiz
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        , destinos: "file://(raiz)/directorio_archivos/prueba.xls"
        , metodo: "HTTPRequest"
        , async: false //Default opcional
        , export_exeption: "RSXMLtoExcel"
        , funComplete: function (response, parseError) {
            var oXML = new tXML()
            if (oXML.loadXML(response.responseText))
                var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
            else
                var numError = -1
            alert(numError)
        }
            })
            alert("Sincronico")
        }


        function exportar_ej19() {
            //Exportación encriptada
            //Destino un IFRAME
            var filtroXML = nvFW.pageContents.exportar01
            nvFW.exportarReporte({ filtroXML: filtroXML 
                                , salida_tipo: "adjunto"
                                , ContentType: "text/html" //default opcional
                                , formTarget: "iframe1"})
          }
    </script>
    <script type="text/javascript" language="javascript">
     
        

    </script>

</head>
<body  style="width: 100%; height: 100%; overflow: auto" >
    <form name="pruebas" action="" method="GET" style="width: 100%">
    <table class="tb1">
        <tr class="tbLabel0">
            <td>
                Ejemplos de Exportar Reporte
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Exp. Ej 01" onclick="return exportar_ej01()" title="Exportacion a HTML simple" />
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Exp. Ej 14" onclick="return exportar_ej14()" title="Exportacion a HTML con paginación y guarda la info en el nvFW" />
                <input type="button" value="Exp. Ej 15" onclick="return exportar_ej15()" title="Exportacion a HTML con paginación y guarda la info en la db" />
                <input type="button" value="Exp. Ej 16" onclick="return exportar_ej16()" title="Exportacion a HTML con paginación y guarda la info en el nvFW y con cache" />
                <input type="button" value="Exp. Ej 17" onclick="return exportar_ej17()" title="Exportacion a HTML desde un StoreProcedure" />
                <input type="button" value="Exp. Ej 18" onclick="return exportar_ej18()" title="Exportacion a EXCEL por RSXMLtoExcel. Guarda a un archivo en la carpera definida como raiz" />
                <input type="button" value="Exp. Ej 19" onclick="return exportar_ej19()" title="Llamada al exportar encriptada" />
                
            </td>
        </tr>
        </table>
    </form>
    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="../admin/enBlanco.htm"></iframe>
</body>
</html>
