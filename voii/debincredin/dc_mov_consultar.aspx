<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<% 
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Me.contents("date") = DateTime.Now.ToShortDateString()


    If Not op.tienePermiso("permisos_debincredin", 1) Then
        Dim errPerm = New tError()
        errPerm.numError = -1
        errPerm.titulo = "No se pudo completar la operación. "
        errPerm.mensaje = "No tiene permisos para ver la página."
        errPerm.mostrar_error()
    End If

    Me.contents("estadosDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_estados'><campos>id_dc_estado as id, dc_estado as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("monedaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>ISO_num as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")
    Me.contents("dc_mov") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDC_movimientos'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("operador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos> distinct Login as id, Login as campo</campos><filtro></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_debincredin")

    Dim next_run As String = "Próxima Actualización Automática de Estado: "
    Try

        If Not next_run Is Nothing Then
            next_run += nvFW.servicios.nvQNET.thread_next_run.ToString("dd/MM/yyyy HH:mm:ss")
        Else
            next_run = "El servicio de actualización de estado se encuentra detenido o fuera del rango horario."
        End If
    Catch ex As Exception
        next_run = "Error al obtener la fecha de próxima consulta."
    End Try

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar CREDIN y DEBIN</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled { background-color: #EBEBE4; }
    </style>

    <script type="application/javascript">
        var filtroWhere

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return serchDeb()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("buscar", "/fw/image/icons/buscar.png")

        //ABRE LA MODAL CON LOS CAMPOS VACIOS PARA GENERAR UN NUEVO DEBIN/CREDIN
        function nuevoCredinDebin(tipo) {

            var title = 'CREDIN'
            if (tipo == 'D') {
                title = 'DEBIN'

                if (!nvFW.tienePermiso('permisos_debincredin', 2)) {
                    alert('No posee permisos para iniciar un Debin');
                    return
                }

            } else {

                if (!nvFW.tienePermiso('permisos_debincredin', 3)) {
                    alert('No posee permisos para iniciar un Credin');
                    return
                }

            }

            var win_nuevo= top.nvFW.createWindow({
                url: '/voii/debincredin/dc_mov.aspx',
                title: '<b>Nuevo '+ title +'</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = { tipo: tipo }

            win_nuevo.showCenter(true)
        }

        //ESTE CHORIZO DE ARGUMENTOS ES LA INFORMACION QUE RECIBE DE LA PLANTILLA Y ENVIA A LA MODAL PARA CARGAR LOS DATOS DE LA TABLA.
        function editar_mov(credito_cuit, credito_cbu, debito_cuit, debito_cbu, fecha_alta, fecha_estado, estado, tipo, nro_mov, concepto, observacion, moneda, idUsuario, idComprobante, importe, lat, lng, precision, ipCli, tipoDisp, plataforma, sucursal, cuenta_cred, cuenta_deb, dc_id, dc_id_estado, dc_estado, db_addDt, db_fecha_expiracion, puntaje, debito_bcra_desc, internalcode, debitoRazonSocial, creditoTipoCta, debitoTipoCta, credito_bcra_desc, reglas, creditoRazonSocial, login, res_descripcion, res_codigo) {
          
            var title = 'CREDIN'
            if (tipo == 'D') {
                title = 'DEBIN'
            }
            var win_nuevo= nvFW.createWindow({
                url: '/voii/debincredin/dc_mov.aspx',
                title: '<b>'+ title +'</b>',
                width: 1080,
                height: 600,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function () {
                }
            })
            win_nuevo.options.userData = {
                modo: 1,
                tipo: tipo,
                credito_cuit: credito_cuit,
                credito_cbu: credito_cbu,
                debito_cuit: debito_cuit,
                debito_cbu: debito_cbu,
                fecha_alta: fecha_alta,
                fecha_estado: fecha_estado,
                estado: estado,
                observacion: observacion,
                moneda: moneda,
                concepto: concepto,
                idUsuario: idUsuario,
                idComprobante: idComprobante,
                importe: importe,
                lat: lat,
                lng: lng,
                precision: precision,
                ipCli: ipCli,
                tipoDisp: tipoDisp,
                plataforma: plataforma,
                sucursal: sucursal,
                cuenta_cred: cuenta_cred,
                cuenta_deb: cuenta_deb,
                nro_mov: nro_mov,
                dc_id: dc_id,
                dc_id_estado: dc_id_estado,
                dc_estado: dc_estado,
                res_descripcion: res_descripcion,
                res_codigo: res_codigo,
                db_addDt: db_addDt,
                db_fecha_expiracion: db_fecha_expiracion,
                //debito_bco: debito_bco,
                internalcode: internalcode,
                debitoRazonSocial: debitoRazonSocial,
                creditoTipoCta: creditoTipoCta,
                debitoTipoCta: debitoTipoCta,
                credito_bcra_desc: credito_bcra_desc,
                debito_bcra_desc: debito_bcra_desc,
                puntaje: puntaje,
                creditoRazonSocial: creditoRazonSocial,
                reglas: reglas,
                login: login
            }

            win_nuevo.showCenter(true)
        }

        function window_onresize()
        {
		  try
		   {
             var frameHeight = $$('body')[0].clientHeight - $('divMenu').offsetHeight - $('cabecera').offsetHeight  
			 
             //$('frmResultados').style.height = frameHeight + 'px';
             //$('frmResultados').style.maxHeight = frameHeight + 'px'
			 $('frmResultados').setStyle({height: (frameHeight + 'px')})

			}
		  catch(e){}
        }

        function window_onload()
        {
            nvFW.enterToTab = false;

            vListButton.MostrarListButton()
            $('fecha_desde_alta').value = nvFW.pageContents.date
            window_onresize()
        }


        function serchDeb() {
            
            setFiltroWhere()
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.dc_mov,
                filtroWhere: "<criterio><select PageSize='"+ setPageSize() +"' AbsolutePage='1' expire_minutes='1' cacheControl='Session'><filtro>" + filtroWhere + "</filtro></select></criterio>",
                path_xsl: "report/credindebin/credin_debin.xsl",
                formTarget: 'frmResultados',
                nvFW_mantener_origen: true,
                cls_contenedor: 'frmResultados'
            })
        }


		function setPageSize() {
		var pagesize = 100
		try {
			pagesize = Math.round($('frmResultados').getHeight() / ($('dc_id').getHeight()) - 1, 0)
			//restamos la cabecera y pie considero 4 el como las row de los mismos
			pagesize = pagesize - 2
		}
		catch (e) { }

		return pagesize
		}

        //CARGAMOS LOS FILTROS
        function setFiltroWhere()
        {
            filtroWhere = ''
            
            if ($('dc_id').value != "")
                filtroWhere += "<dc_id type='igual'>'" + $('dc_id').value + "'</dc_id>"

            if ($('fecha_desde_alta').value != "")
                filtroWhere += "<dc_addDt type='mas'>convert(datetime,'" + $('fecha_desde_alta').value + "',103)</dc_addDt>"

            if ($('fecha_hasta_alta').value != "")
                filtroWhere += "<dc_addDt type='menor'>convert(datetime,'" + $('fecha_hasta_alta').value + "',103)+1</dc_addDt>"

            if ($('fecha_desde_estado').value != "")
                filtroWhere += "<dc_fecha_expiracion type='mas'>convert(datetime,'" + $('fecha_desde_estado').value + "',103)</dc_fecha_expiracion>"

            if ($('fecha_hasta_estado').value != "")
                filtroWhere += "<dc_fecha_expiracion type='menor'>convert(datetime,'" + $('fecha_hasta_estado').value + "',103)+1</dc_fecha_expiracion>"

            if ($('tipo_mov').value != "")
                filtroWhere += "<dc_mov_tipo type='igual'>'" + $('tipo_mov').value + "'</dc_mov_tipo>"

            if ($('estado').value != "")
                filtroWhere += "<dc_id_estado type='igual'>'" + $('estado').value + "'</dc_id_estado>"

            if (campos_defs.get_value('cbu_credito') != "")
                filtroWhere += "<credito_cbu type='like'>%" + campos_defs.get_value('cbu_credito') + "%</credito_cbu>"

            if (campos_defs.get_value('cbu_debito') != "")
                filtroWhere += "<debito_cbu type='like'>%" + campos_defs.get_value('cbu_debito') + "%</debito_cbu>"

            if (campos_defs.get_value('cuit_credito') != "")
                filtroWhere += "<credito_cuit type='like'>%" + campos_defs.get_value('cuit_credito') + "%</credito_cuit>"

            if (campos_defs.get_value('cuit_debito') != "")
                filtroWhere += "<debito_cuit type='like'>%" + campos_defs.get_value('cuit_debito') + "%</debito_cuit>"

            if ($('social_credito').value != "")
                filtroWhere += "<credito_Razon_social type='like'>%" + $('social_credito').value + "%</credito_Razon_social>"

            if ($('social_debito').value != "")
                filtroWhere += "<debito_Razon_social type='like'>%" + $('social_debito').value + "%</debito_Razon_social>"

            if ($('importe').value != "")
                filtroWhere += "<importe type='" + $('condition').value + "'>" + campos_defs.get_value('importe') + "</importe>"

            if ($('internal_code').value != "")
                filtroWhere += "<internalcode type='like'>%" + $('internal_code').value + "%</internalcode>"

            if ($('nro_moneda').value != "")
                filtroWhere += "<moneda type='igual'>" + $('nro_moneda').value + "</moneda>"

            if ($('comprobante').value != "")
                filtroWhere += "<idComprobante type='like'>%" + $('comprobante').value + "%</idComprobante>"

            if ($('operador').value != "")
                filtroWhere += "<Login type='igual'>'" + $('operador').value + "'</Login>"

            console.log(filtroWhere)

        }

        function exportarEXCEL()
        
        {
            setFiltroWhere()
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.dc_mov,
                filtroWhere: '<criterio><select><filtro>' + filtroWhere + '</filtro></select></criterio>',
                path_xsl: "report\\EXCEL_base.xsl",
                salida_tipo: "adjunto",
                formTarget: "_blank",
                ContentType: "application/vnd.ms-excel",
                filename: "debins_credins.xls"

            })
        }

        //ACTUALIZACION MASIVA DE ESTADOS, HOY NO SE USA.
        function actualizarMasivo(xml) {

            error_ajax_request("", {
                parameters: {
                    accion: 'CD',
                    xml: xml
                },
                onSuccess: function (err, transport) {

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    serchDeb()
                },
                onFailure: function (err, transport) {
                    console.log(err)
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                bloq_msg: 'ACTUALIZANDO...',
                error_alert: false
            })
        }

        //CONSULTA INDIVIDUAL DE ESTADO
        function consultarEstado(id_deb, estado, internalcode,dc_mov_tipo) {
		    
            var accion = ""
            var forzar_consulta = false

			if(dc_mov_tipo == "D")
			  accion = "CD" 

            if (dc_mov_tipo == "C") {
                accion = "CC"
                forzar_consulta = true
            }

            error_ajax_request("dc_acciones.aspx", {
                parameters: {
                    accion: accion,
                    id: id_deb,
                    internalcode: internalcode,
                    dc_id_estado: estado,
                    forzar: forzar_consulta
                },
                onSuccess: function (err, transport) {
                    var xmlString = err.params.respuesta
                    
                    var xml = new DOMParser().parseFromString(xmlString, 'text/xml');
                    var params = xml.children
                    //td.innerHTML = params[0].childNodes[37].innerHTML
                    serchDeb() 

                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                onFailure: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    win.close()
                },
                bloq_msg: 'VALIDANDO...',
                error_alert: false
            })
        }

        //VERIFICA QUE EL CBU QUE SE INGRESA NO SEA CUALQUIER COSA
        function validarCBU(cbu) {

            var ponderador = '97139713971397139713971397139713'
            var i
            var nDigito
            var nPond
            var bloque1 = '0' + cbu.substring(0, 7)
            var bloque2
            var nTotal = 0

            for (i = 0; i <= 7; i++) {
                nDigito = bloque1.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador
            //es CVU
            if (cbu.substring(0, 3) == '000') {
                return false;
            }

            if (cbu.substring(7, 8) != i) {
                return false;
            }

            nTotal = 0;

            bloque2 = '000' + cbu.substring(8, 21)

            for (i = 0; i <= 15; i++) {
                nDigito = bloque2.charAt(i)
                nPond = ponderador.charAt(i)
                nTotal = nTotal + (nPond * nDigito) - (Math.floor(nPond * nDigito / 10) * 10)
            }

            i = 0;

            while ((Math.floor((nTotal + i) / 10) * 10) != (nTotal + i)) {
                i += 1;
            }

            // i = digito verificador

            if (cbu.substring(21, 22) != i) {
                return false;
            }

            return true;
        }

        //MOSTRAR REPORTE DE UN USUARIO ESPECÍFICO
        function mostrarReporteDebinCredin(nro_dc_mov) {
            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.dc_mov,
                filtroWhere: "<criterio><select><filtro><nro_dc_mov type='igual'> " + nro_dc_mov + " </nro_dc_mov></filtro></select></criterio>",
                path_reporte: "report/credindebin/dc_comprobante.rpt",
                salida_tipo: "adjunto",
                content_disposition: "attachment",
                filename: "Comprobante Nro " + (nro_dc_mov.toString()).padStart(10, "0") + ".pdf",
                bloq_contenedor: 'frame',
                bloq_msg: "Cargando Información...",
                bloq_id: "frame_detalle"
            })
        }

        function key_Buscar() {
            if ((typeof campos_defs.items[document.activeElement.id] != 'undefined' || typeof $$('input#' + document.activeElement.id) != 'undefined') && window.event.keyCode == 13)
                serchDeb();
        }

        function actualizar() {

            window.location.reload()

        }
    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onkeypress="return key_Buscar()">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu')

        vMenu.loadImage('pdf',   '/FW/image/filetype/pdf.png')
        vMenu.loadImage('excel', '/FW/image/filetype/excel.png')
        vMenu.loadImage('nuevo', '/FW/image/icons/file.png')
        vMenu.loadImage('abm',   '/FW/image/icons/login.png')
        vMenu.loadImage('info',  '/FW/image/icons/info.png')
		vMenu.loadImage('debin', '/voii/image/icons/debin.png')
		vMenu.loadImage('credin', '/voii/image/icons/credin.png')
        
		Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo     = 'A';

        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>info</icono><Desc>Referencias</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verReferencias()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc><%= next_run%></Desc><Acciones><Ejecutar Tipo='script'><Codigo>actualizar()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>pdf</icono><Desc>Exportar PDF</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarPDF()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Excel</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarEXCEL()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abrirEntidadABM()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>debin</icono><Desc>Generar DEBIN</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoCredinDebin('D')</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>credin</icono><Desc>Generar CREDIN</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevoCredinDebin('C')</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()
    </script>
    
