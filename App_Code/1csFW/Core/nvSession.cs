using System;
using Microsoft.VisualBasic;
using System.Web;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace nvFW
{
    public static class nvSession
    {
        public static emunSessionType SessionType = emunSessionType.HTTP_session;
        // Private Shared _IDSession As String
        // Private Shared _otherIDSession As String



        public static string IDSession(System.Web.SessionState.HttpSessionState pvSession = null)
        {

            string SessionID = null;
            if (SessionType == emunSessionType.HTTP_session)
            {
                try
                {
                    if (HttpContext.Current != null && HttpContext.Current.Session != null)
                        SessionID = HttpContext.Current.Session.SessionID;
                }
                catch (Exception ex)
                {
                }
            }
            return SessionID;

            //private set { }
            //set
            //{
            //    if (session != null)
            //        session.Contents("_InterOp_IDSession") = value;
            //    if (HttpContext.Current != null)
            //        HttpContext.Current.Session.Contents("_InterOp_IDSession") = value;
            //}
        }
        // Public Shared Property IDSession As String
        // Get
        // Return nvSession.Contents("nvSessionValue").IDSession
        // End Get
        // Set(ByVal value As String)
        // nvSession.Contents("nvSessionValue").IDSession = value
        // End Set
        // End Property


        // Public Shared Property otherIDSession As String
        // Get
        // Return nvSession.Contents("nvSessionValue").otherIDSession
        // End Get
        // Set(ByVal value As String)
        // nvSession.Contents("nvSessionValue").otherIDSession = value
        // End Set
        // End Property


        public static void ContentsRemoveAll()
        {
            try
            {
                if (HttpContext.Current != null && HttpContext.Current.Session != null)
                    HttpContext.Current.Session.Contents.RemoveAll();
            }
            catch (Exception ex)
            {
            }
        }


        public static System.Web.SessionState.HttpSessionState GetContents( System.Web.SessionState.HttpSessionState pvSession)
        {
            System.Web.SessionState.HttpSessionState res = null;
            if (pvSession != null)
                res = pvSession.Contents;
            else
                res = Contents;
            return res;
        }

        public static System.Web.SessionState.HttpSessionState Contents 
        {
            get
            {
                System.Web.SessionState.HttpSessionState res = null;
                if (SessionType == emunSessionType.HTTP_session)
                {
                    try
                    {
                        if (HttpContext.Current != null && HttpContext.Current.Session != null)
                            res = HttpContext.Current.Session.Contents;//[IDContent];
                    }
                    catch (Exception ex4)
                    {
                    }
                }
                return res;
            }
            //set
            //{
            //    if (SessionType == emunSessionType.HTTP_session)
            //    {
            //        try
            //        {
            //            if (HttpContext.Current != null && HttpContext.Current.Session != null)
            //                HttpContext.Current.Session.Contents;//[IDContent] = oContent;
            //        }
            //        catch (Exception ex)
            //        {
            //        }
            //    }
            //}
        }



        //private static object pvGetInterOPSession(string IDSession)
        //{
        //    object oSession;
        //    object svr;
        //    object Instanciador;
        //    oSession = null;
        //    try
        //    {
        //        Instanciador = Interaction.CreateObject("nvInterOP.nvInstanciador", "localhost");
        //        svr = Instanciador.GetInstance();
        //        oSession = svr.getSession(IDSession);
        //        if (IDSession != oSession.idsession)
        //            System.Diagnostics.Debugger.Break();
        //    }
        //    catch (Exception ex)
        //    {
        //    }
        //    return oSession;
        //}

        //private static object pvGetInterOPServer()
        //{
        //    object svr = null;
        //    object Instanciador;
        //    try
        //    {
        //        Instanciador = Interaction.CreateObject("nvInterOP.nvInstanciador", "localhost");
        //        svr = Instanciador.GetInstance();
        //    }
        //    catch (Exception ex)
        //    {
        //    }
        //    return svr;
        //}

        //private static object pvRemoveInterOPServer()
        //{
        //    object svr = null;
        //    object Instanciador;
        //    try
        //    {
        //        Instanciador = Interaction.CreateObject("nvInterOP.nvInstanciador", "localhost");
        //        Instanciador.removeInstance();
        //    }
        //    catch (Exception ex)
        //    {
        //    }
        //    return svr;
        //}

        //public static string getTempKey()
        //{
        //    string ret = "";
        //    try
        //    {
        //        ret = pvGetInterOPServer.getTempKey(IDSession);
        //    }
        //    catch (Exception ex)
        //    {
        //    }
        //    return ret;
        //}


        public static void Abandon()
        {
            if (HttpContext.Current != null && HttpContext.Current.Session != null)
                Abandon(HttpContext.Current.Session);
        }
        
        public static void Abandon(System.Web.SessionState.HttpSessionState Session)
        {
            //if (SessionType == emunSessionType.nvInterOP_session)
            //{
            //    try
            //    {
            //        string _IDSession = IDSession(Session);
            //        pvGetInterOPSession(_IDSession).removeAllContent();
            //        pvGetInterOPServer().removeSession(_IDSession);
            //    }
            //    catch (Exception ex)
            //    {
            //    }
            //}
            Session.RemoveAll();
            Session.Abandon();
        }

        //public static void removeInstance()
        //{
        //    pvRemoveInterOPServer();
        //}
    }

    // Public Class tnvSessionValue
    // Public IDSession As String
    // Public otherIDSession As String
    // End Class

    /// <summary>
    ///     ''' Existen dos formas de administrar las sesiones de usuario.
    ///     ''' HTTP_session: es la forma clasica que administra directamente IIS desde el objeto Session.
    ///     ''' nvInterOP_session: Utiliza un objeto fuera de proceso para administrar las sessiones. Esto
    ///     ''' permite que mas de un proceso puedan compartir el estado de sessión. Esto es requerido por
    ///     ''' ejemlpo en ambientes mixtos ASP y ASPX
    ///     ''' </summary>
    ///     ''' <remarks></remarks>
    public enum emunSessionType : int
    {
        HTTP_session = 0
        //nvInterOP_session = 1
    }

    public enum enumServerType : int
    {
        ASP_NET = 0,
        ASP_CLASSIC = 1
    }
}