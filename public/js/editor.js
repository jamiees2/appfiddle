// var htmlEditor, jsEditor, cssEditor;
$(function(){
    CodeMirror.modeURL = "/components/codemirror/mode/%N/%N.js";


    var $editor = $('textarea#editor');

    var editor = CodeMirror.fromTextArea($editor[0],{
        mode: $editor.attr('data-mime').toString(),
        lineNumbers: true,
        tabMode: "indent",
        matchBrackets: true
    });
    CodeMirror.autoLoadMode(editor, $editor.attr('data-mime').toString().replace('text/','').replace('x-','').replace('scss','css'));
    
	// htmlEditor = CodeMirror.fromTextArea($('textarea#html')[0], {
	//     mode: "text/html"
	// });
	// htmlEditor.on('changes',function(){
	// 	render();
	// });
	// cssEditor = CodeMirror.fromTextArea($('textarea#css')[0], {
	//     mode: "text/css"
	// });
	// cssEditor.on('changes',function(){
	// 	render();
	// });

	// jsEditor = CodeMirror.fromTextArea($('textarea#js')[0], {
	//     mode: "text/javascript"
	// });
	// jsEditor.on('changes',function(){
	// 	render();
	// });
	// render();
});
