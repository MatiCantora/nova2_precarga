using Microsoft.VisualBasic;
using System.Collections.Generic;
using System;
using System.Web;
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
using System.Runtime.InteropServices;
using System.Net.Sockets;
//using static System.Net.Mime.MediaTypeNames;

namespace nvFW
{
    namespace nvPages
    {

        public class nvPageFW : nvFW.nvPages.nvPageBase
        {
            public const string classname = "nvPageFW";

            public nvPageFW()
            {
                //System.Diagnostics.Debugger.Break();
                this.Load += new System.EventHandler(this.Page_Load);
            }

            protected virtual void Page_Load(object sender, System.EventArgs e)
            {
                nvApp = nvFW.nvApp.getInstance();
                //System.Diagnostics.Debugger.Break();
                //base.Page_Load(sender, e);
                //nvApp = nvFW.nvApp.get_getInstance();
                //_pageID_max += 1;
                //pageID = Session.SessionID + "::" + _pageID_max;
                this.app_acces_control();
                System.Web.HttpContext.Current.Response.Expires = 0;
            }


            public virtual void app_acces_control()
            {
                // ***************************************************************************************
                // Controlar que no haya habido ningún problema al inicio de la aplicación
                // ***************************************************************************************
                if (nvServer.start_error != null)
                {
                    tError err = nvServer.start_error;
                    err.response();
                    return;
                }

                // ***************************************************************************************
                // Si ya está autorizado no hace falta volver a controlar
                // autorizado = 1
                // autorizado_solo_interfaces = 2
                // ***************************************************************************************
                nvFW.nvSecurity.tnvOperador nvAPP_operador = null;
                if (nvApp != null && nvApp.operador != null)
                {
                    nvAPP_operador = (nvSecurity.tnvOperador)nvApp.operador;
                    if (nvAPP_operador.AutLevel == nvSecurity.enumnvAutLevel.autorizado)
                    {
                        return;
                    }
                }
                

                // ***************************************************************************************
                // Controlar que ingrese por el protocolo seguro https si esta configurado de esa manera
                // En caso contrario mandarlo a la misma URL pero en HTTPS
                // ***************************************************************************************
                var HTTPS = Request.ServerVariables["HTTPS"];
                string QueryString = "";
                string URL = Request.ServerVariables["URL"];

                if (Request.QueryString.ToString().Length > 0)
                    QueryString = Request.QueryString.ToString();

                if (nvServer.onlyHTTPS && HTTPS.ToLower() != "on")
                {
                    tError e = new tError();
                    e.numError = 1003;
                    e.titulo = "Error de acceso a la aplicación";
                    e.mensaje = "Solo puede accederse por protocolo HTTPS";
                    e.response();
                }

                // ****************************************************
                // Controlar esté logueado al sistema
                // Puede no estar logueado y venir un HASH de login
                // O puede no estar logueado y venir usuario y contraseña
                // Si no viene ninguno de los anteriores enviarlo a la pantalla de login
                // ****************************************************

                string app_cod_sistema = nvUtiles.obtenerValor("app_cod_sistema", "");

                if (app_cod_sistema == "")
                {
                    string @as = nvUtiles.obtenerValor("as", "");
                    try
                    {
                        app_cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String(@as));
                    }
                    catch (Exception ex)
                    {
                    }
                }
               
                if (nvAPP_operador.AutLevel == nvSecurity.enumnvAutLevel.no_logeado)
                {
                    // ****************************************************
                    // Controlar esté logueado al sistema
                    // Si viene un hash procesarlo
                    // ****************************************************
                    string nv_hash = nvFW.nvUtiles.obtenerValor("nv_hash", "");
                    // Dim app_cod_sistema As String = nvFW.nvUtiles.obtenerValor("app_cod_sistema", "")
                    // Dim [as] As String = nvFW.nvUtiles.obtenerValor("as", "")
                    // If [as] <> "" Then
                    // app_cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String([as]))
                    // End If

                    if (nvAPP_operador.AutLevel == nvSecurity.enumnvAutLevel.no_logeado && nv_hash != "" && app_cod_sistema != "")
                    {
                        // *************************************************************
                        // Procesar el hash
                        // *************************************************************
                        if (nvApp.cod_sistema == "")
                            nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema);

                        tError HashError = nvLogin.execute(nvApp, "login", "", "", "", "", nv_hash, "");

                        if (HashError.numError != 0)
                        {
                            HashError.response();
                            // HashError.salida_tipo = "adjunto"
                            // HashError.mostrar_error()
                            return;
                        }
                    }


