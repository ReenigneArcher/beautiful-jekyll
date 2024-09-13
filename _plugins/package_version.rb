# Find package.json file and load dependencies into site.config
# The version of each package can be parsed for loading dependencies from jsdelivr
# Used by ./_includes/footer_scripts.html and ./_includes/head.html
require 'json'

module Jekyll
  class PackageVersionGenerator < Generator
    safe true
    priority :high

    def generate(site)
      theme_package_json_path = File.join(site.theme.root, 'package.json')
      site_package_json_path = File.join(site.source, 'package.json')

      theme_dependencies = {}
      site_dependencies = {}

      if File.exist?(theme_package_json_path)
        theme_package_json = JSON.parse(File.read(theme_package_json_path))
        theme_dependencies = theme_package_json['dependencies'] || {}
      end

      if File.exist?(site_package_json_path)
        site_package_json = JSON.parse(File.read(site_package_json_path))
        site_dependencies = site_package_json['dependencies'] || {}
      end

      # Merge dependencies, giving precedence to site dependencies
      combined_dependencies = theme_dependencies.merge(site_dependencies)

      site.config['package_versions'] = combined_dependencies
      puts "package_versions: #{site.config['package_versions']}"
    end
  end
end
