# require 'sinatra/reloader'  #only relaods this main.rb by default, not others 
require 'sinatra'
require 'pg'
require 'pry'

def run_sql(sql)
  conn = PG.connect(dbname: 'goodfoodhunting')
  result = conn.exec(sql)
  conn.close
  return result
end

require_relative 'db_config'
require_relative 'models/dish'
require_relative 'models/comment'
require_relative 'models/user'
require_relative 'models/like'

# sessions is a Sinatra method
enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user_id])
  end
  # if theres a current user, then return true, otherwise if not, return false
  def logged_in? 
    # !!current_user either returning true or false without if statement
    if current_user #forcing current_user user object: true, or nil: false
      true
    else
      false
    end
  end

end


get '/' do
  # dbname is a hash we are passing into the PG method
  @dishes = Dish.all
  erb :index
end

#getting the form
get '/dishes/new' do
  erb :new
end

# showing single dish by id
get '/dishes/:id' do #when the url matches this pattern then:
  # :is a wildcard, and will respond to anything typed into the url
  # selecting one dish, and in dish details 
 

  @dish = Dish.find( params[:id] )
  @comments = @dish.comments

  erb :dish_details #displaying these instructions on the dish_details erb
end

#creating a dish
post '/dishes' do
  dish = Dish.new
  dish.name = params[:name]
  dish.image_url = params[:image_url]
  dish.user_id = current_user.id
  dish.save

  redirect '/' #needs to be a route - because it is making a request
  
end

#deleting a dish
delete '/dishes/:id' do
  dish = Dish.find( params[:id] )
  dish.destory
  
  redirect '/'
end

get '/dishes/:id/edit' do
 
  @dish = Dish.find(params[:id])
  erb :edit
end

put '/dishes/:id' do

  dish = Dish.find(params[:id])
  dish.name = params[:name]
  dish.image_url = params[:image_url]
  dish.save

  redirect "/dishes/#{ params[:id] }"
end

post '/comments' do
  redirect '/login' unless logged_in? #single line if statement

  comment = Comment.new
  comment.content = params[:content]
  comment.dish_id = params[:dish_id]
  comment.user_id = current_user.id
  comment.save
  redirect "/dishes/#{ params[:dish_id] }"
end

# getting login form for existing users. making a session
get '/login' do
  erb :login

end

post '/session' do
  # grab email and password
  # find the user by email
  user = User.find_by(email: params[:email])
  # authenticate user with password
  if user && user.authenticate(params[:password])
    #showing who is logged in
    session[:user_id] = user.id
    redirect '/'
    # create new session
    # redirect to secret page
  else
    erb :login
  end
end

delete '/session' do
  # end the session
  session[:user_id] = nil    # redirect to login becuase we are doing a destructive operation. want to direct to a safe page, a get page
  redirect '/login'
end

#recording likes on a dish
post '/likes' do

redirect '/login' unless logged_in?
#unless logged in, cant like and are redirected to login page

  # creating a like into the likes table
  like = Like.new
  like.dish_id = params[:dish_id]
  like.user_id = current_user.id #already logged in, so obvs current user. 
  like.save
  redirect "dishes/#{params[:dish_id]}"
end



