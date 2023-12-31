<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    
    Dim filtroCargar = "<criterio><select vista=""permiso_nodos""><campos>*</campos><filtro></filtro><orden></orden></select></criterio>"
    Dim filtroTieneDependientes = "<criterio><select vista=""verPermiso_Nodos_Dep""><campos>*</campos><filtro></filtro><orden></orden></select></criterio>"
    Dim filtroPermisosCargar = "<criterio><select vista=""verPermiso_Nodos""><campos>*</campos><filtro></filtro><orden>per_orden</orden></select></criterio>"
    Dim filtroNodoPadre = "<criterio><select vista=""permiso_nodos""><campos>top 1 nro_per_nodo</campos><filtro></filtro><orden></orden></select></criterio>"
    Dim filtroPermisoAsociado = "<criterio><select vista=""permiso_nodos""><campos>top 1 nro_per_nodo</campos><filtro></filtro><orden></orden></select></criterio>"
    
    Dim modo as String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim nodo_get as String = nvFW.nvUtiles.obtenerValor("nodo_get", "")
    
    If (modo.ToUpper() = "GUARDAR") Then
    
        Dim err As nvFW.tError = New nvFW.tError()
        Try
            Dim strXML As String = ""
            'strXML = unescape(obtenerValor('strXML', ''))
            strXML = nvFW.nvUtiles.obtenerValor("strXML", "")
            
            Dim Cmd As Object = Server.CreateObject("ADODB.Command")
            
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "FW_permiso_nodos_abm"

            Dim pstrXML As ADODB.Parameter = Cmd.CreateParameter("@strXML", 201, 1, strXML.Length, strXML)
            Cmd.Parameters.Append(pstrXML)
            Dim rs = Cmd.Execute()
            
            Dim nro_per_nodo = rs.Fields("nro_per_nodo").Value
            err.params("nro_per_nodo") = nro_per_nodo
            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value
            
            nvFW.nvDBUtiles.DBDesconectar()
        Catch e As Exception
            nvFW.nvDBUtiles.DBDesconectar()
            err.parse_error_script(e)
        End Try
        err.response()
        
    End If


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <title>Permiso Nodo ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

        var alert =  function(msg){Dialog.alert(msg, {className: "alphacube", width:300, height:100, okLabel: "cerrar"}); }

        var filtroCargar = '<% =filtroCargar %>'
        var filtroTieneDependientes = '<% =filtroTieneDependientes %>'
        var filtroPermisosCargar = '<% =filtroPermisosCargar %>'
        var filtroNodoPadre = '<% =filtroNodoPadre %>'
        var filtroPermisoAsociado = '<% =filtroPermisoAsociado %>'

        var Permisos = new Array()
 
        function window_onload()
         {
              cargar()
              campos_defs.items["per_nodo_tipo"]['onchange'] = per_nodo_tipo_onchange
              campos_defs.items["per_nodo_tipo_ABM"]['onchange'] = per_nodo_tipo_ABM_onchange
              campos_defs.items["nro_permiso_grupo_ABM"]['onchange'] = per_nodo_tipo_ABM_onchange
              
              permisos_cargar()
         }

        function per_nodo_tipo_onchange() {

            if( campos_defs.value("per_nodo_tipo") == 'P')
            {
                campos_defs.habilitar("nro_permiso_grupo",true)
                campos_defs.habilitar("nro_permiso_dep",true)
                $("trPermisoGrupo").show()
                $("trPermiso").show()
                $("divSoloPermisos").hide()
                $("trPer_nodo").hide()
                permisos = new Array()   
            }

            if( campos_defs.value("per_nodo_tipo") == 'M')
            {
                campos_defs.clear("nro_permiso_grupo")
                campos_defs.clear("nro_permiso_dep")
                campos_defs.habilitar("nro_permiso_grupo",false)
                campos_defs.habilitar("nro_permiso_dep",false)
                $("trPermisoGrupo").hide()
                $("trPermiso").hide()
                $("divSoloPermisos").show()
                $("trPer_nodo").show()
            }   
  
            window_onresize()
        }

        function cargar()
        { 
            var filtroWhere = "<nro_per_nodo type='igual'>"+ $('nro_per_nodo').value +"</nro_per_nodo>";
            var i = 0
            var rs = new tRS();
            rs.open(filtroCargar, '', filtroWhere, '', '')
            if(!rs.eof())
                {
                 $('per_nodo').value = rs.getdata('per_nodo')
                 $('per_orden').value = rs.getdata('per_orden') != null ? rs.getdata('per_orden') : 0
                 if(rs.getdata("nro_per_nodo_dep") != null)
                   campos_defs.set_value("nro_per_nodo1",rs.getdata("nro_per_nodo_dep"))
                 campos_defs.set_value("per_nodo_tipo",rs.getdata("per_nodo_tipo"))
                 campos_defs.set_value("nro_permiso_grupo",rs.getdata("nro_permiso_grupo") == null? "" : rs.getdata("nro_permiso_grupo"))
                 campos_defs.set_value("nro_permiso_dep",rs.getdata("nro_permiso") == null ? "" : rs.getdata("nro_permiso"))
         
                 per_nodo_tipo_onchange()
         
                 if(es_nodo_padre($('nro_per_nodo').value) || campos_defs.value("per_nodo_tipo") == 'P')
                   campos_defs.habilitar("per_nodo_tipo",false)
                }
              else
                {
                 campos_defs.set_value("per_nodo_tipo","M")
                 per_nodo_tipo_onchange()
                }  
        
         }

        function nuevo()
        {
         if($('nro_per_nodo').value > 0 && campos_defs.value("per_nodo_tipo") == 'M')
           campos_defs.set_value("nro_per_nodo1",$('nro_per_nodo').value)
         else
           campos_defs.clear("nro_per_nodo1")
 
         permisos = new Array()   
         $('divPermisos').innerHTML = ''
  
         $('nro_per_nodo').value = 0
         $('per_nodo').value = ''
         $('per_orden').value = ''
         campos_defs.habilitar("nro_permiso_grupo",true)
         campos_defs.habilitar("nro_permiso_dep",true)
         campos_defs.habilitar("per_nodo_tipo",true)
         $("trPermisoGrupo").show()
         $("trPermiso").show()
         $("trPer_nodo").show()
         campos_defs.clear("nro_permiso_grupo")
         campos_defs.clear("nro_permiso_dep")
         campos_defs.clear("per_nodo_tipo")
 
         $('divSoloPermisos').hide()
 
         window_onresize()
        }

        function tiene_dependientes()
        { 
            var res = false
            var filtroWhere = "<nro_per_nodo_dep type='igual'>"+ $('nro_per_nodo').value +"</nro_per_nodo_dep>";
            var rs = new tRS();
            rs.open(filtroTieneDependientes, '', filtroWhere, '', '')
            if (!rs.eof())
                res = true;

            return res;
        }

        function eliminar() 
            {
    
               if($('nro_per_nodo').value == 0 || $('nro_per_nodo').value == '')
                return

               if(es_nodo_padre($('nro_per_nodo').value))
                {
                    alert('El elemento tiene m�dulos o permisos asociados.')
                    return
                }
      
       
               Dialog.confirm('�Desea eliminarlo?', { width: 350,
                                className: "alphacube",
                                okLabel: "Si",
                                cancelLabel: "No",
                                onOk: function(win) {
                                                     $('nro_per_nodo').value  = $('nro_per_nodo').value * -1
                                                     guardar()
                                                     win.close()
                                                     },
                                onCancel: function(win) {
                                    win.close()
                                    return
                                }
                            });
            }  


        function guardar()
        {
 
         var strError = ''
 
         if(campos_defs.value("nro_permiso_grupo") == '' && campos_defs.value("per_nodo_tipo") == 'P')
           strError = "Ingrese el permiso grupo.</br>"
 
         if(campos_defs.value("nro_permiso_dep") == '' && campos_defs.value("per_nodo_tipo") == 'P')
           strError += "Ingrese el permiso.</br>"
 
         if(campos_defs.value("per_nodo_tipo") == '')
           strError += "Ingrese el tipo.</br>"

         if(parseInt($('nro_per_nodo').value) >= 0 && campos_defs.value("per_nodo_tipo") == 'P' && campos_defs.value("nro_permiso_grupo") != '' && campos_defs.value("nro_permiso_dep") != '')
          if(permiso_asociado($('nro_per_nodo').value,campos_defs.value("nro_permiso_grupo"),campos_defs.value("nro_permiso_dep"))) 
            strError += "El permiso grupo junto con el permiso</br>ya se encuentran asociados.</br>" 
 
         if($("per_nodo").value == '' && campos_defs.value("per_nodo_tipo") != 'P')
           strError += "Ingrese la descripci�n.</br>"
   
         if(campos_defs.value("nro_per_nodo1") == $("nro_per_nodo").value)
           strError += "El nodo no pude depender de si mismo. Verifique.</br>"
   
         if(strError != '')
          {
           alert(strError)
           return
          }  
   
           //borrar
           if(campos_defs.value("per_nodo_tipo") == 'P')
              $("per_nodo").value == ''
  
          xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?>"
          xmldato += "<nodos>"
          xmldato += "<nodo nro_per_nodo = '" + $('nro_per_nodo').value + "' hijo='N' per_orden ='" + $('per_orden').value + "' nro_per_nodo_dep = '" + campos_defs.value('nro_per_nodo1') + "' per_nodo_tipo='" + campos_defs.value("per_nodo_tipo") + "' nro_permiso_grupo='" + campos_defs.value("nro_permiso_grupo") + "' nro_permiso='" + campos_defs.value('nro_permiso_dep')+ "'>"
                      per_nodo = '<![CDATA[' + $('per_nodo').value + ']]>'
          xmldato += "<per_nodo>" + per_nodo + "</per_nodo>"
          xmldato += "</nodo>"

          permisos.each(function(arreglo, i) 
                  {
                     desc = arreglo['per_nodo_tipo'] == 'M' ? arreglo['per_nodo'] : ''
                     xmldato += "<nodo nro_per_nodo = '" + arreglo['nro_per_nodo'] + "' hijo='S' per_orden ='" + i + "' nro_per_nodo_dep = '" + $('nro_per_nodo').value + "' per_nodo_tipo = '" + arreglo['per_nodo_tipo'] + "' nro_permiso_grupo ='" + arreglo['nro_permiso_grupo'] + "' nro_permiso ='" + arreglo['nro_permiso'] + "'>"
                     xmldato += "<per_nodo><![CDATA["+ desc +"]]></per_nodo>"
                     xmldato += "</nodo>"
                  });

          xmldato += "</nodos>" 
  
          nvFW.error_ajax_request('permiso_nodos_abm.aspx', {
                                     parameters: { modo: 'GUARDAR', strXML: xmldato },
                                     onSuccess: function(err, transport){
                                                 if (err.numError != 0)
                                                   {
                                                     alert(err.mensaje)
                                                     return
                                                   }
                                                 else {
                                                     nro_per_nodo = err.params['nro_per_nodo']
                                                     win.options.userData = 'refresh'
                                                     nro_per_nodo1 = campos_defs.value("nro_per_nodo1")

                                                     if (nro_per_nodo1) {
                                                         var zeroString = "0000";
                                                         var nro_per_nodo1 = zeroString.substring((nro_per_nodo1 + "").length, 5) + nro_per_nodo1;
                                                     }
                                                     parent.vTree.recargar_node(nro_per_nodo1)

                                                     win.close()
                                                  }
                                                }
                                            });  


        }

        var win = nvFW.getMyWindow()

        function window_onresize()
        {
            try
            {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var cab_height = $('divCabecera').getHeight()
                var div_permisos_abm_height = $('div_permisos_abm').getHeight()
                var divMenuABM1_height = $('divMenuABM1').getHeight()
                $('divPermisos').setStyle({'height': body_height - cab_height - div_permisos_abm_height  - divMenuABM1_height - dif + 'px'})
            }
            catch(e){}  
        }

        var permisos = new Array()
        function permisos_cargar() 
        {
            permisos = new Array()
            var k = 0
            var rs = new tRS();
            var vacio
            rs.async = true
            rs.onComplete = function(rs)
            {     
                while (!rs.eof()) 
                {
                    vacio = new Array()
                    vacio['nro_per_nodo'] = rs.getdata('nro_per_nodo')
                    vacio['per_nodo'] = rs.getdata('per_nodo')
                    vacio['per_nodo_tipo'] = rs.getdata('per_nodo_tipo')
                    vacio['per_nodo_tipo_desc'] = rs.getdata('per_nodo_tipo_desc')
                    vacio['nro_permiso_grupo'] = rs.getdata('nro_permiso_grupo')
                    vacio['permiso_grupo'] = rs.getdata('permiso_grupo')
                    vacio['nro_permiso'] = rs.getdata('nro_permiso')
                    vacio['permitir'] = rs.getdata('Permitir')
                    vacio['per_orden'] = rs.getdata('per_orden') != null ? rs.getdata('per_orden') : 0
                    vacio['tiene_dependientes'] = es_nodo_padre(vacio['nro_per_nodo']) 
                    permisos[k] = vacio
                    k++
                    rs.movenext()
                }
            permisos_dibujar()
            }
            var filtroWhere = "<per_nodo_tipo type='distinto'>'R'</per_nodo_tipo><nro_per_nodo_dep type='igual'>" + $('nro_per_nodo').value + "</nro_per_nodo_dep>";
            rs.open(filtroPermisosCargar, '', filtroWhere, '', '')
        
            campos_defs.set_value("per_nodo_tipo_ABM","M")
            per_nodo_tipo_ABM_onchange()
        }
        
        function permisos_dibujar() 
        {
            if (permisos.length >= 0) 
                {
                $('divPermisos').innerHTML = ''
                
                var strHTML = '<table id="tb_permisos" class="tb1" style="width:100%; vertical-align: top;">'
                    strHTML += '<tr class="tbLabel0">'
                    strHTML += '<td style="width:5%;text-align:center">-</td>'
                    strHTML += '<td style="width:15%;text-align:center">Tipo</td>'
                    strHTML += '<td style="text-align:center">Descripci�n</td>'
                    strHTML += '<td style="width:2%;text-align:center">-</td>'
                    strHTML += '<td style="width:10px;text-align:center">-</td>'
                    strHTML += '</tr>'

                    permisos.each(function(arreglo, i) {
       
                    if(arreglo['nro_per_nodo'] >= 0)
                    {
                        ver = '<input type="radio" name="ver_permiso" id="ver_permiso_'+ i + '" value="' + i + '" onclick="editar_permiso(this);" style="border:none"></input>'

                        per_nodo_tipo_desc = arreglo['per_nodo_tipo_desc']
                        per_nodo_tipo = arreglo['per_nodo_tipo']
                        permiso_grupo = arreglo['permiso_grupo']
                        
                        desc = ''
                        trColor = ''
                        if(per_nodo_tipo == 'M')
                            {
                            desc = arreglo['per_nodo']
                            desc = (desc.length > 60) ? desc.substr(0,60) : desc
                            trColor = 'style="color:blue"'
                            }
                        else
                            {
                            desc = arreglo['permitir'] + ' - ' + arreglo['permiso_grupo']
                            desc = (desc.length > 60) ? desc.substr(0,60) : desc
                            }
                             
                        strHTML += '<tr '+ trColor +'>'
                        strHTML += "<td style='width:5%;text-align:center'>" + ver + "</td>"
                        strHTML += '<td style="width:15%;text-align:left" title="'+arreglo['per_nodo_tipo_desc']+'">' + per_nodo_tipo_desc + '</td>'               
                        strHTML += '<td style="text-align:left" title="'+ desc +'">' + desc + '</td>'               
                        
                        if(arreglo['nro_per_nodo'] == 0 || !arreglo['tiene_dependientes'] )
                            strHTML += '<td style="width:2%; text-align:center"><img alt="" title="Eliminar" src="/fw/image/icons/eliminar.png" style="cursor:pointer;cursor:hand" onclick="eliminar_permiso('+ i +')" /></td>'
                        else
                            strHTML += '<td style="width:2%; text-align:center">&nbsp;&nbsp;&nbsp;</td>'
                        strHTML += '<td style="width:10px;text-align:center"><a href="#" onclick="subir(' + i + ')"><img src="/FW/image/icons/up_a.png" border="0" hspace="0"/></a><a href="#" onclick="bajar(' + i + ')"><img src="/FW/image/icons/down_a.png" border="0" hspace="0"/></a></td>'
                        strHTML += '</tr>'
                    }   
                });
                strHTML += '</table>'

                $('divPermisos').insert({ top: strHTML })    
            }

            window_onresize()
            
         }

         function editar_permiso(_this) {

            var indice = _this.value
            var k = indice



            if ((k != '') && (permisos[k] != undefined))
            {
                campos_defs.habilitar('per_nodo_tipo_ABM',true)    
             
                $('indice').value = k
                $('nro_per_nodo_ABM').value = permisos[k]['nro_per_nodo'] == null ? '' : permisos[k]['nro_per_nodo']
                $('per_nodo_ABM').value = permisos[k]['per_nodo'] == null ? '' : permisos[k]['per_nodo']

                nro_permiso_grupo = permisos[k]['nro_permiso_grupo'] == null ? '' : permisos[k]['nro_permiso_grupo']
                nro_permiso = permisos[k]['nro_permiso'] == null ? '' : permisos[k]['nro_permiso']
                per_nodo_tipo = permisos[k]['per_nodo_tipo'] == null ? '' : permisos[k]['per_nodo_tipo']

                campos_defs.set_value('per_nodo_tipo_ABM', per_nodo_tipo)
                campos_defs.set_value('nro_permiso_grupo_ABM', nro_permiso_grupo)
                campos_defs.set_value('nro_permiso_ABM', nro_permiso)

                if($('nro_per_nodo_ABM').value > 0)
                    campos_defs.habilitar('per_nodo_tipo_ABM',false)

            }
         }
        
         function aceptar_permiso()
         {
            var indice = parseInt($('indice').value)   
            var nro_per_nodo = $('nro_per_nodo_ABM').value                    
            var per_nodo = $('per_nodo_ABM').value                    
            var nro_permiso_grupo = campos_defs.value('nro_permiso_grupo_ABM')
            var nro_permiso = campos_defs.value('nro_permiso_ABM')
            var permiso_grupo = campos_defs.desc('nro_permiso_grupo_ABM').split('  (')[0]
            var permitir = campos_defs.desc('nro_permiso_ABM').split('  (')[0]
            var per_nodo_tipo = campos_defs.value('per_nodo_tipo_ABM')
            var per_nodo_tipo_desc = campos_defs.desc('per_nodo_tipo_ABM').split('  (')[0]
        
            if(!si_es_borrado_activar(nro_permiso_grupo,nro_permiso))
                {        
                if (per_nodo_tipo == "")
                {
                    alert('Por favor, seleccione el tipo.')
                    return 
                }

                if (per_nodo_tipo == "P")
                    {
                    if (nro_permiso_grupo == "")
                    {
                        alert('Por favor, seleccione el grupo de permiso.')
                        return 
                    }
                
                    if (nro_permiso == "")
                    {
                        alert('Por favor, seleccione el permiso.')
                        return 
                    }

                    if(permiso_asociado(nro_per_nodo,nro_permiso_grupo,nro_permiso) || existe_en_array(nro_permiso_grupo,nro_permiso)) 
                    {
                        alert('El permiso grupo junto con el permiso</br>ya se encuentran asociados.')
                        return 
                    }

                    }
                else
                    { 
                    if (per_nodo == "")
                    {
                        alert('Por favor,  ingrese la descripci�n.')
                        return 
                    }
                    }        

                    if (indice === '' || nro_per_nodo == 0)
                        indice = permisos.length
                
                    permisos[indice] = new Array()
                    permisos[indice]['nro_per_nodo'] = (nro_per_nodo != '' && nro_per_nodo > 0) ? nro_per_nodo : 0
                    permisos[indice]['per_nodo'] = per_nodo
                    permisos[indice]['per_nodo_tipo'] = per_nodo_tipo
                    permisos[indice]['per_nodo_tipo_desc'] = per_nodo_tipo_desc
                    permisos[indice]['nro_permiso_grupo'] = nro_permiso_grupo
                    permisos[indice]['permiso_grupo'] = permiso_grupo
                    permisos[indice]['nro_permiso'] = nro_permiso
                    permisos[indice]['permitir'] = permitir
                    permisos[indice]['per_nodo_tipo'] = per_nodo_tipo
                    permisos[indice]['per_nodo_tipo_desc'] = per_nodo_tipo_desc
                    permisos[indice]['per_orden'] = permisos_orden()
                    permisos[indice]['tiene_dependientes'] = false
                }  
          
                permisos_dibujar()   
                permisos_nuevo()   
                
          }        

          function permisos_orden()
          {
                var per_orden = 0
                if (permisos.length > 0)
                {
                    permisos.each(function(arreglo, i) {
                        per_orden  = (parseInt(arreglo['per_orden']) > parseInt(per_orden )) ? arreglo['per_orden'] : per_orden 
                    })
                }
                return per_orden 
          }

        function bajar(orden) 
        {
            var len = permisos.size()
            var orden_dest = -1
            for (var i = orden + 1; i < len; i++)
                if (permisos[i] >= 0) {
                orden_dest = i
                break;
            }

            if (orden_dest != -1) {
                var a = permisos[orden]
                permisos[orden] = permisos[orden_dest]
                permisos[orden_dest] = a
                permisos_dibujar()
            }
        }
    
        function subir(orden) 
        {
            var len = permisos.size()
            var orden_dest = -1
            for (var i = orden - 1; i >= 0; i--)
                if (permisos[i] >= 0) {
                orden_dest = i
                break;
            }

            if (orden_dest != -1) {
                var a = permisos[orden]
                permisos[orden] = permisos[orden_dest]
                permisos[orden_dest] = a
                permisos_dibujar()
            }
        }
   
        function permisos_nuevo()
        {
            $('nro_per_nodo_ABM').value = 0
            $('per_nodo_ABM').value = ''
            campos_defs.clear('nro_permiso_grupo_ABM')
            campos_defs.clear('nro_permiso_ABM')
  
            campos_defs.clear('per_nodo_tipo_ABM')
            campos_defs.habilitar('per_nodo_tipo_ABM',true)
            campos_defs.set_value('per_nodo_tipo_ABM', 'P')

            per_nodo_tipo_ABM_onchange()
         }    

        function per_nodo_tipo_ABM_onchange()
        {
              if(campos_defs.value('per_nodo_tipo_ABM') == 'P')
               {
                $('per_nodo_ABM').value = ''
        
                $('td_nro_permiso_grupo_ABM').show()
                $('td_nro_permiso_ABM').show()
                $('td_per_nodo_ABM').hide()
                $('td_nro_permiso_grupo_ABM_Cab').show()
                $('td_nro_permiso_ABM_Cab').show()
                $('td_per_nodo_ABM_Cab').hide()
               } 
              else
               {
                campos_defs.clear('nro_permiso_grupo_ABM')
                campos_defs.clear('nro_permiso_ABM')

                $('td_nro_permiso_grupo_ABM').hide()
                $('td_nro_permiso_ABM').hide()
                $('td_per_nodo_ABM').show()
                $('td_nro_permiso_grupo_ABM_Cab').hide()
                $('td_nro_permiso_ABM_Cab').hide()
                $('td_per_nodo_ABM_Cab').show()
               }         
        }
     
        function eliminar_permiso(indice) 
        {
               Dialog.confirm('�Desea eliminarlo?', { width: 350,
                                className: "alphacube",
                                okLabel: "Si",
                                cancelLabel: "No",
                                onOk: function(win) {
                                                     if(permisos[indice]['nro_per_nodo'] > 0)
                                                      permisos[indice]['nro_per_nodo'] = parseInt(permisos[indice]['nro_per_nodo']) * -1
                           
                                                     if(permisos[indice]['nro_per_nodo']== 0)
                                                         permisos.splice(indice, 1) 
                                             
                                                     permisos_dibujar()
                                                     win.close()
                                             
                                                     },
                                onCancel: function(win) {
                                    win.close()
                                    return
                                }
                            });
        }  
         
        function permiso_asociado(nro_per_nodo,nro_permiso_grupo,nro_permiso) 
        {
            var existe = false;
            var filtro_nodo = "";
            
            if (nro_per_nodo != 0)
                filtro_nodo = "<nro_per_nodo type='distinto'>" + nro_per_nodo + "</nro_per_nodo>";

            var filtroWhere = filtro_nodo + "<nro_permiso type='igual'>" + nro_permiso + "</nro_permiso><nro_permiso_grupo type='igual'>" + nro_permiso_grupo + "</nro_permiso_grupo>";

            var rs = new tRS();
            rs.open(filtroPermisoAsociado, '', filtroWhere, '', '');
            if (!rs.eof()) 
                existe = true
            
            return existe
        }            
        
        function es_nodo_padre(nro_per_nodo) 
        {
            var existe = false
            var filtro_nodo = ""
            
            if(nro_per_nodo == 0)
                return existe
            else
                filtro_nodo = "<nro_per_nodo_dep type='igual'>" + nro_per_nodo + "</nro_per_nodo_dep>"
            
            var rs = new tRS()
            var filtroWhere = filtro_nodo;
            rs.open(filtroNodoPadre, '', filtroWhere, '', '')
            if (!rs.eof()) 
                existe = true
            
            return existe
        }            

        function si_es_borrado_activar(nro_permiso_grupo,nro_permiso) 
        {
            var activo = false
            permisos.each(function(arreglo, i)
            {
                if(arreglo.nro_permiso_grupo == nro_permiso_grupo && arreglo.nro_permiso == nro_permiso)
                    if(parseInt(arreglo.nro_per_nodo) < 0)
                    {
                    arreglo.nro_per_nodo  = parseInt(arreglo.nro_per_nodo)* -1 
                    activo = true
                    } 
            });
           
            return activo  
         }   

        function existe_en_array(nro_permiso_grupo,nro_permiso) 
        {
            var existe = false
            permisos.each(function(arreglo, i)
            {
                if(parseInt(arreglo.nro_permiso_grupo) == parseInt(nro_permiso_grupo) && parseInt(arreglo.nro_permiso) == parseInt(nro_permiso))
                    existe = true
            });
           
            return existe 
        }   

        
