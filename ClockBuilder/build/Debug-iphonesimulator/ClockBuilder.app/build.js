//date format dateFormat(now, "dddd, mmmm dS, yyyy, h:MM:ss TT");

// slide rotation frequency (in minutes)
var slideRotation = 0.3;
var slide = [];
var slideIndex = 1;
var shouldShowSlideShow = false;
var militaryTime = false;
var parallaxEnabled = false;
var wallpaperOnly = false;
var debug = false;
var debugEnabled = false;
var allowWallpaperRotation = true;
var acGrav = {x:0,y:0,z:0};

conditions = ["tornado",
              "tropical storm",
              "hurricane",
              "severe thunderstorms",
              "thunderstorms",
              "mixed rain and snow",
              "mixed rain and sleet",
              "mixed snow and sleet",
              "freezing drizzle",
              "drizzle",
              "freezing rain",
              "showers",
              "showers",
              "snow flurries",
              "light snow showers",
              "blowing snow",
              "snow",
              "hail",
              "sleet",
              "dust",
              "foggy",
              "haze",
              "smoky",
              "blustery",
              "windy",
              "cold",
              "cloudy",
              "mostly cloudy",
              "mostly cloudy",
              "partly cloudy",
              "partly cloudy",
              "clear",
              "sunny",
              "fair",
              "fair",
              "mixed rain and hail",
              "hot",
              "isolated thunderstorms",
              "scattered thunderstorms",
              "scattered thunderstorms",
              "scattered showers",
              "heavy snow",
              "scattered snow showers",
              "heavy snow",
              "partly cloudy",
              "thundershowers",
              "snow showers",
              "isolated thundershowers",
              "not available"];
var dayArray = ["(",
                "z",
                "k",
                "z",
                "z",
                "r",
                "r",
                "r",
                "u",
                "7",
                "u",
                "9",
                "9",
                "p",
                "p",
                "\\",
                "\\",
                "y",
                "y",
                "d",
                "d",
                "d",
                "d",
                ";",
                ";",
                "-",
                "`",
                "1",
                "1",
                "1",
                "1",
                "v",
                "v",
                "v",
                "v",
                "u",
                "e",
                "x",
                "x",
                "x",
                "0",
                "]",
                "\\",
                "]",
                "1",
                "z",
                "r",
                "x",
                "|"];
var nightArray = ["(",
                  "z",
                  "k",
                  "z",
                  "z",
                  "t",
                  "t",
                  "t",
                  "i",
                  "8",
                  "i",
                  "9",
                  "9",
                  "[",
                  "[",
                  "a",
                  "a",
                  "y",
                  "y",
                  "f",
                  "f",
                  "f",
                  "f",
                  "'",
                  "'",
                  "-",
                  "`",
                  "2",
                  "2",
                  "2",
                  "2",
                  "/",
                  "v",
                  "/",
                  "/",
                  "i",
                  "e",
                  "c",
                  "c",
                  "c",
                  "-",
                  "]",
                  "a",
                  "]",
                  "2",
                  "z",
                  "t",
                  "c",
                  "|"];


function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

function buildTheme(){
	$.ajaxSetup ({
                 // Disable caching of AJAX responses
                 cache: false
                 });
	if(data.length>0 || wallpaperOnly == true)
	{
        if(!wallpaperOnly){
            var widgetWrapper = $('#bgWrap');
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
               if(d.widgetClass == 'textBasedWidget' || weatherDataSettings.weatherIconSet.toLowerCase() == 'climacons'){
               var fontColor = d.fontColor;
               if(fontColor)
                var r = getColor(fontColor,'');
               var g = getColor(d.glowColor,'');
               w.css('color','rgba('+r[0]+','+r[1]+','+r[2]+',' + r[3] + ')');
               //w.css('text-shadow','rgba('+g[0]+','+g[1]+','+g[2]+', '+g[3]+') 0px 0px 12px');
               if(d.glowAmount){
                w.css('text-shadow','rgba('+g[0]+','+g[1]+','+g[2]+', '+g[3]+') 0px 0px '+d.glowAmount+'px');
               }
               else
               {
                w.css('text-shadow','rgba('+g[0]+','+g[1]+','+g[2]+', '+g[3]+') 0px 0px 12px');
               }
               if(d.type == 'imageWidget'){
               w.css('text-align',d.textalignment);
               }
               
               if(subClass == "datetime"){
               var df = d.dateFormatOverride;
               w.attr('data',df.replace('a','TT'));
               w.attr('data',df.replace('EEEE','dddd'));
               
               }
               if(d.textTransform == 'uppercase' || d.textTransform == 'lowercase')
               {
               if(d.widgetClass == 'textBasedWidget'){
               w.css('text-transform',d.textTransform);
               }
               }
               if(d.widgetClass == 'textBasedWidget'){
               w.css('text-align',d.textalignment);
               }
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
               widgetWrapper.append(w);
            });
        }
		updateDateTime();
		getWeather();
        if(parallaxEnabled){
            addParallax();
        }
	}
	else
	{
		//show warning
		$('#noTheme').removeClass('hidden');
	}
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

