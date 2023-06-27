<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%
    Me.contents("filtro_verParametros_credito") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos_parametros'><campos>campo_def,parametro_valor,etiqueta</campos><orden></orden><grupo></grupo><filtro></filtro></select></criterio>")
    Me.contents("filtro_verArchivos") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verArchivos'><campos>nro_archivo,Descripcion</campos><orden>orden</orden><filtro></filtro><orden>orden</orden></select></criterio>")

    Dim id_tipo = obtenerValor("id_tipo", "")
    Dim nro_archivo = obtenerValor("nroarchivo", "")
    Dim parametros = obtenerValor("parametros", "")
    Dim etiquetas = obtenerValor("etiquetas", "")
    Dim valores = obtenerValor("valores", "")
    Dim valoresdesc = obtenerValor("valoresdesc", "")
    Dim valoresdesc_antes = obtenerValor("valoresdesc_antes", "")
    Dim ventana = obtenerValor("ventana", "")
    Dim val
    Dim param
    Dim etiq
    Dim Q = ""
    Dim valdesc
    Dim valdesc_antes
    Dim modo = obtenerValor("modo", "")

    Dim tiene_permiso
    Dim nro_docu
    Dim tipo_docu
    Dim sexo

    If (modo = "G") Then

        Dim err = New tError()
        Try
            If (parametros <> "") Then param = parametros.Split(";")

            If (valores <> "") Then val = valores.Split(";")

            If (etiquetas <> "") Then etiq = etiquetas.Split(";")

            If (valoresdesc <> "") Then valdesc = valoresdesc.Split(";")

            If (valoresdesc_antes <> "") Then valdesc_antes = valoresdesc_antes.Split(";")

            For i As Integer = 0 To param.length
                If (valdesc(i) = valdesc_antes(i)) Then Continue For

                Dim StrSQL = ""
                Dim StrSQL_permisos = ""
                StrSQL_permisos = "select tiene_permiso from verarchivos_parametros where id_tipo = " + id_tipo + " and parametro = "" + param[i] + """
                Dim Rs = DBOpenRecordset(StrSQL_permisos)
                tiene_permiso = Rs.Fields("tiene_permiso").Value

                If (tiene_permiso > 0) Then

                    StrSQL = "update archivos_parametros SET parametro_valor = "" + val[i] + "", fe_actualizacion = getdate(), nro_operador = dbo.rm_nro_operador() WHERE id_tipo = " + id_tipo + " and parametro = "" + param[i] + "" \n"

                    Dim comentario = "Cambio en Parámetro <b>" + etiq(i) + "</b>: " + valdesc_antes(i) + " -> " + valdesc(i) + ""

                    StrSQL += "INSERT INTO com_registro(nro_com_tipo,comentario,operador,fecha,nro_com_estado,nro_com_id_tipo,id_tipo)"
                    StrSQL += "VALUES (1,""" + comentario + """,dbo.rm_nro_operador(),getdate(),1,1," + id_tipo + ")"
                    Try
                        DBExecute(StrSQL)
                        err.numError = 0

                    Catch e As Exception
                        err.numError = 1
                        err.parse_error_script(e)
                    End Try



                Else
                    err.numError = 2 ' El xml se proceso, pero el usuario no tiene permisos para ejecutar la actualizacion
                    err.params("retorno_salida") = 2
                End If 'fin del if permiso


            Next

            Err.numError = 0
            Err.mensaje = ""

        Catch e As Exception
            Err.parse_error_script(e)
        End Try

        Err.response()
    End If

%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="/FW/css/cabe.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/swfobject.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var winActualizar
        var lista_archivos_sel = new Array()
        var archivo_actual = 0
        var ancho_frame = 0
        var alto_frame = 0
        var strval_antes = ""

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Guardar";
        vButtonItems[0]["etiqueta"] = "Guardar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return guardar_parametros()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')

        function window_onload() {
            var ventana = '<%=ventana %>';
            vListButton.MostrarListButton()
            if (ventana != '1') {
                var win = nvFW.getMyWindow();
                win.maximize(true)
            }

            var r = cargar_archivos()
            if (r == 0) return;
            cargar_parametros()

            for (var i = 0; i < camposdefs.length; i++) {
                strval_antes += campos_defs.desc(camposdefs[i])
                if (i < camposdefs.length - 1) {
                    strval_antes += ";"
                }
            }

            var narchivo = '<%=nro_archivo %>'
            if (narchivo != '') {
                narchivo = parseInt(narchivo)
                for (var i = 0; i < archivos.length; i++) {
                    if (archivos[i] == narchivo) {
                        $('chk' + i).checked = true
                        lista_archivos_sel.push(i)
                    }
                }
                cargar_frame()
            }
            else {
                $('chktodos').checked = true
                seltodos()
            }
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
                var height = divDocs_height + pie_height + 50

                window.top.documento.setSize(700, height)
                if (divDocs_height >= 200)
                    var top = window.top.documento.element.offsetTop - divDocs_height + 210
                else
                    var top = window.top.documento.element.offsetTop - divDocs_height + 100
                var left = window.top.documento.element.offsetLeft
                window.top.documento.setLocation(top, left)
            }
            catch (e) { }

        }
        var archivos = new Array()

        function cargar_archivos() {
            archivos.clear()
            var id_tipo = $('id_tipo').value
            var rs = new tRS();
            var htmlArchivos = '<tr class = "tbLabel0"><td style="text-align:left" ><input type="checkbox" onclick="seltodos()" id="chktodos" style = "border:0px" />Archivos</td></tr>'
            rs.open(nvFW.pageContents.filtro_verArchivos, "", "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_archivo_estado type='igual'>1</nro_archivo_estado>")
            var i = 0
            while (!rs.eof()) {
                archivos.push(rs.getdata('nro_archivo'))
                htmlArchivos = htmlArchivos + '<tr><td><input type="checkbox" onclick="verArchivosSel()" id="chk' + i + '" style = "border:0px" /><a href="#"><span style="cursor:pointer" onclick="cargar_archivo(' + i + ')" id="span' + i + '">' + rs.getdata('Descripcion') + '</span></a></td></tr>'
                i++
                rs.movenext()
            }


            $('tbArchivos').update(htmlArchivos)
            return i;
        }
        var camposdefs = new Array()
        var etiquetas = new Array()
        var strparametros = ""
        var strvalores = ""
        var strvalores_antes = ""
        var stretiquetas = ""
        var strval = ""

        function cargar_archivo(ind) {
            archivo_actual = ind
            cargar_frame()
        }

        function cargar_parametros() {
            var id_tipo = $('id_tipo').value
            var rs = new tRS();
            var htmlEscaneo = '<tr class = "tbLabel0"><td style="text-align:center;" colspan="2">Parámetros de Escaneo</td></tr>'
            rs.open(nvFW.pageContents.filtro_verParametros_credito, "", "<id_tipo type='igual'>" + id_tipo + "</id_tipo><nro_param_grupo type='igual'>11</nro_param_grupo>")
            var i = 0
            var cddata = new Array()

            while (!rs.eof()) {
                camposdefs.push(rs.getdata("campo_def"))
                cddata.push(rs.getdata("parametro_valor"))
                etiquetas.push(rs.getdata("etiqueta"));
                htmlEscaneo += '<tr><td width="60%">' + rs.getdata("etiqueta") + '</td><td width="40%"><div id="def' + i + '"><div/></td></tr>'
                i++
                rs.movenext()
            }
            if (i > 0) {
                $('tbEscaneo').update(htmlEscaneo)
            } else {
                return
            }
            for (var j = 0; j < i; j++) {
                campos_defs.add(camposdefs[j], { target: 'def' + j })
                campos_defs.set_value(camposdefs[j], cddata[j])
                strparametros += camposdefs[j]
                stretiquetas += etiquetas[j]
                if (j < i - 1) {
                    strparametros += ";"
                    stretiquetas += ";"
                }
            }
        }

        function guardar_parametros() {

            for (var i = 0; i < camposdefs.length; i++) {
                strvalores += $F(camposdefs[i])
                strval += campos_defs.desc(camposdefs[i])
                if (i < camposdefs.length - 1)
                    strvalores += ";"
                strval += ";"
            }


            nvFW.error_ajax_request('verArchivosTodos.aspx', {
                parameters: { modo: 'G', id_tipo: id_tipo.value, parametros: strparametros, etiquetas: stretiquetas, valores: strvalores, valoresdesc: strval, valoresdesc_antes: strval_antes },
                onCreate: actualizar_start,
                onSuccess: function (err, transport) {

                    if (err.params['retorno_salida'] == 2) {
                        window.top.alert("No tiene permiso para realizar esta acción.")
                        return
                    }

                    if (err.numError != 0) {
                        alert("Error al guardar" + err.mensaje)
                    }

                    actualizar_stop();
                }
            });
            strvalores = ""
        }

        function actualizar_start() {
            winActualizar = window.top.Dialog.info('Actualizando', {
                className: "alphacube", width: 250,
                height: 60,
                showProgress: true
            });
        }

        function actualizar_stop() {
            winActualizar.close()

        }

        function recalcula(frame) {
            document.getElementById("frame" + frame).style.height = $('frame' + frame).clientWidth * 1.42 + "px";
        }

        function verArchivosSel_old() {
            var iframes = ""
            var id
            for (var i = 0; i < archivos.length; i++) {
                if ($('chk' + i).checked) {
                    iframes = iframes + '<div style="height:30px;width:100%;font-size:14px; font-weight:bold; color: white; background-color:#185683">' + $('span' + i).innerHTML + '</div><iframe id="frame' + i + '" onload="" src="/fw/file_get.aspx?nro_archivo=' + archivos[i] + '" width="100%" style="position:absolute;height:100%"></iframe>'
                }
            }
            $('vista_archivos').update(iframes)
            for (var i = 0; i < archivos.length; i++) {
                if ($('chk' + i).checked) {
                    id = 'frame' + i
                    $(id).src = '/fw/get_file.aspx?nro_archivo=' + archivos[i]
                    //recalcula(i)
                }
            }
        }

        function verArchivosSel() {
            actualizar_sel()
            archivo_actual = 0
            if (lista_archivos_sel.length == 0) {
                $('titulo').innerHTML = ""
                $('contenido').src = ""
                return
            }
            cargar_frame(lista_archivos_sel)
        }

        function cargar_frame() {
            var ind = lista_archivos_sel[archivo_actual]
            $('titulo').innerHTML = $('span' + lista_archivos_sel[archivo_actual]).innerHTML
            $('contenido').src = "/fw/get_file.aspx?nro_archivo=" + archivos[lista_archivos_sel[archivo_actual]]
            for (var i = 0; i < lista_archivos_sel.length; i++) {
                if (i == ind) {
                    $('span' + ind).style.color = 'blue';
                    $('span' + ind).style.fontWeight = 'bold';
                }
                else {
                    $('span' + i).style.color = 'black';
                    $('span' + i).style.fontWeight = 'normal';
                }
            }

        }

        function actualizar_sel() {
            lista_archivos_sel.clear()
            for (var i = 0; i < archivos.length; i++) {
                if ($('chk' + i).checked) {
                    lista_archivos_sel.push(i)
                }
            }
        }


        function seltodos_old() {
            var iframes = ""
            if ($('chktodos').checked) {
                for (var i = 0; i < archivos.length; i++) {
                    $('chk' + i).checked = true
                    iframes = iframes + '<div style="height:30px;width:100%;font-size:14px; font-weight:bold; color: white; background-color:#185683">' + $('span' + i).innerHTML + '</div><iframe id="frame' + i + '" onload="" src="/fw/file_get.aspx?nro_archivo=' + archivos[i] + '" width="100%" height="1000"></iframe>'

                }

                $('vista_archivos').update(iframes)
            }
            else {
                for (var i = 0; i < archivos.length; i++) {
                    $('chk' + i).checked = false
                    iframes = iframes + '<div style="height:30px;width:100%;font-size:14px; font-weight:bold; color: white; background-color:#185683">' + $('span' + i).innerHTML + '</div>'

                }
                $('vista_archivos').update(iframes)
            }

        }

        function seltodos() {
            lista_archivos_sel.clear()
            if ($('chktodos').checked) {
                for (var i = 0; i < archivos.length; i++) {
                    $('chk' + i).checked = true
                    lista_archivos_sel.push(i)
                }
                cargar_frame()
            }
            else {
                for (var i = 0; i < archivos.length; i++) {
                    $('chk' + i).checked = false
                }
                $('titulo').innerHTML = ""
                $('contenido').src = ""
            }
        }

        function proximo_archivo() {
            if (archivo_actual + 1 > lista_archivos_sel.length - 1)
                return
            archivo_actual = archivo_actual + 1

            cargar_frame()
        }

        function anterior_archivo() {
            if (archivo_actual - 1 < 0)
                return
            archivo_actual = archivo_actual - 1
            cargar_frame()
        }

        function inicio_archivo() {
            if (lista_archivos_sel.length <= 0) return
            archivo_actual = 0
            cargar_frame()
        }

        function fin_archivo() {
            if (lista_archivos_sel.length <= 0) return
            archivo_actual = lista_archivos_sel.length - 1
            cargar_frame()
        }

    </script>

</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto">
    <input type="hidden" name="id_tipo" id="id_tipo" value="<%=id_tipo %>" />
    <table style="width: 100%; height: 100%" class="tb1">
        <tr style="height: 100%">

            <td style="vertical-align: top; width: 200px; height: 100%">
                <div style="height: 400px; overflow: auto">
                    <table style="width: 100%" class="tb1" id="tbArchivos">
                    </table>
                </div>
                <br>
                <table style="width: 100%" class="tb1" id="tbEscaneo">
                </table>
                <div style="width: 100%" id="divGuardar">      
                </div>

                <div style="height: 100%; vertical-align: bottom; text-align: center; position: absolute; top: 0px; left: 0px;">
                    <div style="top: 100%; position: absolute; margin-top: -30px; width: 100px; left: 45px">
                        <img alt="Inicio" onclick="inicio_archivo()" style="cursor: pointer" src="/fw/image/icons/a_inicio_2.png"><img alt="Anterior" style="cursor: pointer" onclick="anterior_archivo()" src="/fw/image/icons/a_left_2.png"><img alt="Siguiente" onclick="proximo_archivo()" style="cursor: pointer" src="/fw/image/icons/a_right_2.png"><img alt="Fin" onclick="fin_archivo()" style="cursor: pointer" src="/fw/image/icons/a_fin_2.png">
                    </div>
                </div>
            </td>

            <td style="height: 100%">
                <div style="width: 100%; height: 100%" id="vista_archivos">
                    <table border="0" style="width: 100%; height: 100%">
                        <tr valign="middle">
                            <td id="titulo" style="width: 94%; font-size: 12px; font-weight: bold; color: white; background-color: #185683; height: 20px"></td>
                        </tr>
                        <tr>
                            <td>
                                <iframe id="contenido" src="" style="height: 100%; width: 100%"></iframe>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
    </table>

</body>
</html>
