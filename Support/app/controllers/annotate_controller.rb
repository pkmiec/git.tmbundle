# encoding: utf-8

require LIB_ROOT + '/show_in_github.rb'

class AnnotateController < ApplicationController
  include DateHelpers
  include AnnotateHelper
  include DiffHelper
  
  layout "application", :except => "update"
  def index
    @file_path = params[:file_path] || ENV['TM_FILEPATH']
    @annotations = git.annotate(@file_path)

    if @annotations.nil?
      puts "Error.  Aborting"
      abort
    end

    @log_entries = git.log(:path => @file_path, :follow => true, :name => true)
    render "index"
  end
  
  def update
    file_path = params[:filepath] || ENV['TM_FILEPATH']
    revision = params[:revision]

    @annotations = git.annotate(file_path, revision)

    if @annotations.nil?
      puts "Error.  Aborting"
      abort
    end
    
      # f = Formatters::Annotate.new(:selected_revision => revision, :as_partial => true)
      # f.header "Annotations for ‘#{htmlize(shorten(file_path))}’"
      # f.content annotations
     render "_content", :locals => { :annotations => @annotations, :revision => revision } 
     render "_select_revision", :locals => { :revision => revision}
  end
  
  def open_file
    show_in_github = ShowInGithub.new
    url = show_in_github.url_for(params[:file_path], params[:revision], nil)
    puts `open "#{url}"`
  end
end