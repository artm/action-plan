require 'spec_helper'
require 'actions/procrastinate'

describe Action::Plan do
  it 'has a version number' do
    expect(Action::Plan::VERSION).not_to be nil
  end

  let(:plan) { Action::Plan.new( Procrastinate ) }

  it "can be instantiated" do
    expect(plan).to be_kind_of Action::Plan
  end

  it "calls root action's ::plan()" do
    expect(Procrastinate).to receive(:plan)
    plan
  end
end