                    // *************************************************************
                    // Procesar JWT
                    // **************************************************************
                    if (nvAPP_operador.AutLevel == nvSecurity.enumnvAutLevel.no_logeado & Request.Headers["Authorization"] != null/* TODO Change to default(_) if this is not a reference type */ )
                    {

                        // If Request.FilePath.ToLower().IndexOf("/ids/ids_client_token.aspx") <> 0 Then

                        string strAuthorization = Request.Headers["Authorization"];
                        string strJWT = "";
                        if (strAuthorization.Substring(0, 7).ToLower() == "bearer " && strAuthorization.Split('.').Length == 3)
                            strJWT = strAuthorization.Substring(7);

                        if (strJWT != "" && nvSession.Contents["_JWT"] != strJWT)
                        {
                            tError LoginError = nvLogin.execute(nvApp, "login", "", "", "", "", strJWT, "");
                            if (LoginError.numError != 0)
                            {
                                LoginError.response();
                                // LoginError.salida_tipo = "adjunto"
                                // LoginError.mostrar_error()
                                return;
                            }
                            nvSession.Contents["_JWT"] = strJWT;
                        }
                    }


                    // ****************************************************
                    // Controlar esté logueado al sistema
                    // Si viene un usuario y contraseña procesarlo o tiene un certificado cliente
                    // ****************************************************
                    string UID = nvFW.nvUtiles.obtenerValor("UID", "");
                    string PWD = nvFW.nvUtiles.obtenerValor("PWD", "");

                    if (nvApp.operador.AutLevel == nvSecurity.enumnvAutLevel.no_logeado && app_cod_sistema != "" && ((UID != "" && PWD != "") || HttpContext.Current.Request.ClientCertificate.Count > 0))
                    {
                        if (nvApp.cod_sistema == "")
                            nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema);

                        tError LoginError = nvLogin.execute(nvApp, "login", UID, PWD, "", "", "", "");

                        if (LoginError.numError != 0)
                        {
                            LoginError.response();
                            // LoginError.salida_tipo = "adjunto"
                            // LoginError.mostrar_error()
                            return;
                        }
                    }
                }


                // ****************************************************
                // Controlar que este configurada la aplicacion actual
                // Si nvApp.appState = enumnvAppState.not_loaded la palicacion no está configurada 
                // y nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.logeado el usuario esta logeado
                // Entonces configurar la aplicación
                // ****************************************************
                // Dim cod_sistema As String = nvUtiles.obtenerValor("app_cod_sistema", "")
                // If cod_sistema = "" Then
                // Dim [as] As String = nvUtiles.obtenerValor("as", "")
                // cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String([as]))
                // End If
                var path_rel = nvUtiles.obtenerValor("app_path_rel", "");

                if (nvApp.appState == enumnvAppState.not_loaded && nvApp.operador.AutLevel == nvSecurity.enumnvAutLevel.logeado && (app_cod_sistema != "" || path_rel != ""))
                {
                    object obj = nvServer.getNvPageInstance(app_cod_sistema);
                    if (obj != null)
                    {
                        Type type = obj.GetType();
                        MethodInfo methodinf = type.GetMethod("app_config");
                        tError err = (tError)methodinf.Invoke(obj, null);
                        //((nvPages.nvPageBase)obj).nvApp = nvApp;
                        //tError err = obj.app_config();

                        if (err.numError != 0)
                            err.response();
                    }
                }


                // ***************************************************************************************
                // Controlar que el usuario esté autorizado para acceder
                // ***************************************************************************************
                if (nvApp.operador.AutLevel != nvSecurity.enumnvAutLevel.autorizado && nvApp.operador.AutLevel != nvSecurity.enumnvAutLevel.autorizado_solo_interfaces)
                {
                    HttpContext.Current.Session.Abandon();
                    tError e = new tError();
                    e.numError = 1001;
                    e.titulo = "Error de acceso a la aplicación";
                    e.mensaje = "El usuario no tiene acceso a la aplicación";
                    e.response();
                }


