
port 4567
workers 2

if ENV['USER'] == 'root'
  user "deploy_okdoki", "deploy_okdoki"
end

preload_app!

on_worker_boot do
  DB.disconnect if defined? DB
end

#
# listen '/home/da01/Documents/unicorn/the_stable.sock'
#
# :tcp_nodelay has no effect on UNIX sockets.
# :tcp_nopush has no effect on UNIX sockets. It is not needed or recommended.
# 
# after_fork do |server,worker|
# 
#    # from: ~/rubyee-gems/unicorn-0.93.3/doc/index.html
#    # drop permissions to "www-data" in the worker
#    # generally there's no reason to start Unicorn as a priviledged user
#    # as it is not recommended to expose Unicorn to public clients.
#    uid, gid = Process.euid, Process.egid
#    user, group = 'www-data', 'www-data'
#    target_uid = Etc.getpwnam(user).uid
#    target_gid = Etc.getgrnam(group).gid
#    worker.tmp.chown(target_uid, target_gid)
#    if uid != target_uid || gid != target_gid
#      Process.initgroups(user, target_gid)
#      Process::GID.change_privilege(target_gid)
#      Process::UID.change_privilege(target_uid)
#    end
# 
# end
