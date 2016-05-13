supervisor_service 'cron' do
  description "Stop cron service"
  action service_is_up?(node, 'cron') ? [:stop, :disable] : [:disable]
end
