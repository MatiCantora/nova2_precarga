<%@ page language="VB" autoeventwireup="false" inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim xmldato = nvUtiles.obtenerValor("xmldato", "")

    If (xmldato <> "") Then
        Dim err As New tError
        Try
            'Stop
            Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
            objXML.LoadXml(xmldato)
            Dim nodosArchivos = objXML.SelectNodes("archivo/archivos")
            For i As Integer = 0 To nodosArchivos.Count - 1
                Dim id_tipo As Integer = nodosArchivos(i).Attributes("id_tipo").Value
                Dim nro_def_archivo As Integer = nodosArchivos(i).Attributes("nro_def_archivo").Value
                Dim nro_archivo_id_tipo As Integer = nodosArchivos(i).Attributes("nro_archivo_id_tipo").Value
                Dim archivo As tnvArchivo
                archivo = New tnvArchivo(id_tipo:=id_tipo, nro_archivo_id_tipo:=nro_archivo_id_tipo, nro_def_detalle:=nro_def_archivo, isFisical:=True)
                archivo.save()
            Next

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualizaci�n del estado"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.addPermisoGrupo("permisos_parametros")
    Me.addPermisoGrupo("permisos_def_archivo")
    Me.addPermisoGrupo("permisos_solicitudes")
    Me.addPermisoGrupo("permisos_herramientas")

    Me.contents("cargar_clientes") = nvFW.nvUtiles.obtenerValor("cargar_cliente", "/voii/cargar_cliente.aspx")

    Me.contents("filtroEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroEstado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_estado'><campos>nro_archivo_estado as id, archivo_estado as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_archivos_def_grupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>distinct nro_archivo_def_grupo as id, archivo_def_grupo as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

    Me.contents("filtroArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_idtipo' ><campos>*,fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Digitalizaci�n</title>
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
        var permisos_solicitudes = nvFW.permiso_grupos.permisos_solicitudes

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return btnBuscar_onclick('RPT')";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")

        
        var modo = 0
        var winListado
        var campoDefParam
        var nro_ent
        var cons_id
        var cons_desc
        var aum 
        var ibs_cliente_oficial = ''
        var vinculos = ''
        var alta_cli = ''
        var alta_cli_to = ''
        var listadoFrame

        function setFrameList(frame) {
            listadoFrame = frame
        }

        function setFrameVals(ofi, vinc , alD, alH) {
            ibs_cliente_oficial = ofi
            vinculos = vinc
            alta_cli = alD
            alta_cli_to = alH
        }

        function def_archivo(nro_def_archivo, nro_def_detalle) {

            if (!nvFW.tienePermiso('permisos_def_archivo', 2)) {
                alert('No tiene permiso para Altas ni Edici�n. Comuniquese con el administrador de sistemas.');
                return
            }
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_archivos_def_abm = w.createWindow({
                className: 'alphacube',
                url: '/fw/def_archivos/archivos_def_ABM.aspx?nro_def_archivo=' + nro_def_archivo + '&nroArDef=' + nro_def_detalle + '&accion="C"',
                title: '<b>ABM Definici�n de Archivos</b>',
                minimizable: true,
                maximizable: false,
                draggable: true,
                resizable: false,
                width: 1000,
                height: 500,
                onClose: function () {
                    buscar_archivos_def()
                    sessionStorage.clear()
                }
            });

            win_archivos_def_abm.options.userData = { nro_def_archivo: nro_def_archivo }
            win_archivos_def_abm.showCenter()
        }

        function window_onload() {

            vListButton.MostrarListButton()
            window_onresize()

            if (nvFW.pageContents.cargar_clientes == '/voii/cargar_cliente.aspx') {

                $('frame_listado_fil').setStyle({ 'display': 'block' })

            } 
        }

        function getWin(win, aume, n_desc, n_id) {
            winListado = win
            cons_id = n_id
            cons_desc = n_desc
            aum = aume

        }

        function getVars(nro_enti) {
            nro_ent = nro_enti
        }

        var cantFilas
        var filtro = ""
        var filtro_1 = ""

        function filtro_fn() {
            filtro = ""
            filtro_1 = ""

            var parametros = ""


            if ($F('nro_def_archivos') != "")
                filtro += "<nro_def_archivo type='in'>" + $F('nro_def_archivos') + "</nro_def_archivo>"

            if ($('nro_archivo_id_tipo').value != "")
                filtro += "<nro_archivo_id_tipo type='igual'>" + $('nro_archivo_id_tipo').value + "</nro_archivo_id_tipo>"

            if ($('cantFilas').value != "") {
                cantFilas = $('cantFilas').value
            } else {
                cantFilas = 10000
            }

            if ($('requerido').value != '')
                filtro += "<requerido type='igual'>" + $('requerido').value + "</requerido>"

            if ($F('nro_def_tipos') != "")
                filtro += "<nro_archivo_def_tipo type='in'>" + $F('nro_def_tipos') + "</nro_archivo_def_tipo>"

            if ($('filRel').value == '' || $('filRel').value == 1 || $('filRel').value == 2) {

                if ($('filRel').value == 1)
                    filtro += '<nro_archivo type="isnull"></nro_archivo>'

                if ($('filRel').value == 2)
                    filtro += '<nro_archivo type="mas">0</nro_archivo>'

                //if ($('estado').value != "")
                //    filtro += '<nro_archivo_estado type="in">' + $('estado').value + '</nro_archivo_estado>'

                    if ($('nro_operador').value != "") {
                        var s = campos_defs.get_desc('nro_operador')
                        filtro += "<operador type='igual'>'" + campos_defs.get_desc('nro_operador').substring(0, s.indexOf(' -')) + "'</operador>"
                    }

                if ($('fecha_venc').value != "")
                    filtro += "<fe_venc type='mas'>convert(datetime,'" + $('fecha_venc').value + "',103)</fe_venc>"

                if ($('fecha_venc_hasta').value != "")
                    filtro += "<fe_venc type='menor'>convert(datetime,'" + $('fecha_venc_hasta').value + "',103)+1</fe_venc>"

                if ($('fecha_desde2').value != "")
                    filtro += "<momento type='mas'>convert(datetime,'" + $('fecha_desde2').value + "',103)</momento>"

                if ($('fecha_hasta2').value != "")
                    filtro += "<momento type='menor'>convert(datetime,'" + $('fecha_hasta2').value + "',103)+1</momento>"

            } else {

                filtro += '<or>'
                filtro += '<nro_archivo type="isnull"></nro_archivo>'
                filtro += '<and>'

                if ($('estado').value != "")
                    filtro += '<nro_archivo_estado type="in">' + $('estado').value + '</nro_archivo_estado>'

                    if ($('nro_operador').value != "") {
                        var s = campos_defs.get_desc('nro_operador')                        
                        filtro += "<operador type='igual'>'" + campos_defs.get_desc('nro_operador').substring(0, s.indexOf(' -')) + "'</operador>"
                    }

                if ($('fecha_venc').value != "" )
                    filtro += "<fe_venc type='mas'>convert(datetime,'" + $('fecha_venc').value + "',103)</fe_venc>"

                if ($('fecha_venc_hasta').value != "")
                    filtro += "<fe_venc type='menor'>convert(datetime,'" + $('fecha_venc_hasta').value + "',103)+1</fe_venc>"

                if ($('fecha_desde2').value != "")
                    filtro += "<momento type='mas'>convert(datetime,'" + $('fecha_desde2').value + "',103)</momento>"

                if ($('fecha_hasta2').value != "")
                    filtro += "<momento type='menor'>convert(datetime,'" + $('fecha_hasta2').value + "',103)+1</momento>"

                filtro += '</and>'
                filtro += '</or>'
            }

            if ($('descripcion').value != "")
                filtro += '<archivo_descripcion type="like">%' + $('descripcion').value + '%</archivo_descripcion>'
            
        }

        //function asignarTipo() {
        //    if ($(tipoAlert).value == 1) {
        //        campos_defs.set_value('nro_archivo_id_tipo', 1)
        //    } else {
        //        campos_defs.set_value('nro_archivo_id_tipo', 2)
        //    }
        //    filtrosEnt()
        //}


        function btnBuscar_onclick(modo) {
            
            //if ($F('nro_archivo_id_tipo') != "") {
            //} else {
            //    alert('<b>Seleccione el "Tipo de seguimiento"</b><br/><select style="width:100%" id="tipoAlert" onchange="asignarTipo()"><option value=""></option><option value="1">Solicitud</option><option value="2">Entidad</option></select>')
            //    return
            //}

            var strValidar = ''

            if (strValidar != '') {
                alert(strValidar)
                return
            }


            var parametros = ""

            filtro_fn()

            var reporte = ''
            var filtroXML = ''
            var filtroWhere = ''


            reporte = 'report\\archivo\\HTML_control_digital_archivos_entidades_voii.xsl'
            filtroXML = nvFW.pageContents.filtroArchivos
            filtroWhere = "<criterio><select PageSize='1000000' top='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>" 


            if (modo == 'EXL') {
                //reporte de archivos con par�metros

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
            else {
                //<nro_archivo_def_grupo>' + $('archivos_def_grupo').value + '</nro_archivo_def_grupo>
                var params = '<parametros><nro_operador>' + $('nro_operador').value + '</nro_operador><nro_img_origen>' + $('nro_img_origen').value + '</nro_img_origen><fecha_desde>' + $('fecha_desde2').value + '</fecha_desde><fecha_hasta>' + $('fecha_hasta2').value + '</fecha_hasta><tipo_def_todos>' + $F('nro_def_tipos') + '</tipo_def_todos></parametros>'

                    nvFW.exportarReporte({
                        filtroXML: filtroXML,
                        filtroWhere: filtroWhere, 
                        path_xsl: reporte,
                        formTarget: 'frame_listado_def',
                        nvFW_mantener_origen: true,
                        //bloq_contenedor: $('frame_listado'),
                        cls_contenedor: 'frame_listado_def',
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
                alert('No posee permiso para realizar esta acci�n.')
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
                //$('frame_listado_fil').setStyle({ 'height': body_h - FiltroDatos_h - dif - 25 + 'px' });
                $('frame_listado_def').setStyle({ 'height': body_h - FiltroDatos_h - dif - 25 + 'px' });

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
                    url_destino += "?nro_entidad=" + rs.getdata('nro_entidad') + "&tipdoc=" + rs.getdata('tipo_docu') + "&nrodoc=" + rs.getdata('nro_docu') + "&tipocli=" + tipocli + "&titulo=" + rs.getdata('Razon_social')
                }

                if (evento.ctrlKey) {
                    // Nueva pesta�a
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
                        }
                        else {
                            porcentajeHeight = 0.92;
                            porcentajeWidth = 0.94;
                            height = $$("body")[0].getHeight() * porcentajeHeight;
                            width = $$("body")[0].getWidth() * porcentajeWidth;
                        }
                  
                        var win = top.nvFW.createWindow({
                            url: "/voii/solicitudes/solicitud_abm.aspx?nro_sol=" + id_tipo, width: "1200",
                            title: "<b>Solicitud N� " + id_tipo + " " + rs.getdata("nombre") + " " + rs.getdata("apellido") + "</b>",
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
                                }
                            }

                        })

                        var id = win.getId();
                        focus(id);

                        win.showCenter()

                    }

                
            }

        }


        function cambioEstadoMasivo(a, winListado, position) {
            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><archivo>"
            var pos = position
            a.each(function (arr, i) {
                if (!nro_ent) {
                    xmldato += "<archivos id_tipo='" + arr['id_tipo'] + "'"
                } else {
                    xmldato += "<archivos id_tipo='" + nro_ent + "'"
                }
                xmldato += !arr['descripcion'] ? " nro_def_archivo='" + 0 + "'" : " nro_def_archivo='" + arr['descripcion'] + "'"
                xmldato += !arr['nro_tipo'] ? " nro_archivo_id_tipo='" + 0 + "'></archivos>": " nro_archivo_id_tipo='" + arr['nro_tipo'] + "'></archivos>"

            })
            xmldato += "</archivo>"

            nvFW.error_ajax_request('digitalizacion.aspx', {
                parameters: { xmldato: xmldato},
                    onSuccess: function (err, transport) {
                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                        if (!pos) {
                            btnBuscar_onclick('RPT')
                        }
                    },
            })
        }

        function fisicoMasivo(pos, child, aoe) {

            var position = pos
            var param = 0
            Dialog.confirm('<b>�Esta seguro de que desea pasar los archivos seleccionados a "Fisico"?</b> <br><br> Una vez realizado el cambio, no se podra revertir por medios convencionales.', {
                        width: 425,
                        className: "alphacube",
                        okLabel: "SI",
                        cancelLabel: "NO",
                onOk: function (win) {
                    param = 1
                    win.close()
                    var cont = 0
                    var doc = winListado[cont]
                    var desc = ""
                    var id = ""
                    var tope = winListado.length
                    var contador = 0

                    var a = []
                    while (cont < tope) {

                        doc = winListado[cont]
                        desc = winListado[cont + cons_desc]
                        id = winListado[cont + cons_id]
                        nro_ti = winListado[cont + cons_desc + 1]
                        contador = contador + 1

                        if (doc == 'undefined') {
                            return
                        } else if (doc.getElementsBySelector("input")[0].checked == true) {
                            if (cons_id == 0) {
                                var obj = {
                                    id_tipo: nro_ent,
                                    descripcion: desc.title,
                                    nro_tipo: nro_ti.title,

                                }
                                a.push(obj)
                            } else {
                                var obj = {
                                    id_tipo: id.title,
                                    descripcion: desc.title,
                                    nro_tipo: nro_ti.title,

                                }
                                a.push(obj)
                            }

                        }

                        cont = cont + aum
                    }
                    cambioEstadoMasivo(a, winListado, position)
                    if (aoe == 0) {
                        child.mostrar_archivos(0, position)
                    } else if (aoe == 1) {
                        child.mostrar_entidades(0, position)
                    }
                    return param
                }
              
            })


        }

        function exportarExcel() {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroArchivos,
                    filtroWhere: '<criterio><select><filtro>' + filtro + filtro_1 + '</filtro></select></criterio>',
                    path_xsl: "report\\EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    formTarget: "_blank",
                    ContentType: "application/vnd.ms-excel",
                    filename: "Solicitudes.xls"

                })
        }


        function habilitarFiltros() {
            if ($('filRel').value == 1) {
                campos_defs.clear('nro_operador')
                campos_defs.habilitar('nro_operador', false)
                campos_defs.clear('nro_img_origen')
                campos_defs.habilitar('nro_img_origen', false)
                campos_defs.clear('fecha_desde2')
                campos_defs.habilitar('fecha_desde2', false)
                campos_defs.clear('fecha_hasta2')
                campos_defs.habilitar('fecha_hasta2', false)
                campos_defs.clear('fecha_venc')
                campos_defs.habilitar('fecha_venc', false)
                campos_defs.clear('fecha_venc_hasta')
                campos_defs.habilitar('fecha_venc_hasta', false)
                campos_defs.clear('estado')
                campos_defs.habilitar('estado', false)

            } else if ($('filRel').value == 2) {
                campos_defs.habilitar('nro_operador', true)
                campos_defs.habilitar('nro_img_origen', true)
                campos_defs.habilitar('fecha_desde2', true)
                campos_defs.habilitar('fecha_hasta2', true)
                campos_defs.habilitar('fecha_venc', true)
                campos_defs.habilitar('fecha_venc_hasta', true)
                campos_defs.habilitar('estado', true)


            } else if ($('filRel').value == 0) {
                campos_defs.habilitar('nro_operador', true)
                campos_defs.habilitar('nro_img_origen', true)
                campos_defs.habilitar('fecha_desde2', true)
                campos_defs.habilitar('fecha_hasta2', true)
                campos_defs.habilitar('fecha_venc', true)
                campos_defs.habilitar('fecha_venc_hasta', true)
                campos_defs.habilitar('estado', true)

            }
        }

    </script>
