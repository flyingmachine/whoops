$(function(){
  var $win = $(window)
    , $toc = $("#toc") 
    , navTop = $('#toc').length && $('#toc').offset().top - 40
    , isFixed = 0
  
  
  $($toc).toc({context: ".main", autoId: true})
  $(".secondary").scrollspy()
  _.defer(function(){
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this).scrollspy('refresh')
    });
    $(".secondary .active").removeClass("active");
    $(".secondary #toc > ul > li:first-child").addClass("active");
  })


  $win.on('scroll', processScroll)
  function processScroll() {
    var i, scrollTop = $win.scrollTop()
    if (scrollTop >= navTop && !isFixed) {
      isFixed = 1
      $toc.addClass('toc-fixed')
    } else if (scrollTop <= navTop && isFixed) {
      isFixed = 0
      $toc.removeClass('toc-fixed')
    }
  }
})
