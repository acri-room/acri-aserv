require 'yaml'
require 'pp'

board = ARGV[0]

Dir['/opt/vitis_ai/workspace/models/AI-Model-Zoo/model-list/*/model.yaml'].each do |f|
  model = YAML.load(File.read(f))
  model['files'].select { |x| x['board'] == board }.each do |file|
    puts file['download link']
  end
end
