namespace :chruby do
  task :install => ["chruby:install_chruby","chruby:autoload","chruby:install_ruby"] do

  end

  task :install_chruby do
    roles(:all).each do |host|
      provision :source_installer, host,
        source: "https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz",
        sha: "320d13bacafeae72631093dba1cd5526147d03cc",
        version: "0.3.8",
        force: true

      server_file host, "/usr/local/share/chruby/chruby.sh" do
        mode "0755"
      end
      server_file host, "/usr/local/share/chruby/auto.sh" do
        mode "0755"
      end

      provision :source_installer, host,
        source: "https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz",
        sha: "be7dd5ad558102ab812addd3100a91c9812d0317",
        version: "0.4.3"
    end
  end

  task :install_ruby do
    on provisioned_hosts( roles(:all) ), in: :parallel do |host|
      manifest = host_manifest( host )
      manifest.select( :ruby_install ) do |bucket|
        Array( fetch(:ruby_versions,fetch(:chruby_ruby)) ).each do |ruby_version|
          sudo 'ruby-install', ruby_version, "--no-reinstall"

          config_change host, "/etc/gemrc" do
            changes entry: "gem: --no-rdoc --no-ri", id: "skip-documentation"
          end

          execute "/usr/local/bin/chruby-exec #{ruby_version} -- gem install bundler"
        end
      end
    end
  end

  task :autoload do
    on provisioned_hosts( roles(:all) ), in: :parallel do |host|
      server_file host, "/etc/profile.d/chruby.sh" do
        owner "root"
        group "root"
        mode "0755"
        template "chruby.sh.erb"
      end
    end
  end

end

task "fastfood:bootstrap:install_ruby" => "chruby:install"

namespace :load do
  task :defaults do
    unless fetch(:chruby_ruby)
      version_file = File.expand_path "../.ruby-version", ENV["BUNDLE_GEMFILE"]
      if File.exist? version_file
        set :chruby_ruby, "#{fetch(:chruby_platform,"ruby")} #{File.read( version_file ).strip}"
      end
    end
  end
end