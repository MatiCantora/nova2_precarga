<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    
    '/************************************************************************************/
    '/********              Carga de arbol de objetos                 ********************/
    '/************************************************************************************/
            
    If (modo = "loadTree") Then
        Dim nodo_id = nvFW.nvUtiles.obtenerValor("nodoid", "")
        Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBOpenRecordset("SELECT dbo.FW_PKI_Nodos_Tree('" + nodo_id + "') AS responseXML")
        Dim responseXML As String = rs.Fields("responseXML").Value
        Response.ContentType = "text/xml"
        Response.Write(responseXML)
        Response.End()
    End If

    Me.contents("ver_tree_nodo") = nvXMLSQL.encXMLSQL("<criterio><select vista='verTree_nodos_pki'><campos>id,nodo_tipo</campos><orden></orden><filtro><nodo_id type='igual'>'%nodo_id%'</nodo_id></filtro></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Cer Admin</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <style type="text/css">
        BODY
        {
            background-color: #E9F0F4;
            font: 11px Trebuchet, Tahoma, Arial, Helvetica;
            border: 0px;
        }
    </style>
    <script type="text/javascript" language="javascript">

        window.alert = function (msg) { window.top.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
        var winP = nvFW.getMyWindow()

        var vTree = new tTree('Div_vTree_0', "vTree")
        vTree.loadImage('r', '/FW/image/icons/permiso.png')
        vTree.loadImage('m', '/FW/image/filetype/folder.png')
        vTree.loadImage('p', '/FW/image/filetype/file.png')
        vTree.loadImage('raiz', '/FW/image/filetype/file.png')
        vTree.loadImage('modulo', '/FW/image/filetype/folder.png')
        var Imagenes = vTree.imagenes

        function window_onload() {
            actualizar_tree()
            window_onresize()                           
        }

        var node_global_actual
        function actualizar_tree() {
            vTree = null
            vTree = new tTree('Div_vTree_0', "vTree");
            vTree.imagenes = Imagenes

            vTree.nvImages.onError_msg = null
            vTree.ChargeNodeOnchek = false
            vTree.getNodo_xml = tree_getNodo
            vTree.onNodeCharge = function (nodo_id) {
                if (nodo_id == '00000') {
                    this.MostrarArbol();
                    //this.nodos['0'].expand()
                }
            }
            //vTree.bloq_contenedor = $$("BODY")[0]
            vTree.async = true
            vTree.cargar_nodo('00000');
        }

        function tree_getNodo(nodo_id, oXML) {

                oXML.load("pki_nodos_tree.aspx", "nodoId=" + nodo_id + "&modo=loadTree")
           }



           function nodo_pki_onclick(nodo_id) {
                
               //var rs = new tRS()
               //rs.open("<criterio><select vista='verTree_nodos_pki'><campos>id,nodo_tipo</campos><orden></orden><filtro><nodo_id type='igual'>'" + nodo_id + "'</nodo_id></filtro></select></criterio>")
                
               var rs = new tRS();
               var parametros = "<criterio><params nodo_id= '" + nodo_id + "' /></criterio>"
               rs.open(nvFW.pageContents.ver_tree_nodo, '', '', '', parametros);

  
                var id
                var nodo_tipo

                if (!rs.eof()) {
                    id = rs.getdata("id")
                    nodo_tipo = rs.getdata("nodo_tipo")
                }

                if (nodo_tipo == 'R')
                    $('frm_nodos_tree').src = '/fw/pki/pki_mostrar.aspx?idpki=' + id
                if (nodo_tipo == 'M')
                    $('frm_nodos_tree').src = '/fw/pki/pki_carpetas_mostrar.aspx?id_carpeta=' + id
                if (nodo_tipo == 'P')
                    $('frm_nodos_tree').src = '/fw/pki/pki_certificados.aspx?idcert=' + id

                window_onresize()
         }


            //  function parametro_mostrar_return()
            //  {
            //    if(win.options.userData == 'refresh')
            //     {
            //       try
            //          {vTree[0].recargar_node(node_global)} 
            //       catch(e)
            //          {
            //           $(vTree[0].canvas).innerHTML = '' //resetea el div
            //           $(vTree[0].canvas).id = 'Div_vTree_0' // lo vuelve a su nombre original
            //           vTree.length = 0 // resetea la estructura
            //           window_onload() // vuelve a cargar
            //          }
            //     }  
            //  }

            function window_onresize() {
         
                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_height = $$('body')[0].getHeight()
                    var cab_height = $('divMenuABM').getHeight()
                    $('Div_vTree_0').setStyle({ height: body_height - cab_height - dif + 'px' })
                    $('divC2').setStyle({ height: body_height  + 'px', overflow: 'hidden' })


            }

            var win_pki

            function pki_abm() {
                var idpki = ''
                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                win_pki = nvFW.createWindow({ className: 'alphacube',
                    url: 'pki_ABM.aspx?modo=VA&idpki=' + idpki,
                    title: '<b>ABM PKI</b>',
                    minimizable: true,
                    maximizable: false,
                    draggable: true,
                    width: 500,
                    height: 180,
                    resizable: false,
                    onClose: win_pki_return
                });
                win_pki.options.userData = { idpki: idpki }
                win_pki.showCenter(true)

            }

        function win_pki_return() {
            var idpki = win_pki.options.userData.idpki
            if (idpki != 0) {
                actualizar_tree()
                $('frm_nodos_tree').src = 'pki_mostrar.aspx?idpki=' + idpki
            }
        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="margin: 0px;
    padding: 0px; width: 100%; height: 100%; overflow: hidden">

    <div id="divC1" style="width:50%;float:left">
    <table id='tb_cert' style='width:100%;height:100%' class='tb1'>
        <tr>
            <td style='width:100%;vertical-align:top'>
                <div id="divMenuABM">
                </div>
                <script type="text/javascript" language="javascript">
                    var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
                    Menus["vMenuABM"] = vMenuABM
                    Menus["vMenuABM"].alineacion = 'centro';
                    Menus["vMenuABM"].estilo = 'A';
                    Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                    Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='3' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>permiso</icono><Desc>Nueva PKI</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pki_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
                    Menus["vMenuABM"].loadImage('permiso', '/FW/image/icons/permiso.png')
                    vMenuABM.MostrarMenu()
                </script>
                <div id="Div_vTree_0" style="width: 100%; height:100%;vertical-align: text-top; overflow: auto">
                </div>
            </td>
        </tr>
    </table>
    </div>

    <div id="divC2" style="width:50%;float:left">
    <iframe id='frm_nodos_tree' src='/fw/enBlanco.htm' style="width: 100%;height:100%;border: 0px;"></iframe>
    </div>



</body>
</html>
