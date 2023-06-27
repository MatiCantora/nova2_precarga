<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err As New nvFW.tError()

    Dim filtroGrupoPermisos As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_grupo'><campos>nro_permiso_grupo,permiso_grupo</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroVectorPermiso As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_grupo'><campos>hardcode</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroCargarDetalle As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_detalle'><campos>nro_permiso_grupo,nro_permiso,permitir,ISNULL(power(2, nro_permiso -1),0) as numero</campos><filtro></filtro><orden>nro_permiso</orden></select></criterio>")
    Dim filtroObtenerPermiso As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadorTipo_Permisos_detalle'><campos>case when power(2, nro_permiso -1) &amp; permiso = 0 then 0 else 1 end as tiene_permiso</campos><filtro></filtro><orden>nro_permiso</orden></select></criterio>")
    Dim filtroObtenerPermisoComp As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadorTipo_Permisos_detalle'><campos>case when power(2, nro_permiso -1) &amp; permiso = 0 then 0 else 1 end as tiene_permiso</campos><filtro></filtro><orden>nro_permiso</orden></select></criterio>")

    'debe tener el permiso para editar el modulo
    If Not op.tienePermiso("permisos_seguridad", 3) Then
        err.numError = -1
        err.titulo = "No se pudo completar la operación. "
        err.mensaje = "No tiene permisos para ver la página."
        err.response()
    End If

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim comparar As String = nvFW.nvUtiles.obtenerValor("vista", "")
    Dim tipo_operador_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_get", "")
    Dim tipo_operador_comp_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_comp_get", "")

    Dim nro_permiso_grupo_get As String = nvFW.nvUtiles.obtenerValor("nro_permiso_grupo_get", "")
    Dim nro_permiso_get As String = nvFW.nvUtiles.obtenerValor("nro_permiso_get", "")

    Dim cod_servidor As String = nvApp.cod_servidor

    If modo = "M" Then

        Dim strSQL As String = ""
        Dim accion = nvFW.nvUtiles.obtenerValor("accion", "").ToLower
        Dim nro_permiso_grupo = nvFW.nvUtiles.obtenerValor("nro_permiso_grupo", "")
        Dim permitir As String = nvFW.nvUtiles.obtenerValor("permitir", "")
        Dim nro_permiso = nvFW.nvUtiles.obtenerValor("nro_permiso", "")
        Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")

        Dim xmlReq As String = "<?xml version='1.0'?>"


        If accion = "alta_grupo" Then
            Dim permiso_grupo As String = nvFW.nvUtiles.obtenerValor("permiso_grupo", "")
            xmlReq &= "<alta_grupo permiso_grupo='" & permiso_grupo & "'/>"
        End If

        If accion = "delete_grupo" Then
            Dim permiso_grupo As String = nvFW.nvUtiles.obtenerValor("nro_permiso", "")
            xmlReq &= "<baja_grupo permiso_grupo='" & permiso_grupo & "' nro_permiso_grupo='" & nro_permiso_grupo & "'/>"
        End If

        If accion = "update_grupo" Then
            Dim permiso_grupo As String = nvFW.nvUtiles.obtenerValor("permitir", "")
            xmlReq &= "<update_grupo nro_permiso_grupo='" & nro_permiso_grupo & "' permiso_grupo='" & permiso_grupo & "'/>"

        End If


        If accion = "update_detalle_permiso" Then
            xmlReq &= "<update_detalle_permiso nro_permiso_grupo='" & nro_permiso_grupo & "' nro_permiso='" & nro_permiso & "' permitir='" & permitir & "'/>"

        End If


        If accion = "update_permiso" Then
            xmlReq &= "<update_permiso>"
            xmlReq &= "<strXML>"
            xmlReq &= strXML
            xmlReq &= "</strXML>"
            xmlReq &= "</update_permiso>"

        End If


        If accion = "permiso_copiar_perfiles" Then

            Dim tiene_permiso As String = nvFW.nvUtiles.obtenerValor("tiene_permiso", "")

            xmlReq &= "<permiso_copiar_perfiles "
            xmlReq &= " nro_permiso_grupo='" & nro_permiso_grupo & "' "
            xmlReq &= " nro_permiso='" & nro_permiso & "' "
            xmlReq &= " tiene_permiso='" & tiene_permiso & "' "
            xmlReq &= " />"

        End If


        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("fw_perfiles_permisos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pAccion As ADODB.Parameter
        Dim pStrXML As ADODB.Parameter

        pAccion = cmd.CreateParameter("@accion", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, accion.Length, accion)
        pStrXML = cmd.CreateParameter("@xmlReq", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlReq.Length, xmlReq)

        cmd.Parameters.Append(pAccion)
        cmd.Parameters.Append(pStrXML)

        Dim rs As ADODB.Recordset = cmd.Execute()

        If Not IsNothing(rs) Then
            err.numError = rs.Fields("numError").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.titulo = rs.Fields("titulo").Value
            err.debug_desc = rs.Fields("debug_desc").Value
            err.debug_src = rs.Fields("debug_src").Value
        Else
            err.numError = -1
            err.mensaje = "rs vacío"
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)

        err.response()
    End If


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Operador Permiso ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var Operador_Tipo = new Array()
        var cod_servidor = "<%=cod_servidor %>"
        var comparar = "<%= comparar %>"

        var filtroGrupoPermisos = '<%= filtroGrupoPermisos %>'
        var filtroVectorPermiso = '<%= filtroVectorPermiso %>'
        var filtroCargarDetalle = '<%= filtroCargarDetalle %>'
        var filtroObtenerPermiso = '<%= filtroObtenerPermiso %>'
        var filtroObtenerPermisoComp = '<%= filtroObtenerPermisoComp %>'

        function window_onload() {
            cargar();
            window_onresize()
        }

        function cargar() {
            grupo_permiso_cargar()
        }

        var tabla_permisos_grupo;
        function grupo_permiso_cargar() {

            var criterio = filtroGrupoPermisos

            tabla_permisos_grupo = new tTable();
            cargarVectorPermiso();

            //Nombre de la tabla y id de la variable
            tabla_permisos_grupo.nombreTabla = "tabla_permisos_grupo";
            //Agregamos consulta XML
            tabla_permisos_grupo.filtroXML = criterio

            tabla_permisos_grupo.filtroWhere = filtroGrupo

            tabla_permisos_grupo.cabeceras = ["-", "Id", "Grupo", "Eliminar"];
            tabla_permisos_grupo.eliminable = false;
            tabla_permisos_grupo.editable = false;
            tabla_permisos_grupo.agregar_espacios_en_blanco_dir = function () { nuevo_grupo(); };
            tabla_permisos_grupo.async = true;
            tabla_permisos_grupo.campos = [
            {
                nombreCampo: "radio", width: "10%", get_html: function (campo, nombre, fila) { return "<input type='radio' name='permisosRadio' onclick='check_permiso_grupo_onclick(" + campo.fila + "," + nombre + ")' id='checkbox" + campo.fila + "' />" }, enDB: false
            },
            {
                nombreCampo: "nro_permiso_grupo", width: "10%", nro_campo_tipo: 104, ordenable: false
            },
            {
                nombreCampo: "permiso_grupo", nro_campo_tipo: 104, get_html:
                  function (campo, nombre, fila) {
                      if (vectorPermiso[campo.fila] == 'False') {
                          return "<b><u><p id='permisoGrupo" + campo.fila + "' onclick='cambiar_desc_grupo(" + fila[1].valor + ",\"" + campo.valor + "\")' style='cursor:hand'>" + campo.valor + "</p></u></b>"
                      }
                      return "<p id='" + campo.fila + "'>" + campo.valor + "</p>";
                  }
            },
            {
                nombreCampo: "eliminar", width: "5%", get_html:
                   function (campo, nombre, fila) {
                       if (vectorPermiso[campo.fila] == 'False') {
                           return '<center><img border="0"  onclick="eliminar_fila(' + fila[1].valor + ',\'' + fila[2].valor + '\')" src="/FW/image/icons/eliminar.png" title="eliminar" style="cursor:pointer" /></center>'
                       }
                       else
                           return "";
                   }
            }
            ];

            tabla_permisos_grupo.addOnComplete(function () { cargarTablaDetalle(); });
            //tabla_permisos_grupo.disableColumns(['radio', 'nro_permiso_grupo'], true);
            tabla_permisos_grupo.table_load_html();

        }

        function eliminar_fila(nro_permiso_grupo, permiso_grupo) {
            accion = "DELETE_GRUPO";
            if (!permiso_grupo)
                return

            Dialog.confirm("<b>¿Desea Eliminar el Grupo de Permisos?</b>",
                                  {
                                      width: 400,
                                      className: "alphacube",
                                      okLabel: "Aceptar",
                                      cancelLabel: "Cancelar",
                                      cancel: function (win) { win.close(); return },
                                      ok: function (win) {
                                          nvFW.error_ajax_request('permiso_abm_view_standard.aspx',
                                           {
                                               parameters: { modo: 'M', accion: accion, nro_permiso_grupo: nro_permiso_grupo, nro_permiso: permiso_grupo },
                                               onSuccess: function (err, transport) {
                                                   if (err.numError == 0) {
                                                       tabla_permisos_grupo.refresh();
                                                   }
                                                   else {
                                                       alert(err.mensaje)
                                                   }
                                               }
                                           });
                                          win.close()
                                      }
                                  });
        }

        //marcar en negrita el detalle, y volverlo clickeable
        var vectorPermiso = [];
        function cargarVectorPermiso() {
            var rs = new tRS();
            var criterio = filtroVectorPermiso
            rs.open(criterio);
            var i = 1;

            while (!rs.eof()) {
                vectorPermiso[i] = rs.getdata('hardcode');
                rs.movenext();
                i++;
            }
        }

        var filaActual = 1;
        var nro_permiso_grupo;
        function cargarTablaDetalle() {
            try {
                $("checkbox" + filaActual).checked = true;

                nro_permiso_grupo = tabla_permisos_grupo.getFila(filaActual)["nro_permiso_grupo"];
                permiso_detalle_cargar(nro_permiso_grupo);
            }
            catch (e) {
                alert("No existen permisos asociados");
            }
        }


        function check_permiso_grupo_onclick(fila) {


            if (checkBoxChanged) {
                var r = confirm("Se realizaron cambios sobre los permisos activos, ¿esta seguro que desea descartar los cambios?")
                if (!r) {
                    $("checkbox" + filaActual).checked = true;
                    return;
                }
                else {
                    checkBoxChanged = false;
                }
            }

            filaActual = fila;
            var filaSeleccionada = tabla_permisos_grupo.getFila(fila);

            nro_permiso_grupo = filaSeleccionada["nro_permiso_grupo"];
            var filtro = "<nro_permiso_grupo type='igual'>" + nro_permiso_grupo + "</nro_permiso_grupo>"
            tabla_permisos_detalle.refresh(filtro);
        }

        var tablaDetalleCarg = false;
        var tabla_permisos_detalle;
        function permiso_detalle_cargar(indice) {

            var filtro = "<nro_permiso_grupo type='igual'>" + indice + "</nro_permiso_grupo>"
            if ('<% = nro_permiso_get  %>' != '')
                filtro += "<nro_permiso type='igual'>" + '<% = nro_permiso_get  %>' + "</nro_permiso>"

            if (tablaDetalleCarg) {
                tabla_permisos_detalle.refresh(filtro);
                return;
            }



            var i = 0
            var criterio = filtroCargarDetalle

            tabla_permisos_detalle = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_permisos_detalle.nombreTabla = "tabla_permisos_detalle";
            //Agregamos consulta XML
            tabla_permisos_detalle.filtroXML = criterio
            tabla_permisos_detalle.filtroWhere = filtro;
            tabla_permisos_detalle.cabeceras = ["-", "Nro", "Bit", "Descripcion", "-"];
            tabla_permisos_detalle.eliminable = false;
            tabla_permisos_detalle.editable = false;
            tabla_permisos_detalle.async = true;
            tabla_permisos_detalle.mostrarAgregar = false;
            tabla_permisos_detalle.camposHide = [{ nombreCampo: "nro_permiso_grupo" }]

            tabla_permisos_detalle.campos = [

            {
                nombreCampo: "detalle", enDB: false, width: "10%", get_html: function (campo, nombre, fila) { return "<input type='checkbox' onchange='checkBoxCambio()' id='checkboxDetalle" + campo.fila + "' />" }
            },
            {
                nombreCampo: "nro_permiso", width: "5%", nro_campo_tipo: 104, ordenable: false
            },
            {
                nombreCampo: "numero", width: "20%", nro_campo_tipo: 104, ordenable: false
            },
            {
                nombreCampo: "permitir", width: "35%", nro_campo_tipo: 104, get_html: function (campo, nombre, fila) { return "<b><u><p id='permisoDetalle" + campo.fila + "' onclick='cambiar_desc_detalle(" + fila[1].valor + ",\"" + campo.valor + "\")' style='cursor:hand'>" + campo.valor + "</p></u></b>"; }
            },
            {
                nombreCampo: "botonCopiar", enDB: false, width: "20%", get_html: function (campo, nombre, fila) { return "<input type='button' value='Copiar' + ' onclick='aplicar_a_todos_perfiles(" + campo.fila + ")' />" }
            }
            ];

            tabla_permisos_detalle.addOnComplete(function () { tablaDetalleCarg = true; });
            tabla_permisos_detalle.addOnComplete(function () { obtener_permiso(); });
            tabla_permisos_detalle.addOnComplete(
                function () {
                    if (comparar)
                        obtener_permiso_comp();
                }
            );

            tabla_permisos_detalle.table_load_html();
        }

        var checkBoxChanged = false;
        function checkBoxCambio() {
            checkBoxChanged = true;
        }

        function aplicar_a_todos_perfiles(index) {

            var tiene_permiso = $('checkboxDetalle' + index).checked == true ? 1 : 0

            var nro_permiso = tabla_permisos_detalle.getFila(index)["nro_permiso"];
            var nombre_permiso = tabla_permisos_detalle.getFila(index)["permitir"];;

            var str
            if (tiene_permiso == 1)
                str = "¿Desea que el permiso: <b>" + nombre_permiso + "</b><br/> este <b>habilitado</b> para todos los perfiles?"
            else
                str = "¿Desea que el permiso: <b>" + nombre_permiso + "</b><br/> este <b>deshabilitado</b> para todos los perfiles?"

            Dialog.confirm(str, {
                width: 400,
                className: "alphacube",
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    guardar_a_todos_perfiles(nro_permiso_grupo, nro_permiso, tiene_permiso)
                    win.close()
                }
            });
        }

        function guardar_a_todos_perfiles(nro_permiso_grupo, nro_permiso, tiene_permiso) {
            nvFW.error_ajax_request('permiso_abm_view_standard.aspx', {
                encoding: 'ISO-8859-1',
                parameters: { modo: 'M', accion: 'PERMISO_COPIAR_PERFILES', nro_permiso_grupo: nro_permiso_grupo, nro_permiso: nro_permiso, tiene_permiso: tiene_permiso },
                onSuccess: tabla_permisos_grupo.refresh()
            });
        }

        function cambiar_desc_detalle(nro_permiso, permiso_nombre) {

            Dialog.confirm("<b>Ingrese la nueva descripción:</b> <div style='width:100%' id='divPermitir'><br/><input id='txt_permitir' style='width:80%' value='" + permiso_nombre + "'/></div>",
                                 {
                                     width: 400,
                                     className: "alphacube",
                                     okLabel: "Aceptar",
                                     cancelLabel: "Cancelar",
                                     onShow: function (win) { $('txt_permitir').focus() },
                                     cancel: function (win) { win.close(); return },
                                     ok: function (win) {
                                         if ($('txt_permitir').value != "") {
                                             var permitir = $('txt_permitir').value

                                             if (nro_permiso_grupo > 0)
                                                 guardar_descripcion('UPDATE_DETALLE_PERMISO', nro_permiso_grupo, nro_permiso, permitir, undefined, permitir)
                                         }
                                         else {
                                             alert("Ingrese la descripción")
                                             return
                                         }
                                         win.close()
                                     }
                                 });
        }

        function cambiar_desc_grupo(nro_permiso_grupo, permiso_grupo) {

            Dialog.confirm("<b>Ingrese la nueva descripción:</b> <div style='width:100%' id='divPermitir'><br/><input id='txt_permitir' style='width:80%' value='" + permiso_grupo + "'/></div>",
                                 {
                                     width: 400,
                                     className: "alphacube",
                                     okLabel: "Aceptar",
                                     cancelLabel: "Cancelar",
                                     onShow: function (win) { $('txt_permitir').focus() },
                                     cancel: function (win) { win.close(); return },
                                     ok: function (win) {

                                         if ($('txt_permitir').value != "") {
                                             var permitir = $('txt_permitir').value

                                             if (nro_permiso_grupo > 0)
                                                 guardar_descripcion('UPDATE_GRUPO', nro_permiso_grupo, permiso_grupo, permitir, permiso_grupo, undefined)
                                         }
                                         else {
                                             alert("Ingrese la descripción")
                                             return
                                         }
                                         win.close()
                                     }
                                 });
        }

        function guardar_descripcion(accion, nro_permiso_grupo, nro_permiso, permitir, permiso_grupo, permiso_nombre) {

            nro_permiso = !nro_permiso ? '' : nro_permiso

            nvFW.error_ajax_request('permiso_abm_view_standard.aspx',
             {
                 parameters: { modo: 'M', accion: accion, nro_permiso_grupo: nro_permiso_grupo, nro_permiso: nro_permiso, permitir: permitir },
                 onSuccess: function (err, transport) {
                     if (accion == 'UPDATE_GRUPO') {
                         tabla_permisos_grupo.refresh();
                     }
                     if (accion == 'UPDATE_DETALLE_PERMISO') {
                         tabla_permisos_detalle.refresh();
                     }

                 }
             });

        }

        function nuevo_grupo() {
           
            Dialog.confirm("<b>Ingrese El nuevo Grupo:</b> <div style='width:100%' id='divNuevoGrupo'><br/><input id='txt_nuevo_grupo' style='width:80%' value=''/></div>",
                                 {
                                     width: 400,
                                     className: "alphacube",
                                     okLabel: "Aceptar",
                                     cancelLabel: "Cancelar",
                                     onShow: function (win) { $('txt_nuevo_grupo').focus() },
                                     cancel: function (win) { win.close(); return },
                                     ok: function (win) {
                                         if ($('txt_nuevo_grupo').value != "") {
                                             nvFW.error_ajax_request('permiso_abm_view_standard.aspx', {
                                                 encoding: 'ISO-8859-1',
                                                 parameters: { modo: 'M', accion: 'ALTA_GRUPO', strXML: '', nro_permiso_grupo: 0, permiso_grupo: $('txt_nuevo_grupo').value },
                                                 onSuccess: function (err) {
                                                     cargarVectorPermiso()
                                                     tabla_permisos_grupo.refresh()
                                                 }
                                             });
                                         }
                                         else {
                                             alert("Ingrese la descripción")
                                             return
                                         }
                                         win.close()
                                     }
                                 });
        }

        function obtener_permiso() {

            var filtroPermiso = "<nro_permiso_grupo type='igual'>" + nro_permiso_grupo + "</nro_permiso_grupo><tipo_operador type='in'>" + $('tipo_operador_get').value + "</tipo_operador>"
            if ('<% = nro_permiso_get  %>' != '')
                filtroPermiso += "<nro_permiso type='igual'>" + '<% = nro_permiso_get  %>' + "</nro_permiso>"

            var rs = new tRS();
            var i = 1
            var criterio = filtroObtenerPermiso
            rs.open(criterio, '', filtroPermiso, '', '')

            while (!rs.eof()) {
                if ($('checkboxDetalle' + i)) {
                    $('checkboxDetalle' + i).checked = rs.getdata('tiene_permiso') == 1 ? true : false;
                }
                i++
                rs.movenext();
            }
        }

        function obtener_permiso_comp() {

            var tipo_operador_comp = $('tipo_operador_comp_get').value

            var filtroPermiso = "<nro_permiso_grupo type='igual'>" + nro_permiso_grupo + "</nro_permiso_grupo><tipo_operador type='in'>" + tipo_operador_comp + "</tipo_operador>"
            if ('<% = nro_permiso_get  %>' != '')
                filtroPermiso += "<nro_permiso type='igual'>" + '<% = nro_permiso_get  %>' + "</nro_permiso>"

            if (tipo_operador_comp != '') {
                var rs = new tRS();
                var i = 1
                var criterio = filtroObtenerPermisoComp
                rs.open(criterio, '', filtroPermiso, '', '')

                while (!rs.eof()) {

                    if ($('checkboxDetalle' + i).checked == true && rs.getdata('tiene_permiso') == 1)
                        $('permisoDetalle' + i).setStyle({ color: 'green' })

                    if ($('checkboxDetalle' + i).checked == false && rs.getdata('tiene_permiso') == 0)
                        $('permisoDetalle' + i).setStyle({ color: 'green' })

                    if ($('checkboxDetalle' + i).checked == false && rs.getdata('tiene_permiso') == 1)
                        $('permisoDetalle' + i).setStyle({ color: 'violet' })

                    if ($('checkboxDetalle' + i).checked == true && rs.getdata('tiene_permiso') == 0)
                        $('permisoDetalle' + i).setStyle({ color: '#749BC4' })

                    i++
                    rs.movenext()
                }
            }
        }

        function formar_xml() {
            var xmldato = ""

            tipo_operador = $('tipo_operador_get').value == 0 ? '' : $('tipo_operador_get').value
            xmldato += "<operador_permiso_all tipo_operador ='" + tipo_operador + "'>"
            xmldato += "<permiso_grupo>"

            var contador = 0;

            for (var i = 1; i < tabla_permisos_detalle.indexReal(tabla_permisos_detalle.cantFilas) ; i++) {

                var check = $('checkboxDetalle' + i).checked;

                var nro_permiso_grupo2 = tabla_permisos_detalle.getFila(i)["nro_permiso_grupo"]
                var nro_permiso2 = tabla_permisos_detalle.getFila(i)["nro_permiso"]

                contador += (check) ? Math.pow(2, nro_permiso2 - 1) : 0;


            }

            xmldato += "<operador_permiso_grupo nro_permiso_grupo='" + nro_permiso_grupo2 + "' permiso_grupo='' permiso='" + contador + "'/>";

            xmldato += "</permiso_grupo>"
            xmldato += "</operador_permiso_all>"

            return xmldato;
        }

        function obtenerPermiso(nro_permiso_grupo2) {

        }

        function guardar() {
            if ($('tipo_operador_get').value == 0 || $('tipo_operador_get').value == "") {
                alert("Seleccione el tipo de operador.");
                return
            }

            var xmldato = formar_xml();
            if (xmldato == "") {
                alert("Seleccione un perfil");
                return;
            }

            nvFW.error_ajax_request('permiso_abm_view_standard.aspx', {
                encoding: 'ISO-8859-1',
                parameters: { modo: 'M', accion: 'UPDATE_PERMISO', strXML: xmldato },
                onSuccess: function () {
                    tabla_permisos_detalle.refresh()
                    checkBoxChanged = false;
                }
            });
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divCab_h = $('divMenuABM').getHeight()

                $('divTabla_permisos_grupo').setStyle({ 'height': body_h - divCab_h - dif })
                $('divTabla_permisos_detalle').setStyle({ 'height': body_h - divCab_h - dif })

                tabla_permisos_grupo.resize()
                tabla_permisos_detalle.resize()
            }
            catch (e) { }
        }

        var filtroGrupo = "";
        var filtroDetalle = "";
        var changeGrupo
        var changeDetalle
        function buscar() {

            var nombreGrupo = campos_defs.get_value("defNombreGrupo")
            var descripcionPermiso = campos_defs.get_value("defDescripcionPermiso")

            if (nombreGrupo) {
                filtroGrupo = "<permiso_grupo type='like'>%" + nombreGrupo + "%</permiso_grupo>"
            }
            else {
                filtroGrupo = ""
            }

            if (descripcionPermiso) {
                filtroDetalle = "<permitir type='like'>%" + descripcionPermiso + "%</permitir>"
            }
            else {
                filtroDetalle = ""
            }

            var entrarEnDetalle = true

            var rs = new tRS()
            rs.open("<criterio><select vista='operador_permiso_detalle'><campos>nro_permiso_grupo,nro_permiso,permitir,ISNULL(power(2, nro_permiso -1),0) as numero</campos><filtro></filtro><orden>nro_permiso</orden></select></criterio>", '', filtroDetalle)

            var busqueda = "";
            while (!rs.eof()) {
                busqueda += rs.getdata("nro_permiso_grupo")
                rs.movenext()
                if ((!rs.eof()))
                    busqueda += ","
            }

            if (!filtroGrupo) {
                filtroGrupo = "<permiso_grupo type='like'>%</permiso_grupo>"
            }
            if (busqueda)
                filtroGrupo += "<nro_permiso_grupo type='in'>" + busqueda + "</nro_permiso_grupo>"

            tabla_permisos_grupo.refresh(filtroGrupo)

        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <input type="hidden" id="tipo_operador_get" value="<%= tipo_operador_get%>" />
    <input type="hidden" id="tipo_operador_comp_get" value="<%= tipo_operador_comp_get%>" />

    <div id="divMenuABM" style="width: 100%"></div>
    <script type="text/javascript" language="javascript">

        var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
        vMenuABM.loadImage("guardar", "/fw/image/icons/guardar.png")
        vMenuABM.loadImage("nueva", "/fw/image/icons/file.png")
        Menus["vMenuABM"] = vMenuABM
        Menus["vMenuABM"].alineacion = 'centro';
        Menus["vMenuABM"].estilo = 'A';

        Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar Permisos Activos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Visualización Tipo Standard</Desc></MenuItem>")
        vMenuABM.MostrarMenu()

    </script>

    <div id="div_buscador">

        <table class="tb1 highlightEven highlightTROver scroll">
            <tr>
                <td>Nombre del Grupo
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('defNombreGrupo', {
                            nro_campo_tipo: 104,
                            enDB: false
                        });
                    </script>
                </td>
                <td style="width:25%">Descripcion del permiso
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('defDescripcionPermiso', {
                            nro_campo_tipo: 104,
                            enDB: false
                        });
                    </script>
                </td>
                <td style="width:25%">
                    <input style="width:100%" type="button" value="Buscar" onclick="buscar()" />
                </td>
                <tr>
        </table>



    </div>

    <div style="width: 49%; height: 100%; display: inline-block; overflow: hidden;" id='divTabla_permisos_grupo'>
        <div id='tabla_permisos_grupo' style="overflow: hidden;"></div>
    </div>
    <div style="width: 49%; height: 100%; display: inline-block; overflow: hidden;" id='divTabla_permisos_detalle'>
        <div id='tabla_permisos_detalle' style="overflow: hidden;"></div>
    </div>

</body>
</html>
