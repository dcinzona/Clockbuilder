/* Os Detection
################################################*/
function OSType() {
  var OSName="Unknown OS";
  if (navigator.appVersion.indexOf("Win")!=-1) OSName="Windows";
  if (navigator.appVersion.indexOf("Mac")!=-1) OSName="MacOS";
  if (navigator.appVersion.indexOf("X11")!=-1) OSName="UNIX";
  if (navigator.appVersion.indexOf("Linux")!=-1) OSName="Linux";
  return OSName;
}

// Fix width for mac
if(OSType()==="MacOS") {
 $('.temp').addClass('mac');
}


/* Color
################################################*/
if(localStorage.color) {
  $('body').addClass(localStorage.color);
}

function allowAnimation() {
  if (localStorage.animation) {
    return localStorage.animation === "true";
  }

  return true;
}

function showSeconds() {
  if (localStorage.seconds) {
    return localStorage.seconds === "true";
  }
  return true;
}

// Remove animation
if (!allowAnimation()) {
  $(".animated").removeClass('animated');
  $(".fadeIn").removeClass('fadeIn');
  $(".fadeInDown").removeClass('fadeInDown');
}

if (!showSeconds()) {
  $('body').addClass('no-seconds');
}

/* Geolocation
################################################*/
var loadedMaps = false;

function convertToAddress(lat, lng, successFunc, errorFunc) {
  if (!loadedMaps) {
    loadMaps();
    return;
  }
  var latlng = new google.maps.LatLng(lat, lng);
  var geocoder = new google.maps.Geocoder();
  geocoder.geocode({'latLng': latlng}, function(results, status) {
    var address;
    if (status == google.maps.GeocoderStatus.OK) {
      for (var i = 0; i < results.length; i++) {
        var row = results[i];
        if (row.formatted_address) {
          address = row.formatted_address;
          break;
        }
      }

      if (!address) {
        return errorFunc(lat, lng, results, status);
      }

    } else {
      return errorFunc(lat, lng, results, status);
    }
    successFunc(address);
  });
}


/* Weather
################################################*/

// Cache Elements;
var $time = $('#time');
var $date = $('#date');
var $now = $('.now');
var $forecast = $('#weather li');
var $city = $('#city');
var $loader = $('#loader');
var $error = $('#error');

function hasCachedWeather() {
  var now = new Date();
  if (now.getTime() < (parseInt(localStorage.cachedWeatherCreatedAt) + 60000 * 20)) {
    return true;
  } else {
    return false;
  }
}

function clearCachedWeather() {
  delete localStorage.cachedWeather;
  delete localStorage.cachedWeatherCreatedAt;
}

function hasCachedAddress() {
  if (localStorage.address) {
    return true;
  } else {
    return false;
  }
}


function weatherAtAddress(address, successFunc) {
  $.ajax({
      url: "http://www.google.com/ig/api?weather=" + address,
      type: 'GET',
      retryLimit: 10,
      tryCount: 0,
      success: function(data) {
        _gaq.push(['_trackEvent', 'weather_retrieval', "true"]);
        var wData = parseWeather(data);
        if (wData) {
          successFunc(wData);
        }
      },
      error : function(xhr, textStatus, errorThrown ) {
        if (textStatus == 'timeout' || xhr.status == 403) {
          this.tryCount++;
          if (this.tryCount <= this.retryLimit) {
            //try again
            $.ajax(this);
            return;
          }
        }

        // Track error
        _gaq.push(['_trackEvent', 'weather_retrieval', "" + xhr.status]);
        _gaq.push(['_trackEvent', 'weather_error', "" + xhr.status + " " + this.url]);
        // FIXME: This should so an error to the user.
        $loader.hide();
      }
  });
}

function fetchWeather(location, successFunc) {
  if (hasCachedWeather()) {
    // Return Cached version
    successFunc(JSON.parse(localStorage.cachedWeather));
  } else {
    // Lets show the loader
    $loader.show();
    if (location.address) {
      weatherAtAddress(location.address, successFunc);
    } else {
      convertToAddress(location.lat, location.lng, function(address) {
        weatherAtAddress(address, successFunc);
      }, function(lat, lng, results, status) {
        _gaq.push(['_trackEvent', 'error_convert_to_zip', JSON.stringify([lat, lng, results, status])]);
        $loader.hide();
        noLocation();
      });
    }
  }
}

