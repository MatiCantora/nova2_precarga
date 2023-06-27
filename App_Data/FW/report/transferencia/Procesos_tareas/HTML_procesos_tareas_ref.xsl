<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl" />
	<xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes" />

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
    function dibujar_cabe_paramatros(cadena)
    {
     var salida = ""
     var arr = cadena.split(',')
     for (var i = 0; i < arr.length; i++)
      {
        salida = salida  + "campos_head.agregar('<xsl:value-of select=\"/xml/rs:data/z:row/@"+ arr[i] + "\"/>', true, '"+ arr[i] +"');"
      }
      
      return salida
    }
    ]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>HTML Procesos Tareas Ref</title>
				<!--<link href="css/base.css" type="text/css" rel="stylesheet"/>-->
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
				<!--<link href="/FW/css/btnSvr.css" type="text/css" rel="stylesheet" />-->
				<!--<link href="/FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />-->

				<script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
				<script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
				<script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
				<script type="text/javascript"  src="/FW/transferencia/script/transf_seg_utiles.js" language="javascript"></script>

				<script language="javascript" type="text/javascript">
					<xsl:comment>
						var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
						campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
						campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
						campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
						campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
						campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
						campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
						campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
						campos_head.orden = <xsl:value-of select="xml/params/@orden"/>

						if (mantener_origen == '0')
						campos_head.nvFW = parent.nvFW;
					</xsl:comment>
				</script>
				<!--definicion del template por defecto-->

				<script language="javascript" type="text/javascript">
					<xsl:comment>
						<![CDATA[
          function window_onload()
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
		           var divPie_height = $('divPie').getHeight()
			         $('divRow').setStyle({height: body_height - tbCabe_height - divPie_height - dif + 'px'})
               
               campos_head.resize("tbCabe", "tbRow")
			     
			        }
			       catch(e){}
            }

      function onmove_sel(indice,id_transf_log_det,avanzado)
			{
       $('tr_ver'+indice).addClassName('tr_cel')
       try{$('imgFinProcesar'+indice).show();$('imgEditar'+indice).show()}catch(e){}
			}
			
			function onout_sel(indice)
			{
			 $('tr_ver'+indice).removeClassName('tr_cel')
       try{$('imgFinProcesar'+indice).hide();$('imgEditar'+indice).hide()}catch(e){}
			}
			
     function verDetalle(indice)
     {
      if($('tr_ver'+ indice).className.indexOf('tr_cel_click') == 0)
			  {
			    $('tr_ver'+ indice).removeClassName('tr_cel_click')
			    $('trParametros' + indice).hide()
			  }
    		else
    		  {	   
			          var i = 1
			          while(i <= ($('tbRow').rows.length/2))
                  {
                    $('tr_ver'+ i).removeClassName('tr_cel')
   			            $('tr_ver'+ i).removeClassName('tr_cel_click')
                    try{ $('trParametros' + i).hide()}catch(e){}
                   i++
                  }
               
               $('trParametros' + indice).show()
               $('tr_ver'+ indice).addClassName('tr_cel_click')
         }
         
         window_onresize()
              
     }
     
     
]]>
					</xsl:comment>
				</script>
				<style type="text/css">
					.tr_cel TD { background-color: white !Important; }
					.tr_cel_click TD { background-color: #BDD3EF !Important; }
				</style>
			</head>
			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				<table class="tb1" id="tbCabe" >
					<tr class="tbLabel">
						<xsl:if test="string(/xml/rs:data/z:row/@transf_pt_param1_eti) != ''">
							<td nowrap='nowrap' style='width:15%;'>
								<script>
									campos_head.agregar('<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param1_eti"/>', true, 'transf_pt_param1')
								</script>&#160;
							</td >
						</xsl:if>
						<xsl:if test="string(/xml/rs:data/z:row/@transf_pt_param2_eti) != ''">
							<td nowrap='nowrap' style='width:15%;'>
								<script>
									campos_head.agregar('<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param2_eti"/>', true, 'transf_pt_param2')
								</script>&#160;
							</td >
						</xsl:if>
						<xsl:if test="string(/xml/rs:data/z:row/@transf_pt_param3_eti) != ''">
							<td nowrap='nowrap' style='width:15%;'>
								<script>
									campos_head.agregar('<xsl:value-of select="/xml/rs:data/z:row/@transf_pt_param3_eti"/>', true, 'transf_pt_param3')
								</script>&#160;
							</td >
						</xsl:if>
						<td>
							<script>
								campos_head.agregar('Procesos y Tareas', true, 'descripcion')
							</script>
						</td>
						<td style='width:10%;' nowrap='nowrap'>
							<script>
								campos_head.agregar('Vigente', true, 'vigente')
							</script>
						</td>
						<td nowrap='nowrap' style='width:5%;'>
							<script>
								campos_head.agregar('Ejecucion', true, 'async')
							</script>&#160;
						</td >
						<td nowrap='nowrap' style='width:5%;'>
							<script>
								Editar
							</script>&#160;
						</td >
						<!--<td class="Tit1" style='width:5%;'>&#160;-&#160;</td>-->
					</tr>
				</table>
				<div style="width:100%;overflow:auto" id="divRow">
					<table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>
				<div id="divPie" class="divPages">
					<script type="text/javascript">
						document.write(campos_head.paginas_getHTML())
					</script>
					<script type="text/javascript">
						campos_head.resize("tbCabe", "tbRow")
					</script>
				</div>
			</body>
		</html>
	</xsl:template>


	<xsl:template match="z:row">
		<xsl:variable name="pos" select="position()"/>
		<tr>
			<xsl:attribute name="id">
				tr_ver<xsl:value-of select="$pos"/>
			</xsl:attribute>
			<!--<xsl:attribute name="style">color:blue;text-decoration:underline;cursor:hand;cursor:pointer</xsl:attribute>-->
     <xsl:if test="@vigente = 'False'">
        <xsl:attribute name="style">
          color:red
        </xsl:attribute>
      </xsl:if>
			<!--<xsl:attribute name="onclick">parent.grupos_procesos_tareas_abm('<xsl:value-of select="@nro_transf_pt_ref"/>','<xsl:value-of select="@id_transferencia"/>')</xsl:attribute>-->
			<xsl:if test="string(@transf_pt_param1_eti) != ''">
				<td nowrap='nowrap' style='width:15%;'>
					<xsl:attribute name='title'>
						<xsl:value-of select="@transf_pt_param1"/>
					</xsl:attribute>
					<xsl:value-of select="@transf_pt_param1"/>
				</td>
			</xsl:if>
			<xsl:if test="string(@transf_pt_param2_eti) != ''">
				<td nowrap='nowrap' style='width:15%;'>
					<xsl:attribute name='title'>
						<xsl:value-of select="@transf_pt_param2"/>
					</xsl:attribute>
					<xsl:value-of select="@transf_pt_param2"/>
				</td>
			</xsl:if>
			<xsl:if test="string(@transf_pt_param3_eti) != ''">
				<td nowrap='nowrap' style='width:15%;'>
					<xsl:attribute name='title'>
						<xsl:value-of select="@transf_pt_param3"/>
					</xsl:attribute>
					<xsl:value-of select="@transf_pt_param3"/>
				</td>
			</xsl:if>
			<td>
				<xsl:attribute name='title'>
					<xsl:value-of select="@descripcion"/>
				</xsl:attribute>
				<xsl:value-of select="@descripcion"/>
			</td>
			<td style='width:10%;text-align:center'>
				<xsl:choose>
					<xsl:when test="string(@vigente) = 'True'">
						Si
					</xsl:when>
					<xsl:otherwise>
						No
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:choose>
					<xsl:when test="string(@async)='True'">
						Asincronica
					</xsl:when>
					<xsl:otherwise>
						Sincronica
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td>
				<xsl:attribute name="style">text-align:center</xsl:attribute>
				<img>
					<xsl:attribute name="style">cursor:hand</xsl:attribute>
					<xsl:attribute name="src">/fw/image/icons/editar.png</xsl:attribute>
					<xsl:attribute name="onclick">
						parent.grupos_procesos_tareas_abm('<xsl:value-of select="@nro_transf_pt_ref"/>','<xsl:value-of select="@id_transferencia"/>')
					</xsl:attribute>
				</img>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>