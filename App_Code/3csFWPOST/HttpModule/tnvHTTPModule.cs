
using System;
using nvFW;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic;
using System.Net;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.SessionState;

namespace nvFW
{

    namespace nvHTTPModule
    {
        public class nvHTTPModuleUtiles
        {
            public static Dictionary<string, trsParam> _fileJSOfuscate = new Dictionary<string, trsParam>();
            public static Dictionary<string, tnvAPINode> _API_nodes;
            public static object _API_nodes_sync = new object();
            public static List<string> _API_raices = new List<string>();

            public static void APINODE_Init()
            {
                // Cargar la configuración de API Nodes para este servidor
                string strSQL = "SELECT * FROM API_nodes n JOIN API_cfg_servers s ON n.api_cfg_id = s.api_cfg_id WHERE cod_servidor = '" + nvServer.cod_servidor + "'";

                lock (_API_nodes_sync)
                {
                    _API_nodes = new Dictionary<string, tnvAPINode>();
                    ADODB.Recordset rsNodes = new ADODB.Recordset();

                    try
                    {
                        rsNodes = nvDBUtiles.ADMDBOpenRecordset(strSQL, logEvent: false);

                        while (!rsNodes.EOF)
                        {
                            
                            //Identificar nodos raices para poder evitar posteriromente el recorrido de los nodos
                            string node_name = (string)nvUtiles.isNUll(rsNodes.Fields["node_name"].Value, "");

                            if ((bool)nvUtiles.isNUllorEmpty(rsNodes.Fields["node_parent"].Value, (bool)true) && !_API_raices.Contains(node_name))
                            {
                                _API_raices.Add(node_name);
                            } 
                            // Verificar que el "node_name" actual no esté en el diccionario
                            // Ejemplo: node_name = "API" está en más de una configuración de API (api_mutuales, api_new)
                            if (_API_nodes.ContainsKey("/" + (string)nvUtiles.isNUll(rsNodes.Fields["node_name"].Value.ToString().ToLower(), "")))
                            {
                                rsNodes.MoveNext();  // Mover al siguiente registro de nodos
                                continue;      // Saltear el bucle actual
                            }

                            tnvAPINode node = new tnvAPINode();
                            node.api_cfg_id = (string)rsNodes.Fields["api_cfg_id"].Value;
                            node.node_name = node_name;
                            node.node_type = (int)rsNodes.Fields["node_type"].Value;
                            node.node_parent = (string)nvUtiles.isNUll(rsNodes.Fields["node_parent"].Value, "");
                            node.permiso_grupo = (string)nvUtiles.isNUll(rsNodes.Fields["permiso_grupo"].Value, "");
                            node.nro_permiso = (int)nvUtiles.isNUll(rsNodes.Fields["nro_permiso"].Value, 0);
                            node.ident_cert = (bool)nvUtiles.isNUllorEmpty(rsNodes.Fields["ident_cert"].Value, false);
                            node.ident_token = (bool)nvUtiles.isNUllorEmpty(rsNodes.Fields["ident_token"].Value, false);
                            node.proxy_url = (string)nvUtiles.isNUll(rsNodes.Fields["proxy_url"].Value, "");
                            node.proxy_client_cert = (byte[])nvUtiles.isNUllorEmpty(rsNodes.Fields["proxy_client_cert"].Value, null/* TODO Change to default(_) if this is not a reference type */);
                            node.proxy_client_cert_name = (string)nvUtiles.isNUllorEmpty(rsNodes.Fields["proxy_client_cert_name"].Value, "");
                            node.proxy_client_cert_pwd = (string)nvUtiles.isNUllorEmpty(rsNodes.Fields["proxy_client_cert_pwd"].Value, "");
                            node.proxy_http_session = (bool)nvUtiles.isNUll(rsNodes.Fields["proxy_http_session"].Value, false);
                            node.proxy_server_cert = (byte[])nvUtiles.isNUllorEmpty(rsNodes.Fields["proxy_server_cert"].Value, null/* TODO Change to default(_) if this is not a reference type */);
                            node.proxy_add_headers = (string)nvUtiles.isNUll(rsNodes.Fields["proxy_add_headers"].Value, "");
                            node.proxy_timeout = (int)nvUtiles.isNUll(rsNodes.Fields["proxy_timeout"].Value, 0);
                            node.buffer_size_request = (int)nvUtiles.isNUllorEmpty(rsNodes.Fields["input_buffer_size"].Value, 81920);
                            node.buffer_size_response = (int)nvUtiles.isNUllorEmpty(rsNodes.Fields["output_buffer_size"].Value, 81920);
                            node.srv_path = (string)nvUtiles.isNUllorEmpty(rsNodes.Fields["srv_path"].Value, "");
                            node.save_request = (bool)nvUtiles.isNUllorEmpty(rsNodes.Fields["save_request"].Value, true);

                            node.proxy_client_cert_object = null;
                            node.proxy_server_cert_valid = false;

                            ADODB.Recordset rsActions = nvDBUtiles.ADMDBExecute("Select * from API_node_srv_actions where api_cfg_id='" + node.api_cfg_id + "' and node_name='" + node.node_name + "'");
                            node.srv_actions = new List<tnvAPINodeAction>();

                            System.Web.Script.Serialization.JavaScriptSerializer serializer = new System.Web.Script.Serialization.JavaScriptSerializer();

                            while (!rsActions.EOF)
                            {
                                tnvAPINodeAction rsP = new tnvAPINodeAction();
                                rsP.srv_path = (string)rsActions.Fields["srv_path"].Value;
                                rsP.httpmethod = (string)rsActions.Fields["httpmethod"].Value;

                                if (!new[] { "", "{}" }.Contains(rsActions.Fields["params"].Value))
                                {
                                    Dictionary<string, object> dic = serializer.Deserialize<Dictionary<string, object>>((string)rsActions.Fields["params"].Value);

                                    foreach (var param in dic.Keys)
                                        rsP.@params[param] = dic[param];
                                }

                                node.srv_actions.Add(rsP);
                                rsActions.MoveNext();
                            }

                            nvDBUtiles.DBCloseRecordset(rsActions);
                            node.srv_regPatternParam = new trsParam();

                            Regex reg = new Regex(@"\{([^\}]*)\}", RegexOptions.IgnoreCase | RegexOptions.Multiline);
                            MatchCollection matches = reg.Matches(node.node_name);
                            int i = 0;

                            foreach (Match match in matches)
                            {
                                node.srv_regPatternParam[i.ToString()] = match.Groups[1].ToString();
                                i += 1;
                            }

                            if (node.srv_regPatternParam.Count > 0)
                                node.srv_regPattern = new Regex(reg.Replace("/" + node.node_name, "([^/]*)"), RegexOptions.IgnoreCase);
                            else
                                node.srv_regPattern = new Regex("^/" + node.node_name + "$", RegexOptions.IgnoreCase);

                            _API_nodes.Add("/" + rsNodes.Fields["node_name"].Value.ToString().ToLower(), node);

                            ADODB.Recordset rsPaths = new ADODB.Recordset();
                            try
                            {
                                rsPaths = nvDBUtiles.ADMDBOpenRecordset("select * from API_node_paths where api_cfg_id='" + (string)rsNodes.Fields["api_cfg_id"].Value + "' and node_name = '" + (string)rsNodes.Fields["node_name"].Value + "'", logEvent: false);
                                while (!rsPaths.EOF)
                                {
                                    _API_nodes.Add("/" + rsPaths.Fields["node_path"].Value.ToString().ToLower(), node);
                                    rsPaths.MoveNext();
                                }
                            }
                            catch (Exception ex)
                            {
                            }
                            finally
                            {
                                nvDBUtiles.DBCloseRecordset(rsPaths);
                            }

                            rsNodes.MoveNext();
                        }
                    }

                    // '***************************************************************************
                    // 'creo un nodo de prueba
                    // Dim node2 As New trsParam()
                    // node2("api_cfg_id") = "API_test"
                    // node2("node_name") = "API/APPFIRMA/{element}/{elementID}"
                    // node2("node_type") = 2
                    // node2("node_parent") = "API/APPFIRMA/"
                    // node2("permiso_grupo") = 369
                    // node2("nro_permiso") = 23
                    // node2("ident_cert") = False
                    // node2("ident_token") = False
                    // node2("proxy_url") = ""
                    // node2("proxy_client_cert") = Nothing
                    // node2("proxy_client_cert_name") = ""
                    // node2("proxy_client_cert_pwd") = ""
                    // node2("proxy_http_session") = False
                    // node2("proxy_server_cert") = Nothing
                    // node2("proxy_add_headers") = ""
                    // node2("proxy_timeout") = 0
                    // node2("buffer_size_request") = 81920
                    // node2("buffer_size_response") = 81920
                    // 'node2("srv_path") = "" '~/FW/identity_server/appfirma_pdf.aspx?ef=json&as=bnZfYWRtaW4=&element={element}&documentID={elementID}




                    // Stop
                    // node2("srv_actions") = New trsParam()
                    // node2("srv_actions")("GET") = New trsParam({"element", "elementID", "srv_path"}, {"document", "*", "~/FW/identity_server/appfirma_pdf.aspx?ef=json&as=bnZfYWRtaW4=&element={element}&ak={elementID}"})
                    // node2("srv_actions")("PUT") = New trsParam({"element", "elementID", "srv_path"}, {"document", "*", "~/FW/identity_server/appfirma_sedPDF.aspx?ef=json&as=bnZfYWRtaW4=&ak={elementID}"})
                    // node2("srv_actions")("POST") = New trsParam({"element", "elementID", "srv_path"}, {"document", "*", "~/FW/identity_server/appfirma_sedPDF.aspx?ef=json&as=bnZfYWRtaW4=&ak={elementID}"})

                    // 'node2("srv_actions") = New trsParam({"httpMethod", "element", "elementID", "srv_path"}, {"Get", "document", "*", "~/FW/identity_server/appfirma_pdf.aspx?ef=json&As=bnZfYWRtaW4=&element={element}&documentID={elementID}"})


                    // node2("proxy_client_cert_object") = Nothing
                    // node2("proxy_server_cert_valid") = Nothing

                    // node2("srv_regPatternParam") = New trsParam()

                    // Dim node_name As String = node2("node_name")
                    // Dim reg As New Regex("\{([^\}]*)\}", RegexOptions.IgnoreCase Or RegexOptions.Multiline)
                    // node2("srv_regPattern") = New Regex(reg.Replace("/" & node_name, "([^/]*)"), RegexOptions.IgnoreCase)
                    // Dim matches = reg.Matches(node_name)
                    // Dim i As Integer = 0
                    // For Each match In matches
                    // node2("srv_regPatternParam")(i) = match.groups(1).ToString()
                    // i += 1
                    // Next


                    // 'node("")

                    // _API_nodes.Add("/" & node2("node_name"), node2)

                    catch (Exception ex)
                    {
                    }
                    // Stop
                    finally
                    {
                        nvDBUtiles.DBCloseRecordset(rsNodes);
                    }
                }
            }
        }