function parseWeather(data) {
  // Cache it
  var w =  $.xml2json(data);

  // Do we have the data we need

  if (!w.weather.forecast_information) {
    noLocation();
    return;
  }

  var unit = w.weather.forecast_information.unit_system.data;

  // Lets only keep what we need.
  var w2 = {
    city: w.weather.forecast_information.city.data,
    current: {
      condition: w.weather.current_conditions.condition.data,
      conditionCode: conditionCode(w.weather.current_conditions.icon.data),
      temp: tempFormat(w.weather.current_conditions.temp_f.data, "US")
    },
    forecast: []
  };

  for (var i = $forecast.length - 1; i >= 0; i--) {
    var high = parseInt(w.weather.forecast_conditions[i].high.data);
    var low = parseInt(w.weather.forecast_conditions[i].low.data);
    w2.forecast[i] = {
      day: w.weather.forecast_conditions[i].day_of_week.data,
      condition: w.weather.forecast_conditions[i].condition.data,
      conditionCode: conditionCode(w.weather.forecast_conditions[i].icon.data),
      temp: tempFormat(Math.floor((high + low)/2), unit),
      high: tempFormat(w.weather.forecast_conditions[i].high.data, unit),
      low: tempFormat(w.weather.forecast_conditions[i].low.data, unit)
    };
  }

  var now = new Date();
  localStorage.cachedWeatherCreatedAt = now.getTime();
  localStorage.cachedWeather = JSON.stringify(w2);

  return w2;
}

function tempFormat(temp, unit) {
  if (unit === "US") {
    if (localStorage.temp === 'c') {
      return Math.round((5/9)*(temp-32));
    } else {
      return temp;
    }
  } else {
    if (localStorage.temp === 'c') {
      return temp;
    } else {
      return Math.round((9/5) * temp + 32);
    }
  }
}

function renderWeather(wd){
  // Set Current Information
  displayWeather($now, wd.current);
  $city.html(wd.city);

  // Show Weather & Hide Loader
  $('#weather-inner').removeClass('hidden');
  $loader.hide(0);

  // Show Forecast
  $forecast.each(function(i, el) {
    var $el = $(el);
    if (allowAnimation()) {
      $el.css("-webkit-animation-delay",150 * i +"ms").addClass('animated fadeInUp');
    }
    var dayWeather = wd.forecast[i];
    displayWeather($el, dayWeather);
  });

}

function tooltip(data) {
  return data.condition;
}

function displayWeather(el, data) {
  el.attr("title", tooltip(data));
  el.find('.weather').html(data.conditionCode);
  if (data.high && data.low) {
    el.find('.high').html(data.high);
    el.find('.low').html(data.low);
  } else {
    el.find('.temp').html(data.temp);
  }
  if(data.day) {
    el.find('.day').html(data.day);
  }
}


