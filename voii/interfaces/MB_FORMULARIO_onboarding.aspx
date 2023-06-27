<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOIInterfaces" %>

<%

    '--------------------------------------------------------------------------
    ' Alta de Onbording Mobile Banking
    '--------------------------------------------------------------------------

    Dim id_transferencia As Integer = nvUtiles.obtenerValor("id_transferencia", 10001243, nvConvertUtiles.DataTypes.int)

    Dim xml_param As Object = nvUtiles.obtenerValor({"xml_param", "params"}, "")
    Dim xml_det_opcional As String = nvUtiles.obtenerValor("xml_det_opcional", "")
    Dim timeout As Integer = 60 '2 segundos
    Dim ini As Date = microsoft.visualbasic.dateandtime.Now

    Dim img_frente_bin() As Byte = Nothing
    Dim img_dorso_bin() As Byte = Nothing
    Dim img_selfie_bin() As Byte = Nothing

    Dim er As New tError()
    Try

        Dim oXML As New System.Xml.XmlDocument
        Try
            oXML.LoadXml(xml_param)

        Catch ex As Exception

        End Try

        Try
            If oXML.InnerText = "" Then

                Dim xml As String = "<parametros>"
                For Each item In xml_param

                    Select Case item.key.ToString

                        Case "img_dni_frente"
						try

                            img_frente_bin = Convert.FromBase64String(item.value)
							  Catch ex As Exception

        End Try
                        Case "img_dni_dorso"
						try
                            img_dorso_bin = Convert.FromBase64String(item.value)
							  Catch ex As Exception

        End Try
                        Case "img_selfie"
						try
                            img_selfie_bin = Convert.FromBase64String(item.value)
							  Catch ex As Exception

        End Try
                        Case Else
                            xml += "<" & item.key & ">" & item.value & "</" & item.key & ">"
                    End Select

                Next
                xml += "</parametros>"

                xml_param = Nothing
                xml_param = xml

            End If

        Catch ex As Exception

        End Try



        Dim Transf As New nvFW.nvTransferencia.tTransfererncia
        er = Transf.cargar(id_transferencia, xml_param, xml_det_opcional)

        If er.numError <> 0 Then
            Transf.error_limpiar_archivos()
            GoTo salir
        End If

        Transf.id_transf_log = Transf.new_id_transf_log()

        Dim async_thread As System.Threading.Thread = New System.Threading.Thread(Sub(psp As Object)

                                                                                      nvFW.nvApp._nvApp_ThreadStatic = psp("nvApp")

                                                                                      Dim archivo As Dictionary(Of String, Object)

																					  if not(img_frente_bin is nothing) then
                                                                                      archivo = New Dictionary(Of String, Object)
                                                                                      archivo.Add("existe", True)
                                                                                      archivo.Add("filename", "img_dni_frente.png")
                                                                                      archivo.Add("extension", ".png")
                                                                                      archivo.Add("size", img_frente_bin.Length)
                                                                                      archivo.Add("path", nvTransferencia.nvTransfUtiles.getFileTmpPath(archivo("filename"), serial:=psp("Transf").serial))
                                                                                      archivo.Add("binary", img_frente_bin)
                                                                                      psp("Transf").Archivos.Add("img_dni_frente", archivo)
																					  end if

																					  if not(img_dorso_bin is nothing) then
                                                                                      archivo = New Dictionary(Of String, Object)
                                                                                      archivo.Add("existe", True)
                                                                                      archivo.Add("filename", "img_dni_dorso.png")
                                                                                      archivo.Add("extension", ".png")
                                                                                      archivo.Add("size", img_dorso_bin.Length)
                                                                                      archivo.Add("path", nvTransferencia.nvTransfUtiles.getFileTmpPath(archivo("filename"), serial:=psp("Transf").serial))
                                                                                      archivo.Add("binary", img_dorso_bin)
                                                                                      psp("Transf").Archivos.Add("img_dni_dorso", archivo)
																					  end if

																					  if not(img_selfie_bin is nothing) then
                                                                                      archivo = New Dictionary(Of String, Object)
                                                                                      archivo.Add("existe", True)
                                                                                      archivo.Add("filename", "img_selfie.png")
                                                                                      archivo.Add("extension", ".png")
                                                                                      archivo.Add("size", img_selfie_bin.Length)
                                                                                      archivo.Add("binary", img_selfie_bin)
                                                                                      archivo.Add("path", nvTransferencia.nvTransfUtiles.getFileTmpPath(archivo("filename"), serial:=psp("Transf").serial))
                                                                                      psp("Transf").Archivos.Add("img_selfie", archivo)
																					  end if

                                                                                      psp("Transf").ejecutar()
                                                                                      psp("nro_sol") = psp("Transf").param("nro_sol")("valor")

                                                                                      Dim error_count As Integer = 0
                                                                                      For Each cola_det In psp("Transf").dets_run
                                                                                          Dim det As nvFW.nvTransferencia.tTransfDet = cola_det.det
                                                                                          If det.det_error.numError <> 0 Then error_count += 1
                                                                                      Next

                                                                                      psp("error_count") = error_count
                                                                                      If psp("nro_sol") Is Nothing Then psp("nro_sol") = -1


                                                                                  End Sub)

        Dim ps As New Dictionary(Of String, Object)
        ps.Add("Transf", Transf)
        ps.Add("nvApp", nvApp)
        ps.Add("nro_sol", 0)
        ps.Add("error_count", 0)
        async_thread.Start(ps)

        While ps("Transf").param("nro_sol")("valor") = 0 And microsoft.visualbasic.dateandtime.Now < microsoft.visualbasic.dateandtime.DateAdd(DateInterval.Second, timeout, ini)
            System.Threading.Thread.CurrentThread.Sleep(500)
        End While

        ps("nro_sol") = ps("Transf").param("nro_sol")("valor")

        If ps("nro_sol") = 0 Then

            er.numError = -99
            er.mensaje = "Error por timeout"
            er.debug_desc = ""
            er.debug_src = ""
            er.params("user_message") = "Su solicitud no pudo ser ingresada. Intente mas tarde."
            GoTo salir

        End If

        If ps("nro_sol") = -1 Or ps("error_count") > 0 Then

            er.numError = -99
            er.mensaje = "Error al ingresar la solicitud"
            er.debug_desc = ""
            er.debug_src = ""
            er.params("user_message") = "Su solicitud no pudo ser ingresada. Intente mas tarde."
            GoTo salir
        End If

        er.params("nro_sol") = ps("nro_sol")
        er.params("user_message") = "Su solicitud ha sido ingresada correctamente"

    Catch ex As Exception
        er.numError = -99
        er.mensaje = "Excepcion no controlada. Msg:" & ex.Message.ToString
        er.debug_desc = ""
        er.debug_src = "interfaces:: MB onboarding"
    End Try

salir:
    er.response()

%>