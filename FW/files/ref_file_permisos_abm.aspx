<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<%
    
    
    
    Me.contents("file_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='ver_propiedades_ref_files'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("file_otener_permisos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.ref_file_obtener_permisos' CommantTimeOut='1500'><parametros><f_id DataType='int'>%f_id%</f_id><vista DataType='int'>%vista%</vista></parametros></procedure></criterio>")
    Me.contents("operador_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("operador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    
    Dim f_id = nvFW.nvUtiles.obtenerValor("f_id", "")
    Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
    
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim err As New nvFW.tError()
    
    If modo.ToUpper = "M" Then
        
        If f_id <> "" Then
            
            Dim rs1 = nvFW.nvDBUtiles.DBOpenRecordset("select dbo.ref_file_permiso_operador( '" + CType(f_id, String) + "') as permiso")
            Dim permiso = rs1.Fields("permiso").Value
            nvFW.nvDBUtiles.DBCloseRecordset(rs1)
            Dim mascara = 16
            Dim result = permiso and mascara

            If result = 16 Then
                Try
                    Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("ref_file_permisos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
                    Dim pStrXML As ADODB.Parameter
                    pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
                    cmd.Parameters.Append(pStrXML)
                    Dim rs As ADODB.Recordset
                    rs = cmd.Execute()
                    
                    f_id = rs.Fields("f_id").Value
                    err.params("f_id") = f_id
                    err.numError = rs.Fields("numError").Value
                    err.titulo = rs.Fields("titulo").Value
                    err.mensaje = rs.Fields("mensaje").Value
                    nvFW.nvDBUtiles.DBCloseRecordset(rs)
                
                
                Catch ex As Exception
                    err.parse_error_script(ex)
                    'err.mensaje = ""
                End Try
                
            Else
                err.params("f_id") = f_id
                err.numError = -10
                err.titulo = "Error en la actualización"
                err.mensaje = "No posee permisos para actualizar la información"
            End If
        
        Else
            err.params("f_id") = 0
            err.numError = -10
            err.titulo = "Error en la actualización"
            err.mensaje = "No hay ningún ref_file seleccionado"
        End If
        err.response()
        
        
    End If
    
    
    
    
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Permisos de Archivos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js" language='javascript'></script>
        <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
        <script type="text/javascript" src="/fw/script/tUpload.js" language="javascript"></script>
        <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var alert = function(msg) { window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 120, okLabel: "cerrar" }); }

        var permisos_particulares = new Array()
        var permisos_heredados = new Array()

        var permisos_particulares_operador = new Array()

        var f_id = 0

        var win = nvFW.getMyWindow()

        function window_onload() { 
            
            campos_defs.items['tipo_operadores']['onchange'] = onchange_tipo_operador
            campos_defs.items['nro_operador']['onchange'] = onchange_nro_operador

            f_id = $('f_id').value
            if (f_id != 0) {
                var ref_files_tipo = ''
                var ref_files_name = ''
                var ref_files_path = ''
                var ref_files_size = ''
                var ref_files_fecha = ''
                var ref_files_operador = ''
                var k = 0
                var rs = new tRS();
                var vacio
                var filtroXML = nvFW.pageContents.file_tipo
                var filtroWhere = "<f_id type='igual'>" + f_id + "</f_id>"
                rs.open(filtroXML, '', filtroWhere, '', '')
                //rs.open("<criterio><select vista='ver_propiedades_ref_files'><campos>*</campos><orden></orden><filtro><f_id type='igual'>" + f_id + "</f_id></filtro></select></criterio>")
                if (!rs.eof()) {
                    switch (rs.getdata('f_nro_tipo')) {
                        case '-1':
                            ref_files_tipo = 'Disco'
                            ref_files_name = rs.getdata('f_nombre')
                            break
                        case '0':
                            ref_files_tipo = 'Carpeta'
                            ref_files_name = rs.getdata('f_nombre')
                            break
                        case '1':
                            ref_files_tipo = 'Archivo'
                            ref_files_name = rs.getdata('f_nombre') + '.' + rs.getdata('f_ext')
                            ref_files_path = rs.getdata('f_path')
                            ref_files_size = rs.getdata('f_size')
                            break
                    }
                    ref_files_fecha = FechaToSTR(new String(rs.getdata('f_falta')))
                    ref_files_operador = rs.getdata('nombre_operador')

                    $('divCuadroPropiedades').innerHTML = ''
                    var strHTML = "<table id='tbPropiedadesRefFiles' style='width:100%;font-size:11px'>"
                    strHTML += "<tr class='tbLabel0'><td style='width:100%;text-align:left' colspan='4'><b>Propiedades:</b></td></tr>"
                    strHTML += (ref_files_tipo != '') ? "<tr><td style='width:20%;text-align:left'>Tipo:</td><td style='width:30%;text-align:left'><b>" + ref_files_tipo + "</b></td><td style='width:10%;text-align:left'>Nombre:</td><td style='width:40%;text-align:left'><b>" + ref_files_name + "</b></td></tr>" : ''
                    strHTML += (ref_files_path != '') ? "<tr><td style='width:20%;text-align:left'>Ubicación:</td><td style='width:30%;text-align:left'>" + ref_files_path + "</td><td style='width:10%;text-align:left'>Tamaño:</td><td style='width:40%;text-align:left'>" + ref_files_size + "</td></tr>" : ''
                    strHTML += (ref_files_fecha != '') ? "<tr><td style='width:20%;text-align:left'>Fecha última modificación:</td><td style='width:30%;text-align:left'>" + ref_files_fecha + "</td><td style='width:10%;text-align:left'>Operador:</td><td style='width:40%;text-align:left'>" + ref_files_operador + "</td></tr>" : ''
                    strHTML += "</table>"
                    $('divCuadroPropiedades').insert({ top: strHTML })
                    $('f_nro_tipo').value = rs.getdata('f_nro_tipo')
                }
                cargar_permisos_particulares()
                cargar_permisos_heredados()
                $('hereda_permisos').checked = (permisos_heredados.length > 0) ? 'checked' : ''
            }
        }

        function parseFecha(strFecha) {
            var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
            a = a.substr(0, a.indexOf('.'))
            var fe = new Date(Date.parse(a))
            return fe
        }

        function FechaToSTR(cadena) {
            var objFecha = parseFecha(cadena)
            var dia
            var mes
            var anio
            var hora
            var minuto
            var segundo
            if (isNaN(objFecha.getDate()))
                return ''

            dia = (objFecha.getDate() < 10) ? '0' + objFecha.getDate().toString() : objFecha.getDate().toString()
            mes = ((objFecha.getMonth() + 1) < 10) ? '0' + (objFecha.getMonth() + 1).toString() : (objFecha.getMonth() + 1).toString()
            anio = objFecha.getFullYear()

            hora = (objFecha.getHours() < 10) ? '0' + objFecha.getHours().toString() : objFecha.getHours().toString()
            minuto = ((objFecha.getMinutes() + 1) < 10) ? '0' + objFecha.getMinutes().toString() : objFecha.getMinutes().toString()
            segundo = ((objFecha.getSeconds() + 1) < 10) ? '0' + objFecha.getSeconds().toString() : objFecha.getSeconds().toString()

            return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + minuto + ':' + segundo
        }

        function cargar_permisos_particulares() { 
            permisos_particulares = new Array()
            f_id = $('f_id').value
            var vista = 3
            if (f_id != 0) {
                var k = 0
                var rs = new tRS();
                var vacio
                var filtroXML = nvFW.pageContents.file_otener_permisos
                var params = "<criterio><params f_id = '" + f_id + "' vista = '" + vista + "'></params></criterio>"
                rs.open(filtroXML, '', '', '', params)
                //rs.open("<criterio><procedure CommandText='dbo.ref_file_obtener_permisos' CommantTimeOut='1500'><parametros><f_id DataType='int'>" + f_id + "</f_id><vista DataType='int'>" + vista + "</vista></parametros></procedure></criterio>")
                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['heredado'] = rs.getdata('heredado')
                    vacio['f_id'] = rs.getdata('f_id')
                    vacio['tipo_operador'] = rs.getdata('tipo_operador')
                    vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = rs.getdata('permiso')
                    vacio['f_nro_tipo'] = rs.getdata('f_nro_tipo')
                    vacio['nro_operador'] = rs.getdata('nro_operador')
                    vacio['Login'] = rs.getdata('Login')
                    permisos_particulares[k] = vacio
                    k++
                    rs.movenext()
                }
                permisos_particulares_dibujar()
            }
        }

        function permisos_particulares_dibujar() { 
            $('divPermisosParticulares').innerHTML = ''
            var strHTML = "<table id='tbPermisosParticulares' class='tb1' style='width:100%'>"
            var checked_administrar_permisos
            var checked_leer
            var checked_modificar
            var checked_borrar
            var checked_subir

            strHTML += "<tr>"
            strHTML += "<td class='Tit1' style='width:35%;text-align:left'>Perfil/Operador</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Administrar Permisos</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Leer</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Modificar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Borrar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Subir Archivos</td>"
            strHTML += "<td class='Tit1' style='width:5%;text-align:center'></td>"
            strHTML += "</tr>"

            permisos_particulares.each(function(arreglo, i) {
            var admin = ''
            
                if (arreglo['tipo_operador'] == 4) { //administrador
                    admin = ' disabled="true"'
                    checked_administrar_permisos = 'checked="checked"'
                    checked_leer = 'checked="checked"'
                    checked_modificar = 'checked="checked"'
                    checked_borrar = 'checked="checked"'
                    checked_subir = 'checked="checked"'
                } else {
                    //mascara = 1:subir; 2:modificar; 4:eliminar; 8:leer; 16:administrar_permisos  
                    checked_subir = ((arreglo['permiso'] & 1) == 1) ? 'checked="checked"' : ''
                    checked_modificar = ((arreglo['permiso'] & 2) == 2) ? 'checked="checked"' : ''
                    checked_borrar = ((arreglo['permiso'] & 4) == 4) ? 'checked="checked"' : ''
                    checked_leer = ((arreglo['permiso'] & 8) == 8) ? 'checked="checked"' : ''
                    checked_administrar_permisos = ((arreglo['permiso'] & 16) == 16) ? 'checked="checked"' : ''
                }

                administrar_permisos = '<input type="checkbox" name="administrar_' + i + '" value="16" ' + checked_administrar_permisos + admin + ' onclick="editar_permiso(this);"></input>'
                leer = '<input type="checkbox" name="leer_' + i + '" value="8" ' + checked_leer + admin + ' onclick="editar_permiso(this);"></input>'
                borrar = '<input type="checkbox" name="borrar_' + i + '" value="4" ' + checked_borrar + admin + ' onclick="editar_permiso(this);"></input>'
                modificar = '<input type="checkbox" name="modificar_' + i + '" value="2" ' + checked_modificar + admin + ' onclick="editar_permiso(this);"></input>'
                subir = '<input type="checkbox" name="subir_' + i + '" value="1" ' + checked_subir + admin + ' onclick="editar_permiso(this);"></input>'

                eliminar = '<img alt="" title="Eliminar" src="../../fw/image/file_dialog/eliminar.png" style="cursor:pointer;cursor:hand" onclick="eliminar_permiso_particular(' + i + ')" />'
                var descripcion = arreglo['tipo_operador_desc'] != null ? arreglo['tipo_operador_desc'] : arreglo['Login']
                
                strHTML += "<tr>"
                strHTML += "<td style='width:35%;text-align:left'>" + descripcion + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + administrar_permisos + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + leer + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + modificar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + borrar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + subir + "</td>"
                strHTML += "<td style='width:5%;text-align:center'>" + eliminar + "</td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('divPermisosParticulares').insert({ top: strHTML })
        }
        

        function editar_permiso(_this) {
        
            var mascara = _this.value
            var name = (_this.name).split('_')
            var indice = name[1]
            permisos_particulares[indice]['permiso'] = (_this.checked) ? parseInt(permisos_particulares[indice]['permiso'],10)+parseInt(mascara,10) : parseInt(permisos_particulares[indice]['permiso'], 10)-parseInt(mascara, 10)
        }

        function cargar_permisos_heredados() {
            permisos_heredados = new Array()
            var heredados = new Array()
            f_id = $('f_id').value
            var vista = 2
            if (f_id != 0) {
                var k = 0
                var rs = new tRS();
                var vacio
                var filtroXML = nvFW.pageContents.file_otener_permisos
                var params = "<criterio><params f_id = '" + f_id + "' vista = '" + vista + "'></params></criterio>"
                rs.open(filtroXML, '', '', '', params)
                //rs.open("<criterio><procedure CommandText='dbo.ref_file_obtener_permisos' CommantTimeOut='1500'><parametros><f_id DataType='int'>" + f_id + "</f_id><vista DataType='int'>" + vista + "</vista></parametros></procedure></criterio>")
                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['heredado'] = rs.getdata('heredado')
                    vacio['f_id'] = rs.getdata('f_id')
                    vacio['tipo_operador'] = rs.getdata('tipo_operador')
                    vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = rs.getdata('permiso')
                    vacio['f_nro_tipo'] = rs.getdata('f_nro_tipo')
                    vacio['nro_operador'] = rs.getdata('nro_operador')
                    vacio['Login'] = rs.getdata('Login')
                    vacio['duplicado'] = 0
                    heredados[k] = vacio
                    k++
                    rs.movenext()
                }

                var particulares = permisos_particulares

                for (var i = 0; i < heredados.length; i++) {
                    for (var j = 0; j < particulares.length; j++) {
                        if ((heredados[i]['tipo_operador'] != null) && (heredados[i]['tipo_operador'] != 0)) {
                            if (heredados[i]['tipo_operador'] == particulares[j]['tipo_operador']) {
                                heredados[i]['duplicado'] = 1
                            }
                        }
                        if ((heredados[i]['nro_operador'] != null) && (heredados[i]['nro_operador'] != 0)) {
                            if (heredados[i]['nro_operador'] == particulares[j]['nro_operador'])
                                heredados[i]['duplicado'] = 1
                        }
                    }
                }
                permisos_heredados = heredados
                permisos_heredados_dibujar()
            }
        }


        function permisos_heredados_dibujar() {
            $('divPermisosHeredados').innerHTML = ''
            var strHTML = "<table id='tbPermisosHeredados' class='tb1' style='width:100%'>"
            var checked_administrar_permisos
            var checked_leer
            var checked_modificar
            var checked_borrar
            var checked_subir

            strHTML += "<tr>"
            strHTML += "<td class='Tit1' style='width:40%;text-align:left'>Perfil/Operador</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Administrar Permisos</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Leer</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Modificar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Borrar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Subir Archivos</td>"
            strHTML += "</tr>"

            permisos_heredados.each(function(arreglo, i) { 
                //mascara = 1:subir; 2:modificar; 4:eliminar; 8:leer; 16:administrar_permisos                
                checked_subir = ((arreglo['permiso'] & 1) == 1) ? 'checked="checked"' : ''
                checked_modificar = ((arreglo['permiso'] & 2) == 2) ? 'checked="checked"' : ''
                checked_borrar = ((arreglo['permiso'] & 4) == 4) ? 'checked="checked"' : ''
                checked_leer = ((arreglo['permiso'] & 8) == 8) ? 'checked="checked"' : ''
                checked_administrar_permisos = ((arreglo['permiso'] & 16) == 16) ? 'checked="checked"' : ''

                var descripcion = arreglo['tipo_operador_desc'] != null ? arreglo['tipo_operador_desc'] : arreglo['Login']
                duplicado = (arreglo['duplicado'] == 1) ? "<strike>" + descripcion + "</strike>" : descripcion

                administrar_permisos = '<input type="checkbox" name="administrar_' + i + '" value="16" ' + checked_administrar_permisos + ' disabled="true"></input>'
                leer = '<input type="checkbox" name="leer_' + i + '" value="8" ' + checked_leer + ' disabled="true"></input>'
                borrar = '<input type="checkbox" name="borrar_' + i + '" value="4" ' + checked_borrar + ' disabled="true"></input>'
                modificar = '<input type="checkbox" name="modificar_' + i + '" value="2" ' + checked_modificar + ' disabled="true"></input>'
                subir = '<input type="checkbox" name="subir_' + i + '" value="1" ' + checked_subir + ' disabled="true"></input>'

                strHTML += "<tr>"
                strHTML += "<td style='width:40%;text-align:left'>" + duplicado + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + administrar_permisos + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + leer + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + modificar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + borrar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + subir + "</td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('divPermisosHeredados').insert({ top: strHTML })
        }

        function eliminar_permiso_particular(i) {
            if (i >= 0) {
                var eliminar_admin_particular = true
                if (permisos_particulares[i]['tipo_operador'] == 4) {//cuando se quiere eliminar el perfil de "Administrador" propio

                    var admin_heredado = 0
                    if ($('hereda_permisos').checked) { //controlo si el checkbok "hereda permisos" esta seleccionado
                        for (var j = 0; j < permisos_heredados.length; j++) {//si el checkbox esta tildado, controlo que el perfil de "Administrador" este heredado
                            if (permisos_heredados[j]['tipo_operador'] == permisos_particulares[i]['tipo_operador']) {
                                admin_heredado = 1
                            }
                        }
                    }
                    //si el perfil "Administrador" no se hereda, entonces no es posible eliminar el perfil "Administrador" propio del archivo
                    if (admin_heredado == 0) {
                        eliminar_admin_particular = false
                        alert('No se puede eliminar el perfil Administrador')
                        return false
                    }
                }
                if (eliminar_admin_particular) {
                    permisos_particulares.splice(i, 1)
                    permisos_particulares_dibujar()
                    if (permisos_heredados.length > 0)
                        cargar_permisos_heredados()
                }
            }
        }

        function agregar_permiso_particular_perfil() {
            // si el objeto ya esta construido
            if (campos_defs.items['tipo_operadores']["window"] != undefined && campos_defs.items['tipo_operadores']["window"].campo_def_value != '') {
                campos_defs.items['tipo_operadores']["window"] = undefined
                campos_defs.clear('tipo_operadores')
            }
            campos_defs.clear('tipo_operadores')
            campos_defs.onclick('', 'tipo_operadores', true)
        }



        function agregar_permiso_particular_operador() {
            // si el objeto ya esta construido
            if (campos_defs.items['nro_operador']["window"] != undefined && campos_defs.items['nro_operador']["window"].campo_def_value != '') {
                campos_defs.items['nro_operador']["window"] = undefined
                campos_defs.clear('nro_operador')
            }
            campos_defs.clear('nro_operador')
            campos_defs.onclick('', 'nro_operador', true)
        
        }
        
        

        function onchange_tipo_operador() {
            var tipo_operador = campos_defs.value('tipo_operadores')
            if (tipo_operador != '') {
                if (!tipo_operador_existe_particular(tipo_operador)) {
                    var k = 0
                    var rs = new tRS();
                    var vacio = new Array()
                    var filtroXML = nvFW.pageContents.operador_tipo
                    var filtroWhere = "<tipo_operador type='igual'>" + tipo_operador + "</tipo_operador>"
                    rs.open(filtroXML, '', filtroWhere, '', '')
                    //rs.open("<criterio><select vista='operador_tipo'><campos>*</campos><orden></orden><filtro><tipo_operador type='igual'>" + tipo_operador + "</tipo_operador></filtro></select></criterio>")
                    if (!rs.eof()) {

                        vacio['heredado'] = '0'
                        vacio['f_id'] = $('f_id').value
                        vacio['tipo_operador'] = tipo_operador
                        vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                        vacio['permiso'] = '31'   //se agrega con todos los permisos seleccionados (poner 0 para que los permisos no esten seleccionados)
                        vacio['f_nro_tipo'] = $('f_nro_tipo').value
                        vacio['nro_operador'] = 0
                        vacio['Login'] = null
                        var indice = permisos_particulares.length
                        permisos_particulares[indice] = vacio
                        permisos_particulares_dibujar()
                        if (permisos_heredados.length > 0)
                            cargar_permisos_heredados()
                    }
                } else {
                    alert('El "Tipo de Operador" seleccionado, ya posee permisos');
                    return
                }
            }
        }

        function tipo_operador_existe_particular(tipo_operador) {
            var existe = false
            if (tipo_operador != '') {
                permisos_particulares.each(function(arreglo, i) {
                    if (arreglo['tipo_operador'] == tipo_operador) {
                        existe = true
                    }
                });
            }
            return existe
        }

        function tipo_operador_existe_heredado(tipo_operador) {
            var existe = false
            if (tipo_operador != '') {
                permisos_heredados.each(function(arreglo, i) {
                    if (arreglo['tipo_operador'] == tipo_operador) {
                        existe = true
                    }
                });
            }
            return existe
        }


        //Por cada perfil particular, controlo si ese perfil esta tb en heredados,
        //si es asi: copio el permiso (de ese perfil), de heredados a particular y elimino ese perfil de heredados
        //y por último concateno los perfiles particulares con los perfiles heredados diferentes
        function copiar_heredados_a_particulares() {
            
            var heredados = permisos_heredados
            for (var j = 0; j < permisos_particulares.length; j++) {
                for (var i = 0; i < heredados.length; i++) {
                    if ((permisos_particulares[j]['tipo_operador'] != 0) && (permisos_particulares[j]['tipo_operador'] != null)) {
                        if (permisos_particulares[j]['tipo_operador'] == heredados[i]['tipo_operador']) {
                            permisos_particulares[j]['permisos'] = heredados[i]['permisos']
                            permisos_particulares[j]['permiso'] = heredados[i]['permiso']
                            heredados.splice(i, 1);
                        }
                    }
                    if ((permisos_particulares[j]['nro_operador'] != 0) && (permisos_particulares[j]['nro_operador'] != null)) {
                        if (permisos_particulares[j]['nro_operador'] == heredados[i]['nro_operador']) {
                            permisos_particulares[j]['permisos'] = heredados[i]['permisos']
                            permisos_particulares[j]['permiso'] = heredados[i]['permiso']
                            heredados.splice(i, 1);
                        }
                    }
                }
            }
            permisos_particulares = permisos_particulares.concat(heredados);
        }

        function conservar_perfil_administrador() { 
            var tipo_operador = 4 //Administrador
            if (!tipo_operador_existe_particular(tipo_operador)) {
                var k = 0
                var rs = new tRS();
                var vacio = new Array()
                var filtroXML = nvFW.pageContents.operador_tipo
                var filtroWhere = "<tipo_operador type='igual'>" + tipo_operador + "</tipo_operador>"
                rs.open(filtroXML, '', filtroWhere, '', '')
                //rs.open("<criterio><select vista='operador_tipo'><campos>*</campos><orden></orden><filtro><tipo_operador type='igual'>" + tipo_operador + "</tipo_operador></filtro></select></criterio>")
                if (!rs.eof()) {

                    vacio['heredado'] = '0'
                    vacio['f_id'] = $('f_id').value
                    vacio['tipo_operador'] = tipo_operador
                    vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = '31'   //se agrega con todos los permisos seleccionados (poner 0 para agregar sin permisos)
                    vacio['f_nro_tipo'] = $('f_nro_tipo').value
                    var indice = permisos_particulares.length
                    permisos_particulares[indice] = vacio
                }
                permisos_particulares_dibujar()
            }
        }

        function heredar_permisos(_this) {
            if (_this.checked) {
                if (permisos_heredados.length == 0) {
                    _this.checked = ''
                }
                $('divPermisosHeredados').style.display = 'block'
            } else {
                if (permisos_heredados.length > 0) {
                    Dialog.confirm("¿Desea copiar los Permisos Heredados a los Permisos Particulares?", {
                        width: 300,
                        className: "alphacube",
                        okLabel: "SI",
                        cancelLabel: "NO",
                        cancel: function(win) {
                            conservar_perfil_administrador()
                            if (permisos_heredados.length > 0)
                                cargar_permisos_heredados()
                            win.close();
                        },
                        ok: function(win) {
                            var back_permisos_heredados = permisos_heredados
                            copiar_heredados_a_particulares()
                            permisos_particulares_dibujar()
                            if (permisos_heredados.length > 0)
                                permisos_heredados = back_permisos_heredados
                            cargar_permisos_heredados()
                            win.close()
                        }
                    });
                    $('divPermisosHeredados').style.display = 'none'
                }
            }
        }

        function guardar_ref_file_permisos() {
            
            var f_id = $('f_id').value
            var f_nro_tipo = $('f_nro_tipo').value
            var hereda_permisos = ($('hereda_permisos').checked) ? '1' : '0'
            var strError = "";

            //Validar los datos
            if ((f_id != "") && (f_nro_tipo == -1) && (permisos_particulares.length == 0))
                strError += 'Los Discos deben tener definición de Permisos Particulares<br />';

            if ((f_id != "") && (permisos_heredados.length == 0) && (permisos_particulares.length == 0))
                strError += 'Debe definir permisos al menos para el perfil "Administrador"<br />';

            if (strError != "") {
                alert(strError);
                return
            }
            
            valor_null_cambiar()
            
            var strXML = ""
            strXML = "<?xml version='1.0' encoding='iso-8859-1'?>"
            strXML += "<ref_files f_id = '" + f_id + "' hereda_permisos = '" + hereda_permisos + "' >"
            strXML += "<permisos>"
            permisos_particulares.each(function(arreglo, index) {
                strXML += "<ref_file_permisos f_id = '" + arreglo['f_id'] + "' tipo_operador = '" + arreglo['tipo_operador'] + "' permiso = '" + arreglo['permiso'] + "' nro_operador = '" + arreglo['nro_operador'] + "' />"
            });
            strXML += "</permisos>"
            strXML += "</ref_files>"


            nvFW.error_ajax_request('ref_file_permisos_abm.aspx', {
                parameters: { modo: 'M', f_id: f_id, strXML: strXML },
                onSuccess: function(err, transport) { 
                    var f_id = err.params['f_id']
                    var params = new Array()
                    params['f_id'] = f_id
                    //window.top.win.returnValue = params
                    win.returnValue = params
                    win.close()
                }
            });
        }


        function valor_null_cambiar() {
            permisos_particulares.each(function(arreglo, i) {
                if (arreglo['nro_operador'] == null) {
                    arreglo['nro_operador'] = 0
                }
                if (arreglo['tipo_operador'] == null) {
                    arreglo['tipo_operador'] = 0
                }
            });
        
        }



        function onchange_nro_operador() {
            
            var nro_operador = campos_defs.value('nro_operador')
            if (nro_operador != '') {
                if (!nro_operador_existe_particular(nro_operador)) {
                    var k = 0
                    var rs = new tRS();
                    var vacio = new Array()
                    var filtroXML = nvFW.pageContents.operador
                    var filtroWhere = "<operador type='igual'>" + nro_operador + "</operador>"
                    rs.open(filtroXML, '', filtroWhere, '', '')
                    //rs.open("<criterio><select vista='operadores'><campos>*</campos><orden></orden><filtro><operador type='igual'>" + nro_operador + "</operador></filtro></select></criterio>")
                    if (!rs.eof()) {

                        vacio['heredado'] = '0'
                        vacio['f_id'] = $('f_id').value
                        vacio['tipo_operador'] = 0
                        vacio['tipo_operador_desc'] = null
                        vacio['permiso'] = '31'   //se agrega con todos los permisos seleccionados (poner 0 para que los permisos no esten seleccionados)
                        vacio['f_nro_tipo'] = $('f_nro_tipo').value
                        vacio['nro_operador'] = rs.getdata('operador')
                        vacio['Login'] = rs.getdata('Login')
                        var indice = permisos_particulares.length
                        permisos_particulares[indice] = vacio
                        permisos_particulares_dibujar()
                        if (permisos_heredados.length > 0)
                            cargar_permisos_heredados()
                    }
                } else {
                    alert('El "Operador" seleccionado, ya posee permisos');
                    return
                }
            }
        }


        function nro_operador_existe_particular(nro_operador) {
            var existe = false
            if (nro_operador != '') {
                permisos_particulares.each(function(arreglo, i) {
                    if (arreglo['nro_operador'] == nro_operador) {
                        existe = true
                    }
                });
            }
            return existe
        }


        function nro_operador_existe_heredado(nro_operador) {
            var existe = false
            if (tipo_operador != '') {
                permisos_heredados.each(function(arreglo, i) {
                    if (arreglo['nro_operador'] == nro_operador) {
                        existe = true
                    }
                });
            }
            return existe
        }

       
 
    </script>

</head>
<body onload="return window_onload();" style="width: 100%; height: 100%; overflow: hidden">
    <input type="hidden" name="f_id" id="f_id" value="<%= f_id %>" />
    <input type="hidden" name="f_nro_tipo" id="f_nro_tipo" value="" />
    <input name="strXML" type="hidden" value="" />
    <input name="operador" id="operador" type="hidden" value="" />
    <div id="divFiltroDatos">
        <div id="divMenuABMRefFilePermisos">
        </div>

        <script type="text/javascript" language="javascript">
            var vMenuABMRefFilePermisos = new tMenu('divMenuABMRefFilePermisos', 'vMenuABMRefFilePermisos');
            vMenuABMRefFilePermisos.loadImage("guardar", "../image/file_dialog/guardar.png")
            Menus["vMenuABMRefFilePermisos"] = vMenuABMRefFilePermisos
            Menus["vMenuABMRefFilePermisos"].alineacion = 'centro';
            Menus["vMenuABMRefFilePermisos"].estilo = 'A';
            //Menus["vMenuABMRefFilePermisos"].imagenes = Imagenes //Imagenes se declara en pvUtiles            
            Menus["vMenuABMRefFilePermisos"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_ref_file_permisos()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABMRefFilePermisos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenuABMRefFilePermisos.MostrarMenu()
        </script>

        <div id="divCuadroPropiedades">
        </div>
        <br />
        <div id="divMenuABMPermisosHeredados">
        </div>

        <script type="text/javascript" language="javascript">
            var vMenuABMPermisosHeredados = new tMenu('divMenuABMPermisosHeredados', 'vMenuABMPermisosHeredados');
            Menus["vMenuABMPermisosHeredados"] = vMenuABMPermisosHeredados
            Menus["vMenuABMPermisosHeredados"].alineacion = 'centro';
            Menus["vMenuABMPermisosHeredados"].estilo = 'A';
            //Menus["vMenuABMPermisosHeredados"].imagenes = Imagenes //Imagenes se declara en pvUtiles            
            Menus["vMenuABMPermisosHeredados"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos Heredados</Desc></MenuItem>")
            vMenuABMPermisosHeredados.MostrarMenu()
        </script>

        <table class="tb1">
            <tr>
                <td style="width: 5%; text-align: center;">
                    <input type="checkbox" name="hereda_permisos" id="hereda_permisos" value="" onclick="heredar_permisos(this);" />
                </td>
                <td style="width: 95%;">
                    <p>
                        Hereda las entradas de permisos ...</p>
                </td>
            </tr>
        </table>
        <div id="divPermisosHeredadosContenedor" style="width: 100%; height: 120px; overflow: auto">
            <div id="divPermisosHeredados" style="width: 100%; height: 120px; overflow: auto">
            </div>
        </div>
        <table style="display: none">
            <tr>
                <td>
                    <%= nvFW.nvCampo_def.get_html_input("tipo_operadores")%>
                </td>
                <td>
                    <%= nvFW.nvCampo_def.get_html_input("nro_operador")%>
                </td>
            </tr>
        </table>
        <div id="divMenuABMPermisosParticulares">
        </div>

        <script type="text/javascript" language="javascript">
            var vMenuABMPermisosParticulares = new tMenu('divMenuABMPermisosParticulares', 'vMenuABMPermisosParticulares');
            vMenuABMPermisosParticulares.loadImage("agregar", "../image/file_dialog/agregar.png")
            Menus["vMenuABMPermisosParticulares"] = vMenuABMPermisosParticulares
            Menus["vMenuABMPermisosParticulares"].alineacion = 'centro';
            Menus["vMenuABMPermisosParticulares"].estilo = 'A';
            //Menus["vMenuABMPermisosParticulares"].imagenes = Imagenes //Imagenes se declara en pvUtiles            
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos Particulares</Desc></MenuItem>")
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Perfil</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_permiso_particular_perfil()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Operador</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_permiso_particular_operador()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMPermisosParticulares.MostrarMenu()
        </script>

        <div id="divPermisosParticulares" style="width: 100%; height: 120px; overflow: auto">
        </div>
    </div>
    <iframe name="frmEnviar" style="display: none" src="/fw/enBlanco.htm"></iframe>
</body>
</html>