                // ***************************************************************************************
                // Controlar que haya una aplicación activa
                // ***************************************************************************************
                if (nvApp.appState == enumnvAppState.not_loaded)
                {
                    tError e = new tError();
                    e.numError = 1002;
                    e.titulo = "Error de acceso a la aplicación";
                    e.mensaje = "No hay una aplicación activa";
                    e.response();
                }
            }


            //public void addPermisoGrupo(string permiso_grupo)
            //{
            //    nvSecurity.tnvOperador op = nvApp.operador;
            //    int valor = op.permisos(permiso_grupo);
            //    this.permiso_grupos.Remove(permiso_grupo);
            //    this.permiso_grupos.Add(permiso_grupo, valor);
            //}


            //public virtual string getHeadInit(Dictionary<string, bool> includes = null)
            //{
            //    string retScript = "";
            //    retScript += "var obj = window;\r\n" ;
            //    retScript += "if (!!nvFW)\r\n" ;
            //    retScript += "  obj = nvFW;\r\n" ;
            //    retScript += "obj.nvPageID = '" + pageID + "';\r\n\r\n";

            //    if (contents.Count > 0)
            //        retScript += " obj.pageContents = " + contents.toJSON() + ";\r\n\r\n";

            //    retScript += "obj.permiso_grupos = {};\r\n";

            //    foreach (string permiso_grupo in this.permiso_grupos.Keys)
            //        retScript += "obj.permiso_grupos['" + permiso_grupo + "'] = " + this.permiso_grupos[permiso_grupo] + ";\r\n" ;

            //    retScript = "<script type='text/javascript' id='nvPageFW_HeadInit' name='nvPageFW_HeadInit'>\r\n" + retScript + "</script>\r\n";

            //    return retScript;
            //}
        }

        
    }
}
/*
Imports nvFW.nvUtiles
Imports nvFW.nvDBUtiles

Namespace nvFW
    Namespace nvPages
        ''' <summary>
        ''' Clase base de todas las paginas de la aplicación
        ''' </summary>
        ''' <remarks></remarks>
        Public Class nvPageFW
            Inherits System.Web.UI.Page

            



            '*************************************************
            ' Propiedades
            '*************************************************
            ''' <summary>
            ''' Devuelve el nombre de la clase
            ''' </summary>
            ''' <value></value>
            ''' <returns></returns>
            ''' <remarks></remarks>
            Public ReadOnly Property classname As String
                Get
                    Return _classname
                End Get
            End Property

            Public ReadOnly Property app_cod_sistema As String
                Get
                    Return _app_cod_sistema
                End Get
            End Property

            Public ReadOnly Property app_sistema As String
                Get
                    Return _app_sistema
                End Get
            End Property

            Public ReadOnly Property app_path_rel As String
                Get
                    Return _app_path_rel
                End Get
            End Property


            '*************************************************
            ' Metodos
            '*************************************************
            Public Sub setAPP(ByVal app_cod_sistema As String, ByVal app_sistema As String, ByVal app_path_rel As String)
                _app_cod_sistema = app_cod_sistema
                _app_sistema = app_sistema
                _app_path_rel = app_path_rel
            End Sub


            Protected Overridable Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
                nvApp = nvFW.nvApp.getInstance
                _pageID_max += 1
                pageID = Session.SessionID & "::" & _pageID_max
                Me.app_acces_control()
                HttpContext.Current.Response.Expires = 0
            End Sub


            Public Overridable Sub app_acces_control()
                '***************************************************************************************
                ' Controlar que no haya habido ningún problema al inicio de la aplicación
                '***************************************************************************************
                If Not nvServer.start_error Is Nothing Then
                    Dim err As tError = nvServer.start_error
                    err.response()
                    Exit Sub
                End If

                '***************************************************************************************
                ' Controlar que ingrese por el protocolo seguro https si esta configurado de esa manera
                ' En caso contrario mandarlo a la misma URL pero en HTTPS
                '***************************************************************************************
                Dim HTTPS = Request.ServerVariables("HTTPS")
                Dim QueryString As String = ""
                Dim URL As String = Request.ServerVariables("URL")

                If Request.QueryString.ToString.Length > 0 Then
                    QueryString = Request.QueryString.ToString
                End If

                If Application.Contents("nv_onlyHTTPS") = True AndAlso HTTPS.ToLower<> "on" Then
                    Dim e As New tError
                    e.numError = 1003
                    e.titulo = "Error de acceso a la aplicación"
                    e.mensaje = "Solo puede accederse por protocolo HTTPS"
                    e.response()
                End If


                '****************************************************
                ' Controlar esté logueado al sistema
                ' Puede no estar logueado y venir un HASH de login
                ' O puede no estar logueado y venir usuario y contraseña
                ' Si no viene ninguno de los anteriores enviarlo a la pantalla de login
                '****************************************************

                Dim app_cod_sistema As String = nvUtiles.obtenerValor("app_cod_sistema", "")

                If app_cod_sistema = "" Then
                    Dim [as] As String = nvUtiles.obtenerValor("as", "")
                    Try
                        app_cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String([as]))
                    Catch ex As Exception

                    End Try

                End If

                If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado Then
                    '****************************************************
                    ' Controlar esté logueado al sistema
                    ' Si viene un hash procesarlo
                    '****************************************************
                    Dim nv_hash As String = nvFW.nvUtiles.obtenerValor("nv_hash", "")
                    'Dim app_cod_sistema As String = nvFW.nvUtiles.obtenerValor("app_cod_sistema", "")
                    'Dim [as] As String = nvFW.nvUtiles.obtenerValor("as", "")
                    'If [as] <> "" Then
                    '    app_cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String([as]))
                    'End If

                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado AndAlso nv_hash<> "" AndAlso app_cod_sistema <> "" Then
                        '*************************************************************
                        ' Procesar el hash
                        '*************************************************************
                        If nvApp.cod_sistema = "" Then
                            nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema)
                        End If

                        Dim HashError As tError = nvLogin.execute(nvApp, "login", "", "", "", "", nv_hash, "")

                        If HashError.numError<> 0 Then
                            HashError.response()
                            'HashError.salida_tipo = "adjunto"
                            'HashError.mostrar_error()
                            Exit Sub
                        End If
                    End If


                    '*************************************************************
                    'Procesar JWT
                    '**************************************************************
                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado And Request.Headers("Authorization") <> Nothing Then

                        'If Request.FilePath.ToLower().IndexOf("/ids/ids_client_token.aspx") <> 0 Then

                        Dim strAuthorization As String = Request.Headers("Authorization")
                        Dim strJWT As String = ""
                        If strAuthorization.Substring(0, 7).ToLower = "bearer " AndAlso strAuthorization.Split(".").Length = 3 Then
                            strJWT = strAuthorization.Substring(7)
                        End If

                        If strJWT <> "" AndAlso nvSession.Contents("_JWT") <> strJWT Then

                            Dim LoginError As tError = nvLogin.execute(nvApp, "login", "", "", "", "", strJWT, "")
                            If LoginError.numError<> 0 Then
                                LoginError.response()
                                'LoginError.salida_tipo = "adjunto"
                                'LoginError.mostrar_error()
                                Exit Sub
                            End If
                            nvSession.Contents("_JWT") = strJWT
                        End If
                    End If


                    '****************************************************
                    ' Controlar esté logueado al sistema
                    ' Si viene un usuario y contraseña procesarlo o tiene un certificado cliente
                    '****************************************************
                    Dim UID As String = nvFW.nvUtiles.obtenerValor("UID", "")
                    Dim PWD As String = nvFW.nvUtiles.obtenerValor("PWD", "")

                    If nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.no_logeado AndAlso app_cod_sistema<> "" AndAlso ((UID<> "" AndAlso PWD <> "") OrElse HttpContext.Current.Request.ClientCertificate.Count > 0) Then
                        If nvApp.cod_sistema = "" Then
                            nvFW.nvApp.set_app_from_cod(nvApp, app_cod_sistema)
                        End If

                        Dim LoginError As tError = nvLogin.execute(nvApp, "login", UID, PWD, "", "", "", "")

                        If LoginError.numError<> 0 Then
                            LoginError.response()
                            'LoginError.salida_tipo = "adjunto"
                            'LoginError.mostrar_error()
                            Exit Sub
                        End If
                    End If
                End If


                '****************************************************
                ' Controlar que este configurada la aplicacion actual
                ' Si nvApp.appState = enumnvAppState.not_loaded la palicacion no está configurada 
                ' y nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.logeado el usuario esta logeado
                ' Entonces configurar la aplicación
                '****************************************************
                'Dim cod_sistema As String = nvUtiles.obtenerValor("app_cod_sistema", "")
                'If cod_sistema = "" Then
                '    Dim [as] As String = nvUtiles.obtenerValor("as", "")
                '    cod_sistema = nvConvertUtiles.BytesToString(Convert.FromBase64String([as]))
                'End If
                Dim path_rel = nvUtiles.obtenerValor("app_path_rel", "")

                If nvApp.appState = enumnvAppState.not_loaded AndAlso nvApp.operador.autlevel = nvSecurity.enumnvAutLevel.logeado AndAlso (app_cod_sistema<> "" OrElse path_rel <> "") Then
                    Dim obj As Object = nvServer.getNvPageInstance(app_cod_sistema)

                    If Not obj Is Nothing Then
                        obj.nvApp = nvApp
                        Dim err As tError = obj.app_config()

                        If err.numError<> 0 Then
                            err.response()
                        End If
                    End If
                End If


                '***************************************************************************************
                ' Controlar que el usuario esté autorizado para acceder
                '***************************************************************************************
                If nvApp.operador.AutLevel<> nvSecurity.enumnvAutLevel.autorizado AndAlso nvApp.operador.AutLevel<> nvSecurity.enumnvAutLevel.autorizado_solo_interfaces Then
                    HttpContext.Current.Session.Abandon()
                    Dim e As New tError
                    e.numError = 1001
                    e.titulo = "Error de acceso a la aplicación"
                    e.mensaje = "El usuario no tiene acceso a la aplicación"
                    e.response()
                End If


                '***************************************************************************************
                ' Controlar que haya una aplicación activa
                '***************************************************************************************
                If nvApp.appState = enumnvAppState.not_loaded Then
                    Dim e As New tError
                    e.numError = 1002
                    e.titulo = "Error de acceso a la aplicación"
                    e.mensaje = "No hay una aplicación activa"
                    e.response()
                End If
            End Sub


            Public Sub addPermisoGrupo(ByVal permiso_grupo As String)
                Dim op As nvSecurity.tnvOperador = nvApp.operador
                Dim valor As Integer = op.permisos(permiso_grupo)
                Me.permiso_grupos.Remove(permiso_grupo)
                Me.permiso_grupos.Add(permiso_grupo, valor)
            End Sub


            Public Overridable Function getHeadInit(Optional ByRef includes As Dictionary(Of String, Boolean) = Nothing) As String
                Dim retScript As String = ""
                retScript &= "var obj = window;" & vbCrLf
                retScript &= "if (!!nvFW)" & vbCrLf
                retScript &= "  obj = nvFW;" & vbCrLf
                retScript &= "obj.nvPageID = '" & pageID & "';" & vbCrLf & vbCrLf

                If contents.Count > 0 Then
                    retScript &= " obj.pageContents = " & contents.toJSON() &";" & vbCrLf & vbCrLf
                End If

                retScript &= "obj.permiso_grupos = {};" & vbCrLf

                For Each permiso_grupo As String In Me.permiso_grupos.Keys
                    retScript &= "obj.permiso_grupos['" & permiso_grupo & "'] = " & Me.permiso_grupos(permiso_grupo) &";" & vbCrLf
                Next

                retScript = "<script type='text/javascript' id='nvPageFW_HeadInit' name='nvPageFW_HeadInit'>" & vbCrLf & retScript & "</script>" & vbCrLf

                Return retScript
            End Function

        End Class
    End Namespace
End Namespace

*/