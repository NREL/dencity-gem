require 'dencity'

d = Dencity.connect(host_name: 'http://localhost:3000/')

# to login using stored credentials:
# begin
#   login = d.login
# rescue StandardError => e
#   printf "%-40s %s\n", 'Login', 'FAIL'
#   puts e
# else
#   printf "%-40s %s\n", 'Login', 'SUCCESS'
#   puts login
# end

puts '****** SEARCH ********'
filters = []
filters << { name: 'building_area', value: 2737.26, operator: 'lt' }
filters << { name: 'building_type', value: ['Community Center'], operator: 'in' }
return_only = ['related_files']
page = 0 # pages are 0-based
begin
  results = d.search(filters, return_only, page)
rescue StandardError => e
  printf "%-40s %s\n", 'Search', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Search', 'SUCCESS'
end
# puts "RESULTS: #{results}"
puts "Total number of pages in results set: #{results.total_pages}"
puts "Number of results: #{results.results.size}"

puts '********  GET ANALYSIS BY NAME & USER_ID *********'
begin
  analysis = d.retrieve_analysis_by_name('test_analysis', '53a3656d986ffba2c5000001')
rescue StandardError => e
  printf "%-40s %s\n", 'Retrieve Analysis', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Retrieve Analysis', 'SUCCESS'
end

puts '******** GET ANALYSIS BY ID ************'
begin
  analysis = d.retrieve_analysis_by_id(analysis.id)
rescue StandardError => e
  printf "%-40s %s\n", 'Retrieve Analysis', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Retrieve Analysis', 'SUCCESS'
end

puts '********* GET ANALYSES *************'
begin
  analyses = d.dencity_get('analyses')
 rescue StandardError => e
   printf "%-40s %s\n", 'Get Analyses', 'FAIL'
   puts e
 else
   printf "%-40s %s\n", 'Get Analyses', 'SUCCESS'
  # puts analyses
end

puts '********* LOGIN ************'
begin
  login = d.login('nicholas.long@nrel.gov', 'testing123')
rescue StandardError => e
  printf "%-40s %s\n", 'Login', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Login', 'SUCCESS'
  puts login
end

puts '********* Upload ANALYSIS **********'

analysis = d.load_analysis('./spec/data/analysis.json')
begin
  a_response = analysis.push
rescue StandardError => e
  printf "%-40s %s\n", 'Upload Analysis', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Upload Analysis', 'SUCCESS'
  puts a_response
end

puts '********* Upload STRUCTURE *********'
structure = d.load_structure(analysis.analysis.id, 'testing!', './spec/data/structure.json')
puts "STRUCTURE: #{structure}"
begin
  s_response = structure.push
  rescue StandardError => e
    printf "%-40s %s\n", 'Upload Structure', 'FAIL'
    puts e
  else
    printf "%-40s %s\n", 'Upload Structure', 'SUCCESS'
    puts s_response
end

puts '******* Upload RELATED FILE *******'
begin
  response = structure.upload_file('./spec/data/related_file.txt', 'test-related-file.txt')
rescue StandardError => e
  printf "%-40s %s\n", 'Upload RelatedFile', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Upload RelatedFile', 'SUCCESS'
  puts response
end

puts '********** GET STRUCTURE *************'
begin
  new_structure = d.dencity_get("structures/#{structure.structure.id}")
rescue StandardError => e
  printf "%-40s %s\n", 'Retrieve Structure', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Retrieve Structure', 'SUCCESS'
end
puts new_structure

puts '******* Delete a RELATED FILE *******'
begin
  response = structure.delete_file('test-related-file.txt')
rescue StandardError => e
  printf "%-40s %s\n", 'Delete File', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Delete File', 'SUCCESS'
  puts response
end

puts '********** BULK UPLOAD ***********'
d.load_structure(analysis.analysis.id, 'testing_bulk_1', './spec/data/structure.json')
d.load_structure(analysis.analysis.id, 'testing_bulk_2', './spec/data/structure.json')
d.load_structure(analysis.analysis.id, 'testing_bulk_3', './spec/data/structure.json')

puts "structures: #{d.structures.size}"
begin
  b_response = d.bulk_upload_structures
rescue StandardError => e
  printf "%-40s %s\n", 'Upload Structure', 'FAIL'
  puts e
else
  printf "%-40s %s\n", 'Upload Structure', 'SUCCESS'
  puts b_response
end

puts '******* LOGOUT *******'
d.logout
