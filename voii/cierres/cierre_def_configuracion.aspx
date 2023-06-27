<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>


<%
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "VA")  ' VA 'Modo Vista Vacia'    V:'Modo Vista'    A:'Modo Alta'  M:'Modo Actualización'
    Dim id_cierre_def As String = nvFW.nvUtiles.obtenerValor("id_cierre_def", "")
    Dim nro_cierre_periodo As String = nvFW.nvUtiles.obtenerValor("nro_cierre_periodo", "")
    Dim id_win As String = nvFW.nvUtiles.obtenerValor("id_win", "")

    Dim nv_operador = nvFW.nvApp.getInstance.operador.operador

    Me.contents("filtro_cierre_def") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cierre_def'><campos>id_cierre_def,cierre_def,id_transferencia,id_periodicidad,id_cierre_tipo,orden</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierres_permisos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierres_permisos' distinct='true'><campos>nro_operador,nombre_operador,ejecuta,controla,anula</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_vercierre_def_dep") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vercierre_def_dep' ><campos>id_cierre_def,cierre_def,id_cierre_def_dep,cierre_def_dep</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierre_def2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierre_def' distinct='true'><campos>id_transferencia,cierre_def,id_cierre_tipo</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_periodicidad") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='periodicidad'><campos>id_periodicidad as id, periodicidad as [campo]</campos><orden>id_periodicidad</orden></select></criterio>")
    Me.contents("filtro_cierre_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cierre_tipo'><campos>id_cierre_tipo as id, cierre_tipo as [campo]</campos><orden>cierre_tipo</orden></select></criterio>")



    If accion.ToUpper() = "GUARDAR" Then
        Dim strxml = nvFW.nvUtiles.obtenerValor("strxml", "")
        Stop
        If (strxml <> "") Then
            Dim Err = New tError()
            Try
                Dim StrSQL = ""
                Dim XML = Server.CreateObject("Microsoft.XMLDOM")
                XML.loadXML("<?xml version='1.0' encoding='ISO-8859-1'?>" + strxml)
                Dim NodoReg = XML.selectSingleNode("/strxml/registro")
                Dim id_cierre = NodoReg.getAttribute("id_cierre_def")
                Dim cierre_def_desc = NodoReg.getAttribute("cierre_def_desc")
                Dim id_transferencia = NodoReg.getAttribute("id_transferencia")
                Dim id_periodicidad = NodoReg.getAttribute("id_periodicidad")
                Dim id_cierre_tipo = NodoReg.getAttribute("id_cierre_tipo")
                Dim orden = NodoReg.getAttribute("orden")

                Dim cn = DBConectar()

                'alta de cierre
                If (id_cierre = "") Then
                    If (orden = "") Then
                        StrSQL = "insert into cierre_def (cierre_def,id_transferencia,id_periodicidad,id_tarea,id_cierre_tipo,orden) values('" + cierre_def_desc + "'," + id_transferencia + "," + id_periodicidad + ",0," + id_cierre_tipo + ",1) "
                    Else
                        StrSQL = "insert into cierre_def (cierre_def,id_transferencia,id_periodicidad,id_tarea,id_cierre_tipo,orden) values('" + cierre_def_desc + "'," + id_transferencia + "," + id_periodicidad + ",0," + id_cierre_tipo + "," + orden + ") "
                    End If
                    cn.Execute(StrSQL)
                    StrSQL = "select  @@IDENTITY as id_cierre_def "
                    Dim Rs = cn.Execute(StrSQL)
                    id_cierre = Rs.Fields("id_cierre_def").Value
                    StrSQL = ""

                Else
                    'es una actualizacion
                    StrSQL += " update cierre_def set cierre_def='" + cierre_def_desc + "', id_transferencia=" + id_transferencia + ",id_periodicidad= " + id_periodicidad + ",id_cierre_tipo=" + id_cierre_tipo + ", orden=" + orden + " where id_cierre_def=" + id_cierre + " "
                    StrSQL += " delete from cierre_def_operador where id_cierre_def=" + id_cierre + " "
                    StrSQL += " delete from cierre_def_dep where id_cierre_def=" + id_cierre + " "
                End If

                Dim NODOperador = XML.selectNodes("/strxml/registro/operadores/operador")
                For i As Integer = 0 To NODOperador.length - 1
                    Dim controla As String = NODOperador(i).getAttribute("controla")
                    Dim anula As String = NODOperador(i).getAttribute("anula")
                    Dim ejecuta As String = NODOperador(i).getAttribute("ejecuta")
                    Dim operador As String = NODOperador(i).text
                    StrSQL += "insert into cierre_def_operador (id_cierre_def,nro_operador,ejecuta,controla,anula) values (" & id_cierre & "," & operador & "," & ejecuta & "," & controla & "," & anula & ") "
                Next

                Dim NODDependencias = XML.selectNodes("/strxml/registro/dependencias/id_cierre_def")
                For i As Integer = 0 To NODDependencias.length - 1
                    Dim id_cierre_def_dep = NODDependencias(i).text
                    StrSQL += "insert into cierre_def_dep (id_cierre_def,id_cierre_def_dep) values (" & id_cierre & "," & id_cierre_def_dep & ") "
                Next

                cn.execute(StrSQL)
                cn.close()


                Err.params("id_cierre_def") = id_cierre
                Err.params("numError") = 0
                Err.params("descError") = ""
                Err.numError = 0

            Catch e As Exception

                Err.parse_error_script(e)
            End Try
            Err.response()
        End If
    End If






