<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<% 
    Dim xml = nvFW.nvUtiles.obtenerValor("xml", "")
    Dim err = New nvFW.tError()


    If xml <> "" Then
        Try
            Dim Cmd = Server.CreateObject("ADODB.Command")
            Cmd.ActiveConnection = nvFW.nvDBUtiles.DBConectar()
            Cmd.CommandType = 4
            Cmd.CommandTimeout = 1500
            Cmd.CommandText = "periodo_abm"
            Cmd.Parameters("@strXML").type = 201
            Cmd.Parameters("@strXML").size = xml.Length
            Cmd.Parameters("@strXML").value = xml

            Dim rs = Cmd.Execute()

            err.numError = rs.Fields("numError").Value
            err.titulo = rs.Fields("titulo").Value
            err.mensaje = rs.Fields("mensaje").Value
            err.comentario = rs.Fields("comentario").Value

        Catch ex As Exception
            err.parse_error_script(ex)
            err.numError = -99
            err.titulo = "Error en la actualización del periodo"
            err.mensaje = "Mensaje:  " & ex.Message
        End Try
        err.response()
    End If

    Me.contents("periodo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='periodos'><campos>*</campos><filtro></filtro></select></criterio>")

%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Periodo ABM</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="application/javascript" src="/FW/script/nvFW.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="application/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="application/javascript" src="/FW/script/tCampo_def.js"></script>

    <% = Me.getHeadInit() %>

    <style type="text/css">
        select:disabled { background-color: #EBEBE4; }
    </style>

    <script type="application/javascript">
        var filtroWhere
        var win = nvFW.getMyWindow()

        function window_onresize()
        {

        }

        function window_onload()
        {
            if (win.options.userData.nro != 0) {
                $('mes').value = win.options.userData.mes
                $('descripcion').value = win.options.userData.desc
                $('anio').value = win.options.userData.anio
                $('tbAnio_completo').hide()

            } else {
                 
            }

        }


        function guardar() {

            var rs = new tRS()
            rs.open({
                filtroXML: nvFW.pageContents.periodo,
                filtroWhere: '<criterio><select><filtro><mes type="igual">' + $('mes').value + '</mes><anio type="igual">' + $('anio').value +'</anio></filtro></select></criterio>'
            })

            if (rs.getdata('anio') == $('anio').value) {
                alert("El periodo ya existe.")
                return
            }

            if ($('anio').value == '') {
                alert("Ingrese el año")
                return
            }

            if ($('mes').value == '' && $('anio_completo').checked == false) {
                alert("Ingrese el mes")
                return
            }

            if ($('descripcion').value == '' && $('anio_completo').checked == false) {
                alert("Ingrese una descripción")
                return
            }

            var nro_periodo = win.options.userData.nro
            if($('anio_completo').checked == true)
                nro_periodo = -12

            var xml = "<?xml version='1.0' encoding='iso-8859-1'?>"
            xml += "<periodo>"
            xml += "<nro_periodo>" + nro_periodo + "</nro_periodo>"
            xml += "<desc_periodo>" + '<![CDATA[' + $('descripcion').value + ']]>' + "</desc_periodo>"
            xml += "<mes>" + $('mes').value + "</mes>"
            xml += "<anio>" + $('anio').value  + "</anio>" 
            xml += "</periodo>"

            error_ajax_request("periodo_ABM.aspx",
                {
                    parameters: {
                        xml: xml
                    },
                    onSuccess: function (err, parametros) {

                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }

                        parent.buscar()
                        //win.refresh()

                        win.close()
                    },
                    onFailure: function (err, parametros) {

                        if (err.numError != 0) {
                            alert(err.mensaje)
                            return
                        }
                    },
                    bloq_msg: 'Guardando',
                    error_alert: false
                })
        }

        function setDefinition() {
            var monthDesc = ''
            const monthVal = $('mes').value
            if ($('mes').value != '') {

                if (monthVal == 1) {
                    monthDesc = 'Enero'
                } else
                if (monthVal == 2) {
                    monthDesc = 'Febrero'
                } else
                if (monthVal == 3) {
                    monthDesc = 'Marzo'
                } else
                if (monthVal == 4) {
                    monthDesc = 'Abril'
                } else
                if (monthVal == 5) {
                    monthDesc = 'Mayo'
                } else
                if (monthVal == 6) {
                    monthDesc = 'Junio'
                } else
                if (monthVal == 7) {
                    monthDesc = 'Julio'
                } else
                if (monthVal == 8) {
                    monthDesc = 'Agosto'
                } else
                if (monthVal == 9) {
                    monthDesc = 'Septiembre'
                } else
                if (monthVal == 10) {
                    monthDesc = 'Octubre'
                } else
                if (monthVal == 11) {
                    monthDesc = 'Noviembre'
                } else
                if (monthVal == 12) {
                    monthDesc = 'Diciembre'
                }

                if ($('anio').value != '') {
                    monthDesc += ' ' + $('anio').value
                }

                $('descripcion').value = monthDesc
            }

        }

