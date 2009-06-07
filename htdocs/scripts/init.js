$(document).ready(function() {



    // if there is an input box, set focus there
    $(".text-input").focus();




    //$(".inline-reply").hide();
    $(".reply").click(function(ev) {
       ev.preventDefault();
       var t = this;
       $(t).siblings().filter(".inline-reply").toggle();
       var sel = $(t).siblings().filter(".inline-reply").children().filter("form").children().filter(".text-input");
       $(sel).focus();


       return false;});
    $("a.up").click(function(ev) {

        ev.preventDefault();
        var t = this;
        the_url = $(t).attr('href');
        $.ajax({
                type: "GET",
                url: the_url,
                success: function()
                {
                    $(t).hide();
                    $(t).siblings('.down').hide();
                    var el = $(t).siblings('.pts')[0];
                    el.innerHTML = parseInt(el.innerHTML) + 1;
                }
        });
        return false;
    });
});

