$(function(){
  $("#toc").toc({context: ".main", autoId: true})
  $(".secondary").scrollspy()
  _.defer(function(){
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this).scrollspy('refresh')
    });
    $(".secondary .active").removeClass("active");
    $(".secondary #toc > ul > li:first-child").addClass("active");
  })
})
