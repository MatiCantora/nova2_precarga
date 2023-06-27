    function SCRIPT_to_sqlstring(tipo_dato,valor)
{
 var res = ''
  if (valor == null || valor == 'null')
    return "'null'"
    
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = "'" + parseInt(valor) + "'"
       break
    case 'MONEY':
       res = "'" + parseFloat(valor).toFixed(2) + "'"
       break
    case 'DATETIME':
       try {res = "'" + FechaToSTR(valor) + "'"} catch(e){res = "'" + valor + "'"}
       break
    case 'BIT':
       var str = valor.toString() 
       res = str.toLowerCase() == 'true' || str == '1' ? "'true'" : "'false'"
       break 
    case 'FILE' :
       res = "'" + valor + "'"     
    default :
       res = "'" + replace(valor, "'", "''") + "'"
    }
  if (res.toString() == '')
    res = "''"   
  return res
}

function SCRIPT_set_valor(tipo_dato, valor)
  {
  var res = ''
  if (valor == null)
    return null
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = valor
       break
    case 'MONEY':
       res = valor
       break
   case 'DATETIME':
        res = "new Date(Date.parse('" + valor.toString() + "'))"
       break
    case 'BIT':
       var str = valor.toString() 
       res = str.toLowerCase() == 'true' || str == '1' ? 'true' : 'false'
       break 
    case 'FILE' :
       res = "'" + valor + "'"     
    default :
       var reg = new RegExp("\\\\", "ig") //corregir barra de escape
       valor = valor.replace(reg, "\\\\")
       reg = new RegExp("'", "ig")      //corregir comilla simple
       valor = valor.replace(reg, "\\'")
       reg = new RegExp("\n", "ig")     //corregir saltos de lineas
       valor = valor.replace(reg, "\\n")
       reg = new RegExp("\r", "ig")     //corregir saltos de lineas
       valor = valor.replace(reg, "\\r")

       res = "'" + valor + "'"  
       //res = "'" + replace(replace(valor, '\\', '\\\\'), '\n', '\\n') + "'"
    }
  if (res.toString() == '' || res.toString() == "'null'")
    res = "''"   
  return res
  }

 function STRING_to_SCRIPT(tipo_dato, valor)  
   {
  var res = ''
  if (valor == null || valor == 'null' || valor === '' && tipo_dato.toUpperCase() != 'VARCHAR')
    return null
  if (valor == null)  
    return null
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = eval(valor)
       break
    case 'MONEY':
       res = eval(valor)
       break
    case 'DATETIME':
        res = parseFecha(valor, 'SCRIPT')
       break
   case 'BIT':
       var str = valor.toString()
       if (str == '0')
           return null
       res = (str.toLowerCase() == 'true' || str == '1') ? true : false
       break 
    case 'FILE' :
       res = valor
    default :
       res = valor
    }
  return res
   }
   
function SCRIPT_to_STRING(tipo_dato, valor)  
   {
  var res = ''
  if (valor == null || valor == 'null' || valor === '' && tipo_dato.toUpperCase() != 'VARCHAR')
    return "''"
  if (valor == null)  
    return "''"
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = "'" + valor + "'"
       break
    case 'MONEY':
       res = "'" + valor.toFixed(2) + "'"
       break
    case 'DATETIME':
       res = "'" + FechaToSTR(valor) + "'"
       break
   case 'BIT':
       var str = valor.toString()
       if (str == '0')
           return false
       res = (str.toLowerCase() == 'true' || str == '1') ? true : false
       break 
    case 'FILE' :
       res = "'" + valor + "'"
    default :
       var reg = new RegExp("\\\\", "ig") //corregir barra de escape
       valor = valor.replace(reg, "\\\\")
       reg = new RegExp("'", "ig")      //corregir comilla simple
       valor = valor.replace(reg, "\\'")
       reg = new RegExp("\n", "ig")     //corregir saltos de lineas
       valor = valor.replace(reg, "\\n")
       reg = new RegExp("\r", "ig")     //corregir saltos de lineas
       valor = valor.replace(reg, "\\r")

       res = "'" + valor + "'" 
    }
  return res
   }   
  
 function USER_set_valor(tipo_dato, valor)
  {
  var res = ''
  if (valor == null)
    return ''
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = valor
       break
    case 'MONEY':
       res = valor
       break
    case 'DATETIME':
       res = FechaToSTR(valor)
       break
    case 'BIT':
       var str = valor.toString() 
       res = (str.toLowerCase() == 'true' || str == '1') ? true : false
       break 
    case 'FILE' :
       res = valor
    default :
       res = valor
    }
  return res
  } 
  
