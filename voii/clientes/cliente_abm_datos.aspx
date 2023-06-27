<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    Dim tipdoc As Integer = nvFW.nvUtiles.obtenerValor("tipdoc", 0)
    Dim nrodoc As Long = nvFW.nvUtiles.obtenerValor("nrodoc", 0)


    If tipdoc > 0 And nrodoc > 0 Then
        'Dim op = nvFW.nvApp.getInstance.operador
        'If (Not op.tienePermiso("permisos_entidades", 2)) Then Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos para ver las entidades.")

        Dim campos_tcl As String = "clinom, cliape, clinac, clifecnac, cliestcivcod, clasicod, clifecfall, clinotifall, " +
            "pais_natal, codprov_natal, dptocod_natal, loccod_natal, ofinrodoc, profesion, reltrabajo, sectorfin, titcod, " +
            "clisexo, emancip, profesional, vincbanco, policaexpuesto, criteriomonto, siter, perconcod, " +
            "tipdoc1, nrodoc1, tipdoc2, nrodoc2, tipdoc3, nrodoc3, " +
            "clicondgi, impgancod, residencia, giin, estfatca, impempre, invercalif, perfoper"
        Me.contents("cliXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidad_clientes' cn='BD_IBS_ANEXA'><campos>" + campos_tcl + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro></select></criterio>")

        Dim camposIBS As String = "tipocli, tiporel, tipdoc, tipdoc_desc, nrodoc, CUIT_CUIL, DNI, cliape, clinom, clideno, " +
"fecnac_insc, clisexo, cartel, numtel, razon_social, tipreldesc, domnom, domnro, dompiso, domdepto, codpos, loccoddesc, codprovdesc, " +
"email, clconddgi, descestciv, tipsocdesc, tipoempdesc, policaexpuesto, sectorfindesc, profdesc, impgandesc, perconnom, clasidesc, desctipcar, " +
"ofitipdoc_desc, ofitipdoc, ofinrodoc, ofirazon_social"
        Me.contents("entXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades' cn='BD_IBS_ANEXA'><campos>" + camposIBS + "</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro></select></criterio>")


        'Me.contents("filtro_vinculos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidad_vinculos' cn='BD_IBS_ANEXA'><campos>vinc_razon_social, vinc_tipocli, " +
        '                                             "vinc_tipdoc, vinc_tipdoc_desc, vinc_nrodoc, tipvinclicod, " +
        '                                             "cliclivincod, vincliclinom, tipvinclidesc, clivinfecalta, clivinfecven, vinc_tiporel</campos>" +
        '                                             "<filtro><tipdoc type='igual'>" & tipdoc.ToString & "</tipdoc><nrodoc type='igual'>" & nrodoc.ToString & "</nrodoc></filtro>" +
        '                                             "<orden>vinc_razon_social ASC</orden></select></criterio>")

        'Me.contents("filtroEntidades") = nvXMLSQL.encXMLSQL("<criterio><select vista='entidades'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
        'Me.contents("filtro_nomenclador_documento") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'documento'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")
        'Me.contents("filtro_nomenclador_grupo_vinculo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'grupo_vinculo'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")
        'Me.contents("filtro_nomenclador_tipo_vinculo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_codigos_externos'><campos>cod_interno, cod_externo, desc_externo</campos><filtro><elemento type='igual'>'tipo_vinculo'</elemento><sistema_externo type='igual'>'ibs'</sistema_externo></filtro><orden></orden></select></criterio>")

        'Me.contents("filtro_archivo_leg_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivo_leg_cab'><campos>nro_def_archivo, id_tipo</campos><filtro><nro_archivo_id_tipo type='igual'>2</nro_archivo_id_tipo></filtro><orden></orden></select></criterio>")
        'Me.contents("filtro_archivos_def_cab") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='archivos_def_cab'><campos>nro_def_archivo, def_archivo</campos><filtro></filtro><orden></orden></select></criterio>")

        'Me.contents("entParamsXML") = nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_params'><campos>orden, etiqueta, nro_entidad, param, valor, campo_def, tipo_dato, visible, editable</campos><orden>orden</orden><filtro></filtro></select></criterio>")

        'Me.contents("filtroContactoDomicilio") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", domnom as calle, domnro as numero, dompiso as piso, domdepto as depto, '' as resto, codpos as postal_real, loccoddesc as localidad, codprovdesc as provincia, '' as cpa" +
        '                        "</campos><filtro><sql type='sql'>domnom IS NOT NULL AND domnro IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")
        'Me.contents("filtroContactoTelefono") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", cartel as car_tel, numtel as telefono" +
        '                        "</campos><filtro><sql type='sql'>cartel IS NOT NULL AND numtel IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")
        'Me.contents("filtroContactoEmail") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos' cn='BD_IBS_ANEXA'>" +
        '                        "<campos>'VER' as modo, 'Personal' as desc_contacto_tipo, '' as fecha_estado" +
        '                        ", email, '' as observacion" +
        '                        "</campos><filtro><sql type='sql'>email IS NOT NULL</sql><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")

        'Me.contents("filtroContactoGenerico") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_entidades_Contactos_Generica' cn='BD_IBS_ANEXA'><campos>*</campos><filtro><tipdoc type='igual'>" + tipdoc.ToString + "</tipdoc><nrodoc type='igual'>" + nrodoc.ToString + "</nrodoc></filtro><orden></orden></select></criterio>")

        Me.contents("tipdoc") = tipdoc
        Me.contents("nrodoc") = nrodoc

        'Me.contents("today") = DateTime.Now

    End If
    'Me.addPermisoGrupo("permisos_vinculos")
%>
<!DOCTYPE html>
<html lang="es-ar">
<head>
    <title>Cliente Datos</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/switch.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        body {
            width: 100%;
            height: 100%;
            overflow: auto;
        }
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>

    <script type="text/javascript" src="/FW/script/IMask/imask.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var winEntidad = nvFW.getMyWindow();



        function window_onload()
        {
            CargarDatos()

            window_onresize();
        }


        function window_onresize()
        {
            try
            {
            }
            catch (e) {}
        }


        function CargarDatos()
        {
            if (nvFW.pageContents == undefined || nvFW.pageContents.tipdoc == undefined || nvFW.pageContents.nrodoc == undefined) return;

            var rs   = new tRS();
            rs.async = true;

            rs.onComplete = function (res)
            {
                
                if (!res.eof())
                {
                    campos_defs.set_value("cliape", rs.getdata("cliape"))
                    campos_defs.set_value("clinom", rs.getdata("clinom"))

                    campos_defs.set_value("clinac", rs.getdata("clinac"))
                    campos_defs.set_value("clifecnac", FechaToSTR(parseFecha(rs.getdata('clifecnac'))))

                    campos_defs.set_value("cilestcivcod", rs.getdata("cliestcivcod"))
                    campos_defs.set_value("clasicod", rs.getdata("clasicod"))

                    if (rs.getdata("clifecfall") != undefined)
                        campos_defs.set_value("clifecfall", FechaToSTR(parseFecha(rs.getdata('clifecfall'))))
                    if (rs.getdata("clinotifall") != undefined)
                        campos_defs.set_value("clinotifall", FechaToSTR(parseFecha(rs.getdata('clinotifall'))))

                    campos_defs.set_value("paiscod", rs.getdata("pais_natal"))
                    if (rs.getdata("codprov_natal") != undefined)
                        campos_defs.set_value("codprovs", rs.getdata("codprov_natal"))
                    if (rs.getdata("dptocod_natal") != undefined)
                        campos_defs.set_value("dptocod", rs.getdata("dptocod_natal"))
                    if (rs.getdata("loccod_natal") != undefined)
                        campos_defs.set_value("loccod", rs.getdata("loccod_natal"))
                    //pais_natal, codprov_natal, dptocod_natal, loccod_natal

                    if (rs.getdata("ofinrodoc") != undefined)
                        campos_defs.set_value("ibs_cliente_oficial", rs.getdata("ofinrodoc"))

                    campos_defs.set_value("profesion", rs.getdata("profesion"))
                    if (rs.getdata("reltrabajo") != undefined)
                        campos_defs.set_value("reltrabajo", rs.getdata("reltrabajo"))
                    if (rs.getdata("sectorfin") != undefined)
                        campos_defs.set_value("sectorfin", rs.getdata("sectorfin"))
                    if (rs.getdata("titcod") != undefined)
                        campos_defs.set_value("titcod", rs.getdata("titcod"))
                    
                    $("clisexo").value = rs.getdata("clisexo")

                    if (rs.getdata("emancip") == "1")
                        $("emancip").parentElement.click()
                    if (rs.getdata("profesional") == "1")
                        $("profesional").parentElement.click()
                    if (rs.getdata("vincbanco") == "1")
                        $("vincbanco").parentElement.click()
                    if (rs.getdata("policaexpuesto") == "1")
                        $("policaexpuesto").parentElement.click()

                    if (rs.getdata("criteriomonto") != undefined)
                        campos_defs.set_value("criteriomonto", rs.getdata("criteriomonto"))
                    $("siter").checked = rs.getdata("siter") == "1"

                    campos_defs.set_value("perconcod", rs.getdata("perconcod"))

                    if (rs.getdata("tipdoc1") != undefined)
                        campos_defs.set_value("tipdoc", rs.getdata("tipdoc1"))
                    if (rs.getdata("nrodoc1") != undefined)
                        campos_defs.set_value("nrodoc1", rs.getdata("nrodoc1"))
                    if (rs.getdata("tipdoc2") != undefined)
                        campos_defs.set_value("tipdoc2", rs.getdata("tipdoc2"))
                    if (rs.getdata("nrodoc2") != undefined)
                        campos_defs.set_value("nrodoc2", rs.getdata("nrodoc2"))
                    if (rs.getdata("tipdoc3") != undefined)
                        campos_defs.set_value("tipdoc3", rs.getdata("tipdoc3"))
                    if (rs.getdata("nrodoc3") != undefined)
                        campos_defs.set_value("nrodoc3", rs.getdata("nrodoc3"))

                    campos_defs.set_value("clicondgi", rs.getdata("clicondgi"))
                    campos_defs.set_value("impgancod", rs.getdata("impgancod"))

                    $("residencia").value = rs.getdata("residencia")
                    if (rs.getdata("giin") != undefined)
                        campos_defs.set_value("giin", rs.getdata("giin"))

                    campos_defs.set_value("perfoper", rs.getdata("perfoper"))
                    if (rs.getdata("estfatca") != undefined)
                        campos_defs.set_value("estfatca", rs.getdata("estfatca"))

                    $("impempre").checked = rs.getdata("impempre") == "1"
                    $("invercalif").checked = rs.getdata("invercalif") == "1"
                    
                    
                }
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_datos')
            }

            rs.onError = function (res) {
                nvFW.bloqueo_desactivar($$('body')[0], 'bloq_datos')
                alert(res.lastError.numError + ' - ' + res.lastError.mensaje);
            }

            nvFW.bloqueo_activar($$('body')[0], 'bloq_datos', 'Cargando información de cliente...')
            rs.open(nvFW.pageContents.cliXML);
        }


        function cambiar_valor(obj)
        {
            inputObj = obj.getElementsByTagName("input")[0];
            
            if (inputObj == undefined) return;

            if (inputObj.value == "1")
            {
                inputObj.className = "slider4";
                inputObj.value = "0";
            }
            else
            {
                inputObj.className = "slider3";
                inputObj.value = "1";
            }
        }


        function getJsonData() {

            var datos = {}

            //datos["action"] = "A";
            //datos["paiscod"] = 54;
            //datos["bcocod"] = 312;
            //datos["succod"] = 1;
            //datos["tipdoc"] = 8;
            //datos["nrodoc"] = 20259040329;

            datos["clinum"] = 0;
            datos["climatcod"] = null;
            datos["tipocli"] = 1; // 1 = peersona fisica
            datos["perconcod"] = campos_defs.get_value("perconcod") ? parseInt(campos_defs.get_value("perconcod"), 10) : 0;//3;
            datos["clasicod"] = campos_defs.get_value("clasicod") ? parseInt(campos_defs.get_value("clasicod"), 10) : null;//1;
            datos["clicondgi"] = campos_defs.get_value("clicondgi") ? parseInt(campos_defs.get_value("clicondgi"), 10) : null;//0;
            datos["vip"] = null;
            datos["impgancod"] = campos_defs.get_value("impgancod") ? parseInt(campos_defs.get_value("impgancod"), 10) : null;//0;
            datos["residencia"] = parseInt($("residencia").value, 10);//0;
            datos["tipcartcod"] = 0;
            //datos["fecambiosit"] = "2015-12-31T00:00:00.000Z";
            datos["fecccongelsit"] = null;
            datos["objsocial"] = null;
            datos["cantpersonal"] = null;
            datos["totinganual"] = null;
            datos["sectorfin"] = campos_defs.get_value("sectorfin") ? parseInt(campos_defs.get_value("sectorfin"), 10) : null;//1;
            datos["vincbanco"] = parseInt($("vincbanco").value, 10);//1;
            datos["invercalif"] = $("invercalif").checked ? 1 : 0;
            datos["impempre"] = $("impempre").checked ? 1 : 0;
            datos["titcod"] = campos_defs.get_value("titcod") ? parseInt(campos_defs.get_value("titcod"), 10) : null;//28;
            datos["siter"] = $("siter").checked ? 1 : 0;
            datos["numextranj"] = null;
            datos["fecamsitant"] = null;
            datos["fecongsitant"] = null;
            datos["tipbalcod"] = null;
            datos["situaclicod"] = 1;
            datos["criteriomonto"] = campos_defs.get_value("criteriomonto") ? parseInt(campos_defs.get_value("criteriomonto"), 10) : null; //Perfil de monitoreo
            datos["policaexpuesto"] = $("policaexpuesto").value == "1" ? 1 : 2; // 1 = SI | 2 = NO
            datos["clifecmodif"] = null;
            datos["estfatca"] = campos_defs.get_value("estfatca") ? parseInt(campos_defs.get_value("estfatca"), 10) : null;//0;
            datos["giin"] = campos_defs.get_value("giin") ? campos_defs.get_value("giin") : null;//null;

            datos["perfoper"] = !campos_defs.get_value("perfoper") || isNaN(campos_defs.get_value("perfoper")) ? null : parseFloat(campos_defs.get_value("perfoper"));//26433.49;

            datos["clinom"] = campos_defs.get_value("clinom");
            datos["cliape"] = campos_defs.get_value("cliape");
            datos["clifecnac"] = campos_defs.get_value("clifecnac") ? parseFecha(campos_defs.get_value("clifecnac"), 'dd/mm/yyyy').toISOString() : null;
            datos["clisexo"] = $("clisexo").value;
            datos["tipdoc1"] = campos_defs.get_value("tipdoc") ? parseInt(campos_defs.get_value("tipdoc"), 10) : null;//"1";
            datos["tipdoc2"] = campos_defs.get_value("tipdoc2") ? parseInt(campos_defs.get_value("tipdoc2"), 10) : null;//null;
            datos["nrodoc1"] = campos_defs.get_value("nrodoc1") ? parseInt(campos_defs.get_value("nrodoc1"), 10) : null;//14686885;
            datos["nrodoc2"] = campos_defs.get_value("nrodoc2") ? parseInt(campos_defs.get_value("nrodoc2"), 10) : null;//null;
            datos["cliestcivcod"] = campos_defs.get_value("cilestcivcod") ? parseInt(campos_defs.get_value("cilestcivcod"), 10) : null;//1;
            datos["profesion"] = campos_defs.get_value("profesion") ? parseInt(campos_defs.get_value("profesion"), 10) : null;//5;
            datos["persoc"] = 0;
            datos["peract"] = 0;
            datos["club"] = null;
            datos["servmed"] = null;
            datos["cliviafrec"] = null;
            datos["cliviafrecint"] = null;
            datos["clinac"] = campos_defs.get_value("clinac") ? parseInt(campos_defs.get_value("clinac"), 10) : null;//54;
            datos["nivedic"] = 0;
            datos["vivpropia"] = " ";
            datos["alqgastos"] = 0;
            datos["perscargo"] = 0;
            datos["reltrabajo"] = campos_defs.get_value("reltrabajo") ? parseInt(campos_defs.get_value("reltrabajo"), 10) : null;//1;
            datos["pais_natal"] = campos_defs.get_value("paiscod") ? parseInt(campos_defs.get_value("paiscod"), 10) : null;//54;
            datos["codprov_natal"] = campos_defs.get_value("codprovs") ? parseInt(campos_defs.get_value("codprovs"), 10) : null;//1;
            datos["dptocod_natal"] = campos_defs.get_value("dptocod") ? parseInt(campos_defs.get_value("dptocod"), 10) : null;//1;
            datos["loccod_natal"] = campos_defs.get_value("loccod") ? parseInt(campos_defs.get_value("loccod"), 10) : null;//1602001;
            datos["emancip"] = parseInt($("emancip").value, 10);//1;
            datos["profesional"] = parseInt($("profesional").value, 10);//1;
            datos["fecingrecli"] = null;
            datos["fecvtorestran"] = null;
            datos["tipdoc3"] = campos_defs.get_value("tipdoc3") ? parseInt(campos_defs.get_value("tipdoc3"), 10) : null;//null;
            datos["nrodoc3"] = campos_defs.get_value("nrodoc3");//null;

            //Oficial asignado
            if (campos_defs.get_value("ibs_cliente_oficial")) {
                datos["ofipaiscod"] = 54;
                datos["ofibcocod"] = 312;
                datos["ofisuccod"] = 1;
                datos["ofitipdoc"] = 1;
                datos["ofiusrident"] = parseInt(campos_defs.get_value("ibs_cliente_oficial"), 10);
            }
            
            

            return datos;
        }
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()">

    <table class="tb1" cellpadding="0" cellspacing="0">
        <tr class="tbLabel">
            <td style="border-radius: 0;">Cliente Particular</td>
        </tr>
    </table>

    <div style="width: 70%; float:left;">
        <table class="tb1" id="datos_cliente">
            <tr>
                <td>
                    <table style="width:100%">
                        <tr>
                            <td class="Tit1" style="width: 10%; font-weight: 700;" nowrap>Apellidos</td>
                            <td style="width: 40%;">
                                <script>
                                    campos_defs.add('cliape', { enDB: false, nro_campo_tipo: 104 });
                                </script>

                            </td>
                            <td class="Tit1" style="width: 10%; font-weight: 700;" nowrap>Nombres</td>
                            <td style="width: 40%;">
                                <script>
                                    campos_defs.add('clinom', { enDB: false, nro_campo_tipo: 104 });
                                </script>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="width:50%; float:left">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Datos Personales</td>
                            </tr>
                            <tr>
                                <td class="Tit1">Nacionalidad</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('clinac');
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table class="tb1">
                                        <tr>
                                            <td class="Tit1">Fec. Nac.</td>
                                            <td class="Tit1">Estado Civil</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <script>
                                                    campos_defs.add('clifecnac', { enDB: false, nro_campo_tipo: 103 });
                                                </script>
                                            </td>
                                            <td>
                                                <script type="text/javascript">
                                                    campos_defs.add('cilestcivcod', {});
                                                </script>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1" colspan="2">Clasificación del cliente</td>
                                        </tr>
                                        <tr>
                                            <td colspan="2">
                                                <script>
                                                    campos_defs.add('clasicod');
                                                </script>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td class="Tit1">Fec. Fallecimiento</td>
                                            <td class="Tit1">Fec. Notificación</td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <script>
                                                    campos_defs.add('clifecfall', { enDB: false, nro_campo_tipo: 103 });
                                                </script>
                                            </td>
                                            <td>
                                                <script>
                                                    campos_defs.add('clinotifall', { enDB: false, nro_campo_tipo: 103 });
                                                </script>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="2"><span style="width: 20%">Carga </span><input type="text" name="carga" id="carga" value="" style="width: 80%" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Lugar de nacimiento</td>
                            </tr>
                            <tr>
                                <td class="Tit1">País</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('paiscod', {
                                            nro_campo_tipo: 1
                                        });
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Provincia</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('codprovs', {
                                            nro_campo_tipo: 1,
                                            depende_de: 'paiscod',
                                            depende_de_campo: 'paiscod'
                                        });
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Part. Dpto.</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('dptocod', {
                                            depende_de: 'codprovs',
                                            depende_de_campo: 'codprov'
                                        });
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Localidad</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add("loccod", {
                                            nro_campo_tipo: 1,
                                            depende_de: 'codprovs',
                                            depende_de_campo: 'codprov'
                                        });
                                    </script>
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Oficial asignado</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('ibs_cliente_oficial');
                                    </script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="width:50%; float:left">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Características</td>
                            </tr>
                            <tr>
                                <td class="Tit1">Profesión</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('profesion');
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Situación laboral</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('reltrabajo');
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Sector financiero</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('sectorfin');
                                    </script>
                                </td>
                            </tr>
                            <tr>
                                <td class="Tit1">Titular</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('titcod');
                                    </script>
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Sexo</td>
                                <td>Emancipado</td>
                            </tr>
                            <tr>
                                <td>
                                    <select name="clisexo" id="clisexo" style="width: 100%">
                                        <option value="M">MASCULINO</option>
                                        <option value="F">FEMENINO</option>
                                    </select>
                                </td>
                                <td>
                                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="emancip" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Profesional</td>
                                <td>Vinc. Bco</td>
                                <td>Polít. Expuesto</td>
                            </tr>
                            <tr>
                                <td>
                                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="profesional" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                                </td>
                                <td>
                                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="vincbanco" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                                </td>
                                <td>
                                    <span onclick="cambiar_valor(this)" style="vertical-align: middle"><b>No</b><input id="policaexpuesto" value="0" class="slider4" style="width: 35px" type="range" min="0" max="1" disabled=""><b>Si</b></span>
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td colspan="2">Perfil de monitoreo</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('criteriomonto');
                                    </script>
                                </td>
                                <td>
                                    <input type="checkbox" name="siter" id="siter" />Siter
                                </td>
                            </tr>
                        </table>
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>Perfil de consumo</td>
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('perconcod');
                                    </script>
                                </td>
                            </tr>
                        </table>
                    </div>
                                            
                </td>
            </tr>
        </table>
    </div>

    <div style="width:30%; float:left">
        <table class="tb1">
            <tr class="tbLabel">
                <td>Documentos Alternativos</td>
            </tr>
        </table>
        <table class="tb1" id="datos_alternativos">
            <tr>
                <td class="Tit1" style="width: 10%;" nowrap>Tipo</td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('tipdoc');
                    </script>
                </td>
                <td class="Tit1" style="width: 10%;" nowrap>Nro</td>
                <td>
                    <script>
                        campos_defs.add('nrodoc1', { enDB: false, nro_campo_tipo: 100 });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 10%;" nowrap>Tipo</td>
                <td>
                    <script type="text/javascript">
                        var tipDocOpc = Object.assign({}, campos_defs.items["tipdoc"])
                        tipDocOpc.campo_def = "tipdoc2"
                        campos_defs.add('tipdoc2', tipDocOpc);
                    </script>
                </td>
                <td class="Tit1" style="width: 10%;" nowrap>Nro</td>
                <td>
                    <script>
                        campos_defs.add('nrodoc2', { enDB: false, nro_campo_tipo: 100 });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 10%;" nowrap>Tipo</td>
                <td>
                    <script type="text/javascript">
                        var tipDocOpc = Object.assign({}, campos_defs.items["tipdoc"])
                        tipDocOpc.campo_def = "tipdoc3"
                        campos_defs.add('tipdoc3', tipDocOpc);
                    </script>
                </td>
                <td class="Tit1" style="width: 10%;" nowrap>Nro Alfa.</td>
                <td>
                    <script>
                        campos_defs.add('nrodoc3', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td>Situación fiscal</td>
            </tr>
            <tr>
                <td class="Tit1">IVA</td>
            </tr>
            <tr>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('clicondgi');
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1">Impuesto a las ganancias</td>
            </tr>
            <tr>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('impgancod');
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td colspan="2">Impuesto IIBB</td>
            </tr>
            <tr>
                <td>
                    <script>
                        campos_defs.add('imp_iibb', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
                <td>
                    <script>
                        campos_defs.add('fecha_iibb', { enDB: false, nro_campo_tipo: 103 });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td>Residencia</td>
                <td>RG 3337</td>
            </tr>
            <tr>
                <td>
                    <select name="residencia" id="residencia" style="width: 100%">
                        <option value="0">PAIS</option>
                        <option value="1">EXTERIOR</option>
                    </select>
                </td>
                <td>
                    <input type="button" value="Bonif." style="width:100%" />
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td>GIIN</td>
            </tr>
            <tr>
                <td>
                    <script>
                        campos_defs.add('giin', { enDB: false, nro_campo_tipo: 104 });
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr class="tbLabel">
                <td>Perfil Operativo</td>
                <td>FATCA</td>
            </tr>
            <tr>
                <td>
                    <script>
                        campos_defs.add('perfoper', { enDB: false, nro_campo_tipo: 102 });
                    </script>
                </td>
                <td>
                    <script type="text/javascript">
                        campos_defs.add('estfatca');
                    </script>
                </td>
            </tr>
        </table>
        <table class="tb1">
            <tr>
                <td>
                    <input type="checkbox" name="impempre" id="impempre" />Impuesto Emp.
                </td>
                <td>
                    <input type="checkbox" name="invercalif" id="invercalif" />Inversor Calif.
                </td>
            </tr>
        </table>
    </div>
   
</body>
</html>