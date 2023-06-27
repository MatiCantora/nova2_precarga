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
                <title></title>
              <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
              <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
              <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
              <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
              <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
              <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
              <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
              <script type="text/javascript" src="/fw/script/tCampo_def.js" language="JavaScript"></script>
              <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>

                <script language="javascript" type="text/javascript">
                    campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
                    var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
                    campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                    campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                    campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
                    campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                    campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                    campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
                    if (mantener_origen == '0')
                        campos_head.nvFW = window.parent.nvFW
                </script>
                <script>
                    
                        <![CDATA[                        
                        function window_onload()
			            {						
				            //window_onresize();
			            }
            			
			            function window_onresize()
			            {
			                try
				              {				               
				               $('div_botones').setStyle({height: body_height + 'px'})
				             }
				            catch(e){}
			            }
			            
			            function btn_CambiarEstado(estado)
			            {
			                parent.btn_CambiarEstado(estado);
			            }
            			
					   ]]>
                    
                </script>
              <style>
                .td_button
                {
                text-align:center;
                display:inline-block;
                min-width: 150px;
                margin-top: 10px;
            
                <!--padding-left:20px;
                padding-right:20px;
                
                padding-top:5px;
                padding-bottom:5px;-->
                }


              </style>
            </head>
            <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:auto; text-align:center;background-color:white">
                        <div id="div_botones" style="width:100%;  overflow:hidden; text-align:center; margin: 0 auto; background-color:white">
                          <xsl:apply-templates select="xml/rs:data/z:row" />
                        </div>

                        <xsl:choose>
                        <xsl:when test="count(xml/rs:data/z:row) &#62; 0">
                        <script language="javascript" type="text/javascript">
                            var indice = 0
                            var estado = ''
                            var desc_estado = ''
                            var vButtonItems = {};
                        </script>
                        <xsl:variable name="count" select="count(xml/rs:data/z:row)"/>
                        <xsl:for-each select="xml/rs:data/z:row">
                            <xsl:variable name="pos" select="position()"/>
                            <xsl:variable name="estado" select="/xml/rs:data/z:row[$pos]/@estado"/>
                            <xsl:variable name="desc_estado" select="/xml/rs:data/z:row[$pos]/@desc_estado"/>
                            <script language="javascript" type="text/javascript">
                                indice = <xsl:value-of select="$pos"/>-1
                                estado = '<xsl:value-of select="$estado"/>'
                                desc_estado = '<xsl:value-of select="$desc_estado"/>'

                                vButtonItems[indice] = {};
                                vButtonItems[indice]["nombre"] = estado;
                                vButtonItems[indice]["etiqueta"] = 'A '+desc_estado;
                                vButtonItems[indice]["imagen"] = "";
                                vButtonItems[indice]["onclick"] = "return btn_CambiarEstado('"+estado+"')";
                            </script>
                        </xsl:for-each>
                         <script language="javascript" type="text/javascript">
                           var vListButton = new tListButton(vButtonItems, 'vListButton');
                           vListButton.MostrarListButton()
                         </script>
                        </xsl:when>
                        <xsl:otherwise>
                          <div style="position: absolute; top: 10px">
                            <b>No tiene permisos o no hay estados posteriores para este crédito</b>
                          </div>
                        </xsl:otherwise>
                    </xsl:choose>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="z:row">
        <div style='float:left;min-width: 150px;width: 50%; text-align:center;margin: auto;padding: 4px;'>
            <xsl:attribute name="id">div<xsl:value-of select="@estado"/></xsl:attribute>            
            </div>
    </xsl:template>
    
</xsl:stylesheet>