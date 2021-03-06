require "spec_helper"
require "actions/procrastinate"
require "actions/just_do_it"
require "actions/delegate_work"
require "actions/busy_work"
require "actions/break_down"
require "plan_helpers"

describe Action::Plan do
  describe "constructor" do
    let(:plan) {
      Action::Plan.new do |plan|
        plan.action Procrastinate
      end
    }

    it "calls actions' #plan()" do
      expect_any_instance_of(Procrastinate).to receive(:plan)
      plan
    end
  end

  describe "#run" do
    context "with a single action" do
      include_context "plan, states", JustDoIt

      it "can be run" do
        expect { plan.run }.not_to raise_error
      end

      it "broadcasts state changes" do
        log = []
        plan.on(:plan_state_changed) do |plan, state, new_status, old_status|
          log << new_status
        end
        plan.run
        expect(log).to eq [:running, :done]
      end
    end

    context "with action broadcasting progress" do
      include_context "plan, states", BusyWork
      it "rebroadcasts action progress" do
        log = []
        plan.on(:action_progress) do |plan, action, progress, total|
          log << [progress, total]
        end
        plan.run
        expect(log).to eq [[1, 3], [2, 3], [3, 3]]
      end
    end

    context "with failing action" do
      include_context "plan, states", BreakDown

      it "broadcasts error details" do
        log = []
        plan.on(:action_failure) do |plan, action, exception|
          log << exception
        end
        plan.run
        expect(log.length).to eq 1
      end
    end
  end

  context "action didn't plan itself" do
    include_context "plan, states, actions", Procrastinate
    it "won't be run" do
      expect(actions.first).not_to receive(:run)
      plan.run
    end
  end

  context "action did plan itself" do
    include_context "plan, states, actions", JustDoIt
    it "will be run" do
      expect(actions[0]).to receive(:run)
      plan.run
    end
  end

  describe "action configs" do
    let(:plan) {
      Action::Plan.new do |plan|
        plan.action JustDoIt do |config|
          config.setting = 1
        end
      end
    }

    it "doesn't break the default action config" do
      plan
      expect(JustDoIt.config.setting).to be_nil
    end

    it "recalls the config when executing action's #run" do
      plan
      expect_any_instance_of(JustDoIt).to receive(:run) do |action|
        expect(action.config.setting).to eq 1
      end
      plan.run
    end

    it "freezes run-time configs" do
      plan
      expect_any_instance_of(JustDoIt).to receive(:run) do |action|
        expect{ action.config.setting = 2 }.to raise_error RuntimeError, /can't modify frozen/
      end
      plan.run
    end
  end

  describe "action states" do
    include_context "plan, states, actions", JustDoIt, JustDoIt, JustDoIt

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
      describe "with status #{status}" do
        before do
          expect(plan).to receive(:status) { status }
        end
        it { is_expected.to be_runnable }
      end
    end

    shared_examples "not runnable" do |status|
      describe "with status #{status}" do
        before do
          expect(plan).to receive(:status) { status }
        end
        it { is_expected.to_not be_runnable }
      end
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
    include_context "plan with statuses", :done, :failed, :planned

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

  describe "#to_json" do
    include_context "plan with statuses", :done, :running, :planned
    subject(:plan_json) { plan.to_json }
    it { is_expected.to be_kind_of String }

    describe "parsing json" do
      let(:loaded_plan) { JSON.parse(plan_json, create_additions: true) }
      it "deserializes the original plan" do
        expect(loaded_plan).to be == plan
      end
    end
  end
end
