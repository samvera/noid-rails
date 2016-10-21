describe ActiveFedora::Noid::Config do
  subject { described_class.new }

  it { is_expected.to respond_to(:template) }
  it { is_expected.to respond_to(:statefile) }
  it { is_expected.to respond_to(:namespace) }
  it { is_expected.to respond_to(:minter_class) }
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

  describe '#minter_class' do
    let(:default) { ActiveFedora::Noid::Minter::Db }

    it 'has a default' do
      expect(subject.minter_class).to eq default
    end

    context 'when overridden' do
      before { subject.minter_class = different_minter }
      let(:different_minter) { ActiveFedora::Noid::Minter::File }
      it 'uses the different minter' do
        expect(subject.minter_class).to eq different_minter
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

    context 'with a short custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/cd/abcd/members" }
      let(:custom_template) { '.reeee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abcd/members' }
    end

    context 'with an even shorter custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/c/abc/members" }
      let(:custom_template) { '.reee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abc/members' }
    end

    context 'with a long custom template' do
      let(:uri) { "http://localhost:8983/fedora/rest/test/ab/cd/ef/gh/abcdefghijklmnopqrstuvwxyz/members" }
      let(:custom_template) { '.reeeeeeeeeeeeeeeeeeeeeeeeee' }
      before { config.template = custom_template }
      subject { translator.call(uri) }

      it { is_expected.to eq 'abcdefghijklmnopqrstuvwxyz/members' }
    end
  end

  describe '#translate_id_to_uri' do
    let(:config) { described_class.new }
    let(:translator) { config.translate_id_to_uri }
    let(:id) { "hh63vz2/members" }
    let(:ActiveFedora) { double(ActiveFedora) }
    subject { translator.call(id) }
    before do
      allow(ActiveFedora).to receive_message_chain("fedora.host") { "http://localhost:8983" }
      allow(ActiveFedora).to receive_message_chain("fedora.base_path") { "/fedora/rest/test" }
    end

    it { is_expected.to eq "http://localhost:8983/fedora/rest/test/hh/63/vz/2/hh63vz2/members" }

    context "with a hash code id" do
      let(:id) { 'hh63vz2#g123' }
      it { is_expected.to eq "http://localhost:8983/fedora/rest/test/hh/63/vz/2/hh63vz2#g123" }
    end

    context 'with a short custom template' do
      let(:id) { "abcd/members" }
      let(:custom_template) { '.reeee' }
      before { config.template = custom_template }
      subject { translator.call(id) }
      it { is_expected.to eq "http://localhost:8983/fedora/rest/test/ab/cd/abcd/members" }
    end

    context 'with an even shorter custom template' do
      let(:id) { 'abc/members' }
      let(:custom_template) { '.reee' }
      before { config.template = custom_template }
      subject { translator.call(id) }
      it { is_expected.to eq "http://localhost:8983/fedora/rest/test/ab/c/abc/members" }
    end

    context 'with a long custom template' do
      let(:id) { "abcdefghijklmnopqrstuvwxyz/members" }
      let(:custom_template) { '.reeeeeeeeeeeeeeeeeeeeeeeeee' }
      before { config.template = custom_template }
      subject { translator.call(id) }
      it { is_expected.to eq "http://localhost:8983/fedora/rest/test/ab/cd/ef/gh/abcdefghijklmnopqrstuvwxyz/members" }
    end
  end
end
