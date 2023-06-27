<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim nro_operador = op.operador
    If (Not op.tienePermiso("permisos_cuentas", 8)) Then Response.Redirect("/FW/error/httpError_401.aspx")


    Me.contents("filtro_entidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>nro_banco,banco,id_banco_sucursal,banco_sucursal,id_cuenta,id_cuenta_old,tipo_cuenta_desc,nro_cuenta,interb_estado_desc,habilitada, CBU, ISO_cod</campos><filtro></filtro><orden>banco</orden></select></criterio>")
    Me.contents("filtro_bco_cuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>nro_entidad,tipo_cuenta,nro_cuenta,CBU,nro_banco,id_banco_sucursal,cod_sucursal,banco_sucursal,monto_max_dto,descripcion,denominacion,cta_sueldo,habilitada,id_cuenta_old,cuit,alias,moneda</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_personas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Personas'><campos>nro_entidad,cuit</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_credito_cobro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='credito_cobro'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_interb_ctas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='interb_ctas'><campos>top 1 id_cuenta,interb_estado</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_entidad_interb_ctas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_ctas_interb'><campos>nro_interb_empresa,interb_estado,interb_estado_desc,interb_empresa</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_DBCuenta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verDBCuenta' top='1'><campos>nro_cuenta</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtro_entidad_bco_cuentas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_bco_ctas'><campos>CBU</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtro_banco_sucursal") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verBancoSucursal'><campos>id_banco_sucursal, cod_sucursal, cod_cbu, Banco_sucursal</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_personaFisica") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Personas'><campos>nro_docu, tipo_docu, sexo, cuit</campos><filtro><nro_entidad type='igual'>%nro_entidad%</nro_entidad></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_entidadCtas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidad_ctas'><campos>id_cuenta</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_banco") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Banco'><campos>nro_banco_BCRA</campos><filtro><nro_banco type='igual'>%param1%</nro_banco></filtro><orden></orden></select></criterio>")

    Dim StrSQL As String = ""

    '---------------------------------------------------
    ' MODOS
    '---------------------------------------------------
    '       VA: 'Modo Vista Vacia'
    '       V: 'Modo Vista'
    '       A: 'Modo Alta'
    '       M: 'Modo Actualización'
    '---------------------------------------------------
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    If (modo = "") Then modo = "VA"

    Dim id_cuenta As String = nvFW.nvUtiles.obtenerValor("id_cuenta", "")
    Dim tipo_docu As String = nvFW.nvUtiles.obtenerValor("tipo_docu", "")
    Dim nro_docu As String = nvFW.nvUtiles.obtenerValor("nro_docu", "")
    Dim sexo As String = nvFW.nvUtiles.obtenerValor("sexo", "")
    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")
    Dim id_tipo As String = nvFW.nvUtiles.obtenerValor("id_tipo", "")
    Dim nro_ent_id_tipo As Integer = nvFW.nvUtiles.obtenerValor("nro_ent_id_tipo", 0)

    If id_tipo <> "" And nro_ent_id_tipo = 1 Then
        nro_entidad = id_tipo
    End If

    Dim id_cuenta_old As String = ""

    If (modo <> "V" And modo <> "VA") Then
        Dim err As New tError()
        Dim strXML = obtenerValor("strxml", "")
        Dim objXML = Server.CreateObject("Microsoft.XMLDOM")

        objXML.loadXML(strXML)

        Dim nro_permitir As Boolean = False
        Dim nro_banco = objXML.selectSingleNode("/abm_cuenta/@nro_banco").nodeValue
        Dim id_banco_sucursal = objXML.selectSingleNode("/abm_cuenta/@id_banco_sucursal").nodeValue
        Dim tipo_cuenta = objXML.selectSingleNode("/abm_cuenta/@tipo_cuenta").nodeValue
        Dim nro_cuenta = objXML.selectSingleNode("/abm_cuenta/@nro_cuenta").nodeValue
        id_cuenta = objXML.selectSingleNode("/abm_cuenta/@id_cuenta").nodeValue
        id_cuenta_old = objXML.selectSingleNode("/abm_cuenta/@id_cuenta_old").nodeValue
        nro_docu = objXML.selectSingleNode("/abm_cuenta/@nro_docu").nodeValue
        tipo_docu = objXML.selectSingleNode("/abm_cuenta/@tipo_docu").nodeValue
        sexo = objXML.selectSingleNode("/abm_cuenta/@sexo").nodeValue
        nro_entidad = objXML.selectSingleNode("/abm_cuenta/@nro_entidad").nodeValue
        id_tipo = objXML.selectSingleNode("/abm_cuenta/@id_tipo").nodeValue
        nro_ent_id_tipo = objXML.selectSingleNode("/abm_cuenta/@nro_ent_id_tipo").nodeValue
        Dim cuit = objXML.selectSingleNode("/abm_cuenta/@cuit").nodeValue
        Dim ctl_monto_max_dto = objXML.selectSingleNode("/abm_cuenta/@ctl_monto_max_dto").nodeValue
        Dim ctl_denominacion = objXML.selectSingleNode("/abm_cuenta/@ctl_denominacion").nodeValue
        Dim descripcion = objXML.selectSingleNode("/abm_cuenta/@descripcion").nodeValue
        Dim denominacion = objXML.selectSingleNode("/abm_cuenta/@denominacion").nodeValue
        Dim cta_sueldo = objXML.selectSingleNode("/abm_cuenta/@cta_sueldo").nodeValue
        Dim habilitada = objXML.selectSingleNode("/abm_cuenta/@habilitada").nodeValue
        Dim cbu = objXML.selectSingleNode("/abm_cuenta/@cbu").nodeValue
        Dim moneda = objXML.selectSingleNode("/abm_cuenta/@moneda").nodeValue
        Dim strAlias = objXML.selectSingleNode("/abm_cuenta/@alias").nodeValue
        Dim str_tipo_cuenta_i As String = ""
        Dim str_tipo_cuenta_u As String = ""
        Dim monto_max_dto = objXML.selectSingleNode("/abm_cuenta/@monto_max_dto").nodeValue

        If (tipo_docu = "") Then tipo_docu = 0

        If (nro_docu = "") Then nro_docu = 0

        If (monto_max_dto = "") Then monto_max_dto = 0

        If (id_cuenta_old = "" Or id_cuenta_old = "undefined") Then id_cuenta_old = 0

        StrSQL = "SELECT DBO.rm_tiene_permiso('permisos_cuentas', 1) AS nro_permitir"
        Dim Rs As ADODB.Recordset = nvDBUtiles.DBExecute(StrSQL) 'DBOpenRecordset(StrSQL)

        If Not Rs.EOF Then
            nro_permitir = Rs.Fields("nro_permitir").Value
        End If

        nvDBUtiles.DBCloseRecordset(Rs)

        If (nro_permitir) Then

            If cbu = "" And nro_cuenta = "" And strAlias = "" Then
                err.numError = 0
                err.params("retorno_proceso") = -99
                err.params("mensaje") = "No ha cargado el CBU/Nº Cuenta/Alias"
                err.response()
            End If

            StrSQL = "DECLARE @ret INT ; "

            Select Case modo
                Case "A"
                    StrSQL += "EXEC @ret = dbo.rm_cuenta_banco_ABM '" & cuit & "', " & tipo_docu & ", " & nro_docu & ", " & nro_banco & ", " & id_banco_sucursal & ", " & tipo_cuenta & ", '" & nro_cuenta & "', null, null, '" & sexo & "', " & nro_entidad & ", '" & descripcion & "', '" & denominacion & "', " & monto_max_dto & ", " & cta_sueldo & ", " & habilitada & ", 'A', " & id_tipo & ", " & nro_ent_id_tipo & ", " & moneda & ", '" & strAlias & "', '" & cbu & "' ; "

                Case "M"
                    StrSQL += "EXEC @ret = dbo.rm_cuenta_banco_ABM '" & cuit & "', " & tipo_docu & ", " & nro_docu & ", " & nro_banco & ", " & id_banco_sucursal & ", " & tipo_cuenta & ", '" & nro_cuenta & "', " & id_cuenta & ", " & id_cuenta_old & ", '" & sexo & "', " & nro_entidad & ", '" & descripcion & "', '" & denominacion & "', " & monto_max_dto & ", " & cta_sueldo & ", " & habilitada & ", 'M', " & id_tipo & ", " & nro_ent_id_tipo & ", " & moneda & ", '" & strAlias & "', '" & cbu & "' ; "

                Case "B"
                    StrSQL += "EXEC @ret = dbo.rm_cuenta_banco_ABM '" & cuit & "', " & tipo_docu & ", " & nro_docu & ", " & nro_banco & ", " & id_banco_sucursal & ", " & tipo_cuenta & ", '" & nro_cuenta & "', " & id_cuenta & ", " & id_cuenta_old & ", '" & sexo & "', " & nro_entidad & ", '" & descripcion & "', '" & denominacion & "', " & monto_max_dto & ", " & cta_sueldo & ", " & habilitada & ", 'B', " & id_tipo & ", " & nro_ent_id_tipo & ", " & moneda & ", '" & strAlias & "', '" & cbu & "' ; "
            End Select

            StrSQL += "SELECT @ret "

            If (StrSQL <> "") Then
                Try
                    Rs = DBOpenRecordset(StrSQL)
                    Dim ret = Rs.Fields(0).Value

                    If (ret > 0) Then
                        err.numError = 0

                        If (modo <> "B") Then
                            err.params("retorno_proceso") = ret
                        Else
                            err.params("retorno_proceso") = ""
                        End If
                    Else
                        If (modo = "A") Then
                            err.numError = 0 'error al dar de alta
                            err.params("retorno_proceso") = ret
                            err.params("mensaje") = "Error al dar de alta en el sistema"

                            If (ret = -8) Then
                                err.params("mensaje") = "Error al dar de alta en el sistema. La cuenta ya existe."
                            End If
                        End If ' Fin IF de Alta (A)

                        If (modo = "M") Then
                            err.numError = 0 'error al hacer modificacion
                            err.params("retorno_proceso") = ret
                            err.params("mensaje") = "Error al hacer modificacion en el sistema"
                        End If ' Fin IF de Modificacion (M)

                        If (modo = "B") Then
                            err.numError = 0 'error al hacer eliminar
                            err.params("retorno_proceso") = ret

                            If (ret = -6) Then
                                err.params("mensaje") = "La cuenta no se puede eliminar ya que tiene pagos asociados"
                            End If

                            If (ret = -7) Then
                                err.params("mensaje") = "La cuenta no se puede eliminar porque esta asociada al interbanking"
                            End If

                            If (ret = -5) Then
                                err.params("mensaje") = "La cuenta no se puede eliminar porque esta asociada a un credito"
                            End If
                        End If ' Fin IF de Baja (B)
                    End If ' Fin ELSE: entra porque no hay errores de ejecucion de procedimiento

                    nvFW.nvDBUtiles.DBCloseRecordset(Rs)

                Catch e As Exception
                    err.numError = 1
                    err.parse_error_script(e)
                    err.params("retorno_proceso") = -99
                    err.params("mensaje") = ""
                End Try
            End If
        Else
            err.numError = 0
            err.params("retorno_proceso") = -99
            err.params("mensaje") = "Error de permisos"
        End If

        err.response()
    End If

    Me.addPermisoGrupo("permisos_cuentas")
