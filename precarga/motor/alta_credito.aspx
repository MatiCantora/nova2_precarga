<%@ Page Language="C#" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageFW" %>

<%@ Import Namespace="nvFW" %>
<%

    nvFW.tError err = new nvFW.tError();
    try
    {

        bool noti_prov = false;
        if (nvUtiles.obtenerValor("noti_prov", "") == "true")
            noti_prov = true;

        int nro_credito = Int32.Parse(nvUtiles.obtenerValor("nro_credito", 0));

        int nro_archivo_noti_prov = Int32.Parse(nvUtiles.obtenerValor("nro_archivo_noti_prov", 0));
        string xmlpersona = nvUtiles.obtenerValor("xmlpersona", "");
        string xmltrabajo = nvUtiles.obtenerValor("xmltrabajo", "");
        string xmlcredito = nvUtiles.obtenerValor("xmlcredito", "");
        string xmlanalisis = nvUtiles.obtenerValor("xmlanalisis", "");
        string xmlcancelaciones = nvUtiles.obtenerValor("xmlcancelaciones", "");
        string xmlparametros = nvUtiles.obtenerValor("xmlparametros");
        string estado = nvUtiles.obtenerValor("estado");
        Dictionary<string, string> paramMotor = new Dictionary<string, string>();
        int evalua_motor = Int32.Parse(nvUtiles.obtenerValor("evalua_motor", 0));
        string xmlmotorparametros = nvUtiles.obtenerValor("xmlmotorparametros", "");
        string mensaje_usuario = nvUtiles.obtenerValor("mensaje_usuario", "");

        if (xmlmotorparametros != "")
        {
            System.Xml.XmlDocument motorXML = new System.Xml.XmlDocument(); ;
            motorXML.LoadXml(xmlmotorparametros);
            System.Xml.XmlNodeList XmlMotorNodeList;
            XmlMotorNodeList = motorXML.SelectNodes("/motor/parametro");
            if (XmlMotorNodeList != null)
            {
                foreach (System.Xml.XmlNode nodemotor in XmlMotorNodeList)
                {
                    string parametro = nodemotor.Attributes.GetNamedItem("nombre").Value;
                    string valor = nodemotor.Attributes.GetNamedItem("valor").Value;
                    paramMotor.Add(parametro, valor);
                }
            }
        }

        bool persona_existe = false;
        
        if (xmlpersona != "")
        {

            Dictionary<string, string> paramPersona = new Dictionary<string, string>();
            System.Xml.XmlDocument personaXML = new System.Xml.XmlDocument(); ;
            personaXML.LoadXml(xmlpersona);
            System.Xml.XmlNode nodePersona;
            nodePersona = personaXML.SelectSingleNode("/persona");
            if (nodePersona != null)
            {
                foreach (System.Xml.XmlAttribute attributePersona in nodePersona.Attributes)
                {
                    string parametro = attributePersona.Name;
                    string valor = attributePersona.Value;
                    paramPersona.Add(parametro, valor);
                }
            }

            ADODB.Recordset rsp = nvDBUtiles.DBOpenRecordset("SELECT COUNT(*) AS cant FROM verPersonas WHERE tipo_docu = " + paramPersona["tipo_docu"] + " and nro_docu = " + paramPersona["nro_docu"] + " AND sexo = '" + paramPersona["sexo"] + "'");
            if (!rsp.EOF)
            {
                persona_existe = Int32.Parse(rsp.Fields["cant"].Value.ToString()) == 0 ? false : true;
            }
            nvDBUtiles.DBCloseRecordset(rsp);
        }

        //Generar alta de credito
        nvFW.nvDBUtiles.tnvDBCommand cmd = new nvFW.nvDBUtiles.tnvDBCommand("rm_cr_solicitud_v11", ADODB.CommandTypeEnum.adCmdStoredProc);
        cmd.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito);
        cmd.addParameter("@persona_existe", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, persona_existe);
        cmd.addParameter("@noti_prov", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, noti_prov);
        cmd.addParameter("@nro_archivo_noti_prov", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_archivo_noti_prov);
        cmd.addParameter("@XMLpersona", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlpersona.Length, xmlpersona);
        cmd.addParameter("@XMLtrabajo", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmltrabajo.Length, xmltrabajo);
        cmd.addParameter("@XMLcredito", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcredito.Length, xmlcredito);
        cmd.addParameter("@XMLanalisis", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlanalisis.Length, xmlanalisis);
        cmd.addParameter("@XMLcancelaciones", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlcancelaciones.Length, xmlcancelaciones);
        cmd.addParameter("@XMLparametros", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, xmlparametros.Length, xmlparametros);
        ADODB.Recordset rs = cmd.Execute();
        nro_credito = Int32.Parse(rs.Fields["nro_credito"].Value.ToString());
        string modo1 = rs.Fields["modo"].Value.ToString();
        err.@params["nro_credito"] = nro_credito;
        err.@params["estado"] = estado;
        err.mensaje = rs.Fields["mensaje"].Value.ToString();
        err.numError = Int32.Parse(rs.Fields["numError"].Value.ToString());
        string estado_credito = rs.Fields["estado"].Value.ToString();
        nvDBUtiles.DBCloseRecordset(rs);

        //''indica que es un alta de credito (sino es una modificacion) y siempre y cuando el credito no sea prueba
        if (err.numError == 0 && modo1 == "A" && estado_credito != "X")
        {
            try
            {
                string strSql = "";
                string scu_id = "0";
                if (paramMotor.ContainsKey("scu_id"))
                {
                    scu_id = paramMotor["scu_id"].Trim() != "" ? paramMotor["scu_id"] : "0";
                }
                //''si evalua motor de cuad(va a generar consumo), y es una alta
                if (evalua_motor == 1 && modo1 == "A" && err.numError == 0)
                {
                    //''dentro del motor, el que decide es el motor 1538 cuad santa fe
                    //''decide si va por robot o no
                    if (scu_id != "0" && scu_id != "")
                    {
                        bool respondiocuad = true;
                        string comprobante_filiacion_64 = "";
                        string comprobante_consumo_64 = "";
                        string comprobante_screen_64 = "";
                        nvFW.tError errr = new nvFW.tError();
                        nvFW.servicios.Robots.wsCuad robot = new nvFW.servicios.Robots.wsCuad();
                        nvFW.servicios.Robots.wsCuad.wsCredencial credencial = new nvFW.servicios.Robots.wsCuad.wsCredencial();
                        string Usuario = nvUtiles.getParametroValor("CUAD_ROBOT_USERNAME", "WS_Nova01");
                        string Password = nvUtiles.getParametroValor("CUAD_ROBOT_PASSWORD", "WS_N0v41F");
                        credencial.usuario = Usuario;
                        credencial.pwd = Password;
                        robot.callback = nvFW.nvApp.getInstance().server_host_https + "/FW/servicios/ROBOTS/cuad_callback.aspx";
                        robot.timeoutconsumo = 1000 * 60 * 15; //''15 minutos;
                        string socio_nuevo = paramMotor["socio_nuevo"] == "1" ? "1" : "0";

                        string nro_docu = "";
                        string importe_cuota = "";
                        string cuotas = "";
                        string primer_venc = "";
                        string cat = "";
                        string tipo_lote = "";
                        string nro_mutual = "";

                        //obtener datos del credito
                        //gjmo -> estos datos no se tienen previamente? - exceptuando primer vencimiento?
                        strSql = "select nro_mutual,nro_docu,importe_cuota,cuotas," +
                                    "dbo.conv_fecha_to_str(dbo.rm_cuad_robot_primer_vencimiento(nro_credito," + paramMotor["scu_id"] + "),'yyyymm') as primer_venc" +
                                    ",tipo_lote from vercreditos where nro_credito=" + nro_credito.ToString() + " and estado <> 'X'";
                        ADODB.Recordset rs2 = nvDBUtiles.DBOpenRecordset(strSql);

                        if (!rs2.EOF)
                        {
                            nro_docu = rs2.Fields["nro_docu"].Value.ToString();
                            importe_cuota = rs2.Fields["importe_cuota"].Value.ToString();
                            cuotas = rs2.Fields["cuotas"].Value.ToString();
                            primer_venc = rs2.Fields["primer_venc"].Value.ToString();
                            tipo_lote = rs2.Fields["tipo_lote"].Value.ToString();
                            nro_mutual = rs2.Fields["nro_mutual"].Value.ToString();
                        }
                        nvDBUtiles.DBCloseRecordset(rs2);
                        string sce_id = ""; //''tipo de lote(activo o pasivo)
                        string scm_id = ""; //'' mutual de referencia en cuad
                        string ses_id = ""; //'' identificativo de tipo de servicio segun categoria de socio, mutual y tipo de lote

                        //gjmo -> estos datos no se tienen previamente?
                        strSql = "select categoria_socio,scm_id,sce_id,ses_id from verPiz_cuad_mutual_categorias_serv" +
                                    " where nro_mutual=" + nro_mutual + " and" +
                                    " tipo_lote='" + tipo_lote + "' and socio_nuevo= " + socio_nuevo + " and sce_id=" + paramMotor["sce_id"];

                        rs2 = nvDBUtiles.DBOpenRecordset(strSql);
                        if (!rs2.EOF && nro_docu != "")
                        {
                            cat = rs2.Fields["categoria_socio"].Value.ToString();
                            scm_id = rs2.Fields["scm_id"].Value.ToString();
                            sce_id = rs2.Fields["sce_id"].Value.ToString();
                            ses_id = rs2.Fields["ses_id"].Value.ToString();
                            //'Scu_Id: sistema cuad
                            //'Sce_Id:id del liquidador
                            //'Scm_id:id de la mutual al cual se consulta el cupo
                            //'ses_id: id del servicio a consumir (por lo general - prestamo personal) segun mutual - sistema cuad - lote
                            //'cat: categoria del socio segun mutual, lote y si es socio nuevo o no
                            string consumo_log_id = "";
                            //''AltaConsumoCredito(ByVal credencial As wsCredencial, ByVal parametrosrobot As Dictionary(Of String, String), ByVal parametroscredito As Dictionary(Of String, String))
                            Dictionary<string, string> parametrosrobot = new Dictionary<string, string>();
                            parametrosrobot["Scu_Id"] = scu_id;
                            parametrosrobot["Sce_Id"] = sce_id;
                            parametrosrobot["Scm_Id"] = scm_id;
                            parametrosrobot["Clave_Sueldo"] = paramMotor["clave_sueldo"];
                            parametrosrobot["Nro_Documento"] = nro_docu;
                            parametrosrobot["Prioridad"] = "1";
                            parametrosrobot["Ses_Id"] = ses_id;
                            parametrosrobot["Cuotas"] = cuotas;
                            parametrosrobot["Importe"] = importe_cuota;
                            parametrosrobot["Primer_Venc"] = primer_venc;
                            parametrosrobot["Categoria_Socio"] = cat;
                            parametrosrobot["Clave_Servicio"] = "";
                            parametrosrobot["Comentario"] = "";
                            Dictionary<string, string> parametroscredito = new Dictionary<string, string>();
                            parametroscredito["nro_credito"] = nro_credito.ToString();
                            parametroscredito["id_transf_log"] = paramMotor["id_transf_log"];
                            parametroscredito["estado"] = paramMotor["estado"];
                            parametroscredito["xmlmotorparametros"] = xmlmotorparametros;
                            //gjmo -> el timeout esta definido en 15 min?

                            //'' referencia 1
                            //''si desde el front, trae mensaje de usuario, lo guardo como comentario observador motivo,
                            //ya que luego de pedir el consumo, nose si cuad va a responder y nose si va a guardar comentario
                            if (mensaje_usuario != "")
                            {
                                //gjmo -> deberia usar el SP
                                strSql = "INSERT INTO com_registro ([tipo_docu], [nro_docu], [sexo], [nro_credito], [nro_com_tipo], [comentario], [operador], [fecha], [nro_com_estado], [operador_destino],";
                                strSql += " [nro_registro_depende], [nro_com_id_tipo], [id_tipo]) " + Environment.NewLine;
                                strSql += "Select tipo_docu,nro_docu,sexo,nro_credito,164 As nro_com_tipo,?,dbo.rm_nro_operador() as operador,getdate() as fecha,1,null,null,2 as nro_com_id_tipo,";
                                strSql += " nro_credito as id_tipo from vercreditos where nro_credito=" + nro_credito.ToString();
                                nvDBUtiles.tnvDBCommand cmd3 = new nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText);
                                mensaje_usuario = mensaje_usuario.Replace("|", "<br/>");
                                mensaje_usuario = mensaje_usuario.Replace("&lt;", "<").Replace("&gt;", ">"); //''esta transformacion de caracteres html viene desde el front
                                ADODB.Parameter parametersSql1 = cmd3.CreateParameter("@comentario", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, mensaje_usuario);
                                cmd3.Parameters.Append(parametersSql1);
                                cmd3.Execute();
                                mensaje_usuario = ""; //''seteo en vacio el mensaje para q siga el circuito pero recabando nuevos mensajes
                            }

                            errr = robot.AltaConsumoCredito(credencial: credencial, parametrosrobot: parametrosrobot, parametroscredito: parametroscredito);
                            if (errr.numError == 1000)
                            {
                                mensaje_usuario += "Carga en proceso. <br/>";
                                respondiocuad = false;
                            }
                            else
                            {
                                respondiocuad = true;
                            }
                            if (errr.@params.ContainsKey("log_id"))
                                consumo_log_id = errr.@params["log_id"].ToString();


                            //''si el consumo se hizo, paso el credito a estado presupuesto
                            if (errr.numError == 0 && respondiocuad)
                            {
                                //string logfiles = "p1;";
                                //cambiar estado credito
                                nvFW.nvDBUtiles.tnvDBCommand cmd4 = new nvFW.nvDBUtiles.tnvDBCommand("rm_credito_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc);
                                cmd4.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito);
                                //gjmo -> estado hardcodeado
                                cmd4.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 1, paramMotor["estado"] == "A" ? "M" : paramMotor["estado"]);
                                cmd4.addParameter("@GenerarCC", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, 0);
                                cmd4.Execute();

                                string codigo_consumo = errr.@params["codigo_consumo"].ToString();
                                comprobante_filiacion_64 = errr.@params.ContainsKey("comprobante_filiacion_64") ? errr.@params["comprobante_filiacion_64"].ToString() : "";
                                comprobante_consumo_64 = errr.@params.ContainsKey("comprobante_consumo_64") ? errr.@params["comprobante_consumo_64"].ToString() : ""; //''errr.params("comprobante_consumo_64")
                                comprobante_screen_64 = errr.@params.ContainsKey("comprobante_screen") ? errr.@params["comprobante_screen"].ToString() : ""; //''errr.params("comprobante_screen")

                                //actualizar detalle sueldo                                                                                                             //''actualizo los valores de los analisis
                                strSql = "update Detalle_Sueldo set valor='" + importe_cuota + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=493" + Environment.NewLine; //''actualizo cuota afectada
                                strSql += "update Detalle_Sueldo set valor='" + codigo_consumo + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=356" + Environment.NewLine; //& vbCrLf ''actualizo codigo cuad de consumo

                                if (errr.@params.ContainsKey("bruto") && errr.@params["bruto"].ToString() != "")
                                    strSql += "update Detalle_Sueldo set monto='" + errr.@params["bruto"].ToString() + "', valor='" + errr.@params["bruto"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta in(0,526) " + Environment.NewLine; //& vbCrLf ''actualizo importe bruto en analisis

                                if (errr.@params.ContainsKey("neto") && errr.@params["neto"].ToString() != "")
                                    strSql += "update Detalle_Sueldo set  monto='" + errr.@params["neto"].ToString() + "', valor='" + errr.@params["neto"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=385" + Environment.NewLine; //''actualizo neto

                                if (errr.@params.ContainsKey("afectable") && errr.@params["afectable"].ToString() != "")
                                    strSql += "update Detalle_Sueldo set monto='" + errr.@params["afectable"].ToString() + "', valor='" + errr.@params["afectable"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=167" + Environment.NewLine; //''actualizo afectable

                                //''cupo antes de realizar el consumo
                                if (errr.@params.ContainsKey("cupo") && errr.@params["cupo"].ToString() != "")
                                    strSql += "update Detalle_Sueldo set  monto='" + errr.@params["cupo"].ToString() + "', valor='" + errr.@params["cupo"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=523" + Environment.NewLine; //''actualizo cupo total

                                //''afectado antes de realizar el consumo
                                if (errr.@params.ContainsKey("afectado") && errr.@params["afectado"].ToString() != "")
                                    strSql += "update Detalle_Sueldo set monto='" + errr.@params["afectado"].ToString() + "', valor='" + errr.@params["afectado"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=524" + Environment.NewLine; //''Afectado Teorico

                                nvFW.nvDBUtiles.DBExecute(strSql);
                                try
                                {
                                    nvFW.nvDBUtiles.DBExecute("exec dbo.rm_ajustar_analisis_calculados2 " + nro_credito.ToString());
                                }
                                catch (Exception exAnalisis)
                                {
                                    err.debug_desc = "Error al actualizar analisis " + exAnalisis.Message;
                                }

                            }

                            //''si el mensaje o error, no es de time out del cuad, y es otro mensajes del cuad, como ser CUPO INSUFICIENTE, lo muestro a pantalla y lo paso a consumo rechazado
                            if (errr.numError != 1000 && errr.numError != 0)
                            {
                                err.numError = 0; //'errr.numError
                                err.mensaje = errr.mensaje;
                                mensaje_usuario += " consumo rechazado " + err.mensaje;
                                err.debug_desc = "id log consumo :" + consumo_log_id + " detalle terror: " + errr.numError.ToString() + " - " + errr.mensaje + " - " + errr.debug_desc;
                                nvFW.nvDBUtiles.tnvDBCommand cmd4 = new nvFW.nvDBUtiles.tnvDBCommand("rm_credito_cambiar_estado", ADODB.CommandTypeEnum.adCmdStoredProc);
                                cmd4.addParameter("@nro_credito", ADODB.DataTypeEnum.adInteger, ADODB.ParameterDirectionEnum.adParamInput, 1, nro_credito);
                                cmd4.addParameter("@estado", ADODB.DataTypeEnum.adVarChar, ADODB.ParameterDirectionEnum.adParamInput, 1, "7");
                                cmd4.addParameter("@GenerarCC", ADODB.DataTypeEnum.adBoolean, ADODB.ParameterDirectionEnum.adParamInput, 1, 0);
                                cmd4.Execute();
                            }
                        }
                        else
                        {
                            err.numError = 0; //'100
                            err.mensaje = "No se pudo generar el consumo. No se encontraron configuraciones necesarias para el alta del consumo. Notifiquelo";
                            err.debug_desc = "No se encontraron asociaciones fundamentales en las pizzarras para con el socio";
                        }
                        nvDBUtiles.DBCloseRecordset(rs2);

                        //''ejecuto la transferencia para que siga generando los archivos faltantes(asincrono) y tmb los demas archivos
                        System.Threading.Thread async_thread = new System.Threading.Thread((object obj) =>
                        {

                            Dictionary<string, object> psp = (Dictionary<string, object>)obj;
                            nvFW.servicios.nvProcesamiento nvFile = new nvFW.servicios.nvProcesamiento();
                            nvFW.nvApp._nvApp_ThreadStatic = (tnvApp)psp["nvApp"];
                            nvFW.nvPDF _pdf = new nvFW.nvPDF();

                            nvFW.servicios.Robots.wsCuad robot2 = new nvFW.servicios.Robots.wsCuad();

                            string comprobante_filiacion_642 = psp["comprobante_filiacion_64"].ToString();
                            string comprobante_consumo_642 = psp["comprobante_consumo_64"].ToString();
                            string comprobante_screen_642 = psp["comprobante_screen_64"].ToString();

                            string nro_def_archivo = "";

                            byte[] bytes = null;

                            string strSQL_def_archivo = "declare @nro_def_archivo int" + Environment.NewLine;
                            strSQL_def_archivo += "select @nro_def_archivo = nro_def_archivo  from vercreditos where nro_credito = " + psp["nro_credito"].ToString() + Environment.NewLine;
                            strSQL_def_archivo += "insert into archivo_leg_cab (nro_archivo_id_tipo, id_tipo, nro_def_archivo) values (2, " + psp["nro_credito"].ToString() + ", @nro_def_archivo)" + Environment.NewLine;
                            strSQL_def_archivo += "select @nro_def_archivo as nro_def_archivo";

                            ADODB.Recordset rs_def_archivo = nvFW.nvDBUtiles.DBExecute(strSQL_def_archivo);
                            if (!rs_def_archivo.EOF)
                            {
                                nro_def_archivo = rs_def_archivo.Fields["nro_def_archivo"].Value.ToString();
                            }
                            nvFW.nvDBUtiles.DBCloseRecordset(rs_def_archivo);

                            //''comprobante de filiacion
                            if (comprobante_filiacion_642 != "")
                            {

                                //gjmo -> addfilelegajo deberia usar la estructura de archivos de FW
                                bytes = robot2.getPdf(comprobante_filiacion_642);
                                //nvFile.addfilelegajo(binary: bytes, nro_credito: psp["nro_credito"].ToString(), nro_archivo_def_tipo: "46", cod_sistema: "nv_mutual"); //'' adjunto cad de cuota social(alta como socio);
                                nvFile.addfilelegajo2(bytes, nro_credito.ToString(), "2", nro_def_archivo, "1453");
                            }
                            //''cad de consumo
                            if (comprobante_consumo_642 != "")
                            {
                                bytes = robot2.getPdf(comprobante_consumo_642);
                                //nvFile.addfilelegajo(binary: bytes, nro_credito: psp["nro_credito"].ToString(), nro_archivo_def_tipo: "2", cod_sistema: "nv_mutual"); //'' adjunto cad de prestacion al legajo
                                nvFile.addfilelegajo2(bytes, nro_credito.ToString(), "2", nro_def_archivo, "1454");
                            }
                            //''captura(png)
                            if (comprobante_screen_642 != "")
                            {

                                bytes = robot2.parseBytes(comprobante_screen_642);
                                try
                                {
                                    //''si es imagen, esto va a reventar, sino, es pdf
                                    bytes = _pdf.ImageToPDF(bytes);
                                }
                                catch (Exception exThread)
                                {

                                }
                                //nvFile.addfilelegajo(binary: bytes, nro_credito: nro_credito.ToString(), nro_archivo_def_tipo: "118", cod_sistema: "nv_mutual"); //'' adjunto captura del cuad
                                nvFile.addfilelegajo2(bytes, nro_credito.ToString(), "2", nro_def_archivo, "4542");
                            }

                            //''adjunta NOSIS
                            nvFW.nvTransferencia.tTransfererncia tTransferencia = new nvFW.nvTransferencia.tTransfererncia();
                            try
                            {
                                tTransferencia.cargar(1567);
                                tTransferencia.param["nro_credito"]["valor"] = psp["nro_credito"];
                                tTransferencia.param["id_consulta"]["valor"] = psp["id_consulta"];
                                tTransferencia.ejecutar();
                            }
                            catch (Exception exThread)
                            {

                            }
                        });

                        Dictionary<string, object> ps = new Dictionary<string, object>();
                        ps.Add("nvApp", nvApp);
                        ps.Add("nro_credito", nro_credito);
                        ps.Add("id_consulta", paramMotor["nosis_id_consulta"]);
                        ps.Add("comprobante_filiacion_64", comprobante_filiacion_64);
                        ps.Add("comprobante_consumo_64", comprobante_consumo_64);
                        ps.Add("comprobante_screen_64", comprobante_screen_64);
                        async_thread.Start(ps);

                    }
                    else
                    {
                        strSql = "INSERT INTO CUAD_motor_calificacion ([id_transf_log],[nro_credito],[estado],[fecha],[nro_operador],[xml])" +
                                    " VALUES (" + paramMotor["id_transf_log"] + "," + nro_credito.ToString() + ",'" + paramMotor["estado"] + "',getdate(),dbo.rm_nro_operador(),?)" + Environment.NewLine;
                        strSql += "select @@identity as id ";
                        cmd = new nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText);
                        ADODB.Parameter parametersSql = cmd.CreateParameter("@xml", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, xmlmotorparametros);
                        cmd.Parameters.Append(parametersSql);
                        cmd.Execute();
                    }//'' si existe scu_id, va por robot cuad, sino, la calificacion, va a depender del motor de desicion

                    if (err.mensaje != "")
                        mensaje_usuario += mensaje_usuario != "" ? "<br/>" + err.mensaje : err.mensaje;
                }
                else
                {
                    //''para casos que no vayan al motor
                    if (paramMotor.ContainsKey("id_transf_log") && paramMotor.ContainsKey("estado"))
                    {
                        strSql = "INSERT INTO [dbo].[CUAD_motor_calificacion]([id_transf_log],[nro_credito],[estado],[fecha],[nro_operador],[xml]) VALUES ";
                        strSql += "(" + paramMotor["id_transf_log"] + "," + nro_credito.ToString() + ",'" + paramMotor["estado"] + "',getdate(),dbo.rm_nro_operador(),?)" + Environment.NewLine;
                        strSql += "select @@identity as id ";
                        cmd = new nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText);
                        ADODB.Parameter parametersSql = cmd.CreateParameter("@xml", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, xmlmotorparametros);
                        cmd.Parameters.Append(parametersSql);
                        cmd.Execute();
                    }
                }

                //'busco una captura del cuad para los casos que tienen cancelaciones
                if (paramMotor["cancelaciones"] != "0" && scu_id != "0")
                {
                    nvFW.tError errr = new nvFW.tError();
                    Byte[] bytes = null;
                    string nro_mutual = "";
                    string tipo_lote = "";
                    string socio_nuevo = "0";
                    nvFW.servicios.Robots.wsCuad robot = new nvFW.servicios.Robots.wsCuad();
                    nvFW.servicios.Robots.wsCuad.wsCredencial credencial = new nvFW.servicios.Robots.wsCuad.wsCredencial();
                    string Usuario = nvUtiles.getParametroValor("CUAD_ROBOT_USERNAME", "WS_Nova01");
                    string Password = nvUtiles.getParametroValor("CUAD_ROBOT_PASSWORD", "WS_N0v41F");
                    credencial.usuario = Usuario;
                    credencial.pwd = Password;
                    robot.callback = nvFW.nvApp.getInstance().server_host_https + "/FW/servicios/ROBOTS/cuad_callback.aspx";

                    //''Dim scu_id As String = paramMotor("scu_id") ''identificativo de sistema cuad
                    string sce_id = ""; //''tipo de lote(activo o pasivo)
                    string scm_id = ""; //'' mutual de referencia en cuad

                    rs = nvDBUtiles.DBOpenRecordset("select nro_mutual,tipo_lote from vercreditos where nro_credito=" + nro_credito.ToString());
                    nro_mutual = rs.Fields["nro_mutual"].Value.ToString();
                    tipo_lote = rs.Fields["tipo_lote"].Value.ToString();
                    strSql = "select categoria_socio,scm_id,sce_id,ses_id from verPiz_cuad_mutual_categorias_serv" +
                        " where nro_mutual=" + nro_mutual + " and tipo_lote='" + tipo_lote + "' and socio_nuevo= " + socio_nuevo + " and scu_id=" + scu_id;
                    rs = nvDBUtiles.DBOpenRecordset(strSql);
                    scm_id = rs.Fields["scm_id"].Value.ToString();
                    sce_id = rs.Fields["sce_id"].Value.ToString();
                    nvDBUtiles.DBCloseRecordset(rs);
                    errr = robot.GetCupoScreen(credencial: credencial, Scu_Id: Int32.Parse(scu_id), Sce_Id: Int32.Parse(sce_id), Scm_Id: Int32.Parse(scm_id), clave_sueldo: paramMotor["clave_sueldo"], prioridad: 1);
                    if (errr.numError == 0)
                    {
                        bytes = robot.parseBytes(errr.@params["comprobante_screen"].ToString());
                        try
                        {
                            strSql = "";
                            //''cupo antes de realizar el consumo -ETIQUETA CUPO TOTAL
                            if (errr.@params.ContainsKey("cupo_total") && errr.@params["cupo_total"].ToString() != "")
                            {
                                strSql += "update Detalle_Sueldo set valor='" + errr.@params["cupo_total"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=523" + Environment.NewLine; //''actualizo cupo total
                            }
                            //''afectado antes de realizar el consumo -ETIQUETA AFECTADO TEORICO
                            if (errr.@params.ContainsKey("afectado") && errr.@params["afectado"].ToString() != "")
                            {
                                strSql += "update Detalle_Sueldo set valor='" + errr.@params["afectado"].ToString() + "' where nro_credito=" + nro_credito.ToString() + " and nro_etiqueta=524" + Environment.NewLine; //''Afectado Teorico
                            }
                            if (strSql != "")
                                nvFW.nvDBUtiles.DBExecute(strSql);
                            try
                            {
                                nvFW.nvDBUtiles.DBExecute("exec dbo.rm_ajustar_analisis_calculados2 " + nro_credito.ToString() + ",'10,53,42,41,525'");
                            }
                            catch (Exception ex)
                            {
                                err.debug_desc = "Error al actualizar analisis " + ex.Message;
                            }
                            nvFW.nvPDF _pdf = new nvFW.nvPDF();
                            //''si es imagen, esto va a reventar, sino, es pdf
                            bytes = _pdf.ImageToPDF(bytes);

                            nvFW.servicios.nvProcesamiento nvFile = new nvFW.servicios.nvProcesamiento();
                            nvFile.addfilelegajo(binary: bytes, nro_credito: nro_credito.ToString(), nro_archivo_def_tipo: "118", cod_sistema: "nv_mutual"); //'' adjunto screen
                            bytes = null;
                            _pdf = null;
                            nvFile = null;
                        }
                        catch (Exception ex) { }
                    }
                }

                //''si desde el front, trae mensaje de usuario(que no se guardo antes de realizar consumo cuad - ver referencia 1), lo guardo como comentario observador motivo, como asi tambien si el motor de cuad, trajo algo
                if (mensaje_usuario != "")
                {
                    //gjmo -> deberia usar SP comentario
                    strSql = "INSERT INTO com_registro ([tipo_docu], [nro_docu], [sexo], [nro_credito], [nro_com_tipo], [comentario], [operador]," +
                                " [fecha], [nro_com_estado], [operador_destino], [nro_registro_depende], [nro_com_id_tipo], [id_tipo])" + Environment.NewLine;
                    strSql += "Select tipo_docu,nro_docu,sexo,nro_credito,164 As nro_com_tipo,?,dbo.rm_nro_operador() as operador,getdate() as fecha," +
                                "1,null,null,2 as nro_com_id_tipo, nro_credito as id_tipo from vercreditos where nro_credito=" + nro_credito.ToString();
                    nvDBUtiles.tnvDBCommand cmd3 = new nvDBUtiles.tnvDBCommand(strSql, ADODB.CommandTypeEnum.adCmdText);
                    mensaje_usuario = mensaje_usuario.Replace("|", "<br/>");
                    mensaje_usuario = mensaje_usuario.Replace("&lt;", "<").Replace("&gt;", ">"); //''esta transformacion de caracteres html viene desde el front
                    ADODB.Parameter parametersSql1 = cmd3.CreateParameter("@comentario", ADODB.DataTypeEnum.adLongVarChar, ADODB.ParameterDirectionEnum.adParamInput, -1, mensaje_usuario);
                    cmd3.Parameters.Append(parametersSql1);
                    cmd3.Execute();
                }
            }
            catch (Exception ex)
            {
                err.parse_error_script(ex);
            }
        }


    }
    catch (Exception ex)
    {
        err.parse_error_script(ex);
    }

response_error:
    err.response();

%>