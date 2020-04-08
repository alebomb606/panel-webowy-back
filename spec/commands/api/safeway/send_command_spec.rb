require 'rails_helper'

RSpec.describe Api::Safeway::SendCommand do
  describe '.call' do
    subject { described_class.call(trailer, status) }

    let(:trailer) { build(:trailer) }

    context 'with armed status' do
      let(:status) { 'armed' }

      it 'calls Api::Safeway::Arm' do
        expect(Api::Safeway::Arm).to receive(:call)
        subject
      end
    end

    context 'with disarmed status' do
      let(:status) { 'disarmed' }

      it 'calls Api::Safeway::Disarm' do
        expect(Api::Safeway::Disarm).to receive(:call)
        subject
      end
    end

    context 'with alarm status' do
      let(:status) { 'alarm' }

      it 'calls Api::Safeway::AlarmOn' do
        expect(Api::Safeway::AlarmOn).to receive(:call)
        subject
      end
    end

    context 'with emergency_call status' do
      let(:status) { 'emergency_call' }

      it 'calls Api::Safeway::AlarmOn' do
        expect(Api::Safeway::AlarmOn).to receive(:call)
        subject
      end
    end

    context 'with alarm_silenced status' do
      let(:status) { 'alarm_silenced' }

      it 'calls Api::Safeway::AlarmOff' do
        expect(Api::Safeway::AlarmOff).to receive(:call)
        subject
      end
    end

    context 'with alarm_off status' do
      let(:status) { 'alarm_off' }

      it 'calls Api::Safeway::AlarmOff' do
        expect(Api::Safeway::AlarmOff).to receive(:call)
        subject
      end
    end

    context 'with start_loading status' do
      let(:status) { 'start_loading' }

      it 'calls Api::Safeway::StartLoading' do
        expect(Api::Safeway::StartLoading).to receive(:call)
        subject
      end
    end

    context 'with end_loading status' do
      let(:status) { 'end_loading' }

      it 'calls Api::Safeway::EndLoading' do
        expect(Api::Safeway::EndLoading).to receive(:call)
        subject
      end
    end

    context 'with any other status' do
      let(:status) { 'other_status' }

      it 'does not call anything' do
        expect(Api::Safeway::Arm).not_to receive(:call)
        expect(Api::Safeway::Disarm).not_to receive(:call)
        expect(Api::Safeway::AlarmOn).not_to receive(:call)
        expect(Api::Safeway::AlarmOff).not_to receive(:call)
        expect(Api::Safeway::StartLoading).not_to receive(:call)
        expect(Api::Safeway::EndLoading).not_to receive(:call)
        subject
      end
    end
  end
end
