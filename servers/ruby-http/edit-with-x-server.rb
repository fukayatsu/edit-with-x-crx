#!/usr/bin/env ruby
require 'tmpdir'

tmpdir = Dir.mktmpdir
at_exit {
  FileUtils.remove_entry_secure tmpdir
}

require 'sinatra'
require 'json'

set :port,    51234
set :tmpdir,  tmpdir

get '/' do
  "ok"
end

post '/init' do
  data     =  JSON.parse(request.body.read)
  tempfile = File.open("#{tmpdir}/editwith_#{Time.now.to_i}#{data['ext'] || '.md'}", 'w')
  tempfile << data['text']

  command = data['command'].split(' ').map { |arg|
    arg.gsub('${editor}', data['editor'])
    .gsub('${file}', tempfile.path)
    .gsub('${line}', data['line'].to_s)
    .gsub('${col}',  data['col'].to_s)
  }

  tempfile.close
  pid  = spawn(*command)
  path = tempfile.path
  { method: 'inited', tempfile: tempfile.path, pid: pid }.to_json
end

post '/watch' do
  data     =  JSON.parse(request.body.read)
  pid      = data['pid'].to_i
  tempfile = data['tempfile']
  text     = File.open(tempfile).read

  begin
    Process.getpgid(pid)
    return { method: 'watched', tempfile: tempfile, pid: pid, text: text}.to_json
  rescue
    begin
      Process.detach(pid)
      Process.kill(:INT, pid)
    rescue
    end
    puts "finished"
    return { method: 'finished', text: text }.to_json
  end
end