</script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
<form name="FrmOP" id="FrmOP" action="" style="width:100%;height:100%;overflow:hidden">
    <input type="hidden" id="nro_per_nodo" value="<%= nodo_get%>"/> 
    <div id="divCabecera">
    <div id="divMenuABM"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM = new tMenu('divMenuABM','vMenuABM');
     Menus["vMenuABM"] = vMenuABM
     Menus["vMenuABM"].alineacion = 'centro';
     Menus["vMenuABM"].estilo = 'A';
     //Menus["vMenuABM"].imagenes = Imagenes //Imagenes se declara en pvUtiles

     vMenuABM.loadImage("guardar", '/FW/image/icons/nueva.png')
     vMenuABM.loadImage("eliminar", '/FW/image/icons/nueva.png')
     vMenuABM.loadImage("nuevo", '/FW/image/icons/nueva.png')

     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")  
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminar()</Codigo></Ejecutar></Acciones></MenuItem>")  
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='3' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")  
     vMenuABM.MostrarMenu()
    </script>  
       <table style="width:100%">
          <tr>
          <td style='width:20%' class="Tit1">Tipo:</td>
          <td>
            <div id="td_per_nodo_tipo"></div>
            <script type="text/javascript">
                campos_defs.add('per_nodo_tipo', { enDB: true,
                    target: 'td_per_nodo_tipo',
                    nro_campo_tipo: 1
                })

            </script></td>
          <td style='width:5%' class="Tit1">Orden:</td>
          <td style='width:5%' id="td_per_orden">
              <script type="text/javascript">
                  campos_defs.add('per_orden', {
                      enDB: false,
                      target: 'td_per_orden',
                      nro_campo_tipo: 101
                  });
              </script>
          </td>
          </tr> 
          <tr id="trPer_nodo">
             <td style='width:20%' class="Tit1" >Descripci�n:</td>
             <td colspan="3"> 
               <input type="text" id="per_nodo" value="" style="width:100%"/> 
             </td>
          </tr>
          <tr>
          <td style='width:20%' class="Tit1">Depende:</td>
          <td colspan="3">
            <div id="td_nro_per_nodo1"></div>
            <script type="text/javascript">
                campos_defs.add('nro_per_nodo1', { enDB: true,
                    target: 'td_nro_per_nodo1',
                    nro_campo_tipo: 1
                });
            </script>
          </td>
          </tr> 
          <tr id="trPermisoGrupo">
          <td style='width:20%' class="Tit1">Permiso Grupo:</td>
          <td colspan="3" id="td_nro_permiso_grupo">
            <script type="text/javascript">
                   campos_defs.add('nro_permiso_grupo', {
                                                         despliega: 'arriba',
                                                         enDB: false,
                                                         target: 'td_nro_permiso_grupo',
                                                         nro_campo_tipo: 1,
                                                         filtroXML: "<criterio><select vista='Operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                                         filtroWhere: "<nro_permiso_grupo type='igual'>%campo_value%</nro_permiso_grupo>",
                                                         depende_de: null,
                                                         depende_de_campo: null
                                                        })
         </script>
          </td>
          </tr> 
          <tr id="trPermiso">
          <td style='width:20%' class="Tit1">Permiso Detalle:</td>
          <td colspan="3" id="td_nro_permiso"> 
           <script type="text/javascript">
                   campos_defs.add('nro_permiso_dep', {      
                                                    despliega: 'arriba',
                                                    enDB: false,
                                                    target: 'td_nro_permiso',
                                                    nro_campo_tipo: 1,
                                                    filtroXML: "<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id, Permitir as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                                    filtroWhere: "<nro_permiso type='igual'>%campo_value%</nro_permiso>",
                                                    depende_de: "nro_permiso_grupo",
                                                    depende_de_campo: "nro_permiso_grupo"
                                                  })
           </script>
          </td>
          </tr> 
       </table>
    </div>   
    <div id="divSoloPermisos" style="display:none">
    <div id="divMenuABM1"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM1 = new tMenu('divMenuABM1','vMenuABM1');
     Menus["vMenuABM1"] = vMenuABM1
     Menus["vMenuABM1"].alineacion = 'centro';
     Menus["vMenuABM1"].estilo = 'A';
     //Menus["vMenuABM1"].imagenes = Imagenes //Imagenes se declara en pvUtiles

     vMenuABM1.loadImage("nuevo", '/FW/image/icons/nueva.png')

     Menus["vMenuABM1"].CargarMenuItemXML("<MenuItem id='0' style='text-align:left'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Permisos</Desc></MenuItem>")
     Menus["vMenuABM1"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo Permiso</Desc><Acciones><Ejecutar Tipo='script'><Codigo>permisos_nuevo()</Codigo></Ejecutar></Acciones></MenuItem>")  

     vMenuABM1.MostrarMenu()
    </script>   
    <div id="divPermisos" style="width:100%;overflow-y:scroll"></div>
    <div id="div_permisos_abm">
      <table id="tb_perfil_param_def_am" class="tb1" style="table-layout:fixed;">
        <tr class="tbLabel0">
            <td style='width:5%;text-align:center'>-</td>
            <td style="width:25%;text-align:center">Tipo</td>
            <td style="text-align:center" id="td_per_nodo_ABM_Cab">Descripci�n</td>
            <td style="width:20%;text-align:center" id="td_nro_permiso_grupo_ABM_Cab">Grupo Permiso</td>
            <td style="width:20%;text-align:center" id="td_nro_permiso_ABM_Cab">Permiso</td>
            <td style="width:4%;text-align:center">-</td>
        </tr>
        <tr>
         <td style="width:5%;text-align:center"><input type="hidden" id="indice" name="indice" value="" style="width:100%"/><input type="text" id="nro_per_nodo_ABM" name="nro_per_nodo_ABM" disabled="disabled" value="" style="width:100%"/></td>
         <td style="width:15%;text-align:left" id="td_per_tipo">
            <script type="text/javascript">
                   campos_defs.add('per_nodo_tipo_ABM', {    despliega: 'arriba',
                                                             enDB: false,
                                                             target: 'td_per_tipo',
                                                             nro_campo_tipo: 1,
                                                             filtroXML: "<criterio><select vista='permiso_nodos_tipos'><campos>distinct per_nodo_tipo as id, per_nodo_tipo_desc as [campo]</campos><orden>[campo]</orden><filtro><per_nodo_tipo type='distinto'>'R'</per_nodo_tipo></filtro></select></criterio>",
                                                             filtroWhere: "<per_nodo_tipo type='igual'>%campo_value%</per_nodo_tipo>"
                                                         })
           </script>
         </td>
         <td style="text-align:center" id="td_per_nodo_ABM"><input type="text" id="per_nodo_ABM" name="per_nodo_ABM" value="" style="width:100%"/></td>
         <td style="width:20%;text-align:left" id="td_nro_permiso_grupo_ABM">
         <script type="text/javascript">
                   campos_defs.add('nro_permiso_grupo_ABM', {
                                                             despliega: 'arriba',
                                                             enDB: false,
                                                             target: 'td_nro_permiso_grupo_ABM',
                                                             nro_campo_tipo: 1,
                                                             filtroXML: "<criterio><select vista='Operador_permiso_grupo'><campos>distinct nro_permiso_grupo as id, permiso_grupo as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                                             filtroWhere: "<nro_permiso_grupo type='igual'>%campo_value%</nro_permiso_grupo>",
                                                             depende_de: null,
                                                             depende_de_campo: null
                                                             })
         </script>
         </td>
         <td style="width:20%;text-align:left" id="td_nro_permiso_ABM">
            <script type="text/javascript">
                   campos_defs.add('nro_permiso_ABM', {      despliega: 'arriba',
                                                             enDB: false,
                                                             target: 'td_nro_permiso_ABM',
                                                             nro_campo_tipo: 1,
                                                             filtroXML: "<criterio><select vista='operador_permiso_detalle'><campos>distinct nro_permiso as id, Permitir as [campo] </campos><orden>[campo]</orden></select></criterio>",
                                                             filtroWhere: "<nro_permiso type='igual'>%campo_value%</nro_permiso>",
                                                             depende_de: "nro_permiso_grupo_ABM",
                                                             depende_de_campo: "nro_permiso_grupo"
                                                             })
           </script>
         </td>
         <td style="width:4%;text-align:center"><img alt="" title="Aceptar" src="/fw/image/icons/agregar.png" style="cursor:pointer;cursor:hand" onclick="aceptar_permiso()" /></td>
        </tr>
      </table>
    </div>   
    </div> 
 </form>
</body>
</html>