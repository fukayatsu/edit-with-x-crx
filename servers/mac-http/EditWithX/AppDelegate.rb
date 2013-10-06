#
#  AppDelegate.rb
#  EditWithX
#
#  Created by fukayatsu on 2013/10/05.
#  Copyright 2013年 fukayatsu. All rights reserved.
#

require 'webrick'
require 'thread'
require 'tmpdir'
require 'json'


class AppDelegate
    attr_accessor :window
    attr_accessor :status_menu
    attr_accessor :server_port
    attr_accessor :auto_launch_on_login
    
    def applicationDidFinishLaunching(a_notification)
        system_status_bar = NSStatusBar.systemStatusBar
        status_item = system_status_bar.statusItemWithLength(NSVariableStatusItemLength)
        status_item.highlightMode = true
        #status_item.title = 'EditWithX'
        status_item.image = NSImage.imageNamed("Status")
        status_item.menu = self.status_menu
        
        @tmpdir = Dir.mktmpdir
        
        start_server
        
    end
    
    def applicationWillTerminate(a_notification)
        FileUtils.remove_entry_secure @tmpdir
    end
    
    def restart_server
        if @server
            @server.shutdown
            @server_thread.join
        end
        
        start_server
    end
    
    def start_server
        @server_thread = Thread.start do
            @server = generate_server
            @server.start
        end
    end
    
    def generate_server
        server = WEBrick::HTTPServer.new(BindAddress:  '0.0.0.0', Port: defaults.stringForKey('server_port') || '51234')
        server.mount_proc('/') { |req, res|
            res.body = 'ok'
        }
        server.mount_proc('/init') { |req, res|
            return res.status = 405 unless req.request_method == 'POST'
            
            data = JSON.parse(req.body)
            
            tempfile = File.open("#{@tmpdir}/editwith_#{Time.now.to_i}#{data['ext'] || '.md'}", 'w')
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
            res.body = { method: 'inited', tempfile: tempfile.path, pid: pid }.to_json
        }
        
        server.mount_proc('/watch') { |req, res|
            return res.status = 405 unless req.request_method == 'POST'
            
            data          = JSON.parse(req.body)
            pid           = data['pid'].to_i
            tempfile      = data['tempfile']
            text          = File.open(tempfile).read
            
            begin
                Process.getpgid(pid)
                res.body = { method: 'watched', tempfile: tempfile, pid: pid, text: text}.to_json
            rescue
                begin
                    Process.detach(pid)
                    Process.kill(:INT, pid)
                rescue
                end
                puts "finished"
                res.body = { method: 'finished', text: text }.to_json
            end
            
        }
        
        server
    end
    
    def auto_launch?
       NSApp.isInLoginItems == 1
    end
    
    def auto_launch(change_to)
       return if auto_launch? == change_to
       
        if change_to
            NSApp.addToLoginItems
        else
            NSApp.removeFromLoginItems
        end
    end
    
    def open_preference(sender)
        window.makeKeyAndOrderFront(self)
        NSApp.activateIgnoringOtherApps(true)
        server_port.stringValue = defaults.stringForKey('server_port') || '51234'
        auto_launch_on_login.state = auto_launch? ? 1 : 0
    end
    
    def save_preference(sender)
        defaults.setObject(server_port.stringValue, forKey: 'server_port')
        defaults.synchronize
        auto_launch(auto_launch_on_login.state == 1)
        
        restart_server
    end
    
    def defaults
        NSUserDefaults.standardUserDefaults
    end
end

