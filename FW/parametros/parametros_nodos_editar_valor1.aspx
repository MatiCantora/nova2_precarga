<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<% 
    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim valor_nodo As String = nvFW.nvUtiles.obtenerValor("valor_nodo", "")
    Dim nro_par_nodo As String = nvFW.nvUtiles.obtenerValor("nro_par_nodo", "")
    Dim par_nodo As String
    Dim stringSQL As String

    Dim filtroParametros = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista=""verParametros_nodos""><campos>*</campos><filtro></filtro><orden>orden</orden></select></criterio>")

    'cargar los permisos de los parametros
    Dim strSQL As String = "select distinct permiso_grupo from verParametros_nodos where permiso_grupo is not null"
    Dim rs_permisos As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
    While Not rs_permisos.EOF()
        Me.addPermisoGrupo(rs_permisos.Fields("permiso_grupo").Value)
        rs_permisos.MoveNext()
    End While
    nvDBUtiles.DBCloseRecordset(rs_permisos)

    If nro_par_nodo = "" Then
        stringSQL = "select par_nodo from verParametros_nodos where par_nodo_tipo = 'M'"
    Else
        stringSQL = "select par_nodo from verParametros_nodos where par_nodo_tipo = 'M' and nro_par_nodo = " + nro_par_nodo
    End If


    If (modo.ToUpper() <> "GUARDAR") Then

        Dim rs = nvFW.nvDBUtiles.DBOpenRecordset(stringSQL)
        If (Not rs.EOF) Then
            par_nodo = rs.Fields("par_nodo").Value
        End If
        nvFW.nvDBUtiles.DBCloseRecordset(rs)
    End If

    'Modificacion
    If (modo.ToUpper() = "DESENCRIPTAR") Then
        Dim Err As nvFW.tError = New nvFW.tError()
        Try
            err.numError = 0
            err.titulo = ""
            Err.mensaje = nvFW.nvSecurity.nvCrypto.EncBase64ToStr(valor_nodo)
            Err.comentario = ""
            Err.params("value") = nvFW.nvSecurity.nvCrypto.EncBase64ToStr(valor_nodo)

        Catch e As Exception
            err.parse_error_script(e)
        End Try

        err.response()

    End If

    If (modo.ToUpper() = "MODIFICAR") Then
        Dim err = New nvFW.tError()
        Try

            par_nodo = nvFW.nvUtiles.obtenerValor("par_nodo", "")
            Dim strXML = nvFW.nvUtiles.obtenerValor("strXML", "")

            Dim objXML As System.Xml.XmlDocument = New System.Xml.XmlDocument()
            objXML.LoadXml(strXML)

            Dim NODS = objXML.SelectNodes("/parametros/parametro")
            For i As Integer = 0 To NODS.Count - 1
                Dim nod = NODS(i)
                Dim id_param = nod.SelectSingleNode("@id_param").Value
                Dim encriptar = nod.SelectSingleNode("@encriptar").Value
                Dim valor = nod.SelectSingleNode("valor").InnerText

                If encriptar = "true" Then
                    valor = nvFW.nvSecurity.nvCrypto.StrToEncBase64(valor)
                End If

                nvFW.nvDBUtiles.DBExecute("update [Parametros_value] set valor = '" + valor + "' where id_param = '" + id_param + "'")

                nvLog.addEvent("lg_edit_param", "id_param=" & id_param & ";valor=" & valor & ";nodo=" & par_nodo & nvLog.parentLogTrack)

            Next

            err.numError = 0
        Catch e As Exception
            err.parse_error_script(e)
        End Try
        err.response()

    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Parametros listado</title>
    <link href='/fw/css/base.css' type='text/css' rel='stylesheet' />
    <script type="text/javascript" src="/FW/script/tCampo_head.js" language="JavaScript"></script>
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <% =Me.getHeadInit()%>

    <script type="text/javascript" language="javascript">

     var par_nodo = '<% =par_nodo %>' 
     var nro_par_nodo = '<% =nro_par_nodo %>'
     var filtroParametros = '<% =filtroParametros %>'
     var tipo_nodo

     function window_onload(){
        var rs = new tRS();
        rs.open(filtroParametros, '', "<nro_par_nodo type='igual'>" + nro_par_nodo + "</nro_par_nodo>")
        if (!rs.eof())
            tipo_nodo = rs.getdata("par_nodo_tipo")
        
        dibujar()
        window_onresize()
    }

    function redraw(idParam){
        var filtroWhere = "<id_param type='igual'>'" + idParam + "'</id_param>";
        var rs = new tRS();
        rs.open(filtroParametros, '', filtroWhere, '', '');
        if(!rs.eof()){
            nro_par_nodo = rs.getdata('nro_par_nodo_dep');
            $('divMenuABM').innerHTML = "";
            Menus.vMenuABM.MenuItems[0].innerHTML = '<td class="mnuCELL_Normal_A" style="text-align:center" ><span>' + rs.getdata('par_nodo_dep') + '</span></td>';
            vMenuABM.MostrarMenu();
            dibujar();
        }
    }

    function link(nro) { nro_par_nodo = nro; dibujar() }

    function dibujar(){   
        $('divModulos').innerHTML = '';
        var strHTML = '<table class="tb1 highlightOdd highlightTROver" id="tbModulo" style="width:100%;">';
        var filtroWhere = "<par_nodo_tipo type='distinto'>'P'</par_nodo_tipo><nro_par_nodo_dep type='igual'>" + nro_par_nodo + "</nro_par_nodo_dep>";

        var rs = new tRS();
        rs.open(filtroParametros, '', filtroWhere, '', ''); 
        while (!rs.eof()) {
            desc = rs.getdata('par_nodo');
            title = desc;
            desc = (desc.length > 150) ? desc.substr(0, 150) + '...' : desc;
             
            strHTML += '<tr>';
            strHTML += '<td style="width:98%;text-align:left;color:blue;font-weight:bold" title="' + title + '">&nbsp;<img src="/fw/image/sistemas/modulo.png" style="cursor:pointer" onclick="link(' + rs.getdata("nro_par_nodo") + ')" />&nbsp;' + desc + '</td>';
            strHTML += '</tr>';
            rs.movenext();
        }
        strHTML += '</table>';

        $('divModulos').insert({ top: strHTML });

        if(tipo_nodo == 'P')
            filtroWhere = "<par_nodo_tipo type='igual'>'P'</par_nodo_tipo><nro_par_nodo type='igual'>" + nro_par_nodo + "</nro_par_nodo>";
        else
            filtroWhere = "<par_nodo_tipo type='igual'>'P'</par_nodo_tipo><nro_par_nodo_dep type='igual'>" + nro_par_nodo + "</nro_par_nodo_dep>";    

        nvFW.exportarReporte({
              filtroXML: filtroParametros
            , filtroWhere: filtroWhere
            , path_xsl: "report\\parametros\\ver_parametros.xsl"
            , formTarget: 'divParametros'
            , nvFW_mantener_origen: true
            , id_exp_origen: 0
            , bloq_contenedor: $('divParametros')
            , cls_contenedor: 'divParametros'
        }) 
    }
 
    function desencriptarValor(param) {
        var resultado;
        if (!param) return '';

        nvFW.nvFW_error_ajax_request('parametros_nodos_editar_valor.aspx', {
            asynchronous: false,
            parameters: { modo: 'DESENCRIPTAR', valor_nodo: param  },
            onSuccess: function (err, transport) {
                if (err.numError != 0)
                {
                    alert(err.mensaje);
                }
                else {
                    resultado =  err.params['value'] ;
                }
            }
        });

        return resultado;
    }

    function mostrarValor() {
        if ($("checkboxEncriptado").checked) 
            changeInputType($('infoNodo'), 'text');
        else 
            changeInputType($('infoNodo'), 'password');
    }

    function changeInputType(oldObject, oType) {
        var newObject = document.createElement('input');
        newObject.type = oType;
        newObject.style.width = '100%';
        if (oldObject.name) newObject.name = oldObject.name;
        if (oldObject.id) newObject.id = oldObject.id;
        if (oldObject.value) newObject.value = oldObject.value;
        oldObject.parentNode.replaceChild(newObject, oldObject);
        
        return newObject;
    }

    function showValorEncriptado(idParam, valor) {            
        var valorText = desencriptarValor(valor);
        
        var htmlDialog = "<table class='tb1' style='height:50px !Important '>" +
                            "<tr>" +
                                "<td style='width:10%;text-align:center'>" +
                                    idParam + ": " +
                                "</td>" +
                                "<td style='width:90%;text-align:center'>" +
                                    "<input type='password' value='" + valorText + "' id='infoNodo' style='width: 100%;' />" +
                                "</td>" +
                            "</tr>" +
                            "<tr>" +
                                "<td style='width:100%;text-align:left' colspan='2'>" +
                                    "<input type='checkbox' id='checkboxEncriptado' onClick='mostrarValor()'> Ver Parámetro <br></input>"
                                "</td>" +
                            "</tr>" +
                        "</table>";

        nvFW.confirm(htmlDialog,{
        width: 300,
        heigth: 70,
        okLabel: "Guardar",
        cancelLabel: "Cancelar",
        title: "<b>Modificar Parametro:</b>",
        closable: true,
        onShow: function (win) { },
            onOk: function (win) {
                    var nuevo_valor = $('infoNodo').value
                    guardar(idParam, nuevo_valor, true);
                    win.close();
            },
            onCancel: function (win) {
                win.close();
            }
        });
    }

    function showValor(idParam, valor, encriptar, permiso_grupo, nro_permiso, _par_nodo){
        par_nodo = _par_nodo 
        if (nvFW.tienePermiso(permiso_grupo, nro_permiso)) {
            if (encriptar == 'True') 
                showValorEncriptado(idParam, valor)
            else{
                var htmlDialog = "<table class='tb1' style='height:50px !Important'>" +
                                "<tr>" +
                                    "<td class='Tit1' style='width:10%;text-align:center'>" +
                                        idParam + ": " +
                                    "</td></tr>" +
                                    "<tr><td style='width:90%;text-align:center'>" +
                                        "<input type='text' value='" + valor + "' id='infoNodo' style='width: 100%;' />" +
                                    "</td>" +
                                "</tr>" +
                            "</table>";

                nvFW.confirm(htmlDialog, {
                    width: 500,
                    heigth: 200,
                    okLabel: "Guardar",
                    cancelLabel: "Cancelar",
                    title: "<b>Modificar Parametro:</b>",
                    closable: true,
                    onShow: function (win) {},
                    onOk: function (win) { 
                        var nuevo_valor = $('infoNodo').value
                        guardar(idParam, nuevo_valor, false);
                        win.close();
                    },
                    onCancel: function (win) {
                        win.close();
                    },
                    onClose: function (win) { }
                });
           }
        }
        else{
             alert("No tiene permiso para editar el valor del parámetros.")
       }
    }

    function guardar(idParam, valor, encriptado) {    
        var xmldato = "<?xml version='1.0' encoding='ISO-8859-1'?>"
        xmldato += "<parametros>"
        xmldato += "<parametro id_param='" + idParam + "' encriptar='"+encriptado+"'>"
        xmldato += "<valor><![CDATA[" + valor + "]]></valor>"
        xmldato += "</parametro></parametros>"
        
        nvFW.error_ajax_request('parametros_nodos_editar_valor.aspx', {
            parameters: { modo: 'MODIFICAR', strXML: xmldato, par_nodo: par_nodo },
                                onSuccess: function (err, transport) {
                                    if (err.numError != 0) {
                                        alert(err.mensaje)
                                        return
                                    }
                                    else {
                                      //  ObtenerValor("menu_left").actualizar_nodo()
                                        dibujar()
                                    }
                                }
                                });  
     }
     
     function window_onresize() {
          try {        
             var dif = Prototype.Browser.IE ? 5 : 2
             var body_height = $$('body')[0].getHeight()
             var cab_height = $('divMenuABM').getHeight()
             var div_mod = $('divModulos').getHeight()

             $('divParametros').setStyle({ 'height': body_height - cab_height  - div_mod - dif + 'px' })
            }
          catch(e){}  
     }

     function abrirVentanaBuscar() {
         var win = nvFW.createWindow({
             url: 'parametros_buscar.aspx',
             title: '<b>Buscar Parámetros</b>',
             minimizable: false,
             maximizable: false,
             setWidthMaxWindow: true,
             draggable: true,
             width: 600,
             parameters: {
                 consulta: filtroParametros,
                 filtro: "<par_nodo_tipo type='igual'>'P'</par_nodo_tipo>",
                 path_reporte: "report\\parametros\\ver_parametros_buscar\\ver_parametros_buscar.xsl"
                            },
             height: 400,
             resizable: true
         });
         win.showCenter(true);
     }

    </script>

