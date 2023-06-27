<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    
    Me.contents("filtrocampoDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_campoDef'><campos>id_rel, id_cfg_especial, comentario_rel_campo, campo_def, CONCAT(descripcion,'(' ,campo_def, ')') descripcion</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_campoDef_campodef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Campos_def'><campos>campo_def as id, descripcion as [campo]</campos><orden>[campo]</orden></select></criterio>")

    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Configuraciones especiales Campos Def</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var tablaCampos = new tTable()
        var id_conf = '<%=id_conf %>'

        function window_onload()
        {
            tablaCampos.nombreTabla = "tablaCampos"
            tablaCampos.filtroXML = nvFW.pageContents.filtrocampoDef
            tablaCampos.filtroWhere = "<id_cfg_especial type='igual'>" + id_conf + "</id_cfg_especial>"
            tablaCampos.cabeceras = ["Campo Def", "Comen.", "Ver"]
            tablaCampos.campos = [
                {nombreCampo: "descripcion", id: "campo_def", width: "85%",
                    get_campo: function(nombreTabla, id)
                    {
                        campos_defs.add(nombreTabla + "_campos_defs" + id,
                                        { nro_campo_tipo: 3, enDB: false, target: 'campos_tb_' + nombreTabla + id, filtroXML: nvFW.pageContents.filtro_campoDef_campodef,
                                            filtroWhere: "<campo_def type='in'>%campo_value%<campo_def>", campo_codigo: "campo_def", campo_desc: "descripcion"
                                        })
                        campos_defs.items[nombreTabla + "_campos_defs" + id]['onchange'] = validarCamposRepetidos 
                    }
                },
                { nombreCampo: "comentario_rel_campo", ordenable: false, style: { 'align': 'center' }, editable: false, get_html: function(campo, nombreTabla){
                    if (campo.fila) {$('campos_tb_tablaCampos_fila_' + campo.fila + '_columna_0').title = campo.valor }
                    return "<div id='comentario_fila_" + campo.fila + "' title='" + (campo.valor != undefined  ? campo.valor : "") + "' style='text-align:center;'><img onclick='comentario(\"" + campo.valor + "\",  " + campo.fila + ")' src='/FW/image/icons/comentario3.png' style='cursor:pointer; text-align:center'></img></div>"
                }
                },
               { nombreCampo: "Ver", width: "5%", editable:false, ordenable: false, enDB: false, get_html: function(campo, tabla) { return "<div style='text-align:center; width:3%' ><img onclick='verCampoDef("+campo.fila+")' src='/FW/image/icons/editar.png' style='cursor:pointer; align:center'></img></div>" } }
            ];
           tablaCampos.validar = function() { return validar() }
           if (!parent.permisosEditar())
           {     
                tablaCampos.eliminable = false
               tablaCampos.mostrarAgregar = false
            }
           tablaCampos.editable = false
           tablaCampos.agregar_espacios_en_blanco_dir = function() { return agregar_espacios_en_blanco_dir() }
           tablaCampos.table_load_html()
       }


       function agregar_espacios_en_blanco_dir()
       {
           var row_index = 0, cell_index = 0;
           var valores_campos = [];

           valores_campos[cell_index] = false;
           valores_campos[cell_index + 1] = false;
           valores_campos[cell_index + 2] = false;
           valores_campos[cell_index + 3] = false;
                              
           tablaCampos.agregar_fila(valores_campos);
           tablaCampos.resize()
           var campo_def = "tablaCampos_campos_defs_fila_" + (tablaCampos.cantFilas - 1).toString() + "_columna_0"
           campos_defs.onclick(event, campo_def)
       }

       function verCampoDef(fila){    
           var campodef = tablaCampos.getValor('campo_def', fila - 1)
//           if(campodef != ''){
               var win = top.nvFW.createWindow(
                            {
                                url: "/fw/campo_def/campos_def_listar.aspx?campo_def=" + campodef,
                                width: "1100",
                                height: "400",
                                top: "50"
                            }
                        )
               win.showCenter()
//          }
       }

       function validarCamposRepetidos(e, campodef) {   
           var nuevo_valor = campos_defs.get_value(campodef)
           if (nuevo_valor == '') return

           for (var i = 0; i < tablaCampos.cantFilas-1; i++){
               if (tablaCampos.getFila(i).campo_def == nuevo_valor && !tablaCampos.data[i].tabla_control.eliminado){
                   campos_defs.clear(campodef)
                   nvFW.top.alert("Ya existe este campo def en la configuración")
                   return
                   }
           }
       }

        function validar(){
            for (var row_index = 1; row_index < tablaCampos.cantFilas; row_index++)
            {
                //Si NO es valido retornamos false
                var fila = tablaCampos.getFila(row_index)
                if (fila.descripcion == '' && !tablaCampos.data[row_index].tabla_control.eliminado)
                {
                    return false
                }
            }
            return true
        }


        function comentario(input, index)  {
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
                                    tablaCampos.data[index].comentario_rel_campo = win.texto
                                    tablaCampos.data[index].tabla_control["modificado"] = true

                                    var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><configuraciones modo='E' id='" + parent.id_conf + "' nombre='" + parent.campos_defs.get_value("nombre") + "' comentario='" + parent.campos_defs.get_value("comentario") + "'>"
                                    xmldato += tablaCampos.generarXML("camposdef")
                                    xmldato += "<pizarras /><transferencias /><parametros/></configuraciones>"

                                    nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                        onSuccess: function(err, transport)
                                        {
                                           tablaCampos.refresh()
                                        }
                                    })

                                } catch (e) { }
                            }
                        }
                    }
                })
                winComentario.showCenter()
            }
            else {
                nvFW.alert('No tiene permisos para editar el comentario')
            }
        }

        function window_onresize(){
            try {              
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divCab_h = $('divFiltroDatos').getHeight()
                $('div_tabla').setStyle({ 'height': body_h - divCab_h - dif })
                tablaCampos.resize()
            }
            catch (e) { }
        }
        
    </script>
    
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden">
    <div id="divFiltroDatos">
    <div id="divMenuABMEntidades" style="width:100%"></div>
     </div>                                                  
       <div id="div_tabla" style="width: 100%; height: 100%; overflow: auto">
        <div id="tablaCampos" name="tablaCampos" style="width: 100%; height: 100%; overflow: hidden"></div></div>     
</body>
</html>