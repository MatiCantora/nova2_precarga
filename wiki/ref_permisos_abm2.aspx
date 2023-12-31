<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nro_ref As String = nvFW.nvUtiles.obtenerValor("nro_ref", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")

    Me.contents("filtroVerReferencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verReferencia'><campos>*</campos><orden></orden><filtro><nro_ref type='igual'>%nro_ref%</nro_ref></filtro></select></criterio>")
    Me.contents("filtroCargarPermisos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.ref_obtener_permisos' ><parametros><nro_ref DataType='int'>%nro_ref%</nro_ref><vista DataType='int'>%vista%</vista></parametros></procedure></criterio>")
    Me.contents("filtroOperadorTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>*</campos><orden></orden><filtro><tipo_operador type='igual'>%tipo_operador%</tipo_operador></filtro></select></criterio>")
    Me.contents("filtroOperador") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores'><campos>distinct operador,upper(rtrim(strNombreCompleto)) as nombre_operador</campos><filtro><tipo_operador type='igual'>%tipo_operador%</tipo_operador></filtro><orden>nombre_operador</orden></select></criterio>")
    '   Me.contents("filtroOperadores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>*</campos><orden></orden><filtro><operador type='igual'>%nro_operador%</operador></filtro></select></criterio>")
    Me.contents("filtroOperadores") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>*</campos><orden></orden><filtro><operador type='igual'>%nro_operador%</operador></filtro></select></criterio>")

    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim err = New nvFW.tError()
       
    If (modo.ToUpper = "M") Then
        If (nro_ref <> "") Then
            Dim rs = nvFW.nvDBUtiles.DBOpenRecordset("select dbo.ref_permiso_operador(" + nro_ref + ") as permiso")
            Dim permiso As Integer = 0

            If Not rs.EOF Then
                permiso = rs.Fields("permiso").Value
            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            Dim mascara As Integer = 16
            Dim result As Integer = permiso And mascara

            If result = 16 Then
                Try
                    Dim cmd As New nvDBUtiles.tnvDBCommand("ref_permisos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
                    cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)

                    rs = cmd.Execute()

                    If Not rs.EOF Then
                        err.params("nro_ref") = rs.Fields("nro_ref").Value
                        err.numError = rs.Fields("numError").Value
                        err.titulo = rs.Fields("titulo").Value
                        err.mensaje = rs.Fields("mensaje").Value
                        err.comentario = rs.Fields("comentario").Value
                    End If

                    nvDBUtiles.DBCloseRecordset(rs)

                Catch ex As Exception
                    err.parse_error_script(ex)
                    err.titulo = "Error al guardar los permisos."
                    err.mensaje = "No se actualizaron los datos." & vbCrLf & err.mensaje
                End Try
            Else
                err.params.Add("nro_ref", nro_ref)
                err.numError = -10
                err.titulo = "Error en la actualizaci�n"
                err.mensaje = "No posee permisos para actualizar la informaci�n"
                err.response()
            End If
        Else
            err.params.Add("nro_ref", 0)
            err.numError = -10
            err.titulo = "Error en la actualizaci�n"
            err.mensaje = "No hay ning�n referencia seleccionado"
        End If
             
        err.response()
    End If


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Permisos de referencia</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/fw/css/calendar/css/jscal2.css" type="text/css" rel="stylesheet"  />

    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_basicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tCampo_def.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var permisos_particulares = new Array(),
            permisos_heredados = new Array(),
            nro_ref = 0

        var win = nvFW.getMyWindow()
        
        function window_onload() {

            campos_defs.items['tipo_operadores']['onchange'] = onchange_tipo_operador
            campos_defs.items['nro_operador']['onchange'] = onchange_nro_operador

            nro_ref = $('nro_ref').value
            if (nro_ref != 0) {
                var referencia = ''
                var ref_fecha = ''
                var ref_operador = ''
                var k = 0
                var vacio

                var rs = new tRS();
                var filtroXML = nvFW.pageContents.filtroVerReferencia
                var params = "<criterio><params nro_ref='" + nro_ref + "'/></criterio>"
                rs.open(filtroXML, '', '', '', params)    
                
                if (!rs.eof()) {
                    ref_fecha = FechaToSTR(new String(rs.getdata('ref_fecha_alta')))
                    ref_operador = rs.getdata('nombre_operador')
                    referencia = rs.getdata('referencia')

                    $('divCuadroPropiedades').innerHTML = ''
                    var strHTML = "<table id='tbPropiedadesRef' class='tb1' style='width:100%;'>"
                    strHTML += "<tr class='tbLabel0'><td style='width:100%;text-align:left' colspan='4'><b>Propiedades:</b></td></tr>"
                    strHTML += "<tr><td style='width:20%;text-align:left'>Referencia:</td><td colspan='3' style='width:30%;text-align:left'><b>" + referencia + "</b></td></tr>" 
                    strHTML += "<tr><td style='width:20%;text-align:left'>Fecha Alta:</td><td style='width:30%;text-align:left'>" + ref_fecha + "</td><td style='width:10%;text-align:left'>Operador:</td><td style='width:40%;text-align:left'>" + ref_operador + "</td></tr>" 
                    strHTML += "</table>"
                    $('divCuadroPropiedades').insert({ top: strHTML })
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
            nro_ref = $('nro_ref').value
            var vista = 3
            if (nro_ref != 0) {
                var k = 0
                var vacio
                var tipo_operador_todos  = 'NO EXISTE'

                var rs = new tRS();
                var filtroXML = nvFW.pageContents.filtroCargarPermisos
                var params = "<criterio><params nro_ref='"+nro_ref+"' vista='"+vista+"'/></criterio>"
                rs.open(filtroXML, '', '', '', params)  

                while (!rs.eof()) {
                    
                    vacio = new Array()
                    vacio['heredado'] = rs.getdata('heredado')
                    vacio['nro_ref'] = rs.getdata('nro_ref')
                    vacio['tipo_operador'] = rs.getdata('tipo_operador')
                    vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = rs.getdata('permiso')
                    vacio['nro_operador'] = rs.getdata('nro_operador')
                    vacio['Login'] = rs.getdata('Login')
                    vacio['referencia'] = rs.getdata('referencia')
                    vacio['ref_abreviada'] = rs.getdata('ref_abreviada')
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
            //strHTML += "<td class='Tit1' style='width:20%;text-align:left'>Ref. Promotor</td>"
            strHTML += "<td class='Tit1' style='width:25%;text-align:left'>Perfil/Operador</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Administrar Permisos</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Leer</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Modificar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Borrar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Subir Archivos</td>"
            strHTML += "<td class='Tit1' style='width:5%;text-align:center'>-</td>"
            strHTML += "<td class='Tit1' style='width:5%;text-align:center'>-</td>"
            strHTML += "</tr>"

            permisos_particulares.each(function(arreglo, i) {
                var admin = ''
                if (arreglo['tipo_operador'] == 1) {
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

                administrar_permisos = '<input type="checkbox" style="border:0" name="administrar_' + i + '" value="16" ' + checked_administrar_permisos + admin + ' onclick="editar_permiso(this);"></input>'
                leer = '<input type="checkbox" style="border:0" name="leer_' + i + '" value="8" ' + checked_leer + admin + ' onclick="editar_permiso(this);"></input>'
                borrar = '<input type="checkbox" style="border:0" name="borrar_' + i + '" value="4" ' + checked_borrar + admin + ' onclick="editar_permiso(this);"></input>'
                modificar = '<input type="checkbox" style="border:0" name="modificar_' + i + '" value="2" ' + checked_modificar + admin + ' onclick="editar_permiso(this);"></input>'
                subir = '<input type="checkbox" style="border:0" name="subir_' + i + '" value="1" ' + checked_subir + admin + ' onclick="editar_permiso(this);"></input>'

                eliminar = '<img alt="" title="Eliminar" src="/fw/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="eliminar_permiso_particular(' + i + ')" />'
                var descripcion = arreglo['tipo_operador_desc'] != null ? arreglo['tipo_operador_desc'] : arreglo['Login']

                operador_detalle = (arreglo['tipo_operador'] != 999 && arreglo['tipo_operador_desc'] != null) ? '<img alt="" title="Ver operadores" src="/fw/image/icons/buscar.png" style="cursor:pointer;cursor:hand" onclick="ver_operadores(' + arreglo['tipo_operador'] + ',\'' + arreglo['tipo_operador_desc'] + '\')" />' : '&nbsp;'

                strHTML += "<tr>"
                //strHTML += "<td style='width:20%;text-align:left' title='" + arreglo['referencia'] + "'>" + arreglo['ref_abreviada'] + "</td>"
                strHTML += "<td style='width:25%;text-align:left'>" + descripcion + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + administrar_permisos + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + leer + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + modificar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + borrar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + subir + "</td>"
                strHTML += "<td style='width:5%;text-align:center'>" + eliminar + "</td>"
                strHTML += "<td style='width:5%;text-align:center'>" + operador_detalle + "</td>"
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
            nro_ref = $('nro_ref').value
            var vista = 2
            if (nro_ref != 0) {
                var k = 0
                var vacio

                var rs = new tRS();
                var filtroXML = nvFW.pageContents.filtroCargarPermisos
                var params = "<criterio><params nro_ref='" + nro_ref + "' vista='" + vista + "'/></criterio>"  
                rs.open(filtroXML, '', '', '', params)

                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['heredado'] = rs.getdata('heredado')
                    vacio['nro_ref'] = rs.getdata('nro_ref')
                    vacio['tipo_operador'] = rs.getdata('tipo_operador')
                    vacio['tipo_operador_desc'] = (rs.getdata('tipo_operador_desc') == null && rs.getdata('tipo_operador') == 999) ? 'Todos' : rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = rs.getdata('permiso')
                    vacio['nro_operador'] = rs.getdata('nro_operador')
                    vacio['Login'] = rs.getdata('Login')
                    vacio['referencia'] = rs.getdata('referencia')
                    vacio['ref_abreviada'] = rs.getdata('ref_abreviada')
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
            strHTML += "<td class='Tit1' style='width:35%;text-align:left'>Perfil/Operador</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Administrar Permisos</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Leer</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Modificar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Borrar</td>"
            strHTML += "<td class='Tit1' style='width:12%;text-align:center'>Subir Archivos</td>"
            strHTML += "<td class='Tit1' style='width:5%;text-align:center'>-</td>"            
            strHTML += "</tr>"

            permisos_heredados.each(function(arreglo, i) {
                //mascara = 1:subir; 2:modificar; 4:eliminar; 8:leer; 16:administrar_permisos                
                checked_subir = ((arreglo['permiso'] & 1) == 1) ? 'checked="checked"' : ''
                checked_modificar = ((arreglo['permiso'] & 2) == 2) ? 'checked="checked"' : ''
                checked_borrar = ((arreglo['permiso'] & 4) == 4) ? 'checked="checked"' : ''
                checked_leer = ((arreglo['permiso'] & 8) == 8) ? 'checked="checked"' : ''
                checked_administrar_permisos = ((arreglo['permiso'] & 16) == 16) ? 'checked="checked"' : ''

                var descripcion = arreglo['tipo_operador_desc'] != null ? arreglo['tipo_operador_desc'] : arreglo['Login']
                //duplicado = arreglo['tipo_operador_desc']
                duplicado = (arreglo['duplicado'] == 1) ? "<strike>" + descripcion + "</strike>" : descripcion

                administrar_permisos = '<input type="checkbox" style="border:0" name="administrar_' + i + '" value="16" ' + checked_administrar_permisos + ' disabled="true"></input>'
                leer = '<input type="checkbox" style="border:0" name="leer_' + i + '" value="8" ' + checked_leer + ' disabled="true"></input>'
                borrar = '<input type="checkbox" style="border:0" name="borrar_' + i + '" value="4" ' + checked_borrar + ' disabled="true"></input>'
                modificar = '<input type="checkbox" style="border:0" name="modificar_' + i + '" value="2" ' + checked_modificar + ' disabled="true"></input>'
                subir = '<input type="checkbox" style="border:0" name="subir_' + i + '" value="1" ' + checked_subir + ' disabled="true"></input>'

                operador_detalle = (arreglo['tipo_operador'] != 999 && arreglo['tipo_operador'] != null) ? '<img alt="" title="Ver operadores" src="/fw/image/icons/buscar.png" style="cursor:pointer;cursor:hand" onclick="ver_operadores(' + arreglo['tipo_operador'] + ',\'' + arreglo['tipo_operador_desc'] + '\')" />' : ''

                strHTML += "<tr>"
                strHTML += "<td style='width:35%;text-align:left'>" + duplicado + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + administrar_permisos + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + leer + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + modificar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + borrar + "</td>"
                strHTML += "<td style='width:12%;text-align:center'>" + subir + "</td>"
                strHTML += "<td style='width:5%;text-align:center'>" + operador_detalle + "</td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('divPermisosHeredados').insert({ top: strHTML })
        }

        function eliminar_permiso_particular(i) {
            if (i >= 0) {
                var eliminar_admin_particular = true
                if (permisos_particulares[i]['tipo_operador'] == 1) {//cuando se quiere eliminar el perfil de "Administrador" propio

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
                    
                    var filtroXML = nvFW.pageContents.filtroOperadorTipo
                    var params = "<criterio><params tipo_operador='" + tipo_operador + "'/></criterio>"
                    rs.open(filtroXML, '', '', '', params) 

                    if (!rs.eof()) {

                        vacio['heredado'] = '0'
                        vacio['nro_ref'] = $('nro_ref').value
                        vacio['tipo_operador'] = tipo_operador
                        vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                        vacio['permiso'] = '0'   //se agrega con todos los permisos seleccionados (poner 0 para que los permisos no esten seleccionados)
                        vacio['referencia'] = ''
                        vacio['ref_abreviada'] = ''
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

        function pp_ref_distintos_igual_perfil_unificar_permiso(heredados) 
         {
                heredados.each(function(arreglo, i) {
                   heredados.each(function(arreglo_j, j) {
                       if ((arreglo['tipo_operador'] == arreglo_j['tipo_operador']) && (arreglo['permiso'] != arreglo_j['permiso'])) {
                            permiso = arreglo['permiso'] | arreglo_j['permiso']
                            arreglo['permiso'] = permiso
                            arreglo_j['permiso'] = permiso
                            arreglo_j['duplicado'] = 2
                        }
                    });
                    arreglo['referencia'] = ''
                    arreglo['ref_abreviada'] = ''
                });

                heredados.each(function(arreglo, i) {
                        if (arreglo['duplicado'] == 2) {
                            heredados.splice(i, 1);
                        }
                });
         }


        //Por cada perfil particular, controlo si ese perfil esta tb en heredados,
        //si es asi: copio el permiso (de ese perfil), de heredados a particular y elimino ese perfil de heredados
        //y por �ltimo concateno los perfiles particulares con los perfiles heredados diferentes
        function copiar_heredados_a_particulares() {
            
            var heredados = permisos_heredados

         //   pp_ref_distintos_igual_perfil_unificar_permiso(heredados)
                
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
                var filtroXML = nvFW.pageContents.filtroOperadorTipo
                var params = "<criterio><params tipo_operador='" + tipo_operador + "'/></criterio>"
                rs.open(filtroXML, '', '', '', params) 

                if (!rs.eof()) {

                    vacio['heredado'] = '0'
                    vacio['nro_ref'] = $('nro_ref').value
                    vacio['tipo_operador'] = tipo_operador
                    vacio['tipo_operador_desc'] = rs.getdata('tipo_operador_desc')
                    vacio['permiso'] = '31'   //se agrega con todos los permisos seleccionados (poner 0 para agregar sin permisos)
                    vacio['referencia'] = ''
                    vacio['ref_abreviada'] = ''
                    var indice = permisos_particulares.length
                    permisos_particulares[indice] = vacio
                }
                permisos_particulares_dibujar()
            }
        }

        function heredar_permisos(_this) {
            if (_this.checked) {
                if (permisos_heredados.length == 0) {
                    _this.checked = 1
                }
                $('divPermisosHeredados').style.display = 'block'
            } else {
                if (permisos_heredados.length > 0) {
                    nvFW.confirm("�Desea copiar los Permisos Heredados a los Permisos Particulares?", {
                        width: 300,
                        okLabel: "SI",
                        cancelLabel: "NO",
                        cancel: function(win) {
                            //conservar_perfil_administrador()
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

        function obtenerIndiceTipoOperadorEnPermisosParticular() //controla que tenga permiso por perfil o por operador
         { 
            var tipo_operador = 0
            var nro_operador = campos_defs.value('nro_operador')
            var rs = new tRS()
            var filtroXML = nvFW.pageContents.filtroOperadores
            var params = "<criterio><params nro_operador='" + nro_operador + "'/></criterio>"
            
			rs.open(filtroXML, '', '', '', params)  

            if (!rs.eof()) {
                tipo_operador = rs.getdata("tipo_operador")
                nro_operador = rs.getdata("operador")
            }
            var indice = -1

            if (tipo_operador > 0)
             {
                permisos_particulares.each(function(arreglo, i) {
                    if ((arreglo['tipo_operador'] == tipo_operador) || (arreglo['nro_operador'] == nro_operador)) {
                        indice = i
                    }
                });
             }
            return indice
        }


        function obtenerIndiceTipoOperadorEnPermisosHeredados() { //controla que tenga permiso por perfil o por operador

            var tipo_operador = 0
            var nro_operador = campos_defs.value('nro_operador')

            var rs = new tRS()
            var filtroXML = nvFW.pageContents.filtroOperadores
            var params = "<criterio><params nro_operador='" + nro_operador + "'/></criterio>"
            rs.open(filtroXML, '', '', '', params)  

            if (!rs.eof()) {
                tipo_operador = rs.getdata("tipo_operador")
                nro_operador = rs.getdata("operador")
            }
            var indice = -1
            if (tipo_operador > 0) {
                permisos_heredados.each(function(arreglo, i) {
                if ((arreglo['tipo_operador'] == tipo_operador) || (arreglo['nro_operador'] == nro_operador)) {
                        indice = i
                    }
                });
            }
            return indice
        }

        function guardar_ref_permisos()
        {
            var nro_ref         = $('nro_ref').value
            var hereda_permisos = $('hereda_permisos').checked ? '1' : '0'
            var strError        = "";

            //Validar los datos
            //if ((nro_ref != "") && (permisos_particulares.length == 0))
            //    strError += 'La referencia deben tener definici�n de Permisos Particulares<br />';

            if ((nro_ref != "") && (permisos_heredados.length == 0) && (permisos_particulares.length == 0) && hereda_permisos == '0')
                strError += 'Es una referencia con permisos propios,</br>debe definir permisos al menos</br>para su perfil';

            var indicep         = obtenerIndiceTipoOperadorEnPermisosParticular()
            var permiso_propios = 0
            
            if (indicep > -1)
                permiso_propios = permisos_particulares[indicep]['permiso']

            var indiceh       = obtenerIndiceTipoOperadorEnPermisosHeredados()
            var permiso_hered = 0

            if (indiceh > -1)
                permiso_hered = permisos_heredados[indiceh]['permiso']

            
            permisos_particulares.each(function(arreglo, i){
                if (arreglo['permiso']  > 23 ) {
                    indicep = i
                }
            });
            if (indicep == -1 && hereda_permisos == '0' )
            {
                strError += 'Debe asignarse como m�nimo los permisos<br/> de lectura y administraci�n de permisos<br/> porque sino se pierde la vinculaci�n con la misma';
            }

//            if ((nro_ref != "") && (permisos_heredados.length == 0 || indiceh == -1) && (permisos_particulares.length > 0) && permiso_propios < 24)
//                strError += 'Debe asignarse como m�nimo los permisos<br/> de lectura y administraci�n de permisos<br/> porque sino se pierde la vinculaci�n con la misma';
            
            if (strError != "") {
                alert(strError);
                return
            }
            
            valor_null_cambiar()
            
            var strXML = ""
            strXML = "<?xml version='1.0' encoding='ISO-8859-1'?>"
            strXML += "<ref nro_ref = '" + nro_ref + "' hereda_permisos = '" + hereda_permisos + "' >"
            strXML += "<permisos>"
            
            permisos_particulares.each(function(permiso_particular) {
                strXML += "<ref_permisos nro_ref = '" + permiso_particular['nro_ref'] + "' tipo_operador = '" + permiso_particular['tipo_operador'] + "' permiso = '" + permiso_particular['permiso'] + "' nro_operador = '" + permiso_particular['nro_operador'] + "' />"
            });
            
            strXML += "</permisos>"
            strXML += "</ref>"

            nvFW.error_ajax_request('ref_permisos_abm.aspx', {
                parameters: {
                    modo:    'M', 
                    nro_ref: nro_ref, 
                    strXML:  strXML
                },
                onSuccess: function (err, transport) {
                    var nro_ref = err.params['nro_ref']
                    var params  = []

                    params['nro_ref'] = nro_ref

                    win.returnValue = params
                    win.refresh()
                },
                bloq_msg: "Guardando permisos..."
            });
        }

        function ver_operadores(tipo_operador, tipo_operador_desc)
        {
                var strHTML = ''
                strHTML = "<table class='tb2'>"
                strHTML += "<tr>"
                strHTML += "<td colspan='2' style='text-align:center'><b>" + tipo_operador_desc + "</b></td>"
                strHTML += "</tr>"
                strHTML += "<tr class='tbLabel'>"
                strHTML += "<td style='width: 15%; text-align:center'><b>N�</b></td>"
                strHTML += "<td style='text-align:center' nowrap><b>Operador</b></td>"
                strHTML += "</tr>"
                strHTML += "</table>"
                strHTML += "<div style='height:130px;overflow:auto'>"
                strHTML += "<table class='tb2'>"

                var rs = new tRS();
                var filtroXML = nvFW.pageContents.filtroOperador
                var params = "<criterio><params tipo_operador='" + tipo_operador + "'/></criterio>"
                rs.open(filtroXML, '', '', '', params)  

                while (!rs.eof()) {
                    if (rs.getdata('nombre_operador') != null) {
                        strHTML += "<tr>"
                        strHTML += "<td class='Tit1' style='width: 15%; text-align:right'>" + rs.getdata("operador") + "</td>"
                        strHTML += "<td style='text-align:left' nowrap>&nbsp;" + rs.getdata('nombre_operador') + "</td>"
                        strHTML += "</tr>"
                    }
                    rs.movenext()
                }
                strHTML += "</table>"
                strHTML += "</div>"

               nvFW.alert(strHTML, { width: 450, height: 220, okLabel: "cerrar" });
           }


           function onchange_nro_operador() {
                //debugger
               var nro_operador = campos_defs.value('nro_operador')
               if (nro_operador != '') {
                   if (!nro_operador_existe_particular(nro_operador)) {
                       var k = 0
                       var rs = new tRS();
                       var vacio = new Array()
                       var filtroXML = nvFW.pageContents.filtroOperadores
                       var params = "<criterio><params nro_operador='" + nro_operador + "'/></criterio>"
                       rs.open(filtroXML, '', '', '', params)  

                       if (!rs.eof()) {

                           vacio['heredado'] = '0'
                           vacio['nro_ref'] = $('nro_ref').value
                           vacio['tipo_operador'] = 0
                           vacio['tipo_operador_desc'] = null
                           vacio['permiso'] = '0'   //se agrega con todos los permisos seleccionados (poner 0 para que los permisos no esten seleccionados)
                           vacio['referencia'] = ''
                           vacio['ref_abreviada'] = ''
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
    </script>

</head>
<body onload="return window_onload();" style="width: 100%; height: 100%; overflow: hidden">
    <form action="ref_permisos_abm.aspx" method="post" name="form1" target="frmEnviar" style="width: 100%; height: 100%; overflow: hidden">
    <input type="hidden" name="nro_ref" id="nro_ref" value="<%= nro_ref %>" />
    <input name="strXML" type="hidden" value="" />
    <input name="operador" id="operador" type="hidden" value="" />
    <div id="divFiltroDatos">
        <div id="divMenuABMRefPermisos"></div>
        <script type="text/javascript" language="javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuABMRefPermisos = new tMenu('divMenuABMRefPermisos', 'vMenuABMRefPermisos');
            Menus["vMenuABMRefPermisos"] = vMenuABMRefPermisos
            Menus["vMenuABMRefPermisos"].alineacion = 'centro';
            Menus["vMenuABMRefPermisos"].estilo = 'A';
            vMenuABMRefPermisos.loadImage("guardar", "/fw/image/icons/guardar.png")          
            Menus["vMenuABMRefPermisos"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar_ref_permisos()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABMRefPermisos"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
            vMenuABMRefPermisos.MostrarMenu()
        </script>
        <div id="divCuadroPropiedades"></div>

        <br />

        <div id="divMenuABMPermisosHeredados"></div>
        <script type="text/javascript" language="javascript">
            var DocumentMNG = new tDMOffLine;
            var vMenuABMPermisosHeredados = new tMenu('divMenuABMPermisosHeredados', 'vMenuABMPermisosHeredados');
            Menus["vMenuABMPermisosHeredados"] = vMenuABMPermisosHeredados
            Menus["vMenuABMPermisosHeredados"].alineacion = 'centro';
            Menus["vMenuABMPermisosHeredados"].estilo = 'A';
            Menus["vMenuABMPermisosHeredados"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos Heredados</Desc></MenuItem>")
            vMenuABMPermisosHeredados.MostrarMenu()
        </script>

        <table class="tb1">
            <tr>
                <td style="width: 5%; text-align: center;">
                    <input style="border:0" type="checkbox" name="hereda_permisos" id="hereda_permisos" value="" onclick="heredar_permisos(this);" />
                </td>
                <td style="width: 95%">
                    <p>
                        Hereda las entradas de permisos ...</p>
                </td>
            </tr>
        </table>
        <div id="divPermisosHeredadosContenedor" style="width: 100%; height: 160px; overflow: auto">
            <div id="divPermisosHeredados" style="width: 100%; height: 160px; overflow: auto">
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
            var DocumentMNG = new tDMOffLine;
            var vMenuABMPermisosParticulares = new tMenu('divMenuABMPermisosParticulares', 'vMenuABMPermisosParticulares');
            Menus["vMenuABMPermisosParticulares"] = vMenuABMPermisosParticulares
            Menus["vMenuABMPermisosParticulares"].alineacion = 'centro';
            Menus["vMenuABMPermisosParticulares"].estilo = 'A';
            vMenuABMPermisosParticulares.loadImage("agregar1", "/fw/image/icons/agregar.png")           
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos Particulares</Desc></MenuItem>")
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar1</icono><Desc>Agregar Perfil</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_permiso_particular_perfil()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar1</icono><Desc>Agregar Operador</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_permiso_particular_operador()</Codigo></Ejecutar></Acciones></MenuItem>")
            vMenuABMPermisosParticulares.MostrarMenu()
        </script>

        <div id="divPermisosParticulares" style="width: 100%; height: 160px; overflow: auto">
        </div>
    </div>
    <iframe name="frmEnviar" style="display: none" src="enBlanco.htm"></iframe>
    </form>
</body>
</html>
