function tDMOffLine()
{
  this.GetDocumentTransform = pvGetDocumentoTransform;
  this.GetDocumentXML = pvGetDocumentXML;
  this.BASE_PATH = pvBASE_PATH;
  this.estado = 'OK';
  this.APP_PATH = '';
  
} 

function pvBASE_PATH()
{
  var pos = this.APP_PATH.toUpperCase().indexOf('/FW/');
  return this.APP_PATH.substr(0,pos) + '/FW/'
}

function pvGetDocumentXML(Lib, Accion, Criterio)
{
  var strPath;
  var msg = 'Error ';
switch(Accion)
  {
  case 'GetTreeItems':
    {
    if (!Criterio)
      Criterio = 0;
    //strPath = Lib + '/Data/ITM' + Len5(Criterio) + '.xml';
    strPath = "/FW/GetXML.asp?accion=vGetTreeItem&criterio=" + Criterio
    
    oXML = new tXML()
    if (oXML.load(strPath))
      return oXML.toString()
    else 
      ''  
    }
   case 'GetMenuItems':
    {
        if (!Criterio)
            Criterio = 0;
        
        strPath = Criterio
        oXML = new tXML()
        if (oXML.load(strPath))
            return oXML.toString()

        strPath = 'DocMNG/Data/' + Criterio + '.xml'
        oXML = new tXML()
        if (oXML.load(strPath))
            return oXML.toString()

        strPath = '/FW/DocMNG/Data/' + Criterio + '.xml'
        oXML = new tXML()
        if (oXML.load(strPath))
            return oXML.toString()

        if (typeof nvSesion != 'undefined') {
            strPath = '/' + nvSesion.app_path_rel + '/DocMNG/Data/' + Criterio + '.xml'
            oXML = new tXML()
            if (oXML.load(strPath))
                return oXML.toString()
        }

        strPath = '/' + window.top.nvSesion.app_path_rel + '/DocMNG/Data/' + Criterio + '.xml'
        oXML = new tXML()
        if (oXML.load(strPath))
            return oXML.toString()

        return ''
    }
    break
  case 'GetMenuCCItems':
    {
    strPath = "GetXML.asp?accion=GetMenuCCItems&criterio=" + Criterio 
    objXML.async = false;
    if (objXML.load(strPath))
      return objXML.xml
    else
      alert(objXML.parseError.reason)
    break  
    }  
  /*case 'GetInfoDoc':
    {
    strPath = this.BASE_PATH() + Lib + '/Data/INF' + Len5(Criterio) + '.dt0'
    objXML.async = false;
    if (objXML.load(strPath))
      return objXML.xml
    else
      alert(objXML.parseError.reason)  
    }
  case 'GetPathDoc':
    {
    strPath = this.BASE_PATH() + Lib + '/Data/MNG' + Len5(Criterio) + '.htm'
    return strPath
    
    }
  case 'FindTreeItems':
    {
    var IDItem;
    var Item;
    var i;
    var strBuscado = Criterio;
    var Nods;
    var pila = new Array();
    var hijos;
    var pos;
    var strXML = '';
    var Path;
    pila[0] = "0";
    while (pila.length > 0)
      {
      Path = this.GetDocumentXML(Lib, 'GetTreeItems', pila[pila.length-1]);
      if (objXML.loadXML(Path));
        {
        Nods = objXML.getElementsByTagName('resultado/Indice/Item');
        pila.length = pila.length - 1;
        for (i=0;i<Nods.length;i++)
          {
          IDItem = Nods[i].attributes[0].nodeValue;;
          Item = Nods[i].childNodes[2].text;
          hijos = parseInt(Nods[i].childNodes[4].attributes[0].nodeValue);
          pos = Item.toUpperCase().indexOf(strBuscado.toUpperCase());
          if (pos > -1)
            strXML = strXML + Nods[i].xml;
          if (hijos > 0)
          pila[pila.length] = IDItem;  
          }
        }
      }
      return '<?xml version=\'1.0\' encoding=\'ISO-8859-1\'?><resultado><Indice IDItem=\"-1\">' + strXML + '</Indice></resultado>'
    }*/        
  }
}
function Len5(num)
{
  var a;
  a = num.toString();
  while (a.length < 5)
    {
    a = '0' + a;
    }
  return a   
}

function pvGetDocumentoTransform()
{
}  
