# frozen_string_literal: true

RSpec.describe Awshark::CloudFormation::Template do
  let(:template) { described_class.new(path: path, stage: stage) }
  let(:stage) { nil }

  json_path = 'spec/fixtures/cloud_formation/json'
  yaml_path = 'spec/fixtures/cloud_formation/yaml'
  json_filepath = 'spec/fixtures/cloud_formation/json/template.json'
  yaml_filepath = 'spec/fixtures/cloud_formation/yaml/template.yaml'

  describe '#as_json' do
    subject { template.as_json }

    context "with directory path #{json_path}" do
      let(:path) { json_path }

      it { is_expected.to be_a(Hash) }

      it 'contains the DynamoDB key schema' do
        properties = subject['Resources']['myDynamoDBTable']['Properties']
        expect(properties['KeySchema']).to be_present
      end
    end

    context "with directory path #{yaml_path}" do
      let(:path) { yaml_path }
      let(:stage) { 'test' }

      it { is_expected.to be_a(Hash) }

      it 'contains the correct queue name' do
        properties = subject['Resources']['TestQueue']['Properties']
        expect(properties['QueueName']).to eq('Foo')
      end
    end

    context "with file path #{json_filepath}" do
      let(:path) { json_filepath }

      it { is_expected.to be_a(Hash) }
    end

    context "with file path #{yaml_filepath}" do
      let(:path) { yaml_filepath }

      it { is_expected.to be_a(Hash) }

      it 'contains the correct queue name' do
        properties = subject['Resources']['TestQueue']['Properties']
        expect(properties['QueueName']).to be_nil
      end
    end
  end

  describe '#body' do
    subject { template.body }
    let(:path) { yaml_path }

    it { is_expected.to be_a(String) }
  end

  describe '#context' do
    subject { template.context }
    let(:stage) { 'test' }

    context "with directory path #{json_path}" do
      let(:path) { json_path }

      it do
        is_expected.to eq({ context: { 'S3Bucket' => 'foo.bar.org' }, stage: 'test' })
      end
    end

    context "with directory path #{yaml_path}" do
      let(:path) { yaml_path }

      it do
        is_expected.to eq({
          context: {
            'QueueName' => 'Foo',
            'Instances' => [
              { 'Name'=>'foo', 'Type'=>'small' },
              { 'Name'=>'bar', 'Type'=>'medium' }
            ],
          },
          stage: 'test'
        })
      end
    end

    context 'with file path' do
      let(:path) { 'spec/fixtures/cloud_formation/yaml/template.yml' }

      it { is_expected.to eq({ context: {}, stage: 'test' }) }
    end

    context 'with no context file' do
      let(:path) { 'spec/fixtures/cloud_formation/empty' }

      it { is_expected.to eq({ context: {}, stage: 'test' }) }
    end
  end
end