function alta_completa()
{
  if($('anio_completo').checked == true)
    $('tbMeses').hide()
  else
    $('tbMeses').show()
}

    </script>
</head>
<body onload="window_onload()" onresize='window_onresize()' style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
        <div id="divMenuTit" style="width: 100%; margin: 0; padding: 0;"></div>
        <script type="text/javascript">
            var vMenuTit = new tMenu('divMenuTit', 'vMenuTit');

            Menus["vMenuTit"] = vMenuTit
            Menus["vMenuTit"].alineacion = 'centro';
            Menus["vMenuTit"].estilo = 'A';
          
            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='0' style='width: 80px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono>guardar</icono><Desc>Guardar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>guardar()</Codigo></Ejecutar></Acciones></MenuItem>")
            Menus["vMenuTit"].CargarMenuItemXML("<MenuItem id='1' style='width: 460px;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
          
            vMenuTit.loadImage("guardar", "/FW/image/icons/guardar.png");

            vMenuTit.MostrarMenu()
        </script>
<input type="hidden" id="razon_social" />
<input type="hidden" id="nro_dc_mov_def" value="0"/>
    <table class="tb1" id="tabDefinicion">
        <tr>
            <td style="width: 5%" class="Tit1"><b>Descripción:</b></td>
            <td style="width:95%"><input style="width: 100%" type="text" id="descripcion" disabled/></td>            
        </tr>
    </table>
    <table class="tb1" id="tbAnio_completo"> 
        <tr>
            <td style="width:45%;white-space:nowrap" class="Tit1">Dar alta año completo:</td>
            <td style="width:5%;text-align:left" ><input style="width: 100%" type="checkbox" id="anio_completo" onclick="return alta_completa()" /></td>  
            <td >&nbsp;</td>
        </tr>
    </table>
      <table class="tb1">
        <tr>
            <td  class="Tit1" style="width: 40px">Año:</td>
            <td><input type="number" onkeypress="return ( this.value.length < 4 )" id="anio" onblur="setDefinition()" style="width: 100%" /></td>
         </tr>
    </table> 
   <table class="tb1" id="tbMeses"> 
        <tr>
            <td class="Tit1" style="width: 40px">Mes:</td>
            <td>
                <select onchange="setDefinition()" id="mes" style="width: 100%">
                    <option value=""></option>
                    <option value="1">01 Enero</option>
                    <option value="2">02 Febrero</option>
                    <option value="3">03 Marzo</option>
                    <option value="4">04 Abril</option>
                    <option value="5">05 Mayo</option>
                    <option value="6">06 Junio</option>
                    <option value="7">07 Julio</option>
                    <option value="8">08 Agosto</option>
                    <option value="9">09 Septiembre</option>
                    <option value="10">10 Octubre</option>
                    <option value="11">11 Noviembre</option>
                    <option value="12">12 Diciembre</option>
                </select>

            </td>
        </tr>
    </table> 
   
</body>
</html>
