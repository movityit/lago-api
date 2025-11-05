# frozen_string_literal: true

module Mutations
  module PaymentProviders
    module Sumup
      class Update < Base
        REQUIRED_PERMISSION = "organization:integrations:update"

        graphql_name "UpdateSumupPaymentProvider"
        description "Update Sumup payment provider"

        input_object_class Types::PaymentProviders::UpdateInput

        type Types::PaymentProviders::Sumup
      end
    end
  end
end
