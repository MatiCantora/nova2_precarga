<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	
      <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
      <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl" />
      <xsl:include href="..\..\..\fw\report\xsl_includes\vb_campo_def.xsl" />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Comentarios de Rechazos</title>
               <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
              <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
              <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
              <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
              <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
              <script type="text/javascript" src="/precarga/script/tCampo_head.js" language="JavaScript"></script>
              <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
              <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
              <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'
                  if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW
                </script>

                <script type="text/javascript" language="javascript">
                    var nro_docu = '<xsl:value-of select="xml/parametros/nro_docu"/>'
                    var tipo_docu = '<xsl:value-of select="xml/parametros/tipo_docu"/>'
                    var sexo = '<xsl:value-of select="xml/parametros/sexo"/>'
                    var nro_credito = '<xsl:value-of select="xml/parametros/nro_credito"/>'
                    var fecha = '<xsl:value-of select="xml/parametros/fecha"/>'
                    var operador = '<xsl:value-of select="xml/parametros/operador"/>'
                    var nro_operador = '<xsl:value-of select="xml/parametros/nro_operador"/>'
                    <xsl:comment>
						<![CDATA[
						            
                        var vButtonItems = {}
                        vButtonItems[0] = {}
                        vButtonItems[0]["nombre"] = "Guardar"
                        vButtonItems[0]["etiqueta"] = "Guardar"
                        vButtonItems[0]["imagen"] = "guardar"
                        vButtonItems[0]["onclick"] = "return btnGuardarComentario()"

                        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
                        vListButtons.loadImage("guardar", "../../precarga/image/guardar.png");
    
    
                        function  window_onload()
                          {
                            vListButtons.MostrarListButton() 
                            window_onresize()
                          }
                          
						function window_onresize()
					      {
					       try
					          {
            			      var dif = Prototype.Browser.IE ? 5 : 2
					          var body_height = $$('body')[0].getHeight()
					          var tbCabe_height = $('tbCabe').getHeight()
					          var bt_guardar_height = $('divGuardar').getHeight()                               
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - bt_guardar_height - 50 - dif + 'px'})            					     
                              
                    $('tbDetalle').getHeight() - $('div_lst_creditos').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
					          }
					       catch(e){}
					     }
					     
					     function tdScroll_hide_show(show)
                          {
                           var i = 1
                           while(i <=  campos_head.recordcount)
                             {
                              if(show &&  $('tdScroll'+ i) != undefined)
                                 $('tdScroll'+ i).show() 
                                      
                              if(!show &&  $('tdScroll'+ i) != undefined)
                                 $('tdScroll'+ i).hide() 
                                   
                              i++
                             }
                          }            
                          
                          function seleccionar(indice)
					       {
					         $('tr_ver'+indice).addClassName('tr_cel')
					       }
                                 
					      function no_seleccionar(indice)
					       {
					         $('tr_ver'+indice).removeClassName('tr_cel')
					       }
					       
					      function seleccionar_todos(chkbox)
					       { 
					          var j = 1
					          for(i=0; ele = $('frm_com_tipo_rechazos').elements[i]; i++)
					           { 
					             if (ele.type == 'checkbox' && ele.id != 'check_all')
					                {  
							          if(chkbox.checked)
							           { 
							             ele.checked = 'checked'   
								         $('tr_ver'+j).addClassName('tbLabel')
								         $('comentario'+j).disabled = ''  
							           }	
							          else
							          {
							            ele.checked = ''   
							            $('tr_ver'+j).removeClassName('tbLabel')
							            $('comentario'+j).disabled = 'disabled'  
							           }
							          j++
							        } 
					            }
                          }
                             
                         function onclick_sel(indice)
                         {
                             if ($('check_'+indice).checked){
                                $('tr_ver'+indice).addClassName('tbLabel')
                                $('comentario'+indice).disabled = ''  
                             }
                             else{
                                $('tr_ver'+indice).removeClassName('tbLabel')
                                $('comentario'+indice).disabled = 'disabled'  
                             }
                         }
                         
                         var rechazos = new Array() 
					     var pos	
					     var nro_com_tipo
					     var comentario				      
					     
                         function btnGuardarComentario()
                         {
                           rechazos.length = 0
                           for(i=0; ele = $('frm_com_tipo_rechazos').elements[i]; i++)
					       { 
					         if (ele.type == 'checkbox' && ele.id != 'check_all')
					            {
							      if(ele.checked) {
							         pos = ele.id.split('_')[1]
							         nro_com_tipo = ele.value
							         comentario = $('comentario'+pos).value 
							         
							         var vacio = new Array()
							         vacio['nro_com_tipo'] = nro_com_tipo
							         vacio['comentario'] = comentario
							         rechazos.push(vacio)				
							      }
							    } 
					        }
					        
					        if (rechazos.length == 0)
					        {
                                alert('No selecciono ning�n comentario.')
                                return
                            }else
                            {
                                var strXML = "<?xml version='1.0' encoding='iso-8859-1' ?>"
                                strXML += "<comentarios nro_docu='" + nro_docu + "' tipo_docu='" + tipo_docu + "' sexo='" + sexo + "' nro_credito='" + nro_credito + "' nro_operador='" + nro_operador + "'>"
                                strXML += "<rechazos>"
                                
                                for(var i=0; i<rechazos.length; i++)
                                {                                     
                                    strXML += "<com_registro nro_com_tipo='" + rechazos[i]['nro_com_tipo'] + "'>"   
                                    comentario = rechazos[i]['comentario']
                                    if (comentario != '')
                                    {
                                        strXML += "<comentario><![CDATA["+ rechazos[i]['comentario'] + "]"
                                        strXML += "]></comentario>"
                                    }else{
                                        strXML += "<comentario></comentario>"
                                    }
                                    strXML += "</com_registro>"
                                }
                                                                
                                strXML += "</rechazos>"
                                strXML += "</comentarios>"
                            }     
                            
                            nvFW.error_ajax_request('../../precarga/ABMRegistro_rechazos.aspx', 
                            {
                             encoding: 'ISO-8859-1',
                             parameters: {modo: 'M', strXML: strXML},
                             onSuccess: function(err, transport)
                                        {
                                          if (err.numError == 0)
                                          {                                          
                                            var nro_credito = err.params['nro_credito']
                                            res = true
                                            var win = parent.nvFW.getMyWindow()
                                            win.options.userData = {res: res}
                                            win.close()
                                          }                                  
                                    
                                         },
                             onFailure: function (err, transport)   
                                        {}
                            });
                  
                         }

					   ]]>
					</xsl:comment>
				</script>
                <style type="text/css">
                    .tr_cel TD {
                    background-color: #f4f4f4 !Important
                    }
                    
                    .tr_cel_click TD {
                    background-color: #DFD6E0 !Important,
                    color : #0000A0 !Important
                    }
                </style>
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto">
                <form name="frm_com_tipo_rechazos" id="frm_com_tipo_rechazos">
                    <table width="100%" class="tb1" id="tbCabe">
                    <tr class="tbLabel">
                        <td style='text-align: center; width:5%'>
                            <input type="checkbox" name="check_all" id="check_all" style="border:none;">
                                <xsl:attribute name="onclick">seleccionar_todos(this)</xsl:attribute>
                            </input>
                        </td>
                        <td style='text-align: center; width: 29%'>Tipo</td>
                        <td style='text-align: center' nowrap='true'>Comentario</td>
                        <td style="width:1%">&#160;</td>
                    </tr>
                </table>
                <div id="div_lst_creditos" style="width:100%;overflow:auto">
                    <table class="tb1 highlightEven highlightTROver" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table>
                </div>
                <div id="divGuardar" style="width:100%"></div>
               </form>
			</body>
		</html>
	</xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>        
            <xsl:variable name="com_tipo" select="foo:replace(string(@com_tipo), 'Rechazado - ', '')"/>
            <td style='text-align: center; width:5%; '>
                <input type="checkbox" style="border:none;">
                    <xsl:attribute name="id">check_<xsl:value-of select="$pos"/></xsl:attribute>
                    <xsl:attribute name="value"><xsl:value-of select="@nro_com_tipo"/></xsl:attribute>
                    <xsl:attribute name="name"><xsl:value-of select="$pos"/></xsl:attribute>
                    <xsl:attribute name="onclick">onclick_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>
                </input>
            </td>
            <td style='text-align: left; width: 29%;'>
                <xsl:attribute name='title'><xsl:value-of select="$com_tipo" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="string-length($com_tipo) &#62; 53">
                        <xsl:value-of select="substring($com_tipo,1,53)"/>...
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$com_tipo"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td style='text-align: left;' nowrap='true'>
                <input type="textarea" style="width:100%;height:100%;" >
                    <xsl:attribute name="id">comentario<xsl:value-of select="$pos"/></xsl:attribute>
                    <xsl:attribute name="name">comentario<xsl:value-of select="$pos"/></xsl:attribute>
                    <xsl:attribute name="disabled">disabled</xsl:attribute>
                </input>
            </td>
            <td style='width:1% !Important'>
                <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;
            </td>
        </tr>
	</xsl:template>
</xsl:stylesheet>