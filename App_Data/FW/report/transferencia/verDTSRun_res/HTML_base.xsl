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
        //function FechaToSTR(objFecha, modo)
		function FechaToSTR(cadena)
          {
		  var objFecha = parseFecha(cadena)
		  var dia
		  var mes
		  var anio
		  var hora
		  var minutos
		  var segundos
		  
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
		     minutos = '0' + objFecha.getMinutes().toString()
		  else
		     minutos = objFecha.getMinutes().toString()			 

		  if (objFecha.getSeconds() < 10)
		     segundos = '0' + objFecha.getSeconds().toString()
		  else
		     segundos = objFecha.getSeconds().toString()
			 
		  var modo = 1
          if (modo == 1) 
            return dia + '/' + mes + '/' + anio + ' ' + hora + ':' + minutos + ':' + segundos
          else
            return  mes + '/' + dia + '/' + anio + ' ' + hora + ':' + minutos + ':' + segundos
          }			
		
		]]>
	</msxsl:script>
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
				<title></title>
				<link href="../css/base.css" type="text/css" rel="stylesheet"/>
			</head>
			<body>
				<table class="tb1">
					<tr class="tblabel">
						<td colspan="3">
							idRUN <xsl:value-of select="/dtsrun/@id_run"/>
						</td>
					</tr>
					<xsl:apply-templates select="dtsrun/*"/>
				</table>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="cmd">
		<tr>
			<td>CMD
			</td>
			<td>-
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="iniciado">
		<tr>
			<td style="background-color: #4B8BF4;color:white">Iniciado</td>
			<td >
				<xsl:value-of select="."/>
			</td>
			<td>-</td>
		</tr>
	</xsl:template>
	<xsl:template match="finalizado">
		<tr >
			<td style="background-color: #1AA15F;color:white">Finalizado</td>
			<td nowrap="true" >
				<xsl:value-of select="."/>
			</td>
			<td>-</td>
		</tr>
	</xsl:template>
	<xsl:template match="transcurrido">
		<tr>
			<td  style="background-color: #4B8BF4;color:white">Transcurrido</td>
			<td nowrap="true">
				<xsl:value-of select="."/>
			</td>
			<td>-</td>
		</tr>
	</xsl:template>
	<xsl:template match="error">
		<tr>
			<td style="background-color: red;color:white">Error</td>
			<td nowrap="true">
			       <xsl:value-of select="string(@inicio)"/>
			</td>
			<td style="background-color: red;color:white">
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="advertencia">
		<tr>
			<td style="background-color: yellow !Important">Advertencia</td>
			<td nowrap="true">
				 <xsl:value-of select="string(@inicio)"/>
			</td>
			<td style="background-color: yellow !Important">
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="progreso">
		<tr >
			<td>Progreso</td>
			<td nowrap="true">
				 <xsl:value-of select="string(@inicio)"/>
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	<xsl:template match="dtexec">
		<tr>
			<td>dtexec</td>
			<td>-</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
    <xsl:template match="comentario">
        <tr>
            <td>comentario</td>
            <td>-</td>
            <td>
                <xsl:value-of select="."/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="params"></xsl:template>
	<xsl:template match="*">
		<tr>
			<td>
                ??:
			</td>
			<td nowrap="true">
                <xsl:if test="count(@inicio) > 0">
                    <xsl:value-of select="foo:FechaToSTR(string(@inicio))"/>
                </xsl:if>	
			</td>
			<td>
				<xsl:value-of select="."/>
			</td>
		</tr>
	</xsl:template>
	
	
</xsl:stylesheet>