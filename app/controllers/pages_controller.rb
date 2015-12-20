require 'zip'
require 'open-uri'
class PagesController < ApplicationController
	 before_action :authenticate_user!, only: [:dashboard]
  def home
  	if current_user
  		redirect_to books_path
  	end
  	@books = Book.last(4)
  end
  def dashboard
  	@books = current_user.books
  end
  def perform
  	book = Book.find_by(:slug => params[:detail])
  	puts book.resource.url
  	puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  	
	download = open(book.resource.url)
	IO.copy_stream(download, "#{Rails.root.join('tmp')}/new.zip")
  	
  	@zip_filenames = Zip::File.open("#{Rails.root.join('tmp')}/new.zip") do |zip_file|
  		zip_file.map { |entry| entry.name } 
  	end
  	puts @zip_filenames
  end
end
