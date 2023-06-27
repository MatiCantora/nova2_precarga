/*
Copyright (c) 2003-2017, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.md or http://ckeditor.com/license
*/
(function () {
    CKEDITOR.dialog.add("link", function (e) {
        var m = CKEDITOR.plugins.link,
            p, q = function () {
                var a = this.getDialog(),
                    b = a.getContentElement("target", "popupFeatures"),
                    a = a.getContentElement("target", "linkTargetName"),
                    n = this.getValue();
                if (b && a) switch (b = b.getElement(), b.hide(), a.setValue(""), n) {
                    case "frame":
                        a.setLabel(e.lang.link.targetFrameName);
                        a.getElement().show();
                        break;
                    case "popup":
                        b.show();
                        a.setLabel(e.lang.link.targetPopupName);
                        a.getElement().show();
                        break;
                    default:
                        a.setValue(n), a.getElement().hide()
                }
            },
            h = function (a) {
                a.target && this.setValue(a.target[this.id] || "")
            },
            f = function (a) {
                a.advanced && this.setValue(a.advanced[this.id] || "")
            },
            k = function (a) {
                a.target || (a.target = {});
                a.target[this.id] = this.getValue() || ""
            },
            l = function (a) {
                a.advanced || (a.advanced = {});
                a.advanced[this.id] = this.getValue() || ""
            },
            c = e.lang.common,
            b = e.lang.link,
            g;
        return {
            title: b.title,
            minWidth: "moono-lisa" == (CKEDITOR.skinName || e.config.skin) ? 450 : 350,
            minHeight: 240,
            contents: [{
                id: "info",
                label: b.info,
                title: b.info,
                elements: [{
                    type: "text",
                    id: "linkDisplayText",
                    label: b.displayText,
                    setup: function () {
                        this.enable();
                        this.setValue(e.getSelection().getSelectedText());
                        p = this.getValue()
                    },
                    commit: function (a) {
                        a.linkText = this.isEnabled() ? this.getValue() : ""
                    }
                }, {
                    id: "linkType",
                    type: "select",
                    label: b.type,
                    "default": "url",
                    items: [
                        [b.toUrl, "url"],
                        [b.toAnchor, "anchor"],
                        [b.toEmail, "email"]
                    ],
                    onChange: function () {
                        var a = this.getDialog(),
                            b = ["urlOptions", "anchorOptions", "emailOptions"],
                            n = this.getValue(),
                            d = a.definition.getContents("upload"),
                            d = d && d.hidden;
                        "url" == n ? (e.config.linkShowTargetTab &&
                            a.showPage("target"), d || a.showPage("upload")) : (a.hidePage("target"), d || a.hidePage("upload"));
                        for (d = 0; d < b.length; d++) {
                            var c = a.getContentElement("info", b[d]);
                            c && (c = c.getElement().getParent().getParent(), b[d] == n + "Options" ? c.show() : c.hide())
                        }
                        a.layout()
                        // Si valor de seleccion es "URL" => mostrar todos sus componentes
                        if ("url" == n) {
                            // si elemento selURLType existe (esta creado) => mostrarlos
                            if ($("selURLType")) {
                                $("selURLType").show()

                                // si la opcion seleccionada es "Archivo Interno" o "Referencia", deshabilitar selector de protocolo e input de URL
                                if ($('selURLType').value == 'f_interno' || $('selURLType').value == 'referencia') {
                                    $("selURLType").selProtocolo.disabled = true
                                    $("selURLType").selProtocolo.setValue("")
                                    $("selURLType").input_url.disabled = true
                                    $("selURLType").selProtocolo.addClassName('disabled')
                                    $("selURLType").input_url.addClassName('disabled')
                                }
                                else {
                                    // caso contrario habilitar los campos antes deshabilitados
                                    $("selURLType").selProtocolo.disabled = false
                                    $("selURLType").selProtocolo.setValue("")
                                    $("selURLType").input_url.disabled = false
                                    $("selURLType").selProtocolo.removeClassName('disabled')
                                    $("selURLType").input_url.removeClassName('disabled')
                                }
                            }
                            else {
                                // Aqui crear los componentes, mostrarlos y luego mantener las referecias con el elemento "selURLType"
                                // nuevo selector de opciones para las URL
                                var strHTML = "<select class='cke_dialog_ui_input_select' style='width:120px !Important' id='selURLType' name='selURLType'>"
                                strHTML += "<option value='f_interno' default='true'>Archivo interno</option>"
                                strHTML += "<option value='f_externo' >Archivo externo</option>"
                                strHTML += "<option value='referencia' >Referencia</option>"
                                strHTML += "</select>"

                                // capturamos el elemento select donde esta la opcion URL para "fixear" su ancho
                                var url_select = a.parts.contents.$.select("SELECT")[0]
                                $(url_select).setStyle({ width: "200px" })
                                $(url_select).attributes["style"].value = "width:200px !Important"
                                document.styleSheets[0].insertRule("#campo_def_tbf_id td {padding-left:2px; padding-right:2px;}", 0)
                                document.styleSheets[0].insertRule(".disabled {background-color: #EFEFEF !important;}", 0)

                                // insertar nuevo selector creado junto al anterior (existente)
                                url_select.insertAdjacentHTML("afterEnd", strHTML)

                                var divWidth = $($("selURLType").parentElement.parentElement).getWidth() - 5
                                // tabla para la opcion de "Archivo Interno"
                                strHTML = "<table id='tbType' class='tb1' style='margin-top: 1em;width:" + divWidth + "px' >"
                                strHTML += "<tr>"
                                strHTML += "<td><div id='miCampoDef01' style='width:100%'></div></td>"
                                strHTML += "</tr><tr>"
                                strHTML += "<td><input type='checkbox' id='chkLastVersion' name='chkLastVersion' checked='true' style='margin-top: 1em'/><label for='chkLastVersion' style='margin-left: 0.5em'>Vínculo a la última version</label></td>"
                                strHTML += "</tr>"
                                strHTML += "</table>"

                                // tabla para opcion de "Referencia"
                                strHTML += "<table id='tbReferencias' class='tb1' style='margin-top: 1em;width:" + divWidth + "px;display:none'>"
                                strHTML += "<tr>"
                                strHTML += "<td><div id='campoDefReferencia' style='width:100%'></div></td>"
                                strHTML += "</tr>"
                                strHTML += "</table>"

                                // Insertar las tablas recien creadas
                                $("selURLType").insertAdjacentHTML("afterEnd", strHTML)

                                // agregar observacion al evento "Change" para el select de tipos de URL
                                $("selURLType").observe("change", function () {
                                    var valorTipo = $('selURLType').value
                                    
                                    if (valorTipo == 'f_interno' || valorTipo == 'referencia') {
                                        $("selURLType").selProtocolo.setValue("")
                                        $("selURLType").selProtocolo.disabled = true
                                        $("selURLType").selProtocolo.addClassName('disabled')
                                        $("selURLType").input_url.disabled = true
                                        $("selURLType").input_url.setValue("")
                                        $("selURLType").input_url.addClassName('disabled')

                                        
                                        // Mostrar los campos segun corresponda
                                        // Archivo interno
                                        if (valorTipo == 'f_interno') {
                                            $("selURLType").tbReferencia.hide()
                                            $("selURLType").tbType.show()
                                            // si el campo_def "f_id" no esta vacio, ejecuto el onchange
                                            if (campos_defs.get_value("f_id") != "")
                                                campos_defs.items["f_id"].onchange()
                                        }
                                        // Referencia
                                        else {
                                            $("selURLType").tbType.hide()
                                            $("selURLType").tbReferencia.show()
                                            // si el campo_def "ref" no esta vacio, ejecuto el onchange
                                            if (campos_defs.get_value("ref") != "")
                                                campos_defs.items["ref"].onchange()
                                        }
                                    } else {
                                        // en otro caso, ocultamos las tablas creadas y dejamos los campos originales con sus valor por defecto
                                        $("selURLType").tbType.hide()
                                        $("selURLType").tbReferencia.hide()
                                        $("selURLType").selProtocolo.disabled = false
                                        $("selURLType").selProtocolo.removeClassName('disabled')
                                        $("selURLType").selProtocolo.setValue("http://")
                                        $("selURLType").input_url.disabled = false
                                        $("selURLType").input_url.removeClassName('disabled')
                                        $("selURLType").input_url.setValue("")

                                        try {
                                            //$('cke_135_select').value = "_blank"
                                            CKEDITOR.dialog.getCurrent().getContentElement("target", "linkTargetType").setValue("_blank")
                                        } catch (excep) { }
                                    }
                                })

                                // Crear un "campos_defs" => "Archivos internos"
                                campos_defs.add("f_id", { target: "miCampoDef01", nro_campo_tipo: 90, enDB: false })
                                campos_defs.items["f_id"]["input_text"].setStyle({ border: "solid #bcbcbc 1px", height: "28px", borderRadius: "2px", boxSizing: "border-box", padding: "4px 6px 4px 6px" })
                                campos_defs.items["f_id"].input_hidden.addClassName("cke_dialog_ui_input_text")
                                campos_defs.items["f_id"].onchange = function () {
                                    // Ejecutar el onchange solo si el campo_def no esta vacio
                                    if (campos_defs.get_value("f_id") != "") {
                                        var parametros = ""

                                        if ($("selURLType").chk_lastVersion.checked)
                                        //parametros = "ref_files_path=" + campos_defs.get_desc("f_id").split(" ")[0]
                                            parametros = "ref_files_path=" + campos_defs.get_desc("f_id")
                                        else
                                            parametros = "f_id=" + campos_defs.get_value("f_id")

                                        // armar la URL completa y asignarla al input URL
                                        $("selURLType").input_url.value = $("selURLType").path_file_get + parametros
                                    }
                                    else {
                                        // si el campo_def esta vacio, limpiar el input URL
                                        $("selURLType").input_url.setValue("")
                                    }

                                    // Limpiar cualquier seleccion luego de modificar el input URL
                                    nvFW.selection_clear()
                                }

                                // asignar la misma funcionalidad "onchange" del campo_def "f_id" al checkbox
                                $("chkLastVersion").onchange = campos_defs.items["f_id"].onchange

                                // Crear un "campos_defs" => "Referencias"
                                // primero obtener el fitroXML encriptado para este caso

                                var err = nvFW.error_ajax_request("/fw/script/ckeditor/get_campo_def_ref_id_filtroXML.aspx", { asynchronous: false })
                                var filtroXML = err.params.filtroXML
                                campos_defs.add("ref", { enDB: false, nro_campo_tipo: 3, filtroXML: filtroXML, campo_codigo: 'nro_ref', campo_desc: "referencia", target: "campoDefReferencia" })
                                campos_defs.items["ref"]["input_text"].setStyle({ border: "solid #bcbcbc 1px", height: "28px", borderRadius: "2px", boxSizing: "border-box", padding: "4px 6px 4px 6px" })
                                campos_defs.items["ref"].onchange = function () {
                                    // ejecutar solo si su valor es distinto de vacio
                                    if (campos_defs.get_value("ref") != "") {
                                        //$("selURLType").input_url.value = $("selURLType").path_referencia + "nro_ref=" + campos_defs.get_value("ref")
                                        $("selURLType").input_url.value = "/wiki/mostrar_ref.aspx?" + "nro_ref=" + campos_defs.get_value("ref") + "&target="
                                    }
                                    else {
                                        // si la referencia esta vacia, limpiar la URL armada
                                        $("selURLType").input_url.setValue("")
                                    }

                                    // Limpiar cualquier seleccion luego de modificar el input URL
                                    nvFW.selection_clear()
                                }

                                // mantener todas las referencias de los elementos creados junto al elemento principal "selURLType"
                                $("selURLType").input_url = $(a.parts.contents.$.select("INPUT")[6])
                                $("selURLType").chk_lastVersion = $("chkLastVersion")
                                $("selURLType").tbType = $("tbType")
                                $("selURLType").tbReferencia = $("tbReferencias")
                                $("selURLType").selProtocolo = $(a.parts.contents.$.select("select")[2])

                                $("selURLType").path_file_get = "/fw/files/file_get.aspx?"
                                $("selURLType").path_referencia = "/wiki/default.aspx?"

                                // Por defecto, deshabilitar protocolo y URL
                                // selector de protocolo
                                $("selURLType").selProtocolo.setValue("")
                                $("selURLType").selProtocolo.disabled = true
                                $("selURLType").selProtocolo.addClassName('disabled')
                                // input URL
                                $("selURLType").input_url.disabled = true
                                $("selURLType").input_url.addClassName('disabled')
                            }

                            if ($('selURLType').input_url.value == "" && this.setup.arguments[0].url != undefined) {

                                var url = this.setup.arguments[0].url.url
                                if (url.startsWith("javascript:window.top.open_nvFW_window(")) {
                                    $('selURLType').input_url.value = url.substring(40, url.length - 2).replace(/\\\\/g, "\\")
                                } else {

                                    $('selURLType').input_url.value = url

                                }


                                /*var url = this.setup.arguments[0].url.url
                                if (url.startsWith("https://")) {
                                this.setup.arguments[0].url.url = url.substring(8, url.length)
                                this.setup.arguments[0].url.protocol = "https://"
                                url = this.setup.arguments[0].url.url
                                }
                                $('selURLType').input_url.value = url*/

                            }


                            // verificar si el campo URL esta vacio (nuevo link) o esta seteado (edicion de link)
                            if ($('selURLType').input_url.value != '') {

                                $('selURLType').value = "f_externo"

                                // verificar si la URL matchea con "f_id"
                                var strReg = "file_get.aspx?.*f_id=(\\d*)",
                                    reg = new RegExp(strReg, "i"),
                                    m = reg.exec($('selURLType').input_url.value)

                                if (m != null) {
                                    // limpio el campo_def que no corresponde aqui
                                    campos_defs.clear("ref")
                                    $("selURLType").chk_lastVersion.checked = false
                                    $('selURLType').value = "f_interno"
                                    // cargo el campo_def correcto
                                    campos_defs.set_value("f_id", m[1])
                                }

                                // verificar si matchea con "ref_files_path"
                                strReg = "file_get.aspx?.*ref_files_path=([^\&]*)"
                                reg = new RegExp(strReg, "i")
                                m = reg.exec($('selURLType').input_url.value)

                                if (m != null) {
                                    // limpio el campo_def que no corresponde aqui
                                    campos_defs.clear("ref")
                                    $("selURLType").chk_lastVersion.checked = true
                                    $('selURLType').value = "f_interno"
                                    // uso un ajax request para obtener el ID (f_id) a partir del valor en "ref_files_path"
                                    // el campo_def numero 90 no tiene definido un filtroXML
                                    var erRes = nvFW.error_ajax_request("/fw/files/file_properties.aspx", { asynchronous: false, parameters: { modo: "get_properties", ref_files_path: m[1] }, error_alert:false, onFailure: function (err) { } })

                                    if (erRes.numError == 0) {
                                        campos_defs.set_value("f_id", erRes.params["f_id"])
                                    }
                                }

                                // verificar si matchea con "nro_ref" (referencia)
                                strReg = "default.aspx?.*nro_ref=(\\d*)"
                                reg = new RegExp(strReg, "i")
                                m = reg.exec($('selURLType').input_url.value)

                                strReg = "mostrar_ref.aspx?.*nro_ref=(\\d*)"
                                reg = new RegExp(strReg, "i")
                                var m2 = reg.exec($('selURLType').input_url.value)

                                if (m != null || m2 != null) {
                                    // limpio el campo_def que no corresponde aqui
                                    campos_defs.clear("f_id")
                                    $('selURLType').value = "referencia"
                                    // cargo el campo_def correcto
                                    if (m != null) {
                                        campos_defs.set_value("ref", m[1])
                                    } else if (m2 != null) {
                                        campos_defs.set_value("ref", m2[1])
                                    }
                                }

                                if ($('selURLType').value == "f_externo") {
                                    $("selURLType").selProtocolo.disabled = false
                                    $("selURLType").selProtocolo.setValue("")
                                    $("selURLType").input_url.disabled = false
                                    $("selURLType").selProtocolo.removeClassName('disabled')
                                    $("selURLType").input_url.removeClassName('disabled')
                                }
                            }
                            // si la URL esta vacia (nuevo link), setear valores por defecto
                            else {
                                // limpio los campos_defs
                                campos_defs.clear("f_id")
                                campos_defs.clear("ref")
                                // checkbox chequeado
                                $("selURLType").chk_lastVersion.checked = true
                                // selector en "archivo interno"
                                $("selURLType").value = "f_interno"
                            }

                            // mostrar campos correspondientes segun el tipo seleccionado
                            $('selURLType').value == 'f_interno' ? $("selURLType").tbType.show() : $("selURLType").tbType.hide()
                            $('selURLType').value == 'referencia' ? $("selURLType").tbReferencia.show() : $("selURLType").tbReferencia.hide()
                        }
                        // Si la opcion NO es URL
                        else {
                            if ($("selURLType")) {
                                // ocultar selector de tipos de URL
                                $("selURLType").hide()
                                // ocultar opciones del campo_def para archivos internos
                                $("selURLType").tbType.hide()
                                // ocultar opciones del campo_def para referencias
                                $("selURLType").tbReferencia.hide()
                            }
                        }
                    },
                    setup: function (a) {
                        var url = !a.url ? "" : a.url.url
                        var pos = url.indexOf("javascript:window.top.open_nvFW_window('")
                        if (pos == 0)
                          {
                          index = pos + "javascript:window.top.open_nvFW_window('".length
                          url = url.substr(index, url.length - index - 2)
                          a.url.url = url.replace(/\\\\/g, "\\")
                          }
                        //if (a.target && a.target.type == "_nvfwWindow") {
                            //var url = this.setup.arguments[0].url.url
                            //var protocols = ["https://", "http://", "ftp://", "news://"]
                            //for (i in protocols) {
                            //    var p = protocols[i]
                            //    if (url.startsWith(p)) {
                            //        this.setup.arguments[0].url.url = url.substring(p.length, url.length)
                            //        this.setup.arguments[0].url.protocol = p
                            //        break;
                            //    }
                            //}
                        //}

                        this.setValue(a.type || "url")
                    },
                    commit: function (a) {
                        a.type = this.getValue()
                    }
                }, {
                    type: "vbox",
                    id: "urlOptions",
                    children: [{
                        type: "hbox",
                        widths: ["25%", "75%"],
                        children: [{
                            id: "protocol",
                            type: "select",
                            label: c.protocol,
                            "default": "http://",
                            items: [
                                ["http://‎",
                                    "http://"
                                ],
                                ["https://‎", "https://"],
                                ["ftp://‎", "ftp://"],
                                ["news://‎", "news://"],
                                [b.other, ""]
                            ],
                            setup: function (a) {
                                a.url && this.setValue(a.url.protocol || "")
                            },
                            commit: function (a) {
                                a.url || (a.url = {});
                                a.url.protocol = this.getValue()
                            }
                        }, {
                            type: "text",
                            id: "url",
                            label: c.url,
                            required: !0,
                            onLoad: function () {
                                this.allowOnChange = !0
                            },
                            onKeyUp: function () {
                                this.allowOnChange = !1;
                                var a = this.getDialog().getContentElement("info", "protocol"),
                                    b = this.getValue(),
                                    c = /^((javascript:)|[#\/\.\?])/i,
                                    d = /^(http|https|ftp|news):\/\/(?=.)/i.exec(b);
                                d ? (this.setValue(b.substr(d[0].length)), a.setValue(d[0].toLowerCase())) : c.test(b) && a.setValue("");
                                this.allowOnChange = !0
                            },
                            onChange: function () {
                                if (this.allowOnChange) this.onKeyUp()
                            },
                            validate: function () {
                                var a = this.getDialog();
                                return a.getContentElement("info", "linkType") && "url" != a.getValueOf("info", "linkType") ? !0 : !e.config.linkJavaScriptLinksAllowed && /javascript\:/.test(this.getValue()) ? (alert(c.invalidValue), !1) : this.getDialog().fakeObj ? !0 : CKEDITOR.dialog.validate.notEmpty(b.noUrl).apply(this)
                            },
                            setup: function (a) {
                                this.allowOnChange = !1;
                                a.url && this.setValue(a.url.url);
                                this.allowOnChange = !0
                            },
                            commit: function (a) {
                                this.onChange();
                                a.url || (a.url = {});
                                a.url.url = this.getValue();
                                this.allowOnChange = !1
                            }
                        }],
                        setup: function () {
                            this.getDialog().getContentElement("info", "linkType") || this.getElement().show()
                        }
                    }, {
                        type: "button",
                        id: "browse",
                        hidden: "true",
                        filebrowser: "info:url",
                        label: c.browseServer
                    }]
                }, {
                    type: "vbox",
                    id: "anchorOptions",
                    width: 260,
                    align: "center",
                    padding: 0,
                    children: [{
                        type: "fieldset",
                        id: "selectAnchorText",
                        label: b.selectAnchor,
                        setup: function () {
                            g =
                                m.getEditorAnchors(e);
                            this.getElement()[g && g.length ? "show" : "hide"]()
                        },
                        children: [{
                            type: "hbox",
                            id: "selectAnchor",
                            children: [{
                                type: "select",
                                id: "anchorName",
                                "default": "",
                                label: b.anchorName,
                                style: "width: 100%;",
                                items: [
                                    [""]
                                ],
                                setup: function (a) {
                                    this.clear();
                                    this.add("");
                                    if (g)
                                        for (var b = 0; b < g.length; b++) g[b].name && this.add(g[b].name);
                                    a.anchor && this.setValue(a.anchor.name);
                                    (a = this.getDialog().getContentElement("info", "linkType")) && "email" == a.getValue() && this.focus()
                                },
                                commit: function (a) {
                                    a.anchor || (a.anchor = {});
                                    a.anchor.name = this.getValue()
                                }
                            }, {
                                type: "select",
                                id: "anchorId",
                                "default": "",
                                label: b.anchorId,
                                style: "width: 100%;",
                                items: [
                                    [""]
                                ],
                                setup: function (a) {
                                    this.clear();
                                    this.add("");
                                    if (g)
                                        for (var b = 0; b < g.length; b++) g[b].id && this.add(g[b].id);
                                    a.anchor && this.setValue(a.anchor.id)
                                },
                                commit: function (a) {
                                    a.anchor || (a.anchor = {});
                                    a.anchor.id = this.getValue()
                                }
                            }],
                            setup: function () {
                                this.getElement()[g && g.length ? "show" : "hide"]()
                            }
                        }]
                    }, {
                        type: "html",
                        id: "noAnchors",
                        style: "text-align: center;",
                        html: '\x3cdiv role\x3d"note" tabIndex\x3d"-1"\x3e' +
                            CKEDITOR.tools.htmlEncode(b.noAnchors) + "\x3c/div\x3e",
                        focus: !0,
                        setup: function () {
                            this.getElement()[g && g.length ? "hide" : "show"]()
                        }
                    }],
                    setup: function () {
                        this.getDialog().getContentElement("info", "linkType") || this.getElement().hide()
                    }
                }, {
                    type: "vbox",
                    id: "emailOptions",
                    padding: 1,
                    children: [{
                        type: "text",
                        id: "emailAddress",
                        label: b.emailAddress,
                        required: !0,
                        validate: function () {
                            var a = this.getDialog();
                            return a.getContentElement("info", "linkType") && "email" == a.getValueOf("info", "linkType") ? CKEDITOR.dialog.validate.notEmpty(b.noEmail).apply(this) :
                                !0
                        },
                        setup: function (a) {
                            a.email && this.setValue(a.email.address);
                            (a = this.getDialog().getContentElement("info", "linkType")) && "email" == a.getValue() && this.select()
                        },
                        commit: function (a) {
                            a.email || (a.email = {});
                            a.email.address = this.getValue()
                        }
                    }, {
                        type: "text",
                        id: "emailSubject",
                        label: b.emailSubject,
                        setup: function (a) {
                            a.email && this.setValue(a.email.subject)
                        },
                        commit: function (a) {
                            a.email || (a.email = {});
                            a.email.subject = this.getValue()
                        }
                    }, {
                        type: "textarea",
                        id: "emailBody",
                        label: b.emailBody,
                        rows: 3,
                        "default": "",
                        setup: function (a) {
                            a.email &&
                                this.setValue(a.email.body)
                        },
                        commit: function (a) {
                            a.email || (a.email = {});
                            a.email.body = this.getValue()
                        }
                    }],
                    setup: function () {
                        this.getDialog().getContentElement("info", "linkType") || this.getElement().hide()
                    }
                }]
            }, {
                id: "target",
                requiredContent: "a[target]",
                label: b.target,
                title: b.target,
                elements: [{
                    type: "hbox",
                    widths: ["50%", "50%"],
                    children: [{
                        type: "select",
                        id: "linkTargetType",
                        label: c.target,
                        "default": "nvfwWindow", //"notSet",
                        style: "width : 100%;",
                        items: [
                            [c.notSet, "notSet"],
                            [b.targetFrame, "frame"],
                            [b.targetPopup, "popup"],
                            [c.targetNew,
                                "_blank"
                            ],
                            [c.targetTop, "_top"],
                            [c.targetSelf, "_self"],
                            [c.targetParent, "_parent"],
                            [c.nvfwWindow, "_nvfwWindow"]
                        ],
                        onChange: q,
                        setup: function (a) {
                            //Si habre la primera vez (no tiene target)  se coloca por defecto el valor 
                            var url = !a.url ? "" : a.url.url

                            if (!a.target || url.indexOf("open_nvFW_window") != -1) 
                                this.setValue("_nvfwWindow")
                            else
                                a.target && this.setValue(a.target.type || "notSet")
                            //a.target && this.setValue(a.target.type || "_nvfwWindow");
                            q.call(this)
                        },
                        commit: function (a) {
                            a.target || (a.target = {});
                            a.target.type = this.getValue()
                            if (a.target.type === "_nvfwWindow") {
                                if (a.linkText === "") {
                                    a.linkText = a.url.protocol + a.url.url
                                }
                                a.url.url = "javascript:window.top.open_nvFW_window('" + a.url.protocol + a.url.url.replace(/\\/g, "\\\\") + "')"
                                a.url.protocol = ""
                                a.target.type = "notSet";
                            }
                        }
                    }, {
                        type: "text",
                        id: "linkTargetName",
                        label: b.targetFrameName,
                        "default": "",
                        setup: function (a) {
                            a.target && this.setValue(a.target.name)
                        },
                        commit: function (a) {
                            a.target || (a.target = {});
                            a.target.name = this.getValue().replace(/([^\x00-\x7F]|\s)/gi, "")
                        }
                    }]
                }, {
                    type: "vbox",
                    width: "100%",
                    align: "center",
                    padding: 2,
                    id: "popupFeatures",
                    children: [{
                        type: "fieldset",
                        label: b.popupFeatures,
                        children: [{
                            type: "hbox",
                            children: [{
                                type: "checkbox",
                                id: "resizable",
                                label: b.popupResizable,
                                setup: h,
                                commit: k
                            }, {
                                type: "checkbox",
                                id: "status",
                                label: b.popupStatusBar,
                                setup: h,
                                commit: k
                            }]
                        }, {
                            type: "hbox",
                            children: [{
                                type: "checkbox",
                                id: "location",
                                label: b.popupLocationBar,
                                setup: h,
                                commit: k
                            }, {
                                type: "checkbox",
                                id: "toolbar",
                                label: b.popupToolbar,
                                setup: h,
                                commit: k
                            }]
                        }, {
                            type: "hbox",
                            children: [{
                                type: "checkbox",
                                id: "menubar",
                                label: b.popupMenuBar,
                                setup: h,
                                commit: k
                            }, {
                                type: "checkbox",
                                id: "fullscreen",
                                label: b.popupFullScreen,
                                setup: h,
                                commit: k
                            }]
                        }, {
                            type: "hbox",
                            children: [{
                                type: "checkbox",
                                id: "scrollbars",
                                label: b.popupScrollBars,
                                setup: h,
                                commit: k
                            }, {
                                type: "checkbox",
                                id: "dependent",
                                label: b.popupDependent,
                                setup: h,
                                commit: k
                            }]
                        }, {
                            type: "hbox",
                            children: [{
                                type: "text",
                                widths: ["50%", "50%"],
                                labelLayout: "horizontal",
                                label: c.width,
                                id: "width",
                                setup: h,
                                commit: k
                            }, {
                                type: "text",
                                labelLayout: "horizontal",
                                widths: ["50%", "50%"],
                                label: b.popupLeft,
                                id: "left",
                                setup: h,
                                commit: k
                            }]
                        }, {
                            type: "hbox",
                            children: [{
                                type: "text",
                                labelLayout: "horizontal",
                                widths: ["50%", "50%"],
                                label: c.height,
                                id: "height",
                                setup: h,
                                commit: k
                            }, {
                                type: "text",
                                labelLayout: "horizontal",
                                label: b.popupTop,
                                widths: ["50%", "50%"],
                                id: "top",
                                setup: h,
                                commit: k
                            }]
                        }]
                    }]
                }]
            }, {
                id: "upload",
                label: b.upload,
                title: b.upload,
                hidden: !0,
                filebrowser: "uploadButton",
                elements: [{
                    type: "file",
                    id: "upload",
                    label: c.upload,
                    style: "height:40px",
                    size: 29
                }, {
                    type: "fileButton",
                    id: "uploadButton",
                    label: c.uploadSubmit,
                    filebrowser: "info:url",
                    "for": ["upload",
                        "upload"
                    ]
                }]
            }, {
                id: "advanced",
                label: b.advanced,
                title: b.advanced,
                elements: [{
                    type: "vbox",
                    padding: 1,
                    children: [{
                        type: "hbox",
                        widths: ["45%", "35%", "20%"],
                        children: [{
                            type: "text",
                            id: "advId",
                            requiredContent: "a[id]",
                            label: b.id,
                            setup: f,
                            commit: l
                        }, {
                            type: "select",
                            id: "advLangDir",
                            requiredContent: "a[dir]",
                            label: b.langDir,
                            "default": "",
                            style: "width:110px",
                            items: [
                                [c.notSet, ""],
                                [b.langDirLTR, "ltr"],
                                [b.langDirRTL, "rtl"]
                            ],
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            id: "advAccessKey",
                            requiredContent: "a[accesskey]",
                            width: "80px",
                            label: b.acccessKey,
                            maxLength: 1,
                            setup: f,
                            commit: l
                        }]
                    }, {
                        type: "hbox",
                        widths: ["45%", "35%", "20%"],
                        children: [{
                            type: "text",
                            label: b.name,
                            id: "advName",
                            requiredContent: "a[name]",
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            label: b.langCode,
                            id: "advLangCode",
                            requiredContent: "a[lang]",
                            width: "110px",
                            "default": "",
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            label: b.tabIndex,
                            id: "advTabIndex",
                            requiredContent: "a[tabindex]",
                            width: "80px",
                            maxLength: 5,
                            setup: f,
                            commit: l
                        }]
                    }]
                }, {
                    type: "vbox",
                    padding: 1,
                    children: [{
                        type: "hbox",
                        widths: ["45%", "55%"],
                        children: [{
                            type: "text",
                            label: b.advisoryTitle,
                            requiredContent: "a[title]",
                            "default": "",
                            id: "advTitle",
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            label: b.advisoryContentType,
                            requiredContent: "a[type]",
                            "default": "",
                            id: "advContentType",
                            setup: f,
                            commit: l
                        }]
                    }, {
                        type: "hbox",
                        widths: ["45%", "55%"],
                        children: [{
                            type: "text",
                            label: b.cssClasses,
                            requiredContent: "a(cke-xyz)",
                            "default": "",
                            id: "advCSSClasses",
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            label: b.charset,
                            requiredContent: "a[charset]",
                            "default": "",
                            id: "advCharset",
                            setup: f,
                            commit: l
                        }]
                    }, {
                        type: "hbox",
                        widths: ["45%", "55%"],
                        children: [{
                            type: "text",
                            label: b.rel,
                            requiredContent: "a[rel]",
                            "default": "",
                            id: "advRel",
                            setup: f,
                            commit: l
                        }, {
                            type: "text",
                            label: b.styles,
                            requiredContent: "a{cke-xyz}",
                            "default": "",
                            id: "advStyles",
                            validate: CKEDITOR.dialog.validate.inlineStyle(e.lang.common.invalidInlineStyle),
                            setup: f,
                            commit: l
                        }]
                    }, {
                        type: "hbox",
                        widths: ["45%", "55%"],
                        children: [{
                            type: "checkbox",
                            id: "download",
                            requiredContent: "a[download]",
                            label: b.download,
                            setup: function (a) {
                                void 0 !== a.download && this.setValue("checked", "checked")
                            },
                            commit: function (a) {
                                this.getValue() && (a.download =
                                    this.getValue())
                            }
                        }]
                    }]
                }]
            }],
            onShow: function () {
                var a = this.getParentEditor(),
                    b = a.getSelection(),
                    c = b.getSelectedElement(),
                    d = this.getContentElement("info", "linkDisplayText").getElement().getParent().getParent(),
                    e = null;
                (e = m.getSelectedLink(a)) && e.hasAttribute("href") ? c || (b.selectElement(e), c = e) : e = null;
                m.showDisplayTextForElement(c, a) ? d.show() : d.hide();
                a = m.parseLinkAttributes(a, e);
                this._.selectedElement = e;

                // si c != null && $('selURLType').input_url != null => setear el valor desde 'c'
                try {
                    if (a.target.type === "_nvfwWindow") {
                        a.url.url = a.url.url.substring(40, a.url.url.length - 2)
                        a.url.url = a.url.url.replace(/\\\\/g, "\\")
                    }
                } catch (e) { }

                if (c != null && $('selURLType')) {
                    if ($('selURLType').input_url != null) {
                        if (a.target && a.target.type === "_nvfwWindow") {
                            $('selURLType').input_url.value = a.url.url
                        } else {
                            $('selURLType').input_url.value = a.url.url //c.$.pathname + c.$.search
                        }
                    }
                }

                this.setupContent(a)

            },
            onOk: function () {
                //debugger
                var a = {};
                this.commitContent(a);
                var b = e.getSelection(),
                    c = m.getLinkAttributes(e, a);
                if (this._.selectedElement) {
                    var d = this._.selectedElement,
                        g = d.data("cke-saved-href") + a.target.type,
                        h = d.getHtml(),
                        f;
                    d.setAttributes(c.set);
                    d.removeAttributes(c.removed);
                    if (a.linkText && p != a.linkText) f = a.linkText;
                    else if (g == h || "email" == a.type && -1 != h.indexOf("@")) f = "email" == a.type ? a.email.address : c.set["data-cke-saved-href"];
                    f && (d.setText(f), b.selectElement(d));
                    delete this._.selectedElement
                } else {
                    b = b.getRanges()[0];
                    b.collapsed ? (a = new CKEDITOR.dom.text(a.linkText || ("email" == a.type ? a.email.address : c.set["data-cke-saved-href"]),
                        e.document), b.insertNode(a), b.selectNodeContents(a)) : p !== a.linkText && (a = new CKEDITOR.dom.text(a.linkText, e.document), b.shrink(CKEDITOR.SHRINK_TEXT), e.editable().extractHtmlFromRange(b), b.insertNode(a));
                    a = b._find("a");
                    for (d = 0; d < a.length; d++) a[d].remove(!0);
                    c = new CKEDITOR.style({
                        element: "a",
                        attributes: c.set
                    });
                    c.type = CKEDITOR.STYLE_INLINE;
                    c.applyToRange(b, e);
                    b.select()
                }
            },
            onLoad: function () {
                e.config.linkShowAdvancedTab || this.hidePage("advanced");
                e.config.linkShowTargetTab || this.hidePage("target")
            },
            onFocus: function () {
                var a =
                    this.getContentElement("info", "linkType");
                a && "url" == a.getValue() && (a = this.getContentElement("info", "url"), a.select())
            }
        }
    })
})();