# More info at https://github.com/guard/guard#readme

guard 'coffeescript', input: 'src/js', output: 'js'

haml_options = { format: :html5, attr_wrapper: '"', ugly: false }
guard "haml", input: "src/pages", output: "pages", haml_options: haml_options do
  watch %r{\.haml}
end