        public class tnvHTTPModule : IHttpModule
        {
            private System.Diagnostics.Stopwatch _stRequest; // Mide el tiempo de la respuesta completa
            private string _stURL; // URL del request
            private object _stSession; // En el OnEndRequest no esxiste la session se utiliza esta variable que se asigna en el AdquireSessionState


            private string getActionURL(tnvAPINode node, trsParam urlParams, HttpRequest request)
            {
                string httpmethod = request.HttpMethod;
                tnvAPINodeAction hasAction = null;

                foreach (tnvAPINodeAction action in node.srv_actions)
                {
                    if (action.httpmethod.ToLower() != httpmethod.ToLower())
                        continue;

                    foreach (var param in action.@params.Keys)
                    {
                        if (action.@params[param] != "*" && action.@params[param].ToString().ToLower() != urlParams[param].ToString().ToLower())
                            continue;
                    }

                    hasAction = action;
                    break;
                }

                string url = "";
                if (hasAction != null)
                    url = hasAction.srv_path;

                url = replaceUrlParams(url, node, urlParams, request);
                // Return replaceUrlParams(srv_path, node, urlParams, request)

                // If Not node.srv_actions(httpmethod, Nothing) Is Nothing Then
                // For Each param In node.srv_actions(httpmethod).keys
                // Select Case param.toLower()
                // Case "srv_path"
                // Case Else
                // If node.srv_actions(httpmethod)(param) <> "*" And node.srv_actions(httpmethod)(param).tolower() <> urlParams(param).tolower() Then Return ""
                // End Select
                // Next
                // Dim srv_path As String = node.srv_actions(httpmethod)("srv_path")
                // Return replaceUrlParams(srv_path, node, urlParams, request)
                // End If

                return url;
            }


