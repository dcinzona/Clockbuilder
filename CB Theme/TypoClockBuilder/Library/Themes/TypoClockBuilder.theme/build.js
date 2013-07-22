//date format dateFormat(now, "dddd, mmmm dS, yyyy, h:MM:ss TT");

// slide rotation frequency (in minutes)
var slideRotation = 0.3;
var slide = [];
var slideIndex = 1;
var shouldShowSlideShow = false;


function buildTheme(){
	$.ajaxSetup ({
	    // Disable caching of AJAX responses
	    cache: false
	});
	if(data.length>0)
	{
		$.each(data,function(i,d){
			var frame = d.frame
			var type = d.type;
			var id = "widget_"+d.widgetTag;
			var subClass = d.subClass;
			var w = $('<div class="widget"></div>');
			var cssObj = {
                'background-color' : 'transparent',
                'font-weight' : '',
                'top':getframe(frame,'top'),
                'left':getframe(frame,'left'),
                'width':getframe(frame,'width'),
                'height':getframe(frame,'height'),
                'position':'absolute',
                'display':'block',
                'opacity':d.opacity,
                'font-family':d.fontFamily,
                'font-size':d.fontSize
            }
            if(d.fontFamily == 'STHeitiJ-Light')
            {
                w.css('padding-top',parseInt(d.fontSize)*.1+'px');
            }
			if(d.widgetClass == 'textBasedWidget'){
				var fontColor = d.fontColor;
				var r = getColor(fontColor,'');
				var g = getColor(d.glowColor,'');
				w.css('color','rgba('+r[0]+','+r[1]+','+r[2]+',' + r[3] + ')');
                w.css('text-shadow','rgba('+g[0]+','+g[1]+','+g[2]+', '+g[3]+') 0px 0px 12px');
				if(subClass == "datetime"){
					var df = d.dateFormatOverride;
					w.attr('data',df.replace('a','TT'));
					w.attr('data',df.replace('EEEE','dddd'));
                    
				}
                if(d.textTransform == 'uppercase' || d.textTransform == 'lowercase')
                {
                    w.css('text-transform',d.textTransform);
                }
				w.css('text-align',d.textalignment);
				if(d.subClass=='weather')
				{
					w.addClass('hidden');
					w.data(d);
				}
				if(d.className == 'Custom Text')
                w.text(d.text);
                
				w.css(cssObj);
			}
			else
			{
				w = $('<img class="widget hidden" />');
				w.addClass('imageWidget');
				w.data(d);
				w.css(cssObj);
			}
			w.addClass(subClass);
			//w.attr('id',id);
			var f = getframe(frame,'');
			$('body').append(w);
		});
		updateDateTime();
		getWeather();
	    if(shouldShowSlideShow)
	        getSlideIndex();
	    switch (slide.length) {
	        case 0:
	        break;
	        case 1:
	        $(".slideshow .slide.current").attr("src", slide[0].image).addClass("zoomOut");
	        break;
	        default:
	        $(".slideshow .slide.next").attr("src", slide[0].image).addClass("zoomIn").css("-webkit-transform-origin", slide[0].origin);
	        setTimeout("slideShow()", 1000);
	        //slideShow();
	        break;
	    }
	}
	else
	{
		//show warning
		$('#noTheme').removeClass('hidden');
	}
}


function slideShow() {
    showSlide(slideIndex);
    slideIndex++;
    if (slideIndex == slide.length) slideIndex = 0;
    setTimeout("slideShow()", slideRotation * 60 * 1000);
}

function showSlide(index) {
    var $curr = $(".slideshow .slide.current");
    var $last = $(".slideshow .slide.last");
    var $next = $(".slideshow .slide.next");
    $curr.addClass("last").removeClass("current").removeClass("zoomOut");
    $last.addClass("next").removeClass("last").removeClass("zoomOut").addClass("zoomIn").attr("src", slide[index].image).css("-webkit-transform-origin", slide[index].origin);
    $next.addClass("current").removeClass("next").removeClass("zoomIn").addClass("zoomOut");
}

