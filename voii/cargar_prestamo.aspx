<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    ' Obtener información básica del cliente
    Dim cuit As String = nvFW.nvUtiles.obtenerValor("cuit", "")
    Dim tipoDoc As String = ""
    Dim nroDoc As String = ""
    Dim sexo As String = ""
    Dim edad As Integer = 0
    Dim apellido As String = ""
    Dim nombres As String = ""
    Dim estCivil As String = ""
    Dim feNacimiento As String = "1/1/1900"

    If cuit <> "" Then
        Try
            Dim strSQL As String = "SELECT TOP 1 tipdocdesc, nrodoc, cliape, clinom, CASE WHEN clisexo = 'M' THEN 'MASCULINO' ELSE 'FEMENINO' END AS clisexo, cliestcivcoddesc, CONVERT(VARCHAR(20), clifecnac, 103) AS clifecnac FROM VOII_prestamos WHERE nrodoc = " & cuit
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="BD_IBS_ANEXA")

            If Not rs.EOF Then
                ' Asignar todos los valores obtenidos del cliente
                tipoDoc = rs.Fields("tipdocdesc").Value
                nroDoc = rs.Fields("nrodoc").Value
                sexo = rs.Fields("clisexo").Value
                apellido = rs.Fields("cliape").Value
                nombres = rs.Fields("clinom").Value
                estCivil = rs.Fields("cliestcivcoddesc").Value
                feNacimiento = rs.Fields("clifecnac").Value ' Fecha siempre viene en formato 103 => DD/MM/YYYY

                Dim hoy As Date = Date.Now()
                Dim mesDiff As Integer = Month(hoy) - Month(feNacimiento)

                edad = Year(hoy) - Year(feNacimiento)

                If (mesDiff < 0 OrElse (mesDiff = 0 AndAlso Day(hoy) - Day(feNacimiento) < 0)) Then
                    edad -= 1
                End If

            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If


    Dim id_prestamo As String = nvFW.nvUtiles.obtenerValor("id_prestamo", "")
    Dim strArr() As String = id_prestamo.Split("-")

    ' Estructura de valores
    ' Ejemplo: "54-312-1-2-0-0-9669-9215"
    '   (0) 54: paiscod
    '   (1) 312: bcocod
    '   (2) 1: succod
    '   (3) 2: sistcod
    '   (4) 0: codsubsist
    '   (5) 0: moncod
    '   (6) 9669: cuecod
    '   (7) 9215: openro
    Dim paiscod As Integer = strArr(0)
    Dim bcocod As Integer = strArr(1)
    Dim succod As Integer = strArr(2)
    Dim sistcod As Integer = strArr(3)
    Dim codsubsist As Integer = strArr(4)
    Dim moncod As Integer = strArr(5)
    Dim cuecod As Integer = strArr(6)
    Dim openro As Integer = strArr(7)
    ' Convertir al id_prestamos en un numero sin los guines
    id_prestamo = id_prestamo.Replace("-", "")

    ' Obtener información extra del préstamo
    Dim pais As String = ""
    Dim banco As String = ""
    Dim bancoDomicilio As String = ""
    Dim bancoCUIT As String = ""
    Dim bancoBCRA As String = ""
    Dim estadoOperacion As String = ""
    Dim producto As String = ""
    Dim tipoOperDesc As String = ""
    Dim temVenc As String = ""
    Dim tnaAnual As String = ""
    Dim cft As String = ""
    Dim nroReferencia As String = ""

    If Not isNUllorEmpty(openro) Then
        Try
            Dim strSQL As String = "SELECT TOP 1 paisdesc, bcodesc, bcodomic, bcocuit, bconrobcra, estoperdesc, producto, tipoperdesc, temvenc, tnaanual, cft, nroreferencia FROM VOII_cuotas WHERE paiscod = " & paiscod & " AND bcocod = " & bcocod & " AND succod = " & succod & " AND sistcod = " & sistcod & " AND codsubsist = " & codsubsist & " AND moncod = " & moncod & " AND cuecod = " & cuecod & " AND openro = " & openro
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="BD_IBS_ANEXA")

            If Not rs.EOF Then
                pais = rs.Fields("paisdesc").Value
                banco = rs.Fields("bcodesc").Value
                bancoDomicilio = rs.Fields("bcodomic").Value
                bancoCUIT = rs.Fields("bcocuit").Value
                bancoBCRA = rs.Fields("bconrobcra").Value
                estadoOperacion = rs.Fields("estoperdesc").Value
                producto = rs.Fields("producto").Value
                tipoOperDesc = rs.Fields("tipoperdesc").Value
                temVenc = rs.Fields("temvenc").Value
                tnaAnual = rs.Fields("tnaanual").Value
                cft = rs.Fields("cft").Value
                nroReferencia = rs.Fields("nroreferencia").Value
            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
        End Try
    End If

    ' Filtro encriptado
    Me.contents("filtro_cuotas") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cuotas' cn='BD_IBS_ANEXA'><campos>nrocuo, 'Cuota final' AS detalle, CONVERT(VARCHAR(20), fecven, 103) AS fecven, monsimbolo, importe_cuota, importe_pago, importe_deuda, CONVERT(VARCHAR(20), fe_ultipago, 103) AS fe_ultipago, estopercod</campos><filtro><paiscod type='igual'>" & paiscod & "</paiscod><bcocod type='igual'>" & bcocod & "</bcocod><succod type='igual'>" & succod & "</succod><sistcod type='igual'>" & sistcod & "</sistcod><codsubsist type='igual'>" & codsubsist & "</codsubsist><moncod type='igual'>" & moncod & "</moncod><cuecod type='igual'>" & cuecod & "</cuecod><openro type='igual'>" & openro & "</openro></filtro><orden>nrocuo</orden></select></criterio>")
    Me.contents("filtro_cuotas_detalle") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='VOII_cuotas_liq' cn='BD_IBS_ANEXA'><campos>nrocuo, accdesc AS detalle, CONVERT(VARCHAR(20), fecven, 103) AS fecven, monsimbolo, impaccope AS importe_cuota, CASE WHEN CONVERT(INT, sdocuo) = 0 THEN impaccope ELSE 0.00 END AS importe_pago, CASE WHEN CONVERT(INT, sdocuo) = 0 THEN 0.00 ELSE impaccope END AS importe_deuda, '' AS fe_ultipago, '0' AS estopercod</campos><filtro><nrocuo type='mas'>0</nrocuo><paiscod type='igual'>" & paiscod & "</paiscod><bcocod type='igual'>" & bcocod & "</bcocod><succod type='igual'>" & succod & "</succod><sistcod type='igual'>" & sistcod & "</sistcod><codsubsist type='igual'>" & codsubsist & "</codsubsist><moncod type='igual'>" & moncod & "</moncod><cuecod type='igual'>" & cuecod & "</cuecod><openro type='igual'>" & openro & "</openro></filtro><orden>nrocuo ASC</orden></select></criterio>")
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Préstamo Nº <% = openro %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var $body
        var $clienteInfo
        var $divMenu
        var $prestamoInfo
        var $divMenuGeneral

        // Objeto para manejar los frames
        var contenedor = {
            'ctacte':     { 'cargado': false, 'elemento': null },
            'comentario': { 'cargado': false, 'elemento': null }
        }

        // Variables para botones
        var vButtonItems = []

        // Variables para el filtro y path xsl
        var filtro   = null
        var path_xsl = ''
        var nombre_excel = '<% = id_prestamo %>_cuotas.xls'


        function window_onload()
        {
            $body            = $$('body')[0]
            $clienteInfo     = $('clienteInfo')
            $divMenu         = $('divMenu')
            $prestamoInfo    = $('prestamoInfo')
            $divMenuGeneral  = $('divMenuGeneral')

            // cargar elementos en objeto 'contenedor'
            contenedor.comentario.elemento = $('divComentarios')
            contenedor.ctacte.elemento     = $('divCtaCte')
            
            // Por defecto cargar los comentarios
            mostrarComentarios()

            window_onresize()
            nvFW.bloqueo_desactivar(null, 'bloq_prestamo')
        }


        function window_onresize()
        {
            try {
                var body_h           = $body.getHeight()
                var clienteInfo_h    = $clienteInfo.getHeight()
                var divMenu_h        = $divMenu.getHeight()
                var prestamoInfo_h   = $prestamoInfo.getHeight()
                var divMenuGeneral_h = $divMenuGeneral.getHeight()
                var altura           = body_h - clienteInfo_h - divMenu_h - prestamoInfo_h - divMenuGeneral_h
                
                for (var item in contenedor) {
                    contenedor[item].elemento.style.height = altura + 'px'
                }
                
                ctacteOnResize(altura) // actualizar la altura para el iframe dentro de cuenta corriente
            }
            catch(e) {}
        }


        function cargarPrestamo()
        {
            filtro = filtro || nvFW.pageContents.filtro_cuotas
            path_xsl  = path_xsl || 'HTML_listado_cuotas.xsl'

            nvFW.exportarReporte({
                filtroXML: filtro,
                path_xsl: 'report/verPrestamos/' + path_xsl,
                formTarget: 'frame_prestamo',
                cls_contenedor: 'frame_prestamo',
                cls_contenedor_msg: ' ',
                bloq_contenedor: $('divCtaCte'),
                bloq_msg: 'Cargando cuenta corriente...',
                nvFW_mantener_origen: true,
                id_exp_origen: 0
            })
        }


        function hideFrames()
        {
            for (var item in contenedor) {
                contenedor[item].elemento.hide()
            }
        }


        function mostrarComentarios()
        {
            if (!contenedor.comentario.cargado) {
                $('frame_comentario').src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=2&nro_com_grupo=2&collapsed_fck=1&do_zoom=0&id_tipo=<% = id_prestamo %>'
                contenedor.comentario.cargado = true
            }

            hideFrames()
            contenedor.comentario.elemento.show()
        }


        function verCtaCte()
        {
            if (!contenedor.ctacte.cargado) {
                cargarPrestamo()
                cargarBotones()
                contenedor.ctacte.cargado = true
            }

            hideFrames()
            contenedor.ctacte.elemento.show()
        }


        function cargarBotones()
        {
            vButtonItems[0] = []
            vButtonItems[0]["nombre"]   = "Imprimir";
            vButtonItems[0]["etiqueta"] = "Imprimir";
            vButtonItems[0]["imagen"]   = "imprimir";
            vButtonItems[0]["onclick"]  = "return imprimir()";
  
            vButtonItems[1] = []
            vButtonItems[1]["nombre"]   = "Exportar";
            vButtonItems[1]["etiqueta"] = "Exportar";
            vButtonItems[1]["imagen"]   = "exportar";
            vButtonItems[1]["onclick"]  = "return exportar()";

            var vListButton = new tListButton(vButtonItems, 'vListButton');
            vListButton.loadImage("imprimir", "/FW/image/icons/imprimir.png")
            vListButton.loadImage("exportar", "/FW/image/filetype/xlsx.png")

            vListButton.MostrarListButton()
        }


        function ctacteOnResize(h_disponible)
        {
            try {
                $('frame_prestamo').style.height = h_disponible - 30 + 'px'
            }
            catch(e) {}
        }


        function exportar()
        {
            if (filtro != null)
                nvFW.exportarReporte({
                    filtroXML: filtro,
                    path_xsl: 'report/EXCEL_base.xsl',
                    salida_tipo: 'adjunto',
                    parametros: '<parametros><columnHeaders><table><tr><td>Nro. Cuota</td><td>Detalle</td><td>Vencimiento</td><td>Moneda</td><td>Cuota</td><td>Pagado</td><td>Deuda</td><td>Ultimo pago</td><td>Cod. Estado Op.</td></tr></table></columnHeaders></parametros>',
                    filename: nombre_excel,
                    export_exception: 'RSXMLtoExcel',
                    ContentType: 'application/vnd.ms-excel',
                    formTarget: 'frame_excel'
                })
        }


        function imprimir()
        {
            alert('Imprimir con crystal report RPT')
        }


        function cambiarVista(valor)
        {
            if ($('agrupar_cuota').checked) {
                $('tipo_vista').value = 'C'
                filtro                = nvFW.pageContents.filtro_cuotas
                path_xsl              = 'HTML_listado_cuotas.xsl'
                nombre_excel          = '<% = id_prestamo %>_cuotas.xls'
            }
            else {
                // Cargar la plantilla XSL correcta para cada vista
                switch (valor) {
                    case 'C':
                        filtro       = nvFW.pageContents.filtro_cuotas
                        path_xsl     = 'HTML_listado_cuotas.xsl'
                        nombre_excel = '<% = id_prestamo %>_cuotas.xls'
                        break

                    case 'D':
                        filtro       = nvFW.pageContents.filtro_cuotas_detalle
                        path_xsl     = 'HTML_listado_cuotas.xsl'
                        nombre_excel = '<% = id_prestamo %>_cuotas_detalles.xls'
                        break

                    case 'H':
                        filtro       = null
                        path_xsl     = 'HTML_listado_cuotas_detalle_horizontal.xsl'
                        nombre_excel = '<% = id_prestamo %>_cuotas_detalles_horizontal.xls'
                        break
                }
            }
            
            cargarPrestamo()
        }


        function agruparCuotas(chequeado)
        {
            if ($('tipo_vista').value != 'C')
                if (chequeado) {
                    $('tipo_vista').value = 'C'
                    $('tipo_vista').onchange()
                }
        }


        function verArchivos()
        {
            alert('Mostrar archivos del préstamo')
        }


        function ventanaInfoCliente(cuit)
        {
            var winCliente = top.nvFW.createWindow({
                url: '/voii/cargar_cliente.aspx?cuit=' + cuit,
                title: '<b>Información de cliente - CUIT ' + cuit + '</b>',
                height: 550,
                width: 980,
                destroyOnClose: true
            })

            winCliente.showCenter()
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'bloq_prestamo', 'Cargando préstamo <b><% = id_prestamo %></b>...')</script>
    
    <%-- Cargar información básica del CLIENTE --%>
    <table class="tb1" id="clienteInfo">
        <tr class="tbLabel">
            <td style="width: 25px;"">&nbsp;</td>
            <td style="width: 70px; text-align: center;">T. Doc.</td>
            <td style="width: 100px; text-align: center;">Nro. Doc.</td>
            <td style="width: 70px; text-align: center;">Sexo</td>
            <td style="width: 70px; text-align: center;">Edad</td>
            <td style="width: 200px; text-align: center;">Apellido</td>
            <td style="text-align: center;">Nombres</td>
            <td style="width: 90px; text-align: center;">E. Civil</td>
            <td style="width: 90px; text-align: center;">Fe. Nac.</td>
        </tr>
        <tr>
            <td style="text-align: center;">
                <img alt="buscar" src="/FW/image/icons/buscar.png" style="cursor: pointer;" title="Mostrar datos de Cliente" onclick="return ventanaInfoCliente(<% = cuit %>)" />
            </td>
            <td class="Tit4"><% = tipoDoc %></td>
            <td class="Tit4" style="text-align: right;"><% = nroDoc %></td>
            <td class="Tit4"><% = sexo %></td>
            <td class="Tit4" style="text-align: right;"><% = edad %></td>
            <td class="Tit4"><% = apellido %></td>
            <td class="Tit4"><% = nombres %></td>
            <td class="Tit4"><% = estCivil %></td>
            <td class="Tit4" style="text-align: right;"><% = feNacimiento %></td>
        </tr>
    </table>

    <%-- MENU propio del préstamo --%>
    <div id="divMenu"></div>
    <script type="text/javascript">
        var Menu = new tMenu('divMenu', 'vMenu');

        Menus["Menu"] = Menu
        Menus["Menu"].alineacion = 'centro';
        Menus["Menu"].estilo = 'A';

        Menus["Menu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Información del Préstamo</Desc></MenuItem>")
    
        Menu.MostrarMenu()
    </script>

    <%-- Información del PRESTAMO --%>
    <table class="tb1" id="prestamoInfo" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 120px; text-align: center;">Pais</td>
                        <td style="width: 200px; text-align: center;">Banco</td>
                        <td style="min-width: 100px; text-align: center;">Bco. Domicilio</td>
                        <td style="width: 50px; text-align: center;">BCRA</td>
                        <td style="width: 100px; text-align: center;">CUIT</td>
                        <td style="width: 100px; text-align: center;"># Referencia</td>
                        <td style="width: 100px; text-align: center;">Estado Op.</td>
                    </tr>
                    <tr>
                        <td class="Tit4" style="text-transform: uppercase;"><% = pais %></td>
                        <td class="Tit4"><% = banco %></td>
                        <td class="Tit4"><% = bancoDomicilio %></td>
                        <td class="Tit4" style="text-align: right;"><% = bancoBCRA %></td>
                        <td class="Tit4" style="text-align: right;"><% = bancoCUIT %></td>
                        <td class="Tit4" style="text-align: right;"><% = nroReferencia %></td>
                        <td class="Tit4"><% = estadoOperacion %></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                    <tr class="tbLabel">
                        <td style="width: 350px; text-align: center;">Producto</td>
                        <td style="min-width: 200px; text-align: center;">Tipo Operación</td>
                        <td style="width: 100px; text-align: center;">TEM</td>
                        <td style="width: 100px; text-align: center;">TNA</td>
                        <td style="width: 100px; text-align: center;">CFT</td>
                    </tr>
                    <tr>
                        <td class="Tit4"><% = producto %></td>
                        <td class="Tit4"><% = tipoOperDesc %></td>
                        <td class="Tit4" style="text-align: right;"><% = temVenc %> %</td>
                        <td class="Tit4" style="text-align: right;"><% = tnaAnual %> %</td>
                        <td class="Tit4" style="text-align: right;"><% = cft %> %</td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>

    <%-- MENU general del préstamo --%>
    <div id="divMenuGeneral"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenuGeneral', 'vMenu');

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarComentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>dollar</icono><Desc>Cuenta Corriente</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verCtaCte()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>verArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")
        
        vMenu.loadImage("comentario", "/FW/image/icons/comentario3.png");
        vMenu.loadImage("dollar", "/FW/image/icons/dollar.png");
        vMenu.loadImage("archivo", "/FW/image/icons/nueva.png");
    
        vMenu.MostrarMenu()
    </script>

    <%-- Contenedor para COMENTARIOS --%>
    <div id="divComentarios" style="display: none; width: 100%;">
        <iframe id="frame_comentario" name="frame_comentario" src="enBlanco.htm" style="width: 100%; height: 100%; overflow: auto; border: none;"></iframe>
    </div>

    <%-- Contenedor para COMENTARIOS --%>
    <div id="divCtaCte" style="display: none; width: 100%;">
        <table class="tb1" id="filtro_prestamo">
            <tr>
                <td class="Tit1" style="width: 170px;">Vista:</td>
                <td>
                    <select id="tipo_vista" style="width: 100%;" onchange="return cambiarVista(this.value)">
                        <option value="C" selected>Cuotas</option>
                        <option value="D">Detalle</option>
                        <option value="H">Detalle Horizontal</option>
                    </select>
                </td>
                <td class="Tit1" style="width: 170px;">Agrupar por cuota:</td>
                <td style="width: 70px; text-align: center;">
                    <input type="checkbox" name="agrupar_cuota" id="agrupar_cuota" onchange="return agruparCuotas(this.checked)" style="cursor: pointer;" title="Agrupar por cuotas" />
                </td>
                <td style="width: 320px;">
                    <table class="tb1" cellspacing="0" cellpadding="0">
                        <tr>
                            <td><div id="divImprimir"></div></td>
                            <td><div id="divExportar"></div></td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
        <iframe id="frame_prestamo" name="frame_prestamo" src="enBlanco.htm" style="width: 100%; height: 100%; overflow: auto; border: none;"></iframe>
    </div>

    <%-- Frame EXCEL --%>
    <iframe name="frame_excel" id="frame_excel" style="display: none;"></iframe>

</body>
</html>
