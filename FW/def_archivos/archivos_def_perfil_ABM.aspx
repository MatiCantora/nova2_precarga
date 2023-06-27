<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nro_archivo_def_perfil As String = nvFW.nvUtiles.obtenerValor("nro_archivo_def_perfil", "")
    
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "" Then
        modo = "VA"
    End If
    
    Dim filtroPerfil = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_perfil'><campos>id,resolucion,tipo_color,formato,multipagina,archivo_def_perfil,compresion</campos><filtro><id type='igual'>%nro_archivo_def_perfil%</id></filtro></select></criterio>")
    Dim filtroExiste = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_perfil'><campos>*</campos><filtro><archivo_def_perfil type='igual'>%archivo_def_perfil%</archivo_def_perfil></filtro></select></criterio>")
    
    Dim strXML = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""))
    Dim err = New nvFW.tError()
    
    If (modo.ToUpper <> "VA") Then
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "archivos_def_perfil_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = strXML.Length
            Cmd.Parameters("@strXML").value = strXML
                    
            Dim rs = Cmd.Execute()
                    
            err.params.Add("nro_archivo_def_perfil", rs.Fields("nro_archivo_def_perfil").Value)
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
    <title>Perfiles de Archivos ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js" ></script>
    
    <script type="text/javascript">

        var filtroPerfil = '<%= filtroPerfil %>'
        var filtroExiste = '<%= filtroExiste %>'

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
    var win = nvFW.getMyWindow() 

    function window_onresize() {
        try {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            tb_archivos_def_perfil_h = $('tb_archivos_def_perfil').getHeight()
            tb_archivos_def_perfil1_h = $('tb_archivos_def_perfil1').getHeight()
            $('iframe_archivos_def_perfil').setStyle({ 'height': body_height - tb_archivos_def_perfil_h - tb_archivos_def_perfil1_h - dif + 'px' })
        }
        catch (e) { }
    }

    function window_onload() {
        cargar_archivos_def_perfil()
        window_onresize()
    }

    function cargar_archivos_def_perfil() {
        var nro_archivo_def_perfil = $('nro_archivo_def_perfil').value == '' ? 0 : $('nro_archivo_def_perfil').value
        if (nro_archivo_def_perfil > 0) {
            var rs = new tRS()

            var params = "<criterio><params nro_archivo_def_perfil='" + nro_archivo_def_perfil + "'/></criterio>"
            rs.open(filtroPerfil, '', '', '', params)
            
            if (!rs.eof()) {
                $('archivo_def_perfil').value = rs.getdata('archivo_def_perfil') == null ? '' : rs.getdata('archivo_def_perfil')
                $('formato').value = rs.getdata('formato') == null ? '' : rs.getdata('formato')
                var resolucion = rs.getdata('resolucion') == null ? '' : rs.getdata('resolucion')
                campos_defs.set_value('resolucion', resolucion)
                var tipo_color = rs.getdata('tipo_color') == null ? '' : rs.getdata('tipo_color')
                campos_defs.set_value('nro_depthcolor', tipo_color)
                $('multipagina').checked = rs.getdata('multipagina') == "True" ? 'checked' : ''
                var compresion = rs.getdata('compresion') == null ? '' : rs.getdata('compresion')
                campos_defs.set_value('compresion', compresion)
            }
        } else {
            $('archivo_def_perfil').value = ''
            $('formato').value = ''
            campos_defs.clear('resolucion')
            campos_defs.clear('nro_depthcolor')
            $('multipagina').checked = ''
            campos_defs.clear('compresion') 
        }
    }

    function archivos_def_perfil_abm(nro_archivo_def_perfil) {
        //Nuevo perfil de archivo
        if (nro_archivo_def_perfil == 0) {
            $('nro_archivo_def_perfil').value = 0
            cargar_archivos_def_perfil()
        }
    }

    function trim(myString) {
        return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
    }

    //Valida y actualiza el Perfil de escaneo de archivos
    function actualizar_archivos_def_perfil() 
    {
        var nro_archivo_def_perfil = $('nro_archivo_def_perfil').value == '' ? 0 : $('nro_archivo_def_perfil').value

        if (nro_archivo_def_perfil == 0)
            modo = 'A'
        else if (nro_archivo_def_perfil < 0)
                modo = 'B'
             else
                modo = 'M'

        $('modo').value = modo

        var archivo_def_perfil = trim($('archivo_def_perfil').value)
        var formato = trim($('formato').value)
        var resolucion = campos_defs.get_value('resolucion')
        var tipo_color = campos_defs.get_value('nro_depthcolor')
        var multipagina = $('multipagina').checked ? 1 : 0
        var compresion = campos_defs.get_value('compresion')

        var str_error = ''

        if (archivo_def_perfil == '')
            str_error += 'Debe ingresar una "Descripción".</br>';
        if (formato == '')
            str_error += 'Debe ingresar un "Formato".</br>';
        if (resolucion == '')
            str_error += 'Debe ingresar una "Resolución".</br>';
        if (tipo_color == '')
            str_error += 'Debe seleccionar un "Tipo de Color".</br>';
//        if (compresion == '')
//            str_error += 'Debe especificar una "Compresión" para el Perfil de Archivo</br>';

        if (nro_archivo_def_perfil == 0) {
            var rs = new tRS()

            var params = "<criterio><params archivo_def_perfil='" + archivo_def_perfil + "'/></criterio>"
            rs.open(filtroExiste, '', '', '', params)

            if (!rs.eof())
                str_error += 'Ya existe un Perfil de Archivo con la misma "Descripción"</br>';
        }

        if (str_error != '') {
            alert(str_error)
            return
        }

        archivo_def_perfil = '<![CDATA[' + archivo_def_perfil + ']]>'
        formato = '<![CDATA[' + formato + ']]>'

        var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
        xmldato += "<archivos_def_perfil modo='" + modo + "' id='" + nro_archivo_def_perfil + "' resolucion='" + resolucion + "' tipo_color='" + tipo_color + "' compresion='" + compresion + "' multipagina='" + multipagina + "'>"
        xmldato += "<archivo_def_perfil>" + archivo_def_perfil + "</archivo_def_perfil>"
        xmldato += "<formato>" + formato + "</formato>"
        xmldato += "</archivos_def_perfil>"

        nvFW.error_ajax_request('/fw/def_archivos/archivos_def_perfil_ABM.aspx', {
            parameters: { modo: 'M', strXML: escape(xmldato) },
            onSuccess: function (err, transport) {
                if (err.numError == 0) {
                    nro_archivo_def_perfil = err.params['nro_archivo_def_perfil']
                    win.options.userData = { nro_archivo_def_perfil: nro_archivo_def_perfil }
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
<form name="frmArchivosDefPerfilABM" action="/fw/def_archivos/archivos_def_perfil_ABM.aspx" method="post" style='width:100%;height:100%;overflow:hidden'>
    <input type="hidden" name="modo" id="modo" value="<%= modo %>" />

        <div id="divMenuArchivosDefPerfilABM" style="margin: 0px; padding: 0px;"></div>
        <script language="javascript" type="text/javascript">
            var vMenuArchivosDefPerfilABM = new tMenu('divMenuArchivosDefPerfilABM', 'vMenuArchivosDefPerfilABM');
            vMenuArchivosDefPerfilABM.loadImage("guardar", "/fw/image/icons/guardar.png")
            vMenuArchivosDefPerfilABM.loadImage("nuevo", "/fw/image/icons/nueva.png")
            Menus["vMenuArchivosDefPerfilABM"] = vMenuArchivosDefPerfilABM
            Menus["vMenuArchivosDefPerfilABM"].alineacion = 'centro';
            Menus["vMenuArchivosDefPerfilABM"].estilo = 'A';
            Menus["vMenuArchivosDefPerfilABM"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar_archivos_def_perfil()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuArchivosDefPerfilABM"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuArchivosDefPerfilABM"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva</Desc><Acciones><Ejecutar Tipo='script'><Codigo>archivos_def_perfil_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuArchivosDefPerfilABM.MostrarMenu()
        </script>
        <table class="tb1" width="100%" id="tb_archivos_def_perfil">
            <tr class="tbLabel">
                <td style="width:10%; text-align:center">Nro.</td> 
                <td style="width:90%; text-align:center">Descripción</td>
            </tr>
            <tr>
                <td style="vertical-align:middle; text-align:center"><input type="text" name="nro_archivo_def_perfil" id="nro_archivo_def_perfil" style="width:100%;text-align:center;" disabled="disabled" value="<%= nro_archivo_def_perfil %>"/></td>
                <td style="vertical-align:middle; text-align:left"><input type="text" name="archivo_def_perfil" id="archivo_def_perfil" style="width:100%;" /></td>
            </tr>
        </table>
        <table class="tb1" width="100%" id="tb_archivos_def_perfil1">
            <tr class="tbLabel">
                <td style="width:30%; text-align:center">Formato</td>
                <td style="width:15%; text-align:center">Resolución</td> 
                <td style="width:25%; text-align:center">Tipo Color</td>
                <td style="width:15%; text-align:center">Multipágina</td>
                <td style="width:15%; text-align:center">Compresión</td>
            </tr>
            <tr>    
                <td style="vertical-align:middle; text-align:left"><input type="text" name="formato" id="formato" style="width:100%;" /></td>
                <td style="vertical-align:middle; text-align:center">
                     <script type="text/javascript">
                         campos_defs.add('resolucion', { enDB: false, nro_campo_tipo: 101 })
                     </script>            
                </td>
                <td style="vertical-align:middle; text-align:center">          
                     <%= nvFW.nvCampo_def.get_html_input("nro_depthcolor") %>                     
                </td>
                <td style="vertical-align:middle; text-align:center"><input style='border:none; vertical-align: middle' type='checkbox' id='multipagina' name='multipagina' /></td>
                <td style="vertical-align:middle; text-align:center">
                     <script type="text/javascript">
                         campos_defs.add('compresion', { enDB: false, nro_campo_tipo: 101 })
                     </script>            
                </td>
            </tr>
        </table>
        <iframe name="iframe_archivos_def_perfil" id="iframe_archivos_def_perfil" style='width: 100%; height: 100%; overflow: auto; border:none' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</form>
</body>
</html>
