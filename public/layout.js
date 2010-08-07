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

$(document).ready(function() { 
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
        } else { 
          $("#login-form-error").html('<div class="warning">Invalid Login</span>');
        }
      },
      error: function(xhr, ts) { alert(ts); }
    });

    return false;
  });
});
