<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim op = nvFW.nvApp.getInstance.operador

    Dim nro_sol As String = nvFW.nvUtiles.obtenerValor("nro_sol", "")
    Dim nro_sol_tipo As String = nvFW.nvUtiles.obtenerValor("nro_sol_tipo", "")

    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")

    Dim paramXML As String = nvFW.nvUtiles.obtenerValor("paramXML", "")
    If (paramXML <> "") Then 'Cambio de estado o Modificaciones
        Dim estado_nuevo As String = nvFW.nvUtiles.obtenerValor("estado_nuevo", "")
        Dim estado_anterior As String = nvFW.nvUtiles.obtenerValor("estado_anterior", "")

        Dim Err = nvFW.nvVOIIUtiles.solicitud_abm(nro_sol, nro_sol_tipo, estado_anterior, estado_nuevo, paramXML)

        Err.response()
    End If

    Me.contents("nro_operador") = op.operador

    Me.contents("cda") = nvUtiles.getParametroValor("nosis_cda_default")

    Me.contents("nro_sol") = nro_sol

    Me.contents("today") = DateTime.Now

    Me.contents("solXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud'><campos>nro_def_archivo, fe_naci, cuil, nombre, apellido, " +
                                               "sexo, estado_civil, nacionalidad, condicion_laboral, actividad, pep, so, " +
                                                "email, tel_tipo, tel_area, tel_numero, dom_pais, dom_provincia, dom_localidad, com_cod_postal, dom_calle, dom_nro, dom_piso, depto, dom_resto, " +
                                                "nro_sol, nro_sol_tipo, sol_tipo, sol_desc, fe_alta, fe_estado, monto, plazo, Login, sol_estado, sol_estado_desc, sol_estado_estilo, nro_circuito, " +
                                                "esEditable, bloq_operador, bloq_operador_login</campos><filtro><nro_sol type='igual'>'" + nro_sol + "'</nro_sol></filtro></select></criterio>")
    Me.contents("solParamsXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verSol_params'><campos>orden, etiqueta, nro_sol, param, valor, campo_def, tipo_dato, visible, editable, permiso_ver, permiso_edicion, nro_sol_tipo</campos><orden>orden</orden><filtro><nro_sol type='igual'>'" + nro_sol + "'</nro_sol><nro_sol_tipo type='igual'>'" + nro_sol_tipo + "'</nro_sol_tipo></filtro></select></criterio>")

    Me.contents("filtro_histotico_sol") = nvXMLSQL.encXMLSQL("<criterio><select vista='ver_sol_param_valor_log'><campos>*</campos><orden>momento</orden><filtro><nro_sol type='igual'>'" + nro_sol + "'</nro_sol></filtro></select></criterio>")

    Me.contents("solEstadosTransicionXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='ver_cire_estado_detalle'><campos>estado_origen, estado, sol_estado_desc</campos><orden>sol_estado_desc</orden><filtro><vigente type='igual'>1</vigente></filtro></select></criterio>")
    Me.contents("solEstadosXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VerSol_estados'><campos>sol_estado, sol_estado_desc, estilo as sol_estado_estilo, esEditable</campos></select></criterio>")

    'Dim fe_campo As String = ""
    'Dim openro As String = ""
    'Dim rsI As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select valor from sol_params where param='IBS_nro_operacion' and  nro_sol = " & nro_sol.ToString)
    'If rsI.EOF = False Then
    '    openro = rsI.Fields("valor").Value
    'End If
    'If (Not String.IsNullOrEmpty(openro) & IsNumeric(openro)) Then
    '    Dim rsF As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("select fecori from VOII_PF where openro = " + openro,,,,,, "BD_IBS_ANEXA")
    '    If rsF.EOF = False Then
    '        fe_campo = Format(rsF.Fields("fecori").Value, "dd/MM/yyyy")
    '    End If
    'End If
    'Me.contents("filtroSolicitudRPT") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud_PF_OnLine'><campos>*," & fe_campo & " as fecha_constitucion</campos><orden></orden><filtro><nro_sol type='igual'>'" + nro_sol + "'</nro_sol></filtro></select></criterio>")
    Me.contents("filtro_buscar_cuit") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_consolidada' cn='BD_IBS_ANEXA'><campos>DISTINCT nro_entidad, tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, razon_social, fecnac_insc, cliape, clinom, clicondgi, clconddgi, tiporel, tipreldesc, tipocli</campos><filtro><tipdoc type='in'>5,8</tipdoc><nrodoc type='igual'>%cuilValor%</nrodoc></filtro><orden>razon_social</orden></select></criterio>")

    Me.contents("filtroVOII_PF") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_PF' cn='BD_IBS_ANEXA'><campos>fecori,importpact</campos></select></criterio>")
    Me.contents("filtroSolicitudRPT") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verSolicitud_PF_OnLine'><campos>*, CAST('%fe_campo%' AS datetime) as fecha_constitucion,CAST('%importe_campo%' AS money) as capital_pf</campos><orden></orden><filtro><nro_sol type='igual'>'" + nro_sol + "'</nro_sol></filtro></select></criterio>")

    Me.addPermisoGrupo("permisos_solicitudes")

    Me.addPermisoGrupo("permisos_parametros_valor_solicitudes_auto_0")
    Me.addPermisoGrupo("permisos_parametros_valor_solicitudes_auto_1")
    Me.addPermisoGrupo("permisos_parametros_valor_solicitudes_auto_2")
