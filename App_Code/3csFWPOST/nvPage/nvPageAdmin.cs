using Microsoft.VisualBasic;
using System.Collections.Generic;
using System;
using nvFW;
using nvFW.nvPages;
using System.Linq;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;

namespace nvFW
{
    namespace nvPages
    {
        public class nvPageAdmin : nvPageBase
        {
            private string _classname = "nvPageAdmin";
            private string _app_cod_sistema = "nv_admin";
            private string _app_sistema = "Nova Administrador";
            private string _app_path_rel = "admin";


            protected override void Page_Load(object sender, System.EventArgs e)
            {
                base.Page_Load(sender, e);
            }

           public nvPageAdmin()
            {
                //System.Diagnostics.Debugger.Break();
                base.setAPP(_app_cod_sistema, _app_sistema, _app_path_rel);
                this.Load += new System.EventHandler(this.Page_Load);
            }


            public tnvOperadorAdmin operadorAdmin
            {
                get { return (tnvOperadorAdmin)base.operador; }
            }


            public override tError app_config()
            {
                tError res = base.app_config();
                if (res.numError == 0)
                {
                    try
                    {
                        tnvOperadorAdmin operador = new tnvOperadorAdmin((nvSecurity.tnvOperador)nvApp.operador);
                        operador.load(operador.operador);
                        nvApp.operador = operador;
                    }
                    catch (Exception ex)
                    {
                        nvApp.appState = enumnvAppState.not_loaded;
                        res.parse_error_script(ex);
                        res.titulo = "";
                        res.debug_src = "nvPageAdmin::app_config()";
                    }
                }
                return res;
            }
            public override string getHeadInit()
            {
                Dictionary<string, bool> includes = new Dictionary<string, bool>() ;
return getHeadInit(ref includes);
            }

            public override string getHeadInit(ref Dictionary<string, bool> includes )
            {
                string retHTML = base.getHeadInit(ref includes);
                string retScript = "";
                // //Carga los permisos al browser
                // Dim nvApp As tnvApp = nvFW.nvApp.getInstance() ' nvSession.Contents("nvApp")
                tnvOperadorAdmin operador = (tnvOperadorAdmin)nvApp.operador;
                string permiso_grupo;

                if (includes == null)
                    includes = new Dictionary<string, bool>();

                if (!includes.ContainsKey("permisos"))
                    includes.Add("permisos", false);
                if (!includes.ContainsKey("URL_BASE"))
                    includes.Add("URL_BASE", false);
                if (!includes.ContainsKey("general"))
                    includes.Add("general", true);
                // If Not includes.Keys.Contains("utiles.js") Then includes.Add("utiles.js", True)
                // If Not includes.Keys.Contains("imagenes_icons.js") Then includes.Add("imagenes_icons.js", True)

                if (includes["permisos"])
                {
                    operador.cargarPermisos();
                    foreach (string permiso_grupo2 in operador.permiso_grupo.Keys )
                        retScript += "var " + permiso_grupo2 + " = " + operador.permiso_grupo[permiso_grupo2] + ";\r\n";
                    retScript += "\r\n";
                }

                if (includes["URL_BASE"])
                    retScript += "var URL_BASE = '" + nvApp.server_path + "/" + _app_path_rel + "/';\r\n\r\n";

                if (includes["general"])
                {
                    retScript += "var nro_operador = '" + operador.operador + "';\r\n";
                    retScript += "var login = '" + operador.login + "';\r\n";
                    retScript += "var sucursal_defecto = '" + operador.datos["nro_sucursal"].value + "';\r\n";
                    retScript += "var app_cod_sistema = '" + nvApp.cod_sistema + "';\r\n";
                    retScript += "var cfg_server_name = '" + nvApp.server_name + "';\r\n";
                    retScript += "var UID = '" + operador.login + "';\r\n";
                }

                if (retScript != "")
                    retScript = "<script  type='text/javascript' language='javascript' id='nvPageAdmin_HeadInit' name='nvPageAdmin_HeadInit'>\r\n" + retScript + "</script>\r\n";


                return retHTML + "\r\n" + retScript;
            }
        }

        
[Serializable()]
        public class tnvOperadorAdmin : nvSecurity.tnvOperador
        {
            public tnvOperadorAdmin() : this(null/* TODO Change to default(_) if this is not a reference type */)
            {
            }
            public tnvOperadorAdmin(nvSecurity.tnvOperador orOpe) : base(orOpe)
            {
            }

            public override tError save()
            {
                tError err = base.save();
                if (err.numError == 0)
                {
                    // update de la sucursal
                    string strSQL = "Update operadores set nro_sucursal = " + this.datos["nro_sucursal"].value + " where operador = " + this.operador;
                    nvDBUtiles.DBExecute(strSQL);
                }
                return err;
            }

            public override bool load(string login)
            {
                bool res = true;
                if (this.operador == 0)
                    res = base.load(login);

                return res;
            }

            public override bool load(int operador)
            {
                bool res = true;
                if (this.operador == 0)
                    res = base.load(operador);

                if (res)
                {
                    string strSQL = "Select nro_sucursal from operadores where operador = " + operador;
                    ADODB.Recordset rs = nvDBUtiles.DBOpenRecordset(strSQL);
                    nvSecurity.tnvOperadorDato dato = new nvSecurity.tnvOperadorDato();
                    dato.name = "nro_sucursal";
                    dato.label = "Nro de sucursal";
                    dato.campo_def = "nro_sucursal";
                    dato.value = rs.Fields["nro_sucursal"].Value.ToString();
                    this.datos.Add("nro_sucursal", dato);
                    nvDBUtiles.DBCloseRecordset(rs);
                }
                return res;
            }
        }


    }
}

/*



Namespace nvFW
    Namespace nvPages
    

        <Serializable()>
        Public Class tnvOperadorAdmin
            Inherits nvSecurity.tnvOperador

            Public Sub New()
                Me.New(Nothing)
            End Sub
            Public Sub New(orOpe As nvSecurity.tnvOperador)
                MyBase.New(orOpe)
            End Sub

            Public Overrides Function save() As tError
                Dim err As tError = MyBase.save()
                If err.numError = 0 Then
                    'update de la sucursal
                    Dim strSQL As String = "Update operadores set nro_sucursal = " & Me.datos("nro_sucursal").value & " where operador = " & Me.operador
                    nvDBUtiles.DBExecute(strSQL)
                End If
                Return err
            End Function

            Public Overrides Function load(login As String) As Boolean
                Dim res As Boolean = True
                If Me.operador = 0 Then res = MyBase.load(login)

                Return res
            End Function

            Public Overrides Function load(operador As Integer) As Boolean

                Dim res As Boolean = True
                If Me.operador = 0 Then res = MyBase.load(operador)

                If res Then
                    Dim strSQL As String = "Select nro_sucursal from operadores where operador = " & operador
                    Dim rs As ADODB.Recordset = nvDBUtiles.DBOpenRecordset(strSQL)
                    Dim dato As New nvSecurity.tnvOperadorDato
                    dato.name = "nro_sucursal"
                    dato.label = "Nro de sucursal"
                    dato.campo_def = "nro_sucursal"
                    dato.value = rs.Fields("nro_sucursal").Value
                    Me.datos.Add("nro_sucursal", dato)
                    nvDBUtiles.DBCloseRecordset(rs)
                End If
                Return res

            End Function

        End Class

    End Namespace
End Namespace

*/