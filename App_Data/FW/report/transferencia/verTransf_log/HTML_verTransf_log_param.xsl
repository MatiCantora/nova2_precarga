<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
  <xsl:include href="..\..\..\report\xsl_includes\js_formato.xsl"  />
  <xsl:output method="html" version="1.0" encoding="iso-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
    
    ]]>    
  </msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Listado</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

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

        <script type="text/javascript"  language="javascript" >
          <xsl:comment> 
          <![CDATA[
                   var alert = function(msg) {Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); } 
                   
                   function window_onresize()
					          {
					              try
					              {
					               var dif = Prototype.Browser.IE ? 5 : 2
					               var body_height = $$('body')[0].getHeight()
					               var tbCabe_height = $('tbCabe').getHeight()
					               //var divPie_height = $('divPie').getHeight()

					               var total = body_height - tbCabe_height - dif // - divPie_height 
					     
					               $('divRow').setStyle({height: total + 'px'})
                         
					               campos_head.resize("tbCabe", "tbRow")
					              }
					               catch(e){}
					          } 
					
				            function window_onload()
                    {
                    window_onresize()
                    }

                    var win_editar
                    function ver_editor(id) 
                    {
                      var texto = $(id).value 
                      win_editar = nvFW.createWindow({ className: 'alphacube',
                                title: '<b>Valor1: ' + $(id).value.substring(0,20) +'</b>',
                                minimizable: false,
                                maximizable: false,
                                draggable: true,
                                resizable: false,
                                recenterAuto: false,
                                width: 550,
                                height: 100,
							                 	onDestroy:true,
                                onClose: function() { }
                      });
                      var html = "<html><head></head><body style='width: 100%; height: 100%;'><form><table class='tb1'><tr><td align='center'><textarea readonly='readonly' style='overflow: auto; resize: both; width: 100%;' rows='5' cols='1'>" + texto + "</textarea></td></tr><tr><td align='right'></td></tr></table></form></body>";
                      win_editar.setHTMLContent(html)
                      var id = win_editar.getId()
                      win_editar.showCenter()
                    }          
                    
          ]]>
            </xsl:comment> 

        </script>
        <style type="text/css">         
        </style>
    </head>
    <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
        <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe" >
					 <tr class="tbLabel">
						<td style="width:40%"><script>campos_head.agregar('Etiqueta', true, 'etiqueta')</script></td>
            <td><script>campos_head.agregar('Valor', true, 'valor')</script></td>
           </tr>
        </table>
                 <div id="divRow" style="width:100%;overflow:auto">
                     <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                         <xsl:apply-templates select="xml/rs:data/z:row" />
                     </table>
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
	      <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
	      <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
		  <td style="width:40%">
		    <xsl:if test='string(@etiqueta) != ""'>
				  <xsl:attribute name='title'><xsl:value-of select="@etiqueta"/></xsl:attribute>
			 	  <xsl:value-of select="@etiqueta"/>
			  </xsl:if>
		  </td>
		  <td >
		      <xsl:if test='string(@valor) != ""'>
		          <xsl:attribute name="onclick">ver_editor('valor<xsl:value-of select="$pos"/>')</xsl:attribute>
				  <xsl:attribute name='title'><xsl:value-of select="@valor"/></xsl:attribute>
				  <xsl:attribute name='style'>
					  <xsl:choose>
						  <xsl:when test="@tipo_dato = 'int' or @tipo_dato = 'float' or @tipo_dato = 'money'">
                              text-align:right;color:blue;text-decoration:underline
                          </xsl:when>
						  <xsl:otherwise>
                              text-align:left;color:blue;text-decoration:underline
                          </xsl:otherwise>
					  </xsl:choose>
				  </xsl:attribute>
   			  <xsl:value-of select="@valor"/>
			  </xsl:if>
			  <input>
                  <xsl:attribute name="id">valor<xsl:value-of select="$pos"/></xsl:attribute>
                  <xsl:attribute name="type">hidden</xsl:attribute>
              </input>
              <script type="text/javascript" language="javascript">
                $('valor<xsl:value-of select="$pos"/>').value = "<xsl:value-of disable-output-escaping ="yes" select="foo:replace(string(@valor),'\','\\')" />"
              </script>
		  </td>
      </tr>
		
	</xsl:template>
	
</xsl:stylesheet>