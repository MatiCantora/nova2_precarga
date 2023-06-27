<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_ref As String = nvFW.nvUtiles.obtenerValor("nro_ref", "")
    Dim nro_ref_doc As String = nvFW.nvUtiles.obtenerValor("nro_ref_doc", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Me.contents("filtroBusqVersion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_doc_versiones'><campos>*</campos><orden>nro_ref_doc,ref_doc_version desc, doc_orden, ref_doc_fe_estado</orden><filtro></filtro><grupo></grupo></select></criterio>")
    Me.contents("filtroCargarVersion") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>nro_ref_doc,ref_doc_version desc, doc_orden, ref_doc_fe_estado</orden><filtro></filtro><grupo></grupo></select></criterio>")

    If (modo.ToUpper = "M") Then
        Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
        Dim err = New nvFW.tError()
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_ref_doc_eliminar", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
            Dim rs As ADODB.Recordset = cmd.Execute()
            err = New nvFW.tError(rs)
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al eliminar la versión"
            err.mensaje = "No se actualizaron los datos. " & vbCrLf & err.mensaje
        End Try
        err.response()
    End If
%>
<html>
<head>
    <title>Búsqueda de Versiones</title>

    <meta name="Buscar versión" content="Microsoft Visual Studio 6.0" />
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/fw/css/calendar/css/jscal2.css" type="text/css" rel="stylesheet"  />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_basicControls.js"></script>    
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">
        var version_todas = new Array(),
            win = nvFW.getMyWindow(),
            parametros = new Array()

        function window_onresize()
        {
            try 
            {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_heigth = $$('body')[0].getHeight(),
                    cab_heigth = $('tbFiltro').getHeight()

                $('iframe_version').setStyle({ 'height': body_heigth - cab_heigth - dif })
            }
            catch(e) {}
        }

        function window_onload() 
        {
            buscar_versiones() 
            window_onresize()
        }

        function buscar_versiones() 
        {
            var strXML = ''
            if ($('nro_ref').value != "")
                strXML += "<nro_ref type='igual'>" + $('nro_ref').value + "</nro_ref>"

            if ($('nro_ref_doc').value != "")
                strXML += "<nro_ref_doc type='igual'>" + $('nro_ref_doc').value + "</nro_ref_doc>"

            var filtroXML = nvFW.pageContents.filtroBusqVersion
            var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro>" + strXML + "</filtro><grupo></grupo></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: filtroWhere,
                path_xsl: "report\\verRef_doc_versiones\\HTML_ref_doc_versiones.xsl",
                formTarget: 'iframe_version',
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $('iframe_version'),
                cls_contenedor: 'iframe_version'
            })
        }

        /***    Muestra en una nueva ventana, el contenido de la versión seleccionada de un documento de una referencia    ***/
        //debugger
        function version_cargar(ref_doc_version, nro_ref_doc, nro_ref)
        {
            var filtroXML = nvFW.pageContents.filtroCargarVersion
            var filtroWhere = "<criterio><select ><campos>*</campos><orden></orden><filtro><ref_doc_version type='igual'>" + ref_doc_version + "</ref_doc_version><nro_ref_doc type='igual'>" + nro_ref_doc + "</nro_ref_doc><nro_ref type='igual'>" + nro_ref + "</nro_ref></filtro><grupo></grupo></select></criterio>"
            
            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: filtroWhere,
                path_xsl: "report\\verRef_docs\\HTML_ref_doc_datos.xsl",
                formTarget: '_blank'
            })
        }

        /*** Elimina todas las versiones seleccionadas de un documento de una referencia ***/
        function eliminar()
        {
            if (version_todas['version'].length > 0) 
            {   
                xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?>"
                xmldato += "<ref_docs nro_ref ='" + version_todas['nro_ref'] + "'>"
                xmldato += "<versiones>"
                
                version_todas['version'].each(function(arreglo_p, index_p) {
                    xmldato += "<version ref_doc_version='" + arreglo_p['nro_version'] + "' nro_ref_doc='" + arreglo_p['nro_doc'] + "'/>"
                });
                
                xmldato += "</versiones>"
                xmldato += "</ref_docs>"
                nvFW.error_ajax_request('version_buscar.aspx', {
                    parameters: {
                        modo: 'M',
                        strXML: xmldato
                    },
                    onSuccess: function (err, transport) {
                          window_onload()
                    }
                });
            }
            else
            {
                alert('No seleccionó versiones del documento a eliminar.')
            }                               
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width:100%;height: 100%; overflow: auto">
    <div id="tbFiltro" style="width:100%">
        <input type="hidden" name="nro_ref" id="nro_ref" value="<%= nro_ref %>"/>
        <input type="hidden" name="nro_ref_doc" id="nro_ref_doc" value="<%= nro_ref_doc %>"/>
        
        <div id="divMenuDatos" style="margin: 0px; padding: 0px"></div>

        <script type="text/javascript">
	        var DocumentMNG = new tDMOffLine;
	        var vMenuDatos = new tMenu('divMenuDatos', 'vMenuDatos');
	        vMenuDatos.loadImage("eliminar","/fw/image/icons/eliminar.png")
	        Menus["vMenuDatos"] = vMenuDatos
	        Menus["vMenuDatos"].alineacion = 'centro';
	        Menus["vMenuDatos"].estilo = 'A';
	        Menus["vMenuDatos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
	        Menus["vMenuDatos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 70%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
	        vMenuDatos.MostrarMenu()
	    </script>

    </div>
    <iframe name="iframe_version" id="iframe_version" style="width:100%; height:100%; overflow:auto" frameborder="0" src="/wiki/enBlanco.htm"></iframe>
</body>
</html>
