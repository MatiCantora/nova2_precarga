<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    ' Modificacion de Estados
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nro_proceso As Integer = nvFW.nvUtiles.obtenerValor("nro_proceso", "0")
    Dim nro_pago_estado As Integer = nvFW.nvUtiles.obtenerValor("nro_pago_estado", "0")
    Dim nro_com_grupo As Integer

    Dim strXMLmail As String = nvFW.nvUtiles.obtenerValor("strXMLmail", "")

    If modo <> "" AndAlso (modo.ToUpper() = "CE" Or modo.ToUpper() = "SM") Then
        If nro_proceso <> 0 Then
            Dim err As New tError
            Try
                If modo.ToUpper() = "CE" Then
                    ' Recupero el "nro_pago_estado" actual para almacenarlo en los comentarios
                    Dim strSQL As String = "SELECT TOP 1 a.nro_pago_estado, b.pago_estados, b.pago_estados + ' (' + CAST(a.nro_pago_estado AS VARCHAR(5)) + ')' AS comentario " _
                    & " FROM pago_registro_detalle a INNER JOIN pago_estados b ON a.nro_pago_estado = b.nro_pago_estado " _
                    & " WHERE nro_pago_registro IN (SELECT TOP 1 nro_pago_registro FROM pago_proceso WHERE nro_proceso=" & nro_proceso & ")"

                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
                    Dim estado_original As String = ""
                    Dim estado_nuevo As String = ""

                    If Not rs.EOF Then
                        estado_original = rs.Fields("pago_estados").Value & " (" & rs.Fields("nro_pago_estado").Value & ")"
                    End If

                    strSQL = "UPDATE pago_registro_detalle" & " SET nro_pago_estado = " & nro_pago_estado & " WHERE nro_pago_registro IN (SELECT nro_pago_registro FROM pago_proceso WHERE nro_proceso = " & nro_proceso & ")"
                    nvDBUtiles.DBExecute(strSQL)

                    rs = nvDBUtiles.DBExecute("SELECT a.nro_pago_estado, b.pago_estados FROM pago_registro_detalle a INNER JOIN pago_estados b ON a.nro_pago_estado = b.nro_pago_estado WHERE a.nro_pago_estado = " & nro_pago_estado)

                    If Not rs.EOF Then
                        estado_nuevo = rs.Fields("pago_estados").Value & " (" & rs.Fields("nro_pago_estado").Value & ")"
                        err.numError = 0
                        err.titulo = ""
                        err.mensaje = "Registros actualizados correctamente."
                        err.params("nro_proceso") = nro_proceso
                        err.params("nro_pago_estado") = nro_pago_estado
                    End If

                    nvDBUtiles.DBCloseRecordset(rs)

                    ' Insertar nuevo comentario para el cambio de estado
                    'Dim strComentario As String = "<p>" & estado_nuevo & "</p>"
                    Dim strComentario As String = "<p><b>Cambio de estado</b></p>"
                    strComentario &= "<p><b>Estado:</b> " & estado_original & " -> " & estado_nuevo & "</p>"
                    strSQL = "DECLARE @nro_com_tipo int "
                    strSQL += "SELECT @nro_com_tipo=nro_com_tipo FROM com_tipos WHERE com_tipo = 'ABM' "
                    strSQL += "INSERT INTO com_registro (nro_com_tipo, comentario, operador, fecha, nro_com_estado, operador_destino, nro_registro_depende, nro_com_id_tipo, id_tipo) "
                    strSQL += "VALUES (@nro_com_tipo, '" & strComentario & "', dbo.rm_nro_operador(), GETDATE(), 1, null, null, 8, '" & nro_proceso & "')"
                    nvDBUtiles.DBExecute(strSQL)

                End If

                'NOTIFICACION MAIL
                If strXMLmail <> "" Then

                    Dim subject As String = "" 'XML
                    Dim body As String = "" 'XML
                    Dim from As String = ""
                    Dim emails_to As String = ""
                    Dim cc As String = ""
                    Dim adjuntar_pdf As Integer = nvFW.nvUtiles.obtenerValor("pdf", "0")

                    Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
                    objXML.LoadXml(strXMLmail)

                    body = objXML.SelectSingleNode("/mail/body").InnerText
                    subject = objXML.SelectSingleNode("/mail/subject").InnerText
                    Dim NOD = objXML.SelectSingleNode("/mail/nro_pago_concepto")

                    Dim nro_pago_concepto As Integer = nvFW.nvXMLUtiles.getNodeText(objXML, "/mail/nro_pago_concepto", -1)

                    'FROM
                    Dim rsMail As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT [from] FROM transf_conf WHERE transf_conf = 'Notificación IP'")
                    If Not rsMail.EOF Then
                        from = rsMail.Fields("from").Value
                    End If

                    'emails_to
                    If nro_pago_concepto <> -1 AndAlso nro_pago_estado <> -1 Then
                        rsMail = nvDBUtiles.DBExecute("SELECT mail FROM pago_concepto_estado_noti WHERE nro_pago_concepto=" & nro_pago_concepto & " AND nro_pago_estado=" & nro_pago_estado)

                        While Not rsMail.EOF
                            emails_to &= "'" & rsMail.Fields("mail").Value & "',"
                            rsMail.MoveNext()
                        End While

                        ' Eliminar la última coma del string
                        emails_to = emails_to.TrimEnd(","c)
                    End If


                    'EMAIL OPERADOR LOGUEADO
                    Dim sql As String = ""
                    sql = "SELECT "
                    sql += " CASE WHEN ISNULL(LOWER(o.login), '') <> '' THEN LOWER(po.email) ELSE '' END AS mail_operador"
                    sql += " FROM operadores o "
                    sql += " LEFT OUTER JOIN verEntidades po ON po.nro_entidad = o.nro_entidad"
                    sql += " WHERE operador=" & nvFW.nvApp.getInstance.operador.operador

                    rsMail = nvDBUtiles.DBOpenRecordset(sql)

                    If Not rsMail.EOF Then
                        If emails_to = "" Then
                            emails_to = rsMail.Fields("mail_operador").Value
                        End If
                        cc = rsMail.Fields("mail_operador").Value
                    End If

                    If adjuntar_pdf = 0 Then
                        If emails_to <> "" Then
                            err = nvNotify.sendMail(_from:=from, _to:=emails_to, _cc:=cc, _bcc:="", _subject:=subject, _body:=body)
                        Else
                            err.numError = -1
                            err.mensaje = "El mail no se pudo enviar. Falta destinatario."
                            err.debug_desc = "El mail no se pudo enviar. Falta destinatario."
                            err.debug_src = "instruccion_pago_consultar.aspx"
                        End If
                    Else
                        ' Armamos el PDF y lo adjuntamo al enviar
                        Dim err_pdf As New nvFW.tError
                        Dim docbytes() As Byte = Nothing
                        Dim expParam As New nvFW.tnvExportarParam

                        With expParam
                            .filtroXML = nvUtiles.obtenerValor("filtroXML", "")
                            .filtroWhere = nvUtiles.obtenerValor("filtroWhere", "")
                            .path_reporte = nvUtiles.obtenerValor("path_reporte", "")
                            .salida_tipo = nvFW.nvenumSalidaTipo.returnWithBinary
                        End With

                        err_pdf = nvFW.reportViewer.mostrarReporte(expParam)

                        If (err_pdf.numError <> 0) Then
                            err_pdf.response()
                        End If

                        docbytes = Convert.FromBase64String(err_pdf.params("reportBinary"))
                        err_pdf.clear()

                        Dim _filename As String = nvUtiles.obtenerValor("filename", "instruccion_pago.pdf")
                        Dim path_destino_pdf As String = System.IO.Path.GetTempPath & _filename

                        If (System.IO.File.Exists(path_destino_pdf)) Then
                            System.IO.File.Delete(path_destino_pdf)
                        End If

                        Dim fs As New System.IO.FileStream(path_destino_pdf, System.IO.FileMode.Create)
                        fs.Write(docbytes, 0, docbytes.Length)
                        fs.Close()

                        docbytes = Nothing

                        ' Email con PDF adjunto
                        If emails_to <> "" Then
                            err = nvNotify.sendMail(_from:=from, _to:=emails_to, _cc:=cc, _bcc:="", _subject:=subject, _body:=body, _attachByPath:=path_destino_pdf)
                        Else
                            err.numError = -1
                            err.mensaje = "El mail no se pudo enviar. Falta destinatario."
                            err.debug_desc = "El mail no se pudo enviar. Falta destinatario."
                            err.debug_src = "instruccion_pago_consultar.aspx"
                        End If
                    End If


                End If

            Catch ex As Exception
                err.parse_error_script(ex)
                err.numError = 100
                err.titulo = "Error"
                err.mensaje = "Ocurrió un error al intentar cambiar el estado. Consulte con el administrador."
            End Try

            err.response()
        End If

    Else

        Dim strSQL = "SELECT distinct nro_com_grupo FROM com_grupos WHERE com_grupo = 'Registro de edición'"
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
        If Not rs.EOF Then
            nro_com_grupo = rs.Fields("nro_com_grupo").Value
        End If

    End If

    ' Filtros XML encriptados
    Me.contents("filtro_listado_inst_pago_lineal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>nro_proceso, convert(varchar(10), fecha_proceso, 103) as fecha_proceso, convert(varchar(10), fecha, 103) as fecha, nro_pago_concepto, pago_concepto, operador, upper(nombre_operador) as nombre_operador, observaciones, nro_entidad_origen, Razon_social_origen, Abreviacion_origen, nro_entidad_destino, Razon_social_destino, Abreviacion_destino, nro_pago_estado, pago_estados, pago_tipo, banco_orig, nro_cuenta_orig, banco_dest, nro_cuenta_dest, importe_pago_det, nro_pago_estado, Login, ISO_cod, en_espera, pago_en_espera, anulado, pago_anulado, pagado, pago_pagado, pendiente, pago_pendiente, pago_otro, pago_tipo_orig</campos><orden>nro_proceso</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_listado_registros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>nro_pago_registro, convert(varchar(10), fecha, 103) as fecha,nro_pago_concepto,pago_concepto,importe_pago,nro_entidad_origen,Razon_social_origen,nro_entidad_destino,Razon_social_destino,operador,nombre_operador,nro_pago_detalle,nro_pago_estado,pago_estados,pago_tipo,importe_pago_det,banco_orig,nro_cuenta_orig,banco_dest,nro_cuenta_dest</campos><orden>fecha</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_listado_inst_pago") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>nro_proceso, convert(varchar(10), fecha_proceso, 103) as fecha_proceso, convert(varchar(10), fecha, 103) as fecha, nro_pago_concepto, pago_concepto, operador, upper(nombre_operador) as nombre_operador, observaciones, nro_entidad_origen, Razon_social_origen, Abreviacion_origen, nro_entidad_destino, Razon_social_destino, Abreviacion_destino, nro_pago_estado, pago_estados, pago_tipo, banco_orig, nro_cuenta_orig, banco_dest, nro_cuenta_dest, importe_pago_det, count(distinct nro_pago_estado) as cantidad_estados, Login, ISO_cod</campos><orden>nro_proceso</orden><filtro></filtro><grupo>nro_proceso, fecha_proceso, fecha, nro_pago_concepto, pago_concepto, operador, nombre_operador, observaciones, nro_entidad_origen, Razon_social_origen, Abreviacion_origen, nro_entidad_destino, Razon_social_destino, Abreviacion_destino, nro_pago_estado, pago_estados, pago_tipo, banco_orig, nro_cuenta_orig, banco_dest, nro_cuenta_dest, importe_pago_det, Login, ISO_cod</grupo></select></criterio>")
    Me.contents("filtro_cuenta_origen") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>id_cuenta as id, descripcion_cta as campo</campos><orden>campo</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_cambio_estado") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago' top='1'><campos>COUNT(nro_pago_estado) AS cant_estados, COUNT(DISTINCT nro_pago_estado) AS cant_estados_diferentes, nro_pago_estado, pago_estados </campos><grupo>nro_pago_estado, pago_estados</grupo></select></criterio>")
    Me.contents("filtro_estados_posibles") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCire_estado_inst_pago'><campos>nro_pago_estado_hasta AS nro_pago_estado, pago_estados_desc_hasta AS pago_estados_desc</campos><orden>nro_pago_estado_hasta</orden></select></criterio>")
    Me.contents("filtro_exportacion_excel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>nro_proceso as Proceso, convert(varchar(10), fecha, 103) as Fecha, pago_concepto as Concepto, nombre_operador as Operador, nro_entidad_origen, case when Abreviacion_origen is null or Abreviacion_origen = '' then Razon_social_origen else Abreviacion_origen end as Razon_social_origen, nro_entidad_destino, case when Abreviacion_destino is null or Abreviacion_destino = '' then Razon_social_destino else Abreviacion_destino end as Razon_social_destino, pago_estados as Estado, pago_tipo as Tipo_pago, banco_orig as Banco_origen, cbu_orig as CBU_origen, banco_dest as Banco_destino, cbu_dest as CBU_destino, detalle, importe_pago_det as Importe</campos><orden>nro_proceso, fecha</orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_exportacion_pdf") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verInstruccion_pago'><campos>*</campos><orden>nro_proceso, fecha</orden><filtro></filtro></select></criterio>")

    ' Permisos
    Me.addPermisoGrupo("permisos_instruccion_pago")
    Me.addPermisoGrupo("permisos_entidades")

    Me.contents("limpiar_fecha") = nro_proceso <> 0
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Consultar Instrucción de Pago <% = IIf(nro_proceso > 0, nro_proceso, "") %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled {
            background-color: #EBEBE4;
        }
    </style>

    <script type="application/javascript">
        var dif = Prototype.Browser.isIE ? 5 : 0
        var filtroXML = ''
        var filtroWhere = ''
        var plantilla = ''
        var data_inst_pago = {}
        var nro_proceso = parseInt(<% = nro_proceso %>, 10)
        var cant_resultados = 0
        var $body
        var $divMenu
        var $tblFiltros
        var $frmResultados



        function window_onresize() {
            try {
                $frmResultados.style.height = $body.getHeight() - $divMenu.getHeight() - $tblFiltros.getHeight() - dif + 'px'
            }
            catch (e) { }
        }


        function window_onload() {
            $body = $$('body')[0]
            $divMenu = $('divMenu')
            $tblFiltros = $('tblFiltros')
            $frmResultados = $('frmResultados')

            // Valores por defecto
            filtroXML = nvFW.pageContents.filtro_listado_inst_pago
            plantilla = 'HTML_instrucciones_pago_por_ip.xsl'

            // Fecha desde -> por defecto con fecha del día (Solo si no hay que limpiar la misma)
            if (!nvFW.pageContents.limpiar_fecha)
                campos_defs.set_value('fecha_desde', FechaToSTR(new Date(), 1))

            campos_defs.items['entidad_origen'].onchange = entidadOrigenOnchange
            window_onresize()

            if (nro_proceso != 0)
                setearNroProcesoYCargar()

            nvFW.enterToTab = false

        }


        function setearNroProcesoYCargar() {
            campos_defs.set_value("nro_proceso", nro_proceso)
            aplicarFiltro()
        }


        function entidadOrigenOnchange() {
            var entidad_origen = campos_defs.get_value('entidad_origen')
            var $select = $('select_cuenta_origen')

            // limpiar el select
            for (var i = $select.options.length - 1; i > -1; --i)
                $select.options[i] = null

            if (!entidad_origen) {
                $select.disabled = true
                return false
            }
            else {
                var rs = new tRS()
                rs.async = true
                rs.onComplete = function (response) {
                    $select.disabled = true
                    $select.options[0] = new Option('', '') // registro vacio
                    var pos = 1

                    while (!response.eof()) {
                        $select.options[pos] = new Option(response.getdata('campo'), response.getdata('id'))
                        pos++
                        response.movenext()
                    }

                    $select.disabled = false
                }

                rs.open({
                    filtroXML: nvFW.pageContents.filtro_cuenta_origen,
                    filtroWhere: '<criterio><select><filtro><nro_entidad type="igual">' + entidad_origen + '</nro_entidad></filtro></select></criterio>'
                })
            }
        }


        function nuevaInstruccionPago(nro_proceso) {
            // chequear permisos de ABM
            // "permisos_web5" : [11][Instruccion de pago ABM]
            if (!nvFW.tienePermiso('permisos_instruccion_pago', 1)) {
                alert('No posee los permisos necesarios para realizar ésta acción. Consulte con el Administrador.')
                return
            }

            nro_proceso = nro_proceso || null

            if (nro_proceso != null)
                if (chequearEstadosDiferentes(nro_proceso)) {
                    alert('No es posible editar la instrucción de pago ya que hay registros con diferentes estados.')
                    return
                }

            var win_nueva_ip = top.nvFW.createWindow({
                url: '/FW/instruccion_pago/instruccion_pago_abm.aspx' + (nro_proceso != null ? '?nro_proceso=' + nro_proceso : ''),
                title: (!nro_proceso ? '<b>Nueva Instrucción de Pago</b>' : '<b>Editar Instrucción de Pago Nº ' + nro_proceso + '</b>'),
                width: 1680,
                height: 700,
                resizable: true,
                destroyOnClose: true,
                minimizable: false,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion)
                        aplicarFiltro();
                }
            })

            win_nueva_ip.options.userData = { hay_modificacion: false }
            win_nueva_ip.showCenter(true)
        }


        function setFiltroWhere() {
            filtroWhere = ''
            var nro_proceso_vacio = true
            var fe_desde_vacio = true
            var fe_hasta_vacio = true

            if (campos_defs.get_value('nro_proceso')) {
                filtroWhere += "<nro_proceso type='igual'>" + campos_defs.get_value('nro_proceso') + "</nro_proceso>"
                nro_proceso_vacio = false
            }

            if (campos_defs.get_value('nro_operador'))
                filtroWhere += "<operador type='igual'>" + campos_defs.get_value('nro_operador') + '</operador>'

            if (campos_defs.get_value('nro_pago_conceptos'))
                filtroWhere += "<nro_pago_concepto type='in'>" + campos_defs.get_value('nro_pago_conceptos') + "</nro_pago_concepto>"

            if (campos_defs.get_value('entidad_origen'))
                filtroWhere += "<nro_entidad_origen type='igual'>" + campos_defs.get_value('entidad_origen') + "</nro_entidad_origen>"

            if ($('select_cuenta_origen').value)
                filtroWhere += "<id_cuenta_orig type='igual'>" + $('select_cuenta_origen').value + "</id_cuenta_orig>"

            //if (campos_defs.get_value('nro_pago_estado'))
            //    filtroWhere += "<nro_pago_estado type='igual'>" + campos_defs.get_value('nro_pago_estado') + "</nro_pago_estado>"

            if (campos_defs.get_value('nro_pago_estado') != '')
                switch (campos_defs.get_value('nro_pago_estado')) {
                    case '0':
                        filtroWhere += "<en_espera type='mayor'>0</en_espera>"
                        break;
                    case '1':
                        filtroWhere += "<pendiente type='mayor'>0</pendiente>"
                        break;
                    case '2':
                        filtroWhere += "<pagado type='mayor'>0</pagado>"
                        break;
                    case '3':
                        filtroWhere += "<anulado type='mayor'>0</anulado>"
                        break;
                    default:
                        filtroWhere += "<otro type='mayor'>0</otro>"
                        break;

                }

            if (campos_defs.get_value('nro_moneda') != '')
                filtroWhere += "<nro_moneda type='in'>" + campos_defs.get_value('nro_moneda') + "</nro_moneda>"

            if (campos_defs.get_value('fecha_desde')) {
                filtroWhere += "<fecha type='mas'>convert(datetime, '" + campos_defs.get_value('fecha_desde') + "', 103)</fecha>"
                fe_desde_vacio = false
            }

            if (campos_defs.get_value('fecha_hasta')) {
                filtroWhere += "<fecha type='menor'>dateadd(dd, 1, convert(datetime, '" + campos_defs.get_value('fecha_hasta') + "', 103))</fecha>"
                fe_hasta_vacio = false
            }

            // Comprobar que el filtro contenga nro_proceso o alguna de las fechas (desde, hasta)
            if (nro_proceso_vacio && fe_desde_vacio && fe_hasta_vacio) {
                alert("Debe proporcionar al menos un valor para <b>Nro. Proceso</b> o para <b>Fecha desde</b> y/o <b>Fecha hasta</b>")
                return false
            }

            return true
        }

        var paginacion = ''
        function aplicarFiltro() {
            if (!setFiltroWhere())
                return

            switch ($('tipo_vista').value) {
                case 'R':
                    filtroXML = nvFW.pageContents.filtro_listado_registros
                    plantilla = 'HTML_instrucciones_pago_por_registro.xsl'
                    paginacion = ''
                    break;
                case 'IP':
                    filtroXML = nvFW.pageContents.filtro_listado_inst_pago
                    plantilla = 'HTML_instrucciones_pago_por_ip.xsl'
                    paginacion = ''
                    break;
                case 'IP2':
                    filtroXML = nvFW.pageContents.filtro_listado_inst_pago_lineal
                    plantilla = 'HTML_instrucciones_pago_por_ip2.xsl'
                    paginacion = ''
                    break;
                case 'L':
                    filtroXML = nvFW.pageContents.filtro_listado_inst_pago_lineal
                    plantilla = 'HTML_instrucciones_pago_por_ip_lineal.xsl'
                    var cantFilas = Math.floor(($("frmResultados").getHeight() - 18) / 22)
                    paginacion = " PageSize='" + cantFilas + "' AbsolutePage='1' expire_minutes='1' cacheControl='Session'"
                    break;
            }

            cargarInstruccionesPago()
        }


        function limpiarFiltro() {
            campos_defs.clear('fecha_desde')
            campos_defs.clear('fecha_hasta')
            campos_defs.clear('nro_operador')
            campos_defs.clear('nro_pago_conceptos')
            campos_defs.clear('entidad_origen')
            campos_defs.clear('nro_pago_estado')
            $('tipo_vista').value = 'IP'
            // Consulta, filtro y plantilla por defecto
            filtroXML = nvFW.pageContents.filtro_listado_inst_pago
            filtroWhere = ''
            plantilla = 'HTML_instrucciones_pago_por_ip.xsl'
        }


        function cargarInstruccionesPago() {
            nvFW.exportarReporte({
                filtroXML: filtroXML,
                filtroWhere: '<criterio><select' + paginacion + '><filtro>' + filtroWhere + '</filtro></select></criterio>',
                path_xsl: 'report/verInstruccionPago/' + plantilla,
                formTarget: 'frmResultados',
                cls_contenedor: 'frmResultados',
                cls_contenedor_msg: ' ',
                bloq_contenedor: $('frmResultados'),
                bloq_msg: 'Cargando instrucciones de pago...',
                nvFW_mantener_origen: true
            })
        }


        function destinatario_abm() {

            win_destinatario = nvFW.createWindow({
                url: 'noti_destinatario_abm.aspx',
                title: '<b>ABM Destinatario</b>',
                width: 700,
                height: 450,
                destroyOnClose: true//,
                //onClose: function (w) {
                //    if (w.options.userData.hay_modificacion)
                //        aplicarFiltro()
                //}
            })

            //win_destinatario.options.userData = {hay_modificacion: false}
            win_destinatario.showCenter()
        }


        var ultimo_estado = '0'   // por defecto: "En espera (0)"
        var ultimo_estado_desc = 'En espera'
        var arr_estados = []
        var win_cambiarEstado


        function cambiarEstado(nro_proceso, fecha, nro_pago_concepto, pago_concepto, nombre_operador, tipo_moneda) {
            // chequear permisos de ABM
            // "permisos_web5" : [11][Instruccion de pago ABM]
            if (!nvFW.tienePermiso('permisos_instruccion_pago', 1)) {
                alert('No posee los permisos necesarios para realizar ésta acción. Consulte con el Administrador.')
                return
            }

            if (chequearEstadosDiferentes(nro_proceso)) {
                alert('No es posible cambiar el estado de la instrucción de pago ya que hay registros con diferentes estados.')
                return
            }

            var importe_total = ObtenerVentana('frmResultados').document.getElementById('importe' + nro_proceso).innerHTML

            // Guardar los datos de la Instruccion de Pago
            data_inst_pago['nro_proceso'] = nro_proceso
            data_inst_pago['fecha'] = fecha
            data_inst_pago['nro_pago_concepto'] = nro_pago_concepto
            data_inst_pago['pago_concepto'] = pago_concepto
            data_inst_pago['nombre_operador'] = nombre_operador

            // HTML de la ventana
            var strHTML = '<table class="tb1 highlightOdd highlightTDOver" style="font-size: 13px;">'
            strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Nro. Proceso:&nbsp;</td><td>&nbsp;<b>' + nro_proceso + '</b></td></tr>'
            strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Fecha:&nbsp;</td><td>&nbsp;<b>' + fecha + '</b></td></tr>'
            strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Concepto:&nbsp;</td><td>&nbsp;<b>' + pago_concepto + '</b></td></tr>'
            strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Operador:&nbsp;</td><td>&nbsp;<b>' + nombre_operador + '</b></td></tr>'
            strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Estado actual:&nbsp;</td><td>&nbsp;<b>' + ultimo_estado_desc + '</b></td></tr>'
            if (typeof tipo_moneda != 'undefined')
                strHTML += '<tr><td class="Tit1" style="text-align: right; width: 50%;">Importe:&nbsp;</td><td>&nbsp;<b>(' + tipo_moneda + ') ' + importe_total + '</b></td></tr>'
            strHTML += '<tr><td colspan="2">&nbsp;</td></tr>'
            strHTML += '</table>'
            //strHTML += '<table class="tb1" style="font-size: 13px;">'
            strHTML += '<div id="divMenuEstado" name="divMenuEstado" style="width: 100%; margin: 0; padding: 0;"></div>'
            //strHTML += '<tr class="tbLabel">'
            //strHTML += '<td><input type="checkbox" name="notificar_email" id="notificar_email" style="cursor: pointer;" checked="true" />&nbsp;<b>Notificar por email</b></td>'
            //strHTML += '<td style="text-align: center; cursor: pointer;" onclick="return destinatario_abm()"><b>Destinatario</b></td></tr>'
            //strHTML += '</table>'

            // obtener todos los estados para el usuario en sesion
            // y armar el HTML con botones
            strHTML += '<table class="tb1" style="font-size: 13px;">'
            strHTML += '<style>.btnCambiarEstado { width: 100%; font: 14px Tahoma, Arial, Verdana, sans-serif !important; text-align: center !important; background-color: #DDDDDD !important; border: 2px solid #D0D0D0 !important; } .btnCambiarEstado:hover, .btnCambiarEstado:focus { cursor: pointer; border-color: #b0b0b0 !important; }</style>'

            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.filtro_estados_posibles,
                filtroWhere: '<criterio><select><filtro><nro_pago_estado_desde type="igual">' + ultimo_estado + '</nro_pago_estado_desde></filtro></select></criterio>'
            })

            // chequear si hay datos
            if (rs.recordcount == 0) {
                strHTML += '<tr><td style="width: 100%; text-align: center; color: red;">No existen cambios posibles a los que el operador actual tenga permiso.</td></tr>'
            }
            else {
                var width = 100 / rs.recordcount
                strHTML += '<tr>'
                while (!rs.eof()) {
                    strHTML += '<td style="width: ' + width + '%">'
                    //strHTML += '<tr><td>'
                    strHTML += '<button onclick="cambiarEstadoInstruccion(' + nro_proceso + ', ' + rs.getdata('nro_pago_estado') + ')" title="Pasar todo a ' + rs.getdata('pago_estados_desc') + '" class="btnCambiarEstado">' + rs.getdata('pago_estados_desc') + '</button>'
                    //strHTML += '<button onclick="cambiarEstadoInstruccion(' + nro_proceso + ', ' + rs.getdata('nro_pago_estado') + ')" title="Pasar todo a ' + rs.getdata('pago_estados_desc') + '" class="btnCambiarEstado">Pasar a ' + rs.getdata('pago_estados_desc') + ' (' + rs.getdata('nro_pago_estado') + ')</button>'
                    //strHTML += '</td></tr>'
                    strHTML += '</td>'

                    // guardo los estados para usarlos al momento de armar el BODY para el mail
                    arr_estados[rs.getdata('nro_pago_estado')] = rs.getdata('pago_estados_desc')

                    rs.movenext()
                }
                strHTML += '</tr>'
            }

            strHTML += '</table>'

            win_cambiarEstado = nvFW.createWindow({
                title: '<b>Cambiar estado al proceso ' + nro_proceso + '</b>',
                width: 500,
                height: 250,
                destroyOnClose: true,
                onShow: function (w) {
                    cargarMenuEstado()
                },
                onClose: function (w) {
                    if (w.options.userData.hay_modificacion)
                        aplicarFiltro()
                }
            })

            win_cambiarEstado.options.userData = { hay_modificacion: false }
            win_cambiarEstado.setHTMLContent(strHTML)
            win_cambiarEstado.showCenter(true)


        }

        var vMenuEstado
        function cargarMenuEstado() {
            vMenuEstado = new tMenu('divMenuEstado', 'vMenuEstado')

            vMenuEstado.loadImage('entidad', '/FW/image/icons/email_contacto.png')

            Menus["vMenuEstado"] = vMenuEstado
            Menus["vMenuEstado"].alineacion = 'centro';
            Menus["vMenuEstado"].estilo = 'A';

            Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>entidad</icono><Desc>Destinatarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>destinatario_abm()</Codigo></Ejecutar></Acciones></MenuItem>")

            vMenuEstado.MostrarMenu()

            //<input type='checkbox' name='notificar_email' id='notificar_email' style='cursor: pointer;' checked='true' />&nbsp;<b>Notificar por email</b>
            $('menuItem_divMenuEstado_0').innerHTML = "<input type='checkbox' name='notificar_email' id='notificar_email' style='cursor: pointer; vertical-align: middle' checked='true' />&nbsp;Notificar por email"
        }


        function chequearEstadosDiferentes(nro_proceso) {
            // chequear que el cambio de estado sea factible, es decir, que no puede haber registros con diferentes estados para modificar
            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.filtro_cambio_estado,
                filtroWhere: '<criterio><select><filtro><nro_proceso type="igual">' + nro_proceso + '</nro_proceso></filtro></select></criterio>'
            })

            if (!rs.eof()) {
                if (parseInt(rs.getdata('cant_estados'), 10) > 1)
                    if (parseInt(rs.getdata('cant_estados_diferentes'), 10) > 1)
                        return true

                ultimo_estado = rs.getdata('nro_pago_estado')
                ultimo_estado_desc = rs.getdata('pago_estados')
            }

            return false
        }


        function getXMLMail(nro_proceso, nro_pago_estado) {

            var subject = 'Notificación - Instrucción de Pago - ' + data_inst_pago.pago_concepto
            // Tabla de datos
            var body = "<span><style type='text/css'>*{font-family:Tahoma,Arial,sans-serif;font-size:13px;}.tb{width:100%;border-collapse:collapse;}.tb th,.tb td{border:1px solid grey;text-align:center;}</style></span>"
            body += "<table class='tb'>"
            body += '<tr><th>Nro. Proceso</th><th>Concepto</th><th>Estado</th><th>Operador</th></tr>'
            body += '<tr>'

            try {
                body += '<td>' + nro_proceso + '</td>'
                body += '<td>' + data_inst_pago.pago_concepto + ' (' + data_inst_pago.nro_pago_concepto + ')</td>'
                body += '<td>' + arr_estados[nro_pago_estado] + ' (' + nro_pago_estado + ')</td>'
                body += '<td>' + data_inst_pago.nombre_operador.toUpperCase() + '</td>'
            }
            catch (e) {
                body += '<td colspan="4">Error al obtener datos para el email. Mensaje: ' + e.message + '</td>'
            }

            body += '</tr>'
            body += '</table>'
            body += '<p><b>Para más detalles, visite el siguiente enlace:</b>&nbsp;'

            var url = "/FW/instruccion_pago/instruccion_pago_consultar.aspx?nro_proceso=" + nro_proceso
            var url_href = nvFW.location.origin + "/FW/nvLogin.aspx?app_cod_sistema=" + top.nvSesion.app_cod_sistema + "&url=" + url
            //var url_href = nvFW.location.origin + "/FW/instruccion_pago/instruccion_pago_consultar.aspx?nro_proceso=" + nro_proceso
            body += "<a href='" + url_href + "' target='_blank' style='text-decoration: none;'>Ver instrucción de pago en NOVA</a></p>"
            body += "<br/><b>Observación:</b> " + frmResultados.$('observacion_' + nro_proceso).value + "<br/>"
            body += "<div contenteditable='true' class='observacion' id='observacion'></div>"

            var xmlDatos = "<mail>"
            xmlDatos += "<subject>" + subject + "</subject>"
            xmlDatos += "<body><![CDATA[" + body + "]]></body>"
            xmlDatos += "<nro_pago_concepto>" + data_inst_pago.nro_pago_concepto + "</nro_pago_concepto>"
            xmlDatos += "</mail>"

            return xmlDatos

        }


        function cambiarEstadoInstruccion(nro_proceso, nro_pago_estado) {

            var strXMLmail = ''

            if ($('notificar_email').checked)
                strXMLmail = getXMLMail(nro_proceso, nro_pago_estado)



            // 1) Modificar todos los pagos involucrados al nro_proceso por el nuevo estado
            nvFW.error_ajax_request('instruccion_pago_consultar.aspx', {
                parameters: {
                    modo: 'CE',  // CE: Cambiar Estado
                    nro_proceso: nro_proceso,
                    nro_pago_estado: nro_pago_estado,
                    strXMLmail: strXMLmail,
                    adjuntar_pdf: (nro_pago_estado == 1 ? 1 : 0),
                    filtroXML: nvFW.pageContents.filtro_exportacion_pdf,
                    filtroWhere: "<criterio><select><filtro><nro_proceso type='igual'>" + nro_proceso + "</nro_proceso></filtro></select></criterio>",
                    path_reporte: "report\\verInstruccionPago\\PDF_instrucciones_pago.rpt",
                    filename: "instruccion_pago_" + nro_proceso + ".pdf",
                    observaciones: frmResultados.$('observacion_' + nro_proceso).value
                },
                onSuccess: function (err) {
                    win_cambiarEstado.options.userData.hay_modificacion = true
                    win_cambiarEstado.close()
                },
                onFailure: function (err) {
                    if (err.numError == -1) {
                        win_cambiarEstado.options.userData.hay_modificacion = true
                        win_cambiarEstado.close()
                    }
                },
                bloq_msg: 'Actualizando estado...'
            })
        }


        function abrirEntidadABM() {
            //abrir_ventana_emergente('Entidad_seleccionar.aspx', 'Entidades', 'permisos_entidades', 1, 500, 1000, true, true, true, true, false)
            abrir_ventana_emergente('/FW/funciones/entidad_consultar.aspx?alta_operador=0', 'Entidades', 'permisos_entidades', 1, 500, 1000, true, true, true, true, false)
        }


        function exportarPDF(objData) {
            if (!hayResultados()) {
                alert("No hay instrucciones de pago a exportar.")
                return
            }

            var _filtroWhere = ""

            if (objData != undefined && typeof objData == "object") {
                _filtroWhere = "<criterio><select><filtro>" + objData.filtroWhere + "</filtro></select></criterio>"
                nro_proceso = objData.nro_proceso
            }
            else {
                _filtroWhere = "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>"
            }

            nvFW.mostrarReporte({
                filtroXML: nvFW.pageContents.filtro_exportacion_pdf,
                filtroWhere: _filtroWhere,
                path_reporte: "report\\verInstruccionPago\\PDF_instrucciones_pago.rpt",
                salida_tipo: "adjunto",
                formTarget: "_blank",
                filename: "instruccion_pago_" + (nro_proceso != 0 ? nro_proceso : "listado") + ".pdf",
                ContentType: "application/pdf",
                content_disposition: "inline"
            })

            objData = undefined
            nro_proceso = 0
        }


        function exportarEXCEL() {
            if (!hayResultados()) {
                alert("No hay instrucciones de pago a exportar.")
                return
            }

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_exportacion_excel,
                filtroWhere: '<criterio><select><filtro>' + filtroWhere + '</filtro></select></criterio>',
                path_xsl: "report\\excel_base.xsl",
                salida_tipo: "adjunto",
                ContentType: "application/vnd.ms-excel",
                filename: "instruccion_pago_listado.xls",
                formTarget: "frameExportar",
                parametros: "<parametros><columnHeaders><table><tr><td>Proceso</td><td>Fecha</td><td>Concepto</td><td>Operador</td><td>Nro. entidad origen</td><td>Razón social origen</td><td>Nro. entidad destino</td><td>Razón social destino</td><td>Estado</td><td>Tipo pago</td><td>Banco origen</td><td>CBU origen</td><td>Banco destino</td><td>CBU destino</td><td>Detalle</td><td>Importe</td></tr></table></columnHeaders></parametros>"
            })
        }


        function hayResultados() {
            return cant_resultados > 0
        }


        function verReferencias() {
            var html = $('tbReferencias').innerHTML

            var winReferencias = nvFW.createWindow({
                title: '<b>Referencias</b>',
                width: 200,
                height: 200,
                resizable: false,
                draggable: true,
                minimizable: false,
                maximizable: false,
                closable: true,
                destroyOnClose: true
            })

            winReferencias.setHTMLContent(html)
            winReferencias.showCenter()
        }


        function exportarPDFProceso(nro_proceso) {
            var objData = {
                "nro_proceso": nro_proceso,
                "filtroWhere": "<nro_proceso type='igual'>" + nro_proceso + "</nro_proceso>"
            }

            return exportarPDF(objData)
        }


        function abrir_ventana_emergente(path, descripcion, permiso_grupo, nro_permiso, height, width, minimizable, maximizable, resizable, draggable, modal) {
            if (permiso_grupo && nro_permiso && !nvFW.tienePermiso(permiso_grupo, nro_permiso)) {
                alert("No tiene permisos para acceder a esta opción", {
                    title: "<b>Permisos insuficientes</b>",
                    height: 70,
                    width: 300
                })

                return
            }

            // Medidas por defecto en caso que no esten definidas
            height = height || 512
            width = width || 1024
            minimizable = minimizable !== undefined ? minimizable : false
            maximizable = maximizable !== undefined ? maximizable : false
            resizable = resizable !== undefined ? resizable : false
            draggable = draggable !== undefined ? draggable : true
            modal = modal !== undefined ? modal : false

            var win = nvFW.createWindow({
                title: '<b>' + descripcion + '</b>',
                url: path,
                minimizable: minimizable,
                maximizable: maximizable,
                resizable: resizable,
                draggable: draggable,
                width: width,
                height: height,
                destroyOnClose: true,
                onClose: function () { }
            });

            win.showCenter(modal);
        }


        function listadoArchivos(nro_proceso) {
            if (nro_proceso == undefined)
                return

            var win_listado_archivos = nvFW.createWindow({
                url: 'instruccion_pago_archivos_listado.aspx?nro_proceso=' + nro_proceso,
                title: '<b>Archivos asociados a Instrucción de Pago - Proceso Nº ' + nro_proceso + '</b>',
                width: 800,
                height: 350,
                resizable: false,
                draggable: true,
                minimizable: false,
                maximizable: false,
                closable: true,
                destroyOnClose: true
            })

            win_listado_archivos.showCenter(true)
        }

        function verComentarios(nro_proceso) {

            win_comentario = nvFW.createWindow({
                url: '/fw/comentario/verCom_registro.aspx?nro_com_id_tipo=8&nro_com_grupo=<% = nro_com_grupo %>&collapsed_fck=1&id_tipo=' + nro_proceso + '&do_zoom=0',
                title: '<b>Registro de edición del proceso ' + nro_proceso + '</b>',
                width: 700,
                height: 250,
                destroyOnClose: true
            })

            win_comentario.showCenter()
        }

        function btnBuscar_onkeypress(e) {
            var key = Prototype.Browser.IE ? e.keyCode : e.which
            if (key == 13)
                aplicarFiltro()
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;" onkeypress="return btnBuscar_onkeypress(event)">
    <div id="divMenu" style="width: 100%; margin: 0; padding: 0;"></div>
    <script>
        var vMenu = new tMenu('divMenu', 'vMenu')

        vMenu.loadImage('pdf', '/FW/image/filetype/pdf.png')
        vMenu.loadImage('excel', '/FW/image/filetype/excel.png')
        vMenu.loadImage('nuevo', '/FW/image/icons/file.png')
        vMenu.loadImage('abm', '/FW/image/icons/login.png')
        vMenu.loadImage('info', '/FW/image/icons/info.png')

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>info</icono><Desc>Referencias</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verReferencias()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>pdf</icono><Desc>Exportar PDF</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarPDF()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Excel</Desc><Acciones><Ejecutar Tipo='script'><Codigo>exportarEXCEL()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Entidad ABM</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abrirEntidadABM()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5' style='text-align: center; vertical-align: middle;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaInstruccionPago()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenu.MostrarMenu()

    </script>

    <table class="tb1" id="tblFiltros">
        <tr class="tbLabel">
            <td style="text-align: center;">Nro.</td>
            <td style="text-align: center;">Fecha desde</td>
            <td style="text-align: center;">Fecha hasta</td>
            <td style="text-align: center;">Operador</td>
            <td style="text-align: center;">Pago Concepto</td>
            <td style="text-align: center;">Entidad Origen</td>
            <td style="text-align: center;">Cuenta Origen</td>
            <td style="text-align: center;">Pago Estados</td>
            <td style="text-align: center;">Moneda</td>
            <td style="text-align: center;">Tipo Vista</td>
            <td style="text-align: center;">-</td>
        </tr>
        <tr>
            <td style="width: 120px;">
                <% = nvFW.nvCampo_def.get_html_input("nro_proceso", nro_campo_tipo:=100, enDB:=False) %>
            </td>
            <td style="width: 120px;">
                <% = nvFW.nvCampo_def.get_html_input("fecha_desde", nro_campo_tipo:=103, enDB:=False) %>
            </td>
            <td style="width: 120px;">
                <% = nvFW.nvCampo_def.get_html_input("fecha_hasta", nro_campo_tipo:=103, enDB:=False) %>
            </td>
            <td style="min-width: 100px;">
                <% = nvFW.nvCampo_def.get_html_input("nro_operador") %>
            </td>
            <td style="width: 150px;">
                <% = nvFW.nvCampo_def.get_html_input("nro_pago_conceptos", enDB:=False, nro_campo_tipo:=2, filtroXML:="<criterio><select vista='verPago_conceptos_instruccionPago'><campos>DISTINCT nro_pago_concepto AS id, pago_concepto AS [campo]</campos><orden>[campo]</orden></select></criterio>") %>
            </td>
            <td style="width: 150px;">
                <% = nvFW.nvCampo_def.get_html_input("entidad_origen", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='Pago_entidad'><campos>nro_entidad AS id, Abreviacion AS [campo]</campos><orden>campo</orden><filtro><administrada type='igual'>1</administrada></filtro></select></criterio>") %>
            </td>
            <td style="width: 150px;">
                <select id="select_cuenta_origen" style="width: 100%;" disabled="disabled"></select>
            </td>
            <td style="width: 150px;">
                <% = nvFW.nvCampo_def.get_html_input("nro_pago_estado", nro_campo_tipo:=2) %>
            </td>
            <td style="width: 160px;">
                <% = nvFW.nvCampo_def.get_html_input("nro_moneda", nro_campo_tipo:=2) %>
            </td>
            <td style="width: 120px;">
                <select id="tipo_vista" style="width: 100%;">
                    <option value="IP" selected="selected">Instrucción de pago</option>
                    <option value="R">Registro</option>
                    <option value="L">Lineal</option>
                    <option value="IP2" selected="selected">Instrucción de pago2</option>
                </select>
            </td>
            <td style="width: 120px;">
                <div id="divFiltro"></div>
                <script>
                    var vButtonItems = {}

                    vButtonItems[0] = {}
                    vButtonItems[0]["nombre"] = "Filtro";
                    vButtonItems[0]["etiqueta"] = "Buscar";
                    vButtonItems[0]["imagen"] = "buscar";
                    vButtonItems[0]["onclick"] = "return aplicarFiltro()";

                    var vListButton = new tListButton(vButtonItems, 'vListButton');

                    vListButton.loadImage("buscar", '/FW/image/transferencia/buscar.png')

                    vListButton.MostrarListButton()
                </script>
            </td>
        </tr>
    </table>

    <iframe name="frmResultados" id="frmResultados" style="width: 100%; border: none;"></iframe>
    <iframe name="frameExportar" id="frameExportar" style="display: none;"></iframe>

    <div id="tbReferencias" style="display: none;">
        <table style="width: 100%; height: 100%; font-size: 13px;" cellpadding="0" cellspacing="0">
            <tbody>
                <tr>
                    <td style="width: 100px; height: 100px; text-align: center; background-color: #808080; color: #FFFFFF;">En espera (0)</td>
                    <td style="width: 100px; height: 100px; text-align: center; background-color: #0000FF; color: #FFFFFF;">Pendiente (1)</td>
                </tr>
                <tr>
                    <td style="width: 100px; height: 100px; text-align: center; background-color: #008000; color: #FFFFFF;">Pagado (2)</td>
                    <td style="width: 100px; height: 100px; text-align: center; background-color: #FD0002; color: #FFFFFF;">Anulado (3)</td>
                </tr>
            </tbody>
        </table>
    </div>
</body>
</html>
