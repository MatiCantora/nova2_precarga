<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_archivo_def_tipo As String = nvFW.nvUtiles.obtenerValor("nro_archivo_def_tipo", "-1")
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "VA"
    End If
    
    Dim filtroTipo = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_tipo'><campos>nro_archivo_def_tipo,archivo_def_tipo</campos><filtro><nro_archivo_def_tipo type='igual'>%nro_archivo_def_tipo%</nro_archivo_def_tipo></filtro></select></criterio>")
    Dim filtroExiste = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_tipo'><campos>*</campos><filtro><archivo_def_tipo type='igual'>%archivo_def_tipo%</archivo_def_tipo></filtro></select></criterio>")
    
    Dim strXML = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""))
    Dim err = New nvFW.tError()
    
    If (modo.ToUpper <> "VA") Then
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "archivos_def_tipo_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML
                    
            Dim rs = Cmd.Execute()
                    
            err.params.Add("nro_archivo_def_tipo", rs.Fields("nro_archivo_def_tipo").Value)
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

            rs.close()
                    
        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al guardar información de Perfiles."
            err.mensaje = "No se actualizaron los datos." & vbCrLf & err.mensaje
        End Try
    
        err.response()
    End If
 
%>

<html>
<head>
    <title>Tipos de Archivos ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var filtroTipo = '<%= filtroTipo %>'
        var filtroExiste = '<%= filtroExiste %>'

    var win = nvFW.getMyWindow() 

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefTipoABM_h = $('divMenuArchivosDefTipoABM').getHeight()
            tb_archivos_def_tipo_h = $('tb_archivos_def_tipo').getHeight()
            $('iframe_archivos_def_tipo').setStyle({ 'height': body_height - divMenuArchivosDefTipoABM_h - tb_archivos_def_tipo_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        cargar_archivos_def_tipo()
        window_onresize()
    }

    function cargar_archivos_def_tipo() {
        var nro_archivo_def_tipo = $('nro_archivo_def_tipo').value == '' ? -1 : $('nro_archivo_def_tipo').value
        if (nro_archivo_def_tipo == -1) {
            $('modo').value = 'A'
            $('archivo_def_tipo').value = ''
        } else {
            var rs = new tRS()

            var params = "<criterio><params nro_archivo_def_tipo='" + nro_archivo_def_tipo + "'/></criterio>"
            rs.open(filtroTipo, '', '', '', params)

            if (!rs.eof()) {
                $('archivo_def_tipo').value = rs.getdata('archivo_def_tipo') == null ? '' : rs.getdata('archivo_def_tipo')
                $('modo').value = 'M'
            }
        }
    }

    function archivos_def_tipo_abm(nro_archivo_def_tipo) {
        //Nuevo tipo de archivo
        if (nro_archivo_def_tipo == -1) {
            $('modo').value = 'A'
            $('nro_archivo_def_tipo').value = -1
            cargar_archivos_def_tipo()
        }
    }

    function trim(myString) {
        return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
    }


    //Valida y actualiza el Tipo de archivos
    function actualizar_archivos_def_tipo() 
    {
        var nro_archivo_def_tipo = $('nro_archivo_def_tipo').value == '' ? -1 : $('nro_archivo_def_tipo').value

        var modo = $('modo').value
        var archivo_def_tipo = trim($('archivo_def_tipo').value)
        var str_error = ''

        if (archivo_def_tipo == '')
            str_error += 'Debe ingresar una "Descripción" para el Tipo de Archivo</br>';

        if (nro_archivo_def_tipo == -1) {
            var rs = new tRS()

            var params = "<criterio><params archivo_def_tipo='" + archivo_def_tipo + "'/></criterio>"
            rs.open(filtroExiste, '', '', '', params)

            if (!rs.eof())
                str_error += 'Ya existe un Tipo de Archivo con la misma "Descripción"</br>';
        }

        if (str_error != '') {
            alert(str_error)
            return
        }

        archivo_def_tipo = '<![CDATA[' + archivo_def_tipo + ']]>'

        var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmldato += "<archivos_def_tipo modo='" + modo + "' nro_archivo_def_tipo='" + nro_archivo_def_tipo + "'>"
        xmldato += "<archivo_def_tipo>" + archivo_def_tipo + "</archivo_def_tipo>"
        xmldato += "</archivos_def_tipo>"

        nvFW.error_ajax_request('/fw/def_archivos/archivos_def_tipo_ABM.aspx', {
            parameters: { modo: 'M', strXML: escape(xmldato) },
            onSuccess: function (err, transport) {
                if (err.numError == 0) {
                    nro_archivo_def_tipo = err.params['nro_archivo_def_tipo']
                    win.options.userData = { nro_archivo_def_tipo: nro_archivo_def_tipo }
                    win.close()
                }
                else {
                    alert(err.mensaje)
                    return
                }
            }
        });
    }


    </script>
</head>
<body onload="return window_onload()" onresize='window_onresize()' style='width:100%;height:100%;overflow:hidden'>
<form name="frmArchivosDefTipoABM" action="/fw/def_archivos/archivos_def_tipo_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    <input type="hidden" name="modo" id="modo" value="<%= modo %>" />

        <div id="divMenuArchivosDefTipoABM" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var vMenuArchivosDefTipoABM = new tMenu('divMenuArchivosDefTipoABM', 'vMenuArchivosDefTipoABM');
            vMenuArchivosDefTipoABM.loadImage("guardar", "/fw/image/icons/guardar.png")
            vMenuArchivosDefTipoABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
            Menus["vMenuArchivosDefTipoABM"] = vMenuArchivosDefTipoABM
            Menus["vMenuArchivosDefTipoABM"].alineacion = 'centro';
            Menus["vMenuArchivosDefTipoABM"].estilo = 'A';
            Menus["vMenuArchivosDefTipoABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar_archivos_def_tipo()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuArchivosDefTipoABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuArchivosDefTipoABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_tipo_abm(-1)</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuArchivosDefTipoABM.MostrarMenu()
        </script>
        <table class="tb1" width="100%" id="tb_archivos_def_tipo">
            <tr class="tbLabel">
                <td style="width:10%; text-align:center">Nro.</td> 
                <td style="width:90%; text-align:center">Descripción</td>
            </tr>
            <tr>
                <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_archivo_def_tipo" id="nro_archivo_def_tipo" style="width:100%;text-align:center;" disabled="disabled" value="<%= nro_archivo_def_tipo %>"/></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="archivo_def_tipo" id="archivo_def_tipo" style="width:100%;" /></td>
            </tr>
        </table>
        <iframe name="iframe_archivos_def_tipo" id="iframe_archivos_def_tipo" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>
