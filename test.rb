require 'dencity'

d = Dencity.connect({host_name: 'http://localhost:3000/'})

# TODO: add response checks in gem or here?
# TODO: need other ways of loading something from file?
# TODO: it may be better to pass around analysis and structure in a hash instead of in json?
# TODO: double check validation by analysis name and user_id (and what error msg comes back)


puts '****** SEARCH ********'
filters = []
filters << { name: 'building_area', value: 2737.26, operator: 'lt' }
filters << { name: 'building_type', value: ['Community Center'], operator: 'in' }
return_only = ['related_files']
page = 1
results = d.search(filters, return_only, page)
puts "RESULTS: #{results}"
puts "Number of results: #{results.results.size}"

puts '********  GET ANALYSIS BY NAME & USER_ID *********'
analysis = d.retrieve_analysis('test_analysis', '53a3656d986ffba2c5000001')
puts "ANALYSIS: #{analysis}"

puts '******** GET ANALYSIS BY ID ************'
analysis2 = d.get_analysis(analysis.id)
puts "2nd ANALYSIS: #{analysis2}"

puts '********* GET ANALYSES *************'
puts d.get('analyses')

puts '********* AUTHENTICATE ************'
d.login('nicholas.long@nrel.gov','testing123')

puts '********* Upload ANALYSIS **********'

loaded_analysis = d.load_analysis('./data/analysis/analysis_test.json')
analysis_response = d.upload_analysis(loaded_analysis)
puts analysis_response
analysis_id = analysis_response.analysis.id
puts "Analysis id: #{analysis_id}"

puts '********* Upload STRUCTURE *********'
loaded_structure = d.load_structure('./data/analysis/data_points/data_point_test.json')
structure_response = d.upload_structure(loaded_structure, analysis_id)
puts structure_response
