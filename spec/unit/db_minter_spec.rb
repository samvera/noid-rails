include MinterStateHelper

describe ActiveFedora::Noid::Minter::Db do
  before(:each) { reset_minter_state_table }
  after( :all ) { reset_minter_state_table }

  before :each do
    # default novel mintings
    allow(ActiveFedora::Base).to receive(:exists?).and_return(false)
    allow(ActiveFedora::Base).to receive(:gone?).and_return(false)
  end

  let(:minter) { described_class.new }
  let(:other) { described_class.new('.reedddk') }

  describe '#initialize' do
    it 'raises on bad templates' do
      expect{ described_class.new('reeddeeddk') }.to raise_error(Noid::TemplateError)
      expect{ described_class.new('')           }.to raise_error(Noid::TemplateError)
    end
    it 'returns object w/ default template' do
      expect(minter).to be_instance_of described_class
      expect(minter).to be_a Noid::Minter
      expect(minter.template).to be_instance_of Noid::Template
      expect(minter.template.to_s).to eq ActiveFedora::Noid.config.template
    end
    it 'accepts valid template arg' do
      expect(other).to be_instance_of described_class
      expect(other).to be_a Noid::Minter
      expect(other.template).to be_instance_of Noid::Template
      expect(other.template.to_s).to eq '.reedddk'
    end
  end

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
  end

  context 'conflicts' do
    let(:existing_pid) { 'ef12ef12f' }
    let(:unique_pid) { 'bb22bb22b' }
    before :each do
      expect(minter).to receive(:next_id).and_return(existing_pid, unique_pid)
    end

    context 'when the pid already exists in Fedora' do
      before do
        expect(ActiveFedora::Base).to receive(:exists?).with(existing_pid).and_return(true)
      end
      it 'skips the existing pid' do
        expect(minter.mint).to eq unique_pid
      end
    end

    context 'when the pid already existed in Fedora and now is gone' do
      let(:gone_pid) { existing_pid }
      before do
        expect(ActiveFedora::Base).to receive(:gone?).with(gone_pid).and_return(true)
      end
      it 'skips the deleted pid' do
        expect(minter.mint).to eq unique_pid
      end
    end
  end
end
