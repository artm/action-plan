require "actions/just_do_it"

module PlanHelpers
  shared_context "exposed plan" do |count, action_class=JustDoIt|
    let(:plan) {
      Action::Plan.new do |plan|
        count.times do
          plan.action action_class
        end
      end
    }
    let(:states) { plan.action_states }
    let(:actions) { states.map{ double("action", run: nil) } }
    before do
      states.each_with_index do |state, i|
        allow(state).to receive(:create_action) { actions[i] }
      end
    end
  end

  shared_context "plan state" do |statuses|
    include_context "exposed plan", statuses.count
    before do
      statuses.each_with_index do |status, index|
        state = states[index]
        state.status = status
        allow(state).to receive(:create_action) { actions[index] }
      end
    end
  end


end
