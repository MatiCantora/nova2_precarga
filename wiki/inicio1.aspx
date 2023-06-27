<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Me.contents("filtroUpdateRef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText = 'dbo.rm_ref_op_suscripcion' CommantTimeOut = '1500'><parametros><nro_ref DataType = 'int'>%nro_ref%</nro_ref></parametros></procedure></criterio>")
    Me.contents("filtroUltimasModificadas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>DISTINCT TOP 10 nro_ref, referencia, MAX(ref_doc_fe_estado), CONVERT(VARCHAR(12), MAX(ref_doc_fe_estado), 103) AS fecha,CONVERT(VARCHAR(5), MAX(ref_doc_fe_estado), 108) AS hora</campos><filtro><ref_doc_activo type='igual'>1</ref_doc_activo></filtro><orden>MAX(ref_doc_fe_estado) DESC</orden><grupo>nro_ref, referencia</grupo></select></criterio>")
    Me.contents("filtroTareasPendientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.operador_get_tareas' CommantTimeOut='1500'><parametros><fe_desde DataType='datetime'>1/1/1900</fe_desde><fe_hasta DataType='datetime'>1/1/2025</fe_hasta><strWhere> nro_tarea_estado = 1 </strWhere><strOrder>fe_inicio,nro_tarea</strOrder><strTop>10</strTop></parametros></procedure></criterio>")
    Me.contents("filtroSuscripciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_ref_sus_operador'><campos>*</campos><filtro><operador type='igual'>dbo.rm_nro_operador()</operador></filtro><orden></orden><grupo></grupo></select></criterio>")
    Me.contents("filtroNoGuardadas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_autoguardado'><campos>TOP 10 nro_ref, referencia, CONVERT(VARCHAR(12), ref_auto_fecha, 103) AS fecha,CONVERT(VARCHAR(5), ref_auto_fecha, 108) AS hora, id_ref_auto</campos><filtro><operador type='igual'>dbo.rm_nro_operador()</operador></filtro><orden>ref_auto_fecha DESC</orden><grupo></grupo></select></criterio>")
    Me.contents("filtroEliminarNoGuardadas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_ref_autoguardado_baja' CommantTimeOut='1500'><parametros><id_ref_auto DataType='int'>%id_ref_auto%</id_ref_auto></parametros></procedure></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Wiki Inicio</title>
        <%--<meta http-equiv="x-ua-compatible" content="IE=8" />--%>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/wiki/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/wiki/css/gadget.css" rel="stylesheet" type="text/css"/> 

        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/wiki/script/gadget.js"></script>
        <script type="text/javascript" src="/wiki/script/tareas.js"></script> <%-- Libreria para levantar instancia tareaABM y funcionalidades relacionadas --%>

        <%= Me.getHeadInit() %>

        <script type="text/javascript">
            var t_layout,
                inicio_referencias,
                tareas_pendientes,
                referencias_no_guardadas,
                win_MenuLeft = {};
            
            function suscripcion_referencia(nro_ref) {
                var dejar_de = (nro_ref < 0) ? 'dejar de ' : '';

                window.top.nvFW.confirm('¿Desea ' + dejar_de + 'recibir las actualizaciones de la referencia?', {
                    width: 320,
                    height: 90,
                    onOk: function(win) {
                        updateRefOp(nro_ref);
                        win.close();
                        t_layout.refresh(inicio_referencias);
                    },
                    onCancel: function(win) {
                        win.close();
                    }
                });
            }

            function updateRefOp(nro_ref) {
                var alert_1 = 'Se subscribió a la referencia',
                    alert_2 = 'No se puedo realizar la operación',
                    rs = new tRS();

                if (nro_ref < 0) {
                    alert_1 = alert_2;
                    alert_2 = 'Se elimino subscripción a la referencia';
                }
                
                rs.open({
                    filtroXML: nvFW.pageContents.filtroUpdateRef,
                    params: "<criterio><params nro_ref='" + nro_ref + "'></params></criterio>"
                });
                
                !rs.eof() ? alert(alert_1) : alert(alert_2);

                /*if (!rs.eof()) {
                    alert(alert_1);
                } else {
                    alert(alert_2);
                }*/
            }

            document.observe("dom:loaded", function() {

                // capturar la ventana de uso comun "menu_letf"
                win_MenuLeft = ObtenerVentana('menu_left')

                if (window.top.editAutoguardadaRef)
				{
                    verRefEditar(0, window.top.editAutoguardadaRef);
                } else if (window.top.showRef) {
                    verRef(window.top.showRef,  window.top.event);
                    window.top.showRef = false;
                    window.top.event = false
                } else {
                    t_layout = new tGadget({container: $('container'), gap: 20});
                    t_layout.add({
                        title: 'Últimas referencias modificadas',
                        content: {
                            filtroXML: nvFW.pageContents.filtroUltimasModificadas,
                            path_xsl: "report\\verRef_docs\\HTML_inicio_referencias.xsl"
                        },
                        min_width: 350,
                        height: 250
                    });
                    tareas_pendientes = t_layout.add({
                        title: 'Tareas pendientes',
                        content: {
                            filtroXML: nvFW.pageContents.filtroTareasPendientes,
                            path_xsl: "report\\verTarea\\HTML_inicio_tareas.xsl"
                        },
                        min_width: 350,
                        height: 250
                    });
                    inicio_referencias = t_layout.add({
                        title: 'Suscripciones',
                        content: {
                            filtroXML: nvFW.pageContents.filtroSuscripciones,
                            path_xsl: "report\\verRef_docs\\HTML_inicio_suscripciones.xsl"
                        },
                        min_width: 350,
                        height: 250
                    });
                    referencias_no_guardadas = t_layout.add({
                        title: 'Referencias no guardadas',
                        content: {
                            filtroXML: nvFW.pageContents.filtroNoGuardadas,
                            path_xsl: "report\\verRef_docs\\HTML_inicio_referencias_no_guardadas.xsl"
                        },
                        min_width: 350,
                        height: 250
                    });
                }
            });

            function verRef(nro_ref, event) {
                if (event) {
                    // CONTROL
                    if (event.ctrlKey) {
                        setTimeout(function() { 
                            window.open(window.location.origin +  '/wiki/enBlanco.htm', "nuevaVentanaRef", "toolbar=0, location=0, directories=0, status=1, scrollbars=1, resizable=1, menuBar=1, width=950, height=600, left=50, top=50") 
                            //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', 'nuevaVentanaRef');
                            win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', 'nuevaVentanaRef');
                        }, 100)
                    }
                    // SHIFT
                    else if (event.shiftKey) {
                        setTimeout(function() {
                            //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', '_blank');
                            win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', '_blank');
                        }, 100)
                        nvFW.selection_clear() // limpia una posible seleccion generada por SHIFT + CLICK
                    }
                    // ALT
                    else if (event.altKey) {
                        //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', 'winPrototype');
                        win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref, '', 'winPrototype');
                    }
                    // Por DEFECTO
                    else {
                        //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
                        win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
                    }
                }
                else {
                    //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
                    win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
                }
            }

            function verTarea(nro_tarea) {
                window.top.showEditTarea = nro_tarea;
                window.top.$$('iframe[name="menu_left"]')[0].contentWindow.tarea();
            }

            function verRefEditar(nro_ref, id_ref_auto) {
                if (nro_ref == 0) {
                    window.top.editAutoguardadaRef = id_ref_auto;
                }
                window.top.showRef = nro_ref;
                window.top.editRef = nro_ref;
                window.top.ref_no_guardada = true;
                //ObtenerVentana('menu_left').$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
                win_MenuLeft.$("divMenu_content").contentWindow.ref_mostrar(nro_ref);
            }

            function eliminarNoGuardadas(id_ref_auto) {
                window.top.nvFW.confirm('¿Desea eliminar el autoguardado de la referencia?', {
                    width: 320,
                    height: 70,
                    onOk: function(win) {
                        var rs = new tRS(),
                            qry = nvFW.pageContents.filtroEliminarNoGuardadas,
                            params = "<criterio><params id_ref_auto='" + id_ref_auto + "'></params></criterio>"

                        rs.open({
                            filtroXML: qry,
                            params: params
                        })
                        
                        if (rs.eof()) {
                            alert('Ocurrio un error intente nuevamente');
                        }
                        
                        t_layout.refresh(referencias_no_guardadas);
                        win.close();
                    },
                    onCancel: function(win) {
                        win.close();
                    }
                });
            }

            // guardar una referencia en el TOP window para ejecutar un refresh externamente
            window.top.recargarTareasInicio = function() {
                t_layout.refresh(tareas_pendientes)
            }
        </script>
    </head>
    <body>
        <div id="container"></div>
    </body>
</html>