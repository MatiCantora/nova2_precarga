<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    Dim idpki As String = nvUtiles.obtenerValor("idpki", "0")
    Me.contents("consulta_ver_pki") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI'><campos>*</campos><orden></orden><filtro><IDPKI type='igual'>'%IDPKI%'</IDPKI></filtro></select></criterio>")
    Me.contents("ver_certificado_extensiones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='PKI_Certificados_extensiones'><campos>*</campos><orden></orden><filtro><idcert type='igual'>%idcert%</idcert></filtro></select></criterio>")
    
 %>
<html>
<head>
    <title>PKI ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <% = Me.getHeadInit()%>
    
    <script type="text/javascript" >
        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        function window_onload() {
            
            var idpki = $('idpki').value 
            if (idpki != '')
                pki_cargar(idpki)
                        
            window_onresize()
        }
        
        var win_carpeta
        
        function carpeta_abm()
        {
        var id_carpeta = 0
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_carpeta = nvFW.createWindow({ className: 'alphacube',
        url: '/fw/pki/pki_carpetas_ABM.aspx?modo=VA&id_carpeta=0&idpki=' + $('idpki').value,
        title: '<b>ABM Carpeta</b>',
            minimizable: true,
            maximizable: false,
            draggable: true,
            width: 500,
            height: 180,
            resizable: false,
            onClose: win_carpeta_return
        });
        win_carpeta.options.userData = { id_carpeta: id_carpeta }
        win_carpeta.showCenter(true)
        }
        
        function win_carpeta_return()
        {
        var id_carpeta = win_carpeta.options.userData.id_carpeta
        if (id_carpeta != 0)
            parent.actualizar_tree()
        }
        
        function pki_cargar(idpki)
        {
        $('div_pki').innerHTML = ''
        var strHTML = ''
        var rs = new tRS()
        var params = "<criterio><params IDPKI= '" + idpki + "' /></criterio>"
        rs.open(nvFW.pageContents.consulta_ver_pki, "", "", "", params);
        if (!rs.eof())
           {
            strHTML = '<table class="tb1" width="100%"><tr class="tbLabel"><td style="width:20%"><b>IDPKI</b></td><td style="width:30%"><b>PKI</b></td><td>Root es confiable</td><td>TSA URL</td></tr>'
            strHTML += '<tr><td>' + rs.getdata('IDPKI') + '</td><td>' + rs.getdata('PKI') + '</td><td>' + (rs.getdata('esConfiable') == 'True' ? 'SI' : 'NO') + '</td><td>' + rs.getdata('urlTsa') + '</td></tr></table>'
            strHTML += '<table class="tb1">'
            strHTML += '<tr class="tbLabel" ><td style="width:100%"><b>Comentario</b></td></tr>'
            strHTML += '<tr><td style="width:100%">' + rs.getdata('PKI_Comentario') + '</td></tr>'
            strHTML += '</table>'
            strHTML += '<table class="tb1">'
            //strHTML += '<tr class="tbLabel" ><td style="width:100%" colspan="4"><b>AC Raiz</b></td></tr>'
            //strHTML += '<tr><td style="width:100%" colspan="4">' + rs.getdata('ACRaiz') + " - " + rs.getdata('cert_name') + '</td></tr>'
            strHTML += '<tr class="tbLabel" ><td style="width:100%" colspan="4"><b>Info Certificado</b></td></tr>'
            strHTML += '<tr><td class="Tit1" style="width:25%"><b>Válido desde:</b></td><td style="width:25%">' + FechaToSTR(parseFecha(rs.getdata('cert_notbefore'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notbefore'))) + '</td>'
            strHTML += '<td class="Tit1" style="width:25%"><b>Válido hasta:</b></td><td>' + FechaToSTR(parseFecha(rs.getdata('cert_notafter'))) + ' ' + HoraToSTR(parseFecha(rs.getdata('cert_notafter'))) + '</td></tr>'
            strHTML += '<td class="Tit1" style="width:25%"><b>Versión:</b></td><td>' + rs.getdata('cert_version') + '</td></tr>'
            strHTML += '<td class="Tit1" style="width:25%"><b>Issuer:</b></td><td colspan="3">' + rs.getdata('cert_issuer') + '</td></tr>'
            strHTML += '<td class="Tit1" style="width:25%"><b>Subject:</b></td><td colspan="3">' + rs.getdata('cert_subject') + '</td></tr>'
            strHTML += '</table>'
            strHTML += '<table class="tb1" width="100%">'
            strHTML += '<tr class="tbLabel"><td style="width:40%"><b>Descripción</b></td><td><b>Valor</b></td></tr>'
            var rsE = new tRS()

            var rsE = new tRS();
            var parametros = "<criterio><params idcert= '" + rs.getdata('ACRaiz') + "' /></criterio>"
            rsE.open(nvFW.pageContents.ver_certificado_extensiones, '', '', '', parametros);
           
            while (!rsE.eof())
             {
                strHTML += '<tr><td class="Tit1" style="width:40%"><b>' + rsE.getdata('descripcion') + '</b></td><td>' + rsE.getdata('valor') + '</td></tr>'
                rsE.movenext()
            }
            strHTML += '</table>'
           }
        $('div_pki').insert({ bottom: strHTML })
        }


        function pki_extensiones_cargar(idcert) {

            var strHTML = ''
            var rs = new tRS();
            var parametros = "<criterio><params idcert= '" + idcert + "' /></criterio>"
            rs.open(nvFW.pageContents.ver_certificado_extensiones, '', '', '', parametros);

            if (!rs.eof()) {
                strHTML = '<table class="tb1" width="100%">'
                strHTML = '<tr class="tbLabel"><td style="width:40%"><b>Descrpción</b></td><td><b>Valor</b></td></tr>'
                strHTML += '<td class="Tit1" style="width:40%"><b>' + +rs.getdata('descripcion') +'</b></td><td>' + rs.getdata('valor') + '</td></tr>'
                strHTML += '</table>'
            }
            return strHTML
        }


        var win_pki       
        function pki_abm()
        {
        var idpki = $('idpki').value
        var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
        win_pki = nvFW.createWindow({ className: 'alphacube',
        url: '/fw/pki/pki_ABM.aspx?modo=VA&idpki=' + $('idpki').value,
        title: '<b>ABM PKI</b>',
            minimizable: false,
            maximizable: false,
            draggable: true,
            width: 500,
            height: 250,
            resizable: true,
            onClose: win_pki_return
        });
        win_pki.options.userData = { idpki: idpki }
        win_pki.showCenter(true)
        }

        function win_pki_return()
        {
        var idpki = win_pki.options.userData.idpki
        if (idpki != 0)
            {
            parent.actualizar_tree()
            pki_cargar(idpki)
            }
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var cab_height = $('divMenuABM_pki').getHeight()
                $('div_pki').setStyle({ height: body_height - cab_height - dif + 'px' })
            }
            catch (e) { }
        }      

      
</script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;height: 100%; overflow: hidden">
  <form action="pki_ABM.aspx" method="post" name="form1" style="width: 100%;height: 100%; overflow: hidden">
      <input type="hidden" id='idpki' value=<%=idpki %> />
      <div id="divMenuABM_pki"></div>
      <script type="text/javascript">
        var vMenuABM_pki = new tMenu('divMenuABM_pki', 'vMenuABM_pki');
        Menus["vMenuABM_pki"] = vMenuABM_pki
        Menus["vMenuABM_pki"].alineacion = 'centro';
        Menus["vMenuABM_pki"].estilo = 'A';
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>PKI</Desc></MenuItem>")
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva Carpeta</Desc><Acciones><Ejecutar Tipo='script'><Codigo>carpeta_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar PKI</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pki_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_pki"].loadImage("editar", "/fw/image/icons/editar.png")
        Menus["vMenuABM_pki"].loadImage("nuevo", "/fw/image/icons/nueva.png")
        vMenuABM_pki.MostrarMenu()
      </script>
      <div id="div_pki"  style="margin: 0px; padding: 0px;overflow:auto"></div>         
</form>
</body>
</html>