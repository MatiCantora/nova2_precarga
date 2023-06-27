<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    
   
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    
    If modo = "" Then
        Dim id_circuito_firma As String = nvUtiles.obtenerValor("id_circuito_firma", "")
        Me.contents("filtroEntidadFunciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidad_funciones'><campos>*</campos><filtro>" &
                                                               "</filtro></select></criterio>")
        
        Me.contents("id_circuito_firma") = id_circuito_firma
        
    ElseIf modo = "GUARDAR" Then
    End If
    %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Entidad Funciones</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var tabla_funciones

        function window_onload() {

            tabla_funciones = new tTable();
            tabla_funciones.async = true;
            tabla_funciones.height = 250;

            //Nombre de la tabla y id de la variable
            tabla_funciones.nombreTabla = "tabla_funciones";

            //Agregamos consulta XML
            tabla_funciones.filtroXML = nvFW.pageContents.filtroEntidadFunciones;
            tabla_funciones.cabeceras = ["Default", "Razón"];

            //No se puede eliminar un radio seleccionado
            tabla_funciones.verificarRadioButton = true;

            //Funcion auxiliar para agregar un combobox
            //tabla_funciones.editable = false;
            //tabla_funciones.eliminable = false;
            tabla_funciones.camposHide = [{ nombreCampo: "razon_id"}]
            tabla_funciones.campos = [
                { nombreCampo: "funcion", nro_campo_tipo: 104, enDB: false, width: "25%"
                },
                { nombreCampo: "funcion_inversa", nro_campo_tipo: 104, enDB: false, width: "25%"
                },
                {
                    nombreCampo: "apli",
                    width: "10%",
                    align: "center",
                    checkBox: true,
                    convertirValorBD: function (valor) {
                        return (valor == "True") ? 1 : 0;
                    },
                    nulleable: true
                },
                {
                    nombreCampo: "port_transf",
                    width: "10%",
                    align: "center",
                    checkBox: true,
                    convertirValorBD: function (valor) {
                        return (valor == "True") ? 1 : 0;
                    },
                    nulleable: true
                }
            ]

        }

    </script>



    </head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    <div id='divHead'></div>

</body>
</html>
