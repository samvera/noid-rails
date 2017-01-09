# frozen_string_literal: true
shared_examples 'a minter' do
  describe '#mint' do
    subject { minter.mint }

    it { is_expected.not_to be_empty }

    it 'does not mint the same ID twice in a row' do
      expect(subject).not_to eq described_class.new.mint
    end

    it 'is valid' do
      expect(minter.valid?(subject)).to be true
      expect(described_class.new.valid?(subject)).to be true
    end

    it 'is invalid under a different template' do
      expect(described_class.new('.reedddk').valid?(subject)).to be false
    end

    context 'with a different template' do
      let(:other) { described_class.new('.reedddk') }
      it 'is invalid under a different template' do
        expect(other).not_to be_valid(minter.mint)
      end
    end
  end

  context 'conflicts' do
    let(:existing_pid) { 'ef12ef12f' }
    let(:unique_pid)   { 'bb22bb22b' }

    before do
      expect(subject).to receive(:next_id).and_return(existing_pid, unique_pid)
    end

    context 'when the pid already exists in Fedora' do
      before do
        expect(ActiveFedora::Base).to receive(:exists?).with(existing_pid).and_return(true)
      end
      it 'skips the existing pid' do
        expect(subject.mint).to eq unique_pid
      end
    end

    context 'when the pid already existed in Fedora and now is gone' do
      let(:gone_pid) { existing_pid }

      before do
        expect(ActiveFedora::Base).to receive(:gone?).with(gone_pid).and_return(true)
      end

      it 'skips the deleted pid' do
        expect(subject.mint).to eq unique_pid
      end
    end
  end
end