//Start Parallax
var addParallax = function(resetView){
    
    //need this because the iPad lock screen doesn't change the window.orientation value
    function isPortrait(){
        return window.innerWidth < window.innerHeight;
    }
    
    var oldOrientation = isPortrait();
    
    var kIsiPad = navigator.userAgent.match(/iPad/i) != null;
    
    //var pad = 90; //this is old, could probably remove it.
    //var orientation = 0, //also old
    //deviceOrientationEvent = 0, //this too can probably be removed
    var perspective = {
        cx: 50, // current x
        cy: 50, // current y
        tx: 50, // target x
        ty: 50  // target y
    };
    var world = $('#bgWrap');
    var $background = $('#background');
    if($background.length<1){
        $background = $('#backgroundWP');  //because I give the user the option to have a different wallpaper on the home screen I need a different ID
    }
    var $boxShadow = $('#boxShadow');
    var growthBase = 40;
    var w = $(window).width();
    var h = $(window).height();
    
    var growthRatio = h/w;
    var ratioedBase = growthBase*growthRatio;
    var resetTO;
    
    var dbg = $('#debug');
    
    var currentHomeButtonPosition = 'bottom'; // assume portrait
    var debugID = $('#debugWP');
    var rotationTimeout;
    
    function initialize(){
        
        $boxShadow.width(w + growthBase);
        $boxShadow.height(h + (ratioedBase));
        $boxShadow.css({top:'-'+(ratioedBase/2)+'px', left:'-'+(growthBase/2)+'px'});
        
        var ipadBGmult = 2.6;
        var iphoneBGMult = 2.2;
        
        if(kIsiPad){
            w = w > h ? w : h;
            $background.width(w+(growthBase*ipadBGmult));
            $background.height(h+((growthBase*ipadBGmult)));
            $background.css({top:'-'+((growthBase*ipadBGmult)/2)+'px',left:'-'+((growthBase*ipadBGmult)/2)+'px', '-webkit-transform':'translateZ(-16px)'});
            world.css('-webkit-perspective' , w+(growthBase*ipadBGmult) + 'px');
        }
        else{
            $background.width(w+(growthBase*iphoneBGMult));
            $background.height(h+((growthBase*iphoneBGMult)*growthRatio));
            $background.css({top:'-'+(((growthBase*iphoneBGMult)*growthRatio)/2)+'px',left:'-'+((growthBase*iphoneBGMult)/2)+'px'});
            world.css('-webkit-perspective' , w+(growthBase*iphoneBGMult) + 'px');
        }
        
        addEventListener( 'devicemotion', onMotionChange, false );        
    }
    
    function handleOrientation(event){
        
		var rD = 3;
        
		var faceUp = (acGrav.z < 0);
		var shouldRotate = false;        
        
        if( Math.abs(acGrav.z) < 8.6){
			if(currentHomeButtonPosition == 'top' || currentHomeButtonPosition == 'bottom'){
				if(Math.abs(acGrav.y)+rD < Math.abs(acGrav.x)){
					if(acGrav.x > 0 ){ //
						currentHomeButtonPosition = 'left';
					}
					if(acGrav.x < 0 ){ //
						currentHomeButtonPosition = 'right';
					}
					shouldRotate = true;
				}
				else{
					if(acGrav.y-rD > 0 && currentHomeButtonPosition == 'bottom'){ //
						currentHomeButtonPosition = 'top';
						shouldRotate = true;
					}
					if(acGrav.y+rD < 0 && currentHomeButtonPosition == 'top'){ //
						currentHomeButtonPosition = 'bottom';
						shouldRotate = true;
					}
				}
			}
            
			else if(currentHomeButtonPosition == 'right' || currentHomeButtonPosition == 'left'){
				//change if gravity if less on X
				if(Math.abs(acGrav.x)+rD < Math.abs(acGrav.y)){
					if(acGrav.y > 0){
						currentHomeButtonPosition = 'top';
					}
					if(acGrav.y < 0 ){
						currentHomeButtonPosition = 'bottom';
					}
					shouldRotate = true;
				}
				//rotate from left to right
				else{
					if(acGrav.x > 0 && currentHomeButtonPosition == 'right'){ //
						currentHomeButtonPosition = 'left';
						shouldRotate = true;
					}
					if(acGrav.x < 0 && currentHomeButtonPosition == 'left'){ //
						currentHomeButtonPosition = 'right';
						shouldRotate = true;
					}
				}
			}
        }
        
        var html = "<p style='color:white'>"+currentHomeButtonPosition+
        "<hr/>xG: "+acGrav.x+"</p>"+
        "<hr/>yG: "+acGrav.y+"</p>"+
        "<hr/>zG: "+acGrav.z+"</p>";
        
		rotation = 0;
		switch(currentHomeButtonPosition){
			case 'left':rotation = -90;
                break;
			case 'right':rotation = 90;
                break;
			case 'bottom':rotation = 0;
                break;
			case 'top':rotation = 180;
                break;
		}
        
        if(shouldRotate && kIsiPad && $background.attr('id')=='backgroundWP' && allowWallpaperRotation){
        	clearTimeout(rotationTimeout);
        	rotationTimeout = setTimeout(function(){
                                         $background.css('-webkit-transform','rotate('+rotation+'deg) translateZ(-16px)');
                                         resetOnIdle();
                                         },180);
        }
        if(debugID.length==1 && debugEnabled){
            debugID.html(html);
        }
    }
    
    
    function updateBoxShadow(){
        $boxShadow.width(window.innerWidth + growthBase);
        $boxShadow.height(window.innerHeight + (ratioedBase));
        $boxShadow.css({top:'-'+(ratioedBase/2)+'px', left:'-'+(growthBase/2)+'px'});
    }
    
    function resetOnIdle(){
        perspective.cx = 50 ;
        perspective.cy = 50 ;
        perspective.tx = perspective.cx;
        perspective.ty = perspective.cy;
        world.css('-webkit-perspective-origin' , perspective.cx + '% ' + perspective.cy + '%');
    }
    
    function onMotionChange( event ) {
        acGrav.x = event.accelerationIncludingGravity.x;
        acGrav.y = event.accelerationIncludingGravity.y;
        acGrav.z = event.accelerationIncludingGravity.z;
        handleOrientation(event);
        updateBoxShadow();
        var divisor = 5;    
        var rotationRateGamma = (-event.rotationRate.gamma/divisor) ;
        var rotationRateBeta = isPortrait() ? (-event.rotationRate.beta/divisor) : (-event.rotationRate.alpha/divisor);
        var rotationRateAlpha = isPortrait() ? (-event.rotationRate.alpha/divisor) : (-event.rotationRate.beta/divisor) ;
        
        if(Math.abs(rotationRateBeta) > 1 || Math.abs(rotationRateAlpha) > 1){
            //clear current timer
            window.clearTimeout(resetTO);
            
            perspective.cx = ( perspective.tx + rotationRateBeta ) ;
            perspective.cy = ( perspective.ty + rotationRateAlpha ) ;
            
            var pX = (perspective.cx) ;
            var pY = (perspective.cy) ;
            
            var xratPositive = 220;
            var xratNegative = -200;
            
            if(pX > xratPositive){
                pX = xratPositive;
            }
            if(pX < xratNegative){
                pX = xratNegative;
            }
            if(pY > xratPositive){
                pY = xratPositive;
            }
            if(pY < xratNegative){
                pY = xratNegative;
            }
            
            perspective.tx = pX;
            perspective.ty = pY;
            
            world.css('-webkit-perspective-origin' , pX + '% ' + pY + '%');
            resetTO = window.setTimeout(resetOnIdle, 15000);
        }
        
        event.preventDefault();
    }
    
    if(resetView){
        resetOnIdle();
    }
    else{
        initialize();
    }
    
};
//End Parallax


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
    xml_request.open("GET", "slideindex.txt", false);
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
    
    
    
    var curr0 = toTitleCase( (conditions) ? conditions[weather.code].toLowerCase() : weather.currently );
    var curr1 = toTitleCase( (conditions) ? conditions[weather.today.code].toLowerCase()  : weather.forecast );
    var curr2 = toTitleCase( (conditions) ? conditions[weather.tomorrow.code].toLowerCase()  : weather.tomorrow.forecast );
    
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
        	widget.text(curr0);
		if(data.type == 'imageWidget'){
			var cc = weather.code;
			if(weather.dayNight=='d')
				widget.text(dayArray[cc]);
			else
				widget.text(nightArray[cc]);
            
		}
	}
	if(data.forecast.toLowerCase()=='today'){
		if(weatherDataSettings.showDegreeSymbol=='NO')
		{
			if(type=='High')
                widget.text(weather.high);
			if(type=="Low")
                widget.text(weather.low);
			if(type=="Conditions")
                widget.text(curr1);
		}
		else
		{
			if(type=='High')
                widget.text(weather.high+'°');
			if(type=="Low")
                widget.text(weather.low+'°');
			if(type=="Conditions")
                widget.text(curr1);
		}
		if(data.type == 'imageWidget'){
			var cc = weather.today.code;
			if(weather.dayNight=='d')
				widget.text(dayArray[cc]);
			else
				widget.text(nightArray[cc]);
            
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
                widget.text(curr2);
		}
		else
		{
			if(type=='High')
                widget.text(weather.tomorrow.high+'°');
			if(type=="Low")
                widget.text(weather.tomorrow.low+'°');
			if(type=="Conditions")
                widget.text(curr2);
		}
		if(data.type == 'imageWidget'){
			var cc = weather.tomorrow.code;
			if(weather.dayNight=='d')
				widget.text(dayArray[cc]);
			else
				widget.text(nightArray[cc]);
            
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
                        var format = t.attr('data').replace('aa','TT');
                        format = format.replace('a','TT');
                        format = format.replace('AA','TT');
                        format = format.replace('A','TT');
                        if(militaryTime){
                        format = format.replace('hh','HH');
                        format = format.replace('h','H');
                        format = format.replace('TT','');
                        }
                        else{
                        format = format.replace('HH','hh');
                        format = format.replace('H','h');
                        }
                        
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
	"default":      "",
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
