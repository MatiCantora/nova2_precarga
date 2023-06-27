<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%
    Me.contents("filtro_parametros") = nvXMLSQL.encXMLSQL("<criterio><select vista='Transferencia_parametros'><campos>*</campos><grupo></grupo><filtro></filtro><orden>orden</orden></select></criterio>")
    Me.contents("verParametros_proceso") = nvXMLSQL.encXMLSQL("<criterio><select vista='verParametros_proceso'><campos>*</campos><grupo></grupo><filtro></filtro></select></criterio>")
    ' Me.contents("exportarParam") = nvFW.nvXMLSQL.encXMLSQL("<criterio><procedure CommandText='dbo.perfiles_batch_export_param2' CommantTimeOut='1500'><parametros><nro_proceso DataType='int'>%nro_proceso%</nro_proceso></parametros></procedure></criterio>")
    
    
    Dim id_transferencia = nvUtiles.obtenerValor("id_transferencia", "")
    Dim id_bpm = nvUtiles.obtenerValor("id_bpm", "")
    Dim nro_proceso = nvUtiles.obtenerValor("nro_proceso", "")
    Dim strXML = nvUtiles.obtenerValor("strxml", "")
    Dim err = New tError
    If strXML <> "" Then
        Try
            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("perfiles_batch_export_param2", ADODB.CommandTypeEnum.adCmdStoredProc)
            cmd.addParameter("@nro_proceso", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, , nro_proceso)
            cmd.addParameter("@strXML", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, , strXML)
            Dim rs As ADODB.Recordset = cmd.Execute()
      
            Dim arParam As trsParam = New trsParam
            arParam("SQL") = ""
            arParam("timeout") = 0
            arParam("objError") = Nothing
            arParam("logTrack") = ""
                 
            Dim XML As New System.Xml.XmlDocument
            XML = nvXMLSQL.RecordsetToXML(rs, arParam)
            DBCloseRecordset(rs)
            err.numError = 0
            err.params("strXML") = XML.OuterXml
            
        Catch ex As Exception
            err.numError = -99
            err.mensaje = ex.Message
        End Try
        
        err.response()
        
    End If
    
%>

<html>
<head>
<title>Transferencia ABM Parametros</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
     <script type="text/javascript" src="/FW/script/nvFW.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js" ></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js" ></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script> 
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>   
    <% = Me.getHeadInit()%>  

    <script type="text/javascript">

        var id_bpm = '<%= id_bpm %>'
        var nro_proceso = '<%= nro_proceso %>'
        var win = nvFW.getMyWindow()
        var vButtonItems = {}
        vButtonItems[0] = {}
        vButtonItems[0]["nombre"] = "Exportar";
        vButtonItems[0]["etiqueta"] = "Exportar";
        vButtonItems[0]["imagen"] = "exportar";
        vButtonItems[0]["onclick"] = "return exportar()";
        var vListButtons = new tListButton(vButtonItems, 'vListButtons')
        vListButtons.loadImage('exportar','/fw/image/filetype/excel.png')

        function window_onload() {
            
            vListButtons.MostrarListButton()
            window_onresize()

            var rs = new tRS()
            rs.open(nvFW.pageContents.filtro_parametros, "", '<id_transferencia>'+ $('id_transferencia').value +'</id_transferencia>')

            var strHTML = "<table id='param' class='tb1 highlightOdd highlightTROver' style='width:100%;overflow:auto'>"
            strHTML += "<tr><td><b>Selecc. Todos</b></td><td style='width:50px;text-align:center'><input style='width:50px;text-align:center' type='checkbox' name='check_todos' id='check_todos' onclick='selec_todos()'/></td></tr>"
            var i = 0
            while (!rs.eof()){
                strHTML += "<tr><td id='param_"+i+"'>" + rs.getdata("parametro") + "</td><td style='width:50px;text-align:center'><input style='width:50px;text-align:center' type='checkbox' name='check_" + i + "' id='check_" + i + "'/></td></tr>"
                i++
                rs.movenext()
            }
            strHTML += "</table>"
            $('divParametros').innerHTML = strHTML

        }

        function selec_todos(){
            var i = 0
            while ($('check_' + i)){
                $('check_' + i).checked =  $('check_todos').checked 
                i++
            }
        }

        function exportar(){  
             var param = "<param>"
             var i = 0
             while ($('check_' + i)){
                if($('check_' + i).checked)
                    param += "<p nombre='" + $('param_' + i).innerText + "' />"
                i++
            }
            param += "</param>"
               
            nvFW.error_ajax_request("perfiles_param_exportar.aspx",
                                        { parameters: { nro_proceso: nro_proceso, strXML: param }
                                            , onSuccess: function(er, a){
                                                if (er.numError != 0) {
                                                    top.nvFW.alert("No se pudo exportar el resultado. " + er.mensaje)
                                                }
                                                else{ 
                                                     nvFW.exportarReporte({
                                                            xml_data: er.params.strXML,
                                                            path_xsl: "report/excel_base.xsl",
                                                            filename: "Resultado proceso Nº "+nro_proceso+" .xls", 
                                                            salida_tipo: "adjunto",
                                                            ContentType: "application/vnd.ms-excel",
                                                            content_disposition: "attachment"
                                                      })
                                                }
                                            }
                                            , onFailure: function(err, b) { }
                                        })
        }
       
        function window_onresize() {
            var h_body = $$("BODY")[0].getHeight() ,
                h_cabe = $("divCab").getHeight() ,
                frame = $("divParametros")

            frame.setStyle({ height: h_body - h_cabe - 40 })
        }

    </script>
</head>
<body onload="return window_onload()" onresize="return window_onresize()" style="width: 100% !Important; height: 100% !Important; overflow: hidden; margin: 0px; padding: 0px;">
    <input type="hidden" name="id_transferencia" id="id_transferencia" value="<%= id_transferencia %>" />
    <div style="display: none;"><%= nvCampo_def.get_html_input("id_param") %></div>
    <div id="divCab" style="margin: 0px; padding: 0px;">
        <table class='tb1'>
            <tr class='tbLabel'>
                <td style='text-align: center'>Parámetros</td>
                <td style='width: 70px; text-align: center'>Exportar</td> 
            </tr>
        </table>
    </div>
    <div id="divParametros" style="width: 100%; overflow: auto;"></div>
    <div style="text-align:-webkit-center"><div id="divExportar" style="width:50%; text-align:center"></div></div>
</body>
</html>