function getSlideIndex() {
    var xml_request = new XMLHttpRequest();
    xml_request.open("GET", "slides/slideindex.txt", false);
    xml_request.setRequestHeader("Cache-Control", "no-cache");
    xml_request.send(null);
    var lines = xml_request.responseText.split("\n");
    var index = 0;
    for (i in lines) {
        if (lines[i].substr(0, 2) != "//" && jQuery.trim(lines[i]) != "") {
            var t = lines[i].split(",");
            if (typeof (t[0]) != "undefined") {
                if (typeof (t[1]) == "undefined") t[1] = "50% 50%";
                //if (typeof (t[2]) == "undefined") t[2] = "50%";
                slide[index] = { image: jQuery.trim(t[0]), origin: jQuery.trim(t[1]) };
                index = index + 1;
            }
        }
    }
}


function getColor(color,rgb)
{
	var a = color.split(',');
	a[0] = parseInt((parseFloat( a[0] )*255));
	a[1] = parseInt((parseFloat( a[1] )*255));
	a[2] = parseInt((parseFloat( a[2] )*255));
	var red = parseInt( a[0] );
	var green = parseInt( a[1] );
	var blue = parseInt( a[2] );
	switch(rgb)
	{
		case "r":
        return red;
        break;
		case "g":
        return green;
        break;
		case "b":
        return blue;
        break;
	}
	return a;
}

function getframe(frame, val)
{
	var f = frame;
	while(f.indexOf('{')!=-1)
    f = f.replace("{","");
	while(f.indexOf('}')!=-1)
    f = f.replace("}","");
	var a = f.split(',');
	var left = a[0];
	var top = parseInt(a[1])+22;
	var width = a[2];
	var height = a[3];
	
	switch(val)
	{
		case "left":
        return left;
        break;
		case "top":
        return top;
        break;
		case "width":
        return width;
        break;
		case "height":
        return height;
        break;
	}
	
	
	return a;
}

function setWeatherTextContent(widget, data)
{
	var type = data.textItemType;
	if(type == 'Location')
	{
		if(data.text == '')
        widget.text(weatherDataSettings.locationName);
		else
        widget.text(data.text);
	}
	if(type == 'Temperature')
	{
		if(data.forecast=='current'){
			if(weatherDataSettings.showDegreeSymbol=='NO')
            widget.text(weather.temp);
			else
            widget.text(weather.temp+'°');
		}
		
	}
	if(data.forecast.toLowerCase()=='current'){
		if(type=="Conditions")
        widget.text(weather.currently);
	}
	if(data.forecast.toLowerCase()=='today'){
		if(weatherDataSettings.showDegreeSymbol=='NO')
		{
			if(type=='High')
            widget.text(weather.high);
			if(type=="Low")
            widget.text(weather.low);
			if(type=="Conditions")
            widget.text(weather.forecast);
		}
		else
		{
			if(type=='High')
            widget.text(weather.high+'°');
			if(type=="Low")
            widget.text(weather.low+'°');
			if(type=="Conditions")
            widget.text(weather.forecast);
		}
	}
	if(data.forecast.toLowerCase()=='tomorrow'){
		if(weatherDataSettings.showDegreeSymbol=='NO')
		{
			if(type=='High')
            widget.text(weather.tomorrow.high);
			if(type=="Low")
            widget.text(weather.tomorrow.low);
			if(type=="Conditions")
            widget.text(weather.tomorrow.forecast);
		}
		else
		{
			if(type=='High')
            widget.text(weather.tomorrow.high+'°');
			if(type=="Low")
            widget.text(weather.tomorrow.low+'°');
			if(type=="Conditions")
            widget.text(weather.tomorrow.forecast);
		}
	}
	
}

function updateWeather(){
	var iconsURL = 'icons/';
	$('.weather').each(function(){
		var t = $(this);
		var d = t.data();
		if(d.forecast.toLowerCase()  == 'current')
		{
			if(t.hasClass('imageWidget')){
				var imgURL = iconsURL+
				weatherDataSettings.weatherIconSet.toLowerCase()+ '/'+weather.code+weather.dayNight+'.png';
				t.attr('src',imgURL);
				t.removeClass('hidden');
			}
			else
			{
				setWeatherTextContent(t, d);
			}
		}
		if(d.forecast.toLowerCase() == 'today')
		{
			var f = weather.today;
			if(t.hasClass('imageWidget')){
				var imgURL = iconsURL+
				weatherDataSettings.weatherIconSet.toLowerCase()+'/'+f.code+'d.png';
				t.attr('src',imgURL);
				t.removeClass('hidden');
			}
			else
			{
				setWeatherTextContent(t, d);
			}
		}
		if(d.forecast.toLowerCase() == 'tomorrow')
		{
			var f = weather.tomorrow;
			if(t.hasClass('imageWidget')){
				var imgURL = iconsURL+
				weatherDataSettings.weatherIconSet.toLowerCase()+'/'+f.code+'d.png';
				t.attr('src',imgURL);
				t.removeClass('hidden');
			}
			else
			{
				setWeatherTextContent(t, d);
			}
		}
	});
    
	
}

