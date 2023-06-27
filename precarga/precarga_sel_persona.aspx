<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>
<% 
    Me.contents.Add("personas", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPersonas'><campos>Documento,tipo_docu,sexo,nro_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad,cod_prov</campos><orden></orden><filtro><cuit type='igual'>'%cuit%'</cuit></filtro></select></criterio>"))

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <title>Precarga - Seleccionar Vendedor</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="/precarga/css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico"/>
    <script type="text/javascript" language='javascript' src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js" ></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

    var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

    var win = nvFW.getMyWindow()
    
    function window_onload() {
        //vListButtons.MostrarListButton()
        //window_onresize()
        var param = win.options.userData.datos_persona
        var filtro = ''
        var strHTML = ''
        $('divSelPersonas').innerText = ''
        //if (param['nro_docu'] == '')
        //    {
        //    strHTML = "<table class='tb1' style='width:100%'><tr><td colspan='7'>Se encontraron más de una persona con el nro de CUIT: <b>" + param['cuit'] + "</b>. Seleccione la que corresponda.<br></td></tr></table>"
        //    filtro = "<cuit type='igual'>'" + param['cuit'] + "'</cuit>"
        //    }
        //else
        //    {
        //    strHTML = "<table class='tb1' style='width:100%'><tr><td colspan='7'>No se encontraron datos con el CUIT: <b>" + param['cuit'] + "</b>. Seleccione alguna de estas personas en caso de ser la correcta.<br></td></tr></table>"
        //    filtro = "<nro_docu type='igual'>'" + param['nro_docu'] + "'</nro_docu>"
        //    }
            
        strHTML = "<table class='tb1'><tr><td colspan='7'>Se encontraron más de una persona con el nro de CUIT: <b>" + param['cuit'] + "</b>. Seleccione la que corresponda.<br></td></tr></table>"
        strHTML += "<table class='tb1 highlightEven highlightTROver'><tr><td class='Tit1'></td><td class='Tit1'>Doc.</td><td class='Tit1'>Sexo</td><td class='Tit1'>Apellido y Nombres</td><td class='Tit1'>Fecha Nac.</td></tr>"
        var rs = new tRS();
        //rs.open("<criterio><select vista='verPersonas'><campos>Documento,tipo_docu,sexo,nro_docu,strNombreCompleto,cuit,convert(varchar,fe_naci,103) as fe_naci,edad</campos><orden></orden><filtro>" + filtro + "</filtro></select></criterio>")
        rs.open({ filtroXML: nvFW.pageContents["personas"], params: "<criterio><params cuit='" + param['cuit'] + "' /></criterio>" })
        while (!rs.eof()) {
            var nro_docu = rs.getdata('nro_docu')
            var tipo_docu = rs.getdata('tipo_docu')
            var sexo = rs.getdata('sexo')
            var nombre = rs.getdata('strNombreCompleto')
            var fe_naci = rs.getdata('fe_naci')
            var edad = rs.getdata('edad')
            var cod_prov = rs.getdata('cod_prov')
            strHTML += '<tr onclick="return Persona_onclick(' + nro_docu + ',' + tipo_docu + ',\'' + sexo + '\',\'' + nombre + '\',\'' + fe_naci + '\',\'' + edad + '\',\'' + cod_prov + '\')"><td style="cursor:pointer;text-align:center" onclick="return Persona_onclick(' + nro_docu + ',' + tipo_docu + ',\'' + sexo + '\',\'' + nombre + '\',\'' + fe_naci + '\',\'' + edad + '\',\'' + cod_prov + '\')" title="Seleccionar persona"><img class="img_button_sel" src="/precarga/image/seleccionar_32.png"/><td>' + rs.getdata('Documento') + ' - ' + rs.getdata('nro_docu') + '</td><td>' + rs.getdata('sexo') + '</td>'
            strHTML += "<td>" + rs.getdata('strNombreCompleto') + "</td><td>" + rs.getdata('fe_naci') + "</td></tr>"
            rs.movenext()
        }
        strHTML += "</table>"
        $('divSelPersonas').insert({ bottom: strHTML })
    }

    function Persona_onclick(nro_docu,tipo_docu,sexo,nombre,fe_naci,edad,cod_prov) {        
      var res = {}
      res["nro_docu"] = nro_docu
      res["tipo_docu"] = tipo_docu
      res["sexo"] = sexo      
      res["nombre"] = nombre
      res["fe_naci"] = fe_naci
      res["edad"] = edad
      res["cod_prov"] = cod_prov  
      win.options.userData = { res: res }
      win.close()
    }

    function window_onresize() {
          /*try {
              var dif = Prototype.Browser.IE ? 5 : 2
              body_height = $$('body')[0].getHeight()
              cab_height = $('tbFiltro').getHeight()

              $('iframe_vendedores').setStyle({ 'height': body_height - cab_height - dif })
          }
          catch (e) { }*/
    }

</script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="height:100%; overflow:auto" >
<div id="divSelPersonas"></div>
     
</body>
</html>
