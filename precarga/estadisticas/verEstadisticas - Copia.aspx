<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador As Integer = op.operador

    ' Si no tiene los permisos necesarios, no lo dejo seguir
    If (Not op.tienePermiso("permisos_precarga", 16)) Then

        Response.Redirect("/FW/error/httpError_401.aspx")

    End If

    'Dim rs
    'Dim err As New tError()

    'Try

    '    rs = nvDBUtiles.DBOpenRecordset("select id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen from [horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1 where fe_inicio >= dbo.finac_inicio_mes(getdate()) and operador_det = " & nro_operador)

    '    If (Not rs.EOF) Then

    '        Dim id_calificacion As String = rs.Fields("id_calificacion").Value
    '        Dim fecha As String = rs.Fields("fecha").Value
    '        Dim cuil As String = rs.Fields("cuil").Value
    '        Dim nro_docu As String = rs.Fields("nro_docu").Value
    '        Dim apellido As String = rs.Fields("apellido").Value
    '        Dim nombres As String = rs.Fields("nombres").Value
    '        Dim dictamen As String = rs.Fields("dictamen").Value

    '    End If

    '    nvDBUtiles.DBCloseRecordset(rs)

    '    Me.contents("id_calificacion") = id_calificacion
    '    Me.contents("fecha") = fecha
    '    Me.contents("cuil") = cuil
    '    Me.contents("nro_docu") = nro_docu
    '    Me.contents("apellido") = apellido
    '    Me.contents("nombres") = nombres
    '    Me.contents("dictamen") = dictamen

    'Catch ex As Exception
    '    err.numError = -1
    '    err.mensaje = ex.Message
    '    err.debug_desc = ex.Message
    '    err.titulo = "Error"
    'End Try

    Me.contents("statType") = nvFW.nvUtiles.obtenerValor("type", "")
    Me.contents("nro_operador") = nro_operador

    'select id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen from [horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1 where fe_inicio >= dbo.finac_inicio_mes(getdate()) and operador_det = 
    Me.contents("filtro_verEstadisticas_consultas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>id_transf_log as id_calificacion, fe_inicio as fecha, cuil, nro_docu, apellido, nombres, dictamen, explicacion</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtro_verEstadisticas_consultas2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='[horus.redmutual.com.ar].onboardingDigitalDW.dbo.ds_santa_fe_calificacion_v1' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>id_calificacion, fe_inicio as fecha, nro_docu, apellido + ', ' + nombres as razon_social, dictamen, explicacion</campos><orden></orden><filtro></filtro></select></criterio>")

    'select * from VerAutogestion_creditos where fe_inicio >= dbo.finac_inicio_mes(getdate()) and nro_operador = 12872
    Me.contents("filtro_verEstadisticas_creditos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerAutogestion_creditos' PageSize='20' AbsolutePage='1' cacheControl='Session'><campos>nro_docu, razon_social, banco, mutual, estado, descripcion_estado, fecha, importe_retirado, importe_solicitado</campos><orden></orden><filtro></filtro></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="initial-scale=1">
    <title>Precarga - Seleccionar Vendedor</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>
    <style type="text/css">
        .filtro {
            -moz-border-radius: 0.33em;
            box-shadow: 0 0 1px #f4f4f4;
            text-align: left;
            height: 21px;
            width:50%;
            margin-bottom: 0.66em;
        }
            .filtro div{
            border-radius: 0.33em; 
            height: 1.5em;
            display: flex;
            justify-content: center;
            align-content: center;
            flex-direction: column;
            padding: 0px 0.35em 0px 0.35em;
        }

        @media screen and (max-width: 580px) {
            .filtro {
                width:100%
            }
        }
        
    </style>
    <script type="text/javascript">

        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        let numOperador = nvFW.pageContents["nro_operador"];
        //let numOperador = 132;
        let tipoEstadistica = nvFW.pageContents.statType; // Consultas o Creditos

        var win = nvFW.getMyWindow()
        /*
        let id_calificacion = nvFW.pageContents.id_calificacion;
        let fecha = nvFW.pageContents.fecha;
        let cuil = nvFW.pageContents.cuil;
        let nro_docu = nvFW.pageContents.nro_docu;
        let apellido = nvFW.pageContents.apellido;
        let nombres = nvFW.pageContents.nombres;
        let dictamen = nvFW.pageContents.dictamen;
        */

        function window_onload() {

            cargarEstadisticasConsultas();

            window_onresize();
        }

        function cargarEstadisticasConsultas() {

            let filtro_XML, archivo_XSL, filtro = "", cargarOK = true;

            filtro += "<fe_inicio type='mas'>dbo.finac_inicio_mes(getdate())</fe_inicio>";

            switch (tipoEstadistica) {

                case "Consultas":
                    archivo_XSL = "HTML_consultas.xsl";
                    //filtro_XML = nvFW.pageContents.filtro_verEstadisticas_consultas;
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_consultas2;
                    filtro += "<operador_det type='igual'>'" + numOperador + "'</operador_det>";

                    break;

                case "Liquidados":

                    archivo_XSL = "HTML_creditos.xsl";
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_creditos;
                    filtro += "<nro_operador type='igual'>'" + numOperador + "'</nro_operador>";
                    filtro += "<estado type='in'>'E','T'</estado>";

                    break;

                case "Gestion":

                    archivo_XSL = "HTML_creditos.xsl";
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_creditos;
                    filtro += "<nro_operador type='igual'>'" + numOperador + "'</nro_operador>";
                    filtro += "<estado type='in'>'1','2','4','A','H','L','M','Z','U','Q'</estado>";

                    break;

                default:
                    cargarOK = false;
                    break;
            }

            if (!cargarOK) {
                alert("Error al cargar los datos.");
                return;
            }

            nvFW.exportarReporte({
                filtroXML: filtro_XML,
                path_xsl: '/report/verEstadisticas/' + archivo_XSL,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                formTarget: 'iframe_stats',
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $$('body')[0],
                cls_contenedor: 'iframe_stats'
            })
        }

        function window_onresize() {

            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                cab_height = $('tbFiltro').getHeight()              
                $('iframe_vendedores').setStyle({ height: body_height - cab_height - dif + 'px' })
              
            }
            catch (e) { }
        }

        /*
        // Esta funcion anda bien, nomas que pidieron sacar el boton de exportar.
        function exportarDatos() {

            let filtro_XML, archivo_XSL = "", filtro = "", nombreArchivo = "", exportarOK = true;

            filtro += "<fe_inicio type='mas'>dbo.finac_inicio_mes(getdate())</fe_inicio>";

            switch(tipoEstadistica) {

                case "Consultas":
                    archivo_XSL = "HTML_consultas.xsl";
                    nombreArchivo = "consultas_mensuales";
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_consultas;
                    filtro += "<operador_det type='igual'>'" + numOperador + "'</operador_det>";
                    
                    break;

                case "Liquidados":

                    archivo_XSL = "HTML_creditos.xsl";
                    nombreArchivo = "creditos_mensuales";
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_creditos;
                    filtro += "<nro_operador type='igual'>'" + numOperador + "'</nro_operador>";
                    filtro += "<estado type='in'>'E','T'</estado>";

                    break;

                case "Gestion":

                    archivo_XSL = "HTML_creditos.xsl";
                    nombreArchivo = "creditos_mensuales";
                    filtro_XML = nvFW.pageContents.filtro_verEstadisticas_creditos;
                    filtro += "<nro_operador type='igual'>'" + numOperador + "'</nro_operador>";
                    filtro += "<estado type='in'>'1','2','4','A','H','L','M','Z','U','Q'</estado>";

                    break;

                default:
                    exportarOK = false;
                    break;
            }

            if (!exportarOK) {
                alert("Error al exportar.");
                return;
            }

            //let nombre = ""
            //let strHTML = "<br/><table class='tb1'><tr><td nowrap>Exportar el listado con el siguiente nombre: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td><input type='text' id='filename' value='" + nombre + "' style='width:100%;text-align:right' /></td></tr></table>"

            nvFW.exportarReporte({
                filtroXML: filtro_XML,
                filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                formTarget: "_blank",
                filename: nombreArchivo + ".xls",
                export_exeption: "RSXMLtoExcel",
                content_disposition: "attachment",
                requestMethod: "GET"
            })
        }
        */

</script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <div id="divMenuVerEstadisticas" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">

        var vMenuVerEstadisticas = new tMenu('divMenuVerEstadisticas', 'vMenuVerEstadisticas');

        Menus["vMenuVerEstadisticas"] = vMenuVerEstadisticas
        Menus["vMenuVerEstadisticas"].alineacion = 'centro';
        Menus["vMenuVerEstadisticas"].estilo = 'A';
        //Menus["vMenuVerEstadisticas"].imagenes = Imagenes //Imagenes se declara en pvUtiles

        vMenuVerEstadisticas.loadImage("excel", "/FW/image/icons/excel.png");

        Menus["vMenuVerEstadisticas"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        //Menus["vMenuVerEstadisticas"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar listado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarDatos()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuVerEstadisticas.MostrarMenu();
    </script>

    <iframe name="iframe_stats" id="iframe_stats" style='width: 100%; height: 100%; overflow: auto; border: none' frameborder="0" src="/fw/enBlanco.htm"></iframe> 

</body>
</html>
