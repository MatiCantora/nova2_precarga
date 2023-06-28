<% @Page Language = "VB" AutoEventWireup = "false" Inherits = "nvFW.nvPages.nvPageMutualPrecarga" %>
<%
    'Dim dependientes As String = ""
    'Dim rsF = nvFW.nvDBUtiles.DBOpenRecordset("select convert(varchar,dbo.finac_inicio_mes(getdate()-2),103) as fe_desde_str")
    'Dim fe_desde_str As String = rsF.Fields("fe_desde_str").Value
    'Dim nro_vendedor As Integer = nvFW.nvUtiles.obtenerValor("nro_vendedor", "0")
    'Dim rsD = nvFW.nvDBUtiles.DBOpenRecordset("select dbo.rm_vendedor_dependencia(" & nro_vendedor & ") as dependientes")
    'if  rsD.EOF = False then
    '    dependientes = rsD.Fields("dependientes").Value
    'end if
    Dim filtro_dependientesA As String = ""
    If Me.operador.dependientes <> "" Then filtro_dependientesA = "<nro_vendedor type='in'>" & Me.operador.dependientes & "</nro_vendedor>"
    Dim filtroEstados As String = "<estado type='in'>'1','2','A', 'D', 'E', 'G', 'H', 'L', 'M', 'O', 'P', 'Q', 'R', 'T', 'U', 'Z'</estado>"
    Me.contents("creditos_mostrar") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select top='100' vista='verCreditos' PageSize='9' AbsolutePage='1' cacheControl='Session'><campos>nro_credito,nro_docu,strNombreCompleto,banco,mutual,importe_neto,cuotas,importe_cuota,descripcion,estado,fe_estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado_str</campos><orden>fe_estado desc</orden><filtro>" & filtro_dependientesA & "</filtro></select></criterio>") 'filtroEstados
    Me.contents("estados") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verEstados'><campos>cod_estado as id,estado_desc as [campo]</campos><filtro><estado type='in'>'A','D','E','G','H','L','M','O','P','Q','R','T','U','Z','1','2'</estado></filtro><orden>estado_desc</orden></select></criterio>")
    Me.contents("creditos_mostrar_exp") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select top='100' vista='verCreditos_exp'><campos>nro_credito,mutual,banco,strNombreCompleto as apellido_y_nombres,nro_docu,grupo as reparticion,importe_neto,cuotas,importe_cuota,descripcion as estado,dbo.conv_fecha_to_str(fe_estado,'dd/mm/yyyy hh:mm:ss') as fe_estado,vendedor,car_tel,telefono,localidad,provincia</campos><orden>fe_estado desc</orden><filtro>" & filtro_dependientesA & filtroEstados & "</filtro></select></criterio>")
    ' Me.contents("dependientes") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista=''><campos>dbo.rm_vendedor_dependencia(%nro_vendedor%) as dependientes</campos><filtro></filtro></select></criterio>")
    '"<criterio><select vista='verEstados'><campos>cod_estado as id,estado_desc as [campo]</campos><filtro><estado type=' in '>'A','D','E','G','H','L','M','O','P','Q','R','T','U','Z'</estado></filtro><orden>estado_desc</orden></select></criterio>"
    'Me.contents("dependientes_vendedor") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='vendedor' ><campos>top 1 dbo.rm_vendedor_dependencia(%nro_vendedor%) As dependientes </campos></select></criterio>")

    %>
    <html xmlns="http://www.w3.org/1999/xhtml">

        <head>
            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <title>NOVA Precarga</title>
            <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            <link href="/precarga/css/cabe_precarga.css" type="text/css" rel="stylesheet" />
            <link href="/precarga/css/mis_creditos.css" type="text/css" rel="stylesheet" />
            <link href="css/precarga.css" type="text/css" rel="stylesheet" />
            <link rel="shortcut icon" href="FW/image/icons/nv_login.ico" />
            <script type="text/javascript" src="/FW/script/nvFW.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
            <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
            <script type="text/javascript" src="/precarga/script/tCampo_head.js"></script>
            <%--<script type="text/javascript" src="/precarga/script/precarga.js"></script>--%>
            <script type="text/javascript" src="/precarga/script/precarga.js"></script>

                <%=Me.getHeadInit()%>
            <script type="text/javascript" language="javascript" class="table_window">
                var cr_listar = {}
                cr_listar.filtro_isVisible = false
                cr_listar.filtros_mostrar = function () {
                    if (!this.filtro_isVisible) {

                        $('filtro_creditos2').show();
                        $('divfiltrar').hide();
                        $('divOcultarFiltro').show();
                        $('divAplicarFiltro').show();
                    }
                    else {
                        $('filtro_creditos2').hide();
                        $('divfiltrar').show();
                        $('divOcultarFiltro').hide();
                        $('divAplicarFiltro').hide();
                    }
                    this.filtro_isVisible = !this.filtro_isVisible

                }
            </script>

                    <script type="text/javascript" language="javascript" class="table_window">


                        var vButtonItems = {}
                        vButtonItems[0] = {}
                        vButtonItems[0]["nombre"] = "Buscar";
                        vButtonItems[0]["etiqueta"] = "Buscar";
                        vButtonItems[0]["imagen"] = "";
                        vButtonItems[0]["onclick"] = "return verCreditos()";
                        vButtonItems[0]["estilo"] = "E";

                        vButtonItems[1] = {}
                        vButtonItems[1]["nombre"] = "filtrar";
                        vButtonItems[1]["etiqueta"] = "Mostrar filtros";
                        vButtonItems[1]["imagen"] = "";
                        vButtonItems[1]["onclick"] = "return cr_listar.filtros_mostrar()";
                        vButtonItems[1]["estilo"] = "M"

                        vButtonItems[2] = {}
                        vButtonItems[2]["nombre"] = "Buscar";
                        vButtonItems[2]["etiqueta"] = "";
                        vButtonItems[2]["imagen"] = "buscar";
                        vButtonItems[2]["onclick"] = "return buscarDNI()";
                        vButtonItems[2]["estilo"] = "B" ;

                        

                        vButtonItems[3] = {}
                        vButtonItems[3]["nombre"] = "AplicarFiltro";
                        vButtonItems[3]["etiqueta"] = "Filtrar";
                        vButtonItems[3]["imagen"] = "";
                        vButtonItems[3]["onclick"] = "return aplicarFiltros()";
                        vButtonItems[3]["estilo"] = "M"

                        vButtonItems[4] = {}
                        vButtonItems[4]["nombre"] = "OcultarFiltro";
                        vButtonItems[4]["etiqueta"] = "Ocultar filtro";
                        vButtonItems[4]["imagen"] = "";
                        vButtonItems[4]["onclick"] = "return cr_listar.filtros_mostrar()";
                        vButtonItems[4]["estilo"] = "M"

                           
                        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
                        vListButtons.loadImage("buscar", "/precarga/image/search_16.png");
                        vListButtons.loadImage("buscar", "/precarga/image/buscar.svg");
                       
                        var nro_vendedor = 0;
                        var nro_docu = 0;
                        var WinTipo = '';
                        var modo = '';
                        var ismobile = false;
                        var fe_desde = '';
                        var dependientes = "";
                        var BodyWidth = 0;
                        var estados = '';
                        var fe_desde = '';

                        function window_onload() {

                            vListButtons.MostrarListButton()
                            $('lista_creditos').show();
                            $('divOcultarFiltro').hide();
                            $('divAplicarFiltro').hide();

                            filtros = nvFW.getMyWindow().options.userData.filtros
                            
                            $("nro_docu").value = filtros["nro_docu"] == undefined ? "" : filtros["nro_docu"]

                            
                            if (filtros["month"] != undefined) {
                                var hoy = new Date()
                                var fe_firstDayMonth = new Date(hoy.getFullYear() + '/' + (hoy.getMonth()+1) + '/1')
                                    
                                for (var j = 0; j < filtros["month"]; j++) {
                                    fe_firstDayMonth = new Date(fe_firstDayMonth - (1000 * 60 * 60 * 24))
                                    fe_firstDayMonth.setDate(1)
                                }
                                campos_defs.set_value('fecha_desde', fe_firstDayMonth.toLocaleDateString())
                            }
                            else {
                                campos_defs.set_value('fecha_desde', (new Date()).toLocaleDateString())
                            }


                            estados = filtros["estados"] == undefined ? "'P','H','M','R','6'" : filtros["estados"]
                            campos_defs.set_value('estados_precarga', estados)
                            
                            verCreditos()

                            window_onresize()

                        }

                        function aplicarFiltros() {
                            
                            if (($('fecha_desde').value == '') && ($('fecha_hasta').value == '') && $('estados_precarga').value == '' && ($('nro_docu').value == '')) {
                                nvFW.alert('Ingrese un filtro para realizar la búsqueda')
                                return
                            } else {
                                verCreditos()
                            }
                        }


                        function buscarDNI() {
                            if ($('nro_docu').value == '') {
                                nvFW.alert('Ingrese un DNI')
                                return
                            } else {
                                verCreditos()
                            }
                        }

                        function nro_docu_onkeypress(e) {
                            var key
                            if (window.event) // IE
                                key = e.keyCode;
                            else
                                key = e.which;
                            if (key == 13)
                                credito_grupos.buscarDNI()

                        }


                        function verCreditos() {

                            var filtro = ""

                            estados = $('estados_precarga').value
                            fe_desde = $('fecha_desde').value

                            
                            filtro += "<fe_credito type='sql'><![CDATA[fe_credito >= convert(datetime,'" + fe_desde + "', 101)]]></fe_credito>" 

                            if ($('fecha_hasta').value != '')
                                filtro += "<fe_credito type='sql'><![CDATA[fe_credito < convert(datetime,'" + $('fecha_hasta').value + "',101)+1]]></fe_credito>"


                            if (estados != '')
                                filtro += "<estado type='in'>" + estados + "</estado>"

                            if ($('nro_docu').value != '')
                                filtro += "<nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"

                            var pageSize = 9
                            
                            nvFW.exportarReporte({
                                filtroXML: nvFW.pageContents.creditos_mostrar,
                                filtroWhere: "<criterio><select PageSize='" + pageSize + "'><filtro>" + filtro + "</filtro></select></criterio>",
                                path_xsl: 'report/verCreditos/HTML_creditos_precarga.xsl',
                                formTarget: 'iframe_cr',
                                nvFW_mantener_origen: true,
                                bloq_contenedor: $(document.documentElement),
                                bloq_msg: 'Realizando búsqueda...'
                            })

                        }

                        //function filtrar() {

                        //    $('filtro_creditos2').style.display = "flex";
                        //    $('lista_creditos').hide();
                        //}

                        //function Exportar() {
                        //    var filtro = ""

                        //    var estados = ''

                        //    estados = $('estados_precarga').value

                        //    if (($('fecha_desde').value == '') && ($('fecha_hasta').value == '') && (estados == '') && ($('nro_docu').value == '')) {
                        //        nvFW.alert('Ingrese un filtro para realizar la búsqueda')
                        //        return
                        //    }

                        //    if ($('fecha_desde').value != '')
                        //        filtro += "<fe_estado type='sql'><![CDATA[fe_estado >= convert(datetime,'" + $('fecha_desde').value + "',103)]]></fe_estado>"

                        //    if ($('fecha_hasta').value != '')
                        //        filtro += "<fe_estado type='sql'><![CDATA[fe_estado < convert(datetime,'" + $('fecha_hasta').value + "',103)+1]]></fe_estado>"

                        //    if (modo == 'V')
                        //        filtro += "<nro_vendedor type='in'>" + dependientes + "</nro_vendedor>"
                        //    if (modo == 'S')
                        //        $('nro_docu').value = nro_docu
                            

                        //    if (estados != '')
                        //        filtro += "<estado type='in'>" + estados + "</estado>"

                        //    if ($('nro_docu').value != '')
                        //        filtro += "<nro_docu type='igual'>" + $('nro_docu').value + "</nro_docu>"

                        //    nvFW.exportarReporte({
                        //        filtroXML: nvFW.pageContents.creditos_mostrar_exp,
                        //        filtroWhere: "<criterio><select><filtro>" + filtro + "</filtro></select></criterio>",
                        //        path_xsl: "report\\EXCEL_base.xsl",
                        //        salida_tipo: "adjunto",
                        //        ContentType: "application/vnd.ms-excel",
                        //        formTarget: "_blank",
                        //        filename: "creditos_" + nro_vendedor + ".xls",
                        //        export_exeption: "RSXMLtoExcel",
                        //        content_disposition: "attachment"
                        //        , requestMethod: "GET"
                        //    })
                        //}

                        var win_estado

                        function MostrarCredito(nro_credito) {
                            var filtros = {}
                            filtros['nro_credito'] = nro_credito
                            win_estado = window.top.createWindow2({
                                url: '/precarga/creditos/credito_mostrar.aspx',
                                title: '<b>Crédito: ' + nro_credito + ' </b>',
                                centerHFromElement: parent.$("contenedor"),
                                parentWidthElement: parent.$("contenedor"),
                                parentWidthPercent: 0.9,
                                parentHeightElement: parent.$("contenedor"),
                                parentHeightPercent: 0.9,
                                maxWidth: 500,
                                maxHeight: 500,
                                minimizable: false,
                                maximizable: false,
                                draggable: true,
                                resizable: true,
                                onClose: MostrarCredito_onClose,
                                
                            });
                            win_estado.options.userData = { filtros: filtros }
                            win_estado.showCenter(true)
                        }

                        function MostrarCredito_onClose() {
                            var retorno = win_estado.options.userData.res
                            if (retorno)
                                verCreditos(modo)
                        }

                        function Aceptar(estado) {
                            var datos_solicitud = {}
                            datos_solicitud['estado'] = estado
                            win.options.userData = { datos_solicitud: datos_solicitud }
                            win.close()
                        }

                        function window_onresize() {
                            
                        }

                    </script>
        </head>

        <body onload="return window_onload()" onresize="return window_onresize()"
            style="height: 100%; overflow: hidden;">
           
            <div class="conteinerCreditos" id="containerDiv">


                   <div id="filtro_creditos2" style="width: 100%; display:none">
                        <table class="tb1">
                            <tr class="tbLabel">
                                <td>
                                  Fecha desde
                                </td>
                                <td colspan="2">
                                Fecha hasta
                                </td>
                                
                            </tr>
                            <tr>
                                <td>
                                    <script type="text/javascript">
                                        campos_defs.add('fecha_desde', { enDB: false, nro_campo_tipo: 103 })
                                    </script>
                                </td>
                                <td colspan="3">
                                    <script type="text/javascript">
                                        campos_defs.add('fecha_hasta', { enDB: false, nro_campo_tipo: 103 })
                                    </script>
                                </td>
                               
                            </tr>
                            <tr class="tbLabel">
                                <td>Estados</td>
                                <td colspan="2">DNI </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="divCrFiltroRight">

                                        <%= nvFW.nvCampo_def.get_html_input("estados_precarga") %>
                                    </div>
                                </td>

                                 <td>    
                                         <script type="text/javascript">
                                             campos_defs.add('nro_docu', { enDB: false, nro_campo_tipo: 101 })
                                         </script>
                                </td>
                                <td><div id="divBuscar"></div></td>
                            </tr>
                        </table>
                        
                        <%--<div>
                            <div id="divAplicarFiltro"></div>
                        </div>--%>
                    </div>
                
   
               <div id="lista_creditos">
                   <table>
                       <tr>
                           <td>
                               <div id="divAplicarFiltro"></div>
                           </td>

                           <td>
                               <div id="divfiltrar" class=""></div>
                               <div id="divOcultarFiltro"></div>
                           </td>

                           

                       </tr>

                   </table>
                        
                   
                    <iframe name="iframe_cr" id="iframe_cr" loading="eager" frameborder="0"
                        src="/fw/enBlanco.htm"></iframe>
               </div>
              
                
        

        </body>

        </html>