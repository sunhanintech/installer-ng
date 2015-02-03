supervisor_service 'cron' do
  action service_is_up?(node, 'cron') ? [:stop, :disable] : [:disable]
end
