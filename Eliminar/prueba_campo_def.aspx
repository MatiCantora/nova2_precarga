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
        function btn_onclick()
          {
          campos_defs.clear('cod_servidor')
//          debugger
//          $("input_hidden").value = $("input_txt").value
          }

        function btn2_onclick()
          {
          campos_defs.set_value('cod_servidor', "dev")
//          $("input_txt").value = "algo"
          }


         function btn3_onclick()
          {
          debugger
          campos_defs.set_value("id_param", "parametro_prueba")
//          $("input_txt").value = "algo"
          }
          

        function handler(a, b, c)
          {
//          debugger
//          var a  = ""
          }  


          function removeAll()
            {
            debugger
            //$('cbcampo_def').options.length = 0
            //$('cbcampo_def').options.length = 0
              
            campos_defs.clear_list("campo_def")

            }
    </script>

</head>
<body onload="window_onload()"  style="width: 100%; height: 100%; overflow: auto" >
    <table class="tb1 ">
        
        <tr class="tbLabel0">
            <td>
                Ejemplos de campo_def
            </td>
        </tr>
    </table>
    <table class="tb1 highlightTROver">
        <tr>
            <td>
                Tipo 1 Cargado por codigo
            </td>
            <td> <script type="text/javascript">
                     
                     //var rs = new tRS()
                     //  rs.addField("id", "varchar")
                     //  rs.addField("campo", "varchar")
                     //  rs.addRecord({id:"1", campo:'Algo de 1', allowSelection: true})
                     //  rs.addRecord({id:"2", campo:'Algo de 2', allowSelection: false})

                      // var id = rs.getdata("id")  
                       //var campo = rs.getdata("campo")
                     campos_defs.add('cod_servidor1', {filtroXML:"<criterio><select vista='nv_servidores'><campos>distinct cod_servidor as id, cod_servidor as [campo] </campos><orden>[campo]</orden></select></criterio>", nro_campo_tipo : 1, enDB: false, json: true});
                     //campos_defs.items['cod_servidor1'].rs = rs
                </script>
                </td>
        </tr>
        <tr>
            <td onclick="campos_defs.set_first('tipo_docu', true);campos_defs.set_first('campo_def', true);campos_defs.set_first('nro_login2', true)  " ondblclick="campos_defs.set_value('tipo_docu', 7)">
                Tipo 1 enDB por script
            </td>
            <td style="width: 50%">
                <script type="text/javascript">
                    campos_defs.add('id_param') //,{permite_codigo:true, onchargefinish:function(campo_def){}}
                </script>

            </td>
        </tr>
        <tr>
            <td>
                Tipo 1 - Campo_def - <input type="button" value="Limpiar lista" onclick="return campos_defs.clear_list('campo_def')">
            </td>
            <td style="width: 50%">
                <%
                    Response.Write(nvFW.nvCampo_def.get_html_input("campo_def"))
                    %>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 3
            </td>
            <td style="25%">
                <%= nvFW.nvCampo_def.get_html_input("id_param")%>
            </td>
        </tr>
        <tr>
            <td>Tipo 1 - Autocomplete</td>
            <td>
                <script>
                    campos_defs.add('miCampo4',{ nro_campo_tipo: 1,enDB: false,filtroXML: nvFW.pageContents.filtroXMLmiCampo, autocomplete: true, autocomplete_minlength: 0, autocomplete_match: 'todo'})
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 2
            </td>
            <td style="">
                <%= nvFW.nvCampo_def.get_html_input("nro_login2")%>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 3 - Por codigo
            </td>
            <td style="">
                <%
                    Dim miCampo_def As New nvFW.tnvCampo_def
                    miCampo_def.campo_def = "miCampo_def"
                    miCampo_def.nro_campo_tipo = 3
                    miCampo_def.filtroXML = "<criterio><select vista='campos_def'><campos> distinct campo_def as id, descripcion as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>"
                    Response.Write(miCampo_def.get_html_input())
                %>
            </td>
        </tr>
        
        <tr>
            <td>
                Tipo 1
            </td>
            <td style="">
                <%= nvFW.nvCampo_def.get_html_input("nro_login3", enDB:=False, filtroXML:="<criterio><select vista='campos_def'><campos> distinct campo_def as id, descripcion as [campo] </campos><orden>[campo]</orden><filtro></filtro></select></criterio>")%>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 1 - Comgrupo
            </td>
            <td>
                <%= nvFW.nvCampo_def.get_html_input("nro_com_grupo")%>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 1
            </td>
            <td>
                <%= nvFW.nvCampo_def.get_html_input("nro_com_tipo")%>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 1
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miCampo',{ nro_campo_tipo: 1,enDB: false,filtroXML: nvFW.pageContents.filtroXMLmiCampo})
                    
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 100 - Entero
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miEntero',{ nro_campo_tipo: 100,enDB: false })
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 101 - Entero + giones y comas
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miMirango',{ nro_campo_tipo: 101,enDB: false })
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 102 - Decimales
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miDecimal',{ nro_campo_tipo: 102,enDB: false })
                </script>
            </td>
        </tr>
        <tr>
            <td>
                Tipo 103 - Fechas
            </td>
            <td>
                <script type="text/javascript">
                    campos_defs.add('miFecha',{ nro_campo_tipo: 103,enDB: false })
                </script>
                <input type="button" value="valor" onclick="nvFW.alert(campos_defs.value('miFecha'))" />
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
                    campos_defs.add('miTexto',{ nro_campo_tipo: 104,enDB: false })
                </script>
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
    <input type="text" id="input_txt" />
    <input type="hidden" id="input_hidden" />
    <input type="button" id="btn" onclick="btn_onclick()"  value="Limpiar campo_def"/>
    <input type="button" id="btn2" onclick="btn2_onclick()"  value="Asignar valor"/>
    <input type="button" id="btn3" onclick="btn3_onclick()"  value="Asignar valor tipo 3"/>
    <input type="button" id="btn4" onclick="removeAll()"  value="Borrar combo"/>

    

    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="/admin/enBlanco.htm"></iframe>
</body>
</html>
