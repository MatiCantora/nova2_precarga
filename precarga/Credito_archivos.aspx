<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageMutualPrecarga" %>

<%


    Me.contents.Add("credito_archivos", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCredito_archivos'><campos>*,dbo.rm_credito_count_defs (nro_credito,nro_def_detalle) as cantidad,dbo.rm_tiene_permiso('permisos_archivos', permiso) as permiso_tiene</campos><orden></orden><filtro></filtro></select></criterio>"))
    Me.contents.Add("cr_fecha", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='credito'><campos>nro_credito</campos><filtro><nro_credito type='in'>%nro_credito%</nro_credito><OR><SQL type='sql'>(MONTH(GETDATE())=MONTH(fe_estado) OR (MONTH(GETDATE())-1=MONTH(fe_estado) AND DAY(fe_estado)>14)) and YEAR(GETDATE())=YEAR(fe_estado)</SQL><SQL type='sql'>(YEAR(GETDATE())-1=YEAR(fe_estado) and month(DATEADD(MONTH,-1,GETDATE()))=MONTH(fe_estado) AND DAY(fe_estado)>14)</SQL></OR></filtro></select></criterio>"))
    Me.contents.Add("cr_estado", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCreditos'><campos>nro_credito</campos><filtro><nro_credito type='in'>%nro_credito%</nro_credito><estado type='in'>'A','B','D','E','L','M','O','P','R','U','Z','H'</estado></filtro></select></criterio>"))
    Me.contents.Add("cr_operador", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>tipo_docu,nro_docu</campos><filtro><login type='igual'>'%login%'</login></filtro></select></criterio>"))
    Me.contents.Add("cr_vendedor", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verVendedores'><campos>tipo_docu,nro_docu</campos><filtro><nro_vendedor type='igual'>%nro_vendedor%</nro_vendedor></filtro></select></criterio>"))
    Me.contents.Add("credito", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='credito'><campos>nro_vendedor</campos><orden></orden><filtro><nro_credito type='igual'>%nro_credito%</nro_credito></filtro></select></criterio>"))
    Me.contents.Add("capturas", nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verCapturas_creditos'><campos>*</campos><filtro><nro_credito type='igual'>%nro_credito%</nro_credito><operador type='distinto'>dbo.rm_nro_operador()</operador><fin_captura type='isnull'/></filtro><orden></orden></select></criterio>"))

    'Me.contents("permisos_web3") = op.permisos("permisos_web3")
    Me.addPermisoGrupo("permisos_web3")
    'Dim a As Boolean = operador.tienePermiso("permisos_web4", 1)
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>NOVA Precarga</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <link href="css/cabe_precarga.css" type="text/css" rel="stylesheet" />
    <link href="css/precarga.css" type="text/css" rel="stylesheet" />
    <link rel="shortcut icon" href="image/icons/nv_admin.ico" />
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language='javascript' src="script/precarga.js"></script>
    <script type="text/javascript" language='javascript' src="/FW/script/tCampo_head.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript" language="javascript" class="table_window">

        //var alert = function (msg) { Dialog.alert(msg, { className: "alphacube", width: 300, height: 100, okLabel: "cerrar" }); }

        var win = nvFW.getMyWindow()

        var vMenu1 = new tMenu('DIV_Menu1', 'vMenu1');
        vMenu1.alineacion = 'derecho';
        vMenu1.estilo = 'O'

        vMenu1.loadImage("archivo", "./image/nueva.png")

        vMenu1.CargarMenuItemXML("<MenuItem id='0' style='width: 50%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='1' style='width: 30%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Solicitar/Adjuntar certificado</Desc><Acciones><Ejecutar Tipo='script'><Codigo>Solicitar_certificado()</Codigo></Ejecutar></Acciones></MenuItem>")
        vMenu1.CargarMenuItemXML("<MenuItem id='2' style='width: 20%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>archivo</icono><Desc>Adjuntar Archivos</Desc><Acciones><Ejecutar Tipo='script'><Codigo>ABMArchivos()</Codigo></Ejecutar></Acciones></MenuItem>")


        //var vButtonItems = {}
        //vButtonItems[0] = {}
        //vButtonItems[0]["nombre"] = "Archivos";
        //vButtonItems[0]["etiqueta"] = "Adjuntar Archivos";
        //vButtonItems[0]["imagen"] = "archivo";
        //vButtonItems[0]["onclick"] = "return ABMArchivos()";

        //vButtonItems[1] = {}
        //vButtonItems[1]["nombre"] = "Certificado";
        //vButtonItems[1]["etiqueta"] = "Solicitar/Adjuntar certificado";
        //vButtonItems[1]["imagen"] = "archivo";
        //vButtonItems[1]["onclick"] = "return Solicitar_certificado()";

        //var vListButtons = new tListButton(vButtonItems, 'vListButtons');
        //vListButtons.loadImage("archivo", "image/nueva.png");

        var nro_credito = 0
        var nro_vendedor
        function window_onload() {
            //vListButtons.MostrarListButton()
            vMenu1.MostrarMenu();

            nro_credito = win.options.userData.param['nro_credito']
            mostrar_archivos()
            window_onresize()
        }

        function verificar_captura(nro_credito) {
            var msj_captura = ''
            var rs = new tRS()
            //rs.open("<criterio><select vista='verCapturas_creditos'><campos>*</campos><filtro><nro_credito type='igual'>" + nro_credito + "</nro_credito><operador type='distinto'>dbo.rm_nro_operador()</operador><fin_captura type='isnull'/></filtro><orden></orden></select></criterio>") 
            rs.open({ filtroXML: nvFW.pageContents["capturas"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            if (!rs.eof())
                msj_captura = 'El crédito <b>Nº ' + nro_credito + '</b> se encuentra capturado por el operador <b>' + rs.getdata('nombre_operador') + '</b>, desde <b>' + rs.getdata('captura_origen') + '</b>. No puede ser editado.'
            return msj_captura
        }

        var win_files
        function ABMArchivos() {
            var msj_captura = ''
            msj_captura = verificar_captura(nro_credito)
            if (msj_captura != '') {
                alert(msj_captura)
                return
            }
            var param = {}
            param['nro_credito'] = nro_credito
            win_files = window.top.createWindow2({
                url: 'ABMDocumentos.aspx',
                title: '<b>Adjuntar Documentos</b>',
                centerHFromElement: window.top.$("contenedor"),
                parentWidthElement: window.top.$("contenedor"),
                parentWidthPercent: 0.9,
                parentHeightElement: window.top.$("contenedor"),
                parentHeightPercent: 0.9,
                maxHeight: 500,
                //setHeightToContent: true,
                //setWidthMaxWindow: true,
                minimizable: false,
                maximizable: false,
                draggable: true,
                resizable: true,
                onClose: ABMArchivos_return
            });
            win_files.options.userData = { param: param }
            win_files.showCenter(true)
        }

        function ABMArchivos_return() {
            var success = win_files.options.userData.success
            if (success == true)
                mostrar_archivos()
        }

        function Solicitar_certificado()
        {


            var strXML = ""
            var strHTML = ""
            nvFW.bloqueo_activar($(document.documentElement), 'blq_precarga', 'Consultando certificado&nbsp;&nbsp;&nbsp;<img border="0" id="img_cancelar" src="image/cancel.png" align="absmiddle" title="Cancelar" style="vertical-align:middle; cursor: pointer" />')
            var oXML = new tXML();
            oXML.async = true
            oXML.load('/FW/servicios/ROBOTS/GetXML.aspx', 'accion=certificado_ba_educacion&criterio=<criterio><nro_credito>' + nro_credito + '</nro_credito><nro_vendedor>' + nro_vendedor + '</nro_vendedor></criterio>',
                            function () {
                                
                                 nvFW.bloqueo_desactivar($(document.documentElement), 'blq_precarga')
                                var NODs = oXML.selectNodes('error_mensajes/error_mensaje')
                                if (NODs.length != 0) {
                                    numerror = selectSingleNode('@numError', NODs[0]).nodeValue 
                                    mensaje = XMLText(selectSingleNode('mensaje', NODs[0]))
                                    if(numerror!=0)
                                    {
                                        alert(numerror + " - " + mensaje)
                                    } else {
                                        mostrar_archivos()
                                    }
                                }                                
                            });

        

        }//solicitar certificado

        function window_onresize() {
            try {
                $("iframe_archivos").setStyle({ width: $$("body")[0].getWidth() + "px" })
                $("tbTitulo").setStyle({ width: $$("body")[0].getWidth() + "px" })

            }
            catch (e) { }
        }

        function getWidth() {
            return $$("body")[0].getWidth();
        }

        function comprobar_fecha(nro_credito) {
            var rs = new tRS();
            //rs.open("<criterio><select vista='credito'><campos>nro_credito</campos><filtro><nro_credito type='in'>" + $('nro_credito').value + "</nro_credito><OR><SQL type='sql'>(MONTH(GETDATE())=MONTH(fe_estado) OR (MONTH(GETDATE())-1=MONTH(fe_estado) AND DAY(fe_estado)>14)) and YEAR(GETDATE())=YEAR(fe_estado)</SQL><SQL type='sql'>(YEAR(GETDATE())-1=YEAR(fe_estado) and month(DATEADD(MONTH,-1,GETDATE()))=MONTH(fe_estado) AND DAY(fe_estado)>14)</SQL></OR></filtro></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents["cr_fecha"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            if (rs.recordcount > 0)
                return true
            else
                return false
        }

        function comprobar_estado(nro_vendedor) {
            var rs = new tRS();
            //rs.open("<criterio><select vista='verCreditos'><campos>*</campos><filtro><nro_credito type='in'>" + $('nro_credito').value + "</nro_credito><estado type='in'>'A','B','D','E','L','M','O','P','R','U','Z'</estado></filtro></select></criterio>")
            rs.open({ filtroXML: nvFW.pageContents["cr_estado"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            if (rs.recordcount > 0)
                return true
            else
                return false
        }

        function comprobar_vendedor(nro_vendedor, login) {

            var rs1 = new tRS();
            //rs1.open("<criterio><select vista='operadores'><campos>tipo_docu,nro_docu</campos><filtro><login type='igual'>'"+login+"'</login></filtro></select></criterio>")
            rs1.open({ filtroXML: nvFW.pageContents["cr_operador"], params: "<criterio><params login='" + login + "' /></criterio>" })
            var rs2 = new tRS();
            //rs2.open("<criterio><select vista='verVendedores'><campos>tipo_docu,nro_docu</campos><filtro><nro_vendedor type='igual'>"+nro_vendedor+"</nro_vendedor></filtro></select></criterio>")
            rs2.open({ filtroXML: nvFW.pageContents["cr_vendedor"], params: "<criterio><params nro_vendedor='" + nro_vendedor + "' /></criterio>" })
            if (rs1.recordcount > 0 && rs2.recordcount > 0) {
                if (rs1.getdata("tipo_docu") == rs2.getdata("tipo_docu") && rs1.getdata("nro_docu") == rs2.getdata("nro_docu"))
                    return true
            }

            return false
        }

      
        function mostrar_archivos() {
            var rs = new tRS();
            rs.open({ filtroXML: nvFW.pageContents["credito"], params: "<criterio><params nro_credito='" + nro_credito + "' /></criterio>" })
            nro_vendedor = rs.getdata('nro_vendedor')

            var plantilla = ''
            var filtro = ""
            var permisos_web3 = nvFW.pageContents["permisos_web3"]
            if (!nvFW.tienePermiso("permisos_web3",11)) //Ver archivos
                plantilla = "sin_permisos.xsl"
            else {
                plantilla = "HTML_ver_archivos_def.xsl"
                var permitir = true

                if (!nvFW.tienePermiso("permisos_web3", 12)) { //Ver archivos sin restricción de fecha
                    if (!comprobar_fecha(nro_credito))
                        permitir = false
                }

                if (!nvFW.tienePermiso("permisos_web3", 13)) { //Ver archivos sin restricción de estados
                    if (!comprobar_estado(nro_vendedor))
                        permitir = false
                }

                if (!nvFW.tienePermiso("permisos_web3", 14)) { //Ver archivos de otros vendedores
                    if (!comprobar_vendedor(nro_vendedor, login))
                        permitir = false
                }
                if (!permitir)
                    plantilla = "sin_permisos.xsl"
            }

            var filtroWhere = "<nro_credito type='igual'>" + nro_credito + "</nro_credito><NOT><archivo_descripcion type='isnull' /></NOT><NOT><nro_archivo type='isnull' /></NOT>"
            nvFW.exportarReporte({
                filtroXML: nvFW.pageContents.credito_archivos,
                filtroWhere: "<criterio><select><filtro>" + filtroWhere + "</filtro></select></criterio>",
                //path_xsl: 'report\\verCredito_archivos\\HTML_ver_archivos_def.xsl',
                xsl_name: plantilla,
                formTarget: 'iframe_archivos',
                nvFW_mantener_origen: true,
                bloq_contenedor: 'iframe_archivos'
            })

        }


    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="height: 100%; overflow: auto; background-color: white">
    <div id="DIV_Menu1" style="width: 100%"></div>

    <div style="overflow: auto; -webkit-overflow-scrolling: touch">
        <iframe name="iframe_archivos" id="iframe_archivos" src="/fw/enBlanco.htm" style='width: 100%; height: 94%; overflow: auto;'
            frameborder="0"></iframe>
    </div>
</body>
</html>
