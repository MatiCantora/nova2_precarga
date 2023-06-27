<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtroEsquemasFrimas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Esquema_firma'><campos>id_esquema,nro_entidad,strXML,nombreEsquema</campos><orden></orden><filtro></filtro></select></criterio>")

    Dim entidad As String = nvUtiles.obtenerValor("entidad", "")
    Dim razon_social As String = nvUtiles.obtenerValor("razon_social", "")

    Me.contents("entidad") = entidad
    Me.contents("razon_social") = razon_social
    
    Me.contents("filtroEsquemasFrimasDef") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Esquema_firma'><campos>id_esquema as id, nombreEsquema as [campo] </campos><orden></orden><filtro><nro_entidad type='igual'>" + entidad + "</nro_entidad></filtro></select></criterio>")

    Me.contents("filtroFunciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidad_funciones'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtroFuncionesRel") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadFuncionesRel'><campos>Razon_social, funcion, nro_funcion, destino </campos></select></criterio>")
    Me.contents("filtroEntidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidades'><campos>nro_entidad, Razon_social</campos><orden>nro_entidad</orden><grupo></grupo></select></criterio>")


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>NOVA Administrador</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var win = nvFW.getMyWindow();
        var entidad = nvFW.pageContents.entidad
        var razonSocial = nvFW.pageContents.razon_social

        var tabla_firmantes
        //var tabla_esquemas

        var funciones_lista = []
        var vectorEntidadesSeleccionadas

        var idEsquemaSeleccionado;
        var nombreEsquemaSeleccionado

        var vectorEsquemaXML = []

        function window_onload() {
            
            seleccionar_firmantes(entidad)
            window_onresize()
        }

        function window_onresize() {
            try {
                var menu_h = $("divMenu").getHeight()
                var seleccionarEsquemas_h = $("seleccionarEsquemas").getHeight()

                var seleccionarFirmantes = $("seleccionarFirmantes")

                var body_heigth = $$('body')[0].getHeight()

                seleccionarFirmantes.setStyle({ 'height': body_heigth - menu_h - seleccionarEntidad_h - seleccionarEsquemas_h })

                tabla_esquemas.resize();
            }
            catch (e) { }
        }

        function esquemaSeleccion() {
            
            idEsquemaSeleccionado = campos_defs.get_value("combo_esquema")//id
            nombreEsquemaSeleccionado = campos_defs.get_desc("combo_esquema")//nombre

            if (!idEsquemaSeleccionado)
                return

            var rsEsquemaXML = new tRS()
            rsEsquemaXML.open(nvFW.pageContents.filtroEsquemasFrimas, "", "<id_esquema>" + idEsquemaSeleccionado + "</id_esquema>")

            var vector = xmlAVector(rsEsquemaXML.getdata("strXML"))

            vectorFuncionesNecesarias = [];
            vectorFuncionesNecesariasExistentes = [];

            functionesNecesarias(vector)

            tabla_firmantes.refresh("<origen>" + entidad + "</origen><nro_funcion type='in'>" + generarFiltroFunctionesRequeridas() + "</nro_funcion>")
        }

        function generarFiltroFunctionesRequeridas() {
            var str = ""

            for (var i = 0; i < vectorFuncionesNecesarias.length ; i++) {
                str += vectorFuncionesNecesarias[i]
                if((i+1) !== vectorFuncionesNecesarias.length)
                    str += ","
            }

            return str;
        }

        function funcionesCargar() {
            if (funciones_lista.length === 0) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtroFunciones);

                while (!rs.eof()) {
                    funciones_lista[rs.getdata("nro_funcion")] = rs.getdata("funcion");
                    rs.movenext();
                }
            }
        }

        var funciones
        function prefijo_a_infijo(strXML, nro_entidad, fila) {

            var oXML = new tXML();
            oXML.loadXML(strXML);

            var resultado = "";

            resultado += "(";

            funcionesCargar();

            if (oXML.xml.firstChild)
                for (var i = 0; selectNodes("funcion", oXML.xml.firstChild).length > i; i++) {
                    var nodo = selectNodes("funcion", oXML.xml.firstChild)[i];
                    var minimo = selectNodes("minimo", nodo)[0].firstChild.data
                    var tipo = selectNodes("tipo", nodo)[0].firstChild.data

                    if (tipo == "funcion") {
                        resultado += funciones_lista[selectNodes("contenido", nodo)[0].firstChild.data] + "(" + minimo + ")";
                    }
                    else if (tipo == "grupo") {
                        //resultado += prefijo_a_infijo(selectNodes("contenido", nodo)[0].firstChild.xml)
                        resultado += prefijo_a_infijo(XMLtoString(nodo.firstChild.firstChild), nro_entidad, fila)
                    }
                    else {
                        resultado += "Esquema ID: " + selectNodes("contenido", nodo)[0].firstChild.data
                    }

                    if (selectNodes("funcion", oXML.xml.firstChild).length - 1 > i)
                        resultado += " " + oXML.xml.firstChild.nodeName + " "

                }

            resultado += ")";

            return resultado;
        }

        function seleccionar_firmantes(nro_entidad) {

            tabla_firmantes = new tTable();

            //Nombre de la tabla y id de la variable
            tabla_firmantes.nombreTabla = "tabla_firmantes";

            //Agregamos consulta XML
            tabla_firmantes.filtroXML = nvFW.pageContents.filtroFuncionesRel
            tabla_firmantes.filtroWhere = "<origen>" + 0 + "</origen>"
        
            tabla_firmantes.async = true;
            tabla_firmantes.cabeceras = ["Razon Social", "Funcion", "Nro Funcion", "Seleccionar"];

            tabla_firmantes.camposHide = [{ nombreCampo: "destino" }]

            //tabla_metadatos.camposHide = [{ nombreCampo: "nro_cn_oficina" }]

            tabla_firmantes.mostrarAgregar = false;

            tabla_firmantes.editable = false;
            tabla_firmantes.eliminable = false;

            tabla_firmantes.campos = [
                {
                    nombreCampo: "Razon_social", nro_campo_tipo: 104, enBD: false
                },
                {
                    nombreCampo: "funcion", nro_campo_tipo: 104, enBD: false
                },
                {
                    nombreCampo: "nro_funcion", nro_campo_tipo: 104, enBD: false
                },
                {
                    nombreCampo: "seleccionar", width: "7%", get_html: function (campo, nombre, fila) { return "<input type='checkbox' value='Seleccionar' id='checkbox_" + campo.fila + "'/>" }
                }
            ];

            tabla_firmantes.table_load_html();
        }





        /*function aceptar() {
            var strXML 
            vectorEntidadesSeleccionadas = []

            if (!idEsquemaSeleccionado) {
                alert("Debe seleccionar un esquema de firmas.")
                return;
            }

            strXML = "<firmantes>"
            strXML += "<esquema nro_entidad='" + entidad + "' idEsquema='" + idEsquemaSeleccionado + "' nombreEsquema='" + nombreEsquemaSeleccionado + "' >"

            var j = 0
            for (var i = 1 ; i < $('campos_tb_' + tabla_firmantes.nombreTabla).rows.length - 1; i++) {
                if ($("checkbox_" + i).checked) {
                    var fila = tabla_firmantes.getFila(i)
                    vectorEntidadesSeleccionadas[j + ",destino"] = fila["destino"]
                    vectorEntidadesSeleccionadas[j + ",Razon_social"] = fila["Razon_social"]
                    vectorEntidadesSeleccionadas[j + ",nro_funcion"] = fila["nro_funcion"]
                    vectorEntidadesSeleccionadas["length"] = j + 1
                    strXML += "<firmante nro_entidad='" + fila["destino"] + "' razon_social='" + fila["Razon_social"] + "' nro_funcion='" + fila["nro_funcion"] + "' />" 

                    j = j + 1
                }
            }

            strXML += "</esquema>"
            strXML += "</firmantes>"


            var rsEsquemaXML = new tRS()
            rsEsquemaXML.open(nvFW.pageContents.filtroEsquemasFrimas,"","<id_esquema>" + idEsquemaSeleccionado + "</id_esquema>")

            var vector = xmlAVector(rsEsquemaXML.getdata("strXML"))
            
            checkAux(vector, vectorEntidadesSeleccionadas)
            var valido = validate(vector)
            
            if (!valido) {
                alert("No es posible completar el circuito con los firmantes seleccionados.")
                return;
            }

            win.options.userData = strXML;
            win.close()
        }*/




        function aceptar() {
            debugger
            var strXML
            vectorEntidadesSeleccionadas = []

            if (!idEsquemaSeleccionado) {
                alert("Debe seleccionar un esquema de firmas.")
                return;
            }

            strXML = "<firmantes>"
            strXML += "<esquema razon_social='" + razonSocial + "' nro_entidad='" + entidad + "' idEsquema='" + idEsquemaSeleccionado + "' nombreEsquema='" + nombreEsquemaSeleccionado + "' >"

            var j = 0
            for (var i = 1; i < $('campos_tb_' + tabla_firmantes.nombreTabla).rows.length - 1; i++) {
                if ($("checkbox_" + i).checked) {
                    var fila = tabla_firmantes.getFila(i)
                    vectorEntidadesSeleccionadas[j + ",destino"] = fila["destino"]
                    vectorEntidadesSeleccionadas[j + ",Razon_social"] = fila["Razon_social"]
                    vectorEntidadesSeleccionadas[j + ",nro_funcion"] = fila["nro_funcion"]
                    vectorEntidadesSeleccionadas["length"] = j + 1
                    strXML += "<firmante nro_entidad='" + fila["destino"] + "' razon_social='" + fila["Razon_social"] + "' nro_funcion='" + fila["nro_funcion"] + "' />"

                    j = j + 1
                }
            }

            strXML += "</esquema>"
            strXML += "</firmantes>"


            var rsEsquemaXML = new tRS()
            rsEsquemaXML.open(nvFW.pageContents.filtroEsquemasFrimas, "", "<id_esquema>" + idEsquemaSeleccionado + "</id_esquema>")

            var vector = xmlAVector(rsEsquemaXML.getdata("strXML"))

            checkAux(vector, vectorEntidadesSeleccionadas)
            var valido = validate(vector)

            if (!valido) {
                alert("No es posible completar el circuito con los firmantes seleccionados.")
                return;
            }


            win.options.userData.retorno["xmlData"] = strXML
            win.close()
        }







        function validate(esquema) {

            var result = []
            var esq = esquema["OR"] || esquema["AND"]
            var anterior = true;

            if (esq) {
                for (var i = 0; i < esq[0].funcion.length; i++) {
                    var funcion = esq[0].funcion[i]
                    var tipo = funcion.tipo[0]
                    var contenido = funcion.contenido[0]

                    if (tipo == "grupo") {
                        result[i] = validate(funcion.contenido[0])
                    }

                }
            }

            if (esquema["OR"]) {
                for (var i = 0; i < esq[0].funcion.length; i++) {
                    var funcion = esq[0].funcion[i]

                    if (funcion.minimo[0] === 0) return true;
                    if (result[i]) return true
                }

                return false;
            }
            else if (esquema["AND"]) {
                for (var i = 0; i < esq[0].funcion.length; i++) {
                    var funcion = esq[0].funcion[i]
                    var tipo = funcion.tipo[0]

                    if (funcion.minimo[0] === 0 && anterior)
                        anterior = true;
                    else if (tipo !== "grupo") {
                        anterior = false;
                        break;
                    }

                    if (result[i] && anterior)
                        anterior = true
                    else if (result[i] !== undefined) {
                        anterior = false;
                        break;
                    }
                }

                return anterior;
            }
           
        }

        var vectorFuncionesNecesarias = [];
        var vectorFuncionesNecesariasExistentes = [];

        function functionesNecesarias(esquema) {

            var esq = esquema["OR"] || esquema["AND"]
            if (esq) {
                for (var i = 0; i < esq[0].funcion.length; i++) {
                    var funcion = esq[0].funcion[i]
                    var tipo = funcion.tipo[0]
                    var contenido = funcion.contenido[0]

                    if (tipo == "funcion") {
                        if (!vectorFuncionesNecesariasExistentes[contenido]) {
                            vectorFuncionesNecesariasExistentes[contenido] = true
                            vectorFuncionesNecesarias[vectorFuncionesNecesarias.length] = contenido
                        }
                    }
                    else if (tipo == "grupo") {
                        functionesNecesarias(funcion.contenido[0])
                    }
                    else if (tipo == "esquema") {
                        funcion.tipo[0] = "grupo"
                        funcion.minimo[0] = 1

                        var rsEsquemaXML = new tRS()
                        rsEsquemaXML.open(nvFW.pageContents.filtroEsquemasFrimas, "", "<id_esquema>" + contenido + "</id_esquema>")
                        funcion.contenido[0] = xmlAVector(rsEsquemaXML.getdata("strXML"))
                        functionesNecesarias(funcion.contenido[0])
                    }

                }
            }
            else { }
        }

        function checkAux(esquema, entidades) {
            for (var i = 0; i < entidades.length; i++) {
                var nro_funcion = entidades[i + ",nro_funcion"];
                check(esquema, nro_funcion)
            }
        }

        function check(esquema, nro_funcion) {
            
            var esq = esquema["OR"] || esquema["AND"]
            if (esq)
            {
                for (var i = 0; i < esq[0].funcion.length; i++) {
                    var funcion = esq[0].funcion[i]
                    var tipo = funcion.tipo[0]
                    var contenido = funcion.contenido[0]

                    if (tipo == "funcion") {
                        
                        if (nro_funcion == contenido) {
                            funcion.minimo[0] = funcion.minimo[0] - 1
                            
                        }
                    }
                    else if (tipo == "grupo") {
                        check(funcion.contenido[0],nro_funcion)
                    }
                    else if (tipo == "esquema") {
                        funcion.tipo[0] = "grupo"
                        funcion.minimo[0] = 1

                        var rsEsquemaXML = new tRS()
                        rsEsquemaXML.open(nvFW.pageContents.filtroEsquemasFrimas, "", "<id_esquema>" + contenido + "</id_esquema>")
                        funcion.contenido[0] = xmlAVector(rsEsquemaXML.getdata("strXML"))
                        check(funcion.contenido[0], nro_funcion)
                    }

                }
            }
        }

        function xmlAVector(xml) {
            if (!xml)
                return

            var oXML = new tXML()
            var vectorAux = []
            oXML.loadXML(xml)

            var retorno = [];
            retorno[oXML.xml.firstChild.baseName || oXML.xml.firstChild.tagName] = []
            retorno[oXML.xml.firstChild.baseName || oXML.xml.firstChild.tagName][0] = xmlAVectorAux(xml)

            return retorno;
        }

        function xmlAVectorAux(xml) {

            var oXML = new tXML()
            var vectorAux = []
            oXML.loadXML(xml)

            for (var i = 0; i < oXML.xml.childNodes[0].childNodes.length ; i++) {
                var valor
                var nodeName = oXML.xml.childNodes[0].childNodes[i].baseName || oXML.xml.childNodes[0].childNodes[i].tagName
                var ev

                try {
                    ev = (oXML.xml.childNodes[0].childNodes[i].childNodes[0].baseName || oXML.xml.childNodes[0].childNodes[i].childNodes[0].tagName)
                }
                catch (e) {
                    ev = false
                }

                if (ev === undefined) {
                    //son dos opciones porq depende si estoy usando el objeto de IE o el de Chrome
                    if (oXML.xml.childNodes[0].childNodes[i].childNodes[0].xml)
                        valor = oXML.xml.childNodes[0].childNodes[i].childNodes[0].xml
                    else
                        valor = oXML.xml.childNodes[0].childNodes[i].childNodes[0].textContent
                }
                else {
                    if (oXML.xml.childNodes[0].childNodes[i].xml)
                        valor = xmlAVectorAux(oXML.xml.childNodes[0].childNodes[i].xml)
                    else
                        valor = xmlAVectorAux(oXML.xml.childNodes[0].childNodes[i].outerHTML)
                }

                if (!vectorAux[nodeName])
                    vectorAux[nodeName] = []

                for (var k = 0 ; k < oXML.xml.childNodes[0].childNodes[i].attributes.length; k++) {
                    var nombreAtributo = oXML.xml.childNodes[0].childNodes[i].attributes[k].baseName || oXML.xml.childNodes[0].childNodes[i].attributes[k].nodeName
                    var valorAtributo = oXML.xml.childNodes[0].childNodes[i].attributes[k].text || oXML.xml.childNodes[0].childNodes[i].attributes[k].value
                    valor[nombreAtributo] = valorAtributo
                }


                vectorAux[nodeName][vectorAux[nodeName].length] = valor
            }

            return vectorAux
        }


    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">

    <div id="divMenu"></div>
    <script type="text/javascript">

        var vMenu = new tMenu('divMenu', 'vMenu');
        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Firmas</Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Aceptar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
        Menus["vMenu"].loadImage("agregar", "/FW/image/icons/agregar.png")
        vMenu.MostrarMenu()
    </script>

    <div id="seleccionarEsquemas">
        Esquema de Firma:
        <script type="text/javascript">
            campos_defs.add('combo_esquema', { nro_campo_tipo: 2, enDB: false, filtroXML: nvFW.pageContents.filtroEsquemasFrimasDef })
            campos_defs.items['combo_esquema']['onchange'] = esquemaSeleccion
        </script> 
    </div>

    <div id="seleccionarFirmantes">
        <div id="div_tabla_firmantes" style="width: 100%;">
            <div id="tabla_firmantes" style="width: 100%;"></div>
        </div>
    </div>


</body>
</html>
