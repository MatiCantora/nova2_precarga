<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim nodoId As String = nvFW.nvUtiles.obtenerValor("nodoId", "")
      
    '|-------------------------------------------------------------------------------------
    '|                        Carga de arbol de objetos
    '|-------------------------------------------------------------------------------------
    If nodoId <> "" Then
        Dim tTreeNodo As New nvFW.nvBasicControls.tTreeNode
        tTreeNodo.loadFromDB("verPermisos_nodosTree", nodoId)
        For i As Integer = 0 To tTreeNodo.hijos.Count - 1
            tTreeNodo.hijos(i).enableCheckBox = False
            tTreeNodo.hijos(i).jscode = "nodo_permiso_onclick(" + tTreeNodo.hijos(i).id + ")"
        Next
        tTreeNodo.reponseXML()
    End If
    Dim filtroPermisosRel1 = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPermiso_Nodos_rel'><campos>nro_permiso,permitir,nro_permiso_grupo,permiso_grupo,path</campos><filtro><nro_per_nodo type='ISNULL'/><permitir type='distinto'>'No utilizado'</permitir></filtro><orden>path,nro_permiso_grupo,nro_permiso</orden></select></criterio>")
    Dim filtroPermisosRel2 = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPermiso_Nodos_rel'><campos>nro_permiso,permitir,nro_permiso_grupo,permiso_grupo,path</campos><filtro><NOT><nro_per_nodo type='ISNULL'/></NOT><permitir type='distinto'>'No utilizado'</permitir></filtro><orden>nro_permiso_grupo,nro_permiso</orden></select></criterio>")
  
    Me.contents("cargarArbol") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select><campos>dbo.FW_Permiso_Nodos_Tree('0000') as forxml_data</campos><filtro></filtro></select></criterio>")
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Arbol</title>

    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <% =Me.getHeadInit()%>
   
    <script type="text/javascript" language="javascript">

        var winP = nvFW.getMyWindow()
        var vTree;
        var filtroPermisosRel1 = '<% =filtroPermisosRel1 %>'
        var filtroPermisosRel2 = '<% =filtroPermisosRel2 %>'

        function window_onload() {
            window_onresize()   
            
            vTree=new tTree('Div_vTree_0',"vTree");
            vTree.loadImage("r",'/fw/image/sistemas/sistema.png')
            vTree.loadImage("m",'/fw/image/sistemas/modulo.png')
            vTree.loadImage("p",'/fw/image/icons/clave.png')
            vTree.bloq_contenedor=$$("BODY")[0]
            vTree.getNodo_xml = tree_getNodo;
            vTree.async=true;
            vTree.ChargeNodeOnchek=false
            vTree.cargar_nodo('raiz');
            vTree.onNodeCharge = function(nodo_id){
                if(nodo_id.toLowerCase()=='raiz')
                    this.MostrarArbol();
                }                 
         }

         function tree_getNodo(nodoId,oXML){
            oXML.load("permiso_nodos_tree.aspx","nodoId="+nodoId)
        }

        var node_global
        function nodo_permiso_onclick(nodo_id){   
            var nro_per_nodo
      
            node_global = nodo_id
            nro_per_nodo = parseInt(nodo_id,10)
    
            if (nro_per_nodo != '' && nro_per_nodo > 1)
            permiso_mostrar(nro_per_nodo)
         }
    
          function permiso_mostrar(nro_per_nodo){ 
                var path = "permiso_nodos_abm.aspx?nodo_get=" + nro_per_nodo;
                win = nvFW.createWindow({
                                        url: path,
                                        title: '<b>Permiso ABM</b>',
                                        minimizable: false,
                                        maximizable: false,
                                        draggable: true,
                                        width: 700,
                                        height: 350,
                                        resizable: true,
                                     });
                win.showCenter(true);
            }
    
        function permisos_rel(son) {
            var criterio;
           
            if(son == 'NO ASIGNADOS') {
                criterio = filtroPermisosRel1
                title = 'Permisos Faltan Asignar';
            }
            else {
                criterio = filtroPermisosRel2
                title = 'Permisos Asignados';
            }

            var strHTML = "<table class='tb1 highlightOdd highlightTROver' style='width: 100%; overflow-x:hidden'><tr class='tbLabel'><td style='width:30%'>Grupo</td><td style='width:30%'>Permiso</td><td>Path</td></tr>";
            
            var rs = new tRS();
            rs.async = true;

            rs.onComplete = function () { 
                while (!rs.eof()) {
                    var permiso2 = '(' + rs.getdata('nro_permiso') + ') ' + rs.getdata('permitir');
                    var grupo2 = '(' + rs.getdata('nro_permiso_grupo') + ') ' + rs.getdata('permiso_grupo');
                    var path2 = rs.getdata('path');
                    
                    strHTML += "<tr>"
                    strHTML += "<td style='text-align: left; vertical-align:middle'>" + grupo2 + "</td>";
                    strHTML += "<td style='text-align: left; vertical-align:middle'>" + permiso2 + "</td>";
                    strHTML += "<td style='text-align: left; vertical-align:middle'>" + path2 + "</td>";
                    strHTML += "</tr>";
                    rs.movenext();
                }

                strHTML += "</table>";

                var winTI = nvFW.createWindow({
                                    minimizable: false
                                    , maximizable: false
                                    , height: 300
                                    , width: 800
                                    , title: "<b>" + title + "</b>"
                });

                winTI.setHTMLContent(strHTML);
                winTI.showCenter(true);
            }
            
            rs.open(criterio);
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
     Menus["vMenuABM"].estilo = 'A';

     vMenuABM.loadImage("permiso_asignado", '/FW/image/icons/nueva.png')
     vMenuABM.loadImage("permiso_sin_asignar", '/FW/image/icons/nueva.png')
     vMenuABM.loadImage("nuevo", '/FW/image/icons/nueva.png')

     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>permiso_asignado</icono><Desc>Permisos Asignados</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permisos_rel('ASIGNADOS')</Codigo></Ejecutar></Acciones></MenuItem>")  
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono>permiso_sin_asignar</icono><Desc>Permisos No Asignados</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permisos_rel('NO ASIGNADOS')</Codigo></Ejecutar></Acciones></MenuItem>")  
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='3' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permiso_mostrar(0)</Codigo></Ejecutar></Acciones></MenuItem>")  
     vMenuABM.MostrarMenu()
    </script>  
   <div id="Div_vTree_0" style="width:100%;overflow:auto"></div>
</body>
</html>
