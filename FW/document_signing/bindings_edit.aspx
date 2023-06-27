<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%

  
    Dim accion As String = nvUtiles.obtenerValor("accion", "")
    If accion.ToLower = "delete_binding" Then
        
        Dim err As New tError
        Dim cod_binding As String = nvUtiles.obtenerValor("cod_binding", "")
        Try
            
            ' obtener idcert, e id_carpeta de los certificados vinculados a un dispositivo movil de usuario
            Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset("SELECT A.idcert, B.id_carpeta FROM notification_bindings_signing_certificates A " &
                                                                   " INNER JOIN verPKI_certificados_carpetas B on B.idcert = A.idcert and B.carpeta_path='entidades' WHERE cod_binding=" & cod_binding)
            Dim certs As New List(Of String)
            Dim carpetas As New List(Of String)
            While Not rs.EOF
                certs.Add(rs.Fields("idcert").Value)
                carpetas.Add(rs.Fields("id_carpeta").Value)
                rs.MoveNext()
            End While
            DBCloseRecordset(rs)
            
            ' Eliminar vinculacion de dispositivo
            Dim strSQL As String = ""
            strSQL += "SET XACT_ABORT ON;"
            strSQL += "BEGIN TRAN;"
            strSQL += "DECLARE @cod_device_operador INT = -1;"
            strSQL += "SELECT @cod_device_operador=cod_device_operador FROM notification_binding WHERE cod_binding=" & cod_binding & ";"
            strSQL += "DELETE FROM notification_bindings_signing_certificates WHERE cod_binding = " & cod_binding & ";"
            strSQL += "DELETE FROM notification_binding WHERE cod_binding=" & cod_binding & ";"
            strSQL += "IF NOT EXISTS(SELECT cod_binding FROM notification_binding WHERE cod_device_operador=@cod_device_operador)" & vbLf
            strSQL += "DELETE FROM device_operador WHERE cod_device_operador=@cod_device_operador;"
            strSQL += "COMMIT TRAN;"
            DBExecute(strSQL)
            
            ' borrar binario de los certificados (siempre y cuando no esten asociados adicionalmente a la entidad mediante la tabla entidad_certificados)
            For i As Integer = 0 To certs.Count - 1
                rs = nvDBUtiles.DBOpenRecordset("SELECT * FROM entidad_certificados WHERE idcert=" & certs(i))
                If rs.EOF Then
                    nvFW.nvPKIDBUtil.dbDeleteCert(certs(i), carpetas(i))
                End If
                nvDBUtiles.DBCloseRecordset(rs)
            Next
            
        Catch e As Exception
            err.parse_error_script(e)
        End Try
        
        err.response()
    Else
        Me.contents("filtroMobileDevices") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='verOperadores_mobile_devices'><campos>*</campos><filtro><operador type='igual'>" & nvApp.operador.operador & "</operador></filtro><orden>[cod_binding]</orden></select></criterio>")
    End If
    
 %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <title>Administrar dipositivos vinculados</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/tCampo_head.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript" src="/fw/script/tcampo_def.js"></script>
    <% = Me.getHeadInit()%>
    <script type="text/javascript">

        var vMenu
        function window_onload() {



            vMenu = new tMenu('divMenu', 'vMenu');
            Menus["vMenu"] = vMenu
            Menus["vMenu"].alineacion = 'centro';
            Menus["vMenu"].estilo = 'A';

            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='0' style='WIDTH: 70%'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>Dispositivos/aplicaciones de firma</Desc></MenuItem>")
            Menus["vMenu"].CargarMenuItemXML("<MenuItem id='1' style='WIDTH: 30%'><Lib TipoLib='offLine'>DocMNG</Lib><icono>agregar</icono><Desc>Agregar vínculo</Desc><Acciones><Ejecutar Tipo='script'><Codigo>nuevaVinculacion()</Codigo></Ejecutar></Acciones></MenuItem>")


            Menus["vMenu"].loadImage("guardar", "/FW/image/icons/guardar.png")
            Menus["vMenu"].loadImage("eliminar", "/FW/image/icons/eliminar.png")
            Menus["vMenu"].loadImage("agregar", "/FW/image/icons/agregar.png")
            vMenu.MostrarMenu()



            loadBindings();
           
        }

        function window_onresize() {

        }


        function loadBindings() {

            if (nvFW.getMyWindow() != null) {
                nvFW.getMyWindow().options.userData.retorno["success"] = true
            }

            var rs = new tRS()
            rs.async = true
            rs.onComplete = function () {

                var strHTML = "<table id='bindingsTable' class='tb1'><tr class='tbLabel'><td>Default</td><td>id</td><td>Dispositivo</td><td>Aplicación</td><td>Eliminar</td></tr>"
                while (!rs.eof()) {

                    if (rs.getdata("default_config") == "True") {
                        defaultBinding = rs.getdata("cod_binding")
                    }

                    strHTML += "<tr>"
                    strHTML += "<td><input type='radio' onclick='setDefaultBinding(" + rs.getdata("cod_binding") + ")' name='default_device' id='" + rs.getdata("cod_binding") + "' " + (rs.getdata("default_config") == 'True' ? "checked='checked'" : "") + " /></td>"
                    strHTML += "<td>" + rs.getdata("cod_binding") + "</td>"
                    strHTML += "<td>" + rs.getdata("device_name") + "</td>"
                    strHTML += "<td>" + rs.getdata("app_name") + "</td>"
                    //strHTML += "<td><input id='input_" + rs.getdata("cod_binding") + "' type='text' value='" + rs.getdata("device_operador_desc") + "'/></td>"
                    strHTML += "<td><img src='/fw/image/icons/eliminar.png' style='cursor:pointer' title='eliminar'/ onclick='confirmEliminarVinculo(" + rs.getdata("cod_binding") + ")'></td>"
                    strHTML += "</tr>"
                    rs.movenext()
                }
                strHTML += "</table>"

                $('divMain').innerHTML = strHTML;
            }
            rs.open(nvFW.pageContents.filtroMobileDevices)
        }

        var defaultBinding
        function confirmEliminarVinculo(cod_binding) {
            
            // se necesita permisos para eliminar device
//            if (!tienePermisoEliminarDevice(operador)) {
//                return
//            }

            // solo se puede borrar la vinculacion por defecto si es la unica vinculacion existente
            if (cod_binding == defaultBinding) {
                if ($("bindingsTable").rows.length != 2) { 
                    alert("No se puede eliminar la vinculación por defecto. Cámbiela y luego podrá eliminar esta entrada")
                    return
                }
            }


            Dialog.confirm('<b>"Esta seguro que desea desvincular el  dispositivo/aplicación?"</br>'
                    , { width: 280, className: "alphacube",
                        onShow: function () {
                        },
                        onOk: function (win) {
                            eliminarVinculo(cod_binding);
                            win.close();
                        },
                        onCancel: function (win) { win.close() },
                        okLabel: 'Confirmar',
                        cancelLabel: 'Cancelar'
                    });
        }


        function eliminarVinculo(cod_binding) {
            nvFW.error_ajax_request('/fw/document_signing/bindings_edit.aspx', {
                parameters: {
                    accion: "delete_binding",
                    cod_binding: cod_binding
                },
                onSuccess: function (error, transport) {
                    if (error.numError == 0) {
                        loadBindings()
                    }
                }
            });
        }

        function nuevaVinculacion() {
            var win = window.top.nvFW.createWindow({
                title: 'Vincular Dispositivo',
                url: '/fw/document_signing/qr_binding_scan.aspx?',
                width: 600,
                height: 560,
                onClose: function (err) {
                    var success = win.options.userData.retorno["success"];
                    if (success) {
                        loadBindings()
                    }
                }
            })
            win.options.userData = { retorno: {} }
            win.showCenter(true)

        }

        function setDefaultBinding(cod_binding) {
            nvFW.confirm('<b>Desea establecer esta vinculación como opción por defecto?</br>'
                                    , { onShow: function () {
                                    },
                                        onOk: function (win) {
                                            updateDefaultBinding(cod_binding)
                                            win.close();
                                        },
                                        onCancel: function (win) { win.close() },
                                        okLabel: 'Confirmar',
                                        cancelLabel: 'Cancelar'
                                    });
        }


        function updateDefaultBinding(cod_binding) {
            nvFW.error_ajax_request('qr_binding_scan.aspx', {
                asynchronous: false,
                bloq_contenedor_on: false,
                parameters: { accion: "update_default_config", cod_binding: cod_binding },
                onSuccess: function (err) {
                    defaultBinding = cod_binding
                    if (nvFW.getMyWindow() != null) {
                        nvFW.getMyWindow().options.userData.retorno["success"] = true
                    }
                },
                onFailure: function (err) {
                }
            })
        }




    </script>
</head>
<body onload="return window_onload()" onresize="window_onresize()" style="width: 100%;
    height: 100%; overflow: hidden">
    
    <div id='divMenu'></div>

    <div id='divMain'>
    
    </div>
</body>
</html>
