require "spec_helper"
require "actions/procrastinate"
require "actions/just_do_it"

describe Action::Plan do
  it 'has a version number' do
    expect(Action::Plan::VERSION).not_to be nil
  end

  let(:action_class) { Procrastinate }
  let(:plan) { Action::Plan.new(action_class) }

  it "can be instantiated" do
    expect(plan).to be_kind_of Action::Plan
  end

  it "knows its root action" do
    expect(plan.root_action).to be_kind_of Procrastinate
  end

  it "calls root action's #plan()" do
    expect_any_instance_of(Procrastinate).to receive(:plan)
    plan
  end

  it "can be run" do
    expect {
      plan.run
    }.not_to raise_error
  end

  context "action didn't plan itself" do
    it "won't be run" do
      plan
      expect_any_instance_of(Procrastinate).not_to receive(:run)
      plan.run
    end
  end

  context "action did plan itself" do
    let(:action_class) { JustDoIt }
    it "will be run" do
      plan
      expect_any_instance_of(JustDoIt).to receive(:run)
      plan.run
    end
  end

  describe "action configs" do
    let(:action_class) { JustDoIt }
    let(:plan) {
      Action::Plan.new(action_class) do |config|
        config.setting = 1
      end
    }

    it "configures the actions" do
      expect(plan.root_action.config.setting).to eq 1
    end

    it "doesn't break the default action config" do
      plan
      expect(action_class.config.setting).to be_nil
    end

    it "recalls the config when executing action's #run" do
      plan
      expect_any_instance_of(action_class).to receive(:run) do |action|
        expect(action.config.setting).to eq 1
      end
      plan.run
    end
  end
end
