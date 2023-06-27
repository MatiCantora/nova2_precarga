<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>


<%
    Dim razon_social = nvFW.nvUtiles.obtenerValor("razon_social", "")
    Dim origen = nvFW.nvUtiles.obtenerValor("origen", "")
    Dim modo = nvFW.nvUtiles.obtenerValor("modo")

    Dim currentTime = New Date()
    Dim mes = currentTime.Month + 1
    Dim dia = currentTime.Day
    Dim anio = currentTime.Year
    Dim nv_operador = nvFW.nvApp.getInstance.operador.operador 'Session.Contents("operador").operador

    Me.addPermisoGrupo("permisos_cierres")

    Dim fecha_actual = dia.ToString + "/" + mes.ToString + "/" + anio.ToString
    Me.contents("filtro_cierre_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cierre_tipo'><campos>id_cierre_tipo as id, cierre_tipo as [campo]</campos><orden>cierre_tipo</orden></select></criterio>")

    Me.contents("filtro_verCierreDet") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierre_det'><campos>nro_cierre_estado</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierreDet2") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierre_def'><campos>estado</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierreDet3") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vercierre_def_status_periodos'><campos>max(case when cierre_status = 'En ejecucion' then fe_desde else null end) as fecha_desde</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierresPermisos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierres_permisos'><campos>id_cierre_def, nro_operador, ejecuta, controla, anula</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verDefStatusPeriodos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vercierre_def_status_periodos'><campos>nro_cierre_periodo,cierre_periodo,fe_desde</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtro_verCierresAcciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierres_acciones'><campos>id_cierre_det</campos><orden></orden><filtro></filtro></select></criterio>")

    Dim verCierre_def = "<criterio><select vista='verCierre_def' distinct='true'><campos> id_cierre_def ,id_transferencia, cierre_def, id_cierre_tipo, cierre_tipo, nro_cierre_periodo, cierre_periodo, id_periodicidad, fe_desde, fe_hasta, estado, nro_cierre_estado"
    verCierre_def += ", CONVERT(varchar, fe_desde,103) as fecha_desde, CONVERT(varchar, fe_hasta, 103) as fecha_hasta, dbo.cierre_operador_permisos(%operador%, id_cierre_def, 'controla') as controla, dbo.cierre_operador_permisos(%operador%, id_cierre_def, 'ejecuta') as ejecuta, dbo.cierre_operador_permisos(%operador%, id_cierre_def, 'anula') as anula, %operador% as operador_login, cast(dbo.cierre_obtener_dependencias(id_cierre_def) as varchar(4000)) as dependencias"
    verCierre_def += ",case when estado=1 and nro_cierre_estado =1 then 'Iniciado'"
    verCierre_def += " when estado=0 and nro_cierre_estado is null then 'Pendiente'"
    verCierre_def += " when estado=-1 and (nro_cierre_estado is null OR nro_cierre_estado in (1,3)) then 'Esperando Dependencia'"
    verCierre_def += " when estado=2 then 'Controlado'"
    verCierre_def += " when estado=3 then 'Anulado'"
    verCierre_def += " else '' end as det_estado,orden</campos><orden>orden</orden><filtro></filtro><grupo>id_cierre_def, id_transferencia, cierre_def, id_cierre_tipo, cierre_tipo, nro_cierre_periodo, cierre_periodo, id_periodicidad, fe_desde, fe_hasta, estado, nro_cierre_estado, orden</grupo></select></criterio>"

    Me.contents("filtro_verCierre_def4") = nvFW.nvXMLSQL.encXMLSQL(verCierre_def)
    'Me.contents("filtro_verCierre_def4") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCierre_def'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")

    If (modo = "ANULAR") Then


        Dim err = New tError()

        Dim id_cierre_def = obtenerValor("id_cierre_def")
        Dim operador = nvFW.nvUtiles.obtenerValor("operador")
        Dim nro_cierre_periodo = obtenerValor("nro_cierre_periodo")
        Dim id_cierre_op_accion = 0
        Dim resultado = 0
        Dim cn = DBConectar()
        Dim StrSQL = ""

        Try
            Dim fso = Server.CreateObject("Scripting.FileSystemObject")

            Dim StrSQL1 = "select distinct link,nombre_archivo,ruta_archivo from verCierre_archivos where nro_cierre_periodo=" + nro_cierre_periodo + " and id_cierre_def=" + id_cierre_def + " and ruta_archivo<>"" and nro_cierre_estado<>3"
            Dim Rs1 = cn.Execute(StrSQL1)

            While Not Rs1.EOF

                Dim ruta_archivo = Rs1.Fields("ruta_archivo").Value
                Dim nombre_archivo = Rs1.Fields("nombre_archivo").Value
                ruta_archivo = Replace(ruta_archivo, "/", "\\")
                Dim filename = Server.MapPath("~/") + "Meridiano\\" + ruta_archivo 'Request.ServerVariables(4).Item + "Meridiano\\" + ruta_archivo
                Dim filedestino = Server.MapPath("~/") + "Meridiano\\directorio_archivos\\CIERRE\\ANULADOS\\" + nombre_archivo 'Request.ServerVariables(4).Item.toString() + "Meridiano\\directorio_archivos\\CIERRE\\ANULADOS\\" + nombre_archivo


                'si el archivo de destino existe, lo renombro
                If (fso.FileExists(filedestino)) Then
                    Dim fechaHs = New Date()
                    Dim _day
                    Dim _second
                    Dim _minute
                    Dim _hour
                    If (fechaHs.Hour < 10) Then _hour = "0" + fechaHs.Hour Else _hour = fechaHs.Hour
                    If (fechaHs.Minute < 10) Then _minute = "0" + fechaHs.Minute Else _minute = fechaHs.Minute
                    If (fechaHs.Second < 10) Then _second = "0" + fechaHs.Second Else _second = fechaHs.Second
                    If (fechaHs.Day < 10) Then _day = "0" + fechaHs.Day Else _day = fechaHs.Day
                    Dim nuevodestino = filedestino + "_" + fechaHs.Year + (fechaHs.Month + 1) + _day + "_" + _hour + _minute + _second
                    fso.MoveFile(filedestino, nuevodestino)
                    fso.DeleteFile(filedestino)
                End If

                'si el archivo existe, lo muevo de lugar
                If (fso.FileExists(filename)) Then
                    fso.MoveFile(filename, filedestino)
                End If

                Rs1.MoveNext()
            End While



        Catch e As Exception
            'try que sirve para poder eliminar archivos por mas que no se encuentren
        End Try
        Try

            StrSQL = "declare @stat tinyint \n"
            StrSQL += "exec dbo.rm_cierre_ingresar_controlV1 " + operador + "," + id_cierre_def + "," + nro_cierre_periodo + ",'ANULAR',"" \n"
            'StrSQL += "select @stat as resultado \n"
            Dim Rs = cn.Execute(StrSQL)
            resultado = Rs.Fields(0).Value
            cn.Close()


        Catch e As Exception
            err.numError = 1
            err.mensaje = ""
            err.parse_error_script(e)
            err.response()
        End Try

        err.numError = 0
        err.mensaje = resultado
        err.response()

    End If