%>
<html>
<head>
    <title>ABM Cuentas Bancarias</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <%--<script type="text/javascript" src="/FW/script/tCampo_head.js"></script>--%>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var win
        var nro_docu
        var tipo_docu
        var sexo
        var isModal
        var modo
        var idcheck_sel
        var BuscarEnPadron = false;
        var returnValue;
        var cuit = ''
        var id_tipo = <% = id_tipo %>
        var nro_ent_id_tipo = <% = nro_ent_id_tipo %>


            function validarCUIT(strCUIT) {
                // Determina si el dígito verificador es correcto
                // @return: 
                //      true si es correcto
                //      false si es incorrecto
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


        function digitoVerificador(S) {
            var v2 = 0;
            var v3 = 0;

            S = S.toString()
            v2 = (parseInt(S.substr(0, 1)) * 5 + parseInt(S.substr(1, 1)) * 4 + parseInt(S.substr(2, 1)) * 3 + parseInt(S.substr(3, 1)) * 2 + parseInt(S.substr(4, 1)) * 7 + parseInt(S.substr(5, 1)) * 6 + parseInt(S.substr(6, 1)) * 5 + parseInt(S.substr(7, 1)) * 4 + parseInt(S.substr(8, 1)) * 3 + parseInt(S.substr(9, 1)) * 2);
            v2 = v2 - (Math.floor(v2 / 11) * 11)
            v3 = 11 - v2;

            //switch (v3) {
            //    case 11: v3 = 0; break;
            //}
            if (v3 == 11) v3 = 0

            return v3
        }


        function validarCBU1(cbu) {
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
        }


        // Evaluar el error devuelto por actualizar return
        function evaluar_error(err, transport) {
            var error = err.numError
            var retorno_proceso = (err.params['retorno_proceso'] != '') ? parseInt(err.params['retorno_proceso']) : 0
            var mensaje = err.params['mensaje']

            if (parseInt(error) == 0) {
                if (retorno_proceso < 0) {
                    alert(mensaje)
                    return
                }

                a["nro_docu"] = $F('nro_docu')
                a["tipo_docu"] = $F('tipo_docu')
                a["sexo"] = $F('sexo')
                a["id_cuenta"] = $F('id_cuenta')
                a["nro_entidad"] = $F('nro_entidad')
                a["id_cuenta_old"] = $F('id_cuenta_old')

                var id_cuenta = retorno_proceso
                var nro_entidad = $F('nro_entidad')
                var modo = $F('modo')



                // Si es baja => resetear todo
                if (modo == 'B') {
                    btnNueva_Cuenta()
                }

                // Si acabo de enviar un alta => queda como modificado
                if (modo == 'A') {
                    $('modo').value = 'M'
                    CargarCuentas(id_cuenta, nro_entidad)
                }
            }
            else {
                switch (error) {
                    case 1:
                        strError = 'Error en la actualización de datos. Consulte con el Adminstrador de Sistemas.'
                        break

                    case 2:
                        strError = 'No posee permisos para realizar esta acción. Consulte con el Administrador de Sistemas'
                        break
                }

                alert(strError)
                return
            }
        }


        function window_onload() {
            var strError = ''
            var a = []
            var e
            inicializar_componentes();
        }


        function inicializar_componentes() {
            //campos_defs.add('cuit', { enDB: false, target: 'tdcuit', nro_campo_tipo: 100 });

            //Event.observe('cuit', 'blur', function (event) {
            //    var cuit = $F('cuit')

            //    if (cuit != '') {
            //        if (!validarCUIT(cuit)) {
            //            alert('El cuit puede ser erroneo')
            //        }
            //    }
            //});

            try {
                var id_cuenta = ('<% = id_cuenta %>' == '') ? 0 : parseInt('<% = id_cuenta %>')
                var nro_entidad = ('<% = nro_entidad %>' == '') ? 0 : parseInt('<% = nro_entidad %>')

                $('id_cuenta_old').value = id_cuenta

                // Recuperar datos persona
                if (nro_entidad != 0) {
                    $('nro_entidad').value = nro_entidad
                    $('modo').value = 'A'
                    $('id_cuenta').value = 0
                    var rs = new tRS();
                    cuit = ''

                    //rs.open("<criterio><select vista='Personas'><campos>nro_docu,tipo_docu,sexo,cuit</campos><filtro><nro_entidad type='igual'>" + nro_entidad + "</nro_entidad></filtro><orden></orden></select></criterio>")
                    rs.open({
                        filtroXML: nvFW.pageContents.filtro_personaFisica,
                        params: "<criterio><params nro_entidad='" + nro_entidad + "' /></criterio>"
                    })

                    if (!rs.eof()) {
                        $('nro_docu').value = rs.getdata('nro_docu')
                        $('tipo_docu').value = rs.getdata('tipo_docu')
                        $('sexo').value = rs.getdata('sexo')
                        //cuit                 = rs.getdata('cuit')
                        //campos_defs.set_value('cuit', cuit)
                    }
                }
                // Recuperar nro_entidad
                else {
                    var nrodocu = parseInt(('<% = nro_docu %>' == '') ? 0 : '<% = nro_docu %>')
                    var tipodoc = parseInt(('<% = tipo_docu %>' == '') ? 0 : '<% = tipo_docu %>')
                    var sex = '<% = sexo %>'

                    $('nro_docu').value = nrodocu
                    $('tipo_docu').value = tipodoc
                    $('sexo').value = sex
                    $('modo').value = 'M'

                    var rs = new tRS();
                    //cuit = ''

                    //rs.open({
                    //    filtroXML: nvFW.pageContents.filtro_personas, 
                    //    filtroWhere: "<nro_docu type='igual'>" + nrodocu + "</nro_docu><tipo_docu type='igual'>" + tipodoc + "</tipo_docu><sexo type='igual'>'" + sex + "'</sexo>"
                    //})

                    //if (!rs.eof()) {
                    //    $('nro_entidad').value = rs.getdata('nro_entidad')
                    //    cuit                   = rs.getdata('cuit')
                    //    campos_defs.set_value('cuit', cuit)
                    //}

                    if ($('id_cuenta_old').value == 'undefined' || $('id_cuenta_old').value == '-1' || $('id_cuenta_old').value == '' || $('id_cuenta_old').value == '0') {
                        $('modo').value = 'A'
                    }
                    else {
                        // Recuperar id_cuenta de entidad_ctas
                        $('modo').value = 'M'
                        var rs = new tRS();

                        rs.open({
                            filtroXML: nvFW.pageContents.filtro_entidadCtas,
                            filtroWhere: "<id_cuenta_old type='igual'>" + $F('id_cuenta_old') + "</id_cuenta_old>"
                        })

                        if (!rs.eof()) {
                            $('id_cuenta').value = rs.getdata('id_cuenta')
                        }
                    }
                }

                $('ctl_monto_max_dto').value = false
                $('ctl_denominacion').value = false
                CargarCuentas($F('id_cuenta'), $F('nro_entidad'))
            }
            catch (e) { }
        } // Fin de inicializar componentes


        function CargarCuentas(id_cuenta, nro_entidad) {
            $('id_cuenta').value = id_cuenta;
            Cuentas = []
            var i = 0
            var j = 0

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_entidad,
                filtroWhere: "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad>",
                //xsl_name:           "HTML_persona_cuentas.xsl",
                path_xsl: "report/funciones/HTML_persona_cuentas.xsl",
                formTarget: 'frame_listado',
                nvFW_mantener_origen: true,
                //async:                false,
                id_exp_origen: 0,
                bloq_contenedor: $('frame_listado'),
                cls_contenedor: 'frame_listado',
                cls_contenedor_msg: ' ',
                bloq_msg: 'Cargando...'
            });

            if (id_cuenta != 0) {
                CargarDatos(id_cuenta)
            }
        }


        function CargarDatos(id_cuenta) {
            var rs = new tRS();
            var nro_cuenta = ''
            var cbu = ''
            var alias = ''
            var tipo_cuenta = ''
            var nro_banco = ''
            var id_banco_sucursal = ''
            var monto_max_dto = ''
            var descripcion = ''
            var denominacion = ''
            var nro_entidad = ''

            rs.open({
                filtroXML: nvFW.pageContents.filtro_bco_cuentas,
                filtroWhere: "<id_cuenta type='igual'>" + id_cuenta + "</id_cuenta>"
            })

            if (!rs.eof()) {
                tipo_cuenta = rs.getdata('tipo_cuenta')
                nro_entidad = rs.getdata('nro_entidad')

                var cbu = typeof rs.getdata('CBU') != 'undefined' ? rs.getdata('CBU') : ''
                campos_defs.set_value('cbu', cbu)
                nro_cuenta = rs.getdata('nro_cuenta')
                var alias = typeof rs.getdata('alias') != 'undefined' ? rs.getdata('alias') : ''
                campos_defs.set_value('alias', alias)
                campos_defs.set_value('nro_moneda', rs.getdata('moneda'))


                //$('cuit').value              = rs.getdata('cuit')
                $('id_banco_sucursal').value = rs.getdata('id_banco_sucursal')
                $('banco_sucursal').value = rs.getdata('cod_sucursal') + ' - ' + rs.getdata('banco_sucursal')

                nro_banco = rs.getdata('nro_banco')
                id_banco_sucursal = rs.getdata('id_banco_sucursal')
                monto_max_dto = (rs.getdata('monto_max_dto') == ".0000") ? '0.00' : rs.getdata('monto_max_dto')
                descripcion = rs.getdata('descripcion')
                denominacion = rs.getdata('denominacion')

                if (monto_max_dto) {
                    $('monto_max_dto').value = monto_max_dto
                }

                if (denominacion) {
                    $('denominacion').value = denominacion
                }

                if (descripcion) {
                    $('descripcion').value = descripcion
                }
            }

            if (tipo_cuenta == 0) {
                $('tipo_cuenta').options[0].selected = true
            }

            if (tipo_cuenta == 1) {
                $('tipo_cuenta').options[1].selected = true
            }

            //if (tipo_cuenta == 2) {
            //    $('tipo_cuenta').options[2].selected = true
            //}

            var cta_sueldo = rs.getdata('cta_sueldo')
            var habilitada = rs.getdata('habilitada')

            if (cta_sueldo == 'True') {
                $('cta_sueldo').checked = true;
            }
            else {
                $('cta_sueldo').checked = false;
            }

            if (habilitada == 'True') {
                $('habilitada').checked = true;
            }
            else {
                $('habilitada').checked = false;
            }

            nro_cuenta = nro_cuenta.replace(/ /g, "")
            $('nro_cuenta').value = nro_cuenta
            $('id_cuenta_old').value = rs.getdata('id_cuenta_old')
        }


        function RCuenta_onclick(idck, id_cuenta, id_cuenta_old, nro_banco, id_banco_sucursal) {
            setTimeout(function () {
                nvFW.bloqueo_activar($$("body")[0], "bloq_cuenta", "Cargando datos de Banco...")
            }, 0)

            setTimeout(function () {
                var i
                var e
                idcheck_sel = idck - 1;

                try {
                    i = frame_listado.$('RCuenta' + id_cuenta).value;
                }
                catch (e) {
                    i = 0
                }

                $('modo').value = 'M';
                $('id_cuenta').value = id_cuenta
                $('id_cuenta_old').value = id_cuenta_old

                CargarDatos(id_cuenta)
                campos_defs.set_value("nro_banco_cta", nro_banco)

                nvFW.bloqueo_desactivar(null, "bloq_cuenta")
            }, 100)
        }


        function btnNueva_Cuenta() {
            $('banco_sucursal').value = ''
            $('id_banco_sucursal').value = ''
            $('denominacion').value = ''

            campos_defs.clear()

            $('tipo_cuenta').options[0].selected = true
            $('nro_cuenta').value = ''
            $('descripcion').value = ''
            $('denominacion').disabled = true
            $('chk_denominacion').checked = false
            $('chk_monto_max_dto').checked = false

            Cambio_monto_max_dto()

            $('monto_max_dto').value = ''
            $('modo').value = 'A';

            CargarCuentas(0, $F('nro_entidad'))
            //campos_defs.set_value('cuit', cuit)

            $('habilitada').checked = true

            Selecciona_Cuenta_BD()
        }


        function btnGuardar_Cambios() {
            // Si no hay una cuenta seleccionada, informar y retornar
            if ($F('id_cuenta') == "") {
                alert("<br>Debe seleccionar una cuenta antes de guardar cambios.", { title: "<b>Información</b>" })
                return
            }

            var strError = "";

            // Validar los datos

            if ($F('nro_banco_cta') == "") {
                strError += 'No ha seleccionado el <b>Banco</b><br>';
            }

            if ($F('banco_sucursal') == "") {
                strError += 'No ha cargado la <b>Sucursal</b><br>';
            }

            if ($F('tipo_cuenta') == "") {
                strError += 'No ha cargado el <b>Tipo de Cuenta</b><br>';
            }

            //cuit = $F('cuit').toString()

            //if (cuit == "") {
            //    strError += 'No ha ingresado <b>CUIT</b><br>';
            //}

            //if ($F('nro_cuenta') == "" || ($F('nro_cuenta')) <= 0) {
            //    strError += 'No ha cargado el <b>Nº Cuenta/CBU</b><br>';
            //}

            if (campos_defs.get_value('cbu') == '' && campos_defs.get_value('nro_cuenta') == '')
                strError += 'No ha cargado el <b>CBU/Nº Cuenta</b><br>';
            // VALIDAMOS UN CBU VÁLIDO POR CANTIDAD DE DÍG. -si correspondiera-
            //var cbu = $F('nro_cuenta').toString()
            //var cbu = $F('nro_cuenta').toString()
            var cbu = campos_defs.get_value('cbu')

            //if (($F('tipo_cuenta') == 2) && (cbu.length != 22)) {
            //    strError += 'La cantidad de dígitos del CBU no concuerda!<br>'
            //}
            if (cbu != '' && (cbu.length != 22)) {
                strError += 'La cantidad de dígitos del CBU no concuerda!<br>'
            }

            if (campos_defs.get_value('nro_moneda') == '') {
                strError += 'No ha seleccionado el <b>Tipo de Moneda</b><br>'
            }

            // VALIDAMOS EL CBU CON EL ALGORITMO VERIFICADOR - PVUTILES
            //if (($F('tipo_cuenta') == 2) && (strError == '')) {
            //    if (validarCBU1(cbu) == false) {
            //        strError += 'El CBU no fue validado por la verificación!<br>'
            //    }
            if (cbu != '' && validarCBU1(cbu) == false) {
                strError += 'El CBU no fue validado por la verificación!<br>'
            }

            if (strError != '') {
                alert(strError, { title: "<b>Información</b>" })
                return
            }
            else {
                var modo = $F('modo')
                modo = (modo == 'VA') ? 'A' : modo;

                switch (modo) {
                    case 'A':
                        //if ((permisos_cuentas & 1) > 0) {
                        if (nvFW.tienePermiso("permisos_cuentas", 1)) { // "permisos_cuentas" => 1: Alta cuenta

                            var strHTML = '¿Desea dar de Alta una Nueva Cuenta?'

                            nvFW.confirm(strHTML, {
                                width: 300,
                                okLabel: "Guardar",
                                cancelLabel: "Cancelar",
                                cancel: function (win) {
                                    win.close();
                                    return
                                },
                                ok: function (win) {
                                    enviar_datos()
                                    win.close()
                                }
                            });
                        }
                        else {
                            alert('No posee los permisos necesarios para realizar esta Acción. Consulte al Administrador del Sistema.')
                            return
                        }
                        break

                    case 'M':
                        //if ((permisos_cuentas & 2) > 0) {
                        if (nvFW.tienePermiso("permisos_cuentas", 2)) { // "permisos_cuentas" => 2: Modificar cuenta

                            var strHTML = '¿Desea Modificar la Cuenta?'

                            nvFW.confirm(strHTML, {
                                width: 400,
                                okLabel: "Modificar",
                                cancelLabel: "Cancelar",
                                cancel: function (win) {
                                    win.close();
                                    return
                                },
                                ok: function (win) {
                                    var rs = new tRS();
                                    rs.open({
                                        filtroXML: nvFW.pageContents.filtro_credito_cobro,
                                        filtroWhere: "<ID_cuenta type='igual'>" + $F('id_cuenta_old') + "</ID_cuenta>"
                                    })

                                    if (!rs.eof()) {
                                        if (validarHabilitar()) {
                                            var strHTML = 'Se va a deshablilitar/habilitar una cuenta asociada a un crédito. Desea continuar?'

                                            nvFW.confirm(strHTML, {
                                                width: 300,
                                                okLabel: "Continuar",
                                                cancelLabel: "Cancelar",
                                                cancel: function (win) {
                                                    win.close();
                                                    return
                                                },
                                                ok: function (win) {
                                                    enviar_datos()
                                                    win.close()
                                                }
                                            });
                                        }
                                        else {
                                            var msj = 'La cuenta posee créditos asociados'

                                            if (interbanking_habilitada()) {
                                                msj += ' y se encuentra habilitada en Interbanking'
                                            }

                                            msj += '. No puede modificarse'

                                            alert(msj)
                                            win.close()
                                        }
                                    }
                                    else {
                                        enviar_datos()
                                    }

                                    win.close()
                                }
                            });
                        }
                        else {
                            alert('No posee los permisos necesarios para realizar esta Acción. Consulte al Administrador del Sistema.')
                            return
                        }

                        break
                }
            }
        }


        function validarHabilitar() {
            var cambio_habilitar = false
            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.filtro_bco_cuentas,
                filtroWhere: "<id_cuenta type='igual'>" + $F('id_cuenta') + "</id_cuenta>"
            })

            if (!rs.eof()) {
                var cta_sueldo = rs.getdata('cta_sueldo') == 'True' ? true : false
                var habilitada = rs.getdata('habilitada') == 'True' ? true : false
                var monto_max_dto = ((rs.getdata('monto_max_dto') == ".0000") || (rs.getdata('monto_max_dto') == null)) ? '0.00' : rs.getdata('monto_max_dto')
                var denominacion = rs.getdata('denominacion') == null ? '' : rs.getdata('denominacion')

                if ($('monto_max_dto').value == '' && monto_max_dto == '0.00') {
                    monto_max_dto = ''
                }

                if (($('tipo_cuenta').value != rs.getdata('tipo_cuenta')) ||
                    (campos_defs.get_value('nro_banco_cta') != rs.getdata('nro_banco')) ||
                    ($('id_banco_sucursal').value != rs.getdata('id_banco_sucursal')) ||
                    ($('nro_cuenta').value != rs.getdata('nro_cuenta')) ||
                    ($('denominacion').value != denominacion) ||
                    ($('monto_max_dto').value != monto_max_dto) ||
                    ($('descripcion').value != rs.getdata('descripcion')) ||
                    (campos_defs.get_value('cuit') != rs.getdata('cuit')) ||
                    ($('cta_sueldo').checked != cta_sueldo)) {
                    cambio_habilitar = false
                }
                else if ($('habilitada').checked != habilitada) {
                    cambio_habilitar = true
                }
            }

            return cambio_habilitar
        }


        function interbanking_habilitada() {
            var habilitada = false
            var rs = new tRS();

            rs.open({
                filtroXML: nvFW.pageContents.filtro_interb_ctas,
                filtroWhere: "<id_cuenta type='igual'>" + $F('id_cuenta') + "</id_cuenta>"
            })

            if (!rs.eof()) {
                habilitada = true
            }

            return habilitada
        }


        function btnEliminar_Cuenta() {
            if ($F('id_cuenta') == '' || !$F('id_cuenta')) {
                alert('Seleccione la cuenta a eliminar.')
                return
            }
            else {
                //if ((permisos_cuentas & 4) > 0) {
                if (nvFW.tienePermiso("permisos_cuentas", 3)) { // "permisos_cuentas" => 3: Eliminar cuenta

                    var id_cuenta_old = $F('id_cuenta_old')
                    var strHTML = '¿Desea Eliminar la cuenta Seleccionada?'

                    nvFW.confirm(strHTML, {
                        width: 300,
                        okLabel: "Eliminar",
                        cancelLabel: "Cancelar",
                        cancel: function (win) {
                            win.close();
                            return
                        },
                        ok: function (win) {
                            var rs = new tRS();
                            rs.open({
                                filtroXML: nvFW.pageContents.filtro_credito_cobro,
                                filtroWhere: "<ID_cuenta type='igual'>" + id_cuenta_old + "</ID_cuenta>"
                            })

                            if (!rs.eof()) {
                                alert('La cuenta no se puede eliminar ya que tiene uno o varios créditos asociados.')
                                win.close()
                                return
                            }

                            $('modo').value = 'B'
                            enviar_datos()
                            win.close()
                        }
                    });
                }
                else {
                    alert('No posee los permisos necesarios para realizar esta Acción. Consulte al Administrador del Sistema.')
                    return
                }
            }
        }


        function enviar_datos() {
            var strxml = "";
            var nro_banco = $F('nro_banco_cta')
            var id_cuenta = $F('id_cuenta')
            var id_cuenta_old = $F('id_cuenta_old')
            var nro_entidad = $F('nro_entidad')
            var nro_cuenta = $F('nro_cuenta')
            var denominacion = $F('denominacion')
            var descripcion = $F('descripcion')
            var ctl_monto_max_dto = $F('ctl_monto_max_dto')
            var ctl_denominacion = $F('ctl_denominacion')
            var id_banco_sucursal = $F('id_banco_sucursal')
            var tipo_cuenta = $F('tipo_cuenta')
            var nro_docu = $F('nro_docu')
            var tipo_docu = $F('tipo_docu')
            var cta_sueldo = ($('cta_sueldo').checked) ? 1 : 0
            var habilitada = ($('habilitada').checked) ? 1 : 0
            var sexo = $F('sexo')
            var monto_max_dto = $F('monto_max_dto');
            //cuit                  = $F('cuit')
            modo = $F('modo')
            var nro_moneda = campos_defs.get_value('nro_moneda')

            strxml += "<abm_cuenta nro_banco = '" + nro_banco + "'  ";
            strxml += " id_cuenta='" + id_cuenta + "' id_cuenta_old='" + id_cuenta_old + "' nro_entidad='" + nro_entidad + "' ";
            strxml += " nro_cuenta='" + nro_cuenta + "' denominacion='" + denominacion + "' descripcion='" + descripcion + "' ";
            strxml += " ctl_monto_max_dto='" + ctl_monto_max_dto + "' ctl_denominacion='" + ctl_denominacion + "' id_banco_sucursal='" + id_banco_sucursal + "' tipo_cuenta='" + tipo_cuenta + "' nro_docu='" + nro_docu + "' ";
            strxml += " tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' monto_max_dto='" + monto_max_dto + "' cta_sueldo='" + cta_sueldo + "' habilitada='" + habilitada + "' cuit=''";
            strxml += " id_tipo='" + id_tipo + "' nro_ent_id_tipo='" + nro_ent_id_tipo + "'";
            strxml += " moneda='" + nro_moneda + "' cbu='" + campos_defs.get_value('cbu') + "' alias='" + campos_defs.get_value('alias') + "'"
            strxml += "></abm_cuenta>";

            nvFW.error_ajax_request('CuentaBanco_ABM.aspx', {
                parameters: {
                    modo: modo,
                    strxml: strxml
                },
                onSuccess: function (err, transport) {
                    evaluar_error(err, transport)
                }
            });
        }


        function Cambio_monto_max_dto() {
            if ($('chk_monto_max_dto').checked) {
                //if ((permisos_cuentas & 8)) {
                if (nvFW.tienePermiso("permisos_cuentas", 4)) { // "permisos_cuentas" => 4: Modificar monto máximo
                    $('monto_max_dto').disabled = false
                    $('ctl_monto_max_dto').value = true
                }
            }
            else {
                $('monto_max_dto').disabled = true
                $('ctl_monto_max_dto').value = false
            }
        }


        function Cambio_denominacion() {
            if ($('chk_denominacion').checked) {
                //if ((permisos_cuentas & 16)) {
                if (nvFW.tienePermiso("permisos_cuentas", 5)) { // "permisos_cuentas" => 5: Modificar denominación
                    $('denominacion').disabled = false
                    $('ctl_denominacion').value = true
                }
            }
            else {
                $('denominacion').disabled = true
                $('ctl_denominacion').value = false
            }
        }

        function actualizar_start() {
            nvFW.bloqueo_activar($(document.body), 'guardar')
        }

        function actualizar_return(transport) {
            var oXML = new tXML();

            oXML.loadXML(transport.responseText)
            objXML = oXML.xml

            var numError = parseInt(objXML.selectSingleNode('error_mensajes/error_mensaje/@numError').value)
            var descripcion = XMLText(selectSingleNode('error_mensajes/error_mensaje/mensaje', objXML))

            if (numError == 0) {
                window.setTimeout("nvFW.bloqueo_desactivar(null, 'guardar')", 1000)
            }
            else {
                nvFW.bloqueo_desactivar($(document.body), 'guardar')

                nvFW.alert(numError + ' - ' + descripcion, {
                    width: 300,
                    height: 100,
                    okLabel: "cerrar",
                    onOk: ver
                })
            }
        }

        function mostrar_rel_interbanking(id_cuenta) {
            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.filtro_entidad_interb_ctas,
                filtroWhere: "<id_cuenta type='igual'>" + id_cuenta + "</id_cuenta>"
            })

            var str_mensaje = ''
            var interb_estado = ''
            var interb_estado_desc = ''
            var interb_empresa = ''

            while (!rs.eof()) {
                interb_estado = rs.getdata('interb_estado')
                interb_estado_desc = rs.getdata('interb_estado_desc')
                interb_empresa = rs.getdata('interb_empresa')

                str_mensaje += 'Estado: <b>' + interb_estado_desc + '</b><br/>'

                if (interb_estado > 0) {
                    str_mensaje += 'Empresa: <b>' + interb_empresa + '</b>'
                }

                str_mensaje += '<br/>'
                rs.movenext()
            }

            alert(str_mensaje, { title: "<b>Interbanking</b>", width: 300 })
        }

        var ParamBco = {}

        function Seleccionar_Sucursal() {
            //var nro_banco = campos_defs.items['nro_banco_cta']["input_hidden"].value
            var nro_banco = campos_defs.get_value('nro_banco_cta')

            if (nro_banco == '') {
                alert("Debe seleccionar una cuenta antes de elegir una sucursal.")
                return
            }
            else {
                ParamBco['nro_banco'] = nro_banco

                var win_suc = nvFW.createWindow({
                    title: '<b>Seleccione Sucursal</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    resizable: false,
                    width: 550,
                    height: 200,
                    destroyOnClose: true,
                    onClose: function (win_suc) {
                        if (win_suc.options.userData == null) return;

                        var retorno = win_suc.options.userData.Parametros_sel

                        if (retorno != undefined) {
                            if (retorno['id_banco_sucursal'] != undefined) {
                                var id_banco_sucursal = retorno['id_banco_sucursal']
                                var cod_sucursal = retorno['cod_sucursal']
                                var banco_sucursal = retorno['banco_sucursal']

                                $('banco_sucursal').value = cod_sucursal + " - " + banco_sucursal;
                                $('id_banco_sucursal').value = id_banco_sucursal;
                            }
                        }
                    }
                });

                win_suc.setURL('/FW/funciones/SeleccionarBanco_sucursal.aspx')
                win_suc.options.userData = { ParamBco: ParamBco }
                win_suc.showCenter(true)
            }
        }


        function Selecciona_Cuenta_BD() {
            var rs = new tRS();
            rs.open({
                filtroXML: nvFW.pageContents.filtro_DBCuenta,
                filtroWhere: "<nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"
            })

            if (!rs.eof()) {
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW

                win = w.createWindow({
                    title: '<b>Seleccionar Cuenta</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 800,
                    height: 200,
                    resizable: false,
                    destroyOnClose: true,
                    onClose: Selecciona_Cuenta_BD_retorno
                });

                win.setURL('/meridiano/SeleccionarCuenta_BD.aspx?nro_docu=' + $('nro_docu').value)
                win.showCenter(true)
            }
        }


        function Selecciona_Cuenta_BD_retorno() {
            if (!win.options.userData) {
                return
            }
            else {
                var objRetorno = win.options.userData.Parametros_sel
                var rs = new tRS();

                rs.open({
                    filtroXML: nvFW.pageContents.filtro_entidad_bco_cuentas,
                    filtroWhere: "<CBU type='igual'>'" + objRetorno['nro_cuenta'] + "'</CBU>"
                })

                if (!rs.eof()) {
                    alert('La persona ya posee la cuenta seleccionada.</br>Verificar.')
                    return
                }

                campos_defs.set_value("nro_banco_cta", objRetorno['nro_banco'])

                rs = new tRS();

                rs.open({
                    filtroXML: nvFW.pageContents.filtro_banco_sucursal,
                    filtroWhere: "<nro_banco type='igual'>" + campos_defs.value('nro_banco_cta') + "</nro_banco><cod_sucursal type='igual'>'999-99'</cod_sucursal>"
                })

                if (!rs.eof()) {
                    $('banco_sucursal').value = rs.getdata("cod_sucursal") + " - " + rs.getdata("Banco_sucursal");
                    $('id_banco_sucursal').value = rs.getdata("id_banco_sucursal");
                }

                $('nro_cuenta').value = objRetorno['nro_cuenta']
                $('tipo_cuenta')[0].selected = true
            }
        }
    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <input type="hidden" id="id_cuenta" name="id_cuenta" value="<% = id_cuenta %>" />
    <input type="hidden" id="id_cuenta_old" name="id_cuenta_old" value="<% = id_cuenta_old %>" />
    <input type="hidden" id="nro_banco" name="nro_banco" value="" />
    <input type="hidden" id="nro_sucursal" name="nro_sucursal" value="" />
    <input type="hidden" id="nro_docu" name="nro_docu" value="<% = nro_docu %>" />
    <input type="hidden" id="tipo_docu" name="tipo_docu" value="<% = tipo_docu %>" />
    <input type="hidden" id="sexo" name="sexo" value="<% = sexo %>" />
    <input type="hidden" id="nro_entidad" name="nro_entidad" value="<% = nro_entidad %>" />
    <input type="hidden" id="modo" name="modo" value="<% = modo %>" />
    <input type="hidden" id="ctl_monto_max_dto" name="ctl_monto_max_dto" value="" />
    <input type="hidden" id="ctl_denominacion" name="ctl_denominacion" value="" />
    <input type="hidden" id="id_banco_sucursal" name="id_banco_sucursal" value="" />

    <div id="divMenuABMCuenta" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuABMCuenta = new tMenu('divMenuABMCuenta', 'vMenuABMCuenta');
        Menus["vMenuABMCuenta"] = vMenuABMCuenta
        Menus["vMenuABMCuenta"].alineacion = 'centro';
        Menus["vMenuABMCuenta"].estilo = 'A';

        vMenuABMCuenta.loadImage("punto", "/FW/image/tTree/punto.jpg");
        vMenuABMCuenta.loadImage("eliminar", "/FW/image/icons/eliminar.png");
        vMenuABMCuenta.loadImage("cuenta_mas", "/FW/image/icons/nueva.png");
        vMenuABMCuenta.loadImage("guardar", "/FW/image/icons/guardar.png");

        //  Menus["vMenuABMCuenta"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 14px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
        Menus["vMenuABMCuenta"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Cuentas Bancarias</Desc></MenuItem>")
        Menus["vMenuABMCuenta"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEliminar_Cuenta()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABMCuenta"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>cuenta_mas</icono><Desc>Nueva cuenta</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnNueva_Cuenta()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABMCuenta"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGuardar_Cambios()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuABMCuenta.MostrarMenu()
    </script>

    <table class="tb1" cellspacing="0" cellpadding="0">
        <tr>
            <%--<td style="width: 15px">&nbsp</td>--%>
            <td style="width: 100%;">
                <iframe name="frame_listado" id="frame_listado" src="/FW/enBlanco.htm" style="width: 100%; height: 210px; overflow-y: auto;" frameborder='0'></iframe>
            </td>
        </tr>
    </table>

    <div id="divMenuDatosCuenta" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuDatosCuenta = new tMenu('divMenuDatosCuenta', 'vMenuDatosCuenta');

        Menus["vMenuDatosCuenta"] = vMenuDatosCuenta
        Menus["vMenuDatosCuenta"].alineacion = 'centro';
        Menus["vMenuDatosCuenta"].estilo = 'A';

        vMenuDatosCuenta.loadImage("punto", "/FW/image/tTree/punto.jpg");

        //Menus["vMenuDatosCuenta"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 14px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>punto</icono><Desc></Desc></MenuItem>")
        Menus["vMenuDatosCuenta"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos Cuenta Bancaria</Desc></MenuItem>")

        vMenuDatosCuenta.MostrarMenu()
    </script>

    <table class="tb1" cellspacing="0" cellpadding="0">
        <tr>
            <%--<td style="width: 15px">&nbsp;</td>--%>
            <td style="width: 100%;">

                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 10%">T. Cuenta</td>
                        <td style="width: 45%">Banco</td>
                        <td style="width: 45%">Sucursal</td>
                    </tr>
                    <tr>
                        <td>
                            <select name="tipo_cuenta" id="tipo_cuenta" style="width: 100%">
                                <option value="0" selected>CA</option>
                                <option value="1">CC</option>
                                <%--<option value="2" selected="selected">CBU</option>--%>
                            </select>
                        </td>
                        <td>
                            <% = nvFW.nvCampo_def.get_html_input("nro_banco_cta") %>
                        </td>
                        <td id="td_sucursal">
                            <input type="text" id="banco_sucursal" name="banco_sucursal" value="" style="width: 95%;" ondblclick="return Seleccionar_Sucursal()" readonly />
                            <img alt="Buscar sucursal" src="/FW/image/campo_def/buscar.png" style="cursor: pointer; vertical-align: middle;" onclick="return Seleccionar_Sucursal()" title="Seleccionar sucursal" />
                            <%--<input type="button" value="..." onclick="return Seleccionar_Sucursal()" style="cursor: pointer;" title="Seleccionar sucursal" />--%>
                        </td>
                    </tr>
                </table>

                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 35%">CBU</td>
                        <td style="width: 35%" colspan="2">Nº cuenta</td>
                        <td style="width: 30%">Alias</td>
                    </tr>
                    <tr>
                        <td>
                            <script>
                                campos_defs.add('cbu', {
                                    enDB: false,
                                    nro_campo_tipo: 100
                                });
                            </script>
                            <%--<input name="nro_cuenta" id="cbu" style="width: 100%;" onkeypress='return valDigito(event)' />--%>
                        </td>
                        <td colspan="2">
                            <script>
                                campos_defs.add('nro_cuenta', {
                                    enDB: false,
                                    nro_campo_tipo: 104
                                });
                            </script>
                            <%--<input name="nro_cuenta" id="nro_cuenta" style="width: 100%;" onkeypress='return valDigito(event)' />--%>
                        </td>
                        <td>
                            <script>
                                campos_defs.add('alias', {
                                    enDB: false,
                                    nro_campo_tipo: 104
                                });
                            </script>
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td style="width: 35%">Moneda</td>
                        <td style="width: 35%" colspan="2">Denominación</td>
                        <td colspan="2" nowrap>Monto Max. Débito</td>
                    </tr>
                    <tr>
                        <td style="width: 35%">
                            <script>
                                campos_defs.add('nro_moneda')
                            </script>
                        </td>
                        <td colspan="2" style="width: 35%" nowrap>
                            <input name="denominacion" id="denominacion" style="width: 95%" disabled />
                            <input type="checkbox" name="chk_denominacion" id="chk_denominacion" onclick='return Cambio_denominacion()' style="border: none; margin: 0; vertical-align: middle;" />
                        </td>
                        <td nowrap>
                            <input name="monto_max_dto" id="monto_max_dto" style="width: 93%" disabled onkeypress="return valDigito(event, '#0.00')" onchange="return validarNumero(event, '#0.00')" />
                            <input type="checkbox" name="chk_monto_max_dto" id="chk_monto_max_dto" onclick='return Cambio_monto_max_dto()' style="border: none; margin: 0; vertical-align: middle;" />
                        </td>
                    </tr>
                    <tr class="tbLabel">
                        <td>Descripción</td>
                        <td>Cta. Sueldo</td>
                        <td>Habilitada</td>
                    </tr>
                    <tr>
                        <td>
                            <input name="descripcion" id="descripcion" style="width: 100%;" type="text" /></td>
                        <td style="text-align: center; width: 15%">
                            <input type="checkbox" name="cta_sueldo" id="cta_sueldo" />
                        </td>
                        <td style="text-align: center; width: 15%">
                            <input type="checkbox" name="habilitada" id="habilitada" />
                        </td>
                    </tr>
                </table>

                <table class="tb1">
                    <tr>
                        <td style="width: 33.3333%">
                            <div id="divEliminar_Cuenta" style="display: inline"></div>
                        </td>
                        <td style="width: 33.3333%">
                            <div id="divNueva_Cuenta"></div>
                        </td>
                        <td style="width: 33.3333%">
                            <div id="divAceptar"></div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
