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
  	zip_file_download_path = "#{Rails.root.join('tmp')}/new.zip"
  	zip_file_uncompressed_path = "#{Rails.root.join('tmp')}/books_folder"
	download = open(book.resource.url)
	IO.copy_stream(download, zip_file_download_path)
  	
  	@zip_filenames = Zip::File.open(zip_file_download_path) do |zip_file|
  		
  		zip_file.each do |file|
    		zip_file.extract(file, "#{zip_file_uncompressed_path}/#{file.name}") unless File.exists?("#{zip_file_uncompressed_path}/#{file.name}")
		end
  		zip_file.map { |entry| entry.name } 
  		
  	end
  	puts @zip_filenames
  end
end
