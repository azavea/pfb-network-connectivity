$(document).ready(function() {

  /* Scroll title fix in sidebar */
  var container    = $('#scrollHeaders'),
      section      = $('#scrollHeaders section');

  $(container).on('scroll', function() {
    containerTop = $(this).offset().top;

    $(section).each(function() {
        var topDistance = $(this).offset().top;
        var topDistance2 = $(this).scrollTop();

        if ( (topDistance) <= containerTop ) {
          $(this).addClass('active');
          $(this).children('.section-title').css('top', containerTop);
        } else {
          $(this).removeClass('active');
          $(this).children('.section-title').css('top', 'initial');
        }
    });
});
})