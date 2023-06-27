<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
    <xsl:include href="..\..\..\..\fw\report\xsl_includes\js_formato.xsl"  />
    <msxsl:script language="javascript" implements-prefix="foo">
        <![CDATA[
		
		 function is_image(ext) {
            switch(ext.toUpperCase()){
                case 'BMP':
                case 'GIF':
                case 'JPG':
                case 'JPGE':
                case 'JPE':
                case 'PNG':
                case 'ICO':
                case 'TGA':
                case 'PCX':
                    return 1;
                    break;
                }
		    return 0;
		}
		]]>
    </msxsl:script>

    <xsl:variable name="filename" select="xml/parametros/@filename"/>
    <xsl:variable name="ext" select="xml/parametros/@ext"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
                <title>Archivos</title>
                <link href="/fw/css/base.css" type="text/css" rel="stylesheet"/>
                <script type="text/javascript" src="/fw/script/nvFW.js" language='javascript'></script>
                <script type="text/javascript" src="/fw/script/tCampo_head.js" language="JavaScript"></script>
                
                <script type="text/javascript" language="javascript">
                    <xsl:comment>

                        campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"  />'
                        var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'


                        campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
                        campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
                        campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>

                        campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
                        campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
                        campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>


                        if (mantener_origen == '0')
                        campos_head.nvFW = parent.nvFW

                    </xsl:comment>
                </script>


            <script type="text/javascript">
                <![CDATA[
          
          
                    function onload() {
                        onresize()
                    }


                    function onresize() {
                  
                        try {
                            var body_h = $$('BODY')[0].getHeight();
                            var divHeader_h = $('divHeader').getHeight();
                            var div_pag_h = $('div_pag').getHeight();
                         
                            var h = body_h - divHeader_h - div_pag_h
                            if (h > 0) {
                                $('divMain').setStyle({ height: h + 'px' });
                            }
                        }                  
                        catch (e) {}
                  
                        campos_head.resize('header_tbl', 'main')
                    } 


                ]]>
            </script>


            </head>
            <body onload="onload()" onresize="onresize()" style="width: 100%; overflow: hidden; height: 100%;">

                <div id="divHeader">

                    <table class="tb1">
                    <tr class="tblabel">
                        <td>


                            <img border='0' align='absmiddle' hspace='1'>
                                <xsl:attribute name='src'>
                                    /fw/image/file_dialog/file_<xsl:value-of select="$ext"/>.png
                                </xsl:attribute>
                            </img>

                            <xsl:value-of select="$filename"/>
                        </td>

                    </tr>
                    </table>
                    
                    
                    <table id="header_tbl" class="tb1 highlightEven highlightTROver">

                        <tr class="tbLabel0">
                            <td style='width:30%'>
                                <script>
                                    campos_head.agregar('Fecha de mod.', true, 'f_falta')
                                </script>
                            </td>

                            <td style='width: 30%'>
                                <script>
                                    campos_head.agregar('Tamaño', true, 'f_size')
                                </script>
                            </td>


                            <td style='width: 25%'>
                                <script>
                                    campos_head.agregar('Operador', true, 'nombre_operador')
                                </script>
                            </td>

                            <td style='width: 5%'></td>
                            <td style='width: 5%'></td>
                            <td style='width: 5%'></td>

                        </tr>
                    </table>
                </div>

                <div  id="divMain" style="height:300px;overflow:auto;background-color:white;">

                    <table id="main" name="main"  class="tb1 highlightEven highlightTROver scroll " >
                        <xsl:apply-templates select="xml/rs:data/z:row" />
                    </table >
                </div>
                        
                        
               


                <div id="div_pag" class="divPages" style="position: absolute; bottom: 0px; background: #BDD2EC; height: 16px;">
                    <script type="text/javascript">
                        if (campos_head.PageCount > 1)  document.write(campos_head.paginas_getHTML())
                    </script>
                </div>

                <iframe name="hiddenIframe" id="hiddenIframe" src="/fw/enBlanco.htm" style="display: none" frameborder="0"></iframe>
            </body>
        </html>
    </xsl:template>




    <xsl:template match="z:row">

        <xsl:param name="is_image" select="foo:is_image(string(@f_ext))"/>

   
            <tr>
                <xsl:attribute name='id'>
                    trFile_<xsl:value-of select="@f_id"/>
                </xsl:attribute>
                

                <td>
                    <xsl:value-of select="foo:FechaToSTR(string(@f_falta))"/>-<xsl:value-of select="foo:HoraToSTR(string(@f_falta))"/>
                </td>

                <td>
                    <xsl:value-of select="@f_size"/> Kb
                </td>

                <td>
                    <xsl:value-of select="@nombre_operador"/> 
                </td>

                <td style="text-align: center; cursor: hand; cursor: pointer">
          
                        <a target="hiddenIframe">
                            <xsl:attribute name="id">
                                link_<xsl:value-of select="@f_id"/>
                            </xsl:attribute>

                            <xsl:attribute name="href">
                                /fw/files/file_get.aspx?content_disposition=attachment&amp;f_id=<xsl:value-of select="@f_id"/>
                            </xsl:attribute>
                            <img title="Descagar Archivo" border='0' align='absmiddle' hspace='1'>
                                <xsl:attribute name='src'>/fw/image/file_dialog/descargar.png</xsl:attribute>
                            </img>
                        </a>
       
                </td>


                <td style="text-align: center;cursor: hand; cursor: pointer">
                    <xsl:if test="$is_image">
                        <img title="Previsualizar" border='0' align='absmiddle' hspace='1'>
                            <xsl:attribute name='src'>/fw/image/file_dialog/buscar.png</xsl:attribute>
                            <xsl:attribute name='onclick'>
                                parent.btnPreview_onclick(<xsl:value-of select="@f_id"/>)
                            </xsl:attribute>
                        </img>
                    </xsl:if>
                </td>


                <td style="text-align: center;cursor: hand; cursor: pointer">
           
                    <img title="Propidades" border='0' align='absmiddle' hspace='1'>
                        <xsl:attribute name='src'>/fw/image/file_dialog/propiedades.png</xsl:attribute>
                        <xsl:attribute name='onclick'>
                            parent.btnPropiedades_onclick(<xsl:value-of select="@f_id"/>)
                        </xsl:attribute>
                    </img>
         
                </td>

            </tr>
            
      
    </xsl:template>

</xsl:stylesheet>