function conditionCode(con){
  switch(con) {
    case "/ig/images/weather/chance_of_snow.gif":
    case "/ig/images/weather/jp_snowysometimescloudy.gif":
      return "p";

    case "/ig/images/weather/flurries.gif":
      return "]";

    case "/ig/images/weather/sleet.gif":
      return "e";

    case "/ig/images/weather/chance_of_rain.gif":
    case "/ig/images/weather/jp_rainysometimescloudy.gif":
    case "/ig/images/weather/jp_rainy.gif":
      return "=";

    case "/ig/images/weather/chance_of_storm.gif":
      return "x";

    case "/ig/images/weather/showers.gif":
      return "3";

    case "/ig/images/weather/rain.gif":
      return "9";

    case "/ig/images/weather/storm.gif":
    case "/ig/images/weather/thunderstorm.gif":
    case "/ig/images/weather/cn_heavyrain.gif":
      return "z";

    case "/ig/images/weather/snow.gif":
    case "/ig/images/weather/rain_snow.gif":
      return "o";

    case "/ig/images/weather/jp_sunny.gif":
    case "/ig/images/weather/sunny.gif":
    case "/ig/images/weather/mostly_sunny.gif":
      return "v";

    case "/ig/images/weather/partly_cloudy.gif":
    case "/ig/images/weather/mostly_cloudy.gif":
    case "/ig/images/weather/cn_cloudy.gif":
      return "1";

    case "/ig/images/weather/jp_cloudy.gif":
    case "/ig/images/weather/cloudy.gif":
    case "/ig/images/weather/cn_overcast.gif":
      return "`";

    case "/ig/images/weather/mist.gif":
      return "6";

    case "/ig/images/weather/fog.gif":
    case "/ig/images/weather/foggy.gif":
    case "/ig/images/weather/smoke.gif":
    case "/ig/images/weather/hazy.gif":
    case "/ig/images/weather/haze.gif":
    case "/ig/images/weather/dusty.gif":
    case "/ig/images/weather/sand.gif":
    case "/ig/images/weather/cn_fog.gif":
      return "g";

    case "/ig/images/weather/icy.gif":
      return "-";

    default:
      _gaq.push(['_trackEvent', 'unknowweather', con]);
      return "T";
  }
}



/* Time
################################################*/
var weekdays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];

function getTime() {
  var date = new Date(),
      hour = date.getHours();

  if (localStorage.clock === "12" || !localStorage.clock) {
    if(hour > 12) {
        hour = hour - 12;
    } else if(hour === 0) {
      hour = 12;
    }
  }
  return {
    day: weekdays[date.getDay()],
    date: date.getDate(),
    month: months[date.getMonth()],
    hour: appendZero(hour),
    minute: appendZero(date.getMinutes()),
    second: appendZero(date.getSeconds())
  };
}

function appendZero(num) {
  if(num < 10) {
    return "0" + num;
  }
  return num;
}

function refreshTime() {
  var now = getTime();
  $date.html(now.day + ', ' + now.month + ' ' + now.date);
  $time.html("<span class='hour'>"+now.hour+"</span>"+"<span class='minute'>"+now.minute+"</span>"+"<span class='second'>"+now.second+"</span");
}


/* Run Stuff
################################################*/
// We don't have to do document ready since this is the last thing to load.
$loader.hide(0); // We will only show it if we are doing network things.

refreshTime();
setInterval(refreshTime, 1000);

function noLocation(data) {
  _gaq.push(['_trackEvent', 'nolocation', JSON.stringify(data)]);
  showErrorMessage($("#locationError").html());

  $("#set-location").submit(function(){
    localStorage.address = $('#error form input').val();
    clearCachedWeather();
    hideErrorMessage();
    main();
    return false;
  });
}

function main() {
  if (hasCachedWeather()) {
    renderWeather(JSON.parse(localStorage.cachedWeather));
  } else if (hasCachedAddress()) {
    fetchWeather({address: localStorage.address}, renderWeather);
  } else {
    if (navigator.geolocation) {
      $loader.show();
      navigator.geolocation.getCurrentPosition(
        function(position) {
            fetchWeather({lat: position.coords.latitude, lng: position.coords.longitude}, renderWeather);
        }, noLocation
      );
    }
  }
}

function loadMaps() {
  var script = document.createElement("script");
  script.type = "text/javascript";
  script.src = "http://maps.googleapis.com/maps/api/js?callback=main&sensor=true";
  document.body.appendChild(script);
  loadedMaps = true;
}

function showErrorMessage(message) {
  $loader.hide();
  $error.html(message);
  $error.show();
  $('#weather-inner').hide();
}

function hideErrorMessage(hide) {
  $error.hide();
  $('#weather-inner').show();
}

$(window).bind('online', function() {
  hideErrorMessage();
  main();
});

// google-analytics
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-33402958-1']);
_gaq.push(['_trackPageview']);

if (navigator.onLine) {
  main();

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = 'https://ssl.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
} else {
  if (hasCachedWeather()) {
    main();
  } else {
    showErrorMessage($("#offlineError").html());
  }
}