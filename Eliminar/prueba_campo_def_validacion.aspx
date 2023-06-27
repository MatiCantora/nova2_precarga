<%@ Page Language="VB" AutoEventWireup="false"  Inherits="nvFW.nvPages.nvPageAdmin" %>


<%
    Me.contents("filtroXMLmiCampo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>estado as [id], descripcion as campo</campos><filtro></filtro></select></criterio>")
    
 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1">
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
        

    <% = Me.getHeadInit()%>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

    <script type="text/javascript" language="javascript">
         
        function window_onload()
          {
         
           
            
//          var el = $("input_txt")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

//          el = $("input_hidden")
//          el.addEventListener('change', handler, false)
//          //el.addEventListener('domattrmodified', handler, false)
//          //el.onchange = handler

          }

function valDigito2(e,strCaracteres)
 {
    debugger
  var key 
 if(window.event) // IE
   key = e.keyCode;
 else 
   key = e.which;
     
  if (key == 13 || key == 9 || key == 8 || key == 27 || key == 0)
      return true
    
  if(!strCaracteres) strCaracteres = ''
  
  var strkey = String.fromCharCode(key)
  var encontrado = strCaracteres.indexOf(strkey) != -1
  
  if (((strkey < "0") || (strkey > "5")) && !encontrado)
    return false
  return true
 }
    </script>

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
    <table class="tb1 ">
        
        <tr class="tbLabel0">
            <td>
                Ejemplos de campo_def Validación
            </td>
        </tr>
    </table>
    <table class="tb1 ">
        <tr>
            <td>
                Tipo 103 - Fechas
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miFecha',{ nro_campo_tipo: 103,enDB: false })
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 103 - Por ASP
            </td>
            <td style="">
                 <%= nvFW.nvCampo_def.get_html_input("fecha2", nro_campo_tipo:=103, enDB:=False)%>
           </td>
        </tr>
        <tr>
            <td>
                Tipo 104 - Texto
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miTexto',{ nro_campo_tipo: 104,enDB: false, valKeypress: function(a, b) {}, valChange:  function(a, b) {}, input_pattern: '[A-Za-z]{3}', input_title: '', input_max_length: '22'})
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 104 - Texto
            </td>
            <td>
              <form action="/action_page.php">
                   Country code: <input type="text" name="country_code" pattern="[A-Z]{3}" title="Three letter country code" />
                   <input type="submit">
              </form>
            </td>
        </tr>
    </table>

    <table class="tb1"><tr>
	
	<td style="font-weight: bold; text-align: left" width="30%">
		Servidor:
	</td>
	<td  colspan="2">
		<script type="text/javascript">
			campos_defs.add('cod_servidor', { enDB: false,
				nro_campo_tipo: 1,
				depende_de: null,
				filtroXML: "<criterio><select vista='nv_servidores'><campos> cod_servidor  as id, cod_servidor as  campo </campos><filtro></filtro><orden>[campo]</orden></select></criterio>",
				filtroWhere: null,
				depende_de_campo: null
			});
	
		</script>
	</td>
	
	
	
	<td  colspan="2">
		<script type="text/javascript">
			campos_defs.add('cod_sistema', { enDB: false,
				nro_campo_tipo: 1,
				depende_de: 'cod_servidor',
				filtroXML: "<criterio><select vista='nv_servidor_sistemas'><campos>cod_sistema  as id, cod_sistema as  [campo] </campos><filtro></filtro><orden>[campo]</orden></select></criterio>",
				filtroWhere: null,
				depende_de_campo: 'cod_servidor'
			});
            </script>
	
	</td>
	
	
	</tr>
	
	</table>
    
    
    <input type="text" onkeypress="return (valDigito(event, '/') && valDigito2(event, '/'))"   /><input type="text" id="deb" />

    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="/admin/enBlanco.htm"></iframe>
</body>
</html>