            private string replaceUrlParams(string original, tnvAPINode node, trsParam urlParams, HttpRequest request)
            {
                var res = original;

                foreach (var param in urlParams.Keys)
                    res = res.Replace("{" + param + "}", System.Web.HttpUtility.UrlEncode(urlParams[param].ToString()));

                res = res.Replace("{HttpMethod}", request.HttpMethod);
                return res;
            }


            private string replaceParams(string original, trsParam node, trsParam urlParams)
            {
                var res = original;

                foreach (var param in urlParams.Keys)
                    res = res.Replace("{" + param + "}", urlParams[param].ToString());

                return res;
            }


            private static void HttpWebResponseCopy(HttpWebResponse source, HttpResponse destination, int buffer_size = 81920)
            {
                foreach (var headerKey in destination.Headers.AllKeys)
                    destination.Headers.Remove(headerKey);

                foreach (var headerKey in source.Headers.AllKeys)
                {
                    switch (headerKey.ToLower())
                    {
                        case "connection":
                        case "content-length":
                        case "Date":
                        case "expect":
                        case "host":
                        case "If-modified-since":
                        case "range":
                        case "transfer-encoding":
                        case "proxy - connection":
                            {
                                break;
                            }

                        default:
                            {
                                destination.Headers[headerKey] = source.Headers[headerKey];
                                break;
                            }
                    }
                }

                var responseStream = source.GetResponseStream();
                byte[] buffer = new byte[buffer_size - 1 + 1];
                int bytes;
                bytes = responseStream.Read(buffer, 0, buffer_size);

                while (bytes > 0)
                {
                    destination.OutputStream.Write(buffer, 0, bytes);
                    bytes = responseStream.Read(buffer, 0, buffer_size);
                }
            }


            private static void HttpWebRequestCopy(HttpRequest source, HttpWebRequest destination, int buffer_size = 81920)
            {
                destination.Method = source.HttpMethod;
                // Recorrer todas las headers
                // Copiar las cabeceras irrestrictas (incluyendo cookies, if any)
                foreach (var headerKey in source.Headers.AllKeys)
                {
                    switch (headerKey.ToLower())
                    {
                        case "connection":
                        case "content-length":
                        case "Date":
                        case "expect":
                        case "host":
                        case "If-modified-since":
                        case "range":
                        case "transfer-encoding":
                        case "proxy - connection":
                            {
                                break;
                            }

                        case "accept":
                        case "content-type":
                        case "referer":
                        case "user-agent":
                            {
                                break;
                            }

                        default:
                            {
                                destination.Headers[headerKey] = source.Headers[headerKey];
                                break;
                            }
                    }
                }

                // Copias las cabeceras restringidas
                if (source.AcceptTypes.Any())
                    destination.Accept = string.Join(",", source.AcceptTypes);

                destination.ContentType = source.ContentType;
                if (source.UrlReferrer != null)
                    destination.Referer = source.UrlReferrer.AbsoluteUri;

                destination.UserAgent = source.UserAgent;
                // Agregar / Actualizar X-Forwarded-For header
                if (!source.IsLocal)
                {
                    if (source.Headers.AllKeys.Contains("X-Forwarded-For"))
                        destination.Headers["X-Forwarded-For"] = source.UserHostAddress;
                }

                // Copiar el contenido del body si existe
                if ((source.HttpMethod.ToUpper() != "Get" & source.HttpMethod.ToUpper() != "HEAD" & source.ContentLength > 0))
                {
                    var destinationStream = destination.GetRequestStream();
                    source.InputStream.CopyTo(destinationStream, buffer_size);
                    destinationStream.Close();
                }
            }


