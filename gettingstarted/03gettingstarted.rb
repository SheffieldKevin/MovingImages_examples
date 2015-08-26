#!/usr/bin/env ruby
require 'moving_images'

include MovingImages
include MIMovie
include CommandModule

module GettingStarted

  def self.import_movie(moviefile)
    importerName = SecureRandom.uuid
    importer = SmigIDHash.make_objectid(objectname: importerName,
                                        objecttype: :movieimporter)
    importMovieCommand = CommandModule.make_createmovieimporter(moviefile,
                                        name: importerName)
    puts JSON.pretty_generate(importMovieCommand.commandhash)
    Smig.perform_command(importMovieCommand)
    importer
  end

  def self.prettyprint_movieimporter_videotrack_properties(movieImporter)
    track = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                                mediatype: :vide,
                                               trackindex: 0)
    
    getPropertiesCommand = CommandModule.make_get_objectproperties(movieImporter,
                                      saveresultstype: :jsonstring)
    getPropertiesCommand.add_option(key: :track, value: track)
    puts JSON.pretty_generate(getPropertiesCommand.commandhash)
    jsonText = Smig.perform_command(getPropertiesCommand)
    jsonHash = JSON.parse(jsonText)
    puts JSON.pretty_generate(jsonHash)
  end

  def self.run()
    movieFile = File.expand_path("~/Desktop/Current/tempmovies/OutputGarden.mov")
    movieImporter = self.import_movie(movieFile)
    self.prettyprint_movieimporter_videotrack_properties(movieImporter)
    sleep 2
    # Smig.close_object_nothrow(theWindow)
    Smig.closeall_nothrow()
  end
end

GettingStarted.run
