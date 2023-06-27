<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "C")         '//Modos --->    'C': Consulta - MC:Modif.Cabecera - AC:Alta Cabecera
    Dim op = nvFW.nvApp.getInstance.operador

    'Maps
    Dim GOOGLE_MAPS_API_KEY_BROWSER As String = nvUtiles.getParametroValor("GOOGLE_MAPS_API_KEY_BROWSER", "")
	 
    'Maps
    Dim ErrPermiso As New nvFW.tError()
    If Not op.tienePermiso("permisos_entidades", 1) Then
        ErrPermiso.numError = -1
        ErrPermiso.mensaje = "No posee permisos para realizar esta acción. Consulte con el Administrador del Sistema."
        ErrPermiso.response()
    End If

    If modo.ToUpper() = "M" Then

        Dim strXML As String = HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""), System.Text.Encoding.Default)
        Dim Err As New nvFW.tError()
        Err.numError = 1
        Err.mensaje = "Error al executar el procedimiento almacenado [nv_entidad_abm]"

        Try
            ' Ejecutar el procedimiento
            '**** Alta/Modificacion Entidad ****
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("nv_entidad_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            If Not rs.EOF Then

                nro_entidad = rs.Fields("nro_entidad").Value
                Err.numError = rs.Fields("numError").Value
                Err.titulo = rs.Fields("titulo").Value
                Err.mensaje = rs.Fields("mensaje").Value
                Err.params.Add("nro_entidad", nro_entidad)


                '**** Actualizar Contactos ****//
                Dim contactos_xml As String = nvFW.nvUtiles.obtenerValor("contactos_xml", "")
                If ((contactos_xml <> "") And (Not contactos_xml Is Nothing) And (rs.Fields("numError").Value = 0)) Then


                    If (op.tienePermiso("permisos_contactos", 1)) Then

                        Dim cmd1 As New nvFW.nvDBUtiles.tnvDBCommand("rm_contacto_abm", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)

                        Dim BinaryData() As Byte
                        BinaryData = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(contactos_xml)

                        cmd1.Parameters.Append(cmd1.CreateParameter("@strXML0", 205, 1, BinaryData.Length, BinaryData))
                        cmd1.Parameters.Append(cmd1.CreateParameter("@nro_entidad", 3, 1, 1, nro_entidad))

                        Dim rs1 As ADODB.Recordset = cmd1.Execute()

                        Err.numError = rs1.Fields("numError").Value
                        Err.titulo = rs1.Fields("titulo").Value
                        Err.mensaje = rs1.Fields("mensaje").Value


                    End If

                End If


                '**** INSERT en DBANEXA ****
                If (rs.Fields("numError").Value = 0) Then

                    nvServer.Events.RaiseEvent("entidad_onSave", convert.ToInt32(nro_entidad), strXML)

                End If

            End If
        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar Entidad"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "entidad_abm.aspx"
        End Try

        Err.response()
    End If


    Me.contents("nro_entidad") = nro_entidad
    Me.contents("nro_operador") = op.operador

    'Consulta de entidades para vínculos
    Me.contents("entidad_consultar") = nvFW.nvUtiles.obtenerValor("entidad_consultar", "")

    Me.contents("filtroXMLEntidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>nro_entidad,'' as rol_desc,razon_social,abreviacion,calle,postal,postal_real,localidad,telefono,email,cuitcuil,cuit,car_tel,nro_docu,tipo_docu,sexo,apellido,nombres,alias,persona_fisica,numero,depto,piso,fecha_nacimiento,fecha_inscripcion,cod_est_civil,desc_est_civil,nro_nacion,pep,nro_emp_tipo,nro_soc_tipo,nro_contacto_tipo,cod_ing_brutos,cod_sit_iva,nro_docu_c,tipo_docu_c,documento,postal_telefono,provincia,resto,dni</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroEntidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroVerEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>cuit</campos><orden>cuit</orden><filtro></filtro></select></criterio>")

    Me.contents("filtroContactoTipo") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_tipo'><campos>distinct nro_contacto_tipo as id, desc_contacto_tipo as [campo]</campos><orden>[id]</orden><filtro><nro_contacto_tipo type='in'>1,2,3,8</nro_contacto_tipo></filtro></select></criterio>")

    Me.contents("filtroDomicilio") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_domicilio'><campos>id_domicilio</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroContactoTelefono") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_telefono'><campos>id_telefono</campos><orden></orden><filtro><predeterminado type='igual'>1</predeterminado></filtro></select></criterio>")
    Me.contents("filtroContactoTelefono2") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_telefono'><campos>id_telefono</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroContactoEmail") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_email'><campos>id_email</campos><orden></orden><filtro><predeterminado type='igual'>1</predeterminado></filtro></select></criterio>")
    Me.contents("filtroContactoEmail2") = nvXMLSQL.encXMLSQL("<criterio><select vista='Contacto_email'><campos>id_email</campos><orden></orden><filtro></filtro></select></criterio>")

    Me.contents("filtroBuscarLocalidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verlocalidad'><campos>postal, postal_real, car_tel, UPPER(localidad)</campos><orden></orden><filtro></filtro></select></criterio>")


    Me.contents("filtro_tipoDocPF") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='documento'><campos>DISTINCT tipo_docu AS id, documento AS [campo]</campos><orden>[campo]</orden><filtro><tipo_docu type='in'>'3','5','6','8'</tipo_docu></filtro></select></criterio>")
    Me.contents("filtro_tipoDocPJ") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='documento'><campos>DISTINCT tipo_docu AS id, documento AS [campo]</campos><orden>[campo]</orden><filtro><tipo_docu type='in'>'8','9'</tipo_docu></filtro></select></criterio>")

    Me.contents("filtro_ent_estado_civil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_estado_civil'><campos>cod_est_civil as id, desc_est_civil as [campo], vigente as allowSelection</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")

    Me.addPermisoGrupo("permisos_entidades")
    Me.addPermisoGrupo("permisos_contactos")
    Me.addPermisoGrupo("permisos_vinculos")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Entidad ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <%-- Google Maps API --%>
    <% 
	if GOOGLE_MAPS_API_KEY_BROWSER <> "" then Response.Write("<script type=""text/javascript"" src=""https://maps.googleapis.com/maps/api/js?key=" & GOOGLE_MAPS_API_KEY_BROWSER & "&libraries=places&region=AR""></script>") 
	%>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var vButtonItems = []
        vButtonItems[0] = []
        vButtonItems[0]["nombre"] = "LocalidadSel";
        vButtonItems[0]["etiqueta"] = "...";
        vButtonItems[0]["imagen"] = "";
        vButtonItems[0]["onclick"] = "return selLocalidad()";

        vButtonItems[1] = []
        vButtonItems[1]["nombre"] = "CaracteristicaSel";
        vButtonItems[1]["etiqueta"] = ".";
        vButtonItems[1]["imagen"] = "";
        vButtonItems[1]["onclick"] = "return selLocalidad_telefono()";

        var flagValidarCuit = false;

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        var win
        var nro_rol = nvFW.pageContents.nro_rol;
        var rol_desc
        var nro_entidad = nvFW.pageContents.nro_entidad;
        //var permisos_entidades      = nvFW.pageContents.permisos_entidades;
        var roles = []
        var permiso = ''
        var nro_dist_tipo = ''

        // Variables de elementos a cachear
        var $body
        var $nro_entidad
        var $razon_social
        var $abreviacion
        var $alias
        var $calle
        var $localidad
        var $car_tel
        var $telefono
        var $email
        var $cuit
        var $cuitcuil
        var $apellido
        var $nombres
        var $nro_docu
        var $frame_comentarios
        var $divMenuABMEntidades
        var $divDatosPersonales
        var $divComentarioParametros
        var $tbComentarioParametros
        var $datos_pjuridica
        var $datos_pfisica
        var $sexo
        var $persona_fisica
        var $modo
        var $postal

        var $fecha_nacimiento
        var $tipo_docu_pf
        var $tipo_docu_pj
        var $nro_nacion
        var $pep
        var $fecha_inscripcion
        var $estado_civil

        var $nro_emp_tipo
        var $nro_soc_tipo

        var $cod_sit_iva
        var $cod_ing_brutos

        var $numero
        var $piso
        var $depto
        var $resto
        var $nro_contacto_tipo
        var $tdnro_entidad
        var $td_inputnro_entidad
        var $inputnro_entidad

        var postal_telefono = ''

        var winEntidad = nvFW.getMyWindow()


        function window_onload() {
            //Maps
            //nvFW.enterToTab = false;

            vListButton.MostrarListButton()
            cachearElementos()
            $nro_entidad.value = nro_entidad;

            var ventana_actual = window.top.Windows.getFocusedWindow()
            ventana_actual.options.userData = {
                modificacion: false,
                recargar: false
            }

            if ($nro_entidad.value != '') {
                CargarDatos($nro_entidad.value);
                $modo.value = 'M'
            }
            else {
                entidad_nueva();
                $modo.value = 'A'
            }

            //Bloquea la seleccion de conyuge
            cbEstado_civil_onchange()

            //Maps
			if(window.google)
              inicializarMaps();


            window_onresize();
        }


        function cachearElementos() {
            $body = $$('BODY')[0]
            $nro_entidad = $('nro_entidad')
            $razon_social = $('razon_social')
            $abreviacion = $('abreviacion')
            $alias = $('alias')
            $calle = $('calle')
            $localidad = $('localidad')
            $car_tel = $('car_tel')
            $telefono = $('telefono')
            $email = $('email')
            $cuit = $('cuit')
            $cuitcuil = $('cuitcuil')
            $apellido = $('apellido')
            $nombres = $('nombres')
            $nro_docu = $('nro_docu')
            $frame_comentarios = $('frame_comentarios')
            $divMenuABMEntidades = $('divMenuABMEntidades')
            $divDatosPersonales = $('divDatosPersonales')
            $divComentarioParametros = $('divComentarioParametros')
            $tbComentarioParametros = $('tbComentarioParametros')
            $datos_pjuridica = $('datos_pjuridica')
            $datos_pfisica = $('datos_pfisica')
            $persona_fisica = $('persona_fisica')
            $modo = $('modo')
            $postal = $('postal')
            $sexo = $('sexo')


            $fecha_nacimiento = $('fecha_nacimiento')
            $tipo_docu_pf = $('tipo_docu_pf')
            $tipo_docu_pj = $('tipo_docu_pj')
            $nro_nacion = $('nro_nacion')
            $pep = $('pep')
            $fecha_inscripcion = $('fecha_inscripcion')
            $estado_civil = $('cod_est_civil')

            $nro_emp_tipo = $('nro_emp_tipo')
            $nro_soc_tipo = $('nro_soc_tipo')

            $cod_sit_iva = $('cod_sit_iva')
            $cod_ing_brutos = $('cod_ing_brutos')

            $numero = $('numero')
            $piso = $('piso')
            $depto = $('depto')
            $resto = $('resto')
            $nro_contacto_tipo = $('nro_contacto_tipo')

            $tdnro_entidad = $('tdnro_entidad')
            $td_inputnro_entidad = $('td_inputnro_entidad')
            $inputnro_entidad = $('inputnro_entidad')
        }

        var topEntidad = 0;
        function window_onresize() {
            try {
                //si la ventana no tiene tamaño suficiente para mostrar toda la informacion (contactos,comentarios)
                if ((mostrarMenuContactos || mostrarMenuComentarios || mostrarMenuVinculos) && (winEntidad.height < 600)) {
                    winEntidad.setSize(winEntidad.width, 600);
                    winEntidad.showCenter();
                }
                //setear tamaño restante al iframe
                var body_h = $body.getHeight();
                var divMenuABMEntidades_h = $divMenuABMEntidades.getHeight();
                var divDatosPersonales_h = $divDatosPersonales.getHeight();
                var divComentarioParametros_h = body_h - divMenuABMEntidades_h - divDatosPersonales_h

                $divComentarioParametros.style.height = divComentarioParametros_h + 'px'
                $tbComentarioParametros.style.height = divComentarioParametros_h + 'px'

            }
            catch (e) { }
        }


        function entidad_nueva() {
            $nro_entidad.value = ''
            $razon_social.value = ''
            $abreviacion.value = ''
            $alias.value = ''
            $calle.value = ''
            $localidad.value = ''
            $car_tel.value = ''
            $telefono.value = ''
            $email.value = ''
            $cuit.value = ''
            $cuitcuil.value = 'CUIL'
            $apellido.value = ''
            $nombres.value = ''
            $nro_docu.value = ''
            campos_defs.clear('tipo_docu_pf')
            campos_defs.clear('tipo_docu_pj')
            campos_defs.set_value('nro_contacto_tipo', 1)
            decidir_tabla('1'); // Cargamos Persona Física por Defecto
            $frame_comentarios.src = "/FW/enBlanco.htm";
        }


        function decidir_tabla(opcion) {

            switch (opcion) {
                // Si es persona Jurídica
                case "0":
                    $datos_pjuridica.show()
                    $datos_pfisica.hide()
                    $('datos_pfisica2').hide()
                    $('datos_pjuridica2').show()
                    $('tdtipo_docu_pf').hide()
                    $('tdtipo_docu_pj').show()
                    $('td_dni_input').hide();
                    $('td_dni').hide();
                    $cuitcuil.value = 'CUIT';
                    $cuitcuil.disabled = true;
                    //desbloqueo/bloqueo cuit si cambio de tipo de persona y seleccione tipo de documento cuit o cuil previamente
                    if ($('tipo_docu_pj').value != '8') {
                        $cuit.disabled = false;
                    } else {
                        $cuit.disabled = true;
                    }
                    break;

                // Si es persona Física
                case "1":
                    $datos_pjuridica.hide()
                    $datos_pfisica.show()
                    $('datos_pfisica2').show()
                    $('datos_pjuridica2').hide()
                    $('tdtipo_docu_pf').show()
                    $('tdtipo_docu_pj').hide()
                    $('td_dni_input').show();
                    $('td_dni').show();
                    $cuitcuil.value = 'CUIL';
                    //desbloqueo/bloqueo cuit si cambio de tipo de persona y seleccione tipo de documento cuit o cuil previamente
                    if ($('tipo_docu_pf').value != '8' && $('tipo_docu_pf').value != '6') {
                        $cuit.disabled = false;
                        $cuitcuil.disabled = false;
                    } else {
                        $cuit.disabled = true;
                        $cuitcuil.disabled = true;
                        if ($('tipo_docu_pf').value == '8')
                            $cuitcuil.value = 'CUIT';
                    }
                    break;

                default:
                    $datos_pjuridica.hide();
                    $('datos_pjuridica2').hide()
                    $datos_pfisica.show();
                    $('datos_pfisica2').show()
                    $('tdtipo_docu_pf').show()
                    $('tdtipo_docu_pj').hide()
                    $('td_dni_input').show();
                    $('td_dni').show();
                    $cuitcuil.value = 'CUIL';
                    //desbloqueo/bloqueo cuit si cambio de tipo de persona y seleccione tipo de documento cuit o cuil previamente
                    if ($('tipo_docu_pf').value != '8' && $('tipo_docu_pf').value != '6') {
                        $cuit.disabled = false;
                        $cuitcuil.disabled = false;
                        if ($('tipo_docu_pf').value == '8')
                            $cuitcuil.value = 'CUIT';
                    } else {
                        $cuit.disabled = true;
                        $cuitcuil.disabled = true;
                    }
                    break;
            }
        }


        function CargarDatos(nro_entidad) {
            var rs = new tRS();
            rs.async = true
            rs.onComplete = function (rs) {
                if (!rs.eof()) {

                    //Muestro el numero de entidad en edicion
                    $tdnro_entidad.show()
                    $td_inputnro_entidad.show();
                    $inputnro_entidad.disabled = true;
                    $inputnro_entidad.value = rs.getdata('nro_entidad');

                    $nro_entidad.value = rs.getdata('nro_entidad')
                    $razon_social.value = !rs.getdata('razon_social') ? "" : rs.getdata('razon_social')
                    $abreviacion.value = !rs.getdata('abreviacion') ? "" : rs.getdata('abreviacion')
                    $calle.value = !rs.getdata('calle') ? "" : rs.getdata('calle')
                    $postal.value = !rs.getdata('postal') ? "" : rs.getdata('postal')
                    postal_telefono = !rs.getdata('postal_telefono') ? "" : rs.getdata('postal_telefono')
                    $telefono.value = !rs.getdata('telefono') ? "" : rs.getdata('telefono')
                    $email.value = !rs.getdata('email') ? "" : rs.getdata('email')
                    $cuit.value = !rs.getdata('cuit') ? "" : rs.getdata('cuit')
                    $cuitcuil.value = !rs.getdata('cuitcuil') ? "" : rs.getdata('cuitcuil')
                    if (rs.getdata('localidad') != null) {
                        $localidad.value = 'CP: ' + rs.getdata('postal_real') + ' - ' + rs.getdata('localidad') + ' - ' + rs.getdata('provincia')
                    } else $localidad.value = '';

                    $car_tel.value = rs.getdata('car_tel') ? rs.getdata('car_tel') : "";
                    $alias.value = (rs.getdata('alias') != null) ? rs.getdata('alias') : ''

                    campos_defs.set_value('cod_sit_iva', (rs.getdata('cod_sit_iva') != null) ? rs.getdata('cod_sit_iva') : "")
                    campos_defs.set_value('cod_ing_brutos', (rs.getdata('cod_ing_brutos') != null) ? rs.getdata('cod_ing_brutos') : "")

                    $numero.value = (rs.getdata('numero') != null) ? rs.getdata('numero') : "";
                    $piso.value = (rs.getdata('piso') != null) ? rs.getdata('piso') : "";
                    $depto.value = (rs.getdata('depto') != null) ? rs.getdata('depto') : "";
                    $resto.value = (rs.getdata('resto') != null) ? rs.getdata('resto') : "";
                    campos_defs.set_value('nro_contacto_tipo', (rs.getdata('nro_contacto_tipo') != null) ? rs.getdata('nro_contacto_tipo') : "");


                    var tipo_docu_p = (rs.getdata("tipo_docu") != null) ? rs.getdata("tipo_docu") : ''
                    $nro_docu.value = (rs.getdata('nro_docu') != null) ? rs.getdata('nro_docu') : ''

                    if ((rs.getdata('pep') != null) && (rs.getdata('pep') == 'True'))
                        $pep.checked = true;

                    //carga de datos que no son comunes entre persona fisica y juridica
                    if (rs.getdata("persona_fisica") == "True") {
                        $persona_fisica.value = "1"
                        $apellido.value = rs.getdata('apellido')
                        $nombres.value = rs.getdata('nombres')
                        $sexo.value = (rs.getdata('sexo') != null) ? rs.getdata('sexo') : ''

                        campos_defs.set_value("tipo_docu_pf", tipo_docu_p)
                        $('dni').value = (rs.getdata('dni') != null) ? rs.getdata('dni') : ''

                        $fecha_nacimiento.value = (rs.getdata('fecha_nacimiento') != null) ? FechaToSTR(parseFecha(rs.getdata('fecha_nacimiento'))) : "";
                        campos_defs.set_value('nro_nacion', (rs.getdata('nro_nacion') != null) ? rs.getdata('nro_nacion') : "")
                        var estadocivilRs = (rs.getdata('cod_est_civil') != null) ? rs.getdata('cod_est_civil') : "";
                        campos_defs.set_value('cod_est_civil',estadocivilRs.substring(0, 1));

                        $('nro_docu_c').value = (rs.getdata('nro_docu_c') != null) ? rs.getdata('nro_docu_c') : "";
                        $('tipo_docu_c').value = (rs.getdata('tipo_docu_c') != null) ? rs.getdata('tipo_docu_c') : "";
                        cargarDatosConyuge();
                        cbEstado_civil_onchange();

                        decidir_tabla('1')
                    }
                    else {
                        $persona_fisica.value = "0"

                        campos_defs.set_value("tipo_docu_pj", tipo_docu_p)
                        $fecha_inscripcion.value = (rs.getdata('fecha_inscripcion') != null) ? FechaToSTR(parseFecha(rs.getdata('fecha_inscripcion'))) : "";
                        campos_defs.set_value('nro_emp_tipo', (rs.getdata('nro_emp_tipo') != null) ? rs.getdata('nro_emp_tipo') : "");
                        campos_defs.set_value('nro_soc_tipo', (rs.getdata('nro_soc_tipo') != null) ? rs.getdata('nro_soc_tipo') : "");

                        decidir_tabla('0')
                    }


                    if (!nvFW.tienePermiso("permisos_entidades", 3)) {
                        $persona_fisica.disabled = true;
                        $tipo_docu_pf.disabled = true;
                        $tipo_docu_pj.disabled = true;
                        $nro_docu.disabled = true;
                    }

                    //Carga de datos de contacto para comparar si hay cambios
                    $('calle_ant').value = $calle.value;
                    $('numero_ant').value = $numero.value;
                    $('piso_ant').value = $piso.value;
                    $('depto_ant').value = $depto.value;
                    $('resto_ant').value = $resto.value;
                    $('postal_ant').value = $postal.value;
                    $('telefono_ant').value = $telefono.value;
                    $('postal_telefono_ant').value = postal_telefono
                    $('email_ant').value = $email.value;
                    $('nro_contacto_tipo_ant').value = $nro_contacto_tipo.value



                }

                VerComentarios()

                //No tiene permiso para editar datos de la Entidad
                //permisos_entidades = 99;

                if (!nvFW.tienePermiso("permisos_entidades", 1)) {
                    $cuit.disabled = true
                    $cuitcuil.disabled = true
                    $persona_fisica.disabled = true
                    $apellido.disabled = true
                    $nombres.disabled = true
                    $razon_social.disabled = true
                    $sexo.disabled = true
                    campos_defs.habilitar('tipo_docu_pf', false)
                    campos_defs.habilitar('tipo_docu_pj', false)
                    $nro_docu.disabled = true
                    $abreviacion.disabled = true
                    $alias.disabled = true
                    $calle.disabled = true
                    $numero.disabled = true
                    $piso.disabled = true
                    $depto.disabled = true
                    $cod_ing_brutos.disabled = true
                    $cod_sit_iva.disabled = true
                    $estado_civil.disabled = true
                    $nro_contacto_tipo.disabled = true
                    $nro_nacion.disabled = true
                    $pep.disabled = true
                    $fecha_nacimiento.disabled = true
                    $fecha_inscripcion.disabled = true
                    $localidad.disabled = true
                    $('divLocalidadSel').hide()
                    $car_tel.disabled = true
                    $telefono.disabled = true
                    $email.disabled = true
                }
            }

            rs.onError = function (rs) {
                alert(rs.lastError.numError + ' - ' + rs.lastError.mensaje)
            }

            rs.open(nvFW.pageContents.filtroXMLEntidad, "", "<criterio><select><orden></orden><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro></select></criterio>", "", "")
        }

        var mostrarMenuComentarios = false;
        function VerComentarios() {
            ObtenerVentana('frame_comentarios').location.href = '/fw/comentario/verCom_registro.aspx?nro_entidad=' + $nro_entidad.value +
                '&nro_com_id_tipo=1&collapsed_fck=1&do_zoom=0' +
                '&id_tipo=' + $nro_entidad.value + '&nro_com_grupo=1'
            mostrarMenuComentarios = true;

            mostrarMenuVinculos = false;
            //se oculta el menu contactos
            btnMostrarMenuContactos_onclick(false);
        }

        //////////////
        var mostrarMenuVinculos = false;
        function VerVinculos() {

            var url = '/fw/entidades/vinculos/ent_vinculos_listar.aspx?nro_entidad=' + $nro_entidad.value
            if (nvFW.pageContents.entidad_consultar != '')
                url += '&entidad_consultar=' + nvFW.pageContents.entidad_consultar

            ObtenerVentana('frame_comentarios').location.href = url
            mostrarMenuVinculos = true;

            mostrarMenuComentarios = false;
            //se oculta el menu contactos
            btnMostrarMenuContactos_onclick(false);
        }


        //////////////



        function Cerrar_Ventanas() {
            window.top.Windows.getFocusedWindow().close()
        }


        function ver(alertError) {
            alertError.close()
            winActualizar.close()
        }


        function window_onunload() {
            var a = []
            a["razon_social"] = $razon_social.value
            a["modo"] = $modo.value
            window.parent.returnValue = a
        }


        var res = []

        // Seleccionar la Localidad (setea caracteristica de telefono)
        function selLocalidad() {
            win = nvFW.createWindow({
                url: '/fw/funciones/localidad_consultar.aspx',
                title: '<b>Seleccionar Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                width: 500, //600
                height: 250, //350
                destroyOnClose: true,
                onClose: selLocalidad_return
            });

            win.options.userData = {}
            win.showCenter(true)
        }

        function selLocalidad_return() {
            if (win.options.userData.res) {
                try {
                    var res = win.options.userData.res
                    $postal.value = res.postal
                    $localidad.value = res.desc + ' - ' + res.provincia;
                    postal_telefono = $postal.value;
                    $car_tel.value = res.car_tel
                }
                catch (e) { }
            }
        }


        //seleccionar caracteristica de telefono
        function selLocalidad_telefono() {
            win = nvFW.createWindow({
                url: '/fw/funciones/localidad_consultar.aspx',
                title: '<b>Seleccionar Localidad</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                width: 500, //600
                height: 250, //350
                destroyOnClose: true,
                onClose: selLocalidad_telefono_return
            });

            win.options.userData = {}
            win.showCenter(true)
        }

        function selLocalidad_telefono_return() {
            if (win.options.userData.res) {
                try {
                    var res = win.options.userData.res
                    $car_tel.value = res.car_tel;
                    postal_telefono = res.postal;
                }
                catch (e) { }
            }
        }

        function isNULL(valor, sinulo) {
            return valor = valor == null ? sinulo : valor
        }

        function isNULL_NaN(valor, sinulo) {
            return valor = valor == 'NaN/NaN/NaN' ? sinulo : valor
        }

        function trim(myString) {
            return myString.replace(/^\s+/g, '').replace(/\s+$/g, '')
        }


        var win_entidad_seleccion

        function validarCUIT() {
            var str = ''
            var accion = ''
            var filtro = ''
            var cuit = trim($cuit.value)
            var msj = ''

            if (flagValidarCuit)
                return;

            flagValidarCuit = true;

            //if (($cuit.value.length > 0) && ($cuit.value.length != 11)) {
            if (!validarFormatoCUIT(cuit)) {
                if (cuit != "")
                    alert('El cuit ingresado puede ser inválido.')
            }
            else {
                var rs = new tRS();
                nro_entidad = $nro_entidad.value
                accion = (($nro_entidad.value != '') && ($nro_entidad.value != '0')) ? 'edicion' : 'alta'
                //verificacion de existencia de entidad con mismo nro de cuit
                rs.open(nvFW.pageContents.filtroEntidades, "", "<criterio><select><filtro><cuit type='like'>" + cuit + "</cuit></filtro></select></criterio>", "", "")

                if (rs.recordcount >= 1) {
                    while (!rs.eof()) {
                        if (nro_entidad != rs.getdata('nro_entidad')) {
                            if (msj == '') {
                                msj = 'Existen las siguientes entidades con el CUIT ingresado:</br>'
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            }
                            else {
                                msj += 'Nro. entidad: "' + rs.getdata('nro_entidad') + '" - Razón social: "' + rs.getdata('Razon_social') + '".</br>'
                            }
                        }
                        rs.movenext()
                    }

                    if ((accion == 'edicion') && (msj != '')) {
                        alert(msj);
                        return
                    }

                    if (accion == 'alta') {
                        //win_entidad_seleccion = new Window({ className: 'alphacube',

                        win_entidad_seleccion = nvFW.createWindow({
                            url: 'entidad_seleccion.aspx?cuit=' + cuit + '&nro_entidad=' + nro_entidad + '&id_ventana=' + winEntidad.getId(),//window.top.win.content.id,
                            title: '<b>Selector de Entidades</b>',
                            minimizable: true,
                            maximizable: false,
                            draggable: false,
                            width: 400,
                            height: 200,
                            resizable: false,
                            onClose: function (win) {
                                recuperar_entidad(); flagValidarCuit = false;
                            },
                            destroyOnClose: true

                        });
                        //win_entidad_seleccion.setURL('rol_seleccion.asp?cuit='+trim($cuit.value) + '&nro_entidad='+nro_entidad + '&id_ventana=' + window.top.win.content.id) 
                        win_entidad_seleccion.showCenter(true)
                    }
                } else { flagValidarCuit = false; }
            }
        }

        function recuperar_entidad() {
            if (nro_entidad != '') {
                CargarDatos(nro_entidad)
            }
        }

        function boton_generar_cuit() {
            var sexo = $sexo.value
            var nro_docu = $nro_docu.value
            var strError = ""

            if ((sexo == "") || (nro_docu == ""))
                strError += 'Para generar el CUIT debe ingresar "Sexo" y "Nro. Documento"</br>';

            if (strError != "") {
                alert(strError)
                return
            } else {
                generarCUIT()
            }
        }

        //function generarCUIT(sexo, nro_docu) {
        function generarCUIT() {
            //sexo "M" = 20
            //sexo "F" = 27
            //30 para otros tipos de entidades

            if ($('dni').value == '')
                return

            var sexo = $sexo.value
            //var nro_docu = $nro_docu.value
            var nro_docu = $('dni').value

            if ((sexo != '') && (nro_docu != '')) {
                var v1
                var str_nro_docu = nro_docu.toString()
                if (sexo.toUpperCase() == "M")
                    v1 = "20"
                else {
                    if (sexo.toUpperCase() == "F")
                        v1 = "27"
                    else
                        v1 = "30"
                }
                while (str_nro_docu.length < 8)
                    str_nro_docu = "0" + str_nro_docu

                var digito = digitoVerificador(v1 + str_nro_docu)

                if (digito == 10) {
                    if (v1 == 20 || v1 == 27 || v1 == 24)
                        v1 = '23'
                    else
                        v1 = '33'
                }
                //el digito verificador debe ser 4 para v1=27. y 9 para v1=22 o 33
                /*No es necesario hacer la llamada recursiva, 
                se puede poner el digito en 9 si el prefijo original era 
                23 o 33 o poner el dijito en 4 si el prefijo era 27*/

                //return v1 + str_nro_docu + digitoVerificador(v1 + str_nro_docu)
                if (trim($cuit.value) == '') {
                    $cuit.value = v1 + str_nro_docu + digitoVerificador(v1 + str_nro_docu)
                    validarCUIT()
                }
            }
        }

        function digitoVerificador(S) {
            var v2 = 0;
            var v3 = 0;
            S = S.toString()
            v2 = (parseInt(S.substr(0, 1)) * 5 + parseInt(S.substr(1, 1)) * 4 + parseInt(S.substr(2, 1)) * 3 + parseInt(S.substr(3, 1)) * 2 + parseInt(S.substr(4, 1)) * 7 + parseInt(S.substr(5, 1)) * 6 + parseInt(S.substr(6, 1)) * 5 + parseInt(S.substr(7, 1)) * 4 + parseInt(S.substr(8, 1)) * 3 + parseInt(S.substr(9, 1)) * 2);
            v2 = v2 - (Math.floor(v2 / 11) * 11)
            v3 = 11 - v2;

            switch (v3) {
                case 11: v3 = 0; break;
            }
            return v3
        }

        function validarFormatoCUIT(strCUIT) {

            // determina si el dígito verificador es correcto
            // Retorna true si es correcto y false si es incorrecto
            var v3
            if (strCUIT.length = 11) {
                v3 = digitoVerificador(parseInt(strCUIT));
                var digito_ok = parseInt(strCUIT.substr(10, 1)) == v3
                var val_ok = (parseInt(strCUIT.substr(0, 2)) == 23 && (v3 == 4 || v3 == 9)) || (parseInt(strCUIT.substr(0, 2)) != 23)
                return digito_ok && val_ok;
            }
            else
                return false
        }


        function entidad_guardar() {
            var strError = "";
            var cuit = trim($cuit.value)
            var cuitcuil = trim($cuitcuil.value)

            // Validar los datos
            //if (cuit == "")
            //    strError += 'No ha cargado el "CUIT"</br>';
            //else {
            if (cuit != "") {
                var rs = new tRS();
                var filtro = ''

                if ($nro_entidad.value != '')
                    filtro = "<nro_entidad type='distinto'>" + $nro_entidad.value + "</nro_entidad>"

                //rs.open("<criterio><select vista='verEntidades'><campos>cuit</campos><filtro><cuit type='igual'>" + cuit + "</cuit>" + filtro + "</filtro></select></criterio>")
                rs.open({
                    filtroXML: nvFW.pageContents.filtroVerEntidades,
                    filtroWhere: "<criterio><select><filtro><cuit type='igual'>" + cuit + "</cuit>" + filtro + "</filtro></select></criterio>"
                })

                if (!rs.eof())
                    strError += 'Ya existe una Entidad con el CUIT ingresado</br>';
            }

            var persona_fisica = $persona_fisica.value == "1"

            if (persona_fisica) {
                if ($apellido.value == "")
                    strError += 'No ha cargado el "Apellido"</br>';
                if ($nombres.value == "")
                    strError += 'No ha cargado el "Nombre"</br>';
                if ($nro_docu.value == "")
                    strError += 'No ha cargado el "Nro.Documento"</br>';
                if ($('tipo_docu_pf').value == "")
                    strError += 'No ha cargado el "Tipo Documento"</br>';
                if ($fecha_nacimiento.value == "")
                    strError += 'No ha cargado la "Fecha de nacimiento"</br>';
            }
            else {
                if ($('tipo_docu_pj').value == "")
                    strError += 'No ha cargado el "Tipo Documento"</br>';
                if ($nro_docu.value == "")
                    strError += 'No ha cargado el "Nro.Documento"</br>';
                if ($razon_social.value == "")
                    strError += 'No ha cargado la "Razón Social"</br>';
            }

            if (strError != "") {
                alert(strError);
                return
            }


            //CONTACTOS
            xmldato_c = ""
            //var email_predeterminado = false

            //if (mostrarMenuContactos) {

            //    email_predeterminado = frame_comentarios.Email_marcar_predeterminado()

            //    if (email_predeterminado) {
            //        alert("Debe seleccionar un Contacto de Email como Predeterminado.")
            //        return
            //    }

            //    //xmldato_c = frame_comentarios.contactos_xml()


            //}
            //else
            //    xmldato_c = contactos_xml()
            if (!mostrarMenuContactos)
                xmldato_c = contactos_xml()

            //CONTACTOS


            var tipo_docu = '';

            if (persona_fisica)
                $razon_social.value = $apellido.value + " " + $nombres.value

            var razon_social = '<![CDATA[' + $razon_social.value + ']]>'
            var abreviacion = '<![CDATA[' + $abreviacion.value + ']]>'
            var apellido = '<![CDATA[' + $apellido.value + ']]>'
            var nombres = '<![CDATA[' + $nombres.value + ']]>'
            var alias = '<![CDATA[' + $alias.value + ']]>'
            var calle = '<![CDATA[' + $calle.value + ']]>'
            var email = '<![CDATA[' + $email.value + ']]>'


            var xmldato = '<?xml version="1.0" encoding="ISO-8859-1"?>'
            xmldato += "<pago_entidad modo = '" + $modo.value + "' nro_entidad = '" + $nro_entidad.value + "' "
            xmldato += "postal='" + $postal.value + "' postal_telefono='" + postal_telefono + "' telefono='" + $telefono.value + "' "
            xmldato += "cuit='" + cuit + "' "
            if (cuit != '')
                xmldato += "cuitcuil='" + $cuitcuil.value + "' ";
            //xmldato += "cuitcuil='" + (cuitcuil != '' ? cuitcuil : (persona_fisica ? 'CUIL' : 'CUIT')) + "' "
            else xmldato += "cuitcuil='' "

            xmldato += "numero='" + $numero.value + "' piso='" + $piso.value + "' nro_contacto_tipo='" + $nro_contacto_tipo.value + "' depto='" + $depto.value + "' resto='" + $resto.value + "' "
            xmldato += "cod_sit_iva='" + $cod_sit_iva.value + "' cod_ing_brutos='" + $cod_ing_brutos.value + "' "

            if ($pep.checked)
                xmldato += "pep='1' "
            else
                xmldato += "pep='0' "


            if (persona_fisica) {

                tipo_docu = $('tipo_docu_pf').value;

                xmldato += "nro_docu='" + $nro_docu.value + "' tipo_docu='" + tipo_docu + "' sexo='" + $sexo.value + "' persona_fisica='" + $persona_fisica.value + "' "
                xmldato += "dni='" + $('dni').value + "' nro_emp_tipo='' nro_soc_tipo='' "
                xmldato += "fecha_nacimiento='" + $fecha_nacimiento.value + "' fecha_inscripcion='' estado_civil='" + $estado_civil.value + "' nro_nacion='" + $nro_nacion.value + "' "
                xmldato += "nro_docu_c='" + $('nro_docu_c').value + "' tipo_docu_c='" + $('tipo_docu_c').value + "' "


            }
            else {

                tipo_docu = $('tipo_docu_pj').value;

                xmldato += "nro_docu='" + $nro_docu.value + "' tipo_docu='" + tipo_docu + "' sexo='' persona_fisica='0' "
                xmldato += "dni='' nro_emp_tipo='" + $nro_emp_tipo.value + "' nro_soc_tipo='" + $nro_soc_tipo.value + "' "
                xmldato += "fecha_nacimiento='' fecha_inscripcion='" + $fecha_inscripcion.value + "' estado_civil='' nro_nacion ='' "
                xmldato += "nro_docu_c='' tipo_docu_c='' "


            }

            xmldato += ">"


            if (persona_fisica) {
                xmldato += "<apellido>" + apellido + "</apellido>"
                xmldato += "<nombres>" + nombres + "</nombres>"

            }
            else {
                xmldato += "<apellido></apellido>"
                xmldato += "<nombres></nombres>"
            }

            xmldato += "<razon_social>" + razon_social + "</razon_social>"
            xmldato += "<abreviacion>" + abreviacion + "</abreviacion>"
            xmldato += "<alias>" + alias + "</alias>"
            xmldato += "<calle>" + calle + "</calle>"
            xmldato += "<email>" + email + "</email>"
            xmldato += "</pago_entidad>"



            nvFW.error_ajax_request('entidad_abm.aspx', {
                parameters: {
                    modo: 'M',
                    strXML: escape(xmldato),
                    contactos_xml: xmldato_c,
                    tipo_docu: tipo_docu
                },
                onSuccess: function (err, transport) {
                    var nro_entidad = err.params['nro_entidad']
                    var ventana_actual = window.top.Windows.getFocusedWindow()
                    var params = []

                    params['nro_entidad'] = nro_entidad

                    ventana_actual.options.userData = {
                        modificacion: true,
                        recargar: true
                    }
                    ventana_actual.returnValue = params
                    ventana_actual.close()
                },
                onFailure: function (err) {
                    if (typeof err == 'object') {
                        alert(err.mensaje != '' ? err.mensaje : err.debug_desc, { title: '<b>' + err.titulo + '</b>' })
                    }
                },
                error_alert: false,
                bloq_msg: "Guardando..."
            });
        }




        //CONTACTOS
        var mostrarMenuContactos = false
        //var winHeightAnterior = {};
        function btnMostrarMenuContactos_onclick(mostrar) {

            //if ($modo.value == 'N') {
            //    alert('Debe dar de alta la persona para poder cargar los Contactos.')
            //    return
            //}

            if (!mostrar) {
                $('calle').disabled = false
                $('numero').disabled = false
                $('piso').disabled = false
                $('depto').disabled = false
                $('resto').disabled = false
                $('telefono').disabled = false
                $('email').disabled = false
                $car_tel.disabled = false
                $('localidad').disabled = false
                $('divLocalidadSel').show()

                campos_defs.habilitar('nro_contacto_tipo', true)
                mostrarMenuContactos = false;

            }
            else {
                //if (!mostrarMenuContactos) {
                $('calle').disabled = true
                $('numero').disabled = true
                $('piso').disabled = true
                $('depto').disabled = true
                $('resto').disabled = true
                $('telefono').disabled = true
                $('email').disabled = true
                $car_tel.disabled = true
                $('localidad').disabled = true
                $('divLocalidadSel').hide()

                campos_defs.habilitar('nro_contacto_tipo', false)

                if ($persona_fisica)
                    $('frame_comentarios').src = '/FW/entidades/contactos/Contacto_ABM.aspx?nro_docu=' + $nro_docu.value + '&tipo_docu=' + $tipo_docu_pf.value + '&sexo=' + sexo
                else $('frame_comentarios').src = '/FW/entidades/contactos/Contacto_ABM.aspx?nro_docu=' + $nro_docu.value + '&tipo_docu=' + $tipo_docu_pj.value + '&sexo=""'

                mostrarMenuComentarios = false;
                mostrarMenuVinculos = false;
                mostrarMenuContactos = true;
            }

            window_onresize();
        }


        //XML DE CONTACTOS
        function contactos_xml() {

            var id_domicilio
            var id_telefono
            var id_email

            var postalStr
            //var cpa = $('cpa').value
            var cpa = 0
            var incorrecto = false//$('incorrecto').value

            if (($('calle').value != $('calle_ant').value) || ($('numero').value != $('numero_ant').value) ||
                ($('piso').value != $('piso_ant').value) || ($('depto').value != $('depto_ant').value) ||
                $('postal').value != $('postal_ant').value) {//Hay cambio de datos inserto un nuevo registro
                id_domicilio = 0
            } else {
                id_domicilio = cargar_id_domicilio() // Update
            }

            if ($('telefono').value != $('telefono_ant').value || postal_telefono != $('postal_telefono_ant').value || $('telefono').value == "") {
                //Edicion de Caracteristica tel inserto nuevo contacto
                id_telefono = 0
                incorrecto = 'False'
                if (postal_telefono == "" || postal_telefono == 0)
                    postalStr = $('postal').value
                else
                    postalStr = postal_telefono
            } else {
                id_telefono = cargar_id_telefono() //Es el mismo lo cargo.
                postalStr = $('postal_telefono_ant').value == "null" ? 0 : $('postal_telefono_ant').value
            }

            var email_ant = $('email_ant').value == "null" ? '' : $('email_ant').value
            var email = $('email').value == "null" ? '' : $('email').value

            if (email == '' && email_ant != '') {
                id_email = cargar_id_email() * -1 //Cuando se elimina el email que esta guardado en la base
            } else if ((email != '' && email_ant == '') || (email != email_ant)) {//Hay cambio de datos inserto un nuevo registro
                id_email = 0
            } else {
                id_email = cargar_id_email() // Update
            }


            var fecha = new Date();



            var calle = '<![CDATA[' + $('calle').value + ']]>'

            var nro_contacto_tipo = campos_defs.get_value('nro_contacto_tipo')

            var id_ro_domicilio = 0
            var id_ro_telefono = 0

            var xmldato = ""
            xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xmldato += "<contactos>"
            if ($('calle').value == '')
                xmldato += "<domicilios><domicilio></domicilio></domicilios >"
            else {
                xmldato += "<domicilios>"
                xmldato += "\n<domicilio id_domicilio= '" + id_domicilio + "' numero ='" + $('numero').value + "' piso ='" + $('piso').value + "' depto ='" + $('depto').value + "' resto ='" + $('resto').value + "' postal ='" + $('postal').value + "' nro_operador ='" + nvFW.pageContents.nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='' nro_contacto_tipo = '1' predeterminado = '1' orden= '1' vigente='True' cpa ='" + cpa + "' id_ro_domicilio = '" + id_ro_domicilio + "'>"
                xmldato += "<calle>" + calle + "</calle>"
                xmldato += "</domicilio>"
                xmldato += "</domicilios>"
            }
            xmldato += "<telefonos>"
            xmldato += "\n<telefono id_telefono = '" + id_telefono + "' telefono ='" + $('telefono').value + "' postal ='" + postalStr + "' observacion ='' nro_operador ='" + nvFW.pageContents.nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' nro_contacto_tipo ='" + nro_contacto_tipo + "' predeterminado= '1' orden= '1' vigente='True' incorrecto='" + incorrecto + "' id_ro_telefono = '" + id_ro_telefono + "'/>"
            xmldato += "</telefonos>"

            if (email != '' || email_ant != '') {
                xmldato += "<emails>"
                xmldato += "\n<email id_email = '" + id_email + "' email ='" + $('email').value + "' nro_operador ='" + nvFW.pageContents.nro_operador + "' fecha_estado ='" + FechaToSTR(fecha, 1) + "' observacion ='' nro_contacto_tipo ='1' orden= '1' predeterminado= '1'  vigente='True' incorrecto='False'/>"
                xmldato += "</emails>"
            }
            xmldato += "</contactos>"

            return xmldato
        }



        //Conyuges
        function cbEstado_civil_onchange() {
            //habilitar/deshabilitar campo conyuge
            if ($('cod_est_civil').value == 'C') {
                if ($('nro_docu_c').value > 0)
                    $('nombre_c').value = nombre_c
                $('nombre_c').disabled = false
                $('btnSelConyuge').disabled = false
            }
            else {
                $('nombre_c').value = ''
                $('tipo_docu_c').value = ''//-1
                $('nro_docu_c').value = ''//-1
                //$('sexo_c').value = ''
                $('nombre_c').disabled = true
                $('btnSelConyuge').disabled = true
            }
        }

        //seleccion de conyuge
        var win_seleccionar_conyuge
        function btnSelConyuge_onclick() {
            titular = new Array()
            titular['estado_civil'] = $('cod_est_civil').value
            titular['calle'] = $('calle').value
            titular['numero'] = $('numero').value
            titular['piso'] = $('piso').value
            titular['depto'] = $('depto').value
            titular['resto'] = $('resto').value
            titular['postal'] = $('postal').value
            titular['localidad'] = $('localidad').value
            titular['car_tel'] = $('car_tel').value
            titular['telefono'] = $('telefono').value

            win_seleccionar_conyuge = new Window({
                className: 'alphacube',
                url: 'SeleccionarPersona.aspx',
                title: '<b>Seleccionar Persona</b>',
                minimizable: false,
                maximizable: false,
                draggable: false,
                resizable: false,
                width: 800,
                height: 200,
                onClose: SeleccionarPersona_conyuge_return
            });
            win_seleccionar_conyuge.options.userData = { titular: titular }
            win_seleccionar_conyuge.showCenter(true)
        }

        function SeleccionarPersona_conyuge_return() {
            if (win_seleccionar_conyuge.options.userData != null) {
                if (win_seleccionar_conyuge.options.userData.retorno != null) {
                    var retorno = win_seleccionar_conyuge.options.userData.retorno
                    //validar que el conyugue no sea la misma persona
                    if (retorno['nro_docu'] == $('nro_docu').value && retorno['tipo_docu'] == $('tipo_docu_pf').value && retorno['sexo'] == $('sexo').value) {
                        alert("No puede asignarse la misma persona como conyugue")
                        return
                    }
                    else {

                        $('tipo_docu_c').value = retorno['tipo_docu']
                        $('nro_docu_c').value = retorno['nro_docu']
                        $('nombre_c').value = retorno['nombre']
                        //$('sexo_c').value = retorno['sexo']
                        $('nombre_c').value = '(' + retorno["documento"] + ' ' + retorno["nro_docu"] + ')  ' + retorno["nombre"]
                    }
                }
            }
        }


        //cargar datos conyuge
        function cargarDatosConyuge() {
            var filtro = ''

            filtro += "<nro_docu type='igual'>" + $('nro_docu_c').value + "</nro_docu>"
            filtro += "<tipo_docu type='igual'>" + $('tipo_docu_c').value + "</tipo_docu>"
            //filtro += "<sexo type='igual'>'" + $('sexo_c').value + "'</sexo>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroXMLEntidad, "", filtro)
            if (!rs.eof()) {

                var dto_return = rs.getdata('documento')
                var nro_doc_return = rs.getdata('nro_docu')
                var nombre_return = rs.getdata('apellido') + ', ' + rs.getdata('nombres')

                //$('nombre_c').value = '(' + dto_return + ' ' + nro_doc_return + ')  ' + nombre_return
                nombre_c = '(' + dto_return + ' ' + nro_doc_return + ')  ' + nombre_return
                $('tipo_docu_desc_c').value = rs.getdata('documento')
            }
        }


        //CONTACTO ANTERIOR
        function cargar_id_domicilio() {
            var id_domicilio
            var filtro = ''

            filtro = "<calle type='igual'>'" + $('calle_ant').value + "'</calle>"
            filtro += "<numero type='igual'>" + $('numero_ant').value + "</numero>"

            if ($('piso_ant').value != "")
                filtro += "<piso type='igual'>'" + $('piso_ant').value + "'</piso>"

            if ($('depto_ant').value != "")
                filtro += "<depto type='igual'>'" + $('depto_ant').value + "'</depto>"

            filtro += "<nro_entidad type='igual'>" + $('nro_entidad').value + "</nro_entidad>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroDomicilio, "", filtro)
            if (!rs.eof()) {
                id_domicilio = rs.getdata('id_domicilio')
            }
            else
                id_domicilio = 0

            return id_domicilio
        }

        function cargar_id_telefono() {
            var id_telefono
            var filtro = ''
            var postal_telefono_ant = $('postal_telefono_ant').value == "null" ? 0 : $('postal_telefono_ant').value

            filtro = "<telefono type='igual'>'" + $('telefono_ant').value + "'</telefono>"
            filtro += "<postal type='igual'>" + postal_telefono_ant + "</postal>"
            filtro += "<nro_entidad type='igual'>" + $('nro_entidad').value + "</nro_entidad>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroContactoTelefono, "", filtro)
            if (!rs.eof()) {
                id_telefono = rs.getdata('id_telefono')
            } else {

                var rs1 = new tRS();
                rs1.open(nvFW.pageContents.filtroContactoTelefono2, "", filtro)
                if (!rs1.eof()) {
                    id_telefono = rs1.getdata('id_telefono')
                }
                else
                    id_telefono = 0
            }

            return id_telefono
        }

        function cargar_id_email() {
            var id_email
            var filtro = ''
            var email_ant = $('email_ant').value == "null" ? '' : $('email_ant').value

            filtro = "<email type='igual'>'" + email_ant + "'</email>"
            filtro += "<nro_entidad type='igual'>" + $('nro_entidad').value + "</nro_entidad>"

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroContactoEmail, "", filtro)
            if (!rs.eof()) {
                id_email = rs.getdata('id_email')
            } else {

                var rs1 = new tRS();
                rs1.open(nvFW.pageContents.filtroContactoEmail2, "", filtro)
                if (!rs1.eof()) {
                    id_email = rs1.getdata('id_email')
                }
                else
                    id_email = 0
            }

            return id_email
        }

        function checkError() {
            if (strError != '') {
                window.alert('Error de inicialización. Consulte al Administrador de Sistemas.\n' + strError)
                strError = ''
            }
        }

        //habilitar/deshabilitar campos cuit/dni dependiendo tipo_docu
        function tipo_docu_onClick() {

            if ($persona_fisica.value == '1') {

                switch ($tipo_docu_pf.value) {
                    case "6":
                        $cuitcuil.disabled = true;
                        $cuit.disabled = true;
                        $('dni').disabled = false;
                        $cuitcuil.value = 'CUIL';
                        break;
                    case "8":
                        $cuitcuil.disabled = true;
                        $cuit.disabled = true;
                        $('dni').disabled = false;
                        $cuitcuil.value = 'CUIT';
                        break;
                    case "3":
                        $cuitcuil.disabled = false;
                        $cuit.disabled = false;
                        $('dni').disabled = true;
                        break

                    default:
                        $cuitcuil.disabled = false;
                        $cuit.disabled = false;
                        $('dni').disabled = false;
                        break;
                }


            } else {

                switch ($tipo_docu_pj.value) {
                    case "8":
                        //$cuitcuil.disabled = true;
                        $cuit.disabled = true;
                        break;

                    default:
                        //$cuitcuil.disabled = false;
                        $cuit.disabled = false;
                        break;
                }

            }

        }

        function nro_docuOnchange() {

            if ($persona_fisica.value == '1') {

                switch ($tipo_docu_pf.value) {
                    case "6":

                        $cuit.value = $nro_docu.value;
                        //validar cuit
                        validarCUIT();
                        break;
                    case "8":
                        $cuit.value = $nro_docu.value;
                        //validar cuit
                        validarCUIT();
                        break;
                    case "3":
                        $('dni').value = $nro_docu.value;
                        $cuit.value = '';
                        generarCUIT();
                        //validarCUIT();
                        break

                    default:
                        break;
                }

            } else {

                switch ($tipo_docu_pj.value) {
                    case "8":
                        $cuit.value = $nro_docu.value;
                        //validar cuit
                        validarCUIT();
                        break;

                    default:
                        break;
                }

            }

        }

        //Maps autocompletar calle
        var autocomplete, autocompleteLsr, calleInputHtml;
        function inicializarMaps() {
		
            // Box general
            var configs = {
                types: ['address'],
                //types: ['(cities)'],
                //types: ['geocode'],
                componentRestrictions: { country: 'ar' }
            };

            //Box calle
            var input = $('calle');
            calleInputHtml = input.outerHTML;
            input.placeholder = ''; //'Ingrese una dirección. Ej: Bv. Oroño 126, Rosario, Santa Fe';
            input.autocomplete = 'on';

            autocomplete = new google.maps.places.Autocomplete(input, configs);
            autocomplete.setFields(['address_components']);
            autocompleteLsr = autocomplete.addListener('place_changed', setDataMapCallback); // Evento seleccionar

        
            //// Box ciudad
            //var config_city = {
            //    types: ['(cities)'],
            //    componentRestrictions: { country: 'ar' }
            //};

            //var input_city = $('ciudad');
            //input_city.placeholder = 'Ej: Santa Fe';
            //input_city.autocomplete = 'on';

            //autocomplete_city = new google.maps.places.Autocomplete(input_city, config_city);
            //autocomplete_city.setFields(['address_components']);
            //autocomplete_city.addListener('place_changed', setDataCityCallback); // Evento seleccionar (input de ciudad)

            //Captura el error de autenticación de Google Maps API
            gm_authFailure = function () {
                //Destruimos el autocomplete y liberamos el campo
                google.maps.event.removeListener(autocompleteLsr);
                google.maps.event.clearInstanceListeners(autocomplete);
                $('calle').outerHTML = calleInputHtml;
                console.log("Google Maps JavaScript API no pudo autenticar. El autocompletado del domicilio no estará disponible.")
            };
        }

        function setDataMapCallback() {
		    
            var filtro = '';
            var place = autocomplete.getPlace();

            if (place.address_components) {
                var item;
                $localidad.value = '';
                
                for (var i = 0; i < place.address_components.length; i++) {
                    item = place.address_components[i];

                    //if (item.types[0] == 'route')
                    //    if (item.long_name) $('calle').value = item.long_name;

                    switch (item.types[0]) {
                        case 'route':
                            if (item.long_name) $('calle').value = item.long_name;
                            //if (item.long_name) campos_defs.set_value('calle', item.long_name);
                            break;

                        //case 'street_number':
                        //    if (item.long_name) campos_defs.set_value('numero', item.long_name);
                        //    break;

                        case 'locality':
                            if (item.long_name) /*campos_defs.set_value('ciudad', item.long_name);*/
                                if (item.long_name) {
                                    $localidad.value += item.long_name.toUpperCase();
                                    filtro += "<sql type='sql'> '" + reemplazarAcentos(item.long_name) + "' = localidad collate Latin1_General_CI_AI</sql >";
                                    
                                }
                            break;

                        //case 'postal_code':
                        //    console.log('entro')
                        //    if (item.long_name) $localidad.value = "CP: " + item.long_name + ' - ' + $localidad.value;
                        //    break;

                        case 'administrative_area_level_1':
                            if (item.long_name) {
                                $localidad.value += ' - ' + item.long_name.toUpperCase();
                                filtro += "<sql type='sql'>'" + reemplazarAcentos(item.long_name) + "' = provincia collate Latin1_General_CI_AI</sql>";
                            }
                            break;
                    }
                }

                var rsLocalidad = new tRS();

                rsLocalidad.open(nvFW.pageContents.filtroBuscarLocalidad, "", filtro)

                if (!rsLocalidad.eof()) {
                    $postal.value = rsLocalidad.getdata('postal');
                    $localidad.value = 'CP: ' + rsLocalidad.getdata('postal_real') + ' - ' + $localidad.value;
                    postal_telefono = $postal.value;
                    $car_tel.value = rsLocalidad.getdata('car_tel');
                }

            }
        } 

        function reemplazarAcentos(cadena) {
            var chars = {
                "á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u",
                "à": "a", "è": "e", "ì": "i", "ò": "o", "ù": "u", "ñ": "n",
                "Á": "A", "É": "E", "Í": "I", "Ó": "O", "Ú": "U",
                "À": "A", "È": "E", "Ì": "I", "Ò": "O", "Ù": "U", "Ñ": "N"
            }
            var expr = /[áàéèíìóòúùñ]/ig;
            var res = cadena.replace(expr, function (e) { return chars[e] });
            return res;
        }

        function onchangeSexo() {

            if (($tipo_docu_pf.value == "3") && ($nro_docu.value != '')) {
                $cuit.value = '';
                generarCUIT();
            }

        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto;">
    <form action="entidad_abm.aspx" method="post" name="form1" target="frmEnviar" autocomplete="off" style="margin: 0; height: 100%">
        <input type="hidden" name="modo" value="<% = modo %>" id="modo" />
        <input type="hidden" name="nro_entidad" id="nro_entidad" value="<% = nro_entidad %>" />
        <input type="hidden" name="strXML" value="" />

        <input type="hidden" name="tipo_docu_c" id="tipo_docu_c" value="" />
        <input type="hidden" name="nro_docu_c" id="nro_docu_c" value="" />
        <input type="hidden" name="tipo_docu_desc_c" id="tipo_docu_desc_c" value="" />

        <input type="hidden" name="tipo_docu_c_ant" id="tipo_docu_c_ant" value="" />
        <input type="hidden" name="nro_docu_c_ant" id="nro_docu_c_ant" value="" />

        <input type="hidden" name="estado_civil_ant" id="estado_civil_ant" value="" />


        <input type="hidden" name="calle_ant" id="calle_ant" value="" />
        <input type="hidden" name="numero_ant" id="numero_ant" value="" />
        <input type="hidden" name="piso_ant" id="piso_ant" value="" />
        <input type="hidden" name="depto_ant" id="depto_ant" value="" />
        <input type="hidden" name="resto_ant" id="resto_ant" value="" />
        <input type="hidden" name="postal_ant" id="postal_ant" value="" />
        <input type="hidden" name="telefono_ant" id="telefono_ant" value="" />
        <input type="hidden" name="postal_telefono_ant" id="postal_telefono_ant" value="" />
        <input type="hidden" name="email_ant" id="email_ant" value="" />
        <input type="hidden" name="nro_contacto_tipo_ant" id="nro_contacto_tipo_ant" value="" />


        <%--<div id="divFiltroDatos" style="width: 100%; height: 97%; overflow: hidden;">--%>
        <div id="divFiltroDatos" style="width: 100%; height: 100%; overflow: hidden;">
            <input type="hidden" name="postal" id="postal" value="" />
            <div id="divMenuABMEntidades"></div>

            <script type="text/javascript">
                var vMenuABMEntidades = new tMenu('divMenuABMEntidades', 'vMenuABMEntidades');
                Menus["vMenuABMEntidades"] = vMenuABMEntidades;
                Menus["vMenuABMEntidades"].alineacion = 'centro';
                Menus["vMenuABMEntidades"].estilo = 'A';
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>entidad_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Generar CUIT</Desc><Acciones><Ejecutar Tipo='script'><Codigo>boton_generar_cuit()</Codigo></Ejecutar></Acciones></MenuItem>")

                if ((permiso & 4) > 0)
                    Menus["vMenuABMEntidades"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>hoja</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>entidad_nueva()</Codigo></Ejecutar></Acciones></MenuItem>") //BORRAR?

                Menus["vMenuABMEntidades"].loadImage('guardar', '/FW/image/icons/guardar.png')
                Menus["vMenuABMEntidades"].loadImage('hoja', '/FW/image/icons/nueva.png')
                vMenuABMEntidades.MostrarMenu()
            </script>

            <div id="divDatosPersonales" style="width: 100%; height: auto;">
                <table class="tb1" cellspacing="0" cellpadding="0">
                    <tr>
                        <td style="width: 20%;">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td id="tdnro_entidad" style="width: 10%; display: none; text-align: center" nowrap>Nro. Entidad</td>
                                    <td style="width: 100%; font-weight: 700; text-align: center;">Tipo Entidad</td>
                                </tr>
                                <tr>
                                    <td style="width: 10%; display: none" id="td_inputnro_entidad">
                                        <input style="width: 100%; text-align: right" type="text" name="inputnro_entidad" id="inputnro_entidad" /></td>
                                    <td style="width: 100%;">
                                        <select name="persona_fisica" id="persona_fisica" onchange="decidir_tabla(this.value)" style="width: 100%;">
                                            <option value="0" selected="selected">Persona Jurídica</option>
                                            <option value="1" selected="selected">Persona Física</option>
                                        </select>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 25%">
                            <table class="tb1">
                                <tr class="tbLabel">
                                    <td style="width: 15%; font-weight: 700; text-align: center;" nowrap>Tipo Doc. *</td>
                                    <td style="width: 20%; font-weight: 700; text-align: center;" nowrap>Nro. Doc. *</td>
                                </tr>
                                <tr>
                                    <td id="tdtipo_docu_pf">
                                        <script>
                                            campos_defs.add('tipo_docu_pf', {
                                                enDB: false,
                                                filtroXML: nvFW.pageContents.filtro_tipoDocPF,
                                                nro_campo_tipo: 1,
                                                onchange: function () { tipo_docu_onClick(); }
                                            })
                                        </script>
                                    </td>
                                    <td id="tdtipo_docu_pj">
                                        <script>
                                            campos_defs.add("tipo_docu_pj", {
                                                enDB: false,
                                                filtroXML: nvFW.pageContents.filtro_tipoDocPJ,
                                                nro_campo_tipo: 1,
                                                onchange: function () { tipo_docu_onClick(); }
                                            })
                                        </script>
                                    </td>
                                    <td>
                                        <input type="text" name="nro_docu" id="nro_docu" <%--maxlength="8"--%> value="" style="width: 100%; text-align: right;" onchange="nro_docuOnchange()" onblur="nro_docuOnchange()" onkeypress="return valDigito(event)" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td style="width: 55%">
                            <table class="tb1" id="datos_pfisica">
                                <tr class="tbLabel">
                                    <td style="width: 30%; font-weight: 700; text-align: center;" nowrap>Apellido *</td>
                                    <td style="width: 30%; font-weight: 700; text-align: center;" nowrap>Nombres *</td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="text" name="apellido" id="apellido" value="" style="width: 100%" autocomplete="new-apellido"/>
                                    </td>
                                    <td>
                                        <input type="text" name="nombres" id="nombres" value="" style="width: 100%" autocomplete="new-nombre"/>
                                    </td>
                                </tr>
                            </table>
                            <table class="tb1" id="datos_pjuridica" style="display: none;">
                                <tr class="tbLabel">
                                    <td style="width: 65%; font-weight: 700; text-align: center;">Razón Social *</td>
                                    <td style="width: 35%; font-weight: 700; text-align: center;">Abreviación</td>
                                </tr>
                                <tr>
                                    <td style="width: 65%">
                                        <input type="text" name="razon_social" id="razon_social" value="" style="width: 100%" maxlength="200" autocomplete="new-RS" />
                                    </td>
                                    <td style="width: 35%">
                                        <input type="text" name="abreviacion" id="abreviacion" value="" style="width: 100%" maxlength="50" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="datos_pfisica2">
                    <tr class="tbLabel">
                        <td style="text-align: center" nowrap>Fecha Nacimiento *</td>
                        <td style="width: 17%; font-weight: 700; text-align: center;" nowrap>Sexo *</td>
                        <td style="width: 26%; text-align: center">Nacionalidad<span id="ObgNacionalidad"></span></td>
                        <td style="width: 17%; text-align: center" nowrap>Estado Civil</td>
                        <td style="width: 26%; text-align: center" colspan="2">Cónyuge</td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('fecha_nacimiento', { enDB: false, nro_campo_tipo: 103 });
                            </script>
                        </td>
                        <td>
                            <select name="sexo" id="sexo" style="width: 100%" onchange="onchangeSexo()">
                                <option value="M">MASCULINO</option>
                                <option value="F">FEMENINO</option>
                            </select>
                        </td>

                        <td style="width: 20%">
                            <script type="text/javascript">
                                campos_defs.add('nro_nacion');
                            </script>
                        </td>
                        <td>
                            <script type="text/javascript">
                                campos_defs.add('cod_est_civil', {
                                    enDB: false,
                                    filtroXML: nvFW.pageContents.filtro_ent_estado_civil,
                                    nro_campo_tipo: 1
                                });
                                campos_defs.items['cod_est_civil']['onchange'] = function () { cbEstado_civil_onchange() }
                            </script>
                        </td>
                        <td>
                            <input style="width: 100%" name="nombre_c" id="nombre_c" readonly="readonly" /></td>
                        <td>
                            <input type="button" name="btnSelConyuge" id="btnSelConyuge" value="." onclick="return btnSelConyuge_onclick()" style="height: 20px" />
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="datos_pjuridica2" style="display: none;">
                    <tr class="tbLabel">
                        <td style="width: 14%; text-align: center" nowrap>Fecha Inscripción</td>
                        <td style="width: 30%; font-weight: 700; text-align: center;">Alias</td>
                        <td style="width: 28%; text-align: center" nowrap>Tipo Empresa</td>
                        <td style="width: 28%; text-align: center" nowrap>Tipo Sociedad</td>
                    </tr>
                    <tr>
                        <td style="width: 14%">
                            <script>
                                campos_defs.add('fecha_inscripcion', { enDB: false, nro_campo_tipo: 103 });
                            </script>
                        </td>
                        <td style="width: 30%">
                            <input type="text" name="alias" id="alias" value="" style="width: 100%" maxlength="200" />
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nro_emp_tipo')
                            </script>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('nro_soc_tipo')
                            </script>
                        </td>
                    </tr>
                </table>
                <table class="tb1" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <table class="tb1" style="width: 100%">
                                <tr class="tbLabel" style="width: 500px !important">
                                    <td style="width: 10.5%; font-weight: 700; text-align: center;">Tipo</td>
                                    <td id="td_cuit_cuil" style="font-weight: 700; text-align: center;">CUIT/CUIL</td>
                                    <td id="td_dni" style="width: 10%; text-align: center">DNI</td>
                                    <td style="width: 35%; font-weight: 700; text-align: center;" nowrap>Situación IVA</td>
                                    <td style="width: 35%; font-weight: 700; text-align: center;" nowrap>Situación I. Brutos</td>
                                </tr>
                                <tr style="width: 500px !important">
                                    <td>
                                        <select id="cuitcuil" style="width: 100%;">
                                            <option value="CUIL" selected="selected">CUIL</option>
                                            <option value="CUIT">CUIT</option>
                                        </select>
                                    </td>
                                    <td>
                                        <input style="width: 100%; text-align: right" maxlength="11" type="text" name="cuit" id="cuit" value="" onkeypress="return valDigito(event)" onchange="validarCUIT()" />
                                    </td>
                                    <td id="td_dni_input">
                                        <input style="width: 100%; text-align: right" maxlength="8" type="text" name="dni" id="dni" value="" onkeypress="return valDigito(event)" onchange="generarCUIT()" onblur="generarCUIT()" <%--onchange="validarCUIT()"--%> />
                                    </td>
                                    <td style="width: 35%">
                                        <script>
                                            campos_defs.add('cod_sit_iva')
                                        </script>
                                    </td>
                                    <td style="width: 35%">
                                        <script>
                                            campos_defs.add('cod_ing_brutos')
                                        </script>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table class="tb1" style="width: 100%" id="tb_dir">
                    <tr class="tbLabel">
                        <td style="text-align: center">Calle<span id="ObgCalle"></span></td>
                        <td style="width: 6%; text-align: center">Nro<span id="ObgNro"></span></td>
                        <td style="width: 5%; text-align: center">Piso</td>
                        <td style="width: 5%; text-align: center">Dpto</td>
                        <td style="width: 6%; text-align: center">Resto</td>
                        <td style="width: 45.5%; font-weight: 700; text-align: center;" colspan="2">Localidad</td>
                    </tr>
                    <tr>
                        <td>
                            <input style="width: 100%" type="text" name="calle" id="calle" value="" maxlength="50" autocomplete="new-calle"/></td>
                        <td style="width: 6%">
                            <input type="text" name="numero" id="numero" style="width: 100%" value="" onkeypress="return valDigito(event)" maxlength="5" /></td>
                        <td style="width: 5%">
                            <input type="text" name="piso" id="piso" style="width: 100%" value="" maxlength="2" /></td>
                        <td style="width: 5%">
                            <input type="text" name="depto" id="depto" style="width: 100%" value="" maxlength="4" /></td>
                        <td style="width: 6%">
                            <input type="text" name="resto" id="resto" style="width: 100%" value="" /></td>
                        <td style="width: 35.5%">
                            <input name="localidad" id="localidad" style="width: 100%" ondblclick="selLocalidad()" readonly="readonly" />
                        </td>
                        <td style="width: 10%">
                            <div id="divLocalidadSel" style="width: 100%"></div>
                        </td>
                    </tr>
                </table>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 45%; font-weight: 700; text-align: center;" colspan="4">Teléfono</td>
                        <td style="width: 46%; font-weight: 700; text-align: center;" nowrap>E-mail</td>
                        <td style="width: 9%; font-weight: 700; text-align: center;">PEP</td>
                    </tr>
                    <tr>
                        <td style="width: 15%" id="td_nro_contacto_tipo">
                            <script>
                                campos_defs.add('nro_contacto_tipo', {
                                    despliega: 'abajo',
                                    enDB: false,
                                    nro_campo_tipo: 1,
                                    filtroXML: nvFW.pageContents.filtroContactoTipo,
                                    filtroWhere: "<nro_contacto_tipo type='igual'>%campo_value%</nro_contacto_tipo>",
                                    depende_de: null,
                                    depende_de_campo: null
                                })
                            </script>
                        </td>
                        <td style="width: 9%">
                            <input type="text" name="car_tel" id="car_tel" value="" readonly="readonly" ondblclick="selLocalidad_telefono()" style="width: 100%; text-align: right" />
                            </td>
                        <td>
                            <div id="divCaracteristicaSel"<%-- style="width: 5%"--%>></div>       
                            </td>
                        <td style="width: 19%">
                            <input type="text" name="telefono" id="telefono" value="" style="width: 100%" />
                        </td>
                        <td style="width: 46%">
                            <input type="text" name="email" id="email" style="width: 100%" value="" maxlength="255" />
                        </td>
                        <td style="width: 9%">
                            <input type="checkbox" name="pep" id="pep" style="width: 100%; text-align: center" onkeypress="" />
                        </td>
                    </tr>
                </table>
                <table class="tb1" id="tb_oblig">
                    <tr class="tbLabel">
                        <td style="width: 75%; text-align: left !Important">(*) Campos obligatorios</td>
                    </tr>
                </table>
                <div id="divMenuContactos" style="width: 100%; margin: 0px; padding: 0px"></div>
                <script type="text/javascript">
                    if (nvFW.pageContents.nro_entidad != '') {
                        var vMenuContactos = new tMenu('divMenuContactos', 'vMenuContactos');
                        Menus["vMenuContactos"] = vMenuContactos
                        Menus["vMenuContactos"].alineacion = 'centro';
                        Menus["vMenuContactos"].estilo = 'A';
                        vMenuContactos.loadImage("comentario", "/FW/image/icons/comentario3.png");
                        vMenuContactos.loadImage("user", "/FW/image/icons/user.png");
                        vMenuContactos.loadImage("vinculo", "/FW/image/icons/personas.png");

                        Menus["vMenuContactos"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                        Menus["vMenuContactos"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>VerComentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
                        if (nvFW.tienePermiso('permisos_contactos', 1)) {
                            Menus["vMenuContactos"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>user</icono><Desc>Contactos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnMostrarMenuContactos_onclick(true)</Codigo></Ejecutar></Acciones></MenuItem>")
                        }
                        if (nvFW.tienePermiso('permisos_vinculos', 1)) {
                            Menus["vMenuContactos"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vinculo</icono><Desc>Vínculos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>VerVinculos()</Codigo></Ejecutar></Acciones></MenuItem>")
                        }

                        vMenuContactos.MostrarMenu()
                    }
                </script>
            </div>
            <div id="divComentarioParametros" style="width: 100%; height: auto;">
                <table class="tb1" id="tbComentarioParametros" cellpadding="0" cellspacing="0">
                    <tr>
                        <td style="width: 100%; vertical-align: top;" id="td_frame_comentarios">
                            <iframe name="frame_comentarios" id="frame_comentarios" style="width: 100%; height: 100%; overflow: hidden; border: none;"></iframe>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</body>
</html>
