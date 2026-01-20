# Configure dartsass-rails to compile SCSS files
# This tells dartsass-rails to compile app/assets/stylesheets/application.scss
# to app/assets/builds/application.css
Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

# Ensure dartsass compiles on boot in development
if Rails.env.development?
  Rails.application.config.dartsass.silence_deprecation = true
end
