Whoops = {
  setupFilters: function() {
    $("#new_whoops_filter select").change(function(){
      $("#new_whoops_filter").submit()
    })
    $("#reset").click(function(){
      window.location = "/event_groups?whoops_filter[service]"
      return false
    })
  },
  
  setupEventLinks: function() {
    $("#instances a").click(function(){
      $(".selected").removeClass("selected")
      $(this).parents("li").addClass("selected")
      $.get(this.href,function(data){
        $("#event-details").html(data)
      }, 'html')
      return false;
    })
  },
  
  setupInfo: function() {
    $(".info-revealer").click(function() {
      $(".info").toggle(300)
    })
  },
  
  setup: function() {
    this.setupFilters();
    this.setupEventLinks();
    this.setupInfo();
  }
}

$(function(){
  Whoops.setup();
  $('.column').equalHeight();
})

jQuery.ajaxSetup({ 
  beforeSend: function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})