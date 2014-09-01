class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @ratings_checked = {}
    @all_ratings = Movie.uniq.pluck(:rating)
    order = params[:order] 
    
    should_redirect = false
    if not order 
      order = session[:order]
      should_redirect = true
    end
    if not params[:ratings]
      if session[:ratings]
        ratings = session[:ratings]
        should_redirect = true
      end
    else
      ratings = params[:ratings]
    end
    if should_redirect
      
      flash.keep
      redirect_to movies_path(:order => order, :ratings => ratings) 
    end
    
    if not params[:ratings]
      ratings = @all_ratings
      @all_ratings.each do |rating|
        @ratings_checked[rating] = 1
      end
    else
      ratings = params[:ratings].keys
      @ratings_checked = params[:ratings]
    end

    
    if order == 'title'
      @movies = Movie.order(:title).find_all_by_rating(ratings)
      @title_class = 'hilite'
    elsif order == 'release_date'
      @movies = Movie.order(:release_date).find_all_by_rating(ratings)
      @release_date_class = 'hilite'
    else
      @movies = Movie.find_all_by_rating(ratings)
    end
    session[:order] = order
    session[:ratings] = params[:ratings]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
