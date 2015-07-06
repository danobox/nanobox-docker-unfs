
directory '/datas'

# chown datas for gonano
execute 'chown /datas' do
  command 'chown -R gonano:gonano /datas'
end

file '/data/etc/exports' do
  mode 0644
  owner 'gonano'
  group 'gonano'
  content <<-EOF
/datas 0.0.0.0/0(rw,no_root_squash,insecure)
  EOF
end

# Import rpcbind service (and start)
directory '/etc/service/rpcbind' do
  recursive true
end

file '/etc/service/rpcbind/run' do
  mode 0755
  content <<-EOF
#!/bin/sh -e
export PATH="/data/sbin:/data/bin:/opt/gonano/sbin:/opt/gonano/bin:/opt/local/sbin:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

exec rpcbind -f
  EOF
end

# Import storage service (and start)
directory '/etc/service/storage' do
  recursive true
end

directory '/etc/service/storage/log' do
  recursive true
end

template '/etc/service/storage/log/run' do
  mode 0755
  source 'log-run.erb'
  variables ({ svc: "storage" })
end

template '/etc/service/storage/run' do
  mode 0755
  variables ({ exec: "/data/sbin/unfsd -d 2>&1" })
end

# Configure narc
template '/opt/gonano/etc/narc.conf' do
  variables ({ uid: payload[:uid], app: "nanobox", logtap: payload[:logtap_uri] })
end

directory '/etc/service/narc'

file '/etc/service/narc/run' do
  mode 0755
  content <<-EOF
#!/bin/sh -e
export PATH="/opt/local/sbin:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/gonano/sbin:/opt/gonano/bin"

exec /opt/gonano/bin/narcd /opt/gonano/etc/narc.conf
  EOF
end