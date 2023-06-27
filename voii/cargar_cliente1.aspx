<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>
<%
    ' Parametros desde solicitud GET
    Dim tituloPagina As String = nvFW.nvUtiles.obtenerValor("titulo", "Datos de entidad")

    Dim tipdoc As String = nvFW.nvUtiles.obtenerValor("tipdoc", "")
    Dim nrodoc As String = nvFW.nvUtiles.obtenerValor("nrodoc", "")

    Dim dni As String = ""
    Dim tipocli As Integer = 0
    'Dim tipdoc As Integer = 0
    Dim cuit_cuil As String = ""
    Dim tipdocdesc As String = ""
    'Dim nrodoc As Decimal = 0
    Dim cliape As String = ""
    Dim clinom As String = ""
    Dim clisexo As Char = ""
    Dim cliestcivcod As Integer = 0
    Dim cliestcivcoddesc As String = ""
    Dim fecnac_insc As DateTime = #01/01/1900#
    Dim codprov As Integer = 0
    Dim codprovdesc As String = ""
    Dim domnom As String = ""
    Dim domnro As String = ""
    Dim dompiso As String = ""
    Dim domdepto As String = ""
    Dim codpos As String = ""
    Dim loccod As Integer = 0
    Dim loccoddesc As String = ""
    Dim cartel As String = ""
    Dim numtel As String = ""

    Dim email As String = ""
    Dim clconddgi As String = ""
    Dim descestciv As String = ""
    Dim tipoempdesc As String = ""
    Dim tipsocdesc As String = ""

    Dim sectorfindesc As String = ""

    Dim razon_social As String = ""
    Dim denominacion As String = ""
    Dim tipreldesc As String = ""

    Dim impgandesc As String = ""

    Dim clasidesc As String = ""

    Dim perconnom As String = ""

    Dim profdesc As String = ""

    Dim desctipcar As String = ""

    Dim pep As Integer = 2
    Dim age As Integer = 0

    If tipdoc <> "" And nrodoc <> "" Then
        Dim err As New tError
        Try
            'Dim strSQL As String = "SELECT TOP 1 tipdoc, tipdocdesc, nrodoc, cliape, clinom, clisexo, cliestcivcod, cliestcivcoddesc, clifecnac, codprov, codprovdesc, domnom, domnro, dompiso, domdepto, codpos, loccod, loccoddesc, cartel, numtel FROM VOII_prestamos WHERE nrodoc = " + cuit_cuil
            Dim strSQLIBS As String = "SELECT TOP 1 tipocli, CAST(tipdoc AS varchar) AS tipdoc, tipdoc_desc, CAST(nrodoc AS varchar) AS nrodoc, CUIT_CUIL, DNI, ISNULL(cliape, '') as cliape, ISNULL(clinom, '') as clinom, ISNULL(clideno, '') as clideno, " +
                "fecnac_insc, ISNULL(clisexo, '') as clisexo, ISNULL(cartel, '') as cartel, ISNULL(numtel, '') as numtel, razon_social, tipreldesc, ISNULL(domnom, '') as domnom, ISNULL(domnro, '') as domnro, ISNULL(dompiso, '') as dompiso, " +
                "ISNULL(domdepto, '') as domdepto, ISNULL(codpos, '') as codpos, ISNULL(loccoddesc, '') as loccoddesc, ISNULL(codprovdesc, '') as codprovdesc, " +
                "ISNULL(email, '') as email, ISNULL(clconddgi, '') as clconddgi, ISNULL(descestciv, '') as descestciv, ISNULL(tipsocdesc, '') as tipsocdesc, ISNULL(tipoempdesc, '') as tipoempdesc, " +
                "ISNULL(policaexpuesto, 2) as pep, ISNULL(sectorfindesc, '') as sectorfindesc, ISNULL(profdesc, '') as profdesc, ISNULL(impgandesc, '') as impgandesc, ISNULL(perconnom, '') as perconnom, " +
                "ISNULL(clasidesc, '') as clasidesc, ISNULL(desctipcar, '') as desctipcar " +
                "FROM VOII_entidades WHERE tipdoc = " + tipdoc + " AND nrodoc = " + nrodoc
            Dim rs As ADODB.Recordset = nvFW.nvDBUtiles.DBExecute(strSQLIBS, cod_cn:="BD_IBS_ANEXA")

            'If rs.EOF Then
            '    Dim strSQL As String = "SELECT TOP 1 '1' as tipocli, 8 as tipdoc1, 'CUIL' as tipdoc1_desc, cuil as nrodoc1, apellido as cliape, nombre as clinom, tel_area as cartel, tel_numero as numtel, nombre + ' ' + apellido as  razon_social, 'No es cliente' as tipreldesc FROM sol_solicitudes WHERE cuil = '" + cuit_cuil + "'"
            '    rs = nvFW.nvDBUtiles.DBExecute(strSQL)
            'End If

            If Not rs.EOF Then
                tipocli = rs.Fields("tipocli").Value

                tipdoc = rs.Fields("tipdoc").Value
                tipdocdesc = rs.Fields("tipdoc_desc").Value
                nrodoc = rs.Fields("nrodoc").Value

                cuit_cuil = rs.Fields("CUIT_CUIL").Value
                dni = rs.Fields("DNI").Value

                cliape = rs.Fields("cliape").Value
                clinom = rs.Fields("clinom").Value
                clisexo = rs.Fields("clisexo").Value
                'cliestcivcod = rs.Fields("cliestcivcod").Value
                'cliestcivcoddesc = rs.Fields("cliestcivcoddesc").Value
                fecnac_insc = rs.Fields("fecnac_insc").Value
                'codprov = rs.Fields("codprov").Value
                codprovdesc = rs.Fields("codprovdesc").Value
                domnom = rs.Fields("domnom").Value
                domnro = rs.Fields("domnro").Value
                dompiso = rs.Fields("dompiso").Value
                domdepto = rs.Fields("domdepto").Value
                codpos = rs.Fields("codpos").Value
                'loccod = rs.Fields("loccod").Value
                loccoddesc = rs.Fields("loccoddesc").Value
                cartel = rs.Fields("cartel").Value
                numtel = rs.Fields("numtel").Value

                email = rs.Fields("email").Value
                clconddgi = rs.Fields("clconddgi").Value
                descestciv = rs.Fields("descestciv").Value
                tipoempdesc = rs.Fields("tipoempdesc").Value
                tipsocdesc = rs.Fields("tipsocdesc").Value

                razon_social = rs.Fields("razon_social").Value
                denominacion = rs.Fields("clideno").Value
                tipreldesc = rs.Fields("tipreldesc").Value

                sectorfindesc = rs.Fields("sectorfindesc").Value

                impgandesc = rs.Fields("impgandesc").Value
                clasidesc = rs.Fields("clasidesc").Value

                perconnom = rs.Fields("perconnom").Value

                profdesc = rs.Fields("profdesc").Value

                desctipcar = rs.Fields("desctipcar").Value

                pep = rs.Fields("pep").Value

                age = Today.Year - fecnac_insc.Year
                If (fecnac_insc > Today.AddYears(-age)) Then age -= 1

            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
            err.parse_error_script(ex)
            err.response()
        End Try
    End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title><% = tituloPagina %></title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet"/>
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

