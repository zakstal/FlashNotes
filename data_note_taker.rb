require 'sqlite3'
require './data'
require './data_mover'
require './data_fc'
require 'pp'
include DBDoer
include ProjectTools

def take_notes_screen
	take_notes_chocies = { 'heading' 											=> 'Take Notes',
							'start a new project notes'							=> 'new',
							'start taking notes from existing project'			=> 'e',
							'view notes from a project or catagorie ' 			=> 'view',
							'view instructions and hints'						=> 'in',
							}
	ProjectTools::choice_screen(take_notes_chocies,3)
end

class MakeNote

	attr_accessor :note_project, :note_cat, :note_page_num, :note_note

	def initialize(*args)
		@note_project, @note_cat, @note_page_num = args.flatten
		@note_note = ""
	end

	def to_array
		args = [@note_project,  @note_cat, @note_page_num]
		args
	end

	def save_to_db
		arr = to_array << @note_note
		puts "in save_to_db"
		DBDoer::insert("notes", arr)
	end

	def alter_note(inpute)
		
		change_to = inpute[4..inpute.length]
		option = inpute[0..3]
		puts "in alter"
		p option
		case option
			when 'poj:'
				change_to = database_all_column_questions('notes', 2,3,4)*'' if inpute[0..4] == 'poj:l' 
				@note_project = change_to
			when 'cat:'
				change_to =database_all_column_questions('notes', 1,3,4)*'' if inpute[0..4] == 'cat:l'
				@note_cat = change_to
			when 'pag:'
				@note_page_num = change_to
			else
				add_to_note(inpute)
		end
	end

	def add_to_note(inpute)

		@note_note  << "\n" << inpute
	end
end

def take_notes_setup
	all = database_all_column_questions('notes','projecs_id', 4).flatten
	all
	#need to figureout how to break if it asks for a note

end


def get_note(note_object)
	note = ""
	keep_going = ''
	while keep_going != 'n'
		notes_interface(note_object)
		inpute = make_choice(4)
		keep_going = 'n' if inpute == 'n' || inpute == 'ex'
		break if inpute == 'n'
		note_object.alter_note(inpute) 
	end
	keep_going = 'ex' if inpute == 'ex'
	keep_going
end


def optoins_notes
	puts "|optoins >>| n | poj: | cat: | pag: | main | proj | note | ex |"
end




def notes_interface(note_object)
	ans = note_object.to_array
	#needs to take answers and serarch to find project names and cats and input those in their place
	space = "                 "
	col =["project", "catagorie", "page number"]
	ProjectTools::space(17)
	optoins_notes
	ProjectTools::space(2)
	puts ProjectTools::each_column(col,space)
	puts "  ------------------------------------------------------------\n"
	puts ProjectTools::each_column(ans,space)
	ProjectTools::space(4)
	puts note_object.note_note
end
def run_note_sequence(note_object)
	next_action = get_note(note_object)
	note_object.save_to_db
	if next_action == 'n'
		note_object.note_note = ''
		run_note_sequence(note_object)
	elsif next_action == 'ex'
	end
end
def the_whole_shbang
	ans = take_notes_setup
	new_note = MakeNote.new(ans)
	run_note_sequence(new_note)
	take_notes_screen
end


def instructions
	
	puts "starting:
to start taking notes, on the note taking screen type 'new'. 
the program will ask for the  project Id or give you the 
optoin to look at a list of optoins.

the sequence will continue for the catagorie and will end 
by asking you for a note name or page number.

taking notes:
when all the informatino has been entered the screen will 
show a list of options and display the project catagorie 
and note name or page number.

you can start taking notes using enter to start a new line 
and. to make a new note type 'n' and then enter. this will 
retain the project, catagorie, and note name. 

changing note info:
at anytime while taking a note the project, catagorie or 
note name can be changed.

to change the project type 'poj:' and then the new project Id,
or type 'poj:l' to get a list to choose from

to change the catagore type 'cat:' and then the new catagorie 
Id, or type 'cat:l' to get a list to choose from

to change the name or page number type 'pag:' and the new 
informatino

navigating out:
at anytime while taking a note the main screen, project 
tools or the note tools can be accessed by typing respectivly, 
main, proj, note. to exit the note taking type 'ex'"
gets
take_notes_screen

end