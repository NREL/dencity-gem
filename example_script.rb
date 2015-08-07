require 'dencity'

d = Dencity.connect({host_name: 'http://localhost:3000/'})

puts '****** SEARCH ********'
filters = []
filters << { name: 'building_area', value: 2737.26, operator: 'lt' }
filters << { name: 'building_type', value: ['Community Center'], operator: 'in' }
return_only = ['related_files']
page = 0 #pages are 0-based
begin
  results = d.search(nil, [], page)
rescue StandardError => e
  printf "%-40s %s\n", "Search", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Search", "SUCCESS"
end
puts "RESULTS: #{results}"
# puts "Number of results: #{results.results.size}"

puts '********  GET ANALYSIS BY NAME & USER_ID *********'
begin
  analysis = d.retrieve_analysis('test_analysis', '53a3656d986ffba2c5000001')
  # TODO: move the failing one to tests
  # this one should fail:
  # analysis = d.retrieve_analysis('test_analysis2', '53a3656d986ffba')
rescue StandardError => e
  printf "%-40s %s\n", "Retrieve Analysis", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Retrieve Analysis", "SUCCESS"
end
#puts "ANALYSIS: #{analysis}" if d.analysis_loaded?

puts '******** GET ANALYSIS BY ID ************'
begin
  analysis = d.get_analysis(analysis.id)
rescue StandardError => e
  printf "%-40s %s\n", "Retrieve Analysis", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Retrieve Analysis", "SUCCESS"
end

#puts "ANALYSIS: #{analysis}" if d.analysis_loaded?

puts '********* GET ANALYSES *************'
begin
 analyses = d.get('analyses')
rescue StandardError => e
   printf "%-40s %s\n", "Get Analyses", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Get Analyses", "SUCCESS"
  #puts analyses
end

puts '********* LOGIN ************'
begin
  login = d.login('nicholas.long@nrel.gov','testing123')
rescue StandardError => e
  printf "%-40s %s\n", "Login", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Login", "SUCCESS"
  puts login
end

puts '********* Upload ANALYSIS **********'

d.load_analysis('./data/analysis/analysis_test.json')
puts "ANALYSIS LOADED? #{d.analysis_loaded?}"
begin
  analysis_response = d.upload_analysis
rescue StandardError => e
  printf "%-40s %s\n", "Upload Analysis", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Upload Analysis", "SUCCESS"
  puts analysis_response
  #puts "@analysis var: #{d.analysis}"
end

puts '********* Upload STRUCTURE *********'
d.load_structure('./data/analysis/data_points/data_point_test.json')
puts "STRUCTURE LOADED? #{d.structure_loaded?}"
begin
  structure_response = d.upload_structure('test_user_id1')
rescue StandardError => e
  printf "%-40s %s\n", "Upload Structure", "FAIL"
  puts e
else
  printf "%-40s %s\n", "Upload Structure", "SUCCESS"
  puts structure_response
  #puts "@structure var: #{d.structure}"
end

puts '******* LOGOUT *******'
d.logout
