require 'slack'
require 'mysql2'
require 'yaml'

setting = YAML.load_file("settings.yml")

context = Mysql2::Client.new(:host => "localhost", :username => "root", :password => setting["password"], :database => "slack", encoding: 'utf8')
TOKEN = setting["token"]

BOTNAME = "task-manager"
IMAGEURL = 'http://i15.photobucket.com/albums/a383/SeanyBoyo/Celebrities/Audrey%20Hepburn/1893337_029.png'
Slack.configure {|config| config.token = TOKEN }

client = Slack.realtime

client.on :hello do
 # puts 'Successfully connected.'
end

client.on :message do |data|
  if data.key?('text')
        if  data['text'].include?('残作業') && data['user'] != nil
                place = data['text'].index('残作業') + 7
                target = data['text'][place..data['text'].length]
                query = ("insert into remaining_tasks (user_id,task_text) values ('#{data['user']}','#{target}')")
                results = context.query(query)
                p "add column #{target}"
        end

        if data['text'] == "@maid-bot task"
                query = ("select * from remaining_tasks where user_id = '#{data['user']}' order by id desc limit 1")
                results = context.query(query)
                puts query
                results.each do |row|
                        puts row['user_id']
                        puts row['task_text']
                        params = createParam(row['task_text'])
                end
                Slack.chat_postMessage params
        end
  end
end

def createParam(message)
    params = {
        channel: data['channel'],
        username: BOTNAME ,
        text:  message
        icon_url: IMAGEURL
    }
    return params
end

client.start
Process.daemon
