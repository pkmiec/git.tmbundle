require 'uri'

class ShowInGithub

  class NotGitHubRepositoryError < Exception; end

  def initialize
    @git = Git.new
  end
  
  def url_for(file_path, branch = nil, selected_line_range = nil)
    branch ||= @git.branch.current.name.to_s
    
    url = file_to_github_url(file_path, branch, best_github_remote)
    url = URI.escape(url)
    if selected_line_range
      url += "##{selected_line_range.uniq.map { |l| "L#{l}" }.join('-')}"
    end
    url
  end
  
  protected
  
  def url_head(user_project, branch='')
    branch = "blob/#{branch}" if branch != ''
    project_path = "/#{user_project[:user]}/#{user_project[:project]}/#{branch}"
    "https://github.com#{project_path}"
  end
  
  def user_project_from_repo(repo)
    if repo =~ %r{github\.com[:/]([^/]+)/(.+)\.git}
      return {:user => $1, :project => $2}
    end
    return 
  end
  
  def file_to_github_url(file, branch, github_remote)
    relative_path = @git.relative_path_for(file)
    repo = repo_for_remote(github_remote)

    user_project = user_project_from_repo(repo)
    if user_project
      File.join(url_head(user_project, branch), relative_path)
    end
  end
  
  def best_github_remote
    remotes = github_remotes
    selected_remote = 'github' if remotes.include?('github')
    selected_remote ||= 'origin' if remotes.include?('origin')
    selected_remote ||= remotes.first
    raise NotGitHubRepositoryError unless selected_remote
    
    return selected_remote
  end
  
  def github_remotes
    @git.remotes.inject([]) do |mem, remote|
      if repo_for_remote(remote) =~ %r{github\.com}
        mem << remote
      end
      mem
    end
  end

  def repo_for_remote(remote)
    @git.config["remote.#{remote}.url"]
  end
  
end
