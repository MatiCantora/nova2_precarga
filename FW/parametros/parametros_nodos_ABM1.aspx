<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nodo_get As String = nvFW.nvUtiles.obtenerValor("nodo_get", "")
    Dim nodo_tipo_get As String = nvFW.nvUtiles.obtenerValor("nodo_tipo_get", "")

    Dim filtroCargar = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verparametros_nodos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroDependientes = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verparametros_nodos_Dep'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroCargarArray = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verparametros_nodos'><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>")
    Dim filtroExisteParametro = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros'><campos>top 1 *</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroParametroAsociado = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_nodos'><campos>top 1 nro_par_nodo</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroNodoPadre = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_nodos'><campos>top 1 nro_par_nodo</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroSeleccionarParametro = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_def'><campos>*</campos></select></criterio>")
    Dim filtroCargarParametro = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verparametros_nodos'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Dim filtroCampoDefTipoParam = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_tipos'><campos>distinct param_tipo as id, param_tipo_desc as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Dim filtroCampoDefPermisoGrupo = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Dim filtroCampoDefPermiso = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id, Permitir as [campo] </campos><orden>[campo]</orden></select></criterio>")
    Dim filtroCampoDefTipoParametro = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='parametros_nodos_tipos'><campos>distinct par_nodo_tipo as id, par_nodo_tipo_desc as [campo]</campos><orden>[campo]</orden><filtro><par_nodo_tipo type='distinto'>'R'</par_nodo_tipo></filtro></select></criterio>")

    If (modo.ToUpper() = "GUARDAR") Then

        Dim err = New nvFW.tError()

        Dim Cmd As New nvFW.nvDBUtiles.tnvDBCommand("FW_parametros_nodos_abm2", ADODB.CommandTypeEnum.adCmdStoredProc, nvFW.nvDBUtiles.emunDBType.db_app, , , , , )
        Try
            Dim strXML As String = ""
            strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
            Cmd.addParameter("@strXML", 201, 1, strXML.Length, strXML)
            Dim rs As ADODB.Recordset = Cmd.Execute()

            Dim nro_par_nodo = rs.Fields("nro_par_nodo").Value
            err.params("nro_par_nodo") = nro_par_nodo
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

        Catch e As Exception
            err.parse_error_script(e)
        End Try

        err.response()

    End If

    Me.addPermisoGrupo("permisos_parametros")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Parametros Nodo ABM</title>

    <link href="/fw/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">
       
        var filtroCargar = '<% =filtroCargar %>'
        var filtroDependientes = '<% =filtroDependientes %>'
        var filtroCargarArray = '<% =filtroCargarArray %>'
        var filtroExisteParametro = '<% =filtroExisteParametro %>'
        var filtroParametroAsociado = '<% =filtroParametroAsociado %>'
        var filtroNodoPadre = '<% =filtroNodoPadre %>'
        var filtroSeleccionarParametro = '<% =filtroSeleccionarParametro %>'
        var filtroCargarParametro = '<% =filtroCargarParametro %>'
        var filtroCampoDefTipoParam = '<% =filtroCampoDefTipoParam %>'
        var filtroCampoDefPermisoGrupo = '<%= filtroCampoDefPermisoGrupo %>'
        var filtroCampoDefPermiso = '<%= filtroCampoDefPermiso %>'
        var filtroCampoDefTipoParametro = '<%= filtroCampoDefTipoParametro %>'
        var parametros = new Array()

        var win = nvFW.getMyWindow()

        function window_onload() {
            cargar()  
            campos_defs.items["par_nodo_tipo"]['onchange'] = par_nodo_tipo_onchange
            parametros_cargar_arr($('nro_par_nodo').value)
          //  param_onblur('')
      
         }

        function par_nodo_tipo_onchange(){
            if( campos_defs.value("par_nodo_tipo") == 'P') {
                campos_defs.habilitar("nro_permiso_grupo",true)
                campos_defs.habilitar("nro_permiso_dep",true)
                $('trId_param').show()
                $('trId_paramValor').show()
                $("trPermisoGrupo").show()
    
                $("divSoloparametros").hide()
                parametros = new Array()   
                win.setTitle("<b>Par�metro ABM</b>")
            }

            if( campos_defs.value("par_nodo_tipo") == 'M'){
                campos_defs.clear("nro_permiso_grupo")
                campos_defs.clear("nro_permiso_dep")
                campos_defs.habilitar("nro_permiso_grupo",false)
                campos_defs.habilitar("nro_permiso_dep",false)
                $('trId_param').hide()
                $('trId_paramValor').hide()
                $("trPermisoGrupo").hide()
                $("divSoloparametros").show()
                win.setTitle("<b>M�dulo ABM</b>")
            }   
  
            window_onresize()
        }

        function cargar(){
            var filtroWhere = "<nro_par_nodo type='igual'>" + $('nro_par_nodo').value + "</nro_par_nodo>";
            var i = 0;
            var rs = new tRS();
            rs.open(filtroCargar, '', filtroWhere, '', '');
            if(!rs.eof()){
                    $('par_nodo').value = rs.getdata('par_nodo')
                    $('orden').value = rs.getdata('orden') != null ? rs.getdata('orden') : 0
         
                    if(rs.getdata("nro_par_nodo_dep") != null)
                    campos_defs.set_value("nro_par_nodo_dep",rs.getdata("nro_par_nodo_dep"))
                    campos_defs.set_value("par_nodo_tipo",rs.getdata("par_nodo_tipo"))
                    campos_defs.set_value("nro_permiso_grupo",rs.getdata("nro_permiso_grupo") == null? "" : rs.getdata("nro_permiso_grupo"))
                    campos_defs.set_value("nro_permiso_dep", rs.getdata("nro_permiso") == null ? "" : rs.getdata("nro_permiso"))
         
                    $("id_param").value = rs.getdata("id_param") == null ? "" : rs.getdata("id_param")
                    campos_defs.set_value("param_tipo", rs.getdata("param_tipo") == null ? "" : rs.getdata("param_tipo"))
                     
                    if ($("par_nodo_tipo").value != 'M'){
                        var habilitar = !(rs.getdata("encriptar") == 'False');
                        $("encriptarCheckbox").checked = habilitar;
                       // $("encriptarCheckbox").disabled = habilitar;
                    }
                    else $("encriptarCheckbox").checked = false

                    par_nodo_tipo_onchange()
         
                    if(es_nodo_padre($('nro_par_nodo').value) || campos_defs.value("par_nodo_tipo") == 'P')
                        campos_defs.habilitar("par_nodo_tipo",false)
                }
              else{
                campos_defs.set_value("par_nodo_tipo","M")
                par_nodo_tipo_onchange()
            }  
        
         }

        function nuevo(){
            if ($('nro_par_nodo').value > 0 && campos_defs.value("par_nodo_tipo") == 'M')
                campos_defs.set_value("nro_par_nodo_dep", $('nro_par_nodo').value)
            else{
                campos_defs.set_value("par_nodo_tipo", "P") 
                campos_defs.clear("nro_par_nodo_dep")
            }
            
            parametros = new Array()   
            $('divparametros').innerHTML = ''
            $("encriptarCheckbox").checked = false
            $("encriptarCheckbox").disabled = false
            $('nro_par_nodo').value = 0
            $('par_nodo').value = ''
            $('orden').value = ''
            campos_defs.habilitar("nro_permiso_grupo",true)
            campos_defs.habilitar("nro_permiso_dep", true)
            campos_defs.habilitar("par_nodo_tipo",true)
            $('trId_param').show()
            $('trId_paramValor').show()
            $("trPermisoGrupo").show()
            $('id_param').value = ''
            campos_defs.clear("param_tipo")
            campos_defs.clear("nro_permiso_grupo")
            campos_defs.clear("nro_permiso_dep")
            campos_defs.clear("par_nodo_tipo")
            campos_defs.clear("nro_par_nodo_dep")
            campos_defs.set_value("par_nodo_tipo", "P") 
            $('divSoloparametros').hide()
 
            window_onresize()
        }
       
        function tiene_dependientes(){
            var res = false;
            var filtroWhere = "<nro_par_nodo_dep type='igual'>"+ $('nro_par_nodo').value +"</nro_par_nodo_dep>";
            var rs = new tRS();
            rs.open(filtroDependientes, '', filtroWhere, '', '');
            if (!rs.eof())
                res = true;

            return res;
        }
         var  win_dialog
        function eliminar() {  
            if($('nro_par_nodo').value == 0 || $('nro_par_nodo').value == '')
                return

            if (parametros.length > 0) {

                var html = '<div id = "modal_dialog_1555001520991_content" class="alphacube_content" style = "height: 100px; width: 390px; overflow: auto;" >'
               html += '<div class="alphacube_message">El m�dulo tiene par�metros asociados: �Desea eliminarlos?</div>'
               html += '<div class="alphacube_buttons" style="width:100%">' 
               html += '<input style="width:27%" type="button" value="Eliminar todo" onclick="eliminar_todo()" class=" " />'
               html += '<input style="width:27%" type="button" value="Eliminar m�dulo" onclick="eliminar_modulo()" class=" " />  ' 
               html += '<input style="width:27%" type="button" value="Cancelar" onclick="cancelar()" class=" " />  ' 
               html += '</div></div>'

              win_dialog = nvFW.createWindow({
                width: 390,
                height: 100,
                draggable: true,
                resizable: false,
                closable: true,
                minimizable: false,
                maximizable: false
            });

            win_dialog.getContent().innerHTML = html
            win_dialog.showCenter(true);

            }
            else {
                nvFW.confirm('�Desea eliminarlo?', { width: 350,
                                    className: "alphacube",
                                    okLabel: "Si",
                                    cancelLabel: "No",
                                    onOk: function (win) {
                                        $('nro_par_nodo').value  = $('nro_par_nodo').value * -1
                                        procesarXML(false)
                                        win.close()
                                        return                                    
                                    },
                                    onCancel: function(win) {
                                        win.close()
                                        return
                                    }
                                });
            }
        }

        function eliminar_todo() {
                                    $('nro_par_nodo').value  = $('nro_par_nodo').value * -1
                                                procesarXML(true)
            win_dialog.close()

                                            }

        function eliminar_modulo() {
            $('nro_par_nodo').value  = $('nro_par_nodo').value * -1
                                        procesarXML(false)
            win_dialog.close()
                                    }
                                    
        function cancelar() {
            win_dialog.close()
            
        }

        function guardar(){                      
//            if ($("encriptarCheckbox").disabled && parseInt($('nro_par_nodo').value) >= 0 ) {
//                alert('No es posible guardar los cambios si el par�metro esta codificado.');
//                return;
//            }
            if(!nvFW.tienePermiso("permisos_parametros",1)){ alert("No tiene permisos para guardar el par�metros") ; return }
            var strError = ''
 
            if(campos_defs.value("nro_permiso_grupo") == '' && campos_defs.value("par_nodo_tipo") == 'P')
                strError = "Ingrese el permiso grupo.</br>"

            if (campos_defs.value("nro_permiso_dep") == '' && campos_defs.value("par_nodo_tipo") == 'P')
                strError += "Ingrese el permiso.</br>"
 
            if(campos_defs.value("par_nodo_tipo") == '')
                strError += "Ingrese el tipo.</br>"

            if(parseInt($('nro_par_nodo').value) >= 0 && campos_defs.value("par_nodo_tipo") == 'P' && campos_defs.value("id_param") != '')
                if(parametro_asociado($('nro_par_nodo').value,campos_defs.value("id_param"))) 
                    strError += "El parametro</br>ya se encuentra asociado.</br>" 
 
            if($("par_nodo").value == '' )//&& campos_defs.value("par_nodo_tipo") != 'P')
                strError += "Ingrese la descripci�n.</br>"
   
            if(campos_defs.value("nro_par_nodo_dep") == $("nro_par_nodo").value)
                strError += "El nodo no pude depender de si mismo. Verifique.</br>"
   

            if(strError != '')
            {
                alert(strError)
                return
            }
            procesarXML()
        }

        function procesarXML(eliminar_dependient) { //si se deben eliminar los dependientes se pasa el nro_par_nodo en negativo para tratarlo en la DB
            var signo_dep = ''
            if (eliminar_dependient) signo_dep = '-'     
                
            xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?>"
            xmldato += "<nodos>"
            xmldato += "<nodo nro_par_nodo = '" + $('nro_par_nodo').value + "' hijo='N' orden ='" + $('orden').value + "' nro_par_nodo_dep = '" + campos_defs.value('nro_par_nodo_dep') + "'"
            xmldato += " par_nodo_tipo='" + campos_defs.value("par_nodo_tipo") + "' id_param='" + campos_defs.value("id_param") + "' param_tipo='" + campos_defs.value("param_tipo") + "' "
            xmldato += " nro_permiso_grupo='" + campos_defs.value("nro_permiso_grupo") + "' nro_permiso='" + campos_defs.value('nro_permiso_dep') + "'>"
            xmldato += "<par_nodo><![CDATA[" + $('par_nodo').value + "]]></par_nodo>"
            xmldato += "<param_valor></param_valor>"
            xmldato += "<encriptar>" + ($('encriptarCheckbox').checked + "").toLowerCase() + "</encriptar>"
            xmldato += "</nodo>";

            parametros.each(function(arreglo, i) 
                    {
                        xmldato += "<nodo nro_par_nodo = '" + signo_dep + arreglo['nro_par_nodo'] + "' hijo='S' orden ='" + i + "' nro_par_nodo_dep = '" + $('nro_par_nodo').value + "' "
                        xmldato += " par_nodo_tipo = '" + arreglo['par_nodo_tipo'] + "' id_param='" + arreglo['id_param'] + "' param_tipo = '" + arreglo['param_tipo'] + "' "
                        xmldato += " nro_permiso_grupo ='" + arreglo['nro_permiso_grupo'] + "' nro_permiso ='" + arreglo['nro_permiso_dep'] + "'>"
                        xmldato += "<par_nodo><![CDATA[" + arreglo['par_nodo'] + "]]></par_nodo>"
                        xmldato += "<param_valor></param_valor>"
                        xmldato += "<encriptar>" + (arreglo["encriptar"] + "").toLowerCase() + "</encriptar>"
                        xmldato += "<hardcode_anterior>" + (arreglo["hardcode_anterior"] + "").toLowerCase() + "</hardcode_anterior>"
                        xmldato += "</nodo>"
                    });
            
            xmldato += "</nodos>"

            nvFW.nvFW_error_ajax_request('parametros_nodos_abm.aspx', {
                parameters: { modo: 'GUARDAR', strXML: xmldato},
                onSuccess: function (err, transport) {
                    if (err.numError != 0) {
                        alert(err.mensaje)
                        return
                    }
                    else {
                        nro_par_nodo = err.params['nro_par_nodo'];
                        win.options.userData = 'refresh';

                        node_global_dep = campos_defs.value('nro_par_nodo_dep');

                        if (node_global_dep) {
                            var zeroString = "00000";
                            var node_global_dep = zeroString.substring((node_global_dep + "").length, 5) + node_global_dep;
                        }

                        if (!node_global_dep)
                            parent.parametro_mostrar_return()
                        else {
                            parent.parametro_mostrar_return()
                        }
                        
                        win.close();
                    }
                }
            });
            
        }

        function window_onresize(){
            try{
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var cab_height = $('divCabecera').getHeight()
               // var div_parametros_abm_height = $('div_parametros_abm').getHeight()
               // var divMenuABM1_height = $('divMenuABM1').getHeight()
                $('divparametros').setStyle({'height': body_height - cab_height  - dif + 'px'})
            }
            catch(e){}  
        }

        function parametros_cargar_arr(nro_par_nodo){            
            parametros = new Array()
            var k = 0
            var rs = new tRS();
            var vacio
            rs.async = true
            rs.onComplete = function (rs) {   
                while (!rs.eof()) { 
                    vacio = new Array()
                    vacio['nro_par_nodo'] = rs.getdata('nro_par_nodo')
                    vacio['par_nodo'] = rs.getdata('par_nodo')
                    vacio['par_nodo_tipo'] = rs.getdata('par_nodo_tipo')
                    vacio['par_nodo_tipo_desc'] = rs.getdata('par_nodo_tipo_desc')
                    vacio['id_param'] = isNULL(rs.getdata('id_param'), '')
                    vacio['param_tipo'] = isNULL(rs.getdata('param_tipo'), '')
                    vacio['param_tipo_desc'] = isNULL(rs.getdata('param_tipo_desc'), '')
                    vacio['nro_permiso_grupo'] = isNULL(rs.getdata('nro_permiso_grupo'), '')
                    vacio['permiso_grupo'] = isNULL(rs.getdata('permiso_grupo'), '')
                    vacio['nro_permiso_dep'] = isNULL(rs.getdata('nro_permiso'), '')
                    vacio['permitir'] = isNULL(rs.getdata('permitir'), '')
                    vacio['orden'] = isNULL(rs.getdata('orden'), 0)
                    vacio['tiene_dependientes'] = es_nodo_padre(vacio['nro_par_nodo'])
                    vacio['encriptar'] = rs.getdata('encriptar')
                    vacio['hardcode_anterior'] = vacio['encriptar']

                    parametros[k] = vacio
                    k++
                    rs.movenext()

                }
                parametros_dibujar()
            }
            var filtroWhere = "<par_nodo_tipo type='distinto'>'R'</par_nodo_tipo><nro_par_nodo_dep type='igual'>" + nro_par_nodo + "</nro_par_nodo_dep>";
            rs.open(filtroCargarArray, '', filtroWhere, '', '');
        }

        function isNULL(valor,retorno)
        {
            return valor == null ? retorno : valor
        }
        
        function parametros_dibujar(){  
            if (parametros.length >= 0) {
                $('divparametros').innerHTML = ''

                var strHTML = '<table id="tb_parametros" class="tb1 highlightOdd highlightTROver" style="width:100%; vertical-align: top;">'
                    strHTML += '<tr class="tbLabel0">'  
                    strHTML += '<td style="width:5%;text-align:center">-</td>'
                    strHTML += '<td style="width:15%;text-align:center">Tipo</td>'
                    strHTML += '<td style="text-align:center">Descripci�n</td>'
                    strHTML += '<td style="width:2%;text-align:center">-</td>'
                    strHTML += '<td style="width:2%;text-align:center">-</td>'
                    strHTML += '<td style="width:10px;text-align:center">-</td>'
                    strHTML += '</tr>'
                    parametros.each(function(arreglo, i){
                        if(arreglo['nro_par_nodo'] >= 0) {
                            ver = '<img src="/fw/image/icons/editar.png" style="cursor:pointer;cursor:hand" title="Editar" name="ver_parametro" id="ver_parametro_' + i + '" value="' + i + '" onclick="editar_parametro('+i+');" />'
                            par_nodo_tipo_desc = arreglo['par_nodo_tipo_desc']
                            par_nodo_tipo = arreglo['par_nodo_tipo']
                       
                            id_param = arreglo['id_param'] 
                            param_tipo_desc = arreglo['param_tipo_desc']
                        
                            permiso_grupo = arreglo['permiso_grupo']
                        
                            desc = ''
                            trColor = ''
                            title_param = ''
                            if(par_nodo_tipo == 'M'){
                                desc = arreglo['par_nodo']
                                title = desc
                                desc = (desc.length > 110) ? desc.substr(0,110)+'...' : desc
                                trColor = 'style="color:blue"'
                            }
                            else{
                                desc =  arreglo['par_nodo'] 
                                title = desc 
                                title_param = '|Param: ' + id_param + '\n|Tipo: '+ param_tipo_desc + '\n|Permiso: ' + arreglo['permitir'] + '-' + arreglo['permiso_grupo'] 
                                desc = (desc.length > 110) ? desc.substr(0,110)+ '...' : desc
                            }
                             
                            strHTML += '<tr '+ trColor +'>'
                            strHTML += "<td style='width:5%;text-align:center'>" + ver + "</td>"
                            strHTML += '<td style="width:15%;text-align:left" title="'+arreglo['par_nodo_tipo_desc']+'">' + par_nodo_tipo_desc + '</td>'               
                            strHTML += '<td style="text-align:left" title="'+ title +'">' + desc + '</td>'               
                            strHTML += '<td style="width:2%; text-align:center">'
                            if(par_nodo_tipo == 'P')
                                strHTML += '<img src="/fw/image/icons/procesar.png" style="cursor:pointer;cursor:hand" title="'+ title_param +'" />'
                            else
                                strHTML += '&nbsp;'
                            strHTML += '</td>'
                        
                            if(arreglo['nro_par_nodo'] == 0 || !arreglo['tiene_dependientes'] )
                                strHTML += '<td style="width:2%; text-align:center"><img alt="" title="Eliminar" src="/fw/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="eliminar_parametro('+ i +')" /></td>'
                            else
                                strHTML += '<td style="width:2%; text-align:center">&nbsp;&nbsp;&nbsp;</td>'
                            strHTML += '<td style="width:10px;text-align:center"><a href="#" onclick="subir(' + i + ')"><img src="/fw/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="bajar(' + i + ')"><img src="/fw/image/icons/down_a.png" border="0" hspace="0"/></a></td>'
                            strHTML += '</tr>'
                            }   
                    });
                
                strHTML += '</table>'

                $('divparametros').insert({ top: strHTML })
            }

            window_onresize()
            
         }

         function editar_parametro(indice){ 
            var k = indice
            if ((parametros[k] != undefined)) {                                   
                var win = top.nvFW.createWindow({ 
                    url: "/fw/parametros/parametros_nodos_ABM_hijo.aspx?nodo_get=" + parametros[k]['nro_par_nodo'] + "&nodo_depende=" + $('nro_par_nodo').value,
                    width: "600",
                    height: "300",
                    top: "50",
                    destroyOnClose: true,
                    onClose: function(win){
                        if (win.params){
                            parametros[k] = win.params
                            parametros_dibujar()
                        }
                    }
                })
                win.showCenter()
            }    
         }   

        function parametros_orden(){
            var orden = 0
            if (parametros.length > 0)
            {
                parametros.each(function(arreglo, i) {
                    orden  = (parseInt(arreglo['orden']) > parseInt(orden )) ? arreglo['orden'] : orden 
                })
            }
            return orden 
         }

        function bajar(orden) 
        {
            var len = parametros.size()
            var orden_dest = -1
            for (var i = orden + 1; i < len; i++)
                if (parametros[i] >= 0) {
                orden_dest = i
                break;
            }

            if (orden_dest != -1) {
                var a = parametros[orden]
                parametros[orden] = parametros[orden_dest]
                parametros[orden_dest] = a
                parametros_dibujar()
            }
        }
    
        function subir(orden) 
        {
            var len = parametros.size()
            var orden_dest = -1
            for (var i = orden - 1; i >= 0; i--)
                if (parametros[i] >= 0) {
                orden_dest = i
                break;
            }

            if (orden_dest != -1) {
                var a = parametros[orden]
                parametros[orden] = parametros[orden_dest]
                parametros[orden_dest] = a
                parametros_dibujar()
            }
        }
   
        function parametros_nuevo() {            
            var win = top.nvFW.createWindow({
                url: "/fw/parametros/parametros_nodos_ABM_hijo.aspx?&nodo_depende=" + $('nro_par_nodo').value   ,
                width: "500",
                height: "300",
                top: "50",
                destroyOnClose: true,
                onClose: function(win){
                    if (win.params){      
                        var indice = parametros.length
                        parametros[indice] = new Array()
                        parametros[indice] = win.params
                        parametros_dibujar()
                    }
                }
            })
            win.showCenter()
        }    

        function eliminar_parametro(indice){
            if (!nvFW.tienePermiso("permisos_parametros", 1)) { alert("No tiene permisos para eliminar el par�metro"); return }
               nvFW.confirm('�Desea eliminarlo?', { width: 350,
                                okLabel: "Si",
                                cancelLabel: "No",
                                onOk: function(win) {          
                                    if(parametros[indice]['nro_par_nodo'] > 0)
                                        parametros[indice]['nro_par_nodo'] = parseInt(parametros[indice]['nro_par_nodo']) * -1
                           
                                    if(parametros[indice]['nro_par_nodo']== 0)
                                        parametros.splice(indice, 1)

                                    parametros_dibujar()
                                    win.close()
                                             
                                },
                                onCancel: function(win) {
                                    win.close()
                                    return
                                }
                            });
        }  

        function parametro_existe(id_param) {
           var existe = false
           var rs = new tRS()
           var filtroWhere = "<id_param type='igual'>'" + id_param + "'</id_param>";
           rs.open(filtroExisteParametro, '', filtroWhere, '', '');
           if (!rs.eof()) 
                existe = true
            
           return existe
        }     
         
        function parametro_asociado(nro_par_nodo,id_param) 
        {
            var existe = false
            var filtro_nodo = ""
    
            if(nro_par_nodo != 0)
              filtro_nodo = "<nro_par_nodo type='distinto'>" + nro_par_nodo + "</nro_par_nodo>"

            var rs = new tRS()
            //var filtroCampo ="<criterio><select vista='parametros_nodos'><campos>top 1 nro_par_nodo</campos><filtro></filtro><orden></orden></select></criterio>";
            var filtroWhere = filtro_nodo + "<par_nodo_tipo type='igual'>'P'</par_nodo_tipo><id_param type='igual'>'" + id_param + "'</id_param>";

            rs.open(filtroParametroAsociado, '', filtroWhere, '', '');
            if (!rs.eof()) 
              existe = true
    
            return existe
        }            
        
        function es_nodo_padre(nro_par_nodo){
            var existe = false
            var filtro_nodo = ""
            
            if(nro_par_nodo == 0)
                return existe
            else
                filtro_nodo = "<nro_par_nodo_dep type='igual'>" + nro_par_nodo + "</nro_par_nodo_dep>"

            var rs = new tRS()

            rs.open(filtroNodoPadre, '', filtro_nodo, '', '');
            if (!rs.eof()) 
                existe = true
            
            return existe
        }            

        function si_es_borrado_activar(nro_par_nodo,id_param){
            var activo = false
            parametros.each(function(arreglo, i)
            {
                if(arreglo.id_param == id_param)
                    if(parseInt(arreglo.nro_par_nodo) < 0)
                    {
                    arreglo.nro_par_nodo  = parseInt(arreglo.nro_par_nodo)* -1 
                    activo = true
                    } 
            });
           
            return activo  
        }

        function existe_en_array(id_param){
            var existe = false
            var cantidad = 0
            parametros.each(function(arreglo, i)
            {
                if(arreglo.id_param == id_param)
                    cantidad++ 
            });
           
            if(cantidad > 0)
                existe = true
             
            return existe 
        }

        var dependiente
        function seleccionar_parametro(valor) {
            dependiente = valor
            if(campos_defs.value('par_nodo_tipo') == "M" && !dependiente){
                alert("Est� editando un m�dulo, no un p�rametro. No se puede realizar la b�squeda")
                return
            }

            var win = nvFW.createWindow({
                url: 'parametros_buscar.aspx',
                title: '<b>Buscar Par�metros</b>',
                parameters: {
                        consulta: filtroSeleccionarParametro,
                    filtro:"",
                        path_reporte: "report\\parametros\\ver_parametros_buscar\\ver_valores_parametros_buscar.xsl"
                            },
                minimizable: false,
                maximizable: false,
                draggable: true,
                width: 600,
                height: 320,
                resizable: false,
                destroyOnClose:true
            });
            win.showCenter(true)

        }

        function redraw(id_param) {
            if (id_param == '')
                return

            var rs = new tRS()
            var filtroWhere = "<id_param type='igual'>'" + id_param + "'</id_param>";
            rs.open(filtroCargarParametro, '', filtroWhere, '', '');
            //if (!rs.eof()){
            //    if (dependiente){
            //        if (existe_en_array(id_param)){
            //            alert("El par�metro ya se encuentra asociado")
            //            return
            //        }
            //        else{
            //            var indice = parametros.length
            //            parametros[indice] = new Array()
            //            parametros[indice]['nro_par_nodo'] = rs.getdata('nro_par_nodo')
            //            parametros[indice]['par_nodo'] = rs.getdata('par_nodo')
            //            parametros[indice]['par_nodo_tipo'] = rs.getdata('par_nodo_tipo')
            //            parametros[indice]['par_nodo_tipo_desc'] = rs.getdata('par_nodo_tipo_desc')
            //            parametros[indice]['id_param'] = isNULL(rs.getdata('id_param'), '')
            //            parametros[indice]['param_tipo'] = isNULL(rs.getdata('param_tipo'), '')
            //            parametros[indice]['param_tipo_desc'] = isNULL(rs.getdata('param_tipo_desc'), '')
            //            parametros[indice]['nro_permiso_grupo'] = isNULL(rs.getdata('nro_permiso_grupo'), '')
            //            parametros[indice]['permiso_grupo'] = isNULL(rs.getdata('permiso_grupo'), '')
            //            parametros[indice]['nro_permiso_dep'] = isNULL(rs.getdata('nro_permiso'), '')
            //            parametros[indice]['permitir'] = isNULL(rs.getdata('permitir'), '')
            //            parametros[indice]['orden'] = isNULL(rs.getdata('orden'), 0)
            //            parametros[indice]['tiene_dependientes'] = false
            //            parametros[indice]['encriptar'] = rs.getdata('encriptar')
            //            parametros[indice]['hardcode_anterior'] = 0

            //            parametros_dibujar()
            //        }
            //    }
            //    else {
            //        $('nro_par_nodo').value = rs.getdata('nro_par_nodo')
            //        cargar()
            //    }
            //} 
            if (!rs.eof()) {
                        alert("El par�metro ya se encuentra asociado")
                campos_defs.set_value('id_param', '')
                campos_defs.set_value('param_tipo', '')
                campos_defs.set_value('nro_permiso_grupo', '')
                campos_defs.set_value('nro_permiso_dep', '')
                        return
                    }
            else {
                var rs_param = new tRS()
                rs_param.open(filtroSeleccionarParametro, '', filtroWhere)

                campos_defs.set_value('id_param', id_param)
                campos_defs.set_value('param_tipo', rs_param.getdata("param_tipo"))
                campos_defs.set_value('nro_permiso_grupo', rs_param.getdata("nro_permiso_grupo"))
                campos_defs.set_value('nro_permiso_dep', rs_param.getdata("nro_permiso"))
                if (rs_param.getdata("encriptar") == 'True') {
                    $('encriptarCheckbox').checked =  'checkeded'
                }
            } 
        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
    <input type="hidden" id="nro_par_nodo" value="<% = nodo_get %>"/> 
    <div id="divCabecera">
    <div id="divMenuABM"></div>
        <script type="text/javascript" language="javascript">
         var DocumentMNG = new tDMOffLine;
         var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
         vMenuABM.loadImage("guardar", '/FW/image/icons/guardar.png')
         vMenuABM.loadImage("eliminar", '/FW/image/icons/eliminar.png')
         vMenuABM.loadImage("buscar", "/FW/image/icons/file.png")
         vMenuABM.loadImage("nuevo", '/FW/image/icons/nueva.png')
         Menus["vMenuABM"] = vMenuABM
         Menus["vMenuABM"].alineacion = 'centro';
         Menus["vMenuABM"].estilo = 'A';
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar Par�metro</Desc><Acciones><Ejecutar Tipo='script'><Codigo>seleccionar_parametro(false)</Codigo></Ejecutar></Acciones></MenuItem>")  
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='3' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")  
         Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='4' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")
         vMenuABM.MostrarMenu()
         </script>  
       <table class="tb1" style="width:100%; table-layout:fixed;">
          <tr>
              <td style='width:14%' class="Tit1">&nbsp;</td>
              <td style='width:10%' class="Tit1">Tipo:</td>
              <td style="text-align:left" id="td_par_nodo_tipo">
              <%= nvFW.nvCampo_def.get_html_input("par_nodo_tipo", enDB:=False, nro_campo_tipo:=1, filtroWhere:="<par_nodo_tipo type='igual'>'%campo_value%'</par_nodo_tipo>",
              filtroXML:="<criterio><select vista='parametros_nodos_tipos'><campos>distinct par_nodo_tipo as id, par_nodo_tipo_desc as [campo]</campos><orden>[campo]</orden><filtro><par_nodo_tipo type='distinto'>'R'</par_nodo_tipo></filtro></select></criterio>")%>
              </td>
              <td style='width:10%' class="Tit1">Orden:</td>
              <td id="td_orden" style='width:10%'><%= nvFW.nvCampo_def.get_html_input("orden", nro_campo_tipo:=101, enDB:=False)%></td>
              <td style='width:15%' class="Tit1">&nbsp;</td>
          </tr>
       </table>
       <table class="tb1" style="width:100%">
          <tr>
              <td  class="Tit1" style='width:10%'>Depende:</td>
              <td style='width:75%' colspan="3" id="td_nro_par_nodo_dep"> <%= nvFW.nvCampo_def.get_html_input("nro_par_nodo_dep", enDB:=False, nro_campo_tipo:=1, filtroWhere:="<nro_par_nodo_dep type='igual'>'%campo_value%'</nro_par_nodo_dep>",
                                                filtroXML:="<criterio><select vista='verParametros_Nodos_dep'><campos>distinct nro_par_nodo as id, par_nodo as [campo]</campos><filtro><par_nodo_tipo type='igual'>'M'</par_nodo_tipo></filtro><orden>[campo]</orden></select></criterio>")%>
              </td>
          </tr> 
          <tr id="trpar_nodo">
             <td  class="Tit1" style='width:10%'>Descripci�n:</td>
             <td style='width:75%' colspan="3"><input type="text" id="par_nodo" value="" style="width:100%"/> 
             </td>
          </tr>
         <tr id="trPermisoGrupo">
              <td style='width:10%' class="Tit1">Grupo:</td>
              <td style='width:30%' id="td_nro_permiso_grupo"><%= nvFW.nvCampo_def.get_html_input("nro_permiso_grupo", enDB:=True, nro_campo_tipo:=1)%>
              </td>
              <td style='width:10%' class="Tit1">Permiso:</td>
              <td colspan="1" id="td_nro_permiso"> <%= nvFW.nvCampo_def.get_html_input("nro_permiso_dep", enDB:=True, nro_campo_tipo:=1)%>
              </td>
          </tr> 
          <tr id="trId_param">
            <td style='width:10%' class="Tit1" >Par�metro:</td>
            <td id='td_id_param'><%= nvFW.nvCampo_def.get_html_input("id_param", enDB:=False, nro_campo_tipo:=104)%></td>
            <td style='width:15%' class="Tit1" nowrap="nowrap">Tipo de dato:</td>
            <td id="td_param_tipo" style='width:20%'> <%= nvFW.nvCampo_def.get_html_input("param_tipo", enDB:=False, nro_campo_tipo:=1, filtroXML:="<criterio><select vista='parametros_tipos'><campos>distinct param_tipo as id, param_tipo_desc as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                                    filtroWhere:="<param_tipo type='igual'>'%campo_value%'</param_tipo>")%></td>
         </tr>
         <tr id="trId_paramValor">
            <td class="Tit1" style='width:8%'>Encriptar:</td>
            <td><input type="checkbox" id="encriptarCheckbox" /></td>
            <td style='width:15%' colspan="2" class="Tit1">&nbsp;</td>
         </tr>
       </table>
    </div>   
    <div id="divSoloparametros" style="display:none">
    <div id="divMenuABM1"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM1 = new tMenu('divMenuABM1', 'vMenuABM1');
     vMenuABM1.loadImage("explorer", '/FW/image/icons/file.png')
     vMenuABM1.loadImage("nuevo", '/FW/image/icons/nueva.png')
     Menus["vMenuABM1"] = vMenuABM1
     Menus["vMenuABM1"].alineacion = 'centro';
     Menus["vMenuABM1"].estilo = 'A';
     Menus["vMenuABM1"].CargarMenuItemXML("<MenuItem id='0' style='text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Dependientes</Desc></MenuItem>")
     //Menus["vMenuABM1"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>explorer</icono><Desc>Par�metros</Desc><Acciones><Ejecutar Tipo='script'><Codigo>seleccionar_parametro(true)</Codigo></Ejecutar></Acciones></MenuItem>")  
     Menus["vMenuABM1"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parametros_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")  

     vMenuABM1.MostrarMenu()
    </script>   
    <div id="divparametros" style="width:100%;overflow-y:scroll"></div>
    </div> 
</body>
</html>