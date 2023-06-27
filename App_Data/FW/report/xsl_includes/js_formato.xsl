<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:msxsl="urn:schemas-microsoft-com:xslt"
				xmlns:foo="http://www.broadbase.com/foo" extension-element-prefixes="msxsl" exclude-result-prefixes="foo">
    
	<msxsl:script language="javascript" implements-prefix="foo">
		<![CDATA[	
    
      function stringToScriptString(cad)
        {
        var str = "\\\\" // las dos primeras barras son el escape, y las segundas dos barras es la barra escapada
        var reg = new RegExp(str, "g")
        cad = cad.replace(reg, "\\\\")

        var str = "'"
        var reg = new RegExp(str, "g")
        cad = cad.replace(reg, "\\\\'")

        var str = "\n"
        var reg = new RegExp(str, "g")
        cad = cad.replace(reg, "\\\\n")

        cad = "'" + cad + "'"
        return cad.toString() 
        }

		   	function str_to_script(cad)
		      {
		      var strreg = "\n"
		      var reg = new RegExp(strreg, "ig")
		      cad = cad.replace(reg, '\\n')
    		  
		      strreg = "'"
		      reg = new RegExp(strreg, "ig")
		      cad = cad.replace(reg, "\\'")
    		  
		      return cad
		      }
		  
		    function str_to_html(cad)
		      {
		      var strreg = "\n"
		      var reg = new RegExp(strreg, "ig")
		      cad = cad.replace(reg, '<br/>')
    		  
		      return cad
		      }  
		      
		    function eliminar_salto_linea(cad)
		     {
		      var strreg = "\n"
		      var reg = new RegExp(strreg, "ig")
		      cad = cad.replace(reg, ' ')
    		  
		      return cad.toString() 
		     }    
            
            function formatear_aviso(str)
            {
             var max_caracteres = 35
             var bn = str.indexOf("\n")
             if (bn == -1)
               bn = 35
             if (bn >= max_caracteres) 
               {
               if (str.length >= 35)
                 {
                 for (var i = 35; i > 0; i--)
                   if (str.substr(i, 1) == ' ') 
                     {
                      bn = i
                      break    
                     }
                 }    
                 else    
                   bn = str.length
               if (i == 0)
                 bn = 35
               }
             
              str = "<b>" + str.substr(0,bn+1) + "</b>" +  str.substr(bn+1, str.length - bn)
              
              str = eliminar_salto_linea(str)
             
             return str
            
            }
            
			function rellenar_izq(numero, largo, relleno)
			{
			if (typeof(numero) == 'object')
			  numero = String(numero)
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			while(strNumero.length < largo)
			  strNumero = relleno + strNumero.toString() 
			return strNumero.toString() 
			}
			
			function entero(numero)
			{
			var nro_entero = Math.floor(parseFloat(numero))
			return String(nro_entero)
			}
			
			function decimal(numero)
			{
			var numero = parseFloat(numero)
			var nro_entero = Math.floor(numero)
			numero = numero - nro_entero
			var nro_dec = Math.round(numero * 100)
			if (numero < 1)
			  nro_dec = '0' + nro_dec
			return nro_dec
			}	
			
			function rellenar_der(numero, largo, relleno)
			{
			if (typeof(numero) == 'object')
			  numero = String(numero)
			var strNumero = numero.toString()
			if (strNumero.length > largo)
			  strNumero = strNumero.substr(1, largo)
			  
			while(strNumero.length < largo)
			  strNumero = strNumero.toString() + relleno
			return strNumero.toString() 
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
       return FechaToSTR(cadena, 1)
      }
		function FechaToSTR(cadena, modo)
      {
      if(!modo)
         modo = 1
		  var objFecha = parseFecha(cadena)
		  if (isNaN(objFecha.getDate()))
		     return ''
		  
  
      var dia = rellenar_izq(objFecha.getDate(),2, "0")
	    var mes = rellenar_izq(objFecha.getMonth()+1,2, "0")
	    var anio = objFecha.getFullYear()

      switch (modo)
        {
        case 1:
          return (dia + '/' + mes + '/' + anio).toString() 
          break;
        case 2:
          return  (mes + '/' + dia + '/' + anio).toString() 
          break;
        case 3:
          return  (anio + '-' + mes + '-' + dia).toString() 
          break;
        }
      }
          
    function HoraToSTR(cadena)
          {
		  var objFecha = parseFecha(cadena)
		  if (isNaN(objFecha.getDate()))
		     return ''
		  var hora
		  var minuto
		  var segundo
		  if (objFecha.getHours() < 10)
		     hora = '0' + objFecha.getHours().toString()
		  else
		     hora = objFecha.getHours().toString() 
		  
		  if ((objFecha.getMinutes() +1) < 10)
		     minuto = '0' + objFecha.getMinutes().toString()
		  else
		     minuto = objFecha.getMinutes().toString() 	 
         
      if ((objFecha.getSeconds() +1) < 10)
		     segundo = '0' + objFecha.getSeconds().toString()
		  else
		     segundo = objFecha.getSeconds().toString() 	    
         
		  var anio = objFecha.getFullYear()  
          var modo = 1
          if (modo == 1) 
            return (hora + ':' + minuto + ':' + segundo).toString() 
          else
            return (hora + ':' + minuto + ':' + segundo).toString() 
          }
          
       function Mayusculas(texto)
        {
        return texto.toUpperCase()
        }
        
      function fecha_vencida(cadena)
		      {
		        var hoy = new Date();
		        var man = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate()+2);
		        var objFecha = parseFecha(cadena)
		        var res = objFecha <= man  
		        return res 
		      }     
          
    function replace(cad, buscar, remplazar)
           {
           cad = cad.toString()
           var re = new RegExp('\\\\',"ig")
           buscar = buscar.replace(re, '\\\\')
           var re = new RegExp(buscar,"ig")
           var res = cad.replace(re, remplazar);
           return res
           }          
	
     function formatoYYYYMMDD(fecha_sin_formato)
       {
		var fecha = parseFecha(fecha_sin_formato)
		var fecha_retorno= fecha.getFullYear().toString()
		
		if (fecha.getMonth() < 9)
			fecha_retorno += '0' + (fecha.getMonth() + 1)
		else
			fecha_retorno += (fecha.getMonth() + 1).toString()
			
		if (fecha.getDate().toString().length == 1)
			fecha_retorno += '0' + fecha.getDate()
		else
			fecha_retorno += fecha.getDate().toString()
				
		return String(fecha_retorno)
	  }
    
    	function formatoMM_DD_YY(fecha_sin_formato){
				var fecha = parseFecha(fecha_sin_formato)
				var mes, dia, anio
				var anio = fecha.getFullYear().toString().substr(2, 2)
				
				if (fecha.getMonth() < 9)
					mes = '0' + (fecha.getMonth() + 1)
				else
					mes = (fecha.getMonth() + 1).toString()
					
				if (fecha.getDate().toString().length == 1)
					dia = '0' + fecha.getDate()
				else
					dia = fecha.getDate().toString()
				
				return String(mes + '/' + dia + '/' + anio)
			}
			
      function formatoDDMMYY(fecha_sin_formato){
      
				var fecha = parseFecha(fecha_sin_formato)
				var mes, dia, anio
				var anio = fecha.getFullYear().toString().substr(2, 2)
				
				if (fecha.getMonth() < 9)
					mes = '0' + (fecha.getMonth() + 1)
				else
					mes = (fecha.getMonth() + 1).toString()
					
				if (fecha.getDate().toString().length == 1)
					dia = '0' + fecha.getDate()
				else
					dia = fecha.getDate().toString()
				
				return String(dia + mes + anio)
        
			}
			
			  function formatoDDMMYYYY(fecha_sin_formato){
      
				var fecha = parseFecha(fecha_sin_formato)
				var mes, dia, anio
				var anio = fecha.getFullYear().toString()
				
				if (fecha.getMonth() < 9)
					mes = '0' + (fecha.getMonth() + 1)
				else
					mes = (fecha.getMonth() + 1).toString()
					
				if (fecha.getDate().toString().length == 1)
					dia = '0' + fecha.getDate()
				else
					dia = fecha.getDate().toString()
				
				return String(dia + mes + anio)
        
			}
      
    function format_params(cad) 
    {
    
		  cad = cad.replace(/(\r\n|\n|\r)/gm, '<br/>')
      //cad = cad.replace(/"/g, '\'');
      var res = cad.replace(/'/g, '\\\'');

      return res
    }
      
		]]>
	</msxsl:script>
</xsl:stylesheet>