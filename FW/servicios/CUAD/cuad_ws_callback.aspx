<%@ Page Language="VB" AutoEventWireup="false" EnableSessionState="False" %>
<%
    Dim respuestaCuad As String = nvUtiles.obtenerValor({"resultado", "Resultado"}, "")
    Dim id As String = nvUtiles.obtenerValor("id", "") ' ID suministrado en URL callback
    Dim op As String = nvUtiles.obtenerValor("op", "") ' Que servicio está respondiendo (suministrado en URL callback) => wsgetcupo || wsaltaconsumodirecto
    Dim err As New tError()

    ' Quitar la cabecera XML si está
    If respuestaCuad.IndexOf("<?xml") <> -1 Then
        Dim xml As New System.Xml.XmlDocument
        xml.LoadXml(respuestaCuad)
        respuestaCuad = xml.OuterXml.Replace(xml.FirstChild.OuterXml, "")
        xml = Nothing
    End If

    err.params("id") = id
    err.params("responseRobot") = respuestaCuad

    If op <> String.Empty Then

        Select Case op.ToLower()
            '------------------------------------------------------------------
            '
            '                           Obtener Cupo
            '
            '------------------------------------------------------------------
            Case "wsgetcupo"
                ' Checkear que exista el diccionario "cuadcupocallback"
                If Application.Contents("cuadcupocallback") Is Nothing Then
                    Application.Contents("cuadcupocallback") = New Dictionary(Of String, Boolean)
                End If

                ' Agregar el valor (id) al diccionario con valor de False para no tener que verificar su existencia
                Application.Contents("cuadcupocallback")(id) = False

                If Not respuestaCuad Is Nothing AndAlso respuestaCuad <> String.Empty Then
                    Application.Contents("cuadcupocallback")(id) = True

                    If Application.Contents("cuadcupocallback_responses") Is Nothing Then
                        Application.Contents("cuadcupocallback_responses") = New Dictionary(Of String, String)
                    End If

                    Application.Contents("cuadcupocallback_responses")(id) = respuestaCuad
                Else
                    err.numError = 1
                    err.titulo = "Error respuesta CUAD"
                    err.mensaje = "No se recibió una respuesta válida desde el CUAD"
                End If


            '------------------------------------------------------------------
            '
            '                   Alta de Consumo Directo
            '
            '------------------------------------------------------------------
            Case "wsaltaconsumodirecto"
                ' Checkear que exista el diccionario "cuadcupocallback"
                If Application.Contents("cuadconsumocallback") Is Nothing Then
                    Application.Contents("cuadconsumocallback") = New Dictionary(Of String, Boolean)
                End If

                ' Agregar el valor (id) al diccionario con valor de False para no tener que verificar su existencia
                Application.Contents("cuadconsumocallback")(id) = False

                If Not respuestaCuad Is Nothing AndAlso respuestaCuad <> String.Empty Then
                    Application.Contents("cuadconsumocallback")(id) = True

                    If Application.Contents("cuadconsumocallback_responses") Is Nothing Then
                        Application.Contents("cuadconsumocallback_responses") = New Dictionary(Of String, String)
                    End If

                    Application.Contents("cuadconsumocallback_responses")(id) = respuestaCuad
                Else
                    err.numError = 1
                    err.titulo = "Error respuesta CUAD"
                    err.mensaje = "No se recibió una respuesta válida desde el CUAD"
                End If

        End Select
    End If

    err.response()
%>