            public void Init(HttpApplication application)
            {
                application.BeginRequest += OnBeginRequest;
                application.EndRequest += OnEndRequest;

                // todos vacios
                // AddHandler application.PostRequestHandlerExecute, AddressOf PostRequestHandlerExecute
                // AddHandler application.PreSendRequestHeaders, AddressOf PreSendRequestHeaders
                // AddHandler application.PostReleaseRequestState, AddressOf PostReleaseRequestState
                application.AcquireRequestState += AcquireRequestState;
            }


            public void Dispose()
            {
            }


            private void OnBeginRequest(object source, EventArgs e)
            {
                printDebug("OnBeginRequest", source, e);
                HttpApplication application = (HttpApplication)source;
                HttpContext context = application.Context;
                string proxy_url = "";
                string currentExecutionFilePath = context.Request.CurrentExecutionFilePath.ToLower();
                _stRequest = new System.Diagnostics.Stopwatch();
                _stRequest.Start();
                _stURL = currentExecutionFilePath;

                if (nvServer.start_error != null)  return;

                // *********************************************************************
                // Procesar las llamadas del API-Proxy
                // Si la ruta está configurada en la lista 
                // *********************************************************************
                lock (nvHTTPModuleUtiles._API_nodes_sync)
                {
                    if (nvHTTPModuleUtiles._API_nodes == null)
                        nvHTTPModuleUtiles.APINODE_Init();
                }

                //Identificar que sea un nodo API comparando con las RAIZ de las APIs
                bool esNodoAPI = false;
                foreach (var node_name in nvHTTPModuleUtiles._API_raices)
                    if (currentExecutionFilePath.IndexOf("" + node_name + "") == 0)
                    {
                        esNodoAPI = true;
                        break;
                    }
                 
                //Si es nodo API proresarlo
                if (esNodoAPI)
                {
                    tnvAPINode hasNode = null;

                    foreach (var key in nvHTTPModuleUtiles._API_nodes.Keys)
                    {
                        if (nvHTTPModuleUtiles._API_nodes[key].srv_regPattern.IsMatch(currentExecutionFilePath))
                        {
                            hasNode = nvHTTPModuleUtiles._API_nodes[key];
                            break;
                        }
                    }

                    if (hasNode != null)
                    {
                        if (hasNode.save_request == true)
                        {
                            System.IO.Stream io = HttpContext.Current.Request.InputStream;
                            io.Position = 0;
                            byte[] buffer = new byte[io.Length - 1 + 1];
                            io.Read(buffer, 0, buffer.Length);

                            byte[] request_binary = buffer.ToArray();

                            HttpContext.Current.Items["hasApi"] = true;
                            HttpContext.Current.Items["save_request"] = true;

                            // guardar stream
                            string strSQL_api_log = "INSERT INTO API_log (node_name, request_momento, request_binary) VALUES (?,GETDATE(),?); SELECT SCOPE_IDENTITY() AS id_api_log";

                            nvDBUtiles.tnvDBCommand cmdAPILog = new nvDBUtiles.tnvDBCommand(strSQL_api_log, db_type: nvDBUtiles.emunDBType.db_admin);

                            // Parametro 0: "node_name"
                            cmdAPILog.Parameters[0].Type = ADODB.DataTypeEnum.adVarChar;
                            cmdAPILog.Parameters[0].Size = hasNode.node_name.Length;
                            cmdAPILog.Parameters[0].Value = hasNode.node_name;

                            // Parametro 1: "request_binary"
                            cmdAPILog.Parameters[1].Type = ADODB.DataTypeEnum.adLongVarBinary;
                            cmdAPILog.Parameters[1].Size = request_binary.Count() == 0 ? -1 : request_binary.Count();
                            cmdAPILog.Parameters[1].Value = request_binary;

                            ADODB.Recordset rs_api_log = cmdAPILog.Execute();
                            // Guardar valor de identity
                            HttpContext.Current.Items["id_API_log"] = rs_api_log.Fields["id_api_log"].Value;
                            nvDBUtiles.DBCloseRecordset(rs_api_log);

                            io.Position = 0;
                        }

                        tnvAPINode APINode = hasNode;

                        if (APINode.node_type == 2)
                        {
                            try
                            {
                                Match m = APINode.srv_regPattern.Match(currentExecutionFilePath);
                                trsParam urlParams = new trsParam();

                                foreach (string index in APINode.srv_regPatternParam.Keys)
                                    urlParams[APINode.srv_regPatternParam[index].ToString()] = m.Groups[System.Convert.ToInt32(index) + 1].ToString();

                                string path = getActionURL(APINode, urlParams, context.Request);
                                if (path != "")
                                    context.RewritePath(path, true);
                                // context.RewritePath(APINode("proxy_url"), True)
                                return;
                            }
                            catch (Exception ex)
                            {
                                var bv = ex.Message;
                            }
                        }

                        try
                        {
                            string cert_login = ""; // login asociado al certificado
                            string token_login = ""; // login asociado al token
                            int nro_operador = 0; // Nro de operador del ADMIN
                            string operador = ""; // Nombre del operador

                            // Controlar acceso HTTPS
                            string HTTPS = context.Request.ServerVariables["HTTPS"];

                            if (nvServer.onlyHTTPS == true & HTTPS.ToLower() != "On")
                                throw new Exception("Error de acceso. El recurso solo puede ser accedido por HTTPS/SSL");

                            // *****************************************************
                            // Agregar controlador genérico de certificado de servidor
                            // *****************************************************
                            if (ServicePointManager.ServerCertificateValidationCallback == null)
                                ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback(nvHttpUtiles.GenericValidateCertificate);

                            // Definir protocolos de seguridad (ssl3, tls1, tls1.1, tls1.2)
                            ServicePointManager.SecurityProtocol = nvHttpUtiles.https_defaultSecurityProtocol;

                            // *****************************************************
                            // Utilizar certificado cliente
                            // *****************************************************
                            if (APINode.ident_cert && context.Request.ClientCertificate.Subject != "")
                            {
                                HttpClientCertificate ClientCertificate = HttpContext.Current.Request.ClientCertificate;
                                string strSQLcert = "Select * from nv_login_certificates where serialnumber= Replace('" + ClientCertificate.SerialNumber + "', '-', '')";
                                ADODB.Recordset rsLogin = nvDBUtiles.ADMDBOpenRecordset(strSQLcert);

                                while (!rsLogin.EOF)
                                {
                                    byte[] bin = (byte[])rsLogin.Fields["cert"].Value;
                                    if (bin.SequenceEqual(ClientCertificate.Certificate))
                                    {
                                        cert_login = rsLogin.Fields["login"].Value.ToString();
                                        break;
                                    }
                                    rsLogin.MoveNext();
                                }

                                nvDBUtiles.DBCloseRecordset(rsLogin);
                            }

                            // *****************************************************
                            // Controlar token de seguridad
                            // *****************************************************
                            if (APINode.ident_token && false)
                            {
                            }

                            // *****************************************************
                            if (APINode.ident_token & APINode.ident_cert & (cert_login != token_login))
                                throw new Exception("Error de acceso. EL usuario del certificado de seguridad no se corresponde con el del token.");

                            // *****************************************************
                            // Identificar operador
                            // *****************************************************
                            // De acuerdo a la configutración de Nodo se valida, certificado, token, filtrado de IP, etc
                            string strSQLoperador = "select * from verOperadores where login ='" + cert_login + "'";
                            ADODB.Recordset rsOperador = nvDBUtiles.ADMDBOpenRecordset(strSQLoperador);

                            if (!rsOperador.EOF)
                            {
                                nro_operador = (int)rsOperador.Fields["operador"].Value;
                                operador = rsOperador.Fields["nombre_operador"].Value.ToString();
                            }
                            else
                                throw new Exception("No se ha podido identificar el usuario del servicio.");

                            // *****************************************************
                            // Controlar Acceso al servicio
                            // *****************************************************
                            if (new[] { 1, 2 }.Contains(APINode.node_type))
                            {
                                string strSQLAcc = "SELECT [dbo].[rm_tiene_permiso_operador] ('" + APINode.permiso_grupo + "', " + APINode.nro_permiso + ", '" + nro_operador + "') as tiene_permiso";
                                ADODB.Recordset rsAcc = nvDBUtiles.ADMDBOpenRecordset(strSQLAcc);
                                int tiene_permiso = (int)rsAcc.Fields["tiene_permiso"].Value;
                                nvDBUtiles.DBCloseRecordset(rsAcc);

                                if (tiene_permiso == 0)
                                    throw new Exception("No tiene permisos para ejecutar este servicio.");
                            }

                            switch (APINode.node_type)
                            {
                                case 0 // Carpeta
                               :
                                    {
                                        // No se hace nada cuando es una carpeta
                                        throw new Exception("No se puede realizar una llamada a un nodo carpeta.");
                                        break;
                                    }

                                case 1 // Proxy ARR
                         :
                                    {
                                        // *****************************************************
                                        // Procesar la llamada
                                        // *****************************************************
                                        proxy_url = APINode.proxy_url;

                                        // Incorporar QueryString
                                        if (context.Request.QueryString.ToString() != "")
                                            proxy_url += "?" + context.Request.QueryString.ToString();

                                        // Copiar el Request
                                        HttpWebRequest externalRequest = (HttpWebRequest)HttpWebRequest.Create(proxy_url);
                                        HttpWebRequestCopy(context.Request, externalRequest, APINode.buffer_size_request);

                                        // Si tiene certificado cliente agregarlo
                                        if (APINode.proxy_client_cert != null)
                                        {
                                            if (APINode.proxy_client_cert_object == null)
                                            {
                                                try
                                                {
                                                    byte[] certBytes = APINode.proxy_client_cert;
                                                    string certPass = APINode.proxy_client_cert_pwd;
                                                    APINode.proxy_client_cert_object = new System.Security.Cryptography.X509Certificates.X509Certificate2(certBytes, certPass);
                                                }
                                                catch (Exception ex)
                                                {
                                                    throw new Exception("No se puede abrir el certificado cliente proporcinado. " + ex.Message);
                                                }
                                            }

                                            externalRequest.ClientCertificates.Add(APINode.proxy_client_cert_object);
                                        }

                                        // Recuperar la resppuesta
                                        externalRequest.Timeout = APINode.proxy_timeout <= 0 ? System.Threading.Timeout.Infinite : APINode.proxy_timeout;
                                        WebResponse externalResponse;
                                        var ServerCertificateValidationCallback_ant = ServicePointManager.ServerCertificateValidationCallback;
                                        var MaxServicePointIdleTime_ant = ServicePointManager.MaxServicePointIdleTime;

                                        if (APINode.proxy_server_cert != null & !APINode.proxy_server_cert_valid)
                                        {
                                            ServicePointManager.MaxServicePointIdleTime = 0;
                                            ServicePointManager.ServerCertificateValidationCallback = new System.Net.Security.RemoteCertificateValidationCallback((object sender, System.Security.Cryptography.X509Certificates.X509Certificate certificate, System.Security.Cryptography.X509Certificates.X509Chain chain, System.Net.Security.SslPolicyErrors sslPolicyErrors) =>
                                            {
                                                bool validationResult;
                                                validationResult = true;
                                                string pvCurrentExecutionFilePath = context.Request.CurrentExecutionFilePath.ToLower();

                                                // *********************************************************************
                                                // Procesar las llamadas del API-Proxy
                                                // Si la ruta está configurada en la lista 
                                                // *********************************************************************
                                                if (nvHTTPModuleUtiles._API_nodes.ContainsKey(pvCurrentExecutionFilePath))
                                                {
                                                    tnvAPINode pvAPINode = nvHTTPModuleUtiles._API_nodes[currentExecutionFilePath];

                                                    if (pvAPINode.proxy_server_cert != null)
                                                    {
                                                    }
                                                }

                                                // Throw New Exception("Error de validación del certificado servidor")
                                                return validationResult;
                                            });
                                            externalResponse = externalRequest.GetResponse();

                                            ServicePointManager.MaxServicePointIdleTime = MaxServicePointIdleTime_ant;
                                            ServicePointManager.ServerCertificateValidationCallback = ServerCertificateValidationCallback_ant;
                                            APINode.proxy_server_cert_valid = true;
                                        }
                                        else
                                            externalResponse = externalRequest.GetResponse();

                                        // Copiar la respuesta
                                        HttpWebResponseCopy((HttpWebResponse)externalResponse, context.Response, APINode.buffer_size_response);

                                        // Terminar la respuesta
                                        application.CompleteRequest();
                                        return;
                                    }
                            }
                        }
                        catch (Exception ex)
                        {
                            tError er = new tError();
                            er.parse_error_script(ex);
                            er.titulo = "Error en API Node";
                            er.mensaje += "No se pudo procesar la llamada a '" + context.Request.Path + "'";
                            er.response();
                        }
                    }


                }

                string PhysicalPath = "";

                try
                {
                    PhysicalPath = context.Request.PhysicalPath.ToLower();
                    string ext = System.IO.Path.GetExtension(PhysicalPath);
                    string filename = System.IO.Path.GetFileName(PhysicalPath);

                    if ((ext == ".htm" | ext == ".html" | ext == ".aspx") & nvSecurity.nvCrypto.jsofuscator_library.ToLower() != "none" & HttpContext.Current.IsDebuggingEnabled)
                        context.Response.Filter = new nvHttpFilterJS(context.Response.Filter, context.Request.Url.ToString().ToLower(), context.Response, context.Request);

                    if (ext == ".js" & nvSecurity.nvCrypto.jsofuscator_library.ToLower() != "none" & HttpContext.Current.IsDebuggingEnabled)
                    {
                        // Excluir ServideWorker
                        if (filename.ToLower() == "sw.js" | filename.ToLower() == "config_sw.js")
                            return;

                        System.Text.Encoding encoder;
                        string charset = "ISO-8859-1";
                        // Dim p As Dean.Edwards.ECMAScriptPacker = New ECMAScriptPacker((ECMAScriptPacker.PackerEncoding) Encoding.SelectedItem, fastDecode.Checked, specialChars.Checked)
                        // context.Request.FilePath
                        string strRes;

                        if (nvHTTPModuleUtiles._fileJSOfuscate.Keys.Contains(PhysicalPath))
                        {
                            strRes = nvHTTPModuleUtiles._fileJSOfuscate[PhysicalPath]["code"].ToString();
                            charset = nvHTTPModuleUtiles._fileJSOfuscate[PhysicalPath]["encode"].ToString();
                            encoder = System.Text.Encoding.GetEncoding(charset);
                        }
                        else
                        {
                            DateTime lastModified = (new System.IO.FileInfo(context.Request.PhysicalPath)).LastWriteTime;
                            var ETag = "\"" + lastModified.ToString("yyyyMMddHHmmss") + "\"";
                            byte[] bytes;

                            try
                            {
                                bytes = System.IO.File.ReadAllBytes(context.Request.PhysicalPath);
                            }
                            catch (Exception ex)
                            {
                                return;
                            }

                            // Dim objReader As New System.IO.StreamReader(context.Request.PhysicalPath)
                            string src;

                            if (bytes.Length >= 3)
                            {
                                if (bytes[0] == 239 & bytes[1] == 187 & bytes[2] == 191)
                                {
                                    byte[] bytes2 = new byte[bytes.Length - 4 + 1];
                                    Array.Copy(bytes, 3, bytes2, 0, bytes.Length - 3);
                                    charset = "UTF-8";
                                    encoder = System.Text.Encoding.GetEncoding("UTF-8");
                                    src = encoder.GetString(bytes2);
                                }
                                else
                                {
                                    encoder = System.Text.Encoding.GetEncoding("iso-8859-1");
                                    src = encoder.GetString(bytes);
                                }
                            }
                            else
                            {
                                encoder = System.Text.Encoding.GetEncoding("iso-8859-1");
                                src = encoder.GetString(bytes);
                            }

                            try
                            {
                                strRes = nvSecurity.nvCrypto.JSToJSOfuscated(src, "file_js");

                                trsParam rs = new trsParam();
                                rs["code"] = strRes;
                                rs["encode"] = charset;
                                nvHTTPModuleUtiles._fileJSOfuscate.Add(PhysicalPath, rs);
                            }
                            catch (Exception ex)
                            {
                                return;
                            }
                        }

                        context.Response.Cache.SetMaxAge(new TimeSpan(1, 0, 0));

                        if (encoder != null)
                            context.Response.ContentEncoding = encoder;

                        context.Response.Charset = charset;
                        context.Response.ContentType = "application/x-javascript";
                        context.Response.Write(strRes);
                        application.CompleteRequest();
                    }
                }
                catch (Exception ex)
                {
                }
            }


