<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("filtro_campodef_mutual") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verAux_banco_mutual_grupo'><campos>nro_mutual as id, mutual as [campo]</campos><filtro></filtro><orden>mutual</orden><grupo>nro_mutual, mutual</grupo></select></criterio>")
    Me.contents("ver_procesos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select PageSize='15' AbsolutePage='1'  vista='verProcesos '><campos>*</campos><orden>nro_proceso</orden><filtro></filtro></select></criterio>")
     
    Dim nro_proceso = nvUtiles.obtenerValor("nro_proceso", "")
    Dim tipo_proceso = nvUtiles.obtenerValor("tipo_proceso", "")
    
    %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Administracion Procesos ABM</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
     <% =Me.getHeadInit()%>
<script>

   var nro_proceso =  '<%= nro_proceso %>'
   var tipo_proceso =  '<%= tipo_proceso %>'
   var criterio = ''
    
    function window_onload(){     
        campos_defs.add('fe_desde_proceso', { nro_campo_tipo: 103, target: 'td_fe_desde_proceso', enDB: false })
        campos_defs.add('fe_hasta_proceso', { nro_campo_tipo: 103, target: 'td_fe_hasta_proceso', enDB: false })
        campos_defs.add('nro_mutual', { nro_campo_tipo: 1, target: 'td_nro_mutual', enDB: false, filtroXML: nvFW.pageContents.filtro_campodef_mutual })
      
        campos_defs.set_value('nro_proceso', nro_proceso)
        campos_defs.set_value('tipo_procesos', "'"+tipo_proceso+"'") 
      
        window_onresize()
  
        var hoy = new Date();
        $('fe_desde_proceso').value = FechaToSTR(hoy, 1)
        $('fe_hasta_proceso').value = FechaToSTR(hoy, 1)
    }  
    
    function MostrarProcesos(){     
        if($('fe_desde_proceso').value == ''){
            alert('Ingrese una "Fecha desde" para realizar la búsqueda')
            return
        } 
 
        if($('fe_hasta_proceso').value == '' ){
            alert('Ingrese una "Fecha Hasta" para realizar la búsqueda')
            return
        } 
       
        var fecha_desde = $('fe_desde_proceso').value
        var fecha_hasta = $('fe_hasta_proceso').value

        var nro_mutual = $('nro_mutual').value
        var nro_sistema = $('nro_sistema').value
        var nro_lote = $('nro_lote').value
        var nro_credito = $('nro_credito').value
        var nro_proceso = campos_defs.get_value('nro_proceso')

        var nro_operador = $('nro_operador').value
        var nro_estado = campos_defs.get_value("estado_procesos")
        var obtener_pr_credito = 'null'

       
        criterio = "<fecha_proceso type='mas'>convert(datetime,'" + fecha_desde + "',103)</fecha_proceso>"
    
        if (fecha_hasta != '')
            criterio = criterio + "<fecha_proceso type='menor'>dateadd(dd,1,convert(datetime,'" + fecha_hasta + "',103))</fecha_proceso>"

        if (nro_mutual != '')
            criterio = criterio + "<nro_mutual type='igual'>" + nro_mutual + "</nro_mutual>"

        if (nro_sistema != '')
            criterio = criterio + "<nro_sistema type='igual'>" + nro_sistema + "</nro_sistema>"

        if (nro_lote != '')
            criterio = criterio + "<nro_lote type='igual'>" + nro_lote + "</nro_lote>"

        if (nro_credito != ''){
            criterio = criterio + "<nro_credito type='igual'>" + nro_credito + " </nro_credito>"          
            }

        if (campos_defs.get_value("tipo_procesos") != '')
            criterio = criterio + '<tipo_proceso type="in">' + campos_defs.get_value("tipo_procesos") + '</tipo_proceso>'
    
        if (nro_operador != '')
            criterio = criterio + '<operador type="igual">' + nro_operador + '</operador>'
        
        if (nro_estado)
            criterio = criterio + '<pr_estado type="igual">' + campos_defs.get_value("estado_procesos") + '</pr_estado>'

        if (nro_proceso > 0)
            criterio = criterio + '<nro_proceso type="igual">' + nro_proceso + '</nro_proceso>'        

        nvFW.exportarReporte({filtroXML: nvFW.pageContents.ver_procesos,
                            filtroWhere: "<criterio><select><filtro>" + criterio + "</filtro></select></criterio>", 
                            path_xsl: 'report/verProcesos/HTML_verProcesos.xsl',
                            formTarget: 'FrameResultado',
                            bloq_contenedor: $('FrameResultado'),
                            cls_contenedor: 'FrameResultado',
                            nvFW_mantener_origen: true,
                            id_exp_origen: 0
                        })
    }                               

    function actualizar_estado_proceso() {
        var rs = new tRS()
        rs.asyn = true
        rs.onComplete = function(){
            if (!rs.eof()){
                var nro_proc = rs.getdata('nro_proceso')
                var porcent = rs.getdata('porc_ejec')
                $(nro_proc).innerText = porcent + '%' //(porcent, '0.00') + '%'
                rs.movenext()
            }

            return window.setTimeout('parent.actualizar_estado_proceso()', 3000)
        }

        rs.open(nvFW.pageContents.ver_procesos, '', criterio + "<pr_estado type='igual'>2</pr_estado>")
    }

    function window_onresize(){           
        var dif = Prototype.Browser.IE ? 5 : 2
        body_heigth = $$('body')[0].getHeight()
        cab_heigth = $('divFiltro').getHeight()
        $('FrameResultado').setStyle({'height': body_heigth - cab_heigth - dif })
     }

