require "spec_helper"
require "action/base"
require "actions/procrastinate"
require "actions/just_do_it"
require "actions/delegate_work"

describe Action::Base do
  let(:plan) { double("plan") }
  let(:action) { action_class.new }
  let(:plan_dsl) { double("plan dsl") }

  context "implements neither #run or #plan" do
    let(:action_class) { Procrastinate }

    it "doesn't plan itself upon #plan" do
      expect(plan_dsl).not_to receive(:myself)
      action.plan plan_dsl
    end
  end

  context "implements #run but no #plan" do
    let(:action_class) { JustDoIt }

    it "plans itself upon #plan" do
      expect(plan_dsl).to receive(:myself)
      action.plan plan_dsl
    end
  end

  describe "run time state" do
    let(:run_time_state) { ActiveSupport::OrderedHash.new }
    let(:action) { Action::Base.new(run_time_state: run_time_state) }

    it "supports todo=" do
      expect{ action.send(:todo=, 100) }.to change{run_time_state[:todo]}
        .from(nil).to(100)
    end

    it "supports done=" do
      expect{ action.send(:done=, 1) }.to change{run_time_state[:done]}
        .from(nil).to(1)
    end

    context "run time state not set" do
      let(:run_time_state) { nil }

      it "breaks on todo=" do
        expect{ action.send(:todo=, 100) }.to raise_error Action::NoRuntimeState
      end

      it "breaks on done=" do
        expect{ action.send(:done=, 1) }.to raise_error Action::NoRuntimeState
      end
    end
  end
end

