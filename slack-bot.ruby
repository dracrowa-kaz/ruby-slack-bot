require 'slack'
require 'mysql2'

context = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "password", :database => "slack", encoding: 'utf8')

TOKEN = ''
Slack.configure {|config| config.token = TOKEN }
client = Slack.realtime

client.on :hello do
  puts 'Successfully connected.'
end

client.on :message do |data|
  if data.key?('text')
        if  data['text'].include?('残作業') && data['user'] != nil
                puts data['user']
                place = data['text'].index('残作業') - 1
                target = data['text'][place..data['text'].length]
                puts data['user']
                puts target
                params = {
                        channel: data['channel'],
                        username: "task-manager",
                        text:  "<@#{data['user']}> your task was memorized"
                }
                #Slack.chat_postMessage params
                query = ("insert into remaining_tasks (user_id,task_text) values ('#{data['user']}','#{target}')")
                results = context.query(query)
                query = ("select * from remaining_tasks where user_id = '#{data['user']}' order by id desc limit 1")
                results = context.query(query)
                puts query
                results.each do |row|
                        puts row['user_id']
                        puts row['task_text']
                end
        end
        if data['text'] == "tell my task"
                query = ("select * from remaining_tasks where user_id = '#{data['user']}' order by id desc limit 1")
                results = context.query(query)
                puts query
                results.each do |row|
                        puts row['user_id']
                        puts row['task_text']

                params = {
                        channel: data['channel'],
                        username: "task-manager" ,
                        text:  "<@#{data['user']}>#{row['task_text']} "
                }

                end
                Slack.chat_postMessage params
        end
  end
end

client.start
