##
# This script organizes an iTunes library into artist/album folders, based on the iTunes music library file
# WARNING: run with care, has only been tested on my own library
##

require "rubygems"
require "hpricot"
require "FileUtils"
require "CGI"
require "yaml"

# Grab the path to the music library
raise "LIBRARY_PATH env variable not set!" if ENV.nil? || ENV["LIBRARY_PATH"].nil?
LIBRARY = ENV["LIBRARY_PATH"]

# Grab the output path for the organized library
raise "ORGANIZED_OUTPUT env variable not set!" if ENV.nil? || ENV["ORGANIZED_OUTPUT"].nil?
OUTPUT = ENV["ORGANIZED_OUTPUT"]
Dir.mkdir(OUTPUT) unless File.exist?(OUTPUT)

# This is used to filter bad characters out that might screw up file names
def filter_bad_characters(s)
  s.gsub("/", "-")
end

# Lets create the metadata if it doesn't already exist
metadata_path = File.join(OUTPUT, "metadata.yml")
unless File.exist?(metadata_path)
  puts "LOADING iTunes music library"
  # Open it up and find the root node
  doc = Hpricot(open(LIBRARY))
  root = (doc/"dict")
  # Locate the track elements
  tracks = ((root/"dict")/"dict")
  # Setup a variable for metadata
  metadata = {}
  # Loop through all tracks
  tracks.each do |track|
    # Grab attributes for the track
    attributes = {}
    elements = track.children.select { |c| c.class == Hpricot::Elem }
    elements.each_with_index do |element, index|
      attributes[element.innerText] = elements[index + 1].innerText if element.name == "key" && elements[index + 1]
    end
  
    # Process the attributes
    metadata[attributes["Artist"]] ||= {}
    metadata[attributes["Artist"]][attributes["Album"]] ||= {}
    metadata[attributes["Artist"]][attributes["Album"]][attributes["Name"]] = attributes["Location"]
  end
  puts "GENERATED iTunes music library metadata in-memory"
  
  # Write the metadata to file
  metadata_file = File.open(metadata_path, "w")
  metadata_file.write metadata.to_yaml
  metadata_file.flush
  metadata_file.close
  metadata_file = nil
  puts "WRITTEN iTunes music library metadata to file (#{metadata_path})"
end

# Read the metadata now we know it exists
metadata = YAML::load(File.read(metadata_path))

errors = []
puts "LOOPING through iTunes music, copying and organizing"
# Loop through artists
artists = metadata.keys
artists.each_with_index do |artist, index|
  next if artist.nil?
  puts "PROCESSING artist #{artist} (#{index + 1} of #{artists.length})"
  # Create the artist folder if it doesn't already exist
  artist_path = File.join(OUTPUT, filter_bad_characters(artist))
  # Loop through albums
  albums = metadata[artist].keys
  albums.each_with_index do |album, index|
    next if album.nil?
    puts "PROCESSING album #{album} (#{index + 1} of #{albums.length})"
    album_path = File.join(artist_path, filter_bad_characters(album))
    # Loop through tracks
    tracks = metadata[artist][album].keys
    tracks.each_with_index do |track, index|
      next if track.nil?
      puts "PROCESSING track #{track} (#{index + 1} of #{tracks.length})"
      if metadata[artist][album][track].nil?
        errors << "#{artist} - #{album} - #{track} - no track found!"
      else
        target = CGI.unescape(metadata[artist][album][track].gsub("file://localhost", ""))
        track_path = File.join(album_path, "#{filter_bad_characters(track)}#{File.extname(target)}")
        # Create the directory
        FileUtils.mkdir_p File.dirname(track_path) unless File.exist?(File.dirname(track_path))
        # Copy the file
        already_retried = false
        begin
          unless File.exist?(track_path)
            puts "COPYING track #{track} (from #{target} to #{track_path})"
            FileUtils.copy(target, track_path)
          end
        rescue
          puts "ERROR COPYING"
          if already_retried
            raise
          else
            already_retried = true
            track_path = File.join(album_path, File.basename(target))
            retry
          end
        end
      end
    end
  end
end

# Output errors, if we have any
unless errors.empty?
  puts "ERROR found #{errors.length} errors"
  errors.each do |error|
    puts error
  end
end