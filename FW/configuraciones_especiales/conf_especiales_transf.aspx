<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    
    Me.contents("filtroTransferencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_transferencia'><campos>id_transferencia, id_transferencia as id, nombre, comentario_rel_transf</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_campoDef_transferencia") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_cab'><campos>id_transferencia as id, nombre as [campo]</campos><orden>[id]</orden></select></criterio>")

    Me.addPermisoGrupo("permisos_transferencia")
    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Configuraciones especiales transferencia</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit()%>
    
    
    <script type="text/javascript">

        var tablaTransferencia = new tTable()
        var id_conf = '<%=id_conf %>'
        
        function window_onload(){
            tablaTransferencia.nombreTabla = "tablaTransferencia"
            tablaTransferencia.filtroXML = nvFW.pageContents.filtroTransferencia
            tablaTransferencia.filtroWhere = "<id_cfg_especial type='igual'>" + id_conf + "</id_cfg_especial>"
            tablaTransferencia.cabeceras = ["Nro Transf.", "Transferencia", "Comen.", "Ver"]
            tablaTransferencia.campos = [
                { nombreCampo: "id", width: "15%", editable: false, style: { 'textAlign': 'center' },
                    get_html: function(campo, nombreTabla) { return (campo.valor != undefined ? campo.valor : 0) }
                 },
                { nombreCampo: "nombre", id: "id_transferencia", width: "85%",
                    get_campo: function(nombreTabla, id)
                    {
                        campos_defs.add(nombreTabla + "_campos_defs" + id,
                                    { nro_campo_tipo: 3, enDB: false, target: 'campos_tb_' + nombreTabla + id, 
                                        filtroXML: nvFW.pageContents.filtro_campoDef_transferencia,
                                        filtroWhere: "<nombre type='in'>%campo_value%<nombre>", campo_codigo: "id_transferencia", campo_desc: "nombre"
                                    })
                        campos_defs.items[nombreTabla + "_campos_defs" + id]['onchange'] = validarCamposRepetidos 
                    }
                },
                { nombreCampo: "comentario_rel_transf", ordenable: false, style: { 'align': 'center' }, editable: false, get_html: function(campo, nombreTabla){
                 if (campo.fila) { $('campos_tb_tablaTransferencia_fila_' + campo.fila + '_columna_1').title = campo.valor }
                  return "<div id='comentario_fila_" + campo.fila + "' title='" + (campo.valor != undefined ? campo.valor : "") + "' style='text-align:center;'><img onclick='comentario(\"" + campo.valor + "\",  " + campo.fila + ")' src='/FW/image/icons/comentario3.png' style='cursor:pointer; text-align:center'></img></div>"
              }},
                {
                  nombreCampo: "Ver", width: "5%", editable: false, ordenable: false, enDB: false, 
              get_html: function(campo, tabla) { return "<div style='text-align:center; width:3%' ><img onclick='verTransferencia(" + campo.fila + ")' src='/FW/image/icons/editar.png' style='cursor:pointer; text-align:center'></img></div>" } }
            ];
            tablaTransferencia.validar = function() { return validar() }

           if (!parent.permisosEditar())
            {     
                tablaTransferencia.eliminable = false
               tablaTransferencia.mostrarAgregar = false
           }
           tablaTransferencia.agregar_espacios_en_blanco_dir = function() { return agregar_espacios_en_blanco_dir() }
           tablaTransferencia.editable = false
           tablaTransferencia.table_load_html()
       }

       function verTransferencia(fila){
           var id_transferencia = tablaTransferencia.getValor('id_transferencia', fila - 1)
           
           if ( nvFW.tienePermiso("permisos_transferencia", 1)) {
               if (id_transferencia > 0) {
                   window.open("/fw/transferencia/transferencia_abm.aspx?id_transferencia=" + id_transferencia)
               }
           }
           else
               alert('No posee permisos para ver esta transferencia. Consulte con el Administrador del Sistema.')
       }

       function validarCamposRepetidos(e, campodef){
           var nuevo_valor = campos_defs.get_value(campodef)
           if (nuevo_valor == '') return

           for (var i = 0; i < tablaTransferencia.cantFilas - 1; i++)
           {
               if (tablaTransferencia.getFila(i).id_transferencia == nuevo_valor && !tablaTransferencia.data[i].tabla_control.eliminado)
               {
                   campos_defs.clear(campodef)
                   nvFW.top.alert("Ya existe esta transferencia en la configuración")
                   return
               }
           }
       }

       function comentario(input, index){  
            if (parent.permisosEditar()){
                var winComentario = nvFW.createWindow({ url: '/fw/configuraciones_especiales/conf_especiales_comentario.aspx?texto=' + input,
                   title: "<b>Comentario</b>",
                   width: "400",
                   height: "150",
                   onClose: function(win)
                   {
                       if (win.cancelado == false)
                       {
                           if (win.texto != input)
                           {
                               try
                               {
                                   $('comentario_fila_' + index).title = win.texto
                                   tablaTransferencia.data[index].comentario_rel_transf = win.texto
                                   tablaTransferencia.data[index].tabla_control["modificado"] = true

                                   var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><configuraciones modo='E' id='" + parent.id_conf + "' nombre='" + parent.campos_defs.get_value("nombre") + "' comentario='" + parent.campos_defs.get_value("comentario") + "'>"
                                   xmldato += tablaCampos.generarXML("transferencias")
                                   xmldato += "<pizarras /><camposdef /><parametros/></configuraciones>"

                                   nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                       onSuccess: function(err, transport)
                                       {
                                           tablaTransferencia.refresh()
                                       }
                                   })

                               } catch (e) { }
                           }
                       }
                   }
               })
               winComentario.showCenter()
           }
           else
           {
               nvFW.alert('No tiene permisos para editar el comentario')
           }
       }

       function validar() {
            for (var row_index = 1; row_index < tablaTransferencia.cantFilas; row_index++)
            {
                //Si NO es valido retornamos false
                var fila = tablaTransferencia.getFila(row_index)
                if (fila.nombre == '' && !tablaTransferencia.data[row_index].tabla_control.eliminado)
                {
                    return false
                }
            }
            return true
        }

        function agregar_espacios_en_blanco_dir()
        {
            var row_index = 0, cell_index = 0;
            var valores_campos = [];

            valores_campos[cell_index] = false;
            valores_campos[cell_index + 1] = false;
            valores_campos[cell_index + 2] = false;
            valores_campos[cell_index + 3] = false;
                         
            tablaTransferencia.agregar_fila(valores_campos);
            tablaTransferencia.resize()
            var campo_def = "tablaTransferencia_campos_defs_fila_" + (tablaTransferencia.cantFilas - 1).toString() + "_columna_1"
            campos_defs.onclick(event, campo_def)
        }

        function window_onresize(){
            try{
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                $('div_tabla').setStyle({ 'height': body_h - dif })
                tablaTransferencia.resize()
            }
            catch (e) { }
        }
        
    </script>
    
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden">
       <div id="div_tabla" style="width: 100%; height: 100%; overflow: auto">
        <div id="tablaTransferencia" name="tablaTransferencia" style="width: 100%; height: 100%; overflow: hidden"></div></div>     
</body>
</html>