%>
<html>
<head>
    <title>ABM Entidades</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var win
        var canc
        vPago_registro = {}
        var arrAcciones = {} //acciones aplicadas a este cierre_def

        function window_onresize() {
            try {

                var win = nvFW.getMyWindow()
                var dif = Prototype.Browser.IE ? 5 : 5
                var height_datos = $('divDatos').getHeight();
                var height_body = height_datos
                var h = height_body + dif + 12
                if (h > 0) {
                    var hdetCierres = h - 35;

                    win.setSize($$('body')[0].getWidth(), h);

                    $('divDetCierres').setStyle({ 'height': hdetCierres + 'px' });

                }

            }
            catch (e) { }
        }

        function window_onload() { 

            var win = getMyWindow()
            inicializar_componentes()
        }

        function inicializar_componentes() {

            campos_defs.add('id_transferencia', { target: 'tdTransf', enDB: true })
            campos_defs.add('orden', { target: 'tdOrden', enDB: false, nro_campo_tipo: 101 })
            campos_defs.add('id_periodicidad', { target: 'tdPeriodicidad', nro_campo_tipo: 1, enDB: false, mostrar_codigo: false, filtroXML: nvFW.pageContents.filtro_periodicidad })           

            var id_cierre_def = $F('this_id_cierre_def')
            var rs = new tRS()
            rs.open(nvFW.pageContents.filtro_cierre_def, "", "<id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def>")

            if (!rs.eof()) {
                
                var cierre_def = rs.getdata('cierre_def')
                var id_transferencia = rs.getdata('id_transferencia')
                var id_periodicidad = (rs.getdata('id_periodicidad')).replace(/ /g, '')
                var id_cierre_tipo = rs.getdata('id_cierre_tipo')
                var orden = rs.getdata('orden')

                $('cierre_def').value = cierre_def
                campos_defs.set_value('id_transferencia', id_transferencia)                
                campos_defs.set_value('id_periodicidad', id_periodicidad)
                campos_defs.set_value('id_cierre_tipos', id_cierre_tipo)
                campos_defs.set_value('orden', orden)
            }


            tbOperadores_cierre_redibujar()
            tbDependencias_cierre_redibujar()
        }


        function Cargar_configuracion_cierre() {

            var id_cierre_def = $F('this_id_cierre_def')
            var id_transferencia
            var id_cierre_tipo
            var rs = new tRS()
            rs.open(nvFW.pageContents.filtro_verCierre_def2, "", "<id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def>")
            while (!rs.eof()) {
                id_transferencia = rs.getdata('id_transferencia')
                id_cierre_tipo = rs.getdata('id_cierre_tipo')
                campos_defs.set_value('id_transferencia', id_transferencia)
                campos_defs.set_value('id_cierre_tipos', id_cierre_tipo)
                rs.movenext()
            }

        }

        function tbOperadores_cierre_redibujar() {
            
            var id_cierre_def = $F('this_id_cierre_def')
            var rs = new tRS()
            var strHtml = ''
            $$('tblOperadores tbody > tr').each(function (e) {
                e.remove()
            })

            rs.open(nvFW.pageContents.filtro_verCierres_permisos, "", "<id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def>")
            while (!rs.eof()) {


                nro_operador = rs.getdata('nro_operador')
                nombre_operador = rs.getdata('nombre_operador')
                nro_operador = rs.getdata('nro_operador')
                ejecuta = rs.getdata('ejecuta')
                strejecuta = (ejecuta == "True") ? 'checked="checked"' : ''
                controla = rs.getdata('controla')
                strcontrola = (controla == "True") ? 'checked="checked"' : ''
                anula = rs.getdata('anula')
                stranula = (anula == "True") ? 'checked="checked"' : ''

                strHtml = '<tr id="tr_' + nro_operador + '">'
                strHtml += '<td>(' + nro_operador + ') ' + nombre_operador + '</td>'
                strHtml += '<td style="text-align:center"><input type="checkbox" id="chkejecuta_' + nro_operador + '" ' + strejecuta + ' style="border:none" /></td>'
                strHtml += '<td style="text-align:center"><input type="checkbox" id="chkcontrola_' + nro_operador + '" ' + strcontrola + ' style="border:none" /></td>'
                strHtml += '<td style="text-align:center"><input type="checkbox" id="chkanula_' + nro_operador + '" ' + stranula + ' style="border:none" /></td>'
                strHtml += '<td style="text-align:center"><img onclick="operador_eliminar(' + nro_operador + ') " style="cursor:pointer" src="/FW/image/icons/eliminar.png" style="border:none" ></td>'
                strHtml += '</tr>'
                rs.movenext()
                $('tblOperadores').down('tbody').insert(strHtml);
            }
        }



        function tbDependencias_cierre_redibujar() {

            var id_cierre_def = $F('this_id_cierre_def')
            var rs = new tRS()
            var strHtml = ''
            $$('#tblDependencias tbody > tr').each(function (e) {
                e.remove()
            })

            rs.open(nvFW.pageContents.filtro_vercierre_def_dep, "", "<id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def>")
            while (!rs.eof()) {


                id_cierre_def_dep = rs.getdata('id_cierre_def_dep')
                cierre_def_dep = rs.getdata('cierre_def_dep')
                strHtml = '<tr id="tr_' + id_cierre_def_dep + '">'
                strHtml += '<td style="text-align:center"><input type="hidden" id="id_cierre_def_dep_' + id_cierre_def_dep + '" />(' + id_cierre_def_dep + ') ' + cierre_def_dep + '</td>'
                strHtml += '<td style="text-align:center"><img onclick="cierre_dep_eliminar(' + id_cierre_def_dep + ')" style="cursor:pointer" src="/FW/image/icons/eliminar.png" style="border:none" ></td>'
                strHtml += '</tr>'
                rs.movenext()
                $('tblDependencias').down('tbody').insert(strHtml);
            }
        }

        function operador_eliminar(id_cierre_def) {

            $$('#tblOperadores tbody > tr').each(function (e) {

                if (e.id == 'tr_' + id_cierre_def) {
                    e.remove()
                    return
                }
            })

        }

        function cierre_dep_eliminar(id_cierre_def) {

            $$('#tblDependencias tbody > tr').each(function (e) {
                if (e.id == 'tr_' + id_cierre_def) {
                    e.remove()
                    return
                }
            })

        }

        function addCierre_def_dep() {

            var id_cierre_def = $('id_cierre_def').value
            var cierre_def_desc = $('id_cierre_def_desc').value
            var existe = false
            var thisid_cierre_def = $('this_id_cierre_def').value

            if (id_cierre_def == '') {
                alert('No ha seleccionado un cierre para su dependencia')
                return
            }


            if (id_cierre_def == thisid_cierre_def) {
                alert('El cierre no puede ser dependiente de si mismo')
                return
            }

            $$('#tblDependencias tbody > tr').each(function (e) {
                var strId = e.id
                id_cierre_def_tr = strId.replace('tr_', '');
                if (id_cierre_def == id_cierre_def_tr) {
                    existe = true
                }
            })

            if (existe) {
                alert("El cierre que intenta ingresar como dependencia, ya fue ingresado anteriormente")
                return
            }
            var first = cierre_def_desc.indexOf("(");
            var last = cierre_def_desc.lastIndexOf(")");
            var strDef = cierre_def_desc.substring(0, first)


            strHtml = '<tr id="tr_' + id_cierre_def + '">'
            strHtml += '<td style="text-align:center"><input type="hidden" id="id_cierre_def_dep_' + id_cierre_def + '" />(' + id_cierre_def + ') ' + strDef + '</td>'
            strHtml += '<td style="text-align:center"><img onclick="cierre_dep_eliminar(' + id_cierre_def + ')" style="cursor:pointer" src="/FW/image/icons/eliminar.png" style="border:none" ></td>'
            strHtml += '</tr>'
            $('tblDependencias').down('tbody').insert(strHtml);

        }


        function addOperador_cierre() {

            var nro_operador = $('nro_operador').value
            var nro_operador_desc = $('nro_operador_desc').value

            var existe = false
          

            if (nro_operador == '') {
                alert('No ha seleccionado un operador')
                return
            }


            $$('#tblOperadores tbody > tr').each(function (e) {
                var strId = e.id
                nro_operador_tr = strId.replace('tr_', '');
                if (nro_operador == nro_operador_tr) {
                    existe = true
                }
            })

            if (existe) {
                alert("El operador que intenta ingresar, ya fue ingresado anteriormente")
                return
            }
            var first = nro_operador_desc.indexOf("(");

            var strOperador = nro_operador_desc.substring(0, first)


            strHtml = '<tr id="tr_' + nro_operador + '">'
            strHtml += '<td style="text-align:left">(' + nro_operador + ') ' + strOperador + '</td>'
            strHtml += '<td style="text-align:center"><input type="checkbox" id="chkejecuta_' + nro_operador + '"  style="border:none" /></td>'
            strHtml += '<td style="text-align:center"><input type="checkbox" id="chkcontrola_' + nro_operador + '"  style="border:none" /></td>'
            strHtml += '<td style="text-align:center"><input type="checkbox" id="chkanula_' + nro_operador + '"  style="border:none" /></td>'
            strHtml += '<td style="text-align:center"><img onclick="operador_eliminar(' + nro_operador + ') " style="cursor:pointer" src="/FW/image/icons/eliminar.png" style="border:none" ></td>'
            strHtml += '</tr>'
            $('tblOperadores').down('tbody').insert(strHtml);

        }


        function guardar() {

            var id_cierre_def = $F('this_id_cierre_def')
            var cierre_def_desc = $F('cierre_def')
            var id_transferencia = $F('id_transferencia')
            var id_periodicidad = $F('id_periodicidad')
            var id_cierre_tipo = campos_defs.get_value('id_cierre_tipos')  // $F('id_cierre_tipo')
            var orden = $F('orden')

            if (cierre_def_desc == '') {
                alert('No ha ingresado una descripcion para el cierre')
                return
            }

            if (id_transferencia == '') {
                alert('No ha seleccionado una transferencia para el cierre')
                return
            }

            if (id_periodicidad == '') {
                alert('No ha seleccionado una periodicidad para el cierre')
                return
            }

            if (id_cierre_tipo == '') {
                alert('No ha seleccionado un tipo de cierre')
                return
            }


            var strXMLoperadores = ''
            var acciona = false
            
            $$('#tblOperadores tbody > tr').each(function (e) {
                var nro_operador = (e.id).replace('tr_', '')
                var ejecuta = ($('chkejecuta_' + nro_operador).checked) ? 1 : 0
                var controla = ($('chkcontrola_' + nro_operador).checked) ? 1 : 0
                var anula = ($('chkanula_' + nro_operador).checked) ? 1 : 0
                if (ejecuta == 1 || controla == 1 || anula == 1) {
                    acciona = true
                }
                strXMLoperadores += '<operador ejecuta="' + ejecuta + '" controla="' + controla + '" anula="' + anula + '" >' + nro_operador + '</operador>'
            })

            if (strXMLoperadores == '') {
                alert('No has seleccionado un operador para el cierre')
                return
            }
            if (!acciona) {
                alert('No ha seleccionado al menos un permiso de operador para este cierre')
                return
            }
            var strXMLdependencias = ''
            $$('#tblDependencias tbody > tr').each(function (e) {
                var id_cierre_def = (e.id).replace('tr_', '')
                strXMLdependencias += '<id_cierre_def>' + id_cierre_def + '</id_cierre_def>'
            })

            var strxml = '<strxml><registro id_cierre_def="' + id_cierre_def + '"  cierre_def_desc="' + cierre_def_desc + '"  id_transferencia="' + id_transferencia + '" id_periodicidad="' + id_periodicidad + '" id_cierre_tipo="' + id_cierre_tipo + '" orden="' + orden + '" >'
            strxml += '<operadores>' + strXMLoperadores + '</operadores>'
            strxml += '<dependencias>' + strXMLdependencias + '</dependencias>'
            strxml += '</registro></strxml>'

            nvFW.error_ajax_request('cierre_def_configuracion.aspx', {
                parameters: {
                    accion: 'GUARDAR',
                    strxml: strxml
                },
                onSuccess: function (err, transport) {

                    var params = new Array()

                    params['status'] = ''
                    if (err.numError == 0) {
                        params['numError'] = err.params['numError']
                        params['descError'] = err.params['descError']
                        params['id_cierre_def'] = err.params['id_cierre_def']
                        if (params['numError'] == 0) {
                            params['status'] = 'OK'
                        } else {
                            params['status'] = 'ERROR'
                            alert(params['descError'])

                        }
                    }
                    var win = nvFW.getMyWindow()
                    win.options.userData = { params: params }
                    win.close()
                },
                   onError: function (err, transport) {
                       alert(err.value + ' ' + err.descError + 'aca' )
                   }
            });
        }

    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <form action="" method="post" name="form1" target="frmEnviar">
        <input type="hidden" id="id_win" value="<%=id_win %>" />
        <input type="hidden" id="num_error" name="num_error" value="" />
       <input type="hidden" id="this_id_cierre_def" name="this_id_cierre_def" value="<%= id_cierre_def %>" />
        <input type="hidden" id="modo" name="modo" value="<%= modo %>" />
        <input type="hidden" id="operador" name="operador" value="<%=nv_operador%>" />

        <div id='divDatos'>
            <div id="divMenuCierre"></div>
            <script type="text/javascript">
                var DocumentMNG = new tDMOffLine;
                var vMenuCierre = new tMenu('divMenuCierre', 'vMenuCierre');
                Menus["vMenuCierre"] = vMenuCierre
                Menus["vMenuCierre"].alineacion = 'centro';
                Menus["vMenuCierre"].estilo = 'A';

                vMenuCierre.loadImage("guardar", '/FW/image/icons/guardar.png')

                Menus["vMenuCierre"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuCierre"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 20%'><Lib TipoLib='offLine'>DocMNG</Lib><Desc>Guardar cierre</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones><icono>guardar</icono></MenuItem>")
                vMenuCierre.MostrarMenu()
            </script>
            <table class="tb1" style="width: 100%">
                <tr class="tbLabel">
                    <td style="width: 30%">Descripción</td>
                    <td style="width: 30%">Transferencia</td>
                    <td style="width: 13%">Periodicidad</td>
                    <td style="width: 13%">Tipo cierre</td>
                    <td style="width: 7%">Orden</td>
                    <td style="width: 7%">Vigente</td>
                </tr>
                <tr>
                    <td>
                        <input type="text" value="" id="cierre_def" style="width: 100%" />
                    </td>
                    <td id="tdTransf"></td>
                    <td id="tdPeriodicidad"></td>
                    <td><%=nvFW.nvCampo_def.get_html_input("id_cierre_tipos") %> </td>
                    <td id="tdOrden"></td>
                    <td style="text-align: center">
                        <input type="checkbox" id="vigente" checked="checked" /></td>
                </tr>
            </table>
            <div id="divOperadores" style="width: 60%; height: 284px; border: medium none; float: left; overflow: auto">
              
                 <table class="tb1" style="width: 100%">
                    <tr class="tbLabel">
                        <td>Agregar operador
                        </td>
                    </tr>
                </table>
                <table class="tb1" style="width: 100%">
                    

                    <tbody>
                        <tr>
                            <td><%=nvFW.nvCampo_def.get_html_input("nro_operador") %> </td>
                            <td style="text-align: center">
                                <input type="button" id="addbtn" value="+" onclick="addOperador_cierre()" />
                            </td>
                        </tr>
                    </tbody>


                </table> 
                <table class="tb1" style="width: 100%" id="tblOperadores">
                    <thead>
                        <tr class="tbLabel">
                            <td style="width: 40%">Operador</td>
                            <td style="width: 15%">Ejecuta</td>
                            <td style="width: 15%">Controla</td>
                            <td style="width: 15%">Anula</td>
                            <td style="width: 15%"></td> 
                        </tr> 
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
            <div id="divDependencias" style="width: 40%; height: 284px; float: left; overflow: auto">
                         
                 <table class="tb1" style="width: 100%">
                    <tr class="tbLabel">
                        <td>Agregar cierre dependiente
                        </td>
                    </tr>
                </table>
                <table class="tb1" style="width: 100%">
                   
                    <tbody>
                        <tr>
                            <th style="width: 80%"><%=nvFW.nvCampo_def.get_html_input("id_cierre_def") %> </th>
                            <th style="width: 20%; text-align: center"><input type="button" id="Button1" value="+" onclick="addCierre_def_dep()" /></th>
                        </tr>
                    </tbody>
                </table>
                <table class="tb1" style="width: 100%" id="tblDependencias">
                    <thead>
                        <tr class="tbLabel">
                            <td style="width: 85%">Cierre dependiente</td>
                            <td style="width: 15%"></td>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </form>
</body>
</html>
