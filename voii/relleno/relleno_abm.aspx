<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>


<%

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim id_relleno As Integer = nvFW.nvUtiles.obtenerValor("id_relleno", 0)
    Dim concepto As String = nvFW.nvUtiles.obtenerValor("concepto", "")
    Dim codigo As Integer = nvFW.nvUtiles.obtenerValor("codigo", 0)
    Dim descripcion As String = nvFW.nvUtiles.obtenerValor("descripcion", "")
    Dim sintetico As String = nvFW.nvUtiles.obtenerValor("sintetico", "")
    Dim estado As Integer = nvFW.nvUtiles.obtenerValor("estado", 0)
    Dim equiv As String = nvFW.nvUtiles.obtenerValor("equiv", "")



    If modo.ToUpper() <> "" Then

        Dim err As New tError()
        Dim strSQL = ""

        Stop


        Try
            Select Case modo


                Case "A"



                    Dim rs As ADODB.Recordset = nvDBUtiles.DBExecute(strSQL:="SELECT * FROM trnv_relleno WHERE id_relleno= " & id_relleno & "", autoclose_connection:=True, CommandTimeout:=0)
                    If Not rs.EOF Then
                        err.mensaje = "El ID ya se encuentra registrado."
                        err.numError = -3
                    End If

                    If err.numError = 0 Then
                        strSQL = "INSERT INTO trnv_relleno (concepto, codigo, descripcion, sintetico, estado, equiv) VALUES ('" & concepto & "', " & codigo & ", '" & descripcion & "', '" & sintetico & "'," & estado & ", " & equiv & ")"
                        nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="BD_IBS_ANEXA")
                    End If

                    nvFW.nvDBUtiles.DBCloseRecordset(rs)

                Case "M"

                    strSQL = "UPDATE trnv_relleno SET concepto = '" & concepto & "', codigo= " & codigo & ", descripcion= '" & descripcion & "', sintetico='" & sintetico & "' , estado=" & estado & ", equiv= '" & equiv & "' WHERE id_relleno = " & id_relleno
                    nvFW.nvDBUtiles.DBExecute(strSQL, cod_cn:="BD_IBS_ANEXA")

            End Select

        Catch ex As Exception

            err.parse_error_script(ex)
            err.numError = -2
            err.mensaje = "Algo salio mal" & strSQL
            err.debug_desc &= strSQL

        End Try

        err.response()

    End If

    Me.contents("filtro_RELLENO") = nvXMLSQL.encXMLSQL("<criterio><select vista='trnv_relleno' cn='BD_IBS_ANEXA'><campos>concepto, id_relleno</campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroID") = nvXMLSQL.encXMLSQL("<criterio><select vista='trnv_relleno' cn='BD_IBS_ANEXA'><campos>id_relleno as [ID] </campos><orden></orden><filtro></filtro></select></criterio>")
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>

    <title>Usuario</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" src="/FW/script/utiles.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/tTable.js"></script>

    <% = Me.getHeadInit() %>

    <script type="text/javascript">

        var win = nvFW.getMyWindow()
        var id_relleno = ''
        var concepto = ''
        var codigo = ''
        var descripcion = ''
        var sintetico = ''
        var estado = ''
        var equiv = ''

        var modo = win.options.userData.modo;


        function window_onresize() {

        }


        function window_onload() {
            

            if (modo == 'M') {
                
                id_relleno = win.options.userData.id_relleno;
                concepto = win.options.userData.concepto;
                codigo = win.options.userData.codigo;
                descripcion = win.options.userData.descripcion;
                sintetico = win.options.userData.sintetico;
                estado = win.options.userData.estado;
                
                if (win.options.userData.equiv = 'undefined') {
                    equiv = ""
                }

                campos_defs.set_value('id_relleno', id_relleno)
                campos_defs.set_value('concepto', concepto)
                campos_defs.set_value('codigo', codigo)
                campos_defs.set_value('descripcion', descripcion)
                campos_defs.set_value('sintetico', sintetico)
                campos_defs.set_value('estado', estado)
                campos_defs.set_value('equiv', equiv)
                
            }
            
            campos_defs.habilitar('id_relleno', false)

        }


        function guardar() {            
            
            id_relleno = campos_defs.get_value('id_relleno')
            codigo = campos_defs.get_value('codigo')
            concepto = campos_defs.get_value('concepto')
            descripcion = campos_defs.get_value('descripcion')
            sintetico = campos_defs.get_value('sintetico')
            estado = campos_defs.get_value('estado')
            equiv = campos_defs.get_value('equiv')

            if (modo != 'M') {
                modo = 'A'
            }


            if (codigo == "" || concepto == "" || descripcion == "" || sintetico == ""|| estado == "" ) {

                alert('Hay campos obligatorios sin completar.')
                return

            } else {

                nvFW.error_ajax_request('relleno_abm.aspx', {

                    parameters: {
                        modo: modo,
                        id_relleno: id_relleno,
                        codigo: codigo,
                        concepto: concepto,
                        descripcion: descripcion,
                        sintetico: sintetico,
                        estado: estado,
                        equiv: equiv
                    },

                    onSuccess: function (err) {
                        if (err.numError == 0) {
                            //campos_defs.clear()

                            win.options.userData.hay_modificacion = true
                            win.close()
                        }
                        else
                            alert(err.mensaje)
                    },

                    onFailure: function (err) {
                        alert(err.mensaje)
                        console.log(err.debug_desc)
                    }
                });
            }

        }


        function salir(){
            nvFW.confirm("<br/>¿Desea cancelar la acción?",
                {
                    
                    okLabel: "Aceptar",
                    cancelLabel: "Cancelar",
                    onOk: function () {
                        win.close();
                        parent.buscar_onclick();
                    },
                    onCancel: function () {
                        win.close();
                    }
                });
        }

    </script>


