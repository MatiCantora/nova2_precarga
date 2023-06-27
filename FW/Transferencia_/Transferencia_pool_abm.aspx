<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Me.contents("filtroXML_nro_permiso_grupo") = nvXMLSQL.encXMLSQL("<criterio><select vista='Operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroXML_nro_permiso") = nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id, Permitir as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Me.contents("filtroXML_operador_tipo") = nvXMLSQL.encXMLSQL("<criterio><select vista='operador_tipo'><campos>*</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_operadores") = nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>nombre_operador</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroXML_verOperadores_operador_tipo") = nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct operador,upper(rtrim(nombre_operador)) as nombre_operador</campos><filtro></filtro><orden>nombre_operador</orden></select></criterio>")



%>
<html>
<head>
<title>Transferencia ABM Pool</title>
    <meta http-equiv="X-UA-Compatible" content="IE=8"/>
    <!--meta charset='utf-8'-->
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            
    <script type="text/javascript"  src="/fw/script/nvFW.js"></script>
    <script type="text/javascript"  src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript"  src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript"  src="/FW/script/tCampo_def.js"></script>     
    <script type="text/javascript"  src="/FW/script/tScript.js"></script>     
     <% = Me.getHeadInit()%>

        <style type="text/css">
            td.permiso {
                width: 80px;
                text-align: center;
            }
            td.action {
                width: 25px;
                text-align: center;
            }
            .icon {
                width: 16px;
                height: 16px;
                background: #f00;
            }
            .icon.erase {
                background: url('/FW/image/tnvRect/delete.png');
            }
            .icon.view {
                background: url('/FW/image/icons/buscar.png');
            }
            .icon.new {
                background: url('/FW/image/icons/agregar.png');
            }
        </style>
        <script type="text/javascript" >
            var win;
            var pool;
            function window_onload() {
                win = nvFW.getMyWindow();
                pool = win.options.Pool;
                $('title').value = pool.title;
                
                try {
                    pool.permisos.each(function(p) {
                        createPermiso(p);
                    });
                } catch (e) 
                { 
                 for(var p=0;p<pool.permisos.length;p++)
                     createPermiso(pool.permisos[p]);
                }
               
                vMenuABMPermisosParticulares = new tMenu('divMenuABMPermisosParticulares', 'vMenuABMPermisosParticulares');
                Menus["vMenuABMPermisosParticulares"] = vMenuABMPermisosParticulares;
                Menus["vMenuABMPermisosParticulares"].alineacion = 'centro';
                Menus["vMenuABMPermisosParticulares"].estilo = 'A';
                //Menus["vMenuABMPermisosParticulares"].imagenes = Imagenes;
                Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos Particulares</Desc></MenuItem>");
                Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Perfil</Desc><Acciones><Ejecutar Tipo='script'><Codigo>newPermiso('tipo_operadores')</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Operador</Desc><Acciones><Ejecutar Tipo='script'><Codigo>newPermiso('nro_operador')</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuABMPermisosParticulares"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar Permiso</Desc><Acciones><Ejecutar Tipo='script'><Codigo>newPermiso('nro_permiso')</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuABMPermisosParticulares"].loadImage("agregar", '/fw/image/transferencia/agregar.png')
                Menus["vMenuABMPermisosParticulares"].MostrarMenu();
                
                campos_defs.items['nro_operador']['onchange'] = createPermisoUser;
                campos_defs.items['tipo_operadores']['onchange'] = createPermisoProfile;

                window_onresize()
            }
            function window_onresize() {
                try {

                    var dif = Prototype.Browser.IE ? 5 : 2
                    var body_heigth = $$('body')[0].getHeight()
                    var divhead_height = $('divCabe').getHeight()
                    var divfooter_height = $('tbPie').getHeight()
                    var calc = body_heigth - divhead_height - divfooter_height - dif + "px"

                    $('divRow').setStyle({ height: calc })

                }
                catch (e) { console.log(e.message) }
            }


            function window_onunload() {

            }

            function btn_Aceptar_onclick() {
                pool.title = $('title').value;

                pool.permisos = [];
                $('permisos').select('tbody tr:not(.title)').each(function(tr) {
                    var permiso = {};
                    var inputs = tr.select('input[type="hidden"]');
                    inputs.each(function(input) {
                        permiso[input.getAttribute('name')] = input.value;
                    });

                    var checkboxes = tr.select('input[type="checkbox"]');
                    var pos = checkboxes.length - 1;
                    permiso.permiso = 0;
                    checkboxes.each(function(checkbox) {
                        if (checkbox.checked) {
                            permiso.permiso += Math.pow(2, pos);
                        }
                        pos--;
                    });
                    pool.permisos.push(permiso);
                });

                pool.reloadTitle();
                //parent.Windows.getFocusedWindow().Undo.add();
                //parent.window.Undo.add();
                //win.Undo.add();
                win.close();
            }
            function btn_Cancelar_onclick() {
                win.close();
            }
            function newPermiso(type) {
              
               if(campos_defs.items[type]!= undefined)
                if (campos_defs.items[type]["window"] != undefined && campos_defs.items[type]["window"].campo_def_value != '') 
                    campos_defs.items[type]["window"] = undefined;

               if(type == 'nro_permiso')
                  {
                   if(campos_defs.items[type+ '_grupo']!= undefined)
                     if (campos_defs.items[type + '_grupo']["window"] != undefined && campos_defs.items[type + '_grupo']["window"].campo_def_value != '') 
                        campos_defs.items[type + '_grupo']["window"] = undefined;
                  
                    Dialog.confirm("<table style='width:100%' class='tb1'><tr><td colspan='2' style='text-align:center' class='Tit1'>Seleccione la definición de permiso:</td></tr><tr><td style='width:10%'>Grupo:</td><td id='td_nro_permiso_grupo'></td></tr><tr><td style='width:10%'>Permiso:</td><td id='td_nro_permiso'></td></tr></table>", 
                                                             {   width: 400,
                                                                 height: 150,
                                                                 className: "alphacube",
                                                                 okLabel: "Si",
                                                                 cancelLabel: "No",
                                                                 onShow: function(w){
                                                                                       campos_defs.add('nro_permiso_grupo',  {  enDB: false,
                                                                                                                                target: 'td_nro_permiso_grupo',
                                                                                                                                nro_campo_tipo: 1,
                                                                                                                                filtroXML: nvFW.pageContents.filtroXML_nro_permiso_grupo,
                                                                                                                                filtroWhere: "<nro_permiso_grupo type='igual'>%campo_value%</nro_permiso_grupo>",
                                                                                                                                depende_de: null,
                                                                                                                                depende_de_campo: null
                                                                                                                              })
                                                                                         
                                                                                        campos_defs.add('nro_permiso',       {  enDB: false,
                                                                                                                                target: 'td_nro_permiso',
                                                                                                                                nro_campo_tipo: 1,
                                                                                                                                filtroXML: nvFW.pageContents.filtroXML_nro_permiso,
                                                                                                                                filtroWhere: "<nro_permiso type='igual'>%campo_value%</nro_permiso>",
                                                                                                                                depende_de: "nro_permiso_grupo",
                                                                                                                                depende_de_campo: "nro_permiso_grupo"
                                                                                                                              })                                                                                                                                   
                                                                                    },
                                                                 onOk: function(win){
                                                                                     if(campos_defs.value('nro_permiso_grupo') == '' || campos_defs.value('nro_permiso') == '')
                                                                                      {
                                                                                       alert("Seleccione el Grupo y/o Permiso.")
                                                                                       return
                                                                                      } 
                                                                                      
                                                                                      createPermisoPermit()
                                                                                      win.close(); return
                                                                                    },
                                                                 onCancel: function(win) { win.close(); return }
                                                              });
                  }
               else
                  {
                    var back = campos_defs.items[type]['onchange'];
                    campos_defs.items[type]['onchange'] = function() {};
                    campos_defs.clear(type);
                    campos_defs.items[type]['onchange'] = back;
                    campos_defs.onclick('', type, true);
                  }  
            }
           
            function createPermisoPermit() {
                var permiso = {};
                    permiso.nro_permiso_grupo = campos_defs.value('nro_permiso_grupo');
                    permiso.nro_permiso = campos_defs.value('nro_permiso');
                    permiso.permiso_grupo = campos_defs.desc('nro_permiso_grupo');
                    permiso.permitir = campos_defs.desc('nro_permiso');
                    permiso.id_permiso = campos_defs.value('nro_permiso_grupo') + '_' + campos_defs.value('nro_permiso');
                    
                if (!existsPermiso('id_permiso', permiso.id_permiso))
                 {
                    permiso.dbId = 0;
                    permiso.transferencia_permiso_id = 0;
                    permiso.permiso = 0;
                    permiso.nro_operador = '';
                    permiso.nombre_operador = '';
                    permiso.tipo_operador = '';
                    permiso.tipo_operador_desc = '';
                    createPermiso(permiso);
                } 
                else 
                  {alert('El "Permiso de usuario" seleccionado, ya existe');}
            }
            
            function createPermisoProfile() {
                var permiso = {};
                permiso.tipo_operador = campos_defs.value('tipo_operadores');
                if (!existsPermiso('tipo_operador', permiso.tipo_operador)) {

                    permiso.dbId = 0;
                    permiso.transferencia_permiso_id = 0;
                    permiso.permiso = 0;
                    permiso.nro_operador = '';
                    permiso.nombre_operador = '';
                    permiso.nro_permiso_grupo = ''
                    permiso.nro_permiso = ''
                    permiso.permiso_grupo = ''
                    permiso.permitir = ''
                    permiso.id_permiso = ''
                    
                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_operador_tipo,"", "<tipo_operador type='igual'>" + permiso.tipo_operador + "</tipo_operador>", "");
                    if (!rs.eof()) {
                        permiso.tipo_operador_desc = rs.getdata('tipo_operador_desc');
                        return createPermiso(permiso);
                    }
                } else {
                    alert('El "Perfil de usuario" seleccionado, ya posee permisos');
                }
            }
            function createPermisoUser() {
                
                var permiso = {};
                permiso.nro_operador = campos_defs.value('nro_operador');
                if (!existsPermiso('nro_operador', permiso.nro_operador)) 
                  {
                    permiso.dbId = 0;
                    permiso.transferencia_permiso_id = 0;
                    permiso.permiso = 0;
                    permiso.tipo_operador = '';
                    permiso.tipo_operador_desc = '';
                    permiso.nro_permiso_grupo = ''
                    permiso.nro_permiso = ''
                    permiso.permiso_grupo = ''
                    permiso.permitir = ''
                    permiso.id_permiso = ''

                    var rs = new tRS();
                    rs.open(nvFW.pageContents.filtroXML_operadores, "", "<operador type='igual'>" + permiso.nro_operador + "</operador>", "");
                    if (!rs.eof()) {
                        permiso.nombre_operador = rs.getdata('nombre_operador');
                        return createPermiso(permiso);
                    }
                } else {
                    alert('El "Operador" seleccionado, ya posee permisos');
                }
            }
            
            function existsPermiso(type, nro_operador) {
                var exists = false;
                $('permisos').select('tbody tr:not(.title) input[name="' + type + '"]').each(function(input) {
                    if (input.value == nro_operador) {
                        exists = true;
                        throw $break;
                    }
                });
                return exists;
            }
            function createPermiso(permiso) {
                var html = '<tr>';
                html += '<td>';
                html += permiso.nro_permiso_grupo > 0 ? permiso.permiso_grupo  + ' - ' + permiso.permitir : permiso.nombre_operador + permiso.tipo_operador_desc;
                html += getInputs(permiso);
                html += '</td>';
//                html += '<td class="permiso"><input type="checkbox" ' + (permiso.permiso & 8 ? 'checked="checked"' : '') + ' /></td>';
//                html += '<td class="permiso"><input type="checkbox" ' + (permiso.permiso & 4 ? 'checked="checked"' : '') + ' /></td>';
//                html += '<td class="permiso"><input type="checkbox" ' + (permiso.permiso & 2 ? 'checked="checked"' : '') + ' /></td>';
//                html += '<td class="permiso"><input type="checkbox" ' + (permiso.permiso & 1 ? 'checked="checked"' : '') + ' /></td>';
                html += '<td class="action view"></td>';
                html += '<td class="action erase"></td>';
                html += '</tr>';

                $('permisos').select('tbody')[0].insert({bottom: html});

                html = $('divRow').select('tbody tr');
                html = html[html.length - 1];

                if (permiso.tipo_operador_desc) {
                    var view = $(document.createElement('div')).addClassName('icon view');
                    view.observe('click', function() {
                        ver_operadores(permiso.tipo_operador, permiso.tipo_operador_desc)
                    });
                    html.select('td.view.action')[0].update(view);
                }

                var erase = $(document.createElement('div')).addClassName('icon erase');
                erase.observe('click', function() {
                    this.up('tr').remove();
                });
                html.select('td.erase.action')[0].update(erase);

            }
            function getInputs(permiso) {
                var html = '';
                for (var key in permiso) {
                    html += '<input type="hidden" name="' + key + '" value="' + permiso[key] + '" />';
                }
                return html;
            }
            function ver_operadores(tipo_operador, tipo_operador_desc) {
                var strHTML = '';
                strHTML = "<table class='tb1'>";
                strHTML += "<tr>";
                strHTML += "<td colspan='2' style='text-align:center'><b>" + tipo_operador_desc + "</b></td>";
                strHTML += "</tr>";
                strHTML += "<tr class='tbLabel'>";
                strHTML += "<td style='width: 15%; text-align:center'><b>N°</b></td>";
                strHTML += "<td style='text-align:center' nowrap><b>Operador</b></td>";
                strHTML += "</tr>";
                strHTML += "</table>";
                strHTML += "<div style='height:130px;overflow:auto'>";
                strHTML += "<table class='tb1'>";
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroXML_verOperadores_operador_tipo,"","<tipo_operador type='igual'>" + tipo_operador + "</tipo_operador>","");
                while (!rs.eof()) {
                    if (rs.getdata('nombre_operador') != null) {
                        strHTML += "<tr>";
                        strHTML += "<td class='Tit1' style='width: 15%; text-align:right'>" + rs.getdata("operador") + "</td>";
                        strHTML += "<td style='text-align:left' nowrap>&nbsp;" + rs.getdata('nombre_operador') + "</td>";
                        strHTML += "</tr>";
                    }
                    rs.movenext();
                }
                strHTML += "</table>";
                strHTML += "</div>";

                Dialog.alert(strHTML, {className: "alphacube", width: 450, height: 220, okLabel: "cerrar"});
            }
        </script>
    </head>
    <body onload="return window_onload()" onresize="return window_onresize()" onunload="return window_onunload()" style="background-color:white; width:100%;height:100%;overflow:hidden">
        <div style="display: none;"><%= nvCampo_def.get_html_input("tipo_operadores")%></div>
        <div style="display: none;"><%= nvCampo_def.get_html_input("nro_operador")%></div>
            
 <%--               
     <table class="tb1" width="100%">
                   <%-- <tr class="tbLabel">
                        <td style="width:10%">Nº</td>
                        <td style="width:10%">Tipo</td>
                        <td style="width:60%">Detalle Transferencia</td>
                        <td style="width:10%">Opcional</td>
                        <td style="width:10%">Estado</td>
                    </tr>
                    <tr>
                        <td><input type="text" name="id_transferencia_txt" id="id_transferencia_txt" style="width:100%; text-align:center" onkeypress='return valDigito()' disabled="disabled" /></td>
                        <td><select name="cb_transf_tipo" id="cb_transf_tipo" style="width:100%" onclick="cb_Transf_Tipo_on_change()" disabled="disabled"></select></td>
                        <td><input type="text" name="title" id="title" style="width:100%" /></td>                
                        <td><input type="checkbox" name="opcional" id="opcional" style="width:100%;border:0px" /></td>
                        <td>
                            <select name="estado" id="estado" style="width:100%">
                                <option value='A'>Activo</option>
                                <option value='N'>Nulo</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="5">
                            <div id="divMenuABMPermisosParticulares">
                                <!-- menu -->
                            </div>
                        </td>
                    </tr>
                </table>  --%>

            <div id="divCabe" style="width:100%">
            <div style="width:100%">
                <table class="tb1">
                <tr>
                    <td class="Tit1" style="width:10%">Titulo:</td>
                    <td><input type="text" id="title" style="width:100%" value=""/></td>
                </tr>
                </table>
            </div>
            <div id="divMenuABMPermisosParticulares"></div>
            </div>
            <div id="divRow" style="width: 100%;  overflow: auto;">
                <table id="permisos" class="tb1" style="width: 100%">
                    <tr class="title">
                        <td class="Tit1">Perfil/Operador/Permiso</td>
                        <!--<td class="Tit1 permiso">Ejecutar</td>-->
                        <td class="Tit1 action">-</td>
                        <td class="Tit1 action">-</td>
                    </tr>
                </table>
            </div>
            <table class="tb1" id="tbPie">
                <tr>
                    <td style="text-align:center;white-space:nowrap;width:10%">&nbsp;</td>
                    <td style="width:30%"><input type="button" style="width:100%" name="btn_Aceptar" value="Aceptar" onclick="btn_Aceptar_onclick()" /></td>
                    <td style="text-align:center;white-space:nowrap">&nbsp;</td>
                    <td style="width:30%"><input type="button" style="width:100%" name="btn_Cancelar" value="Cancelar" onclick="btn_Cancelar_onclick()" /></td>
                    <td style="text-align:center;white-space:nowrap;width:10%">&nbsp;</td>
                </tr>
            </table>             
    </body>
</html>