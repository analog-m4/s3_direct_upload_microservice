class CircuitBreaker
  attr_reader :failure_threshold, :recovery_timeout

  def initialize(failure_threshold: 3, recovery_timeout: 30)
    @failure_threshold = failure_threshold
    @recovery_timeout = recovery_timeout
    @state = :closed
    failure_count = 0
    @latest_failure_time = nil
  end

  def call 
    return handle_open_circuit if open?

    begin
      result = yield
      reset_failure_count if closed?
      result
    rescue StandardError => e
      handle_failure(e)
    end    
  end

  private

  def handle_failure(error)
    @failure_count += 1
    @latest_failure_time = Time.now

    if @failure_count >= failure_threshold
      open_circuit
      puts "Circuit is now open: #{error.message}"
    else 
      raise error
    end
  end

  def handle_open_circuit
    if Time.now - @latest_failure_time >= recovery_timeout
      begin
        result = yield
        close_circuit 
        puts "Circuit is now closed"
        result
      rescue StandardError => e
        open_circuit
        puts "Circuit remains open: #{e.message}"
      end
    else 
      puts "Circuit is open; request not allowed"
    end
  end

  def open?
    @state == :open
  end

  def closed?
    @state == :closed
  end

  def open_circuit
    @state = :open
  end

  def close_circuit
    @state = :closed
    reset_failure_count
  end

  def reset_failure_count
    @failure_count = 0 
  end
end
  