#!/usr/bin/env ruby
require 'tempfile'
require 'json'
require 'em-websocket'

Encoding.default_external = "UTF-8"

Process.daemon if ARGV[0] == "-d"

pid = 0
text = ""

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 51234) do |ws|
    # ws.onopen { |handshake|
    #   puts "WebSocket connection open"
    # }

    # ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      data = JSON.parse(msg)

      case data['method']
      when 'init'
        temp = Tempfile.new(['editwith_', '.md'])
        temp << data['text']
        pid = spawn(data['editor'], *data['options'], temp.path)
        ws.send({ method: 'inited', tempfile: temp.path }.to_json)
        temp.close false
      when 'watch'
        new_text = File.open(data['tempfile']).read
        if (new_text == text)
          ws.send({ method: 'watched', tempfile: data['tempfile']}.to_json)
        else
          text = new_text
          ws.send({ method: 'watched', tempfile: data['tempfile'], text: text}.to_json)
        end

        begin
        # プロセスの生存チェック
          Process.getpgid(pid)
        rescue
          begin
            Process.detach(pid)
            Process.kill(:INT, pid)
          end
          ws.close
        end
      end
    }
  end
}