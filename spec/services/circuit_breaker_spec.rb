require 'rails_helper'

describe CircuitBreaker do
  subject(:circuit_breaker) { described_class.new(failure_threshold: 2, recovery_timeout: 1) }

  context 'when operation is successful' do
    it 'allows the operation to run and stays closed' do
      expect { |b| circuit_breaker.call(&b) }.to yield_control
      expect(circuit_breaker.closed?).to be true
    end
  end

  context 'when operation fails' do
    let(:failing_operation) { -> { raise StandardError, 'Operation failed' } }

    it 'opens after specified number of failures' do
      expect { 
        2.times { circuit_breaker.call(&failing_operation) rescue StandardError }
      }.to change { circuit_breaker.open? }.from(false).to(true)
    end
  end

  context 'after the recovery timeout' do
    let(:failing_operation) { -> { raise StandardError, 'Operation failed' } }

    it 'attempts to reset the circuit' do
      2.times { circuit_breaker.call(&failing_operation) rescue StandardError }
      sleep 1.1 # wait for recovery timeout

      expect { |b| circuit_breaker.call(&b) }.to yield_control
      expect(circuit_breaker.closed?).to be true
    end
  end
end