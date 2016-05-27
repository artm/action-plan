require "actions/just_do_it"

module PlanHelpers
  shared_context "plan, states" do |*classes|
    let(:plan) {
      Action::Plan.new do |plan|
        classes.each do |c|
          plan.action c
        end
      end
    }
    let(:states) { plan.action_states }
  end

  shared_context "plan, states, actions" do |*classes|
    include_context "plan, states", *classes
    let(:actions) { classes.map{ |c| double(c.name, run: nil) } }
    before do
      states.zip(actions).each do |state, action|
        allow(state).to receive(:create_action) { action }
      end
    end
  end

  shared_context "plan with statuses" do |*statuses|
    include_context "plan, states, actions", *statuses.map{JustDoIt}
    before do
      states.zip(statuses).each do |state, status|
        state.status = status
      end
    end
  end
end
