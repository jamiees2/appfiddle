var htmlEditor, jsEditor, cssEditor;
$(function(){
	htmlEditor = CodeMirror.fromTextArea($('textarea#html')[0], {
	    mode: "text/html"
	});
	htmlEditor.on('changes',function(){
		render();
	});
	cssEditor = CodeMirror.fromTextArea($('textarea#css')[0], {
	    mode: "text/css"
	});
	cssEditor.on('changes',function(){
		render();
	});

	jsEditor = CodeMirror.fromTextArea($('textarea#js')[0], {
	    mode: "text/javascript"
	});
	jsEditor.on('changes',function(){
		render();
	});
	render();
});

// Base template
var base_tpl =
    "<!doctype html>\n" +
    "<html>\n\t" +
    "<head>\n\t\t" +
    "<meta charset=\"utf-8\">\n\t\t" +
    "<title>Test</title>\n\n\t\t\n\t" +
    "</head>\n\t" +
    "<body>\n\t\n\t" +
    "</body>\n" +
    "</html>";
 
var prepareSource = function() {
    var html = htmlEditor.getValue(),
        css = cssEditor.getValue(),
        js = jsEditor.getValue(),
        src = '';
 
    // HTML
    src = base_tpl.replace('</body>', html + '</body>');
 
    // CSS
    css = '<style>' + css + '</style>';
    src = src.replace('</head>', css + '</head>');
 
    // Javascript
    js = '<script>' + js + '</script>';
    src = src.replace('</body>', js + '</body>');
 
    return src;
};

var render = function() {
    var source = prepareSource();
 
    var iframe = $('iframe#output'),
        iframe_doc = iframe.get(0).contentDocument;
 
    iframe_doc.open();
    iframe_doc.write(source);
    iframe_doc.close();
};