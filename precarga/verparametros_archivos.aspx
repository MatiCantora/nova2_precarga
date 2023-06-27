<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%
    Me.contents("filtro_archivos_parametros") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_parametros'><campos>*</campos><filtro></filtro><orden>orden ASC</orden></select></criterio>")
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Parámetros</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var nro_credito
        var nro_def_detalle


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
        var wine = nvFW.getMyWindow();

        function window_onload() {
            //cargar archivos  
            var Parametros = wine.options.userData.retorno
            nro_credito = Parametros["nro_credito"]
            nro_def_detalle = Parametros["nro_def_detalle"]

            var strCriterio = nvFW.pageContents.filtro_archivos_parametros
            var rs = new tRS();
            rs.open(strCriterio, "", "<nro_archivo_estado type='igual'>1</nro_archivo_estado><nro_def_detalle type='igual'>" + nro_def_detalle + "</nro_def_detalle><nro_credito type='igual'>" + nro_credito + "</nro_credito>", "", "")
            var strHTML = '<table class="tb1" style="width:100%"><tr class="tbLabel0"><td>Par&aacute;metro</td><td>Valor</td></tr>'
            while (!rs.eof()) {
                strHTML += '<tr><td title="' + rs.getdata('parametro') + '"><strong>' + rs.getdata('etiqueta') + '</strong></td><td>' + rs.getdata('parametro_valor') + '</td></tr>'
                rs.movenext()
            }
            strHTML += '</table>'
            $('tbDocs').insert({ top: strHTML })
        }

        function btnAceptar_onclick() {
            document.all.divAceptar.innerHTML = ''
            formDocs.submit()


            // actualizar_start()
        }



        function actualizar_start() {
            winActualizar = Dialog.info('Actualizando', {
                className: "alphacube", width: 250,
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
            }
            catch (e) { }

        }


    </script>

</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto">

    <div id='tbDocs' style="width: 100%"></div>
    <table id='tbPie' width="100%" cellspacing="0" cellpadding="0">
        <tr style="height: 8px !Important">
            <td></td>
        </tr>
        <tr>
            <td style="width: 100%">
                <div id="divAceptar">
                </div>
            </td>
        </tr>
        <tr style="height: 8px !Important">
            <td></td>
        </tr>
    </table>


    <iframe name="frmEnviar" id="frmEnviar" src="enBlanco.htm" style="display: none"></iframe>
</body>
</html>
