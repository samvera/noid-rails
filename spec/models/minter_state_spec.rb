describe MinterState, type: :model do
  let(:state) { described_class.new }
  it 'validates template' do
    expect{ state.save! }.to raise_error(ActiveRecord::RecordInvalid)
    state.template = 'bad_template'
    expect{ state.save! }.to raise_error(ActiveRecord::RecordInvalid)
    state.template = '.reeddeeddk'
    expect{ state.save! }.not_to raise_error
  end
  it 'noid_options' do
    expect(state.noid_options).to be_nil
    state.template = '.reeddeeddk'
    state.seq = 1
  end
end
