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
            vTree.onNodeCharge = function (nodo_id){
                if (nodo_id.toLowerCase() == 'raiz')
                    this.MostrarArbol();
            }
            window_onresize()                         
        }

        function tree_getNodo(nodoId, oXML){
            oXML.load("parametros_nodos_tree_editar_valor.aspx", "nodoId=" + nodoId)
        }

        var node_global
        function nodo_parametro_onclick(nodo_id) { 
                 
            node_global = nodo_id
            var nro_par_nodo = parseInt(nodo_id,10)
    
            if (nro_par_nodo != '')
                parametro_valor_asignar(nro_par_nodo)
        }
    
        function parametro_valor_asignar(nro_par_nodo)
        { 
            ObtenerVentana("frame_nodo_parametro").location.href = 'parametros_nodos_editar_valor.aspx?nro_par_nodo=' + nro_par_nodo + "&modo=VER"
        }
  
        function actualizar_nodo(){}
    
        function window_onresize()
        {
            try
            {
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
        var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
        vMenuABM.loadImage("arbol", '/FW/image/icons/arbol.png')
        Menus["vMenuABM"] = vMenuABM
        Menus["vMenuABM"].alineacion = 'centro';
        Menus["vMenuABM"].estilo = 'A';
        Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>arbol</icono><Desc></Desc></MenuItem>")  
        vMenuABM.MostrarMenu()
    </script>  
    <div id="Div_vTree_0" style="width:100%;height:100%;overflow-y:auto;"></div>
</body>
</html>
