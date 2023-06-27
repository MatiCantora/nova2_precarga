CKEDITOR.dialog.add('transferenciaDialog', function (editor) {
    return {
        title: 'Seleccionar Parámetros',
        minWidth: 400,
        minHeight: 200,

        contents: [
            {
                id: 'tab-basic',
                label: 'Basic Settings',
                elements: [
                    {
                        type: 'select',
                        items: [[""],
                        ["Fecha"],
                        ["Transf.id_transferencia"],
                        ["Transf.nombre"],
                        ["Transf.habi"],
                        ["Transf.timeout"],
                        ["Transf.estado"],
                        ["Transf.id_transf_log"],
                        ["Transf.transf_det_pendiente"],
                        ["Transf.cola_ejecucion"],
                        ["Transf.tareas[x]"],
                        ["Transf.param[x]"],
                        ["Transf.cola_ejecucion[x]"]], 'default': '',
                        id: 'variables',
                        label: 'Variables',
                        validate: CKEDITOR.dialog.validate.notEmpty("La variable se encuentra vacia."),

                        //setup: function (element) {
                        //    this.setValue(element.getText());
                        //},

                        //commit: function (element) {
                        //    element.setText(this.getValue());
                        //}
                        setup: function (element) {
                            this.setValue(element.getAttribute("varName"));
                        },

                        commit: function (element) {
                            element.setAttribute("varName", this.getValue());
                        },
                        onLoad: function () {
                            var selectList = this;
                            parent.parent.Transferencia.parametros.each(function (a,i) {
                                selectList.add(a.parametro, a.parametro);
                            })
                        }
                    },
                    {
                        type: 'text',
                        id: 'etiqueta',
                        label: 'Etiqueta',
                        validate: CKEDITOR.dialog.validate.notEmpty("La etiqueta se encuentra vacia."),

                        setup: function (element) {
                            this.setValue(element.getAttribute("varLabel"));
                            this.setValue(element.getText());
                        },

                        commit: function (element) {
                            element.setAttribute("varLabel", this.getValue());
                            element.setText(this.getValue());
                        }
                    }
                ]
            },
        ],

        onShow: function () {
            var selection = editor.getSelection();
            var element = selection.getStartElement();

            if (element)
                element = element.getAscendant('transfvariable', true);

            if (!element || element.getName() != 'transfvariable' || !element.hasClass(editor.config.transfvariable_class)) {
                element = editor.document.createElement('transfvariable');
                this.insertMode = true;
            }
            else
                this.insertMode = false;

            this.transfvariable = element;
            if (!this.insertMode)
                this.setupContent(this.transfvariable);
        },

        onOk: function () {
            
            if (editor.config.transfvariable_class)
                this.transfvariable.setAttribute('class', editor.config.transfvariable_class);

            if (this.insertMode)
                editor.insertElement(this.transfvariable);

            this.commitContent(this.transfvariable);

            //var dialog = this;
            //var transfvariable = this.element;
            //this.commitContent(transfvariable);

            //if (this.insertMode)
            //{
            //    editor.addContentsCss('transferencia/base.css');

            //    editor.insertElement(transfvariable);
            //    transfvariable.setAttribute('class', 'TransfVariable');
            //   // transfvariable.setAttribute('style', 'padding: 0;margin-left: 1px;background: #FFFF99;border: 1px solid #AAAA77;border-radius: 3px;position: relative;cursor: pointer;');
            //    //transfvariable.setAttribute('onclick', 'alert("sssss")');
                
            //}
               
        }
    };
});