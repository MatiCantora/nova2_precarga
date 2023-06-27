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
            err.titulo = "Error en la actualización del estado"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.addPermisoGrupo("permisos_parametros")
    Me.addPermisoGrupo("permisos_def_archivo")
    Me.addPermisoGrupo("permisos_solicitudes")
    Me.addPermisoGrupo("permisos_herramientas")

    Me.contents("cargar_clientes") = nvFW.nvUtiles.obtenerValor("cargar_cliente", "")
    Me.contents("campos_def_1") = nvFW.nvUtiles.obtenerValor("campos_def_1", "")
    Me.contents("campos_def_2") = nvFW.nvUtiles.obtenerValor("campos_def_2", "")

    'FILTROS CAMPOS_DEF 
    Me.contents("filtroEstado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_estado'><campos>nro_archivo_estado as id, archivo_estado as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    'Me.contents("filtroParametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_parametro'><campos>distinct parametro as id, parametro as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>nro_archivo_def_grupo as id,archivo_def_grupo as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroDocumento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='documento'><campos>tipo_docu as id,documento as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroDescArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos'><campos>distinct Descripcion as id,Descripcion as campo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_archivos_def_grupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_grupo'><campos>distinct nro_archivo_def_grupo as id, archivo_def_grupo as [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

    'FILTROS RS
    Me.contents("filtroEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroEntidadesCons") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cliente_oficial' cn='BD_IBS_ANEXA'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroParametroBuscar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_parametro_def'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroVinculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerEnt_vinculos'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroSolicitud") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    'FILTRO VISTAS 
    Me.contents("filtroReclamos_ent") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReclamos_entidades'><campos>fecha_docu,reclamable,fecha_forzada,[Razon_social],[f_id],[path],[tipo_docu],[nro_docu],[nro_entidad],[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[def_archivo],[nro_def_detalle],[nro_def_archivo],[archivo_descripcion],[requerido],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[momento],[operador],[nro_archivo_estado],[nro_registro],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")
    Me.contents("filtroReclamos_sol") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReclamos_solicitud'><campos>fecha_docu,reclamable,fecha_forzada,[Razon_social],[f_id],[path],[sol_tipo],[sol_estado],[sol_estado_desc],[cuil],[nro_sol],[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[def_archivo],[nro_def_detalle],[nro_def_archivo],[archivo_descripcion],[requerido],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[momento],[operador],[nro_archivo_estado],[nro_registro],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")
    Me.contents("filtroReclamos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReclamos_general'><campos>fecha_docu,reclamable,fecha_forzada,[Razon_social],[f_id],[path],[nro_archivo_id_tipo],[archivo_id_tipo],[id_tipo],[def_archivo],[nro_def_detalle],[nro_def_archivo],[archivo_descripcion],[requerido],[nro_archivo],replace([path],'\','/') as [path],[f_nro_ubi],[momento],[operador],[nro_archivo_estado],[nro_registro],[fe_venc],fe_venc_obs,dbo.fn_ar_style_venc(fe_venc) as style_vencimiento, getdate() as todayDate</campos><filtro></filtro><orden>id_tipo</orden></select></criterio>")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Reclamos</title>
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
        
        var alert = function (msg) { Dialog.alert(msg, { width: 300, height: 100, okLabel: "cerrar" }); }

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
        var sinoFlag = 0
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

        function setFrameVals(ofi, alD, alH) {
            ibs_cliente_oficial = ofi
            alta_cli = alD
            alta_cli_to = alH
        }

        //ABRE LA VENTANA DE DETALLE DE ARCHIVO
        function def_archivo(nro_def_archivo, nro_def_detalle) {

            if (!nvFW.tienePermiso('permisos_def_archivo', 2)) {
                alert('No tiene permiso para Altas ni Edición. Comuniquese con el administrador de sistemas.');
                return
            }
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_archivos_def_abm = w.createWindow({
                className: 'alphacube',
                url: '/fw/def_archivos/archivos_def_ABM.aspx?nro_def_archivo=' + nro_def_archivo + '&nroArDef=' + nro_def_detalle + '&accion="C"',
                title: '<b>ABM Definición de Archivos</b>',
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
            inicializar_componentes()
            window_onresize()

            if (nvFW.pageContents.cargar_clientes == '/voii/cargar_cliente.aspx') {

                $('frame_listado_fil').setStyle({ 'display': 'block' })
            } 
        }

        //RECIBE LA INFORMACION NECESARIA DE LA PLANTILLA
        function getWin(win, aume, n_desc, n_id) {
            winListado = win
            cons_id = n_id
            cons_desc = n_desc
            aum = aume

        }

        function getVars(nro_enti) {
            nro_ent = nro_enti
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

        var cantFilas
        var filtro = ""
        var filtro_1 = ""

        //CARGA LOS FILTROS
        function filtro_fn() {           
            sinoFlag = 0
            filtro = ""
            filtro_1 = ""

            var parametros = ""

            if ($F('nro_def_archivos') != "")
                filtro += "<nro_def_archivo type='in'>" + $F('nro_def_archivos') + "</nro_def_archivo>"
            

            if ($('cantFilas').value != "") {
                cantFilas = $('cantFilas').value
            } else {
                cantFilas = 10000
            }

            if ($('requerido').value != '')
                filtro += "<requerido type='igual'>" + $('requerido').value + "</requerido>"

            if ($('estado').value != "")
                filtro += '<nro_archivo_estado type="in">' + $('estado').value + '</nro_archivo_estado>'

            if ($('nro_operador').value != "") {
                var s = campos_defs.get_desc('nro_operador')
                filtro += "<operador type='igual'>'" + campos_defs.get_desc('nro_operador').substring(0, s.indexOf(' -')) + "'</operador>"
            }

            if ($('fecha_docu').value != "")
                filtro += "<fecha_docu type='mas'>convert(datetime,'" + $('fecha_docu').value + "',103)</fecha_docu>"

            if ($('fecha_docu_hasta').value != "")
                filtro += "<fecha_docu type='menor'>convert(datetime,'" + $('fecha_docu_hasta').value + "',103)+1</fecha_docu>"

            if ($('fecha_forzado').value != "")
                filtro += "<fecha_forzado type='mas'>convert(datetime,'" + $('fecha_forzado').value + "',103)</fecha_forzado>"

            if ($('fecha_forzado_hasta').value != "")
                filtro += "<fecha_forzado type='menor'>convert(datetime,'" + $('fecha_forzado_hasta').value + "',103)+1</fecha_forzado>"

            if ($('fecha_venc').value != "")
                filtro += "<fe_venc type='mas'>convert(datetime,'" + $('fecha_venc').value + "',103)</fe_venc>"

            if ($('fecha_venc_hasta').value != "")
                filtro += "<fe_venc type='menor'>convert(datetime,'" + $('fecha_venc_hasta').value + "',103)+1</fe_venc>"

            if ($('fecha_desde2').value != "")
                filtro += "<momento type='mas'>convert(datetime,'" + $('fecha_desde2').value + "',103)</momento>"

            if ($('fecha_hasta2').value != "")
                filtro += "<momento type='menor'>convert(datetime,'" + $('fecha_hasta2').value + "',103)+1</momento>"

            if (alta_cli != "")
                filtro += "<momento type='mas'>convert(datetime,'" + alta_cli + "',103)</momento>"

            if (alta_cli_to != "")
                filtro += "<momento type='menor'>convert(datetime,'" + alta_cli_to + "',103)+1</momento>"

            if ($('tipo_docu').value != '') {
                filtro += "<tipo_docu type='igual'>" + $('tipo_docu').value + "</tipo_docu>"
            } else {
                if ($('ibs_cliente_oficial').value != "" &&  $('nro_archivo_id_tipo').value == 2 ) {

                    var rs_ofi = new tRS()
                    rs_ofi.open({
                        filtroXML: nvFW.pageContents.filtroEntidadesCons,
                        filtroWhere: "<criterio><select><filtro><ofinrodoc type='in'>" + $('ibs_cliente_oficial').value + "</ofinrodoc></filtro></select></criterio>"
                    })

                    filtro += "<nro_docu type='in'>0"

                    while (!rs_ofi.eof()) {

                        filtro += ', ' + rs_ofi.getdata('nrodoc')
                        rs_ofi.movenext()
                    }
                    filtro += "</nro_docu>"

                }

            }

            if ($('descripcion').value != "")
                filtro += '<archivo_descripcion type="like">%' + $('descripcion').value + '%</archivo_descripcion>'

            if ($('reclamo').value != "")
                filtro += "<reclamable type='igual'>'" + $('reclamo').value + "'</reclamable>"

            if ($('interno').value != "") {
                if ($('interno').value == 1) {
                    filtro += "<interno type='igual'>2</interno>"
                } else {
                    filtro += "<interno type='isnull'></interno>"
                }
            }

            if ($('razon_social').value != '')
                filtro += "<razon_social type='like'>%" + $('razon_social').value + "%</razon_social>"

            if ($('tipo_docu').value != '')
                filtro += "<tipo_docu type='igual'>" + $('tipo_docu').value + "</tipo_docu>"

            if ($('documento').value != '')
                filtro += "<nro_docu type='in'>" + $('documento').value + "</nro_docu>"

            if ($('persona').value != '')
                filtro += "<persona_fisica type='igual'>" + $('persona').value + "</persona_fisica>"
            
        }

        //ASIGNA VALOR AL CAMPO_DEF TIPO
        //function asignarTipo() {
        //    if ($(tipoAlert).value == 1) {
        //        campos_defs.set_value('nro_archivo_id_tipo', 1)
        //    } else {
        //        campos_defs.set_value('nro_archivo_id_tipo', 2)
        //    }
        //    filtrosEnt()
        //}

        function btnBuscar_onclick(modo) {
            //ALERTA EN CASO DE QUE NO SE SELECCIONE UN TIPO
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

               
            if ($('nro_archivo_id_tipo').value == 2) {
                reporte = 'report\\archivo\\HTML_reclamos_archivos.xsl'
                filtroXML = nvFW.pageContents.filtroReclamos_ent
                filtroWhere = "<criterio><select PageSize='1000000' top='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtro + "</filtro></select></criterio>"
            } else if ($('nro_archivo_id_tipo').value == 1) {
                reporte = 'report\\archivo\\HTML_reclamos_archivos.xsl'
                filtroXML = nvFW.pageContents.filtroReclamos_sol
                filtroWhere = "<criterio><select PageSize='1000000' top='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session' ><filtro>" + filtro + "</filtro></select></criterio>"
            } else {
                reporte = 'report\\archivo\\HTML_reclamos_archivos.xsl'
                filtroXML = nvFW.pageContents.filtroReclamos
                filtroWhere = "<criterio><select PageSize='1000000' top='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session' ><filtro>" + filtro + "</filtro></select></criterio>"
            }


            if (modo == 'EXL') {

                //EXPORTAR REPORTE
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
                var params = '<parametros><nro_operador>' + $('nro_operador').value + '</nro_operador><fecha_desde>' + $('fecha_desde2').value + '</fecha_desde><fecha_hasta>' + $('fecha_hasta2').value + '</fecha_hasta></parametros>'
                nvFW.exportarReporte({
                    filtroXML: filtroXML,
                    filtroWhere: filtroWhere, 
                    path_xsl: reporte,
                    formTarget: 'frame_listado_def',
                    nvFW_mantener_origen: true,
                    cls_contenedor: 'frame_listado_def',
                    parametros: params

                })
            }
            window_onresize()
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
                //$('frame_listado_fil').setStyle({ 'height': 0 + 'px' });

                //if ($('frame_listado_fil').style.display == 'block') {
                //    $('frame_listado_fil').setStyle({ 'height': 50 + 'px' });
                //    FiltroDatos_h = $('divCabe').getHeight()
                //}
                $('frame_listado_def').setStyle({ 'height': body_h - FiltroDatos_h - dif - 25 + 'px' });

            }
            catch (e) { }
        }

        function abrir_entidad_win(evento, nro_archivo_id_tipo, id_tipo) {
            if (nro_archivo_id_tipo == 2) {

                var rs = new tRS()
                rs.open({
                    filtroXML: nvFW.pageContents.filtroEntidades,
                    filtroWhere: '<criterio><select><filtro><nro_entidad type="igual">' + id_tipo + '</nro_entidad></filtro></select></criterio>'
                })

                var url_destino = '/voii/cargar_cliente.aspx'
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
                                }
                            }

                        })

                        var id = win.getId();
                        focus(id);

                        win.showCenter()

                    }

                
            }

        }

        //CAMBIO MASIVO DE ESTADO A FISICO
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

            console.log(xmldato)

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
            Dialog.confirm('<b>¿Esta seguro de que desea pasar los archivos seleccionados a "Fisico"?</b> <br><br> Una vez realizado el cambio, no se podra revertir por medios convencionales.', {
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
                    if ($('tipo_vista').value == 'AR')
                        btnBuscar_onclick('RPT')
                    return param
                }
              
            })


        }

        //EXPORTA A EXCEL LA LISTA FILTRADA
        function exportarExcel() {
            if ($('nro_archivo_id_tipo').value == 2) {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroReclamos,
                    filtroWhere: '<criterio><select><filtro>' + filtro + '</filtro></select></criterio>',
                    path_xsl: "report\\EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    formTarget: "_blank",
                    ContentType: "application/vnd.ms-excel",
                    filename: "Solicitudes.xls"

                })
            } else {
                nvFW.exportarReporte({
                    filtroXML: nvFW.pageContents.filtroReclamos,
                    filtroWhere: '<criterio><select><filtro>' + filtro +  '</filtro></select></criterio>',
                    path_xsl: "report\\EXCEL_base.xsl",
                    salida_tipo: "adjunto",
                    formTarget: "_blank",
                    ContentType: "application/vnd.ms-excel",
                    filename: "Solicitudes.xls"

                })
            }

        }

        //ESCONDE, MUESTRA, HABILITA O DESHABILITA FILTROS 
        function filtrosEnt() {
            if ($('nro_archivo_id_tipo').value == 2) {
                campos_defs.habilitar('ibs_cliente_oficial', true)
                campos_defs.clear('ibs_cliente_oficial')
                campos_defs.habilitar('alta_cli', true)
                campos_defs.clear('alta_cli')
                campos_defs.habilitar('alta_cli_to', true)
                campos_defs.clear('alta_cli_to')

                campos_defs.habilitar('documento', true)
                campos_defs.clear('documento')
                campos_defs.habilitar('tipo_docu', true)
                campos_defs.clear('tipo_docu')
                $('persona').disabled = false
                $('persona').value = ''

                setValues()

            } else {

                campos_defs.clear('ibs_cliente_oficial')
                campos_defs.habilitar('ibs_cliente_oficial', false)
                campos_defs.clear('alta_cli')
                campos_defs.habilitar('alta_cli', false)
                campos_defs.clear('alta_cli_to')
                campos_defs.habilitar('alta_cli_to', false)

                campos_defs.habilitar('documento', false)
                campos_defs.clear('documento')
                campos_defs.habilitar('tipo_docu', false)
                campos_defs.clear('tipo_docu')
                $('persona').disabled = true
                $('persona').value = ''
                setValues()

            }
        }

        //CAMBIA FILTROS SEGUN LA VISTA
        function vistaFiltros() {
            if ($('tipo_vista').value == 'AV') {
                $('persona').disabled = true
                $('persona').value = ''
                campos_defs.habilitar('alta_cli', false)
                campos_defs.clear('alta_cli')
                campos_defs.habilitar('alta_cli_to', false)
                campos_defs.clear('alta_cli_to')
                campos_defs.habilitar('ibs_cliente_oficial', false)
                campos_defs.clear('ibs_cliente_oficial')
                $('tdParam').style.display = 'table-cell'
                $('tdVparam').style.display = 'table-cell'
                $('tdTparam').style.display = 'table-cell'
                $('param_val').style.display = 'table-cell'
                $('frame_listado_fil').style.display = 'block'
                $('frame_listado_fil').style.width = '100%'
                $('tdParam').style.width = 1000
                $('tdVparam').style.width = '50%'
                $('tdTparam').style.width = '50%'
                $('param_val').style.width = '50%'

                window_onresize()
            } else {
                $('persona').disabled = false
                $('persona').value = ''
                campos_defs.habilitar('alta_cli', true)
                campos_defs.clear('alta_cli')
                campos_defs.habilitar('alta_cli_to', true)
                campos_defs.clear('alta_cli_to')
                campos_defs.habilitar('ibs_cliente_oficial', true)
                campos_defs.clear('ibs_cliente_oficial')
                $('tdParam').style.display = 'none'
                $('tdVparam').style.display = 'none'
                $('tdTparam').style.display = 'none'
                $('param_val').style.display = 'none'
                $('frame_listado_fil').style.display = 'none'

                window_onresize()
            }
        }

        function setValues() {
            setFrameVals($('ibs_cliente_oficial').value, $('alta_cli').value, $('alta_cli_to').value)
        }


    </script>
