include MinterStateHelper

describe ActiveFedora::Noid::Minter::Db do
  before(:each) { reset_minter_state_table }
  after(:all) { reset_minter_state_table }

  before :each do
    # default novel mintings
    allow(ActiveFedora::Base).to receive(:exists?).and_return(false)
    allow(ActiveFedora::Base).to receive(:gone?).and_return(false)
  end

  let(:other) { described_class.new('.reedddk') }

  it_behaves_like 'a minter' do
    let(:minter) { described_class.new }
  end

  describe '#initialize' do
    it 'raises on bad templates' do
      expect{ described_class.new('reeddeeddk') }.to raise_error(Noid::TemplateError)
      expect{ described_class.new('')           }.to raise_error(Noid::TemplateError)
    end
    it 'returns object w/ default template' do
      expect(subject).to be_instance_of described_class
      expect(subject).to be_a Noid::Minter
      expect(subject.template).to be_instance_of Noid::Template
      expect(subject.template.to_s).to eq ActiveFedora::Noid.config.template
    end
    it 'accepts valid template arg' do
      expect(other).to be_instance_of described_class
      expect(other).to be_a Noid::Minter
      expect(other.template).to be_instance_of Noid::Template
      expect(other.template.to_s).to eq '.reedddk'
    end
  end

  describe '#read' do
    it 'returns a hash' do
      expect(subject.read).to be_a(Hash)
    end
    it 'has the expected namespace' do
      expect(subject.read[:namespace]).to eq ActiveFedora::Noid.config.namespace
    end
    it 'has the expected template' do
      expect(subject.read[:template]).to eq ActiveFedora::Noid.config.template
    end
  end

  describe '#write!' do
    let(:starting_state) { subject.read }
    let(:minter) { Noid::Minter.new(starting_state) }
    before { minter.mint }
    it 'changes the state of the minter' do
      expect { subject.write!(minter) }.to change { subject.read[:seq] }
                                           .from(starting_state[:seq]).to(minter.seq)
                                       .and change { subject.read[:counters] }
                                           .from(starting_state[:counters]).to(minter.counters)
                                       .and change { subject.read[:rand] }
                                           .from(starting_state[:rand]).to(Marshal.dump(minter.instance_variable_get(:@rand)))
    end
  end
end
