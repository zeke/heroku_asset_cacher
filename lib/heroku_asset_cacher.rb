class HerokuAssetCacher
  @@regex_pattern = /\/\w+\/all.*/i
  
  def initialize_asset_packager
    unless File.directory? heroku_file_location
      Dir.mkdir(heroku_file_location)
    end

    $asset_cache_base_path = heroku_file_location  
  end
  
  def initialize(app)
    @app = app
    initialize_asset_packager if ActionController::Base.perform_caching
  end
  
  def call(env)
		@env = env
		if ActionController::Base.perform_caching
			return render_css if env['REQUEST_PATH'] =~ /\/stylesheets\/all.css/i
			return render_js if env['REQUEST_PATH'] =~ /\/javascripts\/all.js/i
		end
    
		@app.call(env)
  end
  
  def render_js
		file_name = @@regex_pattern.match(@env['REQUEST_PATH'])[1]

		file = "#{heroku_file_location}/javascripts/all.js"
			[
				200,
				{
				'Cache-Control'  => 'public, max-age=86400',
				'Content-Length' => File.size(file).to_s,
				'Content-Type'   => 'text/javascript'
				},
				File.read(file)
			]
  end
  
  def render_css
		file_name = @@regex_pattern.match(@env['REQUEST_PATH'])[1]
		file = "#{heroku_file_location}/stylesheets/all.css"
			[
				200,
				{
				'Cache-Control'  => 'public, max-age=86400',
				'Content-Length' => File.size(file).to_s,
				'Content-Type'   => 'text/css'
				},
				File.read(file)
			]
  end
  
	def heroku_file_location
		"#{RAILS_ROOT}/tmp/asset_cache"
	end
	
end
