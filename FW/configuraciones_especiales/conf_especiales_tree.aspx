<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim id_conf As String = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    Dim nodoId As String = nvFW.nvUtiles.obtenerValor("nodoId", "")
          
    '|-------------------------------------------------------------------------------------
    '|                        Carga de arbol de objetos
    '|-------------------------------------------------------------------------------------
    If nodoId <> "" Then
        Dim rs As ADODB.Recordset
           
        If nodoId = "raiz" Then 'Crear el arbol
            Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode("raiz", "raiz", "R", count_hijos:=1)
           
            rs = nvDBUtiles.DBExecute("select * from verConf_especiales where id_cfg_especial = " & id_conf)
            tTreeNodo.addChildrenNode("conf", rs.Fields("nombre_conf").Value, "R", icono:="r", count_hijos:=4)
            nvDBUtiles.DBCloseRecordset(rs)
            
            tTreeNodo.reponseXML()
        
        ElseIf nodoId = "conf" Then  'cargar hijos de la configuracion
            Dim tTreeNodoConfiguracion As nvFW.nvBasicControls.tTreeNode
            
            rs = nvDBUtiles.DBOpenRecordset("select * from verConf_especiales where id_cfg_especial = " & id_conf)
            tTreeNodoConfiguracion = New nvFW.nvBasicControls.tTreeNode(rs.Fields("id_cfg_especial").Value, rs.Fields("nombre_conf").Value, "R", count_hijos:=4)
            
            rs = nvDBUtiles.DBOpenRecordset("select count(*) as tot from verConf_especial_pizarras where id_cfg_especial = " & id_conf)
            tTreeNodoConfiguracion.addChildrenNode("pizarras", "Pizarras", "M", , jscode:="nuevaPizarra()", count_hijos:=rs.Fields("tot").Value)
            
            rs = nvDBUtiles.DBOpenRecordset("select count(*) as tot from verConf_especial_campoDef where id_cfg_especial = " & id_conf)
            tTreeNodoConfiguracion.addChildrenNode("camposDef", "Campos Def", "M", jscode:="nuevoCampodef()", count_hijos:=rs.Fields("tot").Value)
            
            rs = nvDBUtiles.DBOpenRecordset("select count(*) as tot from verConf_especial_transferencia where id_cfg_especial = " & id_conf)
            tTreeNodoConfiguracion.addChildrenNode("transf", "Transferencias", "M", jscode:="nuevaTransferencia()", count_hijos:=rs.Fields("tot").Value)
            
            rs = nvDBUtiles.DBOpenRecordset("select count(*) as tot from verConf_especial_parametro where id_cfg_especial = " & id_conf)
            tTreeNodoConfiguracion.addChildrenNode("param", "Parámetros", "M", jscode:="nuevoParametro()", count_hijos:=rs.Fields("tot").Value)
            
            nvDBUtiles.DBCloseRecordset(rs)
            tTreeNodoConfiguracion.reponseXML()
            
        ElseIf nodoId = "pizarras" Then 'cargo las pizarras que existan asociadas
            rs = nvDBUtiles.DBOpenRecordset("select * from verConf_especial_pizarras where id_cfg_especial = " & id_conf)
            Dim tTreeNodoPizarras As New nvFW.nvBasicControls.tTreeNode("pizarras", "Pizarras", "M", count_hijos:=rs.RecordCount)
            While Not rs.EOF
                Dim nro_calc_pizarra = rs.Fields("nro_calc_pizarra").Value
                Dim grupo = rs.Fields("permiso_grupo").Value
                Dim permiso = rs.Fields("nro_permiso_ver").Value
               
                tTreeNodoPizarras.addChildrenNode(rs.Fields("calc_pizarra").Value, rs.Fields("calc_pizarra").Value, "H", jscode:="verPizarra(" & nro_calc_pizarra & ",'" & grupo & "'," & permiso & ")")
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            tTreeNodoPizarras.reponseXML()
            
        ElseIf nodoId = "camposDef" Then 'cargo los campos def que existan asociados
            rs = nvDBUtiles.DBOpenRecordset("select * from verConf_especial_campoDef where id_cfg_especial = " & id_conf)
           
            Dim tTreeNodoCampoDef As New nvFW.nvBasicControls.tTreeNode("camposDef", "Campos Def", "M")
            While Not rs.EOF
                tTreeNodoCampoDef.addChildrenNode(rs.Fields("campo_def").Value, rs.Fields("descripcion").Value, "H", jscode:="verCamposDef('" & rs.Fields("campo_def").Value & "')")
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            tTreeNodoCampoDef.reponseXML()
          
            
        ElseIf nodoId = "transf" Then 'cargo las transferencia que existan asociadas
                
            rs = nvDBUtiles.DBOpenRecordset("select * from verConf_especial_transferencia where id_cfg_especial = " & id_conf)
            Dim tTreeNodoTransf As New nvFW.nvBasicControls.tTreeNode("transf", "Transferencias", "M")
            While Not rs.EOF
                Dim id_transferencia = rs.Fields("id_transferencia").Value
                tTreeNodoTransf.addChildrenNode(rs.Fields("nombre").Value, rs.Fields("nombre").Value, "H", jscode:="verTransferencia(" & id_transferencia & ")")
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            tTreeNodoTransf.reponseXML()
            
        ElseIf nodoId = "param" Then  'cargo los parametros que existan asociados
            Me.addPermisoGrupo("permisos_parametros")
                
            rs = nvDBUtiles.DBOpenRecordset("select * from verConf_especial_parametro where id_cfg_especial = " & id_conf)
            Dim tTreeNodoParam As New nvFW.nvBasicControls.tTreeNode("param", "Parámetros", "M")
            While Not rs.EOF
                tTreeNodoParam.addChildrenNode(rs.Fields("par_nodo").Value, rs.Fields("par_nodo").Value, "H", jscode:="verParametro(" & rs.Fields("nro_par_nodo").Value & ")")
                rs.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rs)
            tTreeNodoParam.reponseXML()
            
        Else
            Dim tTreeNodoParam As New nvFW.nvBasicControls.tTreeNode()
            tTreeNodoParam.reponseXML()
        End If

    End If
    
    Me.addPermisoGrupo("permisos_parametros")
    Me.addPermisoGrupo("permisos_transferencia")
    'Cargar permiso grupo de la conf seleccionada
    If id_conf <> 0 Then
        Dim strSQL As String = "select * from verConf_especial_pizarras where id_cfg_especial = " + id_conf
        Dim res As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
        If Not res.EOF Then
            Dim permiso_grupo = res.Fields("permiso_grupo").Value
            Me.addPermisoGrupo(permiso_grupo)
        End If
        nvDBUtiles.DBCloseRecordset(res)
    End If
    
    
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Arbol Conf. especiales</title>

    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var vTree;
        var id_conf = '<%= id_conf %>'
        function window_onload() {   
            vTree = new tTree('Div_vTree_0', "vTree");
            vTree.loadImage('r', '/FW/image/sistemas/sistema.png')
            vTree.loadImage('m', '/FW/image/sistemas/modulo.png')
            vTree.loadImage('h', '/FW/image/transferencia/parametros.png')
            vTree.getNodo_xml = tree_getNodo
            vTree.bloq_contenedor = $$("BODY")[0]
            vTree.async = true;
            vTree.cargar_nodo('raiz');
            
            vTree.MostrarArbol();
            vTree.onNodeCharge = function(nodo_id) {
                if (nodo_id.toLowerCase() == 'raiz')
                    this.MostrarArbol();
            }
            
            window_onresize()                           
        }
        
        function window_onresize(){
            try{
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var cab_height = $('divMenuABM').getHeight()
                $('Div_vTree_0').setStyle({'height': body_height - cab_height - dif + 'px'})
            }
            catch(e){}  
        }

        function tree_getNodo(nodoId, oXML){    
            oXML.load("conf_especiales_tree.aspx", "id_conf=" + id_conf + "&nodoId="+ nodoId)
        }

        /*Pizarras*/
        function nuevaPizarra(){     
            var win = top.nvFW.createWindow({
                        title: "<b>Nueva pizarra</b>",
                        url: "/fw/configuraciones_especiales/conf_especiales_tree_pizarra.aspx?id_conf=" + id_conf,
                        width: "400",
                        height: "200",
                        top: "50"  ,
                        onClose: function(win) { if (win.actualizar) { vTree.recargar_nodo('raiz') } }
                    })
                    win.showCenter(true) 
        }

        function verPizarra(nro_calc_pizarra, permiso_grupo, nro_permiso) {        
                if (nvFW.tienePermiso(permiso_grupo, nro_permiso)){
                    var win = top.nvFW.createWindow({
                        url: "/fw/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=" + nro_calc_pizarra,
                        width: "1100",
                        height: "400",
                        top: "50" ,
                        onClose: function(win) { if (win.actualizar) { vTree.recargar_nodo('raiz') } }
                    })
                    win.showCenter()
                }
                else {
                    alert("No tiene permisos para ver la pizarra seleccionada")
                }
        }

        /*Campos Def*/
        function nuevoCampodef(){
            var win = top.nvFW.createWindow({
                        title: "<b>Nuevo campo def</b>"  ,
                        url: "/fw/configuraciones_especiales/conf_especiales_tree_campodef.aspx?id_conf=" + id_conf,
                        width: "400",
                        height: "200",
                        top: "50" ,
                        onClose: function(win) { if (win.actualizar) { vTree.recargar_nodo('raiz') } }
                    })
                    win.showCenter(true)
        }
               
        function verCamposDef(campo_def){
            var win = top.nvFW.createWindow({
                                url: "/fw/campo_def/campos_def_listar.aspx?campo_def=" + campo_def,
                                width: "1100",
                                height: "400",
                                top: "50"
                            })
            win.showCenter()
        }

        /*Transferencia*/
        function nuevaTransferencia(){
            var win = top.nvFW.createWindow({
                title: "<b>Nueva transferencia</b>",
                url: "/fw/configuraciones_especiales/conf_especiales_tree_transferencia.aspx?id_conf=" + id_conf,
                width: "400",
                height: "200",
                top: "50",
                onClose: function(win) { if (win.actualizar) { vTree.recargar_nodo('raiz') } }
            })
            win.showCenter(true)
        }

        function verTransferencia(id_transferencia) {
            if (nvFW.tienePermiso("permisos_transferencia", 1)) {
                    window.open("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" + id_transferencia)
            }
            else
                alert('No posee permisos para ver esta transferencia. Consulte con el Administrador del Sistema.')
        }

        /*Parametros*/
        function nuevoParametro(){

            var win = nvFW.createWindow({ 
                title: "<b>Nuevo Parámetro</b>",
                url: "/fw/configuraciones_especiales/conf_especiales_tree_parametro.aspx?id_conf=" + id_conf  ,
                width: "400px",
                height: "200px",
                setWidthMaxWindow: true,
                onClose: function(win) { if (win.actualizar) { vTree.recargar_nodo('raiz') } }
                
            })
            win.showCenter(true);
        }

        function verParametro(par_nodo){
            if (nvFW.tienePermiso('permisos_parametros', 2)) {
            if (par_nodo != ''){
                    var win = top.nvFW.createWindow({
                        url: "/fw/parametros/parametros_nodos_editar_valor.aspx?nro_par_nodo=" + par_nodo,
                        width: "700",
                        height: "450",
                        setWidthMaxWindow: true,
                        top: "50"
                    })
                    win.showCenter()
                }
            }
            else{
                nvFW.alert("No posee permisos para ver el parámetro. Consulte con el administrador de sistemas")
            }
        }

    </script>
    
</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<div id="divMenuABM"></div>
   <div id="Div_vTree_0" style="width:100%;overflow-y:auto"></div>
   
</body>
</html>

