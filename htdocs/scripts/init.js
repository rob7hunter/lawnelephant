$(document).ready(function() {

    // if there is an input box, set focus there
    $(".text-input").focus();

    // attach click even handler to all downvotes
    $("a.down").click(function(ev)
    {
        ev.preventDefault();
        var t = this;
        the_url = $(t).attr('href');
        $.ajax({
                type: "GET",
                url: the_url,
                success: function()
                {
                    $(t).hide();
                    $(t).siblings('.up').hide();
                    var el = $(t).siblings('.pts')[0];
                    el.innerHTML = parseInt(el.innerHTML) - 1;
                }
        });
        return false;
    });

    // attach click event handler to all upvotes (XXX DRY alert)
    $("a.up").click(function(ev)
    {
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

