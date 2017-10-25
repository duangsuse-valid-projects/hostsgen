#!/bin/env ruby

# hostsgen is a tool for managing hosts projects

#########################################################################
#   Copyright 2017 duangsuse
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#########################################################################

VERSION = "0.1.0"
CFG_FILENAME = "hostsgen.yml"

# main function
def start(args)
  options = CmdlineOptions.new(args)
  if !options.silent then
    print "Hostsgen v" + VERSION + "; "
    puts case options.operate
      when 0; "building project..."
      when 1; "checking hosts data..."
      when 2; "cleaning..."
      when 3; "printing help..."
      when 4; "printing version..."
    end
    if options.out then puts "[INFO] Outputting to " + options.out + " ..." end
    if options.no_comments then puts "[INFO] No comments in output file" end
    if options.mod_black_list.length != 0 then print "[INFO] No compile: "; puts options.mod_black_list.to_s end
  end
  if options.operate == 3 then
    puts "Usage: ", $0 + " [build/check/clean/help/version] (args)", "args: -q:quiet -o:out [file] -t:no comments -b(an) [mod]"
  end
  if options.operate == 4 then puts VERSION end
  project_cfg = ProjectConfig.new(options.silent)
  if !options.silent then
    print "[INFO] Project '"
    print project_cfg.name
    print "' by "
    puts project_cfg.authors.to_s
    print "[INFO] Default output: "
    print project_cfg.out
    print " , desc: "
    puts project_cfg.desc
    print "[INFO] Modules: "
    puts project_cfg.mods.to_s
  end
end

# commandline arguments structure&parser
# commandline usage:
# ruby hostsgen.rb [operate] [args]
# operate: build(0) check(1) clean(2) help(3) version(4)
# args: -q: quiet -o: out -t: tidy -b [module]: no compile for module
class CmdlineOptions
  def initialize(cmdline)
    @mod_black_list = []
    @operate = nil
    @out = nil
    @silent = false
    @no_comments = false
    if cmdline.include? "-q" then @silent = true end
    if cmdline.include? "-t" then @no_comments = true end
    if cmdline.include? "-o" then @out = cmdline[(cmdline.index "-o") + 1] end
    cmdline.each_with_index do |i, s|
      if i.start_with? "-b" then @mod_black_list.push cmdline[s + 1] end
    end
    @operate = case cmdline[0]
      when "build"; 0
      when "check"; 1
      when "clean"; 2
      when "help"; 3
      when "version"; 4
      else 0
    end
  end
  #getter
  def mod_black_list; return @mod_black_list end
  def operate; return @operate end
  def out
    if !@out.nil?;
      if File.directory? @out; puts "[ERR] Cannot use dir as output"; exit 2 end
    end
    return @out
  end
  def silent; return @silent end
  def no_comments; return @no_comments end
end

# hostsgen project config structure
class ProjectConfig
  def initialize(silent)
    require 'yaml'
    if not File.exist? CFG_FILENAME; puts "[ERR] Project config does not exists"; exit 1 end
    cfg = YAML.load_file(CFG_FILENAME)
    if !silent then puts "[VERBOSE] Parsed YAML:",cfg.inspect end
    @name = cfg["name"]
    @desc = cfg["desc"]
    @out = cfg["out"]
    @authors = cfg["authors"]
    @mods = cfg["mods"]
  end
  #getter
  def name; return @name end
  def desc; return @desc end
  def out; return @out end
  def authors; return @authors end
  def mods; return @mods end
end

# project modules structure
class ProjectModules

end

# hostsgen module structure&parser
class HostsModule

end

# generate rule structure
class GenerateRule

end

# hosts file structure
class Hosts

end

# lint hosts data
def lint(hosts)

end

# merge hosts data
def merge(a, b)

end


if $0 == __FILE__ then start(ARGV) end
