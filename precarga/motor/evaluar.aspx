<%@ Page Language="C#" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>
<%@ Import Namespace="nvFW" %>
<%

    //System.Diagnostics.Debugger.Break;
    //string path = "d:\\nova2\\eliminar\\oferta.xml";
    //System.IO.FileStream ms = new System.IO.FileStream(path,System.IO.FileMode.Open);

    //ms.CopyTo(Response.OutputStream);

    //Response.End();


    string criterio = nvUtiles.obtenerValor("criterio", "");
    System.Xml.XmlDocument XML;
    var Err = new tError();

    int id_transferencia = 1537;
    //string usa_cuad_robot = "0";
    XML = new System.Xml.XmlDocument();
    try
    {
        XML.LoadXml(criterio);
    }
    catch(System.Xml.XmlException e1)
    {
        Err.parse_error_xml(e1);
        Err.titulo = "Error al realizar la evaluación";
        Err.mensaje = "No se pudo calcular la oferta. Intente nuevamente.";
    }
    catch(Exception e2)
    {
        Err.parse_error_script(e2);
        Err.titulo = "Error al realizar la evaluación";
        Err.mensaje = "No se pudo calcular la oferta. Intente nuevamente.";
    }

    string cupo_premotor = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor", "");
    string cuit = nvXMLUtiles.getNodeText(XML, "criterio/cuit", "0");
    string nro_grupo = nvXMLUtiles.getNodeText(XML, "criterio/nro_grupo", "0");
    string clave_sueldo = nvXMLUtiles.getNodeText(XML, "criterio/clave_sueldo", "");
    int nro_tipo_cobro = int.Parse(nvXMLUtiles.getNodeText(XML, "criterio/nro_tipo_cobro", "0"));
    int nro_vendedor = int.Parse(nvXMLUtiles.getNodeText(XML, "criterio/nro_vendedor", "0"));
    int nro_banco_debito = int.Parse(nvXMLUtiles.getNodeText(XML, "criterio/nro_banco", "0"));
    int sce_id = int.Parse(nvXMLUtiles.getNodeText(XML, "criterio/sce_id", "0"));
    var tTransferencia = new nvFW.nvTransferencia.tTransfererncia();
    try
    {
        tTransferencia.cargar(id_transferencia);
        tTransferencia.param["cuil"]["valor"] = cuit;
        tTransferencia.param["nro_grupo"]["valor"] = nro_grupo;
        tTransferencia.param["clave_sueldo"]["valor"] = clave_sueldo;
        tTransferencia.param["nro_tipo_cobro"]["valor"] = nro_tipo_cobro;
        tTransferencia.param["nro_vendedor"]["valor"] = nro_vendedor;
        tTransferencia.param["nro_banco_debito"]["valor"] = nro_banco_debito;
        tTransferencia.param["cod_servidor"]["valor"] = nvApp.cod_servidor;


        if (!string.IsNullOrEmpty(cupo_premotor))
        {
            tTransferencia.param["cupo_disponible"]["valor"] = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_disponible", "");
            tTransferencia.param["cupo_iplyc"]["valor"] = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_iplyc", "");
            tTransferencia.param["cupo_chacra"]["valor"] = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/cupo_chacra", "");
            tTransferencia.param["Scu_Id"]["valor"] = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scu_id", "");
            tTransferencia.param["Scm_Id"]["valor"] = nvXMLUtiles.getNodeText(XML, "criterio/cupo_premotor/scm_id", "");
        }
        tTransferencia.param["Sce_Id"]["valor"] = sce_id;


        tTransferencia.ejecutar();
    }

    catch (Exception ex)
    {
        Err.parse_error_script(ex);
        Err.mensaje = "No se pudo calcular la oferta. Intente nuevamente.";
    }

    //Generar el resumen
    tError errResume = tTransferencia.getErrorResumen_xml(true);

    errResume.response();

%>