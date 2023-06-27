<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim codigoID = nvUtiles.obtenerValor("codigoID", "")
    Dim descTipo = nvUtiles.obtenerValor("descTipo", "")
    Dim nroGrupo = nvUtiles.obtenerValor("nroGrupo", "")
    Dim modo = nvUtiles.obtenerValor("modo", "")

    'Dim err As New tError
    Dim vinc_tipo = nvUtiles.obtenerValor("vinc_tipo", "")
    Dim nro_vinc_grupo = nvUtiles.obtenerValor("nro_vinc_grupo", "")
    'Dim tipo_vinc = nvUtiles.obtenerValor("tipo_vinc", "")
    Dim nro_vinc_tipo = nvUtiles.obtenerValor("nro_vinc_tipo", "")
    Dim nro_vinc_tipo_rel = nvUtiles.obtenerValor("nro_vinc_tipo_rel", "")


    'If (modo = "ER") Then
    '    Try
    '        DBExecute("delete from ent_vinc_tipo_rel where nro_vinc_tipo=" + nro_vinc_tipo + "and nro_vinc_tipo_rel=" + nro_vinc_tipo_rel)
    '        'BORRAR TAMBIEN LA VUELTA
    '        DBExecute("delete from ent_vinc_tipo_rel where nro_vinc_tipo=" + nro_vinc_tipo_rel + "and nro_vinc_tipo_rel=" + nro_vinc_tipo)
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = 101
    '        err.titulo = "Error en DB"
    '        err.mensaje = "Mensaje: " & ex.Message
    '    End Try
    '    err.response()
    'End If

    'If (modo = "E" And vinc_tipo <> "") Then
    '    Try
    '        DBExecute("update ent_vinc_tipos set vinc_tipo='" + vinc_tipo + "', nro_vinc_grupo=" + nro_vinc_grupo + " where nro_vinc_tipo=" + codigoID)
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = 101
    '        err.titulo = "Error en DB"
    '        err.mensaje = "Mensaje: " & ex.Message
    '    End Try
    '    err.response()
    'End If

    'If (modo = "A" And vinc_tipo <> "") Then
    '    Try
    '        DBExecute("insert into ent_vinc_tipos ([vinc_tipo], [nro_vinc_grupo]) values ('" + vinc_tipo + "', " + nro_vinc_grupo + ")")
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = 101
    '        err.titulo = "Error en DB"
    '        err.mensaje = "Mensaje: " & ex.Message
    '    End Try
    '    err.response()
    'End If

    'If (modo = "V" And nro_vinc_tipo_rel <> "") Then
    '    Try
    '        DBExecute("insert into ent_vinc_tipo_rel ([nro_vinc_tipo], [nro_vinc_tipo_rel]) values (" + nro_vinc_tipo + ", " + nro_vinc_tipo_rel + ")")
    '        DBExecute("insert into ent_vinc_tipo_rel ([nro_vinc_tipo], [nro_vinc_tipo_rel]) values (" + nro_vinc_tipo_rel + ", " + nro_vinc_tipo + ")")
    '    Catch ex As Exception
    '        err.parse_error_script(ex)
    '        err.numError = 101
    '        err.titulo = "Error en DB"
    '        err.mensaje = "Mensaje: " & ex.Message
    '    End Try
    '    err.response()
    'End If

    If (modo = "A" Or modo = "M" Or modo = "B") Then

        Dim Err As New nvFW.tError()

        Try

            Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_vinculos_tipos", ADODB.CommandTypeEnum.adCmdStoredProc, nvDBUtiles.emunDBType.db_app)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

            Dim rs As ADODB.Recordset = cmd.Execute()

            Err.numError = rs.Fields("numError").Value
            Err.titulo = rs.Fields("titulo").Value
            Err.mensaje = rs.Fields("mensaje").Value

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar Entidad"
            Err.mensaje = "No se pudo relizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "entidad_abm.aspx"
        End Try

        Err.response()

    End If

    Me.contents("codigoID") = codigoID
    Me.contents("descTipo") = descTipo
    Me.contents("nroGrupo") = nroGrupo
    Me.contents("modo") = modo
    Me.contents("filtro_ent_vinc_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_tipos'><campos>nro_vinc_tipo as id, vinc_tipo as campo, nro_vinc_grupo</campos><filtro></filtro><orden>vinc_tipo</orden></select></criterio>")
    Me.contents("filtro_vinc_tipos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_tipos'><campos>*</campos><filtro></filtro><orden>nro_vinc_tipo</orden></select></criterio>")
    Me.contents("filtro_vinc_rel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEnt_vinc_tipo_rel'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_ent_vinc_grupos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ent_vinc_grupos'><campos>nro_vinc_grupo as id, vinc_grupo as campo</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroTablasSimples") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='nv_tablas_simples'><campos>nro_tabla_simple AS codigoID</campos><filtro><sql type='sql'>'Grupo vinculo' = descripcion collate Latin1_General_CI_AI</sql></filtro><orden></orden></select></criterio>")