</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; width:100%; overflow: hidden;margin: 0px; padding: 0px">
<div id="divFiltro" style="margin: 0px; padding: 0px;width:100%">
<div id="divMenu" style="margin: 0px; padding: 0px" ></div>
    <script type="text/javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenu = new tMenu('divMenu', 'vMenu');
     Menus["vMenu"] = vMenu
     Menus["vMenu"].alineacion = 'centro';
     Menus["vMenu"].estilo = 'A';
     Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 10%; text-align:center; vertical-align:middle'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>MostrarProcesos()</Codigo></Ejecutar></Acciones></MenuItem>")
     Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 80%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
     vMenu.loadImage('buscar','/FW/image/icons/buscar.png')
     vMenu.MostrarMenu()
    </script>
    <table class="tb1" style="width: 100%">
        <tr>
            <td class="Tit1" style="width: 10%">Fecha Desde:</td>
            <td style="width: 13%" id="td_fe_desde_proceso"></td>
            <td class="Tit1" style="width: 10%">Fecha Hasta:</td>
            <td style="width: 13%" id="td_fe_hasta_proceso"></td>
            <td class="Tit1" style="width: 10%">Mutual:</td>
            <td style="width: 23%" id='td_nro_mutual'></td>
            <td class="Tit1" style="width: 20%">&nbsp;</td>
        </tr>
    </table>
    <table class="tb1" style="width: 100%">
        <tr>
            <td class="Tit1" style="width: 10%">Sistema:</td>
            <td style="width: 25%"> <%= nvFW.nvCampo_def.get_html_input("nro_sistema")%></td>
            <td class="Tit1" style="width: 10%">Lote:</td>
            <td style="width: 25%"><%= nvFW.nvCampo_def.get_html_input("nro_lote")%></td>
            <td class="Tit1" style="width: 10%">Nro Crédito:</td>
            <td style="width: 20%"><input type="text" name="nro_credito" id="nro_credito" style="width: 100%" onkeypress='return valDigito(event)' /></td>
        </tr>
    </table>
    <table class="tb1" style="width: 100%">
        <tr>
            <td rowspan="1" class="Tit1" style="width: 10%">Tipo proceso:</td>
            <td rowspan="1" style="width: 40%"> <%= nvFW.nvCampo_def.get_html_input("tipo_procesos")%></select></td>
            <td class="Tit1" style="width: 10%">Operador:</td>
            <td style="width: 40%"> <%= nvFW.nvCampo_def.get_html_input("nro_operador")%></td>
        </tr>
        <tr>
            <td class="Tit1" style="width: 10%">Estado:</td>
            <td><%= nvFW.nvCampo_def.get_html_input("estado_procesos")%></td>
            <td class="Tit1" style="width: 10%">Nro. Proceso:</td>
            <td><%=nvFW.nvCampo_def.get_html_input("nro_proceso", nro_campo_tipo:=100, enDB:=False)%> </td>
        </tr>
    </table>
</div>
<iframe name="FrameResultado" id="FrameResultado" style='height:100%; width:100%;overflow:hidden' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</body>
</html>
