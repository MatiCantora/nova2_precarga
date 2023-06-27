<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%


    'Stop

    'nvLog.addEvent("vi_questions", "Juan;Perez;254667788;M")

    'nvLog.addEvent("vi_questions_ok", "1500;Juan;Perez;254667788;M;1231654")

    'nvLog.addEvent("vi_questions_error", "1500;Juan;Perez;254667788;M;1231654;xxxxxhasxxxxaxsxasx")






    'Dim a As Single = 10 / 0
    'Dim ui As UInt16 = 0

    'ui = ui - 10


    'Dim cn As ADODB.Connection = nvFW.nvDBUtiles.DBConectar("default")
    'Dim rsExec As New ADODB.Recordset
    'Dim strSQL = "select top 10 * into #tmp_campos_def3 from campos_def"
    'rsExec = nvFW.nvDBUtiles.DBExecute(strSQL,,,,, cn, False)

    'strSQL = "select * from #tmp_campos_def3"
    'Dim rs As ADODB.Recordset
    'rs = nvFW.nvDBUtiles.DBExecute(strSQL,,,,, cn, False)


    Me.contents("dato1") = "Hola mundo"
    Me.contents("dato2") = Date.Now
    Me.contents("dato3") = 15
    Me.contents("dato4") = CDbl(15)
    Me.contents("dato5") = CDbl(15.35)




    Me.contents("filtroPrueba") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>")

    Me.contents("filtroXMLmiCampo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>estado as [id], descripcion as campo</campos><filtro></filtro></select></criterio>")

    Me.contents("filtro15") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado' PageSize='3' AbsolutePage='1' ><campos>*</campos></select></criterio>")
    Me.contents("filtro6") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos></select></criterio>")

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

    Me.contents("mostrar16") = nvFW.tnvExportarParam.getEncXML(filtroXML:="", filtroWhere:="", report_name:="Analisis_Interno.rpt")


 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>

    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
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
     
        function exportar_ej1() { 
            //alert(nvFW.pageContents.dato1)

            //Simple exportacion a html
            //Destino un IFRAME
            
            var filtroXML = "<criterio><select vista='estado'  ><campos>*</campos><filtro></filtro></select></criterio>" //"<criterio><select vista='estado'><campos>*</campos><filtro><estado>%pestado%</estado></filtro></select></criterio>"
            //var filtroXML = nvFW.pageContents.filtroPrueba
            var filtroWhere =  "<criterio><select cn='primaria' PageSize='5' AbsolutePage='1' ><orden>estado</orden></select></criterio>" //"<criterio><select><filtro><estado>'G'</estado></filtro></select></criterio>" //
            //filtroWhere = "<criterio><select><orden>nro_permiso</orden></select></criterio>"
            //VistaGuardada = "vg1"
            var params = "<criterio><params pestado=\"'A'\" /></criterio>"

            //vg
            //params
            window.top.nvFW.exportarReporte({
                         //Datos
                         filtroXML: filtroXML
                         , filtroWhere: filtroWhere
                         ,params: params
                         //,vg = ''
                         //Proceso
                         , path_xsl: "report\\HTML_base_fixedHead.xsl"
                         //, xsl_name: "algo.xsl"
                         //Destinos
                         , salida_tipo: "adjunto" // "estado"
                         , ContentType: "text/html" //default opcional
                         ,formTarget: "iframe1"
                         //Aledaños
                         , cls_contenedor: "iframe1"
                         , cls_contenedor_msg : " "
                         
                         ,bloq_contenedor: 'frame_ref'
                         ,bloq_msg: "CargandoSSS....."
                         ,bloq_id: "sasasa1"
                         //,parametros:"<parametros><columnHeaders><![CDATA[dasdsdsadasdsa]]></columnHeaders></parametros>"
                         , parametros: "<parametros><columnHeaders><table><tr><td></td><td></td></tr></table></columnHeaders></parametros>"

            })
            nvFW.bloqueo_msg("sasasa1", "QQQQQQQQQQQQQ")
        }


        function exportar_ej2() {
            //Simple exportacion a excel
            //Destino un IFRAME
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
              , path_xsl: "report\\excel_base.xsl"
              , salida_tipo: "adjunto"
              , ContentType: "application/vnd.ms-excel"
              , filename: "prueba.xls"
              //, formTarget: "iframe1"
            })
        }

        function exportar_ej3() {

            //Simple exportacion a HTML
            //Destino una nueva ventana
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "_blank"
            })
        }

        function exportar_ej4() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        //, destinos: "file://directorio_archivos/prueba.html"
         , ContentType: "application/xml"
        , formTarget: "iframe1"
            })
        }

        function exportar_ej5() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            //Utiliza el parámetro funComplete para analizar el resultado

            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        , destinos: "file://directorio_archivos/prueba.html"
                //, ContentType: "application/vnd.ms-excel"
        , formTarget: "iframe1"
        , funComplete: function (e) {
            //Cuidado aca, dentro del iframe el XML se formatea según el browser
            //Así sería para IE
            //Si necesitas capturar el XML resultado, mejor utilizar con el método HTTPRequest
            var iframe = Event.element(e)
            var strText = iframe.contentWindow.document.body.innerText
            var strReg = "(-|\n)"
            var reg = new RegExp(strReg, 'ig')
            strText = strText.replace(reg, "")

            var oXML = new tXML()
            if (oXML.loadXML(strText))
                var numError = oXML.selectSingleNode("error_mensajes/error_mensaje/@numError").nodeValue
            else
                var numError = -1


            alert("numError = " + numError)
            // O var numError = oXML.selectSingleNode("//@numError").nodeValue

        }
            })
        }

        function exportar_ej6() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Se ejecuta con el metodo HTTPReqest, es decir que no requiere formulario, ni formtarget
            //Utiliza el parámetro funComplete para analizar el resultado
            var filtroXML = nvFW.pageContents.filtro6
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        , destinos: "file://directorio_archivos/prueba.html"
        , metodo: "HTTPRequest"
        , async: false //Default opcional
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

        function exportar_ej7() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Se ejecuta con el metodo HTTPReqest, es decir que no requiere formulario, ni formtarget
            //Utiliza el parámetro funComplete para analizar el resultado
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        , destinos: "file://directorio_archivos/prueba.html"
        , metodo: "HTTPRequest"
        , async: true
        , funComplete: function (response, parseError) {
            var oXML = new tXML()
            if (oXML.loadXML(response.responseText))
                var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
            else
                var numError = -1
            alert(numError)
        }
            })
            alert("Asincronico")
        }

        function exportar_ej8() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Se ejecuta con el metodo HTTPReqest, es decir que no requiere formulario, ni formtarget
            //Utiliza el parámetro funComplete para analizar el resultado

            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
        , destinos: "file://directorio_archivos/prueba.html"
        , metodo: "HTTPRequest"
        , async: true
        , bloq_contenedor:  $("iframe1") //$$("BODY")[0]
        , funComplete: function (response, parseError) {
            $("iframe1").contentWindow.document.body.innerHTML = response.responseText
            /*var oXML = new tXML()
            if (oXML.loadXML(response.responseText))
            var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
            else
            var numError = -1*/
        }
            })
        }

        function exportar_ej9() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Mustra el documento en un iframe
            //bloq_contenedor y cls_contenedor
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
        , metodo: "submit" //defecto
        , destinos: "file://directorio_archivos/prueba.html"
                //, ContentType: "application/vnd.ms-excel"
        , formTarget: "iframe1"
        , bloq_contenedor: $("iframe1") //$$("BODY")[0]//
        , cls_contenedor: "iframe1"

            })

        }

        function exportar_ej10() {
            //Exportacion a HTML. Muestra el documento en una ventana nueva. cls_contenedor
            //Utiliza el parámetro funComplete para analizar el resultado
            var win = window.createWindow("", "miVentana", "width=200,height=100")
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
                //, ContentType: "application/vnd.ms-excel"
        , formTarget: "miVentana"
        , cls_contenedor: "miVentana"

            })
        
