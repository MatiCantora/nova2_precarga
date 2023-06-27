<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>

<%
    Dim nro_ref As String = nvFW.nvUtiles.obtenerValor("nro_ref", "")
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    

    Me.addPermisoGrupo("permisos_referencias")
    Me.addPermisoGrupo("permisos_web")
    Me.addPermisoGrupo("permisos_parametros")
    Me.addPermisoGrupo("permisos_seguridad")
    Me.addPermisoGrupo("permisos_tareas")

    Me.contents("filtroRecargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>doc_orden</orden><filtro><ref_doc_activo type='igual'>1</ref_doc_activo></filtro><grupo></grupo></select></criterio>")

    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    If accion.ToLower = "menu" Then
        Dim menu As New nvFW.nvBasicControls.tMenu
        menu.responseXML()
    End If

    Me.contents("filtroRecargar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>doc_orden</orden><filtro><ref_doc_activo type='igual'>1</ref_doc_activo></filtro><grupo></grupo></select></criterio>")
    Me.contents("filtroTareas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>%fe_desde%</fe_desde><fe_hasta DataType='datetime'>%fe_hasta%</fe_hasta><strWhere> nro_tarea_estado = 1 </strWhere><strOrder>fe_inicio,nro_tarea</strOrder><strTop>10</strTop></parametros></procedure></criterio>")
    Me.contents("filtroReferenciaUltimaModificada") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>DISTINCT TOP 10 nro_ref, referencia, MAX(ref_doc_fe_estado), CONVERT(VARCHAR(12), MAX(ref_doc_fe_estado), 103) AS fecha,CONVERT(VARCHAR(5), MAX(ref_doc_fe_estado), 108) AS hora</campos><filtro><ref_doc_activo type='igual'>1</ref_doc_activo></filtro><orden>MAX(ref_doc_fe_estado) DESC</orden><grupo>nro_ref, referencia</grupo></select></criterio>")
    Me.contents("filtroReferenciaSuscripciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ref_sus_operador'><campos>*</campos><filtro><operador type='igual'>dbo.rm_nro_operador()</operador></filtro><orden></orden><grupo></grupo></select></criterio>")
    Me.contents("filtroReferenciaNoGuardada") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_autoguardado'><campos>TOP 10 nro_ref, referencia, CONVERT(VARCHAR(12), ref_auto_fecha, 103) AS fecha,CONVERT(VARCHAR(5), ref_auto_fecha, 108) AS hora, id_ref_auto</campos><filtro><operador type='igual'>dbo.rm_nro_operador()</operador></filtro><orden>ref_auto_fecha DESC</orden><grupo></grupo></select></criterio>")
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>NOVA Wiki</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_wiki.ico" />
    
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/swfobject.js"></script>
    <script type="text/javascript" src="/fw/script/utiles.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">


        function open_nvFW_window(url) {
            
            /*var strReg = "mostrar_ref.aspx?.*nro_ref=(\\d*)"
            var reg = new RegExp(strReg, "i")
            var m = reg.exec(url)
            if (m != null) {
                var parametros = '<parametros><permisos_referencias>' + window.top.permiso_grupos["permisos_referencias"] + '</permisos_referencias></parametros>'
                url = url + "&parametros=" + encodeURIComponent(parametros)
            }*/
            
            var win = nvFW.createWindow({
                url: url,
                title: '<b></b>',
                width: "840",
                height: "550",
                minimizable: true,
                maximizable: true,
                resizable: true,
                draggable: true,
                destroyOnClose: true,
                onClose: function () { }
            });
            //win.maximize();
            win.showCenter();

            // cerrar automaticamente si no se mostró contenido.
            // Por ej, cuando se linkea a un archivo que no se puede ver en el browser como un docx
            setTimeout(function () {
                try {
                    if (win.content.contentWindow.document.body.innerHTML == "") {
                        win.close()
                    }
                }
                catch (e) { }
            }, 3000)

        }


        //var wikiPermisoRef = tWikiPermisoRef()
        
//        var permiso_referencia = 0

//        function cargarPermisoReferencia(nro_ref)
//        {
//            if (nro_ref == undefined || nro_ref == "") {
//                permiso_referencia = 0
//                return
//            }

//            nvFW.error_ajax_request("default.aspx", {
//                parameters: {
//                    modo:    'get_permiso_referencia',
//                    nro_ref: nro_ref
//                },
//                onSuccess: function(err) {
//                    permiso_referencia = parseInt(err.params["permiso_referencia"], 10)
//                },
//                onFailure: function(err) {
//                    permiso_referencia = 0
//                },
//                bloq_contenedor_on: false,  // no bloquear, solo se usa de llamada
//                error_alert: false
//            })
//        }


