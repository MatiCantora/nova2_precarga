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
        <title>HTML FW Permisos verOperadores accesos lineal</title>
        <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>

        <script type="text/javascript" language='javascript' src="/fw/script/nvFW.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/nvFW_BasicControls.js"></script>
        <script type="text/javascript" language='javascript' src="/fw/script/tcampo_head.js"></script>
        <!--<script type="text/javascript" language='javascript' src="/fw/script/window_utiles.js"></script>-->
        <script language="javascript" type="text/javascript">
          var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
          campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
          campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
          campos_head.recordcount = '<xsl:value-of select="xml/params/@recordcount"/>'
          campos_head.PageCount = '<xsl:value-of select="xml/params/@PageCount"/>'
          campos_head.PageSize = '<xsl:value-of select="xml/params/@PageSize"/>'
          campos_head.AbsolutePage = '<xsl:value-of select="xml/params/@AbsolutePage"/>'
          
          if (mantener_origen == '0')
            campos_head.nvFW = parent.nvFW
        </script>

        <script language="javascript" type="text/javascript">
          <xsl:comment>
          <![CDATA[
          
          function window_onload()
		      {
		 	     window_onresize()
		      }
                                  
         function window_onresize() {
             try {
			           var dif = Prototype.Browser.IE ? 5 : 2
			           var body_height = $$('body')[0].getHeight()
                 var divMenuABM_height = $('divMenuABM').getHeight()
                 var tbCabe_height = $('tbCabe').getHeight()
		             var div_pag_height = $('div_pag').getHeight()
			           $('divRow').setStyle({height: body_height - tbCabe_height - divMenuABM_height - div_pag_height - dif + 'px'})
			     
			          }
			       catch(e){}
            }

]]>
            </xsl:comment>
        </script>

			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
           <div id="divMenuABM"></div>
           <script type="text/javascript" language="javascript">
             <xsl:comment>
             <![CDATA[
                var DocumentMNG = new tDMOffLine;
                var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
                Menus["vMenuABM"] = vMenuABM
                Menus["vMenuABM"].alineacion = 'centro';
                Menus["vMenuABM"].estilo = 'A';
                Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>imprimir</icono><Desc>imprimir</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parent.buscar('imprimir')</Codigo></Ejecutar></Acciones></MenuItem>")
                Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='2' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>parent.buscar('exportar')</Codigo></Ejecutar></Acciones></MenuItem>")
                vMenuABM.loadImage("imprimir",'/FW/image/security/imprimir.png')
                vMenuABM.loadImage("excel",'/FW/image/security/excel.png')
                vMenuABM.MostrarMenu()
                ]]>
               </xsl:comment>
           </script>
           <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe">
                 <tr class="tbLabel">
                   <td nowrap='nowrap' style='width:15%'>
                     <script>
                       campos_head.agregar('Operador', true, 'operador')
                     </script>
                     <script>
                       campos_head.agregar('Login', true, 'login')
                     </script>
                   </td>
                   <td nowrap='nowrap' style='width:30%'>
                     <script>
                       campos_head.agregar('Nro. Permiso Grupo', true, 'nro_permiso_grupo')
                     </script>
                     <script>
                       campos_head.agregar('Permiso Grupo', true, 'permiso_grupo')
                     </script>
                   </td>
                   <td nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Nro. Permiso', true, 'nro_permiso')
                     </script>
                     <script>
                       campos_head.agregar('Permiso', true, 'Permitir')
                     </script>
                   </td>
                   <td nowrap='nowrap' style='width:15%'>
                     <script>
                       campos_head.agregar('Estructura de Permisos', true, 'path')
                     </script>
                   </td>
                   <td  style='width:5%' nowrap='nowrap'>
                    <script>
                      campos_head.agregar('Acceso', true, 'tiene_permiso')
                    </script>
                  </td>
                  <td style='width:14px !Important'>&#160;&#160;</td>
                 </tr>
                 </table>
                 <div style="width:100%;overflow:auto" id="divRow">
                    <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbRow">
                     <xsl:apply-templates select="xml/rs:data/z:row" />
                   </table>
                 </div>
                 <div id="div_pag" class="divPages">
                   <script type="text/javascript">
                     document.write(campos_head.paginas_getHTML())
                   </script>
                 </div>
                 <script type="text/javascript">
                   campos_head.resize("tbCabe", "tbDetalle")
                 </script>
	  </body>
	</html>
 </xsl:template>
	
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="operador" select="@operador"></xsl:variable>
    <tr>
        <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
        <td style="width:15%">
          <xsl:if test="string(@operador) != ''">
            <xsl:attribute name='title'>
              <xsl:value-of select="@operador"/> - <xsl:value-of select="@login"/>
            </xsl:attribute>
            <img>
              <xsl:attribute name="onclick">parent.abm_operadores('<xsl:value-of select="@login"/>')</xsl:attribute>
              <xsl:attribute name="src">/FW/image/icons/editar.png</xsl:attribute>
              <xsl:attribute name="style">cursor:hand;cursor:pointer;</xsl:attribute>
              <xsl:attribute name="title">Editar Operador</xsl:attribute>
            </img>&#160;(<xsl:value-of select="@operador"/>) <xsl:value-of select="@login"/>
          </xsl:if>
        </td>
        <td style="width:30%">
          <xsl:if test="string(@nro_permiso_grupo) != ''">
            <xsl:attribute name='title'>
              <xsl:value-of select="@nro_permiso_grupo"/> - <xsl:value-of select="@permiso_grupo"/>
            </xsl:attribute>
            <xsl:value-of select="@nro_permiso_grupo"/> - <xsl:value-of select="@permiso_grupo"/>
          </xsl:if>
        </td>
      <td>
        <xsl:if test="string(@nro_permiso) != ''">
          <xsl:attribute name='title'>
            <xsl:value-of select="@nro_permiso"/> - <xsl:value-of select="@Permitir"/>
          </xsl:attribute>
          <xsl:value-of select="@nro_permiso"/> - <xsl:value-of select="@Permitir"/>
        </xsl:if>
      </td>
      <td>
        <xsl:attribute name="style">width:15%</xsl:attribute>
        <xsl:if test="string(@path) != 'No Asignado'">
          <xsl:attribute name="style">width:15%;text-decoration:underline;color:blue;cursor:hand;cursor:pointer;space-white:nowrap</xsl:attribute>
          <xsl:attribute name="onclick">parent.permiso_mostrar('arbol',1)</xsl:attribute>
          </xsl:if>
          <xsl:attribute name='title'>
            <xsl:value-of select="@path"/>
          </xsl:attribute>
          <xsl:value-of select="@path"/>
      </td>
      <td style='width:5%;text-align:center'>
        <img>
          <xsl:attribute name="style">cursor:hand;cursor:pointer</xsl:attribute>
          <xsl:if test="string(@tiene_permiso) = '1'">
            <xsl:attribute name="src">/FW/image/security/tilde.png</xsl:attribute>
            <xsl:attribute name="title">Tiene Acceso</xsl:attribute>
          </xsl:if>
          <xsl:if test="string(@tiene_permiso) = '0'">
            <xsl:attribute name="src">/FW/image/security/eliminar.png</xsl:attribute>
            <xsl:attribute name="title">Sin Acceso</xsl:attribute>
          </xsl:if>
        </img>
      </td>
    </tr>
</xsl:template>
</xsl:stylesheet>