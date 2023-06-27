<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>

<%


    Me.contents("filtro_esquema_firma") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='esquema_firma'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")
    Me.contents("filtro_verEntidadFuncionCantidades") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadFuncionCantidades'><campos>nro_funcion, cant_funcion </campos><filtro></filtro></select></criterio>")
    Me.contents("filtro_entidad_funciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='entidad_funciones'><campos>*</campos><filtro></filtro><orden></orden></select></criterio>")

    Dim subesquema = nvUtiles.obtenerValor("subesquema", "")
    Me.contents("subesquema") = subesquema

    Dim posicion = nvUtiles.obtenerValor("posicion", "")
    Me.contents("posicion") = posicion

    Dim nro_entidad = nvUtiles.obtenerValor("nro_entidad", "")
    Me.contents("nro_entidad") = nro_entidad
    Dim id_esquema = nvUtiles.obtenerValor("id_esquema", "")
    Me.contents("id_esquema") = id_esquema

    Dim id_esquema_buscar = nvUtiles.obtenerValor("id_esquema_buscar", "")
    Me.contents("id_esquema_buscar") = id_esquema_buscar

    Dim nombreEsquema = nvUtiles.obtenerValor("nombreEsquema", "")
    Me.contents("nombreEsquema") = nombreEsquema

    Dim modificando = nvUtiles.obtenerValor("modificando", "")
    Me.contents("modificando") = modificando

    Dim eliminar = nvUtiles.obtenerValor("eliminar", "")
    Me.contents("eliminar") = eliminar

    If id_esquema Is "" Then
        id_esquema = -1
    End If

    Me.contents("filtroCargarCertificados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='Esquema_firma'><campos>id_esquema,nro_entidad,strXML,nombreEsquema</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroCargarFunciones") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadFuncionCantidades'><campos>distinct nro_funcion as id, nombre_funcion as [campo] </campos><orden>[id]</orden><filtro></filtro></select></criterio>")


    Dim modo = nvUtiles.obtenerValor("modo", "")
    Dim strXML = nvUtiles.obtenerValor("strXML", "")

    Dim Err = New tError()

    If modo.ToUpper() = "M" Then

        Try
            Dim rs
            If eliminar = "true" Then
                rs = nvFW.nvDBUtiles.DBExecute("Delete from Esquema_firma where nro_entidad='" + nro_entidad + "' AND id_esquema='" + id_esquema + "'")
            Else
                If modificando = "true" Then
                    rs = nvFW.nvDBUtiles.DBExecute("update Esquema_firma set nro_entidad='" + nro_entidad + "', strXML='" + strXML + "', nombreEsquema= '" + nombreEsquema + "'" + "where id_esquema='" + id_esquema + "'")
                Else
                    rs = nvFW.nvDBUtiles.DBExecute("Delete from Esquema_firma where nro_entidad='" + nro_entidad + "' AND id_esquema='" + id_esquema + "'")
                    rs = nvFW.nvDBUtiles.DBExecute("insert into Esquema_firma(nro_entidad,strXML,nombreEsquema) values('" + nro_entidad + "','" + strXML + "','" + nombreEsquema + "')")
                End If
            End If

        Catch ex As Exception
            Err.parse_error_script(ex)
            Err.titulo = "Error guardar el esquema de firma."
            Err.mensaje = "Error guardar el esquema de firma."
            Err.debug_src = "pki_esquema_firma.aspx"

        End Try
        Err.salida_tipo = "adjunto"
        Err.response()

    End If



    If (modo.ToUpper() = "ENCRIPT") Then
        Err = New tError()
        Try
            Dim filtroSQL = obtenerValor("filtroSQL", "")

            Err.numError = 0
            Err.titulo = 0
            Err.mensaje = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadFuncionCantidades'><campos>distinct nro_funcion as id, nombre_funcion as [campo] </campos><orden>[id]</orden><filtro>" + filtroSQL + "</filtro></select></criterio>")
            Err.comentario = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEntidadFuncionCantidades'><campos>distinct nro_funcion as id, nombre_funcion as [campo] </campos><orden>[id]</orden><filtro>" + filtroSQL + "</filtro></select></criterio>")

        Catch e As Exception
            err.parse_error_script(e)
        End Try
        err.response()
    End If