<%--    <% = Me.getHeadInit() %>--%>

    <script type="text/javascript">

        // Objeto frame creado para una mejor organizacion y uso de los datos
        var frame = {
            'comentario': { 'cargado': false, 'elemento': null, 'content': null },
            'vinculo': { 'cargado': false, 'elemento': null, 'content': null },
            'archivo': { 'cargado': false, 'elemento': null, 'content': null },
            //'nosis':      { 'cargado': false, 'elemento': null, 'content': null },
            //'bcra':       { 'cargado': false, 'elemento': null, 'content': null },
            'prestamo': { 'cargado': false, 'elemento': null, 'content': null },
            'solicitud': { 'cargado': false, 'elemento': null, 'content': null }
        }


        function window_onload()
        {
            // Cargar los frames en el objeto 'frame'
            frame.comentario.elemento = $('frame_comentario')
            frame.comentario.content = $('content_comentario')
            frame.vinculo.elemento = $('frame_vinculo')
            frame.vinculo.content = $('content_vinculo')
            frame.archivo.elemento = $('frame_archivo')
            frame.archivo.content = $('content_archivo')
            //frame.nosis.elemento      = $('frame_nosis')
            //frame.bcra.elemento       = $('frame_bcra')
            frame.prestamo.elemento = $('frame_prestamo')
            frame.prestamo.content = $('content_prestamo')
            frame.solicitud.elemento = $('frame_solicitud')
            frame.solicitud.content = $('content_solicitud')

            window_onresize()
            mostrarComentarios()
            nvFW.bloqueo_desactivar(null, 'bloq_datos')
        }


        function window_onresize()
        {
            try {
                var dif                = Prototype.isIE ? 5 : 0
                var body_h             = $$('body')[0].getHeight()
                var tb_datos_cliente_h = $('tb_datos_cliente').getHeight()
                var menu_h             = $('divMenu').getHeight()
                var altura             = body_h - tb_datos_cliente_h - menu_h - dif + 'px'

                for (var item in frame) {
                    frame[item].content.style.height = altura
                }
            }
            catch(e) {}
        }


        function hideFrames()
        {
            for (var item in frame) {
                frame[item].content.hide()
            }
        }

        function mostrarVinculos() {
            if (!frame.vinculo.cargado) {
                frame.vinculo.elemento.src = '/voii/listado_vinculos.aspx?tipdoc=<% = tipdoc %>&nrodoc=<% = nrodoc %>'
                frame.vinculo.cargado = true
            }

            hideFrames()
            frame.vinculo.content.show()
        }


        function mostrarComentarios()
        {
            if (!frame.comentario.cargado) {
                frame.comentario.elemento.src = '/FW/comentario/verCom_registro.aspx?nro_com_id_tipo=1&nro_com_grupo=1&collapsed_fck=1&do_zoom=0&id_tipo=<% = cuit_cuil %>'
                frame.comentario.cargado = true
            }

            hideFrames()
            frame.comentario.content.show()
        }


        function mostrarArchivos()
        {
            if (!frame.archivo.cargado) {
                frame.archivo.elemento.contentDocument.body.style.backgroundColor = '#FFB'
                frame.archivo.elemento.contentDocument.body.innerHTML = '<div style="font-family: Tahoma; width: 50%; margin: 10px auto; text-align: center;"><h3>Frame de Archivos</h3><p>Ingresar los <b>aspx</b> o <b>xsl</b> necesarios para esta funcionalidad.</p></div>'
                frame.archivo.cargado = true
            }

            hideFrames()
            frame.archivo.content.show()
        }


        function mostrarPrestamos()
        {
            if (!frame.prestamo.cargado) {
                frame.prestamo.elemento.src = '/voii/listado_prestamos.aspx?cuit=<% = cuit_cuil %>'
                frame.prestamo.cargado = true
            }

            hideFrames()
            frame.prestamo.content.show()            
        }

        function listar_solicitudes() {
            if (!frame.solicitud.cargado) {
                frame.solicitud.elemento.src = '/voii/Solicitudes/solicitud_seleccion.aspx?cuit=<% = cuit_cuil %>'
                frame.solicitud.cargado = true
            }

            hideFrames()
            frame.solicitud.content.show() 
        }
    </script>
    <style>
        tr.centrado td { text-align: center; }
    </style>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">
    <script type="text/javascript">nvFW.bloqueo_activar($$('body')[0], 'bloq_datos', 'Cargando información de la entidad...')</script>

    <table class="tb1" cellspacing="0" cellpadding="0" id="tb_datos_cliente">
        <tr>
            <td>
                <%-- MENU principal de la operacion --%>
                <div id="divMenuPrincipal"></div>
                <script type="text/javascript">
                    var Menu = new tMenu('divMenuPrincipal', 'vMenu');

                    Menus["Menu"] = Menu
                    Menus["Menu"].alineacion = 'centro';
                    Menus["Menu"].estilo = 'A';

                    Menus["Menu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Entidad [<% = tipdocdesc & " " & nrodoc %>]</Desc></MenuItem>")

                    Menu.MostrarMenu()
                </script>
            </td>
        </tr>
        <tr>
            <td>
                <table class="tb1">
                <%--Persona Física--%>
                <% if tipocli = 1 Then %>
                
                    <tr class="tbLabel centrado">
                        <td  style="width: 120px;">CUIT / CUIL</td>
                        <td >DNI</td>
                        <td >Apellido</td>
                        <td >Nombres</td>
                        <td >Sexo</td>
                        
                        
                        
                        
                        <td colspan="2">Estado</td>
                    </tr>
                    <tr>
                        <td class="Tit4" style="width: 120px;"><% = cuit_cuil %></td>
                        <td class="Tit4"><% = dni %></td>
                        <td class="Tit4"><% = cliape %></td>
                        <td class="Tit4"><% = clinom %></td>
                        <td class="Tit4"><% if clisexo = "M" Then %> Masculino <% ElseIf(clisexo = "F") Then %> Femenino <%End If %></td>
                        
                        
                        
                        
                        <td class="Tit4" colspan="2"><% = tipreldesc %></td>
                    </tr>
                    <tr class="tbLabel centrado">
                        <td style="width: 120px;">Nacionalidad</td>
                        
                        
                        <td >Estado Civil</td>
                        <td >Conyuge</td>
                        <td >Situación IVA</td>
                        <td >PEP</td>
                        
                        <td >Fecha Nac.</td>
                        <td >Edad</td>
                    </tr>
                    <tr>
                        <td class="Tit4" style="width: 120px;"></td>
                        
                        
                        <td class="Tit4"><% = descestciv %></td>
                        <td class="Tit4"></td>
                        <td class="Tit4"><% = clconddgi %></td>
                        <td class="Tit4"><% = If(pep = 1, "Si", "No")  %></td>
                        <td Class="Tit4"><% = fecnac_insc.ToString("dd/MM/yyyy") %></td>
                        <td Class="Tit4"><% = age %></td>
                    </tr>
                <%End If%>
                <%--Persona Jurídica--%>
                <% if tipocli = 2 Then %>
                    <tr class="tbLabel centrado">
                        <td  style="width: 120px;">CUIT / CUIL</td>
                        
                        <td>Razón Social</td>
                        
                        
                        <td >Tipo Empresa</td>
                        
                        <td >Tipo Sociedad</td>
                        <td >Estado</td>
                    </tr>
                    <tr>
                        <td class="Tit4" style="width: 120px;"><% = cuit_cuil %></td>
                        
                        <td class="Tit4"><% = razon_social %></td>
                        
                        <td class="Tit4"><% = tipoempdesc %></td>
                        
                        <td class="Tit4"><% = tipsocdesc %></td>
                        
                        <td class="Tit4"><% = tipreldesc %></td>
                    </tr>

                    <tr class="tbLabel centrado">
                        <td  style="width: 120px;">Fecha Inscripción</td>
                        <td >Denominación</td>
                        
                        <td>Sector Financiero</td>
                        <td colspan="2">Situación IVA</td>
                        
                        
                    </tr>
                    <tr>
                        <td Class="Tit4" style="width: 120px;"><% = fecnac_insc.ToString("dd/MM/yyyy") %></td>
                        <td class="Tit4"><% = denominacion %></td>
                        
                        <td class="Tit4"><% = sectorfindesc %></td>
                        <td class="Tit4" colspan="2"><% = clconddgi %></td>
                        
                        
                        
                    </tr>
                <%End If%>
                </table>
                <table class="tb1">
                    <tr class="tbLabel centrado">
                        <td style="width: 120px;">Teléfono</td>
                        <td >Email</td>
                        <td  >Domicilio</td>
                        <td >CP</td>
                        <td >Localidad</td>
                        <%--<td style="min-width: 100px;">Provincia</td>--%>
                    </tr>
                    <tr>
                        <td class="Tit4"  style="width: 120px;"><% = If(String.IsNullOrWhiteSpace(numtel), "", "(" & cartel & ") " & numtel) %></td>
                        <td class="Tit4"><% = email %></td>
                        <td class="Tit4" ><% = domnom & " " & domnro & If(String.IsNullOrWhiteSpace(dompiso), "", " - Piso: " & dompiso) & If(String.IsNullOrWhiteSpace(domdepto), "", " - Depto: " & domdepto) %></td>
                        <td class="Tit4"><% = codpos %></td>
                        <td class="Tit4"><% = loccoddesc & " (" & codprovdesc & ")" %></td>
                        <%--<td class="Tit4"><% = codprovdesc %></td>--%>
                    </tr>
                </table>

            </td>
        </tr>
    </table>

    <div id="divMenu"></div>
    <script type="text/javascript">
        var vMenu = new tMenu('divMenu', 'vMenu');

        Menus["vMenu"] = vMenu
        Menus["vMenu"].alineacion = 'centro';
        Menus["vMenu"].estilo = 'A';

        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='width: 100%;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>comentario</icono><Desc>Comentarios</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarComentarios()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='2'><Lib TipoLib='offLine'>DocMNG</Lib><icono>vinculos</icono><Desc>Vínculos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarVinculos()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='3'><Lib TipoLib='offLine'>DocMNG</Lib><icono>reporte</icono><Desc>Solicitudes</Desc><Acciones><Ejecutar Tipo='script'><Codigo>listar_solicitudes()</Codigo></Ejecutar></Acciones></MenuItem>")
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='4'><Lib TipoLib='offLine'>DocMNG</Lib><icono>prestamo</icono><Desc>Prestamos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarPrestamos()</Codigo></Ejecutar></Acciones></MenuItem>")
        
        Menus["vMenu"].CargarMenuItemXML("<MenuItem id='5'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>mostrarArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")
             
        vMenu.loadImage("prestamo", "/FW/image/icons/dollar.png");
        vMenu.loadImage("comentario", "/FW/image/icons/comentario3.png");
        vMenu.loadImage("archivo", "/FW/image/icons/nueva.png");
        vMenu.loadImage("vinculos", "/FW/image/icons/personas.png");
        //vMenu.loadImage("nosis", "/FW/image/icons/nosis.png");
        //vMenu.loadImage("bcra", "/FW/image/icons/banco.png");
        vMenu.loadImage("reporte", "/FW/image/icons/reporte.png");
        vMenu.MostrarMenu()
    </script>

    <table id="content_comentario" style="width:100%; display:none;">
        <tr>
            <td width="70%">
                <iframe id="frame_comentario" name="frame_comentario" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
            </td>
            <td width="30%" style="vertical-align:top">
                <table class="tb1">
                    <% If Not String.IsNullOrWhiteSpace(clasidesc) Then %>
                    <tr>
                        <td class="Tit2" width="15%" nowrap>Clasificación:</td>
                        <td class="Tit4" ><% = clasidesc %></td>
                    </tr>
                    <% End If %>
                    <% If Not String.IsNullOrWhiteSpace(profdesc) Then %>
                    <tr>
                        <td class="Tit2" width="15%" nowrap>Profesión:</td>
                        <td class="Tit4" ><% = profdesc %></td>
                    </tr>
                    <% End If %>
                    <% If Not String.IsNullOrWhiteSpace(impgandesc) Then %>
                    <tr>
                        <td class="Tit2" width="15%" nowrap>Imp. Ganancias:</td>
                        <td class="Tit4" ><% = impgandesc %></td>
                    </tr>
                    <% End If %>
                    <% If Not String.IsNullOrWhiteSpace(perconnom) Then %>
                    <tr>
                        <td class="Tit2" width="15%" nowrap>Perfil de Consumo:</td>
                        <td class="Tit4" ><% = perconnom %></td>
                    </tr>
                    <% End If %>
                    <% If Not String.IsNullOrWhiteSpace(desctipcar) Then %>
                    <tr>
                        <td class="Tit2" width="15%" nowrap>Tipo Cartera:</td>
                        <td class="Tit4" ><% = desctipcar %></td>
                    </tr>
                    <% End If %>
                    
                </table>
            </td>
        </tr>
    </table>
    <div id="content_archivo" style="display: none;">
        <iframe id="frame_archivo" name="frame_archivo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    <div id="content_vinculo" style="display: none;">
        <iframe id="frame_vinculo" name="frame_vinculo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%;"></iframe>
    </div>
    
    <%--<iframe id="frame_nosis" name="frame_nosis" src="enBlanco.htm" style="display: none; width: 100%; overflow: auto; border: none;"></iframe>
    <iframe id="frame_bcra" name="frame_bcra" src="enBlanco.htm" style="display: none; width: 100%; overflow: auto; border: none;"></iframe>--%>
    <div id="content_prestamo" style="display: none;">
        <iframe id="frame_prestamo" name="frame_prestamo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>
    <div id="content_solicitud" style="display: none;">
        <iframe id="frame_solicitud" name="frame_prestamo" src="enBlanco.htm" style="width: 100%; overflow: auto; border: none; height:100%"></iframe>
    </div>
    

</body>
</html>
