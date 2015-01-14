supervisor_service 'cron' do
  action service_exists?('cron') ? [:stop, :disable] : [:disable]
end