function USER_get_valor(tipo_dato, valor)
  {
   var res = ''

 // if ((valor == null || valor == 'null' || valor === '') && tipo_dato.toUpperCase() != 'VARCHAR')
 //      return null

  if (valor == null)
      return null

  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = valor
       break
    case 'MONEY':
       res = valor
       break
    case 'DATETIME':
       var fe
       if (valor.constructor == Date)
         fe = valor
       else
         fe = parseFecha(valor, 'dd/mm/yyyy')
       res = FechaToSTR(fe)
       break
    case 'BIT':
       var str = valor.toString() 
       res = (str.toLowerCase() == 'true' || str == '1') ? true : false
       break 
    case 'FILE' :
       res = valor
    default :
       res = valor
    }
  return res
  }   

function json_encode(el, options)
   {
   if (options == undefined) options = {}
   var strJson = ""
   switch (typeof(el))
     {
     case 'object':
       if (el == null)
         {
         strJson = "null"
         break
         }
       if (el.constructor == Date)
         {
         strJson = "new Date(Date.parse('" + el.toString() + "'))"
         }
       else
         {  
         strJson = "{"
         for (var n in el)
           {
           if (strJson != "{")
             strJson += ", "
           strJson += n + ":" + json_encode(el[n], options)
           }
         strJson += "}"
         }
       break
       
     case 'string':
       var str = el
       var reg = new RegExp("\\\\", "ig") //corregir barra de escape
       str = str.replace(reg, "\\\\")
       reg = new RegExp("'", "ig")      //corregir comilla simple
       str = str.replace(reg, "\\'")
       reg = new RegExp("\n", "ig")     //corregir saltos de lineas
       str = str.replace(reg, "\\n")
       reg = new RegExp("\r", "ig")     //corregir saltos de lineas
       str = str.replace(reg, "\\r")

       strJson = "'" + str + "'"  
       break
     
     case 'boolean':
       strJson = el.toString() 
       break 
     
     case 'number':
       strJson = el.toString() 
       break    
     
     case 'function':
       var allow_function =  options.allow_function == undefined ? true : options.allow_function
       if (allow_function)
         strJson = el.toString()
       else 
         strJson = null
       break
     default:
       debugger     
     }
     return strJson
   }
 
function TSQL_tipo_dato(tipo_dato)
  {
  var res = ''
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
       res = ' int'
       break
    case 'MONEY':
       res = ' money'
       break
    case 'DATETIME':
       res = ' datetime'      
       break
    case 'BIT':
       res = ' bit'      
       break   
    default :
       res = ' varchar(max)'
    }
  return res
  }
  
function TSQL_set_valor(tipo_dato, valor)
  {
  if (valor == null || valor == 'null')
    return 'null'
  var res = ''
  switch (tipo_dato.toUpperCase())
    {
    case 'INT':
         res = valor
       break       
    case 'MONEY':
         res = valor
       break       
    case 'DATETIME':
         res = " " + TSQL_convertFecha(valor)
       break
    //case 'FILE':
    //   res = "'" + valor + "'"
    //   break  
    case 'BIT':
       res = valor ? 1 : 0
       break  
    default : //varchar y file
       var valor1
       var reg = new RegExp("'", 'ig')
       valor1 = valor.replace(reg, "''")
       res = "'" + valor1 + "'"
    }
  return res
  }
  
function TSQL_get_valor(tipo_dato, valor)
  {
  if (valor == null)
    return null
  var res = ''
  switch (tipo_dato.toUpperCase())
    {
    case 'DATETIME':
         res = new Date(Date.parse(valor))
       break
    case 'BIT':
       res = valor == 1 || valor 
       break  
    default : 
       res = valor
    }
  return res
  }  
  
function EVAL_STRING(str)
  {
  var strEval = "function res(){" + Transf.paramSCRIPT() + "; return " + str + " } res()"
  return eval(strEval)
  }
  
function ajustarFecha(objInput)
  {
  //var Cfecha = new Date(Date.parse(MMDDYYYY(objInput)))
  return "convert(datetime, '" + FechaToSTR(objInput,2) + "', 101)"
  } 
  