<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0

    Dim modo = nvUtiles.obtenerValor("modo", "")

    If (modo = "") Then
        modo = "VA"
    End If
    
    Dim idpki As String = nvUtiles.obtenerValor("idpki", "")

    Dim id_carpeta As Integer = nvUtiles.obtenerValor("id_carpeta", 0)
    Dim pki As String = nvUtiles.obtenerValor("pki", "")
    Dim carpeta_path As String = nvUtiles.obtenerValor("carpeta_path", "")
    Dim carpeta_nombre As String = nvUtiles.obtenerValor("carpeta_nombre", "")
    Dim esconfiable As Boolean = IIf(nvUtiles.obtenerValor("esconfiable", "") = "true", True, False)
    Dim esmy As Boolean = IIf(nvUtiles.obtenerValor("esmy", "") = "true", True, False)

    Me.contents("ver_PKI_carpetas") = nvXMLSQL.encXMLSQL("<criterio><select vista='PKI_carpetas'><campos>*</campos><orden></orden><filtro><id_carpeta type='igual'>%id_carpeta%</id_carpeta></filtro></select></criterio>")
    
    Dim IDCert As String = nvUtiles.obtenerValor("IDCert", "")

    If (modo <> "VA") Then
        Dim Err As New tError()
        Try
            Err = nvPKIDBUtil.pkiFolderABM(pki, id_carpeta, carpeta_path, carpeta_nombre, esconfiable, esmy)
        Catch ex As Exception

            Err.parse_error_script(ex)

            Err.titulo = "Error Guardar Certificado"
            Err.mensaje = ex.Message
            Err.comentario = ""
            Err.debug_src = "PKI_abm.aspx"

        End Try

        Err.salida_tipo = "adjunto"
        Err.debug_src = "PKI_certificado_abm.aspx"
        Err.response()


    End If

%>
<html>
<head>
    <title>PKI Carpetas ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <% = Me.getHeadInit()%>
    
    <script type="text/javascript" >
        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()
        
        function window_onload() {
            var id_carpeta = $('id_carpeta').value        
            if (id_carpeta != 0)
                pki_carpeta_cargar(id_carpeta)
            else
                {
                //campos_defs.set_value('pki', $('idpki').value)
                $('pki').value = $('idpki').value
                $('id_carpeta').value = 0    
                }
        }


        function pki_carpeta_cargar(id_carpeta) {
            var rs = new tRS()
            var parametros = "<criterio><params id_carpeta= '" + id_carpeta + "' /></criterio>"
            rs.open(nvFW.pageContents.ver_PKI_carpetas, '', '', '', parametros);


            if (!rs.eof()) {

                //campos_defs.set_value('pki', rs.getdata('IDPKI'))
                $('pki').value = rs.getdata('IDPKI')

                //$('carpeta_path').value = rs.getdata('carpeta_path')
                $('carpeta_nombre').value = rs.getdata('carpeta_nombre')

                $('esconfiable').checked = false
                if (rs.getdata('esConfiable') == 'True')
                    $('esconfiable').checked = true
                $('esmy').checked = false
                if (rs.getdata('esMy') == 'True')
                    $('esmy').checked = true

                $('carpeta_nombre').disabled = true
            }
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divMenuABM_lg_caso_h = $('divMenuABM_lg_caso').getHeight()
                var div_lg_caso_h = $('div_lg_caso').getHeight() 
                var divMenu_lg_caso_actores_h = $('divMenu_lg_caso_actores').getHeight()
                var divMenuComentarioArchivo_h = $('divMenuComentarioArchivo').getHeight()

                var resto = body_h - divMenuABM_lg_caso_h - div_lg_caso_h - divMenu_lg_caso_actores_h - divMenuComentarioArchivo_h - dif 
                var mitad = resto / 2
                
                $('frame_lg_caso_actores').setStyle({ 'height': mitad + ' px' });
                $('frame_comentarios').setStyle({ 'height': mitad + ' px' });
                $('frame_archivos').setStyle({ 'height': mitad + ' px' });
                    
            }
            catch (e) { }
        }      

        function guardar()
        { 
            var modo = 'G'
            var id_carpeta = $('id_carpeta').value
            var pki = $('pki').value

            //var carpeta_path = $('carpeta_path').value
            var carpeta_path = $('carpeta_nombre').value // carpeta = path, se usa solo un nivel de directorios

            var carpeta_nombre = $('carpeta_nombre').value
            var esconfiable = $('esconfiable').checked
            var esmy = $('esmy').checked

            var strMsg = ''
            if (pki == '')
                strMsg += 'Debe seleccionar una PKI.<br>'
            if (carpeta_path == '')
                strMsg += 'Debe ingresar el path de la carpeta.<br>'
            if (carpeta_nombre == '')
                strMsg += 'Debe ingresar el nombre de la carpeta.<br>'        
            if (strMsg != '')
                {
                alert(strMsg)
                return
                }         
            nvFW.error_ajax_request('pki_carpetas_ABM.aspx', {
                    parameters: {
                        modo: modo,
                        id_carpeta: id_carpeta,
                        pki: pki,
                        carpeta_path: carpeta_path,
                        carpeta_nombre: carpeta_nombre,
                        esconfiable: esconfiable,
                        esmy: esmy
                    },
                    onSuccess: function(err, transport) {
                        if (err.numError == 0) 
                            {
                            var id_carpeta = err.params['id_carpeta']
	                        win.options.userData = { id_carpeta: id_carpeta }
	                        win.close()
	                        }
                    }
                });
        }

