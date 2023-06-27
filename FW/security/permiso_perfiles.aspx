<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    Dim err As New nvFW.tError()
    
    Me.contents("filtroPerfil") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador,upper(rtrim(login)) as nombre_operador</campos><filtro></filtro><orden>nombre_operador</orden></select></criterio>")
    Me.contents("filtroPerfilComparar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador,upper(rtrim(login)) as nombre_operador</campos><filtro></filtro><orden>nombre_operador</orden></select></criterio>")
    
    'debe tener el permiso para editar el modulo
    If Not op.tienePermiso("permisos_seguridad", 3) Then
        err.numError = -1
        err.titulo = "No se pudo completar la operación. "
        err.mensaje = "No tiene permisos para ver la página."
        err.response()
    End If

    Dim tipo_operador_get As String = nvFW.nvUtiles.obtenerValor("tipo_operador_get", "1")


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Permiso Perfiles</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/fw/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/fw/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var win = nvFW.getMyWindow()
        var tipo_operador_get='<%= tipo_operador_get %>'
        var tablaUsuarios;
        var tablaUsuariosComparar
        
        function window_onload(){
            vPerfilMenu.MostrarMenu()
            window_onresize();
            campos_defs.items['divPerfiles']['onchange']=perfil_change;
            campos_defs.items['divPerfilesComparar']['onchange']=perfil_comparar_change;
            campos_defs.habilitar('divPerfilesComparar', false)
            
            crearTablas()
            campos_defs.set_value("divPerfiles", tipo_operador_get)    
        }

        function crearTablas(){
            tablaUsuarios = new tTable();
            tablaUsuarios.nombreTabla="tablaUsuarios";
            tablaUsuarios.filtroXML = nvFW.pageContents.filtroPerfil
            tablaUsuarios.eliminable = false;
            tablaUsuarios.editable = false;
            tablaUsuarios.mostrarAgregar = false;
            tablaUsuarios.async = true;
            tablaUsuarios.tBody.style = "color:#3380FF";
            tablaUsuarios.cabeceras=["Id","Usuario","-"];
            tablaUsuarios.campos = [
                { nombreCampo: "operador",width: "10%",ordenable: false },
                { nombreCampo: "nombre_operador",width: "70%",nro_campo_tipo: 104, ordenable: false },
                { nombreCampo: "permiso_grupo", nro_campo_tipo: 104, get_html: function(campo,nombre,fila) { return '<img border="0" src="/FW/image/icons/editar.png" title="editar" style="cursor:pointer" onclick="operador_abm(\''+fila[1].valor+'\')">' }
                }
            ];

            tablaUsuariosComparar = new tTable();
            tablaUsuariosComparar.nombreTabla="tablaUsuariosComparar";
            tablaUsuariosComparar.filtroXML=nvFW.pageContents.filtroPerfilComparar;
            tablaUsuariosComparar.eliminable=false;
            tablaUsuariosComparar.editable=false;
            tablaUsuariosComparar.mostrarAgregar=false;
            tablaUsuariosComparar.async=true;
            tablaUsuariosComparar.tBody.style = "color:red";
            tablaUsuariosComparar.cabeceras=["Id","Usuario","-"];
            tablaUsuariosComparar.campos=[
                { nombreCampo: "operador",width: "10%",ordenable: false  },
                { nombreCampo: "nombre_operador",width: "70%",nro_campo_tipo: 104, ordenable: false },
                { nombreCampo: "permiso_grupo",nro_campo_tipo: 104,get_html: function(campo,nombre,fila) { return '<img border="0" src="/FW/image/icons/editar.png" title="editar" style="cursor:pointer" onclick="operador_abm(\''+fila[0].valor+'\')">' }
                }
            ];
        }

        function perfil_change(){
            if(campos_defs.value('divPerfiles')=='') return;
            tablaUsuarios.refresh("<tipo_operador type='igual'>"+campos_defs.value('divPerfiles')+"</tipo_operador><estado type='igual'>'activo'</estado>");
            parent.cambiarPerfil(campos_defs.get_value('divPerfiles'), campos_defs.get_value('divPerfilesComparar'))
        }

        function perfil_comparar_change(){
            if(campos_defs.value('divPerfilesComparar')=='') return;
            tablaUsuariosComparar.refresh("<tipo_operador type='igual'>"+campos_defs.value('divPerfilesComparar')+"</tipo_operador><estado type='igual'>'activo'</estado>");
            parent.cambiarPerfilComparar(campos_defs.get_value('divPerfilesComparar'))
        }

        function compararPerfiles(){
            if($('compararPerfiles').checked) 
                campos_defs.habilitar('divPerfilesComparar', true)
            else{
                campos_defs.habilitar('divPerfilesComparar', false)
                campos_defs.clear('divPerfilesComparar')
                parent.cargar_vista()
                //tablaUsuariosComparar.refresh()
                $('tablaUsuariosComparar').innerHTML = ''
                
                }
        }

        var window_perfil
        function perfil_abm(){

            var get_tipo_operador = ''
            var desc_perfiles=campos_defs.desc('divPerfiles');
            var id_perfiles=campos_defs.value('divPerfiles');
            desc_perfiles = desc_perfiles.substring(0,desc_perfiles.search("("+id_perfiles+")")-2);
            if(campos_defs.items['divPerfiles'])
                get_tipo_operador=campos_defs.value('divPerfiles')==''?'':'?get_tipo_operador='+campos_defs.value('divPerfiles')+'&get_operador_desc='+desc_perfiles

           window_perfil = parent.nvFW.createWindow({ className: 'alphacube',
                url: '/fw/security/perfil_abm.aspx'+get_tipo_operador,
                title: 'Perfil ABM',
                minimizable: false,
                maximizable: false,
                draggable: true,
                minWidth: 300,
                minHeight: 450,
                maxHeight: 500,
                width: 450,
                height: 470,
                onClose: perfil_abm_return
            });

            window_perfil.showCenter(true)

        }

        function perfil_abm_return(){
            if(typeof (window_perfil.returnValue)=='string') {
                var idDef=campos_defs.value("divPerfiles");
                $("cbdivPerfiles").length=0;
                campos_defs.set_value("divPerfiles",idDef);
                idDef=campos_defs.value("divPerfilesComparar");
                $("cbdivPerfilesComparar").length=0;
                campos_defs.set_value("divPerfilesComparar",idDef);
            }
        }

        var winOperador
        function operador_abm(operador){
            winOperador = parent.nvFW.createWindow({ className: 'alphacube',
                url: '/fw/security/operador_abm.aspx',
                title: 'Operador ABM',
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 840,
                height: 500
            });

            winOperador.options.userData={}

            winOperador.options.userData.login=operador;
            winOperador.showCenter(true)
        }

        function window_onresize(){
            try {
                var dif=Prototype.Browser.IE ? 5 : 2
                var body_h = $$('body')[0].getHeight()
                var divCab_h = $('divPerfilMenu').getHeight()

                var h = body_h - divCab_h - dif
                $('tabla').style.height = h +'px';
                $('tr_tablaUsuarios').style.height = (h-80)*0.6 + 'px';
                $('tr_tablaUsuariosComparar').style.height = (h-80)*0.38 + 'px';

              tablaUsuarios.resize();
              tablaUsuariosComparar.resize();
            }
            catch(e) { }
        }

        function nuevo_perfil() {
            
            var win = parent.nvFW.createWindow({
                url: "/fw/security/perfil_abm.aspx",
                width: 360,
                height: 190,
                draggable: true,
                resizable: true,
                closable: true,
                minimizable: false,
                maximizable: false,
                title: "<b>ABM Perfil </b>",
                onShow: function (win) {

                }
            });

            win.showCenter(true);

        }

    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()"  style="width:100%;height:100%;overflow:hidden">
    <div id="divPerfilMenu" style="width:100%;"></div>
        <script type="text/javascript" language="javascript">
            var vPerfilMenu = new tMenu('divPerfilMenu', 'vPerfilMenu');
            vPerfilMenu.loadImage("editar", "/fw/image/icons/editar.png");
            vPerfilMenu.loadImage("nuevo", "/fw/image/icons/nueva.png");
            Menus["vPerfilMenu"] = vPerfilMenu
            Menus["vPerfilMenu"].alineacion = 'centro';
            Menus["vPerfilMenu"].estilo = 'A';
            Menus["vPerfilMenu"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>perfil_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vPerfilMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%;text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Perfil</Desc></MenuItem>")
            Menus["vPerfilMenu"].CargarMenuItemXML("<MenuItem id='2' style=''><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo_perfil()</Codigo></Ejecutar></Acciones></MenuItem>")
        </script>
   
   
    <table id="tabla" class="tb1" style="width: 100%; ">
        <tr style='height: 20px'>
            <td id='tituloOperadores' class='Tit1'>Operadores Habilitados:</td>
        </tr>
        <tr style='height: 20px'>
            <td id='perfiles'><%= nvFW.nvCampo_def.get_html_input("divPerfiles", nro_campo_tipo:=1, enDB:=False, filtroXML:="<criterio><select vista='operador_tipo'><campos>distinct tipo_operador as id,rtrim(tipo_operador_desc) as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")%>
            </td>
        </tr>
        <tr style='height: 45%'>
            <td><div id='tr_tablaUsuarios'><div id='tablaUsuarios'></div></div> </td>
        </tr>
        <tr style='height: 20px'>
            <td class='Tit1'><input type="checkbox" id='compararPerfiles' onclick="compararPerfiles()" />Comparar</td>
        </tr>
        <tr style='height: 20px'>
            <td id='perfilesComparar'><%= nvFW.nvCampo_def.get_html_input("divPerfilesComparar", nro_campo_tipo:=1, enDB:=False, filtroXML:="<criterio><select vista='operador_tipo'><campos>distinct tipo_operador as id,rtrim(tipo_operador_desc) as [campo]</campos><filtro></filtro><orden>[campo]</orden></select></criterio>")%></td>
        </tr>
        <tr style='height: 45%'>
            <td><div id='tr_tablaUsuariosComparar' ><div id='tablaUsuariosComparar'></div></div></td>
        </tr>
    </table>

</body>
</html>