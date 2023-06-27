<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Me.contents("filtro_VerArchivos_estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VerArchivos_estados'><campos>*</campos><filtro></filtro><orden>momento DESC</orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Documentos</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js" ></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js" ></script> 
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var nro_credito
        var nro_def_detalle

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Aceptar";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return btnAceptar_onclick()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')

        var winActualizar

        function parseFecha(strFecha) {
            var a = strFecha.replace('-', '/').replace('-', '/').replace('T', ' ') + '.'
            a = a.substr(0, a.indexOf('.'))
            var fe = new Date(Date.parse(a))
            return fe
        }

        function FechaToSTR(cadena) {
            var objFecha = parseFecha(cadena)
            if (isNaN(objFecha.getDate()))
                return ''
            var dia
            var mes
            var anio
            if (objFecha.getDate() < 10)
                dia = '0' + objFecha.getDate().toString()
            else
                dia = objFecha.getDate().toString()

            if ((objFecha.getMonth() + 1) < 10)
                mes = '0' + (objFecha.getMonth() + 1).toString()
            else
                mes = (objFecha.getMonth() + 1).toString()
            anio = objFecha.getFullYear()
            var modo = 1
            if (modo == 1)
                return dia + '/' + mes + '/' + anio + " " + objFecha.getHours() + ":" + objFecha.getMinutes() + ":" + objFecha.getSeconds()
            else
                return mes + '/' + dia + '/' + anio
        }

        function window_onload() {
            //cargar archivos  
            var Parametros = window.top.documento.returnValue
            id_tipo = Parametros["id_tipo"]
            nro_archivo_id_tipo = Parametros["nro_archivo_id_tipo"]
            nro_def_detalle = Parametros["nro_def_detalle"]

            debugger
            var strCriterio = nvFW.pageContents.filtro_VerArchivos_estados
            var rs = new tRS();
            rs.open(strCriterio, "", "<nro_def_detalle type='igual'>" + nro_def_detalle + "</nro_def_detalle><id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_id_tipo type='igual'>" + nro_archivo_id_tipo + "</nro_archivo_id_tipo>")
            var strHTML = '<table class="tb1" style="width:100%"><tr class="tbLabel0"><td>Documento</td><td style="width:300px">Archivo</td><td style="width:300px">Fecha</td><td style="width:300px">Operador</td><td style="width:300px">Estado</td></tr>'
            while (!rs.eof()) {
                strHTML += '<tr><td width="40%"><a target="_blank" href="/fw/get_file.aspx?nro_archivo=' + rs.getdata('nro_archivo') + '">' + rs.getdata('Descripcion') + ' - ' + rs.getdata('nro_archivo') + '</a></td>'
                strHTML += '<td><a target="_blank" href="/fw/get_file.aspx?nro_archivo=' + rs.getdata('nro_archivo') + '">' + rs.getdata('path') + '</a></td>'
                strHTML += '<td>' + FechaToSTR(rs.getdata('momento')) + '</td><td>' + rs.getdata('nombre_operador') + '</td><td>' + rs.getdata('estado') + '</td></tr>'

                //vListButton.MostrarListButton()
                rs.movenext()
            }
            strHTML += '</table>'
            $('tbDocs').insert({
                top: strHTML
            })
        }

        function btnAceptar_onclick() {
            document.all.divAceptar.innerHTML = ''
            formDocs.submit()


            // actualizar_start()
        }



        function actualizar_start() {
            winActualizar = Dialog.info('Actualizando', {
                className: "alphacube",
                width: 250,
                contentType: "text/plain",
                height: 50,
                showProgress: true
            });
        }



        function window_onresize() {
            try {
                var dif = Prototype.Browser.IE ? 5 : 2
                body_height = $$('body')[0].getHeight()
                pie_height = $('tbPie').getHeight()
                divDocs_height = $('tbDocs').getHeight()
                //var height = divDocs_height + pie_height + 50
                var height = divDocs_height + pie_height

                window.top.documento.setSize(820, height)
                if (divDocs_height >= 200)
                    var top = window.top.documento.element.offsetTop - divDocs_height + 250
                else
                    var top = window.top.documento.element.offsetTop - divDocs_height + 150
                var left = window.top.documento.element.offsetLeft - 50
                window.top.documento.setLocation(top, left)
            } catch (e) { }

        }

    </script>

</head>
<body  onload="return window_onload()" style="width:100%;height:100%; overflow:auto">
   
        <div id='tbDocs' style="width:100%"></div>
        <table id='tbPie' width="100%" cellspacing="0" cellpadding="0">
            <tr style="HEIGHT: 8px !Important">
                <td>
                </td>
            </tr>
            <tr>
                <td style="width: 100%">
                    <div id="divAceptar">
                    </div>
                </td>
            </tr>
            <tr style="HEIGHT: 8px !Important">
                <td>
                </td>
            </tr>
        </table>
       
   
    <iframe name="frmEnviar" id="frmEnviar" src="enBlanco.htm" style="Display: none"></iframe>
</body>
</html>