            private void printDebug(string event_name, object sender, EventArgs e)
            {
            }


            private void OnEndRequest(object source, EventArgs e)
            {
                printDebug("OnEndRequest", source, e);

                long ms = -1;
                if (_stRequest != null)
                {
                    _stRequest.Stop();
                    ms = _stRequest.ElapsedMilliseconds;
                }

                HttpApplication application = (HttpApplication)source;

                string URL = "";
                if (application.Request != null && application.Request.CurrentExecutionFilePath != null)
                    URL = application.Request.CurrentExecutionFilePath.ToLower();

                nvLog.addEvent("httpreq", _stURL + "," + URL + "," + ms.ToString(), (HttpSessionState)_stSession);
            }


            private void AcquireRequestState(object sender, EventArgs e)
            {
                printDebug("AcquireRequestState", sender, e);
                HttpContext context = HttpContext.Current;
                if (context != null && context.Session != null)
                    _stSession = context.Session;
            }


            public void PostRequestHandlerExecute(object source, EventArgs e)
            {
                printDebug("PostRequestHandlerExecute", source, e);
            }


            public void PreSendRequestHeaders(object sender, EventArgs e)
            {
                printDebug("PreSendRequestHeaders", sender, e);
            }


            public void PostReleaseRequestState(object sender, EventArgs e)
            {
                printDebug("PostReleaseRequestState", sender, e);
            }


