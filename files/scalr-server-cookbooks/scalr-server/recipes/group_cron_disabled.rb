supervisor_service 'cron' do
  action service_exists?(node, 'cron') ? [:stop, :disable] : [:disable]
end
