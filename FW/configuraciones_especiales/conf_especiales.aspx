<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    Dim modo = nvFW.nvUtiles.obtenerValor("modo", "").ToUpper()         ' G:guardar
    Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
    Dim permiso_grupo As String = ""
    Dim permiso_editar As Integer = 0
  
    'Guardar la configuracion
    If modo = "G" Then
        Dim er As New tError
        Try
            If (strXML <> "") Then
                Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("configuracion_especiales_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
                cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, , , strXML)
                Dim rs As ADODB.Recordset = cmd.Execute()
                er = New nvFW.tError(rs)
                er.params("resultado") = rs.Fields("resultado").Value
                er.params("id_conf") = rs.Fields("id_conf").Value
            End If
        Catch e As Exception
            er.parse_error_script(e)
        End Try
        er.response()
    End If

    Me.contents("filtro_confEspeciales") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='conf_especiales'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtro_pizarras") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='conf_especiales_pizarra'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtro_transferencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='conf_especiales_transferencia'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtro_campoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='conf_especiales_campodef'><campos>*</campos><orden></orden></select></criterio>")
    Me.contents("filtro_parametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='conf_especiales_parametro'><campos>*</campos><orden></orden></select></criterio>")
    
    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    'Cargar permiso grupo de la conf seleccionada
    If id_conf <> 0 Then
        Dim strSQL As String = "select * from verConf_especiales where id_cfg_especial = " + id_conf
        Dim res As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
        If Not res.EOF Then
            permiso_grupo = res.Fields("permiso_grupo").Value
            permiso_editar = res.Fields("permiso_editar").Value
            Me.addPermisoGrupo(permiso_grupo)
        End If
        nvDBUtiles.DBCloseRecordset(res)
    End If
    

    
    
    %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Configuraciones Especiales</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />     
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    
    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var id_conf = '<%= id_conf %>'
        var permiso_grupo = '<%= permiso_grupo %>'
        var permiso_editar = '<%=permiso_editar %>'
        var mywin = nvFW.getMyWindow()
        var winP, winTrans, winParam, winCampo
        var vista_arbol = false
        
        function window_onload(){
            cargarDatos()
            if (!permisosEditar()){
                campo_def_habilitar("nombre", false)
                campo_def_habilitar("comentario", false)
            }
            
            window_onresize()
            mostrarPizarras()
            mostrarTransferencias()
            mostrarParametros()
            mostrarCampodef()
           
        }

        function cargarDatos(){        
            var filtroXML = nvFW.pageContents.filtro_confEspeciales
            var filtroWhere = "<id_cfg_especial type='igual'>"+id_conf+"</id_cfg_especial>"
            var rs = new tRS()
            rs.open(filtroXML, '', filtroWhere)
            if (!rs.eof()){
                campos_defs.set_value("nombre",rs.getdata("nombre_conf"))
                campos_defs.set_value("comentario", rs.getdata("comentario_conf"))
            }
        }

        function permisosEditar(){   
            if (id_conf == 0){       //permisos para crear una NUEVA configuracion
                if (nvFW.tienePermiso("permisos_conf_especiales_gral", 2))
                    return true
                else
                    return false
            }
            else{  //permisos particular de la conf para poder editarla
                if (nvFW.tienePermiso(permiso_grupo, permiso_editar)) 
                    return true
                else   
                    return false
           }
        }
        
        function mostrarPizarras() {
            winP = nvFW.createWindow({
                title: "<b>Pizarras asociadas</b>",
                width: anchuraIframe,
                height: alturaIframe,
                top: '80px',
                left: '10px',
                minimizable: false,
                maximizable: false,
                closable: false,
                draggable: false,
                resizable: false,
                id: 'pizarras_sub_window',
                destroyOnClose: true,
                onShow: function() { },
                onClose: function(win) { winP = false; }
            });

            winP.show();
            winP.setHTMLContent('<iframe src="conf_especiales_pizarra.aspx?id_conf=' + id_conf + '" id="pizarras_sub_window_iframe" name="pizarras_sub_window_iframe" width="' + anchuraIframe + 'px" height="' + alturaIframe + 'px" style="border: 1px solid #666666; "></iframe>');
        }

        function mostrarTransferencias(){
             winTrans = nvFW.createWindow({
                    title: "<b>Transferencias asociadas</b>",
                    width: anchuraIframe,
                    height: alturaIframe,
                    top: '80%',
                    right: '10%',
                    minimizable: false,
                    maximizable: false,
                    closable: false,
                    draggable: false,
                    resizable: false,
                    setWidthMaxWindow: true,
                    id: 'transferencia_sub_window',
                    destroyOnClose: true,
                    onShow: function() { },
                    onClose: function(win) { winTrans = false; }
                });

                winTrans.show();
                winTrans.setHTMLContent('<iframe src="conf_especiales_transf.aspx?id_conf=' + id_conf + '" id="transferencia_sub_window_iframe" name="transferencia_sub_window_iframe" width="' + anchuraIframe + 'px" height="' + alturaIframe + 'px" style="border: 1px solid #666666; "></iframe>');
            }

        function mostrarParametros(){
                winParam = nvFW.createWindow({
                    title: "<b>Parametros asociados</b>",
                    width: anchuraIframe,
                    height: alturaIframe,
                    bottom: '5px',
                    left: '10%',
                    position: 'absolute',
                    minimizable: false,
                    maximizable: false,
                    closable: false,
                    draggable: false,
                    resizable: false,
                    setWidthMaxWindow: true,
                    id: 'parametro_sub_window',
                    destroyOnClose: true,
                    onShow: function() { },
                    onClose: function(win) { winParam = false; }
                });

                winParam.show();
                winParam.setHTMLContent('<iframe src="conf_especiales_param.aspx?id_conf=' + id_conf + '" id="parametro_sub_window_iframe" name="parametro_sub_window_iframe" width="' + anchuraIframe + 'px" height="' + alturaIframe + 'px" style="border: 1px solid #666666; "></iframe>');
            }

        function mostrarCampodef(){
            winCampo = nvFW.createWindow({
                title: "<b>Campos Def asociados</b>",
                width: anchuraIframe,
                height: alturaIframe,
                bottom: '5px',
                right: '10%',
                position: 'absolute',
                minimizable: false,
                maximizable: false,
                closable: false,
                draggable: false,
                resizable: true,
                setWidthMaxWindow: true,
                id: 'campodef_sub_window',
                destroyOnClose: true,
                onShow: function() { },
                onClose: function(win) { winCampo = false; }
            });

            winCampo.show();
            winCampo.setHTMLContent('<iframe src="conf_especiales_campodef.aspx?id_conf=' + id_conf + '" id="campodef_sub_window_iframe" name="campodef_sub_window_iframe" width="' + anchuraIframe + 'px" height="' + alturaIframe + 'px" style="border: 1px solid #666666; "></iframe>');
        }

        function guardar() {         
            if (!permisosEditar()){
                alert('No tiene permisos para guardar esta configuración.')
               return
           }
           
           if(campos_defs.get_value("nombre") == ''){
               alert("Debe completar el nombre de la configuración")
                return
            }
             
           var tablaPizarra = ObtenerVentana("pizarras_sub_window_iframe").tablaPizarra
           var tablaTransferencia = ObtenerVentana("transferencia_sub_window_iframe").tablaTransferencia
           var tablaParametro = ObtenerVentana("parametro_sub_window_iframe").tablaParametro
           var tablaCampos = ObtenerVentana("campodef_sub_window_iframe").tablaCampos

           if (!tablaPizarra.validar()){
               nvFW.alert("No puede haber filas vacias en la tabla de pizarras")
                return
            }
            if (!tablaCampos.validar()){
                nvFW.alert("No puede haber filas vacias en la tabla de campos def")
                return
            }
            if (!tablaTransferencia.validar()){
                nvFW.alert("No puede haber filas vacias en la tabla de transferencias")
                return
            }
            if (!tablaParametro.validar()){
                nvFW.alert("No puede haber filas vacias en la tabla de parametros")
                return
            }
                
            var pizarraXML = tablaPizarra.generarXML("pizarras")
            var transferenciaXML = tablaTransferencia.generarXML("transferencias")
            var parametroXML = tablaParametro.generarXML("parametros")
            var campodefXML = tablaCampos.generarXML("camposdef")

            var modo
            if (id_conf == 0) modo = 'N' //nuevo
            else modo = 'E' //edicion 
            var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xmldato += "<configuraciones modo='"+modo+"' id='" + id_conf + "' nombre='" + campos_defs.get_value("nombre") + "' comentario='" + campos_defs.get_value("comentario") + "'>"

            if (pizarraXML != ""){
                xmldato += pizarraXML
               }
            else{ xmldato += "<pizarras />" }
            
            if (transferenciaXML != "") {
                xmldato += transferenciaXML
            }
            else{
                xmldato += "<transferencias />"
            }
            if (parametroXML != ""){
                xmldato += parametroXML
            }
            else{
                xmldato += "<parametros />"
            }
            if (campodefXML != ""){
                xmldato += campodefXML
            }
            else{
                xmldato += "<camposdef />"
            }
            xmldato += "</configuraciones>"


            nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                                                            onSuccess: function(err, transport){          
                                                                            if (err.params["resultado"] != '') { alert(err.params["resultado"]) }
                                                                            mywin.actualizar = true
                                                                            id_conf = err.params["id_conf"]
                                                                            tablaCampos.refresh()
                                                                            tablaParametro.refresh()
                                                                            tablaPizarra.refresh()
                                                                            tablaTransferencia.refresh()
                                                                            }
            })
        }

        function eliminar(){   
            if (!permisosEditar()){
                alert('No tiene permisos para eliminar esta configuración.')
                return
            }
            if(id_conf == 0){
                alert('No hay ninguna configuración cargada que pueda ser eliminada.')
                return
            }
            nvFW.confirm("¿Desea eliminar la configuración?", {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function(win) { win.close(); return },
                ok: function(win) {    
                      var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?>"
                        xmldato += "<configuraciones modo='B' id='" + id_conf + "' nombre='" + campos_defs.get_value("nombre") + "' comentario='" + campos_defs.get_value("comentario") + "'></configuraciones>"
                        nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                                                        onSuccess: function(err, transport) {  
                                                                            if (err.params["resultado"] != '') { alert(err.params["resultado"]) }
                                                                            mywin.actualizar = true
                                                                            mywin.close()
                                                                        }
                        }) 
                }
            })
        }

        var alturaIframe = 258
        var anchuraIframe = 560        
        function window_onresize() {
            try{      
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divCab_h = $('divMenu').getHeight()
                var divtab_h = $('tabla').getHeight()
                $('frame_ref').setStyle({ 'height': body_h - divCab_h - divtab_h - dif })
                var frame_h = $('frame_ref').getHeight()
                var frame_w = $('frame_ref').getWidth()

               alturaIframe = (frame_h / 2) - 40
               anchuraIframe = (frame_w / 2) - 40

               if (winCampo){                
                   $('campodef_sub_window').setStyle({ 'height': alturaIframe - 5 + 'px', 'width': anchuraIframe + 'px', 'bottom':40+'px'})
                   $('campodef_sub_window_content').setStyle({ 'height': alturaIframe - 5 + 'px', 'width': anchuraIframe + 'px' })
                   $('campodef_sub_window_iframe').setStyle({ 'height': alturaIframe -5 + 'px', 'width': anchuraIframe + 'px' }) 
               }

               if (winP)
               {
                   $('pizarras_sub_window').setStyle({ 'height': alturaIframe - 5 + 'px', 'width': anchuraIframe + 'px' })
                   $('pizarras_sub_window_content').setStyle({ 'height': alturaIframe - 5 + 'px', 'width': anchuraIframe + 'px' })
                   $('pizarras_sub_window_iframe').setStyle({ 'height': alturaIframe - 5 + 'px', 'width': anchuraIframe + 'px' })
               }

               if (winTrans)
               {
                   $('transferencia_sub_window').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px' })
                   $('transferencia_sub_window_content').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px' })
                   $('transferencia_sub_window_iframe').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px' })
               }

               if (winParam)
               {
                   $('parametro_sub_window').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px', 'bottom': 40 + 'px' })
                   $('parametro_sub_window_content').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px' })
                   $('parametro_sub_window_iframe').setStyle({ 'height': alturaIframe + 'px', 'width': anchuraIframe + 'px' })
               }
            }
            catch (e) { }
        }

        function ver_arbol(){
            if (id_conf == 0 ) {
                alert("Debe seleccionar una configuración guardada para ver el árbol.")
            }
            else{
                if (vista_arbol ){
                    ObtenerVentana('frame_ref').location.href = '../enBlanco.htm'
                    window_onload()
                    vista_arbol = false
                }
                else{
                    winP.close()
                    winCampo.close()
                    winParam.close()
                    winTrans.close()
                    ObtenerVentana('frame_ref').location.href = '/FW/configuraciones_especiales/conf_especiales_tree.aspx?id_conf=' + id_conf
                    vista_arbol = true

                }
            }
        }                
 
    </script>
    
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden">
  <div id="divMenu" style="margin: 0px; padding: 0px;"></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenuLoca = new tMenu('divMenu', 'vMenuLoca');
        Menus["vMenuLoca"] = vMenuLoca
        Menus["vMenuLoca"].alineacion = 'centro';
        Menus["vMenuLoca"].estilo = 'A';
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuLoca"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>arbol</icono><Desc>Cambiar vista</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ver_arbol()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenuLoca.loadImage('guardar', '/FW/image/icons/guardar.png')
        vMenuLoca.loadImage('eliminar', '/FW/image/icons/eliminar.png')
        vMenuLoca.loadImage('arbol', '/FW/image/sistemas/sistema.png')
        vMenuLoca.MostrarMenu()
    </script> 
  <table class="tb1" id="tabla">
    <tr>
        <td class="Tit1" style="width: 10%"> Nombre:</td>
        <td><%= nvFW.nvCampo_def.get_html_input("nombre", enDB:=False, nro_campo_tipo:=104)%></td>
    </tr>
    <tr>
        <td class="Tit1 style="width:10%"> Comentario:</td>
        <td><%= nvFW.nvCampo_def.get_html_input("comentario", enDB:=False, nro_campo_tipo:=104)%></td>
    </tr>
  </table>
  <iframe src="../enBlanco.htm" id="frame_ref" name="frame_ref" style="width: 100%; height: 100%;" frameborder="0" marginheight="0" marginwidth="0"></iframe>
            
</body>
</html>