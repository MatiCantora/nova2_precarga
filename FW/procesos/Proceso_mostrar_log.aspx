<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 

    Dim nro_proceso = nvFW.nvUtiles.obtenerValor("nro_proceso", 0)
    Dim pr_estado = nvFW.nvUtiles.obtenerValor("pr_estado", 0)
    
    Me.contents("filtro_verProcesos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verProcesos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroProceso_log") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select PageSize='16' AbsolutePage='1' vista='Proceso_log'><campos>*</campos><orden>id_plog</orden><filtro></filtro></select></criterio>")
    Me.contents("filtroProceso_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.rm_ver_detalle_proceso'  CommantTimeOut='1500' vista='Proceso_log'><parametros><nro_proceso DataType='int'>%nro_proceso%</nro_proceso></parametros></procedure></criterio>")
    Me.contents("procesos_ejecutados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verProceso_trasferencia'><campos>*</campos><orden></orden></select></criterio>")
    Dim filtro_infocredito = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='wrp_infocredito_base'><campos>tipo_docu,documento,sexo,strNombreCompleto</campos><filtro></filtro><orden></orden></select></criterio>")
%>
<html>
<head>
<title>Administracion Procesos ABM Log</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js" language='javascript'></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
     <% =Me.getHeadInit()%>
    <script type="text/javascript" language="javascript">

        var nro_proceso = '<%=nro_proceso %>'
        var pr_estado = '<%=pr_estado %>'
        var tipo_proceso
        var filtro_infocredito = '<%= filtro_infocredito %>'
          
        function window_onload() {
            vListButtons.MostrarListButton()
            ArmarCabecera()
            window_onresize()
        }

    function ArmarCabecera(){
          var rs = new tRS();
          rs.open(nvFW.pageContents.filtro_verProcesos, '', "<nro_proceso type='igual'>" + nro_proceso + "</nro_proceso>")
          
          if (!rs.eof()){
              pr_estado =  rs.getdata('pr_estado')
              cantidad_registros =  rs.getdata('cantidad_registros')
              observaciones = (rs.getdata('observaciones')) ? rs.getdata('observaciones').toUpperCase() : ''
              observaciones = (observaciones.length >= 120) ? observaciones.substring(1, 120) : observaciones;
              tipo_proceso = rs.getdata('tipo_proceso')  
              $('num_proceso').innerText =  rs.getdata('nro_proceso')
              $('tipo_proceso').innerText = rs.getdata('tipo_proceso_desc')
              $('fecha').innerText = FechaToSTR(parseFecha(rs.getdata('fecha_proceso')))
              $('comentario').innerText = observaciones
              $('estado').innerText = rs.getdata('pr_estado_desc')
              $('operador').innerText = rs.getdata('nombre_operador')
//               if ((pr_estado == 1) || (pr_estado == 4))
//                if (nvFW.tienePermiso('permisos_procesar',4))  
//                    strHTML = strHTML + "<td style='width:33%'><input type='button' id='btn_Eliminar' name='btn_Eliminar' value='Anular Proceso' onclick='Eliminar_Proceso_Confirma()' style='width: 100%' /></td>"
            }
          
          if (pr_estado == 2)
             MostrarProceso_detalle()
    }

    function MostrarProceso_detalle(){     
        var pr_estado_control = pr_estado
        var criterio = ''
//        if (pr_estado == 1 || pr_estado == 3) {
            filtroXML = nvFW.pageContents.filtroProceso_detalle
                                    
            nvFW.exportarReporte({       
                filtroXML: filtroXML,
                path_xsl: "report/verProcesos/HTML_Proceso_log.xsl",
                params: "<criterio><params nro_proceso ='" + nro_proceso + "' /></criterio>",
                formTarget: 'ifProceso_log',
                bloq_contenedor: $('ifProceso_log'),
                cls_contenedor: 'ifProceso_log',
                nvFW_mantener_origen: true,
                id_exp_origen: 0
            })
//        }
//        else{
//                $('divEjecucion').innerHTML = ""
//                var strHTML_barra = "<table width='100%'><tr><td id='tdbarra' style='background-color: gray; text-align: right'>&nbsp;</td><td id='tdbarra2' style='background-color: red; width: 100%'></td></tr></table>"
//                strHTML = "<table class='tb1'><tr><td class='TIT1'>Estado:</td><td><b><font color='red'>" + pr_estado_desc + "</font></b></td><td style='width: 100%'>" + strHTML_barra + "</td></tr></table>"
//                $('divEjecucion').insert({ 'top': strHTML })
//                $('divEjecucion').style.display = 'inline'  
//                actualizar_barra()       
            //        }

    }

    function MostrarProceso_log(){       
        nvFW.exportarReporte({
            filtroXML: nvFW.pageContents.filtroProceso_log,
            filtroWhere: "<criterio><select><campos></campos><filtro><nro_proceso type='igual'>" + parseInt(nro_proceso) + "</nro_proceso></filtro></select></criterio>",
            path_xsl: "report/verProcesos/HTML_Proceso_log_proceso.xsl",
            formTarget: 'ifProceso_log',
            bloq_contenedor: $('ifProceso_log'),
            cls_contenedor: 'ifProceso_log',
            nvFW_mantener_origen: true ,
            id_exp_origen: 0
        })
    }

    var strHTML = ''
    var strBarra = ''

    var x = 0
    var pr_estado_control

    function actualizar_barra(){  
        if (pr_estado == 2){
              var rs = new tRS();
              rs.open(nvFW.pageContents.filtro_verProcesos, '', "<nro_proceso type='igual'>" + nro_proceso + "</nro_proceso>")
              
              if (!rs.eof()) {
                registro_actual = rs.getdata('registro_actual')   
                cantidad_registros = rs.getdata('cantidad_registros')          
                pr_estado = rs.getdata('pr_estado')
                var porc = registro_actual * 100 / cantidad_registros 
                if (porc < 100){
                      $('tdbarra2').setStyle({width : (100 - porc) + '%'})
                      $('tdbarra').innerText = porc.toFixed(2) + '%'
                      window.setTimeout('actualizar_barra()', 1000)
                  }
                else{                    
                    $('divEjecucion').innerHTML = ""
                    window.setTimeout('actualizar_barra()', 1000)        
                  }  
        
                }
        }
        else{
            ArmarCabecera()    
            MostrarProceso_log()       
          }        
        }

    var id_ventana_proc
    var win
    function Eliminar_Proceso_Confirma(){
        var Proceso = new Array()
        Proceso["nro_proceso"] = nro_proceso
        Proceso["tipo_proceso"] = tipo_proceso
        Proceso["usuario"] = usuario
        win = window.top.nvFW.createWindow({ title: '<b>Proceso Log</b>',
                                             minimizable: false,
                                             maximizable: false,
                                             draggable: false,
                                             width: 500,
                                             height: 250,
                                             resizable: false,
                                             Proceso: Proceso,
                                             onClose: Eliminar_Proceso_Confirma_return
                                          });
    
        var url = '/FW/procesos/Proceso_anular.aspx?id_ventana=' + win.getId() 
        win.setURL(url)
        win.showCenter(true)
     }

     function anular_proceso(){
         var win = window.top.nvFW.createWindow({ title: '<b>Anular Proceso</b>',
             minimizable: false,
             maximizable: false,
             draggable: false,
             width: 500,
             height: 250,
             resizable: false,
             onClose: Eliminar_Proceso_Confirma_return
         });

         var url = '/FW/procesos/Proceso_anular.aspx?nro_proceso=' + nro_proceso + "&tipo_proceso="  + tipo_proceso
         win.setURL(url)
         win.returnValue  = ''
         win.showCenter(true)

     }

     function Eliminar_Proceso_Confirma_return() {
         try{
            if (win.returnValue == 'ANULADO')
                ArmarCabecera()
        }
        catch(e){
        }
     }

     function ver_transferencia(){            
         nvFW.exportarReporte({
             filtroXML: nvFW.pageContents.procesos_ejecutados
            , filtroWhere: "<criterio><select PageSize='14' AbsolutePage='1'><filtro><nro_proceso type='igual'>" + nro_proceso + "</nro_proceso></filtro></select></criterio>"
            , path_xsl: "report\\perfiles_batch\\verProceso_batch_transf.xsl"
            , formTarget: 'ifProceso_log'
            , nvFW_mantener_origen: true
            , id_exp_origen: 0
            , bloq_contenedor:  $('ifProceso_log')
            , cls_contenedor: 'ifProceso_log'
         })
     }


     function window_onresize() {
         try {
             var dif = Prototype.Browser.IE ? 5 : 2
             body_height = $$('body')[0].getHeight()
             cab_height = $('divCabecera').getHeight()
             $('ifProceso_log').setStyle({ 'height': body_height - cab_height - 30 - dif })
         }
         catch (e) { }
     }

     function mostrar_transf(id_transf_log){
         var win_seg = window.top.nvFW.createWindow({
             url: '/fw/transferencia/transf_seguimiento_pool_control_exec.aspx?id_transf_log=' + id_transf_log,
             minimizable: false,
             maximizable: true,
             draggable: true,
             width: 800,
             height: 350,
             resizable: true,
             destroyOnClose: true
         })

         win_seg.showCenter()
     }

 
