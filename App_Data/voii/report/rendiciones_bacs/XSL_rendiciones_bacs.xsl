<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882"
				xmlns:rs='urn:schemas-microsoft-com:rowset' 
				xmlns:z='#RowsetSchema'
				xmlns:msxsl="urn:schemas-microsoft-com:xslt" 
	            xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">

	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[
	
		
			 function rellenar_izq(numero, largo, relleno) {
            var strNumero = numero.toString()
            if (strNumero.length > largo)
                strNumero = strNumero.substr(1, largo)
            while (strNumero.length < largo)
                strNumero = relleno + strNumero.toString()
            return strNumero
        }
        function rellenar_der(numero, largo, relleno) {
            var strNumero = numero.toString()
            if (strNumero.length > largo)
                strNumero = strNumero.substr(1, largo)

            while (strNumero.length < largo)
                strNumero = strNumero.toString() + relleno
            return strNumero
        }
        function decimales(cadena, decimales) { //convierte a string un entero o nro floate con "decimales" cantidad de decimlaes luego de la coma
         
            var cad = String(cadena);
            var partes = new Array();
            var resultado = cadena;

            if (cad != "") {
                partes = cad.split('.');
                if (partes.length > 1) {
                    var p1 = String(partes[1])
                    if (p1.length > decimales) {
                        resultado = String(partes[0]) +  p1.substr(0, decimales)
                    }
                    else {
                        var part1 = ""

                        for (var i = 0; i < decimales - p1.length ; i++) {
                            part1 += "0"
                        }
                        partes[1] = p1 + part1
                        resultado = partes[0] +  partes[1]
                    }
                }
            }

            return resultado;

        } //fin de la funcion decimales
        function rellenar_con_decimales(cadena, cant_dec, lado, caracter, cant)//dada la cadena rellena con cant_dec, hacia lado, con el caracter 'caracter', cant=cantidad de caracteres a completar 
        {

            if (cadena == null || cadena == '' || cadena == 0 || cadena == '0') {
                cadena = "0.00"
            }

            var res1 = decimales(cadena, cant_dec)
            var resultado = ''
            if (lado == "izq") {
                resultado = rellenar_izq(res1, cant, caracter)
            }
            if (lado == "der") {
                resultado = rellenar_der(res1, cant, caracter)
            }
            return resultado;
        }

        function parsear_fecha(dato) {//esta funcion convierte la cadena de tipo fecha al formato aaaammdd
          if(dato=="")return "00000000";
            var cadena = new String(dato)
            cadena = cadena.replace(/-/g, '')
            cadena = cadena.replace(/\./g, '')
            cadena = cadena.replace(/:/g, '')
            cadena = cadena.replace(' ', '')
            cadena = cadena.substr(0, 8)
            return cadena;
        }
      
]]>	
	</msxsl:script>
	<xsl:template match="/">
		<xsl:value-of select="string(/xml/rs:data/z:row/@feProceso)" />
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="string(/xml/rs:data/z:row/@feDenuncia)" />
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="string(/xml/rs:data/z:row/@codAdmin)"/>
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="string(/xml/rs:data/z:row/@codOrig)"/>
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="string(/xml/rs:data/z:row/@canalPago)" />
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="string(count(/xml/rs:data/z:row))" />
		<xsl:value-of select="string('|')" />
		<xsl:value-of select="format-number(sum(/xml/rs:data/z:row/@importe_cedido),'#.00')" />
		<xsl:text>&#xD;&#xA;</xsl:text>
        <xsl:apply-templates select="/xml/rs:data/z:row" />
    
  </xsl:template>

<xsl:template match="z:row">    
    <xsl:value-of   select="string(@nroreferencia)" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@tipoCuota)" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@nrocuo)" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@feVenc) " />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@feDesc)" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="format-number(@importe_cedido,'#.00')" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="format-number(@compensatorios_punitorios,'#0.00')" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="format-number(@importe_no_cedido,'#0.00')" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@novCli)" />
    <xsl:value-of select="string('|')" />
    <xsl:value-of select="string(@novAdm)" />    
    <xsl:text>&#xD;&#xA;</xsl:text>
</xsl:template>

</xsl:stylesheet>