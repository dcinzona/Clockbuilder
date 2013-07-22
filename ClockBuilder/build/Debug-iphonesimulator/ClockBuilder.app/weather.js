var weather = {};
var TO, toShow;
var currentZip;
var locationName;
var temp;
var conditions;
var useWindChill;

function loadingAnimation(fadeOut, zip)
{
	if(fadeOut){
		$('#loader').addClass('visible');
		renderWeather(zip);
	}
	else
		$('#loader').removeClass('visible');
}
function renderWeather(z)
{
	currentZip = z;
	if(TO)
		clearTimeout(TO);
	$.simpleWeather({
		zipcode: currentZip,
		unit: temp,
		success: function(weatherData) {
			weather = weatherData;
			var region = ', ' + weather.region;
			if(region == ', ')
			{
				region = ', ' + weather.country;
			}
			var curr0 = (conditions) ? conditions[weather.code].toLowerCase() : weather.currently;
			var curr1 = (conditions) ? conditions[weather.today.code].toLowerCase()  : weather.forecast;
			var curr2 = (conditions) ? conditions[weather.tomorrow.code].toLowerCase()  : weather.tomorrow.forecast;
			TO = setTimeout('getWeather()', 600000);
			setTimeout(function(){loadingAnimation(false);},500);
			updateWeather();
			$('.weather').removeClass('hidden');
		},
		error: function(error) {
			
			TO = setTimeout('getWeather()',1000);
		}
	});
}
function getWeather(){
	loadingAnimation(false);
	temp = weatherDataSettings.units.substr(0,1).toLowerCase();
	var lang = "en-us";
	currentZip = weatherDataSettings.location;
	locationName = weatherDataSettings.locationName;
	useWindChill = weatherDataSettings.windChill;
	renderWeather(currentZip);
}
