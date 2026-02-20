
class ApplicationService
  def self.call(**kwargs)
    new(**kwargs).call
  end

  def call
    raise NotImplementedError, "Services must implement #call"
  end
end
