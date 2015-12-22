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
  	zip_file_download_path = "#{Rails.root.join('tmp')}/new.zip"
  	@zip_file_uncompressed_path = "#{Rails.root.join('tmp')}/books_folder"
	 download = open(book.resource.url)
	 IO.copy_stream(download, zip_file_download_path)
  	@pdf_files = []
    @video_files = []
  	Zip::File.open(zip_file_download_path) do |zip_file|
  		zip_file.each do |file|
    		zip_file.extract(file, "#{@zip_file_uncompressed_path}/#{file.name}") unless File.exists?("#{@zip_file_uncompressed_path}/#{file.name}")
			 if file.name.include? ".pdf"
				  @pdf_files << file.name
			 end
       if file.name.include? ".mp4"
        @video_files << file.name
       end
		  end
    end
  end
  
  def view_video

    @content_path = params[:content]
    send_file ("#{@content_path}.mp4"), :type => 'video/mp4',:disposition => :inline, :stream => true 

  end

  def view_pdf

    @content_path = params[:content]
    send_file ("#{@content_path}.pdf"), :type => 'application/pdf',:disposition => :inline, :stream => true 

  end

end
