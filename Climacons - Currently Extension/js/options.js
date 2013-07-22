/* Options
################################################*/
$(function() {

  $('#options form input').change(function(){
    $('#options button').removeClass('saved').html('SAVE');
  });

  $('#options form').submit(function(){
    saveOptions($('#options form').serializeArray());
    $('#options button').addClass('saved').html('SAVED');
    // Show home button
    $("#save-home").show().addClass('animated bounceIn');
    return false;
  });

  function saveOptions(values) {
    localStorage.clear();
    $.each(values, function(index, obj) {
      localStorage[obj.name] = obj.value;
    });

    localStorage.cachedWeatherCreatedAt = null;
  }

  // Setup form temp type
  if (localStorage.temp === "c") {
    $("#celsius").attr("checked", true);
  } else {
    $("#fahrenheit").attr("checked", true);
  }

  // setup form for time type
  if (localStorage.clock === "24" ) {
    $("#time24").attr("checked", true);
  } else {
    $("#time12").attr("checked", true);
  }

  // setup form for color type
  if (localStorage.color) {
    $("#" + localStorage.color).attr("checked", true);
  } else {
    $("#dark").attr("checked", true);
  }

  // setup form seconds
  if (localStorage.seconds === "false" ) {
    $("#seconds-off").attr("checked", true);
  } else {
    $("#seconds-on").attr("checked", true);
  }

  // setup form animation
  if (localStorage.animation === "false" ) {
    $("#animation-off").attr("checked", true);
  } else {
    $("#animation-on").attr("checked", true);
  }

  // setup form for address
  if (localStorage.address) {
    $("#address").val(localStorage.address);
  }

  var uvOptions = {};
  (function() {
    var uv = document.createElement('script'); uv.type = 'text/javascript'; uv.async = true;
    uv.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'widget.uservoice.com/bHFWmCCXmOiD6gH4QNzA.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(uv, s);
  })();
});

