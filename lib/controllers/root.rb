get '/' do
  @full_projects = $db.projects
  haml :index
end

post '/search' do
  @title = "Search Results"
  techs = params[:techs].split(/\s*,\s*/)
  @full_projects = if !params[:name].empty? and !techs.empty?
                     $db.search_project_by_name_and_tech(params[:name], techs)
                   elsif !params[:name].empty?
                     $db.search_project_by_name(params[:name])
                   elsif !techs.empty?
                     $db.search_project_by_tech(techs)
                   else
                     $db.projects
                   end

  haml :index
end
