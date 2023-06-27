<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

    <xsl:template match="/">
		<html>
			<head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

                <title>Impresión de Reportes</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
                <link href="/FW/css/window_themes/default.css" rel="stylesheet" type="text/css" />
                <link href="/FW/css/window_themes/alphacube.css" rel="stylesheet" type="text/css" />

                <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
                <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>

                <script language="javascript" type="text/javascript">
                  <xsl:comment>
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    nro_credito = '<xsl:value-of select="xml/parametros/nro_credito"/>'
                    mailO = '<xsl:value-of select="xml/parametros/mailO"/>'
                    mailV = '<xsl:value-of select="xml/parametros/mailV"/>'
                    rz_operador= '<xsl:value-of select="xml/parametros/rz_operador"/>'
                    rz_vendedor= '<xsl:value-of select="xml/parametros/rz_vendedor"/>'

                    if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW
                  </xsl:comment>
                </script>
                <script type="text/javascript"   >
						<![CDATA[
					            	var vButtonItems = new Array();
                        
                        vButtonItems[0] = new Array();
                        vButtonItems[0]["nombre"] = "Imprimir";
                        vButtonItems[0]["etiqueta"] = "Imprimir Reportes";
                        vButtonItems[0]["imagen"] = "imprimir";
                        vButtonItems[0]["onclick"] = "return RPT_imprimir('HTML','')";

                        vButtonItems[1] = new Array();
                        vButtonItems[1]["nombre"] = "Enviar";
                        vButtonItems[1]["etiqueta"] = "Enviar Correo a:";
                        vButtonItems[1]["imagen"] = "mail";
                        vButtonItems[1]["onclick"] = "return selEnviarA_onclick()";            
                         
                        var vListButton = new tListButton(vButtonItems, 'vListButton');
                        vListButton.loadImage("imprimir", '/fw/image/icons/imprimir.png')
                        vListButton.loadImage("mail", '/fw/image/icons/mail.gif')
                        
					    function window_onload()
                        {  
                            vListButton.MostrarListButton()
                            seleccionar_todos($('check_all'))
							              if ((window.top.permisos_rpt & 2) > 0) {
								              //  $('divImprimir').setStyle({width:'40%',float:'left'})
								              //  $('divExcel').setStyle({width:'35%',float:'left'})
								                $('divCheck').setStyle({float:'left'})
						                      }else
								              {
							              //	$('divImprimir').setStyle({width:'90%'})
								              $('divExcel').setStyle({display:'none'})
								              $('divCheck').setStyle({display:'none'})
								              }
                              
                              XLS_imprimir()
                              
                              $('op_operador').text += ": " + rz_operador
                              
                              if(rz_vendedor != "")
                               $('op_vendedor').text += ": " + rz_vendedor
                              
                            setTimeout("window_onresize()",100)
                              
                        } 
                          
						function window_onresize()
					      {
					       try
					          {
                    var dif = Prototype.Browser.IE ? 5 : 2
					           var body_height = $$('body')[0].getHeight()
					           var tbCabe_height = $('tbCabe').getHeight()
					           var div_boton_imprimir_height = $('div_boton_imprimir').getHeight()       
                     var div_boton_imprimir_pie_height = $('div_boton_imprimir_pie').getHeight()       

   				           $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_boton_imprimir_height - div_boton_imprimir_pie_height - dif + 'px'})            					     
					          }
					       catch(e){}
					     }
					     
					       function seleccionar_todos(chkbox)
					        { 
							      var estado=$('check_all').checked
							      $$('#frm_rpt_impresion input[type=checkbox]').each(function(ele) {
							
								      if (ele.id != 'check_all' && ele.id!='chkActivosRpt' && ele.id != 'chkUnicoRpt')
								      {
								      ele.checked=estado;
								      }
							      })
							
					       }
					       
					       function onclick_sel(indice, nro_rpt_def)
                            {
                             if ($('check_'+nro_rpt_def).checked)
                                $('tr_ver'+indice).addClassName('tr_cel_click')
                             else
                                $('tr_ver'+indice).removeClassName('tr_cel_click')
                            }
                            
           
           function RPT_imprimir_individual()
                {
                             
                  var fecha = new Date()
							 
							    $$('#frm_rpt_impresion input[type=checkbox]').each(function(ele) {
							 		
							    if (ele.id != 'check_all' &&  ele.id!='chkActivosRpt' && ele.id != 'chkUnicoRpt')
					            {
							        var i=0
								      var fecha_baja = ''
							            if(ele.checked) 
							            { i++
									      var strName=ele.id
									      var nro_rpt_def=strName.replace('check_','')
									      var rpt_name=$F('rpt_name_'+nro_rpt_def)
									      var fe_baja=$F('fe_baja_'+nro_rpt_def)
									      var rpt_nombre=$F('rpt_nombre_'+nro_rpt_def) 
									      var filtroXML=$F('filtroXML_'+nro_rpt_def)
									      filtroXML=eval(filtroXML)
								
									      var filtroWhere=$F('filtroWhere_'+nro_rpt_def)
									      filtroWhere=eval(filtroWhere)
								
									      var path_reporte=$F('path_'+nro_rpt_def)
									      //path_reporte=path_reporte.replace(new RegExp('/', 'g'),'\\\\')
									      path_reporte=eval(path_reporte)
									      if (fe_baja != '')
									      fecha_baja = parseFecha(fe_baja)        
									      else
									      fecha_baja = ''    
						                    
									      if ((fecha_baja == '') || (fecha_baja > fecha))
									      {
										        var win_id = "win_" + (i + ((Math.random() * 1000).floor()))
                                                    var ventana =  window.open('',win_id,'')
														   
											        nvFW.mostrarReporte
                                                    ({   
                                                      filtroXML: filtroXML,
                                                      filtroWhere: filtroWhere,
                                                      path_reporte: path_reporte,
                                                      report_name: rpt_name,
									                  salida_tipo: "adjunto",
									                  formTarget: win_id
												      })
													   
													   
                                            }//si el formulario esta vigente
							              }//checked
							          } //checkbox							 
		
							     });
              }
              
            function RPT_imprimir(salida,mail)
            {
            
            if(salida == 'HTML' && $('chkUnicoRpt').checked == false)
               {
                 RPT_imprimir_individual()
                 return
               }
              
              var rpt_defs = ""
					    for(i=0; ele = $('frm_rpt_impresion').elements[i]; i++)
					      { 
					        if (ele.type == 'checkbox' && ele.id != 'check_all' && ele.id!='chkActivosRpt' && ele.id != 'chkUnicoRpt')
					          {
							        if(ele.checked) 
							          { 
                          var id = ele.id.split("check_")[1]
                          if(id != undefined)
                            if(rpt_defs == '')
                              rpt_defs = id
                            else
                              rpt_defs = rpt_defs + "|" + id
                        }
							        } 
					      }
                     
                if(rpt_defs != "")
                  parent.imprimir_pdf(rpt_defs,salida,mail) 
                else
                  alert("seleccione al menos una definición")
              }
							 
					        
						   
						   function XLS_imprimir()
						   {
                var nro_print_tipo=$('nro_print_tipo').value
							  var filtroXML = ''
							  var strName=''							
							  var f=new Date();
							  var strDia=(f.getDate()<10)?'0'+f.getDate().toString():f.getDate().toString()
							  var strMes=(f.getMonth()<10)?'0'+f.getMonth().toString():f.getMonth().toString()
							  var strAnio=(f.getFullYear()<10)?'0'+f.getFullYear().toString():f.getFullYear().toString()
							  var strHH=(f.getHours()<10)?'0'+f.getHours().toString():f.getHours().toString()
							  var strMM=(f.getMinutes()<10)?'0'+f.getMinutes().toString():f.getMinutes().toString()
							  var strSS=(f.getSeconds()<10)?'0'+f.getSeconds().toString():f.getSeconds().toString()
							
							  var strDate=strAnio+strMes+strDia+'_'+strHH+strMM+strSS
							
							  if (((window.top.permisos_rpt & 2) > 0)&& $('chkActivosRpt').checked==false) {
							  //*Reportes en estado prueba/vigentes y NO vigentes (Los NO vigentes se muestran siempre y cuando la fecha del estado no sea inferior a  la fecha actual)*/
								  filtroXML = "<criterio><procedure><parametros><nro_credito DataType='int'>" + nro_credito + "</nro_credito><rpt_todos>1</rpt_todos><nro_print_tipo DataType='int'>" + nro_print_tipo + "</nro_print_tipo></parametros></procedure></criterio>"
								  strName='Solicitudes_'+nro_credito+'_'+strDate+'.xls'
							  } 
							  else 
							  {
							  //*Reportes en estado vigentes y NO vigentes (Los NO vigentes se muestran siempre y cuando la fecha del estado no sea inferior a  la fecha actual)*//
							  filtroXML = "<criterio><procedure><parametros><nro_credito DataType='int'>" + nro_credito + "</nro_credito><rpt_todos>0</rpt_todos><nro_print_tipo DataType='int'>" + nro_print_tipo + "</nro_print_tipo></parametros></procedure></criterio>"
							  strName='SolicitudesActivas_'+nro_credito+'_'+strDate+'.xls'
							  }

                parent.filtroWhere = filtroXML
                parent.strName = strName
               }
					     
               function selEnviarA_onclick()
               {
                 
                 if($('selEnviarA').value == '')
                 {
                  alert("Seleccione un destinatario")
                 }
                 
                 if($('selEnviarA').value == 'O')
                 {
                  RPT_imprimir('MAIL',mailO)
                 }
                 
                 if($('selEnviarA').value == 'V')
                 {
                  RPT_imprimir('MAIL',mailV)
                 }
               
                 if($('selEnviarA').value == 'T')
                 {
                  RPT_imprimir('MAIL','')
                 }
                 
               }
					     
					   ]]>
				</script>
				
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
                <form name="frm_rpt_impresion" id="frm_rpt_impresion" style="width:100%;height:100%;overflow:hidden">
                    <xsl:variable name="rpt_tipo" select="xml/rs:data/z:row/@rpt_tipo"/>
                  <input type="hidden" id="nro_print_tipo">
                    <xsl:attribute name="value"><xsl:value-of select="xml/rs:data/z:row/@nro_print_tipo"/></xsl:attribute>
                  </input>
                <table width="100%"  class="tb1" id="tbCabe">
						      <tr class="tbLabel">
											  <td style='text-align: center; width:4%'>
												  <input type="checkbox" checked="checked" id="check_all" style="width:100%;border:none"><xsl:attribute name="onclick">seleccionar_todos(this)</xsl:attribute></input>
											  </td>
											  <td style='text-align: center; width:58%;border:none'>
												  Descripción
											  </td>
											  <td style='text-align: center; width:15%;border:none'>
												  Versión
											  </td>							
											  <td style='text-align: center; width:18%;border:none'>
												  Tipo reporte
											  </td>
				        </tr>
            </table>
            <div id="div_lst_creditos" style="width:100%;overflow:auto">
                <table class="tb1" id="tbDetalle">
                    <xsl:apply-templates select="xml/rs:data/z:row" />
                </table>
            </div>
            <div id="div_boton_imprimir" style="height:5%;width:100%;text-align:center">
            <div id="divImprimir" style="width:20%;text-align:center;float: left;margin-right:15px"></div>
            <div id="divEnviar" style="width:15%;text-align:center;float: left;margin-right:5px"></div>
            <div id="divEnviarA" style="width:60%;text-align:center;float: left"><select id="selEnviarA" style="width:100%;border:none;display:inline;margin-top:3px"><option value="">Seleccione el destinatario al que desea enviar el correo...</option><option id="op_operador" value="O">Operador</option><option id="op_vendedor" value="V">Vendedor</option><option value="T">Otros...</option></select></div>
            </div>
            <div id="div_boton_imprimir_pie" style="height:5%;width:100%;text-align:left;padding-top:10px">
             <div id="divCheck" style="width:100%;float: left"><b>Opciones Avanzadas:</b>&#160;&#160;<input type="checkbox"  checked="checked" id="chkActivosRpt" style="border:none"/>&#160;Ver solo la documentación activa.&#160;&#160;&#160;&#160;<input type="checkbox"  checked="checked" id="chkUnicoRpt" style="border:none"/> Imprimir la documentación seleccionada en un solo documento.</div>
            </div>           
          </form>			
			</body>
		</html>
	</xsl:template>

	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
		<tr>
			<xsl:choose>
				<xsl:when test='@rpt_status="activo"'>
					<xsl:attribute name='style'></xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="prueba"'>
					<xsl:attribute name='style'>color:blue</xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="inactivo"'>
					<xsl:attribute name='style'>color:red</xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="pendiente"'>
					<xsl:attribute name='style'>color:green</xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="enretiro"'>
					<xsl:attribute name='style'>color:gray</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name='style'>color:black</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test='@rpt_status="prueba"'>
					<xsl:attribute name='title'>En estado de prueba</xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="inactivo"'>
					<xsl:attribute name='title'>Inactivo</xsl:attribute>
				</xsl:when>				
				<xsl:when test='@rpt_status="pendiente"'>
					<xsl:attribute name='title'>Pendiente de activarse</xsl:attribute>
				</xsl:when>
				<xsl:when test='@rpt_status="enretiro"'>
					<xsl:attribute name='title'>En estado de retiro</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>					
				</xsl:otherwise>
			</xsl:choose>
			

			<td style='text-align: center; width:4%' >				
                <input type="checkbox" style="width:100%;border:0px">
                    <xsl:attribute name="id">check_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="name">check_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
                    <xsl:attribute name="onclick">onclick_sel(<xsl:value-of select="$pos"/>,<xsl:value-of select="@nro_rpt_def"/>)</xsl:attribute>
                </input>
				<input type="hidden" >
					<xsl:attribute name="id">path_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of select="string(@rpt_path)"/>
					</xsl:attribute>
				</input>
				<input type="hidden">
					<xsl:attribute name="id">fe_baja_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of  select="string(@fe_baja)"/>
					</xsl:attribute>
				</input>
				<input type="hidden">
					<xsl:attribute name="id">rpt_name_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of  select="string(@rpt_name)"/>
					</xsl:attribute>
				</input>
				<input type="hidden">
					<xsl:attribute name="id">rpt_nombre_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of select="string(@rpt_nombre)"/>
					</xsl:attribute>					
				</input>
				<input type="hidden">
					<xsl:attribute name="id">filtroXML_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of select="string(@filtroXML)"/>
					</xsl:attribute>
				</input>
				<input type="hidden">
					<xsl:attribute name="id">filtroWhere_<xsl:value-of select="@nro_rpt_def"/></xsl:attribute>
					<xsl:attribute name="value">
						<xsl:value-of select="string(@filtroWhere)"/>
					</xsl:attribute>
				</input>
			</td>
            <td style='width:61%'>							
                <xsl:value-of select="@rpt_descripcion"/>
            </td>
			<td style='text-align: left; width:16%' >				
				<xsl:value-of select="@rpt_codigo"/>
			</td>			
			<td style='text-align: left; width:18%' >
				<xsl:value-of select="@rpt_tipo"/>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>

