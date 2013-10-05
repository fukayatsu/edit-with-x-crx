#!/usr/bin/env ruby
require 'tempfile'
require 'json'
require 'em-websocket'

Encoding.default_external = "UTF-8"

Process.daemon if ARGV[0] == "-d"

EM.run {
  EM::WebSocket.run(host: "0.0.0.0", port: 51234) do |ws|
    ws.onopen { |handshake|
      # puts "WebSocket connection open"
    }

    ws.onclose {
      # puts "Connection closed"
    }

    ws.onmessage { |msg|
      data = JSON.parse(msg)

      case data['method']
      when 'init'
        tempfile = Tempfile.new(['editwith_', data['ext'] || '.md'])
        tempfile << data['text']
        # run: "${editor} -w ${file}:${line}:${col}"
        command = data['command'].split(' ').map { |arg|
          arg.gsub('${editor}', data['editor'])
          .gsub('${file}', tempfile.path)
          .gsub('${line}', data['line'].to_s)
          .gsub('${col}',  data['col'].to_s)
        }
        pid = spawn(*command)
        ws.send({ method: 'inited', tempfile: tempfile.path, pid: pid }.to_json)
        tempfile.close false
      when 'watch'
        tempfile = data['tempfile']
        text = File.open(tempfile).read
        pid  = data['pid']
        ws.send({ method: 'watched', tempfile: tempfile, pid: pid, text: text}.to_json)

        begin
          Process.getpgid(pid)
        rescue
          begin
            Process.detach(pid)
            Process.kill(:INT, pid)
          rescue
          end
          ws.close
        end
      end
    }
  end
}