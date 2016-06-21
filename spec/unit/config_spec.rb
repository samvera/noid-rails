describe ActiveFedora::Noid::Config do
  it { is_expected.to respond_to(:template) }
  it { is_expected.to respond_to(:statefile) }
  it { is_expected.to respond_to(:namespace) }
  it { is_expected.to respond_to(:translate_id_to_uri) }
  it { is_expected.to respond_to(:translate_uri_to_id) }

  describe '#template' do
    let(:default) { '.reeddeeddk' }

    it 'has a default' do
      expect(subject.template).to eq default
    end

    describe 'overriding' do
      before { subject.template = custom_template }

      let(:custom_template) { '.dddddd' }

      it 'allows setting a custom template' do
        expect(subject.template).to eq custom_template
      end
    end
  end

  describe '#translate_uri_to_id' do
    let(:config) { described_class.new }
    let(:translator) { config.translate_uri_to_id }
    let(:uri) { "http://localhost:8983/fedora/rest/test/hh/63/vz/22/hh63vz22q/members" }
    let(:ActiveFedora) { double(ActiveFedora) }
    subject { translator.call(uri) }
    before do
      allow(ActiveFedora).to receive_message_chain("fedora.host") { "http://localhost:8983" }
      allow(ActiveFedora).to receive_message_chain("fedora.base_path") { "/fedora/rest/test" }
    end

    it { is_expected.to eq 'hh63vz22q/members' }

    context "with a hash code uri" do
      let(:uri) { "http://localhost:8983/fedora/rest/test/hh/63/vz/22/hh63vz22q#g123" }
    it { is_expected.to eq 'hh63vz22q#g123' }
    end

    describe 'with a short custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/cd/abcd/members" }
      let(:custom_template) { '.reeee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abcd/members' }
    end

    describe 'with an even shorter custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/c/abc/members" }
      let(:custom_template) { '.reee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abc/members' }
    end

    describe 'with a long custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/cd/ef/gh/abcdefghijklmnopqrstuvwxyz/members" }
      let(:custom_template) { '.reeeeeeeeeeeeeeeeeeeeeeeeee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abcdefghijklmnopqrstuvwxyz/members' }
    end

  end
end
