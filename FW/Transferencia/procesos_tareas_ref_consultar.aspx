<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    '******* vistas encriptadas 
    Me.contents("filtrotransf_procesos_tareas_consultar") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='transf_procesos_tareas_consultar'><orden></orden></procedure></criterio>")
    Me.contents("filtroverTransferencias") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransferencias'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    '*********** permisos
    Me.addPermisoGrupo("permisos_seguridad")
    Me.addPermisoGrupo("permisos_transferencia")
    Me.addPermisoGrupo("permisos_procesos_tareas")

%>
<html>
<head>
    <title></title>
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <%--<script type="text/javascript" src="/fw/script/window_utiles.js"></script>--%>
    <%= Me.getHeadInit()   %>
    <script type="text/javascript">


        //var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); } 

        var vButtonItems = {};

        vButtonItems[0] = {};
        vButtonItems[0]["nombre"] = "Btn_buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return Buscar_procesos()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/fw/image/icons/buscar.png')                                              // "Imagenes" está definida en "pvUtiles.asp"

        var win = nvFW.getMyWindow()

        function window_onload() {
            // mostramos los botones creados
            vListButtons.MostrarListButton()
            window_onresize()

            FiltroProceso("grupo_proceso")

        }

        function window_keypress(e) {
            var key = Prototype.Browser.IE ? event.keyCode : e.which
            if (key == 13)
                Buscar_procesos()
        }

        function Buscar_procesos(orden) {
            var filtro = ''
            var filtroXML = ''
            var filtroWhere = ''
            var xsl_name = ''
            var path_xsl = ''

            if ($('tdGrupoProceso').style.display != 'none') {
                if ($('sel_vigente').value == 'vigente')
                    filtro += "<vigente type='igual'>1</vigente>"

                if ($('sel_vigente').value == 'no_vigente')
                    filtro += "<vigente type='igual'>0</vigente>"

                if ($('modo_ejecucion').value == 'Asincronico') {
                    filtro += "<async type='igual'>1</async>"
                } else if ($('modo_ejecucion').value == 'Sincronico') {
                    filtro += "<async type='igual'>0</async>"
                }
                    

                if ($('detalle').value != "")
                    filtro += "<descripcion type='like'>%" + $('detalle').value + "%</descripcion>"

                //filtroXML = "<criterio><select vista='verGrupos_procesos_ref'><campos>*</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"
                var filtroParam = ''
                for (i in arrtparam) {
                    filtroParam += "<" + i + ">" + campos_defs.value(arrtparam[i]) + "</" + i + ">"
                }

                filtro += campos_defs.filtroWhere()

                filtroWhere = "<criterio><procedure><parametros><tipo_retorno>REF</tipo_retorno><select><filtro>" + filtro + "</filtro></select></parametros><orden></orden></procedure></criterio>"
                filtroXML = nvFW.pageContents.filtrotransf_procesos_tareas_consultar
                path_xsl = "\\report\\transferencia\\procesos_tareas\\HTML_Procesos_tareas_ref.xsl"

            }

            if ($('tdTransferencia').style.display != 'none') {
                if ($('id_transferencia1').value != '')
                    filtro = "<id_transferencia type='in'>" + $('id_transferencia1').value + "</id_transferencia>"

                if ($('nombre').value != '')
                    filtro += "<nombre type='like'>%" + $('nombre').value + "%</nombre>"

                if ($('login').value != '')
                    filtro += obtenerFiltroLogin('login', $('login').value)

                if ($('fe_ini').value != "")
                    filtro += "<transf_fe_modificado type='mas'>convert(datetime,'" + $('fe_ini').value + "',103)</transf_fe_modificado>"

                if ($('fe_fin').value != "")
                    filtro += "<transf_fe_modificado type='menos'>dateadd(day,1,convert(datetime,'" + $('fe_fin').value + "',103))</transf_fe_modificado>"

                filtro += "<SQL type='sql'>not(id_transferencia in (select distinct id_transferencia from verTransf_procesos_tareas_ref)) and habi = 'S' </SQL>"

                filtroWhere = "<criterio><select PageSize='" + setPageSize() + "' AbsolutePage='1'><campos></campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>"
                filtroXML = nvFW.pageContents.filtroverTransferencias
                path_xsl = "\\report\\transferencia\\verTransferencias\\HTML_verTransferencias.xsl"
            }


            nvFW.exportarReporte({
                filtroXML: filtroXML,
                path_xsl: path_xsl,
                filtroWhere: filtroWhere,
                formTarget: "iframe1",
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                bloq_contenedor: $("iframe1"),
                cls_contenedor: "iframe1"
            })
        }

        function obtenerFiltroLogin(campo, valor) {
            str = ''
            if ($('login').value.match(/\,/))
                str = "<" + campo + " type='in'>'" + replace(valor, ",", "','") + "'</" + campo + ">"
            else
                str = "<" + campo + " type='like'>%" + valor + "%" + "</" + campo + ">"
            return str
        }

        function setPageSize() {
            var pagesize = 100
            try {
                pagesize = Math.round($('iframe1').getHeight() / (20) - 1, 0)
                //restamos la cabecera y pie considero 4 el como las row de los mismos
                pagesize = pagesize - 2
            }
            catch (e) { }

            return pagesize
        }

        function transf_editar(id_transferencia) {
            window.open("/fw/transferencia/transferencia_ABM.aspx")
        }

        function seleccion(e, id_transferencia) {
            grupos_procesos_tareas_abm(0, id_transferencia)
        }

        function grupos_procesos_tareas_abm(nro_transf_pt_ref, id_transferencia) {
            if (nvFW.tienePermiso("permisos_procesos_tareas", 2)) {
                win = nvFW.createWindow({
                    url: '/fw/transferencia/procesos_tareas_ref_ABM.aspx?nro_transf_pt_ref=' + nro_transf_pt_ref + '&id_transferencia=' + id_transferencia,
                    title: '<b>Grupos Procesos y Tareas Referencia - ABM</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 800,
                    height: 250,
                    onClose: grupos_procesos_tareas_abm_return
                });

                win.showCenter(true)

            }
            else {
                alert('No posee los permisos necesarios para realizar esta acción')
                return
            }
        }

        function grupos_procesos_tareas_abm_return() {
            if (win.returnValue == 'OK') {
                var e
                try {
                    Buscar_procesos()
                }
                catch (e) { }
            }
        }

        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 2
            body_height = $$('body')[0].getHeight()
            cab_height = $('tbFiltro').getHeight()
            mnu_height = $('divMenuDatosRef').getHeight()
            try {
                $('iframe1').setStyle({ 'height': body_height - cab_height - mnu_height - dif + 'px' })
            }
            catch (e) { }
        }

        function FiltroProceso(tipo) {

            if (tipo == 'grupo_proceso') {
                $('tdGrupoProceso').show()
                $('tdTransferencia').hide()
                ObtenerVentana('iframe1').location.href = '/fw/enBlanco.htm'
                win.setTitle("<b>Grupos de Procesos y Tareas: Procesos Asociados</b>")
            }

            if (tipo == 'transferencia') {
                $('tdGrupoProceso').hide()
                $('tdTransferencia').show()
                ObtenerVentana('iframe1').location.href = '/fw/enBlanco.htm'
                win.setTitle("<b>Grupos de Procesos y Tareas: Procesos No Asociados</b>")
            }

        }

    </script>

