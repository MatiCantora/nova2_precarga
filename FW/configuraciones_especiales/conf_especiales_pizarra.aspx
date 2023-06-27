<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    
    Me.contents("filtroPizarra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_pizarras'><campos>*, nro_calc_pizarra as id</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_campoDef_pizarra") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_cab'><campos>nro_calc_pizarra as id, calc_pizarra as [campo]</campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtro_cab_pizarras") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_cab'><campos>*</campos><orden></orden></select></criterio>")
    
    Dim strSQL As String = "select distinct permiso_grupo from verConf_especial_pizarras"
    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
    While Not rs.EOF()
        Me.addPermisoGrupo(rs.Fields("permiso_grupo").Value)
        rs.MoveNext()
    End While
    
    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Configuraciones especiales pizarras</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var tablaPizarra = new tTable()
        var id_conf = '<%=id_conf %>'
        var mywin = nvFW.getMyWindowId()
        
        function window_onload() {
            tablaPizarra.nombreTabla = "tablaPizarra"
            tablaPizarra.filtroXML = nvFW.pageContents.filtroPizarra
            tablaPizarra.filtroWhere = "<id_cfg_especial type='igual'>"+id_conf+"</id_cfg_especial>"
            tablaPizarra.cabeceras = ["Nro Pizarra", "Pizarra", "Comen.", "Ver"]
            tablaPizarra.camposHide = [{ nombreCampo: "permiso_grupo" }, { nombreCampo: "nro_permiso_ver" }, { nombreCampo: "nro_permiso_editar"}]
            tablaPizarra.campos = [
                { nombreCampo: "id", width: "15%", editable: false, style: { 'textAlign': 'center' },
                    get_html: function(campo, nombreTabla) {  return (campo.valor != undefined ? campo.valor : 0) }
                },
                { nombreCampo: "calc_pizarra", width: "85%", id: "nro_calc_pizarra", nulleable: false,
                    get_campo: function(nombreTabla, id)
                    {
                        campos_defs.add(nombreTabla + "_campos_defs" + id,
                                    { nro_campo_tipo: 3, enDB: false, target: 'campos_tb_' + nombreTabla + id, filtroXML: nvFW.pageContents.filtro_campoDef_pizarra,
                                        filtroWhere: "<criterio><calc_pizarra type='in'>%campo_value%<calc_pizarra></criterio>", campo_codigo: "nro_calc_pizarra", campo_desc: "calc_pizarra"
                                    });
                        campos_defs.items[nombreTabla + "_campos_defs" + id]['onchange'] = validarCamposRepetidos
                    }
                },
               { nombreCampo: "comentario_rel_pizarra", ordenable: false, style: { 'align': 'center' }, editable: false, get_html: function(campo, nombreTabla)
               {
                   if (campo.fila) { $('campos_tb_tablaPizarra_fila_' + campo.fila + '_columna_1').title = campo.valor }
                   return "<div id='comentario_fila_" + campo.fila + "' title='" + (campo.valor != undefined ? campo.valor : "") + "' style='text-align:center;'><img onclick='comentario(\"" + campo.valor + "\",  " + campo.fila + ")' src='/FW/image/icons/comentario3.png' style='cursor:pointer; text-align:center'></img></div>"
               }
               },
               { nombreCampo: "Ver", ordenable: false, editable: false, enDB: false, get_html: function(campo, tabla) { return "<div style='text-align:center; width:3%' ><img onclick='verPizarra(" + campo.fila + ")' src='/FW/image/icons/editar.png' style='cursor:pointer; align:center'></img></div>" } }
            ];
            tablaPizarra.validar = function (){return validar()}

            if (!parent.permisosEditar()){                         
               tablaPizarra.eliminable = false
               tablaPizarra.mostrarAgregar = false
            }
           tablaPizarra.editable = false
           tablaPizarra.agregar_espacios_en_blanco_dir = function () { return agregar_espacios_en_blanco_dir()}
           tablaPizarra.table_load_html()
        
            window_onresize()
        }

        function verPizarra(fila) {
            var pizarra = tablaPizarra.getValor('nro_calc_pizarra', fila - 1)
            var permiso_grupo =  tablaPizarra.getValor('permiso_grupo', fila - 1)
            var nro_permiso = tablaPizarra.getValor('nro_permiso_ver', fila - 1)
            if (pizarra != '')
            {
                if (nvFW.tienePermiso(permiso_grupo, nro_permiso)) {
                    var win = top.nvFW.createWindow({
                                    url: "/fw/pizarra/calculos_pizarra_ABM.aspx?nro_calc_pizarra=" + pizarra,
                                    width: "1100",
                                    height: "400",
                                    top: "50"
                                })
                    win.showCenter()
                }
                 else{
                    alert("No tiene permisos para ver la pizarra seleccionada")
                 }
            }
        }

        function validarCamposRepetidos(e, campodef){
            var nuevo_valor = campos_defs.get_value(campodef)
            if (nuevo_valor == '') return

            for (var i = 0; i < tablaPizarra.cantFilas - 1; i++){
                if (tablaPizarra.getFila(i).nro_calc_pizarra == nuevo_valor && !tablaPizarra.data[i].tabla_control.eliminado) {
                    campos_defs.clear(campodef)
                    nvFW.top.alert("Ya existe este campo def en la configuración")
                    return
                }
            }
        }

