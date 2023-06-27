import System;
import System.DateTime;
import nvFW.nvConvertUtiles;
import nvFW;


/************************************************************/
//Permite la ejecución de código javascript en el framework
//Se agregan algunas funciones por compatibilidad con las 
//versiones anteriores
/************************************************************/
package nvEvaluator
         {
     class jsEvaluator
            {
            public static function Eval(expr : String) : Object 
            { 
                return eval(expr); 
            }
            
            static function rellenar_izq(numero, largo, relleno)
             {
              var strNumero = numero.toString()
              if (strNumero.length > largo)
              strNumero = strNumero.substr(1, largo)
              while(strNumero.length < largo)
              strNumero = relleno + strNumero.toString()
              return strNumero
             }

           
            static function FechaToSTR(objFecha, modo)
              {
              if(!modo)
                modo = 2
              switch (modo)
                {
                case 1:
                  return objFecha.getDate() + '/' + (objFecha.getMonth() +1) + '/' + objFecha.getFullYear()
                  break;
                case 2:
                  return  (objFecha.getMonth() +1) + '/' + objFecha.getDate() + '/' + objFecha.getFullYear() 
                  break;
                case 3:
                  return  objFecha.getFullYear() + '-' + rellenar_izq(objFecha.getMonth() +1,2, '0') + '-' + rellenar_izq(objFecha.getDate(),2,'0')
                  break;
                }
              }
            
            static function ajustarFecha(objInput)
              {
                return "convert(datetime, '" + (objInput.getMonth() + 1) + '/' + objInput.getDate() + '/' + objInput.getFullYear()  + "', 101)"
              }
              

            } //Cierra clase
         } //Cierra package