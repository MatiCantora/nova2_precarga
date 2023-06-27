<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<%
    Dim nodoId As String = nvFW.nvUtiles.obtenerValor("nodoId", "")

    '|-------------------------------------------------------------------------------------
    '|                        Carga de arbol de objetos
    '|-------------------------------------------------------------------------------------
    If nodoId <> "" Then
        Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        tTreeNodo.loadFromDB("verTree_nodos_ref2", nodoId, "ref_dep_orden")
        tTreeNodo.reponseXML()
    End If

    Me.contents("filtroDragAndDrop") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='drag_and_drop_ref'><parametros><nodo_id_drag>%nodo_drag.id%</nodo_id_drag><nodo_id_drop%nodo_drop.id%</nodo_id_drop><copiar>%copiar%</copiar></parametros></procedure></criterio>")
    Me.contents("filtroRefMostrar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verRef_docs'><campos>*</campos><orden>doc_orden</orden></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Arbol de referencias</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit() %>

    <style type="text/css">
        BODY { background-color: white; }
        .dad_tr_drag_over td { border-top: solid gray 2px; }    
    </style>

    <script type="text/javascript">
        var vTree;

        function window_onload() {
            vTree = new tTree('Div_vTree_0', "vTree");
            vTree.loadImage('ref', '/FW/image/icons/info.png')
            vTree.bloq_contenedor = $$("BODY")[0]

            vTree.getNodo_xml = tree_getNodo;
            vTree.async = true;
      
            vTree.cargar_nodo('Raiz');

            vTree.onNodeCharge = function(nodo_id) {
                if (nodo_id.toLowerCase() == 'raiz') 
                    this.MostrarArbol();
            }
            
            vTree.ChargeNodeOnchek = true
            window_onresize();
  
            // Drag and drop
            vTree.dad_drop_eval = "element.hasClassName('hqTR_Arbol') || element.id == 'prueba'" //Evaluación del elemento destino
            vTree.dad_opacity = 0.3
            
            vTree.dad_drag_over = function(e, element) {
                element.addClassName('dad_tr_drag_over')
            }

            vTree.dad_drag_over_out = function(e, element) {
                element.removeClassName('dad_tr_drag_over')
            }

            vTree.dad_drop = function(e, drag_nodo, drop_element, drop_nodo) {
                if (drag_nodo != drop_nodo && drop_nodo != null) {
                    e = !window.event ? e : window.event
                    var copiar = e.ctrlKey == 1 ? 1 : 0
                    drag_and_drop_ref(this, drag_nodo, drop_nodo, copiar)
                }
            }
        }

        function window_onresize() {
            try {
                var dif         = Prototype.Browser.IE ? 5 : 2,
                    body_height = $$('body')[0].getHeight(),
                    cab_height  = $('Contenedor').getHeight()

                $('Div_vTree_0').setStyle({ 'height': body_height - cab_height - dif + 'px' })
            }
            catch(e) {}
        }

        function drag_and_drop_ref(arbol, nodo_drag, nodo_drop, copiar) {
            var rs = new tRS();
     
            rs.open({
                filtroXML: nvFW.pageContents.filtroDragAndDrop,
                params: "<criterio><params nodo_id_drag='" + nodo_drag.id + "' nodo_id_drop='" + nodo_drop.id + "' copiar='" + copiar + "'/></criterio>"
            })
     
            if (!rs.EOF) {
                var depende_de_drop = rs.getdata('depende_de_drop')
                var depende_de_drag = rs.getdata('depende_de_drag')
        
                depende_de_drag = depende_de_drop == depende_de_drag ? null : depende_de_drag
        
                if (depende_de_drop != null)
                    arbol.recargar_nodo(depende_de_drop)   

                if (depende_de_drag != null)
                    arbol.recargar_nodo(depende_de_drag) 
            
                arbol.MostrarArbol()
            }
        }

        var node_global_actual
        
        function actualizar_tree() {
            if ((node_global == undefined) || node_global_actual != node_global) {
                $(vTree.canvas).innerHTML = '' //resetea el div
                $(vTree.canvas).id        = 'Div_vTree_0' // lo vuelve a su nombre original
                vTree.length              = 0 // resetea la estructura
                window_onload() // vuelve a cargar
                node_global               = node_global_actual 

                if (vTree.id != node_global && node_global != undefined)
                    if (vTree.nodos[vTree.uid + node_global] != undefined)
                        vTree.nodos[vTree.uid + node_global].expand()
            }
            else
                vTree.recargar_node(node_global) 
        }

        function tree_getNodo(nodoId, oXML) {
            oXML.load("ref_tree.aspx", "nodoId=" + nodoId + "&modo=loadTree")
        }

        var node_global

        function nodo_ref_onclick(nodo_id) {
            var nro_ref
            node_global = nodo_id

            var r   = new RegExp('B(.*)$')
            nro_ref = parseInt(nodo_id.match(r)[1], 10)
    
            if (nro_ref != '')
                ref_mostrar(nro_ref)
        }

        function ref_mostrar(nro_ref, version, destino) { 
            var strXML = "<nro_ref type='igual'>" + nro_ref + "</nro_ref>"
            
            if (!version)
                strXML += "<ref_doc_activo type='igual'>1</ref_doc_activo>"  
            else  
                strXML += "<ref_doc_version type='igual'>" + version + "</ref_doc_version>"
      
            var id_ref_auto = 0;
    
            if (window.top.editAutoguardadaRef) {
                id_ref_auto = window.top.editAutoguardadaRef;
            }

            if (!destino) {
               destino = 'frame_ref'
            }

            window.top.editAutoguardadaRef = false;

            window.top.nvFW.exportarReporte({
                formTarget: destino,
                filtroXML: nvFW.pageContents.filtroRefMostrar,
                filtroWhere: "<criterio><filtro>" + strXML + "</filtro></criterio>",
                xsl_name: "HTML_Ref_doc_datos.xsl",
                path_xsl: '/wiki/report/verRef_docs/HTML_Ref_doc_datos.xsl',
                parametros: '<parametros><id_ref_auto>' + id_ref_auto + '</id_ref_auto><app_path_rel>' + window.top.app_path_rel + '</app_path_rel></parametros>',
                winPrototype: {
                    modal: true,
                    center: true,
                    bloquear: true,
                    url: 'enBlanco.htm',
                    title: '<b>Referencia</b>',
                    minimizable: true,
                    maximizable: true,
                    draggable: true,
                    width: 1000,
                    height: 800,
                    resizable: true,
                    destroyOnClose: true
                }
            })
        }
    </script>
</head>
<body onload="window_onload()" style="margin: 0px; padding: 0px; height: 99%;">
    <div id="Div_vTree_0" style="width:100%; overflow-y:visible"></div>
    <div id="Contenedor"></div>
</body>
</html>
