require 'spec_helper'

describe Dencity::Client do
  before(:all) do
    @options = Hashie::Mash.new(host_name: 'http://localhost:3000/')
  end

  it 'should connect to host' do
    d = Dencity.connect(@options)
    expect(d.connected?).to eq true
  end

  context 'Unauthenticated but Connected' do
    before(:all) do
      @d = Dencity.connect(@options)
    end
    it 'should search' do

      filters = []
      filters << { name: 'building_type', value: ['Community Center', 'Office'], operator: 'in' }
      return_only = ['aspect_ratio']
      page = 0
      results = @d.search(filters, return_only, page)
      expect(results).to be_an_instance_of(Hashie::Mash)
      expect(results.results).to_not be_nil
    end

    context 'Retrieve Analysis' do
      before(:all) do
        @d = Dencity.connect(@options)
        response = @d.dencity_get('analyses')
        @analysis = response.data[0]
        puts "analysis: #{@analysis}"
      end

      it 'should get analysis by name and user_id' do
        ra = @d.retrieve_analysis_by_name(@analysis.name, @analysis.user_id)
        expect(ra).to be_an_instance_of(Hashie::Mash)
        expect(ra.id).to_not be_nil
      end

      it 'should get analysis by id' do
        a = @d.retrieve_analysis_by_id(@analysis.id)
        expect(a).to be_an_instance_of(Hashie::Mash)
        expect(a.id).to_not be_nil
      end
    end
  end

  context 'Authenticated' do

    it 'should login' do
      @d = Dencity.connect(@options)
      login = @d.login('nicholas.long@nrel.gov', 'testing123')
      expect(login).to be_an_instance_of(Hashie::Mash)
      expect(login.id).to_not be_nil
    end

    before(:all) do
      @options.username = 'nicholas.long@nrel.gov'
      @options.password = 'testing123'
      @d = Dencity.connect(@options)
      $structure = nil
      $analysis = nil
    end

    it 'should upload an analysis' do
      analysis_path = File.join(File.dirname(__FILE__), 'data', 'analysis.json')
      $analysis = @d.load_analysis(analysis_path)
      # analysis loaded?
      expect($analysis).to_not be_nil
      # analysis response
      analysis_response = $analysis.push
      expect(analysis_response).to be_an_instance_of(Hashie::Mash)
      expect(analysis_response.analysis.id).to_not be_nil
      expect(analysis_response.status.to_s).to start_with '2'
    end

    it 'should upload a structure' do
      structure_path = File.join(File.dirname(__FILE__), 'data', 'structure.json')
      $structure = @d.load_structure($analysis.analysis.id,'test_user_id', structure_path)
      # structure loaded?
      expect($structure).to_not be_nil
      # structure response
      structure_response = $structure.push
      expect(structure_response).to be_an_instance_of(Hashie::Mash)
      expect(structure_response.id).to_not be_nil
      expect(structure_response.status.to_s).to start_with '2'
    end

    it 'should upload a file' do
      file_path = File.join(File.dirname(__FILE__), 'data', 'related_File.txt')
      response = $structure.upload_file(file_path, 'test-related-file.txt')
      expect(response).to be_an_instance_of(Hashie::Mash)
      expect(response.id).to_not be_nil
      expect(response.status.to_s).to start_with '2'
    end

    it 'should delete an uploaded file' do
      response = $structure.delete_file('test-related-file.txt')
      expect(response).to be_an_instance_of(Hashie::Mash)
      expect(response.message).to_not be_nil
    end

  end
end
