#
# Project Routes
#

get '/project/create' do
  haml :create_project
end

post '/project/create' do
  username, 
  name,
  description,
  source_code_url,
  meeting_id,
  techs = 
    session[:username], 
    params[:name].strip, 
    params[:description].strip, 
    params[:source_code_url].strip,
    params[:meeting_id].strip,
    params[:techs].to_s.strip.split(/\s*,\s*/)

  if name.empty?
    @error = "Please provide a name"
  elsif name.length > 80
    @error = "Your name is too long. Under 80 characters."
  elsif description.empty?
    @error = "Please provide a description"
  elsif !source_code_url.empty? and source_code_url !~ %r!^(https?|git|svn)://!
    @error = "Please provide a valid URL (git, svn, http, https)"
  elsif $db.project_by_name(name)
    @error = "A project by this name already exists."
  elsif username.nil?
    @error = "Please log in first."
  end

  if @error
    haml :create_project
  else
    begin
      project_id = $db.create_project(username, name, description, source_code_url, *techs)
      unless meeting_id.empty?
        $db.add_project_to_meeting(project_id, meeting_id)
      end
      redirect "/project/show/#{project_id}"
    rescue Exception => e
      @error = "Unknown Error during creation."
      haml :create_project
    end
  end
end

get '/project/show/:project_id' do
  @project = $db.project(params[:project_id])

  return 'project not found' unless @project

  show_project @project
end

get '/project/delete/:project_id' do
  @project = $db.project(params[:project_id])
 
  return 'project not found' unless @project
  
  unless project_owner?(@project)
    @error = "You do not own this project."
    show_project @project
  else
    $db.delete_project(params[:project_id])
    @error = "project '#{@project.name}' deleted"
    redirect '/'
  end
end

get '/project/assign/:project_id' do
  @project = $db.project(params[:project_id])
  project_action(@project) { $db.assign_user_to_project(@project.id, session[:username]) }
end

get '/project/reject/:project_id' do
  @project = $db.project(params[:project_id])
  project_action(@project) { $db.remove_user_from_project(@project.id, session[:username]) }
end

post '/project/assign_meeting' do
  meeting_id, project_id = params[:meeting_id], params[:project_id]

  return '' if meeting_id.empty? and project_id.empty?
  return '' unless meeting = $db.meeting(meeting_id)

  $db.add_project_to_meeting(project_id, meeting_id) rescue nil
  return "Meeting Assigned to #{h meeting.meeting_time}"
end
