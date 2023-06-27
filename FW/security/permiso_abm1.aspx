<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%


    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err As New nvFW.tError()

    'debe tener el permiso para editar el modulo
    If Not op.tienePermiso("permisos_seguridad", 3) Then
        err.numError = -1
        err.titulo = "No se pudo completar la operación. "
        err.mensaje = "No tiene permisos para ver la página."
        err.response()
    End If

    Dim tipo_operador_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_get", "")
    Dim operador_get As String = nvFW.nvUtiles.obtenerValor("operador_get", "")


    Dim nro_per_nodo_get As String = "&nro_per_nodo_get=" & nvFW.nvUtiles.obtenerValor("nro_per_nodo_get", "")
    Dim nro_permiso_grupo_get As String = "&nro_permiso_grupo_get=" & nvFW.nvUtiles.obtenerValor("nro_permiso_grupo_get", "")
    Dim nro_permiso_get As String = "&nro_permiso_get=" & nvFW.nvUtiles.obtenerValor("nro_permiso_get", "")


    Dim tipo_vista = ""
    If nvFW.nvUtiles.obtenerValor("vista", "") = "" Then
        tipo_vista = "standard"
    End If
    Dim vista = "vista=" & nvFW.nvUtiles.obtenerValor("vista", "")

    Dim filtroPerfil As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador,upper(rtrim(login)) as nombre_operador</campos><filtro></filtro><orden>nombre_operador</orden></select></criterio>")
    Dim filtroPerfilComparar As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador,upper(rtrim(login)) as nombre_operador</campos><filtro></filtro><orden>nombre_operador</orden></select></criterio>")
        
    Dim link As String = ""
    If nvFW.nvUtiles.obtenerValor("vista", "") = "lineal" Then
        link &= "permiso_abm_view_tree.aspx?"
    Else
        link &= "permiso_abm_view_standard.aspx?"
    End If
    link &= vista & nro_permiso_grupo_get & nro_permiso_get & nro_per_nodo_get

    Dim query As String = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>distinct tipo_operador as id,rtrim(tipo_operador_desc) as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")
    Dim cod_servidor As String = nvApp.cod_servidor

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/fw/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script  type="text/javascript" >
    

    var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); }

    var Operador_Tipo = new Array()
    var cod_servidor = '<%= cod_servidor %>'
    var win = nvFW.getMyWindow()
    var tipo_operador_get = '<%= tipo_operador_get %>'
    var operador_get = '<%= operador_get %>'
    var filtroPerfil = '<%= filtroPerfil %>'
    var filtroPerfilComparar = '<%= filtroPerfilComparar %>'

    function window_onload() {
        
        campos_defs.set_value('divPerfiles', tipo_operador_get);
        //campos_defs.set_value('divPerfilesComparar', 1);

        if (tipo_operador_get != '') {
            vPerfilMenu.MostrarMenu()

            campos_defs.items['divPerfiles']['onchange'] = perfil_change;
            campos_defs.items['divPerfilesComparar']['onchange'] = perfil_comparar_change;
            cargar_operadores('cb_tipo_operador', 'divOperadores', '#749BC4')
            cargar_iframe('<%= link %>', true)
        }

       // if (operador_get != '')
         //   vOperadorMenu.MostrarMenu()

        if (parent.div_Actualizar_hide)
            parent.div_Actualizar_hide()

        window_onresize();
    }

    function perfil_change() {
        cargar_tabla_Usuarios();
        si_compara('compararPerfiles');
    }

    function perfil_comparar_change() {
        cargar_tabla_Usuarios_comparar();
        si_compara('compararPerfiles2');
    }

    function cargar_operadores(cb,div,color) {
        cargar_tabla_Usuarios(cb, div, color);
        cargar_tabla_Usuarios_comparar(cb, div, color);
    }

    var tablaUsuarios;
    var tablaUsuariosCargada = false; 
    function cargar_tabla_Usuarios(cb, div, color) {

        var filtro

        if (tablaUsuariosCargada) {
            if (campos_defs.value('divPerfiles') == '') return;
            filtro = "<tipo_operador type='igual'>" + campos_defs.value('divPerfiles') + "</tipo_operador><estado type='igual'>'activo'</estado>"
            tablaUsuarios.refresh(filtro);
            return;
        }
    
        tablaUsuariosCargada = true;
        var criterio = filtroPerfil
        filtro = "<tipo_operador type='igual'>" + campos_defs.value('divPerfiles') + "</tipo_operador><estado type='igual'>'activo'</estado>"

        tablaUsuarios = new tTable();
        tablaUsuarios.nombreTabla = "tablaUsuarios";

        tablaUsuarios.filtroXML = criterio
        tablaUsuarios.filtroWhere = filtro

        tablaUsuarios.eliminable = false;
        tablaUsuarios.editable = false;
        tablaUsuarios.mostrarAgregar = false;

        tablaUsuarios.async = true;

        tablaUsuarios.cabeceras = ["Id", "Usuario", "-"];
        tablaUsuarios.campos = [
                { nombreCampo: "operador", width: "10%", ordenable: false
                },
                {
                    nombreCampo: "nombre_operador", width: "70%", nro_campo_tipo: 104, ordenable: false
                },
                { nombreCampo: "permiso_grupo", nro_campo_tipo: 104, get_html: function (campo, nombre, fila) { return '<img border="0" src="/FW/image/icons/editar.png" title="editar" style="cursor:pointer" onclick="operador_abm(\'' + cb + '\',\'' + div + '\',\'' + color + '\',\'' + fila[1].valor + '\')">' }
                }
                ];


        tablaUsuarios.table_load_html();

    }

    var tablaUsuariosCompararCargada = false
    var tablaUsuariosComparar
    function cargar_tabla_Usuarios_comparar(cb, div, color) {

        var filtro

        if (tablaUsuariosCompararCargada) {
            if (campos_defs.value('divPerfilesComparar') == '') return;
            filtro = "<tipo_operador type='igual'>" + campos_defs.value('divPerfilesComparar') + "</tipo_operador><estado type='igual'>'activo'</estado>"
            tablaUsuariosComparar.refresh(filtro);
            return;
        }
    
        tablaUsuariosCompararCargada = true
        var criterio = filtroPerfilComparar
        filtro = "<tipo_operador type='igual'>" + campos_defs.value('divPerfilesComparar') + "</tipo_operador><estado type='igual'>'activo'</estado>"

        tablaUsuariosComparar = new tTable();
        tablaUsuariosComparar.nombreTabla = "tablaUsuariosComparar";

        tablaUsuariosComparar.filtroXML = criterio;
        tablaUsuariosComparar.filtroWhere = filtro;

        tablaUsuariosComparar.eliminable = false;
        tablaUsuariosComparar.editable = false;
        tablaUsuariosComparar.mostrarAgregar = false;

        tablaUsuariosComparar.async = true;

        tablaUsuariosComparar.cabeceras = ["Id", "Usuario", "-"];
        tablaUsuariosComparar.campos = [
                {
                    nombreCampo: "operador", width: "10%", ordenable: false
                },
                {
                    nombreCampo: "nombre_operador", width: "70%", nro_campo_tipo: 104, ordenable: false
                },
                {
                    nombreCampo: "permiso_grupo", nro_campo_tipo: 104, get_html: function (campo, nombre, fila) { return '<img border="0" src="/FW/image/icons/editar.png" title="editar" style="cursor:pointer" onclick="operador_abm(\'' + cb + '\',\'' + div + '\',\'' + color + '\',' + fila[0].valor + ')">'; }
                }
                ];

        tablaUsuariosComparar.table_load_html();

    }


    function si_compara(accion) {
        if (accion == 'compararPerfiles') {
            cargar_iframe(undefined, true)
        }
        else if ('compararPerfiles2') {
            if ($('compararPerfiles').checked) {
                cargar_iframe(undefined, true)
            }
        }

        window_onresize()
    }

    var path0 = ''
    function cargar_iframe(path_rel,recargar) {
    
        if (!campos_defs.value('divPerfiles')) {
            alert("Seleccione un perfil")
            return
        }
 
      if (!recargar) {

        var ventana = ObtenerVentana("frame_permisos")

            if ((ventana.vista == 'lineal' || ventana.vista == 'comparar')) {
                if ($('compararPerfiles').checked) {
                    ventana.vista = 'comparar'
                    ventana.window.$('tipo_operador_comp_get').value = campos_defs.value('divPerfilesComparar')
                    ventana.campos_defs.set_value("operador_tipo", ventana.window.$('tipo_operador_comp_get').value)
                    ventana.window.tipo_operador_desc_comp = ventana.campos_defs.desc('operador_tipo')
                }
                else
                    ventana.vista = 'lineal'

                ventana.window.$('tipo_operador_get').value = tipo_operador_get
                ventana.campos_defs.set_value("operador_tipo", tipo_operador_get)

                ventana.vista_lineal()
            }
        }
        else {

          if(!path_rel)
              path_rel = path0
          else
              path0 = path_rel 


          if (path_rel.indexOf('?') >= 0)
            param_get = path_rel + '&'
          else
            param_get = path_rel + '?'

        param_get += "tipo_operador_get=" + campos_defs.value('divPerfiles');

        if ($('compararPerfiles').checked)
            {
              param_get = replace(param_get, 'vista=lineal', '')
              param_get += '&tipo_operador_comp_get=' + campos_defs.value('divPerfilesComparar');
              param_get += '&vista=comparar'
            }

          var ventana = ObtenerVentana("frame_permisos")

          if (param_get.indexOf('permiso_abm_view_tree.aspx') >= 0 && ventana.location.href.indexOf('permiso_abm_view_tree.aspx') >= 0 && ventana.location.href.indexOf('&vista=comparar') == -1 && !$('compararPerfiles').checked)  
           {
               ventana.campos_defs.set_value("operador_tipo", campos_defs.value('divPerfiles'))
            ventana.habilitar_tree()
           } 
          else
            ventana.location.href = param_get 
         }
    }

    var window_perfil
    function perfil_abm() {

        var get_tipo_operador = ''
        var desc_perfiles = campos_defs.desc('divPerfiles');
        var id_perfiles = campos_defs.value('divPerfiles');
        desc_perfiles = desc_perfiles.substring(0, desc_perfiles.search("(" + id_perfiles + ")") - 2);
    
        if (campos_defs.items['divPerfiles'])
            get_tipo_operador = campos_defs.value('divPerfiles') == '' ? '' : '?get_tipo_operador=' + campos_defs.value('divPerfiles') + '&get_operador_desc=' + desc_perfiles

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
        window_perfil = w.createWindow({ className: 'alphacube',
            url: '/fw/security/perfil_abm.aspx' + get_tipo_operador,
            title: 'Perfil ABM',
            minimizable: false,
            maximizable: false,
            draggable: true,
            minWidth: 300,
            minHeight: 365,
            maxHeight: 365,
            width: 450,
            height: 365,
            onClose: perfil_abm_return
        });

        window_perfil.showCenter(true)

    }

    function perfil_abm_return() {
        if (typeof (window_perfil.returnValue) == 'string') {
            var idDef  = campos_defs.value("divPerfiles");
            $("cbdivPerfiles").length = 0;
            campos_defs.set_value("divPerfiles", idDef);
            idDef = campos_defs.value("divPerfilesComparar");
            $("cbdivPerfilesComparar").length = 0;
            campos_defs.set_value("divPerfilesComparar", idDef);
        }
    }

    var win
    function operador_abm(cb, div, color, operador) {

        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW;
        win = w.createWindow({ className: 'alphacube',
            url: '/fw/security/operador_abm.aspx',
            title: 'Operador ABM',
            minimizable: false,
            maximizable: false,
            draggable: true,
            width: 840,
            height: 500
            //onClose: operador_abm_return
        });

        win.options.userData = {}
        win.options.userData.login = operador;
        win.showCenter(true)
    }

    function window_onresize() {

        try {
        
            var dif = Prototype.Browser.IE ? 5 : 2
            var body_h = $$('body')[0].getHeight()
            var divCab_h = $('divPerfilMenu').getHeight()
            var perfiles_h = $("perfiles").getHeight()
            var perfiles_comparar_h = $("perfilesComparar").getHeight()
            var titulo_peradores_h = $("tituloOperadores").getHeight()
            var botones_h = $("td_botones").getHeight()
       
            var h = body_h - divCab_h - perfiles_h - perfiles_comparar_h - titulo_peradores_h - botones_h - 50;

            $('tr_tablaUsuarios').style.height = h * 0.6 + 'px';
            $('tr_tablaUsuariosComparar').style.height = h * 0.4 + 'px';
            $('frame_permisos').style.height = body_h;


            tablaUsuarios.resize();
            tablaUsuariosComparar.resize();
        }
        catch (e) { }
    }