//        /*----------------------------------------------------------------
//        |   tipo_permiso: valores posibles
//        |-----------------------------------------------------------------
//        | #     | Valor | Descripción
//        |-----------------------------------------------------------------
//        | [1]   | 1     | subir archivo
//        | [2]   | 2     | borrar
//        | [3]   | 4     | modificar
//        | [4]   | 8     | leer (por defecto)
//        | [5]   | 16    | administrar permisos
//        | [6]   | 31    | TODOS los permisos (suma todos los anteriores)
//        |---------------------------------------------------------------*/
//        function tienePermisoReferencia(tipo_permiso)
//        {
//            tipo_permiso = parseInt(tipo_permiso || 2, 10)  // tipo_permiso default = 2 -> leer
//            var valor    = tipo_permiso == 6 ? 31 : Math.pow(2, tipo_permiso - 1)
//            return (valor & permiso_referencia) > 0
//        }

//        function tienePermisoReferencia(nro_ref, tipo_permiso) {
//            cargarPermisoReferencia(nro_ref)
//            return tienePermisoReferencia(tipo_permiso)
//        }


    </script>

    <script type="text/javascript">
        /**********************************/
        // nro_ref <> '' 
        // Mostrar la referencia indicada
        /**********************************/
        var nro_ref = '<%= nro_ref %>',
            win     = nvFW.getMyWindow(),
            // Obtener las referencias hacia todas las ventanas a utilizar
            win_divMenuContent, // = ObtenerVentana('divMenu_content'),
            win_frameRef, // = ObtenerVentana('frame_ref')
            /***    Abre la pantalla de Búsqueda de Referencias    ***/
            winBuscar = null


//        // Usar la funcion homonima en utiles.js
//        function abrir_ventana_emergente(path, descripcion, permiso_grupo, nro_permiso, height, width, minimizable, maximizable, resizable, draggable) {

//            if (!nvFW.tienePermiso(permiso_grupo, nro_permiso)) {
//                alert("No tiene permisos para acceder a esta opción", { title: "Permisos insuficientes", height: 70, width: 300 })
//                return
//            }

//            // Medidas por defecto en caso que no esten definidas
//            width = width || 1024
//            height = height || 512
//            minWidth = width / 2
//            minHeight = height / 2
//            minimizable = minimizable !== undefined ? minimizable : false
//            maximizable = maximizable !== undefined ? maximizable : false
//            resizable = resizable !== undefined ? resizable : false
//            draggable = draggable !== undefined ? draggable : true

//            var win = nvFW.createWindow({
//                url: path,
//                title: '<b>' + descripcion + '</b>',
//                width: width,
//                height: height,
//                minWidth: minWidth,
//                minHeight: minHeight,
//                minimizable: minimizable,
//                maximizable: maximizable,
//                resizable: resizable,
//                draggable: draggable,
//                destroyOnClose: true,
//                onClose: function () { }
//            });

