# frozen_string_literal: true
describe ActiveFedora::Noid::Minter::File do
  before do
    # default novel mintings
    allow(ActiveFedora::Base).to receive(:exists?).and_return(false)
    allow(ActiveFedora::Base).to receive(:gone?).and_return(false)
  end

  it { is_expected.to respond_to(:mint) }

  it 'has a default statefile' do
    expect(subject.statefile).to eq ActiveFedora::Noid.config.statefile
  end
  it 'has a default template' do
    expect(subject.template.to_s).to eq ActiveFedora::Noid.config.template
  end

  it_behaves_like 'a minter' do
    let(:minter) { described_class.new }
  end

  describe '#initialize' do
    let(:template) { '.rededk' }
    let(:statefile) { '/tmp/foobar' }

    subject { described_class.new(template, statefile) }

    it 'respects the custom template' do
      expect(subject.template.to_s).to eq template
    end
    it 'respects the custom statefile' do
      expect(subject.statefile).to eq statefile
    end
  end

  describe '#read' do
    it 'returns a hash' do
      expect(subject.read).to be_a(Hash)
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
        .and change { subject.read[:rand] }
        .from(starting_state[:rand]).to(Marshal.dump(minter.instance_variable_get(:@rand)))
        .and change { subject.read[:counters] }
        .to(minter.counters)
    end
  end
end
