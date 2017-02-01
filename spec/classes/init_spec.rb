require 'spec_helper'
describe 'vms' do

  context 'with defaults for all parameters' do
    it { should contain_class('vms') }
  end
end