</head>

<body onload="window_onload()" onresize="window_onresize()" style="width: 100%; height: 100%; overflow: hidden;">

    <div id="tGuardar">
        <div id="menuLista" style="width: 100%"></div>
        <script type="text/javascript">

</script>
    </div>
    <div id="menu">
        <table class="tb1">
            <tr>
                <td class="Tit1" style="width: 30%;">ID:</td>

                <td style="width: 70%;">
                    <script type="text/javascript">
                        campos_defs.add('id_relleno', {
                            nro_campo_tipo: 100,
                            enDB: false,
                            filtroWhere: '<id_relleno type="igual">%campo_value%</id_relleno>'
                        })

                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 30%;">(*)Código:</td>

                <td style="width: 70%;">
                    <script type="text/javascript">
                        campos_defs.add('codigo', {
                            nro_campo_tipo: 100,
                            enDB: false
                        })

                    </script>
                </td>
            </tr>

            <tr>
                <td class="Tit1" style="width: 30%;">(*)Concepto:</td>

                <td style="width: 70%;">
                    <script type="text/javascript">
                        campos_defs.add('concepto', {
                            nro_campo_tipo: 104,
                            enDB: false
                        })

                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 30%;">(*)Descripción:</td>

                <td style="width: 70%;">
                    <script type="text/javascript">
                        campos_defs.add('descripcion', {
                            nro_campo_tipo: 104,
                            enDB: false
                        })

                    </script>
                </td>

            </tr>
            <tr>
                <td class="Tit1" style="width: 30%;">(*)Sintético:</td>
                <td style="width: 70%; text-align: right">
                    <script type="text/javascript">
                        campos_defs.add('sintetico', {
                            nro_campo_tipo: 104,
                            enDB: false
                        });
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 30%;">(*)Estado:</td>
                <td style="width: 70%; text-align: right">
                    <script type="text/javascript">
                        campos_defs.add('estado', {
                            nro_campo_tipo: 1,
                            enDB: false
                        });

                        var rs = new tRS();
                        rs.xml_format = "rsxml_json";
                        rs.addField("id", "int")
                        rs.addField("campo", "string")
                        rs.addRecord({ id: "0", campo: "Habilitado" });
                        rs.addRecord({ id: "1", campo: "No habilitado" });
                        campos_defs.items['estado'].rs = rs;
                    </script>
                </td>
            </tr>
            <tr>
                <td class="Tit1" style="width: 30%;">Equivalente:</td>
                <td style="width: 70%;">
                    <script type="text/javascript">
                        campos_defs.add('equiv', {
                            nro_campo_tipo: 100,
                            enDB: false
                        })
                    </script>
                </td>
            </tr>

            <tr>
                <td style="width: 2%;"></td>
            </tr>

            <tr>
        </table>

    </div>
    <div id="botones">
        <table class="tb1">
            <tr>
                <td style="width: 50%;">
                    <input type="button" value="Guardar" onclick="guardar()" style="width: 100%; text-align: center; cursor: pointer;" />
                </td>
                <td style="width: 50%;">
                    <input type="button" value="Salir" onclick="salir()" style="width: 100%; background-repeat: no-repeat; background-position: 2px 3px; cursor: pointer;" />
                </td>
            </tr>

        </table>

    </div>
</body>
</html>
