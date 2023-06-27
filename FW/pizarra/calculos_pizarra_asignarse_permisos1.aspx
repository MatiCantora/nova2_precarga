<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    Dim operador As Integer = nvFW.nvApp.getInstance().operador.operador

    If operador <> 0 Then
        Dim strSQL As String = "SELECT oot.tipo_operador, ot.tipo_operador_desc" _
                        & " FROM operadores_operador_tipo oot " _
                        & " INNER JOIN operador_tipo ot ON oot.tipo_operador = ot.tipo_operador" _
                        & " WHERE operador = " & operador
        Try
            Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL)
            Dim perfiles As New trsParam()

            While Not rs.EOF
                perfiles.Add(rs.Fields("tipo_operador").Value, rs.Fields("tipo_operador_desc").Value)
                rs.MoveNext()
            End While

            Me.contents("perfiles") = perfiles
            nvDBUtiles.DBCloseRecordset(rs)
        Catch ex As Exception
            Me.contents("perfiles") = vbNull
        End Try
    Else
        Me.contents("perfiles") = vbNull
    End If
%>
<html>
<head>
    <title>Pizarra Auto-Asignarse Permisos %></title>
    <link rel="shortcut icon" href="/FW/image/icons/nv_mutual.ico" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/fw/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    
    <% = Me.getHeadInit() %>

    <script type="text/javascript">
        var win                     = nvFW.getMyWindow()
        var perfiles                = nvFW.pageContents.perfiles
        var vButtonItems            = []
        var perfil_permisos         = {}
        var $tbContent

        vButtonItems[0]             = []
        vButtonItems[0]["nombre"]   = "Cancelar";
        vButtonItems[0]["etiqueta"] = "Cancelar y continuar";
        vButtonItems[0]["imagen"]   = "cancelar";
        vButtonItems[0]["onclick"]  = "return btnCancelar_onclick()";
        vButtonItems[1]             = []
        vButtonItems[1]["nombre"]   = "Aceptar";
        vButtonItems[1]["etiqueta"] = "Asignar Permisos";
        vButtonItems[1]["imagen"]   = "asignar";
        vButtonItems[1]["onclick"]  = "return btnAceptar_onclick()";

        var vListButton = new tListButton(vButtonItems, 'vListButton');
        vListButton.loadImage("cancelar", "/FW/image/icons/cancelar.png")
        vListButton.loadImage("asignar", "/FW/image/icons/tilde.png")


        function window_onload()
        {
            $tbContent = $('tbContent')
            cargarTablaPerfiles()
            vListButton.MostrarListButton()
            window_onresize()
        }


        function window_onresize()
        {
            try {
                win.setSize(win.width, $tbContent.getHeight())
            }
            catch(e) {}
        }


        function cargarTablaPerfiles()
        {
            var html = '<table class="tb1 highlightOdd highlightTROver" id="tbPerfiles">'
            html += '<tr class="tbLabel"><td style="text-align: center;">Perfil</td><td style="text-align: center;">Ver</td><td style="text-align: center;">Editar</td></tr>'

            for (var tipo_operador in perfiles) {
                html += '<tr>'
                html += '<input type="hidden" name="perfil_' + tipo_operador + '" value="' + tipo_operador + '" />'
                html += '<td style="width: 60%;">&nbsp;' + perfiles[tipo_operador] + ' (' + tipo_operador + ')</td>'
                html += '<td style="width: 20%; text-align: center;"><input type="checkbox" name="chk_perfil_' + tipo_operador + '_ver" id="chk_perfil_' + tipo_operador + '_ver" style="cursor: pointer;" title="Habilitar ver en perfil ' + perfiles[tipo_operador] + '" value="1" /></td>'
                html += '<td style="width: 20%; text-align: center;"><input type="checkbox" name="chk_perfil_' + tipo_operador + '_editar" id="chk_perfil_' + tipo_operador + '_editar" style="cursor: pointer;" title="Habilitar editar en perfil ' + perfiles[tipo_operador] + '" value="2" /></td>'
                html += '</tr>'
            }

            html += '</table>'

            $("divPerfiles").innerHTML = html
        }


        function btnCancelar_onclick()
        {
            win.options.userData.permiso_autoasignado = 0
            win.close()
        }


        function btnAceptar_onclick()
        {
            var valores        = $('tbPerfiles').select('input[type=hidden]')
            var tipo_operador  = 0
            var valor          = 0
            perfil_permisos    = {}

            valores.each(function(perfil) {
                tipo_operador = perfil.value
                valor += $('chk_perfil_' + tipo_operador + '_ver').checked    ? parseInt($('chk_perfil_' + tipo_operador + '_ver').value)    : 0
                valor += $('chk_perfil_' + tipo_operador + '_editar').checked ? parseInt($('chk_perfil_' + tipo_operador + '_editar').value) : 0

                perfil_permisos[tipo_operador] = valor
                valor = 0
            })

            win.options.userData.perfil_permisos = perfil_permisos
            win.close()
        }
    </script>
</head>
<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden; background-color: white;">
   
    <table class="tb1" id="tbContent">
        <tr class="tbLabel">
            <td colspan="2">&nbsp;¿Desea asignar algún permiso a su/sus perfil/es asociado/s?</td>
        </tr>
        <tr>
            <td colspan="2">
                <div id="divPerfiles"></div>
            </td>
        </tr>
        <tr>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td><div id="divCancelar"></div></td>
            <td><div id="divAceptar"></div></td>
        </tr>
    </table>

</body>
</html>