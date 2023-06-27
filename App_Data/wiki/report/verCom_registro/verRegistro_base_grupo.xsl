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
		//modo 1 = dd/mm/yyyy
        //modo 2 = mm/dd/yyyy
		//modo 3 = dd/mm/yyyy hh:mm:ss
		
    var hora
    var minuto
    var segundo

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

		function rellenar0(numero, largo)
			{
			var strNumero
			strNumero = numero.toString()
			while(strNumero.length < largo)
			  strNumero = '0' + strNumero.toString() 
			return strNumero
			}
		function ucase(a)	
		  {
		  return a.toUpperCase()
		  }
		
	
		]]>

    </msxsl:script>

    <xsl:template match="/">
    
       <xsl:apply-templates select="xml/rs:data/z:row" />
    
    </xsl:template>
    
    <xsl:template match="z:row">
        <table style="width:100%">
            <tr>
                <td style="text-align:left;width:10%">&#160;</td>
                <td style="text-align:left;width:90%">
                  <a>
                     <xsl:attribute name="id">link_<xsl:value-of select="@nro_com_grupo"/></xsl:attribute>
                    <xsl:attribute name="href">javascript:Mostrar_Registro_grupo(<xsl:value-of select="@nro_com_grupo"/>,'<xsl:value-of select="@com_grupo"/>')</xsl:attribute>
                    <xsl:value-of select="@com_grupo"/>
                  </a>
                </td>
                <td style="text-align:left">&#160;</td>
            </tr>
        </table>
    </xsl:template>

</xsl:stylesheet>