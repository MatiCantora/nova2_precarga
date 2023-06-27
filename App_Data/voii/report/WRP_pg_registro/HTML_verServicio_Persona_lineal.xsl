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
		function rellenar0(numero, largo)
			{
			var strNumero
			debugger
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}

		function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
		//modo 1 = dd/mm/yyyy
        //modo 2 = mm/dd/yyyy
		//modo 3 = dd/mm/yyyy hh:mm:ss
		
		function conv_fecha_to_str(cadena, modo)
          {
		  var objFecha = parseFecha(cadena)
		  var dia
		  var mes
		  var anio
		  if (objFecha.getDate() < 10)
		     dia = '0' + objFecha.getDate().toString()
		  else
		     dia = objFecha.getDate().toString() 
		  
		  if ((objFecha.getMonth() +1) < 10)
		     mes = '0' + (objFecha.getMonth()+1).toString()
		  else
		     mes = (objFecha.getMonth()+1).toString() 	 
		  anio = objFecha.getFullYear()  
		  
		  if (objFecha.getHours() < 10)
		     hora = '0' + objFecha.getHours().toString()
		  else
		     hora = objFecha.getHours().toString() 
			 
		 if (objFecha.getMinutes() < 10)
		     minuto = '0' + objFecha.getMinutes().toString()
		  else
		     minuto = objFecha.getMinutes().toString() 	 
		
		 if (objFecha.getSeconds() < 10)
		     segundo = '0' + objFecha.getSeconds().toString()
		  else
		     segundo = objFecha.getSeconds().toString() 	 	 
		  switch (modo)	 
		    {
			case 'mm/dd/aa':
			   return mes + '/' + dia + '/' + anio
			   break; 
			case 'dd/mm/aa':
			   return dia + '/' + mes + '/' + anio
			   break;    
			case 'dd/mm/aa hh:mm:ss':
			   return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + minuto + ':' + segundo
			   break;       
			}
          }

		]]>
	</msxsl:script>

	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title>Servicio Detalle</title>
				<link href="../../meridiano/css/base.css" type="text/css" rel="stylesheet"/>
				<script type="text/javascript" src="../../meridiano/script/prototype.js"></script>
				<script language="javascript" type="text/javascript">
					function window_onresize()
					{
					try
					{
					 var dif = Prototype.Browser.IE ? 5 : 2
					 body_height = $$('body')[0].getHeight()
					 cab_height = $('tbCabecera').getHeight()
					 $('div_scroll').setStyle({'height': body_height - cab_height - dif + 'px'})
					}
					catch(e){}
					}
					function window_onload()
					{
					window_onresize()
					}
				</script>

			</head>
			<body onload="window_onload()" onresize="window_onresize()" style="width:100%; height:100%; overflow:hidden">
				<table class="tb1" id="tbCabecera">
					<tr class="tbLabel">
						<td style='text-align: center; width:182px' nowrap='true'>Tipo</td>
						<td style='text-align: center; width:82px'  nowrap='true'>Num. Auto.</td>
						<td style='text-align: center; width:102px' nowrap='true'>Documento</td>
						<td style='text-align: center; width:162px' nowrap='true'>Nombre y Apellido</td>
						<td style='text-align: center; width:162px' nowrap='true'>Beneficiario</td>
						<td style='text-align: center; width:182px' nowrap='true'>Estado</td>
						<td style='text-align: center' nowrap='true'>Importe</td>
					</tr>
				</table>

				<div id='div_scroll' style='width:100%; height:100%; overflow:auto'>
					<table class="tb1">
						<xsl:apply-templates select="xml/rs:data/z:row" />
					</table>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="z:row">
		<xsl:variable name="id_srv" select="@id_srv"/>
		<xsl:variable name="pos" select="position()"/>
		<xsl:variable name="id_srv_ant" select="/xml/rs:data/z:row[position() = ($pos -1)]/@id_srv"/>
		<xsl:choose>
			<xsl:when test="$id_srv != $id_srv_ant or $pos = 1">
						
						<tr>
							<td style='text-align: left; width:180px' nowrap='true'>
								<xsl:value-of select="@id_srv_tipo"/> - <xsl:value-of select="@srv_tipo"/>
							</td>
							<td style='text-align: right; width:80px; vertical-align:middle'>
								<xsl:value-of select="@nro_credito"/>
							</td>
							<td style='text-align: right; width:100px; vertical-align:middle'>
								<xsl:value-of select='@documento'/> - <xsl:value-of select='@nro_docu'/>
							</td>
							<td style='text-align: left; width:160px; vertical-align:middle' nowrap='true'>
								<xsl:value-of select="substring(@strNombreCompleto,0,20)"/>
							</td>
							<td style='text-align: left; width:160px; vertical-align:middle' nowrap='true'>
								<xsl:value-of select="substring(@razon_social,0,20)"/>
							</td>
							<td style='text-align: left; vertical-align:middle; width:180px'>
								<xsl:value-of select='@estado_desc'/> - <xsl:value-of select="foo:conv_fecha_to_str(string(@fe_estado), 'dd/mm/aa')"/>
							</td>
							<td style='text-align: right; vertical-align:middle'>
								$<xsl:value-of select='format-number(@importe_neto, "0.00")'/>
							</td>
						</tr>
					</xsl:when>
					<xsl:when test="$id_srv = $id_srv_ant">
						<tr>
							<td style='text-align: left; width:180px' nowrap='true'>
							<xsl:value-of select="@id_srv_tipo"/> - <xsl:value-of select="@srv_tipo"/>
						</td>
						<td style='text-align: right; width:80px; vertical-align:middle'>
							<xsl:value-of select="@nro_credito"/>
						</td>
						<td style='text-align: right; width:100px; vertical-align:middle'>
							<xsl:value-of select='@documento'/> - <xsl:value-of select='@nro_docu'/>
						</td>
						<td style='text-align: left; width:160px; vertical-align:middle' nowrap='true'>
								<xsl:value-of select="substring(@strNombreCompleto,0,20)"/>
						</td>
						<td style='text-align: left; width:160px; vertical-align:middle' nowrap='true'>
								<xsl:value-of select="substring(@razon_social,0,20)"/>
						</td>
						<td style='text-align: left; vertical-align:middle; width:180px'>
							<xsl:value-of select='@estado_desc'/> - <xsl:value-of select="foo:conv_fecha_to_str(string(@fe_estado), 'dd/mm/aa')"/>
						</td>
						<td style='text-align: right; vertical-align:middle'>
							$<xsl:value-of select='format-number(@importe_neto, "0.00")'/>
						</td>
					</tr>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>