            public void onError(object sender, EventArgs e)
            {
                printDebug("Error", sender, e);
            }


            public void PostAcquireRequestState(object sender, EventArgs e)
            {
                printDebug("PostAcquireRequestState", sender, e);
            }


            public void ReleaseRequestState(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void AuthenticateRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void AuthorizeRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void Disposed(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void LogRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PostAuthenticateRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PostLogRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PostAuthorizeRequest(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PostUpdateRequestCache(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PostResolveRequestCache(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PreRequestHandlerExecute(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void PreSendRequestContent(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void RequestCompleted(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void ResolveRequestCache(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }


            public void UpdateRequestCache(object sender, EventArgs e)
            {
                printDebug("ReleaseRequestState", sender, e);
            }
        }
    }



    public class nvHttpFilterJS : System.IO.MemoryStream
    {
        private System.IO.Stream outputStream = null;

        // Encuentra los script abiertos y cerrados en el buffer
        private string strRegExp = @"<script([^>]*)>+((?:(?!</script>)(.|\s))*)</script>";
        //private System.Text.RegularExpressions.Regex RegExp = new System.Text.RegularExpressions.Regex(strRegExp, RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled, TimeSpan.FromMilliseconds(1000));
        private System.Text.RegularExpressions.Regex RegExp = new System.Text.RegularExpressions.Regex(@"<script([^>]*)>+((?:(?!</script>)(.|\s))*)</script>", RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled, TimeSpan.FromMilliseconds(1000));

        // Encuentra el último script abierto en el buffer
        private string strRegExpEnd = @"<script\s";
        //private System.Text.RegularExpressions.Regex RegExpEnd = new System.Text.RegularExpressions.Regex(strRegExpEnd, RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled | RegexOptions.RightToLeft);
        private System.Text.RegularExpressions.Regex RegExpEnd = new System.Text.RegularExpressions.Regex(@"<script\s", RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled | RegexOptions.RightToLeft);

        // Encuentra la etiqueta de cierre de script
        private string strRegEnd2 = "</script>";
        //private System.Text.RegularExpressions.Regex RegExpEnd2 = new System.Text.RegularExpressions.Regex(strRegEnd2, RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled);
        private System.Text.RegularExpressions.Regex RegExpEnd2 = new System.Text.RegularExpressions.Regex("</script>", RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled);

        // Encuentra la etiqueta de cierre de script
        private string strRegHTML = @"<html(\s|>)+";
        //private System.Text.RegularExpressions.Regex RegExpHTML = new System.Text.RegularExpressions.Regex(strRegHTML, RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled);
        private System.Text.RegularExpressions.Regex RegExpHTML = new System.Text.RegularExpressions.Regex(@"<html(\s|>)+", RegexOptions.IgnoreCase | RegexOptions.Multiline | RegexOptions.Compiled);

        private bool _enabled = true;
        private int _block_count = 0;
        private int _max_block_process = 4;

        private string _requestUrl;
        private HttpResponse _response;
        private HttpRequest _request;

        private string _str_original = "";
        private string _str_ofusqued = "";
        private string _previous_script = "";
        private Dictionary<int, string> _lsouce = new Dictionary<int, string>();
        private Dictionary<int, string> _ldest = new Dictionary<int, string>();
        // Private _previousBuffer As String = ""


        public nvHttpFilterJS(System.IO.Stream output, string requestUrl, HttpResponse response, HttpRequest request)
        {
            outputStream = output;
            _requestUrl = requestUrl;
            _response = response;
            _request = request;
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            // Incrementar el contador de bloques
            _block_count += 1;
            bool hasPreviousScript = _previous_script != "";
            byte[] resBytes;

            // Cargar el contenido teniendo en cuenta que puede haber una parte no procesada del bloque anterior
            //if (buffer[Information.UBound(buffer)] == 0)
            if (buffer[buffer.GetUpperBound(0)] == 0)
            {
                byte[] buffer2 = new byte[buffer.Length - 2 + 1];
                Array.Copy(buffer, buffer2, buffer.Length - 1);
                buffer = buffer2;
            }

            string contentInBuffer = _response.ContentEncoding.GetString(buffer);
            _lsouce.Add(_block_count, contentInBuffer);

            // If contentInBuffer = _previousBuffer Then
            // Exit Sub
            // End If
            // _previousBuffer = contentInBuffer
            _str_original += contentInBuffer;
            // Si _previous_script viene con datos y en este bloque no se encuentra la etiqueta de cierre agregar a _previous_script y continuar con el bloque siguiente
            if (_previous_script != "")
            {
                if (!RegExpEnd2.IsMatch(contentInBuffer))
                {
                    _previous_script += contentInBuffer;
                    contentInBuffer = "";
                }
                else
                {
                    contentInBuffer = _previous_script + contentInBuffer;
                    _previous_script = "";
                }
            }

            // El primer bloque debe terner la etiqueta <HTML>, sino deshabilitar el proceso
            if (_block_count == 1 & !RegExpHTML.IsMatch(contentInBuffer.Substring(0, contentInBuffer.Length > 200 ? 200 : contentInBuffer.Length)))
                _enabled = false;

            resBytes = buffer;
            bool IgnoreJSO = _response.Headers["IgnoreJSO"] == "true";

            // Si está habilitado y no ha llegado a la cantidad máxima de bloques
            if ((_enabled & _block_count <= _max_block_process & !IgnoreJSO) | hasPreviousScript)
            {
                // Encontrar los scripts abierto y no cerrados, si existen colocarlo en _previous_script para ser procesado en el próximo bloque
                Match m2 = RegExpEnd.Match(contentInBuffer);

                if (m2.Success)
                {
                    if (!RegExpEnd2.IsMatch(contentInBuffer.Substring(m2.Index, contentInBuffer.Length - m2.Index)))
                    {
                        _previous_script = contentInBuffer.Substring(m2.Index, contentInBuffer.Length - m2.Index);
                        contentInBuffer = contentInBuffer.Substring(0, m2.Index);
                    }
                }

                trsParam matches = new trsParam();
                int index = 0;

                // Encontrar todos los scripts abiertos y cerrrados y ofuscarlos
                try
                {
                    Match match0 = RegExp.Match(contentInBuffer);

                    while (match0.Success)
                    {
                        string timValue = match0.Groups[2].Value.Trim(' ');
                        if (timValue != "" & timValue.Length > 150 & (match0.Groups[1].Value.ToLower().Contains("javascript") | match0.Groups[1].Value.ToLower().Contains("jscript")))
                        {
                            trsParam trsMatch = new trsParam();
                            trsMatch["index"] = index;
                            trsMatch["group0_value"] = match0.Groups[0].Value;
                            trsMatch["group1_value"] = match0.Groups[1].Value;
                            trsMatch["group2_value"] = match0.Groups[2].Value;

                            matches[index.ToString()] = trsMatch;

                            index += 1;
                        }
                        match0 = match0.NextMatch();
                    }
                }
                catch (Exception ex)
                {
                }

                // Si no es vacío y contiene javascript o jscript hay que ofuscar
                foreach (System.Collections.Generic.KeyValuePair<string, object> match in matches)
                {

                    trsParam trsMatch = (trsParam)match.Value;
                    string strJSOriginal = trsMatch["group2_value"].ToString();
                    string scriptRes = "<script " + trsMatch["group1_value"].ToString() + ">" + nvSecurity.nvCrypto.JSToJSOfuscated(strJSOriginal, "js_in_html") + "</script>";
                    contentInBuffer = contentInBuffer.Replace(trsMatch["group0_value"].ToString(), scriptRes);
                }

                resBytes = _response.ContentEncoding.GetBytes(contentInBuffer);
            }

            var rescontentInBuffer = _response.ContentEncoding.GetString(resBytes);
            _ldest.Add(_block_count, rescontentInBuffer);
            _str_ofusqued += rescontentInBuffer;
            outputStream.Write(resBytes, offset, resBytes.Length);
        }


        ~nvHttpFilterJS()
        {
            //Finaliza en el destructor
            //base.Finalize();
            outputStream = null;
            _requestUrl = null;
            _response = null;
            _request = null;
        }
    }



    public class tnvAPINode
    {
        public string api_cfg_id;
        public string node_name;
        public int node_type;
        public string node_parent;
        public string permiso_grupo;
        public int nro_permiso;
        public bool ident_cert;
        public bool ident_token;
        public string proxy_url;
        public byte[] proxy_client_cert;
        public string proxy_client_cert_name;
        public string proxy_client_cert_pwd;
        public bool proxy_http_session;
        public byte[] proxy_server_cert;
        public string proxy_add_headers;
        public int proxy_timeout;
        public int buffer_size_request;
        public int buffer_size_response;
        public string srv_path;
        public bool save_request;

        public System.Security.Cryptography.X509Certificates.X509Certificate2 proxy_client_cert_object;
        public bool proxy_server_cert_valid;
        public List<tnvAPINodeAction> srv_actions = new List<tnvAPINodeAction>();
        public trsParam srv_regPatternParam = new trsParam();
        public Regex srv_regPattern;
    }



    public class tnvAPINodeAction
    {
        public string srv_path;
        public string httpmethod;
        public trsParam @params = new trsParam();

        ~tnvAPINodeAction()
        {
            //Finaliza en el destructor
            //base.Finalize();
        }
    }
}