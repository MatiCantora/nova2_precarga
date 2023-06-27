// ### Transf Variable
//--------------------------------------------//
var FCKDocumentProcessor_CreateFakeSpan = function(fakeClass, realElement) {
    var oButton = FCKTools.GetElementDocument(realElement).createElement('INPUT');
    oButton.className = fakeClass;
    oButton.type = 'button';
    
    oButton.setAttribute('_fckfakelement', 'true', 0);
    oButton.setAttribute('_fckrealelement', FCKTempBin.AddElement(realElement), 0);
    return oButton;
};
//--------------------------------------------//
var FCKTransfVariableCommand = function() {
    this.Name = 'TransfVariable';
};
function okFunction(element, fakeSpan, value, label, eDIV) {
    FCKUndo.SaveUndoStep();
    if(label == '') {
        label = value;
    }
    if (!element && !fakeSpan) {
        element = FCK.EditorDocument.createElement('TransfVariable');
        fakeSpan = FCKDocumentProcessor_CreateFakeSpan('FCK__TransfVariable', element);
        var oRange = new FCKDomRange(FCK.EditorWindow);
        if(!eDIV) {
            oRange.MoveToSelection();
            oRange.InsertNode(fakeSpan);
        } else {
            eDIV.parentNode.insertBefore(fakeSpan, eDIV);
            eDIV.parentNode.removeChild(eDIV);
        }

        fakeSpan.onclick = function() {
            var args = {
                element: element,
                fakeSpan: fakeSpan,
                okFunction: okFunction
            };
            var dialog = new FCKDialogCommand(FCKLang['DlgTransfVariableTitle'], FCKLang['DlgTransfVariableTitle'], FCKConfig.PluginsPath + 'transferencia/variable.html', 340, 170, undefined, undefined, args);
            dialog.Execute();
        };
        FCK.Events.FireEvent('OnSelectionChange');
    }
    element.setAttribute('varName', value, 0);
    element.setAttribute('varLabel', label, 0);
    if(label) {
        fakeSpan.value = label;
    } else {
        fakeSpan.value = value;
    }
}
FCKTransfVariableCommand.prototype.Execute = function() {
    var args = {
        element: null,
        fakeSpan: null,
        okFunction: okFunction
    };
    var dialog = new FCKDialogCommand(FCKLang['DlgTransfVariableTitle'], FCKLang['DlgTransfVariableTitle'], FCKConfig.PluginsPath + 'transferencia/variable.html', 340, 170, undefined, undefined, args);
    dialog.Execute();
};
FCKTransfVariableCommand.prototype.EditWindow = function() {
    return true;
};
FCKTransfVariableCommand.prototype.GetState = function() {
    if (FCK.EditMode != FCK_EDITMODE_WYSIWYG) {
        return FCK_TRISTATE_DISABLED;
    }
    return 0; // FCK_TRISTATE_OFF
};
//--------------------------------------------//
var FCKTransfVariablesProcessor = FCKDocumentProcessor.AppendNew();
FCKTransfVariablesProcessor.ProcessDocument = function(document) {
    var aDIVs = document.body.getElementsByTagName('TransfVariable');
    var eDIV;
    var i = aDIVs.length - 1;
    var name;
    var label;
    while (i >= 0 && (eDIV = aDIVs[i--])) {
        name = eDIV.getAttribute('varName');
        label = eDIV.getAttribute('varLabel');
        label = label == null ? '' : label;
        okFunction(null, null, name, label, eDIV);
    }
};
//--------------------------------------------//
FCKCommands.RegisterCommand('TransfVariable', new FCKTransfVariableCommand());
// toolbar button
var TransfVariable = new FCKToolbarButton('TransfVariable', FCKLang['DlgMyFindTitle']);
TransfVariable.IconPath = FCKConfig.PluginsPath + 'transferencia/variable.png';
FCKToolbarItems.RegisterItem('TransfVariable', TransfVariable);