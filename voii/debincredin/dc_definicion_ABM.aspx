<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<% 
    Dim xml = nvFW.nvUtiles.obtenerValor("xml", "")
    Dim err = New nvFW.tError()


    If xml <> "" Then
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "dc_mov_def_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = xml.Length
            Cmd.Parameters("@strXML").value = xml

            Dim rs = Cmd.Execute()

            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.params("nro_dc_mov_def") = rs.Fields("nro_dc_mov_def").Value


        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del parametro"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.contents("monedaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='moneda'><campos>ISO_num as id, ISO_cod as campo</campos><filtro><activo type='igual'>1</activo></filtro><orden>campo</orden></select></criterio>")
    Me.contents("tipoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_mov_tipos'><campos>dc_mov_tipo as id, dc_mov_tipo_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("bancoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>nro_bcra as id, bcra_desc as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("tipoCtaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_cuentas_tipo'><campos>nro_dc_tipo_cta as id, desc_dc_tipo_cta as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("cuentaDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_cuentas'><campos>id_tipo as id, CBU as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("seleccionEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidad_ctas'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("conceptoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_conceptos'><campos>id_dc_concepto as id, dc_concepto as campo</campos><filtro></filtro></select></criterio>")
    Me.contents("bancos_bcra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='bancos_bcra'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("tipo_cta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='dc_cuentas_tipo'><campos>*</campos><filtro></filtro></select></criterio>")
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nueva Definición</title>
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
        var win = nvFW.getMyWindow()

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Validar";
        vButtonItems[0]["etiqueta"] = "Validar CBU";
        vButtonItems[0]["imagen"] = "confirmar";
        vButtonItems[0]["onclick"] = "return validar()";

        var vListButton = new tListButton(vButtonItems, 'vListButton')
        vListButton.loadImage("confirmar", "/fw/image/icons/confirmar.png")

        function window_onresize()
        {

        }

        function window_onload()
        {
            vListButton.MostrarListButton()
            if (win.options.userData.id != 0) {
                editar(win.options.userData.id)
            } else {
                nuevo()
            }

            if (win.options.userData.activo == 0) {

            }
        }

        function validar() {
            var cbu = $('cbu').value.replace('#', '')
            if (cbu != '') {
                if (cbu.length != 22) {
                    alert("Ingrese un CBU valido de veintidós digitos")
                    return
                }
            }

            error_ajax_request("dc_acciones.aspx", {
                parameters: {
                    accion: 'CCBUALIAS',
                    id: $('cbu').value
                },
                onSuccess: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    if (err.params.tit_cuit != 'null') {
                        $('cuit').value = err.params.tit_cuit
                        $('cbu').value = err.params.cbu
                        $('sucursal').value = err.params.cbu.substr(3, 4)
                        $('razon_social').value = err.params.tit_razon_social
                        campos_defs.habilitar('banco', true)
                        campos_defs.habilitar('tipoCta', true)
                        campos_defs.set_value("banco", err.params.cu_nro_bcra)
                        campos_defs.set_value("tipoCta", err.params.cu_tipo_cta)
                        campos_defs.habilitar('banco', false)
                        campos_defs.habilitar('tipoCta', false)

                    } else {
                        alert('El CBU/ALIAS no existe')
                    }
                },
                onFailure: function (err, transport) {
                    console.log(err)
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

        function guardar() {

            

            if ($('cbu').value == '') {
                alert("Ingrese un CBU y validelo")
                return
            }

            if ($('razon_social').value == '') {
                alert("Debe validar el CBU")
                return
            }

            if ($('nro_moneda').value == '') {
                alert("Especifique la moneda")
                return
            }

            if ($('tipoCta').value == '') {
                alert("Especifique el tipo de cuenta")
                return
            }

            if ($('tiempoExpiracion').value == '') {
                alert("Especifique el tiempo de expiración")
                return
            }

            if ($('descripcion').value == '') {
                alert("Ingrese una descripción")
                return
            }

            if ($('concepto').value == '') {
                alert("Especifique una concepto")
                return
            }

            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xml += "<dc_mov_def>"
            xml += "<nro_dc_mov_def>" + $('nro_dc_mov_def').value + "</nro_dc_mov_def>"
            xml += "<mov_dc_def_desc>" + '<![CDATA[' + $('descripcion').value + ']]>' + "</mov_dc_def_desc>"
            xml += "<dc_mov_tipo>" + $('tipo').value + "</dc_mov_tipo>"
            xml += "<nro_banco_bcra>" + $('banco').value  + "</nro_banco_bcra>" 
            xml += "<nro_sucursal>" + $('sucursal').value  + "</nro_sucursal>"
            xml += "<cuitcuil>" + $('cuit').value  + "</cuitcuil>"
            xml += "<cbu>" + $('cbu').value  + "</cbu>"
            xml += "<moneda>" + $('nro_moneda').value  + "</moneda>"
            xml += "<tiempoExpiracion>" + $('tiempoExpiracion').value  + "</tiempoExpiracion>"
            xml += "<razon_social>" + '<![CDATA[' + $('razon_social').value + ']]>' + "</razon_social>"
            xml += "<id_dc_concepto>" + $('concepto').value  + "</id_dc_concepto>"
            xml += "<nro_dc_tipo_cta>" + $('tipoCta').value  + "</nro_dc_tipo_cta>"
            xml += "<activo>" + $('activo').value + "</activo>"
            xml += "</dc_mov_def>"


            error_ajax_request("dc_definicion_ABM.aspx",
                {
                    parameters: {
                        xml: xml
                    },
                    onSuccess: function (err, parametros) {

                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }

                        parent.buscar()
                        //win.refresh()

                        //win.close()
                    },
                    onFailure: function (err, parametros) {

                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                    },
                    bloq_msg: 'INICIANDO...',
                    error_alert: false
                })
        }

        function mostrar_entidades(frame, nro) {
            var filtroWhere = "<criterio><select><filtro><nro_def_archivo type='igual'>" + nro + "</nro_def_archivo></filtro></select></criterio>"
            var filtroXMLd = nvFW.pageContents.seleccionCuentas

            nvFW.exportarReporte({
                filtroXML: filtroXMLd,
                filtroWhere: filtroWhere,
                path_xsl: 'report\\archivo\\HTML_control_digital_archivos_legajo_ent.xsl',
                formTarget: 'entidades' + nro,
                nvFW_mantener_origen: true,
                id_exp_origen: 0,
                cls_contenedor: 'entidades' + nro
            })
        }

        function definirDebito(cuit, cbu, razonSocial) {
            $('cuit').value = cuit
            $('cbu').value = cbu
            $('razonSocial').value = razonSocial
            campos_defs.set_value('banco', )
        }

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

        function nuevo() {
            campos_defs.clear('dc_definicion')
            campos_defs.habilitar('dc_definicion', false)
            //$('menuItem_divMenuTit_3').style.display = 'block' 
            //$('menuItem_divMenuTit_2').style.display = 'none' 
            campos_defs.habilitar("nro_moneda", true)
            campos_defs.habilitar("concepto", true)
            campos_defs.habilitar("tipoCta", true)
            campos_defs.habilitar("tipo", true)
            campos_defs.habilitar("cbu", true)
            $('divValidar').style.display = "block"
            $('tabDefinicion').style.display = "none"
        }

        function editar(id) {
            $('nro_dc_mov_def').value = win.options.userData.id
            $('cbu').value = win.options.userData.cbu
            $('razon_social').value = win.options.userData.razonsocial
            $('tiempoExpiracion').value = win.options.userData.exp
            $('descripcion').value = win.options.userData.desc
            $('cuit').value = win.options.userData.cuit
            $('sucursal').value = win.options.userData.sucursal
            campos_defs.habilitar('tipo', true)
            campos_defs.habilitar('banco', true)
            campos_defs.habilitar('tipoCta', true)
            campos_defs.set_value('tipo', win.options.userData.tipo)
            campos_defs.set_value('nro_moneda', win.options.userData.moneda)
            campos_defs.set_value('concepto', win.options.userData.concepto)
            campos_defs.set_value('banco', win.options.userData.nro_bnco)
            campos_defs.set_value('tipoCta', win.options.userData.tip_cta)
            campos_defs.habilitar('banco', false)
            campos_defs.habilitar('tipoCta', false)
            //$('sucursal').value = win.options.userData.nro_bnco
            $('activo').value = win.options.userData.activo
        }

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
        <div id="divMenuTit" style="width: 100%; margin: 0; padding: 0;"></div>
        <script type="text/javascript">
            var vMenuTit = new tMenu('divMenuTit', 'vMenuTit');

            Menus["vMenuTit"] = vMenuTit
            Menus["vMenuTit"].alineacion = 'centro';
            Menus["vMenuTit"].estilo = 'A';

            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='1' style='width: 460px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='0' style='width: 80px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            //Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='2' style='width: 80px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
            //Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='3' style='width: 80px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>editar()</Codigo></Ejecutar></Acciones></MenuItem>")

            //vMenuTit.loadImage("nuevo", "/FW/image/icons/nueva.png");
            //vMenuTit.loadImage("editar", "/FW/image/icons/editar.png");
            vMenuTit.loadImage("guardar", "/FW/image/icons/guardar.png");

            vMenuTit.MostrarMenu()

            $('menuItem_divMenuTit_3').style.display = 'none' 
        </script>
<input type="hidden" id="razon_social" />
<input type="hidden" id="nro_dc_mov_def" value="0"/>
        <table class="tb1" id="tabDefinicion">
        <tr style="display: none">
            <td style="width: 5%" class="Tit1"><b>Definición:</b></td>
            <td style="width:95%">
                    <script type="text/javascript">
                        campos_defs.add('dc_definicion', {
                            enDB: true,
                            json: true,
                            onchange: function (event, campo_def) {
                                var rs_cdef = campos_defs.getRS(campo_def)
                                console.log(rs_cdef)

                                if ($('dc_definicion').value != '') {
                                    $('nro_dc_mov_def').value = rs_cdef.getdata('id')
                                    $('razon_social').value = rs_cdef.getdata('razon_social')
                                    $('descripcion').value = rs_cdef.getdata('campo')
                                    $('sucursal').value = rs_cdef.getdata('nro_sucursal')
                                    $('cuit').value = rs_cdef.getdata('cuitcuil')
                                    $('cbu').value = rs_cdef.getdata('cbu')
                                    $('tiempoExpiracion').value = rs_cdef.getdata('tiempoExpiracion')
                                    campos_defs.habilitar("nro_moneda", true)
                                    campos_defs.habilitar("tipo", true)
                                    campos_defs.habilitar("concepto", true)
                                    campos_defs.habilitar("banco", true)
                                    campos_defs.habilitar("tipoCta", true)
                                    campos_defs.set_value("nro_moneda", rs_cdef.getdata('moneda'))
                                    campos_defs.set_value("banco", rs_cdef.getdata('nro_banco_bcra'))
                                    campos_defs.set_value("concepto", rs_cdef.getdata('id_dc_concepto'))
                                    campos_defs.set_value("tipo", rs_cdef.getdata('dc_mov_tipo'))
                                    campos_defs.set_value("tipoCta", rs_cdef.getdata('nro_dc_tipo_cta'))
                                    //campos_defs.habilitar("nro_moneda", false)
                                    campos_defs.habilitar("banco", false)
                                    campos_defs.habilitar("tipoCta", false)
                                    campos_defs.habilitar("cbu", false)
                                    $('divValidar').style.display = "none"
                                } else {
                                    $('nro_dc_mov_def').value = 0
                                    $('razon_social').value = ''
                                    $('sucursal').value = ''
                                    $('cuit').value = ''
                                    $('cbu').value = ''
                                    $('tiempoExpiracion').value = ''
                                    $('descripcion').value = ''
                                    campos_defs.habilitar("nro_moneda", true)
                                    campos_defs.habilitar("tipo", true)
                                    campos_defs.habilitar("cbu", true)
                                    campos_defs.habilitar("concepto", true)
                                    campos_defs.habilitar("tipoCta", true)
                                    campos_defs.habilitar("banco", true)
                                    campos_defs.clear("tipo")
                                    campos_defs.clear("nro_moneda")
                                    campos_defs.clear("concepto")
                                    campos_defs.clear("banco")
                                    campos_defs.clear("tipoCta")
                                    campos_defs.habilitar("tipo", false)
                                    campos_defs.habilitar("banco", false)
                                    $('divValidar').style.display = "block" 
                                }

                            },
                            nro_campo_tipo: 1
                        })
                        campos_defs.habilitar('dc_definicion', false)
                    </script>
            </td>            
        </tr>
    </table>
<table class="tb1" >
  <tr>
   <td style="width: 93%">
     <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 34px"><b>Tipo:</b></td>
            <td style="width: 95%;">
                <script type="text/javascript">
                    campos_defs.add('tipo', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.tipoDef,
                        nro_campo_tipo: 1
                    })
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1"> 
        <tr>
            <td class="Tit1" style="width: 84px">Descripción:</td>
            <td><input type="text" id="descripcion" style="width: 100%"/></td>
        </tr>
    </table> 
    <table  class="tb1">
         <tr>
            <td style="width: 34px" class="Tit1" id="tit">CBU:</td>
            <td style="width: 95%;" id="tdCbu">
                <script>
                    campos_defs.add('cbu', {
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
            <td style="width: 7%" id="divValidar"></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td  class="Tit1" style="width: 52px">Banco:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('banco', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.bancoDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.habilitar("banco", false)
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td  class="Tit1" style="width: 64px">Sucursal:</td>
            <td><input type="text" id="sucursal"style="width: 100%" disabled/></td>
         </tr>
    </table> 
    <table class="tb1">
        <tr>
            <td class="Tit1" style="width: 44px">CUIT:</td>
            <td><input type="text" id="cuit" style="width: 100%" disabled/></td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width: 90px" class="Tit1">Tipo Cuenta:</td>
            <td style="">
                <script type="text/javascript">
                    campos_defs.add('tipoCta', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.tipoCtaDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.habilitar('tipoCta', false)
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td class="Tit1"  style="width: 64px">Moneda:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_moneda', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.monedaDef,
                        nro_campo_tipo: 1
                    })
                    campos_defs.set_value('nro_moneda', 32)
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width: 72px" class="Tit1">Concepto:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('concepto', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.conceptoDef,
                        nro_campo_tipo: 1
                    })
                </script>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width: 130px" id="expTit" class="Tit1">Tiempo Expiración:</td>
            <td id="tiempoExp" style="">
                <select id="tiempoExpiracion" style="width: 100%" >
                    <option value="24">24 horas</option>
                    <option value="48">48 horas</option>
                    <option value="72">72 horas</option>
                </select>
            </td>
        </tr>
    </table>
    <table class="tb1">
        <tr>
            <td style="width: 55px" class="Tit1">Activo:</td>
            <td style="">
                <select id="activo" style="width: 100%">
                    <option value='1'>Si</option>
                    <option value='0'>No</option>
                </select>
            </td>
        </tr>
    </table>
   </td>
 </tr>
</table>
<br />  
    <iframe name="frmResultados" id="frmResultados" style="width: 100%; height:100%; max-height:508px" frameborder='0'></iframe>
</body>
</html>