</script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; width: 100%; overflow: hidden; margin: 0px; padding: 0px">
    <div id="divMenu" style="margin: 0px; padding: 0px" ></div>
    <script type="text/javascript">
        var DocumentMNG = new tDMOffLine;
        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Información del proceso</Desc></MenuItem>")
        vMenu.MostrarMenu()
    </script>
    <table class="tb1" id="divCabecera">
        <tr>
            <td class='TIT1' style='width:20%'>Nro. Proceso:</td>
            <td style='width:20%' id="num_proceso"></td>
            <td class='TIT1' style='width:20%'>Tipo Proceso:</td>
            <td id="tipo_proceso"></td>
        </tr>
        <tr>
            <td class='TIT1'>Fecha Proceso:</td>
            <td id="fecha"></td>
            <td class='TIT1'>Operador:</td>
            <td id="operador"></td>
        </tr>
        <tr>
            <td class='TIT1' >Comentario:</td>
            <td colspan='3' id="comentario" title=''></td>
        </tr>
        <tr>
            <td class='TIT1'>Estado:</td>
            <td id="estado"></td>
            <td colspan="2">
        </tr>
        <tr>
            <td style="width:25%;"><div id="divLog" style="width:100%;"></div></td>
            <td style="width:25%;"><div id="divDetalle" style="width:100%;"></div></td>
            <td style="width:25%;"><div id="divTransferencia" style="width:100%;"></div></td>
            <td style="width:25%;"><div id="divAnular" style="width:100%;"></div></td>
        </tr>
    </table>
    <script>
        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Log";
        vButtonItems[0]["etiqueta"] = "Ver Log";
        vButtonItems[0]["imagen"] = "detalle";
        vButtonItems[0]["onclick"] = "return MostrarProceso_log()";
        vButtonItems[1] = {}
        vButtonItems[1]["nombre"] = "Detalle";
        vButtonItems[1]["etiqueta"] = "Ver Detalle";
        vButtonItems[1]["imagen"] = "detalle";
        vButtonItems[1]["onclick"] = "return MostrarProceso_detalle()";
        vButtonItems[2] = {}
        vButtonItems[2]["nombre"] = "Anular";
        vButtonItems[2]["etiqueta"] = "Anular Proceso";
        vButtonItems[2]["imagen"] = "anular";
        vButtonItems[2]["onclick"] = "return anular_proceso()";
        vButtonItems[3] = {}
        vButtonItems[3]["nombre"] = "Transferencia";
        vButtonItems[3]["etiqueta"] = "Ver Transferencia";
        vButtonItems[3]["imagen"] = "transferencia";
        vButtonItems[3]["onclick"] = "return ver_transferencia()";
        
        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage('transferencia', '/FW/image/icons/procesar.png')
        vListButtons.loadImage('anular', '/FW/image/icons/cancelar.png')
        vListButtons.loadImage('detalle', '/FW/image/icons/nueva.png')
    </script>
    <iframe name="ifProceso_log" id="ifProceso_log" style='height: 100%; width: 100%; overflow: hidden' frameborder="0" src="/fw/enBlanco.htm"></iframe>
</body>
</html>
