<%@ Page Language="VB" AutoEventWireup="false"   Inherits="nvFW.nvPages.nvPageAdmin"%>


<%

    Me.contents("miConsulta") = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>")
    Me.contents("nro_operador") = 45
    Dim d As DateTime = Now()
    Dim str As String = d.ToString(New System.Globalization.CultureInfo("en-US"))

 %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Prueba del objeto nvFW</title>

    <link href="/admin/css/base.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript"  src="/FW/script/nvFW.js"></script>
    <script type="text/javascript"  src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript"  src="/FW/script/tCampo_def.js"></script>
    <script type="text/javascript"  src="/FW/script/tRS.js"></script>
   <% = Me.getHeadInit()%>

    <style type="text/css">
        input
        {
            width: 100px;
        }
    </style>

    <script type="text/javascript" >
    
    </script>
    <script type="text/javascript" >
         
       
        //var a = {0: {name:'bigint', datatype : 'i8'},1: {name:'smallint', datatype : 'i2'},2: {name:'tinyint', datatype : 'ui1'},3: {name:'int', datatype : 'int'},4: {name:'timestamp', datatype : 'bin.hex'},5: {name:'float', datatype : 'float'},6: {name:'real', datatype : 'r4'},7: {name:'numeric', datatype : 'number'},8: {name:'decimal', datatype : 'number'},9: {name:'smallmoney', datatype : 'number'},10: {name:'money', datatype : 'number'},11: {name:'bit', datatype : 'boolean'},12: {name:'date', datatype : 'desconocido'},13: {name:'datetimeoffset', datatype : 'desconocido'},14: {name:'datetime2', datatype : 'dateTime'},15: {name:'smalldatetime', datatype : 'dateTime'},16: {name:'datetime', datatype : 'dateTime'},17: {name:'time', datatype : 'desconocido'},18: {name:'binary', datatype : 'bin.hex'},19: {name:'varbinary', datatype : 'bin.hex'},20: {name:'image', datatype : 'bin.hex'},21: {name:'varchar', datatype : 'string'},22: {name:'char', datatype : 'string'},23: {name:'nvarchar', datatype : 'string'}, length : 24}
        //var c = {0: {name:'bigint', datatype : 'i8'},1: {name:'smallint', datatype : 'i2'},2: {name:'tinyint', datatype : 'ui1'},3: {name:'int', datatype : 'int'},4: {name:'timestamp', datatype : 'bin.hex'},5: {name:'float', datatype : 'float'},6: {name:'real', datatype : 'r4'},7: {name:'numeric', datatype : 'number'},8: {name:'decimal', datatype : 'number'},9: {name:'smallmoney', datatype : 'number'},10: {name:'money', datatype : 'number'},11: {name:'bit', datatype : 'boolean'},12: {name:'date', datatype : 'desconocido'},13: {name:'datetimeoffset', datatype : 'desconocido'},14: {name:'datetime2', datatype : 'dateTime'},15: {name:'smalldatetime', datatype : 'dateTime'},16: {name:'datetime', datatype : 'dateTime'},17: {name:'time', datatype : 'desconocido'},18: {name:'binary', datatype : 'bin.hex'},19: {name:'varbinary', datatype : 'bin.hex'},20: {name:'image', datatype : 'bin.hex'},21: {name:'varchar', datatype : 'string'},22: {name:'char', datatype : 'string'},23: {name:'nvarchar', datatype : 'string'}, length : 24}
        //var r = JSON.parse("{0: {name:'bigint', datatype : 'i8'},1: {name:'smallint', datatype : 'i2'},2: {name:'tinyint', datatype : 'ui1'},3: {name:'int', datatype : 'int'},4: {name:'timestamp', datatype : 'bin.hex'},5: {name:'float', datatype : 'float'},6: {name:'real', datatype : 'r4'},7: {name:'numeric', datatype : 'number'},8: {name:'decimal', datatype : 'number'},9: {name:'smallmoney', datatype : 'number'},10: {name:'money', datatype : 'number'},11: {name:'bit', datatype : 'boolean'},12: {name:'date', datatype : 'desconocido'},13: {name:'datetimeoffset', datatype : 'desconocido'},14: {name:'datetime2', datatype : 'dateTime'},15: {name:'smalldatetime', datatype : 'dateTime'},16: {name:'datetime', datatype : 'dateTime'},17: {name:'time', datatype : 'desconocido'},18: {name:'binary', datatype : 'bin.hex'},19: {name:'varbinary', datatype : 'bin.hex'},20: {name:'image', datatype : 'bin.hex'},21: {name:'varchar', datatype : 'string'},22: {name:'char', datatype : 'string'},23: {name:'nvarchar', datatype : 'string'}, length : 24}")
        //debugger
        
        //var strJSON = ""
        //strJSON += '{"0": {"name":\'bigint\', "datatype" : \'i8\'},"1": {"name":\'smallint\', "datatype" : \'i2\'},"2": {"name":\'tinyint\', "datatype" : \'ui1\'},"3": {"name":\'int\', "datatype" : \'int\'}}'
        //    //,"4": {"name":\'timestamp\', "datatype" : \'bin.hex\'},"5": {"name":\'float\', "datatype" : \'float\'},"6": {"name":\'real\', "datatype" : \'r4\'},"7": {"name":\'numeric\', "datatype" : \'number\'},"8": {"name":\'decimal\', "datatype" : \'number\'},"9": {"name":\'smallmoney\', "datatype" : \'number\'},"10": {"name":\'money\', "datatype" : \'number\'},"11": {"name":\'bit\', "datatype" : \'boolean\'},"12": {"name":\'date\', "datatype" : \'desconocido\'},"13": {"name":\'datetimeoffset\', "datatype" : \'desconocido\'},"14": {"name":\'datetime2\', "datatype" : \'dateTime\'},"15": {"name":\'smalldatetime\', "datatype" : \'dateTime\'},"16": {"name":\'datetime\', "datatype" : \'dateTime\'},"17": {"name":\'time\', "datatype" : \'desconocido\'},"18": {"name":\'binary\', "datatype" : \'bin.hex\'},"19": {"name":\'varbinary\', "datatype" : \'bin.hex\'},"20": {"name":\'image\', "datatype" : \'bin.hex\'},"21": {"name":\'varchar\', "datatype" : \'string\'},"22": {"name":\'char\', "datatype" : \'string\'},"23": {"name":\'nvarchar\', "datatype" : \'string\'}, "length" : 24}'
        //var j = JSON.parse(strJSON)
        
        //strJSON += "{0: {name:'bigint', datatype : 'i8'},'1': {name:'smallint', datatype : 'i2'},'2': {name:'tinyint', datatype : 'ui1'},'3': {name:'int', datatype : 'int'},\n"
        //strJSON += "'4': {name:'timestamp', datatype : 'bin.hex'},'5': {name:'float', datatype : 'float'},'6': {name:'real', datatype : 'r4'},'7': {name:'numeric', datatype : 'number'},'8': {name:'decimal', datatype : 'number'},'9': {name:'smallmoney', datatype : 'number'},'10': {name:'money', datatype : 'number'},'11': {name:'bit', datatype : 'boolean'},\n"
        //strJSON += "'12': {name:'date', datatype : 'desconocido'},'13': {name:'datetimeoffset', datatype : 'desconocido'},'14': {name:'datetime2', datatype : 'dateTime'},'15': {name:'smalldatetime', datatype : 'dateTime'},'16': {name:'datetime', datatype : 'dateTime'},'17': {name:'time', datatype : 'desconocido'},'18': {name:'binary', datatype : 'bin.hex'},'19': {name:'varbinary', datatype : 'bin.hex'},\n"
        //strJSON += "'20': {name:'image', datatype : 'bin.hex'},'21': {name:'varchar', datatype : 'string'},'22': {name:'char', datatype : 'string'},'23': {name:'nvarchar', datatype : 'string'}, length : 24}"
        //var j = JSON.parse(strJSON)
        //var b = 1
        
        function tRS_01() 
          {
          //Utiliza el parametro de pagina que pasó arriba
            //
          var rs = new tRS()
          var filtroXML =  "<criterio><select vista='estado' PageSize='3' AbsolutePage='1'  cacheControl='session' expire_minutes='60' ><campos>*</campos><filtro></filtro></select></criterio>" //nvFW.pageContents.miConsulta
          var filtroWhere =  "<criterio><select><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>" // "<criterio><select><orden>estado</orden></select></criterio>" //"<criterio><select top='1'></select></criterio>"
          var params = '' //"<criterio><params pepito=\"'A'\" /></criterio>"
          debugger
          rs.onError = function (rs)
                              {
                              rs.lastError.alert()
                              }

          rs.onComplete = function (rs)
                              {
                              debugger   
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
           
                              alert(str + "\nCantidad de registros: " + rs.recordcount)
                              }

          rs.open(filtroXML, '', filtroWhere, '', params)
          debugger                             
          }

        function tRS_02() 
          {
          var rs = new tRS()
          var filtroXML = nvFW.pageContents.miConsulta
          var filtroWhere = "<estado type='igual'>%estado%</estado>"
          var params = "<criterio><params estado=\"'A'\" /></criterio>"
          rs.open(filtroXML, '', filtroWhere, '', params)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }

        function tRS_03() 
          {
          var rs = new tRS()
          var filtroXML = "<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }

       function tRS_04() 
          {
//          var filtroXML = "<criterio><select vista='estado'><campos>*</campos><filtro><estado type='igual'>%estado%(varchar)</estado>[<descripcion type='igual'>%desc?%</descripcion><descripcion type='igual'>'aprobado'</descripcion>]</filtro></select></criterio>"
//          //var filtroWhere = "<criterio><select><filtro><estado type='igual'>'A'</estado></filtro></select></criterio>"
//          var xmlParam = '<criterio><params estado="\'A\'" /></criterio>'
//          var rs = new tRS()
//          rs.async = true
//          rs.onComplete = function(rs)
//                            {
//                            var str = ""
//                            while (!rs.eof())
//                              {
//                              str += rs.getdata("estado") + "\n"
//                              rs.movenext()
//                              }
//                            debugger
//                            alert(str + "\nCantidad de registros: " + rs.recordcount)
//                            }
//          rs.onError = function(rs) 
//                          {
//                          debugger
//                          }

//          rs.open(filtroXML, '', '', '',xmlParam)


          var er = new tError()
          er.Ajax_request("miUrl.aspx", { parameters: {parm0:'val1'}
                           ,asynchronous: true
//                           ,onSuccess : function(a, b)
//                                           {
//                                           debugger
//                                           }
//                           ,onFailure : function (a, b)
//                                            {
//                                            //debugger
//                                            }
                           ,bloq_contenedor_on : true
                           ,error_alert : true                  
                           //,bloq_contenedor : 'window.top'

          }
          
          
          )

          }

        function tRS_05() 
          {
          var filtroXML = nvFW.pageContents.miConsulta
          var rs = new tRS()
          rs.async = true
          rs.onComplete = function(rs)
                            {
                            if (rs.lastError.numError == 0)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
                              }
                            debugger
                            //nvFW.bloqueo_desactivar($$("BODY")[0], "miBloqueo")
                            alert(str + "\nCantidad de registros: " + rs.recordcount + '\nnro_operador:' + nvFW.pageContents.nro_operador)
                            }
          
          
          //nvFW.bloqueo_activar($$("BODY")[0],"miBloqueo")
          rs.open(filtroXML)
          }

        function tRS_06() 
          {
          var filtroXML = nvFW.pageContents.miConsulta
          var rs = new tRS()
          rs.async = true
          rs.xml_format = "rs_xml_json"
          rs.onComplete = function(rs)
                            {
                            if (rs.lastError.numError == 0)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
                              }
                            debugger
                            alert(str + "\nCantidad de registros: " + rs.recordcount + '\nnro_operador:' + nvFW.pageContents.nro_operador)
                            }
          rs.open(filtroXML)
          }  

       function tRS_07() 
          {
          
          var filtroXML = "<criterio><select vista='estado'><campos>cast(10 as bigint) as [bigint], cast(10 as smallint) as [smallint], cast(10 as tinyint) as [tinyint], cast(10 as int) as [int], cast(10 as timestamp) as [timestamp], cast(10 as float) as [float], cast(10 as real) as [real], cast(10 as numeric) as [numeric], cast(10 as decimal) as [decimal], cast(10 as smallmoney) as [smallmoney], cast(10 as money) as [money], cast(10 as bit) as [bit], cast('1/1/2016' as date) as [date], cast('1/1/2016' as datetimeoffset) as [datetimeoffset], cast('1/1/2016' as datetime2) as [datetime2], cast('1/1/2016' as smalldatetime) as [smalldatetime], cast('1/1/2016' as datetime) as [datetime], cast('1/1/2016' as time) as [time], cast('algo' as binary) as [binary],cast('algo' as varbinary) as [varbinary],cast('algo' as image) as [image],cast('algo' as varchar) as [varchar],  cast('algo' as char(255)) as [char], cast('algo' as nvarchar) as [nvarchar]</campos><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>"
          var rs = new tRS()
          rs.async = false
          rs.xml_format = "rs_xml_json"
          rs.open(filtroXML)
//          while(!rs.eof())
//            {

//            rs.movenext()
//            } 
          
          var filtroXML = "<criterio><select vista='estado'><campos>cast(10 as bigint) as [bigint], cast(10 as smallint) as [smallint], cast(10 as tinyint) as [tinyint], cast(10 as int) as [int], cast(10 as timestamp) as [timestamp], cast(10 as float) as [float], cast(10 as real) as [real], cast(10 as numeric) as [numeric], cast(10 as decimal) as [decimal], cast(10 as smallmoney) as [smallmoney], cast(10 as money) as [money], cast(10 as bit) as [bit], cast('1/1/2016' as date) as [date], cast('1/1/2016' as datetimeoffset) as [datetimeoffset], cast('1/1/2016' as datetime2) as [datetime2], cast('1/1/2016' as smalldatetime) as [smalldatetime], cast('1/1/2016' as datetime) as [datetime], cast('1/1/2016' as time) as [time], cast('algo' as binary) as [binary],cast('algo' as varbinary) as [varbinary],cast('algo' as image) as [image],cast('algo' as varchar) as [varchar],  cast('algo' as char(255)) as [char], cast('algo' as nvarchar) as [nvarchar]</campos><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>"
          var rs2 = new tRS()
          rs2.async = false
          rs2.xml_format = "rs_xml"
          rs2.open(filtroXML)
          var strRes = ""
          for (var i = 0; i<rs2.fields.length; i++)
            {
            strRes += rs2.fields[i].name + " : " + rs2.fields[i].datatype + " :: " + rs.fields[i].datatype + " (" + rs.fields[i].name + ")\n"
            }

          alert(strRes)
          while(!rs.eof())
            {

            rs.movenext()
            }

          } 
          
      function tRS_08() 
          {
          debugger
          var rs = new tRS()
          rs.xml_format = "rs_xml_json"
          var filtroXML =  "<criterio><select vista='vernv_servidor_sistema_all_dirs'><campos>cod_dir as id, cod_dir + '  \"' + path + '\"'  as[campo]</campos><filtro><cod_servidor type='igual'>'flezcano'</cod_servidor><cod_sistema type='igual'>'nv_admin'</cod_sistema></filtro><orden>[campo]</orden></select></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }
           
          alert(str + "\nCantidad de registros: " + rs.recordcount)


          }           

      function tRS_09()
        {

        var rs = new tRS()
          rs.xml_format = "rs_xml_json"
          var filtroXML =   "<criterio><procedure CommandText='dbo.rm_verRegistro_padres'><parametros><select><filtro><nro_registro type='in'>28</nro_registro></filtro></select></parametros></procedure></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }

        alert(str)
        }

       function tRS_10()
        {

        var rs = new tRS()
          rs.xml_format = "rs_xml_json"
          var filtroXML =   "<criterio><procedure CommandText='dbo.rm_verRegistro_padres2'></procedure></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("estado") + "\n"
            rs.movenext()
            }

        }

      
       function tRS_11()
        {

        var rs = new tRS()
          //rs.xml_format = "rs_xml_json"
          debugger
          var filtroXML =   "<criterio><select vista='nv_modulos'><campos>*</campos><filtro></filtro><orden>modulo</orden></select></criterio>"
          rs.open(filtroXML)
          var str = ""
          while (!rs.eof())
            {
            str += rs.getdata("cod_modulo") + "\n"
            rs.movenext()
            }
        alert(str)

        }

        function probarJSON()
          {
          debugger

          var obj = {number : 150, double : 100.25, date : new Date(), cadena : "Algo escrito"} 
          var strObj = JSON.stringify(obj)
        
          var strJSON = ""
          strJSON += $("txtJson").value
            //,"4": {"name":\'timestamp\', "datatype" : \'bin.hex\'},"5": {"name":\'float\', "datatype" : \'float\'},"6": {"name":\'real\', "datatype" : \'r4\'},"7": {"name":\'numeric\', "datatype" : \'number\'},"8": {"name":\'decimal\', "datatype" : \'number\'},"9": {"name":\'smallmoney\', "datatype" : \'number\'},"10": {"name":\'money\', "datatype" : \'number\'},"11": {"name":\'bit\', "datatype" : \'boolean\'},"12": {"name":\'date\', "datatype" : \'desconocido\'},"13": {"name":\'datetimeoffset\', "datatype" : \'desconocido\'},"14": {"name":\'datetime2\', "datatype" : \'dateTime\'},"15": {"name":\'smalldatetime\', "datatype" : \'dateTime\'},"16": {"name":\'datetime\', "datatype" : \'dateTime\'},"17": {"name":\'time\', "datatype" : \'desconocido\'},"18": {"name":\'binary\', "datatype" : \'bin.hex\'},"19": {"name":\'varbinary\', "datatype" : \'bin.hex\'},"20": {"name":\'image\', "datatype" : \'bin.hex\'},"21": {"name":\'varchar\', "datatype" : \'string\'},"22": {"name":\'char\', "datatype" : \'string\'},"23": {"name":\'nvarchar\', "datatype" : \'string\'}, "length" : 24}'
          var j
          try
            {
            j = JSON.parse(strJSON)
            }
          catch(ex1) 
            {
            alert(ex1.toString())   
            }
          
          
          }

        function probarEVAL()
          {
          debugger
        
          var strJSON = ""
          strJSON += $("txtJson").value
            //,"4": {"name":\'timestamp\', "datatype" : \'bin.hex\'},"5": {"name":\'float\', "datatype" : \'float\'},"6": {"name":\'real\', "datatype" : \'r4\'},"7": {"name":\'numeric\', "datatype" : \'number\'},"8": {"name":\'decimal\', "datatype" : \'number\'},"9": {"name":\'smallmoney\', "datatype" : \'number\'},"10": {"name":\'money\', "datatype" : \'number\'},"11": {"name":\'bit\', "datatype" : \'boolean\'},"12": {"name":\'date\', "datatype" : \'desconocido\'},"13": {"name":\'datetimeoffset\', "datatype" : \'desconocido\'},"14": {"name":\'datetime2\', "datatype" : \'dateTime\'},"15": {"name":\'smalldatetime\', "datatype" : \'dateTime\'},"16": {"name":\'datetime\', "datatype" : \'dateTime\'},"17": {"name":\'time\', "datatype" : \'desconocido\'},"18": {"name":\'binary\', "datatype" : \'bin.hex\'},"19": {"name":\'varbinary\', "datatype" : \'bin.hex\'},"20": {"name":\'image\', "datatype" : \'bin.hex\'},"21": {"name":\'varchar\', "datatype" : \'string\'},"22": {"name":\'char\', "datatype" : \'string\'},"23": {"name":\'nvarchar\', "datatype" : \'string\'}, "length" : 24}'
          var j
          try
            {
            j = eval(strJSON)
            }
          catch(ex1) 
            {
            alert(ex1.toString())   
            }
          
          
          }
       function tRS_getxml() 
          {
          //Utiliza el parametro de pagina que pasó arriba
            //
           debugger
          var rs = new tRS()
          
          var filtroXML =  "<criterio><select vista='estado' PageSize='3' AbsolutePage='1'  cacheControl='session' expire_minutes='60' ><campos>*</campos><filtro></filtro></select></criterio>" //nvFW.pageContents.miConsulta
          var filtroWhere =  "<criterio><select><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>" // "<criterio><select><orden>estado</orden></select></criterio>" //"<criterio><select top='1'></select></criterio>"
          var params = '' //"<criterio><params pepito=\"'A'\" /></criterio>"

          rs.onError = function (rs)
                              {
                              rs.lastError.alert()
                              }

          rs.onComplete = function (rs)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
           
                              alert(str + "\nCantidad de registros: " + rs.recordcount)
                              }

          rs.open(filtroXML, '', filtroWhere, '', params)


          }

      function tRS_getxml_json() 
          {
          //Utiliza el parametro de pagina que pasó arriba
            //
          debugger
          var rs = new tRS()
          rs.format = 'getxml_json'

          var filtroXML =  "<criterio><select vista='estado' PageSize='3' AbsolutePage='1'  cacheControl='session' expire_minutes='60' ><campos>*</campos><filtro></filtro></select></criterio>" //nvFW.pageContents.miConsulta
          var filtroWhere =  "<criterio><select><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>" // "<criterio><select><orden>estado</orden></select></criterio>" //"<criterio><select top='1'></select></criterio>"
          var params = '' //"<criterio><params pepito=\"'A'\" /></criterio>"

          rs.onError = function (rs)
                              {
                              rs.lastError.alert()
                              }

          rs.onComplete = function (rs)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
           
                              alert(str + "\nCantidad de registros: " + rs.recordcount)
                              }

          rs.open(filtroXML, '', filtroWhere, '', params)


          }

        function tRS_getterror() 
          {
          //Utiliza el parametro de pagina que pasó arriba
          //
          debugger
          var rs = new tRS()
          rs.xml_format = 'getterror' //Va a devolver un XML tError

          var filtroXML =  "<criterio><select vista='estado' PageSize='3' AbsolutePage='1'  cacheControl='session' expire_minutes='60' ><campos>*</campos><filtro></filtro></select></criterio>" //nvFW.pageContents.miConsulta
          var filtroWhere =  "<criterio><select><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>" // "<criterio><select><orden>estado</orden></select></criterio>" //"<criterio><select top='1'></select></criterio>"
          var params = '' //"<criterio><params pepito=\"'A'\" /></criterio>"

          rs.onError = function (rs)
                              {
                              rs.lastError.alert()
                              }

          rs.onComplete = function (rs)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
           
                              alert(str + "\nCantidad de registros: " + rs.recordcount)
                              }

          rs.open(filtroXML, '', filtroWhere, '', params)


          }

        
        function tRS_getterror_JSON() 
          {
          //Utiliza el parametro de pagina que pasó arriba
            //
          debugger
          var rs = new tRS()
          rs.format = 'getterror'
          rs.format_tError = "JSON"

          var filtroXML =  "<criterio><select vista='estado' PageSize='3' AbsolutePage='1'  cacheControl='session' expire_minutes='60' ><campos>*</campos><filtro></filtro></select></criterio>" //nvFW.pageContents.miConsulta
          var filtroWhere =  "<criterio><select><filtro><estado type='igual'>'T'</estado></filtro></select></criterio>" // "<criterio><select><orden>estado</orden></select></criterio>" //"<criterio><select top='1'></select></criterio>"
          var params = '' //"<criterio><params pepito=\"'A'\" /></criterio>"

          rs.onError = function (rs)
                              {
                              rs.lastError.alert()
                              }

          rs.onComplete = function (rs)
                              {
                              var str = ""
                              while (!rs.eof())
                                {
                                str += rs.getdata("estado") + "\n"
                                rs.movenext()
                                }
           
                              alert(str + "\nCantidad de registros: " + rs.recordcount)
                              }

          rs.open(filtroXML, '', filtroWhere, '', params)


          }

    </script>
   

