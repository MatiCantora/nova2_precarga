<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim nro_archivo = obtenerValor("nro_archivo", "")
    Dim nro_registro = obtenerValor("nro_registro", "")

    Dim estado = obtenerValor("estado", "")

    If (nro_archivo <> "" And estado = "2") Then

        DBExecute("update archivos set nro_archivo_estado = 2 where nro_archivo = " + nro_archivo)
        If (nro_registro <> "") Then
            Dim query = "update com_registro set nro_com_estado = 3 where nro_registro =" + nro_registro
            DBExecute(query)
        End If

    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Editar Estado</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var nro_archivo

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

        var wine = nvFW.getMyWindow();

        function window_onload() {
            var Parametros = wine.options.userData.retorno
            nro_archivo = Parametros["nro_archivo"]
            vListButton.MostrarListButton()
            $('nro_archivo').value = nro_archivo
            $('nro_registro').value = Parametros["nro_registro"]
            $('titulo').update(Parametros["titulo"])
        }

        function btnAceptar_onclick() {
            $('frm1').submit()
            var win = nvFW.getMyWindow()
            win.options.userData = {retorno:"refresh"}
            win.close()
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

    <form method="post" id="frm1">
        <input type="hidden" name="nro_archivo" id="nro_archivo" value="<%= nro_archivo %>" />
        <input type="hidden" name="nro_registro" id="nro_registro" value="<%= nro_registro %>" />

        <table style="width: 100%" class='tb1'>
            <tr class="tbLabel">
                <td>Documento</td>
                <td>Estado</td>
            </tr>

            <tr>
                <td style="width: 80%"><span id="titulo"></span></td>
                <td style="width: 20%">
                    <select name="estado" style="width: 100%">
                        <option value="1">Activo</option>
                        <option value="2">Anulado</option>
                    </select></td>
            </tr>
        </table>
        <br>
        <table style="width: 100%">

            <tr>
                <td colspan="2">
                    <div id="divAceptar">
                    </div>
                </td>
            </tr>
        </table>

    </form>

    <iframe name="frmEnviar" id="frmEnviar" src="enBlanco.htm" style="display: none"></iframe>
</body>
</html>
