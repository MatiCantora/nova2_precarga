<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl"  />
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<html>
			<head>
        <title></title>
        <link href="css/base.css" type="text/css" rel="stylesheet"/>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>

        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script language="javascript" type="text/javascript">
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          if (mantener_origen == '0')
          campos_head.nvFW = window.top.nvFW
        </script>

                <style type="text/css">
                  .tr_cel TD
                  {
                  background-color: white !Important
                  }
                  .tr_cel_click TD
                  {
                  background-color: #BDD3EF !Important,
                  color : #0000A0 !Important
                  }            

                </style>
                <script>
					<xsl:comment>
						<xsl:if test="count(xml/rs:data/z:row) > 0" >
						   var nro_entidad = '<xsl:value-of select="xml/rs:data/z:row/@nro_entidad"/>'
						   var bandera = '<xsl:value-of select="xml/rs:data/z:row/@bandera"/>'
                           var id_tipo = '<xsl:value-of select="xml/rs:data/z:row/@id_tipo"/>'
                           var nro_com_id_tipo = '<xsl:value-of select="xml/rs:data/z:row/@nro_com_id_tipo"/>'
                           var nro_com_grupo = '<xsl:value-of select="xml/rs:data/z:row/@nro_com_grupo"/>'
                        </xsl:if>
						<xsl:if test="count(xml/rs:data/z:row) = 0" >
                            var nro_entidad = ''
                            var bandera = ''
                            var id_tipo = ''
                            var nro_com_id_tipo = ''
                            var nro_com_grupo = ''
                        </xsl:if>

                        var visible = 'siempre'
                        var filtro_grupo = '<xsl:value-of select="xml/parametros/filtro_grupo"/>'

                        <![CDATA[										
						
					     function nodo_onclick(nro_registro)
                         {
					       var tb = $('tbH' + nro_registro)
					       var imgG = $('imgG' + nro_registro)
					       if (tb.style.display == 'none')
					          {
						        imgG.src = '/fw/image/comentario/menos.jpg'
					            tb.style.display = 'inline'
						        }
					       else 
					          {
						        imgG.src = '/fw/image/comentario/mas.jpg'
						        tb.style.display = 'none'
						        }
                         }
             
                         function onmove_sel(indice)
			               {
					        $('tr_ver'+indice).addClassName('tr_cel')
					       }
            					
					     function onout_sel(indice)
					       {
					         $('tr_ver'+indice).removeClassName('tr_cel')
					       }
					   
		                function window_onload()
		                {						
		                  // mostramos los botones creados
			              window_onResize();
		                }
						
			            function window_onResize()
			            {
			            /*
				            try{
				                 var dif = Prototype.Browser.IE ? 5 : 2
					             body_height = $$('body')[0].getHeight()
					             alto = body_height - dif - 8
					             $('div_registro').setStyle({height : alto})
					            }
					            catch(e){}*/
			            }
						
			            function com_parametros_expand(nro_registro)
			            {
				            //var imgP = $('imgP' + nro_registro)
				            var div_parametros = $('div' + nro_registro)
				            div_parametros.innerHTML = ''
				            if (visible == 'siempre')
					            {
					             visible = 'todos'
					             //imgP.src = '/fw/image/comentario/menos.jpg'
					             //html_parametros = '<div id="divReg_'+nro_registro+'" style="width: 100%"><table id="tbReg_' + nro_registro + '" class="tb1" style=""><tr class="tbLabel0"><td colspan="2" style="FONT-SIZE: 11px;">Parametros <a href="javascript: com_parametros_expand(' + nro_registro + ')"><img src="/fw/image/comentario/menos.jpg" border="0" align="absmiddle" hspace="1" id="imgP' + nro_registro + '"/></a><td><tr></table>'
                       html_parametros = parent.Ver_com_parametros(nro_registro, visible, 0)
					            }
				            else
					            {
					             visible = 'siempre'
					            // imgP.src = '/fw/image/comentario/mas.jpg'
				                 html_parametros = parent.Ver_com_parametros(nro_registro, visible, 1)	
					            }
				          
				            div_parametros.insert({top: html_parametros})
			            }
			            
						
	   ]]>
		</xsl:comment>
	</script>
