#
# Meeting Routes
#

get '/meeting/:meeting_id' do
  @meeting  = $db.meeting(params[:meeting_id])
  return 'no meeting' unless @meeting

  @projects = $db.projects_for_meeting(params[:meeting_id])
  haml :show_meeting
end
