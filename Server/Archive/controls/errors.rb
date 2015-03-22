error {

  if !request.fullpath["(null)"]
    IssueClient.create(env, options.environment, env['sinatra.error'] )
  end

  read_if_file('public/500.html') || "Programmer error found. I will look into it."

} # === error


not_found {

  if redirectable_get?

    # Try adding a slash to URI.
    redirect_to_slashed_path_info

    # Try downcasing URI.
    redirect_to_downcased_path_info

  end

  # 
  # Log error.
  #
  if !robot? 
    IssueClient.create(env,  options.environment, "404 - Not Found", "Referer: #{env['HTTP_REFERER']}" )
  end

  # 
  # Preset 404 message.
  #
  if request.xhr?
    '<div class="error">Action not found.</div>'
  else
    read_if_file('public/404.html') || "Page not found. Try checking for any typos in the address."
  end

} # === not_found



