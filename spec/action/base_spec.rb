require "spec_helper"
require "action/base"
require "actions/procrastinate"
require "actions/just_do_it"
require "actions/delegate_work"

describe Action::Base do
  let(:plan) { double("plan") }
  let(:action) { action_class.new(plan: plan) }

  context "implements neither #run or #plan" do
    let(:action_class) { Procrastinate }

    it "doesn't respond to #run" do
      expect(action).not_to respond_to(:run)
    end

    it "doesn't plan itself upon #plan" do
      expect(action).not_to receive(:plan_itself)
      action.plan
    end
  end

  context "implements #run but no #plan" do
    let(:action_class) { JustDoIt }

    it "plans itself upon #plan" do
      expect(plan).to receive(:schedule_action).with(JustDoIt)
      action.plan
    end
  end

  context "doesn't implement #run, but plans other actions" do
    let(:action_class) { DelegateWork }

    it "plans the other action" do
      expect(plan).to receive(:plan_action).with(JustDoIt)
      action.plan
    end
  end
end

