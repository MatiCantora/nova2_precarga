<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim id_conf = nvFW.nvUtiles.obtenerValor("id_conf", 0)
    
    Me.contents("filtroParametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verConf_especial_parametro'><campos>nro_par_nodo, nro_par_nodo as id, par_nodo, comentario_relacion</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_campoDef_parametro") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_NodosTree'><campos>distinct nodo_id as id, nombre as [campo]</campos><orden>[campo]</orden></select></criterio>")

    Me.addPermisoGrupo("permisos_parametros")
    Me.addPermisoGrupo("permisos_conf_especiales_gral")
    
    %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Configuraciones especiales parametros</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/fw/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>

    <%= Me.getHeadInit()%>

    <script type="text/javascript">

        var tablaParametro = new tTable()
        var id_conf = '<%=id_conf %>'

        function window_onload()
        {
            tablaParametro.nombreTabla = "tablaParametro"
            tablaParametro.filtroXML = nvFW.pageContents.filtroParametro
            tablaParametro.filtroWhere = "<id_cfg_especial type='igual'>" + id_conf + "</id_cfg_especial>"
            tablaParametro.cabeceras = ["Nro Param", "Parámetro", "Comen.", "Ver"]
            tablaParametro.campos = [
                { nombreCampo: "id", width: "15%", editable: false, style: { 'textAlign': 'center' }  ,
                    get_html: function(campo, nombreTabla) { return (campo.valor != undefined ? campo.valor : 0) }
                },
                { nombreCampo: "par_nodo", id: "nro_par_nodo", width: "65%",
                    get_campo: function(nombreTabla, id)
                    {
                        campos_defs.add(nombreTabla + "_campos_defs" + id,
                                    { nro_campo_tipo: 3, enDB: false, target: 'campos_tb_' + nombreTabla + id, filtroXML: nvFW.pageContents.filtro_campoDef_parametro,
                                        filtroWhere: "<nodo_id type='igual'>%campo_value%<nodo_id>", campo_codigo: "nodo_id", campo_desc: "nombre"
                                    })
                                    campos_defs.onclick = function (event) {campo_def_onclick(event, nombreTabla + "_campos_defs" + id, true) }
                    }
                },
                { nombreCampo: "comentario_relacion", ordenable: false, style: { 'align': 'center' }, editable: false, get_html: function(campo, nombreTabla){
                   if (campo.fila) { $('campos_tb_tablaParametro_fila_' + campo.fila + '_columna_1').title = campo.valor }
                    return "<div id='comentario_fila_" + campo.fila + "' title='" + (campo.valor != undefined ? campo.valor : "") + "' style='text-align:center;'><img onclick='comentario(\"" + campo.valor + "\",  " + campo.fila + ")' src='/FW/image/icons/comentario3.png' style='cursor:pointer; text-align:center'></img></div>"
                }
                },
                { nombreCampo: "ver", width: "5%", ordenable: false, editable:false, enDB: false, get_html: function(campo, tabla) { return "<div style='text-align:center; width:3%' ><img onclick='verParametro(" + campo.fila + ")' src='/FW/image/icons/editar.png' style='cursor:pointer; text-align:center'></img></div>" } }
            ];

            tablaParametro.validar = function() { return validar() }
            if (!parent.permisosEditar()){
                tablaParametro.eliminable = false
                tablaParametro.mostrarAgregar = false
            }
            tablaParametro.agregar_espacios_en_blanco_dir = function() { return agregar_espacios_en_blanco_dir() }
            tablaParametro.editable = false
            tablaParametro.table_load_html()
        }

        function agregar_espacios_en_blanco_dir()
        {
            var row_index = 0, cell_index = 0;
            var valores_campos = [];

            valores_campos[cell_index] = false;
            valores_campos[cell_index + 1] = false;
            valores_campos[cell_index + 2] = false;
            valores_campos[cell_index + 3] = false;

            tablaParametro.agregar_fila(valores_campos);
            tablaParametro.resize()
            var campo_def = "tablaParametro_campos_defs_fila_" + (tablaParametro.cantFilas - 1).toString() + "_columna_1"
            campos_defs.onclick(event, campo_def)
        }

        function verParametro(fila){    
            if(nvFW.tienePermiso('permisos_parametros', 2)){
                var nodo = tablaParametro.getValor('nro_par_nodo', fila - 1)
                if (nodo != ''){
                    var win = top.nvFW.createWindow({
                        url: "/fw/parametros/parametros_nodos_editar_valor.aspx?nro_par_nodo=" + nodo,
                                    width: "800",
                                    height: "450",
                                    top: "50"
                                })
                    win.showCenter()
                }
            }
            else{
                nvFW.alert("No posee permisos para ver el parámetro. Consulte con el administrador de sistemas")
            }
        }

        function comentario(input, index) {       
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
                                    tablaParametro.data[index].comentario_relacion = win.texto
                                    tablaParametro.data[index].tabla_control["modificado"] = true

                                    var xmldato = "<?xml version='1.0' encoding='iso-8859-1'?><configuraciones modo='E' id='" + parent.id_conf + "' nombre='" + parent.campos_defs.get_value("nombre") + "' comentario='" + parent.campos_defs.get_value("comentario") + "'>"
                                    xmldato += tablaCampos.generarXML("parametros")
                                    xmldato += "<pizarras /><camposdef /><transferencias/></configuraciones>"

                                    nvFW.error_ajax_request('/fw/configuraciones_especiales/conf_especiales.aspx', { parameters: { modo: 'G', strXML: xmldato },
                                        onSuccess: function(err, transport)
                                        {
                                            tablaParametro.refresh()
                                        }
                                    })

                                } catch (e) { }
                            }
                        }
                    }
                })
                winComentario.showCenter()
            }
            else{
                nvFW.alert('No tiene permisos para editar el comentario')
            }
        }

        function validar() {
            for (var row_index = 1; row_index < tablaParametro.cantFilas; row_index++)
            {
                //Si NO es valido retornamos false
                var fila = tablaParametro.getFila(row_index)
                if (fila.param == '' && !tablaParametro.data[row_index].tabla_control.eliminado) {
                    return false
                }
            }
            return true
        }

        function window_onresize(){
            try
            {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                $('div_tabla').setStyle({ 'height': body_h - dif })
                tablaParametro.resize()
            }
            catch (e) { }
        }



        function campo_def_onclick(ev, campo_def, mostrar){  
            //mostrar tambien define si la consulta es asincrona
            //si se muestra es asincrona
            this.focus(campo_def)
            if (ev != null && ev.ctrlKey == 1 && ev.shiftKey == 1)
            {
                this.clear(campo_def)
                return
            }

            if (mostrar == undefined)
                mostrar = true
            //si el campo está desabilitado salir
            if (campos_defs.items[campo_def]["input_hidden"].disabled)
                return false

            var depende_de = campos_defs.items[campo_def]['depende_de']
            var depende_de_campo = campos_defs.items[campo_def]['depende_de_campo']


            //Si tiene dependencia y no esta seleccionada salir
            if (depende_de != null && depende_de != "")
            {
                if ($(depende_de).value == "")
                    return false
            }

            //COMBO Busqueda
            if (campos_defs.items[campo_def]['nro_campo_tipo'] == 3)
            {
                if (!campos_defs.items[campo_def]["window"])
                {
                    if (!campos_defs.items[campo_def]["nvFW"])
                    {
                        campos_defs.items[campo_def]["nvFW"] = window.top.nvFW
                        if (!campos_defs.items[campo_def]["nvFW"])
                            campos_defs.items[campo_def]["nvFW"] = nvFW
                    }

                    campos_defs.items[campo_def]["window"] = campos_defs.items[campo_def]["nvFW"].createWindow({
                        title: "Seleccionar",
                        parameters: { campo_def: campos_defs.items[campo_def] },
                        width: 400, height: 350,
                        minimizable: false,
                        minHeight: 350,
                        maxHeight: 350,
                        minWidth: 350,
                        url: "/fw/configuraciones_especiales/conf_especiales_param_nodos.aspx",
                        onClose: function(win)
                        {
                            if (campos_defs.items[campo_def]["input_hidden"].value != win.campo_def_value && win.cancelado == false)
                            {
                                if (!paramExistente(win.campo_def_value)) {
                                    campos_defs.items[campo_def]["input_hidden"].value = win.campo_def_value
                                    campos_defs.items[campo_def]["input_text"].value = win.campo_desc
                                    campos_defs.focus(campo_def)
                                    campos_defs.onchange(ev, campo_def)
                                }
                                 else{ top.nvFW.alert("El parametro ya ha sido agregado")}
                            }
                        }
                    })
                }

                campos_defs.items[campo_def]["window"].showCenter(true);
                return true
            }

            return true
        }

        function paramExistente(nuevoValor){  
            for (var i = 0; i < tablaParametro.cantFilas; i++ ){
                if (tablaParametro.getFila(i).nro_par_nodo == nuevoValor && !tablaParametro.data[i].tabla_control.eliminado)
                    return true
            }
                return false
        }
        
    </script>
    
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width:100%;height: 100%; overflow: hidden">
    <div id="div_tabla" style="width: 100%; height: 100%; overflow: auto">
        <div id="tablaParametro" name="tablaParametro" style="width: 100%; height: 100%; overflow: hidden"></div></div>     
</body>
</html>