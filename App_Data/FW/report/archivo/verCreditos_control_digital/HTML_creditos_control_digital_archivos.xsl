<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">
  
    <xsl:include href="..\..\..\fw\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
    <xsl:include href="..\..\..\fw\report\xsl_includes\js_formato.xsl"/>
  
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Créditos Control Digital</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
        <script type="text/javascript" src="/FW/script/swfobject.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
        <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
        <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
        <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>					
					var fecha_hasta = '<xsl:value-of select="xml/parametros/fecha_hasta"/>'
					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW
				</script>
                <script type="text/javascript">
					<![CDATA[ 				
					function  window_onload()
                          {
                            window_onresize()
                          }
                          
						function window_onresize()
					      {
					       try
					          {
            			      var dif = Prototype.Browser.IE ? 5 : 2
					          var body_height = $$('body')[0].getHeight()
					          var tbCabe_height = $('tbCabe').getHeight()
					          var div_pag_height = $('div_pag').getHeight()
                                     
					          $('div_lst_creditos').setStyle({height: body_height - tbCabe_height - div_pag_height - dif + 'px'})            					     
                              
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
					 
					function mostrar_creditos(e,nro_credito,link)
						{
                            var path = "../../meridiano/credito_mostrar.aspx?nro_credito=" + nro_credito
                            var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'
                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'
                            
                            if (e.ctrlKey) //con la tecla "Ctrl", abre una nueva pestaña
                            $(link).href = path;
                            else {if (e.altKey){ //con la tecla "Alt", abre una ventana emergente
									window.top.abrir_ventana_emergente(path, descripcion, undefined, undefined, 500, 1000, true, true, true, true, false)                                   
									}
									else{ 
										if (e.shiftKey)
										{ //con la tecla "Shift", abre una nueva ventana _blank
										$(link).target = '_blank'
										$(link).href = path;                                 
										}
										else
										{ 
										parent.mostrar_creditos(nro_credito)
										}                            
									}
								}
					     }
						 
				function abrir_archivos(nro_credito)
						 {
						 parent.abrir_archivos(nro_credito)
						 }						 
					
					]]>
				</script>
                <style type="text/css">
                    .tr_cel TD {
                    background-color: #F0FFFF !Important
                    }
                </style>
			</head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto">
				<form name="frm1" id="frm1">
					<table class="tb1" id="tbCabe" >
						<tr class="tbLabel">
							<td style='width:72px'>
                                <script type="text/javascript">
									campos_head.agregar('Nro', 'true', 'nro_archivo')
                                </script>
							</td>
							<td style='width:282px'>
                                <script type="text/javascript">
									campos_head.agregar('Descripción', 'false', 'archivo_descripcion')
                                </script>
							</td>
							<td style='width:152px'>
								<script type="text/javascript">
									campos_head.agregar('Operador', 'false', 'nombre_operador')
								</script>
							</td>
							<td style='width:152px'>
                                <script type="text/javascript">
									campos_head.agregar('Fecha', 'false', 'momento')
								</script>
							</td>
							<td style='width:152px'>
                                <script type="text/javascript">
									campos_head.agregar('Origen', 'false', 'img_origen')
								</script>
							</td>
							<td style='width:222px'>
								<script type="text/javascript">
									campos_head.agregar('Definición', 'false', 'def_archivo')
								</script>
							</td>
							<td style='width:102px'>
                                <script type="text/javascript">
									campos_head.agregar('Nro. Crédito', 'false', 'nro_credito')
								</script>
							</td>
							<td nowrap='true'>-</td>
							<td style="width:15px">&#160;</td>
						</tr>
					</table>
					<div style="width:100%; height:370px ;overflow-y:auto;" id="div_lst_creditos">						
						<table class="tb1 highlightEven highlightTROver" id="tbDetalle">
							<xsl:apply-templates select="xml/rs:data/z:row" />
						</table>
					</div>
                    <div id="div_pag" class="divPages">
                        <script type="text/javascript">
                            document.write(campos_head.paginas_getHTML())
                        </script>
                    </div>
					</form>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
	  <tr>
          <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
		  <td style='text-align: center; width:70px'>
			  <a>
				  <xsl:attribute name="target">_blank</xsl:attribute>
				  <xsl:attribute name="href">../../meridiano/get_file.aspx?nro_archivo=<xsl:value-of select="@nro_archivo"/></xsl:attribute>
				  <xsl:value-of  select="format-number(@nro_archivo,'000000000')" />
			  </a>
		  </td>
		  <td style='width:280px'>
			  <xsl:attribute name='title'><xsl:value-of select="@archivo_descripcion"/></xsl:attribute>
			  <xsl:choose>
				  <xsl:when test="string-length(@archivo_descripcion) &#62; 52">
					  <xsl:value-of select="substring(@archivo_descripcion,1,52)"/>...
				  </xsl:when>
				  <xsl:otherwise>
					  <xsl:value-of select="@archivo_descripcion"/>
				  </xsl:otherwise>
			  </xsl:choose>
		  </td>
		  <td style='width:150px'>
			  <xsl:value-of select="@nombre_operador"/>
		  </td>
		  <td style='text-align: center; width:150px'>
			  <xsl:value-of select="foo:FechaToSTR(string(@momento))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@momento))"/>
		  </td>
		  <td style='width:150px'>
			  <xsl:value-of select="@img_origen"/>
		  </td>
		  <td style='width:220px'>
			  <xsl:value-of select="@def_archivo"/>
		  </td>
		  <td style='text-align: center; width:100px'>
			  <a>
				  <xsl:attribute name="target">_blank</xsl:attribute>
				  <xsl:attribute name="href">../../meridiano/credito_mostrar.aspx?nro_credito=<xsl:value-of select="@nro_credito"/></xsl:attribute>
				  <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
			  </a>
		  </td>
		  <td style='text-align: center'>
			  <a>
				  <xsl:attribute name='href'>../../meridiano/get_file.aspx?nro_archivo=<xsl:value-of  select="@nro_archivo" /></xsl:attribute>
				  <xsl:attribute name='target'>verDocumento</xsl:attribute>
				  <img border='0' src="../image/icons/Notepad.gif" style="vertical-align:middle"></img>
			  </a>
		  </td>	  
		  <td style='width:15px !Important'>
			  <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;
		  </td>
	  </tr>		
	</xsl:template>
</xsl:stylesheet>