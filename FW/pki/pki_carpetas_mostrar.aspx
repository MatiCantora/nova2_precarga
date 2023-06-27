<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Response.Expires = 0
   
    Dim id_carpeta As String = nvUtiles.obtenerValor("id_carpeta", "")
    Me.contents("id_carpeta") = id_carpeta
    
    Me.contents("ver_carpetas") = nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI_carpetas'><campos>*</campos><orden></orden><filtro><id_carpeta type='igual'>%id_carpeta%</id_carpeta></filtro></select></criterio>")
    Me.contents("ver_certificados_carpeta") = nvXMLSQL.encXMLSQL("<criterio><select vista='verPKI_certificados_carpetas'><campos>idcert, cert_name</campos><orden></orden><filtro><id_carpeta type='igual'>%id_carpeta%</id_carpeta></filtro></select></criterio>")
%>
<html>
<head>
    <title>PKI Carpetas ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        var idpki
        var id_carpeta

        function window_onload() {

            id_carpeta = nvFW.pageContents.id_carpeta
            if (id_carpeta != '')
                pki_carpeta_cargar(id_carpeta)
            window_onresize()
        }

        function pki_carpeta_cargar(id_carpeta) {
            $('div_pki_carpetas').innerHTML = ''
            var strHTML = ''
            var rs = new tRS()
            //rs.open("<criterio><select vista='verPKI_carpetas'><campos>*</campos><orden></orden><filtro><id_carpeta type='igual'>" + id_carpeta + "</id_carpeta></filtro></select></criterio>")
            var params = "<criterio><params id_carpeta= '" + id_carpeta + "' /></criterio>"
            rs.open(nvFW.pageContents.ver_carpetas, '', '', '', params);
      

            if (!rs.eof()) {
                strHTML = '<table class="tb1" width="100%"><tr class="tbLabel"><td style="width:100%"><b>PKI</b></td></tr>'
                strHTML += '<tr><td><b>' + rs.getdata('IDPKI') + ' - ' + rs.getdata('PKI') + '</b></td></tr></table>'
                strHTML += '<table class="tb1" width="100%"><tr class="tbLabel"><td style="width:50%"><b>Path</b></td><td style="width:50%"><b>Nombre</b></td></tr>'
                strHTML += '<tr><td>' + rs.getdata('carpeta_path') + '</td><td>' + rs.getdata('carpeta_nombre') + '</td></tr></table>'
                strHTML += '<table class="tb1"><tr class="tbLabel"><td style="width:15%"><b>Confiable</b></td><td style="width:15%"><b>My</b></td></tr>'
                var esconfiable = (rs.getdata('esConfiable') == 'True') ? 'Si' : 'No'
                strHTML += '<tr><td style="text-align:center">' + esconfiable + '</td>'
                var esmy = (rs.getdata('esMy') == 'True') ? 'Si' : 'No'
                strHTML += '<td style="text-align:center">' + esmy + '</td>'
                strHTML += '</tr></table>'
                idpki = rs.getdata('IDPKI')
            }
            $('div_pki_carpetas').insert({ bottom: strHTML })
            certificados_cargar(id_carpeta)
        }

        function certificados_cargar(id_carpeta) {
            $('div_certificados').innerHTML = ''
            var strHTML = ''
            strHTML = '<table class="tb1" style="width:100%"><tr><td class="Tit1" style="width:10%"><b>ID</b></td><td class="Tit1" style="width:60%"><b>Certificado</b></td><td class="Tit1"><b>Editar</b></td><td class="Tit1"><b>Eliminar</b></td></tr>'
            var rs = new tRS()
            var params = "<criterio><params id_carpeta= '" + id_carpeta + "' /></criterio>"
            rs.open(nvFW.pageContents.ver_certificados_carpeta, '', '', '', params);
            while (!rs.eof()) {
                strHTML += '<tr><td>' + rs.getdata('idcert') + '</td><td>' + rs.getdata('cert_name') + '</td><td><img title="Editar certificado" src="/fw/image/icons/editar.png" style="cursor:pointer" onclick="cert_abm(' + rs.getdata('idcert') + ')"/></td><td><img title="Desvincular certificado" src="/fw/image/icons/eliminar.png" style="cursor:pointer" onclick="carp_desvincular_cert(' + rs.getdata('idcert') + ',' + id_carpeta + ')"/></td></tr>'
                rs.movenext()
            }
            strHTML += '</table>'
            $('div_certificados').insert({ bottom: strHTML })
        }

        var win_cert

        var respuesta = {}

        function cert_abm(idcert) {
            respuesta = {}
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_cert = nvFW.createWindow({ className: 'alphacube',
                url: 'pki_certificados.aspx?idcert=' + idcert + '&id_carpeta=' + id_carpeta,
                title: '<b>ABM Certificado</b>',
                minimizable: true,
                maximizable: true,
                draggable: true,
                width: 500,
                height: 300,
                resizable: true,
                onClose: win_cert_return
            });
            win_cert.options.userData = { respuesta: respuesta }
            win_cert.showCenter(true)
            win_cert.maximize()
        }

        function win_cert_return() {

            var retorno = win_cert.options.userData.respuesta
            if (retorno['numError'] != undefined) {
                if (retorno['numError'] != '0' && retorno['numError'] != '') {
                    var mensaje = 'El certificado no se pudo guardar.<br>' + retorno['numError'] + ' - ' + retorno['mensaje']
                    alert(mensaje)
                    return
                }
                else
                    certificados_cargar(id_carpeta)
            }
        }

        var win_carpeta

        function carpeta_abm() {
   
            var w = window.top.nvFW != undefined ? window.top.nvFW : nvFW
            win_carpeta = nvFW.createWindow({ className: 'alphacube',
                url: 'pki_carpetas_ABM.aspx?id_carpeta=' + id_carpeta + '&idpki=' + idpki,
                title: '<b>ABM Carpeta</b>',
                minimizable: false,
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

        function win_carpeta_return() {
            var id_carpeta = win_carpeta.options.userData.id_carpeta
            if (id_carpeta != 0) {
                parent.actualizar_tree()
                pki_carpeta_cargar(id_carpeta)
            }
        }

        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                var body_height = $$('body')[0].getHeight()
                var elem1 = $('divMenuABM_carpetas_pki').getHeight()
                var elem2 = $('div_pki_carpetas').getHeight()
                var elem3 = $('divMenuCert').getHeight()
                $('div_certificados').setStyle({ height: body_height - elem1 - elem2 - elem3 - dif + 'px', overflow: 'auto' })
            }
            catch (e) { }
        }

        function carp_desvincular_cert(idcert) {


            idcert = -1 * idcert
            formEliminarCert.modo.value = "GUARDAR"
            formEliminarCert.id_carpeta.value = id_carpeta
            formEliminarCert.idcert.value = idcert
            formEliminarCert.idpki.value = idpki

            Dialog.confirm('¿Desea desvincular el certificado de la carpeta?',
                {
                    width: 350, className: "alphacube",
                    onShow: function () {
                    },
                    onOk: function (win) {

                        formEliminarCert.submit()
                        win.close()
                    },
                    onCancel: function (win) { win.close() },
                    okLabel: 'Aceptar',
                    cancelLabel: 'Cancelar'
                });
        }



        function hiddenIframe_load() {
            try {
                nvFW.bloqueo_desactivar($$('body')[0], "bloqueo")
                var strXML = $('iframeCargar').contentWindow.error_xml.value
                var oXML = new tXML()
                oXML.loadXML(strXML)
                nroError = oXML.selectSingleNode('error_mensajes/error_mensaje/@numError').nodeValue
                mensaje = XMLText(oXML.selectSingleNode('error_mensajes/error_mensaje/mensaje'))
                if (nroError > 0) {
                    alert(mensaje)
                    return
                }
                else {
                    pki_carpeta_cargar(id_carpeta)
                }
            }
            catch (e) {
            }
        }
                     

      
    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <form action="pki_certificados.aspx" method="post" name="formEliminarCert" id="formEliminarCert"
    target="iframeCargar">
    <input type="hidden" id='modo' name='modo' value='G' />
    <input type="hidden" id='id_carpeta' name='id_carpeta' />
    <input type="hidden" id='idcert' name='idcert' />
    <input type="hidden" id='idpki' name='idpki' />
    </form>
    <div id="divMenuABM_carpetas_pki">
    </div>
    <script type="text/javascript" language="javascript">
        var vMenuABM_carpetas_pki = new tMenu('divMenuABM_carpetas_pki', 'vMenuABM_carpetas_pki');
        Menus["vMenuABM_carpetas_pki"] = vMenuABM_carpetas_pki
        Menus["vMenuABM_carpetas_pki"].alineacion = 'centro';
        Menus["vMenuABM_carpetas_pki"].estilo = 'A';
        Menus["vMenuABM_carpetas_pki"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Carpeta</Desc></MenuItem>")
        Menus["vMenuABM_carpetas_pki"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>carpeta_abm()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuABM_carpetas_pki"].loadImage("editar", "/fw/image/icons/editar.png")
        vMenuABM_carpetas_pki.MostrarMenu()
    </script>
    <div id="div_pki_carpetas" style="margin: 0px; padding: 0px">
    </div>
    <div id="divMenuCert">
    </div>
    <script type="text/javascript" language="javascript">
        var vMenuCert = new tMenu('divMenuCert', 'vMenuCert');
        Menus["vMenuCert"] = vMenuCert
        Menus["vMenuCert"].alineacion = 'centro';
        Menus["vMenuCert"].estilo = 'A';
        Menus["vMenuCert"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Certificados</Desc></MenuItem>")
        Menus["vMenuCert"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nuevo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>cert_abm(0)</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenuCert"].loadImage("nuevo", "/fw/image/icons/nueva.png")
        vMenuCert.MostrarMenu()
    </script>
    <div id="div_certificados" style="margin: 0px; padding: 0px">
    </div>
    <iframe onload="hiddenIframe_load()" name="iframeCargar" id="iframeCargar" style="display: none">
    </iframe>
</body>
</html>
