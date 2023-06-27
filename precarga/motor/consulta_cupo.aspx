<%@ Page Language="C#" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    nvFW.tError err = new nvFW.tError();
    string strXML  = "";

    TimeSpan ts;
    string logTrack = nvLog.getNewLogTrack();
    System.Diagnostics.Stopwatch Stopwatch = System.Diagnostics.Stopwatch.StartNew();

    try {
        string nro_docu = nvFW.nvUtiles.obtenerValor("nro_docu", "0");
        string sce_id = nvFW.nvUtiles.obtenerValor("sce_id", 0);
        string clave_sueldo = nvFW.nvUtiles.obtenerValor("clave_sueldo", 0);
        err = nvLogin.execute(nvApp, "get_hash", nvApp.operador.login, "", "", "", "", "");
        string hash = err.@params["hash"].ToString();
        string aspx_callback = "FW/servicios/ROBOTS/GetXML.aspx";
        string URLREQUEST = "https://" + nvApp.server_name + "/" + aspx_callback;
        ADODB.Recordset rs = nvFW.nvDBUtiles.DBOpenRecordset("Select  isnull(dbo.piz1D('CUAD callback robot','" + nvApp.cod_servidor + "'),'') as host_callback");
        if (!rs.EOF)
            if (rs.Fields["host_callback"].Value.ToString() != "")
                URLREQUEST = "https://" + rs.Fields["host_callback"].Value + "/" + aspx_callback;

        string criterio = "<criterio><nro_docu>" + nro_docu + "</nro_docu><sce_id>" + sce_id + "</sce_id><clave_sueldo>" + clave_sueldo + "</clave_sueldo></criterio>";
        nvHTTPRequest oHTTP = new nvHTTPRequest();
        oHTTP.multi_part = true;
        oHTTP.url = URLREQUEST;
        oHTTP.param_add("a", "consultar_premotor");
        oHTTP.param_add("app_cod_sistema", "nv_mutualprecarga");
        oHTTP.param_add("app_path_rel", "precarga");
        oHTTP.param_add("criterio", criterio);
        oHTTP.param_add("hash", hash);
        oHTTP.param_add("nv_hash", hash);
        oHTTP.param_add("end", "");
        oHTTP.time_out = 30000;

        System.Net.HttpWebResponse response = oHTTP.getResponse();

        if (response == null) {
            err.numError = -1;
            err.mensaje = "Servicio apagado. URL: " + URLREQUEST;
            strXML = err.get_error_xml();
        } else {
            System.IO.StreamReader reader = new System.IO.StreamReader(response.GetResponseStream(), System.Text.Encoding.GetEncoding("iso-8859-1"));
            System.Xml.XmlDocument oXML = new System.Xml.XmlDocument();
            strXML = reader.ReadToEnd();
        }

        //cargo el terror tmp por si viene cualquier cosa
        tError ErrTmp = new tError();
        ErrTmp.loadXML(strXML);
        if (ErrTmp.numError != 0) {
            err.numError = -5;
            err.mensaje = "No se pudo procesar la informacion. Intente luego";
            err.@params["strXML"] = strXML;
        } else {
            err = ErrTmp;
        }
        ErrTmp = null;
    } catch (Exception ex) {
        err.parse_error_script(ex);
        err.titulo = "Error al consultar cupo";
    }
    Stopwatch.Stop();
    ts = Stopwatch.Elapsed;
    nvLog.addEvent("lg_precarga", ";" + logTrack + ";" + ts.TotalMilliseconds + ";Z;consultar_premotor;mensaje=" + err.mensaje);

    err.response();

%>