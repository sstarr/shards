require "./package"

module Shards
  class Manager
    getter :spec, :packages, :locks

    def initialize(@spec, update_cache = true)
      @packages = Set.new(update_cache: update_cache)
    end

    def resolve
      resolve(spec.dependencies)
      resolve(spec.development_dependencies) unless Shards.production?
    #rescue ex : Conflict
    #  Shards.logger.error ex.message
    #  exit -1
    end

    # TODO: handle conflicts
    def resolve(dependencies)
      dependencies.each do |dependency|
        package = packages.add(dependency)
        resolve(package.spec.dependencies)
      end
    end

    def to_lock(io : IO)
      io << "version: 1.0\n"
      io << "shards:\n"

      packages
        .sort { |a, b| a.name <=> b.name }
        .each do |package|
          io << "  " << package.name << ":\n"
          package.to_lock(io)
          io << "\n"
        end
    end
  end
end
