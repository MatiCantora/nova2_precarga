<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageVOII" %>

<%


    Dim paiscod As Integer = obtenerValor("paiscod", 54)
    Dim bcocod As Integer = obtenerValor("bcocod", 312)
    Dim succod As Integer = obtenerValor("succod", 1)

    '***************************************************************************
    'Validar Cierre
    'Durante el cierre no puede ejecutar las APIs
    'Consultar el estado del sistema 7 - Clientes
    '***************************************************************************
    Dim tSistemaEstado As trsParam = IBS.IBSUtiles.get_sistemas_estado("", paiscod, bcocod, succod, 7)
    If Not tSistemaEstado("abierto") Or Not tSistemaEstado("procesando") Then
        Dim err As New tError
        err.numError = 1000
        err.titulo = "Error en la ejecución"
        err.mensaje = "Sistema cerrado o procesando el cierre"
        err.debug_src = "clienteParticular_ABM"
        err.response()
    End If

    '*********************Variables de usuario de conexion IBS**************************
    'Pasar a parámetros el usuario de conexión
    '***********************************************************************************

    Dim trsGral As New trsParam

    Dim tipdoc_usr As Integer = 1
    Dim usrident As String = 23519078



    Dim tagentecod As Integer = obtenerValor("tagentecod", 1) 'Banco VOII solo usa el tipo de agente 1

    Dim sistcod As Integer = 7 'Clientes
    Dim fecreal As Date = Now()
    Dim fecestado As Date = fecreal
    Dim observacion As String = "ALTA DESDE NOVA"
    Dim tiporel As String = 7


    Dim entidadcodpar As Integer = 1057
    Dim entidadpasswpar As String = "PSW CENSYS"


    trsGral("tipdoc_usr") = tipdoc_usr
    trsGral("usrident") = usrident
    trsGral("paiscod") = paiscod
    trsGral("bcocod") = bcocod
    trsGral("succod") = succod
    trsGral("tagentecod") = tagentecod
    trsGral("sistcod") = sistcod
    trsGral("fecreal") = fecreal
    trsGral("fecestado") = fecestado
    trsGral("observacion") = observacion
    trsGral("tiporel") = tiporel
    trsGral("entidadcodpar") = entidadcodpar
    trsGral("entidadpasswpar") = entidadpasswpar


    Dim accion As String = obtenerValor("action", "") '(A) Alta, (B) Baja.

    If Not {"A", "M"}.Contains(accion.ToUpper) Then
        Dim err As New tError
        err.numError = 1000
        err.titulo = "Error en la ejecución"
        err.mensaje = "Acción incorrecta."
        err.debug_src = "clienteParticular_ABM"
        err.response()
    End If


    '*************************Variable a cargar*************************/
    'Dim   tipdoc_ej  As Integer = 5
    'Dim   nrodoc_ej  As String = = 20044155649


    Dim tipdoc As Integer = obtenerValor("tipdoc", 0)
    Dim nrodoc As String = obtenerValor("nrodoc", 0)

    Dim trsCliID As New trsParam
    trsCliID("tipdoc") = tipdoc
    trsCliID("nrodoc") = nrodoc

    'Validar datos de identificación de cliente
    If tipdoc = 0 Or nrodoc = 0 Then
        Dim err As New tError
        err.numError = 1000
        err.titulo = "Error en la ejecución"
        err.mensaje = "El tipo y nro de documento son obligatorios"
        err.debug_src = "clienteParticular_ABM"
        err.response()
    End If

    'Dim tipdoc1 As Integer = obtenerValor("tipdoc1", Nothing)
    'Dim nrodoc1 As String = obtenerValor("nrodoc1", Nothing)
    'Dim tipdoc2 As Integer = obtenerValor("tipdoc2", Nothing)
    'Dim nrodoc2 As String = obtenerValor("nrodoc2", Nothing)
    'Dim tipdoc3 As Integer = obtenerValor("tipdoc3", Nothing)
    'Dim nrodoc3 As String = obtenerValor("nrodoc3", Nothing)
    'Dim fecha As Date = Now()


    'Datos de prueba
    'tipdoc = 5
    'nrodoc = 20179172780
    'tipdoc1 = 1
    'nrodoc1 = 17917278

    'tipdoc2 = null
    'nrodoc2 = null

    'tipdoc3 =null
    'nrodoc3 = null

    '/*************************declaracion de  variable*********************/
    '/*************************scl_itcl_Cliente_DatoBasicos*****************/


    'Dim paiscod As Integer = obtenerValor("tipdoc", 0)
    'Dim bcocod As Integer = obtenerValor("tipdoc", 0)
    'Dim tipdoc As Integer
    'Dim nrodoc As String
    'Dim clinum As Integer = obtenerValor("tipdoc", 0)
    'Dim climatcod As String = obtenerValor("tipdoc", 0)
    'Dim clifecalt As Date = obtenerValor("tipdoc", 0)
    'Dim tipocli As Integer = obtenerValor("tipdoc", 0)
    'Dim perconcod As Integer = obtenerValor("tipdoc", 0)
    'Dim clasicod As Integer = obtenerValor("tipdoc", 0)
    'Dim clicondgi As Integer = obtenerValor("tipdoc", 0)
    ''Dim tiporel As Integer = obtenerValor("tipdoc", 0)
    'Dim vip As Integer = obtenerValor("tipdoc", 0)
    'Dim impgancod As Integer = obtenerValor("tipdoc", 0)
    'Dim residencia As Integer = obtenerValor("tipdoc", 0)
    'Dim tipcartcod As Integer = obtenerValor("tipdoc", 0)
    'Dim fecambiosit As Date = obtenerValor("tipdoc", 0)
    'Dim fecccongelsit As Date = obtenerValor("tipdoc", 0)
    'Dim objsocial As String = obtenerValor("tipdoc", 0)
    'Dim cantpersonal As Integer = obtenerValor("tipdoc", 0)
    'Dim totinganual As String = obtenerValor("tipdoc", 0)
    'Dim sectorfin As Integer = obtenerValor("tipdoc", 0)
    'Dim vincbanco As Integer = obtenerValor("tipdoc", 0)
    'Dim invercalif As Integer = obtenerValor("tipdoc", 0)
    'Dim impempre As Integer = obtenerValor("tipdoc", 0)
    'Dim titcod As Integer = obtenerValor("tipdoc", 0)
    'Dim siter As Integer = obtenerValor("tipdoc", 0)
    'Dim numextranj As String = obtenerValor("tipdoc", 0)
    'Dim fecamsitant As Date = obtenerValor("tipdoc", 0)
    'Dim fecongsitant As Date = obtenerValor("tipdoc", 0)
    'Dim tipbalcod As Integer = obtenerValor("tipdoc", 0)
    'Dim situaclicod As Integer = obtenerValor("tipdoc", 0)
    'Dim criteriomonto As Integer = obtenerValor("tipdoc", 0)
    'Dim policaexpuesto As Integer = obtenerValor("tipdoc", 0)
    'Dim clifecmodif As Date = obtenerValor("tipdoc", 0)
    'Dim estfatca As Integer = obtenerValor("tipdoc", 0)
    'Dim giin As String = obtenerValor("tipdoc", 0)
    'Dim perfoper As String = obtenerValor("tipdoc", 0)


    '/************Declaracion Variable *****************************/
    '/************scl_itcl_CliPartDatosBasico**********************/
    'Dim clinom As String
    'Dim cliape As String
    'Dim clifecnac As Date
    'Dim clisexo As String
    ''Dim tipdoc1 As Integer
    ''Dim tipdoc2 As Integer
    ''Dim nrodoc1 As String
    ''Dim nrodoc2 As String
    ''Dim tipdoc3 As Integer
    ''Dim nrodoc3 As String
    'Dim cliestcivcod As Integer
    'Dim profesion As Integer
    'Dim persoc As Integer
    'Dim peract As Integer
    'Dim club As String
    'Dim servmed As String
    'Dim cliviafrec As String
    'Dim cliviafrecint As String
    'Dim clinac As Integer
    'Dim nivedic As Integer
    'Dim vivpropia As String
    'Dim alqgastos As String
    'Dim perscargo As Integer
    'Dim reltrabajo As Integer
    'Dim pais_natal As Integer
    'Dim codprov_natal As Integer
    'Dim dptocod_natal As Integer
    'Dim loccod_natal As Integer
    'Dim emancip As Integer
    'Dim profesional As Integer
    'Dim advertencia As String
    'Dim fecingrecli As Date()
    'Dim fecvtorestran As Date


    '/************Declaracion Variable *****************************/
    '/************scl_itcl_estadocli**********************/

    'Dim succod As Integer
    'Dim fecestado As Date
    'Dim observacion As String

    '--declare   @tiporel  smallint /* ojo misma variable end dos tablas*

    '/************Declaracion Variable *****************************/
    '/************scl_iutcl_historico_gral**********************/

    'Dim id_hist_gral As String
    'Dim fecproceso As Date
    'Dim nombre_campo As String
    'Dim valor_anterior As String
    'Dim valor_nuevo As String
    ''Dim fecreal As Date


    '**********************************************************************************************************************
    'Si es edición se cargan las variables con los datos de la base y luego se editan, si es alta solo se agragan los datos
    '**********************************************************************************************************************
    Dim tipdoc_edita As Integer = 0
    Dim nrodoc_edita As String = 0
    If accion.ToUpper = "M" Then
        tipdoc_edita = tipdoc
        nrodoc_edita = nrodoc
    End If

    Dim strSQL As String = "select clinom,cliape,clifecnac,clisexo,tipdoc1,tipdoc2,nrodoc1,nrodoc2,cliestcivcod,profesion,persoc,peract,club,servmed,cliviafrec,cliviafrecint, " &
                                   "clinac, nivedic, vivpropia, alqgastos, perscargo, reltrabajo, pais_natal, codprov_natal, dptocod_natal, loccod_natal, emancip, profesional," &
                                   "fecingrecli, fecvtorestran, tipdoc3, nrodoc3 from Banksys.dbo.tcl_CliPartDatosBasico where tipdoc = " & tipdoc_edita & " and nrodoc = " & nrodoc_edita

    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL,,,,, "BD_IBS_BANKSYS")

    If rs.EOF And accion.ToLower = "M" Then
        Dim err As New tError
        err.numError = 1000
        err.titulo = "Error en la ejecución de edición"
        err.mensaje = "Cliente no encontrado"
        err.debug_src = "clienteParticular_ABM"
        err.response()
    End If

    Dim rsCliDatosBasicos As New trsParam
    For i = 0 To rs.Fields.Count - 1
        If Not rs.EOF Then
            rsCliDatosBasicos(rs.Fields(i).Name) = obtenerValor(rs.Fields(i).Name, nvUtiles.isNUll(rs.Fields(i).Value, Nothing))
        Else
            rsCliDatosBasicos(rs.Fields(i).Name) = obtenerValor(rs.Fields(i).Name, Nothing)
        End If
    Next

    nvDBUtiles.DBCloseRecordset(rs)

    strSQL = "select clinom, cliape, clifecnac,clisexo,tipdoc1,tipdoc2,nrodoc1,nrodoc2,cliestcivcod,profesion,persoc,peract,club,servmed,cliviafrec,cliviafrecint," &
                    "clinac,nivedic,vivpropia,alqgastos,perscargo,reltrabajo,pais_natal,codprov_natal,dptocod_natal,loccod_natal,emancip,profesional,fecingrecli," &
                    " fecvtorestran,tipdoc3,nrodoc3 from Banksys.dbo.tcl_CliPartDatosBasico where tipdoc = " & tipdoc_edita & " and nrodoc = " & nrodoc_edita

    Dim rsCliPart As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL,,,,, "BD_IBS_BANKSYS")

    If rsCliPart.EOF And accion.ToLower = "M" Then
        Dim err As New tError
        err.numError = 1000
        err.titulo = "Error en la ejecución de edición"
        err.mensaje = "Cliente no encontrado"
        err.debug_src = "clienteParticular_ABM"
        err.response()
    End If

    Dim rsCliPartDatosBasicos As New trsParam
    For i = 0 To rsCliPart.Fields.Count - 1
        If Not rsCliPart.EOF Then
            rsCliPartDatosBasicos(rsCliPart.Fields(i).Name) = obtenerValor(rsCliPart.Fields(i).Name, nvUtiles.isNUll(rsCliPart.Fields(i).Value, Nothing))
        Else
            rsCliPartDatosBasicos(rsCliPart.Fields(i).Name) = obtenerValor(rsCliPart.Fields(i).Name, Nothing)
        End If
    Next




    '/*************************carga de  variable*********************/
    '/*************************scl_iutcl_historico_gral*****************/
    'Select Case Case@fecproceso = fecproceso from tgl_fechaproceso where succod =  And sistcod =7  
    'Select Case Case@nombre_campo = "perfoper"
    'Select Case Case@valor_anterior = " "
    'Select Case Case@valor_nuevo = convert(varchar(30), @perfoper)

    Dim SQLParams As String = ""

    For Each param In trsGral.Keys
        SQLParams = "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(trsGral(param)) & vbCrLf
    Next

    For Each param In trsCliID.Keys
        SQLParams = "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(trsCliID(param)) & vbCrLf
    Next

    For Each param In rsCliDatosBasicos.Keys
        SQLParams = "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(rsCliDatosBasicos(param)) & vbCrLf
    Next

    For Each param In rsCliPartDatosBasicos.Keys
        SQLParams = "SET @" & param & " = " & nvConvertUtiles.objectToSQLScript(rsCliPartDatosBasicos(param)) & vbCrLf
    Next




    Dim errRes As New tError
    errRes.params("trsGral") = trsGral
    errRes.params("trsCliID") = trsCliID
    errRes.params("rsCliDatosBasicos") = rsCliDatosBasicos
    errRes.params("rsCliPartDatosBasicos") = rsCliPartDatosBasicos
    errRes.params("SQLParams") = SQLParams
    errRes.response()


%>