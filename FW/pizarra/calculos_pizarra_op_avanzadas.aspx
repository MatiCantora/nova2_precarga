<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim nro_calc_pizarra As Integer = nvFW.nvUtiles.obtenerValor("nro_calc_pizarra", "0")
    Dim bloquear As Boolean = nvFW.nvUtiles.obtenerValor("bloquear", "0")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim valores As trsParam = Nothing

    If nro_calc_pizarra <> 0 AndAlso accion <> "" Then
        Select Case accion.ToLower()

            Case "get"
                Dim strSQL As String = "SELECT * FROM calc_pizarra_cab_def_valores WHERE nro_calc_pizarra=" & nro_calc_pizarra

                Try
                    valores = New trsParam()
                    Dim valor As trsParam
                    Dim i As Integer = 0
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

                    While Not rs.EOF
                        valor = New trsParam()
                        valor.Add("id_nro_calc_pizarra", rs.Fields("id_nro_calc_pizarra").Value)
                        valor.Add("nro_calc_pizarra", rs.Fields("nro_calc_pizarra").Value)
                        valor.Add("prefijo", rs.Fields("prefijo").Value)
                        valor.Add("posfijo", rs.Fields("posfijo").Value)
                        valor.Add("tipo_dato", rs.Fields("tipo_dato").Value)
                        valor.Add("campo_def", rs.Fields("etiqueta").Value)
                        valor.Add("etiqueta", rs.Fields("etiqueta").Value)
                        valor.Add("ancho", rs.Fields("ancho").Value)

                        valores.Add(i.ToString, valor)
                        i += 1
                    End While

                    nvDBUtiles.DBCloseRecordset(rs)
                    Me.contents.Add("valores", valores)
                    Me.contents.Add("mensaje", "")

                Catch ex As Exception
                    Me.contents.Add("valores", Nothing)
                    Me.contents.Add("mensaje", "GET::Ocurrió un error al realizar la consulta.")
                End Try


            Case "guardar"
                Dim err As New tError()
                err.numError = 101
                err.debug_src = "::guardar"
                err.response()

        End Select
    End If


    Me.contents.Add("nro_calc_pizarra", nro_calc_pizarra)
    Me.contents.Add("filtro_consulta_valores", nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_cab_def_valores'><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>"))
    Me.contents.Add("filtro_dato_tipos", nvXMLSQL.encXMLSQL("<criterio><select vista='dato_tipos'><campos>id_dato_tipo AS id, nro_campo_tipo, dato_tipo AS campo, adoXML</campos><orden>id_dato_tipo</orden></select></criterio>"))
    Me.contents.Add("filtro_campos_defs", nvXMLSQL.encXMLSQL("<criterio><select vista='campos_def'><campos>campo_def, descripcion</campos><orden>campo_def, descripcion</orden><filtro><depende_de type='sql'>depende_de is null</depende_de></filtro></select></criterio>"))
%>
<html>
<head>
    <title>Pizarra Opciones Avanzadas</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <style type="text/css">
        select:disabled {
            background-color: #e9e9e4;
        }
        #pizarra_matriz:disabled {
            cursor: default !important;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var ventana          = nvFW.getMyWindow();
        var dif              = Prototype.Browser.IE ? 5 : 0;
        var valores_eliminar = [];
        var nro_calc_pizarra = nvFW.pageContents.nro_calc_pizarra;
        var cantidad_valores = 0;
        var arr_tipo_dato    = null;
        var arr_campos_defs  = null;
        var MAX_SALIDAS      = 2;
        var bloquear         = <% = If(bloquear, 1, 0) %>;
        // Elementos cache
        var $body;
        var $tbValores;
        var $divMenu;
        var $tbCubo;
        var $divBotones;


        function window_onload()
        {
            nvFW.enterToTab = false;

            $body       = $$('body')[0];
            $tbValores  = $("tbValores");
            $divMenu    = $("divMenu");
            $tbCubo     = $('tbCubo');
            $divBotones = $("divBotones");

            cargar_salida_original();
            cargarSelectores();
            cargar_opciones();
            cargar_salidas();
            window_onresize();

            nvFW.bloqueo_desactivar(null, "vidrio_cargar"); // lo dejamos aca por si falla en la funcion cargar_salidas()
            DibujarVidrioBloqueo();
        }


        function DibujarVidrioBloqueo()
        {
            if (bloquear)
            {
                // Actualizar el titulo de la ventana
                ventana.setTitle = '<b>Opciones Avanzadas desde Histórico</b>';

                if (!$('vidrioBloqueo'))
                {
                    var div   = document.createElement('div');
                    div.id    = 'vidrioBloqueo';
                    div.title = 'No es posible editar una pizarra histórica';

                    div.setStyle({
                        position: 'absolute',
                        width: '100%',
                        height: $body.getHeight() + 'px',
                        top: 0,
                        left: 0,
                        'z-index': 1,
                        cursor: 'not-allowed',
                        'user-select': 'none'
                    });

                    $body.appendChild(div);
                }
                else
                {
                    $('vidrioBloqueo').show();
                }
            }
        }


        function cargar_salida_original()
        {
            if (ventana.options.userData.valores_salida)
            {
                var salida = ventana.options.userData.valores_salida;

                $("etiqueta").value  = salida.etiqueta;
                $("tipo_dato").value = salida.tipo_dato;
                $("campo_def").value = salida.campo_def;
                $("prefijo").value   = salida.prefijo;
                $("posfijo").value   = salida.posfijo;
                $("ancho").value     = salida.ancho;
            }
        }


        function window_onresize()
        {
            try
            {
                var altura = $divMenu.getHeight() + $tbCubo.getHeight() + $tbValores.getHeight() + $divBotones.getHeight();
                ventana.setSize(ventana.width, altura);
            }
            catch (e) { }
        }


        function cargarSelectores()
        {
            // tipo_dato
            if (!arr_tipo_dato)
            {
                cargar_select_tipo_dato();
            }

            // campos_defs
            if (!arr_campos_defs)
            {
                cargar_select_campos_defs();
            }
        }


        function cargar_select_tipo_dato()
        {
            arr_tipo_dato = {};
            var id        = null;
            var rs        = new tRS();
            rs.open({ filtroXML: nvFW.pageContents.filtro_dato_tipos });

            while (!rs.eof())
            {
                id = rs.getdata("id");
                arr_tipo_dato[id] = {};
                arr_tipo_dato[id].id             = id;
                arr_tipo_dato[id].campo          = rs.getdata("campo");
                arr_tipo_dato[id].nro_campo_tipo = rs.getdata("nro_campo_tipo");
                arr_tipo_dato[id].adoXML         = rs.getdata("adoXML");

                rs.movenext();
            }
        }


        function cargar_select_campos_defs()
        {
            arr_campos_defs = [];
            var rs = new tRS();
            rs.open({ filtroXML: nvFW.pageContents.filtro_campos_defs });

            while (!rs.eof())
            {
                arr_campos_defs[rs.position] = [];
                arr_campos_defs[rs.position].campo_def   = rs.getdata('campo_def').toLowerCase();
                arr_campos_defs[rs.position].descripcion = rs.getdata('descripcion').toLowerCase();

                rs.movenext();
            }
        }


        function cargar_opciones()
        {
            // Marcar las opciones
            if (ventana.options.userData.pizarra_cubo)
            {
                $('pizarra_cubo').checked    = true;
                $('pizarra_matriz').disabled = false;

                if (ventana.options.userData.pizarra_matriz)
                {
                    $('pizarra_matriz').checked = true;
                }
            }
            else
            {
                $('pizarra_cubo').checked    = false;
                $('pizarra_matriz').disabled = true;
                $('pizarra_matriz').checked  = false;
            }
        }


        function cargar_salidas()
        {
            // Probar cargar por datos pasados a ventana
            if (ventana.options.userData["valores"].length)
            {
                cargar_salidas_por_ventana();
            }
            else
            {
                var rs   = new tRS();
                rs.async = true;

                rs.onComplete = function (response)
                {
                    if (response.recordcount)
                    {
                        var html    = '';
                        var evaluar = '';
                        var pos     = 0;

                        while (!response.eof())
                        {
                            pos = response.position;

                            html += '<tr id="tr_' + pos + '">';
                            html += '<td style="width: 7.5%;">';
                            html += '<input type="text" name="id_nro_calc_pizarra_' + pos + '" id="id_nro_calc_pizarra_' + pos + '" value="' + response.getdata("id_nro_calc_pizarra") + '" disabled="disabled" style="width: 100%; text-align: center;" />';
                            html += '</td>';
                            html += '<td style="width: 7.5%;">';
                            html += '<input type="text" name="nro_calc_pizarra_' + pos + '" id="nro_calc_pizarra_' + pos + '" value="' + response.getdata("nro_calc_pizarra") + '" disabled="disabled" style="width: 100%; text-align: center;" />';
                            html += '</td>';
                            html += '<td style="width: 25%;" id="td_etiqueta_' + pos + '">';
                            evaluar += 'campos_defs.add("etiqueta_' + pos + '", { nro_campo_tipo: 104, enDB: false, target: "td_etiqueta_' + pos + '" });campos_defs.set_value("etiqueta_' + pos + '", "' + response.getdata("etiqueta") + '");';
                            html += '</td>';
                            html += '<td style="width: 17.5%;">';
                            html += dibujar_select_tipo_dato("tipo_dato_" + pos, response.getdata("tipo_dato"));
                            html += '</td>';
                            html += '<td style="width: 17.5%;">';
                            html += dibujar_select_campos_defs("campo_def_" + pos, response.getdata("campo_def"));
                            html += '</td>';
                            html += '<td style="width: 5%;">';
                            html += '<input type="text" name="prefijo_' + pos + '" id="prefijo_' + pos + '" value="' + response.getdata("prefijo") + '" style="width: 100%;" />';
                            html += '</td>';
                            html += '<td style="width: 5%;">';
                            html += '<input type="text" name="posfijo_' + pos + '" id="posfijo_' + pos + '" value="' + response.getdata("posfijo") + '" style="width: 100%;" />';
                            html += '</td>';
                            html += '<td style="width: 7.5%;" id="td_ancho_' + pos + '">';
                            evaluar += 'campos_defs.add("ancho_' + pos + '", { nro_campo_tipo: 100, enDB: false, target: "td_ancho_' + pos + '" });campos_defs.set_value("ancho_' + pos + '", "' + (response.getdata("ancho") != 0 ? response.getdata("ancho") : "") + '");';
                            html += '</td>';
                            html += '<td style="width: 5.5%; text-align: center;">';
                            html += '<img alt="eliminar" src="/FW/image/icons/eliminar.png" title="Eliminar" onclick="return eliminar_fila(' + pos + ');" style="cursor: pointer;" />&nbsp;';
                            html += '<img alt="subir" src="/FW/image/icons/up_a.png" title="Subir" onclick="return subir_fila(' + pos + ');" style="cursor: pointer; position: relative; left: 5px; top: -5px;" />';
                            html += '<img alt="bajar" src="/FW/image/icons/down_a.png" title="Bajar" onclick="return bajar_fila(' + pos + ');" style="cursor: pointer; position: relative; left: -5px; top: 5px;" />';
                            html += '<input type="hidden" name="orden_' + pos + '" id="orden_' + pos + '" value="' + pos + '" />';
                            html += '</td>';
                            html += '</tr>';

                            cantidad_valores++;
                            response.movenext();
                        }

                        $tbValores.select("tbody")[0].insert({ bottom: html });
                        eval(evaluar);
                        window_onresize();
                    }

                    nvFW.bloqueo_desactivar(null, "vidrio_cargar");
                }

                rs.onError = function (response)
                {
                    nvFW.bloqueo_desactivar(null, "vidrio_cargar");
                }

                rs.open(
                {
                    filtroXML: nvFW.pageContents.filtro_consulta_valores,
                    filtroWhere: "<criterio><select><filtro><nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra></filtro></select></criterio>"
                });
            }
        }


        function cargar_salidas_por_ventana()
        {
            var datos   = ventana.options.userData.valores;
            var html    = '';
            var evaluar = '';

            for (var i = 0; i < datos.length; i++)
            {
                html += '<tr id="tr_' + i + '">';
                html += '<td style="width: 7.5%;">';
                html += '<input type="text" name="id_nro_calc_pizarra_' + i + '" id="id_nro_calc_pizarra_' + i + '" value="' + datos[i].id_nro_calc_pizarra + '" disabled="disabled" style="width: 100%; text-align: center;" />';
                html += '</td>';
                html += '<td style="width: 7.5%;">';
                html += '<input type="text" name="nro_calc_pizarra_' + i + '" id="nro_calc_pizarra_' + i + '" value="' + datos[i].nro_calc_pizarra + '" disabled="disabled" style="width: 100%; text-align: center;" />';
                html += '</td>';
                html += '<td style="width: 25%;" id="td_etiqueta_' + i + '">';
                evaluar += 'campos_defs.add("etiqueta_' + i + '", { nro_campo_tipo: 104, enDB: false, target: "td_etiqueta_' + i + '" });campos_defs.set_value("etiqueta_' + i + '", "' + datos[i].etiqueta + '");';
                html += '</td>';
                html += '<td style="width: 17.5%;">';
                html += dibujar_select_tipo_dato("tipo_dato_" + i, datos[i].tipo_dato);
                html += '</td>';
                html += '<td style="width: 17.5%;">';
                html += dibujar_select_campos_defs("campo_def_" + i, datos[i].campo_def);
                html += '</td>';
                html += '<td style="width: 5%;">';
                html += '<input type="text" name="prefijo_' + i + '" id="prefijo_' + i + '" value="' + datos[i].prefijo + '" style="width: 100%;" />';
                html += '</td>';
                html += '<td style="width: 5%;">';
                html += '<input type="text" name="posfijo_' + i + '" id="posfijo_' + i + '" value="' + datos[i].posfijo + '" style="width: 100%;" />';
                html += '</td>';
                html += '<td style="width: 7.5%;" id="td_ancho_' + i + '">';
                evaluar += 'campos_defs.add("ancho_' + i + '", { nro_campo_tipo: 100, enDB: false, target: "td_ancho_' + i + '" });campos_defs.set_value("ancho_' + i + '", "' + (datos[i].ancho != 0 ? datos[i].ancho : "") + '");';
                html += '</td>';
                html += '<td style="width: 5.5%; text-align: center;">';
                html += '<img alt="eliminar" src="/FW/image/icons/eliminar.png" title="Eliminar" onclick="return eliminar_fila(' + i + ');" style="cursor: pointer;" />&nbsp;';
                html += '<img alt="subir" src="/FW/image/icons/up_a.png" title="Subir" onclick="return subir_fila(' + i + ');" style="cursor: pointer; position: relative; left: 5px; top: -5px;" />';
                html += '<img alt="bajar" src="/FW/image/icons/down_a.png" title="Bajar" onclick="return bajar_fila(' + i + ');" style="cursor: pointer; position: relative; left: -5px; top: 5px;" />';
                html += '<input type="hidden" name="orden_' + i + '" id="orden_' + i + '" value="' + i + '" />';
                html += '</td>';
                html += '</tr>';

                cantidad_valores++;
            }

            $tbValores.select("tbody")[0].insert({ bottom: html });
            eval(evaluar);
            window_onresize();

            nvFW.bloqueo_desactivar(null, "vidrio_cargar");
        }


        function dibujar_select_tipo_dato(name_id, tipo_dato)
        {
            // "arr_tipo_datos" se carga una sola vez
            if (!arr_tipo_dato)
            {
                cargar_select_tipo_dato();
            }

            var seleccionar_item = tipo_dato ? true : false;
            var seleccionado     = '';
            var strHTML          = "<select style='width: 100%;' name='" + name_id + "' id='" + name_id + "' onchange='return tipoDatoOnchange(this.id, this.value);'>";
            strHTML             += "<option value=''></option>";

            for (tipo in arr_tipo_dato)
            {
                var arr      = arr_tipo_dato[tipo];
                seleccionado = seleccionar_item ? (arr.id == tipo_dato ? "selected" : "") : "";
                strHTML += "<option value='" + arr.id + "' " + seleccionado + ">" + arr.campo + " (" + arr.id + ")</option>";
            }

            strHTML += "</select>";
            return strHTML;
        }


        function tipoDatoOnchange(id_elemento, valor)
        {
            var indice       = id_elemento.split("_").last();
            var deshabilitar = valor == "bit" ? true : false;

            $("campo_def_" + indice).disabled = deshabilitar;
            $("prefijo_" + indice).disabled   = deshabilitar;
            $("posfijo_" + indice).disabled   = deshabilitar;
        }


        var arr_campos_defs = null;


        function dibujar_select_campos_defs(name_id, id_campo_def)
        {
            if (!arr_campos_defs)
            {
                cargar_select_campos_defs();
            }

            var seleccionar_item = id_campo_def ? true : false;
            var seleccionado     = '';
            var str_campo_def    = "<select style='width:100%' name='" + name_id + "' id='" + name_id + "'>";
            str_campo_def       += "<option value=''></option>";

            arr_campos_defs.each(function (campo_def)
            {
                seleccionado   = seleccionar_item ? (campo_def.campo_def == id_campo_def.toLowerCase() ? 'selected' : '') : '';
                str_campo_def += "<option value='" + campo_def.campo_def + "' " + seleccionado + " title='" + campo_def.descripcion + "'>" + campo_def.campo_def + "</option>";
            });

            str_campo_def += "</select>";
            return str_campo_def;
        }


        function agregar_valor()
        {
            // En modo Matriz NO se pueden agregar salidas
            if ($('pizarra_matriz').checked)
            {
                alert('No se pueden agregar salidas adicionales en modo "<b>Matriz</b>".');
                return false;
            }

            if (cantidad_valores == MAX_SALIDAS)
            {
                alert("Sólo se pueden agregar hasta <b>" + MAX_SALIDAS + " salidas adicionales</b>.");
                return false;
            }

            // dibujo la nueva fila y la agrego al final
            var pos     = cantidad_valores;
            var evaluar = '';
            var fila    = '';

            // checkear si la posicion a agregar ya esta ocupada (puede ser 0 o 1)
            if ($("tr_" + pos))
            {
                pos = pos == 0 ? 1 : 0;
            }

            fila += '<tr id="tr_' + pos + '">';
            fila += '<td style="width: 7.5%;">';
            fila += '<input type="text" name="id_nro_calc_pizarra_' + pos + '" id="id_nro_calc_pizarra_' + pos + '" value="0" disabled="disabled" style="width: 100%; text-align: center;" />';
            fila += '</td>';
            fila += '<td style="width: 7.5%;">';
            fila += '<input type="text" name="nro_calc_pizarra_' + pos + '" id="nro_calc_pizarra_' + pos + '" value="' + nro_calc_pizarra + '" disabled="disabled" style="width: 100%; text-align: center;" />';
            fila += '</td>';
            fila += '<td style="width: 25%;" id="td_etiqueta_' + pos + '">';
            evaluar += 'campos_defs.add("etiqueta_' + pos + '", { nro_campo_tipo: 104, enDB: false, target: "td_etiqueta_' + pos + '" });';
            fila += '</td>';
            fila += '<td style="width: 17.5%;">';
            fila += dibujar_select_tipo_dato("tipo_dato_" + pos, "");
            fila += '</td>';
            fila += '<td style="width: 17.5%;">';
            fila += dibujar_select_campos_defs("campo_def_" + pos, "");
            fila += '</td>';
            fila += '<td style="width: 5%;">';
            fila += '<input type="text" name="prefijo_' + pos + '" id="prefijo_' + pos + '" value="" style="width: 100%;" />';
            fila += '</td>';
            fila += '<td style="width: 5%;">';
            fila += '<input type="text" name="posfijo_' + pos + '" id="posfijo_' + pos + '" value="" style="width: 100%;" />';
            fila += '</td>';
            fila += '<td style="width: 7.5%;" id="td_ancho_' + pos + '">';
            evaluar += 'campos_defs.add("ancho_' + pos + '", { nro_campo_tipo: 100, enDB: false, target: "td_ancho_' + pos + '" });';
            fila += '</td>';
            fila += '<td style="width: 5.5%; text-align: center;">';
            fila += '<img alt="eliminar" src="/FW/image/icons/eliminar.png" title="Eliminar" onclick="return eliminar_fila(' + pos + ');" style="cursor: pointer;" />&nbsp;';
            fila += '<img alt="subir" src="/FW/image/icons/up_a.png" title="Subir" onclick="return subir_fila(' + pos + ');" style="cursor: pointer; position: relative; left: 5px; top: -5px;" />';
            fila += '<img alt="bajar" src="/FW/image/icons/down_a.png" title="Bajar" onclick="return bajar_fila(' + pos + ');" style="cursor: pointer; position: relative; left: -5px; top: 5px;" />';
            fila += '<input type="hidden" name="orden_' + pos + '" id="orden_' + pos + '" value="' + cantidad_valores + '" />';
            fila += '</td>';
            fila += '</tr>';

            cantidad_valores++;
            $tbValores.select("tbody")[0].insert({ bottom: fila });
            eval(evaluar);
            window_onresize();
        }


        function cancelar()
        {
            ventana.close()
        }


        function aceptar()
        {
            if (!valores_completos())
            {
                alert("El campo <b>Tipo dato</b> es obligatorio. Por favor, verifique que esté seteado.");
                return;
            }

            ventana.options.userData = {
                valores_extra: true,
                valores: obtener_arreglo_valores(),
                xml: get_xml(),
                valores_eliminados: valores_eliminar.length > 0,
                pizarra_cubo: $('pizarra_cubo').checked,
                pizarra_matriz: $('pizarra_matriz').checked
            };

            ventana.close();
        }


        function valores_completos()
        {
            var elemento    = null;
            var es_completo = true;

            for (var i = 0; i < MAX_SALIDAS; i++)
            {
                elemento = $("tipo_dato_" + i);

                if (elemento)
                {
                    if (!elemento.value)
                    {
                        es_completo = false;
                        break;
                    }
                }
            }

            return es_completo;
        }


        function eliminar_fila(posicion)
        {
            var fila = $("tr_" + posicion);

            if (fila)
            {
                var id_valor = $("id_nro_calc_pizarra_" + posicion).value;

                if (id_valor != "0")
                {
                    valores_eliminar.push(id_valor);
                }

                fila.remove();
                cantidad_valores--;
                window_onresize();
            }
        }


        var arr_valores = null;


        function obtener_arreglo_valores()
        {
            arr_valores = [];

            if (cantidad_valores)
            {
                for (var i = 0; i < MAX_SALIDAS; i++)
                {
                    if ($("id_nro_calc_pizarra_" + i))
                    {
                        arr_valores[i] = {};
                        arr_valores[i].id_nro_calc_pizarra = $("id_nro_calc_pizarra_" + i).value;
                        arr_valores[i].nro_calc_pizarra    = $("nro_calc_pizarra_" + i).value;
                        arr_valores[i].prefijo             = $("prefijo_" + i).value;
                        arr_valores[i].posfijo             = $("posfijo_" + i).value;
                        arr_valores[i].tipo_dato           = $("tipo_dato_" + i).value;
                        arr_valores[i].campo_def           = $("campo_def_" + i).value;
                        arr_valores[i].etiqueta            = campos_defs.get_value("etiqueta_" + i);
                        arr_valores[i].ancho               = campos_defs.get_value("ancho_" + i);
                        arr_valores[i].orden               = $("orden_" + i).value;
                    }
                }
            }

            return arr_valores;
        }


        function get_xml()
        {
            if (!arr_valores)
            {
                obtener_arreglo_valores();
            }

            var xml = '<salidas_extra>';

            arr_valores.each(function (valor)
            {
                xml += '<salida id_nro_calc_pizarra="' + valor.id_nro_calc_pizarra +
                    '" nro_calc_pizarra="' + valor.nro_calc_pizarra +
                    '" prefijo="' + valor.prefijo +
                    '" posfijo="' + valor.posfijo +
                    '" tipo_dato="' + valor.tipo_dato +
                    '" campo_def="' + valor.campo_def +
                    '" etiqueta="' + valor.etiqueta +
                    '" ancho="' + valor.ancho +
                    '" orden="' + valor.orden +
                    '" />';
            });

            for (var i = 0; i < valores_eliminar.length; i++)
            {
                xml += '<salida id_nro_calc_pizarra="-' + valores_eliminar[i] + '" nro_calc_pizarra="" prefijo="" posfijo="" tipo_dato="" campo_def="" etiqueta="" ancho="" orden="0" />';
            }

            xml += '</salidas_extra>';
            return xml;
        }


        function bajar_fila(posicion)
        {
            var fila_actual    = $("tr_" + posicion);
            var fila_siguiente = fila_actual.nextElementSibling;

            // verificar que tenga un nodo "hermano" abajo para hacer el swap
            if (fila_siguiente)
            {
                // Verificar que el ID corresponda con una fila del estilo "tr_"
                if (fila_siguiente.id.indexOf("tr_") != -1)
                {
                    fila_siguiente.parentNode.insertBefore(fila_siguiente, fila_actual);
                    // Actualizar orden tal como sale en pantalla
                    actualizar_orden_filas();
                }
            }
        }


        function subir_fila(posicion)
        {
            var fila_actual   = $("tr_" + posicion);
            var fila_anterior = fila_actual.previousElementSibling;

            // verificar que tenga un nodo "hermano" arriba para hacer el swap
            if (fila_anterior)
            {
                // Verificar que el ID corresponda con una fila del estilo "tr_"
                if (fila_anterior.id.indexOf("tr_") != -1)
                {
                    fila_anterior.parentNode.insertBefore(fila_actual, fila_anterior);
                    // Actualizar orden tal como sale en pantalla
                    actualizar_orden_filas();
                }
            }
        }


        function actualizar_orden_filas()
        {
            $$("input[name*=orden_]").forEach(function (orden, index)
            {
                orden.value = index;
            });
        }


        function habilitarOpcionMatriz(habilitar)
        {
            if (habilitar)
            {
                $('pizarra_matriz').disabled = false;
            }
            else
            {
                $('pizarra_matriz').checked  = false;
                $('pizarra_matriz').disabled = true;
            }
        }


        function verificarUsoMatriz(element)
        {
            // Actualizar los datos de la estructura para no hacer lecturas erróneas
            parent.actualizar_vector_definiciones();

            if (element.checked)
            {
                // Verificar que la pizarra este guardada con la estructura generada
                if (!parent.Pizarra.nro_calc_pizarra)
                {
                    alert('Para mostrar los datos como Matriz, primeramente debe generar la estructura necesaria.<br/><br/>Para ello debe tener una única salida y contar sólo con 2 datos, y éstos últimos deben ser obligatoriamente campos defs.');
                    element.checked = false;
                    return;
                }

                // Verificar si hay salidas extras
                if (parent.PizarraExtra.valores.length)
                {
                    alert('Existen salidas extras en la pizarra. Sólo se admite una única salida.');
                    element.checked = false;
                    return;
                }

                // Verificar la cantidad de datos de la estructura
                if (parent.PizarraDef.length < 2 || parent.PizarraDef.length > 2)
                {
                    alert('La estructura de datos de la pizarra para matriz sólo admite 2 datos.');
                    element.checked = false;
                    return;
                }

                // Verificar que los datos de estructura sean campos_defs
                if (!parent.PizarraDef[0].campo_def || parent.PizarraDef[0].tiene_hasta || !parent.PizarraDef[1].campo_def || parent.PizarraDef[1].tiene_hasta)
                {
                    alert('Al menos uno de los datos de la estructura no está definido correctamente como <b>Campo Def</b>. Por favor verifique los valores ingresados.');
                    element.checked = false;
                    return;
                }
            }
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">

    <script type="text/javascript">nvFW.bloqueo_activar($$("body")[0], "vidrio_cargar", "Cargando...");</script>

    <form name="form_valores" id="form_valores" autocomplete="off" style="width: 100%; height: 100%; margin: 0;">
        <div id="divMenu"></div>
        <script type="text/javascript">
            var vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu;
            Menus["vMenu"].alineacion = "centro";
            Menus["vMenu"].estilo = "A";
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc> </Desc></MenuItem>");

            <% If Not bloquear Then %>
            vMenu.loadImage("nuevo", "/FW/image/icons/agregar.png");
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Agregar salida adicional</Desc><Acciones><Ejecutar Tipo='script'><Codigo>agregar_valor()</Codigo></Ejecutar></Acciones></MenuItem>");
            <% End If %>

            vMenu.MostrarMenu();
        </script>

        <table class="tb1 highlightOdd highlightTROver" id="tbCubo">
            <tr>
                <td class="Tit1" colspan="2" style="text-align: center;">Opciones</td>
            </tr>
            <%-- Opción para cubo --%>
            <tr>
                <td style="width: 50px; text-align: center;">
                    <input type="checkbox" name="pizarra_cubo" id="pizarra_cubo" style="cursor: pointer;" title="Si está seleccionado la pizarra se utilizará como CUBO" onchange="habilitarOpcionMatriz(this.checked)" />
                </td>
                <td>
                    <b><span onclick="$('pizarra_cubo').click();" style="cursor: pointer;">Utilizar ésta pizarra como CUBO</span></b>
                </td>
            </tr>
            <%-- Opción para matriz --%>
            <tr>
                <td style="width: 50px; text-align: center;">
                    <input type="checkbox" name="pizarra_matriz" id="pizarra_matriz" style="cursor: pointer;" title="Mostrar datos como Matriz" disabled="disabled" onchange="verificarUsoMatriz(this)" />
                </td>
                <td>
                    <b><span id="spanCkhMatriz" onclick="$('pizarra_matriz').click();" style="cursor: pointer;">Mostrar los datos como una Matriz</span></b>
                </td>
            </tr>
        </table>

         <table class="tb1" id="tbValores">
            <tr>
                <td colspan="9" class="Tit1" style="text-align: center;">Salida Principal</td>
            </tr>
            <tr class="tbLabel">
                <td style="width: 7.5%; text-align: center;">ID</td>
                <td style="width: 7.5%; text-align: center;">Nro</td>
                <td style="width: 25%; text-align: center;">Etiqueta</td>
                <td style="width: 17.5%; text-align: center;">Tipo Dato</td>
                <td style="width: 17.5%; text-align: center;">Campo Def</td>
                <td style="width: 5%; text-align: center;">Prefijo</td>
                <td style="width: 5%; text-align: center;">Posfijo</td>
                <td style="width: 7.5%; text-align: center;">Ancho px</td>
                <td style="width: 5.5%; text-align: center;">-</td>
            </tr>
            <tr id="tr_salida">
                <td>
                    <input type="text" name="id_nro_calc_pizarra" id="id_nro_calc_pizarra" value="-" style="width: 100%; text-align: center;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="nro_calc_pizarra" id="nro_calc_pizarra" value="<% = nro_calc_pizarra %>" style="width: 100%; text-align: center;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="etiqueta" id="etiqueta" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="tipo_dato" id="tipo_dato" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="campo_def" id="campo_def" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="prefijo" id="prefijo" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="posfijo" id="posfijo" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="ancho" id="ancho" value="" style="width: 100%;" disabled="disabled" />
                </td>
                <td>
                    <input type="text" name="accion" id="accion" value="-" style="width: 100%; text-align: center;" disabled="disabled" />
                </td>
            </tr>
            <tr>
                <td colspan="9" class="Tit1" style="text-align: center;">Salidas Adicionales</td>
            </tr>
        </table>

        <div id="divBotones" style="padding: 15px 0px 10px 0px; text-align: center;">
            <div id="divCancelar" style="width: 20%; display: inline-block;"></div>
            <div style="width: 10%; display: inline-block;">&nbsp;</div>
            <div id="divAceptar" style="width: 20%; display: inline-block;"></div>
        </div>
        <script type="text/javascript">
            var vButtonItems = {};

            vButtonItems[0] = {};
            vButtonItems[0].nombre   = "Cancelar";
            vButtonItems[0].etiqueta = "Cancelar";
            vButtonItems[0].imagen   = "";
            vButtonItems[0].onclick  = "return cancelar()";

            vButtonItems[1] = {};
            vButtonItems[1].nombre   = "Aceptar";
            vButtonItems[1].etiqueta = "Aceptar";
            vButtonItems[1].imagen   = "";
            vButtonItems[1].onclick  = "return aceptar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage('agregar', '/FW/image/icons/agregar.png')

            vListButton.MostrarListButton();
        </script>
    </form>
</body>
</html>