function dateTimeFontFix()
{
	$('.datetime').textfill({ maxFontSize: 200 });
	dateTimeFontFixed = true;
}
var dateTimeFontFixed = false;
function updateDateTime()
{
	$('.datetime').each(function(){
		var t = $(this);
		var format = t.attr('data').replace('a','TT');
		t.text(dateFormat(new Date(), format));
	});
	setTimeout(function(){updateDateTime();},1000);
}


var dateFormat = function () {
	var	token = /d{1,4}|M{1,4}|yy(?:yy)?|([HhmsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
    timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
    timezoneClip = /[^-+\dA-Z]/g,
    pad = function (val, len) {
    val = String(val);
    len = len || 2;
    while (val.length < len) val = "0" + val;
    return val;
    };
    
	// Regexes and supporting functions are cached through closure
	return function (date, mask, utc) {
    var dF = dateFormat;
    
    // You can't provide utc if you skip other args (use the "UTC:" mask prefix)
    if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
    mask = date;
    date = undefined;
    }
    
    // Passing date through Date applies Date.parse, if necessary
    date = date ? new Date(date) : new Date;
    if (isNaN(date)) throw SyntaxError("invalid date");
    
    mask = String(dF.masks[mask] || mask || dF.masks["default"]);
    
    // Allow setting the utc argument via the mask
    if (mask.slice(0, 4) == "UTC:") {
    mask = mask.slice(4);
    utc = true;
    }
    
    var	_ = utc ? "getUTC" : "get",
    d = date[_ + "Date"](),
    D = date[_ + "Day"](),
    M = date[_ + "Month"](),
    y = date[_ + "FullYear"](),
    H = date[_ + "Hours"](),
    m = date[_ + "Minutes"](),
    s = date[_ + "Seconds"](),
    L = date[_ + "Milliseconds"](),
    o = utc ? 0 : date.getTimezoneOffset(),
    flags = {
    d:    d,
    dd:   pad(d),
    ddd:  dF.i18n.dayNames[D],
    dddd: dF.i18n.dayNames[D + 7],
    M:    M + 1,
    MM:   pad(m + 1),
    MMM:  dF.i18n.monthNames[M],
    MMMM: dF.i18n.monthNames[M + 12],
    yy:   String(y).slice(2),
    yyyy: y,
    h:    H % 12 || 12,
    hh:   pad(H % 12 || 12),
    H:    H,
    HH:   pad(H),
    m:    M,
    mm:   pad(m),
    s:    s,
    ss:   pad(s),
    l:    pad(L, 3),
    L:    pad(L > 99 ? Math.round(L / 10) : L),
    t:    H < 12 ? "a"  : "p",
    tt:   H < 12 ? "am" : "pm",
    T:    H < 12 ? "A"  : "P",
    TT:   H < 12 ? "AM" : "PM",
    Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
    o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
    S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
    };
    
    return mask.replace(token, function ($0) {
    return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
    });
	};
    }();
    
    // Some common format strings
    dateFormat.masks = {
	"default":      "ddd mmm dd yyyy HH:MM:ss",
	shortDate:      "m/d/yy",
	mediumDate:     "mmm d, yyyy",
	longDate:       "mmmm d, yyyy",
	fullDate:       "dddd, mmmm d, yyyy",
	shortTime:      "h:MM TT",
	mediumTime:     "h:MM:ss TT",
	longTime:       "h:MM:ss TT Z",
	isoDate:        "yyyy-mm-dd",
	isoTime:        "HH:MM:ss",
	isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
    };
    
    // Internationalization strings
    dateFormat.i18n = {
	dayNames: [
    "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
	],
	monthNames: [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
	]
    };
    
    // For convenience...
    Date.prototype.format = function (mask, utc) {
	return dateFormat(this, mask, utc);
    };
