require "rails_helper"

describe CircuitBreaker do
  context 'when circuit breaker is successful' do
    it 'allows the app to run and stays closed' do
      circuit_breaker = CircuitBreaker.new(failure_threshold: 2, recovery_timeout: 1)
      
      expect {
        circuit_breaker.call {puts "Operation successful"} 
    }.to output("Operation successful\n").to_stdout
      
      expect(circuit_breaker.send(:closed?)).to be true
    end
  end

  context 'when circuit breaker fails' do
    circuit_breaker = CircuitBreaker.new(failure_threshold: 2, recovery_timeout: 1)
    let(:failing_operation) { -> { raise StandardError, 'Operation failed' } }

    it 'opens after specified number of failures' do
      expect { 
        2.times { circuit_breaker.call(&failing_operation) rescue StandardError }
      }.to change { circuit_breaker.send(:open?)}.from(false).to(true)
    end
  end

  context 'after the recovery timeout' do
    circuit_breaker = CircuitBreaker.new(failure_threshold: 2, recovery_timeout: 1)
    let(:failing_operation) { -> { raise StandardError, 'Operation failed' } }

    it 'attempts to reset the circuit' do
      2.times { circuit_breaker.call(&failing_operation) rescue StandardError }
      sleep 1.1 

      expect {
        circuit_breaker.call {puts "Operation successful"} 
    }.to output("Operation successful\n").to_stdout
      
      expect(circuit_breaker.send(:closed?)).to be true
    end
  end
end