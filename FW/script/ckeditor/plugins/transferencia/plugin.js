
CKEDITOR.plugins.add('transferencia', {
    icons: 'transferencia',
    onLoad: function () {
        if (CKEDITOR.config.transfvariable_class) {
            CKEDITOR.addCss(
                'transfvariable.' + CKEDITOR.config.transfvariable_class + ' {' +
                    CKEDITOR.config.transfvariable_style +
                    '}'
            );
        }
    },
    init: function (editor) {

        editor.addCommand('transfvariable', new CKEDITOR.dialogCommand('transferenciaDialog'));

        editor.ui.addButton('transferencia', {
            label: 'Parámetro Transferencia',
            command: 'transfvariable',
            toolbar: 'insert'
        });

        if (editor.contextMenu) {
            editor.addMenuGroup('transfvariableGroup');
            editor.addMenuItem('transfvariableItem', {
                label: 'Editar Parámetro',
                icon: this.path + 'icons/transferencia.png',
                command: 'transfvariable',
                group: 'transfvariableGroup'
            });

            editor.contextMenu.addListener(function (element) {
                if (element.getAscendant('transfvariable', true)) {
                    return { transfvariableItem: CKEDITOR.TRISTATE_OFF };
                }
            });
        }
        CKEDITOR.dialog.add('transferenciaDialog', this.path + 'dialogs/transferencia.js');
    }
   
});

if (typeof (CKEDITOR.config.transfvariable_style) == 'undefined')
    CKEDITOR.config.transfvariable_style = 'padding: 0;margin-left: 1px;background: #FFFF99;border: 1px solid #AAAA77;border-radius: 3px;position: relative;cursor: pointer;cursor: hand';
if (typeof (CKEDITOR.config.transfvariable_class) == 'undefined')
    CKEDITOR.config.transfvariable_class = 'transfvariable';
