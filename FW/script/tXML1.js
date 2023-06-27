
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

    function getAttribute(NOD, attr, isNULL)
      {
      if(isNULL == undefined ) isNULL = ''
      try
        {
        return selectSingleNode("@" + attr,NOD).nodeValue
        }
      catch(e){ return isNULL}
      }  
  
    function getAttribute_path(NOD, xPath, isNULL)
      {
      if(isNULL == undefined ) isNULL = ''
      try
        {
        return selectSingleNode(xPath,NOD).nodeValue
        }
      catch(e){ return isNULL}
      }  
       
    function tXML()
      {
      this.method = "GET"
      this.async = false
      this.xml = null
      this.xhr = null
      this.parseError = {}
      this.parseError['numError'] = 0
      this.parseError['description'] = ''
      this.onComplete = null;
      this.onFailure = null;
      this.onUploadProgress = null;

      this.load = tXML_load; //cargar xml desde una url
      this.loadXML = tXML_loadXML; //cargar xml desde una cadena
      this.getXML = tXML_getXML; 
      this.toString = tXML_toString;
      this.getElementsByTagName = tXML_getElementsByTagName;
      this.abort = tXML_abort;
      
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

      if (typeof(this.onFailure) != 'function')
        this.onFailure = null

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
      
    function tXML_load(URL, strParametres, onComplete, headers)
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
      
      
      if (typeof(this.onUploadProgress) != 'function')
        this.onUploadProgress = null

      if (typeof(this.onFailure) != 'function')
        this.onFailure = null
         
      if (typeof(onComplete) == 'function')
        this.onComplete = onComplete
      
      if  (typeof(this.onComplete) != 'function')
        this.onComplete = null
          
      if (!strParametres)    
        strParametres = ''
      var setHeader = false
      var DataParameters
      if (strParametres.constructor == FormData)
        {
        this.method = 'POST'
        DataParameters = strParametres
        strParametres = ""
        setHeader = true
        }

      if (typeof(strParametres) == "object")
        {
        params = strParametres   
        strParametres = ""
        for (var campo in params)
          strParametres += "&" + campo + "=" + window.encodeURIComponent(params[campo])
        if (strParametres.length > 0)
          strParametres = strParametres.substr(1, strParametres.length-1)
        }
      if (headers == undefined)  headers = {}

        
      try
        {
        //Si es asincrono
        //if (this.async)
        
        var oXMLHttp = XMLHttpObject()
        this.xhr = oXMLHttp

        //Agrega el upload progress
        if (typeof(this.onUploadProgress) == 'function')
          oXMLHttp.upload.addEventListener('progress',this.onUploadProgress , false)

        var miOBJETO = this
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
                                               miOBJETO.parseError.numError = 101
                                               miOBJETO.parseError.description = "Error desconocido. HTTP Status:" + oXMLHttp.status + " - " + oXMLHttp.statusText
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
        for (el in headers)
          {
          oXMLHttp.setRequestHeader(el, headers[el])
          setHeader = true
          }
        if (this.method.toUpperCase() == "POST")
          {
          if (!setHeader) oXMLHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
          //oXMLHttp.setRequestHeader("User-Agent", "Mozilla/4.0+(compatible;+MSIE+7.0;+Windows+NT+5.1)") 
          //oXMLHttp.setRequestHeader("Content-length", strParametres.length);
          //oXMLHttp.setRequestHeader("Connection", "close");
          if (DataParameters != undefined)
            oXMLHttp.send(DataParameters)
          else
            oXMLHttp.send(strParametres)
          }
        else
          oXMLHttp.send()
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
    function tXML_abort()
      {
      try
        {
        this.xhr.abort()  
        }
      catch(e) {}
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
