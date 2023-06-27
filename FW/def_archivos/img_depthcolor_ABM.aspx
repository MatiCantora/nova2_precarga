<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_depthcolor As String = nvFW.nvUtiles.obtenerValor("nro_depthcolor", "")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "VA"
    End If

    Dim filtroColores = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_IMG_depthcolor'><campos>nro_depthcolor,depthcolor,descripcion</campos><filtro><nro_depthcolor type='igual'>%nro_depthcolor%</nro_depthcolor></filtro></select></criterio>")
    Dim filtroDescRep = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_IMG_depthcolor'><campos>*</campos><filtro><OR><depthcolor type='igual'>%depthcolor%</depthcolor><descripcion type='igual'>%descripcion%</descripcion></OR></filtro></select></criterio>")

    Dim strXML = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""))
    Dim err = New nvFW.tError()

    If (modo.ToUpper <> "VA") Then
        Stop
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "archivos_img_depthcolor_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML

            Dim rs = Cmd.Execute()

            err.params.Add("nro_depthcolor", rs.Fields("nro_depthcolor").Value)
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

            ''rs.close()

        Catch ex As Exception
            err.parse_error_script(ex)
            err.titulo = "Error al guardar los Colores."
            err.mensaje = "No se actualizaron los datos." & vbCrLf & err.mensaje
        End Try

        err.response()
    End If

%>
<html>
<head>
    <title>Colores ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    <script type="text/javascript">


    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var win = nvFW.getMyWindow()

    var filtroColores = '<%= filtroColores %>'
    var filtroDescRep = '<%= filtroDescRep %>'

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            tb_img_depthcolor_h = $('tb_img_depthcolor').getHeight()
            $('iframe_img_depthcolor').setStyle({ 'height': body_height - tb_img_depthcolor_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        cargar_img_depthcolor()
        window_onresize()
    }

    function cargar_img_depthcolor() {
        var nro_depthcolor = $('nro_depthcolor').value == '' ? 0 : $('nro_depthcolor').value
        if (nro_depthcolor > 0) {
            var rs = new tRS()

            var params = "<criterio><params nro_depthcolor='" + nro_depthcolor + "'/></criterio>"
            rs.open(filtroColores, '', '', '', params)

            if (!rs.eof()) {
                $('depthcolor').value = rs.getdata('depthcolor') == null ? '' : rs.getdata('depthcolor')
                $('descripcion').value = rs.getdata('descripcion') == null ? '' : rs.getdata('descripcion')
            }
        } else {
            $('depthcolor').value = ''
            $('descripcion').value = ''
        }
    }

    function img_depthcolor_abm(nro_depthcolor) {
        //Nuevo color
        if (nro_depthcolor == 0) {
            $('nro_depthcolor').value = 0
            cargar_img_depthcolor()
        }
    }

    function trim(myString) {
        return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
    }

    //Valida y actualiza el color
    function actualizar_img_depthcolor() 
    {   
        var nro_depthcolor = $('nro_depthcolor').value == '' ? 0 : $('nro_depthcolor').value

        if (nro_depthcolor == 0)
            modo = 'A'
        else if (nro_depthcolor < 0)
                modo = 'B'
             else
                modo = 'M'

        $('modo').value = modo

        var depthcolor = trim($('depthcolor').value)
        var descripcion = trim($('descripcion').value)
        var str_error = ''

        if (depthcolor == '')
            str_error += 'Debe ingresar "Depthcolor".</br>';

        if (descripcion == '')
            str_error += 'Debe ingresar "Descripción".</br>';

        if (nro_depthcolor == 0) {
            var rs = new tRS()
            var params = "<criterio><params nro_depthcolor='" + nro_depthcolor + "' descripcion = '" + descripcion + "'/></criterio>"
            rs.open(filtroDescRep, '', '', '', params)
            
            if (!rs.eof())
                str_error += 'Ya existe un Color con el mismo "Depthcolor" o con la misma "Descripción"</br>';
        }

        if (str_error != '') {
            alert(str_error)
            return
        }

        depthcolor = '<![CDATA[' + depthcolor + ']]>'
        descripcion = '<![CDATA[' + descripcion + ']]>'

        var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmldato += "<img_depthcolor modo='" + modo + "' nro_depthcolor='" + nro_depthcolor + "'>"
        xmldato += "<depthcolor>" + depthcolor + "</depthcolor>"
        xmldato += "<descripcion>" + descripcion + "</descripcion>"
        xmldato += "</img_depthcolor>"

        nvFW.error_ajax_request('/fw/def_archivos/img_depthcolor_ABM.aspx', {
            parameters: { modo: 'M', strXML:xmldato },
            onSuccess: function (err, transport) {
                if (err.numError == 0) {
                    nro_depthcolor = err.params['nro_depthcolor']
                    win.options.userData = { nro_depthcolor: nro_depthcolor }
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
<form name="frmIMGdepthcolorABM" action="/fw/def_archivos/img_depthcolor_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    <input type="hidden" name="modo" id="modo" value="<%= modo %>" />

        <div id="divMenuIMGdepthcolorABM" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var vMenuIMGdepthcolorABM = new tMenu('divMenuIMGdepthcolorABM', 'vMenuIMGdepthcolorABM');
            vMenuIMGdepthcolorABM.loadImage("guardar", "/fw/image/icons/guardar.png")
            vMenuIMGdepthcolorABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
            Menus["vMenuIMGdepthcolorABM"] = vMenuIMGdepthcolorABM
            Menus["vMenuIMGdepthcolorABM"].alineacion = 'centro';
            Menus["vMenuIMGdepthcolorABM"].estilo = 'A';
            Menus["vMenuIMGdepthcolorABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar_img_depthcolor()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuIMGdepthcolorABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuIMGdepthcolorABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>img_depthcolor_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuIMGdepthcolorABM.MostrarMenu()
        </script>
        <table class="tb1" id="tb_img_depthcolor">
            <tr class="tbLabel">
                <td style="width:10%; text-align:center">Nro.</td> 
                <td style="width:20%; text-align:center">Depthcolor</td> 
                <td style="width:70%; text-align:center">Descripción</td>
            </tr>
            <tr>
                <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_depthcolor" id="nro_depthcolor" style="width:100%;text-align:center;" disabled="disabled" value="<%= nro_depthcolor %>"/></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="depthcolor" id="depthcolor" style="width:100%;" /></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="descripcion" id="descripcion" style="width:100%;" /></td>
            </tr>
        </table>
        <iframe name="iframe_img_depthcolor" id="iframe_img_depthcolor" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>
