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

                <title>Créditos</title>
              <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
              <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
              <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
			  <link href="/precarga/css/mis_creditos.css" type="text/css" rel="stylesheet" />
              <script type="text/javascript" src="/fw/script/nvFW.js" language="JavaScript"></script>
              <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
              <script type="text/javascript" src="/precarga/script/tCampo_head.js" language="JavaScript"></script>
              <script type="text/javascript" src="/precarga/script/precarga.js" ></script>
                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					campos_head.top = <xsl:value-of select="xml/params/@top"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'
                  if (mantener_origen == '0')
                    campos_head.nvFW = window.parent.nvFW
                </script>
                <script type="text/javascript"  language="javascript" >
                    <xsl:comment>

                        <![CDATA[
					    function  window_onload()
                          {
                            window_onresize()
							if (campos_head.recordcount == campos_head.top) alert("Por cuestiones de seguridad solo se están mostrando los primeros " + campos_head.recordcount + " registros." )
                          }
                          
						  function window_onresize()
					        {
					         
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
                          
					       
                 function pag_seleccionar(id)
					       {
					         $(id).addClassName('tr_cel')
					       }style="width:100%; overflow:auto;position:relative"
                 
                 function pag_no_seleccionar(id)
                 {
                   $(id).removeClassName('tr_cel')
                 }
                 
					      function mostrar_creditos(e,nro_credito,link)
					      {
                            var path = "/precarga/creditos/credito_mostrar.asp?nro_credito=" + nro_credito
                            var descripcion = '<b>Crédito Nº ' + nro_credito + '</b>'                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'                           
                            $(link).target = '_blank'
                            $(link).href = path;                                 
					      }					
                
                function MostrarCredito(nro_credito)
                {
                window.top.MostrarCredito(nro_credito)
                }
					     
					   ]]>
                    </xsl:comment>
                </script>
            </head>
			
            <body onload="window_onload()" id ="body_iframe_cr" onresize="return window_onresize()" style="width:100%;height:100%;">                    
                      
                <div id="div_lst_creditos" style="width:100%; overflow:auto;position:relative">
                      <table class="tb1 highlightTROver" id="tbDetalle">
                                <xsl:apply-templates select="xml/rs:data/z:row" />
                              </table>
                   </div> 
		         <div class="div_paginador">
                        <script type="text/javascript">
                          document.write(campos_head.paginas_precarga_getHTML())
                        </script>
                      </div>
        
            </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>

		
        <tr style="margin-bottom: 5px ; ">
			<xsl:attribute name="onclick">
				MostrarCredito('<xsl:value-of select="@nro_credito"/>')
			</xsl:attribute>
			<xsl:attribute name="style">color:#194693; cursor:pointer; text-align: right;</xsl:attribute>
			<!--<xsl:attribute name="style">color:#464646; text-transform: capitalize;</xsl:attribute>-->
            <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
              <td style='text-align: left; padding:15px; border-radius: 10px;box-shadow: 0px 0px 4px 1px rgba(0, 0, 0, 0.10);' rowspan='true'>
				<!--<div>
				  <xsl:attribute name="style">color: #194693;;</xsl:attribute>
			    <xsl:choose>
                  <xsl:when test="@estado = 'propuestas'">
                       <p style="background-color: red; display: inline;"><xsl:value-of select="@descripcion" /></p>
                  </xsl:when>
				  <xsl:when test="@grupo = 'a_solucionar'">
                       <p style="background-color: blue;"><xsl:value-of select="@descripcion" /></p>
                  </xsl:when>
					
				  <xsl:when test="@descripcion = 'Aprobado'">
                       <p style="background-color: #4d4d4d; display: inline;"><xsl:value-of select="@descripcion" /></p>
                  </xsl:when>
				
			      <xsl:otherwise>
					  <p style="background-color: #yellow; display: inline;"><xsl:value-of select="@descripcion" /></p>
                  </xsl:otherwise>
                </xsl:choose>
			   </div>-->
				  <div style='display: flex; justify-content: space-between;'>
					  <div>
						  <xsl:value-of  select="@descripcion" />
					  </div>
					  <div>
						  <xsl:value-of  select="@cuotas" />
						  <xsl:text> cuotas de $</xsl:text>
						  <xsl:value-of  select="@importe_cuota" />
					  </div>
				  </div>
				  
			       <div style="margin: 5px 0px 3px 0px">
			           <xsl:value-of  select="@strNombreCompleto" /><br />
			      </div>
				  
				  <div style='display: flex; justify-content: space-between;'>
					  <div> 
						  <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
					  </div>
					  <div>
						  <xsl:text>Consultar Resultado</xsl:text>
					  </div>

				  </div>
              </td>
			
			<!--<td style="text-align: center; width: 40%;cursor:hand">
                <xsl:attribute name="onclick">MostrarCredito('<xsl:value-of select="@nro_credito"/>')</xsl:attribute>
		     </td>-->
        </tr>
    </xsl:template>
</xsl:stylesheet>