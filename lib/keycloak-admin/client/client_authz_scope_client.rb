module KeycloakAdmin
  class ClientAuthzScopeClient < Client
    def initialize(configuration, realm_client, client_id)
      super(configuration)
      raise ArgumentError.new("realm must be defined") unless realm_client.name_defined?
      @realm_client = realm_client
      @client_id = client_id
    end

    def create!(name, display_name, icon_uri)
      response = save(build(name, display_name, icon_uri))
      ClientAuthzScopeRepresentation.from_hash(JSON.parse(response))
    end

    def list
      response = execute_http do
        RestClient::Resource.new(authz_scopes_url(@client_id), @configuration.rest_client_options).get(headers)
      end
      JSON.parse(response).map { |role_as_hash| ClientAuthzScopeRepresentation.from_hash(role_as_hash) }
    end

    def delete(scope_id)
      execute_http do
        RestClient::Resource.new(authz_scopes_url(@client_id, scope_id), @configuration.rest_client_options).delete(headers)
      end
      true
    end

    def authz_scopes_url(client_id, id = nil)
      if id
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/scope/#{id}"
      else
        "#{@realm_client.realm_admin_url}/clients/#{client_id}/authz/resource-server/scope"
      end
    end

    def save(scope_representation)
      execute_http do
        RestClient::Resource.new(authz_scopes_url(@client_id), @configuration.rest_client_options).post(
          create_payload(scope_representation), headers
        )
      end
    end

    def build(name, display_name, icon_uri)
      scope              = ClientAuthzScopeRepresentation.new
      scope.name         = name
      scope.icon_uri     = icon_uri
      scope.display_name = display_name
      scope
    end
  end
end