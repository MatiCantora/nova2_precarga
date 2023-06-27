<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%  

    Dim modo As String = nvFW.nvUtiles.obtenerValor("modo", "")
    Dim accion As String = nvFW.nvUtiles.obtenerValor("accion", "")
    Dim err = New nvFW.tError


    If (modo = "ajax_call") Then

        If (accion = "guardar" Or accion = "eliminar") Then
            Dim nro_com_grupo As String = nvFW.nvUtiles.obtenerValor("nro_com_grupo", "")
            Dim nro_com_tipo As String = nvFW.nvUtiles.obtenerValor("nro_com_tipo", "")
            Dim prioridad As String = nvFW.nvUtiles.obtenerValor("nro_prioridad", "")

            Dim cmd As New nvFW.nvDBUtiles.tnvDBCommand("sp_nv_tipos_grupos_abm", ADODB.CommandTypeEnum.adCmdStoredProc)

            Dim pnro_com_grupo As ADODB.Parameter
            pnro_com_grupo = cmd.CreateParameter("@nro_com_grupo", ADODB.DataTypeEnum.adVarChar,
                                  ADODB.ParameterDirectionEnum.adParamInput, nro_com_grupo.Length, nro_com_grupo)
            cmd.Parameters.Append(pnro_com_grupo)

            Dim pnro_com_tipo As ADODB.Parameter
            pnro_com_tipo = cmd.CreateParameter("@nro_com_tipo", ADODB.DataTypeEnum.adVarChar,
                          ADODB.ParameterDirectionEnum.adParamInput, nro_com_tipo.Length, nro_com_tipo)
            cmd.Parameters.Append(pnro_com_tipo)

            Dim pprioridad As ADODB.Parameter
            pprioridad = cmd.CreateParameter("@prioridad", ADODB.DataTypeEnum.adVarChar,
                          ADODB.ParameterDirectionEnum.adParamInput, prioridad.Length, prioridad)
            cmd.Parameters.Append(pprioridad)

            Dim pAccion As ADODB.Parameter
            pAccion = cmd.CreateParameter("@accion", ADODB.DataTypeEnum.adVarChar,
                  ADODB.ParameterDirectionEnum.adParamInput, accion.Length, accion)
            cmd.Parameters.Append(pAccion)


            Dim rs As ADODB.Recordset = cmd.Execute()
            Dim numError As Integer = rs.Fields.Item("numError").Value

            If numError <> 0 Then
                err.numError = rs.Fields("numError").Value
                err.mensaje = rs.Fields("mensaje").Value
                err.titulo = rs.Fields("titulo").Value
                err.debug_desc = rs.Fields("debug_desc").Value
                err.debug_src = rs.Fields("debug_src").Value

            End If

            nvFW.nvDBUtiles.DBCloseRecordset(rs)

            err.response()
        End If
    End If



    Me.contents("filtroGrupo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_grupos'><campos>nro_com_grupo as id, com_grupo as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")
    Me.contents("filtroTipo") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='com_tipos'><campos>nro_com_tipo as id, com_tipo as [campo] </campos><orden></orden><filtro></filtro></select></criterio>")

    Dim campo_def = nvFW.nvUtiles.obtenerValor("campo_def", "")

