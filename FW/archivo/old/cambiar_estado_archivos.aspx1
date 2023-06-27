<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%


    Dim nro_def_archivo = nvFW.nvUtiles.obtenerValor("nro_def_archivo", "")

    Me.contents("nro_def_archivo") = nro_def_archivo
    Me.contents("verArchivos_def_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_def_detalle'>" +
  "<campos>*</campos>" +
  "<filtro></filtro></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Cer Admin</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var nro_def_archivo = nvFW.pageContents.nro_def_archivo;
        var archivosCargados = false;
        var win = nvFW.getMyWindow();
        var archivos = [];

        function window_onresize() {
            try {

                var body_h = $(document.body).getHeight();
                //var botones_h = $('botones').getHeight();
                var tbArchivos_h = $('tbArchivos').getHeight();
                var tbComentarios_h = $('tbComentarios').getHeight();
                var divCambiar_h = $('divCambiar').getHeight();
                $('frame_archivos').style.height = (body_h - tbArchivos_h - 15 - tbComentarios_h - divCambiar_h) + "px"
                //$('tbComentarios').style.height = (body_h - tbArchivos_h - $('frame_archivos').getHeight() - divCambiar_h) + "px"

            }
            catch (ex) {

            }
        }

        function window_onload() {

            cargarDefArchivos(nro_def_archivo)

            window_onresize();
        }

        function cargarDefArchivos(nro_def_archivo) {
            var filtroWhere = "<nro_def_archivo type='igual'>" +
                                     nro_def_archivo +
                          "</nro_def_archivo>";

            nvFW.exportarReporte({
                filtroWhere: filtroWhere,
                filtroXML: nvFW.pageContents.verArchivos_def_detalle,
                path_xsl: "report\\verArchivos_def_detalle\\verArchivos_def_detalle.xsl",
                formTarget: 'frame_archivos',
                bloq_contenedor: 'frame_archivos',
                async: true,
                cls_contenedor: 'frame_archivos',
                funComplete: function () {
                    cargando_solicitudes = false;
                    if (verificarArchivosRequeridos()) {
                        $('checkArchivos').checked = true;
                        archivosCargados = true;
                    }
                    window_onresize();
                    cargandoEstado = false;
                }
            })
        }
        function setRequerido(requerido, orden) {
            archivos[orden] = {};
            archivos[orden].archivo = "";
            archivos[orden].requerido = requerido;

            if (requerido == 'True')
                return "Si";
            else
                return "No";
        }
        function verificarArchivosRequeridos() {

            for (var key in archivos) {
                var archivo = archivos[key];
                if (archivo.requerido == "True")
                    if (archivo.archivo == "")
                        return false;
            }
            return true;
        }

        function setArchivo(orden, valor, desc, id) {
            if (valor) {

                var iFrameArchivos = frames.frame_archivos.document;
                archivos[orden].archivo = valor ? valor : "";
                archivos[orden].id = id ? id : "";
                archivos[orden].desc = desc ? desc : "";

                iFrameArchivos.getElementById("archivo_def_" + nro_def_archivo + "_" + orden).innerHTML =
                            "<a style='color:blue;font-weight: bold;' onclick=parent.verArchivo('" + 2 +
                            "','" + orden + "','" + id + "')><img src='/FW/image/icons/ver_adjunto.png' style='cursor:pointer;' > " +
                            archivos[orden].archivo + "</a>";
            }
        }

        function cargarArchivo(nro_def_archivo, orden) {
            win_arch = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: 'ABMDocumentos.aspx?nro_def_archivo=' + nro_def_archivo + '&orden=' + orden + "&id_tipo=" + nro_implement + "&nro_com_id_tipo=" + 7,
                title: ('<b>Cargar Archivo</b>'),
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 80,
                onClose: function () {
                    if (win_arch.options.userData.success) {

                        var archivos_list = win_arch.options.userData.archivos;
                        var descripciones = win_arch.options.userData.descripciones;
                        var ids = win_arch.options.userData.ids;

                        setArchivo(orden, archivos_list[0], descripciones[0], ids[0])

                        if (verificarArchivosRequeridos()) {
                            $('checkArchivos').checked = true;
                            archivosCargados = true;
                        }
                        // $("archivo_def_"+nro_def_archivo+"_"+orden).innerHTML = "Si"
                    }
                }
            });

            win_arch.options.userData = {};
            win_arch.options.userData.success = false;
            win_arch.options.userData.nro_com_id_tipo = 8;
            win_arch.options.userData.id_tipo = nro_solicitud;
            win_arch.showCenter(true)
        }

        function historialArchivo(orden) {
            win_arch = window.top.nvFW.createWindow({
                className: 'alphacube',
                url: 'HistorialDocumentos.aspx?orden=' + orden + '&nro_implementacion=' + nro_implement,
                title: ('<b>Historial Archivo</b>'),
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 300,
                onClose: function () {

                    if (win_arch.options.userData.seleccionado != 0) {
                        var id = win_arch.options.userData.seleccionado;
                        var descripcion = win_arch.options.userData.desc
                        var nomArchivo = win_arch.options.userData.archivo;
                        setArchivo(orden, nomArchivo, descripcion, id)
                        if (verificarArchivosRequeridos()) {
                            $('checkArchivos').checked = true;
                            archivosCargados = true;
                        }
                    }
                }
            });

            win_arch.options.userData = {};
            win_arch.options.userData.success = false;
            win_arch.options.userData.nro_com_id_tipo = orden;
            win_arch.options.userData.id_tipo = nro_implement;

            win_arch.showCenter(true)
        }

        function cargar_archivos() {



            win_arch =nvFW.createWindow({
                className: 'alphacube',
                url: 'ABMDocumentos.aspx?nro_def_archivo=' + nro_def_archivo + '&nro_com_id_tipo=7&id_tipo=' + nro_implement,
                title: ('<b>Cargar Archivos</b>'),
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 200,
                onClose: function () {

                    if (win_arch.options.userData.success) {
                        var archivos_list = win_arch.options.userData.archivos;

                        var descripciones = win_arch.options.userData.descripciones;
                        var ids = win_arch.options.userData.ids;
                        $('checkArchivos').checked = true;
                        archivosCargados = true;
                        var contador = 0;

                        for (var key in archivos) {
                            setArchivo(key, archivos_list[contador], descripciones[contador], ids[contador])
                            contador++;
                        }
                    }
                }
            });

            win_arch.options.userData = {};
            win_arch.options.userData.success = false;
            win_arch.options.userData.nro_com_id_tipo = 7;
            win_arch.options.userData.id_tipo = nro_implement;

            win_arch.showCenter(true)
        }

       
        var botonAnterior = null;
        var cargandoEstado = false;
        function seleccionar_estado(pestado_destinto, pid_cire_estado, pdescripcion, pnro_circuito, pnro_def_archivo, boton) {
            if (!cargandoEstado) {
                cargandoEstado = true;
                estado_destinto = pestado_destinto;
                id_cire_estado = pid_cire_estado;
                descripcion = pdescripcion;
                nro_circuito = pnro_circuito;
                if (botonAnterior)
                    botonAnterior.style.backgroundColor = "#DDDDDD";
                botonAnterior = boton;
                boton.style.backgroundColor = "white"
                cargarDefArchivos(pnro_def_archivo)
            }
            /*Dialog.confirm('¿Esta seguro que quiere cambiar el estado a <strong>' + descripcion +
            '</strong> ?', {
            width: 450, className: "alphacube",
            onOk: function (win) {
            cambiarEstado(estado_destinto, id_cire_estado, descripcion, nro_circuito)
            win.close()
            },
            onCancel: function (win) { win.close() },
            okLabel: 'Aceptar',
            cancelLabel: 'Cancelar'
            });*/

        }

      
        function tryGetValue(nombre, rs) {
            var valor = rs.getdata(nombre);

            return (valor ? valor : '');
        }


        function key_Buscar() {
            //if (window.event.keyCode == 13)
            //buscar_click();
        }

        function guardar() {
            if(archivosCargados)
            {
                win.options.userData.cargados = true;
                win.options.userData.archivos = archivos;
                win.options.userData.comentario = $('comentario').value;
                win.close();
            } else {
                alert("Debe cargar todos los archivos requeridos")
            }
        }

    </script>

