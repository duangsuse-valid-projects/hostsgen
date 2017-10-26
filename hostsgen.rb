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
MOD_FILENAME = "mod.txt"
# valid hostname may contain ASCII char A-Z, a-z, 0-9 and '.', '-'.
HOSTNAME_VALID_CHARS = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890-."
LOCATION_VALID_CHARS = "123456790.:"

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
    puts "Usage: ", $0 + " [build/check/clean/help/version] (args)", "args: -q:quiet -o:out [file] -t:no comments -b(an) [mod]"; exit
  end
  if options.operate == 4 then puts VERSION; exit end
  project_cfg = ProjectConfig.new(options.silent)
  if options.operate == 2 then
    begin
      if not options.out.nil? then File.delete options.out end
      if not project_cfg.out.nil? then File.delete project_cfg.out end
      rescue
      # nil.to_s == ''
      if File.exists? options.out.to_s or File.exists? project_cfg.out.to_s then
        puts "[WARN] failed to delete some file"
      end
    end
    if not (File.exists? options.out.to_s or File.exists? project_cfg.out.to_s) then
      puts "[INFO] Cleaned."
    end
    exit 0
  end
  if options.operate == 1 then
    if File.exists? options.out.to_s or File.exists? project_cfg.out.to_s then
      hosts = Hosts.new
      if File.exists? name=options.out.to_s then
        puts "[CHECK] Checking file " + name
        f = File.open name
        hosts.parse(f.read)
        hosts.check
      else
        name = project_cfg.out.to_s
        puts "[CHECK] Checking file " + name
        f = File.open name
        hosts.parse(f.read)
        hosts.check
      end
    else
      puts "[ERR] Cannot find any build artifacts"; exit 4
    end
    exit 0
  end
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
  mods = ProjectModules.new(options.silent, project_cfg.mods, options.mod_black_list)
  print "[COMPILE] Modules: "
  puts mods.mods.to_s
  # if String|nil ...
  if name=options.out then
    mods.build options.silent, options.no_comments, name
  else
    mods.build options.silent, options.no_comments, project_cfg.out
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
      if @out.start_with? '-'; puts "[ERR] Output filename should not start with -"; exit 3 end
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
  def initialize(quiet, mods, ignored)
    @mods = mods
    # strip desc in module config
    mods.each_with_index do |m, i|
     space_idx = m.index ' '
     if space_idx.nil? and not quiet then puts "[WARN] No description in mod " + m
     else @mods[i] = m[0..space_idx - 1] end
    end
    @mods = @mods - ignored
  end
  def build(quiet, no_comments, out)
    if not quiet then
      puts "[COMPILE] Outputting to " + out + (" no comments" if no_comments).to_s
    end
    gen = Hosts.new
    @mods.each_with_index do |m, i|
      puts "[COMPILE] Compiling Module #" + i.to_s + ": " + m if not quiet
      if File.exist? m + '/' + MOD_FILENAME then
        f = File.open m + '/' + MOD_FILENAME
        gen.push HostsModule.new(f.read).compile
      else puts "[ERR] Cannot find module config"; exit 5 end
    end
    puts "[COMPILE] OK, " + gen.logs.length.to_s + " logs generated."
    gen.check
    begin
      (File.new out, 'w').puts gen.to_s
    rescue
      puts "[ERR] Cannot write to file!, check your file permission"
    end
  end
  #getter
  def mods; return @mods end
end

# hostsgen module structure&parser
# contains file names, descriptions, generate rules  
class HostsModule
  def initialize(cfg)
    @files = []
    cfg.lines.each_with_index do |line, i|
      begin
        @files.push FileConfig.new line
      rescue => e
        puts "[COMPILE] Failed to parse mod config at line " + i.to_s
        puts "[ERR] " + e.to_s; exit 8
      end
    end
  end
  def compile()
    ret = []
    for f in @files do
      begin
        ret.push f.compile
      rescue => e
        puts "[COMPILE] Failed to compile file: " + e.to_s; exit 7
      end
    end
    puts if not ARGV.include? '-q'
    return ret
  end
end

# module file
# fields: filename, description, genrule
class FileConfig
  def initialize(line)
    desc = "(none)"
    file_ends = line.index ':'
    if file_ends.nil? then puts "[COMPILE] Cannot find ':' in mod"; exit 6 end
    if file_ends == 0 then raise "invalid filename" end
    @file = line[0..file_ends - 1]
    desc_starts = line.index '('
    desc_ends = line.index ')'
    if desc_starts.nil? then puts "[COMPILE] WARN: Cannot find description start" end
    if desc_starts.nil? then puts "[COMPILE] WARN: Cannot find description end" end
    if not desc_starts.nil? and desc_ends.nil? then raise "[COMPILE] ERR: Endless description (missing ')')" end
    if not (desc_starts.nil? or desc_ends.nil?) then  @desc = line[desc_starts + 1..desc_ends -1] end
    if desc_ends.nil? then
      @genrule = line[file_ends..line.length]
    else
      @genrule = line[desc_ends..line.length]
    end
    begin
      @genrule = GenerateRule.new(@genrule)
    rescue => e
      raise "error initializing genrule: " + e.to_s
    end
  end
  # raise a string contains filename, reason
  def compile()
    print @file + '..' if not ARGV.include? '-q'
  end
end

# generate rule structure
class GenerateRule
  def initialize(line)
  end
  # process a host item using rule
  def process(hostitem)
  end
end

# hosts file structure
# hosts structure is a (array of HostsItem) and HostsComments
class Hosts
  def initialize()
    @logs = []
  end
  # parse a String, store data in self
  def parse(hosts)
    
  end
  # lint hosts data
  def check()
    lint(self)
  end
  # merges self with other
  def push(other)
    merge(self, other)
  end
  def to_s()
    return "Unimplemented!!!"
  end
  #getter
  def logs; return @logs end
end

class HostsItem
  # valid line should not be started with '#'
  def initialize(i, line)
    @line = nil #line number
    @host = nil #hostname
    @loc = nil #address
  end
  #getter
  def line; return @line end
  def host; return @host end
  def locl; return @loc end
end

# comments for hosts data
class HostsComments
  def initialize()
    @text = []
    @at_line = []
  end
  def push(line, comment)
    @text.push comment
    @at_line.push line
  end
  def get_comment(line)
    return @text[@at_line.index line]
  end
end

# lint hosts data
def lint(hosts)

end

# merge hosts data
def merge(a, b)

end


if $0 == __FILE__ then start(ARGV) end
