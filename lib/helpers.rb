def assigned?(project)
  return false unless authenticated?
  return false unless project
  return $db.assigned_to_project?(project.id, session[:username])
end

def project_action(project, &block)
  return 'project not found' unless project

  if project_owner?(project)
    @error = "You are the owner, and already assigned to this project"
    show_project project
  elsif !authenticated?
    @error = "You need to login first."
    show_project project
  elsif assigned?(project) 
    @error = "You are already assigned to this project."
    show_project project
  else
    yield
    redirect "/project/show/#{project.id}"
  end
 
end

def show_project(project)
  @project   = project
  @user      = $db.user_by_id(@project.user_id)
  @techs     = $db.project_techs(params[:project_id])
  @assigned  = $db.users_interested_in_project(@project.id)
  @title     = "Project Page for '#{@project.name}'"

  haml :show_project
end

def project_owner?(project)
  user = $db.user(session[:username])
  user.id == project.user_id
end

def login_text
  return authenticated? ? 
    %Q[
      Account: <a href="/account/show/#{e session[:username]}">#{h session[:username]}</a>
      <a class="logout-link" href="javascript:void(0)" title="Click to logout">(logout)</a>
    ] : '<span class="hand">Login</span>'
end

def login(username, password)
  session[:username] = params[:username]
  session[:password] = $db.password_hash(params[:password])
end

def authenticated?
  $db.crypt_authenticated?(session[:username], session[:password])
end

def title(title=nil)
  "Hackadelphia Project List" + (title ? ": #{h title}" : "")
end

def h(content)
  CGI.escapeHTML(content)
end

def e(content)
  CGI.escape(content)
end

