require 'rake/packagetask'
require 'json'

manifest = JSON.parse(open('manifest.json').read)
package_files = [
  'img',
  'js',
  'pages',
  'manifest.json'
]

Rake::PackageTask.new("release", manifest['version']) do |t|
  t.need_zip = true
  t.package_files.include(package_files)
end