%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Nueva Relacion</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />

    <script type="text/javascript" language="javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript" language="javascript" src="/FW/script/nvFW_basicControls.js"></script>
    <% = Me.getHeadInit()%>

    <script type="text/javascript">
        
        var win = nvFW.getMyWindow()
        var modo = '';
        var grupo = '';
        var tipo = '';
        var prioridad = '';
      
        


        function window_onload() {

            if (typeof win.options.user_data != 'undefined') {
                grupo = win.options.user_data.nro_com_grupo;
                tipo = win.options.user_data.nro_com_tipo;
                prioridad = win.options.user_data.com_prioridad;
                
            }

            campos_defs.set_value('rgrupo', grupo)
            campos_defs.set_value('rtipo', tipo)
            campos_defs.set_value('rprioridad', prioridad)

            

           
        }

        function guardar() {
            
            grupo = campos_defs.get_value('rgrupo')
            tipo = campos_defs.get_value('rtipo')
            prioridad = campos_defs.get_value('rprioridad')


            if (grupo == "") {
                alert('No se selecciono un grupo')
                return
            } else {

                nvFW.error_ajax_request('com_tipo_grupo_abm.aspx', {

                    parameters: {
                        modo: "ajax_call",
                        accion: "guardar",
                        nro_com_grupo: grupo,
                        nro_com_tipo: tipo,
                        nro_prioridad: prioridad
                    },
                    
                    //onSuccess: function (err,transport) {
                        //win.close()
                    //},

                    onFailure: function (err) {
                        console.log(err.debug_desc)
                        alert("Debe establecer grupo, tipo y prioridad antes de guardar la relacion.")
                    }
                });

            }

        }

        function eliminarTipoGrupo(nro_com_grupo, nro_com_tipo, nro_prioridad, com_grupo, com_tipo) {

            Dialog.confirm("¿Esta seguro que desea eliminar la relacion " + com_grupo + '/' + com_tipo + "?", {

                width: 450,
                okLabel: 'Confirmar',
                cancelLabel: 'Cancelar',
                className: "alphacube",
                onOk: function (win) {

                    nvFW.error_ajax_request("com_tipo_grupo_abm.aspx", {
                        parameters: {
                            modo: "ajax_call",
                            accion: "eliminar",
                            nro_com_grupo: nro_com_grupo,
                            nro_com_tipo: nro_com_tipo,
                            nro_prioridad: nro_prioridad
                        },

                        onSuccess: function (err) {
                            win.close()
                            buscar_onclick()
                        },

                        onFailure: function (err) {
                            console.log(err.debug_desc)
                            win.close()
                        }
                    });
                }
            });
        }

        function btnCancelar() {
            win.close()
        }
        
    </script>

</head>
<body style="overflow-y: hidden;" onload="window_onload()">
    <div id="tNuevo">
        <div id="menuLista" style="width: 100%"></div>
            <script type="text/javascript">
                var vMenu = new tMenu('menuLista', 'vMenu');
                vMenu.alineacion = 'centro'
                vMenu.estilo = 'A'

                vMenu.loadImage('eliminar', '/FW/image/icons/eliminar.png')

                vMenu.CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 100%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc></Desc></MenuItem>")
                vMenu.CargarMenuItemXML("<MenuItem id='1'><Lib TipoLib='offLine'>DocMNG</Lib><icono>eliminar</icono><Desc>Eliminar</Desc><Acciones><Ejecutar Tipo='script'><Codigo>eliminarTipoGrupo()</Codigo></Ejecutar></Acciones></MenuItem>")

                vMenu.MostrarMenu();
            </script>
    </div>
    <div>
    <table class="tb1">
        <tr style="width: 100%; display:inline-table">
            <td class="Tit1" style="width: 14%">Grupo:</td>
            <td style="width: 85%">
                <script type="text/javascript">
                    campos_defs.add('rgrupo', {
                        nro_campo_tipo: 1,
                        enDB: false,
                        filtroXML: nvFW.pageContents.filtroGrupo,
                        filtroWhere: "<nro_com_tipo type='igual'>%campo_value%</nro_com_tipo>",
                        mostrar_codigo: false
                    });
                </script>
            </td>
            <td style="width: 1%; visibility: hidden;">1</td>
        </tr>
        <tr style="width: 100%; display:inline-table">
            <td class="Tit1" style="width: 14%">Tipo:</td>
            <td style="width: 85%">
                  <script type="text/javascript">
                      campos_defs.add('rtipo', {
                          nro_campo_tipo: 1,
                          enDB: false,
                          filtroXML: nvFW.pageContents.filtroTipo,
                          filtroWhere: "<nro_com_tipo type='igual'>%campo_value%</nro_com_tipo>",
                          mostrar_codigo: false
                      });
                  </script>
            </td>
            <td style="width: 1%; visibility: hidden;">1</td>
        </tr>      
        <tr style="width: 100%; display:inline-table">
            <td class="Tit1" style="width: 10%;">Prioridad:</td>
            <td style="width: 40%">
                <script type="text/javascript">
                    campos_defs.add('rprioridad', {
                        nro_campo_tipo: 100,
                        enDB: false,
                        mask: {
                            mask: '000'        
                        }
                    });
                </script>
            </td>
            <td style="width: 50%; visibility: hidden;">1</td>
        </tr>
    </table>

    <table class="tb1" style="padding: 75px 0px 5px 0px;">
        <tr>
            <td style="width: 20%;"></td>
            <td style="width: 20%;"><input type="button" name="guardar" value="Guardar" onclick="guardar()" style="width: 100%"/></td>
            <td style="width: 20%;"></td>
            <td style="width: 20%;"><input type="button" name="salir" value="Salir" onclick="btnCancelar()" style="width: 100%"/></td> 
            <td style="width: 20%;"></td>
        </tr>
    </table>
  
</div>
</body>
</html>