</head>
<body onload="return window_onload()" onresize="window_onresize()" onkeypress="window_keypress(event)" style="width: 100%; height: 100%; overflow: hidden">
    <div id="divMenuDatosRef" style="margin: 0px; padding: 0px"></div>
    <script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vMenuDatosRef = new tMenu('divMenuDatosRef', 'vMenuDatosRef');
        Menus["vMenuDatosRef"] = vMenuDatosRef
        Menus["vMenuDatosRef"].alineacion = 'centro';
        Menus["vMenuDatosRef"].estilo = 'A';
        //Menus["vMenuDatosRef"].imagenes = Imagenes //Imagenes se declara en pvUtiles                  
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 5%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>filtro</icono><Desc>Procesos Asociados</Desc><Acciones><Ejecutar Tipo='script'><Codigo>FiltroProceso('grupo_proceso')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 5%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>filtro</icono><Desc>Procesos No Asociados</Desc><Acciones><Ejecutar Tipo='script'><Codigo>FiltroProceso('transferencia')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuDatosRef"].CargarMenuItemXML("<MenuItem id='3' style='WIDTH: 5%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>grupos_procesos_tareas_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDatosRef.loadImage("filtro", "/fw/image/transferencia/filtro.png")
        vMenuDatosRef.loadImage("buscar", "/fw/image/transferencia/buscar.png")
        vMenuDatosRef.loadImage("nueva", "/fw/image/transferencia/nueva.png")
        vMenuDatosRef.MostrarMenu()

    </script>
    <input type="hidden" name="ID" id="ID" value="" />
    <input type="hidden" name="modo" id="modo" value="" />

    <table class="tb1" id="tbFiltro">
        <tr>
            <td style="width: 85%" id="tdGrupoProceso">
                <table class="tb1">
                    <%
                        Dim strarrtparam = ""
                        Dim stretiqueta = ""
                        Dim strecuerpo = ""

                        Dim strSQL = "Select distinct id_transf_pt_param, campo_def,campo_etiqueta from transf_pt_params "
                        Dim rsTpram = nvDBUtiles.DBExecute(strSQL)
                        While Not (rsTpram.EOF)
                            stretiqueta += "<td style='width:22%;text-align:center'>" & rsTpram.Fields("campo_etiqueta").Value & "</td>"
                            strecuerpo += "<td>" & nvFW.nvCampo_def.get_html_input(rsTpram.Fields("campo_def").Value) & "</td>"

                            strarrtparam += " arrtparam['" & rsTpram.Fields("id_transf_pt_param").Value + "'] = '" & rsTpram.Fields("campo_def").Value & "' " & vbCr
                            rsTpram.MoveNext()
                        End While


                        nvDBUtiles.DBCloseRecordset(rsTpram)

                        Response.Write("<tr class='tbLabel'>")
                        Response.Write(stretiqueta)
                        Response.Write("<td style='width: 25%'>Descripción</td>")
                        Response.Write("<td style='width: 5%'>Estado</td>")
                        Response.Write("<td style='width: 5%'>Modo ejecucion</td>")
                        Response.Write("</tr>")

                        Response.Write("<tr>")
                        Response.Write(strecuerpo)
                        Response.Write("<td><input id='detalle' style='width: 100%' /></td>")
                        Response.Write("<td style='text-align: center'><select id='sel_vigente'><options><option value=''></option><option value='vigente' selected='selected'>Vigente</option><option value='no_vigente'>No Vigente</option></options></select></td>")
                        Response.Write("<td><select id='modo_ejecucion'><options><option value=''></option><option value='Asincronico' selected='selected'>Asincronico</option><option value='Sincronico'>Sincronico</option></options></select></td>")
                        Response.Write("</tr>")

                        Response.Write("<script type='text/javascript'>" & vbCr)
                        Response.Write("var arrtparam = {}" & vbCr)
                        Response.Write(strarrtparam)
                        Response.Write("</script>" & vbCr)

                    %>
                </table>

            </td>
            <td style="width: 85%; vertical-align: top; display: none" id="tdTransferencia">
                <table class="tb1" style="width: 100%">
                    <tr class="tbLabel">
                        <td style="width: 15%; text-align: center">Nro.</td>
                        <td style="text-align: center">Nombre</td>
                        <td style="width: 20%; text-align: center">Operadores</td>
                        <td style="width: 15%; text-align: center">Fecha Desde</td>
                        <td style="width: 15%; text-align: center">Fecha Hasta</td>
                    </tr>
                    <tr>
                        <td id="td_id_transferencia1">
                            <script type="text/javascript">campos_defs.add('id_transferencia1', { nro_campo_tipo: 101, enDB: false, target: 'td_id_transferencia1' })</script>
                        </td>
                        <td id="td_nombre">
                            <script type="text/javascript">campos_defs.add('nombre', { nro_campo_tipo: 104, enDB: false, target: 'td_nombre' })</script>
                        </td>
                        <td id="td_login">
                            <script type="text/javascript">campos_defs.add('login', { nro_campo_tipo: 104, enDB: false, target: 'td_login' })</script>
                        </td>
                        <td id="td_fe_ini">
                            <script type="text/javascript">campos_defs.add('fe_ini', { nro_campo_tipo: 103, enDB: false, target: 'td_fe_ini' })</script>
                        </td>
                        <td id="td_fe_fin">
                            <script type="text/javascript">campos_defs.add('fe_fin', { nro_campo_tipo: 103, enDB: false, target: 'td_fe_fin' })</script>
                        </td>
                    </tr>
                </table>
            </td>           
        </tr>
        <tr>
            <td>
                <div id="divBtn_buscar">
                </div>
            </td>
        </tr>
    </table>

    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 100%; overflow: hidden" frameborder="0" src="enBlanco.htm"></iframe>
</body>
</html>
