<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%   

    Me.contents("filtroCircuitos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='cire_circuito'><campos>distinct nro_circuito as id, circuito as [campo], circuito_aspx </campos><filtro></filtro><orden>[ID]</orden></select></criterio>")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Modulo Comentarios</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <script type="text/javascript" src="/FW/script/tParam_def.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var tabla_com_circuito;
        //window.alert = function (msg) {
        //    window.top.Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" });
        //}
        function window_onresize() {
            try {


                body_h = $$('BODY')[0].clientHeight;
                var divCircuito_h = $('divCircuito').getHeight();
                var filtroCircuito_h = $('filtroCircuito').getHeight();

                $('frame_circuito_estructura').style.height = (body_h - divCircuito_h - filtroCircuito_h) + 'px';
                tabla_com_circuito.resize();
            } catch (err) {

            }
        }

        function window_onload() {

            
            //campos_defs.set_first("nro_circuito")
           
            window_onresize();
        }

        function cargarCircuito(a, campo_def) {
            var page = "/fw/enBlanco.htm"
            var nro_circuito = campos_defs.get_value(campo_def)
            if (nro_circuito) {
            //Obtener aspx
                if (campos_defs.items[campo_def].input_select.selectedIndex > 0)
                    campos_defs.items[campo_def].rs.position = campos_defs.items[campo_def].input_select.selectedIndex - 1
            
                var circuito_aspx = campos_defs.items[campo_def].rs.getdata("circuito_aspx")

                if (circuito_aspx)
                    page = circuito_aspx
                else
                    nvFW.alert("La estructura no está definida.")
                    
            }

            $("frame_circuito_estructura").src = page + "?nro_circuito=" + nro_circuito
            //nvFW.exportarReporte({
            //    filtroXML: nvFW.pageContents.filtroCircuitoComRegistros,
            //    filtroWhere: '<criterio><select><filtro><nro_circuito type="igual">' + nro_circuito + '</nro_circuito><nro_com_tipo_origen type="isnull"></nro_com_tipo_origen></filtro></select></criterio>',
            //    bloq_contenedor: $('frame_circuito'),
            //    path_xsl: 'report/comentario/com_circuito.xsl',
            //    bloq_msg: 'Cargando...',
            //    formTarget: 'frame_circuito',
            //    nvFW_mantener_origen: true
            //    //parametros: '<parametros><nro_com_tipo_origen>0</nro_com_tipo_origen><nro_com_estado_origen>0</nro_com_estado_origen><tab>0</tab></parametros>',
            //})
        }


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="overflow: hidden;">
    <div id="divCircuito"></div>
    <script type="text/javascript">
        //var DocumentMNG = new tDMOffLine;
        var vCircuitos = new tMenu('divCircuito', 'vCircuitos');
        //vCircuitos.loadImage("guardar", '/FW/image/icons/guardar.png')
        vCircuitos.loadImage("abm", '/FW/image/icons/abm.png')
        Menus["vCircuitos"] = vCircuitos
        Menus["vCircuitos"].alineacion = 'centro';
        Menus["vCircuitos"].estilo = 'A';



        Menus["vCircuitos"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 90%;text-align:center; vertical-align:middle'>" +
                                        "<Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Circuitos Estructura</Desc></MenuItem>")


        vCircuitos.MostrarMenu()
    </script>

    <table class="tb1" id="filtroCircuito">
        <tr>
            <td class="Tit2" width="100px" >Circuito:</td>
            <td>
                <script type="text/javascript">
                    campos_defs.add("nro_circuito",
                        {
                            enDB: false,
                            nro_campo_tipo: 1,
                            filtroXML: nvFW.pageContents.filtroCircuitos,
                            onchange: cargarCircuito
                        })
                </script>
            </td>
        </tr>
    </table>
    
    <iframe id="frame_circuito_estructura" name="frame_circuito_estructura" style="width: 100%; height: 100%; border: none; overflow: hidden;" src="/fw/enBlanco.htm"></iframe>


</body>
</html>
