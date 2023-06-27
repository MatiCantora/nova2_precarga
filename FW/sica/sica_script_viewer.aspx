<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageAdmin" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>SICA Script Viewer</title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
    
    <script type="text/javascript" src="/FW/script/nvFW.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_windows.js"></script>
    <script type="text/javascript" src="/FW/script/nvFW_BasicControls.js"></script>

    <% = Me.getHeadInit() %>

    <link rel="stylesheet" href="/FW/script/CodeMirror/doc/docs.css" />
    <link rel="stylesheet" href="/FW/script/CodeMirror/lib/codemirror.css" />
    <link rel="stylesheet" href="/FW/script/CodeMirror/addon/fold/foldgutter.css" />

    <script src="/FW/script/CodeMirror/lib/codemirror.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/foldcode.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/foldgutter.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/brace-fold.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/xml-fold.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/markdown-fold.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/fold/comment-fold.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/clike/clike.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/javascript/javascript.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/sql/sql.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/selection/selection-pointer.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/scroll/simplescrollbars.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/xml/xml.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/css/css.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/vbscript/vbscript.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/htmlmixed/htmlmixed.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/htmlembedded/htmlembedded.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/mode/multiplex.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/mode/vb/vb.js" type="text/javascript"></script>
    
    <link rel="stylesheet" href="/FW/script/CodeMirror/addon/hint/show-hint.css" />
    
    <script src="/FW/script/CodeMirror/addon/hint/show-hint.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/hint/sql-hint.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/dialog/dialog.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/search/searchcursor.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/search/search.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/search/jump-to-line.js" type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/scroll/annotatescrollbar.js"  type="text/javascript"></script>
    <script src="/FW/script/CodeMirror/addon/search/matchesonscrollbar.js"  type="text/javascript"></script>

    <link rel="stylesheet" href="/FW/script/CodeMirror/addon/dialog/dialog.css"/>
    <link rel="stylesheet" href="/FW/script/CodeMirror/addon/search/matchesonscrollbar.css"/>

    <style type="text/css">
        p { margin: 0; }
    </style>

    <script type="text/javascript">
        function window_onresize()
        {
            try
            {
                var body_h            = $$('BODY')[0].getHeight();
                var divMenuObjeto_h   = $('divMenuObjeto').getHeight();
                var select_encoding_h = $('select_encoding').up().getHeight();

                $$('div.CodeMirror')[0].setStyle({ height: (body_h - divMenuObjeto_h - select_encoding_h) + 'px' });
            }
            catch (e) {}
        }



        function changeEncoding(select)
        {
            var newEncoding = select.options[select.selectedIndex].value;

            if (encoding != newEncoding)
            {
                encoding = newEncoding;
                loadContent();
            }
        }
    </script>
