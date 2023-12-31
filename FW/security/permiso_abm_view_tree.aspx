<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim nodoId As String = nvFW.nvUtiles.obtenerValor("nodoId", "")
    Dim tipo_operador_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_get", "")
    Dim tipo_operador_comp_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_comp_get", "")
    Dim comparar As Boolean = nvFW.nvUtiles.obtenerValor("comparar", False)

    '|-------------------------------------------------------------------------------------
    '|                        Carga de arbol de objetos
    '|-------------------------------------------------------------------------------------

    If nodoId <> "" Then
        Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        If tipo_operador_get <> "" Then
            tTreeNodo.loadFromDB("verPermisos_nodosTree", nodoId, filtro:="(tipo_operador = " + tipo_operador_get + " or tipo_operador is null)")
        Else
            tTreeNodo.loadFromDB("verPermisos_nodosTree", nodoId, filtro:="(tipo_operador = " + tipo_operador_comp_get + " or tipo_operador is null)")
        End If
        tTreeNodo.reponseXML()
    End If

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim err As New nvFW.tError()
    If modo.ToUpper = "GUARDAR" Then

        Dim strXML As String = nvFW.nvUtiles.obtenerValor("strXML", "")
        Dim rs As ADODB.Recordset
        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_permiso_nodos_perfiles_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
        Dim pStrXML As ADODB.Parameter
		pStrXML = cmd.CreateParameter("@strXML", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
        cmd.Parameters.Append(pStrXML)
        rs = cmd.Execute()
        Dim numError As Integer = rs.Fields.Item("numError").Value
        If numError <> 0 Then
            Err.numError = numError
            Err.titulo = rs.Fields.Item("titulo").Value
            Err.mensaje = rs.Fields.Item("mensaje").Value
            Err.debug_desc = rs.Fields.Item("debug_desc").Value
            Err.debug_src = rs.Fields.Item("debug_src").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Err.response()
    End If

    Me.contents("filtroHeredar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPermisos_nodosTree'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Arbol de permisos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <%= Me.getHeadInit() %>
    <script type="text/javascript">
        var vTree, vTreeComparar
        var tipo_operador_get = '<%= tipo_operador_get %>'
        var tipo_operador_comp_get = '<%= tipo_operador_comp_get %>'

        function window_onload() {
            window_onresize();
            cargarArboles()
            vTree.cargar_nodo('raiz');
            
            if (tipo_operador_comp_get == undefined)
                tipo_operador_comp_get = ''

            campos_defs.add('operador_herencia',{ enDB: false,nro_campo_tipo: 104, target:'herencia' })
            campos_defs.items['operador_herencia']['onchange'] = habilitar_tree
            if (tipo_operador_comp_get != '')
                comparar(tipo_operador_comp_get)
        }

        function cargarArboles(){
            vTree = new tTree('Div_vTree_0',"vTree");
            vTree.loadImage("r",'/fw/image/sistemas/sistema.png')
            vTree.loadImage("m",'/fw/image/sistemas/modulo.png')
            vTree.loadImage("p",'/fw/image/icons/clave.png')
            vTree.bloq_contenedor=$$("BODY")[0]
            vTree.getNodo_xml = tree_getNodo;
            vTree.async=true;
            vTree.ChargeNodeOnchek=true
            vTree.onNodeCharge = function(nodo_id){
                if(nodo_id.toLowerCase()=='raiz')
                    this.MostrarArbol();
                    vTree.nodos[1].expand(true)
                }
            
            //arbol de comparacion de perfiles
            vTreeComparar = new tTree('Div_vTree_comparar',"vTreeComparar");
            vTreeComparar.loadImage("r",'/fw/image/sistemas/sistema.png')
            vTreeComparar.loadImage("m",'/fw/image/sistemas/modulo.png')
            vTreeComparar.loadImage("p",'/fw/image/icons/clave.png')
            vTreeComparar.bloq_contenedor = $$("BODY")[0]
            vTreeComparar.getNodo_xml = tree_getNodo_comparar;
            vTreeComparar.async=true;
            vTreeComparar.ChargeNodeOnchek = true
            vTreeComparar.onNodeCharge = function (nodo_id){
                if(nodo_id.toLowerCase()=='raiz')
                    this.MostrarArbol();
                    vTreeComparar.nodos[1].expand(true)
            }
            
        }

        function tree_getNodo(nodoId,oXML){              
            oXML.load("permiso_abm_view_tree.aspx","nodoId="+nodoId+"&tipo_operador_get="+tipo_operador_get+"&tipo_operador_comp_get="+tipo_operador_comp_get)
        }

        function window_onresize(){
            try {
                var dif=Prototype.Browser.IE?5:2,
                    body_height=$$('body')[0].getHeight(),
                    cab_height=$('divMenuABM').getHeight()

                    $('Div_vTree_0').setStyle({ 'height': body_height-cab_height-dif+'px' })
                    
                    if($('Div_vTree_comparar').style.display == 'none'){
                        $('Div_vTree_0').setStyle({ 'width': 100+'%'})
                    }
                    else{
                        $('Div_vTree_0').setStyle({ 'width': 50+'%'})
                        $('Div_vTree_comparar').setStyle({ 'width': 49+'%'})
                        $('Div_vTree_comparar').setStyle({ 'height': body_height-cab_height-dif+'px' })
                    }
                    
            }
            catch(e) { }
        }

        function habilitar_tree(){
            if(vTree==undefined) return
            Arr_cargar_permiso_nodos()

            for(i in vTree.nodos) {
                nodo=vTree.nodos[i]
                $('chck_'+nodo.uid).checked=false
                vTree.nodos[i].checked=false

                for(j in Arrpnp) {
                    if(i==j) {
                        $('chck_'+nodo.uid).checked=Arrpnp[j].habilitado
                        nodo.checked=Arrpnp[j].habilitado
                    }
                }
            }
        }

        var Arrpnp
        function Arr_cargar_permiso_nodos(){
            Arrpnp={}
            var nro_perfil = campos_defs.value('operador_herencia')

            var rs = new tRS();
            rs.open(nvFW.pageContents.filtroHeredar,'',"<tipo_operador type='igual'>"+nro_perfil+"</tipo_operador>")
            while(!rs.eof()) {
                Arrpnp[rs.getdata('nodo_id')]={}
                Arrpnp[rs.getdata('nodo_id')].habilitado=rs.getdata('checked')=='true' ? true : false
                hereda=false
                rs.movenext()
            }
        }

        function guardar(){
            if(tipo_operador_get=='') {
                alert("Seleccione el perfil.")
                return
            }

            var xmldato=""
            xmldato="<?xml version='1.0' encoding='ISO-8859-1'?>"
            xmldato+="<permiso_nodos_perfiles tipo_operador ='"+tipo_operador_get+"'>"
            xmldato+="<permiso_nodos>"
            for(i in vTree.nodos) {
                nodo=vTree.nodos[i] 
                xmldato+="<relacion nro_per_nodo='"+nodo.id+"' habilitado ='"+nodo.checked+"'/>"
            }
            xmldato+="</permiso_nodos>"
            xmldato+="</permiso_nodos_perfiles>"
            nvFW.error_ajax_request('permiso_abm_view_tree.aspx',{
                parameters: { modo: 'GUARDAR',strXML: xmldato },
                onSuccess: function(err,transport){
                    if(err.numError!=0) {
                        alert(err.mensaje)
                        return
                    }
                    try { parent.win.options.userData.accion='refresh' } catch(e) { }
                }
            });
        }

        var hereda=false
        var  winOperador
        function permiso_heredar(){
            hereda=false
            winOperador = parent.nvFW.createWindow({ 
                url: 'perfil_heredar.aspx',
                title: 'Operador ABM',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 400,
                height: 200,
                onClose: perfil_heredar_return
            });
            winOperador.showCenter(true)
        }

        function perfil_heredar_return() {
            if (winOperador.returnValue != '' && winOperador.returnValue != undefined) {
                campos_defs.set_value("operador_herencia", winOperador.returnValue);
            }
        }

        function vista_lineal(){
            parent.cargar_vista('lineal', tipo_operador_comp_get)
        }

        function comparar(perfil_comparar){
            tipo_operador_comp_get = perfil_comparar
            vTreeComparar.cargar_nodo('raiz');
            $('Div_vTree_comparar').style.display = "inline"
            window_onresize()
        }

        function tree_getNodo_comparar(nodoId,oXML){ 
            oXML.load("permiso_abm_view_tree.aspx","nodoId="+nodoId+"&tipo_operador_comp_get="+tipo_operador_comp_get)
        }

        function window_onresize() {
            try {       
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var Div_vTree_0 = $('Div_vTree_0').getHeight()
                var divBuscador_h = $('divMenuABM').getHeight()

                $('Div_vTree_0').setStyle({ 'height': body_h -  divBuscador_h - dif  })
                $('Div_vTree_comparar').setStyle({ 'height': body_h  - divBuscador_h - dif  })

                tabla_permisos_grupo.resize()
                tabla_permisos_detalle.resize()
            }
            catch (e) { }
        }

    
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="margin: 0px; padding: 0px; height: 99%;">
    <div id="herencia" style="display:none"></div>
    <div id="divMenuABM"></div>
     <script type="text/javascript" language="javascript">
         var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
         vMenuABM.loadImage("guardar", "/fw/image/icons/guardar.png")
         vMenuABM.loadImage("persona_sel", "/fw/image/icons/operador.png")
         vMenuABM.loadImage("nueva", "/fw/image/icons/nueva.png")
         Menus["vMenuABM"] = vMenuABM
         Menus["vMenuABM"].alineacion = 'centro';
         Menus["vMenuABM"].estilo = 'A';
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")  
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Visualizaci�n Tipo �rbol</Desc></MenuItem>")
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>persona_sel</icono><Desc>Heredar Permisos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permiso_heredar()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='4' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nueva</icono><Desc>Vista Lineal</Desc><Acciones><Ejecutar Tipo='script'><Codigo>vista_lineal(event)</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuABM.MostrarMenu()
    </script> 
    <div id="Div_vTree_0" style="width:50%;overflow:auto; float:left"></div>
    <div id="Div_vTree_comparar" style="width:49%;overflow:auto;float:right;display:none"></div>
    <div id="Contenedor"></div>
</body>
</html>
