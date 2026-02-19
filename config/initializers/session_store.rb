# frozen_string_literal: true

# Configure session store for browser-session-only cookies
# Sessions will expire when the browser tab/window is closed
Rails.application.config.session_store :cookie_store,
  key: '_pet_haven_hub_session',
  expire_after: nil,  # Session expires when browser closes (no persistent cookie)
  httponly: true,     # Prevent JavaScript access to session cookie
  secure: Rails.env.production?,  # Use secure cookies (HTTPS only) in production
  same_site: :lax     # CSRF protection
