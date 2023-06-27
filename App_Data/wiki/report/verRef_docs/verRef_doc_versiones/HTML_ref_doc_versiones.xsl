<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		
		var nro_ref_doc_tipo = -1
		var nro_ref_doc = -1
		var nro_linea = -1

		function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}

		function conv_fecha_to_str(cadena, modo)
          {
		  var objFecha = parseFecha(cadena)
		  var dia
		  var mes
		  var anio
		  var hora
		  var minuto
		  var segundo
		  if (objFecha.getDate() < 10)
		     dia = '0' + objFecha.getDate().toString()
		  else
		     dia = objFecha.getDate().toString() 
		  
		  if ((objFecha.getMonth() +1) < 10)
		     mes = '0' + (objFecha.getMonth()+1).toString()
		  else
		     mes = (objFecha.getMonth()+1).toString() 	 
		  anio = objFecha.getFullYear()  
		  
		  if (objFecha.getHours() < 10)
		     hora = '0' + objFecha.getHours().toString()
		  else
		     hora = objFecha.getHours().toString() 
			 
		 if (objFecha.getMinutes() < 10)
		     minuto = '0' + objFecha.getMinutes().toString()
		  else
		     minuto = objFecha.getMinutes().toString() 	 
		
		 if (objFecha.getSeconds() < 10)
		     segundo = '0' + objFecha.getSeconds().toString()
		  else
		     segundo = objFecha.getSeconds().toString() 	 	 
		  switch (modo)	 
		    {
			case 'mm/dd/aa':
			   return mes + '/' + dia + '/' + anio
			   break; 
			case 'dd/mm/aa':
			   return dia + '/' + mes + '/' + anio
			   break;    
			case 'dd/mm/aa hh:mm:ss':
			   return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + minuto + ':' + segundo
			   break;       
			}
    }
		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>Listado de versiones</title>
        <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
        <script type="text/javascript" language="javascript" src="/FW/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
        <script type="text/javascript" language='javascript' src="/FW/script/tcampo_head.js"></script>

        <script type="text/javascript" language="javascript">
        var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
        if (mantener_origen == '0')
          campos_head.nvFW = window.parent.nvFW
          
        <xsl:comment>
		<![CDATA[
					
		var arreglo = window.parent.version_todas
		arreglo['version']= new Array();
          
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
                                 
				    $('divDetalle').setStyle({height: body_height - tbCabe_height - dif + 'px'})
        					     
                    $('tbDetalle').getHeight() - $('divDetalle').getHeight() >= 0 ? tdScroll_hide_show(false) : tdScroll_hide_show(true)
			    }
			    catch(e){}
		    }         
    					    
		function tdScroll_hide_show(show)
          {
            var i = 1
            while(i <= campos_head.recordcount)
              {
                if(show &&  $('tdScroll'+ i) != undefined)
                  $('tdScroll'+ i).show() 
                                  
                if(!show &&  $('tdScroll'+ i) != undefined)
                  $('tdScroll'+ i).hide() 
                                  
                i++
              }
          }    
                            
		function seleccionar_version(ref_doc_version,nro_ref_doc,nro_ref)
		{
            parent.version_cargar(ref_doc_version,nro_ref_doc,nro_ref)
		}
	
		function acumular_versiones(checkeador,referencia,documento,nro_version)
		{  
            if (eval(checkeador).checked == false && arreglo['version'].length > 0)
			{						 
				arreglo['version'].each(function(arreglo_i,index_i)
				{
					if (arreglo_i['nro_version'] == nro_version && arreglo_i['nro_doc']== documento)
					{indice = index_i}
				}); 
				arreglo['version'].splice(indice,1) 
			} 
			else
			{
				if(arreglo['version'][0] == undefined)
				{
					arreglo['nro_ref']= referencia
				}
				indice = arreglo['version'].length
				arreglo['version'][indice]= new Array();
				arreglo['version'][indice]['nro_version'] = nro_version
				arreglo['version'][indice]['nro_doc']= documento
			}
		}
					
					]]>
         </xsl:comment>
				</script>
			</head>
      <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
          <table width="100%" class="tb1 " id="tbCabe">
          <tr class="tbLabel">
            <td style='text-align: center; width:4%' nowrap='true'>-</td>
            <td style='text-align: center; width:15%'>
              <script>
                campos_head.agregar('Versión', true, 'ref_doc_version')
              </script>
            </td>
            <td style='text-align: center; width:40%'>
              <script>
                campos_head.agregar('Documento', false, '')
              </script>
            </td>
            <td style='text-align: center; width:20%'>
              <script>
                campos_head.agregar('Fecha', true, 'ref_doc_fe_estado')
              </script>
            </td>
            <td style='text-align: center; width:20%'>
              <script>
                campos_head.agregar('Operador', true, 'nombre_operador')
              </script>
            </td>
            <td style="width:1%">&#160;</td>
          </tr>
        </table>
        <div id="divDetalle" style="width:100%;overflow:auto">
          <table class="tb1 highlightTROver" id="tbDetalle">
            <xsl:apply-templates select="xml/rs:data/z:row" />
          </table>
        </div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row" >
    <xsl:variable name="pos" select="position()"/>
    <tr>
      <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
      
			<td style="width:4%; text-align:left; vertical-align:middle">
				<xsl:if test="@ref_doc_activo = 'False'">
					<input type="checkbox" style="border:0">
						<xsl:attribute name="id">check<xsl:value-of select="$pos"/></xsl:attribute>
						<xsl:attribute name="onclick">
							acumular_versiones('check<xsl:value-of select="$pos"/>','<xsl:value-of select="@nro_ref"/>','<xsl:value-of select="@nro_ref_doc"/>','<xsl:value-of select="@ref_doc_version"/>')</xsl:attribute>
					</input>
				</xsl:if>
			</td>
			<td style="width:15%; text-align:left; vertical-align:middle">
				<a>
					<xsl:attribute name="href">
            javascript:seleccionar_version('<xsl:value-of select="@ref_doc_version"/>','<xsl:value-of select="@nro_ref_doc"/>','<xsl:value-of select="@nro_ref"/>')
					</xsl:attribute>
					<img src='/wiki/image/icons/vista_previa.png' border='0' align='absmiddle' hspace='2'></img>
					- <xsl:value-of select="@ref_doc_version"/>
				</a>
			</td>
      <xsl:if test="@ref_doc_activo = 'True'">
        <td style="width:40%; font-weight:bold; vertical-align:middle">
          <xsl:value-of select="@nro_ref_doc"/> - <xsl:value-of select="@ref_doc_titulo"/> (Activo)
        </td>
      </xsl:if>
      <xsl:if test="@ref_doc_activo = 'False'">
        <td style="width:40%; font-weight:none; vertical-align:middle">
          <xsl:value-of select="@nro_ref_doc"/> - <xsl:value-of select="@ref_doc_titulo"/>
        </td>
      </xsl:if>
			<td style="width:20%; vertical-align:middle">
				<xsl:value-of select="foo:conv_fecha_to_str(string(@ref_doc_fe_estado), 'dd/mm/aa hh:mm:ss')"/>
			</td>
			<td style="width:20%; vertical-align:middle">
				<xsl:value-of select="@nombre_operador"/>
			</td>
      <td style='width:1% !Important'>
        <xsl:attribute name='id'>tdScroll<xsl:value-of select="$pos"/></xsl:attribute>&#160;&#160;
      </td>
		</tr>
	</xsl:template>	
</xsl:stylesheet>