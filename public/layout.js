function bind_open_link() {
  $("#login-form-open-link").click(function() {
    $("#login-form-display").show();
    $("#login-form-close-link").show();
    $("#login-username-field").focus();
  });
}

function bind_logout_link() {
  $(".logout-link").click(function() {
    $.ajax({
      async: false,
      type: "GET",
      url: "/account/logout",
      dataType: "json",
      success: function(data) {
        if(data.logout_successful) {
          $.get("/account/login_text", function(res) { 
            $("#login-form-open-link").html(res);
            $("#login-form-error").html('');
            $("#create-project").hide();
          });
          bind_open_link();
        } else {
          alert("Error logging out. Tell erikh!");
        }
      }
    });

    return false; 
  });
}

function search_cb() {
  $("#search").removeClass("hand");
  $("#search-form").show();
  $("#search").unbind("click");
  $("#search .close_link").show();
}

function meeting_cb() {
  $("#meeting").removeClass("hand");
  $("#meeting").addClass("meeting-wide");
  $("#meeting-list").show();
  $("#meeting").unbind("click");
  $("#meeting .close_link").show();
}

$(document).ready(function() { 
  $("#search-form").hide();
  $("#search").click(search_cb);
  $("#search .close_link").hide();
  $("#search .close_link").click(function() {
    $("#search-form").hide();
    $("#search").addClass("hand");
    $("#search").click(search_cb);
    $(this).hide();
    return false; // required to make the above click cb not fire
  });

  $("#meeting-list").hide();
  $("#meeting").click(meeting_cb);
  $("#meeting .close_link").hide();
  $("#meeting .close_link").click(function() {
    $("#meeting-list").hide();
    $("#meeting").addClass("hand");
    $("#meeting").removeClass("meeting-wide");
    $("#meeting").click(meeting_cb);
    $(this).hide();
    return false; // required to make the above click cb not fire
  });

  $("#login-form-display").hide();
  $("#login-form-close-link").hide();

  bind_open_link();

  $("#login-form-close-link").click(function() {
    $("#login-form-display").hide();
    $("#login-form-close-link").hide();
  });

  bind_logout_link();

  $("#login-form").submit(function() {
    $.ajax({
      async: false,
      type: "POST",
      url: "/account/login",
      data: {
        username: $("#login-form table tr td input[name=username]").val(),
        password: $("#login-form table tr td input[name=password]").val()
      },
      dataType: "json",
      success: function(data) { 
        if(data.login_successful) {
          $("#login-form-close-link").click();
          $.get("/account/login_text", function(res) { 
            $("#login-form-open-link").html(res); 
            bind_logout_link(); 
          });
          $("#login-form-open-link").unbind('click');
          $("#create-project").show();
        } else { 
          $("#login-form-error").html('<div class="warning">Invalid Login</span>');
        }
      },
      error: function(xhr, ts) { alert(ts); }
    });

    return false;
  });
});