</head>
<body onload="window_onload()" onresize="window_onresize()" onkeypress="return key_Buscar()" style="overflow-y: auto">
     <div id="divCambiar"></div>
                <script type="text/javascript">
                    //var DocumentMNG = new tDMOffLine;
                    var vCambiar = new tMenu('divCambiar', 'vCambiar');
                    vCambiar.loadImage("periodicidad", '/FW/image/icons/periodicidad.png')
                    Menus["vCambiar"] = vCambiar
                    Menus["vCambiar"].alineacion = 'centro';
                    Menus["vCambiar"].estilo = 'A';



                    Menus["vCambiar"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 75%;text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Personales</Desc></MenuItem>")
                    //Si no existe entidad mostramos el boton
                    Menus["vCambiar"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 25%; text-align:center; vertical-align:middle'>" +
                                       "<Lib TipoLib='offLine'>DocMNG</Lib><icono>periodicidad</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'>" +
                                       "<Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                    vCambiar.MostrarMenu()
                </script>
    <center>
        <div style="display: inline; margin-top: .5em" id="botones"></div>
    </center>
    <table class="tb1" id="tbArchivos" style="width: 100%; vertical-align: top;">
       <tr>
           <td class="Tit1" style="width: 25%;  vertical-align: top;">Cargar Archivos</td>
           <td><div id="divArchivos"></div>
               <script type="text/javascript">

                   var vButtonItems = {};
                   vButtonItems[0] = {};
                   vButtonItems[0]["nombre"] = "Archivos";
                   vButtonItems[0]["etiqueta"] = "Cargar Archivos";
                   vButtonItems[0]["imagen"] = "subir";
                   vButtonItems[0]["onclick"] = "return cargar_archivos()";

                   var vListButton = new tListButton(vButtonItems, 'vListButton');
                   vListButton.loadImage('subir', '/FW/image/icons/upload.png')

                   vListButton.MostrarListButton()

            </script>
           </td>
           <td  style="width: 25%;padding-left:1em">
               <input type="checkbox" disabled id="checkArchivos"/> Cargados
           </td>
       </tr>
       <tr class="tbLabel">
           <td colspan="3">Archivos</td>
       </tr>
   </table>
    
    <iframe id="frame_archivos" name="frame_archivos" style="width:100%"></iframe>  
    <table class="tb1" id="tbComentarios">
        <tr class="tbLabel">
            <td>Comentario
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top">
                <textarea style="width: 95%; height: 95% ;margin: 0.5em;" rows="4" id="comentario"></textarea>
            </td>
        </tr>
    </table>



</body>
</html>
