<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl" />
  <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
    
    ]]>    
  </msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title></title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>
        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
          campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
          campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
          campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
          if (mantener_origen == '0')
            campos_head.nvFW = parent.nvFW          
        </script>
				<!--definicion del template por defecto-->

        <script language="javascript" type="text/javascript">
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
			     
			        }
			         catch(e){}
                 try
                    {
                     campos_head.resize("tbCabe","tbRow")                  
                    }
                    catch(e){}
            }

                     
       	    function onmove_sel(indice)
			      {
			       $('tr_ver'+indice).addClassName('tr_cel')
			      }
			
			      function onout_sel(indice)
			      {
			       $('tr_ver'+indice).removeClassName('tr_cel')
			      }
			
		
]]>

        </script>
        <style type="text/css">
          .tr_cel TD
          {
          background-color: white !Important
          }
          .tr_cel_click TD
          {
          background-color: #BDD3EF !Important
          }
        </style>

			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
               <table class="tb2" id="tbCabe">
                 <tr class="tbLabel">
                   <td nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Nro. Operador', true, 'operador')
                     </script>
                     <script>
                       campos_head.agregar('Operador', true, 'login')
                     </script>
                   </td>
                   <td  style='width:120px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Nro. Documento', true, 'nro_docu')
                     </script>
                   </td>
                   <td  style='width:130px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Apellido', true, 'apellido')
                     </script>
                     <script>
                       campos_head.agregar('Nombres', true, 'nombres')
                     </script>
                   </td>
                   <td  style='width:150px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Sucursal', true, 'sucursal')
                     </script>
                   </td>
                   <td style='width:120px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Fecha Alta', true, 'fe_alta')
                     </script>
                   </td>
                   <td  style='width:120px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Fecha Baja', true, 'fe_baja')
                     </script>
                   </td>
                   <td  style='width:80px;' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Estado', true, 'vencido')
                     </script>
                   </td>
                 </tr>
                 </table>
                <div style="width:100%;overflow:auto" id="divRow">
                  <table class="tb2" id="tbRow">
                   <xsl:apply-templates select="xml/rs:data/z:row" />
                 </table>
               </div>
             
         <div id="divPie" class="divPages">               
           <script type="text/javascript">
             document.write(campos_head.paginas_getHTML())
           </script>
         </div>
	  </body>
	</html>
 </xsl:template>
	
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="tipo_operador" select="@tipo_operador"></xsl:variable>
      <tr>
        <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
        <xsl:attribute name="onmousemove">onmove_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>
        <xsl:attribute name="onmouseout">onout_sel(<xsl:value-of select="$pos"/>)</xsl:attribute>
        <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
        <xsl:attribute name="ondblclick">parent.parent.abm_operadores(<xsl:value-of select="@operador"/>)</xsl:attribute>
        
     <xsl:choose>
       <xsl:when test ="@estado = 'vencido'">
         <xsl:attribute name="style">cursor:hand;cursor:pointer;color:red !Important</xsl:attribute>
       </xsl:when >
       <xsl:otherwise>
         <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
       </xsl:otherwise>
     </xsl:choose >
    <td style="" >
      <xsl:if test="string(@operador) != ''">
       <!--<img>
            <xsl:attribute name="onclick">parent.parent.abm_operadores(<xsl:value-of select="@operador"/>)</xsl:attribute>
            <xsl:attribute name="src">/FW/image/icons/editar.png</xsl:attribute>
            <xsl:attribute name="style">cursor:hand;cursor:pointer;border:0px</xsl:attribute>
            <xsl:attribute name="title">Editar Operador</xsl:attribute>
       </img>&#160;-->
      
       <xsl:attribute name='title'>
        <xsl:value-of select="@operador"/> - <xsl:value-of select="@Login"/>
       </xsl:attribute>
       <xsl:choose>
        <xsl:when test="string-length(@Login) &#62; 50">
          <xsl:value-of select="@operador"/> - <xsl:value-of select="substring(@Login,1,50)"/>...
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@operador"/> - <xsl:value-of select="@Login"/>
        </xsl:otherwise>
      </xsl:choose>
       </xsl:if > 
    </td>
    <td style="width:118px">
          <xsl:attribute name='title'>
            <xsl:value-of select="@documento"/> - <xsl:value-of select="@nro_docu"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="string-length(@nro_docu) &#62; 20">
              <xsl:value-of select="@documento"/> - <xsl:value-of select="substring(@nro_docu,1,20)"/>...
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@documento"/> - <xsl:value-of select="@nro_docu"/>
            </xsl:otherwise>
          </xsl:choose>
    </td>    
    <td style="width:128px">
      <xsl:if test ="string(@apellido) != '' or string(@nombres) != ''">
        <xsl:attribute name='title'>
          <xsl:value-of select="concat(@apellido,', ',@nombres)"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="string-length(concat(@apellido,', ',@nombres)) &#62; 20">
            <xsl:value-of select="substring(concat(@apellido,', ',@nombres),1,20)"/>...
          </xsl:when>
          <xsl:when test="string-length(@apellido) = 0">
            &#160;
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat(@apellido,', ',@nombres)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </td>
    <td style="width:148px">
      <xsl:if test ="string(@nro_sucursal) != ''">
        <xsl:attribute name='title'>
          <xsl:value-of select="@nro_sucursal"/> - <xsl:value-of select="@sucursal"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="string-length(@sucursal) &#62; 20">
            <xsl:value-of select="@nro_sucursal"/> - <xsl:value-of select="substring(@sucursal,1,20)"/>...
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@nro_sucursal"/> - <xsl:value-of select="@sucursal"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </td>
    <td  style='width:118px;'>
      <xsl:value-of select="foo:FechaToSTR(string(@fe_alta))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_alta))"/>
    </td>
    <td  style='width:118px;'>
      <xsl:value-of select="foo:FechaToSTR(string(@fe_baja))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@fe_baja))"/>
    </td>
     <td  style='width:78px;'>
       <xsl:choose>
         <xsl:when test ="@estado = 'vencido'">
           Vencido
         </xsl:when >
         <xsl:when test ="@estado = 'activo'">
           Activo
         </xsl:when >
         <xsl:otherwise>
           &#160;
        </xsl:otherwise>
       </xsl:choose >
     </td>
   </tr>
  </xsl:template>
</xsl:stylesheet>