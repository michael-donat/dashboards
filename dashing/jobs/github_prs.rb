require 'octokit'
require 'yaml'

cnf = YAML::load_file(File.join(__dir__, '../', 'config.yml'))['github']

SCHEDULER.every '1m', :first_in => 0 do |job|
  client = Octokit::Client.new(:access_token => cnf['token'])
  my_organization = cnf['organisation']
  repos = client.organization_repositories(my_organization).map { |repo| repo.name }
repos = cnf['prs']['repos']

  open_pull_requests = repos.inject([]) { |pulls, repo|
    client.pull_requests("#{my_organization}/#{repo}", :state => 'open').each do |pull|
      pulls.push({
        title: pull.title,
        repo: repo,
        updated_at: pull.updated_at.strftime("%b %-d %Y, %l:%m %p"),
        creator: "@" + pull.user.login,
        })
    end
    pulls
  }

  len = open_pull_requests.length;

  send_event('pulls', { header: "Pull Requests (#{len})", pulls: open_pull_requests })
end
