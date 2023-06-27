<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<%@ Import Namespace="nvFW" %>
<%@ Import Namespace="nvFW.nvUtiles" %>
<%
    
     
    
    Dim nodo_id = nvFW.nvUtiles.obtenerValor("nodoid", "")
    If (nodo_id <> "") Then
        
        Dim tTreeNodo As nvFW.nvBasicControls.tTreeNode
        Dim cod_servidor As String = obtenerValor("cod_servidor", "")
        Dim cod_sistema As String = obtenerValor("cod_sistema", "")
        Dim cod_ss_cn As String = obtenerValor("cod_ss_cn", "")
        Dim sqlFilter As String = obtenerValor("sqlFilter", "")
        Dim object_id As Integer
        Dim object_name As String
        Dim nodo_id_parts() As String
        
        
        cod_servidor = "dev"
        cod_sistema = "nv_admin"
        cod_ss_cn = "primaria"
        sqlFilter = "name like '%fw%'"
        
        Dim cn_string As String = ""
        Dim rsObjects As ADODB.Recordset
        Dim rsDepends As ADODB.Recordset
        Dim param As ADODB.Parameter
        
        Dim strSQL As String = "select * from nv_servidor_sistema_cn where cod_servidor = '" & cod_servidor & "' and cod_sistema = '" & cod_sistema & "' and cod_ss_cn = '" & cod_ss_cn & "'"
        Dim rsCN As ADODB.Recordset = nvDBUtiles.ADMDBOpenRecordset(strSQL)
        cn_string = rsCN.Fields("cn_string").Value
        nvDBUtiles.DBCloseRecordset(rsCN)
        
        If (nodo_id.ToLower = "raiz") Then
            tTreeNodo = New nvFW.nvBasicControls.tTreeNode("raiz")
            strSQL = "select type, type_desc, COUNT(*) as cantidad from sys.objects where type in ('p', 'u', 'v', 'fn') " & IIf(sqlFilter = "", "", " and " & sqlFilter) & " group by type, type_desc"
            rsObjects = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, cod_cn:=cn_string)
            While Not rsObjects.EOF
                
                tTreeNodo.addChildrenNode(rsObjects.Fields("type").Value, rsObjects.Fields("type_desc").Value, "folder", "folder", count_hijos:=rsObjects.Fields("cantidad").Value, checked:=False, enableCheckBox:=True)
                rsObjects.MoveNext()
            End While
            nvDBUtiles.DBCloseRecordset(rsObjects)
        Else
            tTreeNodo = New nvFW.nvBasicControls.tTreeNode(nodo_id)
            nodo_id_parts = nodo_id.Split("_")
            'Si es el type nodo_id="U"
            If nodo_id_parts.Length = 1 Then
                strSQL = "select object_id, name from sys.objects where type = '" & nodo_id & "' " & IIf(sqlFilter = "", "", " and " & sqlFilter) & " order by name"
                rsObjects = nvDBUtiles.pvDBOpenRecordset(nvDBUtiles.emunDBType.db_other, strSQL, cod_cn:=cn_string)
                While Not rsObjects.EOF
                    
                    tTreeNodo.addChildrenNode(nodo_id & "_" & rsObjects.Fields("object_id").Value, rsObjects.Fields("name").Value, "hoja", "hoja", checked:=False, enableCheckBox:=True)
                    'Dim cmd As New nvDBUtiles.tnvDBCommand("dbo.sica_get_db_depends", ADODB.CommandTypeEnum.adCmdStoredProc, db_type:=nvDBUtiles.emunDBType.db_other, cod_cn:=cn_string, CursorLocation:=ADODB.CursorLocationEnum.adUseClient)
                    'cmd.Parameters("@object_id").Value = rsObjects.Fields("object_id").Value
                    'rsDepends = cmd.Execute
                    'If rsDepends.RecordCount = 0 Then
                    '    tTreeNodo.addChildrenNode(nodo_id & "_" & rsObjects.Fields("object_id").Value, rsObjects.Fields("name").Value, "hoja", "hoja")
                    'Else
                    '    tTreeNodo.addChildrenNode(nodo_id & "_" & rsObjects.Fields("object_id").Value, rsObjects.Fields("name").Value, "folder", "folder", count_hijos:=rsDepends.RecordCount)
                    'End If
                    'nvDBUtiles.DBCloseRecordset(rsDepends)
                    rsObjects.MoveNext()
                End While
                nvDBUtiles.DBCloseRecordset(rsObjects)
            Else
                If nodo_id_parts(nodo_id_parts.Length - 1) <> "depend" Then
                    object_id = nodo_id_parts(nodo_id_parts.Length - 1)
                Else
                    object_id = nodo_id_parts(nodo_id_parts.Length - 2)
                End If
                
                Dim cmd As New nvDBUtiles.tnvDBCommand("dbo.sica_get_db_depends", ADODB.CommandTypeEnum.adCmdStoredProc, db_type:=nvDBUtiles.emunDBType.db_other, cod_cn:=cn_string, CursorLocation:=ADODB.CursorLocationEnum.adUseClient)
                cmd.Parameters("@object_id").Value = object_id
                rsObjects = cmd.Execute
                If nodo_id_parts(nodo_id_parts.Length - 1) <> "depend" Then
                    If rsObjects.RecordCount <> 0 Then
                        tTreeNodo.addChildrenNode(nodo_id & "_depend", "Dependencias", "folder", "folder", count_hijos:=rsObjects.RecordCount)
                    End If
                Else
                    While Not rsObjects Is Nothing
                        While Not rsObjects.EOF
                            tTreeNodo.addChildrenNode(nodo_id & "_" & rsObjects.Fields("referenced_id").Value, rsObjects.Fields("referenced_object").Value, "folder", "folder", count_hijos:=1)
                            rsObjects.MoveNext()
                        End While
                        rsObjects = rsObjects.NextRecordset
                    End While
                End If
                    nvDBUtiles.DBCloseRecordset(rsObjects)
                End If
        End If
        'Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        'tTreeNodo.loadFromDB("verTreeNodos", nodo_id, "tipo", "cod_modulo_version = 806")
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
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    
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
      vTree.ChargeNodeOnchek = false
      vTree.cargar_nodo("raiz");
      
      }

    function tree_getNodo(nodeId, oXML) 
      {
      oXML.load("prueba_tTree11.aspx", "nodoId=" + nodeId)
      }


    </script>
</head>
<body onload="window_onload()" style=" height:100%; overflow: hidden">
<div id="Div_vTree_0" style="width:100%; height:600px; overflow:auto"></div>
</body>
</html>
