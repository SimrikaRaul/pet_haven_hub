# Base service class — subclass for concrete services
class ApplicationService
  def self.call(*args)
    new(*args).call
  end

  def call
    raise NotImplementedError, "Services must implement #call"
  end
end
