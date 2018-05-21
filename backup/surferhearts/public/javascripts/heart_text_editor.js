/*
    Class: HeartTextEditor
    
    Dependencies: FCKeditor
    
    How-To-Use:
        - Put '<div id="text_editor"><textarea name="main_text_editor" id="main_text_editor">zxcxc</textarea></div>' in html.
        - Call <create_text_editor> on window load.
*/

var HeartTextEditor = new Object;

/*
    Private Property: Cache
*/
HeartTextEditor.cache = {
                            currentBlock:   false,
                            editorBlock:    false,
                            editor:         false,
                            basePath:       '/javascripts/FCKeditor/',
                            toolBarSet:     'Public'
                        };




/*
    Function: create_text_editor
*/
HeartTextEditor.create_text_editor = function ( oBlock ) {

    oBlock = $(oBlock);
    var o_textarea = false;
    var oFCKeditor = false;

    if( !oBlock ) {
        alert('Editor block not found');
        return false;
    }
    
    HeartTextEditor.cache.editorBlock = oBlock;
    oBlock.style.position = 'absolute';
    o_textarea = oBlock.getElementsByTagName('TEXTAREA')[0];
    oFCKeditor  = new FCKeditor( o_textarea.name ) ;
    
    oFCKeditor.BasePath = HeartTextEditor.cache.basePath ;
    oFCKeditor.ToolbarSet = HeartTextEditor.cache.toolBarSet;
    oFCKeditor.Height = '100%'; 
    oFCKeditor.ReplaceTextarea() ;
}; // end function create_text_editor

/*
    Function: set_toolbarset
*/
HeartTextEditor.set_toolbarset = function (sName) { HeartTextEditor.cache.toolBarSet = sName;};


/*
    Function: set_text_block
*/
HeartTextEditor.set_text_block = function( oTxtBlock){
	
    return ( HeartTextEditor.cache.currentBlock = $(oTxtBlock)  ); 
}; 

/*
    Function: get_text_block
*/
HeartTextEditor.get_text_block = function( oTxtBlock){
    return HeartTextEditor.cache.currentBlock;
}; 

/*
    Function: show_text_editor
        Closes the text editor if it is open, sets oBlock to be the current text block, and
        repositions the text editor over the text editor.
    
    Parameters:
        oBlock - Optional. If no text block is defined, then <get_text_block> will be used.
*/
HeartTextEditor.show_text_editor=function ( oBlock ) {
    
    // check if editor exists
    if( !HeartTextEditor.cache.editorBlock ) {
        alert('Editor not found.');
        return false;
    }
    
    HeartTextEditor.close_text_editor();
    
    // set current block
    oTxtBlock = (oBlock) ? $(oBlock) : HeartTextEditor.get_text_block();
    HeartTextEditor.set_text_block(oBlock);
    
    if(!oTxtBlock)
        return false;
        
    // get instance 
    if(!HeartTextEditor.cache.editor)
        HeartTextEditor.cache.editor = FCKeditorAPI.GetInstance( HeartTextEditor.cache.editorBlock.getElementsByTagName('TEXTAREA')[0].name );
    HeartTextEditor.cache.editor.SetHTML(oTxtBlock.innerHTML );
    
    // Position editor over text DIV
    var pos = Position.cumulativeOffset(oTxtBlock);
    HeartTextEditor.cache.editorBlock.style.top = pos[1]+'px';
    HeartTextEditor.cache.editorBlock.style.left = pos[0]+'px';
    HeartTextEditor.cache.editorBlock.style.display='block';

/*    
    if (!document.all ){ //Check for Gecko
        // From the FCKeditor developers:
        //   "This test is probably overcautious, but since
        //   EditorDocument isn't available with an accessor
        //     it could disappear in a future release."
        if (window.main_text_editor && window.main_text_editor.EditorDocument && window.main_text_editor.EditMode == FCK_EDITMODE_WYSIWYG)
           window.main_text_editor.EditorDocument.designMode = "On";
    }
*/
}; // end function show_text_editor

/*
    Function: close_text_editor
        Also sets the current text block to 'false'.
*/
HeartTextEditor.close_text_editor = function () {
	
    if(!HeartTextEditor.cache.editorBlock)
        return false;
    if(HeartTextEditor.cache.currentBlock) {
		if( HeartTextEditor.cache.currentBlock.innerHTML != HeartTextEditor.cache.editor.GetXHTML() )
			Element.addClassName(HeartTextEditor.cache.currentBlock, 'altered');
		HeartTextEditor.cache.currentBlock.innerHTML = HeartTextEditor.cache.editor.GetXHTML();
	}    
        
    HeartTextEditor.cache.editorBlock.style.display='none';
    HeartTextEditor.set_text_block(false);
}; // end function close_text_editor
