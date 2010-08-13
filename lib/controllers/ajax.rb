#
# Ajax routes (autocompletion, etc)
#

get '/ajax/list/techs' do
  return $db.all_techs.to_json
end
