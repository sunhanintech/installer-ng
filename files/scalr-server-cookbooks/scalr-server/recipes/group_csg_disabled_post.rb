supervisor_service 'cloud-service-gateway' do
  description "Stop Cloud Service Gateway service"
  action service_is_up?(node, 'csg') ? [:stop, :disable] : [:disable]
end
