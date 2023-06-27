<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim id_tipo As Integer = nvFW.nvUtiles.obtenerValor("id_tipo", 0)
    Dim nro_id_tipo As Integer = nvFW.nvUtiles.obtenerValor("nro_id_tipo", 1)
    Dim nro_contacto_grupo As String = nvFW.nvUtiles.obtenerValor("nro_contacto_grupo", "")
    Dim indice As String = nvUtiles.obtenerValor("indice", "")
    Dim id_contact As String = nvUtiles.obtenerValor("id_contact", "")

    Me.contents("id_tipo") = id_tipo
    Me.contents("nro_id_tipo") = nro_id_tipo
    Me.contents("nro_contacto_grupo") = nro_contacto_grupo
    Me.contents("id_contact") = id_contact
    Me.contents("indice") = indice

%>
<html>
<head>
    <title>ABM Contactos</title>
    <meta name="GENERATOR" content="Microsoft Visual Studio 6.0" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style>
        .footer-pie {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
        }
    </style>

    <style type="text/css">
        .pac-container.pac-logo::after {
            content: none;
        }
    </style>

    <%--<script type="text/javascript" src="/FW/script/swfobject.js"></script>--%>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>


    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var id_tipo = nvFW.pageContents.id_tipo;
        var nro_id_tipo = nvFW.pageContents.nro_id_tipo;
        var nro_contacto_grupo = nvFW.pageContents.nro_contacto_grupo;
        var indice = nvFW.pageContents.indice;
        var id_contact = nvFW.pageContents.id_contact;
        

        function window_onload() {
            campos_defs.set_value('nro_contacto_grupo',nro_contacto_grupo)
            //si indice == -1 es un alta
            campos_defs.habilitar('nro_contacto_grupo',indice == -1)

            window_onresize()
        }


        function window_onresize() {
            $('iframe_abm').setStyle({ height: $$('body')[0].getHeight() - $('tbCdef').getHeight() + 'px' })
        }


        function cargar_abm() {
            if (campos_defs.get_value('nro_contacto_grupo') != '') {
                var index = campos_defs.items["nro_contacto_grupo"].input_select.selectedIndex - 1
                var nombre_asp = campos_defs.items["nro_contacto_grupo"].rs.data[index].nombre_asp
                $('iframe_abm').src = typeof nombre_asp != 'undefined' ? nombre_asp + '?id_tipo=' + id_tipo + '&nro_id_tipo=' + nro_id_tipo + '&indice=' + indice + '&id_contact=' + id_contact : '' //asp generico
            }
        }


    </script>
</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: hidden">
    <table id="tbCdef" class="tb1">
        <tr>
            <td class="tit1">Tipo de contacto</td>
            <td>
                <script>
                    campos_defs.add('nro_contacto_grupo', {
                        onchange: cargar_abm
                    })
                </script>
            </td>
        </tr>
    </table>
    <iframe name="iframe_abm" id="iframe_abm" style="width: 100%; height: 100%" src="/FW/enBlanco.htm" frameborder="0"></iframe>
</body>
</html>
