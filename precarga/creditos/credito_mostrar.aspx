<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%

    'Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    If modo = "A" Then
        'Stop
        Dim err As New nvFW.tError
        Try

            Dim estado As String = nvFW.nvUtiles.obtenerValor("estado", "")
            Dim nro_credito As Integer = nvFW.nvUtiles.obtenerValor("nro_credito", "0")

            Dim rsD = nvFW.nvDBUtiles.DBExecute("select DBO.rm_tiene_permiso('permisos_estado_desde',nro_permiso) as tiene_permiso from Estado where estado = (select estado from verCreditos where nro_credito = " & nro_credito & ")")
            If rsD.Fields("tiene_permiso").Value Then

                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("rm_precarga_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito)
                cmd.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 1, estado)
                Dim rs As ADODB.Recordset = cmd.Execute()
                Dim numError As Integer = rs.Fields("numError").Value
                Dim mensaje As String = rs.Fields("mensaje").Value

                err.numError = numError
                err.titulo = ""
                err.mensaje = mensaje
            Else
                err.numError = 100
                err.titulo = ""
                err.mensaje = "No tiene permisos para cambiar el estado del cr�dito. Verifique."
            End If
        Catch ex As Exception
            err.parse_error_script(ex)
        End Try
        err.response()
    End If

    Me.contents.Add("verCreditos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_credito,nro_docu,tipo_docu,sexo,strNombreCompleto,estado,descripcion,nro_banco,banco,nro_mutual,mutual,nombre_operador,operador,vendedor,convert(varchar,fe_estado,103) as fe_estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado_str,importe_cuota,cuotas,importe_bruto,importe_neto,importe_documentado,gastoscomerc + dbo.rm_PG_suma_importe(nro_credito,18) as gasto_administrativo,saldo_cancelado,dbo.an_cuota_maxima_credito(nro_credito) as cuota_maxima,tipo_cobro,tipo_cuenta_desc,isnull(nro_cuenta,'') as nro_cuenta, descCuentaBanco</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))
    Me.contents.Add("estados_editar", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Estado'><campos>estado</campos><filtro><nro_permiso type='sql'>dbo.rm_tiene_permiso('permisos_editar_estado',nro_permiso) = 1</nro_permiso><estado type='igual'>'%estado%'</estado></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("credito_editar", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='credito'><campos>estado,nro_mutual</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("circuito_estados", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCircuito_estado_credito_permisos_precarga'><campos>distinct estado,desc_estado,nro_credito,'%ismobile%' as ismobile</campos><orden></orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("permisos_estados", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Estado'><campos>DBO.rm_tiene_permiso('permisos_estado_desde',nro_permiso) as tiene_permiso</campos><filtro></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("parametro", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_Parametros'><campos>nro_credito,etiqueta,parametro</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito><parametro type='igual'>'id_gestion_firma_documental'</parametro><parametro_valor type='igual'>1</parametro_valor></filtro></select></criterio>"))

    Me.contents.Add("solicitudes", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_solicitud_rel'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>"))

    Me.contents.Add("contiene_cuenta", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Credito_cobro'><campos>*</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro><orden></orden></select></criterio>"))

    Me.contents.Add("contiene_solicitud", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_solicitud_rel'><campos>*</campos><filtro><estado_solicitud type='in'>'A','C','P'</estado_solicitud><nro_credito type='igual'>%nro_credito%</nro_credito></filtro><orden></orden></select></criterio>"))
    Me.contents.Add("califica_motor_cuad", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='CUAD_motor_calificacion'><campos>*</campos><filtro><not><estado type='igual'>'P'</estado></not><nro_credito type='igual'>%nro_credito%</nro_credito></filtro><orden></orden></select></criterio>"))

    Me.contents.Add("control_estado_vencimiento_cuad", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='credito'><campos>dbo.rm_control_primer_venc_cuad(nro_credito) as control_estado</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro><orden></orden></select></criterio>"))

    Me.addPermisoGrupo("permisos_precarga")
    Me.addPermisoGrupo("permisos_web6")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="viewport" content="width=device-width, minimum-scale=1, initial-scale=1, shrink-to-fit=no">
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="../css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="../css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="../image/icons/nv_admin.ico" />
   
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language='javascript' src="script/precarga.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript" class="table_window">

        var vMenu1 = new tMenu('DIV_Menu1', 'vMenu1');
        vMenu1.alineacion = 'derecho';
        vMenu1.estilo = 'O'

        vMenu1.loadImage("archivo", "../image/nueva.png")
        vMenu1.loadImage("enviar", "../image/send-16.png")

        vMenu1.CargarMenuItemXML("<MenuItem id='0' style='width: 55%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='1' style='width: 15%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>enviar</icono><Desc>Enviar TYC</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEnviarTyc()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='2' style='width: 15%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Solicitudes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnPrintSolicitudes()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='3' style='width: 15%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>MostrarArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")

        var vMenu2 = new tMenu('DIV_Menu2', 'vMenu2');
        vMenu2.alineacion = 'derecho';
        vMenu2.estilo = 'O'

        vMenu2.loadImage("editar", "../image/editar.png")

        vMenu2.CargarMenuItemXML("<MenuItem id='4' style='width: 85%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos del plan</Desc></MenuItem>")
        vMenu2.CargarMenuItemXML("<MenuItem id='5' style='width: 15%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar Plan</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Plan_seleccionar()</Codigo></Ejecutar></Acciones></MenuItem>")
        
        var win = nvFW.getMyWindow()

        var nro_credito = 0
        var nro_docu
        var tipo_docu
        var sexo
        var estado
        var cuotas = 0
        var califica_cuad_motor=false;
        var nro_mutual =0

        function window_onload() {
            vMenu1.MostrarMenu();
            vMenu2.MostrarMenu();

            filtros = win.options.userData.filtros
            nro_credito = filtros['nro_credito']
            var rs = new tRS();
            rs.open({filtroXML: nvFW.pageContents["califica_motor_cuad"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })                
            if(!rs.eof()){
                    califica_cuad_motor=true;
            }

            window_onresize()
            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Cargando informaci�n del cr�dito...')
            credito_mostrar()
            var msj_captura = ''
            msj_captura = verificar_captura(nro_credito)
            if (msj_captura != '')
                alert(msj_captura)
            
        }

        function verificar_captura(nro_credito) {
            var msj_captura = ''
            var rs = new tRS()
            //rs.open("<criterio><select vista='verCapturas_creditos'><campos>*</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito><operador type='distinto'>dbo.rm_nro_operador()</operador><fin_captura type='isnull'/></filtro><orden></orden></select></criterio>") 
            rs.open({ filtroXML: nvFW.pageContents["capturas"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            if (!rs.eof())
                msj_captura = 'El cr�dito <b>N� ' + nro_credito + '</b> se encuentra capturado por el operador <b>' + rs.getdata('nombre_operador') + '</b>, desde <b>' + rs.getdata('captura_origen') + '</b>. No puede ser editado.'
            return msj_captura
        }


                function MostrarArchivos() {
            
            var filtros = {}
            filtros['nro_credito'] = nro_credito
           window.top.precarga.show_modal_window({
                url: '/precarga/Credito_archivos.aspx',
                title: '<b>Archivos - ' + nro_credito + '</b>',
                onClose: MostrarArchivos_return,
                userData: { filtros: filtros }
            });
           
        }

        function MostrarArchivos_return()
        { }

        function ABMArchivos() {

            var filtros = {}
            filtros['nro_credito'] = nro_credito
            window.top.precarga.show_modal_window({
                url: 'ABMDocumentos.aspx',
                title: '<b>ABM Documentos</b>',
                onClose: ABMArchivos_return,
                userData: { filtros: filtros }
            });
        }

        function ABMArchivos_return() {}
        
        function btnPrintSolicitudes() {
           
            if (estado == null)
            {
                estado = $('estado').value
            }
            var strEstados = 'ABDLOPRUZHM'       // Controlar estados que permiten impresion de solicitudes
            if (strEstados.indexOf(estado) == -1 ) {
                alert('El estado en el que se encuentra el cr�dito No permite imprimir papeler�a.')
                return
            }
            else {
                var filtros = {}
                filtros['nro_credito'] = nro_credito
                filtros['nro_rpt_tipo'] = nro_rpt_tipo
                filtros['nro_docu'] = nro_docu
                filtros['tipo_docu'] = tipo_docu
                filtros['sexo'] = sexo

                var nro_rpt_tipo = 1
                
                window.top.precarga.show_modal_window({
                    url: 'RPT_impresion.aspx',
                    title: '<b>Impresi�n de Reportes</b>',
                    userData: { filtros: filtros },
                });
            }    
        }

        var win_plan

        function Plan_seleccionar() {
            var nro_control = 0
            var estado = ''
            var rs = new tRS();
            rs.open({ filtroXML: nvFW.pageContents["credito_editar"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            if (!rs.eof())
                estado = rs.getdata('estado')                    
                nro_mutual = rs.getdata('nro_mutual')  
                if (nro_mutual == 168) {
                alert('No est� permitido editar el plan para esta operatoria')
                return
                }                  
            var strEstados = 'GHLOPRUDMZ'       // Controlar estados que se pueden editar            
            if (strEstados.indexOf(estado) == -1 || (califica_cuad_motor && !nvFW.tienePermiso("permisos_web6", 22))) //si califica por motor cuad y mientras NO tenga permisos para editar dictamen aprobado cuad
                nro_control = 1
            else {
                var rs = new tRS();
                rs.open({ filtroXML: nvFW.pageContents["estados_editar"], params: "<criterio><params estado='" + estado + "' /></criterio>" })
                if (rs.eof())
                    nro_control = 2
            }

            if (nro_control == 1) {
                alert('El Cr�dito se encuentra en un estado en el cual no puede ser Editado.')
                return
            }
            if (nro_control == 2) {
                alert('No posee permisos para editar el Cr�dito')
                return
            }
            var msj_captura = ''
            msj_captura = verificar_captura(nro_credito)
            if (msj_captura != '') {
                alert(msj_captura)
                return
            }

            var param = {}
            param['nro_credito'] = nro_credito
            win_plan = window.top.createWindow2({
                url: 'precarga_plan_seleccionar.aspx?codesrvsw=false',
                title: '<b>Seleccionar Plan</b>',
                centerHFromElement: window.top.$("contenedor"),
                parentWidthElement: window.top.$("contenedor"),
                parentWidthPercent: 0.9,
                parentHeightElement: window.top.$("contenedor"),
                parentHeightPercent: 0.9,
                maxHeight: 500,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: Plan_seleccionar_return
            });
            win_plan.options.userData = { param: param }
            win_plan.showCenter(true)
        }

        function Plan_seleccionar_return() {
            var retorno = win_plan.options.userData.res
            if (retorno)
                credito_mostrar()
        }

        var estadoActual = ''
        var sincuenta = true;

        function credito_mostrar() {
            var importe_mano = 0
            var rsVerCredito = new tRS();
            rsVerCredito.name = 'rsVerCredito'
            rsVerCredito.async = true
            rsVerCredito.onError = function (rs) {
                alert('Error al consultar lo datos. Intente nuevamente')
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
            }
            rsVerCredito.onComplete = function (rs) {
                try{
                        if (!rs.eof()) {
                        $("estado").value=rs.getdata('estado')
                        $('sp_credito').innerHTML = rs.getdata('nro_credito')
                        $('sp_socio').innerHTML = rs.getdata('nro_docu') + ' - ' + rs.getdata('strNombreCompleto')
                        $('sp_estado').innerHTML = rs.getdata('descripcion')
                        estadoActual= rs.getdata('estado')
                        $('sp_fe_estado').innerHTML = rs.getdata('fe_estado_str')
                        $('sp_vendedor').innerHTML = rs.getdata('vendedor')
                        $('sp_banco').innerHTML = rs.getdata('banco')
                        $('sp_mutual').innerHTML = rs.getdata('mutual')
                        
                        var cuenta_desc="SIN CUENTA BANCARIA"
                        var cuenta_desc_tootip="sin datos a�n"
                        
                        if(rs.getdata('nro_cuenta')!=""){
                            cuenta_desc=rs.getdata('tipo_cuenta_desc')+" - "+rs.getdata('nro_cuenta')
                            cuenta_desc_tootip=rs.getdata('descCuentaBanco')
                            sincuenta=false
                        }
                        $('cbudet').update(cuenta_desc)
                        $('cbudet').writeAttribute("tip",cuenta_desc_tootip)
                        $('sp_retirado').innerHTML = parseFloat(rs.getdata('importe_neto')).toFixed(2)
                        $('sp_solicitado').innerHTML = parseFloat(rs.getdata('importe_bruto')).toFixed(2)
                        $('sp_documentado').innerHTML = parseFloat(rs.getdata('importe_documentado')).toFixed(2)
                        $('sp_cuotas').innerHTML = rs.getdata('cuotas') + ' de $ ' + parseFloat(rs.getdata('importe_cuota')).toFixed(2)
                        $('sp_cobro').innerHTML = rs.getdata('tipo_cobro')
                        nro_docu = rs.getdata('nro_docu')
                        tipo_docu = rs.getdata('tipo_docu')
                        sexo = rs.getdata('sexo')
                        login = rs.getdata('nombre_operador')
                        nro_operador = rs.getdata('operador')
                        estado = rs.getdata('estado')
                        cuotas = rs.getdata('cuotas')
                        nro_mutual = rs.getdata('nro_mutual')
                        importe_mano = parseFloat(rs.getdata('importe_neto')) - parseFloat(rs.getdata('gasto_administrativo')) - parseFloat(rs.getdata('saldo_cancelado'))
                        $('sp_cancelado').innerHTML = parseFloat(rs.getdata('saldo_cancelado')).toFixed(2)
                        $('sp_en_mano').innerHTML = parseFloat(importe_mano).toFixed(2)
                        $('sp_cuota_max').innerHTML = parseFloat(rs.getdata('cuota_maxima')).toFixed(2)
                        }

                } catch (error) {
                     console.error(error);
                }

                
                
                 var strEstados = 'PDHXRM'       // Controlar estados que permiten editar cuenta
                 var estado=$("estado").value
                if (strEstados.indexOf(estado) == -1) {
                   $('editar').hide()
                }
                nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                botones_cambiar_estados()
            }
            rsVerCredito.open({ filtroXML: nvFW.pageContents["verCreditos"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            $("notificado_sincuenta").value="0"
        }

        function btnEnviarTyc(){

            if(estadoActual!="1"){
                alert("No est� permitida esta acci�n en el estado actual de cr�dito")
             return;
            }
            //var param = {}
            //param['nro_credito'] = nro_credito
            //var win_enviotyc = window.top.createWindow2({
            //    url: 'precarga_envio_tyc.aspx?crparam='+nro_credito,
            //    title: '<b>Enviar Terminos y condiciones</b>',
            //    centerHFromElement: window.top.$("contenedor"),
            //    parentWidthElement: window.top.$("contenedor"),
            //    parentWidthPercent: 0.9,
            //    parentHeightElement: window.top.$("contenedor"),
            //    parentHeightPercent: 0.9,
            //    maxHeight: 200,
            //    minimizable: false,
            //    maximizable: false,
            //    draggable: true,
            //    resizable: true,
            //    onClose: function(){}
            //});
            //win_enviotyc.options.userData = { param: param }
            //win_enviotyc.showCenter(true)

            var filtros = {}
            filtros['nro_credito'] = nro_credito

            window.top.precarga.show_modal_window({
                url: 'precarga_envio_tyc.aspx?crparam=' + nro_credito,
                title: '<b>Enviar Terminos y condiciones</b>',
                userData: { filtros: filtros },
                onClose: function () { }
            });
        }

        function window_onresize() {
            try {
                //var dif = Prototype.Browser.IE ? 5 : 2
                //body_height = $$('body')[0].getHeight()
                //$('iframe_cr').setStyle({ 'height': body_height - dif })        
                //alert('resize')
                //Ajustar_ventana(300)
                //if (win_rpt_impresion != undefined) {
                //    alert('rpt_impresion_onresize')
                //    win_rpt_impresion.setLocation(topWin, leftWin)
                //    win_rpt_impresion.setSize(widthWin, heightWin)
                //}
                //if (win_files != undefined) {
                //    win_files.setLocation(topWin, leftWin)
                //    win_files.setSize(widthWin, heightWin)
                //}
                //if (win_plan != undefined) {
                //    win_plan.setLocation(topWin, leftWin)
                //    win_plan.setSize(widthWin, heightWin)
                //}
            }
            catch (e) { }
        }

        function botones_cambiar_estados() {

            ismobile = (isMobile()) ? 'true' : 'false'

            var filtroWhere = "<nro_credito type='igual'>" + nro_credito + "</nro_credito><permiso_grupo type='igual'>'permisos_estado'</permiso_grupo>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.circuito_estados,
                filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                params: "<criterio><params ismobile='" + ismobile + "' /></criterio>",
                path_xsl: 'report\\verCircuito_estado_credito_permisos\\HTML_circuito_estado_credito_permisos.xsl',
                formTarget: 'iframe_cambiar_estado',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'iframe_cambiar_estado'
            })
        }

        function cambiar_estado(estadoacambiar) {
            estado = estadoacambiar
            nvFW.error_ajax_request('Credito_cambiar_estado.aspx', {
                parameters: { modo: 'A', nro_credito: nro_credito, estado: estado },
                onSuccess: function (err, transport) {
                    if (err.numError == 0) {
                        var retorno = {}
                        retorno["actualizar"] = true
                        retorno["estado"] = estado
                        retorno['nro_credito']=nro_credito
                        var win = nvFW.getMyWindow()
                        win.options.userData = { res: retorno }
                        win.close()
                    }
                }
            });
        }

        var win_comentario
        var confirma_datos_personales = 0

        function btn_CambiarEstado(estado) {
            var msj_captura = ""

            msj_captura = verificar_captura(nro_credito)
            if (msj_captura != '') {
                alert(msj_captura)
                return
            }


            var rs = new tRS();
            //para los estados esperando tyc y esperando analisis controlo la fecha de vencimiento para creditos del cuad
            if (estado == "1" || estado == "L") {
                rs.open({ filtroXML: nvFW.pageContents["control_estado_vencimiento_cuad"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
                if (!rs.eof()) {
                    if (rs.getdata('control_estado') == 'False' || rs.getdata('control_estado') == false || rs.getdata('control_estado') == 0 || rs.getdata('control_estado') == '0') {
                        alert("Credito Fuera de Vigencia. Debe pasarlo a estado Baja para poder cargar un nuevo CAD por precarga")
                        return
                    }
                }
            }


            rs = new tRS();

            //si el estado a pasar es TYC, necesito que se verique si esta en cuad y si tiene datos personales/cuenta
            if (estado == "1") {
                //rs.open({filtroXML: nvFW.pageContents["califica_motor_cuad"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })                
                //si califica para motor, hace falta confirmacion de datos personales y cuenta antes de pasar a TYC o operatorias varias
                //if(califica_cuad_motor || nro_mutual==950){
                if (1 == 1) { //esta restriccion aplica a todos
                    if (!confirma_datos_personales) {
                        var param_datos = {}
                        param_datos['estado'] = estado
                        param_datos['nro_credito'] = nro_credito
                        var win_confirma_datos = window.top.createWindow2({
                            url: 'confirmar_datos_personales.aspx?nro_credito=' + nro_credito,
                            title: '<b>Confirmar datos personales y cuenta</b>',
                            centerHFromElement: window.top.$("contenedor"),
                            parentWidthElement: window.top.$("contenedor"),
                            parentWidthPercent: 0.9,
                            parentHeightElement: window.top.$("contenedor"),
                            parentHeightPercent: 0.9,
                            maxHeight: 600,
                            minimizable: false,
                            maximizable: false,
                            draggable: true,
                            resizable: true,
                            onClose: function () {

                                if (win_confirma_datos.options.userData.res == true) {
                                    //si se confirman los datos tanto de cuenta como datos personas, cambia de estado
                                    if (win_confirma_datos.options.userData.data.cuenta == 1 && win_confirma_datos.options.userData.data.solicitud == 1) {
                                        confirma_datos_personales = 1
                                        sincuenta = false;
                                        btn_CambiarEstado(estado)
                                    }
                                }
                            }//onClose
                        });//win_confirma_datos
                        win_confirma_datos.options.userData = { param: param_datos, res: false }
                        win_confirma_datos.showCenter(true)
                        return
                    }//para confirma_datos_personales


                    //califica x motor de cuad, debe respetar las siguiente restricciones
                    var mensaje_alerta = ""
                    rs = new tRS();
                    rs.open({ filtroXML: nvFW.pageContents["contiene_cuenta"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
                    if (rs.eof()) {
                        //no contiene cuenta cbu, se alerta
                        mensaje_alerta = "no contiene una cbu cargada"
                    }
                    rs = new tRS();
                    rs.open({ filtroXML: nvFW.pageContents["contiene_solicitud"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
                    if (rs.eof()) {
                        //no contiene solicitud pendiente, se alerta
                        mensaje_alerta += ((mensaje_alerta != "") ? " y no contiene una solicitud de datos personales" : " no contiene una solicitud de datos personales")
                    }
                    if (mensaje_alerta != "") {
                        alert('Atenci�n, el credito ' + mensaje_alerta)
                        return
                    }
                }//calificar por motor de cuad 
            }


            //si esta sin cuenta y no esta notificado, muestro cartel de advertencia
            if (sincuenta && $("notificado_sincuenta").value == "0") {

                Dialog.confirm("No se ha cargado una cuenta bancaria �Desea continuar de todas formas?",
                    {
                        width: 300,
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (w) {
                            $("notificado_sincuenta").value = "1"
                            btn_CambiarEstado(estado)
                        }
                    })
                return
            }

            if (msj_captura != '') {
                alert(msj_captura)
                return
            }

            if (estado == '1') {//cuando se pasa a Esp Aceptacion TyC tienen que tener el parametro "id_gestion_firma_documental" definido                
                rs = new tRS();
                rs.open({ filtroXML: nvFW.pageContents["parametro"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
                if (!rs.eof()) {

                    var parametro = 'id_gestion_firma_documental'
                    var param = {}
                    param['nro_credito'] = nro_credito
                    param['parametro'] = parametro
                    var win_parametro = window.top.createWindow2({
                        url: 'Credito_Parametro_cambiar.aspx?nro_credito=' + nro_credito,
                        title: '<b>Editar Parametro</b>',
                        centerHFromElement: window.top.$("contenedor"),
                        parentWidthElement: window.top.$("contenedor"),
                        parentWidthPercent: 0.9,
                        parentHeightElement: window.top.$("contenedor"),
                        parentHeightPercent: 0.9,
                        maxHeight: 200,
                        minimizable: false,
                        maximizable: false,
                        draggable: true,
                        resizable: true,
                        onClose: function () {
                            if (win_parametro.options.userData.res == true) {
                                cambiar_estado(estado)
                            }
                        }
                    });
                    win_parametro.options.userData = { param: param }
                    win_parametro.showCenter(true)
                }
                else { cambiar_estado(estado) }
            }
            else {
                nvFW.error_ajax_request('Credito_cambiar_estado.aspx', {
                    parameters: { modo: "A", nro_credito: nro_credito, estado: estado },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0) {
                            var retorno = {}
                            retorno["actualizar"] = true
                            retorno["estado"] = estado
                            retorno["nro_credito"] = nro_credito
                            var win = nvFW.getMyWindow()
                            win.options.userData = { res: retorno }
                            win.close()
                        }
                    }
                });
            }
        }

        function mostrarComentarios() {
            var filtros = {}
            filtros['nro_credito'] = nro_credito

            window.top.precarga.show_modal_window({
                url: 'verCom_registro.aspx?nro_com_id_tipo=2&nro_com_grupo=17&collapsed_fck=0&id_tipo=' + nro_credito + '&nro_entidad=0',
                title: '<b>Comentarios de Rechazo</b>',
                userData: { filtros: filtros },
            });
        }

        function Editar_datos() {

            if (!nvFW.tienePermiso("permisos_precarga", 14)) {
                alert('No posee permiso para realizar esta acci�n.')
                return
            }

            var filtros = {}
            filtros['nro_credito'] = nro_credito

            window.top.precarga.show_modal_window({
                url: 'solicitud_cargar.aspx?modo=V&nro_credito=' + nro_credito,
                title: '<b>Solicitud - ' + nro_credito + '</b>',
                userData: { filtros: filtros },
                onClose: datos_return
            });
        }

        function datos_return() {
            var retorno = window.top.options.userData
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                $('containerDiv').setStyle({ height: body_height - dif - 2 + 'px' })
            }
            catch (e) { }
        }

        function CambiarCuenta() {
            var filtros = {}
            filtros['nro_credito'] = nro_credito

            window.top.precarga.show_modal_window({
                url: 'Cuenta_seleccion.aspx?modo=V&nro_credito=' + nro_credito,
                title: '<b>Cuentas - credito ' + nro_credito + '</b>',
                userData: { filtros: filtros },
                onClose: datos_cuenta_return
            });
        }

        function datos_cuenta_return() {
            var retorno = win_cuenta.options.userData
            if (retorno) {
                if (typeof retorno.cuenta_actualizada != "undefined") {
                    if (retorno.cuenta_actualizada == 1) {
                        credito_mostrar()
                    }
                }
            }
        }
        
    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; background-color: white; -webkit-text-size-adjust: none; overflow: auto;">
    <input type="hidden" id="estado" />
    <input type="hidden" id="notificado_sincuenta" value="0" />
    <div style="overflow: auto; -webkit-overflow-scrolling: touch" id="containerDiv">

        <div id="DIV_Menu1" style="width: 100%; margin-bottom: 5px;"></div>

        <div id="divCr1Left" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none;">
                <tr>
                    <td class='Tit1' style="width: auto; display:flex; align-items: center; cursor:pointer" onclick="return Editar_datos()">
                        <img src="../image/editar.png" >
                        <p>Socio</p>
                    </td>
                </tr>
                <tr style="height:30px">
                    <td colspan="2">
                        <span id="sp_credito" style="display: none"></span>
                        <span id="sp_socio"></span>
                    </td>
                </tr>
            </table>
        </div>
        <div id="divCr1Right" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none;">
                <tr>
                    <td class='Tit1' style="width: 25%">Estado</td>
                    <td class='Tit1' style="width: 35%">F.Estado</td>
                    <td class='Tit1' style="width: 40%">Vendedor</td>
                </tr>
                <tr  style="height:30px">
                    <td style="height: 21px;"><a href="#" style='cursor: pointer' onclick="mostrarComentarios()"><span id="sp_estado"></span></a></td>
                    <td><span id="sp_fe_estado"></span></td>
                    <td><span id="sp_vendedor"></span></td>
                </tr>
            </table>
        </div>
        <div id="divCr2Left" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none">
                <tr>
                    <td class='Tit1'>Banco</td>
                </tr>
                <tr  style="height:30px">
                    <td><span id="sp_banco"></span></td>
                </tr>
            </table>
        </div>
        <div id="divCr2Right" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none">
                <tr>
                    <td class='Tit1'>Mutual</td>
                </tr>
                <tr  style="height:30px">
                    <td><span id="sp_mutual"></span></td>
                </tr>
            </table>
        </div>
        <table class="tb1" style="width: 100%">
            <tr>
                <td class='Tit1' style="width: auto; display: flex; align-items: center; cursor: pointer" onclick="return CambiarCuenta()">
                    <img src="../image/editar.png">
                    <p>Cuenta Bancaria</p>
                </td>
            </tr>
            <tr style="height: 30px">
                <td colspan="2"><a href="javascript:;" id="cbudet" class="tooltip default" tip="">Cuenta CBU: </a></td>
            </tr>
        </table>

        <div id="DIV_Menu2" style="width: 100%; margin-bottom: 5px;"></div>

        <div id="divCr3Left" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none">
                <tr>
                    <td class='Tit1' style="width: 35%">Cobro</td>
                    <td class='Tit1' style="width: 20%">Solicitado</td>
                    <td class='Tit1' style="width: 20%">Retirado</td>
                    <td class='Tit1'>Documentado</td>
                </tr>
                <tr  style="height:30px">
                    <td style="text-align: left"><span id="sp_cobro"></span></td>
                    <td style="text-align: right">$ <span id="sp_solicitado"></span></td>
                    <td style="text-align: right">$ <span id="sp_retirado"></span></td>
                    <td style="text-align: right">$ <span id="sp_documentado"></span></td>
                </tr>
            </table>
        </div>
        <div id="divCr3Right" style="width: 100%">
            <table class="tb1" style="border-collapse: collapse; border: none">
                <tr>
                    <td class='Tit1' style="width: 25%">Cuotas</td>
                    <td class='Tit1' style="width: 25%">Cancelado</td>
                    <td class='Tit1' style="width: 25%">En mano</td>
                    <td class='Tit1' style="width: 25%">Cuota M�xima</td>
                </tr>
                <tr  style="height:30px">
                    <td style="text-align: right"><span id="sp_cuotas"></span></td>
                    <td style="text-align: right">$ <span id="sp_cancelado"></span></td>
                    <td style="text-align: right">$ <span id="sp_en_mano"></span></td>
                    <td style="text-align: right">$ <span id="sp_cuota_max"></span></td>
                </tr>
            </table>
        </div>
        <table class="tb1" style="width: 100%">
            <tr class="tbLabel">
                <td style="text-align: left !important">Cambiar estado a:</td>
            </tr>
        </table>
        <div style="overflow: auto; -webkit-overflow-scrolling: touch">
            <iframe name="iframe_cambiar_estado" id="iframe_cambiar_estado" style="width: 100%; border: none"></iframe>
        </div>
    </div>
</body>
</html>