%>
<%--<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">--%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <title>Vinculos ABM</title>
    <link href="/fw/image/icons/nv_voii.ico" type="text/css" rel="shortcut icon" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tcampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>
    <% = Me.getHeadInit() %>

    <style type="text/css">
        .param_editable {
            position: relative;
            cursor: pointer;
            padding-right: 16px;
            background-image: url(../../../fw/image/icons/eliminar.png);
            background-size: 16px;
            background-repeat: no-repeat;
            background-position: center;
        }

    </style>

    <script type="text/javascript">

        var codigoID = nvFW.pageContents.codigoID
        var descTipo = nvFW.pageContents.descTipo
        var nroGrupo = nvFW.pageContents.nroGrupo
        var modo = nvFW.pageContents.modo
        var filtro
        var win = nvFW.getMyWindow();
        var vincularMap = new Map;

        ////Vincula las entidades
        //function vincular_ent() {

        //    if (!$('nro_vinc_tipo_rel').value) {
        //        alert('No se a establecido ninguna relacion')
        //    } else {
        //        nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
        //            parameters: { modo: 'V', nro_vinc_tipo: $('id').value, nro_vinc_tipo_rel: $('nro_vinc_tipo_rel').value },
        //            onSuccess: function (err, transport) {

        //                if (err.numError != 0) {
        //                    alert(err.mensaje)
        //                    return
        //                }
        //                window_onload()
        //                tipoVinculo_rel_listar()

        //                win.options.userData = {
        //                    recargar: true
        //                }
        //            },
        //            error_alert: true
        //        })
        //    }
        //}

        ////Editar tipo
        //function editar_tipo_vinculo() {

        //    nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
        //        parameters: { modo: 'E', vinc_tipo: $('vinc_tipo').value, codigoID: codigoID, nro_vinc_grupo: $('nro_vinc_grupo').value },
        //        onSuccess: function (err, transport) {
        //            if (err.numError != 0) {
        //                alert(err.mensaje)
        //                return
        //            }
        //        },
        //        error_alert: true
        //    })
        //}

        ////Alta de Tipo
        //function alta_vinc_tipos() {

        //    nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
        //        parameters: { modo: 'A', vinc_tipo: $('vinc_tipo').value, nro_vinc_grupo: $('nro_vinc_grupo').value },
        //        onSuccess: function (err, transport) {
        //            if (err.numError != 0) {
        //                alert(err.mensaje)
        //                return
        //            } else { //Pregunta si quiere ingresar un nuevo tipo o si desea vincularlo.
        //                Dialog.confirm('El alta se realizo stasifactoriamente', {
        //                    width: 350,
        //                    className: "alphacube",
        //                    okLabel: "Vincular tipo",
        //                    cancelLabel: "Nuevo tipo",
        //                    onOk: function (win) {
        //                        campos_defs.habilitar('nro_vinc_grupo', false)
        //                        campos_defs.habilitar('vinc_tipo', false)
        //                        //campos_defs.habilitar('nro_vinc_tipo_rel', true)

        //                        win.close()
        //                    },
        //                    onCancel: function (win) {
        //                        window_onload()
        //                        win.close()
        //                    }
        //                })
        //            }
        //        },
        //        error_alert: true
        //    })

        //    var rs = new tRS()
        //    rs.open({ filtroXML: nvFW.pageContents.filtro_vinc_tipos })
        //    var i = 0
        //    while (i == 0) {
        //        if (rs.eof()) {
        //            rs.moveprevious()
        //            var nro = rs.getdata('nro_vinc_tipo')
        //            $('id').value = (parseInt(nro))
        //            campos_defs.habilitar('id', false)
        //            i = 1
        //        }
        //        rs.movenext()
        //    }
        //}

        //valida campos
        //function validar_vinc_tipo() {
        //    if (modo == 'E') {
        //        editar_tipo_vinculo()
        //    } else {
        //        var bandera = 0
        //        //mover a SP
        //        var rsVal = new tRS()
        //        rsVal.open({ filtroXML: nvFW.pageContents.filtro_vinc_tipos })
        //        while (!rsVal.eof()) {
        //            if (rsVal.getdata('vinc_tipo') == $('vinc_tipo').value) {
        //                alert('Ya existe este tipo')
        //                bandera = 1
        //                return
        //            }
        //            rsVal.movenext()
        //        }

        //        if ($('vinc_tipo').value == "") {
        //            alert('Ingrese una descripción')

        //            //} else if ($('nro_ent_desc').value == "") {
        //        } else if ($('nro_vinc_grupo').value == "") {
        //            alert('Seleccione un grupo')

        //        } else if (bandera == 0) {
        //            alta_vinc_tipos()
        //        }
        //    }
        //}

        //ABM para los grupos
        var win_grupos_vinculos_abm
        function abm_grupo() {

            //obtengo el codigoID
            var rs = new tRS();

            rs.open(nvFW.pageContents.filtroTablasSimples)

            if (!rs.eof()) {
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_grupos_vinculos_abm = w.createWindow({
                    className: 'alphacube',
                    url: '/fw/funciones/abmcodigos_seleccion.aspx?codigoID=' + rs.getdata('codigoID'),
                    title: '<b>ABM Grupos Vinculos</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    resizable: false,
                    modal: true,
                    width: 800,
                    height: 400,
                    onClose: window_onload
                });
                win_grupos_vinculos_abm.showCenter()
            }
        }

        function window_onload() {

            win.options.userData = {
                recargar: false
            }

            if (codigoID != "") {
                $('id').value = codigoID;
                $('vinc_tipo').value = descTipo;
                //$('nro_ent').value = nroGrupo;
                campos_defs.set_value('nro_vinc_grupo', nroGrupo)
                campos_defs.habilitar('nro_vinc_grupo', true)
                campos_defs.habilitar('id', false)
                //campos_defs.habilitar('nro_vinc_tipo_rel', true)

                tipoVinculo_rel_listar()

            } else {
                //si es nuevo, muestra ID siguiente
                //var rs = new tRS()
                //rs.open({ filtroXML: nvFW.pageContents.filtro_vinc_tipos })
                //var i = 0
                //while (i == 0) {
                //    if (rs.eof()) {
                //        rs.moveprevious()
                //        var nro = rs.getdata('nro_vinc_tipo')
                //        $('id').value = (parseInt(nro) + 1)
                //        campos_defs.habilitar('id', false)
                //        i = 1
                //    }
                //    rs.movenext()
                //}
                $('id').value = "";
                $('vinc_tipo').value = "";
                //$('nro_ent_desc').value = "";
                //$('divBuscar').innerHTML = "";
                campos_defs.habilitar('id', false)
                campos_defs.habilitar('nro_vinc_grupo', true)
                campos_defs.habilitar('vinc_tipo', true)

                tipoVinculo_rel_listar()

                //vListButtons.MostrarListButton()
            }

            //window_onresize();

        }

        //Muestra la lista de relaciones
        function tipoVinculo_rel_listar() {
            var rsRel = new tRS()
            var id = $('id').value

            rsRel.open({
                filtroXML: nvFW.pageContents.filtro_vinc_rel,
                filtroWhere: '<criterio><select><filtro><nro_vinc_tipo type="igual">' + id + '</nro_vinc_tipo></filtro></select></criterio>'
            })

            var strHTMLparams = '<div><table id="tbTipoVinculoRel" class="tb1 highlightOdd highlightTROver layout_fixe" style="width:100%"><tr></tr>'
            while (!rsRel.eof()) {
                strHTMLparams += '<tr id="trnro_vinc_tipo_rel' + rsRel.getdata('nro_vinc_tipo_rel') + '"><td style="width:10%">' + rsRel.getdata('nro_vinc_tipo_rel') + '</td><td>' + rsRel.getdata('vinc_tipo_rel') + '</td><td style="width: 5%" class="param_editable" onClick="eliminar_relacion(' + rsRel.getdata('nro_vinc_tipo_rel') + ')"></td></tr>'

                vincularMap.set(rsRel.getdata('nro_vinc_tipo_rel'), { nro_vinc_tipo_rel: rsRel.getdata('nro_vinc_tipo_rel'), modo: "ver" });

                rsRel.movenext()

            }

            strHTMLparams += '</table></div>'
            strHTMLparams += '<div id="div_boton_agregar" style="margin-top: 0.5em;">'
            strHTMLparams += '<center><img onclick="agregar_tipoVinculo_relacion()" src="/FW/image/icons/agregar.png" style = "cursor:pointer" title="Agregar Vínculo" /></center></div>'

            $('relaciones').innerHTML = strHTMLparams

        }

        //elimina de la lista
        function eliminar_relacion(nro_vinc_tipo_rel) {
            //nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
            //    parameters: { modo: 'ER', nro_vinc_tipo: nro_vinc_tipo, nro_vinc_tipo_rel: nro_vinc_tipo_rel },
            //    onSuccess: function (err, transport) {
            //        if (err.numError != 0) {
            //            alert(err.mensaje)
            //            return
            //        }

            //        tipoVinculo_rel_listar()
            //    },
            //    error_alert: true
            //})

            vincularMap.get(nro_vinc_tipo_rel.toString()).modo = 'eliminar';
            $('trnro_vinc_tipo_rel' + nro_vinc_tipo_rel).remove();

        }

        function window_onresize() {

            //$('tbTipoVinculoRel').setStyle({ height: $$('body')[0].getHeight() - $('divMenuVinculo').getHeight() - $('tbTipoVinculo').getHeight() - $('divMenuVinculasiones').getHeight() - $('tbcabecera').getHeight() + 'px' })

        }


        //agrega nuevas relaciones a la lista
        function agregar_tipoVinculo_relacion() {

            var strError = '';

            if (campos_defs.get_value('nro_vinc_grupo') == '')
                strError += "Ingresar <b>Grupo</b><br>";
            if (campos_defs.get_value('vinc_tipo') == '')
                strError += "Ingresar <b>Descripción</b><br>";

            if (strError != '') {
                alert(strError);
                return;
            }

            strhtml = "<table class='tb1' style='width:100%'><tr class='tbLabel'><td style='text-align: center'><b>Vincular con</b></td></tr>"

            strhtml += '<tr><td id="vinculos"></td></tr>'
            strhtml += "</table>"

            //$('contenedor').update(strhtml)

            Dialog.confirm(strhtml, {
                width: 500,
                height: 300,
                className: "alphacube",
                draggable: true,
                closable: true,
                okLabel: "Agregar",
                onShow: function (win) {
                    campos_defs.add('nro_vinc_tipo_rel', { target: 'vinculos', enDB: false, nro_campo_tipo: 1, depende_de: 'nro_vinc_grupo', depende_de_campo: 'nro_vinc_grupo', filtroXML: nvFW.pageContents.filtro_ent_vinc_tipos })
                },
                cancelLabel: "Cancelar",
                cancel: function (win) { win.close(); return },
                ok: function (win) {
                    //if (agregar_nuevo_registro(nro_inc_actual, rs.getdata('nro_permiso')) != false) win.close()
                    if (campos_defs.get_value('nro_vinc_tipo_rel') != "") {
                        if (typeof vincularMap.get(campos_defs.get_value('nro_vinc_tipo_rel')) == "undefined") {

                            vincularMap.set(campos_defs.get_value('nro_vinc_tipo_rel'), { modo: "agregar", nro_vinc_tipo_rel: campos_defs.get_value('nro_vinc_tipo_rel') });

                            var desc = campos_defs.get_desc('nro_vinc_tipo_rel');

                            //desc = desc.slice(0, desc.length - 4)
                            desc = desc.slice(0, desc.indexOf("("));

                            var strHTMLparams = '<tr id="trnro_vinc_tipo_rel' + campos_defs.get_value('nro_vinc_tipo_rel') + '"><td style="width:10%">' + campos_defs.get_value('nro_vinc_tipo_rel') + '</td><td>' + desc + '</td><td style="width: 5%" class="param_editable" onClick="eliminar_relacion_map(' + campos_defs.get_value('nro_vinc_tipo_rel') + ')"></td></tr>';

                            $('tbTipoVinculoRel').getElementsByTagName('tbody')[0].innerHTML += strHTMLparams;
                        } else alert("Ya existe la relación");
                        win.close();
                    } else alert("Debe seleccionar un tipo de vínculo")
                }
            });
        }

        //elimina de la lista
        function eliminar_relacion_map(nro_vinc_tipo_rel) {

            $('trnro_vinc_tipo_rel' + nro_vinc_tipo_rel).remove();
            vincularMap.delete(nro_vinc_tipo_rel.toString());

        }

        //crea/edita tipo vinculo, agrega/elimina relaciones
        function tipo_vinculo_guardar() {

            var strError = '';

            if (campos_defs.get_value('nro_vinc_grupo') == '')
                strError += "Ingresar <b>Grupo</b><br>";
            if (campos_defs.get_value('vinc_tipo') == '')
                strError += "Ingresar <b>Descripción</b><br>";

            if (strError != '') {
                alert(strError);
                return;
            }

            var modo;

            if (codigoID != "")
                modo = 'M';
            else { modo = 'A'; codigoID = -1; }

            var strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>";
            strXML += "<ent_vinc_tipo modo='" + modo + "' nro_vinc_grupo='" + campos_defs.get_value('nro_vinc_grupo') + "' vinc_tipo='" + campos_defs.get_value('vinc_tipo') + "' nro_vinc_tipo='" + codigoID + "'>";
            strXML += "<vinc_relaciones>"
            vincularMap.forEach(function (value, key, mapa) {

                var modoRel;
                if (value.modo == "agregar") {
                    modoRel = 'A';
                    strXML += "<vinc_rel modo='" + modoRel + "' nro_vinc_tipo_rel='" + value.nro_vinc_tipo_rel + "' ></vinc_rel>";
                }
                else if (value.modo == 'eliminar') {
                    modoRel = 'B';
                    strXML += "<vinc_rel modo='" + modoRel + "' nro_vinc_tipo_rel='" + value.nro_vinc_tipo_rel + "' ></vinc_rel>";
                }

            });
            strXML += "</vinc_relaciones>";
            strXML += "</ent_vinc_tipo>";

            nvFW.error_ajax_request('ent_vinculos_tipos_ABM.aspx', {
                parameters: { modo: modo, strXML: strXML },
                onSuccess: function (err, transport) {

                    if (err.numError != 0) {
                        if (err.numError == 100)
                            alert('Es posible que el tipo vínculo este relacionado')
                        else {
                            alert(err.mensaje)
                        }
                        return
                    }

                    win.options.userData = {
                        recargar: true
                    }

                    win.close();
                },
                error_alert: true
            })

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="overflow: hidden;">
    <div id="divMenuVinculo" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuVinculo = new tMenu('divMenuVinculo', 'vMenuVinculo');
        vMenuVinculo.loadImage("nuevo", "/fw/image/icons/nueva.png")
        vMenuVinculo.loadImage("guardar", "/fw/image/icons/guardar.png")
        //vMenuVinculo.loadImage("guardar", "/fw/image/icons/asignar0.png")
        Menus["vMenuVinculo"] = vMenuVinculo
        Menus["vMenuVinculo"].alineacion = 'centro';
        Menus["vMenuVinculo"].estilo = 'A';
        Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='0' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>tipo_vinculo_guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='1' style='width: 86%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='2' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>ABM Grupos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abm_grupo()</Codigo></Ejecutar></Acciones></MenuItem>")
        //Menus["vMenuVinculo"].CargarMenuItemXML("<MenuItem id='2' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vincular_ent()</Codigo></Ejecutar></Acciones></MenuItem>") //movido a relacion
        vMenuVinculo.MostrarMenu()
    </script>
    <table id="tbTipoVinculo" style="width: 100%" class="tb1">
        <%-- <tr>
            <td>

                <table class="tb1" id="tb_cab" style="width: 100%;">--%>
        <tr class="tbLabel">
            <td style="width: 10%; vertical-align: middle; text-align: center">ID</td>
            <td style="width: 30%; vertical-align: middle; text-align: center">Grupo</td>
            <td style="width: 60%; vertical-align: middle; text-align: center">Descripción</td>
        </tr>
        <tr>
            <td>
                <script type="text/javascript">
                    campos_defs.add('id', { enDB: false, nro_campo_tipo: 101 })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('nro_vinc_grupo', {
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtro_ent_vinc_grupos,
                        nro_campo_tipo: 1
                    })
                </script>
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('vinc_tipo', { enDB: false, nro_campo_tipo: 104 })
                </script>
            </td>
        </tr>
    </table>
    <%--</td>
            <td>
                <table style="width: 20%;">
                    <tr>
                        <td>
                            <div id="divBuscar" style="width: 150px; vertical-align: middle; margin: auto; padding: 7px"></div>
                            <script type="text/javascript">
                                var vButtonItems = {}

                                vButtonItems[0] = {}
                                vButtonItems[0]["nombre"] = "Buscar";
                                vButtonItems[0]["etiqueta"] = "Crear";
                                vButtonItems[0]["imagen"] = "guardar";
                                vButtonItems[0]["onclick"] = "return validar_vinc_tipo()";

                                var vListButtons = new tListButton(vButtonItems, 'vListButtons')
                                vListButtons.loadImage("guardar", "/fw/image/icons/guardar.png")
                                vListButtons.MostrarListButton()
                            </script>
                        </td>
                    </tr>
                </table>--%>

    <%--</td>
        </tr>
    </table>--%>

    <%-- <div id="divMenuRelacion" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var vMenuRelacion = new tMenu('divMenuRelacion', 'vMenuRelacion');
        Menus["vMenuRelacion"] = vMenuRelacion
        Menus["vMenuRelacion"].alineacion = 'centro';
        Menus["vMenuRelacion"].estilo = 'A';
        Menus["vMenuRelacion"].CargarMenuItemXML("<MenuItem id='0' style='width: 86%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Relacionar</Desc></MenuItem>")
        Menus["vMenuRelacion"].CargarMenuItemXML("<MenuItem id='1' style='width: 7%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Vincular</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vincular_ent()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuRelacion.loadImage("guardar", "/fw/image/icons/asignar0.png")

        vMenuRelacion.MostrarMenu()
    </script>

    <table class="tb1">
        <tr class="tbLabel">
            <td style="vertical-align: middle; text-align: center">Vincular con</td>--%>
    <%--<td style="width:150px;vertical-align:middle; text-align:center"></td>--%>
    <%--</tr>
        <tr>
            <td id="vinculos">
                <script type="text/javascript">
                    campos_defs.add('nro_vinc_tipo_rel', {
                        target: 'vinculos',
                        enDB: false,
                        nro_campo_tipo: 1,
                        depende_de: 'nro_vinc_grupo',
                        depende_de_campo: 'nro_vinc_grupo',
                        filtroXML: nvFW.pageContents.filtro_ent_vinc_tipos,
                    })
                    campos_defs.habilitar('nro_vinc_tipo_rel', false)
                </script>
            </td>
        </tr>
    </table>--%>
    <div id="vinculosTipo">
        <div id="divMenuVinculasiones" style="margin: 0px; padding: 0px;"></div>
        <script type="text/javascript">
            var vMenuVinculasiones = new tMenu('divMenuVinculasiones', 'vMenuVinculasiones');
            Menus["vMenuVinculasiones"] = vMenuVinculasiones
            Menus["vMenuVinculasiones"].alineacion = 'centro';
            Menus["vMenuVinculasiones"].estilo = 'A';
            Menus["vMenuVinculasiones"].CargarMenuItemXML("<MenuItem id='0' style='width: 86%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Vinculos</Desc></MenuItem>")
            vMenuVinculasiones.MostrarMenu()
        </script>

        <table id="tbcabecera" class="tb1">
            <tr class="tbLabel">
                <td style="width: 10%">Nro. Tipo</td>
                <td>Vinculado con:</td>
                <td style="width: 5%; text-align: center">-</td>
            </tr>
        </table>
        <div id="relaciones"></div>

    </div>

</body>
</html>