%>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Solicitud N� <%= nro_sol %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    <style type="text/css">
        .tiporel_   /*Desconocido*/
        {
        /*Anaranjado*/
            color: #5d5c0f;background-color: #ffc107 !important;
        }

        .tiporel-1, /*Prospecto*/
        .tiporel1,  /*Cliente Potencial (CCL)*/
        .tiporel2,  /*Cliente en Tramite*/
        .tiporel6,  /*Cliente de Alta Reducida*/
        .tiporel7,  /*Cliente Normal*/
        .tiporel8,  /*Cliente Pend. de Autorizaci�n*/
        .tiporel10, /*Vuelco Sin Cuentas*/
        .tiporel11, /*Alta Masiva*/
        .tiporel12, /*Vuelco Con Cuenta*/
        .tiporel13  /*Firmantes Cust Val*/
        {
        /*Amarillo*/
            color: #a3a21b;background-color: #ffff9e !important;
        }

        .tiporel3 /*Cliente Activo (CCL)*/
        {
        /*Verde*/
            color: #270;background-color: #DFF2BF !important;
        }

        .tiporel4,  /*Cliente Inactivo*/
        .tiporel5,  /*Cliente Suspendido*/
        .tiporel9 /*Cliente Rechazado*/
        {
        /*Rojo*/
            color: #D8000C;background-color: #FFBABA !important;
        }

        .sol_editable{
            position:relative;
            cursor:pointer;
            padding-right: 16px;
        }
        .sol_editable:hover{
            background-image: url(../../fw/image/icons/editar.png);
            background-size: 16px;
            background-repeat: no-repeat;
            background-position: right center;
        }
        
        .param_editable{
            position:relative;
            cursor:pointer;
            padding-right: 16px;
        }
        .param_editable{
            background-image: url(../../fw/image/icons/editar.png);
            background-size: 16px;
            background-repeat: no-repeat;
            background-position: right center;
        }

        div.adaptive {
            width:50%;
            float:left;
        }
        @media screen and (max-width: 940px) {
             div.adaptive {
               width:100%;
               float:none;
             }
        }
        
    </style>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <script type="text/javascript" src="/FW/script/nosis.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        mediaAdaptive = window.matchMedia("(max-width: 940px)")
        bloq_operador = undefined;
        var win_zoom, _divParams = "solParams"
        var verDivParametros = true
        var verDivArchivos = true

        var ventana = nvFW.getMyWindow()
        if (ventana) {
            if (ventana.options.userData == undefined)
                ventana.options.userData = {}

            ventana.options.userData.hay_modificacion = false

            ventana.options.closeCallback = function () {
                
                //Si est� bloqueada por el operador actual, la desbloqueamos al cerrar
                if (bloq_operador == nvFW.pageContents.nro_operador) {
                    var options = {
                        onOk: function () {
                            desbloquearSolicitud();
                            ventana.options.closeCallback = null;
                            ventana.close();
                            return true;
                        },
                        onCancel: function () { ventana.options.closeCallback = null; ventana.close()}
                    }
                    confirm("�Desea desbloquear la solicitud?", options)
                    //desbloquearSolicitud()
                }
                else
                    return true;
            }
        }
        solicitud = {};
        editable = false;

        var params_defSol = new tParam_def()
        var solicitud_params = {}

        var _nro_def_archivo

        function window_onload() {

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function (rs) {
                if (rs.eof()) {
                    nvFW.bloqueo_desactivar($$('body')[0], 'bloq_datos')
                    $("solContainerDiv").hide()
                    $("result_vacio").show()
                    return;
                }

                // ARCHIVOS //
                
                _nro_def_archivo = rs.getdata("nro_def_archivo")
                nvNosis.callback = cargar_NOSIS
                $('frame_archivo').src = '/FW/archivo/mostrar_def_archivos.aspx?habilitar_nosis=true&nro_archivo_id_tipo=1&nro_def_archivo=' + _nro_def_archivo + '&id_tipo=' + nvFW.pageContents.nro_sol


                // COMENTARIOS //
                $('frame_comentario').src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=5&nro_com_grupo=6&collapsed_fck=1&do_zoom=0&id_tipo=' + nvFW.pageContents.nro_sol

                var fe_naci_date = undefined;
                if (rs.getdata("fe_naci"))
                    fe_naci_date = FechaToSTR(new Date(rs.getdata("fe_naci")))
                
                solicitud = {
                    cuil: new tParam_def({ parametro: "cuil", valor: rs.getdata("cuil"), etiqueta: "CUIL", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    nombre: new tParam_def({ parametro: "nombre", valor: rs.getdata("nombre"), etiqueta: "Nombre", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    apellido: new tParam_def({ parametro: "apellido", valor: rs.getdata("apellido"), etiqueta: "Apellido", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    sexo: new tParam_def({ parametro: "sexo", valor: rs.getdata("sexo"), etiqueta: "Sexo", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    estado_civil: new tParam_def({ parametro: "estado_civil", valor: rs.getdata("estado_civil"), etiqueta: "Estado Civil", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    nacionalidad: new tParam_def({ parametro: "nacionalidad", valor: rs.getdata("nacionalidad"), etiqueta: "Nacionalidad", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    condicion_laboral: new tParam_def({ parametro: "condicion_laboral", valor: rs.getdata("condicion_laboral"), etiqueta: "Condici�n Laboral", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    actividad: new tParam_def({ parametro: "actividad", valor: rs.getdata("actividad"), etiqueta: "Actividad", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    pep: new tParam_def({ parametro: "pep", valor: rs.getdata("pep"), etiqueta: "Expuesto Pol�ticamente", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    so: new tParam_def({ parametro: "so", valor: rs.getdata("so"), etiqueta: "Sujeto Obligado", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    fe_naci: new tParam_def({ parametro: "fe_naci", valor: fe_naci_date, etiqueta: "Fecha de Nacimiento", tipo_dato: "datetime", campo_def: "", requerido: false, editable: true }),
                    email: new tParam_def({ parametro: "email", valor: rs.getdata("email"), etiqueta: "Email", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    tel_tipo: new tParam_def({ parametro: "tel_tipo", valor: rs.getdata("tel_tipo"), etiqueta: "Tipo de Tel�fono", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    tel_area: new tParam_def({ parametro: "tel_area", valor: rs.getdata("tel_area"), etiqueta: "Area", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    tel_numero: new tParam_def({ parametro: "tel_numero", valor: rs.getdata("tel_numero"), etiqueta: "N�mero", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    dom_pais: new tParam_def({ parametro: "dom_pais", valor: rs.getdata("dom_pais"), etiqueta: "Pa�s", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    dom_provincia: new tParam_def({ parametro: "dom_provincia", valor: rs.getdata("dom_provincia"), etiqueta: "Provincia", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    dom_localidad: new tParam_def({ parametro: "dom_localidad", valor: rs.getdata("dom_localidad"), etiqueta: "Localidad", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    com_cod_postal: new tParam_def({ parametro: "com_cod_postal", valor: rs.getdata("com_cod_postal"), etiqueta: "C�digo Postal", tipo_dato: "int", campo_def: "", requerido: true, editable: true }),
                    dom_calle: new tParam_def({ parametro: "dom_calle", valor: rs.getdata("dom_calle"), etiqueta: "Calle", tipo_dato: "varchar", campo_def: "", requerido: true, editable: true }),
                    dom_nro: new tParam_def({ parametro: "dom_nro", valor: rs.getdata("dom_nro"), etiqueta: "N�mero", tipo_dato: "int", campo_def: "", requerido: true, editable: true }),
                    dom_piso: new tParam_def({ parametro: "dom_piso", valor: rs.getdata("dom_piso"), etiqueta: "Piso", tipo_dato: "varchar", campo_def: "", requerido: false, editable: true }),
                    depto: new tParam_def({ parametro: "depto", valor: rs.getdata("depto"), etiqueta: "Departamento", tipo_dato: "varchar", campo_def: "", requerido: false, editable: true }),
                    dom_resto: new tParam_def({ parametro: "dom_resto", valor: rs.getdata("dom_resto"), etiqueta: "Aclaraci�n", tipo_dato: "varchar", campo_def: "", requerido: false, editable: true }),
                    nro_sol: new tParam_def({ parametro: "nro_sol", valor: rs.getdata("nro_sol"), etiqueta: "N�mero Solicitud", tipo_dato: "int", campo_def: "", requerido: true }),
                    nro_sol_tipo: new tParam_def({ parametro: "nro_sol_tipo", valor: rs.getdata("nro_sol_tipo"), etiqueta: "N�mero Solicitud Tipo", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    sol_tipo: new tParam_def({ parametro: "sol_tipo", valor: rs.getdata("sol_tipo"), etiqueta: "Tipo", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    sol_desc: new tParam_def({ parametro: "sol_desc", valor: rs.getdata("sol_desc"), etiqueta: "Descripci�n", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    fe_alta: new tParam_def({ parametro: "fe_alta", valor: rs.getdata("fe_alta"), etiqueta: "Fecha de Alta", tipo_dato: "datetime", campo_def: "", requerido: true }),
                    fe_estado: new tParam_def({ parametro: "fe_estado", valor: rs.getdata("fe_estado"), etiqueta: "Fecha de Estado", tipo_dato: "datetime", campo_def: "", requerido: true }),
                    monto: new tParam_def({ parametro: "monto", valor: rs.getdata("monto"), etiqueta: "Monto", tipo_dato: "money", campo_def: "", requerido: true }),
                    plazo: new tParam_def({ parametro: "plazo", valor: rs.getdata("plazo"), etiqueta: "Plazo", tipo_dato: "int", campo_def: "", requerido: true }),
                    login: new tParam_def({ parametro: "login", valor: rs.getdata("Login"), etiqueta: "Login", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    sol_estado: new tParam_def({ parametro: "sol_estado", valor: rs.getdata("sol_estado"), etiqueta: "Estado", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    sol_estado_desc: new tParam_def({ parametro: "sol_estado_desc", valor: rs.getdata("sol_estado_desc"), etiqueta: "Estado Descripci�n", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    sol_estado_estilo: new tParam_def({ parametro: "sol_estado_estilo", valor: rs.getdata("sol_estado_estilo"), etiqueta: "Estado Estilo", tipo_dato: "varchar", campo_def: "", requerido: true }),
                    nro_circuito: new tParam_def({ parametro: "nro_circuito", valor: rs.getdata("nro_circuito"), etiqueta: "N�mero Circuito", tipo_dato: "int", campo_def: "", requerido: true })
                };

                var esEditable = rs.getdata("esEditable")
                solEditable = ["4", "1"].include(esEditable)
                paramEditable = ["4", "3"].include(esEditable)

                // DATOS SOLICITUD //
                mostrarDatos();

                // PARAMETROS //
                mostrarParametros(_divParams);
                
                // CAMBIO ESTADO //
                mostrarListButtonEstados();

                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_datos')
                bloq_operador = rs.getdata('bloq_operador')
                if (bloq_operador && bloq_operador != nvFW.pageContents.nro_operador) {
                    
                    //nvFW.bloqueo_activar($$('body')[0], 'bloqueo_usuario')
                    var objC = $$('body')[0] //objeto contenedor
                    var doc = document // documento contenedor
                    //crear div contenedor
                    var oDiv = doc.createElement("DIV")
                    oDiv.setAttribute("id", "divBloq_usuario")
                    $(oDiv).addClassName("overlay_bloqueo_base")
                    oDiv.style.zIndex = objC.style.zIndex + 1
                    doc.body.appendChild(oDiv)
                    $(oDiv).clonePosition(objC)

                    oDiv.onclick = function () {
                        var mensaje = "Solicitud bloqueada por el operador <b>" + rs.getdata('bloq_operador_login') + "</b>."
                        if (nvFW.tienePermiso('permisos_solicitudes', 4)) {
                            var options = {
                                okLabel: "Desbloquear",
                                cancelLabel: "Cancelar",
                                onOk: function () { desbloquearSolicitud(); return true; }
                            }
                            confirm(mensaje, options)
                        }
                        else
                            alert(mensaje)
                    }
                }
                    

                // MENU
                mostrarMenuPrincipal(rs.getdata('bloq_operador') != undefined)
                
                window_onresize();

            }
            rs.onError = function (rs) {
                
            }

            rs.open({ filtroXML: nvFW.pageContents.solXML });

        }

        function window_onresize() {
            if (mediaAdaptive.matches) {
                $('frame_archivo').setStyle({ 'height': '200px' });
                var resto = $$("body")[0].getHeight() - $$("#solCliente")[0].getHeight() - $$("#solCol")[0].getHeight() - $$("#DIV_MenuComentario")[0].getHeight()
                $('frame_comentario').setAttribute("height", resto < 240 ? "240px" : resto + "px")
                $('bsolicitud').setStyle({ 'overflow': 'auto' });
                //var suma = $$("#solCol")[0].getHeight()
                //$('frame_comentario').setAttribute("height", suma + "px")
            }
            else {
                //$('frame_archivo').setStyle({ 'height': ($$("body")[0].getHeight() - $$("#solCliente")[0].getHeight() - $$("#solDatos")[0].getHeight()) + 'px' });
                //$('frame_comentario').setAttribute("height", ($$("#solCol")[0].getHeight() - $$("#DIV_MenuComentario")[0].getHeight()) + "px")
                $('solContainerDiv').setStyle({ height: $$("body")[0].getHeight() + "px" })
                $('frame_comentario').setStyle({ height: $$("body")[0].getHeight() - $$("#solCliente")[0].getHeight() - $$("#DIV_MenuComentario")[0].getHeight() + "px" })

                resize_closeable_divs();

            }

            if ($("divBloq_usuario"))
                $("divBloq_usuario").clonePosition($$('body')[0])
        }


        function resize_closeable_divs() {
            var tamanioParametros = 0
            var tamanioArchivos = 0

            var tamanioDivs = $$('body')[0].getHeight() - $('solCliente').getHeight() - $('solDatosCont').getHeight() - $('solEstados').getHeight() - $('DIV_MenuParametro').getHeight() - $('DIV_MenuArchivo').getHeight()

            if (verDivParametros && verDivArchivos) {
                tamanioParametros = tamanioDivs / 2;
                tamanioArchivos = tamanioDivs / 2;
            } else {
                if (verDivParametros)
                    tamanioParametros = tamanioDivs;
                else tamanioArchivos = tamanioDivs;
            }

            $('solParams').setStyle({ height: tamanioParametros + 'px' });
            $('frame_archivo').setStyle({ height: tamanioArchivos + 'px' });
        }


        function mostrarMenuPrincipal(bloqueado) {
            DIV_MenuCliente.innerHTML = ""
            vMenuCliente = new tMenu('DIV_MenuCliente', 'vMenuCliente');
            Menus["vMenuCliente"] = vMenuCliente
            Menus["vMenuCliente"].alineacion = 'centro';
            Menus["vMenuCliente"].estilo = 'A';
            //vMenuCliente.loadImage("imprimir", "/FW/image/icons/imprimir.png");
            vMenuCliente.loadImage("ejecutar", "/FW/image/icons/procesar.png");
            vMenuCliente.loadImage("propiedades", "/FW/image/icons/propiedades.png");
            
            Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos del Cliente</Desc></MenuItem>")
            if (bloqueado) {
                vMenuCliente.loadImage("abrir", "/FW/image/icons/abierto.png");
                Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abrir</icono><Desc>Desbloquear Solicitud</Desc><Acciones><Ejecutar Tipo='script'><Codigo>desbloquearSolicitud()</Codigo></Ejecutar></Acciones></MenuItem>")
            }
            else {
                vMenuCliente.loadImage("cerrar", "/FW/image/icons/cerrar.png");
                Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cerrar</icono><Desc>Bloquear Solicitud</Desc><Acciones><Ejecutar Tipo='script'><Codigo>bloquearSolicitud()</Codigo></Ejecutar></Acciones></MenuItem>")
            }
            Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>propiedades</icono><Desc>Propiedades</Desc><Acciones><Ejecutar Tipo='script'><Codigo>propiedadesAvanzado()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>ejecutar</icono><Desc>Ejecutar Proceso</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ejecutarProceso()</Codigo></Ejecutar></Acciones></MenuItem>")
            //Menus["vMenuCliente"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>Reporte</Desc><Acciones><Ejecutar Tipo='script'><Codigo>imprimirSolicitud()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuCliente.MostrarMenu()
        }

        function _calculateAge(birthday) {
            var ageDifMs = nvFW.pageContents.today - birthday.getTime();
            var ageDate = new Date(ageDifMs);
            return Math.abs(ageDate.getUTCFullYear() - 1970);
        }
        
        function mostrarDatos() {
            // Situaci�n cliente
            if (tdCliente.innerText == "") {
                $("tdCliente").className = $("tdCliente").className.replace(/\btiporel\b/g, "");
                var ibsCliRs = new tRS();
                ibsCliRs.async = true
                ibsCliRs.onComplete = function (rs) {
                    if (!ibsCliRs.eof()) {
                        $("tdCliente").update(ibsCliRs.getdata("tipreldesc"))
                        $("tdCliente").classList.add('tiporel' + ibsCliRs.getdata("tiporel"))
                        $("cuilLabel").colSpan = "2";
                        $("tdVerCliente").show();
                        $("tdVerCliente").update('<img id="verClienteSelf" title="Ver Cliente" height="16px" alt="Ver" src="/FW/image/icons/ver.png" style="cursor:pointer">')
                        $$('#verClienteSelf')[0].onclick = function (event) { verEntidad(event, ibsCliRs.getdata("nro_entidad"), ibsCliRs.getdata("tipdoc"), ibsCliRs.getdata("nrodoc"), ibsCliRs.getdata("tipocli"), ibsCliRs.getdata("razon_social"), ibsCliRs.getdata("tiporel")); };
                    }
                    else {
                        $("cuilLabel").colSpan = "1";
                        $("tdVerCliente").hide()
                        $("tdVerCliente").update('')
                        $("tdCliente").update('Desconocido')
                        $("tdCliente").classList.add('tiporel_')
                    }
                    nvFW.bloqueo_desactivar($('tdCliente'), 'bloq_cliente')
                }
                nvFW.bloqueo_activar($('tdCliente'), 'bloq_cliente')
                ibsCliRs.open({ filtroXML: nvFW.pageContents.filtro_buscar_cuit, params: "<criterio><params cuilValor='" + solicitud.cuil.valor + "'/></criterio>" })
            }

            // CLIENTE //
            $("cuil").value = solicitud.cuil.valor  //Hidden para pasar a los campos def
            $("tdCuil").update(solicitud.cuil.valor)
            $("nombre").update(solicitud.nombre.valor)
            $("apellido").update(solicitud.apellido.valor)
            $("sexo").update(solicitud.sexo.valor)
            $("estado_civil").update(solicitud.estado_civil.valor)

            $("nacionalidad").update(solicitud.nacionalidad.valor)
            $("condicion_laboral").update(solicitud.condicion_laboral.valor)
            $("actividad").update(solicitud.actividad.valor)
            $("pep").update(solicitud.pep.valor)
            $("so").update(solicitud.so.valor)

            if (solicitud.fe_naci.valor) {
                $("fe_naci").update(solicitud.fe_naci.valor)
                $("edadCliente").update(_calculateAge(parseFecha(solicitud.fe_naci.valor, 'dd/mm/yyyy')))
            }
            else {
                $("fe_naci").update("")
                $("edadCliente").update("")
            }

            $("email").update(solicitud.email.valor)
            var telefono = ""
            if (solicitud.tel_tipo.valor)
                telefono += "(" + solicitud.tel_tipo.valor + ")"
            if (solicitud.tel_area.valor)
                telefono += " " + solicitud.tel_area.valor + " -"
            if (solicitud.tel_numero.valor)
                telefono += " " + solicitud.tel_numero.valor
            $("telCliente").update(telefono)

            $("dom_pais").update(solicitud.dom_pais.valor)
            $("dom_provincia").update(solicitud.dom_provincia.valor)
            $("dom_localidad").update(solicitud.dom_localidad.valor)
            $("com_cod_postal").update(solicitud.com_cod_postal.valor)

            var direccion = solicitud.dom_calle.valor + " " + solicitud.dom_nro.valor
            if (solicitud.dom_piso.valor)
                direccion += " - Piso: " + solicitud.dom_piso.valor
            if (solicitud.depto.valor)
                direccion += " - Depto: " + solicitud.depto.valor
            if (solicitud.dom_resto.valor)
                direccion += " - Aclaraci�n: " + solicitud.dom_resto.valor
            $("domCliente").update(direccion)

            //Campos Editables
            $("nombre", "apellido", "estado_civil", "nacionalidad", "condicion_laboral", "actividad", "fe_naci",
                "email", "telCliente", "domCliente", "dom_pais", "dom_provincia", "dom_localidad", "com_cod_postal")
                .invoke(solEditable ? 'addClassName' : 'removeClassName', 'sol_editable')
                .each(function (e) {
                    if (solEditable)
                        e.observe('click', td_onclick);
                    else
                        e.stopObserving('click', td_onclick);
                });

            // SOLICITUD //
            $("nro_sol").update(solicitud.nro_sol.valor)
            $("sol_tipo").update(solicitud.sol_tipo.valor)
            $("sol_estado_desc").update(solicitud.sol_estado_desc.valor).setStyle(solicitud.sol_estado_estilo.valor)
            $("sol_desc").update(solicitud.sol_desc.valor)
            $("fe_alta").update(FechaToSTR(new Date(solicitud.fe_alta.valor)) + " " + HoraToSTR(new Date(solicitud.fe_alta.valor)))
            $("fe_estado").update(FechaToSTR(new Date(solicitud.fe_estado.valor)) + " " + HoraToSTR(new Date(solicitud.fe_estado.valor)) + " (" + solicitud.login.valor + ")")          
            if (solicitud.monto.valor != '') {
                $("monto").update("$" + formatoDecimal(solicitud.monto.valor, 2))
            }
            $("plazo").update(solicitud.plazo.valor + " d�as")
        }

        function mostrarListButtonEstados() {
            var estadosRs = new tRS();
            estadosRs.open(nvFW.pageContents.solEstadosTransicionXML, "", "<nro_circuito type='igual'>" + solicitud.nro_circuito.valor +"</nro_circuito><estado_origen type='igual'>'" + solicitud.sol_estado.valor + "'</estado_origen>");
            $('cambioEstados').innerHTML = "";
            if (estadosRs.recordcount > 0) {
                $$("#DIV_MenuEstado")[0].show();
                var vButtonEstados = {};
                var botonesPorFila = 4;
                var widthButton = 100 / (estadosRs.recordcount > botonesPorFila ? botonesPorFila : estadosRs.recordcount);
                while (!estadosRs.eof()) {
                    if (estadosRs.position % botonesPorFila == 0)
                        $('cambioEstados').insert('<tr style="height: 26px"></tr>');
                    $$('#cambioEstados tr').last().insert('<td style="width: ' + widthButton + '%"><div id="divEstado' + estadosRs.getdata("estado") + '" style="width: 100%"></div></td>');

                    vButtonEstados[estadosRs.position] = {};
                    vButtonEstados[estadosRs.position]["nombre"] = "Estado" + estadosRs.getdata("estado");
                    vButtonEstados[estadosRs.position]["etiqueta"] = estadosRs.getdata("sol_estado_desc");
                    vButtonEstados[estadosRs.position]["imagen"] = "play";
                    vButtonEstados[estadosRs.position]["onclick"] = "return CambiarEstado('" + estadosRs.getdata("estado") + "')";
                    estadosRs.movenext()
                }
                var vListButtonEstados = new tListButton(vButtonEstados, 'vListButtonEstados');
                vListButtonEstados.loadImage("play", '/FW/image/icons/play.png');
                vListButtonEstados.MostrarListButton()
            }
            else {
                $$("#DIV_MenuEstado")[0].hide();
            }
            
        }

        var options_params = {
            width: 600,
            height: 400,
            maximizable: false,
            minimizable: false,
            title: "<b>Editar Par�metros</b>"
        }

        function mostrarParametros(divParams) {
            options_params.params = []
            options_params.params.push(new tParam_def({ parametro: 'cuil', tipo_dato:"int", valor: solicitud.cuil.valor, visible: false }))
            options_params.params.push(new tParam_def({ parametro: 'nro_sol', tipo_dato:"int", valor: solicitud.nro_sol.valor, visible: false }))
            
            solicitud_params = params_defSol.add(nvFW.pageContents.solParamsXML, "", divParams, callback_param_onSave, nvFW.pageContents.filtro_histotico_sol, options_params)

        }


        function verEntidad(event, nro_entidad, tipdoc, nrodoc, tipocli, nombre, tiporel) {
            var url_destino = "/voii/cargar_cliente.aspx"
            if (tiporel < 0) {
                //Entidad de Nv
                url_destino += "?nro_entidad=" + nro_entidad + "&tipdoc=" + tipdoc + "&nrodoc=" + nrodoc + "&tipocli=" + tipocli + "&titulo=" + nombre + "&tiporel=" + tiporel
            }
            else {
                //IBS
                var tipo_docu_ibs = tipdoc;

                url_destino += "?nro_entidad=" + nro_entidad + "&tipdoc=" + tipo_docu_ibs + "&nrodoc=" + nrodoc + "&tipocli=" + tipocli + "&titulo=" + nombre + "&tiporel=" + tiporel
            }

            //abrir_ventana_emergente(url_destino, nombre, 'permisos_entidades', 2, 500, 1000, true, true, true, true, false, 'frame_ref', evento)

            // Abrir datos seg�n modificadores (Ctrl | Shift)
            if (event.ctrlKey) {
                // Nueva pesta�a
                var newWin = window.open(url_destino)
            }
            else if (event.shiftKey) {
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
                    title: '<b>' + nombre + '</b>',
                    width: top.innerWidth * 0.788,
                    height: top.innerHeight * porcentajeHeight,
                    destroyOnClose: true
                })

                win_vinculo.showCenter(false)
            }

        }

        function CambiarEstado(abreviacion, fecha) {
            var nuevoEstadoRs = new tRS();
            nuevoEstadoRs.open(nvFW.pageContents.solEstadosXML, "", "<sol_estado type='igual'>'" + abreviacion + "'</sol_estado>");
            if (!nuevoEstadoRs.eof()) {
                
                var ventana = nvFW.getMyWindow()
                nvFW.confirm("�Confirma pasar la solicitud a estado <b>" + nuevoEstadoRs.getdata("sol_estado_desc") + "</b>?",
                    {
                        okLabel: 'Si',
                        cancelLabel: 'No',
                        onOk: function (win) {

                            var pXML = "<sol modo='E' nro_sol='" + nvFW.pageContents.nro_sol + "'><estado actual='" + solicitud.sol_estado.valor + "' nuevo='" + abreviacion + "' >"
                            if (fecha)
                                pXML += "<fecha><![CDATA[" + fecha + "]]></fecha>"
                            pXML += "</estado></sol>"
                            
                            nvFW.error_ajax_request('solicitud_abm.aspx', {
                                parameters: { paramXML: pXML, nro_sol: nvFW.pageContents.nro_sol, estado_anterior: solicitud.sol_estado.valor, estado_nuevo: nuevoEstadoRs.getdata("sol_estado"), nro_sol_tipo: solicitud.nro_sol_tipo.valor },
                                bloq_msg: "Cambiando Estado",
                                onFailure: function (err, transport) {

                                    window_onload()
                                },
                                onSuccess: function (err, transport) {
                                    
                                    
                                    if (err.numError == 0) {


                                        window_onload()

           //                             //Editable seg�n el estado
           //                             var esEditable = nuevoEstadoRs.getdata("esEditable")
           //                             solEditable = ["4", "1"].include(esEditable)
           //                             paramEditable = ["4", "3"].include(esEditable)

           //                             solicitud.sol_estado.valor = nuevoEstadoRs.getdata("sol_estado");
           //                             solicitud.sol_estado_desc.valor = nuevoEstadoRs.getdata("sol_estado_desc");
           //                             solicitud.sol_estado_estilo.valor = nuevoEstadoRs.getdata("sol_estado_estilo");
           //                             solicitud.fe_estado.valor = fecha ? parseFecha(fecha, "dd/mm/yyyy") : new Date()

           //                             mostrarDatos()
           //                             mostrarParametros(_divParams)
           //                             mostrarListButtonEstados()

           //                             window_onresize()

           //                             //Si pasa a estado Terminado, cambia la definici�n de archivo
           //                             if (solicitud.sol_estado.valor == "T") {
											//$('frame_archivo').contentWindow.cargarHistorial()
           //                             }
           //                             //Si se est� visualizando el grupo ABM, debemos actualizar comentarios
           //                             if ($('frame_comentario').contentWindow.nro_com_grupo == 3)
           //                                 $('frame_comentario').contentWindow.Mostrar_Registro_grupo(3, 'ABM');

                                        win.options.userData = { res: 'ok' }

                                        if (ventana)
                                            ventana.options.userData.hay_modificacion = true    
                                    }

                                    win.close()
                                },
                                error_alert:true                                
                            });

                            win.close();

                        },
                        onCancel: function (win) {
                            win.close();
                        }
                    })
            }

        } 

        function bloquearSolicitud() {
            var pXML = "<sol modo='Q' nro_sol='" + nvFW.pageContents.nro_sol + "'><bloqueo>true</bloqueo></sol>"

            nvFW.error_ajax_request('solicitud_abm.aspx', {
                parameters: { paramXML: pXML, nro_sol: nvFW.pageContents.nro_sol },
                //bloq_msg: "Bloqueando",
                onSuccess: function (err, transport) {

                    if (err.numError == 0) {
                        bloq_operador = nvFW.pageContents.nro_operador
                        mostrarMenuPrincipal(true)
                        if (ventana)
                            ventana.options.userData.hay_modificacion = true    
                    }

                },
                error_alert: true
            });
        }
        function desbloquearSolicitud() {
            var pXML = "<sol modo='Q' nro_sol='" + nvFW.pageContents.nro_sol + "'><bloqueo>false</bloqueo></sol>"

            nvFW.error_ajax_request('solicitud_abm.aspx', {
                parameters: { paramXML: pXML, nro_sol: nvFW.pageContents.nro_sol },
                //bloq_msg: "Desbloqueando",
                onSuccess: function (err, transport) {

                    if (err.numError == 0) {
                        mostrarMenuPrincipal(false)
                        bloq_operador = 0
                        if ($("divBloq_usuario")) {
                            $("divBloq_usuario").remove()
                        }
                        if (ventana)
                            ventana.options.userData.hay_modificacion = true    
                    }

                },
                error_alert: true
            });
        }

        function callback_onSave(params)
        {
            //Guarga los datos
            var er = new tError()

            //var errors = "";
            //var win = nvFW.getMyWindow()

            var pXMLcampos = ""
            
            for (var i = 0; i < params.length; i += 1) {
                if (params[i].visible && params[i].editable)
                    pXMLcampos += "<dato campo='" + params[i].parametro + "' esParametro='0'><valor><![CDATA[" + params[i].valor + "]]></valor><etiqueta><![CDATA[" + params[i].etiqueta + "]]></etiqueta> </dato>"
            }

            if (pXMLcampos !== "") {
                var pXML = "<sol modo='M' nro_sol='" + nvFW.pageContents.nro_sol + "'>" + pXMLcampos + "</sol>";

                nvFW.error_ajax_request('solicitud_abm.aspx', {
                    parameters: { paramXML: pXML, nro_sol: nvFW.pageContents.nro_sol },
                    //asynchronous: false,
                    onSuccess: function (err, transport) {

                        if (err.numError == 0) {

                            //Actualizo los datos
                            for (var i = 0; i < params.length; i += 1) {
                                if (params[i].visible && params[i].editable)
                                    solicitud[params[i].parametro].valor = params[i].valor
                            }

                            mostrarDatos()

                            if ($('frame_comentario').contentWindow.nro_com_grupo == 3)
                                $('frame_comentario').contentWindow.Mostrar_Registro_grupo(3, 'ABM');

                        }

                    },
                    error_alert: true
                });
            }
            
            return er
        }

        function callback_param_onSave(params) {
            //Guarda los datos
            var er = new tError()

            //var errors = "";
            //var win = nvFW.getMyWindow()

            var pXMLcampos = ""
            var permisoEdicionAvanzada = nvFW.tienePermiso('permisos_solicitudes', 5)

            for (var i = 0; i < params.length; i += 1) {
                let allow = (params[i].visible && params[i].editable) || permisoEdicionAvanzada
                if (allow)
                    pXMLcampos += "<dato campo='" + params[i].parametro + "' esParametro='1'><valor><![CDATA[" + params[i].valor + "]]></valor><etiqueta><![CDATA[" + params[i].etiqueta + "]]></etiqueta> </dato>"
            }

            if (pXMLcampos !== "") {
                var pXML = "<sol modo='M' nro_sol='" + nvFW.pageContents.nro_sol + "'>" + pXMLcampos + "</sol>";
                
                nvFW.error_ajax_request('solicitud_abm.aspx', {
                    parameters: { paramXML: pXML, nro_sol: nvFW.pageContents.nro_sol },
                    onSuccess: function (err, transport) {
                        if (err.numError == 0) {
                            //Actualizo los datos
                            for (var i = 0; i < params.length; i += 1) {
                                let allow = (params[i].visible && params[i].editable) || permisoEdicionAvanzada
                                if (allow && solicitud_params[params[i].parametro] != undefined)
                                    solicitud_params[params[i].parametro].valor = params[i].valor
                            }
                            
                            if (win_zoom)
                                win_zoom.options.userData.hayModificacion = true

                            mostrarParametros(_divParams)


                            if ($('frame_comentario').contentWindow.nro_com_grupo == 3)
                                $('frame_comentario').contentWindow.Mostrar_Registro_grupo(3, 'ABM');

                        }

                    },
                    error_alert: true
                });

            }

            return er
        }

    
        function td_onclick(e) {

            if (!solEditable)
                return;

            var el = e.element()
            var id = el.id
            var paramsArr = []
            var options = {}

            
            switch (id) {
                case 'nombre':
                case 'apellido':
                    paramsArr.push(solicitud.nombre)
                    paramsArr.push(solicitud.apellido)

                    options.width = 400
                    break
                case 'domCliente':
                    paramsArr.push(solicitud.dom_calle)
                    paramsArr.push(solicitud.dom_nro)
                    paramsArr.push(solicitud.dom_piso)
                    paramsArr.push(solicitud.depto)
                    paramsArr.push(solicitud.dom_resto)

                    options.title = "<b>Editar Domicilio</b>",
                    options.width = 400
                    break
                
                case 'telCliente':
                    paramsArr.push(solicitud.tel_tipo)
                    paramsArr.push(solicitud.tel_area)
                    paramsArr.push(solicitud.tel_numero)

                    options.title = "<b>Editar Tel�fono</b>",
                    options.width = 400
                    break
                case 'com_cod_postal':
                case 'dom_localidad':
                case 'dom_provincia':
                case 'dom_pais':
                case 'estado_civil':
                case 'nacionalidad':
                case 'fe_naci':
                    paramsArr.push(solicitud[id])
                    options.width = 300
                    break
                default:
                    paramsArr.push(solicitud[id])

            }

            nvFW.param_def_setValues(paramsArr, options_params, callback_onSave, null, false)
        }

        function advanceEditParam_onclick() {
            
            if (!nvFW.tienePermiso('permisos_solicitudes', 5)) {
                alert("No posee permisos para realizar esta acci�n.")
                return;
            }

            var paramsArr = []

            //hiddens
            //paramsArr.push(new tParam_def({ parametro: 'cuil', valor: solicitud.cuil.valor, visible: false }))
            //paramsArr.push(new tParam_def({ parametro: 'nro_sol', valor: solicitud.nro_sol.valor, visible: false }))

            for (p in solicitud_params) {
                let pCopy = Object.assign({}, solicitud_params[p]);

                if (pCopy.parametro == 'cuil' || pCopy.parametro == 'nro_sol')
                    pCopy.editable = pCopy.visible = false
                else
                    pCopy.editable = pCopy.visible = true

                paramsArr.push(pCopy)
            }
            
            nvFW.param_def_setValues(paramsArr, options_params, callback_param_onSave, nvFW.pageContents.filtro_histotico_sol, true)
        }

        function zoomVerParam_onclick() {
            var html = ' <div id="solParamsZoom" style="overflow-y: auto;"></div>'

            win_zoom = createWindow({
                title: '<b>Par�metros</b>',
                width: 800,
                height: 500,
                minimizable: false,
                maximizable: true,
                draggable: true,
                resizable: true,
                closable: true,
                onClose: function () {
                    if (win_zoom.options.userData.hayModificacion) {
                        _divParams = "solParams"
                        mostrarParametros(_divParams)
                    }
                }
            });

            win_zoom.options.userData = { hayModificacion: false }
            win_zoom.setHTMLContent(html)
            win_zoom.showCenter(true)

            _divParams = "solParamsZoom"
            mostrarParametros(_divParams)
        }

        function propiedadesAvanzado() {
            if (!nvFW.tienePermiso('permisos_solicitudes', 6)) {
                alert("No posee permisos para realizar esta acci�n.")
                return;
            }

            var win = window.nvFW.createWindow({
                url: "solicitud_propiedades.aspx?sol_estado=" + solicitud.sol_estado.valor + "&nro_sol_tipo=" + solicitud.nro_sol_tipo.valor,
                width: "400", height: "300", top: "50",
                title: "<b>Propiedades avanzadas</b>",
                maximizable: false,
                minimizable: false,
                resizable: false,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {
                        CambiarEstado(win.options.userData.nuevo_estado, win.options.userData.fecha_estado)
                        
                    }
                }
            })
            win.showCenter(true)
        }

        function ejecutarProceso() {
            var win = window.nvFW.createWindow({
                url: "solicitud_proceso_ejecutar.aspx?nro_sol=" + nvFW.pageContents.nro_sol + "&nro_sol_tipo=" + solicitud.nro_sol_tipo.valor,
                width: "500", height: "180", top: "50",
                title: "<b>Procesos</b>",
                maximizable: false,
                minimizable: false,
                resizable: false,
                onClose: function (win) {
                    if (win.options.userData.hay_modificacion) {
                        window_onload();
                    }
                }
            })
            win.showCenter(true)
        }

        function imprimirSolicitud() {

            //if (!solicitud.sol_estado || solicitud.sol_estado.valor != 'T') {
            //    alert("La solicitud debe estar terminada.")
            //    return;
            //}

            //if (!solicitud_params.IBS_nro_operacion || !solicitud_params.IBS_nro_operacion.valor || nvFW.isNaN(solicitud_params.IBS_nro_operacion.valor)){
            //    alert("El n�mero de operaci�n no est� definido.")
            //    return;
            //}

            
            var fe_campo = ''
            var importe_campo = ''
            var riesgo_nivel = ''

            if (typeof solicitud_params.IBS_nro_operacion != 'undefined' && solicitud_params.IBS_nro_operacion.valor != '' && !nvFW.isNaN(solicitud_params.IBS_nro_operacion.valor)) {
                var fRs = new tRS();
                fRs.open(nvFW.pageContents.filtroVOII_PF, "", "<openro type='igual'>" + solicitud_params.IBS_nro_operacion.valor + "</openro>");
                if (!fRs.eof()) {
                    var fe_campo = fRs.getdata("fecori")
                    var importe_campo = fRs.getdata("importpact")
                }
            }

            if (solicitud_params.riesgo_nivel !== undefined)
                riesgo_nivel = solicitud_params.riesgo_nivel.valor 

            var reportOptions = {
                filtroXML: nvFW.pageContents.filtroSolicitudRPT
                , filtroWhere: "<criterio><select><filtro></filtro></select></criterio>"
                , params: '<criterio><params fe_campo="' + fe_campo + '" importe_campo="' + importe_campo + '" riesgo_nivel="' + riesgo_nivel + '" /></criterio>'
                , path_reporte: "report/Formularios/ModSolicitud/analisis_sol_pfijo_web.rpt"
                , salida_tipo: "adjunto"
                //, ContentType: "application/pdf"
                , filename: "Solicitudes " + nvFW.pageContents.nro_sol + ".pdf"
                , formTarget: "_blank"
            }
            
            nvFW.mostrarReporte(reportOptions)

            
        }


        function cargar_NOSIS() {

            nvFW.bloqueo_activar($$('BODY')[0], 1234, "Adjuntando informe Nosis")
            sac_html_guardar(function (url, propiedades) {
                try {

                    nvFW.bloqueo_desactivar($$('BODY')[0], 1234, "El informe Nosis se adjunto exitosamente")
                    if (url == "return")
                        return

                    if (url == "") {
                        reintentos = propiedades.reintentos
                        consultando = false;
                        cargar_NOSIS();
                        return
                    }

                    // window.open(url, '_blank')

                    //Recargar iframe legajos
                    $('frame_archivo').contentWindow.cargarHistorial()

                    if (propiedades.novedad != "")
                        window.top.alert(propiedades.novedad)

                } catch (e) {
                    window.top.alert('No se pudo generar el archivo. Consulte al administrador del sistema.')
                }
            }, {
                    CDA: nvFW.pageContents.cda,
                    nro_vendedor: 0,
                    nro_banco: 0,
                    id_tipo: nvFW.pageContents.nro_sol,
                    nro_archivo_id_tipo: 1,//nro_archivo_id_tipo,
                    cuit: solicitud.cuil.valor,
                    nro_docu: solicitud.cuil.valor.substr(2, 8),
                    razonsocial: solicitud.nombre.valor + " " + solicitud.apellido.valor,
                    sexo: solicitud.sexo.valor,
                    nro_def_archivo: _nro_def_archivo
                }, function (err) {
                    nvFW.bloqueo_desactivar($$('BODY')[0], 1234, "El informe Nosis se adjunto exitosamente")
                    alert(err.mensaje)
                })

        }

        function mostrar_parametros() {

            if ($('solParams').style.display == 'none') {
                verDivParametros = true;
                $('solParams').show();
                $('imgMenosParametros').src = '/fw/image/icons/menos.gif'
            } else {
                $('solParams').hide();
                verDivParametros = false;
                $('imgMenosParametros').src = '/fw/image/icons/mas.gif'
            }

            resize_closeable_divs();
        }

        function mostrar_archivos() {

            if ($('frame_archivo').style.display == 'none') {
                verDivArchivos = true;
                $('frame_archivo').show();
                $('imgMasArchivos').src = '/fw/image/icons/menos.gif'
            } else {
                $('frame_archivo').hide();
                verDivArchivos = false;
                $('imgMasArchivos').src = '/fw/image/icons/mas.gif'

            }

            resize_closeable_divs();
        }

    </script>
</head>
<body id="bsolicitud" onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'bloq_datos', 'Cargando informaci�n de solicitud...')</script>

    <div id="result_vacio" style="width: 100%; text-align: center; font: 13px Tahoma, Arial, sans-serif; height: 100px; position: absolute; top: 50%; left: 50%; margin-top: -50px; margin-left: -50%;display: none">
        <h3>Se ha completado la b�squeda</h3>
        <p style="color: #AAA;">No se encontr� la solicitud</p>
    </div>
    <div id="solContainerDiv">
        <div id="solCliente">
            <div id="DIV_MenuCliente" style="WIDTH: 100%; height:auto"></div>
            <input type="hidden" id="cuil" name="cuil" />
            <div class="adaptive">
                <table class="tb1">
                    <tr class="tbLabel">
                        <td >Estado</td>
                        <td style="width:100px" id="cuilLabel" colspan="2">CUIL</td>
                        <td>Nombre</td>
                        <td>Apellido</td>
                        <td style="width:40px">Sexo</td>
                    </tr>
                    <tr>
                        <td id="tdCliente" class="Tit4"></td>
                        <td id="tdVerCliente" width="20px">
                            <%--<img id="verClienteSelf" title="Ver Cliente" height="16px" alt="Ver" src="/FW/image/icons/ver.png" style="cursor:pointer">--%>
                        </td>
                        <td id="tdCuil" class="Tit4"></td>
                        <td id="nombre" class="Tit4">&nbsp;</td>
                        <td id="apellido" class="Tit4">&nbsp;</td>
                        <td id="sexo" class="Tit4"></td>
                    </tr>
                </table>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td>Nacionalidad</td>
                        <td style="width:90px">Estado Civil</td>
                        <td style="width:155px">Expuesto Pol�ticamente</td>
                        <td style="width:110px">Sujeto Obligado</td>
                    </tr>
                    <tr>
                        <td id="nacionalidad" class="Tit4">&nbsp;</td>
                        <td id="estado_civil" class="Tit4"></td>
                        <td id="pep" class="Tit4"></td>
                        <td id="so" class="Tit4"></td>
                    </tr>
                </table>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td>Condici�n Laboral</td>
                        <td>Actividad</td>
                    </tr>
                    <tr>
                        <td id="condicion_laboral" class="Tit4">&nbsp;</td>
                        <td id="actividad" class="Tit4">&nbsp;</td>
                    </tr>
                </table>
            </div>
            <div class="adaptive">
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width:140px" nowrap>Fecha de Nacimiento</td>
                        <td style="width:50px">Edad</td>
                        <td>Email</td>
                        <td>Tel�fono</td>
                    </tr>
                    <tr>
                        <td id="fe_naci" class="Tit4">&nbsp;</td>
                        <td id="edadCliente" class="Tit4"></td>
                        <td id="email" class="Tit4">&nbsp;</td>
                        <td id="telCliente" class="Tit4">&nbsp;</td>
                    </tr>
                </table>
                <table class="tb1">
                <tr class="tbLabel">
                    <td style="width:50%">Domicilio</td>
                </tr>
                <tr>
                    <td id="domCliente" class="Tit4">&nbsp;</td>
                </tr>
        
            </table>
            <table class="tb1">
                <tr class="tbLabel">
                    <td style="width:8%">CP</td>
                    <td style="width:14%">Localidad</td>
                    <td style="width:14%">Provincia</td>
                    <td style="width:14%">Pa�s</td>
                </tr>
                <tr>
                    <td id="com_cod_postal" class="Tit4">&nbsp;</td>
                    <td id="dom_localidad" class="Tit4">&nbsp;</td>
                    <td id="dom_provincia" class="Tit4">&nbsp;</td>
                    <td id="dom_pais" class="Tit4">&nbsp;</td>
                </tr>
        
            </table>
            </div>
            <div style="clear:both"></div>
        </div>
        <div id="solCol" class="adaptive" >
            <div id="solDatos">
                <div id="solDatosCont" style="width: 100%;">
                <div id="DIV_MenuSolicitud" style="WIDTH: 100%;"></div>
                <table class="tb1" style="width: 100%;">
                    <tr>
                        <td class="Tit2" style="width: 90px">N�mero:</td>
                        <td id="nro_sol" class="Tit4"></td>
                        <td class="Tit2" style="width: 42px">Tipo:</td>
                        <td id="sol_tipo" class="Tit4"></td>
                        <td class="Tit2" style="width: 81px">Fecha Alta:</td>
                        <td id="fe_alta" class="Tit4"></td>
                    </tr>
                    <tr>
                        <td class="Tit2" style="width: 90px">Descripci�n:</td>
                        <td id="sol_desc" class="Tit4" colspan="5"></td>
                    </tr>
                </table>
                <table class="tb1" style="width: 100%;">
                    <tr>
                        <td class="Tit2" style="width: 90px">Estado:</td>
                        <td id="sol_estado_desc" class="Tit4"></td>
                        <td class="Tit2" style="width: 102px">Fecha Estado:</td>
                        <td id="fe_estado" class="Tit4"></td>
                    </tr>
                </table>
                <table class="tb1" style="width: 100%;">
                    <tr>
                        <td class="Tit2" style="width: 90px">Monto:</td>
                        <td id="monto" class="Tit4"></td>
                        <td class="Tit2" style="width: 48px">Plazo:</td>
                        <td id="plazo" class="Tit4"></td>
                    </tr>
                </table>
                </div>
                 <div id="solEstados" style="width: 100%;">
                <div id="DIV_MenuEstado" style="WIDTH: 100%;"></div>
                <table class="tb1">   
                    <tbody id="cambioEstados"></tbody>
                </table>
                </div>
                <%--<div id="paramsDiv" class="mnuCELL_Normal_P">&nbsp;Par�metros&nbsp;</div>--%>
                <div id="DIV_MenuParametro" style="width: 100%;"></div>
                <div id="solParams" style="height: 100px; overflow-y: auto;">
                    <%--<table class="tb1" style="width: 100%;">
                        <tbody id="tablaParams"></tbody>
                    </table>--%>
                </div>              
                <div id="DIV_MenuArchivo" style="WIDTH: 100%"></div>
                <script type="text/javascript">
                    var vMenuSolicitud = new tMenu('DIV_MenuSolicitud', 'vMenuSolicitud');
                    Menus["vMenuSolicitud"] = vMenuSolicitud
                    Menus["vMenuSolicitud"].alineacion = 'centro'
                    Menus["vMenuSolicitud"].estilo = 'A'
                    Menus["vMenuSolicitud"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Solicitud</Desc></MenuItem>")
                    Menus["vMenuSolicitud"].MostrarMenu();

                    var vMenuParametro = new tMenu('DIV_MenuParametro', 'vMenuParametro');
                    Menus["vMenuParametro"] = vMenuParametro
                    Menus["vMenuParametro"].alineacion = 'centro'
                    Menus["vMenuParametro"].estilo = 'A'
                    Menus["vMenuParametro"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Par�metros</Desc></MenuItem>")

                    vMenuParametro.loadImage("zoom", "/FW/image/icons/ver.png");
                    Menus["vMenuParametro"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>zoom</icono><Desc>Zoom</Desc><Acciones><Ejecutar Tipo='script'><Codigo>zoomVerParam_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")

                    vMenuParametro.loadImage("editar", "/FW/image/icons/editar.png");
                    Menus["vMenuParametro"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Opciones Avanzadas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>advanceEditParam_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                    Menus["vMenuParametro"].MostrarMenu();

                    var vMenuEstado = new tMenu('DIV_MenuEstado', 'vMenuEstado');
                    Menus["vMenuEstado"] = vMenuEstado
                    Menus["vMenuEstado"].alineacion = 'centro'
                    Menus["vMenuEstado"].estilo = 'A'
                    Menus["vMenuEstado"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Cambio de Estado</Desc></MenuItem>")
                    Menus["vMenuEstado"].MostrarMenu();

                    var vMenuArchivo = new tMenu('DIV_MenuArchivo', 'vMenuArchivo');
                    vMenuArchivo.loadImage("nosis", "/FW/image/icons/nosis.png");
                    Menus["vMenuArchivo"] = vMenuArchivo
                    Menus["vMenuArchivo"].alineacion = 'centro'
                    Menus["vMenuArchivo"].estilo = 'A'
                    Menus["vMenuArchivo"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Archivos</Desc></MenuItem>")
                    Menus["vMenuArchivo"].MostrarMenu();

                    $('menuItem_DIV_MenuParametro_0').innerHTML = '<span style="float: left"><img src = "/fw/image/mnusvr/menos.gif" border="0" align="absmiddle" hspace="1" id = "imgMenosParametros" onclick = "mostrar_parametros()" ></span >&nbsp;' + $('menuItem_DIV_MenuParametro_0').innerHTML
                    $('menuItem_DIV_MenuArchivo_0').innerHTML = '<span style="float: left"><img src = "/fw/image/mnusvr/menos.gif" border="0" align="absmiddle" hspace="1" id = "imgMasArchivos" onclick = "mostrar_archivos()" ></span >&nbsp;' + $('menuItem_DIV_MenuArchivo_0').innerHTML
                </script>
            </div>
            <iframe id="frame_archivo" name="frame_archivo" src="/FW/enBlanco.htm" style="width: 100%; overflow: auto; border: none;"></iframe>
        </div>
        <div id="solComentarios" class="adaptive" style="background-color:white">
        
            <div id="DIV_MenuComentario" style="WIDTH: 100%;"></div>

            <iframe id="frame_comentario" name="frame_comentario" src="/FW/enBlanco.htm" style="width: 100%; height: 100%; overflow: hidden; border: none;"></iframe>

                <script type="text/javascript">
                var vMenuComentario = new tMenu('DIV_MenuComentario', 'vMenuComentario');
                Menus["vMenuComentario"] = vMenuComentario
                Menus["vMenuComentario"].alineacion = 'centro'
                Menus["vMenuComentario"].estilo = 'A'
                Menus["vMenuComentario"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Comentarios</Desc></MenuItem>")
                Menus["vMenuComentario"].MostrarMenu();
            </script>
        </div>
        <div style="clear:both"></div>

    </div>
</body>
</html>