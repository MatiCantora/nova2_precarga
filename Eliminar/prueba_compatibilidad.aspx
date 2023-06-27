<%@ Page Language="vb" AutoEventWireup="false"  %>
<%@ Import namespace="nvFW" %>
<!doctype html>
<html>
<head>
    <title>NOVA Login</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="image/icons/nv_login.ico" rel="shortcut icon" />
    <link href="/fw/css/base.css" rel="stylesheet" type="text/css" />
   
    <script type="text/javascript">
    var _nvFW_Page_tSession = false
    </script>
    <script type="text/javascript"  src="/fw/script/nvFW.js"></script>
    <script type="text/javascript"  src="/fw/script/nvFW_BasicControls.js"></script>
    <script type="text/javascript"  src="/fw/script/nvFW_windows.js"></script>

    <!--<script type="text/javascript">
    /************************************************************/
    // Objetos y funciones para el manejo de XML
    //
    //Funciones
    //  XMLDoc()
    //  selectNodes(sXPath, xNode)
    //  selectSingleNode(sXPath, xNode)
    //  XMLtoString(objXML)
    //  XMLText(NODElement)
    //
    //Objetos
    //  tXML()
    /************************************************************/
    
    function XMLDoc()
      {
      //Devuelve un XMLDocument
      try
        {
        return new ActiveXObject("Microsoft.XMLDOM"); //IE
        } 
      catch(e)
        {
        return document.implementation.createDocument("","",null);//NO IE
        }
      }
      
    function XMLHttpObject()
      {
      //Devuelve un XMLHttpRequest
      try
        {
        xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
        }
      catch (e)
        {
        xmlHttp=new XMLHttpRequest(); // Firefox, Opera 8.0+, Safari       
        }
      ////Devuelve un XMLHttpRequest
      //try
      //  {
      //   xmlHttp=new XMLHttpRequest(); // Firefox, Opera 8.0+, Safari
      //  }
      //catch (e)
      //  {
      //  // Internet Explorer
      //  try
      //    {
      //    xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
      //    }
      //  catch (e)
      //    {
      //    xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
      //    }
      //  }
      return xmlHttp;
      }
  
    
    function selectNodes(sXPath, xNode) 
      {
      //para poder llamarlo como funcion
      if( !xNode ) 
        { xNode = this; } 

      var oEvaluator
      try
        {
        oEvaluator = new XPathEvaluator();
        }
      catch(ex)
        {
        return xNode.selectNodes(sXPath)
        }
      var oEvaluator = new XPathEvaluator();
      //Agregar el namespace
      //La funcion createNSResolver devuelve un objeto con los namespaces del nodo
      //Este objeto se pasa como parametro a la funcion evaluate, sin este objeto la funcion
      //no reconoce ningun namespace.
      var contextNode = xNode.ownerDocument;
      if (xNode.ownerDocument == null) 
        contextNode = xNode.documentElement
      if (contextNode == null)
        {
        alert('tXML::selectNodes()::contextNode es nulo.')
        return 
        }
      var nsResolver = document.createNSResolver(contextNode)
      var oResult = oEvaluator.evaluate(sXPath, xNode, nsResolver, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
       
      var aNodes = new Array();
      if (oResult != null) 
        {
        var oElement = oResult.iterateNext();
        while(oElement) 
          {
          aNodes.push(oElement);
          oElement = oResult.iterateNext();
          }
        }
      return aNodes;
      }
      
    function selectSingleNode(sXPath, xNode) 
      {
      //para poder llamarlo como funcion
      if( !xNode ) { xNode = this; } 
      var oEvaluator
      try
        {
        oEvaluator = new XPathEvaluator();
        }
      catch(ex)
        {
        return xNode.selectSingleNode(sXPath  )   
        }
      //Agregar el namespace
      var contextNode = xNode.ownerDocument;
      if (xNode.ownerDocument == null) 
        contextNode = xNode.documentElement
      if (contextNode == null) 
        {
        alert('tXML::selectSingleNode()::contextNode es nulo.')
        return 
        }
      var nsResolver = document.createNSResolver(contextNode)
      // FIRST_ORDERED_NODE_TYPE returns the first match to the xpath.
      try 
        {
        var oResult = oEvaluator.evaluate(sXPath, xNode, nsResolver, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        }
      catch (e) 
        { 
        return null
        }  
        
      if (oResult != null) 
        {
        if (oResult.singleNodeValue != null)
          return oResult.singleNodeValue;
        else
          return null //oResult
        } 
      else
        {
        return null;
        }
      }  
      
     function XMLtoString(objXML)
       {
       var XMLS
       try
         {
         XMLS = new XMLSerializer()
         return XMLS.serializeToString(objXML); 
         }
       catch(ex2) 
         {
         return objXML.xml
         }
       }
     
     function XMLText(NODElement)  
       {
       if (NODElement.text != undefined)
         return NODElement.text
       else
         return NODElement.textContent
       }
       
    function XMLParseError(objXML)   
      {
      var res = {}
      res['numError'] = 0
      res['description'] = ''
      
      if (objXML == null) 
          {
          res['numError'] = 1000
          res['description'] = 'Recurso no encontrado'
          return res 
          }
      
      if (objXML.parseError != undefined)
        {
        res['numError'] = objXML.parseError.errorCode
        res['description'] = objXML.parseError.reason
        }
      else
        {
        //si documentElement is null no se econtro el origen
        if (!objXML.documentElement) 
          {
          res['numError'] = 1000
          res['description'] = 'Recurso no encontrado'
          }
        else
         {
         //Sino devuelve un xml con el resultado del error
         if (objXML.documentElement.tagName == 'parsererror')
           {
            res['numError'] = 1001
            res['description'] = XMLText(objXML.documentElement)
           }
          else
           if (objXML.getElementsByTagName("parsererror")!= undefined )
            if (objXML.getElementsByTagName("parsererror")[0] != undefined ) 
             {
               res['numError'] = 1001
               res['description'] = XMLText(objXML.getElementsByTagName("parsererror")[0])
             }
         }    
        }
      return res  
      
      }

   function stringToXMLAttributeString(str) 
     {
     if (str)
       {
       str = str.replace(/&/g, "&amp;");
       str = str.replace(/"/g, "&quot;");
       str = str.replace(/'/g, "&apos;");
       str = str.replace(/</g, "&lt;");
       str = str.replace(/>/g, "&gt;");
       }
     return str;
     }


    function XMLAttributeStringToString(str)
      {
      if (str) 
        {
        str = str.replace(/&amp;/g, "&");
        str = str.replace(/&quot;/g, "\"");
        str = str.replace(/&apos;/g, "'");
        str = str.replace(/&lt;/g, "<");
        str = str.replace(/&gt;/g, ">");
        }
      return str;
      }


       
    function tXML()
      {
      this.method = "GET"
      this.async = false
      this.xml = null
      this.parseError = {}
      this.parseError['numError'] = 0
      this.parseError['description'] = ''
      this.onComplete = null;
      this.load = tXML_load; //cargar xml desde una url
      this.loadXML = tXML_loadXML; //cargar xml desde una cadena
      this.getXML = tXML_getXML; 
      this.toString = tXML_toString;
      this.getElementsByTagName = tXML_getElementsByTagName;
      
      this.selectNodes = tXML_selectNodes;
      this.selectSingleNode = tXML_selectSingleNode; 
      }
    
    
    function tXML_loadXML(strXML)
      {
      /******************************/
      //No corre de forma asincrona
      //Parsea una cadena XML
      //Devuelve verdadero si puede realizar la operacion
      /*******************************/
      this.parseError['numError'] = 0
      this.parseError['description'] = ''
      if (typeof(this.onComplete) != 'function')
        this.onComplete = null
      
      try
        {
        var activeX = true
        try
         {
         var ax = new ActiveXObject("Microsoft.XMLDOM")
         }
        catch(e)
         {
         activeX = false  
         }  
        if (activeX)
          {
          this.xml = XMLDoc() //IE
          //siempre sincronico
          this.xml.async= false;
          if (this.xml.loadXML(strXML))
            {
            if (this.onComplete != null)
              this.onComplete()
            return true
            }
          else
            {
            this.parseError = XMLParseError(this.xml)
            if (this.onFailure != null)
              this.onFailure()
            return false
            }    
          }
        else 
          {
          var parser = new DOMParser();
          var oXML = parser.parseFromString(strXML, "text/xml"); 
          this.parseError = XMLParseError(oXML)
          if (this.parseError.numError != 0)
            {
            if (this.onFailure != null)
              this.onFailure()
            return false
            }
          this.xml = oXML  
          if (this.onComplete != null)
            this.onComplete()
          return true
          } 
        }
      catch (e) 
       {
        this.parseError['numError'] = e.number
        this.parseError['description'] = e.description
        return false
        }
      }
      
    function tXML_load(URL, strParametres, onComplete)
      {
      /***********************************************************/
      // Parsea el resultado XML de la url 
      // En caso de ser asincrono asigna la funcion "fonComplete"
      // al evento onComplete
      /***********************************************************/
      //if (this.async)
      //   alert('No implementado.\nEl metodo load de tXML no fué probado en modo asincrono')
      this.parseError['numError'] = 0
      this.parseError['description'] = ''

      this.onFailure
      if (typeof(this.onFailure) != 'function')
        this.onFailure = null
         
      if (typeof(onComplete) == 'function')
        this.onComplete = onComplete
      
      if  (typeof(this.onComplete) != 'function')
        this.onComplete = null
          
      if (!strParametres)    
        strParametres = ''
      
      if (strParametres != '')
        strParametres = strParametres   
        
      try
        {
        //Si es asincrono
        //if (this.async)
        
        
        var oXMLHttp = XMLHttpObject() 

        var miOBJETO = this
        //onreadystatechange no funca ne firefox

        oXMLHttp.onreadystatechange = function()
                                          {
                                          if (oXMLHttp.readyState == 4 && miOBJETO.async)
                                            {
                                             if (oXMLHttp.status == 200) 
                                               { 
                                               miOBJETO.xml = oXMLHttp.responseXML
                                               miOBJETO.parseError = XMLParseError(oXMLHttp.responseXML)
                                               if (typeof(miOBJETO.onComplete) == 'function')
                                                  miOBJETO.onComplete()
                                               }
                                             else
                                               {
                                               miOBJETO.parseError.numError = oXMLHttp.status
                                               miOBJETO.parseError.description = oXMLHttp.statusText
                                               if (miOBJETO.onFailure != null)
                                                 miOBJETO.onFailure()

                                               }
 
                                            }  
                                          };
        if (this.method == "GET")
          { 
          if (strParametres != "")
            URL = URL + "?" + strParametres
            strParametres = ""
          }
        oXMLHttp.open(this.method, URL, this.async);
        if (this.method.toUpperCase() == "POST")
          {
          oXMLHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
          //oXMLHttp.setRequestHeader("User-Agent", "Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+5.1)") 
          //oXMLHttp.setRequestHeader("Content-length", strParametres.length);
          //oXMLHttp.setRequestHeader("Connection", "close");
          } 
        oXMLHttp.send(strParametres)
        if (!this.async)
          {
          if (oXMLHttp.readyState == 4)
            {
            if (oXMLHttp.status == 200) 
              {
              this.xml = oXMLHttp.responseXML
              this.parseError = XMLParseError(oXMLHttp.responseXML)
              if (typeof(this.onComplete) == 'function')
                this.onComplete()
              }
            else
              {
              this.parseError.numError = oXMLHttp.status
              this.parseError.description = oXMLHttp.statusText
              if (this.onFailure != null)
                this.onFailure()
              }     
              
            }  
          }
        var res = this.async ? false : this.parseError.numError == 0
        
        return res
        
//        else  
//          {
//          //Si es sincrono
//          this.xml = XMLDoc()
//          this.xml.async= false;
//          if (this.xml.load(URL + strParametres))  
//            return true
//          else
//            {
//            this.parseError = XMLParseError(this.xml)
//            this.xml = XMLDoc()
//            return false
//            }  
//          }
        }  
      catch(e)  
        {
        this.parseError['numError'] = e.number
        this.parseError['description'] = e.description
        return false
        }
      }  
      
    function tXML_getXML(accion, criterio, fonComplete)
      {
      if (criterio == undefined) 
        criterio = ''
      return this.load('/FW/GetXML.aspx?accion=' + accion + '&criterio=' + escape(criterio), '', fonComplete)
      }
    
      
    function tXML_toString()
      {
      if (this.xml != null)
        return XMLtoString(this.xml)
      else
        ''  
      }  
      
     function tXML_selectNodes(sXPath)  
       {
       return selectNodes(sXPath, this.xml)  
       }
       
     function tXML_selectSingleNode(sXPath)   
       {
       return selectSingleNode(sXPath, this.xml) 
       }
       
     function tXML_getElementsByTagName(TagName)  
       {
       return this.xml.getElementsByTagName(TagName)
       }

    </script>-->
    <script type="text/javascript" >

function window_onload()
  {
  debugger
  var oXML = new tXML();
  oXML.async = true

  oXML.onComplete = function()
                      {
                      var node = this.selectSingleNode("xml/s:Schema")
                      alert(node.tagName)
                      alert(XMLText(node))
                      var nodes = this.selectNodes("xml/rs:data/z:row")
                      alert(nodes[0].tagName)

                      var strXML = this.toString()
                      alert(strXML)
                      
                      var oXML2 = new tXML();
                      
                      oXML2.loadXML(strXML)

                     alert(oXML2.toString())

                      node = oXML2.selectSingleNode("xml/s:Schema")
                      alert(node.tagName)
                      alert(XMLText(node))
                      nodes = oXML2.selectNodes("xml/rs:data/z:row")
                      alert(nodes[0].tagName)


                      }

  oXML.load("/fw/getXML.aspx", {accion:"getXML", filtroXML:"<criterio><select vista='transf_binary'><campos>*</campos></select></criterio>"})


  }

  
    </script>

</head>
<body onload="window_onload()">
    <div id="div_body" align="center" style="100%; height:100%" >
    <table class="tb1" id="tb_Loginbody" cellpadding="0" cellspacing="0" style="border: solid white 2px;  -moz-border-radius: 4px; -webkit-border-radius: 4px;    border-radius: 4px;">
        <tr class="tbLabelNormal">
            <td style="align:center; text-align:center">
               <!-- <iframe id="novaLobo" src="image/nvLogin/nova.svg" style="border: 0px; width:150px; height:64px" marginheight="0" marginwidth="0" noresize scrolling="No" frameborder="0"></iframe>-->
                <object data="/fw/image/nvLogin/nova.svg" width="150" height="64px" type="image/svg+xml">
                    <!--<img src="/fw/image/nvLogin/nvLogin_logo.png" alt="PNG image of standAlone.svg" />-->
                </object>
            </td>
        </tr>
        </div>
</body>
</html>
