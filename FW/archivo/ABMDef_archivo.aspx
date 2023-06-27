<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

    Dim op As nvFW.nvSecurity.tnvOperador = nvApp.operador
    If Not op.tienePermiso("permisos_def_archivo", 4) Then
        Response.Redirect("/FW/error/httpError_401.aspx?No posee permisos realizar la operación.")
    End If

    Dim nro_def_archivo As Integer = nvUtiles.obtenerValor("nro_def_archivo", 0)
    Dim nro_archivo_id_tipo As Integer = nvUtiles.obtenerValor("nro_archivo_id_tipo", 0)
    Dim nro_def_archivo_ant As Integer = nvUtiles.obtenerValor("nro_def_archivo_ant", 0)
    Dim id_tipo As Integer = nvUtiles.obtenerValor("id_tipo", 0)
    Dim accion As String = nvUtiles.obtenerValor("accion", "")

    If (accion.ToUpper = "ABM") Then

        Dim err As New tError()
        Try

            If nro_archivo_id_tipo = 0 Or id_tipo = 0 Then
                err.numError = -99
                err.mensaje = "Imposible realizar el cambio solicitado"
                err.response()
            End If

            Dim strSQL As String = "select 1 from archivo_leg_cab where nro_archivo_id_tipo = " & nro_archivo_id_tipo & " and id_tipo = " & id_tipo 'and nro_def_archivo = " & nro_def_archivo_ant & "
            Dim rs As ADODB.Recordset = DBExecute(strSQL)
            If rs.EOF = True Then
                strSQL = "insert into archivo_leg_cab (nro_archivo_id_tipo,nro_def_archivo,id_tipo) "
                strSQL += " values (" & nro_archivo_id_tipo & "," & nro_def_archivo & "," & id_tipo & ")" & vbCrLf
                strSQL += " select @@IDENTITY as id_ar_leg_cab"
            Else
                strSQL = "update archivo_leg_cab set nro_def_archivo = " & nro_def_archivo & " where nro_archivo_id_tipo = " & nro_archivo_id_tipo & " and nro_def_archivo = " & nro_def_archivo_ant & " and id_tipo = " & id_tipo
            End If

            DBExecute(strSQL)

        Catch ex As Exception
            err.numError = -99
            err.parse_error_script(ex)
        End Try

        err.response()

    End If

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>ABM Definición de Archivo</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/nvUtiles.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">

        var vButtonItems = new Array();
        vButtonItems[0] = new Array();
        vButtonItems[0]["nombre"] = "Aceptar";
        vButtonItems[0]["etiqueta"] = "Aceptar";
        vButtonItems[0]["imagen"] = "guardar";
        vButtonItems[0]["onclick"] = "return btnAceptar_onclick()";

        vButtonItems[1] = new Array();
        vButtonItems[1]["nombre"] = "Cancelar";
        vButtonItems[1]["etiqueta"] = "Cancelar";
        vButtonItems[1]["imagen"] = "salir";
        vButtonItems[1]["onclick"] = "return btnCancelar_onclick()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("guardar", '/FW/image/icons/guardar.png')
        vListButton.loadImage("salir", '/FW/image/icons/salir.png')

        var win = nvFW.getMyWindow();

        function window_onload() {
            vListButton.MostrarListButton()
            campos_defs.set_value("nro_def_archivo",<%=nro_def_archivo%>)
        }

        function btnAceptar_onclick() {
            
                if(campos_defs.value("nro_def_archivo") == "")
	  			 {
				  alert("Debe seleccionar una definición")
				  return
			 	 }

				 nvFW.error_ajax_request('ABMDef_archivo.aspx', {
							parameters: {
								accion:'abm',
                                nro_def_archivo: campos_defs.value("nro_def_archivo"),
                                id_tipo: <% = id_tipo%>,
                                nro_def_archivo_ant: <%= nro_def_archivo%>,
                                nro_archivo_id_tipo : <%= nro_archivo_id_tipo%>
							},
							onSuccess: function(err, transport) {
								win.options.userData = {retorno:"refresh"}
								win.close()
							},
							onFailure: function(err) {
								alert(err.mensaje, {
									title: '<b>' + err.titulo + '</b>',
									width: 350
								})
								return
							},
							bloq_msg: 'Guardando definición...',
							error_alert: false
						});

        }

	   function btnCancelar_onclick() {
           win.close()
     	}

</script>

</head>
<body onload="return window_onload()" style="width: 100%; height: 100%; overflow: auto">

        <table style="width: 100%" class='tb1'>
            <tr class="tbLabel">
                <td style="text-align:center">Definición</td>
            </tr>
            <tr>
                <td style="width: 80%"><% = nvCampo_def.get_html_input("nro_def_archivo") %></td>
            </tr>
        </table>
        <br><br>
        <table style="width: 100%">
            <tr>
                <td style="width:10%">&nbsp;</td>
                <td>
                    <div id="divAceptar"></div>
                </td>
                <td style="width:10%">&nbsp;</td>
                <td>
                    <div id="divCancelar"></div>
                </td>
               <td style="width:10%">&nbsp;</td>
            </tr>
        </table>

</body>
</html>
