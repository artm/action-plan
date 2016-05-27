require "spec_helper"
require "actions/procrastinate"
require "actions/just_do_it"
require "plan_helpers"

describe Action::Plan do
  describe "setup" do
    include_context "exposed plan", 1, Procrastinate

    it "calls root action's #plan()" do
      expect_any_instance_of(Procrastinate).to receive(:plan)
      plan
    end

    it "can be run" do
      expect {
        plan.run
      }.not_to raise_error
    end
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
    include_context "exposed plan", 2

    it "initializes all actions as :planned" do
      expect(states[0].status).to eq :planned
      expect(states[1].status).to eq :planned
    end

    it "sets action states to :done after successful run" do
      plan.run
      expect(states[0].status).to eq :done
      expect(states[1].status).to eq :done
    end

    it "sets action state to :running just before calling its #run" do
      expect(actions[0]).to receive(:run) do
        expect(states[0].status).to eq :running
        expect(states[1].status).to eq :planned
      end
      expect(actions[1]).to receive(:run) do
        expect(states[0].status).to eq :done
        expect(states[1].status).to eq :running
      end
      plan.run
    end

    it "sets action state to :failed if its #run raises exception" do
      expect(actions[0]).to receive(:run) do
        expect(states[0].status).to eq :running
        expect(states[1].status).to eq :planned
        raise RuntimeError, "couldn't do it"
      end
      expect(actions[1]).not_to receive(:run)
      plan.run
      expect(states[0].status).to eq :failed
      expect(states[1].status).to eq :planned
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

    it "prevents plan from running when false" do
      expect(plan).to receive(:runnable?) { false }
      expect(plan).to receive(:status) { :in_a_bad_way }
      expect{ plan.run }.to raise_error Action::Plan::NotRunnable, /in_a_bad_way plan can't be run/
    end
  end

  describe "re-running" do
    include_context "plan state", [:done, :failed, :planned]

    it "skips done action" do
      expect(actions[0]).not_to receive(:run)
      plan.run
    end

    it "runs failed action" do
      expect(actions[1]).to receive(:run)
      plan.run
    end

    it "runs planned action" do
      expect(actions[2]).to receive(:run)
      plan.run
    end
  end
end
