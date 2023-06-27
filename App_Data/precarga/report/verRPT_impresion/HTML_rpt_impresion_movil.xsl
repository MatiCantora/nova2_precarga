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
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <meta name="viewport" content="initial-scale=1"/>
                <title>Impresión de Reportes</title>
                <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
                <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />

                <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
                <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
                <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
                <script type="text/javascript" src="/precarga/script/precarga.js" ></script>
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
                
                    var rz_operador_logueado= '<xsl:value-of select="xml/parametros/rz_operador_logueado"/>'
                    var mailOL = '<xsl:value-of select="xml/parametros/mail_operador_logueado"/>'
                    operador_logueado = '<xsl:value-of select="xml/parametros/operador_logueado"/>'
                    operador = '<xsl:value-of select="xml/parametros/operador"/>'

                    if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW
                  </xsl:comment>
                </script>
                <script type="text/javascript"  class="table_window" >
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
							              
                              XLS_imprimir()
                              
                             if(operador_logueado != operador)
                               if(rz_operador_logueado != "")
                                $('op_operador_logueado').text += ": " + rz_operador_logueado
                             
                              if(rz_operador != "")
                               $('op_operador').text += ": " + rz_operador
                              
                              if(rz_vendedor != "")
                               $('op_vendedor').text += ": " + rz_vendedor
                              
                               window_onresize()
                              
                        } 
                          
						function window_onresize()
					      {
					       try
					          {
                    var divFiltro_h = parent.$('divMenu').getHeight()                      
                    var bodyHeight = parent.$$('body')[0].getHeight()
                    parent.$('frame_listado').setStyle({ height: bodyHeight - divFiltro_h + 'px' })
                    var iframe_h = parent.$('frame_listado').getHeight()
                    var tbCabe_height = $('tbCabe').getHeight() 
                    var tbPrint_height = $('tbRPTLeft').getHeight()*2 
                    //(isMobile()) ? $('tbRPTLeft').getHeight()*2 : $('tbRPTLeft').getHeight()
                    $('div_lst_creditos').setStyle({ height: iframe_h - tbCabe_height - tbPrint_height + 'px' })          					     
					          }
					       catch(e){}
					     }
					     
					       function seleccionar_todos(chkbox)
					        { 
							      var estado=$('check_all').checked
							      $$('#frm_rpt_impresion input[type=checkbox]').each(function(ele) {
							
								      if (ele.id != 'check_all')
								      {
								      ele.checked=estado;
								      }
							      })
							
					       }
           
            function RPT_imprimir(salida,mail)
            {
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
							
							  //*Reportes en estado vigentes y NO vigentes (Los NO vigentes se muestran siempre y cuando la fecha del estado no sea inferior a  la fecha actual)*//
							  filtroXML = "<criterio><procedure><parametros><nro_credito DataType='int'>" + nro_credito + "</nro_credito><rpt_todos>0</rpt_todos><nro_print_tipo DataType='int'>" + nro_print_tipo + "</nro_print_tipo></parametros></procedure></criterio>"
							  strName='SolicitudesActivas_'+nro_credito+'_'+strDate+'.xls'

                parent.filtroWhere = filtroXML
                parent.strName = strName
               }
					     
               function selEnviarA_onclick()
               {
                 
                 if($('selEnviarA').value == '')
                 {
                  alert("Seleccione un destinatario")
                 }
                 
                 if($('selEnviarA').value == 'OL')
                 {
                  RPT_imprimir('MAIL',mailOL)
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
                    <xsl:variable name="rpt_tipo" select="xml/rs:data/z:row/@rpt_tipo"/><input type="hidden" id="nro_print_tipo">
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
			 	         </tr>
            </table>
            <div id="div_lst_creditos" style="width:100%;overflow:auto">
                <table class="tb1" id="tbDetalle">
                    <xsl:apply-templates select="xml/rs:data/z:row" />
                </table>
            </div>
                  <div id="div_boton_imprimir" style="height:5%;width:100%;text-align:center;display:inline">
                    <table id="tbRPTLeft">
                      <tr>
                        <td style="width:25%">
                          <div id="divImprimir" style="width:100% !Important;text-align:center;float: left;margin-right:15px !Important"></div>
                        </td>
                        <td style="width:25%">
                          <div id="divEnviar" style="width:100% !Important;text-align:center;float: left;margin-right:5px !Important"></div>
                        </td>
                      </tr>
                    </table>
            <table id="tbRPTRight" class="tb1">
                      <tr>
                      <td>
                        <div id="divEnviarA" style="width:100%;text-align:center;float: left">
                          <select id="selEnviarA" style="width:100%;border:1px;display:inline;margin-top:3px">
                            <option value="">Seleccione el destinatario al que desea enviar el correo...</option>
                            <xsl:if test="string(xml/parametros/operador) != string(xml/parametros/operador_logueado)">
                              <option id="op_operador_logueado" value="OL">Operador conectado</option>
                            </xsl:if>
                            <option id="op_operador" value="O">Operador del crédito</option>
                            <option id="op_vendedor" value="V">Vendedor</option>
                            <option value="T">Otros...</option>
                          </select>
                        </div>
                      </td>
                    </tr>
                  </table>
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
		</tr>
	</xsl:template>
</xsl:stylesheet>

