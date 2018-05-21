window.onload =function () {
    var subObj = document.getElementsByTagName('button')[0];
    
    if( subObj && subObj.className=='btn_submit') 
        subObj.onclick = submit_login;


}; // end function window.onload

function submit_login() {
    this.innerHTML = 'Wait...';
    this.disabled = true;
    document.getElementById('form_login').submit();
    return false;
}; // end function submit_login

// -----------------------------------------------------------------------------------
// ------------------ ...give me liberty of give me death! ---------------------------
// -------------------- - American patriots of the 1700 and early 1800s --------------
// -----------------------------------------------------------------------------------
// ------------------ ...Give me your money or die! ----------------------------------
// -------------------- - The Neo-American voter of the 1900s ------------------------
// -----------------------------------------------------------------------------------
// ----------------- Do you know if Jak was really the Mar who built Haven City? -----