require 'yaml'
require 'pp'

zoo_dir = ARGV[0]
board = ARGV[1]

Dir[zoo_dir + '/model-list/*/model.yaml'].each do |f|
  model = YAML.load(File.read(f))
  model['files'].select { |x| x['board'] == board }.each do |file|
    puts file['download link']
  end
end
