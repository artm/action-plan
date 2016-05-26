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
end

