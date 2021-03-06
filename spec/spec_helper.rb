################################################################################
#
#      Author: Zachary Patten <zachary AT jovelabs DOT com>
#   Copyright: Copyright (c) Zachary Patten
#     License: Apache License, Version 2.0
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
#
################################################################################
require 'coveralls'
Coveralls.wear!
################################################################################
require 'lxc'

LXC_VERSIONS = %w(0.7.5 0.8.0-rc2)

def lxc_fixture(version, filename)
  filepath = File.expand_path(File.join(File.dirname(__FILE__), "support", "fixtures", version, filename))
  IO.read(filepath)
end
