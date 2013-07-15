# Copyright 2012-2013 Crowd Favorite, Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'capistrano'
require 'crowdfavorite/support/capistrano_extensions'

# This module is used to capture the definition of capistrano tasks, which makes it
# easier to test the behaviour of specific tasks without loading everything. If you
# are writing tests for a collection of tasks, you should put those tasks in a module
# and extend that module with `CrowdFavorite::Support::Namespace.
#
# You can look at some of the existing tasks (such as [env](../tasks/env.html)) and
# its corresponding specs for an example of this in practice.
#
# You should not need to use this module directly when using recap to deploy.

module CrowdFavorite::Support::Namespace
  def self.default_config
    @default_config
  end

  def self.default_config=(config)
    @default_config = config
  end

  if Capistrano::Configuration.instance
    self.default_config = Capistrano::Configuration.instance(:must_exist)
  end

  def capistrano_definitions
    @capistrano_definitions ||= []
  end

  def namespace(name, &block)
    capistrano_definitions << Proc.new do
      namespace name do
        instance_eval(&block)
      end
    end

    load_into(CrowdFavorite::Support::Namespace.default_config) if CrowdFavorite::Support::Namespace.default_config
  end

  def load_into(configuration)
    configuration.extend(self)
    capistrano_definitions.each do |definition|
      configuration.load(&definition)
    end
  end
end