</head>
<body id="cuerpo" onload="return window_onload()" onresize="window_onresize()" style="width: 100%; /*height: 100%;*/ /*overflow: auto*/">
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
        //Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>mas</icono><Desc>Busqueda avanzada</Desc><Acciones><Ejecutar Tipo='script'><Codigo>hidShow()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar1</icono><Desc>Marcar como no digital</Desc><Acciones><Ejecutar Tipo='script'><Codigo>fisicoMasivo('RPT')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuDig"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarExcel('RPT')</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuDig.MostrarMenu()
    </script>


    <div id="divCabe" style="width: 100%; overflow: auto;">        
    <table id='contenedor' class="tb1">

        <tr>
            <td style="width:90%">
                <table style="width: 100%" class="tb1">
                    <tr class="tbLabel">
                        <td class="Tit1" style="width: 200px !important;text-align:center;"><b>Archivo</b></td>
                        <td class="Tit1" style="width: 150px;text-align:center;"><b>Obligatorio</b></td>
                        <td class="Tit1" style="width: 150px;text-align:center;"><b>Interno</b></td>
                        <td class="Tit1" style="width: 355px;text-align:center;"><b>Definición</b></td>
                        <td class="Tit1" style="text-align:center;"><b>Documento</b></td>
                    </tr>
                    <tr>
                        <td style="width: 200px !important">
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
                        <td style="">
                            <select style="width:100%" id="interno">
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
                            <script type="text/javascript">
                                campos_defs.add('descripcion', {
                                    enDB: true,
                                    nro_campo_tipo: 1,
                                    depende_de: 'nro_def_archivos',
                                    //depende_de_campo: 'nro_def_archivos',
                                    mostrar_codigo: false,
                                    filtroXML: nvFW.pageContents.filtroDescArchivos
                                })
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="filtros_vista">
                    <tr class="tbLabel">
                        <td class="Tit1" style="width: 200px !important;text-align:center;"><b>Operador</b></td>
                        <td class="Tit1" style="width: 150px;text-align:center;"><b>Reclamable</b></td>
                        <td class="Tit1" colspan="2" style="width: 250px;text-align:center;"><b>Fecha de alta</b></td>
                        <td class="Tit1" colspan="2" style="width: 250px;text-align:center;"><b>Fecha de vencimiento</b></td>
                        <td class="Tit1" style="text-align:center"><b>Estado</b></td>
                        <td class="Tit1" colspan="2" style="width: 240px;text-align:center;"><b>Fecha forzada</b></td>
                        <td class="Tit1" colspan="2" style="width: 250px;text-align:center;"><b>Fecha documento</b></td>
                    </tr>

                     <tr>
                        <td style="width: 200px !important">
                             <script type="text/javascript">
                                campos_defs.add('nro_operador', { enDB: true, nro_campo_tipo: 1 })
                            </script>
                        </td>
                        <td style="">
                            <select style="width:100%" id="reclamo">
                               <option value=""></option>
                               <option value="R">Si</option>
                               <option value="NO RECLAMAR">No</option>
                            </select>
                        </td>
                        <td style="width: 125px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_desde2', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha desde' })
                            </script>
                        </td>
                        <td style="width: 125px!important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_hasta2', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha hasta' })
                            </script>
                        </td>
                        <td style="width: 125px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_venc', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha desde' })
                            </script>
                        </td>

                        <td style="width: 125px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_venc_hasta', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha hasta' })
                            </script>
                        </td>
                        <td style="">
                            <script>
                                campos_defs.add('estado', {
                                    enDB: false,
                                    nro_campo_tipo: 2,
                                    filtroXML: nvFW.pageContents.filtroEstado,
                                })
                            </script>
                        </td>
                        <td style="width: 120px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_forzado', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha desde' })
                            </script>
                        </td>
                        <td style="width: 120px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_forzado_hasta', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha hasta' })
                            </script>
                        </td>
                        <td style="width: 125px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_docu', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha desde' })
                            </script>
                        </td>
                        <td style="width: 125px !important">
                            <script type="text/javascript">
                                campos_defs.add('fecha_docu_hasta', { enDB: false, nro_campo_tipo: 103, placeholder: 'fecha hasta' })
                            </script>
                        </td>
                    </tr>
                </table>
                <table id='filtros_entidad' style="width: 100%; display:block;" class="tb1">
                    <tbody style="width: 100%; display:block;">
                    <tr class="tbLabel" style="width: 100%; display:inline-table;">
                        <td class="Tit1" style="width:200px !important;text-align:center;"><b>Tipo de persona</b></td>
                        <td class="Tit1"  style="width:250px;text-align:center;"><b>Alta Cliente</b></td>
                        <td class="Tit1"  style="width:200px;text-align:center;"><b>Estado Cliente</b></td>
                        <td class="Tit1" style="text-align:center;"><b>Razon Social</b></td>
                        <td class="Tit1" style="width:150px;text-align:center;"><b>Tipo Documento</b></td>
                        <td class="Tit1" style="width:200px;text-align:center;"><b>Nro. Documento</b></td>
                        <td class="Tit1" style="text-align:center"><b>Oficial de cuenta</b></td>
                    </tr>
                    <tr style="width: 100%; display:inline-table;">
                        <td style="width:200px !important">
                            <select style="width:100%" id="persona">
                               <option value=""></option>
                               <option value="1">Fisica</option>
                               <option value="0">Juridica</option>
                            </select>
                        </td>
                        <td id="campos_def_2" style="width:125px !important">
                            <script type="text/javascript">
                                campos_defs.add('alta_cli', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    target: 'campos_def_2',
                                    placeholder: 'fecha desde'
                                })
                                campos_defs.items['alta_cli'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                        <td id="campos_def_2_to" style="width:125px !important">
                            <script type="text/javascript">
                                campos_defs.add('alta_cli_to', {
                                    enDB: false,
                                    nro_campo_tipo: 103,
                                    target: 'campos_def_2_to',
                                    placeholder: 'fecha hasta'
                                })
                                campos_defs.items['alta_cli_to'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                        <td style="width:200px">
                            <script>
                                campos_defs.add('tiporels')
                            </script>
                        </td>
                        <td id='vrSoc' style="">
                            <script type="text/javascript">
                                campos_defs.add('razon_social', { enDB: false, nro_campo_tipo: 104 })
                            </script>
                        </td>
                        <td id='tpoDocu' style="width:150px; text-align:center">
                            <script type="text/javascript">
                                campos_defs.add('tipo_docu', {
                                    enDB: true,
                                    nro_campo_tipo: 2,
                                    filtroXML: nvFW.pageContents.filtroDocumento
                                })
                            </script>
                        </td>
                        <td id='nroDocu' style="width:200px;">
                            <script type="text/javascript">
                                campos_defs.add('documento', { enDB: false, nro_campo_tipo: 101 })
                            </script>
                        </td>
                        <td id="campos_def_1" style="">
                            <script type="text/javascript">
                                campos_defs.add('ibs_cliente_oficial', {
                                    enDB: true,
                                    nro_campo_tipo: 2,
                                    target: 'campos_def_1'
                                })
                                campos_defs.items['ibs_cliente_oficial'].onchange = function (campo_def) {
                                    setValues()
                                }
                            </script>
                        </td>
                    </tr>
                    </tbody>
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
    <div id="fmList" style="width:100%; height:50px !important; display:none"></div>
    <iframe name="frame_listado_def" id="frame_listado_def" src="/voii/enBlanco.htm" style="width: 100%; height:auto; max-height:817px; overflow:auto" frameborder='0'></iframe>
</body>
</html>