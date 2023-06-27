/**
 * @license Copyright (c) 2003-2017, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
    // config.uiColor = '#AADC6E';
    
		config.language = 'es';
		config.allowedContent = true;

		// Sets SCAYT
		config.scayt_sLang = 'es_ES';


      //config.stylesCombo_stylesSet = 'transfvariable';
      //config.transferencia_css =[{
      //                              name: 'transfvariable',
      //                               element: 'transfvariable',
      //                               attributes: { 'padding': '0', 'margin-left': '1px', 'background': '#FFFF99', 'border': '1px solid #AAAA77', 'border-radius': '3px', 'position': 'relative', 'cursor': 'pointer', 'cursor': 'hand' }
      //  }],

      config.toolbar_Comentarios = [
            ['FitWindow', 'Source'],
            ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteWord', '-'],
            ['Undo', 'Redo', '-', 'SelectAll'],
            ['OrderedList', 'UnorderedList', '-', 'Outdent', 'Indent'],
            ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyFull'],
			['NumberedList', 'BulletedList']
        ];

        config.toolbar_Transferencia = [
            ['FitWindow', 'Source'],
            ['Cut', 'Copy', 'Paste', 'PasteText', 'PasteWord', '-'],
            ['Undo', 'Redo', '-', 'SelectAll'],
            ['OrderedList', 'UnorderedList', '-', 'Outdent', 'Indent'],
            ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyFull'],
            ['Link', 'Unlink'],
            ['Style','FontFormat','FontName','FontSize','TextColor','BGColor'],
            ['transferencia','Abbr']
        ];

	config.toolbar_referencias = [
        [ 'Source', '-', 'NewPage', 'Preview', '-', 'Templates' ], //'Save','DocProps','Print','-','Templates' 
		[ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ],
		[ 'Find', 'Replace', '-', 'SelectAll', '-', 'Scayt' ],
		//[ 'Form', 'Checkbox', 'Radio', 'TextField', 'Textarea', 'Select', 'Button', 'ImageButton', 'HiddenField' ]
		[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ],
		[ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl'],
		[ 'Link', 'Unlink', 'Anchor' ],//'CreateDiv',
		[ 'Image','Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak',],//'Flash','Iframe' 
		[ 'Styles', 'Format', 'Font', 'FontSize' ],
		[ 'TextColor', 'BGColor' ],
		[ 'Maximize', 'ShowBlocks' ]//'About' 

	];

};
