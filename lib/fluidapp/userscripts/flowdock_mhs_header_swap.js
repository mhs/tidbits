// ==UserScript==
// @name        FlowDock - Humans
// @namespace   http://fluidapp.com
// @description Changes the FlowDock header to the Mutually Human Logo
// @include     *
// @author      Zach Dennis
// ==/UserScript==

(function () {
    if (window.fluid) {
		  $(function(){
		    var intervalId;
		    intervalId = setInterval(function(){
		      if($(".app-toolbar:first").length){
		        $(".app-toolbar h2:first").text("").css({
		          'width': 192,
		          'height': 48,
		          'background-image': "url(http://mutuallyhuman.com/images/logo.png)",
		          'margin-top': '-14px'
		        });
		        clearInterval(intervalId);
	        }
	      }, 250);
		  });
    }

})();