%>
<html>
<head>
    <title>Control de cierres</title>
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

        //var permisos_cierres = nvFW.permiso_grupos.permisos_cierres

        var nro_entidad
        var razon_social
        var origen
        var isModal
        var cmb_tipo

        //Botones
        var vButtonItems = {}

        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Buscar";
        vButtonItems[0]["etiqueta"] = "Buscar";
        vButtonItems[0]["imagen"] = "buscar";
        vButtonItems[0]["onclick"] = "return buscar()";

        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage("buscar", '/FW/image/icons/buscar.png')

        function window_onresize() {
            var dif = Prototype.Browser.IE ? 5 : 2
            var body_h = $$('body')[0].getHeight()
            var divMenuCierres_h = $('divMenuCierres').getHeight()
            var tb_filtro_datos_h = $('tb_filtro_datos').getHeight()

            $('ifrCierres').setStyle({ 'height': body_h - divMenuCierres_h - tb_filtro_datos_h - dif + 'px' });
        }

        function window_onload() {
            
            vListButtons.MostrarListButton()           
            campos_defs.set_value('id_periodicidad', 3)
            campos_defs.set_value('cierre_tipo', '')
            campos_defs.items['cierre_tipo'].rs.position = campos_defs.items['cierre_tipo'].rs.position - 1
            campos_defs.set_value('cierre_tipo', campos_defs.items['cierre_tipo'].rs.getdata('id'))
            buscar()
            window_onresize()
        } 



        var win_cierre
        function mostrarDependencias(id_cierre_def, nro_cierre_periodo) {

            if (!nvFW.tienePermiso("permisos_cierres", 2)) {

                alert("No tiene permisos para realizar esta acción. comuniquese al administrador del sistema")
                return

            }
            else {

                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_cierre = w.createWindow({
                    className: 'alphacube',
                    title: '<b>Cierre</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    width: 900,
                    height: 350,
                    resizable: false

                })

                win_cierre.setURL("cierres/cierre_def_dep.aspx?modo=C&id_cierre_def=" + id_cierre_def + "&nro_cierre_periodo=" + nro_cierre_periodo + "&id_win=" + win_cierre.getId())
                win_cierre.showCenter(true)
            }

        }
        var id_transferencia
        var strParam

        function ejecutarCierre(id_cierre_def, nro_cierre_periodo, id_transferencia, cierre_periodo, cierre_def) {
            
            var str_mensaje = '¿Desea ejecutar el cierre ' + cierre_def + ' del periodo ' + cierre_periodo + '?'
            var operador = $F('operador')
            /*verificacion de permisos necesarios*/
            var rs1 = new tRS();
            rs1.open(nvFW.pageContents.filtro_verCierresPermisos, "", "<nro_operador type='igual'>" + operador + "</nro_operador><id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def><ejecuta type='igual'>1</ejecuta>")

            if (!rs1.eof()) {

                //*solo se puede ejecutar una transferencia si el cierre esta en estado pendiente*//
                var rs2 = new tRS();
                var estado = ''
                rs2.open(nvFW.pageContents.filtro_verCierreDet2, "", "<nro_cierre_periodo type='igual'>" + nro_cierre_periodo + "</nro_cierre_periodo><id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def>")
                if (!rs2.eof()) {
                    estado = rs2.getdata('estado')
                }
                //solo si el cierre esta en estado pendiente  o anulado, se puede ejecutar
                if (estado == 0 || estado == 3) {
                    var id_transferencia = id_transferencia
                    var strParam = '<parametros><nro_cierre_periodo>' + nro_cierre_periodo + '</nro_cierre_periodo></parametros>'
                    top.Dialog.confirm(str_mensaje, {
                        width: 267, height: 107, className: "alphacube",
                        ok: function (win) {
                            try {

                                nvFW.transferenciaEjecutar({
                                    id_transferencia: id_transferencia,
                                    xml_param: strParam,
                                    pasada: 0,
                                    formTarget: 'winPrototype',
                                    ej_mostrar: true,
                                    async: false,
                                    winPrototype: {
                                        modal: true,
                                        center: true,
                                        bloquear: false,
                                        url: 'enBlanco.htm',
                                        title: '<b>Ejecutar Cierre</b>',
                                        minimizable: false,
                                        maximizable: true,
                                        draggable: true,
                                        width: 800,
                                        height: 400,
                                        resizable: true,
                                        destroyOnClose: true,
                                        onClose: function () {
                                            buscar()
                                        }
                                    }
                                })
                                win.close()
                            } //fin del try
                            catch (e) {
                                return
                            } //fin del catch
                        },
                        cancel: function (win) {
                            return
                        }
                    })



                } else {
                    alert("La transferencia no se puede ejecutar por no está en estado PENDIENTE")
                }

            }
            else {
                alert("Usted no posee los permisos necesarios para realizar esta operacion")
            }

        }
        function controlarCierre(id_cierre_def, nro_cierre_periodo, str_cierre) {


            var operador = $F('operador')

            if (!nvFW.tienePermiso("permisos_cierres", 2)) {

                alert("No tiene permisos para realizar esta acción. comuniquese al administrador del sistema")
                return

            }
            else {


                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_cierre = w.createWindow({
                    className: 'alphacube',
                    title: '<b>Controlar cierre: ' + str_cierre + '</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: false,
                    width: 500,
                    height: 350,

                    resizable: false,
                    onClose: function () {

                        if (this.userData == "2") {

                            buscar()
                        }

                    }

                })

                win_cierre.setURL("cierres/cierre_control.aspx?modo=C&id_cierre_def=" + id_cierre_def + "&nro_cierre_periodo=" + nro_cierre_periodo + "&id_win=" + win_cierre.getId())
                win_cierre.showCenter(true)


            }


        }
        function mostrarArchivos(id_cierre_def, nro_cierre_periodo, str_cierre) {
            //window.parent.mostrarArchivos(id_cierre_def, nro_cierre_periodo)

            if (!nvFW.tienePermiso("permisos_cierres", 2)) {

                alert("No tiene permisos para realizar esta acción. comuniquese al administrador del sistema")
                return

            }
            else {

                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_cierre = w.createWindow({
                    className: 'alphacube',
                    title: '<b>Archivos</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    top: 0,
                    width: 1000,
                    height: 500,
                    resizable: true

                })

                win_cierre.setURL("cierres/cierre_def_archivos.aspx?modo=V&id_cierre_def=" + id_cierre_def + "&nro_cierre_periodo=" + nro_cierre_periodo + "&id_win=" + win_cierre.getId())
                win_cierre.showCenter(true)
            }



        }

        function mostrarHistorial(id_cierre_def, nro_cierre_periodo, str_cierre) {
            //window.parent.mostrarArchivos(id_cierre_def, nro_cierre_periodo)

            if (!nvFW.tienePermiso("permisos_cierres", 2)) {

                alert("No tiene permisos para realizar esta acción. comuniquese al administrador del sistema")
                return

            }
            else {

                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_cierre = w.createWindow({
                    className: 'alphacube',
                    title: '<b>Historial de acciones </b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    top: 0,
                    width: 900,
                    height: 350,
                    resizable: false

                })

                win_cierre.setURL("cierres/cierre_historial_acciones.aspx?modo=V&id_cierre_def=" + id_cierre_def + "&nro_cierre_periodo=" + nro_cierre_periodo + "&id_win=" + win_cierre.getId())
                win_cierre.showCenter(true)
            }
        }



        var ejecutando = false
        function anularCierre(id_cierre_def, nro_cierre_periodo, str_cierre) {

            var operador = $F('operador')
            var rs = new tRS();

            if (ejecutando) {
                return
            } else {
                ejecutando = true
            }

            //si el cierre esta unicamente en iniciado , se puede anular
            rs.open(nvFW.pageContents.filtro_verCierreDet, "", "<nro_cierre_periodo type='igual'>" + nro_cierre_periodo + "</nro_cierre_periodo><id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def><nro_cierre_estado type='igual'>1</nro_cierre_estado>")
            if (!rs.eof()) {

                var rs1 = new tRS();
                rs1.open(nvFW.pageContents.filtro_verCierresPermisos, "", "<nro_operador type='igual'>" + operador + "</nro_operador><id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def><anula type='igual'>1</anula>")
                if (!rs1.eof()) {
                    //verificar que antes no se haya ingresado un control del mismo
                    var rs2 = new tRS();
                    rs2.open(nvFW.pageContents.filtro_verCierresAcciones, "", "<nro_operador type='igual'>" + operador + "</nro_operador><nro_cierre_periodo type='igual'>" + nro_cierre_periodo + "</nro_cierre_periodo><id_cierre_def type='igual'>" + id_cierre_def + "</id_cierre_def><id_cierre_op_accion type='in'>2</id_cierre_op_accion>")
                    if (rs2.eof()) {
                        top.Dialog.confirm("¿Desea anular este cierre en este periodo?", {
                            width: 267, height: 107, className: "alphacube",
                            ok: function (win) {

                                nvFW.error_ajax_request('cierres.aspx', {
                                    parameters: { modo: 'ANULAR', id_cierre_def: id_cierre_def, operador: operador, nro_cierre_periodo: nro_cierre_periodo },
                                    onSuccess: function (err, transport) {

                                        resultado = err.mensaje
                                        if (err.numError == 0) {
                                            if (resultado == "3") {
                                                buscar()
                                                win.close()
                                            }
                                            else {
                                                top.alert("No se pudo anular el cierre")
                                                win.close()
                                            }
                                        } else {
                                            top.alert("Disculpe. No se pudieron realizar los cambios. Consulte con sistemas")
                                            win.close()
                                        }
                                        ejecutando = false
                                        return

                                    } //onsuccess
                                }); //ajax


                            } //ok
                               , cancel: function (win) {
                                   win.close();
                                   ejecutando = false
                               }
                        })//dialog 

                    }//rs2
                    else {
                        alert("No se puede anular porque usted ya ha ingresado una accion sobre este cierre")
                    }

                } else {
                    alert("Usted no tiene permisos para realizar esta accion")
                }
            } else {
                alert("El cierre no se puede anular ya que no esta en estado INICIADO")
            }

            ejecutando = false
            return
        }




        function buscar() {
            var criterio = '<criterio><select><filtro>'            
            var operador = $F('operador') 

            if (campos_defs.get_value('id_periodicidad') != '') 
                criterio += "<id_periodicidad type='igual'>" + campos_defs.get_value('id_periodicidad') + "</id_periodicidad>"
             
            if (campos_defs.get_value('cierre_tipo') != '') 
                criterio += '<nro_cierre_periodo type="igual">' + campos_defs.get_value('cierre_tipo') + '</nro_cierre_periodo>'

            if ($('cierre_buscar').value != '')
                criterio += '<cierre_def type="like">%' + $('cierre_buscar').value + '%</cierre_def>'

            if (criterio == '') {
                alert('Ingrese un criterio para realizar la búsqueda.')
                return
            }

            criterio += "<SQL type='sql'>(not(nro_cierre_estado=3) or nro_cierre_estado is null or (estado = 3 and nro_cierre_estado = 3) or (estado = -1 and nro_cierre_estado = 3))</SQL></filtro></select></criterio>"

            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.filtro_verCierre_def4,
                params: "<criterio><params operador='" + operador + "' /></criterio>",
                filtroWhere: criterio,
                path_xsl: 'report\\verCierre_det\\HTML_verCierre_det_detalle1.xsl',
                formTarget: 'ifrCierres',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'ifrCierres',
                cls_contenedor: 'ifrCierres'
            })

        } 


        function mostrarConfiguracion() {         

                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                winConf = w.createWindow({
                    className: 'alphacube',
                    title: '<b>Configuracion de cierres</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    top: 0,
                    width: 900,
                    height: 350,
                    resizable: false

                })

                winConf.setURL("cierres/cierre_def_consulta.aspx?modo=V&id_win=" + winConf.getId())
                winConf.showCenter(true)           
        }


    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: auto">
    <input type="hidden" id="operador" value="<%=nv_operador %>" />
    <div id="divMenuCierres"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuCierres = new tMenu('divMenuCierres', 'vMenuCierres');
        Menus["vMenuCierres"] = vMenuCierres
        Menus["vMenuCierres"].alineacion = 'centro';
        Menus["vMenuCierres"].estilo = 'A';

        vMenuCierres.loadImage("abm", "/FW/image/icons/abm.png");

        Menus["vMenuCierres"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Control de cierres</Desc></MenuItem>")
        Menus["vMenuCierres"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 20%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Configuración</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarConfiguracion()</Codigo></Ejecutar></Acciones></MenuItem>")

        vMenuCierres.MostrarMenu()
    </script>
    <table id='tb_filtro_datos' class="tb1" style="width: 100%">
        <tr class="tbLabel">
            <td style="width: 30%">Tipo de cierre</td>
            <td style="width: 20%">Periodo</td>
            <td style="width: 30%">Cierre</td>
            <td style="width: 20%">&nbsp</td>
        </tr>
        <tr> 
             <td>  
                 <script type="text/javascript">  
                     campos_defs.add('id_periodicidad')
                 </script>
             </td>
             
           <%-- <td> <select style="width: 100%" id="cbCierrePeriodo" name="cbCierrePeriodo"></select></td> --%>
            <td>
                <script type="text/javascript">                                          
                    campos_defs.add('cierre_tipo')
                </script>
            </td>
           
            <td>
                <input type="text" name="cierre_buscar" id="cierre_buscar" value="" style="width: 100%"/></td>
            <td>
                <div style='width: 100%'>
                    <div id="divBuscar"></div>
                </div>
            </td>
        </tr>
    </table>
    <iframe name="ifrCierres" id="ifrCierres" style="width: 100%; height: 100%; border: none" src="../enBlanco.htm"></iframe>
</body>
</html>