</head>
<body onload="return window_onload()" onresize="return window_onResize()" style="width:100%;height:100%;overflow:hidden">
	<xsl:variable name="nro_com_grupo" select="xml/rs:data/z:row/@nro_com_grupo" />
	<xsl:variable name="nro_entidad" select="xml/rs:data/z:row/@nro_entidad" />
    			<div id="div_registro" style="width:100%; overflow:auto;height:100%;">
					<xsl:apply-templates select="xml/rs:data/z:row[@depende = 0]"/>
				</div>
				</body>
			</html>
		</xsl:template>

		<xsl:template match="z:row">
            <xsl:variable name="pos" select="position()"/>
			<xsl:variable name="nro_registro" select="@nro_registro"/>
            <xsl:variable name="hijos" select="count(/xml/rs:data/z:row[@nro_registro_depende = $nro_registro])"/>
      
			<table cellspacing="0" cellpadding="0">
				<xsl:if test="count(@nro_registro_depende) = 0">
					<xsl:attribute name="style">border-top: solid gray 3px</xsl:attribute>
				</xsl:if>
				<xsl:if test="count(@nro_registro_depende) != 0">
					<xsl:attribute name="style">border-top: solid silver 1px</xsl:attribute>
				</xsl:if>
				<tr>
				   <xsl:attribute name="id">tr_ver<xsl:value-of select="$nro_registro"/></xsl:attribute>
	               <xsl:attribute name="onmousemove">onmove_sel(<xsl:value-of select="$nro_registro"/>)</xsl:attribute>
	               <xsl:attribute name="onmouseout">onout_sel(<xsl:value-of select="$nro_registro"/>)</xsl:attribute>
				
					<td style='text-align: left; FONT-SIZE: 10px; !Important'>
						<xsl:if test="$hijos > 0">
							<img src='/fw/image/comentario/menos.jpg' border='0' align='absmiddle' hspace='1'>
								<xsl:attribute name="id">imgG<xsl:value-of select="@nro_registro"/></xsl:attribute>
								<xsl:attribute name='onclick'>return nodo_onclick('<xsl:value-of select='@nro_registro'/>')</xsl:attribute>
							</img>
						</xsl:if>
						<xsl:if test="$hijos = 0">
							<img src='/fw/image/comentario/punto.jpg' border='0' align='absmiddle' hspace='1'/>
						</xsl:if>
					</td>
					<td nowrap='true' style='text-align: left; FONT-SIZE: 10px; !Important; width: 200px'>
						<xsl:attribute name='onmouseover'>this.title="<xsl:value-of select="foo:HoraToSTR(string(@fecha))"/>"; return</xsl:attribute>
						<b>
							<span>
								<xsl:attribute name="style">
									<xsl:value-of select="@style"/>
								</xsl:attribute>
									<img src='/fw/image/comentario/comentario.png' style='cursor:pointer' border='0' align='absmiddle' hspace='1'>
										<xsl:attribute name='onclick'>return parent.ABMRegistro('<xsl:value-of select='@nro_entidad'/>',<xsl:value-of select='@id_tipo'/>,<xsl:value-of select='@nro_com_id_tipo'/>, <xsl:value-of select='@nro_registro'/>, <xsl:value-of select='@nro_com_tipo'/>, <xsl:value-of select='@nro_com_estado'/>)</xsl:attribute>
									</img>
								&#160;<u>
									<xsl:value-of select="@com_tipo"/> (<xsl:value-of select="@com_estado"/>)
								</u>
							</span>
							<br/>
							<xsl:value-of select="foo:FechaToSTR(string(@fecha))"/>
							<img src='/fw/image/comentario/user.png' border='0' align='absmiddle' hspace='1'/>
							<xsl:value-of select="@nombre_operador"/>
						</b>
					</td>
					<td style="FONT-SIZE: 11px; !Important; text-indent: 5px; width: 100%; ">
                         <xsl:value-of select="@comentario" disable-output-escaping = "yes" />
                         <xsl:if test="@html_parametros != ''">
							<div>
								<xsl:attribute name="id">div<xsl:value-of select="@nro_registro"/></xsl:attribute>
								<xsl:value-of select="@html_parametros" disable-output-escaping = "yes" />
							</div>
						</xsl:if>			
					</td>
			</tr>
		</table>
		<xsl:if test="$hijos > 0">
			<table style="width: 100%" cellspacing="0" cellpadding="0">
				<xsl:attribute name="id">tbH<xsl:value-of select="@nro_registro"/></xsl:attribute>
				<tr>
				   <xsl:attribute name="id">tr_ver<xsl:value-of select="$nro_registro"/><xsl:value-of select="$pos"/><xsl:value-of select="$hijos"/></xsl:attribute>
	               <xsl:attribute name="onmousemove">onmove_sel(<xsl:value-of select="$nro_registro"/><xsl:value-of select="$pos"/><xsl:value-of select="$hijos"/>)</xsl:attribute>
	               <xsl:attribute name="onmouseout">onout_sel(<xsl:value-of select="$nro_registro"/><xsl:value-of select="$pos"/><xsl:value-of select="$hijos"/>)</xsl:attribute>
					<td style="width: 15px;">
						<xsl:text disable-output-escaping="yes">&#x26;nbsp;</xsl:text>
					</td>
					<td>
						<xsl:apply-templates select="/xml/rs:data/z:row[@nro_registro_depende = $nro_registro]" />
					</td>
				</tr>
			</table>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>