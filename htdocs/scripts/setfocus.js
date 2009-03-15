function set_focus()
{
    var test = document.getElementsByTagName('textarea');
    for(var i = 0; i < test.length; i++){
            alert(test[i]);
                   }
}

window.onload=set_focus();


