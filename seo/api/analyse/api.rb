#encoding: utf-8
$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__)) 
require "link_analyse"

module Seo
	module Api
		module Analyse
			class Api
				URL = "http://www.webcircletech.com"
				def initialize
		      Seo::Api::Analyse::LinkAnalyse.new(URL)
				end

			end
		end
	end
end


testing = Seo::Api::Analyse::Api.new