</head>
<body  style="width: 100%; height: 100%; overflow: auto">
    <table class="tb1">
        <tr class="tbLabel0">
            <td>
                Ejemplos de tRS
            </td>
        </tr>
        <tr><td><textarea id="txtJson" style="width:100%"></textarea></td></tr>
        <tr><td><textarea id="txtJsonEscape" style="width:100%"></textarea></td></tr>
        <tr><td><input type="button"  value="Probar JSON" onclick="probarJSON()"/><input type="button"  value="Probar EVAL" onclick="probarEVAL()"/></td></tr>
        <tr>
            <td>
                <input type="button" value="tRS 01" onclick="return tRS_01()" title="Recuperar RS con conculta encriptada" />
                <input type="button" value="tRS 02" onclick="return tRS_02()" title="Recuperar RS con conculta encriptada y filtrarlo" />
                <input type="button" value="tRS 03" onclick="return tRS_03()" title="Consulta simple por filtroXML" />
                <input type="button" value="tRS 04" onclick="return tRS_04()" title="Consulta simple por filtroXML asíncrono" />
                <input type="button" value="tRS 05" onclick="return tRS_05()" title="Consulta simple por filtroXML asíncrono. filtroXML encriptado" />
                <input type="button" value="tRS 06" onclick="return tRS_06()" title="Consulta simple por filtroXML asíncrono. filtroXML encriptado. 2" />
                <input type="button" value="tRS 07" onclick="return tRS_07()" title="Tipos de datos" />
                <input type="button" value="tRS 08" onclick="return tRS_08()" title="String con caracteres de escape" />
                <input type="button" value="tRS 09" onclick="return tRS_09()" title="Procedure con where" />
                <input type="button" value="tRS 10" onclick="return tRS_10()" title="Procedure con where" />
                <input type="button" value="tRS 11" onclick="return tRS_11()" title="Prueba Facu" />
                <input type="button" value="getxml" onclick="return tRS_getxml()" title="getxml" />
                <input type="button" value="getxml_json" onclick="return tRS_getxml_json()" title="getxml_json" />
                <input type="button" value="tRS getterror" onclick="return tRS_getterror()" title="getterror" />
                <input type="button" value="tRS getterror JSON" onclick="return tRS_getterror_JSON()" title="getterror JSON" />
            </td>
        </tr>
    </table>
    <br />
    <iframe name="iframe1" id="iframe1" style="width: 100%; height: 80%; overflow: auto;"
        frameborder="0" src="/admin/enBlanco.htm"></iframe>
</body>
</html>

