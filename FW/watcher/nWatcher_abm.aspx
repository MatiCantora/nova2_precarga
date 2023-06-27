<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

    If (strXML <> "") Then
        Dim er As New tError
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("fw_instancia_watcher_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

        Try
            Dim rs As ADODB.Recordset = cmd.Execute()
            er = New nvFW.tError(rs)
        Catch ex As Exception
            er.parse_error_script(ex)
            er.numError = 104
            er.titulo = "Error en el SP"
            er.mensaje = "Error en el SP fw_instancia_watcher_abm"

        End Try
        er.response()
    End If

    Me.contents("id_nvwinstancia") = nvFW.nvUtiles.obtenerValor("id_nvwinstancia", "")
    Me.contents("watchers") = nvXMLSQL.encXMLSQL("<criterio><select vista='verNvw_Instancias_Watchers'><campos>*</campos><orden>nvwLabel</orden><filtro></filtro></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Watcher</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_basicControls.js"></script>
     
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script> 
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <%= Me.getHeadInit() %>

    <script type="text/javascript">

        var nro_permiso_editar_watchers;
        
        function window_onload()
        {
            var ventana = nvFW.getMyWindow()

            if (ventana.options.userData == undefined)
                ventana.options.userData = {}

            ventana.options.userData.hay_modificacion = false

            var id_nvwinstancia = nvFW.pageContents.id_nvwinstancia

            campos_defs.items["nro_instancias"]["onchange"] = function () {
                
                var rs = new tRS()
                rs.asyc = true
                rs.onComplete = function (rs) {
                    nvFW.bloqueo_desactivar($$("BODY")[0], "rsOnload");

                    //campos_defs.set_value("nro_instancias", rs.getdata("nvwInstancia"))
                    campos_defs.set_value('el_machine', rs.getdata("el_machine"));
                    campos_defs.set_value('el_log', rs.getdata("el_log"));
                    campos_defs.set_value('el_source', rs.getdata("el_source"));
                    campos_defs.set_value('el_cn', rs.getdata("el_cn"));

                    nro_permiso_editar_watchers = rs.getdata("nro_permiso_editar_watchers");

                }

                var id = nvFW.pageContents.id_nvwinstancia = campos_defs.value("nro_instancias");
                // Si "id_nvwinstancia" esta vacio, no hacer la query
                if (id != "") {
                    //campos_defs.items["nro_instancias"].input_text.readOnly = true;
                    nvFW.bloqueo_activar($$("BODY")[0], "rsOnload");
                    var filtroWhere = "<criterio><select><filtro><id_nvwinstancia type='igual'>'" + id + "'</id_nvwinstancia></filtro></select></criterio>";
                    rs.open({ filtroXML: nvFW.pageContents.watchers, filtroWhere: filtroWhere });
                    watcher_cargar(id);
                    $$("#watcherContainer")[0].show();
                }
                else {
                    limpiar_campos();
                    $$("#watcherContainer")[0].hide();
                }
                    
            }
            campos_defs.set_value("nro_instancias", id_nvwinstancia);

        }

        
        function limpiar_campos() {

            nvFW.pageContents.id_nvwinstancia = "";

            campos_defs.items["nro_instancias"].input_text.focus();

            // limpiar todos los campos
            campos_defs.set_value('el_machine', "")
            campos_defs.set_value('el_log', "")
            campos_defs.set_value('el_source', "")
            campos_defs.set_value('el_cn', "")

            // volvemos a generar la tabla vacia
            watcher_cargar();   
        }

        /*---------------------------------------------------------
        | ALTA
        |----------------------------------------------------------
        | Función para agregar una
        | nueva instancia
        |
        |--------------------------------------------------------*/
        function instancia_nueva() {
            campos_defs.set_value("nro_instancias", "");
            nueva_instancia_onclick();
        }


        /*---------------------------------------------------------
        | MODIFICACION
        |----------------------------------------------------------
        | Funcion para modificar los campos de una instancia
        | existente
        |
        |--------------------------------------------------------*/ 
        function instancia_guardar()
        {           
            // Validaciones
            if (campos_defs.desc("nro_instancias") == "") {
                alert("No ha ingresado el valor para <b>Instancia</b>")
                return
            }
            if (campos_defs.get_value("el_machine") == "") {
                alert("No ha ingresado el valor para <b>Máquina</b>")
                return
            }
            if (campos_defs.get_value("el_log") == "") {
                alert("No ha ingresado el valor para <b>Log</b>")
                return
            }
            if (campos_defs.get_value("el_source") == "") {
                alert("No ha ingresado el valor para <b>Source</b>")
                return
            }

            // armar el XML de edición instancia watcher (accion = "W")
            var strXML = '<nWatcher><nvwInstancias accion="W" id_nvwinstancia="' + campos_defs.get_value("nro_instancias")
                + '" nvwInstancia="' + campos_defs.desc("nro_instancias")
                + '" el_machine="' + campos_defs.value("el_machine")
                + '" el_log="' + campos_defs.value("el_log")
                + '" el_source="' + campos_defs.value("el_source")
                + '" el_cn="' + campos_defs.value("el_cn") + '" />'

            strXML += '<nvwWatchers>';
            
            for (var i = 1; i < tabla_watcher.cantFilas; i++) {
                var row = tabla_watcher.getFila(i);
                if (!row.eliminado) {
                    if (row.nvwLabel) {
                        if (!row.dirOrigen) {
                            alert("Complete los datos para el watcher, campo: <b>Origen</b>");
                            return;
                        } else if (!row.dirDestino) {
                            alert("Complete los datos para el watcher, campo: <b>Destino</b>");
                            return;
                        } else if (!row.seg_timeout) {
                            alert("Complete los datos para el watcher, campo: <b>Timeout</b>");
                            return;
                        }
                        strXML += '<watcher id_nvwWatcher="' + (row.id_nvwWatcher ? row.id_nvwWatcher : 0)
                            + '" nvwLabel="' + row.nvwLabel
                            + '" dirOrigen="' + row.dirOrigen
                            + '" dirDestino="' + row.dirDestino
                            + '" dirBackup="' + row.dirBackup
                            + '" addPrefijo="' + (row.addPrefijo ? 1 : 0)
                            + '" addPosFijo="' + (row.addPosFijo ? 1 : 0)
                            + '" dirFiltro="' + row.dirFiltro
                            + '" includeDir="' + (row.includeDir ? 1 : 0)
                            + '" seg_timeout="' + row.seg_timeout + '" />'
                    }
                }
            }
            strXML += '</nvwWatchers></nWatcher>';
            
            var er = nvFW.error_ajax_request("nWatcher_abm.aspx", {
                                                    parameters: {strXML: strXML}
                                                    ,onSuccess: function()
                                                                   {
                                                                    var win = nvFW.getMyWindow()
                                                                    win.options.userData.hay_modificacion = true
                                                                    win.close()
                                                                   } 
                                                    ,error_alert: true  
            })


        }

        /*---------------------------------------------------------
        | BAJA / ELIMINACION
        |----------------------------------------------------------
        | Función para eliminar una instancia, pidiendo confirmación
        | antes de realizar la acción
        |
        |--------------------------------------------------------*/ 
        function instancia_eliminar()
        {
            if (nvFW.pageContents.id_nvwinstancia == "") {
                nvFW.alert("El ID (instancia) no está definido para ser eliminado", {title: "Error al eliminar", okLabel: "Aceptar"})
                return
            }

            // dialogo de confirmacion
            nvFW.confirm("¿Está seguro que desea eliminar la instancia <b>" + nvFW.pageContents.id_nvwinstancia + "</b>?", 
                {
                    title: "Eliminar instancia",
                    onOk: function ()
                    {
                        // armar el XML de eliminación (accion = "E")
                        var strXML = "<nWatcher><nvwInstancias accion='E' id_nvwinstancia='" + nvFW.pageContents.id_nvwinstancia + "'/></nWatcher>" 
                        // ejecutar la accion
                        var er = nvFW.error_ajax_request("nWatcher_abm.aspx", 
                            {
                                parameters: {strXML: strXML},
                                onSuccess: function()
                                {
                                    var win = nvFW.getMyWindow()
                                    win.options.userData.hay_modificacion = true
                                    win.close()
                                },
                                error_alert: true
                            }
                        )
                    },
                    onCancel: function()
                    {
                        // volver a la ventana de edicion
                        return
                    }
                }
            )
        }

        var tabla_watcher;

        function watcher_cargar(id_nvwinstancia) {
            tabla_watcher = new tTable();
            tabla_watcher.cn = '';

            if (id_nvwinstancia) {
                tabla_watcher.filtroXML = nvFW.pageContents.watchers;
                tabla_watcher.filtroWhere = "<criterio><select><filtro><id_nvwinstancia type='igual'>'" + id_nvwinstancia + "'</id_nvwinstancia><SQL type='sql'>id_nvwWatcher is not null</SQL></filtro></select></criterio>"
            }
            else
                tabla_watcher.data = [];
            
            tabla_watcher.nombreTabla = "tabla_watcher";
            tabla_watcher.editable = true;
            tabla_watcher.eliminable = true;
            tabla_watcher.mostrarAgregar = true;
            tabla_watcher.cabeceras = ["Label", "Dir Origen", "Dir Destino", "Dir Backup", "Agregar Prefijo", "Agregar Posfijo", "Filtro", "Incluir Dir", "Timeout (seg)"];

            tabla_watcher.camposHide = [{ nombreCampo: "id_nvwWatcher" }];
            tabla_watcher.campos = [
                {
                    nombreCampo: "nvwLabel",
                    width: "20%",
                    editable: true,
                    nro_campo_tipo: 104,
                    enDB: false,
                    ordenable: false
                },
                {
                    nombreCampo: "dirOrigen",
                    width: "15%",
                    editable: true,
                    nro_campo_tipo: 104,
                    enDB: false,
                    ordenable: false
                },
                {
                    nombreCampo: "dirDestino",
                    width: "15%",
                    editable: true,
                    nro_campo_tipo: 104,
                    enDB: false,
                    ordenable: false
                },
                {
                    nombreCampo: "dirBackup",
                    width: "15%",
                    editable: true,
                    nro_campo_tipo: 104,
                    enDB: false,
                    ordenable: false
                },
                {
                    nombreCampo: "addPrefijo",
                    width: "9%",
                    align: "center",
                    checkBox: true,
                    convertirValorBD: function (valor) {
                        return (valor == "True") ? 1 : 0;
                    },
                    nulleable: true
                },
                {
                    nombreCampo: "addPosFijo",
                    width: "9%",
                    align: "center",
                    checkBox: true,
                    convertirValorBD: function (valor) {
                        return (valor == "True") ? 1 : 0;
                    },
                    nulleable: true
                },
                {
                    nombreCampo: "dirFiltro",
                    editable: true,
                    nro_campo_tipo: 104,
                    enDB: false,
                    ordenable: false
                },
                {
                    nombreCampo: "includeDir",
                    width: "9%",
                    align: "center",
                    checkBox: true,
                    convertirValorBD: function (valor) {
                        return (valor == "True") ? 1 : 0;
                    },
                    nulleable: true
                },
                {
                    nombreCampo: "seg_timeout",
                    editable: true,
                    nro_campo_tipo: 100,
                    enDB: false,
                    ordenable: false
                }
            ];

            if (id_nvwinstancia)
                tabla_watcher.table_load_html();
            else
                tabla_watcher.mostrar_tabla(tabla_watcher);
            tabla_watcher.resize();
        }

        function nueva_instancia_onclick() {
            var win = nvFW.createWindow({
                url: "/FW/watcher/nWatcher_instancia_am.aspx?id_nvwinstancia=",
                width: "400",
                height: "150",
                top: "50",
                maximizable: false,
                minimizable: false,
                resizable: false,
                onClose: function (win) {
                    //Forzamos la carga del combo
                    campos_defs.items["nro_instancias"].input_select.length = 0
                    campos_defs.onclick(event, "nro_instancias", true)
                }
            });

            win.showCenter(true)
        }
        function editar_instancia_onclick() {
            var idInstancia = campos_defs.get_value("nro_instancias");
            var win = nvFW.createWindow({
                url: "/FW/watcher/nWatcher_instancia_am.aspx?id_nvwinstancia=" + idInstancia,
                width: "400",
                height: "150",
                top: "50",
                maximizable: false,
                minimizable: false,
                resizable: false,
                onClose: function (win) {
                    //Forzamos la carga del combo
                    campos_defs.items["nro_instancias"].input_select.length = 0
                    //campo_def_cb_onclick(event, "nro_instancias", idInstancia)
                    campos_defs.set_value("nro_instancias", idInstancia)
                }
            });

            win.showCenter(true)
        }

        function window_watcherabm_onresize() {
            try {
                var divW_h = $('watcherContainer').getHeight();
                var tbtabla_watcher = $('tbtabla_watcher');
                var body_h = $$('BODY')[0].getHeight();
                var tamanio = (body_h - divW_h)

                tbtabla_watcher.style.height = tamanio + "px"

                if (tabla_watcher)
                    tabla_watcher.resize();
            }
            catch (e) { }
        }
    </script>
</head>
<body style="overflow: hidden;" onload="window_onload()" onresize="window_watcherabm_onresize()">
    <table class="tb1">
        <tr>
            <td colspan="7">
                <div id="DIV_Menu" style="WIDTH: 100%"></div>
            </td>
        </tr>
        <script type="text/javascript">
            var vMenu = new tMenu('DIV_Menu','vMenu');
            vMenu.alineacion = 'centro'
            vMenu.estilo     = 'A'
   
            vMenu.loadImage("guardar", '/FW/image/icons/guardar.png')
            vMenu.loadImage('eliminar', '/FW/image/icons/eliminar.png')
            vMenu.loadImage('nuevo', '/FW/image/icons/nueva.png')
            
            vMenu.CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>instancia_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>ABM Instancia</Desc></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>instancia_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenu.CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>instancia_nueva()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenu.MostrarMenu();
        </script>

        <tr>
            <td class="Tit1" style="width: 40px">Instancia:</td>
            <td>
                <div style="width:80%; float:left"><% = nvFW.nvCampo_def.get_html_input("nro_instancias", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='nvwInstancias'><campos> distinct id_nvwinstancia as id, nvwInstancia as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>") %></div>
                <div>
                    <img border="0" onclick="nueva_instancia_onclick()" src="/FW/image/icons/agregar.png" title="nueva" style="cursor:pointer"/>
                    <img border="0" onclick="editar_instancia_onclick()" src="/FW/image/icons/editar.png" title="editar" style="cursor:pointer"/>
                </div>
            </td>
            <td class="Tit1" width="140px">Máquina:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("el_machine", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1" width="40px">Log:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("el_log", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>
        <tr>
            <td class="Tit1">Source:</td>
            <td>
                <% = nvFW.nvCampo_def.get_html_input("el_source", enDB:=False, nro_campo_tipo:=104) %>
            </td>
            <td class="Tit1" width="140px">Cadena de conexión:</td>
            <td colspan="3">
                <% = nvFW.nvCampo_def.get_html_input("el_cn", enDB:=False, nro_campo_tipo:=104) %>
            </td>
        </tr>
    </table>
    <div id="watcherContainer">
        <div id="divMemuWatcher" style="margin: 0px; padding: 0px;"></div>
        <script type="text/javascript">
            var vMemuWatcher = new tMenu('divMemuWatcher', 'vMemuWatcher');

            Menus["vMemuWatcher"] = vMemuWatcher
            Menus["vMemuWatcher"].alineacion = 'centro';
            Menus["vMemuWatcher"].estilo = 'A';

            vMemuWatcher.loadImage("guardar", '/FW/image/icons/guardar.png')

            Menus["vMemuWatcher"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;font-weight:bold'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Watchers:</Desc></MenuItem>")

            vMemuWatcher.MostrarMenu()
        </script>

        <div id="tbtabla_watcher" style="width: 100%; min-height: 100px;">
            <div id="tabla_watcher" style="width: 100%;"></div>
        </div>
    </div>
</body>
</html>