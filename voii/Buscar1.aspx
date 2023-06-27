<%@ Page Language="C#" AutoEventWireup="false"  %>
<%

    trsParam matches = new trsParam();
    int index = 0;

    try
    {

        trsParam trsMatch = new trsParam();
        trsMatch["index"] = index;
        trsMatch["group0_value"] = "algo1";
        trsMatch["group1_value"] = "algo2";
        trsMatch["group2_value"] = "algo3";

        matches[index.ToString()] = trsMatch;

        index += 1;
    }
    catch (Exception ex)
    {
    }

    // Si no es vacío y contiene javascript o jscript hay que ofuscar
    foreach (System.Collections.Generic.KeyValuePair<string, object> match in matches)
    {

        string algo = "";
        trsParam trsMatch = (trsParam)match.Value;
        string algo2 = "";
        //string strJSOriginal = match.Value["group2_value"];
        //string scriptRes = "<script " + match["group1_value"] + ">" + nvSecurity.nvCrypto.JSToJSOfuscated(strJSOriginal, "js_in_html") + "</script>";
        //contentInBuffer = contentInBuffer.Replace(match.Value("group0_value"), scriptRes);
    }
%>