//        debugger
//        var win = ObtenerVentana("miVentana")
//        win.document.body.innerHTML = ""
        }

        function exportar_ej11() {
            //Exportacion a HTML, muetra el resultado en una ventana Prototype
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        , path_xsl: "report\\html_base.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "winPrototype"
        , winPrototype: { modal: true,
            center: true,
            //setWidthMaxWindow:true,
            //centerTop:50,
            recenterAuto:true,
            bloquear: true,
            url: 'enBlanco.htm',
            title: '<b>Titulo ldasldkjskl</b>',
            minimizable: false,
            maximizable: true,
            draggable: true,
            //maxWidth: 1700,
            //width: 1000,
            //height: 400,
            resizable: true,
            destroyOnClose: true,
            centerFromElement: $$("BODY")[0],
            parentHeightPercent: 0.9,
            parentHeightElement: $$("BODY")[0],
            parentWidthPercent: 0.9,
            parentWidthElement: $$("BODY")[0],
            maxWidth:1300,
            maxHeight: 400
            //setHeightToContent:true

        }

            })

        }


        function exportar_ej12() {
            //Exportacion a EXCEL por RSXMLtoExcel. Guarda a un archivo
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
        //, path_xsl: "report\\html_base.xsl"
        , salida_tipo: "estado"
        , destinos: "file://directorio_archivos/prueba.xls"
        , metodo: "HTTPRequest"
        , async: false //Default opcional
        , export_exeption: "RSXMLtoExcel"
        , funComplete: function (response, parseError) {
            var oXML = new tXML()
            if (oXML.loadXML(response.responseText))
                {
                numError = numError = oXML.selectSingleNode("//@numError").nodeValue
                }
            else
                {
                var numError = -1
                }
            alert(numError)
        }
            })
            alert("Sincronico")
        }

        function exportar_ej13() {
            //Simple exportacion a excel
            //Destino un IFRAME
            var filtroXML = "<criterio><select vista='estado'><campos>*</campos></select></criterio>"
            nvFW.exportarReporte({
                //Parémetros de consulta
                filtroXML: filtroXML
                //, metodo: "HTTPRequest"
     , filename: "pruebas.xls"
     , salida_tipo: "adjunto"
     , export_exeption: "RSXMLtoExcel"
     , ContentType: "application/vnd.ms-excel"
                //, formTarget: "miVentana"
                //, cls_contenedor: "miVentana"
                //,formTarget: "iframe1"
            })
        }

        
      function exportar_ej14() {
         //Exportacion a HTML con paginación y guarda la info en el nvFW
         //Destino un IFRAME
         //var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 
         
         var filtroXML = nvFW.pageContents.filtroPrueba // "<criterio><select vista='estado' ><campos>*</campos></select></criterio>"
         var filtroWhere = "<criterio><select vista='estadodsd' PageSize='8' AbsolutePage='1' cacheControl='Session' expire_minutes='1'></select><result><filter campo_id='estado' campo_desc='descripcion'/><filter campo_id='nro_permiso' campo_desc='nro_permiso'/></result></criterio>"
         top.nvFW.exportarReporte({
         filtroXML: filtroXML
        , filtroWhere : filtroWhere
        , path_xsl: "report/ejemplos/HTML_paginacion.xsl"
        , salida_tipo: "adjunto"
        , formTarget: "iframe1"
        , bloq_contenedor: window.top.document.body //$('iframe1')
        , cls_contenedor: 'iframe1'
        , nvFW_mantener_origen: true //Obligatorio para la paginación, sino no sabe donde guardar la incormación de llamada
            })
        }


      function exportar_ej15() {
         //Exportacion a HTML con paginación y guarda la info de la consulta en la DB
         //Destino un IFRAME
         //var filtroXML = "<criterio><select vista='verSocio_Consumos_nova' PageSize='" + registros + "' AbsolutePage='1' cacheControl='Session'><campos>tipo_docu,nro_docu,sexo,nro_credito,nro_banco,banco,nro_mutual,mutual,nro_comercio,comercio,id_srv,srv_desc,estado,fe_estado,nro_operatoria,nro_entidad,importe_neto,cuotas,importe_cuota,descripcion,saldo_total,saldo_vencido,saldo_pagado," + modal + " as modal,'" + id_win + "' as id_win,importe_documentado,nro_banco_origen,banco_origen</campos><orden>nro_comercio desc, fe_estado desc</orden><filtro>" + filtro + "</filtro></select></criterio>" 
         
         var filtroXML = nvFW.pageContents.filtro15
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


         function exportar_ej20() //Exportar a CSV
           {  
            //alert(nvFW.pageContents.dato1)
            //Simple exportacion a html
            //Destino un IFRAME
            var filtroXML = nvFW.pageContents.filtroPrueba 
            nvFW.exportarReporte({
                           filtroXML: filtroXML
                         , path_xsl: "report\\csv_base.xsl"
                         //, xsl_name: "algo.xsl"
                         , salida_tipo: "adjunto"
                         , formTarget: "iframe1"
                         , destinos: "file://directorio_archivos/prueba.csv"
            })
        }
    </script>
    <script type="text/javascript" language="javascript">
        function mostrar_ej1() {
        
            //Exportacion a PDF
            //Destino un IFRAME
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
                , filtroXML: "<criterio><select top='100' otro='otro'><campos>*</campos><filtros><nro_credito type='igual'>4028153</nro_credito></filtros></select></criterio>"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
                //, ContentType: "text/html" //default opcional
        , formTarget: "iframe1"
            })
        }
        function mostrar_ej2() {
            //Exportacion a Excel
            //Destino un IFRAME
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
        , ContentType: "application/vnd.ms-excel" //default opcional
        , formTarget: "iframe1"
            })
        }
        function mostrar_ej3() {
            //Exportacion a crystal
            //Destino una nueva ventana
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "crystal"
        , ContentType: "application/vnd.ms-excel" //default opcional
        , formTarget: "_blank"
            })
        }

        function mostrar_ej4() {
            //Exportacion a PDF guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , destinos: "file://directorio_archivos/prueba.xls"
        , salida_tipo: "estado"
        , formTarget: "iframe1"
            })
        }

        function mostrar_ej5() {
            //Exportacion a PDF guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            //Utiliza el parámetro funComplete para analizar el resultado
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , destinos: "file://directorio_archivos/prueba.xls"
        , salida_tipo: "estado"
        , formTarget: "iframe1"
        , funComplete: function (e) {
            //Cuidado aca, dentro del iframe el XML se formatea según el browser
            //Así sería para IE
            //Si necesitas capturar el XML resultado, mejor utilizar con el método HTTPRequest
            var iframe = Event.element(e)
            var strText = iframe.contentWindow.document.body.innerText
            var strReg = "(-|\n)"
            var reg = new RegExp(strReg, 'ig')
            strText = strText.replace(reg, "")

            var oXML = new tXML()
            if (oXML.loadXML(strText))
                var numError = oXML.selectSingleNode("error_mensajes/error_mensaje/@numError").nodeValue
            else
                var numError = -1


            alert("numError = " + numError)
            // O var numError = oXML.selectSingleNode("//@numError").nodeValue

        }
            })
        }
        function mostrar_ej6() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            //Utiliza el parámetro funComplete para analizar el resultado
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , destinos: "file://directorio_archivos/prueba.xls"
        , salida_tipo: "estado"
        , metodo: "HTTPRequest"
        , async: false
        , formTarget: "iframe1"
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
        function mostrar_ej7() {
            //Simple exportacion a HTML guardando el archivo en disco
            //Informa en el iframe el resultado de la exportación
            //Utiliza el parámetro funComplete para analizar el resultado
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , destinos: "file://directorio_archivos/prueba.xls"
        , salida_tipo: "estado"
        , metodo: "HTTPRequest"
        , async: true
        , formTarget: "iframe1"
        , funComplete: function (response, parseError) {
            var oXML = new tXML()
            if (oXML.loadXML(response.responseText))
                var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
            else
                var numError = -1
            alert(numError)
        }
            })
            alert("Asincronico")
        }

        function mostrar_ej8() {
            //Exportacion a PDF. Destino un IFRAME. 'bloq_contenedor' 
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
                //, ContentType: "text/html" //default opcional
        , formTarget: "iframe1"
        , bloq_contenedor: $("iframe1")
            })
        }

        function mostrar_ej9() {
            ///Exportacion a PDF. Destino una nueva ventana.
            var win = window.createWindow()
            win.name = "miVentana"
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
                //, ContentType: "text/html" //default opcional
        , formTarget: "miVentana"
        , cls_contenedor: "miVentana"
            })
        }

        function mostrar_ej10() {
            //Exportacion a PDF
            //Destino un IFRAME
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
        , formTarget: "winPrototype"
        , winPrototype: { modal: true,
            center: true,
            bloquear: true,
            url: 'enBlanco.htm',
            title: '<b>Titulo ldasldkjskl</b>',
            minimizable: false,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 400,
            resizable: true,
            destroyOnClose: true
        }
            })
        }

        function mostrar_ej11() {
            //Exportacion a PDF
            //Destino un IFRAME
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "adjunto"
        , formTarget: "winPrototype"
        , winPrototype: { modal: true,
            center: true,
            bloquear: true,
            url: 'enBlanco.htm',
            title: '<b>Titulo ldasldkjskl</b>',
            minimizable: false,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 400,
            resizable: true,
            destroyOnClose: true
        }
            })
        }

        function mostrar_ej12() {
            //Exportacion a PDF
            //Destino un IFRAME
            nvFW.mostrarReporte({
                VistaGuardada: "credito_analisis"
        , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
        , report_name: "Analisis_Interno.rpt"
        , salida_tipo: "crystal"
        , formTarget: "winPrototype"
        , winPrototype: { modal: true,
            center: true,
            bloquear: true,
            url: 'enBlanco.htm',
            title: '<b>Titulo ldasldkjskl</b>',
            minimizable: false,
            maximizable: true,
            draggable: true,
            width: 1000,
            height: 400,
            resizable: true,
            destroyOnClose: true
        }
            })
        }


        function mostrar_ej13() {

            //Exportacion a PDF
            //Destino un IFRAME
            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.mostrar13
               , filtroWhere: "<criterio><select><filtro><nro_credito type='igual'>4028153</nro_credito></filtro></select></criterio>"
               , salida_tipo: "adjunto"
               , formTarget: "iframe1"
            })
        }


        function transf_ej1() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = '' //'<parametros><nro_banco>' + nro_banco + '</nro_banco><nro_mutual>' + nro_mutual + '</nro_mutual></parametros>'
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                salida_tipo: 'estado',
                pasada: 0,
                formTarget: 'iframe1'
            })

        }

        function transf_ej2() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = ''
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                formTarget: '_blank',
                salida_tipo: "estado"
            })
        }

        function transf_ej3() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = ''
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                salida_tipo: "estado",
                formTarget: 'winPrototype',
                async: false,
                funComplete: function (response, parseError) {

                    var oXML = new tXML()
                    if (oXML.loadXML(response.responseText))
                        var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
                    else
                        var numError = 'OK'
                    alert(numError)
                },
                winPrototype: { modal: true,
                    center: true,
                    bloquear: false,
                    url: 'enBlanco.htm',
                    title: '<b>Transferencia</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 1000,
                    height: 400,
                    resizable: true,
                    destroyOnClose: true

                }
            })
        }
        function transf_ej4() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = ''
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                formTarget: 'iframe1',
                salida_tipo: 'estado'
                                    , metodo: "HTTPRequest"
                                    , async: true
                                    , funComplete: function (response, parseError) {

                                        var oXML = new tXML()
                                        if (oXML.loadXML(response.responseText))
                                            var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
                                        else
                                            var numError = -1
                                        alert(numError)
                                    }
            })
            alert('Asíncrono')
        }

        function transf_ej5() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = ''
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                formTarget: 'iframe1',
                salida_tipo: 'estado'
                                    , metodo: "HTTPRequest"
                                    , async: false
                                    , funComplete: function (response, parseError) {

                                        var oXML = new tXML()
                                        if (oXML.loadXML(response.responseText))
                                            var numError = numError = oXML.selectSingleNode("//@numError").nodeValue
                                        else
                                            var numError = -1
                                        alert(numError)
                                    }
            })
            alert('Síncrono')
        }

        function transf_ej6() {
            var id_transferencia = 4
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = ''
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                formTarget: 'iframe1',
                salida_tipo: 'html'
            })
        }


        function transf_ej7() {
            var id_transferencia = 19
            var nro_banco = ''
            var nro_mutual = ''
            var strXML_parm = '<parametros><nro_banco>190</nro_banco><nro_mutual>403</nro_mutual><fecha>01/12/2016</fecha></parametros>'
            nvFW.transferenciaEjecutar({ id_transferencia: id_transferencia,
                xml_param: strXML_parm,
                pasada: 0,
                salida_tipo: 'html',
                formTarget: 'iframe1'
            })

        }


        function tRS_01() 
          {
          //Utiliza el parametro de pagina que pasó arriba
          var rs = new tRS()
          var filtroXML = nvFW.pageContents.filtroPrueba
          var filtroWhere = "<criterio><select top='1'></select></criterio>"
          var params = "<criterio><params estado=\"'A'\" /></criterio>"
          rs.open(filtroXML, '', filtroWhere, '', params)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }

        function tRS_02() 
          {
          //Utiliza el parametro de pagina que pasó arriba
          var rs = new tRS()
          var filtroXML = nvFW.pageContents.filtroPrueba
          var filtroWhere = "<estado type='igual'>%estado%</estado>"
          var params = "<criterio><params estado=\"'A'\" /></criterio>"
          rs.open(filtroXML, '', filtroWhere, '', params)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }

        function tRS_03() 
          {
          var rs = new tRS()
          var filtroXML = "<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }

       function tRS_04() 
          {
          var filtroXML = "<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>"
          var rs = new tRS()
          rs.async = true
          rs.onComplete = function(rs)
                            {
                            var str = ""
                            while (!rs.eof())
                              {
                              str += rs.getdata("estado") + "\n"
                              rs.movenext()
                              }
           
                            alert(str + "\nCantidad de registros: " + rs.recordcount)
                            }
          rs.open(filtroXML)
          }

      function tRS_abrir()
        {
        var win = nvFW.createWindow({url: "prueba_tRS.aspx"})
        win.show()
        }
      
      function Campo_def_abrir()
        {
        var win = nvFW.createWindow({url: "prueba_campo_def.aspx", width: "900"})
        win.show()
        }

      function Campo_def_validacion_abrir()
        {
        var win = nvFW.createWindow({url: "prueba_campo_def_validacion.aspx", width: "900"})
        win.show()
        }
        

      function XSL_abrir()
        {
        var win = nvFW.createWindow({url: "prueba_XSL.aspx", width: "900"})
        win.show()
        } 

    function tree_definicion()
       {
       $("iframe1").src = "/eliminar/prueba_tTree10.aspx"
       }

    function tree_db()
       {
       $("iframe1").src = "/eliminar/prueba_tTree11.aspx"
       } 

    
    function firma()
       {
       $("iframe1").src = "/eliminar/prueba_firma.aspx"
       } 

    function legajo()
       {
       $("iframe1").src = "/eliminar/prueba_legajos.aspx"
       } 

    function Identity()
       {
       $("iframe1").src = "/eliminar/prueba_identity.aspx"
       } 

    function nvTCPListener()
       {
       $("iframe1").src = "/eliminar/prueba_nvTCPListener.aspx"
       } 

   function DAD_abrir()
     {
     $("iframe1").src = "/eliminar/prueba_DAD.aspx"
     }
        
    
     function campos_def_abm()
        {
        
        //var hash = nvFW.get_hash()
        //debugger
        //debugger
        //top.nvFW.alert("Hola <b>mundo</b>", {title:"algo", okLabel:"boton"}) 
        //nvFW.alert("Hola  2 <b>mundo</b>", {title:"algo", okLabel:"boton"}) 

        
        //nvFW.confirm("¿Desea continuar?", {title:"algo", onOk: function () {nvFW.alert("OK")}, onCancel:function(){nvFW.alert("NO")} }) 

         //tXML

        // var oXML = new tXML()
         
        // oXML.load(url, options)
        // oXML.loadXML(cadena, options)

        // //oXML.xml document del DOM

        // strXML = oXML.toString()  //XMLtoString(oXML.xml)

        // oXML.async = true
        // oXML.method = [POST|GET]

        // var node = oXML.selectSingleNode("nodos\node")
        // var propiedad = selectNodes("@propiedad", node)   //var node = oXML.selectSingleNode("nodos/node/@propiedad")

        // oXML.selectNodes("path")

        // oXML.getElementsByTagName("nodo")

         

        // var miXML = XMLDoc()
        // var strXML = XMLtoString(miXML)
        // var strXML = miXML.xml

        // //recuperar el texto de un nodo
        // var str = XMLText(nodo)

        // var strXML = "<nodos><nodo id='i' descripcion='" + stringToXMLAttributeString("Esto en el nodo '1'") + "'></nodo></nodos>"

   
        //return
        var win = top.nvFW.createWindow({url: "/FW/campo_def/campos_def_listar.aspx", width: "1100", height: "400", top:"50" })
        win.showCenter(true)
        }    
        
     function  eventos_mouse()
       {
       var win = top.nvFW.createWindow({url: "../eliminar/eventos_mouse.aspx", width: "1100", height: "400", top:"50" })
        win.showCenter(true)
       }

    function  prueba_chart()
       {
       var win = top.nvFW.createWindow({url: "../eliminar/prueba_chart.aspx", width: "1300", height: "800", top:"50" })
        win.showCenter(true)
       }

     function  prueba_chart2()
       {
       var win = top.nvFW.createWindow({url: "../eliminar/prueba_chart2.aspx", width: "1300", height: "800", top:"50" })
        win.showCenter(true)
       }

     function  prueba_notify()
       {
       var win = top.nvFW.createWindow({url: "../eliminar/prueba_notify.aspx", width: "800", height: "600", top:"50" })
        win.showCenter(true)
       }

     function  prueba_file_upload()
       {
       var win = top.nvFW.createWindow({url: "../eliminar/prueba_file_upload.aspx", width: "800", height: "600", top:"50" })
        win.showCenter(true)
       }


     function prueba_getFiltroWhere()         
        {
        var win = top.nvFW.createWindow({url: "../eliminar/prueba_getFiltroWhere.aspx", width: "800", height: "600", top:"50" })
        win.showCenter(true) 
        }
        
    </script>
    <script type="text/javascript">

        function window_onresize() {
            var iframe = $('iframe1')
            var body = $$('BODY')[0]
            var l = body.getHeight() - iframe.cumulativeOffset().top
            if (l > 0)
                iframe.setStyle({ height: l + 'px' })


        }
   
   function XMLHTTPRequest_cache()
     {
     nvFW_chargeJSifNotExist("tnvCache", '/FW/script/tnvCache.js')
     }

     function XMLHTTPRequest_nvFW()
     {
     var jsURL = '/FW/script/nvFW.js'
     var xmlHttp = XMLHttpObject()
     try
       {
       xmlHttp.open("GET", jsURL, false)
       xmlHttp.setRequestHeader("cache-control", "public");
       xmlHttp.send()
       var code = xmlHttp.responseText
       nvFW.alert(code)
       }
     catch(e)
       {
       nvFW.alert("No se puede cargar el archivo '" + jsURL + "'")
       return
       }
     //nvFW_chargeJSifNotExist("tnvCache2", '/FW/script/tnvCache.js')
     }

   function file_base64()
     {
     debugger
     strHTML = "<script id='miScript' type='text/javascript' src='data:application/x-javascript;base64," + nvFW.pageContents.fileBase64 + "'><" + "/script>"
     var body = $$("BODY")[0]
     body.insertAdjacentHTML("afterBegin", strHTML) 
     var miScript = $("miScript") 
     }

    </script>

  <script type="text/javascript">
      var activado = false
      var paso = 0
      var oDIV
      $(document).observe("click", function(e)
                                           {
                                           if (!e.ctrlKey) return
                                           switch (paso)
                                             {
                                             case 0:
                                               oDIV = nvFW.bloqueo_activar("iframe1", "asasas1", "Buscando bases externas...")
                                               paso++
                                               break
                                             case 1:
                                               oDIV._DivMsg.innerHTML =  "Buscando internas..."
                                               paso++
                                               break
                                             case 2:
                                               nvFW.bloqueo_msg("asasas1", "Hola Mundo 3")
                                               paso++
                                               break
                                             case 3:
                                               nvFW.bloqueo_desactivar("iframe1", "asasas1")
                                               paso = 0
                                               break  
                                             }
                                          })

  
  function prueba_carga_script()
    {
     var xmlHttp = new XMLHttpRequest()
     xmlHttp.open("GET", 'JavaScript.js', false)
     xmlHttp.send()
     code = xmlHttp.responseText
     alert(code)

    }

function prueba_carga_simultanea()
  {
  var win = nvFW.createWindow({url: "prueba_carga_simultanea.aspx",
                               width: "1200px",
                               height: "800px"})
  win.showCenter()
  }

function prueba_nova_proxy()
  {
  var win = nvFW.createWindow({url: "prueba_nova_proxy.aspx",
                               width: "800px",
                               height: "500px"})
  win.showCenter()
  }

function prueba_mover_datos()
  {
  var win = nvFW.createWindow({url: "prueba_mover_datos.aspx",
                               width: "800px",
                               height: "500px"})
  win.showCenter()
  }
    
      

  function window_onload()
    {
      
      
      

    var a  = new Date(Date.parse('12/30/1980 00:00:00'))
    //window_onresize() 
    //document.onclick = function () {
    //    debugger 
    //    document.execCommand('copy');
    }

  // document.addEventListener('copy', function (e) 
  //                                     {
  //                                     debugger 
  //                                     e.preventDefault();
  //                                     if (e.clipboardData) 
  //                                       {
  //                                       e.clipboardData.setData('text/plain', 'Mi texto copiado');
  //                                       } 
  //                                     else 
  //                                         if (window.clipboardData) 
  //                                           {
  //                                           window.clipboardData.setData('Text', 'Mi texto copiado');
  //                                           }
  //                                     });
  //document.addEventListener('paste', function (e) 
  //                                       {
  //                                       debugger 
  //                                       e.preventDefault();
  //                                       if (e.clipboardData)
  //                                         {
  //                                         Event.element(e).value = e.clipboardData.getData('text/plain');
  //                                         }
  //                                       else 
  //                                          if (window.clipboardData) 
  //                                          {
  //                                          Event.element(e).value = window.clipboardData.getData('Text');
  //                                          }  
   
  //                                      });
         
  //  }   
    
  </script>

</head>
<body  style="width: 100%; height: 100%; overflow: auto" onload="return window_onload()"    onresize="return window_onresize()">
    <form name="pruebas" action="" method="GET" style="width: 100%">
    <input type="text" />
    <table class="tb1">
        <tr class="tbLabel0">
            <td>
                Ejemplos de Exportar Reporte
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Exp. Ej 01" onclick="return exportar_ej1()" title="Exportacion a html. Destino un IFRAME" />
                <input type="button" value="Exp. Ej 02" onclick="return exportar_ej2()" title="Exportacion a excel. Destino un IFRAME" />
                <input type="button" value="Exp. Ej 03" onclick="return exportar_ej3()" title="Exportacion a excel. Destino una nueva ventana" />
                <input type="button" value="Exp. Ej 04" onclick="return exportar_ej4()" title="Exportacion a HTML guardando el archivo en disco. Informa en el iframe el resultado" />
                <input type="button" value="Exp. Ej 05" onclick="return exportar_ej5()" title="Exportacion a HTML guardando el archivo en disco. Informa en el iframe el resultado. Utiliza funComplete para analizar el resultado" />
                <input type="button" value="Exp. Ej 06" onclick="return exportar_ej6()" title="Idem Ej 05 pero con metodo HTTPRequest síncono" />
                <input type="button" value="Exp. Ej 07" onclick="return exportar_ej7()" title="Idem Ej 05 pero con metodo HTTPRequest asíncono" />
                <input type="button" value="Exp. Ej 08" onclick="return exportar_ej8()" title="Idem Ej 05 pero con metodo HTTPRequest asíncono y bloqueda el iframe" />
                <input type="button" value="Exp. Ej 09" onclick="return exportar_ej9()" title="Exportacion a HTML guardando el archivo en disco. Mustra el documento en un iframe. bloq_contenedor y cls_contenedor" />
                <input type="button" value="Exp. Ej 10" onclick="return exportar_ej10()" title="Exportacion a HTML. Muestra el documento en una ventana nueva. 'cls_contenedor'" />
                <input type="button" value="Exp. Ej 11" onclick="return exportar_ej11()" title="Exportacion a HTML, muetra el resultado en una ventana Prototype" />
                <input type="button" value="Exp. Ej 12" onclick="return exportar_ej12()" title="Exportacion a EXCEL por RSXMLtoExcel. Guarda a un archivo" />
                <input type="button" value="Exp. Ej 13" onclick="return exportar_ej13()" title="Exportacion a EXCEL por RSXMLtoExcel. Devolver adjunto" />
                <input type="button" value="Exp. Ej 14" onclick="return exportar_ej14()" title="Exportacion a HTML con paginación y guarda la info en el nvFW" />
                <input type="button" value="Exp. Ej 15" onclick="return exportar_ej15()" title="Exportacion a HTML con paginación y guarda la info en la db" />
                <input type="button" value="Exp. Ej 16" onclick="return exportar_ej16()" title="Exportacion a HTML con paginación y guarda la info en el nvFW y con cache" />
                <input type="button" value="Exp. Ej 17" onclick="return exportar_ej17()" title="Exportacion a HTML desde un StoreProcedure" />
                <input type="button" value="Exp. Ej 18" onclick="return exportar_ej18()" title="Exportacion a EXCEL por RSXMLtoExcel. Guarda a un archivo en la carpera definida como raiz" />
                <input type="button" value="Exp. Ej 19" onclick="return exportar_ej19()" title="Llamada al exportar encriptada" />
                <input type="button" value="Exp. Ej 20" onclick="return exportar_ej20()" title="Exportar a CSV" />
                
            </td>
        </tr>
        <tr class="tbLabel0">
            <td>
                Ejemplos de Mostrar Reporte
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Mostrar Ej 01" onclick="return mostrar_ej1()" title="Exportacion a PDF. Destino un IFRAME" />
                <input type="button" value="Mostrar Ej 02" onclick="return mostrar_ej2()" title="Exportacion a excel. Destino un IFRAME" />
                <input type="button" value="Mostrar Ej 03" onclick="return mostrar_ej3()" title="Exportacion a Crystal. Destino una nueva ventana" />
                <input type="button" value="Mostrar Ej 04" onclick="return mostrar_ej4()" title="Exportacion a PDF guardando el archivo en disco. Informa en el iframe el resultado de la exportación" />
                <input type="button" value="Mostrar Ej 05" onclick="return mostrar_ej5()" title="Exportacion a PDF guardando el archivo en disco. Informa en el iframe el resultado. Utiliza funComplete para analizar el resultado" />
                <input type="button" value="Mostrar Ej 06" onclick="return mostrar_ej6()" title="Idem Ej 05 pero con metodo HTTPRequest síncono" />
                <input type="button" value="Mostrar Ej 07" onclick="return mostrar_ej7()" title="Idem Ej 05 pero con metodo HTTPRequest asíncono" />
                <input type="button" value="Mostrar Ej 08" onclick="return mostrar_ej8()" title="" />
                <input type="button" value="Mostrar Ej 09" onclick="return mostrar_ej9()" title="" />
                <input type="button" value="Mostrar Ej 10" onclick="return mostrar_ej10()" title="" />
                <input type="button" value="Mostrar Ej 11" onclick="return mostrar_ej11()" title="" />
                <input type="button" value="Mostrar Ej 12" onclick="return mostrar_ej12()" title="" />
                <input type="button" value="Mostrar Ej 13" onclick="return mostrar_ej13()" title="Mostrar reporte con valores encriptados" />
            </td>
        </tr>
        <tr class="tbLabel0">
            <td>
                Ejemplos de Transferencia Ejecutar
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Transf Ej 01" onclick="return transf_ej1()" title="Transferencia ejecutar en un IFRAME" />
                <input type="button" value="Transf Ej 02" onclick="return transf_ej2()" title="Transferencia ejecutar en una ventana nueva" />
                <input type="button" value="Transf Ej 03" onclick="return transf_ej3()" title="Transferencia ejecutar en una ventana prototype" />
                <input type="button" value="Transf Ej 04" onclick="return transf_ej4()" title="httprequest asincrono" />
                <input type="button" value="Transf Ej 05" onclick="return transf_ej5()" title="httprequest sincrono" />
                <input type="button" value="Transf Ej 06" onclick="return transf_ej6()" title="Mostrar el estado en un iframe" />
                <input type="button" value="Transf Ej 07" onclick="return transf_ej7()" title="Transferencia ejecutar en un IFRAME. Con parametros" />
            </td>
        </tr>
        <tr class="tbLabel0">
            <td>
                Ejemplos otros
            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="Abrir ejemplos tRS" onclick="return tRS_abrir()" />
                <input type="button" value="Abrir ejemplos Campo_def" onclick="return Campo_def_abrir()"  style="width: 200px"/>
                <input type="button" value="Abrir Campo_def validación" onclick="return Campo_def_validacion_abrir()"  style="width: 200px"/>
                <input type="button" value="Abrir ejemplos XSL" onclick="return XSL_abrir()"  style="width: 200px"/>
                <input type="button" value="Abrir ejemplos Imput Drop" onclick="return DAD_abrir()"  style="width: 200px"/>
            </td>
        </tr>
        <tr>
            <td><input type="button" value="tree_definicion" onclick="return tree_definicion()"  style="width: 200px"/>
                <input type="button" value="Prueba file base64" onclick="return file_base64()"  style="width: 200px"/>

            </td>
        </tr>
        <tr>
            <td>
                <input type="button" value="tree_db" onclick="return tree_db()" style="width: 200px" />
                <input type="button" value="Firma" onclick="return firma()" style="width: 200px" />
                <input type="button" value="Legajo" onclick="return legajo()" style="width: 200px" />
                <input type="button" value="Indentity" onclick="return Identity()" style="width: 200px" />
                <input type="button" value="nvTCPListener" onclick="return nvTCPListener()" style="width: 200px" />
                <input type="button" value="ABM Campo_def " onclick="return campos_def_abm()" style="width: 200px" />
                <input type="button" value="Eventos de mouse y teclado" onclick="return eventos_mouse()" style="width: 200px" />
                <input type="button" value="XMLHTTPRequest cache" onclick="return XMLHTTPRequest_cache()" style="width: 200px" />
                <input type="button" value="XMLHTTPRequest nvFW" onclick="return XMLHTTPRequest_nvFW()" style="width: 200px" />
                <input type="button" value="Prueba chart" onclick="prueba_chart()" style="width: 200px" />
                <input type="button" value="Prueba chart2" onclick="prueba_chart2()" style="width: 200px" />
                <input type="button" value="Prueba Notificación" onclick="prueba_notify()" style="width: 200px" />
                <input type="button" value="Prueba file upload" onclick="prueba_file_upload()" style="width: 200px" />
                <input type="button" value="Prueba carga script" onclick="prueba_carga_script()" style="width: 200px" />
                <input type="button" value="Prueba carga simultanea EnableSessionState='readOnly'" onclick="prueba_carga_simultanea()" style="width: 200px" />
                <input type="button" value="Prueba campodef getFiltroWhere" onclick="prueba_getFiltroWhere()" style="width: 200px" />
                <input type="button" value="Prueba Nova Proxy" onclick="prueba_nova_proxy()" style="width: 200px" />
                <input type="button" value="Prueba Mover Datos" onclick="prueba_mover_datos()" style="width: 200px" />
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr class="tbLabel0">
            <td>
                Ejemplos de campo_def
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width:50%" >
               <%= nvFW.nvCampo_def.get_html_input("campo_def")%>
            </td>
            <td style="25%" >
               <%= nvFW.nvCampo_def.get_html_input("id_param")%>
            </td>
            <td style="" >
               <%= nvFW.nvCampo_def.get_html_input("nro_login2")%>
            </td>
            <td style="" >
               <%
                   Dim miCampo_def As New nvFW.tnvCampo_def
                   miCampo_def.campo_def = "miCampo_def"
                   miCampo_def.nro_campo_tipo = 1
                   miCampo_def.filtroXML = "<criterio><select vista='campos_def'><campos> distinct campo_def as id, descripcion as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>"
                   Response.Write(miCampo_def.get_html_input())
                   
                   %>
            </td>

            <td style="" >
               <%= nvFW.nvCampo_def.get_html_input("nro_login3", enDB:=False, filtroXML:="<criterio><select vista='campos_def'><campos> distinct campo_def as id, descripcion as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>")%>
            </td>
        </tr>
        <tr>
        <td><%= nvFW.nvCampo_def.get_html_input("nro_com_grupo")%></td>
        <td><%= nvFW.nvCampo_def.get_html_input("nro_com_tipo")%></td>
        <td><script type="text/javascript">
           campos_defs.add('miCampo', {nro_campo_tipo:1, enDB: false, filtroXML: nvFW.pageContents.filtroXMLmiCampo})
        </script> </td>
        </tr>
    </table>
    </form>
    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="PruebaCSS_Tabla.aspx"></iframe>
    <!--<iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="prueba_compatibilidad.aspx"></iframe>-->
</body>
</html>