//            win.showCenter(true);
//        }


        function Busqueda(e, modulo) {
            if (nvFW.tienePermiso('permisos_referencias', 1)) {

                //cambiar_a_modulo(modulo)
                if (winBuscar == null) {
                    // deshabilitar "Enter to Tab" en el buscador
                    nvFW.enterToTab = false

                    var srcElement = Event.element(e)

                    while (srcElement.tagName.toUpperCase() != 'TD')
                        srcElement = srcElement.up()

                    var pos = srcElement.cumulativeOffset()

                    winBuscar = nvFW.createWindow({
                        title: "<b>Buscar</b>",
                        width: 400,
                        height: 200,
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        resizable: false,
                        onShow: function () {
                            $('txtBuscar').focus()
                        },
                        onClose: function (win) {
                            win.destroy();
                            winBuscar = null
                        }
                    })

                    var strHTML = ''
                    strHTML += '<div id="divBuscar" style="width: 100%; font-size:13px;">'
                    strHTML += '<table class="tb1">'
                    strHTML += '<tr>'
                    strHTML += '<td style="width: 95%"><input type="text" style="width:100%" id="txtBuscar" onkeypress="enter_buscar(event)" /></td>'
                    strHTML += '<td><img src="/fw/image/icons/buscar.png" style="cursor:pointer" onclick="doc_buscar()"/></td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:5px 5px 0 10px;" type="checkbox" id="rFreeText">Busqueda por texto libre</td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 18px;">'
                    strHTML += '<td colspan="2" nowrap ><b>Buscar Referencia en:</b></td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:0 5px 0 10px;" type="checkbox" id="rNombre" checked="true">Busqueda por Nombre</td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:0 5px 0 10px;" type="checkbox" id="rTitulo" checked="true">Busqueda por Titulo</td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:0 5px 0 10px;" type="checkbox" id="rCuerpo" checked="true">Busqueda por Contenido</td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 18px;">'
                    strHTML += '<td colspan="2" nowrap ><b>Buscar texto en Archivo:</b></td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:0 5px 0 10px;" type="checkbox" id="aContenido" checked="true">Busqueda en Contenido</td>'
                    strHTML += '</tr>'
                    strHTML += '<tr style="height: 20px;">'
                    strHTML += '<td colspan="2" nowrap ><input style="border:0;margin:0 5px 0 10px;" type="checkbox" id="aPropiedades" checked="true">Busqueda en Propiedades</td>'
                    strHTML += '</tr>'
                    strHTML += '</table>'
                    strHTML += '</div>'

                    winBuscar.setLocation(pos.top + srcElement.getHeight(), $$('BODY')[0].getWidth() - winBuscar.element.getWidth())// getSize()
                    winBuscar.setHTMLContent(strHTML)
                }
                winBuscar.show(false);
            }
            else {
                // habilitar "Enter to Tab" nuevamente
                nvFW.enterToTab = true
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
            }
        }

        /***    Realiza la búsqueda de referencias, al presionar enter en el campo de búsqueda   ***/
        function enter_buscar(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                doc_buscar()
        }

        /***    Muestra el resultado de la búsqueda de referencias en la pantalla "Resultado de la Búsqueda"   ***/
        function doc_buscar() {
            var valor = $('txtBuscar').value,
                tipo_consulta = $('rFreeText').checked == true ? 1 : 0,
                rNombre = $('rNombre').checked == true ? 1 : 0,
                rTitulo = $('rTitulo').checked == true ? 1 : 0,
                rCuerpo = $('rCuerpo').checked == true ? 1 : 0,
                aContenido = $('aContenido').checked == true ? 1 : 0,
                aPropiedades = $('aPropiedades').checked == true ? 1 : 0,
                winBuscar_res = {}

            if (valor.length > 3) {
                winBuscar_res = nvFW.createWindow({
                    url: 'ref_busqueda.aspx?valor=' + valor + '&tipo_consulta=' + tipo_consulta + '&rNombre=' + rNombre + '&rTitulo=' + rTitulo + '&rCuerpo=' + rCuerpo + '&aContenido=' + aContenido + '&aPropiedades=' + aPropiedades,
                    title: '<b>Resultado de la Búsqueda con: "' + valor + '"</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    resizable: false,
                    width: 700,
                    height: 300,
                    destroyOnClose: true,
                    onShow: function (win) {
                        Windows.windows.each(function (arreglo, i) {
                            if (arreglo['element'].id == win.element.id) {
                                if (i > 0) {
                                    if (arreglo['element'].offsetTop == win.element.offsetTop && arreglo['element'].offsetLeft == win.element.offsetLeft) {
                                        win_top = win.element.offsetTop + (i * 20)
                                        win_left = win.element.offsetLeft + (i * 20)
                                    }
                                }
                            }
                        });
                        win.setLocation(win_top, win_left)
                    }
                });
                winBuscar_res.showCenter()
            }
            else {
                alert('La palabra a buscar tiene que ser mayor a tres caracteres')
            }
        }

        /***    Muestra el contenido de una referencia en el iframe de inicio   ***/
        function frame_ref_recargar(nro_ref) {
            //si "nro_ref" es undefined es porque salio del editor por el close

            //si "nro_ref" es mayor a cero es porque no se elimino
            if (nro_ref > 0) {
                var filtroXML = nvFW.pageContents.filtroRecargar,
                    filtroWhere = "<criterio><select><campos>*</campos><orden>doc_orden</orden><filtro><nro_ref type='in'>" + nro_ref + "</nro_ref></filtro><grupo></grupo></select></criterio>"

                nvFW.exportarReporte({
                    filtroXML: filtroXML,
                    filtroWhere: filtroWhere,
                    formTarget: 'frame_ref',
                    xsl_name: "HTML_Ref_doc_datos.xsl",
                    nvFW_mantener_origen: true,
                    id_exp_origen: 0,
                    parametros: '<parametros><app_path_rel>' + window.top.app_path_rel + '</app_path_rel><permisos_referencias>' + window.top.permiso_grupos["permisos_referencias"] + '</permisos_referencias></parametros>'
                })
            }
            //si "nro_ref" es menor a cero  ->  referencia eliminada
            if (nro_ref < 0) {
                win_divMenuContent.node_global = ''
                win_frameRef.location.href = 'enBlanco.htm'
                win_divMenuContent.location.href = 'ref_tree.aspx'
            }
        }

        /***    Se llama desde la plantilla "HTML_ref_doc_datos.xsl" al cerrar la ventana ABM Referencias ***/
        function abrir_ventana_emergente_OnClose(nro_ref) {
             
            var vTree = win_divMenuContent.vTree
                
            vTree.recargar_nodo('A0000B0000')
            vTree.MostrarArbol()

            var nro_ref = nro_ref 

            if (nro_ref < 0)
                win_frameRef.location.href = '/fw/enBlanco.htm'
            if (nro_ref > 0)
                win_divMenuContent.ref_mostrar(nro_ref)
        }

        function cambiar_a_modulo(modulo) {
            if (modulo == 'referencias' && win_divMenuContent.document.location.pathname != "/wiki/ref_tree.aspx") {
                win_divMenuContent.location.href = 'ref_tree.aspx'
                win_frameRef.location.href = '/fw/enBlanco.htm'
                return
            }

            if (modulo == 'tareas' && win_frameRef.document.location.pathname != "/wiki/mis_tareas.aspx") {
                win_divMenuContent.location.href = '/fw/enBlanco.htm'
                win_frameRef.location.href = 'mis_tareas.aspx'
                return
            }
        }

        function Referencia_ABM(nro_ref)
        {
            // 'permisos_referencias' => [3] 'editar referencia'
            if (!nvFW.tienePermiso('permisos_referencias', 3)) {
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
                return
            }
            else {
                cambiar_a_modulo('referencias')

                if (!nro_ref)
                    nro_ref = ''

                if (nro_ref == '') {
                    try {
                        nro_ref = win_frameRef.nro_ref
                    }
                    catch (e) { }
                }

                if (nro_ref != '') {
                    var URL = "Referencias_ABM.aspx?nro_ref2=" + nro_ref,
                        win_top,
                        win_left

                    win = nvFW.createWindow({
                        title: "<b>Editor de Referencia</b>",
                        minimizable: true,
                        maximizable: true,
                        url: URL,
                        minWidth: 1200,
                        minHeight: 800,
                        destroyOnClose: true,
                        maximize: true,
                        onShow: function (win) {
                            win_top = win.element.offsetTop
                            win_left = win.element.offsetLeft

                            Windows.windows.each(function (arreglo, i) {
                                if (arreglo['element'].id == win.element.id) {
                                    if (i > 0) {
                                        win_top = arreglo['element'].offsetTop + (i * 20)
                                        win_left = arreglo['element'].offsetLeft + (i * 20)
                                    }
                                }
                            });

                            win.centerTop = win_top
                            win.centerLeft = win_left
                            win.setLocation(win_top, win_left)
                        },
                        onClose: function () {
                            var vTree = win_divMenuContent.vTree,
                                indice = vTree.length - 1
                            vTree[indice].recargar_nodo('A0000B0000')
                            vTree[indice].MostrarArbol()
                            nro_ref = win.options.userData

                            if (nro_ref < 0)
                                win_frameRef.location.href = '/fw/enBlanco.htm'

                            if (nro_ref > 0)
                                win_divMenuContent.ref_mostrar(nro_ref)
                        },
                        onMinimize: function (win) {
                            if (win.isMaximized() == true)
                                win.maximize()

                            Windows.windows.each(function (arreglo, i) {
                                if (arreglo['element'].id == win.element.id) {
                                    switch (i) {
                                        case 0:
                                            win_top = $$('BODY')[0].getHeight() - arreglo.element.getHeight()
                                            break;
                                        default:
                                            restar = arreglo.element.getHeight() * (i + 1)
                                            win_top = $$('BODY')[0].getHeight() - restar
                                            break;
                                    }
                                }
                            });

                            win_left = 1

                            if (win.isMinimized() == true)
                                win.setLocation(win_top, win_left)
                            else
                                win.setLocation(win.centerTop, win.centerLeft)
                        },
                        onEndMove: function (win) {
                            var left_win = parseInt(win.getLocation()['left'].split('px')[0]),
                                top_win = parseInt(win.getLocation()['top'].split('px')[0]),

                                width_win = win.width,
                                height_win = win.height,

                                posicion_w = (left_win + width_win)

                            if (((posicion_w - $('divVidrio').getWidth()) > 680) || (posicion_w < 20) || (top_win < -20) || (top_win + 20 > $('divVidrio').getHeight()))
                                win.setLocation(win.centerTop, win.centerLeft)
                        }
                    })
                    win.showCenter();
                    win.maximize()
                }
            }
        }

        function frame_tree_recargar(nro_ref) {
            if (nro_ref != undefined)
                if (parseInt(nro_ref, 10) > 0) {
                    var rs = new tRS();
                    rs.open("<criterio><select vista='verTree_nodos_dep_ref'><campos>distinct nodo_id</campos><filtro><h_nro_ref type='igual'>" + nro_ref + "</h_nro_ref></filtro><orden></orden></select></criterio>")

                    if (!rs.eof())
                        win_divMenuContent.node_global_actual = rs.getdata('nodo_id')
                }

            if (win_divMenuContent.document.location.pathname == "/wiki/ref_tree.aspx")
                win_divMenuContent.actualizar_tree()
            else
                win_divMenuContent.location.href = 'ref_tree.aspx'
        }

        var winSusc = false;

        function suscripciones(e) {
            if (winSusc === false) {
                var srcElement = Event.element(e);
                srcElement = srcElement.up('TABLE');
                var pos = srcElement.cumulativeOffset();

                winSusc = nvFW.createWindow({
                    title: "<b>Suscripciones</b>",
                    width: 400,
                    height: 260,
                    minimizable: false,
                    maximizable: false,
                    closable: true,
                    draggable: true,
                    resizable: false,
                    id: 'suscripciones_sub_window',
                    destroyOnClose: true,
                    onShow: function () { },
                    onClose: function (win) {
                        winSusc = false;
                    }
                });

                winSusc.showCenter();
                winSusc.setHTMLContent('<iframe id="suscripciones_sub_window_iframe" name="suscripciones_sub_window_iframe" width="398px" height="258px" style="border: 1px solid #666666;"></iframe>');

                var options = {
                    formTarget: "suscripciones_sub_window_iframe",
                    filtroXML: nvFW.pageContents.filtroReferenciaSuscripciones,
                    path_xsl: "report\\verRef_docs\\HTML_inicio_suscripciones.xsl",
                    bloq_contenedor: $$('BODY')[0]
                };
                exportarReporte(options);
            }
        }

        function ultimasReferenciasModificadas(e) {
            if (winSusc === false) {
                var srcElement = Event.element(e);
                srcElement = srcElement.up('TABLE');
                var pos = srcElement.cumulativeOffset();

                winSusc = nvFW.createWindow({
                    title: "<b>Últimas referencias modificadas</b>",
                    width: 400,
                    height: 260,
                    minimizable: false,
                    maximizable: false,
                    closable: true,
                    draggable: true,
                    resizable: false,
                    id: 'ultimasReferenciasModificadas_sub_window',
                    destroyOnClose: true,
                    onShow: function () { },
                    onClose: function (win) {
                        winSusc = false;
                    }
                });

                winSusc.showCenter();
                winSusc.setHTMLContent('<iframe id="ultimasReferenciasModificadas_sub_window_iframe" name="ultimasReferenciasModificadas_sub_window_iframe" width="398px" height="258px" style="border: 1px solid #666666;"></iframe>');

                var options = {
                    formTarget: "ultimasReferenciasModificadas_sub_window_iframe",
                    filtroXML: nvFW.pageContents.filtroReferenciaUltimaModificada,
                    path_xsl: "report\\verRef_docs\\HTML_inicio_referencias.xsl",
                    bloq_contenedor: $$('BODY')[0]
                };
                exportarReporte(options);
            }
        }

        function tareasPendientes(e) {

            window.top.abrir_ventana_emergente('/wiki/mis_tareas.aspx?inNewWindow=1', 'Tareas', 'permisos_tareas', 1, 720, 1280, 1)

//            if (nvFW.tienePermiso("permisos_tareas", 1)) {
//                // Obtener medidas de la pantalla para centrar la nueva ventana
//                var screenWidth = window.top.screen.width,
//                    screenHeight = window.top.screen.height,
//                    width = 1280,
//                    height = 720,
//                    top = ~ ~((screenHeight - height) / 2), // ~~ captura la parte entera del número flotante
//                    left = ~ ~((screenWidth - width) / 2)

//                //window.open("/wiki/mis_tareas.aspx?inNewWindow=1", null, "top=" + top + ", left=" + left + ", width=" + width + ", height=" + height)
//                
//            }
//            else
//                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
//            

            //if (winSusc === false) {
            //    var srcElement = Event.element(e);
            //    srcElement = srcElement.up('TABLE');
            //    var pos = srcElement.cumulativeOffset();

            //    winSusc = nvFW.createWindow({
            //        title: "<b>Tareas Pendientes</b>",
            //        width: 450,
            //        height: 210,
            //        minimizable: false,
            //        maximizable: false,
            //        closable: true,
            //        draggable: true,
            //        resizable: false,
            //        id: 'tareasPendientes_sub_window',
            //        destroyOnClose: true,
            //        onShow: function () {},
            //        onClose: function (win) {
            //            winSusc = false;
            //        }
            //    });

            //    winSusc.showCenter(true);
            //    winSusc.setLocation(pos.top, $$('BODY')[0].getWidth() - winSusc.element.getWidth());
            //    winSusc.setHTMLContent('<iframe id="tareasPendientes_sub_window_iframe" name="tareasPendientes_sub_window_iframe" width="100%" height="100%" style="border: 1px solid #CFCFCF;"></iframe>');

            //    var fe_desde = FechaToSTR(parseFecha('1/1/2000'), 2),
            //        fe_hasta_plus_one = new Date()
            //    fe_hasta_plus_one.setDate(fe_hasta_plus_one.getDate() + 1) // se necesita sumarle un dia mas a la fecha limite, sino no captura bien los datos el SP
            //    var fe_hasta = FechaToSTR(parseFecha(fe_hasta_plus_one.toJSON().slice(0, 10)), 2),
            //        parametros = "<criterio><params fe_desde='" + fe_desde + "' fe_hasta='" + fe_hasta + "' /></criterio>",

            //        options = {
            //            formTarget: "tareasPendientes_sub_window_iframe",
            //            filtroXML: nvFW.pageContents.filtroTareas,
            //            params: parametros,
            //            path_xsl: "report\\verTarea\\HTML_inicio_tareas.xsl",
            //            bloq_contenedor: "tareasPendientes_sub_window_iframe"
            //        };
            //    exportarReporte(options);
            //}
        }

        function referenciasNoGuardadas(e) {
            if (winSusc === false) {
                var srcElement = Event.element(e);
                srcElement = srcElement.up('TABLE');
                var pos = srcElement.cumulativeOffset();

                winSusc = nvFW.createWindow({
                    title: "<b>Referencias no guardadas</b>",
                    width: 400,
                    height: 260,
                    minimizable: false,
                    maximizable: false,
                    closable: true,
                    draggable: true,
                    resizable: false,
                    id: 'referenciasNoGuardadas_sub_window',
                    destroyOnClose: true,
                    onShow: function () { },
                    onClose: function (win) {
                        winSusc = false;
                    }
                });

                winSusc.showCenter();
                winSusc.setHTMLContent('<iframe id="referenciasNoGuardadas_sub_window_iframe" name="referenciasNoGuardadas_sub_window_iframe" width="398px" height="258px" style="border: 1px solid #666666;"></iframe>');
                winSusc._options = {
                    formTarget: "referenciasNoGuardadas_sub_window_iframe",
                    filtroXML: nvFW.pageContents.filtroReferenciaNoGuardada,
                    path_xsl: "report\\verRef_docs\\HTML_inicio_referencias_no_guardadas.xsl",
                    bloq_contenedor: $$('BODY')[0]
                };
                exportarReporte(winSusc._options);
            }
        }

        var file = null

        function administrador_file(modulo) {
            if (nvFW.tienePermiso('permisos_referencias', 1)) {
                cambiar_a_modulo(modulo)
                file = nvFW.createWindow({
                    title: "<b>ABM archivos</b>",
                    width: 800,
                    height: 450,
                    minimizable: true,
                    draggable: false,
                    minWidth: 600,
                    minHeight: 300,
                    destroyOnClose: true,
                    url: "file_abm.aspx"
                })

                file.showCenter(true);
            }
            else
                alert('No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema.')
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2,
                    body_heigth = $$('body')[0].getHeight(),
                    cab_heigth = $('tb_cab').getHeight(),
                    a = $('tb_body')

                a.setStyle({ 'height': body_heigth - cab_heigth - dif })

                $("menu_left").setStyle({ 'height': body_heigth - cab_heigth - dif })
                $('frame_ref').setStyle({ 'height': body_heigth - cab_heigth - dif })

                if (win.isMaximized() == true)
                    win.maximize()
            }
            catch (e) { }
        }

        var DocumentMNG = new tDMOffLine
        var vMenu = new tMenu('div_Menu', 'vMenu');

        function window_onload() {
            win_divMenuContent = ObtenerVentana('divMenu_content'),
            win_frameRef = ObtenerVentana('frame_ref')

            var tact = new Date(),
            //Importante: Nombre de la ventana que contendrá los documentos 
                TargetDocumentos = 'lado',
                e;
            if (nro_ref != '')
                win_divMenuContent.ref_mostrar(nro_ref)

            // cargar menu
            vMenu.alineacion = 'izquierda';
            vMenu.estilo = 'O'
            vMenu.loadImage("inicio", "/fw/image/icons/home.png")
            vMenu.loadImage("upload", "/wiki/image/icons/upload.png")
            vMenu.loadImage("ref", "/fw/image/icons/info.png")
            vMenu.loadImage("nueva", "/fw/image/icons/nueva.png")
            vMenu.loadImage("servicio_asignar", "/fw/image/icons/play.png")
            vMenu.loadImage("buscar", "/fw/image/icons/buscar.png")
            vMenu.loadImage("vincular", "/wiki/image/icons/vincular.png")
            vMenu.loadImage("herramientas", "/fw/image/icons/herramientas.png")
            vMenu.loadImage("permiso", "/fw/image/icons/permiso.png")
            vMenu.loadImage("imprimir", "/fw/image/icons/imprimir.png")
            vMenu.loadImage("operador", "/fw/image/icons/personas.png")
            vMenu.loadImage("parametros", '/FW/image/transferencia/parametros.png')
            vMenu.loadImage("sistema", '/FW/image/sistemas/sistema.png')
            vMenu.loadImage('seguridad', '/FW/image/icons/periodo.png')
            vMenu.loadImage('login', '/FW/image/icons/login.png')
            vMenu.loadImage('play', '/FW/image/icons/bajar.png')
            vMenu.loadImage('servicio_asignar', '/FW/image/icons/servicio_asignar.png')
            vMenu.loadImage("imprimir", "/fw/image/icons/imprimir.png")

            //var xml_menu_filename = 'ref_mnu_cabecera'
            //var path_xml_menu_file = '/wiki/DocMNG/Data/' + xml_menu_filename + '.xml'
            //DocumentMNG.APP_PATH = window.location.href;
            //var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', 'ref_mnu_cabecera')
            //var strXML = DocumentMNG.GetDocumentXML('DocMNG', 'GetMenuItems', path_xml_menu_file)
            var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?> <resultado> <MenuItems> <MenuItem id='1'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>inicio</icono> <Desc>Inicio</Desc> <Acciones> <Ejecutar Tipo='link'> <Target>_top</Target> <URL>default.aspx</URL> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='20'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>upload</icono> <Desc>Archivos</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>nvFW.file_dialog_show()</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='30'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>ref</icono> <Desc>Referencia</Desc> <MenuItems> <MenuItem id='31'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>nueva</icono> <Desc>Nueva</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/wiki/referencias_abm.aspx', 'Editar Referencia', 'permisos_referencias', 1, 600, 1200, false, true, true, true, false, window.top.abrir_ventana_emergente_OnClose)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='32'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>ref</icono> <Desc>Últimas Modificadas</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>ultimasReferenciasModificadas(event)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='33'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>servicio_asignar</icono> <Desc>Suscripciones</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>suscripciones(event)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='34'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>ref</icono> <Desc>Sin Guardar</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>referenciasNoGuardadas(event)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='35'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>imprimir</icono> <Desc>Configurar impresión pdf</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/wiki/ref_pre_export_pdf.aspx?save_db=1', 'Configurar impresión pdf', 'permisos_parametros', 1, 256, 418, true, false, false, true, false)</codigo> </Ejecutar> </Acciones> </MenuItem> </MenuItems> </MenuItem>  <MenuItem id='40'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>buscar</icono> <Desc>Buscar Referencia</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>Busqueda(event,'referencias')</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='50'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>vincular</icono> <Desc>Tareas</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>tareasPendientes(event)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='55'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>herramientas</icono> <Desc>Herramientas</Desc> <MenuItems> <MenuItem id='56'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>parametros</icono> <Desc>Parámetros - Asignación</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/fw/parametros/parametros_nodos_modulo.aspx?accion=asignar','Parámetros - Asignación','permisos_parametros',2,600,1000, true, true, true, true, false)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='57'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>parametros</icono> <Desc>Parámetros - ABM Esquema</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/fw/parametros/parametros_nodos_modulo.aspx','Esquema de Parámetros','permisos_parametros',1,600,1000, true, true, true, true, false)</codigo> </Ejecutar> </Acciones> </MenuItem>  <MenuItem id='59'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>play</icono> <Desc>PKI ABM</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/fw/pki/pki_nodos_tree.aspx', 'PKI - ABM', 'permisos_parametros', 1, 500, 1000, true, true, true, true)</codigo> </Ejecutar> </Acciones> </MenuItem> </MenuItems> </MenuItem>  <MenuItem id='60'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>seguridad</icono> <Desc>Seguridad</Desc> <MenuItems> <MenuItem id='61'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>permiso</icono> <Desc>ABM Operadores</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/FW/security/operador_consultar.aspx','Seguridad - Accesos','permisos_seguridad',1,500,1000)</codigo> </Ejecutar> </Acciones> </MenuItem> <MenuItem id='62'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>permiso</icono> <Desc>Cambiar Contraseña</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/FW/security/operador_pwd_cambiar.aspx','Seguridad - Cambiar Contraseña','permisos_seguridad',1,160,500, true, false, true, false, false)</codigo> </Ejecutar> </Acciones> </MenuItem> <MenuItem id='63'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>permiso</icono> <Desc>ABM Permisos WIKI</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/fw/security/permiso_abm.aspx','ABM Permisos de WIKI','permisos_seguridad',3,600,1000, true, true, true, true, false)</codigo> </Ejecutar> </Acciones> </MenuItem> <MenuItem id='64'> <Lib TipoLib='offLine'>DocMNG</Lib> <icono>permiso</icono> <Desc>ABM Esquema</Desc> <Acciones> <Ejecutar Tipo='script'> <codigo>window.top.abrir_ventana_emergente('/fw/security/permiso_nodos_tree.aspx','Esquema de Permisos','permisos_seguridad',2,600,1000, true, true, true, true, false)</codigo> </Ejecutar> </Acciones> </MenuItem> </MenuItems> </MenuItem> </MenuItems> </resultado>"
            vMenu.CargarXML(strXML);
            vMenu.MostrarMenu();

            window_onresize();
        }


        function prototype_window(obj) {
            return new Window(obj);
        }


        function ver_info_operador() {
            var win = nvFW.createWindow({
                url: '/fw/security/operador_abm.aspx?modoInfoOperador=1',
                title: '<b>Información del Operador</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 800,
                height: 345,
                resizable: true,
                destroyOnClose: true
            });
            win.options.userData = {}
            win.options.userData.login = login
            win.showCenter(true)
        }

        function tree_ordenar(modulo) {
            cambiar_a_modulo(modulo)

            win = nvFW.createWindow({
                url: '../wiki/ref_tree_ordenar.aspx',
                title: '<b>Ordenamiento</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 350,
                height: 300,
                onClose: function () { win_divMenuContent.location.href = '../../wiki/ref_tree.aspx' }
            });

            win.showCenter(true)
        }

        function nv_sistemas_cambiar(sistema, ventana) {
            nvFW.abrir_sistema(sistema, ventana)
        }

        function sica_control_res() {
            var Parametros = new Array(),
                win = nvFW.createWindow({
                    url: '/FW/sica/sica_control_integridad.aspx?modo=currentApp',
                    title: '<b>Control de Integridad</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 650,
                    height: 350,
                    destroyOnClose: true,
                    onClose: function () {
                        var success = win.options.userData.retorno["success"]
                        if (success) { }
                    }
                });
            win.options.userData = { retorno: Parametros }
            win.options.data = {};
            win.showCenter();
        }
    </script>
    <script type="text/javascript">
        function tb_body_resize_inicio() {
            var body = $$('BODY')[0]

            if ($('tb_body_div_hide') == null) {
                var strHTML = '<div id="tb_body_div_hide" style="width: 100%; height: 100%; position: absolute; z-index: 1000; float: left; background-color: gray"></div>'
                body.insert({ top: strHTML })
                var oDIV = $("tb_body_div_hide")
                Element.setOpacity(oDIV, 0.0)
                strHTML = '<div id="tb_body_div_rec" style="position: absolute; z-index: 1000; float: left; background-color: gray"></div>'
                body.insert({ top: strHTML })
                var oDIV_rec = $("tb_body_div_rec")
                Element.setOpacity(oDIV_rec, 0.5)
                td_move = $('tb_body_td_move')
                oDIV_rec.setStyle({ width: td_move.getWidth(), height: td_move.getHeight() })
            }
            else {
                $('tb_body_div_hide').show()
                var oDIV_rec = $('tb_body_div_rec')
                oDIV_rec.show()
            }

            Element.clonePosition(oDIV_rec, td_move)
            body.setStyle({ cursor: 'w-resize' })

            Event.observe(body, 'mousemove', tb_body_resize_mousemove);
            Event.observe(body, 'mouseup', tb_body_resize_fin);
        }

        function tb_body_resize_fin() {
            var body = $$('BODY')[0],
                oDIV_rec = $('tb_body_div_rec'),
                oDIV = {}

            $('tb_body_td').setStyle({ width: oDIV_rec.getStyle('left') })
            Event.stopObserving(body, 'mousemove', tb_body_resize_mousemove);

            oDIV = $("tb_body_div_hide")
            body.setStyle({ cursor: 'default' })
            oDIV.hide()
            oDIV_rec.hide()
        }

        function tb_body_resize_mousemove(e) {
            try {
                var nuevoX = Event.pointerX(e) - 4
                $('tb_body_div_rec').setStyle({ left: nuevoX })
                document.selection.clear()
            }
            catch (e) { }
        }
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden;">
    <form action='' id="ventana_nueva" target="_blank" method="get" style="display: none;"></form>
    <table id="tb_cab" cellspacing="0" border="0" cellpadding="0" style="width: 100%; height: 64px;">
        <tr>
            <td rowspan="2" id="logo_rm" style="WIDTH: 424px; HEIGHT: 64px">
                <object style="WIDTH: 140px; HEIGHT: 64px" data="/wiki/image/cabecera/Logo_Nova_Inicio_wiki.svg" type="image/svg+xml"></object>
            </td>
            <td>
                <table cellpadding="0" cellspacing="0" border="0" style="width: 100%">
                    <tr>
                        <td id="user_name" style="text-align: right" nowrap>
                            <% = nvApp.operador.nombre_operador.ToString %>
                        </td>
                    </tr>
                    <tr>
                        <td id="data_user" style="text-align: right; vertical-align: middle" nowrap>
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Información de sesión"
                                title="Información de sesión" src="/FW/image/icons/sesion_info.png" onclick="javascript:ver_info_operador()" />
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Bloquear sesión"
                                title="Bloquear sesión" src="/FW/image/tSession/sesion_bloquear.png" onclick="nvSesion.bloquear()" />
                            <img border="0" class="img_button" align="absmiddle" hspace="2" alt="Cerrar sesión"
                                title="Cerrar sesión" src="/FW/image/tSession/sesion_cerrar.png" onclick="nvSesion.cerrar()" />
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td colspan="10">
                <div id="div_Menu" style="width: 100%"></div>
            </td>
        </tr>
    </table>
    <table class="tb1" id="tb_body" cellpadding="0" cellspacing="0" border="0" style="width: 100%; height: 100%">
        <tr>
            <td id="tb_body_td" style="width: 300px;vertical-align:top">
                <iframe src="menu_left.aspx" id="menu_left" name="menu_left" style="width: 100%; height: auto; border: none; overflow: hidden;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
            <td id="tb_body_td_move" style="font-size: 10; width: 2px; cursor: w-resize;" onmousedown="javascript:tb_body_resize_inicio()">
                &nbsp;
            </td>
            <td>
                <iframe src="enBlanco.htm" id="frame_ref" name="frame_ref" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            </td>
        </tr>
    </table>
</body>
</html>