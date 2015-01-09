require 'spec_helper'

describe Scalr::VersionHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::PathHelper } }

  describe '#venv_python' do
    it 'should work' do
      node.set[:scalr][:python][:venv] = '/venv'
      expect(dummy_class.new.venv_python(node)).to eq('/venv/bin/python')
    end
  end

  describe '#venv_pip' do
    it 'should work' do
      node.set[:scalr][:python][:venv] = '/venv'
      expect(dummy_class.new.venv_python(node)).to eq('/venv/bin/python')
    end
  end

  describe '#venv_build_path' do
    it 'should work' do
      node.set[:scalr][:python][:venv] = '/venv'
      expect(dummy_class.new.venv_build_path(node)).to eq('/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin')
    end
  end
end
