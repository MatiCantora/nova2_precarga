<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
				xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
	<xsl:output method="html" version="1.0" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
	  function parseFecha(strFecha)
			{
				var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
				a = a.substr(0, a.indexOf('.'))
				var fe = new Date(Date.parse(a))
				
				return fe
			}
	
		function conv_fecha_to_str(cadena, modo)
          {
		  var objFecha = parseFecha(cadena)
		  var dia
		  var mes
		  var anio
		  var hora
		  var minuto
		  var segundo
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
	  <xsl:apply-templates select="xml/rs:data/z:row" />
		<a>
		   <xsl:attribute name="href">
			javascript:versiones_doc_onclick(<xsl:value-of select="xml/rs:data/z:row/@nro_ref"/>,<xsl:value-of select="xml/rs:data/z:row/@nro_ref_doc"/>)
	       </xsl:attribute> 
			<xsl:attribute name='onmouseover'>
				this.title="Ver todas las versiones del documento"; return
			</xsl:attribute> +
	    </a>  
	</xsl:template>
	<xsl:template match="z:row">
		<a>
			<xsl:attribute name="href">
				javascript:seleccionar_version(<xsl:value-of select="@ref_doc_version"/>,<xsl:value-of select="@nro_ref_doc"/>,<xsl:value-of select="@nro_ref"/>)
			</xsl:attribute>
			<xsl:attribute name='onmouseover'>
				this.title="Modificador: <xsl:value-of select="foo:conv_fecha_to_str(string(@ref_doc_fe_estado), 'dd/mm/aa hh:mm:ss')"/> - <xsl:value-of select='@nombre_operador'/>"; return
			</xsl:attribute>
			<xsl:value-of select="@ref_doc_version"/>
		</a> -

	</xsl:template>
	
</xsl:stylesheet>