require "spec_helper"
require "action/state"

describe Action::State do
  describe "::sequence_status" do
    subject(:sequence_status) { Action::State.sequence_status(statuses) }

    context "empty sequence" do
      let(:statuses) { [] }
      it { is_expected.to eq :empty }
    end

    context "all planned" do
      let(:statuses) { [:planned, :planned, :planned] }
      it { is_expected.to eq :planned }
    end

    context "all done" do
      let(:statuses) { [:done, :done, :done] }
      it { is_expected.to eq :done }
    end
  end
end