</head>
<body id="cuerpo" onload="return window_onload()" onresize="window_onresize()" style="width: 100%">
    <div id="divMenuDig"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuDig = new tMenu('divMenuDig', 'vMenuDig');
        Menus["vMenuDig"] = vMenuDig
        Menus["vMenuDig"].alineacion = 'centro';
        Menus["vMenuDig"].estilo = 'A';

        vMenuDig.loadImage("buscar1", "/fw/image/icons/tilde.png");
        vMenuDig.loadImage("excel", "/FW/image/icons/excel.png");
        vMenuDig.loadImage("mas", "/FW/image/icons/filtro.png");

        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Seguimiento de archivos</Desc></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar1</icono><Desc>Marcar como no digitalizar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>fisicoMasivo('RPT')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarExcel('RPT')</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig.MostrarMenu()
    </script>


    <div id="divCabe" style="width: 100%; overflow: auto;">        
    <table id='contenedor' class="tb1">

        <tr>
            <td>
                <table style="width: 100%" class="tb1">
                    <tr class="tbLabel">
                        <td class="Tit1" style="width: 10%;text-align:center;"><b>Tipo</b></td>
                        <td class="Tit1" style="width: 8%;text-align:center;"><b>Requerido</b></td>
                        <td class="Tit1" style="width: 40%;text-align:center;"><b>Definici�n</b></td>
                        <td class="Tit1" style="width: 21%;text-align:center;"><b>Tipo Documento</b></td>
                        <td class="Tit1" style="width: 21%;text-align:center;"><b>Documento</b></td>

                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('nro_archivo_id_tipo', {nro_campo_tipo: 1})
                                campos_defs.items['nro_archivo_id_tipo'].onchange = function (campo_def) {
                                    filtrosEnt()
                                }
                            </script>
                        </td>
                        <td style="">
                            <select style="width:100%" id="requerido">
                               <option value=""></option>
                               <option value="1">Si</option>
                               <option value="0">No</option>
                            </select>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nro_def_archivos')
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nro_def_tipos')
                            </script>
                        </td>
                        <td>
                            <input name="descripcion" id="descripcion" style="width: 100%" />
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="filtros_vista">
                    <tr class="tbLabel">
                        <td class="Tit1" style="width: 10%;text-align:center;"><b>Digitalizado</b></td>
                        <td class="Tit1" style="width: 22%;text-align:center;"><b>Operador</b></td>
                        <td class="Tit1" style="width: 22%;text-align:center;"><b>Origen</b></td>
                        <td class="Tit1" colspan="2" style="width: 20%;text-align:center;"><b>Fecha de alta</b></td>
                        <td class="Tit1" colspan="2" style="width: 20%;text-align:center;"><b>Fecha de vencimiento</b></td>
