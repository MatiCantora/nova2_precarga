<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim nodoId As String = nvFW.nvUtiles.obtenerValor("nodoId", "")
      
    '|-------------------------------------------------------------------------------------
    '|                        Carga de arbol de objetos
    '|-------------------------------------------------------------------------------------
    If nodoId <> "" Then
        Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        tTreeNodo.loadFromDB("verParametros_NodosTree", nodoId)
        tTreeNodo.reponseXML()
    End If
    
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Arbol</title>

    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var winP = nvFW.getMyWindow()
        var vTree;

        function window_onload() {
            vTree = new tTree('Div_vTree_0', "vTree");
            vTree.loadImage('r', '/FW/image/sistemas/sistema.png')
            vTree.loadImage('m', '/FW/image/sistemas/modulo.png')
            vTree.loadImage('p', '/FW/image/transferencia/parametros.png')

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

        var node_global_actual
        function tree_getNodo(nodoId, oXML){
            oXML.load("parametros_nodos_tree_editar_valor.aspx", "nodoId=" + nodoId)
        }


        var node_global
        function nodo_parametro_onclick(nodo_id) {    
            var nro_par_nodo
            node_global = nodo_id
            nro_par_nodo = parseInt(nodo_id,10)
    
            if (nro_par_nodo != '' && nro_par_nodo > 1)
                parametro_mostrar(nro_par_nodo)
        }
    
        function parametro_mostrar(nro_par_nodo) { 
            var path = "parametros_nodos_abm.aspx?nodo_get=" + nro_par_nodo
            win = nvFW.createWindow({
                url: path,
                title: '<b>ABM</b>',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 700,
                height: 500,
                resizable: true,
                destroyOnClose: true,
             //   onClose: function (win) { debugger;  parametro_mostrar_return(win.options.userData.nodo_id) }
            });
            win.options.userData = { nodo_id: nro_par_nodo }
            win.showCenter(true);
        }

        function parametro_mostrar_return(){
            // Registrar los nodos que se encuentran expandidos
            var nodos_expandir = []
            for (i in vTree.nodos) {
                var nodo = vTree.nodos[i]
                if (nodo.estadoCarpeta == "abierto") {
                    nodos_expandir.push(nodo.id)
                }
            }

            // Volver a cargar el arbol
            vTree.getNodo_xml = tree_getNodo
            vTree.cargar_nodo('raiz')
            vTree.MostrarArbol();

            // Abrir los nodos que se encontraban expandidos antes de refrescar el arbol
            for (i in vTree.nodos) {
                var nodo = vTree.nodos[i]
                if (nodos_expandir.include(nodo.id))
                    nodo.expand(true)
            }
            //window_onload()
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

    </script>
    
</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<div id="divMenuABM"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM = new tMenu('divMenuABM','vMenuABM');
     Menus["vMenuABM"] = vMenuABM
     Menus["vMenuABM"].alineacion = 'centro';
     vMenuABM.loadImage("nuevo", '/FW/image/icons/nueva.png')
     Menus["vMenuABM"].estilo = 'A';
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametro_mostrar(0)</Codigo></Ejecutar></Acciones></MenuItem>")  
     vMenuABM.MostrarMenu()
    </script>  
   <div id="Div_vTree_0" style="width:100%;overflow-y:auto"></div>
</body>
</html>