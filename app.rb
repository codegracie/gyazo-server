# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra/base'
require 'erb'
require 'digest/sha1'

module Gyazo
  class App < Sinatra::Base
    configure do
      set :gyazo_id, '*** gyazo id ***'
      set :image_hash_length, 8
      set :image_url, '*** image url ***'
      set :inline_templates, true
    end

    def hash_from_data(data)
      Digest::SHA1.hexdigest(data)[0...settings.image_hash_length]
    end

    def set_data(data)
      name = hash_from_data(data)
      path = "#{settings.public_folder}/#{name}.png"
      File.open(path, 'w').print(data)
      url = "#{settings.image_url}/#{name}.png"
    end

    get '/' do
      @images = Dir["#{settings.public_folder}/**.png"].sort_by {|f|
        - File.mtime(f).to_i
      }.map {|i|
        "#{settings.image_url}/#{File.basename(i)}"
      }
      erb :index
    end

    post '/upload' do
      raise unless settings.gyazo_id == params['id']
      data = params['imagedata'][:tempfile].read
      set_data(data)
    end
  end
end

__END__
@@layout
<!DOCTYPE html>
<html>
  <head>
  <meta charset="utf-8" />
  <title>Gyazo</title>
  <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js' type='text/javascript'></script>
  <script src='jquery.MyThumbnail.js' type='text/javascript'></script>
  <script type="text/javascript">
    $(document).ready(function() {
      $('img').MyThumbnail({thumbWidth: 200, thumbHeight: 200, backgroundColor: '#fff', imageDivClass: 'pic'});
    });
  </script>
  <style type="text/css">
    .pic {margin:10px; border-radius:10px; border:1px solid #fff;}
  </style>
</head>
<body>
  <h1>スクリーンショットの瞬間共有</h1>
  <%= yield %>
</body>
</html>

@@index
<% @images.each do |i| %>
<a href="<%= i %>" target="_blank">
  <img src="<%= i %>"/>
</a>
<% end %>
