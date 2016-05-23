require 'spec_helper'

require 'action/base'
class Procrastinate < Action::Base

end

describe Action::Plan do
  it 'has a version number' do
    expect(Action::Plan::VERSION).not_to be nil
  end

  let(:plan) {
    Action::Plan.new( Procrastinate )
  }

  it "can be instantiated" do
    expect(plan).to be_kind_of Action::Plan
  end
end
