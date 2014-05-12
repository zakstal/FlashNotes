require 'sqlite3'
require './data'
require './data_mover'
require './data_note_taker'
require './data_fc'
require 'pp'
include DBDoer
include ProjectTools

#module Main_tools
	def main_screen
		main_choices = {'heading' 		=>'Main',
						'project tools'	=> 'pt',
						'take notes'	=>'take',
						'flash cards'	=> 'fc',
						}
		ProjectTools::choice_screen(main_choices,2)
	end
	
#end
main_screen