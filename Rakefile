# Bootstrap Middleman so we can access its config
#
# N.B. Set MM_ENV variable when calling rake tasks to choose proper Middleman "mode" (:server or :build)
require 'middleman-core/load_paths'
::Middleman.setup_load_paths

require 'middleman-core'
require 'middleman-core/application'
require 'middleman-autoprefixer'

begin
  app = ::Middleman::Application.new do
    config[:exit_before_ready] = true
    config[:environment] = (ENV['MM_ENVIRONMENT'] && ENV['MM_ENVIRONMENT'].to_sym) || :development
  end
  config = app.config
ensure
  app.shutdown!
end

desc "Run the development server"
task :server do
  puts "## Running development server. Press CTRL + C to exit..."
  puts "*** Wait until \"The Middleman is standing watch\" appears before loading site! ***"
  system("bundle exec middleman server --port=4567 --force-polling --latency=1.0")
  exit true
end

namespace :build do
  desc "Build the website from source"
  task :build do
    puts '## Building site'
    status = system("bundle exec middleman build")
    puts "Result: #{status ? "Success" : "Fail"}"
    exit status
  end

  desc "Create a zip folder of build"
  task :zip do
    puts '## Creating zip file of build'
    zip_filename = config[:deploy_settings][:zip_filename] || "build-#{Time.now.to_i}.zip"
    status = system("mkdir -p zip && zip -r zip/#{zip_filename} build")
    puts "Result: #{status ? "Success" : "Fail"}"
    exit status
  end
end


desc "Build the website from source"
task :build do
  Rake::Task['build:build'].invoke
end


namespace :deploy do
  desc "Print deploy settings and exit"
  task :settings do
    puts "## Printing deploy settings for #{config[:environment]} environment"
    config[:deploy_settings][:servers].each_with_index do |server, index|
      puts ''
      puts "Server ##{index + 1}"
      puts server
      puts deploy_command(server[:dir], server[:ssh])
    end
  end

  desc "Deploy build via rsync"
  task :rsync do
    puts "## Deploy website to #{config[:environment]} environment"
    config[:deploy_settings][:servers].each do |server|
      puts cmd = deploy_command(server[:dir], server[:ssh])
      status = system(cmd)
      puts "Result: #{status ? "Success" : "Fail"}"
      exit status
    end
  end

  desc "Print deploy URL(s)"
  task :url do
    puts config[:deploy_settings][:url]
  end

  desc 'Post deploy success status to Github'
  task :success_status do
    unless config[:deploy_settings][:github_status]
      puts "You must configure the :github_status key in config[:deploy_settings]"
      exit false
    end
    github_status = config[:deploy_settings][:github_status]

    require 'json'
    body = {
      state: "success",
      target_url: config[:deploy_settings][:url],
      description: "A build has been deployed to sandbox. Check it!",
      context: "sandbox/deploy"
    }
    cmd = "curl -X POST --data '#{JSON.unparse(body)}' https://api.github.com/repos/#{github_status[:owner]}/#{github_status[:repo]}/statuses/#{github_status[:sha1]}?access_token=#{github_status[:access_token]}"
    puts cmd
    result = system(cmd)
    exit result
  end
end


desc "Deploy website remotely via rsync (over SSH)"
task :deploy do
  Rake::Task['deploy:rsync'].invoke
end

def deploy_command(dir, ssh=nil)
  if ssh
    key_file = ssh[:identity_file] && " -i #{ssh[:identity_file]}"
    e_flag = " -e 'ssh#{key_file}'"
    remote_host = "#{ssh[:user]}#{'@' if ssh[:user]}#{ssh[:host]}"
    mkdir = "ssh#{key_file} #{remote_host} 'mkdir -p #{dir}' &&"
  else
    e_flag = ''
    remote_host = nil
    mkdir = "mkdir -p #{dir} &&"
  end
 "#{mkdir} rsync --delete -av#{e_flag} build/ #{remote_host}#{':' if remote_host}#{dir}"
end
