<% @Page Language = "VB" AutoEventWireup = "false" Inherits = "nvFW.nvPages.nvPageMutualPrecarga" %>
<%
    Me.contents("grupos_creditos") = "<criterio><select vista=""[verPiz_373_precarga_estado_grupo_asignacion] g Left outer join verCreditos cr on cr.estado = g.estado and nro_vendedor = " & Me.operador.nro_vendedor & " and fe_credito >= dateadd(month, -1 *  %month%, dbo.finac_inicio_mes(getdate()))""><campos>g.cod_grupo , g.grupo, g.titulo, g.subtitulo, grupo_orden,  count(distinct nro_credito) as cantidad, dbo.piz373_grupo_estados(g.cod_grupo) as estados</campos><filtro></filtro><grupo>grupo_orden, g.cod_grupo, g.grupo, g.titulo, g.subtitulo</grupo></select></criterio>"   %>
<%--< !DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 5.0 Transitional//EN" >--%>
    <html xmlns="http://www.w3.org/1999/xhtml">

        <head>
            <meta http-equiv="X-UA-Compatible" content="IE=edge" />
            <title>NOVA Precarga</title>
            <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
            <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
            <link rel="preload" href="../css/mis_creditos.css" as="style"/>
            <link href="../css/mis_creditos.css" type="text/css" rel="stylesheet" />
            <link rel="shortcut icon" href="FW/image/icons/nv_login.ico" />
            <script type="text/javascript" src="/FW/script/nvFW.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
            <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
            <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
            <script type="text/javascript" src="/precarga/script/tCampo_head.js"></script>
            <script type="text/javascript" src="/precarga/script/precarga.js"></script>
            <script type="text/javascript" src="/precarga/script/precarga.js"></script>

                <%=Me.getHeadInit()%>
             <script type="text/javascript" language="javascript" >
                 var credito_grupos = {}
                 credito_grupos.meses = -1
                 credito_grupos.mostrar_grupos = function () {
                     var rs = new tRS()
                     rs.async = true

                     rs.onComplete = function (rs) {
                         
                         $('lista_grupos').innerHTML = ""
                         var strHTML = ""

                         while (!rs.eof()) {
                             cod_grupos[rs.getdata("cod_grupo")] = {}
                             var grupo = cod_grupos[rs.getdata("cod_grupo")]
                             grupo["cod_grupo"] = rs.getdata("cod_grupo")
                             grupo["grupo"] = rs.getdata("grupo")
                             grupo["cantidad"] = rs.getdata("cantidad")
                             grupo["titulo"] = rs.getdata("titulo")
                             grupo["subtitulo"] = rs.getdata("subtitulo")
                             grupo["estados"] = rs.getdata("estados")
                             strHTML += "<div id='" + grupo["cod_grupo"] + "' class='styleGrupos'><div id='cantidad_" + grupo["cod_grupo"] + "' class='cantidad'><span>" + grupo["cantidad"] + "</span></div><div id='titulo_" + grupo["cod_grupo"] + "' class='styloEstado'><span id='titulo_" + grupo["cod_grupo"] + "' class='styloTitulo'>" + grupo["titulo"] + "</span><span id='subtitulo_" + grupo["cod_grupo"] + "' class='styloSubitulo'>" + grupo["subtitulo"] + "</span></div><div><input id='boton" + grupo["cod_grupo"] + "' class='btnVer' type='button' value='Ver' onclick=\"credito_grupos.filtroGrupos('" + grupo["cod_grupo"] + "')\" /></div></div>"
                             rs.movenext()
                         }
                         $('lista_grupos').insert({ top: strHTML })

                     }

                     rs.open({
                         filtroXML: nvFW.pageContents.grupos_creditos
                         , params: "<criterio><params month='" + this.meses + "' /></criterio>"
                     })
                 }

                 credito_grupos.buscarDNI = function () {

                     if (($('nro_docu').value == '')) {
                         nvFW.alert('Ingrese un DNI')
                         return

                     } else {
                         var filtros = {}
                         filtros["nro_docu"] = $('nro_docu').value
                         filtros["month"] = credito_grupos.meses
                         credito_grupos.aplicarFiltro(filtros)
                     }

                 }

                 credito_grupos.filtroGrupos = function (cod_grupo) {
                     //filtros["nro_docu"] = $('nro_docu').value
                     var filtros = {}
                     filtros["estados"] = cod_grupos[cod_grupo]["estados"]
                     filtros["month"] = credito_grupos.meses

                     credito_grupos.aplicarFiltro(filtros)
                 }

                 credito_grupos.aplicarFiltro = function (filtros) {


                     //filtros['nro_vendedor'] = consulta.nro_vendedor
                     //filtros['nro_docu'] = consulta.cliente.nro_docu


                     let win_creditos = top.window.precarga.show_modal_window({
                         url: 'creditos/credito_listar.aspx',
                         title: '<b>Mis créditos</b>',
                         //maxWidth: 440,
                         //maxHeight: 500,
                         //minimizable: false,
                         //maximizable: false,
                         //draggable: true,
                         //resizable: true,
                         //destroyOnClose: true,
                         //bloq_contenedor: $('divSelTrabajo')
                         userData: { filtros: filtros }
                     });
                     //win_creditos.options.userData = { filtros: filtros }
                     //win_creditos.showCenter(true)

                     //if (isMobile())
                     //    mostrarMenuIzquierdo()
                 }


             </script>
                    <script type="text/javascript" language="javascript" >

                        //var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }
                        //var win = nvFW.getMyWindow()



                        var vButtonItems = {}
                        vButtonItems[0] = {}
                        vButtonItems[0]["nombre"] = "Buscar";
                        vButtonItems[0]["etiqueta"] = "";
                        vButtonItems[0]["imagen"] = "buscar";
                        vButtonItems[0]["onclick"] = "return credito_grupos.buscarDNI()";
                        vButtonItems[0]["estilo"] = "B"

                        var vListButtons = new tListButton(vButtonItems, 'vListButtons');
                        vListButtons.loadImage("buscar", "/precarga/image/buscar.svg");

                        var nro_docu = 0;
                        var cod_grupos = {}
                        function window_onload() {
                            $("btnFe30").click()

                            vListButtons.MostrarListButton()

                            //fe_desde = new Date()
                            //fe_desde.setDate(1)

                        }

                        //var filtros = {}


                        function filtroGrupos(cod_grupo) {
                            filtros["nro_docu"] = $('nro_docu').value
                            filtros["estados"] = cod_grupos[cod_grupo]["estados"]
                            aplicarFiltro(filtros)
                        }

                        function buscarDNI() {

                            if (($('nro_docu').value == '')) {
                                nvFW.alert('Ingrese un DNI')
                                return

                            } else {
                                filtros["nro_docu"] = $('nro_docu').value
                                aplicarFiltro(filtros)
                            }

                        }

                        function filtroMes(idSel) {

                            var IDs = {
                                btnFe30: 0,
                                btnFe60: 1,
                                btnFe90: 2
                            }

                            for (id in IDs) 
                                if (id == idSel && credito_grupos.meses != IDs[id]) {
                                    $(id).addClassName("btnFe_selected")
                                    credito_grupos.meses = IDs[id]
                                    credito_grupos.mostrar_grupos()
                                }
                                else {
                                    $(id).removeClassName("btnFe_selected")
                                }
                            

                            //if (id == 'btnFe30') {
                            //    var cantidadDias = 30

                            //} else if (id == 'btnFe60') {
                            //    var cantidadDias = 60

                            //} else if (id == 'btnFe90') {
                            //    var cantidadDias = 90

                            //}

                            //var fechaActual = new Date();

                            //var fe_desde = (new Date(fechaActual.getTime() - ((cantidadDias) * 24 * 60 * 60 * 1000))).toLocaleDateString();

                            //filtros["fe_desde"] = fe_desde


                            //$(id).style.background = '#194693';

                            /*aplicarFiltro(filtros)*/
                        }

                        function aplicarFiltro(filtros) {


                            //filtros['nro_vendedor'] = consulta.nro_vendedor
                            //filtros['nro_docu'] = consulta.cliente.nro_docu


                            let win_creditos = top.window.createWindow2({
                                url: 'creditos/credito_listar.aspx',
                                title: '<b>Mis créditos</b>',
                                maxWidth: 440,
                                maxHeight: 500,
                                minimizable: false,
                                maximizable: false,
                                draggable: true,
                                resizable: true,
                                destroyOnClose: true,
                                bloq_contenedor: $('divSelTrabajo')

                            });
                            win_creditos.options.userData = { filtros: filtros }
                            win_creditos.showCenter(true)

                            //if (isMobile())
                            //    mostrarMenuIzquierdo()
                        }

                        function window_onresize() {
                            try {
                                var dif = Prototype.Browser.IE ? 5 : 2
                                body_height = $$('body')[0].getHeight()
                                div_filtro = $('divFiltro').getHeight()
                                $('containerDiv').setStyle({ height: body_height - dif - 2 + 'px' })
                                $('iframe_cr').setStyle({ height: body_height - div_filtro - dif - 10 + 'px' })
                            }
                            catch (e) { }
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

                    </script>
        </head>

        <body onload="return window_onload()" onresize="return window_onresize()"
            style="height: 100%; overflow: hidden;">
           
            <div class="conteinerCreditos" id="containerDiv">

               

                    <div id="filtro_creditos">
                        
                        <div id="filtroFecha">
                             <div id="div_fecha">
                                 <input type="button" id="btnFe30" class="btnFe" value="30 Dias" onclick="filtroMes(id)" />
                                 <input type="button" id="btnFe60" class="btnFe" value="60 Dias" onclick="filtroMes(id)" />
                                 <input type="button" id="btnFe90" class="btnFe" value="90 Dias" onclick="filtroMes(id)" />
                             </div>
                        </div>

                        <div id="divCrFiltroLeft">
                            
                            <div id="divFiltroDNI">
                                 <input type="number" placeholder="DNI" name="nro_docu" id="nro_docu" style="text-align:right; height: 30px;" maxlength="10" onkeypress="return nro_docu_onkeypress(event)" />
                                 
                            </div>
                            <div id="divBuscar"></div>
                        </div>
                 
                    <div id="lista_grupos">        
                    </div>

                </div>
   
            </div>

        </body>

        </html>