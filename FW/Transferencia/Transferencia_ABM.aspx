<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvDBUtiles" %>
<script runat="server" >

    Sub getPermisosTransferencia(id_transferencia As String)

        Dim strSQL As String = ""
        If id_transferencia <> "0" AndAlso id_transferencia <> "" Then

            strSQL = "SELECT nombre, cv.permiso_grupo " &
                     ",cv.nro_permiso AS permiso_ver" &
                     ",ce.nro_permiso AS permiso_editar" &
                     ",ci.nro_permiso AS permiso_imprimir" &
                     ",cj.nro_permiso AS permiso_ejecutar" &
                     ",dbo.[FW_permisos_perfiles] (cv.permiso_grupo) as valor" &
                     " FROM transferencia_cab a " &
                     "left outer join (select g.nro_permiso_grupo,permiso_grupo,nro_permiso,Permitir from operador_permiso_grupo g inner join operador_permiso_detalle d on g.nro_permiso_grupo = d.nro_permiso_grupo where permiso_grupo Like 'permisos_transferencia%') cv on cv.Permitir = (a.nombre + ' (' + cast(a.id_transferencia as varchar(50)) + ') ver')" &
                     "left outer join (select g.nro_permiso_grupo,permiso_grupo,nro_permiso,Permitir from operador_permiso_grupo g inner join operador_permiso_detalle d on g.nro_permiso_grupo = d.nro_permiso_grupo where permiso_grupo like 'permisos_transferencia%') ce on ce.Permitir = (a.nombre + ' (' + cast(a.id_transferencia as varchar(50)) + ') editar')" &
                     "left outer join (select g.nro_permiso_grupo,permiso_grupo,nro_permiso,Permitir from operador_permiso_grupo g inner join operador_permiso_detalle d on g.nro_permiso_grupo = d.nro_permiso_grupo where permiso_grupo Like 'permisos_transferencia%') ci on ci.Permitir = (a.nombre + ' (' + cast(a.id_transferencia as varchar(50)) + ') imprimir')" &
                     "left outer join (select g.nro_permiso_grupo,permiso_grupo,nro_permiso,Permitir from operador_permiso_grupo g inner join operador_permiso_detalle d on g.nro_permiso_grupo = d.nro_permiso_grupo where permiso_grupo Like 'permisos_transferencia%') cj on cj.Permitir = (a.nombre + ' (' + cast(a.id_transferencia as varchar(50)) + ') ejecutar')" &
                     " WHERE a.id_transferencia=" & id_transferencia

            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

            If Not rs.EOF Then

                If Me.permiso_grupos.ContainsKey(rs.Fields("permiso_grupo").Value) Then
                    Me.permiso_grupos.Remove(rs.Fields("permiso_grupo").Value)
                End If
                Me.permiso_grupos.Add(rs.Fields("permiso_grupo").Value, rs.Fields("valor").Value)

                Me.contents("permiso_grupo") = rs.Fields("permiso_grupo").Value
                Me.contents("nro_permiso_ver") = rs.Fields("permiso_ver").Value
                Me.contents("nro_permiso_editar") = rs.Fields("permiso_editar").Value
                Me.contents("nro_permiso_imprimir") = rs.Fields("permiso_imprimir").Value
                Me.contents("nro_permiso_ejecutar") = rs.Fields("permiso_ejecutar").Value

            End If

            nvDBUtiles.DBCloseRecordset(rs)
        End If
    End Sub

    Function getUltimasTresTransferencia() As String

        Dim res As String = "  transf = {"
        Dim contador As Integer = 1
        Dim strSQL As String = ""
        strSQL = "SELECT top 3 id_transferencia, nombre FROM transferencia_cab  " &
             " WHERE operador=" & nvApp.operador.operador & " order by transf_fe_modificado desc"

        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
        While Not rs.EOF

            If contador > 1 Then
                res += ","
            End If

            res += " transf" & contador & " : { 'pos' : '" & contador & "', id : '" & rs.Fields("id_transferencia").Value & "', 'nombre' : '" & rs.Fields("nombre").Value & "'}"
            contador += 1
            rs.MoveNext()

        End While
        res += "}"

        nvDBUtiles.DBCloseRecordset(rs)

        Return res
    End Function

</script>

<%

    'Debe tener el permiso para ver el modulo
    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_transferencia", 1) Then
        Response.Redirect("/fw/error/httpError_401.aspx?No tiene permisos de accesos.")
    End If

    Dim id_transferencia As String = nvFW.nvUtiles.obtenerValor("id_transferencia", "")
    Dim id_transf_version As String = nvFW.nvUtiles.obtenerValor("id_transf_version", "")

    Dim StrSQL As String = ""
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")         '//Modos --->    'C': Consulta - MC:Modif.Cabecera - AC:Alta Cabecera
    If (modo = "") Then modo = "C"

    If (modo.ToUpper = "SET_STRING_BASE64") Then

        Dim Err = New tError()
        Err.params("XMLXSLBase64") = ""

        Dim valor = nvUtiles.obtenerValor("valor", "")

        Try
            Err.params("XMLXSLBase64") = Convert.ToBase64String(nvConvertUtiles.StringToBytes(valor))
        Catch ex As Exception

            Err.parse_error_script(ex)
            Err.numError = -99
            Err.mensaje = "Error al generar informaci�n de plantilla"

        End Try

        Err.response()

    End If

    If (modo.ToUpper = "SET_BASE64_STRING") Then

        Dim Err = New tError()
        Err.params("XMLXSL") = ""

        Dim valor = nvUtiles.obtenerValor("valor", "")

        Try
            Err.params("XMLXSL") = nvConvertUtiles.BytesToString(Convert.FromBase64String(valor))
        Catch ex As Exception

            Err.parse_error_script(ex)
            Err.numError = -99
            Err.mensaje = "Error al generar informaci�n de plantilla"

        End Try

        Err.response()

    End If


    If modo.ToUpper() = "A" Then
        Dim Err As New nvFW.tError()

        'debe tener el permiso para editar el modulo
        op = nvApp.operador
        If Not op.tienePermiso("permisos_transferencia", 2) Then
            Err.numError = -1
            Err.titulo = "No se pudo completar la operaci�n. "
            Err.mensaje = "No tiene permisos para ver la p�gina."
            Err.response()
        End If

        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "") ' HttpUtility.UrlDecode(nvFW.nvUtiles.obtenerValor("strXML", ""))

        'Err.numError = 1
        'Err.mensaje = "Error al executar el procedimiento almacenado"
        Err.params("id_transferencia") = -1
        Err.params("nombre") = ""
        Try

            '//Ejecutar el procedimiento
            Dim Cmd As New ADODB.Command ' = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "[transf_abmv3.0]" '& version

            Dim BinaryData() As Byte
            BinaryData = System.Text.Encoding.GetEncoding("ISO-8859-1").GetBytes(strXML)

            Dim param As ADODB.Parameter = Cmd.CreateParameter("strXML0", 205, 1, BinaryData.Length, BinaryData)
            Cmd.Parameters.Append(param)

            Dim nombre As String = ""
            Dim rs As ADODB.Recordset = Cmd.Execute()
            If Not rs.EOF Then
                id_transferencia = rs.Fields("id_transferencia").Value
                nombre = rs.Fields("nombre").Value
                If id_transferencia = -1 Then
                    Err.numError = 1006
                    Err.titulo = "Guardado de transferencia"
                    Err.mensaje = "No se pudo realizar la acci�n"
                    Err.debug_src = "transferencia_abm.aspx"
                    Err.debug_desc = rs.Fields("error").Value
                Else
                    Err.params("id_transferencia") = id_transferencia
                    Err.params("nombre") = nombre

                    Cmd = New ADODB.Command ' = Server.CreateObject("ADODB.Command")
                    Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar
                    Cmd.CommandType = 4
                    Cmd.CommandTimeout = 1500
                    Cmd.CommandText = "[transf_auto_asignar_permiso]"
                    Dim paramId_transferencia As ADODB.Parameter = Cmd.CreateParameter("id_transferencia", ADODB.DataTypeEnum.adInteger, 1, -1, id_transferencia)
                    Cmd.Parameters.Append(paramId_transferencia)
                    Dim paramOperador As ADODB.Parameter = Cmd.CreateParameter("operador", ADODB.DataTypeEnum.adInteger, 1, -1, op.operador)
                    Cmd.Parameters.Append(paramOperador)
                    Dim rsAuto As ADODB.Recordset = Cmd.Execute()
                    If Not rsAuto.EOF Then
                        Err.numError = rsAuto.Fields("numError").Value
                        Err.mensaje = rsAuto.Fields("mensaje").Value
                        If Err.numError <> 0 Then
                            Err.titulo = "Error en la asignaci�n de permisos"
                            Err.debug_src = "transferencia_abm.aspx"
                        End If
                    End If
                    DBCloseRecordset(rsAuto)

                    getPermisosTransferencia(id_transferencia)
                End If

            End If
            DBCloseRecordset(rs)

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error al guardar la transferencia"
            Err.mensaje = "No se pudo rellizar el guardado." & vbCrLf & Err.mensaje
            Err.debug_src = "transferencia_abm.aspx"
        End Try
        Err.response()
    End If
    Dim imprimible = nvFW.nvUtiles.obtenerValor("imprimible", "false").ToLower = "true"


    Me.contents("filtroXML_transferencia_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_det'><campos>[id_transf_det],[id_transferencia],[orden],rtrim(ltrim([transf_tipo])) as transf_tipo,[transferencia],[opcional],[transf_estado],[dtsx_path],cast([TSQL] as varchar(max)) as [TSQL],[dtsx_parametros],[dtsx_exec],[filtroXML],[filtroWhere],[report_name],[path_reporte],[salida_tipo],[contentType],[target],[xsl_name],[path_xsl],cast([xml_xsl] as varchar(max)) as [xml_xsl],[xml_data],[vistaguardada],[metodo],[mantener_origen],[id_exp_origen],[parametros],[top],[left],[height],[width],[xls_path],[xls_path_save_as],[xls_visible],[xls_cerrar],[xls_guardar_resultado],[bpm_class],[parametros_extra_xml],[lenguaje],[cod_cn]</campos><filtro></filtro><orden>orden</orden></select></criterio>")
    Me.contents("filtroXML_transferencia_cab") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_cab'><campos>id_transferencia,nombre,habi,transf_version,log_param_save,case when (timeout/1000) &lt; 1 then timeout else (timeout/1000) end as timeout,isnull(id_transf_estado,1) as id_transf_estado,isnull(convert(varchar,transf_fe_creacion,103),'') as transf_fe_creacion_f,isnull(convert(varchar,transf_fe_creacion,108),'') as transf_fe_creacion_h,convert(varchar,isnull(transf_fe_modificado,getdate()),103) as transf_fe_modificado_f,convert(varchar,isnull(transf_fe_modificado,getdate()),108) as transf_fe_modificado_h,dbo.rm_nombre_operador(operador) as nombre_operador</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_transferencia_permisos") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_permisos'><campos>id_transferencia_lane as dbId, *</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_lanes") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_lanes'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_pools") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_pools'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros'><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>")
    Me.contents("filtroXML_transferencia_notas") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_notas'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_transferencia_notas_det") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_notas_det'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_types") = nvXMLSQL.encXMLSQL("<criterio><select vista=''><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_rel") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_rel'><campos>*</campos><filtro></filtro><orden>[orden]</orden></select></criterio>")
    Me.contents("filtroXML_ver_Transferencia_det_permisos") = nvXMLSQL.encXMLSQL("<criterio><select vista='ver_Transferencia_det_permisos'><campos>*</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")

    Me.contents("filtroXML_transferencia_parametros_NOS") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros_NOS'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_EQV") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros_EQV'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_IUS") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros_IUS'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_USR") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros_USR'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_XLS") = nvXMLSQL.encXMLSQL("<criterio><select vista='transferencia_parametros_XLS'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencia_parametros_TRA") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros_TRA'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroXML_transferencias_version") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTransf_versiones'><campos>id_transf_version,id_transferencia,descripcion,vigente,cast(valor as varchar(max)) as valor,fe_transf_version </campos><filtro></filtro><orden>vigente desc,fe_transf_version desc </orden></select></criterio>")

    '    Me.contents("filtroXML_operador_permisos") = nvXMLSQL.encXMLSQL("<criterio><select vista='verOperador_permisos'><campos>permiso_grupo,Permitir</campos><filtro><permiso_grupo type='like'>permisos_transferencia_auto_%</permiso_grupo></filtro><orden></orden></select></criterio>")

    Me.addPermisoGrupo("permisos_transferencia")
    getPermisosTransferencia(id_transferencia)
    Me.contents("transf_recientes") = getUltimasTresTransferencia()


%>


