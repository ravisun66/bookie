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
  	zip_file_download_path = "#{Rails.root.join('tmp')}/#{params[:detail]}.zip"
  	@zip_file_uncompressed_path = "#{Rails.root.join('tmp')}/#{params[:detail]}"
    
    if !(File.file?(zip_file_download_path))
	     download = open(book.resource.url)
	     IO.copy_stream(download, zip_file_download_path)
       
    end

  	@pdf_files = []
    @video_files = []
  	
    if File.directory?(@zip_file_uncompressed_path)

      Dir.foreach(@zip_file_uncompressed_path) do |f_name|
        if File.directory?("#{@zip_file_uncompressed_path}/#{f_name}") && !(f_name.include? ".")
          
          Dir.foreach("#{@zip_file_uncompressed_path}/#{f_name}") do |file_name|
            if file_name.length > 2
              
                if file_name.include? ".pdf"
                  @pdf_files << "#{f_name}/#{file_name}"
                end
                if file_name.include? ".mp4"
                  @video_files << "#{f_name}/#{file_name}"
                end

          end
          end

        end
        
       
      end
    
    else  

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

    if !File.directory?("#{Rails.public_path}/videos/media/#{params[:detail]}")
    FileUtils.mkdir_p("#{Rails.public_path}/videos/media")
    FileUtils.cp_r "#{@zip_file_uncompressed_path}", "#{Rails.public_path}/videos/media/#{params[:detail]}"
    end
     @file_path = "media#{@zip_file_uncompressed_path.split("tmp").last}"
 
  end
  

  def view_video

    @content_path = params[:content]

  end

  def view_pdf

    @content_path = params[:content]
    #send_file ("#{@content_path}.pdf"), :type => 'application/pdf',:disposition => :inline, :stream => true 

  end

end