</head>
<body onresize="window_onresize()" style="width: 100%; overflow: hidden;">

    <div id="divMenuObjeto" style="height: 26px;"></div>

    <div style="text-align: right">
        <select id="select_encoding" onchange="changeEncoding(this)">
            <option value="ISO-8859-1">ISO-8859-1</option>
            <option value="UTF-8">UTF-8</option>
        </select>
    </div>

    <textarea id="code" name="code" rows="10" cols="10"></textarea>
    
    <script type="text/javascript">

        var winmod = nvFW.getMyWindow();
        var winData = {};
        var cod_objeto = null;
        var objeto = '';
        var cod_obj_tipo;
        var esDBObj = null;
        var extension;
        var encoding;
        var params = {};
        var $code;



        window.onload = function ()
        {
            $code      = $("code");
            winData    = winmod.options.userData;
            
            if (winData)
            {
                cod_objeto = winData.cod_objeto;
                esDBObj    = winData.esDBObj;
            }
            
            loadContent();
        }



        function printMenu()
        {
            var vMenu              = new tMenu('divMenuObjeto', 'vMenu');
            Menus["vMenu"]         = vMenu;
            Menus.vMenu.alineacion = 'centro';
            Menus.vMenu.estilo     = 'A';
            Menus.vMenu.CargarMenuItemXML("<MenuItem id='0' style='width: 100%; text-align: center; font-weight: bold; color: white; font-size: medium;'><Lib TipoLib='offLine'>DocMNG</Lib><icono></icono><Desc>" + objeto + "</Desc></MenuItem>");
            vMenu.MostrarMenu();
        }



        function loadContent()
        {
            var sEncoding = $('select_encoding');
            var encoding = sEncoding.options[sEncoding.selectedIndex].value;
            var url = '';

            if (cod_objeto)
            {
                url = '/FW/sica/get_objeto_def_source.aspx';
                params.modo       = "GET_DEF";
                params.cod_objeto = cod_objeto;
                params.encoding   = encoding;
            }
            else
            {
                url = '/FW/sica/get_objeto_imp_source.aspx';
                params.modo         = "GET_IMP";
                params.encoding     = encoding;
                params.objeto       = winData.objeto;
                params.path         = winData.path;
                params.cod_obj_tipo = winData.cod_obj_tipo;
                params.cod_servidor = winData.cod_servidor;
                params.cod_sistema  = winData.cod_sistema;
                params.port         = winData.port;
            }


            nvFW.error_ajax_request(url,
            {
                bloq_contenedor_on: false,
                parameters: params,
                onSuccess: function (err)
                {
                    var content = err.params.objetoContent;

                    if (content)
                    {
                        // la primera vez cargar el menu, y setear el editor de CodeMirror
                        if (!objeto)
                        {
                            objeto       = err.params.objeto;
                            printMenu();
                            extension    = err.params.extension;
                            cod_obj_tipo = err.params.cod_obj_tipo;
                            setEditor();
                        }

                        // si es info xml, formatear contenido
                        if (cod_obj_tipo == 8 || cod_obj_tipo == 1 || extension == ".xml")
                        {
                            content = formatXml(content);
                        }

                        $code.value = content;
                        editor.setValue(content);
                        window_onresize();
                    }
                },
                onFailure: function (err)
                {
                    alert("No se pudo leer contenido del objeto.<br/>" + err.mensaje);
                    console.error("NOVA Error: %s (%i)", (err.mensaje ? err.mensaje : (err.debug_desc ? err.debug_desc :  'No se pudo leer contenido del objeto.')), err.numError);
                },
                error_alert: false
            });
        }



        function setEditor()
        {
            // Objetos de sql
            if (esDBObj)
            {
                var mime = 'text/x-mariadb';
                //        var mime = "text/x-sql";
                //        var mime = "text/x-mysql";
                //        var mime = "text/x-mariadb";
                //        var mime = "text/x-cassandra";
                //        var mime = "text/x-plsql"; 
                //        var mime = "text/x-mssql";
                //        var mime = "text/x-hive";

                // get mime type
                if (window.location.href.indexOf('mime=') > -1)
                {
                    mime = window.location.href.substr(window.location.href.indexOf('mime=') + 5);
                }

                if (cod_obj_tipo == 8)
                {
                    mime = "xml"
                }

                window.editor = CodeMirror.fromTextArea($code, {
                    scrollbarStyle: "native",
                    mode:           mime,
                    indentWithTabs: true,
                    smartIndent:    true,
                    lineNumbers:    true,
                    lineWrapping:   true,
                    matchBrackets:  true,
                    autofocus:      true,
                    readOnly:       true,
                    lineNumbers:    true,
                    extraKeys: {
                        "Alt-F": "findPersistent", 
                        "Ctrl-Q": function (cm) {
                            cm.foldCode(cm.getCursor());
                        }
                    },
                    hintOptions: { 
                        tables: {
                            users:     { name: null, score: null,      birthDate: null },
                            countries: { name: null, population: null, size: null }
                        }
                    },
                    foldGutter: true,
                    gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
                });

                return;
            }

            var mode = '';

            if (extension == '.vb') {
                mode = 'text/x-vb';
            }
            else if (extension == '.asp' || extension == '.asa') {
                mode = 'application/x-ejs';
            }
            else if (extension == '.aspx' || extension == '.asax') {
                mode = 'application/x-aspx';
            }
            else if (extension == '.js') {
                mode = 'javascript';
            }
            else if (extension == '.css') {
                mode = 'css';
            }
            else if (extension == '.xml') {
                mode = 'xml';
            }
            else if (extension == '.xsl') {
                mode = 'xml';
            }
            else if (extension == '.cs') {
                mode = 'text/x-csharp';
            }
            else if (extension == '.html' || extension == '.htm' || extension == '.xhtml' || extension == '.vbs' || extension == '.vb') {
                mode = {
                    name: "htmlmixed",
                    scriptTypes: [
                        { matches: /\/x-handlebars-template|\/x-mustache/i,  mode: null },
                        { matches: /(text|application)\/(x-)?vb(a|script)/i, mode: "vbscript" }
                    ]
                };
            }
            else {
                mode = 'text/html';
            }


            window.editor = CodeMirror.fromTextArea($code, {
                scrollbarStyle:   "native",
                mode:             mode,
                readOnly:         true,
                selectionPointer: true,
                extraKeys: {
                    "Alt-F": "findPersistent",
                    "Ctrl-Q": function (cm) {
                        cm.foldCode(cm.getCursor());
                    }
                },
                foldGutter:    true,
                matchBrackets: true,
                autofocus:     true,
                lineNumbers:   true,
                gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"]
            });
        }



        function formatXml(xml)
        {
            var formatted = '';
            var reg = /(>)(<)(\/*)/g;
            xml = xml.replace(reg, '$1\r\n$2$3');
            var pad = 0;
            var arr = xml.split('\r\n')
            var node;
            var indent;
            var padding;

            for (var index in arr)
            {
                node = arr[index]

                try
                {
                    indent = 0;
                    
                    if (node.match(/.+<\/\w[^>]*>$/))
                    {
                        indent = 0;
                    }
                    else if (node.match(/^<\/\w/))
                    {
                        if (pad != 0) {
                            pad -= 1;
                        }
                    }
                    else if (node.match(/^<\w[^>]*[^\/]>.*$/))
                    {
                        indent = 1;
                    }
                    else
                    {
                        indent = 0;
                    }

                    padding = '';
                    
                    for (var i = 0; i < pad; i++)
                    {
                        padding += '  ';
                    }

                    formatted += padding + node + '\r\n';
                    pad += indent;
                }
                catch (e) {}
            }

            return formatted;
        }
    </script>
</body>
</html>