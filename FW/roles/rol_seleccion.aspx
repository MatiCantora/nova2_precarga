<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%

    Dim id_ventana As String = nvFW.nvUtiles.obtenerValor("id_ventana", "")
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
    Dim nro_entidad As String = nvFW.nvUtiles.obtenerValor("nro_entidad", "")

    Me.contents("Entidades_filtroXML") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Entidades'><campos>nro_entidad,Razon_social</campos><orden></orden><filtro></filtro></select></criterio>")


%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Rol Seleccion</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tcampo_def.js" ></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var alert = function(msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var entidades
        var cuit = "<%=cuit %>"
        var nro_entidad = "<%= nro_entidad %>"


        function window_onload() {
            buscar()
        }

        function buscar() {

            entidades = new Array()
            k = 0
            if (cuit != '') {

                var rs = new tRS();
                var criterio = "<cuit type='like'>" + cuit + "</cuit>"
                rs.open(nvFW.pageContents.Entidades_filtroXML, "", criterio, "", "")
                while (!rs.eof()) {
                    vacio = new Array()
                    vacio['nro_entidad'] = rs.getdata('nro_entidad')
                    vacio['Razon_social'] = rs.getdata('Razon_social')
                    entidades[k] = vacio
                    k++
                    rs.movenext()
                }
            }
            entidades_dibujar()
        }

        function entidades_dibujar() {
            $('divEntidades').innerHTML = ''
            var strHTML = "<table id='tbEntidades' class='tb1' style='width:100%'>"

            strHTML += "<tr>"
            strHTML += "<td class='Tit1' style='width:5%;text-align:center'></td>"
            strHTML += "<td class='Tit1' style='width:15%;text-align:center'>ID</td>"
            strHTML += "<td class='Tit1' style='width:80%;text-align:center'>Entidad</td>"
            strHTML += "</tr>"

            entidades.each(function(arreglo, i) {

                agregar = '<img alt="" title="Agregar" src="../../fw/image/icons/agregar.png" style="cursor:pointer;cursor:hand" value="' + arreglo['nro_entidad'] + '" onclick="agregar_entidad(this)" />'
                strHTML += "<tr>"
                strHTML += "<td style='width:5%;text-align:center'>" + agregar + "</td>"
                strHTML += "<td style='width:15%;text-align:center'>" + arreglo['nro_entidad'] + "</td>"
                strHTML += "<td style='width:80%;text-align:left'>" + arreglo['Razon_social'] + "</td>"
                strHTML += "</tr>"
            });

            strHTML += "</table>"
            $('divEntidades').insert({ top: strHTML })
        }


        function agregar_entidad(_this) {
            nro_entidad = _this.value
            var win = $('id_ventana').value == '' ? undefined : ObtenerVentana($('id_ventana').value)

            if ((win != undefined) && (nro_entidad != '')) {
                win.nro_entidad = nro_entidad
                window.parent.win_rol_seleccion.close()
            }
        }
        
        
    </script>

</head>
<body onload="return window_onload()" style='width: 100%; height: 100%; overflow: hidden'>
    <form name="frmFiltro_tablas" action="" method="post" target="frmEnviar" style='width: 100%;
    height: 100%; overflow: hidden'>
    <input type="hidden" name="id_ventana" id="id_ventana" value="<%= id_ventana %>" />
    <table class="tb1">
        <tr class="tbLabel">
            <td style="width: 100%; text-align: left">
                <div style="width: 100%; text-align: left; font-size: 12px">
                    Existen las siguientes entidades con el CUIT ingresado. </br> Seleccione una entidad
                    si desea recuperar sus datos o cierre la ventana si quiere dar de alta una entidad
                    nueva.</div>
            </td>
        </tr>
        <tr>
            <td style="width: 100%; text-align: center">
                <div id="divEntidades" style="width: 100%; height: 90%; overflow: auto">
                </div>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
