activate :scss_lint

activate :autoprefixer, browsers: [
  'last 2 versions'
]

activate :external_pipeline,
  name: :webpack,
  command: build? ? './node_modules/webpack/bin/webpack.js --bail' : './node_modules/webpack/bin/webpack.js --watch -d',
  source: ".tmp/dist",
  latency: 1

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # "Ignore" JS so webpack has full control.
  ignore { |path| path =~ /\/(.*)\.js$/ && $1 != 'all' }

  # Minify Javascript on build
  activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  config[:relative_links] = true

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

configure :server do
  ready do
    files.on_change :source do |changed|
      changed_js = changed.select do |f|
        f[:full_path].extname === '.js' && !f[:full_path].to_s.include?('.tmp')
      end

      if changed_js.length > 0
        puts "== Linting Javascript"
        puts `./node_modules/eslint/bin/eslint.js #{changed_js.map { |js| js[:full_path].relative_path_from(app.root_path).to_s }.join(' ')}`
      end
    end
  end
end

