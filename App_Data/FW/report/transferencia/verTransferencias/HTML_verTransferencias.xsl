<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	      xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo"
        xmlns:user="urn:vb-scripts">
  
  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="4.01" encoding="Latin-1" omit-xml-declaration="yes"/>

  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
    
    ]]>    
  </msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Listado transferencias</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
        <link href="/FW/css/btnSvr.css" type="text/css" rel="stylesheet" />
        <link href="/FW/css/mnuSvr.css" type="text/css" rel="stylesheet" />

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
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

	       
]]>
            </xsl:comment>
        </script>
			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				<table class="tb1" id="tbCabe" >
                    <tr class="tbLabel">
                        <td nowrap='true'>
                            <script>
                                campos_head.agregar('Nro.', true, 'id_transferencia')
                            </script>
                           &#160;
                            <script>
                                campos_head.agregar('Nombre', true, 'nombre')
                            </script>
                        </td>
                        <td style='width:20%;' nowrap='true'>
                            <script>
                                campos_head.agregar('Fe. Creación', true, 'transf_fe_creacion')
                            </script>
                        </td>
                        <td style='width:20%;' nowrap='true'>
                            <script>
                                campos_head.agregar('Fe. Modificación', true, 'transf_fe_modificado')
                            </script>
                        </td>
                        <td style='width:20%;' nowrap='true'>
                            <script>
                                campos_head.agregar('Operador', true, 'login')
                            </script>
                        </td>
                        <td style='width:10%;' nowrap='true'>
                            <script>
                                campos_head.agregar('Estado', true, 'transf_estado')
                            </script>
                        </td>
                        <td style='width:10%;' nowrap='true'>
                            <script>
                                campos_head.agregar('Hab.', true, 'habi')
                            </script>
                        </td>
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
    <xsl:variable name="id_transferencia" select="@id_transferencia"></xsl:variable>
    <tr>
     <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
     <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
     <xsl:attribute name="onclick">javascript:parent.seleccion(event,'<xsl:value-of select="$id_transferencia" />','<xsl:value-of select="@nombre"/>')</xsl:attribute>
 		    <td>
            <xsl:if test='string(@nombre) != ""'>
              <a style='width:100%'>
                <xsl:attribute name="href">javascript:parent.seleccion(event,'<xsl:value-of select="$id_transferencia" />','<xsl:value-of select="@nombre"/>')</xsl:attribute>
                <xsl:attribute name='title'>(<xsl:value-of select="@id_transferencia"/>) - <xsl:value-of select="@nombre"/></xsl:attribute>
                (<xsl:value-of select="@id_transferencia"/>) - <xsl:value-of select="@nombre"/>
              </a>
            </xsl:if>
		    </td>
        <td style='width:20%;'>
          <xsl:value-of select="foo:FechaToSTR(string(@transf_fe_creacion))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@transf_fe_creacion))"/>
        </td>
        <td style='width:20%;'>
          <xsl:value-of select="foo:FechaToSTR(string(@transf_fe_modificado))"/>&#160;<xsl:value-of select="foo:HoraToSTR(string(@transf_fe_modificado))"/>
        </td>
        <td style='width:20%;'>
            <xsl:if test='string(@login) != ""'>
                <xsl:attribute name='title'>
                    <xsl:value-of select="@login"/>
                </xsl:attribute>
                        <xsl:value-of select="@login"/>
            </xsl:if>
        </td>
        <td style='width:10%;'><xsl:value-of select="@transf_estado"/></td>
        <td style='width:10%;'>
            <xsl:choose>
                <xsl:when test='@habi = "N"'>
                    <xsl:attribute name='style'>text-align:center;color:red;width:48px</xsl:attribute>
                    <xsl:value-of select="@habi"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name='style'>text-align:center;color:green;width:48px</xsl:attribute>
                    <xsl:value-of select="@habi"/>
                </xsl:otherwise>
            </xsl:choose>
        </td>
      </tr>
    </xsl:template>
	
</xsl:stylesheet>