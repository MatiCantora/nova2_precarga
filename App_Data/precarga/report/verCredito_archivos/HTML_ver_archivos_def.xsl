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

                <title>Archivos</title>
              <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
              <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
              <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
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
                          }
                          
						  function window_onresize()
					        {
					         try
					            {
            			    var divFiltro_h = parent.$('tbTitulo').getHeight()                     
                      var bodyHeight = parent.$$('body')[0].getHeight()
                      parent.$('iframe_archivos').setStyle({ height: bodyHeight - divFiltro_h + 'px' })
                      var iframe_h = parent.$('iframe_archivos').getHeight()
                      var tbCabe_height = $('tbCabe').getHeight() 
                      $('div_lst_archivos').setStyle({ height: iframe_h - tbCabe_height  + 'px' })
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
                            var path = "../../meridiano/credito_mostrar.asp?nro_credito=" + nro_credito
                            var descripcion = '<b>Cr�dito N� ' + nro_credito + '</b>'                            
                            $(link).style.color = '#848484'
                            $(link).style.textDecoration = 'underline'
                            $(link).style.cursor = 'pointer'                           
                            $(link).target = '_blank'
                            $(link).href = path;                                 
					      }					
                
                function MostrarCredito(nro_credito)
                {
                nvFW.selection_clear()
                window.parent.MostrarCredito(nro_credito)
                }
                
                function getCreditoFile(nro_archi){
                 //alert(nro_archi)
                  window.open("../../precarga_test/get_file.aspx?nro_archivo=" + nro_archi)
                }
					     
					   ]]>
                    </xsl:comment>
                </script>
            </head>
            <body onload="window_onload()" onresize="return window_onresize()" style="width:100%;height:100%;overflow:auto">                    
                      <table width="100%" class="tb1" id="tbCabe">
                        <tr class="tbLabel">
                          <td style='text-align: center;width:50%'>Documentos</td>
                          <td style='text-align: center;width:25%'>Fecha</td>
                          <td style='text-align: center;width:25%'>Operador</td>
                        </tr>
                      </table>
              <div id="div_lst_archivos" style="width:100%;height:100%;overflow:auto">      
              <table class="tb1 highlightEven highlightTROver" id="tbDetalle">
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                      </table>
              </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="z:row">
        <xsl:variable name="pos" select="position()"/>
        <tr>
              <td style="text-align: left;width:50%;cursor:hand">
                <xsl:if test='string(@nro_archivo) != ""'>
                  <xsl:attribute name="style">
                    cursor:pointer;color:blue; font-weight:bold; text-decoration: underline;
                  </xsl:attribute>
                  <xsl:attribute name="onclick">
                    window.open('/FW/files/file_get.aspx?f_id=<xsl:value-of select="@f_id"/>&amp;path=<xsl:value-of select="foo:replace(string(@path),'\','/')"/>')
                  </xsl:attribute>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="string-length(@archivo_descripcion) &#62; 100">
                    <xsl:value-of select="substring(@archivo_descripcion,1,100)"/>...
                    <xsl:if test='string(@nro_archivo) != ""'>
                      - <xsl:value-of select="@nro_archivo"/>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@archivo_descripcion"/>
                    <xsl:if test='string(@nro_archivo) != ""'>
                      - <xsl:value-of select="@nro_archivo"/>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </td>
              <td style='text-align: center;width:25%'>
                <xsl:value-of select="foo:FechaToSTR(string(@momento))"/>
              </td>
              <td style='text-align: center;width:25%'>
                <xsl:value-of  select="@operador" />
              </td>                          
        </tr>
    </xsl:template>
</xsl:stylesheet>