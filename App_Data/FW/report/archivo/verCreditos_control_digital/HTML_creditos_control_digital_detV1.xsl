<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset'
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    <xsl:include href="..\..\..\meridiano\report\xsl_includes\js_formato.xsl"  />
	<xsl:output method="html" version="1.0" encoding="Latin-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
		function rellenar0(numero, largo)
			{
			var strNumero
		
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}

		]]>
		</msxsl:script>

		<xsl:template match="/">
			<html>
				<head>
                    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>

                    <title>Archivos del crédito</title>
          <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
          <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
          <script type="text/javascript" src="/FW/script/swfobject.js"></script>
          <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
          <script type="text/javascript" src="/FW/script/nvFW.js"></script>
          <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
          <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
          <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
          <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
          <xsl:value-of disable-output-escaping="yes" select="user:head_init()"/>
                    <script language="javascript" >
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
					<script type="text/javascript" >
					<xsl:comment>
						var nro_credito = '<xsl:value-of select="xml/rs:data/z:row/@nro_credito"/>'
						<![CDATA[
						var nombre_frame						
						function Ajustar_Iframe()
						{
						
						nombre_frame = window.parent.$('if_' + nro_credito)
						var idoc= nombre_frame.contentDocument || nombre_frame.contentWindow.document;
						//nombre_frame.style.height =  this.document.body.scrollHeight+"px"
						var hele=$('tbDetalle').getHeight() + $('tbCabe').getHeight()
						nombre_frame.style.height=hele +"px"
						//alert(hele +"px")
						}							
						
						var win_credito
                        function credito_mostrar(e,nro_credito) {

                            if (e.ctrlKey == false) {
                                var title = 'Nro. Credito: ' + nro_credito;
                                var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
                                win_credito = w.createWindow({
                                    className: 'alphacube',
                                    url: 'credito_mostrar.asp?nro_credito=' + nro_credito,
                                    title: '<b>' + title + '</b>',
                                    minimizable: true,
                                    maximizable: true,
                                    draggable: true,
                                    resizable: false,
                                    width: 1000,
                                    height: 500,
                                    onClose: function() { }
                                });

                                win_credito.showCenter()
                            }
                            else {
                                $('link_mostrar_credito').href = '../credito_mostrar.asp?nro_credito=' + nro_credito;
                            }
                        } 
                        
						
						]]>
				</xsl:comment>
				</script>
            <style type="text/css">
                .tr_cel TD {
                background-color: #F0FFFF !Important
                }
            </style>
			</head>
			<body onload="return Ajustar_Iframe()" style="width:100%;height:100%;overflow:auto">
				<table class="tb1" id="tbCabe">
					<tr class="tbLabel">
						<td style="width:8%">Nro archivo</td>
						<td style="width:10%">Momento</td>
						<td style="width:25%">Descripcion</td>
						<td style="width:12%">Credito</td>
						<td style="width:30%">Definición</td>
						<td style="width:15%">Clasificación</td>						
					</tr>
				</table>
                    <div id="divDetalle" style="width:100%;overflow:auto">
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
          <xsl:attribute name="id">tr_ver<xsl:value-of select="$pos"/></xsl:attribute>
          <td style='text-align: center; width:8%'>
			  <xsl:if test='./@nro_archivo'>
				  <a>
					  <xsl:attribute name='href'>../../meridiano/get_file.aspx?nro_archivo=<xsl:value-of  select="@nro_archivo" /></xsl:attribute>
					  <xsl:attribute name='target'>verDocumento</xsl:attribute>
					  <img border='0' src="../image/icons/Notepad.gif" style="vertical-align:middle"></img>
					  <xsl:value-of  select="@nro_archivo" />
				  </a>
			  </xsl:if>
		  </td>
		  <td style='text-align: center; width:10%'>
			  <xsl:value-of select="foo:FechaToSTR(string(@momento))" />&#160;<xsl:value-of select="foo:HoraToSTR(string(@momento))"/>
		  </td>
		  <td style='text-align: left; width:25%'>
			  <xsl:value-of  select="@archivo_descripcion" />
		  </td>
		  <td style='text-align: left; width:12%'>
		  	 <a>
				  <xsl:attribute name="target">_blank</xsl:attribute>
				  <xsl:attribute name="href">../../meridiano/credito_mostrar.asp?nro_credito=<xsl:value-of select="@nro_credito"/></xsl:attribute>
				  <xsl:value-of  select="format-number(@nro_credito,'0000000')" />
			  </a>
			  
		  </td>
		  <td style='text-align: center; width:30%'>		  	
			  (<xsl:value-of select="@nro_def_archivo" />) - <xsl:value-of select="@def_archivo"/>
		  </td>
		  <td style='text-align: left; width:15%'>
			<xsl:value-of select="@pag_clasificadas"/>   paginas de <xsl:value-of select="@cant_hojas"/> 
		  </td>		  
	  </tr>	  
	</xsl:template>
</xsl:stylesheet>