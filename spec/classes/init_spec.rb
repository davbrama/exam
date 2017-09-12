require 'spec_helper'
describe 'exam' do
  context 'with default values for all parameters' do
    it { should contain_class('exam') }
  end
end
