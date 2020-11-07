library(outsider)

# To forward all Docker commands to a remote host:
# 1. Gain ssh access to a remote host
# 2. Ensure Docker is running on the remote machine
# 3. Supply the IP address and authentication args to ssh::ssh_connect
ip_address <- NULL

if (!is.null(ip_address)) {
  # Create an ssh session
  session <- ssh::ssh_connect(host = ip_address)
  
  # Setup the session for running outsider
  ssh_setup(session)
}

# After setup, run outsider as normal

# simplest repo
repo <- 'dombennett/om..hello.world'

if (is_module_installed(repo = repo)) {
  # import
  hello_world <- module_import(fname = 'hello_world', repo = repo)
  
  # run function
  hello_world()
}

# Always ensure to disconnect after a session
if (!is.null(ip_address)) {
  ssh_teardown()
}