<table class="tb1" id="cabecera" >
  <tr>
   <td style="width: 93%">
        
    <table class="tb1" id="tblFiltros">
        <tr class="tbLabel">
            <td style="text-align: center;width: 100px">Tipo Movimiento</td>
            <td style="text-align: center;" colspan="2">Fecha Alta</td>
            <td style="text-align: center;" colspan="2">Fecha Expiración</td>
            <td style="text-align: center;">Estado</td>
        </tr>
        <tr>
            <td style="width: 100px !important">
                <script type="text/javascript">
                    campos_defs.add('tipo_mov', {
                        enDB: false,
                        nro_campo_tipo: 1,
                        filtroXML: nvFW.pageContents.tipoDef
                    })
                </script>
            </td>
            <td style="width: 100px">
                <script type="text/javascript">
                    campos_defs.add('fecha_desde_alta', { enDB: false, nro_campo_tipo: 103, placeholder: 'desde' })
                </script>
            </td>
            <td style="width: 100px">
                <script type="text/javascript">
                    campos_defs.add('fecha_hasta_alta', { enDB: false, nro_campo_tipo: 103, placeholder: 'hasta' })
                </script>
            </td>
            <td style="width: 100px">
                <script type="text/javascript">
                    campos_defs.add('fecha_desde_estado', { enDB: false, nro_campo_tipo: 103, placeholder: 'desde' })
                </script>
            </td>
            <td style="width: 100px">
                <script type="text/javascript">
                    campos_defs.add('fecha_hasta_estado', { enDB: false, nro_campo_tipo: 103, placeholder: 'hasta' })
                </script>
            </td>
            <td style="width: 100px;">
                <script type="text/javascript">
                    campos_defs.add('estado', {
                        enDB: false,
                        nro_campo_tipo: 2,
                        filtroXML: nvFW.pageContents.estadosDef
                    })
                </script>
            </td>
        </tr>
     </table>
     <table class="tb1">
        <tr  class="tbLabel">
            <td style="text-align: center;">Titular Débito</td>
            <td style="text-align: center;">CUIT Débito</td>
            <td style="text-align: center;">CBU Débito</td>
            <td style="text-align: center;">Titular Crédito</td>
            <td style="text-align: center;">CUIT Crédito</td>
            <td style="text-align: center;">CBU Crédito</td>
            <td style="text-align: center;">Operador</td>
        </tr>
        <tr>
            <td style="width: 20%;">
                <input style="width: 100%" type="text" id="social_debito" />
            </td>
            <td style="width: 10%;">
                <script type="text/javascript">
                    campos_defs.add('cuit_debito', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        mask: {
                            mask: '00-00000000-0',
                            lazy: false
                        },
                        onmask_complete: function (campo_def, objcampo_def) {
                            var vec = new Array(10);
                            var cuit = campos_defs.get_value(campo_def);
                            esCuit = false;
                            cuit_rearmado = "";
                            errors = ''
                            for (i = 0; i < cuit.length; i++) {
                                caracter = cuit.charAt(i);
                                if (caracter.charCodeAt(0) >= 48 && caracter.charCodeAt(0) <= 57) {
                                    cuit_rearmado += caracter;
                                }
                            }
                            cuit = cuit_rearmado;
                            if (cuit.length != 11) {  // si no estan todos los digitos
                                esCuit = false;
                                errors = 'Cuit < 11 ';
                                alert("CUIT Menor a 11 Caracteres");
                            } else {
                                x = i = dv = 0;
                                // Multiplico los dígitos.
                                vec[0] = cuit.charAt(0) * 5;
                                vec[1] = cuit.charAt(1) * 4;
                                vec[2] = cuit.charAt(2) * 3;
                                vec[3] = cuit.charAt(3) * 2;
                                vec[4] = cuit.charAt(4) * 7;
                                vec[5] = cuit.charAt(5) * 6;
                                vec[6] = cuit.charAt(6) * 5;
                                vec[7] = cuit.charAt(7) * 4;
                                vec[8] = cuit.charAt(8) * 3;
                                vec[9] = cuit.charAt(9) * 2;

                                // Suma cada uno de los resultado.
                                for (i = 0; i <= 9; i++) {
                                    x += vec[i];
                                }
                                dv = (11 - (x % 11)) % 11;
                                if (dv == cuit.charAt(10)) {
                                    esCuit = true;
                                }
                            }
                            document.MM_returnValue1 = (errors == '');
                        }
                    })
                </script>
                <%--<input style="width: 100%" type="text" id="cuit_debito" onkeypress="return ( this.value.length < 11 )"/>--%>
            </td>
            <td style="width: 12%;">
                <script>
                    campos_defs.add('cbu_debito', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        mask: {
                            mask: '0000000000000000000000',
                            lazy: false,
                            placeholderChar: '#'
                        },
                        onmask_complete: function (campo_def, objcampo_def) { if (validarCBU(campos_defs.get_value(campo_def))) { } else { } }
                    });
                </script>
            </td>
            <td style="width: 20%;">
                <input style="width: 100%" type="text" id="social_credito" />
            </td>
            <td style="width: 10%;">

                <script type="text/javascript">
                    campos_defs.add('cuit_credito', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        mask: {
                            mask: '00-00000000-0',
                            lazy: false
                        },
                        onmask_complete: function (campo_def, objcampo_def) {
                            var vec = new Array(10);
                            var cuit = campos_defs.get_value(campo_def);
                            esCuit = false;
                            cuit_rearmado = "";
                            errors = ''
                            for (i = 0; i < cuit.length; i++) {
                                caracter = cuit.charAt(i);
                                if (caracter.charCodeAt(0) >= 48 && caracter.charCodeAt(0) <= 57) {
                                    cuit_rearmado += caracter;
                                }
                            }
                            cuit = cuit_rearmado;
                            if (cuit.length != 11) {  // si no estan todos los digitos
                                esCuit = false;
                                errors = 'Cuit < 11 ';
                                alert("CUIT Menor a 11 Caracteres");
                            } else {
                                x = i = dv = 0;
                                // Multiplico los dígitos.
                                vec[0] = cuit.charAt(0) * 5;
                                vec[1] = cuit.charAt(1) * 4;
                                vec[2] = cuit.charAt(2) * 3;
                                vec[3] = cuit.charAt(3) * 2;
                                vec[4] = cuit.charAt(4) * 7;
                                vec[5] = cuit.charAt(5) * 6;
                                vec[6] = cuit.charAt(6) * 5;
                                vec[7] = cuit.charAt(7) * 4;
                                vec[8] = cuit.charAt(8) * 3;
                                vec[9] = cuit.charAt(9) * 2;

                                // Suma cada uno de los resultado.
                                for (i = 0; i <= 9; i++) {
                                    x += vec[i];
                                }
                                dv = (11 - (x % 11)) % 11;
                                if (dv == cuit.charAt(10)) {
                                    esCuit = true;
                                }
                            }
                            document.MM_returnValue1 = (errors == '');
                        }
                    })
                </script>
                <%--<input style="width: 100%" type="text" id="cuit_credito" onkeypress="return ( this.value.length < 11 )"/>--%>
            </td>
            <td style="width: 12%;">
                <script>
                    campos_defs.add('cbu_credito', {
                        enDB: false,
                        nro_campo_tipo: 100,
                        mask: {
                            mask: '0000000000000000000000',
                            lazy: false,
                            placeholderChar: '#'
                        },
                        onmask_complete: function (campo_def, objcampo_def) { if (validarCBU(campos_defs.get_value(campo_def))) { } else { } }
                    });
                </script>
            </td>
             <td style="width: 7%">
                <script type="text/javascript">
                    campos_defs.add('operador', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.operador,
                        nro_campo_tipo: 2
                    })
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr class="tbLabel">
            <td style="text-align: center;">ID Movimiento</td>
            <td style="text-align: center;">Comprobante</td>
            <td style="text-align: center;">Código Interno</td>
            <td style="text-align: center;">Moneda</td>
            <td style="text-align: center;" colspan="3">Importe</td>
        </tr>
        <tr>
            <td  style="width: 25%">
                <input type="text" id="dc_id" style="width:100%"/>
            </td>
            <td  style="width: 20%">
                <script type="text/javascript">
                    campos_defs.add('comprobante', {
                        enDB: false,
                        nro_campo_tipo: 101
                    })
                    $('comprobante').addEventListener('keydown', function (e) {
                        if (e.keyCode == 189) {
                            e.preventDefault();
                            return false;
                        }
                    });
                </script>
                <%--<input type="text" id="comprobante" style="width:100%"/>--%>
            </td>
            <td style="width: 25%">
                <input type="text" id="internal_code" style="width:100%"/>
            </td>
            <td style="width: 10%">
                <script type="text/javascript">
                    campos_defs.add('nro_moneda', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.monedaDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.set_value('nro_moneda', 32)
                    campos_defs.items['nro_moneda'].onchange = function (campo_def) {
                        if ($('nro_moneda').value == 32) {
                            $('prefijo').innerHTML = '$'
                        } else if ($('nro_moneda').value == 978) {
                                    $('prefijo').innerHTML = 'EURO'
                        } else {
                                    $('prefijo').innerHTML = 'U$D'
                        }
                    }

                </script>
            </td>
            <td>
                <select id="condition" style="width: 100%">
                    <option value="igual">Igual</option>
                    <option value="mas">Mayor</option>
                    <option value="menor">Menor</option>
                </select>
            </td>
            <td style="width: 35px; text-align:center" id="prefijo">$</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('importe', {
                        enDB: false,
                        nro_campo_tipo: 102,
                        mask: {
                            mask: Number,
                            scale: 2, //dígitos después del punto
                            radix: ',', //separador de decimales
                            mapToRadix: ['.'],  //separador de decimales sin mascara
                            padFractionalZeros: true,  //si es verdadero, coloca ceros al final de la escala
                            thousandsSeparator: '.' //separador de miles
                        }
                    })
                </script>
            </td>
        </tr>
    </table>
   </td>
   <td style="width: 7%">
    <div id="divBuscar"></div>
   </td>
 </tr>
</table>
    <iframe name="frmResultados" id="frmResultados" style="width: 100%;" frameborder='0' style="width:100%;height:100%;overflow:hidden"></iframe>
</body>
</html>
