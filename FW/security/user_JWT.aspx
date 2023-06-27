<%@ Page Language="VB" Inherits="nvFW.nvPages.nvPageFW" %>
<%
    ' Agregar un nuevo recurso para el cliente seleccionado

    'Dim resorce As String = obtenerValor("resource", "")
    Dim err As tError = nvFW.nvLogin.execute(nvApp, "get_jwt", "", "", "", "", "", "")
    err.response()

    'If resorce = "" Then
    '    err.numError = 10
    '    err.titulo = "Error en genración de token"
    '    err.mensaje = "El campo 'resource' es obligatorio"
    '    err.debug_src = "ids_get_clientToken"
    '    err.response()
    'End If


    'Dim strSQLCheckResource As String = "select * from ids_clientes c join ids_resources r on c.ids_cli_id = r.ids_cli_id where c.ids_cli_id = " & nvApp.operador.ids_cli_id & " and ids_res_id = '" & resorce & "'"
    'Dim rsRes As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQLCheckResource)
    'Dim rescurso_encontrado As Boolean = Not rsRes.EOF
    'nvDBUtiles.DBCloseRecordset(rsRes)

    'If Not rescurso_encontrado Then
    '    err.numError = 10
    '    err.titulo = "Error en genración de token"
    '    err.mensaje = "Recurso no encontrado"
    '    err.debug_src = "ids_get_clientToken"
    '    err.response()
    'End If



    'Dim nvTWT As New nvFW.nvSecurity.tnvJWT
    ''nvTWT.payload("iss") = "IDS"
    'nvTWT.payload("sub") = DirectCast(nvApp.operador, nvPages.tnvOperadorIDS).login
    'nvTWT.payload("aud") = nvApp.cod_sistema


    'Dim cert As System.Security.Cryptography.X509Certificates.X509Certificate2
    'Dim oPKI As tnvPKI = Application.Contents("_Main_PKI")
    'Dim myCerts As Dictionary(Of String, Org.BouncyCastle.X509.X509Certificate)
    'If oPKI Is Nothing Then
    '    oPKI = nvFW.nvPKIDBUtil.LoadPKIFromDB("Main")
    '    Application.Contents("_Main_PKI") = oPKI
    'End If
    'myCerts = oPKI.myCerts()
    'If (myCerts.Count = 0) Then
    '    err.numError = 12
    '    err.titulo = "Error en genración de token"
    '    err.mensaje = "No se se encuentran certificados propios"
    '    err.debug_src = "ids_get_clientToken"
    '    err.response()
    'End If
    'cert = oPKI.certs_X509Certificate2(myCerts.First.Key)
    'Application.Contents("_Main_PKI_myCert") = cert


    'Dim strJWT As String = nvTWT.encode()

    'err.params("JWT") = strJWT

    'err.response()

    'Dim iss As String = ""
    'Dim header As String = "{""alg"":""RS256"",""typ"":""JWT""}" 'indica que este token está firmado utilizando HMAC-SHA256 o firma digital con SHA-256 (RS256).
    'Dim payload As String = "{""iss"":""" & "IdSeparator" & """, ""loggedInAs"":""admin"",""iat"":1422779638}" 'El estándar sugiere incluir una marca temporal o timestamp en inglés, llamado iat para indicar el momento en el que el token fue creado.

    'Para el payload
    'Código  Nombre	Descripción
    'iss Issuer	Identifica el proveedor de identidad que emitió el JWT
    'Sub Subject()	Identifica el objeto o usuario en nombre del cual fue emitido el JWT
    'aud Audience	Identifica la audiencia o receptores para lo que el JWT fue emitido, normalmente el/los servidor/es de recursos (e.g. la API protegida). Cada servicio que recibe un JWT para su validación tiene que controlar la audiencia a la que el JWT está destinado. Si el proveedor del servicio no se encuentra presente en el campo aud, entonces el JWT tiene que ser rechazado
    'exp Expiration time	Identifica la marca temporal luego de la cual el JWT no tiene que ser aceptado. 
    'nbf Not before	Identifica la marca temporal en que el JWT comienza a ser válido. EL JWT no tiene que ser aceptado si el token es utilizando antes de este tiempo. 
    'iat Issued at	Identifica la marca temporal en qué el JWT fue emitido.
    'jti JWT ID	Identificador único del token incluso entre diferente proveedores de servicio.


    'Código   Nombre	Descripción
    'typ Token type	Si está presente, se recomienda utilizar el valor JWT.
    'cty Content type	En casos normales, no es recomendado. En casos de firma o cifrado anidado, debe está presente y el valor debe ser JWT.
    'alg Message authentication code algorithm	El proveedor de identidad puede elegir libremente el algoritmo para verificar la firma del token, aunque algunos de los algoritmos soportados son inseguros.



    'Validación del token -  Authorization: Bearer eyJhbGci...<snip>...yu5CSpyHI
%>