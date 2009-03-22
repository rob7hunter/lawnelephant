$(document).ready(function() {

    $(".text-input").focus();

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

