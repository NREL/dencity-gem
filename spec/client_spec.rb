require 'spec_helper'

describe Dencity::Client do
  before(:all) do
    @options = {host_name: 'http://localhost:3000/'}
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
      before(:each) do
        @d = Dencity.connect(@options)
        @analysis = @d.get('analyses')[0]
      end
      it 'should get analysis by name and user_id' do
        ra = @d.retrieve_analysis(@analysis.name, @analysis.user_id)
        expect(ra).to be_an_instance_of(Hashie::Mash)
        expect(ra.id).to_not be_nil
      end

      it 'should get analysis by id' do
        a = @d.get_analysis(@analysis.id)
        expect(a).to be_an_instance_of(Hashie::Mash)
        expect(a.id).to_not be_nil
      end
    end
  end
end
