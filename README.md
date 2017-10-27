# hostsgen Hosts项目管理工具 ![version](https://img.shields.io/badge/version-0.1.1-green.svg?style=flat-square) ![LoC](https://img.shields.io/badge/LoC-337_lines_of_Ruby-e0115f.svg?style=flat-square) ![resloving](https://img.shields.io/badge/resloving-refactor-blue.svg?style=flat-square)
📝  Simple&amp;powerful hosts file generator for hosts projects

## ❓ What can this tool do? 它能做什么?
__hostsgen__ is designed to make _hosts_ projects modular🗄 and writting-friendly✍️

## ⭐️ Start using `hostsgen` 开始使用
### Create hostsgen.yml 创建项目配置文件
`hostsgen.yml` is __project config file for hostsgen.__ Hostsgen uses this file to know what your project is

available fields:
+ __name__ (_String,_ your project name)
+ __desc__ (_String,_ description)
+ __authors__ (_String|[String],_ project authors)
+ __out__ (_String,_ output file path)

+ __mods__ (_[String],_ your project root modules)

for example:
```yaml
name: project name
desc: example hostgen project config
authors: duangsuse
out: example_hosts

mods:
  - foo-mod desc #splited using ' '
  - ads-baidu AD Block for Baidu
  - google google hosts
```

### Configure your module 配置模块
Create `module dirs` in `project root`. There must be a __"mod.txt"__ in module dir, which contains module settings.
For configure above, module dir __foo-mod__, __ads-baidu__ and __google__ should be created.
mod.txt syntax:
```yaml
#{filename} {rule}
foo.txt: (I am description) 12.13.{IP} {HOST}.xm.com
main.txt: (ad block for baidu ads) 0.0.0.0 {HOST}
```
Each _hosts entry_ will be processed using `rule`
If only {IP} or {HOST} persent, whole line will be placed in the field.

## License 许可证
Copyright 2017 duangsuse

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an __"AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,__ either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
