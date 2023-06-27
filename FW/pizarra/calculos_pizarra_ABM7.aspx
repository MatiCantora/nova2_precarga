<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" EnableSessionState="ReadOnly" %>
<%
    Dim modo As String = nvUtiles.obtenerValor("modo", "")
    Dim nro_calc_pizarra As Integer = nvUtiles.obtenerValor("nro_calc_pizarra", 0)
    Dim campo_def As String = nvUtiles.obtenerValor("campo_def", "")
    Dim separador As String = "~~"
    '---------------- Datos para LOGS de pizarra ----------------
    Dim fe_log As String = nvUtiles.obtenerValor("fe_log", "")
    Dim load_from_log As Boolean = If(Not fe_log Is Nothing AndAlso fe_log <> "", True, False)
    Dim login_log As String = ""
    Dim fe_to_show As String = ""

    If load_from_log Then
        login_log = nvUtiles.obtenerValor("login_log", "")  ' Login del operador
        ' Parseo la fecha del Log => "2019-06-10 10:05:22" -> "Lun 10/06/2019 10:05:22"
        Dim fecha As DateTime = nvUtiles.obtenerValor("fe_log", "")
        fe_to_show = StrConv(fecha.ToString("dddd dd/MM/yyyy HH:mm:ss"), VbStrConv.ProperCase)
    End If

    '--------------------------------------------------------------------------------------------------------
    ' Si Request es directa por URL (no por lista de disponibles, desde otro ASPX) => chequear el permiso
    '--------------------------------------------------------------------------------------------------------
    If Request.UrlReferrer Is Nothing AndAlso nro_calc_pizarra <> 0 Then
        Dim strSQL As String = "SELECT dbo.rm_tiene_permiso(b.permiso_grupo, a.nro_permiso_ver) AS tiene_permiso " _
                & " FROM calc_pizarra_cab a " _
                & " INNER JOIN operador_permiso_grupo b ON b.nro_permiso_grupo = a.nro_permiso_grupo " _
                & " WHERE a.nro_calc_pizarra = " & nro_calc_pizarra

        Try
            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

            If Not rs.EOF AndAlso rs.Fields("tiene_permiso").Value = 0 Then
                '------------------- SIN PERMISO => Redireccionar al HOME de Meridiano -------------------
                Dim UrlRedirect As String = Request.Url.GetLeftPart(UriPartial.Authority) & "/" & Request.Url.Segments(1)
                Response.Redirect(UrlRedirect)
            End If

            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If


    If modo <> "" Then
        Dim err As New tError

        Select Case modo.ToLower()

            Case "m"
                Dim strXML As String = nvUtiles.obtenerValor("strXML", "")

                If strXML <> "" Then
                    Try
                        Dim edita_def As Boolean = nvUtiles.obtenerValor("edita_def", "0")
                        Dim edita_det As Boolean = nvUtiles.obtenerValor("edita_det", "0")
                        '------------------------------------------------------------------------------------
                        ' @@@: usamos diferentes SP según el ambito de ejecución:
                        '
                        '   PRODUCCION: calculo_pizarra_abm_v3
                        '   LOCAL:      calculo_pizarra_abm
                        '
                        ' Al final todo tiene que dirigirse al SP "calculo_pizarra_abm" cuando esté todo OK
                        '------------------------------------------------------------------------------------
                        Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("calculo_pizarra_abm", ADODB.CommandTypeEnum.adCmdStoredProc)
                        cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, strXML.Length, strXML)
                        cmd.addParameter("@edita_def", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, , edita_def)
                        cmd.addParameter("@edita_det", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, , edita_det)

                        Dim rs As ADODB.Recordset = cmd.Execute()

                        If Not rs.EOF Then
                            nro_calc_pizarra = rs.Fields("nro_calc_pizarra").Value
                            err.numError = rs.Fields("numError").Value
                            err.mensaje = rs.Fields("mensaje").Value
                            err.titulo = rs.Fields("titulo").Value
                            err.params("nro_calc_pizarra") = nro_calc_pizarra
                        End If

                        nvDBUtiles.DBCloseRecordset(rs)

                        '------------------------ RE-CARGAR permisos de Operador ------------------------
                        nvFW.nvApp.getInstance().operador.cargarPermisos()

                        Me.contents("permiso_edicion_estructura") = edita_def
                        Me.contents("permiso_edicion_detalles") = edita_det
                    Catch ex As Exception
                        err.parse_error_script(ex)
                        err.numError = -1
                        err.mensaje = "Ocurrió un error al intentar obtener la pizarra"
                        err.debug_src = "calculos_pizarra_ABM.aspx::modo=m"
                    End Try

                    err.response()
                End If


            Case "cubo_get_combinaciones"
                Dim combinaciones As String = "var combinaciones=["
                Dim total As Integer = 0
                Dim str_campos_defs As String = nvFW.nvUtiles.obtenerValor("datos", "") ' datos = "campo_def1,campo_def2,campo_defX"

                If str_campos_defs <> "" Then
                    Dim campos_defs() As String = str_campos_defs.Split(",")
                    Dim SQL_campos_defs() As String = {}
                    Dim filtros_XML() As String = {}
                    Dim strSQL As String = ""
                    Dim rs As New ADODB.Recordset

                    For Each cdef_dato As String In campos_defs
                        strSQL = "SELECT filtroXML FROM campos_def WHERE campo_def='" & cdef_dato & "'"

                        Try
                            rs = nvFW.nvDBUtiles.DBExecute(strSQL)

                            If Not rs.EOF Then
                                Array.Resize(SQL_campos_defs, SQL_campos_defs.Length + 1)
                                SQL_campos_defs(SQL_campos_defs.Length - 1) = nvFW.nvXMLSQL.XMLtoSQL(rs.Fields("filtroXML").Value.ToString.Replace("""", ""))
                            End If

                        Catch ex As Exception
                            nvDBUtiles.DBCloseRecordset(rs)
                            err.parse_error_script(ex)
                            err.numError = 105
                            err.mensaje = "Error al recuperar los valores de 'filtroXML' de datos y convertilos a cadenas SQL"
                            err.debug_src = "calculos_pizarra_ABM.aspx::modo=cubo_get_combinaciones"
                            err.response()
                        End Try
                    Next

                    nvDBUtiles.DBCloseRecordset(rs)

                    ' Obtener todos los nombres de tabla y su columna ID desde cada item en "filtros_XML"
                    Dim ids As String = ""
                    Dim tablas As String = ""
                    Dim filtros() As String = {}
                    Dim ini As Integer = 0
                    Dim fin As Integer = 0

                    If SQL_campos_defs.Length > 0 Then
                        For Each cadena As String In SQL_campos_defs
                            cadena = cadena.ToLower()

                            ' Paso 1: obtener ID
                            ini = cadena.IndexOf("distinct ") + "distinct ".Length ' de esta manera dejo el puntero de Inicio justo antes del ID (nombre columna)
                            fin = cadena.IndexOf(" as id") - ini ' asi defino la cantidad de caracteres a extraer
                            ids &= cadena.Substring(ini, fin).Trim() & ","

                            ' Paso 2: obtener TABLA y WHERE (si esta presente)
                            If cadena.IndexOf("where") <> -1 Then
                                '------------- Existe filtroWhere -------------
                                ' Paso 2.1: obtener TABLA
                                ini = cadena.IndexOf("from ") + "from ".Length
                                fin = cadena.IndexOf(" where") - ini
                                tablas &= cadena.Substring(ini, fin).Trim() & ","

                                ' Paso 2.2: obtener WHERE
                                ini = cadena.IndexOf("where ") + "where ".Length
                                fin = If(cadena.IndexOf(" order by") = -1, cadena.Length - ini, cadena.IndexOf(" order by") - ini)
                                Array.Resize(filtros, filtros.Length + 1)
                                filtros(filtros.Length - 1) = cadena.Substring(ini, fin).Trim()
                            Else
                                '------------- Sin filtroWhere -------------
                                ' Paso 2.1: obtener TABLA
                                ini = cadena.IndexOf("from ") + "from ".Length
                                fin = If(cadena.IndexOf(" order by") = -1, cadena.Length - ini, cadena.IndexOf(" order by") - ini)
                                tablas &= cadena.Substring(ini, fin).Trim() & ","
                            End If
                        Next
                    End If

                    ' Quitar comas (',') al final
                    If ids.Length > 0 Then ids = ids.TrimEnd(",")
                    If tablas.Length > 0 Then tablas = tablas.TrimEnd(",")

                    If ids <> "" AndAlso tablas <> "" Then
                        Dim sql_cross_join As String = ""
                        sql_cross_join &= "SELECT " & ids & " FROM " & tablas

                        If filtros.Length = 1 Then
                            sql_cross_join &= " WHERE " & filtros(0)
                        ElseIf filtros.Length > 1 Then
                            sql_cross_join &= " WHERE " & String.Join(" AND ", filtros)
                        End If

                        sql_cross_join &= " ORDER BY " & ids

                        Dim cols() As String = ids.Split(",")

                        Try
                            rs = nvDBUtiles.DBExecute(sql_cross_join)

                            While Not rs.EOF
                                combinaciones &= "["

                                For Each col As String In cols
                                    combinaciones &= "'" & rs.Fields(col).Value & "',"
                                Next

                                combinaciones = combinaciones.TrimEnd(",")
                                combinaciones &= "],"
                                total += 1
                                rs.MoveNext()
                            End While

                            combinaciones = combinaciones.TrimEnd(",")
                            combinaciones &= "];"
                            nvDBUtiles.DBCloseRecordset(rs)
                        Catch ex As Exception
                        End Try
                    End If
                End If

                err.params("combinaciones") = combinaciones
                err.params("total") = total
                err.params("campos_def") = str_campos_defs
                err.numError = 0
                err.debug_src = "calculos_pizarra_ABM.aspx::modo=cubo_get_combinaciones"
                err.response()


            Case "matriz_get_valores_columnas"
                Dim campos_defs As String() = nvFW.nvUtiles.obtenerValor("datos", "").ToString().Split(",")
                Dim valores_filas As String = ""
                Dim valores_filas_desc As String = ""
                Dim valores_columnas As String = ""
                Dim valores_columnas_desc As String = ""

                ' En modo Matriz sólo debe haber 2 campos_defs
                If campos_defs.Length <> 2 Then
                    err.numError = 1
                    err.titulo = "Error"
                    err.mensaje = "La cantidad de campos defs no corresponde con la acción solicitada"
                    err.debug_desc &= "Cantidad de campos_defs: " & campos_defs.Length
                Else
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute("select filtroXML from campos_def where campo_def in ('" & campos_defs(0) & "','" & campos_defs(1) & "')")
                    Dim strSQL As String = ""
                    Dim rs_filtros As ADODB.Recordset
                    Dim pasadaFilas As Boolean = True

                    While Not rs.EOF
                        strSQL = nvXMLSQL.XMLtoSQL(rs.Fields("filtroXML").Value.ToString.Replace("""", ""))
                        rs_filtros = nvDBUtiles.DBExecute(strSQL)

                        While Not rs_filtros.EOF
                            If pasadaFilas Then
                                valores_filas &= rs_filtros.Fields("id").Value & ","
                                valores_filas_desc &= rs_filtros.Fields("campo").Value & " (" & rs_filtros.Fields("id").Value & ")" & separador
                            Else
                                valores_columnas &= rs_filtros.Fields("id").Value & ","
                                valores_columnas_desc &= rs_filtros.Fields("campo").Value & " (" & rs_filtros.Fields("id").Value & ")" & separador
                            End If

                            rs_filtros.MoveNext()
                        End While

                        nvDBUtiles.DBCloseRecordset(rs_filtros)
                        pasadaFilas = False
                        rs.MoveNext()
                    End While

                    nvDBUtiles.DBCloseRecordset(rs)

                    ' Eliminar las comas al final (trailing commas)
                    valores_filas = valores_filas.TrimEnd(",")
                    valores_columnas = valores_columnas.TrimEnd(",")
                    ' Eliminar los caracteres "~~" al final
                    valores_filas_desc = valores_filas_desc.TrimEnd(separador)
                    valores_columnas_desc = valores_columnas_desc.TrimEnd(separador)
                End If

                err.params("valores_filas") = valores_filas
                err.params("valores_filas_desc") = valores_filas_desc
                err.params("valores_columnas") = valores_columnas
                err.params("valores_columnas_desc") = valores_columnas_desc
                err.response()

        End Select
    End If

    Me.contents("nro_calc_pizarra") = nro_calc_pizarra
    Me.contents("id_win") = nvUtiles.obtenerValor("id_win", "")
    '-------------------- FILTROS encriptados para la Pizarra --------------------
    Me.contents("filtroPizarra") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_cab'><campos>*</campos><filtro><habilitada type='igual'>1</habilitada></filtro></select></criterio>")
    Me.contents("filtroPizarraCab_extras") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_cab_def_valores'><campos>*</campos><orden>orden</orden></select></criterio>")
    Me.contents("filtroPizarraDef") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_def'><campos>*</campos></select></criterio>")
    Me.contents("filtroPizarraDet") = nvXMLSQL.encXMLSQL("<criterio><select vista='calc_pizarra_det'><campos>*</campos></select></criterio>")
    Me.contents("filtroCamposDefs") = nvXMLSQL.encXMLSQL("<criterio><select vista='campos_def'><campos>campo_def, descripcion</campos><orden>campo_def, descripcion</orden><filtro><depende_de type='sql'>depende_de is null</depende_de></filtro></select></criterio>")
    Me.contents("filtroDatoTipos") = nvXMLSQL.encXMLSQL("<criterio><select vista='dato_tipos'><campos>id_dato_tipo AS id, nro_campo_tipo, dato_tipo AS campo, adoXML</campos><orden>id_dato_tipo</orden></select></criterio>")
    '-------------------- Filtro pizarra logs --------------------
    Me.contents("filtroPizarraLogs") = nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='sp_pizarra_logs' CommantTimeOut='2500'><parametros><nro_calc_pizarra DataType='int'>" & nro_calc_pizarra & "</nro_calc_pizarra><tabla>%tabla%</tabla><fecha>%fecha%</fecha></parametros><select><filtro></filtro></select></procedure></criterio>")
    '-------------------- Permisos y nombre de pizarra --------------------
    Dim permiso_grupo As String = ""
    Dim nro_permiso_editar As Integer = 0
    Dim calc_pizarra As String = "" ' nombre de la pizarra

    If nro_calc_pizarra <> 0 Then
        Dim strSQL As String = "SELECT TOP 1 b.permiso_grupo, c.permiso AS valor, a.nro_permiso_ver, a.nro_permiso_editar, a.calc_pizarra " _
            & " FROM calc_pizarra_cab a" _
            & " INNER JOIN operador_permiso_grupo b ON b.nro_permiso_grupo = a.nro_permiso_grupo" _
            & " INNER Join verOperador_permisos c ON c.permiso_grupo = b.permiso_grupo" _
            & " WHERE c.operador = dbo.rm_nro_operador() AND a.nro_calc_pizarra = " & nro_calc_pizarra & " AND a.habilitada = 1"
        Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)

        If Not rs.EOF Then
            Me.permiso_grupos.Add(rs.Fields("permiso_grupo").Value, rs.Fields("valor").Value)
            permiso_grupo = rs.Fields("permiso_grupo").Value
            nro_permiso_editar = rs.Fields("nro_permiso_editar").Value
            calc_pizarra = rs.Fields("calc_pizarra").Value
            Me.contents("pizPermiso_grupo") = permiso_grupo
            Me.contents("pizPermiso_nro_editar") = nro_permiso_editar
            Me.contents("pizPermiso_nro_ver") = rs.Fields("nro_permiso_ver").Value
        End If

        nvDBUtiles.DBCloseRecordset(rs)
    End If

    Dim nro_permiso As Integer = 8 ' Permiso para editar estructura Pizarra
    Dim permiso_edicion_estructura As Boolean = nvFW.nvApp.getInstance().operador.tienePermiso("permisos_web5", Math.Pow(2, nro_permiso - 1))
    Dim permiso_edicion_detalles As Boolean = nvFW.nvApp.getInstance().operador.tienePermiso(permiso_grupo, Math.Pow(2, nro_permiso_editar - 1))

    Me.contents("permiso_edicion_estructura") = permiso_edicion_estructura
    Me.contents("permiso_edicion_detalles") = permiso_edicion_detalles
    Me.contents("fe_log") = fe_log
    Me.contents("login_log") = login_log
    Me.contents("load_from_log") = load_from_log
    Me.contents("fe_to_show") = fe_to_show

    '----------------------- Armar el titulo -----------------------
    Dim titulo As String = "Pizarra "

    If Not load_from_log Then
        titulo &= If(calc_pizarra <> "", calc_pizarra, "Nueva")
    Else
        titulo &= "histórica del " & fe_to_show & " por " & login_log
    End If

    '----------------------- Permisos extras -----------------------
    Me.addPermisoGrupo(permiso_grupo)
    Me.addPermisoGrupo("permisos_web5")
    Me.addPermisoGrupo("permisos_nova_admin")
%>
<html>
<head>
    <title><% = titulo %></title>
    <link rel="shortcut icon" href="/FW/image/icons/nv_mutual.ico" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <style type="text/css">
        tr#filtro input[type=text], tr#filtro input[type=number] {
            border: 1px solid #555;
            background-color: #ffffbf;
        }
        #btnFiltrar, #btnResetear {
            float: left;
            width: 68%;
            border: 1px solid #ccc;
        }
        #btnResetear {
            float: right;
            width: 30%;
            background-image: url("/FW/image/icons/eliminar.png");
            background-repeat: no-repeat;
            background-position-x: center;
        }
        #btnFiltrar:hover, #btnFiltrar:focus, #btnResetear:hover, #btnResetear:focus {
            border-color: #555;
            box-shadow: none;
            outline: none;
            cursor: pointer;
        }
        select:disabled {
            background-color: #e9e9e4;
        }
        .btnOrden {
            width: 16px !important;
            height: 16px !important;
        }
        .btnUp {
            position: relative;
            top: -7px;
            left: 3px;
            cursor: pointer;
        }
        .btnDown {
            position: relative;
            top: 1px;
            left: -7px;
            cursor: pointer;
        }
    </style>

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/tScript.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        /*---------------------------------------------------------------------
        | Cambia el estado de un input hacia habilitado / deshabilitado
        |----------------------------------------------------------------------
        | Parametros:
        |   element_id: ID del elemento
        |   habilitar:  true (si), false (no)
        |--------------------------------------------------------------------*/
        function cambiarEstado(element_id, estado)
        {
            $(element_id).disabled = !estado;
        }


        /*---------------------------------------------------------------------
        | Funcion para determinar si un objeto esta vacio
        |--------------------------------------------------------------------*/
        function isEmpty(objeto)
        {
            var is_empty = true;

            for (var key in objeto)
            {
                if (objeto.hasOwnProperty(key))
                {
                    is_empty = false;
                    break;
                }
            }

            return is_empty;
        }


        /*---------------------------------------------------------------------
        | Objeto global tScript.
        | Aquí es usado para convertir Strings a Scripts
        |--------------------------------------------------------------------*/
        var tScript = new tScript();
    </script>

    <script type="text/javascript">
        var winPrincipal     = nvFW.getMyWindow();
        var separador        = '<% = separador %>';
        var Pizarra          = [];
        var PizarraExtra     = [];
        PizarraExtra.valores = [];
        var PizarraDef       = [];
        var PizarraDet       = [];
        var MAX_DATOS        = 11;
        var nro_calc_pizarra = nvFW.pageContents.nro_calc_pizarra;
        var ar_campos_defs   = '';
        var filtro_oculto    = true;
        var trFiltro;
        var isIE             = Prototype.Browser.IE;
        var modo_edicion     = false;
        var filtro_activado  = false;
        var xml_comparacion  = {
            "original": { xml_cab: '', xml_def: '', xml_det: '' },
            "nuevo":    { xml_cab: '', xml_def: '', xml_det: '' }
        };
        var guardar_como  = false;
        var nueva_pizarra = false;
        var recarga_nuevo = false;
        // Elementos para Cache
        var $body;
        var $div_pizarra;
        var $div_pizarra_def;
        var $div_pizarra_det;
        var $divPizarraDet;
        var $divPizarraDef;
        // Extras
        var col_hasta_habilitada = [];
        var cant_datos_ant;
        var table_header = '';
        var matriz = null;
        var detalles_dibujados_como_matriz;
        var valores_campos_filtro = [];
        var ar_tipo_dato;
        var indices_visibles = [];
        var exp_specialChars = /[^0-9A-Za-zñÑ_áéíóú]/g;
        var win_op_avanzadas = null;
        var valores_extra = false;  // para saber si hay que agregar datos al armar el XML que va al SP
        // Resize
        var dif               = isIE ? 5 : 0;
        var divPizarraDatos_h = 0;
        var divPizarraDef_h   = 0;
        var divPizarraDet_h   = 0;
        // Variables para los botones del menu de Pizarra
        var $vMenuPizarras    = null;
        var btn_nuevo;
        var btn_eliminar;
        var btn_op_avanzadas;
        var btn_historico;


        function window_onload()
        {
            // Deshabilitar enter to tab
            nvFW.enterToTab = false;
            // Cache de elementos mas usados
            $body             = $$('body')[0];
            $div_pizarra      = $('div_pizarra');
            $divPizarraDef    = $('divPizarraDef');
            $div_pizarra_def  = $('div_pizarra_def');
            $divPizarraDet    = $('divPizarraDet');
            $div_pizarra_det  = $('div_pizarra_det');
            // Alturas de los menues
            divPizarraDatos_h = $('divPizarraDatos').getHeight();
            divPizarraDef_h   = $divPizarraDef.getHeight();
            divPizarraDet_h   = $divPizarraDet.getHeight();

            if (!nro_calc_pizarra)
            {
                $('txt_nro_calc_pizarra').value = 0;

                setTimeout(function ()
                {
                    pizarra_editar();
                    pizarra_nueva();
                    nvFW.bloqueo_desactivar(null, "bloq_pizarra");
                }, 0);
            }
            else
            {
                // Ocultar contenido de pizarra y definición
                $div_pizarra.hide();
                $divPizarraDef.hide();
                $div_pizarra_def.hide();

                setTimeout(function ()
                {
                    pizarra_cargar();

					// Actualizar el titulo del Menu de pizarra
                    var tituloPizarra = '[' + Pizarra.nro_calc_pizarra + '] ' + Pizarra.calc_pizarra;

                    if (nvFW.pageContents.load_from_log)
                    {
                        tituloPizarra += ' <span style="color: #95ff93;">[Histórico del <b>' + nvFW.pageContents.fe_to_show + '</b> por <b>' + nvFW.pageContents.login_log + '</b>]</span>';
                    }

                    <% If load_from_log Then %>
                    $$('#vMenuPizarras td')[1].innerHTML = tituloPizarra;
                    $div_pizarra.show();
                    $divPizarraDef.show();
                    $div_pizarra_def.show();
                    CargarVidrioBloqueo();
                    <% Else %>
					<% If permiso_edicion_estructura Then %>
                    $$('#vMenuPizarras td')[2].innerHTML = tituloPizarra;
					<% Else %>
                    $$('#vMenuPizarras td')[1].innerHTML = tituloPizarra;
					<% End If %>
					<% End If %>
                }, 0);
            }

            $('campo_def_cab').onchange = campo_def_onchange;
            window_onresize();
        }


        function CargarVidrioBloqueo()
        {
            try
            {
                var heightMenu   = $('divMenuPizarras').getHeight();
                var heightVidrio = $body.getHeight() - heightMenu;

                if (!$('vidrioBloqueoPizarra'))
                {
                    var div   = document.createElement('div');
                    div.id    = 'vidrioBloqueoPizarra';
                    div.title = 'No es posible editar una pizarra histórica';

                    div.setStyle({
                        position: 'absolute',
                        width: '100%',
                        height: heightVidrio + 'px',
                        top: heightMenu + 'px',
                        left: 0,
                        'z-index': 1,
                        cursor: 'not-allowed',
                        'user-select': 'none'
                    });

                    $body.appendChild(div);
                }
                else
                {
                    $('vidrioBloqueoPizarra').show();
                }

                // Agregar el evento WHEEL para el vidrio y hacer scroll en contenedor de detalles
                $('vidrioBloqueoPizarra').addEventListener('wheel', function (event) { $div_pizarra_det.scrollTop += event.deltaY; });
            }
            catch (e) { }
        }


        function campo_def_onchange(evento)
        {
            nvFW.confirm('El campo def de salida ha cambiado. Para evitar inconsistencias en los detalles, se deben limpiar sus valores de salida y recargarlos. ¿Desea continuar con la operación?',
            {
                width: 450,
                height: 120,
                cancelLabel: 'Cancelar',
                onOk: function (ventana)
                {
                    Pizarra.campo_def = evento.srcElement.value;
                    pizarra_limpiar_detalles_salida();
                    ventana.close();
                },
                onCancel: function (ventana)
                {
                    $('campo_def_cab').value = Pizarra.campo_def;
                    ventana.close();
                }
            });
        }


        function pizarra_limpiar_detalles_salida()
        {
            if (Pizarra.matriz)
            {
                var cantidad_valores = matriz.filas.length * matriz.columnas.length;

                for (var i = 1; i <= cantidad_valores; i++)
                {
                    campos_defs.clear('valor_' + i);
                }

                // Limpiar además los combos que ya fueron cargados
                $$('select[id^=cbvalor_]').each(function (selector)
                {
                    selector.length = 0;
                });
            }
            else
            {
                for (var i = 0; i < PizarraDet.length; i++)
                {
                    campos_defs.clear('valor_1_' + i);
                }

                // Limpiar además los combos que ya fueron cargados
                $$('select[id^=cbvalor_1_]').each(function (selector)
                {
                    selector.length = 0;
                });
            }

            actualizar_vector_detalles();
            pizarra_dibujar_detalles();
        }


        function pizarra_cargar()
        {
            // Limpiar todos los arreglos de datos
            Pizarra.length = 0;
            PizarraExtra = 0;
            PizarraExtra.valores = [];
            PizarraDef.length = 0;
            PizarraDet.length = 0;

            if (nro_calc_pizarra != 0)
            {
                pizarra_datos_cargar();
                pizarra_cargar_vector_definiciones();
                $divPizarraDet.show();
                pizarra_cargar_vector_detalles();
            }
            else
            {
                nvFW.bloqueo_activar($body, "bloq_pizarra", "Limpiando pizarra...");

                $("tb_pizarra").hide();
                $divPizarraDef.hide();
                $div_pizarra_def.innerHTML = "";
                $divPizarraDet.hide();
                $div_pizarra_det.innerHTML = "";

                if (!nvFW.pageContents.load_from_log)
                    dibujar_btn_agregar_detalle();

                nvFW.bloqueo_desactivar(null, "bloq_pizarra");
            }

            window_onresize();
        }


        function dibujar_btn_agregar_detalle()
        {
            var html = '<table class="tb1" id="tbBtnAgregarDetalle"><tbody>';
            html += '<tr style="height: 19px;">';
            html += '<td style="text-align: center;">';
            html += '<img alt="agregar" src="/FW/image/icons/agregar.png" onclick="return pizarra_nuevo_detalle(false)" title="Agregar detalle" style="cursor: pointer;" />';
            html += '</td>';
            html += '</tr>';
            html += '</tbody></table>';

            $div_pizarra_det.insert({ bottom: html });
        }


        function pizarra_datos_cargar()
        {
            var rs = new tRS();

            if (nvFW.pageContents.load_from_log)
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraLogs,
                    params: "<criterio><params tabla='cab' fecha='" + nvFW.pageContents.fe_log + "' /></criterio>"
                });
            }
            else {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarra,
                    filtroWhere: "<criterio><select><filtro><nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra></filtro></select></criterio>"
                });
            }

            if (!rs.eof())
            {
                Pizarra.ancho            = rs.getdata('ancho', '');
                Pizarra.auto_ordenada    = rs.getdata('auto_ordenada', 'true').toLowerCase() == 'true';
                Pizarra.calc_pizarra     = rs.getdata('calc_pizarra', '');
                Pizarra.campo_def        = rs.getdata('campo_def', '');
                Pizarra.cubo             = rs.getdata('cubo', 'false').toLowerCase() == 'true';
                Pizarra.etiqueta         = rs.getdata('etiqueta', '');
                Pizarra.matriz           = rs.getdata('matriz', 'false').toLowerCase() == 'true';
                Pizarra.nro_calc_pizarra = rs.getdata('nro_calc_pizarra', '0');
                Pizarra.posfijo          = rs.getdata('posfijo', '');
                Pizarra.prefijo          = rs.getdata('prefijo', '');
                Pizarra.tipo_dato        = rs.getdata('tipo_dato', '');
            }

            $('txt_nro_calc_pizarra').value = Pizarra.nro_calc_pizarra == null ? '' : Pizarra.nro_calc_pizarra;
            $('calc_pizarra').value = Pizarra.calc_pizarra == null ? '' : Pizarra.calc_pizarra;
            $('etiqueta_cab').value = Pizarra.etiqueta == null ? '' : Pizarra.etiqueta;
            $('tipo_dato').value = Pizarra.tipo_dato == null ? '' : Pizarra.tipo_dato;
            $('campo_def_cab').value = Pizarra.campo_def == null ? '' : Pizarra.campo_def;
            $('auto_ordenada').checked = Pizarra.auto_ordenada == null ? true : Pizarra.auto_ordenada;
            $('prefijo').value = Pizarra.prefijo == null ? '' : Pizarra.prefijo;
            $('posfijo').value = Pizarra.posfijo == null ? '' : Pizarra.posfijo;
            $('width_cab').value = Pizarra.ancho == null ? '' : Pizarra.ancho;

            // Lanzar evento "change" de sólo si "tipo_dato" es "bit"
            if (Pizarra.tipo_dato == "bit")
            {
                tipo_dato_onchange("tipo_dato", "bit");
            }

            // Cargar salidas extra de la cabecera
            rs = new tRS();

            if (nvFW.pageContents.load_from_log)
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraLogs,
                    params: "<criterio><params tabla='ext' fecha='" + nvFW.pageContents.fe_log + "' /></criterio>"
                });
            }
            else
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraCab_extras,
                    filtroWhere: "<criterio><select><filtro><nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra></filtro></select></criterio>"
                });
            }

            PizarraExtra = [];
            PizarraExtra.valores = [];
            PizarraExtra.xml = '';

            var indice = 0;

            while (!rs.eof())
            {
                indice = rs.position;
                PizarraExtra.valores[indice] = {};
                PizarraExtra.valores[indice].id_nro_calc_pizarra = rs.getdata("id_nro_calc_pizarra", 0);
                PizarraExtra.valores[indice].nro_calc_pizarra = rs.getdata("nro_calc_pizarra", 0);
                PizarraExtra.valores[indice].prefijo = rs.getdata("prefijo", '');
                PizarraExtra.valores[indice].posfijo = rs.getdata("posfijo", '');
                PizarraExtra.valores[indice].tipo_dato = rs.getdata("tipo_dato", '');
                PizarraExtra.valores[indice].campo_def = rs.getdata("campo_def", '');
                PizarraExtra.valores[indice].etiqueta = rs.getdata("etiqueta", '');
                PizarraExtra.valores[indice].ancho = rs.getdata("ancho") != null && rs.getdata("ancho") != "0" ? rs.getdata("ancho") : "";
                PizarraExtra.valores[indice].orden = rs.getdata("orden", '' + indice);

                rs.movenext();
            }

            generarXML_pizarra_extras();
        }


        function generarXML_pizarra_extras()
        {
            var xml = '<salidas_extra>';

            if (PizarraExtra.valores.length)
            {
                PizarraExtra.valores.each(function (salida)
                {
                    xml += '<salida id_nro_calc_pizarra="' + salida.id_nro_calc_pizarra + '" nro_calc_pizarra="' + salida.nro_calc_pizarra + '" prefijo="' + salida.prefijo + '" posfijo="' + salida.posfijo + '" tipo_dato="' + salida.tipo_dato + '" campo_def="' + salida.campo_def + '" etiqueta="' + salida.etiqueta + '" ancho="' + salida.ancho + '" orden="' + salida.orden + '" />';
                });
            }

            xml += '</salidas_extra>';

            PizarraExtra.xml = xml;
        }


        function pizarra_cargar_vector_definiciones()
        {
            // Actualizar mensaje de bloqueo
            nvFW.bloqueo_msg("bloq_pizarra", "Cargando datos...");

            var i = 0;
            var rs = new tRS();

            if (nvFW.pageContents.load_from_log)
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraLogs,
                    params: "<criterio><params tabla='def' fecha='" + nvFW.pageContents.fe_log + "' /></criterio>"
                });
            }
            else
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraDef,
                    filtroWhere: "<criterio><select><filtro><nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra></filtro></select></criterio>"
                });
            }

            while (!rs.eof())
            {
                PizarraDef[i] = [];
                PizarraDef[i].ancho = rs.getdata('ancho', '');
                PizarraDef[i].calc_pizarra_dato = rs.getdata('calc_pizarra_dato', '');
                PizarraDef[i].campo_def = rs.getdata('campo_def', '');
                PizarraDef[i].dato_orden = rs.getdata('dato_orden', '');
                PizarraDef[i].etiqueta = rs.getdata('etiqueta', '');
                PizarraDef[i].limite = rs.getdata('limite', '');
                PizarraDef[i].prefijo = rs.getdata('prefijo', '');
                PizarraDef[i].posfijo = rs.getdata('posfijo', '');
                PizarraDef[i].tipo_dato_def = rs.getdata('tipo_dato', '');
                PizarraDef[i].tiene_hasta = rs.getdata('tiene_hasta', 'false').toLowerCase() == 'true' ? 1 : 0;

                i++;
                rs.movenext();
            }

            pizarra_dibujar_definiciones();
        }


        function pizarra_dibujar_definiciones()
        {
            $div_pizarra_def.innerHTML = '';

            var strHTML = "<table class='tb1'>";
            strHTML += "<tr class='tbLabel'>";
            strHTML += "<td style='width:4%; text-align: center;'>Orden</td>";
            strHTML += "<td style='width: 14%; text-align: center;'>Etiqueta</td>";
            strHTML += "<td style='width: 14%; text-align: center;'>Dato</td>";
            strHTML += "<td style='width: 15%; text-align: center;'>Tipo Dato</td>";
            strHTML += "<td style='width: 16%; text-align: center;'>Campo Def</td>";
            strHTML += "<td style='width: 7%; text-align: center;'>Prefijo</td>";
            strHTML += "<td style='width: 7%; text-align: center;'>Posfijo</td>";
            strHTML += "<td style='width: 10%; text-align: center;'>Tiene Hasta</td>";
            strHTML += "<td style='width: 10%; text-align: center;'>Ancho px</td>";
            strHTML += "<td style='width: 3%; text-align: center;'>-</td>";
            strHTML += "</tr>";

            var checked = '';

            PizarraDef.each(function (dato, pos)
            {
                checked = '';

                if (dato.tiene_hasta == 1)
                {
                    checked = "checked";
                    col_hasta_habilitada[pos] = true;
                }
                else
                {
                    col_hasta_habilitada[pos] = false;
                }

                strHTML += "<tr>";
                strHTML += "<td>";
                strHTML += "<input type='text' name='dato_orden_" + pos + "' id='dato_orden_" + pos + "' value='" + dato.dato_orden + "' style='width: 100%; text-align: center;' disabled='disabled'/>";
                strHTML += "</td>";
                strHTML += "<td><input type='text' name='etiqueta_" + pos + "' id='etiqueta_" + pos + "' value='" + dato.etiqueta + "' style='width: 100%;'/></td>";
                strHTML += "<td>";
                strHTML += "<input type='text' name='calc_pizarra_dato_" + pos + "' id='calc_pizarra_dato_" + pos + "' value='" + dato.calc_pizarra_dato + "' style='width: 100%'/>";
                strHTML += "</td>";
                strHTML += "<td id='td_tipo_dato_def_" + pos + "'>";

                strHTML += obtener_select_tipoDato('tipo_dato_def_' + pos);

                strHTML += "</td>";
                strHTML += "<td>" + campo_def_cargar(pos, dato.campo_def) + "</td>";
                strHTML += "<td>";
                strHTML += "<input type='text' name='prefijo_" + pos + "' id='prefijo_" + pos + "' value='" + dato.prefijo + "' style='width: 100%'>";
                strHTML += "</td>";
                strHTML += "<td>";
                strHTML += "<input type='text' name='posfijo_" + pos + "' id='posfijo_" + pos + "' value='" + dato.posfijo + "' style='width: 100%'>";
                strHTML += "</td>";
                strHTML += "<td style='text-align: center'>";
                strHTML += "<input type='checkbox' name='tiene_hasta_" + pos + "' id='tiene_hasta_" + pos + "' style='cursor: pointer;' onchange='return checkSelector(this);' " + (Pizarra.cubo || Pizarra.matriz ? 'disabled' : checked) + "/>";
                strHTML += "<select name='limite_" + pos + "' id='limite_" + pos + "' " + (Pizarra.cubo || Pizarra.matriz ? 'disabled' : (checked != "" ? 'disabled' : '')) + ">";
                strHTML += "<option value=''></option>";
                strHTML += "<option value='igual' " + (dato.limite == 'igual' ? 'selected' : '') + ">Igual</option>";
                strHTML += "<option value='min' " + (dato.limite == 'min' ? 'selected' : '') + ">Min</option>";
                strHTML += "<option value='max' " + (dato.limite == 'max' ? 'selected' : '') + ">Max</option>";
                strHTML += "<option value='in' " + (dato.limite == 'in' ? 'selected' : '') + ">In</option>";
                strHTML += "</select>";
                strHTML += "</td>";
                strHTML += "<td>";
                strHTML += "<input type='number' name='width_" + pos + "' id='width_" + pos + "' onkeypress='return valDigito(event, \"-.\");' min='0' style='width: 100%; text-align: right;' value='" + (dato.ancho != undefined ? dato.ancho : '') + "' title='Si ésta Definición tiene \"Hasta\" activado,&#13;el valor ingresado se duplica.&#13;Unidades en pixeles (PX)' />";
                strHTML += "</td>";
                strHTML += "<td style='text-align: center'>";
                strHTML += "<img alt='Eliminar' title='Eliminar Dato' src='/FW/image/icons/eliminar.png' style='cursor: pointer;' onclick='pizarra_eliminar_dato(" + pos + ")' />";
                strHTML += "</td>";
                strHTML += "</tr>";
            });

            strHTML += "</table>";
            $div_pizarra_def.insert({ top: strHTML });
            tipo_dato_def_seleccionar();
        }


        function checkSelector(checkboxElement)
        {
            var select_element = checkboxElement.nextSibling;
            select_element.disabled = checkboxElement.checked ? true : false;
            select_element.value = '';
        }


        function tipo_dato_def_seleccionar()
        {
            PizarraDef.each(function (dato, i)
            {
                if (dato.tipo_dato_def)
                {
                    $('tipo_dato_def_' + i).value = dato.tipo_dato_def;

                    if (dato.tipo_dato_def == "bit")
                    {
                        tipo_dato_onchange('tipo_dato_def_' + i, 'bit');
                    }
                }
            });
        }


        function campo_def_cargar(orden, campo_def)
        {
            if (ar_campos_defs == '')
            {
                ar_campos_defs = [];
                var rs = new tRS();

                /*-------------------------------------------------------------
                | NOTA
                |--------------------------------------------------------------
                | Los campos defs obtenidos a partir de éste filtro son todos 
                | aquellos que no tienen dependencia hacia otro, es decir, que
                | su valor de columna "depende_de" es NULL
                |------------------------------------------------------------*/
                rs.open({
                    filtroXML: nvFW.pageContents.filtroCamposDefs
                });

                while (!rs.eof())
                {
                    ar_campos_defs[rs.position] = [];
                    ar_campos_defs[rs.position].campo_def = rs.getdata('campo_def', '').toLowerCase();
                    ar_campos_defs[rs.position].descripcion = rs.getdata('descripcion', '').toLowerCase();

                    rs.movenext();
                }
            }

            var str_campo_def = "<select style='width:100%' name='campo_def_" + orden + "' id='campo_def_" + orden + "' " + (Pizarra.cubo || Pizarra.matriz ? 'disabled' : '') + ">";
            str_campo_def += "<option value=''></option>";
            var seleccionado = '';

            ar_campos_defs.each(function (arreglo)
            {
                seleccionado = arreglo.campo_def == campo_def.toLowerCase() ? 'selected' : '';
                str_campo_def += "<option value='" + arreglo.campo_def + "' " + seleccionado + " title='" + arreglo.descripcion + "'>" + arreglo.campo_def + "</option>";
            });

            str_campo_def += "</select>";
            return str_campo_def;
        }


        function pizarra_eliminar_dato(indice)
        {
            var i = indice;
            var dato_orden = i + 1;

            if (i == 0 && PizarraDef.length == 1)
            {
                alert('La pizarra debe tener al menos 1 dato');
                return;
            }

            nvFW.confirm("¿Desea eliminar el dato seleccionado?",
            {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win)
                {
                    win.close();
                    return;
                },
                ok: function (win)
                {
                    actualizar_vector_definiciones();
                    actualizar_vector_detalles();

                    var ultimo = PizarraDef.length - 1;

                    PizarraDef.splice(i, 1);

                    if (i != ultimo)
                    {
                        for (var j = i; j < PizarraDef.length; j++)
                        {
                            PizarraDef[j].dato_orden = PizarraDef[j].dato_orden - 1;
                        }
                    }

                    pizarra_dibujar_definiciones();
                    // Limpiar y redibujar los detalles
                    $div_pizarra_det.innerHTML = '';
                    pizarra_dibujar_detalles();

                    try
                    {
                        pizarra_eliminar_dato_detalle();
                    }
                    catch (e) { }

                    win.close();
                }
            });
        }


        function pizarra_cargar_vector_detalles(filtros)
        {
            /*-----------------------------------------------------------------
            | Filtros (opcional)
            |------------------------------------------------------------------
            | Debe venir con el siguiente formato XML:
            |   <nombre_columna type='igual'>valor_buscado</nombre_columna>...
            |----------------------------------------------------------------*/
            var cant_datos = PizarraDef.length;
            var rs = new tRS();
            var orden = 'orden';
            var i = 0;
            var j;
            var contador;
            filtros = filtros || '';

            /*-----------------------------------------------------------------
            | Definir el "orden" correctamente
            |------------------------------------------------------------------
            | AUTO ORDENADA:
            |  ordenar con la columna "orden" como está en la base de datos.
            | Generalmente se arma como una combinación de los valores de todo 
            | el detalle.
            |
            | ORDEN POR USUARIO:
            |  ordenamos con la columna "orden" igual que antes, pero primera-
            | mente la convertimos a integer sino la DB ordena alfabeticamente
            |
            | Por ejemplo: "1,2,10" lo ordena como "1,10,2"  ERROR
            | Si lo convertimos a INT: "1,2,10" => "1,2,10"  OK
            |----------------------------------------------------------------*/
            if (!Pizarra.auto_ordenada)
            {
                orden = 'convert(int, orden)';
            }

            if (nvFW.pageContents.load_from_log)
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraLogs,
                    params: "<criterio><select><filtro></filtro><orden>" + orden + "</orden></select><params tabla='det' fecha='" + nvFW.pageContents.fe_log + "' /></criterio>"
                });
            }
            else
            {
                rs.open({
                    filtroXML: nvFW.pageContents.filtroPizarraDet,
                    filtroWhere: "<criterio><select><filtro><nro_calc_pizarra type='igual'>" + nro_calc_pizarra + "</nro_calc_pizarra>" + filtros + "</filtro><orden>" + orden + "</orden></select></criterio>"
                });
            }

            while (!rs.eof())
            {
                contador = cant_datos;
                PizarraDet[i] = [];
                j = 1;

                while (contador > 0)
                {
                    PizarraDet[i]['dato' + j + '_desde'] = rs.getdata('dato' + j + '_desde', '');

                    if (PizarraDef[j - 1].tiene_hasta == 1)
                    {
                        PizarraDet[i]['dato' + j + '_hasta'] = rs.getdata('dato' + j + '_hasta', '');
                    }

                    contador--;
                    j++;
                }

                PizarraDet[i].id_calc_piz_det = rs.getdata('id_calc_piz_det', 0);
                PizarraDet[i].valor_1 = rs.getdata('pizarra_valor', '');
                PizarraDet[i].valor_2 = rs.getdata('pizarra_valor_2', '');
                PizarraDet[i].valor_3 = rs.getdata('pizarra_valor_3', '');
                PizarraDet[i].orden = rs.getdata('orden', i.toString());

                i++;
                rs.movenext();
            }

            pizarra_dibujar_detalles();
        }


        function pizarra_nueva_definicion()
        {
            actualizar_vector_definiciones();
            var indice = PizarraDef.length;
            cant_datos_ant = indice;

            // Chequeo si estoy en modo Cubo => Matriz
            if (Pizarra.matriz)
            {
                if (cant_datos_ant == 2)
                {
                    alert('<br/>En modo <b>Matriz</b> se pueden tener únicamente dos datos en la estructura.',
                    {
                        title: '<b>Información</b>'
                    });

                    return;
                }
            }

            if (indice >= MAX_DATOS)
            {
                alert('Se pueden agregar hasta ' + MAX_DATOS + ' datos.',
                {
                    title: "<b>Información</b>",
                    width: 300,
                    height: 70
                });

                return;
            }

            var dato_orden = (indice > 0) ? parseInt(PizarraDef[indice - 1].dato_orden) + 1 : 1;

            PizarraDef[indice] = [];
            PizarraDef[indice].dato_orden = dato_orden;
            PizarraDef[indice].etiqueta = '';
            PizarraDef[indice].calc_pizarra_dato = '';
            PizarraDef[indice].tipo_dato_def = '';
            PizarraDef[indice].tiene_hasta = '';
            PizarraDef[indice].campo_def = '';
            PizarraDef[indice].prefijo = '';
            PizarraDef[indice].posfijo = '';
            PizarraDef[indice].ancho = '';

            pizarra_dibujar_definiciones();
            pizarra_nuevo_dato_detalle();
            pizarra_dibujar_detalles();

            window_onresize();
        }


        // Actualizo la cantidad de datos en el detalle
        function pizarra_nuevo_dato_detalle()
        {
            var cant_datos = PizarraDef.length;
            var j = 0;
            var contador = 0;
            var elemento = null;

            PizarraDet.each(function (arreglo, i)
            {
                j = 1;
                contador = cant_datos;

                while (contador > 0)
                {
                    elemento = $('dato' + j + '_desde_' + i);

                    if (elemento)
                    {
                        PizarraDet[i]['dato' + j + '_desde'] = (j <= cant_datos_ant) ? (elemento.type != 'checkbox' ? elemento.value : (elemento.checked ? '1' : '0')) : '';
                    }

                    if (PizarraDef[j - 1].tiene_hasta == 1)
                    {
                        elemento = $('dato' + j + '_hasta_' + i);

                        if (elemento)
                        {
                            PizarraDet[i]['dato' + j + '_hasta'] = (j <= cant_datos_ant) ? (elemento.type != 'checkbox' ? elemento.value : (elemento.checked ? '1' : '0')) : '';
                        }
                    }

                    contador--;
                    j++;
                }

                elemento = $('valor_1_' + i);

                if (elemento)
                {
                    PizarraDet[i].valor_1 = elemento.type != "checkbox" ? elemento.value : (elemento.checked ? "1" : "0");
                }

                elemento = $('valor_2_' + i);

                if (elemento)
                {
                    PizarraDet[i].valor_2 = elemento.type != "checkbox" ? elemento.value : (elemento.checked ? "1" : "0");
                }

                elemento = $('valor_3_' + i);

                if (elemento)
                {
                    PizarraDet[i].valor_3 = elemento.type != "checkbox" ? elemento.value : (elemento.checked ? "1" : "0");
                }
            });
        }


        function pizarra_eliminar_dato_detalle()
        {
            var contador = 0;
            var j = 0;
            var aux = [];
            var tmpElement = null;

            PizarraDet.each(function (arreglo, i)
            {
                j = 1;
                contador = PizarraDef.length;
                aux[i] = [];

                while (contador > 0)
                {
                    if (j == contador)
                    {
                        j++;
                        contador--;
                        continue;
                    }

                    aux[i]['dato' + j + '_desde'] = PizarraDet[i]['dato' + j + '_desde'];
                    aux[i]['dato' + j + '_hasta'] = PizarraDet[i]['dato' + j + '_hasta'];
                    j++;
                    contador--;
                }

                tmpElement             = $('valor_1_' + i);
                aux[i].id_calc_piz_det = $('id_calc_piz_det_' + i).value;
                aux[i].valor_1         = tmpElement.type != "checkbox" ? tmpElement.value : (tmpElement.checked ? "1" : "0");
                tmpElement             = $('valor_2_' + i);

                if (tmpElement)
                {
                    aux[i].valor_2 = tmpElement.type != "checkbox" ? tmpElement.value : (tmpElement.checked ? "1" : "0");
                }

                tmpElement = $('valor_3_' + i);

                if (tmpElement != null)
                {
                    aux[i].valor_3 = tmpElement.type != "checkbox" ? tmpElement.value : (tmpElement.checked ? "1" : "0");
                }

                tmpElement = null;
            });

            PizarraDet = aux;
            pizarra_dibujar_detalles();
        }


        function pizarra_nuevo_detalle()
        {
            if (nueva_pizarra)
            {
                alert("Antes de agregar datos a la pizarra, es necesario <b>guardar</b>.");
                return;
            }

            if (!nvFW.tienePermiso(nvFW.pageContents.pizPermiso_grupo, nvFW.pageContents.pizPermiso_nro_editar))
            {
                alert("No posee el permiso para editar detalles.<br/>Por favor contacte al Administrador del sistema.");
                return;
            }

            if (Pizarra.cubo || Pizarra.matriz)
            {
                alert('En modo <b>cubo</b> o <b>matriz</b> no está permitido agregar detalles.');
                return;
            }

            nvFW.bloqueo_activar($body, "bloq_detalles", "Agregando nuevo detalle...");
            actualizar_vector_detalles();

            var cant_datos = PizarraDef.length;
            var indice = PizarraDet.length;
            var i = 1; // Variable para contar la cantidad de datos

            PizarraDet[indice] = [];
            PizarraDet[indice].id_calc_piz_det = 0;

            while (cant_datos > 0)
            {
                PizarraDet[indice]['dato' + i + '_desde'] = '';
                PizarraDet[indice]['dato' + i + '_hasta'] = '';
                cant_datos--;
                i++;
            }

            PizarraDet[indice].valor_1 = '';
            PizarraDet[indice].valor_2 = '';
            PizarraDet[indice].valor_3 = '';
            PizarraDet[indice].orden   = '-1';

            // Dibujar solo la nueva fila al final
            pizarra_det_dibujar_nueva_fila();
        }


        function get_campo_def_options(campo_def, target, nro_campo_tipo, posicion_fila)
        {
            if (nro_campo_tipo == 0 || nro_campo_tipo == 2)
            {
                // Setear correctamente posicion_fila si esta indefinido
                posicion_fila = posicion_fila || 0;
                // Si ya existe un campo def con el nombre del target => eliminarlo
                var nombre_cdef_custom = target.substr(3, target.length); // inicia desde 3 ya que arranca con "td_"

                if (campos_defs.items[nombre_cdef_custom])
                {
                    campos_defs.remove(nombre_cdef_custom);
                }

                if (!campos_defs.items[campo_def])
                {
                    campos_defs.add(campo_def, { target: "return_html" }); // con este target creo el campo_def y evito un "document.write" que no necesito
                }

                // Obtener las definiciones del campo_def para armar la copia
                var cdef = campos_defs.items[campo_def];

                return {
                    enDB: false,
                    cacheControl: "nvFW",
                    filtroXML: cdef.filtroXML,
                    filtroWhere: cdef.filtroWhere,
                    nro_campo_tipo: nro_campo_tipo == 0 ? cdef.nro_campo_tipo : 2,
                    permite_codigo: cdef.permite_codigo,
                    json: cdef.json,
                    campo_codigo: cdef.campo_codigo,
                    campo_desc: cdef.campo_desc,
                    target: target,
                    despliega: posicion_fila > 7 ? "arriba" : cdef.despliega
                };
            }
            else
            {
                return {
                    enDB: false,
                    nro_campo_tipo: nro_campo_tipo,
                    target: target
                };
            }
        }


        function draw_pre_pos(prefijo, id, posfijo)
        {
            var strHTML = "<table cellspacing='0' cellpadding='0' class='tb1'><tr>";
            strHTML += prefijo && "<td style='padding-left: 5px; padding-right: 5px;' nowrap>" + prefijo + "</td>";
            strHTML += "<td id='" + id + "' style='width: 100%;'></td>";
            strHTML += posfijo && "<td style='padding-left: 5px; padding-right: 5px;' nowrap>" + posfijo + "</td>";
            strHTML += "</tr></table>";

            return strHTML;
        }


        function pizarra_dibujar_detalles()
        {
            // Actualizar mensajes de bloqueo (vidrio)
            nvFW.bloqueo_msg("bloq_pizarra", "Cargando detalles...");
            nvFW.bloqueo_msg("bloq_detalles", "Cargando nuevo detalle...");

            if (Pizarra.matriz)
            {
                obtener_valores_id_campo_def_matriz();  // Dibuja la pizarra en forma de Matriz
            }
            else
            {
                pizarra_dibujar_detalles_lineal();      // Dibuja la pizarra en forma Lineal (estandar)
            }
        }


        function pizarra_dibujar_detalles_lineal()
        {
            var es_cubo = Pizarra.cubo;
            var cant_datos = PizarraDef.length;
            var contador_desde_hasta = 0;
            var limite = '';
            var strHTML = '';
            var j;
            var width;
            var tipo_dato_fecha;
            var tiene_hasta;

            $div_pizarra_det.innerHTML = ''; // limpia el HTML del contenedor de detalles
            strHTML = "<table class='tb1' style='table-layout: fixed;' id='tbDetalles'>";

            /*------------------------------------------------
            | CABECERA DE LA TABLA
            |-----------------------------------------------*/
            strHTML += "<tr class='tbLabel'>";
            strHTML += "<td style='text-align: center; width: 45px;' rowspan='2'>-</td>";

            // PRIMER pasada => armar la fila sin HASTA
            for (var i = 1; i <= cant_datos; i++)
            {
                etiqueta_col = PizarraDef[i - 1].etiqueta || PizarraDef[i - 1].calc_pizarra_dato;
                tiene_hasta = PizarraDef[i - 1].tiene_hasta == 1;
                width = PizarraDef[i - 1].ancho != undefined ? PizarraDef[i - 1].ancho : null;
                tipo_dato_fecha = PizarraDef[i - 1].tipo_dato_def == "datetime";
                limite_label = PizarraDef[i - 1].limite == "max" ? " Hasta" : PizarraDef[i - 1].limite == "min" ? " Desde" : "";

                if (!tiene_hasta)
                {
                    // Dibujar etiqueta con rowspan doble
                    strHTML += "<td rowspan='2' style='text-align: center;" + (width ? 'width: ' + width + 'px;' : (tipo_dato_fecha ? 'width: 110px;' : 'min-width: 50px;')) + "'>" + etiqueta_col + "<br/>" + limite_label + "</td>";
                }
                else
                {
                    // Dibujar etiqueta con colspan doble
                    strHTML += "<td colspan='2' style='text-align: center;" + (width ? 'width: ' + (width * 2) + 'px;' : (tipo_dato_fecha ? 'width: 220px;' : 'min-width: 50px;')) + "'>" + etiqueta_col + "</td>";
                    contador_desde_hasta++;
                }
            }

            // Salida 1
            strHTML += "<td style='text-align: center; background-color: #027FAA !important; " + (Pizarra.ancho ? 'width: ' + Pizarra.ancho + 'px;' : (Pizarra.tipo_dato == 'datetime' ? 'width: 110px;' : 'min-width: 50px;')) + "' rowspan='2'>" + (Pizarra.etiqueta ? Pizarra.etiqueta : "Valor") + "</td>";

            // Salidas Extra (si las hay)
            if (PizarraExtra && PizarraExtra.valores.length)
            {
                PizarraExtra.valores.each(function (salida)
                {
                    strHTML += "<td style='text-align: center; background-color: #027FAA !important; " + (salida.ancho != null ? 'width: ' + salida.ancho + 'px;' : (salida.tipo_dato == 'datetime' ? 'width: 110px;' : 'min-width: 50px;')) + "' rowspan='2'>" + (salida.etiqueta ? salida.etiqueta : "Valor") + "</td>";
                });
            }

            strHTML += "<td id='td_ultimo' style='text-align: center; width: 45px;' rowspan='2'>-</td>";
            strHTML += "</tr>";
            // SEGUNDA pasada => armar la fila con DESDE y HASTA
            strHTML += "<tr class='tbLabel'>";

            // Armar solo las celdas DESDE - HASTA
            for (i = 1; i <= contador_desde_hasta; i++)
            {
                strHTML += "<td style='text-align: center'>Desde</td>";
                strHTML += "<td style='text-align: center'>Hasta</td>";
            }

            strHTML += "</tr>";

            // Cabeceras HTML para el armado del Excel
            table_header = strHTML.replace("<td style='text-align: center; width: 45px;' rowspan='2'>-</td>", "<td style='text-align: center; width: 45px;' rowspan='2'>ID</td>");
            table_header = table_header.replace("<td id='td_ultimo' style='text-align: center; width: 45px;' rowspan='2'>-</td>", "") + "</table>";

            /*------------------------------------------------
            | Fila para filtrado
            |-----------------------------------------------*/
            strHTML += "<tr id='filtro' style='display: none;'>";
            strHTML += "<td style='text-align: center; border: 1px solid #555; background-color: #e9e9e4;'>-</td>";

            var id_input = "";
            var eval_filtro = [];
            var eval_title = [];

            for (var i = 1; i <= cant_datos; i++)
            {
                tiene_hasta = PizarraDef[i - 1].tiene_hasta == 1;
                prefijo = PizarraDef[i - 1].prefijo || "";
                posfijo = PizarraDef[i - 1].posfijo || "";
                campo_def = PizarraDef[i - 1].campo_def || "";
                tipo_dato = PizarraDef[i - 1].tipo_dato_def || "decimal";
                etiqueta = PizarraDef[i - 1].etiqueta;
                id_input = "filtro_dato_" + i;

                // Array de datos a evaluar pos-insertar el HTML
                if (campo_def != "")
                {
                    eval_filtro.push("campos_defs.add('" + id_input + "', get_campo_def_options('" + campo_def + "', 'td_" + id_input + "', 2, 0));");
                }
                else
                {
                    var nro_campo_tipo = +ar_tipo_dato[tipo_dato].nro_campo_tipo;

                    if (nro_campo_tipo != 105)
                    {
                        eval_filtro.push("campos_defs.add('" + id_input + "', get_campo_def_options('', 'td_" + id_input + "', " + nro_campo_tipo + ", 0));");
                    }
                    else
                    {
                        var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='" + id_input + "' id='" + id_input + "' style='cursor: pointer;' /></td></tr></table>";
                        eval_filtro.push("$('td_" + id_input + "').innerHTML = \"" + html + "\";");
                    }
                }

                strHTML += "<td " + (tiene_hasta ? "colspan='2'" : "") + ">";
                strHTML += "<table cellspacing='0' cellpadding='0' class='tb1'><tr>";

                if (prefijo)
                {
                    strHTML += "<td style='padding-left: 5px; padding-right: 5px;' nowrap>" + prefijo + "</td>";
                }

                strHTML += "<td style='width: 100%;' id='td_filtro_dato_" + i + "'></td>"; // el input que va aqui lo insertamos con un eval; de otra manera algunos campos_defs fallan

                if (posfijo)
                {
                    strHTML += "<td style='padding-left: 5px; padding-right: 5px;' nowrap>" + posfijo + "</td>";
                }

                strHTML += "</tr></table>";
                strHTML += "</td>";

                // armo un string para asignar title al input
                eval_title.push("$('" + id_input + "').setAttribute('title', 'Ingrese un valor para el campo " + etiqueta + " (" + tipo_dato + ")');");
                eval_title.push("$('" + id_input + "_desc').setAttribute('title', 'Ingrese un valor para el campo " + etiqueta + " (" + tipo_dato + ")');");
            }

            strHTML += "<td colspan='2'>";
            strHTML += "<table class='tb1' cellpadding='0' cellspacing='0'>";
            strHTML += "<tr>";
            strHTML += "<td style='width: 100%;'>";
            strHTML += "<input type='button' id='btnFiltrar' name='btnFiltrar' onclick='pizarra_filtrar_datos()' title='Aplicar filtro' value='Filtrar' style='width: 100%; padding: 1px;' />";
            strHTML += "</td>";
            strHTML += "<td style='min-width: 45px; max-width: 45px;'>";
            strHTML += "<input type='button' id='btnResetear' name='btnResetear' onclick='pizarra_resetear_filtro()' title='Resetear filtro' value='' style='width: 100%; padding: 1px;' />";
            strHTML += "</td>";
            strHTML += "</tr>";
            strHTML += "</table>";
            strHTML += "</td>";

            // Arreglo para realizar evaluacion de codigo luego de insertar el HTML en el DOM
            var evaluar = [];
            var prefijo = "";
            var posfijo = "";
            var campo_def = "";
            var tipo_dato_def = "";
            var habilitar_hasta = "";
            var nro_campo_tipo = 0;
            var name_desde = "";
            var name_hasta = "";

            // Actualizar valores para la columna VALOR
            var campo_def_valor = Pizarra.campo_def || "";
            var tipo_dato_valor = Pizarra.tipo_dato;
            var prefijo_valor = Pizarra.prefijo || "";
            var posfijo_valor = Pizarra.posfijo || "";
            var habilitar = recarga_nuevo ? false : nvFW.pageContents.permiso_edicion_detalles;
            var contador = 0;

            /*------------------------------------------------
            | CUERPO DE LA TABLA DATOS
            |-----------------------------------------------*/
            PizarraDet.each(function (fila, i)
            {
                if (Number(fila.id_calc_piz_det) > -1)
                {
                    j = 1;
                    contador = cant_datos;
                    strHTML += "<tr class='tr_detalle' id='" + i + "'>";
                    strHTML += "<td>";
                    strHTML += "<input type='text' name='id_calc_piz_det_" + i + "' id='id_calc_piz_det_" + i + "' value='" + fila.id_calc_piz_det + "' style='width: 100%; text-align: center;' disabled />";
                    strHTML += "</td>";

                    while (contador > 0)
                    {
                        // Determinar si definio un campo_def o solamente un tipo
                        campo_def = PizarraDef[j - 1].campo_def || "";
                        tipo_dato_def = PizarraDef[j - 1].tipo_dato_def || "decimal"; // valor por defecto => 'decimal'
                        habilitar_hasta = PizarraDef[j - 1].tiene_hasta == 1;
                        name_desde = "dato" + j + "_desde_" + i;
                        name_hasta = "dato" + j + "_hasta_" + i;
                        nro_campo_tipo = 0;

                        if (!campo_def)
                        {
                            nro_campo_tipo = +ar_tipo_dato[tipo_dato_def].nro_campo_tipo;
                        }

                        prefijo = PizarraDef[j - 1].prefijo;
                        posfijo = PizarraDef[j - 1].posfijo;

                        // Armar las celdas con los campos_defs mas los pre y posfijos
                        strHTML += "<td>" + draw_pre_pos(prefijo, "td_" + name_desde, posfijo) + "</td>";

                        // Si tipo de dato es MONEY => parsear el valor a punto decimal
                        fila["dato" + j + "_desde"] = ["money", "decimal"].indexOf(tipo_dato_def) != -1 && fila["dato" + j + "_desde"] != ""
                            ? parseFloat(fila["dato" + j + "_desde"]).toFixed(2)
                            : fila["dato" + j + "_desde"];

                        if (nro_campo_tipo != 105)
                        {
                            evaluar.push("campos_defs.add('" + name_desde + "', get_campo_def_options('" + campo_def + "', 'td_" + name_desde + "', " + nro_campo_tipo + ", " + i + "));");

                            if (fila["dato" + j + "_desde"] != undefined && fila["dato" + j + "_desde"] != '')
                            {
                                evaluar.push("campos_defs.set_value('" + name_desde + "', " + tScript.string_to_script(fila["dato" + j + "_desde"]) + ", true);");
                            }

                            evaluar.push("campos_defs.habilitar('" + name_desde + "', " + (es_cubo ? false : habilitar) + ");");

                            // Armar columna HASTA
                            if (habilitar_hasta)
                            {
                                strHTML += "<td>" + draw_pre_pos(prefijo, "td_" + name_hasta, posfijo) + "</td>";

                                // Si tipo de dato es MONEY => parsear el valor a punto decimal
                                fila["dato" + j + "_hasta"] = ["money", "decimal"].indexOf(tipo_dato_def) != -1 && fila["dato" + j + "_desde"] != "" ? parseFloat(fila["dato" + j + "_hasta"]).toFixed(2).replace(",", ".") : fila["dato" + j + "_hasta"];

                                evaluar.push("campos_defs.add('" + name_hasta + "', get_campo_def_options('" + campo_def + "', 'td_" + name_hasta + "', " + nro_campo_tipo + "));");

                                if (fila["dato" + j + "_hasta"] != undefined && fila["dato" + j + "_hasta"] != '')
                                {
                                    evaluar.push("campos_defs.set_value('" + name_hasta + "', " + tScript.string_to_script(fila["dato" + j + "_hasta"]) + ", true);");
                                }

                                evaluar.push("campos_defs.habilitar('" + name_hasta + "', " + (es_cubo ? false : habilitar) + ");");
                            }
                        }
                        else
                        {
                            var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='" + name_desde + "' id='" + name_desde + "' style='cursor: pointer;' /></td></tr></table>";
                            evaluar.push("$('td_" + name_desde + "').innerHTML = \"" + html + "\";");
                            evaluar.push("$('" + name_desde + "').checked = " + (fila["dato" + j + "_desde"] != undefined && fila["dato" + j + "_desde"] != "" ? (fila["dato" + j + "_desde"] == "0" ? "false" : "true") : "false") + ";");
                            evaluar.push("cambiarEstado('" + name_desde + "', " + (es_cubo ? false : habilitar) + ");");
                        }

                        contador--;
                        j++;
                    }

                    strHTML += "<td>" + draw_pre_pos(prefijo_valor, "td_valor_1_" + i, posfijo_valor) + "</td>";

                    tipo_dato_valor = Pizarra.tipo_dato;  // update

                    // tipo_dato == MONEY => parsear el valor a punto decimal (porque la coma es separador)
                    fila.valor_1 = ["money", "decimal"].indexOf(tipo_dato_valor) != -1 ? parseFloat(fila.valor_1).toFixed(2).replace(",", ".") : fila.valor_1;

                    nro_campo_tipo = +ar_tipo_dato[Pizarra.tipo_dato].nro_campo_tipo;

                    if (campo_def_valor)
                    {
                        evaluar.push("campos_defs.add('valor_1_" + i + "', get_campo_def_options('" + campo_def_valor + "', 'td_valor_1_" + i + "', 0, " + i + "));");

                        if (fila.valor_1)
                        {
                            evaluar.push("campos_defs.set_value('valor_1_" + i + "', " + tScript.string_to_script(fila.valor_1) + ");");
                        }

                        evaluar.push("campos_defs.habilitar('valor_1_" + i + "', " + habilitar + ");");
                    }
                    else
                    {
                        if (nro_campo_tipo != 105)
                        {
                            evaluar.push("campos_defs.add('valor_1_" + i + "', get_campo_def_options('', 'td_valor_1_" + i + "', " + (+ar_tipo_dato[tipo_dato_valor].nro_campo_tipo) + "));");

                            if (fila.valor_1)
                            {
                                evaluar.push("campos_defs.set_value('valor_1_" + i + "', " + tScript.string_to_script(fila.valor_1) + ");");
                            }

                            evaluar.push("campos_defs.habilitar('valor_1_" + i + "', " + habilitar + ");");
                        }
                        else
                        {
                            // Dibujar un checkbox
                            var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='valor_1_" + i + "' id='valor_1_" + i + "' style='cursor: pointer;' /></td></tr></table>";
                            evaluar.push("$('td_valor_1_" + i + "').innerHTML = \"" + html + "\";");
                            evaluar.push("$('valor_1_" + i + "').checked = " + (fila.valor_1 ? (fila.valor_1 == "0" ? "false" : "true") : "false") + ";");
                            evaluar.push("cambiarEstado('valor_1_" + i + "', " + habilitar + ");");
                        }
                    }

                    // Salidas extra de la pizarra
                    if (PizarraExtra && PizarraExtra["valores"].length)
                    {
                        var extra = null;
                        var index_inicio = 2;

                        // Inicio el indice en 2 hasta el total mas 2; asi se puede usar como subindice para los valores de salida extra
                        for (var ii = index_inicio; ii < PizarraExtra.valores.length + index_inicio; ii++)
                        {
                            extra = PizarraExtra.valores[ii - index_inicio];

                            if (!extra)
                                continue;

                            tipo_dato_valor = extra.tipo_dato;  // actualizacion
                            // Parsear tipo 'money' o 'decimal' a punto decimal
                            fila["valor_" + ii] = ["money", "decimal"].indexOf(tipo_dato_valor) != -1 ? parseFloat(fila["valor_" + ii]).toFixed(2).replace(",", ".") : fila["valor_" + ii];
                            nro_campo_tipo = parseInt(ar_tipo_dato[tipo_dato_valor].nro_campo_tipo);  // actualizacion
                            strHTML += "<td>" + draw_pre_pos(extra.prefijo, "td_valor_" + ii + "_" + i, extra.posfijo) + "</td>";

                            if (extra.campo_def)
                            {
                                evaluar.push("campos_defs.add('valor_" + ii + "_" + i + "', get_campo_def_options('" + extra.campo_def + "', 'td_valor_" + ii + "_" + i + "', 0, " + i + "));");

                                if (fila['valor_' + ii])
                                    evaluar.push("campos_defs.set_value('valor_" + ii + "_" + i + "', " + tScript.string_to_script(fila['valor_' + ii]) + ");");

                                evaluar.push("campos_defs.habilitar('valor_" + ii + "_" + i + "', " + habilitar + ");");
                            }
                            else
                            {
                                if (nro_campo_tipo != 105)
                                {
                                    evaluar.push("campos_defs.add('valor_" + ii + "_" + i + "', get_campo_def_options('', 'td_valor_" + ii + "_" + i + "', " + (+ar_tipo_dato[tipo_dato_valor].nro_campo_tipo) + "));");

                                    if (fila["valor_" + ii])
                                        evaluar.push("campos_defs.set_value('valor_" + ii + "_" + i + "', " + tScript.string_to_script(fila["valor_" + ii]) + ");");

                                    evaluar.push("campos_defs.habilitar('valor_" + ii + "_" + i + "', " + habilitar + ");");
                                }
                                else
                                {
                                    // Dibuja un CHECKBOX
                                    var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='valor_" + ii + "_" + i + "' id='valor_" + ii + "_" + i + "' style='cursor: pointer;' /></td></tr></table>";
                                    evaluar.push("$('td_valor_" + ii + "_" + i + "').innerHTML = \"" + html + "\";");
                                    evaluar.push("$('valor_" + ii + "_" + i + "').checked = " + (fila["valor_" + ii] ? (fila["valor_" + ii] == "0" ? "false" : "true") : "false") + ";");
                                    evaluar.push("cambiarEstado('valor_" + ii + "_" + i + "', " + habilitar + ");");
                                }
                            }
                        }
                    }

                    strHTML += "<td style='text-align: center'>";

                    if (!es_cubo)
                    {
                        strHTML += "<span class='btnOrden' style='" + (Pizarra.auto_ordenada ? "display: none;" : "") + "'>";
                        strHTML += "<img alt='Subir' title='Subir' src='/FW/image/icons/up_a.png' onclick='pizarra_subir_elemento(this, " + i + ");' class='btnUp' />";
                        strHTML += "<img alt='Bajar' title='Bajar' src='/FW/image/icons/down_a.png' onclick='pizarra_bajar_elemento(this, " + i + ");' class='btnDown' />";
                        strHTML += "</span>";
                        strHTML += "<img alt='Eliminar' title='Eliminar Detalle' src='/FW/image/icons/eliminar.png' style='cursor: pointer;' onclick='pizarra_eliminar_detalle(" + i + ", " + habilitar + ")' class='btnDelete' />";
                    }
                    else
                    {
                        strHTML += "&nbsp;";
                    }

                    strHTML += "</td>";
                    strHTML += "</tr>";
                }
            });

            strHTML += "</table>";
            $div_pizarra_det.insert({ top: strHTML });

            if (!Pizarra.cubo && !nvFW.pageContents.load_from_log)
                dibujar_btn_agregar_detalle();

            if (eval_filtro.length > 0)
            {
                eval_filtro.each(function (item)
                {
                    try
                    {
                        eval(item);
                    }
                    catch (e)
                    {
                        console.log('Error filtro: ' + e.message);
                    }
                });

                if (eval_title.length)
                {
                    eval_title.each(function (item)
                    {
                        try
                        {
                            eval(item);
                        }
                        catch (e)
                        {
                            console.log('Error titulos filtro: ' + e.message);
                        }
                    });
                }

                // Agregar los listeners para cada campo filtro
                for (var i = 1, max = PizarraDef.length; i <= max; ++i)
                {
                    $("filtro_dato_" + i).addEventListener("keydown", function (event)
                    {
                        enterToAction(event);
                    }, false);
                }
            }

            if (!evaluar.length)
            {
                nvFW.bloqueo_desactivar(null, "bloq_pizarra");  // Quitar el vidrio si no llego a evaluar nada (no hay datos)
            }
            else
            {
                evaluar.each(function (item)
                {
                    eval(item);
                });

                /*---------------------------------------------------------------------------
                | Si es CUBO => borrar los modificadores del los detalles de campos defs
                | Cada campo_def tiene 3 TD, entonces eliminamos los 2 ultimos
                | que son el que tiene el icono de buscar y el de limpiar
                |
                | Estructura HTML del campo_def:
                | <table>
                |   <tr>
                |     <td>inputs</td>
                |     <td>lupa de busqueda</td>
                |     <td>hoja en blanco para limpiar el campo</td>
                |   </tr>
                | </table>
                |--------------------------------------------------------------------------*/
                if (Pizarra.cubo && !Pizarra.matriz)
                {
                    $$('table[id^=campo_def_tbdato]').each(function (tabla)
                    {
                        tabla.select('td').each(function (td, i)
                        {
                            if (i)
                                td.remove();
                        });
                    });
                }

                setTimeout(function ()
                {
                    nvFW.bloqueo_desactivar(null, "bloq_pizarra");
                    $div_pizarra_det.scrollTop = 0;
                }, 10);

                // Guardar estado original XML datos
                detalles_dibujados_como_matriz = false;
                generarXML();
            }
        }


        function obtener_valores_id_campo_def_matriz()
        {
            if (PizarraDef.length != 2)
            {
                alert("La cantidad de datos para visualizar los detalles como Matriz debe ser de 2.",
                {
                    title: '<b>Info matriz</b>'
                });
                return false;
            }

            nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx',
            {
                bloq_contenedor_on: false,
                parameters: {
                    modo: 'matriz_get_valores_columnas',
                    datos: PizarraDef[0].campo_def + ',' + PizarraDef[1].campo_def
                },
                onSuccess: function (err)
                {
                    matriz = {
                        'filas': err.params.valores_filas.split(','),
                        'filas_desc': err.params.valores_filas_desc.split('~~'),
                        'columnas': err.params.valores_columnas.split(','),
                        'columnas_desc': err.params.valores_columnas_desc.split('~~')
                    };

                    pizarra_det_dibujar_matriz();
                },
                onFailure: function (err)
                {
                    valores_matriz = {};
                    console.log(err.titulo + ': ' + err.mensaje);
                }
            });
        }


        function pizarra_det_dibujar_matriz()
        {
            nvFW.bloqueo_activar($body, "bloq_pizarra_det", "Cargando detalles...");

            /*-----------------------------------------------------------------
            |   En éste caso debemos dibujar en la primer columna todas las
            | combinaciones del dato 1, y en contraposición debemos dibujar
            | en la primer fila todas combinaciones del dato 2.
            |
            |   En el cruce de cada fila-columna van las celdas de la salida.
            |----------------------------------------------------------------*/
            if (!matriz.filas || !matriz.columnas)
            {
                alert('NO fue posible dibujar la pizarra como Matriz debido a que uno de los campos defs no contiene valores.',
                {
                    title: '<b>Info matriz</b>'
                });
                return;
            }

            // Antes de realizar cualquier cosa, actualizamos los vectores de Detalles
            actualizar_vector_detalles();

            // Obtenemos la cantidad de filas / columnas que usaremos para dibujar la tabla
            var cantidad_filas = matriz.filas.length;
            var cantidad_columnas = matriz.columnas.length;
            var cantidad_valores = cantidad_filas * cantidad_columnas; // usado para comprobar

            // Vector con todos los valores de salida
            var salida_valores = [];
            var posicion = 0;

            for (var i = 0; i < cantidad_valores; i++)
            {
                posicion = cantidad_columnas * matriz.filas.indexOf(PizarraDet[i].dato1_desde) + matriz.columnas.indexOf(PizarraDet[i].dato2_desde);
                salida_valores[posicion] = {
                    'id_calc_piz_det': PizarraDet[i].id_calc_piz_det,
                    'orden': PizarraDet[i].orden,
                    'valor': PizarraDet[i].valor_1
                };
            }

            if (!salida_valores.length)
            {
                alert('No fue posible cargar los valores de salida.');
                return;
            }

            // Campos Def
            var campos_defs_evaluar = [];
            $div_pizarra_det.innerHTML = ''; // limpia el HTML del contenedor de detalles
            var strHTML = '<table class="tb1" id="tbDetallesMatriz"><tbody>';

            /*------------------------------------------------
            |                   Cabecera
            |-----------------------------------------------*/
            strHTML += '<tr>';
            strHTML += '<td class="Tit1" colspan="2" rowspan="2">&nbsp;</td>';
            strHTML += '<td class="Tit1" colspan="' + cantidad_columnas + '" style="text-align: center; font-weight: 700;">' + PizarraDef[1].etiqueta + '</td>';
            strHTML += '</tr>';

            /*------------------------------------------------
            |       Cabeceras del Dato 2 (columnas)
            |-----------------------------------------------*/
            strHTML += '<tr>';

            var campo_def_custom = '';

            for (var columna_pos = 0; columna_pos < cantidad_columnas; columna_pos++)
            {
                campo_def_custom = 'dato_columna_' + columna_pos;

                strHTML += '<td>';
                strHTML += '<input type="hidden" name="' + campo_def_custom + '" id="' + campo_def_custom + '" value="' + matriz.columnas[columna_pos] + '" />';
                strHTML += '<input type="text" name="' + campo_def_custom + '_desc" id="' + campo_def_custom + '_desc" value="' + matriz.columnas_desc[columna_pos] + '" readonly="true" disabled="disabled" style="width: 100%;" />';
                strHTML += '</td>';
            }

            strHTML += '</tr>';

            /*------------------------------------------------
            |    Parte de cabeceras (como fila) y salidas
            |-----------------------------------------------*/
            var nro_salida = 1;
            var tipo_dato = Pizarra.tipo_dato;
            var nro_campo_tipo = parseInt(ar_tipo_dato[tipo_dato].nro_campo_tipo);
            var prefijo_valor = Pizarra.prefijo || '';
            var posfijo_valor = Pizarra.posfijo || '';
            var valor = null;
            var campo_defs_valor = Pizarra.campo_def;
            var posicion_array = 0;

            for (var fila_pos = 0; fila_pos < cantidad_filas; fila_pos++)
            {
                strHTML += '<tr>';

                if (fila_pos == 0)
                {
                    strHTML += '<td class="Tit1" rowspan="' + cantidad_filas + '" style="text-align: center; font-weight: 700;">' + PizarraDef[0].etiqueta + '</td>';
                }

                // Tenemos una columna más para el valor de Dato 1
                for (var columna_pos = 0; columna_pos < cantidad_columnas + 1; columna_pos++)
                {
                    if (columna_pos == 0)
                    {
                        campo_def_custom = 'dato_fila_' + fila_pos;

                        strHTML += '<td>';
                        strHTML += '<input type="hidden" name="' + campo_def_custom + '" id="' + campo_def_custom + '" value="' + matriz.filas[fila_pos] + '" />';
                        strHTML += '<input type="text" name="' + campo_def_custom + '_desc" id="' + campo_def_custom + '_desc" value="' + matriz.filas_desc[fila_pos] + '" readonly="true" disabled="disabled" style="width: 100%;" />';
                        strHTML += '</td>';
                    }
                    else
                    {
                        /*-------------------------------------------
                        |       Celdas de Valores (salida)
                        |------------------------------------------*/
                        posicion_array = nro_salida - 1;
                        id_td = 'td_valor' + nro_salida;
                        strHTML += '<td>';
                        strHTML += draw_pre_pos(prefijo_valor, id_td, posfijo_valor);
                        strHTML += '<input type="hidden" name="id_calc_piz_det_' + nro_salida + '" id="id_calc_piz_det_' + nro_salida + '" value="' + salida_valores[posicion_array].id_calc_piz_det + '" />';
                        strHTML += '<input type="hidden" name="orden_' + nro_salida + '" id="orden_' + nro_salida + '" value="' + salida_valores[posicion_array].orden + '" />';
                        strHTML += '</td>';
                        valor = ['money', 'decimal'].indexOf(tipo_dato) != -1 && salida_valores[posicion_array].valor ? parseFloat(salida_valores[posicion_array].valor).toFixed(2).replace(',', '.') : salida_valores[posicion_array].valor;
                        campo_def_custom = 'valor_' + nro_salida;

                        if (Pizarra.campo_def)
                        {
                            campos_defs_evaluar.push('campos_defs.add("' + campo_def_custom + '", get_campo_def_options("' + campo_defs_valor + '", "' + id_td + '", "0", 0));');

                            if (valor)
                            {
                                campos_defs_evaluar.push('campos_defs.set_value("' + campo_def_custom + '", ' + tScript.string_to_script(valor) + ');');
                            }
                        }
                        else
                        {
                            if (nro_campo_tipo != 105)
                            {
                                campos_defs_evaluar.push('campos_defs.add("' + campo_def_custom + '", get_campo_def_options("", "' + id_td + '", ' + nro_campo_tipo + '));');

                                if (valor)
                                {
                                    campos_defs_evaluar.push('campos_defs.set_value("' + campo_def_custom + '", ' + tScript.string_to_script(valor) + ');');
                                }
                            }
                            else
                            {
                                // Dibujar un checkbox
                                var html = '<table class="tb1"><tr><td style="text-align: center;"><input type="checkbox" name="' + campo_def_custom + '" id="' + campo_def_custom + '" style="cursor: pointer;" /></td></tr></table>';
                                campos_defs_evaluar.push('$("' + id_td + '").innerHTML = \'' + html + '\';');
                                campos_defs_evaluar.push('$("' + id_td + '").checked = ' + (valor ? (valor == '0' ? 'false' : 'true') : 'false') + ';');
                            }
                        }

                        nro_salida++;
                    }
                }

                strHTML += '</tr>';
            }

            if (nro_salida - 1 != cantidad_valores)
            {
                alert('Cantidad de salidas incorrectas');
                return;
            }

            strHTML += '</tbody></table>';
            $div_pizarra_det.innerHTML = strHTML;
            detalles_dibujados_como_matriz = true;

            if (campos_defs_evaluar.length)
            {
                campos_defs_evaluar.each(function (sentencia_campo_def)
                {
                    eval(sentencia_campo_def);
                });
            }

            generarXML();
            nvFW.bloqueo_desactivar(null, "bloq_pizarra");
            nvFW.bloqueo_desactivar(null, "bloq_pizarra_det");
        }


        function pizarra_det_dibujar_nueva_fila()
        {
            nvFW.bloqueo_msg("bloq_detalles", "Cargando nuevo detalle...");   // Actualizar mensajes de bloqueo

            var cant_datos = PizarraDef.length;
            var i = PizarraDet.length - 1;
            var j = 1;
            // Capturar el elemento donde insertar la nueva fila
            var containerDetalles = $div_pizarra_det.select('#tbDetalles > tbody')[0];
            // HTML de salida
            var strHTML = "<tr class='tr_detalle' id='" + i + "'>";
            // Variable para realizar evaluacion de codigo luego de insertar el HTML en el DOM
            var eval_cdef = [];
            var prefijo = "";
            var posfijo = "";
            var campo_def = "";
            var tipo_dato_def = "";
            var habilitar_hasta = "";
            var nro_campo_tipo = 0;
            var name_desde = "";
            var name_hasta = "";
            // Actualizar valores para la columna VALOR
            var campo_def_valor = Pizarra.campo_def || "";
            var tipo_dato_valor = Pizarra.tipo_dato;
            var prefijo_valor = Pizarra.prefijo || "";
            var posfijo_valor = Pizarra.posfijo || "";
            var cant_salidas_extra = PizarraExtra.valores.length;
            var habilitar = recarga_nuevo ? false : nvFW.pageContents.permiso_edicion_detalles;

            /*------------------------------------------------
            | NUEVA FILA
            |-----------------------------------------------*/
            var arreglo = PizarraDet[PizarraDet.length - 1];

            if (arreglo.id_calc_piz_det == 0)
            {
                strHTML += "<td>";
                strHTML += "<input type='text' name='id_calc_piz_det_" + i + "' id='id_calc_piz_det_" + i + "' value='0' style='width: 100%; text-align: center;' disabled />";
                strHTML += "</td>";

                while (cant_datos > 0)
                {
                    // Determinar si definio un campo_def o solamente un tipo
                    campo_def = PizarraDef[j - 1].campo_def || "";
                    tipo_dato_def = PizarraDef[j - 1].tipo_dato_def || "decimal"; // valor por defecto => 'decimal'
                    habilitar_hasta = PizarraDef[j - 1].tiene_hasta == 1;
                    name_desde = "dato" + j + "_desde_" + i;
                    name_hasta = "dato" + j + "_hasta_" + i;
                    nro_campo_tipo = 0;

                    if (!campo_def)
                    {
                        nro_campo_tipo = +ar_tipo_dato[tipo_dato_def].nro_campo_tipo;
                    }

                    prefijo = PizarraDef[j - 1].prefijo;
                    posfijo = PizarraDef[j - 1].posfijo;

                    // Armar las celdas con los campos_defs mas los pre y posfijos
                    strHTML += "<td>" + draw_pre_pos(prefijo, "td_" + name_desde, posfijo) + "</td>";

                    if (nro_campo_tipo != 105)
                    {
                        eval_cdef.push("campos_defs.add('" + name_desde + "', get_campo_def_options('" + campo_def + "', 'td_" + name_desde + "', " + nro_campo_tipo + ", " + i + "));");

                        // ¿Habilitar columna HASTA?
                        if (habilitar_hasta)
                        {
                            strHTML += "<td>" + draw_pre_pos(prefijo, "td_" + name_hasta, posfijo) + "</td>";
                            eval_cdef.push("campos_defs.add('" + name_hasta + "', get_campo_def_options('" + campo_def + "', 'td_" + name_hasta + "', " + nro_campo_tipo + "));");
                        }
                    }
                    else
                    {
                        var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='" + name_desde + "' id='" + name_desde + "' style='cursor: pointer;' /></td></tr></table>";
                        eval_cdef.push("$('td_" + name_desde + "').innerHTML = \"" + html + "\";");
                    }

                    cant_datos--;
                    j++;
                }

                strHTML += "<td>" + draw_pre_pos(prefijo_valor, "td_valor_1_" + i, posfijo_valor) + "</td>";

                campo_def_valor = Pizarra.campo_def || "";    // update
                tipo_dato_valor = Pizarra.tipo_dato;          // update

                if (campo_def_valor)
                {
                    eval_cdef.push("campos_defs.add('valor_1_" + i + "', get_campo_def_options('" + campo_def_valor + "', 'td_valor_1_" + i + "', 0, " + i + "));");
                }
                else
                {
                    nro_campo_tipo = +ar_tipo_dato[Pizarra.tipo_dato].nro_campo_tipo;

                    if (nro_campo_tipo != 105)
                    {
                        eval_cdef.push("campos_defs.add('valor_1_" + i + "', get_campo_def_options('', 'td_valor_1_" + i + "', " + (+ar_tipo_dato[tipo_dato_valor].nro_campo_tipo) + "));");
                    }
                    else
                    {
                        var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='valor_1_" + i + "' id='valor_1_" + i + "' style='cursor: pointer;' /></td></tr></table>";
                        eval_cdef.push("$('td_valor_1_" + i + "').innerHTML = \"" + html + "\";");
                    }
                }

                // Salidas extra
                if (cant_salidas_extra)
                {
                    var salida = null;
                    var index_inicio = 2;

                    // Inicio el indice en 2 hasta el total mas 2; asi se puede usar como subindice para los valores de salida extra
                    for (var ii = index_inicio; ii < cant_salidas_extra + index_inicio; ii++)
                    {
                        salida = PizarraExtra.valores[ii - index_inicio];

                        if (!salida) continue;

                        tipo_dato_valor = salida.tipo_dato;   // update
                        nro_campo_tipo = parseInt(ar_tipo_dato[tipo_dato_valor].nro_campo_tipo);  // update
                        strHTML += "<td>" + draw_pre_pos(salida.prefijo, "td_valor_" + ii + "_" + i, salida.posfijo) + "</td>";

                        if (salida.campo_def)
                        {
                            eval_cdef.push("campos_defs.add('valor_" + ii + "_" + i + "', get_campo_def_options('" + salida.campo_def + "', 'td_valor_" + ii + "_" + i + "', 0, " + i + "));campos_defs.habilitar('valor_" + ii + "_" + i + "', " + habilitar + ");");
                        }
                        else
                        {
                            if (nro_campo_tipo != 105)
                            {
                                eval_cdef.push("campos_defs.add('valor_" + ii + "_" + i + "', get_campo_def_options('', 'td_valor_" + ii + "_" + i + "', " + (+ar_tipo_dato[tipo_dato_valor].nro_campo_tipo) + "));campos_defs.habilitar('valor_" + ii + "_" + i + "', " + habilitar + ");");
                            }
                            else
                            {
                                // Dibuja un CHECKBOX
                                var html = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='valor_" + ii + "_" + i + "' id='valor_" + ii + "_" + i + "' style='cursor: pointer;' /></td></tr></table>";
                                eval_cdef.push("$('td_valor_" + ii + "_" + i + "').innerHTML = \"" + html + "\";");
                                eval_cdef.push("cambiarEstado('valor_" + ii + "_" + i + "', " + habilitar + ");");
                            }
                        }
                    }
                }

                strHTML += "<td style='text-align: center'>";
                strHTML += "<span class='btnOrden' style='" + (Pizarra.auto_ordenada ? "display: none;" : "") + "'>";
                strHTML += "<img alt='Subir' title='Subir' src='/FW/image/icons/up_a.png' onclick='pizarra_subir_elemento(this, " + i + ");' class='btnUp' />";
                strHTML += "<img alt='Bajar' title='Bajar' src='/FW/image/icons/down_a.png' onclick='pizarra_bajar_elemento(this, " + i + ");' class='btnDown' />";
                strHTML += "</span>";
                strHTML += "<img alt='Eliminar' title='Eliminar Detalle' src='/FW/image/icons/eliminar.png' style='cursor: pointer;' onclick='pizarra_eliminar_detalle(" + i + ", " + habilitar + ")' class='btnDelete' />";
                strHTML += "</td>";
            }

            strHTML += "</tr>";

            containerDetalles.insert({ bottom: strHTML });  // Insertar el HTML con la nueva fila

            // Ejecutar los diferentes eval() para cargar los nuevos campos_defs
            if (!eval_cdef.length)
            {
                nvFW.bloqueo_desactivar(null, "bloq_detalles"); // Quitar el vidrio si no llego a evaluar nada (no hay datos)
            }
            else
            {
                eval_cdef.each(function (item)
                {
                    eval(item);
                });

                setTimeout(function ()
                {
                    nvFW.bloqueo_desactivar(null, "bloq_detalles");
                }, 10);
            }
        }


        function pizarra_subir_elemento(element)
        {
            var fila_actual = element.up('tr.tr_detalle');
            var fila_anterior = fila_actual.previous('tr.tr_detalle');

            if (!fila_anterior)
                return false;

            fila_actual.parentNode.insertBefore(fila_actual, fila_anterior);
            pizarra_actualizar_orden();
        }


        function pizarra_bajar_elemento(element)
        {
            var fila_actual = element.up('tr.tr_detalle');
            var fila_posterior = fila_actual.next('tr.tr_detalle');

            if (!fila_posterior)
                return false;

            fila_actual.parentNode.insertBefore(fila_posterior, fila_actual);
            pizarra_actualizar_orden();
        }


        function showHideOrdenar(checkbox)
        {
            if (!checkbox.checked)
            {
                $$('.btnOrden').invoke('show');
                pizarra_actualizar_orden();
            }
            else
            {
                $$('.btnOrden').invoke('hide');
            }
        }


        function pizarra_actualizar_orden()
        {
            $$('.tr_detalle').each(function (fila, i)
            {
                PizarraDet[fila.id].orden = '' + i;
            });
        }


        function pizarra_eliminar_detalle(indice, habilitar)
        {
            habilitar = !habilitar ? false : habilitar;
            top.indice = indice;

            if (!habilitar)
                return;

            if (indice == 0 && PizarraDet.length == 1)
            {
                alert('La pizarra debe tener al menos 1 detalle');
                return;
            }

            nvFW.confirm("¿Desea eliminar el detalle seleccionado?",
            {
                width: 300,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win)
                {
                    win.close();
                    return;
                },
                ok: function (win)
                {
                    var i = top.indice;
                    actualizar_vector_detalles();

                    // Poner ID detalle en negativo para que sea eliminado al guardar
                    PizarraDet[i].id_calc_piz_det = '-' + PizarraDet[i].id_calc_piz_det;

                    if (Number(PizarraDet[i].id_calc_piz_det) == 0)
                    {
                        PizarraDet.splice(i, 1);
                    }

                    if (!filtro_activado)
                    {
                        pizarra_dibujar_detalles();
                    }
                    else
                    {
                        /*-----------------------------------
                        | Salvar los valores de filtrado
                        |----------------------------------*/
                        valores_campos_filtro.length = 0;

                        for (var i = 1, max = PizarraDef.length; i <= max; i++)
                        {
                            valores_campos_filtro.push($F("filtro_dato_" + i));
                        }

                        pizarra_dibujar_detalles(); // Re-dibujar los Detalles

                        // Aplicar el filtrado
                        if (valores_campos_filtro.length)
                        {
                            for (var i = 1, max = PizarraDef.length; i <= max; i++)
                            {
                                if (valores_campos_filtro[i - 1])
                                {
                                    campos_defs.set_value("filtro_dato_" + i, tScript.string_to_script(valores_campos_filtro[i - 1]));
                                }
                            }

                            // Muestro los campos de filtrado
                            filtro_oculto = true;
                            pizarra_ver_filtro();
                            pizarra_filtrar_datos();  // Lanzar la funcion de filtrado
                        }
                    }

                    win.close();
                }
            });
        }


        function actualizar_vector_definiciones()
        {
            if (PizarraDef.length)
            {
                PizarraDef.each(function (detalle, i)
                {
                    detalle.etiqueta = $('etiqueta_' + i).value;
                    detalle.calc_pizarra_dato = $('calc_pizarra_dato_' + i).value;
                    detalle.tipo_dato_def = $('tipo_dato_def_' + i).value;
                    detalle.tiene_hasta = $('tiene_hasta_' + i).checked == true ? 1 : 0;
                    detalle.limite = $('limite_' + i).value;
                    detalle.campo_def = $('campo_def_' + i).value;
                    detalle.prefijo = $('prefijo_' + i).value;
                    detalle.posfijo = $('posfijo_' + i).value;
                    detalle.ancho = $('width_' + i).value;
                });
            }
        }


        function actualizar_vector_detalles()
        {
            var datos_completos = true;    // Flag para verificar si todos los detalles estan completos
            var cant_salidas_extra = !PizarraExtra.valores ? 0 : PizarraExtra.valores.length;
            var cant_datos = PizarraDef.length;
            var contador = 0;
            var j = 0;
            var tmpElement = null;    // Elemento temporal utilizado para no realizar multiples llamadas al mismo elemento bajo análisis
            var recorrer_como_matriz = detalles_dibujados_como_matriz == undefined ? false : detalles_dibujados_como_matriz;

            /*---------------------------------------------
            | Recolección de datos linealmente
            |--------------------------------------------*/
            if (!recorrer_como_matriz)
            {
                PizarraDet.each(function (detalle, i)
                {
                    contador = cant_datos;
                    j = 1;

                    while (contador > 0)
                    {
                        if (detalle.id_calc_piz_det >= 0)
                        {
                            tmpElement = $('dato' + j + '_desde_' + i);

                            if (tmpElement)
                            {
                                detalle['dato' + j + '_desde'] = tmpElement.type != 'checkbox' ? tmpElement.value : (tmpElement.checked == true ? '1' : '0');

                                if (tmpElement.type != 'checkbox' && tmpElement.value == "")
                                {
                                    datos_completos = false;
                                }

                                if (PizarraDef[j - 1].tiene_hasta == 1)
                                {
                                    tmpElement = $('dato' + j + '_hasta_' + i);
                                    detalle['dato' + j + '_hasta'] = tmpElement.type != 'checkbox' ? tmpElement.value : (tmpElement.checked == true ? '1' : '0');

                                    if (tmpElement.type != 'checkbox' && tmpElement.value == "")
                                    {
                                        datos_completos = false;
                                    }
                                }
                            }
                        }

                        contador--;
                        j++;
                    }

                    if (Number(detalle.id_calc_piz_det) > -1)
                    {
                        tmpElement = $('valor_1_' + i);

                        if (tmpElement)
                        {
                            detalle.valor_1 = tmpElement.type != "checkbox" ? tmpElement.value : tmpElement.checked ? "1" : "0";

                            if (tmpElement.type != "checkbox" && tmpElement.value == "")
                            {
                                datos_completos = false;
                            }
                        }

                        tmpElement = $('valor_2_' + i);

                        if (tmpElement)
                        {
                            detalle.valor_2 = tmpElement.type != "checkbox" ? tmpElement.value : tmpElement.checked ? "1" : "0";

                            if (tmpElement.type != "checkbox" && tmpElement.value == "")
                            {
                                datos_completos = false;
                            }
                        }

                        tmpElement = $('valor_3_' + i);

                        if (tmpElement)
                        {
                            detalle.valor_3 = tmpElement.type != "checkbox" ? tmpElement.value : tmpElement.checked ? "1" : "0";

                            if (tmpElement.type != "checkbox" && tmpElement.value == "")
                            {
                                datos_completos = false;
                            }
                        }

                        // Sin salidas extra => vaciar "valor_2" y "valor_3"
                        if (!cant_salidas_extra)
                        {
                            detalle.valor_2 = '';
                            detalle.valor_3 = '';
                        }
                        // Con solo 1 salida extra => vaciar "valor_3"
                        else if (cant_salidas_extra == 1)
                        {
                            detalle.valor_3 = '';
                        }

                        tmpElement = $('orden_' + i);

                        if (tmpElement)
                        {
                            detalle.orden = tmpElement.value;
                        }
                    }

                    tmpElement = null;
                });
            }
            /*---------------------------------------------
            | Recolección de datos desde matriz
            |--------------------------------------------*/
            else
            {
                var datos_detalle = [];
                var detalle = [];
                var posicion = 1;

                // Recorrer 1ro por filas y luego por columnas
                for (var fila = 0; fila < matriz.filas.length; fila++)
                {
                    for (var columna = 0; columna < matriz.columnas.length; columna++)
                    {
                        detalle = [];
                        detalle.dato1_desde = matriz.filas[fila];
                        detalle.dato2_desde = matriz.columnas[columna];
                        detalle.id_calc_piz_det = $('id_calc_piz_det_' + posicion).value;
                        detalle.orden = $('orden_' + posicion).value;
                        detalle.valor_1 = $('valor_' + posicion).value;
                        detalle.valor_2 = '';
                        detalle.valor_3 = '';

                        if (!detalle.valor_1)
                        {
                            datos_completos = false;
                        }

                        // Guardar en "datos_detalle"
                        datos_detalle.push(detalle);
                        posicion++;
                    }
                }

                // Actualizar PizarraDet
                if (PizarraDet.length == datos_detalle.length)
                {
                    PizarraDet = datos_detalle;
                }
            }

            return datos_completos;
        }


        function pizarra_guardar_como()
        {
            nvFW.confirm("¿Desea guardar una nueva versión de la pizarra actual (<b>" + $("calc_pizarra").value + "</b>)?",
            {
                title: "<b>Guardar como...</b>",
                width: 350,
                height: 100,
                okLabel: "Si",
                cancelLabel: "No",
                minimizable: false,
                closable: false,
                maximizable: false,
                async: true,
                onCancel: function (win)
                {
                    win.close();
                    return;
                },
                onOk: function (win)
                {
                    win.close();
                    nvFW.confirm('<table class="tb1"><tr><td>&nbsp;</td></tr><tr><td><input type="text" name="nombrePizarra" id="nombrePizarra" style="width: 99%;" title="Ingrese el nuevo nombre de pizarra" /></td></tr></table>',
                    {
                        title: "<b>Ingrese el nombre de la pizarra</b>",
                        width: 350,
                        height: 100,
                        okLabel: "Aceptar",
                        cancelLabel: "Cancelar",
                        minimizable: false,
                        closable: false,
                        maximizable: false,
                        onCancel: function (win)
                        {
                            win.close();
                            return;
                        },
                        onOk: function (win)
                        {
                            nro_calc_pizarra = 0;
                            guardar_como = true;
                            $("nombrePizarra").value != "" ? pizarra_guardar_wrapper($("nombrePizarra").value) : pizarra_guardar_wrapper();
                            win.close();
                        },
                        onShow: function ()
                        {
                            $("nombrePizarra").focus();
                        }
                    });
                }
            });
        }


        function pizarra_guardar_wrapper(nuevo_nombre_pizarra)
        {
            if (nro_calc_pizarra != 0)
            {
                pizarra_guardar(nuevo_nombre_pizarra);
            }
            // ALTA de pizarra (nro_calc_pizarra == 0) => verificar NOMBRE y TIPO_DATO
            else
            {
                if (!$("calc_pizarra").value)
                {
                    alert("Ingrese un nombre para la pizarra");
                    nvFW.bloqueo_desactivar(null, "guardar");
                    return false;
                }

                if (!$("tipo_dato").value)
                {
                    alert("Debe seleccionar un tipo de dato para la pizarra");
                    nvFW.bloqueo_desactivar(null, "guardar");
                    return false;
                }

                if (nvFW.tienePermiso("permisos_nova_admin", 4))
                {
                    // Consultar si desea asignarse permisos a su perfil para Ver y/o Editar
                    var win_auto_asignarse_permisos = nvFW.createWindow({
                        url: "/FW/pizarra/calculos_pizarra_asignarse_permisos.aspx",
                        title: "<b>Auto-Asignación de permisos</b>",
                        width: 450,
                        height: 170,
                        maximizable: false,
                        resizable: false,
                        destroyOnClose: true,
                        onClose: function (win)
                        {
                            if (win.options)
                            {
                                if (win.options.userData)
                                {
                                    pizarra_guardar(win.options.userData.nuevo_nombre_pizarra, win.options.userData.perfil_permisos);
                                }
                            }
                            else
                            {
                                pizarra_guardar();
                            }
                        }
                    });

                    win_auto_asignarse_permisos.options.userData = {
                        perfil_permisos: {},
                        nuevo_nombre_pizarra: nuevo_nombre_pizarra ? nuevo_nombre_pizarra : null
                    };

                    win_auto_asignarse_permisos.showCenter(true);
                }
                else
                {
                    pizarra_guardar(nuevo_nombre_pizarra, null);
                }
            }
        }


        function pizarra_guardar(nuevo_nombre_pizarra, perfil_permisos)
        {
            nvFW.bloqueo_activar($body, "guardar", "Guardando...");

            var hay_detalles_incompletos = !actualizar_vector_detalles();
            actualizar_vector_definiciones();
            // Verificar si hay combinaciones repetidas
            var combRepetidas = verificar_combinaciones_repetidas();

            if (combRepetidas.hayRepetidas)
            {
                var msj = 'Por favor, elimine y/o modifique las combinaciones que están repetidas.</br></br>';

                for (var i = 0; i < combRepetidas.combinaciones.length; i++)
                {
                    var comb_splitted = combRepetidas.combinaciones[i].split(separador);

                    for (var j = 0; j < comb_splitted.length; j++)
                    {
                        msj += PizarraDef[j].etiqueta + ' (<b>' + comb_splitted[j] + '</b>) ';
                    }

                    msj += '</br>';
                }

                // Sacar el vidrio
                nvFW.bloqueo_desactivar(null, 'guardar');

                alert(msj,
                {
                    title: '<b>Combinaciones repetidas</b>',
                    width: 450,
                    height: 150
                });

                return false;
            }

            var xmldato = generarXML(true, nuevo_nombre_pizarra, perfil_permisos);

            // Guardar todos los valores del filtro
            if (filtro_activado)
            {
                // Limpiar el arreglo
                valores_campos_filtro.length = 0;

                for (var i = 1, max = PizarraDef.length; i <= max; i++)
                {
                    valores_campos_filtro.push($F("filtro_dato_" + i));
                }
            }

            var editaDefinicion = true;
            var editaDetalles = true;

            if (guardar_como || nueva_pizarra)
            {
                editaDefinicion = false;
                editaDetalles = false;
            }
            else
            {
                // comparar si hay diferencias en el XML original y el nuevo
                var chequeo = analizar_diferencias();

                if (!chequeo.hayDiferencias)
                {
                    nvFW.bloqueo_desactivar(null, "guardar");
                    alert('Actualmente no existen cambios para guardar', { title: '<b>Info Guardar</b>', width: 350 });
                    return false;
                }
                else
                {
                    /*-----------------------------------------------------------------
                    |                         Estado de Edición
                    |------------------------------------------------------------------
                    | Activar el flag que corresponda (editaDefinicion, editaDetalles)
                    | y verificar que el operador cuente con los permisos 
                    | correspondientes para éstas acciones.
                    |----------------------------------------------------------------*/

                    // Cabecera y Definición
                    if (chequeo.seccion.indexOf('cab') > -1 || chequeo.seccion.indexOf('def') > -1)
                    {
                        editaDefinicion = true;

                        if (!nvFW.tienePermiso('permisos_web5', 8))
                        {
                            nvFW.bloqueo_desactivar(null, "guardar");
                            alert("No posee el permiso para guardar los cambios realizados en la <b>cabecera</b> o la <b>definición</b>.<br/>Por favor contacte al Administrador del sistema.", { title: '<b>Info Guardar</b>' });
                            return false;
                        }
                    }
                    else
                    {
                        editaDefinicion = false;
                    }

                    // Detalles
                    if (chequeo.seccion.indexOf('det') > -1)
                    {
                        editaDetalles = true;

                        if (!nvFW.tienePermiso(nvFW.pageContents.pizPermiso_grupo, nvFW.pageContents.pizPermiso_nro_editar))
                        {
                            nvFW.bloqueo_desactivar(null, "guardar");
                            alert("No posee los permisos para guardar los cambios realizados en los <b>detalles</b>.<br/>Por favor contacte al Administrador del sistema para pedir la habilitación de los permisos para la pizarra actual.", { title: '<b>Info Guardar</b>' });
                            return false;
                        }
                    }
                    else
                    {
                        editaDetalles = false;
                    }
                }
            }

            nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx', {
                parameters: {
                    modo: 'M',
                    strXML: xmldato,
                    edita_def: editaDefinicion,
                    edita_det: editaDetalles
                },
                onSuccess: function (err)
                {
                    if (err.numError != 0)
                    {
                        alert(err.mensaje, { title: "<b>" + err.titulo + "</b>" });
                        nvFW.bloqueo_desactivar(null, "guardar");
                        return;
                    }
                    else
                    {
                        nro_calc_pizarra = err.params.nro_calc_pizarra;

                        // DATOS INCOMPLETOS => Informar al operador
                        if (hay_detalles_incompletos)
                        {
                            alert("<br/>Hay detalles vacíos o sin completar.<br/><b>El proceso de guardado se efectuó de todas maneras.</b>", {
                                title: "<b>Detalles vacíos al guardar</b>",
                                width: 400,
                                height: 110
                            });
                        }

                        /*---------------------------------------------------------------
                        |
                        | Creación de pizarra por "NUEVA PIZARRA" o "GUARDAR COMO..."
                        |
                        |----------------------------------------------------------------
                        | Informar al operador acerca de los permisos de visualización
                        | y edición de la misma
                        |--------------------------------------------------------------*/
                        if (guardar_como || nueva_pizarra)
                        {
                            recarga_nuevo = true;
                            nuevo_nombre_pizarra = nuevo_nombre_pizarra || $('calc_pizarra').value;

                            if (!nvFW.tienePermiso("permisos_nova_admin", 4))
                            {
                                alert('<br/>La pizarra <b>' + nuevo_nombre_pizarra + '</b> fue creada satisfactoriamente.<br/><br/>Para su visualización y edición, por favor pedir el alta de los siguientes permisos al Administrador:<br/><br/><b>* ' + nuevo_nombre_pizarra + ' ver</b><br/><b>* ' + nuevo_nombre_pizarra + ' editar</b>', {
                                    title: '<b>Habilitar permisos de pizarra</b>',
                                    width: 700,
                                    height: 200
                                });
                            }
                            else
                            {
                                alert('<br/>La pizarra <b>' + nuevo_nombre_pizarra + '</b> fue creada satisfactoriamente.<br/><br/>Si necesita que otros operadores puedan visualizarla y/o editarla, por favor pedir el alta de los siguientes permisos al Administrador:<br/><br/><b>* ' + nuevo_nombre_pizarra + ' ver</b><br/><b>* ' + nuevo_nombre_pizarra + ' editar</b>', {
                                    title: '<b>Habilitar permisos de pizarra</b>',
                                    width: 700,
                                    height: 200,
                                    onOk: function (win_alert)
                                    {
                                        win_alert.close();
                                        reload_new_page_with_alert();
                                    }
                                });
                            }

                            // Actualizar el titulo de la ventana
                            try
                            {
                                winPrincipal.setTitle('<b>Pizarra Edición</b>');
                            }
                            catch (e) { }
                        }

                        // Limpiar los xml de comparacion
                        pizarra_limpiar_xml_comparacion();
                        nvFW.bloqueo_desactivar(null, "guardar");
                        pizarra_cargar();

                        // Filtro ACTIVADO => setear el filtro con sus valores y filtrar los datos
                        if (filtro_activado)
                        {
                            if (valores_campos_filtro.length)
                            {
                                // Setear los valores a cada campo del filtro
                                for (var i = 1, max = PizarraDef.length; i <= max; i++)
                                {
                                    if (valores_campos_filtro[i - 1])
                                    {
                                        campos_defs.set_value("filtro_dato_" + i, tScript.string_to_script(valores_campos_filtro[i - 1]));
                                    }
                                }

                                // Mostrar los campos de filtrado
                                filtro_oculto = true;
                                pizarra_ver_filtro();
                                pizarra_filtrar_datos();  // Lanzar el filtrado
                            }
                        }

                        // Actualizo el titulo
                        $("vMenuPizarras").select("td")[nvFW.pageContents.permiso_edicion_estructura == true ? 2 : 1].innerHTML = "(" + Pizarra.nro_calc_pizarra + ") " + Pizarra.calc_pizarra;
                    }

                    // Vuelvo las variables 'guardar_como', 'nueva_pizarra' y 'recarga_nuevo' a FALSE
                    guardar_como = false;
                    nueva_pizarra = false;
                    recarga_nuevo = false;

                    // seteamos el dato de 'recargar' para la ventana llamante
                    winPrincipal.options.userData.recargar = true;
                },
                onFailure: function (err)
                {
                    alert(err.mensaje, {
                        title: "<b>" + err.titulo + "</b>"
                    });

                    nvFW.bloqueo_desactivar(null, "guardar");
                },
                error_alert: false,
                bloq_contenedor_on: false,
            });
        } // FIN pizarra_guardar()


        function reload_new_page_with_alert()
        {
            alert("<br/>La pizarra se recargará para actualizar los nuevos permisos y poder cargar datos.",
            {
                title: "<b>Recargar pizarra</b>",
                onOk: function (win_alert)
                {
                    win_alert.close();

                    if (window.location.href.indexOf('pizarra=0') != -1)
                    {
                        window.location.href = window.location.href.replace("pizarra=0", "pizarra=" + nro_calc_pizarra);
                    }
                    else
                    {
                        // Obtener el nro_calc_pizarra anterior
                        var href = window.location.href;
                        var pos_params           = href.indexOf('?') + 1;
                        var query_params         = href.substring(pos_params, href.length);
                        var old_nro_calc_pizarra = query_params ? query_params.split('&')[0].split('=')[1] : 0;
                        // Reemplazo el numero viejo por el nuevo para la recarga
                        window.location.href = window.location.href.replace(old_nro_calc_pizarra, nro_calc_pizarra);
                    }
                }
            });
        }


        function pizarra_limpiar_xml_comparacion()
        {
            xml_comparacion.original.xml_cab = '';
            xml_comparacion.original.xml_def = '';
            xml_comparacion.original.xml_det = '';
            xml_comparacion.nuevo.xml_cab = '';
            xml_comparacion.nuevo.xml_def = '';
            xml_comparacion.nuevo.xml_det = '';
        }


        function window_onresize()
        {
            try
            {
                var body_h = $body.getHeight();
                var div_pizarra_h = $div_pizarra.getHeight();
                var div_pizarra_def_h = $div_pizarra_def.getHeight();
                var valor_h = modo_edicion
                    ? body_h - divPizarraDatos_h - div_pizarra_h - divPizarraDef_h - div_pizarra_def_h - divPizarraDet_h - dif
                    : body_h - divPizarraDatos_h - divPizarraDet_h - dif;

                $div_pizarra_det.style.height = valor_h + 'px';
            }
            catch (e) { }
        }


        function pizarra_nueva()
        {
            // Cambiar el título de la ventana (con try/catch)
            try
            {
                winPrincipal.setTitle('<b>Pizarra Nueva</b>');
            }
            catch (e) { }

            nro_calc_pizarra = 0;
            nueva_pizarra = true;

            // Limpiar titulo
            $('vMenuPizarras').select('td')[2].innerText = '';
            $('vMenuPizarras').select('td')[3].hide();  // Ocultar boton "Históricos" en pizarra nueva

            $div_pizarra.hide();
            $divPizarraDef.hide();
            $div_pizarra_def.hide();
            $divPizarraDet.hide();

            // Limpiar HTML
            $div_pizarra_def.innerHTML = $div_pizarra_det.innerHTML = '';

            // Dibujo el boton para agregar detalles
            if (!nvFW.pageContents.load_from_log)
            {
                dibujar_btn_agregar_detalle();
            }

            // Limpiar Pizarra
            Pizarra.ancho = '';
            Pizarra.calc_pizarra = '';
            Pizarra.campo_def = '';
            Pizarra.cubo = false;
            Pizarra.etiqueta = '';
            Pizarra.matriz = false;
            Pizarra.nro_calc_pizarra = nro_calc_pizarra;
            Pizarra.posfijo = '';
            Pizarra.prefijo = '';
            Pizarra.tipo_dato = '';
            // Extras
            PizarraExtra = [];
            PizarraExtra.valores = [];
            // Limpiar arreglos de pizarras (datos y detalles)
            PizarraDef.length = 0;
            PizarraDet.length = 0;

            $('txt_nro_calc_pizarra').value = nro_calc_pizarra;
            $('calc_pizarra').value = "";
            $('campo_def_cab').value = "";
            $('etiqueta_cab').value = "";
            $('prefijo').value = "";
            $('posfijo').value = "";
            $('tipo_dato').value = "";
            $('width_cab').value = "";

            $div_pizarra.show();
            $divPizarraDef.show();
            $div_pizarra_def.show();
            $divPizarraDet.show();
        }


        function pizarra_eliminar()
        {
            if (!nro_calc_pizarra)
            {
                nvFW.alert("No es posible eliminar la pizarra porque aún no fue gurdada.");
                return;
            }

            nvFW.confirm("¿Desea eliminar la pizarra <b>" + $("calc_pizarra").value + " (" + $("txt_nro_calc_pizarra").value + ")</b>?", {
                width: 420,
                height: 90,
                okLabel: "Aceptar",
                cancelLabel: "Cancelar",
                cancel: function (win)
                {
                    win.close();
                    return;
                },
                ok: function (win)
                {
                    eliminar();
                    win.close();
                }
            });
        }


        function eliminar()
        {
            nvFW.bloqueo_activar($body, "bloq_eliminar", "Eliminando pizarra...");

            var xmldato = "";
            xmldato += "<calc_pizarra_cab nro_calc_pizarra='" + $('txt_nro_calc_pizarra').value * (-1) + "' etiqueta='" + $('etiqueta_cab').value + "' calc_pizarra='" + $('calc_pizarra').value + "' prefijo='" + $('prefijo').value + "' posfijo='" + $('posfijo').value + "' tipo_dato='" + $('tipo_dato').value + "' campo_def='" + $('campo_def_cab').value + "' auto_ordenada='" + ($('auto_ordenada').checked ? '1' : '0') + "'>";
            xmldato += "<calc_pizarra_def></calc_pizarra_def>";
            xmldato += "</calc_pizarra_cab>";

            nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx',
            {
                parameters:
                {
                    modo: 'M',
                    strXML: xmldato
                },
                bloq_contenedor_on: false,
                onSuccess: function (err)
                {
                    nvFW.bloqueo_desactivar(null, "bloq_eliminar");

                    if (winPrincipal.options && winPrincipal.options.userData)
                    {
                        winPrincipal.options.userData.recargar = true;
                    }

                    try
                    {
                        winPrincipal.close();
                        window.close();
                    }
                    catch (e) { }
                },
                onFailure: function (err)
                {
                    alert('Ocurrión un error al eliminar la Pizarra. Por favor consulte con el Administrador del sistema.');
                    nvFW.bloqueo_desactivar(null, "bloq_eliminar");
                }
            });
        }


        function obtener_select_tipoDato(name_id)
        {
            // ar_tipo_dato se carga solo una vez
            if (!ar_tipo_dato)
            {
                ar_tipo_dato = {};
                var rs = new tRS();
                var id = null;

                rs.open({
                    filtroXML: nvFW.pageContents.filtroDatoTipos,
                    async: false
                });

                while (!rs.eof())
                {
                    id = rs.getdata('id', 0);
                    ar_tipo_dato[id] = {};
                    ar_tipo_dato[id].id = id;
                    ar_tipo_dato[id].campo = rs.getdata('campo', '');
                    ar_tipo_dato[id].nro_campo_tipo = rs.getdata('nro_campo_tipo', '');
                    ar_tipo_dato[id].adoXML = rs.getdata('adoXML', '');

                    rs.movenext();
                }
            }

            var strHTML = "<select style='width: 100%;' name='" + name_id + "' id='" + name_id + "' onchange='return tipo_dato_onchange(this.id, this.value);'>";
            strHTML += "<option value=''></option>";
            var arr_tmp = null;

            for (el in ar_tipo_dato)
            {
                arr_tmp = ar_tipo_dato[el];
                strHTML += "<option value='" + arr_tmp.id + "'>" + arr_tmp.campo + " (" + arr_tmp.id + ")</option>";
            }

            strHTML += "</select>";
            return strHTML;
        }


        function pizarra_ver_filtro()
        {
            // Si estoy en Matriz, retorno
            if (Pizarra.matriz)
            {
                alert('<br/>No hay filtros en modo <b>Matriz</b>.', {
                    title: '<b>Información</b>',
                    width: 350
                });

                return;
            }

            trFiltro = $("filtro");

            if (!trFiltro)
            {
                alert('<br/>Aún no hay una estructura de pizarra definida y por lo tanto no es posible acceder a opciones de filtrado', { title: '<b>Definir estructura</b>' });
                return;
            }

            if (!PizarraDet.length)
            {
                alert('<br/>Aún no hay datos en la pizarra para acceder al filtrado', { title: '<b>Definir estructura</b>' });
                return;
            }

            if (filtro_oculto)
            {
                trFiltro.show();
                $div_pizarra_det.scrollTop = 0;
                filtro_oculto = false;
                filtro_activado = true;  // activar flag global de filtro activado
            }
            else
            {
                trFiltro.hide();
                filtro_oculto = true;
                filtro_activado = false;  // desactivar flag global de filtro activado
            }
        }


        function pizarra_filtrar_datos()
        {
            nvFW.bloqueo_activar($div_pizarra_det, "bloq_filtro", "Filtrando...");
            filtro_activado = true;
            var cant_datos = PizarraDef.length;

            if (!cant_datos) return;

            // Array con filtros y su tipo de dato
            var ar_filtro = [];

            for (var i = 1; i <= cant_datos; i++)
            {
                ar_filtro[i] = [];
                ar_filtro[i].valor       = $F("filtro_dato_" + i) != "" ? $F("filtro_dato_" + i) : null;
                ar_filtro[i].tipo_dato   = (PizarraDef[i - 1].tipo_dato_def).toLowerCase();
                ar_filtro[i].tiene_hasta = PizarraDef[i - 1].tiene_hasta == 1;
                ar_filtro[i].campo_def   = PizarraDef[i - 1].campo_def != "";
                ar_filtro[i].limite      = PizarraDef[i - 1].limite;
            }

            var hidefila;
            var filaElement;

            for (var fila = 0, max = PizarraDet.length; fila < max; fila++)
            {
                hidefila = false;

                if (!$("id_calc_piz_det_" + fila))
                {
                    continue;
                }
                else
                {
                    filaElement = $("id_calc_piz_det_" + fila).up("tr");     // fila actual; utilizada para accion hide() o show()
                }

                for (var dato = 1; dato <= cant_datos; dato++)
                {
                    if (hidefila) break;

                    if (ar_filtro[dato].valor)
                    {
                        // tiene_hasta => comparacion between
                        if (ar_filtro[dato].tiene_hasta)
                        {
                            // between
                            var desde = PizarraDet[fila]["dato" + dato + "_desde"];
                            var hasta = PizarraDet[fila]["dato" + dato + "_hasta"];
                            var valor_filtro = ar_filtro[dato].valor;

                            switch (ar_filtro[dato].tipo_dato)
                            {
                                case "datetime":
                                    desde = parseFecha(desde, "dd/mm/yyyy");
                                    hasta = parseFecha(hasta, "dd/mm/yyyy");
                                    hasta.setDate(hasta.getDate() + 1); // hay que sumar 1 dia para que entre en el rango
                                    valor_filtro = parseFecha(valor_filtro, "dd/mm/yyyy");

                                    if (valor_filtro < desde || valor_filtro >= hasta) hidefila = true;

                                    break;

                                case "int":
                                case "money":
                                    desde = +desde;
                                    hasta = +hasta;
                                    valor_filtro = +valor_filtro;

                                    if (valor_filtro < desde || valor_filtro > hasta) hidefila = true;

                                    break;
                            }
                        }
                        else
                        {
                            // normal
                            var desde = PizarraDet[fila]["dato" + dato + "_desde"];
                            var valor_filtro = ar_filtro[dato].valor;

                            switch (ar_filtro[dato].tipo_dato)
                            {
                                case "datetime":
                                    desde = parseFecha(desde, "dd/mm/yyyy");
                                    valor_filtro = parseFecha(hasta, "dd/mm/yyyy");

                                    if (valor_filtro != desde) hidefila = true;

                                    break;

                                case "int":
                                case "money":
                                    desde = +desde;

                                    // Distinguir si vino por campo_def tipo 2 (dos) => mas de 1 (un) valor en "valor_filtro"
                                    if (ar_filtro[dato].campo_def)
                                    {
                                        hidefila = eval("[" + valor_filtro + "]").indexOf(desde) == -1 ? true : false;
                                    }
                                    else
                                    {
                                        var limite = ar_filtro[dato].limite;
                                        // caso trivial
                                        valor_filtro = +valor_filtro;

                                        if (!limite || limite == "igual")
                                        {
                                            if (valor_filtro != desde) hidefila = true;
                                        }
                                        else if (limite == "max")
                                        {
                                            if (valor_filtro > desde) hidefila = true;
                                        }
                                        else if (limite == "min")
                                        {
                                            if (valor_filtro < desde) hidefila = true;
                                        }
                                    }

                                    break;

                                case "varchar":
                                    desde = desde.toLowerCase();
                                    valor_filtro = valor_filtro.toLowerCase();

                                    if (desde.indexOf(valor_filtro) == -1) hidefila = true;

                                    break;
                            }
                        }
                    }

                    if (hidefila)
                        filaElement.hide(); // ocultar fila
                    else
                        filaElement.show(); // mostrar fila
                }
            } // end: FOR fila

            // Cargar el array de indices visibles
            window.setTimeout(function ()
            {
                cargar_indices_visibles();
            }, 10);

            show_new_items();                             // mostrar todos los que tengan ID = 0
            nvFW.bloqueo_desactivar(null, "bloq_filtro"); // quitar vidrio del filtro
        }


        function cargar_indices_visibles(limpiar)
        {
            limpiar = limpiar || false;
            indices_visibles.length = 0;

            if (limpiar) {
                return;
            }
            else
            {
                $$("input[name*=id_calc_piz_det]").each(function (detalle_id) {
                    if (detalle_id.up("tr").style.display != "none" && detalle_id.value != "0")
                        indices_visibles.push(parseInt(detalle_id.value));
                });
            }
        }


        // Muestra todos los detalles nuevos, sin importar el filtro seteado
        function show_new_items()
        {
            $$("input[name*=id_calc_piz_det]").each(function (detalle_id)
            {
                if (detalle_id.value == "0")
                {
                    $(detalle_id).up("tr").show();
                }
            });
        }


        function pizarra_resetear_filtro()
        {
            var cant_datos = PizarraDef.length;
            var nombre_filtro = "filtro_dato_";

            // Limpiar todos los campos de filtro
            for (var dato = 1; dato <= cant_datos; dato++)
            {
                // verificar si es un campo_def
                if (PizarraDef[dato - 1].campo_def)
                {
                    campos_defs.clear(nombre_filtro + dato);
                }
                else
                {
                    $(nombre_filtro + dato).value = "";
                }
            }

            pizarra_filtrar_datos(); // llamada al filtrado

            window.setTimeout(function ()
            {
                cargar_indices_visibles(true);
            }, 10);
        }


        function getTimeStamp()
        {
            var timestamp = new Date();

            return timestamp.getFullYear().toString() +
                rellenar_izq(timestamp.getMonth() + 1, 2, '0') +
                rellenar_izq(timestamp.getDate(), 2, '0') +
                "_" +
                rellenar_izq(timestamp.getHours(), 2, '0') +
                rellenar_izq(timestamp.getMinutes(), 2, '0');
        }


        // Exportacion a Excel
        function pizarra_exportar_excel()
        {
            var xml_ado = '';
            var path_xsl = '';

            // Obtener XML con estructura para Excel Base o Excel tipo Matriz
            if (!Pizarra.matriz)
            {
                xml_ado = obtener_xmlADO();
                path_xsl = 'report/EXCEL_base.xsl';
            }
            else
            {
                xml_ado = obtener_xmlADO_matriz();
                path_xsl = 'report/pizarra/EXCEL_pizarra_matriz.xsl';
            }

            nvFW.exportarReporte({
                xml_data: xml_ado,
                path_xsl: path_xsl,
                filename: Pizarra.calc_pizarra + "_" + getTimeStamp() + ".xls",
                ContentType: "application/vnd.ms-excel",
                content_disposition: "attachment",
                formTarget: "iframe_excel",
                salida_tipo: "adjunto"
            });
        }


        function get_excel_tipo(tipo_dato, esCampoDef)
        {
            return esCampoDef ? 'string' : ar_tipo_dato[tipo_dato].adoXML;
        }


        // Armado de XML Excel
        function obtener_xmlADO()
        {
            // Parte inicial del XML; siempre está => armar correctamente las columnas
            var columnas = {};
            var nro_columna = 0;
            var nombre_columnas = [];
            var xml_ado = '<xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema">';
            xml_ado += '<s:Schema id="RowsetSchema">';
            xml_ado += '<s:ElementType name="row" content="eltOnly" rs:updatable="true">';

            // Columna ID
            nombre_columnas[nro_columna] = "id";
            columnas[nro_columna] = {};
            columnas[nro_columna].nombre = nombre_columnas[nro_columna];
            columnas[nro_columna].datoN_name = "";

            xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
            xml_ado += '<s:datatype dt:type="int" dt:maxLength="70" rs:precision="0" rs:maybenull="true" />';
            xml_ado += '</s:AttributeType>';

            nro_columna++;

            var tipo_dato;
            var precision;
            var nro_dato;

            /*-----------------------------------------------------------------
            |   Armar todas las columnas intermedias de DATOS
            |----------------------------------------------------------------*/
            PizarraDef.each(function (dato, pos)
            {
                columnas[nro_columna] = {};
                tipo_dato = get_excel_tipo(dato.tipo_dato_def, dato.campo_def != "");
                precision = tipo_dato == "float" ? 2 : 0;
                nro_dato  = pos + 1;

                if (dato.tiene_hasta)
                {
                    /*-----------------------------------
                    | Columna doble
                    |----------------------------------*/

                    // Desde
                    nombre_columnas[nro_columna]     = ((dato.etiqueta ? dato.etiqueta.split(" ").join("_") : dato.calc_pizarra_dato) + "_desde").replace(exp_specialChars, "");
                    columnas[nro_columna].nombre     = nombre_columnas[nro_columna];
                    columnas[nro_columna].datoN_name = "dato" + nro_dato + "_desde";
                    columnas[nro_columna].tipo_dato  = dato.tipo_dato_def;

                    xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
                    xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
                    xml_ado += '</s:AttributeType>';

                    nro_columna++;
                    columnas[nro_columna] = {};

                    // Hasta
                    nombre_columnas[nro_columna]     = ((dato.etiqueta ? dato.etiqueta.split(" ").join("_") : dato.calc_pizarra_dato) + "_hasta").replace(exp_specialChars, "");
                    columnas[nro_columna].nombre     = nombre_columnas[nro_columna];
                    columnas[nro_columna].datoN_name = "dato" + nro_dato + "_hasta";
                    columnas[nro_columna].tipo_dato  = dato["tipo_dato_def"];

                    xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
                    xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
                    xml_ado += '</s:AttributeType>';

                    nro_columna++;
                }
                else
                {
                    /*-----------------------------------
                    | Columna simple
                    |----------------------------------*/
                    nombre_columnas[nro_columna]     = (dato.etiqueta ? dato.etiqueta.split(" ").join("_") : dato.calc_pizarra_dato).replace(exp_specialChars, "");
                    columnas[nro_columna].datoN_name = "dato" + nro_dato + "_desde";
                    columnas[nro_columna].nombre     = nombre_columnas[nro_columna];
                    columnas[nro_columna].tipo_dato  = dato.tipo_dato_def;

                    xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
                    xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
                    xml_ado += '</s:AttributeType>';

                    nro_columna++;
                }
            });

            // Columna de Salida
            nombre_columnas[nro_columna] = (Pizarra.etiqueta ? Pizarra.etiqueta.split(" ").join("_") : "Valor").replace(exp_specialChars, "");
            tipo_dato = get_excel_tipo(Pizarra.tipo_dato, Pizarra.campo_def != null && Pizarra.campo_def != '');
            precision = tipo_dato == "float" ? 2 : 0;

            xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
            xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
            xml_ado += '</s:AttributeType>';

            nro_columna++;

            // Salidas extra
            if (PizarraExtra.valores.length)
            {
                var index_inicio = 2;

                PizarraExtra.valores.each(function (salida_extra, index)
                {
                    nombre_columnas[nro_columna] = (salida_extra.etiqueta ? salida_extra.etiqueta.split(' ').join('_') : 'Valor_' + (index + index_inicio)).replace(exp_specialChars, '');
                    tipo_dato = get_excel_tipo(salida_extra.tipo_dato, salida_extra.campo_def != null && salida_extra.campo_def != '');
                    precision = tipo_dato == 'float' ? 2 : 0;

                    xml_ado += '<s:AttributeType name="' + nombre_columnas[nro_columna] + '" rs:number="' + (nro_columna + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
                    xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
                    xml_ado += '</s:AttributeType>';

                    nro_columna++;
                });
            }

            xml_ado += '<s:extends type="rs:rowbase" />';
            xml_ado += '</s:ElementType>';
            xml_ado += '</s:Schema>';
            xml_ado += '<rs:data>';

            /*------------------------------------------------------------------
            |   Parte intermedia con los DETALLES; iterar y armar cada "z:row"
            |-----------------------------------------------------------------*/
            var cant_columnas     = nombre_columnas.length;
            var recordCount       = 0;
            var exportarFiltrados = indices_visibles.length > 0;
            var cant_salidas      = PizarraExtra.valores.length + 1;   // Salidas totales = Salida + Salidas Extra

            /*-------------------------------------------------
            |     EXPORTACION SOLO DE DETALLES FILTRADOS
            |------------------------------------------------*/
            if (exportarFiltrados)
            {
                PizarraDet.each(function (detalle, i)
                {
                    if (indices_visibles.indexOf(+detalle.id_calc_piz_det) === -1)
                    {
                        return;
                    }
                    else
                    {
                        var icol = 0; // indice columna
                        xml_ado += '<z:row ';

                        for (; icol < cant_columnas - cant_salidas; icol++)
                        {
                            if (icol == 0)
                            {
                                xml_ado += nombre_columnas[icol] + '="' + detalle.id_calc_piz_det + '" ';
                            }
                            else
                            {
                                // tipo_dato == 'datetime => procesar por separado
                                if (columnas[icol].tipo_dato == 'datetime')
                                {
                                    xml_ado += columnas[icol].nombre + '="' + FechaToSTR(parseFecha(campos_defs.get_desc(columnas[icol].datoN_name + '_' + i), 'dd/mm/yyyy'), 3) + 'T00:00:00.000" ';
                                }
                                // tipo_dato == 'bit' => determinar si el checkbox esta seleccionado ('SI') o no ('NO')
                                else if (columnas[icol].tipo_dato == 'bit')
                                {
                                    xml_dato += columnas[icol].nombre + '="' + ($(columnas[icol].datoN_name + '_' + i).checked ? 'SI' : 'NO') + '" ';
                                }
                                else
                                {
                                    xml_ado += columnas[icol].nombre + '="' + campos_defs.get_desc(columnas[icol].datoN_name + '_' + i) + '" ';
                                }
                            }
                        }

                        var isalida = 1; // indice salida

                        for (; icol < cant_columnas; icol++)
                        {
                            xml_ado += nombre_columnas[icol] + '="' + campos_defs.get_desc('valor_' + isalida + '_' + i) + '" ';
                            isalida++;
                        }

                        xml_ado += '/>';
                        recordCount++;
                    }
                });
            }
            /*-------------------------------------------------
            |       EXPORTACION DE TODOS LOS DETALLES
            |------------------------------------------------*/
            else
            {
                PizarraDet.each(function (arr, i)
                {
                    var icol = 0; // Indice Columna: se deja global dentro de la funcion para reutilizarlo en bucle de salida
                    xml_ado += '<z:row ';

                    for (; icol < cant_columnas - cant_salidas; icol++)
                    {
                        if (icol == 0)
                        {
                            xml_ado += nombre_columnas[icol] + '="' + arr.id_calc_piz_det + '" ';
                        }
                        else
                        {
                            // tipo_dato === 'datetime' => procesarlo por separado
                            if (columnas[icol].tipo_dato == 'datetime')
                            {
                                xml_ado += columnas[icol].nombre + '="' + FechaToSTR(parseFecha(campos_defs.get_desc(columnas[icol].datoN_name + '_' + i), 'dd/mm/yyyy'), 3) + 'T00:00:00.000" ';
                            }
                            // tipo_dato == 'bit' => determinar si el checkbox esta seleccionado ('SI') o no ('NO')
                            else if (columnas[icol].tipo_dato == 'bit')
                            {
                                xml_dato += columnas[icol].nombre + '="' + ($(columnas[icol].datoN_name + '_' + i).checked ? 'SI' : 'NO') + '" ';
                            }
                            else
                            {
                                xml_ado += columnas[icol].nombre + '="' + campos_defs.get_desc(columnas[icol].datoN_name + '_' + i) + '" ';
                            }
                        }
                    }

                    var isalida = 1; // indice para ubicar cada salida (valor_1, valor_2, etcetera)

                    for (; icol < cant_columnas; icol++)
                    {
                        xml_ado += nombre_columnas[icol] + '="' + campos_defs.get_desc('valor_' + isalida + '_' + i) + '" ';
                        isalida++;
                    }

                    xml_ado += '/>';
                    recordCount++;
                });
            }

            // Parter final del XML
            xml_ado += '</rs:data>';
            xml_ado += '<Params recordcount="' + recordCount + '" />';
            // Paso el columnHeaders para personalizar las cabeceras
            xml_ado += '<parametros><columnHeaders>' + table_header + '</columnHeaders></parametros>';
            xml_ado += '</xml>';

            return xml_ado;
        }


        // Armado de XML Excel en modo MATRIZ
        function obtener_xmlADO_matriz()
        {
            /*-----------------------------------------------------------------
            |   Para éste tipo de estructura de datos de Matriz, tanto las
            | filas como las columnas que son fijas las pasamos en una 
            | estructura aparte dentro de <parametros>
            |
            |   En modo "MATRIZ" siempre tenemos 2 datos y son campos defs,
            | además sólo cuenta con 1 salida, y son éstos valores los que
            | tenemos que pasar solamente, ya que los valores de ID, por 
            | ejemplo, no podemos representarlos en la matriz.
            |----------------------------------------------------------------*/
            var cantidad_filas    = matriz.filas.length;
            var cantidad_columnas = matriz.columnas.length;

            /*------------------------------------------------------------------
            |   Parte inicial del XML_ADO
            |   Siempre está => armar correctamente las columnas
            |-----------------------------------------------------------------*/
            var xml_ado = '';
            xml_ado += '<xml xmlns:s="uuid:BDC6E3F0-6DA3-11d1-A2A3-00AA00C14882" xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:rs="urn:schemas-microsoft-com:rowset" xmlns:z="#RowsetSchema">';
            xml_ado += '<s:Schema id="RowsetSchema">';
            xml_ado += '<s:ElementType name="row" content="eltOnly" rs:updatable="true">';

            // Columna de Salida
            var tipo_dato = get_excel_tipo(Pizarra.tipo_dato, Pizarra.campo_def != null && Pizarra.campo_def != '');
            var precision = tipo_dato == 'float' ? 2 : 0;

            /*------------------------------------------------------------------
            |   Armamos "<s:AttributeType>" para cada atributo de salida, asi
            | no tenemos que hacer nada "raro" en la pantilla buscdando nombres
            | de atributos con xPath.
            |
            |   Todos los atributos son del mismo tipo, porque son todos de
            | Salida.
            |-----------------------------------------------------------------*/
            for (var i = 0; i < cantidad_columnas; i++)
            {
                xml_ado += '<s:AttributeType name="valor_' + i + '" rs:number="' + (i + 1) + '" rs:nullable="true" rs:write="true" rs:writeunknown="true">';
                xml_ado += '<s:datatype dt:type="' + tipo_dato + '" dt:maxLength="70" rs:precision="' + precision + '" rs:maybenull="true" />';
                xml_ado += '</s:AttributeType>';
            }

            xml_ado += '<s:extends type="rs:rowbase" />';
            xml_ado += '</s:ElementType>';
            xml_ado += '</s:Schema>';
            xml_ado += '<rs:data>';

            /*------------------------------------------------------------------
            |   Armado de cada "<z:row>". Armamos las filas con todas las 
            | columnas que lo componen.
            |-----------------------------------------------------------------*/
            var recordCount      = 0;
            var posicion         = 1;
            var valor            = '';
            var salida_campo_def = Pizarra.campo_def != '';

            for (var row = 0; row < cantidad_filas; row++)
            {
                xml_ado += '<z:row ';

                for (var col = 0; col < cantidad_columnas; col++)
                {
                    valor = salida_campo_def ? campos_defs.get_desc('valor_' + posicion) : campos_defs.get_value('valor_' + posicion);
                    xml_ado += 'valor_' + col + '="' + valor + '" ';
                    posicion++;
                    recordCount++;
                }

                xml_ado += '/>';
            }

            xml_ado += '</rs:data>';

            /*------------------------------------------------------------------
            |   Final del XML_ADO: Parametría
            |
            |   Params: contiene todo lo relacionado a la cantidad de registros,
            | paginas y todo lo relacionado al orden, en forma de atributos.
            |
            |   parametros: podemos pasarle todo lo que queramos; aquí le
            | pasamos una estructura para la matriz con sus filas y columnas, en
            | forma de etiquetas con valor.
            |-----------------------------------------------------------------*/
            xml_ado += '<Params recordcount="' + recordCount + '" ExpandedRowCount="' + (cantidad_filas + 2) + '" ExpandedColumnCount="' + (cantidad_columnas + 2) + '" />';
            xml_ado += '<parametros>';

            /*------------------------------------------------------------------
            |   Estructura <matriz>
            |-------------------------------------------------------------------
            |   <matriz>
            |       <filas>
            |           <fila></fila>       <!-- 1 o muchas -->
            |           ...
            |           <fila></fila>
            |       </filas>
            |       <columnas>
            |           <columna><columna/> <!-- 1 o muchas -->
            |           ...
            |           <columna><columna/>
            |       </columnas>
            |   </matriz>
            |-----------------------------------------------------------------*/
            xml_ado += '<matriz>';
            xml_ado += '<filas etiqueta="' + PizarraDef[0].etiqueta + '" cantidad="' + cantidad_filas + '">';

            for (var fila = 0; fila < cantidad_filas; fila++)
            {
                xml_ado += '<fila>' + matriz.filas_desc[fila] + '</fila>';
            }

            xml_ado += '</filas>';
            xml_ado += '<columnas etiqueta="' + PizarraDef[1].etiqueta + '" cantidad="' + cantidad_columnas + '">';

            for (var columna = 0; columna < cantidad_columnas; columna++)
            {
                xml_ado += '<columna>' + matriz.columnas_desc[columna] + '</columna>';
            }

            xml_ado += '</columnas>';
            xml_ado += '</matriz>';
            xml_ado += '</parametros>';
            xml_ado += '</xml>';

            return xml_ado;
        }


        function enterToAction(event)
        {
            return (event.keyCode || event.which) == 13 && pizarra_filtrar_datos();
        }


        function pizarra_editar()
        {
            if (!nvFW.pageContents.permiso_edicion_estructura)
            {
                alert("Permisos insuficientes para realizar ésta operación.<br/>Consulte con el Administrador del sistema.",
                {
                    title: "<b>Error</b>"
                });

                return;
            }

            if (!$vMenuPizarras)
                $vMenuPizarras = $('vMenuPizarras');

            // Lista de los elementos TD del menu principal
            var list_of_td = $vMenuPizarras.select("td");
            /*--------------------------------------------
            |   Contenido de [list_of_td]
            |---------------------------------------------
            |   [0] Guardar
            |   [1] Guardar como...
            |   [2] TITULO
            |   [3] Histórico
            |   [4] Op. Avanzadas
            |   [5] Editar Pizarra
            |   [6] Nueva Pizarra
            |   [7] Eliminar Pizarra
            |-------------------------------------------*/

            // Si los botones de:
            //      Histórico
            //      Op.Avanzadas
            //      Nuevo
            //      Eliminar
            // no están enlazados => se los captura
            if (!btn_historico) btn_historico = list_of_td[3];

            if (!btn_op_avanzadas) btn_op_avanzadas = list_of_td[4];

            if (!btn_nuevo) btn_nuevo = list_of_td[6];

            if (!btn_eliminar) btn_eliminar = list_of_td[7];

            // Si todo OK => mostrar datos
            if (modo_edicion)
            {
                // Ocultar botones de menu
                btn_historico.hide();
                btn_op_avanzadas.hide();
                btn_nuevo.hide();
                btn_eliminar.hide();
                $div_pizarra.hide();
                $divPizarraDef.hide();
                $div_pizarra_def.hide();

                modo_edicion = false;
            }
            else
            {
                // Mostrar botones de menu
                btn_historico.show();
                btn_op_avanzadas.show();
                btn_nuevo.show();
                btn_eliminar.show();
                $div_pizarra.show();
                $divPizarraDef.show();
                $div_pizarra_def.show();

                modo_edicion = true;
            }

            window_onresize();
        }


        function generarXML(actualizar_datos, nuevo_nombre_pizarra, perfil_permisos)
        {
            if (actualizar_datos)
            {
                actualizar_vector_detalles();
                actualizar_vector_definiciones();
            }

            var cabecera_apertura = '';
            var permisos          = '';
            var definicion        = '';
            var detalle           = '';
            var cabecera_cierre   = '';
            nuevo_nombre_pizarra  = nuevo_nombre_pizarra || '';
            var cant_datos        = PizarraDef.length || 0;
            var restaurar         = nvFW.pageContents.load_from_log ? 1 : 0;

            /*---------------------------------------------
            |               Cabecera apertura
            |--------------------------------------------*/
            cabecera_apertura += "<calc_pizarra_cab nro_calc_pizarra='" + (guardar_como ? nro_calc_pizarra : $('txt_nro_calc_pizarra').value) + "' calc_pizarra='" + (guardar_como ? nuevo_nombre_pizarra : $('calc_pizarra').value) + "' prefijo='" + $('prefijo').value + "' posfijo='" + $('posfijo').value + "' tipo_dato='" + $('tipo_dato').value + "' campo_def='" + $('campo_def_cab').value + "' cant_datos='" + cant_datos + "' etiqueta='" + $('etiqueta_cab').value + "' ancho='" + $("width_cab").value + "' cubo='" + (Pizarra.cubo ? '1' : '0') + "' auto_ordenada='" + ($('auto_ordenada').checked ? '1' : '0') + "' matriz='" + (Pizarra.matriz ? '1' : '0') + "' restaurar='" + restaurar + "'>";

            /*---------------------------------------------
            |           Cabecera: salidas extra
            |--------------------------------------------*/
            if (PizarraExtra && PizarraExtra.xml)
            {
                cabecera_apertura += PizarraExtra.xml;
            }

            /*---------------------------------------------
            |           Permisos por perfiles
            |--------------------------------------------*/
            if (perfil_permisos && !isEmpty(perfil_permisos))
            {
                // Armar la estructura completa
                permisos += "<perfiles>";

                for (var permiso in perfil_permisos)
                {
                    if (perfil_permisos.hasOwnProperty(permiso))
                    {
                        permisos += "<perfil tipo_operador='" + permiso + "' permiso_autoasignado='" + perfil_permisos[permiso] + "' />";
                    }
                }

                permisos += "</perfiles>";
            }
            else
            {
                // Pasar estructura vacia
                permisos += "<perfiles><perfil tipo_operador='-1' permiso_autoasignado='0' /></perfiles>";
            }

            /*---------------------------------------------
            |               Definición
            |--------------------------------------------*/
            definicion += "<calc_pizarra_def>";

            PizarraDef.each(function (arreglo)
            {
                definicion += "<calc_pizarra_def dato_orden='" + arreglo.dato_orden + "' etiqueta='" + arreglo.etiqueta + "' calc_pizarra_dato='" + arreglo.calc_pizarra_dato + "' tipo_dato='" + arreglo.tipo_dato_def + "' tiene_hasta='" + arreglo.tiene_hasta + "' campo_def='" + arreglo.campo_def + "' prefijo='" + arreglo.prefijo + "' posfijo='" + arreglo.posfijo + "' ancho='" + arreglo.ancho + "' limite='" + arreglo.limite + "' />";
            });

            definicion += "</calc_pizarra_def>";

            if (!xml_comparacion.original.xml_def)
            {
                xml_comparacion.original.xml_def = definicion;
            }
            else
            {
                xml_comparacion.nuevo.xml_def = definicion;
            }

            /*---------------------------------------------
            |               Detalles
            |--------------------------------------------*/
            detalle += "<calc_pizarra_det>";

            if (!$('auto_ordenada').checked)
            {
                pizarra_actualizar_orden();
            }

            var contador = 0;
            var j        = 0;

            PizarraDet.each(function (arreglo)
            {
                detalle += "<calc_pizarra_det id_calc_piz_det='" + (guardar_como || restaurar ? "0" : arreglo.id_calc_piz_det) + "' ";
                contador = cant_datos;
                j = 1;

                while (contador > 0)
                {
                    detalle += "dato" + j + "_desde='" + stringToXMLAttributeString(arreglo['dato' + j + '_desde']) + "' ";
                    detalle += "dato" + j + "_hasta='" + stringToXMLAttributeString((!arreglo['dato' + j + '_hasta'] ? '' : arreglo['dato' + j + '_hasta'])) + "' ";

                    contador--;
                    j++;
                }

                detalle += " valor_1='" + stringToXMLAttributeString(arreglo.valor_1) + "'";

                if (arreglo.valor_2)
                {
                    detalle += " valor_2='" + stringToXMLAttributeString(arreglo.valor_2) + "'";
                }
                else
                {
                    detalle += " valor_2=''";
                }

                if (arreglo.valor_3)
                {
                    detalle += " valor_3='" + stringToXMLAttributeString(arreglo.valor_3) + "'";
                }
                else
                {
                    detalle += " valor_3=''";
                }

                if (arreglo.orden)
                {
                    detalle += " orden='" + stringToXMLAttributeString(arreglo.orden) + "'";
                }

                detalle += " />";
            });

            detalle += "</calc_pizarra_det>";

            if (!xml_comparacion.original.xml_det)
            {
                xml_comparacion.original.xml_det = detalle;
            }
            else
            {
                xml_comparacion.nuevo.xml_det = detalle;
            }

            /*---------------------------------------------
            |               Cabecera cierre
            |--------------------------------------------*/
            cabecera_cierre += "</calc_pizarra_cab>";

            if (!xml_comparacion.original.xml_cab)
            {
                xml_comparacion.original.xml_cab = cabecera_apertura + cabecera_cierre;
            }
            else
            {
                xml_comparacion.nuevo.xml_cab = cabecera_apertura + cabecera_cierre;
            }

            /*---------------------------------------------
            |               XML completo
            |----------------------------------------------
            |   <calc_pizarra_cab>
            |       <perfiles/>
            |       <calc_pizarra_def/>
            |       <calc_pizarra_det/>
            |   </calc_pizarra_cab>
            |--------------------------------------------*/
            return cabecera_apertura + permisos + definicion + detalle + cabecera_cierre;
        }


        function analizar_diferencias()
        {
            var hayDiferencias = false;
            var seccion        = [];

            if (xml_comparacion.original.xml_cab != xml_comparacion.nuevo.xml_cab)
            {
                hayDiferencias = true;
                seccion.push('cab');
            }

            if (xml_comparacion.original.xml_def != xml_comparacion.nuevo.xml_def)
            {
                hayDiferencias = true;
                seccion.push('def');
            }

            if (xml_comparacion.original.xml_det != xml_comparacion.nuevo.xml_det)
            {
                hayDiferencias = true;
                seccion.push('det');
            }

            return {
                hayDiferencias: hayDiferencias,
                seccion: seccion
            };
        }


        function tipo_dato_onchange(id_elemento, valor)
        {
            var indice       = id_elemento.split("_").last();
            var en_cabecera  = isNaN(indice);
            var deshabilitar = valor == "bit" ? true : false;

            if (en_cabecera)
            {
                $("campo_def_cab").disabled = deshabilitar;
                $("prefijo").disabled       = deshabilitar;
                $("posfijo").disabled       = deshabilitar;
            }
            else
            {
                $("campo_def_" + indice).disabled   = deshabilitar;
                $("prefijo_" + indice).disabled     = deshabilitar;
                $("posfijo_" + indice).disabled     = deshabilitar;
                $("tiene_hasta_" + indice).disabled = deshabilitar;
                $("limite_" + indice).disabled      = $("tiene_hasta_" + indice).checked ? true : deshabilitar;
            }
        }


        function pizarra_opciones_avanzadas()
        {
            if (!win_op_avanzadas)
            {
                // Creación de ventana
                win_op_avanzadas = nvFW.createWindow({
                    title: "<b>Opciones Avanzadas</b>",
                    width: 950,
                    height: 200,
                    maximizable: false,
                    minimizable: false,
                    draggable: false,
                    onClose: win_op_avanzadas_onclose
                });
            }

            win_op_avanzadas.options.userData = {
                valores_extra: false,
                valores: (PizarraExtra.valores.length > 0 ? PizarraExtra.valores : []),
                valores_salida: {
                    etiqueta: $("etiqueta_cab").value,
                    tipo_dato: $("tipo_dato").options[$("tipo_dato").options.selectedIndex].innerText,
                    campo_def: $("campo_def_cab").options[$("campo_def_cab").options.selectedIndex].innerText,
                    prefijo: $("prefijo").value,
                    posfijo: $("posfijo").value,
                    ancho: $("width_cab").value
                },
                valores_eliminados: false,
                pizarra_cubo: Pizarra.cubo,
                pizarra_matriz: Pizarra.matriz
            };

            var extraParams = nvFW.pageContents.load_from_log ? '&bloquear=1' : '';
            win_op_avanzadas.setURL("/FW/pizarra/calculos_pizarra_op_avanzadas.aspx?nro_calc_pizarra=" + nro_calc_pizarra + extraParams);
            win_op_avanzadas.showCenter(true);
        }


        function win_op_avanzadas_onclose(win)
        {
            if (win.options.userData.valores_extra)
            {
                var valores_diferentes = false;

                try
                {
                    valores_diferentes = JSON.stringify(win.options.userData.valores) !== JSON.stringify(PizarraExtra["valores"]);
                }
                catch (e) { }

                if (valores_diferentes)
                {
                    PizarraExtra = [];
                    PizarraExtra.valores = win.options.userData.valores;
                    PizarraExtra.xml     = win.options.userData.xml;

                    if (win.options.userData.valores_eliminados)
                    {
                        // Actualizar valores de salidas en PizarraDet
                        var cantidad_salidas_extra = PizarraExtra.valores.length;

                        PizarraDet.each(function (detalle)
                        {
                            switch (cantidad_salidas_extra)
                            {
                                case 0:
                                    if (detalle.valor_2) detalle.valor_2 = '';
                                    if (detalle.valor_3) detalle.valor_3 = '';
                                    break;

                                case 1:
                                    if (detalle.valor_3) detalle.valor_3 = '';
                                    break;
                            }
                        });
                    }

                    alert("Para reflejar los nuevos cambios en la estructura de salida, se procederá al guardado y posterior recarga de la pizarra.", {
                        onOk: function (win_alert)
                        {
                            win_alert.close();
                            pizarra_guardar_wrapper();
                        }
                    });
                }
            }

            var redibujar = false;

            if (win.options.userData.pizarra_cubo)
            {
                /*-------------------------------------------------------------
                | Comprobar si hubo cambio de estado, es decir si cubo cambio 
                | de false a true o viceversa para actualizar estados y saber 
                | si debe dibujar nuevamente o no
                |------------------------------------------------------------*/

                // Sin cambios en CUBO => Pizarra.cubo es 'true'
                if (Pizarra.cubo)
                {
                    if (Pizarra.matriz != win.options.userData.pizarra_matriz)
                    {
                        Pizarra.matriz = win.options.userData.pizarra_matriz;
                        redibujar = true;
                    }
                }
                // Cambio en CUBO => Pizarra.cubo es 'false'
                else
                {
                    // Verificar que puede crear un cubo
                    if (pizarra_cubo_factible())
                    {
                        if (!PizarraDet.length)
                        {
                            pizarra_cubo_crear();
                        }
                        else
                        {
                            Pizarra.cubo = true;
                            Pizarra.matriz = win.options.userData.pizarra_matriz;

                            if (pizarra_cubo_comprobar_cambios())
                            {
                                redibujar = true;
                            }
                            else
                            {
                                redibujar = false;
                                Pizarra.cubo = false;
                                Pizarra.matriz = false;
                            }
                        }
                    }
                    else
                    {
                        Pizarra.cubo = false;
                        Pizarra.matriz = false;
                    }
                }
            }
            else
            {
                if (Pizarra.cubo)
                {
                    redibujar = true;
                }

                Pizarra.cubo = false;
                Pizarra.matriz = false;
            }

            if (redibujar)
            {
                actualizar_vector_detalles();
                pizarra_dibujar_detalles();
            }

            win_op_avanzadas = null;
        }


        function pizarra_cubo_crear()
        {
            // Verificar que cada dato de esctructura sea un campo_def
            if (!pizarra_cubo_factible()) return;

            var datos = pizarra_cubo_get_datos();

            // Verificar que al menos tenga 2 datos de definición
            if (datos.length < 2)
            {
                alert('La pizarra debe contar con al menos 2 datos para generar combinaciones.', {
                    title: '<b>Información CUBO</b>'
                });

                return;
            }

            nvFW.bloqueo_activar($body, 'vidrio_cubo', 'Cargando CUBO...');

            nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx',
            {
                parameters:
                {
                    modo: 'cubo_get_combinaciones',
                    datos: datos.join(',')
                },
                onSuccess: function (err)
                {
                    setTimeout(function ()
                    {
                        pizarra_cubo_dibujar(err.params.combinaciones, err.params.total);
                        bloquear_datos_cubo(true);
                    }, 0);
                },
                onFailure: function (err)
                {
                    nvFW.bloqueo_desactivar(null, 'vidrio_cubo');
                    bloquear_datos_cubo(false);
                },
                bloq_contenedor_on: false
            });
        }


        function pizarra_cubo_factible()
        {
            var factible = true;
            var dato     = null;

            actualizar_vector_definiciones();

            for (var i = 0, n = PizarraDef.length; i < n; i++)
            {
                dato = PizarraDef[i];

                if (!dato.campo_def || dato.tiene_hasta)
                {
                    factible = false;
                    break;
                }
            }

            if (!factible)
            {
                var mensaje = '<br/>Uno o más datos no están definidos como <b>"Campo Def"</b> o tienen seteado el item <b>"Tiene Hasta"</b>.' +
                    '<br/><br/>Para proseguir debe definir <b>todos</b> los datos como "campo def" y el item "tiene hasta" sin chequear.';

                alert(mensaje,
                {
                    title: '<b>No es posible generar CUBO</b>',
                    width: 600,
                    height: 120
                });

                Pizarra.cubo = false;
            }

            return factible;
        }


        function pizarra_cubo_get_datos()
        {
            var datos = [];

            PizarraDef.each(function (dato)
            {
                datos.push(dato.campo_def); // Para CUBO se utilizan si o si los campos_defs
            });

            return datos;
        }


        function pizarra_cubo_dibujar(combinaciones, total)
        {
            nvFW.bloqueo_msg('vidrio_cubo', 'Dibujando CUBO...');
            total = parseInt(total);

            if (!isNaN(total) && total > 0)
            {
                try
                {
                    // Dibujar el total de filas
                    var html = '';
                    var cant_datos = PizarraDef.length;
                    var cant_salidas_extra = PizarraExtra.valores.length;
                    var evaluar = [];
                    var name = '';
                    var indice = 0;
                    var nro_campo_tipo = 104;
                    var cant_detalles_existentes = PizarraDet.length;

                    // Cargar el array de datos => después del evaluador estará disponible "combinaciones[][]"
                    eval(combinaciones);

                    combinaciones.each(function (fila, pos)
                    {
                        indice = 0;
                        pos += cant_detalles_existentes; // se hace para no pisar detalles a eliminar en caso de que existan

                        // Llenar arreglo con cada dato de la fila
                        PizarraDet[pos] = [];
                        PizarraDet[pos].id_calc_piz_det = 0;

                        // Primer y ultima columna son siempre iguales
                        html += '<tr>';
                        html += '<td><input type="text" name="id_calc_piz_det_' + pos + '" id="id_calc_piz_det_' + pos + '" value="0" disabled="true" style="width: 100%; text-align: center;" /></td>';

                        // Datos
                        for (; indice < cant_datos; indice++)
                        {
                            name = 'dato' + (indice + 1) + '_desde_' + pos;
                            html += '<td>' + draw_pre_pos(PizarraDef[indice].prefijo, 'td_' + name, PizarraDef[indice].posfijo) + '</td>';
                            evaluar.push('campos_defs.add("' + name + '", get_campo_def_options("' + PizarraDef[indice].campo_def + '", "td_' + name + '", 0));'); // Crear

                            if (fila[indice])
                            {
                                evaluar.push('campos_defs.set_value("' + name + '", ' + tScript.string_to_script(fila[indice]) + ');'); // Setear solo si hay valor
                            }

                            evaluar.push('campos_defs.habilitar("' + name + '", false);'); // Deshabilitar

                            PizarraDet[pos]['dato' + (indice + 1) + '_desde'] = fila[indice];
                            PizarraDet[pos]['dato' + (indice + 1) + '_hasta'] = '';
                        }

                        // Salida obligatoria
                        name = 'valor_1_' + pos;
                        html += '<td>' + draw_pre_pos(Pizarra.prefijo, 'td_' + name, Pizarra.posfijo) + '</td>';

                        if (Pizarra.campo_def)
                        {
                            evaluar.push('campos_defs.add("' + name + '", get_campo_def_options("' + Pizarra.campo_def + '", "td_' + name + '", 0, ' + pos + '));'); // Crear
                        }
                        else
                        {
                            nro_campo_tipo = Number(ar_tipo_dato[Pizarra.tipo_dato].nro_campo_tipo) || 104;

                            if (nro_campo_tipo != 105)
                            {
                                evaluar.push('campos_defs.add("' + name + '", get_campo_def_options("", "td_' + name + '", ' + nro_campo_tipo + ', ' + pos + '));'); // Crear
                            }
                            else
                            {
                                // Dibuja un CHECKBOX
                                var html_chk = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='" + name + "' id='" + name + "' style='cursor: pointer;' /></td></tr></table>";
                                eval_cdef.push("$('td_" + name + "').innerHTML = \"" + html_chk + "\";");
                                eval_cdef.push("cambiarEstado('valor_" + name + "', " + true + ");");
                            }
                        }

                        PizarraDet[pos].valor_1 = '';

                        // Salidas Extras
                        if (cant_salidas_extra > 0)
                        {
                            var nro_salida = 0;

                            PizarraExtra.valores.each(function (salida, idx)
                            {
                                nro_salida = idx + 2;
                                name = 'valor_' + nro_salida + '_' + pos;
                                html += '<td>' + draw_pre_pos(salida.prefijo, 'td_' + name, salida.posfijo) + '</td>';

                                if (salida.campo_def)
                                {
                                    evaluar.push('campos_defs.add("' + name + '", get_campo_def_options("' + salida.campo_def + '", "td_' + name + '", 0, ' + pos + '));'); // Crear
                                }
                                else
                                {
                                    nro_campo_tipo = Number(ar_tipo_dato[salida.tipo_dato].nro_campo_tipo) || 104;

                                    if (nro_campo_tipo != 105)
                                    {
                                        evaluar.push('campos_defs.add("' + name + '", get_campo_def_options("", "td_' + name + '", ' + nro_campo_tipo + ', ' + pos + '));'); // Crear
                                    }
                                    else
                                    {
                                        // Dibuja un CHECKBOX
                                        var html_chk = "<table class='tb1'><tr><td style='text-align: center;'><input type='checkbox' name='" + name + "' id='" + name + "' style='cursor: pointer;' /></td></tr></table>";
                                        eval_cdef.push("$('td_" + name + "').innerHTML = \"" + html_chk + "\";");
                                        eval_cdef.push("cambiarEstado('valor_" + name + "', " + true + ");");
                                    }
                                }

                                PizarraDet[pos]['valor_' + nro_salida] = '';
                            })
                        }

                        html += '<td>&nbsp;</td>';
                        html += '</tr>';
                    });

                    // Insertar el HTML
                    if (html)
                    {
                        // Elimino las filas de datos anteriores del dibujo
                        $div_pizarra_det.select('#tbDetalles > tbody')[0].childElements().each(function (tr, pos)
                        {
                            if (pos > 2) tr.remove();
                        });

                        try
                        {
                            $div_pizarra_det.select('#tbDetalles > tbody')[0].insert({ bottom: html });
                        }
                        catch (e)
                        {
                            nvFW.bloqueo_desactivar(null, 'vidrio_cubo');
                            alert('Ocurrió un error al dibujar la pizarra en forma de CUBO. Consulte con el administrador de Sistemas.');
                            return;
                        }
                    }

                    // Evaluar
                    if (evaluar.length)
                    {
                        evaluar.each(function (item)
                        {
                            eval(item);
                        });
                    }

                    nvFW.bloqueo_desactivar(null, 'vidrio_cubo');
                }
                catch (e)
                {
                    nvFW.bloqueo_desactivar(null, 'vidrio_cubo');
                }
            }
        }


        function bloquear_datos_cubo(deshabilitar)
        {
            for (var i = 0; i < PizarraDef.length; i++)
            {
                $('campo_def_' + i).disabled   = deshabilitar;
                $('tiene_hasta_' + i).disabled = deshabilitar;
                $('limite_' + i).disabled      = deshabilitar;
            }

            if (!Pizarra.cubo)
            {
                pizarra_descartar_detalles_generados();
            }
        }


        function bloquear_detalles_cubo(deshabilitar)
        {
            var cant_datos = PizarraDef.length;

            for (var i = 0, n = PizarraDet.length; i < n; i++)
            {
                for (var j = 1; j <= cant_datos; j++)
                {
                    if (!campos_defs.items['dato' + j + '_desde_' + i])
                        break;

                    campos_defs.habilitar('dato' + j + '_desde_' + i, !deshabilitar);
                }
            }
        }


        function quitar_eliminar_detalles()
        {
            $div_pizarra_det.select('#tbDetalles img[alt=Eliminar]').each(function (imagen)
            {
                imagen.replace('&nbsp;');
            });
        }


        function quitar_mover_detalles()
        {
            $div_pizarra_det.select('#tbDetalles img[alt=Subir]', '#tbDetalles img[alt=Bajar]').each(function (icono)
            {
                icono.replace('&nbsp;'); // Icono por espacio en blanco
            });
        }


        /*-------------------------------------------------
        |   CUBO: descarte de detalles generados
        |--------------------------------------------------
        |   Sólo elimina/descarta los detalles que no
        |   hayan sido guardados.
        |------------------------------------------------*/
        function pizarra_descartar_detalles_generados()
        {
            var i = 0;
            var n = PizarraDet.length;

            while (n != i)
            {
                if (PizarraDet[i].id_calc_piz_det == 0)
                {
                    PizarraDet.splice(i, 1);
                    n--;
                }
                else
                {
                    i++;
                }
            }

            pizarra_dibujar_detalles();
        }


        /*---------------------------------------------------------------------
        |   CUBO: Comprobación de cambios
        |----------------------------------------------------------------------
        |   Comprueba si existen nuevas combinaciones o bien si hay algunas
        |   de ellas que son obsoletas.
        |
        |   Ésto puede suceder si los valores de los campos defs que definen
        |   el CUBO han variado/cambiado.
        |--------------------------------------------------------------------*/
        function pizarra_cubo_comprobar_cambios()
        {
            // Revisar que no haya combinaciones repetidas en la pizarra actual
            var resultadoRepetidas = verificar_combinaciones_repetidas();

            if (resultadoRepetidas.hayRepetidas)
            {
                var msj = '<br/>Existen <b>combinaciones repetidas</b> en la pizarra actual. Por favor, revise y elimine las que sean necesarias.<br>Listado:<br>';
                var ids = [];

                for (var i = 0; i < resultadoRepetidas.combinaciones.length; i++)
                {
                    ids = resultadoRepetidas.combinaciones[i].split(separador);

                    for (var j = 0; j < ids.length; j++)
                    {
                        msj += PizarraDef[j].etiqueta + ' (' + ids[j] + ') ';
                    }

                    msj += '</br>';
                }

                alert(msj,
                {
                    title: '<b>Combinaciones repetidas</b>',
                    width: 450,
                    height: 150
                });

                // Revertir el valor booleano de Pizarra.cubo
                Pizarra.cubo = !Pizarra.cubo;
                return false;
            }

            var datos = [];

            PizarraDef.each(function (dato)
            {
                datos.push(dato.campo_def);
            });

            nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx',
            {
                parameters:
                {
                    modo: 'cubo_get_combinaciones',
                    datos: datos.join(',')
                },
                onSuccess: function (err)
                {
                    var cant_combinaciones = parseInt(err.params.total);
                    // Contar todos los detalles de la pizarra que no tengan ID negativo,
                    // es decir que no estén para eliminar
                    var cant_detalles_validos = 0;

                    PizarraDet.each(function (detalle)
                    {
                        if (parseInt(detalle.id_calc_piz_det) > -1)
                        {
                            cant_detalles_validos++;
                        }
                    });

                    if (!isNaN(cant_combinaciones) && cant_combinaciones != cant_detalles_validos)
                    {
                        /*-------------------------------------------
                        |              Hay diferencias
                        |--------------------------------------------
                        | A) Nuevas combinaciones    => AGREGAR
                        | B) Combinaciones obsoletas => ELIMINAR
                        |------------------------------------------*/
                        var combinaciones_actuales = obtener_combinaciones_actuales();
                        eval(err.params.combinaciones);
                        var combinaciones_nuevas = generar_combinaciones(combinaciones);

                        /*-------------------------------------------
                        |                   AGREGAR
                        |------------------------------------------*/
                        if (cant_combinaciones > cant_detalles_validos)
                        {
                            var cantidad_combinaciones_nuevas = pizarra_cubo_agregar_combinacion_detalle(combinaciones_actuales, combinaciones_nuevas);
                            var mensaje = '';

                            if (cantidad_combinaciones_nuevas == 1)
                            {
                                mensaje = '<br/>Hay 1 nueva combinación para el <b>cubo</b> actual. Se ha agregado a la pizarra.';
                            }
                            else
                            {
                                mensaje = '<br/>Hay ' + cantidad_combinaciones_nuevas + ' nuevas combinaciones para el <b>cubo</b> actual. Se han agregado a la pizarra.';
                            }

                            alert(mensaje,
                            {
                                title: '<b>Nuevas combinaciones agregadas</b>'
                            });

                            nvFW.bloqueo_activar($body, 'bloq_pizarra', 'Cargando detalles...');
                        }
                        /*-------------------------------------------
                        |                  ELIMINAR
                        |------------------------------------------*/
                        else
                        {
                            var cantidad_combinaciones_obsoletas = pizarra_cubo_eliminar_combinacion_detalle(combinaciones_actuales, combinaciones_nuevas);
                            var mensaje = '';

                            if (cantidad_combinaciones_obsoletas == 1)
                            {
                                mensaje = '<br/>Hay 1 combinación obsoleta en el <b>cubo</b> actual. Se ha eliminado de la pizarra.';
                            }
                            else
                            {
                                mensaje = '<br/>Hay ' + cantidad_combinaciones_obsoletas + ' combinaciones obsoletas para el <b>cubo</b> actual. Se han eliminado de la pizarra.';
                            }

                            alert(mensaje,
                            {
                                title: '<b>Combinaciones obsoletas eliminadas</b>'
                            });

                            nvFW.bloqueo_activar($body, 'bloq_pizarra', 'Cargando detalles...');
                        }

                        // Después de agregar o quitar combinaciones, dibujamos
                        pizarra_dibujar_detalles();

                        if (Pizarra.cubo && !Pizarra.matriz)
                        {
                            bloquear_datos_cubo(true);      // Bloqueo de datos en Definición
                            bloquear_detalles_cubo(true);   // Bloqueo de Detalles
                            quitar_eliminar_detalles();     // Quitar los iconos de eliminar
                            quitar_mover_detalles();        // Quitar los iconos de mover detalles
                        }
                    }
                },
                onFailure: function (err)
                {
                    alert('Ocurrio un error al comprobar si hubo cambios',
                    {
                        title: '<b>Error</b>'
                    });
                },
                bloq_contenedor_on: false,
                error_alert: false
            });

            return true;
        }


        function generar_combinaciones(arreglos)
        {
            var combinaciones = [];

            if (!arreglos.length)
                return combinaciones;

            arreglos.each(function (arreglo)
            {
                combinaciones.push(arreglo.join(separador));
            });

            return combinaciones;
        }


        function obtener_combinaciones_actuales(names_campos_def)
        {
            /*-----------------------------------------------------------------
            |   IMPORTANTE!
            |------------------------------------------------------------------
            |   Los valores de detalles a obtener tienen que ser Campos_Defs
            |   sí o sí.
            |----------------------------------------------------------------*/
            var datos_def      = obtener_indices_datos_def(names_campos_def);
            var cantidad_datos = datos_def.length;
            var combinaciones  = [];
            var combinacion    = [];
            var i = 1;

            actualizar_vector_detalles();

            PizarraDet.each(function (detalle)
            {
                if (Number(detalle.id_calc_piz_det) >= 0)
                {
                    combinacion = [];

                    for (i = 1; i <= cantidad_datos; i++)
                    {
                        combinacion.push(detalle['dato' + i + '_desde']);
                    }

                    combinaciones.push(combinacion.join(separador));
                }
            });

            return combinaciones;
        }


        function obtener_indices_datos_def(names_campos_def)
        {
            var salida = [];

            for (var i = 0, n = PizarraDef.length; i < n; i++)
            {
                if (PizarraDef[i].campo_def && !PizarraDef[i].tiene_hasta)
                {
                    if (names_campos_def)
                    {
                        if (names_campos_def.indexOf(PizarraDef[i].campo_def) > -1)
                        {
                            salida.push(PizarraDef[i].dato_orden);
                        }
                    }
                    // Si no se pasan los nombres de los campos_defs se retorna un vector con
                    // todos los indices de orden de los datos con campos_defs
                    else
                    {
                        salida.push(PizarraDef[i].dato_orden);
                    }
                }
            }

            return salida;
        }


        /*---------------------------------------------------------------------
        |   CUBO: agregar combinaciones
        |----------------------------------------------------------------------
        |   En éste caso, siempre se da que las combinaciones nuevas son más
        |   que las combinaciones actuales:
        |
        |   combinaciones_nuevas > combinaciones_actuales
        |--------------------------------------------------------------------*/
        function pizarra_cubo_agregar_combinacion_detalle(combinaciones_actuales, combinaciones_nuevas)
        {
            var continuar      = true;
            var i = 0;
            var valor_nuevo    = '';
            var iteracion      = 0;
            var MAX_ITERATIONS = 10000;

            while (continuar)
            {
                iteracion++;
                valor_nuevo = combinaciones_nuevas[i];

                // Recorro todos los valores del vector de combinaciones_actuales
                if (combinaciones_actuales.indexOf(valor_nuevo) == -1)
                {
                    i++;
                }
                else
                {
                    for (var j = 0; j < combinaciones_actuales.length; j++)
                    {
                        if (combinaciones_actuales[j] == valor_nuevo)
                        {
                            combinaciones_actuales.splice(j, 1);
                        }
                    }

                    combinaciones_nuevas.splice(i, 1);
                }

                if (!combinaciones_actuales.length || iteracion >= MAX_ITERATIONS)
                {
                    continuar = false;
                }
            }

            var nro_fila           = PizarraDet.length;
            var valores_def        = null;
            var cant_datos         = PizarraDef.length;
            var cant_salidas_extra = PizarraExtra.valores.length;

            // Array "combinaciones_nuevas" => combinaciones a que tenemos que agregar
            combinaciones_nuevas.each(function (combination)
            {
                valores_def = combination.split(separador);

                // Llenar arreglo con cada dato de la fila
                PizarraDet[nro_fila] = [];
                PizarraDet[nro_fila].id_calc_piz_det = 0;

                // Datos
                for (var indice = 0; indice < cant_datos; indice++)
                {
                    PizarraDet[nro_fila]['dato' + (indice + 1) + '_desde'] = valores_def[indice];
                    PizarraDet[nro_fila]['dato' + (indice + 1) + '_hasta'] = '';
                }

                PizarraDet[nro_fila].valor_1 = '';

                // Salidas Extras
                if (cant_salidas_extra)
                {
                    var nro_salida = 0;

                    for (var idx = 0; idx < PizarraExtra.length; idx++)
                    {
                        nro_salida = idx + 2;
                        PizarraDet[nro_fila]['valor_' + nro_salida] = '';
                    }
                }

                nro_fila++;
            });

            return combinaciones_nuevas.length;
        }


        /*---------------------------------------------------------------------
        |   CUBO: eliminar combinaciones
        |----------------------------------------------------------------------
        |   En éste caso, siempre se da que las combinaciones actuales son más
        |   que las combinaciones nuevas:
        |
        |   combinaciones_actuales > combinaciones_nuevas
        |
        |   Por lo tanto, en combinaciones_actuales quedaran los registros 
        |   a borrar.
        |--------------------------------------------------------------------*/
        function pizarra_cubo_eliminar_combinacion_detalle(combinaciones_actuales, combinaciones_nuevas)
        {
            var continuar    = true;
            var i = 0;
            var valor_actual = '';
            var indices      = [];
            var i_real       = 0;

            while (continuar)
            {
                valor_actual = combinaciones_actuales[i];

                // Recorro todos los valores del vector de combinaciones_nuevas
                if (combinaciones_nuevas.indexOf(valor_actual) == -1)
                {
                    indices.push(i_real);
                    i++;
                }
                else
                {
                    for (var j = 0; j < combinaciones_nuevas.length; j++)
                    {
                        if (combinaciones_nuevas[j] == valor_actual)
                        {
                            combinaciones_nuevas.splice(j, 1)
                        }
                    }

                    combinaciones_actuales.splice(i, 1);
                }

                i_real++;

                if (!combinaciones_nuevas.length)
                {
                    continuar = false;
                }
            }

            // Eliminar todas las filas a partir del arreglo de indices (i_real)
            if (indices.length > 0)
            {
                indices.each(function (indice)
                {
                    if (PizarraDet[indice].id_calc_piz_det == 0)
                    {
                        PizarraDet.splice(indice, 1);
                    }
                    else
                    {
                        PizarraDet[indice].id_calc_piz_det *= -1;
                    }
                });
            }

            return indices.length;
        }


        /*---------------------------------------------------------------------
        |   Generación de combinaciones
        |----------------------------------------------------------------------
        |   Función de utiidad para generar todas las combinaciones entre
        |   diferentes campos defs sin estar en modo CUBO.
        |--------------------------------------------------------------------*/
        function pizarra_generar_combinaciones()
        {
            if (!nro_calc_pizarra)
            {
                alert('Debe guardar la pizarra antes de generar combinaciones de detalles.',
                {
                    title: '<b>Información</b>'
                });

                return false;
            }
            else
            {
                if (Pizarra.cubo || Pizarra.matriz)
                {
                    alert('No es posible generar combinaciones en modo <b>cubo</b> y/o <b>matriz</b>.',
                    {
                        title: '<b>Información</b>',
                        width: 350
                    });

                    return;
                }
                else
                {
                    // Generar un HTML con columnas que se quieren/pueden combinar
                    var contador = 1;
                    var html = '';
                    html += '<table class="tb1" style="font-size: 13px;">';
                    html += '<tr style="height: 19px;"><td>&nbsp;A continuación, seleccione los elementos que desea combinar:</td></tr>';
                    html += '<tr style="height: 5px;"><td></td></tr>';
                    html += '</table>';
                    html += '<table class="tb1 highlightOdd highlightTROver" id="tbCombinaciones" style="font-size: 13px;">';

                    PizarraDef.each(function (dato)
                    {
                        if (dato.campo_def && !dato.tiene_hasta)
                        {
                            html += '<tr>';
                            html += '<td style="width: 50px; text-align: center;">';
                            html += '<input type="checkbox" name="chk_' + contador + '" id="chk_' + contador + '" value="' + dato.campo_def + '" style="cursor: pointer;"  title="' + dato.etiqueta + '"/>';
                            html += '</td>';
                            html += '<td onclick="$(\'chk_' + contador + '\').click(); nvFW.selection_clear();">&nbsp;' + dato.etiqueta + '</td>';
                            html += '</tr>';

                            contador++;
                        }
                    });

                    html += '</table>';

                    var win_combinaciones_posibles = nvFW.confirm(html,
                    {
                        title: '<b>Combinaciones posibles</b>',
                        okLabel: 'Combinar',
                        cancelLabel: 'Cancelar',
                        width: 400,
                        height: 150,
                        onOk: pizarra_generar_combinaciones_onclose,
                        onCancel: function (w)
                        {
                            w.close();
                        }
                    });

                    win_combinaciones_posibles.showCenter();
                }
            }
        }


        function pizarra_generar_combinaciones_onclose(win)
        {
            var titulo = '<b>Info Combinaciones</b>';
            var chks   = $('tbCombinaciones').select('input[type=checkbox]:checked');

            if (!chks.length)
            {
                win.close();
                alert('No se seleccionó ningún dato. Se retorna a la aplicación.', { title: titulo });
                return false;
            }
            else
            {
                if (chks.length < 2)
                {
                    alert('Debe seleccionar al menos 2 datos para generar combinaciones.', { title: titulo });
                    return false;
                }
                else
                {
                    // Generar combinaciones
                    var campos_def = [];

                    for (var i = 0; i < chks.length; i++)
                    {
                        campos_def.push(chks[i].value);
                    }

                    // Con lista de "campos_def" obtener producto cartesiano (combinaciones)
                    nvFW.error_ajax_request('/FW/pizarra/calculos_pizarra_ABM.aspx',
                    {
                        parameters:
                        {
                            modo: 'cubo_get_combinaciones',
                            datos: campos_def.join(',')
                        },
                        onSuccess: function (err)
                        {
                            if (Number(err.params.total) > 0)
                            {
                                // Después de evaluar, estará disponible el vector de combinaciones
                                eval(err.params.combinaciones);
                                var campos_def    = err.params.campos_def.split(',');
                                // Obtener vectores de combinaciones
                                var comb_actuales = obtener_combinaciones_actuales(campos_def);
                                var comb_nuevas   = generar_combinaciones(combinaciones);
                                // Comparar ambos vectores
                                var mensaje = '';
                                var accion  = null;
                                var filas   = [];

                                switch (comparar_combinaciones(comb_actuales, comb_nuevas, filas))
                                {
                                    case -1:
                                        mensaje = 'No es posible comprobar si existen combinaciones.';
                                        break;

                                    case 0:
                                        mensaje = 'Todas las combinaciones posibles ya se encuentran en la pizarra o no existen nuevas combinaciones posibles.';
                                        break;

                                    case 1:
                                        mensaje = 'Actualmente existe una o más combinaciones repetidas. ¿Desea quitarlas?';
                                        accion = 'quitar_combinaciones(filas);';
                                        break;

                                    case 2:
                                        mensaje = 'Existen nuevas combinaciones a agregar. ¿Desea agregarlas?';
                                        accion = 'agregar_combinaciones(comb_nuevas, campos_def);';
                                        break;
                                }

                                win.close();

                                if (!accion)
                                {
                                    alert(mensaje, { title: titulo });
                                    return;
                                }
                                else
                                {
                                    nvFW.confirm(mensaje,
                                    {
                                        title: titulo,
                                        onOk: function (w)
                                        {
                                            w.close();
                                            eval(accion);
                                            pizarra_dibujar_detalles();
                                        },
                                        okLabel: 'Aceptar',
                                        cancelLabel: 'Cancelar'
                                    });

                                    return;
                                }
                            }
                        },
                        onFailure: function (err)
                        {
                            win.close()
                        },
                        bloq_contenedor_on: false,
                        error_alert: false
                    });
                }
            }
        }


        function comparar_combinaciones(actuales, nuevas, filas)
        {
            actualizar_vector_detalles();

            /*-----------------------------------
            |  Valores de salida
            |------------------------------------
            |    0: iguales
            |    1: actuales > nuevas
            |    2: nuevas > actuales
            |   -1: error
            |----------------------------------*/
            if ((!actuales.length && !nuevas.length) || (actuales.length == nuevas.length))
            {
                return 0;
            }

            if (!actuales.length || !nuevas.length)
            {
                return -1;
            }

            var p        = -1;
            var nro_fila = 0;

            for (var i = 0; i < actuales.length; i++)
            {
                p = nuevas.indexOf(actuales[i]);

                if (p > -1)
                {
                    // Combinación presente en ambos vectores => borrar de ambos
                    nuevas.splice(p, 1);
                    actuales.splice(p, 1);
                    i--;
                }
                else
                {
                    filas.push(nro_fila);
                }

                nro_fila++;
            }

            return actuales.length == nuevas.length ? 0 : (actuales.length > nuevas.length ? 1 : 2);
        }


        function agregar_combinaciones(combinaciones, target)
        {
            for (var fila = 0; fila < combinaciones.length; fila++)
            {
                var campos_def_ids = combinaciones[fila].split(separador);

                // Armar un nuevo Detalle
                var nuevo_detalle = [];
                nuevo_detalle.id_calc_piz_det = '0';
                nuevo_detalle.valor_1         = '';
                nuevo_detalle.valor_2         = '';
                nuevo_detalle.valor_3         = '';

                // Agregar al Detalle los valores de la definicion (datos)
                for (var i = 0; i < PizarraDef.length; i++)
                {
                    var nombre_campodef = PizarraDef[i].campo_def;
                    var nombre_detalle  = 'dato' + PizarraDef[i].dato_orden;

                    if (nombre_campodef)
                    {
                        // Buscar el nombre del campo def en "target" y con esa posición obtener el valor desde la combinacion actual
                        var posicion = target.indexOf(nombre_campodef);
                        var valor    = posicion == -1 ? '' : campos_def_ids[posicion];

                        nuevo_detalle[nombre_detalle + '_desde'] = valor;
                    }
                    else
                    {
                        // No es campo_def => Agrego las entradas vacias al objeto
                        nuevo_detalle[nombre_detalle + '_desde'] = '';

                        if (PizarraDef[i].tiene_hasta)
                        {
                            nuevo_detalle[nombre_detalle + '_hasta'] = '';
                        }
                    }
                }

                PizarraDet.push(nuevo_detalle);
            }
        }


        function quitar_combinaciones(filas_eliminar)
        {
            var indice = null;
            var valor  = null;

            // Recorrer en sentido inverso porque el array se va decrementanto en caso de realizar un 'splice'
            for (var i = filas_eliminar.length - 1; i >= 0; i--)
            {
                indice = filas_eliminar[i];
                valor  = PizarraDet[indice].id_calc_piz_det;

                if (!Number(valor))
                {
                    PizarraDet.splice(indice, 1);
                }
                else
                {
                    PizarraDet[indice].id_calc_piz_det = '-' + valor;
                }
            }
        }


        /*---------------------------------------------------------------------
        |   Verifica si hay alguna combinación repetida. Retorna un valor
        |   booleano en "true" si hubo al menos una repetición dentro de las
        |   combinaciones de los ID de los campos def.
        |
        |   Ejemplos:
        |       CASO A:
        |           Vector Combinaciones: ["5__6", "5__8", "5__14"]
        |           Combinacion buscada:  "5__12"
        |           Salida:               false
        |
        |       CASO B:
        |           Vector Combinaciones: ["5__6", "5__8", "5__14"]
        |           Combinacion buscada:  "5__14"
        |           Salida:               true
        |
        |   El algoritmo deja de buscar en cuanto se encuentre la primer
        |   repetición dentro del vector de combinaciones actuales.
        |--------------------------------------------------------------------*/
        function verificar_combinaciones_repetidas()
        {
            var hayRepetidas            = false;
            var combinacionesRepetidas  = [];
            var combinaciones_presentes = obtener_combinaciones_actuales();

            for (var i = 0, n = combinaciones_presentes.length; i < n; i++)
            {
                var valor_actual = combinaciones_presentes[i];

                for (var j = i + 1; j < n; j++)
                {
                    if (combinaciones_presentes[j] == valor_actual)
                    {
                        hayRepetidas = true;
                        combinacionesRepetidas.push(valor_actual);
                    }
                }
            }

            return {
                hayRepetidas: hayRepetidas,
                combinaciones: combinacionesRepetidas
            };
        }


        // Apertura de ventana de historicos de la pizarra actual
        function pizarra_historico()
        {
            var winHistoricos = nvFW.createWindow({
                url: "/FW/pizarra/calculos_pizarra_historico.aspx?nro_calc_pizarra=" + nro_calc_pizarra,
                title: "<b>Históricos Pizarra " + nro_calc_pizarra + "</b>",
                width: 700,
                height: 250,
                maximizable: false,
                resizable: false,
                destroyOnClose: true,
                onClose: function (win)
                {
                    if (win.options && win.options.userData && win.options.userData.cargarHistorico)
                    {
                        pizarra_historico_cargar(win.options.userData.fecha, win.options.userData.login);
                    }
                }
            });

            winHistoricos.options.userData = {
                cargarHistorico: false,
                fecha: '',
                login: ''
            };

            winHistoricos.showCenter(true);
        }


        function pizarra_historico_cargar(strFecha, strLogin)
        {
            var newUrl    = window.location.origin + window.location.pathname;
            var searchUrl = window.location.search;
            var index     = searchUrl.indexOf('&fe_log=');

            if (index !== -1)
            {
                // Quitar del query string todo lo realcionado al parametro "&fe_log="
                searchUrl = searchUrl.substring(0, index);
            }

            searchUrl += '&fe_log=' + strFecha + '&login_log=' + strLogin;
            newUrl    += searchUrl;
            // Actualizo el título de la ventana principal
            winPrincipal.setTitle('<b>Pizarra desde Histórico</b>');
            window.location.replace(newUrl);
        }


        <% If load_from_log Then %>
        function pizarra_restaurar()
        {
            nvFW.confirm('<br/>¿Desea restaurar la pizarra <b>' + nro_calc_pizarra + '</b> con ésta versión?<br/><br/><b>Fecha: </b><i>' + nvFW.pageContents.fe_to_show + '</i><br/><b>Operador: </b><i>' + nvFW.pageContents.login_log + '</i>',
            {
                title: '<b>Confirmar restauración</b>',
                width: 450,
                height: 150,
                cancelLabel: 'Cancelar',
                okLabel: 'Restaurar',
                onOk: function (win)
                {
                    var puedeGuardar = true;

                    // Verificar si tiene permisos
                    if (!nvFW.tienePermiso('permisos_web5', 8))
                    {
                        alert('No tiene permiso para editar datos de la estructura');
                        puedeGuardar = false;
                    }

                    if (!nvFW.tienePermiso(nvFW.pageContents.pizPermiso_grupo, nvFW.pageContents.pizPermiso_nro_editar))
                    {
                        alert('No tiene permiso de edición de ésta pizarra');
                        puedeGuardar = false;
                    }

                    if (puedeGuardar)
                    {
                        nvFW.error_ajax_request('calculos_pizarra_ABM.aspx',
                        {
                            parameters:
                            {
                                modo: 'M',
                                strXML: generarXML(),
                                edita_def: true,
                                edita_det: true
                            },
                            onSuccess: function (err)
                            {
                                nvFW.alert('Pizarra Nº ' + nro_calc_pizarra + ' restaurada correctamente.',
                                {
                                    title: '<b>Info restauración</b>',
                                    onOk: function (win)
                                    {
                                        win.close();
                                        pizarra_cargar_ultima_version(false);
                                    }
                                })
                            },
                            onFailure: function (err)
                            {
                                win.close();
                            },
                            bloq_contenedor: $$('body')[0],
                            bloq_msg: 'Restaurando...'
                        });
                    }
                    else
                    {
                        win.close();
                    }
                }
            });
        }


        function pizarra_cargar_ultima_version(pedirConfirmacion)
        {
            pedirConfirmacion = pedirConfirmacion === undefined ? true : pedirConfirmacion;

            if (pedirConfirmacion)
            {
                nvFW.confirm('¿Desea recargar la pizarra con la versión original?',
                {
                    cancelLabel: 'Cancelar',
                    okLabel: 'Recargar',
                    onOk: function (win)
                    {
                        winPrincipal.setTitle('<b>Pizarra Edición</b>');
                        win.close();
                        pizarra_recargar();
                    }
                });
            }
            else
            {
                winPrincipal.setTitle('<b>Pizarra Edición</b>');
                pizarra_recargar();
            }
        }


        function pizarra_recargar()
        {
            var newUrl    = window.location.origin + window.location.pathname;
            var searchUrl = window.location.search;
            var index     = searchUrl.indexOf('&fe_log=');

            if (index !== -1) {
                // Quitar del query string todo lo realcionado al parametro "&fe_log="
                searchUrl = searchUrl.substring(0, index);
            }

            newUrl += searchUrl;
            window.location.replace(newUrl);
        }
        <% end if %>
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
    <%-- Antes de dibujar los elementos HTML, mando el bloqueo --%>
    <script type="text/javascript">nvFW.bloqueo_activar($$("body")[0], "bloq_pizarra", "Cargando pizarra...")</script>

    <form method="post" name="form1" target="frmEnviar" style="width: 100%; height: 100%; margin: 0;" novalidate="novalidate" autocomplete="off">
        <div id="divPizarraDatos">
            <div id="divMenuPizarras" style="width: 100%; margin: 0px; padding: 0px"></div>
            <script type="text/javascript">
                var vMenuPizarras = new tMenu('divMenuPizarras', 'vMenuPizarras');
                vMenuPizarras.loadImage("guardar", "/FW/image/icons/guardar.png");
                Menus["vMenuPizarras"] = vMenuPizarras;
                Menus["vMenuPizarras"].alineacion = 'centro';
                Menus["vMenuPizarras"].estilo = 'A';

            <% If load_from_log %>
            <%-- Menú exclusivo para LOGS --%>
            vMenuPizarras.loadImage("abm", "/FW/image/icons/abm.png");
            vMenuPizarras.loadImage('reload', '/FW/image/icons/periodicidad.png');
            Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Restaurar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_restaurar()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc> </Desc></MenuItem>");
            Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Opciones Avanzadas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_opciones_avanzadas()</Codigo></Ejecutar></Acciones></MenuItem>");
            Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>reload</icono><Desc>Cargar última versión</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_cargar_ultima_version()</Codigo></Ejecutar></Acciones></MenuItem>");
            <% Else %>
                <% If Not permiso_edicion_estructura Then %>
                <%-- Solo puede guardar cambios de DETALLES. Opción "Guardar como...": no puede utilizarlo porque es creación de estructura --%>
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_guardar_wrapper()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='1' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc> </Desc></MenuItem>");
                <% Else %>
                vMenuPizarras.loadImage("historico", "/FW/image/icons/inspeccionar.png");
                vMenuPizarras.loadImage("abm", "/FW/image/icons/abm.png");
                vMenuPizarras.loadImage("editar", "/FW/image/icons/editar.png");
                vMenuPizarras.loadImage("nuevo", "/FW/image/icons/agregar.png");
                vMenuPizarras.loadImage("eliminar", "/FW/image/icons/eliminar.png");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_guardar_wrapper()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar como...</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_guardar_como()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='2' style='width: 100%; text-align: center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc> </Desc></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='3' style='display: none;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>historico</icono><Desc>Históricos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_historico()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='4' style='display: none;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>abm</icono><Desc>Op. Avanzadas</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_opciones_avanzadas()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>editar</icono><Desc>Editar Pizarra</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_editar()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='6' style='display: none;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>nuevo</icono><Desc>Nueva Pizarra</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_nueva()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarras"].CargarMenuItemXML("<MenuItem id='7' style='display: none;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar Pizarra</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_eliminar()</Codigo></Ejecutar></Acciones></MenuItem>");
                <% End If %>
            <% End If %>

                vMenuPizarras.MostrarMenu();
            </script>
        </div>

        <div id="div_pizarra" style="display: none;">
            <table id="tb_pizarra" class="tb1">
                <tr class="tbLabel">
                    <td style="width: 4%; text-align: center">Nro</td>
                    <td style="text-align: center">Pizarra</td>
                    <td style="width: 15%; text-align: center">Etiqueta</td>
                    <td style="width: 15%; text-align: center">Tipo Dato</td>
                    <td style="width: 15%; text-align: center">Campo Def</td>
                    <td style="width: 6%; text-align: center" title="Auto Ordenado">Aut. Orden</td>
                    <td style="width: 8%; text-align: center">Prefijo</td>
                    <td style="width: 8%; text-align: center">Posfijo</td>
                    <td style="width: 8%; text-align: center;">Ancho px</td>
                </tr>
                <tr>
                    <td style="width: 4%">
                        <input type="text" id="txt_nro_calc_pizarra" name="txt_nro_calc_pizarra" value="" disabled="disabled" style="width: 100%; text-align: center;" />
                    </td>
                    <td style="text-align: left">
                        <input type="text" id="calc_pizarra" name="calc_pizarra" value="" style="width: 100%" title="Nombre de la pizarra" />
                    </td>
                    <td style="width: 15%;">
                        <input type="text" id="etiqueta_cab" name="etiqueta_cab" value="" style="width: 100%" title="Etiqueta que aparecerá en la anteúltima cabecera de la tabla de detalles.&#13;Por defecto es 'Valor'" />
                    </td>
                    <td style="width: 15%; text-align: left">
                        <script type="text/javascript">document.write(obtener_select_tipoDato('tipo_dato'))</script>
                    </td>
                    <td style="width: 15%">
                        <script type="text/javascript">document.write(campo_def_cargar("cab", ""))</script>
                    </td>
                    <td style="width: 6%; text-align: center;">
                        <input type="checkbox" name="auto_ordenada" id="auto_ordenada" title="Auto ordenado" style="cursor: pointer;" onclick="return showHideOrdenar(this)" />
                    </td>
                    <td style="text-align: left; width: 8%">
                        <input type="text" id="prefijo" name="prefijo" value="" style="width: 100%" />
                    </td>
                    <td style="text-align: left; width: 8%">
                        <input type="text" id="posfijo" name="posfijo" value="" style="width: 100%" />
                    </td>
                    <td style="width: 8%; text-align: right;">
                        <input type="number" min="0" name="width_cab" id="width_cab" value="" onkeypress="return valDigito(event, '-.');" style="width: 100%; text-align: right;" title="Unidades en pixeles (PX)" />
                    </td>
                </tr>
            </table>
        </div>

        <div id="divPizarraDef" style="display: none;">
            <div id="divMenuPizarraDef"></div>
            <script type="text/javascript">
                var vMenuPizarraDef = new tMenu('divMenuPizarraDef', 'vMenuPizarraDef');
                Menus["vMenuPizarraDef"] = vMenuPizarraDef;
                Menus["vMenuPizarraDef"].alineacion = "centro";
                Menus["vMenuPizarraDef"].estilo = "A";

                vMenuPizarraDef.loadImage("agregar1", "/FW/image/icons/agregar.png");

                Menus["vMenuPizarraDef"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%; text-align:center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Datos</Desc></MenuItem>");
                <% If Not load_from_log %>
                Menus["vMenuPizarraDef"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar1</icono><Desc>Nuevo Dato</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_nueva_definicion()</Codigo></Ejecutar></Acciones></MenuItem>");
                <% End If %>

                vMenuPizarraDef.MostrarMenu();
            </script>
        </div>

        <div id="div_pizarra_def" style="width: 100%; overflow: hidden;"></div>

        <div id="divPizarraDet" style="display: none;">
            <div id="divMenuPizarraDet" style="width: 100%"></div>
            <script type="text/javascript">
                var vMenuPizarraDet = new tMenu('divMenuPizarraDet', 'vMenuPizarraDet');
                Menus["vMenuPizarraDet"] = vMenuPizarraDet;
                Menus["vMenuPizarraDet"].alineacion = "centro";
                Menus["vMenuPizarraDet"].estilo = "A";

                <% If Not load_from_log Then %>
                vMenuPizarraDet.loadImage("filtrar", "/meridiano/image/icons/filtrar.png");
                vMenuPizarraDet.loadImage("tablas", "/FW/image/icons/tablas.png");
                vMenuPizarraDet.loadImage("excel", "/FW/image/filetype/excel.png");
                Menus["vMenuPizarraDet"].CargarMenuItemXML("<MenuItem id='0'><Lib TipoLib='offLine'>DocMNG</Lib><icono>filtrar</icono><Desc>Filtro</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_ver_filtro()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarraDet"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>tablas</icono><Desc>Generar combinaciones</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_generar_combinaciones()</Codigo></Ejecutar></Acciones></MenuItem>");
                Menus["vMenuPizarraDet"].CargarMenuItemXML("<MenuItem id='2' style='WIDTH: 100%; text-align:center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Detalles</Desc></MenuItem>");
                Menus["vMenuPizarraDet"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>excel</icono><Desc>Exportar Excel</Desc><Acciones><Ejecutar Tipo='script'><Codigo>pizarra_exportar_excel()</Codigo></Ejecutar></Acciones></MenuItem>");
                <% Else %>
                Menus["vMenuPizarraDet"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%; text-align:center;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Detalles</Desc></MenuItem>");
                <% End If %>

                vMenuPizarraDet.MostrarMenu();
            </script>
        </div>

        <div id="div_pizarra_det" style="width: 100%; overflow: auto;"></div>
    </form>

    <iframe id="iframe_excel" name="iframe_excel" style="display: none;"></iframe>
</body>
</html>