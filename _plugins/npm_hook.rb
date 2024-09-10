require 'fileutils'
require 'yaml'

module Jekyll
  # Pre-build hook to run `npm install`
  Jekyll::Hooks.register :site, :after_init do |site|
    config = site.config

    puts "Running `npm install`..."
    system('npm install')

    # Install extra npm dependencies
    if config['npm_hook'] && config['npm_hook']['npm_dependencies']
      config['npm_hook']['npm_dependencies'].each do |dependency|
        puts "Installing npm dependency: #{dependency}..."
        system("npm install #{dependency}")
      end
    end
  end

  # Post-build hook to copy files and directories
  Jekyll::Hooks.register :site, :post_write do |site|
    config = site.config

    # Get the build directory from the configuration or default to '_site'
    build_dir = config['build_dir'] || '_site'

    # Print the build directory
    puts "Build directory: #{build_dir}"

    # Copy files and directories as specified in _config.yml
    if config['npm_hook']
      modules_dir = config['npm_hook']['modules_dir'] || 'node_modules'

      # Copy individual files
      if config['npm_hook']['copy_files']
        config['npm_hook']['copy_files'].each do |copy_task|
          source = File.join(modules_dir, copy_task['src'])
          target = File.join(build_dir, copy_task['dst'])
          puts "Copying file from #{source} to #{target}..."
          unless Dir.exist?(File.dirname(target))
            FileUtils.mkdir_p(File.dirname(target))
          end
          FileUtils.cp(source, target)
        end
      end

      # Copy directories
      if config['npm_hook']['copy_dirs']
        config['npm_hook']['copy_dirs'].each do |copy_task|
          source = File.join(modules_dir, copy_task['src'])
          target = File.join(build_dir, copy_task['dst'])
          puts "Copying directory from #{source} to #{target}..."

          # Create directory if it doesn't exist
          unless Dir.exist?(target)
            puts "Creating directory #{target}..."
            FileUtils.mkdir_p(target)
          end

          # Copy contents of the source directory to the target directory
          Dir.glob("#{source}/*").each do |file|
            FileUtils.cp_r(file, target)
          end
        end
      end
    end
  end
end
