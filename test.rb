class Computer
	def initialize()
	# 	@id = camputer_id
	# 	@data_source = data_source
		Computer.define_component :cpu
	end

	def self.define_component(name)
		p name
		define_method(name) {
			result = "name: #{name}"
			p 111
			result
		}
	end
end

# Computer.define_component :cpu
Computer.new.cpu