function chk_winfolderpersonal_onclick()
{
if ($('chk_winfolderpersonal').checked)
    {
    $('winfolder').show()
    $('cbwinfolder').hide()
    }
else
    {
    $('winfolder').hide()
    $('cbwinfolder').show()
    }    
    
}

function eliminar_carpeta() {

    Dialog.confirm('¿Desea eliminar la carpeta?'
               , {
                   width: 350, className: "alphacube",
                   onShow: function () {
                   },
                   onOk: function (win) {
                       $('id_carpeta').value = $('id_carpeta').value * -1
                       guardar()
                       win.close()
                   },
                   onCancel: function (win) { win.close() },
                   okLabel: 'Aceptar',
                   cancelLabel: 'Cancelar'
               });

}


</script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;height: 100%; overflow: hidden">
  <form action="pki_carpetas_ABM.aspx" method="post" name="form1" style="width: 100%;height: 100%; overflow: hidden">
      <input type='hidden' id='id_carpeta' value='<%=id_carpeta %>' />
      <input type='hidden' id='idpki' name='idpki' value='<%=idpki %>' />
      <div id="divMenuABM_pki_carpeta"></div>
      <script type="text/javascript" >

        var vMenuABM_pki_carpeta = new tMenu('divMenuABM_pki_carpeta', 'vMenuABM_pki_carpeta');
        Menus["vMenuABM_pki_carpeta"] = vMenuABM_pki_carpeta
        Menus["vMenuABM_pki_carpeta"].alineacion = 'centro';
        Menus["vMenuABM_pki_carpeta"].estilo = 'A';
        Menus["vMenuABM_pki_carpeta"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Carpetas</Desc></MenuItem>")
        Menus["vMenuABM_pki_carpeta"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar_carpeta()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki_carpeta"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki_carpeta"].loadImage("guardar", "/fw/image/icons/guardar.png")
        Menus["vMenuABM_pki_carpeta"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
        vMenuABM_pki_carpeta.MostrarMenu()
      </script>
      <div id="div_pki_carpetas"  style="margin: 0px; padding: 0px">
          <table class="tb1" style="width:100%">
            <tr class="tbLabel">
              <td style='width:50%'>PKI</td>
               <td style='width:50%'>Carpeta</td>
            </tr>
            <tr>
              <td>
              <input name="pki" id="pki" type="text" value="" disabled="disabled" style="width: 100%" />
              </td>
              <td>
              <input name="carpeta_nombre" id="carpeta_nombre" type="text" value="" style="width: 100%" />
              </td> 
            </tr>
          </table>
          <table class="tb1">
            <tr class="tbLabel">
              <td style='width:50%'>Confiable</td>
              <td style='width:50%'>My</td>

            </tr>
            <tr>
                <td style='text-align:center'><input style='border:0' type="checkbox" id='esconfiable' /></td>
                <td style='text-align:center'><input style='border:0' type="checkbox" id='esmy' /></td>

            </tr>
          </table>
      </div>         
</form>
</body>
</html>