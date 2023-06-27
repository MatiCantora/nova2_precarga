<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%

    Dim nodo_id = nvFW.nvUtiles.obtenerValor("nodoid", "")
    If (nodo_id <> "") Then
        Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        tTreeNodo.loadFromDB("verTreeNodos", nodo_id, "tipo", "cod_modulo_version = 806")
        tTreeNodo.reponseXML()
    End If

    'Dim t As New nvFW.nvBasicControls.tTreeNode("nodo1", "Nodo 1", "folder", count_hijos:=1)
    't.addChildrenNode("nodo2", "Nodo 2", "folder", count_hijos:=1)
    't.addChildrenNode("nodo3", "Nodo 3", "folder", count_hijos:=1)
    't.addChildrenNode("nodo4", "Nodo 4", "folder", count_hijos:=1)

    't.reponseXML()

 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

    var vTree
    function window_onload()
      {
      
      //Crear el div de contenido para el arbol
      vTree = new tTree('Div_vTree_0', "vTree");

      vTree.loadImage('folder', '/FW/image/filetype/folder.png')
      vTree.loadImage('file', '/FW/image/icons/file.png')
      vTree.loadImage('default', '/FW/image/icons/file.png')
      vTree.loadImage('html', '/FW/image/filetype/dbf.png')

           
//      vTree.ChargeNodeOnchek = false

      
      vTree.getNodo_xml = tree_getNodo
      vTree.onNodeCharge = function (nodo_id)
                                    {
                                    if (nodo_id == 'raiz')
                                    {
                                    this.MostrarArbol();
                                    }
                                    }
      vTree.bloq_contenedor = $$("BODY")[0]
      vTree.async = true
      vTree.ChargeNodeOnchek = true
      vTree.cargar_nodo("raiz");
      
      }

    function tree_getNodo(nodeId, oXML) 
      {
      oXML.load("prueba_tTree10.aspx", "nodoId=" + nodeId)
      }


    </script>
</head>
<body onload="window_onload()" style=" height:100%; overflow: hidden">
<div id="Div_vTree_0" style="width:100%; height:600px; overflow:auto"></div>
</body>
</html>
