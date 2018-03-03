require 'net/http'

module Myself
  def self.ip
    "192.168.4.67:3000"
  end
  def self.listening_url(entity_id)
    base= "http://#{ip}/listener"
    [base, entity_id].join('/')
  end
end
module Fiware
  def self.ip(public=false)
    public ? "84.89.60.4" : "192.168.4.230"
  end
  def self.url(path='')
    public= false
    base= "http://#{ip(public)}"
    [base, path].join('/')
  end
end
namespace :fiware do

  # bin/rails fiware:subscribe[computer,computer,search]
  # bin/rails fiware:subscribe[computer,computer,play]
  #
  task :subscribe do |task, args|
    entity_name, type, params= args.to_a
    puts "entity_name, type, params= #{[entity_name, type, params]}"
    subscribe(entity_name, type, (params || entity_name))
    # subscribe('bressol', 'bebe', 'bressol')
    # subscribe('rolf', 'rolf', 'state')
  end

  namespace :entity do
    # bin/rails fiware:entity:register[computer,search--play]
    task :register do |task, args|
      entity, attributes= args.to_a
      attributes= attributes.split('--')
      register(entity, attributes)
    end
    # bin/rails fiware:entity:delete[computer]
    task :delete do |task, args|
      entity= args.to_a[0]
      uri = URI(Fiware.url("v2/entities/#{entity}"))
      Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Delete.new uri
        response = http.request request # Net::HTTPResponse object
        puts "RS: success? #{response.is_a?(Net::HTTPSuccess)}"
        p response.body
      end
    end
  end

  task :list_subscriptions do
    rs= Net::HTTP.get(Fiware.ip, '/v2/subscriptions')
    json= JSON.parse rs
    #    puts "RS: #{json}"
    json.each do |item|
      #      puts "id: #{item['id']}"
      #      puts item
      #      puts "http: #{item['notification']['http']['url']}"
      if item['notification']['http']['url'].include?(Myself.ip)
        puts "MINE: #{item['id']}"
        puts "subject: #{item['subject']}"
      end
    end
  end
end

def register(entity_id, attributes)
  body= {
    "id" => entity_id,"type"=> entity_id,
    "description"=> {"value"=> "One of my computer services...","type"=> "String"},
  }
  attributes.collect { |attr|
    body[attr]= {"value"=> "","type"=> "String"}
  }
  url = Fiware.url('v2/entities')
  post(url, body)
end

def subscribe(entity_name, type, params)
  body= {
    description: "A subscription to get info about #{entity_name}",
    subject: {
      entities: [
        {
          id: entity_name,
          type: type,
        }
      ],
      condition: {attrs: Array.wrap(params)}
    },
    notification: {
      http: {url: Myself.listening_url(entity_name),},
      attrs: Array.wrap(params)
    },
    expires: "2040-01-01T14:00:00.00Z",
    throttling: 5
  }

  url = Fiware.url('v2/subscriptions')
  post(url, body)
end

def post(url, body)
  puts "Subscriving to: #{url}"
  puts "with POST with body: #{body.to_json}"

  uri= URI(url)
  req= Net::HTTP::Post.new(uri)
  req.body= body.to_json
  req.content_type= 'application/json'
  rs= Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  puts "RS: success? #{rs.is_a?(Net::HTTPSuccess)}"
  p rs.body
end