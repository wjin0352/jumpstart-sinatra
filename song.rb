require 'dm-core'
require 'dm-migrations'

# part2 - defining my models with datamapper
# Serial type (auto incrementing int)automatically gives a unique key and 
# generates unique id for each row in db

class Song
	# include is similar to require, different in that when we say include 
	# datamapper is a class and::resource is a module in that class
	# include takes all the functions or methods that are inside resource module 
	# and makes them class methods inside the user class.  so we can use those methods

	# property method takes : name of field, type
	# this is datamapper short hand for unique primary key for the database

	include DataMapper::Resource
	property :id, Serial
	property :title, String
	property :lyrics, Text
	property :length, Integer
	property :released_on, Date 

	def released_on=date
    super Date.strptime(date, '%m/%d/%Y')
	end

 end

# configure :development do
# DataMapper.setup(:default, 'postgres://localhost/sinatraapp1') 
# # DataMapper.finalize.auto_upgrade!
#  end


configure do
	enable :sessions
	set :username, 'frank'
	set :password, 'sinatra'
end

# how do we get datamapper to create this database??
# 2 methods to do this --> DataMapper.auto_upgrade!   
# and DataMapper.auto_migrate!
# auto_migrate! will create a brand new database, even if making a small change
# it will clear all data out of database there and reinitialize the db in its initial state
# auto_upgrade! will try and make any changes to the model. 

DataMapper.finalize
# tells DataMapper to update the database with the tables and
# fields that we will eventually create in our models, 
# and then automatically update it if we change anything
# http://datamapper.org/getting-started.html

module SongHelpers
	# fetches all songs
	def find_songs
		@songs = Song.all  
	end
	# finds particular song in db using :id
	def find_song
		Song.get(params[:id])
	end
	# instantiates new Song object using attributes in params[:song] hash
	def create_song
		@song = Song.create(params[:song])
	end
end
# register these methods as helper methods
helpers SongHelpers


get '/songs' do
	# @songs = Song.all
	find_songs
	slim :songs
end

get '/songs/new' do
	protected!
	@song = Song.new
	slim :new_song
end


get '/songs/:id' do
  # @song = Song.get(params[:id])
  @song = find_song
  slim :show_song
end

get '/songs/:id/edit' do
	protected!
	# @song = Song.get(params[:id])
	@song = find_song
	slim :edit_song
end

post '/songs' do
	protected!
	if create_song
		flash[:notice] = "Great job, song successfuly added!" 
		end
	redirect to("/songs/#{@song.id}")
	# song = Song.create(params[:song])
	# create_song
end

put '/songs/:id' do
	# song = Song.get(params[:id])
	protected!
	song = find_song
	if song.update(params[:song])
		flash[:notice] = "Song successfully updated"
	end
	redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
	protected!
	# Song.get(params[:id]).destroy
	if find_song.destroy
		flash[:notice] = "Song deleted"
	end
	redirect to('/songs')
end



 

















