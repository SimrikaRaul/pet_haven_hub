module Admin::RequestsHelper
  def can_perform_action?(request)
    request.open? || request.pending?
  end

  def request_status_badge(request)
    case request.status
    when 'open', 'pending'
      '<span class="status-badge status-pending">⏳ OPEN</span>'
    when 'approved'
      '<span class="status-badge status-approved">✓ APPROVED</span>'
    when 'rejected'
      '<span class="status-badge status-rejected">✗ REJECTED</span>'
    when 'completed'
      '<span class="status-badge status-completed">★ COMPLETED</span>'
    else
      '<span class="status-badge">UNKNOWN</span>'
    end.html_safe
  end
end
