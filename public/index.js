var box_selector = ".mainpane .bordered-box";

function configure_box_selector() { 
  $(box_selector).click(box_selector_cb);
}

function box_selector_cb() {
  $(this).children(".plus").text("[-]");
  $(this).children(".details").show();
  $(this).children(".close-link").show();
  $(this).unbind('click');
}

$(document).ready(function() {
  $(".details").hide();
  $(".close-link").hide();
 
  configure_box_selector();
  
  $(".close-link").click(function () {
    $(this).hide();
    $(this).siblings(".details").hide();
    $(this).siblings(".plus").text("[+]");
    $(this).parent('.bordered-box').click(box_selector_cb);
    return false; // otherwise this click will trigger the above cb
  });
});
