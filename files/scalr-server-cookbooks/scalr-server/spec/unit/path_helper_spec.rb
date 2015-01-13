require 'spec_helper'

describe Scalr::VersionHelper do
  let(:node) { ChefSpec::SoloRunner.new.node }
  let(:dummy_class) { Class.new { include Scalr::PathHelper } }

  # TODO !
end