<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title></title> 
        <meta http-equiv="X-UA-Compatible" content="IE=8"/>
        <script type="text/javascript" src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>     
        
        <script type="text/javascript" src="/FW/transferencia/script/tRect.js"></script>
        <script type="text/javascript" src="/FW/transferencia/script/transf_destino_utiles.js"></script>
        <script type="text/javascript" src="/FW/transferencia/script/tUndo.js"></script>
             
        <link href="/FW/transferencia/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/transferencia/css/Rect.css" type="text/css" rel="stylesheet" class='link_estable'/>
        <link href="/FW/transferencia/css/transferencia.css" type="text/css" rel="stylesheet"/>
        <style type="text/css">
       
        </style>
        <% = Me.getHeadInit()%>
        <script type="text/javascript">
            var imprimible = '<%= imprimible %>' == 'true'? true : false;
            var version = '';
            var Transferencia = {
                parametros: [],
                pools: [],
                detalle: [],
                relations: [],
                annotations: []
            };
            var oCB1; //canvas
            var Undo;
            var counter = 0;
        </script>
        <script type="text/javascript">
            function alert(msg, width, height) {
                if (width === undefined) {
                    width = 300;
                }
                if (height === undefined) {
                    height = 100;
                }
                Dialog.alert(msg, {className: 'alphacube', width: width, height: height, okLabel: "cerrar"});
            }
            function redirectToTransferABM(id_transferencia) {
                var httpQuery = '';
                if (id_transferencia) {
                    httpQuery = '?id_transferencia=' + id_transferencia;
                }
                window.location = "transferencia_ABM.aspx" + httpQuery;
            }

            var win = nvFW.getMyWindow()

            var xmlCopy = ""
            function transf_copy(e) {
                document.execCommand('copy');
            }

            var eCopyBorrar = false
            var eClear = false
            function transf_clear_event_copy() {
                eClear = true
                document.execCommand('copy');
            }
           
            function windows_onload() {

            
               document.addEventListener('copy', function (e) {

                 //  if (Element.event(e).type == 'input')

                   e.preventDefault();

                   if (eCopyBorrar) {
                       e.clipboardData.clearData()
                       e.clipboardData.setData('text/plain', "");
                       eCopyBorrar = false
                   }

                   if (eClear) {
                       eClear = false
                       return null;
                   }

                   if ($('container') && Event.element(e).type != "text") {
                       var strXML = makeXML("0", "copy")
                       xmlCopy = strXML
                       eCopyBorrar = true
                       if (e.clipboardData) 
                           e.clipboardData.setData('text/plain', strXML);
                       else
                       if (window.clipboardData) 
                           window.clipboardData.setData('Text', strXML);
                   }

               });


               document.addEventListener('paste', function (e) {                                         
                   
                   e.preventDefault();
                   
                   if ($('container') && Event.element(e).type != "text") {
                       
                       if (e.clipboardData) {
                           //Event.element(e).value = e.clipboardData.getData('text/plain');
                           xmlCopy = e.clipboardData.getData('text/plain');
                       }
                       else
                         if (window.clipboardData) 
                               xmlCopy = window.clipboardData.getData('Text');
                           
                       ctrl_newPaste()
                       // e.clipboardData.clearData()
                   }

                });

                if (win)
                    if (('getId' in win)) {
                        parent.$(win.getId() + '_close').onclick = function (e) {
                            
                            var xml_muestra = Undo.list.length > 0 ? Undo.list[0].obj : ""
                            if (xml_muestra !=  makeXML()) {
                                confirm("�Desea salir del m�dulo de procesos y tareas?", {
                                    width: 400,
                                    height: "auto",
                                    className: "alphacube",
                                    okLabel: "Si",
                                    cancelLabel: "No",
                                    onOk: function (w) {
                                        win.close(); return
                                    },
                                    onCancel: function (w) {
                                        w.close(); return
                                    }
                                });
                            }
                            else
                                 win.close(); 
                        }

                    }
             

                nvFW.enterToTab = false
                crearMenues();
                createCanvas();
                crearUndo();
                var id_transferencia = parseInt('<%= id_transferencia %>');
                var id_transf_version = parseInt('<%= id_transf_version %>');
                
                if (id_transferencia) {
                    cargarTransferencia(id_transferencia,id_transf_version);
                } else {
                    newTransferencia();
                }

                campos_defs.items['id_transferencia']['onchange'] = onChangeIdTransferencia;
                $(document).observe('keydown', function() {
                    stopAll();
                });

                window_onresize();

                if(imprimible){
                    var visible = $('container');
                    visible.setStyle({
                        top: '0px',
                        left: '0px',
                        right: '0px',
                        bottom: '0px'
                    });
                    $$('body')[0].update(visible);
                }
                ['nombre', 'timeout'].each(function (input) {

              /*      Event.observe(input, "click", function (event) {
                        Transferencia.detalle.each(function (element) {
                            element.select(false);
                        });
                        Transferencia.annotations.each(function (element) {
                            element.select(false);
                        });
                    });*/

                    $(input).observe('focus', function(){
                        selectNone();
                    });
                    $(input).observe('click', function(){
                        selectNone();
                    });

                    $('container').observe('click', function(){
                        $(input).blur();
                    });
                });
            }
            function selectNone() {
                
                ['annotations', 'detalle'].each(function(field){
                    Transferencia[field].each(function(detalle){
                        if(detalle.select != undefined && typeof(detalle.select) == 'function') {
                            detalle.select(false);
                        }
                    });
                });
            }

            function onChangeIdTransferencia() {
                var id = campos_defs.get_value('id_transferencia');
                if (id) {
                    redirectToTransferABM(id);
                } else {

                    var xml_muestra = Undo.list.length > 0 ? Undo.list[0].obj : ""
                    if (xml_muestra != makeXML()) {
                        confirm("�Desea guardar los cambios actuales?", {
                            width: 400,
                            height: "auto",
                            className: "alphacube",
                            okLabel: "Si",
                            cancelLabel: "No",
                            onOk: function (w) {

                                guardar({ check_validate: false });

                                redirectToTransferABM();

                                w.close(); return
                            },
                            onCancel: function (w) {
                                redirectToTransferABM();
                                w.close(); return
                            }
                        });
                    }
                    else
                        redirectToTransferABM();

                }
            }


            function onRefreshIdTransferencia() {

                    var xml_muestra = Undo.list.length > 0 ? Undo.list[0].obj : ""
                    if (xml_muestra != makeXML()) {
                        confirm("Si recarga la transferencia perder� los datos no guardados</br>�Desea continuar?", {
                            width: 400,
                            height: "auto",
                            className: "alphacube",
                            okLabel: "Si",
                            cancelLabel: "No",
                            onOk: function (w) {

                                redirectToTransferABM(Transferencia.id_transferencia);
                                w.close(); return
                            },
                            onCancel: function (w) {
                                w.close(); return
                            }
                        });
                    }
                   else
                       redirectToTransferABM(Transferencia.id_transferencia);

            }

            function resetLayout() {
                Transferencia.detalle.each(function(element) {
                    element.onDispose = function() {
                    };
                    element.dispose();
                });
                Transferencia.pools.each(function(pool) {
                    pool.tDispose();
                });
                Transferencia.relations.each(function(relation) {
                    relation.dispose();
                });
                Transferencia.annotations.each(function(annotation) {
                    annotation.onDispose = function() {
                    };
                    annotation.dispose();
                });
                Transferencia = {
                    parametros: [],
                    pools: [],
                    detalle: [],
                    relations: [],
                    annotations: []
                };
            }
            function window_onresize() {

                try {
                    //if ((controlPad.element.viewportOffset().left + controlPad.element.getWidth()) > $$('body')[0].getWidth()) {
                    var left = $$('body')[0].getWidth() - controlPad.element.getWidth() - 30;
                    var top = controlPad.getLocation().top.replace('px', '');
                    controlPad.setLocation(top, left);
                    //}
                }
                catch (e) { }

                try {
                    var leftUndo = $$('body')[0].getWidth() - Undo.wUndo.element.getWidth() - 300;
                    var top = Undo.wUndo.getLocation().top.replace('px', '');
                    Undo.wUndo.setLocation(top, leftUndo);
                }
                catch (e) { }

            }

            var Undo;
            function crearUndo() {
                var options = {};
                options.id = "Undo"

                options.onUndo = function (list, indice) {
                    
                    if (!list)
                        return

                    cargarFromXML(list.obj);
                    oCB1.div.focus();

                };
                options.onRedo = function (list, indice) {

                    if (!list)
                        return

                    cargarFromXML(list.obj);
                    oCB1.div.focus();

                };
                Undo = new tUndo(options);
                Undo.tAdd = Undo.add;
                Undo.add = function (desc) {
                    
                    Undo.tAdd(makeXML(), desc);

                }
            }


            function elementRelDispose(element) {

                element.relations.each(function (rel, r) {

                    if (element.relations.length == 2 && !rel.src.allowBeginArrows)
                        rel.src.allowBeginArrows = true;

                    if (element.parametros_extra.op_true_RectId == rel.dest.id || element.parametros_extra.op_true_RectId == rel.dest.parametros_extra.RectId) {
                        rel.src.parametros_extra.op_true_RectId = null
                        rel.src.parametros_extra.op_true_id_transf_det = null
                    }

                    if (element.parametros_extra.op_false_RectId == rel.dest.id || element.parametros_extra.op_false_RectId == rel.dest.parametros_extra.RectId) {
                        element.parametros_extra.op_false_RectId = null
                        element.parametros_extra.op_false_id_transf_det = null
                    }

                    Undo.add("Eliminar relaci�n (" + rel.dest.transf_tipo + ') descripci�n: ' + rel.dest.title);

                    if (element == rel.src)
                        rel.dispose()

                });

            }

            function limpiarUndo()
            {
                
                Undo.inicializar()

                Undo.add('Cargar inicial');
                Undo.reset();

            }


            var vMenu;
            var controlPad;
            ImagenesTransf = {};
            function crearMenues() {
                /*****Menu general*********************************************/
                vMenu = new tMenu('topMenu', 'vMenu');
                vMenu.alineacion = 'derecha';
                vMenu.estilo = 'B';
                ImagenesTransf['abrir'] = new Image();
                ImagenesTransf['abrir'].src = '/FW/image/transferencia/abrir.gif';
                ImagenesTransf['deshacer'] = new Image();
                ImagenesTransf['deshacer'].src = '/FW/image/transferencia/undo.png';
                ImagenesTransf['rehacer'] = new Image();
                ImagenesTransf['rehacer'].src = '/FW/image/transferencia/redo.png';
                ImagenesTransf['undo_abrir'] = new Image();
                ImagenesTransf['undo_abrir'].src = '/FW/image/transferencia/undo_abrir.png';
                ImagenesTransf['imprimir'] = new Image();
                ImagenesTransf['imprimir'].src = '/FW/image/transferencia/imprimir.png';
                ImagenesTransf['buscar'] = new Image();
                ImagenesTransf['buscar'].src = '/FW/image/transferencia/buscar.png';
                ImagenesTransf['parametros'] = new Image();
                ImagenesTransf['parametros'].src = '/FW/image/transferencia/parametros.png';
                ImagenesTransf['procesar'] = new Image();
                ImagenesTransf['procesar'].src = '/FW/image/transferencia/procesar.png';
                ImagenesTransf['guardar'] = new Image();
                ImagenesTransf['guardar'].src = '/FW/image/transferencia/guardar.png';
                ImagenesTransf['nueva'] = new Image();
                ImagenesTransf['nueva'].src = '/FW/image/transferencia/nueva.png';
                ImagenesTransf['abrir'] = new Image();
                ImagenesTransf['abrir'].src = '/FW/image/transferencia/abrir.png';
                ImagenesTransf['pdf'] = new Image();
                ImagenesTransf['pdf'].src = '/FW/image/transferencia/pdf.png';
                ImagenesTransf['html'] = new Image();
                ImagenesTransf['html'].src = '/FW/image/transferencia/html.png';
                ImagenesTransf['inicio'] = new Image();
                ImagenesTransf['inicio'].src = '/FW/image/transferencia/points.png';
                ImagenesTransf['play'] = new Image();
                ImagenesTransf['play'].src = '/FW/image/transferencia/play.png';
                ImagenesTransf['actualizar'] = new Image();
                ImagenesTransf['actualizar'].src = '/FW/image/transferencia/refresh.png';

                ImagenesTransf['copy'] = new Image();
                ImagenesTransf['copy'].src = '/FW/image/transferencia/copiar.png';
                ImagenesTransf['paste'] = new Image();
                ImagenesTransf['paste'].src = '/FW/image/transferencia/pegar.png';
                ImagenesTransf['editar'] = new Image();
                ImagenesTransf['editar'].src = '/FW/image/transferencia/editar.png';
                ImagenesTransf['historial'] = new Image();
                ImagenesTransf['historial'].src = '/FW/image/transferencia/historial.png';
                ImagenesTransf['herramientas'] = new Image();
                ImagenesTransf['herramientas'].src = '/FW/image/transferencia/herramientas.png';
                ImagenesTransf['salir'] = new Image();
                ImagenesTransf['salir'].src = '/FW/image/transferencia/salir.png';

                vMenu.imagenes = ImagenesTransf;
                var menuXmlIzq = '<?xml version="1.0" encoding="ISO-8859-1"?>';
                menuXmlIzq += '<resultado>';
                menuXmlIzq += '     <MenuItems>';

                menuXmlIzq += '         <MenuItem id="99">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>inicio</icono>';
                menuXmlIzq += '             <Desc> </Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo></Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '    <MenuItems>';
                menuXmlIzq += '         <MenuItem id="100">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>nueva</icono>';
                menuXmlIzq += '             <Desc>Nueva</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>onChangeIdTransferencia()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="200">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>abrir</icono>';
                menuXmlIzq += '             <Desc>Abrir</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>abrir(return_abrir)</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="300">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>guardar</icono>';
                menuXmlIzq += '             <Desc>Guardar</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>guardar()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="400">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>guardar</icono>';
                menuXmlIzq += '             <Desc>Guardar como...</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>guardarComo()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="500">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>historial</icono>';
                menuXmlIzq += '             <Desc>Versi�n</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>abrir_versiones()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="501">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>herramientas</icono>';
                menuXmlIzq += '             <Desc>Referencias</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>referencia()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="502">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>actualizar</icono>';
                menuXmlIzq += '             <Desc>Recargar</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>onRefreshIdTransferencia();</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="503">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>play</icono>';
                menuXmlIzq += '             <Desc>Recientes</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '   <MenuItems>';
                
                var transf_recientes = eval(nvFW.pageContents.transf_recientes)
                for (var i in transf_recientes) {
                  var index_base = 503
                  menuXmlIzq += '         <MenuItem id="'+ (index_base + transf_recientes[i].pos) +'">';
                  menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                  menuXmlIzq += '             <icono>play</icono>';
                  menuXmlIzq += '             <Desc><![CDATA['+ transf_recientes[i].nombre +']]></Desc>';
                  menuXmlIzq += '             <Acciones>';
                  menuXmlIzq += '                 <Ejecutar Tipo="script">';
                  menuXmlIzq += '                     <Codigo>campos_defs.set_value("id_transferencia", "'+ transf_recientes[i].id +'"); onChangeIdTransferencia();</Codigo>';
                  menuXmlIzq += '                 </Ejecutar>';
                  menuXmlIzq += '             </Acciones>';
                  menuXmlIzq += '         </MenuItem>';
                }

                menuXmlIzq += '   </MenuItems>';
                menuXmlIzq += '   </MenuItem>';

                menuXmlIzq += '         <MenuItem id="506">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>salir</icono>';
                menuXmlIzq += '             <Desc>Salir</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>' + (win ? 'parent.$("' + win.getId() + '_close").onclick()' : "") + '</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '   </MenuItems>';
                menuXmlIzq += '         </MenuItem>';

                menuXmlIzq += '         <MenuItem id="798">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>nueva</icono>';
                menuXmlIzq += '             <Desc>Nueva</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>onChangeIdTransferencia()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="799">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>guardar</icono>';
                menuXmlIzq += '             <Desc>Guardar</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>guardar()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="801">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>editar</icono>';
                menuXmlIzq += '             <Desc>Edici�n</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo></Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '          <MenuItems>';
                menuXmlIzq += '          <MenuItem id="802">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>copy</icono>';
                menuXmlIzq += '             <Desc>Copiar (Ctrl-C)</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>transf_copy(event)</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '          </MenuItem>';
                menuXmlIzq += '          <MenuItem id="803">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>paste</icono>';
                menuXmlIzq += '             <Desc>Pegar (Ctrl-V)</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>ctrl_newPaste()</Codigo>'; 
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="804">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>deshacer</icono>';
                menuXmlIzq += '             <Desc>Deshacer (Ctrl-Z)</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>Undo.undo() (Ctrl-Z)</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="805">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>rehacer</icono>';
                menuXmlIzq += '             <Desc>Rehacer (Ctrl-Y)</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>Undo.redo()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         <MenuItem id="806">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>undo_abrir</icono>';
                menuXmlIzq += '             <Desc>Seguimiento de Cambios</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>wUndo()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '         </MenuItems>';
                menuXmlIzq += '         </MenuItem>';
             
                menuXmlIzq += '         <MenuItem id="905">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>imprimir</icono>';
                menuXmlIzq += '             <Desc>Imprimir</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo></Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '             <MenuItems>';
                menuXmlIzq += '             <MenuItem id="906">';
                menuXmlIzq += '                     <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '                     <icono>pdf</icono>';
                menuXmlIzq += '                     <Desc>PDF</Desc>';
                menuXmlIzq += '                     <Acciones>';
                menuXmlIzq += '                         <Ejecutar Tipo="script">';
                menuXmlIzq += '                             <Codigo>transferencia_imprimir("pdf")</Codigo>';
                menuXmlIzq += '                         </Ejecutar>';
                menuXmlIzq += '                     </Acciones>';
                menuXmlIzq += '                 </MenuItem>';
                menuXmlIzq += '                 <MenuItem id="907">';
                menuXmlIzq += '                     <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '                     <icono>html</icono>';
                menuXmlIzq += '                     <Desc>HTML</Desc>';
                menuXmlIzq += '                     <Acciones>';
                menuXmlIzq += '                         <Ejecutar Tipo="script">';
                menuXmlIzq += '                             <Codigo>transferencia_imprimir("html")</Codigo>';
                menuXmlIzq += '                         </Ejecutar>';
                menuXmlIzq += '                     </Acciones>';
                menuXmlIzq += '                 </MenuItem>';
                menuXmlIzq += '             </MenuItems>';
                menuXmlIzq += '         </MenuItem>';

                menuXmlIzq += '         <MenuItem id="910">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>parametros</icono>';
                menuXmlIzq += '             <Desc>Par�metros</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>abm_transferencia_parametros()</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';

                menuXmlIzq += '         <MenuItem id="1000">';
                menuXmlIzq += '             <Lib TipoLib="offLine">DocMNG</Lib>';
                menuXmlIzq += '             <icono>procesar</icono>';
                menuXmlIzq += '             <Desc>Ejecutar</Desc>';
                menuXmlIzq += '             <Acciones>';
                menuXmlIzq += '                 <Ejecutar Tipo="script">';
                menuXmlIzq += '                     <Codigo>transferencia_ejecutar(event)</Codigo>';
                menuXmlIzq += '                 </Ejecutar>';
                menuXmlIzq += '             </Acciones>';
                menuXmlIzq += '         </MenuItem>';
                menuXmlIzq += '     </MenuItems>';
                menuXmlIzq += '</resultado>';
                vMenu.CargarXML(menuXmlIzq);
                
                vMenu.MostrarMenu(); 
                $('vMenu').setStyle({"margin-left":"10px"})

                /*****Menu flotante*********************************************/
                var vButtonItems = [];
                controlPad = new Window({
                    height: 580,
                    width: 220,
                    closable: false,
                    resizable: true,
                    maximizable: false,
                    className: 'divTablero alphacube'
                    //minimizable: false
                });
                controlPad.minimize = minimizeFix;
                controlPad.setContent($('divTablero'));
                controlPad.show(false);
                controlPad.setLocation(48, $$('body')[0].getWidth() - 175);
                $('divTablero').setStyle({ height: controlPad.height + 'px' })

                ImagenesTransf['inf'] = new Image();
                ImagenesTransf['inf'].src = '/FW/image/transferencia/file_inf.png';
                ImagenesTransf['exp'] = new Image();
                ImagenesTransf['exp'].src = '/FW/image/transferencia/file_exp.png';
                ImagenesTransf['dts'] = new Image();
                ImagenesTransf['dts'].src = '/FW/image/transferencia/file_dts.png';
                ImagenesTransf['scr'] = new Image();
                ImagenesTransf['scr'].src = '/FW/image/transferencia/file_scr.png';
                ImagenesTransf['sp'] = new Image();
                ImagenesTransf['sp'].src = '/FW/image/transferencia/file_sp.png';
                ImagenesTransf['xls'] = new Image();
                ImagenesTransf['xls'].src = '/FW/image/transferencia/file_xls.png';
                ImagenesTransf['ssr'] = new Image();
                ImagenesTransf['ssr'].src = '/FW/image/transferencia/file_ssr.png';
                ImagenesTransf['eqv'] = new Image();
                ImagenesTransf['eqv'].src = '/FW/image/transferencia/file_eqv.png';
                ImagenesTransf['nos'] = new Image();
                ImagenesTransf['nos'].src = '/FW/image/transferencia/file_nos.png';
                ImagenesTransf['sss'] = new Image();
                ImagenesTransf['sss'].src = '/FW/image/transferencia/file_sss.png';
                ImagenesTransf['tra'] = new Image();
                ImagenesTransf['tra'].src = '/FW/image/transferencia/file_tra.png';
                ImagenesTransf['seg'] = new Image();
                ImagenesTransf['seg'].src = '/FW/image/transferencia/file_seg.png';
                ImagenesTransf['usr'] = new Image();
                ImagenesTransf['usr'].src = '/FW/image/transferencia/file_usr.png';
                ImagenesTransf['var'] = new Image();
                ImagenesTransf['var'].src = '/FW/image/transferencia/file_variable.png';
                ImagenesTransf['and'] = new Image();
                ImagenesTransf['and'].src = '/FW/image/transferencia/file_AND.png';
                ImagenesTransf['or'] = new Image();
                ImagenesTransf['or'].src = '/FW/image/transferencia/file_OR.png';
                ImagenesTransf['xor'] = new Image();
                ImagenesTransf['xor'].src = '/FW/image/transferencia/file_XOR.png';
                ImagenesTransf['if'] = new Image();
                ImagenesTransf['if'].src = '/FW/image/transferencia/file_IF.png';
                ImagenesTransf['ini'] = new Image();
                ImagenesTransf['ini'].src = '/FW/image/transferencia/file_INI.png';
                ImagenesTransf['ius'] = new Image();
                ImagenesTransf['ius'].src = '/FW/image/transferencia/file_IUS.png';
                ImagenesTransf['end'] = new Image();
                ImagenesTransf['end'].src = '/FW/image/transferencia/file_END.png';
                ImagenesTransf['ene'] = new Image();
                ImagenesTransf['ene'].src = '/FW/image/transferencia/file_ENE.png';
                ImagenesTransf['event'] = new Image();
                ImagenesTransf['event'].src = '/FW/image/transferencia/file_EVE.png';
                ImagenesTransf['timer'] = new Image();
                ImagenesTransf['timer'].src = '/FW/image/transferencia/file_TMR.png';
                ImagenesTransf['timer_inicio'] = new Image();
                ImagenesTransf['timer_inicio'].src = '/FW/image/transferencia/file_TII.png';
                ImagenesTransf['msg'] = new Image();
                ImagenesTransf['msg'].src = '/FW/image/transferencia/file_MSG.png';
                ImagenesTransf['pool'] = new Image();
                ImagenesTransf['pool'].src = '/FW/image/transferencia/file_POOL.png';
                ImagenesTransf['lane'] = new Image();
                ImagenesTransf['lane'].src = '/FW/image/transferencia/file_LANE.png';
                ImagenesTransf['annotation'] = new Image();
                ImagenesTransf['annotation'].src = '/FW/image/transferencia/annotation.png';
                ImagenesTransf['pdf'] = new Image();
                ImagenesTransf['pdf'].src = '/FW/image/transferencia/pdf.png';
                ImagenesTransf['html'] = new Image();
                ImagenesTransf['html'].src = '/FW/image/transferencia/html.png';

                vButtonItems.push({
                    nombre: "Pool",
                    etiqueta: "Pool (piscina)",
                    imagen: "pool",
                    onclick: "return ctrl_newPool()"
                });
                vButtonItems.push({
                    nombre: "Lane",
                    etiqueta: "Lane (andaribel)",
                    imagen: "lane",
                    onclick: "return ctrl_newLane()"
                });
                vButtonItems.push({
                    nombre: "INF",
                    etiqueta: "INF (Reportes)",
                    imagen: "inf",
                    onclick: "return ctrl_newElement('INF')"
                });
                vButtonItems.push({
                    nombre: "EXP",
                    etiqueta: "EXP (Exportaci�n)",
                    imagen: "exp",
                    onclick: "return ctrl_newElement('EXP')"
                });
                vButtonItems.push({
                    nombre: "DTS",
                    etiqueta: "DTS (Integration Services)",
                    imagen: "dts",
                    onclick: "return ctrl_newElement('DTS')"
                });
                vButtonItems.push({
                    nombre: "SP",
                    etiqueta: "SP (Procedimiento SQL)",
                    imagen: "sp",
                    onclick: "return ctrl_newElement('SP')"
                });
                vButtonItems.push({
                    nombre: "SCR",
                    etiqueta: "SCR (Script Browser)",
                    imagen: "scr",
                    onclick: "return ctrl_newElement('SCR')"
                });
                vButtonItems.push({
                    nombre: "XLS",
                    etiqueta: "XLS (Calculador Excel)",
                    imagen: "xls",
                    onclick: "return ctrl_newElement('XLS')"
                });
                vButtonItems.push({
                    nombre: "SSR",
                    etiqueta: "SSR (Script Servidor)",
                    imagen: "ssr",
                    onclick: "return ctrl_newElement('SSR')"
                });
                vButtonItems.push({
                    nombre: "EQV",
                    etiqueta: "EQV (API Veraz)",
                    imagen: "eqv",
                    onclick: "return ctrl_newElement('EQV')"
                });
                vButtonItems.push({
                    nombre: "NOS",
                    etiqueta: "NOSIS (API Nosis)",
                    imagen: "nos",
                    onclick: "return ctrl_newElement('NOS')"
                });
                vButtonItems.push({
                    nombre: "SSS",
                    etiqueta: "SWITCH",
                    imagen: "sss",
                    onclick: "return ctrl_newElement('SSS')" //ctrl_newElement('SSS')"
                });
                vButtonItems.push({
                    nombre: "TRA",
                    etiqueta: "TRANSFERENCIA (SubProceso)",
                    imagen: "tra",
                    onclick: "return ctrl_newElement('TRA')" //ctrl_newElement('SSS')"
                });
                vButtonItems.push({
                    nombre: "SEG",
                    etiqueta: "SEGMENTACI�N",
                    imagen: "seg",
                    onclick: "return ctrl_newElement('SEG')" //ctrl_newElement('SSS')"
                });
                vButtonItems.push({
                    nombre: "USR",
                    etiqueta: "USR (Acci�n de Usuario)",
                    imagen: "usr",
                    onclick: "return ctrl_newElement('USR')"
                });
                vButtonItems.push({
                    nombre: "btnSI",
                    etiqueta: "Si",
                    imagen: "",
                    onclick: "guardar(false);transferencia_nueva_accion(); win.close()"
                });
                vButtonItems.push({
                    nombre: "btnNO",
                    etiqueta: "No",
                    imagen: "",
                    onclick: "transferencia_nueva_accion(); win.close()"
                });
                vButtonItems.push({
                    nombre: "btnCancelar",
                    etiqueta: "Cancelar",
                    imagen: "",
                    onclick: "win.close()"
                });
                vButtonItems.push({
                    nombre: "GateAND",
                    etiqueta: "AND (Y)",
                    imagen: "and",
                    onclick: "return ctrl_newElement('AND')"
                });
                vButtonItems.push({
                    nombre: "GateOR",
                    etiqueta: "OR (O inclusivo)",
                    imagen: "or",
                    onclick: "return ctrl_newElement('OR')"
                });
                vButtonItems.push({
                    nombre: "GateXOR",
                    etiqueta: "XOR (O exclusivo)",
                    imagen: "xor",
                    onclick: "return ctrl_newElement('XOR')"
                });
                vButtonItems.push({
                    nombre: "GateIF",
                    etiqueta: "IF (Condicional)",
                    imagen: "if",
                    onclick: "return ctrl_newElement('IF')"
                });
                vButtonItems.push({
                    nombre: "EventINI",
                    etiqueta: "Inicio",
                    imagen: "ini",
                    onclick: "return ctrl_newElement('INI')"
                });
                vButtonItems.push({
                    nombre: "EventIUS",
                    etiqueta: "Inicio Usuario",
                    imagen: "ius",
                    onclick: "return ctrl_newElement('IUS')"
                });
                vButtonItems.push({
                    nombre: "MSG",
                    etiqueta: "Mensaje",
                    imagen: "msg",
                    onclick: "return ctrl_newElement('MSG')"
                });
                vButtonItems.push({
                    nombre: "EventEND",
                    etiqueta: "Fin",
                    imagen: "end",
                    onclick: "return ctrl_newElement('END')"
                });
                vButtonItems.push({
                    nombre: "EventENE",
                    etiqueta: "Fin Error",
                    imagen: "ene",
                    onclick: "return ctrl_newElement('ENE')"
                });
                vButtonItems.push({
                    nombre: "EventEVENT",
                    etiqueta: "Evento",
                    imagen: "event",
                    onclick: "return ctrl_newElement('EVE')"
                });
                vButtonItems.push({
                    nombre: "TMR",
                    etiqueta: "Timer",
                    imagen: "timer",
                    onclick: "return ctrl_newElement('TMR')"
                });
                vButtonItems.push({
                    nombre: "TII",
                    etiqueta: "Timer Inicio",
                    imagen: "timer_inicio",
                    onclick: "return ctrl_newElement('TII')"
                });
                vButtonItems.push({
                    nombre: "Annotation",
                    etiqueta: "Nota",
                    imagen: "annotation",
                    onclick: "return ctrl_newAnnotation()"
                });
                var vListButton = new tListButton(vButtonItems, 'vListButton');
                vListButton.imagenes = ImagenesTransf; //Imagenes se declara en pvUtiles
                vListButton.MostrarListButton();
            }

            /*******ventana Undo***********************************************/
            var controlUndo
            function wUndo()
            {
                Undo.onOpenWindow()

             //   if(controlUndo)
             //    if (!controlUndo.oldStyle)
             //        return

             //   controlUndo = new Window({
             //       height: 20,
             //       width: 500,
             //       closable: true,
             //       resizable: true,
             //       maximizable: false,
             //       className: 'alphacube',
             //       title: "<b>Deshacer</b>",
             //       minimizable: false
             //   });
             ////   controlUndo.minimize = minimizeFix;
             //   controlUndo.setContent($('divUndo'));
             //   controlUndo.show(false);
             //   controlUndo.setLocation(48, $$('body')[0].getWidth() - 800);
             //  $('divUndo').setStyle({ height: controlUndo.height + 'px' })

            }
            /********clases*****************************************************/
            function tnvPool(options) {
                if (!options) {
                    options = {};
                }
                options.transf_tipo = options.transf_tipo == undefined ? 'pool' : options.transf_tipo;
                options.zIndex = options.zIndex == undefined ? zIndexes.pool : options.zIndex;
                options.allowSelect = false;
                //Heredar de tnvRect
                this.inherit = new tnvRect(options);
                Object.extend(this, this.inherit);

                this.permisos = [];
                this.id_transferencia_pool = options.id_transferencia_pool == undefined ? 0 : options.id_transferencia_pool;
                this.bpmClass = options.bpmClass == undefined ? 'pool' : options.bpmClass;
                this.lanes = [];
                this.title = options.title !== undefined ? options.title : 'Nombre Pool';
                this.className = 'divCtrl ' + (options.className == undefined ? 'pool' : ' ' + options.className);
                this.containerArray = options.containerArray == undefined ? Transferencia.pools : options.containerArray;
                this.id_transferencia_pool = options.id_transferencia_pool == undefined ? false : options.id_transferencia_pool;
                this.minWidth = options.minWidth == undefined ? 150 : options.minWidth;
                //eventos
                this.onMoveStart = options.onMoveStart == undefined ? function() {
                } : options.onMoveStart;
                this.onMoveStop = options.onMoveStop == undefined ? function() {
                } : options.onMoveStop;
                this.onSizeStart = options.onSizeStart == undefined ? function() {
                } : options.onSizeStart;
                this.onSizeStop = options.onSizeStop == undefined ? function() {
                } : options.onSizeStop;
                this.calculateBrothersWidth = options.calculateBrothersWidth != undefined ? options.calculateBrothersWidth : function() {
                    var others_width = 0;
                    var pool = this;
                    Transferencia.pools.each(function(tPool) {
                        if (pool != tPool) {
                            others_width += tPool.width;
                        }
                    });
                    return others_width;
                }
                this.calculateChildrenWidth = options.calculateChildrenWidth != undefined ? options.calculateChildrenWidth : function() {
                    var children_width = 0;
                    this.lanes.each(function(tLane) {
                        children_width += tLane.div.getWidth();
                    });
                    if (children_width == 0) {
                        children_width = 150;
                    }
                    return children_width;
                }
                this.draw = function() {
                    var pool = this;
                    this.div = $($(document.createElement('div'))).addClassName(this.className);
                    this.div.setAttribute('id', this.id);
                    this.div.setStyle({
                        width: pool.width + 'px',
                        zIndex: this.zIndex
                    });
                    var title = $($(document.createElement('span'))).addClassName('title');
                    var titleText = $($(document.createElement('span'))).addClassName('text');
                    titleText.update(this.title);
                    title.update(titleText);
                    this.div.insert({top: title});
                    var resizer = $($(document.createElement('div'))).addClassName('resizer');
                    resizer.observe("mousedown", function(event) {
                        pool.width = pool.div.getWidth();
                        var iniAnt = event.clientX;
                        saveLaneElements();
                        var hasMoved = false;
                        Event.observe($($(document)), "mousemove", function(event) {
                            var delta = event.clientX - iniAnt;
                            if (pool.setWidth(delta, true)) {
                                iniAnt = event.clientX;
                                hasMoved = true;
                            }
                        });
                        Event.observe($($(document)), "mouseup", function (event) {
                            
                            $($(document)).stopObserving("mousemove");
                            $($(document)).stopObserving("mouseup");
                            restoreLaneElements();
                            if (hasMoved) {
                                Undo.add("Mover");
                            }
                            fixElementsPositions();
                            pool.onSizeStop();
                        });
                        pool.onSizeStart();
                    });
                    this.div.insert({bottom: resizer});

                    var move = $($(document.createElement('div'))).addClassName('icon move left');
                    move.observe("click", function(event) {
                        if(pool.moveLeft()){
                            Undo.add("Mover pool.moveLeft()");
                        }
                    });
                    title.insert({bottom: move});
                    var move = $($(document.createElement('div'))).addClassName('icon move right');
                    move.observe("click", function(event) {
                        if(pool.moveRight()){
                            Undo.add("Mover pool.moveRight()");
                        }
                    });
                    title.insert({bottom: move});

                    var erase = $($(document.createElement('div'))).addClassName('icon erase');
                    erase.observe("click", function(event) {
                        if (pool.dispose()) {
                            Undo.add("Borrar elemento");
                        } else {
                            setFault();
                        }
                    });
                    title.insert({bottom: erase});

                    var abm_pool = function () {

                       transf_clear_event_copy()

                        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                        var win = w.createWindow({
                            url: "/fw/transferencia/transferencia_pool_abm.aspx",
                            title: '<b>' + pool.title  +'</b>',
                            minimizable: true,
                            maximizable: true,
                            draggable: true,
                            resizable: true,
                            width: 850,
                            height: 300,
                            destroyOnClose: true,
                            zIndex: 20000
                        });
                        win.options.Pool = pool;
                        win.showCenter();
                    }
                    titleText.observe("dblclick", function(event) {
                        abm_pool();
                    });
                    var edit = $($(document.createElement('div'))).addClassName('icon edit');
                    edit.observe("click", function(event) {
                        abm_pool();
                    });
                    title.insert({bottom: edit});

                    this.inherit.div = pool.div;
                    var pools = this.parent.div.select('.' + pool.bpmClass);
                    var order = pool.getOrder();
                    if (pools[order] === undefined) {
                        this.parent.div.insert({bottom: pool.div});
                    } else {
                        pools[order].insert({before: pool.div});
                    }

                    Event.observe(this.div, "click", function(event) {
                        Transferencia.detalle.each(function(element) {
                            element.select(false);
                        });
                        Transferencia.annotations.each(function(element) {
                            element.select(false);
                        });
                    });
                    this.parent.fitToChildren();
                }
                this.reloadTitle = function() {
                    this.div.select('.title .text')[0].update(this.title);
                }
                this.setWidth = options.setWidth != undefined ? options.setWidth : function(width, delta) {
                    var res = this.lanes[this.lanes.length - 1].setWidth(width, delta);
                    return res;
                }
                this.addLane = function(options) {
                    if (options === undefined) {
                        options = {
                            title: 'Nombre Lane' + getTitleCounter(),
                            order: 0,
                            width: this.width,
                            parent: this,
                            className: 'lane',
                            containerArray: this.lanes
                        }
                    }
                    options.parent = this;
                    var lane = new tnvLane(options);
                    this.lanes.splice(options.order, 0, lane);
                    lane.draw();
                    this.fitToChildren();
                    this.parent.fitToChildren();
                    return lane;
                }
                this.moveLeft = function() {
                    var old_order = this.getOrder();
                    if (old_order > 0) {
                        this.onMoveStart();
                        var new_order = old_order - 1;
                        this.containerArray[new_order].div.insert({before: this.div});
                        this.containerArray.splice(old_order, 1);
                        this.containerArray.splice(new_order, 0, this);
                        this.onMoveStop();
                        return true;
                    }
                    return false;
                }
                this.moveRight = function() {
                    var old_order = this.getOrder();
                    if (old_order < this.containerArray.length - 1) {
                        this.onMoveStart();
                        var new_order = old_order + 1;
                        this.containerArray[new_order].div.insert({after: this.div});
                        this.containerArray.splice(old_order, 1);
                        this.containerArray.splice(new_order, 0, this);
                        this.onMoveStop();
                        return true;
                    }
                    return false;
                }
                this.fitToChildren = options.fitToChildren != undefined ? options.fitToChildren : function() {
                    var new_width = this.calculateChildrenWidth() - 1;
                    this.div.setStyle({
                        width: new_width + 'px'
                    });
                }
                this.getOrder = function() {
                    return this.containerArray.indexOf(this);
                }
                this.getWidth = function() {
                    return this.getInnerWidth();
                }
                this.getElements = function() {
                    var elements = [];
                    var pool = this;
                    Transferencia.detalle.each(function(element) {
                        if (pool.checkRectIn(element).fullIn) {
                            elements.push(element);
                        }
                    });
                    return elements;
                }
                this.tDispose = this.dispose;
                this.dispose = function() {
                    if (this.getElements().length == 0 && this.containerArray.length > 1) {
                        saveLaneElements();
                        this.containerArray.splice(this.containerArray.indexOf(this), 1);
                        this.tDispose();
                        this.parent.fitToChildren();
                        restoreLaneElements();
                        return true;
                    }
                    return false;
                }
                this.onDispose = function() {
                    
                }
                return this;
            }
        </script>
        <script type="text/javascript">
            function tnvLane(options) {
                if (!options) {
                    options = {};
                }
                options.transf_tipo = 'lane';
                options.zIndex = 0;
                options.bpmClass = 'lane';
                options.className = 'lane';
                options.containerArray = options.parent.lanes;
                options.onSizeStop = fixElementsPositions;
                options.onMoveStart = saveLaneElements;
                options.onMoveStop = restoreLaneElements;
                options.fitToChildren = function() {
                };
                options.minWidth = 150;
                options.setWidth = function(width, delta) {
                    if (Prototype.Browser.IE) {
                        width += 3;
                    }
                    var pool = this;
                    if (delta) {
                        width = pool.getInnerWidth() + width;
                    }
                    if (width < pool.minWidth) {
                        width = pool.minWidth;
                    }
                    if (width != pool.width) {
                        pool.width = width;
                        pool.div.setStyle({width: pool.width + 'px'});
                        this.parent.fitToChildren();
                        return true;
                    }
                    return false;
                }
                var lane = this;
                options.calculateBrothersWidth = function() {
                    var others_width = 0;
                    this.parent.lanes.each(function(tLane) {
                        if (lane != tLane) {
                            others_width += tLane.div.getWidth();
                        }
                    });
                    return others_width;
                }

                //Heredar de tnvPool
                this.inherit = new tnvPool(options);
                Object.extend(this, this.inherit);
                this.id_transferencia_lane = options.id_transferencia_lane == undefined ? 0 : options.id_transferencia_lane;
                delete this.id_transferencia_pool;
                return this;
            }
        </script>
        <script type="text/javascript">
            function tnvElement(options) {
                if (!options) {
                    options = {};
                }

                options.allowSelect = true
                //Heredar de tnvRect

                new tnvRect(options).extend(this);

                // asigno mismo RectID guardado
                try {
                    if (options.parametros_extra_xml) {
                        var xml = new tXML();
                        xml.loadXML(options.parametros_extra_xml)
                        var RectId = XMLText(xml.selectSingleNode("/parametros_extra/parametro [@nombre='RectId']/text()"))
                        if (RectId.lenght > 0)
                            this.id = RectId
                    }
                }
                catch (e) { }

                //Asignar valores a las propiedades heredadas
                if (this.parent != null) {
                    this.parent.items[this.id] = this;
                }
                this.containerArray = options.containerArray;
                this.tExtend = this.extend;
                this.extend = function(obj) {
                    this.tExtend(obj);
                    this.containerArray.push(obj);
                }

                //Propiedades
                this.transf_tipo = !options.transf_tipo ? null : options.transf_tipo;
                this.bpmClass = !options.bpmClass ? 'activity' : options.bpmClass;
                this.id_transf_det = options.id_transf_det === undefined ? 0 : options.id_transf_det;
                this.indice = !options.indice ? 0 : options.indice;
                this.title = options.title ? options.title : '';
                this.orden = !options.orden ? 0 : options.orden;
                this.id_transferencia = !options.id_transferencia ? null : options.id_transferencia;
                this.transferencia = !options.transferencia ? '' : options.transferencia;
                this.opcional = options.opcional == true ? true : false;
                this.transf_estado = !options.transf_estado ? 'A' : options.transf_estado;
                this.TSQL = !options.TSQL ? '' : options.TSQL;
                this.filtroXML = !options.filtroXML ? '' : options.filtroXML;
                this.filtroWhere = !options.filtroWhere ? '' : options.filtroWhere;
                this.xsl_name = !options.xsl_name ? '' : options.xsl_name;
                this.path_xsl = !options.path_xsl ? '' : options.path_xsl;
                this.xml_xsl = !options.xml_xsl ? '' : options.xml_xsl;
                this.xml_data = !options.xml_data ? '' : options.xml_data;
                this.report_name = !options.report_name ? '' : options.report_name;
                this.path_reporte = !options.path_reporte ? '' : options.path_reporte;
                this.salida_tipo = !options.salida_tipo ? '' : options.salida_tipo;
                this.contenttype = !options.contenttype ? '' : options.contenttype;
                this.target = !options.target ? '' : options.target;
                this.vistaguardada = !options.vistaguardada ? '' : options.vistaguardada;
                this.mantener_origen = !options.mantener_origen ? 'false' : options.mantener_origen;
                this.id_exp_origen = !options.id_exp_origen ? '0' : options.id_exp_origen;
                this.parametros = !options.parametros ? '' : options.parametros;
                this.dtsx_path = !options.dtsx_path ? '' : options.dtsx_path;
                this.dtsx_parametros = !options.dtsx_parametros ? '' : options.dtsx_parametros;
                this.dtsx_exec = !options.dtsx_exec ? '' : options.dtsx_exec;
                this.salida_tipo = !options.salida_tipo ? "'adjunto'" : options.salida_tipo;
                this.metodo = !options.metodo ? "''" : options.metodo;
                this.xls_path = !options.xls_path ? '' : options.xls_path;
                this.xls_path_save_as = !options.xls_path_save_as ? '' : options.xls_path_save_as;
                this.xls_visible = options.xls_visible == true;
                this.xls_cerrar = options.xls_cerrar == true;
                this.xls_guardar_resultado = options.xls_guardar_resultado == true;
                this.parametros_det = options.parametros_det == undefined ? [] : options.parametros_det;
                this.parametros_extra_xml = options.parametros_extra_xml == undefined ? '' : options.parametros_extra_xml;
                this.parametros_extra = options.parametros_extra == undefined ? {} : options.parametros_extra;
                this.lenguaje = !options.lenguaje ? 'js' : options.lenguaje;
                this.cod_cn = !options.cod_cn ? '' : options.cod_cn;
                this.zIndex = zIndexes.element;
                this.className = 'divCtrl ' + options.bpmClass + ' ' + options.transf_tipo;
                this.getOrder = function() {
                    return this.containerArray.indexOf(this);
                }

                this.hDraw = this.draw;
                this.draw = function tnvCtrl_draw() {
                    this.hDraw();
                    this.HTMLTitle();
                }

                this.HTMLTitle = function () {
                    
                    var element = this;

                    var HTML = "";
                    if (!this.contenn) {
                        this.contenn = $($(document).createElement('div')).addClassName('contenn');
                        this.contenn.style.height = "100%"
                        this.div.insert({bottom: this.contenn});
                    }
                    var hasActions = false;
                    switch (this.bpmClass) {
                        case 'activity':
                            //var className = nvCtrls.items[this.id].transf_estado.toUpperCase() == 'N' ? 'divCtrlNULO' : 'divCtrl' + this.type
                            if (this.transf_estado.toUpperCase() == 'N') {
                                this.div.addClassName('NULO');
                            } else {
                                this.div.removeClassName('NULO');
                            }

                            if(!this.parametros_extra.RectId)
                                this.parametros_extra.RectId = this.id

                            if (this.transf_tipo == 'SSR')
                              if (!this.parametros_extra.tipo_aisla)
                                    this.parametros_extra.tipo_aisla = 'interno'
                            
                            if (this.transf_tipo == 'TRA')
                              if (this.parametros_extra.async != true)
                                this.parametros_extra.async = false

                            if (this.transf_tipo != 'SSS')
                            {
                                if (this.parametros_extra.title_hide == undefined)
                                    this.parametros_extra.title_hide = false

                                HTML += "<div id='divTitulo" + this.id + "_" + this.indice + "' style='width:100%;height:100%;vertical-align:middle'>"
                                HTML += "<img class='icon' style='float:left !Important;margin-left:5px;margin-right:5px;margin-top:1px;' alt=''src='/FW/image/transferencia/file_" + this.transf_tipo.toLowerCase() + ".png' title='' />";
                                if (!this.parametros_extra.title_hide)
                                    HTML += "<span class='title layout_fixed'>" + this.title + "</span>";
                                HTML += "</div>"
                            }
                            else
                            {
                                
                                HTML += "<div id='divTitulo" + this.id + "_" + this.indice + "' style='width:100%;height:100%;vertical-align:middle'>"
                                HTML += "<img class='icon' style='float:left !Important;margin-left:5px;margin-right:5px;margin-top:1px;' alt=''src='/FW/image/transferencia/file_" + this.transf_tipo.toLowerCase() + ".png' title='' />";
                                if (!this.parametros_extra.title_hide) 
                                   HTML += "<span class='title'  nowrap='nowrap'>" + this.title + "</span>";
                                HTML += "<table style='width:100%;margin-top:10px' class='content'>";
                                HTML += "<tr>";
                                HTML += "<td class='actions' style='text-align:center'></td>";
                                HTML += (this.parametros_extra.switch ? (this.parametros_extra.switch.expresion != "" ? "Seg�n: " + this.parametros_extra.switch.expresion : "") : "")
                                HTML += "</td>";
                                HTML += "</tr>";
                                HTML += "</table>";
                                HTML += "</div>"
                            }

                            hasActions = true;
                            break;
                        case 'gateway':

                            Transferencia.detalle.each(function (rect, index) {
                                
                                if (element.parametros_extra.op_false_RectId)
                                    if (element.parametros_extra.op_false_RectId == rect.id)
                                        if (element.parametros_extra.op_false_id_transf_det)
                                            element.parametros_extra.op_false_id_transf_det = rect.id_transf_det
                                
                            });

                  //          if (!this.parametros_extra.op_false_id_transf_det)
                    //            this.parametros_extra.op_false_id_transf_det = this.id_transf_det

                        case 'event':
                              if(!this.parametros_extra.RectId)
                                this.parametros_extra.RectId = this.id
                        case 'timer':
                              if(!this.parametros_extra.RectId)
                                this.parametros_extra.RectId = this.id
                        case 'message':

                            HTML += "<img alt='" + this.transf_tipo + "' src='/FW/image/transferencia/" + this.transf_tipo + ".png' />";
                            HTML += "<span class='title'>" + this.title + "</span>";
                            break;
                    }
                    this.contenn.update(HTML);
                    if (hasActions) {

                        if (this.transf_tipo == 'SSS') {

                            var agregar = $(document.createElement('img'));
                            agregar.setAttribute('alt', 'Agregar');
                            agregar.setAttribute('title', 'Agregar ' + this.transf_tipo);
                            agregar.setAttribute('src', '/FW/image/tnvRect/agregar.png');
                            agregar.setAttribute('style', 'z-index:1000;cursor:pointer;cursor:hand');
                            agregar.observe('click', function (e) {

                                var el = Event.element(e)
                                var element = nvCtrls.getRectByElement(el)

                                if (!ObtenerObjnvCtrls(element.id_transf_det))
                                    return

                                //confirm("�Desea insertar una variable?", {
                                //    width: 300,
                                //    className: "alphacube",
                                //    okLabel: "Si",
                                //    cancelLabel: "No",
                                //    onOk: function (win) {                       
                                //        win.close(); return
                                //    },
                                //    onCancel: function (win) { win.close(); return }
                                //});

                                var options = element.getOptions();
                                options.id_transf_det = 0;
                                options.transf_tipo = 'SSC';
                                options.height = "15px";
                                options.title = "Tarea SSC"

                                var top = 0
                                element.relations.each(function (relation, index) {
                                    if (relation.direction == 'down' && element.id == relation.src.id && relation.dest.transf_tipo == 'SSC') {
                                        top = relation.dest.top
                                        left = relation.dest.left
                                    }
                                });

                                options.left += 80;
                                options.top = (top == 0 ? (options.top + 100) : (top + 40));
                                options.src = element

                                var dest = newElement(options);

                                if (!dest.parametros_extra.RectId)
                                    dest.parametros_extra.RectId = dest.id

                                oCase = element.parametros_extra.switch.case
                                var indice = oCase.length;
                                oCase[indice] = new Array();
                                oCase[indice]["RectId"] = dest.id//generateID()
                                oCase[indice]["valor"] = ""
                                oCase[indice]["condicion"] = ""
                                oCase[indice]["evaluacion"] = ""
                                oCase[indice]["descripcion"] = "Evaluaci�n"

                                options = {}
                                options.direction = 'down';
                                options.reception = 'left';
                                options.evaluacion = 'true';
                                options.lenguaje = 'js';
                                options.id_transf_rel = '0';
                                options.title = '';
                                options.title_position = 'middle';
                                options.default = 'true'

                                //var arrow = newArrow(ObtenerObjnvCtrls(element.id_transf_det), dest, options);
                                var arrow = newArrow(element, dest, options);
                                Undo.add("Insertar switch");


                            });

                            this.contenn.select('td.actions')[0].insert({ bottom: agregar });

                        }

                        this.onclonarclick = function (e) {
                            cloneElement(element).select(true, e);
                            Undo.add("Clonar tarea");
                        };

                        this.oneliminarclick = function (e) {
                            
                            element.relations.each(function (relation, i) {

                                if (relation.src.transf_tipo == 'IF') 
                                   elementRelDispose(relation.src)

                                if (relation.src.transf_tipo == 'SSS') {
                                    relation.src.parametros_extra.switch.case.each(function (ocase, j) {
                                        if (ocase.RectId == element.parametros_extra.RectId)
                                            ocase.RectId = "$ELI$" + ocase.RectId
                                    });
                                }

                            });

                            var undo_desc = "Eliminar tarea (" + element.transf_tipo + ') ' + element.title

                            element.select(false, e);
                            element.dispose();

                            Undo.add(undo_desc);
                        };

                       /* var clone = $(document.createElement('img'));
                        clone.setAttribute('alt', 'Clonar');
                        clone.setAttribute('title', 'Clonar ' + this.transf_tipo);
                        clone.setAttribute('src', '/FW/image/tnvRect/copiar.png');
                        clone.observe('click', function(e) {
                            cloneElement(element).select(true, e);
                            //Undo.add();
                        });
                        this.contenn.select('td.actions')[0].insert({bottom: clone});
                        
                        var erase = $(document.createElement('img'));
                        erase.setAttribute('alt', 'Borrar');
                        erase.setAttribute('title', 'Borrar ' + this.transf_tipo);
                        erase.setAttribute('src', '/FW/image/tnvRect/delete.png');
                        erase.observe('click', function(e) {
                            element.select(false, e);
                            element.dispose();
                            //Undo.add();
                        });
                        this.contenn.select('td.actions')[0].insert({bottom: erase});*/
                    }
                    this.fixTitleWidth();
                    return HTML;
                }
                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_transferencia_detalle(this);
//                    }
                }
                this.onarrowdblclick = function (obj, e) {
                                   
                    abm_transferencia_rel(obj, e);
                }

                this.getOrder = function() {
                    return this.containerArray.indexOf(this);
                }

                this.getLane = function() {
                    var ret = null;
                    var element = this;
                    Transferencia.pools.each(function(pool) {
                        pool.lanes.each(function(lane) {
                            if (lane.checkRectIn(element).fullXIn) {
                                ret = lane;
                                throw $break;
                            }
                        });
                        if (ret) {
                            throw $break;
                        }
                    });
                    return ret;
                }

                this.getOptions = function() {
                    var options = {};
                    options.parametros_det = this.parametros_det;
                    options.transf_tipo = this.transf_tipo;
                    options.orden = this.orden;
                    options.id_transf_det = this.id_transf_det;
                    options.transf_tipo = this.transf_tipo;
                    options.transferencia = this.transferenci;
                    options.opcional = this.opcional;
                    options.transf_estado = this.transf_estado;
                    options.archivo = this.archivo;
                    options.TSQL = this.TSQL;
                    options.dtsx_exec = this.dtsx_exec;
                    options.dtsx_path = this.dtsx_path;
                    options.dtsx_parametros = this.dtsx_parametros;
                    options.filtroXML = this.filtroXML;
                    options.filtroWhere = this.filtroWhere;
                    options.report_name = this.report_name;
                    options.path_reporte = this.path_reporte;
                    options.salida_tipo = this.salida_tipo;
                    options.contenttype = this.contenttype;
                    options.target = this.target;
                    options.xsl_name = this.xsl_name;
                    options.path_xsl = this.path_xsl;
                    options.xml_xsl = this.xml_xsl;
                    options.xml_data = this.xml_data;
                    options.vistaguardada = this.vistaguardada;
                    options.metodo = this.metodo;
                    options.mantener_origen = this.mantener_origen;
                    options.id_exp_origen = this.id_exp_origen;
                    options.parametros = this.parametros;
                    options.top = this.getTop();
                    options.left = this.getLeft();
                    options.width = this.getInnerWidth();
                    options.height = this.getInnerHeight();
                    options.xls_path = this.xls_path;
                    options.xls_path_save_as = this.xls_path_save_as;
                    options.xls_visible = this.xls_visible;
                    options.xls_cerrar = this.xls_cerrar;
                    options.xls_guardar_resultado = this.xls_guardar_resultado;
                    options.parent = this.parent;
                    options.containerArray = this.containerArray;
                    options.title = this.title;
                    options.className = this.className;
                    options.lenguaje = this.lenguaje;
                    options.cod_cn = this.cod_cn;
                    return options;
                }                
                this.amIDefault = function(){
                    return false;
                }
                this.amIDOutPutFalse = function () {
                    return false;
                }
                this.afterArrowAdd = function(arrow) {
                    afterArrowAdd(arrow);
                    onArrowDispose(arrow);
                };
                this.__getParametrosExtraLevel = function(xml) {
                    if(xml == null || xml.childNodes == null) {
                        return [];
                    }
                    return $A(xml.childNodes);
                };
                function loadXMLString(txt) {
                    var xmlDoc;
                    if (window.DOMParser) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(txt, "text/xml");
                    } else { // code for IE
                        xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
                        xmlDoc.async = false;
                        xmlDoc.loadXML(txt);
                    }
                    return xmlDoc;
                }
                this.processParametrosExtra = function(xml) {
                    var element = this;
                    var obj = [];
                    var close = false;
                    
                    if(xml === undefined) {
                        xml = loadXMLString(this.parametros_extra_xml);
                        if (xml.childNodes[0].nodeName == "parametros_extra_xml")
                            xml = selectSingleNode("/parametros_extra_xml/parametros_extra", xml)
                        else
                            xml = xml.childNodes[0];
                        close = true;
                    }
                    var parameters = this.__getParametrosExtraLevel(xml);
                    parameters.each(function(parametro){
                        var type = parametro.getAttribute('tipo');
                        var nombre = parametro.getAttribute('nombre');
                        if(type != 'object') {
                            var valor;
                            if(Prototype.Browser.IE) {
                                valor = parametro.text;
                            } else {
                                valor = parametro.innerHTML;
                            }
                            switch(type) {
                                case 'number':
                                    valor = parseFloat(valor);
                                    break;
                                case 'undefined':
                                    valor = undefined;
                                    break;
                                case 'null':
                                    valor = null;
                                    break;
                                case 'boolean':
                                    valor = parseInt(valor);
                                    break;
                                case 'string':
                                    valor = valor === undefined ? '' : valor; //parche para ie
                                    //valor = xmlUnscape(valor);
                                    break;
                            }
                            obj[nombre] = valor;
                        } else {
                            obj[nombre] = element.processParametrosExtra(parametro);
                        }
                    });
                    if(close && element.parametros_extra_xml != '') {
                        element.parametros_extra = obj;
                    }
                    return obj;
                };
                this.makeParametrosExtra = function(parametros_extra) {
                    var close = false;
                    var str = "";
                    if(parametros_extra == undefined) {
                        parametros_extra = this.parametros_extra;
                        str += "<parametros_extra>";
                        close = true;
                    }
                    for(var nombre in parametros_extra) {
                        var valor = parametros_extra[nombre];
                        var type = typeof(valor);
                        type = valor === null ? 'null' : type;
                        if(type != 'function') {
                            str += "<parametro tipo='" + type + "' nombre='" + nombre + "'>";
                            if(type != 'object') {
                                switch(type) {
                                    case 'boolean':
                                        valor = valor ? 1 : 0;
                                        break;
                                    case 'string':
                                        valor = valor ; //xmlScape(valor);
                                        break;
                                }
                                str += valor;
                            } else {
                                str += this.makeParametrosExtra(valor);
                            }
                            str += "</parametro>";
                        }
                    }
                    if(close) {
                        str += "</parametros_extra>";
                    }
                    return str;
                };
                this.processParametrosExtra();
                this.draw();
                return this;
            }
            //------------------------------
            function xmlScape(valor) {
                var scp = valor;
                if(typeof(scp) == 'string') {
                    scp = scp.replace(/&/g, '&amp;');
                    scp = scp.replace(/</g, '&lt;');
                    scp = scp.replace(/>/g, '&gt;');
                    scp = scp.replace(/"/g, '&quot;');
                    scp = scp.replace(/'/g, '&apos;');
                }
                return scp;
            }
            function xmlUnscape(valor) {
                var scp = valor;
                if(typeof(scp) == 'string') {
                    scp = scp.replace(/&lt;/g, '<');
                    scp = scp.replace(/&gt;/g, '>');
                    scp = scp.replace(/&quot;/g, '"');
                    scp = scp.replace(/&apos;/g, "'");
                    scp = scp.replace(/&amp;/g, '&');
                }
                return scp;
            }
            //------------------------------
            //------ acciones --------------
            function tnvSP(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    title_hide: false
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }
            function tnvEXP(options) {
                if (!options) {
                    options = {};
                }
                
                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    page_name: "",
                    filename: "",
                    title_hide: false,
                    source_xsl: 'none'
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }
            function tnvINF(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    page_name: "",
                    filename: "",
                    title_hide: false,
                    source_rpt: 'none'
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }
            function tnvDTS(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    title_hide: false,
                    source_dts: 'none'
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }
            function tnvSCR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    title_hide: false
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }
            function tnvXLS(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    title_hide: false
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvSSR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;


                options.parametros_extra = {
                    RectId: null,
                    lenguaje: 'vb',
                    title_hide: false,
                    tipo_aisla: 'interno'
                };
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }


            function tnvSSS(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;
                options.agregar = true;
                
                options.parametros_extra = {
                    RectId: null,
                    lenguaje: 'js',
                    title_hide: false,
                    switch: {
                        expresion: '',
                        campo_def: '',
                        id_param: '',
                        tipo_dato: '',
                        case:[]
                    }
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.amIDefault = function (arrow) {
                    return this.defaultArrow == arrow;
                }

                return this;
            }

            function tnvSSC(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;

                options.parametros_extra = {
                    RectId: null,
                    lenguaje: 'vb',
                    title_hide: false,
                    tipo_aisla: 'interno'
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvTRA(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;

                options.parametros_extra = {
                    RectId: null,
                    id_transferencia: '0',
                    async: false,
                    title_hide: false,
                    asignacion: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvSEG(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;

                options.parametros_extra = {
                    RectId: null,
                    id_transferencia: '0',
                    title_hide: false,
                    xml: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvEQV(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    title_hide: false
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvNOS(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'activity';
                options.sizable = true;
                options.eliminar = true;
                options.clonar = true;

                options.parametros_extra = {
                    RectId: null,
                    cuil: "",
                    cda: "",
                    vendedor: "",
                    razonsocial: "",
                    sexo: "",
                    actualizar_fuentes: "false",
                    tipo_informe: "sac_informe",
                    forzar_consulta: "false",
                    title_hide: false
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                return this;
            }

            function tnvUSR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = options.bpmClass == undefined ? 'activity' : options.bpmClass;
                options.sizable = options.sizable == undefined ? true : options.sizable;
                options.eliminar = options.eliminar == undefined ? true : options.eliminar;;
                options.clonar = options.clonar == undefined ? true : options.clonar;;

                options.parametros_extra = {
                    RectId: null,
                    verComentarios: false,
                    title_hide: false
                };
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                this.parametros_det = options.parametros_det == undefined || options.parametros_det.length == 0 ? {} : options.parametros_det;
                
                return this;
            }

            //------ eventos --------------
            function tnvINI(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'event';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.ondblclick = function() {
                    abm_event(this);
                }
                
                return this;
            }
            function tnvEND(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'event';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;
                options.allowBeginArrows = false;

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_event(this);
//                    }
                }
                return this;
            }

            function tnvENE(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'event';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;
                options.allowBeginArrows = false;

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.ondblclick = function() {
                    //                    if(tienePermisoDeEdicion(this)){
                    abm_event(this);
                    //                    }
                }
                return this;
            }

            function tnvEVE(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'event';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_event(this);
//                    }
                }
                
                return this;
            }
            function tnvIUS(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'event';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 29;
                options.width = 29;
                
                options.parametros_extra = {
                    RectId: null,
                    verComentarios : false
                };
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                this.parametros_det = options.parametros_det == undefined || options.parametros_det.length == 0 ? {} : options.parametros_det;
                return this;
            }
            //------ compuertas --------------

            function tnvIF(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'gateway';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 39;
                options.width = 39;

                options.parametros_extra = {
                    op_false_RectId: null,
                    op_true_RectId: null,
                    op_false_id_transf_det: null,
                    op_true_id_transf_det: null,
                    op_evaluacion: null,
                    tipo_aisla: 'noaislar'
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.amIDefault = function (arrow) {
                    //return this.defaultArrow == arrow;
                    return false
                }

                this.ondblclick = function () {
                    //                    if(tienePermisoDeEdicion(this)){
                    abm_gateway(this);
                    //                    }
                }

                return this;
            }

            function tnvAND(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'gateway';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 39;
                options.width = 39;

                options.parametros_extra = {
                    op_false_RectId: null,
                    op_false_id_transf_det: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                this.amIDefault = function(arrow){
                    //return this.defaultArrow == arrow;
                    return false
                }

                this.amIDOutPutFalse = function (arrow) {
                    return this.OutPutFalseArrow == arrow;
                }

                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_gateway(this);
//                    }
                }
                
                return this;
            }
            function tnvXOR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'gateway';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 39;
                options.width = 39;

                options.parametros_extra = {
                    op_false_RectId: null,
                    op_false_id_transf_det: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                this.amIDefault = function(arrow){
                    //return this.defaultArrow == arrow;
                    return false
                }

                this.amIDOutPutFalse = function (arrow) {
                    return this.OutPutFalseArrow == arrow;
                }

                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_gateway(this);
//                    }
                }
                
                return this;
            }
            function tnvOR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'gateway';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 39;
                options.width = 39;

                options.parametros_extra = {
                    op_false_RectId: null,
                    op_false_id_transf_det: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                this.amIDefault = function(arrow){
                    //return this.defaultArrow == arrow;
                    return false
                }

                this.amIDOutPutFalse = function (arrow) {
                    return this.OutPutFalseArrow == arrow;
                }

                this.ondblclick = function() {
//                    if(tienePermisoDeEdicion(this)){
                        abm_gateway(this);
//                    }
                }
                
                return this;
            }
            //------ timer --------------
            function tnvTMR(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'timer';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;
                options.parametros_extra = {
                    tipo : 'relativo',
                    
                    r_a_que: 'fecha',
                    r_parametro_base: '',
                    r_unidad: 'minutos',
                    r_valor_desp: '',
                    r_parametro_desp: '',
                    
                    a_valor_base: '',
                    a_parametro_base: ''
                }
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                return this;
            }
            //------ timer inicial ---------
            function tnvTII(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'timer';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;
                options.parametros_extra = {
                    tipo : 'relativo',
                    
                    r_a_que: 'fecha',
                    r_parametro_base: '',
                    r_unidad: 'minutos',
                    r_valor_desp: '',
                    r_parametro_desp: '',
                    
                    a_valor_base: '',
                    a_parametro_base: ''
                }
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                return this;
            }
            //------ mensaje ------------
            function tnvMSG(options) {
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'message';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.width = 29;
                options.height = 29;
                
                options.parametros_extra = {
                    para: {
                        pool: '',
                        lane: '1',
                        mail: '1',
                        xmpp: '',
                        userText: [],
                        mailText: [],
                        xmppText: []
                    },                    
                    cc: {
                        pool: '',
                        lane: '',
                        mail: '',
                        xmpp: '',
                        userText: [],
                        mailText: []
                    },
                    cco: {
                        pool: '',
                        lane: '',
                        mail: '',
                        xmpp: '',
                        userText: [],
                        mailText: []
                    },
                    desde: '',
                    asunto: '',
                    cuerpo: '',
                    archivosAdjuntos: ''
                };
                
                //Heredar de tnvElement
                new tnvElement(options).extend(this);
                
                return this;
            }
        </script>
        <script type="text/javascript">
            function tnvAnnotation(options) {
                if (!options) {
                    options = {};
                }

                options.type = 'annotation';
                options.transf_tipo = 'annotation';
                options.bpmClass = 'annotation';
                options.allowBeginArrows = false;
                options.allowSelect = true

                //Heredar de tnvElement
                new tnvRect(options).extend(this);

                // asigno mismo RectID guardado
                try {
                    if (options.parametros_extra_xml) {
                        var xml = new tXML();
                        xml.loadXML(options.parametros_extra_xml)
                        var RectId = XMLText(xml.selectSingleNode("/parametros_extra/parametro [@nombre='RectId']/text()"))
                        if (RectId.lenght > 0)
                            this.id = RectId
                    }
                }
                catch (e) { }


                this.id_transferencia_annotation = options.id_transferencia_annotation ? options.id_transferencia_annotation : 0;
                this.className = 'divCtrl ' + options.bpmClass;
                this.minWidth = 50;
                this.minHeight = 20;
                this.text = options.text ? options.text : 'nota' + getTitleCounter();
                this.transf_tipo = 'annotation';
                this.containerArray = options.containerArray === undefined ? [] : options.containerArray;
                this.relations = [];
                this.zIndex = zIndexes.annotation;
                this.eliminar = true;
                this.clonar = true;
                
                this.onDispose = function() {
                    var index = this.containerArray.indexOf(this);
                    if (index != -1) {
                        this.containerArray.splice(index, 1);
                        Undo.add("Eliminar anotaci�n");
                    }
                }

                this.hDraw = this.draw;
                this.draw = function() {
                    this.hDraw();
                    this.HTMLTitle();
                }
                this.HTMLTitle = function () {

                    var element = this
                    if (!this.contenn) {
                        this.contenn = $($(document).createElement('div')).addClassName('contenn');
                        this.div.insert({bottom: this.contenn});
                    }
                    var HTML = '<div class="border"></div>';
                    HTML += '<div class="text">' + this.text + '</div>';

                    this.contenn.update(HTML);

                    this.onclonarclick = function (e) {
                        
                        var options = {};
                        options.top = 10;
                        options.left = 10;
                        options.height = 50;
                        options.width = 120;
                        options.parent = oCB1;
                        options.containerArray = [];
                        options.allowSelect = true;
                        options.isNew = false;
                        options.text = element.text;
                        options.left += element.left + 20;
                        options.top += element.top + 20;
                        return newAnnotation(options);

                        Undo.add("Clonar anotaci�n");
                    };

                    this.oneliminarclick = function (e) {
                        element.select(false, e);
                        element.dispose();

                        Undo.add("Eliminar anotaci�n");
                    };
                }
                this.getOrder = function(){
                    return this.containerArray.indexOf(this);
                }
                this.ondblclick = function() {
                    abm_annotation(this);
                }
                
                this.draw();
                this.containerArray.push(this);
                

                this.amIDefault = function(arrow){
                    return false;
                }                

                this.amIDOutPutFalse = function (arrow) {
                    return false;
                }
             

                return this;
            }
        </script>
        <script type="text/javascript">
            /********controles*****************************************************/
            function createCanvas() {
                if (oCB1 !== undefined) {
                    oCB1.dispose();
                }
                var options = {};
                options.container = 'container';
                options.style = 'overflow: hidden;';
                options.multiSelect = 'parent';
                options.allowSelect = false;
                options.container = $('container');
                options.draggable = false;
                options.sizable = false;
                oCB1 = new tnvCanvas(options);
            }
            function newTransfer(options) {
                if (options === undefined) {
                    var options = {};
                    options.id_transferencia = -1;
                    options.nombre = '';
                    options.habi = true;
                    options.timeout = 90;
                    options.log_param_save = 1;
                    options.id_transf_estado = 1;
                    options.transf_version = '2.0';
                    options.transf_fe_creacion = '';
                    options.transf_fe_modificado = '';
                    options.nombre_operador = '';
                }

                Transferencia.pools = [];
                Transferencia.detalle = [];
                Transferencia.relations = [];
                Transferencia.id_transferencia = $('id_transferencia_txt').value = options.id_transferencia;
                Transferencia.nombre = $('nombre').value = options.nombre;
                Transferencia.habi = $('habi').checked = options.habi;
                Transferencia.timeout = $('timeout').value = options.timeout;
                Transferencia.transf_version = $('transf_version').value = options.transf_version;
                Transferencia.log_param_save = $('log_param_save').value = options.log_param_save;

                Transferencia.id_transf_estado = campos_defs.set_value('id_transf_estado', options.id_transf_estado);
                Transferencia.id_transf_estado = options.id_transf_estado;
                
                Transferencia.transf_fe_creacion  = options.transf_fe_creacion;
                Transferencia.transf_fe_modificado = options.transf_fe_modificado;
                Transferencia.nombre_operador = options.nombre_operador;

                if (Transferencia.id_transferencia > 0) {
                    $('descripcion').innerHTML = "<b>(" + id_transferencia_txt.value + ") " + nombre.value + "</b>" 
                    if (!nvFW.tienePermiso(nvFW.pageContents.permiso_grupo, nvFW.pageContents.nro_permiso_editar)) {
                        $('descripcion').innerHTML += "<b style='color:red'> [Solo lectura]</b>" 
                         alert("No posee los permisos espec�ficos para editar<br/><b>" + Transferencia.nombre + "</b>.")
                    }
                }
                else
                  $('descripcion').innerHTML = "<b>Nueva Transferencia</b>" 
            }
            function newTransferencia() {
                resetLayout();
                newTransfer();
                newPool({}, true);
                Undo.add("Carga Inicial");
            }
            function newPool(options, addLane) {
                if (addLane === undefined) {
                    addLane = true;
                }

                options.title = options.title == undefined ? 'Nombre Pool' + getTitleCounter() : options.title;
                options.width = options.width == undefined ? 300 : options.width;
                options.container = oCB1.id;
                options.parent = oCB1;
                options.containerArray = Transferencia.pools;
                options.onSizeStop = fixElementsPositions;
                options.onMoveStart = saveLaneElements;
                options.onMoveStop = function() {
                    restoreLaneElements();
                }
                var pool = new tnvPool(options);
                Transferencia.pools.splice(options.order, 0, pool);
                pool.draw();
                if (addLane) {
                    pool.addLane();
                }
                return  pool;
            }
            function ctrl_newPool() {
                stopAll();
                setMarker('pool');
                Transferencia.pools.each(function(pool) {
                    var div = $($(document.createElement('div'))).addClassName('part left');
                    div.insert({bottom: $($(document.createElement('div'))).addClassName('arrow')});
                    pool.div.insert({bottom: div});
                    div = $($(document.createElement('div'))).addClassName('part right');
                    div.insert({bottom: $($(document.createElement('div'))).addClassName('arrow')});
                    pool.div.insert({bottom: div});
                });
                Event.observe(oCB1.div, "click", function (event) {
                    
                    saveLaneElements();
                    var x = event.clientX - offset;
                    var pool_selected = false;
                    var res_selected;
                    var order;
                    Transferencia.pools.each(function(pool) {
                        var res = pool.checkPointIn({x: x, y: 30});
                        if (res.e <= 0 && res.o <= 0) {
                            pool_selected = pool;
                            res_selected = res;
                        }
                    });
                    if (pool_selected) {
                        if (res_selected.e > res_selected.o) {
                            order = pool_selected.getOrder();
                        } else {
                            order = pool_selected.getOrder() + 1;
                        }
                    } else { //es que toco afuera
                        order = Transferencia.pools.length;
                    }
                    if (order < 0) {
                        order = 0;
                    }

                    var options = {};
                    options.order = order;
                    var pool = newPool(options);
                    restoreLaneElements();
                    stopAll();
                    Undo.add("Nuevo pool");
                    return pool;
                });
            }
            function getTitleCounter() {
                return ' (' + (counter++) + ')';
            }
            var marker;
            var offset;
            function setMarker(className) {
                marker = $($(document.createElement('div'))).addClassName('marker ' + className + 'Marker');
                marker.setStyle({left: '-1000px'});
                oCB1.div.insert({top: marker});
                var half_width = marker.getWidth() / 2;
                marker.setOpacity(0.25);
                Event.observe(oCB1.div, "mousemove", function(event) {
                    offset = oCB1.div.viewportOffset()[0];
                    var width = event.clientX - offset - 1;
                    marker.setStyle({left: width - half_width + 'px'});
                });
            }
            function unsetMarker() {
                if (marker) {
                    marker.remove();
                    marker = null;
                }
            }
            function stopNewPool() {
                
                unsetMarker();
                oCB1.div.stopObserving("mousemove");
                oCB1.div.stopObserving("click");
                Transferencia.pools.each(function(pool) {
                    pool.div.select('.part').each(function(part) {
                        part.remove();
                    });
                });
            }
            function newLane(options, parentPool) {
                options.container = parentPool.id;
                options.parent = parentPool;
                options.onMoveStart = saveLaneElements;
                options.onMoveStop = restoreLaneElements;
                options.onSizeStop = fixElementsPositions;
                var lane = parentPool.addLane(options);
                return lane;
            }
            function ctrl_newLane() {
                stopAll();
                setMarker('lane');
                Transferencia.pools.each(function(pool) {
                    pool.lanes.each(function(lane) {
                        var div = $($(document.createElement('div'))).addClassName('part left');
                        div.insert({bottom: $($(document.createElement('div'))).addClassName('arrow')});
                        lane.div.insert({bottom: div});
                        div = $($(document.createElement('div'))).addClassName('part right');
                        div.insert({bottom: $($(document.createElement('div'))).addClassName('arrow')});
                        lane.div.insert({bottom: div});
                    });
                });
                Transferencia.pools.each(function(pool) {
                    Event.observe(pool.div, "click", function (event) {
                        
                        saveLaneElements();
                        var x = event.clientX - offset;
                        var res_selected;
                        var order;
                        var lane_selected = false;
                        pool.lanes.each(function(lane) {
                            var res = lane.checkPointIn({x: x, y: 30});
                            if (res.e <= 0 && res.o <= 0) {
                                lane_selected = lane;
                                res_selected = res;
                            }
                        });
                        if (res_selected) {
                            if (res_selected.e > res_selected.o) {
                                order = lane_selected.getOrder();
                            } else {
                                order = lane_selected.getOrder() + 1;
                            }
                        } else {
                            order = pool.lanes.length;
                        }
                        if (order < 0) {
                            order = 0;
                        }

                        var options = {};
                        options.order = order;
                        options.title = 'Nueva Lane' + getTitleCounter();
                        options.width = 150;
                        var lane = newLane(options, pool);
                        restoreLaneElements();
                        stopAll();
                        Undo.add("Nueva lane");
                        return lane;
                    });
                });
            }
            function stopNewLane() {
                
                unsetMarker();
                oCB1.div.stopObserving("mousemove");
                Transferencia.pools.each(function(pool) {
                    pool.lanes.each(function(lane) {
                        lane.div.select('.part').each(function(part) {
                            part.remove();
                        });
                    });
                    pool.div.stopObserving("click");
                });
            }
            function newElement(options) {
                options.parent = oCB1;
                options.containerArray = Transferencia.detalle;
                options.onDragStop = function() {
                 //   console.log("onDragStop - fixElementsPositions")
                    fixElementsPositions();
                    Undo.add("Mover tarea (" + options.transf_tipo + ') descripci�n: ' + options.title);
                }
                options.onSizeStop = function () {
                    fixElementsPositions();
                    Undo.add("Dimensionar tarea (" + options.transf_tipo + ') descripci�n: ' + options.title);
                }
                options.parametros_det = options.parametros_det == undefined ? [] : options.parametros_det;
                options.selectorWrapperClass = options.bpmClass;
                options.id_transf_det = options.id_transf_det == undefined ? 0 : options.id_transf_det;
                options.onDispose = function(){
                    var index = Transferencia.detalle.indexOf(newElement);
                    if (index != -1) {
                        Transferencia.detalle.splice(index, 1);
                    }
                }
                options.onArrowStop = function (arrow, e) {

                    if (e) {
                        var desc  = "Insertar relaci�n desde (" + arrow.src.transf_tipo + ")" 
                            desc += arrow.src.title ? " descripci�n: " + arrow.src.title  : ""
                            desc += " hacia (" + arrow.dest.transf_tipo + ")"
                            desc += arrow.dest.title ? " descripci�n: " + arrow.dest.title : ""
                        Undo.add(desc)
                    }

                    if (arrow.dest.type == 'annotation') {
                        //si es tipo anotaci�n guardo en la anotaci�n la relaci�n
                        arrow.segmentClassName = 'annotation';
                        arrow.points_draw = false;
                        arrow.segments.each(function(segment){
                            segment.addClassName(arrow.segmentClassName);
                        });
                    } else {
                        //sino guardo la relaci�n en Transferencia.relations
                        Transferencia.relations.push(arrow);
                    }
                    arrow.draw();
                  
                }
                var newElement = new window['tnv' + options.transf_tipo](options);
                
                return newElement;
            }


            function onDisposeElement(element) {
                var index = Transferencia.detalle.indexOf(element);
                if (index != -1) {
                    Transferencia.detalle.splice(index, 1);
                }
            }
            function cloneElement(element) {
                var options = element.getOptions();
                options.id_transf_det = 0;
                options.left += 10;
                options.top += 10;
                return newElement(options);
            }
            function setFault() {
                oCB1.div.setStyle({background: '#FFDDDD'});
                setTimeout(function() {
                    oCB1.div.setStyle({background: 'none'});
                }, 100);
            }
            var element;
            function makeElementOptions(type) {
                options = {};
                options.parametros_det = [];
                options.transf_tipo = type;
                options.orden = 0;
                options.id_transf_det = 0;
                options.transf_tipo = type;
                options.transferencia = '';
                options.opcional = false;
                options.transf_estado = 'A';
                options.archivo = '';
                options.TSQL = '';
                options.dtsx_exec = '';
                options.dtsx_path = '';
                options.dtsx_parametros = '';
                options.filtroXML = "'<criterio><select vista=\"\"><campos>*</campos><filtro></filtro></select></criterio>'";
                options.filtroWhere = '';
                options.report_name = '';
                options.path_reporte = '';
                options.salida_tipo = "'estado'";
                options.contenttype = "''";
                options.target = '';
                options.xsl_name = '';
                options.path_xsl = '';
                options.xml_xsl = '';
                options.xml_data = '';
                options.vistaguardada = '';
                options.metodo = "''";
                options.mantener_origen = 'false';
                options.id_exp_origen = '0';
                options.parametros = '';
                options.lenguaje = '';
                options.cod_cn = '';
                options.top = 0;
                options.left = 0;
                options.xls_path = '';
                options.xls_path_save_as = '';
                options.xls_visible = 'True';
                options.xls_cerrar = 'True';
                options.xls_guardar_resultado = 'True';
                options.parent = oCB1;
                options.width = 110;
                options.height = 25;
                options.containerArray = [];

                switch (type) {
                    case 'INI':
                        options.title = 'Inicio';
                        break;
                    case 'END':
                        options.title = 'Fin';
                        break;
                    case 'ENE':
                        options.title = 'Fin Error';
                        break;
                    default:
                        options.title = '';
                        break;
                }
                return options;
            }
            function ctrl_newElement(type) {
                
                stopAll();
                var options = makeElementOptions(type);
                options.top = 10;
                options.left = 10;
                options.allowSelect = false;
                options.select = true;
                options.isNew = true;

                //options.style = 'width: ' + options.width + 'px ;height: ' + options.height + 'px; top: 10px; left: 10px; z-index: 300000;';
                element = new window['tnv' + type](options);
                $(oCB1.div).setStyle({cursor: 'none'});
                Event.observe(oCB1.div, 'mousemove', function (event) {
                    var offset = oCB1.div.viewportOffset();
                    options.left = event.clientX - offset.left - options.width / 2;
                    options.top = event.clientY - offset.top - options.height / 2;
                    element.move(options.left, options.top)
                });
                Event.observe(oCB1.div, 'click', function (event) {
                    options.style = '';
                    options.isNew = false
                    newElement(options);
                    stopAll();
                    fixElementsPositions();
                    Undo.add('Alta tarea (' + type + ') ' + options.title);
                });
            }
            function stopNewElement() {
                $(oCB1.div).stopObserving('mousemove');
                $(oCB1.div).stopObserving('click');
                $(oCB1.div).setStyle({cursor: 'default'});
                element.dispose();
                element = false;
            }
            function newAnnotation(options) {
                options.containerArray = Transferencia.annotations;
                options.parent = oCB1;
                options.onDragStop = function() {
                    Undo.add("Mover anotaci�n ");
                }
                options.onSizeStop = function() {
                    Undo.add("Dimensionar anotaci�n ");
                }
                var annotation = new tnvAnnotation(options);
                return annotation;
            }

            function ctrl_newAnnotation() {
                stopAll();

                var options = {};
                options.top = 10;
                options.left = 10;
                options.height = 50;
                options.width = 120;
                options.parent = oCB1;
                options.containerArray = [];
                options.text = ' ';
                options.allowSelect = true;
                options.isNew = true;

//                options.style = 'width: ' + options.width + 'px ;height: ' + options.height + 'px; top: -500px; left: -500px;';
                element = new tnvAnnotation(options);
                $(oCB1.div).setStyle({cursor: 'none'});
                Event.observe(oCB1.div, 'mousemove', function(event) {
                    var offset = oCB1.div.viewportOffset();
                    options.left = event.clientX - offset.left - options.width / 2;
                    options.top = event.clientY - offset.top - options.height / 2;
                    element.move(options.left, options.top)
                });
                Event.observe(oCB1.div, 'click', function (event) {
                    
                    delete options.text;
                    options.isNew = false
                    newAnnotation(options);
                    stopAll();
                    Undo.add('Alta anotaci�n');
                    fixElementsPositions();
                });
            }


            function tnvPASTE(options) {
                
                if (!options) {
                    options = {};
                }

                options.bpmClass = 'gateway';
                options.sizable = false;
                options.eliminar = false;
                options.clonar = false;

                options.height = 39;
                options.width = 39;

                options.parametros_extra = {
                    op_false_RectId: null,
                    op_true_RectId: null,
                    op_false_id_transf_det: null,
                    op_true_id_transf_det: null,
                    op_evaluacion: null
                };

                //Heredar de tnvElement
                new tnvElement(options).extend(this);

                this.amIDefault = function (arrow) {
                    //return this.defaultArrow == arrow;
                    return false
                }

                this.ondblclick = function () {
                    //                    if(tienePermisoDeEdicion(this)){
                    abm_gateway(this);
                    //                    }
                }

                return this;
            }

            function ctrl_newPaste() {
                 
                stopAll();
                selectNone();

                var objXML = new tXML()
                if(!objXML.loadXML(xmlCopy)){
                       alert("No es una estructura valida")
                       return
                }

                
                if (objXML.selectNodes("transferencia/detalles/detalle [@selected = 'true']").lenght == 0) {
                      alert("No es una estructura valida")
                      return
                }

                var detalles = [];
                var NodeDetalles = objXML.selectNodes("transferencia/detalles/detalle")
                for (var i = 0; i < NodeDetalles.length; i++) {
                        
                        var optionsElement = makeOptionsFromXML(NodeDetalles[i]);

                        if (optionsElement.selected == "false")
                            continue                        

                        cargar_parametros_det_from_xml(optionsElement, NodeDetalles[i]);


                        optionsElement.title = optionsElement.transferencia != "" ? optionsElement.transferencia : optionsElement.title
                        optionsElement.left =  parseInt(optionsElement.left)  + 10 // + (10 * i);
                        optionsElement.top =   parseInt(optionsElement.top)  + 10  // + (10*i);

                        var element = newElement(optionsElement);

                        element.info_copy = {}
                        element.info_copy.orden = element.orden
                        element.info_copy.id_transf_det = element.id_transf_det
                        
                        element.orden = element.getOrder()
                        element.id_transf_det = 0;

                        element.select(true);

                        detalles.push({
                            element: element,
                            _relations: selectNodes("relations/relation", NodeDetalles[i])
                        });
                        
                }

                detalles.each(function (detalle) {
                           var NodeRelations = detalle._relations
                        for (var r = 0; r < NodeRelations.length; r++) {
                               var optionsR = makeOptionsFromXML(NodeRelations[r]);
                               optionsR.evaluacion = XMLText(NodeRelations[r].querySelector('evaluacion')).replace('<!--[CDATA[', '').replace('&lt;![CDATA[', '').replace(']]-->', '').replace(']]&gt;', '');
                               optionsR.title = XMLText(NodeRelations[r].querySelector('title')).replace('<!--[CDATA[', '').replace('&lt;![CDATA[', '').replace(']]-->', '').replace(']]&gt;', '');
                               var src = detalle.element;
                               var indice = getDest_temp_id_anterior(detalles,optionsR.dest_temp_id)
                               if (indice > -1) {
                                  var dest = Transferencia.detalle[indice];
                                  newArrow(src, dest, optionsR);
                               }
                           }

                    });

                fixElementsPositions();
                Undo.add('Pegar Selecci�n');
            }

            function getDest_temp_id_anterior(arr,valor) {
                var resultado = -1

                arr.each(function (detalle) {
                     if (detalle.element.info_copy) {
                        if (detalle.element.info_copy.id_transf_det == valor && resultado == -1)
                            resultado = detalle.element.orden
                        if (detalle.element.info_copy.orden == valor && resultado == -1)
                            resultado = detalle.element.orden
                     }
                    });

                return resultado
            }


            function stopAll() {
                if (element) {
                    stopNewElement();
                } else if (marker) {
                    stopNewPool();
                    stopNewLane();
                }
            }
            function fixElementsPositions() {
               // console.log("fixElementsPositions")
                var frees = {};
                var partials = {};
                Transferencia.pools.each(function(pool) {
                    pool.lanes.each(function(lane) {
                        Transferencia.detalle.each(function(element) {
                            var res = lane.checkRectIn(element);
                            var obj = {
                                lane: lane,
                                element: element,
                                res: res
                            };
                            if (frees[element.id] == undefined) {
                                frees[element.id] = {
                                    bestE: false,
                                    bestO: false
                                };
                            }
                            if (frees[element.id] != 'deleted') {
                                if (!frees[element.id].bestE && !frees[element.id].bestO) {
                                    frees[element.id].bestE = obj;
                                    frees[element.id].bestO = obj;
                                } else {
                                    if (obj.res.e > 0 && (obj.res.e < frees[element.id].bestE.res.e || frees[element.id].bestE.res.e < 0)) {
                                        frees[element.id].bestE = obj;
                                    }
                                    if (obj.res.o > 0 && (obj.res.o < frees[element.id].bestO.res.o || frees[element.id].bestO.res.o < 0)) {
                                        frees[element.id].bestO = obj;
                                    }
                                }
                            }
                            if (res.partialXIn) {
                                if (!partials[element.id]) {
                                    partials[element.id] = [];
                                }
                                partials[element.id].push(obj);
                                frees[element.id] = 'deleted';
                            } else if (res.fullXIn) {
                                frees[element.id] = 'deleted';
                            }
                        });
                    });
                });
                for (var ind in frees) {
                    if (frees[ind] == 'deleted') {
                        delete frees[ind];
                    }
                }
                for (var ind in partials) {
                    var partial = partials[ind];
                    var movement = {};
                    if (partial.length == 1) {
                        var obj = partial.pop();
                        if (obj.res.o > obj.res.e) {//mover para el oeste
                            movement.offsetLeft = -1 * obj.res.o;
                        } else {
                            movement.offsetLeft = obj.res.e;
                        }
                    } else {
                        var obj = partial.pop();
                        var movement1 = {};
                        if (obj.res.o > obj.res.e) {//mover para el oeste
                            movement1.offsetLeft = -1 * obj.res.o;
                        } else {
                            movement1.offsetLeft = obj.res.e;
                        }
                        obj = partial.pop();
                        var movement2 = {};
                        if (obj.res.o > obj.res.e) {//mover para el oeste
                            movement2.offsetLeft = -1 * obj.res.o;
                        } else {
                            movement2.offsetLeft = obj.res.e;
                        }
                        if (Math.abs(movement1.offsetX) < Math.abs(movement2.offsetX)) {
                            movement = movement1;
                        } else {
                            movement = movement2;
                        }
                    }
                    if (movement.offsetLeft > 0) {
                        movement.offsetLeft += 4;
                    }
                    if (movement.offsetLeft < 0) {
                        movement.offsetLeft -= 1;
                    }
                    obj.element.move(movement);
                }
                for (var ind in frees) {
                    var free = frees[ind];
                    var o = free.bestO.res.o > 0 ? free.bestO.res.o : false;
                    var e = free.bestE.res.e > 0 ? free.bestE.res.e : false;
                    var movement = {};
                    if (o !== false && e !== false) {
                        if (o < e) {
                            movement.offsetLeft = -1 * o;
                        } else {
                            movement.offsetLeft = e;
                        }
                    } else if (o !== false) {
                        movement.offsetLeft = -1 * o;
                    } else if (e !== false) {
                        movement.offsetLeft = e;
                    }
                    if (movement.offsetLeft > 0) {
                        movement.offsetLeft += 3;
                    }
                    if (movement.offsetLeft < 0) {
                        movement.offsetLeft -= 1;
                    }
                    free.bestO.element.move(movement);
                }
            }
        </script>
        <script type="text/javascript">
            function cargarTransferencia(id_transferencia,id_transf_version) {

                if (id_transf_version > 0) {
                    
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_transferencias_version, '', '<id_transf_version type="igual">' + id_transf_version + '</id_transf_version>');
                    if (!rs.eof()) 
                      cargarFromXML(rs.getdata('valor'));

                    window_onresize();
                     
                }
                else {
                      resetLayout();
                      loadTransfer(id_transferencia);
                      loadParameters(id_transferencia);
                      loadPools(id_transferencia);
                      loadElements(id_transferencia);
                      loadArrows();
                      loadAnnotations(id_transferencia);
                      autoFixTransfer();
                      limpiarUndo()
                }

            }

            function loadTransfer(id_transferencia) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_transferencia_cab,"","<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>","")
                if (!rs.eof()) {
                    var options = {};
                    options.id_transferencia = rs.getdata('id_transferencia');
                    options.nombre = rs.getdata('nombre');
                    options.habi = rs.getdata('habi') == 'S' ? true : false;
                    options.timeout = rs.getdata('timeout');
                    options.id_transf_estado = isNULL(rs.getdata('id_transf_estado'),'');
                    options.transf_fe_creacion = rs.getdata('transf_fe_creacion_f') + ' ' + rs.getdata('transf_fe_creacion_h');
                    options.transf_fe_modificado = rs.getdata('transf_fe_modificado_f') + ' ' + rs.getdata('transf_fe_modificado_h');
                    options.nombre_operador = isNULL(rs.getdata('nombre_operador'), '');
                    options.transf_version = isNULL(rs.getdata('transf_version'), ''); 
                    options.log_param_save = isNULL(rs.getdata('log_param_save'), ''); 
                    newTransfer(options);
                }
            }
            function loadParameters(id_transferencia) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_transferencia_parametros, "", "<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>", "")
                var parametro
                while (!rs.eof()) {
                    parametro = {};
                    parametro.parametro = rs.getdata('parametro');
                    parametro.tipo_dato = rs.getdata('tipo_dato');
                    parametro.valor_defecto = rs.getdata('valor_defecto');
                    parametro.requerido = rs.getdata('requerido') == "True";
                    parametro.editable = rs.getdata('editable') == "True";
                    parametro.etiqueta = rs.getdata('etiqueta');
                    parametro.orden = rs.getdata('orden');
                    parametro.valor_defecto_editable = rs.getdata('valor_defecto_editable');
                    parametro.campo_def = isNULL(rs.getdata('campo_def'),'');
                    parametro.file_max_size = isNULL(rs.getdata('file_max_size'), '0');
                    parametro.file_filtro = isNULL(rs.getdata('file_filtro'), '');
                    parametro.valor_hoja = isNULL(rs.getdata('valor_hoja'), '');
                    parametro.valor_celda = isNULL(rs.getdata('valor_celda'), '');
                    parametro.valor_io = isNULL(rs.getdata('valor_io'), 1);
                    parametro.habilitado = rs.getdata('habilitado') == "True";
                    parametro.valor_eqv = isNULL(rs.getdata('valor_eqv'), '');
                    parametro.id_param = isNULL(rs.getdata('id_param'),'');
                    parametro.tipo_parametria = parametro.campo_def != '' ? 'Campo Def' : (parametro.id_param != '' ? 'Param Global' : '') 
                    parametro.interno = rs.getdata('interno') == "True";

                    Transferencia.parametros.push(parametro);
                    rs.movenext();
                }
            }
            function loadPools(id_transferencia) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_transferencia_pools, "", "<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>", "")
                var options;
                var pool;
                while (!rs.eof()) {
                    options = {};
                    options.id_transferencia_pool = rs.getdata('id_transferencia_pool');
                    options.title = rs.getdata('title');
                    options.order = rs.getdata('order');
                    options.width = parseInt(rs.getdata('width'));
                    pool = newPool(options, false);
                    loadLanes(pool);
                    loadPermisos(pool);
                    rs.movenext();
                }
            }
            function loadLanes(pool) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_transferencia_lanes, "", "<id_transferencia_pool type='igual'>" + pool.id_transferencia_pool + "</id_transferencia_pool>", "")
                var options;
                var lane;
                while (!rs.eof()) {
                    options = {};
                    options.id_transferencia_lane = rs.getdata('id_transferencia_lane');
                    options.title = rs.getdata('title');
                    options.order = rs.getdata('order');
                    options.width = parseInt(rs.getdata('width'));
                    lane = newLane(options, pool);
                    loadPermisos(lane);
                    rs.movenext();
                }
            }
            function loadPermisos(pool) {
                var rs = new tRS();
                if (pool.bpmClass == 'lane') {
                    rs.open(nvFW.pageContents.filtroXML_transferencia_permisos, "", "<id_transferencia_lane type='igual'>" + pool.id_transferencia_lane + "</id_transferencia_lane>","")
                } else {
                    rs.open(nvFW.pageContents.filtroXML_transferencia_permisos, "", "<id_transferencia_pool type='igual'>" + pool.id_transferencia_pool + "</id_transferencia_pool>", "")
                }
                var permiso;
                while (!rs.eof()) {
                    permiso = {};
                    permiso.transferencia_permiso_id = rs.getdata('transferencia_permiso_id');
                    permiso.dbId = rs.getdata('dbId');

                    permiso.tipo_operador = isNULL(rs.getdata('tipo_operador'), '');
                    permiso.tipo_operador_desc = isNULL(rs.getdata('tipo_operador_desc'), '');
                    permiso.nro_operador = isNULL(rs.getdata('nro_operador'), '');
                    permiso.nombre_operador = isNULL(rs.getdata('nombre_operador'), '');
                    
                    permiso.nro_permiso_grupo = isNULL(rs.getdata('nro_permiso_grupo'), '');
                    permiso.permiso_grupo = isNULL(rs.getdata('permiso_grupo'), '');
                    permiso.nro_permiso = isNULL(rs.getdata('nro_permiso'), '');
                    permiso.permitir = isNULL(rs.getdata('permitir'), '');
                    permiso.id_permiso = isNULL(rs.getdata('nro_permiso_grupo'), '') + '_' + isNULL(rs.getdata('nro_permiso'), '') 

                    permiso.permiso = rs.getdata('permiso');
                    pool.permisos.push(permiso);
                    rs.movenext();
                }
            }
            function loadElements(id) {
                
                var rs = new tRS();
                rs.xml_format = 'rs_xml_json';
                rs.open(nvFW.pageContents.filtroXML_transferencia_det, "", "<id_transferencia type='igual'>" + id + "</id_transferencia>","")
                var options;
                while (!rs.eof()) {
                    options = {};
                    options.title = rs.getdata('transferencia');
                    options.id_transf_det = rs.getdata('id_transf_det');
                    options.orden = rs.getdata('orden');
                    options.transf_tipo = rs.getdata('transf_tipo').toUpperCase().replace(' ', '');
                    options.transferencia = rs.getdata('transferencia');
                    options.opcional = rs.getdata('opcional').toString().toLowerCase()== 'true' ? true : false;
                    options.transf_estado = rs.getdata('transf_estado');
                    options.archivo = rs.getdata('archivo');
                    options.TSQL = isNULL(rs.getdata('TSQL'), '');
                    options.dtsx_exec = isNULL(rs.getdata('dtsx_exec'), '');
                    options.dtsx_path = isNULL(rs.getdata('dtsx_path'), '');
                    options.dtsx_parametros = isNULL(rs.getdata('dtsx_parametros'), '');
                    options.filtroXML = isNULL(rs.getdata('filtroXML'), '');
                    options.filtroWhere = isNULL(rs.getdata('filtroWhere'), '');
                    options.report_name = isNULL(rs.getdata('report_name'), '');
                    options.path_reporte = isNULL(rs.getdata('path_reporte'), '');
                    options.salida_tipo = isNULL(rs.getdata('salida_tipo'), "'adjunto'");
                    options.contenttype = isNULL(rs.getdata('contentType'), "''");
                    options.target = isNULL(rs.getdata('target'), '');
                    options.xsl_name = isNULL(rs.getdata('xsl_name'), '');
                    options.path_xsl = isNULL(rs.getdata('path_xsl'), '');
                    options.xml_xsl = rs.getdata('xml_xsl') == 'null' ? '' : isNULL(rs.getdata('xml_xsl'), '');
                    options.xml_data = rs.getdata('xml_data') == 'null' ? '' : isNULL(rs.getdata('xml_data'), '');
                    options.vistaguardada = isNULL(rs.getdata('vistaguardada'), '');
                    options.metodo = isNULL(rs.getdata('metodo'), "''");
                    options.mantener_origen = isNULL(rs.getdata('mantener_origen'), 'false');
                    options.id_exp_origen = isNULL(rs.getdata('id_exp_origen'), '0');
                    options.parametros = isNULL(rs.getdata('parametros'), '');
                    options.top = isNULL(rs.getdata('top'), 50);
                    options.left = isNULL(rs.getdata('left'), 10);
                    options.height = isNULL(rs.getdata('height'), 150);
                    options.width = isNULL(rs.getdata('width'), 150);
                    options.xls_path = isNULL(rs.getdata('xls_path'), '');
                    options.bpmClass = isNULL(rs.getdata('bpm_class'), 'activity');
                    options.xls_path_save_as = isNULL(rs.getdata('xls_path_save_as'), '');
                    options.xls_visible = rs.getdata('xls_visible').toString().toLowerCase() == 'true' ? true : false;
                    options.xls_cerrar = rs.getdata('xls_cerrar').toString().toLowerCase() == 'true' ? true : false;
                    options.xls_guardar_resultado = rs.getdata('xls_guardar_resultado').toString().toLowerCase() == 'true' ? true : false;
                    options.parametros_extra_xml = isNULL(rs.getdata('parametros_extra_xml'), '');
                    options.lenguaje = isNULL(rs.getdata('lenguaje'), '');
                    options.cod_cn = isNULL(rs.getdata('cod_cn'), '');
                    var element = newElement(options);
                    cargar_parametros_det(element);
                    rs.movenext();
                }
            }
            function cargar_parametros_det(element) {
                
                if (['XLS', 'EQV','NOS', 'TRA'].indexOf(element.transf_tipo) != -1) {
                    element.parametros_det = [];
                } else {
                    element.parametros_det = {};
                }
                if (['XLS', 'EQV', 'USR', 'IUS', 'NOS', 'TRA'].indexOf(element.transf_tipo) != -1)
                {
                    var rs = new tRS();
                    var type = element.transf_tipo == 'IUS' ? 'USR' : element.transf_tipo;

                    rs.open(eval("nvFW.pageContents.filtroXML_transferencia_parametros_" + type), "", "<criterio><select><filtro><id_transf_det type='igual'>" + element.id_transf_det + "</id_transf_det></filtro></select></criterio>", "")

                    while (!rs.eof()) {
                        var obj = {};
                        obj.parametro = rs.getdata('parametro');
                        switch (element.transf_tipo) {
                            case 'XLS':
                                obj.valor_hoja = isNULL(rs.getdata('valor_hoja'), '');
                                obj.valor_celda = isNULL(rs.getdata('valor_celda'), '');
                                obj.valor_io = isNULL(rs.getdata('valor_io'), 1);
                                obj.habilitado = true;
                                obj.estado = '';
                                element.parametros_det.push(obj);
                                break;
                            case 'EQV':
                                obj.valor_eqv = isNULL(rs.getdata('valor_eqv'), '');
                                element.parametros_det.push(obj);
                                break;
                            case 'NOS':
                                obj.nosis_def = isNULL(rs.getdata('nosis_def'), '');
                                obj.nosis_xpath = isNULL(rs.getdata('nosis_xpath'), '');
                                obj.nosis_descripcion = isNULL(rs.getdata('nosis_descripcion'), '');
                                obj.parametro = isNULL(rs.getdata('parametro'), '');
                                obj.habilitado = true;
                                obj.disabled = false;
                                obj.estado = '';
                                element.parametros_det.push(obj);
                                break;
                            case 'TRA':
                                obj.transf_id_transferencia = isNULL(rs.getdata('transf_id_transferencia'), '');
                                obj.transf_parametro = isNULL(rs.getdata('transf_parametro'), '');
                                obj.parametro = isNULL(rs.getdata('parametro'), '');
                                obj.habilitado = true;
                                obj.disabled = false;
                                obj.estado = '';
                                element.parametros_det.push(obj);
                                break;
                            //case 'IUS':
                            //    break;
                            case 'USR':
                                var parameter = getParameter(rs.getdata('parametro'));
                                element.parametros_det[parameter.parametro] = {};
                                element.parametros_det[parameter.parametro].parameter = parameter;
                                element.parametros_det[parameter.parametro].tipo = rs.getdata('tipo');
                                element.parametros_det[parameter.parametro].label = rs.getdata('label');
                                element.parametros_det[parameter.parametro].descargable = rs.getdata('descargable') == 'True';
                                element.parametros_det[parameter.parametro].valor_defecto_editable = isNULL(rs.getdata('valor_defecto_editable'), '');
                                element.parametros_det[parameter.parametro].orden = isNULL(rs.getdata('orden'), 0);
                                break;
                             case 'IUS':
                                var parameter = getParameter(rs.getdata('parametro'));
                                element.parametros_det[parameter.parametro] = {};
                                element.parametros_det[parameter.parametro].parameter = parameter;
                                element.parametros_det[parameter.parametro].tipo = rs.getdata('tipo');
                                element.parametros_det[parameter.parametro].label = rs.getdata('label');
                                element.parametros_det[parameter.parametro].descargable = rs.getdata('descargable') == 'True';
                                element.parametros_det[parameter.parametro].valor_defecto_editable = isNULL(rs.getdata('valor_defecto_editable'), '');
                                element.parametros_det[parameter.parametro].orden = isNULL(rs.getdata('orden'), 0);
                                break;
                        }
                        rs.movenext();
                    }
                }
            }
            function loadArrows() {
                Transferencia.detalle.each(function(src) {
                    var dest;
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_transferencia_rel, "", "<det_origen type='igual'>" + src.id_transf_det + "</det_origen>", "")
                    while (!rs.eof()) {
                        dest = ObtenerObjnvCtrls(rs.getdata('det_destino'));
                        if (dest != null) {

                            options = {}
                            options.direction = rs.getdata('direction');
                            options.reception = rs.getdata('reception');
                            options.evaluacion = xmlUnscape(rs.getdata('evaluacion'));
                            options.lenguaje = rs.getdata('lenguaje');
                            options.id_transf_rel = rs.getdata('id_transf_rel');
                            options.title = rs.getdata('title');
                            options.title_position = rs.getdata('titlePosition');
                            options.default = rs.getdata('default') == 'True';
                            options.segmentClassName = rs.getdata('className');
                            options.output_false = rs.getdata('output_false') == 'True';

                            //options.className = rs.getdata('className');

                            var arrow = newArrow(src, dest, options);
                            
                        }
                        rs.movenext();
                    }
                });
            }
            function arrowAfterDraw(arrow) {

                if (arrow.src.transf_tipo == "SSS")
                {
                    var habilitar_unica_salida = false
                    if (arrow.dest.transf_tipo != "SSC") 
                            habilitar_unica_salida = true

                    if (habilitar_unica_salida) {
                        if (arrow.src._arrow_points) {
                            arrow.src._arrow_points.left.hide()
                            arrow.src._arrow_points.right.hide()
                            arrow.src._arrow_points.top.hide()
                            arrow.src._arrow_points.bottom.hide()
                        }
                        arrow.src.allowBeginArrows = false;
                        arrow.src.defaultArrow = arrow;
                    }
                    else
                       arrow.src.defaultArrow = null;
                }

                if (arrow.src.transf_tipo == "IF") {

                    var cant_salidas = 0
                    arrow.src.relations.each(function (relation) {
                        if (relation.src.transf_tipo == "IF")
                            cant_salidas++
                    });

                    if (cant_salidas == 2) {
                        if (arrow.src._arrow_points) {
                            arrow.src._arrow_points.left.hide()
                            arrow.src._arrow_points.right.hide()
                            arrow.src._arrow_points.top.hide()
                            arrow.src._arrow_points.bottom.hide()
                        }
                        arrow.src.allowBeginArrows = false;
                     }
                }
                
                arrow.newMiddleIcon(Icons['empty']);
                if(arrow.src.amIDefault(arrow)){
                    arrow.newFirstIcon(Icons['default']);
                }
                else
                {
                    //if (arrow.src.amIDOutPutFalse(arrow))
                    //    arrow.newFirstIcon(Icons['output_false']);
                    //else
                    // {
                        if (!arrow.evaluacion || arrow.evaluacion == 'true') 
                            arrow.newFirstIcon(Icons['no_condition']);
                        else 
                            arrow.newFirstIcon(Icons['condition']);
                    //}
                }

                if(!arrow.title && arrow.dest.type != 'annotation'){
                    //arrow.title = 'relaci�n' + getTitleCounter();
                }
               
                arrow.updateTitle();
            }
            function newArrow(src, dest, options) {
                options.afterDraw = function(){
                    arrowAfterDraw(this);
                   
                }
                options.dest = dest;//, options.direction, options.reception
                var arrow = src.relation_add(options);
                arrow.evaluacion = options.evaluacion ? options.evaluacion : 'true';
                arrow.lenguaje = options.lenguaje ? options.lenguaje : 'js';
                arrow.id_transf_rel = options.id_transf_rel;

                options['default'] = options['default'] == '0' ? false : options['default'];
                if(options['default']){
                    arrow.src.defaultArrow = arrow;
                }
                options['output_false'] = options['output_false'] == '0' ? false : options['output_false'];
                if (options['output_false']) {
                    arrow.src.OutPutFalseArrow = arrow;
                }
                onArrowDispose(arrow);
                arrow.afterDraw();
                arrow.src.onArrowStop(arrow);
                return arrow;
            }
            function onArrowDispose(arrow){
                arrow.onDispose = function(){
                    var index = Transferencia.relations.indexOf(this);
                    if(index != -1){
                        Transferencia.relations.splice(index, 1);
                    }
                    index = this.src.relations.indexOf(this);
                    if(index != -1){
                        this.src.relations.splice(index, 1);
                    }
                    index = this.dest.relations.indexOf(this);
                    if(index != -1){
                        this.dest.relations.splice(index, 1);
                    }
                }
            }
            function afterArrowAdd(arrow) {

                arrow.afterDraw = function(){
                    arrowAfterDraw(this);
                }
            }
            function loadAnnotations(id_transferencia) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_transferencia_notas,"", "<id_transferencia type='igual'>" + id_transferencia + "</id_transferencia>", "")
                while (!rs.eof()) {
                    //Cargo en el objeto
                    var options = {};
                    options.id_transferencia_annotation = rs.getdata('id_transferencia_nota');
                    options.text = rs.getdata('texto');
                    options.top = rs.getdata('top');
                    options.left = rs.getdata('left');
                    options.width = rs.getdata('width');
                    options.height = rs.getdata('height');
                    newAnnotation(options);
                    rs.movenext();
                }
                loadAnnotationsArrows();
            }
            function loadAnnotationsArrows() {
                Transferencia.annotations.each(function(annotation) {
                    var src;
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_transferencia_notas_det, "", "<id_transferencia_nota type='igual'>" + annotation.id_transferencia_annotation + "</id_transferencia_nota>", "")
                    while (!rs.eof()) {
                        src = ObtenerObjnvCtrls(rs.getdata('id_det'));
                        if (src != null) {
                            options = {}
                            options.id_annotation_det = rs.getdata('id_annotation_det');
                            options.id_annotation = rs.getdata('id_transferencia_nota');
                            options.id_det = rs.getdata('id_det');
                            options.title = rs.getdata('title');
                            options.direction = rs.getdata('direction');
                            options.reception = rs.getdata('reception');
                            //options.title_position = rs.getdata('title_position');

                            var arrow = newArrow(src, annotation, options);
                            arrow.src.onArrowStop(arrow);
                        }
                        rs.movenext();
                    }
                });
            }

            function ObtenerObjnvCtrls(id_element) {
                var obj = null;
                Transferencia.detalle.each(function(element) {
                    if (element.id_transf_det == id_element) {
                        obj = element;
                        throw $break;
                    }
                });
                return obj;
            }
            
            function getParameter(name){
                var parameter = null;
                Transferencia.parametros.each(function(parametro){
                    if(parametro.parametro == name){
                        parameter = parametro;
                        throw $break;
                    }
                });
                return parameter;
            }
            /******************************************************/
            /**
             * verifica detalles correcciones automatizables
             */
            function autoFixTransfer() {
                checkPool();
            }
            function checkIni() {
                var hasIni = false;
                var firstNodes = [];
                Transferencia.detalle.each(function(element) {
                    if (element.transf_tipo == 'INI' || element.transf_tipo == 'IUS') {
                        hasIni = true;
                    }
                    firstNodes.push(element);
                });
                Transferencia.detalle.each(function(element) {
                    element.relations.each(function(relation) {
                        var index_of = firstNodes.indexOf(relation.dest);
                        if (index_of != -1) {
                            firstNodes.splice(index_of, 1);
                        }
                    });
                });
                if (!hasIni) {

                    confirm("La transferencia no posee un evento de inicio. �Desea Agregarlo autom�ticamente?", {
                        width: 400,
                        height:"auto",
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (win) {

                            var options = makeElementOptions('INI');
                            options.left = -20000;
                            options.top = 200;
                            var ini = newElement(options);
                            fixElementsPositions();
                            firstNodes.each(function (dest) {
                                var options = {};
                                options.direction = 'right';
                                options.reception = 'left';
                                options.evaluacion = 'true';
                                options.lenguaje = 'js';
                                options.id_transf_rel = 0;
                                newArrow(ini, dest, options);
                                Undo.add("Insertar evento");
                            });

                            win.close(); return
                        },
                        onCancel: function (win) { win.close(); return }
                    });

                  /*  if (confirm("La transferencia no posee un evento de inicio. �Desea Agregarlo autom�ticamente?")) {
                        var options = makeElementOptions('INI');
                        options.left = -20000;
                        options.top = 200;
                        var ini = newElement(options);
                        fixElementsPositions();
                        firstNodes.each(function(dest) {
                            var options = {};
                            options.direction = 'right';
                            options.reception = 'left';
                            options.evaluacion = 'true';
                            options.lenguaje = 'vb';
                            options.id_transf_rel = 0;
                            newArrow(ini, dest, options);
                        });
                    }*/
                }
            }
            function checkEnd() {
                var hasEnd = false;
                var lastNodes = [];
                Transferencia.detalle.each(function(element) {
                    if (element.transf_tipo == 'END') {
                        hasEnd = true;
                    }
                    var isARelationSrc = false;
                    element.relations.each(function(relation) {
                        if (relation.src == element) {
                            isARelationSrc = true;
                        }
                    });
                    if (!isARelationSrc) {
                        lastNodes.push(element);
                    }
                });
                if (!hasEnd) {

                    confirm("La transferencia no posee un evento de fin. �Desea Agregarlo autom�ticamente?", {
                        width: 400,
                        height: "auto",
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (win) {

                            var options = makeElementOptions('END');
                            options.left = 20000;
                            options.top = 200;
                            var end = newElement(options);
                            fixElementsPositions();
                            lastNodes.each(function (src) {
                                var options = {};
                                options.direction = 'right';
                                options.reception = 'left';
                                options.evaluacion = 'true';
                                options.lenguaje = 'vb';
                                options.id_transf_rel = 0;
                                newArrow(src, end, options);
                            });
                            win.close(); return
                        },
                        onCancel: function (win) { win.close(); return }
                    });

                  /*  if (confirm("La transferencia no posee un evento de fin. �Desea Agregarlo autom�ticamente?")) {
                        var options = makeElementOptions('END');
                        options.left = 20000;
                        options.top = 200;
                        var end = newElement(options);
                        fixElementsPositions();
                        lastNodes.each(function(src) {
                            var options = {};
                            options.direction = 'right';
                            options.reception = 'left';
                            options.evaluacion = 'true';
                            options.lenguaje = 'vb';
                            options.id_transf_rel = 0;
                            newArrow(src, end, options);
                        });
                    }*/
                }
            }
            function checkPool() {
                if (Transferencia.pools.length == 0) {

                    confirm("La transferencia no posee un pool. �Desea Agregarlo autom�ticamente?", {
                        width: 400,
                        height: "auto",
                        className: "alphacube",
                        okLabel: "Si",
                        cancelLabel: "No",
                        onOk: function (win) {

                            var options = {};
                            options.order = 0;
                            options.width = getElementsMaxWidth() + 100;
                            newPool(options);
                            fixElementsPositions();

                            checkIni();
                            checkEnd();

                            win.close(); return
                        },
                        onCancel: function (win) { win.close(); return }
                    });

                    /*    if (confirm("La transferencia no posee un pool. �Desea Agregarlo autom�ticamente?")) {
                            var options = {};
                            options.order = 0;
                            options.width = getElementsMaxWidth() + 100;
                            newPool(options);
                            fixElementsPositions();
                        }*/
                }
                else {

                    checkIni();
                    checkEnd();
                }

            }
            function getElementsMaxWidth() {
                var width = 0;
                Transferencia.detalle.each(function(element) {
                    var curr_width = element.getLeft() + element.getWidth();
                    if (width < curr_width) {
                        width = curr_width;
                    }
                });
                return width;
            }
            /******************************************************/
           // var win;
            function abm_transferencia_parametros() {
                //si existe una ventana de parametros abierta no crea otra
                var _windows = window.top.Windows.windows
                for (var i = 0; i < _windows.length; i++) {
                    if (_windows[i].options.title == '<b>Par�metros</b>') {
                        return;
                    }
                }

                transf_clear_event_copy()

                var path = "/fw/transferencia/transferencia_parametros_abm.aspx?id_transferencia=" + Transferencia.id_transferencia;
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                var win = nvFW.createWindow({
                    className: 'alphacube',
                    url: path,
                    title: '<b>Par�metros</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    //width: 960,
                    //height: 400,
                    //top: 60,
                    //left: 300,
                    centerHFromElement: $("container"),
                    parentWidthElement: $("container"),
                    parentWidthPercent: 0.9,
                    parentHeightElement: $("container"),
                    parentHeightPercent: 0.9,
                    resizable: true,
                    destroyOnClose: true,
                    zIndex: zIndex,
                    onClose: abm_transferencia_parametros_return
                });
                win.options.Transferencia = Transferencia;
                win.showCenter();
            }
            function abm_transferencia_parametros_return() {
                if (typeof (win.options.returnValue) == 'object')
                    Transferencia = win.returnValue;

                ultimo = Transferencia.parametros.length-1
                if (ultimo >= 0)
                    if (Transferencia.parametros[ultimo].parametro == "")
                    Transferencia.parametros.splice(ultimo, 1)

                Undo.add("Acceso par�metro");
            }
            var WinAbrir
            function abrir(return_fuction) {
                // campos_defs.onclick(null, 'id_transferencia');

               transf_clear_event_copy()

                WinAbrir = nvFW.createWindow({ className: 'alphacube',
                    title: '<b>Buscar</b>',
                    url: '/fw/transferencia/transf_buscar.aspx',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    //width: 900,
                    //height: 450,
                    centerHFromElement: $("container"),
                    parentWidthElement: $("container"),
                    parentWidthPercent: 0.9,
                    parentHeightElement: $("container"),
                    parentHeightPercent: 0.9,
                    resizable: true,
                    destroyOnClose: true,
                    onClose: return_fuction
                })

                WinAbrir.options.userData = ""
                WinAbrir.showCenter(true)
            }
            function return_abrir() 
            {
                if (WinAbrir.options.userData > 0) 
                    setTimeout("campos_defs.set_value('id_transferencia', WinAbrir.options.userData);onChangeIdTransferencia()",50)
            }                    
            function saveLaneElements() {
                Transferencia.pools.each(function(pool) {
                    pool.lanes.each(function(lane) {
                        lane.orgX = lane.div.cumulativeOffset().left;
                        lane.elements = [];
                        Transferencia.detalle.each(function(element) {
                            if (lane.checkRectIn(element).fullXIn) {
                                lane.elements.push(element);
                            }
                        });
                    });
                });
            }
            function restoreLaneElements() {
                Transferencia.pools.each(function(pool) {
                    pool.lanes.each(function(lane) {
                        if (lane.elements) {
                            var delta = lane.div.cumulativeOffset().left - lane.orgX;
                            lane.elements.each(function(element) {
                                element.move({offsetX: delta});
                            });
                        }
                    });
                });
            }
            function isNULL(valor, sinulo) {
                valor = valor == null ? sinulo : valor;
                return valor;
            }
            function makeXML(save_as, accion, save_as_transf_desc, save_as_transf_id) {

                save_as = save_as ? '1' : '0';
                save_as_transf_desc = save_as_transf_desc ? save_as_transf_desc : ''
                save_as_transf_id = save_as_transf_id ? save_as_transf_id : 0

                if (!accion)
                  accion = 'undo' 

                // if (accion == 'copy')
                  //  accion = 'guardar' 

                //actualizar campos   
                Transferencia.nombre = $('nombre').value;
                if ($('habi').checked == true) {
                    Transferencia.habi = 'S';
                } else {
                    Transferencia.habi = 'N';
                }
                Transferencia.timeout = $('timeout').value == "" ? -1 : ($('timeout').value*1000);
                Transferencia.id_transf_estado = campos_defs.value('id_transf_estado');
                Transferencia.transf_version = $('transf_version').value; 
                Transferencia.log_param_save = $('log_param_save').value; 

                // Cargo el Time Out con 90 segundos por defecto, si estan vacio o < a los valores definidos
                Transferencia.timeout = Transferencia.timeout == '' ? 90 : Transferencia.timeout;
                if (Transferencia.id_transferencia == -1) {
                    Transferencia.id_transferencia = 0;
                }
                //Cargar XML
                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>";
                xmldato += "<transferencia id_transferencia='" + Transferencia.id_transferencia + "'";
                xmldato += " nombre='" + $('nombre').value + "'";
                xmldato += " habi='" + Transferencia.habi + "'";
                xmldato += " timeout='" + Transferencia.timeout + "'";
                xmldato += " id_transf_estado='" + Transferencia.id_transf_estado + "'";
                xmldato += " transf_version='" + Transferencia.transf_version + "'";
                xmldato += " log_param_save='" + Transferencia.log_param_save + "'";
                xmldato += " save_as='" + save_as + "'";
                xmldato += " save_as_transf_desc='" + save_as_transf_desc + "'";
                xmldato += " transf_fe_creacion='" + Transferencia.transf_fe_creacion + "'";
                xmldato += " transf_fe_modificado='" + Transferencia.transf_fe_modificado + "'";
                xmldato += " nombre_operador='" + Transferencia.nombre_operador + "'";
                xmldato += " save_as_transf_id='" + save_as_transf_id + "'>";
                xmldato += "<parametros>";
                Transferencia.parametros.each(function(parametro) {
                    xmldato += "<parametro parametro='" + parametro.parametro + "' tipo_dato='" + parametro.tipo_dato + "' valor_defecto='" + parametro.valor_defecto + "' requerido='" + parametro.requerido + "' editable='" + parametro.editable + "' etiqueta='" + parametro.etiqueta + "' orden='" + parametro.orden + "' valor_defecto_editable='" + parametro.valor_defecto_editable + "' campo_def='" + parametro.campo_def + "' id_param='" + parametro.id_param + "' file_max_size='" + parametro.file_max_size + "' file_filtro='" + parametro.file_filtro + "'  interno='" + parametro.interno + "'>";
                    xmldato += "</parametro>";
                });
                xmldato += "</parametros>";
                xmldato += "<pools>";
                Transferencia.pools.each(function(pool) {
                    pool.id_transferencia_pool = !pool.id_transferencia_pool ? 0 : pool.id_transferencia_pool;
                    xmldato += "<pool id_transferencia_pool='" + pool.id_transferencia_pool + "' title='" + pool.title + "' order='" + pool.getOrder() + "' width='" + pool.getWidth() + "'>";
                    xmldato += "<lanes>";
                    pool.lanes.each(function(lane) {
                        lane.id_transferencia_lane = !lane.id_transferencia_lane ? 0 : lane.id_transferencia_lane;
                        lane.temp_id = pool.getOrder() + '_' + lane.getOrder();
                        xmldato += "<lane temp_id='" + lane.temp_id + "' id_transferencia_lane='" + lane.id_transferencia_lane + "' title='" + lane.title + "' order='" + lane.getOrder() + "' width='" + lane.getWidth() + "'>";
                        xmldato += "<permisos>";
                        lane.permisos.each(function(permiso) {
                            permiso.nro_operador = !permiso.nro_operador ? 0 : permiso.nro_operador 
                            permiso.tipo_operador = !permiso.tipo_operador ? 0 : permiso.tipo_operador
                            permiso.nro_permiso_grupo = !permiso.nro_permiso_grupo ? 0 : permiso.nro_permiso_grupo
                            permiso.nro_permiso = !permiso.nro_permiso ? 0 : permiso.nro_permiso
                            xmldato += "<permiso transferencia_permiso_id='" + permiso.transferencia_permiso_id + "' nro_operador='" + permiso.nro_operador + "' nombre_operador='" + permiso.nombre_operador + "' tipo_operador='" + permiso.tipo_operador + "' tipo_operador_desc='" + permiso.tipo_operador_desc + "' permiso='" + permiso.permiso + "' nro_permiso_grupo='" + permiso.nro_permiso_grupo + "' nro_permiso='" + permiso.nro_permiso + "' >";
                            xmldato += "</permiso>";
                        });
                        xmldato += "</permisos>";
                        xmldato += "</lane>";
                    });
                    xmldato += "</lanes>";
                    xmldato += "<permisos>";
                    pool.permisos.each(function(permiso) {
                        permiso.nro_operador = !permiso.nro_operador ? 0 : permiso.nro_operador 
                        permiso.tipo_operador = !permiso.tipo_operador ? 0 : permiso.tipo_operador
                        permiso.nro_permiso_grupo = !permiso.nro_permiso_grupo ? 0 : permiso.nro_permiso_grupo
                        permiso.nro_permiso = !permiso.nro_permiso ? 0 : permiso.nro_permiso
                        xmldato += "<permiso transferencia_permiso_id='" + permiso.transferencia_permiso_id + "' nro_operador='" + permiso.nro_operador + "' nombre_operador='" + permiso.nombre_operador + "' tipo_operador='" + permiso.tipo_operador + "' tipo_operador_desc='" + permiso.tipo_operador_desc + "' permiso='" + permiso.permiso + "' nro_permiso_grupo='" + permiso.nro_permiso_grupo + "' nro_permiso='" + permiso.nro_permiso + "'>";
                        xmldato += "</permiso>";
                    });
                    xmldato += "</permisos>";
                    xmldato += "</pool>";
                });
                xmldato += "</pools>";
                xmldato += "<detalles>";
                Transferencia.detalle.each(function(detalle) {
                    var lane = detalle.getLane();
                    detalle["lenguaje"] = detalle["lenguaje"] == '' ? 'js' : detalle["lenguaje"]

                    var selected = ""
                    if (accion == 'copy')
                        selected = " selected = '"+ (!detalle.selected ? false : detalle.selected ) +"'"

                    xmldato += "<detalle id_transf_det='" + detalle.id_transf_det + "' " + selected + " orden='" + detalle.getOrder() + "' transf_tipo='" + detalle.transf_tipo + "' opcional='" + detalle["opcional"] + "' transf_estado='" + detalle["transf_estado"] + "' dtsx_exec='" + detalle["dtsx_exec"] + "' top='" + detalle.getTop() + "' left='" + detalle.getLeft() + "' height='" + detalle.getInnerHeight() + "' width='" + detalle.getInnerWidth() + "' bpm_class='" + detalle.bpmClass + "' lane_temp_id='" + (lane ? lane.temp_id : 0) + "' temp_id='" + detalle.getOrder() + "'>";
                    xmldato += "<transferencia><![CDATA[" + detalle.title + "]]></transferencia>";
                    switch (detalle.transf_tipo) {
                        case 'SP':
                            xmldato += "<TSQL><![CDATA[" + detalle["TSQL"] + "]]></TSQL>";
                            xmldato += "<cod_cn><![CDATA[" + detalle["cod_cn"] + "]]></cod_cn>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'SCR':
                            xmldato += "<TSQL><![CDATA[" + detalle["TSQL"] + "]]></TSQL>";
                            xmldato += "<lenguaje><![CDATA[" + detalle["lenguaje"] + "]]></lenguaje>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'SSR':
                            xmldato += "<TSQL><![CDATA[" + detalle["TSQL"] + "]]></TSQL>";
                            xmldato += "<lenguaje><![CDATA[" + detalle["lenguaje"] + "]]></lenguaje>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'DTS':
                            xmldato += "<dtsx_path><![CDATA[" + detalle["dtsx_path"] + "]]></dtsx_path>";
                            xmldato += "<dtsx_parametros><![CDATA[" + detalle["dtsx_parametros"] + "]]></dtsx_parametros>";
                            xmldato += "<target><![CDATA[" + detalle["target"] + "]]></target>";
                            xmldato += "<salida_tipo><![CDATA['adjunto']]></salida_tipo>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'INF':
                            xmldato += "<filtroXML><![CDATA[" + detalle["filtroXML"] + "]]></filtroXML>";
                            xmldato += "<filtroWhere><![CDATA[" + detalle["filtroWhere"] + "]]></filtroWhere>";
                            xmldato += "<report_name><![CDATA[" + detalle["report_name"] + "]]></report_name>";
                            xmldato += "<path_reporte><![CDATA[" + detalle["path_reporte"] + "]]></path_reporte>";
                            xmldato += "<salida_tipo><![CDATA[" + detalle["salida_tipo"] + "]]></salida_tipo>";
                            xmldato += "<target><![CDATA[" + detalle["target"] + "]]></target>";
                            xmldato += "<vistaguardada><![CDATA[" + detalle["vistaguardada"] + "]]></vistaguardada>";
                            xmldato += "<contenttype><![CDATA[" + detalle["contenttype"] + "]]></contenttype>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'EXP':
                            xmldato += "<filtroXML><![CDATA[" + detalle["filtroXML"] + "]]></filtroXML>";
                            xmldato += "<filtroWhere><![CDATA[" + detalle["filtroWhere"] + "]]></filtroWhere>";
                            xmldato += "<xsl_name><![CDATA[" + detalle["xsl_name"] + "]]></xsl_name>";
                            xmldato += "<path_xsl><![CDATA[" + detalle["path_xsl"] + "]]></path_xsl>";
                            xmldato += "<xml_xsl><![CDATA[" + getBase64FromString(detalle["xml_xsl"]) + "]]></xml_xsl>";
                            xmldato += "<xml_data><![CDATA[" + detalle["xml_data"] + "]]></xml_data>";
                            xmldato += "<salida_tipo><![CDATA[" + detalle["salida_tipo"] + "]]></salida_tipo>";
                            xmldato += "<contenttype><![CDATA[" + detalle["contenttype"] + "]]></contenttype>";
                            xmldato += "<target><![CDATA[" + detalle["target"] + "]]></target>";
                            xmldato += "<vistaguardada><![CDATA[" + detalle["vistaguardada"] + "]]></vistaguardada>";
                            xmldato += "<metodo><![CDATA[" + detalle["metodo"] + "]]></metodo>";
                            xmldato += "<mantener_origen><![CDATA[" + detalle["mantener_origen"] + "]]></mantener_origen>";
                            xmldato += "<id_exp_origen><![CDATA[" + detalle["id_exp_origen"] + "]]></id_exp_origen>";
                            xmldato += "<parametros><![CDATA[" + detalle["parametros"] + "]]></parametros>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'XLS':
                            xmldato += "<xls_path><![CDATA[" + detalle["xls_path"] + "]]></xls_path>";
                            xmldato += "<target><![CDATA[" + detalle["target"] + "]]></target>";
                            xmldato += "<xls_path_save_as><![CDATA[" + detalle["xls_path_save_as"] + "]]></xls_path_save_as>";
                            xmldato += "<xls_visible><![CDATA[" + detalle["xls_visible"] + "]]></xls_visible>";
                            xmldato += "<xls_cerrar><![CDATA[" + detalle["xls_cerrar"] + "]]></xls_cerrar>";
                            xmldato += "<xls_guardar_resultado><![CDATA[" + detalle["xls_guardar_resultado"] + "]]></xls_guardar_resultado>";
                            xmldato += "<parametros_det>";
                            var parametro_det;
                            for (var i = 0; i < detalle["parametros_det"].length; i++)
                            {
                                parametro_det = detalle["parametros_det"][i];
                                if (parametro_det["estado"] == '' && parametro_det["habilitado"])
                                    xmldato += "<parametro_det parametro ='" + parametro_det["parametro"] + "' valor_hoja ='" + parametro_det["valor_hoja"] + "' valor_celda ='" + parametro_det["valor_celda"] + "' valor_io ='" + parametro_det["valor_io"] + "'/>";
                            }
                            xmldato += "</parametros_det>";
                            break;
                        case 'EQV':
                            xmldato += "<parametros_det>";
                            var parametro_det;
                            for (var i = 0; i < detalle["parametros_det"].length; i++)
                            {
                                parametro_det = detalle["parametros_det"][i];
                                xmldato += "<parametro_det parametro ='" + parametro_det["parametro"] + "' valor_eqv ='" + parametro_det["valor_eqv"] + "'/>";
                            }
                            xmldato += "</parametros_det>";
                            break
                        case 'NOS':
                            /*  xmldato += "<nosis_cuil><![CDATA[" + detalle["nosis_cuil"] + "]]></nosis_cuil>";
                              xmldato += "<nosis_cda><![CDATA[" + detalle["nosis_cda"] + "]]></nosis_cda>";
                              xmldato += "<nosis_nro_vendedor><![CDATA[" + detalle["nosis_nro_vendedor"] + "]]></nosis_nro_vendedor>";*/
                            
                            xmldato += "<parametros_det>";
                            var parametro_det;
                            for (var i = 0; i < detalle["parametros_det"].length; i++) {
                                parametro_det = detalle["parametros_det"][i];
                                xmldato += "<parametro_det parametro ='" + parametro_det["parametro"] + "' nosis_def ='" + parametro_det["nosis_def"] + "' nosis_descripcion='" + parametro_det["nosis_descripcion"] + "' nosis_xpath ='" + parametro_det["nosis_xpath"] + "'/>";
                            }
                            xmldato += "</parametros_det>";
                            break
                        case 'TRA':
                            //xmldato += "<parametros_det transf_id_transferencia='" + detalle.parametros_extra.id_transferencia + "'>";
                            //var parametro_det;
                            //for (var i = 0; i < detalle["parametros_det"].length; i++) {
                            //    parametro_det = detalle["parametros_det"][i];
                            //    xmldato += "<parametro_det transf_parametro='" + parametro_det["transf_parametro"] + "' parametro='" + parametro_det["parametro"] + "'/>";
                            //}
                            //xmldato += "</parametros_det>";
                        break
                        case 'IUS':
                        case 'USR':
                            xmldato += "<parametros_det>";
                            var parametro_det;
                            for (var parametro in detalle["parametros_det"])
                            {
                                parametro_det = detalle["parametros_det"][parametro];
                                xmldato += "<parametro_det parametro='" + parametro_det.parameter.parametro + "' tipo='" + parametro_det.tipo + "' descargable='" + parametro_det.descargable + "' label='" + parametro_det.label + "' valor_defecto_editable='" + parametro_det.valor_defecto_editable + "' orden='" + parametro_det.orden + "'/>";
                            }
                            xmldato += "</parametros_det>";
                            break;
                        case 'IF':
                            xmldato += "<lenguaje><![CDATA[" + detalle["lenguaje"] + "]]></lenguaje>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'SEG':
                            xmldato += "<lenguaje><![CDATA[" + detalle["lenguaje"] + "]]></lenguaje>";
                            xmldato += "<parametros_det></parametros_det>";
                            break;
                        case 'MSG':
                            break;
                    }
                    //xmldato += "<parametros_extra_xml><![CDATA[" + detalle.makeParametrosExtra() + "]]></parametros_extra_xml>";
                    xmldato += "<parametros_extra_xml>" + detalle.makeParametrosExtra() + "</parametros_extra_xml>";

                    xmldato += "<relations>";
                    var order = 0;
                    detalle.relations.each(function (relation) {

                        var contar = true
                        if (relation.src.selected != true  && accion == 'copy')
                            contar = false

                        if (detalle.id == relation.src.id && relation.dest.type != 'annotation' && contar == true) {
                            var id_transf_rel = !relation.id_transf_rel ? 0 : relation.id_transf_rel;
                            var det_destino = relation.dest.id_transf_det;
                            var dest_temp_id = relation.dest.getOrder();
                            var direction = relation.direction;
                            var reception = relation.reception;
                            var evaluacion = relation.evaluacion == null ? 'true' : relation.evaluacion;
                            var lenguaje = relation.lenguaje == null ? 'vb' : relation.lenguaje;
                          //  var className = relation.className == null ? '' : relation.className;
                            var className = relation.segmentClassName == null ? '' : relation.segmentClassName;
                            
                            xmldato += "<relation id_transf_rel='" + id_transf_rel + "' ClassName='" + className + "' dest_temp_id='" + dest_temp_id + "' lenguaje='" + lenguaje + "' det_destino='" + det_destino + "' direction='" + direction + "' reception='" + reception + "'  output_false='" + (relation.src.amIDOutPutFalse(relation) ? '1' : '0') + "' default='" + (relation.src.amIDefault(relation) ? '1' : '0') + "' title_position='" + relation.title_position + "' orden='" + order + "'>";
                            xmldato += "<evaluacion><![CDATA[" + xmlUnscape(evaluacion) + "]]></evaluacion>";
                            xmldato += "<title><![CDATA[" + relation.title + "]]></title>";
                            xmldato += "</relation>";
                            order++;
                        }
                    });
                    xmldato += "</relations>";
                    xmldato += "</detalle>";
                });
                xmldato += "</detalles>";
                xmldato += "<annotations>";
                Transferencia.annotations.each(function(annotation) {
                    xmldato += "<annotation id_transferencia_annotation='" + annotation.id_transferencia_annotation + "' top='" + annotation.getTop() + "' left='" + annotation.getLeft() + "' height='" + annotation.getInnerHeight() + "' width='" + annotation.getInnerWidth() + "' >";
                    xmldato += "<text><![CDATA[" + annotation.text + "]]></text>";
                    xmldato += "<relations>";
                    annotation.relations.each(function(relation){
                        xmldato += "<relation id_transf_det='" + relation.src.id_transf_det + "' transf_det_temp_id='" + relation.src.getOrder() + "' direction='" + relation.direction + "' reception='" + relation.reception + "'>";
                        xmldato += "<title><![CDATA[" + relation.title + "]]></title>";
                        xmldato += "</relation>";
                    });
                    xmldato += "</relations>";
                    xmldato += "</annotation>";
                });
                xmldato += "</annotations>";
                xmldato += "</transferencia>";

                //console.debug(xmldato)

                var objXML = new tXML()
                objXML.loadXML(xmldato)

                if (!objXML.xml) {
                    console.error("Error xml de referencia")
                }

//            console.log(xmldato.replace(/'/g, '"'));

                return xmldato;
            }

            function getBase64FromString(valor) 
             {
                
                var res = ''
                if (valor == '' || valor == '0x')
                    return res

                var oXML = new tXML()
                oXML.method = "POST"
                var URL = 'transferencia_abm.aspx'//?modo=SET_STRING_BASE64&valor=' + escape(valor)
                oXML.load(URL, 'modo=SET_STRING_BASE64&valor=' + encodeURIComponent(valor))

                try {

                    var err = new tError()
                    err.error_from_xml(oXML)

                    if (err.numError == 0)
                       res = err.params["XMLXSLBase64"]
                }
                catch (e) { }

                return res
            }            
    
            function guardar(params) {

               if (!nvFW.tienePermiso("permisos_transferencia", 2)) {
                 alert('No posee los permisos necesarios para realizar esta acci�n.')
                 return
                }

                if (Transferencia.id_transferencia > 0) {
                     if (!nvFW.tienePermiso(nvFW.pageContents.permiso_grupo, nvFW.pageContents.nro_permiso_editar)) {
                        alert("No posee los permisos espec�ficos para realizar esta acci�n.")
                        return;
                    }
                }

                if (!params)
                    params = {};

                recargar = !params.recargar ? true : params.recargar;
                save_as = !params.save_as ? false : params.save_as;
                save_as_transf_desc = !params.save_as_transf_desc ? '' : params.save_as_transf_desc;
                save_as_transf_id = !params.save_as_transf_id ? 0 : params.save_as_transf_id;
                check_validate = !params.check_validate ? true : params.check_validate;
                
                var validation = validate();
                if (!check_validate)
                    validation.valid = true; // no existen errores

                if (!validation.valid)
                    confirm("<ul style='text-align:left'><li> "  + validation.errors.join('.<li>') + "</ul>" + "<br><br><b>�Desea continuar?</b>", {
                        width: 450,
                        height: "auto",
                        okLabel: "Si",
                        cancelLabel: "No",
                        draggable: true,
                        resizable:true,
                        onOk: function (win) {
                            
                            ajaxRequest(params)

                            win.close(); return
                        },
                        onCancel: function (win) { win.close(); return }
                    });
                else
                    ajaxRequest(params)

            }

            function ajaxRequest(params) {

                //recargar = recargar === undefined ? true : recargar;
                //save_as = save_as === undefined ? false : save_as;
                //save_as_transf_desc = save_as_transf_desc === undefined ? '' : save_as_transf_desc;
                //save_as_transf_id = save_as_transf_id === undefined ? 0 : save_as_transf_id;

                var xml = makeXML(params.save_as, 'guardar', params.save_as_transf_desc,params.save_as_transf_id);
                
                nvFW.bloqueo_activar($$('BODY')[0], "bloq")

                nvFW.error_ajax_request('Transferencia_ABM.aspx', {
                    parameters: {
                        modo: 'A',
                        strXML: xml,
                        id_transferencia: $('id_transferencia_txt').value
                    },
                    onSuccess: function (err, transport) {

                        nvFW.bloqueo_desactivar($$('BODY')[0], 'bloq')

                        if (err.params.id_transferencia != -1 && recargar)
                         {
                            var reload = false
                            if ($('id_transferencia_txt').value != err.params.id_transferencia)
                                reload  = true

                            $('id_transferencia_txt').value = Transferencia.id_transferencia = err.params.id_transferencia
                            campos_defs.items.id_transferencia.input_hidden.value = $('id_transferencia_txt').value
                            $('nombre').value = Transferencia.nombre = err.params.nombre
                            
                            //autoFixTransfer();
                            //if (params.save_as == true)

                            if (reload  === true || params.save_as === true)
                              redirectToTransferABM(err.params.id_transferencia);

                        }
                    },
                    onFailure: function (err) {
                        nvFW.bloqueo_desactivar($$('BODY')[0], 'bloq')
                        alert(err.mensaje, {
                            title: '<b>' + err.titulo + '</b>',
                            width: 350
                        })
                        return
                    },
                    bloq_msg: 'Guardando transferencia...',
                    error_alert: true
                });
            }

            function return_abrir_guardar_como() {
                if (WinAbrir.options.userData > 0) {
                    $('transf_guardar_como').value = WinAbrir.options.id_transferencia
                    $('transf_guardar_como_desc').value = WinAbrir.options.nombre
                }
            }                    

            var transf_guardar_como = ""
            function guardarComo() {

               if (!nvFW.tienePermiso("permisos_transferencia", 2)) {
                 alert('No posee los permisos necesarios para realizar esta acci�n.')
                 return
               }
               
                transf_guardar_como = ""

                var strHTML = "<section><p style='padding: 5px 5px 0 0'>Cuenta con dos opciones de guardado:</p>"
                    strHTML += "<ul style='float:left;text-align:left'>"
                    strHTML += "<li style= 'padding: 0 5px 10px 10px'>1. Puede crear una copia identica. Para ello deber� ingresar el nuevo nombre para identificarla: <input type='text' style='width:80%' id='save_as_transf_desc_text' value='"+ $('nombre').value +"' /></li>"
                    strHTML += "<li style= 'padding: 0 5px 0 10px'>2. La transferencia <b>" + $('nombre').value + "</b> reemplazar� a la transferencia que usted seleccione: <div id='cdguardar_como' style='width:80%'><input type='hidden' id='transf_guardar_como'/><input type='text' readonly='readonly' id='transf_guardar_como_desc' style='posicion:relative;width:90%;margin-right:5px'/><img src='/fw/image/transferencia/buscar.png' style='cursor:pointer' onclick='abrir(return_abrir_guardar_como)'></div></li>"
                    strHTML += "</ul></section>"

                confirm(strHTML,//"Se crear� una copia id�ntica de toda la transferencia.�Desea continuar?",
                    {
                        width: 500,
                        height: "auto",
                        className: "alphacube",
                        okLabel: "Aceptar",
                        cancelLabel: "Cancelar",
                        title: "<b>" + $('nombre').value + " Guardar Como...</b>",
                        onShow: function () {
                            $('save_as_transf_desc_text').select();
                            //campos_defs.add("id_transferencia_guardar_como", { nro_campo_tipo: 1, target: "cdguardar_como" });
                        },
                        onOk: function (w) {
                            
                            if ($('save_as_transf_desc_text').value == "" && $('transf_guardar_como').value == "") {
                                alert("Ingrese el nombre de la transferencia.")
                                return
                            }
                            
                            if ($('transf_guardar_como').value > 0) {

                                transf_guardar_como = $('transf_guardar_como').value

                                confirm("�Desea reemplazar el contenido de la transferencia <b>" + $("transf_guardar_como_desc").value + "</b>? <input type='hidden' id='save_as_transf_desc_text' value='"+ $('save_as_transf_desc_text').value  +"'>",//"Se crear� una copia id�ntica de toda la transferencia.�Desea continuar?",
                                    {
                                        width: 300,
                                        height: "auto",
                                        className: "alphacube",
                                        okLabel: "Si",
                                        cancelLabel: "No",
                                        onOk: function (w1) {
                                            
                                            //guardar(true, true, $('save_as_transf_desc_text').value, campos_defs.value("id_transferencia"));
                                            guardar({ recargar: true, save_as: true, save_as_transf_desc: $('save_as_transf_desc_text').value, save_as_transf_id: transf_guardar_como  });

                                            w1.close()
                                        },
                                        onCancel: function (w1) {
                                            w1.close()
                                        }
                                    });
                            }
                            else
                                guardar({ recargar: true, save_as: true, save_as_transf_desc: $('save_as_transf_desc_text').value, save_as_transf_id: transf_guardar_como });

                            w.close();
                            return true                          
                        },

                        onCancel: function (w) {
                            return false;
                        }
                    });
            }
        </script>
        <script type="text/javascript">
            var winRel
            function abm_transferencia_rel(obj, e) 
            {

                transf_clear_event_copy()

                var id_point = Event.element(e).id

                var path = "transferencia_rel_abm.aspx"
                //var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                var zIndex = 20000;
                winRel = nvFW.createWindow({
                    url: path,
                    title: '<b>Relaci�n entre Tareas</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    centerHFromElement: $("container"),
                    parentWidthElement: $("container"),
                    parentWidthPercent: 0.6,
                    parentHeightElement: $("container"),
                    parentHeightPercent: 0.7,
                    resizable: true,
                    destroyOnClose: true,
                    zIndex: zIndex,
                    onClose: abm_transferencia_rel_return
                });
                winRel.options.rel = obj
                winRel.options.id_point = id_point
                winRel.options.accion = 'A'
                winRel.options.parametros = Transferencia.parametros
                winRel.showCenter(true)
            }
            function abm_transferencia_rel_return() {
                
                Undo.add("Retorno relaci�n " + winRel.options.rel.src.transf_tipo + " y " + winRel.options.rel.dest.transf_tipo)
                
                if (winRel.options.accion == 'B') {
                    var obj = winRel.options
                    var indice_src = winRel.options.rel.src.relations.indexOf(winRel.options.rel)
                    var indice_dest = winRel.options.rel.dest.relations.indexOf(winRel.options.dest)

                    if (winRel.options.rel.src.relations[indice_src].dest.transf_tipo != 'SSC' && !winRel.options.rel.src.allowBeginArrows)
                        winRel.options.rel.src.allowBeginArrows = true;

                    if (winRel.options.rel.src.transf_tipo == 'IF') {
                        
                        //if (winRel.options.rel.src.relations.length == 2 && !winRel.options.rel.src.allowBeginArrows)
                        //    winRel.options.rel.src.allowBeginArrows = true;

                        //if (winRel.options.rel.src.parametros_extra.op_true_RectId == winRel.options.rel.dest.id || winRel.options.rel.src.parametros_extra.op_true_RectId == winRel.options.rel.dest.parametros_extra.RectId) {
                        //    winRel.options.rel.src.parametros_extra.op_true_RectId = null
                        //    winRel.options.rel.src.parametros_extra.op_true_id_transf_det = null
                        //}

                        //if (winRel.options.rel.src.parametros_extra.op_false_RectId == winRel.options.rel.dest.id || winRel.options.rel.src.parametros_extra.op_false_RectId == winRel.options.rel.dest.parametros_extra.RectId) {
                        //    winRel.options.rel.src.parametros_extra.op_false_RectId = null
                        //    winRel.options.rel.src.parametros_extra.op_false_id_transf_det = null
                        //}

                        elementRelDispose(winRel.options.rel.src)
                       
                    }

                    if (indice_src >= 0)
                        winRel.options.rel.src.relations.splice(indice_src, 1)

                    if (indice_dest >= 0)
                        winRel.options.rel.dest.relations.splice(indice_dest, 1)

                    winRel.options.rel.dispose()
                  
                }

                //else 
                // {
                //      if (winRel.options.rel != undefined)
                //       if (winRel.options.rel.lineColorNew != winRel.options.rel.lineColor && winRel.options.rel.lineColorNew != undefined)
                //        {
                //            var lineColor_ant = winRel.options.rel.lineColor
                //            winRel.options.rel.lineColor = winRel.options.rel.lineColorNew
                //            winRel.options.rel.dest.relations_draw()
                //            for (var i = 0; i < winRel.options.rel.points.length; i++)
                //            {
                //                if (winRel.options.rel.points[i].icon == 'rect')
                //                    winRel.options.rel.points[i].div.setStyle({ backgroundColor: lineColor_ant })
                //            }
                //        }
                //}
                document.activeElement.blur();
            }
            function obtenerIndiceRelationsOrigen_Id(obj_o, id, id_point) {
                var indice = -1;
                obj_o.each(function(arreglo, i) {
                    if (arreglo.dest != null)
                        if (arreglo.dest.id == id)
                            arreglo.points.each(function(arreglo_p, p)
                            {
                                if (arreglo_p.id == id_point)
                                    indice = i
                            });
                });
                return indice;
            }
            
            var winDet
            function abm_transferencia_detalle(detalle) {

                transf_clear_event_copy()

                var j = detalle.getOrder();
                var id = detalle.id;
                var path = "transferencia_detalle.aspx?indice=" + j;
               // var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                winDet = nvFW.createWindow({
                    url: path,
                    title: '<b>Tarea ' + detalle.transf_tipo + '</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    centerHFromElement: $("container"),
                    parentWidthElement: $("container"),
                    parentWidthPercent: 0.9,
                    parentHeightElement: $("container"),
                    parentHeightPercent: 0.9,
                    //parentWidthPercent: 0.9,
                    //parentWidthElement: $("contenedor"),
                    //centerHFromElement: $("contenedor"),
                    //maxWidth: 1000,
                    //setHeightToContent: true,
                    //recenterAuto: true,
                    width: 1000,
                    height: 520,
                    resizable: true,
                    zIndex: zIndex,
                    onClose: abm_transferencia_detalle_return
                });
                
                winDet.minimize = minimizeFix;
                winDet.options.Transferencia = Transferencia;
                winDet.options.detalle = detalle;
                winDet.options.id = id;
                winDet.options.indice = j;
                winDet.showCenter(true);
            }
            function minimizeFix() {
                if (this.resizing)
                  return;

                var r2 = $(this.getId() + "_row2");

                if (!this.minimized) {
                  this.minimized = true;

                  var dh = r2.getDimensions().height;
                  this.r2Height = dh;
                  var h  = this.element.getHeight() - dh;
                  h = h < 0 ? 5 : 0;

                  if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                    new Effect.ResizeWindow(this, null, null, null, this.height -dh, {duration: Window.resizeEffectDuration});
                  } else  {
                    this.height -= dh;
                    this.element.setStyle({height: h + "px"});
                    r2.hide();
                  }

                  if (! this.useTop) {
                    var bottom = parseFloat(this.element.getStyle('bottom'));
                    this.element.setStyle({bottom: (bottom + dh) + 'px'});
                  }
                } 
                else {      
                  this.minimized = false;

                  var dh = this.r2Height;
                  this.r2Height = null;
                  if (this.useLeft && this.useTop && Window.hasEffectLib && Effect.ResizeWindow) {
                    new Effect.ResizeWindow(this, null, null, null, this.height + dh, {duration: Window.resizeEffectDuration});
                  }
                  else {
                    var h  = this.element.getHeight() + dh;
                    this.height += dh;
                    this.element.setStyle({height: h + "px"})
                    r2.show();
                  }
                  if (! this.useTop) {
                    var bottom = parseFloat(this.element.getStyle('bottom'));
                    this.element.setStyle({bottom: (bottom - dh) + 'px'});
                  }
                  this.toFront();
                }
                this._notify("onMinimize");

                // Store new location/size if need be
                this._saveCookie()
            }
            function abm_transferencia_detalle_return() {
                
                if (typeof (winDet.options.Transferencia) == 'object')
                {
                    if (typeof (winDet.options.detalle.parametros_extra.switch) == 'object') {

                       var element = winDet.options.detalle
                       // lo asigno al parametro extra del objeto nuevo SSC
                       if (!element.parametros_extra.RectId)
                           element.parametros_extra.RectId = dest.id

                       var oSwitch = winDet.options.detalle.parametros_extra.switch

                       oSwitch.case.each(function (ocase, index) {

                           element.relations.each(function (relation, index) {
                               if (relation.direction == 'down' && element.id == relation.src.id && relation.dest.transf_tipo == 'SSC') {
                                   var eliminar = ocase.RectId.split("$ELI$")
                                   if (eliminar.length > 0)
                                       if (eliminar[1] == relation.dest.parametros_extra.RectId) {
                                           relation.dest.select(false);
                                           relation.dest.dispose();
                                           Undo.add("Eliminar elemento del 'Switch'");
                                       }
                               }
                           });

                       });

                       oSwitch.case.each(function (ocase, index) {
                           if (ocase.RectId.indexOf("$ELI$") >= 0)
                               ocase.splice(index,1)
                       });

                      oSwitch.case.each(function (ocase,index) {


                         if (ocase.RectId == 0) {

                            var options = element.getOptions();
                            options.id_transf_det = 0;
                            options.transf_tipo = 'SSC';
                            options.height = "15px";

                            var top = 0
                            element.relations.each(function (relation, index) {
                                if (relation.direction == 'down' && element.id == relation.src.id &&  relation.dest.transf_tipo == 'SSC') {
                                    top = relation.dest.top
                                    left = relation.dest.left
                                }

                            });
                            
                            options.left += 80;
                            options.top = (top == 0 ? (options.top + 100) : (top + 40));
                            options.src = element
                            options.title = ocase.descripcion

                            var dest = newElement(options);

                            // lo asigno al case de swicth
                            ocase.RectId = dest.id

                            // lo asigno al parametro extra del objeto nuevo SSC
                            if (!dest.parametros_extra.RectId)
                                dest.parametros_extra.RectId = dest.id

                            options = {}
                            options.direction = 'down';
                            options.reception = 'left';
                            options.evaluacion = ocase.evaluacion;
                            options.lenguaje = 'js';
                            options.id_transf_rel = '0';
                            options.title = '';
                            options.title_position = 'middle';
                            options.default = 'True';

                            //var arrow = newArrow(ObtenerObjnvCtrls(element.id_transf_det), dest, options);
                            var arrow = newArrow(element, dest, options);
                        }
                        else {
                            
                             element.relations.each(function (relation, index) {

                                 if ((ocase.RectId == relation.dest.parametros_extra.RectId) && relation.direction == 'down' && relation.dest.transf_tipo == 'SSC') {
                                     relation.evaluacion = ocase.evaluacion
                                     relation.dest.title = ocase.descripcion
                                     relation.dest.HTMLTitle();
                                 }
                            
                            });
                        }
                    });

                   }

                   Transferencia = winDet.options.Transferencia;
                   var i = winDet.options.indice;
                   var id = winDet.options.id;
                   nvCtrls.items[id].transf_tipo = Transferencia["detalle"][i]["transf_tipo"];
                   nvCtrls.items[id].title = Transferencia["detalle"][i]["transferencia"];
                   Transferencia["detalle"][i].HTMLTitle();
                   if (Transferencia["detalle"][i].transf_tipo == 'XLS') {
                       RefreshWindow_TransferenciaParametros();
                   }

                   Undo.add("Retorno tarea");

                }
                //ojo controlar
                document.activeElement.blur();
            }
            function RefreshWindow_TransferenciaParametros() {
                var _windows = window.top.Windows.windows;
                for (var i=0; i < _windows.length ; i++) { 
                    if(_windows[i].options.title == '<b>Par�metros</b>')
                    _windows[i].refresh();
                }   
            }
            function abm_annotation(annotation) {

                transf_clear_event_copy()

                var path = "/fw/transferencia/transferencia_annotation.aspx";
               // var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                var win = nvFW.createWindow({
                    url: path,
                    title: '<b>Anotaci�n</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 800,
                    height: 300,
                    resizable: true,
                    zIndex: zIndex,
                    destroy: true,
                    onClose: function () { document.activeElement.blur(); Undo.add("Retorno anotaci�n"); }
                });
                win.options.Annotation = annotation;
                win.showCenter();
            }
            function abm_gateway(gateway) {

                transf_clear_event_copy()

                var path = "/fw/transferencia/transferencia_gateway.aspx";
                //var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                var win = nvFW.createWindow({
                    url: path,
                    title: '<b>Compuerta ' + gateway.transf_tipo + '</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    centerHFromElement: $("container"),
                    parentWidthElement: $("container"),
                    parentWidthPercent: 0.6,
                    parentHeightElement: $("container"),
                    parentHeightPercent: 0.6,
                    resizable: true,
                    zIndex: zIndex,
                    onClose: function () { document.activeElement.blur(); Undo.add("Retorno concentrador");}
                });
                win.options.Gateway = gateway;
                win.options.Transferencia = Transferencia;
                win.showCenter(true);
            }
            function abm_event(tEvent) {

                transf_clear_event_copy()

                var path = "/fw/transferencia/transferencia_event.aspx";
             //   var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                var win = nvFW.createWindow({
                    url: path,
                    title: '<b>Evento</b>',
                    minimizable: false,
                    maximizable: true,
                    draggable: true,
                    width: 700,
                    height: 300,
                    resizable: false,
                    zIndex: zIndex,
                    onClose: function () { document.activeElement.blur(); Undo.add("Retorno evento");}
                });
                win.options.tEvent = tEvent;
                win.showCenter(true);
            }
        </script>
        <script type="text/javascript">
            var Validaciones = {
                globales: [],
                elementos: [],
                activities: [],
                gateways: [],
                events: [],
                pools: [],
                lanes: []
            };
            function validate() {
                var errors = [];
                Validaciones.globales.each(function(validation) {
                    var result = validation.func(validation.message);
                    if (result) {
                        errors.push(result);
                    }
                });
                Transferencia.detalle.each(function(element) {
                    switch(element.bpmClass){
                        case 'activity':
                            Validaciones.activities.each(function(validation) {
                                var result = validation.func(validation.message, element);
                                if (result) {
                                    errors.push(result);
                                }
                            });
                            break;                     
                        case 'gateway':
                            Validaciones.gateways.each(function(validation) {
                                var result = validation.func(validation.message, element);
                                if (result) {
                                    errors.push(result);
                                }
                            });
                            break;
                        case 'event':
                            Validaciones.events.each(function(validation) {
                                var result = validation.func(validation.message, element);
                                if (result) {
                                    errors.push(result);
                                }
                            });
                            break;
                    }
                    Validaciones.elementos.each(function(validation) {
                        var result = validation.func(validation.message, element);
                        if (result) {
                            errors.push(result);
                        }
                    });
                });
                Validaciones.pools.each(function(validation) {
                    Transferencia.pools.each(function(pool) {
                        var result = validation.func(validation.message, pool);
                        if (result) {
                            errors.push(result);
                        }
                    });
                });
                Validaciones.lanes.each(function(validation) {
                    Transferencia.pools.each(function(pool) {
                        pool.lanes.each(function(lane) {
                            var result = validation.func(validation.message, lane);
                            if (result) {
                                errors.push(result);
                            }
                        });
                    });
                });
                var ret = {
                    errors: errors,
                    valid: (errors.length == 0)
                };
                return ret;
            }
            /**** GLOBALES ****/
            Validaciones.globales.push({
                func: function(message) {
                    if (Transferencia.pools.length == 0) {
                        return message;
                    }
                    return false;
                },
                message: 'Tiene que existir al menos un Pool'
            });
            Validaciones.globales.push({
                func: function(message) {
                    if (!$('nombre').value) {
                        return message;
                    }
                    return false;
                },
                message: 'Ingrese el nombre de la transferencia'
            });
            Validaciones.globales.push({
                func: function(message) {
                    var result = true;
                    Transferencia.detalle.each(function(detalle){
                        if (detalle.bpmClass == 'activity' || detalle.bpmClass == 'message' || detalle.bpmClass == 'switch'){
                            result = false;
                            throw $break;
                        }
                    });
                    if(result){
                        result = makeErrorMessage(message, '');
                    }
                    return result;
                },
                message: 'La transferencia debe tener al menos una actividad'
            });
            /**** ELEMENTOS ****/
            Validaciones.elementos.push({
                func: function(message, element) {
                    return false;
                },
                message: ''
            });
            /**** ACTIVIDADES ****/
            Validaciones.activities.push({//entradas de la actividad
                func: function(message, activity) {
                    var result = true;
                    Transferencia.relations.each(function(relation){
                        if(relation.dest == activity){
                            result = false;
                            throw $break;
                        }
                    });
                    if(result){
                        var type = activity.transf_tipo == undefined ? '' : '[' + activity.transf_tipo + '] : ';
                        result = makeErrorMessage(message, [activity.title, type]);
                    }
                    return result;
                },
                message: 'La actividad {$1}"{$0}" no tiene flujos de entrada"'
            });
            Validaciones.activities.push({//entradas de la actividad
                func: function(message, activity) {
                    var result = true;
                    Transferencia.relations.each(function(relation){
                        if(relation.src == activity){
                            result = false;
                            throw $break;
                        }
                    });
                    if(result){
                        var type = activity.transf_tipo == undefined ? '' : '[' + activity.transf_tipo + '] : ';
                        result = makeErrorMessage(message, [activity.title, type]);
                    }
                    return result;
                },
                message: 'La actividad {$1}"{$0}" no tiene flujos de salida"'
            });
            /**** GATEWAYS ****/
            Validaciones.gateways.push({//flujos de salida de gateways
                func: function(message, gateway) {
                    var result = true;
                    gateway.relations.each(function(relation){
                        if(relation.src == gateway){
                            result = false;
                            throw $break;
                        }
                    });
                    if(result){
                        result = makeErrorMessage(message, gateway.title);
                    }
                    return result;
                },
                message: 'La compuerta "{$0}" debe tener al menos un flujo de salida'
            });
            Validaciones.gateways.push({//flujos de entrada de gateways
                func: function(message, gateway) {
                    var result = true;
                    Transferencia.relations.each(function(relation){
                        if(relation.dest == gateway){
                            result = false;
                            throw $break;
                        }
                    });
                    if(result){
                        result = makeErrorMessage(message, gateway.title);
                    }
                    return result;
                },
                message: 'La compuerta "{$0}" debe tener al menos un flujo de entrada'
            });
            /**** EVENTOS ****/
            Validaciones.events.push({//flujos de salida de eventos ini
                func: function(message, event) {
                    var result = false;
                    if(event.transf_tipo == 'INI'){
                        result = true;
                        event.relations.each(function(relation){
                            if(relation.src == event){
                                result = false;
                                throw $break;
                            }
                        });
                        if(result){
                            result = makeErrorMessage(message, event.title);
                        }
                    }
                    return result;
                },
                message: 'El evento de inicio "{$0}" debe tener al menos un flujo de salida'
            });
            Validaciones.events.push({//flujos de entrada de eventos ini
                func: function(message, event) {
                    var result = false;
                    if(event.transf_tipo == 'INI' || event.transf_tipo == 'IUS' || event.transf_tipo == 'TII'){
                        Transferencia.relations.each(function(relation){
                            if(relation.dest == event){
                                result = true;
                                throw $break;
                            }
                        });
                        if(result){
                            result = makeErrorMessage(message, event.title);
                        }
                    }
                    return result;
                },
                message: 'El evento "{$0}" no puede tener flujos de entrada'
            });

            Validaciones.events.push({//flujos de salida de eventos fin
                func: function(message, event) {
                    var result = false;
                   if (event.transf_tipo == 'END' || event.transf_tipo == 'ENE') {
                        event.relations.each(function(relation){
                            if(relation.src == event && relation.dest.transf_tipo != 'annotation'){
                                result = true;
                                throw $break;
                            }
                        });
                        if(result){
                            result = makeErrorMessage(message, event.title);
                        }
                    }
                    return result;
                },
                message: 'El evento de fin "{$0}" no puede tener flujos de salida'
            });

            Validaciones.events.push({//flujos de entrada de eventos fin
                func: function(message, event) {
                    var result = false;
                    if (event.transf_tipo == 'END') {
                        result = true;
                        Transferencia.relations.each(function(relation){
                            if(relation.dest == event){
                                result = false;
                                throw $break;
                            }
                        });
                        if(result){
                            result = makeErrorMessage(message, event.title);
                        }
                    }
                    return result;
                },
                message: 'El evento de fin "{$0}" debe tener al menos un flujo de entrada'
            });

            Validaciones.events.push({//flujos de entrada de eventos fin error
                func: function(message, event) {
                    var result = false;
                    if (event.transf_tipo == 'ENE') {
                        result = true;
                        Transferencia.relations.each(function(relation) {
                            if (relation.dest == event) {
                                result = false;
                                throw $break;
                            }
                        });
                        if (result) {
                            result = makeErrorMessage(message, event.title);
                        }
                    }
                    return result;
                },
                message: 'El evento de fin por error "{$0}" debe tener al menos un flujo de entrada'
            });

            /**** POOLES ****/
            Validaciones.pools.push({
                func: function(message, pool) {
                    return false;
                },
                message: ''
            });
            /**** LANES ****/
            Validaciones.lanes.push({
                func: function(message, lane) {
                    return false;
                },
                message: ''
            });
            /*************/
            function makeErrorMessage(message, data){
                if(typeof data == 'string'){
                    data = [data];
                }
                var i = 0;
                data.each(function(data){
                    message = message.split('{$' + (i++) + '}').join(data);
                });
                return message;
            }
            function makeOptionsFromXML(xmlElement) {
                var options = {};
                var nodes = [

                    'TSQL',
                    'target',
                    'metodo',
                    'xsl_name',
                    'path_xsl',
                    'xml_xsl',
                    'xml_data',
                    'dtsx_path',
                    'filtroXML',
                    'parametros',
                    'filtroWhere',
                    'report_name',
                    'contenttype',
                    'salida_tipo',
                    'path_reporte',
                    'id_exp_origen',
                    'vistaguardada',
                    'parametros_det',
                    'dtsx_parametros',
                    'mantener_origen',
                    'parametros_extra_xml',
                    'parametros_det',
                    'text',
                    'title',
                    'lenguaje',
                    'cod_cn',
                    'transferencia',
                    'left',
                    'top'

                ];
                for (var i = 0; i < nodes.length; i++) {
                    singleNode(options, xmlElement, nodes[i]);
                }
                for (var att_index in xmlElement.attributes) {
                    var attribute = xmlElement.attributes[att_index];
                    if (attribute.ownerElement != undefined) {
                        options[attribute.name] = attribute.value;
                    }
                }
                return options;
            }
            function singleNode(options, xmlElement, nodeName) {
                var node = xmlElement.querySelector(nodeName); //xmlElement.select(nodeName);
                if (node)
                    if (node.childNodes)
                      if (node.childNodes.length > 0)
                        { //if(node.length) 
                          node = node.childNodes[0]; //node[0];

                          if (nodeName == "parametros_extra_xml")
                             options[nodeName] = XMLtoString(node)
                          else
                             options[nodeName] = XMLText(node); //node.innerHTML;
                       } 
            }
            function cargarFromXML(xmlStr) {
                //xmlStr = xmlStr.replace(/<\!\[CDATA\[/ig, '').replace(/\]\]>/ig, '').replace("<?xml version='1.0' encoding='iso-8859-1'?>", '');
                
                var objXML = new tXML()
                objXML.loadXML(xmlStr)

                //if (!objXML.xml)
                //{
                // debugger
                // return
                //}

                resetLayout();

                //var xml = $($(document).createElement('div'));
                //xml.update(xmlStr);

                var transferencia = objXML.selectNodes("transferencia")[0] 
                var options = makeOptionsFromXML(transferencia);
                newTransfer(options);

                var NodeParametros = objXML.selectNodes("transferencia/parametros/parametro")
                for (var i = 0; i < NodeParametros.length; i++) {
                    var options = makeOptionsFromXML(NodeParametros[i]);
                    Transferencia.parametros.push(options);
                }

                var NodePools = objXML.selectNodes("transferencia/pools/pool")
                for (var p = 0; p < NodePools.length; p++) {

                    var options = makeOptionsFromXML(NodePools[p]);
                    var c_pool = newPool(options, false);
                    
                    var NodeLanes = selectNodes("lanes/lane", NodePools[p])
                    for (var l = 0; l < NodeLanes.length; l++) {
                        var options = makeOptionsFromXML(NodeLanes[l]);
                        newLane(options, c_pool);
                    }
                }

                var detalles = [];
                var NodeDetalles = objXML.selectNodes("transferencia/detalles/detalle")
                for (var i = 0; i < NodeDetalles.length; i++) {
                    
                    var options = makeOptionsFromXML(NodeDetalles[i]);
                  //  options.title = options.title;
                    options.title = options.transferencia != "" ? options.transferencia : options.title
                    cargar_parametros_det_from_xml(options, NodeDetalles[i]);
                    var element = newElement(options);

                    detalles.push({
                        element: element,
                        _relations: selectNodes("relations/relation", NodeDetalles[i]) 
                    });
                }

                detalles.each(function (detalle) {
                    var NodeRelations = detalle._relations 
                    for (var r = 0; r < NodeRelations.length; r++) {
                        var options = makeOptionsFromXML(NodeRelations[r]);
                        options.evaluacion = XMLText(NodeRelations[r].querySelector('evaluacion')).replace('<!--[CDATA[', '').replace('&lt;![CDATA[', '').replace(']]-->', '').replace(']]&gt;', '');
                        options.title = XMLText(NodeRelations[r].querySelector('title')).replace('<!--[CDATA[', '').replace('&lt;![CDATA[', '').replace(']]-->', '').replace(']]&gt;', '');
                        var src = detalle.element;
                        var dest = Transferencia.detalle[options.dest_temp_id];
                        newArrow(src, dest, options);
                    }

                });

                var NodeAnnotations = objXML.selectNodes("transferencia/annotations/annotation")
                for (var i = 0; i < NodeAnnotations.length; i++) {

                    var options = makeOptionsFromXML(NodeAnnotations[i]);
                    var c_annotation = newAnnotation(options, false);

                    var NodeRelations = selectNodes("relations/relation", NodeAnnotations[i]) //NodeAnnotations[i].querySelectorall("relations relation").childNodes
                    for (var r = 0; r < NodeRelations.length; r++) {
                        var options = makeOptionsFromXML(NodeRelations[r]);
                        options.title = XMLText(NodeRelations[r].querySelector('title')).replace('<!--[CDATA[', '').replace('&lt;![CDATA[', '').replace(']]-->', '').replace(']]&gt;', '');
                        var src = ObtenerObjnvCtrls(options.id_transf_det);
                        newArrow(src, c_annotation, options);
                    }
                
                }

           
            }

            function cargar_parametros_det_from_xml(options, xmlElement) {
                if(options.transf_tipo !== undefined) {
                    if (['XLS','EQV','NOS','TRA'].indexOf(options.transf_tipo) != -1) {
                        options.parametros_det = [];
                    } else {
                        options.parametros_det = {};
                    }
                    if (['XLS', 'EQV', 'USR', 'IUS', 'NOS','TRA'].indexOf(options.transf_tipo) != -1) {
                        
                        var objXML = new tXML()
                        objXML.loadXML(xmlElement.outerHTML)

                        var NodeParametros_det = objXML.selectNodes("parametros_det/parametros_det") 
                        for (var r = 0; r < NodeParametros_det.length; r++) {
                            var obj = {};
                            var obj = makeOptionsFromXML(NodeParametros_det[r]);

                            if (['XLS', 'EQV', 'NOS', 'TRA'].indexOf(options.transf_tipo) != -1) {
                                options.parametros_det.push(obj);
                            } else {
                                var parameter = getParameter(obj.parametro);
                                options.parametros_det[parameter.parametro] = {};
                                options.parametros_det[parameter.parametro].parameter = parameter;
                                options.parametros_det[parameter.parametro].tipo = obj.tipo;
                                options.parametros_det[parameter.parametro].label = obj.label;
                                options.parametros_det[parameter.parametro].descargable = obj.descargable;
                                options.parametros_det[parameter.parametro].valor_defecto_editable = obj.valor_defecto_editable;
                                options.parametros_det[parameter.parametro].orden = obj.orden;
                            }

                        }

                    }
                }
            }
            function transferencia_ejecutar(e) {

                if ("<%= id_transferencia %>" != "") {
                   if (!nvFW.tienePermiso(nvFW.pageContents.permiso_grupo, nvFW.pageContents.nro_permiso_ejecutar)) {
                        alert("No tiene permisos para ejecutar esta transferencia.")
                        return;
                    }
                }
            
                if (Transferencia["id_transferencia"] > 0) 
                 {
                    var strXML_parm = '<parametros></parametros>'

                    if (e.ctrlKey == true) //con la tecla "Ctrl", abre una nueva pesta�a
                     {
                        window.top.nvFW.transferenciaEjecutar({ id_transferencia: Transferencia["id_transferencia"],
                            xml_param: strXML_parm,
                            pasada: 0,
                            formTarget: '_blank',
                            ej_mostrar: true
                        });
                      }  
                    else 
                      {//sino, abre una ventana emergente
                           window.parent.nvFW.transferenciaEjecutar({ id_transferencia: Transferencia["id_transferencia"],
                                                                      xml_param: strXML_parm,
                                                                      formTarget: 'winPrototype',
                                                                      pasada: 0,
                                                                      ej_mostrar: true,
                                                                      winPrototype: 
                                                                          { modal: false,
                                                                            center: true,
                                                                            bloquear: false,
                                                                            title: '<b>' + Transferencia["nombre"] + '</b>',
                                                                            url: 'enBlanco.htm',
                                                                            minimizable: false,
                                                                            maximizable: true,
                                                                            draggable: true,
                                                                            width: 1200,
                                                                            height: 500,
                                                                            resizable: true,
                                                                            destroyOnClose: true
                                                                           }
                                                                        })
                      }  
                 }
            }
            
            function transferencia_imprimir(tipo_salida) {

                if ("<%= id_transferencia %>" != "") {
                   if (!nvFW.tienePermiso(nvFW.pageContents.permiso_grupo, nvFW.pageContents.nro_permiso_imprimir)) {
                        alert("No tiene permisos para imprimir esta transferencia.")
                        return;
                    }
                }
                
                var id_transferencia = parseInt('<%= id_transferencia %>');
                var path = '/FW/Transferencia/Transferencia_pre_export_pdf.aspx?id_transferencia=' + id_transferencia + '&tipo_salida=' + tipo_salida;
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
                var zIndex = 20000;
                var win = nvFW.createWindow({
                    url: path,
                    title: '<b>Exportar</b>',
                    minimizable: false,
                    maximizable: false,
                    draggable: true,
                    width: 450,
                    height: 280,
                    resizable: false,
                    zIndex: zIndex,
                    destroy: true,
                    onClose: function () { document.activeElement.blur() }
                });
                win.showCenter(true);

            }

            var tPermisoDeEdicion = {};
            function tienePermisoDeEdicion(det) {
                
                if(!tPermisoDeEdicion.PermisosDetEdicion){
                    tPermisoDeEdicion.PermisosDetEdicion = {};
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_ver_Transferencia_det_permisos,"","","")
                    var name = '';
                    while(!rs.eof()) {
                        tPermisoDeEdicion.PermisosDetEdicion[rs.getdata('transf_tipo').toUpperCase().replace(/[ ]+/g, '')] = rs.getdata('permiso') != "False";
                        rs.movenext();
                    }
                }
                var result = tPermisoDeEdicion.PermisosDetEdicion[det.transf_tipo] !== undefined && tPermisoDeEdicion.PermisosDetEdicion[det.transf_tipo];
               /* if(!result) {
                    alert('No posee permisos de edici�n');
                }*/
                return result;
            }
            function getFiles(detTypes) {
                if(detTypes == undefined) {
                    detTypes = ['INF', 'DTS', 'EXP'];
                }
                var files = [];
                Transferencia.detalle.each(function(det){
                    if (detTypes.indexOf(det.transf_tipo) != -1) {
                        var targets = det.target.substr(1, det.target.length - 3)
                        if(targets.length) {
                            targets = targets.split(';');
                            targets.each(function(target){
                                var type = target.split(':')
                                //si es comprimido, cargarlo como tal
                                
                                var arTarget = target_parse(target.replace(/\\/ig, ""))
                                if (arTarget[0])
                                 if (arTarget[0].target_comp != "")
                                    target = arTarget[0].target_comp
                                 else
                                    target = arTarget[0].target

                                if(type.length) {
                                    type = type[0];
                                    if(type == 'FILE') {
                                        files.push(target);
                                    }
                                }
                            });
                        }
                    }
                });
                return files;
            }
            function fixDetFiles(detTypes) {
                if(detTypes == undefined) {
                    detTypes = ['MSG'];
                }
                var files = getFiles();
                Transferencia.detalle.each(function(det){
                    if(detTypes.indexOf(det.transf_tipo) != -1){
//                        console.log(det);
                    }
                });
            }

            function clearSelection() {
                var selection = null;
                if (window.getSelection) {
                    selection = window.getSelection();
                } else if (document.selection) {
                    selection = document.selection;
                }
                if (selection) {
                    if (selection.empty) {
                        selection.empty();
                    }
                    if (selection.removeAllRanges) {
                        selection.removeAllRanges();
                    }
                }
            }
       
            var WinAbrir
            var arrXML
            function abrir_versiones()
            {

                if (id_transferencia_txt.value == -1)
                    return


                nvFW.bloqueo_activar($$('BODY')[0],1234,'Cargando Versiones')


                $('divPlantillaVersiones').innerHTML = ""

                var strHTML = "<div id='divPlantillaVersiones_det' style='width:100%;overflow:auto'>"
                strHTML += "<table class='tb1 highlightOdd highlightTROver' style='width:100%'>"
                var rs = new tRS();
                rs.async = true
                rs.open(nvFW.pageContents.filtroXML_transferencias_version, "", "<id_transferencia type='igual'>" + id_transferencia_txt.value + "</id_transferencia>", "")
                rs.onComplete = function () {

                    while (!rs.eof()) {

                        if (!rs.getdata("descripcion")) {
                            rs.movenext();
                            continue
                        }

                        var nombre_operador = ""
                        var objXML = new tXML()
                        objXML.loadXML(rs.getdata("valor"))
                        if (objXML.xml)
                            nombre_operador = selectSingleNode("transferencia/@nombre_operador", objXML.xml).value

                        var descr = !rs.getdata("descripcion") ? "" : rs.getdata("descripcion") + " - Operador: " + nombre_operador
                        var classVigente = rs.getdata("vigente") == "True" ? " class='tbLabel0' " : ""

                        strHTML += "<tr " + classVigente + ">"
                        strHTML += "<td style='width:5%; text-align:center; vertical-align:middle'>"
                        strHTML += "<img src='/fw/image/transferencia/seleccionar.png' onclick='return window_transferencia_abm(event," + id_transferencia_txt.value + "," + rs.getdata("id_transf_version") + ")' style='cursor:hand;cursor:pointer' border='0' align='absmiddle' hspace='1'/>"
                        strHTML += "</td>"
                        strHTML += "<td style='text-align:left; vertical-align:middle'>" + descr + "</td>"
                        strHTML += "</tr>"

                        rs.movenext();
                    }

                strHTML += "</table><br>"
                strHTML += "</divPlantillaVersiones_det>"

                $('divPlantillaVersiones').insert({ top: strHTML })

                winPlantilla = nvFW.createWindow({
                    width: 550, height: 160, zIndex: 100,
                    draggable: true,
                    resizable: true,
                    closable: true,
                    minimizable: false,
                    maximizable: false,
                    title: "<b>Versiones (" + id_transferencia_txt.value + ") " + nombre.value + "</b>",
                    onShow: function (win) {
                        version_windows_resize()
                    },
                    onResize: function(win) {

                        version_windows_resize()
                    }
                })

                winPlantilla.getContent().innerHTML = $('divVersiones').innerHTML 
                winPlantilla.showCenter(true);

                nvFW.bloqueo_desactivar($$('BODY')[0], 1234)

                }

            }

            var winVersion
            function window_transferencia_abm(e,id_transferencia,id_transf_version)
            {
                if (e.ctrlKey == true || e.shiftKey == true)
                    window.open('/fw/transferencia/transferencia_abm.aspx?id_transferencia=' + id_transferencia + '&id_transf_version=' + id_transf_version, "_blank")
                else {

                    winVersion = window.top.nvFW.createWindow({
                        url: '/fw/transferencia/transferencia_abm.aspx?id_transferencia=' + id_transferencia + '&id_transf_version=' + id_transf_version,
                        title: '<b>Editor versi�n (' + id_transf_version + ')</b>',
                        minimizable: true,
                        maximizable: true,
                        draggable: true,
                        width: 900,
                        height: 500
                        //destroyOnClose: true,
                    });

                    winVersion.showCenter()
                }
            }


            function btn_limpiarUndo()
            {

                confirm("�Desea limpiar la papelera?", {
                    width: 400,
                    height: "auto",
                    className: "alphacube",
                    okLabel: "Si",
                    cancelLabel: "No",
                    onOk: function (w) {
                        limpiarUndo()
                        w.close(); return
                    },
                    onCancel: function (w) {
                        w.close(); return
                    }
                });
                

            }

            function version_windows_resize() {
               
                try {
                    
                    var ventana_h = winPlantilla.getSize().height
                    var cabe_h = $('tbCabeVersion').getHeight()
                    $('divPlantillaVersiones_det').setStyle({height : (ventana_h - cabe_h) + 'px'})
                }

                catch (e) { }

            }

            function click_nombre() {
                  
                   Dialog.confirm("<input type='text' style='width:100%' id='input_desc' value='"+ $('nombre').value +"'/> ",{    width:450, 
                                                                                    className: "alphacube",
                                                                                    title:"<b>Ingrese la descripci�n</b>",
                                                                                      okLabel: "Aceptar", 
                                                                                       cancelLabel: "Cancelar",  
                                                                                       top: 10,
                                                                                       onShow: function (w) { transf_clear_event_copy();$('input_desc').focus() },
                                                                                       cancel: function(w){ w.close(); return}, 
                                                                                           ok: function(w){ 
                                                                                                            $('nombre').value = $('input_desc').value 
                                                                                                            w.close() 
                                                                                                          } 
                                                                                 });   
            }

            function referencia() {

                var str = '<b>Fecha Creaci�n:</b>' + Transferencia.transf_fe_creacion
                str += '</br><b>Fecha Modificaci�n:</b>' + Transferencia.transf_fe_modificado 
                str += '</br><b>Operador:</b>' + Transferencia.nombre_operador
                alert(str)

            }
        </script>
    </head>
    <body onload="windows_onload()" onresize="return window_onresize()" >
        <input type="hidden" name="id_transferencia_txt" id="id_transferencia_txt" value="<% = id_transferencia %>"/>
        <table class="tb1 layout_fixed">
            <tr class="tbLabel">
                <td id="descripcion" style="text-align:left;padding-left:10px;white-space:nowrap "></td>
                <td style="width:20%;">Descripci�n</td>
                <td style="width:5%;">Habilitado</td>
                <td style="width:6%;">Runtime</td>
                <td style="width:10%;white-space:nowrap" title="Guardado en log">Guard.Log</td>
                <td style="width:5%;white-space:nowrap" title="Timeout">T.Out (seg.)</td>
                <td style="width:20%;">Estado</td>
            </tr>
            <tr>    
                <td id="topMenu"></td>
                <td style="width:20%;">
                    <input type="text" name="nombre" id="nombre" style="width:100%" onclick="click_nombre(event)" readonly="readonly" />
                </td>
                <td style="width:5%;text-align: center;">
                    <input type="checkbox" name="habi" id="habi" style="border:0px"/>
                </td>
                <td style="width:6%;">
                     <select name="transf_version" id="transf_version" style="width:100%"><option value="1.0">1.0</option><option value="2.0" selected="selected">2.0</option></select>
                </td>
                <td style="width:10%;">
                     <select name="log_param_save" id="log_param_save" style="width:100%"><option value="1" selected="selected">Completo</option><option value="2">Resumido</option></select>
                </td>
                <td style="width:5%;">
                    <input type="text" title="Tiempo de Ejecuci�n de la transferencia. El valor cero (0) es indefinido." name="timeout" id="timeout" style="width:100%; text-align:right;" onkeypress="return valDigito(event);" />
                </td>
                <td style="width:20%">
                    <%= nvCampo_def.get_html_input("id_transf_estado")%>
                </td>
            </tr>
        </table>
        <div style="display: none;"><%= nvCampo_def.get_html_input("id_transferencia")%></div>
        <div id="divUndo"></div>
       <%-- <div id="divUndo" style="overflow:auto;display:none" onmousemove="return clearSelection()" >
            <table class="tb1">
                <tr>
                    <td style="width:5%" class="Tit1">Deshacer</td>
                    <td style="width:5%"><img src="/fw/image/transferencia/undo.png" onclick="Undo.undo()" style="cursor:pointer"/></td>
                    <td style="width:30%"><select id="sel_undo" style="width:100%" onchange="onclickSelUndo()"></select></td>
                    <td style="width:5%" class="Tit1">Rehacer</td>
                    <td style="width:5%"><img src="/fw/image/transferencia/redo.png" onclick="onclickSelRedo()" style="cursor:pointer" /></td>
                    <td><select id="sel_redo" style="width:100%" onchange="Undo.redo()" ></select></td>
                    <td style="width:5%"><input type="button" value="Limpiar" style="width:100%;cursor:pointer" onclick="btn_limpiarUndo()"/></td>
                </tr>
            </table>
        </div>--%>
        <div id="divTablero"  style="overflow:auto" onmousemove="return clearSelection()">
            <div class="tablero" id="divPool" title="Pool" ></div>
            <div class="tablero" id="divLane" title="Lane" ></div>
            <div class="separator"><hr></div>
            <div class="tablero" id="divSP" title="SP" ></div>
            <div class="tablero" id="divEXP" title="EXP" ></div>
            <div class="tablero" id="divINF" title="INF" ></div>
            <div class="tablero" id="divDTS" title="DTS" ></div>
            <div class="tablero" id="divSCR" title="SCR" ></div>
            <div class="tablero" id="divXLS" title="XLS" ></div>
            <div class="tablero" id="divSSR" title="SSR" ></div>
            <div class="tablero" id="divEQV" title="EQV" ></div>
            <div class="tablero" id="divNOS" title="NOS" ></div>
            <div class="tablero" id="divSSS" title="SSS" ></div>
            <div class="tablero" id="divTRA" title="TRA" ></div>
            <div class="tablero" id="divSEG" title="SEG" ></div>
            <div class="tablero" id="divUSR" title="USR" ></div>
            <div class="separator"><hr></div>
            <div class="tablero" id="divGateAND" title="AND" ></div>
            <div class="tablero" id="divGateOR" title="OR" ></div>
            <div class="tablero" id="divGateXOR" title="XOR" ></div>
            <div class="tablero" id="divGateIF" title="IF" ></div>
            <div class="separator"><hr></div>
            <div class="tablero" id="divEventINI" title="Inicio" ></div>
            <div class="tablero" id="divEventIUS" title="Evento" ></div>
            <div class="tablero" id="divEventEND" title="Fin" ></div>
            <div class="tablero" id="divEventENE" title="Fin Error" ></div>
            <div class="tablero" id="divEventEVENT" title="Evento" ></div>
            <div class="separator"><hr></div>
            <div class="tablero" id="divTMR" title="Timer" ></div>
            <div class="tablero" id="divTII" title="Timer" ></div>
            <div class="tablero" id="divMSG" title="Mensaje" ></div>
            <div class="separator" ><hr></div>
            <div class="tablero" id="divAnnotation" title="Nota" ></div>
        </div>
        <div id="container"></div>
        <div id="divActivitiesNueva" style="width: 100%;display: none;">
            <table class="tb1" style="height:100%;background-color:#FFFBFF !Important">
                <tr>
                    <td style="width:100%">�Desea Guardar los cambios efectuados en la transferencia?</td>
                </tr>
                <tr>
                    <td style="width:100%; text-align:center; vertical-align:middle" colspan="2">
                        <table style="width:100%">
                            <tr>
                                <td style="width: 33%; text-align: center">
                                    <div id="divbtnSI" style="width:100%"></div>
                                </td>
                                <td style="width: 33%; text-align: center">
                                    <div id="divbtnNO" style="width:100%"></div>
                                </td>
                                <td style="text-align: center">
                                    <div id="divbtnCancelar" style="width:100%"></div>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
         <div id="divVersiones" style="width: 100%;display: none;overflow:auto">
            <table style="width:100%;" id="tbCabeVersion">
                <tr>
                    <td style="width:100%">
                         <table class="tb1" style="width:100%">
                            <tr class="tbLabel">
                                <td style="width: 5%; text-align: center">-</td>
                                <td style="text-align: center">Descripci�n</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
            <div id="divPlantillaVersiones" style="width:100%;overflow:hidden" />
        </div>
    </body>
</html>