//        function comentario(input, index){
//            var nro_pizarra = tablaPizarra.data[index].id       
//            if (parent.permisosEditar()){
//                var winComentario = nvFW.createWindow({ url: '/fw/configuraciones_especiales/conf_especiales_comentario.aspx?id_conf=' + nro_pizarra + '&configuracion=pizarra',
//                                            title: "<b>Comentario</b>", 
//                                            width: "400", 
//                                            height: "150",
//                                            onClose: function(win){   
//                                                if (win.cancelado == false) {
//                                                    if (win.texto != input) {
//                                                    try{
////                                                        $('comentario_fila_'+index).title =  win.texto 
////                                                        $('comentario_fila_'+index).value = win.texto
////                                                        tablaPizarra.data[index].comentario_rel_pizarra = win.texto
//                                                        //                                                        tablaPizarra.data[index].tabla_control["modificado"] = true
//                                                        tablaPizarra.refresh()
//                                                    } catch (e){}
//                                                    }
//                                                }
//                                            }
//                                        })
//                                         winComentario.showCenter()
//            }
//            else{
//            nvFW.alert('No tiene permisos para editar el comentario')}
//    }


    function comentario(input, index){     
        if (parent.permisosEditar())
        {
            var winComentario = nvFW.createWindow({ url: '/fw/configuraciones_especiales/conf_especiales_comentario.aspx?texto=' + input,
                title: "<b>Comentario</b>",
                width: "400",
                height: "150",
                onClose: function(win){
                    if (win.cancelado == false){
                        if (win.texto != input) {
                            try {
                                $('comentario_fila_' + index).title = win.texto
                                tablaPizarra.data[index].comentario_rel_pizarra = win.texto
                                tablaPizarra.data[index].tabla_control["modificado"] = true
                                 
                                var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><configuraciones modo='E' id='" + parent.id_conf + "' nombre='" + parent.campos_defs.get_value("nombre") + "' comentario='" + parent.campos_defs.get_value("comentario") + "'>"
                                xmldato += tablaPizarra.generarXML("pizarras")
                                xmldato += "<transferencias /><parametros/><camposdef /></configuraciones>"
                                  
                                nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                    onSuccess: function(err, transport)
                                    {
                                        tablaPizarra.refresh()
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


    function agregar_espacios_en_blanco_dir(){                                         
        var row_index = 0  , cell_index = 0;
        var valores_campos = [];

        valores_campos[cell_index] = false;
        valores_campos[cell_index + 1] = false;
        valores_campos[cell_index + 2] = false;
        valores_campos[cell_index + 3] = false;

        tablaPizarra.agregar_fila(valores_campos);
        tablaPizarra.resize()
        var campo_def =  "tablaPizarra_campos_defs_fila_" + (tablaPizarra.cantFilas - 1).toString() + "_columna_1"
        campos_defs.onclick(event, campo_def)
    }
  

        function validar(){    
           for (var row_index = 1; row_index < tablaPizarra.cantFilas; row_index++) {
                //Si NO es valido retornamos false
                var fila = tablaPizarra.getFila(row_index)
                if (fila.calc_pizarra == '' && !tablaPizarra.data[row_index].tabla_control.eliminado){
                    return false
                    }
            }
            return true
        }
      
        function window_onresize(){
            try{    
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                $('div_tabla').setStyle({ 'height': body_h - dif })
                tablaPizarra.resize()
            }
            catch (e) { }
        }
        
    </script>
    
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden">
    <div id="div_tabla" style="width: 100%; height: 100%; overflow: auto">
    <div id="tablaPizarra" name="tablaPizarra" style="width: 100%; height: 100%; overflow: hidden"></div></div>     
</body>
</html>