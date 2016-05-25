require "spec_helper"
require "actions/procrastinate"
require "actions/just_do_it"

describe Action::Plan do
  it 'has a version number' do
    expect(Action::Plan::VERSION).not_to be nil
  end

  let(:action_class) { Procrastinate }
  let(:plan) {
    Action::Plan.new do |plan|
      plan.action action_class
    end
  }

  it "can be instantiated" do
    expect(plan).to be_kind_of Action::Plan
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
      Action::Plan.new do |plan|
        plan.action action_class do |config|
          config.setting = 1
        end
      end
    }

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

    it "freezes run-time configs" do
      plan
      expect_any_instance_of(action_class).to receive(:run) do |action|
        expect{ action.config.setting = 2 }.to raise_error RuntimeError, /can't modify frozen/
      end
      plan.run
    end
  end

  describe "action states" do
    let(:plan) {
      Action::Plan.new do |plan|
        plan.action JustDoIt
        plan.action JustDoIt
      end
    }
    let(:state_a) { plan.action_states[0] }
    let(:state_b) { plan.action_states[1] }
    let(:action_a) { instance_double("JustDoIt") }
    let(:action_b) { instance_double("JustDoIt") }
    before do
      allow(state_a).to receive(:create_action) { action_a }
      allow(state_b).to receive(:create_action) { action_b }
      allow(action_a).to receive(:run)
      allow(action_b).to receive(:run)
    end

    it "initializes all actions as :planned" do
      expect(state_a.status).to eq :planned
      expect(state_b.status).to eq :planned
    end

    it "sets action states to :done after successful run" do
      plan.run
      expect(state_a.status).to eq :done
      expect(state_b.status).to eq :done
    end

    it "sets action state to :running just before calling its #run" do
      expect(action_a).to receive(:run) do
        expect(state_a.status).to eq :running
        expect(state_b.status).to eq :planned
      end
      expect(action_b).to receive(:run) do
        expect(state_a.status).to eq :done
        expect(state_b.status).to eq :running
      end
      plan.run
    end

    it "sets action state to :failed if its #run raises exception" do
      expect(action_a).to receive(:run) do
        expect(state_a.status).to eq :running
        expect(state_b.status).to eq :planned
        raise RuntimeError, "couldn't do it"
      end
      expect(action_b).not_to receive(:run)
      plan.run
      expect(state_a.status).to eq :failed
      expect(state_b.status).to eq :planned
    end
  end

  describe "#runnable?" do
    subject(:plan) { Action::Plan.new }
    shared_examples "runnable" do |status|
      before do
        expect(plan).to receive(:status) { status }
      end
      it { is_expected.to be_runnable }
    end

    shared_examples "not runnable" do |status|
      before do
        expect(plan).to receive(:status) { status }
      end
      it { is_expected.to_not be_runnable }
    end

    it_behaves_like "runnable", :empty
    it_behaves_like "runnable", :planned
    it_behaves_like "runnable", :failed
    it_behaves_like "not runnable", :running
    it_behaves_like "not runnable", :done
    it_behaves_like "not runnable", :invalid
  end
end
