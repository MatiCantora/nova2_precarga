<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_archivo_def_grupo As String = nvFW.nvUtiles.obtenerValor("nro_archivo_def_grupo", "-1")

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "VA"
    End If

    Me.contents("filtroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>nro_archivo_def_grupo,archivo_def_grupo,abreviacion</campos><filtro><nro_archivo_def_grupo type='igual'>%nro_archivo_def_grupo%</nro_archivo_def_grupo></filtro></select></criterio>")
    Me.contents("filtroExiste") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>*</campos><filtro><archivo_def_grupo type='igual'>%archivo_def_grupo%</archivo_def_grupo></filtro></select></criterio>")

    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim err = New nvFW.tError()

    If (modo.ToUpper <> "VA") Then
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "archivos_def_grupo_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML

            Dim rs = Cmd.Execute()

            err.params.Add("nro_archivo_def_grupo", rs.Fields("nro_archivo_def_grupo").Value)
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

            'rs.close()

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
    <title>Grupos de Archivos ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    
    <%= Me.getHeadInit() %>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var filtroGrupo = nvFW.pageContents.filtroGrupo
        var filtroExiste = nvFW.pageContents.filtroExiste

    var win = nvFW.getMyWindow() 

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            divMenuArchivosDefGrupoABM_h = $('divMenuArchivosDefGrupoABM').getHeight()
            tb_archivos_def_grupo_h = $('tb_archivos_def_grupo').getHeight()
            $('iframe_archivos_def_grupo').setStyle({ 'height': body_height - divMenuArchivosDefGrupoABM_h - tb_archivos_def_grupo_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        cargar_archivos_def_grupo()
        window_onresize()
    }

    function cargar_archivos_def_grupo() {
        var nro_archivo_def_grupo = $('nro_archivo_def_grupo').value == '' ? -1 : $('nro_archivo_def_grupo').value
        if (nro_archivo_def_grupo == -1) {
            $('modo').value = 'A'
            $('archivo_def_grupo').value = ''
            $('abreviacion').value = ''
        } else {
            var rs = new tRS()

            var params = "<criterio><params nro_archivo_def_grupo='" + nro_archivo_def_grupo + "'/></criterio>"
            rs.open(filtroGrupo, '', '', '', params)

            if (!rs.eof()) {
                $('archivo_def_grupo').value = rs.getdata('archivo_def_grupo') == null ? '' : rs.getdata('archivo_def_grupo')
                $('abreviacion').value = rs.getdata('abreviacion') == null ? '' : rs.getdata('abreviacion')
                $('modo').value = 'M'
            }
        }
    }

    function archivos_def_grupo_abm(nro_archivo_def_grupo) {
        //Nuevo grupo de archivo
        if (nro_archivo_def_grupo == -1) {
            $('modo').value = 'A'
            $('nro_archivo_def_grupo').value = -1
            cargar_archivos_def_grupo()
        }
    }

    function trim(myString) {
        return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
    }


    //Valida y actualiza el Grupo de archivos
    function actualizar_archivos_def_grupo() 
    {
        var nro_archivo_def_grupo = $('nro_archivo_def_grupo').value == '' ? -1 : $('nro_archivo_def_grupo').value

        var modo = $('modo').value
        var archivo_def_grupo = trim($('archivo_def_grupo').value)
        var abreviacion = trim($('abreviacion').value)
        var str_error = ''

        if (abreviacion == '')
            str_error += 'Debe ingresar una "Abreviación" para el Grupo de Archivo</br>';

        if (archivo_def_grupo == '')
            str_error += 'Debe ingresar una "Descripción" para el Grupo de Archivo</br>';

        if (nro_archivo_def_grupo == -1) {
            var rs = new tRS()

            var params = "<criterio><params archivo_def_grupo='" + archivo_def_grupo + ", abreviacion='" + abreviacion + "/></criterio>"
            rs.open(filtroExiste, '', '', '', params)

            if (!rs.eof())
                str_error += 'Ya existe un Grupo de Archivo con la misma "Descripción"</br>';
        }

        if (str_error != '') {
            alert(str_error)
            return
        }

        archivo_def_grupo = '<![CDATA[' + archivo_def_grupo + ']]>'
        abreviacion = '<![CDATA[' + abreviacion + ']]>'

        var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmldato += "<archivos_def_grupo modo='" + modo + "' nro_archivo_def_grupo='" + nro_archivo_def_grupo + "'>"
        xmldato += "<archivo_def_grupo>" + archivo_def_grupo + "</archivo_def_grupo>"
        xmldato += "<abreviacion>" + abreviacion + "</abreviacion>"
        xmldato += "</archivos_def_grupo>"

        nvFW.error_ajax_request('/fw/def_archivos/archivos_def_grupo_ABM.aspx', {
            parameters: { modo: 'M', strXML: xmldato },
            onSuccess: function (err, transport) {
                if (err.numError == 0) {
                    nro_archivo_def_grupo = err.params['nro_archivo_def_grupo']
                    win.options.userData = { nro_archivo_def_grupo: nro_archivo_def_grupo }
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
<form name="frmArchivosDefGrupoABM" action="/fw/def_archivos/archivos_def_grupo_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    <input type="hidden" name="modo" id="modo" value="<%= modo %>" />

        <div id="divMenuArchivosDefGrupoABM" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var vMenuArchivosDefGrupoABM = new tMenu('divMenuArchivosDefGrupoABM', 'vMenuArchivosDefGrupoABM');
            vMenuArchivosDefGrupoABM.loadImage("guardar", "/fw/image/icons/guardar.png")
            vMenuArchivosDefGrupoABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
            Menus["vMenuArchivosDefGrupoABM"] = vMenuArchivosDefGrupoABM
            Menus["vMenuArchivosDefGrupoABM"].alineacion = 'centro';
            Menus["vMenuArchivosDefGrupoABM"].estilo = 'A';
            Menus["vMenuArchivosDefGrupoABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar_archivos_def_grupo()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuArchivosDefGrupoABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuArchivosDefGrupoABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_grupo_abm(-1)</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuArchivosDefGrupoABM.MostrarMenu()
        </script>
        <table class="tb1" id="tb_archivos_def_grupo">
            <tr class="tbLabel">
                <td style="width:10%; text-align:center">Nro.</td> 
                <td style="width:60%; text-align:center">Descripción</td>
                <td style="width:30%; text-align:center">Abreviación</td>
            </tr>
            <tr>
                <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_archivo_def_grupo" id="nro_archivo_def_grupo" style="width:100%;text-align:center;" disabled="disabled" value="<%= nro_archivo_def_grupo %>"/></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="archivo_def_grupo" id="archivo_def_grupo" style="width:100%;" /></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="abreviacion" id="abreviacion" style="width:100%;" /></td>
            </tr>
        </table>
        <iframe name="iframe_archivos_def_grupo" id="iframe_archivos_def_grupo" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>
