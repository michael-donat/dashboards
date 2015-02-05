require 'net/https'
require 'json'
require 'yaml'

cnf = YAML::load_file(File.join(__dir__, '../../', 'dashing.conf.yml'))['bamboo']

#--------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------
configuration = {
    :bamboo_uri => cnf['url'],
    :credentials => {
        :username => cnf['user'],
        :password => cnf['password']
    },
    :refresh_rate => '10s',
    :plan_keys => cnf['plans']
}
#--------------------------------------------------------------------------------

class BambooBuild
  def initialize(base_uri, credentials)
    @base_uri = base_uri
    @credentials = credentials
  end
  
  def plan_status(plan_key)
    begin
      uri = URI.parse(@base_uri)
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      request = Net::HTTP::Get.new(result_endpoint(plan_key))
      if @credentials && @credentials[:username].length > 0
        request.basic_auth @credentials[:username], @credentials[:password]
      end

      response = http.request(request)
      response_json = JSON.parse(response.body)
      latest_build = response_json['results']['result'][0]

      resKey = latest_build['buildResultKey']
      resLink = "https://monitechnologies.atlassian.net/builds/browse/#{resKey}"

      return {
        :state => latest_build['state'],
        :number => latest_build['number'],
        :duration => latest_build['buildDurationDescription'],
        :finished => latest_build['buildRelativeTime'],
        :link => resLink,
        :target => latest_build['plan']['planKey']['key']    
      }

    rescue => e
      puts "Error getting bamboo plan status: #{e.backtrace}"
        return {
          :state => 'Unknown',
          :number => '?',
          :duration => '',
          :finished => '',
          :link => '',
          :target => '_blank'
        }
    end
  end
  
  private
  def rest_endpoint
    '/builds/rest/api/latest'
  end
  
  def result_endpoint(plan_key)
    auth_param = ''
    if @credentials && @credentials[:username].length > 0
      auth_param = 'os_authType=basic&'
    end

    "#{rest_endpoint}/result/#{plan_key}.json?#{auth_param}expand=results.result&max-results=1"
  end
end

def get_plan_status(bamboo_uri, credentials, job)
  build = BambooBuild.new(bamboo_uri, credentials)
  build.plan_status(job)
end

configuration[:plan_keys].each do |plan_key|
  SCHEDULER.every configuration[:refresh_rate], :first_in => 0 do |_|
    status = get_plan_status(configuration[:bamboo_uri], configuration[:credentials], plan_key)
    send_event(plan_key, status)
  end
end
