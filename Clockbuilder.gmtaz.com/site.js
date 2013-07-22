
$(function(){
	$('#boomButton').click(function(){
		$('#builderSS').fadeToggle(1000);
	});
	$("#boomButton[title]").tooltip({
	
	   // tweak the position
	   offset:[-20,0],
	   
	   position:'bottom center',
	
	   // use the "slide" effect
	   effect: 'slide'
	
	// add dynamic plugin with optional configuration for bottom edge
	}).dynamic({ bottom: { direction: 'down', bounce: true } });
	
	
	$(".item img").live('click',function() {
		$.fancybox({
		//'orig' : $(this),
		'padding' : 0,
		'href' : $(this).attr('src'),
		'title' : $(this).attr('src').replace('http://clockbuilder.gmtaz.com/resources/iphone/','').replace('/themeScreenshot.jpg',''),
		'transitionIn' : 'elastic',
		'transitionOut' : 'elastic',
		'easingIn' : 'easeOutBack',
		'easingOut' : 'easeInBack'
		});
	});
});
