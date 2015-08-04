require 'dencity'

d = Dencity.connect({host_name: 'http://localhost:3000/'})

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