%>
<html>
<head>
    <title>PKI Cert ABM</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        var nro_entidad = nvFW.pageContents.nro_entidad
        
        var id_esquema = nvFW.pageContents.id_esquema
        var id_esquema_buscar = nvFW.pageContents.id_esquema_buscar
        var nombreEsquema = nvFW.pageContents.nombreEsquema
        var vectorCont= [];

        function window_onload() {
            var strInfo
            if (id_esquema) {
                rs = new tRS()

                var filtroWhere = "<id_esquema>"+id_esquema+"</id_esquema>"

                rs.open(nvFW.pageContents.filtro_esquema_firma, '', filtroWhere, '', '');
                strInfo = rs.getdata("strXML");
                vectorCont = generarVectorFunciones(strInfo);

                funcionesMostrar(generarVectorFunciones(strInfo));
            }
            else if (win.options.userData) {
                strInfo = win.options.userData[0];
                vectorCont = generarVectorFunciones(strInfo);
                funcionesMostrar(generarVectorFunciones(strInfo));
            }

            if (nvFW.pageContents.subesquema == 'true') {
                $('div_nombre_esquema').style.display = false;
                $('div_nombre_esquema').hide();
            }

            window_onresize();
            
            actualizarDisenoEsquema()
        }
        
        function actualizarDisenoEsquema() {

            var vector = [];
            vector["contenido"] = vectorCont;

            if (vectorCont.length === 0)
                $("div_str_esquema").innerHTML = "()";
            else {
                vector["cond"] = vectorCont[0]["cond"]
                if (vectorCont[0]["cond"])
                    $("selCombo").value = vectorCont[0]["cond"]
                
            }
            $("div_str_esquema").innerHTML = "<b>Diseño Esquema: </b>" + prefijo_a_infijo(vectorAStr(vector));

            //comboChange()
        }
        
        function generarVectorFunciones(strInfo) {
            var vector_funciones_prueba = []
            
            if (!strInfo)
                return vector_funciones_prueba;

            var oXML = new tXML();
            oXML.loadXML(strInfo);

            cargarFunciones();
            
            var i =0;
            if (oXML.xml.firstChild) {

                var cond = oXML.xml.firstChild.nodeName;

                for (var i = 0; selectNodes("funcion", oXML.xml.firstChild).length > i; i++) {
                    var nodo = selectNodes("funcion", oXML.xml.firstChild)[i];
                    var minimo = selectNodes("minimo", nodo)[0].firstChild.data
                    var tipo = selectNodes("tipo", nodo)[0].firstChild.data

                    var contenido
                    var sub_vector = [];

                    if (tipo == "funcion") {
                        sub_vector["contenido"] = selectNodes("contenido", nodo)[0].firstChild.data
                    }
                    else if (tipo == "grupo") {
                        sub_vector["contenido"] = generarVectorFunciones(XMLtoString(nodo.firstChild.firstChild));
                    }
                    else {
                        var rs = new tRS()
                        rs.open(nvFW.pageContents.filtroCargarCertificados, '', "<id_esquema>" + selectNodes("contenido", nodo)[0].firstChild.data + "</id_esquema>", '', '');

                        sub_vector["strXML"] = generarVectorFunciones(rs.getdata("strXML"));
                        sub_vector["contenido"] = selectNodes("contenido", nodo)[0].firstChild.data
                        sub_vector["nombreEsquema"] = rs.getdata("nombreEsquema")
                    }

                    sub_vector["minimo"] = minimo;
                    sub_vector["tipo"] = tipo;
                    sub_vector["cond"] = cond;
                    vector_funciones_prueba[i] = sub_vector;
                }
                i++;
                
            }

            return vector_funciones_prueba;
        }

        var funciones_lista = []
        function cargarFunciones() {
            var rs
            if (!funciones_lista.length) {
                rs = new tRS();
                
                rs.open(nvFW.pageContents.filtro_entidad_funciones);

                while (!rs.eof()) {
                    funciones_lista[rs.getdata("nro_funcion")] = rs.getdata("funcion");
                    rs.movenext();
                }
            }
        }

        function funcionesMostrar(vector, divContenedor, j, enEsquema) {
            if (!divContenedor)
                $('tabla_esquemas_body').innerHTML = "";
            else
                $(divContenedor).innerHTML = "";

            if (!j && j !== 0) j = ""

            cargarFunciones();

            $('nombreEsquema').value = nombreEsquema

            if (vector.length > 0) {

                var cond = vector[0]["cond"];
                
                for (var i = 0; vector.length > i; i++) {
                    var nodo = vector[i];
                    var minimo = nodo["minimo"]
                    var tipo = nodo["tipo"]

                    var contenido
                    if (tipo == "funcion") {
                        contenido = funciones_lista[nodo["contenido"]];
                    }
                    else if (tipo == "grupo") {

                        if (nodo["contenido"].length === 0)
                            continue;

                        var indice
                        if (!divContenedor) {
                            divContenedor = "";
                            indice = i
                        }
                        else {
                            indice = j + "," + i
                        }

                        if (enEsquema) {
                            contenido = "<a value=\"Editar Grupo\" ><b>Grupo</b></a><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll'  id='" + divContenedor + "tabla_" + i + "'></table></div>";
                        }
                        else
                            contenido = "<a value=\"Editar Grupo\" onclick=\"agregarGrupo('" + indice + "')\"><b>Grupo: </b></a><input type='button' value='Editar' onclick=\"agregarGrupo('" + indice + "')\" /><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll'  id='" + divContenedor + "tabla_" + i + "'></table></div>";
                    }
                    else {
                        if (!divContenedor)
                            divContenedor = "";

                        var divContenedor2 = divContenedor + "esquema_" + i;

                        if (!divContenedor)
                            contenido = "<a value=\"Editar Esquema\" onclick=\"verEsquema('" + nodo["contenido"] + "','" + nodo["nombreEsquema"] + "','" + i + "')\"><b>Esquema: </b></a><input value='Editar' type='button'  onclick=\"verEsquema('" + nodo["contenido"] + "','" + nodo["nombreEsquema"] + "','" + i + "')\" /><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll' id='" + divContenedor2 + "'></table></div>";
                        else {
                            contenido = "<a value=\"Editar Esquema\" ><b>Esquema: </b>" + nodo["nombreEsquema"] + "</a><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll' id='" + divContenedor2 + "'></table></div>";
                        }
                    }

                    if (vector.length > (i + 1))
                        contenido += " " + cond

                    agregarFila(contenido, minimo, divContenedor);
                }

                for (var i = 0 ; i < vector.length ; i++) {
                    if (vector[i]["tipo"] == "grupo") {
                        var divContenedor2 = divContenedor + "tabla_" + i;

                        if (vector[i]["contenido"].length === 0)
                            continue;

                        funcionesMostrar(vector[i]["contenido"], divContenedor2, (j && j !== 0) ? j + "," + i : i, enEsquema);
                    }
                    else if (vector[i]["tipo"] == "esquema") {
                        var divContenedor2 = divContenedor + "esquema_" + i;
                        funcionesMostrar(vector[i]["strXML"], divContenedor2, '', true);
                    }
                }
            }
        }

        function window_onresize() {
            try {
                var menu_pki_h = $("divMenuABM_pki_certificados").getHeight()
                var div_nombre_h = $("div_nombre_esquema").getHeight()
                var div_menu_esquema_h = $("divMenuABM_esquema").getHeight()
                var body_heigth = $$('body')[0].getHeight()
                var selCombo = $("selCombo").getHeight()
                var div_str_esquema_h = $("div_str_esquema").getHeight()

                var tabla = $("tablas")

                tabla.setStyle({ 'height': body_heigth - selCombo - menu_pki_h - div_nombre_h - div_menu_esquema_h - 7 })

                campos_head.resize("tabla_esquemas_head", "tabla_esquemas_body");
            }
            catch (e) { }
        }
        
        function guardar() {
            xmlReturn = aceptar(true);
            if (!id_esquema)
                id_esquema = -1
            
            if (!campos_defs.get_value('nombreEsquema')) {
                alert("Seleccione un nombre para el esquema.")
                return
            }

            nombreEsquema = campos_defs.get_value('nombreEsquema')

            var eliminar = false;
            if (xmlReturn.length <= 11) {
                eliminar = true;
            }

            nvFW.error_ajax_request('pki_esquema_firma.aspx', {
                parameters: {
                    modo: "M",
                    nro_entidad: nro_entidad,
                    strXML: xmlReturn,
                    nombreEsquema: campos_defs.get_value('nombreEsquema'),
                    id_esquema: id_esquema,
                    modificando: nvFW.pageContents.modificando,
                    eliminar: eliminar
                },
                onSuccess: function () {
                    funcionesMostrar(generarVectorFunciones(xmlReturn));
                }

            });
        }

        function agregarFila(nombreFuncion, minimo, divContenedor) {
            var table
            if (!divContenedor) {
                table = $('tabla_esquemas_body')
            }
            else {
                table = $(divContenedor)
            }

            var row = table.insertRow(table.rows.length);
            var cell1 = row.insertCell(0);
            var cell2 = row.insertCell(1);
            cell2.style.textAlign = "center";

            cell1.innerHTML = nombreFuncion
            cell2.innerHTML = minimo

            cell1.id = "celda_columna_0_fila_" + (table.rows.length - 1)
            if (!divContenedor) {
                var cell3 = row.insertCell(2);
                var fila = table.rows.length - 1
                var func = "borrarFuncion('" + fila + "')"
                cell3.innerHTML = '<center><img border="0" onclick="' + func + '" src="/FW/image/icons/eliminar.png" title="eliminar" style="cursor:pointer"></center>';
                table.rows[0].cells[2].style.width = "60px";
            }

            table.rows[0].cells[1].style.width = "60px";

            campos_head.resize("tabla_esquemas_head", "tabla_esquemas_body");
        }

        function borrarFuncion(fila) {
            $('tabla_esquemas_body').rows[fila].hide();
            vectorCont[fila]["contenido"] = -1;
            campos_head.resize("tabla_esquemas_head", "tabla_esquemas_body");
        }

        function agregarFuncionAux() {
            var f = campos_defs.get_value("funcion");
            var m = campos_defs.get_value("funcion_minimo")
            var nombre_f = campos_defs.get_desc("funcion");
            
            if (f == "" || m == "") {
                alert("Asegurese de haber seleccionado una funcion y un minimo.")
                return;
            }
       
            if (m > vector_funcion_cantidad[f]) {
                alert("No se puede superar la cantidad maxima de roles.")
                return;
            }

            if (m < 1) {
                alert("El numero de roles debe ser mayor a 0.")
                return;
            }

            vectorCont[vectorCont.length] = []

            vectorCont[vectorCont.length-1]["contenido"] = f
            vectorCont[vectorCont.length-1]["tipo"] = "funcion"
            vectorCont[vectorCont.length-1]["minimo"] = m

            agregarFila(nombre_f, m)
        }

        var winTI
        var vector_funcion_cantidad = [];
        function agregarFuncion() {

            if (winTI) {
                winTI.show();
                return;
            }

            var strHTML = 'Función:<div id="div_funcion"><\/div>' +
                          'Mínimo:' +
                          '<table class="tb1 highlightEven highlightTROver scroll"><tr>' +
                          '<td style="width:80%"><div id="div_funcion_minimo"><\/div><\/td>' +
                          '<td style="width:20%"><div id="div_cantidad_funcion"><\/div><\/td>' +
                          '</tr>' +
                          '<tr><td><input type="Button" Value="Agregar" onclick="agregarFuncionAux()" style="width:100%" /><\/td>' +
                          '<td><input type="Button" Value="Cerrar" onclick="winTI.close()" style="width:100%" /><\/td><\/table>';

            var filtroWhere2 = "<nro_entidad>" + nro_entidad + "</nro_entidad>"

            if (vector_funcion_cantidad.length === 0) {
                var filtro = nvFW.pageContents.filtro_verEntidadFuncionCantidades;
                var rs = new tRS();

                rs.open(filtro, '', filtroWhere2, '', '');
                
                while (!rs.eof()) {
                    vector_funcion_cantidad[rs.getdata("nro_funcion")] = rs.getdata("cant_funcion");
                    rs.movenext();
                }
            }

            winTI = new Window({
                className: 'alphacube'
              , minimizable: false
              , maximizable: false
              , closable: false
              , height: 90
              , width: 400
              , title: "<b>" + "Agregar Funciones" + "</b>"
              , onShow: function () {

                  if (!campos_defs.items["funcion"]) {

                      encriptar_campo_def(filtroWhere2)

                      campos_defs.add("funcion_minimo",
                      {
                          nro_campo_tipo: 100,
                          enDB: false,
                          target: "div_funcion_minimo"
                      })

                      campos_defs.set_value("funcion_minimo",1)

                  }
              }
            });

            winTI.setHTMLContent(strHTML);
            winTI.showCenter(true);
        }


        function encriptar_campo_def(filtro) {
            nvFW.error_ajax_request('pki_esquema_firma.aspx', {
                parameters: {
                    modo: 'ENCRIPT',
                    filtroSQL: filtro
                },
                onSuccess: function (err, transport) {
                    campos_defs.add("funcion",
                      {
                          filtroXML: err.mensaje,
                          nro_campo_tipo: 1,
                          enDB: false,
                          target: "div_funcion"
                      })


                    campos_defs.items['funcion']['onchange'] = function () {
                        if (campos_defs.get_value("funcion")) {
                            $("div_cantidad_funcion").innerHTML = " de " + vector_funcion_cantidad[campos_defs.get_value("funcion")]
                        }
                    }

                }
            });
        }


        function aceptar(mantenerVentana) {
            
            comboChange();

            var v = []
            v["cond"] = $('selCombo').value
            v["contenido"] = vectorCont
            
            var str = vectorAStr(v);
            
            var parametro = [];
            parametro[0] = str;
            parametro[1] = true;
            if (nvFW.pageContents.posicion)
                parametro[2] = nvFW.pageContents.posicion

            win.options.userData = parametro;
            if (!mantenerVentana)
                win.close();
            return str
        }

        function agregarGrupoAux() {
            if (!win2.options.userData[1])
                return;

            var pos = [];
            var nuevo = false;
            if (win2.options.userData[2] || win2.options.userData[2] === 0) {
                pos = win2.options.userData[2].split(",")
                if (pos[0] == vectorCont.length)
                    nuevo = true;
            }
            else
                pos[0] = vectorCont.length;
            
            var nuevos = generarVectorFunciones(win2.options.userData[0])
            /*
            if (nuevos.length === 0) {
                borrarFuncion(pos[0]);
                campos_head.resize("tabla_esquemas_head", "tabla_esquemas_body");
                return;
            }
            */
            cambiar_valor_a_vector(pos,nuevos)
            
            if (nuevo) {
                var link = "<a value=\"Editar Grupo\" onclick=\"agregarGrupo('" + pos[0] + "')\"><b>Grupo: </b></a><input type='button' value='Editar' onclick=\"agregarGrupo('" + pos[0] + "')\" /><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll'  id='" + "tabla_" + pos[0] + "'></table></div>"
                agregarFila(link, 1);
            }
      
            funcionesMostrar(vectorCont[pos[0]]["contenido"], "tabla_" + pos[0], pos[0]);
        }
        /*
        function vectorAStr(vector) {
            var str = "";
            var cond = vector["cond"];

            vector = vector["contenido"]

            str += "<" + cond + ">";

            for (var i = 0; vector.length > i; i++) {

                if (vector[i]["contenido"] === -1)
                    continue;
                
                if (vector[i]["tipo"] == "grupo" && vector[i]["contenido"].length === 0) 
                    continue;

                str += "<funcion>"
                str += "<contenido>"

                if (vector[i]["tipo"] == "grupo") {
                    str += vectorAStr(vector[i])
                }
                else
                    str += vector[i]["contenido"]

                str += "</contenido>"
                str += "<minimo>"
                str += vector[i]["minimo"]
                str += "</minimo>"
                str += "<tipo>"
                str += vector[i]["tipo"]
                str += "</tipo>"
                str += "</funcion>"

            }

            str += "</" + cond + ">";

            return str;
        }
        */

        function vectorAStr(vector) {
            var str = "";
            //var cond = vector["cond"];

            vector = vector["contenido"]
            var cond = vector[0]["cond"];

            str += "<" + cond + ">";

            for (var i = 0; vector.length > i; i++) {

                if (vector[i]["contenido"] === -1)
                    continue;

                if (vector[i]["tipo"] == "grupo" && vector[i]["contenido"].length === 0)
                    continue;

                str += "<funcion>"
                str += "<contenido>"

                if (vector[i]["tipo"] == "grupo") {
                    str += vectorAStr(vector[i])
                }
                else
                    str += vector[i]["contenido"]

                str += "</contenido>"
                str += "<minimo>"
                str += vector[i]["minimo"]
                str += "</minimo>"
                str += "<tipo>"
                str += vector[i]["tipo"]
                str += "</tipo>"
                str += "</funcion>"

            }

            str += "</" + cond + ">";

            return str;
        }
        
        function cambiar_valor_a_vector_aux(i, vector3, valor) {

            if (i.length == 1) {

                if (!vector3[i]) {
                    vector3[i] = [];
                    vector3[i]["cond"] = $("selCombo").value
                }
                else {
                    if (valor.length === 0)
                        vector3[i]["cond"] = ""
                    else
                        vector3[i]["cond"] = valor[0]["cond"]
                }

                vector3[i]["contenido"] = valor
                vector3[i]["minimo"] = 1
                vector3[i]["tipo"] = "grupo"
                return;
            }

            cambiar_valor_a_vector_aux(i.slice(1), vector3[i[0]]["contenido"], valor)
            return vector3;
        }

        function cambiar_valor_a_vector(i,valor) {
            var resultado = cambiar_valor_a_vector_aux(i, vectorCont, valor)
        }

        function get_valor_vector(i,vector) {

            if (i.length == 1) {
                return vector[i[0]];
            }

            return get_valor_vector(i.slice(1),vector[i[0]]["contenido"])
        }

        var win2
        function agregarGrupo(pos) {

            var str
            if (pos)
                str = vectorAStr(get_valor_vector(pos.split(","), vectorCont));
            else
                pos = vectorCont.length
            
            nvFW.bloqueo_activar($("vidrio_esquema"), 'cargando-esquema');
            win2 =
                window.top.nvFW.createWindow({
                    className: 'alphacube',
                    url: 'pki_esquema_firma.aspx?subesquema=true' + "&posicion=" + pos + "&nro_entidad=" + nro_entidad + "&id_esquema_buscar=" + id_esquema,
                    title: '<b>Sub Esquema</b>',
                    width: 1000,
                    height: 500,
                    onClose: function () {
                        agregarGrupoAux();
                        actualizarDisenoEsquema();
                        nvFW.bloqueo_desactivar($("vidrio_esquema"), 'cargando-esquema');
                    },
                    destroyOnClose: true
                });
            
            var param = []
            param[0] = str
            param[1] = false;
            win2.options.userData = param;
            win2.options.data = {};
            win2.showCenter();
        }

        var winTI
        function agregarEsquema() {

            var strHTML = '<div style="width:400px; height:400" id="div_esquema"><\/div>'

            winTI = new Window({
                className: 'alphacube'
              , minimizable: false
              , maximizable: false
              , height: 400
              , width: 400
              , title: "<b>" + "Agregar Esquema" + "</b>"
              , onShow: function () {
                  mostrarTablaEsquema();
              }
            });

            winTI.setHTMLContent(strHTML);
            winTI.showCenter(true);
        }

        var div_esquema
        function mostrarTablaEsquema() {
            div_esquema = new tTable();

            //Nombre de la tabla y id de la variable
            div_esquema.nombreTabla = "div_esquema";
            //Agregamos consulta XML
            div_esquema.filtroXML = nvFW.pageContents.filtroCargarCertificados

            if (!id_esquema_buscar)
                id_esquema_buscar = id_esquema;

            div_esquema.filtroWhere = "<nro_entidad type='igual'>" + nro_entidad + "</nro_entidad><id_esquema type='distinto'>" + id_esquema_buscar + "</id_esquema>";
            
            div_esquema.cabeceras = ["Nombre Esquema", "Id Esquema", "Seleccionar"];

            div_esquema.async = true;

            div_esquema.mostrarAgregar = false;
            div_esquema.eliminable = false;
            div_esquema.editable = false;

            div_esquema.agregar_espacios_en_blanco_dir = function () {
                esquema_nuevo(nro_entidad)
            }
            div_esquema.modificar_fila = function (fila) {
                modificar_esquema(fila)
            }

            div_esquema.campos = [
             {
                 nombreCampo: "nombreEsquema", nro_campo_tipo: 104, width: "85%"
             },
             {
                 nombreCampo: "id_esquema", nro_campo_tipo: 104, width: "15%"
             },
             {
                 nombreCampo: "seleccionar", get_html: function (campo, nombre, fila)
                 {
                     return "<input type='button' value='Seleccionar' onclick='seleccionarEsquema(\"" + fila[1].valor + "\",\"" + fila[0].valor + "\")'>"
                 }
             }
            ];

            div_esquema.table_load_html();
        }

        function agregarEsquemaAux(id_esquema, i) {

            var contenido = "";

            var rs = new tRS()
            rs.open(nvFW.pageContents.filtroCargarCertificados, '', "<id_esquema>" + id_esquema + "</id_esquema>", '', '');
            var cont = rs.getdata("strXML");

            if (!cont) {
                borrarFuncion(i);
                return;
            }

            vectorCont[i] = [];
            vectorCont[i]["contenido"] = id_esquema
            vectorCont[i]["strXML"] = generarVectorFunciones(cont)
            vectorCont[i]["minimo"] = 1;
            vectorCont[i]["tipo"] = "esquema";

            funcionesMostrar(generarVectorFunciones(cont), "esquema_" + i, '', true);
        }

        function verEsquema(id_esquema, nombre, i) {
            
            nvFW.bloqueo_activar($("vidrio_esquema"), 'cargando-esquema');
            
            var win3 =
            window.top.nvFW.createWindow({
                className: 'alphacube',
                url: 'pki_esquema_firma.aspx?subesquema=false' + "&nro_entidad=" + nro_entidad + "&id_esquema=" + id_esquema + "&nombreEsquema=" + nombre + "&modificando=true",
                title: '<b>Modificar Esquema</b>',
                width: 1000,
                height: 500,
                destroyOnClose: true,
                onClose: function () {
                    agregarEsquemaAux(id_esquema, i);
                    nvFW.bloqueo_desactivar($("vidrio_esquema"), 'cargando-esquema');
                }
            });

            win3.options.data = {};
            win3.showCenter();
        }

        function seleccionarEsquema(valor, nombre) {

            var divContenedor2 = "esquema_" + vectorCont.length;
            
            var link = "<a value=\"Ver Esquema\" onclick=\"verEsquema('" + valor + "','" + nombre + "','" + vectorCont.length + "')\"><b>Ver Esquema: </b></a>" + "<input type='button' value='Editar'  onclick=\"verEsquema('" + valor + "','" + nombre + "','" + vectorCont.length + "')\"  /><div style='background-color: rgb(230,230,230);margin: 5px;border:1px solid black;'><table class='tb1 highlightEven highlightTROver scroll' id='" + divContenedor2 + "'></table></div>"

            agregarFila(link, 1);

            var rs = new tRS()
            rs.open(nvFW.pageContents.filtroCargarCertificados, '', "<id_esquema>" + valor + "</id_esquema>", '', '');

            vectorCont[vectorCont.length] = []
            vectorCont[vectorCont.length-1]["strXML"] = generarVectorFunciones(rs.getdata("strXML"));
            vectorCont[vectorCont.length-1]["contenido"] = valor;
            vectorCont[vectorCont.length-1]["minimo"] = 1;
            vectorCont[vectorCont.length-1]["tipo"] = "esquema";

            funcionesMostrar(generarVectorFunciones(rs.getdata("strXML")), divContenedor2, vectorCont.length - 1, true);

            winTI.close();
        }

        function prefijo_a_infijo(strXML) {
            var oXML = new tXML();
            oXML.loadXML(strXML);

            var resultado = "";

            resultado += "(";

            if (funciones_lista.length === 0) {
                var rs = new tRS();
                rs.open(nvFW.pageContents.filtro_entidad_funciones);

                while (!rs.eof()) {
                    funciones_lista[rs.getdata("nro_funcion")] = rs.getdata("funcion");
                    rs.movenext();
                }
            }

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
                        resultado += prefijo_a_infijo(XMLtoString(nodo.firstChild.firstChild))
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

        function comboChange() {
            for (var i = 0; i < vectorCont.length; i++) {
                vectorCont[i]["cond"] = $("selCombo").value;
            }
        }

    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden">
    <div id="vidrio_esquema" style="height: 100%">

    <div id="divMenuABM_pki_certificados"></div>
    <script type="text/javascript">

        var vMenuABM_pki_certificados = new tMenu('divMenuABM_pki_certificados', 'vMenuABM_pki_certificados');
        Menus["vMenuABM_pki_certificados"] = vMenuABM_pki_certificados
        Menus["vMenuABM_pki_certificados"].alineacion = 'centro';
        Menus["vMenuABM_pki_certificados"].estilo = 'A';
        Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Esquemas</Desc></MenuItem>")

        if (nvFW.pageContents.subesquema == "true") {
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Aceptar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>aceptar()</Codigo></Ejecutar></Acciones></MenuItem>")
        }
        else {
            Menus["vMenuABM_pki_certificados"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
        }

        Menus["vMenuABM_pki_certificados"].loadImage("guardar", "/FW/image/icons/guardar.png")
        vMenuABM_pki_certificados.MostrarMenu()

    </script>

    
    <div id="div_nombre_esquema">
        Nombre de Esquema:
        <script>
            campos_defs.add("nombreEsquema",
            {
                nro_campo_tipo: 104,
                enDB: false
            })
        </script>
    </div>

    Condicion:<select id="selCombo" name="selCombo" onchange="comboChange()">
        <option value="AND">AND</option>
        <option value="OR">OR</option>
    </select>

    <div id="div_str_esquema"></div>

    <div id="divMenuABM_esquema"></div>
    <script type="text/javascript">

        var divMenuABM_esquema = new tMenu('divMenuABM_esquema', 'divMenuABM_esquema');
        Menus["divMenuABM_esquema"] = divMenuABM_esquema
        Menus["divMenuABM_esquema"].alineacion = 'centro';
        Menus["divMenuABM_esquema"].estilo = 'A';
        Menus["divMenuABM_esquema"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Agrear Esquema</Desc></MenuItem>")
        Menus["divMenuABM_esquema"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Agregar Funcion</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregarFuncion()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["divMenuABM_esquema"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Agregar Grupo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregarGrupo()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["divMenuABM_esquema"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Agregar Esquema</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregarEsquema()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["divMenuABM_esquema"].loadImage("guardar", "/FW/image/icons/guardar.png")
        divMenuABM_esquema.MostrarMenu()

    </script>

    <div style="overflow:auto" id="tablas">
        <table class="tb1" id="tabla_esquemas_head">
            <tr class="tbLabel">
                <td>
                    Condicion
                </td>
                <td style="width:60px">
                    Mínimo
                </td>
                 <td style="width:60px">
                    Eliminar
                </td>
            </tr>
        </table>
        <table class="tb1 highlightEven highlightTROver scroll" id="tabla_esquemas_body"></table>
    </div>

    </div>
</body>
</html>