</head>
<body onload="window_onload()" onresize="return window_onresize()" style="margin: 0px; padding: 0px;width:100%;height:100%;overflow:hidden">
<div style="display: none;">nvFW.pageContents.id_param</div>
<div id="divMenuABM"></div>
    <script type="text/javascript" language="javascript">
     var DocumentMNG = new tDMOffLine;
     var vMenuABM = new tMenu('divMenuABM', 'vMenuABM');
     vMenuABM.loadImage("guardar", '/FW/image/icons/guardar.png')
     vMenuABM.loadImage("buscar", '/FW/image/icons/buscar.png')
     Menus["vMenuABM"] = vMenuABM
     Menus["vMenuABM"].alineacion = 'centro';
     Menus["vMenuABM"].estilo = 'A';
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='0' style='text-align:center'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + par_nodo + "</Desc></MenuItem>");
     Menus["vMenuABM"].CargarMenuItemXML("<MenuItem id='1' style='width:10%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>buscar</icono><Desc>Buscar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>abrirVentanaBuscar()</Codigo></Ejecutar></Acciones></MenuItem>");

     vMenuABM.MostrarMenu();
    </script> 
    <table class="tb1" id="tbCabM" style="width: 100%">
        <tr class="tbLabel">
            <td style="width: 98%"><b>Módulos</b></td>
        </tr>
    </table>
   <div id="divModulos" style="width:100%;overflow:auto;"></div> 
   <iframe name="divParametros" id="divParametros"  style="width:100%; overflow:auto;" frameborder="0" src="enBlanco.htm"></iframe>
</body>
</html>