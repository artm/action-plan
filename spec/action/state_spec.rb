require "spec_helper"
require "action/state"

describe Action::State do
  describe "::sequence_status" do
    shared_examples "sequence status" do |statuses, expected_sequence_status|
      subject(:sequence_status) { Action::State.sequence_status(statuses) }
      describe statuses do
        it { is_expected.to eq expected_sequence_status }
      end
    end

    it_behaves_like "sequence status", [], :empty

    it_behaves_like "sequence status", [:planned], :planned
    it_behaves_like "sequence status", [:planned, :planned], :planned
    it_behaves_like "sequence status", [:planned, :planned, :planned], :planned

    it_behaves_like "sequence status", [:done], :done
    it_behaves_like "sequence status", [:done, :done], :done
    it_behaves_like "sequence status", [:done, :done, :done], :done

    it_behaves_like "sequence status", [:running], :running
    it_behaves_like "sequence status", [:done, :running], :running
    it_behaves_like "sequence status", [:done, :done, :running], :running
    it_behaves_like "sequence status", [:running, :planned], :running
    it_behaves_like "sequence status", [:running, :planned, :planned], :running
    it_behaves_like "sequence status", [:done, :running, :planned, :planned], :running
    it_behaves_like "sequence status", [:done, :done, :running, :planned, :planned], :running

    it_behaves_like "sequence status", [:failed], :failed
    it_behaves_like "sequence status", [:done, :failed], :failed
    it_behaves_like "sequence status", [:done, :done, :failed], :failed
    it_behaves_like "sequence status", [:failed, :planned], :failed
    it_behaves_like "sequence status", [:failed, :planned, :planned], :failed
    it_behaves_like "sequence status", [:done, :failed, :planned, :planned], :failed
    it_behaves_like "sequence status", [:done, :done, :failed, :planned, :planned], :failed

    it_behaves_like "sequence status", [:planned, :done], :invalid
    it_behaves_like "sequence status", [:failed, :failed], :invalid
    it_behaves_like "sequence status", [:running, :running], :invalid
    it_behaves_like "sequence status", [:running, :failed], :invalid
    it_behaves_like "sequence status", [:failed, :running], :invalid
    it_behaves_like "sequence status", [:planned, :failed], :invalid
    it_behaves_like "sequence status", [:planned, :running], :invalid
    it_behaves_like "sequence status", [:failed, :done], :invalid
    it_behaves_like "sequence status", [:running, :done], :invalid
  end
end
