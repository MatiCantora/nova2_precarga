<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<%
    Dim strSQL = ""
    Dim numError = ""
    
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim f_id = nvFW.nvUtiles.obtenerValor("f_id", "0")
    Dim ref_files_path = nvFW.nvUtiles.obtenerValor("ref_files_path", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim err As New nvFW.tError()

    Me.contents("f_id") = f_id



    If modo = "M" Then
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("ref_file_pvalues_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
            Dim pStrXML As ADODB.Parameter
            pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            cmd.Parameters.Append(pStrXML)
            Dim rs As ADODB.Recordset
            rs = cmd.Execute()
            f_id = rs.Fields("f_id").Value
            err.params("f_id") = f_id
            err.numError = rs.Fields("numError").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.titulo = rs.Fields("titulo").Value
            err.comentario = rs.Fields("comentario").Value
            nvFW.nvDBUtiles.DBCloseRecordset(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
        End Try

        err.response()

    End If

    If modo = "guardarNroUbi" Then

        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("ref_file_update_nro_ubi", ADODB.CommandTypeEnum.adCmdStoredProc)
            Dim pStrXML As ADODB.Parameter
            pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
            cmd.Parameters.Append(pStrXML)
            Dim rs As ADODB.Recordset
            rs = cmd.Execute()
            f_id = rs.Fields("f_id").Value
            err.params("f_id") = f_id
            err.numError = rs.Fields("numError").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.titulo = rs.Fields("titulo").Value
            err.comentario = rs.Fields("comentario").Value
            nvFW.nvDBUtiles.DBCloseRecordset(rs)

        Catch ex As Exception
            err.parse_error_script(ex)
        End Try

        err.response()

    End If
    
    Dim arfile As New trsParam
    Dim file = nvFile.getFile(f_id:=f_id, ref_files_path:=ref_files_path)
    If file Is Nothing Then
        err.numError = 1366
        err.salida_tipo = "HTML"
        err.titulo = "Error al intentar descargar el archivo"
        err.mensaje = "El archivo no existe o no tiene permisos para verlo"
        err.mostrar_error()
    End If

    If modo = "get_properties" Then
        Dim rsRes As New tError
        rsRes.params("f_id") = file.f_id
        rsRes.params("filename") = file.filename
        rsRes.params("f_falta") = file.f_falta
        rsRes.params("f_nro_tipo") = file.f_nro_tipo
        rsRes.params("f_nro_ubi") = file.f_nro_ubi
        rsRes.params("f_size") = file.f_size
        rsRes.params("parent_ref_files_path") = file.parent_ref_files_path
        rsRes.params("ref_files_dir") = file.ref_files_dir
        rsRes.params("ref_files_path") = file.ref_files_path
        rsRes.params("login") = file.login
        rsRes.params("hasThumb") = nvFile.fileTypes(file.f_ext).hasThumb
        rsRes.response()
    End If

    arfile.Add("f_id", file.f_id)
    arfile.Add("filename", file.filename)
    arfile.Add("f_falta", file.f_falta)
    arfile.Add("f_nro_tipo", file.f_nro_tipo)
    arfile.Add("f_nro_ubi", file.f_nro_ubi)
    arfile.Add("f_size", file.f_size)
    arfile.Add("parent_ref_files_path", file.parent_ref_files_path)
    arfile.Add("ref_files_dir", file.ref_files_dir)
    arfile.Add("ref_files_path", file.ref_files_path)
    arfile.Add("login", file.login)
    arfile.Add("hasThumb", nvFile.fileTypes(file.f_ext).hasThumb)
    arfile.Add("ThumbBinary", file.getThumbBinary(False, 200, 200))
    Me.contents("file") = arfile

    'Me.contents("propiedades_generales") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_files'><campos>*, CONVERT(varchar, f_falta, 103) AS f_falta_str, CONVERT(varchar, f_falta, 108) AS f_hora_str</campos><filtro></filtro></select></criterio>")
    Me.contents("propiedades_DB") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_file_pvalues'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("propiedades_EXIF") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_file_pcats'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("propiedades_IPTC") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ref_file_pcats'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("params_categoria") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_file_pvalues'><campos>*</campos><orden>orden</orden><filtro></filtro></select></criterio>")



%>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>Propiedades de Archivos</title>
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            <style type="text/css">
            td.val1{
                padding: 3px;
            }
            </style>
            <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
            <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js" language='javascript'></script>
            <script type="text/javascript" src="/fw/script/nvFW_windows.js" language='javascript'></script>
            <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
           <% =Me.getHeadInit()%>
        <script type="text/javascript" language="javascript">

            var fimd_exif_array
            var fimd_iptc_array
            var file = nvFW.pageContents.file
            function window_onload() {
                cargarPropiedadesGenerales()
                //cargarPropiedadesDB()
                //cargarPropiedadesEXIF()
                //cargarPropiedadesIPTC()

                vMenuABMRefFilePvalues = new tMenu('divMenuABMRefFilePvalues', 'vMenuABMRefFilePvalues');
                Menus["vMenuABMRefFilePvalues"] = vMenuABMRefFilePvalues
                Menus["vMenuABMRefFilePvalues"].alineacion = 'centro';
                Menus["vMenuABMRefFilePvalues"].estilo = 'A';
                //Menus["vMenuABMRefFilePvalues"].imagenes = Imagenes //Imagenes se declara en pvUtiles            
                Menus["vMenuABMRefFilePvalues"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>General</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnGeneral_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABMRefFilePvalues"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Propiedades</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnBaseDeDatos_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")

                if (file.hasThumb) {
                    Menus["vMenuABMRefFilePvalues"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>EXIF</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnEXIF_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                    Menus["vMenuABMRefFilePvalues"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>IPTC</Desc><Acciones><Ejecutar Tipo='script'><Codigo>btnIPTC_onclick()</Codigo></Ejecutar></Acciones></MenuItem>")
                }
                Menus["vMenuABMRefFilePvalues"].CargarMenuItemXML("<MenuItem id='4' style='width: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenuABMRefFilePvalues.MostrarMenu()
            }

            function cargarPropiedadesGenerales() 
                {
                $('divGeneral').innerHTML = ''
                var strHTML = "<table id='tbGeneral' class='tb1' style='width:100%'>"
                var id_rfile_pcat
                strHTML += "<tr><td style=\"padding: 15px; width:120px; vertical-align: center; text-align: center;\"><img src=\"data:image/jpg;base64," + file.ThumbBinary + "\" /></td><td style=\"padding-left: 3px;\">" + file.filename + "</td></tr>";
                strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">ID</td><td style=\"padding: 3px;\">" + file.f_id + "</td></tr>";
                strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Ubicación</td><td style=\"padding: 3px;\">" + file.ref_files_path + "</td></tr>";
                strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Tamaño</td><td style=\"padding: 3px;\">" + file.f_size + " KB</td></tr>";
                strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Fecha de creación</td><td style=\"padding: 3px;\">" + FechaToSTR(file.f_falta) + ' ' + HoraToSTR(file.f_falta) + "</td></tr>";
                strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Operador</td><td style=\"padding: 3px;\">" + file.login + "</td></tr>";


                if (file.f_nro_tipo == 0 || file.f_nro_tipo == -1) {
                    strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Almacenamiento</td><td style=\"padding: 3px;\"><input onchange=\"onChangeNroUbi();\" name=\"f_nro_ubi\" type=\"radio\" value=\"1\"" + (file.f_nro_ubi == 1 ? "checked=\"checked\"" : "") + ">Sistema de Archivos&nbsp;&nbsp;<input onchange=\"onChangeNroUbi();\" name=\"f_nro_ubi\" type=\"radio\" value=\"2\"" + (file.f_nro_ubi == 1 ? "" : "checked=\"checked\"") + ">Base de Datos</td></tr>";
                } else {
                    strHTML += "<tr><td class=\"Tit1\" style=\"padding: 3px;\">Almacenamiento</td><td style=\"padding: 3px;\">" + (file.f_nro_ubi == 1 ? 'Sistema de Archivos' : 'Base de Datos') + "</td></tr>";
                }
                strHTML += "</table>";
                $('divGeneral').insert({top: strHTML});
               }


            //function obtener_nro_ubi(f_id) {
            //    var rs = new tRS();
            //    rs.open("<criterio><select vista='ref_files'><campos>f_nro_ubi</campos><orden></orden><filtro><f_id type='igual'>" + f_id + "</f_id></filtro></select></criterio>")
            //    return rs.getdata('f_nro_ubi');
                
            //}


            function onChangeNroUbi() {
                nvFW.confirm("¿Desea modificar el lugar donde se almacenan los archivos de esta carpeta?",
                {
                    width: 390,
                    cancel: function(win) {
                        $$('input[type="radio"][name="f_nro_ubi"]')[f_nro_ubi - 1].checked = true
                        win.close();
                    },
                    ok: function(win) {
                        guardarNroUbi();
                        win.close();
                    }
                });
            }


            function guardarNroUbi() {
                 
                var f_nro_ubi = $$('input[type="radio"][name="f_nro_ubi"]:checked')[0].value;
                var strXML = '<?xml version="1.0" encoding="iso-8859-1" ?>';
                strXML += '<ref_file f_id = "' + f_id + '" f_nro_ubi = "' + f_nro_ubi + '" >';
                strXML += '</ref_file>';
                nvFW.error_ajax_request('file_properties.aspx', {
                    parameters: { modo: 'guardarNroUbi',
                                  strXML: strXML
                                  },
                    onSuccess: function (err, transport) {
                        var f_id = err.params['f_id']
                        window.location.reload()
                        
                    }
                });
            }

            function cargarPropiedadesDB() 
                { 
                var id_rfile_pcat = 15
                var rs = new tRS();
                var filtroXML = nvFW.pageContents.propiedades_DB
                var filtroWhere = "<id_rfile_pcat type='igual'>" + id_rfile_pcat + "</id_rfile_pcat><f_id type='igual'>" + file.f_id + "</f_id>"
                rs.open(filtroXML, '', filtroWhere, '', '')
                while (!rs.eof()) 
                  {
                    //$('id_' + rs.getdata('rfile_param')).value = rs.getdata('id_rfile_param')
                    if (campos_defs.items[rs.getdata('rfile_param')] != undefined)
                        campos_defs.set_value(rs.getdata('rfile_param'), rs.getdata('rfile_pvalue'))
                    else
                        $(rs.getdata('rfile_param')).value = rs.getdata('rfile_pvalue')
                    rs.movenext()
                  }
                rs = new tRS();
                }

            function exp_ocul_propiedades(_this) {
                var name = (_this.name).split('-')
                var id = name[1]
                if (id != '') {
                    if ($(id).style.display == 'none') {
                        $(id).style.display = 'block'
                        _this.src = '../image/icons/menos.gif'
                    } else {
                        $(id).style.display = 'none'
                        _this.src = '../image/icons/mas.gif'
                    }
                }
            }

            function cargarPropiedadesEXIF() {
               
                if (f_id != 0) {
                    $('divEXIF').innerHTML = ''
                    var strHTML = "<table id='tbEXIF' class='tb1' style='width:100%'>"
                    var rfile_pcat = 'EXIF'
                    var id_rfile_pcat
                    var rs = new tRS();
                    var filtroXML = nvFW.pageContents.propiedades_EXIF
                    var filtroWhere = "<rfile_pcat type='like'>%" + rfile_pcat + "%</rfile_pcat>"
                    rs.open(filtroXML, '', filtroWhere, '', '')
                    //rs.open("<criterio><select vista='ref_file_pcats'><campos>*</campos><orden></orden><filtro><rfile_pcat type='like'>%" + rfile_pcat + "%</rfile_pcat></filtro></select></criterio>")
                    while (!rs.eof()) {
                        id_rfile_pcat = rs.getdata('id_rfile_pcat')
                        fimd_exif_array = new Array()
                        fimd_exif_array = getParamsCategoria(f_id, id_rfile_pcat)

                        if (fimd_exif_array.length > 0) {
                            menos = "<img alt='' name='img-" + rs.getdata('rfile_pcat') + "' src='../image/icons/menos.gif' style='cursor:pointer;cursor:hand' onclick='exp_ocul_propiedades(this)' />"

                            strHTML += "<tr>"
                            strHTML += "<td class='Tit1' style='width:100%;text-align:left'>" + menos + ' <b>' + rs.getdata('etiqueta') + "</b></td>"
                            strHTML += "</tr>"

                            strHTML += "<tr id='" + rs.getdata('rfile_pcat') + "' >"
                            strHTML += "<td>"
                            strHTML += "<table class='tb1' style='width:100%'>"

                            fimd_exif_array.each(function(arreglo, i) {
                                strHTML += "<tr>"
                                strHTML += "<td style='width:50%;text-align:left'>" + arreglo['etiqueta'] + "</td>"
                                strHTML += "<td style='width:50%;text-align:left'>" + arreglo['rfile_pvalue'] + "</td>"
                                strHTML += "</tr>"
                            });
                            strHTML += "</table>"
                            strHTML += "</td>"
                            strHTML += "</tr>"
                        }
                        rs.movenext()
                    }
                    strHTML += "</table>"
                    $('divEXIF').insert({top: strHTML})
                }
            }

            function cargarPropiedadesIPTC() {
               
                if (f_id != 0) {
                    $('divIPTC').innerHTML = ''
                    var strHTML = "<table id='tbIPTC' class='tb1' style='width:100%'>"
                    var rfile_pcat = 'IPTC'
                    var id_rfile_pcat
                    var rs = new tRS();
                    var filtroXML = nvFW.pageContents.propiedades_IPTC
                    var filtroWhere = "<rfile_pcat type='like'>%" + rfile_pcat + "%</rfile_pcat>"
                    rs.open(filtroXML, '', filtroWhere, '', '')
                    //rs.open("<criterio><select vista='ref_file_pcats'><campos>*</campos><orden></orden><filtro><rfile_pcat type='like'>%" + rfile_pcat + "%</rfile_pcat></filtro></select></criterio>")
                    while (!rs.eof()) {
                        id_rfile_pcat = rs.getdata('id_rfile_pcat')
                        fimd_iptc_array = new Array()
                        fimd_iptc_array = getParamsCategoria(f_id, id_rfile_pcat)

                        if (fimd_iptc_array.length > 0) {
                            menos = "<img alt='' name='img-" + rs.getdata('rfile_pcat') + "' src='../image/icons/menos.gif' style='cursor:pointer;cursor:hand' onclick='exp_ocul_propiedades(this)' />"

                            strHTML += "<tr>"
                            strHTML += "<td class='Tit1' style='width:100%;text-align:left'>" + menos + ' <b>' + rs.getdata('etiqueta') + "</b></td>"
                            strHTML += "</tr>"

                            strHTML += "<tr id='" + rs.getdata('rfile_pcat') + "' >"
                            strHTML += "<td>"
                            strHTML += "<table class='tb1' style='width:100%'>"

                            fimd_iptc_array.each(function(arreglo, i) {
                                strHTML += "<tr>"
                                strHTML += "<td style='width:50%;text-align:left'>" + arreglo['etiqueta'] + "</td>"
                                strHTML += "<td style='width:50%;text-align:left'>" + arreglo['rfile_pvalue'] + "</td>"
                                strHTML += "</tr>"
                            });
                            strHTML += "</table>"
                            strHTML += "</td>"
                            strHTML += "</tr>"
                        }
                        rs.movenext()
                    }
                    strHTML += "</table>"
                    $('divIPTC').insert({top: strHTML})
                }
            }

            function getParamsCategoria(f_id, id_rfile_pcat) {
                if (f_id != 0) {
                    var pvalues_db = new Array()
                    var j = 0
                    var rs1 = new tRS();
                    var filtroXML = nvFW.pageContents.params_categoria
                    var filtroWhere = "<id_rfile_pcat type='igual'>" + id_rfile_pcat + "</id_rfile_pcat><f_id type='igual'>" + f_id + "</f_id>"
                    rs.open(filtroXML, '', filtroWhere, '', '')
                    //rs1.open("<criterio><select vista='verRef_file_pvalues'><campos>*</campos><orden>orden</orden><filtro><id_rfile_pcat type='igual'>" + id_rfile_pcat + "</id_rfile_pcat><f_id type='igual'>" + f_id + "</f_id></filtro></select></criterio>")
                    while (!rs1.eof()) {
                        vacio = new Array()
                        vacio['etiqueta'] = rs1.getdata('etiqueta')
                        vacio['rfile_param'] = rs1.getdata('rfile_param')
                        vacio['rfile_pvalue'] = rs1.getdata('rfile_pvalue')
                        pvalues_db[j] = vacio
                        j++
                        rs1.movenext()
                    }
                    return pvalues_db
                }
            }

            var loadedPropiedadesDB = false
            var loadedEXIF = false
            var loadedIPTC = false

            function btnGeneral_onclick() {
                $('divGeneral').style.display = 'block'
                $('divIPTC').style.display = 'none'
                $('divIPTC').style.display = 'none'
                $('divBaseDeDatos').style.display = 'none'
            }

            function btnBaseDeDatos_onclick() {
                if (!loadedPropiedadesDB) {
                    cargarPropiedadesDB()
                    loadedPropiedadesDB = true
                }
                $('divGeneral').style.display = 'none'
                $('divEXIF').style.display = 'none'
                $('divIPTC').style.display = 'none'
                $('divBaseDeDatos').style.display = 'block'
            }

            function btnEXIF_onclick() {
                if (!loadedEXIF) {
                    cargarPropiedadesEXIF()
                    loadedEXIF = true
                }
                $('divGeneral').style.display = 'none'
                $('divIPTC').style.display = 'none'
                $('divBaseDeDatos').style.display = 'none'
                $('divEXIF').style.display = 'block'

            }

            function btnIPTC_onclick() {
                if (!loadedIPTC) {
                    cargarPropiedadesIPTC()
                    loadedIPTC = true
                }
                $('divGeneral').style.display = 'none'
                $('divEXIF').style.display = 'none'
                $('divBaseDeDatos').style.display = 'none'
                $('divIPTC').style.display = 'block'
            }

            function guardar_propiedades_db() 
                {
                var id_db_titulo = ""
                var db_titulo = $('db_titulo').value
                var id_db_fechahora = ""
                var db_fechahora = campos_defs.get_value('db_fechahora')
                var id_db_autor = ""
                var db_autor = $('db_autor').value
                var id_db_calificacion = ""
                var db_calificacion = campos_defs.get_value('db_calificacion')
                var id_db_notas = ""
                var db_notas = $('db_notas').value
                var id_db_palabrasclave = ""
                var db_palabrasclave = $('db_palabrasclave').value
                var id_db_categorias = ""
                var db_categorias = campos_defs.get_value('db_categorias')

                var strError = "";

                var strXML = ""
                strXML = "<?xml version='1.0' encoding='iso-8859-1'?>"
                strXML += "<ref_file f_id = '" + file.f_id + "'>"
                strXML += "  <file_pvalues>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_titulo + "' rfile_param = 'db_titulo' rfile_pvalue = '" + db_titulo + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_fechahora + "' rfile_param = 'db_fechahora' rfile_pvalue = '" + db_fechahora + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_autor + "' rfile_param = 'db_autor' rfile_pvalue = '" + db_autor + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_calificacion + "' rfile_param = 'db_calificacion' rfile_pvalue = '" + db_calificacion + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_notas + "' rfile_param = 'db_notas' rfile_pvalue = '" + db_notas + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_palabrasclave + "' rfile_param = 'db_palabrasclave' rfile_pvalue = '" + db_palabrasclave + "'/>"
                strXML += "    <ref_file_pvalues id_rfile_param = '" + id_db_categorias + "' rfile_param = 'db_categorias' rfile_pvalue = '" + db_categorias + "'/>"
                strXML += "  </file_pvalues>"
                strXML += "</ref_file>"

                nvFW.error_ajax_request('file_properties.aspx', {
                    parameters: {modo: 'M', strXML: strXML},
                    onSuccess: function(err, transport) { 
                        var f_id = err.params['f_id']
                        //window.location.reload()
                    }
                });
            }

            function allTrim(myString) {
                return myString.replace(/\s/g, '');
            }

            function formatear_palabrasclave(_this) {
                var palabras_clave = _this.value
                if (palabras_clave != '') {
                    palabras_clave = palabras_clave.replace(/(;|.\|,)+/g, '; ')
                    palabras_clave = palabras_clave.replace(/^(;|\.|,|\s)+/g, '').replace(/(;|\.|,|\s)+$/g, '')
                    _this.value = palabras_clave
                }
            }
        </script>
    </head>
    <body onload="return window_onload();" style="width: 100%; height: 100%; overflow: hidden">


            <div id="divFiltroDatos" style="width:100%">
                <div id="divMenuABMRefFilePvalues"></div>

                <div id="divGeneral" style="display: block; width: 100%; height: 390px; overflow: auto"></div>



                <div id="divBaseDeDatos" style="display: none; width: 100%; height: 390px; overflow: auto">
                    <div id="divMenuABMBaseDeDatos">
                    </div>

                    <script type="text/javascript" language="javascript">
            var vMenuABMBaseDeDatos = new tMenu('divMenuABMBaseDeDatos', 'vMenuABMBaseDeDatos');
            vMenuABMBaseDeDatos.loadImage("guardar", "../image/icons/guardar.png")
            Menus["vMenuABMBaseDeDatos"] = vMenuABMBaseDeDatos
            Menus["vMenuABMBaseDeDatos"].alineacion = 'centro';
            Menus["vMenuABMBaseDeDatos"].estilo = 'A';          
            Menus["vMenuABMBaseDeDatos"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_propiedades_db()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABMBaseDeDatos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenuABMBaseDeDatos.MostrarMenu()
                    </script>

                    <table class="tb1">
                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Título:
                            </td>
                            <td style="width: 90%" colspan="3" class="val1">
                                <textarea style='text-align: left; width: 100%;resize:none' rows="3" cols="135" name="db_titulo"
                                          id="db_titulo" ></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Autor:
                            </td>
                            <td style="width: 90%" colspan="3" class="val1">
                                <input style='text-align: left; width: 100%' type="text" name="db_autor" id="db_autor"
                                       value=""  />
                            </td>
                        </tr>

                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Fecha:
                            </td>
                            <td style="width: 40%" class="val1">
                                <script type="text/javascript">
                                    campos_defs.add('db_fechahora', {enDB: false, nro_campo_tipo: 103})
                                </script>

                            </td>
                            <td style="width: 10%" class='Tit1'>
                                Calificación:
                            </td>
                            <td style="width: 40%" class="val1">
                             <%=nvFW.nvCampo_def.get_html_input(campo_def:="db_calificacion", nro_campo_tipo:=1, enDB:=False, filtroXML:="<criterio><select vista='ref_file_db_calificaciones'><campos> distinct id_rfile_db_calificacion as id, rfile_db_calificacion as [campo] </campos><orden>[id]</orden></select></criterio>")%>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Categorías:
                            </td>
                            <td style="width: 90%" colspan="3" class="val1">
                             <%=nvFW.nvCampo_def.get_html_input(campo_def:="db_categorias", nro_campo_tipo:=2, enDB:=False, filtroXML:="<criterio><select vista='ref_file_db_categorias'><campos> distinct id_rfile_db_categoria as id, rfile_db_categoria as [campo] </campos><orden>[campo]</orden></select></criterio>")%>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Notas:
                            </td>
                            <td style="width: 90%" colspan="3" class="val1">
                                <textarea style='text-align: left; width: 100%;resize:none' rows="4" cols="135" name="db_notas"
                                          id="db_notas" ></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 10%" class='Tit1'>
                                Palabras Clave:
                            </td>
                            <td style="width: 90%" colspan="3" class="val1">
                                <textarea style='text-align: left; width: 100%;resize:none' rows="4" cols="135" name="db_palabrasclave"
                                          id="db_palabrasclave" onblur="formatear_palabrasclave(this)"></textarea>
                            </td>
                        </tr>
                    </table>
                </div>



                <div id="divEXIF" style="display: none; width: 100%; height: 390px; overflow: auto">
                </div>
                <div id="divIPTC" style="display: none; width: 100%; height: 390px; overflow: auto">
                </div>
                
                    
            </div>
       

    </body>
</html>