<%--                        <td class="Tit1" style="width: 6%;text-align:center"><b>Estado</b></td>--%>
                    </tr>

                     <tr>
                        <td style="width:10%">
                            <select style="width:100%" id="filRel" onchange="habilitarFiltros()">
                               <option value=""></option>
                               <option value="0">Si/No</option>
                               <option value="1">No</option>
                               <option value="2">Si</option>
                            </select>
                        </td>
                        <td style="width: 22%">
                             <script type="text/javascript">
                                campos_defs.add('nro_operador', { enDB: true, nro_campo_tipo: 1 })
                            </script>
                        </td>
                        <td style="width: 22%">
                            <script type="text/javascript">
                                campos_defs.add('nro_img_origen', { enDB: true })
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
                    </tr>
                </table>
            </td>

            <td>
                <table style="width: 100%" class="tb1">
                    <tr>
                        <td rowspan="2">
                            <div id="divBuscar"></div>
                        </td>
                    </tr>
                    <tr>
                        <td><br><br></td>
                    </tr>
                    <tr class="tbLabel">
                        <td class="Tit1" style="width: 100%;text-align:center;"><b>Cant.Filas</b></td>
                    </tr>    
                    <tr>
                        <td>
                            <input type="text" id="cantFilas" style="width: 100%" value="100"/>
                            <script>
                                $('cantFilas').addEventListener('keydown', function (e) {
                                    if (e.key === 'Enter') {
                                        btnBuscar_onclick()
                                    }
                                })
                            </script>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </div>
        <script>
            $('cuerpo').addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    btnBuscar_onclick()
                }
            })
        </script>
    <iframe name="frame_listado_def" id="frame_listado_def" src="/fw/enBlanco.htm" style="width: 100%; height:auto; max-height:750px; overflow:auto" frameborder='0'></iframe>
</body>
</html>

