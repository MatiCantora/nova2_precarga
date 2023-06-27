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
    
    Me.contents("nombreNodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_NodosTree'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    
    
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

        var win = nvFW.getMyWindow()
        var vTree;
        var oCampo_def = win.options.parameters.campo_def
        win.cancelado = true //por defecto si cierra la ventana
        win.campo_def_value = ""
        win.campo_desc = ""

        function window_onload() 
        {
            vTree = new tTree('Div_vTree_0', "vTree");
            vTree.loadImage('r', '/FW/image/sistemas/sistema.png')
            vTree.loadImage('m', '/FW/image/sistemas/modulo.png')
            vTree.loadImage('p', '/FW/image/transferencia/parametros.png')

            vTree.getNodo_xml = tree_getNodo
            vTree.bloq_contenedor = $$("BODY")[0]
            vTree.async = true;
            vTree.cargar_nodo('raiz');
            vTree.MostrarArbol();
            vTree.onNodeCharge = function(nodo_id){
                if (nodo_id.toLowerCase() == 'raiz')
                    this.MostrarArbol();
            }

            window_onresize()                           
        }

        var node_global_actual

        function tree_getNodo(nodoId, oXML){
            oXML.load("/fw/configuraciones_especiales/conf_especiales_param_nodos.aspx", "nodoId=" + nodoId)
        }

        var node_global
        function nodo_parametro_onclick(nodo_id) {
            var rs = new tRS()
            rs.open(nvFW.pageContents.nombreNodo,"","<nodo_id type='igual'>"+nodo_id+"</nodo_id>")
            win.cancelado = false
            win.campo_def_value = nodo_id
            win.campo_desc = rs.getdata("nombre")
            win.close()
        }
 

        function window_onresize(){
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
     var vMenuABM = new tMenu('divMenuABM','vMenuABM');
     Menus["vMenuABM"] = vMenuABM
     Menus["vMenuABM"].alineacion = 'centro';
     vMenuABM.loadImage("nuevo", '/FW/image/icons/nueva.png')
     Menus["vMenuABM"].estilo = 'A';
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
    vMenuABM.MostrarMenu()
    </script>  
   <div id="Div_vTree_0" style="width:100%;overflow-y:auto"></div>
</body>
</html>