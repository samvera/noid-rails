describe ActiveFedora::Noid::Minter::Db do
  let(:obj) { described_class.new }
  it 'constructs without args' do
    expect{ obj }.not_to raise_error
    expect(obj).to be_instance_of described_class
    expect(obj).to be_a Noid::Minter
  end
  it 'constructs with template arg and validates' do
    x = nil
    expect{ described_class.new('reeddeeddk') }.to raise_error(Noid::TemplateError)
    expect{ x = described_class.new('.reeddeeddk') }.not_to raise_error
    expect(x).to be_instance_of described_class
    expect(x.template).to be_instance_of Noid::Template
    expect(x.template.to_s).to eq '.reeddeeddk'
  end
  describe 'mint' do
    let(:obj) { described_class.new('.reeddeeddk') }
    it 'warns on first mint' do
      expect(ActiveFedora::Base).to receive(:exists?).and_return false
      expect(ActiveFedora::Base).to receive(:gone?).and_return false
      # expect(obj).to receive(:warn).with(/Creating first MinterState in database/)
      id = nil
      expect{ id = obj.mint }.not_to raise_error
      expect(id).to be_a String
    end
  end
end
