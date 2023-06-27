<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
                xmlns:rs='urn:schemas-microsoft-com:rowset'
                xmlns:z='#RowsetSchema'
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
              
				
	
	
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<html onload="return window_onload()" >
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Jugadores</title>
				<link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
				<script type="text/javascript" src="/FW/script/nvFW.js"></script>
				<script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
				<script type="text/javascript">
					  var mantener_origen = '<xsl:value-of select="xml/mantener_origen"/>'
          
					  campos_head.id_exp_origen = '<xsl:value-of select="xml/id_exp_origen"/>'
					  campos_head.cacheID = '<xsl:value-of select="xml/params/@cacheID"/>'
					  campos_head.cacheControl = '<xsl:value-of select="xml/params/@cacheControl"/>'
					  campos_head.recordcount = <xsl:value-of select="xml/params/@recordcount"/>
					  campos_head.PageCount = <xsl:value-of select="xml/params/@PageCount"/>
					  campos_head.PageSize = <xsl:value-of select="xml/params/@PageSize"/>
					  campos_head.AbsolutePage = <xsl:value-of select="xml/params/@AbsolutePage"/>
					  campos_head.orden = '<xsl:value-of select="xml/params/@orden"/>'

					if (mantener_origen == '0')
					campos_head.nvFW = window.parent.nvFW;

					function window_onload(){
					window_onresize()

					}

					function window_onresize() {
					campos_head.resize('tbCabecera','tbDetalles');
}
				</script>
					
			</head>
      
			<body onload="window_onload()" onresize="window_onresize()" style="width:100%;height:100%;overflow:hidden">

				<!-- TABLA DE CABECERAS - El true/false del campos_head.agregar indica si queremos que tenga ordenamiento o no -->
				<table id="tbCabecera" name="main"  class="tb1" style="width: 100%">
					<tr>
						<td class="Tit1"  style="width:5% !important">
							<script>campos_head.agregar('ID', true,'id_tranf_conf')</script>
						</td>
						<td  class="Tit1" style="width:15% !important">
							<script>campos_head.agregar('Descripcion', true , 'transf_conf')</script>
						</td>
						<td class="Tit1" style="width:5% !important">			
							<script>campos_head.agregar('Tipo', true,'transf_conf_tipo')</script>
						</td>
						<td class="Tit1" style="width:10% !important">			
							<script>campos_head.agregar('Servidor', true,'server')</script>
						</td>
						<td class="Tit1" style="width:10% !important">			
							<script>campos_head.agregar('Puerto', true,'port')</script>
						</td>
						<td  class="Tit1" style="width:10% !important">			
							<script>campos_head.agregar('Usuario', true,'user')</script>
						</td>
						<td class="Tit1" style="width:10% !important">
							<script>campos_head.agregar('Contraseña', true,'password')</script>
						</td>
						<td  class="Tit1" style="width:10% !important">
							<script>campos_head.agregar('esSSL', true,'esSSL')</script>
						</td>
						<td  class="Tit1" style="width:5% !important">
							<script>campos_head.agregar('from', true,'from')</script>
						</td>
						<td  class="Tit1" style="width:8% !important">
							<script>campos_head.agregar('from_title', true,'from_title')</script>
						</td>
						<td  class="Tit1" style="width:2% !important">
						</td>
						
					</tr>
				</table>

				<!-- Esta parte hace que complete las filas con la xsl:template  match="z:row" que está acá, más abajo -->
				<div id="divRow" style="overflow:hidden;width:100%">
					<table id="tbDetalles" class="tb1 highlightTROver highlightOdd layout_fixed" style="width: 100%; " >
   						  <xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>
				
				
				<!-- DIV DE PAGINACION -->
				
				<div id="div_pag" class="divPages" style="bottom: 0px; height: 16px;">
				  <script type="text/javascript">
					if (campos_head.PageCount > 1)
						document.write(campos_head.paginas_getHTML())
				  </script>
				</div>

			</body>
		</html>
	</xsl:template>
	<xsl:template  match="z:row">
		<tr>
			<td>
				<!--<xsl:attribute name="style">width:5% !important</xsl:attribute>-->
				<xsl:value-of  select="@id_transf_conf" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:15% !important</xsl:attribute>-->
				<xsl:value-of  select="@transf_conf" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:5% !important</xsl:attribute>-->
				<xsl:value-of  select="@transf_conf_tipo" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:10% !important</xsl:attribute>-->
				<xsl:value-of  select="@server" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:10% !important</xsl:attribute>-->
				<xsl:value-of  select="@port" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:10% !important</xsl:attribute>-->
				<xsl:value-of  select="@user" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:10% !important</xsl:attribute>-->
				<xsl:value-of  select="@password" />
			</td>
			<td >
				<!--<xsl:attribute name="style">width:10% !important</xsl:attribute>-->
				<xsl:value-of  select="@esSSL" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:5% !important</xsl:attribute>-->
				<xsl:value-of  select="@from" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:8% !important</xsl:attribute>-->
				<xsl:value-of  select="@from_title" />
			</td>
			<td>
				<!--<xsl:attribute name="style">width:2% !important</xsl:attribute>-->
				<img>
					<xsl:attribute name="style">cursor:pointer</xsl:attribute>
					<xsl:attribute name="src">/fw/image/icons/editar.png</xsl:attribute>
					<xsl:attribute name="onclick">
						parent.editar('<xsl:value-of select="@id_transf_conf"/>','<xsl:value-of select="@transf_conf"/>','<xsl:value-of select="@transf_conf_tipo"/>','<xsl:value-of select="@transf_conf_tipo_id"/>','<xsl:value-of select="@server"/>','<xsl:value-of select="@port"/>','<xsl:value-of select="@user"/>','<xsl:value-of select="@password"/>','<xsl:value-of select="@esSSL"/>','<xsl:value-of select="@from"/>','<xsl:value-of select="@from_title"/>')
					</xsl:attribute>
				</img>
			</td>
		</tr>
	</xsl:template>
</xsl:stylesheet>


