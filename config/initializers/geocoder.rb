# Geocoder initializer (uses environment variable for lookup)
if defined?(Geocoder)
  Geocoder.configure(
    lookup: :nominatim,
    http_headers: { "User-Agent" => "PetHavenHub/1.0" },
    timeout: 5
  )
end
