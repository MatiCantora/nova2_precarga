<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo"
                extension-element-prefixes="msxsl"
                exclude-result-prefixes="foo"
                xmlns:user="urn:vb-scripts">

  <xsl:include href="..\..\..\..\FW\report\xsl_includes\vb_nvPageXSL.xsl"></xsl:include>
  
  <msxsl:script language="vb" implements-prefix="user">
    <msxsl:assembly name="System.Web"/>
    <msxsl:using namespace="System.Web"/>
    <![CDATA[

      Dim nvFW_interOp as object = HttpContext.current.application.contents("_nvFW_interOp")
      
      Public function getfiltrosXML() as String
        
          Page.contents("filtroverOperadores_operador_tipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_operador_tipo'><campos>distinct tipo_operador,tipo_operador_desc,fe_alta,estado</campos><filtro></filtro><orden></orden></select></criterio>")

		      return ""
      End Function
		
		  Dim a as String = getfiltrosXML()     
      

		]]>
  </msxsl:script>
  <msxsl:script language="javascript" implements-prefix="foo">
    <![CDATA[
        
    
    ]]>    
  </msxsl:script>

	<xsl:template match="/">
		<html>
		<head>
        <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
        <title>HTML verOperadores asociados perfiles</title>
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
		           var div_pag_height = $('div_pag').getHeight()
               var divMenuABM_height = $('divMenuABM').getHeight()
			         $('divRow').setStyle({height: body_height - divMenuABM_height - tbCabe_height - div_pag_height - dif + 'px'})
			     
              }
			         catch(e){}
               
                 
              try
                {
                  campos_head.resize("tbCabe","tbRow")                  
                }
                catch(e){}
        
            }

			function nodo_onclick(operador)
				{ 
						var div = $('trPerfiles' + operador)
						var img = $('img' + operador)
						if (div.style.display == 'none')
								{
								 img.src = '/fw/image/security/menos.gif'
								 div.show()
                 exportar_plantilla(operador)
								}
						else 
								{
								img.src = '/fw/image/security/mas.gif'
								div.hide()
                exportar_plantilla(operador)
								}
							window_onresize()	
		   }		

	   function exportar_plantilla(operador)
			{
			
        var filtroWhere = "<criterio><select><campos></campos><filtro><operador type='igual'>"+ operador +"</operador>"+ parent.cadena_filtro + "</filtro><orden></orden></select></criterio>"
        var path_xsl = "\\report\\security\\FW_Operadores_Perfiles\\HTML_verPerfiles_asociados.xsl"
    
         nvFW.exportarReporte({filtroXML: parent.nvFW.pageContents.filtroverOperadores_operador_tipo
                             ,filtroWhere: filtroWhere
                             , path_xsl: path_xsl
                             , formTarget: 'iframePerfiles' + operador
                             , nvFW_mantener_origen: true
                             , id_exp_origen: 0
                             , bloq_contenedor: 'iframePerfiles' + operador
                             , cls_contenedor: 'iframePerfiles' + operador
                             , cls_contenedor_msg: ' '
                             , bloq_msg: 'Cargando...'
                           })
		   }
	       
]]>

        </script>
			</head>
         <body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">
				     <div id="divMenuABM"></div>
            <script type="text/javascript" language="javascript">
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
            </script>     
               <table class="tb1 highlightOdd highlightTROver layout_fixed" id="tbCabe">
                 <tr class="tbLabel">
                   <td style="width:3%;text-align:center">&#160;-&#160;</td>
                   <td nowrap='nowrap' style='width:15%'>
                     <script>
                       campos_head.agregar('Operador', true, 'operador')
                     </script>
                   </td>
                   <td  style='width:20%;text-align:center' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Apellido', true, 'apellido')
                     </script>
                   </td>
                   <td  nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Nombres', true, 'nombres')
                     </script>
                   </td>
                   <td  style='width:25%;text-align:center' nowrap='nowrap'>
                     <script>
                       campos_head.agregar('Nro. Documento', true, 'nro_docu')
                     </script>
                   </td>
                   <td style='width:5% !Important;text-align:center'>&#160;&#160;</td>
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
             campos_head.resize("tbCabe", "tbRow")
           </script>
	  </body>
	</html>
 </xsl:template>
	
	<xsl:template match="z:row">
    <xsl:variable name="pos" select="position()"/>
    <xsl:variable name="operador" select="@operador"></xsl:variable>
    <xsl:variable name="tipo_operador" select="@tipo_operador"></xsl:variable>
    <xsl:variable name="anteriores" select="count(/xml/rs:data/z:row[@operador = $operador and $tipo_operador > @tipo_operador ])"/>
    <xsl:if test="$anteriores = 0">
      <tr>
       <td  style='text-align: center; width:3%'>
			  	<img src='/fw/image/security/mas.gif' border='0' align='absmiddle' hspace='1'>
						<xsl:attribute name="id">img<xsl:value-of select="$operador"/></xsl:attribute>
						<xsl:attribute name='onclick'>nodo_onclick(<xsl:value-of select='$operador'/>)</xsl:attribute>
					</img>
			 </td>
       <td style='width:15%'>
         <img>
            <xsl:attribute name="onclick">parent.abm_operadores('<xsl:value-of select="@Login"/>')</xsl:attribute>
            <xsl:attribute name="src">/FW/image/icons/editar.png</xsl:attribute>
            <xsl:attribute name="style">cursor:hand;cursor:pointer;border:0px</xsl:attribute>
            <xsl:attribute name="title">Editar Operador</xsl:attribute>
          </img>
          (<xsl:value-of select="$operador"/>)&#160;<xsl:value-of select="@Login"/></td>
        <td style='width:20%'>
          <xsl:attribute name='title'><xsl:value-of select="@apellido"/></xsl:attribute>
          <xsl:value-of select="@apellido"/>
        </td>
        <td>
          <xsl:attribute name='title'><xsl:value-of select="@nombres"/></xsl:attribute>
          <xsl:value-of select="@nombres"/>
        </td>
        <td style="width:25%">
          <xsl:attribute name='title'>
            <xsl:value-of select="@documento"/> - <xsl:value-of select="@nro_docu"/>
          </xsl:attribute>
          <xsl:value-of select="@documento"/> - <xsl:value-of select="@nro_docu"/>
        </td>
        <td style='width:5%;text-align:center'>
          <img>
            <xsl:attribute name="onclick">parent.imprimir_operador(<xsl:value-of select="@operador"/>)</xsl:attribute>
            <xsl:attribute name="src">/FW/image/security/imprimir.png</xsl:attribute>
            <xsl:attribute name="style">cursor:hand;cursor:pointer;border:0px</xsl:attribute>
            <xsl:attribute name="title">Imprimir Operador</xsl:attribute>
          </img>
        </td>
      </tr>
      <tr>
      <xsl:attribute name='id'>trPerfiles<xsl:value-of select="$operador"/></xsl:attribute>
      <xsl:attribute name='style'>display:none</xsl:attribute>
      <!--<xsl:attribute name='class'>tbLabel</xsl:attribute>-->
      <td style="width:3%">&#160;</td>
      <td>
        <xsl:attribute name='colspan'>5</xsl:attribute>
        <iframe>
           <xsl:attribute name='id'>iframePerfiles<xsl:value-of select="$operador"/></xsl:attribute>
           <xsl:attribute name='name'>iframePerfiles<xsl:value-of select="$operador"/></xsl:attribute>
           <xsl:attribute name='style'>width: 100%; overflow-y: auto; height: 180px; border: none;</xsl:attribute>
        </iframe> 
      </td>
    </tr> 
    
    </xsl:if>
  </xsl:template>
  
  </xsl:stylesheet>