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

# main function
def start(args)
    puts "Hello"
end

# commandline arguments structure&parser
class CmdlineOptions

end

# hostsgen project config structure
class ProjectConfig

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
