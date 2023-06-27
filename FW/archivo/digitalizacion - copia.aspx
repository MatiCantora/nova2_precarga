<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim xmldato = nvUtiles.obtenerValor("xmldato", "")

    If (xmldato <> "") Then
        Dim err As New tError
        Try

            'DBExecute("update archivos set nro_archivo_estado = 3 where nro_archivo = " & nro_archivo)
        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del estado"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
    End If

    Me.addPermisoGrupo("permisos_solicitudes")
    Me.addPermisoGrupo("permisos_herramientas")

    Me.contents("cargar_clientes") = nvFW.nvUtiles.obtenerValor("cargar_cliente", "")
    Me.contents("filtroEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroSolicitud") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_archivos_def_grupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>distinct nro_archivo_def_grupo as id, archivo_def_grupo as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_verCreditos_control_digital_det") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo' PageSize='29' AbsolutePage='1' cacheControl='Session' ><campos>*, getdate() as todayDate</campos><filtro></filtro><grupo></grupo><orden></orden></select></criterio>")
    Me.contents("filtro_verCreditos_control_digital_det2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo' PageSize='29' AbsolutePage='1' cacheControl='Session' ><campos>[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[nro_def_archivo],[def_archivo],[orden],[archivo_descripcion],[readonly],[file_filtro],[file_max_size],[f_path],[perfil],[repetido],[requerido],[reutilizable],[nro_def_detalle],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[f_id],[momento],[operador],[nro_archivo_estado],[nro_registro],[nro_archivo_def_tipo],[permiso],[cantidad],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")
    Me.contents("filtro_verCreditos_control_digital_detV1") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo' PageSize='20' AbsolutePage='1' ><campos>MIN(nro_archivo) as id_row,count(nro_archivo) as nro_archivos, operador, nombre_operador,strNombreOperador,nro_img_origen,nro_sucursal,sucursal,img_origen,sum(isnull(cant_hojas,0)) as sum_hojas,sum(isnull(pag_clasificadas,0)) as sum_clasificadas,localidad,provincia</campos><filtro></filtro><orden></orden><grupo>operador,nombre_operador,strNombreOperador,nro_img_origen,nro_sucursal,sucursal,img_origen,localidad,provincia</grupo></select></criterio>")
    Me.contents("filtro_verCreditos_control_digital_det3") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>nro_credito,nro_docu,documento,sexo,strNombreCompleto,nro_banco,banco,nro_mutual,mutual,estado,descripcion,sucursal,control_digital,control_contenido,archivo_descripcion,nro_archivo,CONVERT(varchar,momento,103) + ' ' + CONVERT(varchar,momento,108) as momento,nombre_operador,IMG_origen,convert(varchar,fe_estado,103) as fe_estado,nro_def_archivo,def_archivo</campos><filtro></filtro><orden>nro_credito</orden></select></criterio>")
    Me.contents("filtro_verCreditos_control_digital_det4") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo'><campos>nro_credito,nro_docu,documento,sexo,strNombreCompleto,nro_banco,banco,nro_mutual,mutual,estado,descripcion,sucursal,control_digital,control_contenido,convert(varchar,fe_estado,103) as fe_estado,nro_def_archivo,def_archivo</campos><filtro></filtro><grupo>nro_credito,nro_docu,documento,sexo,strNombreCompleto,nro_banco,banco,nro_mutual,mutual,estado,descripcion,sucursal,control_digital,control_contenido,fe_estado,nro_def_archivo,def_archivo</grupo><orden>nro_credito</orden></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Digitalización</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var permisos_herramientas = nvFW.permiso_grupos.permisos_herramientas

        //var vButtonItems = new Array();
        //vButtonItems[0] = new Array();
        //vButtonItems[0]["nombre"] = "Aceptar";
        //vButtonItems[0]["etiqueta"] = "Buscar";
        //vButtonItems[0]["imagen"] = "";
        //vButtonItems[0]["onclick"] = "return btnBuscar_onclick('RPT')";

        //var vListButton = new tListButton(vButtonItems, 'vListButton');

        var modo = 0

        function window_onload() {

            vListButton.MostrarListButton()
            inicializar_componentes()
            window_onresize()

        }

        function inicializar_componentes() {

            campos_defs.add('archivos_def_grupo',
            {
                enDB: false,
                target: 'td_archivo_def_grupo',
                nro_campo_tipo: 1,
                depende_de: null,
                filtroXML: nvFW.pageContents.filtro_archivos_def_grupo,
                depende_de_campo: null
            })
        }

        function enter_onkeypress(e) {
            key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13) {
                //campos_defs.onclick(e, "nro_vendedor_mendoza")
            }
        }

        function btnBuscar_onclick(modo) {

            var strValidar = ''

            //if (($('fecha_desde2').value == '' && $('fecha_hasta2').value == ''))
              //  strValidar += 'Ingrese un rango de fechas, número de credito o un número de envio para realizar la búsqueda.<br>'

            if (strValidar != '') {
                alert(strValidar)
                return
            }

            var filtro = ""
            var parametros = ""

            if ($('fecha_venc').value != "" && $('tipo_vista').value != 'AV')
                filtro += "<fe_venc type='mas'>convert(datetime,'" + $('fecha_venc').value + "',103)</fe_venc>"

            if ($('fecha_venc_hasta').value != "")
                filtro += "<fe_venc type='menor'>convert(datetime,'" + $('fecha_venc_hasta').value + "',103)+1</fe_venc>"

            if ($('fecha_desde2').value != "")
                filtro += "<momento type='mas'>convert(datetime,'" + $('fecha_desde2').value + "',103)</momento>"

            if ($('fecha_hasta2').value != "")
                filtro += "<momento type='menor'>convert(datetime,'" + $('fecha_hasta2').value + "',103)+1</momento>"

            if ($('descripcion').value != "")
                filtro += '<archivo_descripcion type="like">%' + $('descripcion').value + '%</archivo_descripcion>'

            if ($F('nro_def_archivos') != "")
                filtro += "<nro_def_archivo type='in'>" + $F('nro_def_archivos') + "</nro_def_archivo>"

            if ($F('nro_def_tipos') != "")
                filtro += "<nro_archivo_def_tipo type='in'>" + $F('nro_def_tipos') + "</nro_archivo_def_tipo>"
            if ($('nro_img_origen').value != "")
                filtro += '<nro_img_origen type="igual">' + $('nro_img_origen').value + '</nro_img_origen>'

            if ($('nro_operador').value != "")
                filtro += '<operador type="igual">' + $('nro_operador').value + '</operador>'

            if ($F('nro_archivo_id_tipo') != "")
                filtro += "<nro_archivo_id_tipo type='in'>" + $F('nro_archivo_id_tipo') + "</nro_archivo_id_tipo>"

            if ($('tipo_vista').value == 1)
                filtro += "<f_nro_ubi type='in'>1,2</f_nro_ubi>"

            if ($('tipo_vista').value == 2) 
                filtro += "<f_nro_ubi type='isnull'></f_nro_ubi>"

           // if ($F('archivos_def_grupo') != "")
             //   filtro += "<sql type='sql'>dbo.rm_def_detalle_en_grupo(nro_def_detalle," + $F('archivos_def_grupo') + ")=1</sql>"

            var reporte = ''
            var filtroXML = ''
            var filtroWhere = ''
            if ($('tipo_vista').value == 'CR') {
                reporte = 'report\\verCreditos_control_digital\\HTML_creditos_control_digital.xsl'
                filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_det
                filtroWhere = "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>"
            }

            if ($('tipo_vista').value == 'AR' || $('tipo_vista').value == 1 || $('tipo_vista').value == 2) {
                reporte = 'report\\archivo\\HTML_control_digital_archivos.xsl'
                filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_det2
                filtroWhere = "<criterio><select><filtro>" + filtro + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + "</filtro></select></criterio>"
            }

            if ($('tipo_vista').value == 'AP') {
                reporte = 'report\\archivo\\verCreditos_control_digital\\HTML_archivos_operadores.xsl'
                filtroWhere = "<criterio><select><filtro>" + filtro + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + "</filtro></select></criterio>"
                filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_detV1
            }

            if ($('tipo_vista').value == 'AF') {
                reporte = 'report\\archivo\\HTML_control_digital_archivos.xsl'
                filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_det2
                filtroWhere = "<criterio><select><filtro>" + filtro + "<requerido type='igual'>1</requerido><cantidad type='igual'>0</cantidad>" + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + "</filtro></select></criterio>"
            }

            if ($('tipo_vista').value == 'AV') {
                reporte = 'report\\archivo\\HTML_control_digital_archivos.xsl'
                filtroXML = nvFW.pageContents.filtro_verCreditos_control_digital_det2
                filtroWhere = "<criterio><select><filtro>" + filtro + "<fe_venc type='menos'>convert(datetime,'" + new Date().toLocaleDateString() + "',103)</fe_venc>" + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>" + "</filtro></select></criterio>"
            }


            if (modo == 'EXL') {
                //reporte de archivos con parámetros
                if ($('tipo_vista').value == 'AP') {

                    var strXML_parm = ''
                    strXML_parm = '<parametros><fecha_desde2>' + $('fecha_desde2').value + '</fecha_desde2><fecha_hasta2>' + $('fecha_hasta2').value + '</fecha_hasta2>'
                    strXML_parm += '<nro_def_archivo>' + $F('nro_def_archivos') + '</nro_def_archivo><nro_archivo_def_tipo>' + $F('nro_def_tipos') + '</nro_archivo_def_tipo>'
                    strXML_parm += '<nro_img_origen>' + $('nro_img_origen').value + '</nro_img_origen><operador>' + $('nro_operador').value + '</operador><nro_creditos>' + $('nro_creditos').value + '</nro_creditos>'
                    strXML_parm += '</parametros>'

                    var id_transferencia = 815

                    window.top.nvFW.transferenciaEjecutar({
                        id_transferencia: id_transferencia,
                        xml_param: strXML_parm,
                        pasada: 0,
                        formTarget: 'winPrototype',
                        async: true,
                        winPrototype: {
                            modal: true,
                            center: true,
                            bloquear: false,
                            url: 'enBlanco.htm',
                            title: '<b>Informe de archivos por operador</b>',
                            minimizable: false,
                            maximizable: true,
                            draggable: true,
                            width: 800,
                            height: 400,
                            resizable: true,
                            destroyOnClose: true
                        }
                    })

                }
                if ($('tipo_vista').value == 'AR') {
                    nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtro_verCreditos_control_digital_det3
                    , path_xsl: "report\\EXCEL_base.xsl"
                        , filtroWhere: filtro + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>"
                    , salida_tipo: "adjunto"
                    , ContentType: "application/vnd.ms-excel"
                    , formTarget: "_blank"
                    , export_exeption: 'RSXMLtoExcel'
                    , filename: "digitalizacion_control.xls"
                    })
                }
                if ($('tipo_vista').value == 'CR') {
                    nvFW.exportarReporte({
                        filtroXML: nvFW.pageContents.filtro_verCreditos_control_digital_det4,
                        path_xsl: "report\\EXCEL_base.xsl",
                        filtroWhere: filtro + "<nro_archivo_estado type='igual'>1</nro_archivo_estado>",
                        salida_tipo: "adjunto",
                        export_exeption: 'RSXMLtoExcel',
                        ContentType: "application/vnd.ms-excel",
                        formTarget: "_blank",
                        filename: "digitalizacion_control.xls"
                    })
                }
            }
            else {
                //<nro_archivo_def_grupo>' + $('archivos_def_grupo').value + '</nro_archivo_def_grupo>
                var params = '<parametros><nro_operador>' + $('nro_operador').value + '</nro_operador><nro_img_origen>' + $('nro_img_origen').value + '</nro_img_origen><fecha_desde>' + $('fecha_desde2').value + '</fecha_desde><fecha_hasta>' + $('fecha_hasta2').value + '</fecha_hasta><tipo_def_todos>' + $F('nro_def_tipos') + '</tipo_def_todos></parametros>'

                nvFW.exportarReporte({
                    filtroXML: filtroXML,
                    filtroWhere: filtroWhere, 
                    path_xsl: reporte,
                    formTarget: 'frame_listado',
                    nvFW_mantener_origen: true,
                    bloq_contenedor: $('frame_listado'),
                    cls_contenedor: 'frame_listado',
                    parametros: params

                })
            }
            window_onresize()
        }

        function clave_sueldo_onkeypress(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                btnAceptar_onclick();
        }

        var win_envios

        function btnEjecutar_transferencia(id_transferencia) {
            if (!nvFW.tienePermiso('permisos_herramientas', 5)) {
                alert('No posee permiso para realizar esta acción.')
                return
            }
            else {
                var strXML_parm = ''
                window.top.nvFW.transferenciaEjecutar({
                    id_transferencia: id_transferencia,
                    xml_param: strXML_parm,
                    pasada: 0,
                    formTarget: 'winPrototype',
                    async: false,
                    winPrototype: {
                        modal: true,
                        center: true,
                        bloquear: false,
                        url: 'enBlanco.htm',
                        title: '<b>Reportes de Control</b>',
                        minimizable: false,
                        maximizable: true,
                        draggable: true,
                        width: 800,
                        height: 400,
                        resizable: true,
                        destroyOnClose: true
                    }
                })
            }
        }



        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var FiltroDatos_h = $('divCabe').getHeight()
                $('frame_listado').setStyle({ 'height': body_h - FiltroDatos_h - dif - 40 + 'px' });
            }
            catch (e) { }
        }

        function abrir_entidad_win(evento, nro_archivo_id_tipo, id_tipo) {
            //nro_archivo_id_tipo = 1 (solicitud) nro_archivo_id_tipo = 2 (entidad)
            if (nro_archivo_id_tipo == 2) {

                if (nvFW.pageContents.cargar_clientes == '') {
                    return
                }

                var rs = new tRS()
                rs.open({
                    filtroXML: nvFW.pageContents.filtroEntidades,
                    filtroWhere: '<criterio><select><filtro><nro_entidad type="igual">' + id_tipo + '</nro_entidad></filtro></select></criterio>'
                })

                var url_destino = nvFW.pageContents.cargar_clientes
                var tipocli

                if (rs.getdata('persona_fisica') == 'True') {
                    tipocli = 1
                } else {
                    tipocli = 2
                }

                if (id_tipo > 0) {
                    //Entidad de Nv
                    url_destino += "?nro_entidad=" + rs.getdata('nro_entidad') + "&tipdoc=" + rs.getdata('tipo_docu') + "&nrodoc=" + rs.getdata('nro_docu') + "&tipocli=" + tipocli + "&titulo=" + rs.getdata('Razon_social')
                }

                //abrir_ventana_emergente(url_destino, nombre, 'permisos_entidades', 2, 500, 1000, true, true, true, true, false, 'frame_ref', evento)

                // Abrir datos según modificadores (Ctrl | Shift)
                if (evento.ctrlKey) {
                    // Nueva pestaña
                    var newWin = window.open(url_destino)
                }
                else if (evento.shiftKey) {
                    // Nueva ventana de browser
                    var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                    newWin.moveTo(0, 0)
                    newWin.resizeTo(screen.availWidth, screen.availHeight)
                }
                else {
                    // Ventana flotante NO-modal. Comportamiento por defecto
                    var porcentajeHeight;
                    if (screen.height < 800)
                        porcentajeHeight = 0.747;
                    else porcentajeHeight = 0.763;

                    var win_vinculo = top.nvFW.createWindow({
                        url: url_destino,
                        title: '<b>' + rs.getdata('Razon_social') + '</b>',
                        width: 1240,
                        height: 500,
                        destroyOnClose: true
                    })

                    win_vinculo.showCenter(false)

                }
            } else if (nro_archivo_id_tipo == 1) {

                    if (!nvFW.tienePermiso('permisos_solicitudes', 1)) {
                        alert('No posee permisos para ver la solicitud');
                        return
                    }

                    var rs = new tRS()
                    rs.open({
                        filtroXML: nvFW.pageContents.filtroSolicitud,
                        filtroWhere: '<criterio><select><filtro><nro_sol type="igual">' + id_tipo + '</nro_sol></filtro></select></criterio>'
                    })

                var url_destino = "/voii/solicitudes/solicitud_abm.aspx?nro_sol=" + id_tipo;

                    if (evento.ctrlKey == true) {
                        var win = window.open(url_destino)
                    } else if (evento.shiftKey) {
                        // Nueva ventana de browser
                        var newWin = window.open(url_destino, null, 'scrollbars=yes,width=180px,height=180px,resizable=yes')
                        newWin.moveTo(0, 0)
                        newWin.resizeTo(screen.availWidth, screen.availHeight)
                    } else {
                        var width;
                        var height;

                        if (screen.height < 800) {
                            porcentajeHeight = 0.94;
                            porcentajeWidth = 0.988;
                            height = $$("body")[0].getHeight() * porcentajeHeight;
                            width = $$("body")[0].getWidth() * porcentajeWidth;
                            //porcentajeHeight = 0.947;
                        }
                        else {
                            //porcentajeHeight = 0.963;
                            //porcentajeWidth = 0.988;
                            porcentajeHeight = 0.92;
                            porcentajeWidth = 0.94;
                            height = $$("body")[0].getHeight() * porcentajeHeight;
                            width = $$("body")[0].getWidth() * porcentajeWidth;
                        }

                        //var win = nvFW.createWindow({                   
                        var win = top.nvFW.createWindow({
                            url: "/voii/solicitudes/solicitud_abm.aspx?nro_sol=" + id_tipo, width: "1200",
                            title: "<b>Solicitud N° " + id_tipo + " " + rs.getdata("nombre") + " " + rs.getdata("apellido") + "</b>",
                            resizable: true,
                            height: height,
                            width: width,
                            onShow: function (win) {
                                solVentana += 1;
                                var topLocation = parent.document.getElementById('tb_cab').getHeight() + (win.element.childNodes[4].getHeight() + 2) * solVentana;
                                var leftLocation = ((parent.document.getElementById('tb_cab').getWidth() - win.element.childNodes[4].getWidth()) / 2);

                                win.setLocation(topLocation, leftLocation);

                                solVentanas.set(win.getId(), win);

                            },
                            onClose: function (win) {
                                solVentana -= 1;

                                solVentanas.delete(win.getId());

                                if (win.options.userData.hay_modificacion) {
                                    buscar_solicitud(0);
                                    //campos_head.pagina_cambiar(campos_head.AbsolutePage)
                                }
                            }

                        })

                        var id = win.getId();
                        focus(id);

                        win.showCenter()

                    }

                
            }

        }


        function cambioEstadoMasivo(a) {
            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"

            a.each(function (arr, i) {
                console.log(arr)
                xmldato += "<archivos><id_tipo>" + arr['id_tipo'] + "</id_tipo>"
                xmldato += "<descripcion>" + arr['descripcion'] + "</descripcion></archivos>"
                //xmldato += "<nro_archivo>" + arr['descdescripcion'] + "</nro_archivo></archivos>"

                //nvFW.error_ajax_request('digitalizacion.aspx', {
                //    parameters: { nro_archivo: arr },
                //    onSuccess: function (err, transport) {
                //        if (err.numError != 0) {
                //            alert(err.mensaje)
                //            return
                //        }
                //    },
                //    error_alert: true
                //});
            })

            console.log(xmldato)

            //nvFW.error_ajax_request('digitalizacion.aspx', {
            //    parameters: { xmldato: xmldato },
            //        onSuccess: function (err, transport) {
            //            if (err.numError != 0) {
            //                alert(err.mensaje)
            //                return
            //            }
            //        },
            //})
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; /*height: 100%;*/ /*overflow: auto*/">
    <div id="divMenuDig"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
        Menus["vMenuDig"] = vMenuDig
        Menus["vMenuDig"].alineacion = 'centro';
        Menus["vMenuDig"].estilo = 'A';

        vMenuDig.loadImage("buscar1", "/fw/image/icons/buscar1.png");
        vMenuDig.loadImage("excel", "/FW/image/icons/trabajo.png");

        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Seguimiento de archivos</Desc></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar1</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBuscar_onclick('RPT')</Codigo></Ejecutar></Acciones></MenuItem>")
//        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBuscar_onclick('EXL')</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig.MostrarMenu()
    </script>


    <div id="divCabe" style="width: 100%; overflow: auto;">

        <table style="width: 100%" class="tb1">
            <tr class="tbLabel">
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Tipo</b></td>
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Tipo Def</b></td>
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Definición</b></td>
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Descripción</b></td>
<%--                <td class="Tit1" style="width: 20%;text-align:center;"><b>Estado</b></td>--%>

<%--                <td rowspan="2" style="width: 20%">
                    <div style='width: 100%' id="divAceptar"></div>
                </td>--%>
            </tr>
            <tr>
                <td>
                    <%=nvFW.nvCampo_def.get_html_input("nro_archivo_id_tipo") %>
                </td>
                <td>
                    <%=nvFW.nvCampo_def.get_html_input("nro_def_tipos") %>
                </td>
                <td>
                    <%=nvFW.nvCampo_def.get_html_input("nro_def_archivos") %>
                </td>
                <td>
                    <input name="descripcion" id="descripcion" style="width: 100%" />
                </td>
<%--                <td style="width: 100%">
                    <select id='estado' style="width: 100%">
                        <option value=''>Todo</option>
                        <option value='1'>Cargados</option>
                        <option value='2'>Sin cargar</option>
                    </select>
                </td>--%>
            </tr>
        </table>
    
<%--    <div id="divMenuDig1"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuDig1 = new tMenu('divMenuDig1', 'vMenuDig1');
        Menus["vMenuDig1"] = vMenuDig1
        Menus["vMenuDig1"].alineacion = 'centro';
        Menus["vMenuDig1"].estilo = 'A';

        Menus["vMenuDig1"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos</Desc></MenuItem>")
        //        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>procesar</icono><Desc>Reportes de control</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEjecutar_transferencia(617)</Codigo></Ejecutar></Acciones></MenuItem>")
        //        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBuscar_onclick('EXL')</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig1.MostrarMenu()
    </script>--%>
        <table class="tb1">
            <tr class="tbLabel">
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Operador</b></td>
                <td class="Tit1" colspan="2" style="width: 20%;text-align:center;"><b>Fecha de alta</b></td>
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Origen</b></td>
                <td class="Tit1" colspan="2" style="width: 20%;text-align:center;"><b>Fecha de vencimiento</b></td>
                <td class="Tit1" style="width: 20%;text-align:center;"><b>Vista</b></td>
            </tr>

             <tr>
                <td style="width: 20%">
                    <script type="text/javascript">
                        campos_defs.add('nro_operador', { enDB: true })
                    </script>
                </td>
                <td style="width: 10%">
                    <script type="text/javascript">
                        campos_defs.add('fecha_desde2', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td style="width: 10%">
                    <script type="text/javascript">
                        campos_defs.add('fecha_hasta2', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td style="width: 20%">
                    <script type="text/javascript">
                        campos_defs.add('nro_img_origen', { enDB: true })
                    </script>
                </td>
                <td style="width: 10%">
                    <script type="text/javascript">
                        campos_defs.add('fecha_venc', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td style="width: 10%">
                    <script type="text/javascript">
                        campos_defs.add('fecha_venc_hasta', { enDB: false, nro_campo_tipo: 103 })
                    </script>
                </td>
                <td>
                    <select id='tipo_vista' style="width: 100%">
                        <option value='AR'>Archivo</option>
                        <%--<option value='AP'>Por operador</option>--%>
                        <option value='AV'>Vencidos</option>
                        <option value='AF'>Faltantes</option>
                        <option value='1'>Cargados</option>
                        <option value='2'>Sin cargar</option>
                    </select>
                </td>
            </tr>
        </table>
    </div>
    <iframe name="iframe1" id="iframe1" src="enBlanco.htm" style="width: 100%; /*height: 100%;*/ overflow: auto; border: none; display: none"></iframe>
    <iframe name="frame_listado" id="frame_listado" src="/fw/enBlanco.htm" style="width: 100%; height:auto; max-height:750px; overflow:auto" frameborder='0'></iframe>

</body>
</html>




