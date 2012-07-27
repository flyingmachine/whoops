$(function(){
  $("#toc").toc({context: ".main", autoId: true})
  
  $(function () {
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this)
      $spy.scrollspy($spy.data())
    })
  })
})
