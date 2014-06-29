namespace :chruby do
  task :install do
    roles(:all).each do |host|
      provision :source_installer, host,
        source: "https://github.com/postmodern/chruby/archive/v0.3.8.tar.gz",
        sha: "320d13bacafeae72631093dba1cd5526147d03cc"

      provision :source_installer, host,
        source: "https://github.com/postmodern/ruby-install/archive/v0.4.3.tar.gz",
        sha: "be7dd5ad558102ab812addd3100a91c9812d0317"
    end
  end

  task :install_ruby do
    roles(:all).each do |host|
    end
  end
end

namespace :load do
  task :defaults do
    unless fetch(:chruby_ruby)
      version_file = File.expand_path "../.ruby-version", ENV["BUNDLE_GEMFILE"]
      if File.exist? version_file
        set :chruby_ruby, File.read( version_file ).strip
      end
    end
  end
end