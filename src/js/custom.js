$(window).on('load', function () {
	if (/Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent)) {
		$('body').addClass('ios');
	} else {
		$('body').addClass('web');
	};
	$('body').removeClass('loaded');
});

/* viewport width */
function viewport() {
	var e = window,
		a = 'inner';
	if (!('innerWidth' in window)) {
		a = 'client';
		e = document.documentElement || document.body;
	}
	return { width: e[a + 'Width'], height: e[a + 'Height'] }
};
/* viewport width */


$(function () {

	new WOW().init();

	/*scroll id*/
	$('.js-scroll').click(function () {
		var target = $(this).attr('href');
		$('html, body').animate({
			scrollTop: $(target).offset().top - 20
		}, 1000);
		return false;
	});
	/*scroll id*/

	/* placeholder*/
	$('input, textarea').each(function () {
		var placeholder = $(this).attr('placeholder');
		$(this).focus(function () { $(this).attr('placeholder', ''); });
		$(this).focusout(function () {
			$(this).attr('placeholder', placeholder);
		});
	});
	/* placeholder*/

	/* phone masks */

	$(".js-mask-phone").mask("+7 (999) 999-99-99");

	/* phone masks */

	var jsImg = $('.js-img');

	new LazyLoad(jsImg, {
		root: null,
		rootMargin: "0px",
		threshold: 0
	});

	$(".js-toggle-menu").click(function () {
		$('.js--header-nav').toggleClass('opened');
		$(this).toggleClass('on');
		$('.js-main-wrapper').toggleClass('scroll-off');
	});

	$(".js-header__link").click(function () {
		$('.js--header-nav').removeClass('opened');
		$('.js-toggle-menu').removeClass('on');
		$('.js-main-wrapper').removeClass('scroll-off');
	});

	$('.header-lang__title').click(function () {
		$('.js--list-lang').slideToggle();
		$(this).toggleClass('active');
	});

	$('.list-lang__link').click(function () {
		$('.header-lang__title').text($(this).text()).removeClass('active');
		$('.js--list-lang').slideToggle();
	});
});

	

var handler = function () {

	var height_footer = $('footer').height();
	var height_header = $('header').height();


	var viewport_wid = viewport().width;
	var viewport_height = viewport().height;

};