</script>
</head>
<body onload="window_onload()" onresize="window_onresize()"  style="width:100%;height:100%;overflow:hidden">

    <table>
        <tr>
            <td style='width: 28%;'>
                <table>
                    <tr>
                        <td>
                            <div id="divPerfilMenu" style="width:100%;"></div>
                            <script type="text/javascript" language="javascript">
                                var vPerfilMenu = new tMenu('divPerfilMenu', 'vPerfilMenu');
                                vPerfilMenu.loadImage("sistema", "/fw/image/sistemas/sistema.png");
                                Menus["vPerfilMenu"] = vPerfilMenu
                                Menus["vPerfilMenu"].alineacion = 'centro';
                                Menus["vPerfilMenu"].estilo = 'A';
                                Menus["vPerfilMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Perfil</Desc></MenuItem>")
                            </script>
                        </td>
                    </tr>
                    <tr>
                        <td id='tituloOperadores' class='Tit1'>
                            Operadores Habilitados:
                        </td>        
                    </tr>
                    <tr>
                        <td id='perfiles'>
                            <script type="text/javascript">
                                campos_defs.add('divPerfiles', { nro_campo_tipo: 1, enDB: false, filtroXML: '<%=query %>' })
                            </script> 
                        </td>
                    </tr>
                    <tr >
                        <td>
                            <div style='height: 45%' id='tr_tablaUsuarios'>
                                <div id='tablaUsuarios'></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td class='Tit1'>
                            <input type="checkbox" id='compararPerfiles' onclick="si_compara('compararPerfiles')" />Comparar
                        </td>
                    </tr>
                    <tr>
                        <td id='perfilesComparar'>
                            <script type="text/javascript">
                                campos_defs.add('divPerfilesComparar', { nro_campo_tipo: 1, enDB: false, filtroXML: '<%=query %>' })
                            </script>
                        </td>
                    </tr>
                    <tr >
                        <td>
                            <div id='tr_tablaUsuariosComparar' style='height: 25%'>
                                <div  id='tablaUsuariosComparar'></div>
                            </div>
                        </td>
                    </tr>
                    <tr  id='td_botones'>
                        <td>
                            <div style='text-align: center;'>
                                <input type="button" value='Estructural'  onclick="return cargar_iframe('permiso_abm_view_tree.aspx',true)" />
                                <input type="button" value='Standard' onclick="return cargar_iframe('permiso_abm_view_standard.aspx',true)" />
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
            <td style='width: 72%;height:100%;'>
                <iframe id="frame_permisos" name="frame_permisos" src="/fw/enblanco.htm" style="width:100%;height:100%;overflow:hidden" frameborder="0"/>
            </td>
        </tr>

    </table>

</body>
</html>