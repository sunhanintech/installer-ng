require 'chefspec'

describe 'scalr-server::group_service_enabled' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '12.04') do |node|
      node.set['scalr_server']['config_dir'] = '/tmp'
    end.converge(described_recipe)
  end

  it 'is just a smoke test' do
  end
end